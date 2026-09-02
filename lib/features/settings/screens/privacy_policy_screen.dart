import 'package:flutter/material.dart';
import '../../../core/config/app_config.dart';
import '../../../core/config/app_theme.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  static const _lastUpdated = 'March 20, 2026';
  static const _appName = AppConfig.appName;
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
          'Privacy Policy',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 60),
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(28),
                  child: Image.asset(
                    'assets/3d_isometric/privacy policy.png',
                    width: 140,
                    height: 140,
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  '$_appName Privacy Policy',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Last updated: $_lastUpdated',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Introduction
          _SectionCard(
            children: [
              const _SectionTitle('Introduction'),
              _bodyText(
                'Welcome to $_appName. We are committed to protecting your '
                'privacy and ensuring the security of your personal and health '
                'information. This Privacy Policy explains how we collect, use, '
                'store, and protect your data when you use the $_appName mobile '
                'application and related services.',
              ),
              const SizedBox(height: 12),
              _bodyText(
                'By using $_appName, you agree to the collection and use of '
                'information in accordance with this policy. If you do not agree '
                'with any part of this policy, please discontinue use of the '
                'application immediately.',
              ),
              const SizedBox(height: 12),
              _bodyText(
                '$_appName is designed to help you understand your blood test '
                'reports through AI-powered analysis. We take the responsibility '
                'of handling your health data very seriously and have implemented '
                'industry-standard security measures to protect it.',
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Information We Collect
          _SectionCard(
            children: [
              const _SectionTitle('Information We Collect'),
              const SizedBox(height: 4),
              const _SubSectionTitle('1. Account Information'),
              _bodyText(
                'When you create an account with $_appName, we collect the '
                'following personal information:',
              ),
              const SizedBox(height: 8),
              _bulletPoint('Full name as provided during profile setup'),
              _bulletPoint('Email address associated with your Google account'),
              _bulletPoint('Date of birth for age-related health reference ranges'),
              _bulletPoint('Gender for gender-specific health parameter analysis'),
              _bulletPoint('Profile photo (if provided through your Google account)'),
              const SizedBox(height: 16),
              const _SubSectionTitle('2. Health & Medical Data'),
              _bodyText(
                'To provide our core analysis service, we collect and process '
                'the following health-related data:',
              ),
              const SizedBox(height: 8),
              _bulletPoint(
                'Blood test reports uploaded by you in PDF or image format '
                '(JPG, PNG)',
              ),
              _bulletPoint(
                'Extracted blood test parameters including but not limited to: '
                'hemoglobin, blood sugar (glucose), cholesterol levels (HDL, LDL, '
                'total), triglycerides, thyroid markers (TSH, T3, T4), liver '
                'function markers (ALT, AST, bilirubin), kidney function markers '
                '(creatinine, BUN, uric acid), complete blood count (CBC) values, '
                'vitamin levels (B12, D, iron), and other standard blood parameters',
              ),
              _bulletPoint(
                'Health scores and analysis results generated from your reports',
              ),
              _bulletPoint(
                'Historical trend data compiled from multiple reports over time',
              ),
              _bulletPoint(
                'AI-generated health insights, advice, and parameter summaries',
              ),
              const SizedBox(height: 16),
              const _SubSectionTitle('3. Family Profile Data'),
              _bodyText(
                'If you use our family profiles feature (available with Plus '
                'and Family subscription plans), we additionally collect:',
              ),
              const SizedBox(height: 8),
              _bulletPoint('Full name of each family member'),
              _bulletPoint('Date of birth of each family member'),
              _bulletPoint('Gender of each family member'),
              _bulletPoint(
                'Relationship to the primary account holder (e.g., spouse, '
                'parent, child)',
              ),
              _bulletPoint(
                'Individual blood test reports and health data for each '
                'family member, stored separately under their respective profiles',
              ),
              const SizedBox(height: 16),
              const _SubSectionTitle('4. Subscription & Payment Data'),
              _bodyText(
                'When you subscribe to a paid plan, the following information '
                'is processed:',
              ),
              const SizedBox(height: 8),
              _bulletPoint(
                'Subscription plan type (Plus Monthly, Plus Annual, Family '
                'Monthly, Family Annual)',
              ),
              _bulletPoint('Subscription status (active, expired, cancelled)'),
              _bulletPoint('Purchase dates and renewal dates'),
              _bulletPoint(
                'Transaction identifiers for purchase verification purposes',
              ),
              _bodyText(
                '\nImportant: All payment processing is handled entirely by '
                'Google Play and RevenueCat. We do not collect, store, or have '
                'access to your credit card numbers, bank account details, or '
                'any other direct financial information.',
              ),
              const SizedBox(height: 16),
              const _SubSectionTitle('5. Device & Technical Data'),
              _bodyText(
                'To ensure the app functions correctly and to troubleshoot '
                'issues, we may collect:',
              ),
              const SizedBox(height: 8),
              _bulletPoint('Device type and model'),
              _bulletPoint('Operating system and version'),
              _bulletPoint('App version number'),
              _bulletPoint('General error logs and crash reports'),
              _bulletPoint(
                'Network connectivity status (to determine if the device '
                'is online or offline)',
              ),
            ],
          ),
          const SizedBox(height: 16),

          // How We Use Your Information
          _SectionCard(
            children: [
              const _SectionTitle('How We Use Your Information'),
              const SizedBox(height: 4),
              const _SubSectionTitle('Core Service Delivery'),
              _bulletPoint(
                'Analyze your uploaded blood test reports using AI-powered '
                'technology to extract parameters and provide health insights',
              ),
              _bulletPoint(
                'Generate personalized health scores based on your blood '
                'test results and standard medical reference ranges',
              ),
              _bulletPoint(
                'Display historical trends of your blood parameters across '
                'multiple reports to help you track your health over time',
              ),
              _bulletPoint(
                'Provide AI-generated health advice and recommendations '
                'based on your report findings',
              ),
              _bulletPoint(
                'Manage and display separate health profiles for your '
                'family members',
              ),
              const SizedBox(height: 16),
              const _SubSectionTitle('Account & Service Management'),
              _bulletPoint('Authenticate your identity and manage your account'),
              _bulletPoint(
                'Process and manage your subscription plan and associated '
                'entitlements',
              ),
              _bulletPoint(
                'Enforce fair usage limits to maintain service quality for '
                'all users',
              ),
              _bulletPoint('Respond to your customer support inquiries'),
              const SizedBox(height: 16),
              const _SubSectionTitle('Service Improvement'),
              _bulletPoint(
                'Identify and fix bugs, errors, and technical issues within '
                'the application',
              ),
              _bulletPoint(
                'Understand general usage patterns to improve the user '
                'experience and app performance',
              ),
              _bulletPoint(
                'Develop new features and enhance existing functionality '
                'based on aggregated, anonymized usage data',
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Third-Party Services
          _SectionCard(
            children: [
              const _SectionTitle('Third-Party Services'),
              _bodyText(
                '$_appName integrates with the following trusted third-party '
                'services to deliver its functionality. Each service has its '
                'own privacy policy governing their handling of data:',
              ),
              const SizedBox(height: 16),
              _serviceItem(
                'Google Firebase',
                'Used for secure user authentication via Google Sign-In. '
                'Firebase manages your login session, authentication tokens, '
                'and account security. Firebase does not access your health '
                'data or blood test reports.',
              ),
              const SizedBox(height: 12),
              _serviceItem(
                'RevenueCat',
                'Used for subscription and in-app purchase management. '
                'RevenueCat processes your subscription status and purchase '
                'verification. It receives a unique user identifier but does '
                'not have access to your health data, reports, or personal '
                'profile information.',
              ),
              const SizedBox(height: 12),
              _serviceItem(
                'Cloudinary',
                'Used for secure cloud storage of uploaded report files '
                '(PDFs and images). Files are stored with encrypted URLs and '
                'are accessible only through authenticated API requests from '
                'your account.',
              ),
              const SizedBox(height: 12),
              _serviceItem(
                'AI Analysis Service',
                'Used for extracting text and parameters from your uploaded '
                'blood test reports. Report data is sent to the AI service '
                'solely for the purpose of analysis. The AI service does not '
                'retain, store, or use your report data after processing is '
                'complete. No personal identifiers are sent to the AI service '
                '— only the report content.',
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Data Storage & Security
          _SectionCard(
            children: [
              const _SectionTitle('Data Storage & Security'),
              _bodyText(
                'We take the security of your personal and health information '
                'extremely seriously. The following measures are in place to '
                'protect your data:',
              ),
              const SizedBox(height: 16),
              const _SubSectionTitle('Encryption'),
              _bulletPoint(
                'All data transmitted between the app and our servers is '
                'encrypted using HTTPS/TLS (Transport Layer Security)',
              ),
              _bulletPoint(
                'Sensitive data stored on our servers is encrypted at rest '
                'using industry-standard encryption algorithms',
              ),
              _bulletPoint(
                'Authentication tokens are stored securely on your device '
                'using Flutter Secure Storage, which leverages the platform\'s '
                'native keychain (iOS) or keystore (Android)',
              ),
              const SizedBox(height: 16),
              const _SubSectionTitle('Authentication & Access Control'),
              _bulletPoint(
                'JWT (JSON Web Token) based authentication ensures that '
                'only you can access your account and data',
              ),
              _bulletPoint(
                'Access tokens expire after 15 minutes and are automatically '
                'refreshed using secure refresh tokens',
              ),
              _bulletPoint(
                'Refresh tokens expire after 7 days, requiring periodic '
                're-authentication for continued security',
              ),
              _bulletPoint(
                'Each API request is authenticated and authorized to ensure '
                'users can only access their own data',
              ),
              const SizedBox(height: 16),
              const _SubSectionTitle('Infrastructure'),
              _bulletPoint(
                'Our servers are hosted on secure, industry-standard cloud '
                'infrastructure with regular security updates and monitoring',
              ),
              _bulletPoint(
                'Database access is restricted to authorized services only '
                'and protected by network-level security rules',
              ),
              _bulletPoint(
                'We conduct regular security reviews to identify and address '
                'potential vulnerabilities',
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Data Sharing
          _SectionCard(
            children: [
              const _SectionTitle('Data Sharing & Disclosure'),
              _bodyText(
                'We value your privacy and are committed to keeping your '
                'data confidential. Here is our data sharing policy:',
              ),
              const SizedBox(height: 16),
              const _SubSectionTitle('We Do NOT'),
              _bulletCross(
                'Sell your personal or health data to any third party, '
                'under any circumstances',
              ),
              _bulletCross(
                'Share your blood test results, health scores, or medical '
                'data with advertisers, data brokers, or marketing companies',
              ),
              _bulletCross(
                'Use your health data for targeted advertising or '
                'behavioral profiling',
              ),
              _bulletCross(
                'Provide your data to insurance companies, employers, or '
                'any other entities that could use it against your interests',
              ),
              _bulletCross(
                'Allow third-party services to access your health data '
                'beyond what is strictly necessary for the app\'s core '
                'functionality',
              ),
              const SizedBox(height: 16),
              const _SubSectionTitle('Limited Sharing'),
              _bodyText(
                'We may share limited, non-health data only in the following '
                'circumstances:',
              ),
              const SizedBox(height: 8),
              _bulletPoint(
                'With third-party service providers listed above, solely '
                'for the purpose of operating the app (authentication, '
                'payment processing, file storage, report analysis)',
              ),
              _bulletPoint(
                'When required by law, such as in response to a valid court '
                'order, subpoena, or government request',
              ),
              _bulletPoint(
                'To protect the rights, safety, or property of $_appName, '
                'our users, or the public, as permitted by law',
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Data Retention
          _SectionCard(
            children: [
              const _SectionTitle('Data Retention'),
              _bodyText(
                'We retain your data only for as long as necessary to '
                'provide our services to you:',
              ),
              const SizedBox(height: 12),
              _bulletPoint(
                'Your account data and health information are retained for '
                'as long as your account remains active',
              ),
              _bulletPoint(
                'When you delete a report, it is permanently removed from '
                'our servers and cloud storage within 30 days',
              ),
              _bulletPoint(
                'When you delete a family member profile, all associated '
                'reports and health data for that profile are permanently '
                'deleted',
              ),
              _bulletPoint(
                'When you delete your account, all your data — including '
                'all profiles, reports, health scores, trend data, and '
                'personal information — is permanently removed from our '
                'servers within 30 days',
              ),
              _bulletPoint(
                'Anonymized, aggregated statistical data that cannot be '
                'used to identify any individual may be retained for service '
                'improvement purposes',
              ),
              _bulletPoint(
                'Backup copies may persist in encrypted backups for up to '
                '90 days before being automatically purged',
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Your Rights
          _SectionCard(
            children: [
              const _SectionTitle('Your Rights & Controls'),
              _bodyText(
                'You have full control over your data. The following rights '
                'and controls are available to you at any time:',
              ),
              const SizedBox(height: 16),
              const _SubSectionTitle('Data Access & Portability'),
              _bulletPoint(
                'View all your stored reports, health scores, and trend '
                'data directly within the app at any time',
              ),
              _bulletPoint(
                'Request a complete copy of all your data by contacting '
                'us at $_supportEmail',
              ),
              const SizedBox(height: 16),
              const _SubSectionTitle('Data Deletion'),
              _bulletPoint(
                'Delete individual blood test reports from the History '
                'screen at any time',
              ),
              _bulletPoint(
                'Delete individual family member profiles and all their '
                'associated data from the Family Profiles screen',
              ),
              _bulletPoint(
                'Delete your entire account and all associated data from '
                'the Settings screen',
              ),
              const SizedBox(height: 16),
              const _SubSectionTitle('Subscription Management'),
              _bulletPoint(
                'Cancel your subscription at any time through Google Play '
                'Store settings',
              ),
              _bulletPoint(
                'Downgrade or change your plan at any time — your existing '
                'data remains accessible',
              ),
              const SizedBox(height: 16),
              const _SubSectionTitle('Communication'),
              _bulletPoint(
                'Contact our support team at $_supportEmail for any '
                'privacy-related questions, concerns, or requests',
              ),
              _bulletPoint(
                'Request clarification on how your data is being used or '
                'processed',
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Children's Privacy
          _SectionCard(
            children: [
              const _SectionTitle('Children\'s Privacy'),
              _bodyText(
                '$_appName is not intended for use by children under the age '
                'of 13. We do not knowingly collect personal information from '
                'children under 13 years of age.',
              ),
              const SizedBox(height: 12),
              _bodyText(
                'The family profiles feature allows parents and guardians to '
                'manage health data for their children. In such cases, the '
                'parent or guardian is responsible for managing the child\'s '
                'data and must have the legal authority to consent on behalf '
                'of the child.',
              ),
              const SizedBox(height: 12),
              _bodyText(
                'If we become aware that we have collected personal information '
                'from a child under 13 without parental consent, we will take '
                'immediate steps to delete that information from our servers.',
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Medical Disclaimer
          _SectionCard(
            highlight: true,
            children: [
              const _SectionTitle('Medical Disclaimer'),
              _bodyText(
                '$_appName requires a blood test report from a laboratory or '
                'healthcare provider. It does not perform blood tests, connect '
                'to any external hardware device, or function as a medical device. '
                '$_appName is not a medical device and does not diagnose, treat, '
                'cure, or prevent any medical condition.',
              ),
              const SizedBox(height: 12),
              _bodyText(
                '$_appName provides health information for educational and '
                'informational purposes only. The analysis, health scores, '
                'insights, and advice provided by the app are generated by '
                'artificial intelligence and are NOT intended to:',
              ),
              const SizedBox(height: 12),
              _bulletCross('Replace professional medical advice or consultation'),
              _bulletCross('Serve as a medical diagnosis of any condition'),
              _bulletCross(
                'Be used as a basis for starting, stopping, or modifying '
                'any medication or treatment',
              ),
              _bulletCross(
                'Substitute for regular health check-ups and consultations '
                'with qualified healthcare providers',
              ),
              const SizedBox(height: 12),
              _bodyText(
                'Always consult your doctor or a qualified healthcare '
                'professional for medical advice, diagnosis, or treatment. '
                'If you are experiencing a medical emergency, contact your '
                'local emergency services immediately.',
              ),
              const SizedBox(height: 12),
              _bodyText(
                '$_appName, its developers, and its affiliates shall not be '
                'held liable for any health decisions made based on the '
                'information provided by the application. The accuracy of '
                'AI-generated analysis may vary, and results should always '
                'be verified by a qualified medical professional.',
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Cookies & Tracking
          _SectionCard(
            children: [
              const _SectionTitle('Cookies & Tracking'),
              _bodyText(
                '$_appName is a mobile application and does not use browser '
                'cookies. We do not engage in cross-app tracking or behavioral '
                'advertising.',
              ),
              const SizedBox(height: 12),
              _bodyText(
                'We do not use any analytics SDKs that track your behavior '
                'across other applications. The only data we collect is '
                'directly related to your use of the $_appName application '
                'as described in this policy.',
              ),
            ],
          ),
          const SizedBox(height: 16),

          // International Data Transfers
          _SectionCard(
            children: [
              const _SectionTitle('International Data Transfers'),
              _bodyText(
                'Your data may be stored and processed on servers located '
                'in different countries. By using $_appName, you consent to '
                'the transfer of your information to facilities outside your '
                'country of residence, where data protection laws may differ.',
              ),
              const SizedBox(height: 12),
              _bodyText(
                'We ensure that any international data transfers comply with '
                'applicable data protection regulations and that appropriate '
                'safeguards are in place to protect your information regardless '
                'of where it is processed.',
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Changes to This Policy
          _SectionCard(
            children: [
              const _SectionTitle('Changes to This Policy'),
              _bodyText(
                'We may update this Privacy Policy from time to time to '
                'reflect changes in our practices, technology, legal '
                'requirements, or other factors. When we make changes:',
              ),
              const SizedBox(height: 12),
              _bulletPoint(
                'The "Last Updated" date at the top of this policy will '
                'be revised to reflect the most recent update',
              ),
              _bulletPoint(
                'For significant changes that materially affect your rights '
                'or how your data is handled, we will notify you through an '
                'in-app notification or via the email address associated with '
                'your account',
              ),
              _bulletPoint(
                'Continued use of $_appName after changes are posted '
                'constitutes acceptance of the revised policy',
              ),
              const SizedBox(height: 12),
              _bodyText(
                'We encourage you to review this Privacy Policy periodically '
                'to stay informed about how we are protecting your data.',
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Contact Us
          _SectionCard(
            children: [
              const _SectionTitle('Contact Us'),
              _bodyText(
                'If you have any questions, concerns, or requests regarding '
                'this Privacy Policy or our data practices, please do not '
                'hesitate to contact us:',
              ),
              const SizedBox(height: 16),
              _contactRow(Icons.email_outlined, 'Email', _supportEmail),
              const SizedBox(height: 10),
              _contactRow(Icons.language_rounded, 'Website', 'wiseblood.app'),
              const SizedBox(height: 16),
              _bodyText(
                'We aim to respond to all privacy-related inquiries within '
                '48 hours of receipt.',
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Footer
          Center(
            child: Text(
              '$_appName v${AppConfig.appName} · $_lastUpdated',
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textMuted,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Reusable content builders ──────────────────────────────────────

  static Widget _bodyText(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 14,
        color: AppColors.textSecondary,
        height: 1.6,
      ),
    );
  }

  static Widget _bulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 6),
            child: Icon(Icons.circle, size: 5, color: AppColors.textMuted),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
                height: 1.55,
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Widget _bulletCross(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 1),
            child:
                Icon(Icons.close_rounded, size: 16, color: AppColors.red),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
                height: 1.55,
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Widget _serviceItem(String name, String description) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(
            Icons.verified_outlined,
            size: 18,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  static Widget _contactRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 18, color: AppColors.primary),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textMuted,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ─── Section Card ─────────────────────────────────────────────────────
class _SectionCard extends StatelessWidget {
  final List<Widget> children;
  final bool highlight;

  const _SectionCard({required this.children, this.highlight = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: highlight
            ? AppColors.yellowBg.withValues(alpha: 0.5)
            : AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: highlight
              ? AppColors.yellow.withValues(alpha: 0.2)
              : Colors.black.withValues(alpha: 0.06),
        ),
        boxShadow: highlight
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 12,
                  offset: const Offset(0, 3),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }
}

// ─── Section Title ────────────────────────────────────────────────────
class _SectionTitle extends StatelessWidget {
  final String text;

  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
          letterSpacing: -0.2,
        ),
      ),
    );
  }
}

// ─── Sub-Section Title ────────────────────────────────────────────────
class _SubSectionTitle extends StatelessWidget {
  final String text;

  const _SubSectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}
