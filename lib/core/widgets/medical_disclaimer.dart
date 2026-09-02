import 'package:flutter/material.dart';
import '../config/app_theme.dart';

class MedicalDisclaimer extends StatelessWidget {
  final bool compact;

  const MedicalDisclaimer({super.key, this.compact = false});

  static const _text =
      'This app requires a blood test report from a laboratory or '
      'healthcare provider. It does not perform blood tests or connect '
      'to any external device. This app is not a medical device and does '
      'not diagnose, treat, cure, or prevent any medical condition. '
      'Always consult a qualified healthcare professional for medical '
      'advice, diagnosis, or treatment.';

  @override
  Widget build(BuildContext context) {
    if (compact) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.info_outline_rounded,
              size: 14,
              color: AppColors.textMuted.withValues(alpha: 0.5),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                _text,
                style: TextStyle(
                  fontSize: 11,
                  color: AppColors.textMuted.withValues(alpha: 0.6),
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFFFFE082).withValues(alpha: 0.5),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.medical_information_rounded,
            size: 18,
            color: Color(0xFFF9A825),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              _text,
              style: TextStyle(
                fontSize: 12,
                color: Colors.brown.shade700,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
