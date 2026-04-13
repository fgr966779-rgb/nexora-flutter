import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_radii.dart';
import '../../../../core/constants/app_shadows.dart';
import '../../../../core/constants/app_durations.dart';
import '../../../../core/constants/app_easings.dart';
import '../../../../core/constants/app_enums.dart';
import '../../../../core/extensions/number_format_ext.dart';
import '../../../../core/utils/haptic_service.dart';
import '../../../../core/widgets/app_button_primary.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/widgets/app_progress_bar.dart';
import '../../../../data/models/challenge_model.dart';
import '../../providers/challenge_provider.dart';
import '../../providers/gamification_provider.dart';

// ═══════════════════════════════════════════════════════════════════════════
// Режим відображення викликів (Display Mode Enum)
// ═══════════════════════════════════════════════════════════════════════════

/// Режим відображення списку викликів.
enum ChallengeDisplayMode {
  /// Горизонтальний скрол (compact картки).
  horizontal,

  /// Вертикальний список.
  list,

  /// Сітка (grid) карток.
  grid,
}

/// Фільтр за складністю викликів.
enum DifficultyFilter {
  /// Усі рівні складності.
  all,

  /// Тільки легкі.
  easy,

  /// Тільки середні.
  medium,

  /// Тільки складні.
  hard,
}

// ═══════════════════════════════════════════════════════════════════════════

/// Екран списку викликів (челенджів).
class ChallengesScreen extends StatefulWidget {
  const ChallengesScreen({super.key});

  static const String route = '/challenges';

  @override
  State<ChallengesScreen> createState() => _ChallengesScreenState();
}

class _ChallengesScreenState extends State<ChallengesScreen> {
  Timer? _countdownTimer;

  /// Поточний режим відображення.
  ChallengeDisplayMode _displayMode = ChallengeDisplayMode.horizontal;

  /// Поточний фільтр складності.
  DifficultyFilter _difficultyFilter = DifficultyFilter.all;

  /// Показувати історію завершених викликів.
  bool _showHistory = false;

  @override
  void initState() {
    super.initState();
    // Refresh every second for countdown
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  /// Повертає відфільтрований список доступних викликів.
  List<Challenge> _filterByDifficulty(List<Challenge> challenges) {
    if (_difficultyFilter == DifficultyFilter.all) return challenges;
    return challenges.where((ch) {
      switch (_difficultyFilter) {
        case DifficultyFilter.easy:
          return ch.difficulty == ChallengeDifficulty.easy;
        case DifficultyFilter.medium:
          return ch.difficulty == ChallengeDifficulty.medium;
        case DifficultyFilter.hard:
          return ch.difficulty == ChallengeDifficulty.hard;
        case DifficultyFilter.all:
          return true;
      }
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final c = isDark ? AppColorsPS5 : AppColorsMonitor;

    return Scaffold(
      backgroundColor: c.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.bolt_rounded, color: c.xp, size: 24),
            const SizedBox(width: Spacing.sm),
            Text(
              'Виклики',
              style: AppTypography.heading1.copyWith(color: c.textPrimary),
            ),
          ],
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: c.textSecondary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          // Перемикач режиму відображення
          IconButton(
            icon: Icon(
              _displayMode == ChallengeDisplayMode.horizontal
                  ? Icons.view_list_rounded
                  : _displayMode == ChallengeDisplayMode.list
                      ? Icons.grid_view_rounded
                      : Icons.view_agenda_rounded,
              color: c.textSecondary,
              size: 20,
            ),
            onPressed: () {
              HapticService.selection();
              setState(() {
                switch (_displayMode) {
                  case ChallengeDisplayMode.horizontal:
                    _displayMode = ChallengeDisplayMode.list;
                  case ChallengeDisplayMode.list:
                    _displayMode = ChallengeDisplayMode.grid;
                  case ChallengeDisplayMode.grid:
                    _displayMode = ChallengeDisplayMode.horizontal;
                }
              });
            },
            tooltip: 'Змінити вигляд',
          ),
        ],
      ),
      body: Consumer<ChallengeProvider>(
        builder: (context, provider, _) {
          final activeChallenge = provider.activeChallenge;
          var available = _filterByDifficulty(provider.availableChallenges);
          final completed = provider.completedChallenges;

          return RefreshIndicator(
            onRefresh: () => provider.refreshChallenges(),
            color: c.accent,
            child: CustomScrollView(
              slivers: [
                // Subtitle
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      Spacing.base, Spacing.sm, Spacing.base, Spacing.base,
                    ),
                    child: Text(
                      'Виконай завдання — отримай бонус!',
                      style: AppTypography.bodyMedium
                          .copyWith(color: c.textSecondary),
                    ),
                  ),
                ),

                // Active challenge
                if (activeChallenge != null)
                  SliverToBoxAdapter(
                    child: _buildActiveCard(activeChallenge, c, isDark),
                  ),

                // Filter chips by difficulty
                if (provider.availableChallenges.isNotEmpty) ...[
                  SliverToBoxAdapter(
                    child: _buildDifficultyFilter(c),
                  ),
                ],

                // Available challenges header
                if (available.isNotEmpty) ...[
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(
                        Spacing.base, Spacing.xl, Spacing.base, Spacing.sm,
                      ),
                      child: Row(
                        children: [
                          Text(
                            'Доступні виклики',
                            style: AppTypography.heading3
                                .copyWith(color: c.textPrimary),
                          ),
                          const SizedBox(width: Spacing.sm),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: Spacing.sm,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: c.accent.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(Radii.sm),
                            ),
                            child: Text(
                              '${available.length}',
                              style: AppTypography.caption.copyWith(
                                color: c.accent,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: _buildAvailableList(available, c, isDark),
                  ),
                ],

                // No results after filter
                if (available.isEmpty &&
                    provider.availableChallenges.isNotEmpty) ...[
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(Spacing.xxl),
                      child: Text(
                        'Немає викликів вибраної складності',
                        style: AppTypography.bodyMedium
                            .copyWith(color: c.textHint),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],

                // Completed challenges section
                if (completed.isNotEmpty) ...[
                  SliverToBoxAdapter(
                    child: _buildHistoryToggle(c, completed.length),
                  ),
                  if (_showHistory)
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => _CompletedChallengeTile(
                          challenge: completed[index],
                          isLightTheme: !isDark,
                        ),
                        childCount: completed.length,
                      ),
                    ),
                ],

                // Empty state
                if (activeChallenge == null &&
                    provider.availableChallenges.isEmpty &&
                    completed.isEmpty)
                  SliverFillRemaining(
                    child: AppEmptyState(
                      icon: Icons.bolt_rounded,
                      title: 'Викликів поки немає',
                      subtitle: 'Нові виклики з\'являться згодом. '
                          'Спробуй повернутися пізніше!',
                      isLightTheme: !isDark,
                    ),
                  ),

                const SliverToBoxAdapter(child: SizedBox(height: Spacing.xxxl)),
              ],
            ),
          );
        },
      ),
    );
  }

  /// Будує перемикач фільтра складності.
  Widget _buildDifficultyFilter(dynamic c) {
    final filters = DifficultyFilter.values;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Spacing.base),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: filters.map((filter) {
            final isActive = _difficultyFilter == filter;
            final label = switch (filter) {
              DifficultyFilter.all => 'Усі',
              DifficultyFilter.easy => '🟢 Легкі',
              DifficultyFilter.medium => '🟡 Середні',
              DifficultyFilter.hard => '🔴 Складні',
            };
            return Padding(
              padding: const EdgeInsets.only(right: Spacing.sm),
              child: GestureDetector(
                onTap: () {
                  HapticService.selection();
                  setState(() => _difficultyFilter = filter);
                },
                child: AnimatedContainer(
                  duration: AppDurations.fast,
                  padding: const EdgeInsets.symmetric(
                    horizontal: Spacing.md,
                    vertical: Spacing.xs + 2,
                  ),
                  decoration: BoxDecoration(
                    color: isActive
                        ? c.accent.withOpacity(0.15)
                        : c.border.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(Radii.sm),
                    border: Border.all(
                      color: isActive
                          ? c.accent.withOpacity(0.3)
                          : Colors.transparent,
                      width: 1,
                    ),
                  ),
                  child: Text(
                    label,
                    style: AppTypography.labelSmall.copyWith(
                      color: isActive ? c.accent : c.textSecondary,
                      fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  /// Будує перемикач показу історії.
  Widget _buildHistoryToggle(dynamic c, int completedCount) {
    return GestureDetector(
      onTap: () {
        HapticService.selection();
        setState(() => _showHistory = !_showHistory);
      },
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          Spacing.base, Spacing.xl, Spacing.base, Spacing.sm,
        ),
        child: Row(
          children: [
            Text(
              'Завершені ($completedCount)',
              style: AppTypography.heading3
                  .copyWith(color: c.textSecondary),
            ),
            const SizedBox(width: Spacing.sm),
            Icon(
              _showHistory
                  ? Icons.expand_less_rounded
                  : Icons.expand_more_rounded,
              color: c.textHint,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveCard(Challenge ch, dynamic c, bool isDark) {
    final provider = context.read<ChallengeProvider>();
    final remaining = ch.daysRemaining;
    final hours = remaining * 24;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Spacing.base),
      child: AppCard(
        isLightTheme: !isDark,
        padding: const EdgeInsets.all(Spacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title with difficulty badge
            Row(
              children: [
                Icon(Icons.bolt_rounded, color: c.xp, size: 20),
                const SizedBox(width: Spacing.sm),
                Expanded(
                  child: Text(
                    ch.title,
                    style: AppTypography.heading2.copyWith(color: c.textPrimary),
                  ),
                ),
                const SizedBox(width: Spacing.sm),
                _buildDifficultyBadge(ch.difficulty, c),
              ],
            ),
            const SizedBox(height: Spacing.sm),
            Text(
              ch.description,
              style: AppTypography.bodyMedium.copyWith(color: c.textSecondary),
            ),
            const SizedBox(height: Spacing.base),
            // Countdown
            _buildTimerDisplay(ch, c),
            const SizedBox(height: Spacing.sm),
            // Progress
            Text(
              'День ${ch.currentDay} з ${ch.durationDays}',
              style: AppTypography.labelMedium.copyWith(color: c.textSecondary),
            ),
            const SizedBox(height: Spacing.sm),
            AppProgressBar(
              progress: ch.progress,
              isPulsing: true,
              isLightTheme: !isDark,
              height: ProgressBarHeight.normal,
              showLabel: true,
            ),
            const SizedBox(height: Spacing.base),
            // Reward
            Row(
              children: [
                Icon(Icons.star_rounded, color: c.xp, size: 16),
                const SizedBox(width: 4),
                Text(
                  '+${ch.xpReward} XP',
                  style: AppTypography.labelMedium.copyWith(color: c.xp),
                ),
                const SizedBox(width: Spacing.sm),
                Icon(Icons.monetization_on_rounded, color: c.coin, size: 16),
                const SizedBox(width: 4),
                Text(
                  '+${ch.coinsEarned} монет',
                  style: AppTypography.labelMedium.copyWith(color: c.coin),
                ),
              ],
            ),
            const SizedBox(height: Spacing.base),
            SizedBox(
              width: double.infinity,
              child: AppButtonPrimary(
                label: 'Звіт за сьогодні',
                icon: Icons.check_circle_outline_rounded,
                onPressed: () {
                  HapticService.mediumTap();
                  provider.reportToday();
                },
                isLightTheme: !isDark,
              ),
            ),
          ],
        ),
      )
          .animate()
          .fadeIn(duration: 400.ms)
          .slideY(begin: 0.1, end: 0, duration: 400.ms),
    );
  }

  /// Будує віджет таймера з відліком.
  Widget _buildTimerDisplay(Challenge ch, dynamic c) {
    final remaining = ch.daysRemaining;
    String timeText;
    IconData timerIcon;

    if (remaining >= 1) {
      timeText = '$remaining дн залишилось';
      timerIcon = Icons.event_rounded;
    } else if (ch.startedAt != null) {
      final hoursLeft =
          24 - DateTime.now().difference(ch.startedAt!).inHours % 24;
      timeText = '$hoursLeft год залишилось';
      timerIcon = Icons.timer_rounded;
    } else {
      timeText = 'Очікування старту';
      timerIcon = Icons.schedule_rounded;
    }

    return Row(
      children: [
        Icon(timerIcon, color: c.accent, size: 18),
        const SizedBox(width: Spacing.xs),
        Text(
          timeText,
          style: AppTypography.monoSmall.copyWith(color: c.accent),
        ),
      ],
    );
  }

  /// Будує бейдж складності виклику.
  Widget _buildDifficultyBadge(ChallengeDifficulty difficulty, dynamic c) {
    final color = switch (difficulty) {
      ChallengeDifficulty.easy => c.success,
      ChallengeDifficulty.medium => c.warning,
      ChallengeDifficulty.hard => c.error,
    };
    final label = switch (difficulty) {
      ChallengeDifficulty.easy => 'Легко',
      ChallengeDifficulty.medium => 'Середньо',
      ChallengeDifficulty.hard => 'Складно',
    };

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.sm,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(Radii.sm),
      ),
      child: Text(
        label,
        style: AppTypography.caption.copyWith(
          color: color,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  String _formatCountdown(Challenge ch) {
    final remaining = ch.daysRemaining;
    if (remaining >= 1) return '$remaining дн';
    if (ch.startedAt != null) {
      final hoursLeft = 24 - DateTime.now().difference(ch.startedAt!).inHours % 24;
      return '$hoursLeft год';
    }
    return '—';
  }

  Widget _buildAvailableList(List<Challenge> list, dynamic c, bool isDark) {
    switch (_displayMode) {
      case ChallengeDisplayMode.horizontal:
        return SizedBox(
          height: 160,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: Spacing.base),
            itemCount: list.length,
            separatorBuilder: (_, __) => const SizedBox(width: Spacing.sm),
            itemBuilder: (context, index) {
              final ch = list[index];
              return _AvailableChallengeCard(
                challenge: ch,
                isLightTheme: !isDark,
                onTap: () {
                  HapticService.lightTap();
                  context.read<ChallengeProvider>().startChallenge(ch.id);
                },
              );
            },
          ),
        );
      case ChallengeDisplayMode.list:
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: Spacing.base),
          child: Column(
            children: list.map((ch) {
              return Padding(
                padding: const EdgeInsets.only(bottom: Spacing.sm),
                child: _AvailableChallengeCard(
                  challenge: ch,
                  isLightTheme: !isDark,
                  onTap: () {
                    HapticService.lightTap();
                    context.read<ChallengeProvider>().startChallenge(ch.id);
                  },
                  isFullWidth: true,
                ),
              );
            }).toList(),
          ),
        );
      case ChallengeDisplayMode.grid:
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: Spacing.base),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: Spacing.sm,
              crossAxisSpacing: Spacing.sm,
              childAspectRatio: 1.4,
            ),
            itemCount: list.length,
            itemBuilder: (context, index) {
              final ch = list[index];
              return _AvailableChallengeCard(
                challenge: ch,
                isLightTheme: !isDark,
                onTap: () {
                  HapticService.lightTap();
                  context.read<ChallengeProvider>().startChallenge(ch.id);
                },
                isGridItem: true,
              );
            },
          ),
        );
    }
  }
}

/// Горизонтальна картка доступного виклику.
class _AvailableChallengeCard extends StatelessWidget {
  const _AvailableChallengeCard({
    required this.challenge,
    required this.isLightTheme,
    required this.onTap,
    this.isFullWidth = false,
    this.isGridItem = false,
  });

  final Challenge challenge;
  final bool isLightTheme;
  final VoidCallback onTap;
  final bool isFullWidth;
  final bool isGridItem;

  Color _difficultyColor(dynamic c) {
    switch (challenge.difficulty) {
      case ChallengeDifficulty.easy:
        return c.success;
      case ChallengeDifficulty.medium:
        return c.warning;
      case ChallengeDifficulty.hard:
        return c.error;
    }
  }

  String _difficultyLabel() {
    switch (challenge.difficulty) {
      case ChallengeDifficulty.easy:
        return 'Легко';
      case ChallengeDifficulty.medium:
        return 'Середньо';
      case ChallengeDifficulty.hard:
        return 'Складно';
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = isLightTheme ? AppColorsMonitor : AppColorsPS5;

    return GestureDetector(
      onTap: onTap,
      child: AppCard(
        isLightTheme: isLightTheme,
        width: isFullWidth || isGridItem ? null : 180,
        padding: const EdgeInsets.all(Spacing.base),
        child: isGridItem
            ? _buildGridContent(c)
            : _buildListContent(c),
      ),
    ).animate().fadeIn(delay: (100).ms, duration: 300.ms);
  }

  /// Контент для горизонтального компактного відображення.
  Widget _buildListContent(dynamic c) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: Spacing.sm,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: _difficultyColor(c).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(Radii.sm),
                  ),
                  child: Text(
                    _difficultyLabel(),
                    style: AppTypography.labelSmall.copyWith(
                      color: _difficultyColor(c),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: Spacing.sm),
            Text(
              challenge.title,
              style: AppTypography.heading3.copyWith(color: c.textPrimary),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        Row(
          children: [
            Icon(Icons.star_rounded, color: c.xp, size: 14),
            const SizedBox(width: 2),
            Text(
              '+${challenge.xpReward}',
              style: AppTypography.labelSmall.copyWith(color: c.xp),
            ),
            const SizedBox(width: Spacing.xs),
            Icon(Icons.monetization_on_rounded, color: c.coin, size: 14),
            const SizedBox(width: 2),
            Text(
              '+${challenge.coinsReward}',
              style: AppTypography.labelSmall.copyWith(color: c.coin),
            ),
          ],
        ),
      ],
    );
  }

  /// Контент для відображення у сітці.
  Widget _buildGridContent(dynamic c) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: Spacing.sm,
                vertical: 2,
              ),
              decoration: BoxDecoration(
                color: _difficultyColor(c).withOpacity(0.15),
                borderRadius: BorderRadius.circular(Radii.sm),
              ),
              child: Text(
                _difficultyLabel(),
                style: AppTypography.labelSmall.copyWith(
                  color: _difficultyColor(c),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const Spacer(),
            Text(
              '${challenge.durationDays} дн',
              style: AppTypography.caption.copyWith(color: c.textHint),
            ),
          ],
        ),
        const SizedBox(height: Spacing.sm),
        Text(
          challenge.title,
          style: AppTypography.heading3.copyWith(color: c.textPrimary),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const Spacer(),
        Row(
          children: [
            Icon(Icons.star_rounded, color: c.xp, size: 14),
            const SizedBox(width: 2),
            Text(
              '+${challenge.xpReward}',
              style: AppTypography.labelSmall.copyWith(color: c.xp),
            ),
            const SizedBox(width: Spacing.xs),
            Icon(Icons.monetization_on_rounded, color: c.coin, size: 14),
            const SizedBox(width: 2),
            Text(
              '+${challenge.coinsReward}',
              style: AppTypography.labelSmall.copyWith(color: c.coin),
            ),
          ],
        ),
      ],
    );
  }
}

/// Розкривний рядок завершеного виклику.
class _CompletedChallengeTile extends StatefulWidget {
  const _CompletedChallengeTile({
    required this.challenge,
    required this.isLightTheme,
  });

  final Challenge challenge;
  final bool isLightTheme;

  @override
  State<_CompletedChallengeTile> createState() => _CompletedChallengeTileState();
}

class _CompletedChallengeTileState extends State<_CompletedChallengeTile> {
  bool _expanded = false;

  /// Лічильник розгортувань для аналітики.
  int _expandCount = 0;

  /// Час останнього розгортування.
  DateTime? _lastExpandedAt;

  /// Анімована висота для розгорнутого контенту.
  double _animatedHeight = 0.0;

  /// Валідує виклик на наявність винагород.
  bool get _hasRewards {
    return widget.challenge.xpReward > 0 || widget.challenge.coinsReward > 0;
  }

  /// Обчислює загальну винагороду у балах (XP + монети).
  int get _totalRewardPoints {
    return widget.challenge.xpReward + widget.challenge.coinsReward;
  }

  /// Перевіряє, чи виклик мав високу складність.
  bool get _isHardChallenge {
    return widget.challenge.difficulty == ChallengeDifficulty.hard;
  }

  /// Обчислює відсоток прогресу (завжди 100 для завершених).
  double get _progressPercentage {
    return widget.challenge.progress * 100;
  }

  /// Обчислює оцінку складності виклику (1-3).
  int get _difficultyScore {
    switch (widget.challenge.difficulty) {
      case ChallengeDifficulty.easy:
        return 1;
      case ChallengeDifficulty.medium:
        return 2;
      case ChallengeDifficulty.hard:
        return 3;
    }
  }

  /// Обчислює щільність винагороди (XP за день тривалості).
  double get _xpDensity {
    final days = widget.challenge.durationDays;
    if (days <= 0) return 0.0;
    return widget.challenge.xpReward / days;
  }

  /// Обчислює дні з моменту завершення.
  int _daysSinceCompletion() {
    try {
      if (widget.challenge.completedAt == null) return 0;
      return DateTime.now()
          .difference(widget.challenge.completedAt!)
          .inDays;
    } catch (e) {
      return 0;
    }
  }

  /// Форматує XP density як зручний рядок.
  String get _formattedXpDensity {
    if (_xpDensity == 0) return '—';
    return '${_xpDensity.toStringAsFixed(1)} XP/день';
  }

  /// Форматує час завершення виклику.
  String _formatCompletionTime() {
    final days = _daysSinceCompletion();
    if (days == 0) return 'Завершено сьогодні';
    if (days == 1) return 'Завершено вчора';
    if (days < 7) return 'Завершено $days дн тому';
    if (days < 30) return 'Завершено ${(days / 7).floor()} тиж тому';
    return 'Завершено ${(days / 30).floor()} міс тому';
  }

  /// Валідує опис виклику на предмет порожнечі.
  bool get _hasDescription {
    return widget.challenge.description.isNotEmpty;
  }

  void _handleToggle() {
    HapticService.selection();
    _expandCount++;
    _lastExpandedAt = DateTime.now();
    setState(() => _expanded = !_expanded);
    debugPrint('[CompletedTile] Toggle #$_expandCount at $_lastExpandedAt');
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.isLightTheme ? AppColorsMonitor : AppColorsPS5;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.base,
        vertical: Spacing.xs,
      ),
      child: AppCard(
        isLightTheme: widget.isLightTheme,
        onTap: _handleToggle,
        padding: const EdgeInsets.all(Spacing.base),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.emoji_events_rounded, color: c.xp, size: 20),
                const SizedBox(width: Spacing.sm),
                Expanded(
                  child: Text(
                    widget.challenge.title,
                    style: AppTypography.bodyLarge.copyWith(
                      color: c.textPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                // Difficulty badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: Spacing.sm,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: switch (widget.challenge.difficulty) {
                      ChallengeDifficulty.easy => c.success.withOpacity(0.12),
                      ChallengeDifficulty.medium => c.warning.withOpacity(0.12),
                      ChallengeDifficulty.hard => c.error.withOpacity(0.12),
                    },
                    borderRadius: BorderRadius.circular(Radii.sm),
                  ),
                  child: Text(
                    switch (widget.challenge.difficulty) {
                      ChallengeDifficulty.easy => 'Легко',
                      ChallengeDifficulty.medium => 'Середньо',
                      ChallengeDifficulty.hard => 'Складно',
                    },
                    style: AppTypography.caption.copyWith(
                      color: switch (widget.challenge.difficulty) {
                        ChallengeDifficulty.easy => c.success,
                        ChallengeDifficulty.medium => c.warning,
                        ChallengeDifficulty.hard => c.error,
                      },
                    ),
                  ),
                ),
                const SizedBox(width: Spacing.sm),
                Icon(
                  _expanded
                      ? Icons.expand_less_rounded
                      : Icons.expand_more_rounded,
                  color: c.textHint,
                  size: 20,
                ),
              ],
            ),
            // Швидкий підсумок винагороди
            if (_hasRewards && !_expanded)
              Padding(
                padding: const EdgeInsets.only(top: Spacing.xs),
                child: _buildCompactRewards(c),
              ),
            // Час завершення
            if (!_expanded)
              Padding(
                padding: const EdgeInsets.only(top: Spacing.xs),
                child: Text(
                  _formatCompletionTime(),
                  style: AppTypography.caption.copyWith(color: c.textHint),
                ),
              ),
            AnimatedSize(
              duration: AppDurations.medium,
              child: _expanded
                  ? Padding(
                      padding: const EdgeInsets.only(top: Spacing.sm),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.challenge.description,
                            style: AppTypography.bodyMedium
                                .copyWith(color: c.textSecondary),
                          ),
                          const SizedBox(height: Spacing.sm),
                          // Прогрес-бар завершеного виклику
                          AppProgressBar(
                            progress: 1.0,
                            isLightTheme: widget.isLightTheme,
                            height: ProgressBarHeight.thin,
                            showLabel: false,
                          ),
                          const SizedBox(height: Spacing.sm),
                          Row(
                            children: [
                              Icon(Icons.star_rounded,
                                  color: c.xp, size: 14),
                              const SizedBox(width: 2),
                              Text(
                                '+${widget.challenge.xpReward} XP',
                                style: AppTypography.labelSmall
                                    .copyWith(color: c.xp),
                              ),
                              const SizedBox(width: Spacing.sm),
                              Icon(Icons.monetization_on_rounded,
                                  color: c.coin, size: 14),
                              const SizedBox(width: 2),
                              Text(
                                '+${widget.challenge.coinsReward} монет',
                                style: AppTypography.labelSmall
                                    .copyWith(color: c.coin),
                              ),
                              const Spacer(),
                              Text(
                                '${widget.challenge.durationDays} дн',
                                style: AppTypography.caption
                                    .copyWith(color: c.textHint),
                              ),
                            ],
                          ),
                          // Розширена інформація про виклик
                          const SizedBox(height: Spacing.sm),
                          _buildExpandedDetails(c),
                        ],
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 200.ms);
  }

  /// Будує компактний рядок винагороди для згорнутого стану.
  Widget _buildCompactRewards(dynamic c) {
    return Row(
      children: [
        if (widget.challenge.xpReward > 0) ...[
          Icon(Icons.star_rounded, color: c.xp, size: 12),
          const SizedBox(width: 2),
          Text(
            '+${widget.challenge.xpReward}',
            style: AppTypography.caption.copyWith(
              color: c.xp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
        if (widget.challenge.coinsReward > 0) ...[
          const SizedBox(width: Spacing.sm),
          Icon(Icons.monetization_on_rounded, color: c.coin, size: 12),
          const SizedBox(width: 2),
          Text(
            '+${widget.challenge.coinsReward}',
            style: AppTypography.caption.copyWith(
              color: c.coin,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
        const Spacer(),
        Text(
          '${widget.challenge.durationDays} дн',
          style: AppTypography.caption.copyWith(color: c.textHint),
        ),
      ],
    );
  }

  /// Будує розширені деталі завершеного виклику.
  Widget _buildExpandedDetails(dynamic c) {
    return Container(
      padding: const EdgeInsets.all(Spacing.sm),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(Radii.sm),
        border: Border.all(color: c.border, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Деталізація винагороди
          Text(
            'Деталізація виклику',
            style: AppTypography.labelSmall.copyWith(
              color: c.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: Spacing.xs),
          _buildDetailRow(c, 'XP за день', _formattedXpDensity, Icons.speed_rounded),
          _buildDetailRow(c, 'Тривалість', '${widget.challenge.durationDays} дн', Icons.schedule_rounded),
          _buildDetailRow(c, 'Складність', '${_difficultyScore}/3', Icons.signal_cellular_alt_rounded),
          _buildDetailRow(c, 'Всього балів', '$_totalRewardPoints', Icons.military_tech_rounded),
          // Час завершення
          const SizedBox(height: Spacing.xs),
          Text(
            _formatCompletionTime(),
            style: AppTypography.caption.copyWith(
              color: c.textHint,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  /// Будує рядок деталі для розгорнутого стану.
  Widget _buildDetailRow(dynamic c, String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(icon, color: c.textHint, size: 14),
          const SizedBox(width: Spacing.sm),
          Text(
            label,
            style: AppTypography.labelSmall.copyWith(color: c.textSecondary),
          ),
          const Spacer(),
          Text(
            value,
            style: AppTypography.labelSmall.copyWith(
              color: c.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Додаткові константи екрану викликів
// ═══════════════════════════════════════════════════════════════════════════

/// Мінімальна тривалість виклику в днях для «довгого».
const int _kLongChallengeDays = 14;

/// Мінімальна XP для «високої» винагороди.
const int _kHighRewardXP = 100;

/// Мінімальна кількість монет для «високої» винагороди.
const int _kHighRewardCoins = 50;

/// Максимальна довжина назви виклику для відображення.
const int _kMaxChallengeTitleLength = 30;

/// Кількість «спеціальних» викликів для badge.
const int _kSpecialBadgeThreshold = 3;

// ═══════════════════════════════════════════════════════════════════════════
// Допоміжні функції для екрану викликів (можуть бути використані глобально)
// ═══════════════════════════════════════════════════════════════════════════

/// Перевіряє, чи виклик є «довгим» (>= [_kLongChallengeDays] днів).
///
/// Повертає `true`, якщо тривалість виклику перевищує поріг.
bool _isLongChallenge(Challenge ch) {
  return ch.durationDays >= _kLongChallengeDays;
}

/// Перевіряє, чи виклик має високу винагороду.
///
/// Повертає `true`, якщо XP >= [_kHighRewardXP] або монети >= [_kHighRewardCoins].
bool _isHighRewardChallenge(Challenge ch) {
  return ch.xpReward >= _kHighRewardXP || ch.coinsReward >= _kHighRewardCoins;
}

/// Перевіряє, чи виклик має високу винагороду за день.
///
/// Обчислює XP-щільність і порівнює з порогом 10 XP/день.
bool _isEfficientChallenge(Challenge ch) {
  if (ch.durationDays <= 0) return false;
  return ch.xpReward / ch.durationDays >= 10;
}

/// Обчислює XP-щільність виклику (XP за день).
///
/// Повертає 0.0, якщо тривалість <= 0.
double _computeChallengeXpDensity(Challenge ch) {
  if (ch.durationDays <= 0) return 0.0;
  return ch.xpReward / ch.durationDays;
}

/// Обчислює загальну винагороду виклику (XP + монети).
///
/// Використовується для сортування за «цінністю» виклику.
int _computeTotalReward(Challenge ch) {
  return ch.xpReward + ch.coinsReward;
}

/// Обчислює індекс цінності виклику (XP * coins / days).
///
/// Вищий індекс — більш вигідний виклик.
double _computeValueIndex(Challenge ch) {
  if (ch.durationDays <= 0) return 0.0;
  return (ch.xpReward * ch.coinsReward) / ch.durationDays;
}

/// Форматує тривалість виклику з одиницею виміру.
///
/// Наприклад: «7 дн», «14 дн», «30 дн».
String _formatDuration(int days) {
  if (days <= 0) return '—';
  if (days == 1) return '1 день';
  if (days < 5) return '$days дні';
  return '$days дн';
}

/// Форматує XP-щільність для відображення.
///
/// Наприклад: «12.5 XP/день».
String _formatXpDensity(double density) {
  if (density <= 0) return '—';
  return '${density.toStringAsFixed(1)} XP/день';
}

/// Обрізає назву виклику, якщо вона занадто довга.
///
/// Додає «…» в кінці, якщо назва перевищує [_kMaxChallengeTitleLength].
String _truncateChallengeTitle(String title) {
  if (title.length <= _kMaxChallengeTitleLength) return title;
  return '${title.substring(0, _kMaxChallengeTitleLength - 2)}…';
}

/// Повертає іконку для складності виклику.
///
/// Вибирає відповідну іконку: легка — eco, середня — bolt, складна — fire.
IconData _difficultyIcon(ChallengeDifficulty difficulty) {
  switch (difficulty) {
    case ChallengeDifficulty.easy:
      return Icons.eco_rounded;
    case ChallengeDifficulty.medium:
      return Icons.bolt_rounded;
    case ChallengeDifficulty.hard:
      return Icons.local_fire_department_rounded;
  }
}

/// Повертає описовий рядок для складності виклику.
///
/// Наприклад: «Легкий (1/3)», «Середній (2/3)», «Складний (3/3)».
String _difficultyDescription(ChallengeDifficulty difficulty) {
  switch (difficulty) {
    case ChallengeDifficulty.easy:
      return 'Легкий (1/3)';
    case ChallengeDifficulty.medium:
      return 'Середній (2/3)';
    case ChallengeDifficulty.hard:
      return 'Складний (3/3)';
  }
}

/// Сортує виклики за XP-щільністю (спадання).
///
/// Виклики з вищою XP за день йдуть першими.
List<Challenge> _sortByXpDensity(List<Challenge> challenges) {
  final sorted = List<Challenge>.from(challenges);
  sorted.sort((a, b) => _computeChallengeXpDensity(b).compareTo(_computeChallengeXpDensity(a)));
  return sorted;
}

/// Сортує виклики за загальною винагородою (спадання).
///
/// Виклики з більшою сумою XP + монет йдуть першими.
List<Challenge> _sortByTotalReward(List<Challenge> challenges) {
  final sorted = List<Challenge>.from(challenges);
  sorted.sort((a, b) => _computeTotalReward(b).compareTo(_computeTotalReward(a)));
  return sorted;
}

/// Сортує виклики за тривалістю (зростання).
///
/// Коротші виклики йдуть першими.
List<Challenge> _sortByDuration(List<Challenge> challenges) {
  final sorted = List<Challenge>.from(challenges);
  sorted.sort((a, b) => a.durationDays.compareTo(b.durationDays));
  return sorted;
}

/// Фільтрує виклики, залишаючи лише «довгі» (>= [_kLongChallengeDays] днів).
List<Challenge> _filterLongChallenges(List<Challenge> challenges) {
  return challenges.where(_isLongChallenge).toList();
}

/// Фільтрує виклики, залишаючи лише з високою винагородою.
List<Challenge> _filterHighRewardChallenges(List<Challenge> challenges) {
  return challenges.where(_isHighRewardChallenge).toList();
}

/// Фільтрує виклики, залишаючи лише «ефективні» (висока XP-щільність).
List<Challenge> _filterEfficientChallenges(List<Challenge> challenges) {
  return challenges.where(_isEfficientChallenge).toList();
}

/// Обчислює середню XP-щільність для списку викликів.
///
/// Повертає 0.0, якщо список порожній.
double _averageXpDensity(List<Challenge> challenges) {
  if (challenges.isEmpty) return 0.0;
  final totalDensity = challenges.fold<double>(
    0,
    (sum, ch) => sum + _computeChallengeXpDensity(ch),
  );
  return totalDensity / challenges.length;
}

/// Обчислює максимальну винагороду серед викликів.
///
/// Повертає 0, якщо список порожній.
int _maxReward(List<Challenge> challenges) {
  if (challenges.isEmpty) return 0;
  return challenges.fold<int>(
    0,
    (max, ch) {
      final total = _computeTotalReward(ch);
      return total > max ? total : max;
    },
  );
}
