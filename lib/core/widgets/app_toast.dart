import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../constants/app_colors.dart';
import '../constants/app_typography.dart';
import '../constants/app_spacing.dart';
import '../constants/app_radii.dart';
import '../constants/app_durations.dart';

// ─── Toast Types ────────────────────────────────────────────────────────────

/// Типи сповіщень з відповідними іконками та кольорами.
enum ToastType {
  /// Успішна дія.
  success(
    icon: Icons.check_circle_rounded,
    color: Color(0xFF00C853),
    haptic: HapticFeedbackType.light,
    label: 'Успіх',
  ),

  /// Помилка.
  error(
    icon: Icons.error_rounded,
    color: Color(0xFFFF1744),
    haptic: HapticFeedbackType.heavy,
    label: 'Помилка',
  ),

  /// Попередження.
  warning(
    icon: Icons.warning_rounded,
    color: Color(0xFFFFB300),
    haptic: HapticFeedbackType.medium,
    label: 'Увага',
  ),

  /// Інформаційне повідомлення.
  info(
    icon: Icons.info_rounded,
    color: Color(0xFF4D9AE8),
    haptic: HapticFeedbackType.light,
    label: 'Інфо',
  ),

  /// Отримано XP.
  xp(
    icon: Icons.star_rounded,
    color: Color(0xFFFFD600),
    haptic: HapticFeedbackType.medium,
    label: 'XP',
  ),

  /// Отримано монети.
  coins(
    icon: Icons.monetization_on_rounded,
    color: Color(0xFFFF9100),
    haptic: HapticFeedbackType.medium,
    label: 'Монети',
  ),

  /// Серія продовжена.
  streak(
    icon: Icons.local_fire_department_rounded,
    color: Color(0xFFFF5722),
    haptic: HapticFeedbackType.light,
    label: 'Серія',
  ),

  /// Отримано бейдж/досягнення.
  badge(
    icon: Icons.emoji_events_rounded,
    color: Color(0xFFFFD600),
    haptic: HapticFeedbackType.heavy,
    label: 'Досягнення',
  ),

  /// Вихід з системи.
  logout(
    icon: Icons.logout_rounded,
    color: Color(0xFF78909C),
    haptic: HapticFeedbackType.light,
    label: 'Вихід',
  ),

  /// Синхронізація завершена.
  sync(
    icon: Icons.sync_rounded,
    color: Color(0xFF26A69A),
    haptic: HapticFeedbackType.light,
    label: 'Синхронізація',
  ),

  /// Резервне копіювання.
  backup(
    icon: Icons.cloud_upload_rounded,
    color: Color(0xFF42A5F5),
    haptic: HapticFeedbackType.medium,
    label: 'Бекап',
  ),

  /// Сповіщення з вмістом (кастомне).
  notification(
    icon: Icons.notifications_rounded,
    color: Color(0xFFAB47BC),
    haptic: HapticFeedbackType.light,
    label: 'Сповіщення',
  );

  const ToastType({
    required this.icon,
    required this.color,
    required this.haptic,
    required this.label,
  });

  final IconData icon;
  final Color color;
  final HapticFeedbackType haptic;
  final String label;
}

/// Тип тактильного відгуку.
enum HapticFeedbackType {
  /// Легкий вібро-відгук.
  light,

  /// Середній вібро-відгук.
  medium,

  /// Сильний вібро-відгук.
  heavy,

  /// Без тактильного відгуку.
  none,
}

/// Позиція появи сповіщення на екрані.
enum ToastPosition {
  /// Зверху екрана.
  top,

  /// Знизу екрана.
  bottom,

  /// По центру екрана.
  center,

  /// Зверху з відступом для безпечної зони.
  topSafe,

  /// Знизу з відступом для безпечної зони.
  bottomSafe;
}

// ─── Toast Configuration ────────────────────────────────────────────────────

/// Конфігурація для окремого сповіщення.
class ToastConfig {
  const ToastConfig({
    required this.message,
    this.type = ToastType.success,
    this.isLightTheme = false,
    this.duration,
    this.actionLabel,
    this.actionCallback,
    this.onDismiss,
    this.showProgress = false,
    this.position = ToastPosition.top,
    this.customIcon,
    this.customColor,
    this.enableHaptic = true,
    this.isPersistent = false,
    this.title,
    this.subtitle,
    this.dismissible = true,
    this.animationDuration,
    this.borderRadius,
  });

  /// Текст повідомлення.
  final String message;

  /// Тип сповіщення.
  final ToastType type;

  /// Світла тема.
  final bool isLightTheme;

  /// Тривалість показу.
  final Duration? duration;

  /// Текст кнопки дії.
  final String? actionLabel;

  /// Callback для кнопки дії.
  final VoidCallback? actionCallback;

  /// Callback при закритті.
  final VoidCallback? onDismiss;

  /// Показувати індикатор прогресу.
  final bool showProgress;

  /// Позиція появи.
  final ToastPosition position;

  /// Кастомна іконка (перевизначає type.icon).
  final IconData? customIcon;

  /// Кастомний колір (перевизначає type.color).
  final Color? customColor;

  /// Увімкнути тактильний відгук.
  final bool enableHaptic;

  /// Постійне сповіщення (не зникає автоматично).
  final bool isPersistent;

  /// Заголовок сповіщення (додатковий рядок над повідомленням).
  final String? title;

  /// Підзаголовок сповіщення (додатковий рядок під повідомленням).
  final String? subtitle;

  /// Чи можна закрити свайпом або кнопкою.
  final bool dismissible;

  /// Тривалість анімації входу/виходу.
  final Duration? animationDuration;

  /// Кастомний радіус кутів.
  final double? borderRadius;
}

// ─── Toast Queue Manager ────────────────────────────────────────────────────

/// Менеджер черги сповіщень.
///
/// Підтримує:
/// - Чергу сповіщень з послідовним показом
/// - Постійні сповіщення (isPersistent) — показуються паралельно
/// - Обмеження кількості одночасних сповіщень
/// - Приоритетність: error > warning > success > info
class _ToastQueue {
  _ToastQueue._();

  static final _ToastQueue _instance = _ToastQueue._();
  static _ToastQueue get instance => _instance;

  final List<OverlayEntry> _queue = [];
  final List<OverlayEntry> _persistent = [];
  bool _isShowing = false;

  /// Максимальна кількість одночасних сповіщень.
  static const int maxPersistentToasts = 2;

  /// Додає сповіщення до черги.
  void enqueue(BuildContext context, ToastConfig config) {
    // Тактильний відгук
    if (config.enableHaptic && config.type.haptic != HapticFeedbackType.none) {
      _triggerHaptic(config.type.haptic);
    }

    // Постійні сповіщення показуються паралельно
    if (config.isPersistent) {
      if (_persistent.length >= maxPersistentToasts) {
        // Закриваємо найстаріше постійне сповіщення
        final oldest = _persistent.removeAt(0);
        oldest.remove();
      }
      _showPersistent(context, config);
      return;
    }

    final overlay = Overlay.of(context);
    final effectiveDuration = config.isPersistent
        ? null
        : config.duration ?? AppDurations.toast;

    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => _ToastWidget(
        config: config,
        effectiveDuration: effectiveDuration,
        onDismiss: () {
          overlayEntry.remove();
          config.onDismiss?.call();
          _isShowing = false;
          _processNext(context);
        },
      ),
    );

    _queue.add(overlayEntry);

    if (!_isShowing) {
      _processNext(context);
    }
  }

  /// Показує постійне сповіщення.
  void _showPersistent(BuildContext context, ToastConfig config) {
    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => _ToastWidget(
        config: config,
        effectiveDuration: null,
        onDismiss: () {
          overlayEntry.remove();
          _persistent.remove(overlayEntry);
          config.onDismiss?.call();
        },
      ),
    );

    _persistent.add(overlayEntry);
    Overlay.of(context).insert(overlayEntry);
  }

  /// Обробляє наступне сповіщення з черги.
  void _processNext(BuildContext context) {
    if (_queue.isEmpty) return;
    _isShowing = true;
    final entry = _queue.removeAt(0);
    Overlay.of(context).insert(entry);
  }

  /// Закриває всі сповіщення.
  void dismissAll() {
    for (final entry in [..._queue, ..._persistent]) {
      entry.remove();
    }
    _queue.clear();
    _persistent.clear();
    _isShowing = false;
  }

  /// Запускає тактильний відгук.
  void _triggerHaptic(HapticFeedbackType type) {
    switch (type) {
      case HapticFeedbackType.light:
        HapticFeedback.lightImpact();
        break;
      case HapticFeedbackType.medium:
        HapticFeedback.mediumImpact();
        break;
      case HapticFeedbackType.heavy:
        HapticFeedback.heavyImpact();
        break;
      case HapticFeedbackType.none:
        break;
    }
  }

  /// Чи в черзі є сповіщення.
  bool get hasPending => _queue.isNotEmpty || _isShowing;

  /// Кількість сповіщень у черзі.
  int get pendingCount => _queue.length + (_isShowing ? 1 : 0);
}

// ─── Toast API ──────────────────────────────────────────────────────────────

/// Статичний API для показу сповіщень.
///
/// Підтримує:
/// - Типи [ToastType]: success, error, warning, info, xp, coins, streak, badge тощо
/// - Кнопку дії на сповіщенні
/// - Індикатор прогресу
/// - Автоматичне закриття з налаштовуваною тривалістю
/// - Чергу сповіщень
/// - Позицію появи (top, bottom, center, topSafe, bottomSafe)
/// - Тактильний відгук
/// - Постійні сповіщення
/// - Кастомні заголовки та підзаголовки
class AppToast {
  AppToast._();

  /// Показує сповіщення з конфігурацією.
  static void show(
    BuildContext context, {
    required String message,
    ToastType type = ToastType.success,
    bool isLightTheme = false,
    Duration? duration,
    String? actionLabel,
    VoidCallback? actionCallback,
    VoidCallback? onDismiss,
    bool showProgress = false,
    ToastPosition position = ToastPosition.top,
    IconData? icon,
    Color? color,
    bool enableHaptic = true,
    bool isPersistent = false,
    String? title,
    String? subtitle,
  }) {
    final config = ToastConfig(
      message: message,
      type: type,
      isLightTheme: isLightTheme,
      duration: duration,
      actionLabel: actionLabel,
      actionCallback: actionCallback,
      onDismiss: onDismiss,
      showProgress: showProgress,
      position: position,
      customIcon: icon,
      customColor: color,
      enableHaptic: enableHaptic,
      isPersistent: isPersistent,
      title: title,
      subtitle: subtitle,
    );

    _ToastQueue.instance.enqueue(context, config);
  }

  /// Швидкий показ успішного сповіщення.
  static void success(BuildContext context, String message) {
    show(context, message: message, type: ToastType.success);
  }

  /// Швидкий показ помилки.
  static void error(BuildContext context, String message) {
    show(context, message: message, type: ToastType.error);
  }

  /// Швидкий показ попередження.
  static void warning(BuildContext context, String message) {
    show(context, message: message, type: ToastType.warning);
  }

  /// Швидкий показ інформації.
  static void info(BuildContext context, String message) {
    show(context, message: message, type: ToastType.info);
  }

  /// Показ сповіщення про отримання XP.
  static void xp(BuildContext context, String message) {
    show(context, message: message, type: ToastType.xp);
  }

  /// Показ сповіщення про отримання монет.
  static void coins(BuildContext context, String message) {
    show(context, message: message, type: ToastType.coins);
  }

  /// Показ сповіщення про серію.
  static void streak(BuildContext context, String message) {
    show(context, message: message, type: ToastType.streak);
  }

  /// Показ сповіщення про досягнення.
  static void badge(BuildContext context, String message) {
    show(context, message: message, type: ToastType.badge);
  }

  /// Показ сповіщення про синхронізацію.
  static void sync(BuildContext context, String message) {
    show(context, message: message, type: ToastType.sync);
  }

  /// Показ сповіщення про бекап.
  static void backup(BuildContext context, String message) {
    show(context, message: message, type: ToastType.backup);
  }

  /// Показ сповіщення з кнопкою дії.
  static void withAction(
    BuildContext context, {
    required String message,
    required String actionLabel,
    required VoidCallback actionCallback,
    ToastType type = ToastType.info,
    String? title,
  }) {
    show(
      context,
      message: message,
      type: type,
      actionLabel: actionLabel,
      actionCallback: actionCallback,
      title: title,
    );
  }

  /// Показ постійного сповіщення (не зникає автоматично).
  static void persistent(
    BuildContext context, {
    required String message,
    ToastType type = ToastType.info,
    String? title,
    VoidCallback? onDismiss,
  }) {
    show(
      context,
      message: message,
      type: type,
      isPersistent: true,
      title: title,
      onDismiss: onDismiss,
    );
  }

  /// Закриває всі активні сповіщення.
  static void dismissAll() {
    _ToastQueue.instance.dismissAll();
  }

  /// Чи є активні сповіщення.
  static bool get hasActiveToasts => _ToastQueue.instance.hasPending;
}

// ─── Toast Widget ───────────────────────────────────────────────────────────

class _ToastWidget extends StatefulWidget {
  const _ToastWidget({
    required this.config,
    required this.effectiveDuration,
    required this.onDismiss,
  });

  final ToastConfig config;
  final Duration? effectiveDuration;
  final VoidCallback onDismiss;

  @override
  State<_ToastWidget> createState() => _ToastWidgetState();
}

class _ToastWidgetState extends State<_ToastWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _progressAnimation;
  Timer? _autoDismissTimer;

  @override
  void initState() {
    super.initState();
    final animDuration = widget.config.animationDuration ?? AppDurations.medium;
    _controller = AnimationController(
      vsync: this,
      duration: animDuration,
    );

    // Анімація входу залежить від позиції
    final beginOffset = _getBeginOffset();
    _slideAnimation = Tween<Offset>(
      begin: beginOffset,
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    // Анімація прогресу
    _progressAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.linear),
    );

    _controller.forward();

    // Автоматичне закриття (тільки для не-постійних сповіщень)
    if (widget.effectiveDuration != null) {
      _autoDismissTimer = Timer(widget.effectiveDuration!, () {
        if (mounted) {
          _dismiss();
        }
      });
    }
  }

  Offset _getBeginOffset() {
    switch (widget.config.position) {
      case ToastPosition.top:
      case ToastPosition.topSafe:
        return const Offset(0, -1);
      case ToastPosition.bottom:
      case ToastPosition.bottomSafe:
        return const Offset(0, 1);
      case ToastPosition.center:
        return Offset.zero;
    }
  }

  void _dismiss() {
    _autoDismissTimer?.cancel();
    _controller.reverse().then((_) {
      widget.onDismiss();
    });
  }

  @override
  void dispose() {
    _autoDismissTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  // ─── Кольори ──────────────────────────────────────────────────────────

  Color get _cardColor => widget.config.isLightTheme
      ? AppColorsMonitor.cardElevated
      : AppColorsPS5.cardElevated;

  Color get _textColor => widget.config.isLightTheme
      ? AppColorsMonitor.textPrimary
      : AppColorsPS5.textPrimary;

  Color get _hintColor => widget.config.isLightTheme
      ? AppColorsMonitor.textHint
      : AppColorsPS5.textHint;

  Color get _borderColor => widget.config.isLightTheme
      ? AppColorsMonitor.border
      : AppColorsPS5.border;

  Color get _iconColor =>
      widget.config.customColor ?? widget.config.type.color;

  IconData get _icon =>
      widget.config.customIcon ?? widget.config.type.icon;

  // ─── Build ────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final safePadding = MediaQuery.of(context).padding;
    final effectiveRadius = widget.config.borderRadius ?? Radii.base;

    double? top, bottom;
    switch (widget.config.position) {
      case ToastPosition.top:
        top = Spacing.base;
        break;
      case ToastPosition.topSafe:
        top = safePadding.top + Spacing.base;
        break;
      case ToastPosition.bottom:
        bottom = Spacing.base;
        break;
      case ToastPosition.bottomSafe:
        bottom = safePadding.bottom + Spacing.base;
        break;
      case ToastPosition.center:
        break;
    }

    return Positioned(
      top: top,
      bottom: bottom,
      left: Spacing.base,
      right: Spacing.base,
      child: widget.config.position == ToastPosition.center
          ? Center(child: _buildToast(effectiveRadius))
          : _buildToast(effectiveRadius),
    );
  }

  Widget _buildToast(double effectiveRadius) {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: Spacing.base,
              vertical: Spacing.md,
            ),
            decoration: BoxDecoration(
              color: _cardColor,
              borderRadius: BorderRadius.circular(effectiveRadius),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
              border: Border.all(
                color: _borderColor,
                width: 1,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Заголовок (якщо є)
                if (widget.config.title != null) ...[
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      children: [
                        Icon(_icon, color: _iconColor, size: 14),
                        const SizedBox(width: Spacing.xs),
                        Expanded(
                          child: Text(
                            widget.config.title!,
                            style: AppTypography.labelMedium.copyWith(
                              color: _iconColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                // Індикатор прогресу зверху
                if (widget.config.showProgress)
                  _buildProgressBar(),
                // Основний контент
                Row(
                  children: [
                    // Іконка
                    if (widget.config.title == null) ...[
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: _iconColor.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(Radii.sm),
                        ),
                        child: Icon(
                          _icon,
                          color: _iconColor,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: Spacing.md),
                    ],
                    // Текст
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            widget.config.message,
                            style: AppTypography.bodyMedium.copyWith(
                              color: _textColor,
                            ),
                          ),
                          // Підзаголовок
                          if (widget.config.subtitle != null) ...[
                            const SizedBox(height: 2),
                            Text(
                              widget.config.subtitle!,
                              style: AppTypography.caption.copyWith(
                                color: _hintColor,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    // Кнопка дії
                    if (widget.config.actionLabel != null) ...[
                      const SizedBox(width: Spacing.sm),
                      GestureDetector(
                        onTap: () {
                          widget.config.actionCallback?.call();
                          _dismiss();
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: _iconColor.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(Radii.sm),
                          ),
                          child: Text(
                            widget.config.actionLabel!,
                            style: AppTypography.labelMedium.copyWith(
                              color: _iconColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                    // Кнопка закриття
                    if (widget.config.dismissible)
                      GestureDetector(
                        onTap: _dismiss,
                        child: Icon(
                          Icons.close,
                          color: _hintColor,
                          size: 18,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Індикатор прогресу автозакриття.
  Widget _buildProgressBar() {
    if (widget.effectiveDuration == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 1.0, end: 0.0),
        duration: widget.effectiveDuration!,
        builder: (context, value, child) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: value,
              backgroundColor: _borderColor,
              valueColor: AlwaysStoppedAnimation<Color>(_iconColor),
              minHeight: 2,
            ),
          );
        },
      ),
    );
  }

  /// Будує контейнер заголовка сповіщення.
  ///
  /// Відображає іконку та текст заголовка поруч.
  Widget _buildTitleRow() {
    if (widget.config.title == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(_icon, color: _iconColor, size: 14),
          const SizedBox(width: Spacing.xs),
          Expanded(
            child: Text(
              widget.config.title!,
              style: AppTypography.labelMedium.copyWith(
                color: _iconColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Будує кнопку дії на сповіщенні.
  ///
  /// Якщо є [actionLabel] та [actionCallback], відображає
  /// стилізовану кнопку праворуч від тексту.
  Widget _buildActionButton() {
    if (widget.config.actionLabel == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(left: Spacing.sm),
      child: GestureDetector(
        onTap: () {
          widget.config.actionCallback?.call();
          _dismiss();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 6,
          ),
          decoration: BoxDecoration(
            color: _iconColor.withOpacity(0.15),
            borderRadius: BorderRadius.circular(Radii.sm),
          ),
          child: Text(
            widget.config.actionLabel!,
            style: AppTypography.labelMedium.copyWith(
              color: _iconColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  /// Будує кнопку закриття сповіщення.
  ///
  /// Відображає хрестик, якщо [dismissible] увімкнений.
  Widget _buildCloseButton() {
    if (!widget.config.dismissible) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(left: Spacing.sm),
      child: GestureDetector(
        onTap: _dismiss,
        child: Icon(
          Icons.close,
          color: _hintColor,
          size: 18,
        ),
      ),
    );
  }

  /// Будує підзаголовок сповіщення.
  ///
  /// Відображає додатковий текст під основним повідомленням.
  Widget _buildSubtitle() {
    if (widget.config.subtitle == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 2),
      child: Text(
        widget.config.subtitle!,
        style: AppTypography.caption.copyWith(
          color: _hintColor,
        ),
      ),
    );
  }

  /// Будує контейнер іконки типу сповіщення.
  ///
  /// Круглий контейнер з напівпрозорим фоном та іконкою.
  Widget _buildIconContainer() {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: _iconColor.withOpacity(0.12),
        borderRadius: BorderRadius.circular(Radii.sm),
      ),
      child: Icon(
        _icon,
        color: _iconColor,
        size: 18,
      ),
    );
  }
}

// ─── Toast Configuration Extensions ──────────────────────────────────────────

/// Розширення для [ToastConfig] з додатковими computed properties.
///
/// Надає зручні методи для перевірки стану конфігурації
/// та формування рядків для debug/log.
extension ToastConfigExtensions on ToastConfig {
  /// Чи це сповіщення має будь-який кастомний стиль.
  bool get hasCustomStyle => customIcon != null || customColor != null;

  /// Чи це сповіщення має кнопку дії.
  bool get hasAction => actionLabel != null && actionCallback != null;

  /// Чи це сповіщення має будь-який текстовий контент крім message.
  bool get hasRichContent => title != null || subtitle != null;

  /// Чи це сповіщення інформативного типу (без попередження/помилки).
  bool get isInformational =>
      type == ToastType.info ||
      type == ToastType.success ||
      type == ToastType.xp ||
      type == ToastType.coins ||
      type == ToastType.streak ||
      type == ToastType.badge ||
      type == ToastType.sync ||
      type == ToastType.backup ||
      type == ToastType.notification;

  /// Чи це сповіщення з важливістю (попередження або помилка).
  bool get isCritical =>
      type == ToastType.error || type == ToastType.warning;

  /// Повертає опис конфігурації для debug-логування.
  ///
  /// Форматує всі параметри у зручний рядок.
  String get debugDescription {
    final parts = <String>[
      'ToastConfig(',
      'type: ${type.label},',
      'message: "$message",',
      if (title != null) 'title: "$title",',
      if (subtitle != null) 'subtitle: "$subtitle",',
      'persistent: $isPersistent,',
      'dismissible: $dismissible,',
      if (hasCustomStyle) 'custom: true,',
      if (hasAction) 'action: "${actionLabel!}",',
      'position: ${position.name},',
      'haptic: ${enableHaptic},',
    ];
    return '${parts.join(' ')})';
  }

  /// Повертає орієнтовну тривалість показу.
  ///
  /// Error — довше, info — коротше.
  Duration get suggestedDuration {
    if (isPersistent) return Duration.zero;
    if (duration != null) return duration!;
    switch (type) {
      case ToastType.error:
        return const Duration(seconds: 5);
      case ToastType.warning:
        return const Duration(seconds: 4);
      case ToastType.badge:
        return const Duration(seconds: 4);
      case ToastType.streak:
        return const Duration(seconds: 3);
      default:
        return AppDurations.toast;
    }
  }

  /// Створює копію конфігурації з оновленими параметрами.
  ToastConfig copyWith({
    String? message,
    ToastType? type,
    bool? isLightTheme,
    Duration? duration,
    String? actionLabel,
    VoidCallback? actionCallback,
    VoidCallback? onDismiss,
    bool? showProgress,
    ToastPosition? position,
    IconData? customIcon,
    Color? customColor,
    bool? enableHaptic,
    bool? isPersistent,
    String? title,
    String? subtitle,
    bool? dismissible,
    Duration? animationDuration,
    double? borderRadius,
  }) {
    return ToastConfig(
      message: message ?? this.message,
      type: type ?? this.type,
      isLightTheme: isLightTheme ?? this.isLightTheme,
      duration: duration ?? this.duration,
      actionLabel: actionLabel ?? this.actionLabel,
      actionCallback: actionCallback ?? this.actionCallback,
      onDismiss: onDismiss ?? this.onDismiss,
      showProgress: showProgress ?? this.showProgress,
      position: position ?? this.position,
      customIcon: customIcon ?? this.customIcon,
      customColor: customColor ?? this.customColor,
      enableHaptic: enableHaptic ?? this.enableHaptic,
      isPersistent: isPersistent ?? this.isPersistent,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      dismissible: dismissible ?? this.dismissible,
      animationDuration: animationDuration ?? this.animationDuration,
      borderRadius: borderRadius ?? this.borderRadius,
    );
  }
}

// ─── Toast Validation ─────────────────────────────────────────────────────────

/// Методи валідації для конфігурації сповіщень.
///
/// Перевіряє коректність параметрів перед показом.
class ToastValidation {
  ToastValidation._();

  /// Перевіряє, чи повідомлення не пусте.
  static bool isValidMessage(String message) {
    return message.trim().isNotEmpty;
  }

  /// Перевіряє, чи довжина повідомлення в допустимих межах.
  ///
  /// Максимальна довжина — 200 символів.
  static bool isValidMessageLength(String message) {
    return message.length <= 200;
  }

  /// Перевіряє, чи title в допустимих межах.
  ///
  /// Максимальна довжина — 100 символів.
  static bool isValidTitle(String? title) {
    if (title == null) return true;
    return title.length <= 100;
  }

  /// Перевіряє, чи subtitle в допустимих межах.
  ///
  /// Максимальна довжина — 150 символів.
  static bool isValidSubtitle(String? subtitle) {
    if (subtitle == null) return true;
    return subtitle.length <= 150;
  }

  /// Перевіряє, чи action label в допустимих межах.
  static bool isValidActionLabel(String label) {
    return label.isNotEmpty && label.length <= 20;
  }

  /// Повертає опис помилки валідації.
  static String getErrorDescription(String field, String value) {
    return 'Некоректне значення $field: "$value"';
  }

  /// Повертає список усіх помилок валідації для конфігурації.
  ///
  /// Повертає список рядків з описом помилок.
  static List<String> validateAll(ToastConfig config) {
    final errors = <String>[];
    if (!isValidMessage(config.message)) {
      errors.add('Повідомлення не може бути пустим');
    }
    if (!isValidMessageLength(config.message)) {
      errors.add('Повідомлення задовге (макс. 200 символів)');
    }
    if (!isValidTitle(config.title)) {
      errors.add('Заголовок задовгий (макс. 100 символів)');
    }
    if (!isValidSubtitle(config.subtitle)) {
      errors.add('Підзаголовок задовгий (макс. 150 символів)');
    }
    return errors;
  }
}

// ─── Toast Theme Helpers ────────────────────────────────────────────────────────

/// Допоміжний клас для визначення кольорів toast залежно від теми.
///
/// Центральний точка для всіх кольорових рішень сповіщень.
class ToastThemeHelpers {
  ToastThemeHelpers._();

  /// Повертає колір фону картки сповіщення залежно від теми.
  static Color cardColor({required bool isLightTheme}) {
    return isLightTheme ? AppColorsMonitor.cardElevated : AppColorsPS5.cardElevated;
  }

  /// Повертає колір тексту залежно від теми.
  static Color textColor({required bool isLightTheme}) {
    return isLightTheme ? AppColorsMonitor.textPrimary : AppColorsPS5.textPrimary;
  }

  /// Повертає колір підказки залежно від теми.
  static Color hintColor({required bool isLightTheme}) {
    return isLightTheme ? AppColorsMonitor.textHint : AppColorsPS5.textHint;
  }

  /// Повертає колір рамки залежно від теми.
  static Color borderColor({required bool isLightTheme}) {
    return isLightTheme ? AppColorsMonitor.border : AppColorsPS5.border;
  }

  /// Повертає ефективний колір іконки з урахуванням кастомного.
  static Color resolveIconColor({
    required ToastType type,
    Color? customColor,
  }) {
    return customColor ?? type.color;
  }

  /// Повертає кольори тіні для toast залежно від типу.
  ///
  /// Повертає (iconColor, shadowColor).
  static ({Color icon, Color shadow}) resolveTypeColors({
    required ToastType type,
    Color? customColor,
  }) {
    final effectiveColor = customColor ?? type.color;
    return (
      icon: effectiveColor,
      shadow: effectiveColor.withOpacity(0.4),
    );
  }

  /// Повертає тривалість анімації залежно від позиції.
  static Duration animationDurationForPosition(ToastPosition position) {
    switch (position) {
      case ToastPosition.center:
        return const Duration(milliseconds: 300);
      case ToastPosition.top:
      case ToastPosition.topSafe:
        return const Duration(milliseconds: 250);
      case ToastPosition.bottom:
      case ToastPosition.bottomSafe:
        return const Duration(milliseconds: 250);
    }
  }

  /// Повертає Offset для появи залежно від позиції.
  static Offset slideOffsetForPosition(ToastPosition position) {
    switch (position) {
      case ToastPosition.top:
      case ToastPosition.topSafe:
        return const Offset(0, -1);
      case ToastPosition.bottom:
      case ToastPosition.bottomSafe:
        return const Offset(0, 1);
      case ToastPosition.center:
        return Offset.zero;
    }
  }
}

// ─── Toast Preset Builders ──────────────────────────────────────────────────────

/// Зручні методи для створення типових сповіщень.
///
/// Дозволяє створювати toast з мінімальними параметрами.
class ToastPresets {
  ToastPresets._();

  /// Показує сповіщення про успішне завершення дії.
  ///
  /// [context] — контекст build.
  /// [message] — текст повідомлення.
  /// [actionLabel] — текст кнопки дії (наприклад, "Скасувати").
  /// [onUndo] — callback для кнопки дії.
  static void successWithUndo(
    BuildContext context, {
    required String message,
    required VoidCallback onUndo,
    String? title,
    bool isLightTheme = false,
  }) {
    AppToast.show(
      context,
      message: message,
      type: ToastType.success,
      actionLabel: 'Скасувати',
      actionCallback: onUndo,
      title: title,
      isLightTheme: isLightTheme,
    );
  }

  /// Показує сповіщення про помилку з кнопкою "Повторити".
  ///
  /// [context] — контекст build.
  /// [message] — текст повідомлення.
  /// [onRetry] — callback для кнопки "Повторити".
  static void errorWithRetry(
    BuildContext context, {
    required String message,
    required VoidCallback onRetry,
    String? title,
    bool isLightTheme = false,
  }) {
    AppToast.show(
      context,
      message: message,
      type: ToastType.error,
      actionLabel: 'Повторити',
      actionCallback: onRetry,
      title: title,
      isLightTheme: isLightTheme,
    );
  }

  /// Показує попередження з кнопкою "Дізнатися".
  ///
  /// [context] — контекст build.
  /// [message] — текст повідомлення.
  /// [onLearnMore] — callback для кнопки "Дізнатися".
  static void warningWithDetails(
    BuildContext context, {
    required String message,
    required VoidCallback onLearnMore,
    String? title,
    bool isLightTheme = false,
  }) {
    AppToast.show(
      context,
      message: message,
      type: ToastType.warning,
      actionLabel: 'Дізнатися',
      actionCallback: onLearnMore,
      title: title,
      isLightTheme: isLightTheme,
    );
  }

  /// Показує інформативне сповіщення з заголовком.
  ///
  /// [context] — контекст build.
  /// [title] — заголовок сповіщення.
  /// [message] — текст повідомлення.
  static void infoWithTitle(
    BuildContext context, {
    required String title,
    required String message,
    bool isLightTheme = false,
  }) {
    AppToast.show(
      context,
      message: message,
      type: ToastType.info,
      title: title,
      isLightTheme: isLightTheme,
    );
  }

  /// Показує сповіщення з прогрес-баром.
  ///
  /// Корисно для довгих операцій (наприклад, завантаження файлу).
  static void withProgress(
    BuildContext context, {
    required String message,
    required Duration duration,
    ToastType type = ToastType.info,
    String? title,
    bool isLightTheme = false,
  }) {
    AppToast.show(
      context,
      message: message,
      type: type,
      showProgress: true,
      duration: duration,
      title: title,
      isLightTheme: isLightTheme,
    );
  }

  /// Показує сповіщення з кастомною іконкою та кольором.
  ///
  /// [context] — контекст build.
  /// [message] — текст повідомлення.
  /// [icon] — кастомна іконка.
  /// [color] — кастомний колір.
  static void custom(
    BuildContext context, {
    required String message,
    required IconData icon,
    required Color color,
    String? title,
    bool isLightTheme = false,
    Duration? duration,
  }) {
    AppToast.show(
      context,
      message: message,
      type: ToastType.info,
      icon: icon,
      color: color,
      title: title,
      isLightTheme: isLightTheme,
      duration: duration,
    );
  }
}

// ─── Toast Type Extensions ───────────────────────────────────────────────────────

/// Розширення для [ToastType] з computed properties та допоміжними методами.
extension ToastTypeExtensions on ToastType {
  /// Пріоритет сповіщення (чим вище — тим важливіше).
  ///
  /// error = 3, warning = 2, success/info = 1, інші = 0.
  int get priority {
    switch (this) {
      case ToastType.error:
        return 3;
      case ToastType.warning:
        return 2;
      case ToastType.success:
      case ToastType.info:
      case ToastType.xp:
      case ToastType.coins:
      case ToastType.streak:
        return 1;
      default:
        return 0;
    }
  }

  /// Чи цей тип потребує тривалий показ.
  bool get isLongDuration {
    return this == ToastType.error || this == ToastType.badge;
  }

  /// Чи цей тип є гейміфікованим (XP, монети, серія, досягнення).
  bool get isGamified =>
      this == ToastType.xp ||
      this == ToastType.coins ||
      this == ToastType.streak ||
      this == ToastType.badge;

  /// Чи цей тип є системним (синхронізація, бекап, вихід).
  bool get isSystem =>
      this == ToastType.sync ||
      this == ToastType.backup ||
      this == ToastType.logout;

  /// Індекс типу (для серіалізації).
  int get index => ToastType.values.indexOf(this);

  /// Опис типу для debug-логування.
  String get debugString => 'ToastType($label, priority: $priority, haptic: ${haptic.name})';

  /// Чи цей тип може мати прогрес-бар.
  bool get supportsProgress => true;

  /// Рекомендована тривалість показу залежно від типу.
  Duration get recommendedDuration {
    switch (this) {
      case ToastType.error:
        return const Duration(seconds: 5);
      case ToastType.warning:
        return const Duration(seconds: 4);
      case ToastType.badge:
        return const Duration(seconds: 4);
      case ToastType.streak:
        return const Duration(seconds: 3);
      case ToastType.xp:
      case ToastType.coins:
        return const Duration(seconds: 2);
      default:
        return const Duration(seconds: 2);
    }
  }
}

// ─── Haptic Feedback Type Extensions ──────────────────────────────────────────

/// Розширення для [HapticFeedbackType] з computed properties.
extension HapticFeedbackTypeExtensions on HapticFeedbackType {
  /// Чи цей тип активує тактильний відгук.
  bool get isActive => this != HapticFeedbackType.none;

  /// Інтенсивність відгуку (для сортування).
  int get intensity {
    switch (this) {
      case HapticFeedbackType.heavy:
        return 3;
      case HapticFeedbackType.medium:
        return 2;
      case HapticFeedbackType.light:
        return 1;
      case HapticFeedbackType.none:
        return 0;
    }
  }

  /// Опис типу для debug-логування.
  String get debugString => 'HapticFeedbackType($name, intensity: $intensity)';

  /// Створює Duration для відгуку залежно від типу.
  Duration get duration {
    switch (this) {
      case HapticFeedbackType.heavy:
        return const Duration(milliseconds: 100);
      case HapticFeedbackType.medium:
        return const Duration(milliseconds: 50);
      case HapticFeedbackType.light:
        return const Duration(milliseconds: 30);
      case HapticFeedbackType.none:
        return Duration.zero;
    }
  }
}

// ─── Toast Position Extensions ─────────────────────────────────────────────────

/// Розширення для [ToastPosition] з computed properties.
extension ToastPositionExtensions on ToastPosition {
  /// Чи ця позиція на верхній частині екрана.
  bool get isTop =>
      this == ToastPosition.top || this == ToastPosition.topSafe;

  /// Чи ця позиція на нижній частині екрана.
  bool get isBottom =>
      this == ToastPosition.bottom || this == ToastPosition.bottomSafe;

  /// Чи ця позиція враховує безпечну зону.
  bool get isSafe =>
      this == ToastPosition.topSafe || this == ToastPosition.bottomSafe;

  /// Чи ця позиція вимагає центрування.
  bool get isCenter => this == ToastPosition.center;

  /// Напрямок з'явлення (slide direction).
  Alignment get alignment {
    switch (this) {
      case ToastPosition.top:
      case ToastPosition.topSafe:
        return Alignment.topCenter;
      case ToastPosition.bottom:
      case ToastPosition.bottomSafe:
        return Alignment.bottomCenter;
      case ToastPosition.center:
        return Alignment.center;
    }
  }

  /// Offset для slide-анімації входу.
  Offset get slideOffset {
    switch (this) {
      case ToastPosition.top:
      case ToastPosition.topSafe:
        return const Offset(0, -1);
      case ToastPosition.bottom:
      case ToastPosition.bottomSafe:
        return const Offset(0, 1);
      case ToastPosition.center:
        return Offset.zero;
    }
  }

  /// Опис позиції для debug-логування.
  String get debugString => 'ToastPosition($name, alignment: $alignment)';

  /// Рекомендована тривалість анімації для цієї позиції.
  Duration get animationDuration {
    switch (this) {
      case ToastPosition.center:
        return const Duration(milliseconds: 300);
      default:
        return const Duration(milliseconds: 250);
    }
  }
}

// ─── Toast Constants ────────────────────────────────────────────────────────────

/// Константи для toast-віджета.
///
/// Містить усі числові значення, ліміти та налаштування
/// для сповіщень в додатку Nexora.
class ToastConstants {
  ToastConstants._();

  /// Мінімальна тривалість показу сповіщення.
  static const Duration minDuration = Duration(milliseconds: 1000);

  /// Максимальна тривалість показу сповіщення.
  static const Duration maxDuration = Duration(seconds: 10);

  /// Стандартна тривалість показу.
  static const Duration defaultDuration = Duration(seconds: 3);

  /// Тривалість показу для error-сповіщень.
  static const Duration errorDuration = Duration(seconds: 5);

  /// Тривалість показу для warning-сповіщень.
  static const Duration warningDuration = Duration(seconds: 4);

  /// Тривалість показу для gamified-сповіщень.
  static const Duration gamifiedDuration = Duration(seconds: 3);

  /// Максимальна кількість символів у повідомленні.
  static const int maxMessageLength = 200;

  /// Максимальна кількість символів у заголовку.
  static const int maxTitleLength = 100;

  /// Максимальна кількість символів у підзаголовку.
  static const int maxSubtitleLength = 150;

  /// Максимальна кількість символів у action label.
  static const int maxActionLabelLength = 20;

  /// Максимальна кількість одночасних сповіщень.
  static const int maxConcurrentToasts = 3;

  /// Максимальна кількість постійних сповіщень.
  static const int maxPersistentToasts = 2;

  /// Ширина іконки сповіщення.
  static const double iconContainerSize = 32.0;

  /// Розмір іконки сповіщення.
  static const double iconSize = 18.0;

  /// Мінімальний розмір іконки заголовка.
  static const double titleIconSize = 14.0;

  /// Мінімальна ширина кнопки закриття.
  static const double closeButtonSize = 18.0;

  /// Товщина рамки навколо сповіщення.
  static const double borderWidth = 1.0;

  /// Розмір progress bar.
  static const double progressHeight = 2.0;

  /// Відступ між іконкою та текстом.
  static const double iconTextSpacing = 12.0;

  /// Розмір badge text font.
  static const double badgeFontSize = 10.0;

  /// Blur radius тіні сповіщення.
  static const double shadowBlurRadius = 12.0;

  /// Вертикальне зміщення тіні сповіщення.
  static const double shadowOffsetY = 4.0;

  /// Opacity тіні сповіщення.
  static const double shadowOpacity = 0.2;

  /// Кількість точок (dots) для трійяркрядкового loading.
  static const int loadingDotsCount = 3;

  /// Тривалість анімації loading dots.
  static const Duration loadingDotsDuration = Duration(milliseconds: 400);

  /// Відступ всередині сповіщення (горизонтальний).
  static const double innerPaddingH = 16.0;

  /// Відступ всередині сповіщення (вертикальний).
  static const double innerPaddingV = 12.0;

  /// Відступ знизу progress bar.
  static const double progressBottomPadding = 8.0;

  /// Кастомний радіус для action button.
  static const double actionButtonRadius = 8.0;

  /// Padding для action button (горизонтальний).
  static const double actionButtonPaddingH = 12.0;

  /// Padding для action button (вертикальний).
  static const double actionButtonPaddingV = 6.0;
}

// ─── Toast Accessibility ─────────────────────────────────────────────────────────

/// Допоміжні методи для accessibility сповіщень.
///
/// Генерує семантичні мітки та описи для TalkBack/VoiceOver.
class ToastAccessibility {
  ToastAccessibility._();

  /// Створює семантичну мітку для сповіщення.
  static String semanticLabel({
    required ToastType type,
    required String message,
    String? title,
    bool hasAction = false,
    String? actionLabel,
    bool showProgress = false,
  }) {
    final buffer = StringBuffer();
    buffer.write(type.label);
    if (title != null) {
      buffer.write(': $title');
    }
    buffer.write('. $message');
    if (hasAction && actionLabel != null) {
      buffer.write('. Кнопка: $actionLabel');
    }
    if (showProgress) {
      buffer.write('. Показую прогрес');
    }
    return buffer.toString();
  }

  /// Створює опис announcement для accessibility.
  static String announcementMessage({
    required ToastType type,
    required String message,
    int? badgeCount,
  }) {
    final buffer = StringBuffer();
    buffer.write(type.label);
    buffer.write(': $message');
    if (badgeCount != null) {
      buffer.write(' ($badgeCount)');
    }
    return buffer.toString();
  }

  /// Створює опис для live region.
  static String liveRegionMessage({
    required String message,
    required bool isPersistent,
    ToastType type = ToastType.info,
  }) {
    if (isPersistent) {
      return 'Постійне сповіщення: $message';
    }
    return 'Сповіщення (${type.label}): $message';
  }
}

// ─── Toast Animation Config ──────────────────────────────────────────────────────

/// Конфігурація анімацій для toast-віджета.
///
/// Центральний місце для всіх параметрів анімацій:
/// криві, тривалості, direction.
class ToastAnimationConfig {
  ToastAnimationConfig._();

  /// Створює стандартний SlideTransition для сповіщення.
  static AnimatedBuilder slideIn({
    required AnimationController controller,
    required Widget child,
    required ToastPosition position,
  }) {
    final offset = position.slideOffset;
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: offset,
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: controller,
            curve: Curves.easeOutCubic,
          )),
          child: FadeTransition(
            opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
              CurvedAnimation(
                parent: controller,
                curve: Curves.easeOut,
              ),
            ),
            child: child,
          ),
        );
      },
      child: child,
    );
  }

  /// Повертає криву анімації залежно від позиції.
  static Curve curveForPosition(ToastPosition position) {
    switch (position) {
      case ToastPosition.center:
        return Curves.easeInOutBack;
      case ToastPosition.top:
      case ToastPosition.topSafe:
        return Curves.easeOutCubic;
      case ToastPosition.bottom:
      case ToastPosition.bottomSafe:
        return Curves.easeOutCubic;
    }
  }

  /// Обчислює затримку перед показом наступного сповіщення.
  ///
  /// Додає невелику паузу між сповіщеннями для кращого UX.
  static Duration dismissToNextDelay({
    required ToastType previousType,
    required ToastType nextType,
  }) {
    if (previousType.priority >= nextType.priority) {
      return const Duration(milliseconds: 200);
    }
    return const Duration(milliseconds: 100);
  }

  /// Створює Interval для staggered-анімації.
  static Interval staggerInterval(int index, {double begin = 0.0, double end = 1.0}) {
    final delay = index * 0.15;
    return Interval(
      delay.clamp(0.0, 0.85),
      end,
    );
  }
}

// ─── Toast Queue Stats ────────────────────────────────────────────────────────────

/// Дані про стан черги сповіщень.
///
/// Використовується для debug та моніторингу.
class ToastQueueStats {
  ToastQueueStats({
    required this.totalShown,
    required this.totalDismissed,
    required this.queueDepth,
    required this.persistentCount,
    required this.currentType,
  });

  /// Загальна кількість показаних сповіщень.
  final int totalShown;

  /// Загальна кількість закритих сповіщень.
  final int totalDismissed;

  /// Поточна глибина черги.
  final int queueDepth;

  /// Кількість постійних сповіщень.
  final int persistentCount;

  /// Тип поточного активного сповіщення.
  final ToastType? currentType;

  /// Чи черга порожня.
  bool get isEmpty => queueDepth == 0 && persistentCount == 0;

  /// Кількість активних сповіщень.
  int get activeCount => (queueDepth > 0 ? 1 : 0) + persistentCount;

  /// Опис стану черги для debug.
  String get debugDescription {
    return 'Queue(shown: $totalShown, '
        'dismissed: $totalDismissed, '
        'depth: $queueDepth, '
        'persistent: $persistentCount, '
        'active: $activeCount)';
  }

  /// Створює порожній stats.
  factory ToastQueueStats.empty() => ToastQueueStats(
    totalShown: 0,
    totalDismissed: 0,
    queueDepth: 0,
    persistentCount: 0,
    currentType: null,
  );

  /// Копія з оновленим станом.
  ToastQueueStats copyWith({
    int? totalShown,
    int? totalDismissed,
    int? queueDepth,
    int? persistentCount,
    ToastType? currentType,
  }) {
    return ToastQueueStats(
      totalShown: totalShown ?? this.totalShown,
      totalDismissed: totalDismissed ?? this.totalDismissed,
      queueDepth: queueDepth ?? this.queueDepth,
      persistentCount: persistentCount ?? this.persistentCount,
      currentType: currentType ?? this.currentType,
    );
  }
}

// ─── Toast Format Helpers ────────────────────────────────────────────────────────

/// Допоміжні методи для форматування вмісту сповіщень.
///
/// Надає методи для розуміння, трункації,
/// форматування сум та кількостей.
class ToastFormatHelpers {
  ToastFormatHelpers._();

  /// Розуміює повідомлення до максимальної довжини з "…".
  static String truncateMessage(String message, {int maxLength = 200}) {
    if (message.length <= maxLength) return message;
    return '${message.substring(0, maxLength - 1)}…';
  }

  /// Форматує заголовок з обмеженням довжини.
  static String formatTitle(String? title, {int maxLength = 100}) {
    if (title == null) return '';
    if (title.length <= maxLength) return title;
    return '${title.substring(0, maxLength - 1)}…';
  }

  /// Форматує підзаголовок з обмеженням довжини.
  static String formatSubtitle(String? subtitle, {int maxLength = 150}) {
    if (subtitle == null) return '';
    if (subtitle.length <= maxLength) return subtitle;
    return '${subtitle.substring(0, maxLength - 1)}…';
  }

  /// Форматує кількість непрочитаних для сповіщення.
  static String formatBadgeCount(int count) {
    if (count <= 0) return '';
    if (count > 99) return '99+';
    return '$count';
  }

  /// Форматує тривалість для display.
  static String formatDuration(Duration duration) {
    if (duration.inSeconds == 0) return ' миттєво';
    if (duration.inSeconds < 60) return '${duration.inSeconds}с';
    final minutes = duration.inMinutes;
    if (minutes < 60) return '$minutes хв';
    return '${minutes ~/ 60}г ${minutes % 60}хв';
  }

  /// Форматує тип та повідомлення для логування.
  static String formatLogEntry({
    required ToastType type,
    required String message,
    ToastPosition? position,
    bool? isPersistent,
  }) {
    final parts = <String>['[${type.label}] $message'];
    if (position != null) parts.add('(pos: ${position.name})');
    if (isPersistent == true) parts.add('(persistent)');
    return parts.join(' ');
  }

  /// Створює повний опис сповіщення для debug.
  static String fullDescription(ToastConfig config) {
    final parts = <String>[
      'Toast:',
      'type=${config.type.label}',
      'msg="${config.message}"',
    ];
    if (config.title != null) parts.add('title="${config.title}"');
    if (config.subtitle != null) parts.add('sub="${config.subtitle}"');
    if (config.isPersistent) parts.add('persistent');
    parts.add('pos=${config.position.name}');
    parts.add('haptic=${config.enableHaptic}');
    if (config.actionLabel != null) {
      parts.add('action="${config.actionLabel}"');
    }
    return parts.join(', ');
  }
}

// ─── Toast Position Extensions ───────────────────────────────────────────────

/// Розширення для [ToastPosition] з computed properties.
extension ToastPositionExtensions on ToastPosition {
  /// Чи позиція знаходиться вгорі екрана.
  bool get isTop => this == ToastPosition.top || this == ToastPosition.topSafe;

  /// Чи позиція знаходиться знизу екрана.
  bool get isBottom =>
      this == ToastPosition.bottom || this == ToastPosition.bottomSafe;

  /// Чи позиція використовує safe area insets.
  bool get isSafe =>
      this == ToastPosition.topSafe || this == ToastPosition.bottomSafe;

  /// Напрямок появи анімації (slide direction).
  Offset get slideDirection {
    switch (this) {
      case ToastPosition.top:
      case ToastPosition.topSafe:
        return const Offset(0, -1);
      case ToastPosition.bottom:
      case ToastPosition.bottomSafe:
        return const Offset(0, 1);
      case ToastPosition.center:
        return Offset.zero;
    }
  }

  /// Крива анімації для цієї позиції.
  Curve get entryCurve {
    switch (this) {
      case ToastPosition.top:
      case ToastPosition.topSafe:
        return Curves.easeOutCubic;
      case ToastPosition.bottom:
      case ToastPosition.bottomSafe:
        return Curves.easeOutCubic;
      case ToastPosition.center:
        return Curves.easeOutBack;
    }
  }

  /// Рекомендована тривалість анімації для позиції.
  Duration get recommendedAnimationDuration {
    switch (this) {
      case ToastPosition.center:
        return const Duration(milliseconds: 300);
      case ToastPosition.top:
      case ToastPosition.topSafe:
        return const Duration(milliseconds: 250);
      case ToastPosition.bottom:
      case ToastPosition.bottomSafe:
        return const Duration(milliseconds: 250);
    }
  }

  /// Рекомендований відступ від краю екрана.
  double get recommendedInset {
    switch (this) {
      case ToastPosition.top:
        return Spacing.base;
      case ToastPosition.topSafe:
        return Spacing.base; // + MediaQuery.padding.top
      case ToastPosition.bottom:
        return Spacing.base;
      case ToastPosition.bottomSafe:
        return Spacing.base; // + MediaQuery.padding.bottom
      case ToastPosition.center:
        return 0.0;
    }
  }

  /// Українська назва позиції.
  String get localizedName {
    switch (this) {
      case ToastPosition.top:
        return 'Зверху';
      case ToastPosition.topSafe:
        return 'Зверху (безпечна зона)';
      case ToastPosition.bottom:
        return 'Знизу';
      case ToastPosition.bottomSafe:
        return 'Знизу (безпечна зона)';
      case ToastPosition.center:
        return 'Центр';
    }
  }
}

// ─── Toast Type Extensions ────────────────────────────────────────────────────

/// Розширення для [ToastType] з computed properties.
extension ToastTypeExtensions on ToastType {
  /// Чи цей тип сповіщення є критичним (потребує уваги користувача).
  bool get isCritical => this == ToastType.error || this == ToastType.warning;

  /// Чи цей тип пов'язаний з гейміфікацією (XP, монети, серія).
  bool get isGamified =>
      this == ToastType.xp ||
      this == ToastType.coins ||
      this == ToastType.streak ||
      this == ToastType.badge;

  /// Чи цей тип пов'язаний з системними операціями.
  bool get isSystem =>
      this == ToastType.sync ||
      this == ToastType.backup ||
      this == ToastType.logout;

  /// Рекомендована тривалість показу для цього типу.
  Duration get recommendedDuration {
    switch (this) {
      case ToastType.error:
        return const Duration(seconds: 5);
      case ToastType.warning:
        return const Duration(seconds: 4);
      case ToastType.badge:
        return const Duration(seconds: 4);
      case ToastType.streak:
        return const Duration(seconds: 3);
      case ToastType.coins:
        return const Duration(seconds: 3);
      case ToastType.xp:
        return const Duration(seconds: 3);
      case ToastType.info:
        return const Duration(seconds: 3);
      case ToastType.success:
        return const Duration(seconds: 2);
      case ToastType.logout:
        return const Duration(seconds: 3);
      case ToastType.sync:
        return const Duration(seconds: 2);
      case ToastType.backup:
        return const Duration(seconds: 3);
      case ToastType.notification:
        return const Duration(seconds: 4);
    }
  }

  /// Пріоритет сповіщення для черги (вищий = показується першим).
  ///
  /// Error → Warning → Badge → Warning-like → Info → Info-like.
  int get queuePriority {
    switch (this) {
      case ToastType.error:
        return 100;
      case ToastType.warning:
        return 90;
      case ToastType.badge:
        return 80;
      case ToastType.streak:
        return 70;
      case ToastType.coins:
        return 60;
      case ToastType.xp:
        return 55;
      case ToastType.notification:
        return 50;
      case ToastType.sync:
        return 40;
      case ToastType.backup:
        return 35;
      case ToastType.success:
        return 30;
      case ToastType.info:
        return 20;
      case ToastType.logout:
        return 10;
    }
  }

  /// Чи сповіщення цього типу можна переривати іншим.
  bool get canBeInterrupted => !isCritical;

  /// Опис типу для accessibility.
  String get accessibilityDescription {
    switch (this) {
      case ToastType.error:
        return 'Помилка';
      case ToastType.warning:
        return 'Попередження';
      case ToastType.success:
        return 'Успішне завершення';
      case ToastType.info:
        return 'Інформація';
      case ToastType.xp:
        return 'Отримано досвід';
      case ToastType.coins:
        return 'Отримано монети';
      case ToastType.streak:
        return 'Серія продовжена';
      case ToastType.badge:
        return 'Нове досягнення';
      case ToastType.logout:
        return 'Вихід з системи';
      case ToastType.sync:
        return 'Синхронізація';
      case ToastType.backup:
        return 'Резервне копіювання';
      case ToastType.notification:
        return 'Сповіщення';
    }
  }

  /// Опис типу з іконкою для логування.
  String get logIcon {
    switch (this) {
      case ToastType.success:
        return '[OK]';
      case ToastType.error:
        return '[ERR]';
      case ToastType.warning:
        return '[WARN]';
      case ToastType.info:
        return '[INFO]';
      case ToastType.xp:
        return '[XP]';
      case ToastType.coins:
        return '[COIN]';
      case ToastType.streak:
        return '[STREAK]';
      case ToastType.badge:
        return '[BADGE]';
      case ToastType.logout:
        return '[OUT]';
      case ToastType.sync:
        return '[SYNC]';
      case ToastType.backup:
        return '[BACKUP]';
      case ToastType.notification:
        return '[NOTIF]';
    }
  }
}

// ─── Toast Duration Calculator ─────────────────────────────────────────────────

/// Калькулятор оптимальної тривалості показу сповіщення.
///
/// Обчислює тривалість на основі типу, довжини тексту,
/// наявності action button та інших параметрів.
class ToastDurationCalculator {
  ToastDurationCalculator._();

  /// Базові тривалості для кожного типу (мілісекунди).
  static const Map<ToastType, int> _baseDurationsMs = {
    ToastType.success: 2500,
    ToastType.error: 5000,
    ToastType.warning: 4000,
    ToastType.info: 3000,
    ToastType.xp: 3000,
    ToastType.coins: 3000,
    ToastType.streak: 3000,
    ToastType.badge: 4000,
    ToastType.logout: 3000,
    ToastType.sync: 2500,
    ToastType.backup: 3000,
    ToastType.notification: 4000,
  };

  /// Мінімальна тривалість показу (мілісекунди).
  static const int minDurationMs = 1500;

  /// Максимальна тривалість показу (мілісекунди).
  static const int maxDurationMs = 10000;

  /// Додатковий час на кожні 100 символів тексту.
  static const int extraMsPer100Chars = 500;

  /// Додатковий час для повідомлень з action button.
  static const int extraMsForAction = 2000;

  /// Додатковий час для повідомлень з заголовком.
  static const int extraMsForTitle = 500;

  /// Додатковий час для persistent сповіщень.
  static const int extraMsForPersistent = 5000;

  /// Обчислює оптимальну тривалість для сповіщення.
  ///
  /// Враховує тип, довжину тексту, наявність action/title/subtitle.
  static Duration calculate(ToastConfig config) {
    if (config.isPersistent) {
      return const Duration(milliseconds: maxDurationMs);
    }

    var ms = _baseDurationsMs[config.type] ?? 3000;

    // Додатковий час за довжину повідомлення
    final charCount = config.message.length;
    if (charCount > 50) {
      ms += (charCount ~/ 100) * extraMsPer100Chars;
    }

    // Додатковий час за title/subtitle
    if (config.title != null) ms += extraMsForTitle;
    if (config.subtitle != null) ms += extraMsForTitle;

    // Додатковий час за action button
    if (config.hasAction) ms += extraMsForAction;

    // Додатковий час за прогрес
    if (config.showProgress) ms += 1000;

    return Duration(milliseconds: ms.clamp(minDurationMs, maxDurationMs));
  }

  /// Обчислює мінімальну тривалість для читання повідомлення.
  ///
  /// Базується на швидкості читання ~200 символів/хвилину.
  static Duration readingDuration(String text) {
    final readTimeMs = (text.length / 200) * 60000;
    return Duration(
      milliseconds: readTimeMs.round().clamp(minDurationMs, maxDurationMs),
    );
  }

  /// Обчислює тривалість для debug-режиму (швидко).
  static Duration debugDuration() {
    return const Duration(milliseconds: 1000);
  }

  /// Повертає опис обчисленої тривалості.
  static String describeDuration(Duration duration) {
    final ms = duration.inMilliseconds;
    if (ms < 1000) return '$ms мс';
    return '${(ms / 1000).toStringAsFixed(1)} с';
  }
}

// ─── Toast Queue Statistics ────────────────────────────────────────────────────

/// Статистика черги сповіщень.
///
/// Відстежує кількість показаних, відхилених та активних сповіщень
/// за час сесії.
class ToastQueueStatistics {
  ToastQueueStatistics._();

  static int _totalShown = 0;
  static int _totalDismissed = 0;
  static int _totalDismissedByUser = 0;
  static int _totalExpired = 0;
  static int _totalErrors = 0;
  static final Map<ToastType, int> _typeCount = {};

  /// Загальна кількість показаних сповіщень.
  static int get totalShown => _totalShown;

  /// Загальна кількість закритих сповіщень.
  static int get totalDismissed => _totalDismissed;

  /// Кількість сповіщень, закритих користувачем.
  static int get totalDismissedByUser => _totalDismissedByUser;

  /// Кількість сповіщень, що закрилися автоматично.
  static int get totalExpired => _totalExpired;

  /// Кількість помилок під час показу.
  static int get totalErrors => _totalErrors;

  /// Розподіл за типами.
  static Map<ToastType, int> get typeDistribution =>
      Map.unmodifiable(_typeCount);

  /// Реєструє показ сповіщення.
  static void recordShow(ToastType type) {
    _totalShown++;
    _typeCount[type] = (_typeCount[type] ?? 0) + 1;
  }

  /// Реєструє закриття сповіщення.
  static void recordDismiss({bool byUser = false}) {
    _totalDismissed++;
    if (byUser) {
      _totalDismissedByUser++;
    } else {
      _totalExpired++;
    }
  }

  /// Реєструє помилку.
  static void recordError() {
    _totalErrors++;
  }

  /// Найчастіший тип сповіщення.
  ToastType? get mostFrequentType {
    if (_typeCount.isEmpty) return null;
    return _typeCount.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
  }

  /// Кількість показів конкретного типу.
  static int countForType(ToastType type) => _typeCount[type] ?? 0;

  /// Відсоток сповіщень, закритих користувачем.
  double get userDismissRate {
    if (_totalDismissed == 0) return 0.0;
    return _totalDismissedByUser / _totalDismissed;
  }

  /// Повний звіт для debug.
  static String report() {
    final lines = <String>['ToastQueueStatistics:'];
    lines.add('  shown: $_totalShown');
    lines.add('  dismissed: $_totalDismissed');
    lines.add('  byUser: $_totalDismissedByUser');
    lines.add('  expired: $_totalExpired');
    lines.add('  errors: $_totalErrors');
    lines.add('  dismissRate: ${(userDismissRate * 100).toStringAsFixed(1)}%');
    if (_typeCount.isNotEmpty) {
      lines.add('  types:');
      for (final entry in _typeCount.entries) {
        lines.add('    ${entry.key.logIcon} ${entry.key.label}: ${entry.value}');
      }
    }
    return lines.join('\n');
  }

  /// Скидає всю статистику.
  static void reset() {
    _totalShown = 0;
    _totalDismissed = 0;
    _totalDismissedByUser = 0;
    _totalExpired = 0;
    _totalErrors = 0;
    _typeCount.clear();
  }
}

// ─── Toast Debounce Helper ──────────────────────────────────────────────────────

/// Допоміжник для дебаунсу повторних сповіщень.
///
/// Запобігає показу однакових сповіщень надто часто.
class ToastDebounceHelper {
  ToastDebounceHelper._();

  /// Кеш останніх сповіщень (message → timestamp).
  static final Map<String, DateTime> _lastShown = {};

  /// Мінімальний інтервал між однаковими сповіщеннями.
  static const Duration _minInterval = Duration(seconds: 2);

  /// Максимальна кількість записів у кеші.
  static const int _maxCacheSize = 50;

  /// Перевіряє, чи сповіщення можна показати (не заблоковано дебаунсом).
  static bool canShow(String message) {
    final lastTime = _lastShown[message];
    if (lastTime == null) return true;

    final elapsed = DateTime.now().difference(lastTime);
    return elapsed >= _minInterval;
  }

  /// Реєструє показ сповіщення.
  static void markShown(String message) {
    // Очищуємо старі записи при переповненні
    if (_lastShown.length >= _maxCacheSize) {
      _lastShown.remove(
        _lastShown.keys.first,
      );
    }
    _lastShown[message] = DateTime.now();
  }

  /// Повертає час, що залишився до розблокування сповіщення.
  ///
  /// Якщо сповіщення не заблоковано, повертає null.
  Duration? remainingDebounce(String message) {
    final lastTime = _lastShown[message];
    if (lastTime == null) return null;

    final elapsed = DateTime.now().difference(lastTime);
    final remaining = _minInterval - elapsed;
    if (remaining.isNegative) return null;
    return remaining;
  }

  /// Очищає кеш.
  static void clear() {
    _lastShown.clear();
  }

  /// Кількість записів у кеші.
  static int get cacheSize => _lastShown.length;
}

// ─── Toast Swipe Config ────────────────────────────────────────────────────────

/// Конфігурація свайпу для закриття сповіщення.
///
/// Надає параметри для жести закриття сповіщення свайпом.
class ToastSwipeConfig {
  ToastSwipeConfig({
    this.enabled = true,
    this.dismissThreshold = 50.0,
    this.direction = DismissDirection.horizontal,
    this.backgroundOpacity = 0.6,
    this.animationDuration = const Duration(milliseconds: 200),
    this.curve = Curves.easeOutCubic,
  });

  /// Чи свайп для закриття увімкнений.
  final bool enabled;

  /// Мінімальна відстань свайпу для закриття.
  final double dismissThreshold;

  /// Напрямок свайпу для закриття.
  final DismissDirection direction;

  /// Непрозорість фону при свайпі.
  final double backgroundOpacity;

  /// Тривалість анімації закриття.
  final Duration animationDuration;

  /// Крива анімації закриття.
  final Curve curve;

  /// Створює конфігурацію без свайпу.
  factory ToastSwipeConfig.disabled() {
    return ToastSwipeConfig(enabled: false);
  }

  /// Створює конфігурацію з вертикальним свайпом.
  factory ToastSwipeConfig.vertical() {
    return ToastSwipeConfig(
      direction: DismissDirection.vertical,
      dismissThreshold: 60.0,
    );
  }

  /// Створює конфігурацію з горизонтальним свайпом.
  factory ToastSwipeConfig.horizontal() {
    return ToastSwipeConfig(
      direction: DismissDirection.horizontal,
      dismissThreshold: 50.0,
    );
  }

  /// Чи свайп горизонтальний.
  bool get isHorizontal =>
      direction == DismissDirection.horizontal;

  /// Чи свайп вертикальний.
  bool get isVertical =>
      direction == DismissDirection.vertical;

  /// Опис конфігурації.
  @override
  String toString() {
    return 'ToastSwipeConfig('
        'enabled: $enabled, '
        'threshold: $dismissThreshold, '
        'direction: $direction, '
        'duration: ${animationDuration.inMilliseconds}ms)';
  }
}

// ─── Toast Type Extensions ────────────────────────────────────────────────────

/// Розширення для [ToastType] з додатковими computed properties.
extension ToastTypeExtension on ToastType {
  /// Чи цей тип має сильний тактильний відгук.
  bool get hasHeavyHaptic => haptic == HapticFeedbackType.heavy;

  /// Чи цей тип має легкий тактильний відгук.
  bool get hasLightHaptic => haptic == HapticFeedbackType.light;

  /// Чи цей тип не має тактильного відгуку.
  bool get hasNoHaptic => haptic == HapticFeedbackType.none;

  /// Чи цей тип є гейміфікованим (XP, coins, streak, badge).
  bool get isGamified {
    switch (this) {
      case ToastType.xp:
      case ToastType.coins:
      case ToastType.streak:
      case ToastType.badge:
        return true;
      default:
        return false;
    }
  }

  /// Чи цей тип є системним (sync, backup, logout).
  bool get isSystemType {
    switch (this) {
      case ToastType.sync:
      case ToastType.backup:
      case ToastType.logout:
        return true;
      default:
        return false;
    }
  }

  /// Чи цей тип є критичним (error, warning).
  bool get isCriticalType {
    switch (this) {
      case ToastType.error:
      case ToastType.warning:
        return true;
      default:
        return false;
    }
  }

  /// Чи цей тип є позитивним (success, xp, coins, badge, streak).
  bool get isPositiveType {
    switch (this) {
      case ToastType.success:
      case ToastType.xp:
      case ToastType.coins:
      case ToastType.streak:
      case ToastType.badge:
        return true;
      default:
        return false;
    }
  }

  /// Повертає колір іконки з урахуванням кастомного.
  Color effectiveColor({Color? customColor}) {
    return customColor ?? color;
  }

  /// Повертає іконку з урахуванням кастомної.
  IconData effectiveIcon({IconData? customIcon}) {
    return customIcon ?? icon;
  }

  /// Повертає колір тіні для цього типу.
  Color shadowColor({Color? customColor}) {
    final effective = customColor ?? color;
    return effective.withOpacity(0.3);
  }

  /// Повертає колір glow-ефекту.
  Color glowColor({Color? customColor}) {
    final effective = customColor ?? color;
    return effective.withOpacity(0.15);
  }

  /// Повертає колір фону іконки (напівпрозорий).
  Color iconBgColor({Color? customColor}) {
    final effective = customColor ?? color;
    return effective.withOpacity(0.12);
  }

  /// Повертає пріоритет типу (0 = найвищий).
  ///
  /// Error > Warning > Success > Info > Інші.
  int get priority {
    switch (this) {
      case ToastType.error:
        return 0;
      case ToastType.warning:
        return 1;
      case ToastType.success:
        return 2;
      case ToastType.info:
        return 3;
      case ToastType.badge:
        return 4;
      case ToastType.streak:
        return 5;
      case ToastType.xp:
        return 6;
      case ToastType.coins:
        return 7;
      case ToastType.sync:
        return 8;
      case ToastType.backup:
        return 9;
      case ToastType.notification:
        return 10;
      case ToastType.logout:
        return 11;
    }
  }

  /// Повертає опис типу для accessibility.
  String get accessibilityDescription {
    switch (this) {
      case ToastType.success:
        return 'Успішне сповіщення';
      case ToastType.error:
        return 'Помилка';
      case ToastType.warning:
        return 'Попередження';
      case ToastType.info:
        return 'Інформація';
      case ToastType.xp:
        return 'Отримано досвід';
      case ToastType.coins:
        return 'Отримано монети';
      case ToastType.streak:
        return 'Серія продовжена';
      case ToastType.badge:
        return 'Отримано досягнення';
      case ToastType.logout:
        return 'Вихід з системи';
      case ToastType.sync:
        return 'Синхронізація завершена';
      case ToastType.backup:
        return 'Резервне копіювання';
      case ToastType.notification:
        return 'Сповіщення';
    }
  }

  /// Повертає всі типи крім системних.
  static List<ToastType> get userFacingTypes => ToastType.values
      .where((t) => !t.isSystemType)
      .toList();

  /// Повертає всі типи крім критичних.
  static List<ToastType> get nonCriticalTypes => ToastType.values
      .where((t) => !t.isCriticalType)
      .toList();

  /// Повертає всі гейміфіковані типи.
  static List<ToastType> get gamifiedTypes => ToastType.values
      .where((t) => t.isGamified)
      .toList();

  /// Повертає тип за іменем (case-insensitive).
  static ToastType? fromName(String name) {
    final lower = name.toLowerCase();
    for (final type in ToastType.values) {
      if (type.name.toLowerCase() == lower) return type;
    }
    return null;
  }
}

// ─── Toast Position Extensions ────────────────────────────────────────────────

/// Розширення для [ToastPosition] з додатковими computed properties.
extension ToastPositionExtension on ToastPosition {
  /// Чи ця позиція зверху.
  bool get isTop => this == ToastPosition.top || this == ToastPosition.topSafe;

  /// Чи ця позиція знизу.
  bool get isBottom =>
      this == ToastPosition.bottom || this == ToastPosition.bottomSafe;

  /// Чи ця позиція по центру.
  bool get isCenter => this == ToastPosition.center;

  /// Чи ця позиція враховує безпечну зону.
  bool get isSafe =>
      this == ToastPosition.topSafe || this == ToastPosition.bottomSafe;

  /// Повертає напрямок анімації входу.
  Offset get slideBeginOffset {
    switch (this) {
      case ToastPosition.top:
      case ToastPosition.topSafe:
        return const Offset(0, -1);
      case ToastPosition.bottom:
      case ToastPosition.bottomSafe:
        return const Offset(0, 1);
      case ToastPosition.center:
        return Offset.zero;
    }
  }

  /// Повертає оптимальну криву анімації для цієї позиції.
  Curve get optimalCurve {
    switch (this) {
      case ToastPosition.top:
      case ToastPosition.topSafe:
        return Curves.easeOutCubic;
      case ToastPosition.bottom:
      case ToastPosition.bottomSafe:
        return Curves.easeOutCubic;
      case ToastPosition.center:
        return Curves.easeOutBack;
    }
  }

  /// Повертає оптимальну тривалість анімації.
  Duration get optimalAnimationDuration {
    switch (this) {
      case ToastPosition.top:
      case ToastPosition.topSafe:
      case ToastPosition.bottom:
      case ToastPosition.bottomSafe:
        return const Duration(milliseconds: 250);
      case ToastPosition.center:
        return const Duration(milliseconds: 300);
    }
  }

  /// Повертає опис позиції для accessibility.
  String get accessibilityDescription {
    switch (this) {
      case ToastPosition.top:
        return 'Зверху екрана';
      case ToastPosition.bottom:
        return 'Знизу екрана';
      case ToastPosition.center:
        return 'По центру екрана';
      case ToastPosition.topSafe:
        return 'Зверху екрана (безпечна зона)';
      case ToastPosition.bottomSafe:
        return 'Знизу екрана (безпечна зона)';
    }
  }
}

// ─── Haptic Feedback Type Extensions ──────────────────────────────────────────

/// Розширення для [HapticFeedbackType].
extension HapticFeedbackTypeExtension on HapticFeedbackType {
  /// Чи цей тип має вібрацію.
  bool get hasVibration => this != HapticFeedbackType.none;

  /// Чи це сильна вібрація.
  bool get isStrong => this == HapticFeedbackType.heavy;

  /// Інтенсивність вібрації (0-1).
  double get intensity {
    switch (this) {
      case HapticFeedbackType.none:
        return 0.0;
      case HapticFeedbackType.light:
        return 0.3;
      case HapticFeedbackType.medium:
        return 0.6;
      case HapticFeedbackType.heavy:
        return 1.0;
    }
  }

  /// Українська назва типу.
  String get ukrainianLabel {
    switch (this) {
      case HapticFeedbackType.light:
        return 'Легкий';
      case HapticFeedbackType.medium:
        return 'Середній';
      case HapticFeedbackType.heavy:
        return 'Сильний';
      case HapticFeedbackType.none:
        return 'Без вібрації';
    }
  }

  /// Викликає відповідний тактильний відгук.
  void trigger() {
    switch (this) {
      case HapticFeedbackType.light:
        HapticFeedback.lightImpact();
      case HapticFeedbackType.medium:
        HapticFeedback.mediumImpact();
      case HapticFeedbackType.heavy:
        HapticFeedback.heavyImpact();
      case HapticFeedbackType.none:
        break;
    }
  }
}

// ─── Toast Constants ──────────────────────────────────────────────────────────

/// Константи для toast-системи: розміри, тривалості, ліміти.
///
/// Містить усі числові значення, які використовуються для налаштування
/// сповіщень в додатку Nexora.
class ToastConstants {
  ToastConstants._();

  /// Максимальна довжина повідомлення.
  static const int maxMessageLength = 200;

  /// Максимальна довжина заголовка.
  static const int maxTitleLength = 100;

  /// Максимальна довжина підзаголовка.
  static const int maxSubtitleLength = 150;

  /// Максимальна довжина action label.
  static const int maxActionLabelLength = 20;

  /// Максимальна кількість одночасних постійних сповіщень.
  static const int maxPersistentToasts = 2;

  /// Максимальна кількість сповіщень у черзі.
  static const int maxQueueSize = 10;

  /// Стандартна ширина іконки.
  static const double iconSize = 18.0;

  /// Стандартний розмір контейнера іконки.
  static const double iconContainerSize = 32.0;

  /// Мінімальна висота progress bar.
  static const double progressMinHeight = 2.0;

  /// Розмір кнопки закриття.
  static const double closeButtonSize = 18.0;

  /// Мінімальна відстань свайпу для закриття.
  static const double swipeDismissThreshold = 50.0;

  /// Непрозорість тіні картки.
  static const double shadowOpacity = 0.2;

  /// Blur radius тіні картки.
  static const double shadowBlurRadius = 12.0;

  /// Зміщення тіні картки по Y.
  static const double shadowYOffset = 4.0;

  /// Ширина рамки картки.
  static const double borderWidth = 1.0;

  /// Непрозорість фону іконки.
  static const double iconBgOpacity = 0.12;

  /// Непрозорість фону кнопки дії.
  static const double actionBgOpacity = 0.15;

  /// Мінімальний інтервал між однаковими сповіщеннями (debounce).
  static const Duration debounceInterval = Duration(seconds: 2);

  /// Стандартний вертикальний відступ progress bar.
  static const double progressBottomPadding = 8.0;

  /// Горизонтальний відступ title row від низу.
  static const double titleBottomPadding = 4.0;

  /// Вертикальний відступ subtitle від основного тексту.
  static const double subtitleTopPadding = 2.0;

  /// Горизонтальний відступ між кнопкою дії та текстом.
  static const double actionLeftSpacing = 12.0;

  /// Горизонтальний відступ кнопки закриття.
  static const double closeLeftSpacing = 12.0;

  /// Вертикальний падінг кнопки дії.
  static const double actionVerticalPadding = 6.0;

  /// Горизонтальний падінг кнопки дії.
  static const double actionHorizontalPadding = 12.0;
}

// ─── Toast Priority System ────────────────────────────────────────────────────

/// Система пріоритетів для сповіщень.
///
/// Визначає порядок показу при конфлікті черги.
class ToastPrioritySystem {
  ToastPrioritySystem._();

  /// Порівнює два типи сповіщень за пріоритетом.
  ///
  /// Повертає від'ємне, якщо [a] має вищий пріоритет.
  static int compare(ToastType a, ToastType b) {
    return a.priority.compareTo(b.priority);
  }

  /// Повертає тип з найвищим пріоритетом серед списку.
  static ToastType highestPriority(List<ToastType> types) {
    if (types.isEmpty) return ToastType.info;
    return types.reduce((a, b) => a.priority < b.priority ? a : b);
  }

  /// Повертає тип з найнижчим пріоритетом серед списку.
  static ToastType lowestPriority(List<ToastType> types) {
    if (types.isEmpty) return ToastType.info;
    return types.reduce((a, b) => a.priority > b.priority ? a : b);
  }

  /// Сортує список конфігурацій за пріоритетом типу.
  static List<ToastConfig> sortByPriority(List<ToastConfig> configs) {
    final sorted = List<ToastConfig>.from(configs);
    sorted.sort((a, b) => a.type.priority.compareTo(b.type.priority));
    return sorted;
  }

  /// Чи тип [candidate] має вищий пріоритет ніж [current].
  static bool hasHigherPriority(ToastType candidate, ToastType current) {
    return candidate.priority < current.priority;
  }

  /// Чи сповіщення може бути замінене іншим (lower priority).
  static bool canBeReplaced(ToastConfig current, ToastConfig candidate) {
    if (current.isPersistent) return false;
    return hasHigherPriority(candidate.type, current.type);
  }
}

// ─── Toast Content Builder ────────────────────────────────────────────────────

/// Будівники вмісту для сповіщень.
///
/// Надає готові шаблони повідомлень для типових сценаріїв.
class ToastContentBuilder {
  ToastContentBuilder._();

  /// Створює повідомлення про успішне збереження.
  static String savedSuccessfully(String itemName) {
    return '$itemName успішно збережено';
  }

  /// Створює повідомлення про успішне видалення.
  static String deletedSuccessfully(String itemName) {
    return '$itemName видалено';
  }

  /// Створює повідомлення про помилку з'єднання.
  static String connectionError() {
    return 'Помилка з\'єднання. Перевірте інтернет.';
  }

  /// Створює повідомлення про успішну синхронізацію.
  static String syncComplete({int? count}) {
    if (count != null) return 'Синхронізовано $count елементів';
    return 'Синхронізація завершена';
  }

  /// Створює повідомлення про отримання XP.
  static String xpGained(int amount) {
    return '+$amount XP';
  }

  /// Створює повідомлення про отримання монет.
  static String coinsGained(int amount) {
    return '+$amount монет';
  }

  /// Створює повідомлення про продовження серії.
  static String streakContinued(int days) {
    return 'Серія: $days днів!';
  }

  /// Створює повідомлення про досягнення.
  static String achievementUnlocked(String name) {
    return 'Досягнення: $name';
  }

  /// Створює повідомлення про помилку валідації.
  static String validationError(String field) {
    return 'Некоректне поле: $field';
  }

  /// Створює повідомлення про порожній стан.
  static String emptyState(String itemName) {
    return 'Немає $itemName';
  }

  /// Створює повідомлення про успішне оновлення.
  static String updatedSuccessfully(String itemName) {
    return '$itemName оновлено';
  }

  /// Створює повідомлення про завантаження.
  static String loadingMessage(String itemName) {
    return 'Завантаження $itemName...';
  }

  /// Створює повідомлення про бекап.
  static String backupComplete({DateTime? date}) {
    if (date != null) {
      return 'Бекап створено: ${date.day}.${date.month}.${date.year}';
    }
    return 'Резервну копію створено';
  }

  /// Створює повідомлення про вихід.
  static String logoutMessage() {
    return 'Ви вийшли з системи';
  }

  /// Створює повідомлення про непрочитані сповіщення.
  static String unreadNotifications(int count) {
    if (count == 1) return '1 нове сповіщення';
    if (count >= 2 && count <= 4) return '$count нових сповіщення';
    return '$count нових сповіщень';
  }
}

// ─── Toast Debug Helper ───────────────────────────────────────────────────────

/// Допоміжні методи для debug-логування сповіщень.
class ToastDebugHelper {
  ToastDebugHelper._();

  /// Генерує debug-рядок для конфігурації сповіщення.
  static String buildConfigString(ToastConfig config) {
    final buffer = StringBuffer('ToastConfig(');
    buffer.writeln();
    buffer.writeln('  type: ${config.type.label} (${config.type.name})');
    buffer.writeln('  message: "${config.message}"');
    if (config.title != null) buffer.writeln('  title: "${config.title}"');
    if (config.subtitle != null) buffer.writeln('  subtitle: "${config.subtitle}"');
    buffer.writeln('  position: ${config.position.name}');
    buffer.writeln('  persistent: ${config.isPersistent}');
    buffer.writeln('  dismissible: ${config.dismissible}');
    buffer.writeln('  haptic: ${config.enableHaptic}');
    buffer.writeln('  progress: ${config.showProgress}');
    if (config.hasAction) buffer.writeln('  action: "${config.actionLabel}"');
    if (config.duration != null) {
      buffer.writeln('  duration: ${config.duration!.inMilliseconds}ms');
    }
    buffer.write(')');
    return buffer.toString();
  }

  /// Генерує debug-рядок для стану черги.
  static String buildQueueStateString({
    required int queueSize,
    required int persistentSize,
    required bool isShowing,
  }) {
    return 'ToastQueue('
        'queue: $queueSize, '
        'persistent: $persistentSize, '
        'showing: $isShowing)';
  }

  /// Перетворює колір у hex-рядок.
  static String colorToHex(Color color) {
    return '#${color.value.toRadixString(16).padLeft(8, '0').toUpperCase()}';
  }

  /// Генерує короткий опис для debug-логування.
  static String shortDescription(ToastConfig config) {
    return '[${config.type.label}] "${config.message}" (${config.position.name})';
  }
}
