import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For formatting date and time
import 'package:flutter/foundation.dart'; // For kDebugMode

class OrganizerNewEventScreen extends StatefulWidget {
  const OrganizerNewEventScreen({super.key});

  @override
  _OrganizerNewEventScreenState createState() =>
      _OrganizerNewEventScreenState();
}

class _OrganizerNewEventScreenState extends State<OrganizerNewEventScreen> {
  final _formKey = GlobalKey<FormState>();

  // Form field controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();
  final TextEditingController _locationNameController = TextEditingController();
  final TextEditingController _latitudeController = TextEditingController();
  final TextEditingController _longitudeController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _zipcodeController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _countryController = TextEditingController();
  final TextEditingController _minAgeController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _ticketNameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _currencyController = TextEditingController();
  final TextEditingController _ticketCountController = TextEditingController();
  final TextEditingController _availableFromController =
      TextEditingController();

  // Categories
  List<String> categories = [];

  // Method to create the JSON
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

  // Function to pick a date
  Future<void> _selectDate(
    BuildContext context,
    TextEditingController controller,
  ) async {
    final initialDate = DateTime.now();
    final firstDate = DateTime(1900);
    final lastDate = DateTime(2100);

    final DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
    );

    if (selectedDate != null && context.mounted) {
      final TimeOfDay? selectedTime = await showTimePicker(
        context: context,
        initialTime:
            TimeOfDay(hour: selectedDate.hour, minute: selectedDate.minute),
      );

      if (selectedTime != null) {
        final finalDate = DateTime(
          selectedDate.year,
          selectedDate.month,
          selectedDate.day,
          selectedTime.hour,
          selectedTime.minute,
        );
        controller.text = DateFormat('yyyy-MM-dd HH:mm').format(finalDate);
      }
    }
  }

  String? _validateDateConstraints() {
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
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration:
                      const InputDecoration(labelText: 'Nazwa wydarzenia'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Proszę wprowadzić nazwę wydarzenia';
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
                  onTap: () => _selectDate(context, _startDateController),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Proszę wprowadzić datę rozpoczęcia';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _endDateController,
                  decoration: const InputDecoration(
                    labelText: 'Data zakończenia (RRRR-MM-DD GG:MM)',
                  ),
                  readOnly: true,
                  onTap: () => _selectDate(context, _endDateController),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Proszę wprowadzić datę zakończenia';
                    }
                    return null;
                  },
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
                  decoration: const InputDecoration(labelText: 'Opis'),
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
                  onTap: () => _selectDate(context, _availableFromController),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Proszę wprowadzić datę rozpoczęcia sprzedaży';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState?.validate() ?? false) {
                      final dateValidation = _validateDateConstraints();
                      if (dateValidation != null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(dateValidation)),
                        );
                        return;
                      }
                      _generateJson();
                    }
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
