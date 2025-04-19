import 'package:flutter/material.dart';

class ResellioLogo extends StatelessWidget {
  const ResellioLogo({required this.size, super.key});

  final double size;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: Image.asset(
        'assets/icon/icon.png',
        width: size,
        height: size,
      ),
    );
  }
}

class ResellioLogoWithTitle extends StatelessWidget {
  const ResellioLogoWithTitle({required this.size, super.key});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: Image.asset(
            'assets/icon/icon.png',
            width: size,
            height: size,
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
      ],
    );
  }
}
