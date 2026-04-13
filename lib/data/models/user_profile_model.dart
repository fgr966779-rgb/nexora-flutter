/// Модель профілю користувача.
///
/// Профіль містить всю гейміфікаційну інформацію користувача:
/// XP, монети, рівень, серію днів (streak), розблоковані бейджі,
/// придбані розблоковки, налаштування теми, сповіщень та звуку.
/// Модель також відстежує історію XP для аналітики та графіків.
class UserProfile {
  String name;
  String email;
  String avatarUrl;
  int xp;
  int coins;
  int currentLevel;
  int currentStreak;
  int longestStreak;
  DateTime? lastActiveDate;
  List<String> unlockedBadges;
  List<String> purchasedUnlocks;
  String activeTheme;
  bool soundsEnabled;
  bool hapticsEnabled;
  final DateTime createdAt;
  Map<String, bool> notificationPreferences;
  List<XpHistoryEntry> xpHistory;
  int totalCoinsEarned;
  int totalCoinsSpent;
  AvatarStyle avatarStyle;
  NotificationSchedule notificationSchedule;
  ThemeModePreference themeMode;
  PrivacySettings privacySettings;
  int totalGoalsCreated;
  int totalGoalsCompleted;
  int totalChallengesCompleted;
  int totalDeposits;
  double totalSavedAmount;
  String? bio;
  String? location;
  DateTime? birthDate;
  double hourlyRate;

  UserProfile({
    this.name = 'Користувач',
    this.email = '',
    this.avatarUrl = '',
    this.xp = 0,
    this.coins = 0,
    this.currentLevel = 0,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.lastActiveDate,
    this.unlockedBadges = const [],
    this.purchasedUnlocks = const [],
    this.activeTheme = 'default',
    this.soundsEnabled = true,
    this.hapticsEnabled = true,
    required this.createdAt,
    Map<String, bool>? notificationPreferences,
    List<XpHistoryEntry>? xpHistory,
    this.totalCoinsEarned = 0,
    this.totalCoinsSpent = 0,
    this.avatarStyle = AvatarStyle.defaultStyle,
    this.notificationSchedule = NotificationSchedule.normal,
    this.themeMode = ThemeModePreference.system,
    this.privacySettings = const PrivacySettings(),
    this.totalGoalsCreated = 0,
    this.totalGoalsCompleted = 0,
    this.totalChallengesCompleted = 0,
    this.totalDeposits = 0,
    this.totalSavedAmount = 0,
    this.bio,
    this.location,
    this.birthDate,
    this.hourlyRate = 200.0,
  })  : notificationPreferences = notificationPreferences ?? _defaultNotifications(),
        xpHistory = xpHistory ?? [];

  // ─── Налаштування сповіщень за замовчуванням ───────────────────────

  static Map<String, bool> _defaultNotifications() {
    return {
      'depositReminder': true,
      'goalReached': true,
      'challengeAvailable': true,
      'streakWarning': true,
      'weeklySummary': true,
      'achievementUnlocked': true,
    };
  }

  // ─── Порогові значення рівнів ──────────────────────────────────────

  /// Порогові значення XP для кожного рівня.
  /// 0→L1, 100→L2, 300→L3, 700→L4, 1500→L5, 3000→L6, 6000→L7, 12000→L8
  static const List<int> levelThresholds = [
    0,     // L1: Новачок
    100,   // L2: Стартер
    300,   // L3: Накопичувач
    700,   // L4: Стратег
    1500,  // L5: Майстер
    3000,  // L6: Чемпіон
    6000,  // L7: Легенда
    12000, // L8: Скарбничний бос
    25000, // L9: Зеніт
  ];

  /// Назви рівнів українською.
  static const List<String> levelNames = [
    'Новачок',           // L1
    'Стартер',           // L2
    'Накопичувач',       // L3
    'Стратег',           // L4
    'Майстер',           // L5
    'Чемпіон',           // L6
    'Легенда',           // L7
    'Скарбничний бос',   // L8
    'Зеніт',             // L9
  ];

  /// Іконки рівнів (рядки для відображення).
  static const List<String> levelIcons = [
    '🌱', '⭐', '💎', '🧠', '👑', '🏆', '🔥', '🦄', '✨',
  ];

  /// Описи рівнів українською (мотиваційні).
  static const List<String> levelDescriptions = [
    'Ти тільки почав свою подорож заощаджень!',
    'Перші кроки зроблено — тепер головне регулярність!',
    'Ти вже знаєш основи — час стратегіювати!',
    'Твої заощадження ростуть — продовжуй у тому ж дусі!',
    'Ти досяг мастерства — молодець!',
    'Чемпіон заощаджень — ти надихаєш інших!',
    'Легендарний накопичувач — твої результати вражають!',
    'Скарбничний бос — ти зірка цього додатку!',
    'Ти досяг абсолютного зеніту! Браво!',
  ];

  /// Максимальний рівень у грі.
  static int get maxLevel => levelThresholds.length;

  /// Кількість рівнів у грі.
  static int get totalLevels => levelThresholds.length;

  // ─── Обчислювані властивості: Рівні ───────────────────────────────

  /// Поточний рівень (перераховується з XP).
  int get level {
    int lvl = 0;
    for (int i = levelThresholds.length - 1; i >= 0; i--) {
      if (xp >= levelThresholds[i]) {
        lvl = i;
        break;
      }
    }
    return lvl;
  }

  /// Номер рівня для відображення (1-індексований, тобто 1–9).
  int get levelNumber => level + 1;

  /// Назва поточного рівня українською.
  String get levelName {
    final lvl = level;
    if (lvl >= levelNames.length) return levelNames.last;
    return levelNames[lvl];
  }

  /// Опис поточного рівня.
  String get levelDescription {
    final lvl = level;
    if (lvl >= levelDescriptions.length) return levelDescriptions.last;
    return levelDescriptions[lvl];
  }

  /// Іконка поточного рівня.
  String get levelIcon {
    final lvl = level;
    if (lvl >= levelIcons.length) return levelIcons.last;
    return levelIcons[lvl];
  }

  /// Прогрес усередині поточного рівня (0.0 – 1.0).
  double get levelProgress {
    final lvl = level;
    if (lvl >= levelThresholds.length - 1) return 1.0;
    final lower = levelThresholds[lvl];
    final upper = levelThresholds[lvl + 1];
    if (upper <= lower) return 1.0;
    return ((xp - lower) / (upper - lower)).clamp(0.0, 1.0);
  }

  /// Прогрес рівня у відсотках, наприклад "45.3%".
  String get formattedLevelProgress =>
      '${(levelProgress * 100).toStringAsFixed(1)}%';

  /// XP, необхідний для наступного рівня.
  int get nextLevelXp {
    final lvl = level;
    if (lvl >= levelThresholds.length - 1) return levelThresholds.last;
    return levelThresholds[lvl + 1];
  }

  /// XP, необхідний для поточного рівня (нижня межа).
  int get currentLevelXp {
    final lvl = level;
    if (lvl >= levelThresholds.length) return levelThresholds.last;
    return levelThresholds[lvl];
  }

  /// XP, який залишається до наступного рівня.
  int get xpUntilNextLevel {
    final next = nextLevelXp;
    if (xp >= next) return 0;
    return next - xp;
  }

  /// Форматований XP, що залишився до наступного рівня.
  String get formattedXpUntilNextLevel =>
      '${_formatWithSpaces(xpUntilNextLevel)} XP';

  /// XP, зароблений на поточному рівні.
  int get xpOnCurrentLevel => xp - currentLevelXp;

  /// XP, потрібний для завершення поточного рівня.
  int get xpNeededForCurrentLevel => nextLevelXp - currentLevelXp;

  /// Чи досягнуто максимального рівня.
  bool get isMaxLevel => level >= levelThresholds.length - 1;

  /// Назва наступного рівня.
  String get nextLevelName {
    final nextLvl = level + 1;
    if (nextLvl >= levelNames.length) return 'Максимум!';
    return levelNames[nextLvl];
  }

  /// Повідомлення при підвищенні рівня.
  String get levelUpMessage {
    if (isMaxLevel) return '🎉 Ти вже на максимальному рівні! Залишайся легендою!';
    return '🎉 Рівень підвищено! Тепер ти — $levelIcon $levelName!';
  }

  // ─── Заповненість профілю ──────────────────────────────────────────

  /// Обчислює кількість годин роботи для вказаної суми.
  double calculateWorkHours(double amount) {
    if (hourlyRate <= 0) return 0;
    return amount / hourlyRate;
  }

  /// Відсоток заповненості профілю (0–100).
  int get profileCompletionPercent {
    int completed = 0;
    int total = 0;
    // Ім'я (не дефолтне)
    total++;
    if (name != 'Користувач') completed++;
    // Email
    total++;
    if (email.isNotEmpty) completed++;
    // Аватар
    total++;
    if (avatarUrl.isNotEmpty) completed++;
    // Біо
    total++;
    if (bio != null && bio!.isNotEmpty) completed++;
    // Тема
    total++;
    if (activeTheme != 'default') completed++;
    // Хоча б один бейдж
    total++;
    if (unlockedBadges.isNotEmpty) completed++;
    // Хоча б один внесок
    total++;
    if (totalDeposits > 0) completed++;

    return ((completed / total) * 100).round();
  }

  /// Текстовий звіт про заповненість профілю.
  String get profileCompletionReport {
    final percent = profileCompletionPercent;
    if (percent >= 90) return '🏆 Профіль заповнено на $percent% — чудово!';
    if (percent >= 70) return '💪 Профіль заповнено на $percent% — майже все!';
    if (percent >= 50) return '📈 Профіль заповнено на $percent% — непогано!';
    return '🌱 Профіль заповнено на $percent% — заповни більше!';
  }

  /// Підказки щодо заповнення профілю.
  List<String> get profileCompletionTips {
    final tips = <String>[];
    if (name == 'Користувач') tips.add('👤 Зміни ім\'я на своє');
    if (email.isEmpty) tips.add('📧 Додай email');
    if (avatarUrl.isEmpty) tips.add('🖼️ Встанови аватар');
    if (bio == null || bio!.isEmpty) tips.add('✏️ Додай коротку біо');
    if (activeTheme == 'default') tips.add('🎨 Обери тему оформлення');
    if (unlockedBadges.isEmpty) tips.add('🏆 Заробай свій перший бейдж');
    return tips;
  }

  // ─── Форматовані відображення ──────────────────────────────────────

  /// Форматований XP, наприклад "1 250 XP".
  String get formattedXp => _formatWithSpaces(xp);

  /// Форматовані монети, наприклад "350".
  String get formattedCoins => _formatWithSpaces(coins);

  /// Форматовані монети з суфіксом, наприклад "350 монет".
  String get formattedCoinsWithSuffix {
    final c = coins;
    if (c == 1) return '1 монета';
    if (c >= 2 && c <= 4) return '$c монети';
    return '$c монет';
  }

  /// Формований рівень з іконкою, наприклад "🌱 L1 Новачок".
  String get formattedLevelWithIcon {
    return '$levelIcon L$levelNumber $levelName';
  }

  /// Короткий формат рівня, наприклад "L3 Накопичувач".
  String get formattedLevelShort => 'L$levelNumber $levelName';

  /// Повне текстове представлення профілю.
  String get displaySummary {
    return '$formattedLevelWithIcon · $formattedXp · $formattedCoinsWithSuffix';
  }

  // ─── Часові обчислення ─────────────────────────────────────────────

  /// Кількість днів з моменту реєстрації.
  int get daysSinceRegistration {
    return DateTime.now().difference(createdAt).inDays;
  }

  /// Кількість тижнів з моменту реєстрації.
  int get weeksSinceRegistration {
    return daysSinceRegistration ~/ 7;
  }

  /// Кількість місяців з моменту реєстрації (приблизно).
  int get monthsSinceRegistration {
    return daysSinceRegistration ~/ 30;
  }

  /// Форматована дата реєстрації.
  String get formattedRegistrationDate {
    final months = [
      '', 'січня', 'лютого', 'березня', 'квітня', 'травня',
      'червня', 'липня', 'серпня', 'вересня', 'жовтня',
      'листопада', 'грудня',
    ];
    return '${createdAt.day} ${months[createdAt.month]} ${createdAt.year}';
  }

  /// Кількість днів з останньої активності.
  int get daysSinceLastActive {
    if (lastActiveDate == null) return daysSinceRegistration;
    return DateTime.now().difference(lastActiveDate!).inDays;
  }

  /// Вік користувача (на основі дати народження).
  int? get age {
    if (birthDate == null) return null;
    final now = DateTime.now();
    int age = now.year - birthDate!.year;
    if (now.month < birthDate!.month ||
        (now.month == birthDate!.month && now.day < birthDate!.day)) {
      age--;
    }
    return age;
  }

  // ─── Методи: XP ────────────────────────────────────────────────────

  /// Оновлює рівень на основі поточного XP.
  void recalculateLevel() {
    currentLevel = level;
  }

  /// Додає XP та перераховує рівень. Повертає true якщо рівень підвищено.
  bool addXp(int amount) {
    if (amount <= 0) return false;
    final oldLevel = currentLevel;
    xp += amount;
    xpHistory.add(XpHistoryEntry(
      amount: amount,
      timestamp: DateTime.now(),
      source: 'deposit',
    ));
    recalculateLevel();
    return currentLevel > oldLevel;
  }

  /// Додає XP з вказаним джерелом.
  bool addXpWithSource(int amount, String source) {
    if (amount <= 0) return false;
    final oldLevel = currentLevel;
    xp += amount;
    xpHistory.add(XpHistoryEntry(
      amount: amount,
      timestamp: DateTime.now(),
      source: source,
    ));
    recalculateLevel();
    return currentLevel > oldLevel;
  }

  /// Віднімає XP (для штрафів або скасувань).
  void subtractXp(int amount) {
    xp -= amount;
    if (xp < 0) xp = 0;
    recalculateLevel();
  }

  // ─── Методи: Монети ────────────────────────────────────────────────

  /// Додає монети та оновлює загальну статистику.
  void addCoins(int amount) {
    if (amount <= 0) return;
    coins += amount;
    totalCoinsEarned += amount;
  }

  /// Віднімає монети. Повертає true, якщо вистачило коштів.
  bool subtractCoins(int amount) {
    if (coins < amount) return false;
    coins -= amount;
    totalCoinsSpent += amount;
    return true;
  }

  /// Витрачає монети (синонім subtractCoins).
  bool spendCoins(int amount) => subtractCoins(int amount);

  /// Чи достатньо монет для покупки.
  bool canAfford(int amount) => coins >= amount;

  /// Баланс монет: зароблено мінус витрачено.
  int get coinsNetBalance => totalCoinsEarned - totalCoinsSpent;

  /// Форматований заробіток монет.
  String get formattedTotalCoinsEarned => _formatWithSpaces(totalCoinsEarned);

  /// Формований витрат монет.
  String get formattedTotalCoinsSpent => _formatWithSpaces(totalCoinsSpent);

  // ─── Методи: Бейджі ────────────────────────────────────────────────

  /// Чи має користувач певний бейдж.
  bool hasBadge(String badgeId) {
    return unlockedBadges.contains(badgeId);
  }

  /// Розблоковує бейдж. Повертає true, якщо бейдж був новим.
  bool unlockBadge(String badgeId) {
    if (unlockedBadges.contains(badgeId)) return false;
    unlockedBadges = [...unlockedBadges, badgeId];
    return true;
  }

  /// Розблоковує кілька бейджів одночасно. Повертає кількість нових.
  int unlockBadges(List<String> badgeIds) {
    int newCount = 0;
    for (final id in badgeIds) {
      if (!unlockedBadges.contains(id)) {
        unlockedBadges = [...unlockedBadges, id];
        newCount++;
      }
    }
    return newCount;
  }

  /// Видаляє бейдж.
  bool removeBadge(String badgeId) {
    if (!unlockedBadges.contains(badgeId)) return false;
    unlockedBadges = unlockedBadges.where((b) => b != badgeId).toList();
    return true;
  }

  /// Повертає список усіх розблокованих бейджів.
  List<String> getBadgesList() => List.unmodifiable(unlockedBadges);

  /// Кількість розблокованих бейджів.
  int get achievementCount => unlockedBadges.length;

  /// Кількість придбаних розблоковок.
  int get purchasedCount => purchasedUnlocks.length;

  /// Чи має придбану розблоковку.
  bool hasPurchased(String unlockId) {
    return purchasedUnlocks.contains(unlockId);
  }

  /// Додає придбану розблоковку. Повертає true якщо нова.
  bool addPurchased(String unlockId) {
    if (purchasedUnlocks.contains(unlockId)) return false;
    purchasedUnlocks = [...purchasedUnlocks, unlockId];
    return true;
  }

  /// Зведення досягнень користувача.
  Map<String, dynamic> get achievementSummary {
    return {
      'badgesCount': achievementCount,
      'purchasedCount': purchasedCount,
      'totalGoalsCompleted': totalGoalsCompleted,
      'totalChallengesCompleted': totalChallengesCompleted,
      'totalDeposits': totalDeposits,
      'totalSavedAmount': totalSavedAmount,
      'longestStreak': longestStreak,
      'currentLevel': levelNumber,
    };
  }

  // ─── Стрік ─────────────────────────────────────────────────────────

  /// Статус стріку: "Активний", "Заморожений", "Новий".
  String get streakStatus {
    if (currentStreak >= 7) return '🔥 У неугасі!';
    if (currentStreak >= 3) return '💪 Хороший стрік';
    if (currentStreak >= 1) return '🌱 Початок';
    return '💤 Немає стріку';
  }

  /// Емодзі для стріку.
  String get streakEmoji {
    if (currentStreak >= 30) return '💎';
    if (currentStreak >= 14) return '🔥';
    if (currentStreak >= 7) return '⚡';
    if (currentStreak >= 3) return '💪';
    if (currentStreak >= 1) return '🌱';
    return '💤';
  }

  /// Чи має активний стрік (1+ день).
  bool get hasActiveStreak => currentStreak > 0;

  /// Формований стрік, наприклад "5 днів 🔥".
  String get formattedStreak {
    if (currentStreak == 0) return 'Без серії';
    if (currentStreak == 1) return '1 день $streakEmoji';
    if (currentStreak < 5) return '$currentStreak дні $streakEmoji';
    return '$currentStreak днів $streakEmoji';
  }

  /// Формований найдовший стрік.
  String get formattedLongestStreak {
    if (longestStreak == 0) return '—';
    if (longestStreak == 1) return '1 день';
    if (longestStreak < 5) return '$longestStreak дні';
    return '$longestStreak днів';
  }

  /// Бонусний множник на основі стріку.
  double get streakMultiplier {
    if (currentStreak >= 30) return 3.0;
    if (currentStreak >= 14) return 2.0;
    if (currentStreak >= 7) return 1.5;
    if (currentStreak >= 3) return 1.2;
    return 1.0;
  }

  /// Формований множник стріку, наприклад "x1.5".
  String get formattedStreakMultiplier => 'x${streakMultiplier.toStringAsFixed(1)}';

  /// Оновлює стрік. Повертає true якщо стрік продовжено.
  bool updateStreak() {
    final now = DateTime.now();
    if (lastActiveDate != null) {
      final diff = now.difference(lastActiveDate!).inDays;
      if (diff == 1) {
        currentStreak++;
        if (currentStreak > longestStreak) {
          longestStreak = currentStreak;
        }
      } else if (diff > 1) {
        currentStreak = 1;
      }
    } else {
      currentStreak = 1;
    }
    lastActiveDate = now;
    return currentStreak > 1;
  }

  /// Скидає стрік до 0.
  void resetStreak() {
    currentStreak = 0;
  }

  // ─── Сповіщення ────────────────────────────────────────────────────

  /// Отримує налаштування сповіщень.
  Map<String, bool> getNotificationPrefs() =>
      Map.unmodifiable(notificationPreferences);

  /// Встановлює налаштування сповіщень.
  void setNotificationPrefs(Map<String, bool> prefs) {
    notificationPreferences = Map<String, bool>.from(prefs);
  }

  /// Вмикає конкретне сповіщення.
  void enableNotification(String key) {
    notificationPreferences[key] = true;
  }

  /// Вимикає конкретне сповіщення.
  void disableNotification(String key) {
    notificationPreferences[key] = false;
  }

  /// Чи увімкнено конкретне сповіщення.
  bool isNotificationEnabled(String key) {
    return notificationPreferences[key] ?? false;
  }

  /// Повертає кількість увімкнених сповіщень.
  int get enabledNotificationsCount {
    return notificationPreferences.values.where((v) => v).length;
  }

  /// Україномовні назви сповіщень.
  static String notificationLabel(String key) {
    switch (key) {
      case 'depositReminder': return 'Нагадування про внесок';
      case 'goalReached': return 'Ціль досягнута';
      case 'challengeAvailable': return 'Новий виклик';
      case 'streakWarning': return 'Загроза серії';
      case 'weeklySummary': return 'Тижневий підсумок';
      case 'achievementUnlocked': return 'Нове досягнення';
      default: return key;
    }
  }

  // ─── Оновлення профілю ─────────────────────────────────────────────

  /// Оновлює поля профілю.
  void updateProfile({
    String? name,
    String? email,
    String? avatarUrl,
    String? activeTheme,
    bool? soundsEnabled,
    bool? hapticsEnabled,
    AvatarStyle? avatarStyle,
    ThemeModePreference? themeMode,
    String? bio,
    String? location,
  }) {
    if (name != null) this.name = name;
    if (email != null) this.email = email;
    if (avatarUrl != null) this.avatarUrl = avatarUrl;
    if (activeTheme != null) this.activeTheme = activeTheme;
    if (soundsEnabled != null) this.soundsEnabled = soundsEnabled;
    if (hapticsEnabled != null) this.hapticsEnabled = hapticsEnabled;
    if (avatarStyle != null) this.avatarStyle = avatarStyle;
    if (themeMode != null) this.themeMode = themeMode;
    if (bio != null) this.bio = bio;
    if (location != null) this.location = location;
  }

  /// Створює копію профілю з можливістю заміни полів.
  UserProfile copyWith({
    String? name,
    String? email,
    String? avatarUrl,
    int? xp,
    int? coins,
    int? currentLevel,
    int? currentStreak,
    int? longestStreak,
    DateTime? lastActiveDate,
    List<String>? unlockedBadges,
    List<String>? purchasedUnlocks,
    String? activeTheme,
    bool? soundsEnabled,
    bool? hapticsEnabled,
    DateTime? createdAt,
    Map<String, bool>? notificationPreferences,
    List<XpHistoryEntry>? xpHistory,
    int? totalCoinsEarned,
    int? totalCoinsSpent,
    AvatarStyle? avatarStyle,
    NotificationSchedule? notificationSchedule,
    ThemeModePreference? themeMode,
    PrivacySettings? privacySettings,
    int? totalGoalsCreated,
    int? totalGoalsCompleted,
    int? totalChallengesCompleted,
    int? totalDeposits,
    double? totalSavedAmount,
    String? bio,
    String? location,
    DateTime? birthDate,
    double? hourlyRate,
  }) {
    return UserProfile(
      name: name ?? this.name,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      xp: xp ?? this.xp,
      coins: coins ?? this.coins,
      currentLevel: currentLevel ?? this.currentLevel,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      lastActiveDate: lastActiveDate ?? this.lastActiveDate,
      unlockedBadges: unlockedBadges ?? this.unlockedBadges,
      purchasedUnlocks: purchasedUnlocks ?? this.purchasedUnlocks,
      activeTheme: activeTheme ?? this.activeTheme,
      soundsEnabled: soundsEnabled ?? this.soundsEnabled,
      hapticsEnabled: hapticsEnabled ?? this.hapticsEnabled,
      createdAt: createdAt ?? this.createdAt,
      notificationPreferences: notificationPreferences ?? this.notificationPreferences,
      xpHistory: xpHistory ?? this.xpHistory,
      totalCoinsEarned: totalCoinsEarned ?? this.totalCoinsEarned,
      totalCoinsSpent: totalCoinsSpent ?? this.totalCoinsSpent,
      avatarStyle: avatarStyle ?? this.avatarStyle,
      notificationSchedule: notificationSchedule ?? this.notificationSchedule,
      themeMode: themeMode ?? this.themeMode,
      privacySettings: privacySettings ?? this.privacySettings,
      totalGoalsCreated: totalGoalsCreated ?? this.totalGoalsCreated,
      totalGoalsCompleted: totalGoalsCompleted ?? this.totalGoalsCompleted,
      totalChallengesCompleted: totalChallengesCompleted ?? this.totalChallengesCompleted,
      totalDeposits: totalDeposits ?? this.totalDeposits,
      totalSavedAmount: totalSavedAmount ?? this.totalSavedAmount,
      bio: bio ?? this.bio,
      location: location ?? this.location,
      birthDate: birthDate ?? this.birthDate,
      hourlyRate: hourlyRate ?? this.hourlyRate,
    );
  }

  /// Оновлює дату останньої активності.
  void touchActivity() {
    lastActiveDate = DateTime.now();
  }

  /// Повертає загальну кількість депозитів (передається ззовні).
  int totalDepositsCount(List<dynamic> transactions) {
    return transactions.length;
  }

  /// Повертає загальну збережену суму (передається ззовні).
  double totalSavedAmountFromTransactions(List<dynamic> transactions) {
    return transactions.fold(0.0, (sum, t) {
      return sum + ((t as dynamic).amount as num).toDouble();
    });
  }

  // ─── Історія XP ────────────────────────────────────────────────────

  /// Повертає історію XP (найновіші перші).
  List<XpHistoryEntry> getXpHistory({int limit = 50}) {
    final sorted = List<XpHistoryEntry>.from(xpHistory);
    sorted.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    if (sorted.length > limit) {
      return sorted.sublist(0, limit);
    }
    return sorted;
  }

  /// Загальний XP зароблений за сьогодні.
  int get todayXp {
    final now = DateTime.now();
    return xpHistory
        .where((e) =>
            e.timestamp.year == now.year &&
            e.timestamp.month == now.month &&
            e.timestamp.day == now.day)
        .fold(0, (sum, e) => sum + e.amount);
  }

  /// XP зароблений за цей тиждень.
  int get thisWeekXp {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    return xpHistory
        .where((e) => e.timestamp.isAfter(weekStart))
        .fold(0, (sum, e) => sum + e.amount);
  }

  /// XP зароблений за цей місяць.
  int get thisMonthXp {
    final now = DateTime.now();
    return xpHistory
        .where((e) =>
            e.timestamp.year == now.year && e.timestamp.month == now.month)
        .fold(0, (sum, e) => sum + e.amount);
  }

  /// Кількість записів в історії XP.
  int get xpHistoryCount => xpHistory.length;

  /// Найбільший одиночний заробіток XP.
  int get largestSingleXp {
    if (xpHistory.isEmpty) return 0;
    return xpHistory.map((e) => e.amount).reduce((a, b) => a > b ? a : b);
  }

  /// Середній заробіток XP за запис.
  double get averageXpPerEntry {
    if (xpHistory.isEmpty) return 0;
    return xpHistory.fold(0, (sum, e) => sum + e.amount) / xpHistory.length;
  }

  // ─── Експорт/Імпорт даних профілю ────────────────────────────────────

  /// Генерує мінімальну експортну карту.
  Map<String, dynamic> toMinimalMap() {
    return {
      'name': name,
      'email': email,
      'xp': xp,
      'coins': coins,
      'level': levelNumber,
      'streak': currentStreak,
      'badges': unlockedBadges,
      'theme': activeTheme,
    };
  }

  /// Створює копію профілю для бекапу.
  Map<String, dynamic> toBackupMap() {
    return {
      'name': name,
      'email': email,
      'avatarUrl': avatarUrl,
      'xp': xp,
      'coins': coins,
      'currentLevel': currentLevel,
      'currentStreak': currentStreak,
      'longestStreak': longestStreak,
      'lastActiveDate': lastActiveDate?.toIso8601String(),
      'unlockedBadges': unlockedBadges,
      'purchasedUnlocks': purchasedUnlocks,
      'activeTheme': activeTheme,
      'soundsEnabled': soundsEnabled,
      'hapticsEnabled': hapticsEnabled,
      'totalCoinsEarned': totalCoinsEarned,
      'totalCoinsSpent': totalCoinsSpent,
      'avatarStyle': avatarStyle.name,
      'themeMode': themeMode.name,
      'bio': bio,
      'location': location,
      'totalGoalsCreated': totalGoalsCreated,
      'totalGoalsCompleted': totalGoalsCompleted,
      'totalChallengesCompleted': totalChallengesCompleted,
      'totalDeposits': totalDeposits,
      'totalSavedAmount': totalSavedAmount,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // ─── Статистика профілю ────────────────────────────────────────────

  /// Повертає мапу статистики профілю.
  Map<String, dynamic> toStatsMap() {
    return {
      'name': name,
      'level': levelNumber,
      'levelName': levelName,
      'xp': xp,
      'coins': coins,
      'totalCoinsEarned': totalCoinsEarned,
      'totalCoinsSpent': totalCoinsSpent,
      'currentStreak': currentStreak,
      'longestStreak': longestStreak,
      'streakMultiplier': streakMultiplier,
      'achievementCount': achievementCount,
      'purchasedCount': purchasedCount,
      'daysSinceRegistration': daysSinceRegistration,
      'weeksSinceRegistration': weeksSinceRegistration,
      'monthsSinceRegistration': monthsSinceRegistration,
      'todayXp': todayXp,
      'thisWeekXp': thisWeekXp,
      'thisMonthXp': thisMonthXp,
      'levelProgress': levelProgress,
      'xpUntilNextLevel': xpUntilNextLevel,
      'isMaxLevel': isMaxLevel,
      'profileCompletion': profileCompletionPercent,
      'totalGoalsCreated': totalGoalsCreated,
      'totalGoalsCompleted': totalGoalsCompleted,
      'totalChallengesCompleted': totalChallengesCompleted,
    };
  }

  // ─── Приватне форматування ────────────────────────────────────────

  static String _formatWithSpaces(int value) {
    final str = value.toString();
    final buffer = StringBuffer();
    for (int i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) {
        buffer.write(' ');
      }
      buffer.write(str[i]);
    }
    return buffer.toString();
  }

  // ─── Серіалізація ──────────────────────────────────────────────────

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      name: json['name'] as String? ?? 'Користувач',
      email: json['email'] as String? ?? '',
      avatarUrl: (json['avatarUrl'] as String?) ?? '',
      xp: (json['xp'] as int?) ?? 0,
      coins: (json['coins'] as int?) ?? 0,
      currentLevel: (json['currentLevel'] as int?) ?? 0,
      currentStreak: (json['currentStreak'] as int?) ?? 0,
      longestStreak: (json['longestStreak'] as int?) ?? 0,
      lastActiveDate: json['lastActiveDate'] != null
          ? DateTime.parse(json['lastActiveDate'] as String)
          : null,
      unlockedBadges: (json['unlockedBadges'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      purchasedUnlocks: (json['purchasedUnlocks'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      activeTheme: json['activeTheme'] as String? ?? 'default',
      soundsEnabled: (json['soundsEnabled'] as bool?) ?? true,
      hapticsEnabled: (json['hapticsEnabled'] as bool?) ?? true,
      createdAt: DateTime.parse(json['createdAt'] as String),
      notificationPreferences:
          (json['notificationPreferences'] as Map<String, dynamic>?)
                  ?.map((k, v) => MapEntry(k, v as bool)) ??
              _defaultNotifications(),
      xpHistory: (json['xpHistory'] as List<dynamic>?)
              ?.map((e) => XpHistoryEntry.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      totalCoinsEarned: (json['totalCoinsEarned'] as int?) ?? 0,
      totalCoinsSpent: (json['totalCoinsSpent'] as int?) ?? 0,
      avatarStyle: AvatarStyle.values.firstWhere(
        (e) => e.name == (json['avatarStyle'] ?? 'defaultStyle'),
        orElse: () => AvatarStyle.defaultStyle,
      ),
      notificationSchedule: NotificationSchedule.values.firstWhere(
        (e) => e.name == (json['notificationSchedule'] ?? 'normal'),
        orElse: () => NotificationSchedule.normal,
      ),
      themeMode: ThemeModePreference.values.firstWhere(
        (e) => e.name == (json['themeMode'] ?? 'system'),
        orElse: () => ThemeModePreference.system,
      ),
      privacySettings: json['privacySettings'] != null
          ? PrivacySettings.fromJson(json['privacySettings'] as Map<String, dynamic>)
          : const PrivacySettings(),
      totalGoalsCreated: (json['totalGoalsCreated'] as int?) ?? 0,
      totalGoalsCompleted: (json['totalGoalsCompleted'] as int?) ?? 0,
      totalChallengesCompleted: (json['totalChallengesCompleted'] as int?) ?? 0,
      totalDeposits: (json['totalDeposits'] as int?) ?? 0,
      totalSavedAmount: (json['totalSavedAmount'] as num?)?.toDouble() ?? 0,
      bio: json['bio'] as String?,
      location: json['location'] as String?,
      birthDate: json['birthDate'] != null
          ? DateTime.parse(json['birthDate'] as String)
          : null,
      hourlyRate: (json['hourlyRate'] as num?)?.toDouble() ?? 200.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'avatarUrl': avatarUrl,
      'xp': xp,
      'coins': coins,
      'currentLevel': currentLevel,
      'currentStreak': currentStreak,
      'longestStreak': longestStreak,
      'lastActiveDate': lastActiveDate?.toIso8601String(),
      'unlockedBadges': unlockedBadges,
      'purchasedUnlocks': purchasedUnlocks,
      'activeTheme': activeTheme,
      'soundsEnabled': soundsEnabled,
      'hapticsEnabled': hapticsEnabled,
      'createdAt': createdAt.toIso8601String(),
      'notificationPreferences': notificationPreferences,
      'xpHistory': xpHistory.map((e) => e.toJson()).toList(),
      'totalCoinsEarned': totalCoinsEarned,
      'totalCoinsSpent': totalCoinsSpent,
      'avatarStyle': avatarStyle.name,
      'notificationSchedule': notificationSchedule.name,
      'themeMode': themeMode.name,
      'privacySettings': privacySettings.toJson(),
      'totalGoalsCreated': totalGoalsCreated,
      'totalGoalsCompleted': totalGoalsCompleted,
      'totalChallengesCompleted': totalChallengesCompleted,
      'totalDeposits': totalDeposits,
      'totalSavedAmount': totalSavedAmount,
      'bio': bio,
      'location': location,
      'birthDate': birthDate?.toIso8601String(),
      'hourlyRate': hourlyRate,
    };
  }

  /// Створює профіль за замовчуванням.
  factory UserProfile.defaultProfile() {
    return UserProfile(
      createdAt: DateTime.now(),
    );
  }
}

/// Запис в історії XP.
///
/// Кожен запис фіксує суму XP, час отримання та джерело.
/// Використовується для аналітики заробітку XP за різні періоди.
class XpHistoryEntry {
  final int amount;
  final DateTime timestamp;
  final String source;

  XpHistoryEntry({
    required this.amount,
    required this.timestamp,
    this.source = 'unknown',
  });

  /// Чи це запис за сьогодні.
  bool get isToday {
    final now = DateTime.now();
    return timestamp.year == now.year &&
        timestamp.month == now.month &&
        timestamp.day == now.day;
  }

  /// Чи це запис за цей тиждень.
  bool get isThisWeek {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    return timestamp.isAfter(weekStart);
  }

  /// Чи це запис за цей місяць.
  bool get isThisMonth {
    final now = DateTime.now();
    return timestamp.year == now.year && timestamp.month == now.month;
  }

  /// Кількість хвилин з моменту отримання.
  int get minutesAgo => DateTime.now().difference(timestamp).inMinutes;

  /// Кількість годин з моменту отримання.
  int get hoursAgo => DateTime.now().difference(timestamp).inHours;

  /// Кількість днів з моменту отримання.
  int get daysAgo => DateTime.now().difference(timestamp).inDays;

  factory XpHistoryEntry.fromJson(Map<String, dynamic> json) {
    return XpHistoryEntry(
      amount: json['amount'] as int,
      timestamp: DateTime.parse(json['timestamp'] as String),
      source: (json['source'] as String?) ?? 'unknown',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'amount': amount,
      'timestamp': timestamp.toIso8601String(),
      'source': source,
    };
  }

  /// Україномовне джерело XP.
  String get displaySource {
    switch (source) {
      case 'deposit':
        return 'Внесок';
      case 'challenge':
        return 'Виклик';
      case 'daily':
        return 'Щоденний бонус';
      case 'streak':
        return 'Бонус стріку';
      case 'micro_goal':
        return 'Мікро-ціль';
      case 'level_up':
        return 'Підвищення рівня';
      case 'return_bonus':
        return 'Бонус повернення';
      case 'admin':
        return 'Адміністратор';
      default:
        return 'Інше';
    }
  }

  /// Форматований опис запису.
  String get formattedEntry => '+$amount XP (${displaySource})';

  @override
  String toString() => 'XpHistoryEntry($amount XP, $source, $timestamp)';
}

/// Стиль аватара користувача.
enum AvatarStyle {
  /// Стандартний стиль.
  defaultStyle,

  /// Мінімалістичний стиль.
  minimal,

  /// Кольоровий стиль.
  colorful,

  /// Анімований стиль.
  animated;

  /// Україномовна назва.
  String get displayNameUA {
    switch (this) {
      case AvatarStyle.defaultStyle: return 'Стандартний';
      case AvatarStyle.minimal: return 'Мінімалістичний';
      case AvatarStyle.colorful: return 'Кольоровий';
      case AvatarStyle.animated: return 'Анімований';
    }
  }

  /// Емодзі.
  String get emoji {
    switch (this) {
      case AvatarStyle.defaultStyle: return '👤';
      case AvatarStyle.minimal: return '⭕';
      case AvatarStyle.colorful: return '🎨';
      case AvatarStyle.animated: return '✨';
    }
  }
}

/// Розклад сповіщень користувача.
enum NotificationSchedule {
  /// Звичайний розклад.
  normal,

  /// Тихий (лише критичні).
  quiet,

  /// Детальний (всі події).
  verbose,

  /// Сповіщення вимкнено.
  off;

  /// Україномовна назва.
  String get displayNameUA {
    switch (this) {
      case NotificationSchedule.normal: return 'Звичайний';
      case NotificationSchedule.quiet: return 'Тихий';
      case NotificationSchedule.verbose: return 'Детальний';
      case NotificationSchedule.off: return 'Вимкнено';
    }
  }

  /// Кількість увімкнених типів для розкладу.
  int get enabledTypesCount {
    switch (this) {
      case NotificationSchedule.normal: return 4;
      case NotificationSchedule.quiet: return 1;
      case NotificationSchedule.verbose: return 6;
      case NotificationSchedule.off: return 0;
    }
  }
}

/// Налаштування теми користувача.
enum ThemeModePreference {
  /// Системна тема.
  system,

  /// Світла тема.
  light,

  /// Темна тема.
  dark;

  /// Україномовна назва.
  String get displayNameUA {
    switch (this) {
      case ThemeModePreference.system: return 'Системна';
      case ThemeModePreference.light: return 'Світла';
      case ThemeModePreference.dark: return 'Темна';
    }
  }
}

/// Налаштування конфіденційності користувача.
class PrivacySettings {
  /// Чи показувати суму заощаджень у профілі.
  final bool showTotalSaved;

  /// Чи показувати статистику внесків.
  final bool showDepositStats;

  /// Чи показувати рівень та XP іншим користувачам.
  final bool showLevelToOthers;

  /// Чи дозволяти пошук за іменем.
  final bool allowSearchByName;

  /// Чи дозволяти спільний доступ до цілей.
  final bool allowGoalSharing;

  const PrivacySettings({
    this.showTotalSaved = true,
    this.showDepositStats = true,
    this.showLevelToOthers = true,
    this.allowSearchByName = true,
    this.allowGoalSharing = true,
  });

  factory PrivacySettings.fromJson(Map<String, dynamic> json) {
    return PrivacySettings(
      showTotalSaved: (json['showTotalSaved'] as bool?) ?? true,
      showDepositStats: (json['showDepositStats'] as bool?) ?? true,
      showLevelToOthers: (json['showLevelToOthers'] as bool?) ?? true,
      allowSearchByName: (json['allowSearchByName'] as bool?) ?? true,
      allowGoalSharing: (json['allowGoalSharing'] as bool?) ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'showTotalSaved': showTotalSaved,
      'showDepositStats': showDepositStats,
      'showLevelToOthers': showLevelToOthers,
      'allowSearchByName': allowSearchByName,
      'allowGoalSharing': allowGoalSharing,
    };
  }
}
