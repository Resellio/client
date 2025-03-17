import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:resellio/features/auth/bloc/auth_cubit.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  void _showLoginBottomSheet(
    BuildContext context, {
    required String title,
    required IconData icon,
    required void Function() onSignInWithGoogle,
  }) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          minChildSize: 0.4,
          maxChildSize: 0.8,
          expand: false,
          builder: (context, scrollController) {
            return LoginBottomSheet(
              title: title,
              icon: icon,
              onSignInWithGoogle: onSignInWithGoogle,
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1E88E5), // A rich blue
              Color(0xFF0D47A1), // A deeper blue
            ],
          ),
        ),
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
                    ClipRRect(
                      borderRadius: BorderRadius.circular(30),
                      child: Image.asset(
                        'assets/icon/icon.png',
                        width: 120,
                        height: 120,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Resellio',
                      style: TextStyle(
                        fontSize: 42,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 1.2,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: const Text(
                        'Kupuj i sprzedawaj bilety na wydarzenia',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    const Spacer(),
                    _buildLogInAsButton(
                      context,
                      title: 'Chcę kupować bilety',
                      icon: Icons.person,
                      color: const Color(0xFF1E88E5),
                      backgroundColor: Colors.white,
                      onPressed: () => {
                        _showLoginBottomSheet(
                          context,
                          title: 'Zaloguj/zarejestruj się jako kupujący',
                          icon: Icons.person,
                          onSignInWithGoogle: () {
                            context
                                .read<AuthCubit>()
                                .customerSignInWithGoogle();
                          },
                        ),
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildLogInAsButton(
                      context,
                      title: 'Chcę sprzedawać bilety',
                      icon: Icons.business,
                      color: Colors.white,
                      backgroundColor: Colors.transparent,
                      onPressed: () => {
                        _showLoginBottomSheet(
                          context,
                          title: 'Zaloguj/zarejestruj się jako sprzedawca',
                          icon: Icons.business,
                          onSignInWithGoogle: () {
                            context
                                .read<AuthCubit>()
                                .organizerSignInWithGoogle();
                          },
                        ),
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogInAsButton(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required Color backgroundColor,
    required void Function() onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          foregroundColor: color,
          backgroundColor: backgroundColor,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: const BorderSide(color: Colors.white, width: 2),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: color,
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SignInWithGoogleButton extends StatelessWidget {
  const SignInWithGoogleButton({
    super.key,
    required this.onTap,
  });

  final void Function() onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton.icon(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.black87,
          backgroundColor: Colors.white,
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        icon: Padding(
          padding: const EdgeInsets.only(right: 12),
          child: Image.asset(
            'assets/icon/google.png',
            width: 24,
            height: 24,
          ),
        ),
        label: const Text(
          'Zaloguj się przez Google',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class LoginBottomSheet extends StatelessWidget {
  const LoginBottomSheet({
    super.key,
    required this.title,
    required this.icon,
    required this.onSignInWithGoogle,
  });

  final String title;
  final IconData icon;
  final void Function() onSignInWithGoogle;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          _buildDragHandle(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: Column(
              children: [
                Icon(icon, size: 64, color: const Color(0xFF1E88E5)),
                const SizedBox(height: 16),
                Text(
                  title,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                SignInWithGoogleButton(
                  onTap: onSignInWithGoogle,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDragHandle() {
    return Container(
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}
