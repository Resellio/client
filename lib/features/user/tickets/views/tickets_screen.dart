import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import 'package:resellio/features/common/style/app_colors.dart';
import 'package:resellio/features/common/widgets/error_widget.dart';
import 'package:resellio/features/user/tickets/bloc/tickets_cubit.dart';
import 'package:resellio/features/user/tickets/bloc/tickets_state.dart';
import 'package:resellio/features/user/tickets/model/ticket.dart';
import 'package:resellio/routes/customer_routes.dart';

class CustomerTicketsScreen extends StatefulWidget {
  const CustomerTicketsScreen({super.key});

  @override
  State<CustomerTicketsScreen> createState() => _CustomerTicketsScreenState();
}

class _CustomerTicketsScreenState extends State<CustomerTicketsScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  String _searchQuery = '';
  bool? _usedFilter;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TicketsCubit>().loadTickets();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.9) {
      context.read<TicketsCubit>().loadMoreTickets(
            eventName: _searchQuery.isNotEmpty ? _searchQuery : null,
            used: _usedFilter,
          );
    }
  }

  void _onSearchChanged(String value) {
    setState(() {
      _searchQuery = value;
    });
    _performSearch();
  }

  void _onFilterChanged(bool? used) {
    setState(() {
      _usedFilter = used;
    });
    _performSearch();
  }

  void _performSearch() {
    context.read<TicketsCubit>().refreshTickets(
          eventName: _searchQuery.isNotEmpty ? _searchQuery : null,
          used: _usedFilter,
        );
  }

  void _onTicketTap(Ticket ticket) {
    CustomerTicketDetailRoute(
      ticketId: ticket.ticketId,
    ).go(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          _buildSearchAndFilter(),
          Expanded(
            child: BlocBuilder<TicketsCubit, TicketsState>(
              builder: (context, state) {
                return switch (state) {
                  TicketsInitialState() =>
                    const Center(child: CircularProgressIndicator()),
                  TicketsLoadingState() =>
                    const Center(child: CircularProgressIndicator()),
                  TicketsLoadedState() when state.tickets.isEmpty =>
                    _buildEmptyState(),
                  TicketsLoadedState() => _buildTicketsList(state),
                  TicketsErrorState() => _buildErrorState(state),
                  _ => const Center(child: CircularProgressIndicator()),
                };
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilter() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            onChanged: _onSearchChanged,
            decoration: InputDecoration(
              hintText: 'Wyszukaj po nazwie wydarzenia...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        _onSearchChanged('');
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                const Text(
                  'Filtruj bilety:',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                const SizedBox(width: 16),
                FilterChip(
                  label: const Text('Wszystkie'),
                  selected: _usedFilter == null,
                  onSelected: (_) => _onFilterChanged(null),
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text('Użyte'),
                  selected: (_usedFilter ?? false) == true,
                  onSelected: (_) => _onFilterChanged(true),
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text('Nieużyte'),
                  selected: _usedFilter == false,
                  onSelected: (_) => _onFilterChanged(false),
                ),
                const SizedBox(width: 16), // Extra padding at end for mobile
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTicketsList(TicketsLoadedState state) {
    return RefreshIndicator(
      onRefresh: () => context.read<TicketsCubit>().refreshTickets(
            eventName: _searchQuery.isNotEmpty ? _searchQuery : null,
            used: _usedFilter,
          ),
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        itemCount: state.tickets.length + (state.isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= state.tickets.length) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            );
          }

          final ticket = state.tickets[index];
          return _buildTicketCard(ticket);
        },
      ),
    );
  }

  Widget _buildTicketCard(Ticket ticket) {
    final startDate =
        DateFormat('dd.MM.yyyy HH:mm').format(ticket.eventStartDate);
    final endDate = DateFormat('dd.MM.yyyy HH:mm').format(ticket.eventEndDate);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _onTicketTap(ticket),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      ticket.eventName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: ticket.used
                          ? Colors.grey.withOpacity(0.2)
                          : AppColors.primary.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      ticket.used ? 'Użyty' : 'Aktywny',
                      style: TextStyle(
                        color:
                            ticket.used ? Colors.grey[700] : AppColors.primary,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(
                    Icons.event,
                    size: 16,
                    color: Colors.grey,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Początek: $startDate',
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(
                    Icons.event_available,
                    size: 16,
                    color: Colors.grey,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Koniec: $endDate',
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'ID: ${ticket.ticketId.substring(0, 8)}...',
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Colors.grey,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.confirmation_number_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Brak biletów',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _searchQuery.isNotEmpty || _usedFilter != null
                ? 'Nie znaleziono biletów spełniających kryteria'
                : 'Nie masz jeszcze żadnych biletów',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(TicketsErrorState state) {
    return CommonErrorWidget(
      message: state.message,
      onRetry: () => context.read<TicketsCubit>().refreshTickets(
            eventName: _searchQuery.isNotEmpty ? _searchQuery : null,
            used: _usedFilter,
          ),
      showBackButton: false,
    );
  }
}
