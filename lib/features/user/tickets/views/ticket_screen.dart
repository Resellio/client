import 'package:flutter/material.dart';

class CustomerTicketScreen extends StatelessWidget {
  const CustomerTicketScreen({super.key, required this.ticketId});

  final String ticketId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ticket')),
      body: const Center(
        child: Text('Ticket'),
      ),
    );
  }
}
