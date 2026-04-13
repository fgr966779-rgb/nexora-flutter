/// Тривалості анімацій та часові інтервали для додатку Nexora.
///
/// Всі тривалості організовані за категоріями для зручного пошуку:
/// - **Загальні** — базові часові токени для UI.
/// - **Мікроанімації** — точні таймінги згідно дизайн-специфікації.
/// - **UI-специфічні** — для кнопок, карток, overlay-їв тощо.
/// - **Святкування** — конфетті, феєрверки, підвищення рівня.
/// - **Настрійові** — тривалості, що змінюються з [ProgressMood].
/// - **Тактильні** — для послідовностей вібрацій.
/// - **Звукові** — для звукових сигналів.
/// - **Екранні** — пресети для конкретних екранів.
/// - **Багатокрокові** — готові послідовності анімацій.
/// - **Доступність** — альтернативи зменшеного руху.
/// - **Сповіщення** — для toast, snackbar, popup.
/// - **Навігація** — для переходів між екранами.
library;

/// Клас із статичними константами тривалостей анімацій та часових інтервалів.
///
/// Всі значення є [Duration] для зручного використання
/// разом з Flutter-анімаціями (AnimationController, Tween, etc.).
class AppDurations {
  AppDurations._();

  // ═══════════════════════════════════════════════════════════════════════
  // Загальні часові токени (General Timing Tokens)
  // ═══════════════════════════════════════════════════════════════════════

  /// Нульова тривалість — для миттєвих / no-op tween-ів.
  ///
  /// Використовується коли анімація має відбутися миттєво.
  static const Duration instant = Duration(milliseconds: 0);

  /// Швидкий зворотний зв'язок — малі вібрації, зміни кольорів.
  ///
  /// Для мікро-змін, що мають відчуватися миттєво.
  static const Duration fast = Duration(milliseconds: 150);

  /// Стандартний перехід — більшість UI-змін стану.
  ///
  /// Універсальна тривалість для кнопок, карток, перемикачів.
  static const Duration medium = Duration(milliseconds: 300);

  /// Повільний, навмисний перехід — зміна сторінок, layout-зміни.
  ///
  /// Для великих змін інтерфейсу, що потребують уваги.
  static const Duration slow = Duration(milliseconds: 500);

  /// Дуже повільний — для рідкісних драматичних розкриттів.
  ///
  /// Використовується обережно — тільки для ефектних появ.
  static const Duration xslow = Duration(milliseconds: 800);

  /// Надповільний — для дуже навмисних, кінематографічних анімацій.
  ///
  /// Для onboarding-послідовностей або святкових ефектів.
  static const Duration xxslow = Duration(milliseconds: 1200);

  /// Ультраповільний — для розгорнутих cinematiчних ефектів.
  ///
  /// Для multi-stage святкувань з кількома фазами.
  static const Duration xxxslow = Duration(milliseconds: 2000);

  // ═══════════════════════════════════════════════════════════════════════
  // Дизайн-специфікація мікроанімацій (Design-Spec Micro-Animation Scale)
  // ═══════════════════════════════════════════════════════════════════════

  /// Мікро — fade tooltip, tiny icon bounce.
  ///
  /// Найменша помітна анімація — для делікатних ефектів.
  static const Duration micro = Duration(milliseconds: 100);

  /// Малий — кнопка press, badge pop.
  ///
  /// Для зворотного зв'язку при натисканні.
  static const Duration small = Duration(milliseconds: 200);

  /// Середній — slide-in картки, появлення листа.
  ///
  /// Стандартна тривалість для більшості UI-елементів.
  static const Duration mediumSpec = Duration(milliseconds: 300);

  /// Великий — модальний вхід, hero-перехід.
  ///
  /// Для повноекранних або overlay-переходів.
  static const Duration large = Duration(milliseconds: 400);

  /// Кінематографічний — розкриття цілі, драматичний зворотний відлік.
  ///
  /// Для ефектних появ, що привертають увагу.
  static const Duration cinematic = Duration(milliseconds: 1000);

  /// Ультра-кінематографічний — розширені святкування, onboarding.
  ///
  /// Для довгих святкових послідовностей.
  static const Duration ultraCinematic = Duration(milliseconds: 1500);

  /// Епічний — для багатостадійних святкувань.
  ///
  /// Найдовша стандартна тривалість в додатку.
  static const Duration epic = Duration(milliseconds: 2000);

  // ═══════════════════════════════════════════════════════════════════════
  // UI-специфічні тривалості (UI-Specific Durations)
  // ═══════════════════════════════════════════════════════════════════════

  /// Підсвічування кнопки при наведенні (hover).
  ///
  /// Тривалість підсвічування при наведенні мишею (десктоп).
  static const Duration buttonHover = Duration(milliseconds: 150);

  /// Зворотний зв'язок при натисканні кнопки.
  ///
  /// Тривалість press-ефекту кнопки.
  static const Duration buttonPress = Duration(milliseconds: 100);

  /// Зворотний зв'язок при натисканні картки / tile.
  ///
  /// Тривалість press-ефекту для карток.
  static const Duration cardPress = Duration(milliseconds: 100);

  /// Анімація входу картки (slide in).
  ///
  /// Для появи карток цілей, транзакцій при завантаженні.
  static const Duration cardEnter = Duration(milliseconds: 350);

  /// Анімація виходу картки (slide out).
  ///
  /// Для зникнення карток при видаленні або заміні.
  static const Duration cardExit = Duration(milliseconds: 250);

  /// Цикл shimmer-ефекту завантаження.
  ///
  /// Повний цикл руху підсвітки для skeleton-loader.
  static const Duration shimmer = Duration(milliseconds: 1200);

  /// Цикл pulse для skeleton-placeholder.
  ///
  /// Тривалість однієї пульсації skeleton-елемента.
  static const Duration skeleton = Duration(milliseconds: 1500);

  /// Перехід page route (push / pop).
  ///
  /// Стандартна тривалість навігації між екранами.
  static const Duration pageTransition = Duration(milliseconds: 400);

  /// Відбій spring для інтерактивних елементів.
  ///
  /// Для bounce-back ефекту при відпусканні.
  static const Duration bounce = Duration(milliseconds: 400);

  /// Цикл pulse / дихаючої анімації.
  ///
  /// Повний цикл "вдиху-видиху" для pulsating елементів.
  static const Duration pulse = Duration(milliseconds: 1000);

  /// Лічильник count-up для відображення грошей.
  ///
  /// Тривалість підрахунку від 0 до цільового значення.
  static const Duration countUp = Duration(milliseconds: 600);

  /// Лічильник count-down.
  ///
  /// Тривалість зворотного підрахунку.
  static const Duration countDown = Duration(milliseconds: 500);

  /// Тривалість вибуху конфетті.
  ///
  /// Від появи до повного зникнення частинок.
  static const Duration confetti = Duration(milliseconds: 2000);

  /// Час відображення toast / snackbar.
  ///
  /// Скільки часу toast visible перед автоматичним зникненням.
  static const Duration toast = Duration(milliseconds: 2500);

  /// Анімація появи/зникнення toast.
  ///
  /// Вхід та вихід анімації toast.
  static const Duration toastAnimation = Duration(milliseconds: 300);

  /// Поява напівпрозорого overlay.
  ///
  /// Fade-in для затемнення фону за модалкою.
  static const Duration fadeOverlay = Duration(milliseconds: 250);

  /// Зникнення напівпрозорого overlay.
  ///
  /// Fade-out для затемнення фону.
  static const Duration fadeOutOverlay = Duration(milliseconds: 200);

  /// Slide-in нижнього листа / бічної панелі.
  ///
  /// Для BottomSheet, Drawer, SidePanel.
  static const Duration slideOverlay = Duration(milliseconds: 350);

  /// Анімація перегортання картки (front ↔ back).
  ///
  /// Тривалість 3D flip-ефекту.
  static const Duration flipCard = Duration(milliseconds: 600);

  /// Анімація заповнення прогрес-бару.
  ///
  /// Від 0% до поточного значення прогресу.
  static const Duration progressFill = Duration(milliseconds: 800);

  /// Анімація заповнення XP-шки.
  ///
  /// Тривалість появи досвіду на шкалі.
  static const Duration xpBarFill = Duration(milliseconds: 600);

  /// Цикл пульсації неонового сяйва.
  ///
  /// Повний цикл "світіння-гасіння" для неонових елементів.
  static const Duration glow = Duration(milliseconds: 1500);

  /// Ефект танення криги / морозу.
  ///
  /// Тривалість dissolve-ефекту для морозної теми.
  static const Duration frostMelt = Duration(milliseconds: 1200);

  /// Час життя частинки феєрверку.
  ///
  /// Від вибуху до зникнення однієї частинки.
  static const Duration firework = Duration(milliseconds: 900);

  /// Друкарська машинка — розкриття одного символу.
  ///
  /// Тривалість появи одного символу при typewriter-ефекті.
  static const Duration typewriter = Duration(milliseconds: 40);

  /// Швидка друкарська машинка — один символ.
  ///
  /// Прискорений typewriter для довгих текстів.
  static const Duration typewriterFast = Duration(milliseconds: 25);

  /// Повільна друкарська машинка — один символ.
  ///
  /// Для драматичного, помітного розкриття тексту.
  static const Duration typewriterSlow = Duration(milliseconds: 60);

  /// Тривалість ripple splash при Material tap.
  ///
  /// Стандартна тривалість Material ripple-ефекту.
  static const Duration ripple = Duration(milliseconds: 200);

  /// Затримка між елементами при staggered-анімації.
  ///
  /// Стандартна затримка для послідовної появи елементів.
  static const Duration staggerDelay = Duration(milliseconds: 60);

  /// Скорочена затримка для щільних списків.
  ///
  /// Менша затримка для великої кількості елементів.
  static const Duration staggerDelayShort = Duration(milliseconds: 40);

  /// Збільшена затримка для просторих списків.
  ///
  /// Більша затримка для меншої кількості великих елементів.
  static const Duration staggerDelayLong = Duration(milliseconds: 80);

  /// Тривалість ковзання tab-індикатора.
  ///
  /// Для TabBar indicator animation.
  static const Duration tabIndicator = Duration(milliseconds: 250);

  /// Перемикання checkbox / switch toggle.
  ///
  /// Тривалість анімації стану toggle-елементів.
  static const Duration toggle = Duration(milliseconds: 200);

  /// Анімація slider thumb.
  ///
  /// Для Slider / RangeSlider thumb movement.
  static const Duration slider = Duration(milliseconds: 150);

  /// Затримка появи tooltip.
  ///
  /// Скільки чекати перед показом tooltip.
  static const Duration tooltipAppear = Duration(milliseconds: 200);

  /// Затримка зникнення tooltip.
  ///
  /// Скільки чекати перед прихованням tooltip.
  static const Duration tooltipDisappear = Duration(milliseconds: 150);

  /// Розгортання dropdown меню.
  ///
  /// Тривалість появи DropdownMenu / PopupMenu.
  static const Duration dropdownExpand = Duration(milliseconds: 250);

  /// Згортання dropdown меню.
  ///
  /// Тривалість зникнення DropdownMenu / PopupMenu.
  static const Duration dropdownCollapse = Duration(milliseconds: 200);

  /// Розгортання пошукового рядка.
  ///
  /// Для анімації expand search bar.
  static const Duration searchExpand = Duration(milliseconds: 300);

  /// Згортання пошукового рядка.
  ///
  /// Для анімації collapse search bar.
  static const Duration searchCollapse = Duration(milliseconds: 250);

  /// Анімація вибору чіпу.
  ///
  /// Тривалість зміни стану FilterChip / ChoiceChip.
  static const Duration chipSelect = Duration(milliseconds: 200);

  /// Анімація морфінгу FAB.
  ///
  /// Тривалість перетворення FAB на різні форми.
  static const Duration fabMorph = Duration(milliseconds: 300);

  /// Сховання/поява AppBar при гортанні.
  ///
  /// Для scroll-aware AppBar hide/show.
  static const Duration appBarScroll = Duration(milliseconds: 300);

  /// Показ/сховання BottomNavigationBar.
  ///
  /// Для scroll-aware bottom nav hide/show.
  static const Duration navBarShowHide = Duration(milliseconds: 250);

  /// Поява клавіатури.
  ///
  /// Тривалість підняття клавіатури на екрані.
  static const Duration keyboardAppear = Duration(milliseconds: 300);

  /// Прибирання клавіатури.
  ///
  /// Тривалість опускання клавіатури з екрана.
  static const Duration keyboardDismiss = Duration(milliseconds: 250);

  /// Анімація зміни розміру елемента.
  ///
  /// Для AnimatedSize / AnimatedContainer.
  static const Duration sizeChange = Duration(milliseconds: 250);

  /// Анімація зміни кольору елемента.
  ///
  /// Для анімованої зміни теми або кольору.
  static const Duration colorChange = Duration(milliseconds: 300);

  /// Анімація появи blur-ефекту.
  ///
  /// Для backdrop filter appearance.
  static const Duration blurAppear = Duration(milliseconds: 200);

  /// Анімація зникнення blur-ефекту.
  ///
  /// Для backdrop filter disappearance.
  static const Duration blurDisappear = Duration(milliseconds: 150);

  // ═══════════════════════════════════════════════════════════════════════
  // Тривалості святкувань (Celebration Durations)
  // ═══════════════════════════════════════════════════════════════════════

  /// Анімація входу бейджу підвищення рівня.
  ///
  /// Тривалість появи level-up badge з усіма ефектами.
  static const Duration levelUp = Duration(milliseconds: 1200);

  /// Фанфари розблокування досягнення.
  ///
  /// Повна тривалість unlock achievement celebration.
  static const Duration achievementUnlock = Duration(milliseconds: 1400);

  /// Цикл мерехтіння полум'я серії.
  ///
  /// Один цикл анімації streak fire flame.
  static const Duration streakFlame = Duration(milliseconds: 700);

  /// Загальна тривалість святкування завершення цілі.
  ///
  /// Від початку конфетті до повного зникнення.
  static const Duration goalComplete = Duration(milliseconds: 3000);

  /// Час життя частинки "дощ із грошей".
  ///
  /// Від появи до зникнення монеток.
  static const Duration moneyRain = Duration(milliseconds: 2500);

  /// Анімація спалаху зірок.
  ///
  /// Тривалість star burst celebration effect.
  static const Duration starBurst = Duration(milliseconds: 800);

  /// Анімація розкриття трофею.
  ///
  /// Тривалість trophy reveal animation.
  static const Duration trophyReveal = Duration(milliseconds: 1000);

  /// Анімація блиску бейджу (shine sweep).
  ///
  /// Тривалість проходження світлової смуги по бейджу.
  static const Duration badgeShine = Duration(milliseconds: 1500);

  /// Час відображення спливаючого повідомлення XP.
  ///
  /// Скільки часу visible "+100 XP" popup.
  static const Duration xpPopup = Duration(milliseconds: 800);

  /// Анімація збирання монетки.
  ///
  /// Тривалість "присмоктування" монетки до бейджу.
  static const Duration coinCollect = Duration(milliseconds: 600);

  /// Час відображення лічильника комбо.
  ///
  /// Скільки часу visible "x3 Комбо!" message.
  static const Duration comboDisplay = Duration(milliseconds: 1000);

  /// Цикл анімації попередження серії.
  ///
  /// Для "ваша серія закінчується!" effect.
  static const Duration streakWarning = Duration(milliseconds: 2000);

  /// Тривалість ефекту заморожування.
  ///
  /// Для freeze effect при розриві серії.
  static const Duration freezeEffect = Duration(milliseconds: 500);

  /// Тривалість ефекту "розблокування челенджу".
  ///
  /// Для анімації відкриття нового виклику.
  static const Duration challengeUnlock = Duration(milliseconds: 800);

  /// Тривалість появи reward overlay.
  ///
  /// Для повноекранного overlay з нагородою.
  static const Duration rewardOverlay = Duration(milliseconds: 1500);

  // ═══════════════════════════════════════════════════════════════════════
  // Настрійові тривалості (Mood-Based Animation Durations)
  // ═══════════════════════════════════════════════════════════════════════
  // Тривалості адаптуються до поточного [ProgressMood] для динамічного відчуття.

  /// Спокійний (початок заощаджень) — повільний, zen-подібний.
  ///
  /// На початку шляху анімації плавні та розслаблені.
  static const Duration moodCalm = Duration(milliseconds: 600);

  /// Зростання — пришвидшується.
  ///
  /// Користувач робить прогрес — анімації стають жвавішими.
  static const Duration moodGrowing = Duration(milliseconds: 450);

  /// Енергійний — помітно швидший.
  ///
  /// Ближче до половини цілі — відчуття енергії.
  static const Duration moodEnergetic = Duration(milliseconds: 300);

  /// Прискорення — біля 80%, швидке очікування.
  ///
  /// Користувач нетерпляче чекає завершення.
  static const Duration moodAccelerating = Duration(milliseconds: 200);

  /// Фінал — останній ривок, швидкі сплески.
  ///
  /// Останні 20% — анімації максимально швидкі.
  static const Duration moodFinale = Duration(milliseconds: 120);

  // ═══════════════════════════════════════════════════════════════════════
  // Тактильні тривалості (Haptic Feedback Durations)
  // ═══════════════════════════════════════════════════════════════════════

  /// Інтервал між легкими вібраціями в патерні.
  ///
  /// Затримка між імпульсами HapticFeedback.lightImpact.
  static const Duration hapticLightInterval = Duration(milliseconds: 50);

  /// Інтервал між середніми вібраціями.
  ///
  /// Затримка між імпульсами HapticFeedback.mediumImpact.
  static const Duration hapticMediumInterval = Duration(milliseconds: 100);

  /// Інтервал між сильними вібраціями.
  ///
  /// Затримка між імпульсами HapticFeedback.heavyImpact.
  static const Duration hapticHeavyInterval = Duration(milliseconds: 150);

  /// Інтервал між виборами (toggle, tabs).
  ///
  /// Для HapticFeedback.selectionClick.
  static const Duration hapticSelectionInterval = Duration(milliseconds: 60);

  /// Тривалість конфетті-патерну (усі імпульси).
  ///
  /// Повний патерн вібрацій для святкування.
  static const Duration hapticConfettiPattern = Duration(milliseconds: 240);

  /// Тривалість патерну level-up.
  ///
  /// Послідовність вібрацій при підвищенні рівня.
  static const Duration hapticLevelUpPattern = Duration(milliseconds: 500);

  /// Тривалість патерну розблокування досягнення.
  ///
  /// Для Haptic pattern при отриманні badge.
  static const Duration hapticAchievementPattern =
      Duration(milliseconds: 600);

  /// Тривалість патерну помилки.
  ///
  /// Короткий патерн при помилковій дії.
  static const Duration hapticErrorPattern = Duration(milliseconds: 200);

  // ═══════════════════════════════════════════════════════════════════════
  // Звукові тривалості (Sound Effect Durations)
  // ═══════════════════════════════════════════════════════════════════════

  /// Тривалість звуку монетки.
  ///
  /// Час відтворення "ding" при отриманні монет.
  static const Duration soundCoin = Duration(milliseconds: 300);

  /// Тривалість звуку досягнення.
  ///
  /// Час відтворення fanfare при досягненні milestone.
  static const Duration soundAchievement = Duration(milliseconds: 500);

  /// Тривалість звуку помилки.
  ///
  /// Час відтворення error sound.
  static const Duration soundError = Duration(milliseconds: 400);

  /// Тривалість звуку натискання.
  ///
  /// Час відтворення click sound.
  static const Duration soundTap = Duration(milliseconds: 100);

  /// Тривалість звуку підвищення рівня.
  ///
  /// Час відтворення level-up fanfare.
  static const Duration soundLevelUp = Duration(milliseconds: 800);

  /// Тривалість звуку перемикача.
  ///
  /// Час відтворення toggle sound.
  static const Duration soundToggle = Duration(milliseconds: 150);

  /// Тривалість звуку попередження.
  ///
  /// Час відтворення warning sound.
  static const Duration soundWarning = Duration(milliseconds: 350);

  /// Тривалість звуку навігації.
  ///
  /// Час відтворення navigate sound.
  static const Duration soundNavigate = Duration(milliseconds: 200);

  /// Тривалість звуку святкування.
  ///
  /// Час відтворення celebration sound.
  static const Duration soundCelebration = Duration(milliseconds: 1500);

  // ═══════════════════════════════════════════════════════════════════════
  // Екранні пресети (Screen-Specific Timing Presets)
  // ═══════════════════════════════════════════════════════════════════════

  /// Тривалість анімації входу на головний екран.
  ///
  /// З stagger для дашбордних карток.
  static const Duration homeEnter = Duration(milliseconds: 400);

  /// Тривалість анімації карток цілей.
  ///
  /// Для GoalCard slide-in / fade-in.
  static const Duration goalsCardAnim = Duration(milliseconds: 350);

  /// Тривалість анімації списку транзакцій.
  ///
  /// Для TransactionList stagger appearance.
  static const Duration transactionsListAnim = Duration(milliseconds: 300);

  /// Тривалість анімації профілю користувача.
  ///
  /// Для ProfileScreen entrance animation.
  static const Duration profileEnter = Duration(milliseconds: 500);

  /// Тривалість анімації налаштувань.
  ///
  /// Для SettingsScreen transition.
  static const Duration settingsTransition = Duration(milliseconds: 300);

  /// Тривалість анімації аналітики.
  ///
  /// Для Chart appear animation (bars, lines).
  static const Duration analyticsChartAnim = Duration(milliseconds: 800);

  /// Тривалість анімації челенджів.
  ///
  /// Для ChallengeCard entrance animation.
  static const Duration challengeCardAnim = Duration(milliseconds: 400);

  /// Тривалість анімації онбордингу.
  ///
  /// Для OnboardingPage transitions.
  static const Duration onboardingTransition = Duration(milliseconds: 500);

  /// Тривалість анімації экрану деталей цілі.
  ///
  /// Для GoalDetailScreen entrance.
  static const Duration goalDetailEnter = Duration(milliseconds: 350);

  /// Тривалість анімації редактора цілі.
  ///
  /// Для GoalEditorScreen appearance.
  static const Duration goalEditorEnter = Duration(milliseconds: 300);

  // ═══════════════════════════════════════════════════════════════════════
  // Багатокрокові послідовності (Multi-Step Animation Sequences)
  // ═══════════════════════════════════════════════════════════════════════

  /// Затримка між кроками багатоетапної анімації.
  ///
  /// Пауза між фазами multi-stage celebration.
  static const Duration stepDelay = Duration(milliseconds: 100);

  /// Час на крок у послідовності досягнення цілі.
  ///
  /// Тривалість одного етапу goal completion celebration.
  static const Duration goalStep = Duration(milliseconds: 500);

  /// Час на крок у послідовності level-up.
  ///
  /// Тривалість одного етапу level-up animation.
  static const Duration levelUpStep = Duration(milliseconds: 300);

  /// Затримка перед початком святкування.
  ///
  /// Пауза між "завершенням дії" та "початком святкування".
  static const Duration celebrationDelay = Duration(milliseconds: 200);

  /// Тривалість фази "підготовки" перед головним ефектом.
  ///
  /// Для "charging up" перед confetti / firework.
  static const Duration preparationPhase = Duration(milliseconds: 400);

  /// Тривалість фази "кульмінації" святкування.
  ///
  /// Головна фаза святкування — maximum impact.
  static const Duration climaxPhase = Duration(milliseconds: 1000);

  /// Тривалість фази "згасання" після святкування.
  ///
  /// Плавне зникнення останніх ефектів.
  static const Duration fadeOutPhase = Duration(milliseconds: 500);

  // ═══════════════════════════════════════════════════════════════════════
  // Сповіщення (Notification Durations)
  // ═══════════════════════════════════════════════════════════════════════

  /// Тривалість відображення success notification.
  ///
  /// Скільки часу visible зелене сповіщення успіху.
  static const Duration successNotification = Duration(milliseconds: 2000);

  /// Тривалість відображення error notification.
  ///
  /// Скільки часу visible червоне сповіщення помилки.
  static const Duration errorNotification = Duration(milliseconds: 3000);

  /// Тривалість відображення info notification.
  ///
  /// Скільки часу visible синє інформаційне сповіщення.
  static const Duration infoNotification = Duration(milliseconds: 2500);

  /// Тривалість відображення warning notification.
  ///
  /// Скільки часу visible жовте попереджувальне сповіщення.
  static const Duration warningNotification = Duration(milliseconds: 3000);

  // ═══════════════════════════════════════════════════════════════════════
  // Навігація (Navigation Durations)
  // ═══════════════════════════════════════════════════════════════════════

  /// Тривалість переходу вперед (push).
  ///
  /// Для Navigator.push анімації.
  static const Duration navPush = Duration(milliseconds: 350);

  /// Тривалість переходу назад (pop).
  ///
  /// Для Navigator.pop анімації.
  static const Duration navPop = Duration(milliseconds: 300);

  /// Тривалість появи діалогу.
  ///
  /// Для showDialog / showGeneralDialog.
  static const Duration dialogShow = Duration(milliseconds: 250);

  /// Тривалість закриття діалогу.
  ///
  /// For Navigator.pop closing dialog.
  static const Duration dialogDismiss = Duration(milliseconds: 200);

  /// Тривалість появи bottom sheet.
  ///
  /// Для showModalBottomSheet entrance.
  static const Duration sheetShow = Duration(milliseconds: 350);

  /// Тривалість закриття bottom sheet.
  ///
  /// Для BottomSheet dismiss.
  static const Duration sheetDismiss = Duration(milliseconds: 250);

  // ═══════════════════════════════════════════════════════════════════════
  // Доступність (Accessibility Durations)
  // ═══════════════════════════════════════════════════════════════════════

  /// Reduced motion — мінімальна тривалість для анімацій.
  ///
  /// Використовується коли користувач увімкнув "зменшення руху".
  static const Duration reducedMotion = Duration(milliseconds: 50);

  /// Reduced motion — тривалість переходів при зменшенні руху.
  ///
  /// Зменшена тривалість для переходів між станами.
  static const Duration reducedMotionTransition = Duration(milliseconds: 100);

  /// No motion fallback — миттєвий перехід.
  ///
  /// Повне вимкнення анімацій для максимальної доступності.
  static const Duration noMotion = Duration.zero;

  // ═══════════════════════════════════════════════════════════════════════
  // Допоміжні методи (Utility Methods)
  // ═══════════════════════════════════════════════════════════════════════

  /// Повертає тривалість анімації залежно від відсотка прогресу.
  ///
  /// Ближче до цілі — швидша анімація (менше терпіння!).
  /// На початку шляху — повільна, розслаблена анімація.
  ///
  /// [progress] — відсоток виконання цілі (0.0–1.0).
  /// [baseDuration] — базова тривалість (за замовчуванням 600мс).
  ///
  /// Приклад:
  /// ```dart
  /// final dur = AppDurations.moodBasedDuration(progress: 0.8);
  /// // → ~120мс (швидко!)
  /// ```
  static Duration moodBasedDuration({
    required double progress,
    Duration baseDuration = const Duration(milliseconds: 600),
  }) {
    final clamped = progress.clamp(0.0, 1.0);
    final multiplier = 1.0 - clamped * 0.8; // від 1.0x до 0.2x
    final ms = (baseDuration.inMilliseconds * multiplier).round();
    return Duration(milliseconds: ms);
  }

  /// Повертає тривалість для анімації з урахуванням reduced motion.
  ///
  /// Якщо [reducedMotion] = true — повертає дуже коротку тривалість.
  /// Це гарантує, що анімації не будуть надто тривалими
  /// для користувачів із чутливістю до руху.
  ///
  /// [duration] — оригінальна тривалість.
  /// [reducedMotion] — чи увімкнено режим зменшення руху.
  static Duration accessibleDuration(
    Duration duration, {
    bool reducedMotion = false,
  }) {
    if (reducedMotion) {
      return Duration(
        milliseconds: duration.inMilliseconds.clamp(0, 100),
      );
    }
    return duration;
  }

  /// Обчислює затримку для елемента у каскадній анімації.
  ///
  /// Кожен наступний елемент має більшу затримку.
  ///
  /// [index] — індекс елемента (починаючи з 0).
  /// [staggerMs] — затримка між елементами (за замовчуванням 60мс).
  ///
  /// Приклад:
  /// ```dart
  /// final delay = AppDurations.staggeredDelay(3); // → 180мс
  /// ```
  static Duration staggeredDelay(int index, {int staggerMs = 60}) {
    return Duration(milliseconds: index * staggerMs);
  }

  /// Створює послідовність тривалостей для багатоетапної анімації.
  ///
  /// Генерує список тривалостей для кожного кроку.
  ///
  /// [steps] — кількість кроків.
  /// [stepDuration] — тривалість кожного кроку.
  /// [gapDuration] — пауза між кроками.
  ///
  /// Приклад:
  /// ```dart
  /// final seq = AppDurations.createSequence(steps: 3);
  /// // → [300мс, 300мс, 300мс]
  /// ```
  static List<Duration> createSequence({
    required int steps,
    Duration stepDuration = const Duration(milliseconds: 300),
    Duration gapDuration = const Duration(milliseconds: 100),
  }) {
    return List.generate(
      steps,
      (_) => stepDuration,
    );
  }

  /// Інтерполює між двома тривалостями.
  ///
  /// Повертає проміжне значення між [from] та [to].
  ///
  /// [from] — початкова тривалість.
  /// [to] — кінцева тривалість.
  /// [t] — коефіцієнт (0.0 = from, 1.0 = to).
  ///
  /// Приклад:
  /// ```dart
  /// final dur = AppDurations.lerp(
  ///   Duration(milliseconds: 100),
  ///   Duration(milliseconds: 500),
  ///   0.5,
  /// ); // → 300мс
  /// ```
  static Duration lerp(Duration from, Duration to, double t) {
    final clamped = t.clamp(0.0, 1.0);
    final ms = (from.inMilliseconds +
            (to.inMilliseconds - from.inMilliseconds) * clamped)
        .round();
    return Duration(milliseconds: ms);
  }

  /// Масштабує тривалість відносно базової.
  ///
  /// [duration] — базова тривалість.
  /// [scale] — коефіцієнт масштабування (наприклад, 0.5 = вдвічі швидше).
  ///
  /// Максимальний результат обмежений 5000мс для запобігання
  /// надто довгим анімаціям.
  static Duration scale(Duration duration, double scale) {
    return Duration(
      milliseconds: (duration.inMilliseconds * scale).round().clamp(0, 5000),
    );
  }

  /// Повертає тривалість для "breathing" ефекту.
  ///
  /// Генерує пару (inspire, expire) для дихаючої анімації.
  ///
  /// [cycleDuration] — повний цикл (за замовчуванням 2000мс).
  static ({Duration inDuration, Duration outDuration}) breathingCycle({
    Duration cycleDuration = const Duration(milliseconds: 2000),
  }) {
    final half = cycleDuration ~/ 2;
    return (inDuration: Duration(milliseconds: half), outDuration: Duration(milliseconds: half));
  }

  /// Повертає суму двох тривалостей.
  ///
  /// Корисний для обчислення загальної тривалості послідовності.
  ///
  /// [a] — перша тривалість.
  /// [b] — друга тривалість.
  static Duration add(Duration a, Duration b) {
    return a + b;
  }

  /// Повертає різницю двох тривалостей (не менше нуля).
  ///
  /// [a] — перша тривалість (зменшувана).
  /// [b] — друга тривалість (віднімальна).
  static Duration subtract(Duration a, Duration b) {
    final result = a - b;
    return result.isNegative ? Duration.zero : result;
  }

  /// Повертає максимальну з двох тривалостей.
  ///
  /// [a] — перша тривалість.
  /// [b] — друга тривалість.
  static Duration max(Duration a, Duration b) {
    return a > b ? a : b;
  }

  /// Повертає мінімальну з двох тривалостей.
  ///
  /// [a] — перша тривалість.
  /// [b] — друга тривалість.
  static Duration min(Duration a, Duration b) {
    return a < b ? a : b;
  }

  /// Повертає випадкову тривалість у заданих межах.
  ///
  /// Корисний для "натуральної" вариації в staggered-анімаціях.
  ///
  /// [min] — мінімальна тривалість.
  /// [max] — максимальна тривалість.
  static Duration randomInRange(Duration min, Duration max) {
    if (min >= max) return min;
    // Випадкове значення — спрощена реалізація
    final range = max.inMilliseconds - min.inMilliseconds;
    final random = (DateTime.now().microsecond % 1000) / 1000;
    return Duration(milliseconds: min.inMilliseconds + (range * random).round());
  }
}
