import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:resellio/features/common/bloc/categories_cubit.dart';
import 'package:resellio/features/common/bloc/categories_state.dart';
import 'package:resellio/features/common/data/api.dart';
import 'package:resellio/features/common/style/app_colors.dart';
import 'package:resellio/features/common/widgets/error_widget.dart';

class CreateEventRequest {
  CreateEventRequest({
    required this.name,
    required this.description,
    required this.startDate,
    required this.endDate,
    required this.minimumAge,
    required this.categories,
    required this.ticketTypes,
    this.eventStatus = 0,
    required this.createAddress,
  });

  String name;
  String description;
  String startDate;
  String endDate;
  int minimumAge;
  List<EventCategoryRequest> categories;
  List<TicketTypeRequest> ticketTypes;
  int eventStatus;
  EventAddressRequest createAddress;

  Map<String, dynamic> toJson() => {
        'name': name,
        'description': description,
        'startDate': startDate,
        'endDate': endDate,
        'minimumAge': minimumAge,
        'categories': categories.map((c) => c.toJson()).toList(),
        'ticketTypes': ticketTypes.map((t) => t.toJson()).toList(),
        'eventStatus': eventStatus,
        'createAddress': createAddress.toJson(),
      };
}

class EditEventRequest {
  EditEventRequest({
    required this.name,
    required this.description,
    required this.startDate,
    required this.endDate,
    required this.minimumAge,
    required this.categories,
    this.eventStatus = 0,
    required this.editAddress,
  });

  String name;
  String description;
  String startDate;
  String endDate;
  int minimumAge;
  List<EventCategoryRequest> categories;
  int eventStatus;
  EventAddressRequest editAddress;

  Map<String, dynamic> toJson() => {
        'name': name,
        'description': description,
        'startDate': startDate,
        'endDate': endDate,
        'minimumAge': minimumAge,
        'categories': categories.map((c) => c.toJson()).toList(),
        'eventStatus': eventStatus,
        'editAddress': editAddress.toJson(),
      };
}

class EventCategoryRequest {
  EventCategoryRequest({required this.categoryName});
  String categoryName;
  Map<String, dynamic> toJson() => {'categoryName': categoryName};
}

class TicketTypeRequest {
  TicketTypeRequest({
    required this.description,
    required this.maxCount,
    required this.price,
    required this.currency,
    required this.availableFrom,
  });

  String description;
  int maxCount;
  double price;
  String currency;
  String availableFrom;

  Map<String, dynamic> toJson() => {
        'description': description,
        'maxCount': maxCount,
        'price': price,
        'currency': currency,
        'availableFrom': availableFrom,
      };
}

class EventAddressRequest {
  EventAddressRequest({
    required this.country,
    required this.city,
    required this.street,
    required this.houseNumber,
    required this.flatNumber,
    required this.postalCode,
  });

  String country;
  String city;
  String street;
  int houseNumber;
  int flatNumber;
  String postalCode;

  Map<String, dynamic> toJson() => {
        'country': country,
        'city': city,
        'street': street,
        'houseNumber': houseNumber,
        'flatNumber': flatNumber,
        'postalCode': postalCode,
      };
}

class TicketTypeFormManager {
  TicketTypeFormManager({
    String? description,
    String? maxCount,
    String? price,
    String? currency,
    String? availableFrom,
  }) {
    descriptionController.text = description ?? '';
    maxCountController.text = maxCount ?? '';
    priceController.text = price ?? '';
    currencyController.text = currency ?? 'PLN';
    availableFromController.text = availableFrom ?? '';
  }

  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController maxCountController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController currencyController = TextEditingController();
  final TextEditingController availableFromController = TextEditingController();
  final String id = UniqueKey().toString();

  void dispose() {
    descriptionController.dispose();
    maxCountController.dispose();
    priceController.dispose();
    currencyController.dispose();
    availableFromController.dispose();
  }
}

class OrganizerNewEventScreen extends StatefulWidget {
  const OrganizerNewEventScreen({super.key, required this.apiService});

  final ApiService apiService;

  @override
  _OrganizerNewEventScreenState createState() =>
      _OrganizerNewEventScreenState();
}

class _OrganizerNewEventScreenState extends State<OrganizerNewEventScreen>
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

  final _ticketForms = [TicketTypeFormManager()];

  Uint8List? _imageBytes;
  String? _imageName;

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

    if (kDebugMode) {
      _nameController.text = 'Summer Music Fest 2025';
      _descriptionController.text = 'Ale jazda normlanie, ale jazda';
      _startDateController.text = DateFormat(_displayDateFormat)
          .format(DateTime.now().add(const Duration(days: 60, hours: 2)));
      _endDateController.text = DateFormat(_displayDateFormat)
          .format(DateTime.now().add(const Duration(days: 60, hours: 5)));
      _minAgeController.text = '18';

      _streetController.text = 'Pl. Politechniki';
      _houseNumberController.text = '244';
      _flatNumberController.text = '11';
      _cityController.text = 'Warszawa';
      _postalCodeController.text = '01-234';
      _countryController.text = 'Polska';

      _categoriesController.text = '';

      _ticketForms[0].descriptionController.text = 'VIP';
      _ticketForms[0].maxCountController.text = '100';
      _ticketForms[0].priceController.text = '99.99';
      _ticketForms[0].currencyController.text = 'PLN';
      _ticketForms[0].availableFromController.text =
          DateFormat(_displayDateFormat)
              .format(DateTime.now().add(const Duration(days: 30)));
    }
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
    for (final form_ in _ticketForms) {
      form_.dispose();
    }
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        withData: true,
      );

      if (result != null && result.files.single.bytes != null) {
        setState(() {
          _imageBytes = result.files.single.bytes;
          _imageName = result.files.single.name;
        });
      }
    } catch (err) {
      if (mounted) {
        ErrorSnackBar.show(context, 'Błąd podczas wybierania obrazu: $err');
      }
    }
  }

  void _clearImage() {
    setState(() {
      _imageBytes = null;
      _imageName = null;
    });
  }

  String? _isoFormat(String? dateString) {
    if (dateString == null || dateString.isEmpty) {
      return null;
    }
    try {
      final DateTime dateTime =
          DateFormat(_displayDateFormat).parse(dateString);
      return dateTime.toUtc().toIso8601String();
    } catch (err) {
      return null;
    }
  }

  Future<void> _selectDateTime(
    BuildContext context,
    TextEditingController controller,
  ) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime(DateTime.now().year + 5),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: AppColors.primary,
                ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null && context.mounted) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(
          controller.text.isNotEmpty
              ? DateFormat(_displayDateFormat).parse(controller.text)
              : DateTime.now(),
        ),
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: Theme.of(context).colorScheme.copyWith(
                    primary: AppColors.primary,
                  ),
            ),
            child: child!,
          );
        },
      );
      if (pickedTime != null) {
        controller.text = DateFormat(_displayDateFormat).format(
          DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          ),
        );
      }
    }
  }

  void _addTicketType() {
    setState(() {
      _ticketForms.add(TicketTypeFormManager());
    });
  }

  void _removeTicketType(int index) {
    setState(() {
      _ticketForms[index].dispose();
      _ticketForms.removeAt(index);
      if (_ticketForms.isEmpty) {
        _addTicketType();
      }
    });
  }

  String? _validateNotEmpty(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName nie może być puste';
    }
    return null;
  }

  String? _validateNumber(
    String? value,
    String fieldName, {
    bool allowDecimal = false,
  }) {
    if (value == null || value.isEmpty) {
      return '$fieldName nie może być puste';
    }
    if (allowDecimal) {
      if (double.tryParse(value) == null) {
        return '$fieldName musi być liczbą';
      }
    } else {
      if (int.tryParse(value) == null) {
        return '$fieldName musi być liczbą całkowitą';
      }
    }
    if (allowDecimal && double.tryParse(value)! < 0) {
      return '$fieldName nie może być ujemne';
    }
    return null;
  }

  String? _validateDate(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName nie może być pusta';
    }
    try {
      DateFormat(_displayDateFormat).parse(value);
      return null;
    } catch (err) {
      return 'Nieprawidłowy format daty ($fieldName)';
    }
  }

  String? _validateDateOrder(String? startDateStr, String? endDateStr) {
    if (startDateStr == null ||
        startDateStr.isEmpty ||
        endDateStr == null ||
        endDateStr.isEmpty) {
      return null;
    }
    try {
      final startDate = DateFormat(_displayDateFormat).parse(startDateStr);
      final endDate = DateFormat(_displayDateFormat).parse(endDateStr);
      if (startDate.isAfter(endDate)) {
        return 'Data rozpoczęcia musi być przed datą zakończenia';
      }
      if (startDate.isBefore(DateTime.now())) {
        return 'Data rozpoczęcia nie może być w przeszłości';
      }
    } catch (err) {
      return 'Nieprawidłowe daty';
    }
    return null;
  }

  String? _validateTicketAvailableFrom(
    String? availableFromStr,
    String? eventStartDateStr,
  ) {
    if (availableFromStr == null ||
        availableFromStr.isEmpty ||
        eventStartDateStr == null ||
        eventStartDateStr.isEmpty) {
      return null;
    }
    try {
      final availableFrom =
          DateFormat(_displayDateFormat).parse(availableFromStr);
      final eventStartDate =
          DateFormat(_displayDateFormat).parse(eventStartDateStr);
      if (availableFrom.isAfter(eventStartDate)) {
        return 'Dostępne od musi być przed lub w dniu rozpoczęcia wydarzenia';
      }
    } catch (err) {
      return 'Nieprawidłowe daty (dostępne od / rozpoczęcie)';
    }
    return null;
  }

  bool _validateCurrentStep() {
    switch (_currentStep) {
      case 0:
        return _validateNotEmpty(_nameController.text, 'Nazwa') == null &&
            _validateNotEmpty(_descriptionController.text, 'Opis') == null &&
            _validateDate(_startDateController.text, 'Data rozpoczęcia') ==
                null &&
            _validateDate(_endDateController.text, 'Data zakończenia') ==
                null &&
            _validateNumber(_minAgeController.text, 'Minimalny wiek') == null &&
            _validateDateOrder(
                  _startDateController.text,
                  _endDateController.text,
                ) ==
                null;
      case 1:
        return _validateNotEmpty(_streetController.text, 'Ulica') == null &&
            _validateNumber(_houseNumberController.text, 'Numer domu') ==
                null &&
            _validateNotEmpty(_cityController.text, 'Miasto') == null &&
            _validateNotEmpty(_postalCodeController.text, 'Kod pocztowy') ==
                null &&
            _validateNotEmpty(_countryController.text, 'Kraj') == null;

      case 2:
        return true;
      case 3:
        for (final ticketForm in _ticketForms) {
          if (_validateNotEmpty(
                    ticketForm.descriptionController.text,
                    'Nazwa typu biletu',
                  ) !=
                  null ||
              _validateNumber(ticketForm.maxCountController.text, 'Ilość') !=
                  null ||
              _validateNumber(
                    ticketForm.priceController.text,
                    'Cena',
                    allowDecimal: true,
                  ) !=
                  null ||
              ticketForm.currencyController.text.isEmpty ||
              ticketForm.currencyController.text.toUpperCase() != 'PLN' ||
              _validateDate(
                    ticketForm.availableFromController.text,
                    'Dostępne od',
                  ) !=
                  null ||
              _validateTicketAvailableFrom(
                    ticketForm.availableFromController.text,
                    _startDateController.text,
                  ) !=
                  null) {
            return false;
          }
        }
        return true;

      default:
        return true;
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      ErrorSnackBar.show(context, 'W formularzu znajdują się błędy');
      return;
    }

    final dateOrderError =
        _validateDateOrder(_startDateController.text, _endDateController.text);
    if (dateOrderError != null) {
      ErrorSnackBar.show(context, dateOrderError);
      return;
    }

    for (final ticketForm in _ticketForms) {
      final availableFromError = _validateTicketAvailableFrom(
        ticketForm.availableFromController.text,
        _startDateController.text,
      );
      if (availableFromError != null) {
        ErrorSnackBar.show(
          context,
          'Błąd w typie biletu "${ticketForm.descriptionController.text}": $availableFromError',
        );
        return;
      }
    }

    setState(() => _isLoading = true);

    try {
      final eventData = CreateEventRequest(
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
        createAddress: EventAddressRequest(
          country: _countryController.text,
          city: _cityController.text,
          street: _streetController.text,
          houseNumber: int.tryParse(_houseNumberController.text) ?? 0,
          flatNumber: int.tryParse(_flatNumberController.text) ?? 0,
          postalCode: _postalCodeController.text,
        ),
        ticketTypes: _ticketForms.map((form) {
          return TicketTypeRequest(
            description: form.descriptionController.text,
            maxCount: int.tryParse(form.maxCountController.text) ?? 0,
            price: double.tryParse(form.priceController.text) ?? 0.0,
            currency: form.currencyController.text,
            availableFrom: _isoFormat(form.availableFromController.text)!,
          );
        }).toList(),
      );

      final response = await widget.apiService.createEvent(
        eventData: eventData.toJson(),
        imageBytes: _imageBytes,
        imageName: _imageName,
      );
      if (!response.success) {
        if (mounted) {
          ErrorSnackBar.show(
            context,
            'Błąd podczas tworzenia wydarzenia: ${response.message ?? 'Nieznany błąd'}',
          );
        }
        return;
      }
      if (mounted) {
        SuccessSnackBar.show(context, 'Wydarzenie utworzone pomyślnie!');
        Navigator.of(context).pop(true);
        // TODO: Navigate to the event detail screen
        // const OrganizerEventDetailRoute(
        //         eventId: '7d7cc20f-e48f-4b68-cee3-08ddabf54e26')
        //     .go(context);
      }
    } catch (err) {
      if (mounted) {
        ErrorSnackBar.show(context, 'Błąd podczas tworzenia wydarzenia: $err');
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
            _buildNavigationButtons(),
          ],
        ),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.white,
      foregroundColor: const Color(0xFF2D3436),
      title: const Text(
        'Nowe Wydarzenie',
        style: TextStyle(fontWeight: FontWeight.w600),
      ),
      centerTitle: true,
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
        children: List.generate(4, (index) {
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
                if (index < 3) const SizedBox(width: 8),
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
      case 3:
        return _buildTicketsStep();
      default:
        return _buildBasicInfoStep();
    }
  }

  Widget _buildImagePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Zdjęcie promocyjne',
          style: TextStyle(
            color: Color(0xFF636E72),
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _pickImage,
          child: Container(
            width: double.infinity,
            height: 150,
            decoration: BoxDecoration(
              color: const Color(0xFFFAFBFC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE9ECEF), width: 1.5),
            ),
            child: _imageBytes == null
                ? const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.cloud_upload_outlined,
                        color: AppColors.primary,
                        size: 40,
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Wybierz zdjęcie',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  )
                : Stack(
                    fit: StackFit.expand,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(11),
                        child: Image.memory(
                          _imageBytes!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const Center(child: Icon(Icons.error)),
                        ),
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Material(
                          color: Colors.black54,
                          shape: const CircleBorder(),
                          child: InkWell(
                            onTap: _clearImage,
                            borderRadius: BorderRadius.circular(12),
                            child: const Padding(
                              padding: EdgeInsets.all(4),
                              child: Icon(
                                Icons.close,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildBasicInfoStep() {
    return _buildStepContainer(
      title: 'Podstawowe Informacje',
      icon: Icons.event,
      children: [
        _buildImagePicker(),
        const SizedBox(height: 16),
        _buildModernTextField(
          _nameController,
          'Nazwa wydarzenia',
          validator: (v) => _validateNotEmpty(v, 'Nazwa'),
        ),
        _buildModernTextField(
          _descriptionController,
          'Opis wydarzenia',
          maxLines: 4,
          validator: (v) => _validateNotEmpty(v, 'Opis'),
        ),
        Row(
          children: [
            Expanded(
              child: _buildDateTimeField(
                _startDateController,
                'Data rozpoczęcia',
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildDateTimeField(
                _endDateController,
                'Data zakończenia',
              ),
            ),
          ],
        ),
        _buildModernTextField(
          _minAgeController,
          'Minimalny wiek',
          keyboardType: TextInputType.number,
          validator: (v) => _validateNumber(v, 'Minimalny wiek'),
        ),
      ],
    );
  }

  Widget _buildAddressStep() {
    return _buildStepContainer(
      title: 'Lokalizacja Wydarzenia',
      icon: Icons.location_on,
      children: [
        _buildModernTextField(
          _streetController,
          'Ulica',
          validator: (v) => _validateNotEmpty(v, 'Ulica'),
        ),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: _buildModernTextField(
                _houseNumberController,
                'Numer domu',
                keyboardType: TextInputType.number,
                validator: (v) => _validateNumber(v, 'Numer domu'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildModernTextField(
                _flatNumberController,
                'Nr mieszkania',
                keyboardType: TextInputType.number,
              ),
            ),
          ],
        ),
        _buildModernTextField(
          _cityController,
          'Miasto',
          validator: (v) => _validateNotEmpty(v, 'Miasto'),
        ),
        Row(
          children: [
            Expanded(
              child: _buildModernTextField(
                _postalCodeController,
                'Kod pocztowy',
                validator: (v) => _validateNotEmpty(v, 'Kod pocztowy'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildModernTextField(
                _countryController,
                'Kraj',
                validator: (v) => _validateNotEmpty(v, 'Kraj'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCategoriesStep() {
    return _buildStepContainer(
      title: 'Kategorie Wydarzenia',
      icon: Icons.category,
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
                      final isSelected = selectedCategories.contains(category);
                      return _buildSelectableCategoryChip(category, isSelected);
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

  Widget _buildTicketsStep() {
    return _buildStepContainer(
      title: 'Typy Biletów',
      icon: Icons.confirmation_number,
      children: [
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _ticketForms.length,
          itemBuilder: (context, index) => _buildModernTicketForm(index),
        ),
        const SizedBox(height: 16),
        _buildAddTicketButton(),
      ],
    );
  }

  Widget _buildStepContainer({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withAlpha(50),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: AppColors.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF2D3436),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildModernTextField(
    TextEditingController controller,
    String label, {
    int? maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    String? suffixText,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        validator: validator,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        style: const TextStyle(fontSize: 16),
        decoration: InputDecoration(
          suffixText: suffixText,
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE9ECEF)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE9ECEF)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.primary, width: 2),
          ),
          filled: true,
          fillColor: const Color(0xFFFAFBFC),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }

  Widget _buildDateTimeField(
    TextEditingController controller,
    String label,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        readOnly: true,
        onTap: () => _selectDateTime(context, controller),
        validator: (v) => _validateDate(v, label),
        autovalidateMode: AutovalidateMode.onUserInteraction,
        style: const TextStyle(fontSize: 16),
        decoration: InputDecoration(
          labelText: label,
          suffixIcon:
              const Icon(Icons.calendar_today, color: AppColors.primary),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE9ECEF)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE9ECEF)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.primary, width: 2),
          ),
          filled: true,
          fillColor: const Color(0xFFFAFBFC),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }

  Widget _buildModernTicketForm(int index) {
    final ticketForm = _ticketForms[index];
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFBFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE9ECEF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withAlpha(50),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.confirmation_number,
                      color: AppColors.primary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Typ Biletu ${index + 1}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2D3436),
                    ),
                  ),
                ],
              ),
              if (_ticketForms.length > 1)
                IconButton(
                  onPressed: () => _removeTicketType(index),
                  icon: const Icon(
                    Icons.close,
                    color: Color(0xFFE17055),
                    size: 20,
                  ),
                  style: IconButton.styleFrom(
                    backgroundColor: const Color(0xFFE17055).withAlpha(30),
                    padding: const EdgeInsets.all(6),
                    minimumSize: const Size(32, 32),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          _buildModernTextField(
            ticketForm.descriptionController,
            'Nazwa typu biletu',
            validator: (v) => _validateNotEmpty(v, 'Nazwa typu biletu'),
          ),
          Row(
            children: [
              Expanded(
                child: _buildModernTextField(
                  ticketForm.maxCountController,
                  'Ilość',
                  keyboardType: TextInputType.number,
                  validator: (v) => _validateNumber(v, 'Ilość'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildModernTextField(
                  ticketForm.priceController,
                  'Cena',
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  validator: (v) =>
                      _validateNumber(v, 'Cena', allowDecimal: true),
                  suffixText: 'PLN',
                ),
              ),
            ],
          ),
          _buildDateTimeField(
            ticketForm.availableFromController,
            'Dostępne od',
          ),
        ],
      ),
    );
  }

  Widget _buildAddTicketButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: _addTicketType,
        icon: const Icon(
          Icons.add_circle_outline,
          color: AppColors.primary,
        ),
        label: const Text(
          'Dodaj kolejny typ biletu',
          style: TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: AppColors.primaryLight, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 14),
          backgroundColor: AppColors.primary.withAlpha(30),
        ),
      ),
    );
  }

  Widget _buildNavigationButtons() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 8,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  setState(() {
                    _currentStep--;
                  });
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  side: const BorderSide(color: AppColors.primary),
                ),
                child: const Text(
                  'Wstecz',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
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
                      if (_currentStep < 3) {
                        _formKey.currentState?.validate();
                        if (_validateCurrentStep()) {
                          setState(() {
                            _currentStep++;
                          });
                        } else {
                          ErrorSnackBar.show(
                            context,
                            'Proszę poprawić błędy w formularzu',
                          );
                        }
                      } else {
                        _submitForm();
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Text(
                      _currentStep < 3 ? 'Dalej' : 'Utwórz Wydarzenie',
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
}
