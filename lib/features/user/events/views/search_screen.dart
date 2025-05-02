import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:resellio/features/common/style/app_colors.dart';

class CustomerSearchScreen extends StatelessWidget {
  const CustomerSearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: EventSearchScreen(),
    );
  }
}

class EventSearchScreen extends StatefulWidget {
  const EventSearchScreen({super.key});

  @override
  State<EventSearchScreen> createState() => _EventSearchScreenState();
}

class _EventSearchScreenState extends State<EventSearchScreen> {
  DateTimeRange? _selectedDateRange;
  RangeValues? _selectedPriceRange;
  final TextEditingController _searchController = TextEditingController();

  final List<String> _categories = ['Koncerty', 'Kultura', 'Rozrywka', 'Inne'];
  String? _selectedCategory;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    print('Search query: $query');
  }

  Future<void> _selectDateRange(BuildContext context) async {
    final now = DateTime.now();
    final firstDate = DateTime(now.year - 1, now.month, now.day);
    final lastDate = DateTime(now.year + 2, now.month, now.day);

    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
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
    }
  }

  Future<void> _showPriceFilterDialog(BuildContext context) async {
    RangeValues currentRange = _selectedPriceRange ?? const RangeValues(0, 500);

    final RangeValues? result = await showDialog<RangeValues>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Wybierz zakres cen (zł)'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  RangeSlider(
                    values: currentRange,
                    max: 1000,
                    divisions: 20,
                    labels: RangeLabels(
                      currentRange.start.round().toString(),
                      currentRange.end.round().toString(),
                    ),
                    activeColor: AppColors.primary,
                    inactiveColor: AppColors.primaryLight,
                    onChanged: (values) {
                      setDialogState(() {
                        currentRange = values;
                      });
                    },
                  ),
                  Text(
                    'Zakres: ${currentRange.start.round()} zł - ${currentRange.end.round()} zł',
                  ),
                ],
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('Anuluj'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
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
                  onPressed: () {
                    Navigator.of(context).pop(
                      currentRange,
                    );
                  },
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
        }
      } else if (result != _selectedPriceRange) {
        setState(() {
          _selectedPriceRange = result;
        });
        print(
            'Selected price range: ${result.start.round()} - ${result.end.round()}');
      }
    }
  }

  void _onTypeFilterPressed() {
    print('Type filter pressed');
  }

  void _onCityFilterPressed() {
    print('City filter pressed');
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
  }

  void _clearAllFilters() {
    setState(() {
      _selectedDateRange = null;
      _selectedPriceRange = null;
      _selectedCategory = null;
      _searchController.clear();
    });
    print('All filters cleared');
  }

  @override
  Widget build(BuildContext context) {
    final isAnyFilterActive = _selectedDateRange != null ||
        _selectedPriceRange != null ||
        _selectedCategory != null ||
        _searchController.text.isNotEmpty;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSearchBar(context),
              const SizedBox(height: 8),
              _buildFilterBar(context),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildResultsCount(89976),
                  if (isAnyFilterActive) _buildClearFilters(),
                ],
              ),
              _buildResultsList(context),
            ],
          ),
        ),
      ),
    );
  }

  TextButton _buildClearFilters() {
    return TextButton(
      onPressed: _clearAllFilters,
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Icon(Icons.clear, size: 16, color: AppColors.primary),
          SizedBox(width: 4),
          Text(
            'Wyczyść filtry',
            style: TextStyle(fontSize: 12),
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
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
          borderSide: BorderSide.none,
        ),
        hoverColor: Colors.white,
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[600]!),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      ),
    );
  }

  Widget _buildFilterBar(BuildContext context) {
    var dateLabel = 'Data';
    if (_selectedDateRange != null) {
      final formatter = DateFormat('d MMM', 'pl_PL');
      dateLabel =
          '${formatter.format(_selectedDateRange!.start)} - ${formatter.format(_selectedDateRange!.end)}';
      if (_selectedDateRange!.start.day == _selectedDateRange!.end.day &&
          _selectedDateRange!.start.month == _selectedDateRange!.end.month &&
          _selectedDateRange!.start.year == _selectedDateRange!.end.year) {
        dateLabel = formatter.format(_selectedDateRange!.start);
      }
    }

    return ScrollConfiguration(
      behavior: const ScrollBehavior().copyWith(
        overscroll: false,
        dragDevices: {PointerDeviceKind.mouse, PointerDeviceKind.touch},
        scrollbars: false,
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildFilterChip(
              context,
              dateLabel,
              isDropdown: true,
              isSelected: _selectedDateRange != null,
              onPressed: () => _selectDateRange(context),
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
            _buildFilterChip(
              context,
              'Cena',
              isSelected: _selectedPriceRange != null,
              onPressed: () => _showPriceFilterDialog(context),
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
    return Flexible(
      child: Text(
        'Znaleziono: $count wyników',
        style: TextStyle(color: Colors.grey[600], fontSize: 12),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildResultsList(BuildContext context) {
    return Expanded(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off_outlined, size: 48, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              _searchController.text.isEmpty &&
                      !(_selectedDateRange != null ||
                          _selectedPriceRange != null ||
                          _selectedCategory != null)
                  ? 'Zacznij wyszukiwanie lub wybierz filtry'
                  : 'Brak wyników dla podanych kryteriów',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[500]),
            ),
          ],
        ),
        // Example ListView:
        // ListView.builder(
        //   padding: EdgeInsets.only(top: 8.0, left: 16.0, right: 16.0, bottom: 16.0), // Add padding around list items
        //   itemCount: state.events.length, // From Cubit state
        //   itemBuilder: (context, index) {
        //     final event = state.events[index];
        //     return YourEventListItemWidget(event: event); // Your custom list item widget
        //   },
        // ),
      ),
    );
  }
}
