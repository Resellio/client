import 'package:flutter/material.dart';

class CustomerEventDetails extends StatelessWidget {
  const CustomerEventDetails({super.key, required this.eventId});

  final String eventId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Wydarzenie')),
      body: Center(
        child: Text('Event id: $eventId'),
      ),
    );
  }
}
