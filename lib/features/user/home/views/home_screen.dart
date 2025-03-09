import 'package:flutter/material.dart';

class CustomerHomeScreen extends StatelessWidget {
  const CustomerHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Resellio')),
      body: const Center(
        child: Text('Główny ekran aplikacji'),
      ),
    );
  }
}
