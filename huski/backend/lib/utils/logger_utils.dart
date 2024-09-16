// ignore_for_file: avoid_print

import "dart:convert";
import "dart:io";

import "package:huski_common/huski_common.dart";
import "package:shelf/shelf.dart";

class ServiceLogger {
  ServiceLogger(this.service);
  final String service;

  void log({Request? request, Response? response, Json? messages}) {
    final output = {
      "time": DateTime.now().toIso8601String(),
      "pid": pid,
      "service": service,
      "rid": request?.hashCode,
      "uri": request?.url.toString(),
      "method": request?.method,
      "code": response?.statusCode,
      if (messages != null) ...messages,
    };
    print(jsonEncode(output));
  }
}
