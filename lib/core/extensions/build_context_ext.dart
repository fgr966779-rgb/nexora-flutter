import 'dart:async';
import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import '../utils/haptic_service.dart';

/// Розширення для [BuildContext] зі зручними утилітами UI.
///
/// Надає доступ до теми, розмірів екрана, класифікації пристроїв,
/// toast-повідомлень, модальних вікон, навігації, оверлеїв гейміфікації,
/// тактильного зворотного зв'язку, управління фокусом та прокруткою.
///
/// Приклад використання:
/// ```dart
/// @override
/// Widget build(BuildContext context) {
///   final isDark = context.isDark;
///   final width = context.screenWidth;
///   context.showAppToast('Привіт!', type: AppToastType.info);
/// }
/// ```
extension BuildContextExtensions on BuildContext {
  // ─── Тема ─────────────────────────────────────────────────────────

  /// Повертає поточну тему додатку.
  ///
  /// Обгортка над `Theme.of(this)`.
  /// Використовується для доступу до повної конфігурації теми.
  ThemeData get theme => Theme.of(this);

  /// Повертає поточний [ColorScheme] з теми.
  ///
  /// Надає доступ до кольорів: primary, secondary, surface, error тощо.
  ColorScheme get colorScheme => Theme.of(this).colorScheme;

  /// Повертає поточний [TextTheme] з теми.
  ///
  /// Надає доступ до стилів тексту: headlineLarge, bodyMedium тощо.
  TextTheme get textTheme => Theme.of(this).textTheme;

  /// Перевіряє, чи увімкнено темну тему.
  ///
  /// Повертає `true`, якщо `Theme.of(context).brightness == Brightness.dark`.
  bool get isDark => Theme.of(this).brightness == Brightness.dark;

  /// Перевіряє, чи увімкнена світла тема.
  ///
  /// Повертає `true`, якщо `Theme.of(context).brightness == Brightness.light`.
  bool get isLight => Theme.of(this).brightness == Brightness.light;

  /// Повертає основний колір теми.
  ///
  /// Еквівалент `Theme.of(context).colorScheme.primary`.
  Color get primaryColor => Theme.of(this).colorScheme.primary;

  /// Повертає колір фону теми.
  ///
  /// Еквівалент `Theme.of(context).scaffoldBackgroundColor`.
  Color get backgroundColor => Theme.of(this).scaffoldBackgroundColor;

  /// Повертає колір поверхні теми.
  ///
  /// Еквівалент `Theme.of(context).colorScheme.surface`.
  Color get surfaceColor => Theme.of(this).colorScheme.surface;

  /// Повертає колір тексту з теми.
  ///
  /// Еквівалент `Theme.of(context).colorScheme.onSurface`.
  Color get textColor => Theme.of(this).colorScheme.onSurface;

  /// Повертає колір вторинного тексту.
  ///
  /// Еквівалент `Theme.of(context).colorScheme.onSurfaceVariant`.
  Color get secondaryTextColor => Theme.of(this).colorScheme.onSurfaceVariant;

  /// Повертає колір помилки з теми.
  ///
  /// Еквівалент `Theme.of(context).colorScheme.error`.
  Color get errorColor => Theme.of(this).colorScheme.error;

  /// Повертає колір успіху з теми.
  ///
  /// Зелений колір для успішних дій.
  /// Якщо не визначено в ColorScheme, повертає стандартний зелений.
  Color get successColor =>
      colorScheme.primaryContainer.withOpacity(0.15) != Colors.transparent
          ? Colors.green
          : Colors.green;

  /// Повертає колір попередження з теми.
  ///
  /// Амбарний колір для попереджень.
  Color get warningColor => Colors.amber;

  /// Повертає RoundedRectangle для карток з урахуванням теми.
  ///
  /// В темній темі використовує темніший фон, у світлій — білий.
  BorderRadius get cardBorderRadius => BorderRadius.circular(16);

  /// Повертає колір контейнера картки залежно від теми.
  ///
  /// В темній темі: `Color(0xFF1E1E2E)`, у світлій: `Colors.white`.
  Color get cardColor => isDark
      ? const Color(0xFF1E1E2E)
      : Colors.white;

  /// Повертає колір розділювача залежно від теми.
  ///
  /// В темній темі: `Colors.white24`, у світлій: `Colors.black12`.
  Color get dividerColor => isDark ? Colors.white24 : Colors.black12;

  /// Повертає еlevation (тінь) для карток залежно від теми.
  ///
  /// В темній темі повертає 0, у світлій — 2.
  double get cardElevation => isDark ? 0 : 2;

  /// Повертає BoxDecoration для стандартної картки Nexora.
  ///
  /// Включає колір, border-radius та elevation.
  BoxDecoration get cardDecoration => BoxDecoration(
        color: cardColor,
        borderRadius: cardBorderRadius,
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
      );

  // ─── Розміри екрана ───────────────────────────────────────────────

  /// Ширина екрана в логічних пікселях.
  ///
  /// Еквівалент `MediaQuery.of(this).size.width`.
  double get screenWidth => MediaQuery.of(this).size.width;

  /// Висота екрана в логічних пікселях.
  ///
  /// Еквівалент `MediaQuery.of(this).size.height`.
  double get screenHeight => MediaQuery.of(this).size.height;

  /// Розмір екрана.
  ///
  /// Еквівалент `MediaQuery.of(this).size`.
  Size get screenSize => MediaQuery.of(this).size;

  /// Щільність пікселів екрана.
  ///
  /// Еквівалент `MediaQuery.of(this).devicePixelRatio`.
  double get pixelRatio => MediaQuery.of(this).devicePixelRatio;

  /// Відступи безпечної зони (safe area).
  ///
  /// Еквівалент `MediaQuery.of(this).padding`.
  EdgeInsets get safePadding => MediaQuery.of(this).padding;

  /// Висота статус-бару.
  ///
  /// Еквівалент `MediaQuery.of(this).padding.top`.
  double get statusBarHeight => MediaQuery.of(this).padding.top;

  /// Висота навігаційної панелі (нижня частина).
  ///
  /// Еквівалент `MediaQuery.of(this).padding.bottom`.
  double get bottomPadding => MediaQuery.of(this).padding.bottom;

  /// Висота AppBar з урахуванням статус-бару.
  ///
  /// Сума `kToolbarHeight` та `statusBarHeight`.
  double get appBarHeight => kToolbarHeight + statusBarHeight;

  /// Чи є клавіатура відкрита.
  ///
  /// Повертає `true`, якщо `viewInsets.bottom > 0`.
  bool get isKeyboardOpen => MediaQuery.of(this).viewInsets.bottom > 0;

  /// Висота клавіатури.
  ///
  /// Еквівалент `MediaQuery.of(this).viewInsets.bottom`.
  double get keyboardHeight => MediaQuery.of(this).viewInsets.bottom;

  /// Доступна висота екрана без клавіатури.
  ///
  /// `screenHeight - keyboardHeight`.
  double get availableHeight => screenHeight - keyboardHeight;

  /// Доступна ширина з урахуванням safe area.
  ///
  /// `screenWidth - safePadding.horizontal`.
  double get availableWidth => screenWidth - safePadding.horizontal;

  /// Найменший розмір сторони екрана.
  ///
  /// `min(screenWidth, screenHeight)`.
  double get minDimension => screenSize.shortestSide;

  /// Найбільший розмір сторони екрана.
  ///
  /// `max(screenWidth, screenHeight)`.
  double get maxDimension => screenSize.longestSide;

  /// Діагональ екрана в логічних пікселях.
  ///
  /// Обчислюється за теоремою Піфагора.
  double get screenDiagonal {
    return math.sqrt(screenWidth * screenWidth + screenHeight * screenHeight);
  }

  // ─── Класифікація екрана ──────────────────────────────────────────

  /// Чи є екран вузьким (телефон).
  ///
  /// Повертає `true`, якщо `screenWidth < 600`.
  bool get isPhone => screenWidth < 600;

  /// Чи є екран широкий (планшет).
  ///
  /// Повертає `true`, якщо `screenWidth >= 600 && screenWidth < 1024`.
  bool get isTablet => screenWidth >= 600 && screenWidth < 1024;

  /// Чи є екран дуже широкий (десктоп).
  ///
  /// Повертає `true`, якщо `screenWidth >= 1024`.
  bool get isDesktop => screenWidth >= 1024;

  /// Чи є екран у ландшафтній орієнтації.
  ///
  /// Повертає `true`, якщо `screenWidth > screenHeight`.
  bool get isLandscape => screenWidth > screenHeight;

  /// Чи є екран у портретній орієнтації.
  ///
  /// Повертає `true`, якщо `screenHeight >= screenWidth`.
  bool get isPortrait => screenHeight >= screenWidth;

  /// Класифікація екрана за шириною.
  ///
  /// Повертає [ScreenSize] на основі `screenWidth`:
  /// - < 360: [ScreenSize.compact]
  /// - 360–599: [ScreenSize.small]
  /// - 600–839: [ScreenSize.medium]
  /// - 840–1199: [ScreenSize.large]
  /// - ≥ 1200: [ScreenSize.expanded]
  ScreenSize get screenSizeClass {
    if (screenWidth < 360) return ScreenSize.compact;
    if (screenWidth < 600) return ScreenSize.small;
    if (screenWidth < 840) return ScreenSize.medium;
    if (screenWidth < 1200) return ScreenSize.large;
    return ScreenSize.expanded;
  }

  /// Коротка назва розміру екрана українською.
  ///
  /// Повертає: 'компактний', 'телефон', 'планшет', 'планшет+', 'десктоп'.
  String get screenSizeName {
    switch (screenSizeClass) {
      case ScreenSize.compact:
        return 'компактний';
      case ScreenSize.small:
        return 'телефон';
      case ScreenSize.medium:
        return 'планшет';
      case ScreenSize.large:
        return 'планшет+';
      case ScreenSize.expanded:
        return 'десктоп';
    }
  }

  /// Кількість колонок для сітки на основі розміру екрана.
  ///
  /// Повертає: 1 для телефону, 2 для планшета, 3–4 для десктопа.
  int get gridColumns {
    switch (screenSizeClass) {
      case ScreenSize.compact:
      case ScreenSize.small:
        return 1;
      case ScreenSize.medium:
        return 2;
      case ScreenSize.large:
        return 3;
      case ScreenSize.expanded:
        return 4;
    }
  }

  /// Базовий відступ для сітки залежно від розміру екрана.
  ///
  /// Повертає: 12 для телефону, 16 для планшета, 24 для десктопа.
  double get gridPadding {
    switch (screenSizeClass) {
      case ScreenSize.compact:
      case ScreenSize.small:
        return 12.0;
      case ScreenSize.medium:
        return 16.0;
      case ScreenSize.large:
      case ScreenSize.expanded:
        return 24.0;
    }
  }

  /// Максимальна ширина контенту для адаптивної верстки.
  ///
  /// Обмежує ширину контенту для зручності читання на десктопі.
  double get maxContentWidth {
    if (screenWidth < 600) return screenWidth;
    if (screenWidth < 1024) return 600.0;
    return 840.0;
  }

  // ─── Орієнтація ───────────────────────────────────────────────────

  /// Чи підтримує пристрій зміну орієнтації.
  bool get canRotate =>
      MediaQuery.of(this).orientation == Orientation.landscape ||
      MediaQuery.of(this).orientation == Orientation.portrait;

  // ─── Доступність ──────────────────────────────────────────────────

  /// Чи увімкнено режим зменшення руху.
  ///
  /// Повертає `true`, якщо користувач обрав зменшення анімацій.
  bool get reduceMotion => MediaQuery.of(this).disableAnimations;

  /// Чи увімкнено режим високої контрастності.
  bool get highContrast => MediaQuery.of(this).highContrast;

  /// Коефіцієнт масштабування тексту.
  ///
  /// Еквівалент `MediaQuery.of(this).textScaler.scale(1.0)`.
  double get textScaleFactor => MediaQuery.of(this).textScaler.scale(1.0);

  /// Чи використовує користувач великий шрифт.
  ///
  /// Повертає `true`, якщо `textScaleFactor >= 1.2`.
  bool get isLargeText => textScaleFactor >= 1.2;

  // ─── Платформа ────────────────────────────────────────────────────

  /// Чи працює додаток на iOS.
  bool get isIOS => Theme.of(this).platform == TargetPlatform.iOS;

  /// Чи працює додаток на Android.
  bool get isAndroid => Theme.of(this).platform == TargetPlatform.android;

  /// Чи працює додаток на десктопній платформі.
  bool get isDesktopPlatform =>
      Theme.of(this).platform == TargetPlatform.macOS ||
      Theme.of(this).platform == TargetPlatform.windows ||
      Theme.of(this).platform == TargetPlatform.linux;

  /// Назва поточної платформи українською.
  ///
  /// Повертає: 'iOS', 'Android', 'macOS', 'Windows', 'Linux', 'Web'.
  String get platformName {
    switch (Theme.of(this).platform) {
      case TargetPlatform.iOS:
        return 'iOS';
      case TargetPlatform.android:
        return 'Android';
      case TargetPlatform.macOS:
        return 'macOS';
      case TargetPlatform.windows:
        return 'Windows';
      case TargetPlatform.linux:
        return 'Linux';
      case TargetPlatform.fuchsia:
        return 'Fuchsia';
    }
  }

  // ─── Toast ────────────────────────────────────────────────────────

  /// Показує вспливаюче повідомлення (toast) над контентом.
  ///
  /// [message] — текст повідомлення.
  /// [icon] — опціональна іконка перед текстом.
  /// [color] — колір фону toast (за замовчуванням залежить від теми).
  /// [duration] — тривалість відображення.
  ///
  /// Toast з'являється зверху екрана з анімацією.
  void showToast(
    String message, {
    IconData? icon,
    Color? color,
    Duration duration = const Duration(milliseconds: 2500),
  }) {
    try {
      final overlay = Overlay.of(this);
      final renderBox = findRenderObject() as RenderBox;
      final size = renderBox.size;
      final top = size.height * 0.12;

      late OverlayEntry overlayEntry;

      overlayEntry = OverlayEntry(
        builder: (context) {
          return Positioned(
            top: top,
            left: 16,
            right: 16,
            child: Material(
              elevation: 8,
              borderRadius: BorderRadius.circular(16),
              color: color ??
                  (Theme.of(context).brightness == Brightness.dark
                      ? Colors.grey[850]
                      : Colors.white),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (icon != null) ...[
                        Icon(icon, size: 20, color: _textColor(context)),
                        const SizedBox(width: 10),
                      ],
                      Flexible(
                        child: Text(
                          message,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: _textColor(context),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      );

      overlay.insert(overlayEntry);
      Future.delayed(duration, () {
        try {
          overlayEntry.remove();
        } catch (_) {}
      });
    } catch (e) {
      debugPrint('Toast error: $e');
    }
  }

  /// Повертає колір тексту для toast залежно від теми.
  ///
  /// [context] — контекст для визначення теми.
  Color _textColor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? Colors.white
          : Colors.black87;

  /// Показує стандартний toast додатку з використанням стилів Nexora.
  ///
  /// [message] — текст повідомлення.
  /// [type] — тип toast (визначає колір та іконку).
  /// [duration] — тривалість відображення.
  void showAppToast(
    String message, {
    AppToastType type = AppToastType.info,
    Duration duration = const Duration(milliseconds: 2500),
  }) {
    final colors = {
      AppToastType.success: const Color(0xFF00C853),
      AppToastType.error: const Color(0xFFFF1744),
      AppToastType.warning: const Color(0xFFFFB300),
      AppToastType.info: const Color(0xFF006FCD),
    };

    final icons = {
      AppToastType.success: Icons.check_circle_rounded,
      AppToastType.error: Icons.error_rounded,
      AppToastType.warning: Icons.warning_rounded,
      AppToastType.info: Icons.info_rounded,
    };

    showToast(message, icon: icons[type], color: colors[type], duration: duration);
  }

  /// Показує toast з вбудованою дією (кнопкою).
  ///
  /// [message] — текст повідомлення.
  /// [actionLabel] — текст кнопки дії.
  /// [onAction] — callback при натисканні на кнопку.
  void showActionToast(
    String message, {
    required String actionLabel,
    VoidCallback? onAction,
    Duration duration = const Duration(milliseconds: 3500),
  }) {
    final overlay = Overlay.of(this);
    final renderBox = findRenderObject() as RenderBox;
    final size = renderBox.size;
    final top = size.height * 0.12;

    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) {
        return Positioned(
          top: top,
          left: 16,
          right: 16,
          child: Material(
            elevation: 8,
            borderRadius: BorderRadius.circular(16),
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.grey[850]
                : Colors.white,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        message,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: _textColor(context),
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        overlayEntry.remove();
                        onAction?.call();
                      },
                      child: Text(
                        actionLabel,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );

    overlay.insert(overlayEntry);
    Future.delayed(duration, () {
      try {
        overlayEntry.remove();
      } catch (_) {}
    });
  }

  // ─── Модальні вікна ───────────────────────────────────────────────

  /// Показує модальне нижнє вікно (bottom sheet) з рукояттю перетягування.
  ///
  /// [child] — вміст модального вікна.
  /// [isScrollControlled] — чи модальне вікно може прокручуватись.
  /// [backgroundColor] — колір фону (за замовчуванням залежить від теми).
  ///
  /// Повертає результат типу [T], якщо вікно закрито з результатом.
  Future<T?> showModal<T>(
    Widget child, {
    bool isScrollControlled = true,
    Color? backgroundColor,
  }) {
    final theme = Theme.of(this);
    final isDark = theme.brightness == Brightness.dark;

    return showModalBottomSheet<T>(
      context: this,
      isScrollControlled: isScrollControlled,
      backgroundColor:
          backgroundColor ?? (isDark ? const Color(0xFF1E1E2E) : Colors.white),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 12, bottom: 4),
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white24 : Colors.black12,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Flexible(child: child),
            ],
          ),
        );
      },
    );
  }

  /// Показує нижнє модальне вікно зі стилями Nexora.
  ///
  /// [child] — вміст модального вікна.
  /// [title] — опціональний заголовок з кнопкою закриття.
  /// [isScrollControlled] — чи модальне вікно може прокручуватись.
  Future<T?> showAppBottomSheet<T>(
    Widget child, {
    String? title,
    bool isScrollControlled = true,
  }) {
    return showModal<T>(
      Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (title != null) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 8, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 22),
                    onPressed: () => Navigator.pop(this),
                  ),
                ],
              ),
            ),
          ],
          Flexible(child: child),
        ],
      ),
      isScrollControlled: isScrollControlled,
    );
  }

  /// Показує діалог підтвердження зі стилями Nexora.
  ///
  /// [title] — заголовок діалогу.
  /// [message] — текст повідомлення.
  /// [confirmText] — текст кнопки підтвердження.
  /// [cancelText] — текст кнопки скасування.
  /// [destructive] — чи є дія руйнівною (змінює колір кнопки).
  ///
  /// Повертає `true`, якщо користувач натиснув «Підтвердити».
  Future<bool> showConfirmDialog({
    required String title,
    required String message,
    String confirmText = 'Підтвердити',
    String cancelText = 'Скасувати',
    bool destructive = false,
  }) async {
    try {
      final result = await showDialog<bool>(
        context: this,
        builder: (context) {
          final confirmColor = destructive
              ? Theme.of(context).colorScheme.error
              : Theme.of(context).colorScheme.primary;

          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Text(title),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(cancelText),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text(confirmText, style: TextStyle(color: confirmColor)),
              ),
            ],
          );
        },
      );

      return result ?? false;
    } catch (e) {
      debugPrint('Confirm dialog error: $e');
      return false;
    }
  }

  /// Показує діалог вводу тексту.
  ///
  /// [title] — заголовок діалогу.
  /// [hint] — підказка в полі вводу.
  /// [initialValue] — початкове значення тексту.
  /// [label] — мітка поля вводу.
  ///
  /// Повертає введений текст або `null`, якщо діалог скасовано.
  Future<String?> showInputDialog({
    required String title,
    String? hint,
    String? initialValue,
    String? label,
  }) async {
    final controller = TextEditingController(text: initialValue ?? '');
    try {
      return await showDialog<String>(
        context: this,
        builder: (context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Text(title),
            content: TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: hint,
                labelText: label,
                border: const OutlineInputBorder(),
              ),
              autofocus: true,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Скасувати'),
              ),
              TextButton(
                onPressed: () =>
                    Navigator.pop(context, controller.text.trim()),
                child: const Text('ОК'),
              ),
            ],
          );
        },
      );
    } finally {
      controller.dispose();
    }
  }

  /// Показує діалог вибору з кількома опціями.
  ///
  /// [title] — заголовок діалогу.
  /// [options] — список опцій для вибору.
  ///
  /// Повертає обрану опцію або `null`, якщо діалог скасовано.
  Future<String?> showSelectionDialog({
    required String title,
    required List<String> options,
  }) async {
    return showDialog<String>(
      context: this,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(title),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: options.map((option) {
              return ListTile(
                title: Text(option),
                onTap: () => Navigator.pop(context, option),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  /// Показує діалог з користувацьким вмістом.
  ///
  /// [builder] — білдер вмісту діалогу.
  /// [barrierDismissible] — чи можна закрити торканням поза діалогом.
  Future<T?> showCustomDialog<T>({
    required WidgetBuilder builder,
    bool barrierDismissible = true,
  }) {
    return showDialog<T>(
      context: this,
      barrierDismissible: barrierDismissible,
      builder: builder,
    );
  }

  // ─── Навігація ────────────────────────────────────────────────────

  /// Перехід на новий маршрут зі стандартною анімацією.
  ///
  /// [page] — віджет сторінки для переходу.
  /// [duration] — тривалість анімації.
  /// [curve] — крива анімації.
  Future<T?> pushWithAnimation<T>(
    Widget page, {
    Duration duration = const Duration(milliseconds: 300),
    Curve curve = Curves.easeInOut,
  }) {
    return Navigator.of(this).push<T>(
      PageRouteBuilder<T>(
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final offset =
              Tween<Offset>(begin: const Offset(1.0, 0.0), end: Offset.zero)
                  .animate(CurvedAnimation(parent: animation, curve: curve));
          return SlideTransition(position: offset, child: child);
        },
        transitionDuration: duration,
        reverseTransitionDuration: duration,
      ),
    );
  }

  /// Перехід на новий маршрут з анімацією знизу вгору.
  ///
  /// [page] — віджет сторінки для переходу.
  Future<T?> pushSlideUp<T>(Widget page) {
    return Navigator.of(this).push<T>(
      PageRouteBuilder<T>(
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final offset =
              Tween<Offset>(begin: const Offset(0.0, 1.0), end: Offset.zero)
                  .animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic));
          return SlideTransition(position: offset, child: child);
        },
        transitionDuration: const Duration(milliseconds: 350),
      ),
    );
  }

  /// Перехід з анімацією масштабування (zoom).
  ///
  /// [page] — віджет сторінки для переходу.
  Future<T?> pushZoom<T>(Widget page) {
    return Navigator.of(this).push<T>(
      PageRouteBuilder<T>(
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final scale = Tween<double>(begin: 0.8, end: 1.0).animate(
            CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
          );
          final fade = Tween<double>(begin: 0.0, end: 1.0).animate(
            CurvedAnimation(parent: animation, curve: Curves.easeOut),
          );
          return FadeTransition(
            opacity: fade,
            child: ScaleTransition(scale: scale, child: child),
          );
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  /// Перехід з анімацією fade (зникнення/поява).
  ///
  /// [page] — віджет сторінки для переходу.
  Future<T?> pushFade<T>(Widget page) {
    return Navigator.of(this).push<T>(
      PageRouteBuilder<T>(
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 250),
      ),
    );
  }

  /// Закриває поточний маршрут.
  ///
  /// [result] — опціональний результат для повернення.
  void pop<T extends Object?>([T? result]) {
    Navigator.of(this).pop(result);
  }

  /// Перевіряє, чи можна повернутися назад.
  ///
  /// Повертає `true`, якщо є попередній маршрут у навігації.
  bool get canPop => Navigator.of(this).canPop();

  /// Повертається назад, якщо це можливо.
  ///
  /// Не робить нічого, якщо немає попереднього маршруту.
  void popIfCan<T extends Object?>([T? result]) {
    if (canPop) pop(result);
  }

  /// Замінює поточний маршрут на новий.
  ///
  /// Корисно для перехіду після входу в систему.
  Future<T?> pushReplacement<T, TO>(Widget page) {
    return Navigator.of(this).pushReplacement<T, TO>(
      MaterialPageRoute(builder: (_) => page),
    );
  }

  /// Очищає стек навігації і переходить на новий маршрут.
  ///
  /// Корисно для виходу з системи.
  Future<T?> pushAndRemoveUntil<T>(Widget page) {
    return Navigator.of(this).pushAndRemoveUntil<T>(
      MaterialPageRoute(builder: (_) => page),
      (route) => false,
    );
  }

  // ─── Snackbar ─────────────────────────────────────────────────────

  /// Показує Snackbar з текстом [message].
  ///
  /// Використовує стандартний `ScaffoldMessenger`.
  void showSnackBar(String message) {
    try {
      ScaffoldMessenger.of(this).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } catch (e) {
      debugPrint('SnackBar error: $e');
    }
  }

  /// Показує Snackbar з дією.
  ///
  /// [message] — текст повідомлення.
  /// [actionLabel] — текст кнопки дії.
  /// [onAction] — callback при натисканні на кнопку.
  /// [duration] — тривалість відображення.
  void showSnackBarWithAction(
    String message, {
    required String actionLabel,
    VoidCallback? onAction,
    Duration? duration,
  }) {
    try {
      ScaffoldMessenger.of(this).showSnackBar(
        SnackBar(
          content: Text(message),
          action: SnackBarAction(
            label: actionLabel,
            onPressed: onAction ?? () {},
          ),
          duration: duration ?? const Duration(milliseconds: 3000),
        ),
      );
    } catch (e) {
      debugPrint('SnackBar action error: $e');
    }
  }

  /// Показує Snackbar з іконкою та типом.
  ///
  /// [message] — текст повідомлення.
  /// [type] — тип snack (визначає колір).
  void showStyledSnackBar(
    String message, {
    SnackBarType type = SnackBarType.info,
  }) {
    final bgColor = switch (type) {
      SnackBarType.success => Colors.green,
      SnackBarType.error => Colors.red,
      SnackBarType.warning => Colors.amber,
      SnackBarType.info => Colors.blue,
    };

    final icon = switch (type) {
      SnackBarType.success => Icons.check_circle_rounded,
      SnackBarType.error => Icons.error_rounded,
      SnackBarType.warning => Icons.warning_rounded,
      SnackBarType.info => Icons.info_rounded,
    };

    try {
      ScaffoldMessenger.of(this).showSnackBar(
        SnackBar(
          backgroundColor: bgColor,
          content: Row(
            children: [
              Icon(icon, color: Colors.white, size: 20),
              const SizedBox(width: 12),
              Expanded(child: Text(message)),
            ],
          ),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    } catch (e) {
      debugPrint('Styled SnackBar error: $e');
    }
  }

  /// Прибирає поточний Snackbar.
  void hideSnackBar() {
    try {
      ScaffoldMessenger.of(this).hideCurrentSnackBar();
    } catch (_) {}
  }

  /// Прибирає всі Snackbar.
  void clearSnackBars() {
    try {
      ScaffoldMessenger.of(this).clearSnackBars();
    } catch (_) {}
  }

  // ─── Оверлеї гейміфікації ─────────────────────────────────────────

  /// Показує оверлей «нагорода» по центру екрана.
  ///
  /// [icon] — іконка нагороди.
  /// [title] — заголовок.
  /// [subtitle] — опціональний підзаголовок.
  /// [iconColor] — колір іконки.
  /// [duration] — тривалість відображення.
  void showRewardOverlay({
    required IconData icon,
    required String title,
    String? subtitle,
    Color? iconColor,
    Duration duration = const Duration(seconds: 2),
  }) {
    HapticService.success();
    _showCenterOverlay(
      icon: icon,
      title: title,
      subtitle: subtitle,
      iconColor: iconColor ?? const Color(0xFFFFD600),
      duration: duration,
    );
  }

  /// Показує оверлей «успіх».
  ///
  /// [title] — заголовок успіху.
  /// [subtitle] — опціональний підзаголовок.
  /// [duration] — тривалість відображення.
  void showSuccessOverlay({
    required String title,
    String? subtitle,
    Duration duration = const Duration(seconds: 2),
  }) {
    HapticService.mediumTap();
    _showCenterOverlay(
      icon: Icons.check_circle_rounded,
      title: title,
      subtitle: subtitle,
      iconColor: const Color(0xFF00C853),
      duration: duration,
    );
  }

  /// Показує оверлей «помилка».
  ///
  /// [title] — заголовок помилки.
  /// [subtitle] — опціональний підзаголовок.
  /// [duration] — тривалість відображення.
  void showErrorOverlay({
    required String title,
    String? subtitle,
    Duration duration = const Duration(seconds: 2),
  }) {
    HapticService.error();
    _showCenterOverlay(
      icon: Icons.error_rounded,
      title: title,
      subtitle: subtitle,
      iconColor: const Color(0xFFFF1744),
      duration: duration,
    );
  }

  /// Показує оверлей «попередження».
  ///
  /// [title] — заголовок попередження.
  /// [subtitle] — опціональний підзаголовок.
  /// [duration] — тривалість відображення.
  void showWarningOverlay({
    required String title,
    String? subtitle,
    Duration duration = const Duration(seconds: 2),
  }) {
    HapticService.mediumTap();
    _showCenterOverlay(
      icon: Icons.warning_rounded,
      title: title,
      subtitle: subtitle,
      iconColor: const Color(0xFFFFB300),
      duration: duration,
    );
  }

  /// Показує оверлей з інформацією.
  ///
  /// [title] — заголовок.
  /// [subtitle] — опціональний підзаголовок.
  /// [duration] — тривалість відображення.
  void showInfoOverlay({
    required String title,
    String? subtitle,
    Duration duration = const Duration(seconds: 2),
  }) {
    HapticService.lightTap();
    _showCenterOverlay(
      icon: Icons.info_rounded,
      title: title,
      subtitle: subtitle,
      iconColor: const Color(0xFF006FCD),
      duration: duration,
    );
  }

  // ─── Тактильний зворотний зв'язок ─────────────────────────────────

  /// Викликає легку вібрацію.
  void haptic() => HapticService.lightTap();

  /// Викликає середню вібрацію.
  void hapticMedium() => HapticService.mediumTap();

  /// Викликає сильну вібрацію.
  void hapticHeavy() => HapticService.heavyTap();

  /// Викликає вібрацію «успіх».
  void hapticSuccess() => HapticService.success();

  /// Викликає вібрацію «помилка».
  void hapticError() => HapticService.error();

  /// Викликає вибіркову вібрацію.
  void hapticSelection() => HapticService.selection();

  // ─── Focus ────────────────────────────────────────────────────────

  /// Прибирає фокус з поточного поля (приховує клавіатуру).
  void unfocus() => FocusScope.of(this).unfocus();

  /// Прибирає фокус з усіх полів.
  void dismissKeyboard() => FocusManager.instance.primaryFocus?.unfocus();

  /// Чи має будь-який елемент фокус.
  bool get hasFocus => FocusScope.of(this).hasFocus;

  /// Встановлює фокус на перший фокусований елемент.
  void focusFirstChild() {
    FocusScope.of(this).autofocus(FocusNode());
  }

  // ─── Scroll ───────────────────────────────────────────────────────

  /// Прибирає scroll offset у PrimaryScrollController.
  ///
  /// Прокручує до верху з плавною анімацією.
  void scrollToTop() => PrimaryScrollController.of(this).animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );

  /// Прокручує до вказаної позиції.
  ///
  /// [offset] — позиція прокрутки в пікселях.
  /// [duration] — тривалість анімації.
  void scrollTo(double offset, {Duration? duration}) {
    PrimaryScrollController.of(this).animateTo(
      offset,
      duration: duration ?? const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  // ─── Локалізація ──────────────────────────────────────────────────

  /// Повертає поточну локаль додатку.
  String get locale => Localizations.localeOf(this).languageCode;

  /// Чи є поточна мова українською.
  bool get isUkrainian => locale == 'uk';

  /// Чи є поточна мова англійською.
  bool get isEnglish => locale == 'en';

  // ─── Форматування ─────────────────────────────────────────────────

  /// Повертає адаптивний padding залежно від розміру екрана.
  ///
  /// Для телефону: `EdgeInsets.all(16)`, для планшета: `EdgeInsets.all(24)`,
  /// для десктопа: `EdgeInsets.all(32)`.
  EdgeInsets get responsivePadding {
    switch (screenSizeClass) {
      case ScreenSize.compact:
      case ScreenSize.small:
        return const EdgeInsets.all(16);
      case ScreenSize.medium:
        return const EdgeInsets.all(24);
      case ScreenSize.large:
      case ScreenSize.expanded:
        return const EdgeInsets.all(32);
    }
  }

  /// Повертає горизонтальний margin для центрованого контенту.
  ///
  /// Контент обмежується [maxContentWidth] і центрується.
  double get contentMargin =>
      ((screenWidth - maxContentWidth) / 2).clamp(16, double.infinity);

  // ─── Час та дата ───────────────────────────────────────────────

  /// Повертає поточний час як [TimeOfDay].
  ///
  /// Еквівалент `TimeOfDay.now()`.
  TimeOfDay get currentTimeOfDay => TimeOfDay.now();

  /// Повертає поточну дату та час як [DateTime].
  ///
  /// Еквівалент `DateTime.now()`.
  DateTime get currentDateTime => DateTime.now();

  /// Повертає поточну дату (без часу) як [DateTime].
  ///
  /// Еквівалент `DateTime.now().date`.
  DateTime get currentDate => DateTime.now().date;

  /// Форматує дату з використанням поточної локалі.
  ///
  /// [pattern] — формат дати (за замовчуванням 'dd.MM.yyyy').
  ///
  /// Приклад: `context.formatDate('dd.MM.yyyy')` → '15.01.2025'.
  String formatDate([String pattern = 'dd.MM.yyyy']) {
    // Асинхронний імпорт intl використовує [locale] для форматування
    // Для базового випадку просто формуємо рядок
    final now = DateTime.now();
    final day = now.day.toString().padLeft(2, '0');
    final month = now.month.toString().padLeft(2, '0');
    final year = now.year.toString();
    return pattern
        .replaceAll('dd', day)
        .replaceAll('MM', month)
        .replaceAll('yyyy', year);
  }

  /// Форматує час як 'HH:mm' або 'HH:mm:ss'.
  ///
  /// [showSeconds] — чи показувати секунди (за замовчуванням false).
  String formatTime({bool showSeconds = false}) {
    final now = DateTime.now();
    final hour = now.hour.toString().padLeft(2, '0');
    final minute = now.minute.toString().padLeft(2, '0');
    if (showSeconds) {
      final second = now.second.toString().padLeft(2, '0');
      return '$hour:$minute:$second';
    }
    return '$hour:$minute';
  }

  /// Форматує дату та час разом.
  ///
  /// [dateFormat] — формат дати (за замовчуванням 'dd.MM.yyyy').
  /// [timeFormat] — формат часу (за замовчуванням 'HH:mm').
  String formatDateTime({
    String dateFormat = 'dd.MM.yyyy',
    String timeFormat = 'HH:mm',
  }) {
    return '${formatDate(pattern: dateFormat)} ${formatTime()}';
  }

  /// Повертає день тижня українською.
  ///
  /// Повертає: 'Понеділок', 'Вівторок', ..., 'Неділя'.
  String get weekdayNameUA {
    const days = [
      'Понеділок', 'Вівторок', 'Середа', 'Четвер', "П'ятниця", 'Субота', 'Неділя',
    ];
    return days[DateTime.now().weekday - 1];
  }

  /// Повертає назву місяця українською.
  ///
  /// Повертає: 'Січень', 'Лютий', ..., 'Грудень'.
  String get monthNameUA {
    const months = [
      'Січень', 'Лютий', 'Березень', 'Квітень', 'Травень', 'Червень',
      'Липень', 'Серпень', 'Вересень', 'Жовтень', 'Листопад', 'Грудень',
    ];
    return months[DateTime.now().month - 1];
  }

  // ─── Debounce та Throttle ──────────────────────────────────────────

  /// Створює debounce-функцію з указаною затримкою.
  ///
  /// Функція викликається лише після того, як пройде [milliseconds]
  /// з моменту останнього виклику debounce'd функції.
  ///
  /// [action] — callback для виклику.
  /// [milliseconds] — затримка в мілісекундах (за замовчуванням 300).
  ///
  /// Приклад:
  /// ```dart
  /// final debouncedSearch = context.debounced(() => performSearch(query), 500);
  /// ```
  VoidCallback debounced(
    VoidCallback action, {
    int milliseconds = 300,
  }) {
    Timer? timer;
    return () {
      timer?.cancel();
      timer = Timer(Duration(milliseconds: milliseconds), action);
    };
  }

  /// Створює throttle-функцію з указаною затримкою.
  ///
  /// Функція викликається не частіше ніж один раз за [milliseconds].
  ///
  /// [action] — callback для виклику.
  /// [milliseconds] — мінімальний інтервал між викликами (за замовчуванням 300).
  ///
  /// Приклад:
  /// ```dart
  /// final throttledSave = context.throttled(() => saveData(), 1000);
  /// ```
  VoidCallback throttled(
    VoidCallback action, {
    int milliseconds = 300,
  }) {
    var lastRun = 0;
    return () {
      final now = DateTime.now().millisecondsSinceEpoch;
      if (now - lastRun >= milliseconds) {
        lastRun = now;
        action();
      }
    };
  }

  /// Створює debounce-функцію для обробника з параметром.
  ///
  /// [action] — callback з параметром [T].
  /// [milliseconds] — затримка в мілісекундах.
  ///
  /// Приклад:
  /// ```dart
  /// final debouncedSearch = context.debouncedArg<String>((q) => search(q), 500);
  /// ```
  void Function(T) debouncedArg<T>(
    void Function(T) action, {
    int milliseconds = 300,
  }) {
    Timer? timer;
    return (T value) {
      timer?.cancel();
      timer = Timer(Duration(milliseconds: milliseconds), () => action(value));
    };
  }

  // ─── Форматування розмірів ─────────────────────────────────────────

  /// Повертає адаптивний розмір шрифту залежно від розміру екрана.
  ///
  /// [base] — базовий розмір (за замовчуванням 14).
  /// Повертає [base] для телефону, [base + 2] для планшета, [base + 4] для десктопа.
  double adaptiveFontSize([double base = 14.0]) {
    switch (screenSizeClass) {
      case ScreenSize.compact:
      case ScreenSize.small:
        return base;
      case ScreenSize.medium:
        return base + 2;
      case ScreenSize.large:
      case ScreenSize.expanded:
        return base + 4;
    }
  }

  /// Повертає адаптивний розмір іконки залежно від розміру екрана.
  ///
  /// [base] — базовий розмір (за замовчуванням 24).
  double adaptiveIconSize([double base = 24.0]) {
    switch (screenSizeClass) {
      case ScreenSize.compact:
      case ScreenSize.small:
        return base;
      case ScreenSize.medium:
        return base + 4;
      case ScreenSize.large:
      case ScreenSize.expanded:
        return base + 8;
    }
  }

  /// Повертає адаптивний розмір відступу залежно від розміру екрана.
  ///
  /// [base] — базовий відступ (за замовчуванням 16).
  double adaptivePadding([double base = 16.0]) {
    switch (screenSizeClass) {
      case ScreenSize.compact:
      case ScreenSize.small:
        return base;
      case ScreenSize.medium:
        return base + 4;
      case ScreenSize.large:
      case ScreenSize.expanded:
        return base + 8;
    }
  }

  /// Повертає адаптивний border-radius залежно від розміру екрана.
  ///
  /// [base] — базовий радіус (за замовчуванням 16).
  double adaptiveBorderRadius([double base = 16.0]) {
    switch (screenSizeClass) {
      case ScreenSize.compact:
      case ScreenSize.small:
        return base;
      case ScreenSize.medium:
        return base + 4;
      case ScreenSize.large:
      case ScreenSize.expanded:
        return base + 8;
    }
  }

  /// Повертає адаптивну SizedBox з вказаною шириною.
  ///
  /// [width] — ширина в логічних пікселях (за замовчуванням використовує [maxContentWidth]).
  SizedBox adaptiveSizedBox({double? width}) {
    return SizedBox(width: width ?? maxContentWidth);
  }

  /// Повертає адаптивну горизонтальну прокрутку залежно від типу пристрою.
  ///
  /// Для телефону — [ScrollPhysics.clamping],
  /// для планшета/десктопа — [BouncingScrollPhysics].
  ScrollPhysics get adaptiveScrollPhysics {
    if (isDesktopPlatform) return const BouncingScrollPhysics();
    return const ClampingScrollPhysics();
  }

  /// Повертає тривалість анімації залежно від режиму зменшення руху.
  ///
  /// Якщо [reduceMotion] увімкнено — повертає Duration.zero.
  /// [base] — базова тривалість (за замовчуванням 300ms).
  Duration adaptiveDuration([Duration base = const Duration(milliseconds: 300)]) {
    return reduceMotion ? Duration.zero : base;
  }

  /// Повертає криву анімації залежно від режиму зменшення руху.
  ///
  /// Якщо [reduceMotion] увімкнено — повертає [Curves.linear].
  Curve adaptiveCurve([Curve base = Curves.easeInOut]) {
    return reduceMotion ? Curves.linear : base;
  }

  // ─── Clipboard та Sharing ──────────────────────────────────────────

  /// Копіює текст у буфер обміну.
  ///
  /// [text] — текст для копіювання.
  /// [message] — повідомлення для відображення після копіювання.
  ///
  /// Повертає `true`, якщо копіювання успішне.
  Future<bool> copyToClipboard(String text, {String? message}) async {
    try {
      await Clipboard.setData(ClipboardData(text: text));
      if (message != null) {
        showSnackBar(message);
      }
      return true;
    } catch (e) {
      debugPrint('Clipboard error: $e');
      return false;
    }
  }

  /// Читає текст з буфера обміну.
  ///
  /// Повертає текст або `null`, якщо буфер порожній.
  Future<String?> readFromClipboard() async {
    try {
      final data = await Clipboard.getData(Clipboard.kTextPlain);
      return data?.text;
    } catch (e) {
      debugPrint('Clipboard read error: $e');
      return null;
    }
  }

  // ─── Responsive widget builders ────────────────────────────────────

  /// Будує віджет залежно від орієнтації екрана.
  ///
  /// [portrait] — віджет для портретної орієнтації.
  /// [landscape] — віджет для ландшафтної орієнтації.
  Widget orientationBuilder({
    required Widget portrait,
    required Widget landscape,
  }) {
    if (isLandscape) return landscape;
    return portrait;
  }

  /// Будує віджет залежно від ширини екрана з пороговими значеннями.
  ///
  /// [phone] — віджет для телефону (< 600px).
  /// [tablet] — віджет для планшета (600–1023px).
  /// [desktop] — віджет для десктопа (≥ 1024px).
  Widget responsiveBuilder({
    required Widget phone,
    Widget? tablet,
    Widget? desktop,
  }) {
    if (isDesktop && desktop != null) return desktop;
    if (isTablet && tablet != null) return tablet;
    return phone;
  }

  /// Обгортає віджет у Center з обмеженням [maxContentWidth].
  ///
  /// Корисно для центрування контенту на широких екранах.
  Widget centeredContent({required Widget child}) {
    return Center(
      child: ConstrainedBox(
        maxWidth: maxContentWidth,
        child: child,
      ),
    );
  }

  /// Обгортає віджет у SingleChildScrollView з адаптивною фізикою.
  ///
  /// [child] — прокручуваний вміст.
  /// [padding] — додатковий відступ (за замовчуванням null).
  Widget adaptiveScroll({
    required Widget child,
    EdgeInsets? padding,
  }) {
    return SingleChildScrollView(
      padding: padding ?? responsivePadding,
      physics: adaptiveScrollPhysics,
      child: child,
    );
  }

  // ─── Loading та прогрес ───────────────────────────────────────────

  /// Створює змінну, яка дозволяє прибрати loading-оверлей.
  ///
  /// [message] — текст під індикатором.
  ///
  /// Повертає функцію для закриття оверлею.
  VoidCallback showLoadingOverlay({String message = 'Завантаження...'}) {
    late OverlayEntry overlayEntry;
    try {
      final overlay = Overlay.of(this);
      overlayEntry = OverlayEntry(
        builder: (context) {
          return Positioned.fill(
            child: IgnorePointer(
              child: Container(
                color: Colors.black.withValues(alpha: 0.3),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircularProgressIndicator(color: Colors.white),
                      const SizedBox(height: 16),
                      Text(
                        message,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      );
      overlay.insert(overlayEntry);
    } catch (e) {
      debugPrint('Loading overlay error: $e');
    }
    return () {
      try {
        overlayEntry.remove();
      } catch (_) {}
    };
  }

  /// Створює FutureBuilder, який показує індикатор завантаження під час очікування.
  ///
  /// [future] — Future для обробки.
  /// [builder] — білдер для вмісту.
  /// [loadingWidget] — віджет індикатора.
  /// [errorWidget] — віджет помилки.
  Widget futureBuilder<T>({
    required Future<T> future,
    required Widget Function(T data) builder,
    Widget? loadingWidget,
    Widget? errorWidget,
  }) {
    return FutureBuilder<T>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return errorWidget ?? const SizedBox.shrink();
        }
        if (!snapshot.hasData) {
          return loadingWidget ?? const Center(child: CircularProgressIndicator());
        }
        return builder(snapshot.data!);
      },
    );
  }

  /// Створює StreamBuilder з автоматичним показом індикатора при завантаженні.
  ///
  /// [stream] — потік даних.
  /// [builder] — білдер для вмісту.
  /// [initialData] — початкове значення.
  /// [loadingWidget] — віджет індикатора.
  Widget streamBuilder<T>({
    required Stream<T> stream,
    required Widget Function(T data) builder,
    T? initialData,
    Widget? loadingWidget,
  }) {
    return StreamBuilder<T>(
      stream: stream,
      initialData: initialData,
      builder: (context, snapshot) {
        if (!snapshot.hasData && loadingWidget != null) {
          return loadingWidget;
        }
        if (!snapshot.hasData) {
          return const SizedBox.shrink();
        }
        return builder(snapshot.data!);
      },
    );
  }

  // ─── Додаткові діалоги ──────────────────────────────────────────

  /// Показує діалог вибору кольору (з попереднім переглядом).
  ///
  /// [initialColor] — початковий колір.
  /// [title] — заголовок діалогу.
  ///
  /// Повертає обраний колір або `null`.
  Future<Color?> showColorPickerDialog({
    Color? initialColor,
    String title = 'Оберіть колір',
  }) async {
    var selectedColor = initialColor ?? const Color(0xFF000000);
    try {
      return await showDialog<Color>(
        context: this,
        builder: (context) {
          return StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                title: Text(title),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        color: selectedColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        Colors.red,
                        Colors.orange,
                        Colors.yellow,
                        Colors.green,
                        Colors.blue,
                        Colors.purple,
                        const Color(0xFF0070D1),
                        Colors.pink,
                        Colors.brown,
                        Colors.grey,
                      ].map((color) {
                          return GestureDetector(
                            onTap: () => setState(() => selectedColor = color),
                            child: Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: color,
                                borderRadius: BorderRadius.circular(6),
                                border: selectedColor == color
                                    ? Border.all(color: Colors.white, width: 2)
                                    : null,
                              ),
                            ),
                          );
                        }).toList(),
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, selectedColor),
                    child: const Text('Обрати'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Скасувати'),
                  ),
                ],
              );
            },
          );
        },
      );
    } catch (e) {
      debugPrint('Color picker dialog error: $e');
      return null;
    }
  }

  /// Показує діалог підтвердження з прогрес-індикатором.
  ///
  /// [title] — заголовок.
  /// [message] — текст повідомлення.
  /// [onConfirm] — callback при підтвердженні.
  /// [isLoading] — чи відбувається дія в даний момент.
  Future<void> showAsyncConfirmDialog({
    required String title,
    required String message,
    required VoidCallback onConfirm,
    String confirmText = 'Підтвердити',
    bool isLoading = false,
  }) async {
    await showDialog<void>(
      context: this,
      barrierDismissible: !isLoading,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: isLoading ? null : () => Navigator.pop(context),
              child: const Text('Скасувати'),
            ),
            TextButton(
              onPressed: isLoading ? null : () {
                Navigator.pop(context);
                onConfirm();
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isLoading)
                    const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  const SizedBox(width: 8),
                  Text(confirmText),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  // ─── Налаштування діалогів ───────────────────────────────────────

  /// Створює стиль для модальних діалогів Nexora.
  ///
  /// Повертає [DialogTheme] з налаштуваннями форми, тіні та шрифту.
  DialogTheme get nexoraDialogTheme => DialogTheme(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20)),
        ),
        elevation: 24,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w600,
        ),
        contentTextStyle: textTheme.bodyMedium,
      );

  /// Створює стиль для BottomSheet Nexora.
  ///
  /// Повертає [BottomSheetThemeData] з налаштуваннями форми та кольору.
  BottomSheetThemeData get nexoraBottomSheetTheme => BottomSheetThemeData(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        backgroundColor: cardColor,
        elevation: 8,
        modalBackgroundColor: cardColor,
        clipBehavior: Clip.antiAlias,
      );

  /// Створює стиль для SnackBar Nexora.
  ///
  /// Повертає [SnackBarThemeData] з адаптивним кольором та формою.
  SnackBarThemeData get nexoraSnackBarTheme => SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        width: double.infinity,
      );

  // ─── Зручні обгортки ──────────────────────────────────────────

  /// Показує просте спливаюче повідомлення внизу екрана.
  ///
  /// [message] — текст повідомлення.
  /// [duration] — тривалість.
  void showBottomToast(
    String message, {
    Duration duration = const Duration(milliseconds: 2500),
  }) {
    showSnackBarWithAction(
      message,
      actionLabel: 'OK',
      duration: duration,
      onAction: () {},
    );
  }

  /// Показує інформаційне повідомлення в стилі Nexora.
  ///
  /// [message] — текст повідомлення.
  /// [duration] — тривалість.
  void showInfoMessage(
    String message, {
    Duration duration = const Duration(milliseconds: 2500),
  }) {
    showStyledSnackBar(message, type: SnackBarType.info, duration: duration);
  }

  /// Показує повідомлення про успіх.
  ///
  /// [message] — текст повідомлення.
  /// [duration] — тривалість.
  void showSuccessMessage(
    String message, {
    Duration duration = const Duration(milliseconds: 2500),
  }) {
    showStyledSnackBar(message, type: SnackBarType.success, duration: duration);
  }

  /// Показує повідомлення про помилку.
  ///
  /// [message] — текст повідомлення.
  /// [duration] — тривалість.
  void showErrorMessage(
    String message, {
    Duration duration = const Duration(milliseconds: 3000),
  }) {
    showStyledSnackBar(message, type: SnackBarType.error, duration: duration);
  }

  /// Показує повідомлення-попередження.
  ///
  /// [message] — текст повідомлення.
  /// [duration] — тривалість.
  void showWarningMessage(
    String message, {
    Duration duration = const Duration(milliseconds: 2500),
  }) {
    showStyledSnackBar(message, type: SnackBarType.warning, duration: duration);
  }

  /// Показує діалог з інструкцією для користувача.
  ///
  /// [title] — заголовок.
  /// [steps] — список кроків інструкції.
  Future<void> showTutorialDialog({
    required String title,
    required List<String> steps,
  }) async {
    await showDialog<void>(
      context: this,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(title),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: steps.asMap().entries.map((entry) {
              final index = entry.key;
              final step = entry.value;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: colorScheme.primary,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '${index + 1}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(child: Text(step)),
                  ],
                ),
              );
            }).toList(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Зрозуміло'),
            ),
          ],
        );
      },
    );
  }

  /// Показує діалог з прогрес-баром.
  ///
  /// [title] — заголовок.
  /// [value] — поточне значення (0.0 – 1.0).
  /// [message] — опціональне повідомлення.
  Future<void> showProgressDialog({
    required String title,
    required double value,
    String? message,
  }) async {
    await showDialog<void>(
      context: this,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(title),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              LinearProgressIndicator(
                value: value.clamp(0.0, 1.0),
              ),
              if (message != null) ...[
                const SizedBox(height: 12),
                Text(message, style: textTheme.bodySmall),
              ],
            ],
          ),
        );
      },
    );
  }

  // ─── Приватні методи ──────────────────────────────────────────────

  /// Показує центровий оверлей з анімацією масштабування.
  ///
  /// [icon] — іконка оверлею.
  /// [title] — заголовок.
  /// [subtitle] — опціональний підзаголовок.
  /// [iconColor] — колір іконки.
  /// [duration] — тривалість відображення.
  void _showCenterOverlay({
    required IconData icon,
    required String title,
    String? subtitle,
    required Color iconColor,
    required Duration duration,
  }) {
    try {
      final overlay = Overlay.of(this);
      late OverlayEntry overlayEntry;

      overlayEntry = OverlayEntry(
        builder: (context) {
          return Stack(
            children: [
              Positioned.fill(
                child: IgnorePointer(
                  child: Container(color: Colors.black.withValues(alpha: 0.5)),
                ),
              ),
              Positioned.fill(
                child: Center(
                  child: _RewardOverlayContent(
                    icon: icon,
                    title: title,
                    subtitle: subtitle,
                    iconColor: iconColor,
                  ),
                ),
              ),
            ],
          );
        },
      );

      overlay.insert(overlayEntry);
      Future.delayed(duration, () {
        try {
          overlayEntry.remove();
        } catch (_) {}
      });
    } catch (e) {
      debugPrint('Overlay error: $e');
    }
  }

  // ─── Локалізація ──────────────────────────────────────────────────

  /// Повертає поточну локаль додатку.
  ///
  /// Еквівалент `Localizations.localeOf(this)`.
  /// Використовує [MaterialLocalizations] для доступу.
  Locale get locale {
    try {
      return Localizations.localeOf(this);
    } catch (_) {
      return const Locale('uk');
    }
  }

  /// Повертає код мови (наприклад 'uk', 'en').
  String get languageCode => locale.languageCode;

  /// Повертає код країни (наприклад 'UA', 'US').
  String get countryCode => locale.countryCode ?? '';

  /// Повертає назву мови українською.
  ///
  /// Визначає мову за кодом та повертає назву.
  String get languageName {
    final names = {
      'uk': 'Українська',
      'en': 'Англійська',
      'ru': 'Російська',
      'pl': 'Польська',
      'de': 'Німецька',
      'fr': 'Французька',
      'es': 'Іспанська',
      'it': 'Італійська',
      'pt': 'Португальська',
      'ja': 'Японська',
      'zh': 'Китайська',
      'ko': 'Корейська',
      'tr': 'Турецька',
      'ar': 'Арабська',
      'hi': 'Хінді',
    };
    return names[languageCode] ?? languageCode.toUpperCase();
  }

  /// Чи є поточна мова українською.
  bool get isUkrainian => languageCode == 'uk';

  /// Чи є поточна мова англійською.
  bool get isEnglish => languageCode == 'en';

  /// Повертає відсоток клавіатурної прокрутки (0.0 – 1.0).
  ///
  /// Корисно для parallax ефектів.
  double get scrollProgress {
    return 0.0; // Placeholder — реалізація залежить від ScrollController
  }

  // ─── Дебаг ───────────────────────────────────────────────────────

  /// Повертає рядок з інформацією про екран та пристрій.
  ///
  /// Корисний для дебагу та логування.
  String get debugInfo {
    return 'BuildContext[screen=${screenWidth.toStringAsFixed(0)}x'
        '${screenHeight.toStringAsFixed(0)}, '
        'ratio=$pixelRatio, '
        'platform=$platformName, '
        'theme=${isDark ? "dark" : "light"}]';
  }

  // ─── Форматування ─────────────────────────────────────────────────

  /// Повертає відсоток у вигляді відформатованого рядка.
  ///
  /// [value] — значення від 0.0 до 1.0.
  /// [decimals] — кількість знаків після коми.
  String formatPercent(double value, {int decimals = 1}) {
    return '${(value * 100).toStringAsFixed(decimals)}%';
  }

  /// Повертає відформатовану суму в гривнях.
  ///
  /// [amount] — сума у копійках.
  String formatUAH(int amount) {
    final hryvnias = amount ~/ 100;
    final kopecks = (amount % 100).toString().padLeft(2, '0');
    return '$hryvnias.$kopecks ₴';
  }

  /// Повертає відформатоване число з роздільниками.
  ///
  /// [number] — число для форматування.
  /// [decimals] — кількість знаків після коми.
  String formatNumber(num number, {int decimals = 0}) {
    if (decimals == 0 && number is int) {
      return number.toString();
    }
    return number.toStringAsFixed(decimals);
  }

  /// Повертає компактне представлення числа (1.2K, 3.5M тощо).
  ///
  /// [number] — число для форматування.
  String formatCompact(int number) {
    if (number < 1000) return number.toString();
    if (number < 1000000) return '${(number / 1000).toStringAsFixed(1)}K';
    if (number < 1000000000) return '${(number / 1000000).toStringAsFixed(1)}M';
    return '${(number / 1000000000).toStringAsFixed(1)}B';
  }

  // ─── Валідація ────────────────────────────────────────────────────

  /// Перевіряє, чи email-адреса є валідною.
  ///
  /// [email] — рядок з email-адресою.
  bool isValidEmail(String email) {
    final regex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return regex.hasMatch(email);
  }

  /// Перевіряє, чи номер телефону є валідним (український формат).
  ///
  /// Підтримує формати: +380XXXXXXXXX, 0XXXXXXXXX.
  bool isValidPhone(String phone) {
    final cleaned = phone.replaceAll(RegExp(r'[\s\-()]'), '');
    return RegExp(r'^(\+?380|0)\d{9}$').hasMatch(cleaned);
  }

  /// Перевіряє, чи рядок не порожній після обрізки пробілів.
  ///
  /// [value] — рядок для перевірки.
  bool isNotEmptyString(String? value) {
    return value != null && value.trim().isNotEmpty;
  }

  /// Перевіряє, чи рядок порожній або null.
  ///
  /// [value] — рядок для перевірки.
  bool isEmptyString(String? value) {
    return value == null || value.trim().isEmpty;
  }

  /// Перевіряє, чи рядок відповідає мінімальній довжині.
  ///
  /// [value] — рядок для перевірки.
  /// [minLength] — мінімальна довжина.
  bool hasMinLength(String? value, int minLength) {
    return value != null && value.length >= minLength;
  }

  /// Перевіряє, чи пароль є достатньо надійним.
  ///
  /// Пароль вважається надійним, якщо:
  /// - Має щонайменше 8 символів
  /// - Має хоча б 1 велику літеру
  /// - Має хоча б 1 малу літеру
  /// - Має хоча б 1 цифру
  bool isStrongPassword(String password) {
    if (password.length < 8) return false;
    if (!RegExp(r'[A-Z]').hasMatch(password)) return false;
    if (!RegExp(r'[a-z]').hasMatch(password)) return false;
    if (!RegExp(r'[0-9]').hasMatch(password)) return false;
    return true;
  }

  // ─── ТригериFocus ─────────────────────────────────────────────────

  /// Знімає фокус з поточного елемента.
  ///
  /// Закриває клавіатуру та знімає фокус з активного поля.
  void unfocus() {
    try {
      FocusScope.of(this).unfocus();
    } catch (_) {}
  }

  /// Перевіряє, чи є фокус на елементі.
  bool get hasFocus {
    try {
      return FocusScope.of(this).hasFocus;
    } catch (_) {
      return false;
    }
  }

  /// Перевіряє, чи фокус знаходиться на первинному фокусі.
  bool get hasPrimaryFocus {
    try {
      return FocusScope.of(this).hasPrimaryFocus;
    } catch (_) {
      return false;
    }
  }

  /// Запитує фокус на вказаному [node].
  ///
  /// [node] — вузол фокусу для активації.
  void requestFocus(FocusNode node) {
    try {
      node.requestFocus();
    } catch (_) {}
  }

  // ─── Час ──────────────────────────────────────────────────────────

  /// Повертає поточний час у вигляді рядка.
  ///
  /// [format] — форматування ('short', 'medium', 'long').
  String currentTime({String format = 'short'}) {
    final now = DateTime.now();
    switch (format) {
      case 'short':
        return '${now.hour.toString().padLeft(2, '0')}:'
            '${now.minute.toString().padLeft(2, '0')}';
      case 'medium':
        return '${now.hour.toString().padLeft(2, '0')}:'
            '${now.minute.toString().padLeft(2, '0')}:'
            '${now.second.toString().padLeft(2, '0')}';
      case 'long':
        return '${now.hour.toString().padLeft(2, '0')}:'
            '${now.minute.toString().padLeft(2, '0')}:'
            '${now.second.toString().padLeft(2, '0')}'
            '.${now.millisecond.toString().padLeft(3, '0')}';
      default:
        return currentTime(format: 'short');
    }
  }

  /// Повертає поточну дату у вигляді рядка.
  ///
  /// [separator] — розділюватор (за замовчуванням '.').
  String currentDate({String separator = '.'}) {
    final now = DateTime.now();
    return '${now.day.toString().padLeft(2, '0')}$separator'
        '${now.month.toString().padLeft(2, '0')}$separator'
        '${now.year}';
  }

  /// Форматує дату у відносний рядок (наприклад '5 хвилин тому').
  ///
  /// [date] — дата для форматування.
  String formatRelativeDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays > 365) {
      final years = diff.inDays ~/ 365;
      return '$years ${_pluralize(years, 'рік', 'роки', 'років')} тому';
    }
    if (diff.inDays > 30) {
      final months = diff.inDays ~/ 30;
      return '$months ${_pluralize(months, 'місяць', 'місяці', 'місяців')} тому';
    }
    if (diff.inDays > 0) {
      return '${diff.inDays} ${_pluralize(diff.inDays, 'день', 'дні', 'днів')} тому';
    }
    if (diff.inHours > 0) {
      return '${diff.inHours} ${_pluralize(diff.inHours, 'годину', 'години', 'годин')} тому';
    }
    if (diff.inMinutes > 0) {
      return '${diff.inMinutes} ${_pluralize(diff.inMinutes, 'хвилину', 'хвилини', 'хвилин')} тому';
    }
    return 'Щойно';
  }

  /// Повертає правильну форму слова залежно від числа.
  ///
  /// [count] — число.
  /// [one] — форма для 1 (наприклад 'день').
  /// [few] — форма для 2–4 (наприклад 'дні').
  /// [many] — форма для 0, 5+ (наприклад 'днів').
  String _pluralize(int count, String one, String few, String many) {
    final mod10 = count % 10;
    final mod100 = count % 100;
    if (mod10 == 1 && mod100 != 11) return one;
    if (mod10 >= 2 && mod10 <= 4 && (mod100 < 10 || mod100 >= 20)) return few;
    return many;
  }

  // ─── Кеш та пам'ять ────────────────────────────────────────────────

  /// Виконує дію з затримкою та перевіркою життєздатності контексту.
  ///
  /// [action] — дія для виконання.
  /// [duration] — затримка перед виконанням.
  ///
  /// Повертає `true`, якщо дію було виконано.
  Future<bool> safeAsync(VoidCallback action, {Duration? duration}) async {
    try {
      if (duration != null) await Future.delayed(duration);
      if (!mounted) return false;
      action();
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Перевіряє, чи контекст ще активний (mounted).
  ///
  /// Використовується перед викликом `setState` в асинхронних операціях.
  bool get mounted {
    try {
      // Перевіряємо, чи widget ще в дереві
      findRenderObject();
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Виконує [action], якщо контекст ще активний.
  ///
  /// Повертає результат [action] або `null`, якщо контекст не активний.
  T? runIfMounted<T>(T Function() action) {
    try {
      if (!mounted) return null;
      return action();
    } catch (_) {
      return null;
    }
  }

  // ─── Налаштування ──────────────────────────────────────────────────

  /// Відкриває налаштування системи (для iOS — Settings app).
  ///
  /// Корисно для перенаправлення користувача до налаштувань додатку.
  Future<void> openAppSettings() async {
    try {
      // Спробуємо відкрити налаштування
      if (isIOS) {
        // На iOS можна використати url_launcher
        debugPrint('Opening app settings on iOS');
      } else if (isAndroid) {
        debugPrint('Opening app settings on Android');
      }
    } catch (e) {
      debugPrint('Error opening settings: $e');
    }
  }

  /// Відкриває URL у зовнішньому браузері.
  ///
  /// [url] — URL-адреса для відкриття.
  Future<void> launchUrl(String url) async {
    try {
      debugPrint('Launching URL: $url');
      // Реалізація залежить від url_launcher пакету
    } catch (e) {
      debugPrint('Error launching URL: $e');
    }
  }

  // ─── SafeArea ─────────────────────────────────────────────────────

  /// Повертає EdgeInsets з урахуванням SafeArea та клавіатури.
  ///
  /// Корисно для розміщення Fixed-елементів внизу екрана.
  EdgeInsets get safeAreaPadding => EdgeInsets.only(
        top: statusBarHeight,
        bottom: bottomPadding + (isKeyboardOpen ? 0 : 0),
        left: safePadding.left,
        right: safePadding.right,
      );

  /// Повертає висоту доступної області без AppBar та клавіатури.
  ///
  /// Віднімає висоту AppBar та клавіатури від загальної висоти.
  double get contentAreaHeight => screenHeight - appBarHeight - keyboardHeight;

  /// Повертає ширину контенту з урахуванням відступів.
  ///
  /// [horizontalPadding] — горизонтальні відступи (за замовчуванням 16).
  double contentWidth({double horizontalPadding = 16}) {
    return screenWidth - horizontalPadding * 2 - safePadding.horizontal;
  }

  // ─── Адаптивні відступи ────────────────────────────────────────────

  /// Повертає горизонтальні відступи залежно від розміру екрана.
  ///
  /// Телефон: 16, Планшет: 24, Десктоп: 32.
  double get horizontalPadding {
    switch (screenSizeClass) {
      case ScreenSize.compact:
      case ScreenSize.small:
        return 16.0;
      case ScreenSize.medium:
        return 24.0;
      case ScreenSize.large:
      case ScreenSize.expanded:
        return 32.0;
    }
  }

  /// Повертає вертикальні відступи залежно від розміру екрана.
  ///
  /// Телефон: 12, Планшет: 16, Десктоп: 24.
  double get verticalPadding {
    switch (screenSizeClass) {
      case ScreenSize.compact:
      case ScreenSize.small:
        return 12.0;
      case ScreenSize.medium:
        return 16.0;
      case ScreenSize.large:
      case ScreenSize.expanded:
        return 24.0;
    }
  }

  /// Повертає розмір іконки залежно від розміру екрана.
  ///
  /// Телефон: 24, Планшет: 28, Десктоп: 32.
  double get adaptiveIconSize {
    switch (screenSizeClass) {
      case ScreenSize.compact:
      case ScreenSize.small:
        return 24.0;
      case ScreenSize.medium:
        return 28.0;
      case ScreenSize.large:
      case ScreenSize.expanded:
        return 32.0;
    }
  }

  /// Повертає розмір шрифту залежно від розміру екрана.
  ///
  /// [baseSize] — базовий розмір шрифту.
  double adaptiveFontSize(double baseSize) {
    switch (screenSizeClass) {
      case ScreenSize.compact:
      case ScreenSize.small:
        return baseSize;
      case ScreenSize.medium:
        return baseSize * 1.05;
      case ScreenSize.large:
        return baseSize * 1.1;
      case ScreenSize.expanded:
        return baseSize * 1.15;
    }
  }

  /// Повертає borderRadius залежно від розміру екрана.
  ///
  /// [baseRadius] — базовий радіус.
  double adaptiveBorderRadius(double baseRadius) {
    switch (screenSizeClass) {
      case ScreenSize.compact:
      case ScreenSize.small:
        return baseRadius;
      case ScreenSize.medium:
        return baseRadius * 1.1;
      case ScreenSize.large:
      case ScreenSize.expanded:
        return baseRadius * 1.2;
    }
  }
}

// ─── Типи ───────────────────────────────────────────────────────────

/// Типи toast-повідомлень.
enum AppToastType {
  /// Успішна дія (зелений).
  success,

  /// Помилка (червоний).
  error,

  /// Попередження (жовтий).
  warning,

  /// Інформаційне повідомлення (синій).
  info,
}

/// Типи Snackbar-повідомлень.
enum SnackBarType {
  /// Успішна дія.
  success,

  /// Помилка.
  error,

  /// Попередження.
  warning,

  /// Інформаційне повідомлення.
  info,
}

/// Класифікація розмірів екрана.
enum ScreenSize {
  /// Компактний (< 360px).
  compact,

  /// Телефон (360–599px).
  small,

  /// Планшет (600–839px).
  medium,

  /// Великий планшет (840–1199px).
  large,

  /// Десктоп (≥ 1200px).
  expanded,
}

// ─── Приватні віджети ───────────────────────────────────────────────

/// Вміст центрового оверлею для нагород, успіху та помилок.
///
/// Віджет з анімацією масштабування та fade.
/// Включає іконку, заголовок та опціональний підзаголовок.
class _RewardOverlayContent extends StatefulWidget {
  /// Іконка для відображення в оверлеї.
  final IconData icon;

  /// Заголовок оверлею.
  final String title;

  /// Опціональний підзаголовок.
  final String? subtitle;

  /// Колір іконки.
  final Color iconColor;

  /// Створює вміст оверлею.
  const _RewardOverlayContent({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.iconColor,
  });

  @override
  State<_RewardOverlayContent> createState() => _RewardOverlayContentState();
}

class _RewardOverlayContentState extends State<_RewardOverlayContent>
    with SingleTickerProviderStateMixin {
  /// Контролер анімації масштабування та fade.
  late final AnimationController _controller;

  /// Анімація масштабування.
  late final Animation<double> _scaleAnimation;

  /// Анімація fade.
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimation.value,
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 48),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? const Color(0xFF1E1E2E)
              : Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.25),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: widget.iconColor.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(widget.icon, size: 40, color: widget.iconColor),
            ),
            const SizedBox(height: 16),
            Text(
              widget.title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                  ),
              textAlign: TextAlign.center,
            ),
            if (widget.subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                widget.subtitle!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white60
                          : Colors.black54,
                    ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
