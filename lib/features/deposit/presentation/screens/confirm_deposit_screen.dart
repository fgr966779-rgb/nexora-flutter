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
import '../../../../core/utils/haptic_service.dart';
import '../../../../core/widgets/app_button_primary.dart';
import '../../../../core/widgets/app_button_secondary.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../providers/deposit_provider.dart';
import '../../providers/dashboard_provider.dart';
import 'success_animation_screen.dart';

/// Модальне нижнє вікно підтвердження внеску з превʼю балансу та відсотків.
///
/// Містить: картку з сумою, типом, коментарем, балансом, відсотком;
/// кнопки «Скасувати» та «Підтвердити» з morph-анімацією;
/// shake-анімацію при помилці; розширену інформацію про XP/монети;
/// інтерактивний прогрес-бар; стан завантаження та помилки;
/// редагування суми, вибір методу внеску, біометричне підтвердження,
/// картку підсумку, розрахунок комісій, інформацію про заплановані внески,
/// анімацію скасування, попередній перегляд успіху, вибір методів внеску
/// (ручний/округлення/автоматичний/виклик), детальний розрахунок комісій,
/// діалог підтвердження скасування, картку чеку.
class ConfirmDepositScreen extends StatefulWidget {
  const ConfirmDepositScreen({
    super.key,
    required this.amount,
    required this.comment,
    this.isLightTheme = false,
  });

  final double amount;
  final String comment;
  final bool isLightTheme;

  @override
  State<ConfirmDepositScreen> createState() => _ConfirmDepositScreenState();
}

class _ConfirmDepositScreenState extends State<ConfirmDepositScreen>
    with SingleTickerProviderStateMixin {
  bool _isProcessing = false;
  bool _hasError = false;
  String _errorMessage = '';
  bool _isEditing = false;
  bool _showSuccessPreview = false;
  String _selectedMethod = 'Готівка';
  bool _biometricReady = false;
  bool _biometricConfirmed = false;
  bool _isCancelling = false;
  double _editedAmount = 0;
  String _depositType = 'manual';
  bool _showFeeDetails = false;
  bool _showRecurrenceInfo = false;
  bool _showCancelDialog = false;

  static const _depositMethods = [
    ('Готівка', Icons.payments_rounded),
    ('Картка', Icons.credit_card_rounded),
    ('Переказ', Icons.account_balance_rounded),
    ('Подарунок', Icons.card_giftcard_rounded),
  ];

  static const _depositTypes = [
    ('Вручну', Icons.touch_app_rounded, 'Ручний внесок коштів'),
    ('Округлення', Icons.sync_rounded, 'Автоматичне округлення залишків'),
    ('Автоматичний', Icons.autorenew_rounded, 'Запланований регулярний внесок'),
    ('Виклик', Icons.emoji_events_rounded, 'Внесок під час виклику/змагання'),
  ];

  static const _feeTiers = {
    'Готівка': 0.0,
    'Картка': 0.005,
    'Переказ': 0.0,
    'Подарунок': 0.0,
  };

  static const _feeDetails = {
    'Готівка': 'Без комісії — готівковий внесок безкоштовний',
    'Картка': 'Комісія 0.5% покриває витрати платіжної системи',
    'Переказ': 'Без комісії — прямий банківський переказ',
    'Подарунок': 'Без комісії — подарункові кошти не оподатковуються',
  };

  static const _recurrenceInfo = {
    'manual': 'Одиничний внесок — без повторень',
    'roundup': 'Щоденне округлення — автоматично після кожної покупки',
    'auto': 'Щотижня — кожного понеділка о 09:00',
    'challenge': 'За умовою виклику — після виконання умови',
  };

  static const _processingSteps = [
    'Перевірка даних...',
    'Обробка платежу...',
    'Оновлення балансу...',
    'Збереження запису...',
    'Нарахування XP...',
  ];

  static const _methodDescriptions = {
    'Готівка': 'Внесення готівки безпосередньо в скарбничку',
    'Картка': 'Оплата банківською карткою з мінімальною комісією',
    'Переказ': 'Прямий банківський переказ без комісії',
    'Подарунок': 'Отримані подарункові кошти від рідних чи друзів',
  };

  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;
  late AnimationController _morphController;
  late AnimationController _cancelController;

  @override
  void initState() {
    super.initState();
    _editedAmount = widget.amount;

    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _shakeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.elasticIn),
    );

    _morphController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _cancelController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    // Симуляція перевірки біометрії
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) setState(() => _biometricReady = true);
    });
  }

  @override
  void dispose() {
    _shakeController.dispose();
    _morphController.dispose();
    _cancelController.dispose();
    super.dispose();
  }

  double get _fee {
    final rate = _feeTiers[_selectedMethod] ?? 0;
    return _editedAmount * rate;
  }

  double get _netAmount => _editedAmount - _fee;

  int get _xpReward => (_editedAmount ~/ 100).clamp(5, 50);

  int get _coinReward => (_editedAmount ~/ 200).clamp(1, 25);

  void _showError(String? message) {
    HapticService.error();
    setState(() {
      _hasError = true;
      _errorMessage = message ?? 'Невідома помилка. Спробуй ще раз.';
    });
    _shakeController.forward(from: 0);
  }

  void _onEditAmount() {
    HapticService.selection();
    setState(() => _isEditing = true);
  }

  void _confirmEdit() {
    HapticService.lightTap();
    setState(() => _isEditing = false);
  }

  void _onBiometricTap() {
    HapticService.mediumTap();
    setState(() => _biometricConfirmed = true);
    AppToast.show(context, message: '✅ Біометрія підтверджена!', icon: Icons.fingerprint_rounded, color: AppColorsPS5.success);
  }

  void _onCancelTap() {
    if (_isProcessing) return;
    HapticService.lightTap();
    setState(() => _showCancelDialog = true);
  }

  void _confirmCancel() {
    Navigator.of(context).pop();
  }

  void _dismissCancelDialog() {
    HapticService.lightTap();
    setState(() => _showCancelDialog = false);
  }

  Future<void> _onConfirm(BuildContext context) async {
    if (_isProcessing) return;
    HapticService.success();

    setState(() {
      _isProcessing = true;
      _hasError = false;
    });

    _morphController.forward();

    final depositProvider = context.read<DepositProvider>();
    final dashboardProvider = context.read<DashboardProvider>();

    try {
      await dashboardProvider.addDeposit(
        amount: _editedAmount,
        comment: widget.comment,
      );

      if (!mounted) return;
      setState(() => _showSuccessPreview = true);
      await Future.delayed(const Duration(milliseconds: 800));
      Navigator.of(context).pop();

      SuccessAnimationOverlay.show(
        context,
        amount: _editedAmount,
        xpEarned: _xpReward,
        coinsEarned: _coinReward,
      );

      AppToast.show(
        context,
        message: '+${_editedAmount.toInt()} грн додано!',
        icon: Icons.check_circle_rounded,
        color: AppColorsPS5.success,
      );
    } catch (e) {
      if (!mounted) return;
      _showError(e.toString());
      setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.isLightTheme ? AppColorsMonitor : AppColorsPS5;

    return Stack(
      children: [
        AnimatedBuilder(
          animation: _shakeAnimation,
          builder: (context, child) {
            final shakeOffset = _hasError
                ? (Curves.elasticIn.transform(_shakeController.value) * 10 * (1 - _shakeController.value))
                : 0.0;
            return Transform.translate(offset: Offset(shakeOffset, 0), child: child);
          },
          child: AnimatedBuilder(
            animation: _cancelController,
            builder: (context, child) {
              final scale = 1.0 - _cancelController.value * 0.05;
              final opacity = 1.0 - _cancelController.value * 0.3;
              return Transform.scale(scale: scale, child: Opacity(opacity: opacity, child: child));
            },
            child: Container(
              decoration: BoxDecoration(
                color: c.card,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(Radii.xl)),
              ),
              padding: EdgeInsets.only(
                left: Spacing.base, right: Spacing.base, top: Spacing.sm,
                bottom: MediaQuery.of(context).viewInsets.bottom + Spacing.base,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Drag handle
                  Center(child: Container(width: 40, height: 4, margin: const EdgeInsets.only(bottom: Spacing.lg), decoration: BoxDecoration(color: c.textHint.withOpacity(0.5), borderRadius: BorderRadius.circular(2)))),
                  // Title
                  Text('Підтвердження', style: AppTypography.heading1.copyWith(color: c.textPrimary)).animate().fadeIn(duration: 200.ms),
                  const SizedBox(height: Spacing.xl),
                  // Card with deposit details
                  _buildDetailCard(context, c),
                  // Error message
                  if (_hasError)
                    Padding(
                      padding: const EdgeInsets.only(top: Spacing.sm),
                      child: Container(
                        padding: const EdgeInsets.all(Spacing.sm),
                        decoration: BoxDecoration(color: AppColorsPS5.error.withOpacity(0.08), borderRadius: BorderRadius.circular(Radii.sm), border: Border.all(color: AppColorsPS5.error.withOpacity(0.2))),
                        child: Row(children: [
                          Icon(Icons.error_outline_rounded, color: AppColorsPS5.error, size: 16),
                          const SizedBox(width: Spacing.sm),
                          Expanded(child: Text(_errorMessage, style: AppTypography.labelSmall.copyWith(color: AppColorsPS5.error))),
                        ]),
                      ).animate().fadeIn(duration: 200.ms),
                    ),
                  const SizedBox(height: Spacing.xxl),
                  // Buttons
                  _buildButtons(c),
                  const SizedBox(height: Spacing.sm),
                ],
              ),
            ),
          ),
        ),
        // Діалог скасування
        if (_showCancelDialog) _buildCancelDialog(c),
      ],
    );
  }

  Widget _buildCancelDialog(dynamic c) {
    return Positioned.fill(
      child: Container(
        color: Colors.black.withOpacity(0.5),
        child: Center(
          child: Container(
            width: 300,
            padding: const EdgeInsets.all(Spacing.xl),
            decoration: BoxDecoration(color: c.card, borderRadius: BorderRadius.circular(Radii.lg)),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.warning_amber_rounded, color: AppColorsPS5.warning, size: 40),
                const SizedBox(height: Spacing.md),
                Text('Скасувати внесок?', style: AppTypography.heading3.copyWith(color: c.textPrimary)),
                const SizedBox(height: Spacing.sm),
                Text('Ти впевнений? Внесок на ${_editedAmount.toInt()} грн не буде збережено.', style: AppTypography.bodyMedium.copyWith(color: c.textSecondary), textAlign: TextAlign.center),
                const SizedBox(height: Spacing.xl),
                Row(children: [
                  Expanded(child: AppButtonSecondary(label: 'Продовжити', onPressed: _dismissCancelDialog, isLightTheme: widget.isLightTheme)),
                  const SizedBox(width: Spacing.sm),
                  Expanded(child: AppButtonPrimary(label: 'Скасувати', onPressed: _confirmCancel, isLightTheme: widget.isLightTheme, showGlow: false)),
                ]),
              ],
            ),
          ).animate().scale(duration: 200.ms, curve: Curves.easeOutBack),
        ),
      ),
    ).animate().fadeIn(duration: 150.ms);
  }

  Widget _buildDetailCard(BuildContext context, dynamic c) {
    final dashboardProvider = context.watch<DashboardProvider>();
    final currentAmount = dashboardProvider.currentAmount;
    final targetAmount = dashboardProvider.targetAmount;
    final newBalance = currentAmount + _editedAmount;
    final newPercentage = targetAmount > 0 ? ((newBalance / targetAmount) * 100).clamp(0, 100) : 0.0;
    final oldPercentage = targetAmount > 0 ? ((currentAmount / targetAmount) * 100).clamp(0, 100) : 0.0;
    final gained = newPercentage - oldPercentage;

    return AppCard(
      isLightTheme: widget.isLightTheme,
      padding: const EdgeInsets.all(Spacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Сума з можливістю редагування
          Center(
            child: Column(children: [
              if (_isEditing)
                Container(
                  width: 200,
                  padding: const EdgeInsets.symmetric(horizontal: Spacing.base, vertical: Spacing.xs),
                  decoration: BoxDecoration(color: c.accent.withOpacity(0.08), borderRadius: BorderRadius.circular(Radii.md), border: Border.all(color: c.accent)),
                  child: TextField(
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    autofocus: true,
                    style: AppTypography.monoLarge.copyWith(color: c.accent, fontWeight: FontWeight.w800, fontSize: 36),
                    textAlign: TextAlign.center,
                    decoration: const InputDecoration(border: InputBorder.none),
                    onSubmitted: (_) => _confirmEdit(),
                  ),
                )
              else
                GestureDetector(
                  onTap: _onEditAmount,
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Text('+${_editedAmount.formatUAH()}', style: AppTypography.monoLarge.copyWith(fontSize: 40, color: c.success, fontWeight: FontWeight.w800, letterSpacing: -1))
                        .animate().fadeIn(duration: 300.ms, delay: 100.ms).slideY(begin: 0.2, end: 0, duration: 300.ms, delay: 100.ms, curve: AppEasings.spring),
                    const SizedBox(width: Spacing.xs),
                    Icon(Icons.edit_rounded, color: c.textHint, size: 16),
                  ]),
                ),
              const SizedBox(height: Spacing.xs),
              Text('грн', style: AppTypography.bodyMedium.copyWith(color: c.textSecondary)),
            ]),
          ),
          const SizedBox(height: Spacing.lg),
          // Тип внеску — картки вибору
          Center(
            child: Column(children: [
              Text('Тип внеску', style: AppTypography.labelSmall.copyWith(color: c.textHint)),
              const SizedBox(height: Spacing.xs),
              Wrap(spacing: Spacing.xs, runSpacing: Spacing.xs, children: _depositTypes.map((t) {
                final isActive = _depositType == t.$1;
                return GestureDetector(
                  onTap: () { HapticService.selection(); setState(() => _depositType = t.$1); },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: Spacing.sm, vertical: 6),
                    decoration: BoxDecoration(color: isActive ? c.accent : Colors.transparent, borderRadius: BorderRadius.circular(Radii.circular), border: Border.all(color: isActive ? c.accent : c.border)),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Icon(t.$2, color: isActive ? Colors.white : c.textSecondary, size: 14),
                      const SizedBox(width: 4),
                      Text(t.$1, style: AppTypography.labelSmall.copyWith(color: isActive ? Colors.white : c.textPrimary, fontWeight: isActive ? FontWeight.w600 : FontWeight.w400, fontSize: 11)),
                    ]),
                  ),
                );
              }).toList()),
              // Опис обраного типу
              if (_depositType != 'manual')
                Padding(
                  padding: const EdgeInsets.only(top: Spacing.xs),
                  child: Text(_depositTypes.firstWhere((t) => t.$1 == _depositType).$3, style: AppTypography.labelSmall.copyWith(color: c.accent, fontSize: 10, fontStyle: FontStyle.italic)),
                ),
            ]),
          ),
          const SizedBox(height: Spacing.sm),
          // Метод внеску
          Center(
            child: Column(children: [
              Text('Метод оплати', style: AppTypography.labelSmall.copyWith(color: c.textHint)),
              const SizedBox(height: Spacing.xs),
              Wrap(spacing: Spacing.xs, runSpacing: Spacing.xs, children: _depositMethods.map((m) {
                final isActive = _selectedMethod == m.$1;
                return GestureDetector(
                  onTap: () { HapticService.selection(); setState(() => _selectedMethod = m.$1); },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: Spacing.sm, vertical: 6),
                    decoration: BoxDecoration(color: isActive ? c.accent : Colors.transparent, borderRadius: BorderRadius.circular(Radii.circular), border: Border.all(color: isActive ? c.accent : c.border)),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Icon(m.$2, color: isActive ? Colors.white : c.textSecondary, size: 14),
                      const SizedBox(width: 4),
                      Text(m.$1, style: AppTypography.labelSmall.copyWith(color: isActive ? Colors.white : c.textPrimary, fontWeight: isActive ? FontWeight.w600 : FontWeight.w400, fontSize: 11)),
                    ]),
                  ),
                );
              }).toList()),
            ]),
          ),
          // Деталі комісії (розширений)
          const SizedBox(height: Spacing.sm),
          GestureDetector(
            onTap: () { HapticService.selection(); setState(() => _showFeeDetails = !_showFeeDetails); },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: Spacing.sm, vertical: Spacing.xs),
              decoration: BoxDecoration(color: c.accent.withOpacity(0.03), borderRadius: BorderRadius.circular(Radii.sm)),
              child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(_showFeeDetails ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded, color: c.accent, size: 14),
                const SizedBox(width: Spacing.xs),
                Text('Деталі комісії та методу', style: AppTypography.labelSmall.copyWith(color: c.accent, fontSize: 10)),
              ]),
            ),
          ),
          if (_fee > 0 || _showFeeDetails)
            Container(
              margin: const EdgeInsets.only(top: Spacing.xs),
              padding: const EdgeInsets.all(Spacing.sm),
              decoration: BoxDecoration(color: AppColorsPS5.warning.withOpacity(0.06), borderRadius: BorderRadius.circular(Radii.sm), border: Border.all(color: AppColorsPS5.warning.withOpacity(0.12))),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                if (_fee > 0) Text('⚠️ Комісія: ${_fee.toStringAsFixed(1)} грн · На рахунок: ${_netAmount.toInt()} грн', style: AppTypography.labelSmall.copyWith(color: AppColorsPS5.warning)),
                Text(_feeDetails[_selectedMethod] ?? '', style: AppTypography.labelSmall.copyWith(color: c.textHint, fontSize: 10)),
                const SizedBox(height: Spacing.xs),
                Text(_methodDescriptions[_selectedMethod] ?? '', style: AppTypography.labelSmall.copyWith(color: c.textSecondary, fontSize: 10, fontStyle: FontStyle.italic)),
                const SizedBox(height: Spacing.xs),
                Text('Ставка комісії: ${(_feeTiers[_selectedMethod] ?? 0) * 100}%', style: AppTypography.labelSmall.copyWith(color: c.textHint, fontSize: 10)),
              ]),
            ),
          // Кроки обробки (візуалізація)
          if (_isProcessing)
            Container(
              margin: const EdgeInsets.only(top: Spacing.sm),
              padding: const EdgeInsets.all(Spacing.sm),
              decoration: BoxDecoration(color: c.accent.withOpacity(0.04), borderRadius: BorderRadius.circular(Radii.sm)),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Кроки обробки:', style: AppTypography.labelSmall.copyWith(color: c.accent, fontWeight: FontWeight.w600, fontSize: 10)),
                const SizedBox(height: Spacing.xs),
                ..._processingSteps.asMap().entries.map((e) => Padding(
                  padding: const EdgeInsets.only(bottom: 2),
                  child: Row(children: [
                    Icon(Icons.check_circle_rounded, color: e.key < _processingSteps.length * _morphController.value ? AppColorsPS5.success : c.border, size: 10),
                    const SizedBox(width: Spacing.xs),
                    Text(e.value, style: AppTypography.labelSmall.copyWith(color: e.key < _processingSteps.length * _morphController.value ? c.textSecondary : c.textHint, fontSize: 9)),
                  ]),
                )),
              ]),
            ),
          // Коментар
          if (widget.comment.isNotEmpty) ...[
            const SizedBox(height: Spacing.base),
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: Spacing.base, vertical: Spacing.sm),
                decoration: BoxDecoration(color: c.surface, borderRadius: BorderRadius.circular(Radii.md), border: Border.all(color: c.border, width: 0.5)),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.chat_bubble_outline_rounded, color: c.textHint, size: 14),
                  const SizedBox(width: Spacing.xs),
                  Flexible(child: Text('"${widget.comment}"', style: AppTypography.bodyMedium.copyWith(color: c.textSecondary, fontStyle: FontStyle.italic), textAlign: TextAlign.center, overflow: TextOverflow.ellipsis)),
                ]),
              ),
            ),
          ],
          const SizedBox(height: Spacing.lg),
          Divider(color: c.border, thickness: 1),
          const SizedBox(height: Spacing.base),
          // Інформаційні рядки
          _buildInfoRow(c: c, label: 'Новий баланс', value: '${newBalance.formatUAH()} грн', valueColor: c.textPrimary, icon: Icons.account_balance_wallet_rounded),
          const SizedBox(height: Spacing.sm),
          _buildInfoRow(c: c, label: 'Прогрес', value: '${newPercentage.toStringAsFixed(1)}%', valueColor: c.accent, icon: Icons.pie_chart_rounded, trailing: gained > 0 ? Text('+${gained.toStringAsFixed(1)}%', style: AppTypography.labelSmall.copyWith(color: c.success, fontWeight: FontWeight.w600)) : null),
          const SizedBox(height: Spacing.sm),
          _buildInfoRow(c: c, label: 'Цей внесок', value: '${_editedAmount.formatUAH()} грн', valueColor: c.success, icon: Icons.trending_up_rounded),
          if (_fee > 0)
            _buildInfoRow(c: c, label: 'Комісія', value: '-${_fee.toStringAsFixed(1)} грн', valueColor: AppColorsPS5.warning, icon: Icons.receipt_long_rounded),
          const SizedBox(height: Spacing.sm),
          _buildInfoRow(c: c, label: 'XP за внесок', value: '+$_xpReward XP', valueColor: AppColorsPS5.xp, icon: Icons.star_rounded),
          const SizedBox(height: Spacing.sm),
          _buildInfoRow(c: c, label: 'Монети', value: '+$_coinReward', valueColor: AppColorsPS5.coin, icon: Icons.monetization_on_rounded),
          // Запланований внесок info
          const SizedBox(height: Spacing.sm),
          _buildRecurrenceSection(c),
          // Мотиваційна підказка
          const SizedBox(height: Spacing.sm),
          Container(
            padding: const EdgeInsets.all(Spacing.sm),
            decoration: BoxDecoration(color: AppColorsPS5.success.withOpacity(0.06), borderRadius: BorderRadius.circular(Radii.sm), border: Border.all(color: AppColorsPS5.success.withOpacity(0.12))),
            child: Row(children: [
              Icon(Icons.auto_awesome_rounded, color: AppColorsPS5.success, size: 14),
              const SizedBox(width: Spacing.sm),
              Expanded(child: Text('Внесок наближає тебе до цілі!', style: AppTypography.labelSmall.copyWith(color: AppColorsPS5.success))),
            ]),
          ),
          // Біометричне підтвердження
          if (_biometricReady && !_biometricConfirmed)
            Center(
              child: GestureDetector(
                onTap: _onBiometricTap,
                child: Container(
                  margin: const EdgeInsets.only(top: Spacing.base),
                  padding: const EdgeInsets.symmetric(horizontal: Spacing.base, vertical: Spacing.md),
                  decoration: BoxDecoration(color: c.accent.withOpacity(0.06), borderRadius: BorderRadius.circular(Radii.md), border: Border.all(color: c.accent.withOpacity(0.15))),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(Icons.fingerprint_rounded, color: c.accent, size: 24),
                    const SizedBox(width: Spacing.sm),
                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('Біометричне підтвердження', style: AppTypography.labelMedium.copyWith(color: c.textPrimary, fontWeight: FontWeight.w600)),
                      Text('Натисни для швидкого підтвердження', style: AppTypography.labelSmall.copyWith(color: c.textHint)),
                    ]),
                  ]),
                ),
              ).animate().fadeIn(duration: 300.ms, delay: 500.ms),
            ),
          if (_biometricConfirmed)
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: Spacing.base),
                padding: const EdgeInsets.symmetric(horizontal: Spacing.base, vertical: Spacing.sm),
                decoration: BoxDecoration(color: AppColorsPS5.success.withOpacity(0.06), borderRadius: BorderRadius.circular(Radii.md)),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.verified_rounded, color: AppColorsPS5.success, size: 18),
                  const SizedBox(width: Spacing.xs),
                  Text('✅ Підтверджено біометрією', style: AppTypography.labelSmall.copyWith(color: AppColorsPS5.success, fontWeight: FontWeight.w600)),
                ]),
              ),
            ),
          // Попередній перегляд успіху
          if (_showSuccessPreview)
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: Spacing.base),
                padding: const EdgeInsets.all(Spacing.base),
                decoration: BoxDecoration(gradient: LinearGradient(colors: [AppColorsPS5.gradientStart, AppColorsPS5.gradientEnd]), borderRadius: BorderRadius.circular(Radii.lg)),
                child: Column(children: [
                  Text('🎉 Успіх! Внесок оброблено!', style: AppTypography.labelLarge.copyWith(color: Colors.white, fontWeight: FontWeight.w700)),
                  const SizedBox(height: Spacing.xs),
                  Text('XP +$_xpReward · 🪙 +$_coinReward', style: AppTypography.labelSmall.copyWith(color: Colors.white.withOpacity(0.8))),
                ]),
              ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack),
            ),
          // Міні-чек підсумок
          const SizedBox(height: Spacing.sm),
          _buildReceiptSummary(c, newBalance, newPercentage),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms, delay: 100.ms).slideY(begin: 0.1, end: 0, duration: 300.ms, delay: 100.ms, curve: AppEasings.standard);
  }

  Widget _buildRecurrenceSection(dynamic c) {
    return Column(children: [
      GestureDetector(
        onTap: () { HapticService.selection(); setState(() => _showRecurrenceInfo = !_showRecurrenceInfo); },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: Spacing.sm, vertical: Spacing.xs),
          decoration: BoxDecoration(color: AppColorsPS5.accent.withOpacity(0.04), borderRadius: BorderRadius.circular(Radii.sm)),
          child: Row(children: [
            Icon(Icons.schedule_rounded, color: c.accent, size: 14),
            const SizedBox(width: Spacing.xs),
            Expanded(child: Text('📅 Інформація про повторення', style: AppTypography.labelSmall.copyWith(color: c.accent))),
            Icon(_showRecurrenceInfo ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded, color: c.accent, size: 14),
          ]),
        ),
      ),
      if (_showRecurrenceInfo)
        Container(
          margin: const EdgeInsets.only(top: Spacing.xs),
          padding: const EdgeInsets.all(Spacing.sm),
          decoration: BoxDecoration(color: c.accent.withOpacity(0.03), borderRadius: BorderRadius.circular(Radii.sm)),
          child: Text(_recurrenceInfo[_depositType] ?? '', style: AppTypography.labelSmall.copyWith(color: c.textSecondary, fontSize: 10)),
        ).animate().fadeIn(duration: 200.ms),
    ]);
  }

  Widget _buildReceiptSummary(dynamic c, double newBalance, double newPercentage) {
    final now = DateTime.now();
    return Container(
      padding: const EdgeInsets.all(Spacing.sm),
      decoration: BoxDecoration(color: c.surface, borderRadius: BorderRadius.circular(Radii.sm), border: Border.all(color: c.border, width: 0.5)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('🧾 Чек підсумок', style: AppTypography.labelSmall.copyWith(color: c.textHint, fontWeight: FontWeight.w600)),
        const SizedBox(height: Spacing.xs),
        Text('Внесок: ${_editedAmount.toInt()} грн · Метод: $_selectedMethod · Тип: ${_depositTypes.firstWhere((t) => t.$1 == _depositType).$1}', style: AppTypography.labelSmall.copyWith(color: c.textHint, fontSize: 9)),
        if (_fee > 0) Text('Комісія: ${_fee.toStringAsFixed(1)} грн · Чиста сума: ${_netAmount.toInt()} грн', style: AppTypography.labelSmall.copyWith(color: c.textHint, fontSize: 9)),
        Text('Новий баланс: ${newBalance.toInt()} грн · Прогрес: ${newPercentage.toStringAsFixed(1)}%', style: AppTypography.labelSmall.copyWith(color: c.textHint, fontSize: 9)),
        Text('XP: +$_xpReward · Монети: +$_coinReward', style: AppTypography.labelSmall.copyWith(color: c.textHint, fontSize: 9)),
        Text('Дата: ${now.day.toString().padLeft(2, '0')}.${now.month.toString().padLeft(2, '0')}.${now.year} ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}', style: AppTypography.labelSmall.copyWith(color: c.textHint, fontSize: 9)),
        if (widget.comment.isNotEmpty) Text('Коментар: "${widget.comment}"', style: AppTypography.labelSmall.copyWith(color: c.textHint, fontSize: 9)),
      ]),
    );
  }

  Widget _buildInfoRow({required dynamic c, required String label, required String value, required Color valueColor, required IconData icon, Widget? trailing}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(children: [
          Icon(icon, color: c.textHint, size: 18),
          const SizedBox(width: Spacing.sm),
          Text(label, style: AppTypography.bodyMedium.copyWith(color: c.textSecondary)),
        ]),
        Row(children: [
          Text(value, style: AppTypography.monoMedium.copyWith(color: valueColor, fontWeight: FontWeight.w600)),
          if (trailing != null) ...[const SizedBox(width: Spacing.sm), trailing],
        ]),
      ],
    );
  }

  Widget _buildButtons(dynamic c) {
    return Row(
      children: [
        Expanded(
          child: AnimatedBuilder(animation: _morphController, builder: (context, child) {
            final progress = _morphController.value;
            return Transform.scale(scale: _isProcessing ? 1.0 - progress * 0.02 : 1.0, child: Opacity(opacity: _isProcessing ? 1.0 - progress * 0.5 : 1.0, child: child));
          }), child: AppButtonSecondary(label: _isCancelling ? 'Скасування...' : 'Скасувати', onPressed: _isProcessing ? null : _onCancelTap, isLightTheme: widget.isLightTheme)),
        ),
        const SizedBox(width: Spacing.base),
        Expanded(
          child: AnimatedBuilder(animation: _morphController, builder: (context, child) {
            return Transform.scale(scale: _isProcessing ? 1.0 : 1.0, child: child);
          }), child: AppButtonPrimary(
            label: _isProcessing ? 'Підтвердження...' : 'Підтвердити',
            onPressed: _isProcessing ? null : () => _onConfirm(context),
            isLightTheme: widget.isLightTheme,
            icon: _isProcessing ? SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : Icons.check_circle_outline_rounded,
          )),
        ),
      ],
    ).animate().fadeIn(duration: 300.ms, delay: 300.ms);
  }

  // ═══════════════════════════════════════════════════════════════════════
  // Додаткові константи підтвердження внеску
  // ═══════════════════════════════════════════════════════════════════════

  /// Мінімальна сума для «великого» внеску (виділяється кольором).
  static const double _kLargeDepositThreshold = 5000.0;

  /// Мінімальна сума для «середнього» внеску.
  static const double _kMediumDepositThreshold = 1000.0;

  /// Максимальна XP за один внесок.
  static const int _kMaxXPPerDeposit = 50;

  /// Максимальні монети за один внесок.
  static const int _kMaxCoinsPerDeposit = 25;

  /// Тривалість затримки для показу підказки комісії (мілісекунди).
  static const int _kFeeHintDelayMs = 1500;

  /// Кількість кроків обробки для progress indicator.
  static const int _kProcessingStepCount = 5;

  /// Мінімальна тривалість сесії підтвердження (мілісекунди).
  static const int _kMinSessionDurationMs = 3000;

  /// Максимальна кількість спроб підтвердження.
  static const int _kMaxConfirmAttempts = 3;

  // ═══════════════════════════════════════════════════════════════════════
  // Валідаційні методи
  // ═══════════════════════════════════════════════════════════════════════

  /// Валідує відредаговану суму внеску.
  ///
  /// Повертає рядок помилки або `null`, якщо сума валідна.
  String? _validateEditedAmount(double amount) {
    if (amount <= 0) return 'Сума повинна бути більшою за 0';
    if (amount < 10) return 'Мінімальна сума — 10 грн';
    if (amount > 999999) return 'Максимальна сума — 999 999 грн';
    return null;
  }

  /// Валідує вибраний метод оплати.
  ///
  /// Повертає `true`, якщо метод є валідним.
  bool _isPaymentMethodValid(String method) {
    return _depositMethods.any((m) => m.$1 == method);
  }

  /// Валідує вибраний тип внеску.
  ///
  /// Повертає `true`, якщо тип є валідним.
  bool _isDepositTypeValid(String type) {
    return _depositTypes.any((t) => t.$1 == type);
  }

  /// Перевіряє, чи сума внеску є «великою».
  ///
  /// «Великий» внесок >= [_kLargeDepositThreshold].
  bool get _isLargeDeposit {
    return _editedAmount >= _kLargeDepositThreshold;
  }

  /// Перевіряє, чи сума внеску є «середньою».
  bool get _isMediumDeposit {
    return _editedAmount >= _kMediumDepositThreshold &&
        _editedAmount < _kLargeDepositThreshold;
  }

  /// Перевіряє, чи комісія застосовується до поточного методу.
  bool get _hasFee {
    return _fee > 0;
  }

  /// Перевіряє, чи біометричне підтвердження доступне.
  bool get _isBiometricAvailable {
    return _biometricReady && !_biometricConfirmed;
  }

  /// Перевіряє, чи депозит може бути оброблений.
  ///
  /// Повертає `true`, якщо не обробляється і не скасовується.
  bool get _canProcess {
    return !_isProcessing && !_isCancelling;
  }

  /// Перевіряє, чи коментар порожній.
  bool get _hasComment {
    return widget.comment.isNotEmpty;
  }

  /// Перевіряє, чи депозит вже підтверджено біометрією.
  bool get _isFullyConfirmed {
    return _biometricConfirmed;
  }

  // ═══════════════════════════════════════════════════════════════════════
  // Обчислювальні (computed) властивості
  // ═══════════════════════════════════════════════════════════════════════

  /// Обчислює відсоток комісії від суми.
  ///
  /// Повертає 0.0, якщо комісія не застосовується.
  double get _feePercentage {
    if (_editedAmount <= 0) return 0.0;
    return (_fee / _editedAmount * 100);
  }

  /// Обчислює XP за одиницю суми (XP за 100 грн).
  double get _xpPerUnit {
    if (_editedAmount <= 0) return 0.0;
    return _xpReward / (_editedAmount / 100);
  }

  /// Обчислює монети за одиницю суми (монети за 200 грн).
  double get _coinsPerUnit {
    if (_editedAmount <= 0) return 0.0;
    return _coinReward / (_editedAmount / 200);
  }

  /// Обчислює ефективність внеску (XP + монети / 100 грн).
  double get _depositEfficiency {
    return _xpPerUnit + _coinsPerUnit;
  }

  /// Обчислює загальну винагороду в балах.
  int get _totalRewardPoints {
    return _xpReward + _coinReward;
  }

  /// Обчислює різницю між початковою та відредагованою сумою.
  double get _amountDifference {
    return _editedAmount - widget.amount;
  }

  /// Обчислює відсоток зміни суми (позитивний = збільшення).
  double get _amountChangePercentage {
    if (widget.amount <= 0) return 0.0;
    return (_amountDifference / widget.amount * 100);
  }

  /// Повертає описовий рядок розміру внеску.
  ///
  /// Наприклад: «Великий внесок», «Середній внесок», «Звичайний внесок».
  String get _depositSizeLabel {
    if (_isLargeDeposit) return 'Великий внесок 🔥';
    if (_isMediumDeposit) return 'Середній внесок 💪';
    if (_editedAmount >= 100) return 'Звичайний внесок';
    return 'Маленький внесок';
  }

  /// Повертає іконку розміру внеску.
  IconData get _depositSizeIcon {
    if (_isLargeDeposit) return Icons.local_fire_department_rounded;
    if (_isMediumDeposit) return Icons.trending_up_rounded;
    return Icons.savings_rounded;
  }

  /// Обчислює колір розміру внеску.
  Color get _depositSizeColor {
    if (_isLargeDeposit) return AppColorsPS5.xp;
    if (_isMediumDeposit) return AppColorsPS5.accent;
    return AppColorsPS5.success;
  }

  // ═══════════════════════════════════════════════════════════════════════
  // Форматувальники
  // ═══════════════════════════════════════════════════════════════════════

  /// Форматує відсоток комісії з відсотковим знаком.
  String _formatFeePercentage() {
    if (_feePercentage == 0) return 'Без комісії';
    return '${_feePercentage.toStringAsFixed(2)}%';
  }

  /// Форматує XP per unit як зручний рядок.
  String _formatXpPerUnit() {
    if (_xpPerUnit == 0) return '—';
    return '${_xpPerUnit.toStringAsFixed(1)} XP / 100 грн';
  }

  /// Форматує монети per unit як зручний рядок.
  String _formatCoinsPerUnit() {
    if (_coinsPerUnit == 0) return '—';
    return '${_coinsPerUnit.toStringAsFixed(1)} 🪙 / 200 грн';
  }

  /// Форматує різницю суми зі знаком + або -.
  String _formatAmountDifference() {
    if (_amountDifference == 0) return '';
    final sign = _amountDifference > 0 ? '+' : '';
    return '$sign${_amountDifference.toInt()} грн';
  }

  /// Форматує ефективність як загальний рядок.
  String _formatEfficiency() {
    if (_depositEfficiency == 0) return '—';
    return '${_depositEfficiency.toStringAsFixed(1)} балів / 100 грн';
  }

  /// Форматує опис обраного методу оплати.
  String _formatMethodDescription() {
    return _methodDescriptions[_selectedMethod] ?? '';
  }

  /// Форматує опис обраного типу внеску.
  String _formatTypeDescription() {
    final type = _depositTypes.firstWhere(
      (t) => t.$1 == _depositType,
      orElse: () => ('', Icons.help_outline_rounded, ''),
    );
    return type.$3;
  }

  // ═══════════════════════════════════════════════════════════════════════
  // Додаткові віджети-будівники
  // ═══════════════════════════════════════════════════════════════════════

  /// Будує індикатор розміру внеску з іконкою та кольором.
  Widget _buildDepositSizeIndicator(dynamic c) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: Spacing.sm, vertical: Spacing.xs),
      decoration: BoxDecoration(
        color: _depositSizeColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(Radii.sm),
        border: Border.all(color: _depositSizeColor.withOpacity(0.15)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_depositSizeIcon, color: _depositSizeColor, size: 16),
          const SizedBox(width: Spacing.xs),
          Text(
            _depositSizeLabel,
            style: AppTypography.labelSmall.copyWith(
              color: _depositSizeColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms, delay: 400.ms);
  }

  /// Будує рядок ефективності внеску (XP + монети за одиницю).
  Widget _buildEfficiencyRow(dynamic c) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Spacing.xs),
      child: Container(
        padding: const EdgeInsets.all(Spacing.sm),
        decoration: BoxDecoration(
          color: c.accent.withOpacity(0.04),
          borderRadius: BorderRadius.circular(Radii.sm),
        ),
        child: Column(
          children: [
            Text(
              'Ефективність внеску',
              style: AppTypography.labelSmall.copyWith(
                color: c.textHint,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: Spacing.xs),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildMiniEfficiencyItem(
                  label: 'XP / 100 грн',
                  value: _formatXpPerUnit(),
                  icon: Icons.star_rounded,
                  color: AppColorsPS5.xp,
                  c: c,
                ),
                _buildMiniEfficiencyItem(
                  label: '🪙 / 200 грн',
                  value: _formatCoinsPerUnit(),
                  icon: Icons.monetization_on_rounded,
                  color: AppColorsPS5.coin,
                  c: c,
                ),
                _buildMiniEfficiencyItem(
                  label: 'Загальна',
                  value: _formatEfficiency(),
                  icon: Icons.speed_rounded,
                  color: c.accent,
                  c: c,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Будує міні-елемент ефективності.
  Widget _buildMiniEfficiencyItem({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
    required dynamic c,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 14),
        const SizedBox(height: 2),
        Text(
          value,
          style: AppTypography.labelSmall.copyWith(
            color: color,
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

  /// Будує підказку про зміну суми (якщо користувач відредагував).
  Widget _buildAmountChangeHint(dynamic c) {
    if (_amountDifference == 0) return const SizedBox.shrink();

    final isIncrease = _amountDifference > 0;
    final changeColor = isIncrease ? AppColorsPS5.success : AppColorsPS5.warning;

    return Container(
      margin: const EdgeInsets.only(top: Spacing.xs),
      padding: const EdgeInsets.symmetric(horizontal: Spacing.sm, vertical: 4),
      decoration: BoxDecoration(
        color: changeColor.withOpacity(0.06),
        borderRadius: BorderRadius.circular(Radii.circular),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isIncrease ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
            color: changeColor,
            size: 14,
          ),
          const SizedBox(width: 4),
          Text(
            'Змінено: ${_formatAmountDifference()} (${_amountChangePercentage.toStringAsFixed(1)}%)',
            style: AppTypography.labelSmall.copyWith(
              color: changeColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  /// Будує розширений progress indicator кроків обробки.
  Widget _buildStepProgressIndicator(dynamic c) {
    final completedSteps = (_morphController.value * _kProcessingStepCount).floor();
    return Container(
      margin: const EdgeInsets.only(top: Spacing.sm),
      padding: const EdgeInsets.all(Spacing.sm),
      decoration: BoxDecoration(
        color: c.accent.withOpacity(0.04),
        borderRadius: BorderRadius.circular(Radii.sm),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Обробка: крок $completedSteps з $_kProcessingStepCount',
                style: AppTypography.labelSmall.copyWith(
                  color: c.accent,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '${(_morphController.value * 100).toStringAsFixed(0)}%',
                style: AppTypography.labelSmall.copyWith(
                  color: c.textHint,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(Radii.circular),
            child: LinearProgressIndicator(
              value: _morphController.value,
              backgroundColor: c.border.withOpacity(0.3),
              valueColor: AlwaysStoppedAnimation<Color>(c.accent),
              minHeight: 4,
            ),
          ),
        ],
      ),
    );
  }

  /// Будує підказку безпеки для великих внесків.
  Widget _buildSecurityHint(dynamic c) {
    if (!_isLargeDeposit) return const SizedBox.shrink();
    return Container(
      margin: const EdgeInsets.only(top: Spacing.xs),
      padding: const EdgeInsets.all(Spacing.sm),
      decoration: BoxDecoration(
        color: AppColorsPS5.warning.withOpacity(0.06),
        borderRadius: BorderRadius.circular(Radii.sm),
        border: Border.all(color: AppColorsPS5.warning.withOpacity(0.12)),
      ),
      child: Row(
        children: [
          Icon(Icons.shield_rounded, color: AppColorsPS5.warning, size: 16),
          const SizedBox(width: Spacing.sm),
          Expanded(
            child: Text(
              'Великий внесок — переконайся, що дані правильні!',
              style: AppTypography.labelSmall.copyWith(
                color: AppColorsPS5.warning,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Будує підсумковий рядок «швидка статистика».
  Widget _buildQuickStatsRow(dynamic c) {
    return Container(
      margin: const EdgeInsets.only(top: Spacing.xs),
      padding: const EdgeInsets.symmetric(horizontal: Spacing.sm, vertical: Spacing.xs),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(Radii.sm),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Text(
            'Всього балів: $_totalRewardPoints',
            style: AppTypography.caption.copyWith(color: c.textHint),
          ),
          Text(
            'Комісія: ${_formatFeePercentage()}',
            style: AppTypography.caption.copyWith(
              color: _hasFee ? AppColorsPS5.warning : c.textHint,
            ),
          ),
          Text(
            'Метод: $_selectedMethod',
            style: AppTypography.caption.copyWith(color: c.textHint),
          ),
        ],
      ),
    );
  }
}
