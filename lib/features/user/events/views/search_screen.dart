import 'dart:async';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:resellio/features/common/style/app_colors.dart';
import 'package:resellio/features/common/widgets/event_card.dart';
import 'package:resellio/features/user/events/bloc/event_cubit.dart';
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
  final TextEditingController _searchController = TextEditingController();

  final List<String> _categories = ['Koncerty', 'Kultura', 'Rozrywka', 'Inne'];
  String? _selectedCategory;

  late final Debouncer _debouncer;

  @override
  void initState() {
    super.initState();
    _debouncer = Debouncer(milliseconds: 500);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debouncer.dispose();
    super.dispose();
  }

  void _triggerSearch() {
    context.read<EventsCubit>().getEvents();
  }

  void _onSearchChanged(String query) {
    _debouncer.run(() {
      print('Debounced Search query: $query');
      _triggerSearch();
    });
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
        _selectedDateRange = picked;
      });
      print(
          'Selected date range: ${DateFormat('yyyy-MM-dd').format(picked.start)} - ${DateFormat('yyyy-MM-dd').format(picked.end)}');
      _triggerSearch();
    }
  }

  Future<void> _showPriceFilterDialog(BuildContext context) async {
    final currentRange = _selectedPriceRange ?? const RangeValues(0, 500);

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
                      dialogRange.end.round().toString(),
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
                    'Zakres: ${dialogRange.start.round()} zł - ${dialogRange.end.round()} zł',
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
                      Navigator.of(context).pop(
                        const RangeValues(-1, -1),
                      );
                    },
                  ),
                TextButton(
                  child: const Text('OK'),
                  onPressed: () => Navigator.of(context).pop(
                    dialogRange,
                  ),
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
          _selectedPriceRange = result;
        });
        print(
            'Selected price range: ${result.start.round()} - ${result.end.round()}');
        _triggerSearch();
      }
    }
  }

  void _onTypeFilterPressed() {
    print('Type filter pressed - Implement me');
    // TODO: Implement type filter logic (e.g., show dropdown/dialog)
  }

  void _onCityFilterPressed() {
    print('City filter pressed - Implement me');
    // TODO: Implement city filter logic (e.g., show dropdown/dialog/new screen)
  }

  void _onCategoryFilterPressed(String category) {
    setState(() {
      if (_selectedCategory == category) {
        _selectedCategory = null;
      } else {
        _selectedCategory = category;
      }
    });
    print('Category filter pressed: $category, Selected: $_selectedCategory');
    _triggerSearch();
  }

  void _clearAllFilters() {
    final needsUpdate = _selectedDateRange != null ||
        _selectedPriceRange != null ||
        _selectedCategory != null ||
        _searchController.text.isNotEmpty;

    setState(() {
      _selectedDateRange = null;
      _selectedPriceRange = null;
      _selectedCategory = null;
      _searchController.clear();
    });

    print('All filters cleared');

    if (needsUpdate) {
      _triggerSearch();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isAnyFilterActive = _selectedDateRange != null ||
        _selectedPriceRange != null ||
        _selectedCategory != null ||
        _searchController.text.isNotEmpty;

    final eventState = context.watch<EventsCubit>().state;
    var resultCount = 0;
    if (eventState is EventsLoaded) {
      resultCount = eventState.events.length;
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context, resultCount, isAnyFilterActive),
            Expanded(
              child: _buildResultsContent(
                context,
                isAnyFilterActive,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    int resultCount,
    bool isAnyFilterActive,
  ) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildSearchBar(context),
          const SizedBox(height: 8),
          _buildFilterBar(context),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildResultsCount(resultCount),
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
        hintText: 'Czego szukasz?',
        hintStyle: TextStyle(color: Colors.grey[700]),
        prefixIcon: Icon(Icons.search, color: Colors.grey[800]),
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
    );
  }

  Widget _buildFilterBar(BuildContext context) {
    var dateLabel = 'Data';
    if (_selectedDateRange != null) {
      final formatter = DateFormat('d MMM', 'pl_PL');
      final startFormatted = formatter.format(_selectedDateRange!.start);
      final endFormatted = formatter.format(_selectedDateRange!.end);
      dateLabel = startFormatted == endFormatted
          ? startFormatted
          : '$startFormatted - $endFormatted';
    }

    var priceLabel = 'Cena';
    if (_selectedPriceRange != null) {
      priceLabel =
          '${_selectedPriceRange!.start.round()} - ${_selectedPriceRange!.end.round()} zł';
      if (_selectedPriceRange!.start.round() == 0 &&
          _selectedPriceRange!.end.round() == 1000) {
      } else if (_selectedPriceRange!.end.round() == 1000) {
        priceLabel = '> ${_selectedPriceRange!.start.round()} zł';
      } else if (_selectedPriceRange!.start.round() == 0) {
        priceLabel = '< ${_selectedPriceRange!.end.round()} zł';
      }
    }

    return ScrollConfiguration(
      behavior: const ScrollBehavior().copyWith(
        overscroll: false,
        dragDevices: {PointerDeviceKind.touch, PointerDeviceKind.mouse},
        scrollbars: false,
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
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
              'Typ',
              isDropdown: true,
              onPressed: _onTypeFilterPressed,
            ),
            const SizedBox(width: 8),
            _buildFilterChip(
              context,
              'Miasto',
              isDropdown: true,
              onPressed: _onCityFilterPressed,
            ),
            const SizedBox(width: 8),
            ..._categories.map(
              (category) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: _buildFilterChip(
                  context,
                  category,
                  isSelected: _selectedCategory == category,
                  onPressed: () => _onCategoryFilterPressed(category),
                ),
              ),
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

  Widget _buildResultsCount(int count) {
    final state = context.watch<EventsCubit>().state;
    String message;
    var style = TextStyle(color: Colors.grey[600], fontSize: 12);

    switch (state) {
      case EventsInitial():
        message = 'Wprowadź kryteria wyszukiwania';
      case EventsLoading():
        message = 'Szukanie...';
      case EventsLoaded():
        message = 'Znaleziono: $count wyników';
        style = TextStyle(
            color: Colors.grey[800], fontSize: 12, fontWeight: FontWeight.w500);
      case EventsError():
        message = 'Błąd wyszukiwania';
        style = TextStyle(color: Colors.red[700], fontSize: 12);
    }

    return Flexible(
      child: Text(
        message,
        style: style,
        overflow: TextOverflow.ellipsis,
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

  Widget _buildResultsContent(
    BuildContext context,
    bool filtersOrSearchActive,
  ) {
    return BlocBuilder<EventsCubit, EventsState>(
      builder: (context, state) {
        switch (state) {
          case EventsInitial():
            return _buildPlaceholder(
              icon: Icons.search_outlined,
              message: 'Zacznij wyszukiwanie lub wybierz filtry',
            );

          case EventsLoading():
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 40),
              child: Center(child: CircularProgressIndicator()),
            );

          case EventsError():
            return _buildPlaceholder(
              icon: Icons.error_outline,
              message: 'Błąd: ${state.message}\nSpróbuj ponownie.',
              iconColor: Colors.red,
            );

          case EventsLoaded():
            if (state.events.isEmpty) {
              return _buildPlaceholder(
                icon: Icons.search_off_outlined,
                message: filtersOrSearchActive
                    ? 'Brak wyników dla podanych kryteriów'
                    : 'Nie znaleziono żadnych wydarzeń',
              );
            } else {
              return ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: state.events.length,
                itemBuilder: (context, index) {
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
