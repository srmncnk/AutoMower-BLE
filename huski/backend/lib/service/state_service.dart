import 'dart:async';
import 'dart:convert';

import 'package:shelf/shelf.dart';

import '../repository/redis_repository.dart';
import '../repository/state_repository.dart';
import '../utils/json_utils.dart';
import '../utils/logger_utils.dart';
import '../utils/notify_utils.dart';
import '../utils/render_utils.dart';
import '../utils/time_utils.dart';

class StateService with ServiceRenderer {
  StateService(this.stateRepository, this.redisRepository, this.notifier);

  final StateRepository stateRepository;
  final RedisRepository redisRepository;
  final Notifier notifier;
  final ServiceLogger log = ServiceLogger("StateService");

  Future<Response> get(Request request) async {
    final list = await stateRepository.list();
    return renderSuccess({"list": list.toJsonList()}, request, log);
  }

  Future<Response> post(Request request) async {
    final body = await request.readAsString();
    if (body.isEmpty) {
      return renderError("No body", request, log);
    }

    final json = jsonDecode(body) as Json;
    final state = State.fromJson(json);
    final lastHandledMessage = await redisRepository.loadLastHandledMessage();
    if (lastHandledMessage != "${state.lastMessage}:${state.lastMessageTime}") {
      await redisRepository.saveLastHandledMessage("${state.lastMessage}:${state.lastMessageTime}");
      notifier.notify(state);
    }

    final newState = await stateRepository.save(state);
    if (newState == null) {
      return renderError("State not saved", request, log);
    }

    await stateRepository.deleteWhereOlderThan(DateTime.now().toUtc().subtract(30.days));
    final command = await redisRepository.loadCommand();
    await redisRepository.saveCommand(null);
    return renderSuccess({"command": command}, request, log);
  }
}
