import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:resellio/features/common/model/event.dart';

String getDateString(DateTime dateTime) {
  final dateFormat = DateFormat('EEEE, d MMMM yyyy', 'pl_PL');
  return dateFormat.format(dateTime);
}

String getTimeString(DateTime dateTime) {
  final timeFormat = DateFormat('HH:mm');
  return timeFormat.format(dateTime);
}

class EventCard extends StatelessWidget {
  const EventCard({required this.event, required this.onTap, super.key});

  final Event event;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ConstrainedBox(
                constraints:
                    const BoxConstraints(maxHeight: 200, minHeight: 200),
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(8),
                    topRight: Radius.circular(8),
                  ),
                  child: CachedNetworkImage(
                    imageUrl: event.image,
                    fit: BoxFit.cover,
                    width: double.infinity,
                  ),
                ),
              ),
              ScrollConfiguration(
                behavior:
                    ScrollConfiguration.of(context).copyWith(scrollbars: false),
                child: SizedBox(
                  height: 35,
                  child: ListView(
                    padding: const EdgeInsets.all(5),
                    scrollDirection: Axis.horizontal,
                    children: [
                      //TODO change to Chip
                      ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 1,
                            vertical: 1,
                          ),
                        ),
                        child: const Text('Tag 1'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 1,
                            vertical: 1,
                          ),
                        ),
                        child: const Text('Tag 2'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 1,
                            vertical: 1,
                          ),
                        ),
                        child: const Text('Tag 3'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 1,
                            vertical: 1,
                          ),
                        ),
                        child: const Text('Tag 4'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 1,
                            vertical: 1,
                          ),
                        ),
                        child: const Text('Tag 5'),
                      ),
                    ],
                  ),
                ),
              ),
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          event.name,
                          style: const TextStyle(
                            fontSize: 24,
                            letterSpacing: 1.2,
                          ),
                        ),
                        Text(
                          event.location,
                          style: const TextStyle(
                            fontSize: 16,
                            height: 0.2,
                            color: Color.fromARGB(255, 93, 93, 93),
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Text(
                          event.description,
                        ),
                        Text(
                          getDateString(event.date),
                        ),
                        Text(
                          getTimeString(event.date),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Align(
                      alignment: Alignment.bottomRight,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 16),
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 1,
                              vertical: 1,
                            ),
                          ),
                          child: const Text('Buy'),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
