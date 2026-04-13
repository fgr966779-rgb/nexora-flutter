import 'dart:math' as math;
import 'package:flutter/animation.dart';

/// Режим форматування суми.
enum MoneyFormatMode {
  /// Стандартне відображення з повними числами.
  display,
  /// Компактне відображення (1.2К, 3.5М).
  compact,
  /// Формат для графіків (короткий, без валюти).
  chart,
  /// Формат для порівнянь (знак + чи -).
  comparison,
}

/// Результат округлення суми.
class RoundUpResult {
  final double originalAmount;
  final double roundedAmount;
  final double roundUpAmount;
  final String description;

  const RoundUpResult({
    required this.originalAmount,
    required this.roundedAmount,
    required this.roundUpAmount,
    required this.description,
  });
}

/// Результат розрахунку заощаджень.
class SavingsSummary {
  final double totalSaved;
  final double averageDeposit;
  final int depositCount;
  final double minDeposit;
  final double maxDeposit;
  final int totalDays;
  final double projectedMonthly;

  const SavingsSummary({
    required this.totalSaved,
    required this.averageDeposit,
    required this.depositCount,
    required this.minDeposit,
    required this.maxDeposit,
    required this.totalDays,
    required this.projectedMonthly,
  });
}

/// Порівняння двох сум грошей.
class MoneyComparison {
  final double amount1;
  final double amount2;
  final double difference;
  final double percentDifference;
  final bool isIncrease;

  const MoneyComparison({
    required this.amount1,
    required this.amount2,
    required this.difference,
    required this.percentDifference,
    required this.isIncrease,
  });
}

/// Результат форматування грошей для відображення.
class MoneyDisplayResult {
  /// Відформатований рядок для відображення.
  final String formatted;

  /// Префікс (наприклад, «₴ »).
  final String prefix;

  /// Суфікс (наприклад, « грн»).
  final String suffix;

  /// Числове значення.
  final double numericValue;

  /// Кількість знаків після коми.
  final int decimalPlaces;

  const MoneyDisplayResult({
    required this.formatted,
    required this.prefix,
    required this.suffix,
    required this.numericValue,
    this.decimalPlaces = 0,
  });
}

/// Результат multi-валютного форматування.
class MultiCurrencyResult {
  /// Сума в оригінальній валюті.
  final String originalFormatted;

  /// Сума в конвертованій валюті.
  final String convertedFormatted;

  /// Курс конвертації.
  final double exchangeRate;

  const MultiCurrencyResult({
    required this.originalFormatted,
    required this.convertedFormatted,
    required this.exchangeRate,
  });
}

/// Стан лічильника.
enum CounterState {
  /// Лічильник зупинений.
  idle,
  /// Лічильник працює (збільшення).
  counting,
  /// Лічильник працює (зменшення).
  countingDown,
  /// Лічильник завершив роботу.
  completed,
}

/// Анімація лічильника грошей.
///
/// Використовується для плавного нарощування суми на екрані.
class MoneyCounterAnimation {
  final double begin;
  final double end;
  final Duration duration;
  final int decimalPlaces;
  final String prefix;
  final String suffix;
  final Curve curve;
  final bool currencyBefore;
  final String currencySymbol;
  final bool isCountDown;
  CounterState state;

  late final Tween<double> _tween;

  MoneyCounterAnimation({
    required this.begin,
    required this.end,
    this.duration = const Duration(milliseconds: 600),
    this.decimalPlaces = 0,
    this.prefix = '',
    this.suffix = '',
    this.curve = Curves.easeOutCubic,
    this.currencyBefore = true,
    this.currencySymbol = '₴',
    this.isCountDown = false,
    this.state = CounterState.idle,
  }) {
    _tween = Tween<double>(begin: begin, end: end);
  }

  factory MoneyCounterAnimation.countUp({
    required double begin,
    required double end,
    Duration duration = const Duration(milliseconds: 600),
    int decimalPlaces = 0,
    String currencySymbol = '₴',
    bool currencyBefore = true,
    Curve curve = Curves.easeOutCubic,
  }) {
    return MoneyCounterAnimation(
      begin: begin,
      end: end,
      duration: duration,
      decimalPlaces: decimalPlaces,
      currencySymbol: currencySymbol,
      currencyBefore: currencyBefore,
      curve: curve,
      isCountDown: false,
      state: CounterState.counting,
    );
  }

  factory MoneyCounterAnimation.countDown({
    required double begin,
    required double end,
    Duration duration = const Duration(milliseconds: 600),
    int decimalPlaces = 0,
    String currencySymbol = '₴',
    bool currencyBefore = true,
    Curve curve = Curves.easeInCubic,
  }) {
    return MoneyCounterAnimation(
      begin: begin,
      end: end,
      duration: duration,
      decimalPlaces: decimalPlaces,
      currencySymbol: currencySymbol,
      currencyBefore: currencyBefore,
      curve: curve,
      isCountDown: true,
      state: CounterState.countingDown,
    );
  }

  double currentValue(double t) {
    final curvedT = curve.transform(t.clamp(0.0, 1.0));
    return _tween.transform(curvedT);
  }

  /// Повертає результат форматування з повною інформацією.
  MoneyDisplayResult formatResult(double t) {
    final value = currentValue(t);

    String formatted;
    if (decimalPlaces == 0) {
      formatted = MoneyFormatter.formatWithThousands(value.round());
    } else {
      formatted = MoneyFormatter.formatWithThousandsDecimal(value, decimalPlaces);
    }

    String prefix = this.prefix;
    String suffix = this.suffix;

    if (this.prefix.isEmpty && this.suffix.isEmpty) {
      if (currencyBefore) {
        prefix = '$currencySymbol ';
      } else {
        suffix = ' $currencySymbol';
      }
    }

    return MoneyDisplayResult(
      formatted: '$prefix$formatted$suffix',
      prefix: prefix,
      suffix: suffix,
      numericValue: value,
      decimalPlaces: decimalPlaces,
    );
  }

  String format(double t) => formatResult(t).formatted;

  String _applyCurrency(String formattedNumber) {
    if (prefix.isNotEmpty || suffix.isNotEmpty) {
      return '$prefix$formattedNumber$suffix';
    }
    if (currencyBefore) return '$currencySymbol $formattedNumber';
    return '$formattedNumber $currencySymbol';
  }

  /// Повертає значення прогресу анімації (0.0–1.0) за часом.
  double getProgress(double t) => t.clamp(0.0, 1.0);

  /// Повертає залишок часу анімації.
  double getRemainingTime(double t) => (1.0 - t.clamp(0.0, 1.0)) * duration.inMilliseconds;
}

/// Утиліти форматування грошових сум.
class MoneyFormatter {
  static String formatDisplay(
    double value, {
    String currencySymbol = '₴',
    int decimalPlaces = 0,
    bool currencyBefore = true,
  }) {
    String formatted;
    if (decimalPlaces == 0) {
      formatted = formatWithThousands(value.round());
    } else {
      formatted = formatWithThousandsDecimal(value, decimalPlaces);
    }

    if (currencyBefore) return '$currencySymbol $formatted';
    return '$formatted $currencySymbol';
  }

  static String formatCompact(
    double value, {
    String currencySymbol = '₴',
    int decimalPlaces = 1,
  }) {
    final absValue = value.abs();
    String suffix;

    if (absValue >= 1000000) {
      suffix = 'М';
      return '$currencySymbol${(absValue / 1000000).toStringAsFixed(decimalPlaces)}$suffix';
    } else if (absValue >= 1000) {
      suffix = 'К';
      return '$currencySymbol${(absValue / 1000).toStringAsFixed(decimalPlaces)}$suffix';
    } else if (absValue >= 1) {
      return '$currencySymbol${absValue.toStringAsFixed(decimalPlaces)}';
    } else {
      return '$currencySymbol${absValue.toStringAsFixed(2)}';
    }
  }

  static String formatForChart(double value) {
    final absValue = value.abs();
    if (absValue >= 1000000) {
      return '${(absValue / 1000000).toStringAsFixed(1)}М';
    } else if (absValue >= 1000) {
      return '${(absValue / 1000).toStringAsFixed(1)}К';
    }
    return absValue.round().toString();
  }

  static String formatComparison(double value, {int decimalPlaces = 0}) {
    final isPositive = value >= 0;
    final absValue = value.abs();

    String formatted;
    if (decimalPlaces == 0) {
      formatted = formatWithThousands(absValue.round());
    } else {
      formatted = formatWithThousandsDecimal(absValue, decimalPlaces);
    }

    final sign = isPositive ? '+' : '-';
    return '$sign $formatted';
  }

  static String formatWithThousands(int value) {
    final buffer = StringBuffer();
    final negative = value < 0;
    final absValue = value.abs();

    final digits = absValue.toString().split('');
    final reversed = digits.reversed.toList();

    for (int i = 0; i < reversed.length; i++) {
      if (i > 0 && i % 3 == 0) buffer.write(' ');
      buffer.write(reversed[i]);
    }

    final result = buffer.toString().split('').reversed.join();
    return negative ? '-$result' : result;
  }

  static String formatWithThousandsDecimal(double value, int places) {
    final negative = value < 0;
    final absValue = value.abs();

    final factor = math.pow(10, places).toDouble();
    final rounded = (absValue * factor).round() / factor;

    final parts = rounded.toStringAsFixed(places).split('.');
    final integerPart = int.parse(parts[0]);
    final formattedInteger = formatWithThousands(integerPart);
    final decimalPart = parts[1];

    final result = '$formattedInteger.$decimalPart';
    return negative ? '-$result' : result;
  }

  /// Форматує суму з точністю до копійок.
  ///
  /// Автоматично визначає кількість знаків після коми.
  static String formatAutoDecimal(double value) {
    if (value == value.roundToDouble()) {
      return formatWithThousands(value.round());
    }
    return formatWithThousandsDecimal(value, 2);
  }

  /// Форматує суму з комою як роздільником цілих та копійок.
  ///
  /// Приклад: `1234.5` → `"1 234,5"`
  static String formatShortDecimal(double value) {
    final parts = value.toStringAsFixed(1).split('.');
    final integerPart = formatWithThousands(int.parse(parts[0]));
    return '$integerPart,${parts[1]}';
  }
}

/// Калькулятор фінансових метрик.
class MoneyCalculator {
  // ── Середні значення ────────────────────────────────────────────────

  static double averageDeposit(List<double> deposits) {
    if (deposits.isEmpty) return 0.0;
    return deposits.reduce((a, b) => a + b) / deposits.length;
  }

  static double medianDeposit(List<double> deposits) {
    if (deposits.isEmpty) return 0.0;
    final sorted = List<double>.from(deposits)..sort();
    final mid = sorted.length ~/ 2;
    if (sorted.length % 2 == 1) return sorted[mid];
    return (sorted[mid - 1] + sorted[mid]) / 2;
  }

  static double averageDailyDeposit(double totalSaved, int totalDays) {
    if (totalDays <= 0) return 0.0;
    return totalSaved / totalDays;
  }

  static double averageWeeklyDeposit(double totalSaved, int totalDays) {
    if (totalDays <= 0) return 0.0;
    return totalSaved / (totalDays / 7);
  }

  static double averageMonthlyDeposit(double totalSaved, int totalDays) {
    if (totalDays <= 0) return 0.0;
    return totalSaved / (totalDays / 30);
  }

  /// Медіана депозитів за останні N днів.
  static double recentMedian(List<double> deposits, {int lastN = 7}) {
    if (deposits.isEmpty) return 0.0;
    final recent = deposits.length > lastN
        ? deposits.sublist(deposits.length - lastN)
        : deposits;
    return medianDeposit(recent);
  }

  // ── Дисперсія ────────────────────────────────────────────────────────

  /// Стандартне відхилення депозитів.
  static double depositStdDeviation(List<double> deposits) {
    if (deposits.length < 2) return 0.0;
    final avg = averageDeposit(deposits);
    final variance =
        deposits.map((d) => (d - avg) * (d - avg)).reduce((a, b) => a + b) /
            (deposits.length - 1);
    return math.sqrt(variance);
  }

  /// Діапазон депозитів (мін – макс).
  static double depositRange(List<double> deposits) {
    if (deposits.isEmpty) return 0.0;
    final sorted = List<double>.from(deposits)..sort();
    return sorted.last - sorted.first;
  }

  /// Коефіцієнт варіації (CV) депозитів.
  static double depositCoefficientOfVariation(List<double> deposits) {
    final avg = averageDeposit(deposits);
    if (avg == 0) return 0.0;
    return depositStdDeviation(deposits) / avg;
  }

  // ── Проекції ─────────────────────────────────────────────────────────

  static double projectSavings(
    double currentSaved,
    double dailyRate,
    int projectionDays,
  ) {
    return currentSaved + (dailyRate * projectionDays);
  }

  static int? projectDaysToGoal({
    required double currentSaved,
    required double targetAmount,
    required double dailyRate,
  }) {
    final remaining = targetAmount - currentSaved;
    if (remaining <= 0) return 0;
    if (dailyRate <= 0) return null;
    return (remaining / dailyRate).ceil();
  }

  /// Проектує дату досягнення цілі з інфляційною корекцією.
  ///
  /// [inflationRate] — річний відсоток інфляції (наприклад, 0.10 = 10%).
  static double? projectWithInflation({
    required double currentSaved,
    required double targetAmount,
    required double dailyRate,
    double inflationRate = 0.0,
  }) {
    if (dailyRate <= 0) return null;

    final remaining = targetAmount - currentSaved;
    if (remaining <= 0) return 0.0;

    final adjustedRate = dailyRate * (1 + inflationRate / 365);
    return remaining / adjustedRate;
  }

  static SavingsSummary calculateSummary({
    required double totalSaved,
    required List<double> deposits,
    required int totalDays,
  }) {
    if (deposits.isEmpty) {
      return SavingsSummary(
        totalSaved: totalSaved,
        averageDeposit: 0,
        depositCount: 0,
        minDeposit: 0,
        maxDeposit: 0,
        totalDays: totalDays,
        projectedMonthly: 0,
      );
    }

    final sorted = List<double>.from(deposits)..sort();
    final avgDaily = totalDays > 0 ? totalSaved / totalDays : 0;

    return SavingsSummary(
      totalSaved: totalSaved,
      averageDeposit: deposits.reduce((a, b) => a + b) / deposits.length,
      depositCount: deposits.length,
      minDeposit: sorted.first,
      maxDeposit: sorted.last,
      totalDays: totalDays,
      projectedMonthly: avgDaily * 30,
    );
  }

  // ── Ставка заощаджень ──────────────────────────────────────────────

  static double savingsRate(double current, double target) {
    if (target <= 0) return 0.0;
    return (current / target).clamp(0.0, 1.0);
  }

  static int savingsRatePercent(double current, double target) {
    return (savingsRate(current, target) * 100).round();
  }

  /// Кількість днів для досягнення цілі при поточному темпі.
  static int daysToGoal(double current, double target, double dailyRate) {
    if (dailyRate <= 0) return -1;
    final remaining = target - current;
    if (remaining <= 0) return 0;
    return (remaining / dailyRate).ceil();
  }

  // ── Округлення (round-up) ───────────────────────────────────────────

  static RoundUpResult roundUpAmount(
    double amount, {
    int roundTo = 10,
    String currencySymbol = '₴',
  }) {
    final rounded = (amount / roundTo).ceil() * roundTo;
    final difference = rounded - amount;

    if (difference <= 0) {
      return RoundUpResult(
        originalAmount: amount,
        roundedAmount: amount,
        roundUpAmount: 0,
        description: 'Сума вже кратна $roundTo $currencySymbol',
      );
    }

    return RoundUpResult(
      originalAmount: amount,
      roundedAmount: rounded,
      roundUpAmount: difference,
      description:
          '${_formatMoney(amount)} → ${_formatMoney(rounded)}: +${_formatMoney(difference)} у скарбничку! 🐷',
    );
  }

  /// Округлення до найближчого кратного значення (автоматичний вибір).
  static RoundUpResult smartRoundUp(double amount, {String currencySymbol = '₴'}) {
    if (amount < 50) return roundUpAmount(amount, roundTo: 10, currencySymbol: currencySymbol);
    if (amount < 500) return roundUpAmount(amount, roundTo: 50, currencySymbol: currencySymbol);
    return roundUpAmount(amount, roundTo: 100, currencySymbol: currencySymbol);
  }

  static double monthlyRoundUpProjection({
    required double dailyAverage,
    required double averageRoundUp,
    int days = 30,
  }) {
    return dailyAverage * averageRoundUp * days;
  }

  /// Потенційні заощадження від round-up за тиждень.
  static RoundUpResult weeklyRoundUp({
    required double averageAmount,
    required int transactionsPerWeek,
    String currencySymbol = '₴',
  }) {
    final weeklyTotal = averageAmount * transactionsPerWeek;
    return roundUpAmount(weeklyTotal, roundTo: 10, currencySymbol: currencySymbol);
  }

  // ── Порівняння ──────────────────────────────────────────────────────

  static MoneyComparison compare(double amount1, double amount2) {
    final difference = amount2 - amount1;
    final isIncrease = difference > 0;

    double percentDifference;
    if (amount1 == 0) {
      percentDifference = amount2 > 0 ? 100.0 : 0.0;
    } else {
      percentDifference = (difference / amount1.abs()) * 100;
    }

    return MoneyComparison(
      amount1: amount1,
      amount2: amount2,
      difference: difference,
      percentDifference: percentDifference,
      isIncrease: isIncrease,
    );
  }

  static String getComparisonMessage(MoneyComparison comparison) {
    if (comparison.difference == 0) {
      return '📊 Сума не змінилась';
    }

    final formattedDiff =
        MoneyFormatter.formatWithThousands(comparison.difference.abs().round());
    final formattedPercent =
        comparison.percentDifference.abs().toStringAsFixed(1);

    if (comparison.isIncrease) {
      return '📈 Збільшення на $formattedDiff грн (+$formattedPercent%)';
    } else {
      return '📉 Зменшення на $formattedDiff грн (-$formattedPercent%)';
    }
  }

  /// Повертає іконку тренду (стрілка).
  static String getTrendIcon(double current, double previous) {
    if (previous == 0) return '→';
    if (current > previous) return '↑';
    if (current < previous) return '↓';
    return '→';
  }

  /// Повертає колір тренду.
  static String getTrendColor(double current, double previous) {
    if (previous == 0) return ' нейтральний';
    final diff = ((current - previous) / previous * 100).abs();
    if (diff < 1) return ' стабільний';
    if (diff < 5) return ' невелике зростання';
    return ' значне зростання';
  }

  // ── Повідомлення ───────────────────────────────────────────────────────

  static String getMoneyMessage({
    required double current,
    required double target,
  }) {
    final percent = savingsRatePercent(current, target);

    if (percent >= 100) {
      return '🎉 Мета досягнута! Ти зібрав ${_formatMoney(current)}! Час ставити нову ціль!';
    } else if (percent >= 75) {
      final remaining = target - current;
      return '🔥 Майже там! Залишилось ${_formatMoney(remaining)} — ти на фінішній прямій!';
    } else if (percent >= 50) {
      final remaining = target - current;
      return '💪 Половина пройдено! Ще ${_formatMoney(remaining)} — ти впораєшся!';
    } else if (percent >= 25) {
      final remaining = target - current;
      return '🚀 Чверть цілі досягнуто! ${_formatMoney(remaining)} — вперед!';
    } else if (percent >= 10) {
      return '🌱 Хороший початок! ${percent}% з ${_formatMoney(target)} вже накопичено!';
    } else if (current > 0) {
      return '🎯 Перший крок зроблено! ${_formatMoney(current)} з ${_formatMoney(target)} — продовжуй!';
    } else {
      return '✨ Час починати! Твоя ціль — ${_formatMoney(target)}. Кожна гривня важлива!';
    }
  }

  static String getRateMessage(double dailyRate) {
    if (dailyRate <= 0) {
      return '💤 Почни відкладати — навіть 10 грн/день зроблять різницю!';
    } else if (dailyRate < 20) {
      return '🌱 Твій темп: ${_formatMoney(dailyRate)}/день. Спробуй трохи збільшити!';
    } else if (dailyRate < 50) {
      return '🚀 Твій темп: ${_formatMoney(dailyRate)}/день. Хороший прогрес!';
    } else if (dailyRate < 100) {
      return '💪 Твій темп: ${_formatMoney(dailyRate)}/день. Вражає!';
    } else {
      return '👑 Твій темп: ${_formatMoney(dailyRate)}/день. Фінансовий чемпіон!';
    }
  }

  /// Повертає повідомлення для порожньої цілі.
  static String getEmptyGoalMessage() {
    return '💰 У тебе ще немає цілей. Створи першу ціль та почни заощаджувати! 🌟';
  }

  /// Повертає повідомлення для першого внеску.
  static String getFirstDepositMessage(double amount) {
    return '🎉 Перший внесок! ${_formatMoney(amount)} — чудове початок! Шлях до мрії починається тут!';
  }

  // ── Multi-currency ───────────────────────────────────────────────────

  /// Конвертує суму з однієї валюти в іншу.
  static MultiCurrencyResult convertCurrency({
    required double amount,
    required double exchangeRate,
    String fromSymbol = '₴',
    String toSymbol = '\$',
  }) {
    final converted = amount * exchangeRate;
    return MultiCurrencyResult(
      originalFormatted: MoneyFormatter.formatDisplay(
        amount,
        currencySymbol: fromSymbol,
      ),
      convertedFormatted: MoneyFormatter.formatDisplay(
        converted,
        currencySymbol: toSymbol,
        decimalPlaces: 2,
      ),
      exchangeRate: exchangeRate,
    );
  }

  // ── Допоміжні методи ──────────────────────────────────────────────────

  static String _formatMoney(double amount) {
    return MoneyFormatter.formatWithThousands(amount.round());
  }

  // ── Валідація ──────────────────────────────────────────────────────

  /// Перевіряє, чи є сума валідною (додатне число, не NaN, не Infinity).
  static bool isValidAmount(double amount) {
    if (amount.isNaN || amount.isInfinite) return false;
    return amount >= 0;
  }

  /// Перевіряє, чи валідний відсоток (0–100).
  static bool isValidPercentage(double percentage) {
    return !percentage.isNaN &&
        !percentage.isInfinite &&
        percentage >= 0 &&
        percentage <= 100;
  }

  /// Перевіряє, чи валідний курс конвертації.
  static bool isValidExchangeRate(double rate) {
    return !rate.isNaN && !rate.isInfinite && rate > 0;
  }

  /// Валідує масив депозитів (усі елементи додатні).
  static bool validateDeposits(List<double> deposits) {
    if (deposits.isEmpty) return false;
    return deposits.every((d) => isValidAmount(d) && d > 0);
  }

  /// Валідує параметри цілі (ціль > 0, поточна сума ≥ 0).
  static ({bool valid, String? error}) validateGoal({
    required double target,
    required double current,
  }) {
    if (!isValidAmount(target)) {
      return (valid: false, error: 'Ціль має бути невід\'ємним числом');
    }
    if (target <= 0) {
      return (valid: false, error: 'Ціль має бути більшою за 0');
    }
    if (!isValidAmount(current)) {
      return (valid: false, error: 'Поточна сума має бути невід\'ємною');
    }
    if (current > target) {
      return (valid: false, error: 'Поточна сума не може перевищувати ціль');
    }
    return (valid: true, error: null);
  }

  // ── Відсоткові розрахунки ───────────────────────────────────────────

  /// Обчислює відсоток від суми.
  static double percentageOf(double amount, double percent) {
    if (!isValidPercentage(percent)) return 0.0;
    return amount * (percent / 100);
  }

  /// Обчислює, який відсоток становить [part] від [total].
  static double percentageOfTotal(double part, double total) {
    if (total <= 0) return 0.0;
    return (part / total) * 100;
  }

  /// Застосовує знижку до суми, повертає нову суму.
  static double applyDiscount(double amount, double discountPercent) {
    if (!isValidPercentage(discountPercent)) return amount;
    return amount * (1 - discountPercent / 100);
  }

  /// Обчислює суму з податком.
  static double addTax(double amount, double taxPercent) {
    if (!isValidPercentage(taxPercent)) return amount;
    return amount * (1 + taxPercent / 100);
  }

  /// Виділяє податок із суми (reverse tax calculation).
  static double extractTax(double amountWithTax, double taxPercent) {
    if (!isValidPercentage(taxPercent) || taxPercent == 0) return 0.0;
    return amountWithTax - (amountWithTax / (1 + taxPercent / 100));
  }

  // ── Складні відсотки ────────────────────────────────────────────────

  /// Обчислює майбутню вартість зі складними відсотками.
  ///
  /// [principal] — початкова сума
  /// [rate] — річна відсоткова ставка
  /// [years] — кількість років
  /// [compoundsPerYear] — кількість нарахувань на рік (12 — щомісяця)
  static double compoundInterest({
    required double principal,
    required double rate,
    required int years,
    int compoundsPerYear = 12,
  }) {
    if (principal <= 0 || years <= 0) return principal;
    final r = rate / 100;
    final n = compoundsPerYear.toDouble();
    final factor = 1 + r / n;
    return principal * math.pow(factor, n * years);
  }

  /// Обчислює суму регулярних депозитів зі складними відсотками.
  ///
  /// [monthlyDeposit] — щомісячний внесок
  /// [rate] — річна ставка
  /// [months] — кількість місяців
  static double futureValueOfAnnuity({
    required double monthlyDeposit,
    required double rate,
    required int months,
  }) {
    if (monthlyDeposit <= 0 || months <= 0) return 0.0;
    final r = rate / 100 / 12;
    if (r == 0) return monthlyDeposit * months;
    return monthlyDeposit * ((math.pow(1 + r, months) - 1) / r);
  }

  // ── Кредитні розрахунки ─────────────────────────────────────────────

  /// Обчислює щомісячний платіж за аннуїтетною схемою.
  ///
  /// [loanAmount] — сума кредиту
  /// [annualRate] — річна відсоткова ставка
  /// [termMonths] — термін у місяцях
  static double calculateMonthlyPayment({
    required double loanAmount,
    required double annualRate,
    required int termMonths,
  }) {
    if (loanAmount <= 0 || termMonths <= 0) return 0.0;
    final r = annualRate / 100 / 12;
    if (r == 0) return loanAmount / termMonths;
    final factor = math.pow(1 + r, termMonths);
    return loanAmount * (r * factor) / (factor - 1);
  }

  /// Обчислює загальну суму виплат за кредит.
  static double totalLoanPayment({
    required double loanAmount,
    required double annualRate,
    required int termMonths,
  }) {
    return calculateMonthlyPayment(
      loanAmount: loanAmount,
      annualRate: annualRate,
      termMonths: termMonths,
    ) * termMonths;
  }

  /// Обчислює переплату за кредит (відсотки).
  static double loanOverpayment({
    required double loanAmount,
    required double annualRate,
    required int termMonths,
  }) {
    return totalLoanPayment(
      loanAmount: loanAmount,
      annualRate: annualRate,
      termMonths: termMonths,
    ) - loanAmount;
  }

  // ── Бюджетний аналіз ────────────────────────────────────────────────

  /// Розподіл бюджету по категоріях (50/30/20 правило).
  ///
  /// Повертає мапу з рекомендуемими частинами бюджету.
  static Map<String, double> budgetAllocation503020(double monthlyIncome) {
    return {
      'needs': monthlyIncome * 0.50, // 50% — потреби
      'wants': monthlyIncome * 0.30, // 30% — бажання
      'savings': monthlyIncome * 0.20, // 20% — заощадження
    };
  }

  /// Обчислює фонд екстрених витрат (рекомендація: 3–6 місяців витрат).
  static double emergencyFundTarget({
    required double monthlyExpenses,
    int monthsOfCoverage = 6,
  }) {
    return monthlyExpenses * monthsOfCoverage;
  }

  /// Обчислює прогрес фонду екстрених витрат у відсотках.
  static double emergencyFundProgress({
    required double currentSavings,
    required double monthlyExpenses,
    int monthsOfCoverage = 6,
  }) {
    final target = emergencyFundTarget(
      monthlyExpenses: monthlyExpenses,
      monthsOfCoverage: monthsOfCoverage,
    );
    if (target <= 0) return 0.0;
    return (currentSavings / target * 100).clamp(0.0, 100.0);
  }

  /// Співвідношення боргу до доходу.
  static double debtToIncomeRatio({
    required double totalDebtPayments,
    required double monthlyIncome,
  }) {
    if (monthlyIncome <= 0) return double.infinity;
    return (totalDebtPayments / monthlyIncome) * 100;
  }

  /// Оцінка фінансового здоров'я (0–100).
  ///
  /// Базується на: заощадженнях, відсутності боргів, регулярних депозитах.
  static int financialHealthScore({
    required double savingsRate,
    required double debtToIncome,
    required bool hasEmergencyFund,
    required bool hasRegularDeposits,
  }) {
    int score = 0;

    // Заощадження (0–30 балів)
    score += (savingsRate * 0.3).clamp(0, 30).round();

    // Відсутність боргів (0–30 балів)
    if (debtToIncome <= 15) {
      score += 30;
    } else if (debtToIncome <= 30) {
      score += 20;
    } else if (debtToIncome <= 43) {
      score += 10;
    }

    // Фонд екстрених витрат (0–20 балів)
    if (hasEmergencyFund) score += 20;

    // Регулярність депозитів (0–20 балів)
    if (hasRegularDeposits) score += 20;

    return score.clamp(0, 100);
  }

  /// Аналіз витрат по категоріях з визначенням найбільшої.
  static ({String? largestCategory, double largestAmount, double totalSpent})
      analyzeSpending(Map<String, double> categories) {
    if (categories.isEmpty) {
      return (largestCategory: null, largestAmount: 0, totalSpent: 0);
    }

    double totalSpent = 0;
    String? largestCategory;
    double largestAmount = 0;

    categories.forEach((category, amount) {
      totalSpent += amount;
      if (amount > largestAmount) {
        largestAmount = amount;
        largestCategory = category;
      }
    });

    return (
      largestCategory: largestCategory,
      largestAmount: largestAmount,
      totalSpent: totalSpent,
    );
  }

  // ── Розбивка цілі ───────────────────────────────────────────────────

  /// Розбиває ціль на щоденні, щотижневі та щомісячні внески.
  static Map<String, double> goalBreakdown({
    required double target,
    required int daysRemaining,
  }) {
    if (target <= 0 || daysRemaining <= 0) {
      return {'daily': 0, 'weekly': 0, 'monthly': 0};
    }

    final daily = target / daysRemaining;
    final weeks = daysRemaining / 7;
    final months = daysRemaining / 30;

    return {
      'daily': daily,
      'weekly': daily * 7,
      'monthly': daily * 30,
      'weeklyAvg': weeks > 0 ? target / weeks : target,
      'monthlyAvg': months > 0 ? target / months : target,
    };
  }

  // ── Порівняльний аналіз періодів ─────────────────────────────────────

  /// Порівнює два періоди заощаджень.
  static MoneyComparison comparePeriods({
    required double period1Total,
    required double period2Total,
    required int period1Days,
    required int period2Days,
  }) {
    // Нормалізація до 30 днів для чесного порівняння
    final normalized1 =
        period1Days > 0 ? period1Total / period1Days * 30 : 0;
    final normalized2 =
        period2Days > 0 ? period2Total / period2Days * 30 : 0;

    return compare(normalized1, normalized2);
  }

  // ── Логування (simple structured logging) ───────────────────────────

  /// Генерує структурований лог-запис для фінансової операції.
  static Map<String, dynamic> createLogEntry({
    required String action,
    required double amount,
    double? previousBalance,
    double? newBalance,
    String? currency,
    String? goalId,
    Map<String, dynamic>? extra,
  }) {
    return {
      'timestamp': DateTime.now().toIso8601String(),
      'action': action,
      'amount': amount,
      'previousBalance': previousBalance,
      'newBalance': newBalance,
      'currency': currency ?? '₴',
      'goalId': goalId,
      'isValid': isValidAmount(amount),
      ...?extra,
    };
  }

  /// Лог-звіт за період.
  static Map<String, dynamic> createPeriodReport({
    required double startBalance,
    required double endBalance,
    required int days,
    required int transactionCount,
  }) {
    final netChange = endBalance - startBalance;
    final dailyAvg = days > 0 ? netChange / days : 0;

    return {
      'reportDate': DateTime.now().toIso8601String(),
      'period': '${days} days',
      'startBalance': startBalance,
      'endBalance': endBalance,
      'netChange': netChange,
      'dailyAverage': dailyAvg,
      'transactionCount': transactionCount,
      'isGrowth': netChange > 0,
      'growthPercent': startBalance > 0
          ? ((netChange / startBalance) * 100).toStringAsFixed(2)
          : 'N/A',
    };
  }
}
