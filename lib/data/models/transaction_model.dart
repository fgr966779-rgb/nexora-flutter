import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nexora/core/constants/app_enums.dart';

/// Категорія транзакції для детального аналізу.
enum TransactionCategory {
  /// Щоденні витрати.
  daily,

  /// Продукти харчування.
  groceries,

  /// Транспорт.
  transport,

  /// Розваги.
  entertainment,

  /// Освіта.
  education,

  /// Здоров'я.
  health,

  /// Подарунки.
  gifts,

  /// Інше.
  other;

  /// Україномовна назва.
  String get displayNameUA {
    switch (this) {
      case TransactionCategory.daily: return 'Щоденні';
      case TransactionCategory.groceries: return 'Продукти';
      case TransactionCategory.transport: return 'Транспорт';
      case TransactionCategory.entertainment: return 'Розваги';
      case TransactionCategory.education: return 'Освіта';
      case TransactionCategory.health: return 'Здоров\'я';
      case TransactionCategory.gifts: return 'Подарунки';
      case TransactionCategory.other: return 'Інше';
    }
  }

  /// Емодзі для категорії.
  String get emoji {
    switch (this) {
      case TransactionCategory.daily: return '🛒';
      case TransactionCategory.groceries: return '🥕';
      case TransactionCategory.transport: return '🚌';
      case TransactionCategory.entertainment: return '🎮';
      case TransactionCategory.education: return '📚';
      case TransactionCategory.health: return '💊';
      case TransactionCategory.gifts: return '🎁';
      case TransactionCategory.other: return '📌';
    }
  }
}

/// Модель транзакції (внесок до цілі).
///
/// Кожна транзакція є записом про поповнення скарбнички користувача.
/// Транзакції бувають різних типів: ручні внески, автоокруглення,
/// автоматичні платежі, виклики, щоденні бонуси, мікро-цілі, бонуси повернення.
/// Кожна транзакція фіксує суму, тип, дату створення, коментар,
/// а також XP та монети, які користувач отримав за цей внесок.
class Transaction {
  final String id;
  final String goalId;
  final TransactionType type;
  final double amount;
  final DateTime createdAt;
  final String? comment;
  final int xpEarned;
  final int coinsEarned;
  final TransactionCategory category;
  final bool isRecurring;
  final String? recurringGroupId;
  final DateTime? updatedAt;
  final bool isCancelled;

  Transaction({
    required this.id,
    required this.goalId,
    required this.type,
    required this.amount,
    required this.createdAt,
    this.comment,
    this.xpEarned = 0,
    this.coinsEarned = 0,
    this.category = TransactionCategory.other,
    this.isRecurring = false,
    this.recurringGroupId,
    this.updatedAt,
    this.isCancelled = false,
  });

  // ─── Дисплейні властивості ─────────────────────────────────────────

  /// Україномовна назва типу транзакції для відображення.
  String get displayNameUAH {
    switch (type) {
      case TransactionType.manual:
        return 'Ручний внесок';
      case TransactionType.roundUp:
        return 'Автоокруглення';
      case TransactionType.autoPayment:
        return 'Автоплатіж';
      case TransactionType.challenge:
        return 'Виклик';
      case TransactionType.dailyLogin:
        return 'Щоденний бонус';
      case TransactionType.microGoal:
        return 'Мікро-ціль';
      case TransactionType.returnBonus:
        return 'Бонус повернення';
    }
  }

  /// Коротка назва типу транзакції для компактних UI (badge, chip).
  String get shortTypeName {
    switch (type) {
      case TransactionType.manual:
        return 'Вручну';
      case TransactionType.roundUp:
        return 'Округл.';
      case TransactionType.autoPayment:
        return 'Авто';
      case TransactionType.challenge:
        return 'Виклик';
      case TransactionType.dailyLogin:
        return 'Бонус';
      case TransactionType.microGoal:
        return 'Мікро';
      case TransactionType.returnBonus:
        return 'Поверн.';
    }
  }

  /// Детальний опис типу транзакції для інформативних панелей.
  String get detailedDescription {
    switch (type) {
      case TransactionType.manual:
        return 'Ви особисто внесли кошти на рахунок цілі.';
      case TransactionType.roundUp:
        return 'Залишок від округлення банківської транзакції.';
      case TransactionType.autoPayment:
        return 'Автоматичний плановий внесок за розкладом.';
      case TransactionType.challenge:
        return 'Винагорода за успішне виконання виклику.';
      case TransactionType.dailyLogin:
        return 'Бонус за щоденний вхід у додаток.';
      case TransactionType.microGoal:
        return 'Бонус за виконання мікро-цілі.';
      case TransactionType.returnBonus:
        return 'Бонус за повернення після замороження.';
    }
  }

  /// Іконка для відображення типу транзакції.
  IconData get displayIcon {
    switch (type) {
      case TransactionType.manual:
        return Icons.handyman;
      case TransactionType.roundUp:
        return Icons.autorenew;
      case TransactionType.autoPayment:
        return Icons.calendar_today;
      case TransactionType.challenge:
        return Icons.emoji_events;
      case TransactionType.dailyLogin:
        return Icons.today;
      case TransactionType.microGoal:
        return Icons.check_circle_outline;
      case TransactionType.returnBonus:
        return Icons.restore;
    }
  }

  /// Емодзі для відображення типу транзакції (альтернатива IconData).
  String get displayEmoji {
    switch (type) {
      case TransactionType.manual:
        return '✏️';
      case TransactionType.roundUp:
        return '🔄';
      case TransactionType.autoPayment:
        return '💳';
      case TransactionType.challenge:
        return '🏆';
      case TransactionType.dailyLogin:
        return '📅';
      case TransactionType.microGoal:
        return '✅';
      case TransactionType.returnBonus:
        return '🎁';
    }
  }

  /// Колір для відображення типу транзакції.
  Color get displayColor {
    switch (type) {
      case TransactionType.manual:
        return const Color(0xFF6C63FF);
      case TransactionType.roundUp:
        return const Color(0xFF00BCD4);
      case TransactionType.autoPayment:
        return const Color(0xFF4CAF50);
      case TransactionType.challenge:
        return const Color(0xFFFF9800);
      case TransactionType.dailyLogin:
        return const Color(0xFF9C27B0);
      case TransactionType.microGoal:
        return const Color(0xFF009688);
      case TransactionType.returnBonus:
        return const Color(0xFFE91E63);
    }
  }

  /// Світла (фактова) версія кольору типу транзакції.
  Color get displayColorLight {
    switch (type) {
      case TransactionType.manual:
        return const Color(0x1A6C63FF);
      case TransactionType.roundUp:
        return const Color(0x1A00BCD4);
      case TransactionType.autoPayment:
        return const Color(0x1A4CAF50);
      case TransactionType.challenge:
        return const Color(0x1AFF9800);
      case TransactionType.dailyLogin:
        return const Color(0x1A9C27B0);
      case TransactionType.microGoal:
        return const Color(0x1A009688);
      case TransactionType.returnBonus:
        return const Color(0x1AE91E63);
    }
  }

  // ─── Часові перевірки ─────────────────────────────────────────────

  /// Чи створена сьогодні.
  bool get isToday {
    final now = DateTime.now();
    return createdAt.year == now.year &&
        createdAt.month == now.month &&
        createdAt.day == now.day;
  }

  /// Чи створена вчора.
  bool get isYesterday {
    final now = DateTime.now();
    final yesterday = now.subtract(const Duration(days: 1));
    return createdAt.year == yesterday.year &&
        createdAt.month == yesterday.month &&
        createdAt.day == yesterday.day;
  }

  /// Чи створена на цьому тижні (понеділок–неділя).
  bool get isThisWeek {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weekEnd = weekStart.add(const Duration(days: 6));
    final txDate = DateTime(
      createdAt.year,
      createdAt.month,
      createdAt.day,
    );
    return !txDate.isBefore(
          DateTime(weekStart.year, weekStart.month, weekStart.day),
        ) &&
        !txDate.isAfter(
          DateTime(weekEnd.year, weekEnd.month, weekEnd.day),
        );
  }

  /// Чи створена в цьому місяці.
  bool get isThisMonth {
    final now = DateTime.now();
    return createdAt.year == now.year && createdAt.month == now.month;
  }

  /// Чи створена в цьому році.
  bool get isThisYear {
    final now = DateTime.now();
    return createdAt.year == now.year;
  }

  /// Кількість днів з моменту створення транзакції.
  int get daysAgo {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final created = DateTime(createdAt.year, createdAt.month, createdAt.day);
    return today.difference(created).inDays;
  }

  /// Кількість годин з моменту створення транзакції.
  int get hoursAgo {
    return DateTime.now().difference(createdAt).inHours;
  }

  /// Часова мітка у форматі "відносного часу" (українською).
  String get relativeTime {
    final now = DateTime.now();
    final diff = now.difference(createdAt);

    if (diff.inMinutes < 1) return 'Щойно';
    if (diff.inMinutes < 60) return '${diff.inMinutes} хв тому';
    if (diff.inHours < 24) {
      final hours = diff.inHours;
      final minutes = diff.inMinutes % 60;
      if (minutes == 0) return '$hours год тому';
      return '$hours год $minutes хв тому';
    }
    if (diff.inDays == 1) return 'Вчора';
    if (diff.inDays < 7) return '${diff.inDays} дн тому';
    if (diff.inDays < 30) return '${diff.inDays ~/ 7} тиж тому';
    if (diff.inDays < 365) return '${diff.inDays ~/ 30} міс тому';
    return '${diff.inDays ~/ 365} р тому';
  }

  // ─── Форматування ─────────────────────────────────────────────────

  /// Форматована дата у вигляді "12 січня 2025".
  String get formattedDate {
    final months = [
      '', 'січня', 'лютого', 'березня', 'квітня', 'травня',
      'червня', 'липня', 'серпня', 'вересня', 'жовтня',
      'листопада', 'грудня',
    ];
    return '${createdAt.day} ${months[createdAt.month]} ${createdAt.year}';
  }

  /// Форматована дата коротко "12.01.2025".
  String get formattedDateShort {
    return DateFormat('dd.MM.yyyy').format(createdAt);
  }

  /// Форматована дата з часом "12.01.2025, 14:30".
  String get formattedDateTime {
    return DateFormat('dd.MM.yyyy, HH:mm').format(createdAt);
  }

  /// Форматований час "14:30".
  String get formattedTime {
    return DateFormat('HH:mm').format(createdAt);
  }

  /// Форматована сума з символом гривні, наприклад "1 250.50 грн".
  String get formattedAmount {
    return '${_formatCurrency(amount)} грн';
  }

  /// Форматована сума з додаванням "+", наприклад "+250 грн".
  String get formattedAmountPositive {
    return '+${_formatCurrency(amount)} грн';
  }

  /// Форматована сума з додаванням "+", наприклад "+250.00 грн" (з копійками).
  String get formattedAmountDetailed {
    return '+${amount.toStringAsFixed(2)} грн';
  }

  /// Форматована сума без символу гривні, наприклад "1 250.50".
  String get formattedAmountRaw {
    return _formatCurrency(amount);
  }

  /// Форматований XP як "+50 XP".
  String get formattedXp {
    if (xpEarned <= 0) return '';
    return '+$xpEarned XP';
  }

  /// Форматовані монети як "+25 монет".
  String get formattedCoins {
    if (coinsEarned <= 0) return '';
    return '+$coinsEarned монет';
  }

  /// Повна інформація про винагороду як "+50 XP, +25 монет".
  String get formattedRewards {
    final parts = <String>[];
    if (xpEarned > 0) parts.add('+$xpEarned XP');
    if (coinsEarned > 0) parts.add('+$coinsEarned монет');
    return parts.isEmpty ? '—' : parts.join(', ');
  }

  // ─── Типові перевірки ─────────────────────────────────────────────

  /// Чи це ручний внесок.
  bool get isManual => type == TransactionType.manual;

  /// Чи це автоматична транзакція (округлення або автоплатіж).
  bool get isAuto =>
      type == TransactionType.roundUp || type == TransactionType.autoPayment;

  /// Чи це транзакція від виклику.
  bool get isChallenge => type == TransactionType.challenge;

  /// Чи це бонусна транзакція (щоденний, мікро-ціль, повернення).
  bool get isBonus =>
      type == TransactionType.dailyLogin ||
      type == TransactionType.microGoal ||
      type == TransactionType.returnBonus;

  /// Чи має коментар.
  bool get hasComment => comment != null && comment!.isNotEmpty;

  /// Чи має нагороду (XP або монети).
  bool get hasRewards => xpEarned > 0 || coinsEarned > 0;

  /// Чи це великий внесок (>= 1000 грн).
  bool get isLargeAmount => amount >= 1000;

  /// Чи це маленький внесок (< 50 грн).
  bool get isSmallAmount => amount < 50;

  /// Чи це середній внесок (50–500 грн).
  bool get isMediumAmount => amount >= 50 && amount < 500;

  /// Чи це скасована транзакція.
  bool get isDeleted => isCancelled;

  // ─── Повне описання ───────────────────────────────────────────────

  /// Повне текстове описання транзакції.
  String toDisplayString() {
    final parts = <String>[
      '$displayNameUAH: ${formattedAmountPositive}',
      formattedDate,
    ];
    if (comment != null && comment!.isNotEmpty) {
      parts.add(comment!);
    }
    if (xpEarned > 0) {
      parts.add('+$xpEarned XP');
    }
    if (coinsEarned > 0) {
      parts.add('+$coinsEarned монет');
    }
    return parts.join(' · ');
  }

  /// Коротке описання для списку (назва + сума + дата).
  String toShortDisplayString() {
    return '$displayNameUAH · ${formattedAmountPositive} · $formattedDateShort';
  }

  // ─── Валідація ─────────────────────────────────────────────────────

  /// Чи транзакція валідна для збереження.
  bool get isValid {
    return id.isNotEmpty && goalId.isNotEmpty && amount > 0;
  }

  /// Статус валідації транзакції з описом помилок.
  String get validationMessage {
    if (id.isEmpty) return 'ID транзакції порожній';
    if (goalId.isEmpty) return 'ID цілі порожній';
    if (amount <= 0) return 'Сума має бути більшою за 0';
    return '✅ Валідна';
  }

  // ─── Експорт у різні формати ──────────────────────────────────────

  /// Експорт у формат CSV (один рядок).
  String toCsvRow() {
    final commentEscaped = comment?.replaceAll('"', '""') ?? '';
    return [
      id,
      goalId,
      type.name,
      amount.toStringAsFixed(2),
      createdAt.toIso8601String(),
      commentEscaped,
      xpEarned,
      coinsEarned,
      category.name,
    ].join(',');
  }

  /// Заголовок CSV для транзакцій.
  static String get csvHeader =>
      'ID,Ціль ID,Тип,Сума,Дата,Коментар,XP,Монети,Категорія';

  /// Повна CSV-строка з заголовком.
  String toFullCsv() => '$csvHeader\n${toCsvRow()}';

  /// Експорт у формат JSON-об'єкта (рядок).
  String toJsonString() {
    return jsonEncode(toJson());
  }

  // ─── Статичні утилітарні методи ───────────────────────────────────

  /// Групує транзакції за датою у форматі "12 січня 2025".
  static Map<String, List<Transaction>> groupByDate(
    List<Transaction> transactions,
  ) {
    final months = [
      '', 'січня', 'лютого', 'березня', 'квітня', 'травня',
      'червня', 'липня', 'серпня', 'вересня', 'жовтня',
      'листопада', 'грудня',
    ];
    final map = <String, List<Transaction>>{};
    for (final t in transactions) {
      final key =
          '${t.createdAt.day} ${months[t.createdAt.month]} ${t.createdAt.year}';
      map.putIfAbsent(key, () => []).add(t);
    }
    for (final list in map.values) {
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }
    return map;
  }

  /// Групує транзакції за типом.
  static Map<String, List<Transaction>> groupByType(
    List<Transaction> transactions,
  ) {
    final map = <String, List<Transaction>>{};
    for (final t in transactions) {
      map.putIfAbsent(t.displayNameUAH, () => []).add(t);
    }
    return map;
  }

  /// Групує транзакції за тижнем.
  static Map<String, List<Transaction>> groupByWeek(
    List<Transaction> transactions,
  ) {
    final months = [
      '', 'січня', 'лютого', 'березня', 'квітня', 'травня',
      'червня', 'липня', 'серпня', 'вересня', 'жовтня',
      'листопада', 'грудня',
    ];
    final map = <String, List<Transaction>>{};
    for (final t in transactions) {
      final weekNumber = _weekNumber(t.createdAt);
      final key = 'Тиждень $weekNumber (${months[t.createdAt.month]})';
      map.putIfAbsent(key, () => []).add(t);
    }
    return map;
  }

  /// Групує транзакції за категорією.
  static Map<TransactionCategory, List<Transaction>> groupByCategory(
    List<Transaction> transactions,
  ) {
    final map = <TransactionCategory, List<Transaction>>{};
    for (final t in transactions) {
      map.putIfAbsent(t.category, () => []).add(t);
    }
    return map;
  }

  /// Групує транзакції за місяцем.
  static Map<String, List<Transaction>> groupByMonth(
    List<Transaction> transactions,
  ) {
    final map = <String, List<Transaction>>{};
    for (final t in transactions) {
      final key =
          '${t.createdAt.year}-${t.createdAt.month.toString().padLeft(2, '0')}';
      map.putIfAbsent(key, () => []).add(t);
    }
    return map;
  }

  /// Обчислює загальну суму списку транзакцій.
  static double totalAmount(List<Transaction> transactions) {
    return transactions.fold(0.0, (sum, t) => sum + t.amount);
  }

  /// Обчислює середню суму списку транзакцій.
  static double averageAmount(List<Transaction> transactions) {
    if (transactions.isEmpty) return 0;
    return totalAmount(transactions) / transactions.length;
  }

  /// Знаходить максимальну суму серед транзакцій.
  static double maxAmount(List<Transaction> transactions) {
    if (transactions.isEmpty) return 0;
    return transactions
        .map((t) => t.amount)
        .reduce((a, b) => a > b ? a : b);
  }

  /// Знаходить мінімальну суму серед транзакцій.
  static double minAmount(List<Transaction> transactions) {
    if (transactions.isEmpty) return 0;
    return transactions
        .map((t) => t.amount)
        .reduce((a, b) => a < b ? a : b);
  }

  /// Загальний XP зароблений зі списку транзакцій.
  static int totalXp(List<Transaction> transactions) {
    return transactions.fold(0, (sum, t) => sum + t.xpEarned);
  }

  /// Загальні монети зароблені зі списку транзакцій.
  static int totalCoins(List<Transaction> transactions) {
    return transactions.fold(0, (sum, t) => sum + t.coinsEarned);
  }

  /// Сортує транзакції за датою (найновіші перші).
  static List<Transaction> sortByDate(
    List<Transaction> transactions, {
    bool newestFirst = true,
  }) {
    final sorted = List<Transaction>.from(transactions);
    sorted.sort((a, b) => newestFirst
        ? b.createdAt.compareTo(a.createdAt)
        : a.createdAt.compareTo(b.createdAt));
    return sorted;
  }

  /// Сортує транзакції за сумою (найбільші перші).
  static List<Transaction> sortByAmount(
    List<Transaction> transactions, {
    bool highestFirst = true,
  }) {
    final sorted = List<Transaction>.from(transactions);
    sorted.sort((a, b) =>
        highestFirst ? b.amount.compareTo(a.amount) : a.amount.compareTo(b.amount));
    return sorted;
  }

  /// Фільтрує транзакції за типом.
  static List<Transaction> filterByType(
    List<Transaction> transactions,
    TransactionType type,
  ) {
    return transactions.where((t) => t.type == type).toList();
  }

  /// Фільтрує транзакції за кількома типами одночасно.
  static List<Transaction> filterByTypes(
    List<Transaction> transactions,
    List<TransactionType> types,
  ) {
    return transactions.where((t) => types.contains(t.type)).toList();
  }

  /// Шукає транзакції за коментарем (без врахування регістру).
  static List<Transaction> searchByComment(
    List<Transaction> transactions,
    String query,
  ) {
    if (query.isEmpty) return transactions;
    final lower = query.toLowerCase();
    return transactions
        .where(
          (t) =>
              (t.comment != null && t.comment!.toLowerCase().contains(lower)),
        )
        .toList();
  }

  /// Шукає транзакції за goalId.
  static List<Transaction> filterByGoalId(
    List<Transaction> transactions,
    String goalId,
  ) {
    return transactions.where((t) => t.goalId == goalId).toList();
  }

  /// Фільтрує транзакції за діапазоном дат.
  static List<Transaction> filterByDateRange(
    List<Transaction> transactions, {
    required DateTime from,
    required DateTime to,
  }) {
    return transactions
        .where((t) => !t.createdAt.isBefore(from) && !t.createdAt.isAfter(to))
        .toList();
  }

  /// Фільтрує транзакції за цим місяцем.
  static List<Transaction> filterThisMonth(
    List<Transaction> transactions,
  ) {
    final now = DateTime.now();
    return transactions
        .where((t) => t.createdAt.year == now.year && t.createdAt.month == now.month)
        .toList();
  }

  /// Фільтрує транзакції за цим тижнем.
  static List<Transaction> filterThisWeek(
    List<Transaction> transactions,
  ) {
    return transactions.where((t) => t.isThisWeek).toList();
  }

  /// Фільтрує транзакції за сьогодні.
  static List<Transaction> filterToday(List<Transaction> transactions) {
    return transactions.where((t) => t.isToday).toList();
  }

  /// Фільтрує транзакції за мінімальною сумою.
  static List<Transaction> filterByMinAmount(
    List<Transaction> transactions,
    double minAmount,
  ) {
    return transactions.where((t) => t.amount >= minAmount).toList();
  }

  /// Фільтрує транзакції за максимальною сумою.
  static List<Transaction> filterByMaxAmount(
    List<Transaction> transactions,
    double maxAmount,
  ) {
    return transactions.where((t) => t.amount <= maxAmount).toList();
  }

  /// Фільтрує транзакції за діапазоном сум.
  static List<Transaction> filterByAmountRange(
    List<Transaction> transactions, {
    required double minAmount,
    required double maxAmount,
  }) {
    return transactions
        .where((t) => t.amount >= minAmount && t.amount <= maxAmount)
        .toList();
  }

  /// Фільтрує транзакції за категорією.
  static List<Transaction> filterByCategory(
    List<Transaction> transactions,
    TransactionCategory category,
  ) {
    return transactions.where((t) => t.category == category).toList();
  }

  /// Фільтрує лише повторювані транзакції.
  static List<Transaction> filterRecurring(
    List<Transaction> transactions,
  ) {
    return transactions.where((t) => t.isRecurring).toList();
  }

  /// Обчислює загальну суму транзакцій за сьогодні.
  static double todayTotal(List<Transaction> transactions) {
    return totalAmount(filterToday(transactions));
  }

  /// Обчислює загальну суму транзакцій за цей тиждень.
  static double thisWeekTotal(List<Transaction> transactions) {
    return totalAmount(filterThisWeek(transactions));
  }

  /// Обчислює загальну суму транзакцій за цей місяць.
  static double thisMonthTotal(List<Transaction> transactions) {
    return totalAmount(filterThisMonth(transactions));
  }

  /// Кількість транзакцій за сьогодні.
  static int todayCount(List<Transaction> transactions) {
    return filterToday(transactions).length;
  }

  /// Кількість транзакцій за цей тиждень.
  static int thisWeekCount(List<Transaction> transactions) {
    return filterThisWeek(transactions).length;
  }

  /// Кількість транзакцій за цей місяць.
  static int thisMonthCount(List<Transaction> transactions) {
    return filterThisMonth(transactions).length;
  }

  /// Створює зведену статистику для списку транзакцій.
  static TransactionSummary summarize(List<Transaction> transactions) {
    return TransactionSummary(
      total: totalAmount(transactions),
      average: averageAmount(transactions),
      count: transactions.length,
      maxAmount: maxAmount(transactions),
      minAmount: minAmount(transactions),
      totalXp: totalXp(transactions),
      totalCoins: totalCoins(transactions),
      todayTotal: todayTotal(transactions),
      weekTotal: thisWeekTotal(transactions),
      monthTotal: thisMonthTotal(transactions),
    );
  }

  /// Виявляє дублікати транзакцій (однакові сума + goalId + тип + дата).
  static List<List<Transaction>> findDuplicates(
    List<Transaction> transactions,
  ) {
    final groups = <String, List<Transaction>>{};
    for (final t in transactions) {
      final key =
          '${t.goalId}_${t.type.name}_${t.amount.toStringAsFixed(2)}_${DateFormat('yyyyMMdd').format(t.createdAt)}';
      groups.putIfAbsent(key, () => []).add(t);
    }
    return groups.values.where((g) => g.length > 1).toList();
  }

  /// Повертає унікальні ID цілей серед транзакцій.
  static List<String> uniqueGoalIds(List<Transaction> transactions) {
    return transactions.map((t) => t.goalId).toSet().toList();
  }

  /// Експортує список транзакцій у CSV.
  static String exportListToCsv(List<Transaction> transactions) {
    final buffer = StringBuffer();
    buffer.writeln(csvHeader);
    for (final t in transactions) {
      buffer.writeln(t.toCsvRow());
    }
    return buffer.toString();
  }

  /// Експортує список транзакцій у JSON.
  static String exportListToJson(List<Transaction> transactions) {
    return jsonEncode({
      'transactions': transactions.map((t) => t.toJson()).toList(),
      'count': transactions.length,
      'total': totalAmount(transactions),
      'exportedAt': DateTime.now().toIso8601String(),
    });
  }

  // ─── Приватний форматування ───────────────────────────────────────

  /// Форматує число з пробілами для тисяч, наприклад "1 250.50".
  static String _formatCurrency(double value) {
    final formatted = value.toStringAsFixed(2);
    final parts = formatted.split('.');
    final intPart = parts[0];
    final buffer = StringBuffer();
    for (int i = 0; i < intPart.length; i++) {
      if (i > 0 && (intPart.length - i) % 3 == 0) {
        buffer.write(' ');
      }
      buffer.write(intPart[i]);
    }
    buffer.write('.');
    buffer.write(parts[1]);
    return buffer.toString();
  }

  /// Обчислює номер тижня в році (ISO 8601).
  static int _weekNumber(DateTime date) {
    final dayOfYear = date.difference(DateTime(date.year, 1, 1)).inDays;
    return ((dayOfYear + DateTime(date.year, 1, 1).weekday - 1) / 7).ceil();
  }

  // ─── Серіалізація ──────────────────────────────────────────────────

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'] as String,
      goalId: json['goalId'] as String,
      type: TransactionType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => TransactionType.manual,
      ),
      amount: (json['amount'] as num).toDouble(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      comment: json['comment'] as String?,
      xpEarned: (json['xpEarned'] as int?) ?? 0,
      coinsEarned: (json['coinsEarned'] as int?) ?? 0,
      category: TransactionCategory.values.firstWhere(
        (e) => e.name == (json['category'] ?? 'other'),
        orElse: () => TransactionCategory.other,
      ),
      isRecurring: (json['isRecurring'] as bool?) ?? false,
      recurringGroupId: json['recurringGroupId'] as String?,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
      isCancelled: (json['isCancelled'] as bool?) ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'goalId': goalId,
      'type': type.name,
      'amount': amount,
      'createdAt': createdAt.toIso8601String(),
      'comment': comment,
      'xpEarned': xpEarned,
      'coinsEarned': coinsEarned,
      'category': category.name,
      'isRecurring': isRecurring,
      'recurringGroupId': recurringGroupId,
      'updatedAt': updatedAt?.toIso8601String(),
      'isCancelled': isCancelled,
    };
  }

  Transaction copyWith({
    String? id,
    String? goalId,
    TransactionType? type,
    double? amount,
    DateTime? createdAt,
    String? comment,
    int? xpEarned,
    int? coinsEarned,
    TransactionCategory? category,
    bool? isRecurring,
    String? recurringGroupId,
    DateTime? updatedAt,
    bool? isCancelled,
  }) {
    return Transaction(
      id: id ?? this.id,
      goalId: goalId ?? this.goalId,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      createdAt: createdAt ?? this.createdAt,
      comment: comment ?? this.comment,
      xpEarned: xpEarned ?? this.xpEarned,
      coinsEarned: coinsEarned ?? this.coinsEarned,
      category: category ?? this.category,
      isRecurring: isRecurring ?? this.isRecurring,
      recurringGroupId: recurringGroupId ?? this.recurringGroupId,
      updatedAt: updatedAt ?? this.updatedAt,
      isCancelled: isCancelled ?? this.isCancelled,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Transaction && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'Transaction(id: $id, type: $type, amount: $amount, goalId: $goalId)';
}

/// Зведена статистика для набору транзакцій.
///
/// Використовується для відображення агрегованих показників на дашборді
/// та в аналітичних панелях користувача.
class TransactionSummary {
  /// Загальна сума всіх транзакцій.
  final double total;

  /// Середня сума транзакції.
  final double average;

  /// Загальна кількість транзакцій.
  final int count;

  /// Максимальна сума однієї транзакції.
  final double maxAmount;

  /// Мінімальна сума однієї транзакції.
  final double minAmount;

  /// Загальний XP, зароблений з транзакцій.
  final int totalXp;

  /// Загальні монети, зароблені з транзакцій.
  final int totalCoins;

  /// Загальна сума за сьогодні.
  final double todayTotal;

  /// Загальна сума за цей тиждень.
  final double weekTotal;

  /// Загальна сума за цей місяць.
  final double monthTotal;

  const TransactionSummary({
    required this.total,
    required this.average,
    required this.count,
    required this.maxAmount,
    required this.minAmount,
    required this.totalXp,
    required this.totalCoins,
    required this.todayTotal,
    required this.weekTotal,
    required this.monthTotal,
  });

  /// Форматована загальна сума, наприклад "12 450.00 грн".
  String get formattedTotal => '${_fmt(total)} грн';

  /// Форматована середня сума, наприклад "245.00 грн".
  String get formattedAverage => '${_fmt(average)} грн';

  /// Форматована сума за сьогодні.
  String get formattedTodayTotal => '${_fmt(todayTotal)} грн';

  /// Форматована сума за цей тиждень.
  String get formattedWeekTotal => '${_fmt(weekTotal)} грн';

  /// Форматована сума за цей місяць.
  String get formattedMonthTotal => '${_fmt(monthTotal)} грн';

  /// Повертає мапу для серіалізації.
  Map<String, dynamic> toMap() {
    return {
      'total': total,
      'average': average,
      'count': count,
      'maxAmount': maxAmount,
      'minAmount': minAmount,
      'totalXp': totalXp,
      'totalCoins': totalCoins,
      'todayTotal': todayTotal,
      'weekTotal': weekTotal,
      'monthTotal': monthTotal,
    };
  }

  /// Текстовий звіт українською.
  String get reportText {
    return '💰 Загалом: $formattedTotal · '
        '📊 Середній: $formattedAverage · '
        '📝 Кількість: $count · '
        '📈 За місяць: $formattedMonthTotal';
  }

  static String _fmt(double v) {
    final f = v.toStringAsFixed(2);
    final parts = f.split('.');
    final intPart = parts[0];
    final buf = StringBuffer();
    for (int i = 0; i < intPart.length; i++) {
      if (i > 0 && (intPart.length - i) % 3 == 0) buf.write(' ');
      buf.write(intPart[i]);
    }
    buf.write('.');
    buf.write(parts[1]);
    return buf.toString();
  }
}
