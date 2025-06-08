import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:resellio/features/common/style/app_colors.dart';

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

class SearchBarWidget extends StatelessWidget {
  const SearchBarWidget({
    super.key,
    required this.controller,
    required this.onChanged,
    required this.onClear,
    this.hintText = 'Szukaj...',
  });

  final TextEditingController controller;
  final void Function(String) onChanged;
  final VoidCallback onClear;
  final String hintText;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: Colors.grey[600], fontSize: 15),
        prefixIcon: Icon(Icons.search, color: Colors.grey[700], size: 22),
        suffixIcon: controller.text.isNotEmpty
            ? IconButton(
                icon: Icon(Icons.clear, color: Colors.grey[600], size: 20),
                onPressed: onClear,
              )
            : null,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: Colors.black.withAlpha(20),
          ),
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
      textInputAction: TextInputAction.search,
    );
  }
}

class FilterChipWidget extends StatelessWidget {
  const FilterChipWidget({
    super.key,
    required this.label,
    this.isSelected = false,
    this.isDropdown = false,
    this.onPressed,
  });

  final String label;
  final bool isSelected;
  final bool isDropdown;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
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
}

class DateRangeFilterWidget extends StatelessWidget {
  const DateRangeFilterWidget({
    super.key,
    required this.selectedDateRange,
    required this.onDateRangeChanged,
  });

  final DateTimeRange? selectedDateRange;
  final void Function(DateTimeRange?) onDateRangeChanged;

  String get _dateLabel {
    if (selectedDateRange == null) {
      return 'Data';
    }

    final formatter = DateFormat('d MMM', 'pl_PL');
    final startFormatted = formatter.format(selectedDateRange!.start);
    final endFormatted = formatter.format(selectedDateRange!.end);
    final isSameDay =
        selectedDateRange!.start.year == selectedDateRange!.end.year &&
            selectedDateRange!.start.month == selectedDateRange!.end.month &&
            selectedDateRange!.start.day == selectedDateRange!.end.day;
    return isSameDay ? startFormatted : '$startFormatted - $endFormatted';
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
      initialDateRange: selectedDateRange ??
          DateTimeRange(start: now, end: now.add(const Duration(days: 7))),
    );

    if (picked != null && picked != selectedDateRange) {
      final newRange = DateTimeRange(
        start:
            DateTime(picked.start.year, picked.start.month, picked.start.day),
        end:
            DateTime(picked.end.year, picked.end.month, picked.end.day, 23, 59),
      );
      onDateRangeChanged(newRange);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FilterChipWidget(
      label: _dateLabel,
      isSelected: selectedDateRange != null,
      onPressed: () => _selectDateRange(context),
    );
  }
}

class PriceRangeFilterWidget extends StatelessWidget {
  const PriceRangeFilterWidget({
    super.key,
    required this.selectedPriceRange,
    required this.onPriceRangeChanged,
  });

  final RangeValues? selectedPriceRange;
  final void Function(RangeValues?) onPriceRangeChanged;

  String get _priceLabel {
    if (selectedPriceRange == null) {
      return 'Cena';
    }

    final start = selectedPriceRange!.start.round();
    final end = selectedPriceRange!.end.round();
    if (start == 0 && end < 1000) {
      return '< $end zł';
    } else if (start > 0 && end == 1000) {
      return '> $start zł';
    } else if (start > 0 && end < 1000) {
      return '$start - $end zł';
    }
    return 'Cena';
  }

  Future<void> _showPriceFilterDialog(BuildContext context) async {
    final currentRange = selectedPriceRange ?? const RangeValues(0, 1000);

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
                  onPressed: () => Navigator.of(context).pop(),
                ),
                if (selectedPriceRange != null)
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
        onPriceRangeChanged(null);
      } else if (result != selectedPriceRange) {
        if (result.start == 0 && result.end == 1000) {
          onPriceRangeChanged(null);
        } else {
          onPriceRangeChanged(result);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return FilterChipWidget(
      label: _priceLabel,
      isSelected: selectedPriceRange != null,
      onPressed: () => _showPriceFilterDialog(context),
    );
  }
}

class CityFilterWidget extends StatelessWidget {
  const CityFilterWidget({
    super.key,
    required this.selectedCity,
    required this.cities,
    required this.onCityChanged,
  });

  final String? selectedCity;
  final List<String> cities;
  final void Function(String?) onCityChanged;

  Future<void> _showCityFilterDialog(BuildContext context) async {
    final String? result = await showDialog<String>(
      context: context,
      builder: (context) {
        return SimpleDialog(
          title: const Text('Wybierz miasto'),
          children: <Widget>[
            SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(
                'Wszystkie miasta',
                style: TextStyle(color: AppColors.primary),
              ),
            ),
            ...cities.map(
              (city) => SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context, city);
                },
                child: Text(
                  city,
                  style: TextStyle(
                    fontWeight: selectedCity == city
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );

    if (result != selectedCity) {
      onCityChanged(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cityLabel = selectedCity ?? 'Miasto';

    return FilterChipWidget(
      label: cityLabel,
      isSelected: selectedCity != null,
      isDropdown: true,
      onPressed: () => _showCityFilterDialog(context),
    );
  }
}

class ResultsCountWidget extends StatelessWidget {
  const ResultsCountWidget({
    super.key,
    required this.totalResults,
    this.label = 'Znaleziono',
  });

  final int? totalResults;
  final String label;

  @override
  Widget build(BuildContext context) {
    final total = totalResults ?? '..';

    return Padding(
      padding: const EdgeInsets.all(8),
      child: Text(
        '$label: $total wyników',
        style: TextStyle(color: Colors.grey[600], fontSize: 12),
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
      ),
    );
  }
}

class ClearFiltersButton extends StatelessWidget {
  const ClearFiltersButton({
    super.key,
    required this.onPressed,
  });

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
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
      onPressed: onPressed,
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        visualDensity: VisualDensity.compact,
      ),
    );
  }
}

class PlaceholderWidget extends StatelessWidget {
  const PlaceholderWidget({
    super.key,
    required this.icon,
    required this.message,
    this.iconColor,
  });

  final IconData icon;
  final String message;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
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
