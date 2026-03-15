import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/config/app_theme.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/isometric_icon.dart';

class EmptyState extends StatelessWidget {
  const EmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const IsometricIcon(
            icon: Icons.biotech_rounded,
            size: 100,
            color: AppColors.primary,
          ),
          const SizedBox(height: 24),
          Text(
            'Upload Your First Report',
            style: Theme.of(context).textTheme.headlineMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            'Take a photo or pick a PDF of your blood test report — we\'ll explain everything in simple terms.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          AppButton(
            label: 'Upload Report',
            onPressed: () => context.push('/upload'),
            icon: Icons.add_a_photo_rounded,
          ),
        ],
      ),
    );
  }
}
