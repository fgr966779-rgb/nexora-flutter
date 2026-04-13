import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_radii.dart';
import '../../../../core/extensions/build_context_ext.dart';
import '../../../../core/widgets/app_confetti.dart';

/// Екран «Значки» — лічильник, сітка розблокованих та заблокованих значків, найближчий значок,
/// рідкість, колекційний прогрес, порівняння, вітрина.
class BadgesScreen extends StatefulWidget {
  BadgesScreen({super.key});

  @override
  State<BadgesScreen> createState() => _BadgesScreenState();
}

class _BadgesScreenState extends State<BadgesScreen> {
  final List<String> unlocked = const [
    'firstStep', 'weeklyStreak', 'frostScream', 'nightOwl', 'fastStart',
  ];

  static const _allBadges = [
    _BadgeData('firstStep', 'Перший внесок', Icons.monetization_on_rounded,
        'Зроби свій перший внесок у будь-яку ціль', 'Виконано!', _BadgeRarity.common),
    _BadgeData('weeklyStreak', 'Тиждень поспіль', Icons.local_fire_department_rounded,
        'Зроби внески 7 днів поспіль', 'Виконано!', _BadgeRarity.rare),
    _BadgeData('monthlyMarathon', 'Місячний марафон', Icons.diamond_rounded,
        'Зроби внески 30 днів поспіль', '31 / 30 днів', _BadgeRarity.epic),
    _BadgeData('frostScream', 'Морозний стрижок', Icons.ac_unit_rounded,
        'Зроби внесок у холодний день (нище 0°C)', 'Виконано!', _BadgeRarity.rare),
    _BadgeData('nightOwl', 'Нічна сова', Icons.dark_mode_rounded,
        'Зроби внесок після 23:00', 'Виконано!', _BadgeRarity.common),
    _BadgeData('challengeMaster', 'Майстер викликів', Icons.emoji_events_rounded,
        'Виконай 10 щоденних викликів', '7 / 10', _BadgeRarity.epic),
    _BadgeData('wednesdayFriday', 'СР та ПТ', Icons.calendar_month_rounded,
        'Зроби внески у середу та п\'ятницю одного тижня', 'Середа ✓', _BadgeRarity.common),
    _BadgeData('fastStart', 'Швидкий старт', Icons.bolt_rounded,
        'Зроби внесок у перший день створення цілі', 'Виконано!', _BadgeRarity.common),
    _BadgeData('unbreakable', 'Незламний', Icons.shield_rounded,
        'Збережи серію 14 днів поспіль', '14 / 14 днів', _BadgeRarity.rare),
    _BadgeData('collector', 'Колекціонер', Icons.workspace_premium_rounded,
        'Розблокуй 8 інших значків', '5 / 8', _BadgeRarity.legendary),
    _BadgeData('generousSoul', 'Щедра душа', Icons.volunteer_activism_rounded,
        'Поділися досягненням 5 разів', '2 / 5', _BadgeRarity.rare),
    _BadgeData('earlyBird', 'Ранній пташок', Icons.wb_sunny_rounded,
        'Зроби внесок до 7:00 ранку', '0 / 1', _BadgeRarity.epic),
  ];

  String _selectedFilter = 'Усе';
  final _rarityFilters = ['Усе', 'Звичайні', 'Рідкісні', 'Епічні', 'Легендарні'];

  _BadgeData? _nextBadge() {
    for (final b in _allBadges) {
      if (!unlocked.contains(b.id)) return b;
    }
    return null;
  }

  double _nextBadgeProgress(_BadgeData badge) {
    switch (badge.id) {
      case 'monthlyMarathon':
        return 1.0;
      case 'challengeMaster':
        return 0.7;
      case 'wednesdayFriday':
        return 0.5;
      case 'unbreakable':
        return 1.0;
      case 'collector':
        return 0.625;
      case 'generousSoul':
        return 0.4;
      case 'earlyBird':
        return 0.0;
      default:
        return 0.0;
    }
  }

  bool _showConfetti = false;

  void _simulateConfetti() {
    setState(() => _showConfetti = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _showConfetti = false);
    });
  }

  List<_BadgeData> get _filteredBadges {
    if (_selectedFilter == 'Усе') return _allBadges;
    switch (_selectedFilter) {
      case 'Звичайні':
        return _allBadges.where((b) => b.rarity == _BadgeRarity.common).toList();
      case 'Рідкісні':
        return _allBadges.where((b) => b.rarity == _BadgeRarity.rare).toList();
      case 'Епічні':
        return _allBadges.where((b) => b.rarity == _BadgeRarity.epic).toList();
      case 'Легендарні':
        return _allBadges.where((b) => b.rarity == _BadgeRarity.legendary).toList();
      default:
        return _allBadges;
    }
  }

  int _countByRarity(_BadgeRarity rarity) {
    final allOfRarity = _allBadges.where((b) => b.rarity == rarity).length;
    final unlockedOfRarity = unlocked.where((id) => _allBadges
        .where((b) => b.id == id && b.rarity == rarity).isNotEmpty).length;
    return unlockedOfRarity;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final unlockedCount = unlocked.length;
    final totalBadges = _allBadges.length;
    final commonCount = _countByRarity(_BadgeRarity.common);
    final rareCount = _countByRarity(_BadgeRarity.rare);
    final epicCount = _countByRarity(_BadgeRarity.epic);
    final legendaryCount = _countByRarity(_BadgeRarity.legendary);

    return Scaffold(
      backgroundColor:
          isDark ? AppColorsPS5.background : AppColorsMonitor.background,
      body: Stack(
        children: [
          if (_showConfetti)
            const Positioned.fill(child: AppConfetti(particleCount: 80)),
          Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              title: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Значки'),
                  const SizedBox(width: Spacing.sm),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: (isDark
                              ? AppColorsPS5.accent
                              : AppColorsMonitor.accent)
                          .withOpacity(0.15),
                      borderRadius: BorderRadius.circular(Radii.xl),
                    ),
                    child: Text(
                      '$unlockedCount / $totalBadges',
                      style: AppTypography.monoSmall.copyWith(
                        color: isDark
                            ? AppColorsPS5.accent
                            : AppColorsMonitor.accent,
                      ),
                    ),
                  ),
                ],
              ),
              backgroundColor: Colors.transparent,
              elevation: 0,
              foregroundColor: isDark
                  ? AppColorsPS5.textPrimary
                  : AppColorsMonitor.textPrimary,
              actions: [
                IconButton(
                  icon: const Icon(Icons.style_rounded),
                  onPressed: () => _showShowcase(context, isDark),
                  tooltip: 'Вітрина значків',
                ),
              ],
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(Spacing.base),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ─── Прогрес-бар значків ───────────────────────
                  Container(
                    margin: const EdgeInsets.only(bottom: Spacing.xl),
                    padding: const EdgeInsets.all(Spacing.base),
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColorsPS5.card
                          : AppColorsMonitor.card,
                      borderRadius: BorderRadius.circular(Radii.lg),
                      border: Border.all(
                        color: isDark
                            ? AppColorsPS5.border
                            : AppColorsMonitor.border,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Колекція значків',
                              style: AppTypography.labelMedium.copyWith(
                                color: isDark
                                    ? AppColorsPS5.textPrimary
                                    : AppColorsMonitor.textPrimary,
                              ),
                            ),
                            Text(
                              '${(unlockedCount / totalBadges * 100).toInt()}%',
                              style: AppTypography.monoSmall.copyWith(
                                color: isDark
                                    ? AppColorsPS5.accent
                                    : AppColorsMonitor.accent,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: Spacing.sm),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: LinearProgressIndicator(
                            value: unlockedCount / totalBadges,
                            minHeight: 10,
                            backgroundColor: isDark
                                ? AppColorsPS5.border
                                : AppColorsMonitor.border,
                            valueColor: AlwaysStoppedAnimation(
                              isDark
                                  ? AppColorsPS5.accent
                                  : AppColorsMonitor.accent,
                            ),
                          ),
                        ),
                        const SizedBox(height: Spacing.md),
                        // Рідкість розподіл
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _rarityStat('Звичайні', '$commonCount/4', AppColorsPS5.success, isDark),
                            _rarityStat('Рідкісні', '$rareCount/3', AppColorsPS5.accent, isDark),
                            _rarityStat('Епічні', '$epicCount/3', AppColorsPS5.warning, isDark),
                            _rarityStat('Легенд.', '$legendaryCount/2', AppColorsPS5.error, isDark),
                          ],
                        ),
                      ],
                    ),
                  ).animate().fade(delay: 100.ms),

                  // ─── Найближчий значок ─────────────────────────
                  if (_nextBadge() != null) ...[
                    _buildNextBadgeCard(
                        context, _nextBadge()!, isDark),
                    const SizedBox(height: Spacing.xl),
                  ],

                  // ─── Фільтри за рідкістю ──────────────────────
                  SizedBox(
                    height: 40,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _rarityFilters.length,
                      separatorBuilder: (_, __) => const SizedBox(width: Spacing.sm),
                      itemBuilder: (context, i) {
                        final isActive = _rarityFilters[i] == _selectedFilter;
                        return ChoiceChip(
                          label: Text(_rarityFilters[i]),
                          selected: isActive,
                          onSelected: (_) => setState(() => _selectedFilter = _rarityFilters[i]),
                          labelStyle: AppTypography.labelSmall.copyWith(
                            color: isActive ? Colors.white : (isDark ? AppColorsPS5.textSecondary : AppColorsMonitor.textSecondary),
                          ),
                          selectedColor: isDark ? AppColorsPS5.accent : AppColorsMonitor.accent,
                          backgroundColor: isDark ? AppColorsPS5.card : AppColorsMonitor.card,
                          side: BorderSide(color: isDark ? AppColorsPS5.border : AppColorsMonitor.border),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Radii.xl)),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: Spacing.md),

                  // ─── Заголовок сітки ───────────────────────────
                  Text(
                    'Усі значки (${_filteredBadges.length})',
                    style: AppTypography.heading3.copyWith(
                      color: isDark
                          ? AppColorsPS5.textPrimary
                          : AppColorsMonitor.textPrimary,
                    ),
                  ),
                  const SizedBox(height: Spacing.md),

                  // ─── Сітка значків ──────────────────────────────
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _filteredBadges.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: Spacing.md,
                      mainAxisSpacing: Spacing.md,
                      childAspectRatio: 0.85,
                    ),
                    itemBuilder: (context, index) {
                      final badge = _filteredBadges[index];
                      final isUnlocked = unlocked.contains(badge.id);
                      return _BadgeTile(
                        badge: badge,
                        index: index,
                        isUnlocked: isUnlocked,
                        isDark: isDark,
                        onTap: () {
                          if (isUnlocked) {
                            _showBadgeDetails(context, badge, isDark);
                          }
                        },
                      );
                    },
                  ),

                  // ─── Порівняння з іншими ────────────────────────
                  const SizedBox(height: Spacing.xxl),
                  Container(
                    padding: const EdgeInsets.all(Spacing.base),
                    decoration: BoxDecoration(
                      color: isDark ? AppColorsPS5.card : AppColorsMonitor.card,
                      borderRadius: BorderRadius.circular(Radii.lg),
                      border: Border.all(color: isDark ? AppColorsPS5.border : AppColorsMonitor.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Порівняння',
                          style: AppTypography.heading3.copyWith(
                            color: isDark ? AppColorsPS5.textPrimary : AppColorsMonitor.textPrimary,
                          ),
                        ),
                        const SizedBox(height: Spacing.md),
                        _comparisonRow('Ти', unlockedCount, totalBadges, isDark),
                        const SizedBox(height: Spacing.sm),
                        _comparisonRow('Середній користувач', 7, totalBadges, isDark),
                        const SizedBox(height: Spacing.sm),
                        _comparisonRow('Топ 10%', 10, totalBadges, isDark),
                      ],
                    ),
                  ).animate().fade(delay: 400.ms),

                  const SizedBox(height: Spacing.xxxl),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _rarityStat(String label, String value, Color color, bool isDark) {
    return Column(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(height: 2),
        Text(value, style: AppTypography.monoCaption.copyWith(
          color: isDark ? AppColorsPS5.textSecondary : AppColorsMonitor.textSecondary,
        )),
        Text(label, style: AppTypography.caption.copyWith(
          color: isDark ? AppColorsPS5.textHint : AppColorsMonitor.textHint,
          fontSize: 9,
        )),
      ],
    );
  }

  Widget _comparisonRow(String label, int count, int total, bool isDark) {
    final accent = isDark ? AppColorsPS5.accent : AppColorsMonitor.accent;
    return Row(
      children: [
        SizedBox(
          width: 100,
          child: Text(label, style: AppTypography.bodySmall.copyWith(
            color: isDark ? AppColorsPS5.textPrimary : AppColorsMonitor.textPrimary,
          )),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: count / total,
              minHeight: 8,
              backgroundColor: isDark ? AppColorsPS5.border : AppColorsMonitor.border,
              valueColor: AlwaysStoppedAnimation(accent),
            ),
          ),
        ),
        const SizedBox(width: Spacing.sm),
        SizedBox(
          width: 50,
          child: Text('$count/$total', style: AppTypography.monoCaption.copyWith(
            color: isDark ? AppColorsPS5.textHint : AppColorsMonitor.textHint,
          )),
        ),
      ],
    );
  }

  Widget _buildNextBadgeCard(
      BuildContext context, _BadgeData badge, bool isDark) {
    final progress = _nextBadgeProgress(badge);
    final rarityColor = _rarityColor(badge.rarity);

    return Container(
      padding: const EdgeInsets.all(Spacing.base),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            (isDark ? AppColorsPS5.accent : AppColorsMonitor.accent)
                .withOpacity(0.2),
            (isDark ? AppColorsPS5.accent : AppColorsMonitor.accent)
                .withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(Radii.lg),
        border: Border.all(
          color: (isDark ? AppColorsPS5.accent : AppColorsMonitor.accent)
              .withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: (isDark
                          ? AppColorsPS5.accent
                          : AppColorsMonitor.accent)
                      .withOpacity(0.15),
                  borderRadius: BorderRadius.circular(Radii.md),
                ),
                child: Icon(
                  Icons.emoji_events_rounded,
                  color: isDark
                      ? AppColorsPS5.accent
                      : AppColorsMonitor.accent,
                  size: 24,
                ),
              ),
              const SizedBox(width: Spacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Найближчий значок',
                        style: AppTypography.labelMedium.copyWith(
                            color: isDark
                                ? AppColorsPS5.textSecondary
                                : AppColorsMonitor.textSecondary)),
                    const SizedBox(height: 2),
                    Text(badge.name,
                        style: AppTypography.heading3.copyWith(
                            color: isDark
                                ? AppColorsPS5.textPrimary
                                : AppColorsMonitor.textPrimary)),
                  ],
                ),
              ),
              // Рідкість
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: rarityColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(Radii.sm),
                ),
                child: Text(
                  _rarityName(badge.rarity),
                  style: AppTypography.caption.copyWith(
                    color: rarityColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: Spacing.md),
          Text(
            badge.condition,
            style: AppTypography.bodySmall.copyWith(
              color: isDark
                  ? AppColorsPS5.textSecondary
                  : AppColorsMonitor.textSecondary,
            ),
          ),
          const SizedBox(height: Spacing.sm),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 6,
                    backgroundColor: isDark
                        ? AppColorsPS5.border
                        : AppColorsMonitor.border,
                    valueColor: AlwaysStoppedAnimation(
                      isDark ? AppColorsPS5.accent : AppColorsMonitor.accent,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: Spacing.sm),
              Text(
                badge.progressText,
                style: AppTypography.monoCaption.copyWith(
                  color: isDark
                      ? AppColorsPS5.accent
                      : AppColorsMonitor.accent,
                ),
              ),
            ],
          ),
          // Нагорода за значок
          const SizedBox(height: Spacing.sm),
          Row(
            children: [
              Icon(Icons.star_rounded, color: isDark ? AppColorsPS5.xp : AppColorsMonitor.xp, size: 14),
              const SizedBox(width: 4),
              Text(
                '+25 XP за розблокування',
                style: AppTypography.caption.copyWith(
                  color: isDark ? AppColorsPS5.xp : AppColorsMonitor.xp,
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fade(delay: 200.ms).slideY(begin: 0.05, end: 0);
  }

  String _rarityName(_BadgeRarity rarity) {
    switch (rarity) {
      case _BadgeRarity.common:
        return 'Звичайний';
      case _BadgeRarity.rare:
        return 'Рідкісний';
      case _BadgeRarity.epic:
        return 'Епічний';
      case _BadgeRarity.legendary:
        return 'Легендарний';
    }
  }

  Color _rarityColor(_BadgeRarity rarity) {
    switch (rarity) {
      case _BadgeRarity.common:
        return AppColorsPS5.success;
      case _BadgeRarity.rare:
        return AppColorsPS5.accent;
      case _BadgeRarity.epic:
        return AppColorsPS5.warning;
      case _BadgeRarity.legendary:
        return AppColorsPS5.error;
    }
  }

  void _showBadgeDetails(
      BuildContext context, _BadgeData badge, bool isDark) {
    context.haptic();
    _simulateConfetti();
    final rarityColor = _rarityColor(badge.rarity);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? const Color(0xFF1E1E2E) : Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(Spacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: (isDark
                          ? AppColorsPS5.accent
                          : AppColorsMonitor.accent)
                      .withOpacity(0.15),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: (isDark
                              ? AppColorsPS5.accent
                              : AppColorsMonitor.accent)
                          .withOpacity(0.3),
                      blurRadius: 20,
                    ),
                  ],
                ),
                child: Icon(badge.icon,
                    color: isDark
                        ? AppColorsPS5.accent
                        : AppColorsMonitor.accent,
                    size: 48),
              ).animate().scale(
                  duration: 400.ms,
                  curve: Curves.easeOutBack,
                  begin: const Offset(0.5, 0.5)),
              const SizedBox(height: Spacing.lg),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(badge.name,
                      style: AppTypography.heading1.copyWith(
                          color: isDark
                              ? AppColorsPS5.textPrimary
                              : AppColorsMonitor.textPrimary)),
                  const SizedBox(width: Spacing.sm),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: rarityColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(Radii.sm),
                    ),
                    child: Text(_rarityName(badge.rarity),
                        style: AppTypography.labelSmall.copyWith(
                          color: rarityColor,
                          fontWeight: FontWeight.w600,
                        )),
                  ),
                ],
              ),
              const SizedBox(height: Spacing.sm),
              Text('Отримано: 12 січня 2025',
                  style: AppTypography.bodyMedium.copyWith(
                      color: isDark
                          ? AppColorsPS5.textSecondary
                          : AppColorsMonitor.textSecondary)),
              const SizedBox(height: Spacing.md),
              Container(
                padding: const EdgeInsets.all(Spacing.md),
                decoration: BoxDecoration(
                  color: (isDark
                          ? AppColorsPS5.surface
                          : AppColorsMonitor.surface),
                  borderRadius: BorderRadius.circular(Radii.md),
                ),
                child: Text(
                  'Виконано умови для отримання значка «${badge.name}». Умова: ${badge.condition}',
                  style: AppTypography.bodyMedium.copyWith(
                      color: isDark
                          ? AppColorsPS5.textSecondary
                          : AppColorsMonitor.textSecondary),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: Spacing.sm),
              // Нагорода
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColorsPS5.xp.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(Radii.xl),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.star_rounded,
                        color: AppColorsPS5.xp, size: 18),
                    const SizedBox(width: 6),
                    Text(
                      '+25 XP отримано',
                      style: AppTypography.monoSmall.copyWith(
                          color: AppColorsPS5.xp),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: Spacing.md),
              // Поділитися значком
              OutlinedButton.icon(
                onPressed: () {
                  Navigator.pop(ctx);
                  context.showToast('Значок поділено!', icon: Icons.share_rounded);
                },
                icon: const Icon(Icons.share_rounded, size: 16),
                label: const Text('Поділитися значком'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: isDark ? AppColorsPS5.accent : AppColorsMonitor.accent,
                  side: BorderSide(color: (isDark ? AppColorsPS5.accent : AppColorsMonitor.accent).withOpacity(0.3)),
                ),
              ),
              const SizedBox(height: Spacing.base),
            ],
          ),
        ),
      ),
    );
  }

  void _showShowcase(BuildContext context, bool isDark) {
    final unlockedBadges = _allBadges.where((b) => unlocked.contains(b.id)).toList();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? const Color(0xFF1E1E2E) : Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        expand: false,
        builder: (ctx, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(Spacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(
                    color: isDark ? AppColorsPS5.border : AppColorsMonitor.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: Spacing.lg),
              Text(
                'Вітрина значків',
                style: AppTypography.heading2.copyWith(
                  color: isDark ? AppColorsPS5.textPrimary : AppColorsMonitor.textPrimary,
                ),
              ),
              const SizedBox(height: Spacing.md),
              Wrap(
                spacing: Spacing.md,
                runSpacing: Spacing.md,
                children: unlockedBadges.map((badge) {
                  final rarityColor = _rarityColor(badge.rarity);
                  return Column(
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: (isDark ? AppColorsPS5.accent : AppColorsMonitor.accent).withOpacity(0.1),
                          shape: BoxShape.circle,
                          border: Border.all(color: rarityColor.withOpacity(0.5), width: 2),
                        ),
                        child: Icon(badge.icon,
                            color: isDark ? AppColorsPS5.accent : AppColorsMonitor.accent, size: 32),
                      ),
                      const SizedBox(height: Spacing.xs),
                      Text(badge.name,
                        style: AppTypography.caption.copyWith(
                          color: isDark ? AppColorsPS5.textSecondary : AppColorsMonitor.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

enum _BadgeRarity { common, rare, epic, legendary }

class _BadgeData {
  final String id;
  final String name;
  final IconData icon;
  final String condition;
  final String progressText;
  final _BadgeRarity rarity;

  const _BadgeData(
      this.id, this.name, this.icon, this.condition, this.progressText,
      [this.rarity = _BadgeRarity.common]);
}

class _BadgeTile extends StatelessWidget {
  const _BadgeTile({
    required this.badge,
    required this.index,
    required this.isUnlocked,
    required this.isDark,
    required this.onTap,
  });

  final _BadgeData badge;
  final int index;
  final bool isUnlocked;
  final bool isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bgColor = isUnlocked
        ? (isDark ? AppColorsPS5.accent : AppColorsMonitor.accent)
            .withOpacity(0.15)
        : (isDark ? AppColorsPS5.card : AppColorsMonitor.card);

    final rarityColor = isDark ? AppColorsPS5.accent : AppColorsMonitor.accent;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(Radii.lg),
          border: Border.all(
            color: isUnlocked
                ? (isDark
                        ? AppColorsPS5.accent
                        : AppColorsMonitor.accent)
                    .withOpacity(0.4)
                : (isDark ? AppColorsPS5.border : AppColorsMonitor.border),
          ),
          boxShadow: isUnlocked
              ? [
                  BoxShadow(
                    color: (isDark
                            ? AppColorsPS5.accent
                            : AppColorsMonitor.accent)
                        .withOpacity(0.15),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isUnlocked) ...[
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: (isDark
                          ? AppColorsPS5.accent
                          : AppColorsMonitor.accent)
                      .withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(badge.icon,
                    color: isDark
                        ? AppColorsPS5.accent
                        : AppColorsMonitor.accent,
                    size: 28),
              ),
              const SizedBox(height: Spacing.sm),
              Text(
                badge.name,
                style: AppTypography.labelSmall.copyWith(
                  color: isDark
                      ? AppColorsPS5.textPrimary
                      : AppColorsMonitor.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                _rarityName(badge.rarity),
                style: AppTypography.caption.copyWith(
                  color: _rarityColorValue(badge.rarity, isDark),
                  fontSize: 9,
                ),
              ),
            ] else ...[
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: (isDark
                          ? AppColorsPS5.border
                          : AppColorsMonitor.border)
                      .withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.help_outline_rounded,
                  color: isDark
                      ? AppColorsPS5.textHint
                      : AppColorsMonitor.textHint,
                  size: 28,
                ),
              ),
              const SizedBox(height: Spacing.sm),
              Text(
                '???',
                style: AppTypography.labelSmall.copyWith(
                  color: isDark
                      ? AppColorsPS5.textHint
                      : AppColorsMonitor.textHint,
                ),
              ),
              const SizedBox(height: 2),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  badge.condition,
                  style: AppTypography.caption.copyWith(
                    color: isDark
                        ? AppColorsPS5.textHint
                        : AppColorsMonitor.textHint,
                    fontSize: 9,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ],
        ),
      ),
    )
        .animate()
        .scale(
          delay: (80 * index).ms,
          duration: 400.ms,
          curve: Curves.easeOutBack,
          begin: const Offset(0.7, 0.7),
        )
        .fade(delay: (60 * index).ms, duration: 300.ms);
  }

  String _rarityName(_BadgeRarity rarity) {
    switch (rarity) {
      case _BadgeRarity.common: return 'Звичайний';
      case _BadgeRarity.rare: return 'Рідкісний';
      case _BadgeRarity.epic: return 'Епічний';
      case _BadgeRarity.legendary: return 'Легендарний';
    }
  }

  Color _rarityColorValue(_BadgeRarity rarity, bool isDark) {
    switch (rarity) {
      case _BadgeRarity.common: return isDark ? AppColorsPS5.success : AppColorsMonitor.success;
      case _BadgeRarity.rare: return isDark ? AppColorsPS5.accent : AppColorsMonitor.accent;
      case _BadgeRarity.epic: return AppColorsPS5.warning;
      case _BadgeRarity.legendary: return AppColorsPS5.error;
    }
  }
}
