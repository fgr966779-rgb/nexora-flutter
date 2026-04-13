import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_radii.dart';
import '../../../../core/constants/app_shadows.dart';
import '../../../../core/utils/haptic_service.dart';
import '../../../../core/widgets/app_confetti.dart';

/// Кількість частинок конфеті при отриманні нагороди.
const int _kConfettiParticleCount = 50;

/// Тривалість bounce-анімації значка (мілісекунди).
const int _kBounceDurationMs = 600;

/// Тривалість glow-пульсації (мілісекунди).
const int _kGlowDurationMs = 1500;

/// Тривалість shimmer-анімації (мілісекунди).
const int _kShimmerDurationMs = 2000;

/// Тривалість dismiss-анімації (мілісекунди).
const int _kDismissDurationMs = 350;

/// Максимальна кількість записів в історії нагород.
const int _kMaxRewardHistory = 30;

/// Затримка перед закриттям після отримання (мілісекунди).
const int _kAutoCloseDelayMs = 400;

/// Розмір значка нагороди (пікселі).
const double _kBadgeSize = 140.0;

/// Мінімальний XP для «великої» нагороди.
const int _kBigRewardXpThreshold = 50;

/// Повноекранний оверлей для розблокування значка або рівня.
///
/// Містить:
/// - Full-screen overlay
/// - Badge icon: large bounce-in (600ms, elastic) + glow effect + shimmer
/// - Badge name: fade-in + slide-up (500ms, delay 300ms)
/// - Description text: fade-in (delay 500ms)
/// - XP + Coins reward card: fade-in + scale (delay 700ms)
/// - "Забрати" button: fade-in + slide-up (delay 900ms)
/// - Confetti background (50 particles, 1500ms)
/// - Auto-dismiss on tap outside
/// - Haptic badgeUnlock pattern
/// - Reward categories, inventory, gifting, history, notifications
class RewardScreen extends StatefulWidget {
  const RewardScreen({
    super.key,
    this.badgeIcon = Icons.emoji_events_rounded,
    this.badgeName = 'Майстер викликів',
    this.description = 'Ви виконали всі щоденні виклики протягом тижня!',
    this.xpReward = 15,
    this.coinReward = 10,
    this.levelUp = false,
    this.onClaim,
    this.rewardCategory = 'Виклик',
  });

  final IconData badgeIcon;
  final String badgeName;
  final String description;
  final int xpReward;
  final int coinReward;
  final bool levelUp;
  final VoidCallback? onClaim;
  final String rewardCategory;

  @override
  State<RewardScreen> createState() => _RewardScreenState();
}

class _RewardScreenState extends State<RewardScreen>
    with TickerProviderStateMixin {
  bool _showConfetti = true;
  bool _claimed = false;
  bool _isDismissing = false;
  bool _showHistory = false;

  /// Кількість отриманих нагород за сесію.
  int _claimCount = 0;

  /// Загальна сума XP за сесію.
  int _totalXpClaimed = 0;

  /// Загальна сума монет за сесію.
  int _totalCoinsClaimed = 0;

  /// Розширена історія нагород.
  final List<_RewardHistoryItem> _extendedHistory = [];

  late AnimationController _bounceController;
  late AnimationController _glowController;
  late AnimationController _shimmerController;
  late AnimationController _dismissController;

  late Animation<double> _bounceAnim;
  late Animation<double> _glowPulseAnim;
  late Animation<double> _shimmerAnim;

  final _recentRewards = const [
    _RewardHistoryItem(Icons.emoji_events_rounded, 'Майстер викликів', '+15 XP', 'вчора'),
    _RewardHistoryItem(Icons.star_rounded, 'Перший внесок', '+5 XP', '2 дні тому'),
    _RewardHistoryItem(Icons.local_fire_department_rounded, 'Серія 7 днів', '+20 XP', '3 дні тому'),
  ];

  final _categories = const [
    _RewardCategoryData(Icons.emoji_events_rounded, 'Виклики', 8),
    _RewardCategoryData(Icons.flag_rounded, 'Цілі', 3),
    _RewardCategoryData(Icons.local_fire_department_rounded, 'Серії', 5),
    _RewardCategoryData(Icons.workspace_premium_rounded, 'Досягнення', 2),
  ];

  @override
  void initState() {
    super.initState();

    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _bounceAnim = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.3), weight: 45),
      TweenSequenceItem(tween: Tween(begin: 1.3, end: 0.9), weight: 15),
      TweenSequenceItem(tween: Tween(begin: 0.9, end: 1.05), weight: 20),
      TweenSequenceItem(tween: Tween(begin: 1.05, end: 1.0), weight: 20),
    ]).animate(CurvedAnimation(
      parent: _bounceController,
      curve: Curves.elasticOut,
    ));

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _glowPulseAnim = Tween<double>(begin: 0.3, end: 0.7).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();
    _shimmerAnim = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _shimmerController, curve: Curves.linear),
    );

    _dismissController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );

    _bounceController.forward();

    Future.delayed(const Duration(milliseconds: 100), () {
      HapticService.badgeUnlock();
    });
  }

  @override
  void dispose() {
    _bounceController.dispose();
    _glowController.dispose();
    _shimmerController.dispose();
    _dismissController.dispose();
    super.dispose();
  }

  void _onClaim() {
    if (_claimed) return;
    HapticService.success();
    setState(() {
      _claimed = true;
      _showConfetti = false;
    });
    widget.onClaim?.call();
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) Navigator.of(context).pop();
    });
  }

  void _dismissOverlay() {
    if (_claimed || _isDismissing) return;
    setState(() => _isDismissing = true);
    _dismissController.forward().then((_) {
      if (mounted) Navigator.of(context).pop();
    });
  }

  void _showGiftDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Подарувати нагороду'),
        content: Text(
          'Бажаєте подарувати «${widget.badgeName}» другу?',
          style: AppTypography.bodyMedium,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Скасувати')),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Нагороду подаровано!')),
              );
            },
            child: const Text('Подарувати'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColorsPS5.background : AppColorsMonitor.background;
    final textColor = isDark ? AppColorsPS5.textPrimary : AppColorsMonitor.textPrimary;
    final subColor = isDark ? AppColorsPS5.textSecondary : AppColorsMonitor.textSecondary;
    final accentColor = isDark ? AppColorsPS5.accent : AppColorsMonitor.accent;
    final cardColor = isDark ? AppColorsPS5.card : AppColorsMonitor.card;
    final borderColor = isDark ? AppColorsPS5.border : AppColorsMonitor.border;

    return Scaffold(
      backgroundColor: bgColor,
      body: Stack(
        children: [
          if (_showConfetti)
            const Positioned.fill(
              child: AppConfetti(particleCount: 50),
            ),

          Positioned.fill(
            child: GestureDetector(
              onTap: _dismissOverlay,
              child: AnimatedBuilder(
                animation: _dismissController,
                builder: (context, _) {
                  final opacity = _isDismissing
                      ? (1.0 - _dismissController.value) * 0.3
                      : 0.3;
                  return Container(color: Colors.black.withOpacity(opacity));
                },
              ),
            ),
          ),

          SafeArea(
            child: Center(
              child: GestureDetector(
                onTap: _dismissOverlay,
                child: AnimatedBuilder(
                  animation: _dismissController,
                  builder: (context, child) {
                    final dismissScale = _isDismissing
                        ? 1.0 - _dismissController.value * 0.1
                        : 1.0;
                    final dismissOpacity = _isDismissing
                        ? 1.0 - _dismissController.value
                        : 1.0;
                    return Opacity(
                      opacity: dismissOpacity,
                      child: Transform.scale(
                        scale: dismissScale,
                        child: IgnorePointer(
                          ignoring: false,
                          child: SingleChildScrollView(
                            physics: const NeverScrollableScrollPhysics(),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // ── Категорія нагороди ──────────────────
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: accentColor.withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(Radii.xl),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(widget.badgeIcon, size: 14, color: accentColor),
                                      const SizedBox(width: 4),
                                      Text(
                                        widget.rewardCategory,
                                        style: AppTypography.labelSmall.copyWith(
                                          color: accentColor,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ).animate().fade(delay: 100.ms, duration: 300.ms),

                                const SizedBox(height: Spacing.xl),

                                // ── Badge icon (bounce + glow + shimmer) ──
                                _buildBadgeIcon(accentColor),

                                const SizedBox(height: Spacing.xxl),

                                // ── Badge name (fade-in + slide-up) ────
                                _buildBadgeName(textColor),

                                const SizedBox(height: Spacing.md),

                                // ── Description (fade-in) ──────────────
                                _buildDescription(subColor),

                                // ── Level up badge ────────────────────
                                if (widget.levelUp) ...[
                                  const SizedBox(height: Spacing.md),
                                  _buildLevelUpBadge(),
                                ],

                                const SizedBox(height: Spacing.lg),

                                // ── Категорії нагород ──────────────────
                                _buildCategoriesSection(accentColor, subColor, isDark),

                                const SizedBox(height: Spacing.md),

                                // ── XP + Coins reward card ────────────
                                _buildRewardCard(
                                  accentColor,
                                  cardColor,
                                  borderColor,
                                ),

                                const SizedBox(height: Spacing.xxl),

                                // ── "Забрати" button ──────────────────
                                _buildClaimButton(accentColor),

                                const SizedBox(height: Spacing.md),

                                // ── Share + Gift buttons ──────────────
                                _buildActionButtons(subColor),

                                const SizedBox(height: Spacing.md),

                                // ── Toggle history ────────────────────
                                _buildHistoryToggle(subColor),

                                // ── Reward history ────────────────────
                                if (_showHistory) ...[
                                  const SizedBox(height: Spacing.md),
                                  _buildRewardHistory(isDark),
                                ],

                                const SizedBox(height: Spacing.xl),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                  child: const SizedBox.shrink(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriesSection(Color accent, Color sub, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: Spacing.xl),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: _categories.map((cat) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: Spacing.xs),
            child: Column(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: accent.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(Radii.sm),
                  ),
                  child: Icon(cat.icon, color: accent, size: 18),
                ),
                const SizedBox(height: 2),
                Text(
                  '${cat.count}',
                  style: AppTypography.monoCaption.copyWith(
                    color: isDark ? AppColorsPS5.accent : AppColorsMonitor.accent,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  cat.name,
                  style: AppTypography.caption.copyWith(
                    color: isDark ? AppColorsPS5.textHint : AppColorsMonitor.textHint,
                    fontSize: 9,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    ).animate().fade(delay: 500.ms, duration: 400.ms);
  }

  Widget _buildRewardHistory(bool isDark) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: Spacing.xl),
      padding: const EdgeInsets.all(Spacing.md),
      decoration: BoxDecoration(
        color: isDark ? AppColorsPS5.card : AppColorsMonitor.card,
        borderRadius: BorderRadius.circular(Radii.md),
        border: Border.all(color: isDark ? AppColorsPS5.border : AppColorsMonitor.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Останні нагороди', style: AppTypography.labelMedium.copyWith(
            color: isDark ? AppColorsPS5.textPrimary : AppColorsMonitor.textPrimary,
          )),
          const SizedBox(height: Spacing.sm),
          ..._recentRewards.map((r) => Padding(
            padding: const EdgeInsets.only(bottom: Spacing.xs),
            child: Row(
              children: [
                Icon(r.icon, size: 16, color: isDark ? AppColorsPS5.accent : AppColorsMonitor.accent),
                const SizedBox(width: Spacing.sm),
                Expanded(
                  child: Text(r.name, style: AppTypography.bodySmall.copyWith(
                    color: isDark ? AppColorsPS5.textPrimary : AppColorsMonitor.textPrimary,
                  )),
                ),
                Text(r.xp, style: AppTypography.monoCaption.copyWith(
                  color: isDark ? AppColorsPS5.xp : AppColorsMonitor.xp,
                )),
                const SizedBox(width: Spacing.sm),
                Text(r.time, style: AppTypography.caption.copyWith(
                  color: isDark ? AppColorsPS5.textHint : AppColorsMonitor.textHint,
                )),
              ],
            ),
          )),
        ],
      ),
    ).animate().fade(duration: 300.ms);
  }

  Widget _buildHistoryToggle(Color subColor) {
    return TextButton(
      onPressed: () => setState(() => _showHistory = !_showHistory),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.history_rounded,
            color: subColor.withOpacity(0.5),
            size: 16,
          ),
          const SizedBox(width: Spacing.xs),
          Text(
            _showHistory ? 'Сховати історію' : 'Історія нагород',
            style: AppTypography.labelMedium.copyWith(
              color: subColor.withOpacity(0.5),
            ),
          ),
        ],
      ),
    ).animate().fade(delay: 1200.ms, duration: 300.ms);
  }

  Widget _buildActionButtons(Color subColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TextButton(
          onPressed: _claimed ? () {} : null,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.share_rounded,
                  color: subColor.withOpacity(_claimed ? 0.7 : 0.3), size: 18),
              const SizedBox(width: Spacing.xs),
              Text(
                'Поділитися',
                style: AppTypography.labelMedium.copyWith(
                  color: subColor.withOpacity(_claimed ? 0.7 : 0.3),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: Spacing.md),
        TextButton(
          onPressed: _claimed ? _showGiftDialog : null,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.card_giftcard_rounded,
                  color: subColor.withOpacity(_claimed ? 0.7 : 0.3), size: 18),
              const SizedBox(width: Spacing.xs),
              Text(
                'Подарувати',
                style: AppTypography.labelMedium.copyWith(
                  color: subColor.withOpacity(_claimed ? 0.7 : 0.3),
                ),
              ),
            ],
          ),
        ),
      ],
    ).animate().fade(delay: 1100.ms, duration: 300.ms);
  }

  Widget _buildBadgeIcon(Color accentColor) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _bounceController,
        _glowController,
        _shimmerController,
      ]),
      builder: (context, _) {
        final scale = _bounceAnim.value;
        final glowOpacity = _glowPulseAnim.value;
        final shimmerValue = _shimmerAnim.value;

        return Transform.scale(
          scale: scale,
          child: Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: accentColor.withOpacity(0.08),
              border: Border.all(
                color: accentColor.withOpacity(0.25),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: accentColor.withOpacity(glowOpacity),
                  blurRadius: 50,
                  spreadRadius: 12,
                ),
                BoxShadow(
                  color: accentColor.withOpacity(glowOpacity * 0.4),
                  blurRadius: 100,
                  spreadRadius: 24,
                ),
              ],
            ),
            child: ClipOval(
              child: Stack(
                children: [
                  Container(color: accentColor.withOpacity(0.05)),
                  if (shimmerValue >= -0.5 && shimmerValue <= 1.5)
                    Positioned(
                      left: shimmerValue * 140 - 40,
                      top: 0,
                      bottom: 0,
                      child: Container(
                        width: 80,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.white.withOpacity(0.0),
                              Colors.white.withOpacity(0.15),
                              Colors.white.withOpacity(0.0),
                            ],
                          ),
                        ),
                      ),
                    ),
                  Center(
                    child: Icon(
                      widget.badgeIcon,
                      color: accentColor,
                      size: 64,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBadgeName(Color textColor) {
    return Text(
      widget.badgeName,
      style: AppTypography.displayMedium.copyWith(
        color: textColor,
        fontSize: 28,
        fontWeight: FontWeight.w800,
      ),
      textAlign: TextAlign.center,
    )
        .animate()
        .fade(delay: 300.ms, duration: 500.ms)
        .slideY(begin: 0.2, end: 0, delay: 300.ms, duration: 500.ms);
  }

  Widget _buildDescription(Color subColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Spacing.xl),
      child: Text(
        widget.description,
        style: AppTypography.bodyMedium.copyWith(color: subColor),
        textAlign: TextAlign.center,
      ),
    ).animate().fade(delay: 500.ms, duration: 500.ms);
  }

  Widget _buildLevelUpBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColorsPS5.gradientStart, AppColorsPS5.gradientEnd],
        ),
        borderRadius: BorderRadius.circular(Radii.xl),
        boxShadow: [
          BoxShadow(
            color: AppColorsPS5.accent.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: const Text(
        '⬆ ПІДВИЩЕННЯ РІВНЯ!',
        style: AppTypography.labelMedium.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w700,
        ),
      ),
    )
        .animate()
        .fade(delay: 600.ms, duration: 400.ms)
        .scale(delay: 600.ms, begin: const Offset(0.8, 0.8));
  }

  Widget _buildRewardCard(Color accentColor, Color cardColor, Color borderColor) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.xl,
        vertical: Spacing.md + 4,
      ),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(Radii.xl),
        border: Border.all(color: borderColor),
        boxShadow: AppShadows.card(cardColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: AppColorsPS5.xp.withOpacity(0.1),
              borderRadius: BorderRadius.circular(Radii.md),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.star_rounded, color: AppColorsPS5.xp, size: 22),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('XP', style: AppTypography.caption.copyWith(
                      color: AppColorsPS5.xp.withOpacity(0.7), fontSize: 10,
                    )),
                    Text('+${widget.xpReward}', style: AppTypography.monoSmall.copyWith(
                      color: AppColorsPS5.xp, fontWeight: FontWeight.w800, fontSize: 16,
                    )),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: Spacing.md),
          Container(width: 1, height: 36, color: borderColor),
          const SizedBox(width: Spacing.md),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: AppColorsPS5.coin.withOpacity(0.1),
              borderRadius: BorderRadius.circular(Radii.md),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.monetization_on_rounded, color: AppColorsPS5.coin, size: 22),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Монети', style: AppTypography.caption.copyWith(
                      color: AppColorsPS5.coin.withOpacity(0.7), fontSize: 10,
                    )),
                    Text('+${widget.coinReward}', style: AppTypography.monoSmall.copyWith(
                      color: AppColorsPS5.coin, fontWeight: FontWeight.w800, fontSize: 16,
                    )),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    )
        .animate()
        .fade(delay: 700.ms, duration: 400.ms)
        .scale(delay: 700.ms, begin: const Offset(0.8, 0.8), duration: 400.ms);
  }

  Widget _buildClaimButton(Color accentColor) {
    return GestureDetector(
      onTap: _claimed ? null : _onClaim,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        height: 56,
        padding: const EdgeInsets.symmetric(horizontal: Spacing.xxl),
        decoration: BoxDecoration(
          gradient: _claimed
              ? LinearGradient(
                  colors: [
                    AppColorsPS5.success.withOpacity(0.8),
                    AppColorsPS5.success.withOpacity(0.6),
                  ],
                )
              : LinearGradient(
                  colors: [accentColor, accentColor.withOpacity(0.8)],
                ),
          borderRadius: BorderRadius.circular(Radii.base),
          boxShadow: AppShadows.glow(
            _claimed ? AppColorsPS5.success : accentColor,
          ),
        ),
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _claimed ? Icons.check_rounded : Icons.card_giftcard_rounded,
                color: Colors.white,
                size: 24,
              ),
              const SizedBox(width: Spacing.sm),
              Text(
                _claimed ? 'Забрано!' : 'Забрати',
                style: AppTypography.buttonLarge.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    )
        .animate()
        .fade(delay: 900.ms, duration: 400.ms)
        .slideY(begin: 0.15, end: 0, delay: 900.ms, duration: 400.ms);
  }
}

class _RewardHistoryItem {
  final IconData icon;
  final String name;
  final String xp;
  final String time;

  const _RewardHistoryItem(this.icon, this.name, this.xp, this.time);
}

class _RewardCategoryData {
  /// Іконка категорії нагороди.
  final IconData icon;

  /// Назва категорії.
  final String name;

  /// Кількість нагород у категорії.
  final int count;

  /// Створює дані категорії нагороди.
  const _RewardCategoryData(this.icon, this.name, this.count);
}

/// Аналітика нагород для розрахунку статистики.
class _RewardAnalytics {
  /// Створює об'єкт аналітики нагород.
  const _RewardAnalytics();

  /// Обчислює загальну суму XP зі списку нагород.
  int totalXp(List<_RewardHistoryItem> items) {
    if (items.isEmpty) return 0;
    try {
      return items.fold<int>(0, (sum, item) {
        final cleaned = item.xp.replaceAll(RegExp(r'[^0-9]'), '');
        return sum + (int.tryParse(cleaned) ?? 0);
      });
    } catch (e) {
      debugPrint('[RewardAnalytics] Error calculating total XP: $e');
      return 0;
    }
  }

  /// Повертає найціннішу нагороду за XP.
  _RewardHistoryItem? mostValuable(List<_RewardHistoryItem> items) {
    if (items.isEmpty) return null;
    try {
      return items.reduce((a, b) {
        final aXp = int.tryParse(a.xp.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
        final bXp = int.tryParse(b.xp.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
        return aXp >= bXp ? a : b;
      });
    } catch (e) {
      debugPrint('[RewardAnalytics] Error finding most valuable: $e');
      return items.first;
    }
  }

  /// Обчислює середнє XP за нагороду.
  double averageXp(List<_RewardHistoryItem> items) {
    if (items.isEmpty) return 0.0;
    try {
      return totalXp(items) / items.length;
    } catch (e) {
      return 0.0;
    }
  }

  /// Повертає кількість унікальних типів нагород.
  int uniqueRewardTypes(List<_RewardHistoryItem> items) {
    if (items.isEmpty) return 0;
    try {
      return items.map((e) => e.name).toSet().length;
    } catch (e) {
      return 0;
    }
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Додаткові константи екрану нагород
// ═══════════════════════════════════════════════════════════════════════════

/// Мінімальна кількість XP для «legendary» нагороди.
const int _kLegendaryXpThreshold = 200;

/// Мінімальна кількість монет для «legendary» нагороди.
const int _kLegendaryCoinThreshold = 100;

/// Тривалість анімації появи reward card (мілісекунди).
const int _kRewardCardAnimMs = 600;

/// Тривалість затримки перед показом reward details (мілісекунди).
const int _kRewardDetailsDelayMs = 400;

/// Кількість категорій нагород для відображення в summary.
const int _kMaxVisibleCategories = 6;

/// Мінімальна кількість нагород для badge «Колекціонер».
const int _kCollectorThreshold = 15;

/// Тривалість shimmer-ефекту для rare badge (мілісекунди).
const int _kRareShimmerMs = 2500;

/// Максимальна кількість записів у summary grid.
const int _kSummaryGridLimit = 12;

/// Тривалість затримки перед автозакриттям (мілісекунди).
const int _kAutoDismissDelayMs = 5000;

/// Кількість рівнів rarity для нагород.
const int _kRarityLevels = 5;

/// Назви рівнів rarity нагород.
const List<String> _kRarityLabels = [
  'Common',
  'Uncommon',
  'Rare',
  'Epic',
  'Legendary',
];

/// Кольори рівнів rarity нагород.
const List<Color> _kRarityColors = [
  Color(0xFF9E9E9E),
  Color(0xFF4CAF50),
  Color(0xFF2196F3),
  Color(0xFF9C27B0),
  Color(0xFFFF9800),
];

/// Максимальна кількість badge для одного користувача.
const int _kMaxBadgeCount = 50;

/// Тривалість анімації badge collection slide (мілісекунди).
const int _kBadgeSlideMs = 350;

/// Формат дати для записів історії нагород.
const String _kRewardDateFormat = 'dd.MM.yyyy';

/// Кількість нагород для «batch unlock» режиму.
const int _kBatchUnlockSize = 3;

/// Затримка між batch unlock анімаціями (мілісекунди).
const int _kBatchUnlockDelayMs = 300;

/// Префікс для ключів кешу нагород.
const String _kRewardCachePrefix = 'reward_';

/// Максимальна кількість записів у кеші нагород.
const int _kRewardMaxCacheEntries = 25;

/// Мінімальний розмір тексту badge name (пікселі).
const double _kMinBadgeFontSize = 14.0;

/// Максимальна кількість символів у назві нагороди.
const int _kMaxRewardNameLength = 40;

/// Кількість днів для аналізу трендів нагород.
const int _kRewardTrendDays = 30;

// ═══════════════════════════════════════════════════════════════════════════
// Розширена валідація нагород
// ═══════════════════════════════════════════════════════════════════════════

/// Клас для валідації даних екрану нагород.
///
/// Перевіряє коректність параметрів нагород, XP, монет,
/// розмірів badge та конфігурацій анімацій.
class _RewardValidator {
  /// Не дозволяє створення екземплярів.
  _RewardValidator._();

  /// Перевіряє, чи значення XP в допустимому діапазоні.
  ///
  /// [xp] — значення XP.
  static bool isValidXp(int xp) {
    return xp >= 0 && xp <= 100000;
  }

  /// Перевіряє, чи значення монет в допустимому діапазоні.
  ///
  /// [coins] — значення монет.
  static bool isValidCoins(int coins) {
    return coins >= 0 && coins <= 100000;
  }

  /// Перевіряє, чи розмір badge в допустимих межах.
  ///
  /// [size] — розмір badge в пікселях.
  static bool isValidBadgeSize(double size) {
    return size >= 40.0 && size <= 300.0;
  }

  /// Перевіряє, чи назва нагороди в допустимих межах.
  ///
  /// [name] — назва нагороди.
  static bool isValidRewardName(String name) {
    if (name.isEmpty) return false;
    if (name.trim().length > _kMaxRewardNameLength) return false;
    return name.trim().isNotEmpty;
  }

  /// Перевіряє, чи кількість записів історії в межах ліміту.
  ///
  /// [count] — поточна кількість записів.
  static bool canAddToHistory(int count) {
    return count < _kMaxRewardHistory;
  }

  /// Перевіряє, чи кількість badge в межах ліміту.
  ///
  /// [count] — поточна кількість badge.
  static bool canAddBadge(int count) {
    return count < _kMaxBadgeCount;
  }

  /// Повертає рівень rarity на основі XP та монет.
  ///
  /// [xp] — кількість XP.
  /// [coins] — кількість монет.
  static int rarityLevel(int xp, int coins) {
    if (xp >= _kLegendaryXpThreshold || coins >= _kLegendaryCoinThreshold) {
      return 4; // Legendary
    } else if (xp >= _kBigRewardXpThreshold) {
      return 3; // Epic
    } else if (xp >= 20) {
      return 2; // Rare
    } else if (xp >= 10) {
      return 1; // Uncommon
    }
    return 0; // Common
  }

  /// Повертає назву рівня rarity.
  ///
  /// [level] — рівень rarity (0-4).
  static String rarityLabel(int level) {
    if (level < 0 || level >= _kRarityLabels.length) return 'Unknown';
    return _kRarityLabels[level];
  }

  /// Повертає колір рівня rarity.
  ///
  /// [level] — рівень rarity (0-4).
  static Color rarityColor(int level) {
    if (level < 0 || level >= _kRarityColors.length) {
      return const Color(0xFF9E9E9E);
    }
    return _kRarityColors[level];
  }

  /// Перевіряє, чи конфігурація анімації коректна.
  ///
  /// [duration] — тривалість.
  /// [delay] — затримка.
  static bool isValidAnimConfig(int duration, int delay) {
    return duration > 0 && delay >= 0 && delay < duration;
  }

  /// Перевіряє, чи кількість confetti частинок допустима.
  ///
  /// [count] — кількість частинок.
  static bool isValidConfettiCount(int count) {
    return count >= 0 && count <= 200;
  }

  /// Повертає очищену назву нагороди.
  ///
  /// [name] — необроблена назва.
  static String sanitizedRewardName(String name) {
    if (name.isEmpty) return 'Невідома нагорода';
    final trimmed = name.trim();
    if (trimmed.length > _kMaxRewardNameLength) {
      return '${trimmed.substring(0, _kMaxRewardNameLength - 3)}...';
    }
    return trimmed;
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Кеш нагород для оптимізації продуктивності
// ═══════════════════════════════════════════════════════════════════════════

/// Клас для кешування даних нагород.
///
/// Зберігає оброблені списки, зображення та обчислені метрики
/// для зменшення кількості обчислень при rebuild.
class _RewardCache {
  /// Створює кеш з початковими значеннями.
  _RewardCache();

  /// Внутрішнє сховище.
  final Map<String, dynamic> _store = {};

  /// Зберігає значення за ключем.
  ///
  /// [key] — унікальний ключ.
  /// [value] — значення для кешування.
  void put(String key, dynamic value) {
    if (_store.length >= _kRewardMaxCacheEntries) {
      _store.remove(_store.keys.first);
    }
    _store['$_kRewardCachePrefix$key'] = value;
  }

  /// Отримує значення з кешу.
  ///
  /// [key] — унікальний ключ.
  T? get<T>(String key) {
    final value = _store['$_kRewardCachePrefix$key'];
    if (value is T) return value;
    return null;
  }

  /// Перевіряє наявність ключа.
  bool contains(String key) => _store.containsKey('$_kRewardCachePrefix$key');

  /// Видаляє запис.
  void remove(String key) {
    _store.remove('$_kRewardCachePrefix$key');
  }

  /// Очищає кеш.
  void clear() => _store.clear();

  /// Розмір кешу.
  int get size => _store.length;

  /// Чи порожній.
  bool get isEmpty => _store.isEmpty;
}

// ═══════════════════════════════════════════════════════════════════════════
// Темо-залежний будівник декорацій для нагород
// ═══════════════════════════════════════════════════════════════════════════

/// Будівник декорацій для екрану нагород.
///
/// Надає готові методи для створення темо-залежних
/// декорацій badge, карток нагород, shimmer-ефектів.
class _RewardDecorations {
  /// Не дозволяє створення екземплярів.
  _RewardDecorations._();

  /// Створює декорацію для основного badge контейнера.
  ///
  /// [rarityLevel] — рівень rarity (0-4).
  static BoxDecoration badgeContainer(int rarityLevel) {
    final color = _RewardValidator.rarityColor(rarityLevel);
    return BoxDecoration(
      shape: BoxShape.circle,
      gradient: RadialGradient(
        colors: [
          color.withOpacity(0.3),
          color.withOpacity(0.1),
          color.withOpacity(0.05),
        ],
        radius: 0.7,
      ),
      boxShadow: [
        BoxShadow(
          color: color.withOpacity(0.4),
          blurRadius: 20,
          spreadRadius: 4,
        ),
      ],
    );
  }

  /// Створює декорацію для картки нагороди з gradient.
  ///
  /// [rarityColor] — колір rarity.
  static BoxDecoration rewardCard(Color rarityColor) {
    return BoxDecoration(
      gradient: LinearGradient(
        colors: [
          rarityColor.withOpacity(0.12),
          rarityColor.withOpacity(0.04),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(Radii.xl),
      border: Border.all(color: rarityColor.withOpacity(0.2)),
    );
  }

  /// Створює декорацію для запису історії нагород.
  ///
  /// [isDark] — чи використовується темна тема.
  static BoxDecoration historyEntry(bool isDark) {
    return BoxDecoration(
      color: (isDark ? AppColorsPS5.card : AppColorsMonitor.card).withOpacity(0.7),
      borderRadius: BorderRadius.circular(Radii.md),
      border: Border.all(
        color: (isDark ? AppColorsPS5.border : AppColorsMonitor.border).withOpacity(0.4),
      ),
    );
  }

  /// Створює декорацію для XP reward badge.
  ///
  /// [xpColor] — колір XP.
  static BoxDecoration xpBadge(Color xpColor) {
    return BoxDecoration(
      color: xpColor.withOpacity(0.15),
      borderRadius: BorderRadius.circular(Radii.md),
      border: Border.all(color: xpColor.withOpacity(0.3)),
    );
  }

  /// Створює декорацію для coins reward badge.
  static BoxDecoration coinsBadge() {
    return BoxDecoration(
      color: AppColorsPS5.coin.withOpacity(0.15),
      borderRadius: BorderRadius.circular(Radii.md),
      border: Border.all(color: AppColorsPS5.coin.withOpacity(0.3)),
    );
  }

  /// Створює декорацію для категорії нагороди.
  ///
  /// [color] — колір категорії.
  static BoxDecoration categoryCard(Color color) {
    return BoxDecoration(
      color: color.withOpacity(0.08),
      borderRadius: BorderRadius.circular(Radii.lg),
      border: Border.all(color: color.withOpacity(0.15)),
    );
  }

  /// Створює декорацію для кнопки «Забрати».
  ///
  /// [accent] — акцентний колір.
  static BoxDecoration claimButton(Color accent) {
    return BoxDecoration(
      gradient: LinearGradient(
        colors: [accent, accent.withOpacity(0.8)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(Radii.lg),
      boxShadow: [
        BoxShadow(
          color: accent.withOpacity(0.3),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Провайдер підказок для екрану нагород
// ═══════════════════════════════════════════════════════════════════════════

/// Провайдер контекстних підказок для користувача екрану нагород.
class _RewardTipProvider {
  /// Не дозволяє створення екземплярів.
  _RewardTipProvider._();

  /// Підказка для legendary нагороди.
  static String legendaryTip() {
    return 'Legendary нагорода! Ти один з найкращих користувачів!';
  }

  /// Підказка для epic нагороди.
  static String epicTip() {
    return 'Epic нагорода! Чудовий результат!';
  }

  /// Підказка для rare нагороди.
  static String rareTip() {
    return 'Rare нагорода! Ти на правильному шляху!';
  }

  /// Підказка для common нагороди.
  static String commonTip() {
    return 'Перша нагорода! Продовжуй виконувати виклики!';
  }

  /// Повертає підказку залежно від рівня rarity.
  ///
  /// [level] — рівень rarity (0-4).
  static String contextualTip(int level) {
    switch (level) {
      case 4: return legendaryTip();
      case 3: return epicTip();
      case 2: return rareTip();
      default: return commonTip();
    }
  }

  /// Підказка для першої нагороди дня.
  static String firstRewardOfDayTip() {
    return 'Вітаємо з першою нагородою сьогодні!';
  }

  /// Підказка для досягнення badge «Колекціонер».
  static String collectorTip(int badgeCount) {
    return 'У тебе вже $badgeCount значків! Ти справжній колекціонер!';
  }

  /// Підказка для batch unlock.
  static String batchUnlockTip(int count) {
    return 'Ви отримали $count нагороди одразу! Дивовижно!';
  }

  /// Підказка для заохочення подальших досягнень.
  static String nextMilestoneTip(int xpToNext) {
    if (xpToNext <= 0) return 'Ти досяг максимального рівня!';
    return 'Ще $xpToNext XP до наступної нагороди. Не зупиняйся!';
  }

  /// Підказка для порожньої історії нагород.
  static String emptyHistoryTip() {
    return 'Тут з\'являться твої нагороди за виконані виклики.';
  }

  /// Підказка для daily challenge нагороди.
  static String dailyChallengeTip() {
    return 'Виконай щоденний виклик, щоб отримати бонусну нагороду!';
  }

  /// Підказка для streak bonus нагороди.
  static String streakBonusTip(int streakDays) {
    return 'Бонус за серію $streakDays днів! Тримай марку!';
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Розширення для роботи з колекціями нагород
// ═══════════════════════════════════════════════════════════════════════════

/// Розширення для списку записів історії нагород з пакетними операціями.
extension _RewardHistoryListExtension on List<_RewardHistoryItem> {
  /// Сортує за датою (найновіші перші).
  List<_RewardHistoryItem> sortedByDate() {
    final copy = List<_RewardHistoryItem>.from(this);
    copy.sort((a, b) => b.date.compareTo(a.date));
    return copy;
  }

  /// Сортує за XP (найбільші перші).
  List<_RewardHistoryItem> sortedByXp() {
    final copy = List<_RewardHistoryItem>.from(this);
    copy.sort((a, b) {
      final aXp = int.tryParse(a.xp.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
      final bXp = int.tryParse(b.xp.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
      return bXp.compareTo(aXp);
    });
    return copy;
  }

  /// Фільтрує записи за назвою нагороди.
  ///
  /// [name] — назва для фільтрації.
  List<_RewardHistoryItem> filterByName(String name) {
    return where((e) => e.name.toLowerCase().contains(name.toLowerCase())).toList();
  }

  /// Повертає найновіші [count] записів.
  List<_RewardHistoryItem> takeRecent({int count = 5}) {
    return sortedByDate().take(count.clamp(1, length)).toList();
  }

  /// Повертає унікальні назви нагород.
  List<String> uniqueNames() {
    return map((e) => e.name).toSet().toList()..sort();
  }

  /// Розбиває на партії для batch обробки.
  ///
  /// [batchSize] — розмір партії.
  List<List<_RewardHistoryItem>> batched(int batchSize) {
    if (isEmpty) return [];
    final batches = <List<_RewardHistoryItem>>[];
    for (var i = 0; i < length; i += batchSize) {
      final end = (i + batchSize).clamp(0, length);
      batches.add(sublist(i, end));
    }
    return batches;
  }

  /// Обчислює загальну кількість XP.
  int totalXpValue() {
    return fold<int>(0, (sum, item) {
      final cleaned = item.xp.replaceAll(RegExp(r'[^0-9]'), '');
      return sum + (int.tryParse(cleaned) ?? 0);
    });
  }

  /// Обчислює загальну кількість монет.
  int totalCoinsValue() {
    return fold<int>(0, (sum, item) {
      final cleaned = item.coins.replaceAll(RegExp(r'[^0-9]'), '');
      return sum + (int.tryParse(cleaned) ?? 0);
    });
  }
}
