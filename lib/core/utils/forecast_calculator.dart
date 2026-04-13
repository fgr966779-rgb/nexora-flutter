import 'dart:math' as math;

/// Режим прогнозування.
enum ForecastMode {
  /// Обережний прогноз.
  conservative,
  /// Оптимістичний прогноз.
  optimistic,
  /// Середній прогноз.
  average,
}

/// Результат прогнозу завершення цілі.
class ForecastResult {
  final DateTime estimatedDate;
  final int daysRemaining;
  final double dailyAmount;
  final ForecastMode mode;
  final int confidenceRange;
  final int confidencePercent;
  final double totalProjected;

  const ForecastResult({
    required this.estimatedDate,
    required this.daysRemaining,
    required this.dailyAmount,
    required this.mode,
    this.confidenceRange = 0,
    this.confidencePercent = 50,
    required this.totalProjected,
  });
}

/// Розбивка прогнозу по періодах.
class ForecastBreakdown {
  final double dailyAmount;
  final double weeklyAmount;
  final double monthlyAmount;
  final int activeDays;
  final int activeWeeks;
  final int activeMonths;

  const ForecastBreakdown({
    required this.dailyAmount,
    required this.weeklyAmount,
    required this.monthlyAmount,
    required this.activeDays,
    required this.activeWeeks,
    required this.activeMonths,
  });
}

/// Дата прогнозу етапу.
class MilestoneForecast {
  final double percentage;
  final DateTime expectedDate;
  final int daysFromNow;
  final double expectedAmount;

  const MilestoneForecast({
    required this.percentage,
    required this.expectedDate,
    required this.daysFromNow,
    required this.expectedAmount,
  });
}

/// Запис про точність прогнозу.
class ForecastAccuracyRecord {
  final DateTime forecastDate;
  final DateTime predictedCompletion;
  final DateTime? actualCompletion;
  final int? daysOff;

  const ForecastAccuracyRecord({
    required this.forecastDate,
    required this.predictedCompletion,
    this.actualCompletion,
    this.daysOff,
  });

  double? get accuracyPercent {
    if (daysOff == null) return null;
    final totalDays =
        actualCompletion?.difference(forecastDate).inDays ?? daysOff!;
    if (totalDays == 0) return 100.0;
    final error = (daysOff! / totalDays * 100).abs();
    return (100.0 - error).clamp(0.0, 100.0);
  }
}

/// Порада для прискорення.
class AccelerateSuggestion {
  final double extraDailyAmount;
  final int daysEarlier;
  final double newDailyRate;
  final String message;

  const AccelerateSuggestion({
    required this.extraDailyAmount,
    required this.daysEarlier,
    required this.newDailyRate,
    required this.message,
  });
}

/// Дані для графіка прогнозу.
class ForecastChartData {
  final List<DateTime> dates;
  final List<double> projectedAmounts;
  final double targetAmount;
  final double currentAmount;
  final List<double> upperBound;
  final List<double> lowerBound;

  const ForecastChartData({
    required this.dates,
    required this.projectedAmounts,
    required this.targetAmount,
    required this.currentAmount,
    required this.upperBound,
    required this.lowerBound,
  });
}

/// Результат сценарного аналізу «що-якщо».
class ScenarioResult {
  /// Назва сценарію.
  final String name;

  /// Опис сценарію українською.
  final String description;

  /// Щоденна сума за цим сценарієм.
  final double dailyAmount;

  /// Очікувана дата завершення.
  final DateTime estimatedDate;

  /// Кількість днів до завершення.
  final int daysRemaining;

  const ScenarioResult({
    required this.name,
    required this.description,
    required this.dailyAmount,
    required this.estimatedDate,
    required this.daysRemaining,
  });
}

/// Результат плану заощаджень.
class SavingsPlanResult {
  /// Назва плану.
  final String name;

  /// Щоденний внесок.
  final double dailyDeposit;

  /// Щотижневий внесок.
  final double weeklyDeposit;

  /// Щомісячний внесок.
  final double monthlyDeposit;

  /// Очікувана дата завершення.
  final DateTime estimatedDate;

  /// Загальна зекономлена сума (за час дії плану).
  final double totalSaved;

  const SavingsPlanResult({
    required this.name,
    required this.dailyDeposit,
    required this.weeklyDeposit,
    required this.monthlyDeposit,
    required this.estimatedDate,
    required this.totalSaved,
  });
}

/// Калькулятор прогнозу завершення цілі.
///
/// Використовує лінійну регресію на основі історії транзакцій
/// для прогнозування дати досягнення цільової суми.
class ForecastCalculator {
  // ── Сезонні коефіцієнти ─────────────────────────────────────────

  static const Set<int> _lowActivityMonths = {12, 1};
  static const Set<int> _highActivityMonths = {3, 9};

  /// Розширені сезонні коефіцієнти для кожного місяця.
  static const Map<int, double> monthlySeasonFactors = {
    1: 0.70, // Січень — новорічні витрати
    2: 0.85, // Лютий
    3: 1.15, // Березень — весняне мотивація
    4: 1.05, // Квітень
    5: 1.00, // Травень
    6: 0.95, // Червень — початок літа
    7: 0.85, // Липень — відпустки
    8: 0.80, // Серпень — відпустки
    9: 1.15, // Вересень — повернення до роботи
    10: 1.05, // Жовтень
    11: 0.90, // Листопад
    12: 0.70, // Грудень — свята
  };

  static double _seasonalCoefficient(DateTime date) {
    if (_lowActivityMonths.contains(date.month)) return 0.7;
    if (_highActivityMonths.contains(date.month)) return 1.15;
    return 1.0;
  }

  /// Повертає сезонне коригування для поточного місяця.
  static double currentSeasonalAdjustment() {
    return monthlySeasonFactors[DateTime.now().month] ?? 1.0;
  }

  /// Повертає сезонне коригування для вказаного місяця.
  static double seasonalAdjustmentForMonth(int month) {
    return monthlySeasonFactors[month] ?? 1.0;
  }

  /// Повертає опис сезону українською.
  static String getSeasonDescription() {
    final month = DateTime.now().month;
    if (_lowActivityMonths.contains(month)) {
      return 'Святковий сезон — зазвичай люди заощаджують менше. Будь стійким! 🎄';
    } else if (_highActivityMonths.contains(month)) {
      return 'Чудовий час для заощаджень! Сезон високої мотивації! 🌟';
    }
    return 'Звичайний сезон — чудовий час для стабільних накопичень! 💪';
  }

  /// Повертає опис сезону для вказаного місяця.
  static String getSeasonDescriptionForMonth(int month) {
    const descriptions = {
      1: 'Січень — час після свят, новий початок! 🎄',
      2: 'Лютий — короткий місяць, кожна гривня важлива! ❄️',
      3: 'Березень — весна прийшла, час нових цілей! 🌱',
      4: 'Квітень — гарний час для заощаджень! 🌸',
      5: 'Травень — майже літо, підсилюй темп! ☀️',
      6: 'Червень — початок літа, не забувай про накопичення! 🏖️',
      7: 'Липень — відпустка, але невеликі внески теж рахуються! 🌊',
      8: 'Серпень — останній місяць літа, фінішний ривок! 🏁',
      9: 'Вересень — повернення до рутини, час дисципліни! 📚',
      10: 'Жовтень — осінній сезон заощаджень! 🍂',
      11: 'Листопад — підготовка до зимових свят! 🧣',
      12: 'Грудень — святковий місяць, але є час і для заощаджень! 🎅',
    };
    return descriptions[month] ?? '';
  }

  // ── Базові розрахунки ──────────────────────────────────────────────

  static Map<String, double> _calculateRates(List<_TransactionProxy> txns) {
    if (txns.length < 2) {
      return {'average': 0, 'min': 0, 'max': 0, 'median': 0};
    }

    final firstDate = txns.first.date;
    final lastDate = txns.last.date;
    final totalDays = lastDate.difference(firstDate).inDays;

    if (totalDays < 1) {
      return {'average': 0, 'min': 0, 'max': 0, 'median': 0};
    }

    final totalDeposited =
        txns.fold<double>(0.0, (sum, t) => sum + t.amount);
    final average = totalDeposited / totalDays;

    final dailySums = <double>[];
    var currentDay = firstDate;
    while (!currentDay.isAfter(lastDate)) {
      final dayTotal = txns
          .where((t) =>
              t.date.year == currentDay.year &&
              t.date.month == currentDay.month &&
              t.date.day == currentDay.day)
          .fold<double>(0.0, (sum, t) => sum + t.amount);
      if (dayTotal > 0) dailySums.add(dayTotal);
      currentDay = currentDay.add(const Duration(days: 1));
    }

    dailySums.sort();
    final min = dailySums.isNotEmpty ? dailySums.first : 0.0;
    final max = dailySums.isNotEmpty ? dailySums.last : 0.0;
    final median = dailySums.isNotEmpty
        ? dailySums[dailySums.length ~/ 2]
        : 0.0;

    return {'average': average, 'min': min, 'max': max, 'median': median};
  }

  static List<_TransactionProxy> _filterDeposits(
    List<Map<String, dynamic>> rawTransactions, {
    String? goalIdFilter,
  }) {
    return rawTransactions
        .where((t) =>
            (t['amount'] as num) > 0 &&
            (goalIdFilter == null || t['goalId'] == goalIdFilter))
        .map((t) => _TransactionProxy(
              date: t['date'] as DateTime,
              amount: (t['amount'] as num).toDouble(),
            ))
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));
  }

  /// Прогнозує дату завершення цілі (базовий метод).
  static DateTime? forecastCompletionDate({
    required double remaining,
    required List<Map<String, dynamic>> rawTransactions, {
    String? goalIdFilter,
    ForecastMode mode = ForecastMode.average,
  }) {
    if (remaining <= 0) return DateTime.now();

    final txns = _filterDeposits(rawTransactions, goalIdFilter: goalIdFilter);
    if (txns.length < 2) return null;

    final rates = _calculateRates(txns);
    double dailyRate;

    switch (mode) {
      case ForecastMode.conservative:
        dailyRate = rates['min']!;
      case ForecastMode.optimistic:
        dailyRate = rates['max']!;
      case ForecastMode.average:
        dailyRate = rates['average']!;
    }

    dailyRate *= currentSeasonalAdjustment();
    if (dailyRate <= 0) return null;

    final daysRemaining = (remaining / dailyRate).ceil();
    return DateTime.now().add(Duration(days: daysRemaining));
  }

  // ── Повний прогноз ─────────────────────────────────────────────────

  static ForecastResult? generateForecast({
    required double currentAmount,
    required double targetAmount,
    required List<Map<String, dynamic>> rawTransactions, {
    String? goalIdFilter,
    ForecastMode mode = ForecastMode.average,
  }) {
    final remaining = targetAmount - currentAmount;
    if (remaining <= 0) {
      return ForecastResult(
        estimatedDate: DateTime.now(),
        daysRemaining: 0,
        dailyAmount: 0,
        mode: mode,
        confidenceRange: 0,
        confidencePercent: 100,
        totalProjected: currentAmount,
      );
    }

    final txns = _filterDeposits(rawTransactions, goalIdFilter: goalIdFilter);
    if (txns.length < 2) return null;

    final rates = _calculateRates(txns);
    double dailyRate;

    switch (mode) {
      case ForecastMode.conservative:
        dailyRate = rates['min']!;
      case ForecastMode.optimistic:
        dailyRate = rates['max']!;
      case ForecastMode.average:
        dailyRate = rates['median']!;
    }

    dailyRate *= currentSeasonalAdjustment();
    if (dailyRate <= 0) return null;

    final daysRemaining = (remaining / dailyRate).ceil();
    final estimatedDate = DateTime.now().add(Duration(days: daysRemaining));

    final confidenceRange = txns.length < 7
        ? daysRemaining ~/ 3
        : txns.length < 30
            ? daysRemaining ~/ 5
            : daysRemaining ~/ 8;

    final confidencePercent = txns.length < 7
        ? 40
        : txns.length < 30
            ? 65
            : 80;

    return ForecastResult(
      estimatedDate: estimatedDate,
      daysRemaining: daysRemaining,
      dailyAmount: dailyRate,
      mode: mode,
      confidenceRange: confidenceRange,
      confidencePercent: confidencePercent,
      totalProjected: currentAmount + dailyRate * daysRemaining,
    );
  }

  // ── Сценарний аналіз ──────────────────────────────────────────────

  /// Генерує три сценарії: обережний, середній, оптимістичний.
  static List<ScenarioResult> generateScenarios({
    required double currentAmount,
    required double targetAmount,
    required List<Map<String, dynamic>> rawTransactions, {
    String? goalIdFilter,
  }) {
    final txns = _filterDeposits(rawTransactions, goalIdFilter: goalIdFilter);
    if (txns.length < 2) return [];

    final rates = _calculateRates(txns);
    final remaining = targetAmount - currentAmount;
    if (remaining <= 0) return [];

    final now = DateTime.now();
    final scenarios = <ScenarioResult>[];

    // Обережний
    final conservativeRate = rates['min']! * currentSeasonalAdjustment();
    if (conservativeRate > 0) {
      final days = (remaining / conservativeRate).ceil();
      scenarios.add(ScenarioResult(
        name: 'Обережний',
        description: 'Мінімальний щоденний темп за весь час',
        dailyAmount: conservativeRate,
        estimatedDate: now.add(Duration(days: days)),
        daysRemaining: days,
      ));
    }

    // Середній
    final averageRate = rates['average']! * currentSeasonalAdjustment();
    if (averageRate > 0) {
      final days = (remaining / averageRate).ceil();
      scenarios.add(ScenarioResult(
        name: 'Середній',
        description: 'Середній щоденний темп',
        dailyAmount: averageRate,
        estimatedDate: now.add(Duration(days: days)),
        daysRemaining: days,
      ));
    }

    // Оптимістичний
    final optimisticRate = rates['max']! * currentSeasonalAdjustment();
    if (optimisticRate > 0) {
      final days = (remaining / optimisticRate).ceil();
      scenarios.add(ScenarioResult(
        name: 'Оптимістичний',
        description: 'Максимальний щоденний темп',
        dailyAmount: optimisticRate,
        estimatedDate: now.add(Duration(days: days)),
        daysRemaining: days,
      ));
    }

    return scenarios;
  }

  /// Генерує план заощаджень «що-якщо» з зміненою сумою.
  ///
  /// [whatIfDaily] — гіпотетична щоденна сума.
  static SavingsPlanResult? whatIfPlan({
    required double currentAmount,
    required double targetAmount,
    required double whatIfDaily,
  }) {
    final remaining = targetAmount - currentAmount;
    if (remaining <= 0 || whatIfDaily <= 0) return null;

    final days = (remaining / whatIfDaily).ceil();
    final now = DateTime.now();
    final total = whatIfDaily * days;

    return SavingsPlanResult(
      name: 'План «Що якщо»',
      dailyDeposit: whatIfDaily,
      weeklyDeposit: whatIfDaily * 7,
      monthlyDeposit: whatIfDaily * 30,
      estimatedDate: now.add(Duration(days: days)),
      totalSaved: total,
    );
  }

  /// Генерує оптимальний план заощаджень для досягнення цілі вчасно.
  ///
  /// [targetDate] — бажана дата завершення.
  static SavingsPlanResult? optimalPlan({
    required double currentAmount,
    required double targetAmount,
    required DateTime targetDate,
  }) {
    final remaining = targetAmount - currentAmount;
    if (remaining <= 0) return null;

    final now = DateTime.now();
    final days = targetDate.difference(now).inDays;
    if (days <= 0) return null;

    final daily = remaining / days;
    final weekly = daily * 7;
    final monthly = daily * 30;

    return SavingsPlanResult(
      name: 'Оптимальний план',
      dailyDeposit: daily,
      weeklyDeposit: weekly,
      monthlyDeposit: monthly,
      estimatedDate: targetDate,
      totalSaved: remaining,
    );
  }

  // ── Розбивка по періодах ──────────────────────────────────────────

  static ForecastBreakdown? generateBreakdown({
    required List<Map<String, dynamic>> rawTransactions, {
    String? goalIdFilter,
  }) {
    final txns = _filterDeposits(rawTransactions, goalIdFilter: goalIdFilter);
    if (txns.length < 2) return null;

    final rates = _calculateRates(txns);
    final daily = rates['average']! * currentSeasonalAdjustment();
    if (daily <= 0) return null;

    final uniqueDays = txns
        .map((t) => DateTime(t.date.year, t.date.month, t.date.day))
        .toSet()
        .length;

    return ForecastBreakdown(
      dailyAmount: daily,
      weeklyAmount: daily * 7,
      monthlyAmount: daily * 30,
      activeDays: uniqueDays,
      activeWeeks: (uniqueDays / 7).ceil(),
      activeMonths: (uniqueDays / 30).ceil(),
    );
  }

  // ── Етапні прогнози ───────────────────────────────────────────────

  static List<MilestoneForecast> predictMilestones({
    required double currentAmount,
    required double targetAmount,
    required List<Map<String, dynamic>> rawTransactions, {
    String? goalIdFilter,
  }) {
    final forecasts = <MilestoneForecast>[];
    final txns = _filterDeposits(rawTransactions, goalIdFilter: goalIdFilter);
    if (txns.length < 2) return forecasts;

    final rates = _calculateRates(txns);
    final dailyRate = rates['average']! * currentSeasonalAdjustment();
    if (dailyRate <= 0) return forecasts;

    final now = DateTime.now();
    final percentages = [0.25, 0.50, 0.75, 1.0];

    for (final pct in percentages) {
      final targetForMilestone = targetAmount * pct;
      if (currentAmount >= targetForMilestone) continue;

      final remaining = targetForMilestone - currentAmount;
      final days = (remaining / dailyRate).ceil();
      final date = now.add(Duration(days: days));

      forecasts.add(MilestoneForecast(
        percentage: pct,
        expectedDate: date,
        daysFromNow: days,
        expectedAmount: targetForMilestone,
      ));
    }

    return forecasts;
  }

  // ── Поради для прискорення ────────────────────────────────────────

  static AccelerateSuggestion? calculateAcceleration({
    required double currentAmount,
    required double targetAmount,
    required List<Map<String, dynamic>> rawTransactions, {
    String? goalIdFilter,
    required int targetDaysEarlier,
  }) {
    final remaining = targetAmount - currentAmount;
    if (remaining <= 0) return null;

    final txns = _filterDeposits(rawTransactions, goalIdFilter: goalIdFilter);
    if (txns.length < 2) return null;

    final rates = _calculateRates(txns);
    final currentDaily = rates['average']! * currentSeasonalAdjustment();
    if (currentDaily <= 0) return null;

    final currentDaysNeeded = (remaining / currentDaily).ceil();
    final newDaysNeeded =
        (currentDaysNeeded - targetDaysEarlier).clamp(1, currentDaysNeeded);

    final newDailyRate = remaining / newDaysNeeded;
    final extraDaily = newDailyRate - currentDaily;
    if (extraDaily <= 0) return null;

    String message;
    final extraRounded = extraDaily.ceilToDouble();
    if (extraRounded < 10) {
      message =
          'Додай ще лише ${extraRounded.toStringAsFixed(0)} грн/день — і ти досягнеш цілі на $targetDaysEarlier днів раніше! 🚀';
    } else if (extraRounded < 50) {
      message =
          'Збільш депозит на ${extraRounded.toStringAsFixed(0)} грн/день — це прискорить досягнення цілі на $targetDaysEarlier днів! 💪';
    } else {
      message =
          'Для прискорення на $targetDaysEarlier днів потрібно додавати ще ${extraRounded.toStringAsFixed(0)} грн/день. Ти впораєшся! 🔥';
    }

    return AccelerateSuggestion(
      extraDailyAmount: extraDaily,
      daysEarlier: targetDaysEarlier,
      newDailyRate: newDailyRate,
      message: message,
    );
  }

  static int? calculateImpact({
    required double currentAmount,
    required double targetAmount,
    required List<Map<String, dynamic>> rawTransactions, {
    String? goalIdFilter,
    required double extraDailyAmount,
  }) {
    final remaining = targetAmount - currentAmount;
    if (remaining <= 0) return 0;

    final txns = _filterDeposits(rawTransactions, goalIdFilter: goalIdFilter);
    if (txns.length < 2) return null;

    final rates = _calculateRates(txns);
    final currentDaily = rates['average']! * currentSeasonalAdjustment();
    if (currentDaily <= 0) return null;

    final currentDays = (remaining / currentDaily).ceil();
    final newDaily = currentDaily + extraDailyAmount;
    final newDays = (remaining / newDaily).ceil();

    return currentDays - newDays;
  }

  // ── Точність прогнозу ──────────────────────────────────────────────

  static double evaluateAccuracy(List<ForecastAccuracyRecord> records) {
    if (records.isEmpty) return 0.0;

    final validRecords = records.where((r) => r.daysOff != null).toList();
    if (validRecords.isEmpty) return 0.0;

    final avgAccuracy = validRecords.fold<double>(
      0.0,
      (sum, r) => sum + (r.accuracyPercent ?? 0.0),
    );

    return avgAccuracy / validRecords.length;
  }

  // ── Дані для графіка ──────────────────────────────────────────────

  static ForecastChartData? generateChartData({
    required double currentAmount,
    required double targetAmount,
    required List<Map<String, dynamic>> rawTransactions, {
    String? goalIdFilter,
    int numberOfPoints = 30,
  }) {
    final remaining = targetAmount - currentAmount;
    if (remaining <= 0) return null;

    final txns = _filterDeposits(rawTransactions, goalIdFilter: goalIdFilter);
    if (txns.length < 2) return null;

    final rates = _calculateRates(txns);
    final dailyRate = rates['average']! * currentSeasonalAdjustment();
    if (dailyRate <= 0) return null;

    final totalDays = (remaining / dailyRate).ceil();
    final step = (totalDays / numberOfPoints).ceil().clamp(1, totalDays);
    final now = DateTime.now();

    final dates = <DateTime>[];
    final projected = <double>[];
    final upper = <double>[];
    final lower = <double>[];

    double accumulated = currentAmount;
    final variability = txns.length < 7
        ? 0.3
        : txns.length < 30
            ? 0.15
            : 0.08;

    for (int day = 0; day <= totalDays; day += step) {
      final date = now.add(Duration(days: day));
      dates.add(date);

      accumulated += dailyRate * step;
      final capped = accumulated.clamp(0.0, targetAmount);
      projected.add(capped);
      upper.add((capped * (1 + variability)).clamp(0.0, targetAmount * 1.2));
      lower.add((capped * (1 - variability)).clamp(0.0, double.infinity));
    }

    return ForecastChartData(
      dates: dates,
      projectedAmounts: projected,
      targetAmount: targetAmount,
      currentAmount: currentAmount,
      upperBound: upper,
      lowerBound: lower,
    );
  }

  // ── Повідомлення ───────────────────────────────────────────────────

  static String getForecastMessage({
    required int daysRemaining,
    required double dailyAmount,
  }) {
    if (daysRemaining <= 0) {
      return '🎉 Ціль досягнуто! Ти молодець!';
    } else if (daysRemaining <= 7) {
      return '🔥 Менше тижня залишилось! Фінішна пряма! ${dailyAmount.toStringAsFixed(0)} грн/день — і ти переможець!';
    } else if (daysRemaining <= 30) {
      return '💪 Менше місяця! Продовжуй відкладати ${dailyAmount.toStringAsFixed(0)} грн/день — мета близько!';
    } else if (daysRemaining <= 90) {
      return '🌟 За ${_formatDays(daysRemaining)} ти досягнеш цілі при ${dailyAmount.toStringAsFixed(0)} грн/день. Ти на правильному шляху!';
    } else if (daysRemaining <= 180) {
      return '🎯 План реалістичний: ${_formatDays(daysRemaining)} при поточному темпі. Можеш прискорити!';
    } else {
      return '📅 ${_formatDays(daysRemaining)} — це довгострокова мета. Кожна гривня наближає тебе до мрії! 💎';
    }
  }

  static String _formatDays(int days) {
    if (days == 1) return '1 день';
    final lastTwo = days % 100;
    final lastOne = days % 10;

    if (lastTwo >= 11 && lastTwo <= 14) return '$days днів';
    if (lastOne == 1) return '$days день';
    if (lastOne >= 2 && lastOne <= 4) return '$days дні';
    return '$days днів';
  }

  static String getAdviceMessage(double dailyRate) {
    if (dailyRate <= 0) {
      return '🤔 Почни з невеликих сум — навіть 10 грн/день зроблять різницю!';
    } else if (dailyRate < 20) {
      return '🌱 Непоганий початок! Спробуй збільшити темп до 20 грн/день.';
    } else if (dailyRate < 50) {
      return '🚀 Хороший темп! Ти на шляху до стабільних заощаджень!';
    } else if (dailyRate < 100) {
      return '💪 Вражаючий темп накопичення! Так тримати!';
    } else {
      return '👑 Ти — фінансовий чемпіон! Такий темп вражає!';
    }
  }

  /// Повертає повідомлення про темп заощаджень для сценарії.
  static String getScenarioMessage(ScenarioResult scenario) {
    return '${scenario.name} сценарій: ${scenario.dailyAmount.toStringAsFixed(0)} грн/день → через ${_formatDays(scenario.daysRemaining)}';
  }

  // ── Лінійна регресія ────────────────────────────────────────────────

  /// Обчислює коефіцієнт лінійної регресії (нахил) для прогнозу.
  ///
  /// [txns] — відфільтровані депозитні транзакції.
  static double _linearRegressionSlope(List<_TransactionProxy> txns) {
    if (txns.length < 2) return 0.0;
    final firstDate = txns.first.date;
    final lastDate = txns.last.date;
    final totalDays = lastDate.difference(firstDate).inDays;
    if (totalDays < 1) return 0.0;

    final totalDeposited = txns.fold<double>(0.0, (sum, t) => sum + t.amount);
    return totalDeposited / totalDays;
  }

  /// Обчислює коефіцієнт детермінації (R²) для моделі прогнозу.
  ///
  /// [actual] — фактичні значення.
  /// [predicted] — прогнозовані значення.
  static double coefficientOfDetermination(
    List<double> actual,
    List<double> predicted,
  ) {
    if (actual.length != predicted.length || actual.isEmpty) return 0.0;
    final meanActual = actual.reduce((a, b) => a + b) / actual.length;
    double ssTot = 0;
    double ssRes = 0;
    for (int i = 0; i < actual.length; i++) {
      ssTot += (actual[i] - meanActual) * (actual[i] - meanActual);
      ssRes += (actual[i] - predicted[i]) * (actual[i] - predicted[i]);
    }
    if (ssTot == 0) return 1.0;
    return (1 - ssRes / ssTot).clamp(0.0, 1.0);
  }

  /// Оцінює якість прогнозу на основі минулих прогнозів.
  ///
  /// Повертає значення від 0.0 (погано) до 1.0 (ідеально).
  static double evaluateForecastQuality(List<ForecastAccuracyRecord> records) {
    if (records.isEmpty) return 0.0;
    final validRecords = records
        .where((r) => r.daysOff != null && r.actualCompletion != null)
        .toList();
    if (validRecords.isEmpty) return 0.0;

    double totalAccuracy = 0.0;
    for (final r in validRecords) {
      totalAccuracy += r.accuracyPercent ?? 0.0;
    }
    return (totalAccuracy / validRecords.length).clamp(0.0, 1.0);
  }

  // ── Розширені розрахунки ──────────────────────────────────────────────

  /// Розраховує стабільність заощаджень (відсоток днів з депозитом).
  ///
  /// Повертає значення від 0.0 до 1.0.
  static double calculateConsistency(List<_TransactionProxy> txns) {
    if (txns.length < 2) return 0.0;
    final firstDate = txns.first.date;
    final lastDate = txns.last.date;
    final totalDays = lastDate.difference(firstDate).inDays;
    if (totalDays < 1) return 1.0;

    final uniqueDays = txns
        .map((t) => DateTime(t.date.year, t.date.month, t.date.day))
        .toSet()
        .length;

    return (uniqueDays / totalDays).clamp(0.0, 1.0);
  }

  /// Розраховує середньоквадратичне відхилення депозитів.
  static double depositVariance(List<_TransactionProxy> txns) {
    if (txns.length < 2) return 0.0;
    final firstDate = txns.first.date;
    final lastDate = txns.last.date;
    final totalDays = lastDate.difference(firstDate).inDays;
    if (totalDays < 1) return 0.0;

    final dailyRates = <double>[];
    var currentDay = firstDate;
    while (!currentDay.isAfter(lastDate)) {
      final dayTotal = txns
          .where((t) =>
              t.date.year == currentDay.year &&
              t.date.month == currentDay.month &&
              t.date.day == currentDay.day)
          .fold<double>(0.0, (sum, t) => sum + t.amount);
      if (dayTotal > 0) dailyRates.add(dayTotal);
      currentDay = currentDay.add(const Duration(days: 1));
    }

    if (dailyRates.isEmpty) return 0.0;
    final mean = dailyRates.reduce((a, b) => a + b) / dailyRates.length;
    final variance = dailyRates
        .map((r) => (r - mean) * (r - mean))
        .reduce((a, b) => a + b) / dailyRates.length;
    return variance;
  }

  /// Розраховує коефіцієнт варіації депозитів.
  static double depositCoefficientOfVariation(List<_TransactionProxy> txns) {
    final rates = _calculateRates(txns);
    final avg = rates['average']!;
    if (avg <= 0) return 0.0;
    final variance = depositVariance(txns);
    return (math.sqrt(variance) / avg).clamp(0.0, 10.0);
  }

  /// Повертає найкращий день за deposit Amount за всю історію.
  static DateTime? getBestDepositDay(List<_TransactionProxy> txns) {
    if (txns.isEmpty) return null;
    DateTime? bestDay;
    double maxAmount = 0;

    final dailyTotals = <DateTime, double>{};
    for (final txn in txns) {
      final day = DateTime(txn.date.year, txn.date.month, txn.date.day);
      dailyTotals[day] = (dailyTotals[day] ?? 0.0) + txn.amount;
    }
    dailyTotals.forEach((day, amount) {
      if (amount > maxAmount) {
        maxAmount = amount;
        bestDay = day;
      }
    });
    return bestDay;
  }

  /// Повертає найгірший день за deposit Amount за всю історію.
  static DateTime? getWorstDepositDay(List<_TransactionProxy> txns) {
    if (txns.isEmpty) return null;
    DateTime? worstDay;
    double minAmount = double.infinity;

    final dailyTotals = <DateTime, double>{};
    for (final txn in txns) {
      final day = DateTime(txn.date.year, txn.date.month, txn.date.day);
      dailyTotals[day] = (dailyTotals[day] ?? 0.0) + txn.amount;
    }
    dailyTotals.forEach((day, amount) {
      if (amount > 0 && amount < minAmount) {
        minAmount = amount;
        worstDay = day;
      }
    });
    return worstDay;
  }

  /// Розраховує тренд депозитів (зростання/падіння).
  ///
  /// Повертає позитивне значення для зростаючого тренду,
  /// негативне для падаючого.
  static double calculateTrend(List<_TransactionProxy> txns) {
    if (txns.length < 7) return 0.0;

    // Порівнюємо першу і останню половину
    final mid = txns.length ~/ 2;
    final firstHalf = txns.sublist(0, mid);
    final secondHalf = txns.sublist(mid);

    final firstAvg = _calculateRates(firstHalf)['average']!;
    final secondAvg = _calculateRates(secondHalf)['average']!;
    if (firstAvg <= 0) return secondAvg > 0 ? 1.0 : 0.0;
    return ((secondAvg - firstAvg) / firstAvg).clamp(-1.0, 1.0);
  }

  /// Класифікує тренд депозитів.
  static String classifyTrend(double trendValue) {
    if (trendValue > 0.2) return 'strong_growth';
    if (trendValue > 0.05) return 'moderate_growth';
    if (trendValue > -0.05) return 'stable';
    if (trendValue > -0.2) return 'moderate_decline';
    return 'strong_decline';
  }

  // ── Розширені повідомлення ──────────────────────────────────────────

  /// Повертає деталізоване повідомлення про прогноз.
  static String getDetailedForecastMessage(ForecastResult? forecast) {
    if (forecast == null) {
      return '📊 Недостатньо даних для прогнозу. Продовжуй відкладати щодня!';
    }
    if (forecast.daysRemaining == 0) {
      return '🎉 Ціль досягнуто! Час святкувати!';
    }

    final parts = <String>[];
    parts.add('Прогноз: ${_formatDays(forecast.daysRemaining)} при '
        '${forecast.dailyAmount.toStringAsFixed(0)} грн/день');

    if (forecast.confidencePercent >= 80) {
      parts.add('(висока достовірність)');
    } else if (forecast.confidencePercent >= 50) {
      parts.add('(середня достовірність)');
    } else {
      parts.add('(низька достовірність — більше даних покращить прогноз)');
    }

    parts.add('Режим: ${forecast.mode.name}');

    return parts.join(' • ');
  }

  /// Повертає повідомлення про сезонне коригування.
  static String getSeasonalAdjustmentMessage() {
    final factor = currentSeasonalAdjustment();
    if (factor >= 1.1) {
      return '🌟 Сезонний бонус +${((factor - 1) * 100).toStringAsFixed(0)}% до XP заощаджень!';
    } else if (factor <= 0.9) {
      return '⚠️ Сезонне зниження -${((1 - factor) * 100).toStringAsFixed(0)}% — '
          'залишся вірним у своїй звичці!';
    }
    return '📊 Стандартний сезонний множник';
  }

  /// Повертає повідомлення на основі стабільності.
  static String getConsistencyMessage(double consistency) {
    if (consistency >= 0.8) {
      return '🔥 Видатна стабільність! Ти відкладаєш майже щодня!';
    } else if (consistency >= 0.6) {
      return '💪 Хороша стабільність! Спробуй ще частіше!';
    } else if (consistency >= 0.4) {
      return '🌱 Непогано — трохи частіше і результат буде кращий!';
    } else {
      return '🤔 Рідкості часті — створи звичку щоденних депозитів!';
    }
  }

  /// Повертає повідомлення на основі тренду.
  static String getTrendMessage(double trend) {
    final classification = classifyTrend(trend);
    switch (classification) {
      case 'strong_growth':
        return '📈 Сильне зростання депозитів! Так тримати!';
      case 'moderate_growth':
        return '📊 Помітне зростання — хороший напрям!';
      case 'stable':
        return '➡️ Стабільний темп — продовжуй!';
      case 'moderate_decline':
        return '📉 Депозит трохи зменшився — зверни увагу!';
      case 'strong_decline':
        return '📉 Сильне зниження! Не здавайся!';
      default:
        return '';
    }
  }

  // ── Розширені сценарії ──────────────────────────────────────────────

  /// Генерує сценарій з фіксованою сумою.
  static ScenarioResult? fixedAmountScenario({
    required double currentAmount,
    required double targetAmount,
    required double fixedDaily,
    String name = 'Фіксований',
    String description = 'Щоденна сума встановлена вручну',
  }) {
    final remaining = targetAmount - currentAmount;
    if (remaining <= 0 || fixedDaily <= 0) return null;

    final days = (remaining / fixedDaily).ceil();
    final now = DateTime.now();
    return ScenarioResult(
      name: name,
      description: description,
      dailyAmount: fixedDaily,
      estimatedDate: now.add(Duration(days: days)),
      daysRemaining: days,
    );
  }

  /// Генерує 5 сценарії з різними стратегіями.
  static List<ScenarioResult> generateDetailedScenarios({
    required double currentAmount,
    required double targetAmount,
    required List<Map<String, dynamic>> rawTransactions, {
    String? goalIdFilter,
  }) {
    final scenarios = generateScenarios(
      currentAmount: currentAmount,
      targetAmount: targetAmount,
      rawTransactions: rawTransactions,
      goalIdFilter: goalIdFilter,
    );

    // Додаємо фіксовані сценарії
    final txns = _filterDeposits(rawTransactions, goalIdFilter: goalIdFilter);
    if (txns.length >= 2) {
      final rates = _calculateRates(txns);
      final avg = rates['average']!;

      scenarios.add(fixedAmountScenario(
        currentAmount: currentAmount,
        targetAmount: targetAmount,
        fixedDaily: avg * 0.5,
        name: 'Лінивий',
        description: 'Половина звичного темпу',
      ));

      scenarios.add(fixedAmountScenario(
        currentAmount: currentAmount,
        targetAmount: targetAmount,
        fixedDaily: avg * 1.5,
        name: 'Амбітний',
        description: '1.5x звичайного темпу',
      ));

      scenarios.add(fixedAmountScenario(
        currentAmount: currentAmount,
        targetAmount: targetAmount,
        fixedDaily: avg * 2.0,
        name: 'Агресивний',
        description: 'Подвоєнний темп накопичень',
      ));
    }

    return scenarios;
  }

  /// Генерує порівняль двох сценаріїв.
  static String compareScenarios(ScenarioResult a, ScenarioResult b) {
    final diff = b.daysRemaining - a.daysRemaining;
    if (diff == 0) return 'Сценарії однакові за часом.';
    final faster = diff > 0 ? a : b;
    final slower = diff > 0 ? b : a;
    return '${faster.name} (${faster.dailyAmount.toStringAsFixed(0)} грн/день) '
        'на ${diff.abs()} днів швидше за ${slower.name} (${slower.dailyAmount.toStringAsFixed(0)} грн/день).';
  }

  // ── Валідація ──────────────────────────────────────────────────────────

  /// Валідує вхідні дані для прогнозу.
  static List<String> validateForecastInput({
    required double currentAmount,
    required double targetAmount,
    required List<Map<String, dynamic>> rawTransactions,
  }) {
    final issues = <String>[];

    if (currentAmount < 0) {
      issues.add('Поточна сума не може бути від\'ємною');
    }
    if (targetAmount <= 0) {
      issues.add('Цільова сума має бути позитивною');
    }
    if (currentAmount >= targetAmount) {
      issues.add('Поточна сума вже досягла цілі');
    }
    if (rawTransactions.length < 2) {
      issues.add('Потрібно мінімум 2 транзакції для прогнозу');
    }

    // Перевіряємо, чи транзакції містять необхідні поля
    for (int i = 0; i < rawTransactions.length; i++) {
      final t = rawTransactions[i];
      if (t['amount'] is! num) {
        issues.add('Транзакція #$i не містить поле "amount"');
      }
      if (t['date'] is! DateTime) {
        issues.add('Транзакція #$i не містить поле "date"');
      }
      if ((t['amount'] as num) <= 0) {
        issues.add('Транзакція #$i має непозитивну суму');
      }
    }

    return issues;
  }

  /// Перевіряє, чи достатньо даних для надійного прогнозу.
  static ForecastDataQuality assessDataQuality(List<_TransactionProxy> txns) {
    if (txns.isEmpty) return ForecastDataQuality.insufficient;

    final firstDate = txns.first.date;
    final lastDate = txns.last.date;
    final totalDays = lastDate.difference(firstDate).inDays;

    if (totalDays < 7) return ForecastDataQuality.poor;
    if (totalDays < 14) return ForecastDataQuality.fair;
    if (totalDays < 30) return ForecastDataQuality.good;
    if (txns.length < 5) return ForecastDataQuality.fair;
    return ForecastDataQuality.excellent;
  }

  /// Повертає розгорнуту оцінку якості даних.
  static String getDataQualityMessage(ForecastDataQuality quality) {
    switch (quality) {
      case ForecastDataQuality.insufficient:
        return '❌ Недостатньо даних для прогнозу. Зроби хоча б 2 депозити за останній тиждень.';
      case ForecastDataQuality.poor:
        return '⚠️ Мало даних (менше тижня). Прогноз може бути неточним.';
      case ForecastDataQuality.fair:
        return '📊 Наявні дані (1-2 тижні). Помірний прогноз.';
      case ForecastDataQuality.good:
        return '📊 Хороші дані (2-4 тижні). Достатньо точний прогноз.';
      case ForecastDataQuality.excellent:
        return '🎯 Відмінні дані (4+ тижні). Висока точність прогнозу!';
    }
  }

  // ── Розширені розрахунки та валідація ────────────────────────────────

  /// Розраховує середньоденне значення депозитів за останні [days] днів.
  ///
  /// [rawTransactions] — сирі транзакції.
  /// [goalIdFilter] — фільтр по ID цілі.
  static double getAverageDailyAmountLastDays(
    List<Map<String, dynamic>> rawTransactions, {
    String? goalIdFilter,
    int days = 7,
  }) {
    final txns = _filterDeposits(rawTransactions, goalIdFilter: goalIdFilter);
    if (txns.length < 2) return 0.0;
    final cutoff = DateTime.now().subtract(Duration(days: days));
    final recent = txns.where((t) => t.date.isAfter(cutoff)).toList();
    if (recent.isEmpty) return 0.0;
    final total = recent.fold<double>(0.0, (sum, t) => sum + t.amount);
    final uniqueDays = recent
        .map((t) => DateTime(t.date.year, t.date.month, t.date.day))
        .toSet()
        .length;
    return uniqueDays > 0 ? total / uniqueDays : 0.0;
  }

  /// Розраховує медіану депозитів за останні [days] днів.
  ///
  /// [rawTransactions] — сирі транзакції.
  static double getMedianDailyAmountLastDays(
    List<Map<String, dynamic>> rawTransactions, {
    String? goalIdFilter,
    int days = 7,
  }) {
    final txns = _filterDeposits(rawTransactions, goalIdFilter: goalIdFilter);
    if (txns.length < 2) return 0.0;
    final cutoff = DateTime.now().subtract(Duration(days: days));
    final recent = txns.where((t) => t.date.isAfter(cutoff)).toList();
    if (recent.isEmpty) return 0.0;

    final dailyTotals = <double>[];
    final uniqueDays = <String>{};
    for (final txn in recent) {
      final dayKey =
          '${txn.date.year}-${txn.date.month}-${txn.date.day}';
      uniqueDays.add(dayKey);
    }
    for (final dayKey in uniqueDays) {
      final parts = dayKey.split('-');
      final year = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      final day = int.parse(parts[2]);
      final dayTotal = recent
          .where((t) =>
              t.date.year == year &&
              t.date.month == month &&
              t.date.day == day)
          .fold<double>(0.0, (sum, t) => sum + t.amount);
      if (dayTotal > 0) dailyTotals.add(dayTotal);
    }
    if (dailyTotals.isEmpty) return 0.0;
    dailyTotals.sort();
    return dailyTotals[dailyTotals.length ~/ 2];
  }

  /// Розраховує загальну суму депозитів за період.
  ///
  /// [rawTransactions] — сирі транзакції.
  /// [days] — кількість днів для аналізу.
  static double getTotalDepositsLastDays(
    List<Map<String, dynamic>> rawTransactions, {
    String? goalIdFilter,
    int days = 30,
  }) {
    final txns = _filterDeposits(rawTransactions, goalIdFilter: goalIdFilter);
    if (txns.isEmpty) return 0.0;
    final cutoff = DateTime.now().subtract(Duration(days: days));
    return txns
        .where((t) => t.date.isAfter(cutoff))
        .fold<double>(0.0, (sum, t) => sum + t.amount);
  }

  /// Оцінює якість даних для прогнозу на основі кількості транзакцій.
  ///
  /// Повертає рівень якості даних.
  static ForecastDataQuality assessDataQuality(
    List<Map<String, dynamic>> rawTransactions, {
    String? goalIdFilter,
  }) {
    final txns = _filterDeposits(rawTransactions, goalIdFilter: goalIdFilter);
    if (txns.length < 2) return ForecastDataQuality.insufficient;
    final firstDate = txns.first.date;
    final lastDate = txns.last.date;
    final spanDays = lastDate.difference(firstDate).inDays;

    if (spanDays < 7) return ForecastDataQuality.poor;
    if (spanDays < 14) return ForecastDataQuality.fair;
    if (spanDays < 30) return ForecastDataQuality.good;
    return ForecastDataQuality.excellent;
  }

  /// Валідує вхідні дані для прогнозу.
  ///
  /// Повертає список проблем (порожній = валідно).
  static List<String> validateForecastInput({
    required double currentAmount,
    required double targetAmount,
    required List<Map<String, dynamic>> rawTransactions,
    String? goalIdFilter,
  }) {
    final issues = <String>[];
    if (currentAmount < 0) {
      issues.add('Поточна сума не може бути негативною: $currentAmount');
    }
    if (targetAmount <= 0) {
      issues.add('Цільова сума має бути позитивною: $targetAmount');
    }
    if (currentAmount > targetAmount) {
      issues.add('Поточна сума перевищує цільову: $currentAmount > $targetAmount');
    }
    final txns = _filterDeposits(rawTransactions, goalIdFilter: goalIdFilter);
    if (txns.length < 2) {
      issues.add('Недостатньо даних: ${txns.length} транзакцій (мінімум 2)');
    }
    return issues;
  }

  /// Розраховує кількість унікальних днів з депозитами.
  ///
  /// [rawTransactions] — сирі транзакції.
  static int getUniqueDepositDays(
    List<Map<String, dynamic>> rawTransactions, {
    String? goalIdFilter,
  }) {
    final txns = _filterDeposits(rawTransactions, goalIdFilter: goalIdFilter);
    if (txns.isEmpty) return 0;
    return txns
        .map((t) => DateTime(t.date.year, t.date.month, t.date.day))
        .toSet()
        .length;
  }

  /// Розраховує відсоток днів з депозитами від загальної кількості днів.
  ///
  /// [rawTransactions] — сирі транзакції.
  static double getDepositDayRatio(
    List<Map<String, dynamic>> rawTransactions, {
    String? goalIdFilter,
  }) {
    final txns = _filterDeposits(rawTransactions, goalIdFilter: goalIdFilter);
    if (txns.length < 2) return 0.0;
    final firstDate = txns.first.date;
    final lastDate = txns.last.date;
    final totalDays = lastDate.difference(firstDate).inDays;
    if (totalDays < 1) return 1.0;
    final uniqueDays = getUniqueDepositDays(rawTransactions, goalIdFilter: goalIdFilter);
    return (uniqueDays / totalDays).clamp(0.0, 1.0);
  }

  /// Розраховує середній депозит за день тижня.
  ///
  /// [rawTransactions] — сирі транзакції.
  static double getWeeklyAverageDaily(
    List<Map<String, dynamic>> rawTransactions, {
    String? goalIdFilter,
  }) {
    final txns = _filterDeposits(rawTransactions, goalIdFilter: goalIdFilter);
    if (txns.length < 2) return 0.0;
    final rates = _calculateRates(txns);
    return rates['average']!;
  }

  /// Розраховує мінімальний депозит, необхідний для досягнення цілі за [targetDays] днів.
  ///
  /// [currentAmount] — поточна сума.
  /// [targetAmount] — цільова сума.
  /// [targetDays] — бажана кількість днів.
  static double minimumDailyForTarget({
    required double currentAmount,
    required double targetAmount,
    required int targetDays,
  }) {
    final remaining = targetAmount - currentAmount;
    if (remaining <= 0 || targetDays <= 0) return 0.0;
    return remaining / targetDays;
  }

  /// Розраховує періодичний звіт (тижневий/місячний).
  ///
  /// [rawTransactions] — сирі транзакції.
  /// [goalIdFilter] — фільтр по ID цілі.
  static Map<String, dynamic> generatePeriodicReport(
    List<Map<String, dynamic>> rawTransactions, {
    String? goalIdFilter,
  }) {
    final txns = _filterDeposits(rawTransactions, goalIdFilter: goalIdFilter);
    final rates = _calculateRates(txns);
    final uniqueDays = getUniqueDepositDays(rawTransactions, goalIdFilter: goalIdFilter);
    final consistency = calculateConsistency(txns);
    final trend = calculateTrend(txns);
    final trendClassification = classifyTrend(trend);
    final depositCv = depositCoefficientOfVariation(txns);

    return {
      'averageDaily': rates['average'],
      'medianDaily': rates['median'],
      'minDaily': rates['min'],
      'maxDaily': rates['max'],
      'totalDeposited': txns.fold<double>(0.0, (sum, t) => sum + t.amount),
      'uniqueDepositDays': uniqueDays,
      'transactionCount': txns.length,
      'consistency': consistency,
      'trendValue': trend,
      'trendClassification': trendClassification,
      'coefficientOfVariation': depositCv,
      'dataQuality': assessDataQuality(rawTransactions, goalIdFilter: goalIdFilter).name,
    };
  }

  /// Повертає рекомендацію щодо дій на основі тренду.
  ///
  /// [trend] — значення тренду від -1.0 до 1.0.
  static String getTrendBasedRecommendation(double trend) {
    if (trend > 0.2) {
      return '📈 Ти на правильному шляху! Продовжуй у тому ж темпі!';
    } else if (trend > 0.05) {
      return '👍 Непоганий ріст. Тримай стабільність!';
    } else if (trend > -0.05) {
      return '➡️ Стабільно. Спробуй трохи частіше відкладати!';
    } else if (trend > -0.2) {
      return '⚠️ Темп трохи вповільнюється. Спробуй збільшити депозит!';
    } else {
      return '🔻 Темп зменшився. Зосередся на регулярних внесках!';
    }
  }

  /// Повертає опис рівня достовірності прогнозу.
  ///
  /// [quality] — рівень якості даних.
  static String getDataQualityDescription(ForecastDataQuality quality) {
    return switch (quality) {
      case ForecastDataQuality.insufficient:
        return '❌ Недостатньо даних — потрібно мінімум 2 транзакції.';
      case ForecastDataQuality.poor:
        return '📊 Малo даних (1-2 тижні). Прогноз приблизний.';
      case ForecastDataQuality.fair:
        return '📊 Помірна кількість даних (1-2 тижні). Помірний прогноз.';
      case ForecastDataQuality.good:
        return '📊 Наявні дані (2-4 тижні). Достатньо точний прогноз.';
      case ForecastDataQuality.excellent:
        return '🎯 Відмінні дані (4+ тижні). Висока точність прогнозу!';
    };
  }

  /// Розраховує коефіцієнт зростання (growth rate) в %.
  ///
  /// Порівнює останній тиждень з попереднім.
  static double calculateWeeklyGrowthRate(
    List<Map<String, dynamic>> rawTransactions, {
    String? goalIdFilter,
  }) {
    final txns = _filterDeposits(rawTransactions, goalIdFilter: goalIdFilter);
    if (txns.length < 4) return 0.0;
    final mid = txns.length ~/ 2;
    final firstWeek = txns.sublist(0, mid);
    final secondWeek = txns.sublist(mid);
    final firstRates = _calculateRates(firstWeek);
    final secondRates = _calculateRates(secondWeek);
    final firstAvg = firstRates['average']!;
    final secondAvg = secondRates['average']!;
    if (firstAvg <= 0) return secondAvg > 0 ? 100.0 : 0.0;
    return ((secondAvg - firstAvg) / firstAvg * 100).clamp(-100.0, 100.0);
  }

  /// Генерує порівняння поточного тижня з попереднім.
  ///
  /// [rawTransactions] — сирі транзакції.
  static String generateWeeklyComparison(
    List<Map<String, dynamic>> rawTransactions, {
    String? goalIdFilter,
  }) {
    final growthRate = calculateWeeklyGrowthRate(rawTransactions,
        goalIdFilter: goalIdFilter);
    final rates = _calculateRates(
        _filterDeposits(rawTransactions, goalIdFilter: goalIdFilter));
    final daily = rates['average']!;
    final consistency = calculateConsistency(
        _filterDeposits(rawTransactions, goalIdFilter: goalIdFilter));

    if (growthRate > 0) {
      return '📈 Цей тиждень на ${(growthRate.abs()).toStringAsFixed(1)}% '
          'продуктивніш! Середній депозит: '
          '${daily.toStringAsFixed(0)} грн/день. Стабільність: '
          '${(consistency * 100).toStringAsFixed(0)}%.';
    } else if (growthRate < 0) {
      return '📉 Тиждень на ${(growthRate.abs()).toStringAsFixed(1)}% '
          'менш продуктивний. Середній депозит: '
          '${daily.toStringAsFixed(0)} грн/день. Спробуй відновити мотивацію!';
    } else {
      return '➡️ Стабільний тиждень! Середній депозит: '
          '${daily.toStringAsFixed(0)} грн/день. Стабільність: '
          '${(consistency * 100).toStringAsFixed(0)}%.';
    }
  }

  /// Перевіряє, чи прогноз реалістичний.
  ///
  /// Вважається нереалістичним, якщо > 365 днів або < 1 дня.
  static bool isForecastRealistic(int daysRemaining) {
    if (daysRemaining < 1) return false;
    if (daysRemaining > 365) return false;
    return true;
  }

  /// Повертає попередження, якщо прогноз нереалістичний.
  ///
  /// [daysRemaining] — кількість днів до цілі.
  static String getForecastWarning(int daysRemaining) {
    if (daysRemaining > 365) {
      return '⚠️ Ціль більш ніж на рік! Спробуй збільшити щоденний депозит.';
    }
    if (daysRemaining > 180) {
      return '📅 Ціль більше ніж на півроку. Розглянь можливість прискорення.';
    }
    if (daysRemaining < 0) {
      return '❌ Помилка: від\'ємна кількість днів.';
    }
    return '';
  }

  /// Розраховує кількість днів економії при збільшенні депозиту.
  ///
  /// [currentDaily] — поточний середньоденний депозит.
  /// [newDaily] — новий запропонований щоденний депозит.
  /// [targetAmount] — цільова сума.
  /// [currentAmount] — поточна сума.
  static int? calculateDaysSaved({
    required double currentDaily,
    required double newDaily,
    required double targetAmount,
    required double currentAmount,
  }) {
    final remaining = targetAmount - currentAmount;
    if (remaining <= 0 || newDaily <= currentDaily || currentDaily <= 0) return null;
    final currentDays = (remaining / currentDaily).ceil();
    final newDays = (remaining / newDaily).ceil();
    return currentDays - newDays;
  }

  /// Розраховує оптимальну суму депозиту для досягнення цілі за вказаний час.
  ///
  /// [currentAmount] — поточна сума.
  /// [targetAmount] — цільова сума.
  /// [targetDays] — бажана кількість днів.
  static double? optimalDailyForTarget({
    required double currentAmount,
    required double targetAmount,
    required int targetDays,
  }) {
    final remaining = targetAmount - currentAmount;
    if (remaining <= 0 || targetDays <= 0) return null;
    return remaining / targetDays;
  }

  /// Генерує підсумовок прогнозу для відображення у карточці.
  ///
  /// [forecast] — результат прогнозу.
  static String generateSummaryCard(ForecastResult? forecast) {
    if (forecast == null) {
      return '📊 Недостатньо даних для прогнозу';
    }
    if (forecast.daysRemaining == 0) {
      return '🎉 Ціль досягнуто!';
    }
    return '🎯 ${_formatDays(forecast.daysRemaining)} при '
        '${forecast.dailyAmount.toStringAsFixed(0)} грн/день — '
        '${getDetailedForecastMessage(forecast)}';
  }

  /// Повертає рядок прогресу для текстового відображення.
  ///
  /// [currentAmount] — поточна сума.
  /// [targetAmount] — цільова сума.
  /// [dailyAmount] — щоденний депозит.
  static String getProgressText({
    required double currentAmount,
    required double targetAmount,
    required double dailyAmount,
  }) {
    if (targetAmount <= 0) return 'Ціль не встановлена';
    final progress = (currentAmount / targetAmount).clamp(0.0, 1.0);
    final percent = (progress * 100).toStringAsFixed(1);
    final remaining = targetAmount - currentAmount;
    if (remaining <= 0) {
      return '✅ $percent% завершено!';
    }
    final daysLeft = dailyAmount > 0 ? (remaining / dailyAmount).ceil() : 0;
    return '$percent% (${remaining.toStringAsFixed(0)} грн залишилось)';
  }

  // ── Зважена ковзка (Weighted Moving Average) ──────────────────────────

  /// Коефіцієнт згладжування для експоненціального згладжування.
  static const double _smoothingAlpha = 0.3;

  /// Обчислює експоненційно-згладжений щоденний депозит.
  ///
  /// [dailyDeposits] — список щоденних сум депозитів у хронологічному порядку.
  static double exponentialSmoothing(List<double> dailyDeposits) {
    if (dailyDeposits.isEmpty) return 0.0;
    double smoothed = dailyDeposits.first;
    for (int i = 1; i < dailyDeposits.length; i++) {
      smoothed = _smoothingAlpha * dailyDeposits[i] +
          (1 - _smoothingAlpha) * smoothed;
    }
    return smoothed;
  }

  /// Обчислює зважене середнє (N-періодне згладжування).
  ///
  /// [dailyDeposits] — список щоденних сум депозитів.
  /// [n] — розмір вікна (за замовчуванням 7).
  static double weightedMovingAverage(List<double> dailyDeposits, {int n = 7}) {
    if (dailyDeposits.isEmpty) return 0.0;
    if (dailyDeposits.length < n) n = dailyDeposits.length;

    double weightedSum = 0.0;
    double weightTotal = 0.0;
    for (int i = dailyDeposits.length - n; i < dailyDeposits.length; i++) {
      final weight = (i - (dailyDeposits.length - n) + 1).toDouble();
      weightedSum += dailyDeposits[i] * weight;
      weightTotal += weight;
    }
    return weightTotal > 0 ? weightedSum / weightTotal : 0.0;
  }

  /// Обчислює згладжений прогноз з використанням ковзки.
  ///
  /// [txns] — відфільтровані депозитні транзакції.
  /// [windowSize] — розмір вікна ковзки (за замовчуванням 7).
  static double? smoothedForecastRate(
    List<_TransactionProxy> txns, {
    int windowSize = 7,
  }) {
    if (txns.length < 2) return null;
    final firstDate = txns.first.date;
    final lastDate = txns.last.date;
    final totalDays = lastDate.difference(firstDate).inDays;
    if (totalDays < windowSize) return null;

    final dailyDeposits = <double>[];
    var currentDay = firstDate;
    while (!currentDay.isAfter(lastDate)) {
      final dayTotal = txns
          .where((t) =>
              t.date.year == currentDay.year &&
              t.date.month == currentDay.month &&
              t.date.day == currentDay.day)
          .fold<double>(0.0, (sum, t) => sum + t.amount);
      dailyDeposits.add(dayTotal);
      currentDay = currentDay.add(const Duration(days: 1));
    }

    return exponentialSmoothing(dailyDeposits);
  }

  // ── День тижня аналіз ─────────────────────────────────────────────────

  /// Назви днів тижня українською (для аналітики).
  static const List<String> _weekdayNames = [
    'Понеділок', 'Вівторок', 'Середа', 'Четвер', 'П\'ятниця', 'Субота', 'Неділя',
  ];

  /// Коефіцієнти активності для кожного дня тижня.
  static const Map<int, double> _weekdayFactors = {
    1: 0.9,  // Понеділок — після вихідних
    2: 1.0,  // Вівторок — стандарт
    3: 1.05, // Середа — середина тижня
    4: 1.0,  // Четвер — стандарт
    5: 1.1,  // П'ятниця — перед вихідними
    6: 0.7,  // Субота — вихідний
    7: 0.6,  // Неділя — вихідний
  };

  /// Повертає середній депозит за конкретний день тижня.
  ///
  /// [txns] — відфільтровані депозитні транзакції.
  /// [weekday] — день тижня (1=Пн, 7=Нд).
  static double averageDepositByWeekday(
    List<_TransactionProxy> txns,
    int weekday,
  ) {
    final dayDeposits = txns
        .where((t) => t.date.weekday == weekday)
        .map((t) => t.amount)
        .toList();
    if (dayDeposits.isEmpty) return 0.0;
    return dayDeposits.reduce((a, b) => a + b) / dayDeposits.length;
  }

  /// Повертає мапу середніх депозитів за кожен день тижня.
  static Map<int, double> weeklyDepositBreakdown(List<_TransactionProxy> txns) {
    final result = <int, double>{};
    for (int day = 1; day <= 7; day++) {
      result[day] = averageDepositByWeekday(txns, day);
    }
    return result;
  }

  /// Повертає найкращий день тижня для депозитів.
  ///
  /// Повертає номер дня тижня (1–7) або null.
  static int? getBestWeekday(List<_TransactionProxy> txns) {
    final breakdown = weeklyDepositBreakdown(txns);
    if (breakdown.isEmpty) return null;
    int bestDay = 1;
    double bestAmount = breakdown[1]!;
    breakdown.forEach((day, amount) {
      if (amount > bestAmount) {
        bestAmount = amount;
        bestDay = day;
      }
    });
    return bestDay;
  }

  /// Повертає назву найкращого дня тижня українською.
  static String getBestWeekdayMessage(List<_TransactionProxy> txns) {
    final day = getBestWeekday(txns);
    if (day == null) return 'Недостатньо даних для аналізу по днях';
    final name = _weekdayNames[day! - 1];
    final avg = averageDepositByWeekday(txns, day!);
    return 'Найкращий день: $name '
        '(середній депозит: ${avg.toStringAsFixed(0)} грн)';
  }

  // ── Святкові коригування ──────────────────────────────────────────────

  /// Дати українських свят, коли заощадження зазвичай менші.
  static const Map<String, int> _ukrainianHolidays = {
    '01-01': 0.3,  // Новий рік
    '01-07': 0.5,  // Різдво
    '03-08': 0.7,  // 8 березня
    '04-20': 0.8,  // Великдень
    '05-01': 0.7,  // Праця
    '05-09': 0.8,  // День Перемоги
    '06-28': 0.7,  // День Конституції
    '08-24': 0.7,  // День Незалежності
    '10-14': 0.8,  // День захисника
    '12-25': 0.2,  // Різдво
  };

  /// Повертає святковий коефіцієнт для дати.
  ///
  /// Повертає значення від 0.0 до 1.0.
  static double holidayCoefficient(DateTime date) {
    final key =
        '${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    return _ukrainianHolidays[key] ?? 1.0;
  }

  /// Чи є вказана дата святковим днем.
  static bool isHoliday(DateTime date) {
    return holidayCoefficient(date) < 1.0;
  }

  /// Застосовує святкове коригування до прогнозу.
  ///
  /// [dailyRate] — базовий щоденний депозит.
  /// [date] — дата для перевірки свят.
  static double applyHolidayAdjustment(double dailyRate, DateTime date) {
    return dailyRate * holidayCoefficient(date);
  }

  // ── Оцінка якості даних ──────────────────────────────────────────────

  /// Оцінює якість даних для прогнозу на основі кількості транзакцій.
  ///
  /// Повертає [ForecastDataQuality] рівень.
  static ForecastDataQuality assessDataQuality(List<_TransactionProxy> txns) {
    if (txns.length < 3) return ForecastDataQuality.insufficient;
    if (txns.length < 7) return ForecastDataQuality.poor;
    final firstDate = txns.first.date;
    final lastDate = txns.last.date;
    final totalDays = lastDate.difference(firstDate).inDays;

    if (totalDays < 7) return ForecastDataQuality.poor;
    if (totalDays >= 28) return ForecastDataQuality.excellent;
    return ForecastDataQuality.good;
  }

  /// Повертає текстовий опис якості даних.
  static String getDataQualityDescription(ForecastDataQuality quality) {
    switch (quality) {
      case ForecastDataQuality.insufficient:
        return '❌ Недостатньо даних для прогнозу (менше 3 транзакцій)';
      case ForecastDataQuality.poor:
        return '⚠️ Мало даних — прогноз може бути неточним (менше тижня активності)';
      case ForecastDataQuality.fair:
        return '📊 Помірна кількість даних — прогноз прийнятної якості';
      case ForecastDataGood:
        return '✅ Хороші дані (2–4 тижні) — прогноз достовірний';
      case ForecastDataQuality.excellent:
        return '🌟 Відмінні дані (4+ тижнів) — прогноз дуже достовірний';
    }
  }

  /// Повертає мінімальну рекомендовану кількість транзакцій для прогнозу.
  static int getMinimumTransactionCount() => 3;

  /// Повертає ідеальну кількість транзакцій для достовірного прогнозу.
  static int getIdealTransactionCount() => 30;

  // ── Валідація ────────────────────────────────────────────────────────

  /// Валідує вхідні дані для прогнозу.
  ///
  /// Повертає `null` якщо все ОК, або рядок з описом помилки.
  static String? validateForecastInput({
    required double currentAmount,
    required double targetAmount,
    required List<Map<String, dynamic>> rawTransactions,
  }) {
    if (currentAmount < 0) return 'Поточна сума не може бути від\'ємною';
    if (targetAmount <= 0) return 'Цільова сума має бути позитивною';
    if (currentAmount >= targetAmount) {
      return 'Ціль вже досягнуто — прогноз не потрібен';
    }
    if (rawTransactions.isEmpty) {
      return 'Немає транзакцій для аналізу';
    }
    final positiveCount = rawTransactions
        .where((t) => (t['amount'] as num) > 0)
        .length;
    if (positiveCount < 2) {
      return 'Потрібно мінімум 2 позитивні транзакції';
    }
    return null;
  }

  /// Чи достатньо даних для базового прогнозу.
  static bool hasEnoughData(List<Map<String, dynamic>> rawTransactions) {
    final positiveCount = rawTransactions
        .where((t) => (t['amount'] as num) > 0)
        .length;
    return positiveCount >= 2;
  }

  /// Чи достатньо даних для достовірного прогнозу.
  static bool hasReliableData(List<Map<String, dynamic>> rawTransactions) {
    final positiveCount = rawTransactions
        .where((t) => (t['amount'] as num) > 0)
        .length;
    return positiveCount >= 7;
  }

  // ── Розширена статистика ──────────────────────────────────────────────

  /// Розраховує суму депозитів за останні N днів.
  ///
  /// [txns] — відфільтровані депозитні транзакції.
  /// [days] — кількість днів.
  static double recentDepositSum(List<_TransactionProxy> txns, {int days = 7}) {
    final cutoff = DateTime.now().subtract(Duration(days: days));
    return txns
        .where((t) => t.date.isAfter(cutoff))
        .fold<double>(0.0, (sum, t) => sum + t.amount);
  }

  /// Розраховує середній депозит за останні N днів.
  static double recentAverageDeposit(List<_TransactionProxy> txns, {int days = 7}) {
    final cutoff = DateTime.now().subtract(Duration(days: days));
    final recent = txns.where((t) => t.date.isAfter(cutoff));
    if (recent.isEmpty) return 0.0;
    final total = recent.fold<double>(0.0, (sum, t) => sum + t.amount);
    final activeDays = recent
        .map((t) => DateTime(t.date.year, t.date.month, t.date.day))
        .toSet()
        .length;
    return activeDays > 0 ? total / activeDays : 0.0;
  }

  /// Порівнює поточний місяць з попереднім.
  ///
  /// Повертає відсоток зміни (позитивний = зростання).
  static double monthOverMonthGrowth(List<_TransactionProxy> txns) {
    final now = DateTime.now();
    final thisMonth = DateTime(now.year, now.month, 1);
    final lastMonth = DateTime(now.year, now.month == 1 ? now.year - 1 : now.year,
        now.month == 1 ? 12 : now.month - 1, 1);

    final thisMonthTotal = txns
        .where((t) => !t.date.isBefore(thisMonth))
        .fold<double>(0.0, (sum, t) => sum + t.amount);

    final lastMonthTotal = txns
        .where((t) => t.date.isAfter(lastMonth) && t.date.isBefore(thisMonth))
        .fold<double>(0.0, (sum, t) => sum + t.amount);

    if (lastMonthTotal <= 0) {
      return thisMonthTotal > 0 ? 100.0 : 0.0;
    }
    return ((thisMonthTotal - lastMonthTotal) / lastMonthTotal * 100)
        .clamp(-100.0, 999.0);
  }

  /// Повертає повідомлення про місячне зростання.
  static String getMonthOverMonthMessage(double growthPercent) {
    if (growthPercent > 50) {
      return '🚀 Зростання ${growthPercent.toStringAsFixed(0)}% — фантастичний результат!';
    } else if (growthPercent > 20) {
      return '📈 Зростання ${growthPercent.toStringAsFixed(0)}% — гарний прогрес!';
    } else if (growthPercent > 0) {
      return '📊 Зростання ${growthPercent.toStringAsFixed(0)}% — трохи більше!';
    } else if (growthPercent == 0) {
      return '➡️ Без змін порівняно з минулим місяцем';
    } else if (growthPercent > -20) {
      return '📉 Сниження ${growthPercent.toStringAsFixed(0)}% — спробуй відновити темп';
    } else {
      return '⚠️ Значне зниження ${growthPercent.toStringAsFixed(0)}% — не здавайся!';
    }
  }

  /// Розраховує медіану за останні N днів.
  static double recentMedianDeposit(List<_TransactionProxy> txns, {int days = 7}) {
    final cutoff = DateTime.now().subtract(Duration(days: days));
    final dailyTotals = <double>[];
    var day = cutoff;
    final now = DateTime.now();
    while (!day.isAfter(now)) {
      final dayTotal = txns
          .where((t) =>
              t.date.year == day.year &&
              t.date.month == day.month &&
              t.date.day == day.day)
          .fold<double>(0.0, (sum, t) => sum + t.amount);
      if (dayTotal > 0) dailyTotals.add(dayTotal);
      day = day.add(const Duration(days: 1));
    }
    if (dailyTotals.isEmpty) return 0.0;
    dailyTotals.sort();
    return dailyTotals[dailyTotals.length ~/ 2];
  }

  /// Розраховує стандартне відхилення за останні N днів.
  static double recentStandardDeviation(List<_TransactionProxy> txns, {int days = 7}) {
    final avg = recentAverageDeposit(txns, days: days);
    if (avg <= 0) return 0.0;
    final cutoff = DateTime.now().subtract(Duration(days: days));
    final dailyTotals = <double>[];
    var day = cutoff;
    final now = DateTime.now();
    while (!day.isAfter(now)) {
      final dayTotal = txns
          .where((t) =>
              t.date.year == day.year &&
              t.date.month == day.month &&
              t.date.day == day.day)
          .fold<double>(0.0, (sum, t) => sum + t.amount);
      if (dayTotal > 0) dailyTotals.add(dayTotal);
      day = day.add(const Duration(days: 1));
    }
    if (dailyTotals.isEmpty) return 0.0;
    final variance = dailyTotals
        .map((v) => (v - avg) * (v - avg))
        .reduce((a, b) => a + b) /
        dailyTotals.length;
    return math.sqrt(variance);
  }

  /// Розраховує коефіцієнт варіації за останні N днів.
  static double recentCoefficientOfVariation(
    List<_TransactionProxy> txns, {
    int days = 7,
  }) {
    final avg = recentAverageDeposit(txns, days: days);
    if (avg <= 0) return 0.0;
    final stdDev = recentStandardDeviation(txns, days: days);
    return (stdDev / avg).clamp(0.0, 10.0);
  }

  // ── Діагностика ─────────────────────────────────────────────────────

  /// Генерує діагностичний звіт по даних прогнозу.
  static String generateDiagnosticReport(List<_TransactionProxy> txns) {
    if (txns.isEmpty) {
      return '📊 Немає даних для аналізу';
    }
    final buffer = StringBuffer();
    buffer.writeln('=== Діагностичний звіт прогнозу ===');
    buffer.writeln('');

    // Загальна статистика
    final firstDate = txns.first.date;
    final lastDate = txns.last.date;
    final totalDays = lastDate.difference(firstDate).inDays;
    final totalDeposited = txns.fold<double>(0.0, (s, t) => s + t.amount);
    final avgDaily = totalDays > 0 ? totalDeposited / totalDays : 0;
    final rates = _calculateRates(txns);

    buffer.writeln('Період: ${firstDate.toString().substring(0, 10)} — '
        '${lastDate.toString().substring(0, 10)} ($totalDays днів)');
    buffer.writeln('Загальна сума: ${totalDeposited.toStringAsFixed(2)} грн');
    buffer.writeln('Середньо/день: ${avgDaily.toStringAsFixed(2)} грн');
    buffer.writeln('Мін/день: ${rates['min']!.toStringAsFixed(2)} грн');
    buffer.writeln('Макс/день: ${rates['max']!.toStringAsFixed(2)} грн');
    buffer.writeln('Медіана/день: ${rates['median']!.toStringAsFixed(2)} грн');
    buffer.writeln('Кількість транзакцій: ${txns.length}');
    buffer.writeln('');

    // Якість даних
    final quality = assessDataQuality(txns);
    buffer.writeln('Якість даних: ${getDataQualityDescription(quality)}');
    buffer.writeln('');

    // Стабільність
    final consistency = calculateConsistency(txns);
    buffer.writeln('Стабільність: ${(consistency * 100).toStringAsFixed(1)}%');
    final cv = depositCoefficientOfVariation(txns);
    buffer.writeln('Коефіцієнт варіації: ${cv.toStringAsFixed(2)}');

    // Тренд
    final trend = calculateTrend(txns);
    buffer.writeln('Тренд: ${classifyTrend(trend)} (${(trend * 100).toStringAsFixed(1)}%)');
    buffer.writeln('Тренд-повідлення: ${getTrendMessage(trend)}');

    // Свята
    final todayHoliday = holidayCoefficient(DateTime.now());
    buffer.writeln('Святковий коефіцієнт сьогодні: ${todayHoliday.toStringAsFixed(2)}');
    buffer.writeln('Сезонний коефіцієнт: ${currentSeasonalAdjustment().toStringAsFixed(2)}');

    return buffer.toString();
  }

  /// Повертає повну діагностичну мапу.
  static Map<String, dynamic> getDiagnosticData(List<_TransactionProxy> txns) {
    if (txns.isEmpty) return {'status': 'no_data'};

    final rates = _calculateRates(txns);
    final firstDate = txns.first.date;
    final lastDate = txns.last.date;

    return {
      'status': 'ok',
      'transactionCount': txns.length,
      'dateRange': '${firstDate.toIso8601String()} — ${lastDate.toIso8601String()}',
      'totalDeposited': txns.fold<double>(0.0, (s, t) => s + t.amount),
      'averageDaily': rates['average'],
      'minDaily': rates['min'],
      'maxDaily': rates['max'],
      'medianDaily': rates['median'],
      'dataQuality': assessDataQuality(txns).name,
      'consistency': calculateConsistency(txns),
      'coeffOfVariation': depositCoefficientOfVariation(txns),
      'trend': calculateTrend(txns),
      'trendClassification': classifyTrend(calculateTrend(txns)),
      'seasonalAdjustment': currentSeasonalAdjustment(),
      'holidayCoefficient': holidayCoefficient(DateTime.now()),
      'depositVariance': depositVariance(txns),
    };
  }
}

/// Оцінка якості даних для прогнозу.
enum ForecastDataQuality {
  /// Недостатньо даних.
  insufficient,
  /// Мало даних (менше тижня).
  poor,
  /// Помірна кількість даних.
  fair,
  /// Хороші дані (2-4 тижні).
  good,
  /// Відмінні дані (4+ тижнів).
  excellent,
}

class _TransactionProxy {
  final DateTime date;
  final double amount;

  const _TransactionProxy({required this.date, required this.amount});
}
