// ═══════════════════════════════════════════════════════════════════════════
// notifications_screen.dart — Notification Settings Screen
// ═══════════════════════════════════════════════════════════════════════════
//
/// Екран «Сповіщення» — перемикачі, час, тихі години.
///
/// Містить:
/// - Щоденне нагадування з діалогом вибору часу
/// - Перемикач нагадування про автоплатіж
/// - Мотиваційні повідомлення з частотою
/// - Перемикач нагадувань про виклики
/// - Перемикач новин додатку
/// - Перемикач нагадувань про стріки
/// - Перемикач тижневого звіту
/// - Секцію «Тихі години» (Do Not Disturb) із початковим/кінцевим часом
/// - Звук для кожного типу сповіщення
/// - Кнопку тестового сповіщення
/// - Картку попереднього перегляду сповіщення
/// - Секцію розкладу сповіщень за типом
/// - Історію сповіщень з видаленням
/// - Канали сповіщень з управлінням
/// - Рівні пріоритету (високий/нормальний/низький)
/// - Пакетне позначення прочитаним
/// - Індикатор загальної кількості сповіщень
/// - Анімації для всіх елементів інтерфейсу
/// - Фільтрацію історії сповіщень за типом
/// - Детальний перегляд сповіщення з розгортанням
/// - Лічильник непрочитаних сповіщень
/// - Діалог підтвердження очищення історії
/// - Опції групового керування каналами
/// - Запобіжники дублювання сповіщень
/// - Режим повного вимкнення всіх сповіщень
///
/// {@category Settings}
/// {@subcategory Notifications}
library;

import 'dart:async';
import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_radii.dart';
import '../../../../core/extensions/build_context_ext.dart';

/// ─── Logging Tag ────────────────────────────────────────────────────────────

/// Тег для логування подій цього екрану.
const String _logTag = '🔔 NotificationsScreen';

/// ─── Notification Constants ────────────────────────────────────────────────

/// Клас констант для параметрів сповіщень.
class _NotificationConstants {
  /// Максимальна кількість елементів в історії.
  static const int maxHistoryItems = 100;

  /// Мінімальна тривалість тестового сповіщення (мс).
  static const int testNotificationMinDuration = 800;

  /// Максимальна тривалість тестового сповіщення (мс).
  static const int testNotificationMaxDuration = 3000;

  /// Стандартна тривалість тестового сповіщення (мс).
  static const int testNotificationDefaultDuration = 1500;

  /// Максимальна кількість непрочитаних для показу badge.
  static const int unreadBadgeMax = 99;

  /// Дефолтний час тихих годин (початок).
  static const TimeOfDay defaultQuietStart = TimeOfDay(hour: 22, minute: 0);

  /// Дефолтний час тихих годин (кінець).
  static const TimeOfDay defaultQuietEnd = TimeOfDay(hour: 8, minute: 0);

  /// Анімація появи елементів (мс).
  static const int fadeInDuration = 300;

  /// Затримка між stagger-анімаціями (мс).
  static const int staggerDelay = 100;

  /// Максимальна кількість символів у пошуковому запиті.
  static const int maxSearchQueryLength = 50;

  /// Дефолтна тривалість undo-таймера (секунди).
  static const int undoTimerDuration = 5;

  /// Мінімальна тривалість відкладення (хв).
  static const int minSnoozeDuration = 0;

  /// Максимальна тривалість відкладення (хв).
  static const int maxSnoozeDuration = 60;

  /// Максимальна кількість batch-операцій за один раз.
  static const int maxBatchOperations = 50;

  /// Тривалість анімації кнопки (мс).
  static const int buttonAnimationDuration = 200;

  /// Тривалість показу toast-повідомлення (мс).
  static const int toastDuration = 2500;

  /// Кількість елементів у випадаючому списку пріоритету.
  static const int priorityDropdownItems = 3;

  /// Мінімальна тривалість тихих годин (хвилини).
  static const int minQuietHoursDuration = 30;

  /// Максимальна кількість одночасних тестових сповіщень.
  static const int maxConcurrentTests = 1;

  /// Крок зміни гучності (0.0 - 1.0).
  static const double volumeStep = 0.1;

  /// Мінімальна гучність.
  static const double minVolume = 0.0;

  /// Максимальна гучність.
  static const double maxVolume = 1.0;

  /// Таймаут експорту налаштувань (секунди).
  static const int exportTimeout = 10;

  /// Максимальна кількість шаблонів сповіщень.
  static const int maxTemplates = 20;

  /// Мінімальний інтервал повторних нагадувань (хвилини).
  static const int minRepeatInterval = 5;

  /// Максимальний інтервал повторних нагадувань (хвилини).
  static const int maxRepeatInterval = 120;

  /// Максимальна тривалість сповіщення в секції розкладу (дні).
  static const int maxScheduleDays = 30;

  /// Кількість днів для тижневого розкладу.
  static const int weeklyScheduleDays = 7;

  /// Максимальна кількість звуків у списку.
  static const int maxSoundListItems = 20;

  /// Мінімальна тривалість між двома тестовими сповіщеннями (секунди).
  static const int minTestIntervalSeconds = 2;
}

/// ─── Main Screen Widget ────────────────────────────────────────────────────

/// Екран налаштувань сповіщень користувача.
///
/// Надає повний контроль над усіма типами сповіщень додатку,
/// включаючи розклади, канали, тихі години та історію.
///
/// Приклад використання:
/// ```dart
/// Navigator.of(context).pushNamed('/notifications');
/// ```
///
/// Параметри: не приймає жодних параметрів.
///
/// Повертає екран з [Scaffold] та [ListView] контентом.
class NotificationsScreen extends StatefulWidget {
  /// Створює екран налаштувань сповіщень.
  ///
  /// Всі налаштування зберігаються локально в стані.
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

/// Стан екрану сповіщень.
///
/// Керує:
/// - Перемикачами різних типів сповіщень
/// - Часом нагадувань та тихих годин
/// - Налаштуваннями звуку для кожного каналу
/// - Історією сповіщень
/// - Рівнями пріоритету
/// - Режимами фільтрації
/// - Станами завантаження та відправки
class _NotificationsScreenState extends State<NotificationsScreen> {
  // ─── Notification Toggle States ─────────────────────────────────────────

  /// Чи увімкнено щоденне нагадування про внески.
  bool _dailyReminder = true;

  /// Чи увімкнено нагадування про автоплатіж.
  bool _autoPaymentReminder = true;

  /// Чи увімкнено мотиваційні повідомлення.
  bool _motivationMessages = false;

  /// Частота мотиваційних повідомлень.
  String _motivationFrequency = 'Щотижня';

  /// Чи увімкнено нагадування про виклики.
  bool _challengeReminder = true;

  /// Чи увімкнено новини додатку.
  bool _appNews = false;

  /// Чи увімкнено нагадування про стріки.
  bool _streakReminder = true;

  /// Чи увімкнено щотижневий звіт.
  bool _weeklyReport = true;

  // ─── Time Settings ─────────────────────────────────────────────────────

  /// Час щоденного нагадування.
  TimeOfDay _dailyTime = const TimeOfDay(hour: 19, minute: 0);

  /// Чи увімкнено тихі години.
  bool _quietHoursEnabled = false;

  /// Початок тихих годин.
  TimeOfDay _quietStart = _NotificationConstants.defaultQuietStart;

  /// Кінець тихих годин.
  TimeOfDay _quietEnd = _NotificationConstants.defaultQuietEnd;

  // ─── Sound Settings ────────────────────────────────────────────────────

  /// Чи увімкнено звук для щоденного нагадування.
  bool _dailySound = true;

  /// Чи увімкнено звук для автоплатежу.
  bool _paymentSound = true;

  /// Чи увімкнено звук для мотивації.
  bool _motivationSound = true;

  /// Чи увімкнено звук для викликів.
  bool _challengeSound = true;

  /// Чи увімкнено звук для новин.
  bool _newsSound = false;

  /// Чи увімкнено звук для стріків.
  bool _streakSound = true;

  /// Чи увімкнено звук для звіту.
  bool _weeklySound = true;

  // ─── State Management ─────────────────────────────────────────────────

  /// Чи зараз відправляється тестове сповіщення.
  bool _isTestSending = false;

  /// Фільтр історії сповіщень (порожний = всі).
  String _historyFilter = '';

  /// Чи показувати діалог очищення історії.
  bool _showClearDialog = false;

  /// Ідентифікатор розгорнутого елемента історії (-1 = жоден).
  int _expandedHistoryIndex = -1;

  /// Чи увімкнено вібрацію для сповіщень.
  bool _vibrationEnabled = true;

  /// Тип группування сповіщень ('none' | 'type' | 'app').
  String _groupingMode = 'type';

  /// Тривалість відкладеного сповіщення (хвилини, 0 = вимкнено).
  int _snoozeDuration = 10;

  /// Лічильник спроб тестового сповіщення.
  int _testRetryCount = 0;

  /// Останній час показу тестового сповіщення.
  DateTime? _lastTestTime;

  /// Чи показувати розширену статистику.
  bool _showNotificationStats = false;

  /// Чи відстежувати аналітику сповіщень.
  bool _analyticsEnabled = true;

  /// Кількість надісланих тестових сповіщень за сесію.
  int _totalTestSent = 0;

  // ─── Additional State ─────────────────────────────────────────────────

  /// Гучність сповіщень (0.0 - 1.0).
  double _notificationVolume = 0.8;

  /// Чи увімкнено повторні нагадування.
  bool _repeatRemindersEnabled = false;

  /// Інтервал повторних нагадувань (хвилини).
  int _repeatReminderInterval = 30;

  /// Чи увімкнено LED-індикатор.
  bool _ledIndicatorEnabled = true;

  /// Чи увімкнено показ на екрані блокування.
  bool _showOnLockScreen = true;

  /// Чи показувати текст сповіщення на lock screen.
  bool _showContentOnLockScreen = true;

  /// Обраний звук сповіщення (назва файлу).
  String _selectedSoundName = 'default';

  /// Доступні звуки сповіщень.
  final List<String> _availableSounds = [
    'default', 'chime', 'bell', 'beep', 'melody', 'gentle', 'urgent',
  ];

  /// Індекс сторінки в пагінації історії.
  int _historyCurrentPage = 0;

  /// Кількість відхилених сповіщень для аналітики.
  int _totalDismissed = 0;

  /// Кількість відкритих сповіщень для аналітики.
  int _totalOpened = 0;

  /// Чи показувати секцію розкладу.
  bool _showScheduleSection = false;

  /// Режим експорту даних ('json' | 'csv').
  String _exportFormat = 'json';

  /// Останній експортований timestamp.
  DateTime? _lastExportTime;

  /// Пошуковий запит для фільтрації історії.
  String _historySearchQuery = '';

  /// Чи показувати розширені налаштування звуку.
  bool _showAdvancedSoundSection = false;

  /// Чи показувати секцію повторних нагадувань.
  bool _showRepeatSection = false;

  // ─── Priority Settings ────────────────────────────────────────────────

  /// Рівень пріоритету щоденних сповіщень.
  String _dailyPriority = 'Високий';

  /// Рівень пріоритету сповіщень про виклики.
  String _challengePriority = 'Високий';

  /// Рівень пріоритету новин.
  String _newsPriority = 'Низький';

  /// Рівень пріоритету сповіщень про стріки.
  String _streakPriority = 'Високий';

  // ─── Notification History ─────────────────────────────────────────────

  /// Історія сповіщень (mock дані).
  final List<_NotificationRecord> _notificationHistory = [
    _NotificationRecord(
      title: 'Час зробити внесок!',
      body: 'Ти на правильному шляху! 💪',
      time: '19:00',
      isRead: false,
      type: 'Щоденне',
      id: '1',
    ),
    _NotificationRecord(
      title: 'Автоплатіж успішний',
      body: '50 грн додано до цілі «PS5»',
      time: '10:00',
      isRead: true,
      type: 'Автоплатіж',
      id: '2',
    ),
    _NotificationRecord(
      title: 'Стріка під загрозою!',
      body: 'Не забудь поповнити сьогодні ⚠️',
      time: '08:00',
      isRead: false,
      type: 'Стріка',
      id: '3',
    ),
    _NotificationRecord(
      title: 'Тиждень у цифрах',
      body: 'Заложено 2 450 грн за цей тиждень',
      time: '09:00',
      isRead: true,
      type: 'Звіт',
      id: '4',
    ),
    _NotificationRecord(
      title: 'Новий виклик!',
      body: '«Маратон заощаджень» — приєднуйся!',
      time: '12:00',
      isRead: false,
      type: 'Виклик',
      id: '5',
    ),
  ];

  // ─── Constants ────────────────────────────────────────────────────────

  /// Частоти мотиваційних повідомлень.
  final _motivationFrequencies = ['Щоденно', 'Щотижня', 'Щомісяця'];

  /// Рівні пріоритету сповіщень.
  static const _priorityLevels = ['Високий', 'Нормальний', 'Низький'];

  /// Доступні фільтри для історії сповіщень.
  static const _historyFilterOptions = ['', 'Щоденне', 'Автоплатіж', 'Стріка', 'Звіт', 'Виклик'];

  /// Мапа іконок для типів сповіщень.
  static const _typeIcons = <String, IconData>{
    'Щоденне': Icons.alarm_rounded,
    'Автоплатіж': Icons.credit_card_rounded,
    'Стріка': Icons.local_fire_department_rounded,
    'Звіт': Icons.bar_chart_rounded,
    'Виклик': Icons.emoji_events_rounded,
  };

  /// Мінімальна тривалість затримки повторного сповіщення (хв).
  static const int duplicateSuppressionMinutes = 5;

  /// Максимальна кількість спроб відправки тестового сповіщення.
  static const int maxTestRetries = 3;

  /// Тривалість анімації появи карток (мс).
  static const int cardAppearDuration = 350;

  /// Тривалість анімації зникнення карток (мс).
  static const int cardDismissDuration = 250;

  /// Кількість сповіщень на сторінку в історії.
  static const int historyPageSize = 20;

  /// Мапа кольорів для типів сповіщень.
  static const _typeColors = <String, Color>{
    'Щоденне': AppColorsPS5.accent,
    'Автоплатіж': AppColorsPS5.success,
    'Стріка': Color(0xFFFF6B6B),
    'Звіт': Color(0xFF6C5CE7),
    'Виклик': Color(0xFFFFD600),
  };

  /// Канали сповіщень.
  static const _notificationChannels = [
    _NotificationChannel(
      name: 'Щоденні нагадування',
      description: 'Щоденні сповіщення про внески',
      enabled: true,
      id: 'daily',
    ),
    _NotificationChannel(
      name: 'Автоплатежі',
      description: 'Сповіщення про автоматичні платежі',
      enabled: true,
      id: 'payment',
    ),
    _NotificationChannel(
      name: 'Мотивація',
      description: 'Мотиваційні повідомлення та поради',
      enabled: false,
      id: 'motivation',
    ),
    _NotificationChannel(
      name: 'Виклики',
      description: 'Нові виклики та дедлайни',
      enabled: true,
      id: 'challenge',
    ),
    _NotificationChannel(
      name: 'Стріки',
      description: 'Нагадування про серію поповнень',
      enabled: true,
      id: 'streak',
    ),
    _NotificationChannel(
      name: 'Новини',
      description: 'Оновлення додатку та нові функції',
      enabled: false,
      id: 'news',
    ),
    _NotificationChannel(
      name: 'Звіти',
      description: 'Щотижневі звіти про прогрес',
      enabled: true,
      id: 'report',
    ),
  ];

  // ─── Computed Properties ───────────────────────────────────────────────

  /// Кількість непрочитаних сповіщень.
  int get _unreadCount {
    try {
      return _filteredHistory.where((n) => !n.isRead).length;
    } catch (e) {
      developer.log('Error calculating unread count: $e', name: _logTag);
      return 0;
    }
  }

  /// Відфільтрована історія сповіщень.
  List<_NotificationRecord> get _filteredHistory {
    try {
      if (_historyFilter.isEmpty) return _notificationHistory;
      return _notificationHistory
          .where((n) => n.type == _historyFilter)
          .toList();
    } catch (e) {
      developer.log('Error filtering history: $e', name: _logTag);
      return _notificationHistory;
    }
  }

  /// Чи всі сповіщення вимкнено.
  bool get _allNotificationsOff {
    return !_dailyReminder &&
        !_autoPaymentReminder &&
        !_motivationMessages &&
        !_challengeReminder &&
        !_appNews &&
        !_streakReminder &&
        !_weeklyReport;
  }

  /// Кількість увімкнених каналів сповіщень.
  int get _enabledChannelsCount {
    return _notificationChannels.where((ch) => ch.enabled).length;
  }

  /// Відсоток увімкнених сповіщень (0-100).
  int get _notificationsEnabledPercent {
    final total = _notificationChannels.length;
    if (total == 0) return 0;
    return ((_enabledChannelsCount / total) * 100).round();
  }

  // ─── Lifecycle ────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    developer.log('Screen initialized', name: _logTag);
  }

  // ─── Timer import already at top ─────────────────────────────────────
  // ─── Time Picker ──────────────────────────────────────────────────────

  /// Показує діалог вибору часу.
  ///
  /// [context] — контекст для показу діалогу.
  /// [initial] — початковий час у діалозі.
  /// [onPicked] — callback при виборі часу.
  Future<void> _pickTime(
    BuildContext context,
    TimeOfDay initial,
    Function(TimeOfDay) onPicked,
  ) async {
    try {
      final picked = await showTimePicker(
        context: context,
        initialTime: initial,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        ),
      );
      if (picked != null && mounted) {
        onPicked(picked);
        developer.log(
          'Time picked: ${_formatTime(picked)}',
          name: _logTag,
        );
      }
    } catch (e) {
      developer.log('Error picking time: $e', name: _logTag);
      if (mounted) {
        context.showAppToast(
          'Помилка вибору часу',
          type: AppToastType.error,
        );
      }
    }
  }

  // ─── Formatters ───────────────────────────────────────────────────────

  /// Форматує [TimeOfDay] у рядок HH:mm.
  ///
  /// Приклад: `TimeOfDay(hour: 9, minute: 5)` → `"09:05"`
  String _formatTime(TimeOfDay time) {
    try {
      return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      developer.log('Error formatting time: $e', name: _logTag);
      return '00:00';
    }
  }

  /// Форматує тип сповіщення з відповідною іконкою.
  String _formatTypeWithIcon(String type) {
    final icon = _typeIcons[type] != null ? '🔔' : '📌';
    return '$icon $type';
  }

  // ─── Validation ───────────────────────────────────────────────────────

  /// Перевіряє, чи час тихих годин валідний.
  bool _isQuietHoursValid() {
    if (!_quietHoursEnabled) return true;
    // Не перевіряємо перетин — користувач може хотіти тихі години через північ
    return _quietStart != _quietEnd;
  }

  /// Перевіряє, чи зараз тихі години.
  bool _isCurrentlyQuietHours() {
    if (!_quietHoursEnabled) return false;
    final now = TimeOfDay.now();
    final startMinutes = _quietStart.hour * 60 + _quietStart.minute;
    final endMinutes = _quietEnd.hour * 60 + _quietEnd.minute;
    final nowMinutes = now.hour * 60 + now.minute;

    if (startMinutes <= endMinutes) {
      return nowMinutes >= startMinutes && nowMinutes < endMinutes;
    } else {
      // Перетин через північ (напр. 22:00 - 08:00)
      return nowMinutes >= startMinutes || nowMinutes < endMinutes;
    }
  }

  /// Обчислює тривалість тихих годин у хвилинах.
  int _calculateQuietHoursDuration() {
    final startMinutes = _quietStart.hour * 60 + _quietStart.minute;
    final endMinutes = _quietEnd.hour * 60 + _quietEnd.minute;
    if (startMinutes <= endMinutes) {
      return endMinutes - startMinutes;
    } else {
      return (24 * 60) - startMinutes + endMinutes;
    }
  }

  /// Форматує тривалість тихих годин у зручний вигляд.
  String _formatQuietHoursDuration() {
    final minutes = _calculateQuietHoursDuration();
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    if (hours == 0) return '$mins хв';
    if (mins == 0) return '$hours год';
    return '$hours год $mins хв';
  }

  // ─── Actions ──────────────────────────────────────────────────────────

  /// Відправляє тестове сповіщення.
  ///
  /// Показує індикатор завантаження протягом
  /// [_NotificationConstants.testNotificationDefaultDuration] мс,
  /// потім показує toast з тестовим повідомленням.
  void _sendTestNotification() {
    if (_isTestSending) return;

    try {
      setState(() => _isTestSending = true);
      context.haptic();
      developer.log('Sending test notification...', name: _logTag);

      Future.delayed(
        const Duration(milliseconds: _NotificationConstants.testNotificationDefaultDuration),
        () {
          if (mounted) {
            setState(() => _isTestSending = false);
            context.showAppToast(
              '🔔 Нагадування: Час зробити внесок!',
              type: AppToastType.info,
            );
            developer.log('Test notification sent', name: _logTag);
          }
        },
      );
    } catch (e) {
      developer.log('Error sending test notification: $e', name: _logTag);
      if (mounted) {
        setState(() => _isTestSending = false);
        context.showAppToast(
          'Помилка відправки тестового сповіщення',
          type: AppToastType.error,
        );
      }
    }
  }

  /// Позначає всі сповіщення прочитаними.
  ///
  /// Оновлює стан [_notificationHistory] та показує snackBar.
  void _markAllRead() {
    try {
      context.haptic();
      setState(() {
        for (final n in _notificationHistory) {
          n.isRead = true;
        }
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '✅ Усі сповіщення позначені прочитаними',
            style: AppTypography.labelMedium.copyWith(color: AppColorsPS5.textPrimary),
          ),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(milliseconds: 1500),
        ),
      );
      developer.log('All notifications marked as read', name: _logTag);
    } catch (e) {
      developer.log('Error marking all read: $e', name: _logTag);
    }
  }

  /// Видаляє сповіщення за індексом.
  ///
  /// [index] — індекс елемента у [_notificationHistory].
  void _deleteNotification(int index) {
    try {
      if (index < 0 || index >= _notificationHistory.length) {
        developer.log(
          'Invalid notification index: $index',
          name: _logTag,
          level: 900, // WARNING
        );
        return;
      }
      context.haptic();
      final deleted = _notificationHistory[index];
      setState(() => _notificationHistory.removeAt(index));
      developer.log(
        'Deleted notification: ${deleted.title}',
        name: _logTag,
      );
      if (mounted) {
        context.showAppToast(
          'Сповіщення видалено',
          type: AppToastType.info,
        );
      }
    } catch (e) {
      developer.log('Error deleting notification: $e', name: _logTag);
    }
  }

  /// Показує діалог підтвердження очищення історії.
  void _showClearHistoryDialog() {
    context.haptic();
    setState(() => _showClearDialog = true);
  }

  /// Очищає історію сповіщень.
  void _clearHistory() {
    try {
      context.haptic();
      setState(() {
        _notificationHistory.clear();
        _expandedHistoryIndex = -1;
        _showClearDialog = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '🗑️ Історію сповіщень очищено',
            style: AppTypography.labelMedium.copyWith(color: AppColorsPS5.textPrimary),
          ),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(milliseconds: 1200),
        ),
      );
      developer.log('Notification history cleared', name: _logTag);
    } catch (e) {
      developer.log('Error clearing history: $e', name: _logTag);
      if (mounted) {
        setState(() => _showClearDialog = false);
      }
    }
  }

  /// Розгортає/згортає елемент історії.
  void _toggleHistoryExpand(int index) {
    setState(() {
      _expandedHistoryIndex = _expandedHistoryIndex == index ? -1 : index;
    });
  }

  /// Перемикає всі сповіщення одночасно.
  void _toggleAllNotifications(bool value) {
    context.haptic();
    setState(() {
      _dailyReminder = value;
      _autoPaymentReminder = value;
      _motivationMessages = value;
      _challengeReminder = value;
      _appNews = value;
      _streakReminder = value;
      _weeklyReport = value;
    });
    developer.log(
      'All notifications ${value ? "enabled" : "disabled"}',
      name: _logTag,
    );
    if (mounted) {
      context.showAppToast(
        value ? 'Усі сповіщення увімкнено' : 'Усі сповіщення вимкнено',
        type: value ? AppToastType.success : AppToastType.warning,
      );
    }
  }

  /// Встановлює фільтр для історії сповіщень.
  void _setHistoryFilter(String filter) {
    HapticService.lightTap();
    setState(() => _historyFilter = filter);
    developer.log('History filter set to: $filter', name: _logTag);
  }

  /// Отримує звук-стейт для конкретного типу сповіщення.
  bool _getSoundState(String type) {
    switch (type) {
      case 'Щоденне': return _dailySound;
      case 'Автоплатіж': return _paymentSound;
      case 'Мотивація': return _motivationSound;
      case 'Виклики': return _challengeSound;
      case 'Стріки': return _streakSound;
      case 'Звіт': return _weeklySound;
      default: return true;
    }
  }

  /// Перемикає звук для конкретного типу сповіщення.
  void _toggleSound(String type) {
    context.haptic();
    setState(() {
      switch (type) {
        case 'Щоденне': _dailySound = !_dailySound; break;
        case 'Автоплатіж': _paymentSound = !_paymentSound; break;
        case 'Мотивація': _motivationSound = !_motivationSound; break;
        case 'Виклики': _challengeSound = !_challengeSound; break;
        case 'Стріки': _streakSound = !_streakSound; break;
        case 'Звіт': _weeklySound = !_weeklySound; break;
      }
    });
    developer.log(
      'Sound toggled for $type: ${_getSoundState(type)}',
      name: _logTag,
    );
  }

  // ─── Duplicate Suppression ──────────────────────────────────────────

  /// Перевіряє, чи можна відправити сповіщення (запобіжник дублювання).
  ///
  /// Повертає `true`, якщо минуло достатньо часу з останнього сповіщення.
  bool _canSendNotification() {
    if (_lastTestTime == null) return true;
    final elapsed = DateTime.now().difference(_lastTestTime!).inMinutes;
    return elapsed >= _NotificationConstants.duplicateSuppressionMinutes;
  }

  /// Перевіряє, чи можна відправити тестове сповіщення з урахуванням спроб.
  bool _canSendTest() {
    if (_isTestSending) return false;
    if (_testRetryCount >= _NotificationConstants.maxTestRetries) {
      developer.log('Max test retries reached: $_testRetryCount', name: _logTag, level: 900);
      return false;
    }
    return _canSendNotification();
  }

  // ─── Vibration Methods ──────────────────────────────────────────────

  /// Перемикає вібрацію для сповіщень.
  void _toggleVibration(bool value) {
    try {
      setState(() => _vibrationEnabled = value);
      developer.log('Vibration ${value ? "enabled" : "disabled"}', name: _logTag);
      if (mounted) {
        context.showAppToast(
          value ? 'Вібрацію увімкнено' : 'Вібрацію вимкнено',
          type: value ? AppToastType.success : AppToastType.warning,
        );
      }
    } catch (e) {
      developer.log('Error toggling vibration: $e', name: _logTag);
    }
  }

  /// Викликає легку вібрацію залежно від налаштувань.
  void _vibrateIfEnabled() {
    if (_vibrationEnabled) {
      try {
        HapticFeedback.lightImpact();
      } catch (e) {
        developer.log('Error during haptic: $e', name: _logTag);
      }
    }
  }

  // ─── Grouping Methods ──────────────────────────────────────────────

  /// Встановлює режим группування сповіщень.
  void _setGroupingMode(String mode) {
    try {
      if (!['none', 'type', 'app'].contains(mode)) {
        developer.log('Invalid grouping mode: $mode', name: _logTag, level: 900);
        return;
      }
      setState(() => _groupingMode = mode);
      developer.log('Grouping mode set to: $mode', name: _logTag);
    } catch (e) {
      developer.log('Error setting grouping mode: $e', name: _logTag);
    }
  }

  /// Опис поточного режиму группування.
  String get _groupingModeLabel {
    switch (_groupingMode) {
      case 'type': return 'За типом';
      case 'app': return 'За додатком';
      case 'none': return 'Без групування';
      default: return 'За типом';
    }
  }

  // ─── Snooze Methods ────────────────────────────────────────────────

  /// Встановлює тривалість відкладеного сповіщення.
  void _setSnoozeDuration(int minutes) {
    try {
      final clamped = minutes.clamp(0, 60);
      setState(() => _snoozeDuration = clamped);
      developer.log('Snooze duration: $clamped min', name: _logTag);
    } catch (e) {
      developer.log('Error setting snooze: $e', name: _logTag);
    }
  }

  /// Форматує тривалість відкладення.
  String _formatSnoozeDuration() {
    if (_snoozeDuration == 0) return 'Вимкнено';
    if (_snoozeDuration < 60) return '$_snoozeDuration хв';
    return '${_snoozDuration ~/ 60} год ${_snoozeDuration % 60 > 0 ? "${_snoozeDuration % 60} хв" : ""}';
  }

  // ─── Analytics Methods ─────────────────────────────────────────────

  /// Перемикає аналітику сповіщень.
  void _toggleAnalytics(bool value) {
    try {
      setState(() => _analyticsEnabled = value);
      developer.log('Analytics ${value ? "enabled" : "disabled"}', name: _logTag);
    } catch (e) {
      developer.log('Error toggling analytics: $e', name: _logTag);
    }
  }

  /// Перемикає показ розширеної статистики.
  void _toggleStats() {
    try {
      setState(() => _showNotificationStats = !_showNotificationStats);
      developer.log('Notification stats ${_showNotificationStats ? "shown" : "hidden"}', name: _logTag);
    } catch (e) {
      developer.log('Error toggling stats: $e', name: _logTag);
    }
  }

  /// Обчислює відсоток увімкнених звуків.
  int get _soundEnabledPercent {
    final total = 7;
    var enabled = 0;
    if (_dailySound) enabled++;
    if (_paymentSound) enabled++;
    if (_motivationSound) enabled++;
    if (_challengeSound) enabled++;
    if (_streakSound) enabled++;
    if (_weeklySound) enabled++;
    return ((enabled / total) * 100).round();
  }

  /// Обчислює середню кількість сповіщень на день.
  int get _averageNotificationsPerDay {
    var count = 0;
    if (_dailyReminder) count++;
    if (_autoPaymentReminder) count++;
    if (_motivationMessages) count++;
    if (_challengeReminder) count++;
    if (_streakReminder) count++;
    if (_weeklyReport) count += 1; // ~1/7 per day
    if (_appNews) count += 1; // ~1/7 per day
    return count;
  }

  // ─── Additional Computed Properties ──────────────────────────────────────

  /// Кількість прочитаних сповіщень.
  int get _readCount {
    try {
      return _notificationHistory.where((n) => n.isRead).length;
    } catch (e) {
      developer.log('Error calculating read count: $e', name: _logTag);
      return 0;
    }
  }

  /// Чи історія сповіщень порожня.
  bool get _isHistoryEmpty => _notificationHistory.isEmpty;

  /// Чи досягнуто ліміту історії.
  bool get _isHistoryFull =>
      _notificationHistory.length >= _NotificationConstants.maxHistoryItems;

  /// Відсоток прочитаних сповіщень.
  int get _readPercent {
    if (_notificationHistory.isEmpty) return 0;
    return ((_readCount / _notificationHistory.length) * 100).round();
  }

  /// Кількість сповіщень за кожен тип.
  Map<String, int> get _notificationsByType {
    final map = <String, int>{};
    for (final n in _notificationHistory) {
      map[n.type] = (map[n.type] ?? 0) + 1;
    }
    return map;
  }

  /// Найпопулярніший тип сповіщень.
  String get _mostFrequentType {
    if (_notificationsByType.isEmpty) return 'Немає';
    final sorted = _notificationsByType.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return '${sorted.first.key} (${sorted.first.value})';
  }

  /// Чи можна експортувати налаштування.
  bool get _canExport =>
      _notificationHistory.isNotEmpty || !_allNotificationsOff;

  /// Чи активний фільтр історії.
  bool get _isFilterActive => _historyFilter.isNotEmpty;

  /// Опис статусу вібрації.
  String get _vibrationStatus =>
      _vibrationEnabled ? 'Увімкнено' : 'Вимкнено';

  /// Загальна кількість увімкнених звуків.
  int get _enabledSoundsCount {
    var count = 0;
    if (_dailySound) count++;
    if (_paymentSound) count++;
    if (_motivationSound) count++;
    if (_challengeSound) count++;
    if (_streakSound) count++;
    if (_weeklySound) count++;
    return count;
  }

  /// Чи всі звуки увімкнено.
  bool get _allSoundsOn => _enabledSoundsCount == 6;

  /// Чи всі звуки вимкнено.
  bool get _allSoundsOff => _enabledSoundsCount == 0;

  /// Відформатована гучність у відсотках.
  String get _formattedVolume =>
      '${(_notificationVolume * 100).round()}%';

  /// Кількість сторінок в історії.
  int get _historyTotalPages {
    if (_filteredHistory.isEmpty) return 1;
    return (_filteredHistory.length / _NotificationConstants.historyPageSize)
        .ceil();
  }

  /// Чи є наступна сторінка в історії.
  bool get _hasNextHistoryPage =>
      _historyCurrentPage < _historyTotalPages - 1;

  /// Чи є попередня сторінка в історії.
  bool get _hasPreviousHistoryPage => _historyCurrentPage > 0;

  /// Опис поточного звуку.
  String get _currentSoundLabel {
    switch (_selectedSoundName) {
      case 'chime':
        return 'Дзвоник';
      case 'bell':
        return 'Дзвіночок';
      case 'beep':
        return 'Біп';
      case 'melody':
        return 'Мелодія';
      case 'gentle':
        return "М'який";
      case 'urgent':
        return 'Терміновий';
      default:
        return 'Стандартний';
    }
  }

  /// Список унікальних типів сповіщень в історії.
  List<String> get _uniqueTypesInHistory {
    return _notificationHistory.map((n) => n.type).toSet().toList();
  }

  /// Чи повторні нагадування доступні.
  bool get _canEnableRepeatReminders =>
      _dailyReminder || _challengeReminder;

  /// Відформатований інтервал повторних нагадувань.
  String get _formattedRepeatInterval {
    if (_repeatReminderInterval < 60) return '$_repeatReminderInterval хв';
    return '${_repeatReminderInterval ~/ 60} год';
  }

  /// Опис експорт формату.
  String get _exportFormatLabel {
    switch (_exportFormat) {
      case 'json':
        return 'JSON';
      case 'csv':
        return 'CSV';
      default:
        return 'JSON';
    }
  }

  /// Відфільтрована історія з урахуванням пошуку.
  List<_NotificationRecord> get _searchedHistory {
    if (_historySearchQuery.isEmpty) return _filteredHistory;
    return _filteredHistory
        .where((n) =>
            n.title.toLowerCase().contains(_historySearchQuery) ||
            n.body.toLowerCase().contains(_historySearchQuery))
        .toList();
  }

  // ─── Additional Validation Methods ──────────────────────────────────────

  /// Перевіряє, чи час нагадування в межах тихих годин.
  bool _isReminderInQuietHours(TimeOfDay time) {
    if (!_quietHoursEnabled) return false;
    final timeMinutes = time.hour * 60 + time.minute;
    final startMinutes = _quietStart.hour * 60 + _quietStart.minute;
    final endMinutes = _quietEnd.hour * 60 + _quietEnd.minute;
    if (startMinutes <= endMinutes) {
      return timeMinutes >= startMinutes && timeMinutes < endMinutes;
    }
    return timeMinutes >= startMinutes || timeMinutes < endMinutes;
  }

  /// Перевіряє, чи гучність в допустимих межах.
  bool _isVolumeValid(double volume) {
    return volume >= _NotificationConstants.minVolume &&
        volume <= _NotificationConstants.maxVolume;
  }

  /// Перевіряє, чи тривалість відкладення валідна.
  bool _isSnoozeDurationValid(int minutes) {
    return minutes >= _NotificationConstants.minSnoozeDuration &&
        minutes <= _NotificationConstants.maxSnoozeDuration;
  }

  /// Перевіряє, чи пошуковий запит не порожній і не занадто довгий.
  bool _isSearchQueryValid(String query) {
    if (query.isEmpty) return true;
    return query.length <= _NotificationConstants.maxSearchQueryLength;
  }

  /// Перевіряє, чи індекс історії в межах.
  bool _isHistoryIndexValid(int index) {
    return index >= 0 && index < _notificationHistory.length;
  }

  /// Перевіряє, чи тип сповіщення відомий.
  bool _isKnownNotificationType(String type) {
    return _typeIcons.containsKey(type);
  }

  /// Перевіряє, чи фільтр допустимий.
  bool _isFilterValid(String filter) {
    return filter.isEmpty || _historyFilterOptions.contains(filter);
  }

  /// Перевіряє, чи інтервал повторних нагадувань валідний.
  bool _isRepeatIntervalValid(int minutes) {
    return minutes >= _NotificationConstants.minRepeatInterval &&
        minutes <= _NotificationConstants.maxRepeatInterval;
  }

  /// Валідує всі налаштування та повертає список помилок.
  List<String> _validateAllSettings() {
    final errors = <String>[];
    if (_quietHoursEnabled && !_isQuietHoursValid()) {
      errors.add('Час тихих годин невалідний');
    }
    if (!_isVolumeValid(_notificationVolume)) {
      errors.add('Гучність поза межами');
    }
    if (!_isSnoozeDurationValid(_snoozeDuration)) {
      errors.add('Тривалість відкладення невалідна');
    }
    if (_repeatRemindersEnabled && !_canEnableRepeatReminders) {
      errors.add('Увімкніть хоча б одне нагадування для повторів');
    }
    if (!_isRepeatIntervalValid(_repeatReminderInterval)) {
      errors.add('Інтервал повторних нагадувань невалідний');
    }
    if (!_isFilterValid(_historyFilter)) {
      errors.add('Фільтр історії невалідний');
    }
    return errors;
  }

  // ─── Export / Import Helpers ────────────────────────────────────────────

  /// Експортує налаштування у форматі Map.
  Map<String, dynamic> _exportSettings() {
    try {
      developer.log('Exporting notification settings', name: _logTag);
      final settings = <String, dynamic>{
        'dailyReminder': _dailyReminder,
        'autoPaymentReminder': _autoPaymentReminder,
        'motivationMessages': _motivationMessages,
        'motivationFrequency': _motivationFrequency,
        'challengeReminder': _challengeReminder,
        'appNews': _appNews,
        'streakReminder': _streakReminder,
        'weeklyReport': _weeklyReport,
        'dailyTime': '${_dailyTime.hour}:${_dailyTime.minute}',
        'quietHoursEnabled': _quietHoursEnabled,
        'quietStart': '${_quietStart.hour}:${_quietStart.minute}',
        'quietEnd': '${_quietEnd.hour}:${_quietEnd.minute}',
        'vibrationEnabled': _vibrationEnabled,
        'groupingMode': _groupingMode,
        'snoozeDuration': _snoozeDuration,
        'analyticsEnabled': _analyticsEnabled,
        'notificationVolume': _notificationVolume,
        'repeatRemindersEnabled': _repeatRemindersEnabled,
        'repeatReminderInterval': _repeatReminderInterval,
        'ledIndicatorEnabled': _ledIndicatorEnabled,
        'showOnLockScreen': _showOnLockScreen,
        'showContentOnLockScreen': _showContentOnLockScreen,
        'selectedSoundName': _selectedSoundName,
        'dailySound': _dailySound,
        'paymentSound': _paymentSound,
        'motivationSound': _motivationSound,
        'challengeSound': _challengeSound,
        'streakSound': _streakSound,
        'weeklySound': _weeklySound,
        'newsSound': _newsSound,
        'exportedAt': DateTime.now().toIso8601String(),
        'version': '1.0',
      };
      _lastExportTime = DateTime.now();
      developer.log('Settings exported successfully', name: _logTag);
      return settings;
    } catch (e) {
      developer.log('Error exporting settings: $e', name: _logTag);
      return {};
    }
  }

  /// Імпортує налаштування з Map.
  bool _importSettings(Map<String, dynamic> settings) {
    try {
      developer.log('Importing notification settings', name: _logTag);
      if (settings.isEmpty) return false;

      setState(() {
        if (settings.containsKey('dailyReminder'))
          _dailyReminder =
              settings['dailyReminder'] as bool? ?? _dailyReminder;
        if (settings.containsKey('autoPaymentReminder'))
          _autoPaymentReminder =
              settings['autoPaymentReminder'] as bool? ?? _autoPaymentReminder;
        if (settings.containsKey('motivationMessages'))
          _motivationMessages =
              settings['motivationMessages'] as bool? ?? _motivationMessages;
        if (settings.containsKey('motivationFrequency'))
          _motivationFrequency =
              settings['motivationFrequency'] as String? ?? _motivationFrequency;
        if (settings.containsKey('challengeReminder'))
          _challengeReminder =
              settings['challengeReminder'] as bool? ?? _challengeReminder;
        if (settings.containsKey('appNews'))
          _appNews = settings['appNews'] as bool? ?? _appNews;
        if (settings.containsKey('streakReminder'))
          _streakReminder =
              settings['streakReminder'] as bool? ?? _streakReminder;
        if (settings.containsKey('weeklyReport'))
          _weeklyReport =
              settings['weeklyReport'] as bool? ?? _weeklyReport;
        if (settings.containsKey('vibrationEnabled'))
          _vibrationEnabled =
              settings['vibrationEnabled'] as bool? ?? _vibrationEnabled;
        if (settings.containsKey('groupingMode'))
          _groupingMode =
              settings['groupingMode'] as String? ?? _groupingMode;
        if (settings.containsKey('snoozeDuration'))
          _snoozeDuration =
              (settings['snoozeDuration'] as num?)?.toInt() ?? _snoozeDuration;
        if (settings.containsKey('analyticsEnabled'))
          _analyticsEnabled =
              settings['analyticsEnabled'] as bool? ?? _analyticsEnabled;
        if (settings.containsKey('notificationVolume'))
          _notificationVolume =
              (settings['notificationVolume'] as num?)?.toDouble() ??
                  _notificationVolume;
        if (settings.containsKey('repeatRemindersEnabled'))
          _repeatRemindersEnabled =
              settings['repeatRemindersEnabled'] as bool? ??
                  _repeatRemindersEnabled;
        if (settings.containsKey('repeatReminderInterval'))
          _repeatReminderInterval =
              (settings['repeatReminderInterval'] as num?)?.toInt() ??
                  _repeatReminderInterval;
        if (settings.containsKey('ledIndicatorEnabled'))
          _ledIndicatorEnabled =
              settings['ledIndicatorEnabled'] as bool? ?? _ledIndicatorEnabled;
        if (settings.containsKey('showOnLockScreen'))
          _showOnLockScreen =
              settings['showOnLockScreen'] as bool? ?? _showOnLockScreen;
        if (settings.containsKey('showContentOnLockScreen'))
          _showContentOnLockScreen =
              settings['showContentOnLockScreen'] as bool? ??
                  _showContentOnLockScreen;
        if (settings.containsKey('selectedSoundName'))
          _selectedSoundName =
              settings['selectedSoundName'] as String? ?? _selectedSoundName;
      });

      developer.log('Settings imported successfully', name: _logTag);
      return true;
    } catch (e) {
      developer.log('Error importing settings: $e', name: _logTag);
      return false;
    }
  }

  /// Генерує CSV-рядок з історії сповіщень.
  String _exportHistoryAsCsv() {
    try {
      if (_notificationHistory.isEmpty) return '';
      final buffer = StringBuffer();
      buffer.writeln('ID,Title,Body,Time,Type,IsRead');
      for (final n in _notificationHistory) {
        final escapedTitle = n.title.replaceAll(',', ';');
        final escapedBody = n.body.replaceAll(',', ';');
        buffer.writeln(
            '${n.id},$escapedTitle,$escapedBody,${n.time},${n.type},${n.isRead}');
      }
      developer.log(
          'History exported as CSV (${_notificationHistory.length} items)',
          name: _logTag);
      return buffer.toString();
    } catch (e) {
      developer.log('Error exporting history CSV: $e', name: _logTag);
      return '';
    }
  }

  /// Генерує JSON-рядок з історії сповіщень.
  String _exportHistoryAsJson() {
    try {
      if (_notificationHistory.isEmpty) return '[]';
      final list = _notificationHistory
          .map((n) => {
                'id': n.id,
                'title': n.title,
                'body': n.body,
                'time': n.time,
                'type': n.type,
                'isRead': n.isRead,
              })
          .toList();
      developer.log(
          'History exported as JSON (${list.length} items)', name: _logTag);
      return list.toString();
    } catch (e) {
      developer.log('Error exporting history JSON: $e', name: _logTag);
      return '[]';
    }
  }

  // ─── Batch Operations ──────────────────────────────────────────────────

  /// Пакетне позначення прочитаним за типом.
  void _markTypeAsRead(String type) {
    try {
      context.haptic();
      var count = 0;
      setState(() {
        for (final n in _notificationHistory) {
          if (n.type == type && !n.isRead) {
            n.isRead = true;
            count++;
          }
        }
      });
      if (count > 0 && mounted) {
        context.showAppToast(
          '$count сповіщень типу «$type» позначено прочитаними',
          type: AppToastType.success,
        );
      }
      developer.log(
          'Marked $count notifications of type $type as read', name: _logTag);
    } catch (e) {
      developer.log('Error in batch mark read: $e', name: _logTag);
    }
  }

  /// Пакетне видалення за типом.
  void _deleteByType(String type) {
    try {
      context.haptic();
      final initialLength = _notificationHistory.length;
      setState(() {
        _notificationHistory.removeWhere((n) => n.type == type);
      });
      final deleted = initialLength - _notificationHistory.length;
      if (deleted > 0 && mounted) {
        context.showAppToast(
          'Видалено $deleted сповіщень типу «$type»',
          type: AppToastType.info,
        );
      }
      developer.log(
          'Deleted $deleted notifications of type $type', name: _logTag);
    } catch (e) {
      developer.log('Error in batch delete: $e', name: _logTag);
    }
  }

  /// Пакетне видалення прочитаних сповіщень.
  void _deleteReadNotifications() {
    try {
      context.haptic();
      final initialLength = _notificationHistory.length;
      setState(() {
        _notificationHistory.removeWhere((n) => n.isRead);
      });
      final deleted = initialLength - _notificationHistory.length;
      if (mounted) {
        context.showAppToast(
          'Видалено $deleted прочитаних сповіщень',
          type: AppToastType.info,
        );
      }
      developer.log('Deleted $deleted read notifications', name: _logTag);
    } catch (e) {
      developer.log('Error deleting read notifications: $e', name: _logTag);
    }
  }

  /// Пакетне перемикання звуків для всіх типів.
  void _toggleAllSounds(bool value) {
    try {
      context.haptic();
      setState(() {
        _dailySound = value;
        _paymentSound = value;
        _motivationSound = value;
        _challengeSound = value;
        _streakSound = value;
        _weeklySound = value;
        _newsSound = value;
      });
      developer.log('All sounds ${value ? "enabled" : "disabled"}', name: _logTag);
      if (mounted) {
        context.showAppToast(
          value ? 'Усі звуки увімкнено' : 'Усі звуки вимкнено',
          type: value ? AppToastType.success : AppToastType.warning,
        );
      }
    } catch (e) {
      developer.log('Error toggling all sounds: $e', name: _logTag);
    }
  }

  /// Пакетне увімкнення високого пріоритету для всіх.
  void _setAllPriorityHigh() {
    try {
      context.haptic();
      setState(() {
        _dailyPriority = 'Високий';
        _challengePriority = 'Високий';
        _newsPriority = 'Високий';
        _streakPriority = 'Високий';
      });
      developer.log('All priorities set to high', name: _logTag);
      if (mounted) {
        context.showAppToast(
            'Усі пріоритети — високі', type: AppToastType.success);
      }
    } catch (e) {
      developer.log('Error setting all priorities: $e', name: _logTag);
    }
  }

  /// Пакетне скидання всіх пріоритетів до нормального.
  void _setAllPriorityNormal() {
    try {
      context.haptic();
      setState(() {
        _dailyPriority = 'Нормальний';
        _challengePriority = 'Нормальний';
        _newsPriority = 'Нормальний';
        _streakPriority = 'Нормальний';
      });
      developer.log('All priorities set to normal', name: _logTag);
      if (mounted) {
        context.showAppToast(
            'Усі пріоритети — нормальні', type: AppToastType.info);
      }
    } catch (e) {
      developer.log('Error setting all priorities: $e', name: _logTag);
    }
  }

  // ─── Notification Scheduling Helpers ────────────────────────────────────

  /// Обчислює наступний час нагадування.
  DateTime _computeNextReminderTime() {
    final now = DateTime.now();
    var scheduled = DateTime(
        now.year, now.month, now.day, _dailyTime.hour, _dailyTime.minute);
    if (scheduled.isBefore(now) || scheduled.isAtSameMomentAs(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }

  /// Обчислює час до наступного нагадування.
  Duration _timeUntilNextReminder() {
    return _computeNextReminderTime().difference(DateTime.now());
  }

  /// Форматує час до наступного нагадування.
  String _formatTimeUntilNextReminder() {
    final duration = _timeUntilNextReminder();
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    if (hours > 24) return '${hours ~/ 24} дн ${hours % 24} год';
    if (hours > 0) return '$hours год $mins хв';
    return '$mins хв';
  }

  /// Обчислює розклад сповіщень на тиждень.
  List<Map<String, dynamic>> _computeWeeklySchedule() {
    final schedule = <Map<String, dynamic>>[];
    final days = ['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Нд'];
    for (var i = 0; i < _NotificationConstants.weeklyScheduleDays; i++) {
      final count = <String, int>{};
      if (_dailyReminder) count['Щоденне'] = 1;
      if (_weeklyReport && i == 6) count['Звіт'] = 1;
      if (_motivationMessages) {
        if (_motivationFrequency == 'Щоденно') count['Мотивація'] = 1;
        if (_motivationFrequency == 'Щотижня' && i == 0)
          count['Мотивація'] = 1;
        if (_motivationFrequency == 'Щомісяця' && i == 0)
          count['Мотивація'] = 1;
      }
      schedule.add({
        'day': days[i],
        'notifications': count,
        'total': count.values.fold(0, (sum, v) => sum + v),
      });
    }
    return schedule;
  }

  /// Обчислює кількість сповіщень за тиждень.
  int _computeWeeklyTotal() {
    final schedule = _computeWeeklySchedule();
    return schedule.fold(0, (sum, day) => sum + (day['total'] as int));
  }

  /// Обчислює кількість сповіщень за місяць (приблизно).
  int _computeMonthlyEstimate() {
    return _computeWeeklyTotal() * 4;
  }

  /// Перевіряє, чи час підходить для відправки сповіщення.
  bool _isGoodTimeToSend() {
    if (_isCurrentlyQuietHours()) return false;
    if (_allNotificationsOff) return false;
    return true;
  }

  /// Обчислює оптимальний час для нагадування.
  String _suggestOptimalReminderTime() {
    final quietEndMinutes = _quietEnd.hour * 60 + _quietEnd.minute;
    return '${(quietEndMinutes ~/ 60).toString().padLeft(2, '0')}:${(quietEndMinutes % 60).toString().padLeft(2, '0')}';
  }

  /// Форматує розклад у зручний вигляд.
  String _formatScheduleSummary() {
    final weekly = _computeWeeklyTotal();
    final monthly = _computeMonthlyEstimate();
    return '~$weekly на тиждень · ~$monthly на місяць';
  }

  // ─── Theme-Aware Color Helpers ──────────────────────────────────────────

  /// Повертає фоновий колір для картки з врахуванням теми.
  Color _themedCardColor(bool isDark) {
    return isDark ? AppColorsPS5.card : AppColorsMonitor.card;
  }

  /// Повертає колір тексту з врахуванням теми.
  Color _themedTextColor(bool isDark) {
    return isDark ? AppColorsPS5.textPrimary : AppColorsMonitor.textPrimary;
  }

  /// Повертає колір вторинного тексту з врахуванням теми.
  Color _themedSubColor(bool isDark) {
    return isDark ? AppColorsPS5.textSecondary : AppColorsMonitor.textSecondary;
  }

  /// Повертає акцентний колір з врахуванням теми.
  Color _themedAccent(bool isDark) {
    return isDark ? AppColorsPS5.accent : AppColorsMonitor.accent;
  }

  /// Повертає колір фону з врахуванням теми.
  Color _themedBackground(bool isDark) {
    return isDark ? AppColorsPS5.background : AppColorsMonitor.background;
  }

  /// Повертає колір рамки з врахуванням теми.
  Color _themedBorderColor(bool isDark) {
    return isDark ? AppColorsPS5.border : AppColorsMonitor.border;
  }

  /// Повертає кольори для стейт-індикатора з врахуванням теми.
  Color _themedStatusColor(bool isDark, bool isActive) {
    if (isActive) return _themedAccent(isDark);
    return isDark ? AppColorsPS5.textHint : AppColorsMonitor.textHint;
  }

  /// Повертає колір для badge з врахуванням теми.
  Color _themedBadgeColor(bool isDark) {
    return _themedAccent(isDark).withOpacity(0.08);
  }

  /// Повертає колір рамки badge з врахуванням теми.
  Color _themedBadgeBorderColor(bool isDark) {
    return _themedAccent(isDark).withOpacity(0.2);
  }

  /// Повертає кольорову схему для секції карток.
  _ThemedColors _getThemedColors(bool isDark) {
    return _ThemedColors(
      cardColor: _themedCardColor(isDark),
      textColor: _themedTextColor(isDark),
      subColor: _themedSubColor(isDark),
      accent: _themedAccent(isDark),
      background: _themedBackground(isDark),
      borderColor: _themedBorderColor(isDark),
    );
  }

  // ─── Additional Private Helper Methods ─────────────────────────────────

  /// Генерує семантичний лейбл для перемикача сповіщень.
  String _toggleSemanticLabel(String title, bool value) {
    return '$title: ${value ? "увімкнено" : "вимкнено"}';
  }

  /// Генерує семантичний лейбл для кнопки дії.
  String _actionSemanticLabel(String action) {
    return 'Дія: $action';
  }

  /// Повертає колір для рівня пріоритету.
  Color _priorityColor(String priority) {
    switch (priority) {
      case 'Високий':
        return AppColorsPS5.error;
      case 'Нормальний':
        return AppColorsPS5.warning;
      case 'Низький':
        return AppColorsPS5.textSecondary;
      default:
        return AppColorsPS5.textHint;
    }
  }

  /// Повертає іконку для рівня пріоритету.
  IconData _priorityIcon(String priority) {
    switch (priority) {
      case 'Високий':
        return Icons.priority_high_rounded;
      case 'Нормальний':
        return Icons.remove_circle_outline_rounded;
      case 'Низький':
        return Icons.low_priority_rounded;
      default:
        return Icons.notifications_none_rounded;
    }
  }

  /// Обчислює зведену статистику сповіщень.
  Map<String, dynamic> _computeNotificationSummary() {
    try {
      final total = _notificationHistory.length;
      final unread = _notificationHistory.where((n) => !n.isRead).length;
      final read = total - unread;
      final byType = <String, int>{};
      for (final n in _notificationHistory) {
        byType[n.type] = (byType[n.type] ?? 0) + 1;
      }
      return {
        'total': total,
        'unread': unread,
        'read': read,
        'byType': byType,
        'enabledPercent': _notificationsEnabledPercent,
        'soundPercent': _soundEnabledPercent,
        'avgPerDay': _averageNotificationsPerDay,
      };
    } catch (e) {
      developer.log('Error computing summary: $e', name: _logTag);
      return {
        'total': 0,
        'unread': 0,
        'read': 0,
        'byType': <String, int>{}
      };
    }
  }

  /// Форматує зведену статистику для відображення.
  String _formatSummary() {
    final s = _computeNotificationSummary();
    return 'Всього: ${s['total']} · Непрочитаних: ${s['unread']} · '
        'Увімкнено: ${s['enabledPercent']}% · Звук: ${s['soundPercent']}%';
  }

  /// Встановлює пошуковий запит для історії.
  void _setHistorySearch(String query) {
    final trimmed = query.trim();
    if (!_isSearchQueryValid(trimmed)) {
      developer.log('Search query too long', name: _logTag, level: 900);
      return;
    }
    setState(() => _historySearchQuery = trimmed.toLowerCase());
    developer.log('History search: $trimmed', name: _logTag);
  }

  /// Скидає пошуковий запит.
  void _clearHistorySearch() {
    setState(() => _historySearchQuery = '');
    developer.log('History search cleared', name: _logTag);
  }

  /// Встановлює гучність з валідацією.
  void _setVolume(double volume) {
    final clamped = volume.clamp(
        _NotificationConstants.minVolume, _NotificationConstants.maxVolume);
    setState(() => _notificationVolume = clamped);
    developer.log('Volume set: ${_formattedVolume}', name: _logTag);
  }

  /// Перемикає секцію розкладу.
  void _toggleScheduleSection() {
    setState(() => _showScheduleSection = !_showScheduleSection);
    developer.log(
        'Schedule section ${_showScheduleSection ? "shown" : "hidden"}',
        name: _logTag);
  }

  /// Перемикає розширені налаштування звуку.
  void _toggleAdvancedSoundSection() {
    setState(
        () => _showAdvancedSoundSection = !_showAdvancedSoundSection);
    developer.log(
        'Advanced sound section ${_showAdvancedSoundSection ? "shown" : "hidden"}',
        name: _logTag);
  }

  /// Перемикає секцію повторних нагадувань.
  void _toggleRepeatSection() {
    setState(() => _showRepeatSection = !_showRepeatSection);
    developer.log(
        'Repeat section ${_showRepeatSection ? "shown" : "hidden"}',
        name: _logTag);
  }

  /// Скидає всі налаштування до значень за замовчуванням.
  void _resetNotificationSettings() {
    try {
      context.haptic();
      setState(() {
        _dailyReminder = true;
        _autoPaymentReminder = true;
        _motivationMessages = false;
        _motivationFrequency = 'Щотижня';
        _challengeReminder = true;
        _appNews = false;
        _streakReminder = true;
        _weeklyReport = true;
        _dailySound = true;
        _paymentSound = true;
        _motivationSound = true;
        _challengeSound = true;
        _newsSound = false;
        _streakSound = true;
        _weeklySound = true;
        _quietHoursEnabled = false;
        _quietStart = _NotificationConstants.defaultQuietStart;
        _quietEnd = _NotificationConstants.defaultQuietEnd;
        _vibrationEnabled = true;
        _groupingMode = 'type';
        _snoozeDuration = 10;
        _analyticsEnabled = true;
        _historyFilter = '';
        _notificationVolume = 0.8;
        _repeatRemindersEnabled = false;
        _repeatReminderInterval = 30;
        _ledIndicatorEnabled = true;
        _showOnLockScreen = true;
        _showContentOnLockScreen = true;
        _selectedSoundName = 'default';
        _historySearchQuery = '';
      });
      developer.log('Notification settings reset to defaults', name: _logTag);
      if (mounted) {
        context.showAppToast('Налаштування скинуто', type: AppToastType.info);
      }
    } catch (e) {
      developer.log('Error resetting notification settings: $e', name: _logTag);
    }
  }

  /// Повертає унікальний ID для нового сповіщення.
  String _generateNotificationId() {
    return '${DateTime.now().millisecondsSinceEpoch}';
  }

  /// Додає тестовий запис в історію.
  void _addTestRecordToHistory({
    required String title,
    required String body,
    required String type,
  }) {
    try {
      if (_isHistoryFull) {
        developer.log('History full, removing oldest', name: _logTag);
        _notificationHistory.removeAt(0);
      }
      final now = TimeOfDay.now();
      final record = _NotificationRecord(
        id: _generateNotificationId(),
        title: title,
        body: body,
        time: _formatTime(now),
        type: type,
        isRead: false,
      );
      setState(() => _notificationHistory.add(record));
      developer.log('Added test record: ${record.id}', name: _logTag);
    } catch (e) {
      developer.log('Error adding test record: $e', name: _logTag);
    }
  }

  // ─── Additional Widget Builders ─────────────────────────────────────────

  /// Будує секцію розкладу сповіщень на тиждень.
  Widget _buildWeeklySchedulePreview(
      Color textColor,
      Color subColor,
      Color cardColor,
      Color borderColor,
      Color accent) {
    final schedule = _computeWeeklySchedule();
    return Container(
      padding: const EdgeInsets.all(Spacing.base),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(Radii.lg),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.calendar_view_week_rounded,
                  color: accent, size: 20),
              const SizedBox(width: Spacing.sm),
              Text('Розклад на тиждень',
                  style:
                      AppTypography.labelLarge.copyWith(color: textColor)),
              const Spacer(),
              Text('~$_computeWeeklyTotal() сповіщень',
                  style: AppTypography.labelSmall.copyWith(color: accent)),
            ],
          ),
          const SizedBox(height: Spacing.sm),
          ...schedule.map((day) {
            final total = day['total'] as int;
            final dayLabel = day['day'] as String;
            final notifs = day['notifications'] as Map<String, int>;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                children: [
                  SizedBox(
                    width: 32,
                    child: Text(
                      dayLabel,
                      style: AppTypography.labelSmall.copyWith(
                        color: total > 0 ? textColor : subColor.withOpacity(0.5),
                        fontWeight:
                            total > 0 ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ),
                  ),
                  const SizedBox(width: Spacing.sm),
                  Expanded(
                    child: total > 0
                        ? Wrap(
                            spacing: 4,
                            runSpacing: 2,
                            children: notifs.entries.map((e) {
                              final typeColor =
                                  _typeColors[e.key] ?? accent;
                              return Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: typeColor.withOpacity(0.12),
                                  borderRadius:
                                      BorderRadius.circular(Radii.xs),
                                ),
                                child: Text(
                                  '${e.key} ×${e.value}',
                                  style: AppTypography.caption
                                      .copyWith(
                                          color: typeColor,
                                          fontSize: 9),
                                ),
                              );
                            }).toList(),
                          )
                        : Text('—',
                            style: AppTypography.labelSmall
                                .copyWith(
                                    color: subColor
                                        .withOpacity(0.3))),
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: Spacing.sm),
          Text(
            _formatScheduleSummary(),
            style: AppTypography.labelSmall
                .copyWith(color: subColor.withOpacity(0.6)),
          ),
        ],
      ),
    ).animate().fade(delay: 150.ms, duration: 300.ms);
  }

  /// Будує theme-aware картку з прогресом увімкнених сповіщень.
  Widget _buildThemeAwareProgressCard(bool isDark) {
    final colors = _getThemedColors(isDark);
    final progress = _notificationsEnabledPercent / 100.0;
    return Container(
      padding: const EdgeInsets.all(Spacing.base),
      decoration: BoxDecoration(
        color: colors.cardColor,
        borderRadius: BorderRadius.circular(Radii.lg),
        border: Border.all(color: colors.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Прогрес налаштувань',
              style: AppTypography.labelLarge
                  .copyWith(color: colors.textColor)),
          const SizedBox(height: Spacing.sm),
          ClipRRect(
            borderRadius: BorderRadius.circular(Radii.sm),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: colors.accent.withOpacity(0.1),
              valueColor:
                  AlwaysStoppedAnimation<Color>(colors.accent),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: Spacing.sm),
          Text(
            '$_enabledChannelsCount з ${_notificationChannels.length} каналів (${_notificationsEnabledPercent}%)',
            style: AppTypography.labelSmall
                .copyWith(color: colors.subColor),
          ),
        ],
      ),
    ).animate().fade(delay: 200.ms, duration: 300.ms);
  }

  /// Будує секцію розширеного керування звуком.
  Widget _buildAdvancedSoundSection(
      Color cardColor,
      Color borderColor,
      Color textColor,
      Color subColor,
      Color accent) {
    return Container(
      padding: const EdgeInsets.all(Spacing.base),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(Radii.lg),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.music_note_rounded, color: accent, size: 20),
              const SizedBox(width: Spacing.sm),
              Text('Розширені налаштування звуку',
                  style: AppTypography.labelLarge
                      .copyWith(color: textColor)),
            ],
          ),
          const SizedBox(height: Spacing.md),
          // Volume slider
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Гучність',
                  style: AppTypography.labelSmall
                      .copyWith(color: textColor)),
              Text(_formattedVolume,
                  style: AppTypography.labelSmall.copyWith(
                      color: accent, fontWeight: FontWeight.w600)),
            ],
          ),
          Slider(
            value: _notificationVolume,
            min: _NotificationConstants.minVolume,
            max: _NotificationConstants.maxVolume,
            divisions: 10,
            onChanged: (v) {
              _setVolume(v);
              _vibrateIfEnabled();
            },
            activeColor: accent,
          ),
          const SizedBox(height: Spacing.md),
          // Sound selection
          Text('Звук сповіщення',
              style: AppTypography.labelSmall.copyWith(
                  color: subColor, fontWeight: FontWeight.w600)),
          const SizedBox(height: Spacing.xs),
          Wrap(
            spacing: Spacing.sm,
            runSpacing: Spacing.sm,
            children: _availableSounds.map((sound) {
              final isSelected = _selectedSoundName == sound;
              final label =
                  sound == 'default' ? 'Стандартний' : sound;
              return GestureDetector(
                onTap: () {
                  HapticService.lightTap();
                  setState(() => _selectedSoundName = sound);
                  developer.log('Sound selected: $sound', name: _logTag);
                },
                child: AnimatedContainer(
                  duration:
                      const Duration(milliseconds: _NotificationConstants.buttonAnimationDuration),
                  padding: const EdgeInsets.symmetric(
                      horizontal: Spacing.sm, vertical: Spacing.xs),
                  decoration: BoxDecoration(
                    color: isSelected ? accent : Colors.transparent,
                    borderRadius: BorderRadius.circular(Radii.xl),
                    border: Border.all(
                        color: isSelected ? accent : borderColor),
                  ),
                  child: Text(
                    label,
                    style: AppTypography.labelSmall.copyWith(
                      color: isSelected ? Colors.white : subColor,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: Spacing.md),
          // All sounds toggle
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Усі звуки',
                  style: AppTypography.labelSmall
                      .copyWith(color: textColor)),
              Text(
                _allSoundsOn
                    ? 'Усі увімкнено'
                    : (_allSoundsOff
                        ? 'Усі вимкнено'
                        : '$_enabledSoundsCount/6'),
                style: AppTypography.labelSmall
                    .copyWith(color: accent),
              ),
            ],
          ),
          const SizedBox(height: Spacing.xs),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _toggleAllSounds(true),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: accent,
                    side: BorderSide(color: accent),
                    shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(Radii.sm)),
                  ),
                  child: Text('Увімкнути все',
                      style: AppTypography.labelSmall),
                ),
              ),
              const SizedBox(width: Spacing.sm),
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _toggleAllSounds(false),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColorsPS5.error,
                    side: BorderSide(color: AppColorsPS5.error),
                    shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(Radii.sm)),
                  ),
                  child: Text('Вимкнути все',
                      style: AppTypography.labelSmall),
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fade(delay: 100.ms, duration: 300.ms);
  }

  /// Будує theme-aware секцію експорту/імпорту.
  Widget _buildThemeAwareExportSection(bool isDark) {
    final colors = _getThemedColors(isDark);
    return Container(
      padding: const EdgeInsets.all(Spacing.base),
      decoration: BoxDecoration(
        color: colors.cardColor,
        borderRadius: BorderRadius.circular(Radii.lg),
        border: Border.all(color: colors.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.data_object_rounded,
                  color: colors.accent, size: 20),
              const SizedBox(width: Spacing.sm),
              Text('Експорт / Імпорт',
                  style: AppTypography.labelLarge
                      .copyWith(color: colors.textColor)),
            ],
          ),
          const SizedBox(height: Spacing.md),
          Text(
              'Експортуйте налаштування для резервного копіювання',
              style: AppTypography.labelSmall
                  .copyWith(color: colors.subColor)),
          const SizedBox(height: Spacing.sm),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _canExport
                      ? () {
                          final exported = _exportSettings();
                          developer.log(
                              'Export triggered: ${exported.length} keys',
                              name: _logTag);
                          if (mounted) {
                            context.showAppToast(
                              'Налаштування експортовано (${exported.length} параметрів)',
                              type: AppToastType.success,
                            );
                          }
                        }
                      : null,
                  icon:
                      const Icon(Icons.upload_rounded, size: 18),
                  label: Text('Експорт',
                      style: AppTypography.labelMedium),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: colors.accent,
                    side: BorderSide(
                        color: colors.accent.withOpacity(0.5)),
                    shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(Radii.md)),
                  ),
                ),
              ),
              const SizedBox(width: Spacing.sm),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    developer.log(
                        'Import triggered (demo)', name: _logTag);
                    if (mounted) {
                      context.showAppToast(
                        'Функція імпорту скоро буде доступна',
                        type: AppToastType.info,
                      );
                    }
                  },
                  icon:
                      const Icon(Icons.download_rounded, size: 18),
                  label: Text('Імпорт',
                      style: AppTypography.labelMedium),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: colors.accent,
                    side: BorderSide(
                        color: colors.accent.withOpacity(0.5)),
                    shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(Radii.md)),
                  ),
                ),
              ),
            ],
          ),
          if (_lastExportTime != null) ...[
            const SizedBox(height: Spacing.sm),
            Text(
              'Останній експорт: ${_lastExportTime.toString().substring(0, 16)}',
              style: AppTypography.caption.copyWith(
                  color: colors.subColor.withOpacity(0.6),
                  fontSize: 9),
            ),
          ],
        ],
      ),
    ).animate().fade(delay: 200.ms, duration: 300.ms);
  }

  /// Будує theme-aware секцію повторних нагадувань.
  Widget _buildThemeAwareRepeatSection(bool isDark) {
    final colors = _getThemedColors(isDark);
    return Container(
      padding: const EdgeInsets.all(Spacing.base),
      decoration: BoxDecoration(
        color: colors.cardColor,
        borderRadius: BorderRadius.circular(Radii.lg),
        border: Border.all(color: colors.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SwitchListTile.adaptive(
            value: _repeatRemindersEnabled,
            onChanged: _canEnableRepeatReminders
                ? (v) {
                    setState(
                        () => _repeatRemindersEnabled = v);
                    developer.log(
                        'Repeat reminders ${v ? "enabled" : "disabled"}',
                        name: _logTag);
                  }
                : null,
            activeColor: colors.accent,
            contentPadding: EdgeInsets.zero,
            secondary: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: colors.accent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(Radii.md),
              ),
              child: Icon(Icons.repeat_rounded,
                  color: colors.accent, size: 22),
            ),
            title: Text('Повторні нагадування',
                style: AppTypography.bodyMedium
                    .copyWith(color: colors.textColor)),
            subtitle: Text(
              _repeatRemindersEnabled
                  ? 'Повторювати кожні $_formattedRepeatInterval'
                  : (!_canEnableRepeatReminders
                      ? 'Увімкніть нагадування'
                      : 'Вимкнено'),
              style: AppTypography.bodySmall
                  .copyWith(color: colors.subColor),
            ),
          ),
          if (_repeatRemindersEnabled) ...[
            const SizedBox(height: Spacing.sm),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Інтервал',
                    style: AppTypography.labelSmall
                        .copyWith(color: colors.textColor)),
                Text(_formattedRepeatInterval,
                    style: AppTypography.labelSmall.copyWith(
                        color: colors.accent,
                        fontWeight: FontWeight.w600)),
              ],
            ),
            Slider(
              value: _repeatReminderInterval.toDouble(),
              min: _NotificationConstants.minRepeatInterval
                  .toDouble(),
              max: _NotificationConstants.maxRepeatInterval
                  .toDouble(),
              divisions: (_NotificationConstants.maxRepeatInterval -
                      _NotificationConstants.minRepeatInterval) ~/
                  5,
              onChanged: (v) => setState(
                  () => _repeatReminderInterval = v.round()),
              activeColor: colors.accent,
            ),
          ],
        ],
      ),
    ).animate().fade(delay: 100.ms, duration: 300.ms);
  }

  /// Будує theme-aware секцію batch-операцій.
  Widget _buildThemeAwareBatchSection(bool isDark) {
    final colors = _getThemedColors(isDark);
    return Container(
      padding: const EdgeInsets.all(Spacing.base),
      decoration: BoxDecoration(
        color: colors.cardColor,
        borderRadius: BorderRadius.circular(Radii.lg),
        border: Border.all(color: colors.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.playlist_add_check_rounded,
                  color: colors.accent, size: 20),
              const SizedBox(width: Spacing.sm),
              Text('Пакетні операції',
                  style: AppTypography.labelLarge
                      .copyWith(color: colors.textColor)),
            ],
          ),
          const SizedBox(height: Spacing.md),
          // Batch mark read by type
          ..._uniqueTypesInHistory.map((type) {
            final icon = _typeIcons[type] ?? Icons.notifications_rounded;
            final typeColor = _typeColors[type] ?? colors.accent;
            return Padding(
              padding: const EdgeInsets.only(bottom: Spacing.xs),
              child: OutlinedButton.icon(
                onPressed: () => _markTypeAsRead(type),
                icon: Icon(icon, color: typeColor, size: 16),
                label: Text('Прочитати «$type»',
                    style: AppTypography.labelSmall
                        .copyWith(color: colors.textColor)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: typeColor,
                  side: BorderSide(color: typeColor.withOpacity(0.4)),
                  shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(Radii.sm)),
                  minimumSize: const Size(double.infinity, 36),
                ),
              ),
            );
          }),
          const SizedBox(height: Spacing.sm),
          // Batch delete read
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _readCount > 0
                  ? _deleteReadNotifications
                  : null,
              icon: Icon(Icons.delete_sweep_rounded,
                  color: AppColorsPS5.error, size: 18),
              label: Text(
                  'Видалити прочитані ($_readCount)',
                  style: AppTypography.labelSmall.copyWith(
                      color: _readCount > 0
                          ? AppColorsPS5.error
                          : colors.subColor)),
              style: OutlinedButton.styleFrom(
                side: BorderSide(
                    color: AppColorsPS5.error.withOpacity(0.3)),
                shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(Radii.md)),
              ),
            ),
          ),
          const SizedBox(height: Spacing.xs),
          // Priority batch
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _setAllPriorityHigh,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColorsPS5.error,
                    side: BorderSide(
                        color: AppColorsPS5.error.withOpacity(0.3)),
                    shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(Radii.sm)),
                  ),
                  child: Text('Усі — високі',
                      style: AppTypography.labelSmall),
                ),
              ),
              const SizedBox(width: Spacing.sm),
              Expanded(
                child: OutlinedButton(
                  onPressed: _setAllPriorityNormal,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: colors.accent,
                    side: BorderSide(
                        color: colors.accent.withOpacity(0.3)),
                    shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(Radii.sm)),
                  ),
                  child: Text('Усі — нормальні',
                      style: AppTypography.labelSmall),
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fade(delay: 100.ms, duration: 300.ms);
  }

  /// Будує theme-aware інформаційну картку з лічильниками.
  Widget _buildThemeAwareCountersCard(bool isDark) {
    final colors = _getThemedColors(isDark);
    return Container(
      padding: const EdgeInsets.all(Spacing.base),
      decoration: BoxDecoration(
        color: colors.cardColor,
        borderRadius: BorderRadius.circular(Radii.lg),
        border: Border.all(color: colors.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Лічильники',
              style: AppTypography.labelLarge
                  .copyWith(color: colors.textColor)),
          const SizedBox(height: Spacing.sm),
          _buildStatInfoRow(
              'Всього в історії',
              '${_notificationHistory.length}',
              Icons.inventory_2_outlined,
              colors.accent,
              colors.subColor),
          _buildStatInfoRow(
              'Прочитаних', '$_readCount ($_readPercent%)',
              Icons.done_all_rounded, AppColorsPS5.success,
              colors.subColor),
          _buildStatInfoRow('Непрочитаних', '$_unreadCount',
              Icons.mark_email_unread_rounded,
              AppColorsPS5.error, colors.subColor),
          _buildStatInfoRow(
              'Тестів за сесію', '$_totalTestSent',
              Icons.send_rounded, colors.accent, colors.subColor),
          _buildStatInfoRow(
              'Відкрито', '$_totalOpened',
              Icons.touch_app_rounded, AppColorsPS5.success,
              colors.subColor),
          _buildStatInfoRow(
              'Відхилено', '$_totalDismissed',
              Icons.swipe_rounded, AppColorsPS5.warning,
              colors.subColor),
          _buildStatInfoRow(
              'Найчастіший тип', _mostFrequentType,
              Icons.bar_chart_rounded, colors.accent,
              colors.subColor),
        ],
      ),
    ).animate().fade(delay: 150.ms, duration: 300.ms);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final textColor = isDark ? AppColorsPS5.textPrimary : AppColorsMonitor.textPrimary;
    final subColor = isDark ? AppColorsPS5.textSecondary : AppColorsMonitor.textSecondary;
    final cardColor = isDark ? AppColorsPS5.card : AppColorsMonitor.card;
    final borderColor = isDark ? AppColorsPS5.border : AppColorsMonitor.border;
    final accent = isDark ? AppColorsPS5.accent : AppColorsMonitor.accent;

    return Scaffold(
      backgroundColor: isDark ? AppColorsPS5.background : AppColorsMonitor.background,
      appBar: AppBar(
        title: const Text('Сповіщення'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: textColor,
        actions: [
          // Unread badge
          if (_unreadCount > 0)
            Padding(
              padding: const EdgeInsets.only(right: Spacing.sm),
              child: Chip(
                avatar: const Icon(Icons.mark_email_unread_rounded, size: 14),
                label: Text(
                  '${_unreadCount > _NotificationConstants.unreadBadgeMax ? "${_NotificationConstants.unreadBadgeMax}+" : _unreadCount}',
                  style: AppTypography.labelSmall.copyWith(color: accent),
                ),
                backgroundColor: accent.withOpacity(0.08),
                side: BorderSide(color: accent.withOpacity(0.2)),
                visualDensity: VisualDensity.compact,
              ),
            ),
        ],
      ),
      body: _buildBody(textColor, subColor, cardColor, borderColor, accent, isDark),
    );
  }

  /// Будує основне тіло екрану.
  Widget _buildBody(
    Color textColor, Color subColor, Color cardColor, Color borderColor, Color accent, bool isDark,
  ) {
    return Stack(
      children: [
        ListView(
          padding: const EdgeInsets.symmetric(horizontal: Spacing.base),
          children: [
            const SizedBox(height: Spacing.lg),

            // ─── Master Toggle ────────────────────────────────────
            _buildMasterToggle(textColor, subColor, cardColor, borderColor, accent),

            const SizedBox(height: Spacing.xxl),

            // ─── Notification Preview Card ──────────────────────────
            _buildNotificationPreview(textColor, subColor, cardColor, borderColor, accent),

            const SizedBox(height: Spacing.xxl),

            // ─── Основні сповіщення ──────────────────────────────
            Text('Сповіщення', style: AppTypography.heading3.copyWith(color: textColor)),
            const SizedBox(height: Spacing.sm),

            // Щоденне нагадування
            _buildNotificationTile(
              icon: Icons.alarm_rounded, title: 'Щоденне нагадування',
              subtitle: 'Час: ${_formatTime(_dailyTime)} · Пріоритет: $_dailyPriority',
              value: _dailyReminder,
              onChanged: (v) => setState(() => _dailyReminder = v),
              textColor: textColor, subColor: subColor, accent: accent,
              trailing: _dailyReminder
                  ? GestureDetector(
                      onTap: () => _pickTime(context, _dailyTime, (t) => setState(() => _dailyTime = t)),
                      child: Text('Змінити час', style: AppTypography.labelMedium.copyWith(color: accent, decoration: TextDecoration.underline)),
                    )
                  : null,
            ),
            if (_dailyReminder) _buildSoundToggle('Щоденне', _dailySound, subColor, accent),

            // Нагадування про автоплатіж
            _buildNotificationTile(
              icon: Icons.credit_card_rounded, title: 'Нагадування про автоплатіж',
              subtitle: 'За день до списання',
              value: _autoPaymentReminder,
              onChanged: (v) => setState(() => _autoPaymentReminder = v),
              textColor: textColor, subColor: subColor, accent: accent,
            ),
            if (_autoPaymentReminder) _buildSoundToggle('Автоплатіж', _paymentSound, subColor, accent),

            // Мотиваційні повідомлення
            _buildNotificationTile(
              icon: Icons.auto_awesome_rounded, title: 'Мотиваційні повідомлення',
              subtitle: 'Частота: $_motivationFrequency',
              value: _motivationMessages,
              onChanged: (v) => setState(() => _motivationMessages = v),
              textColor: textColor, subColor: subColor, accent: accent,
              trailing: _motivationMessages
                  ? DropdownButton<String>(
                      underline: const SizedBox.shrink(),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      value: _motivationFrequency,
                      items: _motivationFrequencies
                          .map((f) => DropdownMenuItem(
                                value: f,
                                child: Text(f, style: AppTypography.labelSmall.copyWith(color: textColor)),
                              ))
                          .toList(),
                      onChanged: (v) {
                        if (v != null) setState(() => _motivationFrequency = v);
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(_motivationFrequency, style: AppTypography.labelSmall.copyWith(color: accent)),
                          Icon(Icons.arrow_drop_down_rounded, color: accent, size: 16),
                        ],
                      ),
                    )
                  : null,
            ),
            if (_motivationMessages) _buildSoundToggle('Мотивація', _motivationSound, subColor, accent),

            // Нагадування про виклики
            _buildNotificationTile(
              icon: Icons.emoji_events_rounded, title: 'Нагадування про виклики',
              subtitle: 'Нові виклики та дедлайни · Пріоритет: $_challengePriority',
              value: _challengeReminder,
              onChanged: (v) => setState(() => _challengeReminder = v),
              textColor: textColor, subColor: subColor, accent: accent,
            ),
            if (_challengeReminder) _buildSoundToggle('Виклики', _challengeSound, subColor, accent),

            // Нагадування про стріки
            _buildNotificationTile(
              icon: Icons.local_fire_department_rounded, title: 'Нагадування про стріки',
              subtitle: 'Збережи свою серію · Пріоритет: $_streakPriority',
              value: _streakReminder,
              onChanged: (v) => setState(() => _streakReminder = v),
              textColor: textColor, subColor: subColor, accent: accent,
            ),
            if (_streakReminder) _buildSoundToggle('Стріки', _streakSound, subColor, accent),

            // Щотижневий звіт
            _buildNotificationTile(
              icon: Icons.bar_chart_rounded, title: 'Щотижневий звіт',
              subtitle: 'Підсумок заощаджень за тиждень',
              value: _weeklyReport,
              onChanged: (v) => setState(() => _weeklyReport = v),
              textColor: textColor, subColor: subColor, accent: accent,
            ),
            if (_weeklyReport) _buildSoundToggle('Звіт', _weeklySound, subColor, accent),

            // Новини додатку
            _buildNotificationTile(
              icon: Icons.newspaper_rounded, title: 'Новини додатку',
              subtitle: 'Оновлення та нові функції · Пріоритет: $_newsPriority',
              value: _appNews,
              onChanged: (v) => setState(() => _appNews = v),
              textColor: textColor, subColor: subColor, accent: accent,
            ),

            const SizedBox(height: Spacing.xxl),

            // ─── Тихі години (Do Not Disturb) ───────────────────
            Text('Тихі години', style: AppTypography.heading3.copyWith(color: textColor)),
            const SizedBox(height: Spacing.sm),
            _buildQuietHoursSection(cardColor, borderColor, textColor, subColor, accent),

            const SizedBox(height: Spacing.xxl),

            // ─── Канали сповіщень ────────────────────────────────
            Text('Канали сповіщень', style: AppTypography.heading3.copyWith(color: textColor)),
            const SizedBox(height: Spacing.sm),
            _buildNotificationChannels(cardColor, borderColor, textColor, subColor, accent),

            const SizedBox(height: Spacing.xxl),

            // ─── Історія сповіщень ──────────────────────────────
            Text('Історія сповіщень', style: AppTypography.heading3.copyWith(color: textColor)),
            const SizedBox(height: Spacing.sm),
            _buildNotificationHistory(textColor, subColor, borderColor, accent, isDark),

            const SizedBox(height: Spacing.xxl),

            // ─── Test Notification ────────────────────────────────
            Text('Перевірка', style: AppTypography.heading3.copyWith(color: textColor)),
            const SizedBox(height: Spacing.sm),
            _buildTestSection(cardColor, borderColor, textColor, subColor, accent),

            const SizedBox(height: Spacing.xxl),

            // ─── Vibration ────────────────────────────────
            Text('Вібрація та аналітика', style: AppTypography.heading3.copyWith(color: textColor)),
            const SizedBox(height: Spacing.sm),
            _buildVibrationSection(cardColor, borderColor, accent, textColor, subColor),

            const SizedBox(height: Spacing.xxl),

            // ─── Grouping & Snooze ─────────────────────
            Text('Групування та відкладення', style: AppTypography.heading3.copyWith(color: textColor)),
            const SizedBox(height: Spacing.sm),
            _buildGroupingSnoozeSection(cardColor, borderColor, accent, textColor, subColor),

            const SizedBox(height: Spacing.xxl),

            // ─── Notification Statistics ──────────────────
            GestureDetector(
              onTap: _toggleStats,
              child: Container(
                margin: const EdgeInsets.only(bottom: Spacing.sm),
                padding: const EdgeInsets.all(Spacing.base),
                decoration: BoxDecoration(color: accent.withOpacity(0.04), borderRadius: BorderRadius.circular(Radii.md), border: Border.all(color: accent.withOpacity(0.1))),
                child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text('📊 Статистика сповіщень', style: AppTypography.labelLarge.copyWith(color: accent, fontWeight: FontWeight.w600)),
                  Icon(_showNotificationStats ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded, color: accent, size: 18),
                ]),
              ),
            ),
            if (_showNotificationStats)
              _buildNotificationStatistics(cardColor, borderColor, textColor, subColor, accent),

            const SizedBox(height: Spacing.xxxl),
          ],
        ),

        // ─── Clear History Dialog Overlay ──────────────────────────
        if (_showClearDialog) _buildClearDialogOverlay(textColor, subColor, cardColor, borderColor, accent),
      ],
    );
  }

  /// Будує головний перемикач для всіх сповіщень.
  Widget _buildMasterToggle(Color textColor, Color subColor, Color cardColor, Color borderColor, Color accent) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(Spacing.base),
      decoration: BoxDecoration(
        color: _allNotificationsOff ? AppColorsPS5.error.withOpacity(0.06) : accent.withOpacity(0.06),
        borderRadius: BorderRadius.circular(Radii.lg),
        border: Border.all(
          color: _allNotificationsOff ? AppColorsPS5.error.withOpacity(0.15) : accent.withOpacity(0.15),
        ),
      ),
      child: Row(
        children: [
          Icon(
            _allNotificationsOff ? Icons.notifications_off_rounded : Icons.notifications_active_rounded,
            color: _allNotificationsOff ? AppColorsPS5.error : accent,
            size: 22,
          ),
          const SizedBox(width: Spacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _allNotificationsOff ? 'Сповіщення вимкнено' : 'Сповіщення увімкнено',
                  style: AppTypography.labelLarge.copyWith(color: textColor),
                ),
                Text(
                  '$_enabledChannelsCount з ${_notificationChannels.length} каналів активні · $_notificationsEnabledPercent%',
                  style: AppTypography.labelSmall.copyWith(color: subColor),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: !_allNotificationsOff,
            onChanged: _toggleAllNotifications,
            activeColor: accent,
          ),
        ],
      ),
    ).animate().fade(delay: 50.ms, duration: _NotificationConstants.fadeInDuration.ms);
  }

  /// Будує тестову секцію сповіщень.
  Widget _buildTestSection(Color cardColor, Color borderColor, Color textColor, Color subColor, Color accent) {
    return Container(
      padding: const EdgeInsets.all(Spacing.base),
      decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(Radii.lg), border: Border.all(color: borderColor)),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.notifications_active_rounded, color: accent, size: 22),
              const SizedBox(width: Spacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Тестове сповіщення', style: AppTypography.labelLarge.copyWith(color: textColor)),
                    Text('Надішлі тестове сповіщення, щоб перевірити налаштування', style: AppTypography.labelSmall.copyWith(color: subColor)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: Spacing.md),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _isTestSending ? null : _sendTestNotification,
              icon: _isTestSending
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: AppColorsPS5.accent))
                  : const Icon(Icons.send_rounded),
              label: Text(_isTestSending ? 'Надсилання...' : 'Надіслати тестове сповіщення'),
              style: OutlinedButton.styleFrom(foregroundColor: accent, side: BorderSide(color: accent), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Radii.md))),
            ),
          ),
          // Quiet hours warning
          if (_isCurrentlyQuietHours())
            Container(
              margin: const EdgeInsets.only(top: Spacing.sm),
              padding: const EdgeInsets.all(Spacing.sm),
              decoration: BoxDecoration(
                color: AppColorsPS5.warning.withOpacity(0.08),
                borderRadius: BorderRadius.circular(Radii.sm),
                border: Border.all(color: AppColorsPS5.warning.withOpacity(0.15)),
              ),
              child: Row(
                children: [
                  Icon(Icons.do_not_disturb_on_rounded, color: AppColorsPS5.warning, size: 16),
                  const SizedBox(width: Spacing.xs),
                  Expanded(
                    child: Text(
                      'Зараз тихі години — тестове сповіщення може бути silent',
                      style: AppTypography.labelSmall.copyWith(color: AppColorsPS5.warning, fontSize: 10),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    ).animate().fade(delay: 200.ms, duration: 400.ms);
  }

  /// Будує секцію історії сповіщень з фільтрами.
  Widget _buildNotificationHistory(Color textColor, Color subColor, Color borderColor, Color accent, bool isDark) {
    if (_filteredHistory.isEmpty)
      return _buildEmptyHistoryState(subColor, isDark);

    return Column(
      children: [
        // Filter chips
        SizedBox(
          height: 36,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: _historyFilterOptions.map((filter) {
              final isActive = _historyFilter == filter;
              final label = filter.isEmpty ? 'Усі' : filter;
              return GestureDetector(
                onTap: () => _setHistoryFilter(filter),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(right: Spacing.sm),
                  padding: const EdgeInsets.symmetric(horizontal: Spacing.sm, vertical: Spacing.xs),
                  decoration: BoxDecoration(
                    color: isActive ? accent : Colors.transparent,
                    borderRadius: BorderRadius.circular(Radii.xl),
                    border: Border.all(color: isActive ? accent : borderColor),
                  ),
                  child: Center(
                    child: Text(
                      label,
                      style: AppTypography.labelSmall.copyWith(
                        color: isActive ? Colors.white : subColor,
                        fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: Spacing.sm),

        // Mark all as read button
        if (_unreadCount > 0)
          GestureDetector(
            onTap: _markAllRead,
            child: Container(
              margin: const EdgeInsets.only(bottom: Spacing.sm),
              padding: const EdgeInsets.symmetric(horizontal: Spacing.base, vertical: Spacing.sm),
              decoration: BoxDecoration(color: accent.withOpacity(0.06), borderRadius: BorderRadius.circular(Radii.md), border: Border.all(color: accent.withOpacity(0.12))),
              child: Text('✅ Позначити все прочитаним ($_unreadCount)', style: AppTypography.labelMedium.copyWith(color: accent)),
            ),
          ),

        // History items
        ..._filteredHistory.asMap().entries.map((entry) {
          final actualIndex = _notificationHistory.indexOf(entry.value);
          return _buildHistoryItem(actualIndex, entry.value, textColor, subColor, borderColor, accent);
        }),

        const SizedBox(height: Spacing.sm),

        // Clear history button
        GestureDetector(
          onTap: _showClearHistoryDialog,
          child: Center(child: Text('Очистити історію', style: AppTypography.labelSmall.copyWith(color: AppColorsPS5.error, decoration: TextDecoration.underline))),
        ),
      ],
    );
  }

  /// Будує стан пустої історії.
  Widget _buildEmptyHistoryState(Color subColor, bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(Spacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.notifications_none_rounded, size: 56, color: isDark ? AppColorsPS5.textHint : AppColorsMonitor.textHint),
            const SizedBox(height: Spacing.md),
            Text(
              _historyFilter.isEmpty ? 'Немає сповіщень' : 'Немає сповіщень типу «$_historyFilter»',
              style: AppTypography.bodyMedium.copyWith(color: subColor),
            ),
            if (_historyFilter.isNotEmpty) ...[
              const SizedBox(height: Spacing.xs),
              GestureDetector(
                onTap: () => _setHistoryFilter(''),
                child: Text('Показати всі', style: AppTypography.labelSmall.copyWith(color: AppColorsPS5.accent, decoration: TextDecoration.underline)),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Будує оверлей діалогу очищення історії.
  Widget _buildClearDialogOverlay(Color textColor, Color subColor, Color cardColor, Color borderColor, Color accent) {
    return Positioned.fill(
      child: Container(
        color: Colors.black.withOpacity(0.5),
        child: Center(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: Spacing.xxl),
            padding: const EdgeInsets.all(Spacing.xl),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(Radii.xl),
              border: Border.all(color: borderColor),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.delete_sweep_rounded, color: AppColorsPS5.error, size: 40),
                const SizedBox(height: Spacing.md),
                Text('Очистити історію?', style: AppTypography.heading3.copyWith(color: textColor)),
                const SizedBox(height: Spacing.sm),
                Text('Всі сповіщення буде видалено назавжди.', style: AppTypography.bodyMedium.copyWith(color: subColor), textAlign: TextAlign.center),
                const SizedBox(height: Spacing.xl),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => setState(() => _showClearDialog = false),
                        child: Text('Скасувати', style: AppTypography.labelLarge.copyWith(color: subColor)),
                      ),
                    ),
                    const SizedBox(width: Spacing.md),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _clearHistory,
                        style: ElevatedButton.styleFrom(backgroundColor: AppColorsPS5.error, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Radii.md))),
                        child: Text('Очистити', style: AppTypography.labelLarge.copyWith(color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    ).animate().fadeIn(duration: 200.ms);
  }

  Widget _buildSoundToggle(String type, bool soundOn, Color subColor, Color accent) {
    return Padding(
      padding: const EdgeInsets.only(left: 56, bottom: Spacing.md),
      child: Row(
        children: [
          Text('Звук: ${soundOn ? 'Так' : 'Ні'}', style: AppTypography.labelSmall.copyWith(color: subColor)),
          const SizedBox(width: Spacing.md),
          GestureDetector(
            onTap: () => _toggleSound(type),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Icon(
                soundOn ? Icons.volume_up_rounded : Icons.volume_off_rounded,
                key: ValueKey(soundOn),
                color: soundOn ? accent : subColor,
                size: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Будує елемент історії сповіщень з розгортанням.
  Widget _buildHistoryItem(int index, _NotificationRecord record, Color textColor, Color subColor, Color borderColor, Color accent) {
    final isExpanded = _expandedHistoryIndex == index;
    final typeColor = _typeColors[record.type] ?? accent;
    final typeIcon = _typeIcons[record.type] ?? Icons.notifications_rounded;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(bottom: Spacing.sm),
      padding: EdgeInsets.all(isExpanded ? Spacing.base : Spacing.sm + 4),
      decoration: BoxDecoration(
        color: record.isRead ? Colors.transparent : accent.withOpacity(0.04),
        borderRadius: BorderRadius.circular(Radii.md),
        border: Border.all(color: isExpanded ? accent.withOpacity(0.3) : borderColor),
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: () => _toggleHistoryExpand(index),
            behavior: HitTestBehavior.opaque,
            child: Row(
              children: [
                Icon(typeIcon, color: typeColor, size: 18),
                const SizedBox(width: Spacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          if (!record.isRead)
                            Container(width: 6, height: 6, decoration: BoxDecoration(color: accent, shape: BoxShape.circle))
                          else
                            const SizedBox(width: 6, height: 6),
                          if (!record.isRead) const SizedBox(width: Spacing.sm),
                          Expanded(
                            child: Text(
                              record.title,
                              style: AppTypography.labelMedium.copyWith(
                                color: textColor,
                                fontWeight: record.isRead ? FontWeight.w400 : FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      if (!isExpanded) ...[
                        const SizedBox(height: 2),
                        Text(record.body, style: AppTypography.labelSmall.copyWith(color: subColor), maxLines: 1, overflow: TextOverflow.ellipsis),
                      ],
                      Text('${record.type} · ${record.time}', style: AppTypography.caption.copyWith(color: subColor.withOpacity(0.6))),
                    ],
                  ),
                ),
                Icon(
                  isExpanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                  color: subColor.withOpacity(0.5),
                  size: 18,
                ),
                const SizedBox(width: Spacing.xs),
                GestureDetector(
                  onTap: () => _deleteNotification(index),
                  child: Icon(Icons.delete_outline_rounded, color: subColor.withOpacity(0.5), size: 18),
                ),
              ],
            ),
          ),
          // Expanded content
          if (isExpanded) ...[
            const SizedBox(height: Spacing.sm),
            Container(
              padding: const EdgeInsets.all(Spacing.sm),
              decoration: BoxDecoration(color: accent.withOpacity(0.04), borderRadius: BorderRadius.circular(Radii.sm)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(record.body, style: AppTypography.bodySmall.copyWith(color: subColor)),
                  const SizedBox(height: Spacing.xs),
                  Text('ID: ${record.id} · Тип: ${record.type} · Час: ${record.time}', style: AppTypography.caption.copyWith(color: subColor.withOpacity(0.5), fontSize: 9)),
                  const SizedBox(height: Spacing.xs),
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          setState(() => record.isRead = true);
                          context.showAppToast('Позначено прочитаним', type: AppToastType.info);
                        },
                        child: Text(record.isRead ? '✅ Прочитано' : 'Позначити прочитаним', style: AppTypography.labelSmall.copyWith(color: accent, decoration: TextDecoration.underline, fontSize: 10)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildNotificationChannels(Color cardColor, Color borderColor, Color textColor, Color subColor, Color accent) {
    return Container(
      padding: const EdgeInsets.all(Spacing.base),
      decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(Radii.lg), border: Border.all(color: borderColor)),
      child: Column(
        children: [
          // Summary row
          Padding(
            padding: const EdgeInsets.only(bottom: Spacing.sm),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('$_enabledChannelsCount / ${_notificationChannels.length} каналів', style: AppTypography.labelSmall.copyWith(color: subColor)),
                GestureDetector(
                  onTap: () {
                    final allEnabled = _notificationChannels.every((ch) => ch.enabled);
                    setState(() {
                      for (final ch in _notificationChannels) {
                        ch.enabled = !allEnabled;
                      }
                    });
                  },
                  child: Text(
                    _enabledChannelsCount == _notificationChannels.length ? 'Вимкнути все' : 'Увімкнути все',
                    style: AppTypography.labelSmall.copyWith(color: accent, decoration: TextDecoration.underline),
                  ),
                ),
              ],
            ),
          ),
          ..._notificationChannels.map((ch) {
            return SwitchListTile.adaptive(
              value: ch.enabled,
              onChanged: (v) {
                setState(() => ch.enabled = v);
                developer.log('Channel ${ch.id} ${v ? "enabled" : "disabled"}', name: _logTag);
              },
              activeColor: accent,
              contentPadding: EdgeInsets.zero,
              title: Text(ch.name, style: AppTypography.bodyMedium.copyWith(color: textColor)),
              subtitle: Text(ch.description, style: AppTypography.bodySmall.copyWith(color: subColor)),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildNotificationTile({
    required IconData icon, required String title, required String subtitle, required bool value,
    required ValueChanged<bool> onChanged, required Color textColor, required Color subColor,
    required Color accent, Widget? trailing,
  }) {
    return SwitchListTile.adaptive(
      value: value, onChanged: onChanged, activeColor: accent, contentPadding: EdgeInsets.zero,
      secondary: Icon(icon, color: textColor),
      title: Text(title, style: AppTypography.bodyMedium.copyWith(color: textColor)),
      subtitle: Text(subtitle, style: AppTypography.bodySmall.copyWith(color: subColor)),
      trailing: trailing,
    );
  }

  Widget _buildQuietHoursSection(Color cardColor, Color borderColor, Color textColor, Color subColor, Color accent) {
    return Container(
      padding: const EdgeInsets.all(Spacing.base),
      decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(Radii.lg), border: Border.all(color: borderColor)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(Icons.do_not_disturb_on_rounded, color: accent, size: 20),
            const SizedBox(width: Spacing.sm),
            Text('Не турбувати', style: AppTypography.labelLarge.copyWith(color: textColor)),
            if (_isCurrentlyQuietHours()) ...[
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(color: AppColorsPS5.warning.withOpacity(0.12), borderRadius: BorderRadius.circular(Radii.sm)),
                child: Text('Зараз активні', style: AppTypography.labelSmall.copyWith(color: AppColorsPS5.warning, fontWeight: FontWeight.w700, fontSize: 9)),
              ),
            ],
          ]),
          const SizedBox(height: Spacing.sm),
          SwitchListTile.adaptive(
            value: _quietHoursEnabled, onChanged: (v) => setState(() => _quietHoursEnabled = v),
            activeColor: accent, contentPadding: EdgeInsets.zero,
            title: Text('Увімкнути тихі години', style: AppTypography.bodyMedium.copyWith(color: textColor)),
            subtitle: Text(_quietHoursEnabled ? 'Тривалість: ${_formatQuietHoursDuration()}' : 'Не турбувати у вибраний час', style: AppTypography.bodySmall.copyWith(color: subColor)),
          ),
          if (_quietHoursEnabled) ...[
            const SizedBox(height: Spacing.sm),
            Container(
              padding: const EdgeInsets.all(Spacing.md),
              decoration: BoxDecoration(color: accent.withOpacity(0.05), borderRadius: BorderRadius.circular(Radii.md), border: Border.all(color: accent.withOpacity(0.12))),
              child: Column(
                children: [
                  Row(children: [
                    Icon(Icons.nightlight_rounded, color: subColor, size: 18),
                    const SizedBox(width: Spacing.sm),
                    Text('Графік безшуму', style: AppTypography.labelSmall.copyWith(color: subColor, fontWeight: FontWeight.w600)),
                  ]),
                  const SizedBox(height: Spacing.md),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => _pickTime(context, _quietStart, (t) => setState(() => _quietStart = t)),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: Spacing.md, vertical: Spacing.sm),
                            decoration: BoxDecoration(color: accent.withOpacity(0.1), borderRadius: BorderRadius.circular(Radii.md)),
                            child: Column(children: [
                              Text('Початок', style: AppTypography.labelSmall.copyWith(color: subColor), textAlign: TextAlign.center),
                              Text(_formatTime(_quietStart), style: AppTypography.monoMedium.copyWith(color: accent, fontSize: 18)),
                            ]),
                          ),
                        ),
                      ),
                      Padding(padding: const EdgeInsets.symmetric(horizontal: Spacing.md), child: Icon(Icons.arrow_forward_rounded, color: subColor, size: 18)),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => _pickTime(context, _quietEnd, (t) => setState(() => _quietEnd = t)),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: Spacing.md, vertical: Spacing.sm),
                            decoration: BoxDecoration(color: accent.withOpacity(0.1), borderRadius: BorderRadius.circular(Radii.md)),
                            child: Column(children: [
                              Text('Кінець', style: AppTypography.labelSmall.copyWith(color: subColor), textAlign: TextAlign.center),
                              Text(_formatTime(_quietEnd), style: AppTypography.monoMedium.copyWith(color: accent, fontSize: 18)),
                            ]),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: Spacing.sm),
            Center(child: Text('Сповіщення не надходитимуть з ${_formatTime(_quietStart)} до ${_formatTime(_quietEnd)}', style: AppTypography.labelSmall.copyWith(color: subColor), textAlign: TextAlign.center)),
          ],
        ],
      ),
    );
  }

  Widget _buildNotificationPreview(Color textColor, Color subColor, Color cardColor, Color borderColor, Color accent) {
    final now = DateTime.now();
    final timeStr = _formatTime(TimeOfDay.fromDateTime(now));

    return Container(
      padding: const EdgeInsets.all(Spacing.base),
      decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(Radii.lg), border: Border.all(color: borderColor)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Попередній перегляд', style: AppTypography.labelSmall.copyWith(color: subColor, fontWeight: FontWeight.w600)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(color: accent.withOpacity(0.1), borderRadius: BorderRadius.circular(Radii.sm)),
                child: Text('Нова', style: AppTypography.labelSmall.copyWith(color: accent, fontWeight: FontWeight.w700)),
              ),
            ],
          ),
          const SizedBox(height: Spacing.md),
          Container(
            padding: const EdgeInsets.all(Spacing.md),
            decoration: BoxDecoration(color: (textColor).withOpacity(0.03), borderRadius: BorderRadius.circular(Radii.md)),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(color: accent.withOpacity(0.12), borderRadius: BorderRadius.circular(Radii.sm)),
                  child: Icon(Icons.alarm_rounded, color: accent, size: 18),
                ),
                const SizedBox(width: Spacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Нагадування про внесок', style: AppTypography.labelMedium.copyWith(color: textColor)),
                      Text('Час зробити внесок — ти на правильному шляху! 💪', style: AppTypography.labelSmall.copyWith(color: subColor), maxLines: 2, overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
                Text(timeStr, style: AppTypography.labelSmall.copyWith(color: subColor.withOpacity(0.6))),
              ],
            ),
          ),
        ],
      ),
    ).animate().fade(delay: 100.ms, duration: 300.ms);
  }

  /// Будує секцію вібрації та аналітики.
  Widget _buildVibrationSection(Color cardColor, Color borderColor, Color accent, Color textColor, Color subColor) {
    return Container(
      padding: const EdgeInsets.all(Spacing.base),
      decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(Radii.lg), border: Border.all(color: borderColor)),
      child: Column(
        children: [
          SwitchListTile.adaptive(
            value: _vibrationEnabled,
            onChanged: _toggleVibration,
            activeColor: accent,
            contentPadding: EdgeInsets.zero,
            secondary: Container(
              width: 44, height: 44,
              decoration: BoxDecoration(color: accent.withOpacity(0.1), borderRadius: BorderRadius.circular(Radii.md)),
              child: Icon(Icons.vibration_rounded, color: accent, size: 22),
            ),
            title: Text('Вібрація', style: AppTypography.bodyMedium.copyWith(color: textColor)),
            subtitle: Text(_vibrationEnabled ? 'Тактильний відгук увімкнено' : 'Без вібрації', style: AppTypography.bodySmall.copyWith(color: subColor)),
          ),
          const SizedBox(height: Spacing.sm),
          SwitchListTile.adaptive(
            value: _analyticsEnabled,
            onChanged: _toggleAnalytics,
            activeColor: accent,
            contentPadding: EdgeInsets.zero,
            secondary: Container(
              width: 44, height: 44,
              decoration: BoxDecoration(color: accent.withOpacity(0.1), borderRadius: BorderRadius.circular(Radii.md)),
              child: Icon(Icons.analytics_rounded, color: accent, size: 22),
            ),
            title: Text('Аналітика сповіщень', style: AppTypography.bodyMedium.copyWith(color: textColor)),
            subtitle: Text(_analyticsEnabled ? 'Використання сповіщень для покращення' : 'Без аналітики', style: AppTypography.bodySmall.copyWith(color: subColor)),
          ),
        ],
      ),
    );
  }

  /// Будує секцію групування та відкладення.
  Widget _buildGroupingSnoozeSection(Color cardColor, Color borderColor, Color accent, Color textColor, Color subColor) {
    return Container(
      padding: const EdgeInsets.all(Spacing.base),
      decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(Radii.lg), border: Border.all(color: borderColor)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Режим группування', style: AppTypography.labelSmall.copyWith(color: subColor, fontWeight: FontWeight.w600)),
          const SizedBox(height: Spacing.xs),
          Wrap(
            spacing: Spacing.sm,
            runSpacing: Spacing.sm,
            children: ['none', 'type', 'app'].map((mode) {
              final label = mode == 'none' ? 'Без' : mode == 'type' ? 'За типом' : 'За додатком';
              final isActive = _groupingMode == mode;
              return GestureDetector(
                onTap: () { HapticService.lightTap(); _setGroupingMode(mode); },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: Spacing.sm, vertical: Spacing.xs),
                  decoration: BoxDecoration(
                    color: isActive ? accent : Colors.transparent,
                    borderRadius: BorderRadius.circular(Radii.xl),
                    border: Border.all(color: isActive ? accent : borderColor),
                  ),
                  child: Center(
                    child: Text(label, style: AppTypography.labelSmall.copyWith(
                      color: isActive ? Colors.white : subColor,
                      fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                    )),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: Spacing.md),
          Text('Відкладення сповіщень', style: AppTypography.labelSmall.copyWith(color: subColor, fontWeight: FontWeight.w600)),
          const SizedBox(height: Spacing.xs),
          Container(
            padding: const EdgeInsets.all(Spacing.md),
            decoration: BoxDecoration(color: accent.withOpacity(0.05), borderRadius: BorderRadius.circular(Radii.md), border: Border.all(color: accent.withOpacity(0.12))),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Тривалість відкладення', style: AppTypography.labelSmall.copyWith(color: textColor)),
                    Text(_formatSnoozeDuration(), style: AppTypography.labelSmall.copyWith(color: accent, fontWeight: FontWeight.w600)),
                  ],
                ),
                const SizedBox(height: Spacing.sm),
                Slider(
                  value: _snoozeDuration.toDouble(),
                  min: 0,
                  max: 60,
                  divisions: 12,
                  onChanged: (v) => _setSnoozeDuration(v.round()),
                  activeColor: accent,
                ),
                const SizedBox(height: Spacing.xs),
                Text('0 — вимкнено, 60 хв — максимум', style: AppTypography.caption.copyWith(color: subColor.withOpacity(0.6), fontSize: 9)),
              ],
            ),
          ),
        ],
      ),
    ).animate().fade(delay: 100.ms, duration: 300.ms);
  }

  /// Будує розширену статистику сповіщень.
  Widget _buildNotificationStatistics(Color cardColor, Color borderColor, Color textColor, Color subColor, Color accent) {
    return Container(
      margin: const EdgeInsets.only(bottom: Spacing.sm),
      padding: const EdgeInsets.all(Spacing.base),
      decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(Radii.lg), border: Border.all(color: borderColor)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Загальна статистика', style: AppTypography.labelMedium.copyWith(color: textColor, fontWeight: FontWeight.w600)),
          const SizedBox(height: Spacing.sm),
          _buildStatInfoRow('Усього відправлено за сесію', '$_totalTestSent', Icons.send_rounded, accent, subColor),
          const SizedBox(height: Spacing.xs),
          _buildStatInfoRow('Середньо на день', '$_averageNotificationsPerDay сповіщень', Icons.today_rounded, AppColorsPS5.accent, subColor),
          const SizedBox(height: Spacing.xs),
          _buildStatInfoRow('Звук увімкнено', '$_soundEnabledPercent%', Icons.volume_up_rounded, AppColorsPS5.success, subColor),
          const SizedBox(height: Spacing.xs),
          _buildStatInfoRow('Групування', _groupingModeLabel, Icons.category_rounded, accent, subColor),
          const SizedBox(height: Spacing.xs),
          _buildStatInfoRow('Відкладення', _formatSnoozeDuration(), Icons.snooze_rounded, AppColorsPS5.warning, subColor),
        ],
      ),
    ).animate().fade(duration: 300.ms);
  }

  /// Будує інформаційний рядок статистики.
  Widget _buildStatInfoRow(String label, String value, IconData icon, Color color, Color subColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: Spacing.sm),
          Expanded(child: Text(label, style: AppTypography.labelSmall.copyWith(color: subColor))),
          Text(value, style: AppTypography.labelSmall.copyWith(color: color, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

// ─── Data Models ─────────────────────────────────────────────────────────────

/// Запис історії сповіщень.
  // ─── Priority Color Helper ────────────────────────────────────────────

  /// Повертає колір для рівня пріоритету.
  ///
  /// Використовується для візуального відображення пріоритету сповіщень.
  /// `Високий` → червоний, `Нормальний` — помаранчевий, `Низький` — сірий.
  Color _priorityColor(String priority) {
    switch (priority) {
      case 'Високий':
        return AppColorsPS5.error;
      case 'Нормальний':
        return AppColorsPS5.warning;
      case 'Низький':
        return AppColorsPS5.textSecondary;
      default:
        return AppColorsPS5.textHint;
    }
  }

  /// Повертає іконку для рівня пріоритету.
  IconData _priorityIcon(String priority) {
    switch (priority) {
      case 'Високий':
        return Icons.priority_high_rounded;
      case 'Нормальний':
        return Icons.remove_circle_outline_rounded;
      case 'Низький':
        return Icons.low_priority_rounded;
      default:
        return Icons.notifications_none_rounded;
    }
  }

  // ─── Notification Summary ────────────────────────────────────────────

  /// Обчислює зведену статистику сповіщень.
  ///
  /// Повертає мапу з ключами:
  /// - `total` — загальна кількість
  /// - `unread` — непрочитані
  /// - `read` — прочитані
  /// - `byType` — кількість за типом
  Map<String, dynamic> _computeNotificationSummary() {
    try {
      final total = _notificationHistory.length;
      final unread = _notificationHistory.where((n) => !n.isRead).length;
      final read = total - unread;
      final byType = <String, int>{};
      for (final n in _notificationHistory) {
        byType[n.type] = (byType[n.type] ?? 0) + 1;
      }
      return {
        'total': total,
        'unread': unread,
        'read': read,
        'byType': byType,
        'enabledPercent': _notificationsEnabledPercent,
        'soundPercent': _soundEnabledPercent,
        'avgPerDay': _averageNotificationsPerDay,
      };
    } catch (e) {
      developer.log('Error computing summary: $e', name: _logTag);
      return {'total': 0, 'unread': 0, 'read': 0, 'byType': <String, int>{}};
    }
  }

  /// Форматує зведену статистику для відображення.
  String _formatSummary() {
    final s = _computeNotificationSummary();
    return 'Всього: ${s['total']} · Непрочитаних: ${s['unread']} · '
        'Увімкнено: ${s['enabledPercent']}% · Звук: ${s['soundPercent']}%';
  }

  // ─── Undo Delete ───────────────────────────────────────────────────────

  /// Таймер для скасування видалення сповіщення.
  Timer? _undoDeleteTimer;

  /// Індекс сповіщення, яке було видалено (для undo).
  int _deletedNotificationIndex = -1;

  /// Чи показувати кнопку undo.
  bool get _showUndoButton => _undoDeleteTimer != null && _undoDeleteTimer!.isActive;

  /// Сповіщення, яке було видалено (для відновлення).
  _NotificationRecord? _lastDeletedNotification;

  /// Видаляє сповіщення з можливістю скасування.
  ///
  /// Показує SnackBar з кнопкою «Скасувати» протягом 5 секунд.
  /// Якщо користувач натискає скасувати, сповіщення відновлюється.
  void _deleteNotificationWithUndo(int index) {
    try {
      if (index < 0 || index >= _notificationHistory.length) {
        developer.log('Invalid index for undo delete: $index', name: _logTag, level: 900);
        return;
      }

      context.haptic();
      final deleted = _notificationHistory.removeAt(index);
      _lastDeletedNotification = deleted;
      _deletedNotificationIndex = index;

      setState(() {});

      // Cancel previous undo timer
      _undoDeleteTimer?.cancel();

      developer.log('Notification deleted (undo available): ${deleted.title}', name: _logTag);

      ScaffoldMessenger.of(context)
          .clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Сповіщення видалено',
            style: AppTypography.labelMedium.copyWith(color: AppColorsPS5.textPrimary),
          ),
          action: SnackBarAction(
            label: 'Скасувати',
            textColor: AppColorsPS5.accent,
            onPressed: _undoDelete,
          ),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 5),
        ),
      );

      // Set undo timer
      _undoDeleteTimer = Timer(const Duration(seconds: 5), () {
        if (mounted) {
          setState(() {
            _lastDeletedNotification = null;
            _deletedNotificationIndex = -1;
          });
        }
      });
    } catch (e) {
      developer.log('Error in delete with undo: $e', name: _logTag);
    }
  }

  /// Скасовує видалення останнього сповіщення.
  void _undoDelete() {
    try {
      _undoDeleteTimer?.cancel();
      if (_lastDeletedNotification == null) return;

      final restored = _lastDeletedNotification!;
      final restoreIndex = _deletedNotificationIndex.clamp(0, _notificationHistory.length);

      setState(() {
        _notificationHistory.insert(restoreIndex, restored);
        _lastDeletedNotification = null;
        _deletedNotificationIndex = -1;
      });

      developer.log('Notification restored: ${restored.title}', name: _logTag);
      if (mounted) {
        context.showAppToast('Сповіщення відновлено', type: AppToastType.success);
      }

      ScaffoldMessenger.of(context).clearSnackBars();
    } catch (e) {
      developer.log('Error undoing delete: $e', name: _logTag);
    }
  }

  // ─── Accessibility Helpers ──────────────────────────────────────────────

  /// Генерує семантичний лейб для перемикача сповіщень.
  String _toggleSemanticLabel(String title, bool value) {
    return '$title: ${value ? "увімкнено" : "вимкнено"}';
  }

  /// Генерує семантичний лейб для кнопки дії.
  String _actionSemanticLabel(String action) {
    return 'Дія: $action';
  }

  // ─── Notification Templates ────────────────────────────────────────────

  /// Доступні шаблони тестових сповіщень.
  static const _notificationTemplates = [
    {'title': 'Час зробити внесок!', 'body': 'Ти на правильному шляху! 💪', 'type': 'Щоденне'},
    {'title': 'Автоплатіж успішний', 'body': '50 грн додано до цілі', 'type': 'Автоплатіж'},
    {'title': 'Стріка під загрозою!', 'body': 'Не забудь поповнити сьогодні ⚠️', 'type': 'Стріка'},
    {'title': 'Тиждень у цифрах', 'body': 'Заложено 2 450 грн', 'type': 'Звіт'},
    {'title': 'Новий виклик!', 'body': 'Приєднуйся до маратону!', 'type': 'Виклик'},
  ];

  /// Відправляє тестове сповіщення з випадковим шаблоном.
  void _sendRandomTestNotification() {
    if (_isTestSending) return;

    try {
      setState(() => _isTestSending = true);
      context.haptic();
      final template = _notificationTemplates[DateTime.now().millisecond % _notificationTemplates.length];
      developer.log('Sending random test notification: ${template['title']}', name: _logTag);

      Future.delayed(
        const Duration(milliseconds: _NotificationConstants.testNotificationDefaultDuration),
        () {
          if (mounted) {
            setState(() => _isTestSending = false);
            context.showAppToast(
              '🔔 ${template['title']}\n${template['body']}',
              type: AppToastType.info,
              duration: const Duration(milliseconds: 3000),
            );
            developer.log('Random test notification sent', name: _logTag);
          }
        },
      );
    } catch (e) {
      developer.log('Error sending random test: $e', name: _logTag);
      if (mounted) {
        setState(() => _isTestSending = false);
      }
    }
  }

  // ─── Batch Channel Management ────────────────────────────────────────

  /// Вмикає всі канали сповіщень одночасно.
  void _enableAllChannels() {
    try {
      context.haptic();
      setState(() {
        // Enable all main toggles
        _dailyReminder = true;
        _autoPaymentReminder = true;
        _challengeReminder = true;
        _streakReminder = true;
        _weeklyReport = true;
        _motivationMessages = true;
        _appNews = true;
      });
      developer.log('All notification channels enabled', name: _logTag);
      if (mounted) {
        context.showAppToast('Усі канали увімкнено', type: AppToastType.success);
      }
    } catch (e) {
      developer.log('Error enabling all channels: $e', name: _logTag);
    }
  }

  /// Вимикає всі канали сповіщень одночасно.
  void _disableAllChannels() {
    try {
      context.haptic();
      setState(() {
        _dailyReminder = false;
        _autoPaymentReminder = false;
        _challengeReminder = false;
        _streakReminder = false;
        _weeklyReport = false;
        _motivationMessages = false;
        _appNews = false;
      });
      developer.log('All notification channels disabled', name: _logTag);
      if (mounted) {
        context.showAppToast('Усі канали вимкнено', type: AppToastType.warning);
      }
    } catch (e) {
      developer.log('Error disabling all channels: $e', name: _logTag);
    }
  }

  /// Скидає всі налаштування сповіщень до значень за замовчуванням.
  void _resetNotificationSettings() {
    try {
      context.haptic();
      setState(() {
        _dailyReminder = true;
        _autoPaymentReminder = true;
        _motivationMessages = false;
        _motivationFrequency = 'Щотижня';
        _challengeReminder = true;
        _appNews = false;
        _streakReminder = true;
        _weeklyReport = true;
        _dailySound = true;
        _paymentSound = true;
        _motivationSound = true;
        _challengeSound = true;
        _newsSound = false;
        _streakSound = true;
        _weeklySound = true;
        _quietHoursEnabled = false;
        _quietStart = _NotificationConstants.defaultQuietStart;
        _quietEnd = _NotificationConstants.defaultQuietEnd;
        _vibrationEnabled = true;
        _groupingMode = 'type';
        _snoozeDuration = 10;
        _analyticsEnabled = true;
        _historyFilter = '';
      });
      developer.log('Notification settings reset to defaults', name: _logTag);
      if (mounted) {
        context.showAppToast('Налаштування скинуто', type: AppToastType.info);
      }
    } catch (e) {
      developer.log('Error resetting notification settings: $e', name: _logTag);
    }
  }

  // ─── Notification History Search ──────────────────────────────────────

  /// Пошуковий запит для фільтрації історії.
  String _historySearchQuery = '';

  /// Встановлює пошуковий запит для історії.
  void _setHistorySearch(String query) {
    setState(() => _historySearchQuery = query.toLowerCase());
    developer.log('History search: $query', name: _logTag);
  }

  /// Відфільтрована історія з урахуванням пошуку.
  List<_NotificationRecord> get _searchedHistory {
    if (_historySearchQuery.isEmpty) return _filteredHistory;
    return _filteredHistory
        .where((n) =>
            n.title.toLowerCase().contains(_historySearchQuery) ||
            n.body.toLowerCase().contains(_historySearchQuery))
        .toList();
  }

  @override
  void dispose() {
    _undoDeleteTimer?.cancel();
    developer.log('Screen disposed', name: _logTag);
    super.dispose();
  }
}

/// ─── Notification Record Model ────────────────────────────────────────────
///
/// Зберігає повну інформацію про одне сповіщення:
/// заголовок, текст, час, тип, статус прочитання та унікальний ID.
class _NotificationRecord {
  /// Унікальний ідентифікатор сповіщення.
  final String id;

  /// Заголовок сповіщення.
  final String title;

  /// Текст сповіщення (body).
  final String body;

  /// Час відправки у форматі HH:mm.
  final String time;

  /// Тип сповіщення (Щоденне, Автоплатіж, Стріка, Звіт, Виклик).
  final String type;

  /// Чи сповіщення прочитано.
  bool isRead;

  /// Створює запис історії сповіщень.
  _NotificationRecord({
    required this.title,
    required this.body,
    required this.time,
    required this.type,
    required this.isRead,
    required this.id,
  });
}

/// Канал сповіщень.
///
/// Надає груповий контроль над типами сповіщень.
class _NotificationChannel {
  /// Унікальний ідентифікатор каналу.
  final String id;

  /// Відображувана назва каналу.
  final String name;

  /// Опис каналу для користувача.
  final String description;

  /// Чи канал увімкнений.
  bool enabled;

  /// Створює канал сповіщень.
  _NotificationChannel({
    required this.name,
    required this.description,
    required this.enabled,
    required this.id,
  });
}

/// ─── Extensions ─────────────────────────────────────────────────────────────

/// Розширення для [HapticService] — stub для тактильного відгуку.
class HapticService {
  /// Легкий тактильний відгук.
  static void lightTap() {
    try {
      HapticFeedback.lightImpact();
    } catch (_) {}
  }
}

/// Реквизити методу з обмеженням кількості непрочитаних.
/// Допоміжний метод-розширення для роботи з рядками.
extension _StringExtension on String {
  /// Обрізає рядок до вказаної довжини з додаванням '...'.
  String truncateWithEllipsis(int maxLength) {
    if (length <= maxLength) return this;
    return '${substring(0, maxLength)}...';
  }
}

// ─── Theme-Aware Data Model ─────────────────────────────────────────────────

/// Клас для зберігання theme-aware кольорів.
///
/// Використовується для передачі кольорової схеми між
/// theme-aware widget-білдерами без повторного обчислення.
class _ThemedColors {
  /// Створює набір theme-aware кольорів.
  const _ThemedColors({
    required this.cardColor,
    required this.textColor,
    required this.subColor,
    required this.accent,
    required this.background,
    required this.borderColor,
  });

  /// Фоновий колір для карток.
  final Color cardColor;

  /// Основний колір тексту.
  final Color textColor;

  /// Вторинний колір тексту.
  final Color subColor;

  /// Акцентний колір.
  final Color accent;

  /// Колір фону екрану.
  final Color background;

  /// Колір рамок.
  final Color borderColor;

  /// Колір для індикаторів помилок.
  Color get errorColor => AppColorsPS5.error;

  /// Колір для індикаторів успіху.
  Color get successColor => AppColorsPS5.success;

  /// Колір для індикаторів попереджень.
  Color get warningColor => AppColorsPS5.warning;

  /// Колір для приглушеного тексту.
  Color get hintColor =>
      textColor.withOpacity(0.3);

  /// Колір для активних елементів.
  Color get activeColor => accent;

  /// Колір для неактивних елементів.
  Color get inactiveColor => subColor.withOpacity(0.5);

  /// Повертає копію з заміненим акцентним кольором.
  _ThemedColors withAccent(Color newAccent) {
    return _ThemedColors(
      cardColor: cardColor,
      textColor: textColor,
      subColor: subColor,
      accent: newAccent,
      background: background,
      borderColor: borderColor,
    );
  }
}
