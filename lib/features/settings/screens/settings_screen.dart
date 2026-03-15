import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/config/app_config.dart';
import '../../../core/config/app_theme.dart';
import '../../../core/utils/helpers.dart';
import '../../auth/providers/auth_provider.dart';
import '../../home/providers/home_provider.dart';
import '../../profile/providers/profile_provider.dart' show maxProfilesForPlan;

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.go('/'),
        ),
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Profile card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                    backgroundImage: user?.photoUrl != null
                        ? NetworkImage(user!.photoUrl!)
                        : null,
                    child: user?.photoUrl == null
                        ? Text(
                            user?.name.isNotEmpty == true
                                ? user!.name[0].toUpperCase()
                                : '?',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user?.name ?? 'User',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          user?.email ?? '',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        if (user?.subscription.isPremium == true) ...[
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.yellowBg,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'Premium',
                              style: TextStyle(
                                color: AppColors.yellow,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Settings groups
          _SettingsGroup(
            children: [
              _SettingsTile(
                icon: Icons.family_restroom_rounded,
                title: 'Manage Family Profiles',
                onTap: () => context.push('/settings/profiles'),
              ),
              _SettingsTile(
                icon: Icons.language_rounded,
                title: 'Language',
                trailing: Text(
                  'English',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content:
                            Text('More languages coming soon!')),
                  );
                },
              ),
              _SettingsTile(
                icon: Icons.notifications_outlined,
                title: 'Notifications',
                trailing: Switch(
                  value: true,
                  activeTrackColor: AppColors.primary,
                  onChanged: (_) {},
                ),
                onTap: () {},
              ),
            ],
          ),
          const SizedBox(height: 16),

          _SettingsGroup(
            children: [
              _SettingsTile(
                icon: Icons.privacy_tip_outlined,
                title: 'Privacy Policy',
                onTap: () {},
              ),
              _SettingsTile(
                icon: Icons.description_outlined,
                title: 'Terms of Service',
                onTap: () {},
              ),
              _SettingsTile(
                icon: Icons.medical_information_outlined,
                title: 'Medical Disclaimer',
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Medical Disclaimer'),
                      content: const Text(
                        'WiseBlood provides health information for educational purposes only. '
                        'It is not a substitute for professional medical advice, diagnosis, or treatment. '
                        'Always seek the advice of your physician or other qualified health provider '
                        'with any questions you may have regarding a medical condition.',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: const Text('OK'),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 16),

          _SettingsGroup(
            children: [
              _SettingsTile(
                icon: Icons.delete_outline_rounded,
                title: 'Delete My Data',
                titleColor: AppColors.red,
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Delete All Data'),
                      content: const Text(
                        'This will permanently delete your account, all profiles, and all reports. '
                        'This action cannot be undone.',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(ctx);
                            // TODO: Implement data deletion API
                          },
                          child: const Text('Delete',
                              style: TextStyle(color: AppColors.red)),
                        ),
                      ],
                    ),
                  );
                },
              ),
              _SettingsTile(
                icon: Icons.logout_rounded,
                title: 'Log Out',
                titleColor: AppColors.red,
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Log Out'),
                      content:
                          const Text('Are you sure you want to log out?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(ctx);
                            ref
                                .read(authNotifierProvider.notifier)
                                .logout();
                          },
                          child: const Text('Log Out',
                              style: TextStyle(color: AppColors.red)),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 24),

          // App version
          Center(
            child: Text(
              '${AppConfig.appName} v1.0.0',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textMuted,
                  ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

/// Drawer version of settings — opened from profile picture on home screen.
class SettingsDrawer extends ConsumerWidget {
  const SettingsDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final selectedProfile = ref.watch(selectedProfileProvider);
    final profiles = ref.watch(profilesProvider).valueOrNull ?? [];
    final profileCount = profiles.length;
    final maxAllowed = maxProfilesForPlan(user?.subscription.plan);

    return Drawer(
      backgroundColor: AppColors.background,
      child: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
            // User account card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 26,
                      backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                      backgroundImage: user?.photoUrl != null
                          ? NetworkImage(user!.photoUrl!)
                          : null,
                      child: user?.photoUrl == null
                          ? Text(
                              user?.name.isNotEmpty == true
                                  ? user!.name[0].toUpperCase()
                                  : '?',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary,
                              ),
                            )
                          : null,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user?.name ?? 'User',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            user?.email ?? '',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Active profile indicator
            if (selectedProfile != null &&
                selectedProfile.relation != 'self') ...[
              const SizedBox(height: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.15),
                  ),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 14,
                      backgroundColor:
                          AppColors.primary.withValues(alpha: 0.12),
                      child: Text(
                        selectedProfile.initials[0],
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Viewing ${selectedProfile.name}\'s data',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w500,
                            ),
                      ),
                    ),
                    Text(
                      selectedProfile.relation.capitalize(),
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: AppColors.textMuted,
                          ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 16),

            // Settings groups
            _SettingsGroup(
              children: [
                _SettingsTile(
                  icon: Icons.family_restroom_rounded,
                  title: 'Manage Profiles',
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '$profileCount/$maxAllowed',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.chevron_right_rounded,
                          color: AppColors.textMuted),
                    ],
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    GoRouter.of(context).push('/settings/profiles');
                  },
                ),
                _SettingsTile(
                  icon: Icons.star_rounded,
                  title: 'Premium Plans',
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (user?.subscription.isPremium == true)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.yellowBg,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            (user?.subscription.plan ?? 'plus').toUpperCase(),
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: AppColors.yellow,
                            ),
                          ),
                        )
                      else
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'FREE',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      const SizedBox(width: 4),
                      const Icon(Icons.chevron_right_rounded,
                          color: AppColors.textMuted),
                    ],
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    GoRouter.of(context).push('/pricing');
                  },
                ),
                _SettingsTile(
                  icon: Icons.language_rounded,
                  title: 'Language',
                  trailing: Text(
                    'English',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('More languages coming soon!')),
                    );
                  },
                ),
                _SettingsTile(
                  icon: Icons.notifications_outlined,
                  title: 'Notifications',
                  trailing: Switch(
                    value: true,
                    activeTrackColor: AppColors.primary,
                    onChanged: (_) {},
                  ),
                  onTap: () {},
                ),
              ],
            ),
            const SizedBox(height: 16),

            _SettingsGroup(
              children: [
                _SettingsTile(
                  icon: Icons.privacy_tip_outlined,
                  title: 'Privacy Policy',
                  onTap: () {},
                ),
                _SettingsTile(
                  icon: Icons.description_outlined,
                  title: 'Terms of Service',
                  onTap: () {},
                ),
                _SettingsTile(
                  icon: Icons.medical_information_outlined,
                  title: 'Medical Disclaimer',
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Medical Disclaimer'),
                        content: const Text(
                          'WiseBlood provides health information for educational purposes only. '
                          'It is not a substitute for professional medical advice, diagnosis, or treatment. '
                          'Always seek the advice of your physician or other qualified health provider '
                          'with any questions you may have regarding a medical condition.',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx),
                            child: const Text('OK'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),

            _SettingsGroup(
              children: [
                _SettingsTile(
                  icon: Icons.delete_outline_rounded,
                  title: 'Delete My Data',
                  titleColor: AppColors.red,
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Delete All Data'),
                        content: const Text(
                          'This will permanently delete your account, all profiles, and all reports. '
                          'This action cannot be undone.',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(ctx);
                            },
                            child: const Text('Delete',
                                style: TextStyle(color: AppColors.red)),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                _SettingsTile(
                  icon: Icons.logout_rounded,
                  title: 'Log Out',
                  titleColor: AppColors.red,
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Log Out'),
                        content: const Text('Are you sure you want to log out?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(ctx);
                              ref.read(authNotifierProvider.notifier).logout();
                            },
                            child: const Text('Log Out',
                                style: TextStyle(color: AppColors.red)),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Text(
                '${AppConfig.appName} v1.0.0',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textMuted,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsGroup extends StatelessWidget {
  final List<Widget> children;

  const _SettingsGroup({required this.children});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          for (int i = 0; i < children.length; i++) ...[
            children[i],
            if (i < children.length - 1)
              const Divider(height: 1, indent: 56),
          ],
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color? titleColor;
  final Widget? trailing;
  final VoidCallback onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    this.titleColor,
    this.trailing,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon,
          color: titleColor ?? AppColors.textSecondary, size: 22),
      title: Text(
        title,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: titleColor,
            ),
      ),
      trailing: trailing ??
          const Icon(Icons.chevron_right_rounded,
              color: AppColors.textMuted),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      minTileHeight: AppTheme.minTapTarget,
    );
  }
}
