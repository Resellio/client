import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:resellio/features/common/model/event.dart';
import 'package:resellio/features/user/events/bloc/event_cubit.dart';

class TicketOption extends StatelessWidget {
  const TicketOption({
    super.key,
    required this.title,
    required this.price,
    this.status,
    this.buttonText,
  });
  final String title;
  final String price;
  final String? status;
  final String? buttonText;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFEAEAFE),
          borderRadius: BorderRadius.circular(20),
        ),
        child: ListTile(
          title: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(price),
          trailing: status != null
              ? Text(
                  status!,
                  style: const TextStyle(color: Colors.red),
                )
              : ElevatedButton(
                  onPressed: () {},
                  child: Text(buttonText ?? 'Choose'),
                ),
        ),
      ),
    );
  }
}

class CustomerEventDetails extends StatelessWidget {
  const CustomerEventDetails({super.key, required this.eventId});

  final String eventId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => EventsCubit()..getEvents(),
      child: BlocBuilder<EventsCubit, EventsState>(
        builder: (context, state) {
          if (state is EventInitial) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is EventsLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is EventsLoaded) {
            final event = state.events.firstWhere(
              (event) => event.id == eventId,
              orElse: () => Event(
                id: 'no_event',
                name: 'Event Not Found',
                description: '',
                date: DateTime.now(),
                location: '',
                image: '',
              ),
            );
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Stack(
                children: [
                  Card(
                    color: const Color.fromARGB(255, 204, 178, 219),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 4,
                    child: Padding(
                      padding:
                          const EdgeInsets.only(bottom: 60), // space for FAB
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ConstrainedBox(
                              constraints: const BoxConstraints(
                                maxHeight: 200,
                                minHeight: 200,
                              ),
                              child: ClipRRect(
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(8),
                                  topRight: Radius.circular(8),
                                ),
                                child: Image.network(
                                  event.image,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                ),
                              ),
                            ),
                            const Padding(
                              padding: EdgeInsets.all(8),
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  children: [
                                    Icon(Icons.arrow_back),
                                    SizedBox(width: 8),
                                    Chip(label: Text('Warszawa')),
                                    SizedBox(width: 4),
                                    Chip(label: Text('Koncert')),
                                    SizedBox(width: 4),
                                    Chip(
                                      label: Text('18+'),
                                      backgroundColor: Colors.pinkAccent,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 12),
                              child: Text(
                                event.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 32,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Expanded(
                                        child: Row(
                                          children: [
                                            Icon(Icons.location_on, size: 20),
                                            SizedBox(width: 6),
                                            Expanded(
                                              child: Text(
                                                'Stefana Batorego 10, 02-591 Warszawa',
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  decoration:
                                                      TextDecoration.underline,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      FloatingActionButton.small(
                                        heroTag: 'mapButton',
                                        onPressed: () {
                                          // TODO
                                        },
                                        backgroundColor: Colors.grey[200],
                                        child: const Icon(
                                          Icons.open_in_new,
                                          size: 18,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  const Row(
                                    children: [
                                      Icon(Icons.access_time, size: 20),
                                      SizedBox(width: 6),
                                      Text(
                                        'Niedziela, 9 lutego 2025',
                                        style: TextStyle(fontSize: 14),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const Padding(
                              padding: EdgeInsets.all(12),
                              child: Text(
                                'Kult Akustik to trasa koncertowa, która zabierze fanów w niezwykłą podróż. Usłyszysz największe hity w wersji bez prądu. Start: 9 lutego 2025!',
                                style: TextStyle(fontSize: 14),
                              ),
                            ),
                            const SizedBox(height: 16),
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 12),
                              child: Text(
                                'Bilety od organizatora',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                            ),
                            const TicketOption(
                              title: 'Normalny',
                              price: '39,99 zł',
                              status: 'wyprzedane',
                            ),
                            const TicketOption(
                              title: 'Ulgowy',
                              price: '19,99 zł',
                            ),
                            const TicketOption(
                              title: 'VIP',
                              price: '129,99 zł',
                              buttonText: 'Wybierz na schemacie',
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              child: Text(
                                'Bilety od społeczności',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                            ),
                            const TicketOption(
                              title: 'Normalny',
                              price: 'od 54,99 zł',
                              buttonText: 'Wybierz',
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 10,
                    right: 10,
                    child: FloatingActionButton(
                      backgroundColor: Colors.deepPurple,
                      onPressed: () {
                        //TODO
                      },
                      child: const Icon(
                        Icons.local_activity,
                      ),
                    ),
                  ),
                ],
              ),
            );
          } else if (state is EventsError) {
            return Center(child: Text(state.message));
          } else {
            return const Center(child: Text('Something went wrong'));
          }
        },
      ),
    );
  }
}
