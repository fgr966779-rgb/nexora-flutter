import 'package:flutter/material.dart';

/// PS5-inspired dark theme for the Nexora app.
///
/// Колірна палітра:
/// - background: `#0A0A0F`
/// - card: `#14141F`
/// - primary: `#0070D1`
/// - secondary: `#00D4FF`
/// - text primary: `#FFFFFF`
/// - text secondary: `#8B8BA7`
/// - error: `#FF4B6E`
/// - success: `#00E676`
/// - xp: `#FFD600`
/// - coin: `#FF9100`
class Ps5Theme {
  Ps5Theme._();

  // ─── Основні кольори ───────────────────────────────────────────────────

  static const Color _background = Color(0xFF0A0A0F);
  static const Color _surface = Color(0xFF14141F);
  static const Color _surfaceVariant = Color(0xFF1A1A2E);
  static const Color _surfaceHigh = Color(0xFF24243A);
  static const Color _primary = Color(0xFF0070D1);
  static const Color _primaryLight = Color(0xFF4D9AE8);
  static const Color _secondary = Color(0xFF00D4FF);
  static const Color _tertiary = Color(0xFF7C3AED);
  static const Color _textPrimary = Color(0xFFFFFFFF);
  static const Color _textSecondary = Color(0xFF8B8BA7);
  static const Color _textHint = Color(0xFF555570);
  static const Color _error = Color(0xFFFF4B6E);
  static const Color _errorContainer = Color(0x33FF4B6E);
  static const Color _success = Color(0xFF00E676);
  static const Color _successContainer = Color(0x3300E676);
  static const Color _warning = Color(0xFFFFB300);
  static const Color _warningContainer = Color(0x33FFB300);
  static const Color _xp = Color(0xFFFFD600);
  static const Color _coin = Color(0xFFFF9100);
  static const Color _divider = Color(0xFF2A2A40);
  static const Color _border = Color(0xFF2A2A40);
  static const Color _navBackground = Color(0xFF0E0E16);
  static const Color _neonGlow = Color(0x33006FCD);
  static const Color _neonPurple = Color(0xFF7C3AED);
  static const Color _neonPink = Color(0xFFFF4081);
  static const Color _neonTeal = Color(0xFF00E5FF);
  static const Color _neonGold = Color(0xFFFFD600);
  static const Color _neonGreen = Color(0xFF00E676);

  // ─── Градієнти ─────────────────────────────────────────────────────────

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [_primary, _secondary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient xpGradient = LinearGradient(
    colors: [_xp, _coin],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const LinearGradient successGradient = LinearGradient(
    colors: [_success, Color(0xFF00C853)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Градієнт для неонового glow-ефекту PS5.
  static const LinearGradient neonGlowGradient = LinearGradient(
    colors: [_primary, _secondary, _neonPurple],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Градієнт для геймінгового режиму.
  static const LinearGradient gameModeGradient = LinearGradient(
    colors: [Color(0xFF7C3AED), _primary, _secondary],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  /// Радіальний градієнт для фонових елементів.
  static const RadialGradient radialGlow = RadialGradient(
    colors: [_primary, _background],
    radius: 0.8,
    center: Alignment.center,
  );

  /// Градієнт для прогрес-бару XP.
  static const LinearGradient xpBarGradient = LinearGradient(
    colors: [_xp, _coin],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    stops: [0.0, 0.6, 1.0],
  );

  /// Градієнт для прогрес-бару монет.
  static const LinearGradient coinBarGradient = LinearGradient(
    colors: [_coin, Color(0xFFFFB74D)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    stops: [0.0, 0.5, 1.0],
  );

  /// Градієнт для success-компонентів.
  static const LinearGradient successBarGradient = LinearGradient(
    colors: [_success, Color(0xFF00C853)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  /// Градієнт для error-компонентів.
  static const LinearGradient errorBarGradient = LinearGradient(
    colors: [_error, Color(0xFFFF1744)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  /// Градієнт для заголовків карток.
  static const LinearGradient cardHeaderGradient = LinearGradient(
    colors: [_surfaceVariant, _surface],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // ─── Кастомні декорації ──────────────────────────────────────────────────

  /// Декорація картки з неоновим світінням.
  static BoxDecoration neonCardDecoration({
    Color? glowColor,
    double blurRadius = 20,
    double spreadRadius = 2,
    BorderRadius? borderRadius,
  }) {
    return BoxDecoration(
      color: _surface,
      borderRadius: borderRadius ?? BorderRadius.circular(16),
      border: Border.all(color: _border.withValues(alpha: 0.3)),
      boxShadow: [
        BoxShadow(
          color: (glowColor ?? _neonGlow).withValues(alpha: 0.6),
          blurRadius: blurRadius,
          spreadRadius: spreadRadius,
        ),
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.3),
          blurRadius: 12,
        ),
      ],
    );
  }

  /// Декорація картки з градієнтною рамкою.
  static BoxDecoration gradientBorderDecoration({
    required Gradient gradient,
    double borderWidth = 1.5,
    BorderRadius? borderRadius,
    Color? fillColor,
  }) {
    return BoxDecoration(
      color: fillColor ?? _surface,
      borderRadius: borderRadius ?? BorderRadius.circular(16),
      border: Border.all(
        color: Colors.transparent,
        width: borderWidth,
      ),
    );
  }

  /// Декорація для glassmorphism-ефекту PS5.
  static BoxDecoration glassmorphismDecoration({
    double blur = 20,
    double opacity = 0.15,
    BorderRadius? borderRadius,
  }) {
    return BoxDecoration(
      color: _surface.withValues(alpha: opacity),
      borderRadius: borderRadius ?? BorderRadius.circular(16),
      border: Border.all(
        color: _border.withValues(alpha: 0.2),
        width: 0.5,
      ),
    );
  }

  /// Декорація для кнопки з неоновим hover-ефектом.
  static BoxDecoration neonButtonDecoration({
    required Color baseColor,
    bool isPressed = false,
    bool isHovered = false,
    BorderRadius? borderRadius,
  }) {
    return BoxDecoration(
      color: isPressed
          ? baseColor.withValues(alpha: 0.9)
          : isHovered
              ? baseColor.withValues(alpha: 0.95)
              : baseColor,
      borderRadius: borderRadius ?? BorderRadius.circular(12),
      boxShadow: [
        if (isHovered || isPressed)
          BoxShadow(
            color: baseColor.withValues(alpha: 0.4),
            blurRadius: 16,
            spreadRadius: 1,
          ),
      ],
    );
  }

  /// Декорація для виділеного стану (selected).
  static BoxDecoration selectedDecoration({
    Color? accentColor,
    BorderRadius? borderRadius,
  }) {
    final color = accentColor ?? _secondary;
    return BoxDecoration(
      color: color.withValues(alpha: 0.08),
      borderRadius: borderRadius ?? BorderRadius.circular(16),
      border: Border.all(color: color, width: 2),
    );
  }

  /// Декорація для error-стану компонента.
  static BoxDecoration errorContainerDecoration({
    BorderRadius? borderRadius,
  }) {
    return BoxDecoration(
      color: _errorContainer,
      borderRadius: borderRadius ?? BorderRadius.circular(12),
      border: Border.all(color: _error.withValues(alpha: 0.5), width: 1),
    );
  }

  /// Декорація для success-стану компонента.
  static BoxDecoration successContainerDecoration({
    BorderRadius? borderRadius,
  }) {
    return BoxDecoration(
      color: _successContainer,
      borderRadius: borderRadius ?? BorderRadius.circular(12),
      border: Border.all(color: _success.withValues(alpha: 0.5), width: 1),
    );
  }

  /// Декорація для input-поля при фокусі.
  static BoxDecoration focusedInputDecoration({
    Color? focusColor,
    double blurRadius = 16,
  }) {
    return BoxDecoration(
      boxShadow: [
        BoxShadow(
          color: (focusColor ?? _primary).withValues(alpha: 0.2),
          blurRadius: blurRadius,
          spreadRadius: 1,
        ),
      ],
    );
  }

  /// Декорація для bottom-sheet тіні.
  static BoxDecoration bottomSheetShadow({double elevation = 16}) {
    return BoxDecoration(
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.5),
          blurRadius: elevation * 0.75,
          offset: const Offset(0, -elevation * 0.25),
        ),
      ],
    );
  }

  /// Декорація для warning-контейнера з пульсуючою межею.
  static BoxDecoration warningContainerDecoration({
    BorderRadius? borderRadius,
    double borderWidth = 1.0,
  }) {
    return BoxDecoration(
      color: _warningContainer,
      borderRadius: borderRadius ?? BorderRadius.circular(12),
      border: Border.all(color: _warning.withValues(alpha: 0.6), width: borderWidth),
    );
  }

  /// Декорація для tooltip-вікна у стилі PS5.
  static BoxDecoration tooltipDecoration({
    Color? textColor,
    double blurRadius = 12,
    double spreadRadius = 1,
  }) {
    return BoxDecoration(
      color: _surfaceHigh,
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: _border.withValues(alpha: 0.5)),
      boxShadow: [
        BoxShadow(
          color: (textColor ?? _secondary).withValues(alpha: 0.15),
          blurRadius: blurRadius,
          spreadRadius: spreadRadius,
        ),
      ],
    );
  }

  /// Декорація для notification badge з неоновим обведенням.
  static BoxDecoration notificationBadgeDecoration({
    Color? badgeColor,
    bool showPulse = false,
    double borderRadius = 12,
  }) {
    final color = badgeColor ?? _error;
    return BoxDecoration(
      color: color.withValues(alpha: 0.9),
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(color: color, width: 1.5),
      boxShadow: [
        BoxShadow(
          color: color.withValues(alpha: 0.3),
          blurRadius: showPulse ? 20 : 12,
          spreadRadius: showPulse ? 2 : 0,
        ),
      ],
    );
  }

  /// Декорація для input-поля пошуку у стилі PS5.
  static BoxDecoration searchInputDecoration({
    Color? focusColor,
    bool hasError = false,
    double blurRadius = 16,
  }) {
    final errorColor = hasError ? _error : null;
    return BoxDecoration(
      boxShadow: [
        BoxShadow(
          color: (errorColor ?? focusColor ?? _primary).withValues(alpha: 0.15),
          blurRadius: blurRadius,
          spreadRadius: 1,
        ),
      ],
    );
  }

  /// Декорація для floating-кнопки з неоновим обідком.
  static BoxDecoration fabGlowDecoration({
    Color? fabColor,
    bool isPressed = false,
  }) {
    final color = fabColor ?? _primary;
    return BoxDecoration(
      boxShadow: [
        BoxShadow(
          color: color.withValues(alpha: isPressed ? 0.5 : 0.3),
          blurRadius: isPressed ? 24 : 16,
          spreadRadius: isPressed ? 4 : 2,
        ),
        BoxShadow(
          color: color.withValues(alpha: 0.15),
          blurRadius: 8,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  /// Декорація для avatar-кола з неоновою рамкою.
  static BoxDecoration avatarNeonRingDecoration({
    Color? ringColor,
    double borderWidth = 2.0,
  }) {
    final color = ringColor ?? _secondary;
    return BoxDecoration(
      shape: BoxShape.circle,
      border: Border.all(color: color, width: borderWidth),
      boxShadow: [
        BoxShadow(
          color: color.withValues(alpha: 0.25),
          blurRadius: 10,
          spreadRadius: 1,
        ),
      ],
    );
  }

  /// Декорація для картки-підсвічування при drag-дії.
  static BoxDecoration dragTargetDecoration({
    Color? highlightColor,
    bool isActive = false,
    BorderRadius? borderRadius,
  }) {
    final color = highlightColor ?? _primary;
    return BoxDecoration(
      color: isActive
          ? color.withValues(alpha: 0.12)
          : Colors.transparent,
      borderRadius: borderRadius ?? BorderRadius.circular(16),
      border: Border.all(
        color: isActive
            ? color.withValues(alpha: 0.5)
            : color.withValues(alpha: 0.15),
        width: 2,
      ),
    );
  }

  /// Декорація для shimmer-завантажувальної картки.
  static BoxDecoration shimmerCardDecoration({
    BorderRadius? borderRadius,
  }) {
    return BoxDecoration(
      color: _surface,
      borderRadius: borderRadius ?? BorderRadius.circular(16),
      border: Border.all(color: _border.withValues(alpha: 0.3)),
    );
  }

  // ─── Текстові стилі ────────────────────────────────────────────────────────

  /// Кастомний стиль для заголовків з неоновим glow.
  static const TextStyle neonTitleStyle = TextStyle(
    color: _secondary,
    fontSize: 24,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.3,
    height: 1.3,
    shadows: [
      Shadow(color: _secondary, blurRadius: 8, offset: Offset(0, 0)),
    ],
  );

  /// Кастомний стиль для підзаголовків з легким glow.
  static TextStyle neonSubtitleStyle = TextStyle(
    color: _primaryLight,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: -0.1,
    height: 1.4,
  );

  /// Стиль для міток бейджів та тегів.
  static const TextStyle badgeLabelStyle = TextStyle(
    color: _textPrimary,
    fontSize: 10,
    fontWeight: w600,
    letterSpacing: 0.5,
  );

  /// Стиль для цифрового відображення (моноширинний).
  static const TextStyle monoDisplayStyle = TextStyle(
    color: _textPrimary,
    fontSize: 28,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
    height: 1.1,
  );

  /// Стиль для невеликих цифрових значень.
  static const TextStyle monoSmallStyle = TextStyle(
    color: _textSecondary,
    fontSize: 13,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.2,
    height: 1.3,
  );

  // ─── Теми анімацій PS5 ───────────────────────────────────────────────────

  /// Тривалості анімацій у стилі PS5.
  static const animationDurations = _Ps5AnimationDurations();

  /// Ефекти переходів між екранами у стилі PS5.
  static const pageTransitionsTheme = PageTransitionsTheme(
    builders: {
      TargetPlatform.android: CupertinoPageTransitionsBuilder(),
      TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
      TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
      TargetPlatform.windows: CupertinoPageTransitionsBuilder(),
      TargetPlatform.linux: CupertinoPageTransitionsBuilder(),
    },
  );

  /// Стандартна крива анімації PS5 (еластична з затримкою).
  static const standardCurve = Curves.easeInOutCubic;

  /// Крива для bounce-анімацій PS5.
  static const bounceCurve = Curves.elasticOut;

  /// Крива для neon-pulse ефекту.
  static const neonPulseCurve = Curves.easeInOutSine;

  // ─── Теми для режиму Game Mode ───────────────────────────────────────────

  /// Створює кольорову схему для геймінгового режиму.
  static ColorScheme gameModeColorScheme() {
    return const ColorScheme.dark(
      primary: _neonPurple,
      onPrimary: _textPrimary,
      primaryContainer: Color(0x337C3AED),
      onPrimaryContainer: _textPrimary,
      secondary: _secondary,
      onSecondary: _background,
      secondaryContainer: _surfaceVariant,
      onSecondaryContainer: _textPrimary,
      tertiary: _neonPink,
      onTertiary: _textPrimary,
      tertiaryContainer: _surfaceVariant,
      onTertiaryContainer: _textPrimary,
      error: _error,
      onError: _textPrimary,
      errorContainer: _errorContainer,
      onErrorContainer: _textPrimary,
      surface: _surface,
      onSurface: _textPrimary,
      onSurfaceVariant: _textSecondary,
      outline: _border,
      outlineVariant: _divider,
      brightness: Brightness.dark,
    );
  }

  /// Створює кольорову схему для режиму high-contrast.
  static ColorScheme highContrastColorScheme() {
    return const ColorScheme.dark(
      primary: Color(0xFF4DA6FF),
      onPrimary: Color(0xFF000000),
      primaryContainer: Color(0xFF003366),
      onPrimaryContainer: Color(0xFFFFFFFF),
      secondary: Color(0xFF66E0FF),
      onSecondary: Color(0xFF000000),
      secondaryContainer: Color(0xFF003344),
      onSecondaryContainer: Color(0xFFFFFFFF),
      tertiary: Color(0xFFBB86FC),
      onTertiary: Color(0xFF000000),
      tertiaryContainer: Color(0xFF4C0066),
      onTertiaryContainer: Color(0xFFFFFFFF),
      error: Color(0xFFFFB4AB),
      onError: Color(0xFF000000),
      errorContainer: Color(0xFF690005),
      onErrorContainer: Color(0xFFFFFFFF),
      surface: Color(0xFF000000),
      onSurface: Color(0xFFFFFFFF),
      onSurfaceVariant: Color(0xFFD0BCFF),
      outline: Color(0xFF89A0C8),
      outlineVariant: Color(0xFF504870),
      brightness: Brightness.dark,
    );
  }

  // ─── Повна темна тема PS5 ─────────────────────────────────────────────

  static ThemeData get theme {
    final colorScheme = ColorScheme.dark(
      primary: _primary,
      onPrimary: _textPrimary,
      primaryContainer: _surfaceHigh,
      onPrimaryContainer: _textPrimary,
      secondary: _secondary,
      onSecondary: _background,
      secondaryContainer: _surfaceVariant,
      onSecondaryContainer: _textPrimary,
      tertiary: _tertiary,
      onTertiary: _textPrimary,
      tertiaryContainer: _surfaceVariant,
      onTertiaryContainer: _textPrimary,
      error: _error,
      onError: _textPrimary,
      errorContainer: _errorContainer,
      onErrorContainer: _textPrimary,
      surface: _surface,
      onSurface: _textPrimary,
      onSurfaceVariant: _textSecondary,
      outline: _border,
      outlineVariant: _divider,
      brightness: Brightness.dark,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: _background,
      canvasColor: _background,
      hintColor: _textSecondary.withValues(alpha: 0.6),
      pageTransitionsTheme: pageTransitionsTheme,

      // ─── AppBar ───────────────────────────────────────────────────────
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
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
        elevation: 2,
        shadowColor: Colors.black.withValues(alpha: 0.3),
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: _border.withValues(alpha: 0.5)),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        clipBehavior: Clip.antiAlias,
      ),

      // ─── Elevated Button ──────────────────────────────────────────────
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _primary,
          foregroundColor: _textPrimary,
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
          foregroundColor: _secondary,
          disabledForegroundColor: _textSecondary.withValues(alpha: 0.3),
          side: const BorderSide(color: _secondary, width: 1.5),
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
          foregroundColor: _secondary,
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
          highlightColor: _primary.withValues(alpha: 0.1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),

      // ─── Filled Button ────────────────────────────────────────────────
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: _primary,
          foregroundColor: _textPrimary,
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

      // ─── Input Decoration ─────────────────────────────────────────────
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _surface.withValues(alpha: 0.8),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
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
        backgroundColor: _navBackground,
        selectedItemColor: _secondary,
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
        selectedIconTheme: const IconThemeData(color: _secondary, size: 24),
        unselectedIconTheme: const IconThemeData(color: _textSecondary, size: 22),
        landscapeLayout: BottomNavigationBarLandscapeLayout.spread,
      ),

      // ─── Navigation Rail ──────────────────────────────────────────────
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: _navBackground,
        selectedIconTheme: const IconThemeData(color: _secondary, size: 24),
        unselectedIconTheme: const IconThemeData(color: _textSecondary, size: 22),
        selectedLabelTextStyle: const TextStyle(
          color: _secondary,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelTextStyle: const TextStyle(
          color: _textSecondary,
          fontSize: 12,
        ),
        indicatorColor: _primary.withValues(alpha: 0.15),
        elevation: 4,
      ),

      // ─── Floating Action Button ───────────────────────────────────────
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: _primary,
        foregroundColor: _textPrimary,
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
        foregroundColor: _textPrimary,
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
        color: _divider.withValues(alpha: 0.5),
        thickness: 1,
        space: 1,
      ),

      // ─── Vertical Divider ─────────────────────────────────────────────
      verticalDividerTheme: VerticalDividerThemeData(
        color: _divider.withValues(alpha: 0.5),
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
        backgroundColor: _surfaceVariant,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.black.withValues(alpha: 0.5),
        elevation: 12,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          side: BorderSide(color: _border, width: 0.5),
        ),
        modalBackgroundColor: _surfaceVariant,
        modalElevation: 16,
        dragHandleColor: _textSecondary.withValues(alpha: 0.4),
        dragHandleSize: const Size(36, 4),
        showDragHandle: true,
        constraints: const BoxConstraints(maxWidth: 560),
      ),

      // ─── SnackBar ─────────────────────────────────────────────────────
      snackBarTheme: SnackBarThemeData(
        backgroundColor: _surfaceHigh,
        contentTextStyle: const TextStyle(
          color: _textPrimary,
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: _border.withValues(alpha: 0.5)),
        ),
        elevation: 6,
        dismissDirection: DismissDirection.horizontal,
        showCloseIcon: true,
        closeIconColor: _textSecondary,
        actionTextColor: _secondary,
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
        selectedColor: _textPrimary,
        fillColor: _primary.withValues(alpha: 0.2),
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
        linearTrackColor: _surface,
        circularTrackColor: _surface,
        linearMinHeight: 4,
        refreshBackgroundColor: _surface,
      ),

      // ─── Chip ─────────────────────────────────────────────────────────
      chipTheme: ChipThemeData(
        backgroundColor: _surface,
        selectedColor: _primary.withValues(alpha: 0.2),
        disabledColor: _surface.withValues(alpha: 0.5),
        labelStyle: const TextStyle(color: _textPrimary, fontSize: 13),
        secondaryLabelStyle: const TextStyle(color: _textPrimary),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        labelPadding: const EdgeInsets.symmetric(horizontal: 4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: _border.withValues(alpha: 0.5)),
        ),
        side: BorderSide(color: _border.withValues(alpha: 0.5)),
        elevation: 0,
        pressElevation: 0,
        showCheckmark: true,
        checkmarkColor: _primary,
        deleteIconColor: _textSecondary,
      ),

      // ─── Dialog ───────────────────────────────────────────────────────
      dialogTheme: DialogTheme(
        backgroundColor: _surfaceVariant,
        surfaceTintColor: Colors.transparent,
        elevation: 16,
        shadowColor: Colors.black.withValues(alpha: 0.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: _border.withValues(alpha: 0.5)),
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
        backgroundColor: _surfaceVariant,
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
        labelColor: _secondary,
        unselectedLabelColor: _textSecondary,
        indicatorColor: _secondary,
        indicatorSize: TabBarIndicatorSize.label,
        indicatorPadding: const EdgeInsets.symmetric(horizontal: 16),
        indicatorWeight: 2.5,
        dividerColor: _divider.withValues(alpha: 0.5),
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
        inactiveTrackColor: _surface.withValues(alpha: 0.8),
        thumbColor: _secondary,
        overlayColor: _secondary.withValues(alpha: 0.2),
        valueIndicatorColor: _secondary,
        valueIndicatorTextStyle: const TextStyle(
          color: _background,
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
        inactiveTrackColor: _surface.withValues(alpha: 0.8),
        thumbColor: _secondary,
        overlayColor: _secondary.withValues(alpha: 0.2),
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
        checkColor: WidgetStateProperty.all(_textPrimary),
        side: const BorderSide(color: _textSecondary, width: 1.5),
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
          border: Border.all(color: _border.withValues(alpha: 0.5)),
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
        backgroundColor: _surfaceVariant,
        surfaceTintColor: Colors.transparent,
        headerBackgroundColor: _surfaceHigh,
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
        todayForegroundColor: WidgetStateProperty.all(_secondary),
        yearStyle: const TextStyle(color: _textPrimary, fontSize: 14),
        yearForegroundColor: WidgetStateProperty.all(_textPrimary),
        yearBackgroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return _primary;
          return Colors.transparent;
        }),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        elevation: 16,
        shadowColor: Colors.black.withValues(alpha: 0.3),
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
        backgroundColor: _surfaceVariant,
        surfaceTintColor: Colors.transparent,
        hourMinuteColor: _surfaceHigh,
        hourMinuteTextColor: _textPrimary,
        dialHandColor: _primary,
        dialBackgroundColor: _surface,
        dialTextColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return _secondary;
          return _textPrimary;
        }),
        entryModeIconColor: _textSecondary,
        dayPeriodTextColor: _textSecondary,
        dayPeriodColor: _surfaceHigh,
        dayPeriodBorderSide: const BorderSide(color: _divider),
        dayPeriodShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        elevation: 16,
        hourMinuteShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        helpTextStyle: const TextStyle(
          color: _textSecondary,
          fontSize: 13,
        ),
        cancelButtonStyle: TextButton.styleFrom(foregroundColor: _textSecondary),
        confirmButtonStyle: TextButton.styleFrom(foregroundColor: _secondary),
      ),

      // ─── Popup Menu ───────────────────────────────────────────────────
      popupMenuTheme: PopupMenuThemeData(
        color: _surfaceVariant,
        surfaceTintColor: Colors.transparent,
        elevation: 8,
        shadowColor: Colors.black.withValues(alpha: 0.3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: _border.withValues(alpha: 0.5)),
        ),
        textStyle: const TextStyle(
          color: _textPrimary,
          fontSize: 14,
        ),
        labelTextStyle: WidgetStateProperty.all(
          const TextStyle(color: _textSecondary, fontSize: 12),
        ),
        position: PopupMenuPosition.under,
        barrierColor: Colors.black54,
        popUpAnimationStyle: AnimationStyle(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
        ),
      ),

      // ─── Tooltip ──────────────────────────────────────────────────────
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: _surfaceHigh,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: _border.withValues(alpha: 0.5)),
        ),
        textStyle: const TextStyle(
          color: _textPrimary,
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
        elevation: WidgetStateProperty.all(2),
        shadowColor: WidgetStateProperty.all(
          Colors.black.withValues(alpha: 0.2),
        ),
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
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
        backgroundColor: _surfaceVariant,
        surfaceTintColor: Colors.transparent,
        elevation: 8,
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
        backgroundColor: _surfaceVariant,
        surfaceTintColor: Colors.transparent,
        elevation: 16,
        shadowColor: Colors.black.withValues(alpha: 0.3),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.horizontal(right: Radius.circular(20)),
        ),
        width: 300,
      ),

      // ─── Dropdown Menu ────────────────────────────────────────────────
      dropdownMenuTheme: DropdownMenuThemeData(
        menuStyle: MenuStyle(
          backgroundColor: WidgetStatePropertyAll(_surfaceVariant),
          surfaceTintColor: WidgetStatePropertyAll(Colors.transparent),
          elevation: WidgetStatePropertyAll(8),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: _border.withValues(alpha: 0.5)),
            ),
          ),
          shadowColor: WidgetStatePropertyAll(
            Colors.black.withValues(alpha: 0.3),
          ),
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
            borderSide: BorderSide(color: _textSecondary.withValues(alpha: 0.2)),
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
          backgroundColor: WidgetStatePropertyAll(_surfaceVariant),
          surfaceTintColor: WidgetStatePropertyAll(Colors.transparent),
          elevation: WidgetStatePropertyAll(2),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          shadowColor: WidgetStatePropertyAll(
            Colors.black.withValues(alpha: 0.2),
          ),
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
        iconColor: _secondary,
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
        selectedTileColor: Color(0x1A0070D1),
        selectedColor: _secondary,
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
    );
  }

  /// Створює темну тему PS5 з кастомним акцент-кольором.
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
    );
  }
}

// ─── Тривалості анімацій PS5 ─────────────────────────────────────────────

/// Набір тривалостей анімацій, характерних для PS5-стилю.
class _Ps5AnimationDurations {
  const _Ps5AnimationDurations();

  /// Тривалість появи елементів.
  static const Duration appear = Duration(milliseconds: 300);

  /// Тривалість зникнення елементів.
  static const Duration disappear = Duration(milliseconds: 200);

  /// Тривалість neon-pulse ефекту.
  static const Duration neonPulse = Duration(milliseconds: 1200);

  /// Тривалість bounce-анімації.
  static const Duration bounce = Duration(milliseconds: 500);

  /// Тривалість shimmer-ефекту завантаження.
  static const Duration shimmer = Duration(milliseconds: 1500);

  /// Тривалість count-up анімації чисел.
  static const Duration countUp = Duration(milliseconds: 800);

  /// Тривалість slide-in переходу.
  static const Duration slideIn = Duration(milliseconds: 250);

  /// Тривалість fade-in переходу.
  static const Duration fadeIn = Duration(milliseconds: 200);

  /// Тривалість scale-анімації.
  static const Duration scale = Duration(milliseconds: 200);

  /// Тривалість повного переходу між темами.
  static const Duration themeTransition = Duration(milliseconds: 400);

  /// Тривалість milestone-ефекту (отримання досягнення).
  static const Duration milestone = Duration(milliseconds: 600);

  /// Тривалість переходу bottom-sheet.
  static const Duration sheetTransition = Duration(milliseconds: 350);

  /// Тривалість появи toast-сповіщення.
  static const Duration toastAppear = Duration(milliseconds: 300);
}

// ─── Neon Glow Theme Extensions ──────────────────────────────────────────────

/// Розширення для створення PS5-neon ефектів у будь-якому віджеті.
extension Ps5NeonExtension on Widget {
  /// Додає neon-glow ефект до віджета.
  Widget withNeonGlow({
    Color? glowColor,
    double blurRadius = 20,
    double spreadRadius = 2,
  }) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: (glowColor ?? const Color(0x33006FCD)),
            blurRadius: blurRadius,
            spreadRadius: spreadRadius,
          ),
        ],
      ),
      child: this,
    );
  }

  /// Додає neon-border ефект до віджета.
  Widget withNeonBorder({
    Color? borderColor,
    double borderWidth = 1.5,
    double borderRadius = 16,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: borderColor ?? const Color(0xFF00D4FF),
          width: borderWidth,
        ),
      ),
      child: this,
    );
  }
}
