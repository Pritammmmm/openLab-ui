import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/config/app_theme.dart';
import '../../../core/utils/helpers.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_error_widget.dart';
import '../../../core/widgets/app_loading.dart';
import '../../auth/providers/auth_provider.dart';
import '../models/profile_model.dart';
import '../providers/profile_provider.dart';

class ManageProfilesScreen extends ConsumerWidget {
  const ManageProfilesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profilesAsync = ref.watch(manageProfilesProvider);
    final user = ref.watch(currentUserProvider);
    final isPremium = user?.subscription.isPremium ?? false;
    final maxAllowed = maxProfilesForPlan(user?.subscription.plan);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Family Profiles'),
        actions: [
          profilesAsync.whenOrNull(
                data: (profiles) => Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: profiles.length >= maxAllowed
                            ? AppColors.yellowBg
                            : AppColors.primary.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${profiles.length}/$maxAllowed',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: profiles.length >= maxAllowed
                              ? AppColors.yellow
                              : AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                ),
              ) ??
              const SizedBox.shrink(),
        ],
      ),
      body: profilesAsync.when(
        data: (profiles) {
          final atCap = profiles.length >= maxAllowed;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              ...profiles.map((profile) => _ProfileTile(profile: profile)),
              if (!atCap && isPremium)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: AppButton(
                    label: 'Add Family Member',
                    variant: AppButtonVariant.outline,
                    icon: Icons.person_add_rounded,
                    onPressed: () => _showAddProfileSheet(context, ref),
                  ),
                )
              else if (!isPremium)
                _UpgradeCard(context: context)
              else
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.yellowBg,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline_rounded,
                            color: AppColors.yellow, size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'You\'ve reached the maximum of $maxAllowed profiles. '
                            'Delete an existing member to add a new one.',
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: AppColors.textSecondary,
                                    ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          );
        },
        loading: () => const AppLoading(),
        error: (e, _) => AppErrorWidget(
          message: 'Failed to load profiles',
          onRetry: () => ref.invalidate(manageProfilesProvider),
        ),
      ),
    );
  }

  void _showAddProfileSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom,
        ),
        child: const _AddProfileSheet(),
      ),
    ).then((_) {
      // Always refresh the list when sheet closes
      ref.invalidate(manageProfilesProvider);
    });
  }
}

class _ProfileTile extends ConsumerWidget {
  final ProfileModel profile;

  const _ProfileTile({required this.profile});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          radius: 24,
          backgroundColor: AppColors.primary.withValues(alpha: 0.1),
          child: Text(
            profile.initials,
            style: const TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
        ),
        title: Row(
          children: [
            Flexible(
              child: Text(
                profile.name,
                style: Theme.of(context).textTheme.titleMedium,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (profile.isDefault) ...[
              const SizedBox(width: 8),
              const Icon(Icons.star_rounded,
                  color: AppColors.yellow, size: 18),
            ],
          ],
        ),
        subtitle: Text(
          '${profile.relation.capitalize()} · ${profile.reportCount} reports',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        trailing: profile.isDefault
            ? null
            : PopupMenuButton<String>(
                onSelected: (value) async {
                  if (value == 'default') {
                    await ref
                        .read(manageProfilesProvider.notifier)
                        .setDefault(profile.id);
                  } else if (value == 'delete') {
                    _confirmDelete(context, ref);
                  }
                },
                itemBuilder: (_) => [
                  const PopupMenuItem(
                    value: 'default',
                    child: Text('Set as Default'),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Text('Delete',
                        style: TextStyle(color: AppColors.red)),
                  ),
                ],
              ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Profile'),
        content: Text(
          'Are you sure you want to delete "${profile.name}"? '
          'This will also remove all their reports and data.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await ref
                  .read(manageProfilesProvider.notifier)
                  .deleteProfile(profile.id);
            },
            child: const Text('Delete',
                style: TextStyle(color: AppColors.red)),
          ),
        ],
      ),
    );
  }
}

class _UpgradeCard extends StatelessWidget {
  final BuildContext context;

  const _UpgradeCard({required this.context});

  @override
  Widget build(BuildContext _) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primary.withValues(alpha: 0.08),
              AppColors.primary.withValues(alpha: 0.03),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.15),
          ),
        ),
        child: Column(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.family_restroom_rounded,
                color: AppColors.primary,
                size: 28,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Track Your Family\'s Health',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Upgrade to Premium to add family members and '
              'track their blood reports separately.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: AppButton(
                label: 'Upgrade to Premium',
                icon: Icons.star_rounded,
                onPressed: () => GoRouter.of(context).push('/pricing'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddProfileSheet extends ConsumerStatefulWidget {
  const _AddProfileSheet();

  @override
  ConsumerState<_AddProfileSheet> createState() => _AddProfileSheetState();
}

class _AddProfileSheetState extends ConsumerState<_AddProfileSheet> {
  final _nameController = TextEditingController();
  DateTime? _dateOfBirth;
  String _gender = 'male';
  String _relation = 'father';
  bool _isLoading = false;

  final _relations = ['father', 'mother', 'spouse', 'child', 'other'];

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final name = _nameController.text.trim();
    if (name.isEmpty || _dateOfBirth == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      await ref.read(manageProfilesProvider.notifier).createProfile(
            name: name,
            dateOfBirth: _dateOfBirth!,
            gender: _gender,
            relation: _relation,
          );
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceFirst('Exception: ', '')),
            backgroundColor: AppColors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.surfaceBorder,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text('Add Family Member',
              style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 4),
          Text(
            'Track health reports for a family member',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textMuted,
                ),
          ),
          const SizedBox(height: 24),
          TextFormField(
            controller: _nameController,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
              labelText: 'Full Name',
              prefixIcon: Icon(Icons.person_outline_rounded),
            ),
          ),
          const SizedBox(height: 16),
          InkWell(
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: DateTime(2000),
                firstDate: DateTime(1900),
                lastDate: DateTime.now(),
              );
              if (picked != null) setState(() => _dateOfBirth = picked);
            },
            child: InputDecorator(
              decoration: const InputDecoration(
                labelText: 'Date of Birth',
                prefixIcon: Icon(Icons.calendar_today_rounded),
              ),
              child: Text(
                _dateOfBirth != null
                    ? Helpers.formatDate(_dateOfBirth)
                    : 'Select date',
                style: TextStyle(
                  color: _dateOfBirth != null
                      ? AppColors.textPrimary
                      : AppColors.textMuted,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            initialValue: _gender,
            decoration: const InputDecoration(
              labelText: 'Gender',
              prefixIcon: Icon(Icons.wc_rounded),
            ),
            items: ['male', 'female', 'other']
                .map((g) => DropdownMenuItem(
                    value: g, child: Text(g.capitalize())))
                .toList(),
            onChanged: (v) => setState(() => _gender = v ?? 'male'),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            initialValue: _relation,
            decoration: const InputDecoration(
              labelText: 'Relation',
              prefixIcon: Icon(Icons.family_restroom_rounded),
            ),
            items: _relations
                .map((r) => DropdownMenuItem(
                    value: r, child: Text(r.capitalize())))
                .toList(),
            onChanged: (v) => setState(() => _relation = v ?? 'father'),
          ),
          const SizedBox(height: 24),
          AppButton(
            label: 'Add Profile',
            onPressed: _submit,
            isLoading: _isLoading,
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
