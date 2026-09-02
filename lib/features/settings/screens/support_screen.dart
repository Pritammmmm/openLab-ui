import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/config/app_config.dart';
import '../../../core/config/app_theme.dart';

class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});

  static const _supportEmail = 'support@wiseblood.app';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Customer Support',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
        children: [
          // Header illustration — Airbnb style
          Container(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(28),
                  child: Image.asset(
                    'assets/3d_isometric/head_set_for_customarcare_support_static.png',
                    width: 140,
                    height: 140,
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'How can we help?',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'We\'re here to help you with any questions\nor issues you may have.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    color: AppColors.textMuted,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Contact options
          _SupportCard(
            icon: Icons.email_outlined,
            title: 'Email Support',
            subtitle: _supportEmail,
            trailing: Icons.copy_rounded,
            onTap: () async {
              final uri = Uri(
                scheme: 'mailto',
                path: _supportEmail,
                queryParameters: {
                  'subject': '${AppConfig.appName} Support Request',
                },
              );
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri);
              } else {
                await Clipboard.setData(
                    const ClipboardData(text: _supportEmail));
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Email copied to clipboard'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              }
            },
          ),
          const SizedBox(height: 12),

          _SupportCard(
            icon: Icons.bug_report_outlined,
            title: 'Report a Bug',
            subtitle: 'Help us improve by reporting issues',
            onTap: () async {
              final uri = Uri(
                scheme: 'mailto',
                path: _supportEmail,
                queryParameters: {
                  'subject': '${AppConfig.appName} Bug Report',
                  'body':
                      'Please describe the issue:\n\n\nSteps to reproduce:\n1. \n2. \n3. \n\nDevice info:\n',
                },
              );
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri);
              } else {
                await Clipboard.setData(
                    const ClipboardData(text: _supportEmail));
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Email copied to clipboard'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              }
            },
          ),
          const SizedBox(height: 12),

          _SupportCard(
            icon: Icons.chat_outlined,
            title: 'Feature Request',
            subtitle: 'Suggest new features or improvements',
            onTap: () async {
              final uri = Uri(
                scheme: 'mailto',
                path: _supportEmail,
                queryParameters: {
                  'subject': '${AppConfig.appName} Feature Request',
                  'body':
                      'I\'d like to suggest:\n\n\nWhy this would be useful:\n\n',
                },
              );
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri);
              } else {
                await Clipboard.setData(
                    const ClipboardData(text: _supportEmail));
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Email copied to clipboard'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              }
            },
          ),
          const SizedBox(height: 24),

          // FAQ section
          const Padding(
            padding: EdgeInsets.only(left: 4, bottom: 12),
            child: Text(
              'Frequently Asked Questions',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),

          _FaqCard(
            question: 'How does WiseBlood analyze my reports?',
            answer:
                'WiseBlood uses AI to extract and analyze blood test parameters '
                'from your uploaded reports. It identifies values, compares them '
                'with standard ranges, and provides a simple health overview.',
          ),
          const SizedBox(height: 8),

          _FaqCard(
            question: 'Is my health data secure?',
            answer:
                'Yes. Your reports and health data are encrypted and stored securely. '
                'We never share your personal health information with third parties. '
                'You can delete all your data at any time from Settings.',
          ),
          const SizedBox(height: 8),

          _FaqCard(
            question: 'Can I track multiple family members?',
            answer:
                'Yes! With our Plus plan you can manage up to 2 profiles, '
                'and with the Family plan you can manage up to 6 profiles '
                'to track the health of your entire family.',
          ),
          const SizedBox(height: 8),

          _FaqCard(
            question: 'What report formats are supported?',
            answer:
                'WiseBlood supports PDF and image formats (JPG, PNG) of blood test '
                'reports. For best results, ensure the report is clearly visible '
                'and not blurry.',
          ),
          const SizedBox(height: 8),

          _FaqCard(
            question: 'Is this a substitute for medical advice?',
            answer:
                'No. WiseBlood provides health information for educational purposes '
                'only. Always consult your doctor or qualified healthcare provider '
                'for medical advice, diagnosis, or treatment.',
          ),
          const SizedBox(height: 24),

          // Response time note
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.1),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.schedule_rounded,
                    size: 20,
                    color: AppColors.primary.withValues(alpha: 0.7)),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'We typically respond within 24 hours.',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SupportCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final IconData? trailing;
  final VoidCallback onTap;

  const _SupportCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.trailing,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(16),
      elevation: 1,
      shadowColor: Colors.black.withValues(alpha: 0.08),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 22, color: AppColors.primary),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                trailing ?? Icons.chevron_right_rounded,
                size: 20,
                color: AppColors.textMuted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FaqCard extends StatefulWidget {
  final String question;
  final String answer;

  const _FaqCard({required this.question, required this.answer});

  @override
  State<_FaqCard> createState() => _FaqCardState();
}

class _FaqCardState extends State<_FaqCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(14),
      elevation: 0.5,
      shadowColor: Colors.black.withValues(alpha: 0.06),
      child: InkWell(
        onTap: () => setState(() => _expanded = !_expanded),
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.question,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  AnimatedRotation(
                    turns: _expanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: 22,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
              AnimatedCrossFade(
                firstChild: const SizedBox.shrink(),
                secondChild: Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Text(
                    widget.answer,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                  ),
                ),
                crossFadeState: _expanded
                    ? CrossFadeState.showSecond
                    : CrossFadeState.showFirst,
                duration: const Duration(milliseconds: 200),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
