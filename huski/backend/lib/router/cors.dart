import 'package:shelf/shelf.dart';
import 'package:shelf_cors_headers/shelf_cors_headers.dart';

const _defaultHeadersList = [
  'accept',
  'accept-encoding',
  'authorization',
  'content-type',
  'dnt',
  'origin',
  'user-agent',
];

const _defaultMethodsList = ['DELETE', 'GET', 'OPTIONS', 'PATCH', 'POST', 'PUT'];

Map<String, String> _defaultHeaders = {
  ACCESS_CONTROL_EXPOSE_HEADERS: '',
  ACCESS_CONTROL_ALLOW_CREDENTIALS: 'true',
  ACCESS_CONTROL_ALLOW_HEADERS: _defaultHeadersList.join(','),
  ACCESS_CONTROL_ALLOW_METHODS: _defaultMethodsList.join(','),
  ACCESS_CONTROL_ALLOW_ORIGIN: '*', // uncomment this while debugging
  ACCESS_CONTROL_MAX_AGE: '86400',
};

final _defaultHeadersAll = _defaultHeaders.map((key, value) => MapEntry(key, [value]));

Middleware middleware() {
  return (Handler handler) {
    return (Request request) async {
      if (request.method == 'OPTIONS') {
        return Response.ok(null, headers: _defaultHeadersAll);
      }

      final response = await handler(request);
      return response.change(headers: {...response.headersAll, ..._defaultHeadersAll});
    };
  };
}
