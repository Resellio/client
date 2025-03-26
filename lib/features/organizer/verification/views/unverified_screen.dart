import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:resellio/features/auth/bloc/auth_cubit.dart';
import 'package:resellio/features/auth/bloc/auth_state.dart';

class OrganizerUnverifiedScreen extends StatelessWidget {
  const OrganizerUnverifiedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            const Text('Pending Organizer Registration'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                context.read<AuthCubit>().logout();
              },
              child: const Text('Logout'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              // temporary button to verify organizer
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
                      'http://localhost:5124/api/organizer/verify-organizer'),
                  headers: {
                    'Content-Type': 'application/json',
                  },
                  body: jsonEncode({
                    'email': email,
                  }),
                );

                if (response.statusCode != 200) {
                  print('Failed to verify organizer (${response.body})');
                }

                print(response.body);
              },
              child: const Text('Verify organizer'),
            ),
          ],
        ),
      ),
    );
  }
}
