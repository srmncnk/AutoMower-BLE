import "package:flutter/material.dart";
import "package:http/http.dart" as http;
import "dart:convert";
import "dart:async";

class CommandPage extends StatefulWidget {
  const CommandPage({super.key});

  @override
  State<CommandPage> createState() => _CommandPageState();
}

class _CommandPageState extends State<CommandPage> {
  String _selectedCommand = "park";
  String? currentCommand;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    fetchCurrentCommand();
  }

  Future<void> fetchCurrentCommand() async {
    final response = await http.get(Uri.parse("https://api.irmancnik.dev/huski/v1/command"));

    if (response.statusCode == 200) {
      final command = json.decode(response.body)["command"];
      setState(() {
        currentCommand = command;
      });

      if (command != null && _timer == null) {
        _timer = Timer.periodic(const Duration(seconds: 3), (timer) async {
          fetchCurrentCommand();
        });
      }
    }
  }

  Future<void> sendCommand(String command) async {
    final response = await http.post(
      Uri.parse("https://api.irmancnik.dev/huski/v1/command"),
      headers: {"Content-Type": "application/json"},
      body: json.encode({"command": command}),
    );

    if (response.statusCode == 200) {
      fetchCurrentCommand();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Command", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DropdownButton<String>(
              value: _selectedCommand,
              onChanged: (String? newValue) {
                setState(() {
                  _selectedCommand = newValue!;
                });
              },
              items: <String>["park", "pause", "override", "resume"].map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            ElevatedButton(
              onPressed: () {
                sendCommand(_selectedCommand);
              },
              child: const Text("Send Command"),
            ),
            if (currentCommand != null) Text("Executing Command: $currentCommand ..."),
          ],
        ),
      ),
    );
  }
}
