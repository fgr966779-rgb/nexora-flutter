/// Core enums for the Nexora gamified savings app.
///
/// All domain-level enumeration types used across the application.
/// Every enum includes Ukrainian display labels and, where appropriate,
/// icon keys and colour hints for UI rendering.
library;

// ─── Goal Types ────────────────────────────────────────────────────────────

/// Represents the visual theme / goal motivation type.
///
/// Each value maps to a distinct [ThemeData] palette:
/// - [ps5] — dark neon (PlayStation 5 inspired)
/// - [monitor] — light minimal (monitor / tech inspired)
/// - [custom] — user-defined (future support)
enum GoalType {
  ps5,
  monitor,
  custom;

  /// Human-readable Ukrainian label.
  String get label {
    switch (this) {
      case GoalType.ps5:
        return 'PlayStation 5';
      case GoalType.monitor:
        return 'Монітор';
      case GoalType.custom:
        return 'Власна ціль';
    }
  }

  /// Short key used in persistence & routing.
  String get key => name;

  /// Emoji icon representing the goal type.
  String get icon {
    switch (this) {
      case GoalType.ps5:
        return '🎮';
      case GoalType.monitor:
        return '🖥️';
      case GoalType.custom:
        return '🎯';
    }
  }

  /// Brief description shown in onboarding / cards.
  String get description {
    switch (this) {
      case GoalType.ps5:
        return 'Збирай на PlayStation 5 — темна неонова тема';
      case GoalType.monitor:
        return 'Збирай на монітор — світла мінимальна тема';
      case GoalType.custom:
        return 'Створи власну ціль заощаджень';
    }
  }
}

// ─── Goal Status ───────────────────────────────────────────────────────────

/// Lifecycle state of a savings goal.
enum GoalStatus {
  /// The goal is actively accumulating funds.
  active,

  /// The target amount has been reached.
  completed,

  /// The user explicitly cancelled / abandoned the goal.
  abandoned;

  String get label {
    switch (this) {
      case GoalStatus.active:
        return 'Активна';
      case GoalStatus.completed:
        return 'Досягнуто';
      case GoalStatus.abandoned:
        return 'Скасовано';
    }
  }

  /// Semantic colour token name for status badges.
  String get colorKey {
    switch (this) {
      case GoalStatus.active:
        return 'primary';
      case GoalStatus.completed:
        return 'success';
      case GoalStatus.abandoned:
        return 'muted';
    }
  }
}

// ─── Transaction Types ─────────────────────────────────────────────────────

/// How a deposit was created.
enum TransactionType {
  /// User entered the amount manually.
  manual,

  /// Spare change rounded up from a bank transaction.
  roundUp,

  /// Scheduled automatic payment.
  autoPayment,

  /// Funds earned through a gamified challenge.
  challenge,

  /// Daily login reward.
  dailyLogin,

  /// Completion of a micro-goal (sub-goal).
  microGoal,

  /// Bonus for returning after a frozen period.
  returnBonus;

  String get label {
    switch (this) {
      case TransactionType.manual:
        return 'Вручну';
      case TransactionType.roundUp:
        return 'Округлення';
      case TransactionType.autoPayment:
        return 'Авто-платіж';
      case TransactionType.challenge:
        return 'Виклик';
      case TransactionType.dailyLogin:
        return 'Щоденний вхід';
      case TransactionType.microGoal:
        return 'Мікро-ціль';
      case TransactionType.returnBonus:
        return 'Бонус повернення';
    }
  }

  /// Emoji icon for the transaction type.
  String get icon {
    switch (this) {
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
}

// ─── Transaction Category ──────────────────────────────────────────────────

/// Категорія транзакції для фільтрації та аналітики.
enum TransactionCategory {
  /// Повсякденні покупки.
  shopping,
  /// Харчування та продукти.
  food,
  /// Транспорт.
  transport,
  /// Розваги.
  entertainment,
  /// Оплата комунальних послуг.
  utilities,
  /// Переказ між цілями.
  transfer,
  /// Винагорода від виклику.
  reward,
  /// Інше.
  other;

  /// Українська назва категорії.
  String get label {
    switch (this) {
      case TransactionCategory.shopping:
        return 'Покупки';
      case TransactionCategory.food:
        return 'Харчування';
      case TransactionCategory.transport:
        return 'Транспорт';
      case TransactionCategory.entertainment:
        return 'Розваги';
      case TransactionCategory.utilities:
        return 'Комунальні';
      case TransactionCategory.transfer:
        return 'Переказ';
      case TransactionCategory.reward:
        return 'Винагорода';
      case TransactionCategory.other:
        return 'Інше';
    }
  }

  /// Іконка категорії.
  String get icon {
    switch (this) {
      case TransactionCategory.shopping:
        return '🛒';
      case TransactionCategory.food:
        return '🍕';
      case TransactionCategory.transport:
        return '🚌';
      case TransactionCategory.entertainment:
        return '🎬';
      case TransactionCategory.utilities:
        return '💡';
      case TransactionCategory.transfer:
        return '↔️';
      case TransactionCategory.reward:
        return '⭐';
      case TransactionCategory.other:
        return '📌';
    }
  }
}

// ─── Challenge Status ──────────────────────────────────────────────────────

/// Lifecycle of a savings challenge.
enum ChallengeStatus {
  /// Available for the user to accept.
  available,

  /// Currently in progress.
  active,

  /// Successfully finished.
  completed,

  /// Expired or user failed to complete.
  failed;

  String get label {
    switch (this) {
      case ChallengeStatus.available:
        return 'Доступний';
      case ChallengeStatus.active:
        return 'В процесі';
      case ChallengeStatus.completed:
        return 'Завершено';
      case ChallengeStatus.failed:
        return 'Не виконано';
    }
  }

  /// Semantic colour token name.
  String get colorKey {
    switch (this) {
      case ChallengeStatus.available:
        return 'accent';
      case ChallengeStatus.active:
        return 'primary';
      case ChallengeStatus.completed:
        return 'success';
      case ChallengeStatus.failed:
        return 'error';
    }
  }
}

// ─── Challenge Difficulty ──────────────────────────────────────────────────

/// Difficulty level of a savings challenge.
enum ChallengeDifficulty {
  /// Easy — short duration, low reward.
  easy,

  /// Medium — moderate commitment.
  medium,

  /// Hard — long duration, high reward.
  hard;

  String get label {
    switch (this) {
      case ChallengeDifficulty.easy:
        return 'Легко';
      case ChallengeDifficulty.medium:
        return 'Середньо';
      case ChallengeDifficulty.hard:
        return 'Складно';
    }
  }

  /// Difficulty description for challenge cards.
  String get description {
    switch (this) {
      case ChallengeDifficulty.easy:
        return 'Швидкий виклик з невеликою винагородою';
      case ChallengeDifficulty.medium:
        return 'Помірна віддача — потрібно трохи зусиль';
      case ChallengeDifficulty.hard:
        return 'Серйозне зобов\'язання з великою винагородою';
    }
  }

  /// Multiplier applied to challenge rewards.
  double get rewardMultiplier {
    switch (this) {
      case ChallengeDifficulty.easy:
        return 1.0;
      case ChallengeDifficulty.medium:
        return 1.5;
      case ChallengeDifficulty.hard:
        return 2.5;
    }
  }

  /// Colour hint for difficulty badge.
  String get colorKey {
    switch (this) {
      case ChallengeDifficulty.easy:
        return 'success';
      case ChallengeDifficulty.medium:
        return 'warning';
      case ChallengeDifficulty.hard:
        return 'error';
    }
  }
}

// ─── Progress Mood ─────────────────────────────────────────────────────────

/// Emotional tone of progress visuals — drives animation style & colours.
enum ProgressMood {
  /// Slow, zen-like accumulation (early stages).
  calm,

  /// Building momentum.
  growing,

  /// Picking up pace.
  energetic,

  /// Near the 80 % mark, excitement builds.
  accelerating,

  /// Final stretch — high energy.
  finale;

  /// Returns a value 0-1 representing mood intensity for animation scaling.
  double get intensity {
    switch (this) {
      case ProgressMood.calm:
        return 0.2;
      case ProgressMood.growing:
        return 0.4;
      case ProgressMood.energetic:
        return 0.6;
      case ProgressMood.accelerating:
        return 0.8;
      case ProgressMood.finale:
        return 1.0;
    }
  }

  /// Ukrainian label for mood indicator.
  String get label {
    switch (this) {
      case ProgressMood.calm:
        return 'Спокійний';
      case ProgressMood.growing:
        return 'Зростаючий';
      case ProgressMood.energetic:
        return 'Енергійний';
      case ProgressMood.accelerating:
        return 'Прискорення';
      case ProgressMood.finale:
        return 'Фінал';
    }
  }

  /// Emoji representation for mood badges.
  String get icon {
    switch (this) {
      case ProgressMood.calm:
        return '😌';
      case ProgressMood.growing:
        return '📈';
      case ProgressMood.energetic:
        return '⚡';
      case ProgressMood.accelerating:
        return '🚀';
      case ProgressMood.finale:
        return '🔥';
    }
  }
}

// ─── Dashboard Mood ────────────────────────────────────────────────────────

/// Overall dashboard state that influences UI behaviour.
enum DashboardMood {
  /// Normal saving pace.
  normal,

  /// Saving faster than planned.
  fastProgress,

  /// No deposits for 3+ days.
  frozen,

  /// User returned after frozen period.
  unfreezing,

  /// Goal is > 90 % complete.
  almostThere,

  /// Goal has been fully funded.
  completed;

  String get label {
    switch (this) {
      case DashboardMood.normal:
        return 'Звичайний';
      case DashboardMood.fastProgress:
        return 'Швидкий прогрес';
      case DashboardMood.frozen:
        return 'Заморожено';
      case DashboardMood.unfreezing:
        return 'Відтанення';
      case DashboardMood.almostThere:
        return 'Майже там';
      case DashboardMood.completed:
        return 'Завершено';
    }
  }

  /// Motivational message shown on the dashboard.
  String get message {
    switch (this) {
      case DashboardMood.normal:
        return 'Продовжуй заощаджувати — ти на правильному шляху!';
      case DashboardMood.fastProgress:
        return 'Впевнений рух вперед — так тримати!';
      case DashboardMood.frozen:
        return 'Здається, час зупинився… Повернись та розтопи лід!';
      case DashboardMood.unfreezing:
        return 'Ти повернувся! Лід починає танути…';
      case DashboardMood.almostThere:
        return 'Фінальний ривок — ти майже на місці!';
      case DashboardMood.completed:
        return 'Вітаємо! Твоя ціль досягнута! 🎉';
    }
  }
}

// ─── Notification Type ─────────────────────────────────────────────────────

/// Category of an in-app notification.
enum NotificationType {
  /// Generic informational message.
  info,

  /// Savings milestone reached.
  milestone,

  /// Challenge started or updated.
  challengeUpdate,

  /// Achievement unlocked.
  achievement,

  /// Reminder to save or unfreeze.
  reminder,

  /// Goal completed.
  goalCompleted,

  /// Streak warning (about to break).
  streakWarning;

  /// Ukrainian display label.
  String get label {
    switch (this) {
      case NotificationType.info:
        return 'Інформація';
      case NotificationType.milestone:
        return 'Етап';
      case NotificationType.challengeUpdate:
        return 'Виклик';
      case NotificationType.achievement:
        return 'Досягнення';
      case NotificationType.reminder:
        return 'Нагадування';
      case NotificationType.goalCompleted:
        return 'Ціль досягнута';
      case NotificationType.streakWarning:
        return 'Серія під загрозою';
    }
  }

  /// Emoji icon for notification list.
  String get icon {
    switch (this) {
      case NotificationType.info:
        return 'ℹ️';
      case NotificationType.milestone:
        return '🎯';
      case NotificationType.challengeUpdate:
        return '🏆';
      case NotificationType.achievement:
        return '🎖️';
      case NotificationType.reminder:
        return '⏰';
      case NotificationType.goalCompleted:
        return '🎉';
      case NotificationType.streakWarning:
        return '⚠️';
    }
  }
}

// ─── Auto-Payment Frequency ────────────────────────────────────────────────

/// Frequency of scheduled automatic payments.
enum Frequency {
  /// Every day.
  daily,

  /// Once per week.
  weekly,

  /// Once every two weeks.
  biweekly,

  /// Once per month.
  monthly;

  String get label {
    switch (this) {
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

  /// Short label for compact UI (dropdowns, chips).
  String get shortLabel {
    switch (this) {
      case Frequency.daily:
        return 'Щодня';
      case Frequency.weekly:
        return 'Тиждень';
      case Frequency.biweekly:
        return '2 тижні';
      case Frequency.monthly:
        return 'Місяць';
    }
  }
}

// ─── Achievement Type ──────────────────────────────────────────────────────

/// Category of a gamified achievement.
enum AchievementType {
  /// First deposit ever made.
  firstDeposit,

  /// Saved a specific total amount.
  savingsMilestone,

  /// Consecutive daily logins.
  loginStreak,

  /// Completed a number of challenges.
  challengeCount,

  /// Reached a specific level.
  levelReached,

  /// Unfroze the dashboard after a frozen period.
  unfreeze,

  /// Completed a savings goal.
  goalCompleted,

  /// Saved for a full month without missing.
  monthlyConsistency,

  /// Accumulated a high streak (7+, 30+, etc.).
  streakMaster;

  /// Ukrainian display name.
  String get label {
    switch (this) {
      case AchievementType.firstDeposit:
        return 'Перший внесок';
      case AchievementType.savingsMilestone:
        return 'Етап заощаджень';
      case AchievementType.loginStreak:
        return 'Серія входів';
      case AchievementType.challengeCount:
        return 'Майстер викликів';
      case AchievementType.levelReached:
        return 'Новий рівень';
      case AchievementType.unfreeze:
        return 'Розтопи лід';
      case AchievementType.goalCompleted:
        return 'Цель досягнута';
      case AchievementType.monthlyConsistency:
        return 'Щомісячна стабільність';
      case AchievementType.streakMaster:
        return 'Майстер серії';
    }
  }

  /// Description text for the achievement detail screen.
  String get description {
    switch (this) {
      case AchievementType.firstDeposit:
        return 'Зроби свій перший внесок у ціль';
      case AchievementType.savingsMilestone:
        return 'Досягни визначної суми заощаджень';
      case AchievementType.loginStreak:
        return 'Входь у додаток кілька днів поспіль';
      case AchievementType.challengeCount:
        return 'Завершай виклики для розблокування';
      case AchievementType.levelReached:
        return 'Піднімайся новими рівнями системи';
      case AchievementType.unfreeze:
        return 'Повернись після замороження та продовжуй';
      case AchievementType.goalCompleted:
        return 'Повністю фінансуй свою ціль';
      case AchievementType.monthlyConsistency:
        return 'Збирай щодня протягом цілого місяця';
      case AchievementType.streakMaster:
        return 'Досягни рекордної серії заходів';
    }
  }

  /// Emoji icon for the achievement badge.
  String get icon {
    switch (this) {
      case AchievementType.firstDeposit:
        return '🌱';
      case AchievementType.savingsMilestone:
        return '💰';
      case AchievementType.loginStreak:
        return '🔥';
      case AchievementType.challengeCount:
        return '⚡';
      case AchievementType.levelReached:
        return '🌟';
      case AchievementType.unfreeze:
        return '🧊';
      case AchievementType.goalCompleted:
        return '🏆';
      case AchievementType.monthlyConsistency:
        return '📅';
      case AchievementType.streakMaster:
        return '💎';
    }
  }
}

// ─── Unlock Category ───────────────────────────────────────────────────────

/// Broad category group for unlockables (themes, avatars, effects).
enum UnlockCategory {
  /// Visual theme variations.
  theme,

  /// Profile avatar frames.
  avatarFrame,

  /// Dashboard background effects (particles, animations).
  effect,

  /// Special celebration animations.
  celebration,

  /// Exclusive badge designs.
  badge;

  /// Ukrainian label.
  String get label {
    switch (this) {
      case UnlockCategory.theme:
        return 'Тема';
      case UnlockCategory.avatarFrame:
        return 'Рамка аватара';
      case UnlockCategory.effect:
        return 'Ефект';
      case UnlockCategory.celebration:
        return 'Святкування';
      case UnlockCategory.badge:
        return 'Бейдж';
    }
  }

  /// Emoji representing the category.
  String get icon {
    switch (this) {
      case UnlockCategory.theme:
        return '🎨';
      case UnlockCategory.avatarFrame:
        return '🖼️';
      case UnlockCategory.effect:
        return '✨';
      case UnlockCategory.celebration:
        return '🎊';
      case UnlockCategory.badge:
        return '🏅';
    }
  }
}

// ─── Theme Mode ────────────────────────────────────────────────────────────

/// User-selected application theme mode.
enum ThemeMode {
  /// Always dark — PS5 neon palette.
  dark,

  /// Always light — Monitor frost palette.
  light,

  /// Follows system setting.
  system;

  /// Ukrainian label for settings screen.
  String get label {
    switch (this) {
      case ThemeMode.dark:
        return 'Темна';
      case ThemeMode.light:
        return 'Світла';
      case ThemeMode.system:
        return 'Системна';
    }
  }

  /// Description shown beneath the picker.
  String get description {
    switch (this) {
      case ThemeMode.dark:
        return 'Неонова тема у стилі PlayStation 5';
      case ThemeMode.light:
        return 'Мінимальна світла тема для монітора';
      case ThemeMode.system:
        return 'Автоматично змінюється разом із системою';
    }
  }

  /// Icon for the mode selector.
  String get icon {
    switch (this) {
      case ThemeMode.dark:
        return '🌙';
      case ThemeMode.light:
        return '☀️';
      case ThemeMode.system:
        return '💻';
    }
  }
}

// ─── Screen State ──────────────────────────────────────────────────────────

/// Стан екрану для управління UI-станами.
enum ScreenState {
  /// Вміст завантажується.
  loading,

  /// Дані успішно завантажені.
  loaded,

  /// Сталася помилка.
  error,

  /// Немає даних для відображення.
  empty,

  /// Початковий стан до першого завантаження.
  initial;

  /// Українська назва стану.
  String get label {
    switch (this) {
      case ScreenState.loading:
        return 'Завантаження…';
      case ScreenState.loaded:
        return 'Завантажено';
      case ScreenState.error:
        return 'Помилка';
      case ScreenState.empty:
        return 'Порожньо';
      case ScreenState.initial:
        return 'Початковий';
    }
  }

  /// Чи показувати індикатор завантаження.
  bool get isLoading => this == ScreenState.loading;

  /// Чи показувати стан помилки.
  bool get isError => this == ScreenState.error;

  /// Чи показувати стан порожнечі.
  bool get isEmpty => this == ScreenState.empty;
}

// ─── Animation Type ────────────────────────────────────────────────────────

/// Тип анімації для віджетів та переходів.
enum AnimationType {
  /// Плавна появлення знизу.
  slideUp,

  /// Плавна появлення зліва.
  slideLeft,

  /// Плавна появлення справа.
  slideRight,

  /// Масштабування від центру.
  scale,

  /// Згасання.
  fadeIn,

  /// Обертання.
  rotate,

  /// Пружинна анімація.
  spring,

  /// Без анімації.
  none;

  /// Українська назва типу анімації.
  String get label {
    switch (this) {
      case AnimationType.slideUp:
        return 'Зсув вгору';
      case AnimationType.slideLeft:
        return 'Зсув вліво';
      case AnimationType.slideRight:
        return 'Зсув вправо';
      case AnimationType.scale:
        return 'Масштаб';
      case AnimationType.fadeIn:
        return 'Згасання';
      case AnimationType.rotate:
        return 'Обертання';
      case AnimationType.spring:
        return 'Пружина';
      case AnimationType.none:
        return 'Без анімації';
    }
  }

  /// Тривалість анімації за замовчуванням (мілісекунди).
  int get defaultDurationMs {
    switch (this) {
      case AnimationType.slideUp:
      case AnimationType.slideLeft:
      case AnimationType.slideRight:
        return 300;
      case AnimationType.scale:
        return 250;
      case AnimationType.fadeIn:
        return 200;
      case AnimationType.rotate:
        return 400;
      case AnimationType.spring:
        return 500;
      case AnimationType.none:
        return 0;
    }
  }
}

// ─── Backup Format ─────────────────────────────────────────────────────────

/// Формат резервної копії даних.
enum BackupFormat {
  /// JSON формат — зручний для читання.
  json,

  /// CSV формат — для таблиць.
  csv,

  /// Внутрішній бінарний формат додатку.
  binary;

  /// Українська назва формату.
  String get label {
    switch (this) {
      case BackupFormat.json:
        return 'JSON файл';
      case BackupFormat.csv:
        return 'CSV файл';
      case BackupFormat.binary:
        return 'Бінарний файл';
    }
  }

  /// Розширення файлу.
  String get fileExtension {
    switch (this) {
      case BackupFormat.json:
        return '.json';
      case BackupFormat.csv:
        return '.csv';
      case BackupFormat.binary:
        return '.nexora';
    }
  }

  /// Опис формату для UI.
  String get description {
    switch (this) {
      case BackupFormat.json:
        return 'Універсальний формат для обміну даними';
      case BackupFormat.csv:
        return 'Табличний формат для аналізу в Excel';
      case BackupFormat.binary:
        return 'Оптимальний формат для відновлення в додатку';
    }
  }
}

// ─── Chart Type ────────────────────────────────────────────────────────────

/// Тип графіка для аналітики.
enum ChartType {
  /// Лінійний графік — тренд за часом.
  line,

  /// Стовпчиковий графік — порівняння значень.
  bar,

  /// Кругова діаграма — розподіл категорій.
  pie,

  /// Кільцева діаграма — прогрес цілі.
  donut,

  /// Площевий графік — накопичення за часом.
  area;

  /// Українська назва графіка.
  String get label {
    switch (this) {
      case ChartType.line:
        return 'Лінійний';
      case ChartType.bar:
        return 'Стовпчиковий';
      case ChartType.pie:
        return 'Круговий';
      case ChartType.donut:
        return 'Кільцевий';
      case ChartType.area:
        return 'Площевий';
    }
  }

  /// Опис графіка для підказок.
  String get description {
    switch (this) {
      case ChartType.line:
        return 'Показує динаміку змін за часом';
      case ChartType.bar:
        return 'Порівнює значення між періодами';
      case ChartType.pie:
        return 'Відображає частку кожної категорії';
      case ChartType.donut:
        return 'Показує прогрес до цільової суми';
      case ChartType.area:
        return 'Наглядно відображає накопичення';
    }
  }

  /// Іконка для вибору графіка.
  String get icon {
    switch (this) {
      case ChartType.line:
        return '📈';
      case ChartType.bar:
        return '📊';
      case ChartType.pie:
        return '🥧';
      case ChartType.donut:
        return '🍩';
      case ChartType.area:
        return '📉';
    }
  }
}

// ─── Widget Size ───────────────────────────────────────────────────────────

/// Розмір віджета для адаптивного інтерфейсу.
enum WidgetSize {
  /// Дуже малий — компактні елементи.
  xs,

  /// Малий — для списків та карток.
  sm,

  /// Середній — стандартний розмір за замовчуванням.
  md,

  /// Великий — для акцентних елементів.
  lg,

  /// Дуже великий — для героїв та банерів.
  xl;

  /// Коефіцієнт масштабу відносно md (1.0).
  double get scale {
    switch (this) {
      case WidgetSize.xs:
        return 0.75;
      case WidgetSize.sm:
        return 0.875;
      case WidgetSize.md:
        return 1.0;
      case WidgetSize.lg:
        return 1.25;
      case WidgetSize.xl:
        return 1.5;
    }
  }

  /// Українська назва розміру.
  String get label {
    switch (this) {
      case WidgetSize.xs:
        return 'Дуже малий';
      case WidgetSize.sm:
        return 'Малий';
      case WidgetSize.md:
        return 'Середній';
      case WidgetSize.lg:
        return 'Великий';
      case WidgetSize.xl:
        return 'Дуже великий';
    }
  }
}

// ─── Sorting Option ────────────────────────────────────────────────────────

/// Опція сортування для списків транзакцій та цілей.
enum SortingOption {
  /// За датою — новіші перші.
  newestFirst,

  /// За датою — старіші перші.
  oldestFirst,

  /// За сумою — від більшої до меншої.
  amountDescending,

  /// За сумою — від меншої до більшої.
  amountAscending,

  /// За назвою — алфавітний порядок.
  alphabetical;

  /// Українська назва опції сортування.
  String get label {
    switch (this) {
      case SortingOption.newestFirst:
        return 'Новіші перші';
      case SortingOption.oldestFirst:
        return 'Старіші перші';
      case SortingOption.amountDescending:
        return 'Сума: спадання';
      case SortingOption.amountAscending:
        return 'Сума: зростання';
      case SortingOption.alphabetical:
        return 'За алфавітом';
    }
  }

  /// Іконка опції сортування.
  String get icon {
    switch (this) {
      case SortingOption.newestFirst:
        return '🔽';
      case SortingOption.oldestFirst:
        return '🔼';
      case SortingOption.amountDescending:
        return '💰';
      case SortingOption.amountAscending:
        return '💵';
      case SortingOption.alphabetical:
        return '🔤';
    }
  }
}

// ─── Filter Type ───────────────────────────────────────────────────────────

/// Тип фільтра для відображення списків.
enum FilterType {
  /// Усі записи без фільтру.
  all,

  /// Тільки доходи (внески).
  income,

  /// Тільки за останній тиждень.
  thisWeek,

  /// Тільки за цей місяць.
  thisMonth,

  /// Тільки за цей рік.
  thisYear;

  /// Українська назва фільтра.
  String get label {
    switch (this) {
      case FilterType.all:
        return 'Усі';
      case FilterType.income:
        return 'Внески';
      case FilterType.thisWeek:
        return 'Цей тиждень';
      case FilterType.thisMonth:
        return 'Цей місяць';
      case FilterType.thisYear:
        return 'Цей рік';
    }
  }
}

// ─── Toast Type ────────────────────────────────────────────────────────────

/// Тип вспливаючого повідомлення.
enum ToastType {
  /// Звичайне повідомлення.
  info,

  /// Успішна дія.
  success,

  /// Попередження.
  warning,

  /// Помилка.
  error;

  /// Українська назва типу.
  String get label {
    switch (this) {
      case ToastType.info:
        return 'Інформація';
      case ToastType.success:
        return 'Успіх';
      case ToastType.warning:
        return 'Увага';
      case ToastType.error:
        return 'Помилка';
    }
  }

  /// Іконка для повідомлення.
  String get icon {
    switch (this) {
      case ToastType.info:
        return 'ℹ️';
      case ToastType.success:
        return '✅';
      case ToastType.warning:
        return '⚠️';
      case ToastType.error:
        return '❌';
    }
  }
}

// ─── Card Variant ──────────────────────────────────────────────────────────

/// Вариант картки для різних контекстів.
enum CardVariant {
  /// Стандартна картка з тінню.
  elevated,

  /// Плоска картка з рамкою.
  outlined,

  /// Картка з градієнтним фоном.
  gradient,

  /// Скляна картка з ефектом матового скла.
  glass,

  /// Картка з розширюваним вмістом.
  expandable;

  /// Українська назва варіанту.
  String get label {
    switch (this) {
      case CardVariant.elevated:
        return 'Піднята';
      case CardVariant.outlined:
        return 'Контурна';
      case CardVariant.gradient:
        return 'Градієнтна';
      case CardVariant.glass:
        return 'Скляна';
      case CardVariant.expandable:
        return 'Розширювана';
    }
  }
}

// ─── Icon Position ─────────────────────────────────────────────────────────

/// Позиція іконки відносно тексту в кнопках та елементах.
enum IconPosition {
  /// Іконка зліва від тексту.
  left,

  /// Іконка справа від тексту.
  right,

  /// Іконка зверху від тексту.
  top,

  /// Тільки іконка без тексту.
  only;

  /// Українська назва позиції.
  String get label {
    switch (this) {
      case IconPosition.left:
        return 'Зліва';
      case IconPosition.right:
        return 'Справа';
      case IconPosition.top:
        return 'Зверху';
      case IconPosition.only:
        return 'Тільки іконка';
    }
  }
}
