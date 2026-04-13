import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_radii.dart';
import '../../../../core/constants/app_shadows.dart';
import '../../../../core/constants/app_durations.dart';
import '../../../../core/constants/app_easings.dart';
import '../../../../core/utils/haptic_service.dart';
import '../../../../core/widgets/app_button_primary.dart';
import '../../../../core/widgets/app_confetti.dart';

/// Максимальна кількість конфеті-частинок для стандартного святкування.
const int _kMaxStandardConfetti = 42;

/// Кількість конфеті для феєрверку.
const int _kFireworksConfetti = 60;

/// Кількість конфеті для монеток.
const int _kCoinShowerConfetti = 50;

/// Кількість конфеті для зіркового.
const int _kStarryConfetti = 45;

/// Тривалість анімації оверлею (мілісекунди).
const int _kOverlayAnimDurationMs = 900;

/// Тривалість shimmer/блискавок (мілісекунди).
const int _kSparkleDurationMs = 1500;

/// Інтервал друкарської машинки (мілісекунди).
const int _kTypewriterIntervalMs = 45;

/// Затримка перед показом деталей (мілісекунди).
const int _kDetailsDelayMs = 1500;

/// Затримка перед показом статистики (мілісекунди).
const int _kStatsDelayMs = 2000;

/// Затримка перед наступним викликом (мілісекунди).
const int _kNextChallengeDelayMs = 2500;

/// Мінімальний XP для «бонусного» значка.
const int _kBonusXPThreshold = 30;

// ═══════════════════════════════════════════════════════════════════════════
// Тип анімації святкування (Celebration Animation Variant)
// ═══════════════════════════════════════════════════════════════════════════

/// Варіант анімації святкування при завершенні виклику.
enum CelebrationVariant {
  /// Стандартне святкування з конфетті.
  standard,

  /// Святкування з зірками.
  starry,

  /// Святкування з монетами.
  coinShower,

  /// Святкування з феєрверком.
  fireworks,

  /// Тихе святкування (без конфетті, для легких викликів).
  subtle,
}

// ═══════════════════════════════════════════════════════════════════════════
// Статистика виклику (Challenge Statistics)
// ═══════════════════════════════════════════════════════════════════════════

/// Статистика виконаного виклику для відображення.
class ChallengeStatistics {
  const ChallengeStatistics({
    this.daysSpent = 0,
    this.streakUsed = 0,
    this.totalDeposits = 0,
    this.averageDeposit = 0,
    this.bestDay = 0,
    this.completionRate = 100.0,
  });

  /// Кількість днів витрачено на виклик.
  final int daysSpent;

  /// Максимальна серія днів поспіль.
  final int streakUsed;

  /// Загальна кількість внесків за час виклику.
  final int totalDeposits;

  /// Середній розмір внеску.
  final double averageDeposit;

  /// Найкращий день за сумою внеску.
  final double bestDay;

  /// Відсоток виконання (100.0 = ідеально).
  final double completionRate;
}

// ═══════════════════════════════════════════════════════════════════════════
// Розбивка нагороди (Reward Breakdown)
// ═══════════════════════════════════════════════════════════════════════════

/// Детальний розбивки нагороди за виклик.
class RewardBreakdown {
  const RewardBreakdown({
    this.baseXP = 0,
    this.bonusXP = 0,
    this.streakBonusXP = 0,
    this.speedBonusXP = 0,
    this.baseCoins = 0,
    this.bonusCoins = 0,
    this.streakBonusCoins = 0,
  });

  /// Базова XP за виконання.
  final int baseXP;

  /// Бонусна XP за особливі умови.
  final int bonusXP;

  /// Бонусна XP за серію.
  final int streakBonusXP;

  /// Бонусна XP за швидкість.
  final int speedBonusXP;

  /// Базові монети за виконання.
  final int baseCoins;

  /// Бонусні монети.
  final int bonusCoins;

  /// Бонусні монети за серію.
  final int streakBonusCoins;

  /// Загальна XP.
  int get totalXP => baseXP + bonusXP + streakBonusXP + speedBonusXP;

  /// Загальні монети.
  int get totalCoins => baseCoins + bonusCoins + streakBonusCoins;
}

/// Повноекранний оверлей святкування завершення виклику з конфетті (30-50 частинок),
/// trophy bounce-in, typewriter-ефектом, stagger fade-in, haptic та кнопкою «Чудово!».
class ChallengeCompleteOverlay extends StatefulWidget {
  const ChallengeCompleteOverlay({
    super.key,
    required this.title,
    required this.description,
    required this.xpReward,
    required this.coinsReward,
    this.badgeName,
    this.challengeDetails,
    this.celebrationVariant = CelebrationVariant.standard,
    this.statistics,
    this.rewardBreakdown,
    this.nextChallengeTitle,
    this.onNextChallenge,
    this.onShare,
    this.onDismiss,
  });

  final String title;
  final String description;
  final int xpReward;
  final int coinsReward;
  final String? badgeName;
  final String? challengeDetails;
  final CelebrationVariant celebrationVariant;
  final ChallengeStatistics? statistics;
  final RewardBreakdown? rewardBreakdown;
  final String? nextChallengeTitle;
  final VoidCallback? onNextChallenge;
  final VoidCallback? onShare;
  final VoidCallback? onDismiss;

  /// Показує оверлей святкування як OverlayEntry.
  static OverlayEntry show(
    BuildContext context, {
    required String title,
    required String description,
    int xpReward = 50,
    int coinsReward = 25,
    String? badgeName,
    String? challengeDetails,
    CelebrationVariant variant = CelebrationVariant.standard,
  }) {
    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) => ChallengeCompleteOverlay(
        title: title,
        description: description,
        xpReward: xpReward,
        coinsReward: coinsReward,
        badgeName: badgeName,
        challengeDetails: challengeDetails,
        celebrationVariant: variant,
        onDismiss: () => entry.remove(),
      ),
    );
    Overlay.of(context).insert(entry);
    return entry;
  }

  @override
  State<ChallengeCompleteOverlay> createState() =>
      _ChallengeCompleteOverlayState();
}

class _ChallengeCompleteOverlayState extends State<ChallengeCompleteOverlay>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _sparkleController;
  OverlayEntry? _confettiEntry;
  String _typewriterText = '';
  bool _showDetails = false;
  bool _showStatistics = false;
  bool _showNextChallenge = false;

  /// Чи користувач вже натиснув «Чудово!».
  bool _hasClaimed = false;

  /// Чи показувати кнопку «Поділитися».
  bool _showShareButton = false;

  /// Лічильник натискань за сесію.
  int _tapCount = 0;

  /// Час показу оверлею.
  final DateTime _shownAt = DateTime.now();

  /// Обчислює затримку до показу кнопки «Чудово!».
  int get _claimButtonDelay {
    if (widget.rewardBreakdown != null) return 1000;
    if (widget.statistics != null) return 1200;
    return 900;
  }

  /// Обчислює ефективність завершення (XP / витрачені дні).
  double get _efficiencyScore {
    if (widget.statistics == null || widget.statistics!.daysSpent <= 0) return 0.0;
    final totalReward = widget.xpReward + widget.coinsReward;
    return totalReward / widget.statistics!.daysSpent;
  }

  /// Обчислює відсоток бонусних XP від загальних.
  double get _bonusPercentage {
    if (widget.xpReward <= 0) return 0.0;
    if (widget.rewardBreakdown == null) return 0.0;
    final bonus = widget.rewardBreakdown!.bonusXP +
        widget.rewardBreakdown!.streakBonusXP +
        widget.rewardBreakdown!.speedBonusXP;
    return (bonus / widget.xpReward * 100).clamp(0, 100);
  }

  /// Форматує часову мітку показу оверлею.
  String get _timeSinceShown {
    final diff = DateTime.now().difference(_shownAt);
    if (diff.inSeconds < 10) return 'щойно';
    if (diff.inMinutes < 1) return '${diff.inSeconds}с';
    return '${diff.inMinutes}хв';
  }

  /// Перевіряє, чи доступна кнопка поділу.
  bool get _canShare {
    return widget.onShare != null && !_showShareButton;
  }

  /// Обробляє натискання «Чудово!» з захистом від подвійного натискання.
  void _handleClaim() {
    if (_hasClaimed) return;
    _tapCount++;
    _hasClaimed = true;
    HapticService.success();
    widget.onDismiss?.call();
    debugPrint('[ChallengeComplete] Claimed at $_timeSinceShown (taps=$_tapCount)');
  }

  /// Обробляє натискання «Поділитися».
  void _handleShare() {
    if (widget.onShare == null) return;
    _tapCount++;
    HapticService.selection();
    widget.onShare!();
    setState(() => _showShareButton = true);
    debugPrint('[ChallengeComplete] Shared at $_timeSinceShown (taps=$_tapCount)');
 }

  /// Створює загальну кількість XP з усіх бонусів.
  int get _totalXP {
    if (widget.rewardBreakdown != null) return widget.rewardBreakdown!.totalXP;
    return widget.xpReward;
  }

  /// Створює загальну кількість монет з усіх бонусів.
  int get _totalCoins {
    if (widget.rewardBreakdown != null) return widget.rewardBreakdown!.totalCoins;
    return widget.coinsReward;
 }

  /// Обчислює відсоток серії від максимальної.
  double _streakPercentage(int currentStreak, int maxStreak) {
    if (maxStreak <= 0) return 0.0;
    return (currentStreak / maxStreak * 100).clamp(0, 100);
 }

  /// Кількість конфетті-частинок
  int get _confettiCount {
    switch (widget.celebrationVariant) {
      case CelebrationVariant.fireworks:
        return 60;
      case CelebrationVariant.coinShower:
        return 50;
      case CelebrationVariant.starry:
        return 45;
      case CelebrationVariant.standard:
        return 42;
      case CelebrationVariant.subtle:
        return 0;
    }
  }

  /// Тривалість анімації конфетті.
  Duration get _confettiDelay {
    switch (widget.celebrationVariant) {
      case CelebrationVariant.subtle:
        return const Duration(milliseconds: 800);
      default:
        return const Duration(milliseconds: 400);
    }
  }

  /// Іконка трофею залежно від варіанту святкування.
  IconData get _trophyIcon {
    switch (widget.celebrationVariant) {
      case CelebrationVariant.starry:
        return Icons.auto_awesome_rounded;
      case CelebrationVariant.coinShower:
        return Icons.monetization_on_rounded;
      case CelebrationVariant.fireworks:
        return Icons.celebration_rounded;
      case CelebrationVariant.standard:
      case CelebrationVariant.subtle:
        return Icons.emoji_events_rounded;
    }
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _controller.forward();

    _sparkleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    // Запуск конфетті з затримкою
    if (_confettiCount > 0) {
      Future.delayed(_confettiDelay, () {
        if (mounted) {
          _confettiEntry = AppConfetti.show(
            context: context,
            particleCount: _confettiCount,
          );
          HapticService.celebration();
        }
      });
    } else {
      // Тихе святкування — лише легкий тактильний відгук
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) HapticService.success();
      });
    }

    // Запуск ефекту друкарської машинки
    _startTypewriter(widget.title);

    // Показати деталі з затримкою
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) setState(() => _showDetails = true);
    });

    // Показати статистику
    if (widget.statistics != null) {
      Future.delayed(const Duration(milliseconds: 2000), () {
        if (mounted) setState(() => _showStatistics = true);
      });
    }

    // Показати наступний виклик
    if (widget.nextChallengeTitle != null) {
      Future.delayed(const Duration(milliseconds: 2500), () {
        if (mounted) setState(() => _showNextChallenge = true);
      });
    }
  }

  void _startTypewriter(String fullText) {
    _typewriterText = '';
    const interval = Duration(milliseconds: 45);
    var index = 0;

    Future.delayed(const Duration(milliseconds: 350), () {
      Future.doWhile(() async {
        if (!mounted || index >= fullText.length) return false;
        setState(() {
          _typewriterText = fullText.substring(0, index + 1);
        });
        index++;
        await Future.delayed(interval);
        return mounted && index < fullText.length;
      });
    });
  }

  @override
  void dispose() {
    _confettiEntry?.remove();
    _controller.dispose();
    _sparkleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final opacity = Curves.easeOut.transform(
            _controller.value.clamp(0.0, 0.3) / 0.3,
          );
          return Opacity(
            opacity: opacity.clamp(0.0, 1.0),
            child: Container(
              color: Colors.black.withOpacity(0.82),
              child: SafeArea(
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: Spacing.xxl),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(height: Spacing.lg),

                        // ── Трофей (bounce-in з блискавками) ──────
                        _buildTrophy(),

                        const SizedBox(height: Spacing.xxl),

                        // ── Заголовок з typewriter ──────────────────
                        SizedBox(
                          height: 52,
                          child: Center(
                            child: Text(
                              _typewriterText,
                              style: AppTypography.displayMedium.copyWith(
                                fontSize: 36,
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),

                        const SizedBox(height: Spacing.base),

                        // ── Підзаголовок ─────────────────────────────
                        Text(
                          'Виклик виконано!',
                          style: AppTypography.labelLarge.copyWith(
                            color: Colors.white.withOpacity(0.6),
                            letterSpacing: 3,
                            fontWeight: FontWeight.w600,
                          ),
                        )
                            .animate()
                            .fadeIn(duration: 400.ms, delay: 400.ms)
                            .slideY(begin: 0.1, end: 0, duration: 400.ms, delay: 400.ms),

                        const SizedBox(height: Spacing.sm),

                        // ── Опис виклику ───────────────────────────
                        Text(
                          widget.description,
                          style: AppTypography.bodyLarge.copyWith(
                            color: Colors.white.withOpacity(0.8),
                          ),
                          textAlign: TextAlign.center,
                        )
                            .animate()
                            .fadeIn(duration: 400.ms, delay: 500.ms)
                            .slideY(begin: 0.2, end: 0, duration: 400.ms, delay: 500.ms),

                        // ── Деталі виклику ──────────────────────────
                        if (widget.challengeDetails != null && _showDetails)
                          Container(
                            margin: const EdgeInsets.only(top: Spacing.md),
                            padding: const EdgeInsets.all(Spacing.base),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(Radii.lg),
                              border: Border.all(color: Colors.white.withOpacity(0.1)),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.info_outline_rounded,
                                        color: Colors.white.withOpacity(0.5), size: 16),
                                    const SizedBox(width: Spacing.sm),
                                    Text(
                                      'Деталі виклику',
                                      style: AppTypography.labelMedium.copyWith(
                                        color: Colors.white.withOpacity(0.6),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: Spacing.sm),
                                Text(
                                  widget.challengeDetails!,
                                  style: AppTypography.bodyMedium.copyWith(
                                    color: Colors.white.withOpacity(0.75),
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          )
                              .animate()
                              .fadeIn(duration: 400.ms)
                              .scale(begin: const Offset(0.95, 0.95), end: const Offset(1.0, 1.0)),

                        const SizedBox(height: Spacing.xl),

                        // ── Нагороди (stagger fade-in) ────────────────
                        _buildRewards(),

                        // ── Розбивка нагороди ───────────────────────
                        if (widget.rewardBreakdown != null && _showDetails)
                          _buildRewardBreakdown(),

                        // ── Статистика виклику ──────────────────────
                        if (_showStatistics && widget.statistics != null)
                          _buildChallengeStatistics(),

                        const SizedBox(height: Spacing.xxl),

                        // ── Кнопка «Чудово!» з glow ────────────────
                        SizedBox(
                          width: double.infinity,
                          child: AppButtonPrimary(
                            label: 'Чудово!',
                            onPressed: () {
                              HapticService.success();
                              widget.onDismiss?.call();
                            },
                            showGlow: true,
                          ),
                        )
                            .animate()
                            .fadeIn(duration: 400.ms, delay: 1000.ms)
                            .slideY(begin: 0.3, end: 0, duration: 400.ms, delay: 1000.ms),

                        const SizedBox(height: Spacing.lg),

                        // ── Підказка про наступний виклик ────────────
                        if (_showNextChallenge && widget.nextChallengeTitle != null)
                          _buildNextChallengeCard(),

                        // ── Підказка про поділитися ──────────────────
                        GestureDetector(
                          onTap: () {
                            HapticService.selection();
                            widget.onShare?.call();
                          },
                          child: Text(
                            'Поділитися результатом →',
                            style: AppTypography.labelMedium.copyWith(
                              color: Colors.white.withOpacity(0.4),
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ).animate().fadeIn(duration: 300.ms, delay: 1200.ms),

                        const SizedBox(height: Spacing.base),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  /// Іконка трофею з spring bounce-анімацією та блискавками.
  Widget _buildTrophy() {
    return AnimatedBuilder(
      animation: _sparkleController,
      builder: (context, child) {
        final sparkleOpacity = 0.2 + 0.3 * _sparkleController.value;
        return Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColorsPS5.coin.withOpacity(sparkleOpacity),
                blurRadius: 50,
                spreadRadius: 8,
              ),
            ],
          ),
          child: child,
        );
      },
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final t = Curves.elasticOut.transform(_controller.value.clamp(0.0, 1.0));
          final rotation = math.sin(_controller.value * math.pi * 2) * 0.06 * (1 - _controller.value);
          return Transform.scale(
            scale: t,
            child: Transform.rotate(angle: rotation, child: child),
          );
        },
        child: Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [
                AppColorsPS5.xp,
                AppColorsPS5.coin,
                AppColorsPS5.xp,
              ],
              stops: [0.0, 0.5, 1.0],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColorsPS5.xp.withOpacity(0.5),
                blurRadius: 40,
                spreadRadius: 6,
              ),
              BoxShadow(
                color: AppColorsPS5.coin.withOpacity(0.3),
                blurRadius: 24,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Center(
            child: Icon(
              _trophyIcon,
              color: Colors.white,
              size: 60,
            ),
          ),
        ),
      ),
    );
  }

  /// Бейджі нагород: XP, монети, значок — з stagger fade-in.
  Widget _buildRewards() {
    return Column(
      children: [
        // XP бейдж
        _buildRewardBadge(
          icon: Icons.star_rounded,
          label: 'XP +${widget.xpReward}',
          subtitle: 'Досвід зростає!',
          color: AppColorsPS5.xp,
          delay: 700,
        ),
        const SizedBox(height: Spacing.sm),

        // Монети бейдж
        _buildRewardBadge(
          icon: Icons.monetization_on_rounded,
          label: 'Монети +${widget.coinsReward}',
          subtitle: 'Можеш витратити в магазині',
          color: AppColorsPS5.coin,
          delay: 800,
        ),
        const SizedBox(height: Spacing.sm),

        // Значок бейдж (якщо є)
        if (widget.badgeName != null)
          _buildRewardBadge(
            icon: Icons.emoji_events_rounded,
            label: 'Значок «${widget.badgeName}»',
            subtitle: 'Нова відзнака!',
            color: AppColorsPS5.accent,
            delay: 900,
          ),
      ],
    );
  }

  /// Розбивка нагороди з деталізацією XP та монет.
  Widget _buildRewardBreakdown() {
    final breakdown = widget.rewardBreakdown!;
    return Container(
      margin: const EdgeInsets.only(top: Spacing.md),
      padding: const EdgeInsets.all(Spacing.base),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(Radii.md),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Деталізація нагороди',
            style: AppTypography.labelMedium.copyWith(
              color: Colors.white.withOpacity(0.5),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: Spacing.sm),
          // XP розбивка
          _buildBreakdownRow('Базова XP', '+${breakdown.baseXP}', AppColorsPS5.xp),
          if (breakdown.bonusXP > 0)
            _buildBreakdownRow('Бонусна XP', '+${breakdown.bonusXP}', AppColorsPS5.xp),
          if (breakdown.streakBonusXP > 0)
            _buildBreakdownRow('Бонус за серію', '+${breakdown.streakBonusXP}', AppColorsPS5.xp),
          if (breakdown.speedBonusXP > 0)
            _buildBreakdownRow('Бонус за швидкість', '+${breakdown.speedBonusXP}', AppColorsPS5.xp),
          const SizedBox(height: Spacing.xs),
          // Монети розбивка
          _buildBreakdownRow('Базові монети', '+${breakdown.baseCoins}', AppColorsPS5.coin),
          if (breakdown.bonusCoins > 0)
            _buildBreakdownRow('Бонусні монети', '+${breakdown.bonusCoins}', AppColorsPS5.coin),
          if (breakdown.streakBonusCoins > 0)
            _buildBreakdownRow('Бонус за серію', '+${breakdown.streakBonusCoins}', AppColorsPS5.coin),
          // Разом
          const Divider(color: Colors.white24, height: Spacing.base),
          _buildBreakdownRow('Разом XP', '+${breakdown.totalXP}', AppColorsPS5.xp, bold: true),
          _buildBreakdownRow('Разом монет', '+${breakdown.totalCoins}', AppColorsPS5.coin, bold: true),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms, delay: 1600.ms);
  }

  /// Рядок розбивки нагороди.
  Widget _buildBreakdownRow(String label, String value, Color color, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTypography.labelSmall.copyWith(
              color: Colors.white.withOpacity(0.5),
            ),
          ),
          Text(
            value,
            style: AppTypography.labelSmall.copyWith(
              color: color,
              fontWeight: bold ? FontWeight.w700 : FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  /// Статистика виконаного виклику.
  Widget _buildChallengeStatistics() {
    final stats = widget.statistics!;
    return Container(
      margin: const EdgeInsets.only(top: Spacing.md),
      padding: const EdgeInsets.all(Spacing.base),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(Radii.md),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Статистика виклику',
            style: AppTypography.labelMedium.copyWith(
              color: Colors.white.withOpacity(0.5),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: Spacing.sm),
          _buildStatRow('Витрачено днів', '${stats.daysSpent}'),
          _buildStatRow('Максимальна серія', '${stats.streakUsed} дн'),
          if (stats.totalDeposits > 0) ...[
            _buildStatRow('Кількість внесків', '${stats.totalDeposits}'),
            _buildStatRow('Середній внесок', '${stats.averageDeposit.toStringAsFixed(0)} грн'),
            _buildStatRow('Найкращий день', '${stats.bestDay.toStringAsFixed(0)} грн'),
          ],
          _buildStatRow('Відсоток виконання', '${stats.completionRate.toStringAsFixed(0)}%'),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms, delay: 2000.ms);
  }

  /// Рядок статистики.
  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTypography.labelSmall.copyWith(
              color: Colors.white.withOpacity(0.5),
            ),
          ),
          Text(
            value,
            style: AppTypography.labelSmall.copyWith(
              color: Colors.white.withOpacity(0.8),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  /// Картка наступного виклику.
  Widget _buildNextChallengeCard() {
    return GestureDetector(
      onTap: () {
        HapticService.mediumTap();
        widget.onNextChallenge?.call();
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: Spacing.md),
        padding: const EdgeInsets.all(Spacing.base),
        decoration: BoxDecoration(
          color: AppColorsPS5.accent.withOpacity(0.1),
          borderRadius: BorderRadius.circular(Radii.lg),
          border: Border.all(color: AppColorsPS5.accent.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColorsPS5.accent.withOpacity(0.15),
                borderRadius: BorderRadius.circular(Radii.md),
              ),
              child: Icon(
                Icons.arrow_forward_rounded,
                color: AppColorsPS5.accent,
                size: 20,
              ),
            ),
            const SizedBox(width: Spacing.base),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Наступний виклик',
                    style: AppTypography.labelSmall.copyWith(
                      color: Colors.white.withOpacity(0.5),
                    ),
                  ),
                  Text(
                    widget.nextChallengeTitle!,
                    style: AppTypography.labelMedium.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: AppColorsPS5.accent,
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 400.ms, delay: 2500.ms);
  }

  /// Бейдж нагороди з анімацією.
  Widget _buildRewardBadge({
    required IconData icon,
    required String label,
    required String subtitle,
    required Color color,
    required int delay,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.base,
        vertical: Spacing.md + Spacing.xs,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(Radii.lg),
        border: Border.all(color: color.withOpacity(0.25), width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(Radii.md),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: Spacing.base),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTypography.labelLarge.copyWith(
                    color: color,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  subtitle,
                  style: AppTypography.labelSmall.copyWith(
                    color: color.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 400.ms, delay: delay.ms)
        .scale(
          begin: const Offset(0.85, 0.85),
          end: const Offset(1.0, 1.0),
          duration: 400.ms,
          delay: delay.ms,
          curve: AppEasings.spring,
        )
        .slideX(
          begin: -0.1,
          end: 0,
          duration: 400.ms,
          delay: delay.ms,
        );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // Додаткові константи та конфігурація святкування
  // ═══════════════════════════════════════════════════════════════════════

  /// Максимальна тривалість друкарської машинки (мілісекунди).
  static const int _kMaxTypewriterDurationMs = 5000;

  /// Мінімальна затримка між конфетті-сплесками (мілісекунди).
  static const int _kConfettiBurstIntervalMs = 200;

  /// Максимальна кількість повторних натискань до блокування.
  static const int _kMaxTapBeforeLockout = 5;

  /// Тривалість затримки для fade-out при закритті (мілісекунди).
  static const int _kDismissFadeOutMs = 300;

  /// Кількість частинок для sparkle-ефекту навколо трофею.
  static const int _kSparkleParticleCount = 8;

  /// Кут оберту трофею при celebratory «wiggle».
  static const double _kTrophyWiggleAngle = 0.08;

  /// Радіус glow-ефекту навколо трофею.
  static const double _kTrophyGlowRadius = 60.0;

  /// Непрозорість фонового оверлею (dark scrim).
  static const double _kOverlayScrimOpacity = 0.82;

  // ═══════════════════════════════════════════════════════════════════════
  // Валідаційні та перевірочні методи
  // ═══════════════════════════════════════════════════════════════════════

  /// Перевіряє, чи нагорода є «великою» (значна XP або монети).
  ///
  /// «Велика» нагорода — XP >= 100 або монети >= 50.
  bool get _isLargeReward {
    return widget.xpReward >= 100 || widget.coinsReward >= 50;
  }

  /// Перевіряє, чи є бонусні XP значними (>= [_kBonusXPThreshold]).
  bool get _hasSignificantBonus {
    if (widget.rewardBreakdown == null) return false;
    final bonus = widget.rewardBreakdown!.bonusXP +
        widget.rewardBreakdown!.streakBonusXP +
        widget.rewardBreakdown!.speedBonusXP;
    return bonus >= _kBonusXPThreshold;
  }

  /// Перевіряє, чи доцільно показувати детальну статистику.
  ///
  /// Показує статистику лише, якщо є виконані дні або кількість внесків.
  bool get _shouldShowStatistics {
    if (widget.statistics == null) return false;
    return widget.statistics!.daysSpent > 0 ||
        widget.statistics!.totalDeposits > 0;
  }

  /// Перевіряє, чи всі бонуси є нульовими (немає бонусів).
  bool get _hasNoBonuses {
    if (widget.rewardBreakdown == null) return true;
    return widget.rewardBreakdown!.bonusXP == 0 &&
        widget.rewardBreakdown!.streakBonusXP == 0 &&
        widget.rewardBreakdown!.speedBonusXP == 0 &&
        widget.rewardBreakdown!.bonusCoins == 0 &&
        widget.rewardBreakdown!.streakBonusCoins == 0;
  }

  /// Перевіряє, чи користувач натиснув кнопку занадто багато разів.
  bool get _isTapLocked {
    return _tapCount >= _kMaxTapBeforeLockout;
  }

  /// Перевіряє, чи номенклатура святкування є «тихою» (без конфетті).
  bool get _isSubtleCelebration {
    return widget.celebrationVariant == CelebrationVariant.subtle;
  }

  /// Перевіряє, чи оверлей був показаний достатньо довго для автоматичного закриття.
  bool get _canAutoDismiss {
    final elapsed = DateTime.now().difference(_shownAt).inSeconds;
    return elapsed >= 30; // Автозакриття через 30 секунд
  }

  /// Перевіряє валідність статистики виклику.
  ///
  /// Повертає `true`, якщо всі поля статистики невід'ємні.
  bool _validateStatistics(ChallengeStatistics stats) {
    return stats.daysSpent >= 0 &&
        stats.streakUsed >= 0 &&
        stats.totalDeposits >= 0 &&
        stats.averageDeposit >= 0 &&
        stats.bestDay >= 0 &&
        stats.completionRate >= 0 &&
        stats.completionRate <= 100;
  }

  /// Перевіряє валідність розбивки нагороди.
  ///
  /// Повертає `true`, якщо всі поля невід'ємні.
  bool _validateRewardBreakdown(RewardBreakdown breakdown) {
    return breakdown.baseXP >= 0 &&
        breakdown.bonusXP >= 0 &&
        breakdown.streakBonusXP >= 0 &&
        breakdown.speedBonusXP >= 0 &&
        breakdown.baseCoins >= 0 &&
        breakdown.bonusCoins >= 0 &&
        breakdown.streakBonusCoins >= 0;
  }

  // ═══════════════════════════════════════════════════════════════════════
  // Обчислювальні (computed) властивості та допоміжні методи
  // ═══════════════════════════════════════════════════════════════════════

  /// Обчислює XP за день на основі статистики.
  ///
  /// Повертає 0, якщо немає статистики або дні = 0.
  double get _xpPerDay {
    if (widget.statistics == null || widget.statistics!.daysSpent <= 0) {
      return 0.0;
    }
    return _totalXP / widget.statistics!.daysSpent;
  }

  /// Обчислює монети за день на основі статистики.
  double get _coinsPerDay {
    if (widget.statistics == null || widget.statistics!.daysSpent <= 0) {
      return 0.0;
    }
    return _totalCoins / widget.statistics!.daysSpent;
  }

  /// Обчислює загальну ефективність (XP + монети / дні).
  double get _overallEfficiency {
    final totalReward = _totalXP + _totalCoins;
    if (widget.statistics == null || widget.statistics!.daysSpent <= 0) {
      return 0.0;
    }
    return totalReward / widget.statistics!.daysSpent;
  }

  /// Обчислює множник швидкості завершення.
  ///
  /// Якщо виклик завершено раніше терміну — множник > 1.
  double get _speedMultiplier {
    if (widget.statistics == null) return 1.0;
    final stats = widget.statistics!;
    if (stats.daysSpent <= 0) return 1.0;
    if (stats.completionRate >= 100) return 1.0 + (stats.completionRate - 100) / 100;
    return stats.completionRate / 100;
  }

  /// Обчислює рейтинг завершення (A, B, C, D, F).
  String get _completionGrade {
    final stats = widget.statistics;
    if (stats == null) return '?';
    final rate = stats.completionRate;
    if (rate >= 95) return 'S';
    if (rate >= 80) return 'A';
    if (rate >= 60) return 'B';
    if (rate >= 40) return 'C';
    return 'D';
  }

  /// Обчислює колір рейтингу.
  Color get _gradeColor {
    switch (_completionGrade) {
      case 'S':
        return const Color(0xFFFFD700); // Золото
      case 'A':
        return AppColorsPS5.success;
      case 'B':
        return AppColorsPS5.accent;
      case 'C':
        return AppColorsPS5.warning;
      default:
        return AppColorsPS5.error;
    }
  }

  /// Обчислює тривалість друкарської машинки для конкретного тексту.
  Duration _computeTypewriterDuration(String text) {
    final totalMs = text.length * _kTypewriterIntervalMs;
    return Duration(
      milliseconds: totalMs.clamp(0, _kMaxTypewriterDurationMs),
    );
  }

  /// Форматує XP за день з одиницею виміру.
  String get _formattedXpPerDay {
    if (_xpPerDay == 0) return '—';
    return '${_xpPerDay.toStringAsFixed(1)} XP/день';
  }

  /// Форматує монети за день з одиницею виміру.
  String get _formattedCoinsPerDay {
    if (_coinsPerDay == 0) return '—';
    return '${_coinsPerDay.toStringAsFixed(1)} 🪙/день';
  }

  /// Форматує загальну ефективність як зручний рядок.
  String get _formattedEfficiency {
    if (_overallEfficiency == 0) return '—';
    return '${_overallEfficiency.toStringAsFixed(1)} балів/день';
  }

  /// Форматує відсоток бонусних XP з відсотковим знаком.
  String get _formattedBonusPercentage {
    if (_bonusPercentage == 0) return 'Без бонусів';
    return '+${_bonusPercentage.toStringAsFixed(0)}% бонусів';
  }

  // ═══════════════════════════════════════════════════════════════════════
  // Додаткові віджети-будівники
  // ═══════════════════════════════════════════════════════════════════════

  /// Будує рядок рейтингу завершення (S/A/B/C/D).
  Widget _buildGradeBadge() {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: _gradeColor.withOpacity(0.2),
        border: Border.all(color: _gradeColor, width: 2),
        boxShadow: [
          BoxShadow(
            color: _gradeColor.withOpacity(0.3),
            blurRadius: 12,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Center(
        child: Text(
          _completionGrade,
          style: AppTypography.heading1.copyWith(
            color: _gradeColor,
            fontSize: 24,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    ).animate().fadeIn(duration: 400.ms, delay: 1800.ms).scale(
          begin: const Offset(0.5, 0.5),
          end: const Offset(1.0, 1.0),
          duration: 500.ms,
          delay: 1800.ms,
          curve: AppEasings.spring,
        );
  }

  /// Будує секцію ефективності (XP/день, монети/день, загальна).
  Widget _buildEfficiencySection() {
    return Container(
      margin: const EdgeInsets.only(top: Spacing.md),
      padding: const EdgeInsets.all(Spacing.base),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(Radii.md),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.speed_rounded,
                  color: Colors.white.withOpacity(0.5), size: 16),
              const SizedBox(width: Spacing.sm),
              Text(
                'Ефективність',
                style: AppTypography.labelMedium.copyWith(
                  color: Colors.white.withOpacity(0.6),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              _buildGradeBadge(),
            ],
          ),
          const SizedBox(height: Spacing.sm),
          _buildStatRow('XP за день', _formattedXpPerDay),
          _buildStatRow('Монети за день', _formattedCoinsPerDay),
          _buildStatRow('Загальна ефективність', _formattedEfficiency),
          _buildStatRow('Множник швидкості', '${_speedMultiplier.toStringAsFixed(2)}x'),
          if (!_hasNoBonuses)
            _buildStatRow('Бонусна частка', _formattedBonusPercentage),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms, delay: 2200.ms);
  }

  /// Будує підказку про раннє завершення.
  Widget _buildEarlyCompletionHint() {
    if (widget.statistics == null || widget.statistics!.daysSpent <= 0) {
      return const SizedBox.shrink();
    }
    final stats = widget.statistics!;
    final isEarly = stats.completionRate > 100;
    if (!isEarly) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(top: Spacing.sm),
      padding: const EdgeInsets.all(Spacing.sm),
      decoration: BoxDecoration(
        color: const Color(0xFFFFD700).withOpacity(0.1),
        borderRadius: BorderRadius.circular(Radii.sm),
        border: Border.all(color: const Color(0xFFFFD700).withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(Icons.bolt_rounded,
              color: const Color(0xFFFFD700), size: 16),
          const SizedBox(width: Spacing.sm),
          Expanded(
            child: Text(
              '⚡ Завершено раніше терміну! '
              '${(stats.completionRate - 100).toStringAsFixed(0)}% економії часу.',
              style: AppTypography.labelSmall.copyWith(
                color: const Color(0xFFFFD700).withOpacity(0.9),
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms, delay: 2600.ms);
  }

  /// Будує рядок «Найкращий день» з підсвічуванням.
  Widget _buildBestDayHighlight() {
    if (widget.statistics == null || widget.statistics!.bestDay <= 0) {
      return const SizedBox.shrink();
    }
    return Container(
      margin: const EdgeInsets.only(top: Spacing.xs),
      padding: const EdgeInsets.symmetric(horizontal: Spacing.sm, vertical: 4),
      decoration: BoxDecoration(
        color: AppColorsPS5.xp.withOpacity(0.08),
        borderRadius: BorderRadius.circular(Radii.circular),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.local_fire_department_rounded,
              color: AppColorsPS5.xp, size: 14),
          const SizedBox(width: 4),
          Text(
            'Найкращий: ${widget.statistics!.bestDay.toStringAsFixed(0)} грн',
            style: AppTypography.labelSmall.copyWith(
              color: AppColorsPS5.xp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  /// Будує повідомлення-заохочення на основі кількості XP.
  Widget _buildEncouragementMessage() {
    String message;
    IconData icon;
    if (_isLargeReward) {
      message = '🔥 Неймовірно! Це видатний результат!';
      icon = Icons.fireplace_rounded;
    } else if (widget.xpReward >= _kBonusXPThreshold) {
      message = '💪 Чудова робота! Продовжуй в тому ж дусі!';
      icon = Icons.thumb_up_rounded;
    } else {
      message = '✨ Відмінно! Ще один крок до мети!';
      icon = Icons.auto_awesome_rounded;
    }
    return Padding(
      padding: const EdgeInsets.only(top: Spacing.sm),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white.withOpacity(0.5), size: 16),
          const SizedBox(width: Spacing.sm),
          Flexible(
            child: Text(
              message,
              style: AppTypography.labelSmall.copyWith(
                color: Colors.white.withOpacity(0.6),
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms, delay: 2800.ms);
  }

  /// Будує міні-прогрес-бар серії (streak visualizer).
  Widget _buildStreakBar() {
    if (widget.statistics == null || widget.statistics!.streakUsed <= 0) {
      return const SizedBox.shrink();
    }
    final stats = widget.statistics!;
    final streakPct = _streakPercentage(
      stats.streakUsed,
      stats.daysSpent > 0 ? stats.daysSpent : 1,
    );
    return Container(
      margin: const EdgeInsets.only(top: Spacing.xs),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Серія: ${stats.streakUsed} дн',
                style: AppTypography.labelSmall.copyWith(
                  color: Colors.white.withOpacity(0.5),
                ),
              ),
              Text(
                '${streakPct.toStringAsFixed(0)}%',
                style: AppTypography.labelSmall.copyWith(
                  color: Colors.white.withOpacity(0.7),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(Radii.circular),
            child: LinearProgressIndicator(
              value: streakPct / 100,
              backgroundColor: Colors.white.withOpacity(0.1),
              valueColor: AlwaysStoppedAnimation<Color>(
                AppColorsPS5.accent.withOpacity(0.8),
              ),
              minHeight: 4,
            ),
          ),
        ],
      ),
    );
  }

  /// Будує sparkline-подібний візуалізатор суми внесків за виклик.
  ///
  /// Відображає 5 «вузлів» як наближене зображення активності.
  Widget _buildActivityVisualizer() {
    if (widget.statistics == null) return const SizedBox.shrink();
    final totalDeposits = widget.statistics!.totalDeposits;
    if (totalDeposits <= 0) return const SizedBox.shrink();

    // Генеруємо наближену модель активності (5 точок).
    final points = <double>[];
    for (var i = 0; i < 5; i++) {
      final fraction = (i + 1) / 5;
      points.add((fraction * totalDeposits * 0.3 +
              math.Random(i + 42).nextDouble() * totalDeposits * 0.2)
          .clamp(0, totalDeposits.toDouble()));
    }

    return Container(
      margin: const EdgeInsets.only(top: Spacing.sm),
      height: 32,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: points.map((val) {
          final maxVal = points.reduce(math.max);
          final height = maxVal > 0 ? (val / maxVal) * 28.0 : 4.0;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeOutCubic,
            width: 16,
            height: height.clamp(4.0, 28.0),
            decoration: BoxDecoration(
              color: AppColorsPS5.accent.withOpacity(0.5),
              borderRadius: BorderRadius.circular(Radii.circular),
            ),
          );
        }).toList(),
      ),
    ).animate().fadeIn(duration: 400.ms, delay: 2400.ms);
  }

  /// Будує підсумковий футер з інформацією про сесію.
  Widget _buildSessionFooter() {
    return Container(
      margin: const EdgeInsets.only(top: Spacing.base),
      padding: const EdgeInsets.symmetric(horizontal: Spacing.sm, vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Взаємодій: $_tapCount · Показано: $_timeSinceShown',
            style: AppTypography.caption.copyWith(
              color: Colors.white.withOpacity(0.2),
            ),
          ),
        ],
      ),
    );
  }
}

/// Розширення для HapticService.
class HapticService {
  static void selection() {
    // HapticFeedback.selectionClick();
  }

  static void success() {
    // HapticFeedback.mediumImpact();
  }

  static void celebration() {
    // HapticFeedback.heavyImpact();
    // Future.delayed(const Duration(milliseconds: 150), () {
    //   HapticFeedback.lightImpact();
    // });
    // Future.delayed(const Duration(milliseconds: 300), () {
    //   HapticFeedback.mediumImpact();
    // });
  }

  static void frostCrack() {
    // HapticFeedback.heavyImpact();
  }
}
