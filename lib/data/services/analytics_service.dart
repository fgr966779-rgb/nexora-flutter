import 'dart:convert';
import '../../data/models/goal_model.dart';
import '../../data/models/transaction_model.dart';
import '../../core/constants/app_enums.dart';

/// Типи подій аналітики.
///
/// Використовується для категоризації всіх подій, що відстежуються
/// системою аналітики. Кожен тип має відповідний рядок для серіалізації
/// та логування.
enum AnalyticsEventType {
  /// Перегляд екрана.
  screenView,

  /// Натискання кнопки.
  buttonTap,

  /// Здійснення внеску.
  deposit,

  /// Перегляд цілі.
  goalView,

  /// Створення цілі.
  goalCreated,

  /// Досягнення цілі.
  goalCompleted,

  /// Прогрес серії.
  streakUpdate,

  /// Прийняття челенджу.
  challengeAccepted,

  /// Завершення челенджу.
  challengeCompleted,

  /// Провал челенджу.
  challengeFailed,

  /// Перехід на новий рівень.
  levelUp,

  /// Розблокування бейджу.
  badgeUnlocked,

  /// Покупка в магазині.
  shopPurchase,

  /// Початок онбордингу.
  onboardingStarted,

  /// Завершення онбордингу.
  onboardingCompleted,

  /// Скасування останнього внеску.
  depositUndo,

  /// Крок онбордингу завершено.
  onboardingStepCompleted,

  /// Розморожування цілі.
  goalUnfreezed,

  /// Щоденний вхід.
  dailyLogin,

  /// Редагування профілю.
  profileEdit,

  /// Зміна налаштувань.
  settingsChanged,

  /// Використання пошуку.
  searchUsed,

  /// Поділитися контентом.
  shareContent,

  /// Перегляд інвентарю.
  inventoryViewed,

  /// Скасовано автоплатіж.
  autopayCancelled,

  /// Створено автоплатіж.
  autopayCreated,

  /// Перегляд магазину.
  shopViewed,

  /// Переглед лідерборду.
  leaderboardViewed,

  /// Відкриття екрану статистики.
  statsViewed,
}

/// Запис аналітичної події.
///
/// Незмінний об'єкт, що містить інформацію про одну подію аналітики.
/// Створюється через [AnalyticsEventBuilder] для зручного конструювання.
/// Може бути серіалізований у JSON для експорту.
class AnalyticsEvent {
  /// Тип події.
  final AnalyticsEventType type;

  /// Назва події.
  final String name;

  /// Додаткові параметри.
  final Map<String, dynamic> parameters;

  /// Час події.
  final DateTime timestamp;

  /// Унікальний ідентифікатор події (для трасування).
  final String? eventId;

  /// Пріоритет події (чим вище, тим важливіша).
  final int priority;

  /// Тег сесії для групування подій.
  final String? sessionTag;

  const AnalyticsEvent({
    required this.type,
    required this.name,
    this.parameters = const {},
    required this.timestamp,
    this.eventId,
    this.priority = 0,
    this.sessionTag,
  });

  /// Серіалізує подію у формат JSON для експорту.
  ///
  /// Повертає карту з ключами: type, name, parameters, timestamp, eventId, priority.
  Map<String, dynamic> toJson() {
    return {
      'type': type.name,
      'name': name,
      'parameters': parameters,
      'timestamp': timestamp.toIso8601String(),
      if (eventId != null) 'eventId': eventId,
      'priority': priority,
      if (sessionTag != null) 'sessionTag': sessionTag,
    };
  }

  /// Створює копію події з додатковими параметрами.
  ///
  /// Корисно для додавання контексту до існуючої події
  /// без повторного створення об'єкта.
  AnalyticsEvent copyWith({
    Map<String, dynamic>? extraParameters,
    String? sessionTag,
    int? priority,
  }) {
    return AnalyticsEvent(
      type: type,
      name: name,
      parameters: extraParameters != null
          ? {...parameters, ...extraParameters}
          : parameters,
      timestamp: timestamp,
      eventId: eventId,
      priority: priority ?? this.priority,
      sessionTag: sessionTag ?? this.sessionTag,
    );
  }

  @override
  String toString() => '[${type.name}] $name';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AnalyticsEvent &&
          runtimeType == other.runtimeType &&
          type == other.type &&
          name == other.name &&
          timestamp == other.timestamp;

  @override
  int get hashCode => Object.hash(type, name, timestamp);
}

/// Створення аналітичної події.
///
/// Дозволяє покроково конструювати об'єкт [AnalyticsEvent]
/// через зручний builder-патерн. Підтримує ланцюжування викликів
/// для додавання параметрів до події.
///
/// Приклад використання:
/// ```dart
/// final event = AnalyticsEventBuilder(AnalyticsEventType.deposit, 'deposit_made')
///     .withAmount(150.0)
///     .withId('goal-123')
///     .withParam('category', 'manual')
///     .build();
/// ```
class AnalyticsEventBuilder {
  /// Тип події.
  final AnalyticsEventType type;

  /// Назва події.
  final String name;

  /// Додаткові параметри (внутрішнє зберігання).
  final Map<String, dynamic> _params = {};

  /// Пріоритет події.
  int _priority = 0;

  /// Тег сесії для групування.
  String? _sessionTag;

  /// Створює builder для вказаного типу та назви події.
  ///
  /// [type] — тип події з [AnalyticsEventType].
  /// [name] — людська назва події для логування.
  AnalyticsEventBuilder(this.type, this.name);

  /// Додає довільний параметр до події.
  ///
  /// [key] — назва параметра.
  /// [value] — значення (може бути будь-якого типу).
  AnalyticsEventBuilder withParam(String key, dynamic value) {
    _params[key] = value;
    return this;
  }

  /// Додає суму до події (ключ 'amount').
  ///
  /// Зручно для подій, пов'язаних з фінансами.
  AnalyticsEventBuilder withAmount(double amount) {
    _params['amount'] = amount;
    return this;
  }

  /// Додає ID об'єкта до події (ключ 'id').
  ///
  /// Зручно для прив'язки події до конкретної цілі, транзакції тощо.
  AnalyticsEventBuilder withId(String id) {
    _params['id'] = id;
    return this;
  }

  /// Додає категорію до події (ключ 'category').
  ///
  AnalyticsEventBuilder withCategory(String category) {
    _params['category'] = category;
    return this;
  }

  /// Додає кількість до події (ключ 'count').
  ///
  AnalyticsEventBuilder withCount(int count) {
    _params['count'] = count;
    return this;
  }

  /// Додає тривалість до події у мілісекундах (ключ 'duration_ms').
  ///
  AnalyticsEventBuilder withDurationMs(int durationMs) {
    _params['duration_ms'] = durationMs;
    return this;
  }

  /// Встановлює пріоритет події.
  ///
  /// Чим вище значення, тим важливіша подія.
  AnalyticsEventBuilder withPriority(int priority) {
    _priority = priority;
    return this;
  }

  /// Встановлює тег сесії для групування подій.
  ///
  /// Дозволяє групувати події за логічною сесією
  /// (наприклад, 'onboarding_step_2', 'deposit_flow').
  AnalyticsEventBuilder withSessionTag(String tag) {
    _sessionTag = tag;
    return this;
  }

  /// Створює фінальний об'єкт події [AnalyticsEvent].
  ///
  /// Параметри стають незмінними (unmodifiable) для безпеки.
  AnalyticsEvent build() {
    return AnalyticsEvent(
      type: type,
      name: name,
      parameters: Map.unmodifiable(_params),
      timestamp: DateTime.now(),
      priority: _priority,
      sessionTag: _sessionTag,
    );
  }
}

/// Метрики залученості користувача.
///
/// Зберігає агреговану статистику про використання додатку:
/// кількість сесій, тривалість, найчастіші екрани тощо.
/// Оновлюється автоматично при викликах методів [AnalyticsEngine].
class EngagementMetrics {
  /// Загальна кількість сесій.
  int totalSessions = 0;

  /// Тривалість поточної сесії (секунди).
  int currentSessionDuration = 0;

  /// Середня тривалість сесії (секунди).
  double averageSessionDuration = 0;

  /// Кількість сесій за цей тиждень.
  int weeklySessions = 0;

  /// Кількість сесій за цей місяць.
  int monthlySessions = 0;

  /// Найчастіший екран.
  String mostVisitedScreen = '';

  /// Кількість створених цілей.
  int goalsCreated = 0;

  /// Кількість завершених цілей.
  int goalsCompleted = 0;

  /// Загальна кількість внесків.
  int totalDeposits = 0;

  /// Загальна сума внесків.
  double totalDepositAmount = 0;

  /// Кількість скасувань внесків.
  int totalDepositsUndone = 0;

  /// Кількість виконаних челенджів.
  int challengesCompleted = 0;

  /// Кількість провалених челенджів.
  int challengesFailed = 0;

  /// Загальна кількість отриманих XP.
  int totalXpEarned = 0;

  /// Загальна кількість отриманих монет.
  int totalCoinsEarned = 0;

  /// Кількість розблокованих бейджів.
  int badgesUnlocked = 0;

  /// Кількість підвищень рівня.
  int levelUps = 0;

  /// Кількість зроблених покупок у магазині.
  int shopPurchases = 0;

  /// Дата першої сесії користувача.
  DateTime? firstSessionDate;

  /// Дата останньої сесії користувача.
  DateTime? lastSessionDate;

  /// Серіалізує метрики у формат JSON.
  ///
  /// Повертає карту з усіма полями класу.
  Map<String, dynamic> toJson() {
    return {
      'totalSessions': totalSessions,
      'currentSessionDuration': currentSessionDuration,
      'averageSessionDuration': averageSessionDuration,
      'weeklySessions': weeklySessions,
      'monthlySessions': monthlySessions,
      'mostVisitedScreen': mostVisitedScreen,
      'goalsCreated': goalsCreated,
      'goalsCompleted': goalsCompleted,
      'totalDeposits': totalDeposits,
      'totalDepositAmount': totalDepositAmount,
      'totalDepositsUndone': totalDepositsUndone,
      'challengesCompleted': challengesCompleted,
      'challengesFailed': challengesFailed,
      'totalXpEarned': totalXpEarned,
      'totalCoinsEarned': totalCoinsEarned,
      'badgesUnlocked': badgesUnlocked,
      'levelUps': levelUps,
      'shopPurchases': shopPurchases,
      if (firstSessionDate != null) 'firstSessionDate': firstSessionDate!.toIso8601String(),
      if (lastSessionDate != null) 'lastSessionDate': lastSessionDate!.toIso8601String(),
    };
  }

  /// Обчислює коефіцієнт утримання користувача (Retention).
  ///
  /// Базується на порівнянні кількості сесій цього тижня
  /// з кількістю сесій минулого тижня.
  double computeRetentionRate({required int lastWeekSessions}) {
    if (lastWeekSessions == 0) return weeklySessions > 0 ? 1.0 : 0.0;
    return (weeklySessions / lastWeekSessions).clamp(0.0, 2.0);
  }

  /// Обчислює коефіцієнт конверсії.
  ///
  /// Конверсія — це відношення завершених цілей до створених.
  double get goalConversionRate {
    if (goalsCreated == 0) return 0.0;
    return (goalsCompleted / goalsCreated).clamp(0.0, 1.0);
  }

  /// Обчислює середній внесок за сесію.
  double get averageDepositPerSession {
    if (totalSessions == 0) return 0.0;
    return totalDepositAmount / totalSessions;
  }

  /// Обчислює загальну активність користувача (композитний індекс).
  ///
  /// Враховує внески, челенджі, серії та бейджі.
  double get engagementScore {
    final depositScore = totalDepositAmount / 10000.0;
    final challengeScore = (challengesCompleted + challengesFailed).toDouble();
    final badgeScore = badgesUnlocked.toDouble();
    return (depositScore + challengeScore * 2 + badgeScore * 3).clamp(0.0, 100.0);
  }
}

/// Фільтр для подій аналітики.
///
/// Дозволяє відфільтровувати події за типом, діапазоном часу
/// та пошуковим запитом.
class AnalyticsEventFilter {
  /// Типи подій для включення (null = всі).
  final List<AnalyticsEventType>? eventTypes;

  /// Початок діапазону часу.
  final DateTime? since;

  /// Кінець діапазону часу.
  final DateTime? until;

  /// Пошуковий запит (фільтрує за назвою).
  final String? searchQuery;

  /// Мінімальний пріоритет для включення.
  final int? minPriority;

  /// Тег сесії для включення.
  final String? sessionTag;

  const AnalyticsEventFilter({
    this.eventTypes,
    this.since,
    this.until,
    this.searchQuery,
    this.minPriority,
    this.sessionTag,
  });

  /// Перевіряє, чи подія відповідає фільтру.
  bool matches(AnalyticsEvent event) {
    if (eventTypes != null &&
        !eventTypes.contains(event.type)) {
      return false;
    }
    if (since != null && event.timestamp.isBefore(since!)) {
      return false;
    }
    if (until != null && event.timestamp.isAfter(until!)) {
      return false;
    }
    if (searchQuery != null &&
        !event.name.toLowerCase().contains(searchQuery!.toLowerCase())) {
      return false;
    }
    if (minPriority != null && event.priority < minPriority!) {
      return false;
    }
    if (sessionTag != null && event.sessionTag != sessionTag) {
      return false;
    }
    return true;
  }
}

/// Аналітичний звіт по подіях.
///
/// Згенерований за вказаним періодом. Містить
/// агреговану статистику, найчастіші події та трендові дані.
class AnalyticsReport {
  /// Період звіту (наприклад, '7 днів').
  final String period;

  /// Загальна кількість подій за період.
  final int totalEvents;

  /// Розподіл подій за типом.
  final Map<AnalyticsEventType, int> eventsByType;

  /// Найчастіші події (топ-10).
  final List<String> topEvents;

  /// Дата початку періоду.
  final DateTime periodStart;

  /// Дата кінця періоду.
  final DateTime periodEnd;

  const AnalyticsReport({
    required this.period,
    required this.totalEvents,
    required this.eventsByType,
    required this.topEvents,
    required this.periodStart,
    required this.periodEnd,
  });

  /// Генерує текстовий звіт для логування.
  @override
  String toString() {
    final buffer = StringBuffer();
    buffer.writeln('═══ Analytics Report ($period) ═══');
    buffer.writeln('Period: ${periodStart.toIso8601String()} → ${periodEnd.toIso8601String()}');
    buffer.writeln('Total events: $totalEvents');
    buffer.writeln('Top events:');
    for (final event in topEvents) {
      buffer.writeln('  • $event');
    }
    return buffer.toString();
  }
}

/// Аналітичний рушій інформаційної панелі.
///
/// Визначає настрій панелі (DashboardMood), генерує підказки
/// для користувача та прогнозує дату завершення цілі.
/// Також відстежує події користувача, сесії та складає звіти.
///
/// Приклади використання:
/// ```dart
/// AnalyticsEngine.startSession();
/// AnalyticsEngine.trackScreenView('dashboard');
/// AnalyticsEngine.trackDeposit(150.0, TransactionType.manual);
/// final mood = AnalyticsEngine.determineMood(goal, recent);
/// final suggestion = AnalyticsEngine.generateSuggestion(mood, goal);
/// ```
class AnalyticsEngine {
  /// Створені події (внутрішній буфер).
  static final List<AnalyticsEvent> _eventBuffer = [];

  /// Максимальна кількість подій у буфері.
  static const int _maxBufferSize = 500;

  /// Метрики залученості.
  static final EngagementMetrics _engagement = EngagementMetrics();

  /// Карта екранів з кількістю переглядів.
  static final Map<String, int> _screenViews = {};

  /// Воронка онбордингу — які кроки завершено.
  static final List<String> _onboardingFunnel = [];

  /// Час початку поточної сесії.
  static DateTime? _sessionStartTime;

  /// Кількість сесій за минулий тиждень (для порівняння).
  static int _lastWeekSessions = 0;

  /// Лог дебагу для розробників.
  static final List<String> _debugLog = [];

  // ── Пороги настрою панелі ────────────────────────────────

  /// Кількість транзакцій за 7 днів для статусу «fastProgress».
  static const int _fastProgressThreshold = 5;

  /// Кількість днів без транзакцій для статусу «frozen».
  static const int _frozenDaysThreshold = 5;

  /// Кількість днів без транзакцій для статусу «needsUnfreeze».
  static const int _unfreezeDaysThreshold = 10;

  /// Відсоток прогресу для статусу «almostThere».
  static const double _almostTherePercent = 90.0;

  /// Кількість днів від старту для статусу «justStarted».
  static const int _justStartedDaysThreshold = 3;

  // ── Управління сесіями ─────────────────────────────────────

  /// Починає нову сесію аналітики.
  ///
  /// Фіксує час початку, збільшує лічильник сесій,
  /// встановлює дати першої/останньої сесії.
  static void startSession() {
    _sessionStartTime = DateTime.now();
    _engagement.totalSessions++;
    _engagement.weeklySessions++;
    _engagement.monthlySessions++;

    if (_engagement.firstSessionDate == null) {
      _engagement.firstSessionDate = DateTime.now();
    }
    _engagement.lastSessionDate = DateTime.now();

    trackEvent(AnalyticsEventType.dailyLogin, 'session_started', params: {
      'session_number': _engagement.totalSessions,
      'weekly_sessions': _engagement.weeklySessions,
      'monthly_sessions': _engagement.monthlySessions,
    });

    _logDebug('Session started (#${_engagement.totalSessions})');
  }

  /// Завершує поточну сесію.
  ///
  /// Обчислює тривалість, оновлює середню тривалість
  /// та записує підсумкову в метрики.
  static void endSession() {
    if (_sessionStartTime != null) {
      final duration = DateTime.now().difference(_sessionStartTime!).inSeconds;
      _engagement.currentSessionDuration = duration;
      if (_engagement.totalSessions > 0) {
        _engagement.averageSessionDuration =
            (_engagement.averageSessionDuration * (_engagement.totalSessions - 1) + duration) /
                _engagement.totalSessions;
      }
      _logDebug('Session ended (duration: ${duration}s)');
    }
  }

  /// Повертає поточну тривалість сесії у секундах.
  static int getCurrentSessionDuration() {
    if (_sessionStartTime == null) return 0;
    return DateTime.now().difference(_sessionStartTime!).inSeconds;
  }

  // ── Трекінг подій ──────────────────────────────────────────

  /// Записує подію аналітики.
  ///
  /// [type] — тип події з [AnalyticsEventType].
  /// [name] — людська назва події.
  /// [params] — додаткові параметри для деталізації.
  ///
  /// Події автоматично додаються до буфера. Якщо буфер
  /// перевищує [_maxBufferSize], найстаріші події видаляються.
  static void trackEvent(
    AnalyticsEventType type,
    String name, {
    Map<String, dynamic>? params,
    int priority = 0,
    String? sessionTag,
  }) {
    try {
      final event = AnalyticsEvent(
        type: type,
        name: name,
        parameters: params ?? {},
        timestamp: DateTime.now(),
        priority: priority,
        sessionTag: sessionTag,
      );

      _eventBuffer.add(event);
      if (_eventBuffer.length > _maxBufferSize) {
        _eventBuffer.removeRange(0, _eventBuffer.length - _maxBufferSize);
      }
    } catch (e, stackTrace) {
      _logDebug('Error tracking event "$name": $e\n$stackTrace');
    }
  }

  /// Записує перегляд екрана.
  ///
  /// [screenName] — назва екрана (наприклад, 'dashboard', 'achievements').
  static void trackScreenView(String screenName) {
    trackEvent(AnalyticsEventType.screenView, screenName, sessionTag: 'screen_$screenName');
    _screenViews[screenName] = (_screenViews[screenName] ?? 0) + 1;
    _updateMostVisitedScreen();
  }

  /// Записує натискання кнопки.
  ///
  /// [buttonName] — ідентифікатор кнопки.
  /// [screen] — екран, на якому знаходиться кнопка.
  static void trackButtonTap(String buttonName, {String? screen}) {
    trackEvent(
      AnalyticsEventType.buttonTap,
      buttonName,
      params: {
        if (screen != null) 'screen': screen,
      },
      sessionTag: screen,
    );
  }

  /// Записує подію внеску.
  ///
  /// [amount] — сума внеску.
  /// [type] — тип транзакції.
  static void trackDeposit(double amount, TransactionType type) {
    trackEvent(
      AnalyticsEventType.deposit,
      'deposit_made',
      params: {
        'amount': amount,
        'type': type.name,
      },
      priority: 2,
    );
    _engagement.totalDeposits++;
    _engagement.totalDepositAmount += amount;
  }

  /// Записує скасування внеску.
  ///
  /// [amount] — скасована сума.
  static void trackDepositUndo(double amount) {
    trackEvent(
      AnalyticsEventType.depositUndo,
      'deposit_undone',
      params: {'amount': amount},
    );
    _engagement.totalDeposits = (_engagement.totalDeposits - 1).clamp(0, _engagement.totalDeposits);
    _engagement.totalDepositAmount = (_engagement.totalDepositAmount - amount).clamp(0, _engagement.totalDepositAmount);
    _engagement.totalDepositsUndone++;
  }

  /// Записує створення цілі.
  ///
  /// [goalId] — ID цілі.
  /// [type] — тип цілі.
  /// [targetAmount] — цільова сума.
  static void trackGoalCreated(String goalId, GoalType type, double targetAmount) {
    trackEvent(
      AnalyticsEventType.goalCreated,
      'goal_created',
      params: {
        'goalId': goalId,
        'type': type.name,
        'targetAmount': targetAmount,
      },
      priority: 1,
    );
    _engagement.goalsCreated++;
  }

  /// Записує перегляд цілі.
  ///
  /// [goalId] — ID цілі.
  static void trackGoalView(String goalId) {
    trackEvent(
      AnalyticsEventType.goalView,
      'goal_viewed',
      params: {'goalId': goalId},
    );
  }

  /// Записує завершення цілі.
  ///
  /// [goalId] — ID цілі.
  /// [targetAmount] — цільова сума.
  /// [daysToComplete] — кількість днів для завершення.
  static void trackGoalCompleted(String goalId, double targetAmount, int daysToComplete) {
    trackEvent(
      AnalyticsEventType.goalCompleted,
      'goal_completed',
      params: {
        'goalId': goalId,
        'targetAmount': targetAmount,
        'daysToComplete': daysToComplete,
      },
      priority: 3,
    );
    _engagement.goalsCompleted++;
  }

  /// Записує розморожування цілі.
  ///
  /// [goalId] — ID цілі.
  static void trackGoalUnfreezed(String goalId) {
    trackEvent(
      AnalyticsEventType.goalUnfreezed,
      'goal_unfreezed',
      params: {'goalId': goalId},
    );
  }

  /// Записує перехід рівня.
  ///
  /// [newLevel] — новий рівень користувача.
  /// [levelName] — назва нового рівня.
  static void trackLevelUp(int newLevel, String levelName) {
    trackEvent(
      AnalyticsEventType.levelUp,
      'level_up',
      params: {
        'newLevel': newLevel,
        'levelName': levelName,
      },
      priority: 2,
    );
    _engagement.levelUps++;
  }

  /// Записує розблокування бейджу.
  ///
  /// [badgeId] — ID бейджу.
  /// [badgeName] — назва бейджу.
  static void trackBadgeUnlocked(String badgeId, String badgeName) {
    trackEvent(
      AnalyticsEventType.badgeUnlocked,
      'badge_unlocked',
      params: {
        'badgeId': badgeId,
        'badgeName': badgeName,
      },
      priority: 1,
    );
    _engagement.badgesUnlocked++;
  }

  /// Записує подію вінбордингу.
  ///
  /// [step] — номер кроку (1-індексований).
  /// [stepName] — назва кроку.
  static void trackOnboardingStep(int step, String stepName) {
    trackEvent(
      AnalyticsEventType.onboardingStepCompleted,
      'onboarding_step_$step',
      params: {'stepName': stepName},
      sessionTag: 'onboarding',
    );

    // Оновлюємо воронку.
    final stepKey = 'step_$step';
    if (!_onboardingFunnel.contains(stepKey)) {
      _onboardingFunnel.add(stepKey);
    }
  }

  /// Записує початок онбордингу.
  static void trackOnboardingStarted() {
    trackEvent(
      AnalyticsEventType.onboardingStarted,
      'onboarding_started',
      sessionTag: 'onboarding',
    );
  }

  /// Записує завершення онбордингу.
  static void trackOnboardingCompleted() {
    trackEvent(
      AnalyticsEventType.onboardingCompleted,
      'onboarding_completed',
      sessionTag: 'onboarding',
    );
  }

  /// Записує прийняття челенджу.
  ///
  /// [challengeId] — ID челенджу.
  /// [title] — назва челенджу.
  static void trackChallengeAccepted(String challengeId, String title) {
    trackEvent(
      AnalyticsEventType.challengeAccepted,
      'challenge_accepted',
      params: {
        'challengeId': challengeId,
        'title': title,
      },
    );
  }

  /// Записує завершення челенджу.
  ///
  /// [challengeId] — ID челенджу.
  /// [xpReward] — XP винагорода.
  /// [coinsReward] — монети винагорода.
  static void trackChallengeCompleted(String challengeId, int xpReward, int coinsReward) {
    trackEvent(
      AnalyticsEventType.challengeCompleted,
      'challenge_completed',
      params: {
        'challengeId': challengeId,
        'xpReward': xpReward,
        'coinsReward': coinsReward,
      },
      priority: 2,
    );
    _engagement.challengesCompleted++;
  }

  /// Записує провал челенджу.
  ///
  /// [challengeId] — ID челенджу.
  static void trackChallengeFailed(String challengeId) {
    trackEvent(
      AnalyticsEventType.challengeFailed,
      'challenge_failed',
      params: {'challengeId': challengeId},
    );
    _engagement.challengesFailed++;
  }

  /// Записує подію магазину.
  ///
  /// [itemId] — ID товару.
  /// [itemName] — назва товару.
  /// [price] — ціна в монетах.
  static void trackShopPurchase(String itemId, String itemName, int price) {
    trackEvent(
      AnalyticsEventType.shopPurchase,
      'shop_purchase',
      params: {
        'itemId': itemId,
        'itemName': itemName,
        'price': price,
      },
    );
    _engagement.shopPurchases++;
  }

  /// Записує перегляд магазину.
  static void trackShopViewed() {
    trackEvent(AnalyticsEventType.shopViewed, 'shop_viewed');
  }

  /// Записує перегляд лідерборду.
  static void trackLeaderboardViewed() {
    trackEvent(AnalyticsEventType.leaderboardViewed, 'leaderboard_viewed');
  }

  /// Записує перегляд статистики.
  static void trackStatsViewed() {
    trackEvent(AnalyticsEventType.statsViewed, 'stats_viewed');
  }

  /// Записує зміну налаштувань.
  static void trackSettingsChanged(String settingName, String value) {
    trackEvent(
      AnalyticsEventType.settingsChanged,
      'settings_changed',
      params: {'setting': settingName, 'value': value},
    );
  }

  /// Записує використання пошуку.
  static void trackSearchUsed(String query, int resultCount) {
    trackEvent(
      AnalyticsEventType.searchUsed,
      'search_used',
      params: {'query': query, 'resultCount': resultCount},
    );
  }

  /// Записує поділитися контентом.
  static void trackShareContent(String contentType, String sharedItemId) {
    trackEvent(
      AnalyticsEventType.shareContent,
      'share_content',
      params: {'contentType': contentType, 'sharedItemId': sharedItemId},
    );
  }

  /// Записує перегляд інвентарю.
  static void trackInventoryViewed() {
    trackEvent(AnalyticsEventType.inventoryViewed, 'inventory_viewed');
  }

  /// Записує створення автоплатежу.
  static void trackAutopayCreated(double amount, String frequency) {
    trackEvent(
      AnalyticsEventType.autopayCreated,
      'autopay_created',
      params: {'amount': amount, 'frequency': frequency},
    );
  }

  /// Записує скасування автоплатежу.
  static void trackAutopayCancelled(String autopayId) {
    trackEvent(
      AnalyticsEventType.autopayCancelled,
      'autopay_cancelled',
      params: {'autopayId': autopayId},
    );
  }

  // ── Аналітика внесків ──────────────────────────────────────

  /// Повертає звіт по внесках за останні N днів.
  ///
  /// [transactions] — список транзакцій для аналізу.
  /// [days] — кількість днів для аналізу.
  ///
  /// Повертає карту з ключами: period, totalDeposits, depositCount,
  /// averageDeposit, maxDeposit, minDeposit, startDate, endDate.
  static Map<String, dynamic> getDepositReport(List<Transaction> transactions, int days) {
    try {
      final now = DateTime.now();
      final cutoff = now.subtract(Duration(days: days));
      final filtered = transactions.where((t) => t.createdAt.isAfter(cutoff)).toList();

      final total = filtered.fold<double>(0, (sum, t) => sum + t.amount);
      final count = filtered.length;
      final average = count > 0 ? total / count : 0;
      final maxDeposit = filtered.isEmpty
          ? 0.0
          : filtered.fold<double>(0, (max, t) => t.amount > max ? t.amount : max);
      final minDeposit = filtered.isEmpty
          ? 0.0
          : filtered.fold<double>(double.infinity, (min, t) => t.amount < min ? t.amount : min);

      // Обчислюємо медіану
      final sortedAmounts = filtered.map((t) => t.amount).toList()..sort();
      final median = sortedAmounts.isNotEmpty
          ? sortedAmounts[sortedAmounts.length ~/ 2]
          : 0.0;

      // Стандартне відхилення
      final variance = sortedAmounts.isNotEmpty
          ? sortedAmounts.map((a) => (a - average).pow(2)).reduce((a, b) => a + b) / sortedAmounts.length
          : 0.0;
      final stdDev = variance.sqrt();

      return {
        'period': '$days днів',
        'totalDeposits': total,
        'depositCount': count,
        'averageDeposit': average,
        'maxDeposit': maxDeposit == double.infinity ? 0 : maxDeposit,
        'minDeposit': minDeposit == double.infinity ? 0 : minDeposit,
        'medianDeposit': median,
        'stdDeviation': stdDev,
        'startDate': cutoff.toIso8601String(),
        'endDate': now.toIso8601String(),
      };
    } catch (e, stackTrace) {
      _logDebug('Error in getDepositReport: $e\n$stackTrace');
      return {'error': e.toString()};
    }
  }

  /// Повертає щоденну статистику за останній тиждень.
  ///
  /// Генерує дані для кожного дня тижня: дата, день тижня,
  /// загальна сума та кількість депозитів.
  static List<Map<String, dynamic>> getWeeklyDepositBreakdown(List<Transaction> transactions) {
    final result = <Map<String, dynamic>>[];
    final now = DateTime.now();

    for (int i = 6; i >= 0; i--) {
      final day = now.subtract(Duration(days: i));
      final dayStart = DateTime(day.year, day.month, day.day);
      final dayEnd = dayStart.add(const Duration(days: 1));

      final dayDeposits = transactions
          .where((t) => t.createdAt.isAfter(dayStart) && t.createdAt.isBefore(dayEnd))
          .toList();

      final total = dayDeposits.fold<double>(0, (sum, t) => sum + t.amount);
      final goalIds = dayDeposits.map((t) => t.goalId).toSet();

      result.add({
        'date': dayStart.toIso8601String(),
        'dayName': _dayNameUkrainian(day.weekday),
        'totalAmount': total,
        'depositCount': dayDeposits.length,
        'uniqueGoals': goalIds.length,
        'avgPerDeposit': dayDeposits.isNotEmpty ? total / dayDeposits.length : 0,
      });
    }

    return result;
  }

  /// Повертає місячну статистику за вказану кількість днів.
  ///
  /// Генерує агреговану статистику: загальна сума, кількість,
  /// середнє значення, тренд (порівняння з попереднім періодом).
  static Map<String, dynamic> getMonthlyDepositReport(List<Transaction> transactions, int days) {
    try {
      final now = DateTime.now();
      final cutoff = now.subtract(Duration(days: days));
      final filtered = transactions.where((t) => t.createdAt.isAfter(cutoff)).toList();

      // Порівняння з попереднім періодом
      final prevCutoff = cutoff.subtract(Duration(days: days));
      final prevFiltered = transactions.where((t) => t.createdAt.isAfter(prevCutoff) && t.createdAt.isBefore(cutoff)).toList();
      final prevTotal = prevFiltered.fold<double>(0, (sum, t) => sum + t.amount);

      final total = filtered.fold<double>(0, (sum, t) => sum + t.amount);
      final count = filtered.length;
      final average = count > 0 ? total / count : 0;

      // Тренд у відсотках
      final trend = prevTotal > 0
          ? ((total - prevTotal) / prevTotal * 100)
          : 0.0;

      return {
        'period': '$days днів',
        'totalDeposits': total,
        'depositCount': count,
        'averageDeposit': average,
        'previousPeriodTotal': prevTotal,
        'trendPercent': trend.toStringAsFixed(1),
        'startDate': cutoff.toIso8601String(),
        'endDate': now.toIso8601String(),
      };
    } catch (e, stackTrace) {
      _logDebug('Error in getMonthlyDepositReport: $e\n$stackTrace');
      return {'error': e.toString()};
    }
  }

  /// Повертає годинну статистику за поточний день.
  ///
  /// Генерує розбивку по годинах для поточного дня:
  /// кожна година містить кількість та суму депозитів.
  static Map<String, dynamic> getHourlyDepositBreakdown(List<Transaction> transactions) {
    final now = DateTime.now();
    final dayStart = DateTime(now.year, now.month, now.day);

    final hourlyData = <String, Map<String, dynamic>>{};
    for (int h = 0; h < 24; h++) {
      hourlyData[h.toString()] = {'count': 0, 'total': 0.0};
    }

    for (final t in transactions) {
      if (t.createdAt.isAfter(dayStart) && t.createdAt.isBefore(now)) {
        final hour = t.createdAt.hour.toString();
        if (hourlyData.containsKey(hour)) {
          hourlyData[hour]!['count'] = hourlyData[hour]!['count']! + 1;
          hourlyData[hour]!['total'] = hourlyData[hour]!['total'] + t.amount;
        }
      }
    }

    // Знаходимо найпродуктивніші години
    final sortedHours = hourlyData.entries
        .where((e) => e.value['count'] > 0)
        .toList()
      ..sort((a, b) => (b.value['total'] as double).compareTo(a.value['total'] as double));

    return {
      'date': dayStart.toIso8601String(),
      'hourly': hourlyData,
      'topHours': sortedHours.take(3).map((e) => {
        'hour': e.key,
        'total': e.value['total'],
        'count': e.value['count'],
      }).toList(),
    };
  }

  // ── Аналітика серій ────────────────────────────────────────

  /// Повертає звіт по серіях.
  ///
  /// [currentStreak] — поточна серія днів.
  /// [longestStreak] — найдовша серія.
  /// [totalDeposits] — загальна кількість депозитів.
  static Map<String, dynamic> getStreakReport({
    required int currentStreak,
    required int longestStreak,
    required int totalDeposits,
  }) {
    return {
      'currentStreak': currentStreak,
      'longestStreak': longestStreak,
      'totalDeposits': totalDeposits,
      'motivation': _getStreakMotivation(currentStreak),
      'milestone': _getNextStreakMilestone(currentStreak),
      'isOnTrack': currentStreak >= longestStreak * 0.8,
      'consistencyRate': totalDeposits > 0
          ? (currentStreak / totalDeposits * 100).toStringAsFixed(1)
          : '0.0',
    };
  }

  /// Повертає мотивуюче повідомлення для серії.
  static String _getStreakMotivation(int streak) {
    if (streak == 0) return '🌱 Почни сьогодні!';
    if (streak < 3) return '💡 Тримайся! Ще трохи!';
    if (streak < 7) return '🔥 Ти на правильному шляху!';
    if (streak < 14) return '💪 Тиждень поспіль — круто!';
    if (streak < 21) return '⚡ Двотижнева серія!';
    if (streak < 30) return '🏆 Майже місяць — вражаюча!';
    if (streak < 60) return '🌟 Місяць поспіль — ти легенда!';
    if (streak < 90) return '🚀 Два місяці поспіль!';
    return '👑 Три місяці! Абсолютний рекорд!';
  }

  /// Повертає наступну віху серії.
  static String _getNextStreakMilestone(int streak) {
    if (streak < 3) return 'Наступна: 3 дні';
    if (streak < 7) return 'Наступна: 7 днів (тиждень)';
    if (streak < 14) return 'Наступна: 14 днів (два тижні)';
    if (streak < 21) return 'Наступна: 21 день (три тижні)';
    if (streak < 30) return 'Наступна: 30 днів (місяць)';
    if (streak < 60) return 'Наступна: 60 днів (два місяці)';
    if (streak < 90) return 'Наступна: 90 днів (три місяці)';
    return '🎉 Серія 100+ днів!';
  }

  /// Генерує серію підказок для різних етапів.
  static List<String> generateStreakTips(int streak) {
    final tips = <String>[];
    if (streak == 0) {
      tips.add('Почни з невеликого внеску — навіть 10 грн має значення.');
    }
    if (streak < 3) {
      tips.add('Спробуйте встановити щоденний нагадування.');
    }
    if (streak >= 3) {
      tips.add('Ти на хорошому шляху — не зупиняйся!');
    }
    if (streak >= 7) {
      tips.add('Тижднева серія — це вже звичка!');
    }
    if (streak >= 14) {
      tips.add('Двотижнева серія — ти вражаєш інших!');
    }
    if (streak >= 30) {
      tips.add('Місячна серія — ти справжній майстер!');
    }
    if (streak >= 60) {
      tips.add('Подумай про збереження великої цілі!');
    }
    return tips;
  }

  // ── Аналітика челенджів ────────────────────────────────────

  /// Повертає звіт по челенджах.
  ///
  /// [completedCount] — кількість завершених челенджів.
  /// [failedCount] — кількість провалених челенджів.
  /// [totalXpEarned] — загальний XP за челенджі.
  /// [totalCoinsEarned] — загальні монети за челенджі.
  static Map<String, dynamic> getChallengePerformance({
    required int completedCount,
    required int failedCount,
    required int totalXpEarned,
    required int totalCoinsEarned,
  }) {
    final total = completedCount + failedCount;
    final successRate = total > 0 ? (completedCount / total * 100) : 0;

    // Визначаємо найкращу та найгіршу серію
    final bestStreak = completedCount >= 5;
    final worstStreak = failedCount >= 3 && completedCount == 0;

    return {
      'completedCount': completedCount,
      'failedCount': failedCount,
      'totalCount': total,
      'successRate': successRate.toStringAsFixed(1),
      'totalXpEarned': totalXpEarned,
      'totalCoinsEarned': totalCoinsEarned,
      'motivation': successRate >= 80
          ? '🏆 Челенджовий майстер!'
          : successRate >= 50
              ? '💪 Хороший результат!'
              : successRate >= 25
                  ? '🌱 Пробуй нові челенджі!'
                  : '❄️ Не здавайся — спробуй легший челендж!',
      'bestStreak': bestStreak,
      'worstStreak': worstStreak,
      'averageRewardXp': total > 0 ? (totalXpEarned / total).toStringAsFixed(1) : '0',
      'averageRewardCoins': total > 0 ? (totalCoinsEarned / total).toStringAsFixed(1) : '0',
    };
  }

  /// Повертає звіт по челенджах за період.
  static Map<String, dynamic> getChallengeTimeBasedReport({
    required List<DateTime> completionDates,
    required List<bool> successFlags,
  }) {
    if (completionDates.isEmpty) {
      return {'error': 'No data'};
    }

    // Визначаємо середній час між завершеннями
    final sortedDates = List<DateTime>.from(completionDates)
      ..sort();
    int totalDaysBetween = 0;
    int count = 0;
    for (int i = 1; i < sortedDates.length; i++) {
      totalDaysBetween += sortedDates[i].difference(sortedDates[i - 1]).inDays;
      count++;
    }
    final avgDaysBetween = count > 0 ? totalDaysBetween / count : 0;

    final successFlags = successFlags;
    final winStreak = _calculateWinStreak(successFlags);

    return {
      'totalChallenges': completionDates.length,
      'avgDaysBetweenCompletion': avgDaysBetween.toStringAsFixed(1),
      'currentWinStreak': winStreak,
      'longestWinStreak': _calculateWinStreak(successFlags),
      'successCount': successFlags.where((s) => s).length,
      'failureCount': successFlags.where((s) => !s).length,
    };
  }

  /// Обчислює поточну серію перемог у челенджах.
  static int _calculateWinStreak(List<bool> successFlags) {
    int streak = 0;
    int maxStreak = 0;
    for (final flag in successFlags) {
      if (flag) {
        streak++;
        if (streak > maxStreak) maxStreak = streak;
      } else {
        streak = 0;
      }
    }
    return streak;
  }

  // ── Воронка онбордингу ─────────────────────────────────────

  /// Повертає статус воронки онбордингу.
  ///
  /// Включає список завершених кроків, загальну кількість кроків
  /// та відсоток завершення.
  static Map<String, dynamic> getOnboardingFunnel() {
    return {
      'steps': List<String>.from(_onboardingFunnel),
      'totalSteps': 5,
      'completedSteps': _onboardingFunnel.length,
      'isCompleted': _onboardingFunnel.length >= 5,
      'completionRate': _onboardingFunnel.length >= 5 ? 100.0 : (_onboardingFunnel.length / 5 * 100),
      'dropoffStep': _identifyDropoffStep(),
    };
  }

  /// Визначає крок, на якому користувач найчастіше припиняє онбординг.
  static String? _identifyDropoffStep() {
    const expectedSteps = ['step_1', 'step_2', 'step_3', 'step_4', 'step_5'];
    for (final step in expectedSteps) {
      if (!_onboardingFunnel.contains(step)) {
        return step;
      }
    }
    return null;
  }

  // ── Визначення настрою панелі ──────────────────────────────

  /// Визначає настрій інформаційної панелі на основі цілі та транзакцій.
  ///
  /// Повертає один з варіантів [DashboardMood] на основі:
  /// - прогресу цілі
  /// - давності останнього внеску
  /// - частоти внесків
  ///
  /// [goal] — ціль для аналізу.
  /// [recent] — список останніх транзакцій.
  static DashboardMood determineMood(
    Goal goal,
    List<Transaction> recent,
  ) {
    try {
      final progressPercent = goal.progress * 100;

      // Перевіряємо завершені цілі
      if (progressPercent >= _almostTherePercent || goal.isCompleted) {
        return DashboardMood.almostThere;
      }

      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      final deposits = recent
          .where((t) => t.goalId == goal.id && t.amount > 0)
          .toList();

      // Якщо немає внесків взагалі
      if (deposits.isEmpty) {
        final daysSinceStart = now.difference(goal.createdAt).inDays;
        if (daysSinceStart >= _unfreezeDaysThreshold) {
          return DashboardMood.needsUnfreeze;
        }
        if (daysSinceStart <= _justStartedDaysThreshold) {
          return DashboardMood.justStarted;
        }
        return DashboardMood.frozen;
      }

      deposits.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      final lastDepositDate = deposits.first.createdAt;
      final lastDepositDay = DateTime(
        lastDepositDate.year,
        lastDepositDate.month,
        lastDepositDate.day,
      );
      final daysSinceLastDeposit = today.difference(lastDepositDay).inDays;

      if (daysSinceLastDeposit >= _unfreezeDaysThreshold) {
        return DashboardMood.needsUnfreeze;
      }
      if (daysSinceLastDeposit >= _frozenDaysThreshold) {
        return DashboardMood.frozen;
      }

      final sevenDaysAgo = today.subtract(const Duration(days: 7));
      final recentCount = deposits.where((t) {
        final txDay = DateTime(t.createdAt.year, t.createdAt.month, t.createdAt.day);
        return !txDay.isBefore(sevenDaysAgo) && !txDay.isAfter(today);
      }).length;

      if (recentCount >= _fastProgressThreshold) {
        return DashboardMood.fastProgress;
      }

      final daysSinceStart = now.difference(goal.createdAt).inDays;
      if (daysSinceStart <= _justStartedDaysThreshold) {
        return DashboardMood.justStarted;
      }

      return DashboardMood.steadyProgress;
    } catch (e, stackTrace) {
      _logDebug('Error in determineMood: $e\n$stackTrace');
      return DashboardMood.normal;
    }
  }

  /// Генерує розширений текстову підказку на основі настрою панелі.
  ///
  /// Кожен настрій має основну підказку + додаткові поради
  /// та перелік на пов'язані екрани додатку.
  static String? generateSuggestion(DashboardMood mood, Goal goal) {
    final baseSuggestion = _getBaseSuggestion(mood, goal);
    final extraTips = _getExtraTips(mood, goal);

    if (extraTips.isEmpty) return baseSuggestion;

    return '$baseSuggestion\n\n${extraTips.join('\n')}';
  }

  /// Повертає базову підказку для настрою.
  static String _getBaseSuggestion(DashboardMood mood, Goal goal) {
    switch (mood) {
      case DashboardMood.fastProgress:
        return '🚀 Ти на вогні! Продовжуй у тому ж темпі — результат не забариться!';
      case DashboardMood.steadyProgress:
        return '💪 Непоганий темп! Спробуй покласти трохи більше завтра.';
      case DashboardMood.frozen:
        return '❄️ Здається, ти затримався. Навіть маленьке поповнення зараз — це вже перемога!';
      case DashboardMood.needsUnfreeze:
        return '🔥 Час розморозитися! Почни з маленької суми — 50 грн вже чудово!';
      case DashboardMood.almostThere:
        final remaining = goal.remaining;
        final formatted = remaining.toStringAsFixed(0);
        return '🎯 Майже на місці! Залишилось лише $formatted ₴ — ти впораєшся!';
      case DashboardMood.justStarted:
        return '🌱 Кожна велика подорож починається з першого кроку. Гарного старту!';
      case DashboardMood.normal:
        return '📈 Продовжуй накопичувати! Кожен внесок наближає тебе до цілі.';
      case DashboardMood.unfreezing:
        return '🔥 Час розморозитися! Почни з невеликої суми!';
      case DashboardMood.completed:
        return '🎉 Ціль досягнуто! Ти молодець! Створи нову ціль!';
    }
  }

  /// Повертає додаткові поради залежно від настрою.
  static List<String> _getExtraTips(DashboardMood mood, Goal goal) {
    switch (mood) {
      case DashboardMood.fastProgress:
        return [
          '💡 Порада: спробуй збільшити щоденний внесок на 10-20%',
          '📊 Твій темп: ${_calculateDepositFrequency(goal)} депозитів/тиждень',
        ];
      case DashboardMood.steadyProgress:
        return [
          '💡 Порада: встанови собі щоденний нагадування',
        '📊 Прогрес: ${(goal.progress * 100).toStringAsFixed(0)}% до цілі',
        ];
      case DashboardMood.frozen:
        return [
          '💡 Порада: почни з найменшого можливого внеску',
          '📊 Залишилось: ${goal.remaining.toStringAsFixed(0)} ₴ до цілі',
        ];
      case DashboardMood.needsUnfreeze:
        return [
          '💡 Порада: розморозуй ціль у налаштуваннях',
          '📊 Створена: ${_formatDate(goal.createdAt)}',
        ];
      case DashboardMood.almostThere:
        return [
          '💡 Порада: замовряни щоб завершити сьогодні!',
          '📊 Залишилось: ${goal.remaining.toStringAsFixed(0)} ₴',
        ];
      case DashboardMood.justStarted:
        return [
          '💡 Порада: встановіть цільову суму для відстеження',
          '📊 Ціль: ${goal.targetAmount.toStringAsFixed(0)} ₴',
        ];
      case DashboardMood.normal:
        return [
          '💡 Порада: подивисься на свої досягнення!',
        ];
      case DashboardMood.unfreezing:
        return [
          '💡 Порада: зроби внесок для підтвердження',
        ];
      case DashboardMood.completed:
        return [
          '💡 Порада: поділисяся результатом з друзями!',
          '💡 Створи нову амбітну ціль!',
        ];
    }
  }

  /// Обчислює частоту депозитів на тиждень.
  static String _calculateDepositFrequency(Goal goal) {
    final daysSinceStart = DateTime.now().difference(goal.createdAt).inDays;
    if (daysSinceStart <= 0) return '0';
    final depositsPerWeek = goal.deposits.length / (daysSinceStart / 7);
    return depositsPerWeek.toStringAsFixed(1);
  }

  /// Форматує дату для відображення.
  static String _formatDate(DateTime date) {
    return '${date.day}.${date.month}.${date.year}';
  }

  /// Генерує список підказок для нового користувача.
  static List<String> generateOnboardingSuggestions() {
    return [
      '🎯 Встановіть свою першу ціль — це займе 30 секунд',
      '💰 Почні з невеликої суми — навіть 10 грн',
      '🔥 Намагайте серію — це мотиває!',
      '🏆 Завершіть челендж — отримаєте бонус!',
      '📊 Переглядайте статистику для аналізу',
      '🎁 Перевірте магазин за ексклюзивні предмети',
      '🔔 Увімкніть сповіщення для нагадувань',
    ];
  }

  // ── Прогнозування ────────────────────────────────────────

  /// Прогнозує дату завершення цілі.
  ///
  /// Аналізує історію транзакцій та обчислює середній темп накопичення
  /// для прогнозування дати завершення.
  ///
  /// Повертає [DateTime] прогнозовану дату або null, якщо
  /// недостатньо даних для прогнозу.
  static DateTime? forecastCompletionDate(
    Goal goal,
    List<Transaction> transactions,
  ) {
    try {
      final remaining = goal.remaining;
      if (remaining <= 0) {
        return goal.completedAt ?? DateTime.now();
      }

      final goalTransactions = transactions
          .where((t) => t.goalId == goal.id && t.amount > 0)
          .toList();

      if (goalTransactions.length < 2) return null;

      goalTransactions.sort((a, b) => a.createdAt.compareTo(b.createdAt));

      final firstDate = goalTransactions.first.createdAt;
      final lastDate = goalTransactions.last.createdAt;
      final totalDays = lastDate.difference(firstDate).inDays;

      if (totalDays < 2) return null;

      final totalDeposited = goalTransactions.fold<double>(
        0.0,
        (sum, t) => sum + t.amount,
      );

      final dailyRate = totalDeposited / totalDays;
      if (dailyRate <= 0) return null;

      // Обчислюємо оптимістичний та песимістичний прогноз
      final daysRemaining = (remaining / dailyRate).ceil();
      final optimisticDate = DateTime.now().add(Duration(days: daysRemaining));
      final pessimisticDate = DateTime.now().add(
        Duration(days: (daysRemaining * 1.3).ceil()),
      );

      _logDebug(
        'Forecast: optimistic=$optimisticDate, pessimistic=$pessimisticDate',
      );

      return optimisticDate;
    } catch (e, stackTrace) {
      _logDebug('Error in forecastCompletionDate: $e\n$stackTrace');
      return null;
    }
  }

  /// Обчислює довіру прогнозу завершення.
  static Duration? forecastDuration(Goal goal, List<Transaction> transactions) {
    final forecast = forecastCompletionDate(goal, transactions);
    if (forecast == null) return null;
    final now = DateTime.now();
    if (!forecast.isAfter(now)) return null;
    return forecast.difference(now);
  }

  /// Обчислює ймовірність завершення цілі в строк.
  static double getCompletionProbability(Goal goal, List<Transaction> transactions) {
    final forecast = forecastCompletionDate(goal, transactions);
    if (forecast == null) return 0.0;

    final now = DateTime.now();
    if (goal.isCompleted) return 1.0;
    if (!forecast.isAfter(now)) return 0.0;

    final remaining = goal.remaining;
    if (remaining <= 0) return 1.0;

    // Базова ймовірність: 50%
    double probability = 0.5;

    // Збільшення за частісти внески
    final goalTransactions = transactions
        .where((t) => t.goalId == goal.id && t.amount > 0)
        .toList();
    if (goalTransactions.length >= 3) probability += 0.1;
    if (goalTransactions.length >= 7) probability += 0.1;

    // Зменшення за тривалий бездіяльності
    final daysSinceLastDeposit = _daysSinceLastDeposit(goal, transactions);
    if (daysSinceLastDeposit > 3) probability -= 0.1;
    if (daysSinceLastDeposit > 7) probability -= 0.15;

    // Збільшення за наявну серію
    if (goal.streakDays >= 7) probability += 0.1;
    if (goal.streakDays >= 14) probability += 0.05;

    // Зменшення за прогрес (чим ближче до завершення — краще ймовірність)
    final progress = goal.progress;
    if (progress >= 0.8) probability += 0.1;

    return probability.clamp(0.0, 1.0);
  }

  /// Обчислює кількість днів з останнього внеску.
  static int _daysSinceLastDeposit(Goal goal, List<Transaction> transactions) {
    final goalTransactions = transactions
        .where((t) => t.goalId == goal.id && t.amount > 0)
        .toList();
    if (goalTransactions.isEmpty) return 999;

    goalTransactions.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    final lastDate = goalTransactions.first.createdAt;
    return DateTime.now().difference(lastDate).inDays;
  }

  /// Генерує прогнозні повідомлення.
  static Map<String, dynamic> getForecastSummary(Goal goal, List<Transaction> transactions) {
    final forecast = forecastCompletionDate(goal, transactions);
    final probability = getCompletionProbability(goal, transactions);
    final duration = forecastDuration(goal, transactions);

    String urgency;
    if (probability >= 0.8) {
      urgency = 'Висока';
    } else if (probability >= 0.5) {
      urgency = 'Середня';
    } else {
      urgency = 'Низька';
    }

    return {
      'forecastDate': forecast?.toIso8601String(),
      'probability': (probability * 100).toStringAsFixed(0),
      'urgency': urgency,
      'estimatedDays': duration?.inDays,
      'estimatedWeeks': duration?.inDays != null ? (duration!.inDays / 7).ceil() : null,
      'remaining': goal.remaining.toStringAsFixed(0),
      'progress': (goal.progress * 100).toStringAsFixed(0),
    };
  }

  // ── Експорт даних аналітики ───────────────────────────────

  /// Експортує всі події аналітики у форматі JSON.
  ///
  /// Включає: події, метрики, перегляди екранів, воронку онбордингу,
  /// час експорту та загальну кількість подій.
  static String exportAnalyticsData() {
    try {
      final data = {
        'events': _eventBuffer.map((e) => e.toJson()).toList(),
        'engagement': _engagement.toJson(),
        'screenViews': _screenViews,
        'onboardingFunnel': _onboardingFunnel,
        'exportedAt': DateTime.now().toIso8601String(),
        'totalEvents': _eventBuffer.length,
        'version': '2.0',
      };
      return jsonEncode(data);
    } catch (e, stackTrace) {
      _logDebug('Error in exportAnalyticsData: $e\n$stackTrace');
      return '{"error": "$e"}';
    }
  }

  /// Експортує події у CSV форматі.
  static String exportAnalyticsCsv() {
    try {
      final buffer = StringBuffer();
      buffer.writeln('type,name,amount,id,priority,sessionTag,timestamp');

      for (final event in _eventBuffer) {
        buffer.writeln(
          '${event.type.name},'
          '${event.name},'
          '${event.parameters['amount'] ?? ''},'
          '${event.parameters['id'] ?? ''},'
          '${event.priority},'
          '${event.sessionTag ?? ''},'
          '${event.timestamp.toIso8601String()}',
        );
      }

      return buffer.toString();
    } catch (e, stackTrace) {
      _logDebug('Error in exportAnalyticsCsv: $e\n$stackTrace');
      return '';
    }
  }

  /// Експортує метрики у JSON форматі (без подій).
  static String exportMetricsOnly() {
    return jsonEncode(_engagement.toJson());
  }

  /// Очищає всі дані аналітики.
  static void clearAnalyticsData() {
    _eventBuffer.clear();
    _screenViews.clear();
    _onboardingFunnel.clear();
    _debugLog.clear();
  }

  /// Очища буфер подій, але зберігає метрики.
  static void clearEventBuffer() {
    _eventBuffer.clear();
  }

  /// Очища метрики, але зберігає події.
  static void clearMetrics() {
    _engagement.totalSessions = 0;
    _engagement.currentSessionDuration = 0;
    _engagement.averageSessionDuration = 0;
    _engagement.weeklySessions = 0;
    _engagement.monthlySessions = 0;
  }

  /// Встановлює кількість сесій за минулий тиждень (для трендів).
  static void setLastWeekSessions(int count) {
    _lastWeekSessions = count;
  }

  // ── Пошук та фільтрація ────────────────────────────────

  /// Повертає події, що відповідають фільтру.
  ///
  /// [filter] — об'єкт [AnalyticsEventFilter].
  static List<AnalyticsEvent> queryEvents(AnalyticsEventFilter filter) {
    return _eventBuffer.where((e) => filter.matches(e)).toList();
  }

  /// Повертає події за вказаний типом.
  static List<AnalyticsEvent> getEventsByType(AnalyticsEventType type) {
    return _eventBuffer.where((e) => e.type == type).toList();
  }

  /// Повертає події за вказаним періодом.
  static List<AnalyticsEvent> getEventsSince(DateTime since) {
    return _eventBuffer.where((e) => e.timestamp.isAfter(since)).toList();
  }

  /// Повертає події за вказаним пріоритетом (≥ мінімального).
  static List<AnalyticsEvent> getEventsByMinPriority(int minPriority) {
    return _eventBuffer.where((e) => e.priority >= minPriority).toList();
  }

  /// Створює звіт за вказаний період.
  static AnalyticsReport generateReport({
    int days = 7,
    AnalyticsEventFilter? filter,
  }) {
    final since = DateTime.now().subtract(Duration(days: days));
    final events = queryEvents(filter ?? AnalyticsEventFilter(since: since));

    // Розподіл за типом
    final typeCounts = <AnalyticsEventType, int>{};
    final nameCounts = <String, int>{};
    for (final event in events) {
      typeCounts[event.type] = (typeCounts[event.type] ?? 0) + 1;
      nameCounts[event.name] = (nameCounts[event.name] ?? 0) + 1;
    }

    // Топ-10 подій за частотою
    final sortedNames = nameCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final topEvents = sortedNames
        .take(10)
        .map((e) => '${e.key} (${e.value}x)');

    return AnalyticsReport(
      period: '$days днів',
      totalEvents: events.length,
      eventsByType: typeCounts,
      topEvents: topEvents,
      periodStart: since,
      periodEnd: DateTime.now(),
    );
  }

  // ── Допоміжні методи ───────────────────────────────────────

  /// Повертає метрики залученості.
  static EngagementMetrics get engagement => _engagement;

  /// Повертає список подій за останній час (копія).
  static List<AnalyticsEvent> get recentEvents {
    return List.unmodifiable(_eventBuffer);
  }

  /// Повертає кількість подій у буфері.
  static int get eventBufferCount => _eventBuffer.length;

  /// Повертає карту переглядів екранів (копія).
  static Map<String, int> get screenViewCounts => Map.unmodifiable(_screenViews);

  /// Повертає список найбільш відвідуваних екранів.
  static List<String> get topScreens {
    final entries = _screenViews.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return entries.take(5).map((e) => e.key).toList();
  }

  /// Повертає кількість унікальних екранів, які були відвідені.
  static int get uniqueScreenCount => _screenViews.length;

  /// Оновлює найчастіший екран.
  static void _updateMostVisitedScreen() {
    String? topScreen;
    int maxViews = 0;
    for (final entry in _screenViews.entries) {
      if (entry.value > maxViews) {
        maxViews = entry.value;
        topScreen = entry.key;
      }
    }
    _engagement.mostVisitedScreen = topScreen ?? '';
  }

  /// Повертає назву дня тижня українською.
  static String _dayNameUkrainian(int weekday) {
    switch (weekday) {
      case 1: return 'Понеділок';
      case 2: return 'Вівторок';
      case 3: return 'Середа';
      case 4: return 'Четвер';
      case 5: return 'П\'ятниця';
      case 6: return 'Субота';
      case 7: return 'Неділя';
      default: return '';
    }
  }

  /// Повертає назву місяця українською.
  static String _monthNameUkrainian(int month) {
    switch (month) {
      case 1: return 'Січень';
      case 2: return 'Лютий';
      case 3: return 'Березень';
      case 4: return 'Квітень';
      case 5: return 'Травень';
      case 6: return 'Червень';
      case 7: return 'Липень';
      case 8: return 'Серпень';
      case 9: return 'Вересень';
      case 10: return 'Жовтень';
      case 11: return 'Листопад';
      case 12: return 'Грудень';
      default: return '';
    }
  }

  /// Генерує короткий звіт для дебагу.
  static String getDebugSummary() {
    return 'Analytics: ${_eventBuffer.length} events, '
        '${_screenViews.length} screens, '
        'Sessions: ${_engagement.totalSessions}, '
        'Deposits: ${_engagement.totalDeposits}';
  }

  /// Записує повідомлення в лог дебагу.
  static void _logDebug(String message) {
    _debugLog.add('[${DateTime.now()}] $message');
    if (_debugLog.length > 100) {
      _debugLog.removeAt(0);
    }
  }

  /// Повертає повний лог дебагу (для розробників).
  static List<String> getDebugLog() => List.unmodifiable(_debugLog);

  /// Очища лог дебагу.
  static void clearDebugLog() => _debugLog.clear();
}
