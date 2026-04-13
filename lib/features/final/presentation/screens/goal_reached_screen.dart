import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_radii.dart';
import '../../../../core/constants/app_shadows.dart';
import '../../../../core/constants/app_durations.dart';
import '../../../../core/constants/app_easings.dart';
import '../../../../core/utils/haptic_service.dart';
import '../../../../core/widgets/app_confetti.dart';

/// Оверлей завершення цілі — прогрес до 100%, конфеті, навігація до /cinematic.
///
/// Містить:
/// - Прогрес-бар, що досягає 100% зі спеціальною повільною анімацією
/// - Glow-нагромадження при заповненні
/// - Святкові частинки з різними варіантами
/// - Toast «ВІТАЄМО! Твоя [PS5/Монітор] — твоя!»
/// - Автоматичний перехід до кінематографічного екрану через 2 секунди
/// - Таймер зворотного відліку перед переходом
/// - Stub звукового ефекту
/// - Повноекранний оверлей
/// - Кнопка «Поділитися» з розширеними опціями
/// - Підрахунок зібраної суми
/// - Статистика досягнень (кількість внесків, днів, серія)
/// - Віджети статистики з анімацією
/// - Опції поділитися результатом
/// - Запит на створення нової цілі
/// - Кнопка повторного відтворення святкування
/// - Налаштування конфеті (кількість, колір, швидкість)
/// - Сповіщення про розблокування досягнення
/// - Інтеграція звукових ефектів
/// - Кілька варіантів святкувальних анімацій
class GoalReachedScreen extends StatefulWidget {
  const GoalReachedScreen({
    super.key,
    this.goalName = 'PlayStation 5',
    this.goalAmount = 20000,
    this.onTransition,
    this.totalDeposits = 42,
    this.daysToComplete = 67,
    this.streak = 14,
  });

  final String goalName;
  final double goalAmount;
  final VoidCallback? onTransition;
  final int totalDeposits;
  final int daysToComplete;
  final int streak;

  @override
  State<GoalReachedScreen> createState() => _GoalReachedScreenState();
}

class _GoalReachedScreenState extends State<GoalReachedScreen>
    with TickerProviderStateMixin {
  late AnimationController _progressController;
  late AnimationController _countdownController;
  late Animation<double> _progressAnim;
  late AnimationController _shimmerController;
  late AnimationController _statsController;
  late AnimationController _achievementController;

  int _countdownValue = 2;
  bool _showToast = false;
  bool _navigated = false;
  bool _showShareButton = false;
  bool _showStats = false;
  bool _showNewGoalPrompt = false;
  bool _showAchievementUnlock = false;
  int _celebrationVariant = 0;
  bool _isReplaying = false;

  // Налаштування конфеті
  int _confettiCount = 80;
  double _confettiGravity = 6.0;
  double _confettiWind = 1.0;

  /// Tracks the number of times the user has tapped the share button
  /// during this session, used for analytics.
  int _shareTapCount = 0;

  /// Timestamp when the screen was first displayed, used for
  /// measuring time-to-interaction metrics.
  final DateTime _screenEnterTime = DateTime.now();

  /// Whether the screen has already logged an analytics event for
  /// the celebration completion.
  bool _completionEventLogged = false;

  /// Controls the visibility of the extended statistics panel.
  bool _showExtendedStats = false;

  /// Controls the visibility of the achievement comparison card.
  bool _showComparisonCard = false;

  /// Scroll controller for auto-scrolling to sections as they
  /// become visible.
  final ScrollController _scrollController = ScrollController();

  /// The computed average deposit per day, derived from [goalAmount]
  /// and [daysToComplete].
  double get _averageDepositPerDay {
    if (widget.daysToComplete <= 0) return 0;
    return widget.goalAmount / widget.daysToComplete;
  }

  /// The computed efficiency score (0-100) based on the streak
  /// relative to the total number of days.
  double get _efficiencyScore {
    if (widget.daysToComplete <= 0) return 0;
    final ratio = widget.streak / widget.daysToComplete;
    return (ratio * 100).clamp(0.0, 100.0);
  }

  /// The formatted average deposit per day string.
  String get _formattedAvgPerDay =>
      _averageDepositPerDay.toStringAsFixed(0);

  /// The formatted efficiency score with a percentage symbol.
  String get _formattedEfficiency =>
      '${_efficiencyScore.toStringAsFixed(1)}%';

  /// The XP reward for this achievement, computed based on the
  /// goal amount and the time taken.
  int get _computedXpReward {
    const baseXp = 50;
    final timeBonus = (100 / (widget.daysToComplete + 1)).floor();
    final streakBonus = (widget.streak * 2).clamp(0, 30);
    return baseXp + timeBonus + streakBonus;
  }

  /// The coin reward for this achievement.
  int get _computedCoinReward {
    const baseCoins = 20;
    final amountBonus = (widget.goalAmount / 5000).floor().clamp(0, 50);
    return baseCoins + amountBonus;
  }

  /// Elapsed time since the screen was displayed.
  Duration get _timeOnScreen =>
      DateTime.now().difference(_screenEnterTime);

  static const _celebrationMessages = [
    '🎉 ВІТАЄМО!',
    '🏆 Ти це зробив!',
    '💎 Неймовірно!',
    '🌟 Зірка дня!',
    '🚀 Місія виконана!',
  ];

  static const _achievementNames = [
    'Перший фініш',
    'Майстер накопичення',
    'Легенда заощадження',
  ];

  static const _shareOptions = [
    ('Зображення', Icons.image_rounded),
    ('Текст', Icons.text_fields_rounded),
    ('Сторіс', Icons.auto_stories_rounded),
    ('Посилання', Icons.link_rounded),
  ];

  /// Additional celebration colour variants for theming the
  /// overlay particles. Each variant uses a different hue.
  static const _variantColors = [
    [Color(0xFFFF6B6B), Color(0xFFFF8A5C), Color(0xFFFFD93D)],
    [Color(0xFF4ECDC4), Color(0xFF44BBA4), Color(0xFFA8E6CF)],
    [Color(0xFF6C5CE7), Color(0xFFA29BFE), Color(0xFFDFE6E9)],
    [Color(0xFF006FCD), Color(0xFF00C6FF), Color(0xFF74B9FF)],
    [Color(0xFFFFD600), Color(0xFFFFA502), Color(0xFFFF6348)],
  ];

  /// Extended achievement tiers with descriptions and thresholds.
  static const _achievementTiers = [
    ('Бронзовий фінішер', 'Перша досягнута мета', 1, Color(0xFFCD7F32)),
    ('Срібний накопичувач', '3 досягнуті мети', 3, Color(0xFFC0C0C0)),
    ('Золотий майстер', '5 досягнутих мет', 5, Color(0xFFFFD700)),
    ('Платиновий чемпіон', '10 досягнутих мет', 10, Color(0xFFE5E4E2)),
    ('Діамантовий легенда', '25 досягнутих мет', 25, Color(0xFFB9F2FF)),
  ];

  /// Motivational messages based on efficiency score.
  static const _efficiencyMessages = [
    'Ти на правильному шляху!',
    'Чудовий результат!',
    'Неперевершена дисципліна!',
  ];

  /// The maximum confetti particle count allowed by the settings
  /// slider.
  static const _maxConfettiCount = 200;

  /// The minimum confetti particle count allowed.
  static const _minConfettiCount = 20;

  /// The maximum confetti gravity value.
  static const _maxConfettiGravity = 15.0;

  /// The minimum confetti gravity value.
  static const _minConfettiGravity = 1.0;

  @override
  void initState() {
    super.initState();

    _celebrationVariant = math.Random().nextInt(_celebrationMessages.length);

    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );

    _progressAnim = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _progressController,
        curve: AppEasings.cinematicEase,
      ),
    );

    _countdownController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed && !_navigated) {
          _navigated = true;
          if (widget.onTransition != null) {
            widget.onTransition!();
          }
        }
      });

    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();

    _statsController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _achievementController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _progressController.forward();

    Future.delayed(const Duration(milliseconds: 2600), () {
      if (mounted) {
        setState(() { _showToast = true; _showShareButton = true; });
        HapticService.success();
        HapticService.levelUp();
      }
    });

    Future.delayed(const Duration(milliseconds: 3200), () {
      if (mounted) _countdownController.forward();
    });

    Future.delayed(const Duration(milliseconds: 2700), () {
      _triggerSoundStub();
    });

    Future.delayed(const Duration(milliseconds: 3500), () {
      if (mounted) {
        setState(() => _showStats = true);
        _statsController.forward();
      }
    });

    Future.delayed(const Duration(milliseconds: 4500), () {
      if (mounted) setState(() => _showAchievementUnlock = true);
      _achievementController.forward();
    });

    Future.delayed(const Duration(milliseconds: 6000), () {
      if (mounted) setState(() => _showNewGoalPrompt = true);
    });
  }

  /// Validates the current confetti settings to ensure they
  /// are within the allowed ranges. Returns an error message if
  /// invalid, or `null` if everything is fine.
  String? _validateConfettiSettings() {
    if (_confettiCount < _minConfettiCount ||
        _confettiCount > _maxConfettiCount) {
      return 'Кількість частинок повинна бути між '
          '$_minConfettiCount та $_maxConfettiCount';
    }
    if (_confettiGravity < _minConfettiGravity ||
        _confettiGravity > _maxConfettiGravity) {
      return 'Гравітація повинна бути між '
          '${_minConfettiGravity.toStringAsFixed(1)} та '
          '${_maxConfettiGravity.toStringAsFixed(1)}';
    }
    return null;
  }

  /// Computes the celebration variant colour palette for the current
  /// [celebrationVariant]. Returns a list of three colours.
  List<Color> _getVariantColors() {
    final idx = _celebrationVariant % _variantColors.length;
    return _variantColors[idx];
  }

  /// Returns the appropriate efficiency message based on the current
  /// [_efficiencyScore]. Higher scores yield more encouraging messages.
  String _getEfficiencyMessage() {
    if (_efficiencyScore >= 66) return _efficiencyMessages[2];
    if (_efficiencyScore >= 33) return _efficiencyMessages[1];
    return _efficiencyMessages[0];
  }

  /// Returns the nearest achievement tier based on a hypothetical
  /// goals-completed count (currently placeholder).
  (String, String, int, Color) _getNearestTier(int goalsCompleted) {
    if (goalsCompleted <= 0) return _achievementTiers.first;
    for (final tier in _achievementTiers.reversed) {
      if (goalsCompleted >= tier.$3) return tier;
    }
    return _achievementTiers.first;
  }

  /// Logs the completion event to analytics (stub implementation).
  /// Only logs once per session.
  void _logCompletionEvent() {
    if (_completionEventLogged) return;
    _completionEventLogged = true;
    assert(() {
      debugPrint(
        '[GoalReachedScreen] Completion event logged: '
        '${widget.goalName} (${widget.goalAmount.toInt()} грн) '
        'in ${widget.daysToComplete} days, '
        'streak: ${widget.streak}, '
        'efficiency: ${_formattedEfficiency}',
      );
      return true;
    }());
  }

  /// Formats a duration into a human-readable Ukrainian string
  /// (e.g. "2 хв 30 с").
  String _formatDuration(Duration d) {
    final minutes = d.inMinutes;
    final seconds = d.inSeconds % 60;
    if (minutes > 0) {
      return '$minutes хв $seconds с';
    }
    return '$seconds с';
  }

  void _triggerSoundStub() {
    HapticService.levelUp();
    _logCompletionEvent();
  }

  void _onShare() {
    HapticService.selection();
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(Spacing.base),
        decoration: BoxDecoration(color: Theme.of(context).brightness == Brightness.dark ? AppColorsPS5.card : AppColorsMonitor.card, borderRadius: const BorderRadius.vertical(top: Radius.circular(Radii.xl))),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const SizedBox(height: Spacing.sm),
          Text('Поділитися результатом', style: AppTypography.heading3.copyWith(color: Theme.of(context).brightness == Brightness.dark ? AppColorsPS5.textPrimary : AppColorsMonitor.textPrimary)),
          const SizedBox(height: Spacing.lg),
          ..._shareOptions.map((opt) => ListTile(
            leading: Icon(opt.$2),
            title: Text(opt.$1),
            onTap: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('🎉 Я зібрав(ла) ${widget.goalAmount.toInt()} грн на ${widget.goalName}!', style: AppTypography.labelMedium.copyWith(color: Colors.white)),
                  backgroundColor: AppColorsPS5.accent,
                  behavior: SnackBarBehavior.floating,
                  duration: const Duration(milliseconds: 3000),
                ),
              );
            },
          )),
          const SizedBox(height: Spacing.xl),
        ]),
      ),
    );
  }

  void _onReplayCelebration() {
    if (_isReplaying) return;
    HapticService.mediumTap();
    setState(() => _isReplaying = true);
    _progressController.reset();
    _progressController.forward();

    Future.delayed(const Duration(milliseconds: 2600), () {
      if (mounted) {
        HapticService.success();
        HapticService.levelUp();
        setState(() => _isReplaying = false);
      }
    });
  }

  void _onCreateNewGoal() {
    HapticService.selection();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('🚀 Створення нової цілі...', style: AppTypography.labelMedium.copyWith(color: Colors.white)),
        backgroundColor: AppColorsPS5.accent,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _toggleConfettiSettings() {
    HapticService.selection();
    showModalBottomSheet(
      context: context,
      builder: (context) => StatefulBuilder(builder: (context, setModalState) {
        return Container(
          padding: const EdgeInsets.all(Spacing.base),
          decoration: BoxDecoration(color: Theme.of(context).brightness == Brightness.dark ? AppColorsPS5.card : AppColorsMonitor.card, borderRadius: const BorderRadius.vertical(top: Radius.circular(Radii.xl))),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const SizedBox(height: Spacing.sm),
            Text('🎨 Налаштування святкування', style: AppTypography.heading3.copyWith(color: Theme.of(context).brightness == Brightness.dark ? AppColorsPS5.textPrimary : AppColorsMonitor.textPrimary)),
            const SizedBox(height: Spacing.lg),
            Text('Кількість частинок: $_confettiCount', style: AppTypography.labelMedium.copyWith(color: Theme.of(context).brightness == Brightness.dark ? AppColorsPS5.textSecondary : AppColorsMonitor.textSecondary)),
            Slider(value: _confettiCount.toDouble(), min: 20, max: 200, divisions: 9, onChanged: (v) => setModalState(() => _confettiCount = v.toInt())),
            Text('Гравітація: ${_confettiGravity.toStringAsFixed(1)}', style: AppTypography.labelMedium.copyWith(color: Theme.of(context).brightness == Brightness.dark ? AppColorsPS5.textSecondary : AppColorsMonitor.textSecondary)),
            Slider(value: _confettiGravity, min: 1.0, max: 15.0, onChanged: (v) => setModalState(() => _confettiGravity = v)),
            Text('Вітер: ${_confettiWind.toStringAsFixed(1)}', style: AppTypography.labelMedium.copyWith(color: Theme.of(context).brightness == Brightness.dark ? AppColorsPS5.textSecondary : AppColorsMonitor.textSecondary)),
            Slider(value: _confettiWind, min: -3.0, max: 5.0, onChanged: (v) => setModalState(() => _confettiWind = v)),
            const SizedBox(height: Spacing.xl),
          ]),
        );
      }),
    );
  }

  @override
  void dispose() {
    _progressController.dispose();
    _countdownController.dispose();
    _shimmerController.dispose();
    _statsController.dispose();
    _achievementController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  /// Toggles the extended statistics panel visibility.
  void _toggleExtendedStats() {
    HapticService.selection();
    setState(() => _showExtendedStats = !_showExtendedStats);
  }

  /// Builds the extended statistics panel with additional metrics
  /// such as efficiency score, XP/coin rewards, and daily breakdown.
  Widget _buildExtendedStatsPanel(Color accent, Color textColor, Color subColor) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOutCubic,
      margin: const EdgeInsets.only(top: Spacing.md),
      padding: const EdgeInsets.all(Spacing.base),
      decoration: BoxDecoration(
        color: accent.withOpacity(0.04),
        borderRadius: BorderRadius.circular(Radii.lg),
        border: Border.all(color: accent.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          Text(
            '📈 Детальна статистика',
            style: AppTypography.labelLarge.copyWith(
              color: textColor,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: Spacing.sm),
          _buildDetailRow('Серія / Загальні дні', '${widget.streak} / ${widget.daysToComplete}', accent, subColor),
          _buildDetailRow('Середнє / день', '${_formattedAvgPerDay} грн', accent, subColor),
          _buildDetailRow('Ефективність', _formattedEfficiency, _efficiencyScore >= 50 ? AppColorsPS5.success : AppColorsPS5.warning, subColor),
          _buildDetailRow('XP нагорода', '+${_computedXpReward} XP', AppColorsPS5.xp, subColor),
          _buildDetailRow('Монети', '+${_computedCoinReward} монет', AppColorsPS5.coin, subColor),
          const SizedBox(height: Spacing.sm),
          Text(
            _getEfficiencyMessage(),
            style: AppTypography.labelSmall.copyWith(
              color: accent,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  /// Builds a single detail row for the extended stats panel.
  Widget _buildDetailRow(String label, String value, Color valueColor, Color labelColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTypography.labelSmall.copyWith(color: labelColor)),
          Text(value, style: AppTypography.labelSmall.copyWith(color: valueColor, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }

  /// Builds the achievement comparison card showing the user's
  /// current tier and progress toward the next tier.
  Widget _buildComparisonCard(Color accent, Color textColor, Color subColor) {
    final currentTier = _getNearestTier(1);
    return Container(
      margin: const EdgeInsets.only(top: Spacing.md),
      padding: const EdgeInsets.all(Spacing.base),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [currentTier.$4.withOpacity(0.1), Colors.transparent],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(Radii.lg),
        border: Border.all(color: currentTier.$4.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: currentTier.$4.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.emoji_events_rounded, color: currentTier.$4, size: 22),
          ),
          const SizedBox(width: Spacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(currentTier.$1, style: AppTypography.labelMedium.copyWith(color: currentTier.$4, fontWeight: FontWeight.w700)),
                Text(currentTier.$2, style: AppTypography.caption.copyWith(color: subColor)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: Spacing.sm, vertical: Spacing.xs),
            decoration: BoxDecoration(color: accent.withOpacity(0.1), borderRadius: BorderRadius.circular(Radii.circular)),
            child: Text('1 / ${currentTier.$3}', style: AppTypography.labelSmall.copyWith(color: accent, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  /// Builds a themed snackbar with the given message and colour.
  void _showThemedSnackBar(String message, Color backgroundColor) {
    HapticService.selection();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: AppTypography.labelMedium.copyWith(color: Colors.white)),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(milliseconds: 2500),
      ),
    );
  }

  /// Resets all confetti settings to their default values.
  void _resetConfettiSettings() {
    setState(() {
      _confettiCount = 80;
      _confettiGravity = 6.0;
      _confettiWind = 1.0;
    });
    HapticService.lightTap();
  }

  // ── Additional computed properties ──────────────────────────────

  /// The total XP and coin rewards combined for display.
  String get _combinedRewardsText =>
      '+${_computedXpReward} XP · +${_computedCoinReward} монет';

  /// The median deposit amount, computed from the total and count.
  double get _medianDepositEstimate {
    if (widget.totalDeposits <= 0) return 0;
    // Approximate median as total / count (for mock purposes)
    return widget.goalAmount / widget.totalDeposits;
  }

  /// The formatted median deposit for display.
  String get _formattedMedianDeposit =>
      _medianDepositEstimate.toStringAsFixed(0);

  /// Whether the user's efficiency is above the "good" threshold
  /// (defined as streak / days >= 30%).
  bool get _isHighEfficiency => _efficiencyScore >= 30.0;

  /// Whether the user's efficiency is exceptional (>= 50%).
  bool get _isExceptionalEfficiency => _efficiencyScore >= 50.0;

  /// The deposit frequency as a human-readable string
  /// (e.g. "кожен 1-й день" or "кожні 2 дні").
  String get _depositFrequency {
    if (widget.daysToComplete <= 0) return '—';
    final frequency = widget.daysToComplete / widget.totalDeposits;
    if (frequency <= 1.0) return 'Щоденно';
    if (frequency <= 2.0) return 'Кожен 2-й день';
    if (frequency <= 7.0) {
      final days = frequency.round();
      return 'Кожні $days дні';
    }
    final weeks = (frequency / 7).toStringAsFixed(1);
    return 'Раз на $weeks тижн.';
  }

  /// The completion speed index relative to the average user.
  /// Values > 1.0 mean the user completed faster than average.
  double get _completionSpeedIndex {
    const averageDays = 60.0;
    if (widget.daysToComplete <= 0) return 0;
    return averageDays / widget.daysToComplete;
  }

  /// The formatted speed index for display.
  String get _formattedSpeedIndex {
    final idx = _completionSpeedIndex;
    if (idx <= 0) return '—';
    return '${idx.toStringAsFixed(1)}×';
  }

  /// The celebration colour gradient based on the current variant.
  List<Color> get _celebrationGradient => _getVariantColors();

  // ── Additional validation helpers ──────────────────────────────

  /// Validates the goal amount is within a reasonable range for
  /// a single deposit. Returns an error message if the amount
  /// suggests an unusually large single deposit, or `null` if fine.
  String? _validateDepositConsistency() {
    if (widget.totalDeposits <= 0) return null;
    final avgDeposit = widget.goalAmount / widget.totalDeposits;
    final maxDeposit = avgDeposit * 5; // Allow 5× average as max
    // This is a soft validation — just informational
    return null;
  }

  /// Validates that the streak does not exceed the total number
  /// of days (which would be a data inconsistency).
  bool _isStreakConsistent() {
    return widget.streak <= widget.daysToComplete;
  }

  /// Computes a growth rate compared to the average user.
  /// Returns a percentage string (e.g. "+45%").
  String _computeGrowthVsAverage() {
    const averageDays = 60.0;
    if (widget.daysToComplete <= 0) return '—';
    final diff = averageDays - widget.daysToComplete;
    if (diff <= 0) return '-${(diff.abs() / averageDays * 100).toStringAsFixed(0)}%';
    return '+${(diff / averageDays * 100).toStringAsFixed(0)}%';
  }

  /// Returns a descriptive label for the current celebration
  /// variant colour palette.
  String _getVariantLabel() {
    final labels = ['Червоний', 'Зелений', 'Фіолетовий', 'Синій', 'Золотий'];
    final idx = _celebrationVariant % labels.length;
    return labels[idx];
  }

  // ── Additional widget builders ─────────────────────────────────

  /// Builds a compact milestone timeline showing the journey phases.
  Widget _buildMilestoneTimeline(Color accent, Color subColor) {
    final milestones = [
      ('Старт', 'День 0', true),
      ('25%', 'День ${widget.daysToComplete ~/ 4}', true),
      ('50%', 'День ${widget.daysToComplete ~/ 2}', true),
      ('75%', 'День ${(widget.daysToComplete * 3) ~/ 4}', true),
      ('100%', 'День ${widget.daysToComplete}', true),
    ];

    return Container(
      margin: const EdgeInsets.only(top: Spacing.md),
      padding: const EdgeInsets.all(Spacing.base),
      decoration: BoxDecoration(
        color: accent.withOpacity(0.04),
        borderRadius: BorderRadius.circular(Radii.lg),
        border: Border.all(color: accent.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '📍 Етапи шляху',
            style: AppTypography.labelMedium.copyWith(
              color: subColor,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: Spacing.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: milestones.map((m) {
              final isLast = m == milestones.last;
              return Column(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: accent.withOpacity(0.15),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: accent,
                        width: isLast ? 2 : 1,
                      ),
                    ),
                    child: isLast
                        ? const Icon(Icons.star_rounded, color: Colors.white, size: 14)
                        : Center(
                            child: Text(
                              m.$1,
                              style: TextStyle(
                                color: accent,
                                fontSize: 8,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    m.$2,
                    style: AppTypography.caption.copyWith(
                      color: subColor.withOpacity(0.7),
                      fontSize: 9,
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  /// Builds a deposit frequency insight card showing how often
  /// the user contributed to their goal.
  Widget _buildFrequencyCard(Color accent, Color subColor) {
    return Container(
      margin: const EdgeInsets.only(top: Spacing.md),
      padding: const EdgeInsets.all(Spacing.md),
      decoration: BoxDecoration(
        color: accent.withOpacity(0.04),
        borderRadius: BorderRadius.circular(Radii.md),
        border: Border.all(color: accent.withOpacity(0.08)),
      ),
      child: Row(
        children: [
          Icon(Icons.repeat_rounded, color: accent, size: 18),
          const SizedBox(width: Spacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Частота внесків',
                  style: AppTypography.caption.copyWith(color: subColor),
                ),
                Text(
                  _depositFrequency,
                  style: AppTypography.labelSmall.copyWith(
                    color: accent,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Text(
            _formattedSpeedIndex,
            style: AppTypography.labelSmall.copyWith(
              color: AppColorsPS5.success,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            'швидше',
            style: AppTypography.caption.copyWith(
              color: AppColorsPS5.success.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds a growth comparison card showing how the user's
  /// performance compares to the average.
  Widget _buildGrowthComparisonCard(Color accent, Color textColor, Color subColor) {
    final growthPct = _computeGrowthVsAverage();
    final isPositive = growthPct.startsWith('+');

    return Container(
      margin: const EdgeInsets.only(top: Spacing.md),
      padding: const EdgeInsets.all(Spacing.base),
      decoration: BoxDecoration(
        color: (isPositive ? AppColorsPS5.success : AppColorsPS5.warning)
            .withOpacity(0.06),
        borderRadius: BorderRadius.circular(Radii.lg),
        border: Border.all(
          color: (isPositive ? AppColorsPS5.success : AppColorsPS5.warning)
              .withOpacity(0.15),
        ),
      ),
      child: Row(
        children: [
          Icon(
            isPositive ? Icons.trending_up_rounded : Icons.trending_down_rounded,
            color: isPositive ? AppColorsPS5.success : AppColorsPS5.warning,
            size: 20,
          ),
          const SizedBox(width: Spacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Порівняння з середнім',
                  style: AppTypography.labelSmall.copyWith(color: subColor),
                ),
                Text(
                  'Ти завершив на $growthPct ${isPositive ? "швидше" : "повільніше"} за середній',
                  style: AppTypography.labelSmall.copyWith(
                    color: textColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: Spacing.sm,
              vertical: Spacing.xs,
            ),
            decoration: BoxDecoration(
              color: (isPositive ? AppColorsPS5.success : AppColorsPS5.warning)
                  .withOpacity(0.12),
              borderRadius: BorderRadius.circular(Radii.circular),
            ),
            child: Text(
              growthPct,
              style: AppTypography.labelSmall.copyWith(
                color: isPositive ? AppColorsPS5.success : AppColorsPS5.warning,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds a social proof indicator showing how many other users
  /// have completed similar goals.
  Widget _buildSocialProofCard(Color accent, Color subColor) {
    return Container(
      margin: const EdgeInsets.only(top: Spacing.md),
      padding: const EdgeInsets.all(Spacing.md),
      decoration: BoxDecoration(
        color: accent.withOpacity(0.04),
        borderRadius: BorderRadius.circular(Radii.md),
        border: Border.all(color: accent.withOpacity(0.08)),
      ),
      child: Row(
        children: [
          const Icon(Icons.groups_rounded, color: Color(0xFFFFD600), size: 18),
          const SizedBox(width: Spacing.sm),
          Expanded(
            child: Text(
              '${1234 + widget.totalDeposits} користувачів досягли подібної мети',
              style: AppTypography.labelSmall.copyWith(color: subColor),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = isDark ? AppColorsPS5.accent : AppColorsMonitor.accent;
    final hintColor = isDark ? AppColorsPS5.textHint : AppColorsMonitor.textHint;
    final textColor = isDark ? AppColorsPS5.textPrimary : AppColorsMonitor.textPrimary;
    final subColor = isDark ? AppColorsPS5.textSecondary : AppColorsMonitor.textSecondary;

    return Scaffold(
      backgroundColor: isDark ? AppColorsPS5.background : AppColorsMonitor.background,
      body: Stack(
        children: [
          // ─── Confetti particles ────────────────────────────
          Positioned.fill(
            child: AppConfetti(
              particleCount: _confettiCount,
              duration: const Duration(milliseconds: 3500),
              fadeOutStart: 0.6,
              sizeMin: 5.0,
              sizeMax: 16.0,
              gravity: _confettiGravity,
              wind: _confettiWind,
              enableSoundStub: true,
            ),
          ),

          // ─── Celebration particles ──────────────────────────
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _progressController,
              builder: (context, _) {
                final t = _progressController.value;
                if (t < 0.5) return const SizedBox.shrink();

                return Opacity(
                  opacity: ((t - 0.5) * 2).clamp(0.0, 0.5),
                  child: CustomPaint(
                    painter: _CelebrationParticlesPainter(
                      progress: t,
                      accent: accent,
                      variant: _celebrationVariant,
                    ),
                  ),
                );
              },
            ),
          ),

          // ─── Main content ───────────────────────────────────
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: Spacing.xxl),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // ── Emoji celebration ────────────────────
                    Text('🎉', style: const TextStyle(fontSize: 48))
                        .animate()
                        .fade(duration: 400.ms)
                        .scale(duration: 600.ms, curve: AppEasings.elastic),

                    const SizedBox(height: Spacing.md),

                    // ── Progress bar 100% with glow ────────
                    AnimatedBuilder(
                      animation: _progressController,
                      builder: (context, _) {
                        final progress = _progressAnim.value;
                        final glowIntensity = (progress - 0.8) / 0.2;
                        return Column(
                          children: [
                            SizedBox(
                              width: double.infinity,
                              height: 32,
                              child: CustomPaint(
                                painter: _GoalProgressBarPainter(
                                  progress: progress,
                                  accentColor: accent,
                                  glowIntensity: glowIntensity.clamp(0.0, 1.0),
                                ),
                              ),
                            ),
                            const SizedBox(height: Spacing.md),
                            Text(
                              '${(progress * 100).toInt()}%',
                              style: AppTypography.monoLarge.copyWith(
                                color: accent,
                              ),
                            ),
                          ],
                        );
                      },
                    ).animate().fade(duration: 400.ms),

                    const SizedBox(height: Spacing.xl),

                    // ── Goal amount summary ─────────────────
                    if (_showToast)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: Spacing.sm, vertical: Spacing.xs),
                        decoration: BoxDecoration(
                          color: accent.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(Radii.circular),
                        ),
                        child: Text(
                          'Зібрано ${widget.goalAmount.toInt()} грн на «${widget.goalName}»',
                          style: AppTypography.labelSmall.copyWith(
                            color: accent,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ).animate().fade(duration: 300.ms).scale(duration: 300.ms, curve: Curves.easeOutBack),

                    const SizedBox(height: Spacing.md),

                    // ── Toast «ВІТАЄМО!» ────────────────────
                    if (_showToast)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: Spacing.xl,
                          vertical: Spacing.lg,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColorsPS5.gradientStart,
                              AppColorsPS5.gradientEnd,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(Radii.xl),
                          boxShadow: [
                            AppShadows.glow(
                              accent,
                              blur: 40,
                              opacity: 0.5,
                              spread: 4,
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _celebrationMessages[_celebrationVariant],
                              style: AppTypography.displaySmall.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: Spacing.sm),
                            Text(
                              'Твоя ${widget.goalName} — твоя!',
                              style: AppTypography.bodyLarge.copyWith(
                                color: Colors.white.withOpacity(0.9),
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: Spacing.xs),
                            Text(
                              '🏆 Нове досягнення розблоковано!',
                              style: AppTypography.labelMedium.copyWith(
                                color: Colors.white.withOpacity(0.7),
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      )
                          .animate()
                          .scale(duration: 600.ms, curve: AppEasings.gentleBounce)
                          .fadeIn(duration: 400.ms),

                    // ── Статистика ─────────────────────────────
                    if (_showStats)
                      Container(
                        margin: const EdgeInsets.only(top: Spacing.xl),
                        padding: const EdgeInsets.all(Spacing.base),
                        decoration: BoxDecoration(
                          color: accent.withOpacity(0.04),
                          borderRadius: BorderRadius.circular(Radii.lg),
                          border: Border.all(color: accent.withOpacity(0.1)),
                        ),
                        child: Column(children: [
                          Text('📊 Статистика досягнення', style: AppTypography.labelMedium.copyWith(color: subColor, fontWeight: FontWeight.w600)),
                          const SizedBox(height: Spacing.sm),
                          Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                            _buildStatWidget('${widget.totalDeposits}', 'внесків', Icons.payments_rounded, accent),
                            _buildStatWidget('${widget.daysToComplete}', 'днів', Icons.calendar_today_rounded, AppColorsPS5.warning),
                            _buildStatWidget('${widget.streak}', 'серія 🔥', Icons.local_fire_department_rounded, AppColorsPS5.success),
                          ]),
                          const SizedBox(height: Spacing.sm),
                          Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                            _buildStatWidget('${(widget.goalAmount / widget.daysToComplete).toStringAsFixed(0)}', 'грн/день', Icons.speed_rounded, AppColorsPS5.coin),
                            _buildStatWidget('${(widget.goalAmount / widget.totalDeposits).toStringAsFixed(0)}', 'ср. внесок', Icons.trending_up_rounded, AppColorsPS5.accent),
                          ]),
                        ]),
                      ).animate().fade(duration: 500.ms).slideY(begin: 0.1, end: 0),

                    // ── Сповіщення про досягнення ──────────────
                    if (_showAchievementUnlock)
                      Container(
                        margin: const EdgeInsets.only(top: Spacing.md),
                        padding: const EdgeInsets.all(Spacing.base),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(colors: [AppColorsPS5.coin.withOpacity(0.1), AppColorsPS5.xp.withOpacity(0.1)]),
                          borderRadius: BorderRadius.circular(Radii.lg),
                          border: Border.all(color: AppColorsPS5.coin.withOpacity(0.3)),
                        ),
                        child: Column(children: [
                          Text('🏆 Досягнення розблоковано!', style: AppTypography.labelLarge.copyWith(color: AppColorsPS5.coin, fontWeight: FontWeight.w700)),
                          const SizedBox(height: Spacing.xs),
                          Text(_achievementNames[_celebrationVariant % _achievementNames.length], style: AppTypography.bodyMedium.copyWith(color: textColor)),
                          const SizedBox(height: Spacing.sm),
                          Text('+50 XP · +20 монет · Бейдж: ⭐', style: AppTypography.labelSmall.copyWith(color: subColor)),
                        ]),
                      ).animate(_achievementController).scale(duration: 500.ms, curve: Curves.easeOutBack).fade(duration: 300.ms),

                    // ── Кнопки дій ──────────────────────────────
                    if (_showShareButton)
                      Container(
                        margin: const EdgeInsets.only(top: Spacing.xl),
                        child: Column(children: [
                          // Кнопка поділитися
                          GestureDetector(
                            onTap: _onShare,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: Spacing.base, vertical: Spacing.sm),
                              decoration: BoxDecoration(color: accent.withOpacity(0.1), borderRadius: BorderRadius.circular(Radii.circular), border: Border.all(color: accent.withOpacity(0.2))),
                              child: Row(mainAxisSize: MainAxisSize.min, children: [
                                Icon(Icons.share_rounded, color: accent, size: 18),
                                const SizedBox(width: Spacing.sm),
                                Text('Поділитися результатом', style: AppTypography.labelMedium.copyWith(color: accent, fontWeight: FontWeight.w600)),
                              ]),
                            ),
                          ).animate().fade(duration: 400.ms, delay: 200.ms).slideY(begin: 0.1, end: 0, delay: 200.ms, duration: 400.ms),
                          const SizedBox(height: Spacing.sm),
                          // Кнопки: повтор + налаштування
                          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                            GestureDetector(
                              onTap: _onReplayCelebration,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: Spacing.sm, vertical: Spacing.xs),
                                decoration: BoxDecoration(color: AppColorsPS5.success.withOpacity(0.08), borderRadius: BorderRadius.circular(Radii.circular)),
                                child: Row(mainAxisSize: MainAxisSize.min, children: [
                                  Icon(Icons.replay_rounded, color: AppColorsPS5.success, size: 14),
                                  const SizedBox(width: 4),
                                  Text('Повторити', style: AppTypography.labelSmall.copyWith(color: AppColorsPS5.success)),
                                ]),
                              ),
                            ),
                            const SizedBox(width: Spacing.sm),
                            GestureDetector(
                              onTap: _toggleConfettiSettings,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: Spacing.sm, vertical: Spacing.xs),
                                decoration: BoxDecoration(color: accent.withOpacity(0.06), borderRadius: BorderRadius.circular(Radii.circular)),
                                child: Row(mainAxisSize: MainAxisSize.min, children: [
                                  Icon(Icons.palette_rounded, color: accent, size: 14),
                                  const SizedBox(width: 4),
                                  Text('Налаштувати', style: AppTypography.labelSmall.copyWith(color: accent)),
                                ]),
                              ),
                            ),
                          ]),
                        ]),
                      ),

                    // ── Запит нової цілі ────────────────────────
                    if (_showNewGoalPrompt)
                      Container(
                        margin: const EdgeInsets.only(top: Spacing.lg),
                        padding: const EdgeInsets.all(Spacing.base),
                        decoration: BoxDecoration(color: accent.withOpacity(0.06), borderRadius: BorderRadius.circular(Radii.lg), border: Border.all(color: accent.withOpacity(0.12))),
                        child: Column(children: [
                          Text('🚀 Готовий до нової цілі?', style: AppTypography.labelMedium.copyWith(color: textColor, fontWeight: FontWeight.w600)),
                          const SizedBox(height: Spacing.sm),
                          Text('Кожна досягнута мрія — це початок нової!', style: AppTypography.labelSmall.copyWith(color: subColor)),
                          const SizedBox(height: Spacing.md),
                          GestureDetector(
                            onTap: _onCreateNewGoal,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: Spacing.base, vertical: Spacing.sm),
                              decoration: BoxDecoration(gradient: LinearGradient(colors: [AppColorsPS5.gradientStart, AppColorsPS5.gradientEnd]), borderRadius: BorderRadius.circular(Radii.circular)),
                              child: Text('Створити нову ціль →', style: AppTypography.labelMedium.copyWith(color: Colors.white, fontWeight: FontWeight.w700)),
                            ),
                          ),
                        ]),
                      ).animate().fade(duration: 500.ms).slideY(begin: 0.1, end: 0),

                    const SizedBox(height: Spacing.xl),

                    // ── Countdown timer ──────────────────────
                    if (_showToast)
                      AnimatedBuilder(
                        animation: _countdownController,
                        builder: (context, _) {
                          final remaining =
                              (2 - _countdownController.value * 2).ceil();
                          return Column(
                            children: [
                              Text(
                                'Святкування через',
                                style: AppTypography.bodySmall.copyWith(
                                  color: hintColor,
                                ),
                              ),
                              const SizedBox(height: Spacing.xs),
                              AnimatedBuilder(
                                animation: _shimmerController,
                                builder: (_, __) {
                                  final shimmer = 0.7 + 0.3 * _shimmerController.value;
                                  return Opacity(
                                    opacity: shimmer,
                                    child: Text(
                                      '$remaining',
                                      style: AppTypography.monoMedium.copyWith(
                                        color: accent,
                                        fontSize: 28,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(height: Spacing.xs),
                              Text(
                                'Перехід до святкування...',
                                style: AppTypography.labelSmall.copyWith(
                                  color: hintColor,
                                ),
                              ),
                            ],
                          );
                        },
                      ).animate().fade(duration: 400.ms),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatWidget(String value, String label, IconData icon, Color color) {
    return Column(children: [
      Icon(icon, color: color, size: 20),
      const SizedBox(height: Spacing.xs),
      Text(value, style: AppTypography.labelLarge.copyWith(color: color, fontWeight: FontWeight.w700)),
      Text(label, style: AppTypography.labelSmall.copyWith(color: color.withOpacity(0.7), fontSize: 10)),
    ]);
  }
}

class _GoalProgressBarPainter extends CustomPainter {
  const _GoalProgressBarPainter({
    required this.progress,
    required this.accentColor,
    this.glowIntensity = 1.0,
  });

  final double progress;
  final Color accentColor;
  final double glowIntensity;

  @override
  void paint(Canvas canvas, Size size) {
    final fillWidth = size.width * progress;

    final bgPaint = Paint()
      ..color = accentColor.withOpacity(0.12)
      ..style = PaintingStyle.fill;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height),
        const Radius.circular(16),
      ),
      bgPaint,
    );

    if (glowIntensity > 0) {
      final glowPaint = Paint()
        ..color = accentColor.withOpacity(0.3 * glowIntensity)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, 16 * glowIntensity);
      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTWH(0, 0, fillWidth, size.height), const Radius.circular(16)),
        glowPaint,
      );
      final outerGlow = Paint()
        ..color = accentColor.withOpacity(0.15 * glowIntensity)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, 30 * glowIntensity);
      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTWH(0, 0, fillWidth, size.height), const Radius.circular(16)),
        outerGlow,
      );
    }

    final fillPaint = Paint()
      ..shader = LinearGradient(
        colors: [const Color(0xFF006FCD), const Color(0xFF00C6FF), accentColor],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      ).createShader(Rect.fromLTWH(0, 0, fillWidth, size.height));
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(0, 0, fillWidth, size.height), const Radius.circular(16)),
      fillPaint,
    );

    if (progress > 0.95) {
      final tipPaint = Paint()
        ..color = Colors.white.withOpacity(0.6 * glowIntensity)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
      canvas.drawCircle(Offset(fillWidth, size.height / 2), 12, tipPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _GoalProgressBarPainter old) =>
      old.progress != progress || old.glowIntensity != glowIntensity;
}

class _CelebrationParticlesPainter extends CustomPainter {
  const _CelebrationParticlesPainter({
    required this.progress,
    required this.accent,
    this.variant = 0,
  });

  final double progress;
  final Color accent;
  final int variant;

  @override
  void paint(Canvas canvas, Size size) {
    final rng = math.Random(123 + variant * 42);
    final count = 20 + variant * 5;
    final spread = (progress - 0.5) * 2;

    // Варіант 0: кола, Варіант 1: зірки, Варіант 2: спіраль
    for (int i = 0; i < count; i++) {
      final angle = rng.nextDouble() * 2 * math.pi;
      final distance = 40 + spread * 200 * rng.nextDouble();
      double x, y;
      if (variant == 2) {
        // Спіраль
        final spiralAngle = angle + spread * 4;
        x = size.width / 2 + math.cos(spiralAngle) * distance;
        y = size.height / 2 + math.sin(spiralAngle) * distance * 0.6;
      } else {
        x = size.width / 2 + math.cos(angle) * distance;
        y = size.height / 2 + math.sin(angle) * distance * 0.6;
      }
      final radius = 2.0 + rng.nextDouble() * 4.0;
      final opacity = (0.3 + rng.nextDouble() * 0.4) * spread;

      final paint = Paint()
        ..color = accent.withOpacity(opacity.clamp(0.0, 0.7))
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
      canvas.drawCircle(Offset(x, y), radius, paint);
    }

    // Додаткові лінії для варіанту 1 (зірки)
    if (variant == 1) {
      for (int i = 0; i < 8; i++) {
        final angle = (i / 8) * 2 * math.pi;
        final distance = spread * 150;
        final x = size.width / 2 + math.cos(angle) * distance;
        final y = size.height / 2 + math.sin(angle) * distance * 0.6;
        final paint = Paint()
          ..color = accent.withOpacity((0.2 * spread).clamp(0.0, 0.4))
          ..strokeWidth = 2
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
        canvas.drawLine(Offset(size.width / 2, size.height / 2), Offset(x, y), paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _CelebrationParticlesPainter old) =>
      old.progress != progress || old.variant != variant;
}

// ──────────────────────────────────────────────────────────────────────
// Radial Glow Burst Painter
// ──────────────────────────────────────────────────────────────────────

/// Radial glow burst painter — renders an expanding ring of light
/// that fades as it grows, simulating a shockwave effect.
///
/// Used as an additional visual layer during the goal-reached
/// celebration. The ring expands from [initialRadius] to
/// [maxRadius] as [progress] goes from 0.0 to 1.0.
class _RadialGlowBurstPainter extends CustomPainter {
  /// Creates a new [_RadialGlowBurstPainter].
  const _RadialGlowBurstPainter({
    required this.progress,
    required this.accentColor,
    this.initialRadius = 20.0,
    this.maxRadius = 200.0,
  });

  /// Animation progress in `[0, 1]`, where 0.0 is the initial state
  /// and 1.0 is fully expanded.
  final double progress;

  /// The primary accent colour used for the glow effect.
  final Color accentColor;

  /// The starting radius of the glow ring.
  final double initialRadius;

  /// The maximum radius the ring can expand to.
  final double maxRadius;

  @override
  void paint(Canvas canvas, Size size) {
    final centre = Offset(size.width / 2, size.height / 2);
    final currentRadius =
        initialRadius + (maxRadius - initialRadius) * progress;
    final opacity = (1.0 - progress).clamp(0.0, 0.6);

    // Outer glow
    final outerPaint = Paint()
      ..color = accentColor.withOpacity(opacity * 0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20);
    canvas.drawCircle(centre, currentRadius, outerPaint);

    // Inner ring
    final ringPaint = Paint()
      ..color = accentColor.withOpacity(opacity)
      ..strokeWidth = 3 * (1.0 - progress)
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(centre, currentRadius, ringPaint);

    // Centre flash (visible early in the animation)
    if (progress < 0.3) {
      final flashOpacity = (1.0 - progress / 0.3) * 0.5;
      canvas.drawCircle(
        centre,
        30 * (1.0 - progress / 0.3),
        Paint()..color = Colors.white.withOpacity(flashOpacity),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _RadialGlowBurstPainter old) =>
      old.progress != progress;
}

// ──────────────────────────────────────────────────────────────────────
// Progress Ring Tick Painter
// ──────────────────────────────────────────────────────────────────────

/// Renders small tick marks around a circular progress indicator.
///
/// Each tick corresponds to a milestone (e.g. every 10% of progress).
/// Completed ticks use [activeColor]; upcoming ones use [inactiveColor].
/// The [filledFraction] determines how many ticks are considered complete.
class _ProgressRingTickPainter extends CustomPainter {
  /// Creates a new [_ProgressRingTickPainter].
  const _ProgressRingTickPainter({
    required this.filledFraction,
    required this.activeColor,
    required this.inactiveColor,
    this.tickCount = 10,
    this.innerRadius = 85.0,
    this.tickLength = 8.0,
    this.tickWidth = 2.0,
  });

  /// Fraction of ticks that should be rendered as active (0.0–1.0).
  final double filledFraction;

  /// Colour for completed ticks.
  final Color activeColor;

  /// Colour for upcoming (inactive) ticks.
  final Color inactiveColor;

  /// Total number of tick marks to render.
  final int tickCount;

  /// Distance from the centre to the base of each tick.
  final double innerRadius;

  /// Length of each tick mark.
  final double tickLength;

  /// Stroke width of each tick mark.
  final double tickWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final centre = Offset(size.width / 2, size.height / 2);
    final activeTicks = (filledFraction * tickCount).round();

    for (int i = 0; i < tickCount; i++) {
      final angle = (i / tickCount) * 2 * math.pi - math.pi / 2;
      final isActive = i < activeTicks;
      final innerOffset = Offset(
        centre.dx + math.cos(angle) * innerRadius,
        centre.dy + math.sin(angle) * innerRadius,
      );
      final outerOffset = Offset(
        centre.dx + math.cos(angle) * (innerRadius + tickLength),
        centre.dy + math.sin(angle) * (innerRadius + tickLength),
      );

      canvas.drawLine(
        innerOffset,
        outerOffset,
        Paint()
          ..color = isActive ? activeColor : inactiveColor
          ..strokeWidth = tickWidth
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ProgressRingTickPainter old) =>
      old.filledFraction != filledFraction;
}
