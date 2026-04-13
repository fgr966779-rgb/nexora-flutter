import 'dart:async';
import 'dart:math' as math;

import '../../core/constants/app_enums.dart';

/// Запис про подію XP для історії.
///
/// Використовується для відстеження всіх операцій з нарахування XP.
/// Зберігає тип події, кількість XP, множник та опис.
class XPHistoryEntry {
  /// Унікальний ідентифікатор запису.
  final String id;

  /// Тип події (наприклад: 'transaction', 'challenge', 'daily_login').
  final String eventType;

  /// Кількість нарахованого XP.
  final int xpAmount;

  /// Час виконання події.
  final DateTime timestamp;

  /// Опис події українською.
  final String description;

  /// Множник XP, що був застосований при нарахуванні.
  final double multiplierUsed;

  /// Створює запис про подію XP.
  ///
  /// [id] — унікальний ідентифікатор.
  /// [eventType] — тип події.
  /// [xpAmount] — кількість XP.
  /// [timestamp] — час події.
  /// [description] — опис події.
  /// [multiplierUsed] — застосований множник (за замовчуванням 1.0).
  const XPHistoryEntry({
    required this.id,
    required this.eventType,
    required this.xpAmount,
    required this.timestamp,
    required this.description,
    this.multiplierUsed = 1.0,
  });

  /// Перетворює запис у мапу для серіалізації.
  ///
  /// Повертає мапу з ключами: id, eventType, xpAmount,
  /// timestamp (ISO 8601), description, multiplierUsed.
  Map<String, dynamic> toMap() => {
        'id': id,
        'eventType': eventType,
        'xpAmount': xpAmount,
        'timestamp': timestamp.toIso8601String(),
        'description': description,
        'multiplierUsed': multiplierUsed,
      };

  /// Відновлює запис з мапи.
  ///
  /// [map] — мапа з даними запису.
  factory XPHistoryEntry.fromMap(Map<String, dynamic> map) => XPHistoryEntry(
        id: map['id'] as String,
        eventType: map['eventType'] as String,
        xpAmount: map['xpAmount'] as int,
        timestamp: DateTime.parse(map['timestamp'] as String),
        description: map['description'] as String,
        multiplierUsed: (map['multiplierUsed'] as num?)?.toDouble() ?? 1.0,
      );

  /// Створює JSON-рядок запису для дебагу.
  @override
  String toString() =>
      'XPHistoryEntry(id: $id, type: $eventType, xp: $xpAmount, '
      '${timestamp.toIso8601String()}, mult: ${multiplierUsed}x)';

  /// Чи є ця подія з розблокування бейджу.
  bool get isBadgeUnlock => eventType == 'badge_unlock';

  /// Чи є ця подія пов'язана з серією.
  bool get isStreakRelated =>
      eventType == 'streak_bonus' || eventType == 'streak_milestone';

  /// Чи є ця подія пов'язана з челенджем.
  bool get isChallengeRelated =>
      eventType == 'challenge' || eventType == 'challenge_complete';

  /// Чи є ця подія пов'язана з щоденним входом.
  bool get isDailyLogin => eventType == 'daily_login';

  /// Чи є ця подія пов'язана з транзакцією.
  bool get isTransaction =>
      eventType == 'transaction' || eventType == 'round_up';
}

/// Інформація про наступний рівень.
///
/// Використовується для відображення прогресу до наступного рівня
/// та повідомлень про розблокування.
class NextLevelInfo {
  /// Номер наступного рівня.
  final int level;

  /// Назва наступного рівня українською.
  final String name;

  /// XP, необхідне для переходу на цей рівень.
  final int xpRequired;

  /// XP, зароблене на поточному рівні.
  final int currentLevelXp;

  /// Що розблоковується на цьому рівні.
  final String unlocks;

  /// Емодзі наступного рівня.
  String get emoji => _levelEmojis[(level - 1).clamp(0, _levelEmojis.length - 1)];

  /// Створює інформацію про наступний рівень.
  const NextLevelInfo({
    required this.level,
    required this.name,
    required this.xpRequired,
    required this.currentLevelXp,
    required this.unlocks,
  });

  /// Перетворює у мапу для серіалізації.
  Map<String, dynamic> toMap() => {
        'level': level,
        'name': name,
        'xpRequired': xpRequired,
        'currentLevelXp': currentLevelXp,
        'unlocks': unlocks,
      };

  @override
  String toString() =>
      'NextLevelInfo(level: $level, name: "$name", xpRequired: $xpRequired, '
      'earned: $currentLevelXp, unlocks: "$unlocks")';
}

/// Результат розрахунку XP за транзакцію.
///
/// Містить всі компоненти XP: базове значення, бонуси, множники,
/// монети, інформацію про перехід на новий рівень.
class XPCalculationResult {
  /// Базове XP за тип транзакції.
  final int baseXp;

  /// XP бонус за серію днів.
  final int streakBonusXp;

  /// XP бонус за перше поповнення.
  final int firstDepositBonus;

  /// Застосований множник.
  final double multiplier;

  /// Загальне нараховане XP.
  final int totalXp;

  /// Зароблені монети.
  final int coins;

  /// Чи відбувся перехід на новий рівень.
  final bool leveledUp;

  /// Новий рівень (якщо leveledUp = true).
  final int? newLevel;

  /// Назва нового рівня (якщо leveledUp = true).
  final String? newLevelName;

  /// XP, яке залишилось до наступного рівня після нарахування.
  int get remainingXpToNextLevel {
    if (newLevel == null) return 0;
    final threshold = _levelThresholds[(newLevel! - 1).clamp(0, _levelThresholds.length - 1)];
    final currentThreshold =
        newLevel! > 1 ? _levelThresholds[(newLevel! - 2).clamp(0, _levelThresholds.length - 1)] : 0;
    return (threshold - (currentThreshold + totalXp)).clamp(0, threshold);
  }

  /// Відсоток прогресу до наступного рівня у відсотках (0.0–1.0).
  double get progressToNextLevel {
    if (newLevel == null || newLevel! >= _levelThresholds.length) return 1.0;
    final threshold = _levelThresholds[(newLevel! - 1).clamp(0, _levelThresholds.length - 1)];
    final currentThreshold =
        newLevel! > 1 ? _levelThresholds[(newLevel! - 2).clamp(0, _levelThresholds.length - 1)] : 0;
    if (threshold == currentThreshold) return 1.0;
    return ((currentThreshold + totalXp - currentThreshold) / (threshold - currentThreshold))
        .clamp(0.0, 1.0);
  }

  /// Створює результат розрахунку XP.
  const XPCalculationResult({
    required this.baseXp,
    required this.streakBonusXp,
    required this.firstDepositBonus,
    required this.multiplier,
    required this.totalXp,
    required this.coins,
    required this.leveledUp,
    this.newLevel,
    this.newLevelName,
  });

  /// Перетворює у мапу для серіалізації.
  Map<String, dynamic> toMap() => {
        'baseXp': baseXp,
        'streakBonusXp': streakBonusXp,
        'firstDepositBonus': firstDepositBonus,
        'multiplier': multiplier,
        'totalXp': totalXp,
        'coins': coins,
        'leveledUp': leveledUp,
        'newLevel': newLevel,
        'newLevelName': newLevelName,
      };

  @override
  String toString() =>
      'XPCalculationResult(base: $baseXp, streakBonus: $streakBonusXp, '
      'firstDeposit: $firstDepositBonus, mult: ${multiplier}x, '
      'total: $totalXp, coins: $coins, leveledUp: $leveledUp)';
}

/// Дані для кривої прогресу XP.
///
/// Використовується для відображення прогрес-бару на рівні.
class XPProgressionData {
  /// Номер рівня.
  final int level;

  /// XP, необхідне для цього рівня.
  final int xpRequired;

  /// XP, необхідне для наступного рівня (null для максимального).
  final int? xpForNext;

  /// Прогрес на поточному рівні (0.0–1.0).
  final double progress;

  /// Кількість XP до наступного рівня.
  final int xpNeeded;

  /// XP, зароблене на поточному рівні.
  final int xpInLevel;

  /// Емодзі поточного рівня.
  String get emoji => _levelEmojis[(level - 1).clamp(0, _levelEmojis.length - 1)];

  /// Створює дані прогресу XP.
  const XPProgressionData({
    required this.level,
    required this.xpRequired,
    this.xpForNext,
    required this.progress,
    required this.xpNeeded,
    required this.xpInLevel,
  });

  /// Перетворює у мапу для серіалізації.
  Map<String, dynamic> toMap() => {
        'level': level,
        'xpRequired': xpRequired,
        'xpForNext': xpForNext,
        'progress': progress,
        'xpNeeded': xpNeeded,
        'xpInLevel': xpInLevel,
      };

  @override
  String toString() =>
      'XPProgressionData(level: $level, required: $xpRequired, '
      'forNext: $xpForNext, progress: ${progress.toStringAsFixed(2)}, '
      'needed: $xpNeeded, inLevel: $xpInLevel)';
}

/// Результат оптимізації XP.
///
/// Порада для користувача щодо можливого способу збільшити XP.
class XPOptimizationSuggestion {
  /// Тип дії для оптимізації.
  final String action;

  /// XP, яке можна отримати.
  final int potentialXP;

  /// Опис українською.
  final String description;

  /// Пріоритет поради (1 = низький, 5 = високий).
  final int priority;

  /// Чи порада залежить від преміум-підписки.
  final bool isPremium;

  /// Створює пораду для оптимізації XP.
  const XPOptimizationSuggestion({
    required this.action,
    required this.potentialXP,
    required this.description,
    this.priority = 1,
    this.isPremium = false,
  });

  /// Перетворює у мапу для серіалізації.
  Map<String, dynamic> toMap() => {
        'action': action,
        'potentialXP': potentialXP,
        'description': description,
        'priority': priority,
        'isPremium': isPremium,
      };
}

/// Калькулятор досвіду (XP), монет та рівнів.
///
/// Визначає кількість XP за транзакцію, нарахування монет
/// та перевірку переходу на новий рівень.
///
/// Калькулятор враховує:
/// - Базове XP за тип транзакції
/// - Бонуси за серію, комбо-множники, сезонні множники
/// - Денний та тижневий ліміти XP
/// - Спеціальні події (вхід, челенджі, бейджі, повернення)
/// - Історію нарахувань та анімацію прогресу
///
/// Приклад:
/// ```dart
/// final result = XPCalculator.calculateFullXp(
///   TransactionType.manual,
///   streakDays: 7,
///   currentXp: 500,
///   currentLevel: 2,
/// );
/// print('Total XP: ${result.totalXp}, Coins: ${result.coins}');
/// ```
class XPCalculator {
  // ── XP таблиця ────────────────────────────────────────────────────────

  /// Базове XP за тип транзакції.
  ///
  /// Кожен тип транзакції має власне базове значення XP.
  static const Map<TransactionType, int> _baseXpTable = {
    TransactionType.manual: 10,
    TransactionType.autoPayment: 5,
    TransactionType.challenge: 50,
    TransactionType.dailyLogin: 3,
    TransactionType.microGoal: 8,
    TransactionType.returnBonus: 25,
    TransactionType.roundUp: 3,
  };

  /// Бонус XP за тривалість серії.
  static const Map<int, int> _streakXpBonus = {
    3: 15,
    7: 50,
    30: 200,
  };

  /// XP за перше поповнення скарбнички.
  static const int _firstDepositXp = 30;

  // ── Множник XP ─────────────────────────────────────────────────────────

  /// Базовий множник XP (без бонусів).
  static const double _baseMultiplier = 1.0;

  /// Множник XP за активний період (наприклад, вечірні години).
  static const double _activeMultiplier = 1.5;

  /// Сезонний множник XP (вихідні, свята — менше XP).
  static const double _weekendMultiplier = 1.2;

  /// Щоденний ліміт XP.
  ///
  /// Користувач не може заробити більше цієї кількості XP за день.
  static const int _dailyXpCap = 500;

  /// Тижневий ліміт XP.
  ///
  /// Користувач не може заробити більше цієї кількості XP за тиждень.
  static const int _weeklyXpCap = 3000;

  /// Мінімальний інтервал між транзакціями для комбо-множника (в мілісекунди).
  static const int _comboMinIntervalMs = 30000;

  /// Максимальна кількість транзакцій для розрахунку комбо.
  static const int _maxComboCount = 10;

  // ── Комбо множники ────────────────────────────────────────────────────

  /// XP множник за кількість транзакцій за день.
  ///
  /// Більше транзакцій за день — вищий множник.
  static const Map<int, double> _comboMultipliers = {
    1: 1.0,
    2: 1.1,
    3: 1.2,
    5: 1.3,
    7: 1.5,
    10: 1.8,
  };

  /// XP множник за тривалість серії днів.
  ///
  /// Довша серія — вищий множник XP.
  static const Map<int, double> _streakMultipliers = {
    0: 1.0,
    3: 1.1,
    7: 1.2,
    14: 1.3,
    30: 1.5,
    60: 1.7,
    90: 2.0,
  };

  /// Сезонні множники XP за місяць.
  ///
  /// Вихідні місяці мають менший множник.
  static const Map<int, double> _monthlyMultipliers = {
    1: 0.85, // Січень
    2: 0.90, // Лютий
    3: 1.10, // Березень
    4: 1.05, // Квітень
    5: 1.00, // Травень
    6: 0.95, // Червень
    7: 0.85, // Липень
    8: 0.80, // Серпень
    9: 1.15, // Вересень
    10: 1.05, // Жовтень
    11: 0.90, // Листопад
    12: 0.70, // Грудень
  };

  // ── XP за спеціальні події ──────────────────────────────────────────────

  /// XP за перший вхід у додаток за день.
  static const int dailyLoginXp = 3;

  /// XP за першу транзакцію дня.
  static const int firstDailyTransactionXp = 5;

  /// XP за виконення челенджу.
  static const int challengeCompletionXp = 50;

  /// XP за досягнення цілі.
  static const int goalCompletionXp = 100;

  /// XP за розблокування бейджу.
  static const int badgeUnlockXp = 25;

  /// XP за повернення після перерви.
  static const int returnBonusXp = 25;

  /// XP за використання функції round-up.
  static const int roundUpXp = 3;

  /// XP за перегляд аналітики.
  static const int analyticsViewXp = 2;

  /// XP за налаштування профілю.
  static const int profileSetupXp = 10;

  /// XP за створення цілі.
  static const int goalCreateXp = 5;

  /// XP за виконання першого кроку онбордингу.
  static const int onboardingStepXp = 10;

  /// XP за заповнення всієї інформації профілю.
  static const int profileCompleteXp = 30;

  /// XP за додавання фото профілю.
  static const int profilePhotoXp = 10;

  /// XP за приєднання до команди/групи.
  static const int joinTeamXp = 15;

  /// XP за налаштування сповіщень.
  static const int notificationSetupXp = 5;

  /// XP за перегляд звіту про досягнення цілі.
  static const int goalReviewXp = 3;

  /// XP за завершення тижневого челенджу.
  static const int weeklyChallengeXp = 75;

  /// XP за ранкове завершення челенджу (у перші 24 години).
  static const int earlyChallengeXp = 10;

  /// XP за запит на пораду від спільноти.
  static const int feedbackGivenXp = 3;

  /// XP за перегляд освітніх челенджів.
  static const int challengeExploreXp = 2;

  // ── Монети ────────────────────────────────────────────────────────────

  /// Монети за тип транзакції.
  static const Map<TransactionType, int> _coinTable = {
    TransactionType.manual: 5,
    TransactionType.autoPayment: 2,
    TransactionType.challenge: 25,
    TransactionType.dailyLogin: 0,
    TransactionType.microGoal: 0,
    TransactionType.returnBonus: 0,
    TransactionType.roundUp: 1,
  };

  /// Монети за розблокування бейджу.
  static const int _badgeCoinBonus = 10;

  /// Монети за підвищення рівня.
  static const int _levelUpCoinBonus = 50;

  /// Монети за досягнення тижневого челенджу.
  static const int weeklyChallengeCoins = 40;

  /// Монети за створення цілі.
  static const int goalCreateCoins = 5;

  /// Монети за розблокування преміум-функції.
  static const int premiumUnlockCoins = 0;

  // ── Рівні ─────────────────────────────────────────────────────────────

  /// Пороги XP для кожного рівня (0, 100, 300, 700, 1500, 3000, 6000, 12000).
  static const List<int> _levelThresholds = [
    0, 100, 300, 700, 1500, 3000, 6000, 12000,
  ];

  /// Назви рівнів українською.
  static const List<String> _levelNames = [
    'Новачок', 'Скарбничкар', 'Колекціонер', 'Майстер накопичень',
    'Золотий заощадник', 'Легенда економії', 'Неперевершений', 'Скарбничний бос',
  ];

  /// Опис розблокувань для кожного рівня.
  static const List<String> _levelUnlocks = [
    'Базовий доступ до додатку',
    'Персональна скарбничка з налаштуваннями',
    'Бейджі та досягнення',
    'Системи челенджів',
    'Преміум теми оформлення',
    'Аналітика заощаджень',
    'Ексклюзивні бейджі',
    'Усі функції розблоковано',
  ];

  /// Емодзі для кожного рівня.
  static const List<String> _levelEmojis = [
    '🌱', '🐷', '🏆', '⭐', '👑', '🦸', '💎', '🏅',
  ];

  /// Опис рівнів для профілю користувача.
  static const List<String> _levelDescriptions = [
    'Ти щой щой почав! Зроби перший внесок, щоб розблокувати скарбничку.',
    'Скарбничка працює! Спробуй налаштувати персональну ціль.',
    'Колекціонуй бейджі та досягнення за свої заощадження!',
    'Майстер накопичень! Тепер доступні челенджі.',
    'Золотий заощадник! Розблоковано преміум теми оформлення!',
    'Легенда економії! Аналітика заощаджень тепер доступна.',
    'Неперевершений! Ексклюзивні бейджі та функції.',
    'Скарбничний бос! Усі функції розблоковано! 🎉',
  ];

  /// Кольори для іконок рівнів.
  static const List<int> _levelColors = [
    0xFF4CAF50, // Зелений
    0xFF2196F3, // Синій
    0xFF9C27B0, // Фіолетовий
    0xFFFF9800, // Помаранчевий
    0xFFFFD600, // Золотий
    0xFFF44336, // Червоний
    0xFF00BCD4, // Блакитний
    0xFF212121, // Чорний
  ];

  // ── Денний/тижневий ліміт ──────────────────────────────────────────────

  /// XP за кожен етап серії (додатковий бонус).
  static const Map<int, int> _streakMilestoneXp = {
    3: 5,
    7: 10,
    14: 15,
    21: 20,
    30: 30,
    60: 50,
    90: 75,
    180: 100,
    365: 200,
  };

  /// Назви етапів серії українською.
  static const Map<int, String> _streakMilestoneNames = {
    3: 'Стійкий початок',
    7: 'Тижнева серія',
    14: 'Двотижневий марафон',
    21: 'Три тижні стійкості',
    30: 'Місячний марафон',
    60: 'Двомісячний воїн',
    90: 'Квартал золотого накопичення',
    180: 'Півроку витривалості',
    365: 'Річний чемпіон',
  };

  // ── Публічні методи ─────────────────────────────────────────────────────

  /// Загальна кількість рівнів.
  static int getTotalLevels() => _levelNames.length;

  /// Повертає назву рівня за номером.
  static String getLevelName(int level) {
    final index = (level - 1).clamp(0, _levelNames.length - 1);
    return _levelNames[index];
  }

  /// Повертає емодзі рівня.
  static String getLevelEmoji(int level) {
    final index = (level - 1).clamp(0, _levelEmojis.length - 1);
    return _levelEmojis[index];
  }

  /// Повертає опис розблокування для рівня.
  static String getLevelUnlocks(int level) {
    final index = (level - 1).clamp(0, _levelUnlocks.length - 1);
    return _levelUnlocks[index];
  }

  /// Повертає опис рівня для профілю.
  static String getLevelDescription(int level) {
    final index = (level - 1).clamp(0, _levelDescriptions.length - 1);
    return _levelDescriptions[index];
  }

  /// Повертає колір рівня.
  static Color getLevelColor(int level) {
    final index = (level - 1).clamp(0, _levelColors.length - 1);
    return Color(_levelColors[index]);
  }

  /// Повертає список усіх назв рівнів.
  static List<String> getAllLevelNames() => List.unmodifiable(_levelNames);

  /// Повертає список усіх емодзі рівнів.
  static List<String> getAllLevelEmojis() => List.unmodifiable(_levelEmojis);

  /// Повертає список усіх кольорів рівнів.
  static List<Color> getAllLevelColors() =>
      _levelColors.map((c) => Color(c)).toList();

  // ── Множники ─────────────────────────────────────────────────────────

  /// Повертає поточний множник XP на основі параметрів.
  ///
  /// [isWeekend] — чи зараз вихідний день.
  /// [isActivePeriod] — чи активний період (вечірні години, святкові).
  static double getCurrentMultiplier({
    bool isWeekend = false,
    bool isActivePeriod = false,
    int currentMonth = 1,
  }) {
    double multiplier = _baseMultiplier;

    // Сезонний множник за місяць
    multiplier *= _monthlyMultipliers[currentMonth] ?? 1.0;

    // Вихідний множник
    if (isWeekend) multiplier *= _weekendMultiplier;

    // Активний період множник (перевизначає seasonal)
    if (isActivePeriod) multiplier = _activeMultiplier;

    return multiplier;
  }

  /// Повертає множник XP за серію днів.
  ///
  /// [streakDays] — поточна тривалість серії.
  static double getStreakMultiplier(int streakDays) {
    double multiplier = 1.0;
    for (final entry in _streakMultipliers.entries) {
      if (streakDays >= entry.key) {
        multiplier = entry.value;
      }
    }
    return multiplier;
  }

  /// Повертає множник XP за кількість транзакцій за день.
  ///
  /// [dailyTransactions] — кількість транзакцій сьогодні.
  static double getComboMultiplier(int dailyTransactions) {
    double multiplier = 1.0;
    for (final entry in _comboMultipliers.entries) {
      if (dailyTransactions >= entry.key) {
        multiplier = entry.value;
      }
    }
    return multiplier;
  }

  /// Повертає комбінований множник.
  ///
  /// Обчислює множник на основі серії, комбо та сезонного фактору.
  ///
  /// [streakDays] — тривалість серії.
  /// [dailyTransactions] — кількість транзакцій за день.
  /// [isWeekend] — чи вихідний день.
  /// [currentMonth] — поточний місяць.
  static double getCombinedMultiplier({
    int streakDays = 0,
    int dailyTransactions = 1,
    bool isWeekend = false,
    int currentMonth = 1,
  }) {
    final streak = getStreakMultiplier(streakDays);
    final combo = getComboMultiplier(dailyTransactions);
    final seasonal = _monthlyMultipliers[currentMonth] ?? 1.0;
    final weekend = isWeekend ? _weekendMultiplier : 1.0;
    return streak * combo * seasonal * weekend;
  }

  // ── Денний/тижневий ліміт ──────────────────────────────────────────

  /// Залишилось XP до кінця дня.
  ///
  /// [todayXpEarned] — XP, вже зароблене сьогодні.
  static int remainingDailyXp(int todayXpEarned) {
    if (_dailyXpCap == 0) return -1;
    return (_dailyXpCap - todayXpEarned).clamp(0, _dailyXpCap);
  }

  /// Залишилось XP до кінця тижня.
  ///
  /// [weekXpEarned] — XP, зароблене за цей тиждень.
  static int remainingWeeklyXp(int weekXpEarned) {
    if (_weeklyXpCap == 0) return -1;
    return (_weeklyXpCap - weekXpEarned).clamp(0, _weeklyXpCap);
  }

  /// Чи досягнуто денний ліміт XP.
  ///
  /// [todayXpEarned] — XP, вже зароблене сьогодні.
  /// [newXp] — XP, яке планується нарахувати.
  static bool isDailyCapReached(int todayXpEarned, int newXp) {
    if (_dailyXpCap == 0) return false;
    return todayXpEarned + newXp > _dailyXpCap;
  }

  /// Застосовує денний ліміт XP.
  ///
  /// Повертає XP після обмеження.
  static int applyDailyCap(int xp, int todayXpEarned) {
    if (_dailyXpCap == 0) return xp;
    final remaining = _dailyXpCap - todayXpEarned;
    if (remaining <= 0) return 0;
    return xp.clamp(0, remaining);
  }

  /// Застосовує тижневий ліміт XP.
  ///
  /// Повертає XP після обмеження.
  static int applyWeeklyCap(int xp, int weekXpEarned) {
    if (_weeklyXpCap == 0) return xp;
    final remaining = _weeklyXpCap - weekXpEarned;
    if (remaining <= 0) return 0;
    return xp.clamp(0, remaining);
  }

  // ── Спеціальні події ─────────────────────────────────────────────────

  /// Обчислює XP за спеціальну подію.
  ///
  /// [eventType] — тип події (рядок: 'daily_login', 'challenge', 'goal_complete').
  /// [streakDays] — тривалість серії.
  /// [multiplier] — множник.
  ///
  /// Повертає загальне XP з бонусами.
  static int calculateSpecialEventXp({
    required String eventType,
    int streakDays = 0,
    double multiplier = 1.0,
  }) {
    int baseXp;
    switch (eventType) {
      case 'daily_login':
        baseXp = dailyLoginXp;
      case 'first_transaction':
        baseXp = firstDailyTransactionXp;
      case 'challenge':
        baseXp = challengeCompletionXp;
      case 'challenge_complete':
        baseXp = challengeCompletionXp;
      case 'goal_complete':
        baseXp = goalCompletionXp;
      case 'badge_unlock':
        baseXp = badgeUnlockXp;
      case 'return_bonus':
        baseXp = returnBonusXp;
      case 'round_up':
        baseXp = roundUpXp;
      case 'analytics_view':
        baseXp = analyticsViewXp;
      case 'profile_setup':
        baseXp = profileSetupXp;
      case 'profile_complete':
        baseXp = profileCompleteXp;
      case 'profile_photo':
        baseXp = profilePhotoXp;
      case 'goal_create':
        baseXp = goalCreateXp;
      case 'onboarding_step':
        baseXp = onboardingStepXp;
      case 'join_team':
        baseXp = joinTeamXp;
      case 'notification_setup':
        baseXp = notificationSetupXp;
      case 'goal_review':
        baseXp = goalReviewXp;
      case 'weekly_challenge':
        baseXp = weeklyChallengeXp;
      case 'early_challenge':
        baseXp = earlyChallengeXp;
      case 'feedback_given':
        baseXp = feedbackGivenXp;
      case 'challenge_explore':
        baseXp = challengeExploreXp;
      default:
        baseXp = 0;
    }

    // Додаємо бонус за серію
    int streakBonus = 0;
    for (final entry in _streakMilestoneXp.entries) {
      if (streakDays >= entry.key) streakBonus += entry.value;
    }

    return ((baseXp + streakBonus) * multiplier).round();
  }

  /// Повертає список усіх типів спеціальних подій.
  static List<String> getAllSpecialEventTypes() => [
        'daily_login',
        'first_transaction',
        'challenge',
        'challenge_complete',
        'goal_complete',
        'badge_unlock',
        'return_bonus',
        'round_up',
        'analytics_view',
        'profile_setup',
        'profile_complete',
        'profile_photo',
        'goal_create',
        'onboarding_step',
        'join_team',
        'notification_setup',
        'goal_review',
        'weekly_challenge',
        'early_challenge',
        'feedback_given',
        'challenge_explore',
      ];

  // ── Розрахунок XP за транзакцію ──────────────────────────────────────

  /// Повний розрахунок XP за транзакцію.
  ///
  /// Повертає детальний результат з усіма компонентами.
  static XPCalculationResult calculateFullXp(
    TransactionType type, {
    bool isFirstDeposit = false,
    int streakDays = 0,
    int currentXp = 0,
    int currentLevel = 1,
    double multiplier = 1.0,
    int todayXpEarned = 0,
    int dailyTransactions = 0,
  }) {
    int baseXp = _baseXpTable[type] ?? 0;

    // Бонус за перше поповнення
    int firstDepositBonus = 0;
    if (isFirstDeposit) firstDepositBonus = _firstDepositXp;

    // Бонус за серію
    int streakBonus = 0;
    if (type != TransactionType.dailyLogin) {
      for (final entry in _streakXpBonus.entries) {
        if (streakDays >= entry.key) streakBonus += entry.value;
      }
      // Додатковий бонус за етап серії
      for (final entry in _streakMilestoneXp.entries) {
        if (streakDays >= entry.key) streakBonus += entry.value;
      }
    }

    // Комбо множник
    final comboMultiplier = getComboMultiplier(dailyTransactions);
    final finalMultiplier = multiplier * comboMultiplier;

    int rawXp = baseXp + firstDepositBonus + streakBonus;
    int multipliedXp = (rawXp * finalMultiplier).round();
    int totalXp = applyDailyCap(multipliedXp, todayXpEarned);

    final newXp = currentXp + totalXp;
    final levelInfo = checkLevelUp(newXp);
    final leveledUp = levelInfo != null &&
        (levelInfo['newLevel'] as int) > currentLevel;

    int coins = _coinTable[type] ?? 0;
    if (leveledUp) coins += _levelUpCoinBonus;

    return XPCalculationResult(
      baseXp: baseXp,
      streakBonusXp: streakBonus,
      firstDepositBonus: firstDepositBonus,
      multiplier: finalMultiplier,
      totalXp: totalXp,
      coins: coins,
      leveledUp: leveledUp,
      newLevel: leveledUp ? (levelInfo!['newLevel'] as int) : null,
      newLevelName: leveledUp ? (levelInfo!['name'] as String) : null,
    );
  }

  /// Спрощений розрахунок XP.
  ///
  /// Повертає загальне XP з базовими бонусами.
  static int calculateXp(
    TransactionType type, {
    bool isFirstDeposit = false,
    int streakDays = 0,
  }) {
    int xp = _baseXpTable[type] ?? 0;
    if (isFirstDeposit) xp += _firstDepositXp;
    if (type != TransactionType.dailyLogin) {
      for (final entry in _streakXpBonus.entries) {
        if (streakDays >= entry.key) xp += entry.value;
      }
    }
    return xp;
  }

  /// Детальний розрахунок XP з логуванням.
  ///
  /// Додає debag-output та повертає результат.
  static XPCalculationResult calculateXpDetailed(
    TransactionType type, {
    bool isFirstDeposit = false,
    int streakDays = 0,
    int currentXp = 0,
    int currentLevel = 1,
    double multiplier = 1.0,
    int todayXpEarned = 0,
    int dailyTransactions = 0,
  }) {
    final result = calculateFullXp(
      type,
      isFirstDeposit: isFirstDeposit,
      streakDays: streakDays,
      currentXp: currentXp,
      currentLevel: currentLevel,
      multiplier: multiplier,
      todayXpEarned: todayXpEarned,
      dailyTransactions: dailyTransactions,
    );

    debugPrint('[XPCalc] Type: ${type.name}, '
        'Base: ${result.baseXp}, '
        'Streak: ${result.streakBonusXp}, '
        'Deposit: ${result.firstDepositBonus}, '
        'Mult: ${result.multiplier.toStringAsFixed(2)}x, '
        'Total: ${result.totalXp}, '
        'Coins: ${result.coins}, '
        'LvlUp: ${result.leveledUp}');

    return result;
  }

  // ── Розрахунок монет ─────────────────────────────────────────────────

  /// Обчислює монети за транзакцію.
  ///
  /// [leveledUp] — чи відбувся перехід на новий рівень.
  /// [badgeUnlocked] — чи розблоковано бейдж.
  static int calculateCoins(
    TransactionType type, {
    bool leveledUp = false,
    bool badgeUnlocked = false,
  }) {
    int coins = _coinTable[type] ?? 0;
    if (badgeUnlocked) coins += _badgeCoinBonus;
    if (leveledUp) coins += _levelUpCoinBonus;
    return coins;
  }

  /// Обчислює монети за розблокування етапу серії.
  ///
  /// [streakDays] — тривалість серії.
  static int calculateStreakMilestoneCoins(int streakDays) {
    const coinMilestones = {
      3: 2, 7: 5, 14: 10, 30: 15, 60: 25, 90: 40, 180: 60, 365: 100,
    };
    int total = 0;
    for (final entry in coinMilestones.entries) {
      if (streakDays >= entry.key) total += entry.value;
    }
    return total;
  }

  /// Обчислює загальну кількість монет користувача.
  ///
  /// [history] — історія записів XP.
  static int getTotalCoinsFromHistory(List<XPHistoryEntry> history) {
    return history.fold<int>(0, (sum, e) => sum + e.xpAmount ~/ 10);
  }

  // ── Рівні ─────────────────────────────────────────────────────────────

  /// Перевіряє та повертає інформацію про перехід на новий рівень.
  ///
  /// Повертає `null`, якщо рівень не змінюється.
  static Map<String, dynamic>? checkLevelUp(int currentXp) {
    int newLevel = 1;
    for (int i = 0; i < _levelThresholds.length; i++) {
      if (currentXp >= _levelThresholds[i]) {
        newLevel = i + 1;
      } else {
        break;
      }
    }
    newLevel = newLevel.clamp(1, _levelNames.length);
    return {'newLevel': newLevel, 'name': _levelNames[newLevel - 1]};
  }

  /// Повертає номер рівня для вказаного XP.
  static int getLevelForXp(int currentXp) {
    int level = 1;
    for (int i = 0; i < _levelThresholds.length; i++) {
      if (currentXp >= _levelThresholds[i]) level = i + 1;
      else break;
    }
    return level.clamp(1, _levelNames.length);
  }

  /// Повертає XP-порог для вказаного рівня.
  static int? getXpForLevel(int level) {
    if (level < 1 || level > _levelNames.length) return null;
    return _levelThresholds[level - 1];
  }

  /// Повертає інформацію про наступний рівень.
  static NextLevelInfo? getNextLevel(int currentXp, int currentLevel) {
    final nextLevelNum = currentLevel + 1;
    if (nextLevelNum > _levelNames.length) return null;

    final xpRequired = _levelThresholds[nextLevelNum - 1];
    final currentLevelStart =
        currentLevel > 1 ? _levelThresholds[currentLevel - 2] : 0;
    final currentLevelXp = currentXp - currentLevelStart;

    return NextLevelInfo(
      level: nextLevelNum,
      name: _levelNames[nextLevelNum - 1],
      xpRequired: xpRequired,
      currentLevelXp: currentLevelXp.clamp(0, xpRequired),
      unlocks: _levelUnlocks[nextLevelNum - 1],
    );
  }

  /// Повертає прогрес на поточному рівні (0.0–1.0).
  static double getLevelProgress(int currentXp, int currentLevel) {
    if (currentLevel >= _levelNames.length) return 1.0;
    final currentThreshold = _levelThresholds[currentLevel - 1];
    final nextThreshold = _levelThresholds[currentLevel];
    if (nextThreshold == currentThreshold) return 1.0;
    final xpInLevel = currentXp - currentThreshold;
    final xpNeeded = nextThreshold - currentThreshold;
    if (xpNeeded <= 0) return 1.0;
    return (xpInLevel / xpNeeded).clamp(0.0, 1.0);
  }

  /// Повертає XP на поточному рівні.
  static int getXpInCurrentLevel(int currentXp, int currentLevel) {
    if (currentLevel < 1 || currentLevel > _levelNames.length) return 0;
    final threshold = _levelThresholds[currentLevel - 1];
    return (currentXp - threshold).clamp(0, currentXp);
  }

  /// Повертає XP, необхідне для наступного рівня.
  static int getXpNeededForNextLevel(int currentXp, int currentLevel) {
    if (currentLevel >= _levelNames.length) return 0;
    final nextThreshold = _levelThresholds[currentLevel];
    return (nextThreshold - currentXp).clamp(0, nextThreshold);
  }

  /// Повні дані про прогрес рівня.
  static XPProgressionData getProgressionData(int currentXp, int currentLevel) {
    final level = getLevelForXp(currentXp);
    final xpRequired = _levelThresholds[(level - 1).clamp(0, _levelThresholds.length - 1)];
    final xpForNext = getXpForNextLevel(level);
    final progress = getLevelProgress(currentXp, level);
    final xpNeeded = getXpNeededForNextLevel(currentXp, level);
    final xpInLevel = getXpInCurrentLevel(currentXp, level);

    return XPProgressionData(
      level: level,
      xpRequired: xpRequired,
      xpForNext: xpForNext,
      progress: progress,
      xpNeeded: xpNeeded,
      xpInLevel: xpInLevel,
    );
  }

  /// Повертає відсоток залишку XP до максимуму.
  static double getMaxProgressPercent(int currentXp) {
    if (currentLevel >= _levelNames.length) return 100.0;
    final currentThreshold = _levelThresholds[currentLevel - 1];
    final nextThreshold = _levelThresholds[currentLevel];
    if (nextThreshold == currentThreshold) return 100.0;
    final xpInLevel = currentXp - currentThreshold;
    final xpNeeded = nextThreshold - currentThreshold;
    if (xpNeeded <= 0) return 100.0;
    return ((xpInLevel / xpNeeded) * 100).clamp(0.0, 100.0);
  }

  // ── Оптимізація XP ─────────────────────────────────────────────────────

  /// Повертає список порад для оптимізації XP.
  ///
  /// [currentStreak] — поточна серія.
  /// [todayXp] — XP зароблене сьогодні.
  /// [dailyXpCap] — денний ліміт XP.
  static List<XPOptimizationSuggestion> getOptimizationSuggestions({
    required int currentStreak,
    required int todayXp,
    int dailyXpCap = 500,
  }) {
    final suggestions = <XPOptimizationSuggestion>[];

    if (currentStreak == 0) {
      suggestions.add(XPOptimizationSuggestion(
        action: 'streak',
        potentialXP: 15,
        description: 'Почни серію! 3 дні поспіль = +15 XP бонусу 🔥',
        priority: 5,
      ));
    }

    if (currentStreak >= 3 && currentStreak < 7) {
      suggestions.add(XPOptimizationSuggestion(
        action: 'streak_extend',
        potentialXP: 35,
        description: 'Ще 4 дні до тижневого бонусу +50 XP! 💪',
        priority: 4,
      ));
    }

    if (currentStreak >= 7 && currentStreak < 14) {
      suggestions.add(XPOptimizationSuggestion(
        action: 'streak_long',
        potentialXP: 30,
        description: 'Ще 7 днів до 14-денного етапу +30 XP! ⭐',
        priority: 3,
      ));
    }

    final remaining = dailyXpCap - todayXp;
    if (remaining > 100) {
      suggestions.add(XPOptimizationSuggestion(
        action: 'deposit',
        potentialXP: 50,
        description: 'Зроби внесок для заробітку XP (залишилось $remaining XP до ліміту) 💰',
        priority: 2,
      ));
    }

    if (currentStreak >= 14 && currentStreak < 30) {
      suggestions.add(XPOptimizationSuggestion(
        action: 'streak_month',
        potentialXP: 50,
        description: 'Ще 16 днів до 30-денного етапу! 💎',
        priority: 3,
      ));
    }

    suggestions.add(XPOptimizationSuggestion(
      action: 'challenge',
      potentialXP: 50,
      description: 'Виконай челендж для +50 XP та +25 монет! 🏆',
      priority: 2,
    ));

    if (currentStreak >= 30) {
      suggestions.add(XPOptimizationSuggestion(
        action: 'streak_long',
        potentialXP: 0,
        description: 'Серія $currentStreak днів — ти неймовірна стійкість! 💎',
        priority: 1,
      ));
    }

    return suggestions;
  }

  /// Обчислює XP за розрив серії (penalty).
  ///
  /// Повертає XP, яке втрачається при розриві серії.
  static int calculateStreakPenalty(int streakDays) {
    if (streakDays == 0) return 0;
    final totalBonus = calculateStreakXpBonus(streakDays);
    return (totalBonus * 0.1).round();
  }

  /// Обчислює XP за повернення після паузи.
  ///
  /// [daysSinceLastDeposit] — днів з останнього поповнення.
  /// [previousStreak] — попередня тривалість серії.
  static int calculateReturnBonus({
    required int daysSinceLastDeposit,
    required int previousStreak,
  }) {
    if (daysSinceLastDeposit <= 1) return 0;
    if (daysSinceLastDeposit <= 3) return returnBonusXp;
    if (daysSinceLastDeposit <= 7) return returnBonusXp ~/ 2;
    if (daysSinceLastDeposit <= 14) return returnBonusXp ~/ 4;
    return 5; // мінімальний бонус за повернення
  }

  /// Повертає кількість XP для розблокування наступного етапу серії.
  static int xpToNextStreakMilestone(int currentStreak) {
    for (final entry in _streakMilestoneXp.entries) {
      if (currentStreak < entry.key) return entry.value;
    }
    return 0;
  }

  /// Повертає кількість днів до наступного етапу серії.
  static int daysToNextStreakMilestone(int currentStreak) {
    for (final entry in _streakMilestoneXp.entries) {
      if (currentStreak < entry.key) return entry.key - currentStreak;
    }
    return 0;
  }

  // ── Симуляція лідерборду ──────────────────────────────────────

  /// Симулює позицію в лідерборді.
  ///
  /// [currentXp] — поточне XP користувача.
  /// [totalUsers] — загальна кількість користувачів.
  static int simulateLeaderboardPosition(
    int currentXp, {
    int totalUsers = 1000,
  }) {
    if (currentXp <= 0) return totalUsers;
    final maxThreshold = _levelThresholds.last;
    final ratio = (currentXp / maxThreshold).clamp(0.0, 1.5);
    final normalized = (1.0 - (math.log(ratio + 1) / math.log(2.5)))
        .clamp(0.0, 1.0);
    return (normalized * totalUsers).round().clamp(1, totalUsers);
  }

  /// Повертає процентиль у лідерборді.
  ///
  /// [position] — позиція користувача в лідерборді.
  /// [totalUsers] — загальна кількість користувачів.
  static String getLeaderboardPercentile(int position, int totalUsers) {
    if (totalUsers <= 0) return '0%';
    final topPercent = ((totalUsers - position) / totalUsers * 100).round();
    if (topPercent <= 0) return 'Топ 100%';
    if (topPercent < 1) return 'Топ 1%';
    return 'Топ $topPercent%';
  }

  /// Повертає ранг у лідерборді.
  ///
  /// [position] — позиція користувача.
  static String getLeaderboardRank(int position) {
    if (position <= 1) return '#1 🏆';
    if (position <= 3) return '#$position 🥈';
    if (position <= 10) return '#$position ⭐';
    return '#$position';
  }

  // ── Історія XP ────────────────────────────────────────────────────

  /// Створює запис про подію XP.
  static XPHistoryEntry createHistoryEntry({
    required String id,
    required String eventType,
    required int xpAmount,
    required String description,
    double multiplierUsed = 1.0,
  }) {
    return XPHistoryEntry(
      id: id,
      eventType: eventType,
      xpAmount: xpAmount,
      timestamp: DateTime.now(),
      description: description,
      multiplierUsed: multiplierUsed,
    );
  }

  /// Обчислює сумарне XP за сьогодні з історії.
  ///
  /// [history] — список записів XP.
  static int getTodayXpFromHistory(List<XPHistoryEntry> history) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return history
        .where((e) {
          final entryDate = DateTime(
              e.timestamp.year, e.timestamp.month, e.timestamp.day);
          return entryDate == today;
        })
        .fold<int>(0, (sum, e) => sum + e.xpAmount);
  }

  /// Обчислює сумарне XP за тиждень з історії.
  ///
  /// [history] — список записів XP.
  static int getWeekXpFromHistory(List<XPHistoryEntry> history) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final weekStart = today.subtract(Duration(days: today.weekday - 1));
    return history
        .where((e) {
          final entryDate = DateTime(
              e.timestamp.year, e.timestamp.month, e.timestamp.day);
          return !entryDate.isBefore(weekStart) && !entryDate.isAfter(today);
        })
        .fold<int>(0, (sum, e) => sum + e.xpAmount);
  }

  /// Обчислює сумарне XP за місяць з історії.
  ///
  /// [history] — список записів XP.
  static int getMonthXpFromHistory(List<XPHistoryEntry> history) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final monthStart = DateTime(now.year, now.month, 1);
    return history
        .where((e) {
          final entryDate = DateTime(
              e.timestamp.year, e.timestamp.month, e.timestamp.day);
          return !entryDate.isBefore(monthStart) && !entryDate.isAfter(today);
        })
        .fold<int>(0, (sum, e) => sum + e.xpAmount);
  }

  /// Обчислює сумарне XP за вказаний період.
  ///
  /// [history] — список записів XP.
  /// [startDate] — початок періоду.
  /// [endDate] — кінець періоду.
  static int getXpForPeriod(
    List<XPHistoryEntry> history, {
    required DateTime startDate,
    required DateTime endDate,
  }) {
    return history
        .where((e) {
          final d = e.timestamp;
          return !d.isBefore(startDate) && !d.isAfter(endDate);
        })
        .fold<int>(0, (sum, e) => sum + e.xpAmount);
  }

  /// Обчислює сумарне XP за останні N днів.
  ///
  /// [history] — список записів XP.
  /// [days] — кількість днів.
  static int getRecentXpFromHistory(
    List<XPHistoryEntry> history, {
    int days = 7,
  }) {
    final now = DateTime.now();
    final cutoff = now.subtract(Duration(days: days));
    return history
        .where((e) => !e.timestamp.isBefore(cutoff))
        .fold<int>(0, (sum, e) => sum + e.xpAmount);
  }

  /// Повертає найкращі записи XP.
  ///
  /// [history] — список записів XP.
  /// [limit] — максимальна кількість записів.
  static List<XPHistoryEntry> getRecentEntries(
    List<XPHistoryEntry> history, {
    int limit = 10,
  }) {
    final sorted = List<XPHistoryEntry>.from(history)
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return sorted.take(limit).toList();
  }

  /// Повертає записи XP за вказаний тип події.
  ///
  /// [history] — список записів XP.
  /// [eventType] — тип події для фільтрації.
  /// [limit] — максимальна кількість записів.
  static List<XPHistoryEntry> getEntriesByType(
    List<XPHistoryEntry> history, {
    required String eventType,
    int limit = 10,
  }) {
    final filtered = history
        .where((e) => e.eventType == eventType)
        .toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return filtered.take(limit).toList();
  }

  /// Повертає суму XP за вказаний тип події.
  ///
  /// [history] — список записів XP.
  /// [eventType] — тип події.
  static int getTotalXpByType(
    List<XPHistoryEntry> history,
    String eventType,
  ) {
    return history
        .where((e) => e.eventType == eventType)
        .fold<int>(0, (sum, e) => sum + e.xpAmount);
  }

  /// Повертає розподіл XP по днях тижня.
  ///
  /// [history] — список записів XP.
  static Map<DateTime, int> getXpByDayOfWeek(
    List<XPHistoryEntry> history,
  ) {
    final result = <DateTime, int>{};
    for (final e in history) {
      final day = DateTime(e.timestamp.year, e.timestamp.month, e.timestamp.day);
      result[day] = (result[day] ?? 0) + e.xpAmount;
    }
    return result;
  }

  /// Повертає розподіл XP по місяцях.
  ///
  /// [history] — список записів XP.
  static Map<int, int> getXpByMonth(
    List<XPHistoryEntry> history,
  ) {
    final result = <int, int>{};
    for (final e in history) {
      final month = e.timestamp.month;
      result[month] = (result[month] ?? 0) + e.xpAmount;
    }
    return result;
  }

  // ── Анімація XP ────────────────────────────────────────────────────────

  /// Створює потік значень для анімації підрахунку.
  ///
  /// Генерує [duration] значень від 0 до [targetXp].
  /// Використовує ease-out кубічну криву для плавного наростання.
  ///
  /// [targetXp] — цільове значення.
  /// [duration] — тривалість анімації.
  /// [frameInterval] — інтервал між кадрами (за замовчуванням 16ms).
  static Stream<int> animateXP(
    int targetXp, {
    Duration duration = const Duration(milliseconds: 800),
    int frameInterval = 16,
  }) async* {
    if (targetXp <= 0) {
      yield 0;
      return;
    }

    final totalFrames = duration.inMilliseconds ~/ frameInterval;
    final frames = totalFrames.clamp(1, 100);

    for (int i = 1; i <= frames; i++) {
      final t = i / frames;
      final eased = 1 - (1 - t) * (1 - t);
      yield (targetXp * eased).round();
      await Future<void>.delayed(Duration(milliseconds: frameInterval));
    }

    yield targetXp;
  }

  /// Створює потік значень для анімації прогресу рівня.
  ///
  /// Генерує плавний перехід від [fromProgress] до [toProgress].
  static Stream<double> animateLevelProgress(
    double fromProgress,
    double toProgress, {
    Duration duration = const Duration(milliseconds: 600),
  }) async* {
    final totalFrames = duration.inMilliseconds ~/ 16;
    final frames = totalFrames.clamp(1, 100);

    for (int i = 1; i <= frames; i++) {
      final t = i / frames;
      final eased = 1 - (1 - t) * (1 - t) * (1 - t);
      final value = fromProgress + (toProgress - fromProgress) * eased;
      yield value.clamp(0.0, 1.0);
      await Future<void>.delayed(const Duration(milliseconds: 16));
    }

    yield toProgress.clamp(0.0, 1.0);
  }

  /// Створює потік для анімації монет.
  ///
  /// Генерує плавне нарощення від 0 до [targetCoins].
  static Stream<double> animateCoins(
    int targetCoins, {
    Duration duration = const Duration(milliseconds: 600),
  }) async* {
    if (targetCoins <= 0) {
      yield 0;
      return;
    }

    final totalFrames = duration.inMilliseconds ~/ 16;
    final frames = totalFrames.clamp(1, 100);

    for (int i = 1; i <= frames; i++) {
      final t = i / frames;
      final eased = 1 - (1 - t) * (1 - t);
      yield (targetCoins * eased).round();
      await Future<void>.delayed(const Duration(milliseconds: 16));
    }

    yield targetCoins;
  }

  // ── Повідомлення ─────────────────────────────────────────────────────

  /// Повертає повідомлення для XP-суми.
  ///
  /// [xpAmount] — кількість XP.
  static String getXpMessage(int xpAmount) {
    if (xpAmount >= 200) {
      return '🔥 ВЕЛИКИЙ БОНУС! +$xpAmount XP! Ти просто машина!';
    } else if (xpAmount >= 50) {
      return '⚡ Відмінно! +$xpAmount XP — серйозний прогрес!';
    } else if (xpAmount >= 25) {
      return '💪 Good! +$xpAmount XP — продовжуй!';
    } else if (xpAmount >= 10) {
      return '✨ +$xpAmount XP — кожна одиниця рахується!';
    } else {
      return '🌱 +$xpAmount XP — маленькі кроки ведуть до великих цілей!';
    }
  }

  /// Повертає повідомлення про підвищення рівня.
  ///
  /// [newLevel] — новий рівень.
  /// [levelName] — назва рівня.
  static String getLevelUpMessage(int newLevel, String levelName) {
    switch (newLevel) {
      case 2:
        return '🎉 Новий рівень: $levelName! Скарбничка стає кращою!';
      case 3:
        return '🏆 Рівень $newLevel: $levelName! Колекціонуй досягнення!';
      case 4:
        return '⭐ Рівень $newLevel: $levelName! Ти майстер!';
      case 5:
        return '👑 Рівень $newLevel: $levelName! Золотий статус!';
      case 6:
        return '🦸 Рівень $newLevel: $levelName! Легенда!';
      case 7:
        return '💎 Рівень $newLevel: $levelName! Неперевершений!';
      case 8:
        return '🏅 МАКСИМАЛЬНИЙ РІВЕНЬ: $levelName! Ти — Скарбничний бос!';
      default:
        return '🎉 Підвищення! Рівень $newLevel: $levelName!';
    }
  }

  /// Повертає повідомлення про перше досягнення.
  static String getFirstDepositMessage(double amount) {
    return '🎉 Перший внесок! ${_formatMoney(amount)} — чудове початок! Шлях до мрії починається тут!';
  }

  /// Повертає повідомлення про втрату після паузи.
  static String getReturnMessage({
    required int daysSinceLastDeposit,
    required int previousStreak,
  }) {
    if (daysSinceLastDeposit <= 1) {
      return 'Пройшов лише один день! Почни нову серію прямо зараз! 🔥';
    } else if (daysSinceLastDeposit <= 3) {
      return 'Майже не втрачено час! Почни сьогодні — ти все ще в формі! 💪';
    } else if (previousStreak >= 14) {
      return 'Ти вже досягав $previousStreak днів раніше. Повтори це! 🏆';
    } else {
      return 'Ніколи не пізно почати! Кожна гривня наближає тебе до мети! 🌱';
    }
  }

  /// Повертає повідомлення про досягнення місяця.
  static String getMonthSummaryMessage(int monthEarnedXp) {
    if (monthEarnedXp == 0) return 'Цей місяць ще без XP. Зроби перший внесок!';
    if (monthEarnedXp < 100) {
      return 'Набрано $monthEarnedXp XP за цей місяць. Продовжуй у тому ж темпі! 🌱';
    } else if (monthEarnedXp < 300) {
      return 'Хороший результат: $monthEarnedXp XP за місяць! 💪';
    } else if (monthEarnedXp < 500) {
      return 'Вражаючий місяць: $monthEarnedXp XP! Так тримати! 🚀';
    } else {
      return 'Фантастично: $monthEarnedXp XP за місяць! Можеш бути лідером! 👑';
    }
  }

  /// Повертає повідомлення для порожнього дня без активності.
  static String getInactiveDayMessage(int daysSinceLastDeposit) {
    if (daysSinceLastDeposit == 1) {
      return 'Вчора не було внеску. Сьогодні — нова можливість! 🔄';
    } else if (daysSinceLastDeposit <= 3) {
      return 'Неактивність: $daysSinceLastDeposit дні. Час почати! 💪';
    } else if (daysSinceLastDeposit <= 7) {
      return 'Серія під загрозою! $daysSinceLastDeposit днів без внеску. Увімкнись! ⚠️';
    } else {
      return 'Довга пауза: $daysSinceLastDeposit днів. Повернись — це важливо! 🔥';
    }
  }

  /// Повертає мотивуюційне повідомлення для ранньої стадії.
  static String getEarlyStreakMessage(int streakDays) {
    if (streakDays == 0) return 'Почни серію сьогодні! Це найважливіший крок! 🌱';
    if (streakDays == 1) return 'Перший день — найважливіший! Завтра буде легшим! 💪';
    if (streakDays == 2) return '2 дні поспіль! Близько до тижня! 🔥';
    if (streakDays == 3) return '3 дні — етап досягнено! +15 XP! 🏆';
    return '$streakDays днів — ти на правильному шляху! 💪';
  }

  /// Повертає мотивуюційне повідомлення для середньої стадії.
  static String getMidStreakMessage(int streakDays) {
    if (streakDays < 3) return 'Почни або продовжуй серію!';
    if (streakDays < 7) return '$streakDays дні! Майже тиждень — тримай! 🔥';
    if (streakDays < 14) return '$streakDays днів — ти на півшляху до тижня! ⭐';
    return '$streakDays днів — серія міцяться звичкою! 💎';
  }

  /// Повертає мотивуюційне повідомлення для пізньої стадії.
  static String getLateStreakMessage(int streakDays) {
    if (streakDays < 7) return 'Ти на правильному шляху!';
    if (streakDays < 14) return '$streakDays днів — два тижні! Місяць за піврок! 🎯';
    if (streakDays < 30) return '$streakDays днів — ти наближаєшся до місяця! 🏆';
    if (streakDays < 60) return '$streakDays днів — 2 місяці стійкості! 💪';
    if (streakDays < 90) return '$streakDays днів — 3 місяці фокусу! 🌟';
    if (streakDays < 180) return '$streakDays днів — півроку! Фінансова дисципліна! 🏅';
    return '$streakDays днів — легенда! Рікний чемпіон наближається! 🥇';
  }

  /// Повертає привітання для місячного етапу серії.
  static String getMonthlyStreakMessage(int streakDays) {
    final remaining = 30 - (streakDays % 30);
    if (streakDays < 30) {
      return 'Ще $remaining днів до місячного етапу! Зусиль! 💪';
    }
    return 'Місячний етап за крок! Залишилось $streakDays днів! 🔥';
  }

  /// Повертає привітання для довгострокої стадії серії.
  static String getLongStreakMessage(int streakDays) {
    final remaining = 60 - (streakDays % 60);
    if (streakDays < 60) {
      return 'Ще $remaining днів до 60-денного етапу! Тримай! 💪';
    }
    return 'Два місяці! Залишилось $streakDays днів! Неймовірна стійкість! 💎';
  }

  /// Повертає привітання для тримісячної стадії.
  static String getTripleStreakMessage(int streakDays) {
    final remaining = 90 - (streakDays % 90);
    if (streakDays < 90) {
      return 'Три місяці! Ще $remaining днів до 90-денного етапу!';
    }
    return 'Квартал століття! Залишилось $streakDays днів! 🌟';
  }

  /// Повертає привітання для піврічня.
  static String getHalfYearStreakMessage(int streakDays) {
    final remaining = 180 - (streakDays % 180);
    if (streakDays < 180) {
      return 'Півроку до нового етапу! Ще $remaining днів залишилось!';
    }
    return 'Півроку пройдено! Залишилось $streakDays днів! 🌟';
  }

  /// Повертає привітання для року.
  static String getYearStreakMessage(int streakDays) {
    if (streakDays < 365) {
      final remaining = 365 - (streakDays % 365);
      return 'Рік underway! Ще $remaining днів залишилось!';
    }
    return '🎉 РІЧНИЙ ЧЕМПІОН! $streakDays днів фінансової дисципліни! 🥇';
  }

  /// Повертає привітання для надзвичайного етапу.
  static String getMultiYearStreakMessage(int streakDays) {
    final remaining = 730 - (streakDays % 730);
    if (streakDays < 730) {
      return 'Надзвичайна мета! Ще $remaining днів!';
    }
    return 'Два роки фінансової дисципліни! 🥇';
  }

  /// Повертає повідомлення для визначення найближчого етапу.
  static String getClosestMilestoneMessage(int streakDays) {
    final next = daysToNextStreakMilestone(streakDays);
    if (streakDays == 0) return 'Почни серію!';
    if (next <= 3) return 'Ще $next дні до етапу!';
    if (next <= 7) return 'Майже тиждень!';
    if (next <= 14) return 'Тиждень наближається!';
    if (next <= 30) return 'Місяць за півроку!';
    if (next <= 60) return 'Два місяці за півроку!';
    return 'Довгострок маршрут!';
  }

  /// Повертає привітання для досягнення етапу.
  static String getAlmostReachedMessage(int streakDays) {
    final next = daysToNextStreakMilestone(streakDays);
    if (streakDays == 0) return '';
    if (next <= 1) return 'Завтрашуй завтрашній внесок!';
    if (next <= 3) return 'Ще $next дні до етапу!';
    return 'Залишилось $next днів!';
  }

  /// Повертає повідомлення про ювілейну дату.
  static String getJubileeMessage(DateTime birthDate, {DateTime? referenceDate}) {
    final ref = referenceDate ?? DateTime.now();
    final age = birthDate.age(referenceDate: ref);
    if (age < 0) return '';

    if (age == 18) return '🎂 Повноліття! З 18 років тобі! 🎉';
    if (age == 20) return '🎂 Двадцятиріччя! 20 років мина! 💐';
    if (age == 25) return '🎂 Чверть чверть Hilton! 🥂';
    if (age == 30) return '🎂 Тридцять! Перехід к 40! 🏆';
    if (age == 40) return '🎂 Рубін! 40 років мудрості! 💎';
    if (age == 50) return 'birthday_half_century'; // Для 50 ювілеїв
    if (age == 60) return '🎂 Діамант! 60 років досвіду! 💎';
    if (age == 70) return '🎂 Платинове! 70 років! 🏅';
    if (age == 75) return '🎂 Три чверті чверть! 💎';
    if (age == 80) return '🎂 Вісімь! 80 років! 🎉';
    if (age == 90) return '🎂 Довголіття! 90 років! 🌟';
    if (age == 100) return '🎂 СТОЛІТТЯ! 100 років! 🥇';

    return '🎂 $age років мина! 🎉';
  }

  // ─── Приватні методи ──────────────────────────────────────────────

  /// Обчислює сумарний бонус серії.
  static int calculateStreakXpBonus(int streakDays) {
    int bonus = 0;
    for (final entry in _streakMilestoneXp.entries) {
      if (streakDays >= entry.key) bonus += entry.value;
    }
    return bonus;
  }

  /// Повертає сумарний бонус серії + множник.
  static int calculateTotalStreakBonus(int streakDays, {double multiplier = 1.0}) {
    final bonus = calculateStreakXpBonus(streakDays);
    return (bonus * multiplier).round();
  }

  /// Обчислює ефективну XP-швидкість на основі серії.
  ///
  /// Для логування та аналізу ефективності гейміфікації.
  static double calculateStreakEfficiency(int streakDays) {
    if (streakDays == 0) return 0.0;
    final maxBonus = calculateStreakXpBonus(streakDays);
    // Ефективність = фактична сума бонусів / максимально можливих
    final total = calculateTotalStreakBonus(streakDays);
    if (total == 0) return 0.0;
    return (maxBonus / total).clamp(0.0, 1.0);
  }

  /// Обчислює очікувану вартості досягнення цілі.
  ///
  /// Повертає кількість днів за оптимізованим шляхом.
  static int estimatedDaysToGoal({
    required int currentXp,
    required int currentLevel,
    required double dailyRate,
  }) {
    if (currentLevel >= _levelNames.length) return 0;
    final nextThreshold = _levelThresholds[currentLevel];
    final remaining = nextThreshold - currentXp;
    if (remaining <= 0) return 0;
    return (remaining / dailyRate).ceil();
  }

  /// Повертає категорію серії.
  ///
  /// 'new' (0–2), 'short' (3–6), 'medium' (7–13), 'long' (14–29), 'legendary' (30+).
  static String getStreakCategory(int streakDays) {
    if (streakDays < 3) return 'new';
    if (streakDays < 7) return 'short';
    if (streakDays < 14) return 'medium';
    if (streakDays < 30) return 'long';
    return 'legendary';
  }

  /// Повертає колір етапу в градусах від 0.0 до 1.0.
  static double streakMilestoneProgress(int streakDays) {
    if (streakDays <= 0) return 0.0;
    // Знаходим поточний етап
    int currentMilestone = 0;
    for (final entry in _streakMilestoneXp.entries) {
      if (streakDays >= entry.key) {
        currentMilestone = entry.key;
      }
    }
    if (currentMilestone == 0) return 0.0;

    // Знаходим наступний етап
    int nextMilestone = 0;
    for (final entry in _streakMilestoneXp.entries) {
      if (entry.key > currentMilestone) {
        nextMilestone = entry.key;
        break;
      }
    }
    if (nextMilestone == 0) return 1.0;

    // Обчислюємо прогрес між етапами
    final prevMilestone = currentMilestone;
    final nextMilestone = nextMilestone;
    final range = nextMilestone - prevMilestone;
    final position = streakDays - prevMilestone;
    return (position / range).clamp(0.0, 1.0);
  }

  /// Повертає ID етапу за кількість днів серії.
  static String getMilestoneId(int streakDays) {
    if (streakDays <= 0) return 'streak_start';
    final names = {
      3: 'streak_3',
      7: 'streak_7',
      14: 'streak_14',
      21: 'streak_21',
      30: 'streak_30',
      60: 'streak_60',
      90: 'streak_90',
      180: 'streak_180',
      365: 'streak_365',
    };
    return names[streakDays] ?? 'streak_unknown';
  }

  // ── Аналітика XP ─────────────────────────────────────────────────────

  /// Повертає статистику XP з історії записів.
  static Map<String, dynamic> analyzeHistory(List<XPHistoryEntry> history) {
    if (history.isEmpty) {
      return {'totalXp': 0, 'totalEntries': 0, 'averageXp': 0.0, 'eventTypes': <String, int>{}};
    }

    final totalXp = history.fold<int>(0, (sum, e) => sum + e.xpAmount);
    final eventTypes = <String, int>{};
    for (final entry in history) {
      eventTypes[entry.eventType] = (eventTypes[entry.eventType] ?? 0) + 1;
    }

    // Розподіл по годинах дня
    final hourlyDistribution = <int, int>{};
    for (final entry in history) {
      final hour = entry.timestamp.hour;
      hourlyDistribution[hour] = (hourlyDistribution[hour] ?? 0) + 1;
    }

    // Розподіл по дням тижня
    final weekdayDistribution = <int, int>{};
    for (final entry in history) {
      final weekday = entry.timestamp.weekday;
      weekdayDistribution[weekday] = (weekdayDistribution[weekday] ?? 0) + 1;
    }

    return {
      'totalXp': totalXp,
      'totalEntries': history.length,
      'averageXp': totalXp / history.length,
      'maxSingleXp': history.fold<int>(0, (max, e) => e.xpAmount > max ? e.xpAmount : max),
      'minSingleXp': history.fold<int>(999999, (min, e) => e.xpAmount < min ? e.xpAmount : min),
      'eventTypes': eventTypes,
      'hourlyDistribution': hourlyDistribution,
      'weekdayDistribution': weekdayDistribution,
      'totalCoins': getTotalCoinsFromHistory(history),
    };
  }

  /// Повертає XP зароблене за сьогодні з історії.
  static int getTodayXp(List<XPHistoryEntry> history) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return history
        .where((e) {
          final entryDay = DateTime(e.timestamp.year, e.timestamp.month, e.timestamp.day);
          return entryDay.isAtSameMomentAs(today) || entryDay.isAfter(today);
        })
        .fold<int>(0, (sum, e) => sum + e.xpAmount);
  }

  /// Повертає XP зароблене за цей тиждень з історії.
  static int getWeekXp(List<XPHistoryEntry> history) {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weekStartDay = DateTime(weekStart.year, weekStart.month, weekStart.day);
    return history
        .where((e) => e.timestamp.isAfter(weekStartDay))
        .fold<int>(0, (sum, e) => sum + e.xpAmount);
  }

  /// Повертає XP зароблене за цей місяць з історії.
  static int getMonthXp(List<XPHistoryEntry> history) {
    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month, 1);
    return history
        .where((e) => e.timestamp.isAfter(monthStart))
        .fold<int>(0, (sum, e) => sum + e.xpAmount);
  }

  /// Повертає найкращий день за XP за останні N днів.
  static DateTime? getBestDay(List<XPHistoryEntry> history, {int days = 30}) {
    if (history.isEmpty) return null;
    final since = DateTime.now().subtract(Duration(days: days));
    final recent = history.where((e) => e.timestamp.isAfter(since));
    if (recent.isEmpty) return null;

    final dailyTotals = <DateTime, int>{};
    for (final entry in recent) {
      final day = DateTime(entry.timestamp.year, entry.timestamp.month, entry.timestamp.day);
      dailyTotals[day] = (dailyTotals[day] ?? 0) + entry.xpAmount;
    }

    DateTime? bestDay;
    int maxXp = 0;
    dailyTotals.forEach((day, xp) {
      if (xp > maxXp) {
        maxXp = xp;
        bestDay = day;
      }
    });
    return bestDay;
  }

  // ── Оптимізаційні поради ──────────────────────────────────────────────

  /// Генерує список порад для збільшення XP.
  ///
  /// Аналізує історію та пропонує конкретні кроки.
  static List<XPOptimizationSuggestion> getOptimizationSuggestions({
    required int currentLevel,
    required int currentXp,
    required int streakDays,
    required int dailyTransactions,
    List<XPHistoryEntry>? history,
  }) {
    final suggestions = <XPOptimizationSuggestion>[];

    // Порада 1: Збільшити серію
    if (streakDays < 7) {
      suggestions.add(XPOptimizationSuggestion(
        action: 'extend_streak',
        potentialXP: 50,
        description: 'Досягни 7-денної серії для бонусу +50 XP',
        priority: 4,
      ));
    }

    // Порада 2: Більше транзакцій за день
    if (dailyTransactions < 3) {
      suggestions.add(XPOptimizationSuggestion(
        action: 'more_transactions',
        potentialXP: 20,
        description: 'Роби 3+ транзакції за день для комбо-множника x1.2',
        priority: 3,
      ));
    }

    // Порада 3: Виконати челендж
    if (history != null && !history.any((e) => e.isChallengeRelated)) {
      suggestions.add(XPOptimizationSuggestion(
        action: 'complete_challenge',
        potentialXP: challengeCompletionXp,
        description: 'Виконай челендж для +$challengeCompletionXp XP',
        priority: 5,
      ));
    }

    // Порада 4: Повернутися після перерви
    suggestions.add(XPOptimizationSuggestion(
      action: 'daily_login',
      potentialXP: dailyLoginXp,
      description: 'Заходь щодня для +$dailyLoginXp XP за вхід',
      priority: 1,
    ));

    // Порада 5: Round-up
    if (history != null && !history.any((e) => e.eventType == 'round_up')) {
      suggestions.add(XPOptimizationSuggestion(
        action: 'enable_roundup',
        potentialXP: 15,
        description: 'Увімкни round-up для автоматичного +3 XP за кожну транзакцію',
        priority: 2,
      ));
    }

    // Порада 6: Заповнити профіль
    if (history != null && !history.any((e) => e.eventType == 'profile_complete')) {
      suggestions.add(XPOptimizationSuggestion(
        action: 'complete_profile',
        potentialXP: profileCompleteXp,
        description: 'Заповни профіль повністю для +$profileCompleteXp XP',
        priority: 3,
      ));
    }

    // Порада 7: Преміум (якщо є)
    suggestions.add(XPOptimizationSuggestion(
      action: 'premium_multiplier',
      potentialXP: 0,
      description: 'Преміум-підписка дає додатковий множник XP',
      priority: 1,
      isPremium: true,
    ));

    return suggestions..sort((a, b) => b.priority.compareTo(a.priority));
  }

  // ── Валідація ─────────────────────────────────────────────────────────

  /// Валідує вхідні параметри розрахунку XP.
  ///
  /// Повертає список проблем або порожній список якщо все ок.
  static List<String> validateXpInput({
    required TransactionType type,
    int streakDays = 0,
    int currentXp = 0,
    int currentLevel = 1,
    double multiplier = 1.0,
  }) {
    final issues = <String>[];

    if (currentLevel < 1 || currentLevel > _levelNames.length) {
      issues.add('Рівень має бути від 1 до ${_levelNames.length}');
    }
    if (currentXp < 0) {
      issues.add('XP не може бути від\'ємним');
    }
    if (streakDays < 0) {
      issues.add('Дні серії не можуть бути від\'ємними');
    }
    if (multiplier <= 0 || multiplier > 10.0) {
      issues.add('Множник має бути від 0.1 до 10.0');
    }

    return issues;
  }

  /// Перевіряє, чи XP значення знаходиться в допустимих межах.
  static bool isXpValid(int xp) => xp >= 0 && xp <= _dailyXpCap * 7;

  /// Повертає максимум XP, який можна заробити за один день.
  static int getMaxDailyXp() => _dailyXpCap;

  /// Повертає максимум XP, який можна заробити за один тиждень.
  static int getMaxWeeklyXp() => _weeklyXpCap;

  /// Обчислює скільки XP ще можна заробити сьогодні.
  static int effectiveMaxDailyXp(int todayXpEarned) {
    return remainingDailyXp(todayXpEarned);
  }

  // ── Мотиваційні повідомлення ──────────────────────────────────────────

  /// Повертає мотиваційне повідомлення на основі поточного прогресу.
  static String getProgressMessage({
    required int currentXp,
    required int currentLevel,
    required double dailyRate,
  }) {
    final progress = getLevelProgress(currentXp, currentLevel);
    final nextInfo = getNextLevel(currentXp, currentLevel);

    if (progress >= 1.0) {
      return '🎉 Максимальний рівень досягнуто! Вітаємо на вершині!';
    } else if (progress >= 0.8) {
      return '🔥 Майже на новому рівні! Ще трохи - і ти там!';
    } else if (progress >= 0.5) {
      return '💪 Половина шляху пройдено! Не зупиняйся!';
    } else if (progress >= 0.25) {
      final daysLeft = nextInfo != null
          ? ((nextInfo.xpRequired - currentXp) / dailyRate).ceil()
          : 0;
      return '🚀 Хороший прогрес! Приблизно $daysLeft днів до наступного рівня.';
    } else {
      final daysLeft = nextInfo != null
          ? ((nextInfo.xpRequired - currentXp) / dailyRate).ceil()
          : 0;
      return '🌱 Тільки почав! $daysLeft днів до ${nextInfo?.name ?? "наступного рівня"}.';
    }
  }

  /// Повертає повідомлення при підвищенні рівня.
  static String getLevelUpMessage(int newLevel) {
    final name = getLevelName(newLevel);
    final emoji = getLevelEmoji(newLevel);
    switch (newLevel) {
      case 1:
        return '$emoji Ласкаво просимо! Ти тепер Новачок!';
      case 2:
        return '$emoji Скарбничкар! Перша сходинка пройдена!';
      case 3:
        return '$emoji Колекціонер! Бейджі вже чекають на тебе!';
      case 4:
        return '$emoji Майстер накопичень! Челенджі розблоковано!';
      case 5:
        return '$emoji Золотий заощадник! Преміум теми доступні!';
      case 6:
        return '$emoji Легенда економії! Аналітика заощаджень!';
      case 7:
        return '$emoji Неперевершений! Ексклюзивний контент!';
      case 8:
        return '$emoji Скарбничний бос! Усі функції розблоковано!';
      default:
        return '$emoji Рівень $newLevel: $name!';
    }
  }

  /// Повертає повідомлення про наближеність до наступного рівня.
  static String getNearLevelUpMessage(int currentXp, int currentLevel) {
    final next = getNextLevel(currentXp, currentLevel);
    if (next == null) return '';
    final progress = getLevelProgress(currentXp, currentLevel);

    if (progress >= 0.9) {
      return '🎯 Всього ${next.xpRequired - currentXp} XP до ${next.name}! Так близько!';
    } else if (progress >= 0.7) {
      return '🌟 ${next.xpRequired - currentXp} XP залишилось до ${next.emoji} ${next.name}';
    } else if (progress >= 0.5) {
      return '💪 ${next.xpRequired - currentXp} XP до ${next.emoji} ${next.name} — ти на правильному шляху!';
    }
    return '';
  }

  // ─── Крива прогресу ──────────────────────────────────────────────────

  /// Генерує повні дані про прогрес XP для поточного рівня.
  static XPProgressionData getProgressionData(int currentXp, int currentLevel) {
    if (currentLevel >= _levelNames.length) {
      return XPProgressionData(
        level: currentLevel,
        xpRequired: _levelThresholds[_levelNames.length - 1],
        xpForNext: null,
        progress: 1.0,
        xpNeeded: 0,
        xpInLevel: 0,
      );
    }

    final currentThreshold = _levelThresholds[currentLevel - 1];
    final nextThreshold = _levelThresholds[currentLevel];
    final xpInLevel = currentXp - currentThreshold;
    final xpNeeded = nextThreshold - currentXp;

    double progress = 0.0;
    if (nextThreshold > currentThreshold) {
      progress = (xpInLevel / (nextThreshold - currentThreshold)).clamp(0.0, 1.0);
    }

    return XPProgressionData(
      level: currentLevel,
      xpRequired: currentThreshold,
      xpForNext: nextThreshold,
      progress: progress,
      xpNeeded: xpNeeded.clamp(0, nextThreshold - currentThreshold),
      xpInLevel: xpInLevel.clamp(0, nextThreshold - currentThreshold),
    );
  }

  /// Генерує дані про прогрес для відображення на всі рівні.
  static List<XPProgressionData> getAllProgressionData(int currentXp) {
    final level = getLevelForXp(currentXp);
    return [
      for (int i = 1; i <= getTotalLevels(); i++)
        getProgressionData(
          i == level ? currentXp : getXpForLevel(i)!,
          i,
        ),
    ];
  }

  // ─── Експорт/Імпорт ────────────────────────────────────────────────

  /// Створює повний звіт про стан користувача.
  static Map<String, dynamic> generateUserReport({
    required int currentXp,
    required int currentLevel,
    required int streakDays,
    required int dailyTransactions,
    required int totalCoins,
    List<XPHistoryEntry>? history,
  }) {
    final progression = getProgressionData(currentXp, currentLevel);
    final nextLevel = getNextLevel(currentXp, currentLevel);
    final combinedMult = getCombinedMultiplier(
      streakDays: streakDays,
      dailyTransactions: dailyTransactions,
      currentMonth: DateTime.now().month,
      isWeekend: DateTime.now().weekday >= 6,
    );

    return {
      'currentLevel': currentLevel,
      'currentLevelName': getLevelName(currentLevel),
      'currentLevelEmoji': getLevelEmoji(currentLevel),
      'currentXp': currentXp,
      'totalCoins': totalCoins,
      'streakDays': streakDays,
      'dailyTransactions': dailyTransactions,
      'combinedMultiplier': combinedMult,
      'dailyXpCap': _dailyXpCap,
      'weeklyXpCap': _weeklyXpCap,
      'progression': progression.toMap(),
      'nextLevel': nextLevel?.toMap(),
      'maxLevel': _levelNames.length,
      'maxXp': _levelThresholds.last,
      'suggestions': getOptimizationSuggestions(
        currentLevel: currentLevel,
        currentXp: currentXp,
        streakDays: streakDays,
        dailyTransactions: dailyTransactions,
        history: history,
      ).map((s) => s.toMap()).toList(),
    };
  }

  // ── Оптимізація XP ───────────────────────────────────────────────

  /// Генерує список порад для максимізації XP.
  ///
  /// Аналізує поточний прогрес та пропонує доступні дії.
  static List<XPOptimizationSuggestion> getOptimizationSuggestions({
    required int currentXp,
    required int currentLevel,
    required int streakDays,
    required int todayXpEarned,
    bool hasCompletedProfile = false,
    bool hasCompletedOnboarding = false,
    bool hasViewedAnalytics = false,
    bool isPremium = false,
    int dailyTransactions = 0,
  }) {
    final suggestions = <XPOptimizationSuggestion>[];

    // Профіль
    if (!hasCompletedProfile) {
      suggestions.add(XPOptimizationSuggestion(
        action: 'complete_profile',
        potentialXP: profileCompleteXp,
        description: 'Заповни повний профіль — отримай $profileCompleteXp XP!',
        priority: 3,
      ));
    }
    if (!hasCompletedOnboarding) {
      suggestions.add(XPOptimizationSuggestion(
        action: 'finish_onboarding',
        potentialXP: onboardingStepXp * 3,
        description: 'Заверш онбординг — $onboardingStepXp XP за крок!',
        priority: 2,
      ));
    }

    // Аналітика
    if (!hasViewedAnalytics) {
      suggestions.add(XPOptimizationSuggestion(
        action: 'view_analytics',
        potentialXP: analyticsViewXp,
        description: 'Переглянь аналітики — $analyticsViewXp XP бонус!',
        priority: 1,
      ));
    }

    // Серія
    if (streakDays > 0 && streakDays < 3) {
      suggestions.add(XPOptimizationSuggestion(
        action: 'maintain_streak',
        potentialXP: 15,
        description: 'Дотримуй серію 3+ дні — бонус ${_streakXpBonus[3]} XP!',
        priority: 4,
      ));
    }
    if (streakDays >= 3 && streakDays < 7) {
      suggestions.add(XPOptimizationSuggestion(
        action: 'reach_week_streak',
        potentialXP: 35,
        description: 'Дотримуй тиждень — бонус ${_streakXpBonus[3] + _streakXpBonus[7]} XP!',
        priority: 4,
      ));
    }

    // Комбо
    if (dailyTransactions < 3) {
      suggestions.add(XPOptimizationSuggestion(
        action: 'do_3_transactions',
        potentialXP: 5,
        description: 'Зроби 3+ транзакції — комбо-множник 1.2×!',
        priority: 2,
      ));
    }
    if (dailyTransactions < 5) {
      suggestions.add(XPOptimizationSuggestion(
        action: 'do_5_transactions',
        potentialXP: 10,
        description: 'Зроби 5+ транзакцій — комбо-множник 1.3×!',
        priority: 2,
      ));
    }

    // Щоденний ліміт
    final remaining = remainingDailyXp(todayXpEarned);
    if (remaining > 0 && remaining < 50) {
      suggestions.add(XPOptimizationSuggestion(
        action: 'xp_cap_warning',
        potentialXP: 0,
        description: 'Денний ліміт майже досягнуто ($remaining XP залишилось)!',
        priority: 5,
      ));
    }

    // Преміум
    if (!isPremium) {
      suggestions.add(XPOptimizationSuggestion(
        action: 'premium_upgrade',
        potentialXP: 25,
        description: 'Преміум: додаткові +25% XP за все!',
        priority: 1,
        isPremium: true,
      ));
    }

    // Сортуємо за пріоритетом (найвищий перший)
    suggestions.sort((a, b) => b.priority.compareTo(a.priority));
    return suggestions;
  }

  /// Повертає повідомлення з найкращою пропозицією XP.
  static String getTopOptimizationMessage({
    required int currentXp,
    required int currentLevel,
    required int streakDays,
    required int todayXpEarned,
    bool hasCompletedProfile = false,
    bool hasCompletedOnboarding = false,
    bool hasViewedAnalytics = false,
  }) {
    final suggestions = getOptimizationSuggestions(
      currentXp: currentXp,
      currentLevel: currentLevel,
      streakDays: streakDays,
      todayXpEarned: todayXpEarned,
      hasCompletedProfile: hasCompletedProfile,
      hasCompletedOnboarding: hasCompletedOnboarding,
      hasViewedAnalytics: hasViewedAnalytics,
    );
    if (suggestions.isEmpty) {
      return '✅ Ти використовуєш усі можливі способи отримати XP!';
    }
    final top = suggestions.first;
    return '💡 Порада: ${top.description}';
  }

  // ── Історія XP ─────────────────────────────────────────────────

  /// Аналізує історію нарахувань за останні N днів.
  static Map<String, dynamic> analyzeHistory(
    List<XPHistoryEntry> history, {
    int days = 7,
  }) {
    if (history.isEmpty) {
      return {
        'totalXp': 0,
        'totalCoins': 0,
        'eventCount': 0,
        'uniqueEventTypes': 0,
        'topEventType': '—',
        'averageXpPerEvent': 0.0,
        'xpByType': <String, int>{},
        'dailyXp': <String, int>{},
      };
    }

    final now = DateTime.now();
    final cutoff = now.subtract(Duration(days: days));
    final recent = history.where((e) => e.timestamp.isAfter(cutoff)).toList();

    final totalXp = recent.fold<int>(0, (sum, e) => sum + e.xpAmount);
    final totalCoins = recent.fold<int>(0, (sum, e) => sum + e.xpAmount ~/ 10);
    final eventTypes = recent.map((e) => e.eventType).toSet();

    // XP за типом події
    final xpByType = <String, int>{};
    for (final e in recent) {
      xpByType[e.eventType] = (xpByType[e.eventType] ?? 0) + e.xpAmount;
    }

    // XP за днем
    final dailyXp = <String, int>{};
    for (final e in recent) {
      final dayKey = e.timestamp.toIso8601String().substring(0, 10);
      dailyXp[dayKey] = (dailyXp[dayKey] ?? 0) + e.xpAmount;
    }

    // Топ тип події
    String topEventType = '—';
    int topCount = 0;
    for (final entry in xpByType.entries) {
      if (entry.value > topCount) {
        topCount = entry.value;
        topEventType = entry.key;
      }
    }

    return {
      'totalXp': totalXp,
      'totalCoins': totalCoins,
      'eventCount': recent.length,
      'uniqueEventTypes': eventTypes.length,
      'topEventType': topEventType,
      'averageXpPerEvent': recent.isEmpty ? 0.0 : totalXp / recent.length,
      'xpByType': xpByType,
      'dailyXp': dailyXp,
    };
  }

  /// Повертає повідомлення про аналіз історії.
  static String getHistoryAnalysisMessage(List<XPHistoryEntry> history) {
    final analysis = analyzeHistory(history);
    if (analysis['eventCount'] == 0) {
      return '📝 Почни діяти — кожна дія приносить XP!';
    }
    return '📊 За останні 7 днів: '
        '${analysis['totalXp']} XP, '
        '${analysis['eventCount']} подій, '
        '${analysis['uniqueEventTypes']} типів. '
        'Найпопулярніше: ${analysis['topEventType']}';
  }

  /// Розраховує сумарний множник XP за історію.
  static double calculateEffectiveMultiplier(List<XPHistoryEntry> history) {
    if (history.isEmpty) return 1.0;
    final totalBase = history
        .where((e) => e.multiplierUsed > 0)
        .fold<double>(0.0, (sum, e) => sum + e.multiplierUsed);
    final count = history
        .where((e) => e.multiplierUsed > 0)
        .length;
    if (count == 0) return 1.0;
    return totalBase / count;
  }

  /// Повертає перелік подій, що дають найбільше XP.
  static List<String> getHighValueEvents(List<XPHistoryEntry> history) {
    final xpByType = <String, int>{};
    for (final e in history) {
      xpByType[e.eventType] = (xpByType[e.eventType] ?? 0) + e.xpAmount;
    }
    final sorted = xpByType.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sorted.take(5).map((e) => e.key).toList();
  }

  /// Повертає повідомлення про найприбутковіші події.
  static String getHighValueEventsMessage(List<XPHistoryEntry> history) {
    final highValue = getHighValueEvents(history);
    if (highValue.isEmpty) return '';
    final descriptions = {
      'daily_login': 'Щоденний вхід',
      'transaction': 'Транзакція',
      'challenge': 'Челендж',
      'challenge_complete': 'Завершення челенджу',
      'goal_complete': 'Досягнення цілі',
      'badge_unlock': 'Розблокування бейджу',
      'return_bonus': 'Повернення',
      'streak_bonus': 'Бонус серії',
      'streak_milestone': 'Етап серії',
      'profile_complete': 'Профіль заповнено',
      'onboarding_step': 'Крок онбордингу',
      'weekly_challenge': 'Тижневий челендж',
    };
    final formatted = highValue.map((e) => descriptions[e] ?? e).join(', ');
    return '🏆 Найприбутковіші: $formatted';
  }

  // ── Прогрес-анімація ────────────────────────────────────────────

  /// Повертає дані для анімації прогресу XP.
  ///
  /// Обчислює попередній та наступний рівні, прогрес та тривалість анімації.
  static Map<String, dynamic> getProgressAnimationData({
    required int currentXp,
    required int currentLevel,
    int previousXp = 0,
  }) {
    final levelInfo = checkLevelUp(currentXp);
    final newLevel = levelInfo?['newLevel'] as int? ?? currentLevel;

    final prevLevel = getLevelForXp(previousXp);
    final levelChanged = newLevel > prevLevel;
    final coins = calculateCoins(
      TransactionType.manual,
      leveledUp: levelChanged,
    );

    final progress = getLevelProgress(currentXp, currentLevel);
    final prevProgress = getLevelProgress(previousXp, prevLevel);

    return {
      'previousLevel': prevLevel,
      'newLevel': newLevel,
      'levelChanged': levelChanged,
      'progress': progress,
      'previousProgress': prevProgress,
      'coinsEarned': coins,
      'levelUpCoins': levelChanged ? _levelUpCoinBonus : 0,
      'currentXp': currentXp,
      'previousXp': previousXp,
      'xpGained': currentXp - previousXp,
      'levelName': getLevelName(newLevel),
      'levelEmoji': getLevelEmoji(newLevel),
      'levelColor': getLevelColor(newLevel).value,
    };
  }

  /// Повертає повідомлення для анімації прогресу.
  static String getProgressAnimationMessage({
    required int currentXp,
    required int currentLevel,
  }) {
    final progress = getLevelProgress(currentXp, currentLevel);
    final pct = (progress * 100).round();
    final nextLevelInfo = getNextLevel(currentXp, currentLevel);

    if (nextLevelInfo == null) {
      return '🎉 Максимальний рівень досягнуто!';
    }
    final remaining = nextLevelInfo.xpRequired -
        (currentXp - getXpForLevel(currentLevel)!);
    return '💰 ${getLevelEmoji(currentLevel)} Рівень ${currentLevel} — '
        '$pct% до ${getLevelName(currentLevel + 1)} '
        '(ще ${remaining.clamp(0, 99999)} XP)';
  }

  /// Обчислює тривалість анімації прогресу (в мілісекундах).
  static int calculateAnimationDurationMs({
    required int xpGained,
    int maxDuration = 1200,
  }) {
    // Більше XP → довша анімація, але обмежено.
    final base = (xpGained / 100.0 * 300).round();
    return base.clamp(100, maxDuration);
  }

  /// Обчислює кутову швидкість для прогрес-бару.
  static double calculateProgressBarSpeed({
    required int xpGained,
    required int totalDurationMs,
  }) {
    if (totalDurationMs <= 0) return 1.0;
    final progress = xpGained.toDouble();
    // Хтось більш лінійне
    return (1.0 + progress * 0.5).clamp(1.0, 3.0);
  }

  // ── Щотижневий звіт ──────────────────────────────────────────────

  /// Генерує звіт за останній тиждень.
  static Map<String, dynamic> generateWeeklyReport(List<XPHistoryEntry> history) {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weekEntries = history
        .where((e) => e.timestamp.isAfter(weekStart))
        .toList();

    final totalXp = weekEntries.fold<int>(0, (sum, e) => sum + e.xpAmount);
    final totalCoins = weekEntries.fold<int>(0, (sum, e) => sum + e.xpAmount ~/ 10);
    final dailyTotals = <int>[0, 0, 0, 0, 0, 0, 0];
    for (final e in weekEntries) {
      final weekday = e.timestamp.weekday - 1;
      if (weekday >= 0 && weekday < 7) {
        dailyTotals[weekday] += e.xpAmount;
      }
    }

    final avgDaily = totalXp ~/ 7;
    final bestDay = dailyTotals.reduce((a, b) => a > b ? a : b);
    final bestDayIndex = dailyTotals.indexOf(bestDay);
    final dayNames = ['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Нд'];

    return {
      'totalXp': totalXp,
      'totalCoins': totalCoins,
      'eventCount': weekEntries.length,
      'averageDailyXp': avgDaily,
      'bestDayIndex': bestDayIndex,
      'bestDayName': dayNames[bestDayIndex],
      'bestDayAmount': bestDay,
      'dailyTotals': dailyTotals,
      'dayNames': dayNames,
      'streakBonusDays': dailyTotals.where((xp) => xp > 0).length,
    };
  }

  /// Повертає текстовий звіт за тиждень.
  static String getWeeklyReportMessage(List<XPHistoryEntry> history) {
    final report = generateWeeklyReport(history);
    return '📊 Тижневий звіт: ${report['totalXp']} XP, '
        '${report['totalCoins']} монет, '
        '${report['eventCount']} подій. '
        'Найкращий день: ${report['bestDayName']} (${report['bestDayAmount']} XP).';
  }

  /// Порівнює поточний тиждень із попереднім.
  static Map<String, dynamic> compareWeeks(
    List<XPHistoryEntry> thisWeek,
    List<XPHistoryEntry> lastWeek,
  ) {
    final thisData = generateWeeklyReport(thisWeek);
    final lastData = generateWeeklyReport(lastWeek);

    final xpDiff = thisData['totalXp'] as int;
    final lastXp = lastData['totalXp'] as int;
    final percentChange = lastXp > 0
        ? ((xpDiff - lastXp) / lastXp * 100).round()
        : 0;

    return {
      'thisWeekXp': xpDiff,
      'lastWeekXp': lastXp,
      'xpDifference': xpDiff - lastXp,
      'percentChange': percentChange,
      'isImproved': xpDiff >= lastXp,
    };
  }

  /// Повертає повідомлення порівняння тижнів.
  static String getWeekComparisonMessage(
    List<XPHistoryEntry> thisWeek,
    List<XPHistoryEntry> lastWeek,
  ) {
    final comparison = compareWeeks(thisWeek, lastWeek);
    final diff = comparison['xpDifference'] as int;
    final pct = comparison['percentChange'] as int;
    if (comparison['isImproved'] == true) {
      return '📈 Цей тиждень краще на +$diff XP (+$pct%)!';
    } else if (comparison['isImproved'] == false) {
      return '📉 Цей тиждень на $diff XP менше ($pct%).';
    }
    return '📊 Рівень XP незмінний.';
  }

  // ── Валідація ──────────────────────────────────────────────────

  /// Валідує параметри розрахунку XP.
  static Map<String, dynamic> validateXpCalculation({
    TransactionType type,
    int streakDays = 0,
    double multiplier = 1.0,
    int todayXpEarned = 0,
    int dailyTransactions = 0,
  }) {
    final errors = <String>[];
    final warnings = <String>[];

    if (streakDays < 0) errors.add('streakDays не може бути від\'ємним');
    if (multiplier <= 0) errors.add('multiplier має бути позитивним');
    if (multiplier > 5.0) warnings.add('multiplier дуже високий (${multiplier}x)');
    if (todayXpEarned < 0) errors.add('todayXpEarned не може бути від\'ємним');

    // Перевірка лімітів
    if (isDailyCapReached(todayXpEarned, 10)) {
      warnings.add('Щойновий XP вичерпає денний ліміт');
    }

    // Перевірка комбо
    if (dailyTransactions > _maxComboCount) {
      warnings.add('Кількість транзакцій перевищує комбо-ліміт');
    }

    return {
      'valid': errors.isEmpty,
      'errors': errors,
      'warnings': warnings,
      'type': type.name,
      'streakDays': streakDays,
      'multiplier': multiplier,
    };
  }

  /// Повертає повідомлення валідації.
  static String getValidationMessage(Map<String, dynamic> result) {
    final errors = result['errors'] as List<String>;
    final warnings = result['warnings'] as List<String>;
    if (errors.isNotEmpty) {
      return '❌ Помилки: ${errors.join('; ')}';
    }
    if (warnings.isNotEmpty) {
      return '⚠️ Попередження: ${warnings.join('; ')}';
    }
    return '✅ Параметри валідні';
  }

  /// Валідує тип події спеціальної операції.
  static bool isValidEventType(String eventType) {
    return getAllSpecialEventTypes().contains(eventType);
  }

  /// Повертає опис типу події.
  static String getEventTypeDescription(String eventType) {
    const descriptions = {
      'daily_login': 'Щоденний вхід у додаток',
      'first_transaction': 'Перша транзакція дня',
      'challenge': 'Виконання челенджу',
      'challenge_complete': 'Завершення челенджу',
      'goal_complete': 'Досягнення цілі',
      'badge_unlock': 'Розблокування бейджу',
      'return_bonus': 'Повернення після перерви',
      'round_up': 'Round-up округлення',
      'analytics_view': 'Перегляд аналітики',
      'profile_setup': 'Налаштування профілю',
      'profile_complete': 'Заповнення профілю',
      'profile_photo': 'Додавання фото',
      'goal_create': 'Створення цілі',
      'onboarding_step': 'Крок онбордингу',
      'join_team': 'Приєднання до команди',
      'notification_setup': 'Налаштування сповіщень',
      'goal_review': 'Перегляд звіту цілі',
      'weekly_challenge': 'Тижневий челендж',
      'early_challenge': 'Раннє завершення челенджу',
      'feedback_given': 'Відгук спільноти',
      'challenge_explore': 'Перегляд челенджів',
    };
    return descriptions[eventType] ?? 'Невідомий тип події';
  }

  // ── Розширені розрахунки ──────────────────────────────────────────────

  /// Розраховує загальну суму XP за день з історії.
  ///
  /// [history] — історія записів XP.
  /// [date] — дата для підрахунку (за замовчуванням — сьогодні).
  static int getTotalXpForDay(List<XPHistoryEntry> history, {DateTime? date}) {
    final targetDate = date ?? DateTime.now();
    return history
        .where((e) =>
            e.timestamp.year == targetDate.year &&
            e.timestamp.month == targetDate.month &&
            e.timestamp.day == targetDate.day)
        .fold<int>(0, (sum, e) => sum + e.xpAmount);
  }

  /// Розраховує загальну суму XP за тиждень з історії.
  ///
  /// [history] — історія записів XP.
  /// [weekStart] — початок тижня (за замовчуванням — 7 днів назад).
  static int getTotalXpForWeek(
    List<XPHistoryEntry> history, {
    DateTime? weekStart,
  }) {
    final start = weekStart ?? DateTime.now().subtract(const Duration(days: 7));
    return history
        .where((e) => e.timestamp.isAfter(start))
        .fold<int>(0, (sum, e) => sum + e.xpAmount);
  }

  /// Розраховує загальну суму XP за місяць з історії.
  ///
  /// [history] — історія записів XP.
  /// [monthStart] — початок місяця (за замовчуванням — 30 днів назад).
  static int getTotalXpForMonth(
    List<XPHistoryEntry> history, {
    DateTime? monthStart,
  }) {
    final start = monthStart ?? DateTime.now().subtract(const Duration(days: 30));
    return history
        .where((e) => e.timestamp.isAfter(start))
        .fold<int>(0, (sum, e) => sum + e.xpAmount);
  }

  /// Повертає середнє XP за день з історії.
  ///
  /// [history] — історія записів XP.
  /// [days] — кількість днів для аналізу (за замовчуванням — 7).
  static double getAverageDailyXp(List<XPHistoryEntry> history, {int days = 7}) {
    if (history.isEmpty || days <= 0) return 0.0;
    final cutoff = DateTime.now().subtract(Duration(days: days));
    final recent = history.where((e) => e.timestamp.isAfter(cutoff)).toList();
    if (recent.isEmpty) return 0.0;
    final total = recent.fold<int>(0, (sum, e) => sum + e.xpAmount);
    return total / days;
  }

  /// Повертає найкращий день за XP з історії.
  ///
  /// [history] — історія записів XP.
  /// Повертає мапу з датою та сумою XP.
  static Map<String, dynamic>? getBestDay(List<XPHistoryEntry> history) {
    if (history.isEmpty) return null;
    final dailyTotals = <String, int>{};
    for (final entry in history) {
      final dayKey = '${entry.timestamp.year}-${entry.timestamp.month}-${entry.timestamp.day}';
      dailyTotals[dayKey] = (dailyTotals[dayKey] ?? 0) + entry.xpAmount;
    }
    if (dailyTotals.isEmpty) return null;
    var bestDay = '';
    var bestXp = 0;
    dailyTotals.forEach((day, xp) {
      if (xp > bestXp) {
        bestXp = xp;
        bestDay = day;
      }
    });
    return {'date': bestDay, 'xp': bestXp};
  }

  /// Повертає кількість унікальних днів з XP-активністю.
  ///
  /// [history] — історія записів XP.
  /// [days] — кількість днів для аналізу.
  static int getActiveDaysCount(
    List<XPHistoryEntry> history, {
    int days = 7,
  }) {
    if (history.isEmpty || days <= 0) return 0;
    final cutoff = DateTime.now().subtract(Duration(days: days));
    final activeDays = history
        .where((e) => e.timestamp.isAfter(cutoff))
        .map((e) =>
            '${e.timestamp.year}-${e.timestamp.month}-${e.timestamp.day}')
        .toSet();
    return activeDays.length;
  }

  /// Обчислює XP за депозит на основі суми поповнення.
  ///
  /// Великі поповнення дають більше XP.
  /// [amount] — сума поповнення в гривнях.
  static int calculateDepositXp(double amount) {
    if (amount <= 0) return 0;
    if (amount < 50) return 3;
    if (amount < 100) return 5;
    if (amount < 500) return 8;
    if (amount < 1000) return 12;
    if (amount < 5000) return 20;
    if (amount < 10000) return 30;
    return 50;
  }

  /// Обчислює монети за депозит на основі суми поповнення.
  ///
  /// [amount] — сума поповнення в гривнях.
  static int calculateDepositCoins(double amount) {
    if (amount <= 0) return 0;
    if (amount < 50) return 1;
    if (amount < 100) return 2;
    if (amount < 500) return 5;
    if (amount < 1000) return 8;
    if (amount < 5000) return 15;
    if (amount < 10000) return 25;
    return 40;
  }

  /// Повертає опис XP події українською.
  ///
  /// [eventType] — тип події.
  static String getEventDescription(String eventType) {
    switch (eventType) {
      case 'daily_login':
        return 'Щоденний вхід у додаток';
      case 'first_transaction':
        return 'Перша транзакція дня';
      case 'transaction':
        return 'Транзакція';
      case 'challenge':
        return 'Челендж';
      case 'challenge_complete':
        return 'Завершення челенджу';
      case 'challenge_explore':
        return 'Огляд челенджів';
      case 'goal_complete':
        return 'Досягнення цілі';
      case 'goal_create':
        return 'Створення цілі';
      case 'goal_review':
        return 'Перегляд звіту цілі';
      case 'badge_unlock':
        return 'Розблокування бейджу';
      case 'return_bonus':
        return 'Повернення після перерви';
      case 'round_up':
        return 'Функція round-up';
      case 'analytics_view':
        return 'Перегляд аналітики';
      case 'profile_setup':
        return 'Налаштування профілю';
      case 'profile_complete':
        return 'Заповнення профілю';
      case 'profile_photo':
        return 'Фото профілю';
      case 'onboarding_step':
        return 'Крок онбордингу';
      case 'join_team':
        return 'Приєднання до команди';
      case 'notification_setup':
        return 'Налаштування сповіщень';
      case 'weekly_challenge':
        return 'Тижневий челендж';
      case 'early_challenge':
        return 'Раннє завершення челенджу';
      case 'feedback_given':
        return 'Відгук спільноті';
      case 'streak_bonus':
        return 'Бонус за серію';
      case 'streak_milestone':
        return 'Етап серії';
      default:
        return eventType;
    }
  }

  /// Повертає множник XP за день тижня.
  ///
  /// [weekday] — день тижня (1 = понеділок, 7 = неділя).
  static double getWeekdayMultiplier(int weekday) {
    switch (weekday) {
      case 6: // Субота
        return 0.9;
      case 7: // Неділя
        return 0.85;
      case 1: // Понеділок — найпродуктивніший
        return 1.1;
      case 5: // П'ятниця — добре
        return 1.05;
      default:
        return 1.0;
    }
  }

  /// Повертає множник XP за час доби.
  ///
  /// [hour] — година доби (0-23).
  static double getHourMultiplier(int hour) {
    if (hour >= 6 && hour <= 9) return 1.1; // Ранок — мотивація
    if (hour >= 12 && hour <= 14) return 0.9; // Обід — менше активності
    if (hour >= 18 && hour <= 22) return 1.05; // Вечір — гарний час
    if (hour >= 23 || hour <= 5) return 0.8; // Ніч — мінімум
    return 1.0;
  }

  /// Обчислює преміум-множник.
  ///
  /// [isPremium] — чи має користувач преміум-підписку.
  static double getPremiumMultiplier(bool isPremium) {
    return isPremium ? 1.5 : 1.0;
  }

  /// Повертає повний комбінований множник з усіх джерел.
  ///
  /// Враховує серію, комбо, сезон, місяць, день тижня, час доби, преміум.
  static double getFullMultiplier({
    int streakDays = 0,
    int dailyTransactions = 1,
    bool isWeekend = false,
    int currentMonth = 1,
    int? weekday,
    int? hour,
    bool isPremium = false,
  }) {
    final streak = getStreakMultiplier(streakDays);
    final combo = getComboMultiplier(dailyTransactions);
    final seasonal = _monthlyMultipliers[currentMonth] ?? 1.0;
    final weekend = isWeekend ? _weekendMultiplier : 1.0;
    final weekDay = weekday != null ? getWeekdayMultiplier(weekday) : 1.0;
    final timeOfDay = hour != null ? getHourMultiplier(hour) : 1.0;
    final premium = getPremiumMultiplier(isPremium);
    return streak * combo * seasonal * weekend * weekDay * timeOfDay * premium;
  }

  /// Повертає список усіх етапів серії з описом.
  ///
  /// Повертає мапу, де ключ — кількість днів серії, значення — назва етапу.
  static Map<int, String> getAllStreakMilestoneNames() =>
      Map.unmodifiable(_streakMilestoneNames);

  /// Повертає XP за конкретний етап серії.
  ///
  /// [streakDays] — тривалість серії.
  static int getStreakMilestoneXp(int streakDays) {
    int total = 0;
    for (final entry in _streakMilestoneXp.entries) {
      if (streakDays >= entry.key) total += entry.value;
    }
    return total;
  }

  /// Перевіряє, чи користувач наблизився до наступного етапу серії.
  ///
  /// Повертає назву наступного етапу або `null`.
  static String? getNextStreakMilestone(int streakDays) {
    int? nextMilestone;
    for (final entry in _streakMilestoneXp.keys) {
      if (entry > streakDays) {
        nextMilestone = entry;
        break;
      }
    }
    if (nextMilestone == null) return null;
    return _streakMilestoneNames[nextMilestone];
  }

  /// Розраховує днів до наступного етапу серії.
  ///
  /// Повертає кількість днів або -1, якщо всі етапи пройдено.
  static int daysToNextStreakMilestone(int streakDays) {
    int? nextMilestone;
    for (final entry in _streakMilestoneXp.keys) {
      if (entry > streakDays) {
        nextMilestone = entry;
        break;
      }
    }
    if (nextMilestone == null) return -1;
    return nextMilestone - streakDays;
  }

  /// Розраховує прогрес до наступного етапу серії у відсотках.
  ///
  /// [streakDays] — поточна тривалість серії.
  /// Повертає значення від 0.0 до 1.0.
  static double getStreakMilestoneProgress(int streakDays) {
    int? prevMilestone;
    int? nextMilestone;
    for (final entry in _streakMilestoneXp.keys) {
      if (entry <= streakDays) {
        prevMilestone = entry;
      } else {
        nextMilestone = entry;
        break;
      }
    }
    if (nextMilestone == null) return 1.0;
    if (prevMilestone == null) return 0.0;
    final range = nextMilestone - prevMilestone;
    if (range <= 0) return 1.0;
    return ((streakDays - prevMilestone) / range).clamp(0.0, 1.0);
  }

  /// Повертає всі Unlock-функції для вказаного рівня та всіх нижчих.
  ///
  /// [maxLevel] — максимальний рівень (включно).
  static List<String> getUnlocksUpToLevel(int maxLevel) {
    final unlocks = <String>[];
    for (int i = 0; i < maxLevel && i < _levelUnlocks.length; i++) {
      unlocks.add(_levelUnlocks[i]);
    }
    return unlocks;
  }

  /// Повертає повну інформацію про всі рівні.
  ///
  /// Кожен елемент містить назву, емодзі, поріг XP та опис.
  static List<Map<String, dynamic>> getAllLevelData() {
    final data = <Map<String, dynamic>>[];
    for (int i = 0; i < _levelNames.length; i++) {
      data.add({
        'level': i + 1,
        'name': _levelNames[i],
        'emoji': _levelEmojis[i],
        'xpThreshold': _levelThresholds[i],
        'xpForNext': i + 1 < _levelThresholds.length
            ? _levelThresholds[i + 1]
            : null,
        'unlocks': _levelUnlocks[i],
        'description': _levelDescriptions[i],
        'color': _levelColors[i],
      });
    }
    return data;
  }

  /// ПовертаєXP, необхідне для переходу з [fromLevel] на [toLevel].
  ///
  /// Якщо рівні однакові, повертає 0.
  static int getXpBetweenLevels(int fromLevel, int toLevel) {
    if (fromLevel >= toLevel) return 0;
    final fromThreshold = getXpForLevel(fromLevel) ?? 0;
    final toThreshold = getXpForLevel(toLevel) ?? 0;
    return (toThreshold - fromThreshold).clamp(0, toThreshold);
  }

  /// Розраховує орієнтовний час досягнення максимального рівня.
  ///
  /// [averageDailyXp] — середньоденове XP користувача.
  /// [currentXp] — поточне XP.
  static int estimateDaysToMaxLevel(int averageDailyXp, int currentXp) {
    if (averageDailyXp <= 0) return -1;
    final maxThreshold = _levelThresholds.last;
    final remaining = (maxThreshold - currentXp).clamp(0, maxThreshold);
    return (remaining / averageDailyXp).ceil();
  }

  /// Перевіряє, чи XP значення валідне.
  ///
  /// [xp] — значення XP для перевірки.
  /// Повертає список проблем (порожній = валідно).
  static List<String> validateXp(int xp) {
    final issues = <String>[];
    if (xp < 0) {
      issues.add('XP не може бути негативним: $xp');
    }
    if (xp > _dailyXpCap) {
      issues.add('XP перевищує денний ліміт ($xp > $_dailyXpCap)');
    }
    return issues;
  }

  /// Застосовує обидва ліміти (денний та тижневий).
  ///
  /// Повертає XP після застосування обох обмежень.
  static int applyBothCaps(int xp, int todayXp, int weekXp) {
    final afterDaily = applyDailyCap(xp, todayXp);
    return applyWeeklyCap(afterDaily, weekXp);
  }

  /// Обчислює розрив між поточним XP та порогом рівня.
  ///
  /// [currentXp] — поточне XP.
  /// [level] — номер рівня для порівняння.
  static int getXpGapToLevel(int currentXp, int level) {
    final threshold = getXpForLevel(level) ?? 0;
    return (threshold - currentXp).clamp(0, threshold);
  }

  /// Перевіряє, чи існує тип події.
  ///
  /// [eventType] — тип події для перевірки.
  static bool isValidEventType(String eventType) {
    return getAllSpecialEventTypes().contains(eventType);
  }

  /// Повертає поради для оптимізації XP на основі історії.
  ///
  /// Аналізує історію та пропонує дії для прискорення набуття XP.
  static List<XPOptimizationSuggestion> getOptimizationSuggestions({
    required List<XPHistoryEntry> history,
    int streakDays = 0,
    int dailyTransactions = 0,
  }) {
    final suggestions = <XPOptimizationSuggestion>[];

    // Перевіряємо серію
    if (streakDays < 3) {
      suggestions.add(XPOptimizationSuggestion(
        action: 'streak',
        potentialXP: 15,
        description: 'Зроби 3-денну серію для бонусу +15 XP!',
        priority: 5,
      ));
    }
    if (streakDays < 7) {
      suggestions.add(XPOptimizationSuggestion(
        action: 'streak',
        potentialXP: 50,
        description: 'Досягни тижневої серії для бонусу +50 XP!',
        priority: 4,
      ));
    }

    // Перевіряємо комбо
    if (dailyTransactions < 3) {
      suggestions.add(XPOptimizationSuggestion(
        action: 'more_transactions',
        potentialXP: 10,
        description: 'Зроби ще ${3 - dailyTransactions} транзакцій для комбо-множника x1.2!',
        priority: 4,
      ));
    }

    // Челенджі
    suggestions.add(XPOptimizationSuggestion(
      action: 'challenge',
      potentialXP: 50,
      description: 'Виконай челендж для +50 XP та +25 монет!',
      priority: 5,
    ));

    // Перший депозит
    suggestions.add(XPOptimizationSuggestion(
      action: 'first_deposit',
      potentialXP: 30,
      description: 'Зроби перше поповнення скарбнички для +30 XP!',
      priority: 3,
    ));

    // Профіль
    suggestions.add(XPOptimizationSuggestion(
      action: 'profile',
      potentialXP: 40,
      description: 'Заповни профіль та додай фото для +40 XP!',
      priority: 2,
      isPremium: false,
    ));

    // Сортуємо за пріоритетом (найвищий першим)
    suggestions.sort((a, b) => b.priority.compareTo(a.priority));
    return suggestions;
  }

  // ── XP аналітика та історія ─────────────────────────────────────

  /// Обчислює середньоденне XP з історії записів.
  ///
  /// [history] — історія записів XP.
  /// [daysBack] — скільки останніх днів аналізувати (0 = вся історія).
  static double calculateAverageDailyXp(List<XPHistoryEntry> history, {int daysBack = 0}) {
    if (history.isEmpty) return 0.0;

    DateTime? cutoff;
    if (daysBack > 0) {
      cutoff = DateTime.now().subtract(Duration(days: daysBack));
    }

    final filtered = cutoff != null
        ? history.where((e) => e.timestamp.isAfter(cutoff))
        : history;

    if (filtered.isEmpty) return 0.0;

    // Групуємо за днями
    final dailyTotals = <DateTime, int>{};
    for (final entry in filtered) {
      final day = DateTime(
        entry.timestamp.year,
        entry.timestamp.month,
        entry.timestamp.day,
      );
      dailyTotals[day] = (dailyTotals[day] ?? 0) + entry.xpAmount;
    }

    if (dailyTotals.isEmpty) return 0.0;

    final totalXp = dailyTotals.values.fold<int>(0, (a, b) => a + b);
    return totalXp / dailyTotals.length;
  }

  /// Обчислює середньотижневе XP з історії.
  ///
  /// [history] — історія записів XP.
  static double calculateAverageWeeklyXp(List<XPHistoryEntry> history) {
    if (history.isEmpty) return 0.0;

    // Групуємо за тижнями
    final weeklyTotals = <int, int>{};
    for (final entry in history) {
      final weekNumber = _getWeekNumber(entry.timestamp);
      weeklyTotals[weekNumber] = (weeklyTotals[weekNumber] ?? 0) + entry.xpAmount;
    }

    if (weeklyTotals.isEmpty) return 0.0;

    final totalXp = weeklyTotals.values.fold<int>(0, (a, b) => a + b);
    return totalXp / weeklyTotals.length;
  }

  /// Повертає номер тижня для дати.
  ///
  /// Використовується для групування по тижнях.
  static int _getWeekNumber(DateTime date) {
    final dayOfYear = date.difference(DateTime(date.year)).inDays;
    return ((dayOfYear + date.weekday) / 7).ceil();
  }

  /// Обчислює XP за останні N днів з історії.
  ///
  /// [history] — історія записів XP.
  /// [days] — кількість днів.
  static int calculateXpLastNDays(List<XPHistoryEntry> history, int days) {
    if (history.isEmpty || days <= 0) return 0;
    final cutoff = DateTime.now().subtract(Duration(days: days));
    return history
        .where((e) => e.timestamp.isAfter(cutoff))
        .fold<int>(0, (sum, e) => sum + e.xpAmount);
  }

  /// Обчислює XP за останню годину з історії.
  ///
  /// [history] — історія записів XP.
  static int calculateXpLastHour(List<XPHistoryEntry> history) {
    if (history.isEmpty) return 0;
    final cutoff = DateTime.now().subtract(const Duration(hours: 1));
    return history
        .where((e) => e.timestamp.isAfter(cutoff))
        .fold<int>(0, (sum, e) => sum + e.xpAmount);
  }

  /// Обчислює «швидкість XP» — XP за годину за останні 24 години.
  ///
  /// Корисно для аналізу активності користувача.
  static double calculateXpVelocityPerHour(List<XPHistoryEntry> history) {
    final last24Xp = calculateXpLastNDays(history, 1);
    return last24Xp / 24.0;
  }

  /// Обчислює «швидкість XP» — XP за день за останні 7 днів.
  static double calculateXpVelocityPerDay(List<XPHistoryEntry> history) {
    final last7Xp = calculateXpLastNDays(history, 7);
    return last7Xp / 7.0;
  }

  /// Повертає розподіл XP по дням тижня.
  ///
  /// [history] — історія записів XP.
  static Map<int, int> getXpDistributionByDayOfWeek(List<XPHistoryEntry> history) {
    final distribution = <int, int>{};
    for (int i = 1; i <= 7; i++) distribution[i] = 0;

    for (final entry in history) {
      final day = entry.timestamp.weekday;
      distribution[day] = (distribution[day] ?? 0) + entry.xpAmount;
    }

    return distribution;
  }

  /// Повертає найпродуктивніший день тижня.
  ///
  /// [history] — історія записів XP.
  static int getMostProductiveDayOfWeek(List<XPHistoryEntry> history) {
    final dist = getXpDistributionByDayOfWeek(history);
    int bestDay = 1;
    int bestXp = 0;
    dist.forEach((day, xp) {
      if (xp > bestXp) {
        bestXp = xp;
        bestDay = day;
      }
    });
    return bestDay;
  }

  /// Повертає назву дня тижня українською.
  static String getDayNameUk(int weekday) {
    return switch (weekday) {
      1 => 'Понеділок',
      2 => 'Вівторок',
      3 => 'Середа',
      4 => 'Четвер',
      5 => 'П\'ятниця',
      6 => 'Субота',
      7 => 'Неділя',
      _ => 'Невідомий',
    };
  }

  /// Обчислює середній множник, що застосовувався в історії.
  ///
  /// [history] — історія записів XP.
  static double calculateAverageMultiplierUsed(List<XPHistoryEntry> history) {
    if (history.isEmpty) return 1.0;
    final totalMultiplier = history.fold<double>(
      0.0,
      (sum, e) => sum + e.multiplierUsed,
    );
    return totalMultiplier / history.length;
  }

  /// Обчислює загальну кількість монет з повної історії.
  ///
  /// Кожне XP конвертується в монети за курсом 1 монета = 10 XP.
  static int calculateTotalCoinsFromFullHistory(List<XPHistoryEntry> history) {
    return history.fold<int>(0, (sum, e) => sum + (e.xpAmount ~/ 10));
  }

  // ── Прогнозування та визначення ────────────────────────────────────

  /// Обчислює орієнтовну кількість днів до наступного рівня.
  ///
  /// [currentXp] — поточне XP користувача.
  /// [averageDailyXp] — середньоденне XP користувача (обов'язково > 0).
  static int estimateDaysToNextLevel(int currentXp, int currentLevel, {required int averageDailyXp}) {
    if (averageDailyXp <= 0) return -1;

    final nextLevelInfo = getNextLevel(currentXp, currentLevel);
    if (nextLevelInfo == null) return -1;

    final xpNeeded = nextLevelInfo.xpRequired - nextLevelInfo.currentLevelXp;
    if (xpNeeded <= 0) return 0;

    return (xpNeeded / averageDailyXp).ceil();
  }

  /// Обчислює XP, необхідне для досягнення конкретного рівня.
  ///
  /// [targetLevel] — цільовий рівень.
  static int? xpRequiredForLevel(int targetLevel) {
    if (targetLevel < 1 || targetLevel > _levelNames.length) return null;
    return _levelThresholds[targetLevel - 1];
  }

  /// Обчислює загальний XP, нарахований за тип події з історії.
  ///
  /// [history] — історія записів XP.
  /// [eventType] — тип події для фільтрації.
  static int getXpByEventType(List<XPHistoryEntry> history, String eventType) {
    return history
        .where((e) => e.eventType == eventType)
        .fold<int>(0, (sum, e) => sum + e.xpAmount);
  }

  /// Обчислює загальну кількість монет за тип події з історії.
  ///
  /// [history] — історія записів XP.
  /// [eventType] — тип події.
  static int getCoinsByEventType(List<XPHistoryEntry> history, String eventType) {
    return (getXpByEventType(history, eventType) ~/ 10);
  }

  /// Повертає розподіл типів подій в історії.
  ///
  /// [history] — історія записів XP.
  static Map<String, int> getEventTypeDistribution(List<XPHistoryEntry> history) {
    final distribution = <String, int>{};
    for (final entry in history) {
      distribution[entry.eventType] =
          (distribution[entry.eventType] ?? 0) + entry.xpAmount;
    }
    return distribution;
  }

  /// Повертає найприбутковіший тип події.
  ///
  /// [history] — історія записів XP.
  static String? getMostRewardingEventType(List<XPHistoryEntry> history) {
    if (history.isEmpty) return null;
    final dist = getEventTypeDistribution(history);
    if (dist.isEmpty) return null;

    String bestType = '';
    int bestXp = 0;
    dist.forEach((type, xp) {
      if (xp > bestXp) {
        bestXp = xp;
        bestType = type;
      }
    });
    return bestType;
  }

  /// Повертає поради на основі XP аналітики.
  ///
  /// Аналізує історію та пропонує конкретні дії.
  static List<XPOptimizationSuggestion> getAnalyticsBasedSuggestions({
    required List<XPHistoryEntry> history,
    required int streakDays,
    int currentLevel = 1,
    int currentXp = 0,
  }) {
    final suggestions = <XPOptimizationSuggestion>[];

    final avgDailyXp = calculateAverageDailyXp(history, daysBack: 7);
    final nextLevelDays = estimateDaysToNextLevel(currentXp, currentLevel, averageDailyXp: avgDailyXp.round());

    // Аналіз активності по днях тижня
    final dayDist = getXpDistributionByDayOfWeek(history);
    final today = DateTime.now().weekday;
    final todayXp = dayDist[today] ?? 0;
    final avgDayXp = dayDist.isNotEmpty
        ? dayDist.values.reduce((a, b) => a + b) / dayDist.length
        : 0;

    if (todayXp < avgDayXp * 0.5 && avgDayXp > 0) {
      suggestions.add(XPOptimizationSuggestion(
        action: 'today_activity',
        potentialXP: (avgDayXp - todayXp).round(),
        description: 'Сьогодні активність нижча за середню. Зроби ще запис, щоб не втратити XP!',
        priority: 4,
      ));
    }

    // Рекомендація по днях
    final mostProductive = getMostProductiveDayOfWeek(history);
    if (mostProductive > 0) {
      suggestions.add(XPOptimizationSuggestion(
        action: 'day_optimization',
        potentialXP: dayDist[mostProductive] ?? 0,
        description: 'Найкращий день — ${getDayNameUk(mostProductive)}. Плануй активність!',
        priority: 2,
      ));
    }

    // Множник
    final avgMult = calculateAverageMultiplierUsed(history);
    if (avgMult < 1.2) {
      suggestions.add(XPOptimizationSuggestion(
        action: 'multiplier_boost',
        potentialXP: 20,
        description: 'Підтримуй серію для множника x1.2+ та більше XP!',
        priority: 5,
      ));
    }

    // Прогноз
    if (nextLevelDays > 0 && nextLevelDays <= 7) {
      suggestions.add(XPOptimizationSuggestion(
        action: 'almost_there',
        potentialXP: _levelThresholds[currentLevel.clamp(0, _levelThresholds.length - 1)] - currentXp,
        description: 'До наступного рівня ~$nextLevelDays днів. Не зупиняйся зараз!',
        priority: 5,
      ));
    }

    // Сортуємо за пріоритетом
    suggestions.sort((a, b) => b.priority.compareTo(a.priority));
    return suggestions;
  }

  // ── Валідація XP ────────────────────────────────────────────────────

  /// Повертає повний звіт про валідацію XP операції.
  ///
  /// Перевіряє тип транзакції, значення XP, множник, ліміти.
  static Map<String, dynamic> validateXpOperation({
    required TransactionType type,
    required int baseXp,
    required double multiplier,
    int todayXpEarned = 0,
    int weekXpEarned = 0,
    int streakDays = 0,
  }) {
    final warnings = <String>[];
    final errors = <String>[];

    // Перевірка базового XP
    if (baseXp < 0) {
      errors.add('Базове XP не може бути негативним: $baseXp');
    }

    // Перевірка множника
    if (multiplier < 0) {
      errors.add('Множник не може бути негативним: $multiplier');
    }
    if (multiplier > 5.0) {
      warnings.add('Множник дуже високий ($multiplier). Можливо помилка?');
    }

    // Перевірка лімітів
    final projectedXp = (baseXp * multiplier).round();
    if (isDailyCapReached(todayXpEarned, projectedXp)) {
      warnings.add('Денний ліміт XP буде досягнуто');
    }
    if (_weeklyXpCap > 0 && weekXpEarned + projectedXp > _weeklyXpCap) {
      warnings.add('Тижневий ліміт XP може бути досягнуто');
    }

    // Перевірка серії
    if (streakDays < 0) {
      errors.add('Кількість днів серії не може бути негативною: $streakDays');
    }

    return {
      'valid': errors.isEmpty,
      'type': type.name,
      'baseXp': baseXp,
      'multiplier': multiplier,
      'projectedXp': projectedXp,
      'warnings': warnings,
      'errors': errors,
      'dailyCapReached': isDailyCapReached(todayXpEarned, projectedXp),
      'dailyRemaining': remainingDailyXp(todayXpEarned),
      'weeklyRemaining': remainingWeeklyXp(weekXpEarned),
    };
  }

  /// Перевіряє, чи перехід на рівень коректний.
  ///
  /// Перевіряє, що новий рівень > поточного та в межах допустимих.
  static Map<String, dynamic> validateLevelTransition({
    required int currentLevel,
    required int newLevel,
    required int currentXp,
  }) {
    final issues = <String>[];

    if (newLevel <= currentLevel) {
      issues.add('Новий рівень ($newLevel) не може бути ≤ поточного ($currentLevel)');
    }
    if (newLevel > _levelNames.length) {
      issues.add('Рівень $newLevel перевищує максимум (${_levelNames.length})');
    }
    if (newLevel < 1) {
      issues.add('Рівень не може бути < 1');
    }
    if (currentXp < 0) {
      issues.add('XP не може бути негативним: $currentXp');
    }

    // Перевіряємо, чи XP достатньо для цього рівня
    if (issues.isEmpty) {
      final requiredXp = _levelThresholds[newLevel - 1];
      if (currentXp < requiredXp) {
        issues.add('XP ($currentXp) недостатньо для рівня $newLevel (потрібно: $requiredXp)');
      }
    }

    return {
      'valid': issues.isEmpty,
      'currentLevel': currentLevel,
      'newLevel': newLevel,
      'currentXp': currentXp,
      'requiredXp': newLevel <= _levelNames.length ? _levelThresholds[newLevel - 1] : null,
      'issues': issues,
    };
  }

  /// Повертає повний XP-профіль користувача.
  ///
  /// Включає: рівень, прогрес, XP, множники, серію, монети, рекомендації.
  static Map<String, dynamic> generateFullUserProfile({
    required int currentXp,
    required int currentLevel,
    required List<XPHistoryEntry> history,
    int streakDays = 0,
    int todayXpEarned = 0,
    int weekXpEarned = 0,
    int totalCoins = 0,
  }) {
    final levelProgress = getLevelProgress(currentXp, currentLevel);
    final nextLevel = getNextLevel(currentXp, currentLevel);
    final avgDailyXp = calculateAverageDailyXp(history, daysBack: 7);
    final avgWeeklyXp = calculateAverageWeeklyXp(history);
    const streakMultiplier = 1.0; // Базове значення

    return {
      'level': {
        'current': currentLevel,
        'name': getLevelName(currentLevel),
        'emoji': getLevelEmoji(currentLevel),
        'color': getLevelColor(currentLevel).toARGB32(),
        'description': getLevelDescription(currentLevel),
        'progress': levelProgress,
        'progressPercent': (levelProgress * 100).toStringAsFixed(1),
        'nextLevel': nextLevel?.toMap(),
      },
      'xp': {
        'current': currentXp,
        'max': _levelThresholds.last,
        'xpToMax': (_levelThresholds.last - currentXp).clamp(0, _levelThresholds.last),
        'averageDaily': avgDailyXp.toStringAsFixed(1),
        'averageWeekly': avgWeeklyXp.toStringAsFixed(1),
        'todayEarned': todayXpEarned,
        'weekEarned': weekXpEarned,
        'dailyRemaining': remainingDailyXp(todayXpEarned),
        'weeklyRemaining': remainingWeeklyXp(weekXpEarned),
      },
      'streak': {
        'days': streakDays,
        'multiplier': streakMultiplier,
        'nextMilestone': _getNextStreakMilestone(streakDays),
        'milestoneName': _getStreakMilestoneName(streakDays),
      },
      'coins': {
        'total': totalCoins,
      },
      'statistics': {
        'totalEntries': history.length,
        'averageMultiplier': calculateAverageMultiplierUsed(history).toStringAsFixed(2),
        'mostRewardingEvent': getMostRewardingEventType(history),
      },
    };
  }

  /// Повертає назву наступного етапу серії.
  static String _getStreakMilestoneName(int streakDays) {
    for (final entry in _streakMilestoneNames.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key))) {
      if (streakDays < entry.key) return entry.value;
    }
    if (streakDays >= 365) return 'Річний чемпіон';
    return '';
  }

  /// Повертає XP наступного етапу серії.
  static int _getNextStreakMilestone(int streakDays) {
    for (final entry in _streakMilestoneXp.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key))) {
      if (streakDays < entry.key) return entry.key;
    }
    return 365;
  }

  /// Обчислює XP за "ідеальний" тиждень (всі бонуси).
  ///
  /// Максимальний XP = базове за всі транзакції + всі бонуси.
  static int calculateMaxPossibleWeeklyXp() {
    // Враховує: 7 щоденних входів + 7 транзакцій + 1 челендж + 1 бейдж
    return dailyLoginXp * 7 +
        (_baseXpTable[TransactionType.manual] ?? 0) * 7 +
        challengeCompletionXp +
        badgeUnlockXp +
        goalCompletionXp;
  }

  /// Обчислює XP за "ідеальний" місяць (30 днів).
  static int calculateMaxPossibleMonthlyXp() {
    return calculateMaxPossibleWeeklyXp() * 4 +
        weeklyChallengeXp * 4;
  }

  /// Генерує текстовий звіт про активність користувача.
  ///
  /// [history] — історія записів XP.
  static String generateActivityReport(List<XPHistoryEntry> history) {
    if (history.isEmpty) return '📊 Немає даних про активність.';

    final buffer = StringBuffer();
    buffer.writeln('=== Звіт про активність XP ===');
    buffer.writeln('');

    // Загальна статистика
    buffer.writeln('Загальне XP: ${history.fold<int>(0, (s, e) => s + e.xpAmount)}');
    buffer.writeln('Записів: ${history.length}');
    buffer.writeln('Середній множник: ${calculateAverageMultiplierUsed(history).toStringAsFixed(2)}x');
    buffer.writeln('Монет: ~${calculateTotalCoinsFromFullHistory(history)}');
    buffer.writeln('');

    // Щоденне XP
    final avgDaily = calculateAverageDailyXp(history);
    buffer.writeln('Середньоденне XP: ${avgDaily.toStringAsFixed(1)}');
    buffer.writeln('Середньотижневе XP: ${calculateAverageWeeklyXp(history).toStringAsFixed(1)}');
    buffer.writeln('XP за останню годину: ${calculateXpLastHour(history)}');
    buffer.writeln('XP за останні 7 днів: ${calculateXpLastNDays(history, 7)}');
    buffer.writeln('');

    // Найкращий день
    final bestDay = getMostProductiveDayOfWeek(history);
    if (bestDay > 0) {
      buffer.writeln('Найкращий день: ${getDayNameUk(bestDay)}');
    }
    final bestEvent = getMostRewardingEventType(history);
    if (bestEvent != null) {
      buffer.writeln('Найприбутковіший тип: $bestEvent');
    }

    return buffer.toString();
  }

  // ── Crash report ─────────────────────────────────────────────────

  /// Повертає повний стан калькулятора для crash-репорту.
  static Map<String, dynamic> getDiagnosticData() {
    return {
      'totalLevels': getTotalLevels(),
      'currentMultiplier': _baseMultiplier,
      'dailyXpCap': _dailyXpCap,
      'weeklyXpCap': _weeklyXpCap,
      'comboMultipliers': _comboMultipliers,
      'streakMultipliers': _streakMultipliers,
      'monthlyMultipliers': _monthlyMultipliers,
      'levelThresholds': _levelThresholds,
      'levelNames': _levelNames,
      'streakMilestoneXp': _streakMilestoneXp,
      'streakMilestoneNames': _streakMilestoneNames,
      'baseXpTable': _baseXpTable.map((k, v) => k.name),
    };
  }

  // ── Часові бонуси ─────────────────────────────────────────────────────

  /// Часовий добовий бонус XP за години активності.
  static const Map<int, double> _hourlyBonusMultipliers = {
    6: 1.1,  // Ранок — легкий бонус
    7: 1.2,  // Ранкова рутина
    8: 1.15, // До роботи
    12: 1.0, // Обід — стандарт
    18: 1.1, // Вечірній початок
    19: 1.2,  // Вечірня активність
    20: 1.25, // Пік вечірньої активності
    21: 1.2,  // Пізній вечір
    22: 1.1,  // Пізній вечір
  };

  /// Повертає часовий бонус множника за годину доби.
  ///
  /// [hour] — година (0–23).
  static double getHourlyBonus(int hour) {
    return _hourlyBonusMultipliers[hour] ?? 1.0;
  }

  /// Повертає опис часового періоду українською.
  static String getTimePeriodDescription(int hour) {
    if (hour >= 5 && hour < 9) return 'Ранкова активність ☀️';
    if (hour >= 9 && hour < 12) return 'Дообідній час 🌤️';
    if (hour >= 12 && hour < 14) return 'Обідня перерва 🍽️';
    if (hour >= 14 && hour < 18) return 'Післяобідній час 🏢';
    if (hour >= 18 && hour < 21) return 'Вечірня активність 🌆';
    if (hour >= 21 && hour < 23) return 'Пізній вечір 🌙';
    return 'Нічний час 🌜';
  }

  /// Чи є поточний час піковим для XP (19:00–21:00).
  static bool isPeakXpHour(int hour) => hour >= 19 && hour <= 21;

  /// Чи є поточний час активним для бонусу (6:00–9:00, 18:00–22:00).
  static bool isActiveXpHour(int hour) =>
      (hour >= 6 && hour <= 9) || (hour >= 18 && hour <= 22);

  // ── Валідація ────────────────────────────────────────────────────────

  /// Валідує вхідні дані для розрахунку XP.
  ///
  /// Повертає `null` якщо все ОК, або рядок з описом помилки.
  static String? validateXpInput({
    required int currentXp,
    required int currentLevel,
    required int todayXpEarned,
    required int streakDays,
  }) {
    if (currentXp < 0) return 'XP не може бути від\'ємним';
    if (currentLevel < 1) return 'Рівень не може бути менше 1';
    if (currentLevel > getTotalLevels()) {
      return 'Рівень не може перевищувати ${getTotalLevels()}';
    }
    if (todayXpEarned < 0) return 'XP за сьогодні не може бути від\'ємним';
    if (todayXpEarned > _dailyXpCap) {
      return 'XP за сьогодні перевищує денний ліміт ($_dailyXpCap)';
    }
    if (streakDays < 0) return 'Серія не може бути від\'ємною';
    return null;
  }

  /// Валідує множник на предмет розумних меж.
  ///
  /// Повертає `true` якщо множник в межах [0.1, 5.0].
  static bool isMultiplierValid(double multiplier) {
    return multiplier >= 0.1 && multiplier <= 5.0;
  }

  /// Обмежує множник до допустимих меж.
  static double clampMultiplier(double multiplier) {
    return multiplier.clamp(0.1, 5.0);
  }

  // ── Анти-спам захист ────────────────────────────────────────────────

  /// Мінімальний інтервал між однаковими подіями (в секундах).
  static const int _minEventIntervalSeconds = 5;

  /// Максимальна кількість однакових подій за годину.
  static const int _maxEventsPerHour = 60;

  /// Максимальна кількість однакових подій за хвилину.
  static const int _maxEventsPerMinute = 10;

  /// Чи допустима подія (anti-spam перевірка).
  ///
  /// [eventType] — тип події.
  /// [lastEventTime] — час останньої події цього типу.
  /// [recentCount] — кількість подій цього типу за останню годину.
  static bool isEventAllowed({
    required String eventType,
    required DateTime? lastEventTime,
    required int recentCount,
  }) {
    if (lastEventTime == null) return true;
    final elapsed = DateTime.now().difference(lastEventTime).inSeconds;
    if (elapsed < _minEventIntervalSeconds) return false;
    if (recentCount >= _maxEventsPerHour) return false;
    return true;
  }

  /// Повертає залишок часу до наступної допустимої події (в секундах).
  ///
  /// Повертає 0 якщо подія вже допустима.
  static int secondsUntilNextEvent(DateTime? lastEventTime) {
    if (lastEventTime == null) return 0;
    final elapsed = DateTime.now().difference(lastEventTime).inSeconds;
    if (elapsed >= _minEventIntervalSeconds) return 0;
    return _minEventIntervalSeconds - elapsed;
  }

  // ── XP velocity ──────────────────────────────────────────────────────

  /// Розраховує XP за останню годину з історії.
  ///
  /// [history] — історія записів XP.
  static int calculateXpLastHour(List<XPHistoryEntry> history) {
    final oneHourAgo = DateTime.now().subtract(const Duration(hours: 1));
    return history
        .where((e) => e.timestamp.isAfter(oneHourAgo))
        .fold<int>(0, (sum, e) => sum + e.xpAmount);
  }

  /// Розраховує XP за останні N днів з історії.
  ///
  /// [history] — історія записів XP.
  /// [days] — кількість днів.
  static int calculateXpLastNDays(List<XPHistoryEntry> history, int days) {
    final cutoff = DateTime.now().subtract(Duration(days: days));
    return history
        .where((e) => e.timestamp.isAfter(cutoff))
        .fold<int>(0, (sum, e) => sum + e.xpAmount);
  }

  /// Розраховує середньоденне XP з історії.
  static double calculateAverageDailyXp(List<XPHistoryEntry> history) {
    if (history.isEmpty) return 0.0;
    final sorted = List<XPHistoryEntry>.from(history)
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
    final first = sorted.first.timestamp;
    final last = sorted.last.timestamp;
    final totalDays = last.difference(first).inDays;
    if (totalDays < 1) {
      return history.fold<int>(0, (s, e) => s + e.xpAmount).toDouble();
    }
    final totalXp = history.fold<int>(0, (s, e) => s + e.xpAmount);
    return totalXp / totalDays;
  }

  /// Розраховує середньотижневе XP з історії.
  static double calculateAverageWeeklyXp(List<XPHistoryEntry> history) {
    final dailyAvg = calculateAverageDailyXp(history);
    return dailyAvg * 7;
  }

  /// Розраховує середньомісячне XP з історії.
  static double calculateAverageMonthlyXp(List<XPHistoryEntry> history) {
    final dailyAvg = calculateAverageDailyXp(history);
    return dailyAvg * 30;
  }

  // ── День тижня аналітика ─────────────────────────────────────────────

  /// Назви днів тижня українською.
  static const List<String> _dayNamesUk = [
    'Понеділок', 'Вівторок', 'Середа', 'Четвер', 'П\'ятниця', 'Субота', 'Неділя',
  ];

  /// Повертає назву дня тижня українською.
  ///
  /// [weekday] — день тижня (1 = понеділок, 7 = неділя).
  static String getDayNameUk(int weekday) {
    if (weekday < 1 || weekday > 7) return '';
    return _dayNamesUk[weekday - 1];
  }

  /// Повертає найпродуктивніший день тижня з історії.
  ///
  /// Повертає номер дня (1–7) або -1 якщо немає даних.
  static int getMostProductiveDayOfWeek(List<XPHistoryEntry> history) {
    if (history.isEmpty) return -1;
    final dayTotals = List<int>.filled(7, 0);
    for (final entry in history) {
      final weekday = entry.timestamp.weekday; // 1=Mon, 7=Sun
      dayTotals[weekday - 1] += entry.xpAmount;
    }
    int maxDay = 0;
    int maxAmount = dayTotals[0];
    for (int i = 1; i < dayTotals.length; i++) {
      if (dayTotals[i] > maxAmount) {
        maxAmount = dayTotals[i];
        maxDay = i;
      }
    }
    return maxDay + 1;
  }

  /// Повертає XP за кожен день тижня як мапу.
  static Map<int, int> getXpPerDayOfWeek(List<XPHistoryEntry> history) {
    final result = <int, int>{1: 0, 2: 0, 3: 0, 4: 0, 5: 0, 6: 0, 7: 0};
    for (final entry in history) {
      result[entry.timestamp.weekday] =
          (result[entry.timestamp.weekday] ?? 0) + entry.xpAmount;
    }
    return result;
  }

  // ── Найприбутковіші події ────────────────────────────────────────────

  /// Повертає найприбутковіший тип події з історії.
  ///
  /// [history] — історія записів XP.
  static String? getMostRewardingEventType(List<XPHistoryEntry> history) {
    if (history.isEmpty) return null;
    final totals = <String, int>{};
    for (final entry in history) {
      totals[entry.eventType] =
          (totals[entry.eventType] ?? 0) + entry.xpAmount;
    }
    String? bestType;
    int bestTotal = 0;
    totals.forEach((type, total) {
      if (total > bestTotal) {
        bestTotal = total;
        bestType = type;
      }
    });
    return bestType;
  }

  /// Повертає топ-N найприбутковіших подій з історії.
  ///
  /// [history] — історія записів XP.
  /// [n] — кількість результатів (за замовчуванням 5).
  static List<MapEntry<String, int>> getTopRewardingEvents(
    List<XPHistoryEntry> history, {
    int n = 5,
  }) {
    final totals = <String, int>{};
    for (final entry in history) {
      totals[entry.eventType] =
          (totals[entry.eventType] ?? 0) + entry.xpAmount;
    }
    final entries = totals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return entries.take(n).toList();
  }

  // ── Розширена аналітика монет ────────────────────────────────────────

  /// Розраховує загальну кількість монет з повної історії.
  ///
  /// Враховує бонуси за рівні, бейджі та транзакції.
  static int calculateTotalCoinsFromFullHistory(List<XPHistoryEntry> history) {
    int totalCoins = 0;
    int currentLevel = 1;

    for (final entry in history) {
      // Монети за XP (10 XP = 1 монета)
      totalCoins += entry.xpAmount ~/ 10;

      // Бонус за рівень-ап
      if (entry.isTransaction) {
        final newLevel = getLevelForXp(
          history.indexOf(entry) == 0
              ? entry.xpAmount
              : history
                  .take(history.indexOf(entry) + 1)
                  .fold<int>(0, (s, e) => s + e.xpAmount),
        );
        if (newLevel > currentLevel) {
          totalCoins += _levelUpCoinBonus * (newLevel - currentLevel);
          currentLevel = newLevel;
        }
      }

      // Бонус за бейдж
      if (entry.isBadgeUnlock) {
        totalCoins += _badgeCoinBonus;
      }
    }

    return totalCoins;
  }

  /// Розраховує середній використаний множник.
  static double calculateAverageMultiplierUsed(List<XPHistoryEntry> history) {
    if (history.isEmpty) return 1.0;
    final total = history.fold<double>(
      0.0,
      (sum, e) => sum + e.multiplierUsed,
    );
    return total / history.length;
  }

  // ── Мульти-рівневий апгрейд ──────────────────────────────────────────

  /// Обчислює кількість переходів рівнів при великому XP.
  ///
  /// Повертає список з інформацією про кожен перехід.
  static List<Map<String, dynamic>> calculateMultiLevelUp({
    required int currentXp,
    required int previousLevel,
    required int newXp,
  }) {
    final newLevel = getLevelForXp(newXp);
    if (newLevel <= previousLevel) return [];

    final levelsGained = <Map<String, dynamic>>[];
    for (int lvl = previousLevel + 1; lvl <= newLevel; lvl++) {
      levelsGained.add({
        'level': lvl,
        'name': getLevelName(lvl),
        'emoji': getLevelEmoji(lvl),
        'xpThreshold': getXpForLevel(lvl),
        'coins': _levelUpCoinBonus,
      });
    }

    return levelsGained;
  }

  /// Обчислює XP, необхідне для досягнення конкретного рівня.
  ///
  /// [targetLevel] — цільовий рівень.
  /// [currentXp] — поточне XP.
  static int xpNeededForLevel(int targetLevel, int currentXp) {
    final xpThreshold = getXpForLevel(targetLevel);
    if (xpThreshold == null) return 0;
    return (xpThreshold - currentXp).clamp(0, xpThreshold);
  }

  // ── Оптимізація XP ──────────────────────────────────────────────────

  /// Генерує список порад для збільшення XP.
  ///
  /// [history] — історія записів XP.
  /// [currentStreak] — поточна серія днів.
  /// [hasCompletedToday] — чи вже виконано щоденні завдання.
  static List<XPOptimizationSuggestion> generateOptimizationSuggestions({
    required List<XPHistoryEntry> history,
    required int currentStreak,
    required bool hasCompletedToday,
  }) {
    final suggestions = <XPOptimizationSuggestion>[];

    // Порада: серія
    if (currentStreak < 7) {
      suggestions.add(XPOptimizationSuggestion(
        action: 'streak_7',
        potentialXP: 50,
        description: 'Досягни 7-денної серії для бонусу +50 XP!',
        priority: 4,
      ));
    }

    // Порада: челендж
    final hasChallenge = history.any((e) => e.isChallengeRelated);
    if (!hasChallenge) {
      suggestions.add(XPOptimizationSuggestion(
        action: 'complete_challenge',
        potentialXP: 50,
        description: 'Виконай челендж за +50 XP!',
        priority: 5,
      ));
    }

    // Порада: щоденний вхід
    if (!hasCompletedToday) {
      suggestions.add(XPOptimizationSuggestion(
        action: 'daily_login',
        potentialXP: dailyLoginXp,
        description: 'Увійди в додаток сьогодні за +$dailyLoginXp XP',
        priority: 5,
      ));
    }

    // Порада: комбо множник
    final todayCount = history
        .where((e) => e.timestamp.day == DateTime.now().day &&
            e.timestamp.month == DateTime.now().month)
        .length;
    if (todayCount < 5) {
      suggestions.add(XPOptimizationSuggestion(
        action: 'combo_5',
        potentialXP: 15,
        description: 'Зроби 5+ транзакцій за день для множника 1.3x',
        priority: 3,
      ));
    }

    // Порада: серія 30 днів
    if (currentStreak < 30 && currentStreak >= 7) {
      suggestions.add(XPOptimizationSuggestion(
        action: 'streak_30',
        potentialXP: 200,
        description: '30-денна серія дає +200 XP бонус!',
        priority: 3,
      ));
    }

    // Порада: преміум
    suggestions.add(XPOptimizationSuggestion(
      action: 'premium',
      potentialXP: 100,
      description: 'Преміум-підписка дає додатковий множник XP',
      priority: 1,
      isPremium: true,
    ));

    suggestions.sort((a, b) => b.priority.compareTo(a.priority));
    return suggestions;
  }

  // ── Форматування повідомлень ──────────────────────────────────────────

  /// Генерує повідомлення про перехід на новий рівень.
  static String getLevelUpMessage(int newLevel) {
    final name = getLevelName(newLevel);
    final emoji = getLevelEmoji(newLevel);
    final coins = _levelUpCoinBonus;
    return '$emoji Вітаємо! Рівень $newLevel — $name! '
        '+$coins монет за перехід!';
  }

  /// Генерує повідомлення про досягнення етапу серії.
  static String getStreakMilestoneMessage(int streakDays) {
    final name = _streakMilestoneNames[streakDays] ?? '';
    final xp = _streakMilestoneXp[streakDays] ?? 0;
    if (name.isEmpty) return '';
    return '🔥 $name! Серія $streakDays днів — бонус +$xp XP!';
  }

  /// Генерує підсумкове повідомлення про прогрес рівня.
  static String getLevelProgressMessage({
    required int currentXp,
    required int currentLevel,
  }) {
    final progress = getLevelProgress(currentXp, currentLevel);
    final percent = (progress * 100).toStringAsFixed(0);
    final nextLevel = getNextLevel(currentXp, currentLevel);
    if (nextLevel == null) {
      return '🏆 Максимальний рівень досягнуто!';
    }
    final needed = (nextLevel.xpRequired - currentXp).clamp(0, 99999);
    return '${getLevelEmoji(currentLevel)} ${getLevelName(currentLevel)} — '
        '$percent% (${needed} XP до ${nextLevel.name})';
  }

  // ── Розширена історія ────────────────────────────────────────────────

  /// Фільтрує історію за типом події.
  static List<XPHistoryEntry> filterHistoryByType(
    List<XPHistoryEntry> history,
    String eventType,
  ) {
    return history.where((e) => e.eventType == eventType).toList();
  }

  /// Фільтрує історію за діапазоном дат.
  static List<XPHistoryEntry> filterHistoryByDateRange(
    List<XPHistoryEntry> history, {
    required DateTime from,
    required DateTime to,
  }) {
    return history
        .where((e) => !e.timestamp.isBefore(from) && !e.timestamp.isAfter(to))
        .toList();
  }

  /// Групує історію за днями та повертає XP за кожен день.
  static Map<String, int> groupHistoryByDay(List<XPHistoryEntry> history) {
    final grouped = <String, int>{};
    for (final entry in history) {
      final dayKey =
          '${entry.timestamp.year}-${entry.timestamp.month.toString().padLeft(2, '0')}-'
          '${entry.timestamp.day.toString().padLeft(2, '0')}';
      grouped[dayKey] = (grouped[dayKey] ?? 0) + entry.xpAmount;
    }
    return grouped;
  }

  /// Повертає кількість унікальних днів з активністю.
  static int getActiveDaysCount(List<XPHistoryEntry> history) {
    final days = history
        .map((e) =>
            '${e.timestamp.year}-${e.timestamp.month}-${e.timestamp.day}')
        .toSet();
    return days.length;
  }

  /// Повертає поточну серію днів активності з історії.
  ///
  /// Підраховує кількість послідовних днів з подіями до сьогодні.
  static int calculateCurrentStreakFromHistory(List<XPHistoryEntry> history) {
    if (history.isEmpty) return 0;

    final today = DateTime.now();
    final uniqueDays = history
        .map((e) => DateTime(e.timestamp.year, e.timestamp.month, e.timestamp.day))
        .toSet()
        .toList()
      ..sort((a, b) => b.compareTo(a));

    if (uniqueDays.isEmpty) return 0;

    // Перевіряємо чи сьогодні є активність
    final todayDate = DateTime(today.year, today.month, today.day);
    final yesterday = todayDate.subtract(const Duration(days: 1));

    if (uniqueDays.first != todayDate && uniqueDays.first != yesterday) {
      return 0; // Серія розірвана
    }

    int streak = 0;
    DateTime checkDate = uniqueDays.first == todayDate ? todayDate : yesterday;

    for (final day in uniqueDays) {
      if (day == checkDate) {
        streak++;
        checkDate = checkDate.subtract(const Duration(days: 1));
      } else if (day.isBefore(checkDate)) {
        break;
      }
    }

    return streak;
  }

  // ── Анімація прогресу ────────────────────────────────────────────────

  /// Розраховує тривалість анімації прогресу в мілісекундах.
  ///
  /// [xpGained] — кількість отриманого XP.
  static int calculateAnimationDuration(int xpGained) {
    if (xpGained <= 0) return 200;
    if (xpGained < 10) return 300;
    if (xpGained < 50) return 600;
    if (xpGained < 100) return 900;
    if (xpGained < 500) return 1200;
    return 1500;
  }

  /// Розраховує кількість фонових частинок для анімації рівень-ап.
  ///
  /// [levelsGained] — кількість переходів рівнів.
  static int calculateParticleCount(int levelsGained) {
    return (levelsGained * 15).clamp(5, 100);
  }

  /// Повертає колір анімації XP залежно від множника.
  static int getAnimationColor(double multiplier) {
    if (multiplier >= 2.0) return 0xFFFFD700; // Золотий
    if (multiplier >= 1.5) return 0xFFFF9800; // Помаранчевий
    if (multiplier >= 1.2) return 0xFF4CAF50; // Зелений
    if (multiplier >= 1.0) return 0xFF2196F3; // Синій
    return 0xFF9E9E9E; // Сірий
  }
}
