import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:resellio/features/auth/bloc/auth_cubit.dart';
import 'package:resellio/routes/organizer_routes.dart';
import 'package:resellio/features/organizer/events/bloc/events_cubit.dart';
import 'package:resellio/features/organizer/events/bloc/events_state.dart';
import 'package:resellio/features/common/model/Event/organizer_event.dart';
import 'package:resellio/features/common/data/api.dart';
import 'package:resellio/features/auth/bloc/auth_state.dart';
import 'package:resellio/routes/organizer_routes.dart';

class OrganizerEventsScreen extends StatelessWidget {
  const OrganizerEventsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: _createCubit,
      child: const OrganizerEventsView(),
    );
  }

  OrganizerEventsCubit _createCubit(BuildContext context) {
    final authState = context.read<AuthCubit>().state;
    final cubit = OrganizerEventsCubit(apiService: context.read());
    if (authState is AuthorizedOrganizer) {
      cubit.fetchEvents(authState.user.token, 0);
    } else {
      cubit.setError('you are not a verified organizer');
    }
    return cubit;
  }
}

class OrganizerEventsView extends StatefulWidget {
  const OrganizerEventsView({super.key});

  @override
  State<OrganizerEventsView> createState() => _OrganizerEventsViewState();
}

class _OrganizerEventsViewState extends State<OrganizerEventsView> {
  final ScrollController _scrollController = ScrollController();
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isAtBottom && !_isLoadingMore) {
      _loadMoreEvents();
    }
  }

  bool get _isAtBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9); // Trigger when 90% scrolled
  }

  void _loadMoreEvents() {
    final state = context.read<OrganizerEventsCubit>().state;
    final authState = context.read<AuthCubit>().state;
    if (state is OrganizerEventLoadedState &&
        state.hasNextPage &&
        !_isLoadingMore &&
        authState is AuthorizedOrganizer) {
      setState(() {
        _isLoadingMore = true;
      });
      final int page =
          (state.events.length / OrganizerEventsCubit.pageSize).ceil();
      context
          .read<OrganizerEventsCubit>()
          .fetchEvents(authState.user.token, page)
          .then((_) {
        setState(() {
          _isLoadingMore = false;
        });
      });
    }
  }

  Future<void> _refreshEvents() async {
    final cubit = context.read<OrganizerEventsCubit>();
    final authState = context.read<AuthCubit>().state;
    cubit.list.clear();
    if (authState is AuthorizedOrganizer) {
      await cubit.fetchEvents(authState.user.token, 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Moje Wydarzenia'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 2,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshEvents,
          ),
        ],
      ),
      body: BlocBuilder<OrganizerEventsCubit, OrganizerEventState>(
        builder: (context, state) {
          if (state is OrganizerEventLoadingState) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (state is OrganizerEventErrorState) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    state.message,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _refreshEvents,
                    child: const Text('Spróbuj ponownie'),
                  ),
                ],
              ),
            );
          }

          if (state is OrganizerEventLoadedState) {
            final events = state.events;

            if (events.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.event_busy,
                      size: 64,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Nie masz jeszcze żadnych wydarzeń',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Kliknij przycisk + aby stworzyć pierwsze wydarzenie',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: _refreshEvents,
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: events.length + (state.hasNextPage ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == events.length) {
                    // Loading indicator for pagination
                    return Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Center(
                        child: Column(
                          children: [
                            const CircularProgressIndicator(),
                            const SizedBox(height: 8),
                            Text(
                              'Ładowanie więcej wydarzeń...',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  final event = events[index];
                  return EventCard(event: event);
                },
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => const OrganizerNewEventRoute().go(context),
        backgroundColor: Colors.blue,
        tooltip: 'Stwórz nowe wydarzenie',
        child: const Icon(Icons.add, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}

class EventCard extends StatelessWidget {
  final OrganizerEvent event;

  const EventCard({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          OrganizerEventDetailRoute(eventId: event.id)
              .push<BuildContext>(context);
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      event.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  _buildStatusChip(
                      event.status.statusText, event.status.statusColor),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                event.description,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              _buildEventInfo(),
              const SizedBox(height: 12),
              _buildPriceAndCategories(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(String statusText, Color statusColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: statusColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        statusText,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildEventInfo() {
    return Column(
      children: [
        Row(
          children: [
            Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                _formatDate(event.startDate, event.endDate),
                style: TextStyle(color: Colors.grey[700], fontSize: 14),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '${event.address.city}, ${event.address.street} ${event.address.houseNumber}',
                style: TextStyle(color: Colors.grey[700], fontSize: 14),
              ),
            ),
          ],
        ),
        if (event.minimumAge > 0) ...[
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(Icons.person, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 8),
              Text(
                'Min. wiek: ${event.minimumAge} lat',
                style: TextStyle(color: Colors.grey[700], fontSize: 14),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildPriceAndCategories() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Cena',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '${event.minimumPrice.price.toStringAsFixed(0)} - ${event.maximumPrice.price.toStringAsFixed(0)} ${event.minimumPrice.currency}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.blue,
              ),
            ),
          ],
        ),
        Wrap(
          spacing: 4,
          children: event.categories.take(2).map((category) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Text(
                category.name,
                style: TextStyle(
                  color: Colors.blue[700],
                  fontSize: 12,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  String _formatDate(DateTime start, DateTime end) {
    final months = [
      'sty',
      'lut',
      'mar',
      'kwi',
      'maj',
      'cze',
      'lip',
      'sie',
      'wrz',
      'paź',
      'lis',
      'gru'
    ];

    if (start.day == end.day &&
        start.month == end.month &&
        start.year == end.year) {
      return '${start.day} ${months[start.month - 1]} ${start.year}, ${start.hour}:${start.minute.toString().padLeft(2, '0')} - ${end.hour}:${end.minute.toString().padLeft(2, '0')}';
    } else {
      return '${start.day} ${months[start.month - 1]} - ${end.day} ${months[end.month - 1]} ${end.year}';
    }
  }
}
