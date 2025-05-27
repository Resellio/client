import 'package:bloc_presentation/bloc_presentation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:resellio/features/auth/bloc/auth_cubit.dart';
import 'package:resellio/features/auth/bloc/auth_cubit_event.dart';
import 'package:resellio/features/common/style/app_colors.dart';
import 'package:resellio/features/common/widgets/app_logo.dart';

class OrganizerRegistrationScreen extends StatefulWidget {
  const OrganizerRegistrationScreen({super.key});

  @override
  State<OrganizerRegistrationScreen> createState() =>
      _OrganizerRegistrationScreenState();
}

class _OrganizerRegistrationScreenState
    extends State<OrganizerRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _displayNameController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _displayNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocPresentationListener<AuthCubit, AuthCubitEvent>(
      listener: (context, event) {
        switch (event) {
          case AuthErrorEvent():
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(SnackBar(content: Text(event.reason)));
          case AuthenticatedEvent(:final user):
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(content: Text('Zalogowano jako ${user.email}')),
              );
        }
      },
      child: Scaffold(
        body: Stack(
          children: [
            const SizedBox.expand(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.primary, AppColors.primaryDark],
                  ),
                ),
              ),
            ),

            // Background decorative elements
            const Positioned(
              top: -50,
              right: -50,
              child: Opacity(
                opacity: 0.1,
                child: SizedBox(
                  width: 200,
                  height: 200,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
            ),
            const Positioned(
              bottom: -100,
              left: -50,
              child: Opacity(
                opacity: 0.08,
                child: SizedBox(
                  width: 200,
                  height: 200,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
            ),

            SingleChildScrollView(
              child: SafeArea(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 400),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const ResellioLogo(size: 100),
                            const SizedBox(height: 24),
                            const Text(
                              'Dokończ rejestrację',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                shadows: [
                                  Shadow(
                                    offset: Offset(0, 1),
                                    blurRadius: 1,
                                    color: Color.fromARGB(120, 0, 0, 0),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Podaj swoje dane, aby utworzyć konto organizatora',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 40),
                            _buildTextField(
                              'Imię',
                              controller: _firstNameController,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Wprowadź imię';
                                }
                                return null;
                              },
                              icon: Icons.person_outline,
                            ),
                            const SizedBox(height: 16),
                            _buildTextField(
                              'Nazwisko',
                              controller: _lastNameController,
                              icon: Icons.person_outline,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Wprowadź nazwisko';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            _buildTextField(
                              'Nazwa wyświetlana',
                              controller: _displayNameController,
                              icon: Icons.badge_outlined,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Wprowadź nazwę wyświetlaną';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 40),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : _submit,
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  backgroundColor: Colors.white,
                                  foregroundColor: AppColors.primary,
                                  disabledBackgroundColor: Colors.grey.shade300,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: _isLoading
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 3,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                            AppColors.primary,
                                          ),
                                        ),
                                      )
                                    : const Text(
                                        'Zarejestruj się',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                              ),
                            ),
                            const SizedBox(height: 32),
                            TextButton(
                              onPressed: () {
                                context.read<AuthCubit>().logout();
                              },
                              child: const Text(
                                'Anuluj',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white60,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  OutlineInputBorder buildBorder(Color color, {double width = 1.0}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: color, width: width),
    );
  }

  Widget _buildTextField(
    String label, {
    required TextEditingController controller,
    String? Function(String?)? validator,
    IconData? icon,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        hintStyle: const TextStyle(color: Colors.white60),
        fillColor: Colors.white.withAlpha(25),
        filled: true,
        prefixIcon: icon != null
            ? Icon(
                icon,
                color: Colors.white70,
              )
            : null,
        enabledBorder: buildBorder(Colors.white.withAlpha(25)),
        focusedBorder: buildBorder(Colors.white, width: 2),
        errorBorder: buildBorder(AppColors.error),
        focusedErrorBorder: buildBorder(AppColors.error, width: 2),
        errorStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          color: AppColors.error,
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
      });

      final authCubit = context.read<AuthCubit>();
      await authCubit.completeOrganizerRegistration(
        firstName: _firstNameController.text,
        lastName: _lastNameController.text,
        displayName: _displayNameController.text,
      );

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
