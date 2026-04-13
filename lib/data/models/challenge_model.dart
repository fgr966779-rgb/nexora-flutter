import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nexora/core/constants/app_enums.dart';

/// Категорія челенджу.
enum ChallengeCategory {
  /// Заощадження коштів.
  savings,

  /// Регулярність внесків.
  regularity,

  /// Відмова від шкідливих звичок.
  habitBreaking,

  /// Досягнення фінансових цілей.
  financialGoal,

  /// Навчання та розвиток.
  education,

  /// Загальний тип.
  general;

  /// Україномовна назва.
  String get displayNameUA {
    switch (this) {
      case ChallengeCategory.savings: return 'Заощадження';
      case ChallengeCategory.regularity: return 'Регулярність';
      case ChallengeCategory.habitBreaking: return 'Відмова від звичок';
      case ChallengeCategory.financialGoal: return 'Фінансова ціль';
      case ChallengeCategory.education: return 'Навчання';
      case ChallengeCategory.general: return 'Загальний';
    }
  }

  /// Емодзі категорії.
  String get emoji {
    switch (this) {
      case ChallengeCategory.savings: return '💰';
      case ChallengeCategory.regularity: return '📅';
      case ChallengeCategory.habitBreaking: return '🚫';
      case ChallengeCategory.financialGoal: return '🎯';
      case ChallengeCategory.education: return '📚';
      case ChallengeCategory.general: return '🌟';
    }
  }

  /// Колір категорії.
  Color get color {
    switch (this) {
      case ChallengeCategory.savings: return const Color(0xFF4CAF50);
      case ChallengeCategory.regularity: return const Color(0xFF2196F3);
      case ChallengeCategory.habitBreaking: return const Color(0xFFFF5722);
      case ChallengeCategory.financialGoal: return const Color(0xFFFF9800);
      case ChallengeCategory.education: return const Color(0xFF9C27B0);
      case ChallengeCategory.general: return const Color(0xFF607D8B);
    }
  }

  /// Рівні складності, доступні для цієї категорії.
  List<ChallengeDifficulty> get availableDifficulties {
    switch (this) {
      case ChallengeCategory.savings:
        return ChallengeDifficulty.values;
      case ChallengeCategory.regularity:
        return [ChallengeDifficulty.easy, ChallengeDifficulty.medium];
      case ChallengeCategory.habitBreaking:
        return [ChallengeDifficulty.medium, ChallengeDifficulty.hard];
      case ChallengeCategory.financialGoal:
        return [ChallengeDifficulty.medium, ChallengeDifficulty.hard];
      case ChallengeCategory.education:
        return [ChallengeDifficulty.easy, ChallengeDifficulty.medium];
      case ChallengeCategory.general:
        return ChallengeDifficulty.values;
    }
  }
}

/// Модель челенджу.
///
/// Челендж — це гейміфіковане завдання для користувача з певним терміном
/// виконання, винагородою (грошовою, XP та монетами) та рівнем складності.
/// Кожен челендж має щоденний трекер прогресу та може бути запущений,
/// провалений або успішно завершений.
class Challenge {
  final String id;
  final String title;
  final String description;
  final double rewardAmount;
  final int xpReward;
  final int coinsReward;
  final int durationDays;
  ChallengeStatus status;
  DateTime? startedAt;
  DateTime? completedAt;
  int currentDay;
  final ChallengeDifficulty difficulty;
  List<bool> dailyProgressList;
  final ChallengeCategory category;
  int streakConsecutiveDays;
  int totalAttempts;
  int failedAttempts;
  String? emoji;
  String? customRewardMessage;

  Challenge({
    required this.id,
    required this.title,
    required this.description,
    this.rewardAmount = 0,
    this.xpReward = 0,
    this.coinsReward = 0,
    required this.durationDays,
    this.status = ChallengeStatus.available,
    this.startedAt,
    this.completedAt,
    this.currentDay = 0,
    required this.difficulty,
    List<bool>? dailyProgressList,
    this.category = ChallengeCategory.general,
    this.streakConsecutiveDays = 0,
    this.totalAttempts = 0,
    this.failedAttempts = 0,
    this.emoji,
    this.customRewardMessage,
  }) : dailyProgressList = dailyProgressList ?? [];

  // ─── Дисплейні властивості ─────────────────────────────────────────

  /// Україномовна назва (використовує title, оскільки шаблони вже українською).
  String get displayNameUAH => title;

  /// Україномовний опис.
  String get displayDescriptionUAH => description;

  /// Україномовна складність.
  String get displayDifficultyUAH {
    switch (difficulty) {
      case ChallengeDifficulty.easy:
        return 'Легко';
      case ChallengeDifficulty.medium:
        return 'Середньо';
      case ChallengeDifficulty.hard:
        return 'Складно';
    }
  }

  /// Детальний опис складності.
  String get difficultyDescription {
    switch (difficulty) {
      case ChallengeDifficulty.easy:
        return 'Швидкий виклик з невеликою винагородою';
      case ChallengeDifficulty.medium:
        return 'Помірна віддача — потрібно трохи зусиль';
      case ChallengeDifficulty.hard:
        return 'Серйозне зобов\'язання з великою винагородою';
    }
  }

  /// Колір складності.
  Color get difficultyColor {
    switch (difficulty) {
      case ChallengeDifficulty.easy:
        return const Color(0xFF4CAF50);
      case ChallengeDifficulty.medium:
        return const Color(0xFFFF9800);
      case ChallengeDifficulty.hard:
        return const Color(0xFFF44336);
    }
  }

  /// Світла (фактова) колір складності для фону.
  Color get difficultyColorLight {
    switch (difficulty) {
      case ChallengeDifficulty.easy:
        return const Color(0x1A4CAF50);
      case ChallengeDifficulty.medium:
        return const Color(0x1AFF9800);
      case ChallengeDifficulty.hard:
        return const Color(0x1AF44336);
    }
  }

  /// Іконка складності.
  IconData get difficultyIcon {
    switch (difficulty) {
      case ChallengeDifficulty.easy:
        return Icons.sentiment_satisfied;
      case ChallengeDifficulty.medium:
        return Icons.sentiment_neutral;
      case ChallengeDifficulty.hard:
        return Icons.local_fire_department;
    }
  }

  /// Емодзі складності.
  String get difficultyEmoji {
    switch (difficulty) {
      case ChallengeDifficulty.easy: return '😊';
      case ChallengeDifficulty.medium: return '😐';
      case ChallengeDifficulty.hard: return '😤';
    }
  }

  /// Множник нагороди залежно від складності.
  double get difficultyMultiplier => difficulty.rewardMultiplier;

  /// Емодзя челенджу.
  String get displayEmoji => emoji ?? difficultyEmoji;

  /// Статус челенджу українською.
  String get displayStatusUAH {
    switch (status) {
      case ChallengeStatus.available: return 'Доступний';
      case ChallengeStatus.active: return 'В процесі';
      case ChallengeStatus.completed: return 'Завершено';
      case ChallengeStatus.failed: return 'Не виконано';
    }
  }

  /// Емодзі статусу.
  String get statusEmoji {
    switch (status) {
      case ChallengeStatus.available: return '🟢';
      case ChallengeStatus.active: return '🔵';
      case ChallengeStatus.completed: return '✅';
      case ChallengeStatus.failed: return '❌';
    }
  }

  /// Опис категорії українською.
  String get displayCategoryUA => category.displayNameUA;

  /// Коротка назва категорії.
  String get shortCategoryUA => category.emoji;

  // ─── Часові обчислення ─────────────────────────────────────────────

  /// Кількість днів, що залишилася.
  int get daysRemaining {
    if (startedAt == null || status != ChallengeStatus.active) {
      return durationDays;
    }
    final elapsed = DateTime.now().difference(startedAt!).inDays;
    final remaining = durationDays - elapsed;
    return remaining < 0 ? 0 : remaining;
  }

  /// Кількість годин, що залишилася (приблизно).
  int get hoursRemaining {
    if (startedAt == null || status != ChallengeStatus.active) {
      return durationDays * 24;
    }
    final remaining = startedAt!
        .add(Duration(days: durationDays))
        .difference(DateTime.now());
    final hours = remaining.inHours;
    return hours < 0 ? 0 : hours;
  }

  /// Кількість хвилин, що залишилася (приблизно).
  int get minutesRemaining {
    if (startedAt == null || status != ChallengeStatus.active) {
      return durationDays * 24 * 60;
    }
    final remaining = startedAt!
        .add(Duration(days: durationDays))
        .difference(DateTime.now());
    final mins = remaining.inMinutes;
    return mins < 0 ? 0 : mins;
  }

  /// Кількість днів, що пройшло з моменту старту.
  int get daysElapsed {
    if (startedAt == null) return 0;
    return DateTime.now().difference(startedAt!).inDays;
  }

  /// Формований залишок часу, наприклад "3 дні", "12 годин".
  String get formattedTimeRemaining {
    if (status != ChallengeStatus.active) {
      return '$durationDays дн';
    }
    final days = daysRemaining;
    final hours = hoursRemaining % 24;
    if (days > 0) {
      return hours > 0 ? '$days дн $hours год' : '$days дн';
    }
    if (hours > 0) {
      final mins = (minutesRemaining % 60);
      return mins > 0 ? '$hours год $mins хв' : '$hours год';
    }
    final mins = minutesRemaining;
    return '$mins хв';
  }

  /// Дата створення/реєстрації челенджу (чи це був колись запущений).
  String get formattedStartDate {
    if (startedAt == null) return 'Не розпочато';
    return DateFormat('dd.MM.yyyy').format(startedAt!);
  }

  /// Дата завершення (якщо є).
  String get formattedCompletedDate {
    if (completedAt == null) return '—';
    return DateFormat('dd.MM.yyyy').format(completedAt!);
  }

  /// Тривалість у людському форматі.
  String get formattedDuration {
    if (durationDays == 1) return '1 день';
    if (durationDays < 5) return '$durationDays дні';
    if (durationDays < 30) return '$durationDays днів';
    return '${durationDays ~/ 7} тижнів';
  }

  // ─── Прогрес ───────────────────────────────────────────────────────

  /// Прогрес челенджу (0.0 – 1.0).
  double get progressPercent {
    if (durationDays <= 0) return 1.0;
    return (currentDay / durationDays).clamp(0.0, 1.0);
  }

  /// Прогрес у відсотках, наприклад "42.9%".
  String get formattedProgress => '${(progressPercent * 100).toStringAsFixed(1)}%';

  /// Кількість виконаних днів.
  int get completedDays => dailyProgressList.where((done) => done).length;

  /// Кількість невиконаних днів.
  int get remainingDays => durationDays - completedDays;

  /// Відсоток виконаних днів від загальної тривалості.
  double get completionRate {
    if (durationDays <= 0) return 0;
    return (completedDays / durationDays).clamp(0.0, 1.0);
  }

  /// Прогрес-бар для щоденного виконання (0.0–1.0).
  double get dayProgress {
    if (dailyProgressList.isEmpty || currentDay >= dailyProgressList.length) {
      return 0;
    }
    return dailyProgressList[currentDay] ? 1.0 : 0.0;
  }

  /// Чи виконано сьогоднішній день.
  bool get isTodayDone {
    if (status != ChallengeStatus.active || dailyProgressList.isEmpty) {
      return false;
    }
    if (currentDay >= dailyProgressList.length) return false;
    return dailyProgressList[currentDay];
  }

  /// Чи пропущено сьогоднішній день.
  bool get isTodaySkipped {
    if (status != ChallengeStatus.active) return false;
    if (currentDay >= durationDays) return false;
    return !isTodayDone;
  }

  /// Мотиваційне повідомлення на основі прогресу.
  String get progressMessage {
    if (isCompleted) return '🏆 Челендж успішно завершено! Вітаємо!';
    if (isFailed) return '💔 На жаль, час вийшов. Спробуй ще раз!';
    if (isExpired) return '⏰ Час вийшов! Спробуй знову.';
    if (progressPercent >= 0.8) return '🔥 Майже там! Лише кілька днів залишилося!';
    if (progressPercent >= 0.5) return '💪 Половина шляху позаду! Ти впораєшся!';
    if (progressPercent >= 0.2) return '🌱 Хороший початок! Продовжуй!';
    if (progressPercent > 0) return '🚀 Рухаєшся! Не зупиняйся.';
    return '🎯 Готовий? Почни свій виклик!';
  }

  /// Статистика прогресу для відображення.
  Map<String, dynamic> get progressStats {
    return {
      'progress': progressPercent,
      'formattedProgress': formattedProgress,
      'completedDays': completedDays,
      'remainingDays': remainingDays,
      'completionRate': completionRate,
      'daysRemaining': daysRemaining,
      'isTodayDone': isTodayDone,
    };
  }

  // ─── Дедлайн та нагорода ───────────────────────────────────────────

  /// Дата дедлайну (якщо челендж запущено).
  DateTime? get deadline {
    if (startedAt == null) return null;
    return startedAt!.add(Duration(days: durationDays));
  }

  /// Форматований дедлайн, наприклад "до 20 січня 2025".
  String get formattedDeadline {
    if (startedAt == null) return 'Не розпочато';
    final dl = deadline!;
    return 'до ${DateFormat('d MMMM yyyy', 'uk_UA').format(dl)}';
  }

  /// Короткий дедлайн "20.01.2025".
  String get formattedDeadlineShort {
    if (startedAt == null) return '—';
    return DateFormat('dd.MM.yyyy').format(deadline!);
  }

  /// Формована нагорода, наприклад "+500 грн | XP x2".
  String get formattedReward {
    final msg = customRewardMessage;
    if (msg != null && msg.isNotEmpty) return msg;
    final parts = <String>[];
    if (rewardAmount > 0) {
      parts.add('+${rewardAmount.toStringAsFixed(0)} грн');
    }
    if (xpReward > 0) {
      parts.add('+$xpReward XP');
    }
    if (coinsReward > 0) {
      parts.add('+$coinsReward монет');
    }
    return parts.isEmpty ? 'Без нагороди' : parts.join(' | ');
  }

  /// Формована нагорода коротко.
  String get formattedRewardShort {
    if (rewardAmount > 0) return '+${rewardAmount.toStringAsFixed(0)} грн';
    if (xpReward > 0) return '+$xpReward XP';
    return '';
  }

  /// Загальна цінність нагороди (орієнтовна, для сортування).
  double get totalRewardValue {
    return rewardAmount + (xpReward * 0.5) + (coinsReward * 0.2);
  }

  /// Нагорода з множником складності.
  double get scaledRewardValue => totalRewardValue * difficultyMultiplier;

  /// Кількість днів до дедлайну.
  int? get daysUntilDeadline {
    if (startedAt == null) return null;
    final diff = deadline!.difference(DateTime.now()).inDays;
    return diff < 0 ? 0 : diff;
  }

  // ─── Статус перевірка ──────────────────────────────────────────────

  /// Чи активний челендж зараз.
  bool get isActive => status == ChallengeStatus.active;

  /// Чи завершено челендж.
  bool get isCompleted => status == ChallengeStatus.completed;

  /// Чи минув термін виконання.
  bool get isExpired {
    if (status != ChallengeStatus.active || startedAt == null) return false;
    final elapsed = DateTime.now().difference(startedAt!).inDays;
    return elapsed >= durationDays;
  }

  /// Чи доступний для старту.
  bool get isPending => status == ChallengeStatus.available;

  /// Чи провалено.
  bool get isFailed => status == ChallengeStatus.failed;

  /// Чи може бути запущений (статус available і не завершено).
  bool get canStart => status == ChallengeStatus.available;

  /// Чи може бути скасований (статус active).
  bool get canCancel => status == ChallengeStatus.active;

  /// Відсоток успішних спроб.
  double get successRate {
    if (totalAttempts <= 0) return 0;
    return (totalAttempts - failedAttempts) / totalAttempts;
  }

  /// Чи це перша спроба.
  bool get isFirstAttempt => totalAttempts <= 1;

  // ─── Дії ───────────────────────────────────────────────────────────

  /// Починає челендж. Повертає true якщо вдалося почати.
  bool startChallenge() {
    if (status != ChallengeStatus.available) return false;
    status = ChallengeStatus.active;
    startedAt = DateTime.now();
    currentDay = 0;
    dailyProgressList = List.filled(durationDays, false);
    totalAttempts++;
    return true;
  }

  /// Відзначає поточний день як виконаний. Повертає true якщо день завершено.
  bool completeDay() {
    if (status != ChallengeStatus.active) return false;
    if (currentDay >= durationDays) return false;
    if (dailyProgressList.length > currentDay &&
        dailyProgressList[currentDay]) {
      return false;
    }
    if (currentDay < dailyProgressList.length) {
      dailyProgressList[currentDay] = true;
    }
    currentDay++;
    streakConsecutiveDays++;

    if (currentDay >= durationDays) {
      status = ChallengeStatus.completed;
      completedAt = DateTime.now();
      return true;
    }
    return true;
  }

  /// Провалює челендж.
  bool failChallenge() {
    if (status != ChallengeStatus.active) return false;
    status = ChallengeStatus.failed;
    completedAt = DateTime.now();
    failedAttempts++;
    streakConsecutiveDays = 0;
    return true;
  }

  /// Скасовує активний челендж (повертає в статус available).
  bool cancelChallenge() {
    if (status != ChallengeStatus.active) return false;
    status = ChallengeStatus.available;
    startedAt = null;
    completedAt = null;
    currentDay = 0;
    dailyProgressList = [];
    streakConsecutiveDays = 0;
    return true;
  }

  /// Повертає челендж до початкового стану.
  void reset() {
    status = ChallengeStatus.available;
    startedAt = null;
    completedAt = null;
    currentDay = 0;
    dailyProgressList = [];
    streakConsecutiveDays = 0;
  }

  /// Обчислює загальну нагороду за виконання.
  Map<String, int> calculateReward() {
    return {
      'amount': rewardAmount.toInt(),
      'xp': xpReward,
      'coins': coinsReward,
    };
  }

  /// Обчислює нагороду за неповне виконання (пропорційно).
  Map<String, int> calculatePartialReward() {
    final ratio = progressPercent;
    return {
      'amount': (rewardAmount * ratio).toInt(),
      'xp': (xpReward * ratio).toInt(),
      'coins': (coinsReward * ratio).toInt(),
    };
  }

  /// Обчислює нагороду з урахуванням множника складності.
  Map<String, int> calculateScaledReward() {
    final mult = difficultyMultiplier;
    return {
      'amount': (rewardAmount * mult).toInt(),
      'xp': (xpReward * mult).toInt(),
      'coins': (coinsReward * mult).toInt(),
    };
  }

  // ─── Порівняння челенджів ─────────────────────────────────────────

  /// Порівнює цінність нагороди з іншим челенджем.
  int compareRewardValueTo(Challenge other) {
    return totalRewardValue.compareTo(other.totalRewardValue);
  }

  /// Порівнює складність з іншим челенджем.
  int compareDifficultyTo(Challenge other) {
    return other.difficulty.sortOrder.compareTo(difficulty.sortOrder);
  }

  // ─── Серіалізація ──────────────────────────────────────────────────

  factory Challenge.fromJson(Map<String, dynamic> json) {
    return Challenge(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      rewardAmount: (json['rewardAmount'] as num?)?.toDouble() ?? 0,
      xpReward: (json['xpReward'] as int?) ?? 0,
      coinsReward: (json['coinsReward'] as int?) ?? 0,
      durationDays: (json['durationDays'] as int?) ?? 1,
      status: ChallengeStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => ChallengeStatus.available,
      ),
      startedAt: json['startedAt'] != null
          ? DateTime.parse(json['startedAt'] as String)
          : null,
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'] as String)
          : null,
      currentDay: (json['currentDay'] as int?) ?? 0,
      difficulty: ChallengeDifficulty.values.firstWhere(
        (e) => e.name == json['difficulty'],
        orElse: () => ChallengeDifficulty.easy,
      ),
      dailyProgressList: (json['dailyProgressList'] as List<dynamic>?)
              ?.map((e) => e as bool)
              .toList() ??
          [],
      category: ChallengeCategory.values.firstWhere(
        (e) => e.name == (json['category'] ?? 'general'),
        orElse: () => ChallengeCategory.general,
      ),
      streakConsecutiveDays: (json['streakConsecutiveDays'] as int?) ?? 0,
      totalAttempts: (json['totalAttempts'] as int?) ?? 0,
      failedAttempts: (json['failedAttempts'] as int?) ?? 0,
      emoji: json['emoji'] as String?,
      customRewardMessage: json['customRewardMessage'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'rewardAmount': rewardAmount,
      'xpReward': xpReward,
      'coinsReward': coinsReward,
      'durationDays': durationDays,
      'status': status.name,
      'startedAt': startedAt?.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'currentDay': currentDay,
      'difficulty': difficulty.name,
      'dailyProgressList': dailyProgressList,
      'category': category.name,
      'streakConsecutiveDays': streakConsecutiveDays,
      'totalAttempts': totalAttempts,
      'failedAttempts': failedAttempts,
      'emoji': emoji,
      'customRewardMessage': customRewardMessage,
    };
  }

  Challenge copyWith({
    String? id,
    String? title,
    String? description,
    double? rewardAmount,
    int? xpReward,
    int? coinsReward,
    int? durationDays,
    ChallengeStatus? status,
    DateTime? startedAt,
    DateTime? completedAt,
    int? currentDay,
    ChallengeDifficulty? difficulty,
    List<bool>? dailyProgressList,
    bool clearStartedAt = false,
    bool clearCompletedAt = false,
    ChallengeCategory? category,
    int? streakConsecutiveDays,
    int? totalAttempts,
    int? failedAttempts,
    String? emoji,
    String? customRewardMessage,
  }) {
    return Challenge(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      rewardAmount: rewardAmount ?? this.rewardAmount,
      xpReward: xpReward ?? this.xpReward,
      coinsReward: coinsReward ?? this.coinsReward,
      durationDays: durationDays ?? this.durationDays,
      status: status ?? this.status,
      startedAt: clearStartedAt ? null : (startedAt ?? this.startedAt),
      completedAt:
          clearCompletedAt ? null : (completedAt ?? this.completedAt),
      currentDay: currentDay ?? this.currentDay,
      difficulty: difficulty ?? this.difficulty,
      dailyProgressList: dailyProgressList ?? this.dailyProgressList,
      category: category ?? this.category,
      streakConsecutiveDays: streakConsecutiveDays ?? this.streakConsecutiveDays,
      totalAttempts: totalAttempts ?? this.totalAttempts,
      failedAttempts: failedAttempts ?? this.failedAttempts,
      emoji: emoji ?? this.emoji,
      customRewardMessage: customRewardMessage ?? this.customRewardMessage,
    );
  }

  @override
  String toString() =>
      'Challenge(id: $id, title: $title, difficulty: $difficulty, status: $status)';
}

/// Шаблон челенджу (доступні для прийняття виклики).
///
/// Використовується для попереднього перегляду перед початком челенджу.
/// Містить попередньо завантажені шаблони з різними категоріями
/// та рівнями складності, які розблоковуються залежно від рівня користувача.
class ChallengeTemplate {
  final String id;
  final String title;
  final String description;
  final double rewardAmount;
  final int xpReward;
  final int coinsReward;
  final int durationDays;
  final ChallengeDifficulty difficulty;
  final String category;
  final int minLevel;
  final String? emoji;

  const ChallengeTemplate({
    required this.id,
    required this.title,
    required this.description,
    this.rewardAmount = 0,
    this.xpReward = 0,
    this.coinsReward = 0,
    required this.durationDays,
    required this.difficulty,
    this.category = 'загальний',
    this.minLevel = 1,
    this.emoji,
  });

  /// Створює челендж з цього шаблону.
  Challenge createChallenge() {
    return Challenge(
      id: id,
      title: title,
      description: description,
      rewardAmount: rewardAmount,
      xpReward: xpReward,
      coinsReward: coinsReward,
      durationDays: durationDays,
      status: ChallengeStatus.available,
      difficulty: difficulty,
      category: ChallengeCategory.values.firstWhere(
        (e) => e.name == category,
        orElse: () => ChallengeCategory.general,
      ),
      emoji: emoji,
    );
  }

  /// Повна нагорода у вигляді рядка.
  String get formattedFullReward {
    final parts = <String>[];
    if (rewardAmount > 0) parts.add('+${rewardAmount.toStringAsFixed(0)} грн');
    if (xpReward > 0) parts.add('+$xpReward XP');
    if (coinsReward > 0) parts.add('+$coinsReward монет');
    return parts.isEmpty ? '—' : parts.join(' | ');
  }

  /// Чи доступний для вказаного рівня.
  bool isAvailableForLevel(int userLevel) => userLevel >= minLevel;

  /// Тривалість у людському форматі.
  String get formattedDuration {
    if (durationDays == 1) return '1 день';
    if (durationDays < 5) return '$durationDays дні';
    return '$durationDays днів';
  }

  /// Категорія українською.
  String get displayCategory {
    switch (category) {
      case 'економія': return 'Економія';
      case 'регулярність': return 'Регулярність';
      case 'накопичення': return 'Накопичення';
      case 'вибираючи': return 'Відмова від звичок';
      case 'загальний': return 'Загальний';
      default: return category;
    }
  }

  /// Емодзі категорії.
  String get categoryEmoji {
    switch (category) {
      case 'економія': return '💰';
      case 'регулярність': return '📅';
      case 'накопичення': return '🏦';
      case 'вибираючи': return '🚫';
      default: return '🎯';
    }
  }

  /// Попередньо завантажені шаблони челенджів.
  static const List<ChallengeTemplate> preloaded = [
    // ─── Легкі ─────────────────────────────────────────────────────
    ChallengeTemplate(
      id: 'challenge_no_spend_today',
      title: 'Не витрачай нічого сьогодні',
      description:
          'Протягом одного дня не роби жодних покупок, окрім найнеобхіднішого. Збережи кожну гривню!',
      rewardAmount: 150,
      xpReward: 50,
      coinsReward: 25,
      durationDays: 1,
      difficulty: ChallengeDifficulty.easy,
      category: 'економія',
      minLevel: 1,
      emoji: '🛑',
    ),
    ChallengeTemplate(
      id: 'challenge_5_deposits',
      title: '5 внесків за тиждень',
      description:
          'Зроби 5 внесків протягом одного тижня. Може бути будь-яка сума — головне регулярність!',
      rewardAmount: 200,
      xpReward: 80,
      coinsReward: 40,
      durationDays: 7,
      difficulty: ChallengeDifficulty.easy,
      category: 'регулярність',
      minLevel: 1,
      emoji: '✋',
    ),
    ChallengeTemplate(
      id: 'challenge_morning_deposit',
      title: 'Ранковий внесок',
      description:
          'Зроби внесок до 9:00 ранку протягом 3 днів. Ранкові заощадження — найкращі!',
      rewardAmount: 100,
      xpReward: 60,
      coinsReward: 30,
      durationDays: 3,
      difficulty: ChallengeDifficulty.easy,
      category: 'регулярність',
      minLevel: 1,
      emoji: '🌅',
    ),

    // ─── Середні ──────────────────────────────────────────────────
    ChallengeTemplate(
      id: 'challenge_no_coffee',
      title: '7 днів без кави назовні',
      description:
          'Цілий тиждень пий каву вдома замість того, щоб купувати в кафе. Різницю відклади в скарбничку!',
      rewardAmount: 500,
      xpReward: 150,
      coinsReward: 75,
      durationDays: 7,
      difficulty: ChallengeDifficulty.medium,
      category: 'економія',
      minLevel: 2,
      emoji: '☕',
    ),
    ChallengeTemplate(
      id: 'challenge_daily_7',
      title: 'Щоденний внесок 7 днів поспіль',
      description:
          'Роби щонайменше один внесок щодня протягом 7 днів поспіль. Навіть 10 ₴ рахуються!',
      rewardAmount: 300,
      xpReward: 120,
      coinsReward: 50,
      durationDays: 7,
      difficulty: ChallengeDifficulty.medium,
      category: 'регулярність',
      minLevel: 2,
      emoji: '📅',
    ),
    ChallengeTemplate(
      id: 'challenge_no_delivery',
      title: '10 днів без доставки',
      description:
          'Замовляй їжу лише для приготування вдома. Жодної доставки їжі 10 днів поспіль!',
      rewardAmount: 400,
      xpReward: 130,
      coinsReward: 60,
      durationDays: 10,
      difficulty: ChallengeDifficulty.medium,
      category: 'вибираючи',
      minLevel: 2,
      emoji: '🚴',
    ),
    ChallengeTemplate(
      id: 'challenge_round_savings',
      title: 'Тиждень заокруглень',
      description:
          'Протягом тижня відкладай залишки від заокруглення. Мінімум 10 грн за день.',
      rewardAmount: 250,
      xpReward: 100,
      coinsReward: 45,
      durationDays: 7,
      difficulty: ChallengeDifficulty.medium,
      category: 'економія',
      minLevel: 2,
      emoji: '🔄',
    ),

    // ─── Складні ──────────────────────────────────────────────────
    ChallengeTemplate(
      id: 'challenge_1000_week',
      title: 'Збери 1000 грн за тиждень',
      description:
          'Відклади 1000 гривень за 7 днів. Подвійний XP за кожен внесок у цей період!',
      rewardAmount: 0,
      xpReward: 300,
      coinsReward: 100,
      durationDays: 7,
      difficulty: ChallengeDifficulty.hard,
      category: 'накопичення',
      minLevel: 3,
      emoji: '🎯',
    ),
    ChallengeTemplate(
      id: 'challenge_double_amount',
      title: 'Відклади подвійну суму',
      description:
          'Протягом 3 днів відкладай подвійну суму від звичайного внеска. Це серйозне випробування сили волі!',
      rewardAmount: 400,
      xpReward: 200,
      coinsReward: 90,
      durationDays: 3,
      difficulty: ChallengeDifficulty.hard,
      category: 'накопичення',
      minLevel: 3,
      emoji: '💪',
    ),
    ChallengeTemplate(
      id: 'challenge_no_spend_month',
      title: '30 днів без зайвих витрат',
      description:
          'Цілий місяць без імпульсивних покупок. Купуй лише те, що дійсно необхідно!',
      rewardAmount: 1500,
      xpReward: 500,
      coinsReward: 200,
      durationDays: 30,
      difficulty: ChallengeDifficulty.hard,
      category: 'економія',
      minLevel: 4,
      emoji: '🔒',
    ),
    ChallengeTemplate(
      id: 'challenge_5000_month',
      title: 'Збери 5000 грн за місяць',
      description:
          'Відклади 5000 гривень протягом місяця. Легендарний виклик для справжніх майстрів!',
      rewardAmount: 500,
      xpReward: 800,
      coinsReward: 300,
      durationDays: 30,
      difficulty: ChallengeDifficulty.hard,
      category: 'накопичення',
      minLevel: 4,
      emoji: '💎',
    ),
  ];

  /// Усі доступні категорії.
  static List<String> get allCategories => [
        'економія',
        'регулярність',
        'накопичення',
        'вибираючи',
        'загальний',
      ];

  /// Шаблони за категорією.
  static List<ChallengeTemplate> getByCategory(String category) {
    return preloaded.where((t) => t.category == category).toList();
  }

  /// Шаблони за складністю.
  static List<ChallengeTemplate> getByDifficulty(ChallengeDifficulty diff) {
    return preloaded.where((t) => t.difficulty == diff).toList();
  }

  /// Шаблони доступні для вказаного рівня.
  static List<ChallengeTemplate> getAvailableForLevel(int userLevel) {
    return preloaded.where((t) => t.minLevel <= userLevel).toList();
  }

  /// Шаблони відсортовані за цінністю нагороди (найбільш цінні перші).
  static List<ChallengeTemplate> getSortedByReward() {
    final sorted = List<ChallengeTemplate>.from(preloaded);
    sorted.sort((a, b) => b.totalRewardValue.compareTo(a.totalRewardValue));
    return sorted;
  }

  /// Шаблони відсортовані за тривалістю (найкоротші перші).
  static List<ChallengeTemplate> getSortedByDuration() {
    final sorted = List<ChallengeTemplate>.from(preloaded);
    sorted.sort((a, b) => a.durationDays.compareTo(b.durationDays));
    return sorted;
  }

  /// Шаблони відсортовані за складністю (від легкої до складної).
  static List<ChallengeTemplate> getSortedByDifficulty() {
    final sorted = List<ChallengeTemplate>.from(preloaded);
    sorted.sort((a, b) =>
        a.difficulty.sortOrder.compareTo(b.difficulty.sortOrder));
    return sorted;
  }

  /// Знаходить шаблон за ID.
  static ChallengeTemplate? findById(String id) {
    for (final t in preloaded) {
      if (t.id == id) return t;
    }
    return null;
  }

  /// Шукає шаблони за назвою.
  static List<ChallengeTemplate> search(String query) {
    if (query.isEmpty) return preloaded;
    final lower = query.toLowerCase();
    return preloaded.where((t) => t.title.toLowerCase().contains(lower)).toList();
  }

  /// Кількість попередньо завантажених шаблонів.
  static int get totalCount => preloaded.length;

  /// Кількість шаблонів за складністю.
  static int countByDifficulty(ChallengeDifficulty diff) {
    return preloaded.where((t) => t.difficulty == diff).length;
  }

  /// Кількість шаблонів за категорією.
  static int countByCategory(String category) {
    return preloaded.where((t) => t.category == category).length;
  }

  /// Повертає випадковий шаблон.
  static ChallengeTemplate random() {
    final list = preloaded;
    return list[DateTime.now().millisecondsSinceEpoch % list.length];
  }

  /// Повертає випадковий шаблон для вказаного рівня.
  static ChallengeTemplate randomForLevel(int userLevel) {
    final available = getAvailableForLevel(userLevel);
    if (available.isEmpty) return preloaded.first;
    return available[DateTime.now().millisecondsSinceEpoch % available.length];
  }

  /// Повертає шаблони, які ще не виконувались.
  static List<ChallengeTemplate> getNotAttempted(List<String> attemptedIds) {
    return preloaded
        .where((t) => !attemptedIds.contains(t.id))
        .toList();
  }
}
