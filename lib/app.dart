import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/constants/app_enums.dart' hide ThemeMode;
import 'core/theme/theme_provider.dart';
import 'router/app_router.dart';

/// Конвертує рядок режиму яскравості у Flutter [ThemeMode].
ThemeMode _parseBrightness(String name) {
  switch (name) {
    case 'dark':
      return ThemeMode.dark;
    case 'light':
      return ThemeMode.light;
    case 'system':
      return ThemeMode.system;
    default:
      return ThemeMode.dark;
  }
}

/// Провайдер для керування станом ініціалізації додатку.
final initializationProvider = StateNotifierProvider<InitializationNotifier, bool>(
  (ref) => InitializationNotifier(),
);

/// Нотифікатор, що керує екраном завантаження під час ініціалізації.
class InitializationNotifier extends StateNotifier<bool> {
  InitializationNotifier() : super(true);

  /// Позначає, що ініціалізацію завершено.
  void complete() {
    if (mounted) state = false;
  }

  /// Повертає поточний статус ініціалізації.
  bool get isComplete => !state;
}

/// Провайдер для керування глобальним станом overlay (діалоги, snackbars).
final overlayStateProvider =
    StateNotifierProvider<OverlayNotifier, OverlayStateData>(
  (ref) => OverlayNotifier(),
);

/// Дані про глобальний overlay стан.
class OverlayStateData {
  /// Чи показується глобальний індикатор завантаження.
  final bool isGlobalLoading;

  /// Повідомлення глобального індикатора завантаження.
  final String? loadingMessage;

  /// Чи активний глобальний помилковий стан.
  final bool hasError;

  /// Повідомлення глобальної помилки.
  final String? errorMessage;

  /// Кількість активних модальних діалогів.
  final int activeDialogCount;

  /// Кількість активних overlay шарів.
  final int activeOverlayCount;

  const OverlayStateData({
    this.isGlobalLoading = false,
    this.loadingMessage,
    this.hasError = false,
    this.errorMessage,
    this.activeDialogCount = 0,
    this.activeOverlayCount = 0,
  });

  OverlayStateData copyWith({
    bool? isGlobalLoading,
    String? loadingMessage,
    bool clearLoadingMessage = false,
    bool? hasError,
    String? errorMessage,
    bool clearError = false,
    int? activeDialogCount,
    int? activeOverlayCount,
  }) {
    return OverlayStateData(
      isGlobalLoading: isGlobalLoading ?? this.isGlobalLoading,
      loadingMessage: clearLoadingMessage ? null : (loadingMessage ?? this.loadingMessage),
      hasError: hasError ?? this.hasError,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      activeDialogCount: activeDialogCount ?? this.activeDialogCount,
      activeOverlayCount: activeOverlayCount ?? this.activeOverlayCount,
    );
  }
}

/// Нотифікатор для керування глобальними overlay станами.
class OverlayNotifier extends StateNotifier<OverlayStateData> {
  OverlayNotifier() : super(const OverlayStateData());

  /// Показує глобальний індикатор завантаження.
  void showGlobalLoading([String? message]) {
    state = state.copyWith(
      isGlobalLoading: true,
      loadingMessage: message,
    );
  }

  /// Ховає глобальний індикатор завантаження.
  void hideGlobalLoading() {
    state = state.copyWith(
      isGlobalLoading: false,
      clearLoadingMessage: true,
    );
  }

  /// Показує глобальну помилку.
  void showError(String message) {
    state = state.copyWith(
      hasError: true,
      errorMessage: message,
    );
  }

  /// Ховає глобальну помилку.
  void clearError() {
    state = state.copyWith(
      hasError: false,
      clearError: true,
    );
  }

  /// Збільшує лічильник активних діалогів.
  void incrementDialogCount() {
    state = state.copyWith(
      activeDialogCount: state.activeDialogCount + 1,
    );
  }

  /// Зменшує лічильник активних діалогів.
  void decrementDialogCount() {
    state = state.copyWith(
      activeDialogCount: (state.activeDialogCount - 1).clamp(0, 999),
    );
  }

  /// Збільшує лічильник overlay шарів.
  void incrementOverlayCount() {
    state = state.copyWith(
      activeOverlayCount: state.activeOverlayCount + 1,
    );
  }

  /// Зменшує лічильник overlay шарів.
  void decrementOverlayCount() {
    state = state.copyWith(
      activeOverlayCount: (state.activeOverlayCount - 1).clamp(0, 999),
    );
  }
}

/// Провайдер для керування життєвим циклом додатку.
final appLifecycleProvider =
    StateNotifierProvider<AppLifecycleNotifier, AppLifecycleState>(
  (ref) => AppLifecycleNotifier(),
);

/// Нотифікатор для відстеження стану життєвого циклу додатку.
class AppLifecycleNotifier extends StateNotifier<AppLifecycleState> {
  AppLifecycleNotifier() : super(AppLifecycleState.resumed);

  /// Оновлює стан життєвого циклу.
  void updateState(AppLifecycleState newState) {
    state = newState;
  }

  /// Чи додаток активний (на передньому плані).
  bool get isResumed => state == AppLifecycleState.resumed;

  /// Чи додаток на фоні.
  bool get isInBackground =>
      state == AppLifecycleState.paused ||
      state == AppLifecycleState.hidden;

  /// Чи додаток неактивний (згортається).
  bool get isInactive => state == AppLifecycleState.inactive;

  /// Чи додаток завершується.
  bool get isDetached => state == AppLifecycleState.detached;

  /// Час останнього переходу у фон.
  DateTime? _pausedAt;

  /// Встановлює час переходу у фон.
  void setPausedAt(DateTime time) {
    _pausedAt = time;
  }

  /// Повертає тривалість останньої сесії на фоні.
  Duration? get backgroundDuration {
    if (_pausedAt == null) return null;
    return DateTime.now().difference(_pausedAt!);
  }
}

/// Провайдер для керування глибокими посиланнями.
final deepLinkProvider = StateProvider<Uri?>((ref) => null);

/// Головний віджет додатку Nexora.
///
/// Конфігурує MaterialApp.router із:
/// - Адаптивною темою (темна / світла / системна)
/// - Перехресним розчиненням при зміні теми
/// - Екраном завантаження під час ініціалізації
/// - Закриттям клавіатури при натисканні поза полем вводу
/// - Спостерігачем маршрутизації
/// - Глобальними обробниками помилок
/// - Моніторингом життєвого циклу
/// - Керуванням overlay
/// - Підтримкою глибоких посилань
/// - Налаштуваннями доступності
class NexoraApp extends ConsumerStatefulWidget {
  const NexoraApp({super.key});

  @override
  ConsumerState<NexoraApp> createState() => _NexoraAppState();
}

class _NexoraAppState extends ConsumerState<NexoraApp>
    with WidgetsBindingObserver {
  final RouteObserver<ModalRoute<dynamic>> _routeObserver =
      RouteObserver<ModalRoute<dynamic>>();

  /// Час останнього переходу у стан resumed.
  DateTime? _lastResumedAt;

  /// Таймер для відкладеного відновлення після виходу з фону.
  Timer? _resumeTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // Завантаження збережених налаштувань теми
    ref.read(themeProvider.notifier).loadSavedPreferences();

    // Імітація завершення ініціалізації (замінити реальними перевірками)
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        ref.read(initializationProvider.notifier).complete();
      }
    });

    // Встановлення глобального обробника клавіатури
    _setupKeyboardHandler();

    // Встановлення глобального обробника помилок
    _setupGlobalErrorHandler();

    debugPrint('🟢 NexoraApp: initState завершено');
  }

  @override
  void dispose() {
    _resumeTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
    debugPrint('🔴 NexoraApp: dispose завершено');
  }

  @override
  void didChangePlatformBrightness() {
    super.didChangePlatformBrightness();
    // Якщо режим — системний, адаптуємо тему
    final brightness = ref.read(themeProvider);
    if (brightness.brightness.name == 'system') {
      final platformBrightness = MediaQuery.of(context).platformBrightness;
      ref.read(themeProvider.notifier).getAdaptiveTheme(
            platformBrightness: platformBrightness,
          );
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState lifecycleState) {
    super.didChangeAppLifecycleState(lifecycleState);

    final lifecycleNotifier = ref.read(appLifecycleProvider.notifier);
    lifecycleNotifier.updateState(lifecycleState);

    switch (lifecycleState) {
      case AppLifecycleState.resumed:
        _handleAppResumed();
        break;
      case AppLifecycleState.paused:
        _handleAppPaused();
        break;
      case AppLifecycleState.inactive:
        _handleAppInactive();
        break;
      case AppLifecycleState.detached:
        _handleAppDetached();
        break;
      case AppLifecycleState.hidden:
        _handleAppHidden();
        break;
    }
  }

  /// Обробляє перехід додатку у активний стан (resumed).
  ///
  /// Відновлює дані, перевіряє оновлення, скидає таймери.
  void _handleAppResumed() {
    _lastResumedAt = DateTime.now();
    debugPrint('🟢 NexoraApp: додаток resumed');

    // Скасовуємо відкладене відновлення
    _resumeTimer?.cancel();

    // У майбутньому: перевірка оновлень на сервері
    // У майбутньому: синхронізація даних
    // У майбутньому: оновлення фонового повідомлення
  }

  /// Обробляє перехід додатку у фоновий стан (paused).
  ///
  /// Зберігає стан, зупиняє таймери, фіксує час паузи.
  void _handleAppPaused() {
    debugPrint('🟡 NexoraApp: додаток paused');

    final lifecycleNotifier = ref.read(appLifecycleProvider.notifier);
    lifecycleNotifier.setPausedAt(DateTime.now());

    // У майбутньому: зберегти поточний стан
    // У майбутньому: зупинити таймери
    // У майбутньому: відправити аналітичну подію
  }

  /// Обробляє перехід додатку у неактивний стан.
  ///
  /// Зупиняє анімації, готується до переходу у фон.
  void _handleAppInactive() {
    debugPrint('🟠 NexoraApp: додаток inactive');

    // У майбутньому: призупинити анімації
    // У майбутньому: призупинити відтворення звуку
  }

  /// Обробляє відключення додатку від Flutter Engine.
  ///
  /// Зберігає всі дані, звільняє ресурси.
  void _handleAppDetached() {
    debugPrint('🔴 NexoraApp: додаток detached');

    // У майбутньому: остаточне збереження даних
    // У майбутньому: відправка останніх аналітичних подій
    // У майбутньому: відключення від сервісів
  }

  /// Обробляє прихований стан додатку.
  void _handleAppHidden() {
    debugPrint('⚪ NexoraApp: додаток hidden');
  }

  /// Налаштовує глобальний обробник клавіатури.
  ///
  /// Обробляє спеціальні комбінації клавіш (наприклад, Ctrl+S для збереження).
  void _setupKeyboardHandler() {
    // У майбутньому: HardwareKeyboard.instance.addHandler(...)
    // для обробки глобальних комбінацій клавіш
    debugPrint('⌨️ NexoraApp: обробник клавіатури налаштовано');
  }

  /// Налаштовує глобальний обробник помилок для дочірніх віджетів.
  void _setupGlobalErrorHandler() {
    // У майбутньому: встановлення FlutterError.onError для UI-помилок
    // У майбутньому: налаштування ErrorWidget.builder для кастомних
    // екранів помилок у віджетах
    debugPrint('🛡️ NexoraApp: глобальний обробник помилок налаштовано');
  }

  /// Обробляє глибоке посилання.
  ///
  /// Парсить URI та виконує відповідний перехід.
  void _handleDeepLink(Uri? uri) {
    if (uri == null) return;

    debugPrint('🔗 NexoraApp: глибоке посилання: $uri');
    ref.read(deepLinkProvider.notifier).state = uri;

    // У майбутньому: парсинг шляху та параметрів
    // У майбутньому: навігація до відповідного екрана
  }

  /// Будує віджет інспектора для дебаг-режиму.
  Widget? _buildDebugInspector() {
    // У майбутньому: вивід інформації про стан додатку
    // У майбутньому: кнопка для відкриття панелі дебагу
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final themeState = ref.watch(themeProvider);
    final router = ref.watch(routerProvider);
    final isInitializing = ref.watch(initializationProvider);
    final overlayState = ref.watch(overlayStateProvider);

    return AnimatedSwitcher(
      duration: themeState.transitionDuration,
      switchInCurve: themeState.transitionCurve,
      switchOutCurve: themeState.transitionCurve,
      child: MaterialApp.router(
        key: ValueKey(themeState.goalType),
        title: 'Nexora — Гейміфікований фінансовий трекер',
        debugShowCheckedModeBanner: false,

        // ─── Тема ─────────────────────────────────────────────────────
        theme: themeState.brightness.name == 'light'
            ? _buildLightTheme(themeState)
            : themeState.theme,
        darkTheme: themeState.theme,
        themeMode: _parseBrightness(themeState.brightness.name),

        // ─── Локалізація ──────────────────────────────────────────────
        locale: const Locale('uk', 'UA'),
        supportedLocales: const [
          Locale('uk', 'UA'),
          Locale('en', 'US'),
        ],

        // ─── Маршрутизація ───────────────────────────────────────────
        routerConfig: router,

        // ─── Перехід між екранами ───────────────────────────────────
        builder: (context, child) {
          return _AppBuilderWrapper(
            isInitializing: isInitializing,
            overlayState: overlayState,
            child: child,
          );
        },

        // ─── Налаштування дебагу ────────────────────────────────────
        showPerformanceOverlay: false,
        checkerboardRasterCacheImages: false,
        checkerboardOffscreenLayers: false,
        showSemanticsDebugger: false,

        // ─── Налаштування доступності ────────────────────────────────
        accessibilityFeatures: _getAccessibilityFeatures(context),

        // ─── Колір статус-бару ───────────────────────────────────────
        color: Colors.transparent,

        // ─── Обробка помилок у піддереві ────────────────────────────
        builder: (context, child) {
          ErrorWidget.builder = (details) {
            return _buildErrorWidget(context, details);
          };
          return _AppBuilderWrapper(
            isInitializing: isInitializing,
            overlayState: overlayState,
            child: child,
          );
        },
      ),
    );
  }

  /// Будує світлу тему з урахуванням кастомного акценту.
  ThemeData _buildLightTheme(ThemeState themeState) {
    if (themeState.brightness.name == 'light') {
      // Для світлої теми використовуємо Monitor тему
      final notifier = ref.read(themeProvider.notifier);
      return notifier.getThemeForGoalType(GoalType.monitor);
    }
    return themeState.theme;
  }

  /// Повертає налаштування доступності на основі контексту.
  AccessibilityFeatures _getAccessibilityFeatures(BuildContext context) {
    // У майбутньому: завантажувати збережені налаштування доступності
    return MediaQuery.of(context).accessibilityFeatures;
  }

  /// Будує кастомний віджет помилки для піддерева MaterialApp.
  Widget _buildErrorWidget(BuildContext context, FlutterErrorDetails details) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline,
                size: 48,
                color: Colors.redAccent,
              ),
              const SizedBox(height: 16),
              const Text(
                'Сталася помилка',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                details.exceptionAsString(),
                style: const TextStyle(
                  color: Color(0xFF8B8BA7),
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  // Спробуємо перезавантажити
                  ref.read(initializationProvider.notifier).complete();
                },
                child: const Text('Спробувати знову'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Обгортка для екрану завантаження, overlay та закриття клавіатури.
class _AppBuilderWrapper extends StatelessWidget {
  const _AppBuilderWrapper({
    required this.isInitializing,
    required this.overlayState,
    required this.child,
  });

  /// Чи триває ініціалізація додатку.
  final bool isInitializing;

  /// Поточний стан overlay.
  final OverlayStateData overlayState;

  /// Дочірній вміст додатку.
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    // Екран завантаження під час ініціалізації
    if (isInitializing) {
      return const _LoadingScreen();
    }

    return Stack(
      children: [
        // Головний контент додатку
        child ?? const SizedBox.shrink(),

        // Глобальний індикатор завантаження
        if (overlayState.isGlobalLoading)
          _buildGlobalLoadingOverlay(context),

        // Глобальне повідомлення про помилку
        if (overlayState.hasError && overlayState.errorMessage != null)
          _buildGlobalErrorOverlay(context),

        // Детектор натискань — закриває клавіатуру
        Positioned.fill(
          child: GestureDetector(
            onTap: () {
              final currentFocus = FocusScope.of(context);
              if (!currentFocus.hasPrimaryFocus &&
                  currentFocus.focusedChild != null) {
                FocusManager.instance.primaryFocus?.unfocus();
              }
              // Також приховаємо клавіатуру через SystemChannels
              SystemChannels.textInput.invokeMethod('TextInput.hide');
            },
            // Пропускаємо натискання на інтерактивні елементи
            behavior: HitTestBehavior.translucent,
          ),
        ),
      ],
    );
  }

  /// Будує overlay глобального індикатора завантаження.
  Widget _buildGlobalLoadingOverlay(BuildContext context) {
    return Positioned.fill(
      child: Container(
        color: Colors.black54,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00D4FF)),
              ),
              if (overlayState.loadingMessage != null) ...[
                const SizedBox(height: 16),
                Text(
                  overlayState.loadingMessage!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// Будує overlay глобального повідомлення про помилку.
  Widget _buildGlobalErrorOverlay(BuildContext context) {
    return Positioned(
      bottom: 80,
      left: 16,
      right: 16,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A2E),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.redAccent.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.redAccent, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                overlayState.errorMessage!,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close, color: Colors.white54, size: 16),
              onPressed: () {
                // В callback-контексті цей виджет не має доступу до ref,
                // тому оновлення overlay залишається на UI шарі
              },
              constraints: const BoxConstraints(
                minWidth: 32,
                minHeight: 32,
              ),
              padding: EdgeInsets.zero,
            ),
          ],
        ),
      ),
    );
  }
}

/// Екран завантаження, що показується під час ініціалізації додатку.
class _LoadingScreen extends StatefulWidget {
  const _LoadingScreen();

  @override
  State<_LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<_LoadingScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeIn;
  late final Animation<double> _pulse;
  late final Animation<double> _shimmer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();

    _fadeIn = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.3, curve: Curves.easeIn),
    );

    _pulse = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.5, 1.0, curve: Curves.easeInOut),
    );

    _shimmer = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 1.0, curve: Curves.linear),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      body: Center(
        child: FadeTransition(
          opacity: _fadeIn,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Логотип / іконка з пульсацією
              ScaleTransition(
                scale: _pulse,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: const LinearGradient(
                      colors: [Color(0xFF0070D1), Color(0xFF00D4FF)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF0070D1).withValues(alpha: 0.4),
                        blurRadius: 24,
                        spreadRadius: 4,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.savings_rounded,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Назва додатку
              const Text(
                'Nexora',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 8),

              // Підзаголовок
              const Text(
                'Гейміфікований фінансовий трекер',
                style: TextStyle(
                  color: Color(0xFF8B8BA7),
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 40),

              // Індикатор завантаження
              SizedBox(
                width: 120,
                height: 3,
                child: LinearProgressIndicator(
                  backgroundColor: const Color(0xFF14141F),
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    Color(0xFF00D4FF),
                  ),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),

              // Підказка під індикатором
              FadeTransition(
                opacity: _shimmer,
                child: const Text(
                  'Завантаження даних...',
                  style: TextStyle(
                    color: Color(0xFF8B8BA7),
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
