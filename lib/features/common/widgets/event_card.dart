import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:resellio/features/common/model/event.dart';

String getDateString(DateTime dateTime) {
  final dateFormat = DateFormat('EEEE, d MMMM yyyy, HH:mm', 'pl_PL');
  return dateFormat.format(dateTime);
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
        borderRadius: BorderRadius.circular(8),
        child: Stack(
          children: [
            Padding(
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
                        imageUrl:
                            'https://picsum.photos/200/300?random=${event.id}',
                        fit: BoxFit.cover,
                        width: double.infinity,
                      ),
                    ),
                  ),
                  if (event.categories.isNotEmpty)
                    ScrollConfiguration(
                      behavior: ScrollConfiguration.of(context)
                          .copyWith(scrollbars: false),
                      child: SizedBox(
                        height: 35,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: event.categories.length,
                          itemBuilder: (context, index) {
                            return Chip(
                              label: Text(
                                event.categories[index],
                                style: const TextStyle(
                                  fontSize: 12,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.only(left: 16, right: 16, top: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          event.name,
                          style: const TextStyle(
                            fontSize: 24,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          event.address.street,
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
                          event.address.country,
                        ),
                        Text(
                          getDateString(event.startDate!),
                        ),
                        // Text(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              right: 16,
              bottom: 16,
              child: Text(
                'Od ${event.minimumPrice} PLN',
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
