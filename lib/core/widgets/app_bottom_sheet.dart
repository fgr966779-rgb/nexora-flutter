import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_typography.dart';
import '../constants/app_spacing.dart';
import '../constants/app_radii.dart';
import '../constants/app_durations.dart';

// ═══════════════════════════════════════════════════════════════════════════
// Debug Configuration (Налаштування налагодження)
// ═══════════════════════════════════════════════════════════════════════════

/// Налаштування налагодження для [AppBottomSheet].
class BottomSheetDebugConfig {
  BottomSheetDebugConfig._();

  /// Увімкнути вивід debug-повідомлень.
  static bool enableLogging = false;

  /// Показувати рамки навколо секцій.
  static bool showSectionBounds = false;

  static void log(String message, {String? tag}) {
    if (!enableLogging) return;
    final prefix = tag != null ? '[BottomSheet:$tag] ' : '[BottomSheet] ';
    debugPrint('$prefix$message');
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Розміри нижнього листа (Sheet Size)
// ═══════════════════════════════════════════════════════════════════════════

/// Розміри нижнього листа як частка висоти екрана.
///
/// Кожен розмір також визначає набір snap points.
enum SheetSize {
  /// Малий — 25% висоти екрана.
  ///
  /// Для компактних діалогів, підтверджень, повідомлень.
  small(0.25),

  /// Середній — 50% висоти екрана.
  ///
  /// Для форм, деталей, фільтрів, налаштувань.
  medium(0.5),

  /// Великий — 75% висоти екрана.
  ///
  /// Для повних екранів деталей, редакторів, аналітики.
  large(0.75),

  /// Повний — 95% висоти екрана.
  ///
  /// Для максимально великих форм та повноекранних модалок.
  full(0.95);

  const SheetSize(this.value);

  /// Частка висоти екрана (0.0 – 1.0).
  final double value;

  /// Коротка назва розміру для відображення.
  String get displayName {
    switch (this) {
      case SheetSize.small:
        return 'Малий';
      case SheetSize.medium:
        return 'Середній';
      case SheetSize.large:
        return 'Великий';
      case SheetSize.full:
        return 'Повний';
    }
  }

  /// Опис розміру для accessibility.
  String get description {
    switch (this) {
      case SheetSize.small:
        return 'Малий нижній лист (25% екрана)';
      case SheetSize.medium:
        return 'Середній нижній лист (50% екрана)';
      case SheetSize.large:
        return 'Великий нижній лист (75% екрана)';
      case SheetSize.full:
        return 'Повний нижній лист (95% екрана)';
    }
  }

  /// Висота в пікселях для стандартного екрану (812px).
  double heightForScreen(double screenHeight) => value * screenHeight;
}

// ═══════════════════════════════════════════════════════════════════════════
// Основний віджет (Widget)
// ═══════════════════════════════════════════════════════════════════════════

/// Нижній лист з drag handle, заголовком, футером та snap points.
///
/// Підтримує:
/// - 4 розміри [SheetSize] (small, medium, large, full)
/// - Drag handle для перетягування
/// - Snap points для фіксації на певних висотах
/// - Кастомний заголовок з кнопкою закриття
/// - Кастомний футер з кнопками дій
/// - Backdrop blur для затемнення фону
/// - Safe area padding знизу
/// - Dismissible / isDraggable управління
/// - Кастомні криві анімації
/// - Callback onDismiss при закритті
///
/// Приклад використання:
/// ```dart
/// // Через статичний метод:
/// AppBottomSheet.show(
///   context: context,
///   title: 'Нова ціль',
///   child: GoalFormContent(),
///   footer: SheetFooterSingle(
///     label: 'Створити',
///     onTap: () => _createGoal(),
///   ),
/// );
///
/// // Через конструктор:
/// AppBottomSheet(
///   child: content,
///   sheetSize: SheetSize.large,
///   title: 'Деталі',
/// )
/// ```
class AppBottomSheet extends StatelessWidget {
  const AppBottomSheet({
    super.key,
    required this.child,
    this.sheetSize = SheetSize.medium,
    this.isLightTheme = false,
    this.title,
    this.showDragHandle = true,
    this.showCloseButton = true,
    this.header,
    this.footer,
    this.enableBackdropBlur = true,
    this.enableSafeArea = true,
    this.isDismissible = true,
    this.isDraggable = true,
    this.animationCurve = Curves.easeOutCubic,
    this.onDismiss,
    this.showBorder = true,
    this.handleColor,
    this.handleWidth = 40.0,
    this.handleHeight = 4.0,
    this.enableDragHandleAnimation = true,
    this.closeButtonTooltip = 'Закрити',
    this.dragHandleTooltip = 'Перетягніть для зміни розміру',
    this.backgroundColor,
    this.isScrollControlled = true,
  });

  /// Основний контент листа.
  final Widget child;

  /// Розмір листа.
  final SheetSize sheetSize;

  /// Світла тема (Monitor замість PS5).
  final bool isLightTheme;

  /// Заголовок листа (текстова мітка).
  final String? title;

  /// Показувати drag handle зверху (рукоятка перетягування).
  final bool showDragHandle;

  /// Показувати кнопку закриття (✕) в заголовку.
  final bool showCloseButton;

  /// Кастомний заголовок (повністю замінює title).
  final Widget? header;

  /// Кастомний футер з кнопками (повністю замінює footer).
  final Widget? footer;

  /// Backdrop blur для затемнення фону за листом.
  final bool enableBackdropBlur;

  /// Safe area padding знизу (для iPhone Home Indicator).
  final bool enableSafeArea;

  /// Чи можна закрити натисканням на фон за листом.
  final bool isDismissible;

  /// Чи можна перетягувати лист вгору/вниз.
  final bool isDraggable;

  /// Крива анімації появи/зникнення.
  final Curve animationCurve;

  /// Callback при закритті листа (навіть якщо backdrop натиснуто).
  final VoidCallback? onDismiss;

  /// Показувати верхню межу листа.
  final bool showBorder;

  /// Кастомний колір рукоятки (null = стандартний).
  final Color? handleColor;

  /// Ширина рукоятки в пікселях.
  final double handleWidth;

  /// Висота рукоятки в пікселях.
  final double handleHeight;

  /// Увімкнути анімацію появи рукоятки.
  final bool enableDragHandleAnimation;

  /// Підказка для кнопки закриття.
  final String closeButtonTooltip;

  /// Підказка для рукоятки перетягування.
  final String dragHandleTooltip;

  /// Кастомний колір фону листа.
  final Color? backgroundColor;

  /// Чи контент керується прокруткою.
  final bool isScrollControlled;

  // ═══════════════════════════════════════════════════════════════════════
  // Snap Points
  // ═════════════════════════════════════════════════════════════════════

  /// Snap points для DraggableScrollableSheet.
  ///
  /// Кожен розмір має свій набір точок фіксації.
  List<double> get _snapPoints {
    switch (sheetSize) {
      case SheetSize.small:
        return [0.15, 0.25, 0.5];
      case SheetSize.medium:
        return [0.25, 0.5, 0.75];
      case SheetSize.large:
        return [0.5, 0.75, 0.95];
      case SheetSize.full:
        return [0.75, 0.95];
    }
  }

  // ═══════════════════════════════════════════════════════════════════════
  // Статичний API (Static API)
  // ═════════════════════════════════════════════════════════════════════

  /// Показує нижній лист через showModalBottomSheet.
  ///
  /// Повертає Future з результатом (тип T), якщо передано.
  ///
  /// Приклад:
  /// ```dart
  /// final result = await AppBottomSheet.show<String>(
  ///   context: context,
  ///   title: 'Виберіть суму',
  ///   child: AmountInput(),
  ///   footer: SheetFooterSingle(
  ///     label: 'Підтвердити',
  ///     onTap: () => Navigator.pop(context, '500'),
  ///   ),
  /// );
  /// ```
  static Future<T?> show<T>({
    required BuildContext context,
    required Widget child,
    SheetSize sheetSize = SheetSize.medium,
    bool isLightTheme = false,
    String? title,
    bool showDragHandle = true,
    bool showCloseButton = true,
    Widget? header,
    Widget? footer,
    bool enableBackdropBlur = true,
    bool enableSafeArea = true,
    bool isDismissible = true,
    bool isDraggable = true,
    Curve animationCurve = Curves.easeOutCubic,
    VoidCallback? onDismiss,
    bool isScrollControlled = true,
  }) {
    BottomSheetDebugConfig.log('show() called', tag: 'api');

    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: isScrollControlled,
      isDismissible: isDismissible,
      backgroundColor: Colors.transparent,
      enableDrag: isDraggable,
      transitionAnimationController: null,
      builder: (context) => AppBottomSheet(
        child: child,
        sheetSize: sheetSize,
        isLightTheme: isLightTheme,
        title: title,
        showDragHandle: showDragHandle,
        showCloseButton: showCloseButton,
        header: header,
        footer: footer,
        enableBackdropBlur: enableBackdropBlur,
        enableSafeArea: enableSafeArea,
        isDismissible: isDismissible,
        isDraggable: isDraggable,
        animationCurve: animationCurve,
        onDismiss: onDismiss,
        isScrollControlled: isScrollControlled,
      ),
    ).then((result) {
      onDismiss?.call();
      return result;
    });
  }

  /// Показує простий інформаційний лист з повідомленням.
  ///
  /// Зручно для confirm-діалогів та інформування.
  static Future<void> info({
    required BuildContext context,
    required String title,
    required String message,
    String? closeLabel,
    bool isLightTheme = false,
  }) {
    return show(
      context: context,
      title: title,
      isLightTheme: isLightTheme,
      sheetSize: SheetSize.small,
      showDragHandle: false,
      child: Padding(
        padding: const EdgeInsets.all(Spacing.base),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.info_outline_rounded,
              size: 40,
              color: isLightTheme ? AppColorsMonitor.accent : AppColorsPS5.accent,
            ),
            const SizedBox(height: Spacing.md),
            Text(message),
          ],
        ),
      ),
    );
  }

  /// Показує лист з підтвердженням деструктивної дії.
  static Future<bool> confirm({
    required BuildContext context,
    required String title,
    required String message,
    String? confirmLabel,
    String? cancelLabel,
    bool isLightTheme = false,
  }) async {
    bool result = false;
    await show(
      context: context,
      title: title,
      isLightTheme: isLightTheme,
      sheetSize: SheetSize.small,
      showDragHandle: false,
      footer: SheetFooterDual(
        primaryLabel: confirmLabel ?? 'Підтвердити',
        primaryOnTap: () {
          result = true;
          Navigator.of(context).pop();
        },
        secondaryLabel: cancelLabel ?? 'Скасувати',
        secondaryOnTap: () => Navigator.of(context).pop(),
        isLightTheme: isLightTheme,
      ),
      child: Padding(
        padding: const EdgeInsets.all(Spacing.base),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.warning_amber_rounded,
              size: 40,
              color: AppColorsPS5.warning,
            ),
            const SizedBox(height: Spacing.md),
            Text(message),
          ],
        ),
      ),
    );
    return result;
  }

  // ═══════════════════════════════════════════════════════════════════════
  // Гетери кольорів (Color Getters)
  // ═════════════════════════════════════════════════════════════════════

  /// Колір фону листа.
  Color get _cardColor => widget.backgroundColor ??
      (isLightTheme ? AppColorsMonitor.card : AppColorsPS5.card);

  /// Колір рукоятки перетягування.
  Color get _handleColor =>
      widget.handleColor ??
      (isLightTheme ? AppColorsMonitor.textHint : AppColorsPS5.textHint);

  /// Колір тексту заголовка.
  Color get _titleColor => isLightTheme
      ? AppColorsMonitor.textPrimary
      : AppColorsPS5.textPrimary;

  /// Колір кнопки закриття.
  Color get _closeColor => isLightTheme
      ? AppColorsMonitor.textSecondary
      : AppColorsPS5.textSecondary;

  /// Колір верхньої межі.
  Color get _borderColor => isLightTheme
      ? AppColorsMonitor.border
      : AppColorsPS5.border;

  /// Колір розділювача.
  Color get _dividerColor => isLightTheme
      ? AppColorsMonitor.border
      : AppColorsPS5.border;

  // ═════════════════════════════════════════════════════════════════════
  // Побудова (Build)
  // ═════════════════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    BottomSheetDebugConfig.log('build()', tag: 'lifecycle');

    return Container(
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(Radii.xl),
        ),
        border: widget.showBorder
            ? Border(
                top: BorderSide(
                  color: _borderColor,
                  width: 0.5,
                ),
              )
            : null,
      ),
      child: DraggableScrollableSheet(
        initialChildSize: sheetSize.value,
        minChildSize: 0.1,
        maxChildSize: 0.98,
        snap: true,
        snapSizes: _snapPoints,
        expand: false,
        builder: (context, scrollController) {
          return Column(
            children: [
              // ── Рукоятка перетягування ──
              if (widget.showDragHandle)
                _buildDragHandle(),
              // ── Заголовок ──
              _buildHeader(context),
              // ── Контент ──
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(
                    horizontal: Spacing.base,
                  ),
                  child: widget.child,
                ),
              ),
              // ── Розділювач перед футером ──
              if (widget.footer != null)
                Divider(
                  color: _dividerColor,
                  height: 1,
                  thickness: 0.5,
                ),
              // ── Футер ──
              if (widget.footer != null) _buildFooter(),
              // ── Safe area padding знизу ──
              if (widget.enableSafeArea)
                SizedBox(
                    height: MediaQuery.of(context).padding.bottom),
            ],
          );
        },
      ),
    );
  }

  // ═════════════════════════════════════════════════════════════════════
  // Рукоятка (Drag Handle)
  // ═════════════════════════════════════════════════════════════════════

  /// Будує рукоятку перетягування з анімацією появи.
  Widget _buildDragHandle() {
    final handle = Container(
      width: widget.handleWidth,
      height: widget.handleHeight,
      decoration: BoxDecoration(
        color: _handleColor.withOpacity(0.5),
        borderRadius: BorderRadius.circular(
          widget.handleHeight / 2,
        ),
      ),
    );

    return Padding(
      padding: const EdgeInsets.only(
        top: Spacing.sm,
        bottom: Spacing.xs,
      ),
      child: Center(
        child: widget.enableDragHandleAnimation
            ? handle.animate().fadeIn(
              duration: AppDurations.medium,
              curve: Curves.easeOutCubic,
            ).slideY(begin: -0.2, end: 0.0,
              duration: AppDurations.medium,
              curve: Curves.easeOutCubic,
            )
            : handle,
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // Заголовок (Header)
  // ═════════════════════════════════════════════════════════════════════

  /// Будує заголовок листа (текстовий або кастомний).
  Widget _buildHeader(BuildContext context) {
    // ── Кастомний заголовок ──
    if (widget.header != null) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(
          Spacing.base,
          Spacing.xs,
          Spacing.sm,
          Spacing.md,
        ),
        child: widget.header!,
      );
    }

    // ── Текстовий заголовок з кнопкою закриття ──
    if (widget.title != null) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(
          Spacing.base,
          Spacing.xs,
          Spacing.base,
          Spacing.md,
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                widget.title!,
                style: AppTypography.heading2.copyWith(
                  color: _titleColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            if (widget.showCloseButton)
              _buildCloseButton(context),
          ],
        ),
      );
    }

    return const SizedBox.shrink();
  }

  /// Будує кнопку закриття.
  Widget _buildCloseButton(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).pop(),
      child: Tooltip(
        message: widget.closeButtonTooltip,
        child: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: _borderColor.withOpacity(0.5),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.close_rounded,
            color: _closeColor,
            size: 18,
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // Футер (Footer)
  // ═══════════════════════════════════════════════════════════════════════

  /// Будує футер листа (якщо передано).
  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.base,
        vertical: Spacing.md,
      ),
      child: widget.footer!,
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Пресети футерів (Footer Presets)
// ═══════════════════════════════════════════════════════════════════════════

/// Готовий футер з однією кнопкою.
///
/// Використовується для простих діалогів з однією дією.
///
/// Приклад:
/// ```dart
/// SheetFooterSingle(
///   label: 'Зберегти',
///   onTap: () => _save(),
///   isEnabled: _isValid,
/// )
/// ```
class SheetFooterSingle extends StatelessWidget {
  const SheetFooterSingle({
    super.key,
    required this.label,
    required this.onTap,
    this.isEnabled = true,
    this.isLightTheme = false,
    this.isLoading = false,
    this.isSuccess = false,
    this.height,
  });

  /// Текст кнопки.
  final String label;

  /// Зворотний виклик при натисканні.
  final VoidCallback onTap;

  /// Чи кнопка активна.
  final bool isEnabled;

  /// Світла тема.
  final bool isLightTheme;

  /// Чи кнопка в стані завантаження.
  final bool isLoading;

  /// Стан успіху кнопки (тимчасово зелена).
  final bool isSuccess;

  /// Висота футера.
  final double? height;

  @override
  Widget build(BuildContext context) {
    final accentColor = isLightTheme
        ? AppColorsMonitor.accent
        : AppColorsPS5.accent;

    final successColor = AppColorsPS5.success;

    final effectiveColor = isSuccess ? successColor : accentColor;

    return SizedBox(
      width: double.infinity,
      height: height,
      child: GestureDetector(
        onTap: isEnabled && !isLoading ? onTap : null,
        child: AnimatedContainer(
          duration: AppDurations.fast,
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: isEnabled
                ? effectiveColor
                : effectiveColor.withOpacity(0.4),
            borderRadius: BorderRadius.circular(Radii.button),
          ),
          alignment: Alignment.center,
          child: isLoading
              ? SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Colors.white.withOpacity(0.7),
                    ),
                  ),
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (isSuccess) ...[
                      Icon(
                        Icons.check_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                      const SizedBox(width: Spacing.xs),
                    ],
                    Flexible(
                      child: Text(
                        label,
                        style: AppTypography.buttonMedium.copyWith(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

/// Готовий футер з двома кнопками.
///
/// Основна та другорядна кнопки розміщені горизонтально.
///
/// Приклад:
/// ```dart
/// SheetFooterDual(
///   primaryLabel: 'Видалити',
///   primaryOnTap: () => _delete(),
///   secondaryLabel: 'Скасувати',
///   secondaryOnTap: () => Navigator.pop(context),
/// )
/// ```
class SheetFooterDual extends StatelessWidget {
  const SheetFooterDual({
    super.key,
    required this.primaryLabel,
    required this.primaryOnTap,
    this.secondaryLabel,
    this.secondaryOnTap,
    this.isLightTheme = false,
    this.isLoading = false,
    this.isPrimaryDestructive = false,
  });

  /// Текст основної кнопки.
  final String primaryLabel;

  /// Зворотний виклик основної кнопки.
  final VoidCallback primaryOnTap;

  /// Текст другорядної кнопки.
  final String? secondaryLabel;

  /// Зворотний виклик другорядної кнопки.
  final VoidCallback? secondaryOnTap;

  /// Світла тема.
  final bool isLightTheme;

  /// Чи кнопки в стані завантаження.
  final bool isLoading;

  /// Чи основна кнопка має деструктивний стиль.
  final bool isPrimaryDestructive;

  @override
  Widget build(BuildContext context) {
    final accentColor = isLightTheme
        ? AppColorsMonitor.accent
        : AppColorsPS5.accent;

    final errorColor = AppColorsPS5.error;

    final borderColor = isLightTheme
        ? AppColorsMonitor.border
        : AppColorsPS5.border;

    final textColor = isLightTheme
        ? AppColorsMonitor.textPrimary
        : AppColorsPS5.textPrimary;

    final effectivePrimaryColor =
        isPrimaryDestructive ? errorColor : accentColor;

    return Row(
      children: [
        // ── Вторинна кнопка ──
        if (secondaryLabel != null)
          Expanded(
            child: GestureDetector(
              onTap: isLoading ? null : secondaryOnTap,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(Radii.button),
                  border: Border.all(color: borderColor),
                ),
                alignment: Alignment.center,
                child: isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(
                        secondaryLabel!,
                        style: AppTypography.buttonMedium.copyWith(
                          color: textColor,
                        ),
                      ),
              ),
            ),
          ),
        if (secondaryLabel != null) const SizedBox(width: 12),
        // ── Основна кнопка ──
        Expanded(
          child: GestureDetector(
            onTap: isLoading ? null : primaryOnTap,
            child: AnimatedContainer(
              duration: AppDurations.fast,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: effectivePrimaryColor,
                borderRadius: BorderRadius.circular(Radii.button),
              ),
              alignment: Alignment.center,
              child: isLoading
                  ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                  : Text(
                      primaryLabel,
                      style: AppTypography.buttonMedium.copyWith(
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Готовий футер з трьома кнопками.
///
/// Використовується для складних діалогів з трьома варіантами дій.
class SheetFooterTriple extends StatelessWidget {
  const SheetFooterTriple({
    super.key,
    required this.primaryLabel,
    required this.primaryOnTap,
    required this.secondaryLabel,
    required this.secondaryOnTap,
    this.tertiaryLabel,
    this.tertiaryOnTap,
    this.isLightTheme = false,
    this.isLoading = false,
  });

  /// Текст основної кнопки.
  final String primaryLabel;

  /// Зворотний виклик основної кнопки.
  final VoidCallback primaryOnTap;

  /// Текст другорядної кнопки.
  final String secondaryLabel;

  /// Зворотний виклик другорядної кнопки.
  final VoidCallback secondaryOnTap;

  /// Текст третинної кнопки.
  final String? tertiaryLabel;

  /// Зворотний виклик третинної кнопки.
  final VoidCallback? tertiaryOnTap;

  /// Світла тема.
  final bool isLightTheme;

  /// Чи кнопки в стані завантаження.
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final accentColor = isLightTheme
        ? AppColorsMonitor.accent
        : AppColorsPS5.accent;

    final borderColor = isLightTheme
        ? AppColorsMonitor.border
        : AppColorsPS5.border;

    final textColor = isLightTheme
        ? AppColorsMonitor.textPrimary
        : AppColorsPS5.textPrimary;

    return Row(
      children: [
        // ── Третинна кнопка (якщо є) ──
        if (tertiaryLabel != null && tertiaryOnTap != null) ...[
          Expanded(
            child: GestureDetector(
              onTap: isLoading ? null : tertiaryOnTap,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(Radii.button),
                  border: Border.all(color: borderColor),
                ),
                alignment: Alignment.center,
                child: Text(
                  tertiaryLabel!,
                  style: AppTypography.buttonSmall.copyWith(
                    color: textColor,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
        // ── Вторинна кнопка ──
        Expanded(
          child: GestureDetector(
            onTap: isLoading ? null : secondaryOnTap,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(Radii.button),
                border: Border.all(color: borderColor),
              ),
              alignment: Alignment.center,
              child: isLoading
                  ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                  : Text(
                      secondaryLabel,
                      style: AppTypography.buttonMedium.copyWith(
                        color: textColor,
                      ),
                    ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        // ── Основна кнопка ──
        Expanded(
          child: GestureDetector(
            onTap: isLoading ? null : primaryOnTap,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: accentColor,
                borderRadius: BorderRadius.circular(Radii.button),
              ),
              alignment: Alignment.center,
              child: isLoading
                  ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                  : Text(
                      primaryLabel,
                      style: AppTypography.buttonMedium.copyWith(
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Допоміжні методи (Helper Methods)
// ═══════════════════════════════════════════════════════════════════════════

/// Допоміжні методи для роботи з нижніми листами.
class AppBottomSheetHelpers {
  AppBottomSheetHelpers._();

  /// Повертає опис розміру листа для accessibility.
  static String sizeDescription(SheetSize size) {
    return size.description;
  }

  /// Повертає текст для кнопки закриття.
  static String get closeTooltip => 'Закрити';

  /// Повертає текст для drag handle.
  static String get dragHandleTooltip => 'Перетягніть для зміни розміру';

  /// Обчислює оптимальний розмір залежно від контенту.
  ///
  /// [contentHeight] — висота контенту всередині листа.
  /// [screenHeight] — висота екрана.
  static SheetSize recommendedSize(double contentHeight, double screenHeight) {
    final ratio = contentHeight / screenHeight;
    if (ratio < 0.25) return SheetSize.small;
    if (ratio < 0.5) return SheetSize.medium;
    if (ratio < 0.75) return SheetSize.large;
    return SheetSize.full;
  }

  /// Обчислює максимальну ширину контенту листа.
  ///
  /// [screenWidth] — ширина екрана.
  static double maxContentWidth(double screenWidth) {
    return (screenWidth * 0.95).clamp(300.0, 600.0);
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Utility Extensions (Утиліти-розширення)
// ═══════════════════════════════════════════════════════════════════════════

/// Розширення для [SheetSize] з додатковими методами.
extension SheetSizeExtension on SheetSize {
  /// Наступний розмір.
  SheetSize get next {
    if (index >= SheetSize.values.length - 1) return this;
    return SheetSize.values[index + 1];
  }

  /// Попередній розмір.
  SheetSize get previous {
    if (index <= 0) return this;
    return SheetSize.values[index - 1];
  }

  /// Чи це максимальний розмір.
  bool get isMaxSize => this == SheetSize.full;

  /// Чи це мінімальний розмір.
  bool get isMinSize => this == SheetSize.small;

  /// Перетворює розмір у відсотки висоти екрана (рядок).
  ///
  /// Наприклад: `SheetSize.medium.toPercentage()` → `"50%"`.
  String toPercentage() {
    return '${(value * 100).toInt()}%';
  }

  /// Обчислює висоту в пікселях для конкретного екрану.
  ///
  /// [screenHeight] — висота екрана в пікселях.
  double toPixels(double screenHeight) {
    return value * screenHeight;
  }

  /// Чи розмір підходить для compact-вмісту (менше 40% екрана).
  bool get isCompact => value < 0.4;

  /// Чи розмір підходить для повного контенту (понад 60% екрана).
  bool get isLargeContent => value >= 0.6;
}

// ═══════════════════════════════════════════════════════════════════════════
// Bottom Sheet Constants (Константи)
// ═══════════════════════════════════════════════════════════════════════════

/// Константи для налаштування нижніх листів.
///
/// Містить стандартні значення для розмірів, анімацій, отступів
/// та інших параметрів, що використовуються у [AppBottomSheet].
class AppBottomSheetConstants {
  AppBottomSheetConstants._();

  /// Стандартна ширина рукоятки перетягування.
  static const double defaultHandleWidth = 40.0;

  /// Стандартна висота рукоятки перетягування.
  static const double defaultHandleHeight = 4.0;

  /// Мінімальна висота рукоятки.
  static const double minHandleHeight = 2.0;

  /// Максимальна висота рукоятки.
  static const double maxHandleHeight = 8.0;

  /// Мінімальна ширина рукоятки.
  static const double minHandleWidth = 24.0;

  /// Максимальна ширина рукоятки.
  static const double maxHandleWidth = 80.0;

  /// Стандартний радіус заокруглення верхніх кутів листа.
  static const double defaultTopRadius = 16.0;

  /// Стандартна висота кнопки закриття.
  static const double closeButtonSize = 32.0;

  /// Стандартний розмір іконки закриття.
  static const double closeIconSize = 18.0;

  /// Стандартний вертикальний відступ футера.
  static const double footerVerticalPadding = 16.0;

  /// Стандартний горизонтальний відступ футера.
  static const double footerHorizontalPadding = 16.0;

  /// Стандартний вертикальний відступ заголовка (зверху).
  static const double headerTopPadding = 8.0;

  /// Стандартний вертикальний відступ заголовка (знизу).
  static const double headerBottomPadding = 16.0;

  /// Стандартний горизонтальний відступ заголовка.
  static const double headerHorizontalPadding = 16.0;

  /// Товщина розділювача перед футером.
  static const double dividerThickness = 0.5;

  /// Мінімальний розмір дитинячого елемента (10% екрана).
  static const double minChildSize = 0.1;

  /// Максимальний розмір дитинячого елемента (98% екрана).
  static const double maxChildSize = 0.98;

  /// Стандартна тривалість анімації появи рукоятки.
  static const Duration handleAnimationDuration = AppDurations.medium;

  /// Стандартна крива анімації появи рукоятки.
  static const Curve handleAnimationCurve = Curves.easeOutCubic;

  /// Непрозорість кольору рукоятки.
  static const double handleOpacity = 0.5;

  /// Непрозорість кольору фону кнопки закриття.
  static const double closeButtonBackgroundOpacity = 0.5;

  /// Непрозорість тіні за листом.
  static const double backdropOpacity = 0.5;

  /// Тривалість анімації появи листа (milliseconds).
  static const int sheetAnimationDurationMs = 300;

  /// Тривалість анімації зникнення листа (milliseconds).
  static const int sheetDismissAnimationDurationMs = 250;

  /// Максимальна ширина контенту на планшетах.
  static const double maxContentWidth = 600.0;

  /// Мінімальна ширина контенту.
  static const double minContentWidth = 300.0;

  /// Стандартний відступ між двома кнопками футера.
  static const double footerButtonSpacing = 12.0;

  /// Стандартна висота кнопки футера (вертикальний падінг + текст).
  static const double footerButtonHeight = 48.0;

  /// Розмір індикатора завантаження в кнопках футера.
  static const double loadingIndicatorSize = 20.0;

  /// Товщина індикатора завантаження.
  static const double loadingIndicatorStrokeWidth = 2.0;

  /// Відступ рукоятки перетягування зверху.
  static const double handleTopPadding = 12.0;

  /// Відступ рукоятки перетягування знизу.
  static const double handleBottomPadding = 4.0;

  /// Максимальна кількість кнопок в футері.
  static const int maxFooterButtons = 3;

  /// Стандартний зсув анімації рукоятки по осі Y.
  static const double handleSlideYBegin = -0.2;

  /// Кінцевий зсув анімації рукоятки по осі Y.
  static const double handleSlideYEnd = 0.0;
}

// ═══════════════════════════════════════════════════════════════════════════
// Theme-Aware Sheet Builders (Темо-залежні білдери)
// ═══════════════════════════════════════════════════════════════════════════

/// Набір методів для створення темо-залежних компонентів листа.
///
/// Використовується для забезпечення consistency між різними
/// нижніми листами в додатку.
class AppBottomSheetThemeBuilders {
  AppBottomSheetThemeBuilders._();

  /// Створює колір фону листа залежно від теми.
  ///
  /// [isLightTheme] — чи використовувати світлу тему.
  /// [overrideColor] — кастомний колір фону (перевизначає тему).
  static Color sheetBackgroundColor({
    bool isLightTheme = false,
    Color? overrideColor,
  }) {
    return overrideColor ??
        (isLightTheme ? AppColorsMonitor.card : AppColorsPS5.card);
  }

  /// Створює колір тексту заголовка залежно від теми.
  ///
  /// [isLightTheme] — чи використовувати світлу тему.
  static Color titleTextColor({bool isLightTheme = false}) {
    return isLightTheme
        ? AppColorsMonitor.textPrimary
        : AppColorsPS5.textPrimary;
  }

  /// Створює колір кнопки закриття залежно від теми.
  ///
  /// [isLightTheme] — чи використовувати світлу тему.
  static Color closeButtonColor({bool isLightTheme = false}) {
    return isLightTheme
        ? AppColorsMonitor.textSecondary
        : AppColorsPS5.textSecondary;
  }

  /// Створює колір акценту залежно від теми.
  ///
  /// [isLightTheme] — чи використовувати світлу тему.
  static Color accentColor({bool isLightTheme = false}) {
    return isLightTheme ? AppColorsMonitor.accent : AppColorsPS5.accent;
  }

  /// Створює колір межі залежно від теми.
  ///
  /// [isLightTheme] — чи використовувати світлу тему.
  static Color borderColor({bool isLightTheme = false}) {
    return isLightTheme ? AppColorsMonitor.border : AppColorsPS5.border;
  }

  /// Створює колір тексту кнопки залежно від теми.
  ///
  /// [isLightTheme] — чи використовувати світлу тему.
  static Color buttonTextColor({bool isLightTheme = false}) {
    return isLightTheme
        ? AppColorsMonitor.textPrimary
        : AppColorsPS5.textPrimary;
  }

  /// Створює стиль заголовка листа залежно від теми.
  ///
  /// [isLightTheme] — чи використовувати світлу тему.
  static TextStyle titleStyle({bool isLightTheme = false}) {
    return AppTypography.heading2.copyWith(
      color: titleTextColor(isLightTheme: isLightTheme),
      fontWeight: FontWeight.w600,
    );
  }

  /// Створює стиль тексту кнопки залежно від теми.
  ///
  /// [isLightTheme] — чи використовувати світлу тему.
  /// [isDestructive] — чи кнопка має деструктивний стиль (червона).
  static TextStyle buttonTextStyle({
    bool isLightTheme = false,
    bool isDestructive = false,
  }) {
    return AppTypography.buttonMedium.copyWith(
      color: isDestructive
          ? AppColorsPS5.error
          : Colors.white,
    );
  }

  /// Створює BoxDecoration для кнопки закриття.
  ///
  /// [isLightTheme] — чи використовувати світлу тему.
  static BoxDecoration closeButtonDecoration({bool isLightTheme = false}) {
    return BoxDecoration(
      color: borderColor(isLightTheme: isLightTheme).withOpacity(
        AppBottomSheetConstants.closeButtonBackgroundOpacity,
      ),
      shape: BoxShape.circle,
    );
  }

  /// Створює BoxDecoration для основної кнопки футера.
  ///
  /// [isLightTheme] — чи використовувати світлу тему.
  /// [isDestructive] — чи кнопка має деструктивний стиль.
  static BoxDecoration primaryButtonDecoration({
    bool isLightTheme = false,
    bool isDestructive = false,
  }) {
    return BoxDecoration(
      color: isDestructive
          ? AppColorsPS5.error
          : accentColor(isLightTheme: isLightTheme),
      borderRadius: BorderRadius.circular(Radii.button),
    );
  }

  /// Створює BoxDecoration для вторинної кнопки футера.
  ///
  /// [isLightTheme] — чи використовувати світлу тему.
  static BoxDecoration secondaryButtonDecoration({bool isLightTheme = false}) {
    return BoxDecoration(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(Radii.button),
      border: Border.all(
        color: borderColor(isLightTheme: isLightTheme),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Computed Properties Extension (Обчислювальні властивості)
// ═══════════════════════════════════════════════════════════════════════════

/// Розширення для [AppBottomSheet] з обчислюваними властивостями.
///
/// Забезпечує швидкий доступ до комплексних значень, що залежать
/// від комбінації кількох полів віджета.
extension AppBottomSheetComputedProperties on AppBottomSheet {
  /// Чи лист має видимий заголовок.
  ///
  /// Обчислюється на основі наявності title або header.
  bool get hasVisibleHeader => title != null || header != null;

  /// Чи лист має видимий футер.
  bool get hasVisibleFooter => footer != null;

  /// Чи лист повністю кастомний (заголовок та футер).
  ///
  /// Обчислюється як наявність обох кастомних компонентів.
  bool get isFullyCustom => header != null && footer != null;

  /// Чи лист має рукоятку перетягування.
  ///
  /// Враховує showDragHandle та isDraggable.
  bool get canDrag => showDragHandle && isDraggable;

  /// Чи лист можна закрити натисканням на фон.
  ///
  /// Враховує isDismissible та відсутність обов'язкового футера.
  bool get canDismissViaBackdrop => isDismissible;

  /// Опис листа для accessibility.
  ///
  /// Включає розмір, наявність заголовка та футера.
  String get accessibilityDescription {
    final parts = <String>['Нижній лист'];
    parts.add(sheetSize.description);
    if (title != null) parts.add('заголовок: $title');
    if (hasVisibleFooter) parts.add('з кнопками');
    return parts.join(', ');
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Validation Helpers (Допоміжні методи валідації)
// ═══════════════════════════════════════════════════════════════════════════

/// Допоміжні методи для перевірки конфігурації нижнього листа.
///
/// Використовується для попередження помилок конфігурації
/// при розробці нових листів.
class AppBottomSheetValidation {
  AppBottomSheetValidation._();

  /// Перевіряє, чи ширина рукоятки в допустимих межах.
  ///
  /// [width] — ширина рукоятки.
  /// Повертає `true`, якщо значення коректне.
  static bool isHandleWidthValid(double width) {
    return width >= AppBottomSheetConstants.minHandleWidth &&
        width <= AppBottomSheetConstants.maxHandleWidth;
  }

  /// Перевіряє, чи висота рукоятки в допустимих межах.
  ///
  /// [height] — висота рукоятки.
  /// Повертає `true`, якщо значення коректне.
  static bool isHandleHeightValid(double height) {
    return height >= AppBottomSheetConstants.minHandleHeight &&
        height <= AppBottomSheetConstants.maxHandleHeight;
  }

  /// Перевіряє, чи комбінація прапорців коректна.
  ///
  /// [isDraggable] — чи лист перетягуваний.
  /// [showDragHandle] — чи показувати рукоятку.
  /// Повертає рядок з попередженням або null якщо все ок.
  static String? validateDragConfig({
    required bool isDraggable,
    required bool showDragHandle,
  }) {
    if (showDragHandle && !isDraggable) {
      return 'showDragHandle is true but isDraggable is false';
    }
    return null;
  }

  /// Перевіряє, чи розмір листа підходить для контенту.
  ///
  /// [sheetSize] — розмір листа.
  /// [contentHeight] — висота контенту.
  /// [screenHeight] — висота екрана.
  /// Повертає `true`, якщо контент поміститься.
  static bool isContentFit({
    required SheetSize sheetSize,
    required double contentHeight,
    required double screenHeight,
  }) {
    final sheetHeight = sheetSize.toPixels(screenHeight);
    return sheetHeight >= contentHeight;
  }

  /// Перевіряє, чи конфігурація футера коректна.
  ///
  /// [hasFooter] — чи є футер.
  /// [isDismissible] — чи лист можна закрити.
  /// Повертає `true`, якщо конфігурація безпечна.
  static bool isFooterConfigSafe({
    required bool hasFooter,
    required bool isDismissible,
  }) {
    // Безпечна конфігурація: футер є і лист не dismissable
    // або футера немає і лист dismissable
    return hasFooter || isDismissible;
  }

  /// Обчислює рекомендовану висоту рукоятки залежно від розміру листа.
  ///
  /// Більші листи мають трохи товщу рукоятку.
  static double recommendedHandleHeight(SheetSize size) {
    switch (size) {
      case SheetSize.small:
        return AppBottomSheetConstants.defaultHandleHeight;
      case SheetSize.medium:
        return AppBottomSheetConstants.defaultHandleHeight;
      case SheetSize.large:
        return 5.0;
      case SheetSize.full:
        return 5.0;
    }
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Sheet Animation Presets (Пресети анімацій)
// ═══════════════════════════════════════════════════════════════════════════

/// Пресети анімацій для нижніх листів.
///
/// Дозволяє швидко застосувати популярні анімаційні ефекти.
enum SheetAnimationPreset {
  /// Стандартна плавна поява.
  ///
  /// Використовує Curves.easeOutCubic з тривалістю 300ms.
  standard(
    curve: Curves.easeOutCubic,
    durationMs: 300,
  ),

  /// Швидка поява (для small листів).
  ///
  /// Використовує Curves.easeOut з тривалістю 200ms.
  fast(
    curve: Curves.easeOut,
    durationMs: 200,
  ),

  /// Пружинна анімація (bounce ефект).
  ///
  /// Використовує Curves.elasticOut з тривалістю 500ms.
  bouncy(
    curve: Curves.elasticOut,
    durationMs: 500,
  ),

  /// Повільна плавна поява (для large/full листів).
  ///
  /// Використовує Curves.easeInOutCubic з тривалістю 400ms.
  slow(
    curve: Curves.easeInOutCubic,
    durationMs: 400,
  ),

  /// Мінімальна анімація (без ефектів).
  ///
  /// Використовує Curves.linear з тривалістю 150ms.
  minimal(
    curve: Curves.linear,
    durationMs: 150,
  );

  const SheetAnimationPreset({
    required this.curve,
    required this.durationMs,
  });

  /// Крива анімації.
  final Curve curve;

  /// Тривалість анімації в мілісекундах.
  final int durationMs;

  /// Тривалість як Duration.
  Duration get duration => Duration(milliseconds: durationMs);

  /// Опис пресету для налаштувань.
  String get description {
    switch (this) {
      case SheetAnimationPreset.standard:
        return 'Стандартна плавна анімація';
      case SheetAnimationPreset.fast:
        return 'Швидка анімація';
      case SheetAnimationPreset.bouncy:
        return 'Пружинна анімація з bounce';
      case SheetAnimationPreset.slow:
        return 'Повільна плавна анімація';
      case SheetAnimationPreset.minimal:
        return 'Мінімальна анімація';
    }
  }

  /// Українська назва пресету.
  String get label {
    switch (this) {
      case SheetAnimationPreset.standard:
        return 'Стандартна';
      case SheetAnimationPreset.fast:
        return 'Швидка';
      case SheetAnimationPreset.bouncy:
        return 'Пружинна';
      case SheetAnimationPreset.slow:
        return 'Повільна';
      case SheetAnimationPreset.minimal:
        return 'Мінімальна';
    }
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Sheet Configuration Builder (Конфігуратор)
// ═══════════════════════════════════════════════════════════════════════════

/// Конфігуратор для створення [AppBottomSheet] з pattern builder.
///
/// Дозволяє покроково налаштовувати параметри листа
/// та отримувати готовий віджет.
///
/// Приклад:
/// ```dart
/// final sheet = AppBottomSheetConfig.builder()
///     .title('Налаштування')
///     .sheetSize(SheetSize.large)
///     .isLightTheme(true)
///     .showDragHandle(true)
///     .build(child: settingsContent);
/// ```
class AppBottomSheetConfig {
  AppBottomSheetConfig._({
    this.sheetSize = SheetSize.medium,
    this.isLightTheme = false,
    this.title,
    this.showDragHandle = true,
    this.showCloseButton = true,
    this.header,
    this.footer,
    this.enableBackdropBlur = true,
    this.enableSafeArea = true,
    this.isDismissible = true,
    this.isDraggable = true,
    this.animationCurve = Curves.easeOutCubic,
    this.onDismiss,
    this.showBorder = true,
    this.handleColor,
    this.handleWidth = 40.0,
    this.handleHeight = 4.0,
    this.enableDragHandleAnimation = true,
    this.backgroundColor,
  });

  /// Створює новий конфігуратор з стандартними значеннями.
  ///
  /// Повертає порожній [AppBottomSheetConfig] для подальшого налаштування.
  static AppBottomSheetConfig builder() => AppBottomSheetConfig._();

  /// Розмір листа.
  final SheetSize sheetSize;

  /// Світла тема.
  final bool isLightTheme;

  /// Заголовок листа.
  final String? title;

  /// Показувати рукоятку перетягування.
  final bool showDragHandle;

  /// Показувати кнопку закриття.
  final bool showCloseButton;

  /// Кастомний заголовок.
  final Widget? header;

  /// Кастомний футер.
  final Widget? footer;

  /// Backdrop blur.
  final bool enableBackdropBlur;

  /// Safe area padding.
  final bool enableSafeArea;

  /// Чи можна закрити натисканням на фон.
  final bool isDismissible;

  /// Чи можна перетягувати.
  final bool isDraggable;

  /// Крива анімації.
  final Curve animationCurve;

  /// Callback при закритті.
  final VoidCallback? onDismiss;

  /// Показувати верхню межу.
  final bool showBorder;

  /// Кастомний колір рукоятки.
  final Color? handleColor;

  /// Ширина рукоятки.
  final double handleWidth;

  /// Висота рукоятки.
  final double handleHeight;

  /// Анімація рукоятки.
  final bool enableDragHandleAnimation;

  /// Кастомний колір фону.
  final Color? backgroundColor;

  /// Встановлює розмір листа.
  AppBottomSheetConfig withSheetSize(SheetSize size) => AppBottomSheetConfig._(
        sheetSize: size,
        isLightTheme: isLightTheme,
        title: title,
        showDragHandle: showDragHandle,
        showCloseButton: showCloseButton,
        header: header,
        footer: footer,
        enableBackdropBlur: enableBackdropBlur,
        enableSafeArea: enableSafeArea,
        isDismissible: isDismissible,
        isDraggable: isDraggable,
        animationCurve: animationCurve,
        onDismiss: onDismiss,
        showBorder: showBorder,
        handleColor: handleColor,
        handleWidth: handleWidth,
        handleHeight: handleHeight,
        enableDragHandleAnimation: enableDragHandleAnimation,
        backgroundColor: backgroundColor,
      );

  /// Встановлює заголовок.
  AppBottomSheetConfig withTitle(String? title) => AppBottomSheetConfig._(
        sheetSize: sheetSize,
        isLightTheme: isLightTheme,
        title: title,
        showDragHandle: showDragHandle,
        showCloseButton: showCloseButton,
        header: header,
        footer: footer,
        enableBackdropBlur: enableBackdropBlur,
        enableSafeArea: enableSafeArea,
        isDismissible: isDismissible,
        isDraggable: isDraggable,
        animationCurve: animationCurve,
        onDismiss: onDismiss,
        showBorder: showBorder,
        handleColor: handleColor,
        handleWidth: handleWidth,
        handleHeight: handleHeight,
        enableDragHandleAnimation: enableDragHandleAnimation,
        backgroundColor: backgroundColor,
      );

  /// Встановлює футер.
  AppBottomSheetConfig withFooter(Widget? footer) => AppBottomSheetConfig._(
        sheetSize: sheetSize,
        isLightTheme: isLightTheme,
        title: title,
        showDragHandle: showDragHandle,
        showCloseButton: showCloseButton,
        header: header,
        footer: footer,
        enableBackdropBlur: enableBackdropBlur,
        enableSafeArea: enableSafeArea,
        isDismissible: isDismissible,
        isDraggable: isDraggable,
        animationCurve: animationCurve,
        onDismiss: onDismiss,
        showBorder: showBorder,
        handleColor: handleColor,
        handleWidth: handleWidth,
        handleHeight: handleHeight,
        enableDragHandleAnimation: enableDragHandleAnimation,
        backgroundColor: backgroundColor,
      );

  /// Встановлює callback при закритті.
  AppBottomSheetConfig withOnDismiss(VoidCallback? onDismiss) =>
      AppBottomSheetConfig._(
        sheetSize: sheetSize,
        isLightTheme: isLightTheme,
        title: title,
        showDragHandle: showDragHandle,
        showCloseButton: showCloseButton,
        header: header,
        footer: footer,
        enableBackdropBlur: enableBackdropBlur,
        enableSafeArea: enableSafeArea,
        isDismissible: isDismissible,
        isDraggable: isDraggable,
        animationCurve: animationCurve,
        onDismiss: onDismiss,
        showBorder: showBorder,
        handleColor: handleColor,
        handleWidth: handleWidth,
        handleHeight: handleHeight,
        enableDragHandleAnimation: enableDragHandleAnimation,
        backgroundColor: backgroundColor,
      );

  /// Створює [AppBottomSheet] з поточною конфігурацією.
  AppBottomSheet build({required Widget child, Key? key}) => AppBottomSheet(
        key: key,
        child: child,
        sheetSize: sheetSize,
        isLightTheme: isLightTheme,
        title: title,
        showDragHandle: showDragHandle,
        showCloseButton: showCloseButton,
        header: header,
        footer: footer,
        enableBackdropBlur: enableBackdropBlur,
        enableSafeArea: enableSafeArea,
        isDismissible: isDismissible,
        isDraggable: isDraggable,
        animationCurve: animationCurve,
        onDismiss: onDismiss,
        showBorder: showBorder,
        handleColor: handleColor,
        handleWidth: handleWidth,
        handleHeight: handleHeight,
        enableDragHandleAnimation: enableDragHandleAnimation,
        backgroundColor: backgroundColor,
      );
}

// ═══════════════════════════════════════════════════════════════════════════
// Sheet Preset Configurations (Готові конфігурації)
// ═══════════════════════════════════════════════════════════════════════════

/// Готові конфігурації нижніх листів для поширених сценаріїв.
class AppBottomSheetPresets {
  AppBottomSheetPresets._();

  /// Створює конфігурацію для інформаційного повідомлення.
  ///
  /// [title] — заголовок повідомлення.
  /// [message] — текст повідомлення.
  /// [isLightTheme] — світла тема.
  static AppBottomSheetConfig infoConfig({
    required String title,
    bool isLightTheme = false,
  }) {
    return AppBottomSheetConfig.builder()
        .title(title)
        .sheetSize(SheetSize.small)
        .showDragHandle(false)
        .isDismissible(true);
  }

  /// Створює конфігурацію для діалогу підтвердження.
  ///
  /// [title] — заголовок діалогу.
  /// [isLightTheme] — світла тема.
  static AppBottomSheetConfig confirmConfig({
    required String title,
    bool isLightTheme = false,
  }) {
    return AppBottomSheetConfig.builder()
        .title(title)
        .sheetSize(SheetSize.small)
        .showDragHandle(false)
        .isDismissible(false);
  }

  /// Створює конфігурацію для форми вводу.
  ///
  /// [title] — заголовок форми.
  /// [isLightTheme] — світла тема.
  static AppBottomSheetConfig formConfig({
    required String title,
    bool isLightTheme = false,
  }) {
    return AppBottomSheetConfig.builder()
        .title(title)
        .sheetSize(SheetSize.large)
        .showDragHandle(true)
        .isDismissible(false)
        .showCloseButton(true);
  }

  /// Створює конфігурацію для фільтрів.
  ///
  /// [title] — заголовок фільтрів.
  /// [isLightTheme] — світла тема.
  static AppBottomSheetConfig filterConfig({
    required String title,
    bool isLightTheme = false,
  }) {
    return AppBottomSheetConfig.builder()
        .title(title)
        .sheetSize(SheetSize.medium)
        .showDragHandle(true)
        .isDismissible(true);
  }

  /// Створює конфігурацію для повноекранного контенту.
  ///
  /// [title] — заголовок.
  /// [isLightTheme] — світла тема.
  static AppBottomSheetConfig fullscreenConfig({
    String? title,
    bool isLightTheme = false,
  }) {
    return AppBottomSheetConfig.builder()
        .title(title)
        .sheetSize(SheetSize.full)
        .showDragHandle(true)
        .isDismissible(false)
        .showCloseButton(true);
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Additional Extensions (Додаткові розширення)
// ═══════════════════════════════════════════════════════════════════════════

/// Розширення для [SheetFooterSingle] з додатковими методами.
extension SheetFooterSingleExtension on SheetFooterSingle {
  /// Чи кнопка в активному стані.
  bool get isInteractive => isEnabled && !isLoading;

  /// Опис стану кнопки для accessibility.
  String get accessibilityState {
    if (!isEnabled) return 'Вимкнено';
    if (isLoading) return 'Завантаження';
    if (isSuccess) return 'Успішно';
    return 'Активна';
  }
}

/// Розширення для [SheetFooterDual] з додатковими методами.
extension SheetFooterDualExtension on SheetFooterDual {
  /// Чи обидві кнопки активні.
  bool get areBothInteractive => !isLoading;

  /// Чи основна кнопка має деструктивний стиль.
  bool get isDestructiveAction => isPrimaryDestructive;

  /// Опис стану футера для accessibility.
  String get accessibilityState {
    if (isLoading) return 'Завантаження';
    if (isPrimaryDestructive) return 'Деструктивна дія';
    return 'Стандартні кнопки';
  }
}

/// Розширення для контексту показу bottom sheet.
extension BottomSheetContextExtension on BuildContext {
  /// Показує [AppBottomSheet] з використанням поточного контексту.
  ///
  /// Це зручний метод, що дозволяє не передавати context явно.
  Future<T?> showAppBottomSheet<T>({
    required Widget child,
    SheetSize sheetSize = SheetSize.medium,
    bool isLightTheme = false,
    String? title,
    bool showDragHandle = true,
    bool showCloseButton = true,
    Widget? header,
    Widget? footer,
    bool isScrollControlled = true,
  }) {
    return AppBottomSheet.show<T>(
      context: this,
      child: child,
      sheetSize: sheetSize,
      isLightTheme: isLightTheme,
      title: title,
      showDragHandle: showDragHandle,
      showCloseButton: showCloseButton,
      header: header,
      footer: footer,
      isScrollControlled: isScrollControlled,
    );
  }

  /// Показує інформаційний лист з повідомленням.
  ///
  /// [title] — заголовок повідомлення.
  /// [message] — текст повідомлення.
  Future<void> showInfoSheet({
    required String title,
    required String message,
    bool isLightTheme = false,
  }) {
    return AppBottomSheet.info(
      context: this,
      title: title,
      message: message,
      isLightTheme: isLightTheme,
    );
  }

  /// Показує лист підтвердження.
  ///
  /// [title] — заголовок.
  /// [message] — повідомлення.
  Future<bool> showConfirmSheet({
    required String title,
    required String message,
    String? confirmLabel,
    String? cancelLabel,
    bool isLightTheme = false,
  }) {
    return AppBottomSheet.confirm(
      context: this,
      title: title,
      message: message,
      confirmLabel: confirmLabel,
      cancelLabel: cancelLabel,
      isLightTheme: isLightTheme,
    );
  }
}
