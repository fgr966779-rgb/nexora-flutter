import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_radii.dart';
import '../../../../core/constants/app_durations.dart';
import '../../../../core/constants/app_enums.dart';
import '../../../../core/extensions/number_format_ext.dart';
import '../../../../core/extensions/build_context_ext.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/transaction_tile.dart';
import '../../../../core/utils/haptic_service.dart';
import '../../../../data/models/transaction_model.dart';
import '../../providers/dashboard_provider.dart';

/// Екран історії транзакцій із пошуком, фільтрами, пагінацією,
/// date separators, pull-to-refresh, swipe to delete з undo, empty state,
/// loading skeleton, grouping (by day/week/month), bulk actions,
/// експортом транзакцій та оптимізацією безкінцевого прокрутки.
class TransactionHistoryScreen extends StatefulWidget {
  const TransactionHistoryScreen({super.key});

  static const String route = '/transaction-history';

  @override
  State<TransactionHistoryScreen> createState() => _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  TransactionType? _filterType; // null = Усе
  final _scrollController = ScrollController();
  bool _isLoadingMore = false;
  bool _isRefreshing = false;
  bool _hasMore = true;

  /// Undo state
  Transaction? _deletedTransaction;
  bool _showUndo = false;
  int _undoSeconds = 5;
  int _undoTimerId = 0;

  /// Групування транзакцій (day/week/month).
  String _groupBy = 'day'; // day | week | month

  /// Чи показувати панель масових дій.
  bool _showBulkActions = false;

  /// Вибрані транзакції для масових дій.
  final Set<String> _selectedIds = {};

  /// Асинхронна валідація для діапазону суми.
  double? _minAmountFilter;
  double? _maxAmountFilter;
  bool _showAmountFilter = false;

  /// Асинхронна валідація для діапазону дат.
  DateTime? _dateFrom;
  DateTime? _dateTo;
  bool _showDateFilter = false;

  static const _filterLabels = ['Усе', 'Ручні', 'Авто', 'Виклики'];
  static const _filterTypes = [
    null,
    TransactionType.manual,
    TransactionType.autoPayment,
    TransactionType.challenge,
  ];

  static const _groupByLabels = ['День', 'Тиждень', 'Місяць'];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  /// Обробник скролу для безкінцевого завантаження.
  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 100) {
      if (!_isLoadingMore && _hasMore) {
        _loadMore();
      }
    }
  }

  /// Асинхронне завантаження додаткових транзакцій.
  Future<void> _loadMore() async {
    setState(() => _isLoadingMore = true);
    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) {
      setState(() {
        _isLoadingMore = false;
        _hasMore = false;
      });
    }
  }

  /// Обробник зміни пошукового запиту.
  void _onSearch(String query) {
    setState(() => _searchQuery = query.toLowerCase());
  }

  /// Обробник pull-to-refresh.
  Future<void> _onRefresh(DashboardProvider provider) async {
    setState(() => _isRefreshing = true);
    await provider.refreshTransactions();
    if (mounted) {
      setState(() => _isRefreshing = false);
    }
  }

  /// Фільтрує транзакції за типом та пошуком.
  List<Transaction> _filterTransactions(List<Transaction> all) {
    var filtered = all;
    if (_filterType != null) {
      filtered = filtered.where((t) => t.type == _filterType).toList();
    }
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((t) {
        final comment = (t.comment ?? '').toLowerCase();
        final amount = t.amount.toString();
        return comment.contains(_searchQuery) || amount.contains(_searchQuery);
      }).toList();
    }
    // Фільтр по діапазону суми.
    if (_minAmountFilter != null) {
      filtered = filtered.where((t) => t.amount >= _minAmountFilter!).toList();
    }
    if (_maxAmountFilter != null) {
      filtered = filtered.where((t) => t.amount <= _maxAmountFilter!).toList();
    }
    // Фільтр по діапазону дат.
    if (_dateFrom != null && _dateTo != null) {
      filtered = filtered.where((t) =>
        t.createdAt.isAfter(_dateFrom!) &&
        t.createdAt.isBefore(_dateTo!.add(const Duration(days: 1))),
      ).toList();
    }
    return filtered;
  }

  /// Групування транзакцій за обраний період.
  Map<String, List<Transaction>> _groupByPeriod(List<Transaction> transactions) {
    final grouped = <String, List<Transaction>>{};
    for (final t in transactions) {
      String key;
      switch (_groupBy) {
        case 'week':
          final weekStart = t.createdAt.subtract(
            Duration(days: t.createdAt.weekday - 1),
          );
          key = '${weekStart.day.toString().padLeft(2, '0')}.${weekStart.month.toString().padLeft(2, '0')} –';
          '${t.createdAt.day.toString().padLeft(2, '0')}.${t.createdAt.month.toString().padLeft(2, '0')}';
          break;
        case 'month':
          key = '${t.createdAt.month.toString().padLeft(2, '0')}.${t.createdAt.year}';
          break;
        default: // day
          key = _formatGroupDate(t.createdAt);
      }
      grouped.putIfAbsent(key, () => []).add(t);
    }
    return grouped;
  }

  /// Форматування дати для групування.
  String _formatGroupDate(DateTime date) {
    final now = DateTime.now();
    if (date.year == now.year &&
        date.month == now.month &&
        date.day == now.day) {
      return 'Сьогодні';
    }
    final yesterday = now.subtract(const Duration(days: 1));
    if (date.year == yesterday.year &&
        date.month == yesterday.month &&
        date.day == yesterday.day) {
      return 'Вчора';
    }
    final thisWeek = now.subtract(const Duration(days: 7));
    if (date.isAfter(thisWeek)) {
      return 'Цього тижня';
    }
    return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
  }

  /// Підрахунок суми за день.
  double _dayTotal(List<Transaction> items) {
    return items.fold<double>(0, (sum, t) => sum + t.amount);
  }

  /// XP за день.
  int _dayXP(List<Transaction> items) {
    return items.fold<int>(0, (sum, t) => sum + (t.xpEarned ?? 0));
  }

  /// Обробка скасування транзакції з undo-possible.
  void _showDeleteUndo(Transaction t) {
    HapticService.selection();
    setState(() {
      _deletedTransaction = t;
      _showUndo = true;
      _undoSeconds = 5;
    });

    _startUndoTimer();

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('${t.amount.toInt().formatUAH()} грн видалено'),
          action: SnackBarAction(
            label: 'Скасувати (${_undoSeconds}с)',
            onPressed: () {
              setState(() {
                _showUndo = false;
                _deletedTransaction = null;
              });
            },
          ),
          duration: const Duration(seconds: 5),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  /// Запуск таймера undo.
  void _startUndoTimer() {
    _undoTimerId++;
    final currentId = _undoTimerId;
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted || !_showUndo || currentId != _undoTimerId) return false;
      final remaining = --_undoSeconds;
      if (remaining <= 0) {
        setState(() {
          _showUndo = false;
          _deletedTransaction = null;
        });
        return false;
      }
      setState(() {});
      return true;
    });
  }

  /// Перемикачення групи транзакцій.
  void _onGroupByChanged(String groupBy) {
    HapticService.selection();
    setState(() => _groupBy = groupBy);
  }

  /// Показати/сховати масові дії.
  void _toggleBulkActions() {
    HapticService.selection();
    setState(() => _showBulkActions = !_showBulkActions);
  }

  /// Додати/прибрати ID з вибраних.
  void _toggleSelection(String id) {
    HapticService.lightTap();
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
      } else {
        _selectedIds.add(id);
      }
    });
  }

  /// Виділити всі транзакції.
  void _selectAll(List<Transaction> transactions) {
    HapticService.selection();
    setState(() {
      _selectedIds = transactions.map((t) => t.id).toSet();
    });
  }

  /// Скасувати вибір.
  void _clearSelection() {
    setState(() => _selectedIds.clear());
  }

  /// Видалити виділені транзакції.
  void _deleteSelected() {
    HapticService.mediumTap();
    setState(() {
      _showUndo = true;
      _undoSeconds = 5;
      _deletedTransaction = null;
      _selectedIds.clear();
    });
    _startUndoTimer();
    context.showAppToast(
      '${_selectedIds.length} транзакцій видалено',
      type: AppToastType.success,
    );
  }

  /// Показати діалог фільтрації суми.
  void _showAmountFilterDialog() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final c = isDark ? AppColorsPS5 : AppColorsMonitor;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: c.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Radii.xl),
        ),
        title: Text(
          'Фільтр по сумі',
          style: AppTypography.heading3.copyWith(color: c.textPrimary),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Вкажи мінімальну та максимальну суму:',
              style: AppTypography.bodyMedium.copyWith(color: c.textSecondary),
            ),
            const SizedBox(height: Spacing.base),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: TextEditingController(
                      text: _minAmountFilter?.toInt().toString() ?? '',
                    ),
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Мінімум',
                      labelStyle: AppTypography.labelMedium.copyWith(color: c.accent),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(Radii.md),
                      ),
                      onChanged: (v) {
                        _minAmountFilter = double.tryParse(v);
                      },
                    ),
                  ),
                ),
                const SizedBox(width: Spacing.md),
                Expanded(
                  child: TextField(
                    controller: TextEditingController(
                      text: _maxAmountFilter?.toInt().toString() ?? '',
                    ),
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Максимум',
                      labelStyle: AppTypography.labelMedium.copyWith(color: c.accent),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(Radii.md),
                      ),
                      onChanged: (v) {
                        _maxAmountFilter = double.tryParse(v);
                      },
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              setState(() {
                _showAmountFilter = true;
              });
            },
            child: Text('Застосувати',
              style: AppTypography.labelLarge.copyWith(color: c.accent),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Скасувати',
              style: AppTypography.labelLarge.copyWith(color: c.textSecondary),
            ),
        ],
      ),
    );
  }

  /// Показати діалог фільтрації дат.
  void _showDateFilterDialog() async {
    final now = DateTime.now();
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2024),
      lastDate: now,
      initialDateRange: _dateFrom != null && _dateTo != null
          ? DateTimeRange(start: _dateFrom!, end: _dateTo!)
          : DateTimeRange(
              start: now.subtract(const Duration(days: 30)),
              end: now,
            ),
    );
    if (range != null) {
      HapticService.selection();
      setState(() {
        _dateFrom = range.start;
        _dateTo = range.end;
        _showDateFilter = true;
      });
    }
  }

  /// Експорт транзакцій.
  Future<void> _exportTransactions() async {
    HapticService.mediumTap();
    setState(() => _isExporting = true);
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) {
      setState(() => _isExporting = false);
      context.showAppToast(
        'Транзакції експортовано!',
        type: AppToastType.success,
      );
    }
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
        title: Text(
          'Історія',
          style: AppTypography.heading1.copyWith(color: c.textPrimary),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: c.textSecondary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          if (_searchQuery.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear_rounded),
              onPressed: () {
                _searchController.clear();
                setState(() => _searchQuery = '');
              },
            ),
          PopupMenuButton(
            icon: Icon(Icons.more_vert_rounded, color: c.textSecondary),
            onSelected: (value) {
              HapticService.selection();
              switch (value) {
                case 'amount':
                  _showAmountFilterDialog();
                  break;
                case 'date':
                  _showDateFilterDialog();
                  break;
                case 'export':
                  _exportTransactions();
                  break;
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'amount',
                child: Row(
                  children: [
                    Icon(Icons.tune_rounded, color: c.textSecondary, size: 18),
                    const SizedBox(width: 8),
                    Text('Фільтр по сумі',
                      style: AppTypography.bodyMedium.copyWith(color: c.textSecondary)),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'date',
                child: Row(
                  children: [
                    Icon(Icons.date_range_rounded, color: c.textSecondary, size: 18),
                    const SizedBox(width: 8),
                    Text('Фільтр по даті',
                      style: AppTypography.bodyMedium.copyWith(color: c.textSecondary)),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'export',
                child: Row(
                  children: [
                    Icon(Icons.file_download_rounded, color: c.textSecondary, size: 18),
                    const SizedBox(width: 8),
                    Text('Експорт',
                      style: AppTypography.bodyMedium.copyWith(color: c.textSecondary)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Consumer<DashboardProvider>(
        builder: (context, provider, _) {
          final allTransactions = provider.transactions;
          final filtered = _filterTransactions(allTransactions);

          if (allTransactions.isEmpty && provider.isLoading) {
            return _buildLoadingSkeleton(c);
          }

          if (allTransactions.isEmpty) {
            return AppEmptyState(
              icon: Icons.receipt_long_rounded,
              title: 'Немає транзакцій',
              subtitle: 'Тут з\'явиться історія твоїх внесків 💰',
              actionLabel: 'Зробити перший внесок',
              onAction: () => Navigator.of(context).pop(),
              isLightTheme: !isDark,
            );
          }

          final grouped = _groupByPeriod(filtered);
          final totalAmount = filtered.fold<double>(0, (sum, t) => sum + t.amount);
          final totalXP = filtered.fold<int>(0, (sum, t) => sum + (t.xpEarned ?? 0));

          return Column(
            children: [
              // ── Загальна сума ───────────────────────────────
              if (filtered.isNotEmpty)
                Container(
                  margin: const EdgeInsets.fromLTRB(
                    Spacing.base, Spacing.sm, Spacing.base, 0),
                  padding: const EdgeInsets.symmetric(
                    horizontal: Spacing.base,
                    vertical: Spacing.sm,
                  ),
                  decoration: BoxDecoration(
                    color: c.card,
                    borderRadius: BorderRadius.circular(Radii.md),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Всього: ${filtered.length} транзакцій',
                        style: AppTypography.labelMedium.copyWith(color: c.textSecondary),
                      ),
                      Text(
                        totalAmount.toInt().formatUAH() + ' грн',
                        style: AppTypography.monoMedium.copyWith(
                          color: c.accent,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(duration: 300.ms),

              // ── Search field ──────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: Spacing.base,
                  vertical: Spacing.sm,
                ),
                child: AppTextField(
                  controller: _searchController,
                  hint: 'Пошук за сумою або коментарем',
                  onChanged: _onSearch,
                  isLightTheme: !isDark,
                  prefixIcon: Icon(Icons.search_rounded, color: c.textHint),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? null
                      : Icon(Icons.tune_rounded, color: c.textHint),
                ),
              ),

              // ── Filter chips ──────────────────────────────────
              SizedBox(
                height: 40,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: Spacing.base),
                  itemCount: _filterLabels.length,
                  separatorBuilder: (_, __) => const SizedBox(width: Spacing.sm),
                  itemBuilder: (context, index) {
                    final isActive = _filterType == _filterTypes[index];
                    return GestureDetector(
                      onTap: () {
                        HapticService.selection();
                        setState(() => _filterType = _filterTypes[index]);
                      },
                      child: AnimatedContainer(
                        duration: AppDurations.fast,
                        padding: const EdgeInsets.symmetric(
                          horizontal: Spacing.base,
                          vertical: Spacing.sm,
                        ),
                        decoration: BoxDecoration(
                          color: isActive ? c.accent : Colors.transparent,
                          borderRadius: BorderRadius.circular(Radii.circular),
                          border: Border.all(
                            color: isActive ? c.accent : c.border,
                            width: 1.5,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (isActive)
                              const Icon(Icons.check_rounded, color: Colors.white, size: 14)
                            else
                              Icon(
                                _getFilterIcon(_filterTypes[index]),
                                color: c.textSecondary,
                                size: 14,
                              ),
                            if (isActive) const SizedBox(width: 4),
                            Text(
                              _filterLabels[index],
                              style: AppTypography.labelLarge.copyWith(
                                color: isActive ? Colors.white : c.textPrimary,
                                fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              // ── Grouping selector ─────────────────────────────
              Padding(
                padding: const EdgeInsets.only(
                  left: Spacing.base,
                  top: Spacing.sm,
                ),
                child: Row(
                  children: [
                    Text(
                      'Групувати по:',
                      style: AppTypography.labelSmall.copyWith(color: c.textHint),
                    ),
                    ...List.generate(
                      _groupByLabels.length,
                      (i) => Padding(
                        padding: const EdgeInsets.only(right: Spacing.sm),
                        child: GestureDetector(
                          onTap: () => _onGroupByChanged(
                            ['day', 'week', 'month'][i],
                          ),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: Spacing.sm,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: _groupBy == ['day', 'week', 'month'][i]
                                  ? c.accent
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(Radii.circular),
                            ),
                            child: Text(
                              _groupByLabels[i],
                              style: AppTypography.labelSmall.copyWith(
                                color: _groupBy == ['day', 'week', 'month'][i]
                                    ? Colors.white
                                    : c.textSecondary,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ── Active filters badges ─────────────────────────
              if (_showAmountFilter ||
                  _showDateFilter) ...[
                Padding(
                  padding: const EdgeInsets.only(
                    left: Spacing.base,
                    top: Spacing.xs,
                  ),
                  child: Wrap(
                    spacing: Spacing.sm,
                    children: [
                      if (_showAmountFilter) ...[
                        _FilterBadge(
                          label: '₴ ${_minAmountFilter?.toInt() ?? 0} – ${_maxAmountFilter?.toInt() ?? '∞'}',
                          onTap: _showAmountFilterDialog,
                          c: c,
                        ),
                      ],
                      if (_showDateFilter && _dateFrom != null) ...[
                        _FilterBadge(
                          label: '${_dateFrom!.day.toString().padLeft(2, '0')}.${_dateFrom!.month.toString().padLeft(2, '0')} – ${_dateTo!.day.toString().padLeft(2, '0')}.${_dateTo!.month.toString().padLeft(2, '0')}',
                          onTap: _showDateFilterDialog,
                          c: c,
                        ),
                      ],
                    ],
                  ),
                ),
              ],

              // ── Transaction list ─────────────────────────────
              Expanded(
                child: Stack(
                  children: [
                    RefreshIndicator(
                      onRefresh: () => _onRefresh(provider),
                      color: c.accent,
                      child: grouped.isEmpty
                          ? _buildNoResultsState(c)
                          : ListView.builder(
                              controller: _scrollController,
                              padding: const EdgeInsets.symmetric(
                                horizontal: Spacing.base,
                              ),
                              itemCount:
                                  grouped.length +
                                  (_isLoadingMore ? 1 : 0),
                              itemBuilder: (context, sectionIndex) {
                                if (sectionIndex >= grouped.length) {
                                  return Padding(
                                    padding:
                                        const EdgeInsets.all(Spacing.base),
                                    child: Center(
                                      child: SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: c.accent,
                                        ),
                                      ),
                                    ),
                                  );
                                }

                                final entry =
                                    grouped.entries.elementAt(sectionIndex);
                                final dateLabel = entry.key;
                                final items = entry.value;

                                return Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    // Date header with XP
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        top: Spacing.base,
                                        bottom: Spacing.xs,
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment
                                                .spaceBetween,
                                        children: [
                                          Text(
                                            dateLabel,
                                            style: AppTypography
                                                .labelMedium
                                                .copyWith(
                                                  color:
                                                      c.textSecondary,
                                                  fontWeight:
                                                      FontWeight.w600,
                                                ),
                                          ),
                                          Container(
                                            padding:
                                                const EdgeInsets.symmetric(
                                                  horizontal:
                                                      Spacing.sm,
                                                  vertical: 2,
                                                ),
                                            decoration:
                                                BoxDecoration(
                                                  color: c.accent
                                                      .withOpacity(0.08),
                                                  borderRadius:
                                                      BorderRadius
                                                          .circular(
                                                              Radii.sm),
                                                ),
                                            child: Row(
                                              mainAxisSize:
                                                  MainAxisSize.min,
                                              children: [
                                                Icon(
                                                  Icons
                                                      .trending_up_rounded,
                                                  color: c.accent,
                                                  size: 12,
                                                ),
                                                const SizedBox(
                                                    width: 4,
                                                ),
                                                Text(
                                                  '${_dayTotal(items).toInt().formatUAH()} грн',
                                                  style: AppTypography
                                                      .labelSmall
                                                      .copyWith(
                                                        color: c.accent,
                                                        fontWeight:
                                                            FontWeight
                                                                .w600,
                                                        fontSize: 11,
                                                      ),
                                                ),
                                                if (_dayXP(items) >
                                                    0) ...[
                                                  const SizedBox(
                                                      width:
                                                          Spacing.sm,
                                                  ),
                                                  Text(
                                                    '+${_dayXP(items)} XP',
                                                    style: AppTypography
                                                        .labelSmall
                                                        .copyWith(
                                                      color:
                                                          AppColorsPS5
                                                              .xp,
                                                      fontSize: 11,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),

                                      // Transaction tiles
                                      ...items.map(
                                        (t) => Padding(
                                          padding:
                                              const EdgeInsets.only(
                                                bottom:
                                                    Spacing.xs,
                                              ),
                                          child: Dismissible(
                                            key:
                                                ValueKey(t.id),
                                            direction:
                                                DismissDirection
                                                    .endToStart,
                                            background: Container(
                                              alignment:
                                                  Alignment
                                                      .centerRight,
                                              margin:
                                                  const EdgeInsets
                                                          .only(
                                                              left: 40),
                                              padding:
                                                  const EdgeInsets
                                                          .only(
                                                              right:
                                                                  Spacing
                                                                      .base,
                                                              ),
                                              decoration:
                                                  BoxDecoration(
                                                    color: AppColorsPS5
                                                        .error
                                                        .withOpacity(
                                                              0.08),
                                                    borderRadius:
                                                        BorderRadius
                                                            .circular(
                                                                Radii
                                                                    .md),
                                                  ),
                                              child: Icon(
                                                Icons
                                                    .delete_outline_rounded,
                                                color:
                                                    AppColorsPS5
                                                        .error,
                                              ),
                                            ),
                                            confirmDismiss:
                                                (_) async => true,
                                            onDismissed: (_) =>
                                                _showDeleteUndo(t),
                                            child:
                                                TransactionTile(
                                                  type: t.type,
                                                  amount: t.amount,
                                                  date:
                                                      t.createdAt,
                                                  comment:
                                                      t.comment,
                                                  xp: t.xpEarned,
                                                  isLightTheme:
                                                      !isDark,
                                                ),
                                          ),
                                        ),
                                      ),

                                      // Date separator
                                      if (sectionIndex <
                                          grouped.length - 1)
                                        Padding(
                                          padding: const
                                              .symmetric(
                                                vertical:
                                                    Spacing.xs,
                                              ),
                                          child: Divider(
                                            color: c.border
                                                .withOpacity(0.3),
                                            height: 1,
                                          ),
                                        ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                    ),
                    // ── Bulk actions overlay ────────────────────────
                    if (_showBulkActions &&
                        _selectedIds.isNotEmpty)
                      Positioned(
                        bottom: 16,
                        left: 0,
                        right: 0,
                        child: Container(
                          margin: const
                              .symmetric(
                            horizontal:
                                Spacing.base,
                          ),
                          padding: const EdgeInsets.all(
                            Spacing.base,
                          ),
                          decoration: BoxDecoration(
                            color: c.card,
                            borderRadius:
                                BorderRadius.circular(Radii.lg),
                            border: Border.all(
                              color: c.border,
                            ),
                            boxShadow: AppShadows
                                .level2,
                            ),
                            child: SafeArea(
                              child: Column(
                                mainAxisSize:
                                    MainAxisSize.min,
                                children: [
                                  Text(
                                    'Масові дії (${_selectedIds.length})',
                                    style: AppTypography
                                        .labelLarge
                                        .copyWith(
                                      color:
                                          c.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height:
                                      Spacing.sm),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: AppButtonSecondary(
                                          label: 'Вибрати всі',
                                          onPressed: () =>
                                              _selectAll(filtered),
                                          isLightTheme:
                                              !isDark,
                                        ),
                                      ),
                                      const SizedBox(
                                          width: Spacing.sm,
                                      ),
                                      Expanded(
                                        child: AppButtonSecondary(
                                          label: 'Скасувати',
                                          icon: Icons
                                              .close_rounded,
                                          onPressed: () =>
                                              _clearSelection(),
                                          isLightTheme:
                                              !isDark,
                                        ),
                                      ),
                                      const SizedBox(
                                          width: Spacing.sm,
                                      ),
                                      Expanded(
                                        child: AppButtonPrimary(
                                          label: 'Видалити',
                                          icon: Icons
                                              .delete_outline_rounded,
                                          onPressed:
                                              _deleteSelected,
                                          isLightTheme:
                                              !isDark,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildNoResultsState(dynamic c) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off_rounded, size: 48, color: c.textHint),
          const SizedBox(height: Spacing.md),
          Text(
            'Нічого не знайдено',
            style: AppTypography.bodyMedium.copyWith(color: c.textHint),
          ),
          const SizedBox(height: Spacing.sm),
          Text(
            'Спробуй інший фільтр або пошук',
            style: AppTypography.labelSmall.copyWith(color: c.textHint),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingSkeleton(dynamic c) {
    return ListView.builder(
      padding: const EdgeInsets.all(Spacing.base),
      itemCount: 6,
      itemBuilder: (_, i) {
        return Container(
          margin: const EdgeInsets.only(bottom: Spacing.sm),
          height: i == 0 ? 48 : 72,
          decoration: BoxDecoration(
            color: c.surface,
            borderRadius: BorderRadius.circular(Radii.md),
          ),
        );
      },
    );
  }

  /// Бейдж фільтра для відображення активних фільтрів.
  Widget _FilterBadge({
    required String label,
    required VoidCallback onTap,
    required dynamic c,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: Spacing.sm,
          vertical: 4,
        ),
        decoration: BoxDecoration(
          color: c.accent.withOpacity(0.08),
          borderRadius: BorderRadius.circular(Radii.sm),
        ),
        child: Text(
          label,
          style: AppTypography.labelSmall.copyWith(
            color: c.accent,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  IconData _getFilterIcon(TransactionType? type) {
    switch (type) {
      case TransactionType.manual:
        return Icons.touch_app_rounded;
      case TransactionType.autoPayment:
        return Icons.autorenew_rounded;
      case TransactionType.challenge:
        return Icons.emoji_events_rounded;
      default:
        return Icons.receipt_long_rounded;
    }
  }

  /// Розраховує медіану суми для фільтрованих транзакцій.
  double _calculateMedian(List<Transaction> transactions) {
    if (transactions.isEmpty) return 0;
    try {
      final sorted = transactions.map((t) => t.amount).toList()..sort();
      final mid = sorted.length ~/ 2;
      if (sorted.length % 2 == 0) {
        return (sorted[mid - 1] + sorted[mid]) / 2;
      }
      return sorted[mid];
    } catch (e) {
      debugPrint('[TransactionHistory] Error calculating median: $e');
      return 0;
    }
  }

  /// Розраховує стандартне відхилення суми транзакцій.
  double _calculateStandardDeviation(List<Transaction> transactions) {
    if (transactions.isEmpty) return 0;
    try {
      final amounts = transactions.map((t) => t.amount).toList();
      final mean = amounts.reduce((a, b) => a + b) / amounts.length;
      final variance = amounts.map((a) => (a - mean) * (a - mean)).reduce((a, b) => a + b) / amounts.length;
      return math.sqrt(variance);
    } catch (e) {
      debugPrint('[TransactionHistory] Error calculating std dev: $e');
      return 0;
    }
  }

  /// Розраховує зведену статистику для поточного фільтру.
  _TransactionSummaryStats _calculateSummaryStats(List<Transaction> filtered) {
    if (filtered.isEmpty) {
      return _TransactionSummaryStats(
        total: 0, count: 0, avg: 0, median: 0,
        max: 0, min: 0, stdDev: 0, totalXP: 0,
      );
    }
    final total = filtered.fold<double>(0, (s, t) => s + t.amount);
    final count = filtered.length;
    final avg = total / count;
    final amounts = filtered.map((t) => t.amount).toList();
    final maxVal = amounts.reduce((a, b) => a > b ? a : b);
    final minVal = amounts.reduce((a, b) => a < b ? a : b);
    final median = _calculateMedian(filtered);
    final stdDev = _calculateStandardDeviation(filtered);
    final totalXP = filtered.fold<int>(0, (s, t) => s + (t.xpEarned ?? 0));
    return _TransactionSummaryStats(
      total: total, count: count, avg: avg, median: median,
      max: maxVal, min: minVal, stdDev: stdDev, totalXP: totalXP,
    );
  }

  /// Побудовує розширений рядок швидкої статистики.
  Widget _buildQuickStatsRow(_TransactionSummaryStats stats, dynamic c) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.fromLTRB(Spacing.base, Spacing.sm, Spacing.base, 0),
      padding: const EdgeInsets.all(Spacing.sm),
      decoration: BoxDecoration(
        color: c.card,
        borderRadius: BorderRadius.circular(Radii.md),
        border: Border.all(color: c.border.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _QuickStatChip(
            label: 'Медіана',
            value: '${stats.median.formatUAH()}',
            icon: Icons.linear_scale_rounded,
            color: c.accent,
            c: c,
          ),
          _QuickStatChip(
            label: 'σ відхил.',
            value: '${stats.stdDev.formatUAH()}',
            icon: Icons.timeline_rounded,
            color: c.warning,
            c: c,
          ),
          _QuickStatChip(
            label: 'XP',
            value: '+${stats.totalXP}',
            icon: Icons.star_rounded,
            color: AppColorsPS5.xp,
            c: c,
          ),
        ],
      ),
    );
  }

  /// Побудовує розгорнуту секцію статистичного резюме.
  Widget _buildStatsSummary(_TransactionSummaryStats stats, dynamic c, bool isDark) {
    return AppCard(
      isLightTheme: !isDark,
      padding: const EdgeInsets.all(Spacing.base),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Статистичне резюме',
              style: AppTypography.heading3.copyWith(color: c.textPrimary)),
          const SizedBox(height: Spacing.md),
          _StatsRow(
            label: 'Кількість транзакцій',
            value: '${stats.count}',
            color: c.textPrimary,
            c: c,
          ),
          _StatsRow(
            label: 'Загальна сума',
            value: '${stats.total.formatUAH()} грн',
            color: c.accent,
            c: c,
          ),
          _StatsRow(
            label: 'Середнє значення',
            value: '${stats.avg.formatUAH()} грн',
            color: c.textPrimary,
            c: c,
          ),
          _StatsRow(
            label: 'Медіана',
            value: '${stats.median.formatUAH()} грн',
            color: c.textPrimary,
            c: c,
          ),
          _StatsRow(
            label: 'Максимальна',
            value: '${stats.max.formatUAH()} грн',
            color: c.success,
            c: c,
          ),
          _StatsRow(
            label: 'Мінімальна',
            value: '${stats.min.formatUAH()} грн',
            color: c.warning,
            c: c,
          ),
          _StatsRow(
            label: 'Стандартне відхилення',
            value: '${stats.stdDev.formatUAH()} грн',
            color: c.textSecondary,
            c: c,
          ),
          const SizedBox(height: Spacing.sm),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: Spacing.base, vertical: Spacing.sm),
            decoration: BoxDecoration(
              color: c.accent.withOpacity(0.04),
              borderRadius: BorderRadius.circular(Radii.md),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline_rounded, color: c.accent, size: 16),
                const SizedBox(width: Spacing.sm),
                Expanded(
                  child: Text(
                    'Варіація ${stats.stdDev > stats.avg * 0.5 ? "висока" : "низька"} — '
                    '${stats.stdDev > stats.avg * 0.5 ? "спробуй стабілізувати суми" : "стабільний pattern внесків"}',
                    style: AppTypography.labelSmall.copyWith(color: c.accent),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Побудовує стан помилки при завантаженні даних.
  Widget _buildErrorState(dynamic c, dynamic error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(Spacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline_rounded, size: 56, color: c.error),
            const SizedBox(height: Spacing.base),
            Text('Помилка завантаження',
                style: AppTypography.heading3.copyWith(color: c.textPrimary)),
            const SizedBox(height: Spacing.sm),
            Text(
              'Не вдалося завантажити транзакції. Спробуй пізніше.',
              style: AppTypography.bodyMedium.copyWith(color: c.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: Spacing.sm),
            Text(
              '$error',
              style: AppTypography.caption.copyWith(color: c.textHint),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: Spacing.base),
            ElevatedButton.icon(
              onPressed: () {
                setState(() {});
              },
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Спробувати знову'),
            ),
          ],
        ),
      ),
    );
  }

  /// Розраховує розподіл за типами транзакцій.
  Map<String, int> _calculateTypeDistribution(List<Transaction> transactions) {
    final distribution = <String, int>{};
    for (final t in transactions) {
      final typeName = t.type.name;
      distribution[typeName] = (distribution[typeName] ?? 0) + 1;
    }
    return distribution;
  }

  /// Показує діалог сортування транзакцій.
  void _showSortDialog(List<Transaction> filtered) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final c = isDark ? AppColorsPS5 : AppColorsMonitor;

    showDialog(
      context: context,
      builder: (ctx) => SimpleDialog(
        backgroundColor: c.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Radii.xl)),
        title: Text('Сортувати за',
            style: AppTypography.heading3.copyWith(color: c.textPrimary)),
        children: [
          _SortOption(
            label: 'Датою (нові спочатку)',
            icon: Icons.access_time_rounded,
            c: c,
            onTap: () { Navigator.pop(ctx); },
          ),
          _SortOption(
            label: 'Сумою (зростання)',
            icon: Icons.arrow_upward_rounded,
            c: c,
            onTap: () { Navigator.pop(ctx); },
          ),
          _SortOption(
            label: 'Сумою (спадання)',
            icon: Icons.arrow_downward_rounded,
            c: c,
            onTap: () { Navigator.pop(ctx); },
          ),
          _SortOption(
            label: 'XP (зростання)',
            icon: Icons.star_rounded,
            c: c,
            onTap: () { Navigator.pop(ctx); },
          ),
        ],
      ),
    );
  }
}

/// Зведена статистика для відфільтрованих транзакцій.
class _TransactionSummaryStats {
  /// Загальна сума всіх транзакцій.
  final double total;

  /// Кількість транзакцій.
  final int count;

  /// Середня сума транзакції.
  final double avg;

  /// Медіанна сума транзакції.
  final double median;

  /// Максимальна сума транзакції.
  final double max;

  /// Мінімальна сума транзакції.
  final double min;

  /// Стандартне відхилення сум.
  final double stdDev;

  /// Загальна кількість XP отримана з транзакцій.
  final int totalXP;

  const _TransactionSummaryStats({
    required this.total,
    required this.count,
    required this.avg,
    required this.median,
    required this.max,
    required this.min,
    required this.stdDev,
    required this.totalXP,
  });
}

/// Міні-чип швидкої статистики для рядка підсумків.
class _QuickStatChip extends StatelessWidget {
  const _QuickStatChip({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.c,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final dynamic c;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 12),
            const SizedBox(width: 4),
            Text(label,
                style: AppTypography.caption.copyWith(color: c.textHint, fontSize: 9)),
          ],
        ),
        const SizedBox(height: 2),
        Text(value,
            style: AppTypography.monoSmall.copyWith(
              color: color, fontWeight: FontWeight.w700, fontSize: 12,
            )),
      ],
    );
  }
}

/// Рядок статистичного значення для резюме.
class _StatsRow extends StatelessWidget {
  const _StatsRow({
    required this.label,
    required this.value,
    required this.color,
    required this.c,
  });

  final String label;
  final String value;
  final Color color;
  final dynamic c;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Spacing.xs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: AppTypography.labelMedium.copyWith(color: c.textSecondary)),
          Text(value,
              style: AppTypography.monoSmall.copyWith(
                color: color, fontWeight: FontWeight.w600,
              )),
        ],
      ),
    );
  }
}

/// Опція сортування для діалогу сортування.
class _SortOption extends StatelessWidget {
  const _SortOption({
    required this.label,
    required this.icon,
    required this.c,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final dynamic c;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(Radii.md),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: Spacing.base, vertical: Spacing.md),
        child: Row(
          children: [
            Icon(icon, color: c.textSecondary, size: 20),
            const SizedBox(width: Spacing.md),
            Text(label,
                style: AppTypography.bodyMedium.copyWith(color: c.textPrimary)),
          ],
        ),
      ),
    );
  }
}
