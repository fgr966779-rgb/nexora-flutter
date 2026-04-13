import 'dart:async';

import 'package:flutter/material.dart' hide ThemeMode;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../constants/app_enums.dart';
import 'ps5_theme.dart';
import 'monitor_theme.dart';

// ─── Ключі збереження ────────────────────────────────────────────────────────

const _keyGoalType = 'nexora_goal_type';
const _keyBrightness = 'nexora_brightness';
const _keyAccentColor = 'nexora_accent_color';
const _keyUseSystem = 'nexora_use_system';
const _keyFontSize = 'nexora_font_scale';
const _keyHighContrast = 'nexora_high_contrast';
const _keyReduceMotion = 'nexora_reduce_motion';

// ─── Перехід теми ──────────────────────────────────────────────────────────────

/// Опис конфігурації для анімації переходу між темами.
class ThemeTransitionConfig {
  /// Створює конфігурацію переходу теми.
  const ThemeTransitionConfig({
    this.duration = const Duration(milliseconds: 400),
    this.curve = Curves.easeInOutCubic,
    this.enableFade = true,
    this.enableScale = false,
    this.scaleFactor = 0.98,
  });

  /// Тривалість анімації переходу.
  final Duration duration;

  /// Крива анімації.
  final Curve curve;

  /// Увімкнути fade-ефект.
  final bool enableFade;

  /// Увімкнути scale-ефект (легке зменшення/збільшення).
  final bool enableScale;

  /// Коефіцієнт масштабування при переході.
  final double scaleFactor;

  /// Стандартна конфігурація — плавне перехресне розчинення.
  static const standard = ThemeTransitionConfig();

  /// Швидкий перехід — для швидких перемикань.
  static const fast = ThemeTransitionConfig(
    duration: Duration(milliseconds: 200),
    curve: Curves.easeOutCubic,
  );

  /// Економний перехід — без масштабування.
  static const minimal = ThemeTransitionConfig(
    duration: Duration(milliseconds: 150),
    enableFade: false,
  );

  /// Розширений перехід — зі scale-ефектом.
  static const elaborate = ThemeTransitionConfig(
    duration: Duration(milliseconds: 600),
    curve: Curves.easeInOutQuart,
    enableScale: true,
    scaleFactor: 0.96,
  );
}

// ─── Стан теми додатку ──────────────────────────────────────────────────────

/// Повний стан теми, що включає цільовий тип, режим яскравості
/// та необов'язковий кастомний акцент-колір.
class ThemeState {
  /// Тип цілі (PS5 / Monitor / Custom), який визначає основну палітру.
  final GoalType goalType;

  /// Поточна тема [ThemeData], обрана на основі [goalType].
  final ThemeData theme;

  /// Режим яскравості, обраний користувачем.
  final ThemeMode brightness;

  /// Кастомний колір акценту, що перевизначає стандартний.
  /// Якщо `null` — використовується типовий колір із палітри.
  final Color? customAccent;

  /// Чи відбувається анімація переходу між темами.
  final bool isTransitioning;

  /// Чи слідувати за системною темою.
  final bool followSystem;

  /// Масштаб шрифту (1.0 = стандартний).
  final double fontScale;

  /// Режим високого контрасту для доступності.
  final bool highContrast;

  /// Режим зменшення руху для доступності.
  final bool reduceMotion;

  const ThemeState({
    required this.goalType,
    required this.theme,
    this.brightness = ThemeMode.dark,
    this.customAccent,
    this.isTransitioning = false,
    this.followSystem = false,
    this.fontScale = 1.0,
    this.highContrast = false,
    this.reduceMotion = false,
  });

  /// Створює копію стану з перезаписом вказаних полів.
  ThemeState copyWith({
    GoalType? goalType,
    ThemeData? theme,
    ThemeMode? brightness,
    Color? customAccent,
    bool? isTransitioning,
    bool clearAccent = false,
    bool? followSystem,
    double? fontScale,
    bool? highContrast,
    bool? reduceMotion,
  }) {
    return ThemeState(
      goalType: goalType ?? this.goalType,
      theme: theme ?? this.theme,
      brightness: brightness ?? this.brightness,
      customAccent: clearAccent ? null : (customAccent ?? this.customAccent),
      isTransitioning: isTransitioning ?? this.isTransitioning,
      followSystem: followSystem ?? this.followSystem,
      fontScale: fontScale ?? this.fontScale,
      highContrast: highContrast ?? this.highContrast,
      reduceMotion: reduceMotion ?? this.reduceMotion,
    );
  }

  /// Чи є поточна тема темною.
  ///
  /// Повертає `true` якщо [brightness] дорівнює [ThemeMode.dark] або
  /// [ThemeMode.system] із системною темною темою.
  bool get isDark {
    switch (brightness) {
      case ThemeMode.dark:
        return true;
      case ThemeMode.light:
        return false;
      case ThemeMode.system:
        // За замовчуванням вважаємо темною, якщо немає доступу до платформи
        return goalType == GoalType.ps5;
    }
  }

  /// Тривалість анімації переходу між темами (мс).
  Duration get transitionDuration => const Duration(milliseconds: 400);

  /// Крива анімації для перехресного розчинення теми.
  Curve get transitionCurve => Curves.easeInOutCubic;

  /// Чи доступна кастомізація шрифту.
  bool get isFontScaleCustom => (fontScale - 1.0).abs() > 0.01;

  /// Чи увімкнені будь-які налаштування доступності.
  bool get hasAccessibilityOverrides => highContrast || reduceMotion;

  /// Опис поточного стану теми для логування.
  String get debugDescription =>
      'ThemeState(goalType: $goalType, brightness: ${brightness.name}, '
      'customAccent: ${customAccent != null}, followSystem: $followSystem, '
      'fontScale: $fontScale, highContrast: $highContrast, '
      'reduceMotion: $reduceMotion)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ThemeState &&
          runtimeType == other.runtimeType &&
          goalType == other.goalType &&
          brightness == other.brightness &&
          customAccent == other.customAccent &&
          followSystem == other.followSystem &&
          fontScale == other.fontScale &&
          highContrast == other.highContrast &&
          reduceMotion == other.reduceMotion;

  @override
  int get hashCode => Object.hash(
        goalType,
        brightness,
        customAccent,
        followSystem,
        fontScale,
        highContrast,
        reduceMotion,
      );
}

// ─── Нотифікатор теми ───────────────────────────────────────────────────────

/// Нотифікатор для керування темою додатку.
///
/// Підтримує:
/// - Перемикання між темами PS5 (темна) та Monitor (світла).
/// - Три режими яскравості: темна, світла, системна.
/// - Кастомний акцент-колір.
/// - Перехресне розчинення при переході між темами.
/// - Збереження / відновлення налаштувань.
/// - Системне слідування за темою пристрою.
/// - Масштабування шрифту.
/// - Режими доступності (високий контраст, зменшення руху).
/// - Збереження у пресети.
class ThemeNotifier extends StateNotifier<ThemeState> {
  /// Опціональний зовнішній сторедж для персистентності.
  ///
  /// Використовується замість Hive/SharedPreferences для тестування.
  Map<String, dynamic>? externalStorage;

  /// Остання конфігурація переходу.
  ThemeTransitionConfig _transitionConfig = ThemeTransitionConfig.standard;

  /// Кеш попередніх тем для швидкого повернення.
  final Map<String, ThemeData> _themeCache = {};

  /// Стрим історії змін теми.
  final _themeHistory = <ThemeState>[];

  /// Максимальна кількість записів в історії.
  static const _maxHistorySize = 10;

  ThemeNotifier() : super(const ThemeState(goalType: GoalType.ps5, theme: Ps5Theme.theme)) {
    // Ініціалізуємо кеш
    _themeCache['ps5_dark'] = Ps5Theme.theme;
    _themeCache['monitor_light'] = MonitorTheme.theme;
  }

  // ─── Базові методи ─────────────────────────────────────────────────────

  /// Встановлює тему на основі типу цілі.
  ///
  /// Якщо [animate] дорівнює `true`, увімкнеться прапорець
  /// [ThemeState.isTransitioning] для перехресного розчинення.
  void setTheme(GoalType type, {bool animate = false}) {
    final newTheme = _getCachedOrBuild(type);

    if (animate) {
      state = state.copyWith(isTransitioning: true);
      Future.delayed(const Duration(milliseconds: 50), () {
        state = ThemeState(
          goalType: type,
          theme: newTheme,
          brightness: state.brightness,
          customAccent: state.customAccent,
          followSystem: state.followSystem,
          fontScale: state.fontScale,
          highContrast: state.highContrast,
          reduceMotion: state.reduceMotion,
        );
      });
    } else {
      state = ThemeState(
        goalType: type,
        theme: newTheme,
        brightness: state.brightness,
        customAccent: state.customAccent,
        followSystem: state.followSystem,
        fontScale: state.fontScale,
        highContrast: state.highContrast,
        reduceMotion: state.reduceMotion,
      );
    }
    _addToHistory();
    _persistGoalType(type);
  }

  /// Повертає тему для вказаного типу цілі без зміни стану.
  ThemeData getThemeForGoalType(GoalType type) {
    return _getCachedOrBuild(type);
  }

  /// Отримує тему з кешу або будує нову.
  ThemeData _getCachedOrBuild(GoalType type) {
    final key = '${type.name}_${state.brightness.name}';
    if (_themeCache.containsKey(key)) {
      return _themeCache[key]!;
    }
    final theme = _buildThemeForGoalType(type);
    _themeCache[key] = theme;
    return theme;
  }

  ThemeData _buildThemeForGoalType(GoalType type) {
    switch (type) {
      case GoalType.ps5:
        return Ps5Theme.theme;
      case GoalType.monitor:
        return MonitorTheme.theme;
      case GoalType.custom:
        // Custom поки що використовує тему PS5 як запасну
        return Ps5Theme.theme;
    }
  }

  // ─── Конфігурація переходу ─────────────────────────────────────────────

  /// Встановлює конфігурацію анімації переходу.
  ///
  /// Ця конфігурація може бути використана в [App] для налаштування
  /// [AnimatedTheme] або [TweenAnimationBuilder].
  void setTransitionConfig(ThemeTransitionConfig config) {
    _transitionConfig = config;
  }

  /// Повертає поточну конфігурацію переходу.
  ThemeTransitionConfig get transitionConfig => _transitionConfig;

  // ─── Історія тем ──────────────────────────────────────────────────────────

  /// Додає поточний стан до історії.
  void _addToHistory() {
    _themeHistory.add(state);
    if (_themeHistory.length > _maxHistorySize) {
      _themeHistory.removeAt(0);
    }
  }

  /// Повертає історію змін теми.
  List<ThemeState> get history => List.unmodifiable(_themeHistory);

  /// Повертає на попередню тему, якщо така є в історії.
  ///
  /// Повертає `true`, якщо перехід відбувся успішно.
  bool undo() {
    if (_themeHistory.length < 2) return false;
    _themeHistory.removeLast(); // Видаляємо поточний
    final previous = _themeHistory.last;
    state = previous;
    return true;
  }

  // ─── Режим яскравості ──────────────────────────────────────────────────

  /// Встановлює режим яскравості.
  void setBrightness(ThemeMode mode) {
    // Очищаємо кеш при зміні яскравості
    _themeCache.clear();
    state = state.copyWith(brightness: mode);
    _persistBrightness(mode);
  }

  /// Перемикає між темною та світлою темою.
  ///
  /// Якщо поточний режим — `system`, перемикає на `dark`.
  void toggleDarkLight() {
    final next = state.brightness == ThemeMode.dark
        ? ThemeMode.light
        : ThemeMode.dark;
    setBrightness(next);
  }

  /// Повертає адаптивну тему на основі системних налаштувань.
  ///
  /// Якщо [platformBrightness] не надано, використовує [state.brightness].
  ThemeData getAdaptiveTheme({Brightness? platformBrightness}) {
    if (state.brightness == ThemeMode.system && platformBrightness != null) {
      return platformBrightness == Brightness.dark
          ? Ps5Theme.theme
          : MonitorTheme.theme;
    }
    return state.theme;
  }

  /// Оновлює стан на основі системної яскравості пристрою.
  ///
  /// Викликається при зміні системної теми, якщо [followSystem] увімкнено.
  void updateSystemBrightness(Brightness platformBrightness) {
    if (!state.followSystem) return;
    // Очищаємо кеш для оновлення
    _themeCache.clear();
    final isDark = platformBrightness == Brightness.dark;
    final newMode = isDark ? ThemeMode.dark : ThemeMode.light;
    state = state.copyWith(brightness: newMode);
  }

  /// Повертає ім'я режиму яскравості для серіалізації.
  ///
  /// Використовується для конвертації у Flutter [ThemeMode] у [App].
  String get brightnessName => state.brightness.name;

  /// Встановлює режим слідування за системною темою.
  void setFollowSystem(bool follow) {
    state = state.copyWith(followSystem: follow);
    _persistBool(_keyUseSystem, follow);
  }

  /// Перемикає режим слідування за системною темою.
  void toggleFollowSystem() {
    setFollowSystem(!state.followSystem);
  }

  // ─── Кастомний акцент-колір ────────────────────────────────────────────

  /// Встановлює кастомний колір акценту.
  ///
  /// [color] може бути будь-яким [Color]. Щоб скинути до стандартного,
  /// використовуйте [clearAccentColor].
  void setAccentColor(Color color) {
    final modified = _applyAccentColor(state.theme, color);
    state = state.copyWith(
      theme: modified,
      customAccent: color,
    );
    _persistAccentColor(color);
  }

  /// Скидає кастомний акцент до стандартного палітрового значення.
  void clearAccentColor() {
    final base = _getCachedOrBuild(state.goalType);
    state = state.copyWith(theme: base, clearAccent: true);
    _persistAccentColor(null);
  }

  ThemeData _applyAccentColor(ThemeData base, Color accent) {
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
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return accent;
          return base.colorScheme.onSurface.withOpacity(0.6);
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return accent.withOpacity(0.5);
          }
          return base.colorScheme.onSurface.withOpacity(0.3);
        }),
        trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
        splashRadius: 20,
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: accent,
        thumbColor: accent,
        overlayColor: accent.withOpacity(0.2),
        valueIndicatorColor: accent,
      ),
      tabBarTheme: TabBarTheme(
        indicatorColor: accent,
        labelColor: accent,
      ),
    );
  }

  /// Створює попередньо налаштовану тему з кастомним акцентом.
  ///
  /// Корисно для відображення прев'ю теми у налаштуваннях.
  ThemeData previewWithAccent(Color accent) {
    return _applyAccentColor(state.theme, accent);
  }

  /// Перевіряє, чи вказаний колір близький до поточного акценту.
  bool isAccentCloseTo(Color color, {double threshold = 30.0}) {
    if (state.customAccent == null) return false;
    final current = state.customAccent!;
    final dr = (current.red - color.red).abs();
    final dg = (current.green - color.green).abs();
    final db = (current.blue - color.blue).abs();
    return (dr + dg + db) / 3 < threshold;
  }

  /// Повертає список стандартних акцент-кольорів для вибору.
  static List<Color> get standardAccentColors => const [
        Color(0xFF0070D1), // PS5 Blue
        Color(0xFF00D4FF), // PS5 Cyan
        Color(0xFF7C3AED), // Purple
        Color(0xFF00E676), // Green
        Color(0xFFFF4B6E), // Red/Pink
        Color(0xFFFFB300), // Amber
        Color(0xFFFF9100), // Orange
        Color(0xFF2563EB), // Monitor Blue
        Color(0xFF0891B2), // Teal
        Color(0xFFEC4899), // Pink
      ];

  // ─── Масштаб шрифту ─────────────────────────────────────────────────────

  /// Встановлює масштаб шрифту.
  ///
  /// [scale] має бути в діапазоні 0.8 — 1.5.
  void setFontScale(double scale) {
    final clamped = scale.clamp(0.8, 1.5);
    state = state.copyWith(fontScale: clamped);
    _persistDouble(_keyFontSize, clamped);
  }

  /// Збільшує масштаб шрифту на один крок.
  void increaseFontScale() {
    setFontScale(state.fontScale + 0.1);
  }

  /// Зменшує масштаб шрифту на один крок.
  void decreaseFontScale() {
    setFontScale(state.fontScale - 0.1);
  }

  /// Скидає масштаб шрифту до стандартного (1.0).
  void resetFontScale() {
    setFontScale(1.0);
  }

  /// Повертає відсоток масштабу для UI (наприклад, "125%").
  String get fontScalePercent => '${(state.fontScale * 100).round()}%';

  // ─── Доступність ──────────────────────────────────────────────────────────

  /// Встановлює режим високого контрасту.
  void setHighContrast(bool enabled) {
    state = state.copyWith(highContrast: enabled);
    _persistBool(_keyHighContrast, enabled);
  }

  /// Перемикає режим високого контрасту.
  void toggleHighContrast() {
    setHighContrast(!state.highContrast);
  }

  /// Встановлює режим зменшення руху.
  void setReduceMotion(bool enabled) {
    state = state.copyWith(reduceMotion: enabled);
    _persistBool(_keyReduceMotion, enabled);
  }

  /// Перемикає режим зменшення руху.
  void toggleReduceMotion() {
    setReduceMotion(!state.reduceMotion);
  }

  /// Повертає тему з застосованими оверрайдами доступності.
  ///
  /// Якщо [highContrast] увімкнено, адаптує кольори для кращої видимості.
  ThemeData get accessibilityAwareTheme {
    if (!state.hasAccessibilityOverrides) return state.theme;

    var theme = state.theme;

    if (state.highContrast) {
      // Підсилюємо контраст для accessibility
      theme = theme.copyWith(
        colorScheme: theme.colorScheme.copyWith(
          onSurface: theme.brightness == Brightness.dark
              ? const Color(0xFFFFFFFF)
              : const Color(0xFF000000),
          outline: theme.colorScheme.outline.withOpacity(0.8),
        ),
      );
    }

    if (state.reduceMotion) {
      // Налаштовуємо швидші анімації або відключаємо їх
      theme = theme.copyWith(
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.android: CupertinoPageTransitionsBuilder(),
            TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          },
        ),
      );
    }

    return theme;
  }

  // ─── Пресети тем ─────────────────────────────────────────────────────────

  /// Збережена структура пресету теми.
  static const _presetsStorageKey = 'nexora_theme_presets';

  /// Зберігає поточний стан як пресет з вказаною назвою.
  void savePreset(String name) {
    // TODO: Реалізувати збереження пресету через Hive/SharedPreferences
    debugPrint('📋 ThemeNotifier: пресет "$name" збережено (заглушка)');
  }

  /// Завантажує пресет за назвою та застосовує його.
  ///
  /// Повертає `true`, якщо пресет завантажено успішно.
  Future<bool> loadPreset(String name) async {
    // TODO: Реалізувати завантаження пресету
    debugPrint('📋 ThemeNotifier: завантаження пресету "$name" (заглушка)');
    return false;
  }

  /// Повертає список збережених пресетів.
  Future<List<String>> getSavedPresets() async {
    // TODO: Реалізувати отримання списку пресетів
    return [];
  }

  /// Видаляє пресет за назвою.
  Future<void> deletePreset(String name) async {
    // TODO: Реалізувати видалення пресету
    debugPrint('📋 ThemeNotifier: пресет "$name" видалено (заглушка)');
  }

  // ─── Попередній перегляд ──────────────────────────────────────────────────

  /// Будує віджет для попереднього перегляду теми.
  ///
  /// Повертає [Widget], що відображає мініатюрний прев'ю теми
  /// з урахуванням усіх поточних налаштувань.
  static Widget buildPreview({
    required ThemeData theme,
    required ThemeMode brightness,
    double width = 200,
    double height = 300,
    Color? customAccent,
  }) {
    final effectiveTheme = customAccent != null
        ? ThemeData(
            colorScheme: theme.colorScheme.copyWith(primary: customAccent),
            useMaterial3: theme.useMaterial3,
            brightness: theme.brightness,
            scaffoldBackgroundColor: theme.scaffoldBackgroundColor,
          )
        : theme;

    return SizedBox(
      width: width,
      height: height,
      child: Theme(
        data: effectiveTheme,
        child: Material(
          color: effectiveTheme.scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Заголовок
                Text(
                  brightness == ThemeMode.dark
                      ? 'Темна тема'
                      : 'Світла тема',
                  style: effectiveTheme.textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                // Кнопки
                ElevatedButton(
                  onPressed: () {},
                  child: const Text('Головна кнопка'),
                ),
                const SizedBox(height: 8),
                OutlinedButton(
                  onPressed: () {},
                  child: const Text('Вторинна кнопка'),
                ),
                const SizedBox(height: 8),
                Text(
                  'Зразок тексту для перегляду',
                  style: effectiveTheme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  'Додатковий текст',
                  style: effectiveTheme.textTheme.bodySmall,
                ),
                const Spacer(),
                // Акцент-смужка
                Container(
                  height: 4,
                  decoration: BoxDecoration(
                    color: effectiveTheme.colorScheme.primary,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─── Скидання до стандартних налаштувань ───────────────────────────────

  /// Повертає всі налаштування теми до стандартних значень.
  ///
  /// Тип цілі: PS5, яскравість: темна, акцент: стандартний.
  void resetToDefault({bool animate = false}) {
    setTheme(GoalType.ps5, animate: animate);
    setBrightness(ThemeMode.dark);
    clearAccentColor();
    setFollowSystem(false);
    resetFontScale();
    setHighContrast(false);
    setReduceMotion(false);
  }

  /// Повертає всі налаштування доступності до стандартних значень.
  void resetAccessibility() {
    setHighContrast(false);
    setReduceMotion(false);
    resetFontScale();
  }

  // ─── Кольорова утиліта ────────────────────────────────────────────────────

  /// Генерує колір акценту на основі Hue (від 0 до 360).
  ///
  /// Корисно для повзункового вибору кольору акценту.
  static Color generateAccentFromHue(double hue) {
    return HSLColor.fromAHSL(
      1.0,
      hue.clamp(0, 360),
      0.7,
    ).toColor();
  }

  /// Повертає світлу варіацію кольору акценту.
  static Color lightenAccent(Color color, {double amount = 0.2}) {
    final hsl = HSLColor.fromColor(color);
    return hsl.withLightness(
      (hsl.lightness + amount).clamp(0.0, 1.0),
    ).toColor();
  }

  /// Повертає темну варіацію кольору акценту.
  static Color darkenAccent(Color color, {double amount = 0.2}) {
    final hsl = HSLColor.fromColor(color);
    return hsl.withLightness(
      (hsl.lightness - amount).clamp(0.0, 1.0),
    ).toColor();
  }

  /// Повертає насичену варіацію кольору акценту.
  ///
  /// Збільшує saturation кольору, зберігаючи hue та lightness.
  static Color saturateAccent(Color color, {double amount = 0.2}) {
    final hsl = HSLColor.fromColor(color);
    return hsl.withSaturation(
      (hsl.saturation + amount).clamp(0.0, 1.0),
    ).toColor();
  }

  /// Повертає десатурену (приглушену) варіацію кольору.
  ///
  /// Зменшує saturation кольору для створення м'якших акцентів.
  static Color desaturateAccent(Color color, {double amount = 0.3}) {
    final hsl = HSLColor.fromColor(color);
    return hsl.withSaturation(
      (hsl.saturation - amount).clamp(0.0, 1.0),
    ).toColor();
  }

  /// Генерує колір акценту з відтінками на основі базового Hue.
  ///
  /// Повертає мапу з 5 кольорів від найтемнішого до найсвітлішого.
  static Map<String, Color> generateAccentPalette(double baseHue) {
    return {
      'darkest': HSLColor.fromAHSL(1.0, baseHue.clamp(0, 360), 0.3).toColor(),
      'dark': HSLColor.fromAHSL(1.0, baseHue.clamp(0, 360), 0.45).toColor(),
      'base': HSLColor.fromAHSL(1.0, baseHue.clamp(0, 360), 0.55).toColor(),
      'light': HSLColor.fromAHSL(1.0, baseHue.clamp(0, 360), 0.65).toColor(),
      'lightest': HSLColor.fromAHSL(1.0, baseHue.clamp(0, 360), 0.8).toColor(),
    };
  }

  /// Перевіряє, чи колір має достатній контраст із білим/чорним текстом.
  ///
  /// Використовує співвідношення контрасту WCAG 2.1 (мінімум 4.5:1).
  static bool hasSufficientContrast(Color color, {bool isDarkBg = true}) {
    const darkText = Color(0xFF000000);
    const lightText = Color(0xFFFFFFFF);
    final textColor = isDarkBg ? lightText : darkText;
    final luminance = color.computeLuminance();
    final textLuminance = textColor.computeLuminance();
    final ratio = (luminance + 0.05) / (textLuminance + 0.05);
    return ratio >= 4.5;
  }

  /// Перевіряє, чи колір має достатній контраст для великого тексту (WCAG AA).
  ///
  /// Мінімальне співвідношення: 3.0:1.
  static bool hasLargeTextContrast(Color color, {bool isDarkBg = true}) {
    const darkText = Color(0xFF000000);
    const lightText = Color(0xFFFFFFFF);
    final textColor = isDarkBg ? lightText : darkText;
    final luminance = color.computeLuminance();
    final textLuminance = textColor.computeLuminance();
    final ratio = (luminance + 0.05) / (textLuminance + 0.05);
    return ratio >= 3.0;
  }

  // ─── Кастомне створення тем ──────────────────────────────────────────

  /// Створює кастомну тему на основі існуючої з новою палітрою.
  ///
  /// Корисно для динамічного створення тем на основі брендингу.
  static ThemeData createCustomTheme({
    required ThemeData base,
    required Color primary,
    required Color secondary,
    required Color surface,
    required Color background,
    Color? tertiary,
    Color? error,
    Color? success,
    String? fontFamily,
  }) {
    return base.copyWith(
      colorScheme: base.colorScheme.copyWith(
        primary: primary,
        onPrimary: background,
        secondary: secondary,
        onSecondary: background,
        tertiary: tertiary ?? secondary,
        error: error ?? base.colorScheme.error,
        surface: surface,
        onSurface: background,
      ),
      scaffoldBackgroundColor: background,
      cardTheme: CardThemeData(
        color: surface,
        surfaceTintColor: Colors.transparent,
        elevation: base.cardTheme.elevation,
        shape: base.cardTheme.shape,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: background,
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primary,
        foregroundColor: background,
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(color: primary),
    );
  }

  /// Створює мінімальну «плоску» тему на основі одного кольору.
  ///
  /// Корисно для спрощених тестових UI та модальних вікон.
  static ThemeData createMonoTheme({
    required Color accent,
    bool isDark = true,
  }) {
    final bg = isDark ? const Color(0xFF121212) : const Color(0xFFFAFAFA);
    final fg = isDark ? const Color(0xFFE0E0E0) : const Color(0xFF212121);
    return ThemeData(
      useMaterial3: true,
      brightness: isDark ? Brightness.dark : Brightness.light,
      colorScheme: ColorScheme(
        primary: accent,
        onPrimary: fg,
        surface: bg,
        onSurface: fg,
        brightness: isDark ? Brightness.dark : Brightness.light,
      ),
      scaffoldBackgroundColor: bg,
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accent,
          foregroundColor: fg,
        ),
      ),
      textTheme: TextTheme(
        bodyLarge: TextStyle(color: fg, fontSize: 16),
        bodyMedium: TextStyle(color: fg, fontSize: 14),
      ),
    );
  }

  // ─── Пакетні операції ────────────────────────────────────────────────

  /// Перемикає між PS5 та Monitor темою з анімацією.
  ///
  /// Зручний метод для швидкого перемикання стилів додатку.
  void toggleThemeGoal({bool animate = true}) {
    final nextType = state.goalType == GoalType.ps5
        ? GoalType.monitor
        : GoalType.ps5;
    setTheme(nextType, animate: animate);

    // Автоматично встановлюємо відповідний режим яскравості
    final nextBrightness = nextType == GoalType.ps5
        ? ThemeMode.dark
        : ThemeMode.light;
    setBrightness(nextBrightness);
  }

  /// Застосовує кілька налаштувань одночасно.
  ///
  /// Корисно для імпорту пресетів або відновлення налаштувань.
  void applySettings({
    GoalType? goalType,
    ThemeMode? brightness,
    Color? accentColor,
    bool? clearAccent,
    double? fontScale,
    bool? followSystem,
    bool? highContrast,
    bool? reduceMotion,
    bool animate = false,
  }) {
    if (goalType != null) setTheme(goalType, animate: animate);
    if (brightness != null) setBrightness(brightness);
    if (clearAccent == true) {
      clearAccentColor();
    } else if (accentColor != null) {
      setAccentColor(accentColor);
    }
    if (fontScale != null) setFontScale(fontScale);
    if (followSystem != null) setFollowSystem(followSystem);
    if (highContrast != null) setHighContrast(highContrast);
    if (reduceMotion != null) setReduceMotion(reduceMotion);
  }

  /// Повертає серіалізовану карту всіх поточних налаштувань.
  ///
  /// Корисно для експорту пресетів або діагностики.
  Map<String, dynamic> exportSettings() {
    return {
      'goalType': state.goalType.index,
      'brightness': state.brightness.index,
      'accentColor': state.customAccent?.value,
      'fontScale': state.fontScale,
      'followSystem': state.followSystem,
      'highContrast': state.highContrast,
      'reduceMotion': state.reduceMotion,
    };
  }

  /// Відновлює налаштування з серіалізованої карти.
  ///
  /// Повертає `true`, якщо хоча б одне значення було оновлено.
  bool importSettings(Map<String, dynamic> settings) {
    var changed = false;

    if (settings.containsKey('goalType')) {
      final index = settings['goalType'] as int?;
      if (index != null && index < GoalType.values.length) {
        setTheme(GoalType.values[index]);
        changed = true;
      }
    }

    if (settings.containsKey('brightness')) {
      final index = settings['brightness'] as int?;
      if (index != null && index < ThemeMode.values.length) {
        setBrightness(ThemeMode.values[index]);
        changed = true;
      }
    }

    if (settings.containsKey('accentColor')) {
      final value = settings['accentColor'] as int?;
      if (value != null) {
        setAccentColor(Color(value));
        changed = true;
      }
    }

    if (settings.containsKey('fontScale')) {
      setFontScale((settings['fontScale'] as num?)?.toDouble() ?? 1.0);
      changed = true;
    }

    if (settings.containsKey('followSystem')) {
      setFollowSystem(settings['followSystem'] as bool? ?? false);
      changed = true;
    }

    if (settings.containsKey('highContrast')) {
      setHighContrast(settings['highContrast'] as bool? ?? false);
      changed = true;
    }

    if (settings.containsKey('reduceMotion')) {
      setReduceMotion(settings['reduceMotion'] as bool? ?? false);
      changed = true;
    }

    return changed;
  }

  /// Повертає діагностичний звіт про поточний стан кешу тем.
  ///
  /// Корисно для налагодження проблем з продуктивністю.
  String get cacheReport {
    return '📋 ThemeCache: ${_themeCache.length} записів\n'
        '📋 Історія: ${_themeHistory.length} записів\n'
        '📋 Перехід: ${_transitionConfig.duration.inMilliseconds}мс';
  }

  /// Очищає кеш тем.
  ///
  /// Використовуйте при оновленні даних теми або для тестування.
  void clearCache() {
    _themeCache.clear();
    debugPrint('📋 ThemeNotifier: кеш очищено');
  }

  /// Очищає історію змін тем.
  void clearHistory() {
    _themeHistory.clear();
    debugPrint('📋 ThemeNotifier: історія очищена');
  }

  /// Повертає кількість доступних пресетів теми.
  ///
  /// Включає вбудовані пресети + користувацькі.
  int get availablePresetCount => 3; // PS5, Monitor, Системна

  /// Українська назва типу цілі для UI.
  static String goalTypeName(GoalType type) {
    switch (type) {
      case GoalType.ps5:
        return 'Геймінг (PS5)';
      case GoalType.monitor:
        return 'Продуктивність (Monitor)';
      case GoalType.custom:
        return 'Власна тема';
    }
  }

  /// Українська назва режиму яскравості для UI.
  static String brightnessModeName(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.dark:
        return 'Темна';
      case ThemeMode.light:
        return 'Світла';
      case ThemeMode.system:
        return 'Системна';
    }
  }

  /// Створює розширений прев'ю з додатковими компонентами.
  static Widget buildExtendedPreview({
    required ThemeData theme,
    required ThemeMode brightness,
    double width = 220,
    double height = 360,
    Color? customAccent,
    double fontScale = 1.0,
  }) {
    final effectiveTheme = customAccent != null
        ? ThemeData(
            colorScheme: theme.colorScheme.copyWith(primary: customAccent),
            useMaterial3: theme.useMaterial3,
            brightness: theme.brightness,
            scaffoldBackgroundColor: theme.scaffoldBackgroundColor,
          )
        : theme;

    final textTheme = effectiveTheme.textTheme;

    return SizedBox(
      width: width,
      height: height,
      child: Theme(
        data: effectiveTheme,
        child: Material(
          color: effectiveTheme.scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(16),
          clipBehavior: Clip.antiAlias,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Заголовок
                Text(
                  brightness == ThemeMode.dark
                      ? 'Темна тема'
                      : 'Світла тема',
                  style: textTheme.titleMedium,
                ),
                const SizedBox(height: 6),
                Text(
                  'Масштаб тексту: ${(fontScale * 100).round()}%',
                  style: textTheme.bodySmall,
                ),
                const SizedBox(height: 10),
                // Головна кнопка
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {},
                    child: const Text('Основна дія'),
                  ),
                ),
                const SizedBox(height: 6),
                // Вторинна кнопка
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {},
                    child: const Text('Скасувати'),
                  ),
                ),
                const SizedBox(height: 6),
                // Рядок переключачів
                Row(
                  children: [
                    Expanded(
                      child: Switch(
                        value: true,
                        onChanged: (_) {},
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text('Увімкнено', style: textTheme.bodySmall),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Прогрес-бар
                LinearProgressIndicator(
                  value: 0.65,
                  backgroundColor:
                      effectiveTheme.colorScheme.surfaceContainerHighest,
                ),
                const SizedBox(height: 4),
                Text(
                  'Прогрес: 65%',
                  style: textTheme.labelSmall,
                ),
                const Spacer(),
                // Колірна палістра
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: effectiveTheme.colorScheme.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                    Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: effectiveTheme.colorScheme.secondary,
                        shape: BoxShape.circle,
                      ),
                    ),
                    Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: effectiveTheme.colorScheme.tertiary,
                        shape: BoxShape.circle,
                      ),
                    ),
                    Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: effectiveTheme.colorScheme.error,
                        shape: BoxShape.circle,
                      ),
                    ),
                    Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: effectiveTheme.colorScheme.surface,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─── Збереження та відновлення ────────────────────────────────────────

  /// Завантажує збережені налаштування теми.
  ///
  /// Викликається під час ініціалізації додатку.
  /// Для реалізації використовуйте Hive або SharedPreferences.
  ///
  /// Структура збереження:
  /// - `_keyGoalType` → `int` (індекс GoalType)
  /// - `_keyBrightness` → `int` (індекс ThemeMode)
  /// - `_keyAccentColor` → `int` (ARGB значення кольору)
  Future<void> loadSavedPreferences() async {
    // TODO: Реалізувати завантаження через Hive / SharedPreferences
    // final box = await Hive.openBox('theme_settings');
    //
    // final goalIndex = box.get(_keyGoalType) as int?;
    // if (goalIndex != null && goalIndex < GoalType.values.length) {
    //   final savedGoal = GoalType.values[goalIndex];
    //   final theme = _buildThemeForGoalType(savedGoal);
    //   state = state.copyWith(goalType: savedGoal, theme: theme);
    // }
    //
    // final brightnessIndex = box.get(_keyBrightness) as int?;
    // if (brightnessIndex != null && brightnessIndex < ThemeMode.values.length) {
    //   state = state.copyWith(
    //     brightness: ThemeMode.values[brightnessIndex],
    //   );
    // }
    //
    // final accentValue = box.get(_keyAccentColor) as int?;
    // if (accentValue != null) {
    //   final accent = Color(accentValue);
    //   final modified = _applyAccentColor(state.theme, accent);
    //   state = state.copyWith(theme: modified, customAccent: accent);
    // }
    debugPrint('📋 ThemeNotifier: завантаження налаштувань (заглушка)');
  }

  /// Зберігає тип цілі.
  Future<void> _persistGoalType(GoalType type) async {
    // TODO: await Hive.box('theme_settings').put(_keyGoalType, type.index);
  }

  /// Зберігає режим яскравості.
  Future<void> _persistBrightness(ThemeMode mode) async {
    // TODO: await Hive.box('theme_settings').put(_keyBrightness, mode.index);
  }

  /// Зберігає кастомний акцент-колір.
  Future<void> _persistAccentColor(Color? color) async {
    // TODO: final box = await Hive.box('theme_settings');
    // if (color != null) {
    //   await box.put(_keyAccentColor, color.value);
    // } else {
    //   await box.delete(_keyAccentColor);
    // }
  }

  /// Зберігає булеве значення.
  Future<void> _persistBool(String key, bool value) async {
    // TODO: await Hive.box('theme_settings').put(key, value);
    debugPrint('📋 ThemeNotifier: збереження $key = $value (заглушка)');
  }

  /// Зберігає числове значення.
  Future<void> _persistDouble(String key, double value) async {
    // TODO: await Hive.box('theme_settings').put(key, value);
    debugPrint('📋 ThemeNotifier: збереження $key = $value (заглушка)');
  }
}

// ─── Провайдери ─────────────────────────────────────────────────────────────

/// Riverpod провайдер для стану теми.
final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeState>(
  (ref) => ThemeNotifier(),
);

/// Провайдер, що спостерігає за темною/світлою темою.
final isDarkProvider = Provider<bool>((ref) {
  return ref.watch(themeProvider).isDark;
});

/// Провайдер, що повертає ім'я поточного режиму яскравості.
///
/// Використовується в [App] для конвертації у Flutter ThemeMode.
final brightnessNameProvider = Provider<String>((ref) {
  return ref.watch(themeProvider.select((s) => s.brightness.name));
});

/// Провайдер, що повертає поточний тип цілі.
final goalTypeProvider = Provider<GoalType>((ref) {
  return ref.watch(themeProvider.select((s) => s.goalType));
});

/// Провайдер, що повертає поточний масштаб шрифту.
final fontScaleProvider = Provider<double>((ref) {
  return ref.watch(themeProvider.select((s) => s.fontScale));
});

/// Провайдер, що повертає тему з урахуванням доступності.
final accessibilityThemeProvider = Provider<ThemeData>((ref) {
  return ref.watch(themeProvider.select((s) => s.accessibilityAwareTheme));
});

/// Провайдер, що повертає конфігурацію переходу теми.
final transitionConfigProvider = Provider<ThemeTransitionConfig>((ref) {
  return ref.watch(themeProvider.notifier).transitionConfig;
});

/// Провайдер, що спостерігає за режимом високого контрасту.
final highContrastProvider = Provider<bool>((ref) {
  return ref.watch(themeProvider.select((s) => s.highContrast));
});

/// Провайдер, що спостерігає за режимом зменшення руху.
final reduceMotionProvider = Provider<bool>((ref) {
  return ref.watch(themeProvider.select((s) => s.reduceMotion));
});

/// Провайдер, що спостерігає за режимом слідування за системною темою.
final followSystemProvider = Provider<bool>((ref) {
  return ref.watch(themeProvider.select((s) => s.followSystem));
});

/// Провайдер, що повертає список стандартних акцент-кольорів.
final standardAccentsProvider = Provider<List<Color>>((ref) {
  return ThemeNotifier.standardAccentColors;
});

/// Провайдер, що повертає назву поточної цілі українською.
final goalTypeNameProvider = Provider<String>((ref) {
  return ThemeNotifier.goalTypeName(ref.watch(goalTypeProvider));
});

/// Провайдер, що повертає назву режиму яскравості українською.
final brightnessModeNameProvider = Provider<String>((ref) {
  final name = ref.watch(brightnessNameProvider);
  final mode = ThemeMode.values.firstWhere(
    (m) => m.name == name,
    orElse: () => ThemeMode.dark,
  );
  return ThemeNotifier.brightnessModeName(mode);
});

/// Провайдер, що спостерігає за кастомним акцентом.
final hasCustomAccentProvider = Provider<bool>((ref) {
  return ref.watch(themeProvider.select((s) => s.customAccent != null));
});

/// Провайдер, що повертає HEX-значення кастомного акценту (або null).
final accentHexProvider = Provider<String?>((ref) {
  final color = ref.watch(themeProvider.select((s) => s.customAccent));
  if (color == null) return null;
  return '#${color.value.toRadixString(16).padLeft(8, '0')}';
});

/// Провайдер, що повертає повну інформацію про стан для діагностики.
final themeDebugInfoProvider = Provider<String>((ref) {
  final state = ref.watch(themeProvider);
  return '${ThemeNotifier.goalTypeName(state.goalType)} · '
      '${ThemeNotifier.brightnessModeName(state.brightness)} · '
      'Масштаб: ${(state.fontScale * 100).round()}%';
});

/// Провайдер, що повертає мапу кольорів палітри для прев'ю.
final accentPaletteProvider = Provider<Map<String, Color>>((ref) {
  final state = ref.watch(themeProvider);
  final hue = state.customAccent != null
      ? HSLColor.fromColor(state.customAccent!).hue
      : 210.0;
  return ThemeNotifier.generateAccentPalette(hue);
});
