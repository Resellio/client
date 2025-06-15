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
  bool? _resellFilter;

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
            resell: _resellFilter,
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

  void _onResellFilterChanged(bool? resell) {
    setState(() {
      _resellFilter = resell;
    });
    _performSearch();
  }

  void _performSearch() {
    context.read<TicketsCubit>().refreshTickets(
          eventName: _searchQuery.isNotEmpty ? _searchQuery : null,
          used: _usedFilter,
          resell: _resellFilter,
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
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
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
        crossAxisAlignment: CrossAxisAlignment.start,
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
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  _buildCompactFilterChip(
                    'Wszystkie',
                    _usedFilter == null,
                    () => _onFilterChanged(null),
                  ),
                  _buildCompactFilterChip(
                    'Użyte',
                    (_usedFilter ?? false) == true,
                    () => _onFilterChanged(true),
                  ),
                  _buildCompactFilterChip(
                    'Nieużyte',
                    _usedFilter == false,
                    () => _onFilterChanged(false),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  _buildCompactFilterChip(
                    'Wszystkie',
                    _resellFilter == null,
                    () => _onResellFilterChanged(null),
                  ),
                  _buildCompactFilterChip(
                    'Na sprzedaż',
                    (_resellFilter ?? false) == true,
                    () => _onResellFilterChanged(true),
                  ),
                  _buildCompactFilterChip(
                    'Nie na sprzedaż',
                    _resellFilter == false,
                    () => _onResellFilterChanged(false),
                  ),
                ],
              ),
            ],
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
            resell: _resellFilter,
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
                          : ticket.forResell
                              ? Colors.orange.withOpacity(0.2)
                              : AppColors.primary.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      ticket.used
                          ? 'Użyty'
                          : ticket.forResell
                              ? 'Na sprzedaż'
                              : 'Aktywny',
                      style: TextStyle(
                        color: ticket.used
                            ? Colors.grey[700]
                            : ticket.forResell
                                ? Colors.orange[700]
                                : AppColors.primary,
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
              if (ticket.forResell &&
                  ticket.resellPrice != null &&
                  !ticket.used) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(
                      Icons.attach_money,
                      size: 16,
                      color: Colors.orange,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Cena odsprzedaży: ${ticket.resellPrice?.toStringAsFixed(2)} ${ticket.resellCurrency ?? 'PLN'}',
                      style: const TextStyle(
                        color: Colors.orange,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
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
            _searchQuery.isNotEmpty ||
                    _usedFilter != null ||
                    _resellFilter != null
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
            resell: _resellFilter,
          ),
      showBackButton: false,
    );
  }

  Widget _buildCompactFilterChip(
    String label,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.grey[200],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.grey[300]!,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey[700],
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
