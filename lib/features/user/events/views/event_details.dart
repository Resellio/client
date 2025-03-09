import 'package:flutter/material.dart';

class CustomerEventDetails extends StatelessWidget {
  const CustomerEventDetails({super.key, required this.eventId});

  final String eventId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Event Details')),
      body: Center(
        child: Text('Event Details $eventId'),
      ),
    );
  }
}
