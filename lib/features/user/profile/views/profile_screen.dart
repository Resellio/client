import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:resellio/features/auth/bloc/auth_cubit.dart';
import 'package:resellio/features/user/profile/bloc/profile_cubit.dart';
import 'package:resellio/features/user/profile/bloc/profile_state.dart';

class CustomerProfileScreen extends StatelessWidget {
  const CustomerProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          CustomerProfileCubit(context.read(), context.read<AuthCubit>())
            ..fetchAboutMe(),
      child: Scaffold(
        appBar: AppBar(title: const Text('Profil użytkownika')),
        body: BlocBuilder<CustomerProfileCubit, CustomerProfileState>(
          builder: (context, state) {
            if (state.status == CustomerProfileStatus.loading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state.status == CustomerProfileStatus.failure) {
              return Center(child: Text('Błąd: ${state.errorMessage}'));
            }

            if (state.aboutMe == null) {
              return const Center(child: Text('Brak danych użytkownika.'));
            }

            final aboutMe = state.aboutMe!;
            final formattedDate =
                DateFormat('yyyy-MM-dd – kk:mm').format(aboutMe.creationDate);

            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          _profileRow(Icons.person, 'Imię', aboutMe.firstName),
                          _profileRow(
                            Icons.person_outline,
                            'Nazwisko',
                            aboutMe.lastName,
                          ),
                          _profileRow(Icons.email, 'Email', aboutMe.email),
                          _profileRow(
                            Icons.calendar_today,
                            'Utworzono',
                            formattedDate,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Spacer(),
                  Center(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        context.read<AuthCubit>().logout();
                      },
                      icon: const Icon(Icons.logout),
                      label: const Text('Wyloguj'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _profileRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[700]),
          const SizedBox(width: 12),
          Text('$label:', style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}
