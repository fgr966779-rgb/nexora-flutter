import 'dart:convert';

import 'package:nexora/data/models/user_profile_model.dart';

/// Репозиторій профілю користувача (in-memory).
///
/// Забезпечує повне керування профілем, налаштуваннями,
/// бейджами, історією XP, монетами, стріком, придбаними
/// розблокуваннями та експортом/імпортом у JSON.
///
/// Додатково: пакетне оновлення профілю, управління вподобаннями,
/// агрегація статистики, відстеження активності, прогресія рівнів,
/// міграція даних, очищення даних, журнал дій.
///
/// Всі рядки-повідомлення українською.
class UserRepository {
  UserProfile? _user;
  Map<String, dynamic> _settings = {};
  final List<Map<String, dynamic>> _activityLog = [];

  // ─── Статистика профілю ─────────────────────────────────────────────

  /// Повертає кількість днів з моменту останньої активності.
  /// Якщо активності не було — повертає null.
  int? get daysSinceLastActive {
    if (_user == null || _user!.lastActiveDate == null) return null;
    return DateTime.now().difference(_user!.lastActiveDate!).inDays;
  }

  /// Повертає XP, зароблений за сьогодні.
  int get todayXp {
    final user = getUser();
    return user.todayXp;
  }

  /// Повертає XP, зароблений за цей тиждень.
  int get thisWeekXp {
    final user = getUser();
    return user.thisWeekXp;
  }

  /// Повертає повний статистичний зведення профілю.
  Map<String, dynamic> getProfileSummary() {
    final user = getUser();
    return {
      'ім\'я': user.name,
      'email': user.email,
      'рівень': user.level,
      'назваРівня': user.levelName,
      'xp': user.xp,
      'xpДоНаступного': user.xpUntilNextLevel,
      'прогресРівня': user.levelProgress,
      'монети': user.coins,
      'стрік': user.currentStreak,
      'найбільшійСтрік': user.longestStreak,
      'бейджів': user.unlockedBadges.length,
      'придбань': user.purchasedUnlocks.length,
      'днівЗРеєстрації': user.daysSinceRegistration,
      'тема': user.activeTheme,
      'звукУвімкнено': user.soundsEnabled,
      'вібраціяУвімкнено': user.hapticsEnabled,
    };
  }

  /// Повертає агреговану статистику за весь час.
  Map<String, dynamic> getAggregatedStats() {
    final user = getUser();
    final xpSummary = getXpSummaryBySource();
    final totalXpEarned = xpSummary.values.fold(0, (a, b) => a + b);

    return {
      'загальнийXp': totalXpEarned,
      'поточнийРівень': user.currentLevel,
      'загальниМонети': user.coins,
      'найбільшійСтрік': user.longestStreak,
      'поточнийСтрік': user.currentStreak,
      'кількістьБейджів': user.unlockedBadges.length,
      'кількістьПридбань': user.purchasedUnlocks.length,
      'джерелаХр': xpSummary,
      'днейЗРеєстрації': user.daysSinceRegistration,
      'днейБезперервноЇАктивності': user.currentStreak,
    };
  }

  /// Повертає щоденну статистику XP за останні [days] днів.
  Map<String, int> getDailyXpStats({int days = 7}) {
    final history = getXpHistory(limit: 500);
    final now = DateTime.now();
    final dailyStats = <String, int>{};

    for (var i = 0; i < days; i++) {
      final date = now.subtract(Duration(days: i));
      final key = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      dailyStats[key] = 0;
    }

    for (final entry in history) {
      final key = '${entry.timestamp.year}-${entry.timestamp.month.toString().padLeft(2, '0')}-${entry.timestamp.day.toString().padLeft(2, '0')}';
      if (dailyStats.containsKey(key)) {
        dailyStats[key] = (dailyStats[key] ?? 0) + entry.amount;
      }
    }

    return dailyStats;
  }

  // ─── Базові методи ─────────────────────────────────────────────────

  /// Повертає профіль користувача. Якщо не існує — створює за замовчуванням.
  UserProfile getUser() {
    _user ??= UserProfile.defaultProfile();
    return _user!;
  }

  /// Зберігає профіль користувача.
  void save(UserProfile user) {
    _user = user;
  }

  /// Скидає профіль до значень за замовчуванням.
  void reset() {
    _user = UserProfile.defaultProfile();
    _settings = {};
    _activityLog.clear();
  }

  /// Повне скидання з очищенням всієї історії XP.
  /// Використовується при виході з акаунту або скиданні даних.
  void fullReset() {
    _user = null;
    _settings = {};
    _activityLog.clear();
  }

  /// Чи існує профіль.
  bool get hasUser => _user != null;

  /// Чи пройдено онбординг (ім'я змінено з дефолтного).
  bool get hasCompletedOnboarding {
    if (_user == null) return false;
    return _user!.name != 'Користувач';
  }

  /// Чи користувач має активний стрік (1+ день поспіль).
  bool get hasActiveStreak {
    return getUser().hasActiveStreak;
  }

  /// Кількість розблокованих бейджів.
  int get badgeCount {
    return getUser().achievementCount;
  }

  /// Кількість придбаних розблокувань.
  int get purchasedCount {
    return getUser().purchasedCount;
  }

  // ─── Методи оновлення профілю ──────────────────────────────────────

  /// Оновлює ім'я користувача.
  /// Повертає true, якщо ім'я успішно змінено.
  bool updateName(String name) {
    if (name.trim().isEmpty) return false;
    final user = getUser();
    user.name = name.trim();
    save(user);
    _logActivity('оновлення_ім\'я', 'Нове ім\'я: ${name.trim()}');
    return true;
  }

  /// Оновлює email користувача.
  /// Перевіряє базовий формат email перед збереженням.
  bool updateEmail(String email) {
    if (email.isEmpty) {
      final user = getUser();
      user.email = '';
      save(user);
      _logActivity('оновлення_email', 'Email видалено');
      return true;
    }
    // Базова валідація формату email
    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!emailRegex.hasMatch(email)) return false;
    final user = getUser();
    user.email = email.trim();
    save(user);
    _logActivity('оновлення_email', 'Новий email: ${email.trim()}');
    return true;
  }

  /// Оновлює аватар користувача.
  void updateAvatar(String avatarUrl) {
    final user = getUser();
    user.avatarUrl = avatarUrl;
    save(user);
    _logActivity('оновлення_аватара', 'Новий аватар встановлено');
  }

  /// Оновлює тему оформлення.
  void updateTheme(String theme) {
    final user = getUser();
    user.activeTheme = theme;
    save(user);
    _logActivity('оновлення_теми', 'Тема: $theme');
  }

  /// Оновлює звук та вібрацію.
  void updateSoundAndHaptics({bool? sounds, bool? haptics}) {
    final user = getUser();
    user.updateProfile(
      soundsEnabled: sounds,
      hapticsEnabled: haptics,
    );
    save(user);
    _logActivity('оновлення_звуку', 'Звук: $sounds, Вібрація: $haptics');
  }

  /// Багаторазове оновлення полів профілю.
  void updateProfile({
    String? name,
    String? email,
    String? avatarUrl,
    String? activeTheme,
    bool? soundsEnabled,
    bool? hapticsEnabled,
  }) {
    final user = getUser();
    user.updateProfile(
      name: name,
      email: email,
      avatarUrl: avatarUrl,
      activeTheme: activeTheme,
      soundsEnabled: soundsEnabled,
      hapticsEnabled: hapticsEnabled,
    );
    save(user);
    _logActivity('оновлення_профілю', 'Пакетне оновлення профілю');
  }

  /// Пакетне оновлення з чергою змін.
  ///
  /// Приймає список змін, які будуть застосовані послідовно.
  /// Логує кожну зміну окремо.
  void batchUpdateProfile(List<Map<String, dynamic>> changes) {
    final user = getUser();
    for (final change in changes) {
      final field = change['field'] as String?;
      final value = change['value'];
      if (field == null) continue;

      switch (field) {
        case 'name':
          if (value is String && value.trim().isNotEmpty) user.name = value.trim();
          break;
        case 'email':
          if (value is String) user.email = value.trim();
          break;
        case 'avatarUrl':
          if (value is String) user.avatarUrl = value;
          break;
        case 'activeTheme':
          if (value is String) user.activeTheme = value;
          break;
      }
    }
    save(user);
    _logActivity('пакетне_оновлення', '${changes.length} змін застосовано');
  }

  /// Оновлює дату останньої активності на поточний момент.
  void touchActivity() {
    final user = getUser();
    user.touchActivity();
    save(user);
  }

  // ─── Управління вподобаннями ──────────────────────────────────────

  /// Отримує всі вподобання користувача (копія мапи).
  Map<String, dynamic> getPreferences() {
    return Map.unmodifiable(_settings);
  }

  /// Встановлює вподобання.
  void setPreferences(Map<String, dynamic> prefs) {
    _settings.addAll(prefs);
    _logActivity('оновлення_вподобань', 'Оновлено ${prefs.length} налаштувань');
  }

  /// Отримує конкретне вподобання.
  T? getPreference<T>(String key) {
    return _settings[key] as T?;
  }

  /// Встановлює конкретне вподобання.
  void setPreference<T>(String key, T value) {
    _settings[key] = value;
  }

  /// Скидає всі вподобання до значень за замовчуванням.
  void resetPreferences() {
    _settings.clear();
    _logActivity('скидання_вподобань', 'Усі налаштування скинуто');
  }

  // ─── Сповіщення ────────────────────────────────────────────────────

  /// Отримує налаштування сповіщень (копія мапи).
  Map<String, bool> getNotificationPrefs() {
    return getUser().getNotificationPrefs();
  }

  /// Встановлює налаштування сповіщень (повна заміна).
  void setNotificationPrefs(Map<String, bool> prefs) {
    final user = getUser();
    user.setNotificationPrefs(prefs);
    save(user);
  }

  /// Вмикає конкретне сповіщення за ключем.
  void enableNotification(String key) {
    final user = getUser();
    user.enableNotification(key);
    save(user);
  }

  /// Вимикає конкретне сповішення за ключем.
  void disableNotification(String key) {
    final user = getUser();
    user.disableNotification(key);
    save(user);
  }

  /// Перевіряє, чи увімкнено конкретне сповіщення.
  bool isNotificationEnabled(String key) {
    return getUser().isNotificationEnabled(key);
  }

  /// Повертає список усіх ключів сповіщень з їхніми станами.
  /// Зручно для відображення у налаштуваннях.
  List<MapEntry<String, bool>> get notificationEntries {
    return getNotificationPrefs().entries.toList();
  }

  /// Повертає список українських назв для ключів сповіщень.
  static const Map<String, String> notificationLabels = {
    'depositReminder': 'Нагадування про внесок',
    'goalReached': 'Ціль досягнута',
    'challengeAvailable': 'Новий виклик доступний',
    'streakWarning': 'Попередження про стрік',
    'weeklySummary': 'Щотижневий звіт',
    'achievementUnlocked': 'Нове досягнення',
    'dailyReminder': 'Щоденне нагадування',
    'monthlyReport': 'Щомісячний звіт',
  };

  // ─── Історія XP ────────────────────────────────────────────────────

  /// Додає запис в історію XP з вказаним джерелом.
  /// Повертає true, якщо рівень підвищено.
  bool addToXpHistory(int amount, String source) {
    final user = getUser();
    final result = user.addXpWithSource(amount, source);
    save(user);
    _logActivity('отримання_xp', '+$amount XP від "$source"');
    return result;
  }

  /// Отримує історію XP (найновіші перші).
  List<XpHistoryEntry> getXpHistory({int limit = 50}) {
    return getUser().getXpHistory(limit: limit);
  }

  /// Отримує історію XP за конкретний період.
  List<XpHistoryEntry> getXpHistorySince(DateTime since) {
    final all = getUser().getXpHistory(limit: 1000);
    return all.where((e) => e.timestamp.isAfter(since)).toList();
  }

  /// Отримує історію XP за конкретним джерелом.
  List<XpHistoryEntry> getXpHistoryBySource(String source) {
    final all = getUser().getXpHistory(limit: 1000);
    return all.where((e) => e.source == source).toList();
  }

  /// Повертає зведення XP за джерелами.
  Map<String, int> getXpSummaryBySource() {
    final all = getUser().getXpHistory(limit: 1000);
    final summary = <String, int>{};
    for (final entry in all) {
      summary[entry.source] = (summary[entry.source] ?? 0) + entry.amount;
    }
    return summary;
  }

  /// Очищає історію XP (для адміністративних потреб).
  void clearXpHistory() {
    final user = getUser();
    user.xpHistory.clear();
    save(user);
    _logActivity('очищення_історії_xp', 'Історію XP очищено');
  }

  // ─── Прогресія рівнів ──────────────────────────────────────────────

  /// Повертає інформацію про прогресію до наступного рівня.
  Map<String, dynamic> getLevelProgression() {
    final user = getUser();
    return {
      'поточнийРівень': user.currentLevel,
      'назваРівня': user.levelName,
      'поточнийXp': user.xp,
      'xpДляНаступного': user.xpUntilNextLevel,
      'прогрес': user.levelProgress,
      'залишилосяXp': user.xpUntilNextLevel - (user.xp % user.xpUntilNextLevel),
    };
  }

  /// Повертає назву рівня українською за номером.
  static String getLevelName(int level) {
    if (level >= 50) return 'Легенда';
    if (level >= 40) return 'Майстер';
    if (level >= 30) return 'Експерт';
    if (level >= 20) return 'Ветеран';
    if (level >= 15) return 'Спеціаліст';
    if (level >= 10) return 'Професіонал';
    if (level >= 7) return 'Тіністер';
    if (level >= 5) return 'Знавець';
    if (level >= 3) return 'Початківець+';
    if (level >= 1) return 'Початківець';
    return 'Новачок';
  }

  // ─── Журнал активності ─────────────────────────────────────────────

  /// Логує дію користувача.
  void _logActivity(String action, String details) {
    _activityLog.add({
      'дія': action,
      'деталі': details,
      'час': DateTime.now().toIso8601String(),
    });
    // Обмежуємо розмір журналу — зберігаємо останні 200 записів
    if (_activityLog.length > 200) {
      _activityLog.removeRange(0, _activityLog.length - 200);
    }
  }

  /// Повертає журнал активності (найновіші перші).
  List<Map<String, dynamic>> getActivityLog({int limit = 50}) {
    if (limit >= _activityLog.length) {
      return List.unmodifiable(_activityLog.reversed.toList());
    }
    return List.unmodifiable(
      _activityLog.reversed.take(limit).toList(),
    );
  }

  /// Очищає журнал активності.
  void clearActivityLog() {
    _activityLog.clear();
  }

  /// Повертає кількість записів у журналі.
  int get activityLogCount => _activityLog.length;

  // ─── Бейджі ────────────────────────────────────────────────────────

  /// Додає бейж. Повертає true якщо бейдж був новим.
  bool addBadge(String badgeId) {
    final user = getUser();
    final result = user.unlockBadge(badgeId);
    save(user);
    if (result) _logActivity('розблокування_бейджа', 'Бейдж: $badgeId');
    return result;
  }

  /// Видаляє бейдж. Повертає true якщо бейдж існував.
  bool removeBadge(String badgeId) {
    final user = getUser();
    final result = user.removeBadge(badgeId);
    save(user);
    return result;
  }

  /// Отримує список усіх бейджів.
  List<String> getBadges() {
    return getUser().getBadgesList();
  }

  /// Чи має користувач певний бейдж.
  bool hasBadge(String badgeId) {
    return getUser().hasBadge(badgeId);
  }

  /// Перевіряє, чи має користувач усі бейджі з указаного списку.
  bool hasAllBadges(List<String> badgeIds) {
    return badgeIds.every((id) => hasBadge(id));
  }

  /// Перевіряє, чи має користувач хоча б один бейдж зі списку.
  bool hasAnyBadge(List<String> badgeIds) {
    return badgeIds.any((id) => hasBadge(id));
  }

  /// Перемикає бейдж: додає якщо немає, видаляє якщо є.
  bool toggleBadge(String badgeId) {
    if (hasBadge(badgeId)) {
      return removeBadge(badgeId);
    }
    return addBadge(badgeId);
  }

  /// Повертає кількість бейджів, яких не вистачає для повної колекції.
  int missingBadgesCount(List<String> allBadgeIds) {
    return allBadgeIds.where((id) => !hasBadge(id)).length;
  }

  // ─── Придбані розблокування ────────────────────────────────────────

  /// Додає придбане розблокування.
  void addPurchasedUnlock(String unlockId) {
    final user = getUser();
    if (!user.purchasedUnlocks.contains(unlockId)) {
      user.purchasedUnlocks = [...user.purchasedUnlocks, unlockId];
      save(user);
      _logActivity('придбання', 'Розблокування: $unlockId');
    }
  }

  /// Видаляє придбане розблокування.
  void removePurchasedUnlock(String unlockId) {
    final user = getUser();
    user.purchasedUnlocks = user.purchasedUnlocks
        .where((u) => u != unlockId)
        .toList();
    save(user);
  }

  /// Чи має користувач вказане придбане розблокування.
  bool hasPurchasedUnlock(String unlockId) {
    return getUser().purchasedUnlocks.contains(unlockId);
  }

  /// Повертає список усіх придбаних розблокувань.
  List<String> getPurchasedUnlocks() {
    return List.unmodifiable(getUser().purchasedUnlocks);
  }

  // ─── XP та Монети ──────────────────────────────────────────────────

  /// Додає XP. Повертає true якщо рівень підвищено.
  bool addXp(int amount) {
    final user = getUser();
    final result = user.addXp(amount);
    save(user);
    _logActivity('отримання_xp', '+$amount XP');
    return result;
  }

  /// Додає монети.
  void addCoins(int amount) {
    final user = getUser();
    user.addCoins(amount);
    save(user);
    _logActivity('отримання_монет', '+$amount монет');
  }

  /// Витрачає монети. Повертає true якщо вистачило коштів.
  bool spendCoins(int amount) {
    final user = getUser();
    final result = user.spendCoins(amount);
    save(user);
    if (result) _logActivity('витрата_монет', '-$amount монет');
    return result;
  }

  /// Перевіряє, чи достатньо монет для покупки.
  bool canAfford(int amount) {
    return getUser().coins >= amount;
  }

  // ─── Стрік ─────────────────────────────────────────────────────────

  /// Оновлює стрік користувача.
  /// Повертає true якщо стрік продовжено (не перший день).
  bool updateStreak() {
    final user = getUser();
    final result = user.updateStreak();
    save(user);
    if (result) _logActivity('продовження_стріку', 'Стрік: ${user.currentStreak} днів');
    return result;
  }

  /// Повертає текстовий статус стріку українською.
  String get streakStatusText {
    return getUser().streakStatus;
  }

  /// Повертає детальну інформацію про стрік.
  Map<String, dynamic> getStreakInfo() {
    final user = getUser();
    return {
      'поточний': user.currentStreak,
      'найбільший': user.longestStreak,
      'активний': user.hasActiveStreak,
      'статус': user.streakStatus,
    };
  }

  // ─── Налаштування ──────────────────────────────────────────────────

  /// Отримує всі налаштування (незмінна копія).
  Map<String, dynamic> getSettings() {
    return Map.unmodifiable(_settings);
  }

  /// Оновлює налаштування (об'єднання з існуючими).
  void updateSettings(Map<String, dynamic> settings) {
    _settings.addAll(settings);
  }

  /// Отримує конкретне налаштування.
  T? getSetting<T>(String key) {
    return _settings[key] as T?;
  }

  /// Встановлює конкретне налаштування.
  void setSetting<T>(String key, T value) {
    _settings[key] = value;
  }

  /// Видаляє конкретне налаштування.
  void removeSetting(String key) {
    _settings.remove(key);
  }

  /// Перевіряє, чи існує налаштування.
  bool hasSetting(String key) {
    return _settings.containsKey(key);
  }

  /// Очищає всі налаштування.
  void clearSettings() {
    _settings.clear();
  }

  /// Скидає конкретне налаштування до значення за замовчуванням.
  void resetSetting(String key) {
    _settings.remove(key);
  }

  // ─── Міграція та очищення даних ────────────────────────────────────

  /// Виконує міграцію даних користувача до нової версії.
  ///
  /// [fromVersion] — поточна версія даних.
  /// [toVersion] — цільова версія даних.
  bool migrateData({required int fromVersion, required int toVersion}) {
    if (fromVersion >= toVersion) return true;

    _logActivity('міграція_даних', 'З версії $fromVersion до $toVersion');

    final user = getUser();

    // Міграція версії 1 → 2
    if (fromVersion < 2) {
      // Додати нові поля за замовчуванням
      if (user.activeTheme.isEmpty) {
        user.activeTheme = 'ps5';
      }
    }

    // Міграція версії 2 → 3
    if (fromVersion < 3) {
      // Додати нові налаштування сповіщень
      enableNotification('dailyReminder');
      enableNotification('monthlyReport');
    }

    save(user);
    return true;
  }

  /// Очищає застарілі дані користувача.
  ///
  /// Видаляє: старі записи активності, застарілі кешовані дані.
  void cleanupOldData({int keepActivityDays = 90}) {
    final cutoff = DateTime.now().subtract(Duration(days: keepActivityDays));

    // Очищення журналу активності
    final initialCount = _activityLog.length;
    _activityLog.removeWhere((entry) {
      final timestamp = DateTime.parse(entry['час'] as String);
      return timestamp.isBefore(cutoff);
    });

    if (_activityLog.length < initialCount) {
      _logActivity('очищення_даних',
        'Видалено ${initialCount - _activityLog.length} застарілих записів');
    }

    // У майбутньому: очистка кешу зображень, Lottie анімацій
  }

  /// Повертає розмір даних у пам'яті (приблизно).
  int get estimatedMemorySize {
    final userData = exportToJson().length;
    final settingsSize = _settings.toString().length;
    final logSize = _activityLog.toString().length;
    return userData + settingsSize + logSize;
  }

  // ─── Експорт / Імпорт ──────────────────────────────────────────────

  /// Експортує профіль у форматований JSON.
  String exportToJson() {
    final user = getUser();
    final data = {
      'version': '1.0.0',
      'exportedAt': DateTime.now().toIso8601String(),
      'app': 'nexora',
      'profile': user.toJson(),
      'settings': _settings,
      'activityLog': _activityLog.length > 50
          ? _activityLog.take(50).toList()
          : _activityLog,
    };
    return const JsonEncoder.withIndent('  ').convert(data);
  }

  /// Імпортує профіль з JSON. Повертає true у разі успіху.
  bool importFromJson(String jsonString) {
    try {
      final data = json.decode(jsonString) as Map<String, dynamic>;
      if (data['profile'] == null) return false;

      final user = UserProfile.fromJson(
        data['profile'] as Map<String, dynamic>,
      );
      save(user);

      if (data['settings'] != null) {
        _settings = Map<String, dynamic>.from(data['settings'] as Map);
      }

      if (data['activityLog'] != null) {
        _activityLog.clear();
        _activityLog.addAll(
          (data['activityLog'] as List).cast<Map<String, dynamic>>(),
        );
      }

      _logActivity('імпорт_профілю', 'Профіль імпортовано успішно');
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Експортує мінімальний профіль (для швидкого бекапу).
  Map<String, dynamic> exportMinimal() {
    final user = getUser();
    return {
      'name': user.name,
      'email': user.email,
      'xp': user.xp,
      'coins': user.coins,
      'currentLevel': user.currentLevel,
      'currentStreak': user.currentStreak,
      'longestStreak': user.longestStreak,
      'badges': user.unlockedBadges,
      'purchasedUnlocks': user.purchasedUnlocks,
      'daysSinceRegistration': user.daysSinceRegistration,
    };
  }

  /// Імпортує мінімальний профіль з мапи.
  /// Не перезаписує історію XP та налаштування.
  bool importMinimal(Map<String, dynamic> data) {
    try {
      final user = getUser();
      if (data['name'] != null) user.name = data['name'] as String;
      if (data['email'] != null) user.email = data['email'] as String;
      if (data['xp'] != null) user.xp = data['xp'] as int;
      if (data['coins'] != null) user.coins = data['coins'] as int;
      if (data['currentLevel'] != null) {
        user.currentLevel = data['currentLevel'] as int;
      }
      if (data['currentStreak'] != null) {
        user.currentStreak = data['currentStreak'] as int;
      }
      if (data['longestStreak'] != null) {
        user.longestStreak = data['longestStreak'] as int;
      }
      if (data['badges'] != null) {
        user.unlockedBadges = (data['badges'] as List<dynamic>)
            .map((e) => e as String)
            .toList();
      }
      save(user);
      _logActivity('імпорт_мінімального_профілю', 'Профіль оновлено');
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Повертає розмір експортованого JSON у байтах.
  int get exportSizeInBytes {
    return exportToJson().length;
  }

  /// Форматований розмір експорту (Б / КБ / МБ).
  String get formattedExportSize {
    final bytes = exportSizeInBytes;
    if (bytes < 1024) return '$bytes Б';
    if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} КБ';
    }
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} МБ';
  }

  /// Перевіряє цілісність даних профілю.
  ///
  /// Повертає список виявлених проблем (порожній, якщо все ок).
  List<String> validateDataIntegrity() {
    final issues = <String>[];
    final user = getUser();

    if (user.name.isEmpty) {
      issues.add('Ім\'я користувача порожнє');
    }
    if (user.xp < 0) {
      issues.add('XP не може бути від\'ємним');
    }
    if (user.coins < 0) {
      issues.add('Монети не можуть бути від\'ємними');
    }
    if (user.currentStreak < 0) {
      issues.add('Стрік не може бути від\'ємним');
    }

    return issues;
  }
}
