/// Box-shadow tokens for the Nexora gamified savings app.
///
/// Shadows are split into several categories:
/// - **Base** — elevation-based shadows for general UI.
/// - **Themed** — PS5 (dark neon) & Monitor (light frost) presets.
/// - **Dynamic** — factory methods for coloured glows & insets.
/// - **Component** — shadows for specific widgets (cards, buttons, inputs).
/// - **Animated** — helpers for smooth shadow transitions & interpolation.
library;

import 'package:flutter/material.dart';

class AppShadows {
  AppShadows._();

  // ─── Base Elevation Shadows ───────────────────────────────────────────

  /// No shadow — flat elements.
  static List<BoxShadow> get none => const [];

  /// Subtle shadow — slightly elevated cards on mobile.
  static List<BoxShadow> get sm => [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 4,
          offset: const Offset(0, 2),
        ),
      ];

  /// Medium shadow — default card elevation.
  static List<BoxShadow> get md => [
        BoxShadow(
          color: Colors.black.withOpacity(0.08),
          blurRadius: 8,
          offset: const Offset(0, 4),
        ),
      ];

  /// Level-2 — elevated cards, floating panels.
  static List<BoxShadow> get level2 => [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          blurRadius: 12,
          offset: const Offset(0, 6),
        ),
      ];

  /// Large shadow — modals, popovers.
  static List<BoxShadow> get lg => [
        BoxShadow(
          color: Colors.black.withOpacity(0.12),
          blurRadius: 16,
          offset: const Offset(0, 8),
        ),
      ];

  /// Level-4 — bottom sheets, dialogs.
  static List<BoxShadow> get level4 => [
        BoxShadow(
          color: Colors.black.withOpacity(0.15),
          blurRadius: 24,
          offset: const Offset(0, 12),
        ),
      ];

  /// Extra-large — full-screen overlays, hero elements.
  static List<BoxShadow> get xl => [
        BoxShadow(
          color: Colors.black.withOpacity(0.18),
          blurRadius: 32,
          offset: const Offset(0, 16),
        ),
      ];

  /// Floating action button — small directional shadow.
  static List<BoxShadow> get fab => [
        BoxShadow(
          color: Colors.black.withOpacity(0.2),
          blurRadius: 12,
          spreadRadius: 0,
          offset: const Offset(0, 6),
        ),
      ];

  // ─── Additional Base Shadows ─────────────────────────────────────────

  /// Ultra-subtle shadow — для тонких розділювачів та плоских кнопок.
  static List<BoxShadow> get xs => [
        BoxShadow(
          color: Colors.black.withOpacity(0.03),
          blurRadius: 2,
          offset: const Offset(0, 1),
        ),
      ];

  /// 2XL — для найвищих рівнів підняття (модальні вікна на весь екран).
  static List<BoxShadow> get xxl => [
        BoxShadow(
          color: Colors.black.withOpacity(0.22),
          blurRadius: 40,
          offset: const Offset(0, 20),
        ),
      ];

  /// Напрямлена тінь — для карток з ілюзією підняття вгору.
  static List<BoxShadow> get lifted => [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          blurRadius: 16,
          offset: const Offset(0, -4),
        ),
      ];

  /// Тінь з розмитим ореолом — для кнопок головних дій.
  static List<BoxShadow> get halo => [
        BoxShadow(
          color: Colors.black.withOpacity(0.06),
          blurRadius: 20,
          spreadRadius: 2,
          offset: const Offset(0, 4),
        ),
      ];

  // ─── PS5 Theme Shadows (dark / intense) ─────────────────────────────
  // Darker background needs stronger, more saturated shadows.

  /// PS5 small — subtle depth on dark cards.
  static List<BoxShadow> get ps5Sm => [
        BoxShadow(
          color: Colors.black.withOpacity(0.3),
          blurRadius: 6,
          offset: const Offset(0, 2),
        ),
      ];

  /// PS5 medium — default dark card elevation.
  static List<BoxShadow> get ps5Md => [
        BoxShadow(
          color: Colors.black.withOpacity(0.4),
          blurRadius: 12,
          offset: const Offset(0, 6),
        ),
      ];

  /// PS5 large — modal / sheet on dark background.
  static List<BoxShadow> get ps5Lg => [
        BoxShadow(
          color: Colors.black.withOpacity(0.5),
          blurRadius: 24,
          offset: const Offset(0, 12),
        ),
      ];

  /// PS5 extra-large — hero elements with neon halo.
  static List<BoxShadow> get ps5Xl => [
        BoxShadow(
          color: Colors.black.withOpacity(0.6),
          blurRadius: 36,
          offset: const Offset(0, 16),
        ),
      ];

  // ─── PS5 Extended Shadows ────────────────────────────────────────────

  /// PS5 неонове сяйво — синє сяйво для активних елементів.
  static List<BoxShadow> get ps5GlowBlue => [
        BoxShadow(
          color: const Color(0xFF006FCD).withOpacity(0.6),
          blurRadius: 16,
          spreadRadius: 2,
          offset: const Offset(0, 0),
        ),
        BoxShadow(
          color: const Color(0xFF006FCD).withOpacity(0.25),
          blurRadius: 32,
          spreadRadius: 0,
          offset: const Offset(0, 0),
        ),
      ];

  /// PS5 фіолетове сяйво — для особливих досягнень.
  static List<BoxShadow> get ps5GlowPurple => [
        BoxShadow(
          color: const Color(0xFF8B5CF6).withOpacity(0.55),
          blurRadius: 18,
          spreadRadius: 3,
          offset: const Offset(0, 0),
        ),
        BoxShadow(
          color: const Color(0xFF8B5CF6).withOpacity(0.2),
          blurRadius: 36,
          spreadRadius: 0,
          offset: const Offset(0, 0),
        ),
      ];

  /// PS5 кнопка — тінь для натискних кнопок у темній темі.
  static List<BoxShadow> get ps5Button => [
        BoxShadow(
          color: Colors.black.withOpacity(0.4),
          blurRadius: 8,
          offset: const Offset(0, 4),
        ),
        BoxShadow(
          color: const Color(0xFF006FCD).withOpacity(0.3),
          blurRadius: 12,
          spreadRadius: 1,
          offset: const Offset(0, 2),
        ),
      ];

  /// PS5 картка — глибока тінь для карток у темній темі.
  static List<BoxShadow> get ps5Card => [
        BoxShadow(
          color: Colors.black.withOpacity(0.35),
          blurRadius: 16,
          offset: const Offset(0, 8),
        ),
        BoxShadow(
          color: Colors.black.withOpacity(0.15),
          blurRadius: 4,
          offset: const Offset(0, 2),
        ),
      ];

  /// PS5 ігровий режим — посилене сяйво під час викликів.
  static List<BoxShadow> get ps5GameMode => [
        BoxShadow(
          color: Colors.black.withOpacity(0.5),
          blurRadius: 20,
          offset: const Offset(0, 10),
        ),
        BoxShadow(
          color: const Color(0xFFFF3366).withOpacity(0.35),
          blurRadius: 24,
          spreadRadius: 4,
          offset: const Offset(0, 0),
        ),
      ];

  // ─── Monitor Theme Shadows (light / soft) ───────────────────────────

  /// Monitor small — gentle depth on light cards.
  static List<BoxShadow> get monitorSm => [
        BoxShadow(
          color: Colors.black.withOpacity(0.04),
          blurRadius: 4,
          offset: const Offset(0, 1),
        ),
      ];

  /// Monitor medium — default light card elevation.
  static List<BoxShadow> get monitorMd => [
        BoxShadow(
          color: Colors.black.withOpacity(0.06),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ];

  /// Monitor large — elevated panels on light background.
  static List<BoxShadow> get monitorLg => [
        BoxShadow(
          color: Colors.black.withOpacity(0.08),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
      ];

  // ─── Monitor Extended Shadows ────────────────────────────────────────

  /// Monitor чистий — ледь помітна тінь для плоских елементів.
  static List<BoxShadow> get monitorClean => [
        BoxShadow(
          color: Colors.black.withOpacity(0.02),
          blurRadius: 6,
          offset: const Offset(0, 2),
        ),
      ];

  /// Monitor XL — для модальних вікон на світлому фоні.
  static List<BoxShadow> get monitorXl => [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          blurRadius: 28,
          offset: const Offset(0, 12),
        ),
      ];

  /// Monitor кнопка — м'яка тінь для кнопок у світлій темі.
  static List<BoxShadow> get monitorButton => [
        BoxShadow(
          color: Colors.black.withOpacity(0.08),
          blurRadius: 6,
          offset: const Offset(0, 2),
        ),
      ];

  /// Monitor картка — чиста тінь з білковим ореолом.
  static List<BoxShadow> get monitorCard => [
        BoxShadow(
          color: Colors.black.withOpacity(0.06),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
        BoxShadow(
          color: Colors.white.withOpacity(0.8),
          blurRadius: 4,
          offset: const Offset(0, -1),
        ),
      ];

  /// Monitor продуктивність — для панелей продуктивності.
  static List<BoxShadow> get monitorProductivity => [
        BoxShadow(
          color: Colors.blue.shade100.withOpacity(0.3),
          blurRadius: 16,
          spreadRadius: 1,
          offset: const Offset(0, 4),
        ),
      ];

  /// Monitor заморожений — блакитна тінь для стану замороження.
  static List<BoxShadow> get monitorFrozen => [
        BoxShadow(
          color: Colors.cyan.shade100.withOpacity(0.4),
          blurRadius: 20,
          spreadRadius: 2,
          offset: const Offset(0, 4),
        ),
      ];

  // ─── Component-Specific Shadows ──────────────────────────────────────

  /// Тінь для кнопки-головної дії (Primary Button).
  static List<BoxShadow> primaryButton({
    Color color = const Color(0xFF006FCD),
    bool pressed = false,
  }) =>
      [
        BoxShadow(
          color: color.withOpacity(pressed ? 0.15 : 0.3),
          blurRadius: pressed ? 4 : 12,
          spreadRadius: pressed ? 0 : 2,
          offset: Offset(0, pressed ? 1 : 4),
        ),
      ];

  /// Тінь для картки цілі — залежить від прогресу.
  static List<BoxShadow> goalCard(double progress) {
    if (progress >= 0.9) {
      return [
        ...level2,
        BoxShadow(
          color: Colors.amber.withOpacity(0.25),
          blurRadius: 16,
          spreadRadius: 2,
        ),
      ];
    }
    return level2;
  }

  /// Тінь для плаваючої кнопки (FAB).
  static List<BoxShadow> fabShadow({Color? accentColor}) {
    final shadows = [...fab];
    if (accentColor != null) {
      shadows.add(
        BoxShadow(
          color: accentColor.withOpacity(0.3),
          blurRadius: 16,
          spreadRadius: 1,
          offset: const Offset(0, 4),
        ),
      );
    }
    return shadows;
  }

  /// Тінь для текстового поля — фокусований стан.
  static List<BoxShadow> focusedInput({Color? focusColor}) => [
        BoxShadow(
          color: (focusColor ?? const Color(0xFF006FCD)).withOpacity(0.2),
          blurRadius: 12,
          spreadRadius: 1,
          offset: const Offset(0, 2),
        ),
      ];

  /// Тінь для нижнього навігаційного бару.
  static List<BoxShadow> get bottomNav => [
        BoxShadow(
          color: Colors.black.withOpacity(0.06),
          blurRadius: 16,
          offset: const Offset(0, -4),
        ),
      ];

  /// Тінь для панелі інструментів (AppBar).
  static List<BoxShadow> get appBar => [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ];

  /// Тінь для діалогового вікна.
  static List<BoxShadow> get dialog => [
        BoxShadow(
          color: Colors.black.withOpacity(0.2),
          blurRadius: 28,
          offset: const Offset(0, 14),
        ),
      ];

  /// Тінь для нижнього аркуша (BottomSheet).
  static List<BoxShadow> get bottomSheet => [
        BoxShadow(
          color: Colors.black.withOpacity(0.15),
          blurRadius: 24,
          offset: const Offset(0, -8),
        ),
      ];

  /// Тінь для бейджа з рівнем (XP Badge).
  static List<BoxShadow> xpBadge({Color? color}) => [
        BoxShadow(
          color: (color ?? Colors.amber).withOpacity(0.4),
          blurRadius: 12,
          spreadRadius: 2,
          offset: const Offset(0, 2),
        ),
      ];

  // ─── Dynamic Glow Shadows ────────────────────────────────────────────

  /// Generic coloured glow halo.
  ///
  /// Use for neon effects on buttons, progress bars, badges.
  static List<BoxShadow> glow(
    Color color, {
    double blur = 20,
    double opacity = 0.3,
    double spread = 2,
    Offset? offset,
  }) =>
      [
        BoxShadow(
          color: color.withOpacity(opacity),
          blurRadius: blur,
          spreadRadius: spread,
          offset: offset ?? Offset.zero,
        ),
      ];

  /// Neon glow — PS5-styled coloured aura with a tight core.
  static List<BoxShadow> neonGlow(
    Color color, {
    double blur = 16,
    double opacity = 0.6,
  }) =>
      [
        BoxShadow(
          color: color.withOpacity(opacity),
          blurRadius: blur,
          spreadRadius: 4,
        ),
        BoxShadow(
          color: color.withOpacity(opacity * 0.4),
          blurRadius: blur * 2,
          spreadRadius: 0,
        ),
      ];

  /// Frost glow — Monitor-styled soft icy halo.
  static List<BoxShadow> frostGlow({
    double blur = 20,
    double opacity = 0.15,
  }) =>
      [
        BoxShadow(
          color: Colors.blue.shade100.withOpacity(opacity),
          blurRadius: blur,
          spreadRadius: 0,
        ),
      ];

  /// Success glow — green aura for completed actions.
  static List<BoxShadow> successGlow({double blur = 18, double opacity = 0.4}) =>
      [
        BoxShadow(
          color: Colors.green.withOpacity(opacity),
          blurRadius: blur,
          spreadRadius: 2,
        ),
      ];

  /// Error glow — red aura for warnings / failures.
  static List<BoxShadow> errorGlow({double blur = 18, double opacity = 0.4}) =>
      [
        BoxShadow(
          color: Colors.red.withOpacity(opacity),
          blurRadius: blur,
          spreadRadius: 2,
        ),
      ];

  /// Warning glow — amber / orange aura.
  static List<BoxShadow> warningGlow({double blur = 18, double opacity = 0.35}) =>
      [
        BoxShadow(
          color: Colors.orange.withOpacity(opacity),
          blurRadius: blur,
          spreadRadius: 2,
        ),
      ];

  /// Level-up glow — golden radiant aura.
  static List<BoxShadow> levelUpGlow({double blur = 24, double opacity = 0.5}) =>
      [
        BoxShadow(
          color: Colors.amber.withOpacity(opacity),
          blurRadius: blur,
          spreadRadius: 4,
        ),
        BoxShadow(
          color: Colors.amber.withOpacity(opacity * 0.3),
          blurRadius: blur * 2,
        ),
      ];

  /// XP сяйво — для badges з досвідом.
  static List<BoxShadow> xpGlow({
    double blur = 14,
    double opacity = 0.5,
    Color color = Colors.amber,
  }) =>
      [
        BoxShadow(
          color: color.withOpacity(opacity),
          blurRadius: blur,
          spreadRadius: 3,
        ),
        BoxShadow(
          color: color.withOpacity(opacity * 0.3),
          blurRadius: blur * 1.8,
        ),
      ];

  /// Монетне сяйво — для відображення монет.
  static List<BoxShadow> coinGlow({
    double blur = 16,
    double opacity = 0.4,
    Color color = const Color(0xFFFFD700),
  }) =>
      [
        BoxShadow(
          color: color.withOpacity(opacity),
          blurRadius: blur,
          spreadRadius: 2,
        ),
      ];

  /// Вогняне сяйво — для серії (streak fire).
  static List<BoxShadow> fireGlow({
    double blur = 18,
    double opacity = 0.5,
  }) =>
      [
        BoxShadow(
          color: Colors.orange.withOpacity(opacity),
          blurRadius: blur,
          spreadRadius: 3,
        ),
        BoxShadow(
          color: Colors.red.withOpacity(opacity * 0.4),
          blurRadius: blur * 1.5,
          spreadRadius: 1,
        ),
      ];

  // ─── Inset Shadows ───────────────────────────────────────────────────

  /// Inset shadow for text fields / inputs — subtle inner depth.
  static List<BoxShadow> insetShadow({
    Color color = Colors.black,
    double blur = 6,
    double opacity = 0.08,
  }) =>
      [
        BoxShadow(
          color: color.withOpacity(opacity),
          blurRadius: blur,
          offset: const Offset(0, 2),
          inset: true,
        ),
      ];

  /// Inset shadow for frozen (disabled) fields — blue tint.
  static List<BoxShadow> frostedInsetShadow({
    double blur = 8,
    double opacity = 0.12,
  }) =>
      [
        BoxShadow(
          color: Colors.blue.shade200.withOpacity(opacity),
          blurRadius: blur,
          offset: const Offset(0, 2),
          inset: true,
        ),
      ];

  /// Внутрішня тінь для активного текстового поля.
  static List<BoxShadow> focusedInsetShadow({Color? color}) => [
        BoxShadow(
          color: (color ?? const Color(0xFF006FCD)).withOpacity(0.15),
          blurRadius: 8,
          offset: const Offset(0, 1),
          inset: true,
        ),
      ];

  /// Внутрішня тінь помилки — червонуватий відтінок.
  static List<BoxShadow> errorInsetShadow({double opacity = 0.1}) => [
        BoxShadow(
          color: Colors.red.withOpacity(opacity),
          blurRadius: 6,
          offset: const Offset(0, 1),
          inset: true,
        ),
      ];

  // ─── Dynamic Elevation Method ────────────────────────────────────────

  /// Returns a shadow list that adapts based on an elevation level 0–8.
  ///
  /// Level 0 → `none`, Level 8 → `xxl`. Intermediate levels interpolate.
  static List<BoxShadow> dynamicElevation(int level) {
    switch (level) {
      case 0:
        return none;
      case 1:
        return sm;
      case 2:
        return md;
      case 3:
        return level2;
      case 4:
        return lg;
      case 5:
        return xl;
      case 6:
        return level4;
      case 7:
        return xl;
      case 8:
        return xxl;
      default:
        return xxl;
    }
  }

  /// Повертає тінь залежно від рівня підняття для PS5 теми.
  static List<BoxShadow> ps5Elevation(int level) {
    switch (level) {
      case 0:
        return none;
      case 1:
        return ps5Sm;
      case 2:
        return ps5Md;
      case 3:
        return ps5Lg;
      case 4:
        return ps5Xl;
      default:
        return ps5Xl;
    }
  }

  /// Повертає тінь залежно від рівня підняття для Monitor теми.
  static List<BoxShadow> monitorElevation(int level) {
    switch (level) {
      case 0:
        return none;
      case 1:
        return monitorSm;
      case 2:
        return monitorMd;
      case 3:
        return monitorLg;
      case 4:
        return monitorXl;
      default:
        return monitorXl;
    }
  }

  // ─── Animated Shadow Helpers ─────────────────────────────────────────

  /// Інтерполяція між двома наборами тіней для анімації.
  ///
  /// [t] — значення від 0.0 до 1.0. При 0 повертає [from], при 1 — [to].
  static List<BoxShadow> lerp(
    List<BoxShadow> from,
    List<BoxShadow> to,
    double t,
  ) {
    final maxLen = from.length > to.length ? from.length : to.length;
    final result = <BoxShadow>[];

    for (var i = 0; i < maxLen; i++) {
      final a = i < from.length ? from[i] : _emptyShadow;
      final b = i < to.length ? to[i] : _emptyShadow;
      result.add(BoxShadow.lerp(a, b, t)!);
    }
    return result;
  }

  static const BoxShadow _emptyShadow = BoxShadow(color: Color(0x00000000));

  /// Анімована тінь що пульсує — для привернення уваги.
  ///
  /// Повертає [BoxShadow] з інтерпольованим [t] (0.0–1.0) між
  /// базовою тінню та сяйвом.
  static List<BoxShadow> pulsingGlow(
    Color color, {
    double t = 0.5,
    double baseBlur = 8,
    double glowBlur = 24,
    double baseOpacity = 0.1,
    double glowOpacity = 0.5,
    double spread = 3,
  }) {
    final blur = baseBlur + (glowBlur - baseBlur) * t;
    final opacity = baseOpacity + (glowOpacity - baseOpacity) * t;
    return [
      BoxShadow(
        color: color.withOpacity(opacity),
        blurRadius: blur,
        spreadRadius: spread * t,
      ),
    ];
  }

  /// Генерує тінь для підняття при наведенні / натисканні.
  ///
  /// [hovered] — курсор над елементом.
  /// [pressed] — елемент натиснуто.
  static List<BoxShadow> interactiveShadow({
    bool hovered = false,
    bool pressed = false,
    Color? glowColor,
  }) {
    if (pressed) {
      return const [
        BoxShadow(
          color: Color(0x0A000000),
          blurRadius: 2,
          offset: Offset(0, 1),
        ),
      ];
    }
    if (hovered) {
      final shadows = [...level2];
      if (glowColor != null) {
        shadows.add(
          BoxShadow(
            color: glowColor.withOpacity(0.2),
            blurRadius: 16,
            spreadRadius: 1,
          ),
        );
      }
      return shadows;
    }
    return sm;
  }

  /// Створює каскадну тінь — декілька шарів для глибини.
  ///
  /// [layers] — кількість шарів тіні (1–5).
  /// [color] — колір тіні.
  /// [maxBlur] — максимальний розмиття останнього шару.
  static List<BoxShadow> cascadedShadow({
    int layers = 3,
    Color color = Colors.black,
    double maxBlur = 20,
    double maxOpacity = 0.15,
    double maxYOffset = 8,
  }) {
    assert(layers >= 1 && layers <= 5, 'Кількість шарів має бути від 1 до 5');
    final result = <BoxShadow>[];
    for (var i = 0; i < layers; i++) {
      final fraction = (i + 1) / layers;
      result.add(
        BoxShadow(
          color: color.withOpacity(maxOpacity * fraction),
          blurRadius: maxBlur * fraction,
          offset: Offset(0, maxYOffset * fraction),
        ),
      );
    }
    return result;
  }

  /// Тінь для картки з градієнтним сяйвом зверху.
  ///
  /// Створює ефект «світіння зверху» для привернення уваги.
  static List<BoxShadow> topGlow({
    required Color color,
    double blur = 24,
    double opacity = 0.25,
  }) =>
      [
        BoxShadow(
          color: color.withOpacity(opacity),
          blurRadius: blur,
          offset: const Offset(0, -8),
          spreadRadius: 4,
        ),
      ];

  // ─── Додаткові компонентні тіні (Extended Component Shadows) ──────────

  /// Тінь для картки лідерборду.
  static List<BoxShadow> leaderboardCard({
    int rank = 1,
    Color? accentColor,
  }) {
    if (rank <= 3) {
      final glowColor = accentColor ?? const Color(0xFFFFD600);
      return [
        ...level2,
        BoxShadow(
          color: glowColor.withOpacity(0.2),
          blurRadius: 12,
          spreadRadius: 1,
        ),
      ];
    }
    return sm;
  }

  /// Тінь для картки товару в магазині.
  static List<BoxShadow> shopCard({bool isNew = false}) {
    if (isNew) {
      return [
        ...level2,
        BoxShadow(
          color: const Color(0xFF006FCD).withOpacity(0.15),
          blurRadius: 16,
          spreadRadius: 2,
        ),
      ];
    }
    return sm;
  }

  /// Тінь для профільної картки користувача.
  static List<BoxShadow> profileCard({bool hasGlow = false}) {
    if (hasGlow) {
      return [
        ...lg,
        BoxShadow(
          color: const Color(0xFF8B5CF6).withOpacity(0.25),
          blurRadius: 20,
          spreadRadius: 3,
        ),
      ];
    }
    return md;
  }

  /// Тінь для картки вінтажу (onboarding).
  static List<BoxShadow> onboardingCard({int step = 1, int total = 3}) {
    final progress = step / total;
    return [
      BoxShadow(
        color: const Color(0xFF006FCD).withOpacity(0.1 + progress * 0.2),
        blurRadius: 12 + progress * 12,
        spreadRadius: progress * 2,
        offset: Offset(0, 4 + progress * 4),
      ),
    ];
  }

  /// Тінь для locked/locked achievements.
  static List<BoxShadow> lockedAchievement => [
        BoxShadow(
          color: Colors.grey.withOpacity(0.3),
          blurRadius: 8,
          offset: const Offset(0, 4),
        ),
      ];

  /// Тінь для unlocked achievement з сяйвом.
  static List<BoxShadow> unlockedAchievement({Color? color}) => [
        ...lg,
        BoxShadow(
          color: (color ?? const Color(0xFFFFD600)).withOpacity(0.3),
          blurRadius: 20,
          spreadRadius: 4,
        ),
      ];

  /// Тінь для текстового blockquote.
  static List<BoxShadow> blockquote => [
        BoxShadow(
          color: const Color(0xFF006FCD).withOpacity(0.08),
          blurRadius: 0,
          offset: const Offset(3, 0),
        ),
      ];

  /// Тінь для glassmorphism картки.
  static List<BoxShadow> glassCard => [
        BoxShadow(
          color: Colors.white.withOpacity(0.1),
          blurRadius: 20,
          spreadRadius: 0,
        ),
      ];

  /// Тінь для elevated tag / pill.
  static List<BoxShadow> elevatedTag({Color? color}) => [
        BoxShadow(
          color: (color ?? Colors.black).withOpacity(0.1),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ];

  /// Багатошарова тінь для premium картки.
  static List<BoxShadow> premiumCard({
    Color accentColor = const Color(0xFFFFD600),
  }) => cascadedShadow(
        layers: 3,
        color: accentColor,
        maxBlur: 24,
        maxOpacity: 0.15,
      );

  // ─── Додаткові методи ────────────────────────────────────────────

  /// Генерує тінь з градієнтним напрямком.
  ///
  /// Корисно для 3D-ефектів підняття.
  static List<BoxShadow> directionalShadow({
    double dx = 0,
    double dy = 4,
    double blur = 12,
    double opacity = 0.1,
    Color color = Colors.black,
  }) =>
      [
        BoxShadow(
          color: color.withOpacity(opacity),
          blurRadius: blur,
          offset: Offset(dx, dy),
        ),
      ];

  /// Повертає тінь залежно від стану елемента.
  ///
  /// Плавно переходить між normal, hovered, focused, pressed.
  static List<BoxShadow> stateShadow({
    bool isHovered = false,
    bool isFocused = false,
    bool isPressed = false,
    bool isDisabled = false,
    Color? accentColor,
  }) {
    if (isDisabled) {
      return const [BoxShadow(color: Color(0x00000000))];
    }
    if (isPressed) {
      return const [
        BoxShadow(
          color: Color(0x0A000000),
          blurRadius: 2,
          offset: Offset(0, 1),
        ),
      ];
    }
    if (isFocused && accentColor != null) {
      return [
        BoxShadow(
          color: accentColor.withOpacity(0.2),
          blurRadius: 12,
          spreadRadius: 1,
          offset: Offset(0, 2),
        ),
      ];
    }
    if (isHovered) {
      return level2;
    }
    return sm;
  }

  /// Повертає опис тіні для дебагу.
  static String debugShadow(List<BoxShadow> shadows) {
    return shadows
        .map((s) => 'BoxShadow(${s.color}, blur: ${s.blurRadius}, '
          'offset: ${s.offset})')
        .join(', ');
  }

  /// Перевіряє, чи список тіней порожній.
  static bool isNoShadow(List<BoxShadow> shadows) => shadows.isEmpty;

  /// Повертає кількість шарів тіні.
  static int shadowLayerCount(List<BoxShadow> shadows) => shadows.length;

  /// Об'єднує два набори тіней.
  static List<BoxShadow> merge(List<BoxShadow> a, List<BoxShadow> b) => [
        ...a,
        ...b,
      ];

  /// Створює тінь з кольором за назвою стану.
  ///
  /// Підтримувані назви: 'success', 'error', 'warning', 'info', 'primary'.
  static List<BoxShadow> statusGlow(String status, {double blur = 16, double opacity = 0.3}) {
    final color = switch (status) {
      'success' => Colors.green,
      'error' => Colors.red,
      'warning' => Colors.orange,
      'info' => Colors.blue,
      'primary' => const Color(0xFF006FCD),
      _ => Colors.blue,
    };
    return [BoxShadow(color: color.withOpacity(opacity), blurRadius: blur)];
  }
}
