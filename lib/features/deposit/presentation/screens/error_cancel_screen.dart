import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_radii.dart';
import '../../../../core/constants/app_durations.dart';
import '../../../../core/constants/app_easings.dart';
import '../../../../core/constants/app_shadows.dart';
import '../../../../core/utils/haptic_service.dart';
import '../../../../core/widgets/app_button_primary.dart';
import '../../../../core/widgets/app_button_secondary.dart';

// ═══════════════════════════════════════════════════════════════════════════
// Тип помилки (Error Type Enum)
// ═══════════════════════════════════════════════════════════════════════════

/// Конкретний тип помилки для відображення деталізованої інформації.
///
/// Кожен тип має свою іконку, колір, заголовок та пораду щодо вирішення.
enum DepositErrorType {
  /// Помилка підключення до мережі.
  networkError,

  /// Недостатньо коштів на рахунку.
  insufficientFunds,

  /// Помилка валідації введених даних.
  validationError,

  /// Транзакція відхилена банком.
  bankDeclined,

  /// Таймаут операції.
  timeout,

  /// Помилка сервера.
  serverError,

  /// Сесія закінчилась, потрібен повторний вхід.
  sessionExpired,

  /// Сервіс тимчасово недоступний.
  serviceUnavailable,

  /// Загальна невідома помилка.
  unknown,
}

/// Розширення для отримання українських повідомлень про помилки.
extension DepositErrorTypeExtension on DepositErrorType {
  /// Іконка для типу помилки.
  IconData get icon {
    switch (this) {
      case DepositErrorType.networkError:
        return Icons.wifi_off_rounded;
      case DepositErrorType.insufficientFunds:
        return Icons.account_balance_wallet_rounded;
      case DepositErrorType.validationError:
        return Icons.error_outline_rounded;
      case DepositErrorType.bankDeclined:
        return Icons.credit_card_off_rounded;
      case DepositErrorType.timeout:
        return Icons.schedule_rounded;
      case DepositErrorType.serverError:
        return Icons.cloud_off_rounded;
      case DepositErrorType.sessionExpired:
        return Icons.lock_clock_rounded;
      case DepositErrorType.serviceUnavailable:
        return Icons.build_rounded;
      case DepositErrorType.unknown:
        return Icons.help_outline_rounded;
    }
  }

  /// Заголовок помилки українською.
  String get title {
    switch (this) {
      case DepositErrorType.networkError:
        return 'Немає підключення до мережі';
      case DepositErrorType.insufficientFunds:
        return 'Недостатньо коштів';
      case DepositErrorType.validationError:
        return 'Помилка у введених даних';
      case DepositErrorType.bankDeclined:
        return 'Операцію відхилено банком';
      case DepositErrorType.timeout:
        return 'Час очікування вичерпано';
      case DepositErrorType.serverError:
        return 'Помилка на сервері';
      case DepositErrorType.sessionExpired:
        return 'Сесію закінчено';
      case DepositErrorType.serviceUnavailable:
        return 'Сервіс тимчасово недоступний';
      case DepositErrorType.unknown:
        return 'Щось пішло не так';
    }
  }

  /// Опис помилки українською.
  String get description {
    switch (this) {
      case DepositErrorType.networkError:
        return 'Перевірте підключення до інтернету та спробуйте ще раз';
      case DepositErrorType.insufficientFunds:
        return 'На вашому рахунку недостатньо коштів для цієї операції';
      case DepositErrorType.validationError:
        return 'Перевірте правильність введених даних та спробуйте ще раз';
      case DepositErrorType.bankDeclined:
        return 'Банк відхилив операцію. Зверніться до свого банку';
      case DepositErrorType.timeout:
        return 'Операція зайняла забагато часу. Спробуйте ще раз';
      case DepositErrorType.serverError:
        return 'Сталася помилка на сервері. Ми вже працюємо над її вирішенням';
      case DepositErrorType.sessionExpired:
        return 'Ваша сесія закінчилась. Увійдіть знову для продовження';
      case DepositErrorType.serviceUnavailable:
        return 'Сервіс тимчасово недоступний. Спробуйте пізніше';
      case DepositErrorType.unknown:
        return 'Сталася неочікувана помилка. Спробуйте ще раз або зверніться до підтримки';
    }
  }

  /// Порада щодо вирішення проблеми.
  String get suggestion {
    switch (this) {
      case DepositErrorType.networkError:
        return 'Увімкніть Wi-Fi або мобільний інтернет';
      case DepositErrorType.insufficientFunds:
        return 'Поповніть рахунок або зменшіть суму внеску';
      case DepositErrorType.validationError:
        return 'Перевірте номер картки та суму';
      case DepositErrorType.bankDeclined:
        return 'Зателефонуйте на гарячу лінію банку';
      case DepositErrorType.timeout:
        return 'Переконайтесь, що інтернет стабільний';
      case DepositErrorType.serverError:
        return 'Зачекайте кілька хвилин та спробуйте ще';
      case DepositErrorType.sessionExpired:
        return 'Натисніть «Увійти» для повторної авторизації';
      case DepositErrorType.serviceUnavailable:
        return 'Повторіть спробу через 5-10 хвилин';
      case DepositErrorType.unknown:
        return 'Зверніться до підтримки, якщо проблема повторюється';
    }
  }

  /// Категорія помилки для логування.
  String get category {
    switch (this) {
      case DepositErrorType.networkError:
        return 'МЕРЕЖА';
      case DepositErrorType.insufficientFunds:
        return 'КОШТИ';
      case DepositErrorType.validationError:
        return 'ВАЛІДАЦІЯ';
      case DepositErrorType.bankDeclined:
        return 'БАНК';
      case DepositErrorType.timeout:
        return 'ТАЙМАУТ';
      case DepositErrorType.serverError:
        return 'СЕРВЕР';
      case DepositErrorType.sessionExpired:
        return 'СЕСІЯ';
      case DepositErrorType.serviceUnavailable:
        return 'СЕРВІС';
      case DepositErrorType.unknown:
        return 'НЕВІДОМА';
    }
  }
}

/// Оверлей скасування або помилки при внеску.
///
/// Показує:
/// - Error: м'яку червону іконку ✕, заголовок, підзаголовок, кнопку OK та Повторити
/// - Cancel: жовту іконку стрілки, заголовок, підзаголовок, кнопку OK
/// - Оверлей із backdrop blur
/// - М'які анімації (fade + scale, без bounce)
/// - Тактильний зворотний зв'язок
/// - Автозакриття
/// - Кнопку «Зв'язатися з підтримкою»
/// - Показ частин помилки з деталізованими типами
/// - Анімований контур помилки
/// - Альтернативні способи внеску
/// - Поради щодо відновлення
class ErrorCancelOverlay extends StatefulWidget {
  const ErrorCancelOverlay({
    super.key,
    this.isError = false,
    this.errorMessage,
    this.errorType,
    this.autoDismiss = false,
    this.autoDismissDuration = const Duration(seconds: 4),
    this.onRetry,
    this.onContactSupport,
    this.onTryAlternative,
    required this.onDismiss,
    this.showRecoverySuggestions = true,
    this.showAlternativeMethods = false,
    this.alternativeMethodLabel,
  });

  /// Якщо `true` — показує «Щось пішло не так»,
  /// інакше — «Внесок скасовано».
  final bool isError;

  /// Додатковий текст помилки для відображення.
  final String? errorMessage;

  /// Конкретний тип помилки для деталізованого відображення.
  final DepositErrorType? errorType;

  /// Автоматично закрити оверлей через [autoDismissDuration].
  final bool autoDismiss;

  /// Тривалість автозакриття.
  final Duration autoDismissDuration;

  /// Зворотний виклик для кнопки «Повторити» (тільки при помилці).
  final VoidCallback? onRetry;

  /// Зворотний виклик для кнопки «Зв'язатися з підтримкою».
  final VoidCallback? onContactSupport;

  /// Зворотний виклик для кнопки альтернативного способу внеску.
  final VoidCallback? onTryAlternative;

  /// Зворотний виклик при закритті.
  final VoidCallback onDismiss;

  /// Показувати поради щодо відновлення.
  final bool showRecoverySuggestions;

  /// Показувати альтернативні способи внеску.
  final bool showAlternativeMethods;

  /// Мітка альтернативного способу внеску.
  final String? alternativeMethodLabel;

  /// Показує оверлей як OverlayEntry.
  static OverlayEntry show(
    BuildContext context, {
    bool isError = false,
    String? errorMessage,
    DepositErrorType? errorType,
    bool autoDismiss = false,
    Duration autoDismissDuration = const Duration(seconds: 4),
    VoidCallback? onRetry,
  }) {
    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) => ErrorCancelOverlay(
        isError: isError,
        errorMessage: errorMessage,
        errorType: errorType,
        autoDismiss: autoDismiss,
        autoDismissDuration: autoDismissDuration,
        onRetry: onRetry,
        onDismiss: () => entry.remove(),
      ),
    );
    Overlay.of(context).insert(entry);
    return entry;
  }

  @override
  State<ErrorCancelOverlay> createState() => _ErrorCancelOverlayState();
}

class _ErrorCancelOverlayState extends State<ErrorCancelOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late AnimationController _pulseController;
  Timer? _autoDismissTimer;
  String _errorCode = '';
  bool _showDetails = false;
  bool _isRetrying = false;

  /// Лог помилок для дебагу.
  static final List<String> _errorLog = [];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _scaleAnimation = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: AppEasings.smooth),
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    // Генерація коду помилки
    final now = DateTime.now();
    _errorCode = 'DEP-${now.millisecondsSinceEpoch.toString().substring(5, 9)}';

    // Тактильний відгук при помилці
    Future.delayed(const Duration(milliseconds: 100), () {
      if (widget.isError) {
        HapticService.error();
      } else {
        HapticService.mediumTap();
      }
    });

    _controller.forward();

    // Логування помилки
    _logError();

    // Автозакриття
    if (widget.autoDismiss) {
      _autoDismissTimer = Timer(widget.autoDismissDuration, () {
        if (mounted) widget.onDismiss();
      });
    }
  }

  /// Логує помилку в локальний журнал.
  void _logError() {
    if (widget.isError) {
      final entry = '[$_errorCode] ${widget.errorType?.title ?? "Помилка"}: '
          '${widget.errorMessage ?? "невідома причина"}';
      _errorLog.add(entry);
      // Обмежуємо розмір журналу
      if (_errorLog.length > 50) {
        _errorLog.removeAt(0);
      }
    }
  }

  /// Повертає всі записані помилки (для дебагу).
  static List<String> getErrorLog() => List.unmodifiable(_errorLog);

  /// Очищає журнал помилок.
  static void clearErrorLog() => _errorLog.clear();

  @override
  void dispose() {
    _autoDismissTimer?.cancel();
    _controller.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _handleDismiss() {
    HapticService.lightTap();
    _controller.reverse().then((_) => widget.onDismiss());
  }

  void _handleRetry() {
    HapticService.lightTap();
    setState(() => _isRetrying = true);
    widget.onRetry?.call();
    // Анімація повторної спроби
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() => _isRetrying = false);
      }
    });
    _controller.reverse().then((_) => widget.onDismiss());
  }

  void _handleSupport() {
    HapticService.selection();
    if (widget.onContactSupport != null) {
      widget.onContactSupport!();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'З\'єднання з підтримкою...',
            style: AppTypography.labelMedium.copyWith(color: AppColorsPS5.textPrimary),
          ),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(milliseconds: 2000),
        ),
      );
    }
  }

  void _handleAlternative() {
    HapticService.selection();
    widget.onTryAlternative?.call();
    _controller.reverse().then((_) => widget.onDismiss());
  }

  void _toggleDetails() {
    HapticService.selection();
    setState(() => _showDetails = !_showDetails);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final errorType = widget.errorType;
    final iconColor =
        widget.isError ? AppColorsPS5.error : AppColorsPS5.warning;
    final cardBg = isDark ? AppColorsPS5.card : AppColorsMonitor.card;
    final cardBorder = isDark ? AppColorsPS5.border : AppColorsMonitor.border;
    final textColor = isDark ? AppColorsPS5.textPrimary : AppColorsMonitor.textPrimary;
    final subColor = isDark ? AppColorsPS5.textSecondary : AppColorsMonitor.textSecondary;
    final hintColor = isDark ? AppColorsPS5.textHint : AppColorsMonitor.textHint;

    return Positioned.fill(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Opacity(
            opacity: _fadeAnimation.value,
            child: Stack(
              children: [
                // ─── Backdrop blur overlay ──────────────────────
                Positioned.fill(
                  child: GestureDetector(
                    onTap: _handleDismiss,
                    child: Container(
                      color: Colors.black.withOpacity(
                        0.55 * _fadeAnimation.value,
                      ),
                      child: BackdropFilter(
                        filter: AppImageFilter.blur(
                          sigmaX: 8.0 * _fadeAnimation.value,
                          sigmaY: 8.0 * _fadeAnimation.value,
                        ),
                        child: const SizedBox.expand(),
                      ),
                    ),
                  ),
                ),

                // ─── Content card ───────────────────────────────
                Positioned.fill(
                  child: Center(
                    child: Transform.scale(
                      scale: _scaleAnimation.value,
                      child: Container(
                        margin: const EdgeInsets.symmetric(
                          horizontal: Spacing.xxl,
                        ),
                        padding: const EdgeInsets.all(Spacing.xl),
                        decoration: BoxDecoration(
                          color: cardBg,
                          borderRadius: BorderRadius.circular(Radii.xl),
                          border: widget.isError
                              ? Border.all(
                                  color: AppColorsPS5.error.withOpacity(
                                      0.3 * _fadeAnimation.value),
                                  width: 1.5,
                                )
                              : Border.all(
                                  color: cardBorder,
                                  width: 1,
                                ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 24,
                              offset: const Offset(0, 12),
                            ),
                            if (widget.isError)
                              BoxShadow(
                                color: AppColorsPS5.error.withOpacity(
                                    0.15 * _fadeAnimation.value),
                                blurRadius: 40,
                                spreadRadius: 8,
                              ),
                          ],
                        ),
                        child: SingleChildScrollView(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // ── Error / Cancel Icon ─────────────
                              _buildIconSection(iconColor),

                              const SizedBox(height: Spacing.lg),

                              // ── Title ────────────────────────────
                              Text(
                                errorType?.title ??
                                    (widget.isError
                                        ? 'Щось пішло не так'
                                        : 'Внесок скасовано'),
                                style: AppTypography.heading2.copyWith(
                                  color: textColor,
                                  fontWeight: FontWeight.w600,
                                ),
                                textAlign: TextAlign.center,
                              ),

                              const SizedBox(height: Spacing.sm),

                              // ── Subtitle ──────────────────────────
                              Text(
                                widget.errorMessage ??
                                    errorType?.description ??
                                    (widget.isError
                                        ? 'Спробуй ще раз або звернись до підтримки'
                                        : 'Можеш спробувати ще раз — нічого страшного!'),
                                style: AppTypography.bodyMedium.copyWith(
                                  color: subColor,
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                              ),

                              // ── Recovery suggestion ───────────────
                              if (widget.showRecoverySuggestions &&
                                  widget.isError &&
                                  errorType != null) ...[
                                const SizedBox(height: Spacing.sm),
                                _buildSuggestionCard(errorType, isDark),
                              ],

                              const SizedBox(height: Spacing.sm),

                              // ── Error detail line ─────────────────
                              if (widget.isError) ...[
                                GestureDetector(
                                  onTap: _toggleDetails,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: Spacing.md,
                                      vertical: Spacing.xs,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColorsPS5.error.withOpacity(0.08),
                                      borderRadius:
                                          BorderRadius.circular(Radii.sm),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.info_outline_rounded,
                                          color: AppColorsPS5.error,
                                          size: 14,
                                        ),
                                        const SizedBox(width: Spacing.xs),
                                        Text(
                                          'Код помилки: $_errorCode',
                                          style: AppTypography.labelSmall.copyWith(
                                            color: AppColorsPS5.error,
                                          ),
                                        ),
                                        const SizedBox(width: Spacing.xs),
                                        Text(
                                          '(${errorType?.category ?? "НЕВІДОМА"})',
                                          style: AppTypography.caption.copyWith(
                                            color: AppColorsPS5.error.withOpacity(0.6),
                                          ),
                                        ),
                                        const SizedBox(width: Spacing.xs),
                                        Icon(
                                          _showDetails
                                              ? Icons.keyboard_arrow_up_rounded
                                              : Icons.keyboard_arrow_down_rounded,
                                          color: AppColorsPS5.error,
                                          size: 14,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                if (_showDetails) ...[
                                  const SizedBox(height: Spacing.sm),
                                  _buildErrorDetails(isDark, subColor, errorType),
                                ],
                              ],

                              const SizedBox(height: Spacing.xxl),

                              // ── Action Buttons ───────────────────
                              _buildActionButtons(isDark, iconColor),

                              // ── Alternative method ───────────────
                              if (widget.showAlternativeMethods &&
                                  widget.isError) ...[
                                const SizedBox(height: Spacing.md),
                                _buildAlternativeMethod(hintColor),
                              ],

                              // ── Support link ─────────────────────
                              if (widget.isError) ...[
                                const SizedBox(height: Spacing.md),
                                GestureDetector(
                                  onTap: _handleSupport,
                                  child: Text(
                                    'Зв\'язатися з підтримкою →',
                                    style: AppTypography.labelSmall.copyWith(
                                      color: hintColor,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ─── Icon Section ──────────────────────────────────────────────────────

  Widget _buildIconSection(Color iconColor) {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, _) {
        final pulse = 0.8 + 0.2 * _pulseController.value;
        return Transform.scale(
          scale: pulse,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Primary icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: iconColor.withOpacity(0.12),
                  border: Border.all(
                    color: iconColor.withOpacity(0.2),
                    width: 1.5,
                  ),
                ),
                child: Center(
                  child: Icon(
                    widget.errorType?.icon ??
                        (widget.isError
                            ? Icons.highlight_off_rounded
                            : Icons.arrow_back_rounded),
                    color: iconColor,
                    size: 40,
                  ),
                ),
              ),
              const SizedBox(height: Spacing.sm),
              // Small ring decoration
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: iconColor.withOpacity(0.06),
                    width: 1,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ─── Suggestion Card ───────────────────────────────────────────────────

  /// Будує картку з порадою щодо вирішення проблеми.
  Widget _buildSuggestionCard(DepositErrorType errorType, bool isDark) {
    final c = isDark ? AppColorsPS5 : AppColorsMonitor;
    return Container(
      padding: const EdgeInsets.all(Spacing.sm),
      decoration: BoxDecoration(
        color: AppColorsPS5.warning.withOpacity(0.06),
        borderRadius: BorderRadius.circular(Radii.sm),
        border: Border.all(
          color: AppColorsPS5.warning.withOpacity(0.15),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.lightbulb_outline_rounded,
            color: AppColorsPS5.warning,
            size: 16,
          ),
          const SizedBox(width: Spacing.sm),
          Expanded(
            child: Text(
              errorType.suggestion,
              style: AppTypography.labelSmall.copyWith(
                color: c.textSecondary,
              ),
            ),
          ),
        ],
      ),
    ).animate().fade(duration: 300.ms, delay: 200.ms);
  }

  // ─── Error Details ─────────────────────────────────────────────────────

  /// Будує розгорнуті деталі помилки.
  Widget _buildErrorDetails(
    bool isDark,
    Color subColor,
    DepositErrorType? errorType,
  ) {
    return Container(
      padding: const EdgeInsets.all(Spacing.sm),
      decoration: BoxDecoration(
        color: AppColorsPS5.error.withOpacity(0.04),
        borderRadius: BorderRadius.circular(Radii.sm),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Деталі помилки:', style: AppTypography.labelSmall.copyWith(
            color: AppColorsPS5.error,
            fontWeight: FontWeight.w600,
          )),
          const SizedBox(height: Spacing.xs),
          Text('Тип: ${errorType?.category ?? "Помилка підключення"}', style: AppTypography.caption.copyWith(color: subColor)),
          Text('Код: $_errorCode', style: AppTypography.caption.copyWith(color: subColor)),
          Text('Час: ${DateTime.now().toString().substring(11, 19)}', style: AppTypography.caption.copyWith(color: subColor)),
          Text('Версія: Nexora v1.0.0', style: AppTypography.caption.copyWith(color: subColor)),
          const SizedBox(height: Spacing.xs),
          Text(
            'Якщо проблема повторюється, зверніться до підтримки з кодом $_errorCode',
            style: AppTypography.caption.copyWith(color: subColor.withOpacity(0.7)),
          ),
        ],
      ),
    ).animate().fade(duration: 300.ms);
  }

  // ─── Action Buttons ────────────────────────────────────────────────────

  Widget _buildActionButtons(bool isDark, Color iconColor) {
    final hintColor = isDark ? AppColorsPS5.textHint : AppColorsMonitor.textHint;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // OK button
        SizedBox(
          width: 200,
          child: AppButtonPrimary(
            label: 'OK',
            onPressed: _isRetrying ? null : _handleDismiss,
            isLightTheme: !isDark,
          ),
        ),
        // Retry button (error only)
        if (widget.isError) ...[
          const SizedBox(height: Spacing.md),
          SizedBox(
            width: 200,
            child: AppButtonSecondary(
              label: _isRetrying ? 'Повторення...' : 'Повторити',
              icon: _isRetrying
                  ? Icons.hourglass_top_rounded
                  : Icons.refresh_rounded,
              onPressed: _isRetrying ? null : _handleRetry,
              isLightTheme: !isDark,
            ),
          ),
        ],
        // Auto-dismiss indicator
        if (widget.autoDismiss) ...[
          const SizedBox(height: Spacing.sm),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.schedule_rounded, color: hintColor, size: 14),
              const SizedBox(width: Spacing.xs),
              Text(
                'Або чекай — закриється автоматично',
                style: AppTypography.labelSmall.copyWith(
                  color: hintColor,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  // ─── Alternative Method ────────────────────────────────────────────────

  /// Будує кнопку альтернативного способу внеску.
  Widget _buildAlternativeMethod(Color hintColor) {
    return GestureDetector(
      onTap: _handleAlternative,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: Spacing.md,
          vertical: Spacing.sm,
        ),
        decoration: BoxDecoration(
          color: AppColorsPS5.accent.withOpacity(0.08),
          borderRadius: BorderRadius.circular(Radii.sm),
          border: Border.all(
            color: AppColorsPS5.accent.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.alt_route_rounded,
              color: AppColorsPS5.accent,
              size: 16,
            ),
            const SizedBox(width: Spacing.sm),
            Text(
              widget.alternativeMethodLabel ?? 'Спробувати інший спосіб внеску',
              style: AppTypography.labelSmall.copyWith(
                color: AppColorsPS5.accent,
              ),
            ),
          ],
        ),
      ),
    ).animate().fade(duration: 300.ms, delay: 300.ms);
  }
}

// ─── ImageFilter extension for backdrop blur ────────────────────────────

/// Extension to create blur filter without importing dart:ui directly.
extension AppImageFilter on ImageFilter {
  /// Створює Gaussian blur filter.
  static ImageFilter blur({
    double sigmaX = 5.0,
    double sigmaY = 5.0,
  }) {
    return ImageFilter.blur(
      sigmaX: sigmaX,
      sigmaY: sigmaY,
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Error Severity (Рівень серйозності помилки)
// ═══════════════════════════════════════════════════════════════════════════

/// Рівень серйозності помилки для визначення стилю відображення.
///
/// Впливає на кольори, іконки, анімації та наявність додаткових дій.
enum ErrorSeverity {
  /// Низький рівень — інформаційне повідомлення (наприклад, скасування).
  low,

  /// Середній рівень — попередження (наприклад, таймаут).
  medium,

  /// Високий рівень — критична помилка (наприклад, відхилення банком).
  high,

  /// Критичний рівень — фатальна помилка (наприклад, збій сервера).
  critical,
}

/// Розширення для [ErrorSeverity] з допоміжними методами.
extension ErrorSeverityExtension on ErrorSeverity {
  /// Кольорова палітра для рівня серйозності.
  ///
  /// Повертає колір залежно від теми (isDark).
  Color accentColor(bool isDark) {
    switch (this) {
      case ErrorSeverity.low:
        return AppColorsPS5.warning;
      case ErrorSeverity.medium:
        return AppColorsPS5.warning;
      case ErrorSeverity.high:
        return AppColorsPS5.error;
      case ErrorSeverity.critical:
        return AppColorsPS5.error;
    }
  }

  /// Коефіцієнт тривалості автозакриття.
  ///
  /// Чим серйозніше — тим довше залишається на екрані.
  Duration autoDismissMultiplier(Duration base) {
    switch (this) {
      case ErrorSeverity.low:
        return base;
      case ErrorSeverity.medium:
        return Duration(milliseconds: (base.inMilliseconds * 1.5).round());
      case ErrorSeverity.high:
        return Duration(milliseconds: (base.inMilliseconds * 2.0).round());
      case ErrorSeverity.critical:
        return Duration(milliseconds: (base.inMilliseconds * 3.0).round());
    }
  }

  /// Чи показувати кнопку «Повторити».
  bool get showRetry {
    switch (this) {
      case ErrorSeverity.low:
        return false;
      case ErrorSeverity.medium:
        return true;
      case ErrorSeverity.high:
        return true;
      case ErrorSeverity.critical:
        return true;
    }
  }

  /// Чи показувати кнопку підтримки.
  bool get showSupport {
    switch (this) {
      case ErrorSeverity.low:
        return false;
      case ErrorSeverity.medium:
        return true;
      case ErrorSeverity.high:
        return true;
      case ErrorSeverity.critical:
        return true;
    }
  }

  /// Анімована іконка для рівня серйозності.
  IconData animatedIcon(bool isAnimating) {
    switch (this) {
      case ErrorSeverity.low:
        return Icons.info_outline_rounded;
      case ErrorSeverity.medium:
        return isAnimating
            ? Icons.warning_amber_rounded
            : Icons.warning_outlined;
      case ErrorSeverity.high:
        return isAnimating
            ? Icons.error_rounded
            : Icons.error_outline_rounded;
      case ErrorSeverity.critical:
        return isAnimating
            ? Icons.gpp_bad_rounded
            : Icons.gpp_bad_outlined;
    }
  }

  /// Мітка рівня серйозності українською.
  String get label {
    switch (this) {
      case ErrorSeverity.low:
        return 'Інформація';
      case ErrorSeverity.medium:
        return 'Увага';
      case ErrorSeverity.high:
        return 'Помилка';
      case ErrorSeverity.critical:
        return 'Критична помилка';
    }
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Error Recovery Strategy (Стратегія відновлення)
// ═══════════════════════════════════════════════════════════════════════════

/// Стратегія відновлення після помилки.
///
/// Кожна стратегія має іконку, назву, опис та набір дій.
class ErrorRecoveryStrategy {
  /// Іконка стратегії.
  final IconData icon;

  /// Назва стратегії українською.
  final String title;

  /// Опис стратегії.
  final String description;

  /// Категорія стратегії для фільтрації.
  final String category;

  /// Пріоритет стратегії (нижче = вищий пріоритет).
  final int priority;

  const ErrorRecoveryStrategy({
    required this.icon,
    required this.title,
    required this.description,
    required this.category,
    this.priority = 0,
  });
}

/// Попередньо визначені стратегії відновлення для кожного типу помилки.
///
/// Повертає список стратегій, відсортованих за пріоритетом.
List<ErrorRecoveryStrategy> getRecoveryStrategies(DepositErrorType type) {
  switch (type) {
    case DepositErrorType.networkError:
      return const [
        ErrorRecoveryStrategy(
          icon: Icons.wifi_rounded,
          title: 'Перевірити з\'єднання',
          description: 'Увімкніть Wi-Fi або мобільний інтернет і спробуйте ще раз',
          category: 'МЕРЕЖА',
          priority: 1,
        ),
        ErrorRecoveryStrategy(
          icon: Icons.airplanemode_active_rounded,
          title: 'Режим польоту',
          description: 'Вимкніть режим польоту, якщо він увімкнений',
          category: 'МЕРЕЖА',
          priority: 2,
        ),
        ErrorRecoveryStrategy(
          icon: Icons.restart_alt_rounded,
          title: 'Перезапуск додатку',
          description: 'Закрийте та відкрийте додаток знову',
          category: 'МЕРЕЖА',
          priority: 3,
        ),
      ];
    case DepositErrorType.insufficientFunds:
      return const [
        ErrorRecoveryStrategy(
          icon: Icons.account_balance_rounded,
          title: 'Поповнити рахунок',
          description: 'Переказайте кошти на картку, прив\'язану до внеску',
          category: 'КОШТИ',
          priority: 1,
        ),
        ErrorRecoveryStrategy(
          icon: Icons.tune_rounded,
          title: 'Зменшити суму',
          description: 'Спробуйте внести меншу суму, що доступна на рахунку',
          category: 'КОШТИ',
          priority: 2,
        ),
      ];
    case DepositErrorType.validationError:
      return const [
        ErrorRecoveryStrategy(
          icon: Icons.edit_rounded,
          title: 'Перевірити дані',
          description: 'Перевірте правильність номера картки та суми',
          category: 'ВАЛІДАЦІЯ',
          priority: 1,
        ),
      ];
    case DepositErrorType.bankDeclined:
      return const [
        ErrorRecoveryStrategy(
          icon: Icons.phone_in_talk_rounded,
          title: 'Зателефонувати до банку',
          description: 'Зверніться на гарячу лінію вашого банку',
          category: 'БАНК',
          priority: 1,
        ),
        ErrorRecoveryStrategy(
          icon: Icons.credit_card_rounded,
          title: 'Змінити картку',
          description: 'Спробуйте використати іншу банківську картку',
          category: 'БАНК',
          priority: 2,
        ),
      ];
    case DepositErrorType.timeout:
      return const [
        ErrorRecoveryStrategy(
          icon: Icons.refresh_rounded,
          title: 'Повторити спробу',
          description: 'Переконайтеся, що інтернет стабільний, і спробуйте ще',
          category: 'ТАЙМАУТ',
          priority: 1,
        ),
      ];
    case DepositErrorType.serverError:
      return const [
        ErrorRecoveryStrategy(
          icon: Icons.schedule_rounded,
          title: 'Зачекати та повторити',
          description: 'Сталася помилка на сервері. Зачекайте кілька хвилин',
          category: 'СЕРВЕР',
          priority: 1,
        ),
        ErrorRecoveryStrategy(
          icon: Icons.history_rounded,
          title: 'Перевірити статус',
          description: 'Перевірте, чи не було технічних робіт на сервері',
          category: 'СЕРВЕР',
          priority: 2,
        ),
      ];
    case DepositErrorType.sessionExpired:
      return const [
        ErrorRecoveryStrategy(
          icon: Icons.login_rounded,
          title: 'Увійти знову',
          description: 'Ваша сесія закінчилась. Увійдіть для продовження',
          category: 'СЕСІЯ',
          priority: 1,
        ),
      ];
    case DepositErrorType.serviceUnavailable:
      return const [
        ErrorRecoveryStrategy(
          icon: Icons.update_rounded,
          title: 'Оновити додаток',
          description: 'Можливо, потрібна нова версія додатку',
          category: 'СЕРВІС',
          priority: 1,
        ),
        ErrorRecoveryStrategy(
          icon: Icons.schedule_rounded,
          title: 'Спробувати пізніше',
          description: 'Сервіс тимчасово недоступний. Повторіть через 5-10 хв',
          category: 'СЕРВІС',
          priority: 2,
        ),
      ];
    case DepositErrorType.unknown:
      return const [
        ErrorRecoveryStrategy(
          icon: Icons.bug_report_rounded,
          title: 'Зв\'язатися з підтримкою',
          description: 'Надішліть код помилки підтримці для аналізу',
          category: 'НЕВІДОМА',
          priority: 1,
        ),
        ErrorRecoveryStrategy(
          icon: Icons.restart_alt_rounded,
          title: 'Перезапустити',
          description: 'Перезапустіть додаток та спробуйте ще раз',
          category: 'НЕВІДОМА',
          priority: 2,
        ),
      ];
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Error Theme Resolution Helpers
// ═══════════════════════════════════════════════════════════════════════════

/// Набір кольорів для помилкового оверлею.
///
/// Надає зручний доступ до тематичних кольорів залежно від теми додатку.
class ErrorOverlayTheme {
  /// Основний колір тексту.
  final Color textPrimary;

  /// Другорядний колір тексту.
  final Color textSecondary;

  /// Колір підказки.
  final Color textHint;

  /// Колір фону картки.
  final Color cardBackground;

  /// Колір рамки картки.
  final Color cardBorder;

  /// Колір акценту помилки.
  final Color accentColor;

  /// Колір успіху.
  final Color successColor;

  /// Колір попередження.
  final Color warningColor;

  const ErrorOverlayTheme({
    required this.textPrimary,
    required this.textSecondary,
    required this.textHint,
    required this.cardBackground,
    required this.cardBorder,
    required this.accentColor,
    required this.successColor,
    required this.warningColor,
  });

  /// Створює тему для темного режиму.
  factory ErrorOverlayTheme.dark() {
    return const ErrorOverlayTheme(
      textPrimary: AppColorsPS5.textPrimary,
      textSecondary: AppColorsPS5.textSecondary,
      textHint: AppColorsPS5.textHint,
      cardBackground: AppColorsPS5.card,
      cardBorder: AppColorsPS5.border,
      accentColor: AppColorsPS5.accent,
      successColor: AppColorsPS5.success,
      warningColor: AppColorsPS5.warning,
    );
  }

  /// Створює тему для світлого режиму.
  factory ErrorOverlayTheme.light() {
    return const ErrorOverlayTheme(
      textPrimary: AppColorsMonitor.textPrimary,
      textSecondary: AppColorsMonitor.textSecondary,
      textHint: AppColorsMonitor.textHint,
      cardBackground: AppColorsMonitor.card,
      cardBorder: AppColorsMonitor.border,
      accentColor: AppColorsMonitor.accent,
      successColor: AppColorsMonitor.success,
      warningColor: AppColorsMonitor.warning,
    );
  }

  /// Створює тему на основі поточного [BuildContext].
  factory ErrorOverlayTheme.fromContext(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? ErrorOverlayTheme.dark() : ErrorOverlayTheme.light();
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Error Timestamp Utilities
// ═══════════════════════════════════════════════════════════════════════════

/// Утиліти для форматування часових міток помилок.
class ErrorTimestampUtils {
  /// Константа — не дозволяємо створювати екземпляри.
  ErrorTimestampUtils._();

  /// Форматує час для відображення у деталях помилки (ГГ:ХХ:СС).
  static String formatTime(DateTime time) {
    return time.toString().substring(11, 19);
  }

  /// Форматує дату для відображення (ДД.ММ.РРРР).
  static String formatDate(DateTime time) {
    final day = time.day.toString().padLeft(2, '0');
    final month = time.month.toString().padLeft(2, '0');
    final year = time.year;
    return '$day.$month.$year';
  }

  /// Форматує повну дату та час (ДД.ММ.РРРР ГГ:ХХ:СС).
  static String formatFull(DateTime time) {
    return '${formatDate(time)} ${formatTime(time)}';
  }

  /// Повертає відносний час (наприклад, «щойно», «5 хв тому»).
  static String formatRelative(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inSeconds < 5) return 'щойно';
    if (diff.inSeconds < 60) return '${diff.inSeconds} сек тому';
    if (diff.inMinutes < 60) return '${diff.inMinutes} хв тому';
    if (diff.inHours < 24) return '${diff.inHours} год тому';
    return '${diff.inDays} дн тому';
  }

  /// Генерує унікальний код помилки на основі часової мітки.
  ///
  /// Формат: `DEP-XXXX` де XXXX — 4 цифри з мілісекунд.
  static String generateErrorCode([DateTime? time]) {
    final t = time ?? DateTime.now();
    return 'DEP-${t.millisecondsSinceEpoch.toString().substring(5, 9)}';
  }

  /// Генерує розширений код помилки з префіксом типу.
  ///
  /// Формат: `DEP-[TYPE]-XXXX`.
  static String generateExtendedErrorCode(DepositErrorType type) {
    final code = generateErrorCode();
    return '$code-${type.category}';
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Error Validation Helpers
// ═══════════════════════════════════════════════════════════════════════════

/// Валідатори та допоміжні методи для обробки помилок внесків.
class DepositErrorValidator {
  /// Константа — не дозволяємо створювати екземпляри.
  DepositErrorValidator._();

  /// Максимальна довжина повідомлення про помилку.
  static const int maxErrorMessageLength = 200;

  /// Мінімальна довжина коду помилки.
  static const int minErrorCodeLength = 4;

  /// Валідує повідомлення про помилку.
  ///
  /// Повертає `null` якщо повідомлення коректне, інакше — опис проблеми.
  static String? validateErrorMessage(String? message) {
    if (message == null || message.trim().isEmpty) return null;
    if (message.length > maxErrorMessageLength) {
      return 'Повідомлення про помилку занадто довге '
          '(${message.length}/$maxErrorMessageLength символів)';
    }
    return null;
  }

  /// Валідує код помилки.
  ///
  /// Повертає `true` якщо код має коректний формат.
  static bool isValidErrorCode(String code) {
    if (code.isEmpty) return false;
    if (code.length < minErrorCodeLength) return false;
    // Код має починатись з префіксу DEP-
    if (!code.startsWith('DEP-')) return false;
    return true;
  }

  /// Нормалізує повідомлення про помилку (обрізає, видаляє зайві пробіли).
  static String normalizeErrorMessage(String message) {
    return message.trim().replaceAll(RegExp(r'\s+'), ' ');
  }

  /// Визначає [ErrorSeverity] на основі [DepositErrorType].
  static ErrorSeverity resolveSeverity(DepositErrorType type) {
    switch (type) {
      case DepositErrorType.networkError:
        return ErrorSeverity.medium;
      case DepositErrorType.insufficientFunds:
        return ErrorSeverity.medium;
      case DepositErrorType.validationError:
        return ErrorSeverity.low;
      case DepositErrorType.bankDeclined:
        return ErrorSeverity.high;
      case DepositErrorType.timeout:
        return ErrorSeverity.medium;
      case DepositErrorType.serverError:
        return ErrorSeverity.high;
      case DepositErrorType.sessionExpired:
        return ErrorSeverity.medium;
      case DepositErrorType.serviceUnavailable:
        return ErrorSeverity.medium;
      case DepositErrorType.unknown:
        return ErrorSeverity.critical;
    }
  }

  /// Визначає [DepositErrorType] на основі рядка помилки.
  ///
  /// Використовується для парсингу помилок з API.
  static DepositErrorType? parseErrorType(String errorString) {
    final lower = errorString.toLowerCase();

    if (lower.contains('network') || lower.contains('connect')) {
      return DepositErrorType.networkError;
    }
    if (lower.contains('insufficient') || lower.contains('funds')) {
      return DepositErrorType.insufficientFunds;
    }
    if (lower.contains('valid') || lower.contains('invalid')) {
      return DepositErrorType.validationError;
    }
    if (lower.contains('declined') || lower.contains('reject')) {
      return DepositErrorType.bankDeclined;
    }
    if (lower.contains('timeout') || lower.contains('timed out')) {
      return DepositErrorType.timeout;
    }
    if (lower.contains('server') || lower.contains('internal')) {
      return DepositErrorType.serverError;
    }
    if (lower.contains('session') || lower.contains('expired')) {
      return DepositErrorType.sessionExpired;
    }
    if (lower.contains('unavailable') || lower.contains('maintenance')) {
      return DepositErrorType.serviceUnavailable;
    }

    return null;
  }

  /// Визначає, чи є помилка можливою для повторної спроби.
  static bool isRetryable(DepositErrorType type) {
    switch (type) {
      case DepositErrorType.networkError:
        return true;
      case DepositErrorType.timeout:
        return true;
      case DepositErrorType.serverError:
        return true;
      case DepositErrorType.serviceUnavailable:
        return true;
      case DepositErrorType.insufficientFunds:
        return false;
      case DepositErrorType.validationError:
        return false;
      case DepositErrorType.bankDeclined:
        return false;
      case DepositErrorType.sessionExpired:
        return false;
      case DepositErrorType.unknown:
        return true;
    }
  }

  /// Повертає рекомендовану затримку перед повторною спробою.
  static Duration retryDelay(DepositErrorType type) {
    switch (type) {
      case DepositErrorType.networkError:
        return const Duration(seconds: 3);
      case DepositErrorType.timeout:
        return const Duration(seconds: 5);
      case DepositErrorType.serverError:
        return const Duration(seconds: 30);
      case DepositErrorType.serviceUnavailable:
        return const Duration(minutes: 5);
      case DepositErrorType.unknown:
        return const Duration(seconds: 10);
      case DepositErrorType.insufficientFunds:
      case DepositErrorType.validationError:
      case DepositErrorType.bankDeclined:
      case DepositErrorType.sessionExpired:
        return Duration.zero;
    }
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Constants
// ═══════════════════════════════════════════════════════════════════════════

/// Константи для оверлея помилок.
class ErrorOverlayConstants {
  /// Константа — не дозволяємо створювати екземпляри.
  ErrorOverlayConstants._();

  /// Стандартна тривалість анімації входу.
  static const Duration entryAnimationDuration = Duration(milliseconds: 500);

  /// Стандартна тривалість анімації виходу.
  static const Duration exitAnimationDuration = Duration(milliseconds: 300);

  /// Тривалість пульсації іконки помилки.
  static const Duration pulseDuration = Duration(milliseconds: 2000);

  /// Затримка перед тактильним відгуком.
  static const Duration hapticDelay = Duration(milliseconds: 100);

  /// Затримка перед початком анімації повтору.
  static const Duration retryAnimationDelay = Duration(milliseconds: 300);

  /// Стандартний відступ по горизонталі для картки.
  static const double cardHorizontalPadding = Spacing.xxl;

  /// Внутрішній відступ картки.
  static const double cardPadding = Spacing.xl;

  /// Радіус округлення картки.
  static const double cardRadius = Radii.xl;

  /// Радіус округлення дрібних елементів.
  static const double smallRadius = Radii.sm;

  /// Розмір іконки помилки (діаметр).
  static const double iconSize = 80.0;

  /// Розмір іконки помилки (пікселі для Icon widget).
  static const double iconPixelSize = 40.0;

  /// Розмір зовнішнього кільця декорації.
  static const double outerRingSize = 96.0;

  /// Ширина кнопки OK / Повторити.
  static const double buttonWidth = 200.0;

  /// Максимальна кількість записів в журналі помилок.
  static const int maxErrorLogSize = 50;

  /// Непрозорість фонового оверлея.
  static const double backdropOpacity = 0.55;

  /// Сила blur для backdrop filter.
  static const double backdropBlurSigma = 8.0;

  /// Максимальна кількість рядків підзаголовка.
  static const int subtitleMaxLines = 3;

  /// Непрозорість рамки помилки.
  static const double errorBorderOpacity = 0.3;

  /// Непрозорість тіні помилки.
  static const double errorShadowOpacity = 0.15;

  /// Blur radius для тіні картки.
  static const double cardShadowBlur = 24.0;

  /// Відступ тіні картки по Y.
  static const double cardShadowOffsetY = 12.0;

  /// Spread radius для glow-тіні помилки.
  static const double errorGlowSpread = 8.0;

  /// Blur radius для glow-тіні помилки.
  static const double errorGlowBlur = 40.0;

  /// Мінімальна ширина картки (responsive).
  static const double minCardWidth = 280.0;

  /// Максимальна ширина картки (responsive).
  static const double maxCardWidth = 400.0;
}
