import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_radii.dart';
import '../../../../core/constants/app_enums.dart';
import '../../../../core/extensions/number_format_ext.dart';
import '../../../../core/widgets/app_button_primary.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_coin_badge.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/widgets/app_fab.dart';
import '../../../../core/widgets/app_money_display.dart';
import '../../../../core/widgets/app_particle_bg.dart';
import '../../../../core/widgets/app_progress_bar.dart';
import '../../../../core/widgets/app_skeleton.dart';
import '../../../../core/widgets/app_streak_fire.dart';
import '../../../../core/widgets/app_xp_badge.dart';
import '../../../../core/widgets/app_bottom_nav.dart';
import '../../../../core/widgets/transaction_tile.dart';
import '../../../../core/extensions/datetime_ext.dart';
import '../../../../core/utils/haptic_service.dart';
import '../../../dashboard/providers/dashboard_provider.dart';
import '../quick_add_sheet.dart';

/// Головний екран дашборду — центральний hub користувача.
///
/// Містить: привітання, XP/монети, картку цілі з частинками,
/// швидкі дії, підцілі, останні транзакції, заморожений оверлей,
/// оверлей «майже там», скелетон завантаження, стан без цілі,
/// pull-to-refresh, scroll-анімації, дзвіночок з лічильником,
/// туторіал-оверлей, переміщення віджетів, теми дашборду,
/// секцію порад дня, секцію активності друзів, настроюваний header.
class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen>
    with TickerProviderStateMixin {
  int _currentNavIndex = 0;
  bool _isRefreshing = false;
  int _notificationCount = 3;
  bool _showTutorialOverlay = false;
  int _tutorialStep = 0;
  String _dashboardTheme = 'standard';
  bool _showWeeklySummary = false;
  bool _showQuickStats = false;
  bool _showTipOfDay = false;
  bool _showFriendActivity = false;
  late AnimationController _refreshController;
  late AnimationController _fabController;
  late ScrollController _scrollController;
  double _scrollOffset = 0.0;
  bool _showCollapsedHeader = false;

  /// Доступні теми дашборду.
  static const _dashboardThemes = ['standard', 'compact', 'minimal'];

  /// Поради дня для мотивування користувача.
  static const _dailyTips = [
    '💡 Спробуй відкладати хоча б 50 грн щодня — за рік накопичиш 18 000 грн!',
    '💡 Встанови дедлайн для своєї цілі — це мотивує на 30% більше!',
    '💡 Включи сповіщення, щоб не забувати про регулярні внески.',
    '💡 Виклики — найшвидший шлях до досягнення фінансових цілей!',
    '💡 Поділися своїм прогресом з друзями для додаткової мотивації!',
    '💡 Кожен внесок наближає тебе до мрії — не зупиняйся!',
    '💡 Спробуй правило «заплати спочатку собі» — 10% від доходу.',
  ];

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(dashboardProvider.notifier).loadData());
    _refreshController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000));
    _fabController = AnimationController(vsync: this, duration: const Duration(milliseconds: 600))..repeat(reverse: true);
    _scrollController = ScrollController()..addListener(_onScroll);
  }

  @override
  void dispose() {
    _refreshController.dispose();
    _fabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  /// Обробник прокрутки для анімацій.
  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final offset = _scrollController.offset;
    final shouldCollapse = offset > 60;

    if (shouldCollapse != _showCollapsedHeader) {
      setState(() {
        _showCollapsedHeader = shouldCollapse;
        _scrollOffset = offset;
      });
    }
  }

  /// Pull-to-refresh обробник.
  Future<void> _onRefresh() async {
    setState(() => _isRefreshing = true);
    HapticService.lightTap();
    _refreshController.forward(from: 0);
    await Future.delayed(const Duration(milliseconds: 800));
    if (mounted) {
      ref.read(dashboardProvider.notifier).loadData();
      setState(() => _isRefreshing = false);
    }
  }

  void _showQuickAdd() {
    HapticService.mediumTap();
    showModalBottomSheet(context: context, isScrollControlled: true, backgroundColor: Colors.transparent, builder: (_) => const QuickAddSheet());
  }

  /// Перемкнути туторіал-оверлей.
  void _toggleTutorial() {
    HapticService.selection();
    setState(() => _showTutorialOverlay = !_showTutorialOverlay);
  }

  /// Перемкнути тему дашборду.
  void _cycleDashboardTheme() {
    HapticService.selection();
    setState(() {
      final idx = _dashboardThemes.indexOf(_dashboardTheme);
      _dashboardTheme = _dashboardThemes[(idx + 1) % _dashboardThemes.length];
    });
    final themeNames = {
      'standard': 'Стандартна',
      'compact': 'Компактна',
      'minimal': 'Мінімалістична',
    };
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Тема: ${themeNames[_dashboardTheme] ?? _dashboardTheme}',
          style: AppTypography.labelMedium.copyWith(color: AppColorsPS5.textPrimary)),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(milliseconds: 1500),
      ),
    );
  }

  /// Зменшити лічильник сповіщень.
  void _clearNotifications() {
    HapticService.lightTap();
    setState(() => _notificationCount = 0);
  }

  void _toggleWeeklySummary() {
    HapticService.selection();
    setState(() => _showWeeklySummary = !_showWeeklySummary);
  }

  void _toggleQuickStats() {
    HapticService.selection();
    setState(() => _showQuickStats = !_showQuickStats);
  }

  void _toggleTipOfDay() {
    HapticService.selection();
    setState(() => _showTipOfDay = !_showTipOfDay);
  }

  void _toggleFriendActivity() {
    HapticService.selection();
    setState(() => _showFriendActivity = !_showFriendActivity);
  }

  void _showNotificationsPanel() {
    HapticService.lightTap();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: const EdgeInsets.all(Spacing.base),
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark ? AppColorsPS5.card : AppColorsMonitor.card,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(Radii.xl)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColorsPS5.textHint.withOpacity(0.3), borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: Spacing.lg),
            Text('Сповіщення', style: AppTypography.heading2.copyWith(color: AppColorsPS5.textPrimary)),
            const SizedBox(height: Spacing.md),
            _notificationItem('🏆 Нове досягнення!', 'Ви виконали «5 днів поспіль»', Icons.emoji_events_rounded, AppColorsPS5.xp),
            _notificationItem('⚡ Виклик оновлено', 'Щотижневий виклик «Заощадь 500»', Icons.bolt_rounded, AppColorsPS5.coin),
            _notificationItem('📊 Тижневий звіт', 'Ви зекономили 1 250 грн цього тижня', Icons.bar_chart_rounded, AppColorsPS5.accent),
            const SizedBox(height: Spacing.xl),
          ],
        ),
      ),
    );
  }

  Widget _notificationItem(String title, String body, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: Spacing.md),
      child: Row(
        children: [
          Container(width: 40, height: 40, decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(Radii.base)), child: Icon(icon, color: color, size: 20)),
          const SizedBox(width: Spacing.md),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: AppTypography.labelLarge.copyWith(color: AppColorsPS5.textPrimary)),
            const SizedBox(height: 2),
            Text(body, style: AppTypography.caption.copyWith(color: AppColorsPS5.textSecondary)),
          ])),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(dashboardProvider);
    final isLight = Theme.of(context).brightness == Brightness.light;
    final isFrozen = state.mood == DashboardMood.frozen || state.mood == DashboardMood.unfreezing;
    final isAlmost = state.mood == DashboardMood.almostThere;

    return Scaffold(
      backgroundColor: isLight ? AppColorsMonitor.background : AppColorsPS5.background,
      body: state.isLoading
          ? _buildLoadingSkeleton(isLight)
          : state.goal == null
              ? _buildNoGoalState(isLight)
              : Stack(
                  children: [
                    _buildContent(state, isLight, isAlmost),
                    if (isFrozen) _buildFrozenOverlay(state, isLight),
                    if (isAlmost) _buildAlmostThereOverlay(state, isLight),
                    if (_showTutorialOverlay) _buildTutorialOverlay(isLight),
                  ],
                ),
      floatingActionButton: state.goal != null && !state.isLoading
          ? AnimatedBuilder(
              animation: _fabController,
              builder: (context, child) {
                final scale = 1.0 + _fabController.value * 0.05;
                return Transform.scale(scale: scale, child: child);
              },
              child: AppFab(onPressed: _showQuickAdd, isLightTheme: isLight),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: AppBottomNav(currentIndex: _currentNavIndex, onTabChanged: (index) { HapticService.selection(); setState(() => _currentNavIndex = index); }, isLightTheme: isLight),
    );
  }

  // ── Скелетон завантаження ────────────────────────────────────
  Widget _buildLoadingSkeleton(bool isLight) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(Spacing.base),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: Spacing.base),
            Row(
              children: [
                AppSkeleton(width: 180, height: 24, isLightTheme: isLight),
                const Spacer(),
                AppSkeleton(width: 40, height: 40, isLightTheme: isLight, borderRadius: Radii.base),
              ],
            ),
            const SizedBox(height: Spacing.xl),
            AppSkeleton(width: double.infinity, height: 200, borderRadius: Radii.lg, isLightTheme: isLight),
            const SizedBox(height: Spacing.lg),
            AppSkeleton(width: double.infinity, height: 60, borderRadius: Radii.base, isLightTheme: isLight),
            const SizedBox(height: Spacing.lg),
            AppSkeleton(width: double.infinity, height: 80, borderRadius: Radii.md, isLightTheme: isLight),
            AppSkeleton(width: double.infinity, height: 80, borderRadius: Radii.md, isLightTheme: isLight),
            const SizedBox(height: Spacing.lg),
            Text('  Завантаження...', style: AppTypography.labelSmall.copyWith(color: isLight ? AppColorsMonitor.textHint : AppColorsPS5.textHint)),
          ],
        ),
      ),
    );
  }

  // ── Стан без цілі ──────────────────────────────────────────
  Widget _buildNoGoalState(bool isLight) {
    return SafeArea(child: AppEmptyState(
      icon: Icons.savings_rounded,
      title: 'Ще немає цілі',
      subtitle: 'Створи свою першу ціль накопичення та почни мріяти!',
      actionLabel: 'Почати',
      onAction: () { HapticService.mediumTap(); },
      isLightTheme: isLight,
    ));
  }

  // ── Основний контент ────────────────────────────────────────
  Widget _buildContent(DashboardState state, bool isLight, bool isAlmost) {
    final goal = state.goal!;
    final user = state.user;

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: _onRefresh,
        color: isLight ? AppColorsMonitor.accent : AppColorsPS5.accent,
        child: CustomScrollView(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            // ── Верхня панель (з анімацією при скролі) ─────────
            SliverToBoxAdapter(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: EdgeInsets.fromLTRB(
                  Spacing.base,
                  _showCollapsedHeader ? Spacing.sm : Spacing.base,
                  Spacing.base,
                  Spacing.sm,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AnimatedDefaultTextStyle(
                            duration: const Duration(milliseconds: 200),
                            style: (_showCollapsedHeader ? AppTypography.heading3 : AppTypography.heading1).copyWith(
                              color: isLight ? AppColorsMonitor.textPrimary : AppColorsPS5.textPrimary,
                            ),
                            child: Text('Привіт, ${user?.name ?? 'Користувач'}!'),
                          ),
                          if (!_showCollapsedHeader) ...[
                            const SizedBox(height: 2),
                            Text(_getGreeting(), style: AppTypography.bodySmall.copyWith(color: isLight ? AppColorsMonitor.textSecondary : AppColorsPS5.textSecondary)),
                          ],
                        ],
                      ),
                    ),
                    // ── Дзвіночок сповіщень ──────────────────────
                    GestureDetector(
                      onTap: _notificationCount > 0 ? _showNotificationsPanel : _clearNotifications,
                      child: Container(
                        width: 40, height: 40,
                        decoration: BoxDecoration(color: (isLight ? AppColorsMonitor.card : AppColorsPS5.card), borderRadius: BorderRadius.circular(Radii.base)),
                        child: Stack(alignment: Alignment.center, children: [
                          Icon(Icons.notifications_outlined, color: isLight ? AppColorsMonitor.textSecondary : AppColorsPS5.textSecondary, size: 20),
                          if (_notificationCount > 0) Positioned(top: 4, right: 4, child: Container(width: 16, height: 16, decoration: BoxDecoration(color: AppColorsPS5.error, shape: BoxShape.circle, border: Border.all(color: isLight ? AppColorsMonitor.card : AppColorsPS5.card, width: 2)), child: Center(child: Text('$_notificationCount', style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w700)))).animate().scale(duration: 300.ms, curve: Curves.easeOutBack)),
                        ]),
                      ),
                    ),
                    const SizedBox(width: Spacing.sm),
                    if (user != null) ...[
                      AppXpBadge(xp: user.xp, isLightTheme: isLight),
                      const SizedBox(width: Spacing.sm),
                      AppCoinBadge(coins: user.coins, isLightTheme: isLight),
                    ],
                  ],
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: Spacing.md)),

            // ── Швидка статистика ──────────────────────────
            SliverToBoxAdapter(child: _buildQuickStatsToggle(isLight)),

            // ── Картка цілі ────────────────────────────────────
            SliverToBoxAdapter(
              child: AppCard(
                isLightTheme: isLight,
                padding: EdgeInsets.zero,
                onTap: () { HapticService.lightTap(); },
                child: Column(
                  children: [
                    SizedBox(height: 160, child: ParticleSilhouette(goalType: goal.type, progress: goal.progress, isLightTheme: isLight)),
                    Padding(
                      padding: const EdgeInsets.all(Spacing.base),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(children: [Expanded(child: Text(goal.name, style: AppTypography.heading2.copyWith(color: isLight ? AppColorsMonitor.textPrimary : AppColorsPS5.textPrimary), overflow: TextOverflow.ellipsis)), if (goal.streakDays > 0) AppStreakFire(streakDays: goal.streakDays, isLightTheme: isLight)]),
                          const SizedBox(height: Spacing.sm),
                          Row(crossAxisAlignment: CrossAxisAlignment.end, children: [Expanded(child: AppMoneyDisplay(amount: goal.currentAmount, isLightTheme: isLight, style: AppTypography.monoLarge.copyWith(color: isLight ? AppColorsMonitor.textPrimary : AppColorsPS5.textPrimary))), Text('/ ${goal.targetAmount.toInt().formatUAH()} грн', style: AppTypography.labelMedium.copyWith(color: isLight ? AppColorsMonitor.textSecondary : AppColorsPS5.textSecondary))]),
                          const SizedBox(height: Spacing.base),
                          AppProgressBar(progress: goal.progress, isLightTheme: isLight, isPulsing: isAlmost),
                          const SizedBox(height: Spacing.sm),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Залишилось ${goal.remaining.toInt().formatUAH()} грн', style: AppTypography.labelMedium.copyWith(color: isLight ? AppColorsMonitor.textSecondary : AppColorsPS5.textSecondary)),
                              Text(
                                '${ref.watch(userRepositoryProvider).getUser().calculateWorkHours(goal.remaining).toStringAsFixed(1)} год роботи',
                                style: AppTypography.caption.copyWith(color: isLight ? AppColorsMonitor.textHint : AppColorsPS5.textHint),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 500.ms),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: Spacing.lg)),

            // ── Швидкі дії ──────────────────────────────────
            SliverToBoxAdapter(child: _QuickActions(isLight: isLight, onAdd: _showQuickAdd, onTutorial: _toggleTutorial, onTheme: _cycleDashboardTheme).animate().fadeIn(duration: 500.ms, delay: 100.ms)),
            const SliverToBoxAdapter(child: SizedBox(height: Spacing.lg)),

            // ── Мотиваційна картка дня ───────────────────────
            SliverToBoxAdapter(child: _buildMotivationCard(isLight)),
            const SliverToBoxAdapter(child: SizedBox(height: Spacing.lg)),

            // ── Порада дня ─────────────────────────────────
            SliverToBoxAdapter(child: _buildTipOfDayToggle(isLight)),
            const SliverToBoxAdapter(child: SizedBox(height: Spacing.lg)),

            // ── Тижневий звіт ─────────────────────────────
            SliverToBoxAdapter(child: _buildWeeklySummaryToggle(isLight)),
            const SliverToBoxAdapter(child: SizedBox(height: Spacing.lg)),

            // ── Активність друзів ─────────────────────────
            SliverToBoxAdapter(child: _buildFriendActivityToggle(isLight)),
            const SliverToBoxAdapter(child: SizedBox(height: Spacing.lg)),

            // ── Підцілі ────────────────────────────────────
            if (goal.subGoals.isNotEmpty) SliverToBoxAdapter(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Padding(padding: const EdgeInsets.symmetric(horizontal: Spacing.base), child: Text('Підцілі', style: AppTypography.heading3.copyWith(color: isLight ? AppColorsMonitor.textPrimary : AppColorsPS5.textPrimary))),
              const SizedBox(height: Spacing.sm),
              SizedBox(height: 100, child: ListView.separated(scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: Spacing.base), itemCount: goal.subGoals.length, separatorBuilder: (_, __) => const SizedBox(width: Spacing.sm), itemBuilder: (context, index) {
                final sg = goal.subGoals[index];
                return AppCard(isLightTheme: isLight, padding: const EdgeInsets.all(Spacing.base), child: SizedBox(width: 140, child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(sg.name, style: AppTypography.labelLarge.copyWith(color: isLight ? AppColorsMonitor.textPrimary : AppColorsPS5.textPrimary), overflow: TextOverflow.ellipsis, maxLines: 1), AppProgressBar(progress: sg.progress, isLightTheme: isLight), Text('${sg.remaining.toInt().formatUAH()} грн', style: AppTypography.labelSmall.copyWith(color: isLight ? AppColorsMonitor.textSecondary : AppColorsPS5.textSecondary))]));
              })),
            ]).animate().fadeIn(duration: 500.ms, delay: 200.ms)),
            const SliverToBoxAdapter(child: SizedBox(height: Spacing.lg)),

            // ── Останні транзакції ────────────────────────
            SliverToBoxAdapter(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Padding(padding: const EdgeInsets.symmetric(horizontal: Spacing.base), child: Text('Останні внески', style: AppTypography.heading3.copyWith(color: isLight ? AppColorsMonitor.textPrimary : AppColorsPS5.textPrimary))),
              if (state.recentTransactions.isEmpty) Padding(padding: const EdgeInsets.all(Spacing.base), child: Text('Ще немає транзакцій. Натисни «+» щоб почати!', style: AppTypography.bodyMedium.copyWith(color: isLight ? AppColorsMonitor.textHint : AppColorsPS5.textHint)))
              else Padding(padding: const EdgeInsets.symmetric(horizontal: Spacing.base), child: Column(children: state.recentTransactions.map((tx) => Padding(padding: const EdgeInsets.only(bottom: Spacing.sm), child: TransactionTile(type: tx.type, amount: tx.amount, date: tx.createdAt, comment: tx.comment, xp: tx.xpEarned, isLightTheme: isLight))).toList())),
            ]).animate().fadeIn(duration: 500.ms, delay: 300.ms)),
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }

  // ── Швидка статистика ────────────────────────────────────
  Widget _buildQuickStatsToggle(bool isLight) {
    return GestureDetector(
      onTap: _toggleQuickStats,
      child: AnimatedSize(
        duration: const Duration(milliseconds: 300),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: Spacing.base),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(children: [
                    Icon(Icons.insights_rounded, color: isLight ? AppColorsMonitor.accent : AppColorsPS5.accent, size: 16),
                    const SizedBox(width: Spacing.xs),
                    Text('Швидка статистика', style: AppTypography.labelMedium.copyWith(color: isLight ? AppColorsMonitor.accent : AppColorsPS5.accent)),
                  ]),
                  Icon(_showQuickStats ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded, color: isLight ? AppColorsMonitor.accent : AppColorsPS5.accent, size: 18),
                ],
              ),
              if (_showQuickStats)
                Container(
                  margin: const EdgeInsets.only(top: Spacing.sm),
                  padding: const EdgeInsets.all(Spacing.base),
                  decoration: BoxDecoration(
                    color: (isLight ? AppColorsMonitor.accent : AppColorsPS5.accent).withOpacity(0.06),
                    borderRadius: BorderRadius.circular(Radii.md),
                    border: Border.all(color: (isLight ? AppColorsMonitor.accent : AppColorsPS5.accent).withOpacity(0.12)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _quickStatItem('Сьогодні', '+150 грн', isLight),
                      _quickStatItem('Тиждень', '+850 грн', isLight),
                      _quickStatItem('Серія', '5 днів', isLight),
                      _quickStatItem('Цілей', '2 активні', isLight),
                    ],
                  ),
                ).animate().fade(duration: 300.ms),
            ],
          ),
        ),
      ),
    );
  }

  Widget _quickStatItem(String label, String value, bool isLight) {
    return Column(
      children: [
        Text(value, style: AppTypography.monoSmall.copyWith(color: isLight ? AppColorsMonitor.accent : AppColorsPS5.accent, fontWeight: FontWeight.w700)),
        Text(label, style: AppTypography.caption.copyWith(color: isLight ? AppColorsMonitor.textSecondary : AppColorsPS5.textSecondary)),
      ],
    );
  }

  /// Мотиваційна картка дня з цитатою.
  Widget _buildMotivationCard(bool isLight) {
    final quotes = [
      '💪 Кожен день наближає тебе до цілі!',
      '🔥 Не здавайся — ти на правильному шляху!',
      '✨ Маленькі кроки — великий результат!',
      '🎯 Фокусуйся на меті — ти впораєшся!',
      '💎 Ти вже на 40% шляху — продовжуй!',
    ];
    final quote = quotes[DateTime.now().hour % quotes.length];
    final accentColor = isLight ? AppColorsMonitor.accent : AppColorsPS5.accent;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Spacing.base),
      child: Container(
        padding: const EdgeInsets.all(Spacing.base),
        decoration: BoxDecoration(color: accentColor.withOpacity(0.06), borderRadius: BorderRadius.circular(Radii.lg), border: Border.all(color: accentColor.withOpacity(0.1))),
        child: Row(children: [Icon(Icons.format_quote_rounded, color: accentColor, size: 20), const SizedBox(width: Spacing.sm), Expanded(child: Text(quote, style: AppTypography.labelMedium.copyWith(color: isLight ? AppColorsMonitor.textPrimary : AppColorsPS5.textPrimary)))]),
      ),
    ).animate().fadeIn(duration: 500.ms, delay: 150.ms).slideY(begin: 0.1, end: 0, duration: 500.ms, delay: 150.ms);
  }

  // ── Порада дня ──────────────────────────────────────────
  Widget _buildTipOfDayToggle(bool isLight) {
    final tip = _dailyTips[DateTime.now().day % _dailyTips.length];
    return GestureDetector(
      onTap: _toggleTipOfDay,
      child: AnimatedSize(
        duration: const Duration(milliseconds: 300),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: Spacing.base),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(children: [
                    Icon(Icons.lightbulb_outline_rounded, color: isLight ? AppColorsPS5.coin : AppColorsPS5.coin, size: 16),
                    const SizedBox(width: Spacing.xs),
                    Text('Порада дня', style: AppTypography.labelMedium.copyWith(color: isLight ? AppColorsPS5.coin : AppColorsPS5.coin)),
                  ]),
                  Icon(_showTipOfDay ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded, color: isLight ? AppColorsPS5.coin : AppColorsPS5.coin, size: 18),
                ],
              ),
              if (_showTipOfDay)
                Container(
                  margin: const EdgeInsets.only(top: Spacing.sm),
                  padding: const EdgeInsets.all(Spacing.base),
                  decoration: BoxDecoration(color: AppColorsPS5.coin.withOpacity(0.06), borderRadius: BorderRadius.circular(Radii.md), border: Border.all(color: AppColorsPS5.coin.withOpacity(0.12))),
                  child: Text(tip, style: AppTypography.labelSmall.copyWith(color: isLight ? AppColorsMonitor.textPrimary : AppColorsPS5.textPrimary, height: 1.5)),
                ).animate().fade(duration: 300.ms),
            ],
          ),
        ),
      ),
    );
  }

  // ── Активність друзів ────────────────────────────────────
  Widget _buildFriendActivityToggle(bool isLight) {
    return GestureDetector(
      onTap: _toggleFriendActivity,
      child: AnimatedSize(
        duration: const Duration(milliseconds: 300),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: Spacing.base),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(children: [
                    Icon(Icons.people_outline_rounded, color: isLight ? AppColorsMonitor.accent : AppColorsPS5.accent, size: 16),
                    const SizedBox(width: Spacing.xs),
                    Text('Активність друзів', style: AppTypography.labelMedium.copyWith(color: isLight ? AppColorsMonitor.accent : AppColorsPS5.accent)),
                  ]),
                  Icon(_showFriendActivity ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded, color: isLight ? AppColorsMonitor.accent : AppColorsPS5.accent, size: 18),
                ],
              ),
              if (_showFriendActivity)
                Container(
                  margin: const EdgeInsets.only(top: Spacing.sm),
                  padding: const EdgeInsets.all(Spacing.base),
                  decoration: BoxDecoration(color: (isLight ? AppColorsMonitor.card : AppColorsPS5.card), borderRadius: BorderRadius.circular(Radii.md), border: Border.all(color: isLight ? AppColorsMonitor.border : AppColorsPS5.border)),
                  child: Column(children: [
                    _friendActivityItem('Олена', 'Внесла 500 грн у «Подорож»', Icons.trending_up_rounded, AppColorsPS5.success),
                    _friendActivityItem('Максим', 'Досяг цілі «PS5» 🎉', Icons.emoji_events_rounded, AppColorsPS5.xp),
                    _friendActivityItem('Анна', 'Почала нову ціль «Монітор»', Icons.flag_rounded, AppColorsPS5.accent),
                  ]),
                ).animate().fade(duration: 300.ms),
            ],
          ),
        ),
      ),
    );
  }

  Widget _friendActivityItem(String name, String action, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: Spacing.md),
      child: Row(children: [
        Container(width: 32, height: 32, decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(Radii.circular)), child: Icon(icon, color: color, size: 16)),
        const SizedBox(width: Spacing.sm),
        Expanded(child: RichText(text: TextSpan(children: [
          TextSpan(text: name, style: AppTypography.labelMedium.copyWith(color: AppColorsPS5.textPrimary, fontWeight: FontWeight.w600)),
          TextSpan(text: ' $action', style: AppTypography.caption.copyWith(color: AppColorsPS5.textSecondary)),
        ]))),
      ]),
    );
  }

  // ── Тижневий звит ───────────────────────────────────────
  Widget _buildWeeklySummaryToggle(bool isLight) {
    return GestureDetector(
      onTap: _toggleWeeklySummary,
      child: AnimatedSize(
        duration: const Duration(milliseconds: 300),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: Spacing.base),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(children: [
                    Icon(Icons.bar_chart_rounded, color: isLight ? AppColorsMonitor.accent : AppColorsPS5.accent, size: 16),
                    const SizedBox(width: Spacing.xs),
                    Text('Цьотижневий звіт', style: AppTypography.labelMedium.copyWith(color: isLight ? AppColorsMonitor.accent : AppColorsPS5.accent)),
                  ]),
                  Icon(_showWeeklySummary ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded, color: isLight ? AppColorsMonitor.accent : AppColorsPS5.accent, size: 18),
                ],
              ),
              if (_showWeeklySummary)
                Container(
                  margin: const EdgeInsets.only(top: Spacing.sm),
                  padding: const EdgeInsets.all(Spacing.base),
                  decoration: BoxDecoration(color: (isLight ? AppColorsMonitor.card : AppColorsPS5.card), borderRadius: BorderRadius.circular(Radii.md), border: Border.all(color: isLight ? AppColorsMonitor.border : AppColorsPS5.border)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('📈 Ти впораєшся краще за 80% користувачів!', style: AppTypography.labelSmall.copyWith(color: isLight ? AppColorsMonitor.textPrimary : AppColorsPS5.textPrimary, fontWeight: FontWeight.w600)),
                      const SizedBox(height: Spacing.xs),
                      Text('Внесено 5 разів · Всього 1 250 грн · Серія 5 днів', style: AppTypography.caption.copyWith(color: isLight ? AppColorsMonitor.textSecondary : AppColorsPS5.textSecondary)),
                    ],
                  ),
                ).animate().fade(duration: 300.ms),
            ],
          ),
        ),
      ),
    );
  }

  // ── Туторіал-оверлей ──────────────────────────────────────
  Widget _buildTutorialOverlay(bool isLight) {
    final tutorials = [
      '👆 Натисни «+» щоб додати кошти',
      '📊 Тут бачиш свій прогрес',
      '🎮 Виклики та нагороди тут',
      '⚙️ Налаштування у меню',
      '💡 Порада дня допоможе заощадити більше',
      '👥 Порівняй свій прогрес з друзями',
    ];

    return Positioned.fill(
      child: Container(
        color: Colors.black.withOpacity(0.6),
        child: Center(
          child: Container(
            margin: const EdgeInsets.all(Spacing.xxl),
            padding: const EdgeInsets.all(Spacing.xl),
            decoration: BoxDecoration(color: isLight ? AppColorsMonitor.card : AppColorsPS5.card, borderRadius: BorderRadius.circular(Radii.xl), border: Border.all(color: isLight ? AppColorsMonitor.accent : AppColorsPS5.accent, width: 2)),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('🧭 Туторіал', style: AppTypography.heading2.copyWith(color: isLight ? AppColorsMonitor.textPrimary : AppColorsPS5.textPrimary)),
                const SizedBox(height: Spacing.base),
                Text(tutorials[_tutorialStep % tutorials.length], style: AppTypography.bodyLarge.copyWith(color: isLight ? AppColorsMonitor.textSecondary : AppColorsPS5.textSecondary), textAlign: TextAlign.center),
                const SizedBox(height: Spacing.sm),
                // Індикатор прогресу туторіалу
                Row(mainAxisAlignment: MainAxisAlignment.center, children: List.generate(tutorials.length, (i) => Container(width: 8, height: 8, margin: const EdgeInsets.symmetric(horizontal: 2), decoration: BoxDecoration(shape: BoxShape.circle, color: i <= _tutorialStep % tutorials.length ? (isLight ? AppColorsMonitor.accent : AppColorsPS5.accent) : (isLight ? AppColorsMonitor.border : AppColorsPS5.border)))),
                const SizedBox(height: Spacing.sm),
                Text('Крок ${_tutorialStep + 1} з ${tutorials.length}', style: AppTypography.labelSmall.copyWith(color: isLight ? AppColorsMonitor.textHint : AppColorsPS5.textHint)),
                const SizedBox(height: Spacing.xxl),
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  TextButton(onPressed: () { HapticService.selection(); setState(() => _tutorialStep++); }, child: Text('Далі', style: AppTypography.labelLarge.copyWith(color: isLight ? AppColorsMonitor.accent : AppColorsPS5.accent))),
                  const SizedBox(width: Spacing.base),
                  TextButton(onPressed: _toggleTutorial, child: Text('Закрити', style: AppTypography.labelLarge.copyWith(color: isLight ? AppColorsMonitor.textHint : AppColorsPS5.textHint))),
                ]),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Заморожений оверлей ────────────────────────────────────
  Widget _buildFrozenOverlay(DashboardState state, bool isLight) {
    return Positioned.fill(
      child: Container(
        color: (isLight ? AppColorsMonitor.accent : AppColorsPS5.accent).withOpacity(0.15),
        child: BackdropFilter(filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4), child: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.ac_unit_rounded, size: 48, color: isLight ? AppColorsMonitor.accent : AppColorsPS5.accent).animate(onPlay: (c) => c.repeat()).rotate(begin: 0, end: 0.1, duration: const Duration(milliseconds: 2000)),
          const SizedBox(height: Spacing.base),
          Text('Твій прогрес чекає на тебе', style: AppTypography.heading2.copyWith(color: isLight ? AppColorsMonitor.textPrimary : AppColorsPS5.textPrimary)),
          const SizedBox(height: Spacing.md),
          Text('Ти накопичив ${(state.goal?.currentAmount ?? 0).toInt().formatUAH()} грн — не гай це!', style: AppTypography.bodyMedium.copyWith(color: isLight ? AppColorsMonitor.textSecondary : AppColorsPS5.textSecondary), textAlign: TextAlign.center),
          const SizedBox(height: Spacing.sm),
          Text('Зроби внесок хоча б 50 грн щоб розморозити!', style: AppTypography.labelSmall.copyWith(color: isLight ? AppColorsMonitor.textHint : AppColorsPS5.textHint)),
          const SizedBox(height: Spacing.xl),
          AppButtonPrimary(label: 'Розпочати з 50 грн', onPressed: _showQuickAdd, showPulse: true, isLightTheme: isLight),
        ]))),
      ),
    );
  }

  // ── Оверлей «майже там» ────────────────────────────────────
  Widget _buildAlmostThereOverlay(DashboardState state, bool isLight) {
    final goal = state.goal!;
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [(isLight ? AppColorsMonitor.background : AppColorsPS5.background).withOpacity(0.9), (isLight ? AppColorsMonitor.accent : AppColorsPS5.accent).withOpacity(0.05)])),
        child: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
          SizedBox(height: 140, child: ParticleSilhouette(goalType: goal.type, progress: goal.progress, isLightTheme: isLight)),
          const SizedBox(height: Spacing.base),
          Text('Залишилось ${goal.remaining.toInt().formatUAH()} грн!', style: AppTypography.displaySmall.copyWith(color: isLight ? AppColorsMonitor.accent : AppColorsPS5.accent)).animate(onPlay: (c) => c.repeat(reverse: true)).scale(begin: const Offset(1.0, 1.0), end: const Offset(1.03, 1.03), duration: const Duration(milliseconds: 800)),
          const SizedBox(height: Spacing.md),
          AppProgressBar(progress: goal.progress, isLightTheme: isLight, isPulsing: true),
          const SizedBox(height: Spacing.lg),
          AppButtonPrimary(label: 'Фінішуємо!', onPressed: _showQuickAdd, showGlow: true, showPulse: true, icon: Icons.emoji_events_rounded, isLightTheme: isLight),
        ])),
      ).animate().fadeIn(duration: 500.ms),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 6) return 'На добраніч, чемпіоне 🌙';
    if (hour < 12) return 'Доброго ранку! ☀️';
    if (hour < 18) return 'Гарного дня! 💪';
    return 'Вечірній внесок? 🔥';
  }
}

/// Швидкі дії — рядок із 5 кнопок + кнопка теми/туторіалу.
class _QuickActions extends ConsumerWidget {
  const _QuickActions({required this.isLight, required this.onAdd, required this.onTutorial, required this.onTheme});
  final bool isLight;
  final VoidCallback onAdd;
  final VoidCallback onTutorial;
  final VoidCallback onTheme;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final actions = [
      _QuickAction(icon: Icons.add_circle_rounded, label: 'Додати', onTap: onAdd, delay: 0),
      _QuickAction(icon: Icons.bolt_rounded, label: 'Виклики', onTap: () {}, delay: 1),
      _QuickAction(icon: Icons.bar_chart_rounded, label: 'Статистика', onTap: () {}, delay: 2),
      _QuickAction(icon: Icons.park_rounded, label: 'Сад', onTap: () => context.push('/garden'), delay: 3),
      _QuickAction(icon: Icons.school_rounded, label: 'Навчання', onTap: onTutorial, delay: 4),
      _QuickAction(icon: Icons.palette_rounded, label: 'Тема', onTap: onTheme, delay: 5),
      _QuickAction(icon: Icons.people_rounded, label: 'Друзі', onTap: () {}, delay: 6),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Spacing.base),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: actions.map((a) => SizedBox(width: 64, child: _QuickActionWidget(action: a, isLight: isLight))).toList()),
      ),
    );
  }
}

class _QuickAction {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final int delay;
  const _QuickAction({required this.icon, required this.label, required this.onTap, required this.delay});
}

class _QuickActionWidget extends StatelessWidget {
  const _QuickActionWidget({required this.action, required this.isLight});
  final _QuickAction action;
  final bool isLight;

  @override
  Widget build(BuildContext context) {
    final accentColor = isLight ? AppColorsMonitor.accent : AppColorsPS5.accent;
    final textColor = isLight ? AppColorsMonitor.textSecondary : AppColorsPS5.textSecondary;

    return GestureDetector(
      onTap: action.onTap,
      child: Column(children: [
        Container(width: 52, height: 52, decoration: BoxDecoration(color: accentColor.withOpacity(0.1), borderRadius: BorderRadius.circular(Radii.base)), child: Icon(action.icon, color: accentColor, size: 24)),
        const SizedBox(height: Spacing.xs),
        Text(action.label, style: AppTypography.labelSmall.copyWith(color: textColor), textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis),
      ]),
    ).animate().fadeIn(duration: 400.ms, delay: (action.delay * 100).ms).slideY(begin: 0.2, end: 0, duration: 400.ms, delay: (action.delay * 100).ms);
  }
}
