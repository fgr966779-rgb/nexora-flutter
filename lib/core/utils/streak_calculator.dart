import 'dart:collection';

import 'package:flutter/material.dart';

/// Запис про історію серії для відстеження минулих досягнень.
class StreakHistoryEntry {
  /// Дата початку серії.
  final DateTime startDate;

  /// Дата закінчення серії.
  final DateTime endDate;

  /// Тривалість серії в днях.
  final int days;

  /// Причина завершення (пропуск дня або заморожування).
  final String endReason;

  const StreakHistoryEntry({
    required this.startDate,
    required this.endDate,
    required this.days,
    required this.endReason,
  });

  Map<String, dynamic> toMap() => {
        'startDate': startDate.toIso8601String(),
        'endDate': endDate.toIso8601String(),
        'days': days,
        'endReason': endReason,
      };

  factory StreakHistoryEntry.fromMap(Map<String, dynamic> map) =>
      StreakHistoryEntry(
        startDate: DateTime.parse(map['startDate'] as String),
        endDate: DateTime.parse(map['endDate'] as String),
        days: map['days'] as int,
        endReason: map['endReason'] as String,
      );
}

/// Етап серії з нагородами.
class StreakMilestone {
  final int days;
  final int xpReward;
  final int coinReward;
  final String badgeName;
  final String description;

  const StreakMilestone({
    required this.days,
    required this.xpReward,
    required this.coinReward,
    required this.badgeName,
    required this.description,
  });
}

/// Рівень ризику для серії поповнень.
enum StreakRiskLevel {
  /// Безпечно — серія активна і надійна.
  safe,
  /// Попередження — серія може бути під загрозою.
  warning,
  /// Критично — сьогодні ще не було поповнення.
  critical,
  /// Розірвано — серія перервана.
  broken,
}

/// Результат розрахунку серії.
class StreakResult {
  final int currentStreak;
  final int longestStreak;
  final int weeklyStreak;
  final int monthlyStreak;
  final bool isFrozen;
  final int freezeCount;
  final StreakRiskLevel riskLevel;
  final int daysUntilBreak;

  const StreakResult({
    required this.currentStreak,
    required this.longestStreak,
    required this.weeklyStreak,
    required this.monthlyStreak,
    required this.isFrozen,
    required this.freezeCount,
    required this.riskLevel,
    required this.daysUntilBreak,
  });
}

/// Дані для візуалізації історії серій (тижнева карта).
class StreakWeekData {
  /// Початок тижня.
  final DateTime weekStart;

  /// Кількість днів у тижні, коли було поповнення.
  final int activeDays;

  /// Чи всі 7 днів були активні.
  final bool isPerfectWeek;

  const StreakWeekData({
    required this.weekStart,
    required this.activeDays,
    required this.isPerfectWeek,
  });
}

/// Дані для візуалізації місячної серії.
class StreakMonthData {
  /// Рік і місяць.
  final DateTime monthStart;

  /// Загальна кількість днів з поповненням.
  final int activeDays;

  /// Загальна кількість днів у місяці.
  final int totalDays;

  /// Відсоток активних днів.
  double get coverage => totalDays > 0 ? activeDays / totalDays : 0.0;

  const StreakMonthData({
    required this.monthStart,
    required this.activeDays,
    required this.totalDays,
  });
}

/// Результат прогнозу серії.
class StreakPrediction {
  /// Ймовірність збереження серії завтра (0.0–1.0).
  final double retentionProbability;

  /// Очікувана довжина серії в днях.
  final int expectedLength;

  /// Порада для користувача.
  final String advice;

  const StreakPrediction({
    required this.retentionProbability,
    required this.expectedLength,
    required this.advice,
  });
}

/// Калькулятор серій поповнень.
///
/// Відстежує поточну та найбільшу серії днів поспіль, протягом яких
/// користувач робив хоча б одне поповнення. Також підтримує
/// тижневі/місячні серії, ризик-оцінку, заморожування та історію.
class StreakCalculator {
  // ── Етапи ────────────────────────────────────────────────────

  /// Повні етапи серії з нагородами.
  static const List<StreakMilestone> milestones = [
    StreakMilestone(
      days: 3,
      xpReward: 15,
      coinReward: 5,
      badgeName: 'Стійкий початок',
      description: '3 дні поспіль — ти на правильному шляху!',
    ),
    StreakMilestone(
      days: 7,
      xpReward: 50,
      coinReward: 15,
      badgeName: 'Тижнева серія',
      description: '7 днів — ти справжній скарбничкар!',
    ),
    StreakMilestone(
      days: 14,
      xpReward: 80,
      coinReward: 25,
      badgeName: 'Двотижневий марафон',
      description: '14 днів — звичка формується!',
    ),
    StreakMilestone(
      days: 21,
      xpReward: 120,
      coinReward: 35,
      badgeName: 'Три тижні стійкості',
      description: '21 день — накопичення стало звичкою!',
    ),
    StreakMilestone(
      days: 30,
      xpReward: 200,
      coinReward: 50,
      badgeName: 'Місячний марафон',
      description: '30 днів — ти легенда дисципліни!',
    ),
    StreakMilestone(
      days: 60,
      xpReward: 350,
      coinReward: 80,
      badgeName: 'Двомісячний воїн',
      description: '60 днів — неймовірна стійкість!',
    ),
    StreakMilestone(
      days: 90,
      xpReward: 500,
      coinReward: 120,
      badgeName: 'Квартал золотого накопичення',
      description: '90 днів — ти надихаєш інших!',
    ),
    StreakMilestone(
      days: 180,
      xpReward: 800,
      coinReward: 200,
      badgeName: 'Півроку витривалості',
      description: '180 днів — фінансова дисципліна на максимумі!',
    ),
    StreakMilestone(
      days: 365,
      xpReward: 1500,
      coinReward: 500,
      badgeName: 'Річний чемпіон',
      description: '365 днів — рік фінансової дисципліни!',
    ),
  ];

  // ── Базові розрахунки ──────────────────────────────────────────────

  /// Оновлює серію на основі [lastDepositDate] та поточної дати.
  /// Враховує [isHolidayModeActive] — якщо режим активовано, серія не обнуляється.
  static Map<String, int> updateStreak({
    DateTime? lastDepositDate,
    int currentStreak = 0,
    int longestStreak = 0,
    bool isHolidayModeActive = false,
  }) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    if (lastDepositDate == null) {
      return {'current': 0, 'longest': longestStreak};
    }

    final lastDepositDay = DateTime(
      lastDepositDate.year,
      lastDepositDate.month,
      lastDepositDate.day,
    );

    final daysDiff = today.difference(lastDepositDay).inDays;

    if (daysDiff == 0) {
      // Поповнення було сьогодні.
    } else if (daysDiff == 1) {
      currentStreak += 1;
    } else {
      // Якщо режим відпустки активний, серія не обривається, а "заморожується".
      if (!isHolidayModeActive) {
        currentStreak = 0;
      }
    }

    if (currentStreak > longestStreak) {
      longestStreak = currentStreak;
    }

    return {'current': currentStreak, 'longest': longestStreak};
  }

  /// Повний розрахунок серії з усіма метриками.
  static StreakResult calculateFullStreak({
    DateTime? lastDepositDate,
    int currentStreak = 0,
    int longestStreak = 0,
    bool isFrozen = false,
    int freezeCount = 0,
    required List<DateTime> depositDates,
  }) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Тижнева серія
    final weekStart = today.subtract(Duration(days: today.weekday - 1));
    final weeklyStreak = depositDates
        .where((d) {
          final day = DateTime(d.year, d.month, d.day);
          return !day.isBefore(weekStart) && !day.isAfter(today);
        })
        .map((d) => DateTime(d.year, d.month, d.day))
        .toSet()
        .length;

    // Місячна серія
    final monthStart = DateTime(today.year, today.month, 1);
    final monthlyStreak = depositDates
        .where((d) {
          final day = DateTime(d.year, d.month, d.day);
          return !day.isBefore(monthStart) && !day.isAfter(today);
        })
        .map((d) => DateTime(d.year, d.month, d.day))
        .toSet()
        .length;

    // Ризик-оцінка
    final riskLevel = _assessRisk(
      lastDepositDate: lastDepositDate,
      currentStreak: currentStreak,
      isFrozen: isFrozen,
    );

    // Днів до розриву
    int daysUntilBreak = 0;
    if (lastDepositDate != null && currentStreak > 0 && !isFrozen) {
      final lastDay = DateTime(
        lastDepositDate.year,
        lastDepositDate.month,
        lastDepositDate.day,
      );
      daysUntilBreak = 1 - today.difference(lastDay).inDays;
      if (daysUntilBreak < 0) daysUntilBreak = 0;
    }

    return StreakResult(
      currentStreak: currentStreak,
      longestStreak: longestStreak,
      weeklyStreak: weeklyStreak,
      monthlyStreak: monthlyStreak,
      isFrozen: isFrozen,
      freezeCount: freezeCount,
      riskLevel: riskLevel,
      daysUntilBreak: daysUntilBreak,
    );
  }

  // ── Оцінка ризику ────────────────────────────────────────────────

  static StreakRiskLevel _assessRisk({
    DateTime? lastDepositDate,
    required int currentStreak,
    required bool isFrozen,
    bool isHolidayModeActive = false,
  }) {
    if (isFrozen || isHolidayModeActive) return StreakRiskLevel.safe;
    if (currentStreak == 0) return StreakRiskLevel.broken;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    if (lastDepositDate == null) return StreakRiskLevel.critical;

    final lastDay = DateTime(
      lastDepositDate.year,
      lastDepositDate.month,
      lastDepositDate.day,
    );
    final daysDiff = today.difference(lastDay).inDays;

    if (daysDiff == 0) return StreakRiskLevel.safe;
    if (daysDiff == 1) return StreakRiskLevel.warning;
    return StreakRiskLevel.critical;
  }

  // ── Етапи ─────────────────────────────────────────────────────────

  /// Перевіряє, чи досягнуто новий етап серії.
  static List<String> checkStreakMilestones(int streakDays) {
    final List<String> badgeIds = [];

    if (streakDays >= 7) badgeIds.add('weeklyStreak');
    if (streakDays >= 30) badgeIds.add('monthlyMarathon');
    if (streakDays >= 90) badgeIds.add('quarterChampion');
    if (streakDays >= 365) badgeIds.add('yearlyChampion');

    return badgeIds;
  }

  /// Повертає нові досягнуті етапи порівняно з [previousStreak].
  static List<StreakMilestone> getNewMilestones(
    int currentStreak,
    int previousStreak,
  ) {
    return milestones
        .where((m) => currentStreak >= m.days && previousStreak < m.days)
        .toList();
  }

  /// Повертає наступний етап для досягнення.
  static StreakMilestone? getNextMilestone(int currentStreak) {
    for (final milestone in milestones) {
      if (currentStreak < milestone.days) return milestone;
    }
    return null;
  }

  /// Повертає кількість днів до наступного етапу.
  static int? daysToNextMilestone(int currentStreak) {
    final next = getNextMilestone(currentStreak);
    if (next == null) return null;
    return next.days - currentStreak;
  }

  // ── Заморожування ──────────────────────────────────────────────────

  /// Чи можна заморозити серію.
  static bool canFreeze({
    required int currentStreak,
    required int freezeCount,
    required bool depositedToday,
  }) {
    return currentStreak > 0 && freezeCount > 0 && !depositedToday;
  }

  /// Обчислює максимальну кількість заморожувань за серією.
  static int maxFreezesForStreak(int currentStreak) {
    if (currentStreak < 7) return 1;
    return (currentStreak / 7).floor();
  }

  // ── Винагороди за серію ───────────────────────────────────────────

  /// Обчислює бонус XP за поточну серію.
  static int calculateStreakXpBonus(int streakDays) {
    int bonus = 0;
    for (final milestone in milestones) {
      if (streakDays >= milestone.days) bonus += milestone.xpReward;
    }
    return bonus;
  }

  /// Обчислює бонус монет за поточну серію.
  static int calculateStreakCoinBonus(int streakDays) {
    int bonus = 0;
    for (final milestone in milestones) {
      if (streakDays >= milestone.days) bonus += milestone.coinReward;
    }
    return bonus;
  }

  // ── Прогнозування ──────────────────────────────────────────────────

  /// Прогнозує ймовірність збереження серії.
  ///
  /// Базується на історії депозитів: чим довша серія,
  /// тим вища ймовірність продовження.
  static StreakPrediction predictRetention({
    required int currentStreak,
    required List<DateTime> depositDates,
  }) {
    if (currentStreak == 0) {
      return StreakPrediction(
        retentionProbability: 0.0,
        expectedLength: 0,
        advice: 'Почни свою серію сьогодні! Перший крок найважливіший 💪',
      );
    }

    // Аналіз регулярності за останні 14 днів
    final now = DateTime.now();
    final twoWeeksAgo = now.subtract(const Duration(days: 14));
    final recentDeposits = depositDates
        .where((d) => !d.isBefore(twoWeeksAgo) && !d.isAfter(now))
        .length;

    final regularity = recentDeposits / 14.0;
    final consistencyBonus = (currentStreak / 30.0).clamp(0.0, 0.3);
    final probability = (regularity * 0.7 + consistencyBonus).clamp(0.0, 0.95);

    // Очікувана довжина серії
    final expectedLength = currentStreak + (regularity * 30).round();

    String advice;
    if (probability > 0.8) {
      advice = 'Серія надійна! Продовжуй у тому ж дусі! 🔥';
    } else if (probability > 0.5) {
      advice = 'Хороший темп! Не забудь поповнити сьогодні! 💪';
    } else if (probability > 0.3) {
      advice = 'Увага! Ризик розриву серії. Зроби внесок зараз! ⚠️';
    } else {
      advice = 'Серія під загрозою! Терміново поповни скарбничку! 🚨';
    }

    return StreakPrediction(
      retentionProbability: probability,
      expectedLength: expectedLength,
      advice: advice,
    );
  }

  // ── Повідомлення ───────────────────────────────────────────────────

  /// Повертає мотиваційне повідомлення українською.
  static String getStreakMessage(int streakDays) {
    if (streakDays == 0) {
      return 'Почни свою серію сьогодні! Перше поповнення запускає лічильник 🔥';
    } else if (streakDays == 1) {
      return 'Перший день — це найважливіший крок! Продовжуй завтра! 💪';
    } else if (streakDays < 3) {
      return '$streakDays дні поспіль! Ти на правильному шляху! 🌱';
    } else if (streakDays < 7) {
      return '$streakDays дні поспіль! Ледь не тиждень — тримайся! 🚀';
    } else if (streakDays == 7) {
      return 'Тиждень поспіль! Ти справжній скарбничкар! 🏆';
    } else if (streakDays < 14) {
      return '$streakDays днів поспіль! Другий тиждень почався! ⭐';
    } else if (streakDays == 14) {
      return 'Два тижні! Звичка накопичення формується! 🎯';
    } else if (streakDays < 30) {
      return '$streakDays днів поспіль! Ти наближаєшся до місячного марафону! 🔥';
    } else if (streakDays == 30) {
      return 'Місяць поспіль! Ти легенда фінансової дисципліни! 👑';
    } else if (streakDays < 60) {
      return '$streakDays днів поспіль! Неймовірна стійкість! 💎';
    } else if (streakDays < 90) {
      return '$streakDays днів! Ти вже на півшляху до квартального рекорду! 🌟';
    } else if (streakDays < 180) {
      return '$streakDays днів! Фінансова дисципліна на рівні чемпіона! 🏅';
    } else if (streakDays < 365) {
      return '$streakDays днів! Ти надихаєш усіх навколо! 🎊';
    } else {
      return '$streakDays днів — РІЧНИЙ ЧЕМПІОН! Ти написав історію! 🥇';
    }
  }

  /// Повертає мотиваційне повідомлення для розірваної серії.
  static String getBrokenStreakMessage({
    required int previousStreak,
    required int freezeCount,
  }) {
    if (previousStreak >= 30) {
      return 'Серія $previousStreak днів розірвана. Але ти вже довів, що здатен! Почни знову! 💪';
    } else if (previousStreak >= 7) {
      return 'Тиждень+$ роботи втрачено. Але ти знаєш як — почни знову! 🌱';
    } else if (freezeCount > 0 && previousStreak > 0) {
      return 'Наступного разу використай заморожування, щоб зберегти серію! ❄️';
    } else {
      return 'Серія розірвана. Не здавайся — кожен новий день це новий шанс! 💔';
    }
  }

  /// Повертає повідомлення про ризик розриву серії.
  static String getRiskMessage(StreakRiskLevel risk) {
    switch (risk) {
      case StreakRiskLevel.safe:
        return 'Серія в безпеці! ✅';
      case StreakRiskLevel.warning:
        return 'Увага! Зроби поповнення сьогодні, щоб зберегти серію! ⚠️';
      case StreakRiskLevel.critical:
        return 'Серія під загрозою! Терміново поповни скарбничку! 🚨';
      case StreakRiskLevel.broken:
        return 'Серія розірвана. Але не здавайся — почни знову! 💔';
    }
  }

  /// Повертає пораду для відновлення серії.
  static String getRecoverySuggestion({
    required int daysSinceBreak,
    required int previousStreak,
  }) {
    if (daysSinceBreak <= 1) {
      return 'Пройшов лише один день! Почни нову серію прямо зараз! 🔥';
    } else if (daysSinceBreak <= 3) {
      return 'Майже не втрачено час! Почни сьогодні — ти все ще в формі! 💪';
    } else if (previousStreak >= 14) {
      return 'Ти вже досягав $previousStreak днів раніше. Повтори це! 🏆';
    } else {
      return 'Ніколи не пізно почати! Кожна гривня наближає тебе до мети! 🌱';
    }
  }

  /// Повертає колір на основі інтенсивності серії.
  static Color getStreakColor(int streakDays) {
    if (streakDays == 0) return Colors.grey.shade400;
    if (streakDays < 3) return Colors.green.shade300;
    if (streakDays < 7) return Colors.green.shade500;
    if (streakDays < 14) return Colors.lime.shade600;
    if (streakDays < 30) return Colors.amber.shade600;
    if (streakDays < 60) return Colors.orange.shade600;
    if (streakDays < 90) return Colors.deepOrange.shade600;
    if (streakDays < 180) return Colors.red.shade500;
    return const Color(0xFFFF1744);
  }

  /// Повертає іконку (emoji) на основі інтенсивності серії.
  static String getStreakEmoji(int streakDays) {
    if (streakDays == 0) return '💤';
    if (streakDays < 3) return '🌱';
    if (streakDays < 7) return '🔥';
    if (streakDays < 14) return '⚡';
    if (streakDays < 30) return '🌟';
    if (streakDays < 60) return '💎';
    if (streakDays < 90) return '👑';
    if (streakDays < 180) return '🏅';
    if (streakDays < 365) return '🎊';
    return '🥇';
  }

  // ── Історія серій ───────────────────────────────────────────────────

  /// Додає завершену серію до історії.
  static StreakHistoryEntry createHistoryEntry({
    required DateTime startDate,
    required DateTime endDate,
    required String endReason,
  }) {
    final days = endDate.difference(startDate).inDays + 1;
    return StreakHistoryEntry(
      startDate: startDate,
      endDate: endDate,
      days: days,
      endReason: endReason,
    );
  }

  /// Повертає статистику історії серій.
  static Map<String, dynamic> getStreakHistoryStats(
    List<StreakHistoryEntry> history,
  ) {
    if (history.isEmpty) {
      return {
        'totalStreaks': 0,
        'averageLength': 0.0,
        'longestHistory': 0,
        'totalDays': 0,
      };
    }

    final totalStreaks = history.length;
    final totalDays = history.fold<int>(0, (sum, e) => sum + e.days);
    final longestHistory =
        history.fold<int>(0, (max, e) => e.days > max ? e.days : max);

    return {
      'totalStreaks': totalStreaks,
      'averageLength': totalDays / totalStreaks,
      'longestHistory': longestHistory,
      'totalDays': totalDays,
    };
  }

  /// Генерує дані для візуалізації тиждневої карти серії.
  ///
  /// Повертає список даних за останні [weeksCount] тижнів.
  static List<StreakWeekData> getWeeklyVisualization({
    required List<DateTime> depositDates,
    int weeksCount = 12,
  }) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final result = <StreakWeekData>[];

    for (int w = weeksCount - 1; w >= 0; w--) {
      final weekStart = today.subtract(Duration(days: today.weekday - 1 + w * 7));
      final weekEnd = weekStart.add(const Duration(days: 6));

      final activeDays = depositDates
          .where((d) {
            final day = DateTime(d.year, d.month, d.day);
            return !day.isBefore(weekStart) && !day.isAfter(weekEnd);
          })
          .map((d) => DateTime(d.year, d.month, d.day))
          .toSet()
          .length;

      result.add(StreakWeekData(
        weekStart: weekStart,
        activeDays: activeDays,
        isPerfectWeek: activeDays == 7,
      ));
    }

    return result;
  }

  /// Генерує дані для візуалізації місячної карти серії.
  ///
  /// Повертає список даних за останні [monthsCount] місяців.
  static List<StreakMonthData> getMonthlyVisualization({
    required List<DateTime> depositDates,
    int monthsCount = 6,
  }) {
    final now = DateTime.now();
    final result = <StreakMonthData>[];

    for (int m = monthsCount - 1; m >= 0; m--) {
      final month = DateTime(now.year, now.month - m, 1);
      final monthEnd = DateTime(month.year, month.month + 1, 0);

      final activeDays = depositDates
          .where((d) {
            final day = DateTime(d.year, d.month, d.day);
            return !day.isBefore(month) && !day.isAfter(monthEnd);
          })
          .map((d) => DateTime(d.year, d.month, d.day))
          .toSet()
          .length;

      result.add(StreakMonthData(
        monthStart: month,
        activeDays: activeDays,
        totalDays: monthEnd.day,
      ));
    }

    return result;
  }

  // ── Валідація ───────────────────────────────────────────────────────

  /// Перевіряє, чи є дата валідною для аналізу серії (не в майбутньому).
  static bool isValidStreakDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final day = DateTime(date.year, date.month, date.day);
    return !day.isAfter(today);
  }

  /// Валідує список дат депозитів (відсортований, без дублікатів, не в майбутньому).
  static ({bool valid, String? error}) validateDepositDates(
    List<DateTime> dates,
  ) {
    if (dates.isEmpty) {
      return (valid: false, error: 'Список дат порожній');
    }
    for (final date in dates) {
      if (!isValidStreakDate(date)) {
        return (
          valid: false,
          error: 'Дата ${date.toIso8601String()} в майбутньому',
        );
      }
    }
    // Перевірка на дублікати
    final uniqueDays = dates
        .map((d) => DateTime(d.year, d.month, d.day).toIso8601String())
        .toSet();
    if (uniqueDays.length != dates.length) {
      return (valid: false, error: 'Знайдено дублікати дат');
    }
    return (valid: true, error: null);
  }

  /// Перевіряє коректність параметрів заморожування.
  static bool validateFreezeParams({
    required int currentStreak,
    required int freezeCount,
    required bool depositedToday,
  }) {
    if (currentStreak < 0 || freezeCount < 0) return false;
    if (currentStreak == 0 && freezeCount > 0) return false;
    return true;
  }

  // ── Індекс стабільності ─────────────────────────────────────────────

  /// Обчислює індекс стабільності серії (0.0–1.0).
  ///
  /// Базується на відношенні активних днів до загальної тривалості
  /// з урахуванням вагових коефіцієнтів за останні 30, 60, 90 днів.
  static double stabilityIndex({
    required List<DateTime> depositDates,
    int lookbackDays = 90,
  }) {
    if (depositDates.isEmpty) return 0.0;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final cutoff = today.subtract(Duration(days: lookbackDays));

    final recentDates = depositDates
        .where((d) {
          final day = DateTime(d.year, d.month, d.day);
          return !day.isBefore(cutoff) && !day.isAfter(today);
        })
        .map((d) => DateTime(d.year, d.month, d.day))
        .toSet();

    if (recentDates.isEmpty) return 0.0;

    // Ваги: останні 30 днів — найважливіші
    double weightedScore = 0;
    double totalWeight = 0;

    for (final date in recentDates) {
      final daysAgo = today.difference(date).inDays;
      if (daysAgo <= 30) {
        weightedScore += 1.0;
        totalWeight += 1.0;
      } else if (daysAgo <= 60) {
        weightedScore += 0.6;
        totalWeight += 0.6;
      } else {
        weightedScore += 0.3;
        totalWeight += 0.3;
      }
    }

    // Максимальний бал — всі дні в періоді
    final maxScore30 = 30 * 1.0;
    final maxScore60 = 30 * 0.6;
    final maxScore90 = 30 * 0.3;
    final maxPossible = lookbackDays >= 90
        ? maxScore30 + maxScore60 + maxScore90
        : lookbackDays >= 60
            ? maxScore30 + maxScore60
            : maxScore30;

    return (weightedScore / maxPossible).clamp(0.0, 1.0);
  }

  // ── Волатильність серії ─────────────────────────────────────────────

  /// Обчислює волатильність серії (кількість розривів за період).
  ///
  /// Чим менше розривів, тим стабільніша серія.
  static int streakBreakCount(List<DateTime> depositDates) {
    if (depositDates.length < 2) return 0;

    final sorted = depositDates
        .map((d) => DateTime(d.year, d.month, d.day))
        .toSet()
        .toList()
      ..sort();

    int breaks = 0;
    for (int i = 1; i < sorted.length; i++) {
      final diff = sorted[i].difference(sorted[i - 1]).inDays;
      if (diff > 1) breaks++;
    }

    return breaks;
  }

  /// Обчислює середню довжину серії між розривами.
  static double averageStreakLength(List<DateTime> depositDates) {
    if (depositDates.isEmpty) return 0.0;

    final sorted = depositDates
        .map((d) => DateTime(d.year, d.month, d.day))
        .toSet()
        .toList()
      ..sort();

    if (sorted.length < 2) return 1.0;

    final streakLengths = <int>[1];
    for (int i = 1; i < sorted.length; i++) {
      final diff = sorted[i].difference(sorted[i - 1]).inDays;
      if (diff == 1) {
        streakLengths[streakLengths.length - 1] += 1;
      } else {
        streakLengths.add(1);
      }
    }

    return streakLengths.reduce((a, b) => a + b) / streakLengths.length;
  }

  /// Розподіл довжин серій (гістограмma).
  static Map<int, int> streakLengthDistribution(List<DateTime> depositDates) {
    if (depositDates.isEmpty) return {};

    final sorted = depositDates
        .map((d) => DateTime(d.year, d.month, d.day))
        .toSet()
        .toList()
      ..sort();

    if (sorted.length < 2) return {1: 1};

    final distribution = <int, int>{};
    int currentLength = 1;

    for (int i = 1; i < sorted.length; i++) {
      final diff = sorted[i].difference(sorted[i - 1]).inDays;
      if (diff == 1) {
        currentLength += 1;
      } else {
        distribution[currentLength] = (distribution[currentLength] ?? 0) + 1;
        currentLength = 1;
      }
    }
    distribution[currentLength] = (distribution[currentLength] ?? 0) + 1;

    return distribution;
  }

  // ── Аналіз по днях тижня ────────────────────────────────────────────

  /// Визначає найактивніший день тижня для депозитів.
  ///
  /// Повертає назву дня (українською) та кількість депозитів.
  static ({String dayName, int count}) mostActiveDayOfWeek(
    List<DateTime> depositDates,
  ) {
    const dayNames = [
      'Понеділок',
      'Вівторок',
      'Середа',
      'Четвер',
      'П\'ятниця',
      'Субота',
      'Неділя',
    ];

    final counts = List.filled(7, 0);
    for (final date in depositDates) {
      // DateTime.weekday: 1 = Monday, 7 = Sunday
      counts[date.weekday - 1]++;
    }

    int maxIndex = 0;
    for (int i = 1; i < counts.length; i++) {
      if (counts[i] > counts[maxIndex]) maxIndex = i;
    }

    return (dayName: dayNames[maxIndex], count: counts[maxIndex]);
  }

  /// Повертає карту активності по днях тижня.
  static Map<String, int> weeklyActivityMap(List<DateTime> depositDates) {
    const dayNames = [
      'Понеділок',
      'Вівторок',
      'Середа',
      'Четвер',
      'П\'ятниця',
      'Субота',
      'Неділя',
    ];

    final counts = List.filled(7, 0);
    for (final date in depositDates) {
      counts[date.weekday - 1]++;
    }

    return Map.fromEntries(
      List.generate(7, (i) => MapEntry(dayNames[i], counts[i])),
    );
  }

  // ── Порівняння серій між періодами ──────────────────────────────────

  /// Порівнює активність двох періодів.
  static ({int period1Days, int period2Days, double changePercent})
      comparePeriodActivity({
    required List<DateTime> period1Dates,
    required List<DateTime> period2Dates,
    required DateTime period1Start,
    required DateTime period1End,
    required DateTime period2Start,
    required DateTime period2End,
  }) {
    final period1Days = period1Dates
        .where((d) {
          final day = DateTime(d.year, d.month, d.day);
          return !day.isBefore(period1Start) && !day.isAfter(period1End);
        })
        .map((d) => DateTime(d.year, d.month, d.day))
        .toSet()
        .length;

    final period2Days = period2Dates
        .where((d) {
          final day = DateTime(d.year, d.month, d.day);
          return !day.isBefore(period2Start) && !day.isAfter(period2End);
        })
        .map((d) => DateTime(d.year, d.month, d.day))
        .toSet()
        .length;

    double changePercent = 0;
    if (period1Days > 0) {
      changePercent = ((period2Days - period1Days) / period1Days) * 100;
    }

    return (
      period1Days: period1Days,
      period2Days: period2Days,
      changePercent: changePercent,
    );
  }

  // ── Теплова карта серій (heatmap) ───────────────────────────────────

  /// Генерує дані для теплової карти за останні [totalDays] днів.
  ///
  /// Повертає мапу: дата → кількість депозитів (0 або 1 для активного дня).
  static Map<String, int> generateHeatmapData({
    required List<DateTime> depositDates,
    int totalDays = 90,
  }) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final startDate = today.subtract(Duration(days: totalDays - 1));

    final activeDays = depositDates
        .map((d) => DateTime(d.year, d.month, d.day).toIso8601String())
        .toSet();

    final heatmap = <String, int>{};
    for (int i = 0; i < totalDays; i++) {
      final day = startDate.add(Duration(days: i));
      final key = day.toIso8601String();
      heatmap[key] = activeDays.contains(key) ? 1 : 0;
    }

    return heatmap;
  }

  /// Підраховує інтенсивність для кольору теплової карти (0–4).
  static int heatmapIntensity(int consecutiveDays) {
    if (consecutiveDays == 0) return 0;
    if (consecutiveDays < 3) return 1;
    if (consecutiveDays < 7) return 2;
    if (consecutiveDays < 14) return 3;
    return 4;
  }

  // ── Показник стійкості серії (resilience score) ─────────────────────

  /// Обчислює індекс стійкості серії (0–100).
  ///
  /// Враховує: поточну серію, кількість розривів,
  /// швидкість відновлення, використання заморожувань.
  static int resilienceScore({
    required int currentStreak,
    required int longestStreak,
    required int totalBreaks,
    required int totalFreezesUsed,
    required int totalFreezesAvailable,
    required double recoverySpeed,
    // recoverySpeed: 0.0–1.0, де 1.0 = миттєве відновлення
  }) {
    int score = 0;

    // Поточна серія (0–25 балів)
    if (currentStreak >= 30) {
      score += 25;
    } else if (currentStreak >= 14) {
      score += 20;
    } else if (currentStreak >= 7) {
      score += 15;
    } else if (currentStreak >= 3) {
      score += 10;
    } else if (currentStreak > 0) {
      score += 5;
    }

    // Відношення до рекорду (0–25 балів)
    if (longestStreak > 0) {
      final ratio = currentStreak / longestStreak;
      score += (ratio * 25).round();
    }

    // Частота розривів (0–25 балів, менше = краще)
    if (totalBreaks == 0) {
      score += 25;
    } else if (totalBreaks <= 2) {
      score += 18;
    } else if (totalBreaks <= 5) {
      score += 10;
    } else {
      score += 5;
    }

    // Ефективність заморожувань (0–15 балів)
    if (totalFreezesAvailable > 0) {
      final freezeUsage = totalFreezesUsed / totalFreezesAvailable;
      // Ідеально: використано 0–30% від доступних
      if (freezeUsage <= 0.3) {
        score += 15;
      } else if (freezeUsage <= 0.6) {
        score += 10;
      } else {
        score += 5;
      }
    } else {
      score += 15; // Якщо заморожувань немає — не потрібні
    }

    // Швидкість відновлення (0–10 балів)
    score += (recoverySpeed * 10).round();

    return score.clamp(0, 100);
  }

  // ── Підрахунок ідеальних тижнів/місяців ─────────────────────────────

  /// Кількість ідеальних тижнів (7 днів поспіль) за період.
  static int countPerfectWeeks(List<DateTime> depositDates) {
    final weeks = getWeeklyVisualization(depositDates: depositDates, weeksCount: 52);
    return weeks.where((w) => w.isPerfectWeek).length;
  }

  /// Кількість місяців з покриттям 80%+.
  static int countStrongMonths(List<DateTime> depositDates) {
    final months = getMonthlyVisualization(depositDates: depositDates, monthsCount: 12);
    return months.where((m) => m.coverage >= 0.8).length;
  }

  // ── Набір даних для таблиці лідерів ─────────────────────────────────

  /// Обчислює бал для таблиці лідерів на основі серії.
  ///
  /// Формула: поточна серія × 2 + рекорд × 1 + ідеальні тижні × 10.
  static int leaderboardScore({
    required int currentStreak,
    required int longestStreak,
    required int perfectWeeks,
  }) {
    return currentStreak * 2 + longestStreak + perfectWeeks * 10;
  }

  /// Повертає ранг користувача в таблиці лідерів.
  ///
  /// [scores] — відсортований список балів (від найвищого).
  /// [userScore] — бал поточного користувача.
  static int getLeaderboardRank(List<int> scores, int userScore) {
    if (scores.isEmpty) return 1;
    final sorted = List<int>.from(scores)..sort((a, b) => b.compareTo(a));
    for (int i = 0; i < sorted.length; i++) {
      if (userScore >= sorted[i]) return i + 1;
    }
    return sorted.length + 1;
  }

  // ── Логування серій ─────────────────────────────────────────────────

  /// Генерує структурований лог-запис для події серії.
  static Map<String, dynamic> createStreakLogEntry({
    required String eventType,
    required int currentStreak,
    int? previousStreak,
    String? milestoneReached,
    bool? freezeUsed,
    Map<String, dynamic>? extra,
  }) {
    return {
      'timestamp': DateTime.now().toIso8601String(),
      'eventType': eventType, // 'deposit', 'break', 'freeze', 'milestone'
      'currentStreak': currentStreak,
      'previousStreak': previousStreak,
      'streakChanged': previousStreak != null && previousStreak != currentStreak,
      'milestoneReached': milestoneReached,
      'freezeUsed': freezeUsed ?? false,
      ...?extra,
    };
  }

  /// Генерує підсумковий звіт серії.
  static Map<String, dynamic> createStreakReport({
    required StreakResult result,
    required List<DateTime> depositDates,
  }) {
    final now = DateTime.now();
    final streakHistory = getStreakHistoryStats(_extractHistory(depositDates));

    return {
      'reportDate': now.toIso8601String(),
      'currentStreak': result.currentStreak,
      'longestStreak': result.longestStreak,
      'weeklyStreak': result.weeklyStreak,
      'monthlyStreak': result.monthlyStreak,
      'riskLevel': result.riskLevel.name,
      'isFrozen': result.isFrozen,
      'freezeCount': result.freezeCount,
      'daysUntilBreak': result.daysUntilBreak,
      'stabilityIndex': stabilityIndex(depositDates: depositDates),
      'breakCount': streakBreakCount(depositDates),
      'avgStreakLength': averageStreakLength(depositDates),
      'resilienceScore': resilienceScore(
        currentStreak: result.currentStreak,
        longestStreak: result.longestStreak,
        totalBreaks: streakBreakCount(depositDates),
        totalFreezesUsed: result.freezeCount,
        totalFreezesAvailable: maxFreezesForStreak(result.currentStreak),
        recoverySpeed: result.currentStreak > 0 ? 0.8 : 0.0,
      ),
      'perfectWeeks': countPerfectWeeks(depositDates),
      'leaderboardScore': leaderboardScore(
        currentStreak: result.currentStreak,
        longestStreak: result.longestStreak,
        perfectWeeks: countPerfectWeeks(depositDates),
      ),
      'totalActiveDays': depositDates
          .map((d) => DateTime(d.year, d.month, d.day))
          .toSet()
          .length,
    };
  }

  /// Допоміжний метод: витягує історію серій із дат депозитів.
  static List<StreakHistoryEntry> _extractHistory(List<DateTime> dates) {
    if (dates.isEmpty) return [];

    final sorted = dates
        .map((d) => DateTime(d.year, d.month, d.day))
        .toSet()
        .toList()
      ..sort();

    final history = <StreakHistoryEntry>[];
    int streakStart = 0;

    for (int i = 1; i < sorted.length; i++) {
      final diff = sorted[i].difference(sorted[i - 1]).inDays;
      if (diff > 1) {
        history.add(createHistoryEntry(
          startDate: sorted[streakStart],
          endDate: sorted[i - 1],
          endReason: 'gap',
        ));
        streakStart = i;
      }
    }

    // Остання активна серія
    history.add(createHistoryEntry(
      startDate: sorted[streakStart],
      endDate: sorted.last,
      endReason: 'active',
    ));

    return history;
  }
}
