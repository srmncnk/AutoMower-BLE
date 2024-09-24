import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:external_app_launcher/external_app_launcher.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late Timer openTimer;
  late Timer closeTimer;

  @override
  void initState() {
    super.initState();
    openTimer = Timer(const Duration(seconds: 5), () {
      LaunchApp.openApp(androidPackageName: "com.irmancnik.findmyhuski");
    });
    closeTimer = Timer(const Duration(seconds: 10), () {
      exit(0);
    });
  }

  @override
  void dispose() {
    super.dispose();
    openTimer.cancel();
    closeTimer.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Restart Huski",
      theme: ThemeData.dark(useMaterial3: true).copyWith(colorScheme: const ColorScheme.dark().copyWith(primary: Colors.teal.shade200)),
      home: Scaffold(
        appBar: AppBar(title: const Center(child: Text("Huski Restarter"))),
        body: Container(),
      ),
    );
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}
