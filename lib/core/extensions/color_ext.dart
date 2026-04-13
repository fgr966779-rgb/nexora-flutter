import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';

/// Extensions on [Color] for comprehensive color manipulation utilities.
///
/// Містить:
/// - Базові перетворення (alpha, hex, fromHex, toCSSColor)
/// - Зміну яскравості (lighten, darken, saturate, desaturate, grayscale)
/// - Мікшування кольорів (blend, blendWhite, blendBlack, blendFour)
/// - Градієнти (лінійні, радіальні, з проміжними кольорами)
/// - Визначення тональності (isLight, isDark, luminance)
/// - Контраст (WCAG AA/AAA, contrastText, accessibleContrastText)
/// - Комплементарні кольори (complementary, analogous, triadic, split)
/// - Гармонію кольорів (монохроматична, комплементарна, аналогова палітри)
/// - Температуру кольору (теплий/холодний, градуси)
/// - Material Color генерацію
/// - Насиченість, відтінок, світлість (HSL/HSV конверсії)
/// - Конверсії колірних просторів (RGB→HSL, RGB→HSV, RGB→CMYK)
/// - Фільтри (ColorFilter, сепія, інверт, інвертувати канал)
/// - Стани UI (disabled, pressed, hovered, selected, focused)
/// - Гейміфікаційні ефекти (glow, inverted, fade, pulse, shimmer)
/// - Контрастні коефіцієнти для доступності
/// - Теплову температуру кольору (warm, cool, neutral)
/// - Відстань між кольорами (Euclidean, weighted)
/// - Тонування, відтінки, tint/shade палітри
/// - Кольори для графіків, палітри для діаграм
/// - Іменовані кольори Nexora, константи тем
/// - CSS-кольори, парсинг кольорових рядків
library;

// ─── Константи кольорів Nexora ─────────────────────────────────────────

/// Іменовані кольори, що використовуються в додатку Nexora.
///
/// Містить основні кольори бренду, станів та гейміфікації.
class NexoraColors {
  NexoraColors._();

  // ── Бренд ──────────────────────────────────────────────────────────

  /// Основний колір бренду Nexora — блакитний.
  static const Color primary = Color(0xFF0070D1);

  /// Вторинний колір бренду — золотий.
  static const Color secondary = Color(0xFFFFD600);

  /// Акцентний колір — м'ятний.
  static const Color accent = Color(0xFF00BFA5);

  // ── Гейміфікація ──────────────────────────────────────────────────

  /// Колір XP — золотистий.
  static const Color xp = Color(0xFFFFD600);

  /// Колір монеток — помаранчевий.
  static const Color coins = Color(0xFFFF9100);

  /// Колір серії (streak) — червоний.
  static const Color streak = Color(0xFFFF1744);

  /// Колір успіху — зелений.
  static const Color success = Color(0xFF00C853);

  /// Колір помилки — червоний.
  static const Color error = Color(0xFFFF1744);

  /// Колір попередження — амбар.
  static const Color warning = Color(0xFFFFB300);

  /// Колір інформації — синій.
  static const Color info = Color(0xFF006FCD);

  // ── Стани ─────────────────────────────────────────────────────────

  /// Колір активного елемента.
  static const Color active = Color(0xFF0070D1);

  /// Колір неактивного елемента.
  static const Color inactive = Color(0xFFBDBDBD);

  /// Колір фокусу — блакитний з низькою непрозорістю.
  static const Color focus = Color(0x400070D1);

  /// Колір виділення — блакитний з низькою непрозорістю.
  static const Color selection = Color(0x330070D1);

  /// Колір наведення — сірий з низькою непрозорістю.
  static const Color hover = Color(0x14000000);

  // ── Фони ──────────────────────────────────────────────────────────

  /// Основний фон для світлої теми.
  static const Color lightBackground = Color(0xFFF5F5FA);

  /// Основний фон для темної теми.
  static const Color darkBackground = Color(0xFF121212);

  /// Поверхня для світлої теми.
  static const Color lightSurface = Color(0xFFFFFFFF);

  /// Поверхня для темної теми.
  static const Color darkSurface = Color(0xFF1E1E2E);

  // ── Текст ─────────────────────────────────────────────────────────

  /// Основний текст для світлої теми.
  static const Color lightText = Color(0xFF212121);

  /// Вторинний текст для світлої теми.
  static const Color lightTextSecondary = Color(0xFF757575);

  /// Основний текст для темної теми.
  static const Color darkText = Color(0xFFEEEEEE);

  /// Вторинний текст для темної теми.
  static const Color darkTextSecondary = Color(0xFF9E9E9E);

  // ── Градієнти ─────────────────────────────────────────────────────

  /// Градієнт «зоряне небо» — від синього до фіолетового.
  static const List<Color> starryGradient = [
    Color(0xFF1A237E),
    Color(0xFF4A148C),
  ];

  /// Градієнт «золота пора» — від жовтого до помаранчевого.
  static const List<Color> goldenGradient = [
    Color(0xFFFFD600),
    Color(0xFFFF9100),
  ];

  /// Градієнт «м'ятна свіжість» — від м'ятного до блакитного.
  static const List<Color> mintGradient = [
    Color(0xFF00BFA5),
    Color(0xFF006FCD),
  ];

  /// Градієнт «вогняна серія» — від жовтого до червоного.
  static const List<Color> fireGradient = [
    Color(0xFFFFD600),
    Color(0xFFFF9100),
    Color(0xFFFF1744),
  ];

  // ── Рівні ─────────────────────────────────────────────────────────

  /// Колір рівня 1 — зелений (Новачок).
  static const Color level1 = Color(0xFF4CAF50);

  /// Колір рівня 2 — блакитний (Скарбничкар).
  static const Color level2 = Color(0xFF2196F3);

  /// Колір рівня 3 — фіолетовий (Колекціонер).
  static const Color level3 = Color(0xFF9C27B0);

  /// Колір рівня 4 — помаранчевий (Майстер).
  static const Color level4 = Color(0xFFFF9800);

  /// Колір рівня 5 — золотий (Золотий заощадник).
  static const Color level5 = Color(0xFFFFD600);

  /// Колір рівня 6 — червоний (Легенда).
  static const Color level6 = Color(0xFFF44336);

  /// Колір рівня 7 — діамантовий (Неперевершений).
  static const Color level7 = Color(0xFF00BCD4);

  /// Колір рівня 8 — чорний з золотом (Скарбничний бос).
  static const Color level8 = Color(0xFF212121);

  /// Повертає колір для вказаного рівня.
  ///
  /// [level] — номер рівня (1–8).
  /// Повертає [NexoraColors.level1] для рівня 1 тощо.
  /// Для невідомих рівнів повертає [NexoraColors.primary].
  static Color forLevel(int level) {
    switch (level) {
      case 1:
        return level1;
      case 2:
        return level2;
      case 3:
        return level3;
      case 4:
        return level4;
      case 5:
        return level5;
      case 6:
        return level6;
      case 7:
        return level7;
      case 8:
        return level8;
      default:
        return primary;
    }
  }

  /// Повертає список кольорів рівнів.
  ///
  /// Зручний метод для генерації палітри рівнів.
  /// Повертає масив з 8 кольорів, відповідних рівням 1–8.
  static List<Color> get allLevelColors => [
        level1,
        level2,
        level3,
        level4,
        level5,
        level6,
        level7,
        level8,
      ];

  /// Повертає палітру кольорів для графіка серії.
  ///
  /// Генерує плавний перехід від зеленого до червоного
  /// з вказаною кількістю [steps] кроків.
  ///
  /// [steps] — кількість кольорів у палітрі (за замовчуванням 7).
  static List<Color> heatmapPalette({int steps = 7}) {
    final colors = <Color>[];
    for (var i = 0; i < steps; i++) {
      final t = i / (steps - 1).clamp(1, steps);
      final r = (76 + t * 179).round().clamp(0, 255);
      final g = (175 - t * 150).round().clamp(0, 255);
      final b = (80 - t * 12).round().clamp(0, 255);
      colors.add(Color.fromARGB(255, r, g, b));
    }
    return colors;
  }

  /// Повертає палітру кольорів для діаграм.
  ///
  /// [count] — кількість кольорів у палітрі.
  /// Генерує рівномірно розподілені кольори на кольоровому колесі.
  static List<Color> chartPalette({int count = 8}) {
    return ColorExt.generateHarmony(const Color(0xFF0070D1), count: count);
  }
}

extension ColorExt on Color {
  // ─── Базові перетворення ──────────────────────────────────────────

  /// Повертає колір з вказаною непрозорістю.
  ///
  /// [alpha] — значення від 0.0 (повністю прозорий) до 1.0 (повністю непрозорий).
  ///
  /// Приклад: `Colors.blue.withCustomAlpha(0.5)` → напівпрозорий синій.
  ///
  /// Бросає [AssertionError], якщо [alpha] поза межами 0.0–1.0.
  Color withCustomAlpha(double alpha) {
    assert(alpha >= 0.0 && alpha <= 1.0, 'alpha must be between 0.0 and 1.0');
    return withValues(alpha: alpha.clamp(0.0, 1.0));
  }

  /// Перетворює колір у hex-рядок з альфа-каналом.
  ///
  /// Формат: `#AARRGGBB` (8 шістнадцяткових символів).
  ///
  /// Приклад: `const Color(0xFF0070D1).toHex()` → `"#FF0070D1"`
  ///
  /// Повертає рядок з великими літерами.
  String toHex() {
    final a = alpha.toInt();
    final r = red.toInt();
    final g = green.toInt();
    final b = blue.toInt();
    return '#${a.toRadixString(16).padLeft(2, '0').toUpperCase()}'
        '${r.toRadixString(16).padLeft(2, '0').toUpperCase()}'
        '${g.toRadixString(16).padLeft(2, '0').toUpperCase()}'
        '${b.toRadixString(16).padLeft(2, '0').toUpperCase()}';
  }

  /// Перетворює колір у короткий hex-рядок без альфа-каналу.
  ///
  /// Формат: `#RRGGBB` (6 шістнадцяткових символів).
  ///
  /// Приклад: `const Color(0xFF0070D1).toHexShort()` → `"#0070D1"`
  ///
  /// Повертає рядок з великими літерами.
  String toHexShort() {
    final r = red.toInt();
    final g = green.toInt();
    final b = blue.toInt();
    return '#${r.toRadixString(16).padLeft(2, '0').toUpperCase()}'
        '${g.toRadixString(16).padLeft(2, '0').toUpperCase()}'
        '${b.toRadixString(16).padLeft(2, '0').toUpperCase()}';
  }

  /// Перетворює колір у CSS-формат `rgba(r, g, b, a)`.
  ///
  /// Корисний для веб-експорту та HTML-генерації.
  ///
  /// Приклад: `Color(0x80FF0000).toCSSColor()` → `"rgba(255, 0, 0, 0.5)"`
  ///
  /// Повертає рядок у форматі CSS rgba.
  String toCSSColor() {
    final r = red.toInt();
    final g = green.toInt();
    final b = blue.toInt();
    final a = alpha.toStringAsFixed(2);
    return 'rgba($r, $g, $b, $a)';
  }

  /// Перетворює колір у рядок `rgb(r, g, b)` без альфа-каналу.
  ///
  /// Корисний для веб-експорту та HTML-генерації.
  ///
  /// Приклад: `const Color(0xFFFF0000).toRGBString()` → `"rgb(255, 0, 0)"`
  String toRGBString() {
    final r = red.toInt();
    final g = green.toInt();
    final b = blue.toInt();
    return 'rgb($r, $g, $b)';
  }

  /// Створює колір з hex-рядка.
  ///
  /// Підтримує формати: `#RRGGBB`, `#AARRGGBB`, `RRGGBB`, `AARRGGBB`.
  ///
  /// Приклад: `ColorExt.fromHex('#0070D1')` → `Color(0xFF0070D1)`
  ///
  /// Бросає [ArgumentError], якщо формат некоректний.
  static Color fromHex(String hex) {
    final cleaned = hex.replaceAll('#', '').replaceAll('0x', '');
    String fullHex;
    if (cleaned.length == 6) {
      fullHex = 'FF$cleaned'; // додаємо повну непрозорість
    } else if (cleaned.length == 8) {
      fullHex = cleaned;
    } else {
      throw ArgumentError(
          'Невірний формат hex: $hex. Очікується #RRGGBB або #AARRGGBB.');
    }
    try {
      return Color(int.parse(fullHex, radix: 16));
    } catch (e) {
      throw ArgumentError('Не вдалося розпарсити колір з hex: $hex. Помилка: $e');
    }
  }

  /// Створює колір з CSS-рядка `rgba(r, g, b, a)` або `rgb(r, g, b)`.
  ///
  /// Підтримує формати:
  /// - `rgba(255, 0, 0, 0.5)`
  /// - `rgb(255, 0, 0)`
  /// - `#FF0000`
  /// - `#80FF0000`
  ///
  /// Приклад: `ColorExt.fromCSSString('rgba(255, 0, 0, 0.5)')` → напівпрозорий червоний.
  ///
  /// Бросає [FormatException], якщо рядок не розпізнано.
  static Color fromCSSString(String cssString) {
    final trimmed = cssString.trim();

    // Спробуємо hex формат
    if (trimmed.startsWith('#')) {
      return fromHex(trimmed);
    }

    // Спробуємо rgba формат
    final rgbaMatch = RegExp(
            r'rgba?\(\s*(\d+)\s*,\s*(\d+)\s*,\s*(\d+)(?:\s*,\s*([\d.]+))?\s*\)')
        .firstMatch(trimmed);

    if (rgbaMatch != null) {
      final r = int.parse(rgbaMatch.group(1)!);
      final g = int.parse(rgbaMatch.group(2)!);
      final b = int.parse(rgbaMatch.group(3)!);
      final a = rgbaMatch.group(4) != null
          ? double.parse(rgbaMatch.group(4)!)
          : 1.0;
      return Color.fromARGB(
        (a * 255).round().clamp(0, 255),
        r.clamp(0, 255),
        g.clamp(0, 255),
        b.clamp(0, 255),
      );
    }

    throw FormatException('Не вдалося розпарсити колір: $cssString');
  }

  /// Створює колір з ARGB компонентів.
  ///
  /// [a] — альфа (0–255), [r] — червоний (0–255),
  /// [g] — зелений (0–255), [b] — синій (0–255).
  ///
  /// Усі значення автоматично обмежуються в межах 0–255.
  ///
  /// Приклад: `ColorExt.fromARGBValues(255, 0, 112, 209)` → `Color(0xFF0070D1)`
  static Color fromARGBValues(int a, int r, int g, int b) {
    return Color.fromARGB(
      a.clamp(0, 255),
      r.clamp(0, 255),
      g.clamp(0, 255),
      b.clamp(0, 255),
    );
  }

  // ─── Зміна яскравості ─────────────────────────────────────────────

  /// Засвітлює колір на вказану кількість [amount] (0.0 – 1.0).
  ///
  /// Переводить колір у HSL, збільшує світлість та повертає назад.
  ///
  /// [amount] — величина засвітлення (0.0 = без змін, 1.0 = максимально світлий).
  /// Бросає [AssertionError], якщо [amount] поза межами 0.0–1.0.
  Color lighten(double amount) {
    assert(amount >= 0.0 && amount <= 1.0, 'amount must be between 0.0 and 1.0');
    final hsl = HSLColor.fromColor(this);
    final lightness = (hsl.lightness + amount).clamp(0.0, 1.0);
    return hsl.withLightness(lightness).toColor();
  }

  /// Затемнює колір на вказану кількість [amount] (0.0 – 1.0).
  ///
  /// Переводить колір у HSL, зменшує світлість та повертає назад.
  ///
  /// [amount] — величина затемнення (0.0 = без змін, 1.0 = максимально темний).
  /// Бросає [AssertionError], якщо [amount] поза межами 0.0–1.0.
  Color darken(double amount) {
    assert(amount >= 0.0 && amount <= 1.0, 'amount must be between 0.0 and 1.0');
    final hsl = HSLColor.fromColor(this);
    final lightness = (hsl.lightness - amount).clamp(0.0, 1.0);
    return hsl.withLightness(lightness).toColor();
  }

  /// Насичує колір (збільшує насиченість).
  ///
  /// [amount] — величина насичення (0.0 – 1.0).
  /// Бросає [AssertionError], якщо [amount] поза межами 0.0–1.0.
  Color saturate(double amount) {
    assert(amount >= 0.0 && amount <= 1.0, 'amount must be between 0.0 and 1.0');
    final hsl = HSLColor.fromColor(this);
    final saturation = (hsl.saturation + amount).clamp(0.0, 1.0);
    return hsl.withSaturation(saturation).toColor();
  }

  /// Зменшує насиченість кольору (робить його більш сірим).
  ///
  /// [amount] — величина зменшення (0.0 – 1.0).
  /// Бросає [AssertionError], якщо [amount] поза межами 0.0–1.0.
  Color desaturate(double amount) {
    assert(amount >= 0.0 && amount <= 1.0, 'amount must be between 0.0 and 1.0');
    final hsl = HSLColor.fromColor(this);
    final saturation = (hsl.saturation - amount).clamp(0.0, 1.0);
    return hsl.withSaturation(saturation).toColor();
  }

  /// Повертає повністю десатурений (сірий) варіант кольору.
  ///
  /// Зберігає оригінальну світлість, але прибирає колір.
  Color get grayscale {
    final hsl = HSLColor.fromColor(this);
    return hsl.withSaturation(0.0).toColor();
  }

  /// Збільшує яскравість кольору на вказаний відсоток.
  ///
  /// На відміну від [lighten], працює у відсотковому відношенні:
  /// `amount = 0.2` збільшує яскравість на 20% від поточного значення.
  ///
  /// [amount] — відсоток збільшення (0.0 – 1.0, наприклад 0.2 = +20%).
  /// Бросає [AssertionError], якщо [amount] поза межами.
  Color brighten(double amount) {
    assert(amount >= 0.0 && amount <= 1.0, 'amount must be between 0.0 and 1.0');
    final hsl = HSLColor.fromColor(this);
    final newLightness = hsl.lightness * (1.0 + amount).clamp(0.0, 2.0);
    return hsl.withLightness(newLightness.clamp(0.0, 1.0)).toColor();
  }

  /// Зменшує яскравість кольору на вказаний відсоток.
  ///
  /// [amount] — відсоток зменшення (0.0 – 1.0, наприклад 0.2 = −20%).
  /// Бросає [AssertionError], якщо [amount] поза межами.
  Color dim(double amount) {
    assert(amount >= 0.0 && amount <= 1.0, 'amount must be between 0.0 and 1.0');
    final hsl = HSLColor.fromColor(this);
    final newLightness = hsl.lightness * (1.0 - amount).clamp(0.0, 1.0);
    return hsl.withLightness(newLightness.clamp(0.0, 1.0)).toColor();
  }

  /// Повертає tint (змішаний з білим) варіант кольору.
  ///
  /// На відміну від [lighten], працює через просте мікшування.
  /// [amount] — частка білого (0.0 = оригінал, 1.0 = білий).
  Color tint(double amount) {
    return blendWhite(amount);
  }

  /// Повертає shade (змішаний з чорним) варіант кольору.
  ///
  /// На відміну від [darken], працює через просте мікшування.
  /// [amount] — частка чорного (0.0 = оригінал, 1.0 = чорний).
  Color shade(double amount) {
    return blendBlack(amount);
  }

  /// Повертає тон (tint) кольору — освітлений версія.
  ///
  /// Збільшує світлість на 10% і зменшує насиченість на 5%.
  Color get tonalized => lighten(0.10).desaturate(0.05);

  /// Повертає відтінок (shade) кольору — затемнений версія.
  ///
  /// Зменшує світлість на 10% і трохи збільшує насиченість.
  Color get shadowized => darken(0.10).saturate(0.03);

  // ─── Мікшування кольорів ──────────────────────────────────────────

  /// Змішує цей колір з [other] у вказаній пропорції [ratio].
  ///
  /// [ratio] — частка [other] у результаті (0.0 = цей колір, 1.0 = інший).
  ///
  /// Приклад: `Colors.red.blend(Colors.blue, 0.5)` → фіолетовий.
  Color blend(Color other, double ratio) {
    final clamped = ratio.clamp(0.0, 1.0);
    return Color.lerp(this, other, clamped) ?? this;
  }

  /// Змішує колір з білим (засвітлює).
  ///
  /// [ratio] — частка білого (0.0 = оригінал, 1.0 = білий).
  Color blendWhite(double ratio) {
    return blend(const Color(0xFFFFFFFF), ratio);
  }

  /// Змішує колір з чорним (затемнює).
  ///
  /// [ratio] — частка чорного (0.0 = оригінал, 1.0 = чорний).
  Color blendBlack(double ratio) {
    return blend(const Color(0xFF000000), ratio);
  }

  /// Змішує три кольори у вказаних пропорціях.
  ///
  /// Суми [ratioA] + [ratioB] + [ratioC] нормалізуються до 1.0.
  ///
  /// Приклад:
  /// ```dart
  /// ColorExt.blendThree(
  ///   Colors.red, Colors.green, Colors.blue,
  ///   ratioA: 1, ratioB: 1, ratioC: 1,
  /// )
  /// ```
  static Color blendThree(Color a, Color b, Color c, {
    double ratioA = 0.33,
    double ratioB = 0.34,
    double ratioC = 0.33,
  }) {
    final total = ratioA + ratioB + ratioC;
    if (total == 0) return a;
    final first = Color.lerp(a, b, ratioB / total) ?? a;
    return Color.lerp(first, c, ratioC / total) ?? first;
  }

  /// Змішує чотири кольори у вказаних пропорціях.
  ///
  /// Суми всіх ratio нормалізуються до 1.0.
  ///
  /// [a], [b], [c], [d] — кольори для мікшування.
  /// [ratioA], [ratioB], [ratioC], [ratioD] — пропорції кожного кольору.
  static Color blendFour(
    Color a,
    Color b,
    Color c,
    Color d, {
    double ratioA = 0.25,
    double ratioB = 0.25,
    double ratioC = 0.25,
    double ratioD = 0.25,
  }) {
    final total = ratioA + ratioB + ratioC + ratioD;
    if (total == 0) return a;
    final first = Color.lerp(a, b, ratioB / total) ?? a;
    final second = Color.lerp(first, c, ratioC / (total - ratioA)) ?? first;
    return Color.lerp(second, d, ratioD / (total - ratioA - ratioB)) ?? second;
  }

  /// Алфатичне мікшування (alpha compositing) цього кольору з [other].
  ///
  /// Використовує стандартну формулу: result = src × srcAlpha + dst × (1 - srcAlpha).
  ///
  /// [other] — фоновий колір.
  /// [srcAlpha] — альфа цього (переднього) кольору. За замовчуванням — поточний alpha.
  ///
  /// Повертає результуючий колір з композитингом.
  Color alphaBlend(Color other, {double? srcAlpha}) {
    final a = (srcAlpha ?? alpha).clamp(0.0, 1.0);
    final invA = 1.0 - a;
    final r = (red * a + other.red * invA).round().clamp(0, 255);
    final g = (green * a + other.green * invA).round().clamp(0, 255);
    final b = (blue * a + other.blue * invA).round().clamp(0, 255);
    return Color.fromARGB(255, r, g, b);
  }

  // ─── Градієнти ────────────────────────────────────────────────────

  /// Створює вертикальний `LinearGradient` від цього кольору
  /// до його повністю прозорої версії.
  ///
  /// Корисно для фонових ефектів карток та оверлеїв.
  ///
  /// [begin] — початкова точка градієнта.
  /// [end] — кінцева точка градієнта.
  /// [tileMode] — режим повторення градієнта.
  LinearGradient toGradient({
    AlignmentGeometry begin = Alignment.topCenter,
    AlignmentGeometry end = Alignment.bottomCenter,
    TileMode tileMode = TileMode.clamp,
  }) {
    return LinearGradient(
      colors: [this, withValues(alpha: 0.0)],
      begin: begin,
      end: end,
      tileMode: tileMode,
    );
  }

  /// Створює горизонтальний градієнт від цього кольору до прозорого.
  LinearGradient toHorizontalGradient() {
    return LinearGradient(
      colors: [this, withValues(alpha: 0.0)],
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
    );
  }

  /// Створює діагональний градієнт (зліва-зверху до справа-знизу).
  LinearGradient toDiagonalGradient() {
    return LinearGradient(
      colors: [this, withValues(alpha: 0.0)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  /// Створює радіальний градієнт від цього кольору до прозорого.
  ///
  /// [radius] — радіус градієнта (0.0 – 1.0).
  /// [center] — центр градієнта.
  RadialGradient toRadialGradient({
    double radius = 0.5,
    AlignmentGeometry center = Alignment.center,
  }) {
    return RadialGradient(
      colors: [this, withValues(alpha: 0.0)],
      radius: radius,
      center: center,
    );
  }

  /// Створює градієнт з двох кольорів: цей → [toColor].
  ///
  /// [toColor] — кінцевий колір градієнта.
  /// [begin] — початкова точка.
  /// [end] — кінцева точка.
  LinearGradient toGradientTo(
    Color toColor, {
    AlignmentGeometry begin = Alignment.topCenter,
    AlignmentGeometry end = Alignment.bottomCenter,
  }) {
    return LinearGradient(
      colors: [this, toColor],
      begin: begin,
      end: end,
    );
  }

  /// Створює градієнт через проміжний колір.
  ///
  /// Цей → [mid] → [toColor].
  ///
  /// [mid] — проміжний колір.
  /// [toColor] — кінцевий колір.
  LinearGradient toGradientVia(
    Color mid,
    Color toColor, {
    AlignmentGeometry begin = Alignment.topCenter,
    AlignmentGeometry end = Alignment.bottomCenter,
  }) {
    return LinearGradient(
      colors: [this, mid, toColor],
      begin: begin,
      end: end,
    );
  }

  /// Створює градієнт із зазначеним списком кольорів.
  ///
  /// Перший колір — цей, решта — з [stops].
  LinearGradient toGradientWithStops(
    List<double> stops, {
    AlignmentGeometry begin = Alignment.topCenter,
    AlignmentGeometry end = Alignment.bottomCenter,
  }) {
    final hsl = HSLColor.fromColor(this);
    final colors = stops.map((s) {
      final lightness = hsl.lightness * (1 - s);
      return hsl.withLightness(lightness.clamp(0.0, 1.0)).toColor();
    }).toList();
    return LinearGradient(
      colors: [this, ...colors],
      stops: [0.0, ...stops],
      begin: begin,
      end: end,
    );
  }

  /// Створює градієнт з [count] рівномірно розподілених відтінків.
  ///
  /// Корисно для створення плавних перехідних ефектів.
  ///
  /// [count] — кількість кольорів у градієнті (мінімум 2).
  /// Бросає [AssertionError], якщо [count] < 2.
  LinearGradient toGradientWithSteps(int count, {
    AlignmentGeometry begin = Alignment.topCenter,
    AlignmentGeometry end = Alignment.bottomCenter,
  }) {
    assert(count >= 2, 'Кількість кроків має бути ≥ 2');
    final hsl = HSLColor.fromColor(this);
    final colors = List.generate(count, (i) {
      final factor = i / (count - 1);
      final lightness = (hsl.lightness + (factor - 0.5) * 0.6).clamp(0.0, 1.0);
      return hsl.withLightness(lightness).toColor();
    });
    return LinearGradient(colors: colors, begin: begin, end: end);
  }

  /// Створює градієнт з вказаним списком кольорів.
  ///
  /// [colors] — список кольорів (цей колір додається на початок).
  /// [stops] — опціональні стоп-позиції (мають збігатися з кількістю кольорів).
  LinearGradient toGradientWithColors(
    List<Color> colors, {
    List<double>? stops,
    AlignmentGeometry begin = Alignment.topCenter,
    AlignmentGeometry end = Alignment.bottomCenter,
  }) {
    return LinearGradient(
      colors: [this, ...colors],
      stops: stops,
      begin: begin,
      end: end,
    );
  }

  /// Створює swept градієнт (круговий).
  ///
  /// Корисно для індикаторів прогресу та годинників.
  ///
  /// [center] — центр градієнта.
  /// [startAngle] — початковий кут у радіанах.
  /// [endAngle] — кінцевий кут у радіанах.
  SweepGradient toSweepGradient({
    AlignmentGeometry center = Alignment.center,
    double startAngle = 0.0,
    double endAngle = math.pi * 2,
  }) {
    return SweepGradient(
      colors: [this, withValues(alpha: 0.0)],
      center: center,
      startAngle: startAngle,
      endAngle: endAngle,
    );
  }

  // ─── Визначення тональності ───────────────────────────────────────

  /// Чи є цей колір «світлим» (світлість > 0.5).
  ///
  /// Використовує WCAG relative luminance для визначення.
  bool get isLight => luminance > 0.5;

  /// Чи є цей колір «темним» (світлість ≤ 0.5).
  ///
  /// Використовує WCAG relative luminance для визначення.
  bool get isDark => luminance <= 0.5;

  /// Відносна світлість кольору (0.0 — чорний, 1.0 — білий).
  ///
  /// Використовує формулу WCAG 2.0 для розрахунку відносної світлість.
  double get luminance => computeLuminance();

  /// Повертає назву тону кольору українською.
  ///
  /// Визначає загальну назву на основі відтінку:
  /// 'Червоний', 'Помаранчевий', 'Жовтий', 'Зелений', 'Блакитний',
  /// 'Синій', 'Фіолетовий', 'Рожевий', 'Коричневий', 'Сірий'.
  String get hueName {
    final hsl = HSLColor.fromColor(this);
    final hue = hsl.hue;
    final sat = hsl.saturation;
    final light = hsl.lightness;

    // Низька насиченість або крайня світлість — сірий
    if (sat < 0.1 || light < 0.05 || light > 0.95) {
      return light < 0.1 ? 'Чорний' : light > 0.9 ? 'Білий' : 'Сірий';
    }

    if (hue < 15 || hue >= 345) return 'Червоний';
    if (hue < 40) return 'Помаранчевий';
    if (hue < 70) return 'Жовтий';
    if (hue < 150) return 'Зелений';
    if (hue < 190) return 'Блакитний';
    if (hue < 250) return 'Синій';
    if (hue < 290) return 'Фіолетовий';
    if (hue < 345) return 'Рожевий';
    return 'Червоний';
  }

  /// Повертає назву тону кольору англійською.
  ///
  /// Визначає загальну назву на основі відтінку.
  String get hueNameEN {
    final hsl = HSLColor.fromColor(this);
    final hue = hsl.hue;
    final sat = hsl.saturation;
    final light = hsl.lightness;

    if (sat < 0.1 || light < 0.05 || light > 0.95) {
      return light < 0.1 ? 'Black' : light > 0.9 ? 'White' : 'Gray';
    }

    if (hue < 15 || hue >= 345) return 'Red';
    if (hue < 40) return 'Orange';
    if (hue < 70) return 'Yellow';
    if (hue < 150) return 'Green';
    if (hue < 190) return 'Cyan';
    if (hue < 250) return 'Blue';
    if (hue < 290) return 'Purple';
    if (hue < 345) return 'Pink';
    return 'Red';
  }

  // ─── Контрастний текст ────────────────────────────────────────────

  /// Повертає чорний або білий колір тексту залежно від світлості фону.
  ///
  /// Якщо колір світлий — повертає чорний, інакше — білий.
  /// Використовується для гарантії читабельності тексту.
  Color get contrastText => isLight ? Colors.black : Colors.white;

  /// Повертає колір тексту з покращеним контрастом для доступності.
  ///
  /// Повертає колір, що має контрастне співвідношення не менше 4.5:1.
  Color get accessibleContrastText {
    final whiteContrast = _contrastRatio(this, const Color(0xFFFFFFFF));
    final blackContrast = _contrastRatio(this, const Color(0xFF000000));
    return whiteContrast > blackContrast
        ? const Color(0xFFFFFFFF)
        : const Color(0xFF000000);
  }

  /// Повертає контрастний текст із зазначеним мінімальним співвідношенням.
  ///
  /// Шукає між білим та чорним, а також створює напівпрозорі варіанти,
  /// щоб досягти [minRatio].
  ///
  /// [minRatio] — мінімальне контрастне співвідношення (за замовчуванням 4.5).
  Color contrastTextWithMinRatio({double minRatio = 4.5}) {
    // Спочатку перевіряємо чисті білий та чорний
    final whiteContrast = _contrastRatio(this, const Color(0xFFFFFFFF));
    final blackContrast = _contrastRatio(this, const Color(0xFF000000));

    if (whiteContrast >= minRatio) return const Color(0xFFFFFFFF);
    if (blackContrast >= minRatio) return const Color(0xFF000000);

    // Проміжний варіант — сірий
    return const Color(0xFF808080);
  }

  // ─── Контраст ─────────────────────────────────────────────────────

  /// Обчислює контрастне співвідношення з [other] кольором.
  ///
  /// Використовує WCAG 2.0 формулу.
  /// Повертає значення від 1.0 (однаковий) до 21.0 (максимальний контраст).
  double contrastRatioWith(Color other) {
    return _contrastRatio(this, other);
  }

  /// Чи задовольняє колір WCAG AA стандарт контрасту з [other].
  ///
  /// Для звичайного тексту: ≥ 4.5:1.
  bool meetsWcagAA(Color other) {
    return contrastRatioWith(other) >= 4.5;
  }

  /// Чи задовольняє колір WCAG AAA стандарт контрасту з [other].
  ///
  /// Для звичайного тексту: ≥ 7.0:1.
  bool meetsWcagAAA(Color other) {
    return contrastRatioWith(other) >= 7.0;
  }

  /// Чи задовольняє колір WCAG AA для великого тексту з [other].
  ///
  /// Для великого тексту: ≥ 3.0:1.
  bool meetsWcagAALarge(Color other) {
    return contrastRatioWith(other) >= 3.0;
  }

  /// Повертає рівень доступності контрасту українською.
  ///
  /// 'AAA' — ≥ 7.0, 'AA' — ≥ 4.5, 'AA великий' — ≥ 3.0, 'Недостатньо' — < 3.0.
  String accessibilityLevelWith(Color other) {
    final ratio = contrastRatioWith(other);
    if (ratio >= 7.0) return 'AAA — відмінний контраст';
    if (ratio >= 4.5) return 'AA — хороший контраст';
    if (ratio >= 3.0) return 'AA великий — задовільний контраст';
    return 'Недостатній контраст ($ratio.toStringAsFixed(1):1)';
  }

  // ─── Відстань між кольорами ───────────────────────────────────────

  /// Обчислює евклідову відстань у RGB-просторі між цим кольором та [other].
  ///
  /// Повертає значення від 0.0 (ідентичні кольори) до ~441.67 (максимальна відстань).
  ///
  /// Корисний для порівняння схожості кольорів.
  ///
  /// [other] — колір для порівняння.
  /// Повертає double — відстань у RGB-просторі.
  double colorDistance(Color other) {
    final dr = red - other.red;
    final dg = green - other.green;
    final db = blue - other.blue;
    return math.sqrt(dr * dr + dg * dg + db * db);
  }

  /// Обчислює зважену відстань у RGB-просторі.
  ///
  /// Враховує чутливість людського ока до червоного, зеленого та синього.
  /// Використовує коефіцієнти: R×2, G×4, B×3.
  ///
  /// [other] — колір для порівняння.
  double weightedColorDistance(Color other) {
    final dr = (red - other.red) * 2;
    final dg = (green - other.green) * 4;
    final db = (blue - other.blue) * 3;
    return math.sqrt(dr * dr + dg * dg + db * db);
  }

  /// Обчислює відстань у HSL-просторі між цим кольором та [other].
  ///
  /// Враховує кругову природу відтінку (hue).
  ///
  /// [other] — колір для порівняння.
  double hslDistance(Color other) {
    final hsl1 = HSLColor.fromColor(this);
    final hsl2 = HSLColor.fromColor(other);

    // Кругова відстань hue
    double hueDiff = (hsl1.hue - hsl2.hue).abs();
    if (hueDiff > 180) hueDiff = 360 - hueDiff;

    final satDiff = hsl1.saturation - hsl2.saturation;
    final lightDiff = hsl1.lightness - hsl2.lightness;

    return math.sqrt(
        hueDiff * hueDiff + satDiff * satDiff * 100 + lightDiff * lightDiff * 100);
  }

  /// Чи є цей колір достатньо схожим на [other] за вказаним порогом.
  ///
  /// [other] — колір для порівняння.
  /// [threshold] — максимальна відстань (за замовчуванням 50.0).
  /// Повертає `true`, якщо відстань між кольорами ≤ [threshold].
  bool isSimilarTo(Color other, {double threshold = 50.0}) {
    return colorDistance(other) <= threshold;
  }

  // ─── Комплементарний колір ────────────────────────────────────────

  /// Комплементарний (додатковий) колір — на протилежному боці кольорового колеса.
  ///
  /// Приклад: червоний → зелений, синій → жовтий.
  Color get complementary {
    final hsl = HSLColor.fromColor(this);
    final newHue = (hsl.hue + 180) % 360;
    return hsl.withHue(newHue).toColor();
  }

  /// Аналоговий колір — на 30° від цього.
  Color get analogous {
    final hsl = HSLColor.fromColor(this);
    final newHue = (hsl.hue + 30) % 360;
    return hsl.withHue(newHue).toColor();
  }

  /// Тріадичний колір — на 120° від цього.
  Color get triadic {
    final hsl = HSLColor.fromColor(this);
    final newHue = (hsl.hue + 120) % 360;
    return hsl.withHue(newHue).toColor();
  }

  /// Розділено-комплементарний колір — на 150° від цього.
  Color get splitComplementary {
    final hsl = HSLColor.fromColor(this);
    final newHue = (hsl.hue + 150) % 360;
    return hsl.withHue(newHue).toColor();
  }

  /// Тетрадичний (квадратний) колір — на 90° від цього.
  Color get tetradic {
    final hsl = HSLColor.fromColor(this);
    final newHue = (hsl.hue + 90) % 360;
    return hsl.withHue(newHue).toColor();
  }

  /// Повертає колір на вказаному куті від цього.
  ///
  /// [degrees] — кут повороту на кольоровому колесі (може бути від'ємним).
  Color rotatedHue(double degrees) {
    final hsl = HSLColor.fromColor(this);
    final newHue = (hsl.hue + degrees) % 360;
    final normalized = newHue < 0 ? newHue + 360 : newHue;
    return hsl.withHue(normalized).toColor();
  }

  // ─── Гармонія кольорів ────────────────────────────────────────────

  /// Генерує монохроматичну палітру (5 відтінків).
  ///
  /// Повертає список кольорів від темного до світлого.
  List<Color> get monochromaticPalette {
    final hsl = HSLColor.fromColor(this);
    return [
      hsl.withLightness((hsl.lightness - 0.3).clamp(0.0, 1.0)).toColor(),
      hsl.withLightness((hsl.lightness - 0.15).clamp(0.0, 1.0)).toColor(),
      this,
      hsl.withLightness((hsl.lightness + 0.15).clamp(0.0, 1.0)).toColor(),
      hsl.withLightness((hsl.lightness + 0.3).clamp(0.0, 1.0)).toColor(),
    ];
  }

  /// Генерує розширену монохроматичну палітру (9 відтінків).
  ///
  /// Повертає список від дуже темного до дуже світлого з кроком 0.08.
  List<Color> get extendedMonochromaticPalette {
    final hsl = HSLColor.fromColor(this);
    return List.generate(9, (i) {
      final lightness = (hsl.lightness - 0.32 + i * 0.08).clamp(0.0, 1.0);
      return hsl.withLightness(lightness).toColor();
    });
  }

  /// Генерує комплементарну палітру (2 кольори).
  ///
  /// Повертає цей колір та його комплементарний.
  List<Color> get complementaryPalette => [this, complementary];

  /// Генерує аналогову палітру (3 кольори).
  ///
  /// Повертає цей колір та два суміжних на кольоровому колесі.
  List<Color> get analogousPalette {
    final hsl = HSLColor.fromColor(this);
    return [
      hsl.withHue((hsl.hue - 30) % 360).toColor(),
      this,
      hsl.withHue((hsl.hue + 30) % 360).toColor(),
    ];
  }

  /// Генерує тріадичну палітру (3 кольори).
  ///
  /// Повертає цей колір та два на 120° від нього.
  List<Color> get triadicPalette {
    final hsl = HSLColor.fromColor(this);
    return [
      this,
      hsl.withHue((hsl.hue + 120) % 360).toColor(),
      hsl.withHue((hsl.hue + 240) % 360).toColor(),
    ];
  }

  /// Генерує розділено-комплементарну палітру (3 кольори).
  ///
  /// Цей колір + два кольори на 150° та 210°.
  List<Color> get splitComplementaryPalette {
    final hsl = HSLColor.fromColor(this);
    return [
      this,
      hsl.withHue((hsl.hue + 150) % 360).toColor(),
      hsl.withHue((hsl.hue + 210) % 360).toColor(),
    ];
  }

  /// Генерує тетрадичну палітру (4 кольори).
  ///
  /// Цей колір та три кольори на 90°, 180° та 270°.
  List<Color> get tetradicPalette {
    final hsl = HSLColor.fromColor(this);
    return [
      this,
      hsl.withHue((hsl.hue + 90) % 360).toColor(),
      hsl.withHue((hsl.hue + 180) % 360).toColor(),
      hsl.withHue((hsl.hue + 270) % 360).toColor(),
    ];
  }

  /// Генерує палітру з [count] рівномірно розподілених кольорів
  /// на кольоровому колесі.
  ///
  /// [count] — кількість кольорів у палітрі (мінімум 2).
  /// Бросає [AssertionError], якщо [count] < 2.
  static List<Color> generateHarmony(Color base, {int count = 5}) {
    assert(count >= 2, 'count must be at least 2');
    final hsl = HSLColor.fromColor(base);
    final step = 360.0 / count;
    return List.generate(count, (i) {
      final hue = (hsl.hue + step * i) % 360;
      return hsl.withHue(hue).toColor();
    });
  }

  /// Генерує палітру відтінків (shades) — від темного до світлого.
  ///
  /// [steps] — кількість відтінків (за замовчуванням 10).
  /// Повертає список кольорів від найтемнішого до найсвітлішого.
  List<Color> shadePalette({int steps = 10}) {
    return List.generate(steps, (i) {
      final t = i / (steps - 1).clamp(1, steps);
      return darken(0.4 * (1 - t)).lighten(0.4 * t);
    });
  }

  /// Генерує палітру тонів (tints) — від цього кольору до білого.
  ///
  /// [steps] — кількість тонів (за замовчуванням 10).
  List<Color> tintPalette({int steps = 10}) {
    return List.generate(steps, (i) {
      final t = i / (steps - 1).clamp(1, steps);
      return blendWhite(t);
    });
  }

  // ─── Температура кольору ──────────────────────────────────────────

  /// Температура кольору: «теплий» чи «холодний».
  ///
  /// Теплі: червоний, помаранчевий, жовтий (відтінок 0–60° або 300–360°).
  /// Холодні: синій, зелений, фіолетовий (відтінок 60–300°).
  bool get isWarm {
    final hsl = HSLColor.fromColor(this);
    return hsl.hue < 60 || hsl.hue > 300;
  }

  /// Чи є колір холодним.
  bool get isCool => !isWarm;

  /// Повертає температуру кольору у градусах (0–360).
  double get temperature {
    final hsl = HSLColor.fromColor(this);
    return hsl.hue;
  }

  /// Повертає текстовий опис температури кольору українською.
  ///
  /// 'Дуже теплий', 'Теплий', 'Нейтральний', 'Холодний', 'Дуже холодний'.
  String get temperatureDescription {
    final hsl = HSLColor.fromColor(this);
    final hue = hsl.hue;
    if (hue < 20 || hue > 340) return 'Дуже теплий';
    if (hue < 60 || hue > 300) return 'Теплий';
    if (hue < 80 || hue > 260) return 'Нейтральний';
    if (hue < 200) return 'Холодний';
    return 'Дуже холодний';
  }

  /// Повертає тепло-настроєний варіант кольору.
  ///
  /// [factor] — наскільки змістити відтінок у теплий бік (0.0 – 1.0).
  /// Додає помаранчевий відтінок для теплого ефекту.
  /// Бросає [AssertionError], якщо [factor] поза межами.
  Color warmUp(double factor) {
    assert(factor >= 0.0 && factor <= 1.0, 'factor must be between 0.0 and 1.0');
    final hsl = HSLColor.fromColor(this);
    // Зміщуємо відтінок до 30° (помаранчевий)
    var targetHue = 30.0;
    var diff = targetHue - hsl.hue;
    if (diff > 180) diff -= 360;
    if (diff < -180) diff += 360;
    final newHue = (hsl.hue + diff * factor) % 360;
    return hsl.withHue(newHue < 0 ? newHue + 360 : newHue).toColor();
  }

  /// Повертає холодно-настроєний варіант кольору.
  ///
  /// [factor] — наскільки змістити відтінок у холодний бік (0.0 – 1.0).
  /// Додає блакитний відтінок для холодного ефекту.
  /// Бросає [AssertionError], якщо [factor] поза межами.
  Color coolDown(double factor) {
    assert(factor >= 0.0 && factor <= 1.0, 'factor must be between 0.0 and 1.0');
    final hsl = HSLColor.fromColor(this);
    // Зміщуємо відтінок до 210° (блакитний)
    var targetHue = 210.0;
    var diff = targetHue - hsl.hue;
    if (diff > 180) diff -= 360;
    if (diff < -180) diff += 360;
    final newHue = (hsl.hue + diff * factor) % 360;
    return hsl.withHue(newHue < 0 ? newHue + 360 : newHue).toColor();
  }

  // ─── Material Color ───────────────────────────────────────────────

  /// Перетворює колір у Material [MaterialColor] з набором відтінків (50–900).
  ///
  /// Генерує палітру від світлого (50) до темного (900),
  /// використовуючи зміну світлості.
  MaterialColor toMaterialColor() {
    final shades = <int, Color>{};
    const swatchValues = <int>[50, 100, 200, 300, 400, 500, 600, 700, 800, 900];
    const lightnessFactors = <double>[
      0.9, 0.82, 0.74, 0.66, 0.58, 0.5, 0.42, 0.34, 0.26, 0.18,
    ];

    for (var i = 0; i < swatchValues.length; i++) {
      final hsl = HSLColor.fromColor(this);
      final target = lightnessFactors[i];
      final current = hsl.lightness;
      final diff = target - current;
      final adjusted = hsl.withLightness(current.clamp(0.0, 1.0) + diff);
      shades[swatchValues[i]] = adjusted.toColor();
    }

    return MaterialColor(toARGB32(), shades);
  }

  // ─── Насиченість та відтінок ─────────────────────────────────────

  /// Повертає колір із зміненою насиченістю.
  ///
  /// [saturation] — нове значення насиченості (0.0 – 1.0).
  /// Бросає [AssertionError], якщо значення поза межами.
  Color withSaturation(double saturation) {
    assert(saturation >= 0.0 && saturation <= 1.0,
        'saturation must be between 0.0 and 1.0');
    final hsl = HSLColor.fromColor(this);
    return hsl.withSaturation(saturation).toColor();
  }

  /// Повертає колір із зміненим відтінком (hue).
  ///
  /// [hue] — нове значення відтінку (0.0 – 360.0).
  /// Бросає [AssertionError], якщо значення поза межами.
  Color withHue(double hue) {
    assert(hue >= 0.0 && hue <= 360.0, 'hue must be between 0.0 and 360.0');
    final hsl = HSLColor.fromColor(this);
    return hsl.withHue(hue).toColor();
  }

  /// Повертає колір із зміненою світлістю.
  ///
  /// [lightness] — нове значення світлості (0.0 – 1.0).
  /// Бросає [AssertionError], якщо значення поза межами.
  Color withLightness(double lightness) {
    assert(lightness >= 0.0 && lightness <= 1.0,
        'lightness must be between 0.0 and 1.0');
    final hsl = HSLColor.fromColor(this);
    return hsl.withLightness(lightness).toColor();
  }

  /// Повертає HSL у вигляді списку [hue, saturation, lightness].
  List<double> get hslValues {
    final hsl = HSLColor.fromColor(this);
    return [hsl.hue, hsl.saturation, hsl.lightness];
  }

  /// Повертає HSV у вигляді списку [hue, saturation, value].
  List<double> get hsvValues {
    final hsl = HSLColor.fromColor(this);
    // Наближене перетворення HSL → HSV
    final s = hsl.saturation;
    final l = hsl.lightness;
    final v = l + s * math.min(l, 1 - l);
    final sv = v == 0 ? 0 : 2 * (1 - l / v);
    return [hsl.hue, sv.clamp(0.0, 1.0), v];
  }

  /// Повертає CMYK у вигляді списку [cyan, magenta, yellow, key].
  ///
  /// Всі значення в діапазоні 0.0–1.0.
  List<double> get cmykValues {
    final r = red / 255.0;
    final g = green / 255.0;
    final b = blue / 255.0;

    final k = 1.0 - math.max(r, math.max(g, b));
    if (k == 1.0) return [0.0, 0.0, 0.0, 1.0];

    final c = (1.0 - r - k) / (1.0 - k);
    final m = (1.0 - g - k) / (1.0 - k);
    final y = (1.0 - b - k) / (1.0 - k);

    return [
      c.clamp(0.0, 1.0),
      m.clamp(0.0, 1.0),
      y.clamp(0.0, 1.0),
      k.clamp(0.0, 1.0),
    ];
  }

  /// Створює колір з HSL значень.
  ///
  /// [hue] — відтінок (0.0 – 360.0).
  /// [saturation] — насиченість (0.0 – 1.0).
  /// [lightness] — світлість (0.0 – 1.0).
  /// [alpha] — непрозорість (0.0 – 1.0, за замовчуванням 1.0).
  static Color fromHSL({
    required double hue,
    required double saturation,
    required double lightness,
    double alpha = 1.0,
  }) {
    return HSLColor.fromAHSL(alpha, hue, saturation, lightness).toColor();
  }

  /// Створює колір з HSV значень.
  ///
  /// [hue] — відтінок (0.0 – 360.0).
  /// [saturation] — насиченість (0.0 – 1.0).
  /// [value] — значення / яскравість (0.0 – 1.0).
  /// [alpha] — непрозорість (0.0 – 1.0, за замовчуванням 1.0).
  static Color fromHSV({
    required double hue,
    required double saturation,
    required double value,
    double alpha = 1.0,
  }) {
    // HSV → HSL перетворення
    final l = value * (1 - saturation / 2);
    final sl = l == 0 || l == 1
        ? 0
        : (value - l) / math.min(l, 1 - l);
    return HSLColor.fromAHSL(alpha, hue, sl.clamp(0.0, 1.0), l).toColor();
  }

  // ─── Фільтри ──────────────────────────────────────────────────────

  /// Створює `ColorFilter.mode` з цим кольором та режимом [blendMode].
  ///
  /// За замовчуванням використовується [BlendMode.srcIn].
  ColorFilter toFilter({BlendMode blendMode = BlendMode.srcIn}) {
    return ColorFilter.mode(this, blendMode);
  }

  /// Створює `ColorFilter.matrix` для сепія-ефекту.
  ///
  /// [intensity] — сила ефекту (0.0 = без змін, 1.0 = повний сепія).
  static ColorFilter sepiaFilter({double intensity = 1.0}) {
    final t = intensity.clamp(0.0, 1.0);
    return const ColorFilter.matrix(<double>[
      0.393, 0.769, 0.189, 0, 0,
      0.349, 0.686, 0.168, 0, 0,
      0.272, 0.534, 0.131, 0, 0,
      0, 0, 0, 1, 0,
    ]);
  }

  /// Створює `ColorFilter.matrix` для інверсії кольорів.
  static ColorFilter invertFilter() {
    return const ColorFilter.matrix(<double>[
      -1, 0, 0, 0, 255,
      0, -1, 0, 0, 255,
      0, 0, -1, 0, 255,
      0, 0, 0, 1, 0,
    ]);
  }

  /// Створює `ColorFilter.matrix` для градації сірого.
  static ColorFilter grayscaleFilter() {
    return const ColorFilter.matrix(<double>[
      0.2126, 0.7152, 0.0722, 0, 0,
      0.2126, 0.7152, 0.0722, 0, 0,
      0.2126, 0.7152, 0.0722, 0, 0,
      0, 0, 0, 1, 0,
    ]);
  }

  /// Створює кольоровий фільтр з цим кольором (тонування).
  ///
  /// [blendMode] — режим мікшування.
  ColorFilter toTintFilter({BlendMode blendMode = BlendMode.overlay}) {
    return ColorFilter.mode(this, blendMode);
  }

  // ─── Стани UI ─────────────────────────────────────────────────────

  /// Повертає колір у стані «вимкнено» — 50% непрозорості.
  ///
  /// Використовується для неактивних кнопок, полів, елементів.
  Color disabled() => withCustomAlpha(0.5);

  /// Повертає колір у стані «натиснуто» — затемнений на 10%.
  Color pressed() => darken(0.1);

  /// Повертає колір у стані «наведено» — засвічений на 5%.
  Color hovered() => lighten(0.05);

  /// Повертає колір у стані «виділено» — з підвищеною насиченістю.
  Color selected() => saturate(0.1);

  /// Повертає колір у стані «фокус» — з кільцем фокусу.
  Color focused() => saturate(0.15).lighten(0.05);

  /// Повертає колір у стані «помилка» — злегка червонуватий відтінок.
  Color error() => blend(const Color(0xFFFF0000), 0.15);

  /// Повертає колір у стані «успіх» — злегка зелений відтінок.
  Color success() => blend(const Color(0xFF00C853), 0.15);

  /// Повертає колір у стані «попередження» — злегка жовтуватий відтінок.
  Color warning() => blend(const Color(0xFFFFD600), 0.15);

  /// Повертає колір у стані «інформація» — злегка блакитний відтінок.
  Color info() => blend(const Color(0xFF006FCD), 0.15);

  /// Повертає колір з кастомним затемненням для стану натискання.
  ///
  /// [amount] — рівень затемнення (0.0 – 1.0, за замовчуванням 0.1).
  Color pressedCustom(double amount) => darken(amount);

  /// Повертає колір з кастомним засвітленням для стану наведення.
  ///
  /// [amount] — рівень засвітлення (0.0 – 1.0, за замовчуванням 0.05).
  Color hoveredCustom(double amount) => lighten(amount);

  // ─── Гейміфікаційні ефекти ──────────────────────────────────────────

  /// Повертає колір з додаванням «сяйва» (glow).
  ///
  /// Засвітлює колір та створює напівпрозору версію для тіні.
  /// Використовується для іконок XP, монеток, бейджів.
  ///
  /// [factor] — інтенсивність сяйва (за замовчуванням 0.3).
  Color glow({double factor = 0.3}) {
    return lighten(factor).withCustomAlpha(0.5);
  }

  /// Інвертує колір (повертає протилежний на кольоровому колесі + інвертує світлість).
  Color get inverted {
    final hsl = HSLColor.fromColor(this);
    final invertedLightness = 1.0 - hsl.lightness;
    return hsl
        .withHue((hsl.hue + 180) % 360)
        .withLightness(invertedLightness.clamp(0.0, 1.0))
        .toColor();
  }

  /// Повертає колір із прозорою версією для анімацій «зникнення».
  ///
  /// [ratio] — частка непрозорості (0.0 = повністю прозорий, 1.0 = оригінал).
  Color fade(double ratio) {
    return withCustomAlpha(ratio.clamp(0.0, 1.0));
  }

  /// Повертає список кольорів для анімації пульсації.
  ///
  /// Генерує [steps] проміжних кольорів від оригіналу до прозорого.
  ///
  /// [steps] — кількість кроків анімації (за замовчуванням 5).
  List<Color> pulseColors({int steps = 5}) {
    return List.generate(steps + 1, (i) {
      return withCustomAlpha(1.0 - (i / steps));
    });
  }

  /// Повертає список кольорів для анімації «хвилі».
  ///
  /// Генерує проміжні кольори між двома відтінками.
  ///
  /// [toColor] — кінцевий колір хвилі.
  /// [steps] — кількість кроків (за замовчуванням 5).
  List<Color> waveColors(Color toColor, {int steps = 5}) {
    return List.generate(steps + 1, (i) {
      return blend(toColor, i / steps);
    });
  }

  /// Повертає розмитий варіант кольору для фонових ефектів.
  ///
  /// Створює колір із зниженою непрозорістю для використання
  /// у BoxShadow з MaskFilter.blur.
  ///
  /// [opacity] — рівень непрозорості (за замовчуванням 0.3).
  Color blurred({double opacity = 0.3}) {
    return withCustomAlpha(opacity);
  }

  /// Повертає колір для ефекту «мерехтіння» (shimmer).
  ///
  /// Генерує колір, що чергується між світлим та напівпрозорим.
  /// Використовується для loading-індикаторів та скелетонів.
  ///
  /// [t] — прогрес анімації (0.0 – 1.0).
  Color shimmer(double t) {
    final hsl = HSLColor.fromColor(this);
    final lightness =
        (hsl.lightness + 0.2 * math.sin(t * math.pi * 2)).clamp(0.0, 1.0);
    return hsl.withLightness(lightness).toColor();
  }

  /// Генерує палітру кольорів для анімації «золоте сяйво».
  ///
  /// Повертає [count] кольорів від золотого до прозорого.
  ///
  /// [count] — кількість кольорів (за замовчуванням 5).
  static List<Color> goldGlowPalette({int count = 5}) {
    const gold = Color(0xFFFFD600);
    return List.generate(count, (i) {
      final t = i / (count - 1).clamp(1, count);
      return gold.blend(const Color(0xFFFF9100), t * 0.5)
          .withCustomAlpha(1.0 - t * 0.8);
    });
  }

  /// Генерує палітру кольорів для анімації «вогняна серія».
  ///
  /// Повертає [count] кольорів від жовтого через помаранчевий до червоного.
  ///
  /// [count] — кількість кольорів (за замовчуванням 5).
  static List<Color> firePalette({int count = 5}) {
    const yellow = Color(0xFFFFD600);
    const orange = Color(0xFFFF9100);
    const red = Color(0xFFFF1744);

    return List.generate(count, (i) {
      final t = i / (count - 1).clamp(1, count);
      if (t < 0.5) {
        return Color.lerp(yellow, orange, t * 2) ?? yellow;
      }
      return Color.lerp(orange, red, (t - 0.5) * 2) ?? orange;
    });
  }

  // ─── Дебаг та опис ─────────────────────────────────────────────────

  /// Повертає детальний рядок-опис кольору для дебагу.
  ///
  /// Включає hex, RGB, HSL, HSV та назву тону.
  String get debugDescription {
    final hsl = HSLColor.fromColor(this);
    return 'Color('
        'hex: $toHex, '
        'rgb: (${red.toInt()}, ${green.toInt()}, ${blue.toInt()}), '
        'hsl: (${hsl.hue.toStringAsFixed(1)}°, ${(hsl.saturation * 100).toStringAsFixed(0)}%, ${(hsl.lightness * 100).toStringAsFixed(0)}%), '
        'tone: $hueName, '
        'luminance: ${luminance.toStringAsFixed(3)})';
  }

  /// Повертає короткий рядок-опис кольору.
  ///
  /// Формат: `#RRGGBB (Назва)`.
  String get shortDescription => '$toHexShort ($hueName)';

  /// Чи є колір повністю прозорим (alpha = 0).
  bool get isTransparent => alpha == 0.0;

  /// Чи є колір повністю непрозорим (alpha = 1).
  bool get isOpaque => alpha == 1.0;

  /// Перевіряє, чи колір є дійсним (всі компоненти в межах 0–255).
  bool get isValid => red >= 0 && red <= 255 && green >= 0 && green <= 255 && blue >= 0 && blue <= 255;

  // ─── LAB та перцептуальні кольорові простори ─────────────────────

  /// Повертає колір у форматі HSL як записаний рядок.
  ///
  /// Формат: `hsl(H, S%, L%)`.
  ///
  /// Приклад: `Color(0xFF0070D1).toHSLString()` → `"hsl(208, 100%, 41%)"`.
  String toHSLString() {
    final hsl = HSLColor.fromColor(this);
    return 'hsl(${hsl.hue.round()}, ${(hsl.saturation * 100).round()}%, ${(hsl.lightness * 100).round()}%)';
  }

  /// Повертає колір у форматі HSV як записаний рядок.
  ///
  /// Формат: `hsv(H, S%, V%)`.
  ///
  /// Приклад: `Color(0xFFFF0000).toHSVString()` → `"hsv(0, 100%, 100%)"`.
  String toHSVString() {
    final hsv = HSVColor.fromColor(this);
    return 'hsv(${hsv.hue.round()}, ${(hsv.saturation * 100).round()}%, ${(hsv.value * 100).round()}%)';
  }

  /// Обчислює наближену кольорову температуру в Кельвінах.
  ///
  /// Використовує алгоритм Таннена-Різа для перетворення RGB → температура.
  ///
  /// Повертає значення від ~1000K (теплий/світлий) до ~40000K (холодний/синій).
  ///
  /// Базується на формулі:
  /// ```
  /// temp = 449 * 0.35 + 114 * 0.65 − (114 * 0.65 − 221 * 0.35) * ((b * 0.35 − r * 0.65) / Δ)
  /// ```
  double get colorTemperature {
    final r = red.toInt();
    final g = green.toInt();
    final b = blue.toInt();

    // Робимо наближену перетворення у температуру (Tanner Helland algorithm)
    var temp = 0.0;
    if (r <= b) {
      temp = b;
    } else {
      temp = r;
    }

    temp = temp - b;
    temp = temp / 100.0;
    temp = temp + 2.0;

    // Обчислення червоної компоненти
    final redComp = r / 255.0;
    // Обчислення зеленої компоненти
    final greenComp = g / 255.0;
    // Обчислення синьої компоненти
    final blueComp = b / 255.0;

    if (redComp <= blueComp) {
      temp = -1.0;
    }

    // Наближене значення температури в Кельвінах (1000–40000)
    return (10000 * (blueComp / redComp)).clamp(1000, 40000);
  }

  /// Повертає опис температури кольору українською.
  ///
  /// 'Дуже теплий', 'Теплий', 'Нейтральний', 'Холодний', 'Дуже холодний'.
  String get colorTemperatureDescription {
    final temp = colorTemperature;
    if (temp < 3500) return 'Дуже теплий';
    if (temp < 5000) return 'Теплий';
    if (temp < 6500) return 'Нейтральний';
    if (temp < 8000) return 'Холодний';
    return 'Дуже холодний';
  }

  /// Обчислює Delta-E (CIE76) між цим кольором та [other].
  ///
  /// Delta-E вимірює перцептуальну відмінність між кольорами.
  /// Значення < 1.0 — непомітна різниця, 1–2 — уважний огляд,
  /// 2–10 — помітна, > 10 — значна різниця.
  ///
  /// [other] — колір для порівняння.
  /// Повертає Delta-E76 значення.
  double deltaE(Color other) {
    // Перетворення RGB → LAB (наближене через XYZ)
    final lab1 = _rgbToLab(red.toInt(), green.toInt(), blue.toInt());
    final lab2 = _rgbToLab(other.red.toInt(), other.green.toInt(), other.blue.toInt());

    final dL = lab1[0] - lab2[0];
    final da = lab1[1] - lab2[1];
    final db = lab1[2] - lab2[2];

    return math.sqrt(dL * dL + da * da + db * db);
  }

  /// Чи є перцептуальна різниця між цим кольором та [other] непомітною.
  ///
  /// Повертає `true`, якщо Delta-E < 1.0.
  bool isPerceptuallySame(Color other) => deltaE(other) < 1.0;

  /// Чи є перцептуальна різниця між кольорами помітною.
  ///
  /// Повертає `true`, якщо Delta-E >= 2.0.
  bool isPerceptuallyDifferent(Color other) => deltaE(other) >= 2.0;

  /// Наближене перетворення RGB → LAB.
  ///
  /// Повертає масив [L, a, b] де:
  /// - L — світлість (0–100)
  /// - a — зелено-червона вісь (-128–127)
  /// - b — жовто-синя вісь (-128–127)
  static List<double> _rgbToLab(int r, int g, int b) {
    // RGB → сітка (0–1)
    double rl = r / 255.0;
    double gl = g / 255.0;
    double bl = b / 255.0;

    // sRGB gamma correction
    rl = rl > 0.04045 ? math.pow((rl + 0.055) / 1.055, 2.4) : rl / 12.92;
    gl = gl > 0.04045 ? math.pow((gl + 0.055) / 1.055, 2.4) : gl / 12.92;
    bl = bl > 0.04045 ? math.pow((bl + 0.055) / 1.055, 2.4) : bl / 12.92;

    // RGB → XYZ (D65)
    final x = (rl * 0.4124564 + gl * 0.3575761 + bl * 0.1804375) / 0.95047;
    final y = (rl * 0.2126729 + gl * 0.7151522 + bl * 0.0721750);
    final z = (rl * 0.0193339 + gl * 0.1191920 + bl * 0.9503041) / 1.08883;

    // XYZ → LAB
    final fx = x > 0.008856 ? math.pow(x, 1 / 3) : (7.787 * x) + 16 / 116;
    final fy = y > 0.008856 ? math.pow(y, 1 / 3) : (7.787 * y) + 16 / 116;
    final fz = z > 0.008856 ? math.pow(z, 1 / 3) : (7.787 * z) + 16 / 116;

    final l = (116 * fy) - 16;
    final a = 500 * (fx - fy);
    final bv = 200 * (fy - fz);

    return [l, a, bv];
  }

  // ─── Продвинуте мікшування ───────────────────────────────────────

  /// Мультиплікативне мікшування (Multiply blend mode).
  ///
  /// Результат = this × other. Зменшує яскравість — корисний для ефекту тіні.
  ///
  /// [other] — колір для мікшування.
  Color multiply(Color other) {
    final r = (red / 255.0 * (other.red / 255.0) * 255).round().clamp(0, 255);
    final g = (green / 255.0 * (other.green / 255.0) * 255).round().clamp(0, 255);
    final b = (blue / 255.0 * (other.blue / 255.0) * 255).round().clamp(0, 255);
    return Color.fromARGB(255, r, g, b);
  }

  /// Screen blend mode — інвертує, множить, інвертує знову.
  ///
  /// Результат збільшує яскравість — корисний для ефекту підсвічування.
  ///
  /// [other] — колір для мікшування.
  Color screen(Color other) {
    final r = (255 - ((255 - red) * (255 - other.red) / 255)).round().clamp(0, 255);
    final g = (255 - ((255 - green) * (255 - other.green) / 255)).round().clamp(0, 255);
    final b = (255 - ((255 - blue) * (255 - other.blue) / 255)).round().clamp(0, 255);
    return Color.fromARGB(255, r, g, b);
  }

  /// Overlay blend mode — комбінація multiply та screen.
  ///
  /// [other] — колір для накладання.
  Color overlay(Color other) {
    final result = multiply(other);
    if (other.luminance < 0.5) {
      return result;
    }
    return screen(other);
  }

  /// Soft light blend mode — м'яке освітлення/затемнення.
  ///
  /// [other] — колір для накладання.
  Color softLight(Color other) {
    final r = _softLightChannel(red.toInt(), other.red.toInt());
    final g = _softLightChannel(green.toInt(), other.green.toInt());
    final b = _softLightChannel(blue.toInt(), other.blue.toInt());
    return Color.fromARGB(255, r, g, b);
  }

  /// Допоміжний метод для soft light каналу.
  static int _softLightChannel(int base, int blend) {
    final b = base / 255.0;
    final l = blend / 255.0;
    if (l < 0.5) {
      return ((2 * b * l + b * b * (255 - 2 * l)).round()).clamp(0, 255);
    }
    return ((2 * b * (255 - l) + math.sqrt(b) * (2 * l - 255)).round()).clamp(0, 255);
  }

  // ─── Квантування та палітри ────────────────────────────────────────

  /// Квантує колір до заданої кількості бітів на канал.
  ///
  /// [bits] — кількість бітів на канал (1–8, за замовчуванням 4 = 16 кольорів на канал).
  ///
  /// Корисний для створення спрощених палітр та піксель-арту.
  Color quantize(int bits) {
    assert(bits >= 1 && bits <= 8, 'bits must be between 1 and 8');
    final shift = 8 - bits;
    final mask = 0xFF << shift;
    final r = (red.toInt() & mask);
    final g = (green.toInt() & mask);
    final b = (blue.toInt() & mask);
    return Color.fromARGB(alpha.toInt(), r, g, b);
  }

  /// Генерує повну палітру Material Design (50–900 + A100/A200/A400/A700).
  ///
  /// Повертає карту `{'50': Color, '100': Color, ..., 'A700': Color}`.
  Map<String, Color> toMaterialSwatch() {
    final hsl = HSLColor.fromColor(this);
    final baseHue = hsl.hue;

    final swatch = <String, Color>{};
    // Тонові відтінки
    final lightnesses = [0.95, 0.90, 0.80, 0.70, 0.60, 0.50, 0.40, 0.30, 0.20, 0.12];
    final labels = ['50', '100', '200', '300', '400', '500', '600', '700', '800', '900'];

    for (var i = 0; i < lightnesses.length; i++) {
      final l = lightnesses[i];
      final s = (i < 3) ? (hsl.saturation * 0.6).clamp(0.0, 1.0) : hsl.saturation;
      swatch[labels[i]] = hsl
          .withLightness(l)
          .withSaturation(s)
          .toColor();
    }

    // Акцентні відтінки
    final accentLights = [0.75, 0.60, 0.45, 0.30];
    final accentLabels = ['A100', 'A200', 'A400', 'A700'];

    for (var i = 0; i < accentLights.length; i++) {
      swatch[accentLabels[i]] = hsl
          .withLightness(accentLights[i])
          .withSaturation(hsl.saturation.clamp(0.6, 1.0))
          .toColor();
    }

    return swatch;
  }

  /// Генерує послідовність кольорів від цього до [target].
  ///
  /// [steps] — кількість проміжних кольорів (мінімум 1).
  /// Повертає список, де перший елемент — цей колір, останній — [target].
  List<Color> interpolateTo(Color target, {int steps = 5}) {
    assert(steps >= 1, 'steps must be at least 1');
    return List.generate(steps + 2, (i) {
      final t = i / (steps + 1);
      return Color.lerp(this, target, t) ?? this;
    });
  }

  /// Генерує випадкову варіацію цього кольору.
  ///
  /// [maxDelta] — максимальне відхилення кожного каналу (0–127, за замовчуванням 20).
  Color randomVariation({int maxDelta = 20}) {
    assert(maxDelta >= 0 && maxDelta <= 127, 'maxDelta must be 0–127');
    final rng = math.Random();
    final r = (red.toInt() + (rng.nextInt(maxDelta * 2 + 1) - maxDelta)).clamp(0, 255);
    final g = (green.toInt() + (rng.nextInt(maxDelta * 2 + 1) - maxDelta)).clamp(0, 255);
    final b = (blue.toInt() + (rng.nextInt(maxDelta * 2 + 1) - maxDelta)).clamp(0, 255);
    return Color.fromARGB(alpha.toInt(), r, g, b);
  }

  /// Повертає кольори основних каналів окремо.
  ///
  /// Корисний для аналізу та відладки.
  ColorChannelValues get channelValues => ColorChannelValues(
        red: red.toInt(),
        green: green.toInt(),
        blue: blue.toInt(),
        alpha: alpha,
      );

  /// Перевіряє рівність з [other] із заданою толерантністю.
  ///
  /// [tolerance] — максимальна різниця для кожного каналу (0–255, за замовчуванням 1).
  bool equalsWithTolerance(Color other, {int tolerance = 1}) {
    assert(tolerance >= 0 && tolerance <= 255, 'tolerance must be 0–255');
    final dr = (red - other.red).abs();
    final dg = (green - other.green).abs();
    final db = (blue - other.blue).abs();
    final da = (alpha - other.alpha).abs();
    return dr <= tolerance && dg <= tolerance && db <= tolerance && da <= tolerance;
  }

  /// Перевіряє, чи є колір ахроматичним (сірим, без кольору).
  ///
  /// Повертає `true`, якщо насиченість HSL < 0.05.
  bool get isAchromatic {
    final hsl = HSLColor.fromColor(this);
    return hsl.saturation < 0.05;
  }

  /// Повертає колір з заданими відтінком (hue).
  ///
  /// Зберігає поточну насиченість та світлість, але змінює відтінок.
  ///
  /// [hue] — новий відтінок (0.0 – 360.0).
  Color withHue(double hue) {
    final hsl = HSLColor.fromColor(this);
    return hsl.withHue(hue.clamp(0.0, 360.0)).toColor();
  }

  /// Повертає колір з заданою насиченістю.
  ///
  /// [saturation] — нова насиченість (0.0 – 1.0).
  Color withSaturation(double saturation) {
    final hsl = HSLColor.fromColor(this);
    return hsl.withSaturation(saturation.clamp(0.0, 1.0)).toColor();
  }

  /// Повертає колір з заданою світлістю.
  ///
  /// [lightness] — нова світлість (0.0 – 1.0).
  Color withLightness(double lightness) {
    final hsl = HSLColor.fromColor(this);
    return hsl.withLightness(lightness.clamp(0.0, 1.0)).toColor();
  }

  /// Повертає значення насиченості кольору (0.0 – 1.0).
  double get saturation {
    final hsl = HSLColor.fromColor(this);
    return hsl.saturation;
  }

  /// Повертає значення відтінку кольору (0.0 – 360.0).
  double get hue {
    final hsl = HSLColor.fromColor(this);
    return hsl.hue;
  }

  /// Повертає значення світлості кольору (0.0 – 1.0).
  double get lightness {
    final hsl = HSLColor.fromColor(this);
    return hsl.lightness;
  }

  /// Повертає значення значення кольору HSV (0.0 – 1.0).
  double get value {
    final hsv = HSVColor.fromColor(this);
    return hsv.value;
  }

  /// Перетворює колір у формат ARGB ціле число.
  ///
  /// Зручний для серіалізації та збереження.
  int get toIntValue => (alpha * 255).round() << 24 |
      (red * 255).round() << 16 |
      (green * 255).round() << 8 |
      (blue * 255).round();

  // ─── Приватні методи ──────────────────────────────────────────────

  /// Обчислює контрастне співвідношення між двома кольорами (WCAG 2.0).
  ///
  /// Повертає значення від 1.0 (без контрасту) до 21.0 (максимальний контраст).
  static double _contrastRatio(Color c1, Color c2) {
    final l1 = c1.computeLuminance();
    final l2 = c2.computeLuminance();
    final lighter = math.max(l1, l2);
    final darker = math.min(l1, l2);
    return (lighter + 0.05) / (darker + 0.05);
  }

  // ─── Oklab колірний простір ────────────────────────────────────────

  /// Перетворює колір у Oklab колірний простір і повертає компоненти L, a, b.
  ///
  /// Oklab — це перцептивно-рівномірний колірний простір, який краще
  /// відображає людське сприйняття кольору порівняно з RGB або HSL.
  ///
  /// Повертає [OklabColor] з компонентами:
  /// - [L] — світлість (0.0 = чорний, 1.0 = білий)
  /// - [a] — зелено-червона вісь (негативний = зелений, позитивний = червоний)
  /// - [b] — сине-жовта вісь (негативний = синій, позитивний = жовтий)
  OklabColor toOklab() {
    final r = red / 255.0;
    final g = green / 255.0;
    final b = blue / 255.0;

    // sRGB → лінеарний RGB
    final lr = r <= 0.04045 ? r / 12.92 : math.pow((r + 0.055) / 1.055, 2.4);
    final lg = g <= 0.04045 ? g / 12.92 : math.pow((g + 0.055) / 1.055, 2.4);
    final lb = b <= 0.04045 ? b / 12.92 : math.pow((b + 0.055) / 1.055, 2.4);

    // Лінеарний RGB → LMS
    final l_ = 0.4122214708 * lr + 0.5363325363 * lg + 0.0514459929 * lb;
    final m_ = 0.2119034982 * lr + 0.6806995451 * lg + 0.1073969566 * lb;
    final s_ = 0.0883024619 * lr + 0.2817188376 * lg + 0.6299787005 * lb;

    // Кубічний корінь для LMS
    final lC = math.pow(l_, 1.0 / 3.0);
    final mC = math.pow(m_, 1.0 / 3.0);
    final sC = math.pow(s_, 1.0 / 3.0);

    // LMS → Oklab
    return OklabColor(
      L: (0.2104542553 * lC + 0.7936177850 * mC - 0.0040720468 * sC).clamp(0.0, 1.0),
      a: (1.9779984951 * lC - 2.4285922050 * mC + 0.4505937099 * sC).clamp(-0.5, 0.5),
      b: (0.0259040371 * lC + 0.7827717662 * mC - 0.8086757660 * sC).clamp(-0.5, 0.5),
    );
  }

  /// Створює колір з Oklab компонентів.
  ///
  /// [L] — світлість (0.0–1.0).
  /// [a] — зелено-червона вісь (-0.5–0.5).
  /// [b] — сине-жовта вісь (-0.5–0.5).
  static Color fromOklab(double L, double a, double b) {
    final l_ = L + 0.3963377774 * a + 0.2158037573 * b;
    final m_ = L - 0.1055613458 * a - 0.0638541728 * b;
    final s_ = L - 0.0894841775 * a - 1.2914855480 * b;

    final l = l_ * l_ * l_;
    final m = m_ * m_ * m_;
    final s = s_ * s_ * s_;

    final lr = +4.0767416621 * l - 3.3077115913 * m + 0.2309699292 * s;
    final lg = -1.2684380046 * l + 2.6097574011 * m - 0.3413193965 * s;
    final lb = -0.0041960863 * l - 0.7034186147 * m + 1.7076147010 * s;

    // Лінеарний RGB → sRGB
    int toSrgb(double c) {
      final v = c <= 0.0031308 ? 12.92 * c : 1.055 * math.pow(c, 1.0 / 2.4) - 0.055;
      return (v.clamp(0.0, 1.0) * 255).round();
    }

    return Color.fromARGB(255, toSrgb(lr), toSrgb(lg), toSrgb(lb));
  }

  /// Обчислює відстань CIEDE2000-подібну між цим кольором та [other].
  ///
  /// Використовує Oklab простір для перцептивно-точного порівняння.
  /// Повертає значення від 0.0 (ідентичні) до ~0.5 (дуже різні).
  double perceptualDistance(Color other) {
    final lab1 = toOklab();
    final lab2 = other.toOklab();
    final dL = lab1.L - lab2.L;
    final da = lab1.a - lab2.a;
    final db = lab1.b - lab2.b;
    return math.sqrt(dL * dL + da * da + db * db);
  }

  // ─── Точкові кольори Material Design ───────────────────────────────

  /// Генерує повну палітру Material Design з цього кольору.
  ///
  /// Повертає 13 відтінків: від найсвітлішого (50) до найтемнішого (950).
  /// Використовує HSL для генерації рівномірних відтінків.
  ///
  /// Порядок: [50, 100, 200, 300, 400, 500, 600, 700, 800, 900, 950].
  List<Color> toMaterialPalette() {
    final hsl = HSLColor.fromColor(this);
    final shades = <Color>[];

    final lightnessStops = [0.97, 0.93, 0.84, 0.74, 0.62, 0.50, 0.42, 0.34, 0.26, 0.20, 0.14];

    for (final l in lightnessStops) {
      final satMult = l > 0.5 ? 0.5 + (1.0 - l) : 0.7 + l * 0.6;
      final s = (hsl.saturation * satMult).clamp(0.0, 1.0);
      final adjustedHsl = hsl.withLightness(l).withSaturation(s);
      shades.add(adjustedHsl.toColor());
    }

    return shades;
  }

  /// Повертає конкретний відтінок Material з цієї палітри.
  ///
  /// [shade] — номер відтінку (50, 100, 200, ..., 950).
  /// За замовчуванням повертає відтінок 500 (базовий).
  Color materialShade(int shade) {
    final palette = toMaterialPalette();
    final index = switch (shade) {
      50 => 0,
      100 => 1,
      200 => 2,
      300 => 3,
      400 => 4,
      500 => 5,
      600 => 6,
      700 => 7,
      800 => 8,
      900 => 9,
      950 => 10,
      _ => 5,
    };
    return palette[index];
  }

  // ─── Палітри для UI ───────────────────────────────────────────────

  /// Генерує палітру відтінків (shades) з чорним.
  ///
  /// [steps] — кількість кроків (за замовчуванням 10).
  /// Повертає список від оригінального до чорного.
  List<Color> shadePalette({int steps = 10}) {
    return List.generate(steps, (i) {
      final t = i / (steps - 1);
      return darken(t * 0.7);
    });
  }

  /// Генерує палітру відтінків (tints) з білим.
  ///
  /// [steps] — кількість кроків (за замовчуванням 10).
  /// Повертає список від оригінального до білого.
  List<Color> tintPalette({int steps = 10}) {
    return List.generate(steps, (i) {
      final t = i / (steps - 1);
      return lighten(t * 0.7);
    });
  }

  /// Генерує тональну палітру (tone scale).
  ///
  /// Корисно для створення однорідної палітри для Material You / M3.
  /// [steps] — кількість кроків.
  /// [minLightness] — мінімальна світлість (0.0–1.0).
  /// [maxLightness] — максимальна світлість (0.0–1.0).
  List<Color> toneScale({
    int steps = 12,
    double minLightness = 0.05,
    double maxLightness = 0.95,
  }) {
    final hsl = HSLColor.fromColor(this);
    return List.generate(steps, (i) {
      final t = i / (steps - 1);
      final lightness = minLightness + t * (maxLightness - minLightness);
      return hsl.withLightness(lightness).toColor();
    });
  }

  // ─── Додаткові фільтри ─────────────────────────────────────────────

  /// Застосовує сепія-ефект до кольору.
  ///
  /// [amount] — інтенсивність ефекту (0.0 – 1.0).
  /// Високі значення дають теплий коричневий відтінок.
  Color sepia(double amount) {
    final r = red / 255.0;
    final g = green / 255.0;
    final b = blue / 255.0;

    final sr = (r * 0.393 + g * 0.769 + b * 0.189).clamp(0.0, 1.0);
    final sg = (r * 0.349 + g * 0.686 + b * 0.168).clamp(0.0, 1.0);
    final sb = (r * 0.272 + g * 0.534 + b * 0.131).clamp(0.0, 1.0);

    final nr = (r + (sr - r) * amount).clamp(0.0, 1.0);
    final ng = (g + (sg - g) * amount).clamp(0.0, 1.0);
    final nb = (b + (sb - b) * amount).clamp(0.0, 1.0);

    return Color.fromARGB(
      (alpha * 255).round(),
      (nr * 255).round(),
      (ng * 255).round(),
      (nb * 255).round(),
    );
  }

  /// Застосовує海报 (posterize) ефект — зменшує кількість кольорів.
  ///
  /// [levels] — кількість рівнів на канал (2–256).
  /// Менші значення дають більш «плакатний» ефект.
  Color posterize(int levels) {
    assert(levels >= 2 && levels <= 256, 'levels must be between 2 and 256');
    final step = 255.0 / (levels - 1);
    final nr = (red / step).round() * step;
    final ng = (green / step).round() * step;
    final nb = (blue / step).round() * step;
    return Color.fromARGB(
      (alpha * 255).round(),
      nr.round().clamp(0, 255),
      ng.round().clamp(0, 255),
      nb.round().clamp(0, 255),
    );
  }

  /// Обертає відтінок кольору (hue rotation).
  ///
  /// [degrees] — кут повороту у градусах (0–360).
  /// Позитивні значення обертають за годинниковою стрілкою.
  Color rotateHue(double degrees) {
    final hsl = HSLColor.fromColor(this);
    final newHue = (hsl.hue + degrees) % 360;
    return hsl.withHue(newHue < 0 ? newHue + 360 : newHue).toColor();
  }

  /// Додає хроматичну аберацію — зміщує канали відносно один одного.
  ///
  /// [offset] — величина зміщення (0–10).
  Color chromaticAberration(int offset) {
    final r = (red + offset).clamp(0, 255);
    final b = (blue - offset).clamp(0, 255);
    return Color.fromARGB((alpha * 255).round(), r, green.toInt(), b);
  }

  // ─── Генератори палітр ─────────────────────────────────────────────

  /// Генерує випадковий колір на основі цього кольору.
  ///
  /// Зберігає відтінок (hue), але випадково змінює насиченість та світлість.
  /// [random] — об'єкт генератора випадкових чисел.
  static Color randomVariant(Color base, math.Random random) {
    final hsl = HSLColor.fromColor(base);
    final newSat = (hsl.saturation + (random.nextDouble() - 0.5) * 0.4)
        .clamp(0.1, 1.0);
    final newLight = (hsl.lightness + (random.nextDouble() - 0.5) * 0.4)
        .clamp(0.1, 0.9);
    return hsl.withSaturation(newSat).withLightness(newLight).toColor();
  }

  /// Генерує пастельну версію кольору.
  ///
  /// Зменшує насиченість та збільшує світлість.
  Color get pastel => HSLColor.fromColor(this)
      .withSaturation(0.35)
      .withLightness(0.78)
      .toColor();

  /// Генерує яскраву (vivid) версію кольору.
  ///
  /// Збільшує насиченість та встановлює світлість близько 0.55.
  Color get vivid => HSLColor.fromColor(this)
      .withSaturation(1.0)
      .withLightness(0.55)
      .toColor();

  /// Генерує приглушену (muted) версію кольору.
  ///
  /// Зменшує насиченість до ~30% та встановлює світлість 0.50.
  Color get muted => HSLColor.fromColor(this)
      .withSaturation(0.30)
      .withLightness(0.50)
      .toColor();

  /// Генерує глибоку (deep) версію кольору.
  ///
  /// Збільшує насиченість та зменшує світлість.
  Color get deep => HSLColor.fromColor(this)
      .withSaturation(0.70)
      .withLightness(0.30)
      .toColor();

  /// Генерує м'яку (soft) версію кольору.
  ///
  /// Помірно зменшує насиченість та збільшує світлість.
  Color get soft => HSLColor.fromColor(this)
      .withSaturation(0.50)
      .withLightness(0.75)
      .toColor();

  // ─── Перетворення в рядок-опис ─────────────────────────────────────

  /// Повертає детальний опис кольору.
  ///
  /// Включає hex, RGB, HSL та назву тону.
  String get detailedDescription {
    final hsl = HSLColor.fromColor(this);
    return 'Color(${toHex()}) — ${hueName}, '
        'H=${hsl.hue.toStringAsFixed(0)}° '
        'S=${(hsl.saturation * 100).toStringAsFixed(0)}% '
        'L=${(hsl.lightness * 100).toStringAsFixed(0)}%';
  }

  /// Перевіряє, чи колір є ахроматичним (без кольору).
  ///
  /// Ахроматичні кольори: чорний, білий, сірий.
  bool get isAchromatic => HSLColor.fromColor(this).saturation < 0.08;

  /// Перевіряє, чи колір є хроматичним (має відтінок).
  ///
  /// Зворотній до [isAchromatic].
  bool get isChromatic => !isAchromatic;

  /// Перевіряє, чи цей колір є аналогічним до [other] (відстань hue < 30°).
  bool isAnalogousTo(Color other) {
    final hsl1 = HSLColor.fromColor(this);
    final hsl2 = HSLColor.fromColor(other);
    double diff = (hsl1.hue - hsl2.hue).abs();
    if (diff > 180) diff = 360 - diff;
    return diff < 30;
  }

  /// Перевіряє, чи цей колір є комплементарним до [other] (hue ~180°).
  bool isComplementaryTo(Color other) {
    final hsl1 = HSLColor.fromColor(this);
    final hsl2 = HSLColor.fromColor(other);
    double diff = (hsl1.hue - hsl2.hue).abs();
    if (diff > 180) diff = 360 - diff;
    return diff > 150 && diff < 210;
  }

  /// Повертає колір з мінімальною відстанню до [other].
  ///
  /// Зберігає відтінок [other], але адаптує насиченість та світлість.
  Color closestTo(Color other) {
    final hsl1 = HSLColor.fromColor(this);
    final hsl2 = HSLColor.fromColor(other);
    return hsl1
        .withHue(hsl2.hue)
        .withSaturation((hsl1.saturation + hsl2.saturation) / 2)
        .withLightness((hsl1.lightness + hsl2.lightness) / 2)
        .toColor();
  }
}

// ─── Допоміжні класи ───────────────────────────────────────────────

/// Клас для представлення кольору в Oklab колірному просторі.
///
/// Oklab — перцептивно-рівномірний колірний простір, розроблений Björn Ottosson.
/// Краще відображає людське сприйняття кольору порівняно з RGB або HSL.
///
/// Приклад:
/// ```dart
/// final oklab = Colors.blue.toOklab();
/// print('L=${oklab.L}, a=${oklab.a}, b=${oklab.b}');
/// ```
class OklabColor {
  /// Світлість (0.0 = чорний, 1.0 = білий).
  final double L;

  /// Зелено-червона вісь (-0.5 = зелений, 0.5 = червоний).
  final double a;

  /// Сине-жовта вісь (-0.5 = синій, 0.5 = жовтий).
  final double b;

  /// Створює OklabColor з компонентів L, a, b.
  const OklabColor({required this.L, required this.a, required this.b});

  /// Повертає колір Flutter з цього OklabColor.
  Color toColor() => ColorExt.fromOklab(L, a, b);

  /// Евклідова відстань до іншого OklabColor.
  double distanceTo(OklabColor other) {
    final dL = L - other.L;
    final da = a - other.a;
    final db = b - other.b;
    return math.sqrt(dL * dL + da * da + db * db);
  }

  /// Лінійна інтерполяція між цим та [other] OklabColor.
  OklabColor lerpTo(OklabColor other, double t) {
    return OklabColor(
      L: L + (other.L - L) * t,
      a: a + (other.a - a) * t,
      b: b + (other.b - b) * t,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OklabColor &&
          other.L == L &&
          other.a == a &&
          other.b == b;

  @override
  int get hashCode => Object.hash(L, a, b);

  @override
  String toString() =>
      'OklabColor(L: ${L.toStringAsFixed(3)}, a: ${a.toStringAsFixed(3)}, b: ${b.toStringAsFixed(3)})';
}

/// Клас, що зберігає окремі значення каналів кольору.
///
/// Використовується для дебагу та аналізу кольорів.
///
/// Приклад:
/// ```dart
/// final channels = Colors.blue.channelValues;
/// print('R=${channels.red}, G=${channels.green}, B=${channels.blue}');
/// ```
class ColorChannelValues {
  /// Червоний канал (0–255).
  final int red;

  /// Зелений канал (0–255).
  final int green;

  /// Синій канал (0–255).
  final int blue;

  /// Альфа-канал (0.0 – 1.0).
  final double alpha;

  /// Створює об'єкт з окремими значеннями каналів.
  const ColorChannelValues({
    required this.red,
    required this.green,
    required this.blue,
    required this.alpha,
  });

  /// Повертає кольор із цих значень.
  Color toColor() => Color.fromARGB(
        (alpha * 255).round().clamp(0, 255),
        red.clamp(0, 255),
        green.clamp(0, 255),
        blue.clamp(0, 255),
      );

  /// Повертає опис каналів як рядок.
  @override
  String toString() =>
      'ColorChannelValues(r: $red, g: $green, b: $blue, a: ${alpha.toStringAsFixed(2)})';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ColorChannelValues &&
          other.red == red &&
          other.green == green &&
          other.blue == blue &&
          other.alpha == alpha;

  @override
  int get hashCode => Object.hash(red, green, blue, alpha);
}
