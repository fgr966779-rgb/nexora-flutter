import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_radii.dart';
import '../../../../core/extensions/build_context_ext.dart';
import '../../../../core/widgets/app_empty_state.dart';

/// Екран «Досягнення» — фільтри, timeline, статистика, категорії, відстеження прогресу,
/// календар досягнень, розподіл за рідкістю, поділитися.
class AchievementsScreen extends StatefulWidget {
  const AchievementsScreen({super.key});

  @override
  State<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _listController;
  String _selectedFilter = 'Усе';
  String _sortBy = 'Дата';
  bool _showCalendar = false;

  final _filters = ['Усе', 'Цілі', 'Виклики', 'Серії'];
  final _sortOptions = ['Дата', 'Категорія', 'Рідкість'];

  final _achievements = const [
    _AchievementItem(
      icon: Icons.flag_rounded,
      title: 'Перша ціль досягнута',
      date: '10 січня 2025',
      detail: 'Накопичено 15 000 грн на PlayStation 5',
      category: 'Цілі',
      isMilestone: false,
      progress: 100,
      rarity: 'Звичайне',
      xpReward: 50,
    ),
    _AchievementItem(
      icon: Icons.local_fire_department_rounded,
      title: 'Серія 7 днів',
      date: '18 січня 2025',
      detail: 'Внески 7 днів поспіль без перерв',
      category: 'Серії',
      isMilestone: false,
      progress: 100,
      rarity: 'Рідкісне',
      xpReward: 75,
    ),
    _AchievementItem(
      icon: Icons.emoji_events_rounded,
      title: '50% цілі зібрано',
      date: '25 січня 2025',
      detail: 'Половина шляху до PlayStation 5 пройдена',
      category: 'Цілі',
      isMilestone: true,
      progress: 50,
      rarity: 'Епічне',
      xpReward: 100,
    ),
    _AchievementItem(
      icon: Icons.bolt_rounded,
      title: 'Виклик «Швидкий старт»',
      date: '2 лютого 2025',
      detail: 'Внесено 500 грн за перший тиждень',
      category: 'Виклики',
      isMilestone: false,
      progress: 100,
      rarity: 'Звичайне',
      xpReward: 40,
    ),
    _AchievementItem(
      icon: Icons.star_rounded,
      title: '100% цілі досягнуто!',
      date: '15 лютого 2025',
      detail: 'PlayStation 5 куплено!',
      category: 'Цілі',
      isMilestone: true,
      progress: 100,
      rarity: 'Легендарне',
      xpReward: 200,
    ),
    _AchievementItem(
      icon: Icons.military_tech_rounded,
      title: 'Серія 30 днів',
      date: '20 лютого 2025',
      detail: 'Місяць щоденних внесків',
      category: 'Серії',
      isMilestone: true,
      progress: 100,
      rarity: 'Епічне',
      xpReward: 150,
    ),
    _AchievementItem(
      icon: Icons.trending_up_rounded,
      title: 'Виклик «Набираючи темп»',
      date: '22 лютого 2025',
      detail: 'Збільшити щоденний внесок на 20%',
      category: 'Виклики',
      isMilestone: false,
      progress: 100,
      rarity: 'Рідкісне',
      xpReward: 60,
    ),
    _AchievementItem(
      icon: Icons.workspace_premium_rounded,
      title: '10 викликів виконано',
      date: '1 березня 2025',
      detail: 'Ви майстер викликів!',
      category: 'Виклики',
      isMilestone: true,
      progress: 100,
      rarity: 'Легендарне',
      xpReward: 250,
    ),
    _AchievementItem(
      icon: Icons.diamond_rounded,
      title: 'Колекціонер значків',
      date: '',
      detail: 'Зібрати 10 різних значків',
      category: 'Виклики',
      isMilestone: false,
      progress: 70,
      rarity: 'Епічне',
      xpReward: 150,
    ),
    _AchievementItem(
      icon: Icons.calendar_month_rounded,
      title: '90 днів серія',
      date: '',
      detail: 'Три місяці щоденних внесків',
      category: 'Серії',
      isMilestone: true,
      progress: 45,
      rarity: 'Легендарне',
      xpReward: 500,
    ),
  ];

  final _calendarMonths = const [
    _CalendarMonth('Січень 2025', 2),
    _CalendarMonth('Лютий 2025', 4),
    _CalendarMonth('Березень 2025', 2),
  ];

  List<_AchievementItem> get _filtered {
    if (_selectedFilter == 'Усе') return _achievements;
    return _achievements.where((a) => a.category == _selectedFilter).toList();
  }

  int get _goalsCount =>
      _achievements.where((a) => a.category == 'Цілі').length;
  int get _challengesCount =>
      _achievements.where((a) => a.category == 'Виклики').length;
  int get _streaksCount =>
      _achievements.where((a) => a.category == 'Серії').length;
  int get _completedCount =>
      _achievements.where((a) => a.progress == 100).length;
  int get _legendaryCount =>
      _achievements.where((a) => a.rarity == 'Легендарне').length;
  int get _totalXpFromAchievements =>
      _achievements.fold(0, (sum, a) => sum + (a.progress == 100 ? a.xpReward : 0));

  @override
  void initState() {
    super.initState();
    _listController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _listController.forward();
  }

  @override
  void dispose() {
    _listController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;

    return Scaffold(
      backgroundColor:
          isDark ? AppColorsPS5.background : AppColorsMonitor.background,
      appBar: AppBar(
        title: const Text('Досягнення'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor:
            isDark ? AppColorsPS5.textPrimary : AppColorsMonitor.textPrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month_rounded),
            onPressed: () => setState(() => _showCalendar = !_showCalendar),
            tooltip: 'Календар досягнень',
          ),
          IconButton(
            icon: const Icon(Icons.share_rounded),
            onPressed: () {
              context.showToast('Посилання скопійовано!', icon: Icons.share_rounded);
            },
            tooltip: 'Поділитися',
          ),
        ],
      ),
      body: Column(
        children: [
          // ─── Статистика картки ───────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Spacing.base),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _miniStatCard(
                      '${_achievements.length}', 'Всього', isDark),
                  const SizedBox(width: Spacing.sm),
                  _miniStatCard('$_completedCount', 'Виконано', isDark),
                  const SizedBox(width: Spacing.sm),
                  _miniStatCard('$_goalsCount', 'Цілі', isDark),
                  const SizedBox(width: Spacing.sm),
                  _miniStatCard('$_challengesCount', 'Виклики', isDark),
                  const SizedBox(width: Spacing.sm),
                  _miniStatCard('$_streaksCount', 'Серії', isDark),
                  const SizedBox(width: Spacing.sm),
                  _miniStatCard('$_legendaryCount', 'Легенд.', isDark),
                ],
              ),
            ),
          ).animate().fade(duration: 300.ms),

          // ─── Календар досягнень ─────────────────────────────
          if (_showCalendar) ...[
            const SizedBox(height: Spacing.sm),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: Spacing.base),
              padding: const EdgeInsets.all(Spacing.md),
              decoration: BoxDecoration(
                color: isDark ? AppColorsPS5.card : AppColorsMonitor.card,
                borderRadius: BorderRadius.circular(Radii.lg),
                border: Border.all(
                  color: isDark ? AppColorsPS5.border : AppColorsMonitor.border,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Календар досягнень',
                    style: AppTypography.labelMedium.copyWith(
                      color: isDark ? AppColorsPS5.textPrimary : AppColorsMonitor.textPrimary,
                    ),
                  ),
                  const SizedBox(height: Spacing.sm),
                  ..._calendarMonths.map((m) => Padding(
                    padding: const EdgeInsets.only(bottom: Spacing.xs),
                    child: Row(
                      children: [
                        Text(
                          m.month,
                          style: AppTypography.bodySmall.copyWith(
                            color: isDark ? AppColorsPS5.textSecondary : AppColorsMonitor.textSecondary,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '${m.count} досягнень',
                          style: AppTypography.monoCaption.copyWith(
                            color: isDark ? AppColorsPS5.accent : AppColorsMonitor.accent,
                          ),
                        ),
                      ],
                    ),
                  )),
                ],
              ),
            ).animate().fade(duration: 300.ms),
          ],

          const SizedBox(height: Spacing.base),

          // ─── Загальний XP з досягнень ────────────────────────
          Container(
            margin: const EdgeInsets.symmetric(horizontal: Spacing.base),
            padding: const EdgeInsets.symmetric(horizontal: Spacing.base, vertical: Spacing.sm),
            decoration: BoxDecoration(
              color: (isDark ? AppColorsPS5.xp : AppColorsMonitor.xp).withOpacity(0.08),
              borderRadius: BorderRadius.circular(Radii.md),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.star_rounded, color: isDark ? AppColorsPS5.xp : AppColorsMonitor.xp, size: 16),
                const SizedBox(width: Spacing.sm),
                Text(
                  'Загалом XP з досягнень: $_totalXpFromAchievements',
                  style: AppTypography.monoSmall.copyWith(
                    color: isDark ? AppColorsPS5.xp : AppColorsMonitor.xp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: Spacing.base),

          // ─── Фільтри ──────────────────────────────────────────
          SizedBox(
            height: 48,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: Spacing.base),
              itemCount: _filters.length,
              separatorBuilder: (_, __) =>
                  const SizedBox(width: Spacing.sm),
              itemBuilder: (context, i) {
                final isActive = _filters[i] == _selectedFilter;
                return ChoiceChip(
                  label: Text(_filters[i]),
                  selected: isActive,
                  onSelected: (_) {
                    setState(() => _selectedFilter = _filters[i]);
                    _listController.reset();
                    _listController.forward();
                  },
                  labelStyle: AppTypography.labelMedium.copyWith(
                    color: isActive
                        ? Colors.white
                        : (isDark
                            ? AppColorsPS5.textSecondary
                            : AppColorsMonitor.textSecondary),
                  ),
                  selectedColor:
                      isDark ? AppColorsPS5.accent : AppColorsMonitor.accent,
                  backgroundColor:
                      isDark ? AppColorsPS5.card : AppColorsMonitor.card,
                  side: BorderSide(
                    color: isDark
                        ? AppColorsPS5.border
                        : AppColorsMonitor.border,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(Radii.xl),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: Spacing.sm),

          // ─── Підрахунок ───────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Spacing.base),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${_filtered.length} досягнень${_selectedFilter != 'Усе' ? ' — $_selectedFilter' : ''} за весь час',
                  style: AppTypography.bodySmall.copyWith(
                    color: isDark
                        ? AppColorsPS5.textSecondary
                        : AppColorsMonitor.textSecondary,
                  ),
                ),
                // Сортування
                GestureDetector(
                  onTap: () {
                    setState(() {
                      final idx = _sortOptions.indexOf(_sortBy);
                      _sortBy = _sortOptions[(idx + 1) % _sortOptions.length];
                    });
                  },
                  child: Row(
                    children: [
                      Icon(Icons.sort_rounded, size: 14,
                        color: isDark ? AppColorsPS5.textHint : AppColorsMonitor.textHint),
                      const SizedBox(width: 4),
                      Text(
                        _sortBy,
                        style: AppTypography.labelSmall.copyWith(
                          color: isDark ? AppColorsPS5.textHint : AppColorsMonitor.textHint,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: Spacing.md),

          // ─── Розподіл за рідкістю ────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Spacing.base),
            child: Container(
              padding: const EdgeInsets.all(Spacing.sm),
              decoration: BoxDecoration(
                color: isDark ? AppColorsPS5.card : AppColorsMonitor.card,
                borderRadius: BorderRadius.circular(Radii.md),
                border: Border.all(
                  color: isDark ? AppColorsPS5.border : AppColorsMonitor.border,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _rarityBadge('Звичайне', AppColorsPS5.success, isDark),
                  _rarityBadge('Рідкісне', AppColorsPS5.accent, isDark),
                  _rarityBadge('Епічне', AppColorsPS5.warning, isDark),
                  _rarityBadge('Легенд.', AppColorsPS5.error, isDark),
                ],
              ),
            ),
          ),

          const SizedBox(height: Spacing.md),

          // ─── Timeline або пустий стан ────────────────────────
          Expanded(
            child: _filtered.isEmpty
                ? const AppEmptyState(
                    icon: Icons.emoji_events_outlined,
                    title: 'Немає досягнень у цій категорії',
                    subtitle: 'Виконуй завдання і тут з\'являться твої досягнення!',
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(
                        horizontal: Spacing.base),
                    itemCount: _filtered.length,
                    itemBuilder: (context, index) {
                      final item = _filtered[index];
                      final isLast = index == _filtered.length - 1;
                      return _AchievementTile(
                        item: item,
                        isLast: isLast,
                        isDark: isDark,
                      )
                          .animate()
                          .fade(
                              delay: (120 * index).ms,
                              duration: 400.ms)
                          .slideY(
                              begin: 0.15,
                              end: 0,
                              delay: (120 * index).ms,
                              duration: 400.ms);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _rarityBadge(String label, Color color, bool isDark) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: AppTypography.caption.copyWith(
            color: isDark ? AppColorsPS5.textHint : AppColorsMonitor.textHint,
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  Widget _miniStatCard(String value, String label, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(
        color: isDark ? AppColorsPS5.card : AppColorsMonitor.card,
        borderRadius: BorderRadius.circular(Radii.md),
        border: Border.all(
          color: isDark ? AppColorsPS5.border : AppColorsMonitor.border,
        ),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: AppTypography.monoSmall.copyWith(
              color: isDark
                  ? AppColorsPS5.accent
                  : AppColorsMonitor.accent,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            label,
            style: AppTypography.caption.copyWith(
              color: isDark
                  ? AppColorsPS5.textHint
                  : AppColorsMonitor.textHint,
            ),
          ),
        ],
      ),
    );
  }
}

class _AchievementTile extends StatelessWidget {
  const _AchievementTile({
    required this.item,
    required this.isLast,
    required this.isDark,
  });

  final _AchievementItem item;
  final bool isLast;
  final bool isDark;

  Color _rarityColor(String rarity) {
    switch (rarity) {
      case 'Рідкісне':
        return AppColorsPS5.accent;
      case 'Епічне':
        return AppColorsPS5.warning;
      case 'Легендарне':
        return AppColorsPS5.error;
      default:
        return AppColorsPS5.success;
    }
  }

  @override
  Widget build(BuildContext context) {
    final accentColor =
        isDark ? AppColorsPS5.accent : AppColorsMonitor.accent;
    final textColor =
        isDark ? AppColorsPS5.textPrimary : AppColorsMonitor.textPrimary;
    final subColor =
        isDark ? AppColorsPS5.textSecondary : AppColorsMonitor.textSecondary;
    final lineColor =
        isDark ? AppColorsPS5.border : AppColorsMonitor.border;
    final rarityColor = _rarityColor(item.rarity);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline line + dot
          SizedBox(
            width: 40,
            child: Column(
              children: [
                Container(
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    color: item.isMilestone
                        ? accentColor
                        : accentColor.withOpacity(0.3),
                    shape: BoxShape.circle,
                    border: item.isMilestone
                        ? null
                        : Border.all(color: accentColor, width: 2),
                    boxShadow: item.isMilestone
                        ? [
                            BoxShadow(
                              color: accentColor.withOpacity(0.3),
                              blurRadius: 6,
                            ),
                          ]
                        : null,
                  ),
                  child: item.isMilestone
                      ? Icon(Icons.star_rounded,
                          size: 10, color: Colors.white)
                      : null,
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: lineColor,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: Spacing.md),

          // Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: Spacing.xl),
              child: Container(
                padding: const EdgeInsets.all(Spacing.base),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColorsPS5.card
                      : AppColorsMonitor.card,
                  borderRadius: BorderRadius.circular(Radii.lg),
                  border: item.isMilestone
                      ? Border.all(
                          color: accentColor.withOpacity(0.4),
                          width: 1.5,
                        )
                      : null,
                  boxShadow: item.isMilestone
                      ? [
                          BoxShadow(
                            color: accentColor.withOpacity(0.08),
                            blurRadius: 12,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: accentColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(Radii.md),
                      ),
                      child:
                          Icon(item.icon, color: accentColor, size: 22),
                    ),
                    const SizedBox(width: Spacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(item.title,
                                    style: AppTypography.heading3.copyWith(
                                        color: textColor)),
                              ),
                              // Рідкість
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: rarityColor.withOpacity(0.12),
                                  borderRadius:
                                      BorderRadius.circular(Radii.sm),
                                ),
                                child: Text(
                                  item.rarity,
                                  style: AppTypography.caption.copyWith(
                                    color: rarityColor,
                                    fontSize: 9,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          if (item.date.isNotEmpty)
                            Text(item.date,
                                style: AppTypography.bodySmall.copyWith(
                                    color: subColor)),
                          const SizedBox(height: Spacing.xs),
                          Text(item.detail,
                              style: AppTypography.bodySmall.copyWith(
                                  color: subColor)),
                          const SizedBox(height: Spacing.sm),
                          // Прогрес бар для незавершених
                          if (item.progress < 100) ...[
                            Row(
                              children: [
                                Expanded(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(4),
                                    child: LinearProgressIndicator(
                                      value: item.progress / 100,
                                      minHeight: 6,
                                      backgroundColor: isDark
                                          ? AppColorsPS5.border
                                          : AppColorsMonitor.border,
                                      valueColor: AlwaysStoppedAnimation(accentColor),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: Spacing.sm),
                                Text(
                                  '${item.progress}%',
                                  style: AppTypography.monoCaption.copyWith(
                                    color: accentColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ] else ...[
                            Row(
                              children: [
                                Icon(Icons.star_rounded, color: isDark ? AppColorsPS5.xp : AppColorsMonitor.xp, size: 14),
                                const SizedBox(width: 4),
                                Text(
                                  '+${item.xpReward} XP',
                                  style: AppTypography.monoCaption.copyWith(
                                    color: isDark ? AppColorsPS5.xp : AppColorsMonitor.xp,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                    // Кнопка поділитися
                    IconButton(
                      icon: Icon(Icons.share_rounded,
                        size: 16,
                        color: isDark ? AppColorsPS5.textHint : AppColorsMonitor.textHint),
                      onPressed: () {},
                      tooltip: 'Поділитися',
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AchievementItem {
  final IconData icon;
  final String title;
  final String date;
  final String detail;
  final String category;
  final bool isMilestone;
  final int progress;
  final String rarity;
  final int xpReward;

  const _AchievementItem({
    required this.icon,
    required this.title,
    required this.date,
    required this.detail,
    required this.category,
    required this.isMilestone,
    required this.progress,
    required this.rarity,
    required this.xpReward,
  });
}

class _CalendarMonth {
  final String month;
  final int count;

  const _CalendarMonth(this.month, this.count);
}
