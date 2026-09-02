import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/config/app_theme.dart';
import '../../../core/widgets/app_toast.dart';
import '../providers/health_sync_provider.dart';
import '../providers/pedometer_provider.dart';
import '../widgets/health_card.dart';

class HealthSyncSettingsScreen extends ConsumerWidget {
  const HealthSyncSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final syncAsync = ref.watch(healthSyncProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Health Sync',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: syncAsync.when(
        data: (state) => _SyncBody(state: state),
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.sync_problem_rounded,
                    size: 48, color: AppColors.textMuted),
                const SizedBox(height: 16),
                Text(
                  'Could not load sync settings',
                  style: TextStyle(
                    fontSize: 15,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Body
// ─────────────────────────────────────────────────────────────────────────────

class _SyncBody extends ConsumerWidget {
  final HealthSyncState state;

  const _SyncBody({required this.state});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
      children: [
        // Header text
        const Text(
          'Connect your health apps to sync data automatically.',
          style: TextStyle(fontSize: 14, color: AppColors.textMuted),
        ),
        const SizedBox(height: 20),

        // ── Google Fit ──
        _PlatformTile(
          logoPath: 'assets/images/Google_Fit_icon_(2018).svg.png',
          title: 'Google Fit',
          connectedSubtitle: 'Connected — syncing via Health Connect',
          disconnectedSubtitle: 'Steps, heart rate, weight, sleep & more',
          brandColor: const Color(0xFF4285F4),
          enabled: state.googleFitEnabled,
          isSyncing: state.isSyncing && state.googleFitEnabled,
          onToggle: (v) => _handleToggle(
            context,
            ref,
            v,
            'Google Fit',
            ref.read(healthSyncProvider.notifier).toggleGoogleFit,
          ),
        ),
        const SizedBox(height: 12),

        // ── Samsung Health ──
        _PlatformTile(
          logoPath: 'assets/images/Samsung_Health_2025_logo.png',
          title: 'Samsung Health',
          connectedSubtitle: 'Connected — syncing via Health Connect',
          disconnectedSubtitle: 'Steps, heart rate, weight, sleep & more',
          brandColor: const Color(0xFF1428A0),
          enabled: state.samsungHealthEnabled,
          isSyncing: state.isSyncing && state.samsungHealthEnabled,
          onToggle: (v) => _handleToggle(
            context,
            ref,
            v,
            'Samsung Health',
            ref.read(healthSyncProvider.notifier).toggleSamsungHealth,
          ),
        ),

        const SizedBox(height: 24),

        // ── Health Connect missing banner ──
        if (!state.healthConnectAvailable) ...[
          _HealthConnectMissingCard(),
          const SizedBox(height: 16),
        ],

        // ── Data types being synced ──
        if (state.anyEnabled) ...[
          _SyncedDataTypesCard(),
          const SizedBox(height: 16),
        ],

        // ── Step Counter Fallback ──
        _SensorFallbackCard(),
        const SizedBox(height: 16),

        // ── Sync status card ──
        _SyncStatusCard(state: state),
        const SizedBox(height: 16),

        // ── How it works ──
        _HowItWorksCard(),
      ],
    );
  }

  Future<void> _handleToggle(
    BuildContext context,
    WidgetRef ref,
    bool enabled,
    String platform,
    Future<ConnectOutcome> Function(bool) toggle,
  ) async {
    final outcome = await toggle(enabled);
    if (!context.mounted) return;

    switch (outcome) {
      case ConnectOutcome.connected:
        AppToast.success(
          context,
          '$platform connected',
          subtitle: 'Syncing your health data now...',
        );

      case ConnectOutcome.disconnected:
        AppToast.info(
          context,
          '$platform disconnected',
        );

      case ConnectOutcome.permissionDenied:
        AppToast.warning(
          context,
          'Permission not granted',
          subtitle:
              'Open Health Connect settings and allow WiseBlood to read your data.',
        );

      case ConnectOutcome.healthConnectMissing:
        AppToast.show(
          context,
          message: 'Health Connect not found',
          subtitle:
              'Install Health Connect from the Play Store to sync data.',
          type: ToastType.warning,
          duration: const Duration(seconds: 5),
        );

      case ConnectOutcome.healthConnectNotReady:
        AppToast.warning(
          context,
          'Health Connect needs an update',
          subtitle: 'Please update Health Connect from the Play Store.',
        );

      case ConnectOutcome.failed:
        AppToast.error(
          context,
          'Connection failed',
          subtitle: 'Something went wrong. Please try again.',
        );
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Platform tile — logo, title, connection status, toggle
// ─────────────────────────────────────────────────────────────────────────────

class _PlatformTile extends StatelessWidget {
  final String logoPath;
  final String title;
  final String connectedSubtitle;
  final String disconnectedSubtitle;
  final Color brandColor;
  final bool enabled;
  final bool isSyncing;
  final ValueChanged<bool> onToggle;

  const _PlatformTile({
    required this.logoPath,
    required this.title,
    required this.connectedSubtitle,
    required this.disconnectedSubtitle,
    required this.brandColor,
    required this.enabled,
    required this.isSyncing,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: enabled
              ? brandColor.withValues(alpha: 0.25)
              : Colors.black.withValues(alpha: 0.04),
          width: enabled ? 1.2 : 0.8,
        ),
        boxShadow: [
          if (enabled)
            BoxShadow(
              color: brandColor.withValues(alpha: 0.08),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Logo
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.white,
              border: Border.all(
                color: Colors.black.withValues(alpha: 0.06),
                width: 0.5,
              ),
            ),
            clipBehavior: Clip.antiAlias,
            child: Padding(
              padding: const EdgeInsets.all(6),
              child: Image.asset(logoPath, fit: BoxFit.contain),
            ),
          ),
          const SizedBox(width: 14),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    if (enabled) ...[
                      const SizedBox(width: 8),
                      if (isSyncing)
                        const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(
                            strokeWidth: 1.5,
                            color: AppColors.primary,
                          ),
                        )
                      else
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.greenBg,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'Active',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: AppColors.green,
                            ),
                          ),
                        ),
                    ],
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  enabled ? connectedSubtitle : disconnectedSubtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: enabled ? AppColors.textSecondary : AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),

          // Toggle
          Switch.adaptive(
            value: enabled,
            onChanged: onToggle,
            activeTrackColor: brandColor,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Data types card
// ─────────────────────────────────────────────────────────────────────────────

class _SyncedDataTypesCard extends StatelessWidget {
  static const _types = [
    ('Steps', Icons.directions_walk_rounded, Color(0xFF4CAF50)),
    ('Heart Rate', Icons.favorite_rounded, Color(0xFFFF5252)),
    ('Weight', Icons.monitor_weight_rounded, Color(0xFF5F33E1)),
    ('Blood Pressure', Icons.monitor_heart_rounded, Color(0xFFE91E63)),
    ('Blood Sugar', Icons.bloodtype_rounded, Color(0xFFEF5350)),
    ('Sleep', Icons.bedtime_rounded, Color(0xFF6E8EF7)),
    ('SpO₂', Icons.air_rounded, Color(0xFF4FC3F7)),
    ('Temperature', Icons.thermostat_rounded, Color(0xFF66BB6A)),
  ];

  @override
  Widget build(BuildContext context) {
    return HealthCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.sync_rounded, size: 16, color: AppColors.primary),
              SizedBox(width: 8),
              Text(
                'Syncing these data types',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _types
                .map((t) => _TypeChip(label: t.$1, icon: t.$2, color: t.$3))
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _TypeChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;

  const _TypeChip({
    required this.label,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.14)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: color.withValues(alpha: 0.85),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Sync status card
// ─────────────────────────────────────────────────────────────────────────────

class _SyncStatusCard extends ConsumerWidget {
  final HealthSyncState state;

  const _SyncStatusCard({required this.state});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return HealthCard(
      child: Column(
        children: [
          Row(
            children: [
              _SyncIcon(state: state),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _statusTitle,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _statusSubtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              if (state.anyEnabled)
                TextButton(
                  onPressed:
                      state.isSyncing ? null : () => ref.read(healthSyncProvider.notifier).syncNow(),
                  style: TextButton.styleFrom(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    backgroundColor: state.isSyncing
                        ? null
                        : AppColors.primary.withValues(alpha: 0.06),
                  ),
                  child: Text(
                    state.isSyncing ? 'Syncing...' : 'Sync Now',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: state.isSyncing
                          ? AppColors.textMuted
                          : AppColors.primary,
                    ),
                  ),
                ),
            ],
          ),
          if (state.syncStatus == SyncStatus.success &&
              state.lastSyncCount > 0) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.greenBg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle_rounded,
                      size: 16, color: AppColors.green),
                  const SizedBox(width: 8),
                  Text(
                    '${state.lastSyncCount} data points synced',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.green,
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (state.syncStatus == SyncStatus.success &&
              state.lastSyncCount == 0 &&
              state.anyEnabled) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline_rounded,
                      size: 16, color: AppColors.primary),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'No new data found. Make sure Samsung Health or Google Fit has synced to Health Connect.',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  String get _statusTitle {
    if (state.isSyncing) return 'Syncing health data...';
    if (!state.anyEnabled) return 'Not connected';
    if (state.lastSyncAt != null) return 'Last synced ${_relativeTime(state.lastSyncAt!)}';
    return 'Ready to sync';
  }

  String get _statusSubtitle {
    if (state.isSyncing) return 'Reading from Health Connect';
    if (!state.anyEnabled) return 'Enable a platform above to start';
    if (state.lastSyncAt != null) {
      return DateFormat('MMM d, yyyy · h:mm a').format(state.lastSyncAt!);
    }
    return 'Tap Sync Now to pull your data';
  }

  String _relativeTime(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inSeconds < 60) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return DateFormat('MMM d').format(dt);
  }
}

class _SyncIcon extends StatelessWidget {
  final HealthSyncState state;

  const _SyncIcon({required this.state});

  @override
  Widget build(BuildContext context) {
    if (state.isSyncing) {
      return Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.primary,
            ),
          ),
        ),
      );
    }

    final (color, icon) = state.anyEnabled
        ? (AppColors.green, Icons.sync_rounded)
        : (AppColors.textMuted, Icons.sync_disabled_rounded);

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: color, size: 20),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// How it works
// ─────────────────────────────────────────────────────────────────────────────

class _HowItWorksCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return HealthCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.info_outline_rounded,
                    color: AppColors.primary, size: 18),
              ),
              const SizedBox(width: 12),
              const Text(
                'How it works',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _StepRow(
            number: '1',
            text: 'Google Fit & Samsung Health write data to Health Connect',
          ),
          const SizedBox(height: 12),
          _StepRow(
            number: '2',
            text: 'WiseBlood reads steps, vitals, sleep & weight',
          ),
          const SizedBox(height: 12),
          _StepRow(
            number: '3',
            text: 'Data syncs automatically every time you open the app',
          ),
        ],
      ),
    );
  }
}

class _SensorFallbackCard extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sensorEnabled = ref.watch(pedometerToggleProvider);
    final isOn = sensorEnabled.valueOrNull ?? false;

    return HealthCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF4CAF50).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.directions_walk_rounded,
                    color: Color(0xFF4CAF50), size: 18),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Phone Step Counter',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Count steps using phone sensors',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              Switch.adaptive(
                value: isOn,
                onChanged: (v) async {
                  await ref.read(pedometerToggleProvider.notifier).toggle(v);
                  if (!context.mounted) return;
                  final newState = ref.read(pedometerToggleProvider).valueOrNull ?? false;
                  if (v && !newState) {
                    AppToast.warning(
                      context,
                      'Permission required',
                      subtitle: 'Allow activity recognition to count steps.',
                    );
                  } else if (v && newState) {
                    AppToast.success(
                      context,
                      'Step counter active',
                      subtitle: 'Counting steps using phone sensors.',
                    );
                  }
                },
                activeTrackColor: const Color(0xFF4CAF50),
              ),
            ],
          ),
          if (isOn) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.greenBg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Row(
                children: [
                  Icon(Icons.check_circle_rounded,
                      size: 14, color: AppColors.green),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Active — counting steps from phone motion sensors',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.green,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (!isOn) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline_rounded,
                      size: 14, color: AppColors.primary),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Enable to track steps when Health Connect is unavailable or has no data.',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _HealthConnectMissingCard extends StatelessWidget {
  static const _playStoreUrl =
      'https://play.google.com/store/apps/details?id=com.google.android.apps.healthdata';

  @override
  Widget build(BuildContext context) {
    return HealthCard(
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.yellowBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.warning_amber_rounded,
                    color: AppColors.yellow, size: 18),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Health Connect required',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Install Health Connect from the Play Store to sync data from Samsung Health and Google Fit.',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textMuted,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () => launchUrl(
                Uri.parse(_playStoreUrl),
                mode: LaunchMode.externalApplication,
              ),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                backgroundColor: AppColors.primary.withValues(alpha: 0.06),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Install Health Connect',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StepRow extends StatelessWidget {
  final String number;
  final String text;

  const _StepRow({required this.number, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.08),
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Text(
            number,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}
