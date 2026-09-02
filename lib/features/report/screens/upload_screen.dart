import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../core/config/app_theme.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/isometric_icon.dart';
import '../../home/providers/home_provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../subscription/models/subscription_plan.dart';
import '../../subscription/providers/subscription_provider.dart';
import '../../../core/utils/helpers.dart';
import '../../profile/models/profile_model.dart';
import '../providers/upload_provider.dart';

class UploadScreen extends ConsumerStatefulWidget {
  const UploadScreen({super.key});

  @override
  ConsumerState<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends ConsumerState<UploadScreen> {
  File? _selectedFile;
  String? _fileName;
  bool _isImage = false;
  ProfileModel? _uploadProfile;

  @override
  void initState() {
    super.initState();
    Future((){
      ref.read(uploadNotifierProvider.notifier).reset();
      _initUploadProfile();
    });
  }

  void _initUploadProfile() {
    if (_uploadProfile != null) return;
    final global = ref.read(selectedProfileProvider);
    if (global != null && mounted) {
      setState(() => _uploadProfile = global);
    }
  }

  Future<void> _pickFromCamera() async {
    final status = await Permission.camera.request();
    if (!status.isGranted) {
      if (mounted) {
        _showPermissionDialog(
          'Camera Access Required',
          'WiseBlood needs camera access to take photos of your blood reports.',
        );
      }
      return;
    }

    final picker = ImagePicker();
    final image = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 85,
    );
    if (image != null) {
      setState(() {
        _selectedFile = File(image.path);
        _fileName = image.name;
        _isImage = true;
      });
    }
  }

  Future<void> _pickFromGallery() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (image != null) {
      setState(() {
        _selectedFile = File(image.path);
        _fileName = image.name;
        _isImage = true;
      });
    }
  }

  Future<void> _pickPdf() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    if (result != null && result.files.single.path != null) {
      setState(() {
        _selectedFile = File(result.files.single.path!);
        _fileName = result.files.single.name;
        _isImage = false;
      });
    }
  }

  void _showPermissionDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              openAppSettings();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  Future<void> _upload() async {
    if (_selectedFile == null) return;
    if (_uploadProfile == null) return;

    await ref.read(uploadNotifierProvider.notifier).upload(
          file: _selectedFile!,
          profileId: _uploadProfile!.id,
        );
  }

  @override
  Widget build(BuildContext context) {
    final uploadState = ref.watch(uploadNotifierProvider);

    // Initialize local upload profile from the global selection on first build
    if (_uploadProfile == null) {
      final global = ref.read(selectedProfileProvider);
      if (global != null) {
        _uploadProfile = global;
      }
    }

    ref.listen<UploadState>(uploadNotifierProvider, (prev, next) {
      if (next.status == UploadStatus.processing && next.reportId != null) {
        context.pushReplacement('/processing/${next.reportId}');
      }
      if (next.status == UploadStatus.failed && next.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error!),
            backgroundColor: AppColors.red,
          ),
        );
      }
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Upload Report'),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go('/');
              }
            },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_selectedFile == null) ...[
              Text(
                'Choose your report',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Take a photo or pick a PDF of your blood test report '
                'from a laboratory or healthcare provider.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.15),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.science_outlined,
                      size: 20,
                      color: AppColors.primary.withValues(alpha: 0.7),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'This app does not perform blood tests. You need a '
                        'blood test report from a certified lab or clinic.',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              _UploadLimitBanner(),
              const SizedBox(height: 16),
              _UploadOption(
                icon: Icons.camera_alt_rounded,
                title: 'Take a Photo',
                subtitle: 'Use your camera to capture the report',
                onTap: _pickFromCamera,
              ),
              const SizedBox(height: 12),
              _UploadOption(
                icon: Icons.photo_library_rounded,
                title: 'Choose from Gallery',
                subtitle: 'Select an existing photo of your report',
                onTap: _pickFromGallery,
              ),
              const SizedBox(height: 12),
              _UploadOption(
                icon: Icons.picture_as_pdf_rounded,
                title: 'Upload PDF',
                subtitle: 'Select a PDF report from your files',
                onTap: _pickPdf,
              ),
            ] else ...[
              // File preview
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppTheme.cardRadius),
                  border: Border.all(color: AppColors.surfaceBorder),
                ),
                child: Column(
                  children: [
                    if (_isImage)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(
                          _selectedFile!,
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      )
                    else
                      Container(
                        height: 120,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: AppColors.redBg,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.picture_as_pdf_rounded,
                                size: 48, color: AppColors.red),
                            const SizedBox(height: 8),
                            Text(
                              _fileName ?? 'PDF File',
                              style: Theme.of(context).textTheme.bodyMedium,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 12),
                    TextButton.icon(
                      onPressed: () {
                        setState(() {
                          _selectedFile = null;
                          _fileName = null;
                        });
                      },
                      icon: const Icon(Icons.swap_horiz_rounded),
                      label: const Text('Choose Different File'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Profile selector
              _ProfileSelector(
                selectedProfile: _uploadProfile,
                onSwitch: (profile) {
                  setState(() => _uploadProfile = profile);
                },
              ),
              const SizedBox(height: 32),

              // Upload button
              AppButton(
                label: uploadState.status == UploadStatus.uploading
                    ? 'Uploading... ${(uploadState.progress * 100).toInt()}%'
                    : 'Analyze This Report',
                onPressed: uploadState.status == UploadStatus.uploading
                    ? null
                    : _upload,
                isLoading: uploadState.status == UploadStatus.uploading,
                icon: Icons.auto_awesome_rounded,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _UploadOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _UploadOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppTheme.cardRadius),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppTheme.cardRadius),
          border: Border.all(color: AppColors.surfaceBorder),
        ),
        child: Row(
          children: [
            Icon3D(
              icon: icon,
              size: 48,
              color: AppColors.primary,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 2),
                  Text(subtitle,
                      style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded,
                color: AppColors.textMuted),
          ],
        ),
      ),
    );
  }
}

class _UploadLimitBanner extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activePlan = ref.watch(activePlanProvider);
    final isFree = activePlan == PlanTier.free;

    if (!isFree) return const SizedBox.shrink();

    // Use the user model's report count as an estimate
    // The exact enforcement happens server-side
    final user = ref.watch(currentUserProvider);
    final totalReports = user?.usage?.totalReports ?? 0;
    const freeLimit = 3;
    final remaining = (freeLimit - totalReports).clamp(0, freeLimit);
    final isAtCap = remaining <= 0;

    final bgColor = isAtCap ? AppColors.redBg : AppColors.yellowBg;
    final accentColor = isAtCap ? AppColors.red : AppColors.yellow;
    final icon = isAtCap ? Icons.block_rounded : Icons.info_outline_rounded;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: accentColor.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 20, color: accentColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isAtCap
                      ? 'Free upload limit reached'
                      : '$remaining of $freeLimit free reports remaining',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                GestureDetector(
                  onTap: () => GoRouter.of(context).push('/pricing'),
                  child: Text(
                    isAtCap
                        ? 'Upgrade to Plus for unlimited reports'
                        : 'Upgrade for unlimited uploads',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.primary,
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

// ─────────────────────────────────────────────────────────────────────────────
// Profile Selector — dropdown-style profile picker for upload target
// ─────────────────────────────────────────────────────────────────────────────

class _ProfileSelector extends ConsumerWidget {
  final ProfileModel? selectedProfile;
  final ValueChanged<ProfileModel> onSwitch;

  const _ProfileSelector({
    required this.selectedProfile,
    required this.onSwitch,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profilesAsync = ref.watch(profilesProvider);
    final profiles = profilesAsync.valueOrNull ?? [];
    final hasMultiple = profiles.length > 1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        const Padding(
          padding: EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            'This report belongs to',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1C1C1E),
            ),
          ),
        ),

        // Dropdown-style card
        GestureDetector(
          onTap: hasMultiple
              ? () => _showProfilePicker(context, profiles)
              : null,
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: hasMultiple
                    ? AppColors.primary.withValues(alpha: 0.2)
                    : Colors.black.withValues(alpha: 0.06),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                // Avatar
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF7B52F5),
                        Color(0xFF5F33E1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    selectedProfile?.initials ?? '?',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 14),

                // Name + relation
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        selectedProfile?.name ?? 'Unknown',
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1C1C1E),
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        selectedProfile?.relation.capitalize() ?? 'Self',
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF8E8E93),
                        ),
                      ),
                    ],
                  ),
                ),

                // Dropdown chevron or single-profile check
                if (hasMultiple)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Change',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                        SizedBox(width: 2),
                        Icon(
                          Icons.keyboard_arrow_down_rounded,
                          size: 18,
                          color: AppColors.primary,
                        ),
                      ],
                    ),
                  )
                else
                  Container(
                    width: 28,
                    height: 28,
                    decoration: const BoxDecoration(
                      color: AppColors.green,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_rounded,
                      size: 16,
                      color: Colors.white,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showProfilePicker(
      BuildContext context, List<ProfileModel> profiles) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        margin: const EdgeInsets.fromLTRB(10, 0, 10, 10),
        decoration: BoxDecoration(
          color: const Color(0xFFF2F2F7),
          borderRadius: BorderRadius.circular(20),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(0, 10, 0, 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Drag handle
                Container(
                  width: 36,
                  height: 5,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD1D1D6),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                const SizedBox(height: 16),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Who is this report for?',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1C1C1E),
                        letterSpacing: -0.3,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                // Profile list
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      children: [
                        for (int i = 0; i < profiles.length; i++) ...[
                          _ProfilePickerRow(
                            profile: profiles[i],
                            isSelected:
                                profiles[i].id == selectedProfile?.id,
                            onTap: () {
                              Navigator.pop(ctx);
                              onSwitch(profiles[i]);
                            },
                          ),
                          if (i < profiles.length - 1)
                            Padding(
                              padding: const EdgeInsets.only(left: 62),
                              child: Container(
                                height: 0.5,
                                color: const Color(0xFFE5E5EA),
                              ),
                            ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ProfilePickerRow extends StatelessWidget {
  final ProfileModel profile;
  final bool isSelected;
  final VoidCallback onTap;

  const _ProfilePickerRow({
    required this.profile,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        color: isSelected
            ? AppColors.primary.withValues(alpha: 0.04)
            : Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                gradient: isSelected
                    ? const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF7B52F5), Color(0xFF5F33E1)],
                      )
                    : LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColors.primary.withValues(alpha: 0.12),
                          AppColors.primary.withValues(alpha: 0.06),
                        ],
                      ),
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: Text(
                profile.initials,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: isSelected ? Colors.white : AppColors.primary,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    profile.name,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight:
                          isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: const Color(0xFF1C1C1E),
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    '${profile.relation.capitalize()} · ${profile.reportCount} reports',
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF8E8E93),
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Container(
                width: 24,
                height: 24,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_rounded,
                  size: 14,
                  color: Colors.white,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
