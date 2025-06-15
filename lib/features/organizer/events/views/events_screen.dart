import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:resellio/features/auth/bloc/auth_cubit.dart';
import 'package:resellio/features/auth/bloc/auth_state.dart';
import 'package:resellio/features/common/model/event.dart';
import 'package:resellio/features/common/style/app_colors.dart';
import 'package:resellio/features/common/widgets/error_widget.dart';
import 'package:resellio/features/common/widgets/event_card.dart';
import 'package:resellio/features/common/widgets/search_widgets.dart';
import 'package:resellio/features/organizer/events/bloc/events_cubit.dart';
import 'package:resellio/features/user/events/bloc/events_state.dart';
import 'package:resellio/routes/organizer_routes.dart';

enum EventStatusFilter { all, ongoing, upcoming, finished }

class OrganizerEventsScreen extends StatelessWidget {
  const OrganizerEventsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: OrganizerEventsContent(),
    );
  }
}

class OrganizerEventsContent extends StatefulWidget {
  const OrganizerEventsContent({super.key});

  @override
  State<OrganizerEventsContent> createState() => _OrganizerEventsContentState();
}

class _OrganizerEventsContentState extends State<OrganizerEventsContent> {
  DateTimeRange? _selectedDateRange;
  EventStatusFilter _selectedStatusFilter = EventStatusFilter.all;
  final TextEditingController _searchController = TextEditingController();
  late final Debouncer _debouncer;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _debouncer = Debouncer(milliseconds: 300);
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadEvents());
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    _debouncer.dispose();
    super.dispose();
  }

  void _loadEvents() {
    final authState = context.read<AuthCubit>().state;
    if (authState is! AuthorizedOrganizer) {
      return;
    }

    final query = _searchController.text.trim();
    final (
      startDate,
      endDate,
      minStartDate,
      maxStartDate,
      minEndDate,
      maxEndDate
    ) = _getApiDateFilters();

    context.read<OrganizerEventsCubit>().applyFiltersAndFetch(
          searchQuery: query.isEmpty ? null : query,
          startDate: startDate,
          endDate: endDate,
          minStartDate: minStartDate,
          maxStartDate: maxStartDate,
          minEndDate: minEndDate,
          maxEndDate: maxEndDate,
        );
  }

  (DateTime?, DateTime?, DateTime?, DateTime?, DateTime?, DateTime?)
      _getApiDateFilters() {
    final now = DateTime.now();

    // Obsługa custom date range (ma priorytet)
    if (_selectedDateRange != null) {
      return (
        _selectedDateRange!.start, // startDate
        _selectedDateRange!.end, // endDate
        null, null, null, null // pozostałe null
      );
    }

    // Obsługa filtra statusu
    switch (_selectedStatusFilter) {
      case EventStatusFilter.all:
        return (null, null, null, null, null, null);

      case EventStatusFilter.ongoing:
        // Wydarzenia które już się rozpoczęły ale jeszcze się nie skończyły
        return (
          null, // startDate
          null, // endDate
          null, // minStartDate
          now, // maxStartDate - start musi być <= teraz
          now, // minEndDate - end musi być >= teraz
          null, // maxEndDate
        );

      case EventStatusFilter.upcoming:
        // Wydarzenia które jeszcze się nie rozpoczęły
        return (
          null, // startDate
          null, // endDate
          now, // minStartDate - start musi być > teraz
          null, // maxStartDate
          null, // minEndDate
          null, // maxEndDate
        );

      case EventStatusFilter.finished:
        // Wydarzenia które już się skończyły
        return (
          null, // startDate
          null, // endDate
          null, // minStartDate
          null, // maxStartDate
          null, // minEndDate
          now, // maxEndDate - end musi być < teraz
        );
    }
  }

  void _onSearchChanged(String query) {
    _debouncer.run(_loadEvents);
  }

  void _onSearchClear() {
    _searchController.clear();
    _loadEvents();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) {
      return;
    }

    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    final state = context.read<OrganizerEventsCubit>().state;

    if (currentScroll >= (maxScroll * 0.9) &&
        state.status != EventsStatus.loading &&
        !state.hasReachedMax) {
      _loadNextPage();
    }
  }

  void _loadNextPage() {
    final authState = context.read<AuthCubit>().state;
    if (authState is AuthorizedOrganizer) {
      context.read<OrganizerEventsCubit>().fetchNextPage();
    }
  }

  void _onDateRangeChanged(DateTimeRange? dateRange) {
    setState(() => _selectedDateRange = dateRange);
    _loadEvents();
  }

  void _onStatusFilterChanged(EventStatusFilter filter) {
    setState(() => _selectedStatusFilter = filter);
    _loadEvents();
  }

  bool get _hasActiveFilters =>
      _selectedDateRange != null ||
      _searchController.text.isNotEmpty ||
      _selectedStatusFilter != EventStatusFilter.all;

  void _clearFilters() {
    if (!_hasActiveFilters) {
      return;
    }

    setState(() {
      _selectedDateRange = null;
      _selectedStatusFilter = EventStatusFilter.all;
      _searchController.clear();
    });
    _loadEvents();
  }

  void _refreshEvents() {
    final authState = context.read<AuthCubit>().state;
    if (authState is AuthorizedOrganizer) {
      context.read<OrganizerEventsCubit>().refreshEvents();
    }
  }

  void _deleteEvent(Event event) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Usuń wydarzenie'),
        content: Text('Czy na pewno chcesz usunąć wydarzenie "${event.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Anuluj'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _performDeleteEvent(event);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Usuń'),
          ),
        ],
      ),
    );
  }

  void _performDeleteEvent(Event event) {
    final authState = context.read<AuthCubit>().state;
    if (authState is AuthorizedOrganizer) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final cubit = context.read<OrganizerEventsCubit>();
          final result =
              await const OrganizerNewEventRoute().push<bool>(context);
          if ((result ?? false) && mounted) {
            await cubit.refreshEvents();
          }
        },
        backgroundColor: AppColors.primary,
        tooltip: 'Dodaj wydarzenie',
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Column(
        children: [
          _buildSearchAndFiltersSection(),
          Expanded(child: _buildEventsList()),
        ],
      ),
    );
  }

  Widget _buildSearchAndFiltersSection() {
    final state = context.watch<OrganizerEventsCubit>().state;

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        children: [
          SearchBarWidget(
            controller: _searchController,
            onChanged: _onSearchChanged,
            onClear: _onSearchClear,
            hintText: 'Szukaj wydarzeń...',
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: DateRangeFilterWidget(
                  selectedDateRange: _selectedDateRange,
                  onDateRangeChanged: _onDateRangeChanged,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatusFilter(),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ResultsCountWidget(totalResults: state.totalResults),
              if (_hasActiveFilters)
                ClearFiltersButton(onPressed: _clearFilters),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusFilter() {
    return DropdownButtonFormField<EventStatusFilter>(
      value: _selectedStatusFilter,
      decoration: const InputDecoration(
        labelText: 'Status',
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      items: EventStatusFilter.values.map((filter) {
        return DropdownMenuItem(
          value: filter,
          child: Text(_getStatusFilterLabel(filter)),
        );
      }).toList(),
      onChanged: (filter) {
        if (filter != null) {
          _onStatusFilterChanged(filter);
        }
      },
    );
  }

  String _getStatusFilterLabel(EventStatusFilter filter) {
    switch (filter) {
      case EventStatusFilter.all:
        return 'Wszystkie';
      case EventStatusFilter.ongoing:
        return 'W trakcie';
      case EventStatusFilter.upcoming:
        return 'Nadchodzące';
      case EventStatusFilter.finished:
        return 'Zakończone';
    }
  }

  Widget _buildEventsList() {
    return BlocBuilder<OrganizerEventsCubit, EventsState>(
      builder: (context, state) {
        if (state.status == EventsStatus.initial ||
            (state.status == EventsStatus.loading && state.events.isEmpty)) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state.status == EventsStatus.failure) {
          return _buildErrorState(state.errorMessage);
        }

        if (state.events.isEmpty) {
          return _buildEmptyState();
        }

        return _buildEventsListView(state);
      },
    );
  }

  Widget _buildErrorState(String? errorMessage) {
    return CommonErrorWidget(
      message: errorMessage ?? 'Wystąpił błąd podczas ładowania',
      onRetry: _refreshEvents,
      showBackButton: false,
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _hasActiveFilters ? Icons.search_off : Icons.event_note,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            _hasActiveFilters
                ? 'Brak wydarzeń dla wybranych kryteriów'
                : 'Nie masz jeszcze żadnych wydarzeń',
            style: Theme.of(context).textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            _hasActiveFilters
                ? 'Spróbuj zmienić filtry wyszukiwania'
                : 'Utwórz swoje pierwsze wydarzenie',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildEventsListView(EventsState state) {
    return RefreshIndicator(
      onRefresh: () async => _refreshEvents(),
      child: ListView.separated(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        itemCount: state.events.length +
            (state.status == EventsStatus.loading ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= state.events.length) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            );
          }

          final event = state.events[index];
          return EventCard(
            event: event,
            onTap: () =>
                OrganizerEventDetailRoute(eventId: event.id).go(context),
            onLongPress: () => _showEventActions(event),
          );
        },
        separatorBuilder: (context, index) => const SizedBox(height: 12),
      ),
    );
  }

  void _showEventActions(Event event) {
    showModalBottomSheet<void>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.visibility),
              title: const Text('Zobacz szczegóły'),
              onTap: () {
                Navigator.pop(context);
                OrganizerEventDetailRoute(eventId: event.id).go(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Edytuj'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Navigate to edit screen
                ErrorSnackBar.show(context, 'Edycja - do implementacji');
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Usuń', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                _deleteEvent(event);
              },
            ),
          ],
        ),
      ),
    );
  }
}
