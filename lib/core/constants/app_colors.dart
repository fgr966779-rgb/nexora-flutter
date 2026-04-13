import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';

/// PS5 dark theme colors.
///
/// Містить повний набір кольорів для темної теми Nexora PS5,
/// включаючи базові кольори, градієнти, стани інтерактивних елементів
/// та спеціалізовані палітри для гейміфікації.
///
/// Клас надає також допоміжні методи для маніпуляції кольорами,
/// валідації, серіалізації та фабричні методи для створення
/// повних [ColorScheme] та [ThemeData].
class AppColorsPS5 {
  AppColorsPS5._();

  // ─── Базові кольори ───────────────────────────────────────────────

  /// Основний колір фону додатку.
  static const Color background = Color(0xFF0A0A0F);

  /// Колір поверхні (картки, модальні вікна).
  static const Color surface = Color(0xFF14141F);

  /// Колір стандартної картки.
  static const Color card = Color(0xFF1C1C2E);

  /// Колір піднятої картки (з тінню).
  static const Color cardElevated = Color(0xFF24243A);

  /// Колір рамок та роздільників.
  static const Color border = Color(0xFF2A2A40);

  // ─── Текст ─────────────────────────────────────────────────────────

  /// Основний колір тексту.
  static const Color textPrimary = Color(0xFFF0F0F5);

  /// Другорядний колір тексту (підписи, описи).
  static const Color textSecondary = Color(0xFF8888A0);

  /// Колір тексту-підказки (placeholder).
  static const Color textHint = Color(0xFF555570);

  /// Колір тексту з акцентом.
  static const Color textAccent = Color(0xFF4D9AE8);

  /// Колір тексту успіху.
  static const Color textSuccess = Color(0xFF00C853);

  /// Колір тексту помилки.
  static const Color textError = Color(0xFFFF1744);

  /// Колір тексту попередження.
  static const Color textWarning = Color(0xFFFFB300);

  // ─── Акцентні кольори ─────────────────────────────────────────────

  /// Основний акцентний колір.
  static const Color accent = Color(0xFF006FCD);

  /// Світлий акцент.
  static const Color accentLight = Color(0xFF4D9AE8);

  /// Темний акцент.
  static const Color accentDark = Color(0xFF004A8A);

  // ─── Станні кольори ───────────────────────────────────────────────

  /// Колір успішної дії.
  static const Color success = Color(0xFF00C853);

  /// Світлий колір успіху (для фону).
  static const Color successLight = Color(0xFF00E676);

  /// Темний колір успіху.
  static const Color successDark = Color(0xFF009624);

  /// Колір попередження.
  static const Color warning = Color(0xFFFFB300);

  /// Світлий колір попередження (для фону).
  static const Color warningLight = Color(0xFFFFD54F);

  /// Темний колір попередження.
  static const Color warningDark = Color(0xFFFF8F00);

  /// Колір помилки.
  static const Color error = Color(0xFFFF1744);

  /// Світлий колір помилки (для фону).
  static const Color errorLight = Color(0xFFFF5252);

  /// Темний колір помилки.
  static const Color errorDark = Color(0xFFD50000);

  // ─── Гейміфікація ─────────────────────────────────────────────────

  /// Колір XP (досвід).
  static const Color xp = Color(0xFFFFD600);

  /// Світлий колір XP для фону.
  static const Color xpLight = Color(0xFFFFEA00);

  /// Темний колір XP.
  static const Color xpDark = Color(0xFFFFC400);

  /// Колір монет.
  static const Color coin = Color(0xFFFF9100);

  /// Світлий колір монет.
  static const Color coinLight = Color(0xFFFFAB40);

  /// Темний колір монет.
  static const Color coinDark = Color(0xFFFF6D00);

  /// Колір серії (streak fire).
  static const Color streak = Color(0xFFFF6D00);

  /// Колір заморожування.
  static const Color frozen = Color(0xFF80DEEA);

  /// Темний колір заморожування.
  static const Color frozenDark = Color(0xFF4DD0E1);

  // ─── Градієнти ────────────────────────────────────────────────────

  /// Початковий колір основного градієнта.
  static const Color gradientStart = Color(0xFF006FCD);

  /// Кінцевий колір основного градієнта.
  static const Color gradientEnd = Color(0xFF00C6FF);

  /// Початковий колір градієнта XP.
  static const Color xpGradientStart = Color(0xFFFFD600);

  /// Кінцевий колір градієнта XP.
  static const Color xpGradientEnd = Color(0xFFFF9100);

  /// Початковий колір градієнта успіху.
  static const Color successGradientStart = Color(0xFF00C853);

  /// Кінцевий колір градієнта успіху.
  static const Color successGradientEnd = Color(0xFF00E676);

  /// Початковий колір градієнта помилки.
  static const Color errorGradientStart = Color(0xFFFF1744);

  /// Кінцевий колір градієнта помилки.
  static const Color errorGradientEnd = Color(0xFFFF5252);

  // ─── Ефекти ───────────────────────────────────────────────────────

  /// Базовий колір shimmer-ефекту.
  static const Color shimmerBase = Color(0xFF1C1C2E);

  /// Колір підсвітки shimmer-ефекту.
  static const Color shimmerHighlight = Color(0xFF2A2A44);

  /// Колір сяйва (glow).
  static const Color glow = Color(0x33006FCD);

  /// Світле сяйво XP.
  static const Color xpGlow = Color(0x33FFD600);

  /// Світле сяйво монет.
  static const Color coinGlow = Color(0x33FF9100);

  /// Світле сяйво помилки.
  static const Color errorGlow = Color(0x33FF1744);

  // ─── Стани інтерактивних елементів ────────────────────────────────

  /// Колір елемента у вимкненому стані (50% непрозорості).
  static Color get disabled => textHint;

  /// Колір елемента при наведенні (легке засвітлення).
  static const Color hovered = Color(0xFF22223A);

  /// Колір елемента при натисканні (легке затемнення).
  static const Color pressed = Color(0xFF10101A);

  /// Колір фокусу (кільце фокуса для доступності).
  static const Color focusRing = Color(0x40006FCD);

  // ─── Нижня навігація ──────────────────────────────────────────────

  /// Колір неактивного пункту навігації.
  static const Color navInactive = Color(0xFF555570);

  /// Колір активного пункту навігації.
  static const Color navActive = Color(0xFF006FCD);

  /// Колір фону нижньої навігації.
  static const Color navBackground = Color(0xFF12121E);

  // ─── Оверлеї ──────────────────────────────────────────────────────

  /// Напівпрозорий темний оверлей.
  static const Color overlayDark = Color(0xB0000000);

  /// Легкий напівпрозорий оверлей.
  static const Color overlayLight = Color(0x40000000);

  /// Оверлей для розмитого фону.
  static const Color backdropBlur = Color(0x800A0A0F);

  // ─── Неонова палітра ──────────────────────────────────────────────

  /// Неоновий синій.
  static const Color neonBlue = Color(0xFF00D4FF);

  /// Неоновий фіолетовий.
  static const Color neonPurple = Color(0xFFBF00FF);

  /// Неоновий зелений.
  static const Color neonGreen = Color(0xFF39FF14);

  /// Неоновий рожевий.
  static const Color neonPink = Color(0xFFFF006E);

  /// Неоновий жовтий.
  static const Color neonYellow = Color(0xFFFFF300);

  /// Неоновий помаранчевий.
  static const Color neonOrange = Color(0xFFFF6600);

  // ─── Морозна палітра ──────────────────────────────────────────────

  /// Льодяний блакитний.
  static const Color frostBlue = Color(0xFFE0F7FA);

  /// Морозний білий.
  static const Color frostWhite = Color(0xFFF0F8FF);

  /// Зимовий сірий.
  static const Color frostGrey = Color(0xFFB0BEC5);

  /// Лідяний зелений.
  static const Color frostMint = Color(0xFFB2DFDB);

  /// Сніжний блакитний.
  static const Color frostSky = Color(0xFFB3E5FC);

  // ─── Сезонна палітра (розширена) ────────────────────────────────

  /// Весняний зелений.
  static const Color seasonSpring = Color(0xFF66BB6A);

  /// Весняний бузковий.
  static const Color seasonSpringBlossom = Color(0xFFF8BBD0);

  /// Весняний світло-зелений.
  static const Color seasonSpringLeaf = Color(0xFFAED581);

  /// Літній жовтий.
  static const Color seasonSummer = Color(0xFFFFCA28);

  /// Літній сонячний.
  static const Color seasonSummerSun = Color(0xFFFFD54F);

  /// Літній небесний.
  static const Color seasonSummerSky = Color(0xFF42A5F5);

  /// Осінній помаранчевий.
  static const Color seasonAutumn = Color(0xFFFF7043);

  /// Осінній бурштиновий.
  static const Color seasonAutumnLeaf = Color(0xFFBF360C);

  /// Осінній золотий.
  static const Color seasonAutumnGold = Color(0xFFFFA000);

  /// Зимовий блакитний.
  static const Color seasonWinter = Color(0xFF42A5F5);

  /// Зимовий льодяний.
  static const Color seasonWinterIce = Color(0xFF80DEEA);

  /// Зимовий сніжний.
  static const Color seasonWinterSnow = Color(0xFFF5F5FA);

  // ─── Палітра настрою ───────────────────────────────────────────

  /// Спокійний настрій — м′який блакитний.
  static const Color moodCalm = Color(0xFF90CAF9);

  /// Енергійний настрій — яскравий жовтий.
  static const Color moodEnergetic = Color(0xFFFFD600);

  /// Зосереджений настрій — фіолетовий.
  static const Color moodFocused = Color(0xFFB388FF);

  /// Щасливий настрій — теплий помаранчевий.
  static const Color moodHappy = Color(0xFFFFAB40);

  /// Мотивований настрій — зелений.
  static const Color moodMotivated = Color(0xFF69F0AE);

  /// Розслаблений настрій — м′який зелений.
  static const Color moodRelaxed = Color(0xFFA5D6A7);

  /// Амбітний настрій — яскравий червоний.
  static const Color moodAmbitious = Color(0xFFFF5252);

  /// Спокійний нічний настрій — глибокий синій.
  static const Color moodNight = Color(0xFF1A237E);

  // ─── Семантичні кольори компонентів (8 станів) ────────────────────

  /// Кнопка у стандартному стані.
  static const Color buttonDefault = Color(0xFF006FCD);

  /// Кнопка при наведенні.
  static const Color buttonHovered = Color(0xFF005ABB);

  /// Кнопка при натисканні.
  static const Color buttonPressed = Color(0xFF004A8A);

  /// Кнопка вимкнена.
  static const Color buttonDisabled = Color(0xFF555570);

  /// Інпут у фокусі.
  static const Color inputFocused = Color(0xFF006FCD);

  /// Інпут з помилкою.
  static const Color inputError = Color(0xFFFF1744);

  /// Інпут успішний.
  static const Color inputSuccess = Color(0xFF00C853);

  /// Інпут вимкнений.
  static const Color inputDisabled = Color(0xFF333350);

  // ─── Кольори контрасту для доступності ────────────────────────────

  /// Високий контраст — текст на темному фоні.
  static const Color contrastHighOnDark = Color(0xFFFFFFFF);

  /// Високий контраст — текст на світлому фоні.
  static const Color contrastHighOnLight = Color(0xFF000000);

  /// Середній контраст — додатковий текст.
  static const Color contrastMedium = Color(0xFFCCCCCC);

  /// Низький контраст — підказки та декоративні елементи.
  static const Color contrastLow = Color(0xFF8888A0);

  /// Колір позначення фокусу для accessibility.
  static const Color accessibilityFocus = Color(0x4D006FCD);

  /// Колір фокусу при помилці.
  static const Color accessibilityError = Color(0x4DFF1744);

  /// Колір фокусу успіху.
  static const Color accessibilitySuccess = Color(0x4D00C853);

  // ─── Тепла палітера ──────────────────────────────────────────────

  /// Теплий червоний — для "гарячих" цілей.
  static const Color warmRed = Color(0xFFE53935);

  /// Теплий помаранчевий — для енергійних елементів.
  static const Color warmOrange = Color(0xFFFF7043);

  /// Теплий жовтий — для сонячних акцентів.
  static const Color warmYellow = Color(0xFFFDD835);

  /// Теплий бежевий — для фонових акцентів.
  static const Color warmBeige = Color(0xFFD7CCC8);

  /// Теплий коричневий — для земельних акцентів.
  static const Color warmBrown = Color(0xFF8D6E63);

  // ─── Холодна палітера ────────────────────────────────────────────

  /// Холодний блакитний — для спокійних елементів.
  static const Color coolBlue = Color(0xFF1E88E5);

  /// Холодний індиго — для глибоких акцентів.
  static const Color coolIndigo = Color(0xFF3949AB);

  /// Холодний фіолетовий — для містичних елементів.
  static const Color coolPurple = Color(0xFF7B1FA2);

  /// Холодний сірий — для нейтральних фонів.
  static const Color coolGrey = Color(0xFF78909C);

  /// Холодний чорний — для глибокого темного фону.
  static const Color coolBlack = Color(0xFF0D0D12);

  // ─── Glassmorphism кольори ───────────────────────────────────────

  /// Скляний фон — напівпрозорий темний.
  static const Color glassBackground = Color(0x1A1C1C2E);

  /// Скляна рамка — тонка біла.
  static const Color glassBorder = Color(0x33FFFFFF);

  /// Скляна підсвітка — легке біле сяйво.
  static const Color glassHighlight = Color(0x1AFFFFFF);

  // ─── Градієнтні пресети ───────────────────────────────────────────

  /// Основний градієнт додатку (синій).
  static LinearGradient get primaryGradient => const LinearGradient(
        colors: [gradientStart, gradientEnd],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  /// Градієнт XP (золотий).
  static LinearGradient get xpGradient => const LinearGradient(
        colors: [xpGradientStart, xpGradientEnd],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  /// Градієнт успіху (зелений).
  static LinearGradient get successGradient => const LinearGradient(
        colors: [successGradientStart, successGradientEnd],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  /// Градієнт помилки (червоний).
  static LinearGradient get errorGradient => const LinearGradient(
        colors: [errorGradientStart, errorGradientEnd],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  /// Градієнт заморожування (блакитний).
  static LinearGradient get frozenGradient => const LinearGradient(
        colors: [frozenDark, frozen],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  /// Неоновий градієнт.
  static LinearGradient get neonGradient => const LinearGradient(
        colors: [neonBlue, neonPurple],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  /// Градієнт монет.
  static LinearGradient get coinGradient => const LinearGradient(
        colors: [Color(0xFFFFAB40), Color(0xFFFF6D00)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  /// Градієнт «Весняне пробудження».
  static LinearGradient get springGradient => const LinearGradient(
        colors: [seasonSpringBlossom, seasonSpring, seasonSpringLeaf],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  /// Градієнт «Літнє сонце».
  static LinearGradient get summerGradient => const LinearGradient(
        colors: [seasonSummerSun, seasonSummer, seasonSummerSky],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  /// Градієнт «Осіннє золото».
  static LinearGradient get autumnGradient => const LinearGradient(
        colors: [seasonAutumnGold, seasonAutumn, seasonAutumnLeaf],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  /// Градієнт «Зимова казка».
  static LinearGradient get winterGradient => const LinearGradient(
        colors: [seasonWinterSnow, seasonWinterIce, seasonWinter],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  /// Радіальний градієнт сяйва.
  static RadialGradient get glowRadial => const RadialGradient(
        colors: [Color(0x4D006FCD), Color(0x00000000)],
        radius: 0.6,
      );

  /// Радіальний градієнт XP.
  static RadialGradient get xpGlowRadial => const RadialGradient(
        colors: [Color(0x4DFFD600), Color(0x00000000)],
        radius: 0.6,
      );

  /// Радіальний градієнт успіху.
  static RadialGradient get successGlowRadial => const RadialGradient(
        colors: [Color(0x4D00C853), Color(0x00000000)],
        radius: 0.6,
      );

  /// Радіальний градієнт помилки.
  static RadialGradient get errorGlowRadial => const RadialGradient(
        colors: [Color(0x4DFF1744), Color(0x00000000)],
        radius: 0.6,
      );

  /// Градієнт скляного ефекту.
  static LinearGradient get glassGradient => const LinearGradient(
        colors: [Color(0x1AFFFFFF), Color(0x0DFFFFFF)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  /// Градієнт вогняної серії.
  static LinearGradient get fireGradient => const LinearGradient(
        colors: [Color(0xFFFF6D00), Color(0xFFFF1744), Color(0xFFFFD600)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  /// Градієнт заморожування (льодяний).
  static LinearGradient get iceGradient => const LinearGradient(
        colors: [Color(0xFF80DEEA), Color(0xFF4DD0E1), Color(0xFF00BCD4)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  /// Градієнт золотої премії.
  static LinearGradient get premiumGoldGradient => const LinearGradient(
        colors: [Color(0xFFFFD600), Color(0xFFFFAB00), Color(0xFFFF8F00)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  /// Градієнт "Північне сяйво".
  static LinearGradient get auroraGradient => const LinearGradient(
        colors: [Color(0xFF00D4FF), Color(0xFF39FF14), Color(0xFFBF00FF)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  /// Градієнт заходу сонця.
  static LinearGradient get sunsetGradient => const LinearGradient(
        colors: [Color(0xFFFF6B6B), Color(0xFFFFA07A), Color(0xFFFFD93D)],
        begin: Alignment.bottomLeft,
        end: Alignment.topRight,
      );

  /// Градієнт глибокого космосу.
  static LinearGradient get deepSpaceGradient => const LinearGradient(
        colors: [Color(0xFF0A0A1A), Color(0xFF1A1A3E), Color(0xFF0D0D2B)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      );

  // ─── Допоміжні методи ─────────────────────────────────────────────

  /// Повертає колір з вказаною непрозорістю.
  static Color withAlpha(Color color, double alpha) {
    return color.withValues(alpha: alpha.clamp(0.0, 1.0));
  }

  /// Повертає колір для вказаного рівня ризику серії.
  static Color riskColor(double level) {
    final clamped = level.clamp(0.0, 1.0);
    if (clamped < 0.33) return success;
    if (clamped < 0.66) return warning;
    return error;
  }

  /// Повертає колір прогресу на основі відсотка (0.0–1.0).
  static Color progressColor(double progress) {
    final p = progress.clamp(0.0, 1.0);
    if (p < 0.25) return error;
    if (p < 0.5) return warning;
    if (p < 0.75) return coin;
    return success;
  }

  /// Змішує два кольори у вказаній пропорції.
  static Color blend(Color color1, Color color2, double ratio) {
    return Color.lerp(color1, color2, ratio.clamp(0.0, 1.0)) ?? color1;
  }

  /// Змішує три кольори за вагою.
  ///
  /// [weight2] та [weight3] — вага другого та третього кольорів (0.0–1.0).
  static Color blendThree(
    Color c1,
    Color c2,
    Color c3, {
    double weight2 = 0.3,
    double weight3 = 0.3,
  }) {
    final w1 = 1.0 - weight2 - weight3;
    final first = Color.lerp(c1, c2, weight2 / (w1 + weight2)) ?? c1;
    return Color.lerp(first, c3, weight3 / (w1 + weight2 + weight3)) ?? first;
  }

  /// Змішує колір із білим за вказаною непрозорістю.
  static Color blendWithWhite(Color color, double whiteAmount) {
    return Color.lerp(color, const Color(0xFFFFFFFF), whiteAmount.clamp(0.0, 1.0)) ?? color;
  }

  /// Змішує колір із чорним за вказаною непрозорістю.
  static Color blendWithBlack(Color color, double blackAmount) {
    return Color.lerp(color, const Color(0xFF000000), blackAmount.clamp(0.0, 1.0)) ?? color;
  }

  /// Повертає колір ступи серії за кількістю днів.
  static Color streakColor(int days) {
    if (days == 0) return textHint;
    if (days < 3) return const Color(0xFF81C784);
    if (days < 7) return const Color(0xFF4CAF50);
    if (days < 14) return const Color(0xFF8BC34A);
    if (days < 30) return const Color(0xFFFFC107);
    if (days < 60) return const Color(0xFFFF9800);
    if (days < 90) return const Color(0xFFFF5722);
    return const Color(0xFFFF1744);
  }

  /// Повертає колір на основі настрою.
  static Color moodColor(String mood) {
    switch (mood) {
      case 'спокійний':
        return moodCalm;
      case 'енергійний':
        return moodEnergetic;
      case 'зосереджений':
        return moodFocused;
      case 'щасливий':
        return moodHappy;
      case 'мотивований':
        return moodMotivated;
      case 'розслаблений':
        return moodRelaxed;
      case 'амбітний':
        return moodAmbitious;
      case 'нічний':
        return moodNight;
      default:
        return accent;
    }
  }

  /// Повертає сезонну палітру.
  static LinearGradient seasonGradient(String season) {
    switch (season) {
      case 'весна':
        return springGradient;
      case 'літо':
        return summerGradient;
      case 'осінь':
        return autumnGradient;
      case 'зима':
        return winterGradient;
      default:
        return primaryGradient;
    }
  }

  /// Повертає колір рівня (level) за номером рівня.
  ///
  /// Кожні 5 рівнів колір змінюється від блакитного до червоного.
  static Color levelColor(int level) {
    final clamped = level.clamp(1, 50);
    final hue = ((clamped - 1) % 10) * 36.0;
    return HSLColor.fromAHSL(1.0, hue, 0.8, 0.6).toColor();
  }

  /// Затемнює колір на вказану величину (0.0–1.0).
  ///
  /// [amount] — ступінь затемнення (0.0 = без змін, 1.0 = повністю чорний).
  static Color darken(Color color, double amount) {
    return Color.lerp(color, const Color(0xFF000000), amount.clamp(0.0, 1.0)) ?? color;
  }

  /// Освітлює колір на вказану величину (0.0–1.0).
  ///
  /// [amount] — ступінь освітлення (0.0 = без змін, 1.0 = повністю білий).
  static Color lighten(Color color, double amount) {
    return Color.lerp(color, const Color(0xFFFFFFFF), amount.clamp(0.0, 1.0)) ?? color;
  }

  /// Інвертує колір (доповняє до білого).
  static Color invert(Color color) {
    return Color.fromARGB(
      color.alpha,
      255 - color.red,
      255 - color.green,
      255 - color.blue,
    );
  }

  /// Перевіряє, чи є колір достатньо контрастним для тексту на темному фоні.
  ///
  /// Повертає `true`, якщо контрастність >= 4.5:1 (WCAG AA).
  static bool isAccessibleOnDark(Color color) {
    return _contrastRatio(color, background) >= 4.5;
  }

  /// Перевіряє, чи є колір достатньо контрастним для тексту на світлому фоні.
  ///
  /// Повертає `true`, якщо контрастність >= 4.5:1 (WCAG AA).
  static bool isAccessibleOnLight(Color color) {
    return _contrastRatio(color, const Color(0xFFF5F5FA)) >= 4.5;
  }

  /// Обчислює відносну яскравість кольору (WCAG).
  static double _luminance(Color color) {
    final r = color.red / 255.0;
    final g = color.green / 255.0;
    final b = color.blue / 255.0;
    final fn = (double v) => v <= 0.03928 ? v / 12.92 : pow((v + 0.055) / 1.055, 2.4).toDouble();
    return 0.2126 * fn(r) + 0.7152 * fn(g) + 0.0722 * fn(b);
  }

  /// Обчислює контрастність між двома кольорами.
  static double _contrastRatio(Color c1, Color c2) {
    final l1 = _luminance(c1);
    final l2 = _luminance(c2);
    final lighter = l1 > l2 ? l1 : l2;
    final darker = l1 > l2 ? l2 : l1;
    return (lighter + 0.05) / (darker + 0.05);
  }

  /// Повертає контрастність між двома кольорами.
  static double contrastRatio(Color c1, Color c2) {
    return _contrastRatio(c1, c2);
  }

  /// Повертає кращий колір тексту (чорний або білий) для фону [bg].
  static Color contrastTextColor(Color bg) {
    return _luminance(bg) > 0.179 ? const Color(0xFF000000) : const Color(0xFFFFFFFF);
  }

  /// Конвертує колір у HEX рядок (напр. "#FF006FCD").
  static String toHex(Color color) {
    return '#${color.alpha.toRadixString(16).padLeft(2, '0')}'
        '${color.red.toRadixString(16).padLeft(2, '0')}'
        '${color.green.toRadixString(16).padLeft(2, '0')}'
        '${color.blue.toRadixString(16).padLeft(2, '0')}';
  }

  /// Парсить HEX рядок у [Color].
  ///
  /// Підтримує формати: "#RGB", "#RRGGBB", "#ARGB", "#AARRGGBB".
  /// Кидає [FormatException] при невалідному форматі.
  static Color fromHex(String hex) {
    final cleaned = hex.replaceAll('#', '');
    if (cleaned.length == 6) {
      return Color(int.parse('FF$cleaned', radix: 16));
    } else if (cleaned.length == 8) {
      return Color(int.parse(cleaned, radix: 16));
    } else if (cleaned.length == 3) {
      return Color(int.parse(
        'FF${cleaned[0]}${cleaned[0]}${cleaned[1]}${cleaned[1]}${cleaned[2]}${cleaned[2]}',
        radix: 16,
      ));
    }
    throw FormatException('Невалідний HEX колір: $hex');
  }

  /// Серіалізує колір у JSON-сумісний рядок.
  static String colorToJson(Color color) => toHex(color);

  /// Десеріалізує колір із JSON-рядка.
  static Color colorFromJson(String json) => fromHex(json);

  /// Створює [ColorScheme] на основі PS5 темної палітри.
  ///
  /// Зручний фабричний метод для ThemeData.
  static ColorScheme colorScheme() {
    return const ColorScheme.dark(
      primary: accent,
      onPrimary: Colors.white,
      primaryContainer: accentDark,
      onPrimaryContainer: Color(0xFFD0E4FF),
      secondary: Color(0xFF4D9AE8),
      onSecondary: Colors.white,
      secondaryContainer: Color(0xFF003F75),
      onSecondaryContainer: Color(0xFFD0E4FF),
      tertiary: Color(0xFF8B5CF6),
      onTertiary: Colors.white,
      tertiaryContainer: Color(0xFF4A1F8E),
      onTertiaryContainer: Color(0xFFEDDCFF),
      error: error,
      onError: Colors.white,
      errorContainer: Color(0xFF93000A),
      onErrorContainer: Color(0xFFFFDAD6),
      surface: surface,
      onSurface: textPrimary,
      onSurfaceVariant: textSecondary,
      outline: border,
      outlineVariant: Color(0xFF3A3A52),
      shadow: Color(0xFF000000),
      scrim: Color(0xFF000000),
      inverseSurface: Color(0xFFE0E0F0),
      onInverseSurface: Color(0xFF1A1A2E),
      inversePrimary: Color(0xFF005ABB),
    );
  }

  /// Створює [ColorScheme] з кастомним акцентним кольором.
  ///
  /// Зберігає PS5 палітру, але замінює акцентні кольори.
  static ColorScheme colorSchemeWithAccent(Color primaryAccent) {
    return ColorScheme.dark(
      primary: primaryAccent,
      onPrimary: Colors.white,
      primaryContainer: darken(primaryAccent, 0.3),
      onPrimaryContainer: lighten(primaryAccent, 0.8),
      secondary: accentLight,
      onSecondary: Colors.white,
      surface: surface,
      onSurface: textPrimary,
      error: error,
      onError: Colors.white,
      outline: border,
    );
  }

  /// Повертає мапу всіх іменованих кольорів для дебагу.
  ///
  /// Ключ — назва кольору, значення — HEX представлення.
  static Map<String, String> debugColorMap() {
    return {
      'background': toHex(background),
      'surface': toHex(surface),
      'card': toHex(card),
      'cardElevated': toHex(cardElevated),
      'border': toHex(border),
      'textPrimary': toHex(textPrimary),
      'textSecondary': toHex(textSecondary),
      'accent': toHex(accent),
      'accentLight': toHex(accentLight),
      'accentDark': toHex(accentDark),
      'success': toHex(success),
      'warning': toHex(warning),
      'error': toHex(error),
      'xp': toHex(xp),
      'coin': toHex(coin),
      'streak': toHex(streak),
      'frozen': toHex(frozen),
      'neonBlue': toHex(neonBlue),
      'neonPurple': toHex(neonPurple),
      'neonGreen': toHex(neonGreen),
    };
  }

  /// Валідація кольору — перевіряє, чи не є колір прозорим.
  ///
  /// [minAlpha] — мінімальна допустима непрозорість (0.0–1.0).
  static bool isValidColor(Color color, {double minAlpha = 0.05}) {
    return color.a >= minAlpha;
  }

  /// Генерує випадковий колір із неонової палітри.
  ///
  /// Корисно для тестування та конфетті.
  static Color randomNeon([Random? random]) {
    final rng = random ?? Random();
    final neons = [neonBlue, neonPurple, neonGreen, neonPink, neonYellow, neonOrange];
    return neons[rng.nextInt(neons.length)];
  }

  /// Генерує випадковий сезонний колір.
  static Color randomSeason([Random? random]) {
    final rng = random ?? Random();
    final seasons = [
      seasonSpring, seasonSummer, seasonAutumn, seasonWinter,
      seasonSpringBlossom, seasonSummerSky, seasonAutumnGold, seasonWinterIce,
    ];
    return seasons[rng.nextInt(seasons.length)];
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Розширення (Extensions)
// ═══════════════════════════════════════════════════════════════════════════

/// Розширення [Color] для швидкого доступу до часткових операцій.
extension AppColorExtension on Color {
  /// Затемнює колір на [amount] (0.0–1.0).
  Color darken(double amount) => AppColorsPS5.darken(this, amount);

  /// Освітлює колір на [amount] (0.0–1.0).
  Color lighten(double amount) => AppColorsPS5.lighten(this, amount);

  /// Змішує з іншим кольором у пропорції [ratio].
  Color blend(Color other, double ratio) => AppColorsPS5.blend(this, other, ratio);

  /// Повертає HEX рядок кольору.
  String toHex() => AppColorsPS5.toHex(this);

  /// Інвертує колір.
  Color invert() => AppColorsPS5.invert(this);

  /// Встановлює непрозорість кольору.
  Color withOpacity(double opacity) => withValues(alpha: opacity.clamp(0.0, 1.0));

  /// Повертає кращий колір тексту для цього фону.
  Color get contrastText => AppColorsPS5.contrastTextColor(this);
}

/// Розширення [LinearGradient] для серіалізації.
extension LinearGradientExtension on LinearGradient {
  /// Серіалізує градієнт у JSON.
  Map<String, dynamic> toJson() => {
        'begin': '${begin.x},${begin.y}',
        'end': '${end.x},${end.y}',
        'colors': colors.map((c) => AppColorsPS5.toHex(c)).toList(),
      };
}

// ═══════════════════════════════════════════════════════════════════════════
// Data-клас для набору кольорів (Swatch)
// ═══════════════════════════════════════════════════════════════════════════

/// Повний набір кольорів для серіалізації / відновлення теми.
///
/// Містить всі основні кольори PS5-теми у зручному форматі
/// для збереження у SharedPreferences або базу даних.
class AppColorsPS5Swatch {
  /// Створює набір кольорів з поточних значень [AppColorsPS5].
  AppColorsPS5Swatch();

  /// Колір фону.
  String get backgroundHex => AppColorsPS5.toHex(AppColorsPS5.background);

  /// Колір поверхні.
  String get surfaceHex => AppColorsPS5.toHex(AppColorsPS5.surface);

  /// Колір картки.
  String get cardHex => AppColorsPS5.toHex(AppColorsPS5.card);

  /// Акцентний колір.
  String get accentHex => AppColorsPS5.toHex(AppColorsPS5.accent);

  /// Колір тексту.
  String get textPrimaryHex => AppColorsPS5.toHex(AppColorsPS5.textPrimary);

  /// Серіалізує набір у JSON.
  Map<String, dynamic> toJson() => {
        'background': backgroundHex,
        'surface': surfaceHex,
        'card': cardHex,
        'accent': accentHex,
        'textPrimary': textPrimaryHex,
      };

  /// Десеріалізує набір із JSON.
  factory AppColorsPS5Swatch.fromJson(Map<String, dynamic> json) {
    return AppColorsPS5Swatch();
  }

  /// Десеріалізує набір із JSON рядка.
  factory AppColorsPS5Swatch.fromJsonString(String jsonString) {
    return AppColorsPS5Swatch.fromJson(jsonDecode(jsonString));
  }

  /// Повертає JSON рядок.
  String toJsonString() => jsonEncode(toJson());

  /// Повертає опис наборf для дебагу.
  @override
  String toString() => 'AppColorsPS5Swatch(accent: $accentHex, bg: $backgroundHex)';
}

/// Monitor light theme colors.
///
/// Містить повний набір кольорів для світлої теми Nexora Monitor,
/// включаючи базові кольори, градієнти, стани інтерактивних елементів
/// та спеціалізовані палітри для гейміфікації.
///
/// Цей клас є дзеркальним відображенням [AppColorsPS5], але адаптованим
/// для світлої теми з м'якими морозними відтінками.
class AppColorsMonitor {
  AppColorsMonitor._();

  // ─── Базові кольори ───────────────────────────────────────────────

  /// Основний колір фону додатку (світлий).
  static const Color background = Color(0xFFF5F5FA);

  /// Колір поверхні (картки, модальні вікна).
  static const Color surface = Color(0xFFFFFFFF);

  /// Колір стандартної картки.
  static const Color card = Color(0xFFFFFFFF);

  /// Колір піднятої картки (з тінню).
  static const Color cardElevated = Color(0xFFF8F8FC);

  /// Колір рамок та роздільників.
  static const Color border = Color(0xFFE0E0EA);

  // ─── Текст ─────────────────────────────────────────────────────────

  /// Основний колір тексту (темний на світлому фоні).
  static const Color textPrimary = Color(0xFF1A1A2E);

  /// Другорядний колір тексту (підписи, описи).
  static const Color textSecondary = Color(0xFF6B6B80);

  /// Колір тексту-підказки (placeholder).
  static const Color textHint = Color(0xFF9E9EB0);

  /// Колір тексту з акцентом.
  static const Color textAccent = Color(0xFF006FCD);

  /// Колір тексту успіху.
  static const Color textSuccess = Color(0xFF00893B);

  /// Колір тексту помилки.
  static const Color textError = Color(0xFFD50000);

  /// Колір тексту попередження.
  static const Color textWarning = Color(0xFFE65100);

  // ─── Акцентні кольори ─────────────────────────────────────────────

  /// Основний акцентний колір.
  static const Color accent = Color(0xFF006FCD);

  /// Світлий акцент.
  static const Color accentLight = Color(0xFF4D9AE8);

  /// Темний акцент.
  static const Color accentDark = Color(0xFF004A8A);

  // ─── Станні кольори ───────────────────────────────────────────────

  /// Колір успішної дії.
  static const Color success = Color(0xFF00C853);

  /// Світлий колір успіху (для фону).
  static const Color successLight = Color(0xFFE8F5E9);

  /// Темний колір успіху.
  static const Color successDark = Color(0xFF009624);

  /// Колір попередження.
  static const Color warning = Color(0xFFFFB300);

  /// Світлий колір попередження (для фону).
  static const Color warningLight = Color(0xFFFFF8E1);

  /// Темний колір попередження.
  static const Color warningDark = Color(0xFFFF8F00);

  /// Колір помилки.
  static const Color error = Color(0xFFFF1744);

  /// Світлий колір помилки (для фону).
  static const Color errorLight = Color(0xFFFFEBEE);

  /// Темний колір помилки.
  static const Color errorDark = Color(0xFFD50000);

  // ─── Гейміфікація ─────────────────────────────────────────────────

  /// Колір XP (досвід).
  static const Color xp = Color(0xFFFFD600);

  /// Світлий колір XP для фону.
  static const Color xpLight = Color(0xFFFFF8E1);

  /// Темний колір XP.
  static const Color xpDark = Color(0xFFFFC400);

  /// Колір монет.
  static const Color coin = Color(0xFFFF9100);

  /// Світлий колір монет.
  static const Color coinLight = Color(0xFFFFF3E0);

  /// Темний колір монет.
  static const Color coinDark = Color(0xFFFF6D00);

  /// Колір серії (streak fire).
  static const Color streak = Color(0xFFFF6D00);

  /// Колір заморожування.
  static const Color frozen = Color(0xFF00BCD4);

  /// Темний колір заморожування.
  static const Color frozenDark = Color(0xFF0097A7);

  // ─── Градієнти ────────────────────────────────────────────────────

  /// Початковий колір основного градієнта.
  static const Color gradientStart = Color(0xFF006FCD);

  /// Кінцевий колір основного градієнта.
  static const Color gradientEnd = Color(0xFF00C6FF);

  /// Початковий колір градієнта XP.
  static const Color xpGradientStart = Color(0xFFFFD600);

  /// Кінцевий колір градієнта XP.
  static const Color xpGradientEnd = Color(0xFFFF9100);

  /// Початковий колір градієнта успіху.
  static const Color successGradientStart = Color(0xFF00C853);

  /// Кінцевий колір градієнта успіху.
  static const Color successGradientEnd = Color(0xFF69F0AE);

  /// Початковий колір градієнта помилки.
  static const Color errorGradientStart = Color(0xFFFF1744);

  /// Кінцевий колір градієнта помилки.
  static const Color errorGradientEnd = Color(0xFFFF8A80);

  // ─── Ефекти ───────────────────────────────────────────────────────

  /// Базовий колір shimmer-ефекту.
  static const Color shimmerBase = Color(0xFFE8E8F0);

  /// Колір підсвітки shimmer-ефекту.
  static const Color shimmerHighlight = Color(0xFFF5F5FA);

  /// Колір сяйва (glow).
  static const Color glow = Color(0x33006FCD);

  /// Світле сяйво XP.
  static const Color xpGlow = Color(0x1AFFD600);

  /// Світле сяйво монет.
  static const Color coinGlow = Color(0x1AFF9100);

  /// Світле сяйво помилки.
  static const Color errorGlow = Color(0x1AFF1744);

  // ─── Стани інтерактивних елементів ────────────────────────────────

  /// Колір елемента у вимкненому стані.
  static Color get disabled => textHint;

  /// Колір елемента при наведенні.
  static const Color hovered = Color(0xFFECECF4);

  /// Колір елемента при натисканні.
  static const Color pressed = Color(0xFFE0E0EA);

  /// Колір фокусу (кільце фокуса для доступності).
  static const Color focusRing = Color(0x40006FCD);

  // ─── Нижня навігація ──────────────────────────────────────────────

  /// Колір неактивного пункту навігації.
  static const Color navInactive = Color(0xFF9E9EB0);

  /// Колір активного пункту навігації.
  static const Color navActive = Color(0xFF006FCD);

  /// Колір фону нижньої навігації.
  static const Color navBackground = Color(0xFFFFFFFF);

  // ─── Оверлеї ──────────────────────────────────────────────────────

  /// Напівпрозорий темний оверлей.
  static const Color overlayDark = Color(0x80000000);

  /// Легкий напівпрозорий оверлей.
  static const Color overlayLight = Color(0x40000000);

  /// Оверлей для розмитого фону.
  static const Color backdropBlur = Color(0x80F5F5FA);

  // ─── Морозна палітра (розширена) ──────────────────────────────────

  /// Льодяний блакитний.
  static const Color frostBlue = Color(0xFFE3F2FD);

  /// Морозний білий.
  static const Color frostWhite = Color(0xFFFFFFFF);

  /// Зимовий сірий.
  static const Color frostGrey = Color(0xFFCFD8DC);

  /// Лідяний зелений.
  static const Color frostMint = Color(0xFFE0F2F1);

  /// Сніжний блакитний.
  static const Color frostSky = Color(0xFFE1F5FE);

  /// Лідяний лавандовий.
  static const Color frostLavender = Color(0xFFF3E5F5);

  /// Морозний персиковий.
  static const Color frostPeach = Color(0xFFFBE9E7);

  /// Сніжний м'ятний.
  static const Color frostSnowMint = Color(0xFFE8F5E9);

  // ─── Glassmorphism кольори для світлої теми ──────────────────────

  /// Скляний фон — напівпрозорий білий.
  static const Color glassBackground = Color(0x66FFFFFF);

  /// Скляна рамка — тонка сіра.
  static const Color glassBorder = Color(0x33E0E0EA);

  /// Скляна підсвітка — легке біле сяйво зверху.
  static const Color glassHighlight = Color(0x4DFFFFFF);

  // ─── Сезонна палітра ──────────────────────────────────────────────

  /// Весняний зелений.
  static const Color seasonSpring = Color(0xFF4CAF50);

  /// Літній жовтий.
  static const Color seasonSummer = Color(0xFFFFCA28);

  /// Осінній помаранжевий.
  static const Color seasonAutumn = Color(0xFFFF7043);

  /// Зимовий блакитний.
  static const Color seasonWinter = Color(0xFF42A5F5);

  // ─── Градієнтні пресети ───────────────────────────────────────────

  /// Основний градієнт додатку.
  static LinearGradient get primaryGradient => const LinearGradient(
        colors: [gradientStart, gradientEnd],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  /// Градієнт XP.
  static LinearGradient get xpGradient => const LinearGradient(
        colors: [xpGradientStart, xpGradientEnd],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  /// Градієнт успіху.
  static LinearGradient get successGradient => const LinearGradient(
        colors: [successGradientStart, successGradientEnd],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  /// Градієнт помилки.
  static LinearGradient get errorGradient => const LinearGradient(
        colors: [errorGradientStart, errorGradientEnd],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  /// Градієнт заморожування.
  static LinearGradient get frozenGradient => const LinearGradient(
        colors: [frozenDark, frozen],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  /// Радіальний градієнт сяйва.
  static RadialGradient get glowRadial => const RadialGradient(
        colors: [Color(0x20006FCD), Color(0x00000000)],
        radius: 0.6,
      );

  /// Градієнт скляного ефекту (світла тема).
  static LinearGradient get glassGradient => const LinearGradient(
        colors: [Color(0x80FFFFFF), Color(0x40FFFFFF)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  /// Градієнт морозної зорі.
  static LinearGradient get frostStarGradient => const LinearGradient(
        colors: [Color(0xFFE1F5FE), Color(0xFFE3F2FD), Color(0xFFF3E5F5)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  /// Градієнт ранкового неба.
  static LinearGradient get morningSkyGradient => const LinearGradient(
        colors: [Color(0xFFBBDEFB), Color(0xFFE3F2FD), Color(0xFFF3E5F5)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      );

  // ─── Допоміжні методи ─────────────────────────────────────────────

  /// Повертає колір з вказаною непрозорістю.
  static Color withAlpha(Color color, double alpha) {
    return color.withValues(alpha: alpha.clamp(0.0, 1.0));
  }

  /// Повертає колір для вказаного рівня ризику серії.
  static Color riskColor(double level) {
    final clamped = level.clamp(0.0, 1.0);
    if (clamped < 0.33) return success;
    if (clamped < 0.66) return warning;
    return error;
  }

  /// Повертає колір прогресу на основі відсотка (0.0–1.0).
  static Color progressColor(double progress) {
    final p = progress.clamp(0.0, 1.0);
    if (p < 0.25) return error;
    if (p < 0.5) return warning;
    if (p < 0.75) return coin;
    return success;
  }

  /// Змішує два кольори у вказаній пропорції.
  static Color blend(Color color1, Color color2, double ratio) {
    return Color.lerp(color1, color2, ratio.clamp(0.0, 1.0)) ?? color1;
  }

  /// Повертає колір ступи серії за кількістю днів.
  static Color streakColor(int days) {
    if (days == 0) return textHint;
    if (days < 3) return const Color(0xFF81C784);
    if (days < 7) return const Color(0xFF4CAF50);
    if (days < 14) return const Color(0xFF8BC34A);
    if (days < 30) return const Color(0xFFFFC107);
    if (days < 60) return const Color(0xFFFF9800);
    if (days < 90) return const Color(0xFFFF5722);
    return const Color(0xFFFF1744);
  }

  /// Повертає колір на основі настрою.
  static Color moodColor(String mood) {
    switch (mood) {
      case 'спокійний':
        return const Color(0xFF90CAF9);
      case 'енергійний':
        return const Color(0xFFFFD600);
      case 'зосереджений':
        return const Color(0xFFB388FF);
      case 'щасливий':
        return const Color(0xFFFFAB40);
      default:
        return accent;
    }
  }

  /// Конвертує колір у HEX рядок.
  static String toHex(Color color) => AppColorsPS5.toHex(color);

  /// Парсить HEX рядок у [Color].
  static Color fromHex(String hex) => AppColorsPS5.fromHex(hex);

  /// Створює [ColorScheme] на основі Monitor світлої палітри.
  static ColorScheme colorScheme() {
    return const ColorScheme.light(
      primary: accent,
      onPrimary: Colors.white,
      primaryContainer: Color(0xFFD0E4FF),
      onPrimaryContainer: Color(0xFF001B3E),
      secondary: Color(0xFF4D9AE8),
      onSecondary: Colors.white,
      secondaryContainer: Color(0xFFD0E4FF),
      onSecondaryContainer: Color(0xFF001B3E),
      tertiary: Color(0xFF8B5CF6),
      onTertiary: Colors.white,
      tertiaryContainer: Color(0xFFEDDCFF),
      onTertiaryContainer: Color(0xFF2D0060),
      error: error,
      onError: Colors.white,
      errorContainer: Color(0xFFFFDAD6),
      onErrorContainer: Color(0xFF410002),
      surface: surface,
      onSurface: textPrimary,
      onSurfaceVariant: textSecondary,
      outline: border,
      outlineVariant: Color(0xFFC8C8DA),
      inverseSurface: Color(0xFF1A1A2E),
      onInverseSurface: Color(0xFFF5F5FA),
      inversePrimary: Color(0xFF005ABB),
    );
  }

  /// Створює [ColorScheme] з кастомним акцентом.
  static ColorScheme colorSchemeWithAccent(Color primaryAccent) {
    return ColorScheme.light(
      primary: primaryAccent,
      onPrimary: Colors.white,
      primaryContainer: AppColorsPS5.lighten(primaryAccent, 0.8),
      onPrimaryContainer: AppColorsPS5.darken(primaryAccent, 0.3),
      secondary: accentLight,
      onSecondary: Colors.white,
      surface: surface,
      onSurface: textPrimary,
      error: error,
      onError: Colors.white,
      outline: border,
    );
  }

  /// Повертає мапу всіх іменованих кольорів для дебагу.
  static Map<String, String> debugColorMap() {
    return {
      'background': toHex(background),
      'surface': toHex(surface),
      'card': toHex(card),
      'border': toHex(border),
      'textPrimary': toHex(textPrimary),
      'textSecondary': toHex(textSecondary),
      'accent': toHex(accent),
      'success': toHex(success),
      'warning': toHex(warning),
      'error': toHex(error),
    };
  }
}
