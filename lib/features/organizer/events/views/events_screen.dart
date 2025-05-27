import 'package:flutter/material.dart';
import 'package:resellio/routes/organizer_routes.dart';

class OrganizerEventsScreen extends StatelessWidget {
  const OrganizerEventsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: const Center(
        child: Text('Wydarzenia organizatora'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => const OrganizerNewEventRoute().go(context),
        backgroundColor: Colors.blue,
        tooltip: 'Stwórz nowe wydarzenie',
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
