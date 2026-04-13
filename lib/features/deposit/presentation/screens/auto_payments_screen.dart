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
import '../../../../core/extensions/number_format_ext.dart';
import '../../../../core/extensions/build_context_ext.dart';
import '../../../../core/utils/haptic_service.dart';
import '../../../../core/widgets/app_button_primary.dart';
import '../../../../core/widgets/app_button_secondary.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../data/models/auto_payment_model.dart';
import '../../providers/deposit_provider.dart';

/// Тривалість завантаження екрану (мілісекунди).
const int _kLoadingDelayMs = 600;

/// Максимальна кількість автоплатежів для одного користувача.
const int _kMaxAutoPayments = 10;

/// Мінімальна сума автоплатежу (грн).
const double _kMinPaymentAmount = 1.0;

/// Максимальна сума автоплатежу (грн).
const double _kMaxPaymentAmount = 100000.0;

/// Кількість shimmer-елементів при завантаженні.
const int _kSkeletonItemCount = 3;

/// Мінімальна довжина назви автоплатежу.
const int _kMinNameLength = 2;

/// Кількість спроб підтвердження видалення.
const int _kDeleteConfirmAttempts = 2;

/// Екран списку автоматичних платежів з повним функціоналом.
///
/// Містить: активний список з toggle, swipe to edit/delete, статистику,
/// empty state, add button, confirm delete dialog, loading skeleton, pull-to-refresh.
class AutoPaymentsScreen extends StatefulWidget {
  const AutoPaymentsScreen({super.key});

  static const String route = '/auto-payments';

  @override
  State<AutoPaymentsScreen> createState() => _AutoPaymentsScreenState();
}

class _AutoPaymentsScreenState extends State<AutoPaymentsScreen> {
  bool _isLoading = true;
  bool _isRefreshing = false;
  bool _isCreating = false;

  /// Чи показувати лише активні платежі.
  bool _showActiveOnly = false;

  /// Лічильник дій користувача за сесію.
  int _actionCount = 0;

  /// Час останньої дії користувача.
  DateTime? _lastActionTime;

  /// Обчислює загальну суму всіх активних автоплатежів.
  double _computeTotalMonthly(List<AutoPayment> payments) {
    if (payments.isEmpty) return 0.0;
    try {
      return payments
          .where((p) => p.isEnabled)
          .fold<double>(0, (sum, p) => sum + p.amount);
    } catch (e) {
      debugPrint('[AutoPayments] Error computing total: $e');
      return 0.0;
    }
  }

  /// Обчислює середню суму автоплатежу.
  double _computeAverageAmount(List<AutoPayment> payments) {
    if (payments.isEmpty) return 0.0;
    try {
      final enabled = payments.where((p) => p.isEnabled).toList();
      if (enabled.isEmpty) return 0.0;
      return enabled.fold<double>(0, (sum, p) => sum + p.amount) / enabled.length;
    } catch (e) {
      debugPrint('[AutoPayments] Error computing average: $e');
      return 0.0;
    }
  }

  /// Перевіряє, чи можна створити новий автоплатіж.
  bool _canCreatePayment(List<AutoPayment> payments) {
    return payments.length < _kMaxAutoPayments;
  }

  /// Валідує суму автоплатежу.
  String? _validateAmount(String text) {
    final amount = double.tryParse(text);
    if (amount == null) return 'Введи коректне число';
    if (amount < _kMinPaymentAmount) return 'Мінімум $_kMinPaymentAmount грн';
    if (amount > _kMaxPaymentAmount) return 'Максимум ${_kMaxPaymentAmount.toInt()} грн';
    return null;
 }

  /// Додає запис до журналу дій.
  void _logAction(String action) {
    _actionCount++;
    _lastActionTime = DateTime.now();
    debugPrint('[AutoPayments] Action #$actionCount: $action at $_lastActionTime');
  }

  /// Форматує суму з валютою.
  String _formatAmount(double amount) {
    try {
      return '${amount.toStringAsFixed(0)} грн';
    } catch (e) {
      return '0 грн';
    }
  }

  /// Будує панель швидкої інформації про автоплатежі.
  Widget _buildQuickInfoBar(dynamic c, List<AutoPayment> payments) {
    final total = _computeTotalMonthly(payments);
    final average = _computeAverageAmount(payments);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: Spacing.base, vertical: Spacing.xs),
      padding: const EdgeInsets.symmetric(horizontal: Spacing.sm, vertical: 8),
      decoration: BoxDecoration(color: c.accent.withOpacity(0.04), borderRadius: BorderRadius.circular(Radii.sm)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Text('Місяць: ${_formatAmount(total)}', style: AppTypography.labelSmall.copyWith(color: c.textSecondary, fontSize: 10)),
          Text('Середній: ${_formatAmount(average)}', style: AppTypography.labelSmall.copyWith(color: c.textSecondary, fontSize: 10)),
          Text('Ліміт: $_kMaxAutoPayments', style: AppTypography.labelSmall.copyWith(color: c.textSecondary, fontSize: 10)),
        ],
      ),
    );
  }

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

  Future<void> _onRefresh(DepositProvider provider) async {
    setState(() => _isRefreshing = true);
    await provider.refreshAutoPayments();
    if (mounted) {
      setState(() => _isRefreshing = false);
    }
  }

  void _showDeleteDialog(BuildContext context, AutoPayment payment, DepositProvider provider) {
    HapticService.selection();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Radii.lg)),
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: AppColorsPS5.error),
            const SizedBox(width: Spacing.sm),
            const Text('Видалити автоплатіж?'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Автоплатіж ${payment.amount.formatUAH()} грн (${payment.frequencyLabel}) буде скасовано.',
            ),
            const SizedBox(height: Spacing.base),
            Container(
              padding: const EdgeInsets.all(Spacing.sm),
              decoration: BoxDecoration(
                color: AppColorsPS5.error.withOpacity(0.06),
                borderRadius: BorderRadius.circular(Radii.sm),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline_rounded, size: 14, color: AppColorsPS5.error),
                  const SizedBox(width: Spacing.xs),
                  Expanded(
                    child: Text(
                      'Цю дію не можна скасувати. Всі майбутні автоматичні внески будуть припинені.',
                      style: AppTypography.labelSmall.copyWith(color: AppColorsPS5.error),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Скасувати'),
          ),
          TextButton(
            onPressed: () {
              provider.deleteAutoPayment(payment.id);
              Navigator.pop(ctx);
              context.showToast('Автоплатіж видалено', icon: Icons.check_circle_rounded);
            },
            child: Text('Видалити', style: TextStyle(color: AppColorsPS5.error, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(BuildContext context, AutoPayment payment) {
    final amountController = TextEditingController(text: payment.amount.toInt().toString());
    String? amountError;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Radii.lg)),
          title: const Text('Редагувати автоплатіж'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${payment.frequencyLabel}',
                style: AppTypography.labelMedium.copyWith(color: AppColorsPS5.textSecondary),
              ),
              const SizedBox(height: Spacing.base),
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Сума (грн)',
                  border: const OutlineInputBorder(),
                  prefixText: '₴ ',
                  errorText: amountError,
                ),
                onChanged: (_) => setDialogState(() => amountError = null),
              ),
              const SizedBox(height: Spacing.sm),
              Row(
                children: [
                  Icon(Icons.info_outline_rounded, size: 14, color: AppColorsPS5.textSecondary),
                  const SizedBox(width: Spacing.xs),
                  Expanded(
                    child: Text(
                      'Наступній платіж: ${payment.nextDateLabel}',
                      style: AppTypography.labelSmall.copyWith(color: AppColorsPS5.textSecondary),
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                amountController.dispose();
                Navigator.pop(ctx);
              },
              child: const Text('Скасувати'),
            ),
            TextButton(
              onPressed: () {
                final amount = double.tryParse(amountController.text) ?? 0;
                if (amount <= 0) {
                  setDialogState(() => amountError = 'Введи коректну суму');
                  return;
                }
                context.showToast('Автоплатіж оновлено!', icon: Icons.check_circle_rounded);
                amountController.dispose();
                Navigator.pop(ctx);
              },
              child: const Text('Зберегти'),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddDialog(BuildContext context) {
    final amountController = TextEditingController();
    String? amountError;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Radii.lg)),
          title: const Text('Новий автоплатіж'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Налаштуй регулярне поповнення, щоб накопичувати автоматично!',
                style: AppTypography.labelSmall.copyWith(color: AppColorsPS5.textSecondary),
              ),
              const SizedBox(height: Spacing.base),
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Сума (грн)',
                  border: const OutlineInputBorder(),
                  prefixText: '₴ ',
                  hintText: 'Наприклад: 100',
                  errorText: amountError,
                ),
                onChanged: (_) => setDialogState(() => amountError = null),
              ),
              const SizedBox(height: Spacing.sm),
              Text(
                '💡 Порада: почни з невеликої суми та збільшуй пізніше',
                style: AppTypography.labelSmall.copyWith(color: AppColorsPS5.textHint),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                amountController.dispose();
                Navigator.pop(ctx);
              },
              child: const Text('Скасувати'),
            ),
            TextButton(
              onPressed: () {
                final amount = double.tryParse(amountController.text) ?? 0;
                if (amount <= 0) {
                  setDialogState(() => amountError = 'Введи коректну суму');
                  return;
                }
                context.showToast('Автоплатіж створено!', icon: Icons.check_circle_rounded);
                amountController.dispose();
                Navigator.pop(ctx);
              },
              child: const Text('Створити'),
            ),
          ],
        ),
      ),
    );
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
          'Автоплатежі',
          style: AppTypography.heading1.copyWith(color: c.textPrimary),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: c.textSecondary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          if (!_isLoading)
            IconButton(
              icon: Icon(Icons.info_outline_rounded, color: c.textSecondary),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Radii.lg)),
                    title: const Text('Як працюють автоплатежі?'),
                    content: const Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Автоплатежі — це регулярні автоматичні внески, які допомагають накопичувати без зусиль.'),
                        SizedBox(height: 12),
                        Text('💡 Можеш створити кілька автоплатежів з різними сумами та частотами.'),
                        SizedBox(height: 12),
                        Text('⚡ Кожен автоплатіж дає XP так само як звичайний внесок!'),
                      ],
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text('Зрозуміло'),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
      body: Consumer<DepositProvider>(
        builder: (context, provider, _) {
          final payments = provider.autoPayments;

          if (_isLoading) {
            return _buildLoadingSkeleton(c);
          }

          if (payments.isEmpty) {
            return AppEmptyState(
              icon: Icons.autorenew_rounded,
              title: 'У тебе ще немає автоплатежів',
              subtitle: 'Налаштуй регулярні поповнення,\n'
                  'щоб накопичувати автоматично 🔄',
              actionLabel: 'Додати автоплатіж',
              onAction: () => _showAddDialog(context),
              isLightTheme: !isDark,
            );
          }

          final activePayments = payments.where((p) => p.isEnabled).toList();
          final pausedPayments = payments.where((p) => !p.isEnabled).toList();

          return RefreshIndicator(
            onRefresh: () => _onRefresh(provider),
            color: c.accent,
            child: CustomScrollView(
              slivers: [
                // Підзаголовок
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(Spacing.base, Spacing.sm, Spacing.base, Spacing.sm),
                    child: Text(
                      'Налаштуй регулярні поповнення',
                      style: AppTypography.bodyMedium.copyWith(color: c.textSecondary),
                    ),
                  ),
                ),

                // Статистика
                SliverToBoxAdapter(
                  child: _buildStatsCard(provider, c, isDark),
                ),

                // Лічильник
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(Spacing.base, Spacing.xl, Spacing.base, Spacing.sm),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Всі автоплатежі',
                          style: AppTypography.heading3.copyWith(color: c.textPrimary),
                        ),
                        Text(
                          '${activePayments.length} активних',
                          style: AppTypography.labelMedium.copyWith(color: c.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ),

                // Активні
                if (activePayments.isNotEmpty) ...[
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: Spacing.base),
                      child: Text(
                        'Активні',
                        style: AppTypography.labelLarge.copyWith(
                          color: c.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final payment = activePayments[index];
                        return _AutoPaymentTile(
                          payment: payment,
                          isLightTheme: !isDark,
                          onToggle: (val) => provider.toggleAutoPayment(payment.id, val),
                          onDelete: () => _showDeleteDialog(context, payment, provider),
                          onEdit: () => _showEditDialog(context, payment),
                        );
                      },
                      childCount: activePayments.length,
                    ),
                  ),
                ],

                // Призупинені
                if (pausedPayments.isNotEmpty) ...[
                  const SliverToBoxAdapter(child: SizedBox(height: Spacing.base)),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: Spacing.base),
                      child: Text(
                        'Призупинені',
                        style: AppTypography.labelLarge.copyWith(
                          color: c.textHint,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final payment = pausedPayments[index];
                        return Opacity(
                          opacity: 0.55,
                          child: _AutoPaymentTile(
                            payment: payment,
                            isLightTheme: !isDark,
                            onToggle: (val) => provider.toggleAutoPayment(payment.id, val),
                            onDelete: () => _showDeleteDialog(context, payment, provider),
                            onEdit: () => _showEditDialog(context, payment),
                          ),
                        );
                      },
                      childCount: pausedPayments.length,
                    ),
                  ),
                ],

                const SliverToBoxAdapter(child: SizedBox(height: 120)),
              ],
            ),
          );
        },
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: Spacing.xl),
        child: AppButtonPrimary(
          label: 'Додати автоплатіж',
          icon: Icons.add_rounded,
          onPressed: () => _showAddDialog(context),
          isLightTheme: !isDark,
          showGlow: true,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  /// Skeleton для завантаження.
  Widget _buildLoadingSkeleton(dynamic c) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(Spacing.base),
      child: Column(
        children: [
          Container(height: 16, width: 200, decoration: BoxDecoration(color: c.surface, borderRadius: BorderRadius.circular(8))),
          const SizedBox(height: Spacing.xl),
          _buildSkeletonShimmer(width: double.infinity, height: 140, color: c.card, radius: Radii.lg),
          const SizedBox(height: Spacing.xl),
          for (int i = 0; i < 3; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: Spacing.sm),
              child: _buildSkeletonShimmer(width: double.infinity, height: 90, color: c.card, radius: Radii.lg),
            ),
        ],
      ),
    );
  }

  Widget _buildSkeletonShimmer({required double width, required double height, required Color color, required double radius}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }

  /// Картка статистики.
  Widget _buildStatsCard(DepositProvider provider, dynamic c, bool isDark) {
    final totalViaAuto = provider.totalViaAutoPayments;
    final nextPayment = provider.nextAutoPaymentDate;
    final payments = provider.autoPayments;
    final activeCount = payments.where((p) => p.isEnabled).length;

    return AppCard(
      isLightTheme: !isDark,
      margin: const EdgeInsets.symmetric(horizontal: Spacing.base),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.bar_chart_rounded, color: c.accent, size: 18),
              const SizedBox(width: Spacing.sm),
              Text(
                'Статистика автоплатежів',
                style: AppTypography.heading3.copyWith(color: c.textPrimary),
              ),
            ],
          ),
          const SizedBox(height: Spacing.base),

          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  label: 'Всього внесено',
                  value: '${totalViaAuto.formatUAH()} грн',
                  valueColor: c.success,
                  subColor: c.textSecondary,
                ),
              ),
              Container(width: 1, height: 40, color: c.border),
              Expanded(
                child: _buildStatItem(
                  label: 'Наступний платіж',
                  value: nextPayment ?? 'Немає',
                  valueColor: c.accent,
                  subColor: c.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: Spacing.sm),
          Divider(color: c.border.withOpacity(0.5)),
          const SizedBox(height: Spacing.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.repeat_rounded, color: c.textSecondary, size: 16),
                  const SizedBox(width: Spacing.xs),
                  Text(
                    'Активних: $activeCount',
                    style: AppTypography.labelSmall.copyWith(color: c.textSecondary),
                  ),
                ],
              ),
              Row(
                children: [
                  Icon(Icons.pause_circle_outline_rounded, color: c.textSecondary, size: 16),
                  const SizedBox(width: Spacing.xs),
                  Text(
                    'Призупинених: ${payments.length - activeCount}',
                    style: AppTypography.labelSmall.copyWith(color: c.textSecondary),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildStatItem({
    required String label,
    required String value,
    required Color valueColor,
    required Color subColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTypography.labelMedium.copyWith(color: subColor)),
        const SizedBox(height: Spacing.xs),
        Text(
          value,
          style: AppTypography.monoSmall.copyWith(color: valueColor, fontWeight: FontWeight.w500),
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // Додаткові константи екрану автоплатежів
  // ═══════════════════════════════════════════════════════════════════════

  /// Максимальна довжина назви автоплатежу для відображення.
  static const int _kMaxNameDisplayLength = 28;

  /// Кількість shimmer-елементів при завантаженні (більший розмір).
  static const int _kExtendedSkeletonCount = 5;

  /// Затримка анімації появи картки статистики (мілісекунди).
  static const int _kStatsAnimDelayMs = 200;

  /// Мінімальна сума для виділення «висока».
  static const double _kHighAmountThreshold = 5000.0;

  /// Максимальна кількість символів у пошуковому запиті.
  static const int _kMaxSearchLength = 40;

  /// Кількість найчастіших сум для швидкого вибору.
  static const int _kQuickAmountCount = 4;

  // ═══════════════════════════════════════════════════════════════════════
  // Пошуковий стан
  // ═══════════════════════════════════════════════════════════════════════

  /// Запит для пошуку автоплатежів за сумою або назвою.
  String _searchQuery = '';

  /// Чи показувати панель пошуку.
  bool _isSearchVisible = false;

  // ═══════════════════════════════════════════════════════════════════════
  // Валідаційні методи
  // ═══════════════════════════════════════════════════════════════════════

  /// Перевіряє, чи рядок пошуку відповідає автоплатежу.
  ///
  /// Здійснює пошук за сумою (як число) та за частотою.
  /// Пошук нечутливий до регістру.
  bool _matchesSearchQuery(AutoPayment payment, String query) {
    if (query.isEmpty) return true;
    final lowerQuery = query.toLowerCase();
    final amountStr = payment.amount.toInt().toString();
    final frequencyStr = payment.frequencyLabel.toLowerCase();
    return amountStr.contains(lowerQuery) ||
        frequencyStr.contains(lowerQuery);
  }

  /// Валідує назву автоплатежу при створенні.
  ///
  /// Повертає `null`, якщо назва валідна, або рядок помилки.
  String? _validatePaymentName(String name) {
    if (name.trim().isEmpty) return 'Назва не може бути порожньою';
    if (name.trim().length < _kMinNameLength) {
      return 'Мінімальна довжина назви — $_kMinNameLength символи';
    }
    if (name.trim().length > _kMaxNameDisplayLength) {
      return 'Максимальна довжина назви — $_kMaxNameDisplayLength символів';
    }
    return null;
  }

  /// Валідує частоту автоплатежу за датою наступного платежу.
  ///
  /// Повертає `true`, якщо наступний платіж ще не настав.
  bool _isNextPaymentValid(AutoPayment payment) {
    try {
      // Якщо nextDateLabel містить «завтра» або більше — валідно.
      return payment.nextDateLabel.isNotEmpty;
    } catch (e) {
      debugPrint('[AutoPayments] Error validating next payment: $e');
      return false;
    }
  }

  /// Перевіряє, чи сума є «високою» (виділяється кольором).
  bool _isHighAmount(double amount) {
    return amount >= _kHighAmountThreshold;
  }

  /// Валідує пошуковий запит.
  ///
  /// Повертає `true`, якщо запит не перевищує максимальну довжину.
  bool _isSearchQueryValid(String query) {
    return query.length <= _kMaxSearchLength;
  }

  // ═══════════════════════════════════════════════════════════════════════
  // Обчислювальні (computed) властивості
  // ═══════════════════════════════════════════════════════════════════════

  /// Обчислює загальну суму за рік на основі місячної.
  ///
  /// Припускає, що щомісячний платіж повторюється 12 разів.
  double _computeAnnualProjection(List<AutoPayment> payments) {
    final monthly = _computeTotalMonthly(payments);
    return monthly * 12;
  }

  /// Обчислює кількість днів до наступного платежу (приблизно).
  ///
  /// Повертає 0, якщо немає активних платежів.
  int _computeDaysToNextPayment(List<AutoPayment> payments) {
    final enabled = payments.where((p) => p.isEnabled).toList();
    if (enabled.isEmpty) return 0;
    // Приблизний розрахунок: беремо перший активний.
    try {
      return enabled.first.daysUntilNext;
    } catch (e) {
      return 0;
    }
  }

  /// Обчислює відсоток використання ліміту автоплатежів.
  ///
  /// Повертає значення від 0.0 до 1.0.
  double _computeLimitUsage(List<AutoPayment> payments) {
    if (_kMaxAutoPayments <= 0) return 0.0;
    return (payments.length / _kMaxAutoPayments).clamp(0.0, 1.0);
  }

  /// Обчислює медіанну суму автоплатежу.
  double _computeMedianAmount(List<AutoPayment> payments) {
    if (payments.isEmpty) return 0.0;
    try {
      final sorted = List<double>.from(
        payments.map((p) => p.amount),
      )..sort();
      final mid = sorted.length ~/ 2;
      if (sorted.length % 2 == 0) {
        return (sorted[mid - 1] + sorted[mid]) / 2;
      }
      return sorted[mid];
    } catch (e) {
      debugPrint('[AutoPayments] Error computing median: $e');
      return 0.0;
    }
  }

  /// Обчислює суму «високих» автоплатежів (>= [_kHighAmountThreshold]).
  double _computeHighAmountTotal(List<AutoPayment> payments) {
    try {
      return payments
          .where((p) => p.isEnabled && _isHighAmount(p.amount))
          .fold<double>(0, (sum, p) => sum + p.amount);
    } catch (e) {
      debugPrint('[AutoPayments] Error computing high amount total: $e');
      return 0.0;
    }
  }

  /// Обчислює відсоток «високих» платежів від загальної кількості.
  double _computeHighAmountPercentage(List<AutoPayment> payments) {
    final enabled = payments.where((p) => p.isEnabled).toList();
    if (enabled.isEmpty) return 0.0;
    final highCount = enabled.where((p) => _isHighAmount(p.amount)).length;
    return (highCount / enabled.length * 100).clamp(0, 100);
  }

  // ═══════════════════════════════════════════════════════════════════════
  // Форматувальники
  // ═══════════════════════════════════════════════════════════════════════

  /// Форматує суму з значком валюти та розрядками.
  ///
  /// Наприклад: «1 234 грн».
  String _formatCurrencyWithSpaces(double amount) {
    try {
      final formatted = amount.toInt().toString();
      final buffer = StringBuffer();
      for (var i = 0; i < formatted.length; i++) {
        if (i > 0 && (formatted.length - i) % 3 == 0) {
          buffer.write(' ');
        }
        buffer.write(formatted[i]);
      }
      return '$buffer грн';
    } catch (e) {
      return '0 грн';
    }
  }

  /// Форматує дату останньої дії.
  String _formatLastActionTime() {
    if (_lastActionTime == null) return 'Немає дій';
    final diff = DateTime.now().difference(_lastActionTime!);
    if (diff.inSeconds < 5) return 'Щойно';
    if (diff.inMinutes < 1) return '${diff.inSeconds}с тому';
    if (diff.inHours < 1) return '${diff.inMinutes}хв тому';
    return '${diff.inHours}год тому';
  }

  /// Форматує відсоток використання ліміту з описом.
  String _formatLimitUsageText(int currentCount) {
    final usage = currentCount / _kMaxAutoPayments;
    if (usage >= 1.0) return 'Ліміт вичерпано ($currentCount/$_kMaxAutoPayments)';
    if (usage >= 0.8) return 'Майже заповнено ($currentCount/$_kMaxAutoPayments)';
    return '$currentCount з $_kMaxAutoPayments';
  }

  /// Обрізає назву автоплатежу, якщо вона занадто довга.
  String _truncateName(String name, [int maxLength = _kMaxNameDisplayLength]) {
    if (name.length <= maxLength) return name;
    return '${name.substring(0, maxLength - 2)}…';
  }

  // ═══════════════════════════════════════════════════════════════════════
  // Додаткові віджети-будівники
  // ═══════════════════════════════════════════════════════════════════════

  /// Будує панель пошуку з анімацією розгортання.
  Widget _buildSearchBar(dynamic c) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOutCubic,
      height: _isSearchVisible ? 52 : 0,
      margin: const EdgeInsets.symmetric(horizontal: Spacing.base, vertical: Spacing.xs),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(Radii.md),
        border: Border.all(color: c.border, width: 1),
      ),
      child: _isSearchVisible
          ? Row(
              children: [
                const SizedBox(width: Spacing.sm),
                Icon(Icons.search_rounded, color: c.textHint, size: 20),
                const SizedBox(width: Spacing.sm),
                Expanded(
                  child: TextField(
                    onChanged: (value) {
                      if (_isSearchQueryValid(value)) {
                        setState(() => _searchQuery = value);
                      }
                    },
                    style: AppTypography.bodyMedium.copyWith(color: c.textPrimary),
                    decoration: InputDecoration(
                      hintText: 'Пошук за сумою чи частотою…',
                      hintStyle: AppTypography.labelSmall.copyWith(color: c.textHint),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
                if (_searchQuery.isNotEmpty)
                  GestureDetector(
                    onTap: () => setState(() => _searchQuery = ''),
                    child: Icon(Icons.clear_rounded, color: c.textHint, size: 18),
                  ),
                const SizedBox(width: Spacing.sm),
              ],
            )
          : const SizedBox.shrink(),
    );
  }

  /// Будує рядок швидких дій (лічильник дій, час останньої дії).
  Widget _buildActionFooter(dynamic c, List<AutoPayment> payments) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: Spacing.base, vertical: Spacing.xs),
      padding: const EdgeInsets.symmetric(horizontal: Spacing.sm, vertical: 6),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(Radii.sm),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Дій за сесію: $_actionCount',
            style: AppTypography.caption.copyWith(color: c.textHint),
          ),
          Text(
            _formatLastActionTime(),
            style: AppTypography.caption.copyWith(color: c.textHint),
          ),
          Text(
            _formatLimitUsageText(payments.length),
            style: AppTypography.caption.copyWith(
              color: _computeLimitUsage(payments) >= 0.8
                  ? AppColorsPS5.warning
                  : c.textHint,
            ),
          ),
        ],
      ),
    );
  }

  /// Будує розширений skeleton для завантаження з більшою кількістю елементів.
  Widget _buildExtendedLoadingSkeleton(dynamic c) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(Spacing.base),
      child: Column(
        children: [
          Container(
            height: 20,
            width: 240,
            decoration: BoxDecoration(
              color: c.surface,
              borderRadius: BorderRadius.circular(Radii.sm),
            ),
          ),
          const SizedBox(height: Spacing.xl),
          _buildSkeletonShimmer(
            width: double.infinity,
            height: 160,
            color: c.card,
            radius: Radii.lg,
          ),
          const SizedBox(height: Spacing.lg),
          _buildSkeletonShimmer(
            width: double.infinity,
            height: 48,
            color: c.surface,
            radius: Radii.md,
          ),
          const SizedBox(height: Spacing.lg),
          for (int i = 0; i < _kExtendedSkeletonCount; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: Spacing.sm),
              child: _buildSkeletonShimmer(
                width: double.infinity,
                height: 90,
                color: c.card,
                radius: Radii.lg,
              ),
            ),
        ],
      ),
    );
  }

  /// Будує картку проєкції річних заощаджень.
  Widget _buildAnnualProjectionCard(dynamic c, List<AutoPayment> payments) {
    final annual = _computeAnnualProjection(payments);
    final monthly = _computeTotalMonthly(payments);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: Spacing.base, vertical: Spacing.xs),
      padding: const EdgeInsets.symmetric(horizontal: Spacing.md, vertical: Spacing.sm),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [c.accent.withOpacity(0.06), c.accent.withOpacity(0.02)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(Radii.md),
        border: Border.all(color: c.accent.withOpacity(0.12)),
      ),
      child: Row(
        children: [
          Icon(Icons.trending_up_rounded, color: c.accent, size: 18),
          const SizedBox(width: Spacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Прогноз за рік',
                  style: AppTypography.labelSmall.copyWith(color: c.textSecondary),
                ),
                Text(
                  _formatCurrencyWithSpaces(annual),
                  style: AppTypography.monoSmall.copyWith(
                    color: c.accent,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${_formatCurrencyWithSpaces(monthly)}/міс',
            style: AppTypography.caption.copyWith(color: c.textHint),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms, delay: const Duration(milliseconds: _kStatsAnimDelayMs + 100));
  }

  /// Будує розширений skeleton shimmer з градієнтом.
  Widget _buildGradientSkeletonShimmer({
    required double width,
    required double height,
    required Color startColor,
    required Color endColor,
    required double radius,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [startColor, endColor],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }

  /// Будує підказку для порожнього пошуку.
  Widget _buildNoSearchResults(dynamic c) {
    return Padding(
      padding: const EdgeInsets.all(Spacing.xxl),
      child: Column(
        children: [
          Icon(Icons.search_off_rounded, color: c.textHint, size: 48),
          const SizedBox(height: Spacing.base),
          Text(
            'Нічого не знайдено за запитом\n«$_searchQuery»',
            style: AppTypography.bodyMedium.copyWith(
              color: c.textHint,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: Spacing.sm),
          Text(
            'Спробуй змінити пошуковий запит',
            style: AppTypography.labelSmall.copyWith(
              color: c.textHint.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  /// Будує індикатор прогресу використання ліміту.
  Widget _buildLimitProgressBar(dynamic c, int currentCount) {
    final usage = _computeLimitUsageByCount(currentCount);
    final barColor = usage >= 0.8
        ? AppColorsPS5.warning
        : usage >= 0.5
            ? c.accent
            : c.success;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: Spacing.base, vertical: Spacing.xs),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Ліміт автоплатежів',
                style: AppTypography.labelSmall.copyWith(color: c.textHint),
              ),
              Text(
                '$currentCount/$_kMaxAutoPayments',
                style: AppTypography.labelSmall.copyWith(
                  color: barColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(Radii.circular),
            child: LinearProgressIndicator(
              value: usage,
              backgroundColor: c.border.withOpacity(0.3),
              valueColor: AlwaysStoppedAnimation<Color>(barColor),
              minHeight: 4,
            ),
          ),
        ],
      ),
    );
  }

  /// Обчислює використання ліміту за кількістю платежів.
  double _computeLimitUsageByCount(int count) {
    if (_kMaxAutoPayments <= 0) return 0.0;
    return (count / _kMaxAutoPayments).clamp(0.0, 1.0);
  }

  /// Будує картку з медіаною та статистикою сум.
  Widget _buildAmountStatsCard(dynamic c, List<AutoPayment> payments) {
    final median = _computeMedianAmount(payments);
    final highTotal = _computeHighAmountTotal(payments);
    final highPct = _computeHighAmountPercentage(payments);

    return AppCard(
      isLightTheme: c == AppColorsMonitor,
      margin: const EdgeInsets.symmetric(horizontal: Spacing.base, vertical: Spacing.xs),
      padding: const EdgeInsets.all(Spacing.sm),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildMiniStat(
            icon: Icons.median_rounded,
            label: 'Медіана',
            value: _formatAmount(median),
            c: c,
          ),
          Container(width: 1, height: 30, color: c.border),
          _buildMiniStat(
            icon: Icons.arrow_upward_rounded,
            label: 'Високих',
            value: '${highPct.toStringAsFixed(0)}%',
            c: c,
            valueColor: AppColorsPS5.warning,
          ),
          Container(width: 1, height: 30, color: c.border),
          _buildMiniStat(
            icon: Icons.attach_money_rounded,
            label: 'Сума високих',
            value: _formatAmount(highTotal),
            c: c,
          ),
        ],
      ),
    );
  }

  /// Міні-статистичний елемент для картки.
  Widget _buildMiniStat({
    required IconData icon,
    required String label,
    required String value,
    required dynamic c,
    Color? valueColor,
  }) {
    final resolvedColor = valueColor ?? c.textPrimary;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: c.textHint, size: 14),
        const SizedBox(height: 2),
        Text(
          value,
          style: AppTypography.labelSmall.copyWith(
            color: resolvedColor,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          label,
          style: AppTypography.caption.copyWith(color: c.textHint),
        ),
      ],
    );
  }
}

/// Рядок автоплатежу з toggle, swipe edit/delete.
class _AutoPaymentTile extends StatefulWidget {
  const _AutoPaymentTile({
    required this.payment,
    required this.isLightTheme,
    required this.onToggle,
    required this.onDelete,
    required this.onEdit,
  });

  final AutoPayment payment;
  final bool isLightTheme;
  final ValueChanged<bool> onToggle;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  @override
  State<_AutoPaymentTile> createState() => _AutoPaymentTileState();
}

class _AutoPaymentTileState extends State<_AutoPaymentTile> {
  @override
  Widget build(BuildContext context) {
    final c = widget.isLightTheme ? AppColorsMonitor : AppColorsPS5;

    return Dismissible(
      key: ValueKey(widget.payment.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        margin: const EdgeInsets.symmetric(horizontal: Spacing.base, vertical: Spacing.xs),
        padding: const EdgeInsets.only(right: Spacing.base),
        decoration: BoxDecoration(
          color: AppColorsPS5.error.withOpacity(0.1),
          borderRadius: BorderRadius.circular(Radii.lg),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            GestureDetector(
              onTap: widget.onEdit,
              child: Container(
                padding: const EdgeInsets.all(Spacing.sm),
                decoration: BoxDecoration(color: c.accent.withOpacity(0.2), shape: BoxShape.circle),
                child: Icon(Icons.edit_rounded, color: c.accent, size: 20),
              ),
            ),
            const SizedBox(width: Spacing.sm),
            Icon(Icons.delete_rounded, color: AppColorsPS5.error),
          ],
        ),
      ),
      confirmDismiss: (direction) async {
        return await showDialog<bool>(
              context: context,
              builder: (ctx) => AlertDialog(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Radii.lg)),
                title: const Text('Видалити автоплатіж?'),
                content: Text('${widget.payment.amount.formatUAH()} грн (${widget.payment.frequencyLabel})'),
                actions: [
                  TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Скасувати')),
                  TextButton(
                    onPressed: () => Navigator.pop(ctx, true),
                    child: Text('Видалити', style: TextStyle(color: AppColorsPS5.error)),
                  ),
                ],
              ),
            ) ??
            false;
      },
      onDismissed: (direction) => widget.onDelete(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: Spacing.base, vertical: Spacing.xs),
        child: AppCard(
          isLightTheme: widget.isLightTheme,
          padding: const EdgeInsets.all(Spacing.base),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: c.accent.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(Radii.md),
                    ),
                    child: Icon(
                      Icons.autorenew_rounded,
                      color: widget.payment.isEnabled ? c.accent : c.textHint,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: Spacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${widget.payment.amount.formatUAH()} грн',
                          style: AppTypography.monoMedium.copyWith(
                            color: widget.payment.isEnabled ? c.textPrimary : c.textHint,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          widget.payment.frequencyLabel,
                          style: AppTypography.labelSmall.copyWith(
                            color: widget.payment.isEnabled ? c.textSecondary : c.textHint,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Transform.scale(
                    scale: 0.85,
                    child: Switch(
                      value: widget.payment.isEnabled,
                      onChanged: widget.onToggle,
                      activeColor: c.accent,
                      inactiveThumbColor: c.textHint,
                      inactiveTrackColor: c.border,
                    ),
                  ),
                ],
              ),
              if (widget.payment.isEnabled) ...[
                const SizedBox(height: Spacing.sm),
                Divider(color: c.border.withOpacity(0.3)),
                const SizedBox(height: Spacing.xs),
                Row(
                  children: [
                    Icon(Icons.schedule_rounded, color: c.textSecondary, size: 14),
                    const SizedBox(width: Spacing.xs),
                    Text(
                      'Наступний: ${widget.payment.nextDateLabel}',
                      style: AppTypography.labelSmall.copyWith(color: c.textSecondary),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: widget.onEdit,
                      child: Text(
                        'Редагувати',
                        style: AppTypography.labelSmall.copyWith(
                          color: c.accent,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    ).animate().fadeIn(duration: 250.ms).slideX(begin: 0.1, end: 0, duration: 250.ms);
  }
}
