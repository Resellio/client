import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Resellio',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Buy & Resell Your Tickets',
              style: TextStyle(
                fontSize: 18,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => CustomerLoginScreen()),
                );
              },
              child: const Text('Continue as Customer'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => OrganizerLoginScreen()),
                );
              },
              child: const Text('Continue as Organizer'),
            ),
          ],
        ),
      ),
    );
  }
}

class CustomerLoginScreen extends StatelessWidget {
  const CustomerLoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Customer Login')),
      body: const Center(
        child: Text('Customer Login Screen - Add login/register options here'),
      ),
    );
  }
}

// Placeholder for Organizer Login Screen
class OrganizerLoginScreen extends StatelessWidget {
  const OrganizerLoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Organizer Login')),
      body: const Center(
        child: Text('Organizer Login Screen - Add login/register options here'),
      ),
    );
  }
}

class SignInWithGoogleButton extends StatelessWidget {
  const SignInWithGoogleButton({super.key});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () {
        // Add Google sign-in logic here when implementing login screens
      },
      icon: Image.asset('assets/icon/google.png'), // Ensure this asset exists
      label: const Text(
        'Sign in with Google',
        style: TextStyle(
          color: Colors.black,
          height: 1.5,
        ),
      ),
    );
  }
}

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => {
                context.go('/'),
              },
              child: const Text('Login as Customer'),
            ),
            ElevatedButton(
              onPressed: () => {
                context.go('/'),
              },
              child: const Text('Login as Organizer'),
            ),
          ],
        ),
      ),
    );
  }
}
