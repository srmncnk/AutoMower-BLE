import 'dart:async';
import 'dart:convert';

import 'package:huski_common/huski_common.dart';
import 'package:shelf/shelf.dart';

import '../repository/redis_repository.dart';
import '../utils/logger_utils.dart';
import '../utils/render_utils.dart';

class PingService with ServiceRenderer {
  PingService(this.repository);

  final RedisRepository repository;
  final ServiceLogger log = ServiceLogger("PingService");

  Future<Response> get(Request request) async {
    final ping = await repository.loadPing();
    return renderSuccess({"ping": ping}, request, log);
  }

  Future<Response> post(Request request) async {
    final body = await request.readAsString();
    if (body.isEmpty) {
      return renderError("No body", request, log);
    }

    final json = jsonDecode(body) as Json;
    final ping = json["ping"] as String?;
    if (ping == null) {
      return renderError("Invalid payload", request, log);
    }

    await repository.savePing(ping);
    return renderSuccess(body, request, log);
  }
}
