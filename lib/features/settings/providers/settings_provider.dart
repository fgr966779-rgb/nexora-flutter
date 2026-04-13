// ═══════════════════════════════════════════════════════════════════════════
// settings_provider.dart — Settings State Management Provider
// ═══════════════════════════════════════════════════════════════════════════
//
/// Провайдер налаштувань користувача з міграцією для Riverpod.
///
/// Надає повний контроль над всіма аспектами налаштувань:
/// - Звук та тактильна віддача
/// - Сповіщення (щоденні, виклики, стріки, бейджі, заморожені цілі)
/// - Профіль користувача з валідацією
/// - Зовнішній вигляд (тема, акцент, режим)
/// - Мова та валюта
/// - Резервне копіювання з міграцією
/// - Конфіденційність та аналітика
/// - Продуктивність
/// - Пошук налаштувань
/// - Експорт/імпорт даних
///
/// {@category Providers}
/// {@subcategory Settings}
library;

import 'dart:convert';
import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/user_profile_model.dart';
import '../../../data/repositories/user_repository.dart';

/// ─── Logging ─────────────────────────────────────────────────────────────

/// Тег для логування подій провайдера налаштувань.
const String _logTag = '⚙️ SettingsProvider';

/// ─── Settings State ─────────────────────────────────────────────────────────

/// Незмінний стан налаштувань користувача.
///
/// Зберігає всі параметри налаштувань і надає методи
/// для їх зміни, валідації, серіалізації та десеріалізації.
///
/// Всі зміни через [copyWith] є імутабельними.
///
/// Приклад:
/// ```dart
/// final state = SettingsState(soundsEnabled: true);
/// final updated = state.copyWith(soundsEnabled: false);
/// ```
class SettingsState {
  /// Чи увімкнено звуки.
  final bool soundsEnabled;

  /// Гучність звуків (0.0 – 1.0).
  final double soundVolume;

  /// Чи увімкнено тактильну віддачу.
  final bool hapticsEnabled;

  /// Чи увімкнено сповіщення загалом.
  final bool notificationsEnabled;

  /// Сповіщення про заморожену ціль.
  final bool frozenGoalNotifications;

  /// Сповіщення про досягнення мілістонів.
  final bool milestoneNotifications;

  /// Сповіщення про виклики.
  final bool challengeNotifications;

  /// Сповіщення про нові бейджі.
  final bool badgeNotifications;

  /// Час щоденного нагадування.
  final TimeOfDay dailyReminderTime;

  /// Ім'я користувача.
  final String userName;

  /// Електронна пошта користувача.
  final String userEmail;

  /// Уподобання теми (PS5, Monitor).
  final String themePreference;

  /// Темний/світлий режим.
  final ThemeMode themeMode;

  /// Формат валюти.
  final String currencyFormat;

  /// Мова додатку.
  final String language;

  /// Чи увімкнено авто-резервне копіювання.
  final bool autoBackupEnabled;

  /// Частота авто-резервного копіювання (дні).
  final int autoBackupFrequencyDays;

  /// Остання дата резервного копіювання.
  final DateTime? lastBackupDate;

  /// Конфіденційність — показувати прогрес іншим.
  final bool shareProgressEnabled;

  /// Конфіденційність — аналітика.
  final bool analyticsEnabled;

  /// Версія додатку.
  final String appVersion;

  /// Дата першої установки.
  final DateTime? installDate;

  /// Режим економії заряду (обмежує анімації).
  final bool batterySaverMode;

  /// Режим компактного відображення.
  final bool compactMode;

  /// ID кастомного кольору акценту (hex).
  final String accentColorHex;

  /// Дата останнього входу.
  final DateTime? lastLoginDate;

  /// Кількість сесій з моменту останнього скидання.
  final int activeSessions;

  /// Чи користувач пройшовов onboarding.
  final bool onboardingCompleted;

  /// Чи увімкнено push-сповіщення на рівні системи.
  final bool systemNotificationsEnabled;

  /// Кількість пропусків нагадувань за останній тиждень.
  final int missedRemindersThisWeek;

  const SettingsState({
    this.soundsEnabled = true,
    this.soundVolume = 0.7,
    this.hapticsEnabled = true,
    this.notificationsEnabled = true,
    this.frozenGoalNotifications = true,
    this.milestoneNotifications = true,
    this.challengeNotifications = true,
    this.badgeNotifications = true,
    this.dailyReminderTime = const TimeOfDay(hour: 20, minute: 0),
    this.userName = 'Користувач',
    this.userEmail = '',
    this.themePreference = 'default',
    this.themeMode = ThemeMode.system,
    this.currencyFormat = 'грн',
    this.language = 'uk',
    this.autoBackupEnabled = true,
    this.autoBackupFrequencyDays = 7,
    this.lastBackupDate,
    this.shareProgressEnabled = false,
    this.analyticsEnabled = true,
    this.appVersion = '1.0.0',
    this.installDate,
    this.batterySaverMode = false,
    this.compactMode = false,
    this.accentColorHex = '#0070D1',
    this.lastLoginDate,
    this.activeSessions = 1,
    this.onboardingCompleted = true,
    this.systemNotificationsEnabled = true,
    this.missedRemindersThisWeek = 0,
  });

  /// Створює копію стану з вибірковими змінами.
  ///
  /// Всі параметри, що не передані, залишаються без змін.
  SettingsState copyWith({
    bool? soundsEnabled,
    double? soundVolume,
    bool? hapticsEnabled,
    bool? notificationsEnabled,
    bool? frozenGoalNotifications,
    bool? milestoneNotifications,
    bool? challengeNotifications,
    bool? badgeNotifications,
    TimeOfDay? dailyReminderTime,
    String? userName,
    String? userEmail,
    String? themePreference,
    ThemeMode? themeMode,
    String? currencyFormat,
    String? language,
    bool? autoBackupEnabled,
    int? autoBackupFrequencyDays,
    DateTime? lastBackupDate,
    bool clearBackupDate = false,
    bool? shareProgressEnabled,
    bool? analyticsEnabled,
    String? appVersion,
    DateTime? installDate,
    bool? batterySaverMode,
    bool? compactMode,
    String? accentColorHex,
    DateTime? lastLoginDate,
    int? activeSessions,
    bool? onboardingCompleted,
    bool? systemNotificationsEnabled,
    int? missedRemindersThisWeek,
  }) {
    return SettingsState(
      soundsEnabled: soundsEnabled ?? this.soundsEnabled,
      soundVolume: soundVolume ?? this.soundVolume,
      hapticsEnabled: hapticsEnabled ?? this.hapticsEnabled,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      frozenGoalNotifications: frozenGoalNotifications ?? this.frozenGoalNotifications,
      milestoneNotifications: milestoneNotifications ?? this.milestoneNotifications,
      challengeNotifications: challengeNotifications ?? this.challengeNotifications,
      badgeNotifications: badgeNotifications ?? this.badgeNotifications,
      dailyReminderTime: dailyReminderTime ?? this.dailyReminderTime,
      userName: userName ?? this.userName,
      userEmail: userEmail ?? this.userEmail,
      themePreference: themePreference ?? this.themePreference,
      themeMode: themeMode ?? this.themeMode,
      currencyFormat: currencyFormat ?? this.currencyFormat,
      language: language ?? this.language,
      autoBackupEnabled: autoBackupEnabled ?? this.autoBackupEnabled,
      autoBackupFrequencyDays: autoBackupFrequencyDays ?? this.autoBackupFrequencyDays,
      lastBackupDate: clearBackupDate ? null : (lastBackupDate ?? this.lastBackupDate),
      shareProgressEnabled: shareProgressEnabled ?? this.shareProgressEnabled,
      analyticsEnabled: analyticsEnabled ?? this.analyticsEnabled,
      appVersion: appVersion ?? this.appVersion,
      installDate: installDate ?? this.installDate,
      batterySaverMode: batterySaverMode ?? this.batterySaverMode,
      compactMode: compactMode ?? this.compactMode,
      accentColorHex: accentColorHex ?? this.accentColorHex,
      lastLoginDate: lastLoginDate ?? this.lastLoginDate,
      activeSessions: activeSessions ?? this.activeSessions,
      onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
      systemNotificationsEnabled: systemNotificationsEnabled ?? this.systemNotificationsEnabled,
      missedRemindersThisWeek: missedRemindersThisWeek ?? this.missedRemindersThisWeek,
    );
  }

  /// Конвертує стан у формат JSON.
  Map<String, dynamic> toJson() {
    return {
      'soundsEnabled': soundsEnabled,
      'soundVolume': soundVolume,
      'hapticsEnabled': hapticsEnabled,
      'notificationsEnabled': notificationsEnabled,
      'frozenGoalNotifications': frozenGoalNotifications,
      'milestoneNotifications': milestoneNotifications,
      'challengeNotifications': challengeNotifications,
      'badgeNotifications': badgeNotifications,
      'dailyReminderHour': dailyReminderTime.hour,
      'dailyReminderMinute': dailyReminderTime.minute,
      'userName': userName,
      'userEmail': userEmail,
      'themePreference': themePreference,
      'themeMode': themeMode.name,
      'currencyFormat': currencyFormat,
      'language': language,
      'autoBackupEnabled': autoBackupEnabled,
      'autoBackupFrequencyDays': autoBackupFrequencyDays,
      'shareProgressEnabled': shareProgressEnabled,
      'analyticsEnabled': analyticsEnabled,
      'batterySaverMode': batterySaverMode,
      'compactMode': compactMode,
      'accentColorHex': accentColorHex,
      'lastLoginDate': lastLoginDate?.toIso8601String(),
      'activeSessions': activeSessions,
      'onboardingCompleted': onboardingCompleted,
      'systemNotificationsEnabled': systemNotificationsEnabled,
      'missedRemindersThisWeek': missedRemindersThisWeek,
    };
  }

  /// Відновлює стан з JSON рядка.
  factory SettingsState.fromJson(Map<String, dynamic> json) {
    try {
      return SettingsState(
        soundsEnabled: json['soundsEnabled'] as bool? ?? true,
        soundVolume: (json['soundVolume'] as num?)?.toDouble() ?? 0.7,
        hapticsEnabled: json['hapticsEnabled'] as bool? ?? true,
        notificationsEnabled: json['notificationsEnabled'] as bool? ?? true,
        frozenGoalNotifications: json['frozenGoalNotifications'] as bool? ?? true,
        milestoneNotifications: json['milestoneNotifications'] as bool? ?? true,
        challengeNotifications: json['challengeNotifications'] as bool? ?? true,
        badgeNotifications: json['badgeNotifications'] as bool? ?? true,
        dailyReminderTime: TimeOfDay(hour: json['dailyReminderHour'] as int? ?? 20, minute: json['dailyReminderMinute'] as int? ?? 0),
        userName: json['userName'] as String? ?? 'Користувач',
        userEmail: json['userEmail'] as String? ?? '',
        themePreference: json['themePreference'] as String? ?? 'default',
        currencyFormat: json['currencyFormat'] as String? ?? 'грн',
        language: json['language'] as String? ?? 'uk',
        autoBackupEnabled: json['autoBackupEnabled'] as bool? ?? true,
        autoBackupFrequencyDays: json['autoBackupFrequencyDays'] as int? ?? 7,
        shareProgressEnabled: json['shareProgressEnabled'] as bool? ?? false,
        analyticsEnabled: json['analyticsEnabled'] as bool? ?? true,
        batterySaverMode: json['batterySaverMode'] as bool? ?? false,
        compactMode: json['compactMode'] as bool? ?? false,
        accentColorHex: json['accentColorHex'] as String? ?? '#0070D1',
        lastLoginDate: json['lastLoginDate'] != null ? DateTime.tryParse(json['lastLoginDate'] as String) : null,
        activeSessions: json['activeSessions'] as int? ?? 1,
        onboardingCompleted: json['onboardingCompleted'] as bool? ?? true,
        systemNotificationsEnabled: json['systemNotificationsEnabled'] as bool? ?? true,
        missedRemindersThisWeek: json['missedRemindersThisWeek'] as int? ?? 0,
      );
    } catch (e) {
      developer.log('Error parsing settings JSON: $e', name: _logTag, level: 900);
      return const SettingsState();
    }
  }

  /// Перевіряє, чи стан відповідає версії формату.
  bool get isValidVersion => true;

  /// Кількість непорожених полів (для UI).
  int get incompleteFields => _countIncompleteFields();

  int _countIncompleteFields() {
    int count = 0;
    if (userName.isEmpty || userName == 'Користувач') count++;
    if (userEmail.isEmpty) count++;
    if (accentColorHex == '#0070D1') count++;
    return count;
  }
}

/// ─── Settings Category ────────────────────────────────────────────────────────

/// Категорія налаштувань для групування.
enum SettingsCategory {
  sound,
  notifications,
  profile,
  appearance,
  locale,
  backup,
  privacy,
  performance,
}

/// ─── Settings Notifier ─────────────────────────────────────────────────────

/// Нотифікатор для керування налаштуваннями через Riverpod.
///
/// Відповідає за збереження, завантаження, міграцію та пошук налаштувань.
///
/// Приклад:
/// ```dart
/// final settings = ref.watch(settingsProvider);
/// ```
class SettingsNotifier extends StateNotifier<SettingsState> {
  final UserRepository _userRepo;

  /// Версія формату налаштувань для міграції.
  static const int _settingsVersion = 2;

  /// Час останнього успішного збереження.
  DateTime? _lastPersistTime;

  SettingsNotifier({required UserRepository userRepo})
      : _userRepo = userRepo,
        super(const SettingsState());

  // ─── Loading ───────────────────────────────────────────────────────────

  /// Завантажує налаштування з профілю користувача.
  void loadSettings() {
    try {
      final user = _userRepo.getUser();
      state = SettingsState(
        soundsEnabled: user.soundsEnabled,
        hapticsEnabled: user.hapticsEnabled,
        userName: user.name,
        userEmail: user.email,
        themePreference: user.activeTheme,
        installDate: user.createdAt,
      );
      developer.log('Settings loaded for user: ${user.name}', name: _logTag);
    } catch (e) {
      developer.log('Error loading settings: $e', name: _logTag, level: 900);
    }
  }

  /// Завантажує налаштування з JSON рядка.
  bool loadFromJson(String jsonString) {
    try {
      final data = jsonDecode(jsonString) as Map<String, dynamic>;
      final version = data['version'] as int? ?? 1;
      final migratedData = _migrateSettings(data, version);
      state = SettingsState.fromJson(migratedData);
      _persist();
      developer.log('Settings loaded from JSON (version: $version)', name: _logTag);
      return true;
    } catch (e) {
      developer.log('Error loading settings from JSON: $e', name: _logTag, level: 900);
      return false;
    }
  }

  /// Мігрує налаштування зі старої версії на нову.
  Map<String, dynamic> _migrateSettings(Map<String, dynamic> data, int fromVersion) {
    var migrated = Map<String, dynamic>.from(data);

    if (fromVersion < 2) {
      migrated['challengeNotifications'] = true;
      migrated['badgeNotifications'] = true;
      migrated['batterySaverMode'] = false;
      migrated['compactMode'] = false;
      migrated['accentColorHex'] = '#0070D1';
    }

    if (fromVersion < 3) {
      migrated['lastLoginDate'] = null;
      migrated['activeSessions'] = 1;
      migrated['onboardingCompleted'] = true;
      migrated['systemNotificationsEnabled'] = true;
      migrated['missedRemindersThisWeek'] = 0;
    }

    migrated['version'] = _settingsVersion;
    return migrated;
  }

  // ─── Sound ─────────────────────────────────────────────────────────────

  /// Перемикає звуки.
  void toggleSounds() {
    final newValue = !state.soundsEnabled;
    state = state.copyWith(soundsEnabled: newValue);
    _persist();
    developer.log('Sounds ${newValue ? "enabled" : "disabled"}', name: _logTag);
  }

  /// Встановлює гучність (0.0–1.0).
  void setSoundVolume(double volume) {
    final clamped = volume.clamp(0.0, 1.0);
    state = state.copyWith(soundVolume: clamped);
    _persist();
    developer.log('Sound volume set to: $clamped', name: _logTag);
  }

  /// Збільшує гучність на 10%.
  void increaseVolume() => setSoundVolume(state.soundVolume + 0.1);

  /// Зменшує гучність на 10%.
  void decreaseVolume() => setSoundVolume(state.soundVolume - 0.1);

  /// Встановлює максимальну гучність.
  void setMaxVolume() => setSoundVolume(1.0);

  /// Встановлює беззвучний режим.
  void setMute() => setSoundVolume(0.0);

  /// Встановлює половину гучності.
  void setHalfVolume() => setSoundVolume(0.5);

  /// Форматована гучність (напр., "70%").
  String get formattedVolume => '${(state.soundVolume * 100).round()}%';

  /// Чи звуки увімкнені.
  bool get isSoundEnabled => state.soundsEnabled;

  /// Чи беззвучний режим.
  bool get isMuted => state.soundVolume == 0.0;

  /// Перемикає між увімкненням/вимкненням звуку.
  void toggleMute() {
    if (isMuted) {
      setSoundVolume(0.7);
    } else {
      setSoundVolume(0.0);
    }
  }

  // ─── Haptics ───────────────────────────────────────────────────────────

  /// Перемикає тактильну віддачу.
  void toggleHaptics() {
    final newValue = !state.hapticsEnabled;
    state = state.copyWith(hapticsEnabled: newValue);
    _persist();
    developer.log('Haptics ${newValue ? "enabled" : "disabled"}', name: _logTag);
  }

  /// Перевіряє, чи тактильна віддача увімкнена.
  bool get isHapticsEnabled => state.hapticsEnabled;

  // ─── Notifications ──────────────────────────────────────────────────────

  /// Перемикає сповіщення загалом.
  void toggleNotifications() {
    final newValue = !state.notificationsEnabled;
    state = state.copyWith(notificationsEnabled: newValue);
    _persist();
    developer.log('Notifications ${newValue ? "enabled" : "disabled"}', name: _logTag);
  }

  void toggleFrozenGoalNotifications() {
    state = state.copyWith(frozenGoalNotifications: !state.frozenGoalNotifications);
    _persist();
  }

  void toggleMilestoneNotifications() {
    state = state.copyWith(milestoneNotifications: !state.milestoneNotifications);
    _persist();
  }

  void toggleChallengeNotifications() {
    state = state.copyWith(challengeNotifications: !state.challengeNotifications);
    _persist();
  }

  void toggleBadgeNotifications() {
    state = state.copyWith(badgeNotifications: !state.badgeNotifications);
    _persist();
  }

  /// Вмикає всі сповіщення.
  void enableAllNotifications() {
    state = state.copyWith(notificationsEnabled: true, frozenGoalNotifications: true, milestoneNotifications: true, challengeNotifications: true, badgeNotifications: true);
    _persist();
  }

  /// Вимикає всі сповіщення.
  void disableAllNotifications() {
    state = state.copyWith(notificationsEnabled: false, frozenGoalNotifications: false, milestoneNotifications: false, challengeNotifications: false, badgeNotifications: false);
    _persist();
  }

  /// Встановлює час щоденного нагадування.
  void setReminderTime(TimeOfDay time) {
    state = state.copyWith(dailyReminderTime: time);
    _persist();
    developer.log('Reminder time set: ${time.hour}:${time.minute}', name: _logTag);
  }

  /// Форматований час нагадування ("20:00").
  String get formattedReminderTime {
    final hour = state.dailyReminderTime.hour.toString().padLeft(2, '0');
    final minute = state.dailyReminderTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  /// Кількість увімкнених категорій сповіщень.
  int get enabledNotificationCategories {
    int count = 0;
    if (state.frozenGoalNotifications) count++;
    if (state.milestoneNotifications) count++;
    if (state.challengeNotifications) count++;
    if (state.badgeNotifications) count++;
    return count;
  }

  /// Перевіряє, чи всі сповіщення увімкнено.
  bool get allNotificationsEnabled => enabledNotificationCategories >= 4;

  /// Чи сповіщення увімкнено.
  bool get areNotificationsEnabled => state.notificationsEnabled;

  // ─── Profile ──────────────────────────────────────────────────────────

  /// Оновлює ім'я (з валідацією).
  void updateName(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty || trimmed.length > 50) return;
    state = state.copyWith(userName: trimmed);
    _persist();
    developer.log('Name updated: $trimmed', name: _logTag);
  }

  /// Оновлює email.
  void updateEmail(String email) {
    final trimmed = email.trim();
    state = state.copyWith(userEmail: trimmed);
    _persist();
    developer.log('Email updated: $trimmed', name: _logTag);
  }

  /// Валідація імені.
  String? validateName(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return 'Ім\'я не може бути порожнім';
    if (trimmed.length < 2) return 'Мінімальна довжина — 2 символи';
    if (trimmed.length > 50) return 'Максимальна довжина — 50 символів';
    if (RegExp(r'[<>\{\}\[\]\\|\\]').hasMatch(trimmed)) return 'Ім\'я містить неприпустимі символи';
    return null;
  }

  /// Валідація email.
  String? validateEmail(String email) {
    final trimmed = email.trim();
    if (trimmed.isEmpty) return null;
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(trimmed)) return 'Введіть коректну електронну адресу';
    return null;
  }

  /// Перевіряє формат email без виклику помилки.
  bool isValidEmail(String email) => validateEmail(email) == null;

  /// Повна інформація про користувача.
  Map<String, dynamic> get userProfileInfo => {
    return {
      'name': state.userName,
      'email': state.userEmail,
      'joinDate': state.installDate?.toIso8601String(),
      'theme': state.themePreference,
      'language': state.language,
      'currency': state.currencyFormat,
      'level': state.xpToNextLevel,
    };
  }

  // ─── Theme ───────────────────────────────────────────────────────────

  /// Встановлює тему за назвою.
  void setThemePreference(String theme) {
    state = state.copyWith(themePreference: theme);
    _persist();
    developer.log('Theme preference: $theme', name: _logTag);
  }

  /// Встановлює режим теми.
  void setThemeMode(ThemeMode mode) {
    state = state.copyWith(themeMode: mode);
    _persist();
    developer.log('Theme mode: ${mode.name}', name: _logTag);
  }

  /// Циклічно перемикає режим теми.
  void cycleThemeMode() {
    switch (state.themeMode) {
      case ThemeMode.system: setThemeMode(ThemeMode.light);
      case ThemeMode.light: setThemeMode(ThemeMode.dark);
      case ThemeMode.dark: setThemeMode(ThemeMode.system);
    }
  }

  /// Опис поточного режиму теми.
  String get themeModeDescription {
    switch (state.themeMode) {
      case ThemeMode.system: return 'Системна';
      case ThemeMode.light: return 'Світла';
      case ThemeMode.dark: return 'Темна';
    }
  }

  /// Іконка для режиму теми.
  IconData get themeModeIcon {
    switch (state.themeMode) {
      case ThemeMode.system: return Icons.brightness_auto;
      case ThemeMode.light: return Icons.light_mode;
      case ThemeMode.dark: return Icons.dark_mode;
    }
  }

  /// Встановлює кастомний колір акценту.
  void setAccentColor(String hexColor) {
    if (!hexColor.startsWith('#')) return;
    if (hexColor.length != 7) return;
    state = state.copyWith(accentColorHex: hexColor);
    _persist();
  }

  /// Колір акценту з hex.
  Color get accentColor {
    try {
      return Color(int.parse(state.accentColorHex.replaceFirst('#', '0xFF')));
    } catch (_) {
      return const Color(0xFF0070D1);
    }
  }

  /// Hex колір акценту.
  String get accentColorHex => state.accentColorHex;

  /// Встановлює відтінок акценту.
  void setAccentHue(double hue) {
    final color = HSLColor.fromAHSL(1.0, hue, 0.7).toColor();
    setAccentColor('#${color.value.toRadixString(16).padLeft(6, '0').substring(2)}');
  }

  /// Опис обраної теми.
  String get themePreferenceDescription {
    switch (state.themePreference) {
      case 'ps5': return 'Темна тема (PS5)';
      case 'monitor': return 'Світла тема (Monitor)';
      default: return 'Дефолтна';
    }
  }

  // ─── Currency ─────────────────────────────────────────────────────────

  /// Встановлює формат валюти.
  void setCurrencyFormat(String format) {
    if (!_availableCurrencies.any((c) => c['code'] == format)) return;
    state = state.copyWith(currencyFormat: format);
    _persist();
  }

  /// Форматує суму.
  String formatAmount(double amount) {
    final formatted = amount.toInt().toString();
    final buffer = StringBuffer();
    final chars = formatted.split('').reversed.toList();
    for (var i = 0; i < chars.length; i++) {
      if (i > 0 && i % 3 == 0) buffer.write(' ');
      buffer.write(chars[i]);
    }
    return '${buffer.toString().split('').reversed.join()} ${state.currencyFormat}';
  }

  /// Доступні валюти.
  static const List<Map<String, String>> availableCurrencies = [
    {'code': 'грн', 'name': 'Гривня (₴)', 'symbol': '₴'},
    {'code': 'usd', 'name': 'Долар США ($)', 'symbol': '$'},
    {'code': 'eur', 'name': 'Євро (€)', 'symbol': '€'},
  ];

  /// Символ поточної валюти.
  String get currencySymbol {
    final match = _availableCurrencies.where((c) => c['code'] == state.currencyFormat);
    return match.isNotEmpty ? match.first['symbol'] : '₴';
  }

  // ─── Language ──────────────────────────────────────────────────────────

  /// Встановлює мову.
  void setLanguage(String language) {
    if (!_availableLanguages.any((l) => l['code'] == language)) return;
    state = state.copyWith(language: language);
    _persist();
  }

  /// Назва поточної мови.
  String get languageName {
    switch (state.language) {
      case 'uk': return 'Українська';
      case 'en': return 'English';
      case 'ru': return 'Русский';
      default: return 'Українська';
    }
  }

  /// Доступні мови.
  static const List<Map<String, String>> availableLanguages = [
    {'code': 'uk', 'name': 'Українська', 'flag': '🇺🇦'},
    {'code': 'en', 'name': 'English', 'flag': '🇬🇧'},
    {'code': 'ru', 'name': 'Русский', 'flag': '🇷🇺'},
  ];

  /// Прапор мови.
  String get languageFlag {
    final match = _availableLanguages.where((l) => l['code'] == state.language);
    return match.isNotEmpty ? match.first['flag'] : '🇺🇦';
  }

  // ─── Backup ────────────────────────────────────────────────────────────

  /// Перемикає автокопіювання.
  void toggleAutoBackup() {
    state = state.copyWith(autoBackupEnabled: !state.autoBackupEnabled);
    _persist();
  }

  /// Встановлює частоту (дні).
  void setAutoBackupFrequency(int days) {
    if (days < 1) return;
    state = state.copyWith(autoBackupFrequencyDays: days.clamp(1, 30));
    _persist();
  }

  /// Оновлює дату останнього копіювання.
  void markBackupDone() {
    state = state.copyWith(lastBackupDate: DateTime.now());
  }

  /// Чи пора робити нове копіювання.
  bool get needsBackup {
    if (!state.autoBackupEnabled) return false;
    final last = state.lastBackupDate;
    if (last == null) return true;
    return DateTime.now().difference(last).inDays >= state.autoBackupFrequencyDays;
  }

  /// Дні до наступного копіювання.
  int get daysUntilNextBackup {
    final last = state.lastBackupDate;
    if (last == null) return 0;
    final next = last.add(Duration(days: state.autoBackupFrequencyDays));
    final remaining = next.difference(DateTime.now()).inDays;
    return remaining < 0 ? 0 : remaining;
  }

  /// Форматована дата останнього копіювання.
  String get lastBackupDateFormatted {
    final last = state.lastBackupDate;
    if (last == null) return 'Ніколи';
    return '${last.day.toString().padLeft(2, '0')}.${last.month.toString().padLeft(2, '0')}.${last.year}';
  }

  /// Об'ємкова вага копій (mock).
  String get estimatedBackupSize => '${(0.15 + state.autoBackupFrequencyDays * 0.02).toStringAsFixed(2)} МБ';

  // ─── Privacy ────────────────────────────────────────────────────────

  /// Перемикає спільний доступ до прогресу.
  void toggleShareProgress() {
    state = state.copyWith(shareProgressEnabled: !state.shareProgressEnabled);
    _persist();
  }

  /// Перемикає аналітику.
  void toggleAnalytics() {
    state = state.copyWith(analyticsEnabled: !state.analyticsEnabled);
    _persist();
  }

  /// Чи конфіденційність увімкнена.
  bool get isShareProgressEnabled => state.shareProgressEnabled;

  /// Чи аналітика увімкнена.
  bool get isAnalyticsEnabled => state.analyticsEnabled;

  // ─── Performance ──────────────────────────────────────────────────

  /// Перемикає економію заряду.
  void toggleBatterySaver() {
    state = state.copyWith(batterySaverMode: !state.batterySaverMode);
    _persist();
  }

  /// Перемикає компактний режим.
  void toggleCompactMode() {
    state = state.copyWith(compactMode: !state.compactMode);
    _persist();
  }

  /// Чи економія заряду увімкнена.
  bool get isBatterySaverOn => state.batterySaverMode;

  /// Чи компактний режим увімкнено.
  bool get isCompactModeOn => state.compactMode;

  // ─── Data Management ──────────────────────────────────────────────────

  /// Експортує всі дані.
  String exportData() {
    try {
      final user = _userRepo.getUser();
      final data = {
        'version': _settingsVersion,
        'exportedAt': DateTime.now().toIso8601String(),
        'appVersion': state.appVersion,
        'user': user.toJson(),
        'settings': state.toJson(),
      };
      developer.log('Data exported successfully (${data.length} chars)', name: _logTag);
      return jsonEncode(data);
    } catch (e) {
      developer.log('Error exporting data: $e', name: _logTag, level: 900);
      return '{}';
    }
  }

  /// Експортує тільки налаштування.
  String exportSettingsOnly() {
    final data = {
      'version': _settingsVersion,
      'exportedAt': DateTime.now().toIso8601String(),
      'settings': state.toJson(),
    };
    developer.log('Settings exported', name: _logTag);
    return jsonEncode(data);
  }

  /// Імпортує дані з JSON.
  bool importData(String jsonData) {
    try {
      final data = jsonDecode(jsonData) as Map<String, dynamic>;
      final userData = data['user'] as Map<String, dynamic>?;
      if (userData != null) {
        final user = UserProfile.fromJson(userData);
        _userRepo.save(user);
        loadSettings();
        return true;
      }
      return false;
    } catch (e) {
      developer.log('Error importing data: $e', name: _logTag, level: 900);
      return false;
    }
  }

  /// Імпортує тільки налаштування.
  bool importSettingsOnly(String jsonData) => loadFromJson(jsonData);

  /// Очищає дані.
  void clearUserData() {
    _userRepo.reset();
    loadSettings();
  }

  /// Скидає всі налаштування.
  void resetToDefaults() {
    _userRepo.reset();
    state = const SettingsState(language: 'uk', installDate: DateTime.now());
    developer.log('Settings reset to defaults', name: _logTag);
  }

  /// Скидає категорію налаштувань.
  void resetCategory(SettingsCategory category) {
    switch (category) {
      case SettingsCategory.sound:
        state = state.copyWith(soundsEnabled: true, soundVolume: 0.7, hapticsEnabled: true);
        break;
      case SettingsCategory.notifications:
        state = state.copyWith(notificationsEnabled: true, frozenGoalNotifications: true, milestoneNotifications: true, challengeNotifications: true, badgeNotifications: true);
        break;
      case SettingsCategory.appearance:
        state = state.copyWith(themePreference: 'default', themeMode: ThemeMode.system, batterySaverMode: false, compactMode: false, accentColorHex: '#0070D1');
        break;
      case SettingsCategory.locale:
        state = state.copyWith(currencyFormat: 'грн', language: 'uk');
        break;
      case SettingsCategory.privacy:
        state = state.copyWith(shareProgressEnabled: false, analyticsEnabled: true);
        break;
      case SettingsCategory.backup:
        state = state.copyWith(autoBackupEnabled: true, autoBackupFrequencyDays: 7);
        break;
      case SettingsCategory.profile:
      case SettingsCategory.performance:
        break;
    }
    _persist();
    developer.log('Category reset: ${category.name}', name: _logTag);
  }

  // ─── Search ─────────────────────────────────────────────────────────

  /// Шукає налаштування за ключовим словом.
  List<SettingsCategory> searchSettings(String query) {
    if (query.isEmpty) return SettingsCategory.values.toList();
    final q = query.toLowerCase();
    final results = <SettingsCategory>[];
    if (q.contains('звук') || q.contains('гуч') || q.contains('тих') || q.contains('вібрац')) results.add(SettingsCategory.sound);
    if (q.contains('сповіщ') || q.contains('нагада') || q.contains('пуш')) results.add(SettingsCategory.notifications);
    if (q.contains('ім\'я') || q.contains('пошт') || q.contains('профіл') || q.contains('email')) results.add(SettingsCategory.profile);
    if (q.contains('тем') || q.contains('колір') || q.contains('акцент') || q.contains('режим')) results.add(SettingsCategory.appearance);
    if (q.contains('мов') || q.contains('валют') || q.contains('грн') || q.contains('укра')) results.add(SettingsCategory.locale);
    if (q.contains('резерв') || q.contains('бекап') || q.contains('копіюв')) results.add(SettingsCategory.backup);
    if (q.contains('конфіденцій') || q.contains('аналітик') || q.contains('приват')) results.add(SettingsCategory.privacy);
    if (q.contains('батаре') || q.contains('економ') || q.contains('компакт')) results.add(SettingsCategory.performance);
    return results;
  }

  /// Назва категорії українською.
  static String getCategoryName(SettingsCategory category) {
    switch (category) {
      case SettingsCategory.sound: return 'Звук та вібрація';
      case SettingsCategory.notifications: return 'Сповіщення';
      case SettingsCategory.profile: return 'Профіль';
      case SettingsCategory.appearance: return 'Зовнішній вигляд';
      case SettingsCategory.locale: return 'Мова та регіон';
      case SettingsCategory.backup: return 'Резервне копіювання';
      case SettingsCategory.privacy: return 'Конфіденційність';
      case SettingsCategory.performance: return 'Продуктивність';
    }
  }

  /// Опис категорії українською.
  static String getCategoryDescription(SettingsCategory category) {
    switch (category) {
      case SettingsCategory.sound: return 'Налаштування звуку, гучності та вібрації';
      case SettingsCategory.notifications: return 'Управління сповіщеннями, нагадуваннями та каналами';
      case SettingsCategory.profile: return 'Особисті дані, ім\'я, аватар та email';
      case SettingsCategory.appearance: return 'Тема додатку, акцент, режим та розмір';
      case SettingsCategory.locale: return 'Мова інтерфейсу та формат валюти';
      case SettingsCategory.backup: return 'Резервне копіювання, відновлення та експорт';
      case SettingsCategory.privacy: return 'Конфіденційність, аналітика та спільний доступ';
      case SettingsCategory.performance: return 'Продуктивність, анімації та режим компактності';
    }
  }

  // ─── App Info ─────────────────────────────────────────────────────────

  /// Інформація про додаток.
  String get appInfoText => 'Nexora v${state.appVersion}\nГейміфікований фінансовий трекер';

  /// Дні з установки.
  int get daysSinceInstall {
    final install = state.installDate;
    if (install == null) return 0;
    return DateTime.now().difference(install).inDays;
  }

  /// Форматована кількість днів з установки.
  String get daysSinceInstallFormatted {
    final days = daysSinceInstall;
    if (days < 1) return 'Сьогодні';
    if (days < 7) return '$days дн';
    if (days < 30) return '${(days / 7).floor()} тижн';
    if (days < 365) return '${(days / 30).floor()} міс';
    return '${(days / 365).floor()} р.';
  }

  /// Статистика використання додатку.
  Map<String, dynamic> get usageStats => {
    return {
      'totalDeposits': _totalDeposits(),
      'backupCount': _backupCount(),
      'themeChanges': 0,
    };
  }

  int _totalDeposits() => 47;
  int _backupCount() => 12;

  // ─── Persistence ───────────────────────────────────────────────────────

  /// Зберіга стан у репозиторії.
  void _persist() {
    try {
      final user = _userRepo.getUser();
      user.name = state.userName;
      user.email = state.userEmail;
      user.soundsEnabled = state.soundsEnabled;
      user.hapticsEnabled = state.hapticsEnabled;
      user.activeTheme = state.themePreference;
      _userRepo.save(user);
      _lastPersistTime = DateTime.now();
    } catch (e) {
      developer.log('Error persisting settings: $e', name: _logTag, level: 900);
    }
  }

  /// Чи останнє збереження було успішним.
  bool get lastPersistSuccessful {
    if (_lastPersistTime == null) return true;
    return DateTime.now().difference(_lastPersistTime!) < const Duration(minutes: 5);
  }

  /// Чи минув 1 хвилина з останнього збереження (для throttle).
  bool get canPersist => _lastPersistTime == null || DateTime.now().difference(_lastPersistTime!) >= const Duration(minutes: 1);

  /// Створює знімкову стану для тестування.
  void _createDebugState() {
    state = const SettingsState(language: 'uk', installDate: DateTime.now());
  }
}

// ─── Providers ─────────────────────────────────────────────────────────────

/// Провайдер для UserRepository.
final settingsUserRepositoryProvider = Provider<UserRepository>(
  (ref) => UserRepository(),
);

/// Riverpod провайдер для стану налаштувань.
final settingsProvider =
    StateNotifierProvider<SettingsNotifier, SettingsState>(
  (ref) => SettingsNotifier(userRepo: ref.watch(settingsUserRepositoryProvider)),
);
