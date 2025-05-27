import 'package:flutter/material.dart';

class ResellioLogo extends StatelessWidget {
  const ResellioLogo({
    required this.size,
    this.withBorder = false,
    super.key,
  });

  final double size;
  final bool withBorder;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: withBorder
          ? BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: Theme.of(context).primaryColorDark,
                width: 2,
              ),
            )
          : null,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: Image.asset(
          'assets/icon/icon.png',
          width: size,
          height: size,
        ),
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
