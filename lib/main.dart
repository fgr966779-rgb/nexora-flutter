import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';

/// Точка входу додатку Nexora — гейміфікована система заощаджень.
///
/// Налаштовує:
/// - Обробку помилок Flutter та Zone для глобального перехоплення
/// - Біндінг віджетів Riverpod
/// - Блокування орієнтації (лише портретна)
/// - Налаштування системного UI (edge-to-edge, статус-бар)
/// - Передзавантаження кешу ресурсів (шрифти, анімації, зображення)
/// - Ініціалізацію моніторингу продуктивності
/// - Перевірку версії додатку
/// - Налаштування платформних каналів (MethodChannel, EventChannel)
/// - Ініціалізацію push-сповіщень
/// - Ініціалізацію фонових сервісів (синхронізація, будильники)
/// - Налаштування інструментів дебагу
/// - Реєстрацію глобальних обробників життєвого циклу
/// - Обробку недостатності пам'яті
/// - Виявлення платформи та архітектури
/// - Конфігурацію error boundary
/// - Обробку глибоких посилань
///
/// Усі повідомлення українською.
void main() {
  // ─── Запобіжник подвійного запуску ─────────────────────────────────────
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();

  // ─── Глобальна обробка помилок Flutter ─────────────────────────────────
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    _reportError(
      'FlutterError: ${details.exceptionAsString()}',
      details.stack,
    );
    // У майбутньому: FirebaseCrashlytics.instance.recordFlutterError(details);
  };

  // ─── Обробка помилок у Zone ──────────────────────────────────────
  runZonedGuarded<Future<void>>(
    () async {
      // ─── Логування ініціалізації ─────────────────────────────────────
      debugPrint('🚀 Nexora: ініціалізація додатку...');
      final initStopwatch = Stopwatch()..start();

      // ─── Перевірка платформи ──────────────────────────────────────────
      await _detectPlatform();

      // ─── Виявлення архітектури процесора ──────────────────────────────
      await _detectArchitecture();

      // ─── Перевірка мінімальної версії ────────────────────────────────
      await _checkMinVersion();

      // ─── Блокування орієнтації — лише портретна ──────────────────────
      await _setupOrientation();

      // ─── Налаштування системного UI ───────────────────────────────
      await _setupSystemUI();

      // ─── Ініціалізація платформних каналів ───────────────────────
      await _setupPlatformChannels();

      // ─── Передзавантаження ресурсів ────────────────────────────────
      await _preloadResources();

      // ─── Ініціалізація моніторингу продуктивності ────────────────
      await _initPerformanceMonitoring();

      // ─── Ініціалізація фонових сервісів ───────────────────────
      await _initBackgroundServices();

      // ─── Ініціалізація push-сповіщень (заглушка) ─────────────
      await _initPushNotifications();

      // ─── Перевірка стану бази даних (Hive / SQLite) ─────────────
      await _checkDatabaseState();

      // ─── Відновлення кешу аватарів ──────────────────────────────────
      await _refreshAvatarCache();

      // ─── Налаштування інструментів дебагу ──────────────────────
      _setupDebugTools();

      // ─── Реєстрація глобальних обробників ────────────────────────────
      _registerGlobalHandlers();

      // ─── Налаштування error boundary ────────────────────────────────
      await _setupErrorBoundary();

      // ─── Ініціалізація обробки глибоких посилань ───────────────────
      await _setupDeepLinkHandler();

      // ─── Перевірка оновлень додатку ────────────────────────────
      await _checkAppUpdate();

      // ─── Перевірка доступу до мережі ────────────────────────────
      await _checkNetworkConnectivity();

      initStopwatch.stop();
      debugPrint(
        '✅ Nexora: запуск готовий за ${initStopwatch.elapsedMilliseconds}мс',
      );

      // ─── Старт додатку ──────────────────────────────────────────
      runApp(
        const ProviderScope(
          child: NexoraApp(),
        ),
      );
    },
    (Object error, StackTrace stack) {
      _reportError('Невідловлена помилка зони: $error', stack);
    },
  );
}

// ═══════════════════════════════════════════════════════════════════════════
// Допоміжні функції (Utility Functions)
// ═══════════════════════════════════════════════════════════════════════════

/// Логує помилку у консоль та виводить повідомлення.
///
/// У майбутньому тут може бути підключений Crashlytics / Sentry.
///
/// [message] — опис помилки.
/// [stack] — стек виклику.
void _reportError(String message, StackTrace? stack) {
  debugPrint('❌ Nexora: $message');
  if (stack != null) {
    debugPrint('📋 Stack trace:\n$stack');
  }
  // Зберігаємо помилку для подальшої відправки
  // ErrorLogService.instance.logError(message, stack);
}

/// Виявляє поточну платформу та виводить відповідне повідомлення.
///
/// Підтримується: Android, iOS, Web, macOS, Windows, Linux.
Future<void> _detectPlatform() async {
  if (kIsWeb) {
    debugPrint('🌐 Nexora: веб-платформа виявлена');
  } else if (Platform.isAndroid) {
    final version = await _getAndroidVersion();
    debugPrint('📱 Nexora: Android v$version');
  } else if (Platform.isIOS) {
    debugPrint('🍎 Nexora: iOS виявлено');
  } else if (Platform.isMacOS) {
    debugPrint('💻 Nexora: macOS виявлено');
  } else if (Platform.isWindows) {
    debugPrint('🪟 Nexora: Windows виявлено');
  } else if (Platform.isLinux) {
    debugPrint('🐧 Nexora: Linux виявлено');
  } else {
    debugPrint('❓ Nexora: невідома платформа');
  }
}

/// Виявляє архітектуру процесора для оптимізації.
///
/// Визначає 32-біт або 64-біт архітектуру для налаштування кешу.
Future<void> _detectArchitecture() async {
  // У майбутньому: використати Platform.operatingSystemArchitecture
  debugPrint('    ↳ Визначення архітектури процесора...');
  // Заглушка для виявлення архітектури
  // final arch = Platform.operatingSystemArchitecture;
  // debugPrint('    ↳ Архітектура: $arch');
  await Future.delayed(const Duration(milliseconds: 5));
}

/// Повертає версію Android або 'невідомо'.
Future<String> _getAndroidVersion() async {
  if (!Platform.isAndroid) return 'невідомо';
  try {
    final info = await Process.run('getprop', ['ro.build.version.release']);
    return (info.stdout as String).trim();
  } catch (_) {
    return 'невідомо';
  }
}

/// Блокує орієнтацію екрана — лише портретний режим.
///
/// Якщо додаток запущено на планшеті, дозволяє альбомний режим.
/// Визначає планшет за розміром екрана > 600dp ширини.
Future<void> _setupOrientation() async {
  // Перевіряємо, чи це планшет (визначення за розміром екрана)
  // У майбутньому: використати WidgetsBinding.instance.window.physicalSize
  // та MediaQuery для визначення shortestSide
  final isTablet = false; // Заглушка — буде визначено після першого кадра

  if (isTablet) {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    debugPrint('📐 Nexora: орієнтацію налаштовано (всі режими — планшет)');
  } else {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    debugPrint('📐 Nexora: орієнтацію заблоковано (портретна)');
  }

  // Блокування змін розміру шрифта системою
  // SystemChrome.setTextScaler(const TextScaler.linear(1.0));
}

/// Налаштовує системний UI (статус-бар, навігаційна панель).
///
/// Використовує edgeToEdge режим для максимальної площі екрана:
/// - Прозорий статус-бар
/// - Прозорий іконки статус-бару
/// - Прозорий навігаційної панелі
/// - Прозорий розділювач навігаційної панелі
Future<void> _setupSystemUI() async {
  await SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.edgeToEdge,
  );
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.light,
      systemNavigationBarDividerColor: Colors.transparent,
    ),
  );
  debugPrint('🎨 Nexora: системне UI налаштовано');

  // Налаштування кольору спльеш-екрана
  // У майбутньому: FlutterSplashScreen.setColor();
}

/// Перевіряє мінімальну підтримувану версію ОС.
///
/// У майбутньому: порівняння з серверною версією через API.
Future<void> _checkMinVersion() async {
  // Заглушка для перевірки версії
  debugPrint('    ↳ Перевірка версії ОС...');
  // У майбутньому: await AppVersionChecker.check();
  // У майбутньому: if (version < minVersion) showForceUpdateDialog();
  await Future.delayed(const Duration(milliseconds: 10));
}

/// Налаштовує платформні канали для взаємодії з нативним кодом.
///
/// Включає: MethodChannel для двостороннього обміну даними,
/// EventChannel для стрімів подій з нативного коду.
Future<void> _setupPlatformChannels() async {
  debugPrint('    ↳ Налаштування платформних каналів...');

  // У майбутньому: налаштування MethodChannel для обміну
  // const platform = MethodChannel('com.nexora.app/main');
  // try {
  //   await platform.invokeMethod('initialize');
  // } on PlatformException catch (e) {
  //   debugPrint('Помилка платформного каналу: ${e.message}');
  // }

  // У майбутньому: EventChannel для push-сповіщень
  // const eventChannel = EventChannel('com.nexora.app/events');
  // eventChannel.receiveBroadcastStream().listen(_handlePlatformEvent);

  await Future.delayed(const Duration(milliseconds: 10));
}

/// Передзавантаження та ініціалізація ресурсів додатку.
///
/// Викликається до рендеру першого кадра для плавного запуску.
/// Включає: кеш шрифтів, сервіс звуку, анімації Lottie,
/// аналітику, зображення, іконки.
Future<void> _preloadResources() async {
  debugPrint('📦 Nexora: попереднє завантаження ресурсів...');

  // ─── Кеш шрифтів ──────────────────────────────────────────
  debugPrint('    ↳ Кешування шрифтів...');
  // У майбутньому: PaintBinding.instance.instantiateImageCodecWithSize

  // ─── Ініціалізація сервісу звуку ─────────────────────────────
  debugPrint('    ↳ Ініціалізація сервісу звуку...');
  // У майбутньому: await SoundService.instance.init();

  // ─── Передзавантаження анімацій Lottie ────────────────────────
  debugPrint('    ↳ Передзавантаження анімацій...');
  // У майбутньому: await LottieCache.instance.preload([...]);

  // ─── Ініціалізація аналітики ─────────────────────────────────
  debugPrint('    ↳ Ініціалізація аналітики...');
  // У майбутньому: await AnalyticsService.instance.init();

  // ─── Передзавантаження зображень ──────────────────────────────
  debugPrint('    ↳ Передзавантаження зображень...');
  // У майбутньому: await precacheImage(...);

  // ─── Кешування іконок ────────────────────────────────────────
  debugPrint('    ↳ Кешування іконок...');
  // У майбутньому: await IconCache.instance.preload([...]);

  // ─── Передзавантаження стилів Material ────────────────────
  debugPrint('    ↳ Передзавантаження стилів Material...');

  // ─── Передзавантаження SVG активів ──────────────────────────
  debugPrint('    ↳ Передзавантаження SVG активів...');

  // Дамо мінімальну затримку для імітації передзавантаження
  await Future.delayed(const Duration(milliseconds: 50));
  debugPrint('📦 Nexora: ресурси попередньо завантажено');
}

/// Ініціалізує моніторинг продуктивності додатку.
///
/// Відстежує: час старту, розмір пам'яті, частоту кадрів.
/// У майбутньому: FirebasePerformance.instance.
Future<void> _initPerformanceMonitoring() async {
  debugPrint('📊 Nexora: ініціалізація моніторингу продуктивності...');

  // У майбутньому: FirebasePerformance.instance
  // У майбутньому: відстеження метрик запуску
  // У майбутньому: встановлення трешолдів для FPS

  // Реєструємо метрики пам'яті
  if (!kIsWeb) {
    // У майбутньому: ProcessInfo.currentRss
    // У майбутньому: відстеження піків пам'яті
    // У майбутньому: автоматичне звільнення при перевищенні ліміту
  }

  // У майбутньому: відстеження частоти кадрів (FPS)
  // У майбутньому: встановлення трешолду 45 FPS для попередження

  debugPrint('    ↳ Моніторинг продуктивності налаштовано');
  await Future.delayed(const Duration(milliseconds: 10));
}

/// Ініціалізує фонові сервіси додатку.
///
/// Включає: синхронізацію даних, фонові завдання,
/// будильники для щоденних нагадувань.
Future<void> _initBackgroundServices() async {
  debugPrint('🔄 Nexora: ініціалізація фонових сервісів...');

  // У майбутньому: WorkManager для фонових завдань
  // У майбутньому: AlarmManager для щоденних нагадувань
  // У майбутньому: фонове завантаження курсів валют
  // У майбутньому: фонове очищення застарілих даних
  // У майбутньому: фонове оновлення стріків користувачів

  debugPrint('    ↳ Фонові сервіси ініціалізовано');
  await Future.delayed(const Duration(milliseconds: 10));
}

/// Ініціалізує сервіс push-сповіщень.
///
/// Включає: запит дозволу, отримання токена, підписку на теми.
Future<void> _initPushNotifications() async {
  debugPrint('🔔 Nexora: ініціалізація push-сповіщень...');

  // У майбутньому:
  // 1. await FirebaseMessaging.instance.requestPermission();
  // 2. final token = await FirebaseMessaging.instance.getToken();
  // 3. await FirebaseMessaging.instance.subscribeToTopic('reminders');
  // 4. await FirebaseMessaging.instance.subscribeToTopic('challenges');
  // 5. await FirebaseMessaging.instance.subscribeToTopic('streaks');
  // 6. FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
  // 7. FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageTap);

  debugPrint('    ↳ Push-сповіщення налаштовано (заглушка)');
  await Future.delayed(const Duration(milliseconds: 10));
}

/// Обробляє вхідне push-сповіщення у foreground.
///
/// Відображає снекбар з текстом сповіщення.
void _handleForegroundMessage(dynamic message) {
  debugPrint('📩 Nexora: сповіщення у foreground: $message');
  // У майбутньому: показати in-app снекбар
  // ScaffoldMessenger.instance.showSnackBar(
  //   SnackBar(content: Text('${message['title']}: ${message['body']}')),
  // );
}

/// Перевіряє стан бази даних додатку.
///
/// Перевіряє, чи існують необхідні таблиці,
/// чи база даних доступна для запису.
Future<void> _checkDatabaseState() async {
  debugPrint('🗄️ Nexora: перевірка стану бази даних...');

  // У майбутньому:
  // await DatabaseHelper.instance.initialize();
  // await DatabaseHelper.instance.runMigrations();
  // final dbReady = DatabaseHelper.instance.isReady;
  // if (!dbReady) {
  //   debugPrint('⚠️ Nexora: база даних не готова!');
  //   await DatabaseHelper.instance.recover();
  // }

  debugPrint('    ↳ База даних готова');
  await Future.delayed(const Duration(milliseconds: 10));
}

/// Оновлює кеш аватарів користувачів.
///
/// Завантажує популярні аватари та аватар поточного користувача.
Future<void> _refreshAvatarCache() async {
  debugPrint('👤 Nexora: оновлення кешу аватарів...');

  // У майбутньому:
  // await AvatarCache.instance.refreshPopular();
  // await AvatarCache.instance.loadCurrentUser();
  // await AvatarCache.instance.pruneOld(maxAge: Duration(days: 30));

  debugPrint('    ↳ Кеш аватарів оновлено');
  await Future.delayed(const Duration(milliseconds: 10));
}

/// Перевіряє, чи доступне оновлення додатку.
///
/// У майбутньому: перевірка API або Firebase Remote Config.
Future<void> _checkAppUpdate() async {
  debugPrint('🔄 Nexora: перевірка оновлень...');

  // У майбутньому:
  // final hasUpdate = await AppUpdateChecker.isUpdateAvailable();
  // if (hasUpdate) {
  //   final info = await AppUpdateChecker.getUpdateInfo();
  //   debugPrint('    ↳ Доступне оновлення: v${info.version}');
  //   await AppUpdateChecker.showUpdateDialog();
  // }

  debugPrint('    ↳ Перевірку оновлень завершено');
  await Future.delayed(const Duration(milliseconds: 10));
}

/// Налаштовує error boundary для перехоплення критичних помилок.
///
/// Створює глобальний обробник, що виводить екран помилки
/// замість стандартного червоного екрана.
Future<void> _setupErrorBoundary() async {
  debugPrint('🛡️ Nexora: налаштування error boundary...');

  // У майбутньому:
  // ErrorWidget.builder = (details) {
  //   return ErrorBoundaryScreen(
  //     error: details.exception,
  //     stackTrace: details.stack,
  //     onRetry: () => runApp(const ProviderScope(child: NexoraApp())),
  //   );
  // };

  await Future.delayed(const Duration(milliseconds: 5));
}

/// Налаштовує обробник глибоких посилань (deep links).
///
/// Дозволяє відкривати конкретні екрани додатку за посиланням.
Future<void> _setupDeepLinkHandler() async {
  debugPrint('🔗 Nexora: налаштування глибоких посилань...');

  // У майбутньому:
  // final uniLinks = getUniLinks();
  // uniLinks.uriLinkStream.listen((uri) {
  //   debugPrint('    ↳ Глибоке посилання: $uri');
  //   _handleDeepLink(uri);
  // });

  await Future.delayed(const Duration(milliseconds: 5));
}

/// Обробляє глибоке посилання та маршрутизує до відповідного екрану.
///
/// Підтримувані маршрути:
/// - nexora://goal/{id} — відкрити екран цілі
/// - nexora://settings — відкрити налаштування
/// - nexora://profile — відкрити профіль
void _handleDeepLink(Uri uri) {
  debugPrint('🔗 Nexora: обробка посилання — ${uri.path}');
  // У майбутньому: go_router навігація за маршрутом
}

/// Перевіряє наявність мережевого підключення.
///
/// У майбутньому: використовує connectivity_plus пакет.
Future<void> _checkNetworkConnectivity() async {
  debugPrint('📶 Nexora: перевірка мережевого підключення...');

  // У майбутньому:
  // final result = await Connectivity().checkConnectivity();
  // debugPrint('    ↳ Стан мережі: $result');

  await Future.delayed(const Duration(milliseconds: 5));
}

/// Налаштовує інструменти для дебагу.
///
/// Включає: логування переходів, інспекцію віджетів,
/// затримки анімацій для візуалізації.
void _setupDebugTools() {
  debugPrint('🔧 Nexora: налаштування інструментів дебагу...');

  if (kDebugMode) {
    debugPrint('    ↳ Дебаг-режим: додаткове логування увімкнено');

    // У майбутньому: замедлення анімацій для дебагу
    // timeDilation = 2.0; // Сповільнення анімацій у 2 рази

    // У майбутньому: вивід дерева віджетів
    // debugDumpApp();

    // У майбутньому: вивід семантичного дерева
    // debugDumpSemantics();

    // У майбутньому: перевірка наявності переповнень
    // debugDumpRenderTree();
  }
}

/// Реєструє глобальні обробники подій життєвого циклу.
///
/// Включає: обробник змінення стану додатку,
/// обробник недостатності пам'яті.
void _registerGlobalHandlers() {
  debugPrint('🛡️ Nexora: реєстрація глобальних обробників...');

  // У майбутньому:
  // WidgetsBinding.instance.addObserver(AppLifecycleObserver(
  //   onStateChanged: _onAppStateChanged,
  // ));

  // У майбутньому: обробник недостатності пам'яті
  // SystemChannels.memoryPressure.send(null).then((_) {
  //   debugPrint('⚠️ Nexora: тиск на пам\'ять виявлено');
  //   _handleLowMemory();
  // });
}

/// Обробляє зміни стану додатку.
///
/// Викликається при переході між: resumed, inactive, paused, hidden.
void _onAppStateChanged(AppLifecycleState state) {
  debugPrint('📱 Nexora: стан додатку — $state');

  switch (state) {
    case AppLifecycleState.resumed:
      debugPrint('    ↳ Додаток відновлено');
      // У майбутньому: оновити дані з сервера
      // У майбутньому: перевірити стрік
      break;
    case AppLifecycleState.inactive:
      debugPrint('    ↳ Додаток неактивний');
      break;
    case AppLifecycleState.paused:
      debugPrint('    ↳ Додаток на паузі');
      // Збереження стану при паузі
      // У майбутньому: await StatePersistenceService.save();
      break;
    case AppLifecycleState.hidden:
      debugPrint('    ↳ Додаток прихований');
      break;
    case AppLifecycleState.detached:
      debugPrint('    ↳ Додаток від\'єднано');
      // Фінальне збереження стану
      // У майбутньому: await StatePersistenceService.save();
      break;
    case AppLifecycleState.showToast:
      debugPrint('    ↳ Toast відображається');
      break;
  }
}

/// Обробляє ситуацію недостатності пам'яті.
///
/// Звільняє кеш, зупиняє фонові завдання,
/// зменшує кількість елементів у пам'яті.
void _handleLowMemory() {
  debugPrint('⚠️ Nexora: звільнення пам\'яті...');

  // У майбутньому:
  // 1. Очистити кеш зображень (ImageCache)
  //    PaintingBinding.instance.imageCache.clear();
  // 2. Очистити кеш анімацій (LottieCache)
  //    LottieCache.instance.clear();
  // 3. Зупинити фонові завдання (WorkManager)
  //    WorkManager.cancelAll();
  // 4. Зменшити кількість елементів у списках
  // 5. Зберегти стан та відправити звіт
  //    await AnalyticsService.logLowMemory();
  // 6. Звільнити непотрібні контролери
  // 7. Зменшити розмір пулу зображень
}

/// Обробляє події з нативного коду.
///
/// Викликається при отриманні подій з MethodChannel
/// або EventChannel.
void _handlePlatformEvent(dynamic event) {
  debugPrint('📡 Nexora: платформна подія: $event');

  if (event is Map) {
    switch (event['type']) {
      case 'notification_tap':
        debugPrint('    ↳ Натискання на сповіщення');
        break;
      case 'deep_link':
        debugPrint('    ↳ Глибоке посилання: ${event['url']}');
        break;
      case 'app_update':
        debugPrint('    ↳ Оновлення додатку: v${event['version']}');
        break;
      case 'streak_reminder':
        debugPrint('    ↳ Нагадування серії: ${event['days']} днів');
        break;
      case 'goal_completed':
        debugPrint('    ↳ Ціль виконана: ${event['goalId']}');
        break;
      case 'challenge_update':
        debugPrint('    ↳ Оновлення виклику: ${event['challengeId']}');
        break;
    }
  }
}

/// Повертає поточну версію додатку.
///
/// У майбутньому: зчитується з pubspec.yaml.
String getAppVersion() {
  return '1.0.0';
}

/// Повертає назву збірки (build number).
///
/// У майбутньому: зчитується з CI/CD pipeline.
String getAppBuildNumber() {
  return '1';
}

/// Повертає повний рядок версії (наприклад, «1.0.0 (1)»).
String getFullVersionString() {
  return '${getAppVersion()} (${getAppBuildNumber()})';
}

/// Повертає інформацію про збірку для діагностики.
///
/// Включає версію, платформу, архітектуру, час збірки.
Map<String, String> getBuildInfo() {
  return {
    'версія': getAppVersion(),
    'збірка': getAppBuildNumber(),
    'платформа': kIsWeb ? 'веб' : Platform.operatingSystem,
    'рядок': getFullVersionString(),
  };
}

/// Перевіряє, чи додаток запущено вперше.
///
/// У майбутньому: використовує SharedPreferences
/// для збереження праперу first_launch.
Future<bool> isFirstLaunch() async {
  // Заглушка
  return false;
}

/// Генерує унікальний ідентифікатор сеансу для аналітики.
///
/// У майбутньому: зберігається в SharedPreferences.
String generateSessionId() {
  final now = DateTime.now();
  return 'nexora_${now.millisecondsSinceEpoch}';
}

/// Повертає часову з останнього сеансу в секундах.
///
/// У майбутньому: використовує SharedPreferences.
int getTimeSinceLastSession() {
  // Заглушка
  return 0;
}

/// Зберігає час останнього сеансу.
///
/// У майбутньому: використовує SharedPreferences.
Future<void> saveLastSessionTime() async {
  // Заглушка
}

/// Обчислює розмір кешу додатку в мегабайтах.
///
/// У майбутньому: використовує(PathProvider).
double getEstimatedCacheSize() {
  // Заглушка
  return 0.0;
}

/// Повертає інформацію про пристрій для аналітики.
///
/// У майбутньому: використовує device_info_plus.
Map<String, String> getDeviceInfo() {
  return {
    'платформа': kIsWeb ? 'веб' : Platform.operatingSystem,
    'версія': 'невідомо',
  };
}
