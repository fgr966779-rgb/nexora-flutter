import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/xp_calculator.dart';
import '../../../core/utils/streak_calculator.dart';
import '../../../data/models/user_profile_model.dart';
import '../../../data/repositories/user_repository.dart';

/// Подія отримання XP для відображення в UI.
class XpEvent {
  /// Кількість нарахованого XP.
  final int amount;

  /// Джерело XP (наприклад, "Внесок", "Челендж").
  final String source;

  /// Час події.
  final DateTime timestamp;

  /// ID пов'язаного об'єкта (наприклад, ID транзакції).
  final String? relatedId;

  const XpEvent({
    required this.amount,
    required this.source,
    required this.timestamp,
    this.relatedId,
  });
}

/// Інформація про розблокований бейдж.
class BadgeUnlockEvent {
  /// ID бейджу.
  final String badgeId;

  /// Назва бейджу.
  final String name;

  /// Опис бейджу.
  final String description;

  /// Іконка бейджу.
  final IconData icon;

  /// Час розблокування.
  final DateTime unlockedAt;

  /// XP бонус за розблокування.
  final int xpBonus;

  const BadgeUnlockEvent({
    required this.badgeId,
    required this.name,
    required this.description,
    required this.icon,
    required this.unlockedAt,
    this.xpBonus = 10,
  });
}

/// Інформація про предмет магазину розблокувань.
class UnlockItem {
  /// ID предмета.
  final String id;

  /// Назва предмета.
  final String name;

  /// Опис предмета.
  final String description;

  /// Ціна в монетах.
  final int coinCost;

  /// Іконка предмета.
  final IconData icon;

  /// Чи обмежений (тимчасовий) предмет.
  final bool isLimited;

  /// Дата закінчення (для обмежених предметів).
  final DateTime? expiresAt;

  /// Категорія предмета.
  final UnlockCategory category;

  const UnlockItem({
    required this.id,
    required this.name,
    required this.description,
    required this.coinCost,
    required this.icon,
    this.isLimited = false,
    this.expiresAt,
    this.category = UnlockCategory.cosmetic,
  });
}

/// Категорія предмета розблокування.
enum UnlockCategory {
  /// Косметичні предмети.
  cosmetic,

  /// Бонуси XP.
  xpBonus,

  /// Рамки аватара.
  avatarFrame,

  /// Тла.
  background,

  /// Спеціальні здібності.
  ability,
}

/// Дані для таблиці лідерів (містичні дані для прикладу).
class LeaderboardEntry {
  /// Позиція в рейтингу.
  final int rank;

  /// Ім'я гравця.
  final String playerName;

  /// Рівень гравця.
  final int level;

  /// XP гравця.
  final int xp;

  /// Кількість монет.
  final int coins;

  /// Серія днів.
  final int streak;

  /// Чи це поточний користувач.
  final bool isCurrentUser;

  const LeaderboardEntry({
    required this.rank,
    required this.playerName,
    required this.level,
    required this.xp,
    required this.coins,
    required this.streak,
    this.isCurrentUser = false,
  });
}

/// Дані щоденної нагороди.
class DailyRewardData {
  /// День нагороди (1-7).
  final int day;

  /// Тип нагороди.
  final DailyRewardType type;

  /// Кількість (XP або монети).
  final int amount;

  /// Чи вже отримано.
  final bool isClaimed;

  const DailyRewardData({
    required this.day,
    required this.type,
    required this.amount,
    this.isClaimed = false,
  });
}

/// Тип щоденної нагороди.
enum DailyRewardType {
  /// Досвід.
  xp,

  /// Монети.
  coins,

  /// Бейдж.
  badge,

  /// Бонусний предмет.
  item,
}

/// Стан гейміфікації.
class GamificationState {
  /// Загальний XP користувача.
  final int xp;

  /// Кількість монет.
  final int coins;

  /// Поточний рівень (1-базований).
  final int level;

  /// Назва поточного рівня.
  final String levelName;

  /// Прогрес у межах поточного рівня (0.0 – 1.0).
  final double levelProgress;

  /// Список розблокованих бейджів.
  final List<String> unlockedBadges;

  /// Останні події XP для відображення в UI.
  final List<XpEvent> recentXpEvents;

  /// Історія XP для екрану прогресу рівнів.
  final List<XpEvent> xpHistory;

  /// Куплені предмети (ID).
  final Set<String> purchasedItems;

  /// Доступні предмети для покупки.
  final List<UnlockItem> availableUnlocks;

  /// Остання розблокована подія бейджу.
  final BadgeUnlockEvent? lastBadgeEvent;

  /// Останній день входу (для щоденного трекінгу).
  final DateTime? lastLoginDate;

  /// Бонус серії (множник XP).
  final double streakBonusMultiplier;

  /// Повідомлення про рівень (для відображення в UI).
  final String? levelUpMessage;

  /// Активний XP буст (множник).
  final double activeXpBoostMultiplier;

  /// Час закінчення XP бусту.
  final DateTime? xpBoostExpiry;

  /// Лічильник днів для щоденних нагород.
  final int dailyRewardDay;

  /// Дані щоденних нагород.
  final List<DailyRewardData> dailyRewards;

  /// Загальна кількість розблокованих бейджів за всю історію.
  final int totalBadgesEarned;

  /// Чи показувати святковий бонус.
  final bool hasHolidayBonus;

  const GamificationState({
    this.xp = 0,
    this.coins = 0,
    this.level = 0,
    this.levelName = 'Новачок',
    this.levelProgress = 0,
    this.unlockedBadges = const [],
    this.recentXpEvents = const [],
    this.xpHistory = const [],
    this.purchasedItems = const {},
    this.availableUnlocks = const [],
    this.lastBadgeEvent,
    this.lastLoginDate,
    this.streakBonusMultiplier = 1.0,
    this.levelUpMessage,
    this.activeXpBoostMultiplier = 1.0,
    this.xpBoostExpiry,
    this.dailyRewardDay = 0,
    this.dailyRewards = const [],
    this.totalBadgesEarned = 0,
    this.hasHolidayBonus = false,
  });

  GamificationState copyWith({
    int? xp,
    int? coins,
    int? level,
    String? levelName,
    double? levelProgress,
    List<String>? unlockedBadges,
    List<XpEvent>? recentXpEvents,
    List<XpEvent>? xpHistory,
    Set<String>? purchasedItems,
    List<UnlockItem>? availableUnlocks,
    BadgeUnlockEvent? lastBadgeEvent,
    DateTime? lastLoginDate,
    double? streakBonusMultiplier,
    String? levelUpMessage,
    double? activeXpBoostMultiplier,
    DateTime? xpBoostExpiry,
    bool clearXpBoostExpiry = false,
    int? dailyRewardDay,
    List<DailyRewardData>? dailyRewards,
    int? totalBadgesEarned,
    bool? hasHolidayBonus,
    bool clearBadgeEvent = false,
    bool clearLevelUpMessage = false,
  }) {
    return GamificationState(
      xp: xp ?? this.xp,
      coins: coins ?? this.coins,
      level: level ?? this.level,
      levelName: levelName ?? this.levelName,
      levelProgress: levelProgress ?? this.levelProgress,
      unlockedBadges: unlockedBadges ?? this.unlockedBadges,
      recentXpEvents: recentXpEvents ?? this.recentXpEvents,
      xpHistory: xpHistory ?? this.xpHistory,
      purchasedItems: purchasedItems ?? this.purchasedItems,
      availableUnlocks: availableUnlocks ?? this.availableUnlocks,
      lastBadgeEvent: clearBadgeEvent ? null : (lastBadgeEvent ?? this.lastBadgeEvent),
      lastLoginDate: lastLoginDate ?? this.lastLoginDate,
      streakBonusMultiplier: streakBonusMultiplier ?? this.streakBonusMultiplier,
      levelUpMessage: clearLevelUpMessage ? null : (levelUpMessage ?? this.levelUpMessage),
      activeXpBoostMultiplier: activeXpBoostMultiplier ?? this.activeXpBoostMultiplier,
      xpBoostExpiry: clearXpBoostExpiry ? null : (xpBoostExpiry ?? this.xpBoostExpiry),
      dailyRewardDay: dailyRewardDay ?? this.dailyRewardDay,
      dailyRewards: dailyRewards ?? this.dailyRewards,
      totalBadgesEarned: totalBadgesEarned ?? this.totalBadgesEarned,
      hasHolidayBonus: hasHolidayBonus ?? this.hasHolidayBonus,
    );
  }
}

/// Нотифікатор для керування станом гейміфікації.
class GamificationNotifier extends StateNotifier<GamificationState> {
  final UserRepository _userRepo;

  GamificationNotifier({
    required UserRepository userRepo,
  })  : _userRepo = userRepo,
        super(const GamificationState());

  // ─── Визначення всіх бейджів ──────────────────────────────

  /// Повна специфікація всіх 10 бейджів.
  static const List<Map<String, dynamic>> allBadges = [
    {
      'id': 'first_deposit',
      'name': 'Перший внесок',
      'description': 'Здійсни свій перший внесок до цілі',
      'icon': Icons.star,
      'xp_bonus': 10,
    },
    {
      'id': 'weekly_streak',
      'name': 'Тижнева серія',
      'description': 'Зроби внесок 7 днів поспіль',
      'icon': Icons.local_fire_department,
      'xp_bonus': 25,
    },
    {
      'id': 'monthly_marathon',
      'name': 'Місячний марафон',
      'description': 'Зроби внесок 30 днів поспіль',
      'icon': Icons.emoji_events,
      'xp_bonus': 50,
    },
    {
      'id': 'challenge_winner',
      'name': 'Переможець виклику',
      'description': 'Заверш будь-який челендж',
      'icon': Icons.military_tech,
      'xp_bonus': 20,
    },
    {
      'id': 'double_level',
      'name': 'Подвійний рівень',
      'description': 'Досягни 3-го рівня',
      'icon': Icons.trending_up,
      'xp_bonus': 30,
    },
    {
      'id': 'generous_saver',
      'name': 'Щедрий заощадник',
      'description': 'Накопич 50 000 ₴ загалом',
      'icon': Icons.savings,
      'xp_bonus': 40,
    },
    {
      'id': 'early_bird',
      'name': 'Рання пташка',
      'description': 'Зроби внесок до 8:00 ранку',
      'icon': Icons.wb_sunny,
      'xp_bonus': 15,
    },
    {
      'id': 'night_owl',
      'name': 'Нічна сова',
      'description': 'Зроби внесок після 23:00',
      'icon': Icons.nightlight,
      'xp_bonus': 15,
    },
    {
      'id': 'big_splash',
      'name': 'Великий внесок',
      'description': 'Зроби внесок від 5000 ₴ за раз',
      'icon': Icons.water_drop,
      'xp_bonus': 20,
    },
    {
      'id': 'goal_crusher',
      'name': 'Руйнівник цілей',
      'description': 'Досягни своєї головної цілі',
      'icon': Icons.verified,
      'xp_bonus': 100,
    },
  ];

  // ─── Визначення предметів магазину ────────────────────────

  /// Доступні предмети для покупки.
  static const List<UnlockItem> shopItems = [
    UnlockItem(
      id: 'theme_neon',
      name: 'Неонова тема',
      description: 'Яскраве неонове оформлення дашборду',
      coinCost: 500,
      icon: Icons.palette,
      category: UnlockCategory.cosmetic,
    ),
    UnlockItem(
      id: 'theme_minimal',
      name: 'Мінімалістична тема',
      description: 'Чистий та простий дизайн',
      coinCost: 300,
      icon: Icons.auto_awesome_mosaic,
      category: UnlockCategory.cosmetic,
    ),
    UnlockItem(
      id: 'avatar_frame_gold',
      name: 'Золота рамка аватара',
      description: 'Розкішна золота рамка навколо аватара',
      coinCost: 1000,
      icon: Icons.account_circle,
      category: UnlockCategory.avatarFrame,
    ),
    UnlockItem(
      id: 'avatar_frame_diamond',
      name: 'Діамантова рамка аватара',
      description: 'Ексклюзивна діамантова рамка',
      coinCost: 2500,
      icon: Icons.diamond,
      category: UnlockCategory.avatarFrame,
    ),
    UnlockItem(
      id: 'custom_background',
      name: 'Власне тло',
      description: 'Встановити власне зображення на фон',
      coinCost: 800,
      icon: Icons.image,
      category: UnlockCategory.background,
    ),
    UnlockItem(
      id: 'xp_boost_24h',
      name: 'XP буст ×2 (24 години)',
      description: 'Подвоєний XP на 24 години',
      coinCost: 400,
      icon: Icons.bolt,
      category: UnlockCategory.xpBonus,
    ),
    UnlockItem(
      id: 'streak_shield',
      name: 'Щит серії',
      description: 'Зберігає серію на 1 день пропуску',
      coinCost: 600,
      icon: Icons.shield,
      category: UnlockCategory.ability,
    ),
  ];

  /// Дані щоденних нагород (7 днів).
  static const List<DailyRewardData> _defaultDailyRewards = [
    DailyRewardData(day: 1, type: DailyRewardType.coins, amount: 5),
    DailyRewardData(day: 2, type: DailyRewardType.xp, amount: 10),
    DailyRewardData(day: 3, type: DailyRewardType.coins, amount: 10),
    DailyRewardData(day: 4, type: DailyRewardType.xp, amount: 25),
    DailyRewardData(day: 5, type: DailyRewardType.coins, amount: 25),
    DailyRewardData(day: 6, type: DailyRewardType.xp, amount: 50),
    DailyRewardData(day: 7, type: DailyRewardType.badge, amount: 100),
  ];

  // ─── Завантаження стану ───────────────────────────────────

  /// Завантажує стан гейміфікації з репозиторію.
  void load() {
    final user = _userRepo.getUser();

    final levelData = XPCalculator.checkLevelUp(user.xp);
    final level = levelData?['newLevel'] as int? ?? user.currentLevel;
    final name = XPCalculator.getLevelName(level);
    final nextXp = XPCalculator.getXpForNextLevel(level);

    double progress = 0;
    if (nextXp != null) {
      final lowerBound = _getLevelLowerBound(level);
      final range = nextXp - lowerBound;
      progress = range > 0
          ? ((user.xp - lowerBound) / range).clamp(0.0, 1.0)
          : 1.0;
    } else {
      progress = 1.0; // Максимальний рівень.
    }

    final bonusMultiplier = _calculateStreakBonus(user.currentStreak);

    state = GamificationState(
      xp: user.xp,
      coins: user.coins,
      level: level,
      levelName: name,
      levelProgress: progress,
      unlockedBadges: List.unmodifiable(user.unlockedBadges),
      purchasedItems: Set.unmodifiable(user.purchasedUnlocks.toSet()),
      availableUnlocks: shopItems,
      lastLoginDate: user.lastActiveDate,
      streakBonusMultiplier: bonusMultiplier,
      dailyRewards: _defaultDailyRewards,
    );
  }

  // ─── XP та рівні ──────────────────────────────────────────

  /// Додає XP користувачу та оновлює стан.
  ///
  /// Повертає `true`, якщо відбувся перехід на новий рівень.
  bool addXp(int amount, String source, {String? relatedId}) {
    final user = _userRepo.getUser();
    final oldLevel = user.currentLevel;

    // Застосовуємо бонусні множники
    final effectiveAmount = _calculateEffectiveXp(amount);

    final leveledUp = user.addXp(effectiveAmount);
    user.lastActiveDate = DateTime.now();
    _userRepo.save(user);

    // Додаємо подію XP.
    final event = XpEvent(
      amount: effectiveAmount,
      source: source,
      timestamp: DateTime.now(),
      relatedId: relatedId,
    );
    final updatedEvents = [event, ...state.recentXpEvents];
    final trimmedEvents = updatedEvents.length > 20
        ? updatedEvents.sublist(0, 20)
        : updatedEvents;

    // Додаємо до історії XP.
    final updatedHistory = [...state.xpHistory, event];
    final trimmedHistory = updatedHistory.length > 100
        ? updatedHistory.sublist(updatedHistory.length - 100)
        : updatedHistory;

    load(); // Перезавантажуємо стан.

    String? levelUpMsg;
    if (leveledUp) {
      final newLevel = user.currentLevel;
      final newName = XPCalculator.getLevelName(newLevel);
      levelUpMsg = '🎉 Рівень $newLevel: $newName! Вітаємо!';
    }

    state = state.copyWith(
      recentXpEvents: trimmedEvents,
      xpHistory: trimmedHistory,
      levelUpMessage: levelUpMsg,
    );

    return leveledUp;
  }

  /// Обчислює ефективний XP з урахуванням бонусів.
  int _calculateEffectiveXp(int baseXp) {
    double multiplier = 1.0;

    // Бонус серії
    multiplier *= state.streakBonusMultiplier;

    // XP буст
    if (_isXpBoostActive()) {
      multiplier *= state.activeXpBoostMultiplier;
    }

    // Святковий бонус
    if (state.hasHolidayBonus) {
      multiplier *= 1.25;
    }

    return (baseXp * multiplier).round();
  }

  /// Чи активний XP буст.
  bool _isXpBoostActive() {
    if (state.xpBoostExpiry == null) return false;
    return DateTime.now().isBefore(state.xpBoostExpiry!);
  }

  /// Активує XP буст на вказаний період.
  void activateXpBoost({Duration duration = const Duration(hours: 24), double multiplier = 2.0}) {
    state = state.copyWith(
      activeXpBoostMultiplier: multiplier,
      xpBoostExpiry: DateTime.now().add(duration),
    );
  }

  /// Повертає нижню межу XP для заданого рівня.
  int _getLevelLowerBound(int level) {
    const thresholds = [0, 100, 300, 700, 1500, 3000, 6000, 12000, 25000];
    final index = (level - 1).clamp(0, thresholds.length - 1);
    return thresholds[index];
  }

  /// Повертає номер поточного рівня.
  int get levelNumber => state.level;

  /// Повертає назву поточного рівня.
  String get levelName => state.levelName;

  /// Повертає прогрес поточного рівня.
  double get levelProgress => state.levelProgress;

  /// Повертає XP, необхідний для наступного рівня (або null, якщо максимальний).
  int? get nextLevelXp {
    return XPCalculator.getXpForNextLevel(state.level);
  }

  /// Повертає XP для поточного рівня (нижня межа).
  int get currentLevelXp {
    return _getLevelLowerBound(state.level);
  }

  /// Повертає XP, отриманий на поточному рівні.
  int get xpOnCurrentLevel {
    return state.xp - currentLevelXp;
  }

  /// Повертає XP, необхідний для завершення поточного рівня.
  int get xpToNextLevel {
    final next = nextLevelXp;
    if (next == null) return 0;
    return next - state.xp;
  }

  /// Повертає назву наступного рівня (або null).
  String? get nextLevelName {
    final nextXp = XPCalculator.getXpForNextLevel(state.level);
    if (nextXp == null) return null;
    final nextLevel = state.level + 1;
    if (nextLevel > 9) return null;
    return XPCalculator.getLevelName(nextLevel);
  }

  /// Чи досягнуто максимального рівня.
  bool get isMaxLevel => state.level >= 9;

  /// Повертає форматований рядок прогресу рівня.
  String get formattedLevelProgress {
    return '${(state.levelProgress * 100).toStringAsFixed(1)}%';
  }

  // ─── Монети ───────────────────────────────────────────────

  /// Витрачає монети. Повертає `true`, якщо операція успішна.
  bool spendCoins(int amount) {
    final user = _userRepo.getUser();
    final success = user.spendCoins(amount);
    if (success) {
      _userRepo.save(user);
      load();
    }
    return success;
  }

  /// Додає монети.
  void addCoins(int amount) {
    final user = _userRepo.getUser();
    user.addCoins(amount);
    _userRepo.save(user);
    load();
  }

  /// Повертає форматований баланс монет.
  String get formattedCoins => '${state.coins} 🪙';

  /// Повертає, чи користувач може дозволити собі покупку.
  bool canAfford(int coinCost) => state.coins >= coinCost;

  // ─── Бейджі ───────────────────────────────────────────────

  /// Перевіряє та нараховує бейджі за різні досягнення.
  ///
  /// Приймає карту умов, де ключ — ID бейджу, значення — `true`, якщо умова виконана.
  /// Повертає список ID нових розблокованих бейджів.
  List<String> checkAndAwardBadges(Map<String, bool> conditions) {
    final user = _userRepo.getUser();
    final newlyUnlocked = <String>[];

    for (final entry in conditions.entries) {
      if (!entry.value) continue;
      if (user.hasBadge(entry.key)) continue;

      final badgeInfo = allBadges.firstWhere(
        (b) => b['id'] == entry.key,
        orElse: () => {},
      );
      if (badgeInfo.isEmpty) continue;

      final didUnlock = user.unlockBadge(entry.key);
      if (didUnlock) {
        newlyUnlocked.add(entry.key);

        final xpBonus = badgeInfo['xp_bonus'] as int? ?? 10;

        // Створюємо подію розблокування.
        final event = BadgeUnlockEvent(
          badgeId: entry.key,
          name: badgeInfo['name'] as String,
          description: badgeInfo['description'] as String,
          icon: badgeInfo['icon'] as IconData,
          unlockedAt: DateTime.now(),
          xpBonus: xpBonus,
        );

        state = state.copyWith(lastBadgeEvent: event);

        // Нараховуємо бонусні монети та XP за бейдж.
        user.addCoins(10);
        user.addXp(xpBonus);
      }
    }

    if (newlyUnlocked.isNotEmpty) {
      _userRepo.save(user);
      load();
    }

    return newlyUnlocked;
  }

  /// Повертає інформацію про бейдж за ID.
  Map<String, dynamic>? getBadgeInfo(String badgeId) {
    try {
      return allBadges.firstWhere((b) => b['id'] == badgeId);
    } catch (_) {
      return null;
    }
  }

  /// Повертає всі бейджі з інформацією про їх розблокування.
  List<Map<String, dynamic>> getAllBadgesWithStatus() {
    return allBadges.map((badge) {
      return {
        ...badge,
        'isUnlocked': state.unlockedBadges.contains(badge['id']),
      };
    }).toList();
  }

  /// Повертає кількість розблокованих бейджів.
  int get unlockedBadgeCount => state.unlockedBadges.length;

  /// Повертає загальну кількість бейджів.
  int get totalBadgeCount => allBadges.length;

  /// Очищає подію розблокування бейджу (після обробки в UI).
  void clearBadgeEvent() {
    state = state.copyWith(clearBadgeEvent: true);
  }

  // ─── Магазин розблокувань ─────────────────────────────────

  /// Повертає список доступних предметів (що ще не куплені).
  List<UnlockItem> get availableUnlocks {
    return shopItems
        .where((item) => !state.purchasedItems.contains(item.id))
        .toList();
  }

  /// Повертає список куплених предметів.
  List<UnlockItem> get purchasedUnlocks {
    return shopItems
        .where((item) => state.purchasedItems.contains(item.id))
        .toList();
  }

  /// Повертає предмети за категорією.
  List<UnlockItem> getItemsByCategory(UnlockCategory category) {
    return shopItems.where((item) => item.category == category).toList();
  }

  /// Купує предмет із магазину.
  ///
  /// Повертає `true`, якщо покупка успішна.
  bool purchaseUnlock(String itemId) {
    final item = shopItems.firstWhere(
      (i) => i.id == itemId,
      orElse: () => const UnlockItem(
        id: '',
        name: '',
        description: '',
        coinCost: 0,
        icon: Icons.help_outline,
      ),
    );

    if (item.id.isEmpty) return false;
    if (state.purchasedItems.contains(itemId)) return false;
    if (state.coins < item.coinCost) return false;

    final user = _userRepo.getUser();
    if (!user.spendCoins(item.coinCost)) return false;

    final updatedPurchases = {...user.purchasedUnlocks, itemId};
    user.purchasedUnlocks = updatedPurchases.toList();
    _userRepo.save(user);
    load();

    return true;
  }

  // ─── Щоденний вхід ────────────────────────────────────────

  /// Обробляє щоденний вхід користувача.
  ///
  /// Нараховує бонусний XP за щоденний вхід.
  /// Повертає кількість нарахованого XP.
  int handleDailyLogin() {
    final user = _userRepo.getUser();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Перевіряємо, чи вже був вхід сьогодні.
    if (user.lastActiveDate != null) {
      final lastLogin = DateTime(
        user.lastActiveDate!.year,
        user.lastActiveDate!.month,
        user.lastActiveDate!.day,
      );

      if (lastLogin.isAtSameMomentAs(today)) {
        return 0; // Вже входили сьогодні.
      }
    }

    // Нараховуємо XP за щоденний вхід.
    final dailyXp = XPCalculator.calculateXp(TransactionType.dailyLogin);
    addXp(dailyXp, 'Щоденний вхід');

    return dailyXp;
  }

  // ─── Щоденні нагороди ──────────────────────────────────────

  /// Повертає поточну щоденну нагороду.
  DailyRewardData? get currentDailyReward {
    final day = state.dailyRewardDay;
    if (day >= state.dailyRewards.length) return null;
    return state.dailyRewards[day];
  }

  /// Отримує щоденну нагороду.
  ///
  /// Повертає `true`, якщо нагороду успішно отримано.
  bool claimDailyReward() {
    final day = state.dailyRewardDay;
    if (day >= state.dailyRewards.length) return false;

    final reward = state.dailyRewards[day];
    if (reward.isClaimed) return false;

    // Нараховуємо нагороду
    switch (reward.type) {
      case DailyRewardType.xp:
        addXp(reward.amount, 'Щоденна нагорода');
        break;
      case DailyRewardType.coins:
        addCoins(reward.amount);
        break;
      case DailyRewardType.badge:
        // Бейдж нагорода на 7-й день
        checkAndAwardBadges({'daily_streak_7': true});
        break;
      case DailyRewardType.item:
        // Предмет нагорода
        break;
    }

    // Оновлюємо день
    final updatedRewards = List<DailyRewardData>.from(state.dailyRewards);
    updatedRewards[day] = DailyRewardData(
      day: reward.day,
      type: reward.type,
      amount: reward.amount,
      isClaimed: true,
    );

    final nextDay = day + 1;
    state = state.copyWith(
      dailyRewardDay: nextDay,
      dailyRewards: updatedRewards,
    );

    return true;
  }

  /// Скидає щоденні нагороди (новий тиждень).
  void resetDailyRewards() {
    state = state.copyWith(
      dailyRewardDay: 0,
      dailyRewards: _defaultDailyRewards,
    );
  }

  // ─── Серія (streak) ───────────────────────────────────────

  /// Обчислює бонус множник XP на основі серії.
  double _calculateStreakBonus(int streakDays) {
    if (streakDays >= 30) return 2.0;
    if (streakDays >= 14) return 1.75;
    if (streakDays >= 7) return 1.5;
    if (streakDays >= 3) return 1.25;
    return 1.0;
  }

  /// Повертає опис бонусу серії.
  String get streakBonusDescription {
    final multiplier = state.streakBonusMultiplier;
    if (multiplier >= 2.0) return '🔥 XP ×2.0 — Місячний марафон!';
    if (multiplier >= 1.75) return '⚡ XP ×1.75 — Двотижнева серія!';
    if (multiplier >= 1.5) return '💪 XP ×1.5 — Тижнева серія!';
    if (multiplier >= 1.25) return '✨ XP ×1.25 — 3-денна серія!';
    return '➡️ XP ×1.0 — Зроби внесок для бонусу!';
  }

  /// Обчислює серію днів до наступного бонусу.
  int get daysToNextStreakBonus {
    if (state.streakBonusMultiplier >= 2.0) return 0;
    if (state.streakBonusMultiplier >= 1.75) return 30 - 14; // до 30
    if (state.streakBonusMultiplier >= 1.5) return 14 - 7; // до 14
    if (state.streakBonusMultiplier >= 1.25) return 7 - 3; // до 7
    return 3; // до 3
  }

  // ─── Лідери (імітація) ────────────────────────────────────

  /// Повертає таблицю лідерів (імітація).
  List<LeaderboardEntry> get leaderboard {
    final user = _userRepo.getUser();
    return [
      LeaderboardEntry(rank: 1, playerName: 'Олександр К.', level: 8, xp: 18500, coins: 3200, streak: 45),
      LeaderboardEntry(rank: 2, playerName: 'Марія П.', level: 7, xp: 15200, coins: 2800, streak: 38),
      LeaderboardEntry(rank: 3, playerName: 'Дмитро Л.', level: 7, xp: 14100, coins: 2500, streak: 30),
      LeaderboardEntry(rank: 4, playerName: 'Анна С.', level: 6, xp: 11200, coins: 1900, streak: 22),
      LeaderboardEntry(rank: 5, playerName: 'Віктор Т.', level: 5, xp: 8500, coins: 1500, streak: 18),
      LeaderboardEntry(rank: 6, playerName: user.name, level: user.currentLevel, xp: user.xp, coins: user.coins, streak: user.currentStreak, isCurrentUser: true),
      LeaderboardEntry(rank: 7, playerName: 'Юлія М.', level: 4, xp: 5200, coins: 900, streak: 12),
      LeaderboardEntry(rank: 8, playerName: 'Тарас Б.', level: 4, xp: 4800, coins: 850, streak: 10),
      LeaderboardEntry(rank: 9, playerName: 'Олена В.', level: 3, xp: 3100, coins: 600, streak: 7),
      LeaderboardEntry(rank: 10, playerName: 'Ігор Н.', level: 3, xp: 2800, coins: 500, streak: 5),
    ];
  }

  /// Повертає позицію користувача в таблиці лідерів.
  int get userLeaderboardRank {
    final entry = leaderboard.where((e) => e.isCurrentUser).firstOrNull;
    return entry?.rank ?? leaderboard.length;
  }

  // ─── Мотиваційні повідомлення ─────────────────────────────

  /// Повертає мотивуюче повідомлення українською на основі рівня та XP.
  String getMotivationalMessage() {
    final level = state.level;
    final progress = state.levelProgress;

    if (isMaxLevel) {
      return '🏆 Ти досяг максимального рівня — Скарбничний бос! Ти справжній майстер заощаджень!';
    }

    if (progress >= 0.9) {
      return '🔥 Майже на новому рівні! Трохи зусиль — і ти там!';
    }

    if (progress >= 0.5) {
      return '💪 Ти на половині шляху до наступного рівня. Не здавайся!';
    }

    switch (level) {
      case 0:
        return '🌱 Почни свій шлях заощадника вже сьогодні!';
      case 1:
        return '⭐ Гарне начало! Продовжуй accumuлювати XP.';
      case 2:
        return '🎯 Ти справжній скарбничкар! Збираєш монети вірно.';
      case 3:
        return '📊 Колекціонер — твої результати вражають!';
      case 4:
        return '🚀 Майстер накопичень! Ти наближаєшся до вершини!';
      case 5:
        return '💎 Золотий заощадник — твої навички на висоті!';
      case 6:
        return '🌟 Легенда економії! Лише найкращі досягають цього рівня.';
      case 7:
        return '👑 Неперевершений! Ти майже на вершині!';
      default:
        return '💪 Кожен внесок наближає тебе до нових вершин!';
    }
  }

  /// Повертає мотивуюче повідомлення на основі XP.
  String getMotivationalMessageForXp(int xpAmount) {
    if (xpAmount >= 100) return '🔥 Велетенський бонус XP!';
    if (xpAmount >= 50) return '⚡ Чудовий XP!';
    if (xpAmount >= 25) return '✨ Добре зароблено!';
    if (xpAmount >= 10) return '👍 Непогано!';
    return '🎯 Крок за кроком!';
  }

  // ─── Обробка гейміфікаційних подій ─────────────────────────

  /// Обробляє подію внеску для гейміфікації.
  ///
  /// Перевіряє умови бейджів, нараховує XP.
  void handleDepositEvent({
    required double amount,
    required bool isFirstDeposit,
    required int streakDays,
    required DateTime depositTime,
  }) {
    final conditions = <String, bool>{};

    // Перший внесок
    if (isFirstDeposit) {
      conditions['first_deposit'] = true;
    }

    // Серія 7 днів
    if (streakDays >= 7) {
      conditions['weekly_streak'] = true;
    }

    // Серія 30 днів
    if (streakDays >= 30) {
      conditions['monthly_marathon'] = true;
    }

    // Ранній пташка (до 8:00)
    if (depositTime.hour < 8) {
      conditions['early_bird'] = true;
    }

    // Нічна сова (після 23:00)
    if (depositTime.hour >= 23) {
      conditions['night_owl'] = true;
    }

    // Великий внесок
    if (amount >= 5000) {
      conditions['big_splash'] = true;
    }

    // Перевіряємо бейджі
    checkAndAwardBadges(conditions);
  }

  /// Обробляє подію завершення челенджу.
  void handleChallengeCompleted() {
    checkAndAwardBadges({'challenge_winner': true});
  }

  /// Обробляє подію досягнення цілі.
  void handleGoalReached() {
    checkAndAwardBadges({'goal_crusher': true});
  }

  /// Обробляє подію підвищення рівня.
  void handleLevelUp(int newLevel) {
    if (newLevel >= 3) {
      checkAndAwardBadges({'double_level': true});
    }
  }

  // ─── Очищення повідомлень ─────────────────────────────────

  /// Очищає повідомлення про перехід рівня.
  void clearLevelUpMessage() {
    state = state.copyWith(clearLevelUpMessage: true);
  }
}

// ─── Провайдери ─────────────────────────────────────────────────────

/// Провайдер для UserRepository (пере використовує з dashboard_provider).
final gamificationUserRepositoryProvider = Provider<UserRepository>(
  (ref) => UserRepository(),
);

/// Riverpod провайдер для стану гейміфікації.
final gamificationProvider =
    StateNotifierProvider<GamificationNotifier, GamificationState>(
  (ref) => GamificationNotifier(
    userRepo: ref.watch(gamificationUserRepositoryProvider),
  ),
);
