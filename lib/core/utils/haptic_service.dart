import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Унікальні патерни тактильного зворотного зв'язку.
///
/// Кожен патерн відповідає певній події у гейміфікованому
/// фінансовому трекері Nexora.
enum HapticPattern {
  /// Легке натискання кнопки.
  light,

  /// Середнє підтвердження дії.
  medium,

  /// Сильне натискання — важливі події.
  heavy,

  /// Вибір елемента (toggle, tabs).
  selection,

  /// Успішна дія або досягнення.
  success,

  /// Помилка або невдала спроба.
  error,

  /// Додавання монет у скарбничку.
  coinDrop,

  /// Підвищення рівня — сходовий патерн.
  levelUp,

  /// Розблокування бейджу — потрійний імпульс.
  badgeUnlock,

  /// Активна серія — наростаючий патерн.
  streakFire,

  /// Заморожування серії — тріщина льоду.
  frostCrack,

  /// Конфетті — швидкі черги імпульсів.
  confetti,

  /// Перемикач — дуже легкий клік.
  switchToggle,

  /// Потягни для оновлення — середня вібрація.
  pullToRefresh,

  /// Видалення свайпом — легкий зворотний зв'язок.
  deleteSwipe,

  /// Розтягування картки — легка вібрація.
  cardStretch,

  /// Досягнення цілі — святковий патерн.
  goalAchieved,

  /// Попередження — подвійний легкий імпульс.
  warning,

  /// Інформаційне повідомлення — одиночний легкий клік.
  info,

  /// Скасування дії — коротка легка вібрація.
  cancel,

  /// Переміщення елемента (drag) — мінімальний відгук.
  dragStart,

  /// Кидання елемента (drop) — середній відгук.
  dropComplete,

  /// Набір тексту на клавіатурі — дуже делікатний.
  keystroke,

  /// Довге натискання (long press) — наростаючий імпульс.
  longPress,

  /// Двічі натиснути (double tap) — подвійний клік.
  doubleTap,

  /// Скасування дії (undo) — два легкі імпульси.
  undo,

  /// Підтвердження видалення — сильний імпульс.
  deleteConfirm,

  /// Завершення онбордингу — святковий патерн.
  onboardingComplete,

  /// Розблокування функції — три швидких імпульси.
  featureUnlock,
}

/// Рівень інтенсивності вібрації.
///
/// Використовується для адаптивної настройки тактильного зворотного зв'язку
/// залежно від вподобань користувача та типу події.
enum HapticIntensity {
  /// Дуже легка інтенсивність (мінімальна, для делікатних подій).
  subtle,

  /// Легка інтенсивність (мінімальна).
  light,

  /// Середня інтенсивність (стандартна).
  medium,

  /// Сильна інтенсивність (максимальна).
  heavy,

  /// Екстремальна інтенсивність (для особливих подій).
  extreme,
}

/// Інформація про можливості пристрою щодо вібрації.
///
/// Визначається під час ініціалізації сервісу.
/// Містить прапорці для перевірки підтримки розширених ефектів,
/// кастомних вібрацій та контролю амплітуди.
class DeviceHapticCapabilities {
  /// Створює інформацію про можливості пристрою.
  ///
  /// Всі параметри за замовчуванням встановлені у `false` або `0`.
  const DeviceHapticCapabilities({
    this.supportsHaptics = false,
    this.supportsAdvancedHaptics = false,
    this.supportsCustomVibration = false,
    this.hasAmplitudeControl = false,
    this.hasVibrator = false,
    this.maxAmplitude = 255,
  });

  /// Чи підтримує пристрій базову вібрацію.
  final bool supportsHaptics;

  /// Чи підтримує пристрій розширені haptic-ефекти (AHV).
  final bool supportsAdvancedHaptics;

  /// Чи підтримує кастомні послідовності вібрації.
  final bool supportsCustomVibration;

  /// Чи має пристрій контроль амплітуди вібрації.
  final bool hasAmplitudeControl;

  /// Чи має пристрій вібромотор.
  final bool hasVibrator;

  /// Максимальна амплітуда вібрації (0–255).
  final int maxAmplitude;

  /// Повертає опис можливостей пристрою українською.
  ///
  /// Перелічує підтримувані функції через кому.
  String get description {
    if (!supportsHaptics) return 'Вібрація не підтримується';
    final parts = <String>[];
    if (supportsAdvancedHaptics) parts.add('розширені ефекти');
    if (hasAmplitudeControl) parts.add('контроль амплітуди');
    if (supportsCustomVibration) parts.add('кастомні послідовності');
    if (parts.isEmpty) parts.add('базова вібрація');
    return 'Підтримується: ${parts.join(', ')}';
  }

  /// Повертає опис можливостей англійською.
  String get descriptionEN {
    if (!supportsHaptics) return 'Haptics not supported';
    final parts = <String>[];
    if (supportsAdvancedHaptics) parts.add('advanced effects');
    if (hasAmplitudeControl) parts.add('amplitude control');
    if (supportsCustomVibration) parts.add('custom vibration');
    if (parts.isEmpty) parts.add('basic haptics');
    return 'Supported: ${parts.join(', ')}';
  }

  /// Перетворює об'єкт у мапу для серіалізації.
  Map<String, dynamic> toMap() => {
        'supportsHaptics': supportsHaptics,
        'supportsAdvancedHaptics': supportsAdvancedHaptics,
        'supportsCustomVibration': supportsCustomVibration,
        'hasAmplitudeControl': hasAmplitudeControl,
        'hasVibrator': hasVibrator,
        'maxAmplitude': maxAmplitude,
      };

  /// Відновлює об'єкт з мапи.
  factory DeviceHapticCapabilities.fromMap(Map<String, dynamic> map) =>
      DeviceHapticCapabilities(
        supportsHaptics: map['supportsHaptics'] as bool? ?? false,
        supportsAdvancedHaptics: map['supportsAdvancedHaptics'] as bool? ?? false,
        supportsCustomVibration: map['supportsCustomVibration'] as bool? ?? false,
        hasAmplitudeControl: map['hasAmplitudeControl'] as bool? ?? false,
        hasVibrator: map['hasVibrator'] as bool? ?? false,
        maxAmplitude: map['maxAmplitude'] as int? ?? 255,
      );

  @override
  String toString() => description;
}

/// Крок часової лінії тактильного ефекту.
///
/// Використовується в [HapticService.buildTimeline] для складних патернів.
/// Кожен крок має свою інтенсивність, тривалість та опціональну паузу.
class HapticTimelineStep {
  /// Створює крок часової лінії.
  ///
  /// [intensity] — інтенсивність кроку.
  /// [duration] — тривалість вібрації.
  /// [pauseAfter] — пауза після кроку (за замовчуванням Duration.zero).
  const HapticTimelineStep({
    required this.intensity,
    required this.duration,
    this.pauseAfter = Duration.zero,
  });

  /// Інтенсивність кроку.
  final HapticIntensity intensity;

  /// Тривалість вібрації в цьому кроці.
  final Duration duration;

  /// Пауза після цього кроку.
  final Duration pauseAfter;

  /// Перетворює крок у мапу для серіалізації.
  Map<String, dynamic> toMap() => {
        'intensity': intensity.index,
        'durationMs': duration.inMilliseconds,
        'pauseAfterMs': pauseAfter.inMilliseconds,
      };

  @override
  String toString() =>
      'HapticTimelineStep(${intensity.name}, ${duration.inMilliseconds}ms, pause: ${pauseAfter.inMilliseconds}ms)';
}

/// Запис про виконаний тактильний патерн (для логування).
///
/// Використовується в [HapticService] для відстеження історії вібрацій
/// та аналізу використання тактильного зворотного зв'язку.
class HapticLogEntry {
  /// Створює запис про виконаний патерн.
  ///
  /// [pattern] — тип патерну.
  /// [timestamp] — час виконання.
  /// [duration] — тривалість патерну.
  /// [intensity] — рівень інтенсивності під час виконання.
  HapticLogEntry({
    required this.pattern,
    required this.timestamp,
    this.duration = Duration.zero,
    this.intensity = HapticIntensity.medium,
    this.tag,
    this.metadata,
  });

  /// Тип виконаного патерну.
  final HapticPattern pattern;

  /// Час виконання патерну.
  final DateTime timestamp;

  /// Тривалість виконання патерну.
  final Duration duration;

  /// Рівень інтенсивності під час виконання.
  final HapticIntensity intensity;

  /// Опціональний тег для фільтрації записів.
  final String? tag;

  /// Опціональні метадані, що описують контекст виклику.
  final Map<String, dynamic>? metadata;

  /// Перетворює запис у мапу для серіалізації.
  Map<String, dynamic> toMap() => {
        'pattern': pattern.name,
        'timestamp': timestamp.toIso8601String(),
        'durationMs': duration.inMilliseconds,
        'intensity': intensity.name,
        if (tag != null) 'tag': tag,
        if (metadata != null) 'metadata': metadata,
      };

  @override
  String toString() =>
      '[${timestamp.toIso8601String()}] ${pattern.name} '
      '(${duration.inMilliseconds}ms, ${intensity.name}'
      '${tag != null ? ', tag: $tag' : ''})';
}

/// Конфігурація інтенсивності для конкретної події.
///
/// Дозволяє встановлювати кастомний поріг інтенсивності
/// та кількість імпульсів для кожного патерну окремо.
class HapticIntensityConfig {
  /// Створює конфігурацію інтенсивності.
  const HapticIntensityConfig({
    this.minIntensity = HapticIntensity.subtle,
    this.impulseMultiplier = 1.0,
    this.pauseMultiplier = 1.0,
    this.enabled = true,
    this.customPattern,
    this.maxRepetitions = 3,
    this.tag,
  });

  /// Мінімальна інтенсивність для виконання патерну.
  final HapticIntensity minIntensity;

  /// Множник кількості імпульсів (0.5–2.0).
  final double impulseMultiplier;

  /// Множник пауз між імпульсами (0.5–2.0).
  final double pauseMultiplier;

  /// Чи увімкнений цей патерн.
  final bool enabled;

  /// Кастомна заміна стандартного патерну.
  final Future<void> Function()? customPattern;

  /// Максимальна кількість повторень (для repeated patterns).
  final int maxRepetitions;

  /// Тег для фільтрації в журналі.
  final String? tag;

  /// Створює копію з перевизначеними параметрами.
  HapticIntensityConfig copyWith({
    HapticIntensity? minIntensity,
    double? impulseMultiplier,
    double? pauseMultiplier,
    bool? enabled,
    Future<void> Function()? customPattern,
    int? maxRepetitions,
    String? tag,
  }) {
    return HapticIntensityConfig(
      minIntensity: minIntensity ?? this.minIntensity,
      impulseMultiplier: (impulseMultiplier ?? this.impulseMultiplier)
          .clamp(0.5, 2.0),
      pauseMultiplier:
          (pauseMultiplier ?? this.pauseMultiplier).clamp(0.5, 2.0),
      enabled: enabled ?? this.enabled,
      customPattern: customPattern ?? this.customPattern,
      maxRepetitions: (maxRepetitions ?? this.maxRepetitions).clamp(1, 10),
      tag: tag ?? this.tag,
    );
  }

  /// Перетворює конфігурацію у мапу.
  Map<String, dynamic> toMap() => {
        'minIntensity': minIntensity.name,
        'impulseMultiplier': impulseMultiplier,
        'pauseMultiplier': pauseMultiplier,
        'enabled': enabled,
        'maxRepetitions': maxRepetitions,
        if (tag != null) 'tag': tag,
      };

  /// Відновлює конфігурацію з мапи.
  factory HapticIntensityConfig.fromMap(Map<String, dynamic> map) {
    return HapticIntensityConfig(
      minIntensity: HapticIntensity.values.firstWhere(
        (i) => i.name == map['minIntensity'],
        orElse: () => HapticIntensity.subtle,
      ),
      impulseMultiplier: (map['impulseMultiplier'] as num?)?.toDouble() ?? 1.0,
      pauseMultiplier: (map['pauseMultiplier'] as num?)?.toDouble() ?? 1.0,
      enabled: map['enabled'] as bool? ?? true,
      maxRepetitions: map['maxRepetitions'] as int? ?? 3,
      tag: map['tag'] as String?,
    );
  }

  @override
  String toString() =>
      'HapticIntensityConfig(min: ${minIntensity.name}, '
      'impulses: ${impulseMultiplier.toStringAsFixed(1)}x, '
      'pauses: ${pauseMultiplier.toStringAsFixed(1)}x, '
      'enabled: $enabled)';
}

/// Оператор пакетного виконання тактильних патернів.
///
/// Дозволяє групувати кілька патернів з власними параметрами
/// та виконувати їх як єдину операцію.
class HapticBatch {
  /// Створює пакетний оператор.
  ///
  /// [name] — назва пакету для ідентифікації в журналі.
  /// [steps] — кроки пакету.
  HapticBatch({
    required this.name,
    required this.steps,
    this.parallel = false,
    this.tag,
  });

  /// Назва пакету.
  final String name;

  /// Кроки пакету.
  final List<HapticBatchStep> steps;

  /// Чи виконувати кроки паралельно (накладаються).
  final bool parallel;

  /// Тег для фільтрації.
  final String? tag;

  /// Перетворює пакет у мапу.
  Map<String, dynamic> toMap() => {
        'name': name,
        'steps': steps.map((s) => s.toMap()).toList(),
        'parallel': parallel,
        if (tag != null) 'tag': tag,
      };

  @override
  String toString() =>
      'HapticBatch($name, ${steps.length} steps, parallel: $parallel)';
}

/// Крок пакетного виконання.
class HapticBatchStep {
  /// Створює крок пакету.
  const HapticBatchStep({
    required this.pattern,
    this.delayBefore = Duration.zero,
    this.delayAfter = Duration.zero,
    this.condition = true,
    this.tag,
  });

  /// Патерн для виконання.
  final HapticPattern pattern;

  /// Затримка перед виконанням.
  final Duration delayBefore;

  /// Затримка після виконання.
  final Duration delayAfter;

  /// Умова виконання кроку.
  final bool condition;

  /// Опціональний тег.
  final String? tag;

  /// Перетворює крок у мапу.
  Map<String, dynamic> toMap() => {
        'pattern': pattern.name,
        'delayBeforeMs': delayBefore.inMilliseconds,
        'delayAfterMs': delayAfter.inMilliseconds,
        'condition': condition,
        if (tag != null) 'tag': tag,
      };
}

/// Внутрішній клас для запланованих тактильних патернів.
class _ScheduledHaptic {
  final HapticPattern pattern;
  final DateTime executeAt;
  final String id;
  final bool recurring;
  final Duration? recurringInterval;

  const _ScheduledHaptic({
    required this.pattern,
    required this.executeAt,
    required this.id,
    this.recurring = false,
    this.recurringInterval,
  });
}

/// Сервіс тактильного зворотного зв'язку (haptic feedback).
///
/// Надає статичні методи для різних типів вібрації,
/// що відповідають UX-подіям у додатку Nexora.
///
/// Може бути увімкнений/вимкнений користувачем через [enable]/[disable]/[toggle].
/// Підтримує розширене визначення можливостей пристрою,
/// кастомні послідовності, часові лінії, адаптивні патерни
/// та доступність.
///
/// Приклад ініціалізації:
/// ```dart
/// void main() async {
///   await HapticService.init();
///   // ....initializeApp(...)
/// }
/// ```
///
/// Приклад використання:
/// ```dart
/// HapticService.lightTap();     // Легке натискання
/// HapticService.coinDrop();      // Крапля монети
/// HapticService.trigger(HapticPattern.levelUp);  // Підвищення рівня
/// ```
class HapticService {
  HapticService._();

  // ─── Стан сервісу ──────────────────────────────────────────────────

  /// Чи увімкнено тактильний зворотний зв'язок.
  static bool _enabled = true;

  /// Чи підтримує платформа вібрацію.
  static bool _platformSupported = true;

  /// Поточний рівень інтенсивності.
  static HapticIntensity _intensity = HapticIntensity.medium;

  /// Режим зменшення руху (для доступності).
  static bool _reduceMotion = false;

  /// Інформація про можливості пристрою.
  static DeviceHapticCapabilities _capabilities =
      const DeviceHapticCapabilities();

  /// Історія виконаних патернів (для логування).
  static final List<HapticLogEntry> _log = [];

  /// Максимальний розмір журналу (для пам'яті).
  static const int _maxLogSize = 100;

  /// Кількість виконаних патернів за всю сесію.
  static int _totalTriggers = 0;

  /// Чи зараз виконується вібрація (для запобігання накладання).
  static bool _isTriggering = false;

  /// Лічильник послідовних викликів (для debounce).
  static int _rapidCallCount = 0;

  /// Час останнього виклику (для rate limiting).
  static DateTime? _lastTriggerTime;

  /// Мінімальний інтервал між вібраціями (для захисту від спаму).
  static const Duration _minInterval = Duration(milliseconds: 30);

  /// Максимальна кількість швидких викликів перед блокуванням.
  static const int _maxRapidCalls = 5;

  /// Режим енергозбереження.
  static bool _batterySaverMode = false;

  /// Кастомні конфігурації для патернів.
  static final Map<HapticPattern, HapticIntensityConfig> _patternConfigs = {};

  /// Глобальний множник інтенсивності.
  static double _globalIntensityMultiplier = 1.0;

  /// Планувальник відкладених патернів.
  static final List<_ScheduledHaptic> _scheduledQueue = [];

  /// Таймер для обробки запланованих патернів.
  static Timer? _schedulerTimer;

  /// Поточний debounce-таймер.
  static Timer? _debounceTimer;

  /// Глобальний тег для фільтрації записів.
  static String? _globalTag;

  /// Категорії патернів для аналітики.
  static const Map<String, List<HapticPattern>> _patternCategories = {
    'basic': [
      HapticPattern.light,
      HapticPattern.medium,
      HapticPattern.heavy,
      HapticPattern.selection,
    ],
    'gamification': [
      HapticPattern.coinDrop,
      HapticPattern.levelUp,
      HapticPattern.badgeUnlock,
      HapticPattern.streakFire,
      HapticPattern.frostCrack,
      HapticPattern.confetti,
      HapticPattern.goalAchieved,
    ],
    'navigation': [
      HapticPattern.switchToggle,
      HapticPattern.pullToRefresh,
      HapticPattern.deleteSwipe,
      HapticPattern.cardStretch,
      HapticPattern.dragStart,
      HapticPattern.dropComplete,
    ],
    'feedback': [
      HapticPattern.success,
      HapticPattern.error,
      HapticPattern.warning,
      HapticPattern.info,
      HapticPattern.cancel,
    ],
    'interaction': [
      HapticPattern.keystroke,
      HapticPattern.longPress,
      HapticPattern.doubleTap,
      HapticPattern.undo,
      HapticPattern.deleteConfirm,
    ],
    'milestones': [
      HapticPattern.onboardingComplete,
      HapticPattern.featureUnlock,
    ],
  };

  /// Попередньо визначені профілі налаштувань.
  static const Map<String, HapticIntensity> _intensityProfiles = {
    'minimal': HapticIntensity.subtle,
    'balanced': HapticIntensity.light,
    'default': HapticIntensity.medium,
    'enhanced': HapticIntensity.heavy,
    'max': HapticIntensity.extreme,
  };

  // ─── Ініціалізація ──────────────────────────────────────────────────

  /// Ініціалізує сервіс та перевіряє підтримку платформи.
  ///
  /// Повинен викликатися під час запуску додатку.
  /// Визначає можливості пристрою (базова вібрація, розширені ефекти,
  /// кастомні послідовності).
  ///
  /// Повертає `true`, якщо платформа підтримує вібрацію.
  static Future<bool> init() async {
    try {
      if (kIsWeb) {
        _platformSupported = false;
        _capabilities = const DeviceHapticCapabilities();
        return false;
      } else {
        await HapticFeedback.lightImpact();
        _platformSupported = true;
        _capabilities = const DeviceHapticCapabilities(
          supportsHaptics: true,
          supportsAdvancedHaptics: true,
          supportsCustomVibration: true,
          hasAmplitudeControl: true,
          hasVibrator: true,
        );
        return true;
      }
    } catch (_) {
      _platformSupported = false;
      _capabilities = const DeviceHapticCapabilities();
      return false;
    }
  }

  /// Запускає планувальник відкладених патернів.
  ///
  /// [interval] — інтервал перевірки черги (за замовчуванням 1 секунда).
  static void startScheduler({Duration interval = const Duration(seconds: 1)}) {
    _schedulerTimer?.cancel();
    _schedulerTimer = Timer.periodic(interval, (_) {
      processScheduledHaptics();
    });
    debugPrint('[HapticService] Scheduler started (interval: ${interval.inSeconds}s)');
  }

  /// Зупиняє планувальник відкладених патернів.
  static void stopScheduler() {
    _schedulerTimer?.cancel();
    _schedulerTimer = null;
    debugPrint('[HapticService] Scheduler stopped');
  }

  /// Звільняє ресурси сервісу (викликати при завершенні).
  static void dispose() {
    stopScheduler();
    _debounceTimer?.cancel();
    _debounceTimer = null;
    cancelAllScheduled();
    debugPrint('[HapticService] Disposed');
  }

  // ─── Гетери стану сервісу ──────────────────────────────────────────

  /// Чи увімкнений тактильний зворотний зв'язок.
  ///
  /// Повертає `true`, якщо: сервіс увімкнений, платформа підтримує вібрацію,
  /// та режим зменшення руху вимкнено.
  static bool get isEnabled =>
      _enabled && _platformSupported && !_reduceMotion;

  /// Чи підтримується вібрація на цій платформі.
  static bool get isPlatformSupported => _platformSupported;

  /// Поточний рівень інтенсивності.
  static HapticIntensity get intensity => _intensity;

  /// Інформація про можливості пристрою.
  static DeviceHapticCapabilities get capabilities => _capabilities;

  /// Загальна кількість виконаних патернів за сесію.
  static int get totalTriggers => _totalTriggers;

  /// Чи зараз виконується вібраційний патерн.
  static bool get isTriggering => _isTriggering;

  /// Останні записи журналу (найновіші перші).
  static List<HapticLogEntry> get recentLog =>
      _log.reversed.take(10).toList();

  /// Повна історія викликів.
  static List<HapticLogEntry> get fullLog => List.unmodifiable(_log);

  /// Чи увімкнено режим енергозбереження.
  static bool get isBatterySaverMode => _batterySaverMode;

  /// Кількість запланованих патернів.
  static int get scheduledCount => _scheduledQueue.length;

  /// Глобальний множник інтенсивності.
  static double get globalIntensityMultiplier => _globalIntensityMultiplier;

  /// Глобальний тег.
  static String? get globalTag => _globalTag;

  /// Чи пристрій підтримує розширені haptic-ефекти.
  static bool get supportsAdvancedEffects =>
      _capabilities.supportsAdvancedHaptics;

  /// Чи пристрій підтримує кастомні послідовності.
  static bool get supportsCustomVibration =>
      _capabilities.supportsCustomVibration;

  /// Чи пристрій має контроль амплітуди.
  static bool get hasAmplitudeControl => _capabilities.hasAmplitudeControl;

  // ─── Управління станом ──────────────────────────────────────────────

  /// Увімкнути тактильний зворотний зв'язок.
  static void enable() => _enabled = true;

  /// Вимкнути тактильний зворотний зв'язок.
  static void disable() => _enabled = false;

  /// Змінює стан увімкнення на протилежний.
  static void toggle() => _enabled = !_enabled;

  /// Встановлює рівень інтенсивності.
  ///
  /// [intensity] — новий рівень інтенсивності.
  static void setIntensity(HapticIntensity intensity) {
    _intensity = intensity;
    debugPrint('[HapticService] Intensity: ${intensity.name}');
  }

  /// Встановлює глобальний множник інтенсивності.
  ///
  /// [multiplier] — значення від 0.0 до 2.0.
  static void setGlobalIntensityMultiplier(double multiplier) {
    _globalIntensityMultiplier = multiplier.clamp(0.0, 2.0);
    debugPrint('[HapticService] Global multiplier: ${_globalIntensityMultiplier.toStringAsFixed(2)}x');
  }

  /// Встановлює глобальний тег для фільтрації.
  static void setGlobalTag(String? tag) => _globalTag = tag;

  /// Увімкнути режим зменшення руху.
  ///
  /// Коли увімкнено, всі патерни або пропускаються,
  /// або виконуються з мінімальною інтенсивністю.
  static void setReduceMotion(bool reduce) => _reduceMotion = reduce;

  /// Увімкнути/вимкнути режим енергозбереження.
  ///
  /// У цьому режимі лише ~50% патернів виконуються,
  /// інтенсивність знижується на один рівень.
  static void setBatterySaverMode(bool enabled) {
    _batterySaverMode = enabled;
    debugPrint('[HapticService] Battery saver: ${enabled ? "ON" : "OFF"}');
  }

  /// Встановлює кастомну конфігурацію для патерну.
  static void setPatternConfig(
    HapticPattern pattern,
    HapticIntensityConfig config,
  ) {
    _patternConfigs[pattern] = config;
  }

  /// Встановлює конфігурацію для кількох патернів.
  static void setPatternConfigs(
    Map<HapticPattern, HapticIntensityConfig> configs,
  ) {
    _patternConfigs.addAll(configs);
  }

  /// Видаляє кастомну конфігурацію патерну.
  static void removePatternConfig(HapticPattern pattern) {
    _patternConfigs.remove(pattern);
  }

  /// Очищає всі кастомні конфігурації.
  static void clearPatternConfigs() {
    _patternConfigs.clear();
  }

  /// Повертає конфігурацію патерну (або дефолтну).
  static HapticIntensityConfig getPatternConfig(HapticPattern pattern) {
    return _patternConfigs[pattern] ?? const HapticIntensityConfig();
  }

  /// Очищає журнал викликів.
  static void clearLog() {
    _log.clear();
  }

  /// Повністю скидає стан сервісу до значень за замовчуванням.
  ///
  /// Очищає журнал, скидає лічильники, відновлює стандартні налаштування.
  static void reset() {
    _enabled = true;
    _intensity = HapticIntensity.medium;
    _reduceMotion = false;
    _batterySaverMode = false;
    _isTriggering = false;
    _rapidCallCount = 0;
    _lastTriggerTime = null;
    _totalTriggers = 0;
    _globalIntensityMultiplier = 1.0;
    _globalTag = null;
    _log.clear();
    _patternConfigs.clear();
    cancelAllScheduled();
    debugPrint('[HapticService] Service reset to defaults');
  }

  /// Скидає стан сервісу для тестування (без debugPrint).
  static void resetForTesting() {
    _log.clear();
    _totalTriggers = 0;
    _rapidCallCount = 0;
    _lastTriggerTime = null;
    _isTriggering = false;
    _enabled = true;
    _intensity = HapticIntensity.medium;
    _reduceMotion = false;
    _batterySaverMode = false;
    _globalIntensityMultiplier = 1.0;
    _globalTag = null;
    _patternConfigs.clear();
    cancelAllScheduled();
  }

  // ─── Базові патерни ────────────────────────────────────────────────

  /// Легке торкання — для звичайних натискань кнопок.
  static Future<void> lightTap() async {
    if (!isEnabled) return;
    if (!_checkRateLimit()) return;
    await _executeWithLogging(
      HapticPattern.light,
      () => HapticFeedback.lightImpact(),
    );
  }

  /// Середнє торкання — для підтверджень дій.
  static Future<void> mediumTap() async {
    if (!isEnabled) return;
    if (!_checkRateLimit()) return;
    await _executeWithLogging(
      HapticPattern.medium,
      () => HapticFeedback.mediumImpact(),
    );
  }

  /// Сильне торкання — для важливих подій.
  static Future<void> heavyTap() async {
    if (!isEnabled) return;
    if (!_checkRateLimit()) return;
    await _executeWithLogging(
      HapticPattern.heavy,
      () => HapticFeedback.heavyImpact(),
    );
  }

  /// Торкання-вибір — для перемикання елементів.
  static Future<void> selection() async {
    if (!isEnabled) return;
    await _executeWithLogging(
      HapticPattern.selection,
      () => HapticFeedback.selectionClick(),
    );
  }

  /// Успішна дія — «vibrate» патерн для досягнень.
  static Future<void> success() async {
    if (!isEnabled) return;
    if (!_checkRateLimit()) return;
    await _executeWithLogging(
      HapticPattern.success,
      () => HapticFeedback.vibrate(),
    );
  }

  /// Помилка — коротка вібрація для невдалих дій.
  static Future<void> error() async {
    if (!isEnabled) return;
    if (!_checkRateLimit()) return;
    await _executeWithLogging(
      HapticPattern.error,
      () async {
        await HapticFeedback.heavyImpact();
        await Future<void>.delayed(const Duration(milliseconds: 50));
        await HapticFeedback.heavyImpact();
      },
    );
  }

  // ─── Гейміфіковані патерни ──────────────────────────────────────────

  /// Крапля монети — для додавання грошей у скарбничку.
  static Future<void> coinDrop() async {
    if (!isEnabled) return;
    if (!_checkRateLimit()) return;
    await _executeWithLogging(
      HapticPattern.coinDrop,
      () async {
        await HapticFeedback.lightImpact();
        await Future<void>.delayed(const Duration(milliseconds: 50));
        await HapticFeedback.vibrate();
      },
    );
  }

  /// Підвищення рівня — сходовий патерн вібрації.
  static Future<void> levelUp() async {
    if (!isEnabled) return;
    if (!_checkRateLimit()) return;
    await _executeWithLogging(
      HapticPattern.levelUp,
      () async {
        await HapticFeedback.lightImpact();
        await Future<void>.delayed(const Duration(milliseconds: 100));
        await HapticFeedback.mediumImpact();
        await Future<void>.delayed(const Duration(milliseconds: 100));
        await HapticFeedback.heavyImpact();
        await Future<void>.delayed(const Duration(milliseconds: 150));
        await HapticFeedback.vibrate();
      },
    );
  }

  /// Розблокування бейджу — потрійний короткий імпульс.
  static Future<void> badgeUnlock() async {
    if (!isEnabled) return;
    if (!_checkRateLimit()) return;
    await _executeWithLogging(
      HapticPattern.badgeUnlock,
      () async {
        for (int i = 0; i < 3; i++) {
          await HapticFeedback.lightImpact();
          await Future<void>.delayed(const Duration(milliseconds: 80));
        }
      },
    );
  }

  /// Активна серія — наростаючий патерн.
  static Future<void> streakFire() async {
    if (!isEnabled) return;
    if (!_checkRateLimit()) return;
    await _executeWithLogging(
      HapticPattern.streakFire,
      () async {
        await HapticFeedback.selectionClick();
        await Future<void>.delayed(const Duration(milliseconds: 60));
        await HapticFeedback.lightImpact();
        await Future<void>.delayed(const Duration(milliseconds: 60));
        await HapticFeedback.mediumImpact();
        await Future<void>.delayed(const Duration(milliseconds: 80));
        await HapticFeedback.heavyImpact();
      },
    );
  }

  /// Тріщина льоду — для заморожування серії.
  static Future<void> frostCrack() async {
    if (!isEnabled) return;
    if (!_checkRateLimit()) return;
    await _executeWithLogging(
      HapticPattern.frostCrack,
      () async {
        await HapticFeedback.heavyImpact();
        await Future<void>.delayed(const Duration(milliseconds: 200));
        await HapticFeedback.lightImpact();
        await Future<void>.delayed(const Duration(milliseconds: 100));
        await HapticFeedback.lightImpact();
      },
    );
  }

  /// Конфетті — швидкі черги імпульсів.
  static Future<void> confetti() async {
    if (!isEnabled) return;
    if (!_checkRateLimit()) return;
    await _executeWithLogging(
      HapticPattern.confetti,
      () async {
        for (int i = 0; i < 6; i++) {
          await HapticFeedback.selectionClick();
          await Future<void>.delayed(const Duration(milliseconds: 40));
        }
      },
    );
  }

  /// Перемикач — дуже легкий клік.
  static Future<void> switchToggle() async {
    if (!isEnabled) return;
    await _executeWithLogging(
      HapticPattern.switchToggle,
      () => HapticFeedback.selectionClick(),
    );
  }

  /// Потягни для оновлення.
  static Future<void> pullToRefresh() async {
    if (!isEnabled) return;
    if (!_checkRateLimit()) return;
    await _executeWithLogging(
      HapticPattern.pullToRefresh,
      () => HapticFeedback.mediumImpact(),
    );
  }

  /// Видалення свайпом.
  static Future<void> deleteSwipe() async {
    if (!isEnabled) return;
    if (!_checkRateLimit()) return;
    await _executeWithLogging(
      HapticPattern.deleteSwipe,
      () async {
        await HapticFeedback.lightImpact();
        await Future<void>.delayed(const Duration(milliseconds: 30));
        await HapticFeedback.selectionClick();
      },
    );
  }

  /// Розтягування картки.
  static Future<void> cardStretch() async {
    if (!isEnabled) return;
    if (!_checkRateLimit()) return;
    await _executeWithLogging(
      HapticPattern.cardStretch,
      () async {
        await HapticFeedback.selectionClick();
        await Future<void>.delayed(const Duration(milliseconds: 100));
        await HapticFeedback.lightImpact();
      },
    );
  }

  /// Досягнення цілі — святковий патерн.
  static Future<void> goalAchieved() async {
    if (!isEnabled) return;
    if (!_checkRateLimit()) return;
    await _executeWithLogging(
      HapticPattern.goalAchieved,
      () async {
        await HapticFeedback.lightImpact();
        await Future<void>.delayed(const Duration(milliseconds: 80));
        await HapticFeedback.mediumImpact();
        await Future<void>.delayed(const Duration(milliseconds: 80));
        await HapticFeedback.heavyImpact();
        await Future<void>.delayed(const Duration(milliseconds: 120));
        await HapticFeedback.vibrate();
        await Future<void>.delayed(const Duration(milliseconds: 200));
        await HapticFeedback.vibrate();
      },
    );
  }

  /// Попередження — подвійний легкий імпульс.
  static Future<void> warning() async {
    if (!isEnabled) return;
    if (!_checkRateLimit()) return;
    await _executeWithLogging(
      HapticPattern.warning,
      () async {
        await HapticFeedback.lightImpact();
        await Future<void>.delayed(const Duration(milliseconds: 100));
        await HapticFeedback.lightImpact();
      },
    );
  }

  /// Інформаційне повідомлення — одиночний легкий клік.
  static Future<void> info() async {
    if (!isEnabled) return;
    await _executeWithLogging(
      HapticPattern.info,
      () => HapticFeedback.selectionClick(),
    );
  }

  /// Скасування дії — коротка легка вібрація.
  static Future<void> cancel() async {
    if (!isEnabled) return;
    if (!_checkRateLimit()) return;
    await _executeWithLogging(
      HapticPattern.cancel,
      () => HapticFeedback.lightImpact(),
    );
  }

  /// Початок перетягування — мінімальний відгук.
  static Future<void> dragStart() async {
    if (!isEnabled) return;
    await _executeWithLogging(
      HapticPattern.dragStart,
      () => HapticFeedback.selectionClick(),
    );
  }

  /// Завершення перетягування — середній відгук.
  static Future<void> dropComplete() async {
    if (!isEnabled) return;
    if (!_checkRateLimit()) return;
    await _executeWithLogging(
      HapticPattern.dropComplete,
      () => HapticFeedback.mediumImpact(),
    );
  }

  /// Натискання клавіші — дуже делікатний відгук.
  static Future<void> keystroke() async {
    if (!isEnabled) return;
    if (_intensity.index < HapticIntensity.light.index) return;
    await _executeWithLogging(
      HapticPattern.keystroke,
      () => HapticFeedback.selectionClick(),
    );
  }

  /// Довге натискання — наростаючий імпульс.
  static Future<void> longPress() async {
    if (!isEnabled) return;
    if (!_checkRateLimit()) return;
    await _executeWithLogging(
      HapticPattern.longPress,
      () async {
        await HapticFeedback.lightImpact();
        await Future<void>.delayed(const Duration(milliseconds: 150));
        await HapticFeedback.mediumImpact();
      },
    );
  }

  /// Двічі натиснути — подвійний клік.
  static Future<void> doubleTap() async {
    if (!isEnabled) return;
    if (!_checkRateLimit()) return;
    await _executeWithLogging(
      HapticPattern.doubleTap,
      () async {
        await HapticFeedback.lightImpact();
        await Future<void>.delayed(const Duration(milliseconds: 50));
        await HapticFeedback.lightImpact();
      },
    );
  }

  /// Скасування останньої дії — два легкі імпульси.
  static Future<void> undo() async {
    if (!isEnabled) return;
    if (!_checkRateLimit()) return;
    await _executeWithLogging(
      HapticPattern.undo,
      () async {
        await HapticFeedback.lightImpact();
        await Future<void>.delayed(const Duration(milliseconds: 80));
        await HapticFeedback.lightImpact();
      },
    );
  }

  /// Підтвердження видалення — сильний імпульс.
  static Future<void> deleteConfirm() async {
    if (!isEnabled) return;
    if (!_checkRateLimit()) return;
    await _executeWithLogging(
      HapticPattern.deleteConfirm,
      () async {
        await HapticFeedback.heavyImpact();
        await Future<void>.delayed(const Duration(milliseconds: 100));
        await HapticFeedback.heavyImpact();
      },
    );
  }

  /// Завершення онбордингу — святковий патерн.
  static Future<void> onboardingComplete() async {
    if (!isEnabled) return;
    if (!_checkRateLimit()) return;
    await _executeWithLogging(
      HapticPattern.onboardingComplete,
      () async {
        await HapticFeedback.lightImpact();
        await Future<void>.delayed(const Duration(milliseconds: 100));
        await HapticFeedback.mediumImpact();
        await Future<void>.delayed(const Duration(milliseconds: 100));
        await HapticFeedback.heavyImpact();
        await Future<void>.delayed(const Duration(milliseconds: 150));
        await HapticFeedback.vibrate();
        await Future<void>.delayed(const Duration(milliseconds: 100));
        await HapticFeedback.vibrate();
      },
    );
  }

  /// Розблокування функції — три швидких імпульси.
  static Future<void> featureUnlock() async {
    if (!isEnabled) return;
    if (!_checkRateLimit()) return;
    await _executeWithLogging(
      HapticPattern.featureUnlock,
      () async {
        for (int i = 0; i < 3; i++) {
          await HapticFeedback.mediumImpact();
          await Future<void>.delayed(const Duration(milliseconds: 60));
        }
      },
    );
  }

  // ─── Додаткові патерни ──────────────────────────────────────────────

  /// Скарбничка поповнена — «дзень» монети + підтвердження.
  static Future<void> piggyBankDeposit() async {
    if (!isEnabled) return;
    if (!_checkRateLimit()) return;
    await _executeWithLogging(
      HapticPattern.coinDrop,
      () async {
        await HapticFeedback.selectionClick();
        await Future<void>.delayed(const Duration(milliseconds: 40));
        await HapticFeedback.lightImpact();
        await Future<void>.delayed(const Duration(milliseconds: 60));
        await HapticFeedback.mediumImpact();
      },
    );
  }

  /// Щоденна нагорода — подвійний light + selectionClick.
  static Future<void> dailyReward() async {
    if (!isEnabled) return;
    if (!_checkRateLimit()) return;
    await _executeWithLogging(
      HapticPattern.success,
      () async {
        await HapticFeedback.lightImpact();
        await Future<void>.delayed(const Duration(milliseconds: 80));
        await HapticFeedback.lightImpact();
        await Future<void>.delayed(const Duration(milliseconds: 50));
        await HapticFeedback.selectionClick();
      },
    );
  }

  /// Завершення челенджу — сходинка з фінальним акцентом.
  static Future<void> challengeComplete() async {
    if (!isEnabled) return;
    if (!_checkRateLimit()) return;
    await _executeWithLogging(
      HapticPattern.goalAchieved,
      () async {
        await HapticFeedback.lightImpact();
        await Future<void>.delayed(const Duration(milliseconds: 100));
        await HapticFeedback.mediumImpact();
        await Future<void>.delayed(const Duration(milliseconds: 100));
        await HapticFeedback.heavyImpact();
        await Future<void>.delayed(const Duration(milliseconds: 150));
        await HapticFeedback.vibrate();
        await Future<void>.delayed(const Duration(milliseconds: 80));
        await HapticFeedback.heavyImpact();
      },
    );
  }

  /// Серія втрачена — різкий «злам» патерн.
  static Future<void> streakLost() async {
    if (!isEnabled) return;
    if (!_checkRateLimit()) return;
    await _executeWithLogging(
      HapticPattern.frostCrack,
      () async {
        await HapticFeedback.heavyImpact();
        await Future<void>.delayed(const Duration(milliseconds: 200));
        await HapticFeedback.lightImpact();
        await Future<void>.delayed(const Duration(milliseconds: 100));
        await HapticFeedback.selectionClick();
      },
    );
  }

  /// Відкриття скарбу — трійковий «вскриття» з різною силою.
  static Future<void> treasureOpen() async {
    if (!isEnabled) return;
    if (!_checkRateLimit()) return;
    await _executeWithLogging(
      HapticPattern.badgeUnlock,
      () async {
        await HapticFeedback.mediumImpact();
        await Future<void>.delayed(const Duration(milliseconds: 120));
        await HapticFeedback.heavyImpact();
        await Future<void>.delayed(const Duration(milliseconds: 60));
        await HapticFeedback.vibrate();
      },
    );
  }

  /// Помилка з підказкою — error патерн з додатковим light.
  static Future<void> errorWithHint() async {
    if (!isEnabled) return;
    if (!_checkRateLimit()) return;
    await _executeWithLogging(
      HapticPattern.error,
      () async {
        await HapticFeedback.heavyImpact();
        await Future<void>.delayed(const Duration(milliseconds: 150));
        await HapticFeedback.lightImpact();
        await Future<void>.delayed(const Duration(milliseconds: 50));
        await HapticFeedback.lightImpact();
      },
    );
  }

  /// Нотифікація — легкий імпульс для вхідних повідомлень.
  static Future<void> notification() async {
    if (!isEnabled) return;
    await _executeWithLogging(
      HapticPattern.info,
      () => HapticFeedback.lightImpact(),
    );
  }

  /// Навігація між вкладками — миттєвий selectionClick.
  static Future<void> tabNavigation() async {
    if (!isEnabled) return;
    await _executeWithLogging(
      HapticPattern.selection,
      () => HapticFeedback.selectionClick(),
    );
  }

  /// Прокрутка списку до краю — легкий bump.
  static Future<void> scrollBoundary() async {
    if (!isEnabled) return;
    await _executeWithLogging(
      HapticPattern.light,
      () => HapticFeedback.selectionClick(),
    );
  }

  /// Натискання кнопки «назад» — легкий імпульс.
  static Future<void> backButton() async {
    if (!isEnabled) return;
    await _executeWithLogging(
      HapticPattern.light,
      () => HapticFeedback.lightImpact(),
    );
  }

  /// Автентифікація біометричним сканером.
  static Future<void> biometricAuth() async {
    if (!isEnabled) return;
    if (!_checkRateLimit()) return;
    await _executeWithLogging(
      HapticPattern.heavy,
      () => HapticFeedback.heavyImpact(),
    );
  }

  /// Успішна оплата — святковий патерн з 4 імпульсів.
  static Future<void> paymentSuccess() async {
    if (!isEnabled) return;
    if (!_checkRateLimit()) return;
    await _executeWithLogging(
      HapticPattern.success,
      () async {
        await HapticFeedback.lightImpact();
        await Future<void>.delayed(const Duration(milliseconds: 60));
        await HapticFeedback.mediumImpact();
        await Future<void>.delayed(const Duration(milliseconds: 80));
        await HapticFeedback.heavyImpact();
        await Future<void>.delayed(const Duration(milliseconds: 100));
        await HapticFeedback.vibrate();
      },
    );
  }

  /// Помилка платежу — подвійний важкий імпульс з затримкою.
  static Future<void> paymentError() async {
    if (!isEnabled) return;
    if (!_checkRateLimit()) return;
    await _executeWithLogging(
      HapticPattern.error,
      () async {
        await HapticFeedback.heavyImpact();
        await Future<void>.delayed(const Duration(milliseconds: 100));
        await HapticFeedback.heavyImpact();
      },
    );
  }

  /// «Heartbeat» — два швидких імпульси для активності.
  static Future<void> heartbeat() async {
    if (!isEnabled) return;
    await _executeWithLogging(
      HapticPattern.info,
      () async {
        await HapticFeedback.lightImpact();
        await Future<void>.delayed(const Duration(milliseconds: 40));
        await HapticFeedback.lightImpact();
      },
    );
  }

  /// «Success chime» — 3 короткі ascending тони.
  static Future<void> successChime() async {
    if (!isEnabled) return;
    if (!_checkRateLimit()) return;
    await _executeWithLogging(
      HapticPattern.success,
      () async {
        await HapticFeedback.selectionClick();
        await Future<void>.delayed(const Duration(milliseconds: 60));
        await HapticFeedback.lightImpact();
        await Future<void>.delayed(const Duration(milliseconds: 80));
        await HapticFeedback.mediumImpact();
      },
    );
  }

  /// «Fail buzz» — спадаючий патерн для невдачі.
  static Future<void> failBuzz() async {
    if (!isEnabled) return;
    if (!_checkRateLimit()) return;
    await _executeWithLogging(
      HapticPattern.error,
      () async {
        await HapticFeedback.mediumImpact();
        await Future<void>.delayed(const Duration(milliseconds: 50));
        await HapticFeedback.lightImpact();
      },
    );
  }

  /// Різке падіння монет — для втрати монет або штрафу.
  static Future<void> coinLoss() async {
    if (!isEnabled) return;
    if (!_checkRateLimit()) return;
    await _executeWithLogging(
      HapticPattern.error,
      () async {
        await HapticFeedback.heavyImpact();
        await Future<void>.delayed(const Duration(milliseconds: 30));
        await HapticFeedback.lightImpact();
        await Future<void>.delayed(const Duration(milliseconds: 30));
        await HapticFeedback.lightImpact();
      },
    );
  }

  /// Купівля в магазині — подвійний середній імпульс.
  static Future<void> shopPurchase() async {
    if (!isEnabled) return;
    if (!_checkRateLimit()) return;
    await _executeWithLogging(
      HapticPattern.medium,
      () async {
        await HapticFeedback.mediumImpact();
        await Future<void>.delayed(const Duration(milliseconds: 80));
        await HapticFeedback.mediumImpact();
      },
    );
  }

  /// Відкриття скриньки — трійковий наростаючий патерн.
  static Future<void> lootBoxOpen() async {
    if (!isEnabled) return;
    if (!_checkRateLimit()) return;
    await _executeWithLogging(
      HapticPattern.coinDrop,
      () async {
        await HapticFeedback.selectionClick();
        await Future<void>.delayed(const Duration(milliseconds: 60));
        await HapticFeedback.lightImpact();
        await Future<void>.delayed(const Duration(milliseconds: 80));
        await HapticFeedback.mediumImpact();
      },
    );
  }

  /// Нагорода за серію — серія з 5 імпульсів з наростаючою силою.
  static Future<void> streakReward() async {
    if (!isEnabled) return;
    if (!_checkRateLimit()) return;
    await _executeWithLogging(
      HapticPattern.streakFire,
      () async {
        for (int i = 0; i < 5; i++) {
          await HapticFeedback.selectionClick();
          await Future<void>.delayed(Duration(milliseconds: 80 - i * 12));
        }
        await HapticFeedback.mediumImpact();
      },
    );
  }

  // ─── Загальний метод trigger ───────────────────────────────────────

  /// Виконує вібрацію за заданим патерном [pattern].
  ///
  /// Перемикається на відповідний метод залежно від типу патерну.
  static Future<void> trigger(HapticPattern pattern) async {
    if (!isEnabled) return;

    // Перевіряємо кастомну конфігурацію
    final config = _patternConfigs[pattern];
    if (config != null) {
      if (!config.enabled) return;
      if (_intensity.index < config.minIntensity.index) return;
      if (config.customPattern != null) {
        await _executeWithLogging(pattern, config.customPattern!);
        return;
      }
    }

    // Перевіряємо режим енергозбереження
    if (_batterySaverMode && !_shouldExecuteInBatterySaver(pattern)) {
      return;
    }

    switch (pattern) {
      case HapticPattern.light:
        await lightTap();
      case HapticPattern.medium:
        await mediumTap();
      case HapticPattern.heavy:
        await heavyTap();
      case HapticPattern.selection:
        await selection();
      case HapticPattern.success:
        await success();
      case HapticPattern.error:
        await error();
      case HapticPattern.coinDrop:
        await coinDrop();
      case HapticPattern.levelUp:
        await levelUp();
      case HapticPattern.badgeUnlock:
        await badgeUnlock();
      case HapticPattern.streakFire:
        await streakFire();
      case HapticPattern.frostCrack:
        await frostCrack();
      case HapticPattern.confetti:
        await confetti();
      case HapticPattern.switchToggle:
        await switchToggle();
      case HapticPattern.pullToRefresh:
        await pullToRefresh();
      case HapticPattern.deleteSwipe:
        await deleteSwipe();
      case HapticPattern.cardStretch:
        await cardStretch();
      case HapticPattern.goalAchieved:
        await goalAchieved();
      case HapticPattern.warning:
        await warning();
      case HapticPattern.info:
        await info();
      case HapticPattern.cancel:
        await cancel();
      case HapticPattern.dragStart:
        await dragStart();
      case HapticPattern.dropComplete:
        await dropComplete();
      case HapticPattern.keystroke:
        await keystroke();
      case HapticPattern.longPress:
        await longPress();
      case HapticPattern.doubleTap:
        await doubleTap();
      case HapticPattern.undo:
        await undo();
      case HapticPattern.deleteConfirm:
        await deleteConfirm();
      case HapticPattern.onboardingComplete:
        await onboardingComplete();
      case HapticPattern.featureUnlock:
        await featureUnlock();
    }
  }

  // ─── Адаптивні за інтенсивністю ───────────────────────────────────

  /// Виконує базовий патерн з урахуванням поточної інтенсивності.
  ///
  /// Якщо інтенсивність lower ніж [minIntensity] — патерн пропускається.
  static Future<void> intensityGated(
    HapticIntensity minIntensity,
    Future<void> Function() action,
  ) async {
    if (!isEnabled) return;
    if (_intensity.index < minIntensity.index) return;
    await action();
  }

  /// Адаптивний патерн на основі значення (0.0–1.0).
  ///
  /// Мапує значення на один з трьох патернів.
  static Future<void> valueMapped({
    required double value,
    HapticPattern lowPattern = HapticPattern.light,
    HapticPattern midPattern = HapticPattern.medium,
    HapticPattern highPattern = HapticPattern.heavy,
    double lowThreshold = 0.33,
    double highThreshold = 0.66,
  }) async {
    if (value < lowThreshold) {
      await trigger(lowPattern);
    } else if (value < highThreshold) {
      await trigger(midPattern);
    } else {
      await trigger(highPattern);
    }
  }

  /// Умовний виконання патерну.
  static Future<void> conditional(
    HapticPattern pattern,
    bool condition,
  ) async {
    if (condition) await trigger(pattern);
  }

  /// Різні патерни залежно від умови.
  static Future<void> conditionalEither({
    required HapticPattern onTrue,
    required HapticPattern onFalse,
    required bool condition,
  }) async {
    await trigger(condition ? onTrue : onFalse);
  }

  /// Адаптивна вібрація за значенням (0.0–1.0).
  static Future<void> adaptive({
    required double value,
    double threshold = 0.5,
    HapticPattern low = HapticPattern.light,
    HapticPattern medium = HapticPattern.medium,
    HapticPattern high = HapticPattern.heavy,
  }) async {
    if (value < threshold * 0.5) {
      await trigger(low);
    } else if (value < threshold) {
      await trigger(medium);
    } else {
      await trigger(high);
    }
  }

  /// Доступність-орієнтований вибір патерну.
  static Future<void> accessibleSelection({
    HapticPattern normalPattern = HapticPattern.selection,
    HapticPattern reducedPattern = HapticPattern.light,
  }) async {
    if (!isEnabled) return;
    await trigger(_reduceMotion ? reducedPattern : normalPattern);
  }

  /// Вібрація-підтвердження з пониженням інтенсивності.
  static Future<void> scaledConfirmation() async {
    if (!isEnabled) return;
    switch (_intensity) {
      case HapticIntensity.subtle:
        await HapticFeedback.selectionClick();
      case HapticIntensity.light:
        await HapticFeedback.lightImpact();
      case HapticIntensity.medium:
        await HapticFeedback.mediumImpact();
      case HapticIntensity.heavy:
        await HapticFeedback.heavyImpact();
      case HapticIntensity.extreme:
        try {
          await HapticFeedback.heavyImpact();
          await Future<void>.delayed(const Duration(milliseconds: 50));
          await HapticFeedback.heavyImpact();
        } catch (_) {}
    }
  }

  /// Перетворює значення прогресу (0.0–1.0) на адаптивний патерн.
  static Future<void> progressFeedback(double progress) async {
    if (!isEnabled) return;
    if (progress >= 1.0) {
      await trigger(HapticPattern.goalAchieved);
    } else if (progress >= 0.75) {
      await trigger(HapticPattern.heavy);
    } else if (progress >= 0.5) {
      await trigger(HapticPattern.medium);
    } else if (progress >= 0.25) {
      await trigger(HapticPattern.light);
    } else {
      await trigger(HapticPattern.selection);
    }
  }

  /// Критичний патерн — виконується навіть якщо сервіс вимкнений.
  ///
  /// ⚠️ Тільки для критичних подій (помилки системи).
  static Future<void> triggerCritical(HapticPattern pattern) async {
    if (!_platformSupported) return;
    if (_isTriggering) return;
    final previousEnabled = _enabled;
    _enabled = true;
    try {
      await trigger(pattern);
    } finally {
      _enabled = previousEnabled;
    }
  }

  // ─── Кастомні вібрації ──────────────────────────────────────────────

  /// Виконує кастомну вібрацію за заданим патерном.
  ///
  /// [pattern] — список тривалостей в мілісекундах, що чергуються:
  /// непарні значення — вібрація, парні — пауза.
  static Future<void> customVibrate(List<int> pattern) async {
    if (!isEnabled || pattern.isEmpty) return;
    final validationError = validateCustomPatternString(pattern);
    if (validationError != null) {
      debugPrint('[HapticService] Invalid custom pattern: $validationError');
      return;
    }
    try {
      for (int i = 0; i < pattern.length; i++) {
        final isVibration = i.isEven;
        final duration = Duration(milliseconds: pattern[i].clamp(0, 500));
        if (isVibration && duration.inMilliseconds > 0) {
          await HapticFeedback.vibrate();
        }
        if (i < pattern.length - 1) {
          await Future<void>.delayed(duration);
        }
      }
    } catch (_) {}
  }

  /// Будує кастомну послідовність вібрацій.
  static Future<void> buildSequence({
    required List<HapticIntensity> steps,
    Duration stepDuration = const Duration(milliseconds: 50),
    Duration pauseDuration = const Duration(milliseconds: 30),
  }) async {
    if (!isEnabled) return;
    try {
      for (int i = 0; i < steps.length; i++) {
        await _executeIntensityStep(steps[i]);
        if (i < steps.length - 1) {
          await Future<void>.delayed(pauseDuration);
        }
      }
    } catch (_) {}
  }

  /// Будує складний тактильний ефект за часовою лінією.
  static Future<void> buildTimeline(
    List<HapticTimelineStep> steps,
  ) async {
    if (!isEnabled || steps.isEmpty) return;
    try {
      for (int i = 0; i < steps.length; i++) {
        final step = steps[i];
        await _executeIntensityStep(step.intensity);
        if (step.duration.inMilliseconds > 0) {
          await Future<void>.delayed(step.duration);
        }
        if (step.pauseAfter.inMilliseconds > 0 && i < steps.length - 1) {
          await Future<void>.delayed(step.pauseAfter);
        }
      }
    } catch (_) {}
  }

  // ─── Пакетні операції ──────────────────────────────────────────────

  /// Виконує кілька патернів послідовно з паузою між ними.
  static Future<void> triggerSequence(
    List<HapticPattern> patterns, {
    Duration delayBetween = const Duration(milliseconds: 150),
  }) async {
    if (!isEnabled || patterns.isEmpty) return;
    for (final pattern in patterns) {
      await trigger(pattern);
      if (pattern != patterns.last) {
        await Future<void>.delayed(delayBetween);
      }
    }
  }

  /// Виконує патерн з повторенням.
  static Future<void> triggerRepeated(
    HapticPattern pattern, {
    int count = 3,
    Duration interval = const Duration(milliseconds: 100),
  }) async {
    if (!isEnabled || count <= 0) return;
    final effectiveCount = count.clamp(1, 10);
    for (int i = 0; i < effectiveCount; i++) {
      await trigger(pattern);
      if (i < effectiveCount - 1) {
        await Future<void>.delayed(interval);
      }
    }
  }

  /// Виконує патерн з наростаючою інтенсивністю.
  static Future<void> triggerRampUp({
    int count = 4,
    Duration stepDelay = const Duration(milliseconds: 60),
  }) async {
    if (!isEnabled || count <= 0) return;
    final intensities = HapticIntensity.values.take(count.clamp(1, 5)).toList();
    for (int i = 0; i < intensities.length; i++) {
      await _executeIntensityStep(intensities[i]);
      if (i < intensities.length - 1) {
        await Future<void>.delayed(stepDelay);
      }
    }
  }

  /// Виконує патерн зі спадаючою інтенсивністю.
  static Future<void> triggerRampDown({
    int count = 4,
    Duration stepDelay = const Duration(milliseconds: 60),
  }) async {
    if (!isEnabled || count <= 0) return;
    final intensities = HapticIntensity.values
        .toList()
        .reversed
        .take(count.clamp(1, 5))
        .toList();
    for (int i = 0; i < intensities.length; i++) {
      await _executeIntensityStep(intensities[i]);
      if (i < intensities.length - 1) {
        await Future<void>.delayed(stepDelay);
      }
    }
  }

  /// Виконує пакетну операцію.
  static Future<void> executeBatch(HapticBatch batch) async {
    if (!isEnabled) return;
    for (final step in batch.steps) {
      if (!step.condition) continue;
      if (step.delayBefore > Duration.zero) {
        await Future<void>.delayed(step.delayBefore);
      }
      await trigger(step.pattern);
      if (step.delayAfter > Duration.zero) {
        await Future<void>.delayed(step.delayAfter);
      }
    }
  }

  /// Відкладений виконання патерну з затримкою.
  static Future<void> triggerDelayed(
    HapticPattern pattern, {
    Duration delay = const Duration(milliseconds: 200),
  }) async {
    await Future<void>.delayed(delay);
    await trigger(pattern);
  }

  /// Відкладений патерн з умовою — скасовується, якщо сервіс вимкнеться.
  static Future<void> triggerDeferred(
    HapticPattern pattern, {
    Duration delay = const Duration(milliseconds: 300),
  }) async {
    await Future<void>.delayed(delay);
    if (isEnabled) await trigger(pattern);
  }

  /// Перекриваючі патерни.
  static Future<void> triggerOverlapping(
    HapticPattern first,
    HapticPattern second, {
    Duration delay = Duration.zero,
  }) async {
    if (!isEnabled) return;
    await trigger(first);
    if (delay > Duration.zero) {
      await Future<void>.delayed(delay);
    }
    await trigger(second);
  }

  /// Debounce — відкладає патерн, скасовуючи попередні виклики.
  ///
  /// Якщо [pattern] викликається кілька разів протягом [wait],
  /// виконається лише останній.
  static void triggerDebounced(
    HapticPattern pattern, {
    Duration wait = const Duration(milliseconds: 100),
  }) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(wait, () {
      trigger(pattern);
    });
  }

  /// Генерує випадковий патерн з вказаної категорії.
  static Future<void> triggerRandomFromCategory(String category) async {
    final patterns = getPatternsByCategory(category);
    if (patterns.isEmpty) return;
    final index = DateTime.now().millisecondsSinceEpoch % patterns.length;
    await trigger(patterns[index]);
  }

  /// Прогрес-послідовність для таймера.
  static Future<void> playProgressSequence({
    required int steps,
    Duration stepDelay = const Duration(milliseconds: 200),
  }) async {
    if (!isEnabled) return;
    if (steps <= 0 || steps > 20) return;
    for (int i = 0; i < steps; i++) {
      final progress = i / (steps - 1);
      if (progress < 0.33) {
        await selection();
      } else if (progress < 0.66) {
        await lightTap();
      } else {
        await mediumTap();
      }
      if (i < steps - 1) {
        await Future<void>.delayed(stepDelay);
      }
    }
  }

  /// «Тік» таймера.
  static Future<void> playCountdownTick() async {
    if (!isEnabled) return;
    await _executeWithLogging(
      HapticPattern.selection,
      () => HapticFeedback.selectionClick(),
    );
  }

  /// «Фінал» таймера.
  static Future<void> playCountdownFinal() async {
    if (!isEnabled) return;
    if (!_checkRateLimit()) return;
    await _executeWithLogging(
      HapticPattern.medium,
      () async {
        await HapticFeedback.mediumImpact();
        await Future<void>.delayed(const Duration(milliseconds: 100));
        await HapticFeedback.mediumImpact();
      },
    );
  }

  /// Трійкова прогресія.
  static Future<void> playTripleProgression() async {
    if (!isEnabled) return;
    await _executeWithLogging(
      HapticPattern.levelUp,
      () async {
        await HapticFeedback.lightImpact();
        await Future<void>.delayed(const Duration(milliseconds: 80));
        await HapticFeedback.mediumImpact();
        await Future<void>.delayed(const Duration(milliseconds: 80));
        await HapticFeedback.heavyImpact();
      },
    );
  }

  /// Цикл «вгору-вниз».
  static Future<void> playUpDownCycle() async {
    if (!isEnabled) return;
    await _executeWithLogging(
      HapticPattern.warning,
      () async {
        await HapticFeedback.lightImpact();
        await Future<void>.delayed(const Duration(milliseconds: 60));
        await HapticFeedback.mediumImpact();
        await Future<void>.delayed(const Duration(milliseconds: 60));
        await HapticFeedback.lightImpact();
      },
    );
  }

  /// Зупиняє всі активні вібрації.
  static Future<void> stopAll() async {
    try {
      await HapticFeedback.vibrate();
    } catch (_) {}
  }

  // ─── Планувальник ──────────────────────────────────────────────────

  /// Додає відкладений патерн у чергу.
  static void scheduleHaptic({
    required HapticPattern pattern,
    required DateTime executeAt,
    String? id,
    bool recurring = false,
    Duration? recurringInterval,
  }) {
    final item = _ScheduledHaptic(
      pattern: pattern,
      executeAt: executeAt,
      id: id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      recurring: recurring,
      recurringInterval: recurringInterval,
    );
    _scheduledQueue.add(item);
  }

  /// Обробляє чергу відкладених патернів.
  static Future<void> processScheduledHaptics() async {
    final now = DateTime.now();
    final dueItems =
        _scheduledQueue.where((s) => !s.executeAt.isAfter(now)).toList();
    for (final item in dueItems) {
      _scheduledQueue.remove(item);
      await trigger(item.pattern);
      if (item.recurring && item.recurringInterval != null) {
        scheduleHaptic(
          pattern: item.pattern,
          executeAt: now.add(item.recurringInterval!),
          id: item.id,
          recurring: true,
          recurringInterval: item.recurringInterval,
        );
      }
    }
  }

  /// Скасовує відкладений патерн за ідентифікатором.
  static bool cancelScheduledHaptic(String id) {
    final initialLength = _scheduledQueue.length;
    _scheduledQueue.removeWhere((s) => s.id == id);
    return _scheduledQueue.length < initialLength;
  }

  /// Скасовує всі відкладені патерни.
  static void cancelAllScheduled() {
    _scheduledQueue.clear();
  }

  // ─── Масштабування інтенсивності ────────────────────────────────────

  /// Масштабує тривалість паузи залежно від поточної інтенсивності.
  static int scaledPauseMs(int baseMs) {
    final multiplier = _pauseMultiplierForIntensity(_intensity);
    return (baseMs * multiplier).round();
  }

  /// Обчислює ефективну кількість імпульсів для патерну.
  static int effectiveImpulseCount(int baseCount) {
    if (!isEnabled) return 0;
    final multiplier = _impulseMultiplierForIntensity(_intensity);
    return (baseCount * multiplier).clamp(1, baseCount * 2).round();
  }

  // ─── Валідація ─────────────────────────────────────────────────────

  /// Валідує кастомний патерн вібрації (повертає рядок помилки або null).
  static String? validateCustomPatternString(List<int> pattern) {
    if (pattern.isEmpty) return 'Патерн не може бути порожнім';
    if (pattern.length > 20) return 'Занадто багато елементів (макс 20)';
    int totalMs = 0;
    for (int i = 0; i < pattern.length; i++) {
      if (pattern[i] < 0) return "Значення не може бути від'ємним: ${pattern[i]}";
      if (pattern[i] > 500) return 'Тривалість перевищує 500ms: ${pattern[i]}';
      totalMs += pattern[i];
    }
    if (totalMs > 3000) return 'Загальна тривалість перевищує 3000ms: ${totalMs}ms';
    return null;
  }

  /// Валідує кастомний патерн (повертає список проблем).
  static List<String> validateCustomPattern(List<int> pattern) {
    final issues = <String>[];
    if (pattern.isEmpty) {
      issues.add('Патерн порожній');
      return issues;
    }
    if (pattern.length > 50) {
      issues.add('Патерн занадто довгий (${pattern.length} елементів, макс 50)');
    }
    for (int i = 0; i < pattern.length; i++) {
      if (pattern[i] < 0) {
        issues.add('Елемент $i: негативне значення ${pattern[i]}');
      }
      if (pattern[i] > 500) {
        issues.add('Елемент $i: значення ${pattern[i]}ms перевищує 500ms');
      }
    }
    final totalDuration = pattern.fold<int>(0, (sum, v) => sum + v);
    if (totalDuration > 3000) {
      issues.add('Загальна тривалість ${totalDuration}ms перевищує 3000ms');
    }
    return issues;
  }

  /// Чи патерн підтримується сервісом.
  static bool isPatternSupported(HapticPattern pattern) =>
      HapticPattern.values.contains(pattern);

  /// Чи інтенсивність підтримується.
  static bool isIntensityValid(HapticIntensity intensity) =>
      HapticIntensity.values.contains(intensity);

  /// Чи кастомний патерн валідний.
  static bool isCustomPatternValid(List<int> pattern) {
    if (pattern.isEmpty || pattern.length > 50) return false;
    return pattern.every((ms) => ms >= 0 && ms <= 500);
  }

  /// Чи частота викликів в межах норми.
  static bool isFrequencyHealthy() => getTriggersPerMinute() < 20;

  /// Чи можна виконати патерн (всі умови).
  static bool canExecute(HapticPattern pattern) {
    if (!isEnabled) return false;
    if (!isPatternSupported(pattern)) return false;
    if (_isTriggering) return false;
    return true;
  }

  /// Повертає причину, чому патерн не може бути виконаний.
  static String getCannotExecuteReason(HapticPattern pattern) {
    if (!isPatternSupported(pattern)) return 'Патерн не підтримується';
    if (!_platformSupported) return 'Платформа не підтримує вібрацію';
    if (!_enabled) return 'Сервіс вимкнений';
    if (_reduceMotion) return 'Режим зменшення руху увімкнено';
    if (_isTriggering) return 'Патерн вже виконується';
    return '';
  }

  /// Перевіряє здоров'я сервісу та повертає список проблем.
  static List<String> performHealthCheck() {
    final issues = <String>[];
    if (!_platformSupported) issues.add('Платформа не підтримує вібрацію');
    if (!_enabled) issues.add('Сервіс вимкнений користувачем');
    if (_reduceMotion) issues.add('Режим зменшення руху увімкнено');
    if (_rapidCallCount >= _maxRapidCalls) {
      issues.add('Rate limiter активний');
    }
    if (_log.length >= _maxLogSize * 0.9) {
      issues.add('Журнал майже заповнений (${_log.length}/$_maxLogSize)');
    }
    if (_isTriggering) issues.add('Вібрація зараз виконується');
    if (getTriggersInLastMinute() > 30) {
      issues.add('Високий трафік: >30 викликів за хвилину');
    }
    if (_batterySaverMode) issues.add('Режим енергозбереження активний');
    return issues;
  }

  /// Повертає стан здоров'я сервісу (ok/warning/critical).
  static String get healthStatus {
    final issues = performHealthCheck();
    if (issues.isEmpty) return 'ok';
    if (issues.length <= 2) return 'warning';
    return 'critical';
  }

  /// Валідація всіх налаштувань сервісу.
  static List<String> validateServiceConfiguration() {
    final issues = <String>[];
    if (!HapticIntensity.values.contains(_intensity)) {
      issues.add('Недійсна інтенсивність: ${_intensity.name}');
    }
    if (_globalIntensityMultiplier < 0 || _globalIntensityMultiplier > 2) {
      issues.add('Множник інтенсивності поза межами (0.0–2.0)');
    }
    for (final entry in _intensityProfiles.entries) {
      if (!HapticIntensity.values.contains(entry.value)) {
        issues.add('Профіль "${entry.key}" має недійсну інтенсивність');
      }
    }
    for (final entry in _patternCategories.entries) {
      if (entry.value.isEmpty) {
        issues.add('Категорія "${entry.key}" порожня');
      }
    }
    return issues;
  }

  // ─── Статистика та аналітика ───────────────────────────────────────

  /// Повертає опис поточного стану сервісу (для дебагу).
  static String getStatus() {
    final status = isEnabled ? 'увімкнено' : 'вимкнено';
    final intensityLabel = _getIntensityLabel(_intensity);
    final platform =
        _platformSupported ? 'підтримується' : 'не підтримується';
    return 'Тактильний зв\'язок: $status | '
        'Інтенсивність: $intensityLabel | '
        'Платформа: $platform | '
        'Викликів: $_totalTriggers';
  }

  /// Повертає детальну статистику використання сервісу.
  static Map<String, dynamic> getStatistics() {
    final patternCounts = <String, int>{};
    final intensityCounts = <String, int>{};
    for (final entry in _log) {
      patternCounts[entry.pattern.name] =
          (patternCounts[entry.pattern.name] ?? 0) + 1;
      intensityCounts[entry.intensity.name] =
          (intensityCounts[entry.intensity.name] ?? 0) + 1;
    }
    return {
      'totalTriggers': _totalTriggers,
      'logSize': _log.length,
      'patternCounts': patternCounts,
      'intensityCounts': intensityCounts,
      'platformSupported': _platformSupported,
      'enabled': _enabled,
      'reduceMotion': _reduceMotion,
      'batterySaverMode': _batterySaverMode,
      'globalMultiplier': _globalIntensityMultiplier,
      'capabilities': _capabilities.toMap(),
    };
  }

  /// Повертає середню тривалість патернів у мілісекундах.
  static double getAveragePatternDuration() {
    if (_log.isEmpty) return 0.0;
    final totalMs =
        _log.fold<int>(0, (sum, e) => sum + e.duration.inMilliseconds);
    return totalMs / _log.length;
  }

  /// Повертає медіану тривалості патернів у мілісекундах.
  static double getMedianPatternDuration() {
    if (_log.isEmpty) return 0.0;
    final sorted = List<int>.from(
      _log.map((e) => e.duration.inMilliseconds),
    )..sort();
    final mid = sorted.length ~/ 2;
    if (sorted.length % 2 == 1) return sorted[mid].toDouble();
    return (sorted[mid - 1] + sorted[mid]) / 2.0;
  }

  /// Загальний час вібрації за сесію.
  static Duration getTotalVibrationTime() {
    final totalMs = _log.fold<int>(
      0,
      (sum, e) => sum + e.duration.inMilliseconds,
    );
    return Duration(milliseconds: totalMs);
  }

  /// Найпопулярніший патерн за сесію.
  static HapticPattern? getMostUsedPattern() {
    if (_log.isEmpty) return null;
    final counts = <HapticPattern, int>{};
    for (final entry in _log) {
      counts[entry.pattern] = (counts[entry.pattern] ?? 0) + 1;
    }
    HapticPattern? top;
    int maxCount = 0;
    counts.forEach((pattern, count) {
      if (count > maxCount) {
        maxCount = count;
        top = pattern;
      }
    });
    return top;
  }

  /// Найменш використовуваний патерн.
  static HapticPattern? getLeastUsedPattern() {
    if (_log.isEmpty) return null;
    final counts = <HapticPattern, int>{};
    for (final entry in _log) {
      counts[entry.pattern] = (counts[entry.pattern] ?? 0) + 1;
    }
    final unused = HapticPattern.values
        .where((p) => !counts.containsKey(p))
        .toList();
    if (unused.isNotEmpty) return unused.first;
    HapticPattern? bottom;
    int minCount = double.maxFinite.toInt();
    counts.forEach((pattern, count) {
      if (count < minCount) {
        minCount = count;
        bottom = pattern;
      }
    });
    return bottom;
  }

  /// Кількість викликів за останню хвилину.
  static int getTriggersInLastMinute() {
    final cutoff = DateTime.now().subtract(const Duration(minutes: 1));
    return _log.where((e) => e.timestamp.isAfter(cutoff)).length;
  }

  /// Кількість викликів за останні N хвилин.
  static int getTriggersInLast({int minutes = 5}) {
    final cutoff = DateTime.now().subtract(Duration(minutes: minutes));
    return _log.where((e) => e.timestamp.isAfter(cutoff)).length;
  }

  /// Кількість викликів за останню годину.
  static int getTriggersLastHour() {
    final cutoff = DateTime.now().subtract(const Duration(hours: 1));
    return _log.where((e) => e.timestamp.isAfter(cutoff)).length;
  }

  /// Кількість викликів за останні 24 години.
  static int getTriggersLast24Hours() {
    final cutoff = DateTime.now().subtract(const Duration(hours: 24));
    return _log.where((e) => e.timestamp.isAfter(cutoff)).length;
  }

  /// Кількість викликів конкретного патерну.
  static int getPatternTriggerCount(HapticPattern pattern) {
    return _log.where((e) => e.pattern == pattern).length;
  }

  /// Чи патерн використовувався принаймні [count] разів.
  static bool wasPatternUsedAtLeast(HapticPattern pattern, int count) {
    return _log.where((e) => e.pattern == pattern).length >= count;
  }

  /// Середня частота викликів за хвилину.
  static double getTriggersPerMinute() {
    if (_log.length < 2) return 0.0;
    final minutes = _log.last.timestamp.difference(_log.first.timestamp).inMinutes;
    if (minutes <= 0) return 0.0;
    return _log.length / minutes;
  }

  /// Середній інтервал між викликами (ms).
  static int? getAverageIntervalMs() {
    if (_log.length < 2) return null;
    int totalMs = 0;
    for (int i = 1; i < _log.length; i++) {
      totalMs +=
          _log[i].timestamp.difference(_log[i - 1].timestamp).inMilliseconds;
    }
    return (totalMs / (_log.length - 1)).round();
  }

  /// Частота використання за категоріями.
  static Map<String, int> getCategoryUsage() {
    final result = <String, int>{};
    for (final entry in _log) {
      final cat = getPatternCategory(entry.pattern);
      result[cat] = (result[cat] ?? 0) + 1;
    }
    return result;
  }

  /// Чи використовувався гейміфікований патерн.
  static bool get hasGamificationUsage {
    const set = {
      HapticPattern.coinDrop, HapticPattern.levelUp, HapticPattern.badgeUnlock,
      HapticPattern.streakFire, HapticPattern.frostCrack, HapticPattern.confetti,
      HapticPattern.goalAchieved,
    };
    return _log.any((e) => set.contains(e.pattern));
  }

  /// Відсоток гейміфікованих патернів.
  static double get gamificationRatio {
    if (_log.isEmpty) return 0.0;
    const set = {
      HapticPattern.coinDrop, HapticPattern.levelUp, HapticPattern.badgeUnlock,
      HapticPattern.streakFire, HapticPattern.frostCrack, HapticPattern.confetti,
      HapticPattern.goalAchieved,
    };
    return _log.where((e) => set.contains(e.pattern)).length / _log.length;
  }

  /// Розподіл викликів по годинах доби.
  static Map<int, int> getHourlyDistribution() {
    final distribution = <int, int>{};
    for (final entry in _log) {
      final hour = entry.timestamp.hour;
      distribution[hour] = (distribution[hour] ?? 0) + 1;
    }
    return distribution;
  }

  /// Година з найбільшою активністю.
  static int? getPeakHour() {
    final dist = getHourlyDistribution();
    if (dist.isEmpty) return null;
    int peakHour = 0;
    int peakCount = 0;
    dist.forEach((hour, count) {
      if (count > peakCount) {
        peakCount = count;
        peakHour = hour;
      }
    });
    return peakHour;
  }

  /// Тривалість сесії.
  static Duration getSessionDuration() {
    if (_log.length < 2) return Duration.zero;
    return _log.last.timestamp.difference(_log.first.timestamp);
  }

  /// Опис частоти використання (для UI).
  static String getFrequencyDescription() {
    final tpm = getTriggersPerMinute();
    if (tpm < 0.5) return 'Майже не використовується';
    if (tpm < 2) return 'Помірне використання';
    if (tpm < 5) return 'Часте використання';
    return 'Дуже часте використання';
  }

  // ─── Батарея ───────────────────────────────────────────────────────

  /// Споживання батареї за патерн (умовні одиниці 1–12).
  static int estimateBatteryCost(HapticPattern pattern) {
    switch (pattern) {
      case HapticPattern.keystroke:
      case HapticPattern.selection:
      case HapticPattern.switchToggle:
      case HapticPattern.info:
        return 1;
      case HapticPattern.light:
      case HapticPattern.cancel:
      case HapticPattern.dragStart:
        return 2;
      case HapticPattern.medium:
      case HapticPattern.pullToRefresh:
      case HapticPattern.cardStretch:
      case HapticPattern.doubleTap:
      case HapticPattern.undo:
      case HapticPattern.deleteSwipe:
      case HapticPattern.dropComplete:
      case HapticPattern.longPress:
        return 3;
      case HapticPattern.heavy:
      case HapticPattern.success:
      case HapticPattern.error:
      case HapticPattern.warning:
        return 5;
      case HapticPattern.coinDrop:
      case HapticPattern.streakFire:
        return 7;
      case HapticPattern.levelUp:
      case HapticPattern.badgeUnlock:
      case HapticPattern.frostCrack:
      case HapticPattern.goalAchieved:
        return 10;
      case HapticPattern.confetti:
      case HapticPattern.onboardingComplete:
      case HapticPattern.featureUnlock:
        return 12;
      case HapticPattern.deleteConfirm:
        return 8;
    }
  }

  /// Загальне споживання батареї за сесію.
  static int getSessionBatteryCost() {
    return _log.fold<int>(0, (sum, e) => sum + estimateBatteryCost(e.pattern));
  }

  /// Порада щодо енергозбереження.
  static String getBatteryAdvice() {
    final cost = getSessionBatteryCost();
    if (cost < 20) return 'Тактильний зв\'язок майже не впливає на батарею.';
    if (cost < 50) return 'Помірне використання тактильного зв\'язку.';
    if (cost < 100) return 'Тактильний зв\'язок споживає помірну кількість батареї.';
    return 'Знижте інтенсивність — тактильний зв\'язок споживає багато енергії!';
  }

  // ─── Профілі ───────────────────────────────────────────────────────

  /// Повертає список доступних профілів.
  static List<String> getAvailableProfiles() =>
      _intensityProfiles.keys.toList();

  /// Застосовує профіль налаштувань за назвою.
  static bool applyProfile(String profileName) {
    final intensity = _intensityProfiles[profileName];
    if (intensity == null) {
      debugPrint('[HapticService] Unknown profile: $profileName');
      return false;
    }
    setIntensity(intensity);
    return true;
  }

  /// Опис профілю українською.
  static String getProfileDescription(String profileName) {
    switch (profileName) {
      case 'minimal':
        return 'Мінімальний — лише найважливіші події';
      case 'balanced':
        return 'Збалансований — легкий відгук на базові дії';
      case 'default':
        return 'Стандартний — рекомендований для більшості';
      case 'enhanced':
        return 'Посилений — сильний відгук на всі події';
      case 'max':
        return 'Максимальний — найінтенсивніший відгук';
      default:
        return 'Невідомий профіль';
    }
  }

  /// Порівнює два профілі.
  static Map<String, dynamic> compareProfiles(
    String profile1Name,
    String profile2Name,
  ) {
    final i1 = _intensityProfiles[profile1Name];
    final i2 = _intensityProfiles[profile2Name];
    if (i1 == null || i2 == null) {
      return {'error': 'Один з профілів не знайдено'};
    }
    final diff = i2.index - i1.index;
    return {
      'profile1': profile1Name,
      'profile1Intensity': i1.name,
      'profile2': profile2Name,
      'profile2Intensity': i2.name,
      'difference': diff > 0 ? '+$diff рівнів' : diff < 0 ? '$diff рівнів' : 'Однаково',
    };
  }

  // ─── Категорії ─────────────────────────────────────────────────────

  /// Патерни за категорією.
  static List<HapticPattern> getPatternsByCategory(String category) {
    return List.unmodifiable(_patternCategories[category] ?? []);
  }

  /// Назви всіх категорій.
  static List<String> getPatternCategories() => _patternCategories.keys.toList();

  /// Категорія патерну.
  static String getPatternCategory(HapticPattern pattern) {
    for (final entry in _patternCategories.entries) {
      if (entry.value.contains(pattern)) return entry.key;
    }
    return 'unknown';
  }

  /// Виконує всі патерни категорії послідовно.
  static Future<void> triggerCategory(String category) async {
    final patterns = _patternCategories[category];
    if (patterns == null || patterns.isEmpty) return;
    for (final p in patterns) {
      await trigger(p);
      await Future<void>.delayed(const Duration(milliseconds: 20));
    }
  }

  // ─── Описи та допоміжні методи ────────────────────────────────────

  /// Кількість доступних патернів.
  static int get patternCount => HapticPattern.values.length;

  /// Список усіх назв патернів.
  static List<String> getAllPatternNames() =>
      HapticPattern.values.map((p) => p.name).toList();

  /// Чи патерн існує за назвою.
  static bool isPatternValid(String patternName) =>
      HapticPattern.values.any((p) => p.name == patternName);

  /// Виконує патерн за назвою (рядком).
  static Future<bool> triggerByName(String patternName) async {
    final pattern = HapticPattern.values
        .where((p) => p.name == patternName)
        .firstOrNull;
    if (pattern == null) return false;
    await trigger(pattern);
    return true;
  }

  /// Опис патерна українською.
  static String getPatternDescription(HapticPattern pattern) {
    return switch (pattern) {
      HapticPattern.light => 'Легке натискання кнопки',
      HapticPattern.medium => 'Середнє підтвердження дії',
      HapticPattern.heavy => 'Сильне натискання — важливі події',
      HapticPattern.selection => 'Вибір елемента (toggle, tabs)',
      HapticPattern.success => 'Успішна дія або досягнення',
      HapticPattern.error => 'Помилка або невдала спроба',
      HapticPattern.coinDrop => 'Додавання монет у скарбничку',
      HapticPattern.levelUp => 'Підвищення рівня — сходовий патерн',
      HapticPattern.badgeUnlock => 'Розблокування бейджу — потрійний імпульс',
      HapticPattern.streakFire => 'Активна серія — наростаючий патерн',
      HapticPattern.frostCrack => 'Заморожування серії — тріщина льоду',
      HapticPattern.confetti => 'Конфетті — швидкі черги імпульсів',
      HapticPattern.switchToggle => 'Перемикач — дуже легкий клік',
      HapticPattern.pullToRefresh => 'Потягни для оновлення',
      HapticPattern.deleteSwipe => 'Видалення свайпом',
      HapticPattern.cardStretch => 'Розтягування картки',
      HapticPattern.goalAchieved => 'Досягнення цілі — святковий патерн',
      HapticPattern.warning => 'Попередження — подвійний легкий імпульс',
      HapticPattern.info => 'Інформаційне повідомлення',
      HapticPattern.cancel => 'Скасування дії',
      HapticPattern.dragStart => 'Початок перетягування',
      HapticPattern.dropComplete => 'Завершення перетягування',
      HapticPattern.keystroke => 'Натискання клавіші — делікатний',
      HapticPattern.longPress => 'Довге натискання — наростаючий',
      HapticPattern.doubleTap => 'Подвійне натискання',
      HapticPattern.undo => 'Скасування останньої дії',
      HapticPattern.deleteConfirm => 'Підтвердження видалення',
      HapticPattern.onboardingComplete => 'Завершення онбордингу',
      HapticPattern.featureUnlock => 'Розблокування функції',
    };
  }

  /// Опис інтенсивності українською.
  static String getIntensityLabel(HapticIntensity intensity) =>
      _getIntensityLabel(intensity);

  /// Опис інтенсивності англійською.
  static String getIntensityLabelEN(HapticIntensity intensity) {
    return switch (intensity) {
      HapticIntensity.subtle => 'subtle',
      HapticIntensity.light => 'light',
      HapticIntensity.medium => 'medium',
      HapticIntensity.heavy => 'heavy',
      HapticIntensity.extreme => 'extreme',
    };
  }

  // ─── Оптимізація ───────────────────────────────────────────────────

  /// Поради щодо оптимізації використання haptic.
  static List<String> getOptimizationTips() {
    final tips = <String>[];
    if (_log.length < 10) {
      tips.add('Недостатньо даних для аналізу (менше 10 викликів).');
      return tips;
    }
    final lastMinuteCount = getTriggersInLastMinute();
    if (lastMinuteCount > 20) {
      tips.add('Високий трафік: $lastMinuteCount викликів за хвилину.');
    }
    final mostUsed = getMostUsedPattern();
    if (mostUsed != null) {
      final count = getPatternTriggerCount(mostUsed);
      final pct = (count / _log.length * 100).toStringAsFixed(0);
      tips.add('Найпопулярніший: ${mostUsed.name} ($pct%).');
    }
    final avg = getAveragePatternDuration();
    if (avg > 200) {
      tips.add('Середня тривалість: ${avg.toStringAsFixed(0)}ms — деякі занадто довгі.');
    }
    if (_intensity == HapticIntensity.extreme) {
      tips.add('Екстремальна інтенсивність — батарея швидше розряджається.');
    }
    if (!_reduceMotion && _totalTriggers > 100) {
      tips.add('Розгляньте режим зменшення руху для чутливих користувачів.');
    }
    return tips;
  }

  // ─── Експорт ───────────────────────────────────────────────────────

  /// Конфігурація для серіалізації.
  static Map<String, dynamic> saveConfig() => {
        'enabled': _enabled,
        'intensity': _intensity.name,
        'reduceMotion': _reduceMotion,
        'batterySaverMode': _batterySaverMode,
        'globalMultiplier': _globalIntensityMultiplier,
        'globalTag': _globalTag,
        'profile': _intensityProfiles.entries
            .where((e) => e.value == _intensity)
            .map((e) => e.key)
            .firstOrNull,
        'patternConfigs': _patternConfigs.map(
          (k, v) => MapEntry(k.name, v.toMap()),
        ),
      };

  /// Відновлює конфігурацію з мапи.
  static void loadConfig(Map<String, dynamic> config) {
    if (config['enabled'] is bool) _enabled = config['enabled'] as bool;
    if (config['reduceMotion'] is bool) {
      _reduceMotion = config['reduceMotion'] as bool;
    }
    if (config['batterySaverMode'] is bool) {
      _batterySaverMode = config['batterySaverMode'] as bool;
    }
    if (config['intensity'] is String) {
      final intensity = HapticIntensity.values
          .where((i) => i.name == config['intensity'] as String)
          .firstOrNull;
      if (intensity != null) _intensity = intensity;
    }
    if (config['globalMultiplier'] is num) {
      _globalIntensityMultiplier =
          (config['globalMultiplier'] as num).toDouble().clamp(0.0, 2.0);
    }
    if (config['globalTag'] is String?) {
      _globalTag = config['globalTag'] as String?;
    }
    if (config['profile'] is String) {
      applyProfile(config['profile'] as String);
    }
    if (config['patternConfigs'] is Map) {
      final configs = config['patternConfigs'] as Map;
      for (final entry in configs.entries) {
        final pattern = HapticPattern.values
            .where((p) => p.name == entry.key)
            .firstOrNull;
        if (pattern != null && entry.value is Map) {
          _patternConfigs[pattern] =
              HapticIntensityConfig.fromMap(entry.value as Map<String, dynamic>);
        }
      }
    }
  }

  /// Експортує журнал у список мап.
  static List<Map<String, dynamic>> exportLog({int limit = 0}) {
    final entries = limit > 0
        ? _log.take(limit).toList()
        : List<HapticLogEntry>.from(_log);
    return entries.map((e) => e.toMap()).toList();
  }

  /// Експортує журнал у форматі CSV.
  static String exportLogAsCsv() {
    final buffer = StringBuffer();
    buffer.writeln('timestamp,pattern,duration_ms,intensity,tag');
    for (final entry in _log) {
      buffer.writeln(
        '${entry.timestamp.toIso8601String()},'
        '${entry.pattern.name},'
        '${entry.duration.inMilliseconds},'
        '${entry.intensity.name},'
        '${entry.tag ?? ""}',
      );
    }
    return buffer.toString();
  }

  /// Повна статистика для експорту.
  static Map<String, dynamic> exportData() {
    return {
      'serviceStatus': {
        'enabled': _enabled,
        'platformSupported': _platformSupported,
        'reduceMotion': _reduceMotion,
        'batterySaverMode': _batterySaverMode,
        'intensity': _intensity.name,
        'globalMultiplier': _globalIntensityMultiplier,
        'totalTriggers': _totalTriggers,
        'capabilities': _capabilities.toMap(),
      },
      'statistics': getStatistics(),
      'log': _log.map((e) => e.toMap()).toList(),
      'logSize': _log.length,
      'maxLogSize': _maxLogSize,
      'exportTimestamp': DateTime.now().toIso8601String(),
    };
  }

  /// Коротка версія статистики для UI-віджетів.
  static Map<String, dynamic> getWidgetData() {
    return {
      'isEnabled': isEnabled,
      'intensity': _intensity.name,
      'totalTriggers': _totalTriggers,
      'recentLogCount': recentLog.length,
      'mostUsedPattern': getMostUsedPattern()?.name,
      'batterySaver': _batterySaverMode,
      'healthStatus': healthStatus,
    };
  }

  /// Коротка версія статистики.
  static String exportStatisticsSummary() {
    final avgDuration = getAveragePatternDuration();
    final totalTime = getTotalVibrationTime();
    return 'HapticService Stats | '
        'Triggers: $_totalTriggers | '
        'Log: ${_log.length}/$_maxLogSize | '
        'Avg: ${avgDuration.toStringAsFixed(1)}ms | '
        'Total: ${totalTime.inMilliseconds}ms | '
        'Enabled: $isEnabled | '
        'Intensity: ${_intensity.name}';
  }

  /// Читабельна статистика.
  static String getReadableStatistics() {
    final stats = getStatistics();
    final patternCounts = stats['patternCounts'] as Map<String, dynamic>;
    final buffer = StringBuffer();
    buffer.writeln('=== Haptic Service Statistics ===');
    buffer.writeln('Total triggers: ${stats['totalTriggers']}');
    buffer.writeln('Enabled: ${stats['enabled']}');
    buffer.writeln('Platform: ${stats['platformSupported']}');
    buffer.writeln('Reduce motion: ${stats['reduceMotion']}');
    buffer.writeln('Log size: ${stats['logSize']}');
    buffer.writeln('Battery saver: ${stats['batterySaverMode']}');
    buffer.writeln('');
    buffer.writeln('Pattern usage:');
    final sorted = patternCounts.entries.toList()
      ..sort((a, b) => (b.value as int).compareTo(a.value as int));
    for (final entry in sorted) {
      buffer.writeln('  ${entry.key}: ${entry.value}');
    }
    return buffer.toString();
  }

  /// Дані для crash-репорту.
  static Map<String, dynamic> getCrashReportData() {
    return {
      'enabled': _enabled,
      'platformSupported': _platformSupported,
      'reduceMotion': _reduceMotion,
      'intensity': _intensity.name,
      'totalTriggers': _totalTriggers,
      'logSize': _log.length,
      'triggersPerMinute': getTriggersPerMinute(),
      'frequencyHealthy': isFrequencyHealthy(),
      'sessionBatteryCost': getSessionBatteryCost(),
      'mostUsedPattern': getMostUsedPattern()?.name,
      'healthStatus': healthStatus,
    };
  }

  /// Повний аудиторський звіт.
  static Map<String, dynamic> generateFullAuditReport() {
    final categoryUsage = getCategoryUsage();
    final hourlyDist = getHourlyDistribution();
    final peakHour = getPeakHour();

    int peakMinuteCount = 0;
    if (_log.length >= 2) {
      for (int i = 0; i < _log.length - 1; i++) {
        int count = 1;
        final windowStart = _log[i].timestamp;
        for (int j = i + 1; j < _log.length; j++) {
          if (_log[j].timestamp.difference(windowStart).inSeconds <= 60) {
            count++;
          } else {
            break;
          }
        }
        if (count > peakMinuteCount) peakMinuteCount = count;
      }
    }

    return {
      'summary': {
        'totalTriggers': _totalTriggers,
        'sessionDuration': getSessionDuration().inMinutes,
        'averageDurationMs': getAveragePatternDuration().toStringAsFixed(1),
        'medianDurationMs': getMedianPatternDuration().toStringAsFixed(1),
        'totalVibrationMs': getTotalVibrationTime().inMilliseconds,
        'triggersPerMinute': getTriggersPerMinute().toStringAsFixed(2),
        'frequencyHealthy': isFrequencyHealthy(),
      },
      'categories': categoryUsage,
      'hourlyDistribution': hourlyDist,
      'peakHour': peakHour,
      'peakMinuteCount': peakMinuteCount,
      'battery': {
        'sessionCost': getSessionBatteryCost(),
        'advice': getBatteryAdvice(),
      },
      'health': {
        'status': healthStatus,
        'issues': performHealthCheck(),
      },
      'recommendations': getOptimizationTips(),
    };
  }

  /// Ефективність використання (0.0–1.0).
  static double calculateUsageEfficiency() {
    if (_log.length < 5) return 0.0;
    final uniquePatterns = _log.map((e) => e.pattern).toSet().length;
    final diversityScore = uniquePatterns / HapticPattern.values.length;
    final tpm = getTriggersPerMinute();
    double frequencyScore;
    if (tpm < 0.5) {
      frequencyScore = 0.3;
    } else if (tpm <= 5) {
      frequencyScore = 1.0;
    } else if (tpm <= 10) {
      frequencyScore = 0.7;
    } else {
      frequencyScore = 0.3;
    }
    final categoryDiversity =
        getCategoryUsage().length / _patternCategories.length;
    return (diversityScore * 0.4 + frequencyScore * 0.35 + categoryDiversity * 0.25)
        .clamp(0.0, 1.0);
  }

  /// Текстова оцінка ефективності.
  static String getEfficiencyLabel() {
    final eff = calculateUsageEfficiency();
    if (eff >= 0.8) return 'Відмінна ефективність';
    if (eff >= 0.6) return 'Хороша ефективність';
    if (eff >= 0.4) return 'Середня ефективність';
    if (eff >= 0.2) return 'Низька ефективність';
    return 'Сервіс майже не використовується';
  }

  /// Звіт про доступність.
  static Map<String, dynamic> generateAccessibilityReport() {
    final recommendations = <String>[];
    if (!_platformSupported) {
      recommendations.add('Вібрація не підтримується на цьому пристрої');
    }
    if (_reduceMotion) {
      recommendations.add('Режим зменшення руху увімкнено');
    }
    if (_intensity == HapticIntensity.extreme) {
      recommendations.add('Екстремальна інтенсивність може бути незручна');
    }
    if (_batterySaverMode) {
      recommendations.add('Енергозбереження обмежує частоту');
    }
    return {
      'reduceMotion': _reduceMotion,
      'intensity': _intensity.name,
      'platformSupported': _platformSupported,
      'capabilities': _capabilities.toMap(),
      'batterySaver': _batterySaverMode,
      'recommendations': recommendations,
      'isAccessible': _platformSupported && !_reduceMotion,
    };
  }

  // ─── Приватні методи ──────────────────────────────────────────────

  /// Перевіряє rate limit.
  static bool _checkRateLimit() {
    final now = DateTime.now();
    final elapsed = _lastTriggerTime != null
        ? now.difference(_lastTriggerTime!)
        : const Duration(seconds: 1);
    if (elapsed < _minInterval) {
      _rapidCallCount++;
      return _rapidCallCount <= _maxRapidCalls;
    }
    _rapidCallCount = 0;
    _lastTriggerTime = now;
    return true;
  }

  /// Перевіряє, чи патерн можна виконати в режимі енергозбереження.
  static bool _shouldExecuteInBatterySaver(HapticPattern pattern) {
    final category = getPatternCategory(pattern);
    if (category == 'basic' || category == 'feedback') return true;
    return _totalTriggers % 2 == 0;
  }

  /// Виконує вібрацію за інтенсивністю.
  static Future<void> _executeIntensityStep(HapticIntensity intensity) async {
    switch (intensity) {
      case HapticIntensity.subtle:
        await HapticFeedback.selectionClick();
      case HapticIntensity.light:
        await HapticFeedback.lightImpact();
      case HapticIntensity.medium:
        await HapticFeedback.mediumImpact();
      case HapticIntensity.heavy:
      case HapticIntensity.extreme:
        await HapticFeedback.heavyImpact();
    }
  }

  /// Множник пауз для інтенсивності.
  static double _pauseMultiplierForIntensity(HapticIntensity intensity) {
    return switch (intensity) {
      HapticIntensity.subtle => 1.5,
      HapticIntensity.light => 1.2,
      HapticIntensity.medium => 1.0,
      HapticIntensity.heavy => 0.8,
      HapticIntensity.extreme => 0.6,
    };
  }

  /// Множник імпульсів для інтенсивності.
  static double _impulseMultiplierForIntensity(HapticIntensity intensity) {
    return switch (intensity) {
      HapticIntensity.subtle => 0.5,
      HapticIntensity.light => 0.75,
      HapticIntensity.medium => 1.0,
      HapticIntensity.heavy => 1.25,
      HapticIntensity.extreme => 1.5,
    };
  }

  /// Опис інтенсивності українською (приватний).
  static String _getIntensityLabel(HapticIntensity intensity) {
    return switch (intensity) {
      HapticIntensity.subtle => 'дуже легка',
      HapticIntensity.light => 'легка',
      HapticIntensity.medium => 'середня',
      HapticIntensity.heavy => 'сильна',
      HapticIntensity.extreme => 'екстремальна',
    };
  }

  /// Виконує патерн з логуванням.
  static Future<void> _executeWithLogging(
    HapticPattern pattern,
    Future<void> Function() action,
  ) async {
    if (_isTriggering) return;
    _isTriggering = true;
    final stopwatch = Stopwatch()..start();
    try {
      await action();
    } catch (_) {
      // Тихо ігноруємо помилки вібрації
    } finally {
      stopwatch.stop();
      _isTriggering = false;
      _totalTriggers++;
      _addLogEntry(
        pattern: pattern,
        duration: stopwatch.elapsed,
        intensity: _intensity,
      );
    }
  }

  /// Додає запис у журнал з обмеженням розміру.
  static void _addLogEntry({
    required HapticPattern pattern,
    required Duration duration,
    required HapticIntensity intensity,
  }) {
    if (_log.length >= _maxLogSize) {
      _log.removeAt(0);
    }
    _log.add(HapticLogEntry(
      pattern: pattern,
      timestamp: DateTime.now(),
      duration: duration,
      intensity: intensity,
      tag: _globalTag,
    ));
  }
}
