import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_enums.dart';
import '../../../core/utils/xp_calculator.dart';
import '../../../data/models/challenge_model.dart';
import '../../../data/repositories/challenge_repository.dart';

/// Подія прогресу челенджу для UI.
class ChallengeProgressEvent {
  /// ID челенджу.
  final String challengeId;

  /// Новий день прогресу.
  final int newDay;

  /// Загальна кількість днів челенджу.
  final int totalDays;

  /// Чи завершено челендж.
  final bool isComplete;

  /// XP отримано за завершення дня.
  final int xpEarned;

  /// Монети отримано за завершення дня.
  final int coinsEarned;

  const ChallengeProgressEvent({
    required this.challengeId,
    required this.newDay,
    required this.totalDays,
    this.isComplete = false,
    this.xpEarned = 0,
    this.coinsEarned = 0,
  });
}

/// Запис історії челенджів.
class ChallengeHistoryEntry {
  /// ID челенджу.
  final String challengeId;

  /// Назва челенджу.
  final String name;

  /// Статус завершення.
  final bool wasCompleted;

  /// Кількість виконаних днів.
  final int daysCompleted;

  /// Загальна тривалість.
  final int totalDays;

  /// Дата завершення або провалу.
  final DateTime endedAt;

  /// Складність.
  final ChallengeDifficulty difficulty;

  const ChallengeHistoryEntry({
    required this.challengeId,
    required this.name,
    required this.wasCompleted,
    required this.daysCompleted,
    required this.totalDays,
    required this.endedAt,
    required this.difficulty,
  });
}

/// Стан челенджів.
class ChallengeState {
  /// Поточний активний челендж.
  final Challenge? activeChallenge;

  /// Доступні для прийняття челенджі.
  final List<Challenge> availableChallenges;

  /// Завершені челенджі.
  final List<Challenge> completedChallenges;

  /// Провалені челенджі.
  final List<Challenge> failedChallenges;

  /// Чи завантажуються дані.
  final bool isLoading;

  /// Помилка (якщо є).
  final String? error;

  /// Карта прогресу челенджів за ID.
  final Map<String, int> challengeProgress;

  /// ID активного фільтру складності.
  final ChallengeDifficulty? difficultyFilter;

  /// Остання подія прогресу (для UI анімацій).
  final ChallengeProgressEvent? lastProgressEvent;

  /// Пошуковий запит для фільтрації.
  final String searchQuery;

  /// Сортування челенджів.
  final ChallengeSortOption sortBy;

  /// Історія завершених та провалених челенджів.
  final List<ChallengeHistoryEntry> history;

  const ChallengeState({
    this.activeChallenge,
    this.availableChallenges = const [],
    this.completedChallenges = const [],
    this.failedChallenges = const [],
    this.isLoading = false,
    this.error,
    this.challengeProgress = const {},
    this.difficultyFilter,
    this.lastProgressEvent,
    this.searchQuery = '',
    this.sortBy = ChallengeSortOption.recommended,
    this.history = const [],
  });

  ChallengeState copyWith({
    Challenge? activeChallenge,
    List<Challenge>? availableChallenges,
    List<Challenge>? completedChallenges,
    List<Challenge>? failedChallenges,
    bool? isLoading,
    String? error,
    Map<String, int>? challengeProgress,
    ChallengeDifficulty? difficultyFilter,
    ChallengeProgressEvent? lastProgressEvent,
    String? searchQuery,
    ChallengeSortOption? sortBy,
    List<ChallengeHistoryEntry>? history,
    bool clearActiveChallenge = false,
    bool clearError = false,
    bool clearProgressEvent = false,
    bool clearFilter = false,
  }) {
    return ChallengeState(
      activeChallenge:
          clearActiveChallenge ? null : (activeChallenge ?? this.activeChallenge),
      availableChallenges: availableChallenges ?? this.availableChallenges,
      completedChallenges: completedChallenges ?? this.completedChallenges,
      failedChallenges: failedChallenges ?? this.failedChallenges,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      challengeProgress: challengeProgress ?? this.challengeProgress,
      difficultyFilter: clearFilter ? null : (difficultyFilter ?? this.difficultyFilter),
      lastProgressEvent:
          clearProgressEvent ? null : (lastProgressEvent ?? this.lastProgressEvent),
      searchQuery: searchQuery ?? this.searchQuery,
      sortBy: sortBy ?? this.sortBy,
      history: history ?? this.history,
    );
  }
}

/// Опції сортування челенджів.
enum ChallengeSortOption {
  /// За рекомендацією (легкі першими).
  recommended,

  /// За складністю (легкі першими).
  difficulty,

  /// За тривалістю (коротші перші).
  duration,

  /// За винагородою (більші перші).
  reward,

  /// За назвою (алфавітно).
  name,
}

/// Нотифікатор для керування станом челенджів.
class ChallengeNotifier extends StateNotifier<ChallengeState> {
  final ChallengeRepository _challengeRepo;

  /// Таймер для перевірки закінчення челенджів.
  Timer? _expirationTimer;

  /// Таймер нагадування про активний челендж.
  Timer? _reminderTimer;

  ChallengeNotifier({
    required ChallengeRepository challengeRepo,
  })  : _challengeRepo = challengeRepo,
        super(const ChallengeState()) {
    _startExpirationTimer();
    _startReminderTimer();
  }

  // ─── Завантаження ─────────────────────────────────────────

  /// Завантажує всі челенджі.
  Future<void> load() async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final active = _challengeRepo.getActive();
      final available = _challengeRepo.getAvailable();
      final completed = _challengeRepo.getCompleted();
      final failed = _challengeRepo.getFailed();

      // Відновлюємо карту прогресу.
      final progress = <String, int>{};
      for (final challenge in [...completed, ...failed, ...? [active]]) {
        if (challenge != null) {
          progress[challenge.id] = challenge.currentDay;
        }
      }

      // Формуємо історію.
      final historyEntries = <ChallengeHistoryEntry>[
        ...completed.map((c) => ChallengeHistoryEntry(
          challengeId: c.id,
          name: c.name,
          wasCompleted: true,
          daysCompleted: c.durationDays,
          totalDays: c.durationDays,
          endedAt: c.completedAt ?? DateTime.now(),
          difficulty: c.difficulty,
        )),
        ...failed.map((c) => ChallengeHistoryEntry(
          challengeId: c.id,
          name: c.name,
          wasCompleted: false,
          daysCompleted: c.currentDay,
          totalDays: c.durationDays,
          endedAt: c.completedAt ?? DateTime.now(),
          difficulty: c.difficulty,
        )),
      ];

      state = state.copyWith(
        activeChallenge: active,
        availableChallenges: available,
        completedChallenges: completed,
        failedChallenges: failed,
        isLoading: false,
        challengeProgress: progress,
        history: historyEntries,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Помилка завантаження челенджів: $e',
      );
    }
  }

  // ─── Управління челенджами ────────────────────────────────

  /// Приймає челендж за його ID.
  void acceptChallenge(String id) {
    // Перевіряємо, чи немає вже активного челенджу.
    if (state.activeChallenge != null) {
      state = state.copyWith(error: 'Ви вже маєте активний челендж. Спершу завершіть його.');
      return;
    }

    final challenge = _challengeRepo.getById(id);
    if (challenge == null) {
      state = state.copyWith(error: 'Челендж не знайдено');
      return;
    }

    if (challenge.status != ChallengeStatus.available) {
      state = state.copyWith(error: 'Цей челендж вже недоступний');
      return;
    }

    final startedChallenge = challenge.copyWith(
      status: ChallengeStatus.active,
      startedAt: DateTime.now(),
      currentDay: 0,
    );

    _challengeRepo.save(startedChallenge);

    // Оновлюємо список доступних.
    final available = _challengeRepo.getAvailable();

    // Оновлюємо карту прогресу.
    final updatedProgress = Map<String, int>.from(state.challengeProgress);
    updatedProgress[challenge.id] = 0;

    state = state.copyWith(
      activeChallenge: startedChallenge,
      availableChallenges: available,
      challengeProgress: updatedProgress,
      clearError: true,
    );
  }

  /// Відзначає поточний день як виконаний.
  void completeDay() {
    final active = state.activeChallenge;
    if (active == null) return;

    final updatedDay = active.currentDay + 1;
    final isComplete = updatedDay >= active.durationDays;

    // Обчислюємо винагороду за день
    final xpPerDay = (active.xpReward / active.durationDays).round();
    final coinsPerDay = (active.coinsReward / active.durationDays).round();

    final updatedChallenge = active.copyWith(
      currentDay: updatedDay,
      status: isComplete ? ChallengeStatus.completed : null,
      completedAt: isComplete ? DateTime.now() : null,
    );

    _challengeRepo.save(updatedChallenge);

    // Оновлюємо карту прогресу.
    final updatedProgress = Map<String, int>.from(state.challengeProgress);
    updatedProgress[active.id] = updatedDay;

    // Створюємо подію прогресу.
    final progressEvent = ChallengeProgressEvent(
      challengeId: active.id,
      newDay: updatedDay,
      totalDays: active.durationDays,
      isComplete: isComplete,
      xpEarned: xpPerDay,
      coinsEarned: coinsPerDay,
    );

    if (isComplete) {
      final completed = _challengeRepo.getCompleted();

      // Додаємо до історії
      final historyEntry = ChallengeHistoryEntry(
        challengeId: active.id,
        name: active.name,
        wasCompleted: true,
        daysCompleted: updatedDay,
        totalDays: active.durationDays,
        endedAt: DateTime.now(),
        difficulty: active.difficulty,
      );

      final updatedHistory = [historyEntry, ...state.history];

      state = state.copyWith(
        activeChallenge: null,
        completedChallenges: completed,
        challengeProgress: updatedProgress,
        lastProgressEvent: progressEvent,
        clearActiveChallenge: true,
        history: updatedHistory,
      );
    } else {
      state = state.copyWith(
        activeChallenge: updatedChallenge,
        challengeProgress: updatedProgress,
        lastProgressEvent: progressEvent,
      );
    }
  }

  /// Звіт за поточний день челенджу за ID.
  void reportTodayProgress(String id) {
    final active = state.activeChallenge;
    if (active == null || active.id != id) {
      state = state.copyWith(error: 'Активний челендж не збігається');
      return;
    }

    // Перевіряємо, чи день вже відзначено сьогодні.
    if (active.startedAt != null) {
      final now = DateTime.now();
      final lastReportedDay = active.startedAt!.add(Duration(days: active.currentDay));
      if (now.isBefore(lastReportedDay)) {
        state = state.copyWith(error: 'Ви вже відзвітували за сьогодні');
        return;
      }
    }

    completeDay();
  }

  /// Перевіряє та закінчує прострочені челенджі.
  void checkAndExpireChallenges() {
    final active = state.activeChallenge;
    if (active == null) return;

    if (active.isExpired) {
      final expired = active.copyWith(status: ChallengeStatus.failed);
      _challengeRepo.save(expired);

      final failed = _challengeRepo.getFailed();

      // Оновлюємо карту прогресу.
      final updatedProgress = Map<String, int>.from(state.challengeProgress);
      updatedProgress[active.id] = active.currentDay;

      // Додаємо до історії
      final historyEntry = ChallengeHistoryEntry(
        challengeId: active.id,
        name: active.name,
        wasCompleted: false,
        daysCompleted: active.currentDay,
        totalDays: active.durationDays,
        endedAt: DateTime.now(),
        difficulty: active.difficulty,
      );

      final updatedHistory = [historyEntry, ...state.history];

      state = state.copyWith(
        activeChallenge: null,
        failedChallenges: failed,
        challengeProgress: updatedProgress,
        clearActiveChallenge: true,
        history: updatedHistory,
      );
    }
  }

  /// Скасовує активний челендж.
  void cancelActiveChallenge() {
    final active = state.activeChallenge;
    if (active == null) return;

    final cancelled = active.copyWith(status: ChallengeStatus.failed);
    _challengeRepo.save(cancelled);

    final failed = _challengeRepo.getFailed();
    final available = _challengeRepo.getAvailable();

    // Додаємо до історії
    final historyEntry = ChallengeHistoryEntry(
      challengeId: active.id,
      name: active.name,
      wasCompleted: false,
      daysCompleted: active.currentDay,
      totalDays: active.durationDays,
      endedAt: DateTime.now(),
      difficulty: active.difficulty,
    );

    final updatedHistory = [historyEntry, ...state.history];

    state = state.copyWith(
      activeChallenge: null,
      failedChallenges: failed,
      availableChallenges: available,
      clearActiveChallenge: true,
      history: updatedHistory,
    );
  }

  // ─── Прогрес активного челенджу ───────────────────────────

  /// Прогрес активного челенджу у відсотках.
  double get activeChallengeProgress {
    final active = state.activeChallenge;
    if (active == null) return 0;
    if (active.durationDays <= 0) return 1.0;
    return (active.currentDay / active.durationDays).clamp(0.0, 1.0);
  }

  /// Залишок днів активного челенджу.
  int get activeChallengeRemainingDays {
    final active = state.activeChallenge;
    if (active == null) return 0;
    return (active.durationDays - active.currentDay).clamp(0, active.durationDays);
  }

  /// Чи активний челендж закінчується сьогодні.
  bool get isActiveChallengeEndingToday {
    final active = state.activeChallenge;
    if (active == null) return false;
    return activeChallengeRemainingDays <= 1;
  }

  /// Форматований прогрес активного челенджу.
  String get activeChallengeProgressText {
    final active = state.activeChallenge;
    if (active == null) return '—';
    return '${active.currentDay} / ${active.durationDays} днів';
  }

  // ─── Гетери ───────────────────────────────────────────────

  /// Повертає активний челендж.
  Challenge? getActiveChallenge() {
    return state.activeChallenge;
  }

  /// Повертає список доступних челенджів.
  List<Challenge> getAvailableChallenges() {
    var challenges = state.availableChallenges;

    // Фільтруємо за складністю, якщо встановлено.
    if (state.difficultyFilter != null) {
      challenges = challenges
          .where((c) => c.difficulty == state.difficultyFilter)
          .toList();
    }

    // Пошук за назвою.
    if (state.searchQuery.isNotEmpty) {
      final query = state.searchQuery.toLowerCase();
      challenges = challenges
          .where((c) => c.name.toLowerCase().contains(query))
          .toList();
    }

    // Сортування.
    switch (state.sortBy) {
      case ChallengeSortOption.recommended:
        challenges.sort((a, b) {
          final order = {ChallengeDifficulty.easy: 0, ChallengeDifficulty.medium: 1, ChallengeDifficulty.hard: 2};
          return (order[a.difficulty] ?? 0).compareTo(order[b.difficulty] ?? 0);
        });
        break;
      case ChallengeSortOption.difficulty:
        challenges.sort((a, b) {
          final order = {ChallengeDifficulty.easy: 0, ChallengeDifficulty.medium: 1, ChallengeDifficulty.hard: 2};
          return (order[a.difficulty] ?? 0).compareTo(order[b.difficulty] ?? 0);
        });
        break;
      case ChallengeSortOption.duration:
        challenges.sort((a, b) => a.durationDays.compareTo(b.durationDays));
        break;
      case ChallengeSortOption.reward:
        challenges.sort((a, b) => b.xpReward.compareTo(a.xpReward));
        break;
      case ChallengeSortOption.name:
        challenges.sort((a, b) => a.name.compareTo(b.name));
        break;
    }

    return challenges;
  }

  /// Повертає список завершених челенджів.
  List<Challenge> getCompletedChallenges() {
    return state.completedChallenges;
  }

  /// Повертає список провалених челенджів.
  List<Challenge> getFailedChallenges() {
    return state.failedChallenges;
  }

  /// Повертає загальну кількість завершених челенджів.
  int get completedCount => state.completedChallenges.length;

  /// Повертає загальну кількість провалених челенджів.
  int get failedCount => state.failedChallenges.length;

  /// Повертає загальну кількість челенджів (всіх типів).
  int get totalChallengesCount {
    return state.availableChallenges.length +
        state.completedChallenges.length +
        state.failedChallenges.length +
        (state.activeChallenge != null ? 1 : 0);
  }

  /// Повертає відсоток успішних челенджів.
  double get successRate {
    final total = completedCount + failedCount;
    if (total == 0) return 0;
    return (completedCount / total) * 100;
  }

  // ─── Нагороди ─────────────────────────────────────────────

  /// Загальний XP, отриманий за завершені челенджі.
  int get totalXpEarned {
    return state.completedChallenges.fold<int>(
      0,
      (sum, c) => sum + c.xpReward,
    );
  }

  /// Загальні монети, отримані за завершені челенджі.
  int get totalCoinsEarned {
    return state.completedChallenges.fold<int>(
      0,
      (sum, c) => sum + c.coinsReward,
    );
  }

  /// Загальна винагорода у гривнях.
  double get totalRewardAmount {
    return state.completedChallenges.fold<double>(
      0.0,
      (sum, c) => sum + c.rewardAmount,
    );
  }

  /// Обчислює винагороду за конкретний челендж.
  ///
  /// Повертає карту з XP, монетами та сумою винагороди.
  Map<String, dynamic> calculateChallengeRewards(String challengeId) {
    final challenge = _challengeRepo.getById(challengeId);
    if (challenge == null) {
      return {'xp': 0, 'coins': 0, 'amount': 0.0};
    }

    // Бонус за складність.
    double difficultyMultiplier = 1.0;
    switch (challenge.difficulty) {
      case ChallengeDifficulty.easy:
        difficultyMultiplier = 1.0;
        break;
      case ChallengeDifficulty.medium:
        difficultyMultiplier = 1.5;
        break;
      case ChallengeDifficulty.hard:
        difficultyMultiplier = 2.0;
        break;
    }

    return {
      'xp': (challenge.xpReward * difficultyMultiplier).toInt(),
      'coins': (challenge.coinsReward * difficultyMultiplier).toInt(),
      'amount': challenge.rewardAmount * difficultyMultiplier,
    };
  }

  /// Повертає винагороду за день для активного челенджу.
  Map<String, int> get dailyRewardForActive {
    final active = state.activeChallenge;
    if (active == null) return {'xp': 0, 'coins': 0};
    return {
      'xp': (active.xpReward / active.durationDays).round(),
      'coins': (active.coinsReward / active.durationDays).round(),
    };
  }

  // ─── Щоденні пропозиції ───────────────────────────────────

  /// Повертає щоденну пропозицію челенджу.
  ///
  /// Обирає випадковий доступний челендж, який відповідає критеріям:
  /// - користувач ще не завершував цей тип челенджу;
  /// - челендж відповідає поточному фільтру (якщо встановлено).
  Challenge? getDailySuggestion() {
    final available = getAvailableChallenges();
    if (available.isEmpty) return null;

    // Пріоритет для легких челенджів.
    final easyFirst = List<Challenge>.from(available)
      ..sort((a, b) {
        final order = {ChallengeDifficulty.easy: 0, ChallengeDifficulty.medium: 1, ChallengeDifficulty.hard: 2};
        return (order[a.difficulty] ?? 0).compareTo(order[b.difficulty] ?? 0);
      });

    return easyFirst.first;
  }

  /// Повертає список рекомендацій челенджів на основі історії.
  List<Challenge> getRecommendedChallenges() {
    final available = getAvailableChallenges();
    if (available.isEmpty) return [];

    // Схильність користувача: якщо високий успіх — важчі, якщо низький — легші
    final rate = successRate;
    if (rate >= 70) {
      // Рекомендуємо середні та важкі
      return available
          .where((c) => c.difficulty != ChallengeDifficulty.easy)
          .toList();
    } else if (rate <= 30) {
      // Рекомендуємо лише легкі
      return available
          .where((c) => c.difficulty == ChallengeDifficulty.easy)
          .toList();
    }

    return available;
  }

  /// Повертає кількість доступних челенджів.
  int get availableCount => getAvailableChallenges().length;

  // ─── Скалювання складності ────────────────────────────────

  /// Повертає рекомендовану складність на основі історії.
  ChallengeDifficulty? get recommendedDifficulty {
    final rate = successRate;
    if (completedCount == 0) return ChallengeDifficulty.easy;
    if (rate >= 80 && completedCount >= 3) return ChallengeDifficulty.hard;
    if (rate >= 50 && completedCount >= 2) return ChallengeDifficulty.medium;
    return ChallengeDifficulty.easy;
  }

  /// Повертає опис складності українською.
  String difficultyLabel(ChallengeDifficulty difficulty) {
    switch (difficulty) {
      case ChallengeDifficulty.easy:
        return 'Легкий';
      case ChallengeDifficulty.medium:
        return 'Середній';
      case ChallengeDifficulty.hard:
        return 'Складний';
    }
  }

  // ─── Пошук та фільтрація ──────────────────────────────────

  /// Встановлює пошуковий запит.
  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  /// Встановлює порядок сортування.
  void setSortOption(ChallengeSortOption option) {
    state = state.copyWith(sortBy: option);
  }

  /// Встановлює фільтр за складністю.
  void setDifficultyFilter(ChallengeDifficulty? difficulty) {
    state = state.copyWith(
      difficultyFilter: difficulty,
      clearFilter: difficulty == null,
    );
  }

  /// Перемикає фільтр за складністю (чергування: none → easy → medium → hard → none).
  void cycleDifficultyFilter() {
    final current = state.difficultyFilter;
    switch (current) {
      case null:
        setDifficultyFilter(ChallengeDifficulty.easy);
        break;
      case ChallengeDifficulty.easy:
        setDifficultyFilter(ChallengeDifficulty.medium);
        break;
      case ChallengeDifficulty.medium:
        setDifficultyFilter(ChallengeDifficulty.hard);
        break;
      case ChallengeDifficulty.hard:
        setDifficultyFilter(null);
        break;
    }
  }

  /// Скидає всі фільтри.
  void clearFilters() {
    state = state.copyWith(
      searchQuery: '',
      sortBy: ChallengeSortOption.recommended,
      clearFilter: true,
    );
  }

  // ─── Очищення подій ───────────────────────────────────────

  /// Очищає останню подію прогресу (після обробки в UI).
  void clearProgressEvent() {
    state = state.copyWith(clearProgressEvent: true);
  }

  /// Очищає помилку.
  void clearError() {
    state = state.copyWith(clearError: true);
  }

  // ─── Таймери ──────────────────────────────────────────────

  /// Запускає періодичний таймер перевірки закінчення челенджів.
  void _startExpirationTimer() {
    _expirationTimer?.cancel();
    _expirationTimer = Timer.periodic(
      const Duration(minutes: 5),
      (_) => checkAndExpireChallenges(),
    );
  }

  /// Запускає таймер нагадування про активний челендж.
  void _startReminderTimer() {
    _reminderTimer?.cancel();
    _reminderTimer = Timer.periodic(
      const Duration(hours: 1),
      (_) => _checkReminderNeeded(),
    );
  }

  /// Перевіряє, чи потрібне нагадування про активний челендж.
  void _checkReminderNeeded() {
    final active = state.activeChallenge;
    if (active == null) return;

    // Нагадування, якщо залишився 1 день
    final remaining = active.durationDays - active.currentDay;
    if (remaining <= 1 && remaining > 0) {
      // У майбутньому: відправити push-сповіщення
      debugPrint('🔔 Нагадування: челендж «${active.name}» закінчується завтра!');
    }
  }

  // ─── Запити історії ───────────────────────────────────────

  /// Повертає історію за останні N записів.
  List<ChallengeHistoryEntry> getRecentHistory([int limit = 10]) {
    if (state.history.length <= limit) return state.history;
    return state.history.sublist(0, limit);
  }

  /// Повертає статистику за певний період.
  Map<String, dynamic> getHistoryStats({DateTime? since}) {
    final filtered = since != null
        ? state.history.where((h) => h.endedAt.isAfter(since)).toList()
        : state.history;

    final completed = filtered.where((h) => h.wasCompleted).length;
    final failed = filtered.where((h) => !h.wasCompleted).length;
    final totalDays = filtered.fold<int>(0, (sum, h) => sum + h.daysCompleted);
    final avgDays = completed > 0
        ? (totalDays / completed).round()
        : 0;

    return {
      'total': filtered.length,
      'completed': completed,
      'failed': failed,
      'success_rate': completed + failed > 0
          ? ((completed / (completed + failed)) * 100).toStringAsFixed(1)
          : '0.0',
      'total_days': totalDays,
      'avg_completion_days': avgDays,
    };
  }

  // ─── Звільнення ресурсів ──────────────────────────────────

  @override
  void dispose() {
    _expirationTimer?.cancel();
    _reminderTimer?.cancel();
    super.dispose();
  }
}

// ─── Провайдери залежностей ─────────────────────────────────────────

/// Провайдер для ChallengeRepository.
final challengeRepositoryProvider = Provider<ChallengeRepository>(
  (ref) => ChallengeRepository(),
);

// ─── Головний провайдер челенджів ───────────────────────────────────

/// Riverpod провайдер для стану челенджів.
final challengeProvider =
    StateNotifierProvider<ChallengeNotifier, ChallengeState>(
  (ref) => ChallengeNotifier(
    challengeRepo: ref.watch(challengeRepositoryProvider),
  ),
);

// ═══════════════════════════════════════════════════════════════════════════
// Challenge State Extensions
// ═══════════════════════════════════════════════════════════════════════════

/// Розширення для [ChallengeState] з обчислюваними властивостями.
extension ChallengeStateExtensions on ChallengeState {
  /// Чи користувач має активний челендж наразі.
  bool get hasActiveChallenge => activeChallenge != null;

  /// Чи є помилка.
  bool get hasError => error != null && error!.isNotEmpty;

  /// Чи є подія прогресу для UI.
  bool get hasProgressEvent => lastProgressEvent != null;

  /// Чи історія порожня.
  bool get hasHistory => history.isNotEmpty;

  /// Чи є пошуковий запит.
  bool get hasSearchQuery => searchQuery.isNotEmpty;

  /// Чи встановлено фільтр складності.
  bool get hasDifficultyFilter => difficultyFilter != null;

  /// Загальна кількість днів, виконаних у всіх челенджах.
  int get totalDaysCompleted {
    return completedChallenges.fold<int>(
      0,
      (sum, c) => sum + c.durationDays,
    );
  }

  /// Загальна тривалість всіх челенджів (дні).
  int get totalDaysAllChallenges {
    return [...completedChallenges, ...failedChallenges]
        .fold<int>(0, (sum, c) => sum + c.durationDays);
  }

  /// Середня тривалість завершених челенджів (дні).
  double get averageCompletedDuration {
    if (completedChallenges.isEmpty) return 0;
    return totalDaysCompleted / completedChallenges.length;
  }

  /// Загальний XP за всі завершені челенджі.
  int get totalXpFromCompleted {
    return completedChallenges.fold<int>(
      0,
      (sum, c) => sum + c.xpReward,
    );
  }

  /// Загальні монети за всі завершені челенджі.
  int get totalCoinsFromCompleted {
    return completedChallenges.fold<int>(
      0,
      (sum, c) => sum + c.coinsReward,
    );
  }

  /// Чи користувач є новачком (немає завершених челенджів).
  bool get isBeginner => completedChallenges.isEmpty && failedChallenges.isEmpty;

  /// Найтриваліший завершений челендж (дні).
  int get longestCompletedChallenge {
    if (completedChallenges.isEmpty) return 0;
    return completedChallenges
        .map((c) => c.durationDays)
        .fold<int>(0, (max, d) => d > max ? d : max);
  }

  /// Найкоротший завершений челендж (дні).
  int get shortestCompletedChallenge {
    if (completedChallenges.isEmpty) return 0;
    return completedChallenges
        .map((c) => c.durationDays)
        .fold<int>(double.maxFinite.toInt(), (min, d) => d < min ? d : min);
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Challenge Progress Event Extensions
// ═══════════════════════════════════════════════════════════════════════════

/// Розширення для [ChallengeProgressEvent] з допоміжними методами.
extension ChallengeProgressEventExtensions on ChallengeProgressEvent {
  /// Прогрес у відсотках (0.0 — 1.0).
  double get progressPercent {
    if (totalDays <= 0) return 1.0;
    return (newDay / totalDays).clamp(0.0, 1.0);
  }

  /// Прогрес у відсотках (0 — 100).
  double get progressPercent100 => progressPercent * 100;

  /// Форматований прогрес (наприклад, «5/7»).
  String get formattedProgress => '$newDay / $totalDays';

  /// Форматований відсоток (наприклад, «71%»).
  String get formattedPercent => '${progressPercent100.toStringAsFixed(0)}%';

  /// Загальна винагорода за день (XP + монети як рядок).
  String get rewardSummary => 'XP +$xpEarned, Монети +$coinsEarned';

  /// Чи це фінальний день челенджу.
  bool get isLastDay => newDay >= totalDays;

  /// Залишок днів до завершення.
  int get remainingDays => (totalDays - newDay).clamp(0, totalDays);

  /// Форматований опис для push-сповіщення.
  String get notificationBody {
    if (isComplete) {
      return '🎉 Челендж завершено! $rewardSummary';
    }
    return 'День $newDay з $totalDays завершено. $rewardSummary';
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Challenge History Entry Extensions
// ═══════════════════════════════════════════════════════════════════════════

/// Розширення для [ChallengeHistoryEntry] з допоміжними методами.
extension ChallengeHistoryEntryExtensions on ChallengeHistoryEntry {
  /// Тривалість в днях.
  int get durationDays => totalDays;

  /// Прогрес завершення у відсотках (0.0 — 1.0).
  double get completionRatio {
    if (totalDays <= 0) return 0;
    return (daysCompleted / totalDays).clamp(0.0, 1.0);
  }

  /// Чи челендж було повністю завершено.
  bool get isFullyCompleted => wasCompleted && daysCompleted >= totalDays;

  /// Форматована дата завершення (ДД.ММ.РРРР).
  String get formattedEndDate {
    final d = endedAt.day.toString().padLeft(2, '0');
    final m = endedAt.month.toString().padLeft(2, '0');
    return '$d.$m.${endedAt.year}';
  }

  /// Форматований час завершення (ГГ:ХХ).
  String get formattedEndTime {
    return '${endedAt.hour.toString().padLeft(2, '0')}:'
        '${endedAt.minute.toString().padLeft(2, '0')}';
  }

  /// Відносний час завершення (наприклад, «3 дн тому»).
  String get relativeEndTime {
    final now = DateTime.now();
    final diff = now.difference(endedAt);
    if (diff.inSeconds < 60) return 'щойно';
    if (diff.inMinutes < 60) return '${diff.inMinutes} хв тому';
    if (diff.inHours < 24) return '${diff.inHours} год тому';
    if (diff.inDays < 7) return '${diff.inDays} дн тому';
    if (diff.inDays < 30) return '${(diff.inDays / 7).floor()} тиж тому';
    return '${(diff.inDays / 30).floor()} міс тому';
  }

  /// Статус запису українською.
  String get statusLabel => wasCompleted ? 'Завершено' : 'Провалено';

  /// Іконка статусу.
  IconData get statusIcon =>
      wasCompleted ? Icons.check_circle_rounded : Icons.cancel_rounded;

  /// Колір статусу.
  Color get statusColor => wasCompleted
      ? const Color(0xFF2ECC71)
      : const Color(0xFFE74C3C);

  /// Складність українською.
  String get difficultyLabel {
    switch (difficulty) {
      case ChallengeDifficulty.easy:
        return 'Легкий';
      case ChallengeDifficulty.medium:
        return 'Середній';
      case ChallengeDifficulty.hard:
        return 'Складний';
    }
  }

  /// Опис результату для UI.
  String get resultDescription {
    if (wasCompleted) {
      return '$name — $daysCompleted/$totalDays днів ✅';
    }
    return '$name — $daysCompleted/$totalDays днів ❌';
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Challenge Sort Option Extensions
// ═══════════════════════════════════════════════════════════════════════════

/// Розширення для [ChallengeSortOption] з допоміжними методами.
extension ChallengeSortOptionExtensions on ChallengeSortOption {
  /// Мітка варіанту сортування українською.
  String get label {
    switch (this) {
      case ChallengeSortOption.recommended:
        return 'Рекомендовані';
      case ChallengeSortOption.difficulty:
        return 'За складністю';
      case ChallengeSortOption.duration:
        return 'За тривалістю';
      case ChallengeSortOption.reward:
        return 'За винагородою';
      case ChallengeSortOption.name:
        return 'За назвою';
    }
  }

  /// Іконка варіанту сортування.
  IconData get icon {
    switch (this) {
      case ChallengeSortOption.recommended:
        return Icons.star_rounded;
      case ChallengeSortOption.difficulty:
        return Icons.signal_cellular_alt_rounded;
      case ChallengeSortOption.duration:
        return Icons.schedule_rounded;
      case ChallengeSortOption.reward:
        return Icons.card_giftcard_rounded;
      case ChallengeSortOption.name:
        return Icons.sort_by_alpha_rounded;
    }
  }

  /// Наступний варіант сортування (циклічний).
  ChallengeSortOption get next {
    switch (this) {
      case ChallengeSortOption.recommended:
        return ChallengeSortOption.difficulty;
      case ChallengeSortOption.difficulty:
        return ChallengeSortOption.duration;
      case ChallengeSortOption.duration:
        return ChallengeSortOption.reward;
      case ChallengeSortOption.reward:
        return ChallengeSortOption.name;
      case ChallengeSortOption.name:
        return ChallengeSortOption.recommended;
    }
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Challenge Validation & Helpers
// ═══════════════════════════════════════════════════════════════════════════

/// Валідатори та допоміжні методи для челенджів.
class ChallengeValidator {
  /// Константа — не дозволяємо створювати екземпляри.
  ChallengeValidator._();

  /// Мінімальна тривалість челенджу (дні).
  static const int minDurationDays = 1;

  /// Максимальна тривалість челенджу (дні).
  static const int maxDurationDays = 365;

  /// Мінімальна винагорода XP.
  static const int minXpReward = 10;

  /// Максимальна винагорода XP.
  static const int maxXpReward = 10000;

  /// Мінімальна винагорода монет.
  static const int minCoinsReward = 5;

  /// Максимальна кількість символів у назві челенджу.
  static const int maxNameLength = 100;

  /// Максимальна кількість символів у описі челенджу.
  static const int maxDescriptionLength = 500;

  /// Валідує тривалість челенджу.
  static String? validateDuration(int? days) {
    if (days == null || days <= 0) return 'Вкажіть тривалість челенджу';
    if (days < minDurationDays) {
      return 'Мінімальна тривалість — $minDurationDays день';
    }
    if (days > maxDurationDays) {
      return 'Максимальна тривалість — $maxDurationDays днів';
    }
    return null;
  }

  /// Валідує винагороду XP.
  static String? validateXpReward(int? xp) {
    if (xp == null || xp <= 0) return 'Вкажіть винагороду XP';
    if (xp < minXpReward) {
      return 'Мінімальна винагорода — $minXpReward XP';
    }
    if (xp > maxXpReward) {
      return 'Максимальна винагорода — $maxXpReward XP';
    }
    return null;
  }

  /// Валідує винагороду монет.
  static String? validateCoinsReward(int? coins) {
    if (coins == null || coins <= 0) return 'Вкажіть винагороду монет';
    if (coins < minCoinsReward) {
      return 'Мінімальна винагорода — $minCoinsReward монет';
    }
    return null;
  }

  /// Валідує назву челенджу.
  static String? validateName(String? name) {
    if (name == null || name.trim().isEmpty) return 'Вкажіть назву';
    if (name.length > maxNameLength) {
      return 'Назва занадто довга (${name.length}/$maxNameLength)';
    }
    return null;
  }

  /// Валідує пошуковий запит.
  static String? validateSearchQuery(String query) {
    if (query.length > 50) return 'Пошуковий запит занадто довгий';
    return null;
  }

  /// Обчислює XP за день на основі загальної винагороди та тривалості.
  static int xpPerDay(int totalXp, int totalDays) {
    if (totalDays <= 0) return 0;
    return (totalXp / totalDays).round();
  }

  /// Обчислює монети за день.
  static int coinsPerDay(int totalCoins, int totalDays) {
    if (totalDays <= 0) return 0;
    return (totalCoins / totalDays).round();
  }

  /// Визначає рівень складності на основі тривалості та винагороди.
  ///
  /// Використовується для автоматичної категоризації.
  static ChallengeDifficulty estimateDifficulty({
    required int durationDays,
    required int xpReward,
  }) {
    final dailyXp = xpPerDay(xpReward, durationDays);
    if (durationDays <= 3 && dailyXp <= 20) return ChallengeDifficulty.easy;
    if (durationDays >= 14 || dailyXp >= 50) return ChallengeDifficulty.hard;
    return ChallengeDifficulty.medium;
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Challenge Statistics Calculator
// ═══════════════════════════════════════════════════════════════════════════

/// Калькулятор статистики челенджів.
///
/// Надає розширені методи аналізу історії та прогресу.
class ChallengeStatisticsCalculator {
  /// Константа — не дозволяємо створювати екземпляри.
  ChallengeStatisticsCalculator._();

  /// Обчислює середній успіх за останні N челенджів.
  ///
  /// Повертає відсоток успішних (0-100).
  static double recentSuccessRate(List<ChallengeHistoryEntry> history, {int limit = 10}) {
    final recent = history.length <= limit
        ? history
        : history.sublist(0, limit);
    if (recent.isEmpty) return 0;
    final completed = recent.where((h) => h.wasCompleted).length;
    return (completed / recent.length) * 100;
  }

  /// Обчислює тренд успішності (покращується / погіршується).
  ///
  /// Порівнює першу половину історії з другою.
  static String successTrend(List<ChallengeHistoryEntry> history) {
    if (history.length < 4) return 'недостатньо даних';

    final mid = history.length ~/ 2;
    final firstHalf = history.sublist(mid);
    final secondHalf = history.sublist(0, mid);

    final firstRate = firstHalf.where((h) => h.wasCompleted).length /
        firstHalf.length;
    final secondRate = secondHalf.where((h) => h.wasCompleted).length /
        secondHalf.length;

    if (secondRate > firstRate * 1.1) return ' Покращується ↗';
    if (secondRate < firstRate * 0.9) return ' Погіршується ↘';
    return ' Стабільний →';
  }

  /// Групує історію за складністю.
  ///
  /// Повертає карту {складність: кількість завершених}.
  static Map<ChallengeDifficulty, int> completedByDifficulty(
      List<ChallengeHistoryEntry> history) {
    final map = <ChallengeDifficulty, int>{};
    for (final entry in history) {
      if (entry.wasCompleted) {
        map[entry.difficulty] = (map[entry.difficulty] ?? 0) + 1;
      }
    }
    return map;
  }

  /// Обчислює середній час виконання челенджу за складністю.
  ///
  /// Повертає карту {складність: середня кількість днів}.
  static Map<ChallengeDifficulty, double> averageDurationByDifficulty(
      List<ChallengeHistoryEntry> history) {
    final totals = <ChallengeDifficulty, int>{};
    final counts = <ChallengeDifficulty, int>{};

    for (final entry in history) {
      if (entry.wasCompleted) {
        totals[entry.difficulty] = (totals[entry.difficulty] ?? 0) + entry.daysCompleted;
        counts[entry.difficulty] = (counts[entry.difficulty] ?? 0) + 1;
      }
    }

    return totals.map((difficulty, total) {
      final count = counts[difficulty] ?? 1;
      return MapEntry(difficulty, total / count);
    });
  }

  /// Визначає найуспішнішу складність для користувача.
  ///
  /// Повертає складність з найвищим відсотком успіху.
  static ChallengeDifficulty mostSuccessfulDifficulty(
      List<ChallengeHistoryEntry> history) {
    final byDifficulty = <ChallengeDifficulty, List<bool>>{};
    for (final entry in history) {
      byDifficulty.putIfAbsent(entry.difficulty, () => []).add(entry.wasCompleted);
    }

    ChallengeDifficulty best = ChallengeDifficulty.easy;
    double bestRate = -1;

    byDifficulty.forEach((difficulty, results) {
      if (results.isEmpty) return;
      final rate = results.where((r) => r).length / results.length;
      if (rate > bestRate) {
        bestRate = rate;
        best = difficulty;
      }
    });

    return best;
  }

  /// Форматує детальну статистику для відображення.
  static String formatDetailedStats(ChallengeState state) {
    final buffer = StringBuffer();
    buffer.writeln('Всього челенджів: ${state.completedCount + state.failedCount}');
    buffer.writeln('Завершено: ${state.completedCount}');
    buffer.writeln('Провалено: ${state.failedCount}');
    buffer.writeln('Успіх: ${state.successRate.toStringAsFixed(1)}%');
    buffer.writeln('XP зароблено: ${state.totalXpEarned}');
    buffer.writeln('Монет зароблено: ${state.totalCoinsEarned}');
    if (state.activeChallenge != null) {
      buffer.writeln('Активний: ${state.activeChallengeProgressText}');
    }
    return buffer.toString().trimRight();
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Challenge Formatting Utilities
// ═══════════════════════════════════════════════════════════════════════════

/// Утиліти для форматування даних челенджів.
class ChallengeFormatter {
  /// Константа — не дозволяємо створювати екземпляри.
  ChallengeFormatter._();

  /// Форматує тривалість челенджу українською.
  ///
  /// Наприклад: «7 днів», «1 день», «14 днів».
  static String formatDuration(int days) {
    if (days == 1) return '$days день';
    if (days >= 2 && days <= 4) return '$days дні';
    return '$days днів';
  }

  /// Форматує винагороду XP для відображення.
  ///
  /// Наприклад: «XP +150».
  static String formatXpReward(int xp) {
    return 'XP +$xp';
  }

  /// Форматує винагороду монет для відображення.
  ///
  /// Наприклад: «Монети +50».
  static String formatCoinsReward(int coins) {
    return 'Монети +$coins';
  }

  /// Форматує винагороду у гривнях.
  ///
  /// Наприклад: «50 ₴».
  static String formatRewardAmount(double amount) {
    return '${amount.toInt()} ₴';
  }

  /// Форматує повну винагороду челенджу.
  ///
  /// Наприклад: «XP +150 | Монети +50 | 50 ₴».
  static String formatFullReward({
    required int xp,
    required int coins,
    required double amount,
  }) {
    return '${formatXpReward(xp)} | ${formatCoinsReward(coins)} | ${formatRewardAmount(amount)}';
  }

  /// Форматує залишок днів.
  ///
  /// Наприклад: «Залишилось 3 дні».
  static String formatRemainingDays(int days) {
    if (days <= 0) return 'Останній день!';
    if (days == 1) return 'Залишився $days день';
    if (days <= 4) return 'Залишилось $days дні';
    return 'Залишилось $days днів';
  }

  /// Форматує опис челенджу для картки.
  static String formatChallengeCard({
    required String name,
    required int currentDay,
    required int totalDays,
    required ChallengeDifficulty difficulty,
  }) {
    final diffLabel = _difficultyLabel(difficulty);
    return '$name ($diffLabel) — $currentDay/$totalDays';
  }

  /// Повертає мітку складності українською.
  static String _difficultyLabel(ChallengeDifficulty difficulty) {
    switch (difficulty) {
      case ChallengeDifficulty.easy:
        return 'Легкий';
      case ChallengeDifficulty.medium:
        return 'Середній';
      case ChallengeDifficulty.hard:
        return 'Складний';
    }
  }

  /// Форматує повідомлення про прийняття челенджу.
  static String formatAcceptMessage(String name, int days) {
    return 'Челендж «$name» розпочато! $formatDuration(days) — вперед!';
  }

  /// Форматує повідомлення про завершення челенджу.
  static String formatCompleteMessage(String name, int xp, int coins) {
    return '🎉 «$name» завершено! ${formatXpReward(xp)}, ${formatCoinsReward(coins)}';
  }

  /// Форматує повідомлення про провал челенджу.
  static String formatFailMessage(String name, int completedDays) {
    return '«$name» не завершено. Виконано: $completedDays днів.';
  }

  /// Форматує повідомлення нагадування.
  static String formatReminder(String name, int remainingDays) {
    return '🔔 Не забудь виконати челендж «$name»! ${formatRemainingDays(remainingDays)}';
  }

  /// Форматує підсумок активного челенджу.
  static String formatActiveSummary(Challenge challenge) {
    final progress = (challenge.currentDay / challenge.durationDays * 100)
        .toStringAsFixed(0);
    return '${challenge.name}: $progress% (${challenge.currentDay}/${challenge.durationDays})';
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Challenge Difficulty Helpers
// ═══════════════════════════════════════════════════════════════════════════

/// Допоміжні методи для роботи зі складністю челенджів.
class ChallengeDifficultyHelper {
  /// Константа — не дозволяємо створювати екземпляри.
  ChallengeDifficultyHelper._();

  /// Порядок складностей від легкої до важкої.
  static const List<ChallengeDifficulty> order = [
    ChallengeDifficulty.easy,
    ChallengeDifficulty.medium,
    ChallengeDifficulty.hard,
  ];

  /// Множники XP за складність.
  static const Map<ChallengeDifficulty, double> xpMultipliers = {
    ChallengeDifficulty.easy: 1.0,
    ChallengeDifficulty.medium: 1.5,
    ChallengeDifficulty.hard: 2.0,
  };

  /// Множники монет за складність.
  static const Map<ChallengeDifficulty, double> coinMultipliers = {
    ChallengeDifficulty.easy: 1.0,
    ChallengeDifficulty.medium: 1.5,
    ChallengeDifficulty.hard: 2.0,
  };

  /// Кольори для кожної складності.
  static const Map<ChallengeDifficulty, int> colors = {
    ChallengeDifficulty.easy: 0xFF2ECC71,  // зелений
    ChallengeDifficulty.medium: 0xFFF39C12, // помаранчевий
    ChallengeDifficulty.hard: 0xFFE74C3C,  // червоний
  };

  /// Повертає множник XP для складності.
  static double xpMultiplier(ChallengeDifficulty d) =>
      xpMultipliers[d] ?? 1.0;

  /// Повертає множник монет для складності.
  static double coinMultiplier(ChallengeDifficulty d) =>
      coinMultipliers[d] ?? 1.0;

  /// Повертає колір складності як Color.
  static Color color(ChallengeDifficulty d) =>
      Color(colors[d] ?? 0xFF95A5A6);

  /// Повертає наступну складність (циклічно).
  static ChallengeDifficulty nextDifficulty(ChallengeDifficulty d) {
    final index = order.indexOf(d);
    return order[(index + 1) % order.length];
  }

  /// Повертає попередню складність (циклічно).
  static ChallengeDifficulty previousDifficulty(ChallengeDifficulty d) {
    final index = order.indexOf(d);
    return order[(index - 1 + order.length) % order.length];
  }

  /// Повертає кількість зірок складності (1-3).
  static int starCount(ChallengeDifficulty d) => order.indexOf(d) + 1;

  /// Повертає рядок зі зірками складності (наприклад, «⭐⭐⭐»).
  static String starString(ChallengeDifficulty d) {
    return '⭐' * starCount(d);
  }
}
