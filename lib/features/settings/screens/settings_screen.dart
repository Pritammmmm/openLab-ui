import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/config/app_config.dart';
import '../../../core/config/app_theme.dart';
import '../../../core/utils/helpers.dart';
import '../../auth/providers/auth_provider.dart';
import '../../home/providers/home_provider.dart';
import '../../subscription/models/subscription_plan.dart';
import '../../subscription/providers/subscription_provider.dart';
import '../../../core/widgets/premium_avatar.dart';

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
                  PremiumAvatar(
                    radius: 30,
                    photoUrl: user?.photoUrl,
                    fallbackText: user?.name.isNotEmpty == true
                        ? user!.name[0].toUpperCase()
                        : '?',
                    fallbackFontSize: 24,
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
                        if (ref.watch(activePlanProvider) != PlanTier.free) ...[
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.yellowBg,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              ref.watch(activePlanProvider).name.toUpperCase(),
                              style: const TextStyle(
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
                icon: Icons.support_agent_rounded,
                title: 'Customer Support',
                onTap: () => context.push('/support'),
              ),
              _SettingsTile(
                icon: Icons.privacy_tip_outlined,
                title: 'Privacy Policy',
                onTap: () => context.push('/privacy'),
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

/// Drawer version of settings — Apple Settings style with grouped lists.
class SettingsDrawer extends ConsumerStatefulWidget {
  const SettingsDrawer({super.key});

  @override
  ConsumerState<SettingsDrawer> createState() => _SettingsDrawerState();
}

class _SettingsDrawerState extends ConsumerState<SettingsDrawer>
    with SingleTickerProviderStateMixin {
  late AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final selectedProfile = ref.watch(selectedProfileProvider);
    final plan = ref.watch(activePlanProvider);
    final isFree = plan == PlanTier.free;

    return Drawer(
      width: MediaQuery.of(context).size.width,
      backgroundColor: const Color(0xFFF2F2F7),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 12),
          children: [
            // Profile card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFF7B52F5),
                            Color(0xFF5F33E1),
                          ],
                        ),
                      ),
                      alignment: Alignment.center,
                      child: user?.photoUrl != null
                          ? ClipOval(
                              child: Image.network(
                                user!.photoUrl!,
                                width: 60,
                                height: 60,
                                fit: BoxFit.cover,
                              ),
                            )
                          : Text(
                              user?.name.isNotEmpty == true
                                  ? user!.name[0].toUpperCase()
                                  : '?',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                letterSpacing: -0.5,
                              ),
                            ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user?.name ?? 'User',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1C1C1E),
                              letterSpacing: -0.4,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            user?.email ?? '',
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF8E8E93),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.chevron_right_rounded,
                      color: Color(0xFFC7C7CC),
                      size: 22,
                    ),
                  ],
                ),
              ),
            ),

            // Active profile indicator
            if (selectedProfile != null &&
                selectedProfile.relation != 'self') ...[
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 10),
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
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Text(
                        selectedProfile.relation.capitalize(),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],

            // Premium banner
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                  GoRouter.of(context).push('/pricing');
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 18, vertical: 16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF6B3FA0),
                        Color(0xFF4A1F8A),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Stack(
                    children: [
                      // Shimmer sweep
                      Positioned.fill(
                        child: AnimatedBuilder(
                          animation: _shimmerController,
                          builder: (context, _) {
                            return FractionallySizedBox(
                              widthFactor: 2.0,
                              alignment: Alignment(
                                -1.0 + 2.0 * _shimmerController.value,
                                0,
                              ),
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.transparent,
                                      Colors.white.withValues(alpha: 0.08),
                                      Colors.transparent,
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            alignment: Alignment.center,
                            child: const Icon(
                              Icons.star_rounded,
                              color: Colors.white,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  isFree
                                      ? 'Upgrade to Premium'
                                      : '${plan.name} Plan',
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                    letterSpacing: -0.2,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  isFree
                                      ? 'Unlock all health insights'
                                      : 'All features unlocked',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color:
                                        Colors.white.withValues(alpha: 0.7),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 5),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              isFree
                                  ? 'FREE'
                                  : plan.name.toUpperCase(),
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // General settings
            const SizedBox(height: 20),
            _DrawerGroup(
              children: [
                _DrawerItem(
                  icon: Icons.language_rounded,
                  iconColor: const Color(0xFF5B6EF5),
                  title: 'Language',
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Text(
                        'English',
                        style: TextStyle(
                            fontSize: 15, color: Color(0xFF8E8E93)),
                      ),
                      SizedBox(width: 6),
                      Icon(Icons.chevron_right_rounded,
                          color: Color(0xFFC7C7CC), size: 20),
                    ],
                  ),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('More languages coming soon!')),
                    );
                  },
                ),
                _DrawerItem(
                  icon: Icons.notifications_rounded,
                  iconColor: const Color(0xFF34C759),
                  title: 'Notifications',
                  trailing: SizedBox(
                    width: 51,
                    height: 31,
                    child: CupertinoSwitch(
                      value: true,
                      activeTrackColor: const Color(0xFF34C759),
                      onChanged: (_) {},
                    ),
                  ),
                ),
              ],
            ),

            // Support section
            const SizedBox(height: 20),
            _DrawerGroup(
              children: [
                _DrawerItem(
                  icon: Icons.support_agent_rounded,
                  iconColor: const Color(0xFFD4883A),
                  title: 'Customer Support',
                  onTap: () {
                    Navigator.pop(context);
                    GoRouter.of(context).push('/support');
                  },
                ),
                _DrawerItem(
                  icon: Icons.privacy_tip_rounded,
                  iconColor: const Color(0xFF6366B0),
                  title: 'Privacy Policy',
                  onTap: () {
                    Navigator.pop(context);
                    GoRouter.of(context).push('/privacy');
                  },
                ),
                _DrawerItem(
                  icon: Icons.description_rounded,
                  iconColor: const Color(0xFF2BA5A5),
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

            // Danger section
            const SizedBox(height: 20),
            _DrawerGroup(
              children: [
                _DrawerItem(
                  icon: Icons.delete_outline_rounded,
                  iconColor: const Color(0xFFE04B3D),
                  title: 'Delete My Data',
                  titleColor: const Color(0xFFE04B3D),
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
                _DrawerItem(
                  icon: Icons.logout_rounded,
                  iconColor: const Color(0xFFE04B3D),
                  title: 'Log Out',
                  titleColor: const Color(0xFFE04B3D),
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

            // Version
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Text(
                  '${AppConfig.appName} v1.0.0',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF8E8E93),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Drawer-specific widgets — Apple Settings grouped list style
// ─────────────────────────────────────────────────────────────────────────────

class _DrawerGroup extends StatelessWidget {
  final List<_DrawerItem> children;

  const _DrawerGroup({required this.children});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            for (int i = 0; i < children.length; i++) ...[
              children[i],
              if (i < children.length - 1)
                Padding(
                  padding: const EdgeInsets.only(left: 64),
                  child: Container(
                    height: 0.5,
                    color: const Color(0xFFE5E5EA),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final Color? titleColor;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _DrawerItem({
    required this.icon,
    required this.iconColor,
    required this.title,
    this.titleColor,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: iconColor,
                borderRadius: BorderRadius.circular(8),
              ),
              alignment: Alignment.center,
              child: Icon(icon, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: titleColor ?? const Color(0xFF1C1C1E),
                  letterSpacing: -0.2,
                ),
              ),
            ),
            if (trailing != null)
              trailing!
            else if (onTap != null)
              const Icon(Icons.chevron_right_rounded,
                  color: Color(0xFFC7C7CC), size: 20),
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
