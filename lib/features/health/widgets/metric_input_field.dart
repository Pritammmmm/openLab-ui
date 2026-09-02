import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/config/app_theme.dart';

class MetricInputField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String unit;
  final String? hint;
  final bool autofocus;

  const MetricInputField({
    super.key,
    required this.controller,
    required this.label,
    required this.unit,
    this.hint,
    this.autofocus = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          autofocus: autofocus,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
          ],
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
          decoration: InputDecoration(
            hintText: hint ?? '0',
            hintStyle: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: AppColors.textMuted.withValues(alpha: 0.4),
            ),
            suffixText: unit,
            suffixStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppColors.textMuted,
            ),
            filled: true,
            fillColor: AppColors.background,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
        ),
      ],
    );
  }
}
