import 'dart:async';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:resellio/features/auth/bloc/auth_cubit.dart';
import 'package:resellio/features/auth/bloc/auth_state.dart';
import 'package:resellio/features/common/style/app_colors.dart';
import 'package:resellio/features/common/widgets/event_card.dart'; // Ensure correct path
import 'package:resellio/features/user/events/bloc/events_cubit.dart';
import 'package:resellio/features/user/events/bloc/events_state.dart'; // Ensure correct path
import 'package:resellio/routes/customer_routes.dart';

class Debouncer {
  Debouncer({required this.milliseconds});

  final int milliseconds;
  VoidCallback? action;
  Timer? _timer;

  void run(VoidCallback action) {
    if (_timer != null) {
      _timer!.cancel();
    }
    _timer = Timer(Duration(milliseconds: milliseconds), action);
  }

  void dispose() {
    _timer?.cancel();
  }
}

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
  final List<String> _categories = ['Koncert', 'Rock', 'Rap', 'Inne'];
  // TEMP
  final List<String> _cities = [
    'Warszawa',
    'Kraków',
    'Gdańsk',
    'Wrocław',
    'Poznań',
    'Łódź'
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
            token: authState.user.token,
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
      print('Debounced Search query: $query');
      _triggerSearch();
    });
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    final state = context.read<EventsCubit>().state;

    if (currentScroll >= (maxScroll * 0.9) &&
        state.status != EventsStatus.loading &&
        !state.hasReachedMax) {
      print("Reached bottom, loading more events...");
      final authState = context.read<AuthCubit>().state;
      if (authState is AuthorizedCustomer) {
        context.read<EventsCubit>().fetchNextPage(authState.user.token);
      }
    }
  }

  Future<void> _selectDateRange(BuildContext context) async {
    final now = DateTime.now();
    final firstDate = DateTime(now.year - 1, now.month, now.day);
    final lastDate = DateTime(now.year + 2, now.month, now.day);

    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      locale: const Locale('pl', 'PL'),
      firstDate: firstDate,
      lastDate: lastDate,
      initialDateRange: _selectedDateRange ??
          DateTimeRange(start: now, end: now.add(const Duration(days: 7))),
    );

    if (picked != null && picked != _selectedDateRange) {
      setState(() {
        _selectedDateRange = DateTimeRange(
          start: DateTime(
              picked.start.year, picked.start.month, picked.start.day, 0, 0),
          end: DateTime(
              picked.end.year, picked.end.month, picked.end.day, 23, 59),
        );
      });
      print(
          'Selected date range: ${DateFormat('yyyy-MM-dd HH:mm').format(_selectedDateRange!.start)} - ${DateFormat('yyyy-MM-dd HH:mm').format(_selectedDateRange!.end)}');
      _triggerSearch();
    }
  }

  Future<void> _showPriceFilterDialog(BuildContext context) async {
    final currentRange = _selectedPriceRange ?? const RangeValues(0, 1000);

    final RangeValues? result = await showDialog<RangeValues>(
      context: context,
      builder: (context) {
        var dialogRange = currentRange;
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Wybierz zakres cen (zł)'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  RangeSlider(
                    values: dialogRange,
                    max: 1000,
                    divisions: 20,
                    labels: RangeLabels(
                      dialogRange.start.round().toString(),
                      dialogRange.end.round() == 1000
                          ? '1000+'
                          : dialogRange.end.round().toString(),
                    ),
                    activeColor: AppColors.primary,
                    inactiveColor: AppColors.primaryLight,
                    onChanged: (values) {
                      setDialogState(() {
                        dialogRange = values;
                      });
                    },
                  ),
                  Text(
                    'Zakres: ${dialogRange.start.round()} zł - ${dialogRange.end.round() == 1000 ? '1000+ zł' : '${dialogRange.end.round()} zł'}',
                  ),
                ],
              ),
              actions: <Widget>[
                TextButton(
                    child: const Text('Anuluj'),
                    onPressed: () => Navigator.of(context).pop()),
                if (_selectedPriceRange != null)
                  TextButton(
                    child: const Text('Wyczyść cenę'),
                    onPressed: () {
                      Navigator.of(context).pop(const RangeValues(-1, -1));
                    },
                  ),
                TextButton(
                  child: const Text('OK'),
                  onPressed: () => Navigator.of(context).pop(dialogRange),
                ),
              ],
            );
          },
        );
      },
    );

    if (result != null) {
      if (result.start == -1 && result.end == -1) {
        if (_selectedPriceRange != null) {
          setState(() {
            _selectedPriceRange = null;
          });
          print('Price filter cleared');
          _triggerSearch();
        }
      } else if (result != _selectedPriceRange) {
        setState(() {
          if (result.start == 0 && result.end == 1000) {
            _selectedPriceRange = null;
          } else {
            _selectedPriceRange = result;
          }
        });
        print(
            'Selected price range: ${result.start.round()} - ${result.end.round()}');
        _triggerSearch();
      }
    }
  }

  Future<void> _showCityFilterDialog(BuildContext context) async {
    final String? result = await showDialog<String>(
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(
            title: const Text('Wybierz miasto'),
            children: <Widget>[
              SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context, null);
                },
                child: const Text('Wszystkie miasta',
                    style: TextStyle(color: AppColors.primary)),
              ),
              ..._cities.map(
                (city) => SimpleDialogOption(
                  onPressed: () {
                    Navigator.pop(context, city);
                  },
                  child: Text(
                    city,
                    style: TextStyle(
                        fontWeight: _selectedCity == city
                            ? FontWeight.bold
                            : FontWeight.normal),
                  ),
                ),
              ),
            ],
          );
        });

    if (result != _selectedCity) {
      setState(() {
        _selectedCity = result;
      });
      print('Selected city: $_selectedCity');
      _triggerSearch();
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
    print('Selected category: $_selectedCategories');
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

    print('All filters cleared');

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
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context, isAnyFilterActive),
            Expanded(
              child: _buildResultsContent(context),
            ),
          ],
        ),
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
          _buildSearchBar(context),
          const SizedBox(height: 8),
          _buildFilterBar(context),
          // const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildResultsCount(state),
              if (isAnyFilterActive) _buildClearFiltersButton(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return TextField(
      controller: _searchController,
      onChanged: _onSearchChanged,
      decoration: InputDecoration(
        hintText: 'Szukaj wydarzeń...',
        hintStyle: TextStyle(color: Colors.grey[600], fontSize: 15),
        prefixIcon: Icon(Icons.search, color: Colors.grey[700], size: 22),
        suffixIcon: _searchController.text.isNotEmpty
            ? IconButton(
                icon: Icon(Icons.clear, color: Colors.grey[600], size: 20),
                onPressed: () {
                  _searchController.clear();
                  _triggerSearch();
                },
              )
            : null,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(
            color: AppColors.primary,
            width: 1.5,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      ),
      onSubmitted: (_) => _triggerSearch(),
      textInputAction: TextInputAction.search,
    );
  }

  Widget _buildFilterBar(BuildContext context) {
    var dateLabel = 'Data';
    if (_selectedDateRange != null) {
      final formatter = DateFormat('d MMM', 'pl_PL');
      final startFormatted = formatter.format(_selectedDateRange!.start);
      final endFormatted = formatter.format(_selectedDateRange!.end);
      bool isSameDay = _selectedDateRange!.start.year ==
              _selectedDateRange!.end.year &&
          _selectedDateRange!.start.month == _selectedDateRange!.end.month &&
          _selectedDateRange!.start.day == _selectedDateRange!.end.day;
      dateLabel =
          isSameDay ? startFormatted : '$startFormatted - $endFormatted';
    }

    var priceLabel = 'Cena';
    if (_selectedPriceRange != null) {
      final start = _selectedPriceRange!.start.round();
      final end = _selectedPriceRange!.end.round();
      if (start == 0 && end < 1000) {
        priceLabel = '< $end zł';
      } else if (start > 0 && end == 1000) {
        priceLabel = '> $start zł';
      } else if (start > 0 && end < 1000) {
        priceLabel = '$start - $end zł';
      }
    }

    final cityLabel = _selectedCity ?? 'Miasto';

    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        children: [
          _buildFilterChip(
            context,
            dateLabel,
            isSelected: _selectedDateRange != null,
            onPressed: () => _selectDateRange(context),
          ),
          const SizedBox(width: 8),
          _buildFilterChip(
            context,
            priceLabel,
            isSelected: _selectedPriceRange != null,
            onPressed: () => _showPriceFilterDialog(context),
          ),
          const SizedBox(width: 8),
          _buildFilterChip(
            context,
            cityLabel,
            isSelected: _selectedCity != null,
            isDropdown: true,
            onPressed: () => _showCityFilterDialog(context),
          ),
          const SizedBox(width: 8),
          ..._categories.map(
            (category) => Padding(
              padding: const EdgeInsets.only(right: 8),
              child: _buildFilterChip(
                context,
                category,
                isSelected: _selectedCategories.contains(category),
                onPressed: () => _onCategoryFilterPressed(category),
              ),
            ),
          ),
        ],
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

  Widget _buildResultsCount(EventsState state) {
    final total = state.totalResults ?? '..';

    return Padding(
      padding: const EdgeInsets.all(8),
      child: Text(
        'Znaleziono: $total wyników',
        style: TextStyle(color: Colors.grey[600], fontSize: 12),
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
      ),
    );
  }

  Widget _buildClearFiltersButton() {
    return TextButton.icon(
      icon: const Icon(
        Icons.clear_all_rounded,
        size: 18,
        color: AppColors.primary,
      ),
      label: const Text(
        'Wyczyść filtry',
        style: TextStyle(fontSize: 12, color: AppColors.primary),
      ),
      onPressed: _clearAllFilters,
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        visualDensity: VisualDensity.compact,
      ),
    );
  }

  Widget _buildResultsContent(BuildContext context) {
    return BlocBuilder<EventsCubit, EventsState>(
      builder: (context, state) {
        switch (state.status) {
          case EventsStatus.initial:
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(40),
                child: CircularProgressIndicator(),
              ),
            );

          case EventsStatus.failure:
            return Center(
              child: _buildPlaceholder(
                icon: Icons.error_outline,
                message:
                    'Wystąpił błąd podczas ładowania wydarzeń.\n${state.errorMessage ?? 'Spróbuj ponownie później.'}',
                iconColor: Colors.red.shade400,
              ),
            );

          case EventsStatus.loading:
          case EventsStatus.success:
            if (state.events.isEmpty && state.status == EventsStatus.loading) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(40),
                  child: CircularProgressIndicator(),
                ),
              );
            } else if (state.events.isEmpty &&
                state.status == EventsStatus.success) {
              return Center(
                child: _buildPlaceholder(
                  icon: Icons.sentiment_dissatisfied_outlined,
                  message:
                      'Nie znaleziono wydarzeń pasujących\ndo wybranych kryteriów.',
                ),
              );
            } else {
              return ListView.separated(
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
              );
            }
        }
      },
    );
  }

  Widget _buildPlaceholder(
      {required IconData icon, required String message, Color? iconColor}) {
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
