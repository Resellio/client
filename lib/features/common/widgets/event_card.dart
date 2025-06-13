import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:resellio/features/common/model/event.dart';
import 'package:resellio/features/common/style/app_colors.dart';

String getDateString(DateTime dateTime) {
  final dateFormat = DateFormat('EEEE, d MMMM yyyy, HH:mm', 'pl_PL');
  return dateFormat.format(dateTime);
}

class EventCard extends StatelessWidget {
  const EventCard({
    required this.event,
    required this.onTap,
    this.onLongPress,
    super.key,
  });

  final Event event;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(8),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
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
                            'https://picsum.photos/800/400?random=${event.id}',
                        fit: BoxFit.cover,
                        width: double.infinity,
                      ),
                    ),
                  ),
                  if (event.categories.isNotEmpty)
                    ScrollConfiguration(
                      behavior: ScrollConfiguration.of(context)
                          .copyWith(scrollbars: false),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxHeight: 50),
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: event.categories.length,
                            itemBuilder: (context, index) {
                              return Center(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 4,
                                    horizontal: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryLight,
                                    border: Border.all(
                                      color: Colors.grey[400]!,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    event.categories[index],
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: Colors.black87,
                                      fontWeight: FontWeight.normal,
                                    ),
                                  ),
                                ),
                              );
                            },
                            separatorBuilder: (context, index) =>
                                const SizedBox(width: 8),
                          ),
                        ),
                      ),
                    ),
                  if (event.categories.isEmpty) const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.only(left: 16, right: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          event.name,
                          style: const TextStyle(
                            fontSize: 24,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          getDateString(event.startDate!),
                        ),
                        Text(
                          event.address.fullAddress,
                          style: TextStyle(
                            color: Colors.grey[700],
                          ),
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
                // TODO currency
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
