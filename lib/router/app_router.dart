import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// ─── Онбординг ──────────────────────────────────────────────────────────────
import '../features/onboarding/presentation/screens/welcome_screen.dart';
import '../features/onboarding/presentation/screens/concept_screen.dart';
import '../features/onboarding/presentation/screens/choose_goal_screen.dart';
import '../features/onboarding/presentation/screens/set_goal_screen.dart';
import '../features/onboarding/presentation/screens/first_deposit_screen.dart';

// ─── Головна панель ─────────────────────────────────────────────────────────
import '../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../features/dashboard/presentation/screens/goal_detail_screen.dart';
import '../features/dashboard/presentation/screens/almost_there_screen.dart';
import '../features/dashboard/presentation/screens/subgoals_screen.dart';
import '../features/dashboard/presentation/screens/inactive_screen.dart';
import '../features/dashboard/presentation/screens/breakdown_screen.dart';

// ─── Внески ─────────────────────────────────────────────────────────────────
import '../features/deposit/presentation/screens/enter_amount_screen.dart';
import '../features/deposit/presentation/screens/confirm_deposit_screen.dart';
import '../features/deposit/presentation/screens/challenges_screen.dart';
import '../features/deposit/presentation/screens/auto_payments_screen.dart';
import '../features/deposit/presentation/screens/setup_autopay_screen.dart';
import '../features/deposit/presentation/screens/success_animation_screen.dart';
import '../features/deposit/presentation/screens/error_cancel_screen.dart';
import '../features/deposit/presentation/screens/challenge_complete_screen.dart';

// ─── Аналітика ──────────────────────────────────────────────────────────────
import '../features/analytics/presentation/screens/overall_stats_screen.dart';
import '../features/analytics/presentation/screens/accumulation_chart_screen.dart';
import '../features/analytics/presentation/screens/transaction_history_screen.dart';
import '../features/analytics/presentation/screens/forecast_screen.dart';
import '../features/analytics/presentation/screens/period_comparison_screen.dart';
import '../features/analytics/presentation/screens/activity_detail_screen.dart';

// ─── Гейміфікація ───────────────────────────────────────────────────────────
import '../features/gamification/presentation/screens/user_level_screen.dart';
import '../features/gamification/presentation/screens/badges_screen.dart';
import '../features/gamification/presentation/screens/achievements_screen.dart';
import '../features/gamification/presentation/screens/unlocks_shop_screen.dart';
import '../features/gamification/presentation/screens/level_progress_screen.dart';
import '../features/gamification/presentation/screens/reward_screen.dart';
import '../features/gamification/presentation/screens/garden_screen.dart';

// ─── Соціальна мережа ───────────────────────────────────────────────────────
import '../features/social/presentation/screens/share_progress_screen.dart';
import '../features/social/presentation/screens/motivation_feed_screen.dart';
import '../features/social/presentation/screens/achievement_history_screen.dart';
import '../features/social/presentation/screens/result_preview_screen.dart';

// ─── Налаштування ────────────────────────────────────────────────────────────
import '../features/settings/presentation/screens/profile_screen.dart';
import '../features/settings/presentation/screens/change_theme_screen.dart';
import '../features/settings/presentation/screens/notifications_screen.dart';
import '../features/settings/presentation/screens/security_screen.dart';
import '../features/settings/presentation/screens/backup_screen.dart';
import '../features/settings/presentation/screens/subscription_scanner_screen.dart';

// ─── Фінальні екрани ─────────────────────────────────────────────────────────
import '../features/final/presentation/screens/cinematic_screen.dart';
import '../features/final/presentation/screens/journey_summary_screen.dart';
import '../features/final/presentation/screens/new_goal_screen.dart';
import '../features/final/presentation/screens/goal_reached_screen.dart';

// ─── Віджети ─────────────────────────────────────────────────────────────────
import '../core/widgets/app_bottom_nav.dart';

// ─── Константи шляхів ───────────────────────────────────────────────────────

/// Константи маршрутів додатку Nexora.
///
/// Використовуйте ці константи замість рядкових літералів
/// для безпечного переходу між екранами.
class AppRoutes {
  AppRoutes._();

  // ─── Онбординг ──────────────────────────────────────────────────────────
  static const String welcome = '/';
  static const String concept = '/concept';
  static const String chooseGoal = '/choose-goal';
  static const String setGoal = '/set-goal';
  static const String firstDeposit = '/first-deposit';

  // ─── Головна ────────────────────────────────────────────────────────────
  static const String dashboard = '/dashboard';
  static const String goalDetail = '/goal-detail';
  static const String almostThere = '/almost-there';
  static const String subgoals = '/subgoals';
  static const String inactive = '/inactive';
  static const String breakdown = '/breakdown';

  // ─── Внески ─────────────────────────────────────────────────────────────
  static const String enterAmount = '/enter-amount';
  static const String confirmDeposit = '/confirm-deposit';
  static const String successAnimation = '/success-animation';
  static const String errorCancel = '/error-cancel';

  // ─── Виклики ────────────────────────────────────────────────────────────
  static const String challenges = '/challenges';
  static const String challengeComplete = '/challenge-complete';

  // ─── Автоплатежі ────────────────────────────────────────────────────────
  static const String autoPayments = '/auto-payments';
  static const String setupAutopay = '/setup-autopay';

  // ─── Аналітика ──────────────────────────────────────────────────────────
  static const String stats = '/stats';
  static const String chart = '/chart';
  static const String history = '/history';
  static const String forecast = '/forecast';
  static const String comparison = '/comparison';
  static const String activity = '/activity';

  // ─── Гейміфікація ──────────────────────────────────────────────────────
  static const String level = '/level';
  static const String levelProgress = '/level-progress';
  static const String badges = '/badges';
  static const String achievements = '/achievements';
  static const String unlocks = '/unlocks';
  static const String reward = '/reward';
  static const String garden = '/garden';

  // ─── Соціальна мережа ───────────────────────────────────────────────────
  static const String share = '/share';
  static const String motivation = '/motivation';
  static const String historyAchievements = '/history-achievements';
  static const String resultPreview = '/result-preview';

  // ─── Налаштування ───────────────────────────────────────────────────────
  static const String profile = '/profile';
  static const String changeTheme = '/change-theme';
  static const String notifications = '/notifications';
  static const String security = '/security';
  static const String backup = '/backup';
  static const String subscriptionScanner = '/subscription-scanner';

  // ─── Фінальні екрани ────────────────────────────────────────────────────
  static const String cinematic = '/cinematic';
  static const String journey = '/journey';
  static const String newGoal = '/new-goal';
  static const String goalReached = '/goal-reached';

  // ─── Помилка ────────────────────────────────────────────────────────────
  static const String notFound = '/not-found';

  // ─── Збірки списків для перевірки ──────────────────────────────────────

  /// Усі маршрути онбордингу.
  static const List<String> onboardingRoutes = [
    welcome,
    concept,
    chooseGoal,
    setGoal,
    firstDeposit,
  ];

  /// Усі маршрути, що вимагають пройденого онбордингу.
  static const List<String> authRoutes = [
    dashboard,
    goalDetail,
    almostThere,
    subgoals,
    inactive,
    breakdown,
    enterAmount,
    confirmDeposit,
    successAnimation,
    errorCancel,
    challenges,
    challengeComplete,
    autoPayments,
    setupAutopay,
    stats,
    chart,
    history,
    forecast,
    comparison,
    activity,
    level,
    levelProgress,
    badges,
    achievements,
    unlocks,
    reward,
    garden,
    share,
    motivation,
    historyAchievements,
    resultPreview,
    profile,
    changeTheme,
    notifications,
    security,
    backup,
    subscriptionScanner,
    cinematic,
    journey,
    newGoal,
    goalReached,
  ];

  /// Перевіряє, чи є маршрут частиною онбордингу.
  static bool isOnboardingRoute(String location) {
    return onboardingRoutes.any((r) => location.startsWith(r));
  }

  /// Перевіряє, чи маршрут вимагає автентифікації (пройденого онбордингу).
  static bool isAuthRoute(String location) {
    return authRoutes.any((r) => location.startsWith(r));
  }

  /// Перевіряє, чи є маршрут частиною вкладок нижньої навігації.
  static bool isTabRoute(String location) {
    return location == dashboard ||
        location == stats ||
        location == challenges ||
        location == profile;
  }
}

// ─── Перехід на вкладки ─────────────────────────────────────────────────────

/// Індекси вкладок нижньої навігації.
class TabIndex {
  TabIndex._();

  /// Головна (панель приладів)
  static const int home = 0;

  /// Аналітика
  static const int analytics = 1;

  /// Виклики
  static const int challenges = 2;

  /// Профіль
  static const int profile = 3;
}

// ─── Історія маршрутів ──────────────────────────────────────────────────────

/// Запис про відвіданий маршрут.
class RouteHistoryEntry {
  /// Шлях маршруту.
  final String path;

  /// Час відвідування.
  final DateTime visitedAt;

  /// Назва екрана (для відображення).
  final String screenName;

  const RouteHistoryEntry({
    required this.path,
    required this.visitedAt,
    required this.screenName,
  });
}

/// Провайдер для управління історією маршрутів.
final routeHistoryProvider =
    StateNotifierProvider<RouteHistoryNotifier, List<RouteHistoryEntry>>(
  (ref) => RouteHistoryNotifier(),
);

/// Нотифікатор для управління історією відвіданих маршрутів.
class RouteHistoryNotifier extends StateNotifier<List<RouteHistoryEntry>> {
  RouteHistoryNotifier() : super(const []);

  /// Додає запис про відвіданий маршрут.
  void push(String path, {String screenName = ''}) {
    final entry = RouteHistoryEntry(
      path: path,
      visitedAt: DateTime.now(),
      screenName: screenName.isNotEmpty ? screenName : _extractScreenName(path),
    );

    // Обмежуємо історію до 50 записів
    final updated = [entry, ...state];
    if (updated.length > 50) {
      state = updated.sublist(0, 50);
    } else {
      state = updated;
    }
  }

  /// Видаляє всі записи історії.
  void clear() {
    state = const [];
  }

  /// Повертає останній відвіданий маршрут (не включаючи поточний).
  String? get previousRoute {
    if (state.length < 2) return null;
    return state[1].path;
  }

  /// Повертає кількість унікальних відвіданих маршрутів.
  int get uniqueRouteCount {
    return state.map((e) => e.path).toSet().length;
  }

  /// Витягує назву екрана з шляху.
  String _extractScreenName(String path) {
    // Прибираємо перший '/'
    final name = path.replaceFirst('/', '');
    // Замінюємо дефіси на пробіли та робимо першу літеру великою
    if (name.isEmpty) return 'Головна';
    final words = name.split('-');
    return words.map((w) {
      if (w.isEmpty) return '';
      return w[0].toUpperCase() + w.substring(1);
    }).join(' ');
  }
}

// ─── Нотифікатор вкладки ────────────────────────────────────────────────────

/// Провайдер, що відстежує поточну активну вкладку.
final currentTabProvider = StateProvider<int>((ref) => TabIndex.home);

// ─── Кастомні переходи ──────────────────────────────────────────────────────

/// Плавне зникнення.
CustomTransitionPage<void> _fadeInPage({
  required Widget child,
  required GoRouterState state,
}) {
  return CustomTransitionPage(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 300),
    reverseTransitionDuration: const Duration(milliseconds: 200),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
        child: child,
      );
    },
  );
}

/// Зсув знизу вгору (для модальних екранів та вкладок).
CustomTransitionPage<void> _slideUpPage({
  required Widget child,
  required GoRouterState state,
}) {
  return CustomTransitionPage(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 350),
    reverseTransitionDuration: const Duration(milliseconds: 250),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final tween = Tween(begin: const Offset(0, 0.08), end: Offset.zero)
          .chain(CurveTween(curve: Curves.easeOutCubic));
      return SlideTransition(
        position: animation.drive(tween),
        child: FadeTransition(
          opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
          child: child,
        ),
      );
    },
  );
}

/// Зсув справа наліво (для push-переходів).
CustomTransitionPage<void> _slideRightPage({
  required Widget child,
  required GoRouterState state,
}) {
  return CustomTransitionPage(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 300),
    reverseTransitionDuration: const Duration(milliseconds: 250),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final tween = Tween(begin: const Offset(0.05, 0), end: Offset.zero)
          .chain(CurveTween(curve: Curves.easeOutCubic));
      return SlideTransition(
        position: animation.drive(tween),
        child: FadeTransition(
          opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
          child: child,
        ),
      );
    },
  );
}

/// Масштабування від центру (для відкриття деталей).
CustomTransitionPage<void> _zoomInPage({
  required Widget child,
  required GoRouterState state,
}) {
  return CustomTransitionPage(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 300),
    reverseTransitionDuration: const Duration(milliseconds: 200),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final scale = Tween(begin: 0.92, end: 1.0)
          .chain(CurveTween(curve: Curves.easeOutCubic));
      return ScaleTransition(
        scale: animation.drive(scale),
        child: FadeTransition(
          opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
          child: child,
        ),
      );
    },
  );
}

/// Зсув зліва направо (для кнопки «Назад»).
CustomTransitionPage<void> _slideLeftPage({
  required Widget child,
  required GoRouterState state,
}) {
  return CustomTransitionPage(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 300),
    reverseTransitionDuration: const Duration(milliseconds: 250),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final tween = Tween(begin: const Offset(-0.05, 0), end: Offset.zero)
          .chain(CurveTween(curve: Curves.easeOutCubic));
      return SlideTransition(
        position: animation.drive(tween),
        child: FadeTransition(
          opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
          child: child,
        ),
      );
    },
  );
}

/// Плавне розчинення з масштабуванням (для модальних діалогів).
CustomTransitionPage<void> _fadeScalePage({
  required Widget child,
  required GoRouterState state,
}) {
  return CustomTransitionPage(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 250),
    reverseTransitionDuration: const Duration(milliseconds: 200),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final scale = Tween(begin: 0.95, end: 1.0)
          .chain(CurveTween(curve: Curves.easeOutCubic));
      return ScaleTransition(
        scale: animation.drive(scale),
        child: FadeTransition(
          opacity: CurvedAnimation(parent: animation, curve: Curves.easeInOut),
          child: child,
        ),
      );
    },
  );
}

// ─── Екран помилки ──────────────────────────────────────────────────────────

/// Екран 404 — маршрут не знайдено.
class NotFoundScreen extends StatelessWidget {
  const NotFoundScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Сторінку не знайдено')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.sentiment_dissatisfied_rounded,
                size: 64,
                color: Colors.grey,
              ),
              const SizedBox(height: 16),
              const Text(
                'Ой! Цю сторінку не знайдено',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'Перевірте посилання або поверніться на головну',
                style: TextStyle(fontSize: 14, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => context.go(AppRoutes.dashboard),
                child: const Text('На головну'),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => context.go(AppRoutes.welcome),
                child: const Text('На екран привітання'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Екран помилки для внутрішніх помилок маршрутизації.
class RouteErrorScreen extends StatelessWidget {
  /// Повідомлення про помилку.
  final String errorMessage;

  /// Шлях, який спричинив помилку.
  final String errorPath;

  const RouteErrorScreen({
    super.key,
    required this.errorMessage,
    required this.errorPath,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Помилка маршруту')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.redAccent,
              ),
              const SizedBox(height: 16),
              const Text(
                'Сталася помилка навігації',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                errorMessage,
                style: const TextStyle(fontSize: 14, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                'Шлях: $errorPath',
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                  fontFamily: 'monospace',
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => context.go(AppRoutes.dashboard),
                child: const Text('На головну'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Екран обробки глибоких посилань (заглушка).
class DeepLinkHandlerScreen extends StatelessWidget {
  /// URI глибокого посилання.
  final Uri deepLinkUri;

  const DeepLinkHandlerScreen({
    super.key,
    required this.deepLinkUri,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Обробка посилання')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.link, size: 48),
            const SizedBox(height: 16),
            Text(
              'Обробка посилання...',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 8),
            Text(
              deepLinkUri.toString(),
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Обгортка з нижньою навігацією ──────────────────────────────────────────

/// Шаблон екрана з нижньою навігаційною панеллю.
class ShellWithNav extends StatelessWidget {
  const ShellWithNav({
    super.key,
    required this.child,
  });

  /// Дочірній вміст, що рендериться всередині навігаційної оболонки.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: Consumer(
        builder: (context, ref, _) {
          final currentIndex = ref.watch(currentTabProvider);

          // Визначаємо, чи використовуємо світлу тему
          final isLight = Theme.of(context).brightness == Brightness.light;

          return AppBottomNav(
            currentIndex: currentIndex,
            isLightTheme: isLight,
            onTabChanged: (index) {
              ref.read(currentTabProvider.notifier).state = index;
              switch (index) {
                case TabIndex.home:
                  context.go(AppRoutes.dashboard);
                case TabIndex.analytics:
                  context.go(AppRoutes.stats);
                case TabIndex.challenges:
                  context.go(AppRoutes.challenges);
                case TabIndex.profile:
                  context.go(AppRoutes.profile);
              }
            },
          );
        },
      ),
    );
  }
}

// ─── Допоміжні класи для маршрутизації ──────────────────────────────────────

/// Категорія маршруту для групування.
enum RouteCategory {
  /// Екрани онбордингу.
  onboarding,

  /// Основні екрани (вкладки).
  main,

  /// Екрани детальної інформації.
  detail,

  /// Екрани гейміфікації.
  gamification,

  /// Екрани соціальної мережі.
  social,

  /// Екрани налаштувань.
  settings,

  /// Фінальні екрани.
  final_,

  /// Екрани помилок.
  error,
}

/// Повертає категорію маршруту за шляхом.
RouteCategory getRouteCategory(String path) {
  if (AppRoutes.isOnboardingRoute(path)) return RouteCategory.onboarding;
  if (path == AppRoutes.dashboard ||
      path == AppRoutes.stats ||
      path == AppRoutes.challenges ||
      path == AppRoutes.profile) {
    return RouteCategory.main;
  }
  if (path.startsWith(AppRoutes.enterAmount) ||
      path.startsWith(AppRoutes.confirmDeposit) ||
      path.startsWith(AppRoutes.goalDetail) ||
      path.startsWith(AppRoutes.almostThere) ||
      path.startsWith(AppRoutes.subgoals) ||
      path.startsWith(AppRoutes.breakdown)) {
    return RouteCategory.detail;
  }
  if (path.startsWith(AppRoutes.level) ||
      path.startsWith(AppRoutes.badges) ||
      path.startsWith(AppRoutes.achievements) ||
      path.startsWith(AppRoutes.unlocks) ||
      path.startsWith(AppRoutes.reward)) {
    return RouteCategory.gamification;
  }
  if (path.startsWith(AppRoutes.share) ||
      path.startsWith(AppRoutes.motivation) ||
      path.startsWith(AppRoutes.historyAchievements) ||
      path.startsWith(AppRoutes.resultPreview)) {
    return RouteCategory.social;
  }
  if (path.startsWith(AppRoutes.changeTheme) ||
      path.startsWith(AppRoutes.notifications) ||
      path.startsWith(AppRoutes.security) ||
      path.startsWith(AppRoutes.backup)) {
    return RouteCategory.settings;
  }
  if (path.startsWith(AppRoutes.cinematic) ||
      path.startsWith(AppRoutes.journey) ||
      path.startsWith(AppRoutes.newGoal) ||
      path.startsWith(AppRoutes.goalReached)) {
    return RouteCategory.final_;
  }
  return RouteCategory.error;
}

/// Повертає назву категорії маршруту українською.
String getRouteCategoryName(RouteCategory category) {
  switch (category) {
    case RouteCategory.onboarding:
      return 'Онбординг';
    case RouteCategory.main:
      return 'Основні';
    case RouteCategory.detail:
      return 'Деталі';
    case RouteCategory.gamification:
      return 'Гейміфікація';
    case RouteCategory.social:
      return 'Спільнота';
    case RouteCategory.settings:
      return 'Налаштування';
    case RouteCategory.final_:
      return 'Результат';
    case RouteCategory.error:
      return 'Помилка';
  }
}

// ─── Парсинг глибоких посилань ──────────────────────────────────────────────

/// Результат парсингу глибокого посилання.
class DeepLinkParseResult {
  /// Цільовий маршрут.
  final String targetRoute;

  /// Параметри маршруту.
  final Map<String, String> queryParams;

  /// Чи парсинг успішний.
  final bool isValid;

  /// Повідомлення про помилку (якщо є).
  final String? errorMessage;

  const DeepLinkParseResult({
    required this.targetRoute,
    this.queryParams = const {},
    this.isValid = true,
    this.errorMessage,
  });
}

/// Парсить глибоке посилання та повертає цільовий маршрут.
///
/// Підтримує формати:
/// - nexora://dashboard
/// - nexora://challenge?id=123
/// - https://nexora.app/goal-detail
DeepLinkParseResult parseDeepLink(Uri uri) {
  try {
    final path = uri.path;

    // Перевіряємо відомі маршрути
    if (path.isEmpty || path == '/') {
      return const DeepLinkParseResult(targetRoute: AppRoutes.dashboard);
    }

    // Мапінг шляхів веб-URL на внутрішні маршрути
    final routeMap = <String, String>{
      '/dashboard': AppRoutes.dashboard,
      '/stats': AppRoutes.stats,
      '/challenges': AppRoutes.challenges,
      '/profile': AppRoutes.profile,
      '/goal-detail': AppRoutes.goalDetail,
      '/level': AppRoutes.level,
      '/badges': AppRoutes.badges,
      '/achievements': AppRoutes.achievements,
      '/share': AppRoutes.share,
    };

    final targetRoute = routeMap[path];
    if (targetRoute != null) {
      return DeepLinkParseResult(
        targetRoute: targetRoute,
        queryParams: uri.queryParameters,
      );
    }

    // Невідомий шлях — перенаправляємо на головну
    return const DeepLinkParseResult(
      targetRoute: AppRoutes.dashboard,
      isValid: false,
      errorMessage: 'Невідоме глибоке посилання',
    );
  } catch (e) {
    return DeepLinkParseResult(
      targetRoute: AppRoutes.dashboard,
      isValid: false,
      errorMessage: 'Помилка парсингу: $e',
    );
  }
}

// ─── Допоміжні функції для тестування маршрутів ─────────────────────────────

/// Генерує тестові дані для перевірки маршрутизації.
///
/// Повертає список тестових випадків: шлях → очікувана вкладка.
List<Map<String, dynamic>> generateRouteTestCases() {
  return [
    {'path': AppRoutes.dashboard, 'expectedTab': TabIndex.home},
    {'path': AppRoutes.stats, 'expectedTab': TabIndex.analytics},
    {'path': AppRoutes.chart, 'expectedTab': TabIndex.analytics},
    {'path': AppRoutes.history, 'expectedTab': TabIndex.analytics},
    {'path': AppRoutes.forecast, 'expectedTab': TabIndex.analytics},
    {'path': AppRoutes.challenges, 'expectedTab': TabIndex.challenges},
    {'path': AppRoutes.profile, 'expectedTab': TabIndex.profile},
    {'path': AppRoutes.changeTheme, 'expectedTab': TabIndex.profile},
    {'path': AppRoutes.notifications, 'expectedTab': TabIndex.profile},
    {'path': AppRoutes.security, 'expectedTab': TabIndex.profile},
    {'path': AppRoutes.backup, 'expectedTab': TabIndex.profile},
    {'path': AppRoutes.goalDetail, 'expectedTab': TabIndex.home},
    {'path': AppRoutes.enterAmount, 'expectedTab': TabIndex.home},
    {'path': AppRoutes.level, 'expectedTab': TabIndex.home},
    {'path': AppRoutes.share, 'expectedTab': TabIndex.home},
  ];
}

/// Перевіряє, чи всі маршрути з AppRoutes мають відповідні GoRoute.
///
/// У майбутньому: для автоматизованого тестування.
bool validateAllRoutesRegistered(List<String> registeredPaths) {
  final allRoutes = [
    ...AppRoutes.onboardingRoutes,
    ...AppRoutes.authRoutes,
  ];

  for (final route in allRoutes) {
    if (!registeredPaths.any((p) => p.startsWith(route))) {
      return false;
    }
  }
  return true;
}

// ─── Спостерігач маршрутів ──────────────────────────────────────────────────

/// Спостерігач для відстеження переходів між маршрутами.
///
/// Логує переходи, оновлює історію, відправляє аналітичні події.
class NexoraRouteObserver extends RouteObserver<ModalRoute<dynamic>> {
  /// Зворотний виклик при зміні маршруту.
  final void Function(String route, String action)? onRouteChanged;

  NexoraRouteObserver({this.onRouteChanged});

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    _logRouteChange(route, previousRoute, 'push');
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    _logRouteChange(previousRoute, route, 'pop');
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    _logRouteChange(newRoute, oldRoute, 'replace');
  }

  void _logRouteChange(Route<dynamic>? newRoute, Route<dynamic>? oldRoute, String action) {
    final newName = newRoute?.settings.name ?? 'unknown';
    final oldName = oldRoute?.settings.name ?? 'none';
    debugPrint('🧭 NexoraRoute: $action $oldName → $newName');
    onRouteChanged?.call(newName, action);
  }
}

/// Глобальний екземпляр спостерігача маршрутів.
final nexoraRouteObserver = NexoraRouteObserver(
  onRouteChanged: (route, action) {
    // У майбутньому: відправка аналітичної події
    // AnalyticsService.instance.logRouteChange(route, action);
  },
);

// ─── Головний роутер ────────────────────────────────────────────────────────

/// Головний роутер додатку Nexora.
///
/// Організація маршрутів:
/// - Кореневі: вінбординг та привітання
/// - Shell: основні вкладки з нижньою навігацією
/// - Повні екрани: детальні екрани без нижньої навігації
/// - Помилка: обробка неіснуючих маршрутів
/// - Deep links: підтримка зовнішніх посилань
final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoutes.welcome,
    debugLogDiagnostics: true,
    errorBuilder: (context, state) => const NotFoundScreen(),
    observers: [nexoraRouteObserver],

    // ─── Перенаправлення ──────────────────────────────────────────────────
    redirect: (context, state) {
      final location = state.matchedLocation;

      final isOnboarding = AppRoutes.isOnboardingRoute(location);
      final isAuthRoute = AppRoutes.isAuthRoute(location);

      // Обробка глибоких посилань
      final deepLink = state.uri;
      if (deepLink.hasScheme && deepLink.scheme != 'http' && deepLink.scheme != 'https') {
        final parsed = parseDeepLink(deepLink);
        if (parsed.isValid) {
          return parsed.targetRoute;
        }
      }

      // Обробка веб-глибоких посилаань (query parameters)
      if (location.startsWith('/deep-link')) {
        final deepLinkParam = state.uri.queryParameters['link'];
        if (deepLinkParam != null) {
          final parsed = parseDeepLink(Uri.parse(deepLinkParam));
          if (parsed.isValid) {
            return parsed.targetRoute;
          }
        }
        return AppRoutes.dashboard;
      }

      // У майбутньому: перевірка чи пройдено онбординг
      // Зараз дозволяємо вільний перехід
      // if (!isOnboarded && isAuthRoute) return AppRoutes.welcome;
      // if (isOnboarded && isOnboarding) return AppRoutes.dashboard;

      // Захист від дублювання слешів
      if (location.contains('//')) {
        return location.replaceAll(RegExp(r'/+'), '/');
      }

      return null;
    },

    // ─── Перехід між вкладками ───────────────────────────────────────────
    onNavigate: (context, state) {
      final location = state.matchedLocation;
      int newTab = TabIndex.home;

      // Визначаємо вкладку на основі шляху
      if (location.startsWith(AppRoutes.stats) ||
          location.startsWith(AppRoutes.chart) ||
          location.startsWith(AppRoutes.history) ||
          location.startsWith(AppRoutes.forecast) ||
          location.startsWith(AppRoutes.comparison) ||
          location.startsWith(AppRoutes.activity)) {
        newTab = TabIndex.analytics;
      } else if (location.startsWith(AppRoutes.challenges) ||
          location.startsWith(AppRoutes.challengeComplete)) {
        newTab = TabIndex.challenges;
      } else if (location.startsWith(AppRoutes.profile) ||
          location.startsWith(AppRoutes.changeTheme) ||
          location.startsWith(AppRoutes.notifications) ||
          location.startsWith(AppRoutes.security) ||
          location.startsWith(AppRoutes.backup)) {
        newTab = TabIndex.profile;
      }

      ref.read(currentTabProvider.notifier).state = newTab;

      // Додаємо запис до історії маршрутів
      ref.read(routeHistoryProvider.notifier).push(location);
    },

    routes: [
      // ─── ОНБОРДИНГ ─────────────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.welcome,
        page: (state) => _fadeInPage(
          state: state,
          child: const WelcomeScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.concept,
        page: (state) => _slideRightPage(
          state: state,
          child: const ConceptScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.chooseGoal,
        page: (state) => _slideRightPage(
          state: state,
          child: const ChooseGoalScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.setGoal,
        page: (state) => _slideRightPage(
          state: state,
          child: const SetGoalScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.firstDeposit,
        page: (state) => _slideUpPage(
          state: state,
          child: const FirstDepositScreen(),
        ),
      ),

      // ─── ОСНОВНІ ВКЛАДКИ (Shell з навігацією) ────────────────────────
      ShellRoute(
        builder: (context, state, child) => ShellWithNav(child: child),
        routes: [
          // -- Головна --
          GoRoute(
            path: AppRoutes.dashboard,
            page: (state) => _fadeInPage(
              state: state,
              child: const DashboardScreen(),
            ),
          ),

          // -- Аналітика --
          GoRoute(
            path: AppRoutes.stats,
            page: (state) => _fadeInPage(
              state: state,
              child: const OverallStatsScreen(),
            ),
          ),

          // -- Виклики --
          GoRoute(
            path: AppRoutes.challenges,
            page: (state) => _fadeInPage(
              state: state,
              child: const ChallengesScreen(),
            ),
          ),

          // -- Профіль --
          GoRoute(
            path: AppRoutes.profile,
            page: (state) => _fadeInPage(
              state: state,
              child: const ProfileScreen(),
            ),
          ),
        ],
      ),

      // ─── ГОЛОВНА — ДОДАТКОВІ ЕКРАНИ ───────────────────────────────────
      GoRoute(
        path: AppRoutes.goalDetail,
        page: (state) => _slideRightPage(
          state: state,
          child: const GoalDetailScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.almostThere,
        page: (state) => _zoomInPage(
          state: state,
          child: const AlmostThereScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.subgoals,
        page: (state) => _slideRightPage(
          state: state,
          child: const SubgoalsScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.inactive,
        page: (state) => _fadeInPage(
          state: state,
          child: const InactiveScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.breakdown,
        page: (state) => _slideRightPage(
          state: state,
          child: const BreakdownScreen(),
        ),
      ),

      // ─── ВНЕСКИ ────────────────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.enterAmount,
        page: (state) => _slideUpPage(
          state: state,
          child: const EnterAmountScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.confirmDeposit,
        page: (state) => _slideUpPage(
          state: state,
          child: const ConfirmDepositScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.successAnimation,
        page: (state) => _zoomInPage(
          state: state,
          child: const SuccessAnimationScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.errorCancel,
        page: (state) => _fadeInPage(
          state: state,
          child: const ErrorCancelScreen(),
        ),
      ),

      // ─── ВИКЛИКИ — ДОДАТКОВІ ─────────────────────────────────────────
      GoRoute(
        path: AppRoutes.challengeComplete,
        page: (state) => _zoomInPage(
          state: state,
          child: const ChallengeCompleteScreen(),
        ),
      ),

      // ─── АВТОПЛАТЕЖІ ───────────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.autoPayments,
        page: (state) => _slideRightPage(
          state: state,
          child: const AutoPaymentsScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.setupAutopay,
        page: (state) => _slideUpPage(
          state: state,
          child: const SetupAutopayScreen(),
        ),
      ),

      // ─── АНАЛІТИКА — ДОДАТКОВІ ───────────────────────────────────────
      GoRoute(
        path: AppRoutes.chart,
        page: (state) => _slideRightPage(
          state: state,
          child: const AccumulationChartScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.history,
        page: (state) => _slideRightPage(
          state: state,
          child: const TransactionHistoryScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.forecast,
        page: (state) => _slideRightPage(
          state: state,
          child: const ForecastScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.comparison,
        page: (state) => _slideRightPage(
          state: state,
          child: const PeriodComparisonScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.activity,
        page: (state) => _slideRightPage(
          state: state,
          child: const ActivityDetailScreen(),
        ),
      ),

      // ─── ГЕЙМІФІКАЦІЯ ──────────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.level,
        page: (state) => _slideUpPage(
          state: state,
          child: const UserLevelScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.levelProgress,
        page: (state) => _slideUpPage(
          state: state,
          child: const LevelProgressScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.badges,
        page: (state) => _slideUpPage(
          state: state,
          child: const BadgesScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.achievements,
        page: (state) => _slideRightPage(
          state: state,
          child: const AchievementsScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.unlocks,
        page: (state) => _slideRightPage(
          state: state,
          child: const UnlocksShopScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.reward,
        page: (state) => _zoomInPage(
          state: state,
          child: const RewardScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.garden,
        page: (state) => _slideUpPage(
          state: state,
          child: const GardenScreen(),
        ),
      ),

      // ─── СОЦІАЛЬНА МЕРЕЖА ─────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.share,
        page: (state) => _slideUpPage(
          state: state,
          child: const ShareProgressScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.motivation,
        page: (state) => _slideRightPage(
          state: state,
          child: const MotivationFeedScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.historyAchievements,
        page: (state) => _slideRightPage(
          state: state,
          child: const AchievementHistoryScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.resultPreview,
        page: (state) => _zoomInPage(
          state: state,
          child: const ResultPreviewScreen(),
        ),
      ),

      // ─── НАЛАШТУВАННЯ — ДОДАТКОВІ ─────────────────────────────────────
      GoRoute(
        path: AppRoutes.changeTheme,
        page: (state) => _slideRightPage(
          state: state,
          child: const ChangeThemeScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.notifications,
        page: (state) => _slideRightPage(
          state: state,
          child: const NotificationsScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.security,
        page: (state) => _slideRightPage(
          state: state,
          child: const SecurityScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.backup,
        page: (state) => _slideRightPage(
          state: state,
          child: const BackupScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.subscriptionScanner,
        page: (state) => _slideRightPage(
          state: state,
          child: const SubscriptionScannerScreen(),
        ),
      ),

      // ─── ФІНАЛЬНІ ЕКРАНИ ───────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.cinematic,
        page: (state) => _fadeInPage(
          state: state,
          child: const CinematicScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.journey,
        page: (state) => _slideUpPage(
          state: state,
          child: const JourneySummaryScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.goalReached,
        page: (state) => _zoomInPage(
          state: state,
          child: const GoalReachedScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.newGoal,
        page: (state) => _slideUpPage(
          state: state,
          child: const NewGoalScreen(),
        ),
      ),

      // ─── ГЛИБОКІ ПОСИЛАННЯ ────────────────────────────────────────────
      GoRoute(
        path: '/deep-link',
        redirect: (context, state) {
          final link = state.uri.queryParameters['link'];
          if (link != null) {
            final parsed = parseDeepLink(Uri.parse(link));
            return parsed.targetRoute;
          }
          return AppRoutes.dashboard;
        },
      ),
    ],
  );
});
