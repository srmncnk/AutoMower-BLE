import "package:flutter/material.dart";
import "package:font_awesome_flutter/font_awesome_flutter.dart";
import "dart:async";

import "../api/api.dart";

class CommandPage extends StatefulWidget {
  const CommandPage({super.key});

  @override
  State<CommandPage> createState() => _CommandPageState();
}

class _CommandPageState extends State<CommandPage> {
  String? currentCommand;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    fetchCurrentCommand();
  }

  Future<void> fetchCurrentCommand() async {
    final command = await HuskiApi.getCommand();
    setState(() {
      currentCommand = command;
    });

    if (command != null && _timer == null) {
      _timer = Timer.periodic(const Duration(seconds: 3), (timer) async {
        fetchCurrentCommand();
      });
    }
  }

  Future<void> sendCommand(String command) async {
    if (await HuskiApi.setCommand(command)) {
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
        title: const Text("Commands", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildButton("Resume", "resume", FontAwesomeIcons.play),
            _buildButton("Pause", "pause", FontAwesomeIcons.pause),
            _buildButton("Park", "park", FontAwesomeIcons.house),
            const SizedBox(height: 16),
            if (currentCommand != null)
              Theme(
                data: Theme.of(context).copyWith(
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade800,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Executing "$currentCommand"', style: TextStyle(fontSize: 16, color: Colors.grey[100])),
                          Text("Please wait ...", style: TextStyle(fontSize: 12, color: Colors.grey[400])),
                        ],
                      ),
                      const SizedBox(
                        height: 12,
                        width: 12,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildButton(String title, String command, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 64, vertical: 8),
      child: ElevatedButton(
        onPressed: () => sendCommand(command),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.teal.shade200,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(width: 32),
            FaIcon(icon, color: Colors.black, size: 12),
            const SizedBox(width: 16),
            Text(
              title,
              style: const TextStyle(color: Colors.black), // Set the text color to white
            ),
          ],
        ),
      ),
    );
  }
}
