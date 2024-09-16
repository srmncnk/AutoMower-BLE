import "dart:convert";

import "package:http/http.dart" as http;
import "package:huski_common/huski_common.dart";

class HuskiApi {
  static const _baseApi = "https://api.irmancnik.dev/huski/v1";

  static Future<List<MowerState>> getState(int page, int limit, bool distinct) async {
    final response = await http.get(Uri.parse("$_baseApi/state?page=$page&limit=$limit&distinct=$distinct"));

    if (response.statusCode == 200) {
      final Map<String, dynamic> json = jsonDecode(response.body);
      final List<dynamic> jsonList = json["list"];
      final List<MowerState> list = jsonList.map((json) => MowerState.fromJson(json)).toList();
      return list;
    } else {
      throw Exception("Failed to load state");
    }
  }

  static Future<String?> getCommand() async {
    final response = await http.get(Uri.parse("$_baseApi/command"));
    if (response.statusCode == 200) {
      final command = json.decode(response.body)["command"];
      return command;
    }
    return null;
  }

  static Future<bool> setCommand(String command) async {
    final response = await http.post(Uri.parse("$_baseApi/command"),
      headers: {"Content-Type": "application/json"},
      body: json.encode({"command": command}),
    );
    return response.statusCode == 200;
  }
}
