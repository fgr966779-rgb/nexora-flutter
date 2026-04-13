import 'package:flutter/material.dart';

/// Monitor-inspired light theme for the Nexora app.
///
/// Колірна палітра:
/// - background: `#F5F5F7`
/// - card: `#FFFFFF`
/// - primary: `#2563EB`
/// - secondary: `#7C3AED`
/// - text primary: `#1A1A2E`
/// - text secondary: `#6B7280`
/// - error: `#DC2626`
/// - success: `#16A34A`
/// - xp: `#FFD600`
/// - coin: `#FF9100`
class MonitorTheme {
  MonitorTheme._();

  // ─── Основні кольори ───────────────────────────────────────────────────

  static const Color _background = Color(0xFFF5F5F7);
  static const Color _surface = Color(0xFFFFFFFF);
  static const Color _surfaceVariant = Color(0xFFF0F0F5);
  static const Color _surfaceHigh = Color(0xFFFAFAFC);
  static const Color _primary = Color(0xFF2563EB);
  static const Color _primaryLight = Color(0xFF60A5FA);
  static const Color _primaryMuted = Color(0xFFDBEAFE);
  static const Color _secondary = Color(0xFF7C3AED);
  static const Color _secondaryMuted = Color(0xFFEDE9FE);
  static const Color _tertiary = Color(0xFF0891B2);
  static const Color _textPrimary = Color(0xFF1A1A2E);
  static const Color _textSecondary = Color(0xFF6B7280);
  static const Color _textHint = Color(0xFF9E9EB0);
  static const Color _error = Color(0xFFDC2626);
  static const Color _errorContainer = Color(0x1ADC2626);
  static const Color _errorMuted = Color(0xFFFEE2E2);
  static const Color _success = Color(0xFF16A34A);
  static const Color _successContainer = Color(0x1A16A34A);
  static const Color _successMuted = Color(0xFFDCFCE7);
  static const Color _warning = Color(0xFFD97706);
  static const Color _warningContainer = Color(0x1AD97706);
  static const Color _warningMuted = Color(0xFFFEF3C7);
  static const Color _xp = Color(0xFFEAB308);
  static const Color _coin = Color(0xFFEA580C);
  static const Color _divider = Color(0xFFE5E7EB);
  static const Color _border = Color(0xFFD1D5DB);
  static const Color _borderLight = Color(0xFFE5E7EB);
  static const Color _shadow = Color(0x1A000000);
  static const Color _shadowSoft = Color(0x0A000000);
  static const Color _hover = Color(0x0F2563EB);
  static const Color _focus = Color(0x1A2563EB);
  static const Color _cardHover = Color(0xFFF8FAFC);

  // ─── Градієнти ─────────────────────────────────────────────────────────

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [_primary, _primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient xpGradient = LinearGradient(
    colors: [_xp, _coin],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const LinearGradient successGradient = LinearGradient(
    colors: [_success, Color(0xFF22C55E)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient subtleGradient = LinearGradient(
    colors: [_surfaceVariant, _surfaceHigh],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  /// Градієнт для преміум-карток Monitor.
  static const LinearGradient premiumGradient = LinearGradient(
    colors: [_primary, _secondary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Градієнт для прогрес-бару цілей.
  static const LinearGradient goalProgressGradient = LinearGradient(
    colors: [_primary, _primaryLight],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  /// Градієнт для фону секцій статистики.
  static const LinearGradient statsGradient = LinearGradient(
    colors: [_surfaceVariant, _surface],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  /// Градієнт для header-ів карток.
  static const LinearGradient cardHeaderGradient = LinearGradient(
    colors: [_primaryMuted, _surface],
    begin: Alignment.topLeft,
    end: Alignment.topRight,
  );

  /// Градієнт для XP-компонентів.
  static const LinearGradient xpComponentGradient = LinearGradient(
    colors: [_xp, _coin],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  /// Градієнт для success-барів.
  static const LinearGradient successBarGradient = LinearGradient(
    colors: [_success, Color(0xFF22C55E)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  /// Градієнт для error-барів.
  static const LinearGradient errorBarGradient = LinearGradient(
    colors: [_error, Color(0xFFEF4444)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  /// Радіальний градієнт для фонових елементів.
  static const RadialGradient radialHighlight = RadialGradient(
    colors: [_primaryMuted, Colors.transparent],
    radius: 1.2,
    center: Alignment.topCenter,
  );

  // ─── Кастомні декорації ──────────────────────────────────────────────────

  /// Декорація картки з м'яким тіньовим ефектом.
  static BoxDecoration cardDecoration({
    double elevation = 1,
    BorderRadius? borderRadius,
    bool showBorder = true,
    Color? borderColor,
  }) {
    return BoxDecoration(
      color: _surface,
      elevation: elevation,
      shadowColor: _shadowSoft,
      surfaceTintColor: Colors.transparent,
      borderRadius: borderRadius ?? BorderRadius.circular(16),
      border: showBorder
          ? Border.all(
              color: borderColor ?? _borderLight,
            )
          : null,
    );
  }

  /// Декорація картки з hover-ефектом.
  static BoxDecoration cardHoverDecoration({
    BorderRadius? borderRadius,
  }) {
    return BoxDecoration(
      color: _cardHover,
      borderRadius: borderRadius ?? BorderRadius.circular(16),
      border: Border.all(color: _border),
      shadowColor: _shadow.withValues(alpha: 0.25),
    );
  }

  /// Декорація картки з виділеним станом.
  static BoxDecoration selectedCardDecoration({
    Color? accentColor,
    BorderRadius? borderRadius,
  }) {
    final color = accentColor ?? _primary;
    return BoxDecoration(
      color: _primaryMuted,
      borderRadius: borderRadius ?? BorderRadius.circular(16),
      border: Border.all(color: color, width: 2),
    );
  }

  /// Декорація для error-контейнера.
  static BoxDecoration errorContainerDecoration({
    BorderRadius? borderRadius,
  }) {
    return BoxDecoration(
      color: _errorMuted,
      borderRadius: borderRadius ?? BorderRadius.circular(12),
      border: Border.all(color: _error.withValues(alpha: 0.3), width: 1),
    );
  }

  /// Декорація для success-контейнера.
  static BoxDecoration successContainerDecoration({
    BorderRadius? borderRadius,
  }) {
    return BoxDecoration(
      color: _successMuted,
      borderRadius: borderRadius ?? BorderRadius.circular(12),
      border: Border.all(color: _success.withValues(alpha: 0.3), width: 1),
    );
  }

  /// Декорація для warning-контейнера.
  static BoxDecoration warningContainerDecoration({
    BorderRadius? borderRadius,
  }) {
    return BoxDecoration(
      color: _warningMuted,
      borderRadius: borderRadius ?? BorderRadius.circular(12),
      border: Border.all(color: _warning.withValues(alpha: 0.3), width: 1),
    );
  }

  /// Декорація для input-поля при фокусі.
  static BoxDecoration focusedInputDecoration({
    double blurRadius = 12,
    double spreadRadius = 0,
  }) {
    return BoxDecoration(
      boxShadow: [
        BoxShadow(
          color: _primary.withValues(alpha: 0.15),
          blurRadius: blurRadius,
          spreadRadius: spreadRadius,
        ),
      ],
    );
  }

  /// Декорація для спливаючого тіньового ефекту.
  static BoxDecoration softShadowDecoration({
    double blurRadius = 8,
    double offset = 2,
  }) {
    return BoxDecoration(
      boxShadow: [
        BoxShadow(
          color: _shadow,
          blurRadius: blurRadius,
          offset: Offset(0, offset),
        ),
      ],
    );
  }

  /// Декорація для проміжного поверхневого шару.
  static BoxDecoration surfaceVariantDecoration({
    BorderRadius? borderRadius,
  }) {
    return BoxDecoration(
      color: _surfaceVariant,
      borderRadius: borderRadius ?? BorderRadius.circular(16),
    );
  }

  /// Декорація для високої поверхні.
  static BoxDecoration surfaceHighDecoration({
    BorderRadius? borderRadius,
  }) {
    return BoxDecoration(
      color: _surfaceHigh,
      borderRadius: borderRadius ?? BorderRadius.circular(16),
    );
  }

  /// Декорація bottom-sheet тіні.
  static BoxDecoration bottomSheetShadow({double elevation = 8}) {
    return BoxDecoration(
      boxShadow: [
        BoxShadow(
          color: _shadow.withValues(alpha: 0.8),
          blurRadius: elevation * 0.75,
          offset: const Offset(0, -elevation * 0.25),
        ),
      ],
    );
  }

  // ─── Текстові стилі ────────────────────────────────────────────────────────

  /// Кастомний стиль заголовків Monitor.
  static const TextStyle headingAccentStyle = TextStyle(
    color: _primary,
    fontSize: 20,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.3,
    height: 1.25,
  );

  /// Стиль для підзаголовків.
  static const TextStyle subtitleStyle = TextStyle(
    color: _textSecondary,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.4,
  );

  /// Стиль для цифрового відображення.
  static const TextStyle monoDisplayStyle = TextStyle(
    color: _textPrimary,
    fontSize: 28,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
    height: 1.1,
  );

  /// Стиль для малих цифрових значень.
  static const TextStyle monoSmallStyle = TextStyle(
    color: _textSecondary,
    fontSize: 13,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.2,
    height: 1.3,
  );

  /// Стиль для лейблів та тегів.
  static const TextStyle labelStyle = TextStyle(
    color: _textSecondary,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 1.35,
  );

  // ─── Теми для режимів Monitor ────────────────────────────────────────────

  /// Створює кольорову схему для режиму читання.
  static ColorScheme readingModeColorScheme() {
    return const ColorScheme.light(
      primary: Color(0xFF1D4ED8),
      onPrimary: _surface,
      primaryContainer: _primaryMuted,
      onPrimaryContainer: _textPrimary,
      secondary: Color(0xFF5B21B6),
      onSecondary: _surface,
      secondaryContainer: Color(0xFFF3E8FF),
      onSecondaryContainer: _textPrimary,
      tertiary: _tertiary,
      onTertiary: _surface,
      tertiaryContainer: Color(0xFFECFEFF),
      onTertiaryContainer: _textPrimary,
      error: Color(0xFFB91C1C),
      onError: _surface,
      errorContainer: Color(0xFEE2E2),
      onErrorContainer: _error,
      surface: Color(0xFFFFFBEB),
      onSurface: Color(0xFF1C1917),
      onSurfaceVariant: _textSecondary,
      outline: _border,
      outlineVariant: _divider,
      brightness: Brightness.light,
    );
  }

  /// Створює кольорову схему для продуктивного режиму.
  static ColorScheme productivityColorScheme() {
    return const ColorScheme.light(
      primary: Color(0xFF2563EB),
      onPrimary: _surface,
      primaryContainer: _primaryMuted,
      onPrimaryContainer: _textPrimary,
      secondary: Color(0xFF7C3AED),
      onSecondary: _surface,
      secondaryContainer: _secondaryMuted,
      onSecondaryContainer: _textPrimary,
      tertiary: _tertiary,
      onTertiary: _surface,
      tertiaryContainer: Color(0xFFECFEFF),
      onTertiaryContainer: _textPrimary,
      error: _error,
      onError: _surface,
      errorContainer: _errorMuted,
      onErrorContainer: _error,
      surface: _surface,
      onSurface: _textPrimary,
      onSurfaceVariant: _textSecondary,
      outline: _border,
      outlineVariant: _divider,
      brightness: Brightness.light,
    );
  }

  /// Створює кольорову схему для режиму high-contrast.
  static ColorScheme highContrastColorScheme() {
    return const ColorScheme.light(
      primary: Color(0xFF000000),
      onPrimary: Color(0xFFFFFFFF),
      primaryContainer: Color(0xFF60A5FA),
      onPrimaryContainer: Color(0xFF000000),
      secondary: Color(0xFF000000),
      onSecondary: Color(0xFFFFFFFF),
      secondaryContainer: Color(0xFFCE93D8),
      onSecondaryContainer: Color(0xFF000000),
      tertiary: Color(0xFF000000),
      onTertiary: Color(0xFFFFFFFF),
      tertiaryContainer: Color(0xFFB3E5FC),
      onTertiaryContainer: Color(0xFF000000),
      error: Color(0xFFBA1A1A),
      onError: Color(0xFFFFFFFF),
      errorContainer: Color(0xFFF9DEDC),
      onErrorContainer: Color(0xFF410002),
      surface: Color(0xFFFFFFFF),
      onSurface: Color(0xFF000000),
      onSurfaceVariant: Color(0xFF49454F),
      outline: Color(0xFF79747E),
      outlineVariant: Color(0xFFC4C7D5),
      brightness: Brightness.light,
    );
  }

  // ─── Повна світла тема Monitor ─────────────────────────────────────────────

  static ThemeData get theme {
    final colorScheme = ColorScheme.light(
      primary: _primary,
      onPrimary: _surface,
      primaryContainer: _primaryMuted,
      onPrimaryContainer: _textPrimary,
      secondary: _secondary,
      onSecondary: _surface,
      secondaryContainer: _secondaryMuted,
      onSecondaryContainer: _textPrimary,
      tertiary: _tertiary,
      onTertiary: _surface,
      tertiaryContainer: Color(0xFFECFEFF),
      onTertiaryContainer: _textPrimary,
      error: _error,
      onError: _surface,
      errorContainer: _errorMuted,
      onErrorContainer: _error,
      surface: _surface,
      onSurface: _textPrimary,
      onSurfaceVariant: _textSecondary,
      outline: _border,
      outlineVariant: _divider,
      brightness: Brightness.light,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: _background,
      canvasColor: _background,
      hintColor: _textSecondary.withValues(alpha: 0.6),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),

      // ─── AppBar ───────────────────────────────────────────────────────
      appBarTheme: AppBarTheme(
        backgroundColor: _surface,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        centerTitle: true,
        surfaceTintColor: Colors.transparent,
        titleSpacing: 16,
        titleTextStyle: const TextStyle(
          color: _textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.3,
        ),
        iconTheme: const IconThemeData(color: _textSecondary, size: 24),
        actionsIconTheme: const IconThemeData(color: _textSecondary, size: 24),
        toolbarTextStyle: const TextStyle(
          color: _textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),

      // ─── Card ─────────────────────────────────────────────────────────
      cardTheme: CardTheme(
        color: _surface,
        elevation: 1,
        shadowColor: _shadowSoft,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: _borderLight),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        clipBehavior: Clip.antiAlias,
      ),

      // ─── Elevated Button ──────────────────────────────────────────────
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _primary,
          foregroundColor: _surface,
          disabledBackgroundColor: _primary.withValues(alpha: 0.3),
          disabledForegroundColor: _textSecondary.withValues(alpha: 0.5),
          elevation: 0,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.2,
          ),
        ),
      ),

      // ─── Outlined Button ──────────────────────────────────────────────
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: _primary,
          disabledForegroundColor: _textSecondary.withValues(alpha: 0.3),
          side: const BorderSide(color: _primary, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // ─── Text Button ──────────────────────────────────────────────────
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: _primary,
          disabledForegroundColor: _textSecondary.withValues(alpha: 0.3),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),

      // ─── Icon Button ──────────────────────────────────────────────────
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: _textSecondary,
          disabledForegroundColor: _textHint,
          highlightColor: _primary.withValues(alpha: 0.08),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),

      // ─── Filled Button ────────────────────────────────────────────────
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: _primary,
          foregroundColor: _surface,
          disabledBackgroundColor: _primary.withValues(alpha: 0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // ─── Filled Button Tonal ──────────────────────────────────────────
      filledButtonTonalTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: _primaryMuted,
          foregroundColor: _primary,
          disabledBackgroundColor: _primaryMuted.withValues(alpha: 0.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // ─── Input Decoration ─────────────────────────────────────────────
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _border, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _textSecondary.withValues(alpha: 0.2)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _error, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _error, width: 1.5),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _textHint.withValues(alpha: 0.15)),
        ),
        hintStyle: TextStyle(
          color: _textSecondary.withValues(alpha: 0.5),
          fontSize: 14,
        ),
        labelStyle: const TextStyle(
          color: _textSecondary,
          fontSize: 14,
        ),
        errorStyle: const TextStyle(
          color: _error,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        prefixIconColor: _textSecondary,
        suffixIconColor: _textSecondary,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        isDense: true,
        helperStyle: TextStyle(
          color: _textSecondary.withValues(alpha: 0.6),
          fontSize: 12,
        ),
        counterStyle: TextStyle(
          color: _textSecondary.withValues(alpha: 0.6),
          fontSize: 12,
        ),
      ),

      // ─── Bottom Navigation Bar ────────────────────────────────────────
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: _surface,
        selectedItemColor: _primary,
        unselectedItemColor: _textSecondary,
        selectedLabelStyle: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w400,
        ),
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        selectedIconTheme: const IconThemeData(color: _primary, size: 24),
        unselectedIconTheme: const IconThemeData(color: _textSecondary, size: 22),
        landscapeLayout: BottomNavigationBarLandscapeLayout.spread,
      ),

      // ─── Navigation Rail ──────────────────────────────────────────────
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: _surface,
        selectedIconTheme: const IconThemeData(color: _primary, size: 24),
        unselectedIconTheme: const IconThemeData(color: _textSecondary, size: 22),
        selectedLabelTextStyle: const TextStyle(
          color: _primary,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelTextStyle: const TextStyle(
          color: _textSecondary,
          fontSize: 12,
        ),
        indicatorColor: _primaryMuted,
        elevation: 2,
      ),

      // ─── Floating Action Button ───────────────────────────────────────
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: _primary,
        foregroundColor: _surface,
        elevation: 4,
        highlightElevation: 8,
        focusElevation: 6,
        disabledElevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        iconSize: 24,
      ),

      // ─── Extended Floating Action Button ───────────────────────────────
      floatingActionButtonExtendedTheme: const FloatingActionButtonThemeData(
        backgroundColor: _primary,
        foregroundColor: _surface,
        elevation: 4,
        extendedSizeConstraints: BoxConstraints(
          minWidth: 64,
          maxWidth: 256,
        ),
        extendedPadding: EdgeInsets.symmetric(horizontal: 20),
        shape: StadiumBorder(),
      ),

      // ─── Text Theme ───────────────────────────────────────────────────
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          color: _textPrimary,
          fontSize: 36,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
          height: 1.2,
        ),
        displayMedium: TextStyle(
          color: _textPrimary,
          fontSize: 32,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.4,
          height: 1.25,
        ),
        displaySmall: TextStyle(
          color: _textPrimary,
          fontSize: 28,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.3,
          height: 1.25,
        ),
        headlineLarge: TextStyle(
          color: _textPrimary,
          fontSize: 24,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.3,
          height: 1.3,
        ),
        headlineMedium: TextStyle(
          color: _textPrimary,
          fontSize: 22,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.2,
          height: 1.3,
        ),
        headlineSmall: TextStyle(
          color: _textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.2,
          height: 1.3,
        ),
        titleLarge: TextStyle(
          color: _textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.1,
          height: 1.35,
        ),
        titleMedium: TextStyle(
          color: _textPrimary,
          fontSize: 16,
          fontWeight: FontWeight.w600,
          height: 1.35,
        ),
        titleSmall: TextStyle(
          color: _textPrimary,
          fontSize: 14,
          fontWeight: FontWeight.w600,
          height: 1.35,
        ),
        bodyLarge: TextStyle(
          color: _textPrimary,
          fontSize: 16,
          fontWeight: FontWeight.w400,
          height: 1.5,
        ),
        bodyMedium: TextStyle(
          color: _textPrimary,
          fontSize: 14,
          fontWeight: FontWeight.w400,
          height: 1.5,
        ),
        bodySmall: TextStyle(
          color: _textSecondary,
          fontSize: 12,
          fontWeight: FontWeight.w400,
          height: 1.5,
        ),
        labelLarge: TextStyle(
          color: _textPrimary,
          fontSize: 14,
          fontWeight: FontWeight.w500,
          height: 1.35,
        ),
        labelMedium: TextStyle(
          color: _textSecondary,
          fontSize: 12,
          fontWeight: FontWeight.w500,
          height: 1.35,
        ),
        labelSmall: TextStyle(
          color: _textSecondary,
          fontSize: 10,
          fontWeight: FontWeight.w500,
          height: 1.35,
        ),
      ),

      // ─── Divider ──────────────────────────────────────────────────────
      dividerTheme: DividerThemeData(
        color: _divider,
        thickness: 1,
        space: 1,
      ),

      // ─── Vertical Divider ─────────────────────────────────────────────
      verticalDividerTheme: VerticalDividerThemeData(
        color: _divider,
        thickness: 1,
        width: 1,
        spacing: 8,
      ),

      // ─── Icon ─────────────────────────────────────────────────────────
      iconTheme: const IconThemeData(
        color: _textSecondary,
        size: 24,
        fill: 0,
      ),

      // ─── Primary Icon ─────────────────────────────────────────────────
      primaryIconTheme: const IconThemeData(
        color: _primary,
        size: 24,
      ),

      // ─── Bottom Sheet ─────────────────────────────────────────────────
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: _surface,
        surfaceTintColor: Colors.transparent,
        shadowColor: _shadow,
        elevation: 8,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          side: BorderSide(color: _borderLight),
        ),
        modalBackgroundColor: _surface,
        modalElevation: 12,
        dragHandleColor: _textSecondary.withValues(alpha: 0.4),
        dragHandleSize: const Size(36, 4),
        showDragHandle: true,
        constraints: const BoxConstraints(maxWidth: 560),
      ),

      // ─── SnackBar ─────────────────────────────────────────────────────
      snackBarTheme: SnackBarThemeData(
        backgroundColor: _textPrimary,
        contentTextStyle: const TextStyle(
          color: _surface,
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 6,
        dismissDirection: DismissDirection.horizontal,
        showCloseIcon: true,
        closeIconColor: _surface.withValues(alpha: 0.7),
        actionTextColor: _primaryLight,
        width: 400,
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),

      // ─── Switch ───────────────────────────────────────────────────────
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return _primary;
          return _textSecondary;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return _primary.withValues(alpha: 0.5);
          }
          return _textSecondary.withValues(alpha: 0.3);
        }),
        trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
        splashRadius: 20,
      ),

      // ─── Toggle Buttons ───────────────────────────────────────────────
      toggleButtonsTheme: ToggleButtonsThemeData(
        borderColor: _border,
        selectedBorderColor: _primary,
        selectedColor: _primary,
        fillColor: _primaryMuted,
        borderRadius: BorderRadius.circular(12),
        borderWidth: 1.5,
        constraints: const BoxConstraints(minHeight: 40),
        textStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),

      // ─── Progress Indicator ───────────────────────────────────────────
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: _primary,
        linearTrackColor: _surfaceVariant,
        circularTrackColor: _surfaceVariant,
        linearMinHeight: 4,
        refreshBackgroundColor: _surfaceVariant,
      ),

      // ─── Chip ─────────────────────────────────────────────────────────
      chipTheme: ChipThemeData(
        backgroundColor: _surfaceVariant,
        selectedColor: _primaryMuted,
        disabledColor: _surfaceVariant.withValues(alpha: 0.5),
        labelStyle: const TextStyle(color: _textPrimary, fontSize: 13),
        secondaryLabelStyle: const TextStyle(color: _textPrimary),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        labelPadding: const EdgeInsets.symmetric(horizontal: 4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: _borderLight),
        ),
        side: BorderSide(color: _borderLight),
        elevation: 0,
        pressElevation: 0,
        showCheckmark: true,
        checkmarkColor: _primary,
        deleteIconColor: _textSecondary,
      ),

      // ─── Dialog ───────────────────────────────────────────────────────
      dialogTheme: DialogTheme(
        backgroundColor: _surface,
        surfaceTintColor: Colors.transparent,
        elevation: 8,
        shadowColor: _shadow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: _borderLight),
        ),
        titleTextStyle: const TextStyle(
          color: _textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.3,
        ),
        contentTextStyle: const TextStyle(
          color: _textSecondary,
          fontSize: 14,
          height: 1.5,
        ),
        actionsPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
        alignment: Alignment.center,
      ),

      // ─── Alert Dialog ─────────────────────────────────────────────────
      alertDialogTheme: AlertDialogTheme(
        backgroundColor: _surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        titleTextStyle: const TextStyle(
          color: _textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
        contentTextStyle: const TextStyle(
          color: _textSecondary,
          fontSize: 14,
        ),
        actionsPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      ),

      // ─── Tab Bar ──────────────────────────────────────────────────────
      tabBarTheme: TabBarTheme(
        labelColor: _primary,
        unselectedLabelColor: _textSecondary,
        indicatorColor: _primary,
        indicatorSize: TabBarIndicatorSize.label,
        indicatorPadding: const EdgeInsets.symmetric(horizontal: 16),
        indicatorWeight: 2.5,
        dividerColor: _divider,
        labelStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
        tabAlignment: TabAlignment.start,
        splashFactory: InkRipple.splashFactory,
      ),

      // ─── Slider ───────────────────────────────────────────────────────
      sliderTheme: SliderThemeData(
        activeTrackColor: _primary,
        inactiveTrackColor: _surfaceVariant,
        thumbColor: _primary,
        overlayColor: _primary.withValues(alpha: 0.15),
        valueIndicatorColor: _primary,
        valueIndicatorTextStyle: const TextStyle(
          color: _surface,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
        trackHeight: 4,
        thumbShape: const RoundSliderThumbShape(elevation: 2),
        overlayShape: const RoundSliderOverlayShape(),
        valueIndicatorShape: const DropSliderValueIndicatorShape(),
        showValueIndicator: ShowValueIndicator.always,
        minThumbSeparation: 8,
      ),

      // ─── Range Slider ─────────────────────────────────────────────────
      rangeSliderTheme: RangeSliderThemeData(
        activeTrackColor: _primary,
        inactiveTrackColor: _surfaceVariant,
        thumbColor: _primary,
        overlayColor: _primary.withValues(alpha: 0.15),
        valuesTextStyle: const TextStyle(
          color: _textPrimary,
          fontSize: 12,
        ),
        trackHeight: 4,
      ),

      // ─── Checkbox ─────────────────────────────────────────────────────
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return _primary;
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(_surface),
        side: const BorderSide(color: _border, width: 1.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
        splashRadius: 16,
      ),

      // ─── Radio ────────────────────────────────────────────────────────
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return _primary;
          return _textSecondary;
        }),
        splashRadius: 16,
      ),

      // ─── Data Table ───────────────────────────────────────────────────
      dataTableTheme: DataTableThemeData(
        decoration: BoxDecoration(
          color: _surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _borderLight),
        ),
        dataTextStyle: const TextStyle(
          color: _textPrimary,
          fontSize: 14,
        ),
        headingTextStyle: const TextStyle(
          color: _textSecondary,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
        headingRowColor: WidgetStateProperty.all(_surfaceVariant),
        dataRowColor: WidgetStateProperty.all(_surface),
        dataRowMinHeight: 48,
        dataRowMaxHeight: 64,
        dividerThickness: 1,
        horizontalMargin: 16,
        columnSpacing: 24,
        headingRowHeight: 52,
        checkboxHorizontalMargin: 12,
      ),

      // ─── Date Picker ──────────────────────────────────────────────────
      datePickerTheme: DatePickerThemeData(
        backgroundColor: _surface,
        surfaceTintColor: Colors.transparent,
        headerBackgroundColor: _surfaceVariant,
        headerForegroundColor: _textPrimary,
        headerHeadlineStyle: const TextStyle(
          color: _textPrimary,
          fontSize: 22,
          fontWeight: FontWeight.w700,
        ),
        headerHelpStyle: const TextStyle(
          color: _textSecondary,
          fontSize: 13,
        ),
        weekdayStyle: const TextStyle(
          color: _textSecondary,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        dayStyle: const TextStyle(color: _textPrimary, fontSize: 14),
        dayForegroundColor: WidgetStateProperty.all(_textPrimary),
        dayBackgroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return _primary;
          return Colors.transparent;
        }),
        todayForegroundColor: WidgetStateProperty.all(_primary),
        todayBackgroundColor: WidgetStateProperty.all(_primaryMuted),
        yearStyle: const TextStyle(color: _textPrimary, fontSize: 14),
        yearForegroundColor: WidgetStateProperty.all(_textPrimary),
        yearBackgroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return _primary;
          return Colors.transparent;
        }),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        elevation: 8,
        shadowColor: _shadowSoft,
        dividerColor: _divider,
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: _surface,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),

      // ─── Time Picker ──────────────────────────────────────────────────
      timePickerTheme: TimePickerThemeData(
        backgroundColor: _surface,
        surfaceTintColor: Colors.transparent,
        hourMinuteColor: _surfaceVariant,
        hourMinuteTextColor: _textPrimary,
        dialHandColor: _primary,
        dialBackgroundColor: _surfaceVariant,
        dialTextColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return _primary;
          return _textPrimary;
        }),
        entryModeIconColor: _textSecondary,
        dayPeriodTextColor: _textSecondary,
        dayPeriodColor: _surfaceVariant,
        dayPeriodBorderSide: const BorderSide(color: _borderLight),
        dayPeriodShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        elevation: 8,
        hourMinuteShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        helpTextStyle: const TextStyle(
          color: _textSecondary,
          fontSize: 13,
        ),
        cancelButtonStyle: TextButton.styleFrom(foregroundColor: _textSecondary),
        confirmButtonStyle: TextButton.styleFrom(foregroundColor: _primary),
      ),

      // ─── Popup Menu ───────────────────────────────────────────────────
      popupMenuTheme: PopupMenuThemeData(
        color: _surface,
        surfaceTintColor: Colors.transparent,
        elevation: 4,
        shadowColor: _shadow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: _borderLight),
        ),
        textStyle: const TextStyle(
          color: _textPrimary,
          fontSize: 14,
        ),
        labelTextStyle: WidgetStateProperty.all(
          const TextStyle(color: _textSecondary, fontSize: 12),
        ),
        position: PopupMenuPosition.under,
        barrierColor: Colors.black26,
        popUpAnimationStyle: AnimationStyle(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
        ),
      ),

      // ─── Tooltip ──────────────────────────────────────────────────────
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: _textPrimary,
          borderRadius: BorderRadius.circular(8),
        ),
        textStyle: const TextStyle(
          color: _surface,
          fontSize: 12,
          fontWeight: FontWeight.w400,
        ),
        height: 32,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        margin: const EdgeInsets.symmetric(horizontal: 8),
        preferBelow: true,
        verticalOffset: 8,
        waitDuration: const Duration(milliseconds: 600),
        showDuration: const Duration(seconds: 3),
        enableFeedback: true,
      ),

      // ─── Search Bar ───────────────────────────────────────────────────
      searchBarTheme: SearchBarThemeData(
        backgroundColor: WidgetStateProperty.all(_surface),
        surfaceTintColor: WidgetStateProperty.all(Colors.transparent),
        elevation: WidgetStateProperty.all(1),
        shadowColor: WidgetStateProperty.all(_shadowSoft),
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
            side: BorderSide(color: _borderLight),
          ),
        ),
        textStyle: WidgetStateProperty.all(
          const TextStyle(color: _textPrimary, fontSize: 14),
        ),
        hintStyle: WidgetStateProperty.all(
          TextStyle(color: _textSecondary.withValues(alpha: 0.5), fontSize: 14),
        ),
        padding: WidgetStateProperty.all(
          const EdgeInsets.symmetric(horizontal: 16),
        ),
        textCapitalization: TextCapitalization.none,
      ),

      // ─── Search View ──────────────────────────────────────────────────
      searchViewTheme: SearchViewThemeData(
        backgroundColor: _surface,
        surfaceTintColor: Colors.transparent,
        elevation: 4,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        dividerColor: _divider,
        headerHintStyle: TextStyle(
          color: _textSecondary.withValues(alpha: 0.5),
          fontSize: 16,
        ),
        headerTextStyle: const TextStyle(
          color: _textPrimary,
          fontSize: 16,
        ),
      ),

      // ─── Drawer ───────────────────────────────────────────────────────
      drawerTheme: DrawerThemeData(
        backgroundColor: _surface,
        surfaceTintColor: Colors.transparent,
        elevation: 4,
        shadowColor: _shadow,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.horizontal(right: Radius.circular(20)),
        ),
        width: 300,
      ),

      // ─── Dropdown Menu ────────────────────────────────────────────────
      dropdownMenuTheme: DropdownMenuThemeData(
        menuStyle: MenuStyle(
          backgroundColor: WidgetStatePropertyAll(_surface),
          surfaceTintColor: WidgetStatePropertyAll(Colors.transparent),
          elevation: WidgetStatePropertyAll(4),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: _borderLight),
            ),
          ),
          shadowColor: WidgetStatePropertyAll(_shadow),
        ),
        textStyle: const TextStyle(
          color: _textPrimary,
          fontSize: 14,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: _surface,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: _borderLight),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: _primary, width: 1.5),
          ),
        ),
      ),

      // ─── Menu Bar ─────────────────────────────────────────────────────
      menuBarTheme: MenuBarThemeData(
        style: MenuStyle(
          backgroundColor: WidgetStatePropertyAll(_surface),
          surfaceTintColor: WidgetStatePropertyAll(Colors.transparent),
          elevation: WidgetStatePropertyAll(1),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          shadowColor: WidgetStatePropertyAll(_shadowSoft),
        ),
      ),

      // ─── Menu Button ──────────────────────────────────────────────────
      menuButtonTheme: MenuButtonThemeData(
        style: ButtonStyle(
          textStyle: WidgetStatePropertyAll(
            const TextStyle(color: _textPrimary, fontSize: 14),
          ),
        ),
      ),

      // ─── Expansion Tile ───────────────────────────────────────────────
      expansionTileTheme: const ExpansionTileThemeData(
        tilePadding: EdgeInsets.symmetric(horizontal: 16),
        childrenPadding: EdgeInsets.only(left: 32, right: 16, bottom: 8),
        iconColor: _primary,
        textColor: _textPrimary,
        collapsedIconColor: _textSecondary,
        collapsedTextColor: _textPrimary,
        shape: Border(bottom: BorderSide(color: _divider, width: 0.5)),
        collapsedShape: Border(bottom: BorderSide(color: _divider, width: 0.5)),
      ),

      // ─── List Tile ────────────────────────────────────────────────────
      listTileTheme: const ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(horizontal: 16),
        horizontalTitleGap: 12,
        minVerticalPadding: 8,
        titleTextStyle: TextStyle(
          color: _textPrimary,
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
        subtitleTextStyle: TextStyle(
          color: _textSecondary,
          fontSize: 13,
        ),
        leadingAndTrailingTextStyle: TextStyle(
          color: _textSecondary,
          fontSize: 13,
        ),
        iconColor: _textSecondary,
        selectedTileColor: _primaryMuted,
        selectedColor: _primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),

      // ─── Badge / Tooltip ─────────────────────────────────────────────
      badgeTheme: BadgeThemeData(
        backgroundColor: _error,
        textColor: Colors.white,
        textSize: 11,
        smallSize: const Size(16, 16),
        largeSize: const Size(20, 20),
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      ),

      // ─── Scrollbar ──────────────────────────────────────────────────
      scrollbarTheme: ScrollbarThemeData(
        thumbColor: WidgetStatePropertyAll(_border),
        radius: const Radius.circular(8),
        thickness: MaterialStatePropertyAll(6),
        trackColor: WidgetStatePropertyAll(_surfaceVariant),
        trackVisibility: MaterialStatePropertyAll(ScrollbarVisibility()),
      ),

      // ─── Splash Color ───────────────────────────────────────────────
      splashColor: _primaryMuted,

      // ─── Ink Ripple ─────────────────────────────────────────────────
      inkSplashFactory: InkRipple.splashFactory,
    );
  }

  /// Створює світлу тему Monitor з кастомним акцент-кольором.
  static ThemeData withAccent(Color accent) {
    final base = theme;
    return base.copyWith(
      colorScheme: base.colorScheme.copyWith(
        primary: accent,
        secondary: accent,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accent,
          foregroundColor: base.colorScheme.onPrimary,
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: accent,
        foregroundColor: base.colorScheme.onPrimary,
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: accent,
      ),
    );
  }

  /// Створює світлу тему для режиму читання.
  static ThemeData readingTheme() {
    return ThemeData.light(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: readingModeColorScheme(),
      scaffoldBackgroundColor: const Color(0xFFFFFBEB),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          color: Color(0xFF1C1917),
          fontSize: 36,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
          height: 1.35,
        ),
        bodyLarge: TextStyle(
          color: Color(0xFF1C1917),
          fontSize: 16,
          fontWeight: FontWeight.w400,
          height: 1.8,
        ),
        bodyMedium: TextStyle(
          color: Color(0xFF1C1917),
          fontSize: 14,
          fontWeight: FontWeight.w400,
          height: 1.75,
        ),
      ),
      cardTheme: CardTheme(
        color: const Color(0xFFFFFBEB),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  /// Створює світлу тему для продуктивного режиму.
  static ThemeData productivityTheme() {
    return ThemeData.light(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: productivityColorScheme(),
      scaffoldBackgroundColor: _background,
      textTheme: theme.textTheme,
      cardTheme: theme.cardTheme,
    );
  }
}

// ─── Monitor Accessibility Theme Extensions ──────────────────────────────────

/// Розширення для доступності Monitor-тему.
extension MonitorAccessibilityExtension on ThemeData {
  /// Повертає тему з застосуванням оверрайдів доступності.
  ThemeData applyAccessibility({
    bool highContrast = false,
    bool largeText = false,
    bool reduceMotion = false,
  }) {
    if (!highContrast && !largeText && !reduceMotion) return this;

    var modified = this;

    if (highContrast) {
      modified = modified.copyWith(
        colorScheme: MonitorTheme.highContrastColorScheme(),
        iconTheme: modified.iconTheme.copyWith(
          size: 26,
        ),
      );
    }

    if (largeText) {
      modified = modified.copyWith(
        textTheme: modified.textTheme.copyWith(
          displayLarge: modified.textTheme.displayLarge?.copyWith(fontSize: 40),
          displayMedium: modified.textTheme.displayMedium?.copyWith(fontSize: 36),
          displaySmall: modified.textTheme.displaySmall?.copyWith(fontSize: 32),
          headlineLarge: modified.textTheme.headlineLarge?.copyWith(fontSize: 28),
          headlineMedium: modified.textTheme.headlineMedium?.copyWith(fontSize: 26),
          headlineSmall: modified.textTheme.headlineSmall?.copyWith(fontSize: 24),
          bodyLarge: modified.textTheme.bodyLarge?.copyWith(fontSize: 20),
          bodyMedium: modified.textTheme.bodyMedium?.copyWith(fontSize: 18),
          bodySmall: modified.textTheme.bodySmall?.copyWith(fontSize: 16),
        ),
      );
    }

    return modified;
  }
}
