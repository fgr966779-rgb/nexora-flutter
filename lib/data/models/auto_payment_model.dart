import 'package:intl/intl.dart';
import 'package:nexora/core/constants/app_enums.dart';
import 'package:nexora/data/models/auto_payment_model.dart';

/// Статус виконання платежу.
enum PaymentExecutionStatus {
  /// Успішно виконано.
  success,

  /// Помилка при виконанні (недостатньо коштів, помилка мережі).
  failed,

  /// Відхилено через ліміт.
  limitReached,

  /// Відхилено користувачем.
  userCancelled;

  /// Відхилено через відсутність коштів.
  insufficientFunds;

  /// Україномовна назва.
  String get displayNameUA {
    switch (this) {
      case PaymentExecutionStatus.success: return 'Виконано';
      case PaymentExecutionStatus.failed: return 'Помилка';
      case PaymentExecutionStatus.limitReached: return 'Ліміт досягнуто';
      case PaymentExecutionStatus.userCancelled: return 'Скасовано';
      case PaymentExecutionStatus.insufficientFunds: return 'Недостатньо коштів';
    }
  }

  /// Емодзі статусу.
  String get emoji {
    switch (this) {
      case PaymentExecutionStatus.success: return '✅';
      case PaymentExecutionStatus.failed: return '❌';
      case PaymentExecutionStatus.limitReached: return '🛑';
      case PaymentExecutionStatus.userCancelled: return '🚫';
      case PaymentExecutionStatus.insufficientFunds: return '💸';
    }
  }
}

/// Статистика виконання платежу для аналітики.
class PaymentExecutionRecord {
  final String paymentId;
  final DateTime executedAt;
  final double amount;
  final PaymentExecutionStatus status;
  final String? errorMessage;

  PaymentExecutionRecord({
    required this.paymentId,
    required this.executedAt,
    required this.amount,
    required this.status,
    this.errorMessage,
  });

  Map<String, dynamic> toJson() => {
    'paymentId': paymentId,
    'executedAt': executedAt.toIso8601String(),
    'amount': amount,
    'status': status.name,
    'errorMessage': errorMessage,
  };
}

/// Модель автоматичного платежу (регулярний внесок до цілі).
///
/// AutoPayment дозволяє користувачу налаштувати регулярні автоматичні
/// внески до цілі накопичення. Платежі можуть бути щоденними, щотижневими,
/// раз на два тижні або щомісячними. Модель відстежує кількість виконань,
/// загальну суму виплат, розраховує наступну дату виконання та проекції.
class AutoPayment {
  final String id;
  final String goalId;
  final double amount;
  final Frequency frequency;
  final int? dayOfWeek;
  final int? dayOfMonth;
  bool isEnabled;
  final bool onlyIfFundsAvailable;
  final double? limitPerPeriod;
  final DateTime createdAt;
  int timesExecuted;
  double totalPaid;
  DateTime? pausedAt;
  DateTime? lastExecutedAt;
  PaymentExecutionStatus? lastExecutionStatus;
  int consecutiveFailures;
  double totalFailedAmount;
  String? description;
  int totalScheduled;
  int totalSkipped;

  AutoPayment({
    required this.id,
    required this.goalId,
    required this.amount,
    required this.frequency,
    this.dayOfWeek,
    this.dayOfMonth,
    this.isEnabled = true,
    this.onlyIfFundsAvailable = false,
    this.limitPerPeriod,
    required this.createdAt,
    this.timesExecuted = 0,
    this.totalPaid = 0,
    this.pausedAt,
    this.lastExecutedAt,
    this.lastExecutionStatus,
    this.consecutiveFailures = 0,
    this.totalFailedAmount = 0,
    this.description,
    this.totalScheduled = 0,
    this.totalSkipped = 0,
  });

  // ─── Обчислювані властивості ───────────────────────────────────────

  /// Чи потрібно сьогодні виконати платіж.
  bool get shouldExecuteToday {
    if (!isEnabled) return false;
    final today = DateTime.now();
    switch (frequency) {
      case Frequency.daily:
        return true;
      case Frequency.weekly:
        return dayOfWeek != null && today.weekday == dayOfWeek;
      case Frequency.biweekly:
        if (dayOfWeek == null) return false;
        final daysSinceCreation = today.difference(createdAt).inDays;
        final weeksSinceCreation = daysSinceCreation ~/ 7;
        return today.weekday == dayOfWeek && weeksSinceCreation % 2 == 0;
      case Frequency.monthly:
        return dayOfMonth != null && today.day == dayOfMonth;
    }
  }

  /// Людська назва частоти (українською).
  String get frequencyLabel {
    switch (frequency) {
      case Frequency.daily:
        return 'Щоденно';
      case Frequency.weekly:
        return 'Щотижня';
      case Frequency.biweekly:
        return 'Раз на два тижні';
      case Frequency.monthly:
        return 'Щомісяця';
    }
  }

  /// Повна назва частоти з описом (українською).
  String get displayFrequencyUAH {
    switch (frequency) {
      case Frequency.daily:
        return 'Щодня';
      case Frequency.weekly:
        final dayName = _weekdayName(dayOfWeek);
        return dayName != null ? 'Щотижня ($dayName)' : 'Щотижня';
      case Frequency.biweekly:
        final dayName = _weekdayName(dayOfWeek);
        return dayName != null
            ? 'Раз на 2 тижні ($dayName)'
            : 'Раз на 2 тижні';
      case Frequency.monthly:
        return dayOfMonth != null
            ? 'Щомісяця ($dayOfMonth числа)'
            : 'Щомісяця';
    }
  }

  /// Довгий опис частоти для детальної інформації.
  String get displayFrequencyDetailed {
    switch (frequency) {
      case Frequency.daily:
        return 'Щоденний автоматичний внесок';
      case Frequency.weekly:
        final dayName = _weekdayNameFull(dayOfWeek);
        return dayName != null
            ? 'Щотижневий внесок щодня $dayName'
            : 'Щотижневий внесок';
      case Frequency.biweekly:
        final dayName = _weekdayNameFull(dayOfWeek);
        return dayName != null
            ? 'Внесок раз на два тижні щодня $dayName'
            : 'Внесок раз на два тижні';
      case Frequency.monthly:
        return dayOfMonth != null
            ? 'Щомісячний внесок $dayOfMonth числа'
            : 'Щомісячний внесок';
    }
  }

  /// Короткий ярлик частоти для компактних UI.
  String get frequencyShortLabel {
    switch (frequency) {
      case Frequency.daily:
        return 'Щод.';
      case Frequency.weekly:
        return 'Щотиж.';
      case Frequency.biweekly:
        return '2/тиж.';
      case Frequency.monthly:
        return 'Щоміс.';
    }
  }

  /// Назва дня тижня українською (скорочено).
  static String? _weekdayName(int? day) {
    if (day == null) return null;
    switch (day) {
      case 1: return 'пн';
      case 2: return 'вт';
      case 3: return 'ср';
      case 4: return 'чт';
      case 5: return 'пт';
      case 6: return 'сб';
      case 7: return 'нд';
      default: return null;
    }
  }

  /// Повна назва дня тижня українською.
  static String? _weekdayNameFull(int? day) {
    if (day == null) return null;
    switch (day) {
      case 1: return 'понеділок';
      case 2: return 'вівторок';
      case 3: return 'середа';
      case 4: return 'четвер';
      case 5: return 'п\'ятниця';
      case 6: return 'субота';
      case 7: return 'неділя';
      default: return null;
    }
  }

  /// Назва дня тижня українською (static public).
  static String? weekdayName(int? day) => _weekdayName(day);

  /// Повна назва дня тижня українською (static public).
  static String? weekdayNameFull(int? day) => _weekdayNameFull(day);

  // ─── Дата наступного виконання ────────────────────────────────────

  /// Дата наступного виконання платежу.
  DateTime get nextExecutionDate {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    switch (frequency) {
      case Frequency.daily:
        return today;
      case Frequency.weekly:
        if (dayOfWeek == null) return today;
        int diff = dayOfWeek! - now.weekday;
        if (diff <= 0) diff += 7;
        return today.add(Duration(days: diff));
      case Frequency.biweekly:
        if (dayOfWeek == null) return today;
        var candidate = today;
        for (int i = 0; i < 14; i++) {
          final check = today.add(Duration(days: i));
          final weeksSince = check.difference(createdAt).inDays ~/ 7;
          if (check.weekday == dayOfWeek && weeksSince % 2 == 0) {
            candidate = check;
            break;
          }
        }
        return candidate;
      case Frequency.monthly:
        if (dayOfMonth == null) {
          return DateTime(now.year, now.month + 1, 1);
        }
        var target = DateTime(now.year, now.month, dayOfMonth!);
        if (!target.isAfter(today) || target == today) {
          target = DateTime(now.year, now.month + 1, dayOfMonth!);
        }
        return target;
    }
  }

  /// Дати наступних N виконань платежу (для планування).
  List<DateTime> upcomingExecutionDates({int count = 5}) {
    final dates = <DateTime>[];
    var current = nextExecutionDate;

    for (int i = 0; i < count; i++) {
      dates.add(current);
      switch (frequency) {
        case Frequency.daily:
          current = current.add(const Duration(days: 1));
          break;
        case Frequency.weekly:
          current = current.add(const Duration(days: 7));
          break;
        case Frequency.biweekly:
          current = current.add(const Duration(days: 14));
          break;
        case Frequency.monthly:
          current = DateTime(
            current.year,
            current.month + 1,
            current.day > 28 ? 28 : current.day,
          );
          break;
      }
    }
    return dates;
  }

  /// Повертає дати наступних N виконань у форматі українською.
  List<String> upcomingExecutionDatesFormatted({int count = 5}) {
    return upcomingExecutionDates(count: count).map((d) {
      return '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year}';
    }).toList();
  }

  // ─── Статистика ────────────────────────────────────────────────────

  /// Загальна сума, виплачена за весь час.
  double get calculatedTotalPaid => totalPaid;

  /// Кількість виконань.
  int get calculatedTimesExecuted => timesExecuted;

  /// Середня сума одного виконання.
  double get averagePayment {
    if (timesExecuted <= 0) return amount;
    return totalPaid / timesExecuted;
  }

  /// Кількість днів з моменту створення платежу.
  int get daysSinceCreation {
    return DateTime.now().difference(createdAt).inDays;
  }

  /// Кількість днів з останнього виконання.
  int get daysSinceLastExecution {
    if (lastExecutedAt == null) return daysSinceCreation;
    return DateTime.now().difference(lastExecutedAt!).inDays;
  }

  /// Кількість пропущених виконань (орієнтовно).
  int get missedExecutions {
    if (!isEnabled) return 0;
    final expected = daysSinceCreation ~/ frequency.daysInPeriod;
    return (expected - timesExecuted).clamp(0, 999);
  }

  /// Ефективність платежу (виконано / очікувалося).
  double get executionEfficiency {
    if (!isEnabled) return 0;
    final expected = daysSinceCreation ~/ frequency.daysInPeriod;
    if (expected <= 0) return 1.0;
    return (timesExecuted / expected).clamp(0.0, 1.0);
  }

  /// Формована ефективність, наприклад "85%".
  String get formattedEfficiency =>
      '${(executionEfficiency * 100).toStringAsFixed(0)}%';

  /// Кількість успішних виконань.
  int get successCount => timesExecuted;

  /// Відсоток успішних виконань.
  double get successRate {
    if (totalScheduled <= 0) return 0;
    return (timesExecuted / totalScheduled).clamp(0.0, 1.0);
  }

  /// Формований відсоток успішних виконань.
  String get formattedSuccessRate =>
      '${(successRate * 100).toStringAsFixed(0)}%';

  /// Чи є проблемні платеж (3+ невдалі поспіль).
  bool get hasRepeatedFailures => consecutiveFailures >= 3;

  /// Чи потрібна увага (2+ невдалі поспіль).
  bool get needsAttention => consecutiveFailures >= 2;

  /// Статистика невдач.
  Map<String, dynamic> get failureStats => {
    return {
      'consecutiveFailures': consecutiveFailures,
      'totalFailedAmount': totalFailedAmount,
      'totalScheduled': totalScheduled,
      'successRate': formattedSuccessRate,
    };
  }

  /// Повна статистика виконань.
  Map<String, dynamic> get executionStats => {
    return {
      'timesExecuted': timesExecuted,
      'totalPaid': totalPaid,
      'averagePayment': averagePayment,
      'missedExecutions': missedExecutions,
      'executionEfficiency': formattedEfficiency,
      'consecutiveFailures': consecutiveFailures,
      'totalFailedAmount': totalFailedAmount,
      'successCount': successCount,
      'totalScheduled': totalScheduled,
      'totalSkipped': totalSkipped,
    };
  }

  // ─── Форматування ──────────────────────────────────────────────────

  /// Форматована сума платежу, наприклад "500.00 грн".
  String get formattedAmount => '${amount.toStringAsFixed(2)} грн';

  /// Форматована сума платежу з коротким форматом "500 грн".
  String get formattedAmountShort => '${amount.toStringAsFixed(0)} грн';

  /// Форматована сума з пробілами, наприклад "1 500 грн".
  String get formattedAmountWithSpaces => '${_formatWithSpaces(amount)} грн';

  /// Форматована дата наступного платежу.
  String get formattedNextDate {
    return DateFormat('dd.MM.yyyy').format(nextExecutionDate);
  }

  /// Форматована дата наступного платежу з назвою дня.
  String get formattedNextDateFull {
    final date = nextExecutionDate;
    return '${DateFormat('dd.MM.yyyy').format(date)} (${_weekdayName(date.weekday) ?? ''})';
  }

  /// Формована дата наступного платежу з повною назвою дня.
  String get formattedNextDateDetailed {
    final date = nextExecutionDate;
    final dayName = _weekdayNameFull(date.weekday) ?? '';
    final months = [
      '', 'січня', 'лютого', 'березня', 'квітня', 'травня',
      'червня', 'липня', 'серпня', 'вересня', 'жовтня',
      'листопада', 'грудня',
    ];
    return '${date.day} $months[date.month], $dayName';
  }

  /// Форматована загальна сума виплат.
  String get formattedTotalPaid => '${totalPaid.toStringAsFixed(0)} грн';

  /// Формована кількість виконань.
  String get formattedTimesExecuted => '$timesExecuted разів';

  /// Формована середня сума платежу.
  String get formattedAveragePayment =>
      '${averagePayment.toStringAsFixed(0)} грн';

  /// Форматований опис платежу.
  String get formattedDescription {
    final parts = <String>[
      '${formattedAmountShort} · ${displayFrequencyUAH} · ${displayStatus}',
    ];
    if (description != null && description!.isNotEmpty) {
      parts.insert(0, '$description · ');
    }
    return parts.join();
  }

  /// Повний опис платежу для відображення.
  String toDisplayString() {
    final status = isEnabled ? 'Увімкнено' : 'Вимкнено';
    return '$formattedAmountShort · $displayFrequencyUAH · $status';
  }

  /// Детальний опис платежу.
  String toDetailedString() {
    final parts = <String>[
      '$formattedAmountShort кожну частоту $displayFrequencyUAH',
      'Виконано: $timesExecuted разів ($formattedTotalPaid)',
      'Місячна проекція: $formattedMonthlyProjection',
    ];
    if (limitPerPeriod != null) {
      parts.add('Ліміт: ${limitPerPeriod!.toStringAsFixed(0)} грн');
    }
    if (description != null && description!.isNotEmpty) {
      parts.add('Опис: $description');
    }
    return parts.join(' · ');
  }

  /// Статус платежу українською.
  String get displayStatus {
    if (!isEnabled) return '⛔ Вимкнено';
    if (isPaused) return '⏸️ Призупинено';
    if (hasRepeatedFailures) return '⚠️ Помилки';
    return '✅ Увімкнено';
  }

  /// Детальний статус українською з причиною.
  String get detailedStatus {
    if (!isEnabled) return '⛔ Вимкнено';
    if (isPaused) return '⏸️ Призупинено';
    if (hasRepeatedFailures) {
      return '⚠️ $consecutiveFailures помилок поспіль (останнє: ${lastExecutionStatus?.displayNameUA ?? "невідомо"})';
    }
    if (needsAttention) {
      return '⚡ Увага: $consecutiveFailures невдачі';
    }
    return '✅ Увімкнено';
  }

  /// Кількість днів до наступного виконання.
  int get daysUntilNext {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final next = nextExecutionDate;
    final diff = next.difference(today).inDays;
    return diff < 0 ? 0 : diff;
  }

  /// Формований залишок днів до наступного платежу.
  String get formattedDaysUntilNext {
    final days = daysUntilNext;
    if (days == 0) return 'Сьогодні';
    if (days == 1) return 'Завтра';
    return 'Через $days дн';
  }

  /// Місячна проекція витрат на основі частоти.
  double get monthlyProjection {
    switch (frequency) {
      case Frequency.daily:
        return amount * 30;
      case Frequency.weekly:
        return amount * (30 / 7);
      case Frequency.biweekly:
        return amount * (30 / 14);
      case Frequency.monthly:
        return amount;
    }
  }

  /// Формована місячна проекція.
  String get formattedMonthlyProjection =>
      '${monthlyProjection.toStringAsFixed(0)} грн/міс';

  /// Річна проекція витрат.
  double get yearlyProjection => monthlyProjection * 12;

  /// Формована річна проекція.
  String get formattedYearlyProjection =>
      '${yearlyProjection.toStringAsFixed(0)} грн/рік';

  /// Денна проекція витрат.
  double get dailyProjection {
    switch (frequency) {
      case Frequency.daily: return amount;
      case Frequency.weekly: return amount / 7;
      case Frequency.biweekly: return amount / 14;
      case Frequency.monthly: return amount / 30;
    }
  }

  /// Формована денна проекція.
  String get formattedDailyProjection =>
      '${dailyProjection.toStringAsFixed(1)} грн/день';

  /// Річна проекція успішних платежів.
  double get yearlySuccessProjection => monthlyProjection * successRate * 12;

  /// Формована річна проекція успішних.
  String get formattedYearlySuccessProjection =>
      '${yearlySuccessProjection.toStringAsFixed(0)} грн/рік (очікуваний)';

  // ─── Дії ───────────────────────────────────────────────────────────

  /// Вмикає автоматичний платіж.
  void enable() {
    isEnabled = true;
    pausedAt = null;
    consecutiveFailures = 0;
  }

  /// Вимикає автоматичний платіж.
  void disable() {
    isEnabled = false;
  }

  /// Призупиняє платіж (зберігає час призупинення).
  void pause() {
    isEnabled = false;
    pausedAt = DateTime.now();
  }

  /// Відновлює призупинений платіж.
  void resume() {
    isEnabled = true;
    pausedAt = null;
  }

  /// Перемикає стан увімкнення/вимкнення.
  void toggle() {
    isEnabled = !isEnabled;
  }

  /// Реєструє успішне виконання платежу.
  void markExecuted() {
    timesExecuted++;
    totalScheduled++;
    totalPaid += amount;
    lastExecutedAt = DateTime.now();
    lastExecutionStatus = PaymentExecutionStatus.success;
    consecutiveFailures = 0;
  }

  /// Реєструє успішне виконання з кастомною сумою.
  void markExecutedWithAmount(double paidAmount) {
    timesExecuted++;
    totalScheduled++;
    totalPaid += paidAmount;
    lastExecutedAt = DateTime.now();
    lastExecutionStatus = PaymentExecutionStatus.success;
    consecutiveFailures = 0;
  }

  /// Реєструє невдале виконання платежу.
  void markFailed({String? errorMessage}) {
    totalScheduled++;
    totalFailedAmount += amount;
    lastExecutedAt = DateTime.now();
    lastExecutionStatus = PaymentExecutionStatus.failed;
    consecutiveFailures++;
  }

  /// Реєструє пропущення через ліміт.
  void markLimitReached() {
    totalScheduled++;
    totalSkipped++;
    lastExecutedAt = DateTime.now();
    lastExecutionStatus = PaymentExecutionStatus.limitReached;
  }

  /// Скидає статистику виконань.
  void resetStats() {
    timesExecuted = 0;
    totalPaid = 0;
    lastExecutedAt = null;
    lastExecutionStatus = null;
    consecutiveFailures = 0;
    totalFailedAmount = 0;
    totalScheduled = 0;
    totalSkipped = 0;
  }

  /// Перевіряє, чи досягнуто ліміт за період.
  bool isLimitReached() {
    if (limitPerPeriod == null) return false;
    return totalPaid >= limitPerPeriod!;
  }

  /// Скільки залишилося до ліміту.
  double remainingUntilLimit() {
    if (limitPerPeriod == null) return double.infinity;
    final remaining = limitPerPeriod! - totalPaid;
    return remaining < 0 ? 0 : remaining;
  }

  /// Формований залишок до ліміту.
  String get formattedRemainingUntilLimit {
    if (limitPerPeriod == null) return 'Без ліміту';
    final remaining = remainingUntilLimit();
    if (remaining == 0) return 'Ліміт досягнуто';
    return '${remaining.toStringAsFixed(0)} грн до ліміту';
  }

  /// Оновлює суму платежу (для copyWith паттерну).
  void updateAmount(double newAmount) {
    // amount is final, so we use copyWith
  }

  // ─── Статичні утиліти ──────────────────────────────────────────────

  /// Загальна сума всіх платежів.
  static double totalPayments(List<AutoPayment> payments) {
    return payments.fold(0.0, (sum, p) => sum + p.totalPaid);
  }

  /// Загальна місячна проекція всіх платежів.
  static double totalMonthlyProjection(List<AutoPayment> payments) {
    return payments.fold(0.0, (sum, p) => sum + p.monthlyProjection);
  }

  /// Кількість активних платежів.
  static int activeCount(List<AutoPayment> payments) {
    return payments.where((p) => p.isEnabled).length;
  }

  /// Фільтрує платежі за goalId.
  static List<AutoPayment> filterByGoalId(
    List<AutoPayment> payments,
    String goalId,
  ) {
    return payments.where((p) => p.goalId == goalId).toList();
  }

  /// Фільтрує активні платежі.
  static List<AutoPayment> filterActive(List<AutoPayment> payments) {
    return payments.where((p) => p.isEnabled).toList();
  }

  /// Фільтрує неактивні платежі.
  static List<AutoPayment> filterInactive(List<AutoPayment> payments) {
    return payments.where((p) !p.isEnabled).toList();
  }

  /// Фільтрує платежі з помилками.
  static List<AutoPayment> filterWithFailures(
    List<AutoPayment> payments,
  ) {
    return payments.where((p) => p.consecutiveFailures >= 2).toList();
  }

  /// Сортує платежі за сумою (найбільші перші).
  static List<AutoPayment> sortByAmount(
    List<AutoPayment> payments, {
    bool highestFirst = true,
  }) {
    final sorted = List<AutoPayment>.from(payments);
    sorted.sort((a, b) => highestFirst
        ? b.amount.compareTo(a.amount)
        : a.amount.compareTo(b.amount));
    return sorted;
  }

  /// Сортує платежі за датою наступного виконання.
  static List<AutoPayment> sortByNextExecution(
    List<AutoPayment> payments,
  ) {
    final sorted = List<AutoPayment>.from(payments);
    sorted.sort((a, b) =>
        a.nextExecutionDate.compareTo(b.nextExecutionDate));
    return sorted;
  }

  /// Сортує платежі за ефективністю (найкращчі перші).
  static List<AutoPayment> sortByEfficiency(
    List<AutoPayment> payments,
  ) {
    final sorted = List<AutoPayment>.from(payments);
    sorted.sort((a, b) => b.executionEfficiency.compareTo(a.executionEfficiency));
    return sorted;
  }

  /// Платежі, які потрібно виконати сьогодні.
  static List<AutoPayment> dueToday(List<AutoPayment> payments) {
    return payments.where((p) => p.shouldExecuteToday).toList();
  }

  /// Зведення по всіх платежах.
  static Map<String, dynamic> getPaymentsSummary(
    List<AutoPayment> payments,
  ) {
    final active = payments.where((p) => p.isEnabled).toList();
    return {
      'total': payments.length,
      'active': active.length,
      'inactive': payments.length - active.length,
      'totalPaid': totalPayments(payments).toStringAsFixed(2),
      'monthlyProjection': totalMonthlyProjection(payments).toStringAsFixed(2),
      'withFailures': filterWithFailures(payments).length,
      'totalScheduled': payments.fold(0, (s, p) => s + p.totalScheduled),
      'totalSkipped': payments.fold(0, (s, p) => s + p.totalSkipped),
    };
  }

  // ─── Приватне форматування ────────────────────────────────────────

  static String _formatWithSpaces(double value) {
    final formatted = value.toStringAsFixed(0);
    final buffer = StringBuffer();
    for (int i = 0; i < formatted.length; i++) {
      if (i > 0 && (formatted.length - i) % 3 == 0) {
        buffer.write(' ');
      }
      buffer.write(formatted[i]);
    }
    return buffer.toString();
  }

  // ─── Серіалізація ──────────────────────────────────────────────────

  factory AutoPayment.fromJson(Map<String, dynamic> json) {
    return AutoPayment(
      id: json['id'] as String,
      goalId: json['goalId'] as String,
      amount: (json['amount'] as num).toDouble(),
      frequency: Frequency.values.firstWhere(
        (e) => e.name == json['frequency'],
        orElse: () => Frequency.monthly,
      ),
      dayOfWeek: json['dayOfWeek'] as int?,
      dayOfMonth: json['dayOfMonth'] as int?,
      isEnabled: (json['isEnabled'] as bool?) ?? true,
      onlyIfFundsAvailable: (json['onlyIfFundsAvailable'] as bool?) ?? false,
      limitPerPeriod: (json['limitPerPeriod'] as num?)?.toDouble(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      timesExecuted: (json['timesExecuted'] as int?) ?? 0,
      totalPaid: (json['totalPaid'] as num?)?.toDouble() ?? 0,
      pausedAt: json['pausedAt'] != null
          ? DateTime.parse(json['pausedAt'] as String)
          : null,
      lastExecutedAt: json['lastExecutedAt'] != null
          ? DateTime.parse(json['lastExecutedAt'] as String)
          : null,
      lastExecutionStatus: json['lastExecutionStatus'] != null
          ? PaymentExecutionStatus.values.firstWhere(
                (e) => e.name == json['lastExecutionStatus'],
                orElse: () => PaymentExecutionStatus.success,
              )
          : null,
      consecutiveFailures: (json['consecutiveFailures'] as int?) ?? 0,
      totalFailedAmount: (json['totalFailedAmount'] as num?)?.toDouble() ?? 0,
      description: json['description'] as String?,
      totalScheduled: (json['totalScheduled'] as int?) ?? 0,
      totalSkipped: (json['totalSkipped'] as int?) ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'goalId': goalId,
      'amount': amount,
      'frequency': frequency.name,
      'dayOfWeek': dayOfWeek,
      'dayOfMonth': dayOfMonth,
      'isEnabled': isEnabled,
      'onlyIfFundsAvailable': onlyIfFundsAvailable,
      'limitPerPeriod': limitPerPeriod,
      'createdAt': createdAt.toIso8601String(),
      'timesExecuted': timesExecuted,
      'totalPaid': totalPaid,
      'pausedAt': pausedAt?.toIso8601String(),
      'lastExecutedAt': lastExecutedAt?.toIso8601String(),
      'lastExecutionStatus': lastExecutionStatus?.name,
      'consecutiveFailures': consecutiveFailures,
      'totalFailedAmount': totalFailedAmount,
      'description': description,
      'totalScheduled': totalScheduled,
      'totalSkipped': totalSkipped,
    };
  }

  AutoPayment copyWith({
    String? id,
    String? goalId,
    double? amount,
    Frequency? frequency,
    int? dayOfWeek,
    int? dayOfMonth,
    bool? isEnabled,
    bool? onlyIfFundsAvailable,
    double? limitPerPeriod,
    DateTime? createdAt,
    int? timesExecuted,
    double? totalPaid,
    DateTime? pausedAt,
    DateTime? lastExecutedAt,
    bool clearDayOfWeek = false,
    bool clearDayOfMonth = false,
    bool clearLimitPerPeriod = false,
    bool clearPausedAt = false,
    bool clearLastExecutedAt = false,
    PaymentExecutionStatus? lastExecutionStatus,
    int? consecutiveFailures,
    double? totalFailedAmount,
    String? description,
    int? totalScheduled,
    int? totalSkipped,
  }) {
    return AutoPayment(
      id: id ?? this.id,
      goalId: goalId ?? this.goalId,
      amount: amount ?? this.amount,
      frequency: frequency ?? this.frequency,
      dayOfWeek: clearDayOfWeek ? null : (dayOfWeek ?? this.dayOfWeek),
      dayOfMonth: clearDayOfMonth ? null : (dayOfMonth ?? this.dayOfMonth),
      isEnabled: isEnabled ?? this.isEnabled,
      onlyIfFundsAvailable:
          onlyIfFundsAvailable ?? this.onlyIfFundsAvailable,
      limitPerPeriod: clearLimitPerPeriod
          ? null
          : (limitPerPeriod ?? this.limitPerPeriod),
      createdAt: createdAt ?? this.createdAt,
      timesExecuted: timesExecuted ?? this.timesExecuted,
      totalPaid: totalPaid ?? this.totalPaid,
      pausedAt: clearPausedAt ? null : (pausedAt ?? this.pausedAt),
      lastExecutedAt: clearLastExecutedAt
          ? null
          : (lastExecutedAt ?? this.lastExecutedAt),
      lastExecutionStatus: lastExecutionStatus ?? this.lastExecutionStatus,
      consecutiveFailures: consecutiveFailures ?? this.consecutiveFailures,
      totalFailedAmount: totalFailedAmount ?? this.totalFailedAmount,
      description: description ?? this.description,
      totalScheduled: totalScheduled ?? this.totalScheduled,
      totalSkipped: totalSkipped ?? this.totalSkipped,
    );
  }

  @override
  String toString() =>
      'AutoPayment(id: $id, amount: $amount, frequency: ${frequency.name})';
}

/// Розширення для переліку [Frequency].
extension AutoPaymentFrequencyExtension on Frequency {
  /// Кількість днів у періоді частоти.
  int get daysInPeriod {
    switch (this) {
      case Frequency.daily: return 1;
      case Frequency.weekly: return 7;
      case Frequency.biweekly: return 14;
      case Frequency.monthly: return 30;
    }
  }

  /// Кількість періодів у місяці.
  double get periodsPerMonth {
    return 30 / daysInPeriod;
  }

  /// Кількість виконань на рік.
  double get executionsPerYear {
    return 365 / daysInPeriod;
  }

  /// Коротке позначення.
  String get shortLabel {
    switch (this) {
      case Frequency.daily: return 'Щод.';
      case Frequency.weekly: return 'Щотиж.';
      case Frequency.biweekly: return '2/тиж.';
      case Frequency.monthly: return 'Щоміс.';
    }
  }

  /// Емодзі для частоти.
  String get emoji {
    switch (this) {
      case Frequency.daily: return '📅';
      case Frequency.weekly: return '📆';
      case Frequency.biweekly: return '🗓️';
      case Frequency.monthly: return '🗓️';
    }
  }

  /// Україномовна назва.
  String get ukrainianLabel {
    switch (this) {
      case Frequency.daily: return 'Щодня';
      case Frequency.weekly: return 'Щотижня';
      case Frequency.biweekly: return 'Раз на 2 тижні';
      case Frequency.monthly: return 'Щомісяця';
    }
  }

  /// Повна українськомовна назва частоти.
  String get ukrainianLabelFull {
    switch (this) {
      case Frequency.daily: return 'Щоденний';
      case Frequency.weekly: return 'Щотижневий';
      case Frequency.biweekly: return 'Раз на два тижні';
      case Frequency.monthly: return 'Щомісячний';
    }
  }

  /// Порядок сортування (від найменшого до найбільшого періоду).
  int get sortOrder {
    switch (this) {
      case Frequency.daily: return 0;
      case Frequency.weekly: return 1;
      case Frequency.biweekly: return 2;
      case Frequency.monthly: return 3;
    }
  }

  /// Опис частоти для відображення у тілі платежів.
  String get displayTooltip {
    switch (this) {
      case Frequency.daily:
        return 'Щоденний автоматичний внесок — кожен день';
      case Frequency.weekly:
        return 'Щотижневий внесок — кожного тижня';
      case Frequency.biweekly:
        return 'Раз на два тижні — економія витрат';
      case Frequency.monthly:
        return 'Щомісячний внесок — стабільне заощадження';
    }
  }
}
