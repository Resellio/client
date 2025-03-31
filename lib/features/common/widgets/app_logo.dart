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
