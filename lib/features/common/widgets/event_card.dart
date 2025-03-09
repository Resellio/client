import 'package:flutter/material.dart';
import 'package:resellio/features/common/model/event.dart';

class EventCard extends StatelessWidget {
  const EventCard({required this.event, required this.onTap, super.key});

  final Event event;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Card(
        child: Column(
          children: [
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 200, minHeight: 200),
              child: Image.network(event.image),
            ),
            ListTile(
              title: Text(event.name),
              subtitle: Text(event.description),
            ),
          ],
        ),
      ),
    );
  }
}
