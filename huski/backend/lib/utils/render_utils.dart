// ignore_for_file: avoid_print

import "dart:convert";

import "package:shelf/shelf.dart";

import "json_utils.dart";
import "logger_utils.dart";

mixin ServiceRenderer {
  Response renderSuccess(dynamic body, Request request, ServiceLogger log, [Json? messages]) => //
      render(200, body, request, log, messages);
  Response renderError(String errorMessage, Request request, ServiceLogger log, [Json? messages]) =>
      render(400, {"error": errorMessage}, request, log, messages);
  Response renderUnauthorized(Request request, ServiceLogger log, [Json? messages]) =>
      render(401, {"error": "unauthorized"}, request, log, messages);
  Response renderForbidden(Request request, ServiceLogger log, [Json? messages]) =>
      render(403, {"error": "forbidden"}, request, log, messages);
  Response renderNotFound(Request request, ServiceLogger log, [Json? messages]) =>
      render(404, {"error": "not found"}, request, log, messages);
  Response renderCrash(Request request, ServiceLogger log, [Object? exception]) =>
      render(500, {"error": "internal server error"}, request, log, {"exception": exception?.toString()});

  Response render(int statusCode, dynamic body, Request request, ServiceLogger log, [Json? messages]) {
    final response = Response(
      statusCode,
      body: body is Json || body is List ? jsonEncode(body) : body,
      headers: {"Content-Type": "application/json"},
    );
    log.log(request: request, response: response, messages: messages);
    return response;
  }
}
