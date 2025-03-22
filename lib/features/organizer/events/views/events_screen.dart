import 'package:flutter/material.dart';
import 'new_event_screen.dart';

class OrganizerEventsScreen extends StatelessWidget {
  const OrganizerEventsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Organizer Events'),
      ),
      body: const Center(
        child: Text('test'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push<Widget>(
            context,
            MaterialPageRoute<OrganizerNewEventScreen>(
              builder: (context) => const OrganizerNewEventScreen(),
            ),
          );
        },
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
