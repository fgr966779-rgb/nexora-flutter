import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_radii.dart';
import '../../../../core/extensions/number_format_ext.dart';
import '../../../../core/utils/haptic_service.dart';
import '../../../../core/widgets/app_button_primary.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../../dashboard/providers/dashboard_provider.dart';

/// Екран першого внеску — фінальний крок онбордингу (4 з 5).
///
/// Містить ракету з анімацією, пресети, коментар, кнопку з glow, XP +30 тост,
/// badge unlock, step indicator, валідацію, мотививні повідомлення,
/// святкувальну послідовність, жести швидкого внеску, пропозиції суми
/// залежно від цілі, категорії пресетів, розширені анімації,
/// інтерактивний прогресс-бар внеску, порівняння з іншими користувачами,
/// розширені категорії пресетів з українськими мітками,
/// анімовану послідовність внеску, мотиваційні повідомлення під час внеску,
/// виявлення жестів швидкого внеску, пропозиції суми залежно від цілі,
/// передсвяткувальне очікування з підказками, фази внеску з enum,
/// обробку з спіннером, цільові пропозиції 5%/10%/15%, мотиваційний зворотний відлік,
/// святкувальний гаптичний відгук, конфеті-превʼю, щоденна порадка.
enum _DepositPhase { idle, entering, processing, success }

class FirstDepositScreen extends ConsumerStatefulWidget {
  const FirstDepositScreen({super.key});

  @override
  ConsumerState<FirstDepositScreen> createState() => _FirstDepositScreenState();
}

class _FirstDepositScreenState extends ConsumerState<FirstDepositScreen>
    with SingleTickerProviderStateMixin {
  final _amountController = TextEditingController();
  final _commentController = TextEditingController();
  double? _selectedPreset;
  bool _isSubmitting = false;
  bool _depositSuccess = false;
  bool _showBadgeUnlock = false;
  bool _showRocketTrail = false;
  int _motivationalIndex = 0;
  bool _showMotivational = true;
  double _celebrationScale = 0.0;
  bool _showQuickPresets = false;
  String _depositCategory = 'general';
  bool _showComparison = false;
  bool _showAnticipation = false;
  _DepositPhase _depositPhase = _DepositPhase.idle;
  double _animatedProgress = 0;
  bool _showConfettiPreview = false;
  int _countdownSeconds = 0;
  Timer? _countdownTimer;
  bool _showDailyTip = false;

  static const double _minAmount = 10;
  static const double _maxAmount = 100000;
  static const int _currentStep = 4;
  static const int _totalSteps = 5;
  static const _presets = [50.0, 100.0, 200.0, 500.0];
  static const _quickPresets = [25.0, 75.0, 150.0, 300.0, 750.0, 1000.0];

  static const _presetCategories = [
    _PresetCategory(icon: Icons.savings_rounded, name: 'Загальне', amounts: [50, 100, 200, 500]),
    _PresetCategory(icon: Icons.coffee_rounded, name: 'Кава', amounts: [30, 50, 75, 100]),
    _PresetCategory(icon: Icons.fastfood_rounded, name: 'Фастфуд', amounts: [50, 75, 100, 200]),
    _PresetCategory(icon: Icons.shopping_bag_rounded, name: 'Покупки', amounts: [100, 200, 300, 500]),
    _PresetCategory(icon: Icons.card_giftcard_rounded, name: 'Подарунок', amounts: [100, 200, 500, 1000]),
    _PresetCategory(icon: Icons.directions_bus_rounded, name: 'Транспорт', amounts: [25, 50, 100, 150]),
    _PresetCategory(icon: Icons.restaurant_rounded, name: 'Кафе', amounts: [75, 150, 250, 400]),
    _PresetCategory(icon: Icons.movie_rounded, name: 'Розваги', amounts: [100, 200, 350, 500]),
    _PresetCategory(icon: Icons.medication_rounded, name: 'Здоров\'я', amounts: [50, 100, 200, 500]),
    _PresetCategory(icon: Icons.school_rounded, name: 'Навчання', amounts: [100, 250, 500, 1000]),
  ];

  static const _motivationalMessages = [
    '🚀 Кожна гривня наближає тебе до мрії!',
    '💪 Ти на правильному шляху!',
    '✨ Навіть маленький внесок — це великий крок!',
    '🎯 Фокусуйся на цілі — ти впораєшся!',
    '🔥 Регулярність важливіша за суму!',
    '💎 Скарбничка працює — ти будеш вражений!',
    '🌟 Сьогодні внески — найкращий звичка!',
    '🏆 Мрія стає ближче з кожним внеском!',
    '📈 Ти вже на ${'%'} шляху!',
    '⚡ Перший внесок — найважливіший!',
    '🌈 Маленькі кроки = велика зміна!',
    '💫 Перший крок — половина шляху!',
    '🎯 Зосередься — фініш поруч!',
  ];

  static const _depositPhaseLabels = {
    _DepositPhase.idle: '✍️ Готовий до першого внеску',
    _DepositPhase.entering: '👀 Вводиш суму — чудово!',
    _DepositPhase.processing: '⏳ Обробляємо твій внесок...',
    _DepositPhase.success: '🎉 Успіх! Святкуємо!',
  };

  static const _successMessages = [
    '🎉 Перший внесок зроблено!',
    '🌟 Ти молодець! Перший крок найважливіший!',
    '🔥 Початок покладено! Йдемо далі!',
    '💎 Вітаємо! Твоя подорож почалась!',
  ];

  static const _goalBasedSuggestions = [
    '💡 Для швидкого старту спробуй 200 грн',
    '🎯 Оптимальний внесок: 10% від цілі',
    '⚡ Зроби внесок зараз — прокачай серію!',
    '🚀 Почни з 15% — і будеш на шляху до перемоги!',
  ];

  static const _dailyTips = [
    '💡 Щоденний внесок навіть 10 грн — це 3650 грн за рік!',
    '📅 Найкращий час для внеску — одразу після зарплати',
    '🎯 Встанови конкретний день тижня для внесків',
    '📱 Увімкни нагадування — не забудь про скарбничку!',
    '💰 Спробуй відкладати 5% від кожного доходу',
    '📊 Відстежуй прогрес щотижня — візуалізація мотиває!',
    '🏃 Почни з малого — збільшуй суму кожного тижня на 10%',
    '🧠 Психологія: «заплати собі спочатку» — і залишок на витрати',
    '⚡ Автоматичний внесок = відсутність спокус витратити!',
    '🌟 Перший внесок — найважчий. Далі буде легше!',
  ];

  static const _motivationalCountdowns = [
    '⏰ Кожна хвилина затримки — це відстрочена мрія',
    '🏃 Ти на правильному шляху — зроби перший крок!',
    '💪 Твоя майбутня подяка — за цей внесок',
    '🚀 Відлік почався — час діяти!',
    '✨ Наступна секунда може змінити все',
  ];

  static const _confettiEmojis = ['🎉', '🎊', '✨', '💫', '🌟', '⭐', '🏆'];

  static const int _xpReward = 30;
  static const String _badgeName = 'Перший крок';
  static const int _coinsReward = 5;

  late AnimationController _rocketController;
  late AnimationController _trailController;
  late AnimationController _motivationalController;
  late AnimationController _pulseController;
  late AnimationController _anticipationController;
  late AnimationController _confettiController;

  @override
  void initState() {
    super.initState();
    _rocketController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500))..repeat(reverse: true);
    _trailController = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _motivationalController = AnimationController(vsync: this, duration: const Duration(milliseconds: 3000))..repeat();
    _pulseController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))..repeat(reverse: true);
    _anticipationController = AnimationController(vsync: this, duration: const Duration(milliseconds: 2000))..repeat(reverse: true);
    _confettiController = AnimationController(vsync: this, duration: const Duration(milliseconds: 2500))..repeat();
    _cycleMotivation();

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _countdownSeconds++);
    });

    Future.delayed(const Duration(milliseconds: 2000), () {
      if (mounted) setState(() => _showDailyTip = true);
    });

    Future.delayed(const Duration(milliseconds: 4000), () {
      if (mounted) setState(() => _showAnticipation = true);
    });

    Future.delayed(const Duration(milliseconds: 6000), () {
      if (mounted) setState(() => _showConfettiPreview = true);
    });
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _amountController.dispose();
    _commentController.dispose();
    _rocketController.dispose();
    _trailController.dispose();
    _motivationalController.dispose();
    _pulseController.dispose();
    _anticipationController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  void _cycleMotivation() {
    Timer.periodic(const Duration(seconds: 3), (timer) {
      if (!mounted) { timer.cancel(); return; }
      setState(() {
        _motivationalIndex = (_motivationalIndex + 1) % _motivationalMessages.length;
      });
    });
  }

  String get _currentMotivationalMessage {
    final base = _motivationalMessages[_motivationalIndex];
    final state = ref.watch(dashboardProvider);
    final progress = state.goal?.progress ?? 0;
    return base.replaceAll('${'%'}', '${(progress * 100).toStringAsFixed(0)}');
  }

  double? _validateAmount(double amount) {
    if (amount < _minAmount) return null; // спеціально для first deposit — дозволяємо мін
    if (amount > _maxAmount) return null;
    if (amount == 13) return null;
    return null;
  }

  String? _validationMessage(double amount) {
    if (amount < _minAmount) return 'Мінімальна сума — $_minAmount грн';
    if (amount > _maxAmount) return 'Максимальна сума — ${_maxAmount.toInt().formatUAH()} грн';
    if (amount == 13) return 'Може, краще 15 грн? 😄';
    return null;
  }

  void _onPresetTap(double amount) {
    HapticService.selection();
    setState(() { _selectedPreset = amount; _amountController.text = amount.toInt().toString(); _depositPhase = _DepositPhase.entering; });
  }

  void _onQuickPresetTap(double amount) {
    HapticService.coinDrop();
    setState(() { _selectedPreset = amount; _amountController.text = amount.toInt().toString(); _depositPhase = _DepositPhase.entering; });
  }

  void _onAmountChanged(String value) {
    final amount = double.tryParse(value) ?? 0;
    if (amount >= _minAmount) {
      setState(() => _depositPhase = _DepositPhase.entering);
    } else {
      setState(() => _depositPhase = _DepositPhase.idle);
    }
  }

  Future<void> _submit() async {
    final amount = double.tryParse(_amountController.text) ?? 0;
    if (amount < _minAmount) {
      AppToast.show(context, message: 'Мінімальна сума — $_minAmount грн', icon: Icons.warning_rounded, color: AppColorsPS5.warning);
      return;
    }
    final valMsg = _validationMessage(amount);
    if (valMsg != null) {
      AppToast.show(context, message: valMsg, icon: Icons.warning_rounded, color: AppColorsPS5.warning);
      return;
    }

    setState(() { _isSubmitting = true; _depositPhase = _DepositPhase.processing; });
    HapticService.mediumTap();

    // Анімація прогресу під час обробки
    for (double i = 0; i <= 1.0; i += 0.1) {
      await Future.delayed(const Duration(milliseconds: 100));
      if (mounted) setState(() => _animatedProgress = i);
    }

    final success = await ref.read(dashboardProvider.notifier).addDeposit(amount, comment: _commentController.text.trim().isEmpty ? null : _commentController.text.trim());

    if (success && mounted) {
      HapticService.success();
      // Святкувальний гаптичний паттерн
      await Future.delayed(const Duration(milliseconds: 100));
      HapticService.mediumTap();
      await Future.delayed(const Duration(milliseconds: 100));
      HapticService.lightTap();

      setState(() {
        _depositSuccess = true;
        _showRocketTrail = true;
        _trailController.forward();
        _celebrationScale = 1.0;
        _depositPhase = _DepositPhase.success;
      });
      AppToast.show(context, message: 'Перший внесок — +${amount.toInt().formatUAH()} грн! XP +$_xpReward', icon: Icons.rocket_launch_rounded, color: AppColorsPS5.success);
      await Future.delayed(const Duration(milliseconds: 1500));
      if (mounted) {
        setState(() => _showBadgeUnlock = true);
        AppToast.show(context, message: '🏆 Значок «$_badgeName» розблоковано!', icon: Icons.emoji_events_rounded, color: AppColorsPS5.xp);
      }
      await Future.delayed(const Duration(milliseconds: 1000));
      if (mounted) context.go('/dashboard');
    } else if (mounted) {
      HapticService.error();
      setState(() { _isSubmitting = false; _depositPhase = _DepositPhase.idle; });
      AppToast.show(context, message: 'Помилка. Спробуй ще раз.', icon: Icons.error_rounded, color: AppColorsPS5.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final inputAmount = double.tryParse(_amountController.text) ?? 0;
    final validationError = inputAmount > 0 ? _validationMessage(inputAmount) : null;
    final isValid = inputAmount >= _minAmount && validationError == null;

    if (_depositSuccess) return _buildSuccessView(isLight);

    return Scaffold(
      backgroundColor: isLight ? AppColorsMonitor.background : AppColorsPS5.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: Spacing.base),
          child: Column(
            children: [
              const SizedBox(height: Spacing.lg),
              _StepIndicator(current: _currentStep, total: _totalSteps, isLight: isLight),
              const SizedBox(height: Spacing.xl),
              Align(alignment: Alignment.centerLeft, child: GestureDetector(onTap: () { HapticService.lightTap(); context.go('/onboarding'); }, child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.arrow_back_rounded, color: isLight ? AppColorsMonitor.textSecondary : AppColorsPS5.textSecondary, size: 20), const SizedBox(width: Spacing.xs), Text('Назад', style: AppTypography.labelMedium.copyWith(color: isLight ? AppColorsMonitor.textSecondary : AppColorsPS5.textSecondary))]))),
              const SizedBox(height: Spacing.xxl),
              // ── Іконка ракети (bounce + glow + trail) ────
              AnimatedBuilder(animation: _rocketController, builder: (context, child) {
                final t = _rocketController.value;
                final yOffset = -10 * (1 - t);
                final glowOpacity = 0.3 + 0.2 * t;
                final rotation = 0.05 * math.sin(t * math.pi * 2);
                return Transform.translate(offset: Offset(0, yOffset), child: Transform.rotate(angle: rotation, child: child));
              }, child: Container(decoration: BoxDecoration(shape: BoxShape.circle, boxShadow: [BoxShadow(color: (isLight ? AppColorsMonitor.accent : AppColorsPS5.accent).withOpacity(0.3), blurRadius: 36, spreadRadius: 10)]), child: Icon(Icons.rocket_launch_rounded, size: 80, color: isLight ? AppColorsMonitor.accent : AppColorsPS5.accent))).animate().fadeIn(duration: 500.ms).scale(duration: 600.ms, curve: Curves.easeOutBack),
              const SizedBox(height: Spacing.lg),
              Text('Час першого внеску!', style: AppTypography.displaySmall.copyWith(color: isLight ? AppColorsMonitor.textPrimary : AppColorsPS5.textPrimary), textAlign: TextAlign.center).animate().fadeIn(duration: 500.ms, delay: 100.ms),
              const SizedBox(height: Spacing.sm),
              Text('Навіть маленька сума — це початок\nчогось великого 🚀', style: AppTypography.bodyMedium.copyWith(color: isLight ? AppColorsMonitor.textSecondary : AppColorsPS5.textSecondary), textAlign: TextAlign.center).animate().fadeIn(duration: 500.ms, delay: 200.ms),
              // ── Фаза внеску ────────────────────────
              const SizedBox(height: Spacing.sm),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: Spacing.sm, vertical: Spacing.xs),
                decoration: BoxDecoration(color: (isLight ? AppColorsMonitor.accent : AppColorsPS5.accent).withOpacity(0.06), borderRadius: BorderRadius.circular(Radii.circular)),
                child: Text(_depositPhaseLabels[_depositPhase] ?? '', style: AppTypography.labelSmall.copyWith(color: isLight ? AppColorsMonitor.accent : AppColorsPS5.accent)),
              ),
              // ── Мотиваційне повідомлення (циклічне) ──
              const SizedBox(height: Spacing.sm),
              AnimatedBuilder(animation: _motivationalController, builder: (_, __) {
                final fade = 0.5 + 0.5 * math.sin(_motivationalController.value * math.pi * 2);
                return Opacity(opacity: fade, child: Text(_currentMotivationalMessage, style: AppTypography.labelSmall.copyWith(color: isLight ? AppColorsMonitor.accent : AppColorsPS5.accent), textAlign: TextAlign.center));
              }),
              // ── Щоденна порадка з анімацією ────────────
              if (_showDailyTip) _buildDailyTipCard(isLight),
              // ── Мотиваційний зворотний відлік ────────────
              Container(
                margin: const EdgeInsets.only(top: Spacing.xs),
                padding: const EdgeInsets.symmetric(horizontal: Spacing.sm, vertical: 2),
                decoration: BoxDecoration(color: (isLight ? AppColorsMonitor.accent : AppColorsPS5.accent).withOpacity(0.03), borderRadius: BorderRadius.circular(Radii.sm)),
                child: Text(_motivationalCountdowns[_countdownSeconds % _motivationalCountdowns.length], style: AppTypography.labelSmall.copyWith(color: (isLight ? AppColorsMonitor.textHint : AppColorsPS5.textHint), fontSize: 9, fontStyle: FontStyle.italic)),
              ),
              const SizedBox(height: Spacing.xxl),
              // ── Поле суми ──────────────────────────
              AppTextField(hint: 'Введи суму (мін. $_minAmount грн)', controller: _amountController, keyboardType: const TextInputType.numberWithOptions(decimal: true), isLightTheme: isLight, prefixIcon: Icon(Icons.attach_money_rounded, color: isLight ? AppColorsMonitor.accent : AppColorsPS5.accent), onChanged: (v) { setState(() {}); _onAmountChanged(v); }).animate().slideY(begin: 0.15, end: 0, duration: 500.ms, delay: 300.ms),
              if (validationError != null) Padding(padding: const EdgeInsets.only(top: Spacing.xs), child: Row(children: [Icon(Icons.error_outline_rounded, color: AppColorsPS5.error, size: 14), const SizedBox(width: Spacing.xs), Expanded(child: Text(validationError, style: AppTypography.labelSmall.copyWith(color: AppColorsPS5.error)))])),
              if (inputAmount > 0) Container(margin: const EdgeInsets.only(top: Spacing.sm), padding: const EdgeInsets.symmetric(horizontal: Spacing.base, vertical: Spacing.sm), decoration: BoxDecoration(color: (isLight ? AppColorsMonitor.accent : AppColorsPS5.accent).withOpacity(0.08), borderRadius: BorderRadius.circular(Radii.md)), child: Text('${inputAmount.toInt().formatUAH()} грн', style: AppTypography.monoLarge.copyWith(color: isValid ? (isLight ? AppColorsMonitor.accent : AppColorsPS5.accent) : AppColorsPS5.error), textAlign: TextAlign.center)).animate().scale(duration: 300.ms, curve: Curves.easeOutBack),
              // ── Цільові пропозиції (5%/10%/15%) ──────
              _buildGoalSuggestions(isLight),
              const SizedBox(height: Spacing.base),
              // ── Категорії пресетів ─────────────────────
              _buildPresetCategories(isLight),
              // ── Пресети ───────────────────────────
              Wrap(spacing: Spacing.sm, runSpacing: Spacing.sm, children: _presets.map((amount) {
                final isSelected = _selectedPreset == amount;
                return GestureDetector(onTap: () => _onPresetTap(amount), child: AnimatedContainer(duration: const Duration(milliseconds: 200), padding: const EdgeInsets.symmetric(horizontal: Spacing.lg, vertical: Spacing.md), decoration: BoxDecoration(color: isSelected ? (isLight ? AppColorsMonitor.accent : AppColorsPS5.accent) : Colors.transparent, borderRadius: BorderRadius.circular(Radii.circular), border: Border.all(color: isSelected ? (isLight ? AppColorsMonitor.accent : AppColorsPS5.accent) : (isLight ? AppColorsMonitor.border : AppColorsPS5.border), width: 1.5), boxShadow: isSelected ? [BoxShadow(color: (isLight ? AppColorsMonitor.accent : AppColorsPS5.accent).withOpacity(0.3), blurRadius: 12)] : null), child: Text('${amount.toInt().formatUAH()} грн', style: AppTypography.labelLarge.copyWith(color: isSelected ? Colors.white : (isLight ? AppColorsMonitor.textPrimary : AppColorsPS5.textPrimary), fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500, fontSize: isSelected ? 16 : 14))));
              }).toList()).animate().fadeIn(duration: 500.ms, delay: 400.ms),
              // ── Швидкі пресети ────────────────────────
              GestureDetector(
                onTap: () { HapticService.selection(); setState(() => _showQuickPresets = !_showQuickPresets); },
                child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(_showQuickPresets ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded, color: isLight ? AppColorsMonitor.accent : AppColorsPS5.accent, size: 16),
                  const SizedBox(width: Spacing.xs),
                  Text('⚡ Швидкий вибір (${_quickPresets.length} варіантів)', style: AppTypography.labelSmall.copyWith(color: isLight ? AppColorsMonitor.textHint : AppColorsPS5.textHint)),
                ]),
              ).animate().fadeIn(duration: 300.ms, delay: 500.ms),
              if (_showQuickPresets)
                Container(
                  margin: const EdgeInsets.only(bottom: Spacing.sm),
                  padding: const EdgeInsets.symmetric(horizontal: Spacing.base, vertical: Spacing.xs),
                  decoration: BoxDecoration(color: (isLight ? AppColorsMonitor.card : AppColorsPS5.card).withOpacity(0.5), borderRadius: BorderRadius.circular(Radii.md), border: Border.all(color: (isLight ? AppColorsMonitor.border : AppColorsPS5.border).withOpacity(0.3))),
                  child: Wrap(spacing: Spacing.xs, runSpacing: Spacing.xs, children: _quickPresets.map((amount) => GestureDetector(
                    onTap: () => _onQuickPresetTap(amount),
                    child: Container(padding: const EdgeInsets.symmetric(horizontal: Spacing.sm, vertical: 4), decoration: BoxDecoration(color: Colors.transparent, borderRadius: BorderRadius.circular(Radii.sm), border: Border.all(color: (isLight ? AppColorsMonitor.border : AppColorsPS5.border).withOpacity(0.5), width: 1)), child: Text('${amount.toInt()}', style: AppTypography.labelSmall.copyWith(color: isLight ? AppColorsMonitor.textSecondary : AppColorsPS5.textSecondary))),
                  )).toList()),
                ).animate().fadeIn(duration: 300.ms, delay: 600.ms),
              const SizedBox(height: Spacing.xxl),
              // ── Поле коментаря ────────────────────
              AppTextField(hint: 'Коментар (необов\'язково)', controller: _commentController, isLightTheme: isLight, prefixIcon: Icon(Icons.comment_rounded, color: isLight ? AppColorsMonitor.textSecondary : AppColorsPS5.textSecondary)).animate().slideY(begin: 0.1, end: 0, duration: 500.ms, delay: 500.ms),
              // ── Швидкі шаблони коментарів ─────────
              AnimatedSize(
                duration: const Duration(milliseconds: 300),
                child: Container(
                  margin: const EdgeInsets.only(top: Spacing.xs),
                  padding: const EdgeInsets.symmetric(horizontal: Spacing.base),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('📌 Швидкі коментарі:', style: AppTypography.labelSmall.copyWith(color: isLight ? AppColorsMonitor.textHint : AppColorsPS5.textHint)),
                      const SizedBox(height: Spacing.xs),
                      Wrap(spacing: Spacing.xs, runSpacing: Spacing.xs, children: [
                        _buildCommentTemplate('Перший внесок! 🎉', onTap: () => _commentController.text = 'Перший внесок! 🎉'),
                        _buildCommentTemplate('Щодня практика', onTap: () => _commentController.text = 'Щодня практика'),
                        _buildCommentTemplate('Кавова копійка → скарбничка', onTap: () => _commentController.text = 'Кавова копійка → скарбничка'),
                        _buildCommentTemplate('За мрією!', onTap: () => _commentController.text = 'За мрією!'),
                        _buildCommentTemplate('Автоматичний внесок', onTap: () => _commentController.text = 'Автоматичний внесок'),
                        _buildCommentTemplate('День зарплати 💵', onTap: () => _commentController.text = 'День зарплати 💵'),
                        _buildCommentTemplate('Безмовні заощадження 🤫', onTap: () => _commentController.text = 'Безмовні заощадження 🤫'),
                      ]),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: Spacing.xs),
              // ── Порада ────────────────────────────────
              AnimatedBuilder(animation: _pulseController, builder: (_, __) {
                final pulse = 0.6 + 0.4 * math.sin(_pulseController.value * math.pi);
                return Opacity(opacity: pulse, child: Text('💡 Порада: почни з $_minAmount грн — головне регулярність!', style: AppTypography.labelSmall.copyWith(color: isLight ? AppColorsMonitor.textHint : AppColorsPS5.textHint)));
              }),
              // ── Пропозиція залежно від цілі ──────────
              const SizedBox(height: Spacing.sm),
              AnimatedBuilder(animation: _anticipationController, builder: (_, __) {
                final fade = 0.5 + 0.5 * math.sin(_anticipationController.value * math.pi);
                return Opacity(opacity: _showAnticipation ? fade : 0, child: Text(_goalBasedSuggestions[_motivationalIndex % _goalBasedSuggestions.length], style: AppTypography.labelSmall.copyWith(color: isLight ? AppColorsMonitor.accent : AppColorsPS5.accent, fontStyle: FontStyle.italic)));
              }),
              // ── Передсвяткувальне очікування ─────────
              if (_showAnticipation && isValid)
                Container(
                  margin: const EdgeInsets.only(top: Spacing.sm),
                  padding: const EdgeInsets.all(Spacing.sm),
                  decoration: BoxDecoration(color: AppColorsPS5.success.withOpacity(0.06), borderRadius: BorderRadius.circular(Radii.md), border: Border.all(color: AppColorsPS5.success.withOpacity(0.12))),
                  child: Row(children: [
                    Icon(Icons.celebration_rounded, color: AppColorsPS5.success, size: 16),
                    const SizedBox(width: Spacing.xs),
                    Expanded(child: Text('🎊 Після натискання — святкування з конфеті та XP!', style: AppTypography.labelSmall.copyWith(color: AppColorsPS5.success))),
                  ]),
                ).animate().fadeIn(duration: 400.ms),
              // ── Конфеті-превʼю з анімацією ─────────────
              if (_showConfettiPreview && isValid) _buildConfettiPreview(),
              // ── Статистика успіху першого внеску ────────
              const SizedBox(height: Spacing.xs),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: Spacing.sm, vertical: Spacing.xs),
                decoration: BoxDecoration(color: AppColorsPS5.xp.withOpacity(0.04), borderRadius: BorderRadius.circular(Radii.sm)),
                child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                  Text('XP +$_xpReward', style: AppTypography.labelSmall.copyWith(color: AppColorsPS5.xp, fontWeight: FontWeight.w600)),
                  Text('🪙 +$_coinsReward', style: AppTypography.labelSmall.copyWith(color: AppColorsPS5.coin, fontWeight: FontWeight.w600)),
                  Text('🏅 $_badgeName', style: AppTypography.labelSmall.copyWith(color: AppColorsPS5.accent, fontWeight: FontWeight.w600)),
                ]),
              ),
              // ── Порівняння ────────────────────────────
              const SizedBox(height: Spacing.sm),
              GestureDetector(
                onTap: () { HapticService.selection(); setState(() => _showComparison = !_showComparison); },
                child: Text('📊 Порівняння з іншими користувачами', style: AppTypography.labelSmall.copyWith(color: isLight ? AppColorsMonitor.accent : AppColorsPS5.accent, decoration: TextDecoration.underline)),
              ),
              if (_showComparison) _buildComparisonCard(isLight),
              // ── Прогрес обробки ─────────────────────────
              if (_depositPhase == _DepositPhase.processing)
                Container(
                  margin: const EdgeInsets.only(top: Spacing.sm),
                  child: Column(children: [
                    ClipRRect(borderRadius: BorderRadius.circular(4), child: LinearProgressIndicator(value: _animatedProgress, minHeight: 6)),
                    const SizedBox(height: Spacing.xs),
                    Text('Обробка: ${(_animatedProgress * 100).toInt()}%', style: AppTypography.labelSmall.copyWith(color: isLight ? AppColorsMonitor.accent : AppColorsPS5.accent)),
                  ]),
                ),
              const SizedBox(height: Spacing.xxl),
              // ── Кнопка внеску (glow + pulse) ────────
              AppButtonPrimary(label: 'Зробити перший внесок!', onPressed: isValid && !_isSubmitting ? _submit : null, isDisabled: !isValid || _isSubmitting, isLoading: _isSubmitting, showGlow: isValid, showPulse: isValid, icon: Icons.rocket_launch_rounded, isLightTheme: isLight).animate().fadeIn(duration: 500.ms, delay: 600.ms),
              const SizedBox(height: Spacing.xxxl),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGoalSuggestions(bool isLight) {
    final state = ref.watch(dashboardProvider);
    final target = state.goal?.targetAmount ?? 10000;
    final pct5 = (target * 0.05).clamp(10, 999999).toInt();
    final pct10 = (target * 0.10).clamp(10, 999999).toInt();
    final pct15 = (target * 0.15).clamp(10, 999999).toInt();
    final pct20 = (target * 0.20).clamp(10, 999999).toInt();
    final accent = isLight ? AppColorsMonitor.accent : AppColorsPS5.accent;

    return Container(
      margin: const EdgeInsets.only(top: Spacing.sm),
      padding: const EdgeInsets.symmetric(horizontal: Spacing.base, vertical: Spacing.sm),
      decoration: BoxDecoration(color: accent.withOpacity(0.04), borderRadius: BorderRadius.circular(Radii.md), border: Border.all(color: accent.withOpacity(0.08))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('🎯 Пропозиції залежно від цілі (${target.toInt().formatUAH()} грн):', style: AppTypography.labelSmall.copyWith(color: isLight ? AppColorsMonitor.textHint : AppColorsPS5.textHint, fontWeight: FontWeight.w600)),
        const SizedBox(height: Spacing.xs),
        Wrap(spacing: Spacing.xs, runSpacing: Spacing.xs, children: [
          _buildGoalChip('5% — $pct5 грн', pct5.toDouble(), isLight),
          _buildGoalChip('10% — $pct10 грн', pct10.toDouble(), isLight),
          _buildGoalChip('15% — $pct15 грн', pct15.toDouble(), isLight),
          _buildGoalChip('20% — $pct20 грн', pct20.toDouble(), isLight),
        ]),
        const SizedBox(height: Spacing.xs),
        Text('💡 Рекомендовано: 10% для стабільного прогресу', style: AppTypography.labelSmall.copyWith(color: accent.withOpacity(0.7), fontSize: 10, fontStyle: FontStyle.italic)),
      ]),
    );
  }

  Widget _buildDailyTipCard(bool isLight) {
    final tip = _dailyTips[_countdownSeconds % _dailyTips.length];
    return Container(
      margin: const EdgeInsets.only(top: Spacing.xs),
      padding: const EdgeInsets.all(Spacing.sm),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [AppColorsPS5.coin.withOpacity(0.06), AppColorsPS5.coin.withOpacity(0.02)]),
        borderRadius: BorderRadius.circular(Radii.md),
        border: Border.all(color: AppColorsPS5.coin.withOpacity(0.12)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(Icons.wb_sunny_rounded, color: AppColorsPS5.coin, size: 14),
          const SizedBox(width: Spacing.xs),
          Text('📌 Порадка дня', style: AppTypography.labelSmall.copyWith(color: AppColorsPS5.coin, fontWeight: FontWeight.w600)),
        ]),
        const SizedBox(height: Spacing.xs),
        Text(tip, style: AppTypography.labelSmall.copyWith(color: isLight ? AppColorsMonitor.textSecondary : AppColorsPS5.textSecondary, fontSize: 11)),
      ]),
    ).animate().fadeIn(duration: 400.ms);
  }

  Widget _buildComparisonCard(bool isLight) {
    return Container(
      margin: const EdgeInsets.only(top: Spacing.sm),
      padding: const EdgeInsets.all(Spacing.base),
      decoration: BoxDecoration(color: (isLight ? AppColorsMonitor.card : AppColorsPS5.card), borderRadius: BorderRadius.circular(Radii.md), border: Border.all(color: isLight ? AppColorsMonitor.border : AppColorsPS5.border)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('📊 Статистика користувачів', style: AppTypography.labelSmall.copyWith(color: isLight ? AppColorsMonitor.textPrimary : AppColorsPS5.textPrimary, fontWeight: FontWeight.w600)),
        const SizedBox(height: Spacing.sm),
        _buildComparisonRow('Середній перший внесок', '150 грн', isLight),
        _buildComparisonRow('Топ-10% почали з', '200+ грн', isLight),
        _buildComparisonRow('Найбільший внесок', '5000 грн 🏆', isLight),
        _buildComparisonRow('Середній час до цілі', '45 днів', isLight),
        const SizedBox(height: Spacing.xs),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: Spacing.sm, vertical: Spacing.xs),
          decoration: BoxDecoration(color: AppColorsPS5.success.withOpacity(0.06), borderRadius: BorderRadius.circular(Radii.sm)),
          child: Text('🌟 Ти будеш у топ-25% з першого внеску!', style: AppTypography.labelSmall.copyWith(color: AppColorsPS5.success)),
        ),
      ]),
    ).animate().fade(duration: 300.ms);
  }

  Widget _buildComparisonRow(String label, String value, bool isLight) {
    return Padding(
      padding: const EdgeInsets.only(bottom: Spacing.xs),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(label, style: AppTypography.labelSmall.copyWith(color: isLight ? AppColorsMonitor.textSecondary : AppColorsPS5.textSecondary, fontSize: 11)),
        Text(value, style: AppTypography.labelSmall.copyWith(color: isLight ? AppColorsMonitor.textPrimary : AppColorsPS5.textPrimary, fontWeight: FontWeight.w600, fontSize: 11)),
      ]),
    );
  }

  Widget _buildConfettiPreview() {
    return Container(
      margin: const EdgeInsets.only(top: Spacing.xs),
      padding: const EdgeInsets.symmetric(horizontal: Spacing.base, vertical: Spacing.sm),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [AppColorsPS5.coin.withOpacity(0.06), AppColorsPS5.xp.withOpacity(0.04)]),
        borderRadius: BorderRadius.circular(Radii.md),
        border: Border.all(color: AppColorsPS5.coin.withOpacity(0.12)),
      ),
      child: Column(children: [
        Text('🎊 Попередній перегляд святкування', style: AppTypography.labelSmall.copyWith(color: AppColorsPS5.coin, fontWeight: FontWeight.w600)),
        const SizedBox(height: Spacing.xs),
        AnimatedBuilder(animation: _confettiController, builder: (_, __) {
          final idx = (_confettiController.value * _confettiEmojis.length).floor() % _confettiEmojis.length;
          return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Text(_confettiEmojis[idx], style: const TextStyle(fontSize: 16)),
            const SizedBox(width: Spacing.sm),
            Text(_confettiEmojis[(idx + 2) % _confettiEmojis.length], style: const TextStyle(fontSize: 16)),
            const SizedBox(width: Spacing.sm),
            Text(_confettiEmojis[(idx + 4) % _confettiEmojis.length], style: const TextStyle(fontSize: 16)),
            const SizedBox(width: Spacing.sm),
            Text(_confettiEmojis[(idx + 6) % _confettiEmojis.length], style: const TextStyle(fontSize: 16)),
          ]);
        }),
        const SizedBox(height: Spacing.xs),
        Text('Натисни кнопку — і магія почнеться! ✨', style: AppTypography.labelSmall.copyWith(color: AppColorsPS5.coin.withOpacity(0.8), fontSize: 10, fontStyle: FontStyle.italic)),
      ]),
    ).animate().fadeIn(duration: 300.ms);
  }

  Widget _buildGoalChip(String label, double amount, bool isLight) {
    return GestureDetector(
      onTap: () => _onPresetTap(amount),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: Spacing.sm, vertical: 4),
        decoration: BoxDecoration(color: (isLight ? AppColorsMonitor.accent : AppColorsPS5.accent).withOpacity(0.08), borderRadius: BorderRadius.circular(Radii.circular), border: Border.all(color: (isLight ? AppColorsMonitor.accent : AppColorsPS5.accent).withOpacity(0.15))),
        child: Text(label, style: AppTypography.labelSmall.copyWith(color: isLight ? AppColorsMonitor.accent : AppColorsPS5.accent, fontWeight: FontWeight.w600, fontSize: 11)),
      ),
    );
  }

  Widget _buildCommentTemplate(String text, {required VoidCallback onTap}) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    return GestureDetector(
      onTap: () { HapticService.selection(); onTap(); },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: Spacing.sm, vertical: 4),
        decoration: BoxDecoration(color: (isLight ? AppColorsMonitor.accent : AppColorsPS5.accent).withOpacity(0.06), borderRadius: BorderRadius.circular(Radii.circular), border: Border.all(color: (isLight ? AppColorsMonitor.accent : AppColorsPS5.accent).withOpacity(0.12))),
        child: Text(text, style: AppTypography.labelSmall.copyWith(color: isLight ? AppColorsMonitor.accent : AppColorsPS5.accent, fontSize: 11)),
      ),
    );
  }

  Widget _buildPresetCategories(bool isLight) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: _presetCategories.map((cat) {
        return GestureDetector(
          onTap: () { HapticService.selection(); setState(() => _depositCategory = cat.name); },
          child: AnimatedContainer(duration: const Duration(milliseconds: 200), margin: const EdgeInsets.only(right: Spacing.xs), padding: const EdgeInsets.symmetric(horizontal: Spacing.sm, vertical: 6), decoration: BoxDecoration(color: _depositCategory == cat.name ? (isLight ? AppColorsMonitor.accent : AppColorsPS5.accent) : Colors.transparent, borderRadius: BorderRadius.circular(Radii.circular), border: Border.all(color: _depositCategory == cat.name ? (isLight ? AppColorsMonitor.accent : AppColorsPS5.accent) : (isLight ? AppColorsMonitor.border : AppColorsPS5.border).withOpacity(0.4), width: 1.5)),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(cat.icon, color: _depositCategory == cat.name ? Colors.white : (isLight ? AppColorsMonitor.textSecondary : AppColorsPS5.textSecondary), size: 12),
            const SizedBox(width: 4),
            Text(cat.name, style: AppTypography.labelSmall.copyWith(color: _depositCategory == cat.name ? Colors.white : (isLight ? AppColorsMonitor.textPrimary : AppColorsPS5.textPrimary), fontSize: 11)),
          ]),
        ),
      }).toList()),
    ).animate().fadeIn(duration: 300.ms, delay: 350.ms);
  }

  Widget _buildSuccessView(bool isLight) {
    return Scaffold(
      backgroundColor: isLight ? AppColorsMonitor.background : AppColorsPS5.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(Spacing.base),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: Spacing.xxl),
                TweenAnimationBuilder<double>(tween: Tween(begin: 0, end: 1.0), duration: const Duration(milliseconds: 800), curve: Curves.elasticOut, builder: (_, scale) {
                  return Transform.scale(scale: scale, child: Container(width: 130, height: 130, decoration: BoxDecoration(shape: BoxShape.circle, gradient: LinearGradient(colors: [AppColorsPS5.success, AppColorsPS5.success.withOpacity(0.7)], begin: Alignment.topLeft, end: Alignment.bottomRight), boxShadow: [BoxShadow(color: AppColorsPS5.success.withOpacity(0.3), blurRadius: 40, spreadRadius: 8)]), child: const Icon(Icons.check_rounded, color: Colors.white, size: 64)));
                }),
                const SizedBox(height: Spacing.xxl),
                Text('Вітаємо! 🎉', style: AppTypography.displaySmall.copyWith(color: isLight ? AppColorsMonitor.textPrimary : AppColorsPS5.textPrimary), textAlign: TextAlign.center).animate().fadeIn(duration: 500.ms, delay: 400.ms),
                const SizedBox(height: Spacing.sm),
                Text('Твій перший крок до мрії зроблено!\nТи молодець! 💪', style: AppTypography.bodyLarge.copyWith(color: isLight ? AppColorsMonitor.textSecondary : AppColorsPS5.textSecondary), textAlign: TextAlign.center).animate().fadeIn(duration: 500.ms, delay: 600.ms),
                const SizedBox(height: Spacing.xl),
                Container(padding: const EdgeInsets.symmetric(horizontal: Spacing.lg, vertical: Spacing.md), decoration: BoxDecoration(color: AppColorsPS5.xp.withOpacity(0.1), borderRadius: BorderRadius.circular(Radii.lg), border: Border.all(color: AppColorsPS5.xp.withOpacity(0.2))), child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.star_rounded, color: AppColorsPS5.xp, size: 22), const SizedBox(width: Spacing.sm), Text('XP +$_xpReward', style: AppTypography.labelLarge.copyWith(color: AppColorsPS5.xp, fontWeight: FontWeight.w700))])).animate().scale(duration: 500.ms, delay: 800.ms, curve: Curves.easeOutBack),
                const SizedBox(height: Spacing.md),
                Container(padding: const EdgeInsets.symmetric(horizontal: Spacing.lg, vertical: Spacing.md), decoration: BoxDecoration(color: AppColorsPS5.coin.withOpacity(0.1), borderRadius: BorderRadius.circular(Radii.lg), border: Border.all(color: AppColorsPS5.coin.withOpacity(0.2))), child: Row(mainAxisSize: MainAxisSize.min, children: [const Icon(Icons.monetization_on_rounded, color: AppColorsPS5.coin, size: 22), const SizedBox(width: Spacing.sm), Text('Монети +$_coinsReward', style: AppTypography.labelLarge.copyWith(color: AppColorsPS5.coin, fontWeight: FontWeight.w700))])).animate().scale(duration: 500.ms, delay: 900.ms, curve: Curves.easeOutBack),
                const SizedBox(height: Spacing.md),
                Container(padding: const EdgeInsets.symmetric(horizontal: Spacing.lg, vertical: Spacing.sm), decoration: BoxDecoration(color: AppColorsPS5.accent.withOpacity(0.08), borderRadius: BorderRadius.circular(Radii.md), border: Border.all(color: AppColorsPS5.accent.withOpacity(0.15))), child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.local_fire_department_rounded, color: AppColorsPS5.accent, size: 18), const SizedBox(width: Spacing.sm), Text('🔥 Серія: 1 день!', style: AppTypography.labelMedium.copyWith(color: AppColorsPS5.accent, fontWeight: FontWeight.w600))])).animate().scale(duration: 500.ms, delay: 1000.ms, curve: Curves.easeOutBack),
                if (_showBadgeUnlock) Padding(padding: const EdgeInsets.only(top: Spacing.md), child: Container(padding: const EdgeInsets.symmetric(horizontal: Spacing.lg, vertical: Spacing.md), decoration: BoxDecoration(color: AppColorsPS5.coin.withOpacity(0.1), borderRadius: BorderRadius.circular(Radii.lg), border: Border.all(color: AppColorsPS5.coin.withOpacity(0.2))), child: Row(mainAxisSize: MainAxisSize.min, children: [const Icon(Icons.emoji_events_rounded, color: AppColorsPS5.coin, size: 22), const SizedBox(width: Spacing.sm), Text('Значок «$_badgeName»', style: AppTypography.labelLarge.copyWith(color: AppColorsPS5.coin, fontWeight: FontWeight.w700))])).animate().scale(duration: 500.ms, curve: Curves.easeOutBack)),
                const SizedBox(height: Spacing.xxxl),
                AppButtonPrimary(label: 'Перейти до дашборду', icon: Icons.arrow_forward_rounded, isLightTheme: isLight, onPressed: () => context.go('/dashboard')).animate().fadeIn(duration: 500.ms, delay: 1200.ms),
                const SizedBox(height: Spacing.xl),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StepIndicator extends StatelessWidget {
  const _StepIndicator({required this.current, required this.total, required this.isLight});
  final int current;
  final int total;
  final bool isLight;
  static const _stepLabels = ['Обери тему', 'Назва', 'Сума', 'Внесок', 'Готово!'];

  @override
  Widget build(BuildContext context) {
    final accent = isLight ? AppColorsMonitor.accent : AppColorsPS5.accent;
    final border = isLight ? AppColorsMonitor.border : AppColorsPS5.border;
    return Column(
      children: [
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          for (int i = 1; i <= total; i++) ...[
            AnimatedContainer(duration: const Duration(milliseconds: 300), width: i == current ? 32 : 10, height: 10, decoration: BoxDecoration(color: i <= current ? accent : border, borderRadius: BorderRadius.circular(5), boxShadow: i == current ? [BoxShadow(color: accent.withOpacity(0.3), blurRadius: 8)] : null)),
            if (i < total) Container(width: i < current ? 12 : 8, height: 2, color: i < current ? accent.withOpacity(0.5) : border),
          ],
        ]),
        const SizedBox(height: Spacing.xs),
        Text('Крок $current з $total — ${_stepLabels[current - 1]}', style: AppTypography.labelSmall.copyWith(color: isLight ? AppColorsMonitor.textSecondary : AppColorsPS5.textSecondary)),
      ],
    );
  }
}
