import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_radii.dart';
import '../../../../core/widgets/app_button_primary.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/extensions/build_context_ext.dart';

// ═══════════════════════════════════════════════════════════════════════════
// Константи екрану «Мої перемоги»
// ═══════════════════════════════════════════════════════════════════════════

/// Максимальна кількість кешованих цілей.
const int _kMaxCachedGoals = 100;

/// Затримка завантаження (мілісекунди).
const int _kLoadingDelayMs = 600;

/// Затримка pull-to-refresh (мілісекунди).
const int _kRefreshDelayMs = 800;

/// Кількість елементів у статисти.
const int _kStatsCount = 3;

/// Мінімальна XP для високого бейджа.
const int _kHighXpThreshold = 200;

/// Мінімальна кількість монет для преміум бейджа.
const int _kPremiumCoinThreshold = 50;

/// Максимальна кількість фільтрів для відображення.
const int _kMaxVisibleFilters = 6;

/// Тривалість анімації появи картки цілі (мілісекунди).
const int _kCardAnimDurationMs = 400;

/// Мінімальна кількість символів для пошуку цілей.
const int _kMinSearchLength = 2;

/// Максимальна кількість записів у хронології.
const int _kMaxTimelineEntries = 50;

/// Кількість цілей для показу на першій сторінці.
const int _kInitialGoalsCount = 10;

/// Кількість цілей для додаткового завантаження.
const int _kLoadMoreIncrement = 5;

/// Тривалість анімації появи картки цілі (мілісекунди).
const int _kCardAnimDurationMs = 400;

/// Мінімальна кількість символів для пошуку цілей.
const int _kMinSearchLength = 2;

/// Максимальна кількість записів у хронології.
const int _kMaxTimelineEntries = 50;

/// Кількість цілей для показу на першій сторінці.
const int _kInitialGoalsCount = 10;

/// Кількість цілей для додаткового завантаження.
const int _kLoadMoreIncrement = 5;

// ═══════════════════════════════════════════════════════════════════════════
// Utility Extensions
// ═══════════════════════════════════════════════════════════════════════════

/// Розширення для форматування числових значень.
extension _NumFormatting on num {
  /// Форматує число з одним знаком після коми.
  String formatted() => toStringAsFixed(1);

  /// Форматує число як ціле.
  String formattedInt() => toInt().toString();

  /// Повертає відсоток як відформатований рядок.
  String formattedPercent() => toStringAsFixed(0) + '%';

  /// Форматує суму з знаком гривні.
  String formattedUah() => toStringAsFixed(0) + ' грн';
}

/// Розширення для безпечної роботи зі списками.
extension _ListSafety on List {
  /// Безпечний доступ до елемента за індексом.
  T? safeAt<T>(int index) {
    if (index < 0 || index >= length) return null;
    return this[index] as T?;
  }

  /// Кількість елементів, що задовольняють умову.
  int countWhere(bool Function(dynamic) test) => where(test).length;

  /// Перевіряє, чи список порожній або null.
  bool get isNullOrEmpty => isEmpty;

  /// Перевіряє, чи список не порожній.
  bool get isNotNullOrEmpty => isNotEmpty;
}

/// Розширення для роботи з датами.
extension _DateParsing on String {
  /// Спробує розпарсити рядок як дату.
  DateTime? tryParseDate() => DateTime.tryParse(this);
}

/// Екран «Мої перемоги» — timeline завершених цілей з розгортанням,
/// фільтрами за типом, розширеними деталями, completed challenge milestones,
/// stagger-анімаціями та «Створити нову мету» кнопкою.
/// Модель запису хронології цілей для аналітики.
///
/// Зберігає події завершення цілей з часовими мітками
/// та розраховує статистичні показники.
class _TimelineAnalytics {
  /// Створює об'єкт аналітики хронології.
  const _TimelineAnalytics();

  /// Обчислює середній час досягнення цілей у днях.
  ///
  /// [entries] — список завершених цілей з даними про час.
  double averageCompletionDays(List<_CompletedGoal> entries) {
    if (entries.isEmpty) return 0.0;
    try {
      final total = entries.fold<double>(0, (sum, e) {
        final days = double.tryParse(e.duration.replaceAll(RegExp(r'[^\\d.]'), '')) ?? 0;
        return sum + days;
      });
      return total / entries.length;
    } catch (e) {
      debugPrint('[TimelineAnalytics] Error calculating avg days: $e');
      return 0.0;
    }
  }

  /// Повертає загальну суму зібраних коштів.
  ///
  /// [entries] — список завершених цілей.
  double totalAmountSaved(List<_CompletedGoal> entries) {
    if (entries.isEmpty) return 0.0;
    try {
      return entries.fold<double>(0, (sum, e) {
        final amount = double.tryParse(e.amount.replaceAll(RegExp(r'[^\\d.]'), '')) ?? 0;
        return sum + amount;
      });
    } catch (e) {
      debugPrint('[TimelineAnalytics] Error calculating total: $e');
      return 0.0;
    }
  }

  /// Повертає найбільшу ціль за сумою.
  ///
  /// [entries] — список завершених цілей.
  _CompletedGoal? largestGoal(List<_CompletedGoal> entries) {
    if (entries.isEmpty) return null;
    try {
      return entries.reduce((a, b) {
        final aAmt = double.tryParse(a.amount.replaceAll(RegExp(r'[^\\d.]'), '')) ?? 0;
        final bAmt = double.tryParse(b.amount.replaceAll(RegExp(r'[^\\d.]'), '')) ?? 0;
        return aAmt >= bAmt ? a : b;
      });
    } catch (e) {
      debugPrint('[TimelineAnalytics] Error finding largest goal: $e');
      return entries.first;
    }
  }

  /// Обчислює відсоток цілей з бонусом XP.
  ///
  /// [entries] — список завершених цілей.
  double highXpGoalPercentage(List<_CompletedGoal> entries) {
    if (entries.isEmpty) return 0.0;
    try {
      final highXp = entries.where((e) => e.xpEarned >= _kHighXpThreshold).length;
      return (highXp / entries.length) * 100;
    } catch (e) {
      debugPrint('[TimelineAnalytics] Error calculating high XP %: $e');
      return 0.0;
    }
  }
}

/// Модель запису хронології цілей для аналітики.
///
/// Зберігає події завершення цілей з часовими мітками
/// та розраховує статистичні показники.
class _TimelineAnalytics {
  /// Створює об'єкт аналітики хронології.
  const _TimelineAnalytics();

  /// Обчислює загальну суму зібраних коштів.
  ///
  /// [entries] — список завершених цілей.
  double totalAmountSaved(List<_CompletedGoal> entries) {
    if (entries.isEmpty) return 0.0;
    try {
      return entries.fold<double>(0, (sum, e) {
        final cleaned = e.totalAmount.replaceAll(RegExp(r'[^0-9]'), '');
        final amount = double.tryParse(cleaned) ?? 0;
        return sum + amount;
      });
    } catch (e) {
      debugPrint('[TimelineAnalytics] Error calculating total: $e');
      return 0.0;
    }
  }

  /// Обчислює середній час досягнення цілей у днях.
  ///
  /// [entries] — список завершених цілей з даними про час.
  double averageCompletionDays(List<_CompletedGoal> entries) {
    if (entries.isEmpty) return 0.0;
    try {
      final total = entries.fold<int>(0, (sum, e) => sum + e.daysTaken);
      return total / entries.length;
    } catch (e) {
      debugPrint('[TimelineAnalytics] Error calculating avg days: $e');
      return 0.0;
    }
  }

  /// Повертає найбільшу ціль за сумою.
  ///
  /// [entries] — список завершених цілей.
  _CompletedGoal? largestGoal(List<_CompletedGoal> entries) {
    if (entries.isEmpty) return null;
    try {
      return entries.reduce((a, b) {
        final aAmt = double.tryParse(a.totalAmount.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
        final bAmt = double.tryParse(b.totalAmount.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
        return aAmt >= bAmt ? a : b;
      });
    } catch (e) {
      debugPrint('[TimelineAnalytics] Error finding largest goal: $e');
      return entries.first;
    }
  }

  /// Обчислює відсоток цілей з високим бонусом XP.
  ///
  /// [entries] — список завершених цілей.
  double highXpGoalPercentage(List<_CompletedGoal> entries) {
    if (entries.isEmpty) return 0.0;
    try {
      final highXp = entries.where((e) => e.xpEarned >= _kHighXpThreshold).length;
      return (highXp / entries.length) * 100;
    } catch (e) {
      debugPrint('[TimelineAnalytics] Error calculating high XP %: $e');
      return 0.0;
    }
  }

  /// Обчислює загальну суму зароблених монет.
  ///
  /// [entries] — список завершених цілей.
  int totalCoinsEarned(List<_CompletedGoal> entries) {
    if (entries.isEmpty) return 0;
    try {
      return entries.fold<int>(0, (sum, e) => sum + e.coinsEarned);
    } catch (e) {
      debugPrint('[TimelineAnalytics] Error calculating total coins: $e');
      return 0;
    }
  }
}

class AchievementHistoryScreen extends StatefulWidget {
  const AchievementHistoryScreen({super.key});

  @override
  State<AchievementHistoryScreen> createState() => _AchievementHistoryScreenState();
}

class _AchievementHistoryScreenState extends State<AchievementHistoryScreen> {
  final Set<int> _expanded = {};
  bool _isRefreshing = false;
  bool _isLoading = true;
  bool _showCompletedOnly = false;

  /// Аналітика хронології цілей.
  final _TimelineAnalytics _analytics = const _TimelineAnalytics();

  /// Чи показувати панель статистики.
  bool _showTimelineStats = false;

  /// Лічильник розгорнутих карток.
  int _expandedCount = 0;

  /// Фільтр: null = все, 'goals' = цілі, 'challenges' = виклики
  String? _filterType;

  /// Мокові дані завершених цілей — розширено з milestones
  final _completedGoals = const [
    _CompletedGoal(
      name: 'PlayStation 5',
      icon: Icons.gamepad_rounded,
      completedDate: '15 лютого 2025',
      totalAmount: '25 999 грн',
      depositCount: 87,
      daysTaken: 45,
      averageDeposit: '299 грн',
      type: 'goal',
      xpEarned: 350,
      coinsEarned: 75,
      badgeName: 'Перший мільйон',
      milestone: 'Накопичено більше 25 000 грн за один mục',
      streak: 12,
    ),
    _CompletedGoal(
      name: 'Навушники Sony WH-1000XM5',
      icon: Icons.headphones_rounded,
      completedDate: '10 березня 2025',
      totalAmount: '8 500 грн',
      depositCount: 32,
      daysTaken: 28,
      averageDeposit: '266 грн',
      type: 'goal',
      xpEarned: 180,
      coinsEarned: 40,
      badgeName: 'Меломан',
      milestone: 'Перший завершений аксесуар',
      streak: 7,
    ),
    _CompletedGoal(
      name: '7 днів без кави',
      icon: Icons.local_cafe_rounded,
      completedDate: '22 березня 2025',
      totalAmount: '500 грн',
      depositCount: 7,
      daysTaken: 7,
      averageDeposit: '71 грн',
      type: 'challenge',
      xpEarned: 50,
      coinsEarned: 25,
      badgeName: 'Челендж-майстер',
      milestone: 'Перший виклик завершено!',
      streak: 7,
    ),
    _CompletedGoal(
      name: 'Контроллер DualSense',
      icon: Icons.sports_esports_rounded,
      completedDate: '5 квітня 2025',
      totalAmount: '3 200 грн',
      depositCount: 15,
      daysTaken: 20,
      averageDeposit: '213 грн',
      type: 'goal',
      xpEarned: 120,
      coinsEarned: 30,
      badgeName: null,
      milestone: null,
      streak: 5,
    ),
    _CompletedGoal(
      name: '14 днів щоденних внесків',
      icon: Icons.local_fire_department_rounded,
      completedDate: '19 квітня 2025',
      totalAmount: '1 400 грн',
      depositCount: 14,
      daysTaken: 14,
      averageDeposit: '100 грн',
      type: 'challenge',
      xpEarned: 80,
      coinsEarned: 35,
      badgeName: 'Стихійний накопичувач',
      milestone: 'Серія 14 днів поспіль!',
      streak: 14,
    ),
    _CompletedGoal(
      name: 'Підписка PS Plus',
      icon: Icons.card_membership_rounded,
      completedDate: '1 травня 2025',
      totalAmount: '1 799 грн',
      depositCount: 6,
      daysTaken: 10,
      averageDeposit: '300 грн',
      type: 'goal',
      xpEarned: 90,
      coinsEarned: 20,
      badgeName: 'Підписник',
      milestone: null,
      streak: 4,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _simulateLoading();
  }

  void _simulateLoading() {
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    });
  }

  Future<void> _onRefresh() async {
    setState(() => _isRefreshing = true);
    await Future.delayed(const Duration(milliseconds: 800));
    if (mounted) {
      setState(() => _isRefreshing = false);
    }
  }

  List<_CompletedGoal> get _filteredGoals {
    var list = _completedGoals;
    if (_filterType != null) {
      list = list.where((g) => g.type == _filterType).toList();
    }
    if (_showCompletedOnly) {
      list = list.where((g) => g.badgeName != null).toList();
    }
    return list;
  }

  int get _totalXP => _completedGoals.fold<int>(0, (sum, g) => sum + g.xpEarned);
  int get _totalCoins => _completedGoals.fold<int>(0, (sum, g) => sum + g.coinsEarned);
  int get _completedCount => _completedGoals.length;

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final textColor = isDark ? AppColorsPS5.textPrimary : AppColorsMonitor.textPrimary;
    final subColor = isDark ? AppColorsPS5.textSecondary : AppColorsMonitor.textSecondary;
    final cardColor = isDark ? AppColorsPS5.card : AppColorsMonitor.card;

    if (_isLoading) {
      return Scaffold(
        backgroundColor: isDark ? AppColorsPS5.background : AppColorsMonitor.background,
        appBar: AppBar(
          title: const Text('Мої перемоги'),
          backgroundColor: Colors.transparent,
          elevation: 0,
          foregroundColor: textColor,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: Spacing.md),
              Text(
                'Завантаження досягнень...',
                style: AppTypography.labelMedium.copyWith(color: subColor),
              ),
            ],
          ),
        ),
      );
    }

    final filtered = _filteredGoals;

    return Scaffold(
      backgroundColor: isDark ? AppColorsPS5.background : AppColorsMonitor.background,
      appBar: AppBar(
        title: const Text('Мої перемоги'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: textColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list_rounded),
            onPressed: () => setState(() => _showCompletedOnly = !_showCompletedOnly),
          ),
        ],
      ),
      body: filtered.isEmpty
          ? AppEmptyState(
              icon: Icons.emoji_events_outlined,
              title: 'Ще немає завершених цілей',
              subtitle: 'Почни накопичувати і тут з\'являться твої досягнення!',
              actionLabel: 'Створити нову мету',
              onAction: () => Navigator.of(context).pushNamed('/set-goal'),
            )
          : Column(
              children: [
                // ─── Загальна статистика ────────────────────────
                Container(
                  margin: const EdgeInsets.all(Spacing.base),
                  padding: const EdgeInsets.all(Spacing.base),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(Radii.lg),
                    border: Border.all(
                      color: isDark ? AppColorsPS5.border : AppColorsMonitor.border,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _SummaryChip(
                        icon: Icons.emoji_events_rounded,
                        value: '$_completedCount',
                        label: 'Завершено',
                        color: isDark ? AppColorsPS5.accent : AppColorsMonitor.accent,
                      ),
                      _SummaryChip(
                        icon: Icons.star_rounded,
                        value: '$_totalXP',
                        label: 'XP',
                        color: AppColorsPS5.xp,
                      ),
                      _SummaryChip(
                        icon: Icons.monetization_on_rounded,
                        value: '$_totalCoins',
                        label: 'Монет',
                        color: AppColorsPS5.coin,
                      ),
                    ],
                  ),
                ).animate().fadeIn(duration: 400.ms),

                // ─── Фільтри по типу ──────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: Spacing.base),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _FilterChip(
                          label: 'Усе',
                          isActive: _filterType == null,
                          onTap: () => setState(() => _filterType = null),
                          isDark: isDark,
                        ),
                        const SizedBox(width: Spacing.sm),
                        _FilterChip(
                          label: 'Цілі',
                          isActive: _filterType == 'goal',
                          onTap: () => setState(() => _filterType = 'goal'),
                          isDark: isDark,
                        ),
                        const SizedBox(width: Spacing.sm),
                        _FilterChip(
                          label: 'Виклики',
                          isActive: _filterType == 'challenge',
                          onTap: () => setState(() => _filterType = 'challenge'),
                          isDark: isDark,
                        ),
                        const SizedBox(width: Spacing.sm),
                        _FilterChip(
                          label: 'Зі значком',
                          icon: Icons.workspace_premium_rounded,
                          isActive: _showCompletedOnly,
                          onTap: () => setState(() => _showCompletedOnly = !_showCompletedOnly),
                          isDark: isDark,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: Spacing.sm),

                // ─── Лічильник ────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: Spacing.base),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${filtered.length} з ${_completedGoals.length}',
                        style: AppTypography.labelMedium.copyWith(color: subColor),
                      ),
                      Text(
                        'XP: ${filtered.fold<int>(0, (sum, g) => sum + g.xpEarned)}',
                        style: AppTypography.labelMedium.copyWith(
                          color: isDark ? AppColorsPS5.xp : AppColorsMonitor.accent,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: Spacing.sm),

                // ─── Список з timeline ────────────────────────
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _onRefresh,
                    color: isDark ? AppColorsPS5.accent : AppColorsMonitor.accent,
                    child: filtered.isEmpty
                        ? ListView(
                            children: [
                              const SizedBox(height: 120),
                              Center(
                                child: Column(
                                  children: [
                                    Icon(Icons.filter_alt_off_rounded, size: 48, color: subColor.withOpacity(0.5)),
                                    const SizedBox(height: Spacing.md),
                                    Text(
                                      'Нічого не знайдено за цим фільтром',
                                      style: AppTypography.bodyMedium.copyWith(color: subColor),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: Spacing.base),
                            itemCount: filtered.length,
                            itemBuilder: (context, index) {
                              final goal = filtered[index];
                              final isExpanded = _expanded.contains(index);
                              final isLast = index == filtered.length - 1;

                              return _GoalTimelineEntry(
                                goal: goal,
                                isExpanded: isExpanded,
                                isDark: isDark,
                                isLast: isLast,
                                staggerDelay: index * 80,
                                onTap: () {
                                  context.haptic();
                                  setState(() {
                                    if (isExpanded) {
                                      _expanded.remove(index);
                                    } else {
                                      _expanded.add(index);
                                    }
                                  });
                                },
                              );
                            },
                          ),
                  ),
                ),

                // ─── Кнопка «Створити нову мету» ────────────────
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(Spacing.base, Spacing.sm, Spacing.base, Spacing.xxl),
                  decoration: BoxDecoration(
                    color: cardColor,
                    border: Border(
                      top: BorderSide(
                        color: isDark ? AppColorsPS5.border : AppColorsMonitor.border,
                      ),
                    ),
                  ),
                  child: AppButtonPrimary(
                    label: 'Створити нову мету',
                    icon: Icons.add_rounded,
                    showGlow: true,
                    onPressed: () => Navigator.of(context).pushNamed('/set-goal'),
                  ),
                ),
              ],
            ),
    );
  }
}

/// Чип підсумку для загальної статистики.
class _SummaryChip extends StatelessWidget {
  const _SummaryChip({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(Radii.md),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(height: Spacing.xs),
        Text(
          value,
          style: AppTypography.monoMedium.copyWith(
            color: color,
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          label,
          style: AppTypography.labelSmall.copyWith(
            color: color.withOpacity(0.7),
          ),
        ),
      ],
    );
  }
}

/// Фільтр-чип для переключення типів.
class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.isActive,
    required this.onTap,
    required this.isDark,
    this.icon,
  });

  final String label;
  final bool isActive;
  final VoidCallback onTap;
  final bool isDark;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final accent = isDark ? AppColorsPS5.accent : AppColorsMonitor.accent;
    final textColor = isDark ? AppColorsPS5.textPrimary : AppColorsMonitor.textPrimary;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(
          horizontal: Spacing.base,
          vertical: Spacing.sm,
        ),
        decoration: BoxDecoration(
          color: isActive ? accent : Colors.transparent,
          borderRadius: BorderRadius.circular(Radii.circular),
          border: Border.all(
            color: isActive ? accent : (isDark ? AppColorsPS5.border : AppColorsMonitor.border),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 14, color: isActive ? Colors.white : textColor),
              const SizedBox(width: Spacing.xs),
            ],
            Text(
              label,
              style: AppTypography.labelLarge.copyWith(
                color: isActive ? Colors.white : textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Timeline-запис з розширюваними деталями та stagger-анімаціями.
class _GoalTimelineEntry extends StatelessWidget {
  const _GoalTimelineEntry({
    required this.goal,
    required this.isExpanded,
    required this.isDark,
    required this.isLast,
    required this.onTap,
    this.staggerDelay = 0,
  });

  final _CompletedGoal goal;
  final bool isExpanded;
  final bool isDark;
  final bool isLast;
  final VoidCallback onTap;
  final int staggerDelay;

  @override
  Widget build(BuildContext context) {
    final cardColor = isDark ? AppColorsPS5.card : AppColorsMonitor.card;
    final textColor = isDark ? AppColorsPS5.textPrimary : AppColorsMonitor.textPrimary;
    final subColor = isDark ? AppColorsPS5.textSecondary : AppColorsMonitor.textSecondary;
    final accent = isDark ? AppColorsPS5.accent : AppColorsMonitor.accent;
    final bool isChallenge = goal.type == 'challenge';

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Timeline лінія та точка ────────────────────
          SizedBox(
            width: 32,
            child: Column(
              children: [
                Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isChallenge ? AppColorsPS5.coin : accent,
                    border: Border.all(color: cardColor, width: 3),
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: (isDark ? AppColorsPS5.border : AppColorsMonitor.border)
                          .withOpacity(0.5),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: Spacing.sm),

          // ── Контент картки ──────────────────────────────
          Expanded(
            child: GestureDetector(
              onTap: onTap,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.only(bottom: Spacing.md),
                padding: const EdgeInsets.all(Spacing.base),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(Radii.lg),
                  border: Border.all(
                    color: isExpanded
                        ? accent
                        : (isDark ? AppColorsPS5.border : AppColorsMonitor.border),
                  ),
                ),
                child: Column(
                  children: [
                    // Header row
                    Row(
                      children: [
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                (isChallenge ? AppColorsPS5.coin : accent).withOpacity(0.3),
                                (isChallenge ? AppColorsPS5.coin : accent).withOpacity(0.1),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(Radii.md),
                          ),
                          child: Icon(goal.icon, color: accent, size: 26),
                        ),
                        const SizedBox(width: Spacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Flexible(
                                    child: Text(
                                      goal.name,
                                      style: AppTypography.heading3.copyWith(color: textColor),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  if (isChallenge) ...[
                                    const SizedBox(width: Spacing.xs),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: Spacing.xs,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColorsPS5.coin.withOpacity(0.15),
                                        borderRadius: BorderRadius.circular(Radii.sm),
                                      ),
                                      child: Text(
                                        'Виклик',
                                        style: AppTypography.labelSmall.copyWith(
                                          color: AppColorsPS5.coin,
                                          fontSize: 10,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                goal.completedDate,
                                style: AppTypography.bodySmall.copyWith(color: subColor),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          isExpanded ? Icons.expand_less_rounded : Icons.expand_more_rounded,
                          color: subColor,
                        ),
                      ],
                    ),

                    // Quick stats bar
                    const SizedBox(height: Spacing.sm),
                    Row(
                      children: [
                        _quickStatChip(Icons.star_rounded, '+${goal.xpEarned} XP', AppColorsPS5.xp),
                        const SizedBox(width: Spacing.xs),
                        _quickStatChip(Icons.coins_rounded, '+${goal.coinsEarned}', AppColorsPS5.coin),
                        const SizedBox(width: Spacing.xs),
                        _quickStatChip(Icons.local_fire_department_rounded, '${goal.streak} дн.', AppColorsPS5.accent),
                      ],
                    ),

                    // Розгорнуті деталі
                    AnimatedCrossFade(
                      firstChild: const SizedBox.shrink(),
                      secondChild: Padding(
                        padding: const EdgeInsets.only(top: Spacing.md),
                        child: Container(
                          padding: const EdgeInsets.all(Spacing.base),
                          decoration: BoxDecoration(
                            color: (isDark ? AppColorsPS5.surface : AppColorsMonitor.surface),
                            borderRadius: BorderRadius.circular(Radii.md),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _statRow('Всього накопичено', goal.totalAmount, textColor, subColor),
                              _statRow('Кількість внесків', '${goal.depositCount}', textColor, subColor),
                              _statRow('Днів', '${goal.daysTaken}', textColor, subColor),
                              _statRow('Середній внесок', goal.averageDeposit, textColor, subColor),
                              _statRow('XP отримано', '+${goal.xpEarned}', textColor, subColor),
                              _statRow('Монети', '+${goal.coinsEarned}', textColor, subColor),
                              _statRow('Найдовша серія', '${goal.streak} дн.', textColor, subColor),
                              if (goal.badgeName != null)
                                _statRow('Значок', '🏆 ${goal.badgeName!}', AppColorsPS5.xp, subColor),
                              if (goal.milestone != null) ...[
                                const SizedBox(height: Spacing.sm),
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(Spacing.sm),
                                  decoration: BoxDecoration(
                                    color: (isDark ? AppColorsPS5.accent : AppColorsMonitor.accent).withOpacity(0.08),
                                    borderRadius: BorderRadius.circular(Radii.sm),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.flag_rounded, size: 14, color: AppColorsPS5.accent),
                                      const SizedBox(width: Spacing.xs),
                                      Expanded(
                                        child: Text(
                                          goal.milestone!,
                                          style: AppTypography.labelSmall.copyWith(
                                            color: isDark ? AppColorsPS5.accent : AppColorsMonitor.accent,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                      crossFadeState: isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                      duration: const Duration(milliseconds: 300),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms, delay: Duration(milliseconds: staggerDelay));
  }

  Widget _quickStatChip(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(Radii.sm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: color),
          const SizedBox(width: 2),
          Text(
            text,
            style: AppTypography.labelSmall.copyWith(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _statRow(String label, String value, Color textColor, Color subColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Spacing.xs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTypography.bodyMedium.copyWith(color: subColor)),
          Text(
            value,
            style: AppTypography.monoSmall.copyWith(color: textColor, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

/// Модель завершеної цілі з розширеними полями.
///
/// Містить інформацію про завершену ціль або виклик:
/// - Назву, іконку, дату завершення
/// - Фінансові показники (сума, кількість внесків, середній внесок)
/// - Гейміфікаційні нагороди (XP, монети, значки)
/// - Статистику серії та досягнення (milestones)
///
/// Використовується в [AchievementHistoryScreen] для відображення
/// в timeline-форматі з розгортанням деталей.
class _CompletedGoal {
  /// Назва завершеної цілі або виклику.
  final String name;

  /// Іконка для відображення в картці.
  final IconData icon;

  /// Дата завершення у форматі 'dd MMMM yyyy' (українською).
  final String completedDate;

  /// Загальна сума накопичень (формат: 'XX XXX грн').
  final String totalAmount;

  /// Загальна кількість внесків за час накопичування.
  final int depositCount;

  /// Кількість днів від початку до завершення.
  final int daysTaken;

  /// Середній розмір одного внеску (формат: 'XXX грн').
  final String averageDeposit;

  /// Тип запису: 'goal' для цілей, 'challenge' для викликів.
  final String type;

  /// Кількість XP, отриманих за завершення.
  final int xpEarned;

  /// Кількість монет, отриманих за завершення.
  final int coinsEarned;

  /// Назва значка (null якщо значок не отримано).
  final String? badgeName;

  /// Опис досягнення/milestone (null якщо відсутнє).
  final String? milestone;

  /// Найдовша серія послідовних внесків (у днях).
  final int streak;

  /// Чи це преміум досягнення (XP > 200 або монети > 50).
  bool get isPremium => xpEarned >= _kHighXpThreshold || coinsEarned >= _kPremiumCoinThreshold;

  /// Повертає тип запису для відображення в UI.
  String get typeLabel => type == 'goal' ? 'Ціль' : 'Виклик';

  /// Повертає іконку типу для відображення.
  IconData get typeIcon => type == 'goal' ? Icons.flag_rounded : Icons.emoji_events_rounded;

  /// Повертає колір типу.
  Color typeColor(bool isDark) =>
      type == 'challenge' ? AppColorsPS5.coin : (isDark ? AppColorsPS5.accent : AppColorsMonitor.accent);

  /// Форматує тривалість як 'X дн.'.
  String get formattedDaysTaken => '$daysTaken дн.';

  const _CompletedGoal({
    required this.name,
    required this.icon,
    required this.completedDate,
    required this.totalAmount,
    required this.depositCount,
    required this.daysTaken,
    required this.averageDeposit,
    required this.type,
    required this.xpEarned,
    required this.coinsEarned,
    this.badgeName,
    this.milestone,
    required this.streak,
  });
}

// ═══════════════════════════════════════════════════════════════════════════
// Додаткові константи екрану «Мої перемоги»
// ═══════════════════════════════════════════════════════════════════════════

/// Максимальна кількість записів для експорту історії досягнень.
const int _kMaxExportGoals = 100;

/// Тривалість анімації появи запису хронології (мілісекунди).
const int _kTimelineEntryAnimMs = 450;

/// Мінімальна кількість XP для badge «Ветеран досягнень».
const int _kVeteranXpThreshold = 500;

/// Мінімальна серія для badge «Залізна воля».
const int _kIronWillStreak = 30;

/// Кількість записів у міні-хронології для віджетів.
const int _kMiniTimelineCount = 3;

/// Тривалість затримки між batch-експортами (мілісекунди).
const int _kExportBatchDelayMs = 200;

/// Максимальна ширина тексту назви цілі в хронології.
const int _kMaxGoalNameWidth = 35;

/// Формат дати для записів хронології.
const String _kTimelineDateFormat = 'dd MMM yyyy';

/// Кількість місяців для аналізу трендів досягнень.
const int _kTrendAnalysisMonths = 6;

/// Мінімальна кількість записів для обчислення тренду.
const int _kMinTrendEntries = 3;

/// Коефіцієнт для розрахунку «velocity» досягнень (ц/день).
const double _kVelocityFactor = 1.5;

/// Максимальна кількість фільтрів для хронології.
const int _kMaxTimelineFilters = 8;

/// Тривалість анімації badge появи (мілісекунди).
const int _kBadgeAppearMs = 350;

/// Префікс для ключів кешу хронології.
const String _kTimelineCachePrefix = 'timeline_';

/// Максимальна кількість записів у кеші хронології.
const int _kTimelineMaxCacheEntries = 30;

// ═══════════════════════════════════════════════════════════════════════════
// Розширена аналітика досягнень
// ═══════════════════════════════════════════════════════════════════════════

/// Розширена аналітика досягнень для розрахунку додаткових метрик.
///
/// Надає методи для аналізу трендів, velocity, batch-операцій
/// та обчислення преміум-досягнень.
class _AchievementAdvancedAnalytics {
  /// Створює об'єкт розширеної аналітики.
  const _AchievementAdvancedAnalytics();

  /// Обчислює загальну суму зібраних коштів за всі цілі.
  ///
  /// [goals] — список завершених цілей.
  int totalAmountSaved(List<_CompletedGoal> goals) {
    if (goals.isEmpty) return 0;
    try {
      return goals.fold<int>(0, (sum, g) {
        final cleaned = g.totalAmount.replaceAll(RegExp(r'[^0-9]'), '');
        return sum + (int.tryParse(cleaned) ?? 0);
      });
    } catch (e) {
      debugPrint('[AchievementAnalytics] Error calculating total saved: $e');
      return 0;
    }
  }

  /// Обчислює середню тривалість досягнення цілі (у днях).
  ///
  /// [goals] — список завершених цілей.
  double averageDaysToComplete(List<_CompletedGoal> goals) {
    if (goals.isEmpty) return 0.0;
    try {
      final total = goals.fold<int>(0, (sum, g) => sum + g.daysTaken);
      return total / goals.length;
    } catch (e) {
      return 0.0;
    }
  }

  /// Повертає найдовшу серію послідовних внесків.
  ///
  /// [goals] — список завершених цілей.
  int longestStreak(List<_CompletedGoal> goals) {
    if (goals.isEmpty) return 0;
    try {
      return goals.fold<int>(0, (max, g) => g.streak > max ? g.streak : max);
    } catch (e) {
      return 0;
    }
  }

  /// Обчислює загальну кількість XP, отриману за всі досягнення.
  ///
  /// [goals] — список завершених цілей.
  int totalXpEarned(List<_CompletedGoal> goals) {
    if (goals.isEmpty) return 0;
    try {
      return goals.fold<int>(0, (sum, g) => sum + g.xpEarned);
    } catch (e) {
      return 0;
    }
  }

  /// Обчислює загальну кількість монет, отриманих за досягнення.
  ///
  /// [goals] — список завершених цілей.
  int totalCoinsEarned(List<_CompletedGoal> goals) {
    if (goals.isEmpty) return 0;
    try {
      return goals.fold<int>(0, (sum, g) => sum + g.coinsEarned);
    } catch (e) {
      return 0;
    }
  }

  /// Обчислює загальну кількість внесків за всі цілі.
  ///
  /// [goals] — список завершених цілей.
  int totalDeposits(List<_CompletedGoal> goals) {
    if (goals.isEmpty) return 0;
    return goals.fold<int>(0, (sum, g) => sum + g.depositCount);
  }

  /// Повертає відсоток преміум досягнень (XP >= 200 або монети >= 50).
  ///
  /// [goals] — список завершених цілей.
  double premiumPercentage(List<_CompletedGoal> goals) {
    if (goals.isEmpty) return 0.0;
    final premium = goals.where((g) => g.isPremium).length;
    return (premium / goals.length) * 100;
  }

  /// Обчислює «velocity» досягнень (середня сума за день).
  ///
  /// Повертає середню швидкість накопичення у форматі «X грн/день».
  String velocityFormatted(List<_CompletedGoal> goals) {
    if (goals.isEmpty) return '0 грн/дн';
    final avgDays = averageDaysToComplete(goals);
    if (avgDays == 0) return '∞';
    final total = totalAmountSaved(goals);
    final velocity = (total / avgDays * _kVelocityFactor).round();
    return '$velocity грн/дн';
  }

  /// Повертає кількість досягнень кожного типу.
  ///
  /// [goals] — список завершених цілей.
  Map<String, int> countByType(List<_CompletedGoal> goals) {
    final counts = <String, int>{};
    for (final goal in goals) {
      counts[goal.type] = (counts[goal.type] ?? 0) + 1;
    }
    return counts;
  }

  /// Повертає список унікальних значків, отриманих користувачем.
  ///
  /// [goals] — список завершених цілей.
  List<String> earnedBadges(List<_CompletedGoal> goals) {
    return goals
        .where((g) => g.badgeName != null && g.badgeName!.isNotEmpty)
        .map((g) => g.badgeName!)
        .toSet()
        .toList()
      ..sort();
  }

  /// Перевіряє, чи користувач має badge «Ветеран досягнень».
  ///
  /// [goals] — список завершених цілей.
  bool hasVeteranBadge(List<_CompletedGoal> goals) {
    return totalXpEarned(goals) >= _kVeteranXpThreshold;
  }

  /// Перевіряє, чи користувач має badge «Залізна воля».
  ///
  /// [goals] — список завершених цілей.
  bool hasIronWillBadge(List<_CompletedGoal> goals) {
    return longestStreak(goals) >= _kIronWillStreak;
  }

  /// Розбиває список цілей на партії для експорту.
  ///
  /// [goals] — список завершених цілей.
  /// [batchSize] — розмір однієї партії.
  List<List<_CompletedGoal>> batched(List<_CompletedGoal> goals, {int batchSize = _kExportBatchSize}) {
    if (goals.isEmpty) return [];
    final batches = <List<_CompletedGoal>>[];
    for (var i = 0; i < goals.length; i += batchSize) {
      final end = (i + batchSize).clamp(0, goals.length);
      batches.add(goals.sublist(i, end));
    }
    return batches;
  }

  /// Форматує зведення досягнень для UI.
  ///
  /// [goals] — список завершених цілей.
  static String formatSummary(List<_CompletedGoal> goals) {
    if (goals.isEmpty) return 'Немає завершених цілей';
    final total = goals.length;
    final challenges = goals.where((g) => g.type == 'challenge').length;
    final badges = goals.where((g) => g.badgeName != null).length;
    return 'Усього: $total | Викликів: $challenges | Значків: $badges';
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Валідатор даних екрану досягнень
// ═══════════════════════════════════════════════════════════════════════════

/// Клас для валідації даних екрану досягнень.
///
/// Перевіряє коректність параметрів цілей, фільтрів, пошукових запитів.
class _AchievementValidator {
  /// Не дозволяє створення екземплярів.
  _AchievementValidator._();

  /// Перевіряє коректність пошукового запиту.
  ///
  /// [query] — пошуковий запит для перевірки.
  static bool isValidSearchQuery(String query) {
    if (query.isEmpty) return true;
    final trimmed = query.trim();
    return trimmed.length >= _kMinSearchLength;
  }

  /// Перевіряє, чи кількість записів для експорту в межах ліміту.
  ///
  /// [count] — кількість записів.
  static bool isValidExportCount(int count) {
    return count > 0 && count <= _kMaxExportGoals;
  }

  /// Перевіряє, чи індекс запису хронології в допустимих межах.
  ///
  /// [index] — індекс для перевірки.
  /// [totalCount] — загальна кількість записів.
  static bool isValidIndex(int index, int totalCount) {
    return index >= 0 && index < totalCount;
  }

  /// Перевіряє коректність кількості сторінок пагінації.
  ///
  /// [page] — номер сторінки (починається з 0).
  /// [totalPages] — загальна кількість сторінок.
  static bool isValidPage(int page, int totalPages) {
    return page >= 0 && page < totalPages;
  }

  /// Перевіряє, чи значення XP в допустимому діапазоні.
  ///
  /// [xp] — значення XP для перевірки.
  static bool isValidXp(int xp) {
    return xp >= 0 && xp <= 10000;
  }

  /// Перевіряє, чи тривалість досягнення в розумних межах.
  ///
  /// [days] — кількість днів.
  static bool isValidDays(int days) {
    return days > 0 && days <= 3650;
  }

  /// Повертає очищений пошуковий запит.
  ///
  /// [query] — необроблений запит.
  static String sanitizedQuery(String query) {
    if (query.isEmpty) return '';
    return query.trim();
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Кеш хронології досягнень
// ═══════════════════════════════════════════════════════════════════════════

/// Клас для кешування даних хронології досягнень.
///
/// Зменшує кількість обчислень при rebuild шляхом
/// збереження оброблених списків та статистики.
class _TimelineCache {
  /// Створює кеш з початковими значеннями.
  _TimelineCache();

  /// Внутрішнє сховище.
  final Map<String, dynamic> _store = {};

  /// Зберігає значення за ключем.
  ///
  /// [key] — унікальний ключ.
  /// [value] — значення для кешування.
  void put(String key, dynamic value) {
    if (_store.length >= _kTimelineMaxCacheEntries) {
      _store.remove(_store.keys.first);
    }
    _store['$_kTimelineCachePrefix$key'] = value;
  }

  /// Отримує значення з кешу.
  ///
  /// [key] — унікальний ключ.
  T? get<T>(String key) {
    final value = _store['$_kTimelineCachePrefix$key'];
    if (value is T) return value;
    return null;
  }

  /// Перевіряє наявність ключа в кеші.
  bool contains(String key) => _store.containsKey('$_kTimelineCachePrefix$key');

  /// Очищає весь кеш.
  void clear() => _store.clear();

  /// Розмір кешу.
  int get size => _store.length;

  /// Чи порожній.
  bool get isEmpty => _store.isEmpty;
}

// ═══════════════════════════════════════════════════════════════════════════
// Темо-залежний будівник декорацій для хронології
// ═══════════════════════════════════════════════════════════════════════════

/// Будівник декорацій для екрану досягнень.
///
/// Надає готові методи для створення темо-залежних
/// декорацій записів хронології, бейджів та карток.
class _AchievementDecorations {
  /// Не дозволяє створення екземплярів.
  _AchievementDecorations._();

  /// Створює декорацію для запису хронології.
  ///
  /// [isDark] — чи використовується темна тема.
  static BoxDecoration timelineEntry(bool isDark) {
    return BoxDecoration(
      color: isDark ? AppColorsPS5.card : AppColorsMonitor.card,
      borderRadius: BorderRadius.circular(Radii.lg),
      border: Border.all(
        color: isDark ? AppColorsPS5.border : AppColorsMonitor.border,
      ),
    );
  }

  /// Створює декорацію для преміум запису з градієнтом.
  ///
  /// [accent] — акцентний колір.
  static BoxDecoration premiumEntry(Color accent) {
    return BoxDecoration(
      gradient: LinearGradient(
        colors: [
          accent.withOpacity(0.08),
          accent.withOpacity(0.02),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(Radii.lg),
      border: Border.all(color: accent.withOpacity(0.2)),
    );
  }

  /// Створює декорацію для бейджа досягнення.
  ///
  /// [color] — колір бейджа.
  static BoxDecoration achievementBadge(Color color) {
    return BoxDecoration(
      color: color.withOpacity(0.15),
      borderRadius: BorderRadius.circular(Radii.xl),
      border: Border.all(color: color.withOpacity(0.3)),
    );
  }

  /// Створює декорацію для фільтр-чіпа.
  ///
  /// [isActive] — чи фільтр активний.
  /// [color] — колір фільтра.
  static BoxDecoration filterChip(bool isActive, Color color) {
    return BoxDecoration(
      color: isActive ? color : Colors.transparent,
      borderRadius: BorderRadius.circular(Radii.md),
      border: Border.all(
        color: isActive ? color : color.withOpacity(0.3),
      ),
    );
  }

  /// Створює декорацію для контейнера статистики.
  ///
  /// [isDark] — чи використовується темна тема.
  static BoxDecoration statsCard(bool isDark) {
    return BoxDecoration(
      color: (isDark ? AppColorsPS5.card : AppColorsMonitor.card).withOpacity(0.8),
      borderRadius: BorderRadius.circular(Radii.md),
    );
  }

  /// Створює декорацію для milestone-індикатора.
  ///
  /// [color] — колір milestone.
  static BoxDecoration milestoneDot(Color color) {
    return BoxDecoration(
      color: color,
      shape: BoxShape.circle,
      boxShadow: [
        BoxShadow(
          color: color.withOpacity(0.4),
          blurRadius: 8,
          spreadRadius: 2,
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Провайдер підказок для екрану досягнень
// ═══════════════════════════════════════════════════════════════════════════

/// Провайдер контекстних підказок для користувача екрану досягнень.
class _AchievementTipProvider {
  /// Не дозволяє створення екземплярів.
  _AchievementTipProvider._();

  /// Підказка для порожнього списку досягнень.
  static String emptyListTip() {
    return 'Тут з\'являться твої завершені цілі та виклики.';
  }

  /// Підказка для порожнього результату пошуку.
  static String emptySearchTip() {
    return 'Досягнень за цим запитом не знайдено.';
  }

  /// Підказка для першого досягнення.
  static String firstAchievementTip() {
    return 'Вітаємо з першим досягненням! Продовжуй у тому ж дусі!';
  }

  /// Підказка для преміум досягнення.
  static String premiumTip(String goalName) {
    return 'Преміум досягнення: $goalName! Чудовий результат!';
  }

  /// Підказка для довгої серії.
  static String streakTip(int streakDays) {
    if (streakDays >= _kIronWillStreak) {
      return 'Залізна воля! $streakDays днів поспіль!';
    }
    return 'Серія: $streakDays днів. Тримаймо марку!';
  }

  /// Форматує підсумок досягнень для пошуку.
  ///
  /// [query] — пошуковий запит.
  /// [resultCount] — кількість результатів.
  static String searchResultTip(String query, int resultCount) {
    if (resultCount == 0) {
      return 'За запитом «$query» нічого не знайдено.';
    } else if (resultCount == 1) {
      return 'Знайдено 1 досягнення за запитом «$query».';
    }
    return 'Знайдено $resultCount досягнень за запитом «$query».';
  }

  /// Підказка для заохочення досягнення нової цілі.
  static String encouragementTip(int completedCount) {
    if (completedCount >= 20) {
      return 'Неймовірна кількість досягнень! Ти — справжній майстер!';
    } else if (completedCount >= 10) {
      return '$completedCount досягнень! Ти на правильному шляху!';
    } else if (completedCount >= 5) {
      return 'Уже $completedCount досягнень. Не зупиняйся!';
    }
    return 'Кожне досягнення наближає тебе до мрії!';
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Розширення для роботи з колекціями досягнень
// ═══════════════════════════════════════════════════════════════════════════

/// Розширення для списку завершених цілей з пакетними операціями.
extension _CompletedGoalListExtension on List<_CompletedGoal> {
  /// Фільтрує цілі за типом.
  ///
  /// [type] — тип цілі ('goal' або 'challenge').
  List<_CompletedGoal> filterByType(String type) {
    return where((g) => g.type == type).toList();
  }

  /// Фільтрує преміум досягнення.
  List<_CompletedGoal> premiumOnly() {
    return where((g) => g.isPremium).toList();
  }

  /// Сортує за датою завершення (найновіші перші).
  List<_CompletedGoal> sortedByDate() {
    final copy = List<_CompletedGoal>.from(this);
    copy.sort((a, b) => b.completedDate.compareTo(a.completedDate));
    return copy;
  }

  /// Сортує за XP (найбільші перші).
  List<_CompletedGoal> sortedByXp() {
    final copy = List<_CompletedGoal>.from(this);
    copy.sort((a, b) => b.xpEarned.compareTo(a.xpEarned));
    return copy;
  }

  /// Повертає цілі з серією більше порогу.
  ///
  /// [minStreak] — мінімальна серія.
  List<_CompletedGoal> withMinStreak(int minStreak) {
    return where((g) => g.streak >= minStreak).toList();
  }

  /// Повертає цілі з бейджами.
  List<_CompletedGoal> withBadges() {
    return where((g) => g.badgeName != null && g.badgeName!.isNotEmpty).toList();
  }

  /// Повертає перші [count] записів для міні-хронології.
  List<_CompletedGoal> takePreview({int count = _kMiniTimelineCount}) {
    return sortedByDate().take(count.clamp(1, length)).toList();
  }

  /// Повертає унікальні типи досягнень.
  List<String> uniqueTypes() {
    return map((g) => g.type).toSet().toList()..sort();
  }
}
