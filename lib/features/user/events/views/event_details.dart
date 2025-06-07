import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:resellio/features/common/model/Event/customer_event.dart';
import 'package:resellio/features/user/events/bloc/events_cubit.dart';
import 'package:resellio/features/user/events/bloc/events_state.dart';

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
              ? Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.block, color: Colors.red, size: 18),
                    const SizedBox(width: 4),
                    Text(
                      status!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ],
                )
              : ElevatedButton(
                  onPressed: () {
                    // TODO: Dodać logikę wyboru biletu
                  },
                  child: Text(buttonText ?? 'Wybierz'),
                ),
        ),
      ),
    );
  }
}

class EventDetails extends StatelessWidget {
  const EventDetails({super.key, required this.event});

  final Event event;

  @override
  Widget build(BuildContext context) {
    final priceFormatter =
        NumberFormat.currency(locale: 'pl_PL', symbol: 'zł', decimalDigits: 2);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.location_on, size: 20),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  event.address.city,
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.access_time, size: 20),
              const SizedBox(width: 6),
              Text(
                event.startDate != null
                    ? DateFormat('EEEE, d MMMM yyyy, HH:mm', 'pl_PL')
                        .format(event.startDate!)
                    : 'Brak informacji o dacie',
                style: const TextStyle(fontSize: 14),
              ),
            ],
          ),
          if (event.endDate != null) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.access_time, size: 20),
                const SizedBox(width: 6),
                Text(
                  'Koniec: ${DateFormat('EEEE, d MMMM yyyy, HH:mm', 'pl_PL').format(event.endDate!)}',
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
          ],
          const SizedBox(height: 8),
          if (event.minimumPrice > 0 || event.maximumPrice > 0)
            Row(
              children: [
                const Icon(Icons.attach_money, size: 20),
                const SizedBox(width: 6),
                Text(
                  event.minimumPrice == event.maximumPrice
                      ? 'Cena: ${priceFormatter.format(event.minimumPrice)}'
                      : 'Cena: od ${priceFormatter.format(event.minimumPrice)} do ${priceFormatter.format(event.maximumPrice)}',
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
          const SizedBox(height: 8),
          if (event.minimumAge > 0)
            Row(
              children: [
                const Icon(Icons.person, size: 20),
                const SizedBox(width: 6),
                Text(
                  'Minimalny wiek: ${event.minimumAge} lat',
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class CustomerEventDetailsScreen extends StatelessWidget {
  const CustomerEventDetailsScreen({super.key, required this.eventId});

  final String eventId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Szczegóły wydarzenia (WIP)'),
        centerTitle: true,
      ),
      body: BlocBuilder<EventsCubit, EventsState>(
        builder: (context, state) {
          if (state.status == EventsStatus.initial ||
              (state.status == EventsStatus.loading && state.events.isEmpty)) {
            return const Center(child: CircularProgressIndicator());
          } else if (state.status == EventsStatus.failure &&
              state.events.isEmpty) {
            return Center(
              child:
                  Text(state.errorMessage ?? 'Wystąpił błąd ładowania danych.'),
            );
          } else {
            final event = state.events.firstWhere(
              (e) => e.id == eventId,
            );

            return Padding(
              padding: const EdgeInsets.all(16),
              child: Card(
                color: Theme.of(context).colorScheme.primaryContainer,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 4,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Zdjęcie
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
                            'https://picsum.photos/200/300?random=${event.id}',
                            fit: BoxFit.cover,
                            width: double.infinity,
                            errorBuilder: (context, error, stackTrace) =>
                                const Center(
                                    child: Icon(Icons.broken_image, size: 50)),
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) {
                                return child;
                              }
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            },
                          ),
                        ),
                      ),
                      // Tagi/Chipsy
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              if (event.address.city != null &&
                                  event.address.city!.isNotEmpty) ...[
                                Chip(label: Text(event.address.city!)),
                                const SizedBox(width: 4),
                              ],
                              if (event.categories != null)
                                ...event.categories!
                                    .map((category) => Padding(
                                          padding:
                                              const EdgeInsets.only(right: 4.0),
                                          child: Chip(label: Text(category)),
                                        ))
                                    .toList(),
                            ],
                          ),
                        ),
                      ),
                      // Nazwa wydarzenia
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          event.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 32,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Szczegóły wydarzenia
                      EventDetails(event: event),
                      const SizedBox(height: 16),
                      // Opis
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Text(
                          event.description,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Bilety
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
                        padding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
            );
          }
        },
      ),
    );
  }
}
