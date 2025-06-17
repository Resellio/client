import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:resellio/features/common/model/address.dart';
import 'package:resellio/features/common/model/event.dart';
import 'package:resellio/features/common/widgets/error_widget.dart';
import 'package:resellio/features/user/cart/bloc/cart_cubit.dart';
import 'package:resellio/features/user/events/bloc/event_details_cubit.dart';
import 'package:resellio/features/user/events/bloc/event_details_state.dart';
import 'package:resellio/features/user/events/model/resell_ticket.dart';

class CustomerEventDetailsScreen extends StatefulWidget {
  const CustomerEventDetailsScreen({
    super.key,
    required this.eventId,
  });

  final String eventId;

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
    return BlocBuilder<EventDetailsCubit, EventDetailsState>(
      builder: (context, state) {
        return switch (state.status) {
          EventDetailsStatus.initial ||
          EventDetailsStatus.loading =>
            const _LoadingView(),
          EventDetailsStatus.failure => Scaffold(
              body: CommonErrorWidget(
                message: state.errorMessage ?? 'Wystąpił błąd',
                onRetry: () => context
                    .read<EventDetailsCubit>()
                    .loadEventDetails(widget.eventId),
                onBack: () => Navigator.of(context).pop(),
              ),
            ),
          EventDetailsStatus.success => _EventDetailsView(
              event: state.event!,
              eventId: widget.eventId,
            ),
        };
      },
    );
  }
}

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

class _EventDetailsView extends StatelessWidget {
  const _EventDetailsView({
    required this.event,
    required this.eventId,
  });

  final Event event;
  final String eventId;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        _SliverEventAppBar(event: event),
        SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _EventHeader(event: event),
              _EventInfo(event: event),
              _EventDescription(event: event),
              _TicketSection(event: event, eventId: eventId),
              _ResellTicketsSection(eventId: eventId),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ],
    );
  }
}

class _SliverEventAppBar extends StatelessWidget {
  const _SliverEventAppBar({required this.event});

  final Event event;

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      iconTheme: IconThemeData(
        color: Colors.white,
        shadows: [
          Shadow(
            color: Colors.black.withOpacity(0.8),
            blurRadius: 4,
          ),
        ],
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            if (event.imageUrl == null)
              CachedNetworkImage(
                imageUrl: 'https://picsum.photos/800/400?random=${event.id}',
                fit: BoxFit.cover,
                width: double.infinity,
              )
            else
              Image.network(
                event.imageUrl!,
                fit: BoxFit.cover,
                width: double.infinity,
              ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withAlpha(150),
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

class _EventHeader extends StatelessWidget {
  const _EventHeader({required this.event});

  final Event event;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (event.categories.isNotEmpty == true) ...[
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: event.categories
                  .map(
                    (category) => Chip(
                      label: Text(category),
                      backgroundColor: Theme.of(context)
                          .colorScheme
                          .primaryContainer
                          .withAlpha(150),
                    ),
                  )
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

class _EventInfo extends StatelessWidget {
  const _EventInfo({required this.event});

  final Event event;

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
    if (address.street.isNotEmpty) {
      parts.add(address.street);
    }
    if (address.houseNumber > 0) {
      parts.add(address.houseNumber.toString());
    }
    if (address.city.isNotEmpty) {
      parts.add(address.city);
    }
    return parts.join(', ');
  }

  String _formatDate(DateTime? date) {
    if (date == null) {
      return 'Brak informacji';
    }
    return DateFormat('EEEE, d MMMM yyyy, HH:mm', 'pl_PL').format(date);
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.title,
    required this.content,
  });

  final IconData icon;
  final String title;
  final String content;

  @override
  Widget build(BuildContext context) {
    return Row(
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

class _EventDescription extends StatelessWidget {
  const _EventDescription({required this.event});

  final Event event;

  @override
  Widget build(BuildContext context) {
    if (event.description.isEmpty) {
      return const SizedBox.shrink();
    }

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

class _TicketSection extends StatelessWidget {
  const _TicketSection({
    required this.event,
    required this.eventId,
  });

  final Event event;
  final String eventId;

  @override
  Widget build(BuildContext context) {
    debugPrint(event.tickets.toString());
    if (event.tickets.isEmpty) {
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
          ...event.tickets.map(
            (ticket) => _TicketCard(
              ticket: ticket,
              eventId: eventId,
            ),
          ),
        ],
      ),
    );
  }
}

class TicketType {
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

  final String id;
  final String description;
  final double price;
  final String currency;
  final int amountAvailable;
}

class _TicketCard extends StatefulWidget {
  const _TicketCard({
    required this.ticket,
    required this.eventId,
  });

  final TicketType ticket;
  final String eventId;

  @override
  State<_TicketCard> createState() => _TicketCardState();
}

class _TicketCardState extends State<_TicketCard> {
  bool _isLoading = false;
  @override
  Widget build(BuildContext context) {
    final isAvailable = widget.ticket.amountAvailable > 0;
    final priceFormatter = NumberFormat.currency(
      locale: 'pl_PL',
      symbol: widget.ticket.currency,
      decimalDigits: 2,
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withAlpha(150),
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
                    widget.ticket.description,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    priceFormatter.format(widget.ticket.price),
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
                      'Dostępne: ${widget.ticket.amountAvailable}',
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
              onPressed: (isAvailable && !_isLoading)
                  ? () => _addToCart(context, widget.ticket)
                  : null,
              child: _isLoading
                  ? const SizedBox(
                      height: 16,
                      width: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(isAvailable ? 'Dodaj do koszyka' : 'Niedostępne'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _addToCart(BuildContext context, TicketType ticket) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final success =
          await context.read<CartCubit>().addTicketToCart(ticket.id, 1);

      if (!context.mounted) {
        return;
      }

      if (success) {
        context
            .read<EventDetailsCubit>()
            .updateTicketAvailabilityLocally(ticket.id, 1);
        SuccessSnackBar.show(
          context,
          'Dodano bilet do koszyka: ${ticket.description}',
        );
      } else {
        ErrorSnackBar.show(
          context,
          'Nie udało się dodać biletu do koszyka: ${ticket.description}',
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}

class _QuantitySelector extends StatefulWidget {
  const _QuantitySelector({
    required this.initialQuantity,
    required this.maxQuantity,
    required this.onQuantityChanged,
  });

  final int initialQuantity;
  final int maxQuantity;
  final ValueChanged<int> onQuantityChanged;

  @override
  State<_QuantitySelector> createState() => _QuantitySelectorState();
}

class _QuantitySelectorState extends State<_QuantitySelector> {
  late int _quantity;

  @override
  void initState() {
    super.initState();
    _quantity = widget.initialQuantity;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          onPressed: _quantity > 1 ? _decrementQuantity : null,
          icon: const Icon(Icons.remove),
          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          padding: EdgeInsets.zero,
        ),
        Container(
          width: 40,
          alignment: Alignment.center,
          child: Text(
            _quantity.toString(),
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        IconButton(
          onPressed: _quantity < widget.maxQuantity ? _incrementQuantity : null,
          icon: const Icon(Icons.add),
          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          padding: EdgeInsets.zero,
        ),
      ],
    );
  }

  void _incrementQuantity() {
    setState(() {
      _quantity++;
    });
    widget.onQuantityChanged(_quantity);
  }

  void _decrementQuantity() {
    setState(() {
      _quantity--;
    });
    widget.onQuantityChanged(_quantity);
  }
}

class _ResellTicketsSection extends StatelessWidget {
  const _ResellTicketsSection({required this.eventId});

  final String eventId;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EventDetailsCubit, EventDetailsState>(
      builder: (context, state) {
        if (state.isLoadingResellTickets) {
          return const Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bilety od innych użytkowników',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 16),
                Center(child: CircularProgressIndicator()),
              ],
            ),
          );
        }

        if (state.resellTicketsError != null) {
          return Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bilety od innych użytkowników',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.errorContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: Theme.of(context).colorScheme.error,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Nie udało się załadować biletów od innych użytkowników',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }

        if (state.resellTickets.isEmpty) {
          return const SizedBox.shrink();
        }

        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Bilety od innych użytkowników',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),
              ...state.resellTickets.map(
                (ticket) => _ResellTicketCard(ticket: ticket),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ResellTicketCard extends StatefulWidget {
  const _ResellTicketCard({required this.ticket});

  final ResellTicket ticket;

  @override
  State<_ResellTicketCard> createState() => _ResellTicketCardState();
}

class _ResellTicketCardState extends State<_ResellTicketCard> {
  bool _isLoading = false;
  @override
  Widget build(BuildContext context) {
    final priceFormatter = NumberFormat.currency(
      locale: 'pl_PL',
      symbol: widget.ticket.currency,
      decimalDigits: 2,
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withAlpha(150),
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
                  Row(
                    children: [
                      Icon(
                        Icons.person_outline,
                        size: 16,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Od użytkownika',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.ticket.description,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    priceFormatter.format(widget.ticket.price),
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  if (widget.ticket.seats.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Miejsca: ${widget.ticket.seats}',
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
                  !_isLoading ? () => _addToCart(context, widget.ticket) : null,
              child: _isLoading
                  ? const SizedBox(
                      height: 16,
                      width: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Dodaj do koszyka'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _addToCart(BuildContext context, ResellTicket ticket) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final result =
          await context.read<CartCubit>().addResellTicketToCart(ticket.id);

      if (!context.mounted) {
        return;
      }

      if (result.success) {
        SuccessSnackBar.show(
          context,
          'Dodano bilet do koszyka: ${ticket.description}',
        );
      } else {
        final errorMessage = result.errorMessage ??
            'Nie udało się dodać biletu do koszyka: ${ticket.description}';
        ErrorSnackBar.show(
          context,
          errorMessage,
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
