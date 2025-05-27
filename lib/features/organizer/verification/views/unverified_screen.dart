import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:resellio/features/auth/bloc/auth_cubit.dart';
import 'package:resellio/features/auth/bloc/auth_state.dart';
import 'package:resellio/features/common/data/api_endpoints.dart';
import 'package:resellio/features/common/style/app_colors.dart';
import 'package:resellio/features/common/widgets/app_logo.dart';
import 'package:resellio/features/organizer/verification/views/widgets.dart';

class OrganizerUnverifiedScreen extends StatefulWidget {
  const OrganizerUnverifiedScreen({super.key});

  @override
  State<OrganizerUnverifiedScreen> createState() =>
      _OrganizerUnverifiedScreenState();
}

class _OrganizerUnverifiedScreenState extends State<OrganizerUnverifiedScreen> {
  final _emailController = TextEditingController();
  final _nameController = TextEditingController();
  final _surnameController = TextEditingController();
  final _displayNameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final user =
        (context.read<AuthCubit>().state as AuthorizedUnverifiedOrganizer).user;
    _emailController.text = user.email;
    _nameController.text = user.firstName;
    _surnameController.text = user.lastName;
    _displayNameController.text = user.displayName;

    return Scaffold(
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
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 32),
                        const ResellioLogo(size: 120),
                        const SizedBox(height: 32),
                        const Text(
                          'Status',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                        const Text(
                          'W trakcie weryfikacji',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 32),
                        const Text(
                          'Twoje dane są weryfikowane przez administratora.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                        const SizedBox(height: 32),
                        ResellioTextField(
                          'Email',
                          controller: _emailController,
                          readOnly: true,
                        ),
                        const SizedBox(height: 16),
                        ResellioTextField(
                          'Imię',
                          controller: _nameController,
                          readOnly: true,
                        ),
                        const SizedBox(height: 16),
                        ResellioTextField(
                          'Nazwisko',
                          controller: _surnameController,
                          readOnly: true,
                        ),
                        const SizedBox(height: 16),
                        ResellioTextField(
                          'Nazwa firmy',
                          controller: _displayNameController,
                          readOnly: true,
                        ),
                        const SizedBox(height: 32),
                        ElevatedButton(
                          onPressed: () => context.read<AuthCubit>().logout(),
                          style: ElevatedButton.styleFrom(
                            foregroundColor: AppColors.primaryDark,
                          ),
                          child: const Text('Wyloguj się'),
                        ),
                        ElevatedButton(
                          // FIXME: temporary button to verify organizer
                          onPressed: () async {
                            print((context.read<AuthCubit>().state
                                    as AuthorizedUnverifiedOrganizer)
                                .user);
                            final email = (context.read<AuthCubit>().state
                                    as AuthorizedUnverifiedOrganizer)
                                .user
                                .email;

                            final response = await http.post(
                              Uri.parse(
                                  '${ApiEndpoints.baseUrl}/${ApiEndpoints.organizerVerify}'),
                              headers: {
                                'Content-Type': 'application/json',
                              },
                              body: jsonEncode({
                                'email': email,
                              }),
                            );

                            if (response.statusCode != 200) {
                              print(
                                  'Failed to verify organizer (${response.body})');
                            }

                            print(response.body);
                          },
                          child: const Text('Verify organizer'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
