import 'package:flutter/material.dart';

class CustomerTicketsScreen extends StatelessWidget {
  const CustomerTicketsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bilety')),
      body: const Center(
        child: Text('Bileety'),
      ),
    );
  }
}
