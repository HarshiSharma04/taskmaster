import 'package:flutter/material.dart';
import '../config/app_config.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? hint;
  final bool obscureText;
  final TextInputType keyboardType;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;
  final void Function(String)? onFieldSubmitted;
  final int? maxLines;
  final int? minLines;
  final bool enabled;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.label,
    this.hint,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.prefixIcon,
    this.suffixIcon,
    this.validator,
    this.onFieldSubmitted,
    this.maxLines = 1,
    this.minLines,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: maxLines != null && maxLines! > 1
          ? TextInputType.multiline
          : keyboardType,
      maxLines: obscureText ? 1 : maxLines,
      minLines: minLines,
      enabled: enabled,
      style: AppTextStyles.bodyLarge.copyWith(fontSize: 15),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: prefixIcon != null
            ? Icon(prefixIcon, color: const Color(0x663D3530), size: 20)
            : null,
        suffixIcon: suffixIcon,
      ),
      validator: validator,
      onFieldSubmitted: onFieldSubmitted,
    );
  }
}