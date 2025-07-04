import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:resellio/features/auth/bloc/auth_cubit.dart';
import 'package:resellio/features/auth/bloc/auth_state.dart';
import 'package:resellio/features/common/bloc/categories_cubit.dart';
import 'package:resellio/features/common/bloc/categories_state.dart';
import 'package:resellio/features/common/style/app_colors.dart';
import 'package:resellio/features/common/widgets/error_widget.dart';
import 'package:resellio/features/common/widgets/event_card.dart';
import 'package:resellio/features/common/widgets/search_widgets.dart';
import 'package:resellio/features/user/events/bloc/events_cubit.dart';
import 'package:resellio/features/user/events/bloc/events_state.dart';
import 'package:resellio/routes/customer_routes.dart';

class CustomerSearchScreen extends StatelessWidget {
  const CustomerSearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: EventSearchScreenContent(),
    );
  }
}

class EventSearchScreenContent extends StatefulWidget {
  const EventSearchScreenContent({super.key});

  @override
  State<EventSearchScreenContent> createState() =>
      _EventSearchScreenContentState();
}

class _EventSearchScreenContentState extends State<EventSearchScreenContent> {
  DateTimeRange? _selectedDateRange;
  RangeValues? _selectedPriceRange;
  String? _selectedCity;
  final List<String> _selectedCategories = [];

  final TextEditingController _searchController = TextEditingController();

  // TEMP
  final List<String> _cities = [
    'Warszawa',
    'Kraków',
    'Gdańsk',
    'Wrocław',
    'Poznań',
    'Łódź',
  ];

  late final Debouncer _debouncer;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _debouncer = Debouncer(milliseconds: 300);
    _scrollController.addListener(_onScroll);
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

  void _triggerSearch() {
    final query = _searchController.text.trim();
    final authState = context.read<AuthCubit>().state;

    final DateTime? startDate = _selectedDateRange?.start;
    final DateTime? endDate = _selectedDateRange?.end;
    final double? minPrice =
        (_selectedPriceRange != null && _selectedPriceRange!.start > 0)
            ? _selectedPriceRange!.start
            : null;
    final double? maxPrice =
        (_selectedPriceRange != null && _selectedPriceRange!.end < 1000)
            ? _selectedPriceRange!.end
            : null;
    final String? city = _selectedCity;

    if (authState is AuthorizedCustomer) {
      context.read<EventsCubit>().applyFiltersAndFetch(
            searchQuery: query,
            startDate: startDate,
            endDate: endDate,
            minPrice: minPrice,
            maxPrice: maxPrice,
            city: city,
            categories: _selectedCategories,
          );
    }
  }

  void _onSearchChanged(String query) {
    _debouncer.run(() {
      debugPrint('Debounced Search query: $query');
      _triggerSearch();
    });
  }

  void _onScroll() {
    if (!_scrollController.hasClients) {
      return;
    }
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    final state = context.read<EventsCubit>().state;

    if (currentScroll >= (maxScroll * 0.9) &&
        state.status != EventsStatus.loading &&
        !state.hasReachedMax) {
      debugPrint('Reached bottom, loading more events...');
      final authState = context.read<AuthCubit>().state;
      if (authState is AuthorizedCustomer) {
        context.read<EventsCubit>().fetchNextPage();
      }
    }
  }

  void _onCategoryFilterPressed(String category) {
    setState(() {
      if (_selectedCategories.contains(category)) {
        _selectedCategories.remove(category);
      } else {
        _selectedCategories.add(category);
      }
    });
    debugPrint('Selected category: $_selectedCategories');
    _triggerSearch();
  }

  void _clearAllFilters() {
    final bool filtersWereActive = _selectedDateRange != null ||
        _selectedPriceRange != null ||
        _selectedCategories.isNotEmpty ||
        _selectedCity != null ||
        _searchController.text.isNotEmpty;

    setState(() {
      _selectedDateRange = null;
      _selectedPriceRange = null;
      _selectedCategories.clear();
      _selectedCity = null;
      _searchController.clear();
    });

    debugPrint('All filters cleared');

    if (filtersWereActive) {
      _triggerSearch();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isAnyFilterActive = _selectedDateRange != null ||
        _selectedPriceRange != null ||
        _selectedCategories.isNotEmpty ||
        _selectedCity != null ||
        _searchController.text.isNotEmpty;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        children: [
          _buildHeader(context, isAnyFilterActive),
          Expanded(
            child: _buildResultsContent(context),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isAnyFilterActive) {
    final state = context.watch<EventsCubit>().state;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SearchBarWidget(
            controller: _searchController,
            onChanged: _onSearchChanged,
            onClear: () {
              setState(() {
                _searchController.clear();
                _triggerSearch();
              });
            },
          ),
          const SizedBox(height: 8),
          _buildFilterBar(context),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ResultsCountWidget(totalResults: state.totalResults),
              if (isAnyFilterActive)
                ClearFiltersButton(onPressed: _clearAllFilters),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(
          dragDevices: {
            PointerDeviceKind.touch,
            PointerDeviceKind.mouse,
          },
        ),
        child: ListView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 4),
          children: [
            DateRangeFilterWidget(
              selectedDateRange: _selectedDateRange,
              onDateRangeChanged: (range) {
                setState(() {
                  _selectedDateRange = range;
                });
                _triggerSearch();
              },
            ),
            const SizedBox(width: 8),
            PriceRangeFilterWidget(
              selectedPriceRange: _selectedPriceRange,
              onPriceRangeChanged: (range) {
                setState(() {
                  _selectedPriceRange = range;
                });
                debugPrint(
                  'Selected price range: ${range?.start.round()} - ${range?.end.round()}',
                );
                _triggerSearch();
              },
            ),
            const SizedBox(width: 8),
            CityFilterWidget(
              selectedCity: _selectedCity,
              onCityChanged: (city) {
                setState(() {
                  _selectedCity = city;
                });
                debugPrint('Selected city: $_selectedCity');
                _triggerSearch();
              },
              cities: _cities,
            ),
            const SizedBox(width: 8),
            BlocBuilder<CategoriesCubit, CategoriesState>(
              builder: (context, state) {
                return switch (state) {
                  CategoriesInitial() => const SizedBox.shrink(),
                  CategoriesLoading() => const Center(
                      child: Padding(
                        padding: EdgeInsets.all(8),
                        child: CircularProgressIndicator(),
                      ),
                    ),
                  CategoriesLoaded(categories: final categories) => Row(
                      children: categories.map((category) {
                        final isSelected =
                            _selectedCategories.contains(category);
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: _buildFilterChip(
                            context,
                            category,
                            isSelected: isSelected,
                            onPressed: () => _onCategoryFilterPressed(category),
                          ),
                        );
                      }).toList(),
                    ),
                  CategoriesError() => const SizedBox.shrink(),
                };
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(
    BuildContext context,
    String label, {
    bool isDropdown = false,
    VoidCallback? onPressed,
    bool isSelected = false,
  }) {
    return ActionChip(
      onPressed: onPressed,
      backgroundColor: isSelected ? AppColors.primaryLight : Colors.white,
      side: BorderSide(
        color: isSelected ? Colors.grey[400]! : Colors.grey[300]!,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: Colors.black87,
              fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
            ),
          ),
          if (isDropdown) ...[
            const SizedBox(width: 2),
            Icon(Icons.arrow_drop_down, size: 20, color: Colors.grey[700]),
          ],
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8),
    );
  }

  Widget _buildScrollableContent(Widget child) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: SizedBox(
        height: MediaQuery.of(context).size.height -
            MediaQuery.of(context).padding.top -
            200, // Approximate header height
        child: child,
      ),
    );
  }

  Widget _buildResultsContent(BuildContext context) {
    return BlocBuilder<EventsCubit, EventsState>(
      builder: (context, state) {
        return RefreshIndicator(
          onRefresh: () async {
            _triggerSearch();
          },
          child: switch (state.status) {
            EventsStatus.initial => _buildScrollableContent(
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(40),
                    child: CircularProgressIndicator(),
                  ),
                ),
              ),
            EventsStatus.failure => _buildScrollableContent(
                CommonErrorWidget(
                  message: state.errorMessage ??
                      'Wystąpił błąd podczas ładowania wydarzeń',
                  onRetry: _triggerSearch,
                  showBackButton: false,
                  retryText: 'Odśwież',
                ),
              ),
            EventsStatus.loading when state.events.isEmpty =>
              _buildScrollableContent(
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(40),
                    child: CircularProgressIndicator(),
                  ),
                ),
              ),
            EventsStatus.success when state.events.isEmpty =>
              _buildScrollableContent(
                Center(
                  child: _buildPlaceholder(
                    icon: Icons.sentiment_dissatisfied_outlined,
                    message:
                        'Nie znaleziono wydarzeń pasujących\ndo wybranych kryteriów.',
                  ),
                ),
              ),
            EventsStatus.loading || EventsStatus.success => ListView.separated(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: state.events.length +
                    (state.status == EventsStatus.loading ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index >= state.events.length) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  final event = state.events[index];
                  return EventCard(
                    event: event,
                    onTap: () =>
                        CustomerEventDetailRoute(eventId: event.id).go(context),
                  );
                },
                separatorBuilder: (context, index) {
                  return const SizedBox(height: 12);
                },
              ),
          },
        );
      },
    );
  }

  Widget _buildPlaceholder({
    required IconData icon,
    required String message,
    Color? iconColor,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: iconColor ?? Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style:
                  TextStyle(color: Colors.grey[600], fontSize: 14, height: 1.4),
            ),
          ],
        ),
      ),
    );
  }
}
