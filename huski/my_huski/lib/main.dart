import "package:flutter/material.dart";
import 'package:google_fonts/google_fonts.dart';

import "ui/command_page.dart";
import "ui/status_page.dart";

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "My Huski",
      theme: ThemeData.dark(useMaterial3: true).copyWith(
        colorScheme: const ColorScheme.dark().copyWith(primary: Colors.teal.shade200),
        textTheme: GoogleFonts.ubuntuTextTheme(),
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  static const List<Widget> _pages = <Widget>[
    StatusPage(),
    CommandPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(child: Text("Huski • Automower® 305")),
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: "Reports",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.control_camera),
            label: "Command",
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.teal.shade200,
        onTap: _onItemTapped,
      ),
    );
  }
}
