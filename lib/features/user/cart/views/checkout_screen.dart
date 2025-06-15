import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:resellio/features/common/style/app_colors.dart';
import 'package:resellio/features/common/widgets/error_widget.dart';
import 'package:resellio/features/user/cart/bloc/cart_cubit.dart';
import 'package:resellio/features/user/cart/bloc/cart_state.dart';
import 'package:resellio/features/user/cart/model/cart_item.dart';
import 'package:resellio/features/user/tickets/bloc/tickets_cubit.dart';
import 'package:resellio/routes/customer_routes.dart';

class CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.replaceAll(' ', '');
    final buffer = StringBuffer();

    for (var i = 0; i < text.length; i++) {
      if (i > 0 && i % 4 == 0) {
        buffer.write(' ');
      }
      buffer.write(text[i]);
    }

    final formatted = buffer.toString();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

class ExpiryDateFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.replaceAll('/', '');

    if (text.length > 4) {
      return oldValue;
    }

    final buffer = StringBuffer();
    for (var i = 0; i < text.length; i++) {
      if (i == 2) {
        buffer.write('/');
      }
      buffer.write(text[i]);
    }

    final formatted = buffer.toString();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

class CustomerCheckoutScreen extends StatefulWidget {
  const CustomerCheckoutScreen({super.key});

  @override
  State<CustomerCheckoutScreen> createState() => _CustomerCheckoutScreenState();
}

class _CustomerCheckoutScreenState extends State<CustomerCheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _billingStreetController = TextEditingController();
  final _billingCityController = TextEditingController();
  final _billingPostalCodeController = TextEditingController();
  final _billingCountryController = TextEditingController();

  // Payment fields
  final _cardNumberController = TextEditingController();
  final _cardExpiryController = TextEditingController();
  final _cvvController = TextEditingController();
  String _selectedPaymentMethod = 'card';
  bool _agreeToTerms = false;
  bool _isProcessingPayment = false;
  @override
  void dispose() {
    _emailController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _billingStreetController.dispose();
    _billingCityController.dispose();
    _billingPostalCodeController.dispose();
    _billingCountryController.dispose();
    _cardNumberController.dispose();
    _cardExpiryController.dispose();
    _cvvController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: _buildAppBar(),
      body: BlocListener<CartCubit, CartState>(
        listener: (context, state) {
          if (state is CartErrorState) {
            // Show error message and stop loading
            if (_isProcessingPayment) {
              setState(() {
                _isProcessingPayment = false;
              });
            }
            ErrorSnackBar.show(context, state.message);
            context.read<CartCubit>().fetchCart();
          }
        },
        child: BlocBuilder<CartCubit, CartState>(
          builder: (context, state) {
            if (state is CartLoadingState && !_isProcessingPayment) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is CartErrorState) {
              return CommonErrorWidget(
                message: state.message,
                onRetry: () => context.read<CartCubit>().fetchCart(),
              );
            }

            if (state is! CartLoadedState) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state.items.isEmpty) {
              Navigator.of(context).pop();
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildOrderSummary(state),
                    const SizedBox(height: 24),
                    // _buildPersonalInformation(),
                    // const SizedBox(height: 24),
                    // _buildBillingAddress(),
                    // const SizedBox(height: 24),
                    _buildPaymentMethod(),
                    const SizedBox(height: 24),
                    _buildTermsAndConditions(),
                    const SizedBox(height: 32),
                    _buildPaymentButton(state),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      foregroundColor: const Color(0xFF2D3436),
      title: const Text(
        'Płatność',
        style: TextStyle(fontWeight: FontWeight.w600),
      ),
      centerTitle: true,
      elevation: 0,
    );
  }

  Widget _buildOrderSummary(CartLoadedState state) {
    return _buildSection(
      title: 'Podsumowanie zamówienia',
      icon: Icons.receipt_long,
      child: Column(
        children: [
          ...state.items.map(_buildOrderItem),
          const Divider(height: 24),
          _buildOrderTotals(state),
        ],
      ),
    );
  }

  Widget _buildOrderItem(CartItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFBFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE9ECEF)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              item.isResell ? Icons.people : Icons.confirmation_number,
              color: AppColors.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.eventName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                Text(
                  '${item.ticketType} • ${item.organizerName}',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
                if (item.isResell)
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Bilet z drugiej ręki',
                      style: TextStyle(
                        color: Colors.orange[700],
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Text(
            '${item.totalPrice.toStringAsFixed(2)} ${item.currency}',
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderTotals(CartLoadedState state) {
    final subtotal = state.totalPrice;
    const serviceFee = 0;
    final total = subtotal + serviceFee;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: _buildTotalRow(
        'Suma całkowita',
        '${total.toStringAsFixed(2)} PLN',
        isTotal: true,
      ),
    );
  }

  Widget _buildTotalRow(String label, String amount, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 16 : 14,
            fontWeight: isTotal ? FontWeight.w600 : FontWeight.normal,
            color: isTotal ? Colors.black : Colors.grey[700],
          ),
        ),
        Text(
          amount,
          style: TextStyle(
            fontSize: isTotal ? 16 : 14,
            fontWeight: FontWeight.w600,
            color: isTotal ? AppColors.primary : Colors.black,
          ),
        ),
      ],
    );
  }

  // for future use, if needed
  // ignore: unused_element
  Widget _buildPersonalInformation() {
    return _buildSection(
      title: 'Dane osobowe',
      icon: Icons.person,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  controller: _firstNameController,
                  label: 'Imię',
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(50),
                  ],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Wprowadź imię';
                    }
                    if (value.trim().length < 2) {
                      return 'Imię jest za krótkie';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildTextField(
                  controller: _lastNameController,
                  label: 'Nazwisko',
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(50),
                  ],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Wprowadź nazwisko';
                    }
                    if (value.trim().length < 2) {
                      return 'Nazwisko jest za krótkie';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _emailController,
            label: 'Adres e-mail',
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Wprowadź adres e-mail';
              }
              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                  .hasMatch(value)) {
                return 'Wprowadź poprawny adres e-mail';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _phoneController,
            label: 'Numer telefonu',
            keyboardType: TextInputType.phone,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[\d\s\+\-\(\)]')),
              LengthLimitingTextInputFormatter(20),
            ],
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Wprowadź numer telefonu';
              }
              final phoneNumber = value.replaceAll(RegExp(r'[\s\-\(\)]'), '');
              if (phoneNumber.length < 9) {
                return 'Numer telefonu jest za krótki';
              }
              if (!RegExp(r'^[\+]?[\d]+$').hasMatch(phoneNumber)) {
                return 'Nieprawidłowy format numeru telefonu';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  // for future use, if needed
  // ignore: unused_element
  Widget _buildBillingAddress() {
    return _buildSection(
      title: 'Adres rozliczeniowy',
      icon: Icons.location_on,
      child: Column(
        children: [
          _buildTextField(
            controller: _billingStreetController,
            label: 'Ulica i numer domu',
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Wprowadź adres';
              }
              if (value.trim().length < 5) {
                return 'Adres jest za krótki';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  controller: _billingCityController,
                  label: 'Miasto',
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(50),
                  ],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Wprowadź miasto';
                    }
                    if (value.trim().length < 2) {
                      return 'Nazwa miasta jest za krótka';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildTextField(
                  controller: _billingPostalCodeController,
                  label: 'Kod pocztowy',
                  keyboardType: TextInputType.text,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[\d\s\-]')),
                    LengthLimitingTextInputFormatter(10),
                  ],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Wprowadź kod pocztowy';
                    }
                    if (!RegExp(r'^\d{2}-?\d{3}$')
                        .hasMatch(value.replaceAll(' ', ''))) {
                      return 'Format: 00-000';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _billingCountryController,
            label: 'Kraj',
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Wprowadź kraj';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethod() {
    return _buildSection(
      title: 'Metoda płatności',
      icon: Icons.payment,
      child: Column(
        children: [
          _buildPaymentOption(
            value: 'card',
            title: 'Karta płatnicza',
            subtitle: 'Visa, Mastercard',
            icon: Icons.credit_card,
          ),
          if (_selectedPaymentMethod == 'card') ...[
            const SizedBox(height: 16),
            _buildCardPaymentFields(),
          ],
        ],
      ),
    );
  }

  Widget _buildCardPaymentFields() {
    return Column(
      children: [
        _buildTextField(
          controller: _cardNumberController,
          label: 'Numer karty',
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(19), // 16 digits + 3 spaces
            CardNumberFormatter(),
          ],
          maxLength: 19,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Wprowadź numer karty';
            }
            final cardNumber = value.replaceAll(' ', '');
            if (cardNumber.length < 13 || cardNumber.length > 19) {
              return 'Numer karty musi mieć 13-19 cyfr';
            }
            if (!RegExp(r'^\d+$').hasMatch(cardNumber)) {
              return 'Numer karty może zawierać tylko cyfry';
            }
            if (!_isValidCardNumber(cardNumber)) {
              return 'Nieprawidłowy numer karty';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                controller: _cardExpiryController,
                label: 'Data ważności (MM/RR)',
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(4),
                  ExpiryDateFormatter(),
                ],
                maxLength: 5,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Wprowadź datę ważności';
                  }
                  if (!RegExp(r'^\d{2}/\d{2}$').hasMatch(value)) {
                    return 'Format: MM/RR';
                  }

                  final parts = value.split('/');
                  final month = int.tryParse(parts[0]);
                  final year = int.tryParse(parts[1]);

                  if (month == null || month < 1 || month > 12) {
                    return 'Nieprawidłowy miesiąc (01-12)';
                  }

                  if (year == null) {
                    return 'Nieprawidłowy rok';
                  }

                  final now = DateTime.now();
                  final currentYear = now.year % 100;
                  final currentMonth = now.month;

                  if (year < currentYear ||
                      (year == currentYear && month < currentMonth)) {
                    return 'Karta jest przeterminowana';
                  }

                  return null;
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildTextField(
                controller: _cvvController,
                label: 'CVV',
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(3),
                ],
                maxLength: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Wprowadź CVV';
                  }
                  if (value.length < 3 || value.length > 4) {
                    return 'CVV: 3 cyfry';
                  }
                  if (!RegExp(r'^\d+$').hasMatch(value)) {
                    return 'CVV może zawierać tylko cyfry';
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPaymentOption({
    required String value,
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    final isSelected = _selectedPaymentMethod == value;

    return InkWell(
      onTap: () {
        setState(() {
          _selectedPaymentMethod = value;
        });
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withOpacity(0.05)
              : const Color(0xFFFAFBFC),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : const Color(0xFFE9ECEF),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary.withOpacity(0.1)
                    : Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: isSelected ? AppColors.primary : Colors.grey[600],
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: isSelected ? AppColors.primary : Colors.black,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Radio<String>(
              value: value,
              groupValue: _selectedPaymentMethod,
              onChanged: (newValue) {
                if (newValue != null) {
                  setState(() {
                    _selectedPaymentMethod = newValue;
                  });
                }
              },
              activeColor: AppColors.primary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTermsAndConditions() {
    return _buildSection(
      title: 'Warunki i zgody',
      icon: Icons.gavel,
      child: _buildCheckboxTile(
        value: _agreeToTerms,
        title: 'Akceptuję regulamin serwisu',
        subtitle: 'Zapoznałem się z warunkami korzystania z platformy',
        onChanged: (value) {
          setState(() {
            _agreeToTerms = value ?? false;
          });
        },
        required: true,
      ),
    );
  }

  Widget _buildCheckboxTile({
    required bool value,
    required String title,
    required String subtitle,
    required ValueChanged<bool?> onChanged,
    bool required = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFBFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE9ECEF)),
      ),
      child: Row(
        children: [
          Checkbox(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.primary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    if (required)
                      const Text(
                        '*',
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                  ],
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentButton(CartLoadedState state) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _agreeToTerms && !_isProcessingPayment
            ? () => _processPayment(state)
            : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
          disabledBackgroundColor: Colors.grey[300],
        ),
        child: _isProcessingPayment
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                'Zapłać ${state.totalPrice.toStringAsFixed(2)} PLN',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required Widget child,
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
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: AppColors.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2D3436),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    int? maxLength,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      maxLength: maxLength,
      decoration: InputDecoration(
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
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red),
        ),
        filled: true,
        fillColor: const Color(0xFFFAFBFC),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        counterText: maxLength != null ? '' : null,
      ),
    );
  }

  bool _isValidCardNumber(String cardNumber) {
    var sum = 0;
    var isEven = false;

    for (var i = cardNumber.length - 1; i >= 0; i--) {
      var digit = int.parse(cardNumber[i]);

      if (isEven) {
        digit *= 2;
        if (digit > 9) {
          digit = digit ~/ 10 + digit % 10;
        }
      }

      sum += digit;
      isEven = !isEven;
    }

    return sum % 10 == 0;
  }

  Future<void> _processPayment(CartLoadedState state) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (!_agreeToTerms) {
      ErrorSnackBar.show(
        context,
        'Musisz zaakceptować regulamin aby kontynuować',
      );
      return;
    }

    if (_selectedPaymentMethod == 'card') {
      if (_cardNumberController.text.isEmpty ||
          _cardExpiryController.text.isEmpty ||
          _cvvController.text.isEmpty) {
        ErrorSnackBar.show(context, 'Wypełnij wszystkie pola karty płatniczej');
        return;
      }
    }

    setState(() {
      _isProcessingPayment = true;
    });

    try {
      final success = await context.read<CartCubit>().processCheckout(
            amount: state.totalPrice,
            currency: 'PLN',
            cardNumber: _cardNumberController.text,
            cardExpiry: _cardExpiryController.text,
            cvv: _cvvController.text,
          );

      if (mounted) {
        if (success) {
          _showSuccessDialog();
        }
      }
    } catch (err) {
      if (mounted) {
        ErrorSnackBar.show(
          context,
          'Wystąpił błąd podczas przetwarzania płatności',
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessingPayment = false;
        });
      }
    }
  }

  void _showSuccessDialog() {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: 48,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Płatność zakończona sukcesem!',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Twoje bilety zostały wysłane na adres e-mail',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    const CustomerTicketsRoute().go(context);
                    context.read<TicketsCubit>().refreshTickets();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('OK'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
