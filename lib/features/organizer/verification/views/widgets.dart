import 'package:flutter/material.dart';
import 'package:resellio/features/common/style/app_colors.dart';

OutlineInputBorder buildBorder(Color color, {double width = 1.0}) {
  return OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
    borderSide: BorderSide(color: color, width: width),
  );
}

class ResellioTextField extends StatelessWidget {
  const ResellioTextField(
    this.label, {
    required this.controller,
    this.validator,
    this.icon,
    this.readOnly,
    super.key,
  });

  final String label;
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final IconData? icon;
  final bool? readOnly;

  @override
  Widget build(BuildContext context) {
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
      readOnly: readOnly ?? false,
    );
  }
}
