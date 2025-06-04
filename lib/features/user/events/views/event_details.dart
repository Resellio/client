import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:resellio/features/common/model/address.dart';
import 'package:resellio/features/common/model/event.dart';
import 'package:resellio/features/user/events/bloc/event_details_cubit.dart';
import 'package:resellio/features/user/events/bloc/event_details_state.dart';

class CustomerEventDetailsScreen extends StatefulWidget {
  final String eventId;

  const CustomerEventDetailsScreen({
    super.key,
    required this.eventId,
  });

  @override
  State<CustomerEventDetailsScreen> createState() => _EventDetailsScreenState();
}

class _EventDetailsScreenState extends State<CustomerEventDetailsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<EventDetailsCubit>().loadEventDetails(widget.eventId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<EventDetailsCubit, EventDetailsState>(
        builder: (context, state) {
          return switch (state.status) {
            EventDetailsStatus.initial ||
            EventDetailsStatus.loading =>
              const _LoadingView(),
            EventDetailsStatus.failure => _ErrorView(
                message: state.errorMessage ?? 'Wystąpił błąd',
                onRetry: () => context
                    .read<EventDetailsCubit>()
                    .loadEventDetails(widget.eventId),
              ),
            EventDetailsStatus.success =>
              _EventDetailsView(event: state.event!),
          };
        },
      ),
    );
  }
}

// Loading View
class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}

// Error View
class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: onRetry,
              child: const Text('Spróbuj ponownie'),
            ),
          ],
        ),
      ),
    );
  }
}

// Event Details View
class _EventDetailsView extends StatelessWidget {
  final Event event;

  const _EventDetailsView({required this.event});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _EventAppBar(event: event),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _EventHeader(event: event),
                _EventInfo(event: event),
                _EventDescription(event: event),
                _TicketSection(event: event),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Event App Bar with Image
class _EventAppBar extends StatelessWidget {
  final Event event;

  const _EventAppBar({required this.event});

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              'https://picsum.photos/400/300?random=${event.id}',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                color: Theme.of(context).colorScheme.surfaceVariant,
                child: const Icon(
                  Icons.image_not_supported,
                  size: 64,
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.7),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Event Header with Title and Categories
class _EventHeader extends StatelessWidget {
  final Event event;

  const _EventHeader({required this.event});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (event.categories?.isNotEmpty == true) ...[
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: event.categories!
                  .map((category) => Chip(
                        label: Text(category),
                        backgroundColor: Theme.of(context)
                            .colorScheme
                            .primaryContainer
                            .withOpacity(0.5),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 16),
          ],
          Text(
            event.name,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }
}

// Event Info Section
class _EventInfo extends StatelessWidget {
  final Event event;

  const _EventInfo({required this.event});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          _InfoRow(
            icon: Icons.location_on,
            title: 'Lokalizacja',
            content: _formatAddress(event.address),
          ),
          const SizedBox(height: 16),
          _InfoRow(
            icon: Icons.calendar_today,
            title: 'Data rozpoczęcia',
            content: _formatDate(event.startDate),
          ),
          if (event.endDate != null) ...[
            const SizedBox(height: 16),
            _InfoRow(
              icon: Icons.calendar_today_outlined,
              title: 'Data zakończenia',
              content: _formatDate(event.endDate),
            ),
          ],
          if (event.minimumAge > 0) ...[
            const SizedBox(height: 16),
            _InfoRow(
              icon: Icons.person,
              title: 'Ograniczenie wiekowe',
              content: 'Min. ${event.minimumAge} lat',
            ),
          ],
        ],
      ),
    );
  }

  String _formatAddress(Address address) {
    final parts = <String>[];
    if (address.street.isNotEmpty) parts.add(address.street);
    if (address.houseNumber > 0) parts.add(address.houseNumber.toString());
    if (address.city.isNotEmpty) parts.add(address.city);
    return parts.join(', ');
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Brak informacji';
    return DateFormat('EEEE, d MMMM yyyy, HH:mm', 'pl_PL').format(date);
  }
}

// Info Row Component
class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String content;

  const _InfoRow({
    required this.icon,
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 20,
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: 2),
              Text(
                content,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// Event Description Section
class _EventDescription extends StatelessWidget {
  final Event event;

  const _EventDescription({required this.event});

  @override
  Widget build(BuildContext context) {
    if (event.description.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Opis wydarzenia',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),
          Text(
            event.description,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

// Ticket Section
class _TicketSection extends StatelessWidget {
  final Event event;

  const _TicketSection({required this.event});

  @override
  Widget build(BuildContext context) {
    print(event.tickets);
    if (event.tickets == null || event.tickets!.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(20),
        child: Text(
          'Brak dostępnych biletów',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Dostępne bilety',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          ...event.tickets!.map((ticket) => _TicketCard(ticket: ticket)),
        ],
      ),
    );
  }
}

class TicketType {
  final String id;
  final String description;
  final double price;
  final String currency;
  final int amountAvailable;

  const TicketType({
    required this.id,
    required this.description,
    required this.price,
    required this.currency,
    required this.amountAvailable,
  });

  factory TicketType.fromJson(Map<String, dynamic> json) {
    return TicketType(
      id: json['id'] as String? ?? '',
      description: json['description'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      currency: json['currency'] as String? ?? 'PLN',
      amountAvailable: json['amountAvailable'] as int? ?? 0,
    );
  }
}

class _TicketCard extends StatelessWidget {
  final TicketType ticket;

  const _TicketCard({required this.ticket});

  @override
  Widget build(BuildContext context) {
    final isAvailable = ticket.amountAvailable > 0;
    final priceFormatter = NumberFormat.currency(
      locale: 'pl_PL',
      symbol: ticket.currency,
      decimalDigits: 2,
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ticket.description,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    priceFormatter.format(ticket.price),
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  if (!isAvailable) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Wyprzedane',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.error,
                          ),
                    ),
                  ] else ...[
                    const SizedBox(height: 4),
                    Text(
                      'Dostępne: ${ticket.amountAvailable}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 16),
            ElevatedButton(
              onPressed:
                  isAvailable ? () => _selectTicket(context, ticket) : null,
              child: Text(isAvailable ? 'Wybierz' : 'Niedostępne'),
            ),
          ],
        ),
      ),
    );
  }

  void _selectTicket(BuildContext context, TicketType ticket) {
    // TODO: Implement ticket selection logic
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Wybrano bilet: ${ticket.description}'),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
