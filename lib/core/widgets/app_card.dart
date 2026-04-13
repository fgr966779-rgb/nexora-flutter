import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';
import '../constants/app_radii.dart';
import '../constants/app_shadows.dart';
import '../constants/app_durations.dart';
import '../constants/app_easings.dart';

// ─── Debug Configuration ───────────────────────────────────────────────────

/// Налаштування налагодження для [AppCard].
///
/// Контролює видимість debug-повідомлень та візуальних індикаторів.
class AppCardDebugConfig {
  AppCardDebugConfig._();

  /// Увімкнути вивід debug-повідомлень у консоль.
  static bool enableLogging = false;

  /// Показувати візуальні рамки-індикатори для акцентних позицій.
  static bool showAccentIndicators = false;

  /// Показувати розміри margin/padding.
  static bool showLayoutBounds = false;

  /// Записує debug-повідомлення у консоль.
  ///
  /// [message] — текст повідомлення.
  /// [tag] — додатковий тег для фільтрації.
  static void log(String message, {String? tag}) {
    if (!enableLogging) return;
    final prefix = tag != null ? '[AppCard:$tag] ' : '[AppCard] ';
    debugPrint('$prefix$message');
  }
}

// ─── Card Animation Config ─────────────────────────────────────────────────

/// Конфігурація анімацій для [AppCard].
///
/// Дозволяє кастомізувати тривалість, криві та параметри анімацій.
class AppCardAnimationConfig {
  /// Створює конфігурацію анімацій для картки.
  ///
  /// [pressScale] — масштаб при натисканні (за замовчуванням 0.98).
  /// [pressDuration] — тривалість анімації натискання.
  /// [pressCurve] — крива анімації натискання.
  /// [fadeInDuration] — тривалість появи картки.
  /// [fadeInCurve] — крива появи.
  /// [expandDuration] — тривалість розгортання.
  /// [expandCurve] — крива розгортання.
  /// [shakeDuration] — тривалість тряски для error-стану.
  /// [shakeH] — амплітуда тряски по горизонталі.
  const AppCardAnimationConfig({
    this.pressScale = 0.98,
    this.pressDuration = AppDurations.fast,
    this.pressCurve = AppEasings.standard,
    this.fadeInDuration = AppDurations.fast,
    this.fadeInCurve = AppEasings.decelerate,
    this.expandDuration = AppDurations.medium,
    this.expandCurve = AppEasings.standard,
    this.shakeDuration = AppDurations.medium,
    this.shakeH = 4.0,
    this.shimmerDuration = AppDurations.skeleton,
  });

  /// Масштаб при натисканні.
  final double pressScale;

  /// Тривалість анімації натискання.
  final Duration pressDuration;

  /// Крива анімації натискання.
  final Curve pressCurve;

  /// Тривалість появи картки.
  final Duration fadeInDuration;

  /// Крива появи.
  final Curve fadeInCurve;

  /// Тривалість розгортання.
  final Duration expandDuration;

  /// Крива розгортання.
  final Curve expandCurve;

  /// Тривалість тряски для error-стану.
  final Duration shakeDuration;

  /// Амплітуда тряски по горизонталі.
  final double shakeH;

  /// Тривалість shimmer-ефекту для loading-стану.
  final Duration shimmerDuration;

  /// Стандартна конфігурація анімацій.
  static const AppCardAnimationConfig standard = AppCardAnimationConfig();

  /// Швидка конфігурація (менші тривалості).
  static const AppCardAnimationConfig fast = AppCardAnimationConfig(
    pressDuration: Duration(milliseconds: 80),
    fadeInDuration: Duration(milliseconds: 120),
    expandDuration: Duration(milliseconds: 200),
    shakeDuration: Duration(milliseconds: 300),
  );

  /// Повільна конфігурація (більші тривалості для елегантності).
  static const AppCardAnimationConfig slow = AppCardAnimationConfig(
    pressDuration: Duration(milliseconds: 250),
    fadeInDuration: Duration(milliseconds: 400),
    expandDuration: Duration(milliseconds: 500),
    shakeDuration: Duration(milliseconds: 600),
    pressCurve: Curves.easeInOutCubic,
    fadeInCurve: Curves.easeOutQuart,
    expandCurve: Curves.easeInOutCubic,
  );

  // ─── copyWith ────────────────────────────────────────────────────────

  /// Створює копію з перезаписаними полями.
  ///
  /// Дозволяє змінити окремі параметри анімації,
  /// зберігаючи решту значень незмінними.
  AppCardAnimationConfig copyWith({
    double? pressScale,
    Duration? pressDuration,
    Curve? pressCurve,
    Duration? fadeInDuration,
    Curve? fadeInCurve,
    Duration? expandDuration,
    Curve? expandCurve,
    Duration? shakeDuration,
    double? shakeH,
    Duration? shimmerDuration,
  }) {
    return AppCardAnimationConfig(
      pressScale: pressScale ?? this.pressScale,
      pressDuration: pressDuration ?? this.pressDuration,
      pressCurve: pressCurve ?? this.pressCurve,
      fadeInDuration: fadeInDuration ?? this.fadeInDuration,
      fadeInCurve: fadeInCurve ?? this.fadeInCurve,
      expandDuration: expandDuration ?? this.expandDuration,
      expandCurve: expandCurve ?? this.expandCurve,
      shakeDuration: shakeDuration ?? this.shakeDuration,
      shakeH: shakeH ?? this.shakeH,
      shimmerDuration: shimmerDuration ?? this.shimmerDuration,
    );
  }

  // ─── Interpolation ───────────────────────────────────────────────────

  /// Інтерполює між двома конфігураціями анімацій.
  ///
  /// [other] — інша конфігурація.
  /// [t] — коефіцієнт інтерполяції (0.0 — this, 1.0 — other).
  AppCardAnimationConfig lerp(AppCardAnimationConfig other, double t) {
    return AppCardAnimationConfig(
      pressScale: _lerpDouble(pressScale, other.pressScale, t),
      pressDuration: _lerpDuration(pressDuration, other.pressDuration, t),
      pressCurve: t < 0.5 ? pressCurve : other.pressCurve,
      fadeInDuration: _lerpDuration(fadeInDuration, other.fadeInDuration, t),
      fadeInCurve: t < 0.5 ? fadeInCurve : other.fadeInCurve,
      expandDuration: _lerpDuration(expandDuration, other.expandDuration, t),
      expandCurve: t < 0.5 ? expandCurve : other.expandCurve,
      shakeDuration: _lerpDuration(shakeDuration, other.shakeDuration, t),
      shakeH: _lerpDouble(shakeH, other.shakeH, t),
      shimmerDuration: _lerpDuration(shimmerDuration, other.shimmerDuration, t),
    );
  }

  /// Інтерполює значення [double] між [a] та [b] з коефіцієнтом [t].
  static double _lerpDouble(double a, double b, double t) =>
      a + (b - a) * t.clamp(0.0, 1.0);

  /// Інтерполює значення [Duration] між [a] та [b] з коефіцієнтом [t].
  static Duration _lerpDuration(Duration a, Duration b, double t) {
    final ms = (a.inMilliseconds + (b.inMilliseconds - a.inMilliseconds) * t)
        .clamp(0.0, double.maxFinite)
        .round();
    return Duration(milliseconds: ms);
  }

  // ─── Equality & Diagnostics ──────────────────────────────────────────

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AppCardAnimationConfig &&
        other.pressScale == pressScale &&
        other.pressDuration == pressDuration &&
        other.pressCurve == pressCurve &&
        other.fadeInDuration == fadeInDuration &&
        other.fadeInCurve == fadeInCurve &&
        other.expandDuration == expandDuration &&
        other.expandCurve == expandCurve &&
        other.shakeDuration == shakeDuration &&
        other.shakeH == shakeH &&
        other.shimmerDuration == shimmerDuration;
  }

  @override
  int get hashCode => Object.hash(
        pressScale,
        pressDuration,
        pressCurve,
        fadeInDuration,
        fadeInCurve,
        expandDuration,
        expandCurve,
        shakeDuration,
        shakeH,
        shimmerDuration,
      );

  /// Чи всі тривалості анімацій менші за порогове значення.
  bool get isFast =>
      pressDuration.inMilliseconds < 150 &&
      fadeInDuration.inMilliseconds < 200 &&
      expandDuration.inMilliseconds < 300;

  /// Загальна тривалість основних анімацій (для діагностики).
  Duration get totalPrimaryDuration =>
      pressDuration + fadeInDuration + expandDuration;

  /// Повертає опис конфігурації для налагодження.
  Map<String, dynamic> toDebugMap() => {
        'pressScale': pressScale,
        'pressDuration': '${pressDuration.inMilliseconds}ms',
        'fadeInDuration': '${fadeInDuration.inMilliseconds}ms',
        'expandDuration': '${expandDuration.inMilliseconds}ms',
        'shakeDuration': '${shakeDuration.inMilliseconds}ms',
        'shakeH': shakeH,
        'isFast': isFast,
      };

  /// Серіалізує конфігурацію у Map для збереження.
  Map<String, dynamic> toJson() => {
        'pressScale': pressScale,
        'pressDurationMs': pressDuration.inMilliseconds,
        'fadeInDurationMs': fadeInDuration.inMilliseconds,
        'expandDurationMs': expandDuration.inMilliseconds,
        'shakeDurationMs': shakeDuration.inMilliseconds,
        'shakeH': shakeH,
        'shimmerDurationMs': shimmerDuration.inMilliseconds,
      };

  /// Десеріалізує конфігурацію з Map.
  factory AppCardAnimationConfig.fromJson(Map<String, dynamic> json) {
    return AppCardAnimationConfig(
      pressScale: (json['pressScale'] as num?)?.toDouble() ?? 0.98,
      pressDuration: Duration(
        milliseconds: (json['pressDurationMs'] as num?)?.toInt() ?? 150,
      ),
      fadeInDuration: Duration(
        milliseconds: (json['fadeInDurationMs'] as num?)?.toInt() ?? 150,
      ),
      expandDuration: Duration(
        milliseconds: (json['expandDurationMs'] as num?)?.toInt() ?? 300,
      ),
      shakeDuration: Duration(
        milliseconds: (json['shakeDurationMs'] as num?)?.toInt() ?? 300,
      ),
      shakeH: (json['shakeH'] as num?)?.toDouble() ?? 4.0,
      shimmerDuration: Duration(
        milliseconds: (json['shimmerDurationMs'] as num?)?.toInt() ?? 1500,
      ),
    );
  }
}

// ─── Card Variant Enum ─────────────────────────────────────────────────────

/// Візуальний стиль картки.
///
/// Кожен варіант має унікальний вигляд:
/// - [elevated] — стандартна тіньова картка з фоном.
/// - [outlined] — контурна картка з прозорим фоном та рамкою.
/// - [glassmorphism] — ефект розмитого скла з напівпрозорістю.
/// - [gradient] — градієнтний фон у стилі PS5 неон.
/// - [frosted] — морозний ефект з сильною напівпрозорістю та м'яким blur.
/// - [neon] — неонова рамка з пульсуючим свіченням у стилі PS5.
enum AppCardVariant {
  /// Стандартна картка з тінню та однотонним фоном.
  elevated,

  /// Картка з контурною рамкою без заливки.
  outlined,

  /// Ефект розмитого скла (glassmorphism) з backdrop blur.
  glassmorphism,

  /// Картка з градієнтним фоном у неоновому стилі PS5.
  gradient,

  /// Морозний ефект з сильною напівпрозорістю та м'яким blur.
  frosted,

  /// Неонова рамка з пульсуючим свіченням у стилі PS5.
  neon;

  /// Українська назва варіанту для налаштувань.
  String get label {
    switch (this) {
      case AppCardVariant.elevated:
        return 'Піднята';
      case AppCardVariant.outlined:
        return 'Контурна';
      case AppCardVariant.glassmorphism:
        return 'Скляна';
      case AppCardVariant.gradient:
        return 'Градієнтна';
      case AppCardVariant.frosted:
        return 'Морозна';
      case AppCardVariant.neon:
        return 'Неонова';
    }
  }

  /// Опис варіанту для accessibility.
  ///
  /// Повертає детальний опис для екранних читачів.
  String get accessibilityDescription {
    switch (this) {
      case AppCardVariant.elevated:
        return 'Картка з тінню';
      case AppCardVariant.outlined:
        return 'Контурна картка';
      case AppCardVariant.glassmorphism:
        return 'Скляна картка з ефектом розбиття';
      case AppCardVariant.gradient:
        return 'Картка з градієнтним фоном';
      case AppCardVariant.frosted:
        return 'Морозна картка';
      case AppCardVariant.neon:
        return 'Картка з неоновою рамкою';
    }
  }

  /// Чи має варіант напівпрозорий фон.
  bool get isTranslucent {
    switch (this) {
      case AppCardVariant.elevated:
      case AppCardVariant.outlined:
        return false;
      case AppCardVariant.glassmorphism:
      case AppCardVariant.gradient:
      case AppCardVariant.frosted:
      case AppCardVariant.neon:
        return true;
    }
  }

  /// Чи варіант використовує градієнт.
  bool get usesGradient => this == AppCardVariant.gradient;

  /// Чи варіант використовує тінь/свічення.
  bool get usesShadow {
    switch (this) {
      case AppCardVariant.elevated:
      case AppCardVariant.glassmorphism:
      case AppCardVariant.gradient:
      case AppCardVariant.frosted:
      case AppCardVariant.neon:
        return true;
      case AppCardVariant.outlined:
        return false;
    }
  }

  /// Іконка для відображення у налаштуваннях.
  IconData get settingsIcon {
    switch (this) {
      case AppCardVariant.elevated:
        return Icons.layers_outlined;
      case AppCardVariant.outlined:
        return Icons.crop_square;
      case AppCardVariant.glassmorphism:
        return Icons.blur_on;
      case AppCardVariant.gradient:
        return Icons.gradient;
      case AppCardVariant.frosted:
        return Icons.ac_unit;
      case AppCardVariant.neon:
        return Icons.lightbulb_outline;
    }
  }

  /// Англійська назва варіанту для серіалізації.
  String get serializedName {
    switch (this) {
      case AppCardVariant.elevated:
        return 'elevated';
      case AppCardVariant.outlined:
        return 'outlined';
      case AppCardVariant.glassmorphism:
        return 'glassmorphism';
      case AppCardVariant.gradient:
        return 'gradient';
      case AppCardVariant.frosted:
        return 'frosted';
      case AppCardVariant.neon:
        return 'neon';
    }
  }

  /// Розбирає варіант з рядкового значення.
  ///
  /// [value] — рядкове представлення варіанту.
  /// Повертає `null`, якщо значення не розпізнано.
  static AppCardVariant? tryParse(String value) {
    return AppCardVariant.values.firstWhere(
      (v) => v.serializedName == value.toLowerCase(),
      orElse: () => AppCardVariant.elevated,
    );
  }

  /// Порядок сортування варіантів (для UI-списків).
  int get sortIndex {
    switch (this) {
      case AppCardVariant.elevated:
        return 0;
      case AppCardVariant.outlined:
        return 1;
      case AppCardVariant.gradient:
        return 2;
      case AppCardVariant.glassmorphism:
        return 3;
      case AppCardVariant.frosted:
        return 4;
      case AppCardVariant.neon:
        return 5;
    }
  }

  /// Чи цей варіант рекомендовано використовувати з акцентом.
  bool get supportsAccent {
    switch (this) {
      case AppCardVariant.elevated:
      case AppCardVariant.outlined:
      case AppCardVariant.gradient:
        return true;
      case AppCardVariant.glassmorphism:
      case AppCardVariant.frosted:
      case AppCardVariant.neon:
        return false;
    }
  }

  /// Оптимальний рівень тіні за замовчуванням для цього варіанту.
  int get defaultElevation {
    switch (this) {
      case AppCardVariant.elevated:
        return 2;
      case AppCardVariant.outlined:
        return 0;
      case AppCardVariant.glassmorphism:
        return 1;
      case AppCardVariant.gradient:
        return 2;
      case AppCardVariant.frosted:
        return 1;
      case AppCardVariant.neon:
        return 3;
    }
  }
}

// ─── Card Accent Position ──────────────────────────────────────────────────

/// Позиція кольорової смужки-акценту на картці.
enum AppCardAccent {
  /// Без акцентної смужки.
  none,

  /// Ліва вертикальна смужка.
  left,

  /// Права вертикальна смужка.
  right,

  /// Верхня горизонтальна смужка.
  top,

  /// Нижня горизонтальна смужка.
  bottom;

  /// Опис позиції акценту для accessibility.
  String get accessibilityDescription {
    switch (this) {
      case AppCardAccent.none:
        return 'Без акцентної смужки';
      case AppCardAccent.left:
        return 'Акцентна смужка зліва';
      case AppCardAccent.right:
        return 'Акцентна смужка справа';
      case AppCardAccent.top:
        return 'Акцентна смужка вгорі';
      case AppCardAccent.bottom:
        return 'Акцентна смужка внизу';
    }
  }
}

// ─── Card State ────────────────────────────────────────────────────────────

/// Стан картки для управління UX.
///
/// Використовується для визначення поточного візуального стану:
/// - [normal] — стандартний стан.
/// - [loading] — завантаження даних.
/// - [error] — помилка завантаження.
/// - [empty] — порожній контент.
/// - [disabled] — вимкнена картка.
enum AppCardState {
  /// Стандартний стан — картка інтерактивна.
  normal,

  /// Картка в процесі завантаження даних.
  loading,

  /// Картка відображає помилку.
  error,

  /// Картка не має контенту для відображення.
  empty,

  /// Картка вимкнена та неінтерактивна.
  disabled;

  /// Чи картка інтерактивна в цьому стані.
  bool get isInteractive => this == AppCardState.normal;

  /// Чи картка відображає індикатор стану.
  bool get hasStateIndicator {
    switch (this) {
      case AppCardState.normal:
      case AppCardState.disabled:
        return false;
      case AppCardState.loading:
      case AppCardState.error:
      case AppCardState.empty:
        return true;
    }
  }

  /// Українська назва стану.
  String get label {
    switch (this) {
      case AppCardState.normal:
        return 'Звичайний';
      case AppCardState.loading:
        return 'Завантаження';
      case AppCardState.error:
        return 'Помилка';
      case AppCardState.empty:
        return 'Порожній';
      case AppCardState.disabled:
        return 'Вимкнено';
    }
  }

  /// Англійська назва стану для серіалізації.
  String get serializedName {
    switch (this) {
      case AppCardState.normal:
        return 'normal';
      case AppCardState.loading:
        return 'loading';
      case AppCardState.error:
        return 'error';
      case AppCardState.empty:
        return 'empty';
      case AppCardState.disabled:
        return 'disabled';
    }
  }

  /// Створює стан на основі булевих прапорців.
  ///
  /// Перевіряє прапорці у порядку пріоритету: disabled → loading → error → empty → normal.
  static AppCardState fromFlags({
    bool isDisabled = false,
    bool isLoading = false,
    bool hasError = false,
    bool isEmpty = false,
  }) {
    if (isDisabled) return AppCardState.disabled;
    if (isLoading) return AppCardState.loading;
    if (hasError) return AppCardState.error;
    if (isEmpty) return AppCardState.empty;
    return AppCardState.normal;
  }

  /// Кольорова семантика стану для індикаторів.
  ///
  /// Повертає `null` для станів, що не потребують кольорового індикатора.
  String? get indicatorColorKey {
    switch (this) {
      case AppCardState.normal:
      case AppCardState.disabled:
      case AppCardState.empty:
        return null;
      case AppCardState.loading:
        return 'accent';
      case AppCardState.error:
        return 'error';
    }
  }

  /// Іконка для стану.
  IconData get stateIcon {
    switch (this) {
      case AppCardState.normal:
        return Icons.check_circle_outline;
      case AppCardState.loading:
        return Icons.hourglass_top_rounded;
      case AppCardState.error:
        return Icons.error_outline_rounded;
      case AppCardState.empty:
        return Icons.inbox_outlined;
      case AppCardState.disabled:
        return Icons.block_outlined;
    }
  }
}

/// Багатофункціональна картка з різними стилями, станами та секціями.
///
/// Підтримує шість візуальних варіантів (elevated, outlined, glassmorphism,
/// gradient, frosted, neon), акцентні рамки, shimmer-завантаження,
/// секції header/body/footer, onLongPress, розгортання, вибір та свайп.
///
/// Приклад використання:
/// ```dart
/// AppCard(
///   variant: AppCardVariant.gradient,
///   accent: AppCardAccent.left,
///   header: Text('Заголовок'),
///   child: Text('Контент картки'),
///   footer: Text('Футер'),
///   onTap: () => print('Натиснуто!'),
/// )
/// ```
class AppCard extends StatefulWidget {
  const AppCard({
    super.key,
    required this.child,
    this.variant = AppCardVariant.elevated,
    this.accent = AppCardAccent.none,
    this.accentColor,
    this.gradientStart,
    this.gradientEnd,
    this.isLoading = false,
    this.hasError = false,
    this.errorMessage = 'Сталася помилка',
    this.isEmpty = false,
    this.emptyMessage = 'Немає даних',
    this.emptyIcon,
    this.onRetry,
    this.isSelected = false,
    this.header,
    this.footer,
    this.onTap,
    this.onLongPress,
    this.isLightTheme = false,
    this.padding,
    this.borderRadius,
    this.margin,
    this.elevationLevel = 2,
    this.isExpandable = false,
    this.expandableContent,
    this.expandLabel = 'Детальніше',
    this.collapseLabel = 'Згорнути',
    this.isSwipeable = false,
    this.onSwipeLeft,
    this.onSwipeRight,
    this.swipeThreshold = 80.0,
    this.onSelectedChanged,
    this.enableNeonPulse = false,
    this.animationConfig = const AppCardAnimationConfig.standard,
    this.isDisabled = false,
    this.semanticLabel,
    this.clipContent = true,
    this.width,
    this.height,
  });

  /// Створює картку з градієнтним фоном.
  ///
  /// Зручний конструктор для найпопулярнішого варіанту.
  AppCard.gradient({
    super.key,
    required this.child,
    this.accent = AppCardAccent.none,
    this.accentColor,
    this.gradientStart,
    this.gradientEnd,
    this.isLoading = false,
    this.hasError = false,
    this.errorMessage = 'Сталася помилка',
    this.isEmpty = false,
    this.emptyMessage = 'Немає даних',
    this.emptyIcon,
    this.onRetry,
    this.isSelected = false,
    this.header,
    this.footer,
    this.onTap,
    this.onLongPress,
    this.isLightTheme = false,
    this.padding,
    this.borderRadius,
    this.margin,
    this.elevationLevel = 2,
    this.isExpandable = false,
    this.expandableContent,
    this.expandLabel = 'Детальніше',
    this.collapseLabel = 'Згорнути',
    this.isSwipeable = false,
    this.onSwipeLeft,
    this.onSwipeRight,
    this.swipeThreshold = 80.0,
    this.onSelectedChanged,
    this.animationConfig = const AppCardAnimationConfig.standard,
    this.isDisabled = false,
    this.semanticLabel,
    this.clipContent = true,
    this.width,
    this.height,
  }) : variant = AppCardVariant.gradient,
       enableNeonPulse = false;

  /// Створює контурну картку.
  AppCard.outlined({
    super.key,
    required this.child,
    this.accent = AppCardAccent.none,
    this.accentColor,
    this.isLoading = false,
    this.hasError = false,
    this.errorMessage = 'Сталася помилка',
    this.isEmpty = false,
    this.emptyMessage = 'Немає даних',
    this.emptyIcon,
    this.onRetry,
    this.isSelected = false,
    this.header,
    this.footer,
    this.onTap,
    this.onLongPress,
    this.isLightTheme = false,
    this.padding,
    this.borderRadius,
    this.margin,
    this.isExpandable = false,
    this.expandableContent,
    this.expandLabel = 'Детальніше',
    this.collapseLabel = 'Згорнути',
    this.isSwipeable = false,
    this.onSwipeLeft,
    this.onSwipeRight,
    this.swipeThreshold = 80.0,
    this.onSelectedChanged,
    this.animationConfig = const AppCardAnimationConfig.standard,
    this.isDisabled = false,
    this.semanticLabel,
    this.clipContent = true,
    this.width,
    this.height,
  }) : variant = AppCardVariant.outlined,
       gradientStart = null,
       gradientEnd = null,
       elevationLevel = 0,
       enableNeonPulse = false;

  /// Створює неонову картку з пульсуючим свіченням.
  AppCard.neon({
    super.key,
    required this.child,
    this.accent = AppCardAccent.none,
    this.accentColor,
    this.isLoading = false,
    this.hasError = false,
    this.errorMessage = 'Сталася помилка',
    this.isEmpty = false,
    this.emptyMessage = 'Немає даних',
    this.emptyIcon,
    this.onRetry,
    this.isSelected = false,
    this.header,
    this.footer,
    this.onTap,
    this.onLongPress,
    this.isLightTheme = false,
    this.padding,
    this.borderRadius,
    this.margin,
    this.elevationLevel = 2,
    this.isExpandable = false,
    this.expandableContent,
    this.expandLabel = 'Детальніше',
    this.collapseLabel = 'Згорнути',
    this.isSwipeable = false,
    this.onSwipeLeft,
    this.onSwipeRight,
    this.swipeThreshold = 80.0,
    this.onSelectedChanged,
    this.animationConfig = const AppCardAnimationConfig.standard,
    this.isDisabled = false,
    this.semanticLabel,
    this.clipContent = true,
    this.width,
    this.height,
  }) : variant = AppCardVariant.neon,
       gradientStart = null,
       gradientEnd = null,
       enableNeonPulse = true;

  /// Основний вміст картки.
  final Widget child;

  /// Візуальний стиль картки.
  final AppCardVariant variant;

  /// Позиція акцентної смужки.
  final AppCardAccent accent;

  /// Колір акцентної смужки. Якщо не задано — використовується accent кольори.
  final Color? accentColor;

  /// Кастомний початковий колір градієнта (тільки для variant=gradient).
  final Color? gradientStart;

  /// Кастомний кінцевий колір градієнта (тільки для variant=gradient).
  final Color? gradientEnd;

  /// Показувати shimmer-ефект завантаження.
  final bool isLoading;

  /// Показувати стан помилки.
  final bool hasError;

  /// Повідомлення про помилку для стану hasError.
  final String errorMessage;

  /// Показувати стан порожнього контенту.
  final bool isEmpty;

  /// Повідомлення для стану порожнього контенту.
  final String emptyMessage;

  /// Іконка для стану порожнього контенту.
  final IconData? emptyIcon;

  /// Зворотний виклик для повторної спроби при стані помилки.
  final VoidCallback? onRetry;

  /// Виділена стан — подсвічування рамкою вибору.
  final bool isSelected;

  /// Верхня секція картки (заголовок).
  final Widget? header;

  /// Нижня секція картки (підвал).
  final Widget? footer;

  /// Зворотний виклик при натисканні.
  final VoidCallback? onTap;

  /// Зворотний виклик при тривалому натисканні.
  final VoidCallback? onLongPress;

  /// Використовувати світлу тему кольорів.
  final bool isLightTheme;

  /// Кастомний внутрішній відступ. За замовчуванням Spacing.lg.
  final EdgeInsetsGeometry? padding;

  /// Кастомний радіус закруглення кутів.
  final double? borderRadius;

  /// Кастомний зовнішній відступ.
  final EdgeInsetsGeometry? margin;

  /// Рівень тіні (0-5). 0 — без тіні.
  final int elevationLevel;

  /// Чи картка розгортається при натисканні на секцію-підвал.
  final bool isExpandable;

  /// Додатковий вміст, що з'являється при розгортанні.
  final Widget? expandableContent;

  /// Текст мітки розгортання.
  final String expandLabel;

  /// Текст мітки згортання.
  final String collapseLabel;

  /// Чи картку можна свайпнути ліворуч/праворуч.
  final bool isSwipeable;

  /// Зворотний виклик при свайпі ліворуч.
  final VoidCallback? onSwipeLeft;

  /// Зворотний виклик при свайпі праворуч.
  final VoidCallback? onSwipeRight;

  /// Поріг свайпу в пікселях для активації дії.
  final double swipeThreshold;

  /// Зворотний виклик при зміні стану вибору.
  final ValueChanged<bool>? onSelectedChanged;

  /// Увімкнути пульсуючу неонову анімацію (тільки для variant=neon).
  final bool enableNeonPulse;

  /// Конфігурація анімацій для картки.
  final AppCardAnimationConfig animationConfig;

  /// Чи картка вимкнена та неінтерактивна.
  final bool isDisabled;

  /// Семантична мітка для екранних читачів.
  final String? semanticLabel;

  /// Чи обрізати контент за межами картки.
  final bool clipContent;

  /// Фіксована ширина картки.
  final double? width;

  /// Фіксована висота картки.
  final double? height;

  @override
  State<AppCard> createState() => _AppCardState();
}

class _AppCardState extends State<AppCard> {
  bool _isPressed = false;
  bool _isExpanded = false;
  double _swipeOffset = 0.0;

  /// Поточний ступінь розгортання для анімації (0.0 — згорнуто, 1.0 — розгорнуто).
  double _expandProgress = 0.0;

  /// Чи картка зараз інтерактивна.
  bool get _isInteractive =>
      !widget.isDisabled && !widget.isLoading && !widget.hasError && !widget.isEmpty;

  // ─── Color Getters ───────────────────────────────────────────────────

  /// Колір фону картки.
  ///
  /// Обирає між світлою та темною темою.
  Color get _cardColor =>
      widget.isLightTheme ? AppColorsMonitor.card : AppColorsPS5.card;

  /// Колір рамки картки.
  Color get _borderColor =>
      widget.isLightTheme ? AppColorsMonitor.border : AppColorsPS5.border;

  /// Колір акценту.
  Color get _accentColor =>
      widget.accentColor ??
      (widget.isLightTheme ? AppColorsMonitor.accent : AppColorsPS5.accent);

  /// Початковий колір градієнта.
  Color get _gradientStartColor =>
      widget.gradientStart ??
      (widget.isLightTheme
          ? AppColorsMonitor.gradientStart
          : AppColorsPS5.gradientStart);

  /// Кінцевий колір градієнта.
  Color get _gradientEndColor =>
      widget.gradientEnd ??
      (widget.isLightTheme
          ? AppColorsMonitor.gradientEnd
          : AppColorsPS5.gradientEnd);

  /// Колір помилки.
  Color get _errorColor =>
      widget.isLightTheme ? AppColorsMonitor.error : AppColorsPS5.error;

  /// Вторинний колір тексту.
  Color get _textSecondary =>
      widget.isLightTheme
          ? AppColorsMonitor.textSecondary
          : AppColorsPS5.textSecondary;

  /// Основний колір тексту.
  Color get _textPrimary =>
      widget.isLightTheme
          ? AppColorsMonitor.textPrimary
          : AppColorsPS5.textPrimary;

  /// Колір підказок.
  Color get _textHint =>
      widget.isLightTheme
          ? AppColorsMonitor.textHint
          : AppColorsPS5.textHint;

  /// Список тіней для картки.
  ///
  /// Обчислюється на основі [elevationLevel].
  List<BoxShadow> get _shadows =>
      AppShadows.dynamicElevation(widget.elevationLevel);

  // ─── Additional Computed Properties ──────────────────────────────────

  /// Чи картка має хоча б один обробник жесту.
  bool get _hasAnyGestureCallback =>
      widget.onTap != null ||
      widget.onLongPress != null ||
      widget.onSwipeLeft != null ||
      widget.onSwipeRight != null ||
      widget.onSelectedChanged != null ||
      widget.isExpandable;

  /// Прогрес свайпу у діапазоні 0.0–1.0.
  double get _swipeProgress =>
      (_swipeOffset.abs() / (widget.swipeThreshold * 1.5)).clamp(0.0, 1.0);

  /// Напрямок свайпу.
  _SwipeDirection get _swipeDirection {
    if (_swipeOffset < 0) return _SwipeDirection.left;
    if (_swipeOffset > 0) return _SwipeDirection.right;
    return _SwipeDirection.none;
  }

  /// Ефективна непрозорість картки (зменшується при вимкненому стані).
  double get _effectiveOpacity =>
      widget.isDisabled ? 0.6 : 1.0;

  /// Ефективний border-radius як число.
  double get _effectiveBorderRadiusValue =>
      widget.borderRadius ?? Radii.lg;

  /// Чи картка має секції header або footer.
  bool get _hasSections =>
      widget.header != null || widget.footer != null || widget.isExpandable;

  /// Чи варіант картки використовує backdrop-filter (для ClipRect).
  bool get _requiresBackdropFilter =>
      widget.variant == AppCardVariant.glassmorphism ||
      widget.variant == AppCardVariant.frosted;

  /// Кількість секцій контенту картки.
  int get _sectionCount {
    int count = 1; // body
    if (widget.header != null) count++;
    if (widget.footer != null) count++;
    if (widget.isExpandable) count++;
    return count;
  }

  /// Чи картка відображає анімацію неонового пульсу.
  bool get _shouldAnimateNeonPulse =>
      widget.enableNeonPulse && widget.variant == AppCardVariant.neon;

  // ─── Theme-Aware Color Resolution ────────────────────────────────────

  /// Обирає колір між світлою та темною темою.
  ///
  /// [lightColor] — колір для світлої теми.
  /// [darkColor] — колір для темної теми.
  Color _resolveThemeColor(Color lightColor, Color darkColor) =>
      widget.isLightTheme ? lightColor : darkColor;

  /// Обчислює кольори градієнта з врахуванням кастомних значень.
  ///
  /// Повертає пару (початковий, кінцевий).
  (Color start, Color end) _resolveGradientColors() => (
        widget.gradientStart ??
            _resolveThemeColor(
              AppColorsMonitor.gradientStart,
              AppColorsPS5.gradientStart,
            ),
        widget.gradientEnd ??
            _resolveThemeColor(
              AppColorsMonitor.gradientEnd,
              AppColorsPS5.gradientEnd,
            ),
      );

  /// Обчислює загальну непрозорість фону для translucent варіантів.
  double _computeBackgroundOpacity() {
    switch (widget.variant) {
      case AppCardVariant.elevated:
      case AppCardVariant.outlined:
        return 1.0;
      case AppCardVariant.glassmorphism:
        return 0.4;
      case AppCardVariant.gradient:
        return 1.0;
      case AppCardVariant.frosted:
        return 0.25;
      case AppCardVariant.neon:
        return 0.6;
    }
  }

  /// Обчислює ширину акцентної смужки залежно від розміру картки.
  double _computeAccentWidth(double cardWidth) {
    const maxWidth = 6.0;
    const minWidth = 3.0;
    final computed = cardWidth * 0.01;
    return computed.clamp(minWidth, maxWidth);
  }

  // ─── Layout Computation ──────────────────────────────────────────────

  /// Обчислює BoxConstraints для контенту картки.
  BoxConstraints _computeContentConstraints() {
    return BoxConstraints(
      minWidth: widget.width ?? 0,
      maxWidth: widget.width ?? double.infinity,
      minHeight: 0,
      maxHeight: widget.height ?? double.infinity,
    );
  }

  /// Обчислює ефективний відступ для секцій header/footer.
  EdgeInsets _computeSectionPadding() {
    final base = widget.padding ?? const EdgeInsets.all(Spacing.lg);
    if (base is EdgeInsets) {
      return EdgeInsets.only(
        left: base.left,
        right: base.right,
        top: Spacing.lg,
        bottom: Spacing.xs,
      );
    }
    return const EdgeInsets.fromLTRB(Spacing.lg, Spacing.lg, Spacing.lg, Spacing.xs);
  }

  /// Обчислює максимальну висоту розгортання.
  double _computeExpandedMaxHeight() {
    return _sectionCount * 200.0;
  }

  // ─── State Management ─────────────────────────────────────────────────

  /// Визначає поточний стан картки.
  AppCardState get _currentState {
    if (widget.isDisabled) return AppCardState.disabled;
    if (widget.isLoading) return AppCardState.loading;
    if (widget.hasError) return AppCardState.error;
    if (widget.isEmpty) return AppCardState.empty;
    return AppCardState.normal;
  }

  /// Обчислює ефективний рівень тіні.
  ///
  /// Повертає 0 для вимкнених карток, translucent варіантів або коли
  /// картка натиснута.
  int _computeEffectiveElevation() {
    if (widget.isDisabled) return 0;
    if (widget.variant.isTranslucent && _isPressed) return 0;
    if (_isPressed) return (widget.elevationLevel - 1).clamp(0, 5);
    return widget.elevationLevel;
  }

  // ─── Lifecycle ────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    AppCardDebugConfig.log('initState', tag: 'lifecycle');
  }

  @override
  void didUpdateWidget(covariant AppCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isSelected != widget.isSelected) {
      AppCardDebugConfig.log(
        'isSelected changed: ${oldWidget.isSelected} → ${widget.isSelected}',
        tag: 'state',
      );
    }
    if (oldWidget.isLoading != widget.isLoading) {
      AppCardDebugConfig.log(
        'isLoading changed: ${oldWidget.isLoading} → ${widget.isLoading}',
        tag: 'state',
      );
    }
  }

  // ─── Swipe Handling ───────────────────────────────────────────────────

  /// Обробляє горизонтальне свайп-жест.
  ///
  /// [details] — деталі жесту для обчислення напрямку.
  void _handleHorizontalDragUpdate(DragUpdateDetails details) {
    if (!widget.isSwipeable) return;
    setState(() {
      _swipeOffset = (_swipeOffset + details.delta.dx)
          .clamp(-widget.swipeThreshold * 1.5, widget.swipeThreshold * 1.5);
    });
  }

  /// Обробляє завершення горизонтального свайпу.
  ///
  /// Перевіряє поріг та викликає відповідний callback.
  void _handleHorizontalDragEnd(DragEndDetails details) {
    if (!widget.isSwipeable) return;

    final exceededThreshold = _swipeOffset.abs() > widget.swipeThreshold;

    if (exceededThreshold) {
      if (_swipeOffset < 0 && widget.onSwipeLeft != null) {
        AppCardDebugConfig.log('Swipe left detected', tag: 'gesture');
        widget.onSwipeLeft!();
      } else if (_swipeOffset > 0 && widget.onSwipeRight != null) {
        AppCardDebugConfig.log('Swipe right detected', tag: 'gesture');
        widget.onSwipeRight!();
      }
    }

    // Повернути на місце з анімацією
    setState(() => _swipeOffset = 0.0);
  }

  /// Обробляє вибір картки при довгому натисканні.
  ///
  /// Змінює стан вибору та викликає callback.
  void _handleSelectionToggle() {
    final newValue = !widget.isSelected;
    widget.onSelectedChanged?.call(newValue);
    AppCardDebugConfig.log(
      'Selection toggled: $newValue',
      tag: 'selection',
    );
  }

  /// Обробляє розгортання/згортання контенту.
  void _handleExpandToggle() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
    AppCardDebugConfig.log(
      'Expand toggled: $_isExpanded',
      tag: 'expand',
    );
  }

  // ─── Validation ───────────────────────────────────────────────────────

  /// Перевіряє коректність конфігурації картки.
  ///
  /// Генерує попередження у debug-режимі при некоректних комбінаціях.
  void _validateConfiguration() {
    assert(
      widget.elevationLevel >= 0 && widget.elevationLevel <= 5,
      'elevationLevel must be between 0 and 5, got ${widget.elevationLevel}',
    );
    assert(
      widget.swipeThreshold > 0,
      'swipeThreshold must be positive, got ${widget.swipeThreshold}',
    );

    if (widget.isDisabled && widget.onTap != null) {
      AppCardDebugConfig.log(
        'Warning: onTap is set but card is disabled',
        tag: 'validation',
      );
    }

    if (widget.isExpandable && widget.expandableContent == null) {
      AppCardDebugConfig.log(
        'Warning: isExpandable is true but expandableContent is null',
        tag: 'validation',
      );
    }

    _validateGestureConfiguration();
    _validateVariantConsistency();
    _validateDimensions();
  }

  /// Перевіряє коректність конфігурації жестів.
  void _validateGestureConfiguration() {
    if (widget.isSwipeable && widget.isDisabled) {
      AppCardDebugConfig.log(
        'Warning: isSwipeable is true but card is disabled',
        tag: 'validation',
      );
    }

    if (widget.onSwipeLeft != null && !widget.isSwipeable) {
      AppCardDebugConfig.log(
        'Warning: onSwipeLeft is set but isSwipeable is false',
        tag: 'validation',
      );
    }

    if (widget.onSwipeRight != null && !widget.isSwipeable) {
      AppCardDebugConfig.log(
        'Warning: onSwipeRight is set but isSwipeable is false',
        tag: 'validation',
      );
    }

    if (widget.onSelectedChanged != null && widget.onLongPress != null) {
      AppCardDebugConfig.log(
        'Warning: both onSelectedChanged and onLongPress are set; '
        'onLongPress will take precedence',
        tag: 'validation',
      );
    }
  }

  /// Перевіряє consistency між variant та іншими параметрами.
  void _validateVariantConsistency() {
    if (widget.variant == AppCardVariant.gradient &&
        widget.gradientStart == null &&
        widget.gradientEnd == null) {
      // Це нормальна ситуація — будуть використані дефолтні кольори.
      // Логуємо тільки в verbose-режимі.
      AppCardDebugConfig.log(
        'Info: gradient variant using default gradient colors',
        tag: 'validation',
      );
    }

    if (widget.variant == AppCardVariant.outlined &&
        widget.elevationLevel > 0) {
      AppCardDebugConfig.log(
        'Warning: outlined variant with elevation > 0; '
        'elevation will be ignored for outlined style',
        tag: 'validation',
      );
    }

    if (widget.enableNeonPulse && widget.variant != AppCardVariant.neon) {
      AppCardDebugConfig.log(
        'Warning: enableNeonPulse is true but variant is not neon; '
        'pulse animation will not be applied',
        tag: 'validation',
      );
    }
  }

  /// Перевіряє коректність розмірів картки.
  void _validateDimensions() {
    if (widget.width != null && widget.width! <= 0) {
      assert(false, 'Card width must be positive, got ${widget.width}');
    }
    if (widget.height != null && widget.height! <= 0) {
      assert(false, 'Card height must be positive, got ${widget.height}');
    }
    if (widget.borderRadius != null && widget.borderRadius! < 0) {
      assert(
        false,
        'borderRadius must be non-negative, got ${widget.borderRadius}',
      );
    }
  }

  // ─── Build ───────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    _validateConfiguration();

    final borderRadiusValue = widget.borderRadius ?? Radii.lg;
    final effectiveRadius = BorderRadius.circular(borderRadiusValue);

    // ── Loading State ──
    if (widget.isLoading) {
      return _buildLoadingCard(effectiveRadius);
    }

    // ── Error State ──
    if (widget.hasError) {
      return _buildErrorCard(effectiveRadius);
    }

    // ── Empty State ──
    if (widget.isEmpty) {
      return _buildEmptyCard(effectiveRadius);
    }

    // ── Normal Card ──
    return Semantics(
      label: widget.semanticLabel,
      button: widget.onTap != null,
      selected: widget.isSelected,
      enabled: _isInteractive,
      child: GestureDetector(
        onTapDown: _isInteractive && widget.onTap != null
            ? (_) => setState(() => _isPressed = true)
            : null,
        onTapUp: _isInteractive && widget.onTap != null
            ? (_) => setState(() => _isPressed = false)
            : null,
        onTapCancel: _isInteractive && widget.onTap != null
            ? () => setState(() => _isPressed = false)
            : null,
        onTap: _isInteractive
            ? (widget.onTap ?? (widget.isExpandable ? _handleExpandToggle : null))
            : null,
        onLongPress: _isInteractive
            ? (widget.onLongPress ?? (widget.onSelectedChanged != null ? _handleSelectionToggle : null))
            : null,
        onHorizontalDragUpdate: _handleHorizontalDragUpdate,
        onHorizontalDragEnd: _handleHorizontalDragEnd,
        child: AnimatedScale(
          scale: _isPressed && !widget.isDisabled
              ? widget.animationConfig.pressScale
              : 1.0,
          duration: widget.animationConfig.pressDuration,
          curve: widget.animationConfig.pressCurve,
          child: AnimatedContainer(
            duration: widget.animationConfig.expandDuration,
            curve: widget.animationConfig.expandCurve,
            margin: widget.margin,
            clipBehavior: widget.clipContent ? Clip.antiAlias : Clip.none,
            width: widget.width,
            height: widget.height,
            transform: _isSwipeable
                ? Matrix4.translationValues(_swipeOffset, 0, 0)
                : Matrix4.identity(),
            decoration: _buildDecoration(effectiveRadius),
            child: _buildAccentOverlay(effectiveRadius),
          ),
        ),
      ).animate().fadeIn(
        duration: widget.animationConfig.fadeInDuration,
        curve: widget.animationConfig.fadeInCurve,
      ),
    );
  }

  // ─── Decoration Builder ──────────────────────────────────────────────

  /// Будує декорацію [BoxDecoration] для картки.
  ///
  /// [radius] — радіус закруглення кутів.
  /// Вибирає стиль залежно від [variant].
  BoxDecoration _buildDecoration(BorderRadius radius) {
    final border = _buildBorder(radius);

    switch (widget.variant) {
      case AppCardVariant.elevated:
        return BoxDecoration(
          color: _cardColor,
          borderRadius: radius,
          boxShadow: AppShadows.dynamicElevation(
            _computeEffectiveElevation(),
          ),
          border: border,
        );

      case AppCardVariant.outlined:
        return BoxDecoration(
          color: widget.isDisabled
              ? _cardColor.withOpacity(0.5)
              : Colors.transparent,
          borderRadius: radius,
          border: Border.all(
            color: widget.isSelected
                ? _accentColor
                : (widget.isDisabled
                    ? _borderColor.withOpacity(0.5)
                    : _borderColor),
            width: widget.isSelected ? 2.0 : 1.5,
          ),
        );

      case AppCardVariant.glassmorphism:
        return BoxDecoration(
          color: _cardColor.withOpacity(0.4),
          borderRadius: radius,
          border: border,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              spreadRadius: 0,
            ),
          ],
        );

      case AppCardVariant.gradient:
        return BoxDecoration(
          gradient: LinearGradient(
            colors: [_gradientStartColor, _gradientEndColor],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: radius,
          boxShadow: AppShadows.glow(_gradientStartColor),
          border: border,
        );

      case AppCardVariant.frosted:
        return BoxDecoration(
          color: _cardColor.withOpacity(0.25),
          borderRadius: radius,
          border: Border.all(
            color: _borderColor.withOpacity(0.3),
            width: 0.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 30,
              spreadRadius: 0,
            ),
          ],
        );

      case AppCardVariant.neon:
        return BoxDecoration(
          color: _cardColor.withOpacity(0.6),
          borderRadius: radius,
          border: Border.all(
            color: widget.isSelected ? _accentColor : _borderColor,
            width: 2.0,
          ),
          boxShadow: [
            BoxShadow(
              color: _accentColor.withOpacity(0.35),
              blurRadius: 24,
              spreadRadius: 2,
            ),
            BoxShadow(
              color: _accentColor.withOpacity(0.15),
              blurRadius: 48,
              spreadRadius: 4,
            ),
          ],
        );
    }
  }

  /// Будує рамку для картки.
  ///
  /// Повертає null для outlined варіанту (обробляється окремо).
  Border? _buildBorder(BorderRadius radius) {
    if (widget.variant == AppCardVariant.outlined) return null;
    if (widget.isSelected) {
      return Border.all(color: _accentColor, width: 2);
    }
    if (widget.isDisabled) {
      return Border.all(color: _borderColor.withOpacity(0.3), width: 1);
    }
    return null;
  }

  // ─── Accent Overlay ──────────────────────────────────────────────────

  /// Будує накладку з акцентною смужкою та контентом картки.
  ///
  /// [radius] — радіус закруглення кутів.
  Widget _buildAccentOverlay(BorderRadius radius) {
    final content = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // ── Header Section ──
        if (widget.header != null) ...[
          Padding(
            padding: const EdgeInsets.only(
              left: Spacing.lg,
              right: Spacing.lg,
              top: Spacing.lg,
              bottom: Spacing.xs,
            ),
            child: DefaultTextStyle(
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: _textPrimary,
              ),
              child: widget.header!,
            ),
          ),
        ],
        // ── Body Section ──
        Flexible(
          child: Padding(
            padding: widget.padding ?? const EdgeInsets.all(Spacing.lg),
            child: widget.child,
          ),
        ),
        // ── Expandable Section ──
        if (widget.isExpandable && widget.expandableContent != null) ...[
          _buildExpandableSection(),
        ],
        // ── Footer Section ──
        if (widget.footer != null) ...[
          Padding(
            padding: const EdgeInsets.only(
              left: Spacing.lg,
              right: Spacing.lg,
              top: Spacing.xs,
              bottom: Spacing.lg,
            ),
            child: DefaultTextStyle(
              style: TextStyle(
                fontSize: 12,
                color: _textSecondary,
              ),
              child: widget.footer!,
            ),
          ),
        ],
      ],
    );

    // ── Debug Accent Indicators ──
    if (AppCardDebugConfig.showAccentIndicators &&
        widget.accent != AppCardAccent.none) {
      return Stack(
        children: [
          content,
          Positioned.fill(
            child: IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: radius,
                  border: Border.all(
                    color: Colors.red.withOpacity(0.3),
                    width: 2,
                    strokeAlign: BorderSide.strokeAlignOutside,
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    }

    if (widget.accent == AppCardAccent.none) return content;

    final accentBorder = _buildAccentBorder(radius);
    return Stack(
      children: [
        content,
        Positioned.fill(
          child: IgnorePointer(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: radius,
                border: accentBorder,
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Будує секцію розгортання.
  Widget _buildExpandableSection() {
    return AnimatedCrossFade(
      firstChild: const SizedBox.shrink(),
      secondChild: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Divider(color: _borderColor.withOpacity(0.5), height: 1),
          Padding(
            padding: const EdgeInsets.all(Spacing.lg),
            child: widget.expandableContent!,
          ),
        ],
      ),
      crossFadeState: _isExpanded
          ? CrossFadeState.showSecond
          : CrossFadeState.showFirst,
      duration: widget.animationConfig.expandDuration,
      sizeCurve: widget.animationConfig.expandCurve,
    );
  }

  /// Будує рамку акценту залежно від позиції.
  ///
  /// [radius] — радіус закруглення кутів.
  Border _buildAccentBorder(BorderRadius radius) {
    final side = BorderSide(color: _accentColor, width: 4);

    switch (widget.accent) {
      case AppCardAccent.none:
        return Border.none;
      case AppCardAccent.left:
        return Border(left: side);
      case AppCardAccent.right:
        return Border(right: side);
      case AppCardAccent.top:
        return Border(top: side);
      case AppCardAccent.bottom:
        return Border(bottom: side);
    }
  }

  // ─── Loading Card ────────────────────────────────────────────────────

  /// Будує картку у стані завантаження з shimmer-ефектом.
  ///
  /// [radius] — радіус закруглення кутів.
  Widget _buildLoadingCard(BorderRadius radius) {
    return Container(
      margin: widget.margin,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: radius,
        boxShadow: _shadows,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.header != null) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(
                Spacing.lg, Spacing.lg, Spacing.lg, 0,
              ),
              child: _buildShimmerLine(20.0, 1.0),
            ),
          ],
          Padding(
            padding: widget.padding ?? const EdgeInsets.all(Spacing.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(
                _calculateSkeletonLines(),
                (index) => Padding(
                  padding: const EdgeInsets.only(bottom: Spacing.sm),
                  child: _buildShimmerLine(
                    14.0,
                    1.0 - index * 0.15,
                  ),
                ),
              ),
            ),
          ),
        ],
      )
          .animate(onPlay: (c) => c.repeat())
          .shimmer(
            duration: widget.animationConfig.shimmerDuration,
            color: Colors.white.withOpacity(0.08),
          ),
    );
  }

  /// Будує рядок shimmer-скелета.
  ///
  /// [height] — висота рядка.
  /// [widthFactor] — коефіцієнт ширини (0.0–1.0).
  Widget _buildShimmerLine(double height, double widthFactor) {
    return Container(
      height: height,
      width: double.infinity * widthFactor.clamp(0.3, 1.0),
      decoration: BoxDecoration(
        color: _borderColor,
        borderRadius: BorderRadius.circular(Radii.xs),
      ),
    );
  }

  /// Обчислює кількість рядків skeleton-завантаження.
  ///
  /// Повертає 3 для карток без footer, 4 — з footer.
  int _calculateSkeletonLines() {
    if (widget.footer != null) return 4;
    if (widget.header != null) return 3;
    return 3;
  }

  // ─── Error Card ──────────────────────────────────────────────────────

  /// Будує картку у стані помилки з іконкою та повідомленням.
  ///
  /// [radius] — радіус закруглення кутів.
  Widget _buildErrorCard(BorderRadius radius) {
    return Container(
      margin: widget.margin,
      padding: widget.padding ?? const EdgeInsets.all(Spacing.lg),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: radius,
        border: Border.all(color: _errorColor, width: 1.5),
        boxShadow: AppShadows.errorGlow(),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(Spacing.sm),
                decoration: BoxDecoration(
                  color: _errorColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.error_outline_rounded,
                  color: _errorColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: Spacing.md),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Помилка завантаження',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: _textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.errorMessage,
                      style: TextStyle(
                        fontSize: 12,
                        color: _textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          // ── Retry Button ──
          if (widget.onRetry != null) ...[
            const SizedBox(height: Spacing.md),
            GestureDetector(
              onTap: widget.onRetry,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: Spacing.md,
                  vertical: Spacing.sm,
                ),
                decoration: BoxDecoration(
                  color: _errorColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(Radii.sm),
                  border: Border.all(
                    color: _errorColor.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.refresh_rounded,
                      color: _errorColor,
                      size: 16,
                    ),
                    const SizedBox(width: Spacing.xs),
                    Text(
                      'Спробувати знову',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: _errorColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    ).animate().shake(
      duration: widget.animationConfig.shakeDuration,
      h: widget.animationConfig.shakeH,
    );
  }

  // ─── Empty Card ──────────────────────────────────────────────────────

  /// Будує картку у стані порожнього контенту.
  ///
  /// [radius] — радіус закруглення кутів.
  Widget _buildEmptyCard(BorderRadius radius) {
    final emptyIcon = widget.emptyIcon ?? Icons.inbox_outlined;

    return Container(
      margin: widget.margin,
      padding: widget.padding ??
          const EdgeInsets.symmetric(
            horizontal: Spacing.lg,
            vertical: Spacing.xl,
          ),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: radius,
        border: Border.all(
          color: _borderColor.withOpacity(0.5),
          width: 1,
          strokeAlign: BorderSide.strokeAlignInside,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            emptyIcon,
            color: _textHint,
            size: 40,
          ),
          const SizedBox(height: Spacing.md),
          Text(
            widget.emptyMessage,
            style: TextStyle(
              fontSize: 14,
              color: _textSecondary,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ─── Utility Extensions ─────────────────────────────────────────────────────

/// Розширення для [AppCardVariant] з додатковими методами.
extension AppCardVariantExtension on AppCardVariant {
  /// Чи цей варіант підтримує налаштування gradientStart/gradientEnd.
  bool get supportsCustomGradient => this == AppCardVariant.gradient;

  /// Чи цей варіант підтримує налаштування elevationLevel.
  bool get supportsElevation => this == AppCardVariant.elevated;

  /// Повертає список усіх варіантів з їх назвами.
  static List<MapEntry<AppCardVariant, String>> get allWithName =>
      AppCardVariant.values
          .map((v) => MapEntry(v, v.label))
          .toList();
}

/// Розширення для [AppCardAccent] з додатковими методами.
extension AppCardAccentExtension on AppCardAccent {
  /// Чи цей варіант використовує вертикальну смужку.
  bool get isVertical =>
      this == AppCardAccent.left || this == AppCardAccent.right;

  /// Чи цей варіант використовує горизонтальну смужку.
  bool get isHorizontal =>
      this == AppCardAccent.top || this == AppCardAccent.bottom;
}

/// Розширення для [AppCardState] з додатковими методами.
extension AppCardStateExtension on AppCardState {
  /// Повертає опис поточного стану для Tooltip.
  String get tooltipMessage {
    switch (this) {
      case AppCardState.normal:
        return '';
      case AppCardState.loading:
        return 'Завантаження...';
      case AppCardState.error:
        return 'Помилка';
      case AppCardState.empty:
        return 'Немає даних';
      case AppCardState.disabled:
        return 'Недоступно';
    }
  }

  /// Чи цей стан є помилковим і потребує уваги користувача.
  bool get requiresUserAction =>
      this == AppCardState.error || this == AppCardState.empty;

  /// Чи в цьому стані картка відображає анімацію.
  bool get isAnimated =>
      this == AppCardState.loading || this == AppCardState.error;
}

// ─── Card Helpers ───────────────────────────────────────────────────────────

/// Допоміжні методи для роботи з [AppCard].
class AppCardHelpers {
  AppCardHelpers._();

  /// Створює стандартну картку з підтримкою різних станів.
  ///
  /// [child] — основний контент.
  /// [isLoading] — стан завантаження.
  /// [hasError] — стан помилки.
  /// [errorMessage] — повідомлення помилки.
  /// [isEmpty] — стан порожнього контенту.
  /// [onRetry] — callback для повторної спроби.
  /// [onTap] — callback при натисканні.
  /// [variant] — візуальний стиль.
  static Widget withStates({
    required Widget child,
    bool isLoading = false,
    bool hasError = false,
    String errorMessage = 'Сталася помилка',
    bool isEmpty = false,
    String emptyMessage = 'Немає даних',
    VoidCallback? onRetry,
    VoidCallback? onTap,
    AppCardVariant variant = AppCardVariant.elevated,
    bool isLightTheme = false,
  }) {
    return AppCard(
      variant: variant,
      child: child,
      isLoading: isLoading,
      hasError: hasError,
      errorMessage: errorMessage,
      isEmpty: isEmpty,
      emptyMessage: emptyMessage,
      onRetry: onRetry,
      onTap: onTap,
      isLightTheme: isLightTheme,
    );
  }

  /// Створює картку-обгортку з відступами.
  ///
  /// Зручно для обгортання контенту у списках.
  static Widget wrapper({
    required Widget child,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    AppCardVariant variant = AppCardVariant.elevated,
    bool isLightTheme = false,
  }) {
    return AppCard(
      variant: variant,
      child: child,
      padding: padding,
      margin: margin,
      isLightTheme: isLightTheme,
    );
  }

  /// Обчислює оптимальний рівень тіні залежно від контексту.
  ///
  /// [isHighlighted] — чи картка виділена.
  /// [isNested] — чи картка вкладена в іншу картку.
  static int optimalElevation({
    bool isHighlighted = false,
    bool isNested = false,
  }) {
    if (isNested) return isHighlighted ? 2 : 0;
    return isHighlighted ? 4 : 2;
  }

  /// Обчислює максимальну ширину картки для адаптивного layout.
  ///
  /// [screenWidth] — ширина екрана.
  /// [maxFraction] — максимальна частка ширини екрана (0.0–1.0).
  static double maxCardWidth(double screenWidth, {double maxFraction = 0.9}) {
    return (screenWidth * maxFraction).clamp(300.0, 600.0);
  }

  /// Створює картку з автоматичним визначенням стану за прапорцями.
  ///
  /// Зручно для використання з BLoC/Cubit, де стан передається прапорцями.
  static AppCard fromStateFlags({
    required Widget child,
    bool isDisabled = false,
    bool isLoading = false,
    bool hasError = false,
    String errorMessage = 'Сталася помилка',
    bool isEmpty = false,
    String emptyMessage = 'Немає даних',
    VoidCallback? onRetry,
    VoidCallback? onTap,
    AppCardVariant variant = AppCardVariant.elevated,
    bool isLightTheme = false,
  }) {
    return AppCard(
      variant: variant,
      child: child,
      isDisabled: isDisabled,
      isLoading: isLoading,
      hasError: hasError,
      errorMessage: errorMessage,
      isEmpty: isEmpty,
      emptyMessage: emptyMessage,
      onRetry: onRetry,
      onTap: onTap,
      isLightTheme: isLightTheme,
    );
  }
}

// ─── Swipe Direction ────────────────────────────────────────────────────────

/// Напрямок свайпу для внутрішнього використання.
enum _SwipeDirection {
  /// Немає свайпу.
  none,

  /// Свайп ліворуч.
  left,

  /// Свайп праворуч.
  right;
}

// ─── Card Theme Data ────────────────────────────────────────────────────────

/// Тематичні дані для картки.
///
/// Зберігає повну палітру кольорів, тіней та типографіки
/// для конкретної теми (світла або темна).
class AppCardThemeData {
  /// Створює тематичні дані для картки.
  const AppCardThemeData({
    required this.cardColor,
    required this.borderColor,
    required this.accentColor,
    required this.textPrimary,
    required this.textSecondary,
    required this.textHint,
    required this.errorColor,
    required this.gradientStart,
    required this.gradientEnd,
    this.defaultElevation = 2,
    this.defaultBorderRadius = Radii.lg,
    this.accentWidth = 4.0,
    this.disabledOpacity = 0.6,
  });

  /// Створює тематичні дані для світлої теми (Monitor).
  factory AppCardThemeData.light() => const AppCardThemeData(
        cardColor: AppColorsMonitor.card,
        borderColor: AppColorsMonitor.border,
        accentColor: AppColorsMonitor.accent,
        textPrimary: AppColorsMonitor.textPrimary,
        textSecondary: AppColorsMonitor.textSecondary,
        textHint: AppColorsMonitor.textHint,
        errorColor: AppColorsMonitor.error,
        gradientStart: AppColorsMonitor.gradientStart,
        gradientEnd: AppColorsMonitor.gradientEnd,
      );

  /// Створює тематичні дані для темної теми (PS5).
  factory AppCardThemeData.dark() => const AppCardThemeData(
        cardColor: AppColorsPS5.card,
        borderColor: AppColorsPS5.border,
        accentColor: AppColorsPS5.accent,
        textPrimary: AppColorsPS5.textPrimary,
        textSecondary: AppColorsPS5.textSecondary,
        textHint: AppColorsPS5.textHint,
        errorColor: AppColorsPS5.error,
        gradientStart: AppColorsPS5.gradientStart,
        gradientEnd: AppColorsPS5.gradientEnd,
        defaultElevation: 2,
        disabledOpacity: 0.6,
      );

  /// Колір фону картки.
  final Color cardColor;

  /// Колір рамки картки.
  final Color borderColor;

  /// Колір акценту.
  final Color accentColor;

  /// Основний колір тексту.
  final Color textPrimary;

  /// Вторинний колір тексту.
  final Color textSecondary;

  /// Колір підказок.
  final Color textHint;

  /// Колір помилки.
  final Color errorColor;

  /// Початковий колір градієнта.
  final Color gradientStart;

  /// Кінцевий колір градієнта.
  final Color gradientEnd;

  /// Рівень тіні за замовчуванням.
  final int defaultElevation;

  /// Радіус закруглення за замовчуванням.
  final double defaultBorderRadius;

  /// Ширина акцентної смужки.
  final double accentWidth;

  /// Непрозорість при вимкненому стані.
  final double disabledOpacity;

  /// Створює копію з перезаписаними полями.
  AppCardThemeData copyWith({
    Color? cardColor,
    Color? borderColor,
    Color? accentColor,
    Color? textPrimary,
    Color? textSecondary,
    Color? textHint,
    Color? errorColor,
    Color? gradientStart,
    Color? gradientEnd,
    int? defaultElevation,
    double? defaultBorderRadius,
    double? accentWidth,
    double? disabledOpacity,
  }) {
    return AppCardThemeData(
      cardColor: cardColor ?? this.cardColor,
      borderColor: borderColor ?? this.borderColor,
      accentColor: accentColor ?? this.accentColor,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textHint: textHint ?? this.textHint,
      errorColor: errorColor ?? this.errorColor,
      gradientStart: gradientStart ?? this.gradientStart,
      gradientEnd: gradientEnd ?? this.gradientEnd,
      defaultElevation: defaultElevation ?? this.defaultElevation,
      defaultBorderRadius: defaultBorderRadius ?? this.defaultBorderRadius,
      accentWidth: accentWidth ?? this.accentWidth,
      disabledOpacity: disabledOpacity ?? this.disabledOpacity,
    );
  }

  /// Інтерполює між двома темами.
  AppCardThemeData lerp(AppCardThemeData other, double t) {
    return AppCardThemeData(
      cardColor: Color.lerp(cardColor, other.cardColor, t)!,
      borderColor: Color.lerp(borderColor, other.borderColor, t)!,
      accentColor: Color.lerp(accentColor, other.accentColor, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textHint: Color.lerp(textHint, other.textHint, t)!,
      errorColor: Color.lerp(errorColor, other.errorColor, t)!,
      gradientStart: Color.lerp(gradientStart, other.gradientStart, t)!,
      gradientEnd: Color.lerp(gradientEnd, other.gradientEnd, t)!,
      defaultElevation:
          (defaultElevation + (other.defaultElevation - defaultElevation) * t)
              .round()
              .clamp(0, 5),
      defaultBorderRadius:
          defaultBorderRadius + (other.defaultBorderRadius - defaultBorderRadius) * t,
      disabledOpacity:
          disabledOpacity + (other.disabledOpacity - disabledOpacity) * t,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AppCardThemeData &&
        other.cardColor == cardColor &&
        other.borderColor == borderColor &&
        other.accentColor == accentColor &&
        other.textPrimary == textPrimary &&
        other.textSecondary == textSecondary &&
        other.textHint == textHint &&
        other.errorColor == errorColor &&
        other.gradientStart == gradientStart &&
        other.gradientEnd == gradientEnd;
  }

  @override
  int get hashCode => Object.hash(
        cardColor,
        borderColor,
        accentColor,
        textPrimary,
        textSecondary,
        textHint,
        errorColor,
        gradientStart,
        gradientEnd,
      );
}

// ─── Card Layout Metrics ────────────────────────────────────────────────────

/// Метрики layout для [AppCard].
///
/// Надає предобчислені значення розмірів для швидкого доступу
/// під час build без повторних обчислень.
class AppCardLayoutMetrics {
  AppCardLayoutMetrics._();

  /// Стандартна висота секції header.
  static const double headerMinHeight = 48.0;

  /// Стандартна висота секції footer.
  static const double footerMinHeight = 36.0;

  /// Стандартна висота кнопки retry у error-стані.
  static const double retryButtonHeight = 36.0;

  /// Стандартна висота іконки empty-стану.
  static const double emptyIconSize = 40.0;

  /// Ширина акцентної смужки за замовчуванням.
  static const double defaultAccentWidth = 4.0;

  /// Мінімальна ширина акцентної смужки.
  static const double minAccentWidth = 2.0;

  /// Максимальна ширина акцентної смужки.
  static const double maxAccentWidth = 8.0;

  /// Мінімальна висота картки.
  static const double minHeight = 64.0;

  /// Мінімальна ширина картки.
  static const double minWidth = 120.0;

  /// Максимальний рівень тіні.
  static const int maxElevation = 5;

  /// Мінімальний рівень тіні.
  static const int minElevation = 0;

  /// Максимальна кількість skeleton-рядків для shimmer.
  static const int maxSkeletonLines = 8;

  /// Мінімальна кількість skeleton-рядків для shimmer.
  static const int minSkeletonLines = 1;

  /// Максимальний поріг свайпу.
  static const double maxSwipeThreshold = 200.0;

  /// Мінімальний поріг свайпу.
  static const double minSwipeThreshold = 20.0;

  /// Обчислює висоту картки з усіма секціями.
  ///
  /// [hasHeader] — чи є секція header.
  /// [hasFooter] — чи є секція footer.
  /// [isExpanded] — чи розгорнуто додатковий контент.
  /// [bodyHeight] — висота основного контенту.
  /// [expandHeight] — висота розгортання (якщо застосовно).
  static double estimateTotalHeight({
    bool hasHeader = false,
    bool hasFooter = false,
    bool isExpanded = false,
    double bodyHeight = 100.0,
    double expandHeight = 150.0,
    double padding = Spacing.lg,
  }) {
    double total = padding * 2 + bodyHeight;
    if (hasHeader) total += headerMinHeight;
    if (hasFooter) total += footerMinHeight;
    if (isExpanded) total += expandHeight + padding;
    return total;
  }

  /// Обчислює оптимальний розмір картки для заданого контексту.
  ///
  /// [availableWidth] — доступна ширина.
  /// [availableHeight] — доступна висота.
  /// [contentLines] — орієнтовна кількість рядків контенту.
  static Size optimalSize({
    double availableWidth = 400.0,
    double availableHeight = 200.0,
    int contentLines = 3,
  }) {
    final width = availableWidth.clamp(minWidth, 600.0);
    final lineEstimate = contentLines * 20.0 + Spacing.lg;
    final height = lineEstimate.clamp(minHeight, availableHeight);
    return Size(width, height);
  }

  /// Перевіряє, чи рівень тіні знаходиться в допустимому діапазоні.
  static bool isValidElevation(int level) =>
      level >= minElevation && level <= maxElevation;

  /// Перевіряє, чи поріг свайпу знаходиться в допустимому діапазоні.
  static bool isValidSwipeThreshold(double threshold) =>
      threshold >= minSwipeThreshold && threshold <= maxSwipeThreshold;

  /// Перевіряє, чи кількість skeleton-рядків знаходиться в допустимому діапазоні.
  static bool isValidSkeletonLineCount(int count) =>
      count >= minSkeletonLines && count <= maxSkeletonLines;
}

// ─── Card Preset Builder ────────────────────────────────────────────────────

/// Збірка готових пресетів для швидкого створення карток.
class AppCardPresets {
  AppCardPresets._();

  /// Створює інформаційну картку з іконкою, заголовком та описом.
  static AppCard info({
    required String title,
    required String description,
    required IconData icon,
    VoidCallback? onTap,
    AppCardVariant variant = AppCardVariant.elevated,
    bool isLightTheme = false,
  }) {
    return AppCard(
      variant: variant,
      isLightTheme: isLightTheme,
      header: Row(
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: Spacing.sm),
          Expanded(
            child: Text(title, overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
      child: Text(description),
      onTap: onTap,
    );
  }

  /// Створює картку-дію з іконкою, міткою та підзаголовком.
  static AppCard action({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
    String? subtitle,
    AppCardVariant variant = AppCardVariant.elevated,
    bool isLightTheme = false,
  }) {
    return AppCard(
      variant: variant,
      isLightTheme: isLightTheme,
      child: Row(
        children: [
          Icon(icon, size: 28),
          const SizedBox(width: Spacing.md),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                if (subtitle != null)
                  Text(subtitle, style: const TextStyle(fontSize: 12)),
              ],
            ),
          ),
          Icon(Icons.chevron_right, size: 20),
        ],
      ),
      onTap: onTap,
    );
  }

  /// Створює картку статистики з числовим значенням.
  static AppCard stat({
    required String label,
    required String value,
    IconData? icon,
    Color? valueColor,
    AppCardVariant variant = AppCardVariant.elevated,
    bool isLightTheme = false,
  }) {
    return AppCard(
      variant: variant,
      isLightTheme: isLightTheme,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null)
            Icon(icon, size: 24),
          const SizedBox(height: Spacing.sm),
          Text(
            value,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: valueColor,
            ),
          ),
          const SizedBox(height: Spacing.xs),
          Text(
            label,
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }

  /// Створює картку налаштування з перемикачем.
  static AppCard setting({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    IconData? icon,
    AppCardVariant variant = AppCardVariant.elevated,
    bool isLightTheme = false,
  }) {
    return AppCard(
      variant: variant,
      isLightTheme: isLightTheme,
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, size: 24),
            const SizedBox(width: Spacing.md),
          ],
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                Text(subtitle, style: const TextStyle(fontSize: 12)),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
