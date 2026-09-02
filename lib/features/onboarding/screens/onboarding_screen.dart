import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/config/app_theme.dart';
import '../../auth/providers/auth_provider.dart';
import '../../profile/providers/profile_provider.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen>
    with TickerProviderStateMixin {
  late final PageController _pageCtrl;
  late final AnimationController _contentAnim;
  late final AnimationController _completeAnim;
  late final TextEditingController _nameCtrl;
  late final TextEditingController _heightCtrl;
  late final TextEditingController _weightCtrl;

  int _page = 0;
  DateTime? _dob;
  String _gender = 'male';
  String? _goal;
  final Set<String> _conditions = {};
  String? _occupation;
  String? _activity;
  bool _saving = false;

  static const _totalPages = 8;
  static const _dataPages = 6;

  @override
  void initState() {
    super.initState();
    _pageCtrl = PageController();
    _contentAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..forward();
    _completeAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    final user = ref.read(currentUserProvider);
    _nameCtrl = TextEditingController(text: user?.name ?? '');
    _heightCtrl = TextEditingController();
    _weightCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    _contentAnim.dispose();
    _completeAnim.dispose();
    _nameCtrl.dispose();
    _heightCtrl.dispose();
    _weightCtrl.dispose();
    super.dispose();
  }

  // ─── Navigation ───────────────────────────────────────────────────────

  void _next() {
    if (_page >= _totalPages - 1) return;
    FocusScope.of(context).unfocus();
    HapticFeedback.lightImpact();
    _pageCtrl.nextPage(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOutCubic,
    );
  }

  void _back() {
    if (_page <= 0) return;
    FocusScope.of(context).unfocus();
    HapticFeedback.selectionClick();
    _pageCtrl.previousPage(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOutCubic,
    );
  }

  void _onPageChanged(int page) {
    setState(() => _page = page);
    _contentAnim.reset();
    _contentAnim.forward();
    if (page == _totalPages - 1) {
      _completeAnim.forward();
    }
  }

  Future<void> _finish() async {
    if (_saving) return;
    setState(() => _saving = true);

    try {
      await ref.read(manageProfilesProvider.notifier).createProfile(
            name: _nameCtrl.text.trim(),
            dateOfBirth: _dob!,
            gender: _gender,
            relation: 'self',
          );

      final prefs = await SharedPreferences.getInstance();
      final h = double.tryParse(_heightCtrl.text);
      final w = double.tryParse(_weightCtrl.text);
      if (h != null) await prefs.setDouble('onboarding_height_cm', h);
      if (w != null) await prefs.setDouble('onboarding_weight_kg', w);
      if (_goal != null) await prefs.setString('onboarding_goal', _goal!);
      if (_conditions.isNotEmpty) {
        await prefs.setString(
            'onboarding_conditions', jsonEncode(_conditions.toList()));
      }
      if (_occupation != null) {
        await prefs.setString('onboarding_occupation', _occupation!);
      }
      if (_activity != null) {
        await prefs.setString('onboarding_activity', _activity!);
      }

      await ref.read(authNotifierProvider.notifier).completeOnboarding();
      _next();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Something went wrong: $e'),
            backgroundColor: AppColors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  bool get _canNext => switch (_page) {
        1 => _nameCtrl.text.trim().length >= 2,
        2 => _dob != null,
        4 => _goal != null,
        _ => true,
      };

  // ─── Animation helper ─────────────────────────────────────────────────

  Widget _anim(double delay, Widget child) {
    final end = (delay + 0.4).clamp(0.0, 1.0);
    final curve = CurvedAnimation(
      parent: _contentAnim,
      curve: Interval(delay, end, curve: Curves.easeOutCubic),
    );
    return AnimatedBuilder(
      animation: curve,
      builder: (context, ch) => Opacity(
        opacity: curve.value,
        child: Transform.translate(
          offset: Offset(0, 28 * (1 - curve.value)),
          child: ch,
        ),
      ),
      child: child,
    );
  }

  // ─── Build ────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final isDataPage = _page >= 1 && _page <= _dataPages;
    final isLastDataPage = _page == _dataPages;
    final isComplete = _page == _totalPages - 1;

    return PopScope(
      canPop: _page == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _back();
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        resizeToAvoidBottomInset: true,
        body: SafeArea(
          child: Column(
            children: [
              // Header with progress
              if (isDataPage) _buildHeader(),

              // Pages
              Expanded(
                child: PageView(
                  controller: _pageCtrl,
                  physics: const NeverScrollableScrollPhysics(),
                  onPageChanged: _onPageChanged,
                  children: [
                    _welcomePage(),
                    _namePage(),
                    _basicInfoPage(),
                    _bodyPage(),
                    _goalPage(),
                    _healthPage(),
                    _lifestylePage(),
                    _completePage(),
                  ],
                ),
              ),

              // Footer button
              if (!isComplete)
                _buildFooter(isLastDataPage: isLastDataPage),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final progress = _page / _dataPages;
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 20, 0),
      child: Row(
        children: [
          GestureDetector(
            onTap: _back,
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(Icons.arrow_back_ios_new_rounded,
                  size: 18, color: AppColors.textPrimary),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeInOutCubic,
                height: 6,
                child: LayoutBuilder(
                  builder: (context, constraints) => Stack(
                    children: [
                      Container(
                        width: constraints.maxWidth,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeInOutCubic,
                        width: constraints.maxWidth * progress,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppColors.primaryDark, AppColors.primary],
                          ),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            '$_page/$_dataPages',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter({required bool isLastDataPage}) {
    final showSkip = _page == 3 || _page == 5 || _page == 6;
    final isWelcome = _page == 0;
    final label = isWelcome
        ? 'Get Started'
        : isLastDataPage
            ? "Let's Go"
            : 'Continue';

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: double.infinity,
            height: 56,
            child: AnimatedOpacity(
              opacity: _canNext ? 1.0 : 0.5,
              duration: const Duration(milliseconds: 200),
              child: FilledButton(
                onPressed:
                    _canNext ? (isLastDataPage ? _finish : _next) : null,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  disabledBackgroundColor:
                      AppColors.primary.withValues(alpha: 0.4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: _saving
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        label,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          ),
          if (showSkip) ...[
            const SizedBox(height: 8),
            GestureDetector(
              onTap: isLastDataPage ? _finish : _next,
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  'Skip for now',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textMuted,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ─── Page 0: Welcome ──────────────────────────────────────────────────

  Widget _welcomePage() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _anim(
            0.0,
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.primary.withValues(alpha: 0.12),
                    AppColors.primary.withValues(alpha: 0.04),
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.bloodtype_rounded,
                  size: 56, color: AppColors.primary.withValues(alpha: 0.7)),
            ),
          ),
          const SizedBox(height: 36),
          _anim(
            0.1,
            const Text(
              'Welcome to BloodWise',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
                letterSpacing: -0.8,
                height: 1.1,
              ),
            ),
          ),
          const SizedBox(height: 12),
          _anim(
            0.2,
            const Text(
              'Your personal health companion.\nLet\'s set up your profile in a few quick steps.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: AppColors.textMuted,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Page 1: Name ─────────────────────────────────────────────────────

  Widget _namePage() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 40, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _anim(0.0, _pageTitle('What\'s your name?')),
          const SizedBox(height: 6),
          _anim(
              0.05,
              const Text('We\'ll use this to personalise your experience.',
                  style: TextStyle(fontSize: 14, color: AppColors.textMuted))),
          const SizedBox(height: 32),
          _anim(
            0.15,
            TextField(
              controller: _nameCtrl,
              textCapitalization: TextCapitalization.words,
              autofocus: true,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
              decoration: InputDecoration(
                hintText: 'Enter your full name',
                hintStyle: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textMuted.withValues(alpha: 0.5),
                ),
                filled: true,
                fillColor: AppColors.surface,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: AppColors.divider.withValues(alpha: 0.5),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(
                    color: AppColors.primary,
                    width: 1.5,
                  ),
                ),
              ),
              onChanged: (_) => setState(() {}),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Page 2: Basic Info ───────────────────────────────────────────────

  Widget _basicInfoPage() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 40, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _anim(0.0, _pageTitle('Tell us about yourself')),
          const SizedBox(height: 6),
          _anim(
              0.05,
              const Text('This helps us analyse your blood reports accurately.',
                  style: TextStyle(fontSize: 14, color: AppColors.textMuted))),
          const SizedBox(height: 32),

          // Date of birth
          _anim(0.1, const Text('Date of Birth',
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary))),
          const SizedBox(height: 8),
          _anim(
            0.15,
            GestureDetector(
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _dob ?? DateTime(1995, 1, 1),
                  firstDate: DateTime(1900),
                  lastDate: DateTime.now(),
                  builder: (context, child) => Theme(
                    data: Theme.of(context).copyWith(
                      colorScheme: Theme.of(context)
                          .colorScheme
                          .copyWith(primary: AppColors.primary),
                    ),
                    child: child!,
                  ),
                );
                if (picked != null) setState(() => _dob = picked);
              },
              child: Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _dob != null
                        ? AppColors.primary.withValues(alpha: 0.3)
                        : AppColors.divider.withValues(alpha: 0.5),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.calendar_today_rounded,
                        size: 20,
                        color: _dob != null
                            ? AppColors.primary
                            : AppColors.textMuted),
                    const SizedBox(width: 12),
                    Text(
                      _dob != null
                          ? '${_dob!.day}/${_dob!.month}/${_dob!.year}'
                          : 'Select your date of birth',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight:
                            _dob != null ? FontWeight.w600 : FontWeight.w400,
                        color: _dob != null
                            ? AppColors.textPrimary
                            : AppColors.textMuted.withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 28),

          // Gender
          _anim(0.2, const Text('Gender',
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary))),
          const SizedBox(height: 10),
          _anim(
            0.25,
            Row(
              children: [
                _GenderPill(
                  label: 'Male',
                  icon: Icons.male_rounded,
                  selected: _gender == 'male',
                  onTap: () => setState(() => _gender = 'male'),
                ),
                const SizedBox(width: 10),
                _GenderPill(
                  label: 'Female',
                  icon: Icons.female_rounded,
                  selected: _gender == 'female',
                  onTap: () => setState(() => _gender = 'female'),
                ),
                const SizedBox(width: 10),
                _GenderPill(
                  label: 'Other',
                  icon: Icons.transgender_rounded,
                  selected: _gender == 'other',
                  onTap: () => setState(() => _gender = 'other'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── Page 3: Body Measurements ────────────────────────────────────────

  Widget _bodyPage() {
    final h = double.tryParse(_heightCtrl.text);
    final w = double.tryParse(_weightCtrl.text);
    final hasBmi = h != null && h > 0 && w != null && w > 0;
    final bmi = hasBmi ? w / ((h / 100) * (h / 100)) : 0.0;

    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 40, 24, 24),
      children: [
        _anim(0.0, _pageTitle('Your measurements')),
        const SizedBox(height: 6),
        _anim(
          0.05,
          const Text(
            'This helps track your body metrics over time.',
            style: TextStyle(fontSize: 14, color: AppColors.textMuted),
          ),
        ),
        const SizedBox(height: 32),
        _anim(
          0.1,
          _PremiumMeasurementCard(
            controller: _heightCtrl,
            label: 'Height',
            unit: 'cm',
            icon: Icons.straighten_rounded,
            hint: '170',
            accentColor: const Color(0xFF5F33E1),
            minVal: 100,
            maxVal: 220,
            onChanged: () => setState(() {}),
          ),
        ),
        const SizedBox(height: 14),
        _anim(
          0.2,
          _PremiumMeasurementCard(
            controller: _weightCtrl,
            label: 'Weight',
            unit: 'kg',
            icon: Icons.monitor_weight_outlined,
            hint: '65',
            accentColor: const Color(0xFFFF6B35),
            minVal: 30,
            maxVal: 150,
            onChanged: () => setState(() {}),
          ),
        ),
        if (hasBmi) ...[
          const SizedBox(height: 18),
          _anim(0.3, _BmiPreviewCard(bmi: bmi)),
        ],
      ],
    );
  }

  // ─── Page 4: Goal ─────────────────────────────────────────────────────

  Widget _goalPage() {
    const goals = [
      ('Track Blood Work', Icons.science_rounded, Color(0xFF5F33E1)),
      ('Stay Healthy', Icons.favorite_rounded, Color(0xFF34C759)),
      ('Lose Weight', Icons.monitor_weight_rounded, Color(0xFFFF9500)),
      ('Build Strength', Icons.fitness_center_rounded, Color(0xFFFF3B30)),
      ('Better Nutrition', Icons.restaurant_rounded, Color(0xFF30B0C7)),
      ('Manage Condition', Icons.medical_services_rounded, Color(0xFFAF52DE)),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 40, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _anim(0.0, _pageTitle('What\'s your primary goal?')),
          const SizedBox(height: 6),
          _anim(
              0.05,
              const Text('You can always change this later.',
                  style: TextStyle(fontSize: 14, color: AppColors.textMuted))),
          const SizedBox(height: 28),
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.45,
              padding: EdgeInsets.zero,
              children: [
                for (int i = 0; i < goals.length; i++)
                  _anim(
                    0.1 + i * 0.06,
                    _SelectCard(
                      label: goals[i].$1,
                      icon: goals[i].$2,
                      color: goals[i].$3,
                      selected: _goal == goals[i].$1,
                      onTap: () {
                        HapticFeedback.selectionClick();
                        setState(() => _goal = goals[i].$1);
                      },
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── Page 5: Health Conditions ────────────────────────────────────────

  Widget _healthPage() {
    const conditions = [
      ('Diabetes', Icons.bloodtype_rounded),
      ('Hypertension', Icons.speed_rounded),
      ('Thyroid Disorder', Icons.shield_rounded),
      ('Heart Disease', Icons.monitor_heart_rounded),
      ('Anemia', Icons.water_drop_rounded),
      ('High Cholesterol', Icons.show_chart_rounded),
      ('PCOS / PCOD', Icons.female_rounded),
      ('None of these', Icons.check_circle_outline_rounded),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 40, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _anim(0.0, _pageTitle('Any health conditions?')),
          const SizedBox(height: 6),
          _anim(
              0.05,
              const Text('Select all that apply. This stays private.',
                  style: TextStyle(fontSize: 14, color: AppColors.textMuted))),
          const SizedBox(height: 24),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    for (int i = 0; i < conditions.length; i++)
                      _anim(
                        0.1 + i * 0.04,
                        _ConditionChip(
                          label: conditions[i].$1,
                          icon: conditions[i].$2,
                          selected:
                              _conditions.contains(conditions[i].$1),
                          onTap: () {
                            HapticFeedback.selectionClick();
                            setState(() {
                              final label = conditions[i].$1;
                              if (label == 'None of these') {
                                _conditions.clear();
                                _conditions.add(label);
                              } else {
                                _conditions.remove('None of these');
                                if (_conditions.contains(label)) {
                                  _conditions.remove(label);
                                } else {
                                  _conditions.add(label);
                                }
                              }
                            });
                          },
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── Page 6: Lifestyle ────────────────────────────────────────────────

  Widget _lifestylePage() {
    const occupations = [
      'Student',
      'Working Professional',
      'Self Employed',
      'Homemaker',
      'Retired',
    ];
    const activities = [
      ('Sedentary', 'Little to no exercise'),
      ('Lightly Active', '1-3 days/week'),
      ('Moderately Active', '3-5 days/week'),
      ('Very Active', '6-7 days/week'),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 40, 24, 0),
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          _anim(0.0, _pageTitle('Your lifestyle')),
          const SizedBox(height: 6),
          _anim(
              0.05,
              const Text('Helps us tailor health insights for you.',
                  style: TextStyle(fontSize: 14, color: AppColors.textMuted))),
          const SizedBox(height: 28),

          // Occupation
          _anim(0.1, const Text('Occupation',
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary))),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (int i = 0; i < occupations.length; i++)
                _anim(
                  0.15 + i * 0.04,
                  _PillChip(
                    label: occupations[i],
                    selected: _occupation == occupations[i],
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() => _occupation = occupations[i]);
                    },
                  ),
                ),
            ],
          ),
          const SizedBox(height: 28),

          // Activity level
          _anim(0.3, const Text('Activity Level',
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary))),
          const SizedBox(height: 10),
          for (int i = 0; i < activities.length; i++) ...[
            _anim(
              0.35 + i * 0.05,
              _ActivityCard(
                label: activities[i].$1,
                subtitle: activities[i].$2,
                selected: _activity == activities[i].$1,
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() => _activity = activities[i].$1);
                },
              ),
            ),
            const SizedBox(height: 8),
          ],
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // ─── Page 7: Complete ─────────────────────────────────────────────────

  Widget _completePage() {
    final name = _nameCtrl.text.trim().split(' ').first;
    final scaleAnim = CurvedAnimation(
      parent: _completeAnim,
      curve: const Interval(0.0, 0.5, curve: Curves.elasticOut),
    );
    final fadeAnim = CurvedAnimation(
      parent: _completeAnim,
      curve: const Interval(0.3, 0.7, curve: Curves.easeOut),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ScaleTransition(
            scale: scaleAnim,
            child: Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.green.withValues(alpha: 0.15),
                    AppColors.green.withValues(alpha: 0.06),
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_rounded,
                  size: 56, color: AppColors.green),
            ),
          ),
          const SizedBox(height: 32),
          FadeTransition(
            opacity: fadeAnim,
            child: Column(
              children: [
                Text(
                  'You\'re all set, $name!',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Your profile has been created.\nLet\'s start your health journey.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    color: AppColors.textMuted,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: FilledButton(
                    onPressed: () => context.go('/'),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      'Start Your Journey',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
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

  // ─── Shared helpers ───────────────────────────────────────────────────

  Widget _pageTitle(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 26,
        fontWeight: FontWeight.w800,
        color: AppColors.textPrimary,
        letterSpacing: -0.5,
        height: 1.1,
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Reusable widgets
// ═══════════════════════════════════════════════════════════════════════════

// ─── Gender pill ────────────────────────────────────────────────────────

class _GenderPill extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _GenderPill({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.primary.withValues(alpha: 0.08)
                : AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected
                  ? AppColors.primary.withValues(alpha: 0.3)
                  : AppColors.divider.withValues(alpha: 0.5),
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Column(
            children: [
              Icon(icon,
                  size: 24,
                  color:
                      selected ? AppColors.primary : AppColors.textMuted),
              const SizedBox(height: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                  color: selected
                      ? AppColors.primary
                      : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Select card (goals grid) ───────────────────────────────────────────

class _SelectCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  const _SelectCard({
    required this.label,
    required this.icon,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: selected ? color.withValues(alpha: 0.08) : AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected
                ? color.withValues(alpha: 0.35)
                : AppColors.divider.withValues(alpha: 0.4),
            width: selected ? 1.5 : 1,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.1),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: selected
                    ? color.withValues(alpha: 0.15)
                    : color.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(13),
              ),
              child: Icon(icon, size: 22, color: color),
            ),
            const SizedBox(height: 10),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                color: selected ? color : AppColors.textPrimary,
                letterSpacing: -0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Condition chip (health multi-select) ───────────────────────────────

class _ConditionChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _ConditionChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isNone = label == 'None of these';
    final chipColor = isNone ? AppColors.green : AppColors.primary;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: selected
              ? chipColor.withValues(alpha: 0.08)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected
                ? chipColor.withValues(alpha: 0.3)
                : AppColors.divider.withValues(alpha: 0.4),
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon,
                size: 18,
                color: selected ? chipColor : AppColors.textMuted),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                color: selected ? chipColor : AppColors.textPrimary,
              ),
            ),
            if (selected) ...[
              const SizedBox(width: 6),
              Icon(Icons.check_rounded, size: 16, color: chipColor),
            ],
          ],
        ),
      ),
    );
  }
}

// ─── Pill chip (occupation) ─────────────────────────────────────────────

class _PillChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _PillChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary.withValues(alpha: 0.08)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: selected
                ? AppColors.primary.withValues(alpha: 0.3)
                : AppColors.divider.withValues(alpha: 0.4),
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
            color: selected ? AppColors.primary : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}

// ─── Activity card ──────────────────────────────────────────────────────

class _ActivityCard extends StatelessWidget {
  final String label;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  const _ActivityCard({
    required this.label,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary.withValues(alpha: 0.06)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected
                ? AppColors.primary.withValues(alpha: 0.3)
                : AppColors.divider.withValues(alpha: 0.4),
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: selected
                    ? AppColors.primary
                    : AppColors.surface,
                shape: BoxShape.circle,
                border: Border.all(
                  color: selected
                      ? AppColors.primary
                      : AppColors.textMuted.withValues(alpha: 0.3),
                  width: 2,
                ),
              ),
              child: selected
                  ? const Icon(Icons.check_rounded,
                      size: 14, color: Colors.white)
                  : null,
            ),
            const SizedBox(width: 14),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                    color: selected
                        ? AppColors.primary
                        : AppColors.textPrimary,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Premium measurement card ──────────────────────────────────────────

class _PremiumMeasurementCard extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String unit;
  final IconData icon;
  final String hint;
  final Color accentColor;
  final double minVal;
  final double maxVal;
  final VoidCallback? onChanged;

  const _PremiumMeasurementCard({
    required this.controller,
    required this.label,
    required this.unit,
    required this.icon,
    required this.hint,
    required this.accentColor,
    required this.minVal,
    required this.maxVal,
    this.onChanged,
  });

  @override
  State<_PremiumMeasurementCard> createState() =>
      _PremiumMeasurementCardState();
}

class _PremiumMeasurementCardState extends State<_PremiumMeasurementCard>
    with SingleTickerProviderStateMixin {
  late final FocusNode _focus;
  late final AnimationController _glowCtrl;

  @override
  void initState() {
    super.initState();
    _focus = FocusNode()..addListener(_onFocusChange);
    _glowCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  void _onFocusChange() {
    if (_focus.hasFocus) {
      _glowCtrl.forward();
    } else {
      _glowCtrl.reverse();
    }
    setState(() {});
  }

  @override
  void dispose() {
    _focus.removeListener(_onFocusChange);
    _focus.dispose();
    _glowCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final value = double.tryParse(widget.controller.text);
    final hasValue = value != null && value > 0;
    final progress = hasValue
        ? ((value - widget.minVal) / (widget.maxVal - widget.minVal))
            .clamp(0.0, 1.0)
        : 0.0;
    final focused = _focus.hasFocus;

    return AnimatedBuilder(
      animation: _glowCtrl,
      builder: (context, child) => Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: widget.accentColor
                  .withValues(alpha: _glowCtrl.value * 0.12),
              blurRadius: 24,
              spreadRadius: 2,
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: child,
      ),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        padding: EdgeInsets.fromLTRB(20, 18, 20, hasValue ? 16 : 20),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: focused
                ? widget.accentColor.withValues(alpha: 0.4)
                : hasValue
                    ? widget.accentColor.withValues(alpha: 0.15)
                    : AppColors.divider.withValues(alpha: 0.3),
            width: focused ? 1.5 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        widget.accentColor.withValues(alpha: 0.14),
                        widget.accentColor.withValues(alpha: 0.04),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child:
                      Icon(widget.icon, size: 22, color: widget.accentColor),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    widget.label,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.3,
                    ),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                  decoration: BoxDecoration(
                    color: widget.accentColor.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    widget.unit,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: widget.accentColor,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.only(left: 4),
              child: TextField(
                controller: widget.controller,
                focusNode: _focus,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
                ],
                style: TextStyle(
                  fontSize: 38,
                  fontWeight: FontWeight.w800,
                  color:
                      hasValue ? widget.accentColor : AppColors.textMuted,
                  letterSpacing: -1.5,
                  height: 1.1,
                ),
                decoration: InputDecoration(
                  hintText: widget.hint,
                  hintStyle: TextStyle(
                    fontSize: 38,
                    fontWeight: FontWeight.w300,
                    color: AppColors.textMuted.withValues(alpha: 0.15),
                    letterSpacing: -1.5,
                    height: 1.1,
                  ),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
                onChanged: (_) {
                  setState(() {});
                  widget.onChanged?.call();
                },
              ),
            ),
            if (hasValue) ...[
              const SizedBox(height: 14),
              ClipRRect(
                borderRadius: BorderRadius.circular(3),
                child: SizedBox(
                  height: 6,
                  child: LayoutBuilder(
                    builder: (context, constraints) => Stack(
                      children: [
                        Container(
                          width: constraints.maxWidth,
                          decoration: BoxDecoration(
                            color:
                                widget.accentColor.withValues(alpha: 0.06),
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.easeOutCubic,
                          width: constraints.maxWidth * progress,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                widget.accentColor
                                    .withValues(alpha: 0.6),
                                widget.accentColor
                                    .withValues(alpha: 0.25),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 5),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${widget.minVal.toInt()} ${widget.unit}',
                    style: TextStyle(
                      fontSize: 10,
                      color: AppColors.textMuted.withValues(alpha: 0.4),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    '${widget.maxVal.toInt()} ${widget.unit}',
                    style: TextStyle(
                      fontSize: 10,
                      color: AppColors.textMuted.withValues(alpha: 0.4),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ─── BMI preview card ──────────────────────────────────────────────────

class _BmiPreviewCard extends StatelessWidget {
  final double bmi;

  const _BmiPreviewCard({required this.bmi});

  @override
  Widget build(BuildContext context) {
    final (label, color) = _category(bmi);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withValues(alpha: 0.06),
            color.withValues(alpha: 0.02),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.15)),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(Icons.speed_rounded, size: 20, color: color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Body Mass Index',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textMuted,
                        letterSpacing: 0.2,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          bmi.toStringAsFixed(1),
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            color: color,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            label,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: color,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _BmiRangeBar(bmi: bmi, color: color),
        ],
      ),
    );
  }

  static (String, Color) _category(double bmi) {
    if (bmi < 18.5) return ('Underweight', const Color(0xFF30B0C7));
    if (bmi < 25) return ('Normal', AppColors.green);
    if (bmi < 30) return ('Overweight', const Color(0xFFFF9500));
    return ('Obese', AppColors.red);
  }
}

// ─── BMI range bar ─────────────────────────────────────────────────────

class _BmiRangeBar extends StatelessWidget {
  final double bmi;
  final Color color;

  const _BmiRangeBar({required this.bmi, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 10,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              final clamped = bmi.clamp(15.0, 40.0);
              final position = ((clamped - 15) / 25) * width;

              return Stack(
                clipBehavior: Clip.none,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(5),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 14,
                          child: Container(
                            height: 8,
                            color: const Color(0xFF30B0C7)
                                .withValues(alpha: 0.25),
                          ),
                        ),
                        const SizedBox(width: 2),
                        Expanded(
                          flex: 26,
                          child: Container(
                            height: 8,
                            color: AppColors.green.withValues(alpha: 0.25),
                          ),
                        ),
                        const SizedBox(width: 2),
                        Expanded(
                          flex: 20,
                          child: Container(
                            height: 8,
                            color: const Color(0xFFFF9500)
                                .withValues(alpha: 0.25),
                          ),
                        ),
                        const SizedBox(width: 2),
                        Expanded(
                          flex: 40,
                          child: Container(
                            height: 8,
                            color: AppColors.red.withValues(alpha: 0.25),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    left: (position - 6).clamp(0.0, width - 12),
                    top: -1,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border:
                            Border.all(color: Colors.white, width: 2.5),
                        boxShadow: [
                          BoxShadow(
                            color: color.withValues(alpha: 0.3),
                            blurRadius: 6,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('15',
                style: TextStyle(
                    fontSize: 9,
                    color: AppColors.textMuted.withValues(alpha: 0.5))),
            Text('18.5',
                style: TextStyle(
                    fontSize: 9,
                    color: AppColors.textMuted.withValues(alpha: 0.5))),
            Text('25',
                style: TextStyle(
                    fontSize: 9,
                    color: AppColors.textMuted.withValues(alpha: 0.5))),
            Text('30',
                style: TextStyle(
                    fontSize: 9,
                    color: AppColors.textMuted.withValues(alpha: 0.5))),
            Text('40',
                style: TextStyle(
                    fontSize: 9,
                    color: AppColors.textMuted.withValues(alpha: 0.5))),
          ],
        ),
      ],
    );
  }
}
