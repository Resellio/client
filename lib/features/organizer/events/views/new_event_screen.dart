import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class OrganizerNewEventScreen extends StatefulWidget {
  const OrganizerNewEventScreen({super.key});

  @override
  _OrganizerNewEventScreenState createState() =>
      _OrganizerNewEventScreenState();
}

class _OrganizerNewEventScreenState extends State<OrganizerNewEventScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _startDateController = TextEditingController();
  final _endDateController = TextEditingController();
  final _locationNameController = TextEditingController();
  final _latitudeController = TextEditingController();
  final _longitudeController = TextEditingController();
  final _addressController = TextEditingController();
  final _zipcodeController = TextEditingController();
  final _cityController = TextEditingController();
  final _countryController = TextEditingController();
  final _minAgeController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _ticketNameController = TextEditingController();
  final _priceController = TextEditingController();
  final _currencyController = TextEditingController();
  final _ticketCountController = TextEditingController();
  final _availableFromController = TextEditingController();

  List<String> categories = [];

  void _generateJson() {
    final eventData = {
      'name': _nameController.text,
      'date': {
        'start': _startDateController.text,
        'end': _endDateController.text,
      },
      'location': {
        'name': _locationNameController.text,
        'latitude': double.tryParse(_latitudeController.text) ?? 0.0,
        'longitude': double.tryParse(_longitudeController.text) ?? 0.0,
        'address': _addressController.text,
        'zipcode': _zipcodeController.text,
        'city': _cityController.text,
        'country': _countryController.text,
      },
      'category': [categories],
      'minAge': int.tryParse(_minAgeController.text) ?? 0,
      'description': _descriptionController.text,
      'tickets': [
        {
          'ticketName': _ticketNameController.text,
          'price': double.tryParse(_priceController.text) ?? 0.0,
          'currency': _currencyController.text,
          'count': int.tryParse(_ticketCountController.text) ?? 0,
          'available_from': _availableFromController.text,
        }
      ],
    };
    print(jsonEncode(eventData));
  }

  Future<void> _selectDateUsingDatePicker(
    BuildContext context,
    TextEditingController controller,
  ) async {
    final nowDate = DateTime.now();
    final lastDate = DateTime(nowDate.year + 1, nowDate.month, nowDate.day);

    final DateTime? selectedDate = await showDatePicker(
      context: context,
      firstDate: nowDate,
      lastDate: lastDate,
    );

    if (selectedDate != null && context.mounted) {
      final TimeOfDay? selectedTime = await showTimePicker(
        context: context,
        initialTime:
            TimeOfDay(hour: selectedDate.hour, minute: selectedDate.minute),
      );

      if (selectedTime != null) {
        controller.text = DateFormat('yyyy-MM-dd HH:mm').format(selectedDate);
      }
    }
  }

  String? _validateDateConstraints(String? value) {
    if (value == null || value.isEmpty) {
      return 'Wprowadź datę';
    }
    final startDate =
        DateFormat('yyyy-MM-dd HH:mm').parse(_startDateController.text);
    final endDate =
        DateFormat('yyyy-MM-dd HH:mm').parse(_endDateController.text);
    final availableFrom =
        DateFormat('yyyy-MM-dd HH:mm').parse(_availableFromController.text);
    final now = DateTime.now();

    if (availableFrom.isAfter(startDate)) {
      return 'Dostępne od musi być wcześniejsze niż data rozpoczęcia.';
    }

    if (startDate.isBefore(now)) {
      return 'Data rozpoczęcia musi być późniejsza niż obecny czas.';
    }

    if (startDate.isAfter(endDate)) {
      return 'Data rozpoczęcia musi być wcześniejsza niż data zakończenia.';
    }

    return null;
  }

  @override
  void initState() {
    super.initState();
// DEBUG mode inital values
    if (kDebugMode) {
      _nameController.text = 'Test Event';
      _startDateController.text = '2025-03-21 12:00';
      _endDateController.text = '2025-03-21 15:00';
      _locationNameController.text = 'Test Location';
      _latitudeController.text = '52.2298';
      _longitudeController.text = '21.0118';
      _addressController.text = 'Some Address';
      _zipcodeController.text = '00-000';
      _cityController.text = 'Warsaw';
      _countryController.text = 'Poland';
      _minAgeController.text = '18';
      _descriptionController.text = 'Test description';
      _ticketNameController.text = 'Regular Ticket';
      _priceController.text = '49.99';
      _currencyController.text = 'PLN';
      _ticketCountController.text = '100';
      _availableFromController.text = '2025-03-01 10:00';
      categories = ['Live', 'Music'];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nowe Wydarzenie'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            autovalidateMode: AutovalidateMode.onUserInteraction,
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration:
                      const InputDecoration(labelText: 'Nazwa wydarzenia'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Wprowadź nazwę wydarzenia';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _startDateController,
                  decoration: const InputDecoration(
                    labelText: 'Data rozpoczęcia (RRRR-MM-DD GG:MM)',
                  ),
                  readOnly: true,
                  onTap: () =>
                      _selectDateUsingDatePicker(context, _startDateController),
                  validator: _validateDateConstraints,
                ),
                TextFormField(
                  controller: _endDateController,
                  decoration: const InputDecoration(
                    labelText: 'Data zakończenia (RRRR-MM-DD GG:MM)',
                  ),
                  readOnly: true,
                  onTap: () =>
                      _selectDateUsingDatePicker(context, _endDateController),
                  validator: _validateDateConstraints,
                ),
                TextFormField(
                  controller: _locationNameController,
                  decoration: const InputDecoration(labelText: 'Nazwa miejsca'),
                ),
                TextFormField(
                  controller: _latitudeController,
                  decoration: const InputDecoration(
                    labelText: 'Szerokość geograficzna',
                  ),
                ),
                TextFormField(
                  controller: _longitudeController,
                  decoration:
                      const InputDecoration(labelText: 'Długość geograficzna'),
                ),
                TextFormField(
                  controller: _addressController,
                  decoration: const InputDecoration(labelText: 'Adres'),
                ),
                TextFormField(
                  controller: _zipcodeController,
                  decoration: const InputDecoration(labelText: 'Kod pocztowy'),
                ),
                TextFormField(
                  controller: _cityController,
                  decoration: const InputDecoration(labelText: 'Miasto'),
                ),
                TextFormField(
                  controller: _countryController,
                  decoration: const InputDecoration(labelText: 'Kraj'),
                ),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Kategoria (oddzielone przecinkami)',
                  ),
                  onChanged: (value) {
                    setState(() {
                      categories =
                          value.split(',').map((e) => e.trim()).toList();
                    });
                  },
                ),
                TextFormField(
                  controller: _minAgeController,
                  decoration:
                      const InputDecoration(labelText: 'Minimalny wiek'),
                ),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Opis',
                  ),
                  maxLines: null,
                  minLines: 1,
                ),
                TextFormField(
                  controller: _ticketNameController,
                  decoration: const InputDecoration(labelText: 'Nazwa biletu'),
                ),
                TextFormField(
                  controller: _priceController,
                  decoration: const InputDecoration(labelText: 'Cena'),
                ),
                TextFormField(
                  controller: _currencyController,
                  decoration: const InputDecoration(labelText: 'Waluta'),
                ),
                TextFormField(
                  controller: _ticketCountController,
                  decoration:
                      const InputDecoration(labelText: 'Liczba biletów'),
                ),
                TextFormField(
                  controller: _availableFromController,
                  decoration: const InputDecoration(
                    labelText: 'Dostępne od (RRRR-MM-DD GG:MM)',
                  ),
                  readOnly: true,
                  onTap: () => _selectDateUsingDatePicker(
                    context,
                    _availableFromController,
                  ),
                  validator: _validateDateConstraints,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    if (!(_formKey.currentState?.validate() ?? false)) {
                      return;
                    }
                    _generateJson();
                  },
                  child: const Text('Wyślij'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
