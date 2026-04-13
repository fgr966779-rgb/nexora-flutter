import 'package:nexora/core/constants/app_enums.dart';
import 'package:nexora/data/models/auto_payment_model.dart';

/// Запис про невдачу платежу.
class PaymentFailureRecord {
  final String paymentId;
  final DateTime failedAt;
  final String reason;

  const PaymentFailureRecord({
    required this.paymentId,
    required this.failedAt,
    required this.reason,
  });
}

/// Запис про паузу платежу.
class PaymentPauseRecord {
  final String paymentId;
  final DateTime pausedAt;
  final DateTime? resumeAt;
  final String reason;

  const PaymentPauseRecord({
    required this.paymentId,
    required this.pausedAt,
    this.resumeAt,
    required this.reason,
  });
}

/// Репозиторій автоматичних платежів (in-memory).
///
/// Забезпечує CRUD, фільтрацію за частотою/ціллю, увімкнення/вимкнення,
/// обробку запланованих платежів, лімітивання та фінансову аналітику.
///
/// Всі рядки-повідомлення українською.
///
/// Розширено: прогнозування майбутніх платежів, відстеження невдач,
/// агрегація історії, валідація розкладу, управління паузами,
/// розширена аналітика платежів, пакетні операції.
class AutoPaymentRepository {
  final List<AutoPayment> _payments = [];
  final List<PaymentFailureRecord> _failureHistory = [];
  final List<PaymentPauseRecord> _pauseHistory = [];

  // ─── Базові CRUD ───────────────────────────────────────────────────

  /// Повертає всі автоматичні платежі (незмінний список).
  List<AutoPayment> getAll() {
    return List.unmodifiable(_payments);
  }

  /// Створює новий платіж та повертає його.
  AutoPayment create(AutoPayment payment) {
    _payments.add(payment);
    return payment;
  }

  /// Зберігає (або оновлює) платіж.
  void save(AutoPayment payment) {
    final index = _payments.indexWhere((p) => p.id == payment.id);
    if (index >= 0) {
      _payments[index] = payment;
    } else {
      _payments.add(payment);
    }
  }

  /// Зберігає без перевірки дублікатів (для імпорту).
  void saveSilent(AutoPayment payment) {
    _payments.add(payment);
  }

  /// Оновлює існуючий платіж.
  bool update(AutoPayment payment) {
    final index = _payments.indexWhere((p) => p.id == payment.id);
    if (index >= 0) {
      _payments[index] = payment;
      return true;
    }
    return false;
  }

  /// Видаляє платіж за ID. Повертає true якщо видалено.
  bool delete(String id) {
    final initialLength = _payments.length;
    _payments.removeWhere((p) => p.id == id);
    return _payments.length < initialLength;
  }

  /// Видаляє всі платежі для конкретної цілі. Повертає кількість видалених.
  int deleteByGoalId(String goalId) {
    final initialLength = _payments.length;
    _payments.removeWhere((p) => p.goalId == goalId);
    return initialLength - _payments.length;
  }

  /// Знаходить платіж за ID.
  AutoPayment? getById(String id) {
    for (final p in _payments) {
      if (p.id == id) return p;
    }
    return null;
  }

  /// Чи існує платіж з таким ID.
  bool exists(String id) {
    return _payments.any((p) => p.id == id);
  }

  /// Кількість платежів.
  int get count => _payments.length;

  /// Чи репозиторій порожній.
  bool get isEmpty => _payments.isEmpty;

  /// Очищає всі платежі.
  void clearAll() {
    _payments.clear();
    _failureHistory.clear();
    _pauseHistory.clear();
  }

  // ─── Пакетні операції ──────────────────────────────────────────────

  /// Створює кілька платежів одночасно. Повертає кількість створених.
  int createBatch(List<AutoPayment> payments) {
    int count = 0;
    for (final payment in payments) {
      if (!exists(payment.id)) {
        _payments.add(payment);
        count++;
      }
    }
    return count;
  }

  /// Видаляє кілька платежів за списком ID. Повертає кількість видалених.
  int deleteBatch(List<String> ids) {
    final idSet = ids.toSet();
    final initialLength = _payments.length;
    _payments.removeWhere((p) => idSet.contains(p.id));
    return initialLength - _payments.length;
  }

  /// Вмикає кілька платежів за списком ID. Повертає кількість увімкнених.
  int enableBatch(List<String> ids) {
    int count = 0;
    for (final id in ids) {
      if (enable(id)) count++;
    }
    return count;
  }

  /// Вимикає кілька платежів за списком ID. Повертає кількість вимкнених.
  int disableBatch(List<String> ids) {
    int count = 0;
    for (final id in ids) {
      if (disable(id)) count++;
    }
    return count;
  }

  // ─── Фільтрація за станом ──────────────────────────────────────────

  /// Повертає лише активні (увімкнені) платежі.
  List<AutoPayment> getActive() {
    return _payments.where((p) => p.isEnabled).toList();
  }

  /// Повертає лише неактивні (вимкнені) платежі.
  List<AutoPayment> getInactive() {
    return _payments.where((p) => !p.isEnabled).toList();
  }

  /// Повертає платежі, які мають виконатися сьогодні.
  List<AutoPayment> getDueToday() {
    return _payments.where((p) => p.shouldExecuteToday).toList();
  }

  /// Повертає активні платежі, які мають виконатися найближчим часом.
  List<AutoPayment> getUpcoming({int daysAhead = 7}) {
    final now = DateTime.now();
    final cutoff = now.add(Duration(days: daysAhead));
    return _payments.where((p) {
      if (!p.isEnabled) return false;
      final next = p.nextExecutionDate;
      return !next.isAfter(cutoff);
    }).toList()
      ..sort((a, b) => a.nextExecutionDate.compareTo(b.nextExecutionDate));
  }

  /// Повертає платежі, які мають виконатися сьогодні і активні.
  List<AutoPayment> getDueTodayActive() {
    return _payments
        .where((p) => p.shouldExecuteToday && p.isEnabled)
        .toList();
  }

  /// Синонім getActive().
  List<AutoPayment> getEnabled() => getActive();

  /// Повертає платежі на паузі.
  List<AutoPayment> getPaused() {
    final pausedIds = _pauseHistory
        .where((r) => r.resumeAt == null)
        .map((r) => r.paymentId)
        .toSet();
    return _payments.where((p) => pausedIds.contains(p.id)).toList();
  }

  // ─── Фільтрація за зв'язками ───────────────────────────────────────

  /// Повертає платежі для конкретної цілі.
  List<AutoPayment> getForGoal(String goalId) {
    return _payments.where((p) => p.goalId == goalId).toList();
  }

  /// Повертає платежі для конкретної цілі (синонім getForGoal).
  List<AutoPayment> getByGoalId(String goalId) {
    return getForGoal(goalId);
  }

  /// Повертає активні платежі для конкретної цілі.
  List<AutoPayment> getActiveForGoal(String goalId) {
    return _payments
        .where((p) => p.goalId == goalId && p.isEnabled)
        .toList();
  }

  /// Повертає платежі за частотою.
  List<AutoPayment> getByFrequency(Frequency frequency) {
    return _payments.where((p) => p.frequency == frequency).toList();
  }

  /// Повертає активні платежі за частотою.
  List<AutoPayment> getActiveByFrequency(Frequency frequency) {
    return _payments
        .where((p) => p.frequency == frequency && p.isEnabled)
        .toList();
  }

  /// Повертає платежі, які досягли ліміту за період.
  List<AutoPayment> getWithReachedLimit() {
    return _payments.where((p) => p.limitPerPeriod != null && p.isLimitReached()).toList();
  }

  /// Повертає платежі з встановленим лімітом.
  List<AutoPayment> getWithLimit() {
    return _payments.where((p) => p.limitPerPeriod != null).toList();
  }

  /// Пошук платежів за сумою (всі з сумою >= minAmount).
  List<AutoPayment> getByMinAmount(double minAmount) {
    return _payments.where((p) => p.amount >= minAmount).toList();
  }

  /// Повертає платежі, що виконувалися хоча б раз.
  List<AutoPayment> getExecutedPayments() {
    return _payments.where((p) => p.timesExecuted > 0).toList();
  }

  // ─── Управління станом ─────────────────────────────────────────────

  /// Вмикає платіж за ID. Повертає true якщо успішно.
  bool enable(String id) {
    final payment = getById(id);
    if (payment == null) return false;
    payment.enable();
    return true;
  }

  /// Вимикає платіж за ID. Повертає true якщо успішно.
  bool disable(String id) {
    final payment = getById(id);
    if (payment == null) return false;
    payment.disable();
    return true;
  }

  /// Перемикає стан платежу. Повертає новий стан (true = увімкнено).
  bool toggle(String id) {
    final payment = getById(id);
    if (payment == null) return false;
    payment.toggle();
    return payment.isEnabled;
  }

  /// Вмикає всі платежі. Повертає кількість увімкнених.
  int enableAll() {
    int count = 0;
    for (final p in _payments) {
      if (!p.isEnabled) {
        p.enable();
        count++;
      }
    }
    return count;
  }

  /// Вимикає всі платежі. Повертає кількість вимкнених.
  int disableAll() {
    int count = 0;
    for (final p in _payments) {
      if (p.isEnabled) {
        p.disable();
        count++;
      }
    }
    return count;
  }

  // ─── Управління паузами ────────────────────────────────────────────

  /// Ставить платіж на паузу.
  bool pause(String id, String reason) {
    final payment = getById(id);
    if (payment == null) return false;
    payment.disable();
    _pauseHistory.add(PaymentPauseRecord(
      paymentId: id,
      pausedAt: DateTime.now(),
      reason: reason,
    ));
    return true;
  }

  /// Знімає платіж з паузи.
  bool resume(String id) {
    final payment = getById(id);
    if (payment == null) return false;
    payment.enable();
    final pauseRecord = _pauseHistory.lastWhere(
      (r) => r.paymentId == id && r.resumeAt == null,
      orElse: null,
    );
    if (pauseRecord != null) {
      final index = _pauseHistory.indexOf(pauseRecord);
      _pauseHistory[index] = PaymentPauseRecord(
        paymentId: id,
        pausedAt: pauseRecord.pausedAt,
        resumeAt: DateTime.now(),
        reason: pauseRecord.reason,
      );
    }
    return true;
  }

  /// Повертає історію пауз для платежу.
  List<PaymentPauseRecord> getPauseHistory(String id) {
    return _pauseHistory.where((r) => r.paymentId == id).toList();
  }

  // ─── Обробка платежів ──────────────────────────────────────────────

  /// Обробляє всі заплановані платежі, що мають виконатися сьогодні.
  /// Повертає список ID виконаних платежів.
  List<String> processScheduledPayments() {
    final executed = <String>[];
    for (final payment in _payments) {
      if (payment.shouldExecuteToday && payment.isEnabled) {
        // Перевірка ліміту за період
        if (payment.limitPerPeriod != null && payment.isLimitReached()) {
          continue;
        }
        // Перевірка паузи
        final isPaused = _pauseHistory.any(
          (r) => r.paymentId == payment.id && r.resumeAt == null,
        );
        if (isPaused) continue;

        try {
          payment.markExecuted();
          executed.add(payment.id);
        } catch (e) {
          _failureHistory.add(PaymentFailureRecord(
            paymentId: payment.id,
            failedAt: DateTime.now(),
            reason: e.toString(),
          ));
        }
      }
    }
    return executed;
  }

  /// Обробляє платежі тільки для конкретної цілі.
  List<String> processScheduledPaymentsForGoal(String goalId) {
    final executed = <String>[];
    for (final payment in _payments) {
      if (payment.goalId == goalId &&
          payment.shouldExecuteToday &&
          payment.isEnabled) {
        if (payment.limitPerPeriod != null && payment.isLimitReached()) {
          continue;
        }
        payment.markExecuted();
        executed.add(payment.id);
      }
    }
    return executed;
  }

  /// Відмічає конкретний платіж як виконаний вручну.
  bool markManuallyExecuted(String id) {
    final payment = getById(id);
    if (payment == null) return false;
    payment.markExecuted();
    return true;
  }

  /// Повертає дату наступного виконання для всіх активних платежів.
  DateTime? getNextExecution() {
    final active = getActive();
    if (active.isEmpty) return null;
    DateTime? nearest;
    for (final p in active) {
      final next = p.nextExecutionDate;
      if (nearest == null || next.isBefore(nearest)) {
        nearest = next;
      }
    }
    return nearest;
  }

  /// Повертає інформацію про найближчий активний платіж.
  AutoPayment? getNextPayment() {
    final active = getActive();
    if (active.isEmpty) return null;
    active.sort((a, b) => a.nextExecutionDate.compareTo(b.nextExecutionDate));
    return active.first;
  }

  /// Повертає дні до наступного виконання для всіх активних платежів.
  int? get daysUntilNextExecution {
    final next = getNextExecution();
    if (next == null) return null;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final diff = next.difference(today).inDays;
    return diff < 0 ? 0 : diff;
  }

  /// Скидає статистику виконань для всіх платежів.
  void resetAllStats() {
    for (final p in _payments) {
      p.resetStats();
    }
  }

  /// Скидає статистику виконань для конкретного платежу.
  bool resetStats(String id) {
    final payment = getById(id);
    if (payment == null) return false;
    payment.resetStats();
    return true;
  }

  // ─── Прогнозування ─────────────────────────────────────────────────

  /// Прогнозує суму платежів за вказаний період у днях.
  double predictForDays(int days) {
    return getActive().fold(0.0, (sum, p) {
      switch (p.frequency) {
        case Frequency.daily:
          return sum + p.amount * days;
        case Frequency.weekly:
          return sum + p.amount * (days / 7);
        case Frequency.biweekly:
          return sum + p.amount * (days / 14);
        case Frequency.monthly:
          return sum + p.amount * (days / 30.44);
        case Frequency.yearly:
          return sum + p.amount * (days / 365.25);
      }
    });
  }

  /// Прогнозує дату досягнення цілі для вказаної суми.
  DateTime? predictGoalDate(String goalId, double remainingAmount) {
    final activeForGoal = getActiveForGoal(goalId);
    if (activeForGoal.isEmpty) return null;
    final dailyPrediction = activeForGoal.fold(0.0, (sum, p) {
      switch (p.frequency) {
        case Frequency.daily: return sum + p.amount;
        case Frequency.weekly: return sum + p.amount / 7;
        case Frequency.biweekly: return sum + p.amount / 14;
        case Frequency.monthly: return sum + p.amount / 30.44;
        case Frequency.yearly: return sum + p.amount / 365.25;
      }
    });
    if (dailyPrediction <= 0) return null;
    final daysNeeded = (remainingAmount / dailyPrediction).ceil();
    return DateTime.now().add(Duration(days: daysNeeded));
  }

  // ─── Валідація розкладу ────────────────────────────────────────────

  /// Перевіряє наявність конфліктів у розкладі. Повертає список конфліктів.
  List<String> validateSchedule() {
    final conflicts = <String>[];
    final active = getActive();
    for (int i = 0; i < active.length; i++) {
      for (int j = i + 1; j < active.length; j++) {
        if (active[i].goalId == active[j].goalId &&
            active[i].frequency == active[j].frequency &&
            active[i].amount == active[j].amount) {
          conflicts.add(
            '⚠️ Дублікат: ${active[i].formattedAmountShort} для цілі ${active[i].goalId} (${active[i].frequency.name})',
          );
        }
      }
    }
    if (active.length > 20) {
      conflicts.add('⚠️ Забагато активних платежів (${active.length}). Рекомендується ≤20.');
    }
    return conflicts;
  }

  // ─── Відстеження невдач ─────────────────────────────────────────────

  /// Повертає всі записи про невдачі.
  List<PaymentFailureRecord> getFailureHistory() {
    return List.unmodifiable(_failureHistory);
  }

  /// Повертає невдачі для конкретного платежу.
  List<PaymentFailureRecord> getFailuresForPayment(String id) {
    return _failureHistory.where((r) => r.paymentId == id).toList();
  }

  /// Повертає кількість невдач за останні N днів.
  int getRecentFailureCount({int days = 7}) {
    final cutoff = DateTime.now().subtract(Duration(days: days));
    return _failureHistory.where((r) => r.failedAt.isAfter(cutoff)).length;
  }

  /// Чи є платіж «проблемним» (більше 3 невдач за останні 7 днів).
  bool isProblematicPayment(String id, {int threshold = 3}) {
    return getFailuresForPayment(id)
        .where((r) => r.failedAt.isAfter(DateTime.now().subtract(const Duration(days: 7))))
        .length >= threshold;
  }

  /// Повертає всі проблемні платежі.
  List<AutoPayment> getProblematicPayments({int threshold = 3}) {
    return _payments.where((p) => isProblematicPayment(p.id, threshold: threshold)).toList();
  }

  /// Очищає історію невдач для конкретного платежу.
  void clearFailuresForPayment(String id) {
    _failureHistory.removeWhere((r) => r.paymentId == id);
  }

  // ─── Агрегація історії ─────────────────────────────────────────────

  /// Повертає кількість виконань за останні N днів.
  int getExecutionsCount({int days = 7}) {
    // Приблизний розрахунок на основі загальної кількості виконань
    return totalExecutions;
  }

  /// Повертає загальну суму за останні N днів (оцінка).
  double getRecentTotal({int days = 7}) {
    return getActive().fold(0.0, (sum, p) {
      switch (p.frequency) {
        case Frequency.daily: return sum + p.amount * days;
        case Frequency.weekly: return sum + p.amount * (days / 7);
        case Frequency.biweekly: return sum + p.amount * (days / 14);
        case Frequency.monthly: return sum + p.amount * (days / 30.44);
        case Frequency.yearly: return sum + p.amount * (days / 365.25);
      }
    });
  }

  /// Повертає середню суму за виконання.
  double get averageExecutionAmount {
    if (totalExecutions == 0) return 0;
    return totalPaid / totalExecutions;
  }

  /// Повертає найуспішніший платіж (найбільше виконань).
  AutoPayment? getMostExecutedPayment {
    if (_payments.isEmpty) return null;
    return _payments.reduce((a, b) => a.timesExecuted >= b.timesExecuted ? a : b);
  }

  // ─── Аналітика ─────────────────────────────────────────────────────

  /// Місячна проекція всіх активних платежів.
  double monthlyProjection() {
    return getActive()
        .fold(0.0, (sum, p) => sum + p.monthlyProjection);
  }

  /// Річна проекція всіх активних платежів.
  double yearlyProjection() {
    return monthlyProjection() * 12;
  }

  /// Тижнева проекція всіх активних платежів.
  double weeklyProjection() {
    return monthlyProjection() / 4.33;
  }

  /// Місячна проекція для конкретної цілі.
  double monthlyProjectionForGoal(String goalId) {
    return getForGoal(goalId)
        .where((p) => p.isEnabled)
        .fold(0.0, (sum, p) => sum + p.monthlyProjection);
  }

  /// Загальна сума всіх виконаних платежів.
  double get totalPaid {
    return _payments.fold(0.0, (sum, p) => sum + p.totalPaid);
  }

  /// Загальна кількість виконань.
  int get totalExecutions {
    return _payments.fold(0, (sum, p) => sum + p.timesExecuted);
  }

  /// Загальна сума всіх активних платежів (разова).
  double get totalActiveAmount {
    return getActive().fold(0.0, (sum, p) => sum + p.amount);
  }

  /// Середня сума активного платежу.
  double get averageActiveAmount {
    final active = getActive();
    if (active.isEmpty) return 0;
    return active.fold(0.0, (sum, p) => sum + p.amount) / active.length;
  }

  /// Максимальна сума активного платежу.
  double get maxActiveAmount {
    final active = getActive();
    if (active.isEmpty) return 0;
    return active.fold(0.0, (max, p) => p.amount > max ? p.amount : max);
  }

  /// Статистика за частотами.
  Map<Frequency, int> countByFrequency() {
    final map = <Frequency, int>{};
    for (final p in _payments) {
      map[p.frequency] = (map[p.frequency] ?? 0) + 1;
    }
    return map;
  }

  /// Статистика за частотами (тільки активні).
  Map<Frequency, int> activeCountByFrequency() {
    final map = <Frequency, int>{};
    for (final p in _payments) {
      if (p.isEnabled) {
        map[p.frequency] = (map[p.frequency] ?? 0) + 1;
      }
    }
    return map;
  }

  /// Повертає повний звіт по автоплатежах.
  Map<String, dynamic> getFullStats() {
    return {
      'загальноПлатежів': count,
      'активних': getActive().length,
      'неактивних': getInactive().length,
      'наПаузі': getPaused().length,
      'виконаносьогодні': getDueTodayActive().length,
      'найближчі7днів': getUpcoming(daysAhead: 7).length,
      'місячнаПрокція': monthlyProjection().toStringAsFixed(2),
      'річнаПрокція': yearlyProjection().toStringAsFixed(2),
      'загальноВиплачено': totalPaid.toStringAsFixed(2),
      'загальнеВиконань': totalExecutions,
      'заЛімітами': getWithReachedLimit().length,
      'невдачЗаТиждень': getRecentFailureCount(),
      'проблемних': getProblematicPayments().length,
      'конфліктів': validateSchedule().length,
    };
  }

  // ─── Текстові зведення ─────────────────────────────────────────────

  /// Короткий опис для відображення.
  String get summaryText {
    final active = getActive().length;
    final total = count;
    final monthly = monthlyProjection().toStringAsFixed(0);
    return 'Увімкнено: $active з $total · ~$monthly грн/міс';
  }

  /// Розширений опис для відображення.
  String get detailedSummaryText {
    final active = getActive().length;
    final total = count;
    final monthly = monthlyProjection().toStringAsFixed(0);
    final yearly = yearlyProjection().toStringAsFixed(0);
    final paid = totalPaid.toStringAsFixed(0);
    return 'Платежів: $total (активних: $active) · '
        'Місяць: ~$monthly грн · Рік: ~$yearly грн · '
        'Виплачено: $paid грн';
  }

  /// Повертає текстову підказку щодо автоплатежів.
  String get tipText {
    if (isEmpty) {
      return '💡 Налаштуй автоматичні платежі, щоб заощадити без зусиль!';
    }
    if (getActive().isEmpty) {
      return '⚠️ Усі автоплатежі вимкнено. Увімкніть хоча б один!';
    }
    final problems = getProblematicPayments();
    if (problems.isNotEmpty) {
      return '🔧 Увага: ${problems.length} проблемних платежів потребують уваги!';
    }
    final conflicts = validateSchedule();
    if (conflicts.isNotEmpty) {
      return '⚠️ Знайдено ${conflicts.length} конфліктів у розкладі!';
    }
    final next = getNextPayment();
    if (next != null) {
      return '📅 Найближчий платіж: ${next.formattedAmountShort} — ${next.formattedNextDateFull}';
    }
    return '✅ Автоплатежі налаштовані та працюють!';
  }
}
