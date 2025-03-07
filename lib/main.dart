import 'package:flutter/material.dart';
import 'package:resellio/features/user/events/views/event_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Resellio',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const EventScreen(),
    );
  }
}
