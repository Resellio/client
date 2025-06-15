import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:resellio/features/common/bloc/categories_cubit.dart';
import 'package:resellio/features/common/bloc/categories_state.dart';
import 'package:resellio/features/common/data/api.dart';
import 'package:resellio/features/common/model/event.dart';
import 'package:resellio/features/common/style/app_colors.dart';
import 'package:resellio/features/common/widgets/error_widget.dart';
import 'package:resellio/features/organizer/events/views/new_event_screen.dart';

class EditEventScreen extends StatefulWidget {
  const EditEventScreen({super.key, required this.event});

  final Event event;

  @override
  State<EditEventScreen> createState() => _EditEventScreenState();
}

class _EditEventScreenState extends State<EditEventScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  int _currentStep = 0;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _startDateController = TextEditingController();
  final _endDateController = TextEditingController();
  final _minAgeController = TextEditingController();

  final _streetController = TextEditingController();
  final _houseNumberController = TextEditingController();
  final _flatNumberController = TextEditingController();
  final _cityController = TextEditingController();
  final _postalCodeController = TextEditingController();
  final _countryController = TextEditingController();

  final _categoriesController = TextEditingController();

  final String _displayDateFormat = 'yyyy-MM-dd HH:mm';

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();

    // Wypełnij kontrolery istniejącymi danymi
    _fillFormWithEventData();
  }

  void _fillFormWithEventData() {
    final event = widget.event;

    _nameController.text = event.name;
    _descriptionController.text = event.description;

    if (event.startDate != null) {
      _startDateController.text =
          DateFormat(_displayDateFormat).format(event.startDate!);
    }
    if (event.endDate != null) {
      _endDateController.text =
          DateFormat(_displayDateFormat).format(event.endDate!);
    }

    _minAgeController.text = event.minimumAge.toString();

    // Adres
    _streetController.text = event.address.street;
    _houseNumberController.text = event.address.houseNumber.toString();
    _flatNumberController.text = event.address.flatNumber?.toString() ?? '';
    _cityController.text = event.address.city;
    _postalCodeController.text = event.address.postalCode;
    _countryController.text = event.address.country;

    // Kategorie
    _categoriesController.text = event.categories.join(', ');
  }

  @override
  void dispose() {
    _animationController.dispose();
    _nameController.dispose();
    _descriptionController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    _minAgeController.dispose();
    _streetController.dispose();
    _houseNumberController.dispose();
    _flatNumberController.dispose();
    _cityController.dispose();
    _postalCodeController.dispose();
    _countryController.dispose();
    _categoriesController.dispose();
    super.dispose();
  }

  String? _isoFormat(String? displayDate) {
    if (displayDate == null || displayDate.trim().isEmpty) {
      return null;
    }
    try {
      final parsed = DateFormat(_displayDateFormat).parse(displayDate.trim());
      return parsed.toUtc().toIso8601String();
    } catch (err) {
      debugPrint('Date formatting error: $err');
      return null;
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      ErrorSnackBar.show(context, 'W formularzu znajdują się błędy');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final eventData = EditEventRequest(
        name: _nameController.text,
        description: _descriptionController.text,
        startDate: _isoFormat(_startDateController.text)!,
        endDate: _isoFormat(_endDateController.text)!,
        minimumAge: int.tryParse(_minAgeController.text) ?? 0,
        categories: _categoriesController.text
            .split(',')
            .map((s) => s.trim())
            .where((s) => s.isNotEmpty)
            .map((name) => EventCategoryRequest(categoryName: name))
            .toList(),
        editAddress: EventAddressRequest(
          country: _countryController.text,
          city: _cityController.text,
          street: _streetController.text,
          houseNumber: int.tryParse(_houseNumberController.text) ?? 0,
          flatNumber: int.tryParse(_flatNumberController.text) ?? 0,
          postalCode: _postalCodeController.text,
        ),
        eventStatus: widget.event.status,
      );

      final apiService = context.read<ApiService>();
      final response = await apiService.updateEvent(
        eventId: widget.event.id,
        eventData: eventData.toJson(),
      );

      if (mounted) {
        if (response.success) {
          SuccessSnackBar.show(
            context,
            'Wydarzenie zostało pomyślnie zaktualizowane',
          );
          Navigator.of(context).pop(true); // Zwróć true aby odświeżyć listę
        } else {
          ErrorSnackBar.show(
            context,
            response.message ?? 'Błąd podczas aktualizacji wydarzenia',
          );
        }
      }
    } catch (err) {
      if (mounted) {
        ErrorSnackBar.show(
          context,
          'Błąd podczas aktualizacji wydarzenia: $err',
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: _buildAppBar(),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            _buildProgressIndicator(),
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Form(
                    key: _formKey,
                    autovalidateMode: AutovalidateMode.disabled,
                    child: _buildCurrentStep(),
                  ),
                ),
              ),
            ),
            _buildBottomButtons(),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text(
        'Edytuj Wydarzenie',
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 20,
        ),
      ),
      backgroundColor: Colors.white,
      foregroundColor: const Color(0xFF1E293B),
      elevation: 0,
      shadowColor: Colors.black.withOpacity(0.1),
      surfaceTintColor: Colors.transparent,
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: List.generate(3, (index) {
          final isActive = index <= _currentStep;

          return Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 4,
                    decoration: BoxDecoration(
                      color: isActive
                          ? AppColors.primary
                          : const Color(0xFFE9ECEF),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                if (index < 2) const SizedBox(width: 8),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildCurrentStep() {
    switch (_currentStep) {
      case 0:
        return _buildBasicInfoStep();
      case 1:
        return _buildAddressStep();
      case 2:
        return _buildCategoriesStep();
      default:
        return _buildBasicInfoStep();
    }
  }

  Widget _buildBasicInfoStep() {
    return _buildStepCard(
      title: 'Podstawowe informacje',
      subtitle: 'Podaj nazwę, opis i szczegóły wydarzenia',
      child: Column(
        children: [
          _buildTextField(
            controller: _nameController,
            label: 'Nazwa wydarzenia',
            hint: 'np. Summer Music Fest 2025',
            validator: (value) => _validateNotEmpty(value, 'Nazwa'),
          ),
          const SizedBox(height: 20),
          _buildTextField(
            controller: _descriptionController,
            label: 'Opis wydarzenia',
            hint: 'Szczegółowy opis wydarzenia...',
            maxLines: 4,
            validator: (value) => _validateNotEmpty(value, 'Opis'),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildDateTimeField(
                  controller: _startDateController,
                  label: 'Data rozpoczęcia',
                  validator: (value) =>
                      _validateDate(value, 'Data rozpoczęcia'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildDateTimeField(
                  controller: _endDateController,
                  label: 'Data zakończenia',
                  validator: (value) =>
                      _validateDate(value, 'Data zakończenia'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildTextField(
            controller: _minAgeController,
            label: 'Minimalny wiek',
            hint: '18',
            keyboardType: TextInputType.number,
            validator: (value) => _validateNumber(value, 'Minimalny wiek'),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressStep() {
    return _buildStepCard(
      title: 'Lokalizacja',
      subtitle: 'Gdzie odbędzie się wydarzenie?',
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                flex: 2,
                child: _buildTextField(
                  controller: _streetController,
                  label: 'Ulica',
                  hint: 'ul. Przykładowa',
                  validator: (value) => _validateNotEmpty(value, 'Ulica'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildTextField(
                  controller: _houseNumberController,
                  label: 'Nr domu',
                  hint: '123',
                  keyboardType: TextInputType.number,
                  validator: (value) => _validateNumber(value, 'Numer domu'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildTextField(
                  controller: _flatNumberController,
                  label: 'Nr mieszkania',
                  hint: '4A',
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  controller: _cityController,
                  label: 'Miasto',
                  hint: 'Warszawa',
                  validator: (value) => _validateNotEmpty(value, 'Miasto'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildTextField(
                  controller: _postalCodeController,
                  label: 'Kod pocztowy',
                  hint: '00-000',
                  validator: (value) =>
                      _validateNotEmpty(value, 'Kod pocztowy'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildTextField(
            controller: _countryController,
            label: 'Kraj',
            hint: 'Polska',
            validator: (value) => _validateNotEmpty(value, 'Kraj'),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriesStep() {
    return _buildStepCard(
      title: 'Kategorie Wydarzenia',
      subtitle: 'Wybierz kategorie dla swojego wydarzenia',
      child: Column(
        children: [
          const Text(
            'Wybierz kategorie dla swojego wydarzenia:',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Color(0xFF636E72),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F3F4),
                borderRadius: BorderRadius.circular(12),
              ),
              constraints: const BoxConstraints(
                minHeight: 100,
              ),
              child: BlocBuilder<CategoriesCubit, CategoriesState>(
                builder: (context, state) {
                  if (state is CategoriesLoaded) {
                    final selectedCategories = _categoriesController.text
                        .split(',')
                        .map((s) => s.trim())
                        .where((s) => s.isNotEmpty)
                        .toSet();

                    return Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: state.categories.map((category) {
                        final isSelected =
                            selectedCategories.contains(category);
                        return _buildSelectableCategoryChip(
                          category,
                          isSelected,
                        );
                      }).toList(),
                    );
                  } else if (state is CategoriesLoading) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  } else if (state is CategoriesError) {
                    return Text(
                      'Błąd ładowania kategorii: ${state.message}',
                      style: const TextStyle(color: Colors.red),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectableCategoryChip(String category, bool isSelected) {
    return FilterChip(
      showCheckmark: false,
      selected: isSelected,
      onSelected: (selected) {
        final currentText = _categoriesController.text;
        final categories = currentText.split(',').map((s) => s.trim()).toList();

        if (selected) {
          if (!categories.contains(category)) {
            categories.add(category);
          }
        } else {
          categories.remove(category);
        }

        _categoriesController.text =
            categories.where((s) => s.isNotEmpty).join(', ');
        setState(() {});
      },
      label: Text(
        category,
        style: TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 12,
          color: isSelected ? Colors.white : AppColors.primary,
        ),
      ),
      backgroundColor: Colors.white,
      selectedColor: AppColors.primary,
      side: BorderSide(
        color:
            isSelected ? AppColors.primary : AppColors.primary.withAlpha(100),
        width: 1.5,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    );
  }

  Widget _buildStepCard({
    required String title,
    required String subtitle,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF64748B),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF374151),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red),
            ),
            filled: true,
            fillColor: const Color(0xFFF9FAFB),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildDateTimeField({
    required TextEditingController controller,
    required String label,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF374151),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          readOnly: true,
          validator: validator,
          onTap: () => _selectDateTime(controller),
          decoration: InputDecoration(
            suffixIcon: const Icon(Icons.calendar_today_outlined),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red),
            ),
            filled: true,
            fillColor: const Color(0xFFF9FAFB),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ],
    );
  }

  Future<void> _selectDateTime(TextEditingController controller) async {
    final initialDate = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );

    if (date != null && mounted) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(initialDate),
      );

      if (time != null && mounted) {
        final selectedDateTime = DateTime(
          date.year,
          date.month,
          date.day,
          time.hour,
          time.minute,
        );
        controller.text =
            DateFormat(_displayDateFormat).format(selectedDateTime);
      }
    }
  }

  Widget _buildBottomButtons() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Color(0xFFE5E7EB)),
        ),
      ),
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              child: ElevatedButton(
                onPressed: () => setState(() => _currentStep--),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF6B7280),
                  elevation: 0,
                  side: const BorderSide(color: Color(0xFFD1D5DB)),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Wstecz',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          if (_currentStep > 0) const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: _isLoading
                  ? null
                  : () {
                      if (_currentStep < 2) {
                        setState(() => _currentStep++);
                      } else {
                        _submitForm();
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(
                      _currentStep < 2 ? 'Dalej' : 'Zaktualizuj Wydarzenie',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  String? _validateNotEmpty(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName jest wymagane';
    }
    return null;
  }

  String? _validateNumber(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName jest wymagane';
    }
    if (int.tryParse(value.trim()) == null) {
      return '$fieldName musi być liczbą';
    }
    return null;
  }

  String? _validateDate(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName jest wymagane';
    }
    try {
      DateFormat(_displayDateFormat).parse(value.trim());
      return null;
    } catch (err) {
      return '$fieldName ma nieprawidłowy format';
    }
  }
}
