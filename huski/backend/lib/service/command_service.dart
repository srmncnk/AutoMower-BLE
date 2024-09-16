import 'dart:async';
import 'dart:convert';

import 'package:huski_common/huski_common.dart';
import 'package:shelf/shelf.dart';

import '../repository/redis_repository.dart';
import '../utils/logger_utils.dart';
import '../utils/render_utils.dart';

class CommandService with ServiceRenderer {
  CommandService(this.repository);

  final RedisRepository repository;
  final ServiceLogger log = ServiceLogger("CommandService");

  Future<Response> get(Request request) async {
    final command = await repository.loadCommand();
    return renderSuccess({"command": command}, request, log);
  }

  Future<Response> post(Request request) async {
    final body = await request.readAsString();
    if (body.isEmpty) {
      return renderError("No body", request, log);
    }

    final json = jsonDecode(body) as Json;
    final command = json["command"] as String?;
    if (command == null) {
      return renderError("Invalid payload", request, log);
    }

    await repository.saveCommand(command);
    return renderSuccess(body, request, log);
  }
}
