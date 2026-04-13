import 'package:flutter/material.dart';

/// Система типографіки додатку Nexora.
///
/// Містить повний набір текстових стилів для всіх компонентів UI,
/// включаючи display, heading, body, label, button, mono стилі,
/// а також допоміжні методи для створення темозалежних стилів,
/// адаптивного масштабування та форматування числових значень.
class AppTypography {
  AppTypography._();

  // ─── Шрифти ────────────────────────────────────────────────────────

  /// Основний шрифт додатку.
  static const String fontFamily = 'Inter';

  /// Моноширинний шрифт для чисел та коду.
  static const String monoFontFamily = 'JetBrainsMono';

  // ─── Display ───────────────────────────────────────────────────────

  /// Display великий — для головних заголовків екранів.
  static const TextStyle displayLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 32,
    fontWeight: FontWeight.w700,
    height: 1.25,
    letterSpacing: -0.5,
  );

  /// Display середній — для проміжних заголовків.
  static const TextStyle displayMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 28,
    fontWeight: FontWeight.w700,
    height: 1.3,
    letterSpacing: -0.3,
  );

  /// Display малий — для невеликих display-заголовків.
  static const TextStyle displaySmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 24,
    fontWeight: FontWeight.w600,
    height: 1.3,
  );

  /// Display компактний — для обмеженого простору.
  static const TextStyle displayCompact = TextStyle(
    fontFamily: fontFamily,
    fontSize: 20,
    fontWeight: FontWeight.w700,
    height: 1.3,
    letterSpacing: -0.2,
  );

  /// Display мініатюрний — для дуже компактних заголовків.
  static const TextStyle displayMini = TextStyle(
    fontFamily: fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w700,
    height: 1.3,
    letterSpacing: -0.1,
  );

  // ─── Headings ──────────────────────────────────────────────────────

  /// Заголовок 1 — для основних секцій.
  static const TextStyle heading1 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 22,
    fontWeight: FontWeight.w600,
    height: 1.35,
  );

  /// Заголовок 2 — для підсекцій.
  static const TextStyle heading2 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.4,
  );

  /// Заголовок 3 — для дрібних секцій.
  static const TextStyle heading3 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.4,
  );

  /// Заголовок 4 — для підзаголовків карток.
  static const TextStyle heading4 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.4,
  );

  /// Заголовок 5 — для найдрібніших підзаголовків.
  static const TextStyle heading5 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w600,
    height: 1.4,
  );

  /// Заголовок 6 — для мікро-підзаголовків.
  static const TextStyle heading6 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 10,
    fontWeight: FontWeight.w600,
    height: 1.3,
    letterSpacing: 0.3,
  );

  // ─── Body ──────────────────────────────────────────────────────────

  /// Body великий — для основного контенту.
  static const TextStyle bodyLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );

  /// Body середній — для стандартного контенту.
  static const TextStyle bodyMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );

  /// Body малий — для другорядного контенту.
  static const TextStyle bodySmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );

  /// Body екстра малий — для підписів та приміток.
  static const TextStyle bodyExtraSmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 10,
    fontWeight: FontWeight.w400,
    height: 1.4,
  );

  /// Body напівжирний великий.
  static const TextStyle bodyLargeBold = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.5,
  );

  /// Body напівжирний середній.
  static const TextStyle bodyMediumBold = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.5,
  );

  /// Body напівжирний малий.
  static const TextStyle bodySmallBold = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w600,
    height: 1.5,
  );

  /// Body світлий — для менш виразного контенту.
  static const TextStyle bodyLight = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w300,
    height: 1.5,
  );

  /// Body напівжирний світлий — для ніжного акценту.
  static const TextStyle bodyLightBold = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.5,
  );

  // ─── Label ─────────────────────────────────────────────────────────

  /// Label великий — для міток форм та полів.
  static const TextStyle labelLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.3,
  );

  /// Label середній — для стандартних міток.
  static const TextStyle labelMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 1.3,
  );

  /// Label малий — для компактних міток.
  static const TextStyle labelSmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 10,
    fontWeight: FontWeight.w500,
    height: 1.3,
  );

  /// Label екстра малий — для мініатюрних міток.
  static const TextStyle labelExtraSmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 8,
    fontWeight: FontWeight.w500,
    height: 1.3,
  );

  // ─── Caption ───────────────────────────────────────────────────────

  /// Caption — для підписів зображень та описів.
  static const TextStyle caption = TextStyle(
    fontFamily: fontFamily,
    fontSize: 11,
    fontWeight: FontWeight.w400,
    height: 1.4,
    letterSpacing: 0.2,
  );

  /// Caption напівжирний — для акцентних підписів.
  static const TextStyle captionBold = TextStyle(
    fontFamily: fontFamily,
    fontSize: 11,
    fontWeight: FontWeight.w600,
    height: 1.4,
    letterSpacing: 0.2,
  );

  /// Caption малий — для компактних підписів.
  static const TextStyle captionSmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 9,
    fontWeight: FontWeight.w400,
    height: 1.3,
    letterSpacing: 0.1,
  );

  // ─── Overline ──────────────────────────────────────────────────────

  /// Overline — для тексту над заголовками (категорії, теги).
  static const TextStyle overline = TextStyle(
    fontFamily: fontFamily,
    fontSize: 10,
    fontWeight: FontWeight.w600,
    height: 1.6,
    letterSpacing: 1.5,
  );

  /// Overline середній — для менш виразних overline-текстів.
  static const TextStyle overlineMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 11,
    fontWeight: FontWeight.w500,
    height: 1.5,
    letterSpacing: 1.0,
  );

  /// Overline малий — для компактних overline-текстів.
  static const TextStyle overlineSmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 9,
    fontWeight: FontWeight.w600,
    height: 1.5,
    letterSpacing: 1.2,
  );

  // ─── Button ────────────────────────────────────────────────────────

  /// Button великий — для основних кнопок.
  static const TextStyle buttonLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.2,
    letterSpacing: 0.2,
  );

  /// Button середній — для стандартних кнопок.
  static const TextStyle buttonMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.2,
    letterSpacing: 0.1,
  );

  /// Button малий — для компактних кнопок.
  static const TextStyle buttonSmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w600,
    height: 1.2,
  );

  /// Button екстра малий — для міні-кнопок.
  static const TextStyle buttonExtraSmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 10,
    fontWeight: FontWeight.w600,
    height: 1.2,
    letterSpacing: 0.3,
  );

  /// Button напівжирний світлий — для другорядних кнопок.
  static const TextStyle buttonLight = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.2,
    letterSpacing: 0.1,
  );

  // ─── Mono (числа) ─────────────────────────────────────────────────

  /// Mono великий — для великих числових значень.
  static const TextStyle monoLarge = TextStyle(
    fontFamily: monoFontFamily,
    fontSize: 28,
    fontWeight: FontWeight.w700,
    height: 1.2,
  );

  /// Mono середній — для стандартних чисел.
  static const TextStyle monoMedium = TextStyle(
    fontFamily: monoFontFamily,
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 1.2,
  );

  /// Mono малий — для компактних чисел.
  static const TextStyle monoSmall = TextStyle(
    fontFamily: monoFontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.2,
  );

  /// Mono caption — для підписів з числами.
  static const TextStyle monoCaption = TextStyle(
    fontFamily: monoFontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 1.2,
  );

  /// Mono екстра малий — для мініатюрних чисел.
  static const TextStyle monoExtraSmall = TextStyle(
    fontFamily: monoFontFamily,
    fontSize: 10,
    fontWeight: FontWeight.w500,
    height: 1.2,
  );

  /// Mono напівжирний екстра малий — для акцентних мікро-чисел.
  static const TextStyle monoExtraSmallBold = TextStyle(
    fontFamily: monoFontFamily,
    fontSize: 10,
    fontWeight: FontWeight.w700,
    height: 1.2,
  );

  // ─── Валютні стилі ─────────────────────────────────────────────────

  /// Валютний стиль великий (з символом гривні).
  static const TextStyle currencyLarge = TextStyle(
    fontFamily: monoFontFamily,
    fontSize: 32,
    fontWeight: FontWeight.w700,
    height: 1.2,
  );

  /// Валютний стиль середній.
  static const TextStyle currencyMedium = TextStyle(
    fontFamily: monoFontFamily,
    fontSize: 22,
    fontWeight: FontWeight.w600,
    height: 1.2,
  );

  /// Валютний стиль малий.
  static const TextStyle currencySmall = TextStyle(
    fontFamily: monoFontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w500,
    height: 1.2,
  );

  /// Валютний стиль компактний (для списків).
  static const TextStyle currencyCompact = TextStyle(
    fontFamily: monoFontFamily,
    fontSize: 13,
    fontWeight: FontWeight.w600,
    height: 1.2,
  );

  /// Валютний стиль мініатюрний (для чіпів та бейджів).
  static const TextStyle currencyMini = TextStyle(
    fontFamily: monoFontFamily,
    fontSize: 11,
    fontWeight: FontWeight.w600,
    height: 1.2,
  );

  // ─── Стилі гейміфікації ───────────────────────────────────────────

  /// Стиль для XP-значень (золотий акцент).
  static const TextStyle xpLarge = TextStyle(
    fontFamily: monoFontFamily,
    fontSize: 24,
    fontWeight: FontWeight.w700,
    height: 1.2,
  );

  /// Стиль для XP середній.
  static const TextStyle xpMedium = TextStyle(
    fontFamily: monoFontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.2,
  );

  /// Стиль для кількості монет.
  static const TextStyle coinsMedium = TextStyle(
    fontFamily: monoFontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.2,
  );

  /// Стиль для монет малий.
  static const TextStyle coinsSmall = TextStyle(
    fontFamily: monoFontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w600,
    height: 1.2,
  );

  /// Стиль для серії (streak).
  static const TextStyle streakLarge = TextStyle(
    fontFamily: monoFontFamily,
    fontSize: 36,
    fontWeight: FontWeight.w800,
    height: 1.1,
  );

  /// Стиль для серії середній.
  static const TextStyle streakMedium = TextStyle(
    fontFamily: monoFontFamily,
    fontSize: 24,
    fontWeight: FontWeight.w700,
    height: 1.2,
  );

  /// Стиль для рівня.
  static const TextStyle levelBadge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w700,
    height: 1.2,
    letterSpacing: 1.0,
  );

  /// Стиль для рангу (лідерборд).
  static const TextStyle rankDisplay = TextStyle(
    fontFamily: monoFontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w800,
    height: 1.2,
    letterSpacing: 0.5,
  );

  // ─── Висота рядків (line height constants) ──────────────────────────

  /// Компактна висота рядка (для щільного тексту).
  static const double lineHeightTight = 1.1;

  /// Стандартна висота рядка.
  static const double lineHeightNormal = 1.4;

  /// Розширена висота рядка (для комфортного читання).
  static const double lineHeightRelaxed = 1.6;

  /// Дуже розширена висота рядка.
  static const double lineHeightLoose = 1.8;

  // ─── Міжлітерний інтервал ──────────────────────────────────────────

  /// Міжлітерний інтервал для щільного тексту.
  static const double letterSpacingTight = -0.5;

  /// Стандартний міжлітерний інтервал.
  static const double letterSpacingNormal = 0.0;

  /// Розширений міжлітерний інтервал (для overline).
  static const double letterSpacingWide = 1.5;

  /// Дуже розширений міжлітерний інтервал.
  static const double letterSpacingWider = 2.0;

  /// Ультра-розширений міжлітерний інтервал (для display).
  static const double letterSpacingUltraWide = 3.0;

  /// Міжлітерний інтервал для compact-тексту.
  static const double letterSpacingCompact = -0.2;

  // ─── Допоміжні методи ─────────────────────────────────────────────

  /// Створює копію стилю з новим кольором.
  ///
  /// [style] — базовий стиль.
  /// [color] — новий колір тексту.
  ///
  /// Приклад: `AppTypography.withColor(bodyMedium, Colors.red)`
  static TextStyle withColor(TextStyle style, Color color) {
    return style.copyWith(color: color);
  }

  /// Створює копію стилю з новою непрозорістю.
  ///
  /// [style] — базовий стиль.
  /// [opacity] — непрозорість від 0.0 до 1.0.
  static TextStyle withOpacity(TextStyle style, double opacity) {
    return style.copyWith(
      color: style.color?.withValues(alpha: opacity.clamp(0.0, 1.0)),
    );
  }

  /// Створює копію стилю з новим розміром шрифту.
  ///
  /// [style] — базовий стиль.
  /// [fontSize] — новий розмір шрифту.
  static TextStyle withSize(TextStyle style, double fontSize) {
    return style.copyWith(fontSize: fontSize);
  }

  /// Створює копію стилю з новою вагою.
  ///
  /// [style] — базовий стиль.
  /// [fontWeight] — нова вага шрифту.
  static TextStyle withWeight(TextStyle style, FontWeight fontWeight) {
    return style.copyWith(fontWeight: fontWeight);
  }

  /// Створює стиль для відсоткового значення.
  ///
  /// [fontSize] — розмір шрифту (за замовчуванням 14).
  /// [isBold] — чи використовувати напівжирний (за замовчуванням false).
  static TextStyle percentStyle({double fontSize = 14, bool isBold = false}) {
    return TextStyle(
      fontFamily: monoFontFamily,
      fontSize: fontSize,
      fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
      height: 1.2,
    );
  }

  /// Створює стиль для дати.
  ///
  /// [fontSize] — розмір шрифту (за замовчуванням 12).
  static TextStyle dateStyle({double fontSize = 12}) {
    return TextStyle(
      fontFamily: fontFamily,
      fontSize: fontSize,
      fontWeight: FontWeight.w400,
      height: 1.4,
      color: const Color(0xFF8888A0),
    );
  }

  /// Створює стиль для тривалості (хвилини, дні).
  ///
  /// [fontSize] — розмір шрифту (за замовчуванням 12).
  static TextStyle durationStyle({double fontSize = 12}) {
    return TextStyle(
      fontFamily: monoFontFamily,
      fontSize: fontSize,
      fontWeight: FontWeight.w500,
      height: 1.3,
    );
  }

  /// Масштабує розмір шрифту стилю відносно ширини екрана.
  ///
  /// [style] — базовий стиль.
  /// [screenWidth] — ширина екрана.
  /// [baseWidth] — базова ширина для масштабування (за замовчуванням 375).
  ///
  /// Приклад: `AppTypography.scaleForScreen(displayLarge, 414)`
  static TextStyle scaleForScreen(
    TextStyle style,
    double screenWidth, {
    double baseWidth = 375,
  }) {
    final scale = (screenWidth / baseWidth).clamp(0.85, 1.2);
    return style.copyWith(fontSize: (style.fontSize ?? 14) * scale);
  }

  /// Масштабує розмір шрифту стилю з використанням MediaQuery.
  ///
  /// Зручний метод для використання в білд-методах.
  static TextStyle scaleForContext(
    BuildContext context,
    TextStyle style, {
    double baseWidth = 375,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    return scaleForScreen(style, screenWidth, baseWidth: baseWidth);
  }

  /// Повертає адаптивний розмір шрифту для тексту залежно від довжини.
  ///
  /// [text] — текст для аналізу.
  /// [baseSize] — базовий розмір.
  /// [maxLines] — максимальна кількість рядків.
  /// [maxWidth] — максимальна ширина в пікселях.
  ///
  /// Зменшує розмір, якщо текст не вміщується у вказану ширину.
  static double adaptiveFontSize({
    required String text,
    required double baseSize,
    int maxLines = 1,
    double maxWidth = 300,
  }) {
    // Приблизна оцінка: 1 символ ≈ baseSize * 0.5 пікселів.
    final estimatedWidth = text.length * baseSize * 0.5;
    final maxAllowedWidth = maxWidth * maxLines;

    if (estimatedWidth <= maxAllowedWidth) return baseSize;

    final scale = maxAllowedWidth / estimatedWidth;
    return (baseSize * scale).clamp(baseSize * 0.6, baseSize);
  }

  /// Створює стиль з текстовим оздобленням (підкреслення, закреслення).
  ///
  /// [style] — базовий стиль.
  /// [decoration] — тип оздоблення.
  /// [decorationColor] — колір оздоблення.
  /// [decorationStyle] — стиль лінії.
  static TextStyle withDecoration(
    TextStyle style, {
    TextDecoration decoration = TextDecoration.underline,
    Color? decorationColor,
    TextDecorationStyle decorationStyle = TextDecorationStyle.solid,
  }) {
    return style.copyWith(
      decoration: decoration,
      decorationColor: decorationColor,
      decorationStyle: decorationStyle,
    );
  }

  /// Створює закреслений стиль (для вихідних цілей, знижок тощо).
  ///
  /// [style] — базовий стиль.
  /// [color] — колір лінії закреслення.
  static TextStyle strikethrough(TextStyle style, {Color? color}) {
    return style.copyWith(
      decoration: TextDecoration.lineThrough,
      decorationColor: color,
    );
  }

  /// Створює підкреслений стиль.
  ///
  /// [style] — базовий стиль.
  /// [color] — колір лінії підкреслення.
  static TextStyle underline(TextStyle style, {Color? color}) {
    return style.copyWith(
      decoration: TextDecoration.underline,
      decorationColor: color,
    );
  }

  /// Створює стиль з пунктирним підкресленням.
  ///
  /// [style] — базовий стиль.
  /// [color] — колір лінії.
  static TextStyle dottedUnderline(TextStyle style, {Color? color}) {
    return style.copyWith(
      decoration: TextDecoration.underline,
      decorationColor: color,
      decorationStyle: TextDecorationStyle.dotted,
    );
  }

  /// Створює тему тексту (TextTheme) на основі стилів AppTypography.
  ///
  /// Зручний метод для створення повної теми тексту.
  static TextTheme createTextTheme({Color? primaryColor}) {
    final color = primaryColor;
    return TextTheme(
      displayLarge: displayLarge.copyWith(color: color),
      displayMedium: displayMedium.copyWith(color: color),
      displaySmall: displaySmall.copyWith(color: color),
      headlineLarge: heading1.copyWith(color: color),
      headlineMedium: heading2.copyWith(color: color),
      headlineSmall: heading3.copyWith(color: color),
      titleLarge: heading1.copyWith(color: color),
      titleMedium: heading2.copyWith(color: color),
      titleSmall: heading3.copyWith(color: color),
      bodyLarge: bodyLarge.copyWith(color: color),
      bodyMedium: bodyMedium.copyWith(color: color),
      bodySmall: bodySmall.copyWith(color: color),
      labelLarge: labelLarge.copyWith(color: color),
      labelMedium: labelMedium.copyWith(color: color),
      labelSmall: labelSmall.copyWith(color: color),
    );
  }

  /// Створює стиль для номера в списку (нумерований список).
  ///
  /// [index] — номер елемента.
  static TextStyle numberedItemStyle(int index) {
    return monoCaption.copyWith(
      fontWeight: FontWeight.w700,
      fontSize: 12,
    );
  }

  /// Повертає стиль для акцентного тексту всередині речення.
  ///
  /// Наприклад: "Ви зекономили **15 000 грн**"
  static TextStyle inlineAccent({Color? color}) {
    return bodyMediumBold.copyWith(
      color: color ?? const Color(0xFF006FCD),
    );
  }

  // ─── Темозалежні фабричні методи ──────────────────────────────────

  /// Повертає стиль заголовка залежно від теми (світла/темна).
  ///
  /// Автоматично обирає колір тексту.
  static TextStyle themedHeading(
    BuildContext context, {
    TextStyle base = heading2,
    bool? isLight,
  }) {
    final light = isLight ?? Theme.of(context).brightness == Brightness.light;
    return base.copyWith(
      color: light ? const Color(0xFF1A1A2E) : const Color(0xFFE8E8F0),
    );
  }

  /// Повертає стиль основного тексту залежно від теми.
  static TextStyle themedBody(
    BuildContext context, {
    TextStyle base = bodyMedium,
    bool? isLight,
  }) {
    final light = isLight ?? Theme.of(context).brightness == Brightness.light;
    return base.copyWith(
      color: light ? const Color(0xFF2D2D44) : const Color(0xFFC8C8D8),
    );
  }

  /// Повертає стиль підзаголовка залежно від теми.
  static TextStyle themedSubtitle(
    BuildContext context, {
    TextStyle base = bodySmall,
    bool? isLight,
  }) {
    final light = isLight ?? Theme.of(context).brightness == Brightness.light;
    return base.copyWith(
      color: light ? const Color(0xFF6B7280) : const Color(0xFF8B8BA0),
    );
  }

  /// Повертає стиль мітки залежно від теми.
  static TextStyle themedLabel(
    BuildContext context, {
    TextStyle base = labelMedium,
    bool? isLight,
  }) {
    final light = isLight ?? Theme.of(context).brightness == Brightness.light;
    return base.copyWith(
      color: light ? const Color(0xFF4B5563) : const Color(0xFF9CA3AF),
    );
  }

  /// Повертає стиль підказки залежно від теми.
  static TextStyle themedHint(
    BuildContext context, {
    TextStyle base = caption,
    bool? isLight,
  }) {
    final light = isLight ?? Theme.of(context).brightness == Brightness.light;
    return base.copyWith(
      color: light ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280),
    );
  }

  // ─── Числові стилі відображення ───────────────────────────────────

  /// Стиль для відображення великого числа з валютою.
  ///
  /// Наприклад: "25 000 грн" на картці цілі.
  static TextStyle largeMoneyDisplay({Color? color}) {
    return currencyLarge.copyWith(color: color);
  }

  /// Стиль для відображення середнього числа з валютою.
  ///
  /// Наприклад: "1 500 грн" у списку транзакцій.
  static TextStyle mediumMoneyDisplay({Color? color}) {
    return currencyMedium.copyWith(color: color);
  }

  /// Стиль для компактного числа з валютою.
  ///
  /// Наприклад: "500 грн" у чіпі.
  static TextStyle compactMoneyDisplay({Color? color}) {
    return currencyCompact.copyWith(color: color);
  }

  /// Стиль для позитивного числа (зелений).
  static TextStyle positiveNumber({double fontSize = 14}) {
    return TextStyle(
      fontFamily: monoFontFamily,
      fontSize: fontSize,
      fontWeight: FontWeight.w600,
      height: 1.2,
      color: const Color(0xFF00C853),
    );
  }

  /// Стиль для негативного числа (червоний).
  static TextStyle negativeNumber({double fontSize = 14}) {
    return TextStyle(
      fontFamily: monoFontFamily,
      fontSize: fontSize,
      fontWeight: FontWeight.w600,
      height: 1.2,
      color: const Color(0xFFFF1744),
    );
  }

  /// Стиль для нейтрального числа (сірий).
  static TextStyle neutralNumber({double fontSize = 14}) {
    return TextStyle(
      fontFamily: monoFontFamily,
      fontSize: fontSize,
      fontWeight: FontWeight.w500,
      height: 1.2,
      color: const Color(0xFF8888A0),
    );
  }

  // ─── Текстові оздоблення (Decoration Presets) ──────────────────────

  /// Стиль для text-decoration: line-through (закреслення).
  static TextDecorationStyle get decorationSolid =>
      TextDecorationStyle.solid;

  /// Стиль для text-decoration: dashed (штрихове підкреслення).
  static TextDecorationStyle get decorationDashed =>
      TextDecorationStyle.dashed;

  /// Стиль для text-decoration: dotted (крапкове підкреслення).
  static TextDecorationStyle get decorationDotted =>
      TextDecorationStyle.dotted;

  /// Стиль для text-decoration: wavy (хвилеподібне підкреслення).
  static TextDecorationStyle get decorationWavy =>
      TextDecorationStyle.wavy;

  /// Створює стиль подвійного підкреслення.
  ///
  /// [style] — базовий стиль.
  /// [color] — колір підкреслення.
  static TextStyle doubleUnderline(TextStyle style, {Color? color}) {
    return style.copyWith(
      decoration: TextDecoration.underline,
      decorationColor: color,
      decorationStyle: TextDecorationStyle.double,
    );
  }

  // ─── Кастомні набори міжлітерних інтервалів ──────────────────────

  /// Набір міжлітерних інтервалів для різних контекстів.
  static const letterSpacings = _LetterSpacings();

  /// Створює стиль з кастомним міжлітерним інтервалом.
  ///
  /// [style] — базовий стиль.
  /// [spacing] — значення міжлітерного інтервалу.
  static TextStyle withLetterSpacing(TextStyle style, double spacing) {
    return style.copyWith(letterSpacing: spacing);
  }
}

/// Набір констант для міжлітерних інтервалів.
class _LetterSpacings {
  const _LetterSpacings();

  /// Для display-заголовків (компактний).
  static const double display = -0.5;

  /// Для заголовків (стандартний).
  static const double heading = 0.0;

  /// Для body-тексту (стандартний).
  static const double body = 0.0;

  /// Для label (дещо розширений).
  static const double label = 0.2;

  /// Для overline (розширений).
  static const double overline = 1.5;

  /// Для кнопок (дещо розширений).
  static const double button = 0.2;

  /// Для mono-чисел (компактний).
  static const double mono = -0.3;

  /// Для акцентного тексту (компактний).
  static const double accent = -0.2;
}
