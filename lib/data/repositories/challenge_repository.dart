import 'dart:math';

import 'package:nexora/core/constants/app_enums.dart';
import 'package:nexora/data/models/challenge_model.dart';

/// Репозиторій челенджів (in-memory, попередньо заповнений шаблонами).
///
/// Забезпечує повне керування життєвим циклом челенджів,
/// фільтрацію за складністю, перевірку термінів дії,
/// статистику нагород та роботу з шаблонами.
///
/// Всі рядки-повідомлення українською.
class ChallengeRepository {
  final List<Challenge> _challenges = [];
  final _random = Random();

  ChallengeRepository() {
    _prepopulateChallenges();
  }

  // ─── Базові методи ─────────────────────────────────────────────────

  /// Повертає всі челенджі (незмінний список).
  List<Challenge> getAll() {
    return List.unmodifiable(_challenges);
  }

  /// Повертає активний челендж (перший з активних).
  Challenge? getActive() {
    for (final c in _challenges) {
      if (c.status == ChallengeStatus.active) return c;
    }
    return null;
  }

  /// Повертає всі активні челенджі.
  List<Challenge> getActiveChallenges() {
    return _challenges
        .where((c) => c.status == ChallengeStatus.active)
        .toList();
  }

  /// Повертає доступні для старту челенджі.
  List<Challenge> getAvailable() {
    return _challenges
        .where((c) => c.status == ChallengeStatus.available)
        .toList();
  }

  /// Повертає завершені челенджі (найновіші перші).
  List<Challenge> getCompleted() {
    return _challenges
        .where((c) => c.status == ChallengeStatus.completed)
        .toList()
      ..sort((a, b) {
        final aDate = a.completedAt ?? DateTime.now();
        final bDate = b.completedAt ?? DateTime.now();
        return bDate.compareTo(aDate);
      });
  }

  /// Повертає провалені челенджі.
  List<Challenge> getFailed() {
    return _challenges
        .where((c) => c.status == ChallengeStatus.failed)
        .toList();
  }

  /// Зберігає (оновлює або створює) челендж.
  void save(Challenge challenge) {
    final index = _challenges.indexWhere((c) => c.id == challenge.id);
    if (index >= 0) {
      _challenges[index] = challenge;
    } else {
      _challenges.add(challenge);
    }
  }

  /// Знаходить челендж за ID.
  Challenge? getById(String id) {
    for (final c in _challenges) {
      if (c.id == id) return c;
    }
    return null;
  }

  /// Видаляє челендж за ID. Повертає true якщо видалено.
  bool delete(String id) {
    final initialLength = _challenges.length;
    _challenges.removeWhere((c) => c.id == id);
    return _challenges.length < initialLength;
  }

  /// Кількість челенджів.
  int get count => _challenges.length;

  /// Кількість завершених челенджів.
  int get completedCount =>
      _challenges.where((c) => c.status == ChallengeStatus.completed).length;

  /// Кількість активних челенджів.
  int get activeCount =>
      _challenges.where((c) => c.status == ChallengeStatus.active).length;

  /// Кількість провалених челенджів.
  int get failedCount =>
      _challenges.where((c) => c.status == ChallengeStatus.failed).length;

  /// Кількість доступних челенджів.
  int get availableCount =>
      _challenges.where((c) => c.status == ChallengeStatus.available).length;

  /// Чи є активний челендж зараз.
  bool get hasActiveChallenge => activeCount > 0;

  /// Чи є доступні для старту челенджі.
  bool get hasAvailableChallenges => availableCount > 0;

  /// Очищає всі челенджі.
  void clearAll() {
    _challenges.clear();
  }

  /// Скидає челенджі до початкового стану (тільки доступні).
  void resetToDefaults() {
    clearAll();
    _prepopulateChallenges();
  }

  // ─── Фільтрація за складністю ───────────────────────────────────────

  /// Повертає челенджі вказаної складності.
  List<Challenge> getByDifficulty(ChallengeDifficulty difficulty) {
    return _challenges
        .where((c) => c.difficulty == difficulty)
        .toList();
  }

  /// Повертає легкі челенджі.
  List<Challenge> getEasy() => getByDifficulty(ChallengeDifficulty.easy);

  /// Повертає середні челенджі.
  List<Challenge> getMedium() => getByDifficulty(ChallengeDifficulty.medium);

  /// Повертає складні челенджі.
  List<Challenge> getHard() => getByDifficulty(ChallengeDifficulty.hard);

  /// Повертає челенджі за тривалістю (не більше вказаних днів).
  List<Challenge> getByMaxDuration(int maxDays) {
    return _challenges
        .where((c) => c.durationDays <= maxDays)
        .toList();
  }

  /// Повертає челенджі за мінімальною винагородою XP.
  List<Challenge> getByMinXpReward(int minXp) {
    return _challenges
        .where((c) => c.xpReward >= minXp)
        .toList();
  }

  /// Пошук челенджів за назвою (без регістру).
  List<Challenge> searchChallenges(String query) {
    if (query.isEmpty) return getAll();
    final lower = query.toLowerCase();
    return _challenges
        .where((c) => c.title.toLowerCase().contains(lower))
        .toList();
  }

  // ─── Дії з життєвим циклом ─────────────────────────────────────────

  /// Приймає челендж (починає його).
  /// Повертає true якщо вдалося почати.
  bool acceptChallenge(String challengeId) {
    final challenge = getById(challengeId);
    if (challenge == null) return false;
    // Не можна мати більше одного активного челенджу одночасно
    if (getActive() != null) return false;
    final started = challenge.startChallenge();
    if (started) {
      save(challenge);
    }
    return started;
  }

  /// Завершує челендж (виконання всіх днів). Повертає нагороду.
  Map<String, int>? completeChallenge(String challengeId) {
    final challenge = getById(challengeId);
    if (challenge == null) return null;
    if (challenge.status != ChallengeStatus.active) return null;
    challenge.status = ChallengeStatus.completed;
    challenge.completedAt = DateTime.now();
    challenge.dailyProgressList = List.filled(challenge.durationDays, true);
    challenge.currentDay = challenge.durationDays;
    save(challenge);
    return challenge.calculateReward();
  }

  /// Провалює челендж. Повертає часткову нагороду.
  Map<String, int>? failChallenge(String challengeId) {
    final challenge = getById(challengeId);
    if (challenge == null) return null;
    final failed = challenge.failChallenge();
    if (failed) {
      save(challenge);
      return challenge.calculatePartialReward();
    }
    return null;
  }

  /// Виконує поточний день челенджу. Повертає true якщо день завершено.
  bool completeDay(String challengeId) {
    final challenge = getById(challengeId);
    if (challenge == null) return false;
    final completed = challenge.completeDay();
    if (completed) {
      save(challenge);
    }
    return completed;
  }

  /// Скасовує активний челендж (повертає в статус «доступний»).
  bool cancelChallenge(String challengeId) {
    final challenge = getById(challengeId);
    if (challenge == null) return false;
    if (challenge.status != ChallengeStatus.active) return false;
    final updated = challenge.copyWith(
      status: ChallengeStatus.available,
      clearStartedAt: true,
      clearCompletedAt: true,
      currentDay: 0,
      dailyProgressList: [],
    );
    save(updated);
    return true;
  }

  /// Пропускає поточний день (без нагороди за цей день).
  bool skipDay(String challengeId) {
    final challenge = getById(challengeId);
    if (challenge == null) return false;
    if (challenge.status != ChallengeStatus.active) return false;
    if (challenge.currentDay >= challenge.durationDays) return false;
    challenge.currentDay++;
    if (challenge.currentDay >= challenge.durationDays) {
      // Автоматичне провалення при пропуску останнього дня
      challenge.failChallenge();
    }
    save(challenge);
    return true;
  }

  // ─── Перевірка термінів ────────────────────────────────────────────

  /// Перевіряє всі активні челенджі та провалює прострочені.
  /// Повертає список провалених челенджів.
  List<Challenge> checkExpiredChallenges() {
    final expired = <Challenge>[];
    for (final challenge in _challenges) {
      if (challenge.isActive && challenge.isExpired) {
        challenge.failChallenge();
        save(challenge);
        expired.add(challenge);
      }
    }
    return expired;
  }

  /// Скидає щоденний прогрес для всіх активних челенджів.
  /// Викликати опівночі для перевірки прострочених.
  void resetDailyProgress() {
    for (final challenge in _challenges) {
      if (challenge.isActive && challenge.isExpired) {
        challenge.failChallenge();
        save(challenge);
      }
    }
  }

  // ─── Прогрес ───────────────────────────────────────────────────────

  /// Повертає прогрес челенджу у відсотках (0.0–1.0).
  double getProgress(String challengeId) {
    final challenge = getById(challengeId);
    if (challenge == null) return 0;
    return challenge.progressPercent;
  }

  /// Отримує загальний прогрес по всіх активних челенджах.
  double get overallActiveProgress {
    final active = getActiveChallenges();
    if (active.isEmpty) return 0;
    return active.fold(0.0, (sum, c) => sum + c.progressPercent) /
        active.length;
  }

  /// Отримує загальний прогрес завершених челенджів у відсотках.
  double get overallCompletionRate {
    if (_challenges.isEmpty) return 0;
    final nonAvailable = _challenges
        .where((c) => c.status != ChallengeStatus.available);
    if (nonAvailable.isEmpty) return 0;
    return completedCount / nonAvailable.length;
  }

  // ─── Шаблони ───────────────────────────────────────────────────────

  /// Повертає всі попередньо завантажені шаблони.
  static List<ChallengeTemplate> getTemplates() {
    return ChallengeTemplate.preloaded;
  }

  /// Повертає шаблони за складністю.
  static List<ChallengeTemplate> getTemplatesByDifficulty(
    ChallengeDifficulty difficulty,
  ) {
    return ChallengeTemplate.getByDifficulty(difficulty);
  }

  /// Повертає шаблони для вказаного рівня користувача.
  static List<ChallengeTemplate> getTemplatesForLevel(int userLevel) {
    return ChallengeTemplate.getAvailableForLevel(userLevel);
  }

  /// Повертає шаблони за категорією.
  static List<ChallengeTemplate> getTemplatesByCategory(String category) {
    return ChallengeTemplate.getByCategory(category);
  }

  /// Створює челендж з шаблону та зберігає.
  Challenge createFromTemplate(String templateId) {
    final templates = ChallengeTemplate.preloaded;
    final template = templates.firstWhere(
      (t) => t.id == templateId,
      orElse: () => templates.first,
    );
    final challenge = template.createChallenge();
    save(challenge);
    return challenge;
  }

  /// Створює випадковий челендж з доступних шаблонів.
  Challenge createRandomChallenge() {
    final available = getAvailable();
    if (available.isEmpty) {
      // Якщо немає доступних — створюємо з шаблону
      return createFromTemplate(
        ChallengeTemplate.preloaded[_random.nextInt(
          ChallengeTemplate.preloaded.length,
        )].id,
      );
    }
    final randomChallenge = available[_random.nextInt(available.length)];
    return randomChallenge;
  }

  /// Перевіряє, чи доступний шаблон (не прийнято ще).
  bool isTemplateAvailable(String templateId) {
    final challenge = getById(templateId);
    return challenge == null || challenge.status == ChallengeStatus.available;
  }

  /// Перезавантажує шаблони, яких ще немає в репозиторії.
  void reloadMissingTemplates() {
    for (final template in ChallengeTemplate.preloaded) {
      if (!exists(template.id)) {
        save(template.createChallenge());
      }
    }
  }

  /// Чи існує челендж з таким ID.
  bool exists(String id) {
    return _challenges.any((c) => c.id == id);
  }

  // ─── Рекомендації ──────────────────────────────────────────────────

  /// Повертає рекомендований челендж на основі рівня користувача.
  /// Спочатку намагається дати легкий, потім середній, потім складний.
  Challenge? getRecommendedChallenge(int userLevel) {
    // Спочатку шукаємо серед доступних
    final available = getAvailable();
    if (available.isEmpty) return null;

    // Пріоритет: легкий → середній → складний
    final easy = available
        .where((c) => c.difficulty == ChallengeDifficulty.easy)
        .toList();
    if (easy.isNotEmpty && userLevel < 3) {
      return easy[_random.nextInt(easy.length)];
    }

    final medium = available
        .where((c) => c.difficulty == ChallengeDifficulty.medium)
        .toList();
    if (medium.isNotEmpty && userLevel >= 2) {
      return medium[_random.nextInt(medium.length)];
    }

    final hard = available
        .where((c) => c.difficulty == ChallengeDifficulty.hard)
        .toList();
    if (hard.isNotEmpty && userLevel >= 4) {
      return hard[_random.nextInt(hard.length)];
    }

    // Повертаємо будь-який доступний
    return available[_random.nextInt(available.length)];
  }

  /// Повертає текстову підказку для користувача щодо челенджів.
  String getChallengeTip() {
    if (hasActiveChallenge) {
      final active = getActive()!;
      return '🔥 Ти вже виконуєш «${active.title}». Продовжуй — залишилось ${active.daysRemaining} дн.';
    }
    if (hasAvailableChallenges) {
      return '🎯 У тебе ${availableCount} доступних викликів. Обери один і почни накопичувати!';
    }
    return '✅ Ти виконав усі доступні виклики! Скоро з\'являться нові.';
  }

  // ─── Статистика нагород ────────────────────────────────────────────

  /// Загальний XP зароблений через завершені челенджі.
  int get totalXpReward {
    return _challenges
        .where((c) => c.status == ChallengeStatus.completed)
        .fold(0, (sum, c) => sum + c.xpReward);
  }

  /// Загальні монети зароблені через завершені челенджі.
  int get totalCoinsReward {
    return _challenges
        .where((c) => c.status == ChallengeStatus.completed)
        .fold(0, (sum, c) => sum + c.coinsReward);
  }

  /// Загальна сума винагород за завершені челенджі.
  double get totalAmountReward {
    return _challenges
        .where((c) => c.status == ChallengeStatus.completed)
        .fold(0.0, (sum, c) => sum + c.rewardAmount);
  }

  /// Часткова нагорода за всі провалені челенджі.
  Map<String, int> get totalPartialRewards {
    final failed = getFailed();
    return {
      'amount': failed.fold(0, (sum, c) => sum + c.calculatePartialReward()['amount']!),
      'xp': failed.fold(0, (sum, c) => sum + c.calculatePartialReward()['xp']!),
      'coins': failed.fold(0, (sum, c) => sum + c.calculatePartialReward()['coins']!),
    };
  }

  /// Загальна кількість виконаних днів по всіх челенджах.
  int get totalCompletedDays {
    return _challenges
        .fold(0, (sum, c) => sum + c.completedDays);
  }

  /// Загальна кількість запропонованих днів по всіх челенджах.
  int get totalProposedDays {
    return _challenges
        .where((c) => c.status != ChallengeStatus.available)
        .fold(0, (sum, c) => sum + c.durationDays);
  }

  /// Повертає зведення по челенджах.
  Map<String, dynamic> getFullStats() {
    return {
      'загальноЧеленджів': count,
      'доступних': availableCount,
      'активних': activeCount,
      'завершених': completedCount,
      'провалених': failedCount,
      'загальнийXp': totalXpReward,
      'загальнеМонет': totalCoinsReward,
      'загальнаСумаНагород': totalAmountReward,
      'виконанихДнів': totalCompletedDays,
      'запропонованихДнів': totalProposedDays,
      'відсотокУспіху': overallCompletionRate.toStringAsFixed(1),
    };
  }

  // ─── Приватні методи ───────────────────────────────────────────────

  /// Попереднє заповнення челенджів з шаблонів.
  void _prepopulateChallenges() {
    _challenges.addAll([
      // ─── Легкі ─────────────────────────────────────────────────
      Challenge(
        id: 'challenge_no_spend_today',
        title: 'Не витрачай нічого сьогодні',
        description:
            'Протягом одного дня не роби жодних покупок, окрім найнеобхіднішого. Збережи кожну гривню!',
        rewardAmount: 150,
        xpReward: 50,
        coinsReward: 25,
        durationDays: 1,
        status: ChallengeStatus.available,
        difficulty: ChallengeDifficulty.easy,
      ),

      Challenge(
        id: 'challenge_5_deposits',
        title: '5 внесків за тиждень',
        description:
            'Зроби 5 внесків протягом одного тижня. Може бути будь-яка сума — головне регулярність!',
        rewardAmount: 200,
        xpReward: 80,
        coinsReward: 40,
        durationDays: 7,
        status: ChallengeStatus.available,
        difficulty: ChallengeDifficulty.easy,
      ),

      Challenge(
        id: 'challenge_morning_deposit',
        title: 'Ранковий внесок 3 дні',
        description:
            'Роби внесок до 10:00 ранку протягом 3 днів поспіль. Ранкові заощадження — найкращі!',
        rewardAmount: 180,
        xpReward: 60,
        coinsReward: 30,
        durationDays: 3,
        status: ChallengeStatus.available,
        difficulty: ChallengeDifficulty.easy,
      ),

      // ─── Середні ───────────────────────────────────────────────
      Challenge(
        id: 'challenge_no_coffee',
        title: '7 днів без кави назовні',
        description:
            'Цілий тиждень пий каву вдома замість того, щоб купувати в кафе. Різницю відклади в скарбничку!',
        rewardAmount: 500,
        xpReward: 150,
        coinsReward: 75,
        durationDays: 7,
        status: ChallengeStatus.available,
        difficulty: ChallengeDifficulty.medium,
      ),

      Challenge(
        id: 'challenge_daily_7',
        title: 'Щоденний внесок 7 днів поспіль',
        description:
            'Роби щонайменше один внесок щодня протягом 7 днів поспіль. Навіть 10 ₴ рахуються!',
        rewardAmount: 300,
        xpReward: 120,
        coinsReward: 50,
        durationDays: 7,
        status: ChallengeStatus.available,
        difficulty: ChallengeDifficulty.medium,
      ),

      Challenge(
        id: 'challenge_no_delivery',
        title: '10 днів без доставки їжі',
        description:
            'Готуй самостійно 10 днів поспіль. Гроші, що зекономиш на доставці, відклади!',
        rewardAmount: 700,
        xpReward: 200,
        coinsReward: 80,
        durationDays: 10,
        status: ChallengeStatus.available,
        difficulty: ChallengeDifficulty.medium,
      ),

      // ─── Складні ───────────────────────────────────────────────
      Challenge(
        id: 'challenge_1000_week',
        title: 'Збери 1000 грн за тиждень',
        description:
            'Відклади 1000 гривень за 7 днів. Подвійний XP за кожен внесок у цей період!',
        rewardAmount: 0,
        xpReward: 300,
        coinsReward: 100,
        durationDays: 7,
        status: ChallengeStatus.available,
        difficulty: ChallengeDifficulty.hard,
      ),

      Challenge(
        id: 'challenge_double_amount',
        title: 'Відклади подвійну суму',
        description:
            'Протягом 3 днів відкладай подвійну суму від звичайного внеска. Це серйозне випробування сили волі!',
        rewardAmount: 400,
        xpReward: 200,
        coinsReward: 90,
        durationDays: 3,
        status: ChallengeStatus.available,
        difficulty: ChallengeDifficulty.hard,
      ),

      Challenge(
        id: 'challenge_no_shopping_14',
        title: '14 днів без імпульсивних покупок',
        description:
            'Протягом двох тижнів купуй лише заздалегідь заплановані речі. Жодних спонтанних витрат!',
        rewardAmount: 1000,
        xpReward: 400,
        coinsReward: 150,
        durationDays: 14,
        status: ChallengeStatus.available,
        difficulty: ChallengeDifficulty.hard,
      ),

      Challenge(
        id: 'challenge_5000_month',
        title: 'Збери 5 000 грн за місяць',
        description:
            'Великий виклик для справжніх накопичувачів! Відклади 5 000 гривень протягом 30 днів.',
        rewardAmount: 0,
        xpReward: 500,
        coinsReward: 200,
        durationDays: 30,
        status: ChallengeStatus.available,
        difficulty: ChallengeDifficulty.hard,
      ),
    ]);
  }
}
