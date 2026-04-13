import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../constants/app_colors.dart';
import '../constants/app_typography.dart';
import '../constants/app_radii.dart';
import '../constants/app_durations.dart';
import '../constants/app_easings.dart';

// ═══════════════════════════════════════════════════════════════════════
// Опис елемента навігації (Nav Item Definition)
// ═══════════════════════════════════════════════════════════════════════
// ignore_for_file: avoid_equals_and_hash_code_on_wrappers

/// Опис одного елемента нижньої навігаційної панелі.
///
/// Містить всі необхідні дані для відображення вкладки:
/// іконки, мітку, бейдж, індикатор непрочитого, tooltip.
///
/// Приклад створення:
/// ```dart
/// final homeItem = AppNavItem(
///   icon: Icons.home_outlined,
///   activeIcon: Icons.home_rounded,
///   label: 'Головна',
///   tooltip: 'Головний екран',
/// );
/// ```
class AppNavItem {
  const AppNavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    this.badgeCount,
    this.hasUnread = false,
    this.customActiveColor,
    this.tooltip,
    this.isEnabled = true,
    this.showBadge = true,
    this.isCenterAction = false,
    this.subtitle,
    this.semanticLabel,
    this.routeName,
  });

  /// Іконка у неактивному стані.
  final IconData icon;

  /// Іконка у активному стані (filled variant).
  final IconData activeIcon;

  /// Текстова мітка під іконкою (українською).
  final String label;

  /// Лічильник бейджів на іконці (наприклад, кількість сповіщень).
  final int? badgeCount;

  /// Індикатор непрочитаного контенту (синя точка).
  final bool hasUnread;

  /// Кастомний колір для активного стану (перевизначає тему).
  final Color? customActiveColor;

  /// Текст підказки (для екранних читачів та довгого натискання).
  final String? tooltip;

  /// Чи елемент доступний для натискання.
  final bool isEnabled;

  /// Чи показувати бейдж-лічильник (навіть якщо badgeCount > 0).
  final bool showBadge;

  /// Чи це центральна кнопка дії (FAB-стиль).
  final bool isCenterAction;

  /// Додатковий підзаголовок під міткою (для expanded вигляду).
  final String? subtitle;

  /// Семантична мітка для екранних читачів.
  final String? semanticLabel;

  /// Ім'я маршруту для навігації (для deep linking).
  final String? routeName;

  /// Повертає відформатований бейдж для відображення.
  ///
  /// Повертає пустий рядок якщо бейдж відсутній або прихований.
  String get displayBadgeText {
    if (badgeCount == null || !showBadge || badgeCount! <= 0) return '';
    return badgeCount! > 99 ? '99+' : '$badgeCount';
  }

  /// Повертає текст для екранних читачів при натисканні.
  String get accessibilityLabel {
    final label = semanticLabel ?? this.label;
    final badgeInfo = displayBadgeText.isNotEmpty
        ? ', $displayBadgeText нових'
        : '';
    return 'Вкладка $label$badgeInfo';
  }

  /// Копія з перевизначенням значень.
  AppNavItem copyWith({
    IconData? icon,
    IconData? activeIcon,
    String? label,
    int? badgeCount,
    bool? hasUnread,
    Color? customActiveColor,
    String? tooltip,
    bool? isEnabled,
    bool? showBadge,
    bool? isCenterAction,
    String? subtitle,
    String? semanticLabel,
    String? routeName,
  }) {
    return AppNavItem(
      icon: icon ?? this.icon,
      activeIcon: activeIcon ?? this.activeIcon,
      label: label ?? this.label,
      badgeCount: badgeCount ?? this.badgeCount,
      hasUnread: hasUnread ?? this.hasUnread,
      customActiveColor: customActiveColor ?? this.customActiveColor,
      tooltip: tooltip ?? this.tooltip,
      isEnabled: isEnabled ?? this.isEnabled,
      showBadge: showBadge ?? this.showBadge,
      isCenterAction: isCenterAction ?? this.isCenterAction,
      subtitle: subtitle ?? this.subtitle,
      semanticLabel: semanticLabel ?? this.semanticLabel,
      routeName: routeName ?? this.routeName,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppNavItem &&
          runtimeType == other.runtimeType &&
          icon == other.icon &&
          activeIcon == other.activeIcon &&
          label == other.label &&
          badgeCount == other.badgeCount &&
          hasUnread == other.hasUnread &&
          isCenterAction == other.isCenterAction;

  @override
  int get hashCode => Object.hash(
        icon,
        activeIcon,
        label,
        badgeCount,
        hasUnread,
        isCenterAction,
      );
}

// ═══════════════════════════════════════════════════════════════════════
// Стандартні елементи навігації (Default Nav Items)
// ═══════════════════════════════════════════════════════════════════════

/// Стандартні елементи навігації Nexora (5 вкладок).
///
/// Використовується як значення за замовчуванням для [AppBottomNav].
/// Містить: Головна, Аналітика, Додати, Гейміфікація, Налаштування.
final List<AppNavItem> defaultNavItems = [
  const AppNavItem(
    icon: Icons.home_outlined,
    activeIcon: Icons.home_rounded,
    label: 'Головна',
    tooltip: 'Головний екран',
    routeName: '/home',
  ),
  const AppNavItem(
    icon: Icons.bar_chart_outlined,
    activeIcon: Icons.bar_chart_rounded,
    label: 'Аналітика',
    tooltip: 'Аналітика та статистика',
    routeName: '/analytics',
  ),
  const AppNavItem(
    icon: Icons.add_circle_outline_rounded,
    activeIcon: Icons.add_circle_rounded,
    label: 'Додати',
    tooltip: 'Додати запис',
    isCenterAction: true,
  ),
  const AppNavItem(
    icon: Icons.emoji_events_outlined,
    activeIcon: Icons.emoji_events_rounded,
    label: 'Гейміфікація',
    tooltip: 'Виклики та досягнення',
    routeName: '/gamification',
  ),
  const AppNavItem(
    icon: Icons.settings_outlined,
    activeIcon: Icons.settings_rounded,
    label: 'Налаштування',
    tooltip: 'Налаштування профілю',
    routeName: '/settings',
  ),
];

/// Компактний набір навігації (3 вкладки для маленьких екранів).
///
/// Містить: Головна, Додати, Ще.
final List<AppNavItem> compactNavItems = [
  const AppNavItem(
    icon: Icons.home_outlined,
    activeIcon: Icons.home_rounded,
    label: 'Головна',
    tooltip: 'Головний екран',
    routeName: '/home',
  ),
  const AppNavItem(
    icon: Icons.add_circle_outline_rounded,
    activeIcon: Icons.add_circle_rounded,
    label: 'Додати',
    tooltip: 'Додати запис',
    isCenterAction: true,
  ),
  const AppNavItem(
    icon: Icons.settings_outlined,
    activeIcon: Icons.settings_rounded,
    label: 'Ще',
    tooltip: 'Додаткові опції',
  ),
];

/// Набір навігації з бейджами (для тестування та демо).
///
/// Містить вкладки з різними бейджами.
final List<AppNavItem> navItemsWithBadges = [
  const AppNavItem(
    icon: Icons.home_outlined,
    activeIcon: Icons.home_rounded,
    label: 'Головна',
    tooltip: 'Головний екран',
    badgeCount: 0,
  ),
  const AppNavItem(
    icon: Icons.bar_chart_outlined,
    activeIcon: Icons.bar_chart_rounded,
    label: 'Аналітика',
    tooltip: 'Аналітика та статистика',
    badgeCount: 3,
  ),
  const AppNavItem(
    icon: Icons.add_circle_outline_rounded,
    activeIcon: Icons.add_circle_rounded,
    label: 'Додати',
    tooltip: 'Додати запис',
    isCenterAction: true,
  ),
  const AppNavItem(
    icon: Icons.emoji_events_outlined,
    activeIcon: Icons.emoji_events_rounded,
    label: 'Гейміфікація',
    tooltip: 'Виклики та досягнення',
    badgeCount: 5,
    hasUnread: true,
  ),
  const AppNavItem(
    icon: Icons.settings_outlined,
    activeIcon: Icons.settings_rounded,
    label: 'Налаштування',
    tooltip: 'Налаштування профілю',
  ),
];

// ═══════════════════════════════════════════════════════════════════════
// Навігаційні конфігурації (Navigation Configurations)
// ═══════════════════════════════════════════════════════════════════════

/// Конфігурація для нижньої навігаційної панелі.
///
/// Об'єднує всі налаштування в один об'єкт для зручного управління.
/// Дозволяє передавати готові конфігурації між екранами.
class NavConfig {
  /// Створює конфігурацію з усіма параметрами.
  const NavConfig({
    this.currentIndex = 0,
    this.isLightTheme = false,
    this.enableHaptic = true,
    this.showActiveIndicator = true,
    this.showBorder = true,
    this.enableAnimation = true,
    this.enablePressEffect = true,
    this.enableBlurBackground = false,
    this.activeIndicatorType = ActiveIndicatorType.bar,
    this.height = 64.0,
    this.iconSize = 24.0,
    this.activeIconSize = 26.0,
    this.blurSigma = 10.0,
    this.centerActionSize = 48.0,
  });

  /// Поточний індекс вкладки.
  final int currentIndex;

  /// Світла тема.
  final bool isLightTheme;

  /// Тактильний відгук.
  final bool enableHaptic;

  /// Показувати індикатор активності.
  final bool showActiveIndicator;

  /// Показувати верхню межу.
  final bool showBorder;

  /// Увімкнути анімації.
  final bool enableAnimation;

  /// Увімкнути ефект натискання.
  final bool enablePressEffect;

  /// Увімкнути blur-фон.
  final bool enableBlurBackground;

  /// Тип індикатора.
  final ActiveIndicatorType activeIndicatorType;

  /// Висота панелі.
  final double height;

  /// Розмір неактивної іконки.
  final double iconSize;

  /// Розмір активної іконки.
  final double activeIconSize;

  /// Інтенсивність blur.
  final double blurSigma;

  /// Розмір центральної кнопки.
  final double centerActionSize;

  /// Створює копію конфігурації з перевизначенням.
  NavConfig copyWith({
    int? currentIndex,
    bool? isLightTheme,
    bool? enableHaptic,
    bool? showActiveIndicator,
    bool? showBorder,
    bool? enableAnimation,
    bool? enablePressEffect,
    bool? enableBlurBackground,
    ActiveIndicatorType? activeIndicatorType,
    double? height,
    double? iconSize,
    double? activeIconSize,
    double? blurSigma,
    double? centerActionSize,
  }) {
    return NavConfig(
      currentIndex: currentIndex ?? this.currentIndex,
      isLightTheme: isLightTheme ?? this.isLightTheme,
      enableHaptic: enableHaptic ?? this.enableHaptic,
      showActiveIndicator: showActiveIndicator ?? this.showActiveIndicator,
      showBorder: showBorder ?? this.showBorder,
      enableAnimation: enableAnimation ?? this.enableAnimation,
      enablePressEffect: enablePressEffect ?? this.enablePressEffect,
      enableBlurBackground: enableBlurBackground ?? this.enableBlurBackground,
      activeIndicatorType: activeIndicatorType ?? this.activeIndicatorType,
      height: height ?? this.height,
      iconSize: iconSize ?? this.iconSize,
      activeIconSize: activeIconSize ?? this.activeIconSize,
      blurSigma: blurSigma ?? this.blurSigma,
      centerActionSize: centerActionSize ?? this.centerActionSize,
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════
// Тип індикатора ───────────────────────────────────────────────────────
// ═══════════════════════════════════════════════════════════════════════

/// Тип індикатора активної вкладки.
///
/// Використовується для налаштування візуального стилю індикатора.
enum ActiveIndicatorType {
  /// Горизонтальна смужка під іконкою.
  ///
  /// Стандартний варіант — довга смужка під активною іконкою.
  bar,

  /// Крапка під іконкою.
  ///
  /// Компактний варіант — маленька крапка під активною іконкою.
  dot,

  /// Фонова пляма за іконкою.
  ///
  /// Розширений варіант — напівпрозорий фон за активною іконкою.
  highlight,

  /// Без індикатора.
  ///
  /// Для мінімалістичних дизайнів.
  none,

  /// Пульсуюча крапка.
  ///
  /// Анімована крапка з пульс-ефектом.
  pulse,

  /// Градієнтна смужка.
  ///
  /// Смужка з градієнтом замість суцільного кольору.
  gradientBar,

  /// Двокрапсна лінія.
  ///
  /// Дві паралельні лінії зверху та знизу іконки.
  doubleLine;

  /// Українська назва типу індикатора.
  String get label {
    switch (this) {
      case ActiveIndicatorType.bar:
        return 'Смужка';
      case ActiveIndicatorType.dot:
        return 'Крапка';
      case ActiveIndicatorType.highlight:
        return 'Пляма';
      case ActiveIndicatorType.none:
        return 'Без';
      case ActiveIndicatorType.pulse:
        return 'Пульс';
      case ActiveIndicatorType.gradientBar:
        return 'Градієнт';
      case ActiveIndicatorType.doubleLine:
        return 'Двокрапсна';
    }
  }

  /// Повертає краткий опис для дебагу.
  String get description {
    switch (this) {
      case ActiveIndicatorType.bar:
        return 'Горизонтальна смужка під іконкою';
      case ActiveIndicatorType.dot:
        return 'Маленька крапка під іконкою';
      case ActiveIndicatorType.highlight:
        return 'Напівпрозорий фон за іконкою';
      case ActiveIndicatorType.none:
        return 'Без індикатора';
      case ActiveIndicatorType.pulse:
        return 'Пульсуюча крапка';
      case ActiveIndicatorType.gradientBar:
        return 'Смужка з градієнтом';
      case ActiveIndicatorType.doubleLine:
        return 'Двокрапсна лінія';
    }
  }
}

// ─── Navigation Logger ────────────────────────────────────────────────────

/// Логер для навігаційної панелі.
///
/// Забезпечує структурований логування подій навігації.
class NavLogger {
  NavLogger._();

  /// Увімкнути логування (тільки в debug режимі).
  static bool enableLogging = false;

  /// Логування зміни вкладки.
  static void tabChanged(int fromIndex, int toIndex, String label) {
    if (!enableLogging) return;
    developer.log(
      '🔄 [Nav] Вкладка змінена: $fromIndex → $toIndex ($label)',
      name: 'AppBottomNav',
    );
  }

  /// Логування натискання.
  static void tap(int index, String label, {bool isCenterAction = false}) {
    if (!enableLogging) return;
    developer.log(
      '👆 [Nav] Натискання на вкладку $index ($label)${isCenterAction ? ' [CENTER]' : ''}',
      name: 'AppBottomNav',
    );
  }

  /// Логування тактильного відгуку.
  static void haptic(String type) {
    if (!enableLogging) return;
    developer.log(
      '📳 [Nav] Тактильний відгук: $type',
      name: 'AppBottomNav',
    );
  }

  /// Логування помилки.
  static void error(String message, [Object? error]) {
    developer.log(
      '❌ [Nav] Помилка: $message',
      name: 'AppBottomNav',
      error: error,
    );
  }
}

// ─── Navigation Analytics ────────────────────────────────────────────

/// Аналітика використання навігації.
///
/// Збирає статистику про взаємодії з навігаційною панеллю.
class NavAnalytics {
  NavAnalytics._();

  static final NavAnalytics instance = NavAnalytics._();

  /// Карта: вкладка → кількість натискань.
  final Map<int, int> _tapCounts = {};

  /// Загальна кількість натискань.
  int _totalTaps = 0;

  /// Час останньої активної дії.
  DateTime? _lastActiveTime;

  /// Реєструє натискання на вкладку.
  void registerTap(int index) {
    _tapCounts[index] = (_tapCounts[index] ?? 0) + 1;
    _totalTaps++;
    _lastActiveTime = DateTime.now();
  }

  /// Повертає кількість натискань на вкладку.
  int getTapCount(int index) => _tapCounts[index] ?? 0;

  /// Повертає список найбільш використовуваних вкладок.
  List<int> get mostUsedTabs {
    final sorted = _tapCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sorted.take(3).map((e) => e.key).toList();
  }

  /// Повертає загальну кількість натискань.
  int get totalTaps => _totalTaps;

  /// Повертає час останньої активної дії (null якщо немає).
  DateTime? get lastActiveTime => _lastActiveTime;

  /// Повертає найменш використовувану вкладку.
  int? get leastUsedTab {
    if (_tapCounts.isEmpty) return null;
    int minKey = _tapCounts.keys.first;
    for (final key in _tapCounts.keys) {
      if ((_tapCounts[key] ?? 0) < (_tapCounts[minKey] ?? 0)) {
        minKey = key;
      }
    }
    return minKey;
  }

  /// Скидає всю статистику.
  void reset() {
    _tapCounts.clear();
    _totalTaps = 0;
    _lastActiveTime = null;
  }

  /// Повертає текстовий звіт для дебагу.
  String generateReport() {
    final buffer = StringBuffer();
    buffer.writeln('📊 Звіт навігації:');
    buffer.writeln('  Загальна кількість натискань: $_totalTaps');
    buffer.writeln('  Остання активність: ${_lastActiveTime ?? "ніколи"}');
    if (_tapCounts.isNotEmpty) {
      buffer.writeln('  Натискання по вкладках:');
      for (final entry in _tapCounts.entries) {
        buffer.writeln(
            '    Вкладка ${entry.key}: ${entry.value} натискань');
      }
    }
    return buffer.toString();
  }
}

// ═══════════════════════════════════════════════════════════════════════
// Нижня навігаційна панель (Bottom Navigation Widget)
// ═══════════════════════════════════════════════════════════════════════

/// Нижня навігаційна панель з 5 вкладками, бейджами, анімаціями.
///
/// Включає: активний стан з анімацією іконки, лічильник бейджів,
/// кастомні кольори, індикатор непрочитого, тактильний відгук,
/// адаптивну форму, blur-фон, ефекти натискання, анімовані
/// переходи міток, центральну кнопку дії та адаптивні елементи.
///
/// Приклад використання:
/// ```dart
/// AppBottomNav(
///   currentIndex: _selectedIndex,
///   onTabChanged: (index) => setState(() => _selectedIndex = index),
/// )
/// ```
class AppBottomNav extends StatefulWidget {
  const AppBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTabChanged,
    this.isLightTheme = false,
    this.items = defaultNavItems,
    this.enableHaptic = true,
    this.showActiveIndicator = true,
    this.customNavColor,
    this.customActiveColor,
    this.customInactiveColor,
    this.height = 64.0,
    this.iconSize = 24.0,
    this.activeIconSize = 26.0,
    this.onCenterTap,
    this.showBorder = true,
    this.enableAnimation = true,
    this.enableBlurBackground = false,
    this.blurSigma = 10.0,
    this.enablePressEffect = true,
    this.activeIndicatorType = ActiveIndicatorType.bar,
    this.centerActionSize = 48.0,
    this.centerActionColor,
    this.navConfig,
  });

  /// Індекс поточної активної вкладки.
  final int currentIndex;

  /// Зворотний виклик при зміні вкладки.
  ///
  /// [index] — індекс нової вкладки (0-based).
  final ValueChanged<int> onTabChanged;

  /// Світла тема (Monitor замість PS5).
  final bool isLightTheme;

  /// Список елементів навігації.
  final List<AppNavItem> items;

  /// Тактильний відгук при зміні вкладки (HapticFeedback).
  final bool enableHaptic;

  /// Показувати індикатор активної вкладки (пляма під іконкою).
  final bool showActiveIndicator;

  /// Кастомний колір фону навігаційної панелі.
  final Color? customNavColor;

  /// Кастомний колір активного елементу.
  final Color? customActiveColor;

  /// Кастомний колір неактивного елементу.
  final Color? customInactiveColor;

  /// Висота навігаційної панелі в пікселях.
  final double height;

  /// Розмір неактивної іконки в пікселях.
  final double iconSize;

  /// Розмір активної іконки в пікселях.
  final double activeIconSize;

  /// Зворотний виклик для центральної кнопки (опціонально).
  ///
  /// Дозволяє відрізнити натискання на центральну вкладку.
  final VoidCallback? onCenterTap;

  /// Показувати верхню межу навігації.
  final bool showBorder;

  /// Увімкнути анімації переходів.
  final bool enableAnimation;

  /// Увімкнути blur-фон (матовий фон).
  final bool enableBlurBackground;

  /// Інтенсивність blur-ефекту (sigma).
  final double blurSigma;

  /// Увімкнути ефект натискання (scale down).
  final bool enablePressEffect;

  /// Тип індикатора активної вкладки.
  final ActiveIndicatorType activeIndicatorType;

  /// Розмір центральної кнопки дії.
  final double centerActionSize;

  /// Кастомний колір центральної кнопки дії.
  final Color? centerActionColor;

  /// Кастомна конфігурація (перевизначає окремі параметри).
  final NavConfig? navConfig;

  /// Створює AppBottomNav з конфігурації.
  factory AppBottomNav.fromConfig({
    required int currentIndex,
    required ValueChanged<int> onTabChanged,
    NavConfig? config,
    List<AppNavItem>? items,
    VoidCallback? onCenterTap,
  }) {
    return AppBottomNav(
      currentIndex: currentIndex,
      onTabChanged: onTabChanged,
      items: items ?? defaultNavItems,
      isLightTheme: config?.isLightTheme ?? false,
      enableHaptic: config?.enableHaptic ?? true,
      showActiveIndicator: config?.showActiveIndicator ?? true,
      showBorder: config?.showBorder ?? true,
      enableAnimation: config?.enableAnimation ?? true,
      enablePressEffect: config?.enablePressEffect ?? true,
      enableBlurBackground: config?.enableBlurBackground ?? false,
      blurSigma: config?.blurSigma ?? 10.0,
      activeIndicatorType: config?.activeIndicatorType ?? ActiveIndicatorType.bar,
      height: config?.height ?? 64.0,
      iconSize: config?.iconSize ?? 24.0,
      activeIconSize: config?.activeIconSize ?? 26.0,
      centerActionSize: config?.centerActionSize ?? 48.0,
      onCenterTap: onCenterTap,
    );
  }

  @override
  State<AppBottomNav> createState() => _AppBottomNavState();
}

class _AppBottomNavState extends State<AppBottomNav> {
  /// Попередній індекс активної вкладки.
  int _previousIndex = 0;

  /// Контролери анімацій для кожного елемента.
  final List<AnimationController> _itemControllers = [];

  /// Індекс елемента, що натискається (для press-ефекту).
  int? _pressedIndex;

  /// Індекс елемента, що отримав фокус (для hover-ефекту).
  int? _hoveredIndex;

  /// Контролер анімації для появи панелі.
  AnimationController? _appearController;

  /// Чи панель завершує анімацію появи.
  bool _hasAppeared = false;

  /// Аналітика навігації.
  final NavAnalytics _analytics = NavAnalytics.instance;

  // ═══════════════════════════════════════════════════════════
  // Гетери кольорів (Color Getters)
  // ═══════════════════════════════════════════════════════════

  /// Кастомна конфігурація або null.
  NavConfig get _config => widget.navConfig;

  /// Колір фону навігаційної панелі.
  Color get _bgColor =>
      widget.customNavColor ??
      (widget.isLightTheme
          ? AppColorsMonitor.navBackground
          : AppColorsPS5.navBackground);

  /// Колір активної вкладки.
  Color get _activeColor =>
      widget.customActiveColor ??
      (widget.isLightTheme
          ? AppColorsMonitor.navActive
          : AppColorsPS5.navActive);

  /// Колір неактивної вкладки.
  Color get _inactiveColor =>
      widget.customInactiveColor ??
      (widget.isLightTheme
          ? AppColorsMonitor.navInactive
          : AppColorsPS5.navInactive);

  /// Колір верхньої межі.
  Color get _borderColor =>
      widget.isLightTheme ? AppColorsMonitor.border : AppColorsPS5.border;

  /// Колір бейджу (червоний).
  Color get _errorColor => AppColorsPS5.error;

  /// Колір індикатора непрочитого.
  Color get _unreadColor => AppColorsPS5.accent;

  /// Колір центральної кнопки дії.
  Color get _centerColor =>
      widget.centerActionColor ??
      (widget.isLightTheme
          ? AppColorsMonitor.accent
          : AppPS5.accent);

  /// Колір для tooltip'у.
  Color get _tooltipColor =>
      widget.isLightTheme
          ? AppColorsMonitor.textSecondary
          : AppColorsPS5.textSecondary;

  /// Фонова панель.
  Color get _panelColor =>
      widget.customNavColor ??
      (widget.isLightTheme
          ? AppColorsMonitor.card
          : AppColorsPS5.card);

  // ═══════════════════════════════════════════════════════════
  // Життєвий цикл (Lifecycle)
  // ═══════════════════════════════════════════════════════════

  @override
  void initState() {
    super.initState();
    _previousIndex = widget.currentIndex;
    _setupAppearAnimation();
  }

  @override
  void didUpdateWidget(covariant AppBottomNav oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Оновлюємо попередній індекс
    if (widget.currentIndex != _previousIndex) {
      _previousIndex = widget.currentIndex;
    }

    // Оновлюємо анімацію появи
    if (widget.height != oldWidget.height ||
        widget.items.length != oldWidget.items.length) {
      _setupAppearAnimation();
    }

    // Логування зміни конфігурації
    if (widget.isLightTheme != oldWidget.isLightTheme) {
      NavLogger.log('Тема змінена: ${widget.isLightTheme ? 'світла' : 'темна'}');
    }
  }

  @override
  void dispose() {
    for (final controller in _itemControllers) {
      controller.dispose();
    }
    _itemControllers.clear();
    _appearController?.dispose();
    super.dispose();
  }

  /// Ініціалізує анімацію появи панелі.
  void _setupAppearAnimation() {
    _appearController?.dispose();
    _hasAppeared = false;

    try {
      _appearController = AnimationController(
        vsync: this,
        duration: AppDurations.medium,
        value: 0.0,
      );

      _appearController!.forward().then((_) {
        if (mounted) {
          setState(() => _hasAppeared = true);
        }
      });
    } catch (e, st) {
      NavLogger.error('Помилка ініціалізації анімації', st);
    }
  }

  // ═══════════════════════════════════════════════════════════
  // Обробник зміни вкладки (Tab Change Handler)
  // ═══════════════════════════════════════════════════════════

  /// Обробляє натискання на вкладку навігації.
  ///
  /// Включає тактильний відгук та виклик callback.
  void _handleTabChange(int index) {
    // Перевірка межів
    if (index < 0 || index >= widget.items.length) {
      NavLogger.error('Недійсний індекс вкладки: $index');
      return;
    }

    final item = widget.items[index];

    // Перевірка доступності
    if (!item.isEnabled) {
      NavLogger.log('Вкладка ${item.label} недоступна');
      return;
    }

    // Тактильний відгук при зміні вкладки
    if (widget.enableHaptic && index != widget.currentIndex) {
      try {
        HapticFeedback.selectionClick();
        NavLogger.haptic('selectionClick');
      } catch (e) {
        NavLogger.error('Помилка тактильного відгуку', e);
      }
    }

    // Аналітика
    _analytics.registerTap(index);

    // Центрально-кнопка callback (якщо визначено)
    if (widget.onCenterTap != null && item.isCenterAction) {
      try {
        widget.onCenterTap!();
      } catch (e, st) {
        NavLogger.error('Помилка в onCenterTap', st);
      }
    }

    // Логування
    NavLogger.tabChanged(widget.currentIndex, index, item.label);

    // Виклик основного callback
    try {
      widget.onTabChanged(index);
    } catch (e, st) {
      NavLogger.error('Помилка в onTabChanged', st);
    }
  }

  // ═══════════════════════════════════════════════════════════
  // Обробка довгого натискання (Long Press Handler)
  // ═══════════════════════════════════════════════════════════

  /// Обробляє довге натискання на вкладку.
  ///
  /// Показує tooltip або виклика callback.
  void _handleLongPress(int index) {
    if (index < 0 || index >= widget.items.length) return;
    final item = widget.items[index];

    if (item.tooltip != null) {
      _showTooltip(item.tooltip!);
    }
  }

  /// Показує tooltip над панеллю.
  void _showTooltip(String message) {
    try {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: AppTypography.bodySmall.copyWith(
              color: _tooltipColor,
            ),
          ),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Radii.md),
          ),
          margin: EdgeInsets.only(
            bottom: widget.height + 8,
            left: 16,
            right: 16,
          ),
        ),
      );
    } catch (e, st) {
      NavLogger.error('Помилка показу tooltip', st);
    }
  }

  // ═══════════════════════════════════════════════════════════
  // Обробка натискання на бейдж (Badge Tap Handler)
  // ═══════════════════════════════════════════════════════════

  /// Обробляє натискання на бейдж.
  ///
  /// Показує інформацію про кількість сповіщень.
  void _handleBadgeTap(int index) {
    if (index < 0 || index >= widget.items.length) return;
    final item = widget.items[index];
    if (item.badgeCount != null || item.badgeCount! <= 0) return;

    try {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${item.badgeCount} непрочитаних сповіщень у вкладці "${item.label}"',
            style: AppTypography.bodySmall.copyWith(
              color: _tooltipColor,
            ),
          ),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e, st) {
      NavLogger.error('Помилка обробки натискання на бейдж', st);
    }
  }

  // ═══════════════════════════════════════════════════════════
  // Побудова (Build)
  // ═══════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    try {
      return _buildContent(context);
    } catch (e, st) {
      NavLogger.error('Помилка побудови панелі', st);
      return _buildErrorFallback();
    }
  }

  /// Основна логіка побудови.
  Widget _buildContent(BuildContext context) {
    Widget nav = Container(
      height: widget.height,
      decoration: BoxDecoration(
        color: widget.enableBlurBackground
            ? _bgColor.withOpacity(0.85)
            : _bgColor,
        border: widget.showBorder
            ? Border(
                top: BorderSide(
                  color: _borderColor,
                  width: 0.5,
                ),
              )
            : null,
      ),
      child: SafeArea(
        top: false,
        child: _buildItemsRow(),
      ),
    );

    // Blur-ефект фону
    if (widget.enableBlurBackground) {
      nav = ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: widget.blurSigma,
            sigmaY: widget.blurSigma,
          ),
          child: nav,
        ),
      );
    }

    // Анімація появи
    if (_appearController != null) return nav;

    return AnimatedBuilder(
      animation: _appearController!,
      builder: (context, child) {
        final progress = CurvedAnimation(
          parent: _appearController!,
          curve: Curves.easeOutCubic,
        ).value;

        return AnimatedOpacity(
          opacity: progress,
          duration: Duration.zero,
          child: AnimatedScale(
            scale: progress,
            duration: Duration.zero,
            curve: Curves.easeOutBack,
            alignment: Alignment.topCenter,
            child: AnimatedSlide(
              offset: Offset(0, progress * 0.3),
              duration: Duration.zero,
              child: child,
            ),
          ),
        );
      },
    );
  }

  /// Будує ряд елементів навігації.
  Widget _buildItemsRow() {
    return Row(
      children: List.generate(
        widget.items.length,
        (index) => _buildNavItem(index),
      ),
    );
  }

  /// Будує панель у стані помилки.
  Widget _buildErrorFallback() {
    return Container(
      height: widget.height,
      color: _bgColor,
      child: const Center(
        child: Icon(
          Icons.error_outline,
          color: AppColorsPS5.error,
          size: 24,
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // Побудова елемента навігації (Nav Item Build)
  // ═══════════════════════════════════════════════════════════

  /// Будує один елемент навігаційної панелі.
  ///
  /// Кожен елемент має: іконку з бейджем, індикатор, текстову мітку.
  /// Центральна кнопка має особливий стиль.
  Widget _buildNavItem(int index) {
    final item = widget.items[index];
    final isActive = index == widget.currentIndex;
    final effectiveActiveColor = item.customActiveColor ?? _activeColor;
    final isDisabled = !item.isEnabled;
    final isPressed = _pressedIndex == index;
    final isHovered = _hoveredIndex == index;

    // Центральна кнопка дії — особливий стиль
    if (item.isCenterAction) {
      return _buildCenterActionButton(item, index);
    }

    // Вимкнення семантики
    return Semantics(
      button: true,
      label: item.accessibilityLabel,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: widget.enablePressEffect
            ? (_) => setState(() => _pressedIndex = index)
            : null,
        onTapUp: widget.enablePressEffect
            ? (_) => setState(() => _pressedIndex = null)
            : null,
        onTapCancel: widget.enablePressEffect
            ? () => setState(() => _pressedIndex = null)
            : null,
        onLongPress: () => _handleLongPress(index),
        onHorizontalDragStart: (_) =>
            setState(() => _pressedIndex = index),
        onHorizontalDragEnd: (_) =>
            setState(() => _pressedIndex = null),
        onTap: isDisabled ? null : () => _handleTabChange(index),
        child: AnimatedScale(
          scale: isPressed ? 0.88 : 1.0,
          duration: const Duration(milliseconds: 100),
          curve: Curves.easeOutQuad,
          child: AnimatedOpacity(
            opacity: isDisabled ? 0.3 : 1.0,
            duration: const Duration(milliseconds: 200),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // ── Іконка з бейджем ──
                  _buildIconWithBadge(
                    item: item,
                    isActive: isActive,
                    activeColor: effectiveActiveColor,
                    isDisabled: isDisabled,
                  ),
                  const SizedBox(height: 2),
                  // ── Індикатор активної вкладки ──
                  if (widget.showActiveIndicator &&
                      widget.activeIndicatorType != ActiveIndicatorType.none) ...[
                    _buildActiveIndicator(isActive, effectiveActiveColor),
                    const SizedBox(height: 2),
                  ],
                  // ── Текстова мітка ──
                  AnimatedDefaultTextStyle(
                    duration: widget.enableAnimation
                        ? AppDurations.fast
                        : Duration.zero,
                    style: AppTypography.labelSmall.copyWith(
                      color: isDisabled
                          ? _inactiveColor.withOpacity(0.3)
                          : isActive
                              ? effectiveActiveColor
                              : _inactiveColor,
                      fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                      fontSize: isActive ? 11 : 10,
                    ),
                    child: Text(
                      item.label,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                  // ── Підзаголовок (якщо є) ──
                  if (item.subtitle != null) ...[
                    const SizedBox(height: 1),
                    Text(
                      item.subtitle!,
                      style: AppTypography.caption.copyWith(
                        color: isDisabled
                            ? _inactiveColor.withOpacity(0.25)
                            : _inactiveColor.withOpacity(0.6),
                        fontSize: 7,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // Центральна кнопка дії (Center Action Button)
  // ═══════════════════════════════════════════════════════════

  /// Будує центральну кнопку дії у стилі FAB.
  ///
  /// Має додаткову тінь, сяйво та пульс-ефект.
  Widget _buildCenterActionButton(AppNavItem item, int index) {
    final isPressed = _pressedIndex == index;

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: item.isEnabled ? () => _handleTabChange(index) : null,
              onTapDown: widget.enablePressEffect
                  ? (_) => setState(() => _pressedIndex = index)
                  : null,
              onTapUp: widget.enablePressEffect
                  ? (_) => setState(() => _pressedIndex = null)
                  : null,
              onTapCancel: widget.enablePressEffect
                  ? () => setState(() => _pressedIndex = null)
                  : null,
              child: AnimatedScale(
                scale: isPressed ? 0.9 : 1.0,
                duration: const Duration(milliseconds: 100),
                curve: Curves.easeOutQuad,
                child: Container(
                  width: widget.centerActionSize,
                  height: widget.centerActionSize,
                  decoration: BoxDecoration(
                    color: _centerColor,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: _centerColor.withOpacity(0.3),
                        blurRadius: 12,
                        spreadRadius: 2,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(
                    item.activeIcon,
                    color: Colors.white,
                    size: widget.iconSize + 4,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 2),
            AnimatedDefaultTextStyle(
              duration: widget.enableAnimation
                  ? AppDurations.fast
                  : Duration.zero,
              style: AppTypography.labelSmall.copyWith(
                color: _centerColor,
                fontWeight: FontWeight.w600,
                fontSize: 10,
              ),
              child: Text(
                item.label,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // Індикатор активності (Active Indicator)
  // ═════════════════════════════════════════════════════════

  /// Будує індикатор активної вкладки залежно від типу.
  Widget _buildActiveIndicator(bool isActive, Color activeColor) {
    final color = isActive ? activeColor : Colors.transparent;

    switch (widget.activeIndicatorType) {
      case ActiveIndicatorType.bar:
        return AnimatedContainer(
          duration: widget.enableAnimation
              ? AppDurations.fast
              : Duration.zero,
          width: isActive ? 16 : 0,
          height: 3,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(1.5),
          ),
        );

      case ActiveIndicatorType.dot:
        return AnimatedContainer(
          duration: widget.enableAnimation
              ? AppDurations.fast
              : Duration.zero,
          width: isActive ? 6 : 0,
          height: 6,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        );

      case ActiveIndicatorType.highlight:
        return AnimatedContainer(
          duration: widget.enableAnimation
              ? AppDurations.fast
              : Duration.zero,
          width: isActive ? 40 : 0,
          height: 28,
          decoration: BoxDecoration(
            color: isActive
                ? activeColor.withOpacity(0.1)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
          ),
        );

      case ActiveIndicatorType.pulse:
        return AnimatedContainer(
          duration: widget.enableAnimation
              ? AppDurations.pulse
              : Duration.zero,
          width: isActive ? 6 : 0,
          height: 6,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        );

      case ActiveIndicatorType.gradientBar:
        return AnimatedContainer(
          duration: widget.enableAnimation
              ? AppDurations.fast
              : Duration.zero,
          width: isActive ? 16 : 0,
          height: 3,
          decoration: BoxDecoration(
            gradient: isActive
                ? LinearGradient(
                    colors: [
                      activeColor,
                      activeColor.withOpacity(0.6),
                    ],
                  )
                : null,
            borderRadius: BorderRadius.circular(1.5),
          ),
        );

      case ActiveIndicatorType.doubleLine:
        return AnimatedContainer(
          duration: widget.enableAnimation
              ? AppDurations.fast
              : Duration.zero,
          width: isActive ? 16 : 0,
          height: 6,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 2,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
              const SizedBox(height: 2),
              Container(
                height: 2,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
            ],
          ),
        );

      case ActiveIndicatorType.none:
        return const SizedBox.shrink();
    }
  }

  // ═══════════════════════════════════════════════════════════
  // Іконка з бейджем (Icon with Badge)
  // ═══════════════════════════════════════════════════════════

  /// Будує іконку вкладки з бейджем та/або індикатором непрочитого.
  Widget _buildIconWithBadge({
    required AppNavItem item,
    required bool isActive,
    required Color activeColor,
    required bool isDisabled,
  }) {
    final iconSize = isActive ? widget.activeIconSize : widget.iconSize;
    final iconColor = isDisabled
        ? _inactiveColor.withOpacity(0.3)
        : isActive
            ? activeColor
            : _inactiveColor;

    return SizedBox(
      width: widget.activeIconSize + 12,
      height: widget.activeIconSize + 4,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // ── Основна іконка ──
          Center(
            child: AnimatedSwitcher(
              duration: widget.enableAnimation
                  ? AppDurations.fast
                  : Duration.zero,
              transitionBuilder: (child, animation) {
                return ScaleTransition(
                  scale: animation,
                  child: child,
                );
              },
              child: Icon(
                isActive ? item.activeIcon : item.icon,
                key: ValueKey('$isActive-${item.label}'),
                color: iconColor,
                size: iconSize,
              ),
            ),
          ),
          // ── Лічильник бейджів ──
          if (item.badgeCount != null &&
              item.badgeCount! > 0 &&
              item.showBadge) ...[
            _buildBadgeCounter(item.badgeCount!, item),
          ],
          // ── Індикатор непрочитаного ──
          if (item.hasUnread &&
              (item.badgeCount == null || item.badgeCount! <= 0)) ...[
            _buildUnreadDot(),
          ],
        ],
      ),
    );
  }

  /// Будує лічильник бейджів (червоне коло з числом).
  Widget _buildBadgeCounter(int count, [AppNavItem? item]) {
    final isLarge = count > 99;
    final displayText = isLarge ? '99+' : '$count';
    final badgeWidth = isLarge ? 28.0 : (count > 9 ? 22.0 : 18.0);

    return Positioned(
      top: -4,
      right: -6,
      child: GestureDetector(
        onTap: item != null ? () => _handleBadgeTap(
            widget.items.indexOf(item!),
          ) : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutBack,
          width: badgeWidth,
          height: 18,
          decoration: BoxDecoration(
            color: _errorColor,
            borderRadius: BorderRadius.circular(9),
            border: Border.all(
              color: _bgColor,
              width: 1.5,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            displayText,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 9,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  /// Будує індикатор непрочитаного (синя точка).
  Widget _buildUnreadDot() {
    return Positioned(
      top: 0,
      right: 2,
      child: Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(
          color: _unreadColor,
          shape: BoxShape.circle,
          border: Border.all(
            color: _bgColor,
            width: 1.5,
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // Семантичні мітки (Semantics)
  // ═══════════════════════════════════════════════════════════

  /// Семантична назва для вкладки (для доступності).
  static String tabSemanticsLabel(int index, String label) {
    return 'Вкладка $index: $label';
  }

  /// Повідомлення про перехід до нової вкладки.
  static String tabChangedMessage(String label) {
    return 'Відкрито: $label';
  }

  /// Повідомлення про центральну кнопку.
  static String get centerActionMessage => 'Натиснуто кнопку дії';

  /// Повертає повну інформацію про панель навігації.
  static String debugInfo({
    required int currentIndex,
    required int itemCount,
    required int? badgeTotal,
  }) {
    return 'Навігація: $itemCount вкладок, активна: $currentIndex, '
        'бейджів: ${badgeTotal ?? 0}';
  }

  /// Повертає кількість непрочитаних елементів.
  static int countBadges(List<AppNavItem> items) {
    return items.fold(0, (sum, item) {
      if (item.badgeCount != null && item.badgeCount! > 0) {
        return sum + item.badgeCount!;
      }
      if (item.hasUnread) return sum + 1;
      return sum;
    });
  }

  /// Повертає текст опису всіх вкладок.
  static String describeTabs(List<AppNavItem> items) {
    return items.map((item) => item.label).join(', ');
  }

  /// Повертає кількість вкладок, що мають непрочиті.
  static int countUnread(List<AppNavItem> items) {
    return items.where((item) => item.hasUnread).length;
  }

  /// Повертає список індексів вкладок з бейджами.
  static List<int> badgeIndices(List<AppNavItem> items) {
    return items
        .asMap()
        .entries
        .where((e) => e.value.badgeCount != null && e.value.badgeCount! > 0)
        .keys
        .toList();
  }

  /// Повертає загальну кількість бейджів.
  static int totalBadgeCount(List<AppNavItem> items) {
    return countBadges(items);
  }

  /// Перевіряє, чи вкладка з індексом є валідною.
  static bool isValidIndex(int index, int itemCount) {
    return index >= 0 && index < itemCount;
  }
}

// ─── Extension on Widget ──────────────────────────────────────────────────

/// Розширення для Widget для роботи з навігаційною панеллю.
extension AppBottomNavExtension on Widget {
  /// Обгортає віджет у панель навігації.
  Widget wrapWithNav({
    required int selectedIndex,
    required ValueChanged<int> onTabChanged,
    bool isLightTheme = false,
    List<AppNavItem>? items,
    VoidCallback? onCenterTap,
  }) {
    return AppBottomNav(
      currentIndex: selectedIndex,
      onTabChanged: onTabChanged,
      isLightTheme: isLightTheme,
      items: items ?? defaultNavItems,
      onCenterTap: onCenterTap,
    );
  }
}

// ─── Extension on List<AppNavItem> ──────────────────────────────────────

/// Розширення для списку навігаційних елементів.
extension AppNavItemListExtension on List<AppNavItem> {
  /// Поверта кількість вкладок з бейджами.
  int get badgeCount => where(
    (item) => (item.badgeCount ?? 0) > 0 && item.showBadge,
  ).length;

  /// Поверта кількість вкладок з непрочитими.
  int get unreadCount => where(
    (item) => item.hasUnread,
  ).length;

  /// Поверта список непрочитих вкладок.
  List<AppNavItem> get unreadItems => where(
    (item) => item.hasUnread,
  );

  /// Поверта список вкладок з найбільшим бейджем.
  List<AppNavItem> sortedByBadge() {
    final sorted = [...this]
      ..sort((a, b) =>
          (b.badgeCount ?? 0).compareTo(a.badgeCount ?? 0));
    return sorted;
  }

  /// Поверта true, якщо хоча бейдж-вкладка існує.
  bool get hasBadge => badgeCount > 0;

  /// Поверта true, якщо хоча вкладка має непрочиті.
  bool get hasUnread => unreadCount > 0;

  /// Поверта індекси вкладок з найбільшими бейджами.
  List<int> topBadgeIndices({int max = 3}) {
    return sortedByBadge()
        .take(max)
        .map((item) => indexOf(item))
        .toList();
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Конфігурація навігаційної панелі (Nav Configuration)
// ═══════════════════════════════════════════════════════════════════════════════════════

/// Розширена конфігурація для нижньої навігаційної панелі.
///
/// Об'єднує всі налаштування в один об'єкт для зручного управління.
///
/// Приклад створення:
/// ```dart
/// final config = NavExtendedConfig(
///   currentIndex: 0,
///   isLightTheme: true,
///   activeIndicatorType: ActiveIndicatorType.dot,
///   enableBlurBackground: true,
/// );
/// ```
class NavExtendedConfig {
  /// Створює розширену конфігурацію з усіма параметрами.
  const NavExtendedConfig({
    this.currentIndex = 0,
    this.isLightTheme = false,
    this.enableHaptic = true,
    this.showActiveIndicator = true,
    this.showBorder = true,
    this.enableAnimation = true,
    this.enablePressEffect = true,
    this.enableBlurBackground = false,
    this.activeIndicatorType = ActiveIndicatorType.bar,
    this.height = 64.0,
    this.iconSize = 24.0,
    this.activeIconSize = 26.0,
    this.blurSigma = 10.0,
    this.centerActionSize = 48.0,
    this.maxItems = 7,
    this.minItems = 2,
    this.badgeOverflowText = '99+',
    this.animationCurve = Curves.easeOutCubic,
    this.pressScale = 0.9,
    this.enableTooltips = true,
    this.enableLongPress = true,
  });

  /// Поточний індекс вкладки.
  final int currentIndex;

  /// Світла тема.
  final bool isLightTheme;

  /// Тактильний відгук.
  final bool enableHaptic;

  /// Показувати індикатор активності.
  final bool showActiveIndicator;

  /// Показувати верхню межу.
  final bool showBorder;

  /// Увімкнути анімації.
  final bool enableAnimation;

  /// Увімкнути ефект натискання.
  final bool enablePressEffect;

  /// Увімкнути blur-фон.
  final bool enableBlurBackground;

  /// Тип індикатора.
  final ActiveIndicatorType activeIndicatorType;

  /// Висота панелі.
  final double height;

  /// Розмір неактивної іконки.
  final double iconSize;

  /// Розмір активної іконки.
  final double activeIconSize;

  /// Інтенсивність blur.
  final double blurSigma;

  /// Розмір центральної кнопки.
  final double centerActionSize;

  /// Максимальна кількість елементів.
  final int maxItems;

  /// Мінімальна кількість елементів.
  final int minItems;

  /// Текст для бейджів що перевищують ліміт.
  final String badgeOverflowText;

  /// Крива анімації.
  final Curve animationCurve;

  /// Множник масштабу при натисканні.
  final double pressScale;

  /// Показувати tooltips при довгому натисканні.
  final bool enableTooltips;

  /// Дозволити довге натискання.
  final bool enableLongPress;

  /// Створює копію з перевизначенням.
  NavExtendedConfig copyWith({
    int? currentIndex,
    bool? isLightTheme,
    bool? enableHaptic,
    bool? showActiveIndicator,
    bool? showBorder,
    bool? enableAnimation,
    bool? enablePressEffect,
    bool? enableBlurBackground,
    ActiveIndicatorType? activeIndicatorType,
    double? height,
    double? iconSize,
    double? activeIconSize,
    double? blurSigma,
    double? centerActionSize,
    int? maxItems,
    int? minItems,
    String? badgeOverflowText,
    Curve? animationCurve,
    double? pressScale,
    bool? enableTooltips,
    bool? enableLongPress,
  }) {
    return NavExtendedConfig(
      currentIndex: currentIndex ?? this.currentIndex,
      isLightTheme: isLightTheme ?? this.isLightTheme,
      enableHaptic: enableHaptic ?? this.enableHaptic,
      showActiveIndicator: showActiveIndicator ?? this.showActiveIndicator,
      showBorder: showBorder ?? this.showBorder,
      enableAnimation: enableAnimation ?? this.enableAnimation,
      enablePressEffect: enablePressEffect ?? this.enablePressEffect,
      enableBlurBackground: enableBlurBackground ?? this.enableBlurBackground,
      activeIndicatorType: activeIndicatorType ?? this.activeIndicatorType,
      height: height ?? this.height,
      iconSize: iconSize ?? this.iconSize,
      activeIconSize: activeIconSize ?? this.activeIconSize,
      blurSigma: blurSigma ?? this.blurSigma,
      centerActionSize: centerActionSize ?? this.centerActionSize,
      maxItems: maxItems ?? this.maxItems,
      minItems: minItems ?? this.minItems,
      badgeOverflowText: badgeOverflowText ?? this.badgeOverflowText,
      animationCurve: animationCurve ?? this.animationCurve,
      pressScale: pressScale ?? this.pressScale,
      enableTooltips: enableTooltips ?? this.enableTooltips,
      enableLongPress: enableLongPress ?? this.enableLongPress,
    );
  }

  /// Перетворює в стандартну [NavConfig].
  NavConfig toNavConfig() {
    return NavConfig(
      currentIndex: currentIndex,
      isLightTheme: isLightTheme,
      enableHaptic: enableHaptic,
      showActiveIndicator: showActiveIndicator,
      showBorder: showBorder,
      enableAnimation: enableAnimation,
      enablePressEffect: enablePressEffect,
      enableBlurBackground: enableBlurBackground,
      activeIndicatorType: activeIndicatorType,
      height: height,
      iconSize: iconSize,
      activeIconSize: activeIconSize,
      blurSigma: blurSigma,
      centerActionSize: centerActionSize,
    );
  }

  /// Чи конфігурація включає blur-фон.
  bool get hasBlur => enableBlurBackground;

  /// Чи конфігурація включає всі ефекти.
  bool get isFullEffects =>
      enableHaptic &&
      showActiveIndicator &&
      enableAnimation &&
      enablePressEffect;

  /// Чи конфігурація мінімалістична.
  bool get isMinimal =>
      !enableAnimation && !enablePressEffect && !showActiveIndicator;
}

// ═══════════════════════════════════════════════════════════════════════════
// Предвизначені конфігурації (Preset Configurations)
// ═══════════════════════════════════════════════════════════════════════════

/// Передвизначені конфігурації для навігаційної панелі.
///
/// Дозволяє швидко обрати потрібний стиль відображення.
class NavExtendedConfigs {
  NavExtendedConfigs._();

  /// Стандартна конфігурація для темної теми PS5.
  static const NavExtendedConfig ps5 = NavExtendedConfig(
    isLightTheme: false,
    activeIndicatorType: ActiveIndicatorType.bar,
    enableAnimation: true,
    enablePressEffect: true,
    enableHaptic: true,
  );

  /// Стандартна конфігурація для світлої теми Monitor.
  static const NavExtendedConfig monitor = NavExtendedConfig(
    isLightTheme: true,
    activeIndicatorType: ActiveIndicatorType.bar,
    enableAnimation: true,
    enablePressEffect: true,
    enableHaptic: true,
  );

  /// Конфігурація з blur-фоном (для прозорої навігації).
  static const NavExtendedConfig blurred = NavExtendedConfig(
    enableBlurBackground: true,
    blurSigma: 12.0,
  );

  /// Конфігурація з пульсуючим індикатором.
  static const NavExtendedConfig pulseIndicator = NavExtendedConfig(
    activeIndicatorType: ActiveIndicatorType.pulse,
  );

  /// Конфігура з градієнтним індикатором.
  static const NavExtendedConfig gradientBar = NavExtendedConfig(
    activeIndicatorType: ActiveIndicatorType.gradientBar,
  );

  /// Конфігура з двокрапсним індикатором.
  static const NavExtendedConfig doubleLine = NavExtendedConfig(
    activeIndicatorType: ActiveIndicatorType.doubleLine,
  );

  /// Конфігура без індикатора (мінімалістичний).
  static const NavExtendedConfig noIndicator = NavExtendedConfig(
    showActiveIndicator: false,
  );

  /// Конфігура без анімацій (для економії заряду).
  static const NavExtendedConfig noAnimation = NavExtendedConfig(
    enableAnimation: false,
    enablePressEffect: false,
  );

  /// Конфігура з точкою-індикатором.
  static const NavExtendedConfig dotIndicator = NavExtendedConfig(
    activeIndicatorType: ActiveIndicatorType.dot,
  );

  /// Конфігура з фонова плямою.
  static const NavExtendedConfig highlightIndicator = NavExtendedConfig(
    activeIndicatorType: ActiveIndicatorType.highlight,
  );

  /// Мінімалістична конфігура (без зайвих ефектів).
  static const NavExtendedConfig minimal = NavExtendedConfig(
    enableAnimation: false,
    enablePressEffect: false,
    showActiveIndicator: false,
    showBorder: false,
  );
}

// ═══════════════════════════════════════════════════════════════════════════
// Розширення для ActiveIndicatorType (Indicator Extensions)
// ═══════════════════════════════════════════════════════════════════════════

/// Розширення для [ActiveIndicatorType] з додатковими властивостями.
extension ActiveIndicatorTypeExtension on ActiveIndicatorType {
  /// Чи тип має анімацію.
  bool get isAnimated =>
      this == ActiveIndicatorType.pulse ||
      this == ActiveIndicatorType.gradientBar;

  /// Чи тип є градієнтним.
  bool get isGradient => this == ActiveIndicatorType.gradientBar;

  /// Чи тип використовує крапки.
  bool get isDotBased =>
      this == ActiveIndicatorType.dot || this == ActiveIndicatorType.pulse;

  /// Чи тип використовує лінії.
  bool get isLineBased =>
      this == ActiveIndicatorType.bar || this == ActiveIndicatorType.doubleLine;

  /// Повертає ширину індикатора в пікселях.
  double indicatorWidth() {
    switch (this) {
      case ActiveIndicatorType.bar:
        return 24.0;
      case ActiveIndicatorType.dot:
        return 6.0;
      case ActiveIndicatorType.highlight:
        return 48.0;
      case ActiveIndicatorType.none:
        return 0.0;
      case ActiveIndicatorType.pulse:
        return 8.0;
      case ActiveIndicatorType.gradientBar:
        return 24.0;
      case ActiveIndicatorType.doubleLine:
        return 24.0;
    }
  }

  /// Повертає висоту індикатора в пікселях.
  double indicatorHeight() {
    switch (this) {
      case ActiveIndicatorType.bar:
        return 3.0;
      case ActiveIndicatorType.dot:
        return 6.0;
      case ActiveIndicatorType.highlight:
        return 32.0;
      case ActiveIndicatorType.none:
        return 0.0;
      case ActiveIndicatorType.pulse:
        return 6.0;
      case ActiveIndicatorType.gradientBar:
        return 3.0;
      case ActiveIndicatorType.doubleLine:
        return 3.0;
    }
  }

  /// Повертає відступ індикатора від іконки.
  double bottomOffset() {
    switch (this) {
      case ActiveIndicatorType.bar:
        return 4.0;
      case ActiveIndicatorType.dot:
        return 4.0;
      case ActiveIndicatorType.highlight:
        return 0.0;
      case ActiveIndicatorType.none:
        return 0.0;
      case ActiveIndicatorType.pulse:
        return 4.0;
      case ActiveIndicatorType.gradientBar:
        return 4.0;
      case ActiveIndicatorType.doubleLine:
        return 2.0;
    }
  }

  /// Повертає радіус кутів індикатора.
  double indicatorRadius() {
    switch (this) {
      case ActiveIndicatorType.bar:
        return 1.5;
      case ActiveIndicatorType.dot:
        return 3.0;
      case ActiveIndicatorType.highlight:
        return Radii.base;
      case ActiveIndicatorType.none:
        return 0.0;
      case ActiveIndicatorType.pulse:
        return 3.0;
      case ActiveIndicatorType.gradientBar:
        return 1.5;
      case ActiveIndicatorType.doubleLine:
        return 1.5;
    }
  }

  /// Створює BoxDecoration для індикатора.
  BoxDecoration indicatorDecoration(Color color) {
    if (this == ActiveIndicatorType.none) {
      return const BoxDecoration();
    }
    if (this == ActiveIndicatorType.highlight) {
      return BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(indicatorRadius()),
      );
    }
    return BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(indicatorRadius()),
    );
  }

  /// Перевіряє чи індикатор сумісний з напрямком.
  bool isCompatibleWith(ActiveIndicatorType other) {
    return this == other;
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Валідація (Validation)
// ═════════════════════════════════════════════════════════════════════════

/// Валідатори для параметрів навігаційної панелі.
///
/// Забезпечують безпечні значення для всіх конфігураційних параметрів.
class NavValidators {
  NavValidators._();

  /// Мінімальна висота панелі.
  static const double minHeight = 48.0;

  /// Максимальна висота панелі.
  static const double maxHeight = 100.0;

  /// Мінімальний розмір іконки.
  static const double minIconSize = 16.0;

  /// Максимальний розмір іконки.
  static const double maxIconSize = 40.0;

  /// Мінімальний розмір активної іконки.
  static const double minActiveIconSize = 18.0;

  /// Максимальний розмір активної іконки.
  static const double maxActiveIconSize = 44.0;

  /// Мінімальна кількість елементів.
  static const int minItems = 2;

  /// Максимальна кількість елементів.
  static const int maxItems = 7;

  /// Мінімальна ширина центральної кнопки.
  static const double minCenterActionSize = 32.0;

  /// Максимальна ширина центральної кнопки.
  static const double maxCenterActionSize = 72.0;

  /// Мінімальне значення blur sigma.
  static const double minBlurSigma = 0.0;

  /// Максимальне значення blur sigma.
  static const double maxBlurSigma = 25.0;

  /// Мінімальний лічильник бейджів.
  static const int minBadgeCount = 0;

  /// Максимальний лічильник бейджів.
  static const int maxBadgeCount = 999;

  /// Валідує висоту панелі.
  static double validateHeight(double height) {
    return height.clamp(minHeight, maxHeight);
  }

  /// Валідує розмір неактивної іконки.
  static double validateIconSize(double size) {
    return size.clamp(minIconSize, maxIconSize);
  }

  /// Валідує розмір активної іконки.
  static double validateActiveIconSize(double size) {
    return size.clamp(minActiveIconSize, maxActiveIconSize);
  }

  /// Валідує кількість елементів.
  static int validateItemCount(int count) {
    return count.clamp(minItems, maxItems);
  }

  /// Валідує розмір центральної кнопки.
  static double validateCenterActionSize(double size) {
    return size.clamp(minCenterActionSize, maxCenterActionSize);
  }

  /// Валідує blur sigma.
  static double validateBlurSigma(double sigma) {
    return sigma.clamp(minBlurSigma, maxBlurSigma);
  }

  /// Валідує лічильник бейджів.
  static int validateBadgeCount(int count) {
    return count.clamp(minBadgeCount, maxBadgeCount);
  }

  /// Валідує індекс вкладки для списку елементів.
  ///
  /// Повертає -1 якщо індекс недійсний.
  static int validateIndex(int index, int itemCount) {
    if (itemCount <= 0) return -1;
    if (index < 0 || index >= itemCount) return -1;
    return index;
  }

  /// Перевіряє чи списки елементів не пустий.
  static bool isValidItems(List<AppNavItem> items) {
    return items.isNotEmpty && items.length >= minItems;
  }

  /// Перевіряє чи конфігурація валідна.
  static bool isValidConfig(NavConfig config) {
    return config.height >= minHeight &&
        config.height <= maxHeight &&
        config.iconSize >= minIconSize &&
        config.iconSize <= maxIconSize &&
        config.activeIconSize >= minActiveIconSize &&
        config.activeIconSize <= maxActiveIconSize &&
        config.blurSigma >= minBlurSigma &&
        config.blurSigma <= maxBlurSigma &&
        config.centerActionSize >= minCenterActionSize &&
        config.centerActionSize <= maxCenterActionSize;
  }

  /// Обчислює ширину кожного елемента залежно від кількості.
  static double computeItemWidth(double totalWidth, int itemCount) {
    final validCount = validateItemCount(itemCount);
    if (validCount <= 0) return totalWidth;
    return totalWidth / validCount;
  }

  /// Повертає кількість елементів що поміщаються в доступній ширині.
  static int itemsInWidth(double totalWidth, double itemMinWidth) {
    if (itemMinWidth <= 0) return 0;
    return (totalWidth / itemMinWidth).floor();
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Тема-білдер (Nav Theme Builder)
// ═══════════════════════════════════════════════════════════════════════════

/// Білдер теми для навігаційної панелі.
///
/// Дозволяє створювати кастомні палітри кольорів для навігації.
///
/// Приклад використання:
/// ```dart
/// final config = NavThemeBuilder()
///   .withActiveColor(const Color(0xFFFF5722))
///   .withInactiveColor(const Color(0xFF6B6B80))
///   .withBlurBackground()
///   .build();
/// ```
class NavThemeBuilder {
  /// Створює білдер з початковими значеннями.
  NavThemeBuilder({
    this.activeColor,
    this.inactiveColor,
    this.navColor,
    this.borderColor,
    this.centerActionColor,
    this.isLightTheme = false,
    this.showBorder = true,
    this.enableBlur = false,
    this.blurSigma = 10.0,
    this.height = 64.0,
  });

  /// Кастомний колір активної вкладки.
  final Color? activeColor;

  /// Кастомний колір неактивної вкладки.
  final Color? inactiveColor;

  /// Кастомний колір фону панелі.
  final Color? navColor;

  /// Кастомний колір межі.
  final Color? borderColor;

  /// Кастомний колір центральної кнопки.
  final Color? centerActionColor;

  /// Світла тема.
  final bool isLightTheme;

  /// Показувати верхню межу.
  final bool showBorder;

  /// Увімкнути blur-фон.
  final bool enableBlur;

  /// Інтенсивність blur.
  final double blurSigma;

  /// Висота панелі.
  final double height;

  /// Встановлює колір активної вкладки.
  NavThemeBuilder withActiveColor(Color color) {
    return NavThemeBuilder(
      activeColor: color,
      inactiveColor: inactiveColor,
      navColor: navColor,
      borderColor: borderColor,
      centerActionColor: centerActionColor,
      isLightTheme: isLightTheme,
      showBorder: showBorder,
      enableBlur: enableBlur,
      blurSigma: blurSigma,
      height: height,
    );
  }

  /// Встановлює колір неактивної вкладки.
  NavThemeBuilder withInactiveColor(Color color) {
    return NavThemeBuilder(
      activeColor: activeColor,
      inactiveColor: color,
      navColor: navColor,
      borderColor: borderColor,
      centerActionColor: centerActionColor,
      isLightTheme: isLightTheme,
      showBorder: showBorder,
      enableBlur: enableBlur,
      blurSigma: blurSigma,
      height: height,
    );
  }

  /// Встановлює колір фону панелі.
  NavThemeBuilder withNavColor(Color color) {
    return NavThemeBuilder(
      activeColor: activeColor,
      inactiveColor: inactiveColor,
      navColor: color,
      borderColor: borderColor,
      centerActionColor: centerActionColor,
      isLightTheme: isLightTheme,
      showBorder: showBorder,
      enableBlur: enableBlur,
      blurSigma: blurSigma,
      height: height,
    );
  }

  /// Встановлює колір межі.
  NavThemeBuilder withBorderColor(Color color) {
    return NavThemeBuilder(
      activeColor: activeColor,
      inactiveColor: inactiveColor,
      navColor: navColor,
      borderColor: color,
      centerActionColor: centerActionColor,
      isLightTheme: isLightTheme,
      showBorder: true,
      enableBlur: enableBlur,
      blurSigma: blurSigma,
      height: height,
    );
  }

  /// Встановлює колір центральної кнопки.
  NavThemeBuilder withCenterActionColor(Color color) {
    return NavThemeBuilder(
      activeColor: activeColor,
      inactiveColor: inactiveColor,
      navColor: navColor,
      borderColor: borderColor,
      centerActionColor: color,
      isLightTheme: isLightTheme,
      showBorder: showBorder,
      enableBlur: enableBlur,
      blurSigma: blurSigma,
      height: height,
    );
  }

  /// Встановлює тему.
  NavThemeBuilder withTheme(bool light) {
    return NavThemeBuilder(
      activeColor: activeColor,
      inactiveColor: inactiveColor,
      navColor: navColor,
      borderColor: borderColor,
      centerActionColor: centerActionColor,
      isLightTheme: light,
      showBorder: showBorder,
      enableBlur: enableBlur,
      blurSigma: blurSigma,
      height: height,
    );
  }

  /// Вмикає blur-фон з вказаною інтенсивністю.
  NavThemeBuilder withBlur([double sigma = 10.0]) {
    return NavThemeBuilder(
      activeColor: activeColor,
      inactiveColor: inactiveColor,
      navColor: navColor,
      borderColor: borderColor,
      centerActionColor: centerActionColor,
      isLightTheme: isLightTheme,
      showBorder: showBorder,
      enableBlur: true,
      blurSigma: NavValidators.validateBlurSigma(sigma),
      height: height,
    );
  }

  /// Встановлює висоту панелі.
  NavThemeBuilder withHeight(double h) {
    return NavThemeBuilder(
      activeColor: activeColor,
      inactiveColor: inactiveColor,
      navColor: navColor,
      borderColor: borderColor,
      centerActionColor: centerActionColor,
      isLightTheme: isLightTheme,
      showBorder: showBorder,
      enableBlur: enableBlur,
      blurSigma: blurSigma,
      height: NavValidators.validateHeight(h),
    );
  }

  /// Вимикає верхню межу.
  NavThemeBuilder withoutBorder() {
    return NavThemeBuilder(
      activeColor: activeColor,
      inactiveColor: inactiveColor,
      navColor: navColor,
      borderColor: borderColor,
      centerActionColor: centerActionColor,
      isLightTheme: isLightTheme,
      showBorder: false,
      enableBlur: enableBlur,
      blurSigma: blurSigma,
      height: height,
    );
  }

  /// Створює [NavConfig]-сумісну конфігурацію.
  NavConfig buildConfig({int currentIndex = 0}) {
    return NavConfig(
      currentIndex: currentIndex,
      isLightTheme: isLightTheme,
      showActiveIndicator: true,
      showBorder: showBorder,
      enableBlurBackground: enableBlur,
      blurSigma: blurSigma,
      height: height,
      customNavColor: navColor,
      customActiveColor: activeColor,
      customInactiveColor: inactiveColor,
      centerActionSize: 48.0,
      enableAnimation: true,
      enablePressEffect: true,
    );
  }

  /// Створює конфігурацію для темної теми.
  NavConfig buildDark({int currentIndex = 0}) =>
      buildConfig(currentIndex: currentIndex);

  /// Створює конфігурацію для світлої теми.
  NavConfig buildLight({int currentIndex = 0}) =>
      buildConfig(currentIndex: currentIndex, isLightTheme: true);

  /// Створює повну палітру кольорів для теми.
  NavThemeColors buildColors() {
    final resolvedActive = activeColor ??
        (isLightTheme
            ? const Color(0xFF006FCD)
            : const Color(0xFF00D1FF));
    final resolvedInactive = inactiveColor ??
        (isLightTheme
            ? const Color(0xFF9CA3AF)
            : const Color(0xFF6B6B80));
    final resolvedNav = navColor ??
        (isLightTheme
            ? const Color(0xFFFFFFFF)
            : const Color(0xFF16161E));
    final resolvedBorder = borderColor ??
        (isLightTheme
            ? const Color(0xFFE0E0E0)
            : const Color(0xFF2A2A3A));
    final resolvedCenter = centerActionColor ??
        resolvedActive;
    return NavThemeColors(
      active: resolvedActive,
      inactive: resolvedInactive,
      nav: resolvedNav,
      border: resolvedBorder,
      center: resolvedCenter,
      error: const Color(0xFFFF1744),
      unread: resolvedActive,
      tooltip: resolvedInactive,
    );
  }

  @override
  String toString() =>
      'NavThemeBuilder(isLightTheme: $isLightTheme, '
      'enableBlur: $enableBlur, '
      'height: $height)';
}

// ═══════════════════════════════════════════════════════════════════════════
// Палітра кольорів навігації (Nav Theme Colors)
// ═══════════════════════════════════════════════════════════════════════════

/// Повна палітра кольорів для навігаційної панелі.
///
/// Об'єднує всі кольори в один об'єкт для зручного доступу.
class NavThemeColors {
  /// Створює палітру кольорів з усіма параметрами.
  const NavThemeColors({
    required this.active,
    required this.inactive,
    required this.nav,
    required this.border,
    required this.center,
    required this.error,
    required this.unread,
    required this.tooltip,
  });

  /// Колір активної вкладки.
  final Color active;

  /// Колір неактивної вкладки.
  final Color inactive;

  /// Колір фону панелі.
  final Color nav;

  /// Колір верхньої межі.
  final Color border;

  /// Колір центральної кнопки.
  final Color center;

  /// Колір бейджу / помилки.
  final Color error;

  /// Колір індикатора непрочитого.
  final Color unread;

  /// Колір для tooltip'у.
  final Color tooltip;

  /// Створює палітру для темної теми PS5.
  factory NavThemeColors.ps5() {
    return const NavThemeColors(
      active: const Color(0xFF00D1FF),
      inactive: const Color(0xFF6B6B80),
      nav: const Color(0xFF16161E),
      border: const Color(0xFF2A2A3A),
      center: const Color(0xFF00D1FF),
      error: const Color(0xFFFF1744),
      unread: const Color(0xFF00D1FF),
      tooltip: const Color(0xFF6B6B80),
    );
  }

  /// Створює палітру для світлої теми Monitor.
  factory NavThemeColors.monitor() {
    return const NavThemeColors(
      active: const Color(0xFF006FCD),
      inactive: const Color(0xFF9CA3AF),
      nav: const Color(0xFFFFFFFF),
      border: const Color(0xFFE0E0E0),
      center: const Color(0xFF006FCD),
      error: const Color(0xFFFF1744),
      unread: const Color(0xFF006FCD),
      tooltip: const Color(0xFF6B7280),
    );
  }

  /// Повертає кольори залежно від теми.
  static NavThemeColors forTheme(bool isLightTheme) {
    return isLightTheme
        ? NavThemeColors.monitor()
        : NavThemeColors.ps5();
  }

  /// Темні варіанти кольорів.
  NavThemeColors darken(double amount) {
    return NavThemeColors(
      active: Color.lerp(active, Colors.black, amount)!,
      inactive: Color.lerp(inactive, Colors.black, amount)!,
      nav: Color.lerp(nav, Colors.black, amount)!,
      border: Color.lerp(border, Colors.black, amount)!,
      center: Color.lerp(center, Colors.black, amount)!,
      error: error,
      unread: Color.lerp(unread, Colors.black, amount)!,
      tooltip: Color.lerp(tooltip, Colors.black, amount)!,
    );
  }

  /// Світлі варіанти кольорів.
  NavThemeColors lighten(double amount) {
    return NavThemeColors(
      active: Color.lerp(active, Colors.white, amount)!,
      inactive: Color.lerp(inactive, Colors.white, amount)!,
      nav: Color.lerp(nav, Colors.white, amount)!,
      border: Color.lerp(border, Colors.white, amount)!,
      center: Color.lerp(center, Colors.white, amount)!,
      error: error,
      unread: Color.lerp(unread, Colors.white, amount)!,
      tooltip: Color.lerp(tooltip, Colors.white, amount)!,
    );
  }

  /// Створює копію з перевизначенням кольору активної вкладки.
  NavThemeColors withActive(Color color) => NavThemeColors(
        active: color,
        inactive: inactive,
        nav: nav,
        border: border,
        center: center,
        error: error,
        unread: unread,
        tooltip: tooltip,
      );
}

// ═══════════════════════════════════════════════════════════════════════════
// Допоміжні будівельники (Utility Builders)
// ═════════════════════════════════════════════════════════════════════════

/// Будівельники для специфічних конфігурацій навігаційної панелі.
///
/// Надає фабричні методи для створення готових конфігурацій
/// для різних контекстів використання навігації.
class NavBuilders {
  NavBuilders._();

  /// Будує конфігурацію для головного екрану.
  static NavConfig home({
    bool isLightTheme = false,
    bool enableBlur = false,
  }) {
    return NavConfig(
      currentIndex: 0,
      isLightTheme: isLightTheme,
      enableBlurBackground: enableBlur,
      activeIndicatorType: ActiveIndicatorType.bar,
    );
  }

  /// Будує конфігурацію для екрана аналітики.
  static NavConfig analytics({
    bool isLightTheme = false,
    bool enableBlur = false,
  }) {
    return NavConfig(
      currentIndex: 1,
      isLightTheme: isLightTheme,
      enableBlurBackground: enableBlur,
      activeIndicatorType: ActiveIndicatorType.dot,
    );
  }

  /// Будує конфігурацію для екрана налаштувань.
  static NavConfig settings({
    bool isLightTheme = false,
    bool enableBlur = false,
  }) {
    return NavConfig(
      currentIndex: 4,
      isLightTheme: isLightTheme,
      enableBlurBackground: enableBlur,
      activeIndicatorType: ActiveIndicatorType.none,
    );
  }

  /// Будує конфігурацію для екрана гейміфікації.
  static NavConfig gamification({
    bool isLightTheme = false,
    bool enableBlur = false,
  }) {
    return NavConfig(
      currentIndex: 3,
      isLightTheme: isLightTheme,
      enableBlurBackground: enableBlur,
      activeIndicatorType: ActiveIndicatorType.dot,
    );
  }

  /// Будує конфігурацію з усіма ефектами.
  static NavConfig fullEffects({
    bool isLightTheme = false,
  }) {
    return NavConfig(
      currentIndex: 0,
      isLightTheme: isLightTheme,
      enableBlurBackground: true,
      blurSigma: 12.0,
      activeIndicatorType: ActiveIndicatorType.gradientBar,
      enablePressEffect: true,
      enableHaptic: true,
    );
  }

  /// Будує мінімалістичну конфігурацію.
  static NavConfig minimal({
    bool isLightTheme = false,
  }) {
    return NavConfig(
      currentIndex: 0,
      isLightTheme: isLightTheme,
      showBorder: false,
      showActiveIndicator: false,
      enableAnimation: false,
      enablePressEffect: false,
      enableHaptic: false,
    );
  }

  /// Будує конфігурацію для планшетів.
  static NavConfig tablet({
    bool isLightTheme = false,
    bool enableBlur = true,
  }) {
    return NavConfig(
      currentIndex: 0,
      isLightTheme: isLightTheme,
      height: 72.0,
      iconSize: 28.0,
      activeIconSize: 30.0,
      centerActionSize: 56.0,
      enableBlurBackground: enableBlur,
      blurSigma: 14.0,
    );
  }

  /// Будує конфігурацію для маленьких екранів.
  static NavConfig smallScreen({
    bool isLightTheme = false,
  }) {
    return NavConfig(
      currentIndex: 0,
      isLightTheme: isLightTheme,
      height: 56.0,
      iconSize: 20.0,
      activeIconSize: 22.0,
      centerActionSize: 40.0,
    );
  }

  /// Будує конфігурацію для phone-формату.
  static NavConfig phone({
    bool isLightTheme = false,
  }) {
    return NavConfig(
      currentIndex: 0,
      isLightTheme: isLightTheme,
      height: 60.0,
      iconSize: 24.0,
      activeIconSize: 26.0,
      centerActionSize: 48.0,
    );
  }

  /// Будує конфігурацію з пульсуючим індикатором.
  static NavConfig pulseIndicator({
    bool isLightTheme = false,
  }) {
    return NavConfig(
      currentIndex: 0,
      isLightTheme: isLightTheme,
      activeIndicatorType: ActiveIndicatorType.pulse,
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Валідатор навігації (Navigation Validator)
// ═══════════════════════════════════════════════════════════════════════════

/// Валідатор параметрів навігаційної панелі.
class NavValidator {
  NavValidator._();

  /// Перевіряє список елементів навігації.
  static String? validateItems(List<AppNavItem> items) {
    if (items.isEmpty) return 'Список елементів порожній';
    if (items.length < 2) return 'Мінімум 2 елементи навігації';
    if (items.length > 7) return 'Максимум 7 елементів навігації';
    return null;
  }

  /// Перевіряє поточний індекс.
  static String? validateCurrentIndex(int index, int itemCount) {
    if (index < 0) return 'Індекс не може бути від\'ємним';
    if (index >= itemCount) {
      return 'Індекс $index поза межами (макс: ${itemCount - 1})';
    }
    return null;
  }

  /// Перевіряє розмір іконки.
  static String? validateIconSize(double size, {double min = 12, double max = 48}) {
    if (size < min) return 'Розмір іконки занадто малий (мін: $min)';
    if (size > max) return 'Розмір іконки занадто великий (макс: $max)';
    return null;
  }

  /// Перевіряє висоту панелі.
  static String? validateHeight(double height, {double min = 40, double max = 100}) {
    if (height < min) return 'Висота панелі занадто мала (мін: $min)';
    if (height > max) return 'Висота панелі занадто велика (макс: $max)';
    return null;
  }

  /// Перевіряє інтенсивність blur.
  static String? validateBlurSigma(double sigma) {
    if (sigma < 0) return 'Blur sigma не може бути від\'ємним';
    if (sigma > 30) return 'Blur sigma занадто великий (макс: 30)';
    return null;
  }

  /// Перевіряє розмір центральної кнопки.
  static String? validateCenterActionSize(double size) {
    if (size <= 0) return 'Розмір центральної кнопки > 0';
    if (size > 80) return 'Розмір центральної кнопки занадто великий (макс: 80)';
    return null;
  }

  /// Перевіряє множник швидкості.
  static String? validateSpeedMultiplier(double speed) {
    if (speed <= 0) return 'Множник швидкості > 0';
    if (speed > 5.0) return 'Множник швидкості занадто великий (макс: 5.0)';
    return null;
  }

  /// Повна валідація всіх параметрів.
  static List<String> validateAll({
    required List<AppNavItem> items,
    required int currentIndex,
    double height = 64.0,
    double iconSize = 24.0,
    double activeIconSize = 26.0,
    double blurSigma = 10.0,
    double centerActionSize = 48.0,
  }) {
    final errors = <String>[];
    final i = validateItems(items);
    if (i != null) errors.add(i);
    final c = validateCurrentIndex(currentIndex, items.length);
    if (c != null) errors.add(c);
    final h = validateHeight(height);
    if (h != null) errors.add(h);
    final ic = validateIconSize(iconSize);
    if (ic != null) errors.add(ic);
    final aic = validateIconSize(activeIconSize);
    if (aic != null) errors.add(aic);
    final b = validateBlurSigma(blurSigma);
    if (b != null) errors.add(b);
    final ca = validateCenterActionSize(centerActionSize);
    if (ca != null) errors.add(ca);
    return errors;
  }

  /// Швидка перевірка.
  static bool isValid({
    required List<AppNavItem> items,
    required int currentIndex,
  }) {
    return validateItems(items) == null &&
        validateCurrentIndex(currentIndex, items.length) == null;
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Помічник теми навігації (Navigation Theme Helper)
// ═══════════════════════════════════════════════════════════════════════════

/// Помічник для управління кольорами навігаційної панелі.
///
/// Централізує доступ до кольорів залежно від теми та кастомних налаштувань.
class NavThemeHelper {
  NavThemeHelper({
    required this.isLightTheme,
    this.customNavColor,
    this.customActiveColor,
    this.customInactiveColor,
    this.customCenterColor,
  });

  /// Світла тема.
  final bool isLightTheme;

  /// Кастомний колір фону.
  final Color? customNavColor;

  /// Кастомний колір активної вкладки.
  final Color? customActiveColor;

  /// Кастомний колір неактивної вкладки.
  final Color? customInactiveColor;

  /// Кастомний колір центральної кнопки.
  final Color? customCenterColor;

  /// Колір фону панелі.
  Color get bgColor => customNavColor ??
      (isLightTheme ? AppColorsMonitor.navBackground : AppColorsPS5.navBackground);

  /// Колір активної вкладки.
  Color get activeColor => customActiveColor ??
      (isLightTheme ? AppColorsMonitor.navActive : AppColorsPS5.navActive);

  /// Колір неактивної вкладки.
  Color get inactiveColor => customInactiveColor ??
      (isLightTheme ? AppColorsMonitor.navInactive : AppColorsPS5.navInactive);

  /// Колір верхньої межі.
  Color get borderColor =>
      isLightTheme ? AppColorsMonitor.border : AppColorsPS5.border;

  /// Колір бейджу.
  Color get badgeColor => AppColorsPS5.error;

  /// Колір індикатора непрочитаного.
  Color get unreadColor => AppColorsPS5.accent;

  /// Колір центральної кнопки.
  Color get centerColor => customCenterColor ??
      (isLightTheme ? AppColorsMonitor.accent : AppColorsPS5.accent);

  /// Колір тексту мітки.
  Color get labelColor => inactiveColor;

  /// Колір тексту активної мітки.
  Color get activeLabelColor => activeColor;

  /// Створює BoxDecoration для панелі.
  BoxDecoration panelDecoration({bool showBorder = true}) {
    return BoxDecoration(
      color: bgColor,
      border: showBorder
          ? Border(top: BorderSide(color: borderColor, width: 0.5))
          : null,
    );
  }

  /// Створює BoxDecoration для центральної кнопки.
  BoxDecoration centerButtonDecoration() {
    return BoxDecoration(
      color: centerColor,
      shape: BoxShape.circle,
      boxShadow: [
        BoxShadow(
          color: centerColor.withOpacity(0.3),
          blurRadius: 12,
          spreadRadius: 2,
        ),
      ],
    );
  }

  /// Створює BoxDecoration для бейджу.
  BoxDecoration badgeDecoration() {
    return BoxDecoration(
      color: badgeColor,
      shape: BoxShape.circle,
    );
  }

  /// Обчислює колір для елемента за індексом.
  Color colorForItem(int index, int activeIndex) {
    if (index == activeIndex) return activeColor;
    return inactiveColor;
  }

  /// Створює NavConfig з поточними налаштуваннями.
  NavConfig toConfig({
    int currentIndex = 0,
    bool enableHaptic = true,
    bool showActiveIndicator = true,
    ActiveIndicatorType indicatorType = ActiveIndicatorType.bar,
  }) {
    return NavConfig(
      currentIndex: currentIndex,
      isLightTheme: isLightTheme,
      enableHaptic: enableHaptic,
      showActiveIndicator: showActiveIndicator,
      activeIndicatorType: indicatorType,
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Помічник доступності навігації (Navigation Accessibility Helper)
// ═══════════════════════════════════════════════════════════════════════════

/// Помічник для забезпечення доступності навігаційної панелі.
///
/// Генерує семантичні мітки, описи та обробляє навігацію клавіатурою.
class NavAccessibilityHelper {
  NavAccessibilityHelper._();

  /// Повертає семантичну мітку для вкладки.
  static String semanticLabelForItem(AppNavItem item, int index) {
    return item.semanticLabel ?? 'Вкладка ${index + 1}: ${item.label}';
  }

  /// Повертає повний опис для екранних читачів.
  static String fullDescription(AppNavItem item, int index, bool isActive) {
    final label = semanticLabelForItem(item, index);
    final badge = item.displayBadgeText.isNotEmpty
        ? ', ${item.badgeCount} нових сповіщень'
        : '';
    final status = isActive ? ', активна' : ', неактивна';
    final unread = item.hasUnread ? ', є непрочитані' : '';
    final disabled = !item.isEnabled ? ', недоступна' : '';
    return '$label$badge$status$unread$disabled';
  }

  /// Повертає підказку для long-press.
  static String tooltipForItem(AppNavItem item) {
    return item.tooltip ?? item.label;
  }

  /// Створює Semantics для елемента навігації.
  static Semantics buildSemantics({
    required AppNavItem item,
    required int index,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return Semantics(
      label: semanticLabelForItem(item, index),
      hint: tooltipForItem(item),
      selected: isActive,
      button: true,
      enabled: item.isEnabled,
      onTap: onTap,
    );
  }

  /// Створює MergeSemantics для панелі в цілому.
  static Semantics buildPanelSemantics({
    required int itemCount,
    required int activeIndex,
    required String panelLabel,
  }) {
    return MergeSemantics(
      child: Semantics(
        label: panelLabel,
        hint: 'Нижня навігаційна панель з $itemCount вкладками',
        value: 'Активна вкладка ${activeIndex + 1} з $itemCount',
      ),
    );
  }

  /// Генерує коротке ім'я для focus-обміну.
  static String focusNodeName(int index) {
    return 'nav_item_$index';
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Калькулятор розкладки навігації (Nav Layout Calculator)
// ═══════════════════════════════════════════════════════════════════════════

/// Калькулятор розмірів та розкладки навігаційної панелі.
///
/// Обчислює розміри елементів, відступи та позиції
/// залежно від кількості елементів та ширини екрана.
class NavLayoutCalculator {
  NavLayoutCalculator({
    required this.itemCount,
    required this.panelWidth,
    required this.panelHeight,
    this.hasCenterAction = false,
    this.iconSize = 24.0,
    this.activeIconSize = 26.0,
    this.centerActionSize = 48.0,
    this.horizontalPadding = 8.0,
  });

  /// Кількість елементів.
  final int itemCount;

  /// Ширина панелі.
  final double panelWidth;

  /// Висота панелі.
  final double panelHeight;

  /// Наявність центральної кнопки.
  final bool hasCenterAction;

  /// Розмір неактивної іконки.
  final double iconSize;

  /// Розмір активної іконки.
  final double activeIconSize;

  /// Розмір центральної кнопки.
  final double centerActionSize;

  /// Горизонтальний відступ.
  final double horizontalPadding;

  /// Доступна ширина для елементів.
  double get availableWidth =>
      panelWidth - (horizontalPadding * 2);

  /// Ширина одного елемента.
  double get itemWidth {
    if (itemCount <= 0) return 0;
    return availableWidth / itemCount;
  }

  /// Центр кожного елемента по X.
  double itemCenterX(int index) {
    if (itemCount <= 0) return 0;
    final itemW = itemWidth;
    return horizontalPadding + itemW * index + itemW / 2;
  }

  /// Висота іконки для елемента.
  double iconHeightForItem(int index) {
    if (hasCenterAction && _isCenterIndex(index)) {
      return centerActionSize;
    }
    return iconSize;
  }

  /// Чи елемент є центральним.
  bool _isCenterIndex(int index) {
    if (!hasCenterAction || itemCount % 2 == 0) return false;
    return index == itemCount ~/ 2;
  }

  /// Вертикальний відступ від верху до іконки.
  double get iconTopOffset {
    final usedHeight = hasCenterAction ? centerActionSize : iconSize;
    return (panelHeight - usedHeight) / 2 - 10;
  }

  /// Мінімальна ширина панелі для вміщення всіх елементів.
  double get minimumPanelWidth {
    final regularItems = hasCenterAction ? itemCount - 1 : itemCount;
    return regularItems * 60 + centerActionSize + horizontalPadding * 2;
  }

  /// Чи всі елементи поміщаються на екрані.
  bool get fitsOnScreen => panelWidth >= minimumPanelWidth;

  /// Рекомендована висота панелі для кількості елементів.
  static double recommendedHeight(int itemCount, {bool hasCenter = false}) {
    if (itemCount <= 3) return 56.0;
    if (itemCount <= 5) return 64.0;
    return 72.0;
  }

  /// Рекомендований розмір іконки для кількості елементів.
  static double recommendedIconSize(int itemCount) {
    if (itemCount <= 3) return 28.0;
    if (itemCount <= 5) return 24.0;
    return 20.0;
  }
}
