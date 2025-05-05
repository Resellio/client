import 'package:flutter/material.dart';
import 'package:resellio/features/common/widgets/app_logo.dart';

class OrganizerHomeScreen extends StatelessWidget {
  const OrganizerHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ResellioLogo(
              size: 100,
              withBorder: true,
            ),
            SizedBox(height: 32),
            Text('Jesteś zalogowany jako organizator'),
          ],
        ),
      ),
    );
  }
}
