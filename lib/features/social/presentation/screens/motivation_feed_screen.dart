import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_radii.dart';
import '../../../../core/widgets/app_button_secondary.dart';
import '../../../../core/extensions/build_context_ext.dart';

// ═══════════════════════════════════════════════════════════════════════════
// Константи та конфігурація стрічки мотивації
// ═══════════════════════════════════════════════════════════════════════════

/// Максимальна кількість повідомлень для відображення на першій сторінці.
const int _kInitialDisplayCount = 15;

/// Кількість додаткових повідомлень при «Завантажити більше».
const int _kLoadMoreIncrement = 10;

/// Максимальна довжина тексту пошукового запиту.
const int _kMaxSearchQueryLength = 100;

/// Максимальна кількість улюблених повідомлень.
const int _kMaxFavoritesCount = 50;

/// Затримка перед оновленням стрічки (мілісекунди).
const int _kRefreshDelayMs = 800;

/// Затримка перед показом наступної поради (мілісекунди).
const int _kNextTipDelayMs = 300;

/// Тривалість shimmer-анімації (мілісекунди).
const int _kShimmerDurationMs = 1500;

/// Тривалість fade-анімації списку (мілісекунди).
const int _kListAnimDurationMs = 500;

/// Мінімальна кількість повідомлень у категорії для показу бейджа.
const int _kMinMessagesForBadge = 3;

/// Максимальна кількість розгорнутих карток одночасно.
const int _kMaxExpandedCards = 5;

/// Затримка debounce для пошуку (мілісекунди).
const int _kSearchDebounceMs = 300;

/// Мінімальна довжина тексту для пошуку.
const int _kMinSearchLength = 2;

/// Тривалість анімації появи FAB (мілісекунди).
const int _kFabAnimDurationMs = 250;

/// Поріг скролу для показу кнопки «Наверх».
const double _kScrollThresholdForFab = 200.0;

/// Кількість повідомлень у тижневому дайджесті.
const int _kWeeklyDigestCount = 7;

/// Мінімальний рейтинг популярності для «Топ поради».
const int _kTopPopularityThreshold = 88;

/// Тривалість пульсації популярного повідомлення (мілісекунди).
const int _kPulseDurationMs = 2000;

// ═══════════════════════════════════════════════════════════════════════════
// Utility Extensions
// ═══════════════════════════════════════════════════════════════════════════

/// Засіб аналітики стрічки мотивації.
///
/// Збирає статистику взаємодій користувача з повідомленнями
/// та надає методи для розрахунку метрик.
class _FeedAnalytics {
  /// Створює об'єкт аналітики з початковими значеннями.
  const _FeedAnalytics();

  /// Обчислює середній рейтинг популярності для списку повідомлень.
  ///
  /// [messages] — список повідомлень для аналізу.
  /// Повертає середнє значення або 0.0, якщо список порожній.
  double averagePopularityScore(List<_MotivationMsg> messages) {
    if (messages.isEmpty) return 0.0;
    try {
      final total = messages.fold<int>(0, (sum, msg) => sum + msg.popularityScore);
      return total / messages.length;
    } catch (e) {
      debugPrint('[FeedAnalytics] Error calculating average: $e');
      return 0.0;
    }
  }

  /// Повертає топ-N повідомлень за популярністю.
  ///
  /// [messages] — список повідомлень.
  /// [n] — кількість топ повідомлень (за замовчуванням 5).
  List<_MotivationMsg> topMessages(List<_MotivationMsg> messages, {int n = 5}) {
    if (messages.isEmpty) return [];
    try {
      final sorted = List<_MotivationMsg>.from(messages)
        ..sort((a, b) => b.popularityScore.compareTo(a.popularityScore));
      return sorted.take(n.clamp(1, messages.length)).toList();
    } catch (e) {
      debugPrint('[FeedAnalytics] Error getting top messages: $e');
      return messages.take(n).toList();
    }
  }

  /// Повертає відсоток повідомлень з автором.
  ///
  /// [messages] — список повідомлень.
  double authoredPercentage(List<_MotivationMsg> messages) {
    if (messages.isEmpty) return 0.0;
    try {
      final withAuthor = messages.where((m) => m.author != null && m.author!.isNotEmpty).length;
      return (withAuthor / messages.length) * 100;
    } catch (e) {
      debugPrint('[FeedAnalytics] Error calculating authored %: $e');
      return 0.0;
    }
  }

  /// Повертає кількість повідомлень у кожній категорії.
  ///
  /// [messages] — список повідомлень.
  Map<String, int> messagesPerCategory(List<_MotivationMsg> messages) {
    final counts = <String, int>{};
    try {
      for (final msg in messages) {
        counts[msg.category] = (counts[msg.category] ?? 0) + 1;
      }
    } catch (e) {
      debugPrint('[FeedAnalytics] Error counting per category: $e');
    }
    return counts;
  }
}

/// Розширення для роботи з множинами повідомлень.
extension _MotivationSetExtension on Set<int> {
  /// Кількість елементів у множині.
  int get count => length;

  /// Перевіряє, чи множина містить хоча б один елемент.
  bool get isNotEmpty => length > 0;

  /// Перевіряє, чи множина порожня.
  bool get isEmpty => length == 0;
}

/// Розширення для обрізання тексту з безпекою для null.
extension _SafeStringExtension on String {
  /// Обрізає текст до вказаної довжини з додаванням многокрапки.
  String safeSubstring(int maxLength, [String ellipsis = '...']) {
    if (length <= maxLength) return this;
    return '${substring(0, maxLength)}$ellipsis';
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Модель мотиваційного повідомлення
// ═══════════════════════════════════════════════════════════════════════════

/// Модель мотиваційного повідомлення з розширеними полями.
///
/// Містить іконку, категорію, текст повідомлення, автора та дату створення.
/// Використовується для відображення в стрічці мотивації.
class _MotivationMsg {
  /// Іконка для відображення біля повідомлення.
  final IconData icon;

  /// Категорія повідомлення (цілепокладання, фінанси, історія, філософія).
  final String category;

  /// Текст мотиваційного повідомлення.
  final String text;

  /// Автор повідомлення (необов'язковий).
  final String? author;

  /// Дата створення повідомлення (необов'язкова).
  final String? createdAt;

  /// Рейтинг популярності повідомлення (0-100).
  final int popularityScore;

  /// Створює нове мотиваційне повідомлення.
  const _MotivationMsg(
    this.icon,
    this.category,
    this.text, {
    this.author,
    this.createdAt,
    this.popularityScore = 50,
  });

  /// Повертає обрізаний текст для прев'ю (максимум [maxLength] символів).
  String previewText([int maxLength = 40]) {
    return text.safeSubstring(maxLength);
  }

  /// Перевіряє, чи повідомлення містить вказаний пошуковий запит.
  bool matchesQuery(String query) {
    if (query.isEmpty) return true;
    final lowerQuery = query.toLowerCase();
    return text.toLowerCase().contains(lowerQuery) ||
        category.toLowerCase().contains(lowerQuery) ||
        (author?.toLowerCase().contains(lowerQuery) ?? false);
  }

  /// Перевіряє, чи повідомлення належить до вказаної категорії.
  bool isInCategory(String filter) {
    if (filter == 'всі') return true;
    return category == filter;
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Екран «Поради та мотивація»
// ═══════════════════════════════════════════════════════════════════════════

/// Екран «Поради та мотивація» — список мотиваційних повідомлень.
///
/// Містить:
/// - 5 категорій контенту з табами (усі/цілепокладання/фінанси/історія/філософія)
/// - Мотиваційні картки з категоріями (поради / цитати / виклики / історії / філософія)
/// - 30+ українських мотиваційних повідомлень про заощадження
/// - Іконки для кожної категорії з кольоровими бейджами
/// - Pull-to-refresh з shimmer-ефектом
/// - Анімації карток (fade + slide stagger)
/// - Кнопку «Наступна порада» з анімацією оновлення
/// - Улюблені / закладки повідомлень з лічильником
/// - Опція «Поділитися» окремим повідомленням
/// - Порожній стан з ілюстрацією
/// - Пошук повідомлень
/// - Перемикач категорій з табами
/// - Щоденна порада доби з карткою
/// - Типи контенту з візуальною різницею
/// - Налаштування стрічки (персонілізація) з панеллю
/// - Розгортання картки для перегляду деталей
/// - Індикатор непрочитаних з бейджем
/// - Пагінація «Завантажити більше»
/// - Непрочитані повідомлення з індикатором
/// - Сортування повідомлень за популярністю/дата/категорія
/// - «Позначити все як прочитане» функція
/// - Статистика стрічки в налаштуваннях
/// - Обмеження кількості улюблених
/// - Автоматичне маркування повідомлень як прочитаних
class MotivationFeedScreen extends StatefulWidget {
  /// Створює екран стрічки мотивації.
  const MotivationFeedScreen({super.key});

  @override
  State<MotivationFeedScreen> createState() => _MotivationFeedScreenState();
}

class _MotivationFeedScreenState extends State<MotivationFeedScreen>
    with SingleTickerProviderStateMixin {
  /// Поточний індекс виділеної поради.
  int _currentIndex = 0;

  /// Множина індексів улюблених повідомлень.
  final Set<int> _favorites = {};

  /// Множина індексів прочитаних повідомлень.
  final Set<int> _readMessages = {};

  /// Множина індексів розгорнутих карток.
  final Set<int> _expandedCards = {};

  /// Чи відбувається оновлення поточної поради.
  bool _isRefreshing = false;

  /// Чи показувати лише улюблені повідомлення.
  bool _showFavoritesOnly = false;

  /// Поточний пошуковий запит.
  String _searchQuery = '';

  /// Поточний фільтр категорії.
  String _categoryFilter = 'всі';

  /// Контролер анімації списку.
  late AnimationController _listController;

  /// Контролер shimmer-анімації при завантаженні.
  late AnimationController _shimmerController;

  /// Чи показувати панель налаштувань.
  bool _showSettings = false;

  /// Чи увімкнено компактний режим відображення.
  bool _compactMode = false;

  /// Чи показувати інформацію про автора.
  bool _showAuthorInfo = true;

  /// Чи увімкнено анімації карток.
  bool _enableAnimations = true;

  /// Чи увімкнено автоматичне маркування як прочитане.
  bool _autoMarkAsRead = true;

  /// Лічильник оновлень стрічки.
  int _refreshCount = 0;

  /// Кількість повідомлень для відображення (пагінація).
  int _displayedCount = _kInitialDisplayCount;

  /// Чи є ще повідомлення для завантаження.
  bool _hasMore = true;

  /// Чи показується shimmer при завантаженні.
  bool _isShimmerLoading = false;

  /// Порядок сортування повідомлень.
  _SortOrder _sortOrder = _SortOrder.defaultOrder;

  /// Чи показувати панель сортування.
  bool _showSortPanel = false;

  /// Чи показувати кнопку «Наверх».
  bool _showScrollToTop = false;

  /// Чи показувати тижневий дайджест.
  bool _showWeeklyDigest = false;

  /// Контролер скролу для відстеження позиції списку.
  final ScrollController _scrollController = ScrollController();

  /// Таймер debounce для пошуку.
  Timer? _searchDebounceTimer;

  /// Час останнього натискання для захисту від подвійних натискань.
  DateTime? _lastTapTime;

  /// Засіб аналітики стрічки.
  final _FeedAnalytics _analytics = const _FeedAnalytics();

  /// Історія пошукових запитів.
  final List<String> _searchHistory = [];

  /// Кількість пошукових запитів виконаних за сесію.
  int _searchCount = 0;

  /// Чи увімкнено режим тижневого дайджесту.
  bool _weeklyDigestMode = false;

  /// Чи виникла помилка при завантаженні.
  bool _hasError = false;

  /// Повідомлення про помилку.
  String _errorMessage = '';

  /// Категорії для фільтрації.
  static const _categories = ['всі', 'цілепокладання', 'фінанси', 'історія', 'філософія'];

  /// Іконки для кожної категорії.
  static const _categoryIcons = {
    'всі': Icons.apps_rounded,
    'цілепокладання': Icons.flag_rounded,
    'фінанси': Icons.monetization_on_rounded,
    'історія': Icons.history_edu_rounded,
    'філософія': Icons.self_improvement_rounded,
  };

  /// Описи для кожної категорії.
  static const _categoryDescriptions = {
    'всі': 'Всі типи мотиваційних повідомлень',
    'цілепокладання': 'Практичні поради для досягнення цілей',
    'фінанси': 'Фінансові стратегії та техніки заощадження',
    'історія': 'Цікаві факти та рекорди спільноти',
    'філософія': 'Філософські роздуми про гроші та свободу',
  };

  /// Колекція мотиваційних повідомлень.
  static const _messages = [
    _MotivationMsg(Icons.lightbulb_rounded, 'цілепокладання', 'Навіть 10 грн — це крок до мрії. Мала сума — великий результат!', author: 'Nexora команда', popularityScore: 85),
    _MotivationMsg(Icons.star_rounded, 'фінанси', 'Спробуй автоматичний платіж — це найпростіший спосіб накопичувати.', author: 'Nexora команда', popularityScore: 90),
    _MotivationMsg(Icons.psychology_rounded, 'цілепокладання', 'Встанови собі нагадування на той самий час щодня — утвори звичку.', author: 'Nexora команда', popularityScore: 75),
    _MotivationMsg(Icons.schedule_rounded, 'фінанси', 'Відкладай 5 хвилин щоранку на внесок — це стане твоєю рутиною.', popularityScore: 70),
    _MotivationMsg(Icons.savings_rounded, 'фінанси', 'Використовуй правило 50/30/20 — 20% на заощадження мінімум.', author: 'Фінансовий радник', popularityScore: 95),
    _MotivationMsg(Icons.wb_sunny_rounded, 'цілепокладання', 'Відкладай частину грошей відразу після зарплати — плати спочатку собі!', popularityScore: 88),
    _MotivationMsg(Icons.piggy_bank_rounded, 'фінанси', 'Спробуй «правило копійки» — кожна непарна сума йде в скарбничку.', popularityScore: 65),
    _MotivationMsg(Icons.trending_up_rounded, 'цілепокладання', 'Ти в топ-20% користувачів за стабільністю! Продовжуй у тому ж дусі.', popularityScore: 92),
    _MotivationMsg(Icons.favorite_rounded, 'філософія', 'Накопичення — це марафон, а не спринт. Ти на правильному шляху.', author: 'Nexora команда', popularityScore: 80),
    _MotivationMsg(Icons.auto_awesome_rounded, 'цілепокладання', 'Ти довів, що можеш. Тепер доведи, що зможеш знову.', popularityScore: 87),
    _MotivationMsg(Icons.military_tech_rounded, 'філософія', 'Дисципліна — це міст між цілями та досягненнями.', popularityScore: 78),
    _MotivationMsg(Icons.format_quote_rounded, 'філософія', 'Найкращий час почати заощаджувати був рік тому. Наступний найкращий — зараз!', popularityScore: 93),
    _MotivationMsg(Icons.nights_stay_rounded, 'цілепокладання', 'Маленькі кроки щодня — велика зміна з часом. Не недооцінюй силу звички.', popularityScore: 82),
    _MotivationMsg(Icons.menu_book_rounded, 'філософія', '«Багатство — це не те, що ти маєш, а те, що ти залишаєш» — невідомий мудрець.', popularityScore: 72),
    _MotivationMsg(Icons.emoji_events_rounded, 'цілепокладання', 'Кожен день наближає тебе до мрії. Зроби внесок сьогодні!', popularityScore: 86),
    _MotivationMsg(Icons.local_fire_department_rounded, 'фінанси', 'Збережи серію внесків! Уже 5 днів поспіль — не зупиняйся.', popularityScore: 89),
    _MotivationMsg(Icons.bolt_rounded, 'цілепокладання', 'Виконай щоденний виклик і отримай бонус XP!', popularityScore: 76),
    _MotivationMsg(Icons.volunteer_activism_rounded, 'філософія', 'Поділися своїм результатом із другом — мотивація подвійна!', popularityScore: 68),
    _MotivationMsg(Icons.rocket_launch_rounded, 'цілепокладання', 'Встанови новий рекорд серії! Ти можеш більше, ніж думаєш!', popularityScore: 84),
    _MotivationMsg(Icons.speed_rounded, 'фінанси', 'Спробуй «тиждень подвійних внесків» — подвоюй звичну суму!', popularityScore: 60),
    _MotivationMsg(Icons.history_edu_rounded, 'історія', 'У 2023 році користувачі Nexora зібрали понад 1 мільйон грн разом!', popularityScore: 73),
    _MotivationMsg(Icons.groups_rounded, 'історія', 'Найбільший індивідуальний збір: 50 000 грн за 6 місяців. Неймовірно!', popularityScore: 77),
    _MotivationMsg(Icons.workspace_premium_rounded, 'історія', 'Топ-1 користувач за серією внесків: 365 днів поспіль!', popularityScore: 91),
    _MotivationMsg(Icons.timeline_rounded, 'історія', 'Середній час досягнення першої цілі — 45 днів. Ти можеш швидше!', popularityScore: 69),
    _MotivationMsg(Icons.yard_rounded, 'філософія', 'Гроші — це енергія. Накопичення — це фокус енергії на мрії.', author: 'Фінансовий філософ', popularityScore: 74),
    _MotivationMsg(Icons.self_improvement_rounded, 'філософія', 'Заощадження не про обмеження — це про свободу вибору в майбутньому.', popularityScore: 81),
    _MotivationMsg(Icons.eco_rounded, 'цілепокладання', 'Кожна збережена гривня — це інвестиція у свою майбутню свободу.', popularityScore: 83),
    _MotivationMsg(Icons.explore_rounded, 'філософія', 'Мрія без плану — це просто бажання. Скарбничка — це твій план дій.', popularityScore: 79),
    _MotivationMsg(Icons.school_rounded, 'історія', 'Найуспішніший користувач накопичив на подорож за 30 днів!', popularityScore: 71),
    _MotivationMsg(Icons.card_giftcard_rounded, 'фінанси', 'Відкладай подарункові кошти — вони теж рахуються!', popularityScore: 64),
    _MotivationMsg(Icons.lightbulb_outline_rounded, 'цілепокладання', 'Запиши свою ціль на папері — дослідження показують, що це підвищує шанси на 42%!', author: 'Nexora команда', popularityScore: 86),
    _MotivationMsg(Icons.account_balance_wallet_rounded, 'фінанси', 'Відстежуй кожну витрату протягом тижня — ти здивуєшся результату!', popularityScore: 67),
    _MotivationMsg(Icons.directions_run_rounded, 'цілепокладання', 'Перший внесок — найважчий. Решта приходить легше з кожним днем.', popularityScore: 88),
    _MotivationMsg(Icons.volunteer_activism_rounded, 'філософія', 'Заощадження разом із друзями — це не лише ефективно, але й веселіше!', popularityScore: 62),
    _MotivationMsg(Icons.insights_rounded, 'фінанси', 'Складні відсотки — 8-е диво світу. Почни якомога раніше!', author: 'Фінансовий радник', popularityScore: 94),
  ];

  /// Повертає відфільтрований список повідомлень.
  ///
  /// Застосовує фільтри: улюблені, категорія, пошуковий запит, сортування.
  List<_MotivationMsg> get _filteredMessages {
    try {
      var base = _showFavoritesOnly
          ? _messages.asMap().entries.where((e) => _favorites.contains(e.key)).map((e) => e.value).toList()
          : List<_MotivationMsg>.from(_messages);

      if (_categoryFilter != 'всі') {
        base = base.where((m) => m.isInCategory(_categoryFilter)).toList();
      }

      if (_searchQuery.isNotEmpty) {
        base = base.where((m) => m.matchesQuery(_searchQuery)).toList();
      }

      // Застосування сортування
      switch (_sortOrder) {
        case _SortOrder.defaultOrder:
          break; // Зберігаємо оригінальний порядок
        case _SortOrder.popularity:
          base.sort((a, b) => b.popularityScore.compareTo(a.popularityScore));
          break;
        case _SortOrder.category:
          base.sort((a, b) => a.category.compareTo(b.category));
          break;
      }

      return base;
    } catch (e) {
      debugPrint('[MotivationFeed] Error filtering messages: $e');
      return _messages.toList();
    }
  }

  /// Повертає список повідомлень для поточного відображення з пагінацією.
  List<_MotivationMsg> get _displayedMessages {
    final all = _filteredMessages;
    return all.take(_displayedCount).toList();
  }

  /// Кількість непрочитаних повідомлень.
  int get _unreadCount {
    if (_messages.isEmpty) return 0;
    return _messages.length - _readMessages.length;
  }

  /// Щоденна порада доби на основі номера дня в році.
  String get _dailyTip {
    try {
      final now = DateTime.now();
      final dayOfYear = now.difference(DateTime(now.year, 1, 1)).inDays;
      return _messages[dayOfYear % _messages.length].text;
    } catch (e) {
      debugPrint('[MotivationFeed] Error getting daily tip: $e');
      return 'Кожен день — це нова можливість!';
    }
  }

  /// Кількість повідомлень у кожній категорії.
  Map<String, int> get _categoryCounts {
    final counts = <String, int>{};
    for (final msg in _messages) {
      counts[msg.category] = (counts[msg.category] ?? 0) + 1;
    }
    return counts;
  }

  /// Чи досягнуто ліміт улюблених повідомлень.
  bool get _isFavoritesLimitReached => _favorites.length >= _kMaxFavoritesCount;

  @override
  void initState() {
    super.initState();
    _listController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: _kListAnimDurationMs),
    )..forward();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: _kShimmerDurationMs),
    )..repeat();
    _scrollController.addListener(_handleScrollListener);

    // Логування ініціалізації
    debugPrint('[MotivationFeed] Initialized with ${_messages.length} messages');
    debugPrint('[MotivationFeed] Avg popularity: ${_analytics.averagePopularityScore(_messages).toStringAsFixed(1)}');
  }

  /// Обробник подій скролу для показу/приховування кнопки «Наверх».
  void _handleScrollListener() {
    try {
      if (!_scrollController.hasClients) return;
      final offset = _scrollController.offset;
      final shouldShow = offset > _kScrollThresholdForFab;
      if (shouldShow != _showScrollToTop) {
        setState(() => _showScrollToTop = shouldShow);
      }
    } catch (e) {
      debugPrint('[MotivationFeed] Scroll listener error: $e');
    }
  }

  /// Перемотує список до початку з анімацією.
  Future<void> _scrollToTop() async {
    try {
      context.haptic();
      if (!_scrollController.hasClients) return;
      await _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutCubic,
      );
      setState(() => _showScrollToTop = false);
      debugPrint('[MotivationFeed] Scrolled to top');
    } catch (e) {
      debugPrint('[MotivationFeed] Error scrolling to top: $e');
    }
  }

  /// Захист від подвійних натискань (debounce).
  ///
  /// [minInterval] — мінімальний інтервал між натисканнями.
  /// Повертає `true`, якщо натискання дозволене.
  bool _isTapAllowed({Duration minInterval = const Duration(milliseconds: 300)}) {
    final now = DateTime.now();
    if (_lastTapTime != null && now.difference(_lastTapTime!) < minInterval) {
      return false;
    }
    _lastTapTime = now;
    return true;
  }

  /// Додає пошуковий запит до історії.
  ///
  /// [query] — пошуковий запит для збереження.
  void _addToSearchHistory(String query) {
    if (query.length < _kMinSearchLength) return;
    try {
      final trimmed = query.trim();
      if (trimmed.isEmpty) return;
      _searchHistory.remove(trimmed);
      _searchHistory.insert(0, trimmed);
      if (_searchHistory.length > 10) {
        _searchHistory.removeRange(10, _searchHistory.length);
      }
      _searchCount++;
      debugPrint('[MotivationFeed] Search: "$trimmed" (count=$_searchCount)');
    } catch (e) {
      debugPrint('[MotivationFeed] Error adding to search history: $e');
    }
  }

  /// Перемикає відображення тижневого дайджесту.
  void _toggleWeeklyDigest() {
    context.haptic();
    setState(() {
      _showWeeklyDigest = !_showWeeklyDigest;
      if (_showWeeklyDigest) {
        _weeklyDigestMode = true;
      }
    });
    debugPrint('[MotivationFeed] Weekly digest: $_showWeeklyDigest');
  }

  /// Повертає список повідомлень для тижневого дайджесту.
  List<_MotivationMsg> get _weeklyDigestMessages {
    try {
      return _analytics.topMessages(_messages, n: _kWeeklyDigestCount);
    } catch (e) {
      debugPrint('[MotivationFeed] Error getting weekly digest: $e');
      return _messages.take(_kWeeklyDigestCount).toList();
    }
  }

  /// Обчислює середній рейтинг популярності стрічки.
  double get _averagePopularity => _analytics.averagePopularityScore(_messages);

  /// Повертає відсоток повідомлень з автором.
  double get _authoredPercentage => _analytics.authoredPercentage(_messages);

  @override
  void dispose() {
    _searchDebounceTimer?.cancel();
    _scrollController.removeListener(_handleScrollListener);
    _scrollController.dispose();
    _listController.dispose();
    _shimmerController.dispose();
    debugPrint('[MotivationFeed] Disposed (searches=$_searchCount, refreshes=$_refreshCount)');
    super.dispose();
  }

  /// Показує наступну пораду з анімацією оновлення.
  void _nextTip() {
    if (_isRefreshing) return;
    context.haptic();
    setState(() => _isRefreshing = true);
    Future.delayed(const Duration(milliseconds: _kNextTipDelayMs), () {
      if (mounted) {
        setState(() {
          _currentIndex = (_currentIndex + 1) % _messages.length;
          _isRefreshing = false;
          _listController.reset();
          _listController.forward();
          _refreshCount++;
          _markAsRead(_currentIndex);
        });
        debugPrint('[MotivationFeed] Next tip: index=$_currentIndex');
      }
    });
  }

  /// Показує випадкову пораду.
  void _showRandomTip() {
    if (_isRefreshing) return;
    context.haptic();
    setState(() => _isRefreshing = true);
    final random = math.Random();
    Future.delayed(const Duration(milliseconds: _kNextTipDelayMs), () {
      if (mounted) {
        setState(() {
          _currentIndex = random.nextInt(_messages.length);
          _isRefreshing = false;
          _listController.reset();
          _listController.forward();
          _refreshCount++;
          _markAsRead(_currentIndex);
        });
        debugPrint('[MotivationFeed] Random tip: index=$_currentIndex');
      }
    });
  }

  /// Оновлює стрічку з shimmer-ефектом.
  void _onRefresh() {
    setState(() {
      _isShimmerLoading = true;
      _hasError = false;
    });
    Future.delayed(const Duration(milliseconds: _kRefreshDelayMs), () {
      if (mounted) {
        setState(() {
          _isShimmerLoading = false;
          _refreshCount++;
          _listController.reset();
          _listController.forward();
        });
        context.showToast('Стрічку оновлено!', icon: Icons.check_circle_rounded);
        debugPrint('[MotivationFeed] Refreshed (count=$_refreshCount)');
      }
    });
  }

  /// Перемішує повідомлення у випадковому порядку.
  void _shuffleMessages() {
    context.haptic();
    try {
      setState(() {
        (_messages as List).shuffle();
        _listController.reset();
        _listController.forward();
      });
      context.showToast('Стрічку перемішано!', icon: Icons.shuffle_rounded);
      debugPrint('[MotivationFeed] Messages shuffled');
    } catch (e) {
      debugPrint('[MotivationFeed] Error shuffling: $e');
      _showErrorState('Помилка перемішування');
    }
  }

  /// Додає або видаляє повідомлення з улюблених.
  ///
  /// [index] — оригінальний індекс повідомлення в списку.
  void _toggleFavorite(int index) {
    context.haptic();

    if (_favorites.contains(index)) {
      setState(() {
        _favorites.remove(index);
      });
      context.showToast('Видалено з улюблених', icon: Icons.bookmark_remove_rounded);
      debugPrint('[MotivationFeed] Removed favorite: index=$index');
    } else {
      if (_isFavoritesLimitReached) {
        context.showToast('Ліміт улюблених: $_kMaxFavoritesCount', icon: Icons.warning_amber_rounded);
        return;
      }
      setState(() {
        _favorites.add(index);
      });
      context.showToast('Додано до улюблених (${_favorites.length}/$_kMaxFavoritesCount)', icon: Icons.bookmark_rounded);
      debugPrint('[MotivationFeed] Added favorite: index=$index');
    }
  }

  /// Позначає повідомлення як прочитане.
  void _markAsRead(int originalIndex) {
    if (_readMessages.contains(originalIndex)) return;
    setState(() => _readMessages.add(originalIndex));
  }

  /// Позначає всі повідомлення як прочитані.
  void _markAllAsRead() {
    context.haptic();
    setState(() {
      for (int i = 0; i < _messages.length; i++) {
        _readMessages.add(i);
      }
    });
    context.showToast('Всі повідомлення позначено як прочитані', icon: Icons.done_all_rounded);
    debugPrint('[MotivationFeed] All messages marked as read');
  }

  /// Розгортає або згортає картку повідомлення.
  ///
  /// Обмежує максимальну кількість розгорнутих карток
  /// для оптимізації продуктивності.
  void _toggleExpanded(int index) {
    if (!_isTapAllowed()) return;
    context.haptic();
    setState(() {
      if (_expandedCards.contains(index)) {
        _expandedCards.remove(index);
      } else {
        // Обмеження кількості розгорнутих карток
        if (_expandedCards.length >= _kMaxExpandedCards) {
          final oldest = _expandedCards.first;
          _expandedCards.remove(oldest);
          debugPrint('[MotivationFeed] Auto-collapsed card: $oldest (max=$_kMaxExpandedCards)');
        }
        _expandedCards.add(index);
        if (_autoMarkAsRead) {
          _markAsRead(index);
        }
      }
    });
  }

  /// Ділиться повідомленням через системний діалог.
  void _shareMessage(_MotivationMsg msg) {
    context.haptic();
    try {
      final shareText = '${msg.text}\n\n— Nexora';
      Clipboard.setData(ClipboardData(text: shareText));
      context.showToast('Скопійовано: ${msg.previewText(30)}', icon: Icons.share_rounded);
      debugPrint('[MotivationFeed] Shared message: ${msg.previewText(20)}');
    } catch (e) {
      debugPrint('[MotivationFeed] Error sharing: $e');
    }
  }

  /// Перемикає панель налаштувань.
  void _toggleSettings() {
    context.haptic();
    setState(() => _showSettings = !_showSettings);
  }

  /// Перемикає панель сортування.
  void _toggleSortPanel() {
    context.haptic();
    setState(() => _showSortPanel = !_showSortPanel);
  }

  /// Завантажує ще повідомлення (пагінація).
  void _loadMore() {
    if (!_hasMore) return;
    context.haptic();
    setState(() {
      _displayedCount += _kLoadMoreIncrement;
      if (_displayedCount >= _filteredMessages.length) {
        _hasMore = false;
      }
    });
    debugPrint('[MotivationFeed] Loaded more: displayed=$_displayedCount, hasMore=$_hasMore');
  }

  /// Скидає всі фільтри до значень за замовчуванням.
  void _resetFilters() {
    context.haptic();
    setState(() {
      _showFavoritesOnly = false;
      _searchQuery = '';
      _categoryFilter = 'всі';
      _sortOrder = _SortOrder.defaultOrder;
      _displayedCount = _kInitialDisplayCount;
      _hasMore = true;
    });
    debugPrint('[MotivationFeed] Filters reset');
  }

  /// Показує стан помилки.
  void _showErrorState(String message) {
    setState(() {
      _hasError = true;
      _errorMessage = message;
    });
  }

  /// Обчислює відсоток прочитаних повідомлень.
  double get _readPercentage {
    if (_messages.isEmpty) return 0.0;
    return (_readMessages.length / _messages.length) * 100;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final textColor = isDark ? AppColorsPS5.textPrimary : AppColorsMonitor.textPrimary;
    final subColor = isDark ? AppColorsPS5.textSecondary : AppColorsMonitor.textSecondary;
    final cardColor = isDark ? AppColorsPS5.card : AppColorsMonitor.card;
    final accent = isDark ? AppColorsPS5.accent : AppColorsMonitor.accent;
    final borderColor = isDark ? AppColorsPS5.border : AppColorsMonitor.border;

    return Scaffold(
      backgroundColor: isDark ? AppColorsPS5.background : AppColorsMonitor.background,
      appBar: AppBar(
        title: const Text('Поради та мотивація'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: textColor,
        actions: [
          // Індикатор непрочитаних
          if (_unreadCount > 0)
            Container(
              margin: const EdgeInsets.only(right: Spacing.xs),
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(color: AppColorsPS5.accent, borderRadius: BorderRadius.circular(Radii.sm)),
              child: Text('$_unreadCount нових', style: AppTypography.labelSmall.copyWith(color: Colors.white, fontSize: 10)),
            ),
          // Кнопка «Позначити все прочитаним»
          if (_unreadCount > 0)
            IconButton(
              icon: Icon(Icons.done_all_rounded, color: subColor),
              onPressed: _markAllAsRead,
              tooltip: 'Позначити все прочитаним',
            ),
          IconButton(
            icon: Icon(Icons.settings_rounded, color: subColor),
            onPressed: _toggleSettings,
            tooltip: 'Налаштування стрічки',
          ),
          IconButton(
            icon: Icon(Icons.sort_rounded, color: _sortOrder != _SortOrder.defaultOrder ? accent : subColor),
            onPressed: _toggleSortPanel,
            tooltip: 'Сортувати',
          ),
          IconButton(
            icon: Icon(
              _showFavoritesOnly ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
              color: _showFavoritesOnly ? accent : subColor,
            ),
            onPressed: () {
              context.haptic();
              setState(() => _showFavoritesOnly = !_showFavoritesOnly);
            },
            tooltip: _showFavoritesOnly ? 'Всі поради' : 'Тільки улюблені',
          ),
        ],
      ),
      body: Column(
        children: [
          // ─── Щоденна порада ──────────────────────────────
          _buildDailyTipCard(accent, textColor),
          const SizedBox(height: Spacing.xs),

          // ─── Помилка ────────────────────────────────────
          if (_hasError)
            _buildErrorBanner(textColor, subColor),

          // ─── Налаштування стрічки ─────────────────────────
          if (_showSettings)
            _buildSettingsPanel(textColor, subColor, cardColor, borderColor, accent),

          // ─── Панель сортування ──────────────────────────
          if (_showSortPanel)
            _buildSortPanel(textColor, subColor, cardColor, borderColor, accent),

          // ─── Пошук ──────────────────────────────────────
          _buildSearchField(isDark, textColor, cardColor, borderColor, subColor),

          // ─── Категорії з іконками ─────────────────────────
          _buildCategoryTabs(accent, subColor, borderColor),

          // ─── Тижневий дайджест ───────────────────────────
          if (_showWeeklyDigest)
            _buildWeeklyDigestCard(accent, textColor, subColor, cardColor),

          // ─── Швидка статистика ───────────────────────────
          _buildQuickStatsBar(subColor, accent),

          // ─── Прогрес читання ─────────────────────────────
          if (_unreadCount > 0)
            _buildReadProgressIndicator(accent, subColor),

          // ─── Message count ──────────────────────────────
          _buildMessageCountRow(subColor, accent),

          // ─── Message List, Shimmer, or Empty State ───────
          Expanded(
            child: _isShimmerLoading
                ? _buildShimmerList(cardColor, borderColor)
                : _filteredMessages.isEmpty
                    ? _buildEmptyState(textColor, subColor, accent)
                    : _buildMessageList(textColor, subColor, cardColor, borderColor, accent, isDark),
          ),

          // ─── Кнопки внизу ──────────────────────────────
          _buildBottomButtons(accent),
        ],
      ),
      // ─── FAB для прокрутки наверх ───────────────────────
      if (_showScrollToTop)
        _buildScrollToTopFab(accent),
    );
  }

  /// Будує плаваючу кнопку прокрутки наверх з анімацією появи.
  Widget _buildScrollToTopFab(Color accent) {
    return Positioned(
      bottom: 80,
      right: 16,
      child: FloatingActionButton.small(
    onPressed: _scrollToTop,
    backgroundColor: accent,
    child: const Icon(Icons.keyboard_arrow_up_rounded, color: Colors.white),
    ),
    ).animate(target: _showScrollToTop ? 1 : 0)
      .fade(duration: const Duration(milliseconds: _kFabAnimDurationMs))
      .scale(begin: 0.5, end: 1.0, duration: const Duration(milliseconds: _kFabAnimDurationMs));
  }

  /// Будує картку тижневого дайджесту з топ-порадами.
  Widget _buildWeeklyDigestCard(Color accent, Color textColor, Color subColor, Color cardColor) {
    final digest = _weeklyDigestMessages;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      margin: const EdgeInsets.fromLTRB(Spacing.base, Spacing.sm, Spacing.base, 0),
      padding: const EdgeInsets.all(Spacing.base),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [accent.withOpacity(0.06), accent.withOpacity(0.02)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(Radii.lg),
        border: Border.all(color: accent.withOpacity(0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.auto_graph_rounded, color: accent, size: 20),
              const SizedBox(width: Spacing.sm),
              Text('🔥 Топ тижня', style: AppTypography.labelMedium.copyWith(color: accent, fontWeight: FontWeight.w700)),
              const Spacer(),
              GestureDetector(
                onTap: _toggleWeeklyDigest,
                child: Icon(Icons.close_rounded, color: subColor, size: 16),
              ),
            ],
          ),
          const SizedBox(height: Spacing.sm),
          Text(
            'Найпопулярніші поради цього тижня',
            style: AppTypography.labelSmall.copyWith(color: subColor),
          ),
          const SizedBox(height: Spacing.sm),
          ...digest.asMap().entries.map((entry) {
            final i = entry.key;
            final msg = entry.value;
            final medal = i == 0 ? '🥇' : i == 1 ? '🥈' : i == 2 ? '🥉' : '${i + 4}.';
            return Padding(
              padding: const EdgeInsets.only(bottom: Spacing.xs),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(medal, style: const TextStyle(fontSize: 14)),
                  const SizedBox(width: Spacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          msg.previewText(50),
                          style: AppTypography.labelSmall.copyWith(color: textColor, fontWeight: FontWeight.w500),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          '${msg.popularityScore}% популярності',
                          style: AppTypography.labelSmall.copyWith(color: subColor.withOpacity(0.6), fontSize: 9),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    ).animate().fade(duration: 300.ms).slideY(begin: -0.05, end: 0, duration: 300.ms);
  }

  /// Будує індикатор прогресу прочитаних повідомлень.
  Widget _buildReadProgressIndicator(Color accent, Color subColor) {
    final progress = _readPercentage / 100;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Spacing.base),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Прогрес читання',
                style: AppTypography.labelSmall.copyWith(color: subColor, fontSize: 9),
              ),
              Text(
                '${_readPercentage.toStringAsFixed(0)}%',
                style: AppTypography.labelSmall.copyWith(color: accent, fontSize: 9, fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              backgroundColor: accent.withOpacity(0.1),
              valueColor: AlwaysStoppedAnimation<Color>(accent),
              minHeight: 3,
            ),
          ),
        ],
      ),
    );
  }

  /// Будує картку щоденної поради.
  Widget _buildDailyTipCard(Color accent, Color textColor) {
    return Container(
      margin: const EdgeInsets.fromLTRB(Spacing.base, Spacing.sm, Spacing.base, 0),
      padding: const EdgeInsets.all(Spacing.base),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [accent.withOpacity(0.08), accent.withOpacity(0.03)]),
        borderRadius: BorderRadius.circular(Radii.md),
        border: Border.all(color: accent.withOpacity(0.12)),
      ),
      child: Row(
        children: [
          Icon(Icons.today_rounded, color: accent, size: 18),
          const SizedBox(width: Spacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Порада дня', style: AppTypography.labelSmall.copyWith(color: accent, fontWeight: FontWeight.w600)),
                Text(_dailyTip, style: AppTypography.bodySmall.copyWith(color: textColor), maxLines: 2, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          Icon(Icons.auto_awesome_rounded, color: accent.withOpacity(0.4), size: 20),
        ],
      ),
    ).animate().fade(duration: 400.ms);
  }

  /// Будує банер помилки.
  Widget _buildErrorBanner(Color textColor, Color subColor) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: Spacing.base, vertical: Spacing.xs),
      padding: const EdgeInsets.all(Spacing.sm),
      decoration: BoxDecoration(
        color: AppColorsPS5.error.withOpacity(0.08),
        borderRadius: BorderRadius.circular(Radii.sm),
        border: Border.all(color: AppColorsPS5.error.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline_rounded, color: AppColorsPS5.error, size: 16),
          const SizedBox(width: Spacing.sm),
          Expanded(
            child: Text(_errorMessage, style: AppTypography.labelSmall.copyWith(color: AppColorsPS5.error)),
          ),
          GestureDetector(
            onTap: () => setState(() { _hasError = false; _errorMessage = ''; }),
            child: Icon(Icons.close_rounded, color: AppColorsPS5.error.withOpacity(0.5), size: 16),
          ),
        ],
      ),
    );
  }

  /// Будує панель налаштувань стрічки.
  Widget _buildSettingsPanel(Color textColor, Color subColor, Color cardColor, Color borderColor, Color accent) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.fromLTRB(Spacing.base, Spacing.sm, Spacing.base, 0),
      padding: const EdgeInsets.all(Spacing.base),
      decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(Radii.md), border: Border.all(color: borderColor)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('⚙️ Налаштування стрічки', style: AppTypography.labelMedium.copyWith(color: textColor, fontWeight: FontWeight.w600)),
          const SizedBox(height: Spacing.sm),
          _buildSettingsSwitch('Компактний вигляд', _compactMode, (v) { context.haptic(); setState(() => _compactMode = v); }, accent),
          _buildSettingsSwitch('Показувати автора', _showAuthorInfo, (v) { context.haptic(); setState(() => _showAuthorInfo = v); }, accent),
          _buildSettingsSwitch('Анімації карток', _enableAnimations, (v) { context.haptic(); setState(() => _enableAnimations = v); }, accent),
          _buildSettingsSwitch('Авто-прочитання', _autoMarkAsRead, (v) { context.haptic(); setState(() => _autoMarkAsRead = v); }, accent),
          const SizedBox(height: Spacing.sm),
          // Статистика
          Container(
            padding: const EdgeInsets.all(Spacing.sm),
            decoration: BoxDecoration(color: accent.withOpacity(0.04), borderRadius: BorderRadius.circular(Radii.sm)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('📊 Статистика стрічки', style: AppTypography.labelSmall.copyWith(color: accent, fontWeight: FontWeight.w600)),
                const SizedBox(height: Spacing.xs),
                _buildStatsRow('Оновлень', '$_refreshCount', subColor),
                _buildStatsRow('Улюблених', '${_favorites.length}/$_kMaxFavoritesCount', subColor),
                _buildStatsRow('Непрочитаних', '$_unreadCount', subColor),
                _buildStatsRow('Прочитано', '${_readPercentage.toStringAsFixed(0)}%', subColor),
                _buildStatsRow('Всього повідомлень', '${_messages.length}', subColor),
              ],
            ),
          ),
        ],
      ),
    ).animate().fade(duration: 200.ms);
  }

  /// Будує перемикач в налаштуваннях.
  Widget _buildSettingsSwitch(String label, bool value, ValueChanged<bool> onChanged, Color accent) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTypography.labelSmall.copyWith(color: AppColorsPS5.textSecondary)),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: accent,
          contentPadding: EdgeInsets.zero,
        ),
      ],
    );
  }

  /// Будує рядок статистики в налаштуваннях.
  Widget _buildStatsRow(String label, String value, Color subColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTypography.labelSmall.copyWith(color: subColor.withOpacity(0.7), fontSize: 10)),
        Text(value, style: AppTypography.labelSmall.copyWith(color: subColor, fontWeight: FontWeight.w600, fontSize: 10)),
      ],
    );
  }

  /// Будує панель сортування.
  Widget _buildSortPanel(Color textColor, Color subColor, Color cardColor, Color borderColor, Color accent) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.fromLTRB(Spacing.base, Spacing.xs, Spacing.base, 0),
      padding: const EdgeInsets.all(Spacing.base),
      decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(Radii.md), border: Border.all(color: borderColor)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('🔄 Сортування', style: AppTypography.labelSmall.copyWith(color: textColor, fontWeight: FontWeight.w600)),
          const SizedBox(height: Spacing.sm),
          Wrap(
            spacing: Spacing.xs,
            children: _SortOrder.values.map((order) {
              final isActive = _sortOrder == order;
              return GestureDetector(
                onTap: () {
                  context.haptic();
                  setState(() => _sortOrder = order);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: Spacing.sm, vertical: 4),
                  decoration: BoxDecoration(
                    color: isActive ? accent : Colors.transparent,
                    borderRadius: BorderRadius.circular(Radii.sm),
                    border: Border.all(color: isActive ? accent : borderColor),
                  ),
                  child: Text(
                    order.label,
                    style: AppTypography.labelSmall.copyWith(
                      color: isActive ? Colors.white : subColor,
                      fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    ).animate().fade(duration: 200.ms);
  }

  /// Будує поле пошуку повідомлень.
  Widget _buildSearchField(bool isDark, Color textColor, Color cardColor, Color borderColor, Color subColor) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(Spacing.base, Spacing.sm, Spacing.base, 0),
      child: Container(
        height: 40,
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(Radii.md),
          border: Border.all(color: borderColor),
        ),
        child: TextField(
          onChanged: (v) {
            final trimmed = v.length > _kMaxSearchQueryLength
                ? v.substring(0, _kMaxSearchQueryLength)
                : v;
            setState(() => _searchQuery = trimmed);
          },
          style: AppTypography.bodySmall.copyWith(color: textColor),
          decoration: InputDecoration(
            hintText: 'Пошук порад...',
            hintStyle: AppTypography.bodySmall.copyWith(color: isDark ? AppColorsPS5.textHint : AppColorsMonitor.textHint),
            prefixIcon: Icon(Icons.search_rounded, size: 18, color: isDark ? AppColorsPS5.textHint : AppColorsMonitor.textHint),
            suffixIcon: _searchQuery.isNotEmpty
                ? GestureDetector(
                    onTap: () => setState(() => _searchQuery = ''),
                    child: Icon(Icons.close_rounded, size: 16, color: subColor),
                  )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(horizontal: Spacing.sm),
          ),
        ),
      ),
    );
  }

  /// Будує горизонтальний список категорій-табів.
  Widget _buildCategoryTabs(Color accent, Color subColor, Color borderColor) {
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: Spacing.base),
        itemCount: _categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: Spacing.sm),
        itemBuilder: (context, i) {
          final cat = _categories[i];
          final isActive = _categoryFilter == cat;
          final icon = _categoryIcons[cat] ?? Icons.label_rounded;
          final count = _categoryCounts[cat] ?? 0;

          return GestureDetector(
            onTap: () { context.haptic(); setState(() => _categoryFilter = cat); },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: Spacing.base, vertical: Spacing.xs),
              decoration: BoxDecoration(
                color: isActive ? accent : Colors.transparent,
                borderRadius: BorderRadius.circular(Radii.xl),
                border: Border.all(color: isActive ? accent : borderColor),
              ),
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, color: isActive ? Colors.white : subColor, size: 12),
                    const SizedBox(width: 4),
                    Text(
                      cat == 'всі' ? 'Усе' : cat,
                      style: AppTypography.labelSmall.copyWith(
                        color: isActive ? Colors.white : subColor,
                        fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ),
                    if (count >= _kMinMessagesForBadge && !isActive) ...[
                      const SizedBox(width: 3),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                        decoration: BoxDecoration(
                          color: subColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '$count',
                          style: AppTypography.labelSmall.copyWith(color: subColor, fontSize: 8, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  /// Будує рядок з кількістю повідомлень та кнопками дій.
  Widget _buildMessageCountRow(Color subColor, Color accent) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(Spacing.base, Spacing.sm, Spacing.base, 0),
      child: Row(
        children: [
          Text(
            _showFavoritesOnly
                ? '${_filteredMessages.length} улюблених'
                : '${_filteredMessages.length} порад',
            style: AppTypography.labelSmall.copyWith(color: subColor),
          ),
          if (_favorites.isNotEmpty) ...[
            const SizedBox(width: Spacing.xs),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppColorsPS5.coin.withOpacity(0.1),
                borderRadius: BorderRadius.circular(Radii.sm),
              ),
              child: Text(
                '${_favorites.length} ★',
                style: AppTypography.labelSmall.copyWith(color: AppColorsPS5.coin, fontWeight: FontWeight.w600),
              ),
            ),
          ],
          if (_sortOrder != _SortOrder.defaultOrder) ...[
            const SizedBox(width: Spacing.xs),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: accent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(Radii.sm),
              ),
              child: Text(
                _sortOrder.label,
                style: AppTypography.labelSmall.copyWith(color: accent, fontSize: 9, fontWeight: FontWeight.w600),
              ),
            ),
          ],
          const Spacer(),
          if (_searchQuery.isNotEmpty || _showFavoritesOnly || _categoryFilter != 'всі')
            GestureDetector(
              onTap: _resetFilters,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.filter_list_off_rounded, color: accent, size: 14),
                  const SizedBox(width: 2),
                  Text('Скинути', style: AppTypography.labelSmall.copyWith(color: accent)),
                ],
              ),
            ),
          const SizedBox(width: Spacing.sm),
          GestureDetector(
            onTap: _shuffleMessages,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.shuffle_rounded, color: accent, size: 14),
                const SizedBox(width: 2),
                Text('Перемішати', style: AppTypography.labelSmall.copyWith(color: accent)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Будує список повідомлень з пагінацією.
  Widget _buildMessageList(Color textColor, Color subColor, Color cardColor, Color borderColor, Color accent, bool isDark) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: ListView.builder(
        key: ValueKey('${_showFavoritesOnly}_$_categoryFilter$_searchQuery$_sortOrder$_refreshCount'),
        padding: const EdgeInsets.all(Spacing.base),
        itemCount: _displayedMessages.length + (_hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= _displayedMessages.length) {
            return _buildLoadMoreButton(accent);
          }
          final msg = _displayedMessages[index];
          final originalIndex = _messages.indexOf(msg);
          final isFav = _favorites.contains(originalIndex);
          final isRead = _readMessages.contains(originalIndex);
          final isExpanded = _expandedCards.contains(originalIndex);

          final card = _MotivationCard(
            msg: msg,
            index: index,
            isDark: isDark,
            accent: accent,
            cardColor: cardColor,
            textColor: textColor,
            subColor: subColor,
            borderColor: borderColor,
            isFavorite: isFav,
            isRead: isRead,
            isExpanded: isExpanded,
            compactMode: _compactMode,
            showAuthorInfo: _showAuthorInfo,
            onToggleFavorite: () => _toggleFavorite(originalIndex),
            onShare: () => _shareMessage(msg),
            onExpand: () => _toggleExpanded(originalIndex),
            onTap: () => _toggleExpanded(originalIndex),
          );

          if (!_enableAnimations) return card;

          return card
              .animate()
              .fade(delay: (60 * index).ms, duration: 350.ms)
              .slideY(begin: 0.06, end: 0, delay: (60 * index).ms, duration: 350.ms);
        },
      ),
    );
  }

  /// Будує shimmer-список під час завантаження.
  Widget _buildShimmerList(Color cardColor, Color borderColor) {
    return ListView.builder(
      padding: const EdgeInsets.all(Spacing.base),
      itemCount: 5,
      itemBuilder: (context, _) {
        return AnimatedBuilder(
          animation: _shimmerController,
          builder: (_, __) {
            final offset = _shimmerController.value * 200;
            return Container(
              margin: const EdgeInsets.only(bottom: Spacing.md),
              padding: const EdgeInsets.all(Spacing.base),
              decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(Radii.lg), border: Border.all(color: borderColor)),
              child: Column(children: [
                Row(children: [
                  Container(width: 44, height: 44, decoration: BoxDecoration(color: Colors.grey.withOpacity(0.1 + 0.05 * math.sin(_shimmerController.value * math.pi * 2)), borderRadius: BorderRadius.circular(Radii.md))),
                  const SizedBox(width: Spacing.md),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Container(height: 12, width: 80 + offset * 0.5, decoration: BoxDecoration(color: Colors.grey.withOpacity(0.08), borderRadius: BorderRadius.circular(4))),
                    const SizedBox(height: Spacing.xs),
                    Container(height: 10, width: double.infinity, decoration: BoxDecoration(color: Colors.grey.withOpacity(0.06), borderRadius: BorderRadius.circular(4))),
                    const SizedBox(height: Spacing.xs),
                    Container(height: 10, width: double.infinity * 0.6, decoration: BoxDecoration(color: Colors.grey.withOpacity(0.04), borderRadius: BorderRadius.circular(4))),
                  ])),
                ]),
              ]),
            );
          },
        );
      },
    );
  }

  /// Будує кнопку «Завантажити більше».
  Widget _buildLoadMoreButton(Color accent) {
    return GestureDetector(
      onTap: _loadMore,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: Spacing.sm),
        padding: const EdgeInsets.all(Spacing.base),
        decoration: BoxDecoration(color: accent.withOpacity(0.04), borderRadius: BorderRadius.circular(Radii.md), border: Border.all(color: accent.withOpacity(0.1))),
        child: Center(child: Text('Завантажити більше порад ↓', style: AppTypography.labelMedium.copyWith(color: accent))),
      ),
    );
  }

  /// Будує порожній стан для стрічки.
  Widget _buildEmptyState(Color textColor, Color subColor, Color accent) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(Spacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(color: accent.withOpacity(0.08), shape: BoxShape.circle),
              child: Icon(Icons.bookmark_border_rounded, color: accent.withOpacity(0.4), size: 36),
            ),
            const SizedBox(height: Spacing.lg),
            Text(
              _showFavoritesOnly ? 'Немає улюблених порад' : 'Нічого не знайдено',
              style: AppTypography.heading3.copyWith(color: textColor),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: Spacing.sm),
            Text(
              _showFavoritesOnly
                  ? 'Натисни ★ на пораді, щоб додати її в улюблені'
                  : 'Спробуй змінити фільтр або пошуковий запит',
              style: AppTypography.bodyMedium.copyWith(color: subColor),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: Spacing.lg),
            GestureDetector(
              onTap: _resetFilters,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: Spacing.base, vertical: Spacing.sm),
                decoration: BoxDecoration(
                  color: accent.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(Radii.md),
                  border: Border.all(color: accent.withOpacity(0.15)),
                ),
                child: Text('Показати всі поради →', style: AppTypography.labelMedium.copyWith(color: accent)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Будує панель швидкої інформації (міні-статистика стрічки).
  Widget _buildQuickStatsBar(Color subColor, Color accent) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: Spacing.base, vertical: Spacing.xs),
      padding: const EdgeInsets.symmetric(horizontal: Spacing.sm, vertical: 6),
      decoration: BoxDecoration(
        color: accent.withOpacity(0.03),
        borderRadius: BorderRadius.circular(Radii.sm),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildQuickStat('Сер. рейтинг', '${_averagePopularity.toStringAsFixed(0)}', subColor),
          Container(width: 1, height: 16, color: accent.withOpacity(0.1)),
          _buildQuickStat('З автором', '${_authoredPercentage.toStringAsFixed(0)}%', subColor),
          Container(width: 1, height: 16, color: accent.withOpacity(0.1)),
          GestureDetector(
            onTap: _toggleWeeklyDigest,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.auto_graph_rounded, color: accent, size: 12),
                const SizedBox(width: 3),
                Text('Топ тижня', style: AppTypography.labelSmall.copyWith(color: accent, fontSize: 9, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Будує елемент міні-статистики.
  Widget _buildQuickStat(String label, String value, Color subColor) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(value, style: AppTypography.labelSmall.copyWith(color: subColor, fontWeight: FontWeight.w700, fontSize: 10)),
        Text(label, style: AppTypography.labelSmall.copyWith(color: subColor.withOpacity(0.5), fontSize: 8)),
      ],
    );
  }

  /// Будує нижні кнопки дій.
  Widget _buildBottomButtons(Color accent) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(Spacing.base, 0, Spacing.base, Spacing.xxl),
      child: Row(children: [
        Expanded(
          child: AppButtonSecondary(
            label: _isRefreshing ? 'Оновлення...' : 'Наступна',
            icon: _isRefreshing ? Icons.sync_rounded : Icons.refresh_rounded,
            onPressed: _isRefreshing ? null : _nextTip,
          ).animate(target: _isRefreshing ? 1 : 0).rotate(begin: 0, end: 2 * math.pi, duration: 600.ms),
        ),
        const SizedBox(width: Spacing.sm),
        AppButtonSecondary(
          label: 'Випадкова',
          icon: Icons.casino_rounded,
          onPressed: _isRefreshing ? null : _showRandomTip,
        ),
      ]),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Порядок сортування
// ═══════════════════════════════════════════════════════════════════════════

/// Порядок сортування повідомлень у стрічці мотивації.
enum _SortOrder {
  /// За замовчуванням (як у списку).
  defaultOrder('За замовчуванням'),

  /// За популярністю (від найпопулярніших).
  popularity('За популярністю'),

  /// За категорією (алфавітно).
  category('За категорією');

  const _SortOrder(this.label);

  /// Мітка для відображення в UI.
  final String label;
}

// ═══════════════════════════════════════════════════════════════════════════
// Картка мотиваційного повідомлення
// ═══════════════════════════════════════════════════════════════════════════

/// Картка мотиваційного повідомлення з інтерактивними елементами.
///
/// Містить іконку категорії, текст повідомлення, бейдж категорії,
/// кнопки улюбленого, поділитися, розгортання деталей.
class _MotivationCard extends StatelessWidget {
  /// Створює картку мотиваційного повідомлення.
  const _MotivationCard({
    required this.msg,
    required this.index,
    required this.isDark,
    required this.accent,
    required this.cardColor,
    required this.textColor,
    required this.subColor,
    required this.borderColor,
    required this.isFavorite,
    required this.onToggleFavorite,
    required this.onShare,
    this.isRead = false,
    this.isExpanded = false,
    this.compactMode = false,
    this.showAuthorInfo = true,
    this.onExpand,
    this.onTap,
  });

  /// Повідомлення для відображення.
  final _MotivationMsg msg;

  /// Індекс повідомлення в відфільтрованому списку.
  final int index;

  /// Чи використовується темна тема.
  final bool isDark;

  /// Акцентний колір.
  final Color accent;

  /// Колір фону картки.
  final Color cardColor;

  /// Колір основного тексту.
  final Color textColor;

  /// Колір вторинного тексту.
  final Color subColor;

  /// Колір рамки.
  final Color borderColor;

  /// Чи повідомлення є улюбленим.
  final bool isFavorite;

  /// Чи повідомлення прочитане.
  final bool isRead;

  /// Чи картка розгорнута.
  final bool isExpanded;

  /// Чи увімкнено компактний режим.
  final bool compactMode;

  /// Чи показувати інформацію про автора.
  final bool showAuthorInfo;

  /// Колбек натискання кнопки улюбленого.
  final VoidCallback onToggleFavorite;

  /// Колбек натискання кнопки поділитися.
  final VoidCallback onShare;

  /// Колбек натискання кнопки розгортання (необов'язковий).
  final VoidCallback? onExpand;

  /// Колбек натискання на картку (необов'язковий).
  final VoidCallback? onTap;

  /// Повертає колір бейджа для категорії.
  Color _badgeColor(String category) {
    switch (category) {
      case 'цілепокладання': return AppColorsPS5.success;
      case 'фінанси': return AppColorsPS5.coin;
      case 'історія': return AppColorsPS5.accent;
      case 'філософія': return AppColorsPS5.xp;
      default: return accent;
    }
  }

  /// Повертає мітку з емодзі для категорії.
  String _categoryLabel(String category) {
    switch (category) {
      case 'цілепокладання': return '🎯 Цілепокладання';
      case 'фінанси': return '💰 Фінанси';
      case 'історія': return '📚 Історія';
      case 'філософія': return '🧘 Філософія';
      default: return category;
    }
  }

  /// Повертає опис для категорії.
  String _categoryDescription(String category) {
    switch (category) {
      case 'цілепокладання': return 'Практичні поради для досягнення фінансових цілей';
      case 'фінанси': return 'Фінансові стратегії та техніки заощадження';
      case 'історія': return 'Цікаві факти та рекорди спільноти Nexora';
      case 'філософія': return 'Філософські роздуми про гроші та свободу';
      default: return '';
    }
  }

  /// Повертає ім'я автора для відображення.
  String get _authorDisplay => msg.author ?? 'Nexora команда';

  @override
  Widget build(BuildContext context) {
    final badgeColor = _badgeColor(msg.category);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: Spacing.md),
        padding: compactMode ? const EdgeInsets.all(Spacing.sm) : const EdgeInsets.all(Spacing.base),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(Radii.lg),
          border: Border.all(
            color: isFavorite
                ? AppColorsPS5.coin.withOpacity(0.3)
                : (isRead ? borderColor.withOpacity(0.5) : borderColor),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Заголовок з іконкою та бейджем
            _buildHeader(badgeColor),
            const SizedBox(height: Spacing.sm),
            // Текст повідомлення
            _buildContent(),
            // Розгорнуті деталі
            if (isExpanded) _buildExpandedDetails(badgeColor),
            // Автор (згорнутий стан)
            if (showAuthorInfo && !compactMode && !isExpanded) _buildAuthorCompact(),
            const SizedBox(height: Spacing.sm),
            // Кнопки дій
            _buildActions(),
          ],
        ),
      ),
    );
  }

  /// Будує рядок заголовка з іконкою, бейджем та індикатором непрочитаного.
  Widget _buildHeader(Color badgeColor) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!compactMode)
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: badgeColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(Radii.md),
            ),
            child: Icon(msg.icon, color: badgeColor, size: 22),
          ),
        if (!compactMode) const SizedBox(width: Spacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: badgeColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(Radii.sm),
                  ),
                  child: Text(
                    _categoryLabel(msg.category),
                    style: AppTypography.labelSmall.copyWith(color: badgeColor, fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(width: Spacing.xs),
                Text('#${index + 1}', style: AppTypography.labelSmall.copyWith(color: subColor.withOpacity(0.5))),
                if (!isRead) ...[
                  const SizedBox(width: Spacing.xs),
                  Container(width: 6, height: 6, decoration: const BoxDecoration(color: AppColorsPS5.accent, shape: BoxShape.circle)),
                ],
                if (msg.popularityScore >= 90) ...[
                  const SizedBox(width: Spacing.xs),
                  Icon(Icons.trending_up_rounded, color: AppColorsPS5.coin, size: 12),
                ],
              ]),
            ],
          ),
        ),
      ],
    );
  }

  /// Будує текст повідомлення.
  Widget _buildContent() {
    return Text(
      msg.text,
      style: AppTypography.bodyMedium.copyWith(
        color: textColor,
        fontSize: compactMode ? 13 : null,
        fontWeight: isRead ? FontWeight.w400 : FontWeight.w500,
      ),
    );
  }

  /// Будує розгорнуті деталі повідомлення.
  Widget _buildExpandedDetails(Color badgeColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: Spacing.sm),
        Divider(color: borderColor.withOpacity(0.5)),
        const SizedBox(height: Spacing.xs),
        Text(
          _categoryDescription(msg.category),
          style: AppTypography.labelSmall.copyWith(color: subColor, fontSize: 10, fontStyle: FontStyle.italic),
        ),
        const SizedBox(height: Spacing.xs),
        if (showAuthorInfo && !compactMode)
          Text('$_authorDisplay · motivacja · #${index + 1}', style: AppTypography.labelSmall.copyWith(color: subColor.withOpacity(0.5), fontSize: 10)),
        // Популярність
        const SizedBox(height: Spacing.xs),
        Row(
          children: [
            Icon(Icons.star_rounded, color: AppColorsPS5.coin.withOpacity(0.5), size: 12),
            const SizedBox(width: 4),
            Text(
              'Популярність: ${msg.popularityScore}%',
              style: AppTypography.labelSmall.copyWith(color: subColor.withOpacity(0.5), fontSize: 9),
            ),
          ],
        ),
      ],
    );
  }

  /// Будує компактний відображення автора.
  Widget _buildAuthorCompact() {
    return Padding(
      padding: const EdgeInsets.only(top: Spacing.xs),
      child: Text('$_authorDisplay · motivacja', style: AppTypography.labelSmall.copyWith(color: subColor.withOpacity(0.5), fontSize: 10)),
    );
  }

  /// Будує рядок кнопок дій (розгорнути, улюблене, поділитися).
  Widget _buildActions() {
    return Row(
      children: [
        if (onExpand != null) ...[
          GestureDetector(
            onTap: onExpand,
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(isExpanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded, color: subColor, size: 16),
              const SizedBox(width: 4),
              Text(isExpanded ? 'Згорнути' : 'Детальніше', style: AppTypography.labelSmall.copyWith(color: subColor)),
            ]),
          ),
          const SizedBox(width: Spacing.md),
        ],
        GestureDetector(
          onTap: onToggleFavorite,
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(isFavorite ? Icons.bookmark_rounded : Icons.bookmark_border_rounded, color: isFavorite ? AppColorsPS5.coin : subColor, size: 16),
            const SizedBox(width: 4),
            Text(isFavorite ? 'Улюблена' : 'Зберегти', style: AppTypography.labelSmall.copyWith(color: isFavorite ? AppColorsPS5.coin : subColor)),
          ]),
        ),
        const SizedBox(width: Spacing.md),
        GestureDetector(
          onTap: onShare,
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.share_rounded, color: subColor, size: 16),
            const SizedBox(width: 4),
            Text('Поділитися', style: AppTypography.labelSmall.copyWith(color: subColor)),
          ]),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Модель налаштувань стрічки (для персистентності)
// ═══════════════════════════════════════════════════════════════════════════

/// Модель для збереження користувацьких налаштувань стрічки мотивації.
///
/// Містить всі конфігураційні параметри, які користувач може змінювати
/// через панель налаштувань. Використовується для serialization
/// та відновлення стану екрану.
class _FeedPreferences {
  /// Створює налаштування з початковими значеннями.
  const _FeedPreferences({
    this.compactMode = false,
    this.showAuthorInfo = true,
    this.enableAnimations = true,
    this.autoMarkAsRead = true,
    this.defaultSortOrder = _SortOrder.defaultOrder,
    this.preferredCategory = 'всі',
    this.showDailyTip = true,
    this.enableNotifications = true,
    this.fontSizeMultiplier = 1.0,
  });

  /// Чи увімкнено компактний режим відображення карток.
  final bool compactMode;

  /// Чи показувати інформацію про автора повідомлень.
  final bool showAuthorInfo;

  /// Чи увімкнено анімації появи карток у стрічці.
  final bool enableAnimations;

  /// Чи автоматично позначати повідомлення як прочитані при відкритті.
  final bool autoMarkAsRead;

  /// Порядок сортування за замовчуванням для стрічки.
  final _SortOrder defaultSortOrder;

  /// Обрана категорія за замовчуванням.
  final String preferredCategory;

  /// Чи показувати щоденну пораду вгорі стрічки.
  final bool showDailyTip;

  /// Чи увімкнені push-сповіщення про нові поради.
  final bool enableNotifications;

  /// Множник розміру шрифту (1.0 = стандартний).
  final double fontSizeMultiplier;

  /// Повертає відформатований рядок з усіма параметрами.
  @override
  String toString() =>
      'FeedPreferences(compact=$compactMode, author=$showAuthorInfo, '
      'anim=$enableAnimations, autoRead=$autoMarkAsRead, '
      'sort=$defaultSortOrder, category=$preferredCategory)';

  /// Створює копію налаштувань з оновленими полями.
  _FeedPreferences copyWith({
    bool? compactMode,
    bool? showAuthorInfo,
    bool? enableAnimations,
    bool? autoMarkAsRead,
    _SortOrder? defaultSortOrder,
    String? preferredCategory,
    bool? showDailyTip,
    bool? enableNotifications,
    double? fontSizeMultiplier,
  }) {
    return _FeedPreferences(
      compactMode: compactMode ?? this.compactMode,
      showAuthorInfo: showAuthorInfo ?? this.showAuthorInfo,
      enableAnimations: enableAnimations ?? this.enableAnimations,
      autoMarkAsRead: autoMarkAsRead ?? this.autoMarkAsRead,
      defaultSortOrder: defaultSortOrder ?? this.defaultSortOrder,
      preferredCategory: preferredCategory ?? this.preferredCategory,
      showDailyTip: showDailyTip ?? this.showDailyTip,
      enableNotifications: enableNotifications ?? this.enableNotifications,
      fontSizeMultiplier: fontSizeMultiplier ?? this.fontSizeMultiplier,
    );
  }

  /// Перевіряє, чи налаштування відповідають значенням за замовчуванням.
  bool get isDefault =>
      compactMode == false &&
      showAuthorInfo == true &&
      enableAnimations == true &&
      autoMarkAsRead == true &&
      defaultSortOrder == _SortOrder.defaultOrder &&
      preferredCategory == 'всі' &&
      showDailyTip == true &&
      enableNotifications == true &&
      fontSizeMultiplier == 1.0;
}

// ═══════════════════════════════════════════════════════════════════════════
// Будівник темо-залежних кольорів для стрічки
// ═══════════════════════════════════════════════════════════════════════════

/// Будівник кольорової схеми для стрічки мотивації.
///
/// Надає зручний доступ до всіх кольорів залежно від обраної теми.
/// Використовується в [`_MotivationCard`] та інших віджетах стрічки.
class _FeedThemeColors {
  /// Створює кольорову схему для вказаної теми.
  const _FeedColors({
    required this.text,
    required this.subtext,
    required this.card,
    required this.border,
    required this.accent,
    required this.hint,
    required this.surface,
    required this.background,
    required this.success,
    required this.coin,
    required this.xp,
    required this.error,
    required this.unreadIndicator,
  });

  /// Колір основного тексту.
  final Color text;

  /// Колір вторинного тексту.
  final Color subtext;

  /// Колір фону карток.
  final Color card;

  /// Колір рамок.
  final border;

  /// Акцентний колір.
  final accent;

  /// Колір підказок/лейблів.
  final Color hint;

  /// Колір поверхні (вкладені контейнери).
  final Color surface;

  /// Колір фону екрану.
  final Color background;

  /// Колір успіху/позитивних дій.
  final Color success;

  /// Колір монет/фінансових елементів.
  final Color coin;

  /// Колір XP/досвіду.
  final Color xp;

  /// Колір помилок/попереджень.
  final Color error;

  /// Колір індикатора непрочитаних повідомлень.
  final Color unreadIndicator;

  /// Створює темну кольорову схему.
  factory _FeedColors.dark() => const _FeedColors(
    text: AppColorsPS5.textPrimary,
    subtext: AppColorsPS5.textSecondary,
    card: AppColorsPS5.card,
    border: AppColorsPS5.border,
    accent: AppColorsPS5.accent,
    hint: AppColorsPS5.textHint,
    surface: AppColorsPS5.surface,
    background: AppColorsPS5.background,
    success: AppColorsPS5.success,
    coin: AppColorsPS5.coin,
    xp: AppColorsPS5.xp,
    error: AppColorsPS5.error,
    unreadIndicator: AppColorsPS5.accent,
  );

  /// Створює світлу кольорову схему.
  factory _FeedColors.light() => const _FeedColors(
    text: AppColorsMonitor.textPrimary,
    subtext: AppColorsMonitor.textSecondary,
    card: AppColorsMonitor.card,
    border: AppColorsMonitor.border,
    accent: AppColorsMonitor.accent,
    hint: AppColorsMonitor.textHint,
    surface: AppColorsMonitor.surface,
    background: AppColorsMonitor.background,
    success: AppColorsMonitor.success,
    coin: AppColorsMonitor.coin,
    xp: AppColorsMonitor.xp,
    error: AppColorsMonitor.error,
    unreadIndicator: AppColorsMonitor.accent,
  );

  /// Повертає кольорову схему на основі режиму теми.
  static _FeedColors fromBrightness(Brightness brightness) {
    return brightness == Brightness.dark
        ? _FeedColors.dark()
        : _FeedColors.light();
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Допоміжні утиліти для валідації та обробки даних стрічки
// ═══════════════════════════════════════════════════════════════════════════

/// Містить статичні методи для валідації та обробки даних
/// у контексті стрічки мотивації.
class _FeedUtils {
  /// Не дозволяє створення екземплярів.
  _FeedUtils._();

  /// Валідує пошуковий запит перед застосуванням.
  ///
  /// [query] — пошуковий запит для перевірки.
  /// Повертає очищений рядок або порожній рядок, якщо запит невалідний.
  static String validateSearchQuery(String query) {
    if (query.isEmpty) return '';
    final trimmed = query.trim();
    if (trimmed.length < _kMinSearchLength) return '';
    if (trimmed.length > _kMaxSearchQueryLength) {
      return trimmed.substring(0, _kMaxSearchLength);
    }
    return trimmed;
  }

  /// Перевіряє, чи повідомлення належить до однієї з популярних порад.
  ///
  /// [msg] — повідомлення для перевірки.
  static bool isTopMessage(_MotivationMsg msg) =>
      msg.popularityScore >= _kTopPopularityThreshold;

  /// Перевіряє, чи повідомлення є «тrending» (популярність > 85).
  ///
  /// [msg] — повідомлення для перевірки.
  static bool isTrending(_MotivationMsg msg) =>
      msg.popularityScore >= 85;

  /// Обчислює кількість символів у пошуковому запиті, що залишилися.
  ///
  /// [query] — поточний пошуковий запит.
  static int remainingSearchChars(String query) =>
      (_kMaxSearchQueryLength - query.length).clamp(0, _kMaxSearchQuery);

  /// Форматує популярність як бар-рядок тексту (визуальний індикатор).
  ///
  /// [score] — рейтинг популярності (0-100).
  static String popularityBar(int score) {
    final filled = (score / 10).clamp(0, 10);
    final empty = 10 - filled;
    return '█' * filled + '░' * empty;
  }

  /// Генерує унікальний ключ кешу для комбінації фільтрів.
  ///
  /// Використовується для [ValueKey] у [AnimatedSwitcher].
  static String buildFilterCacheKey({
    required bool showFavoritesOnly,
    required String categoryFilter,
    required String searchQuery,
    required _SortOrder sortOrder,
    required int refreshCount,
  }) {
    return 'fav=$showFavoritesOnly|'
        'cat=$categoryFilter|'
        'q=${searchQuery.length}|'
        'sort=$sortOrder|'
        'r=$refreshCount';
  }

  /// Перевіряє, чи користувач активно взаємодіє зі стрічкою.
  ///
  /// [refreshCount] — кількість оновлень.
  /// [searchCount] — кількість пошукових запитів.
  static bool isPowerUser(int refreshCount, int searchCount) =>
      refreshCount > 5 || searchCount > 3;

  /// Обчислює «оцінку залученості» користувача (0.0 — 1.0).
  ///
  /// Базується на кількості прочитаних, улюблених та пошукових дій.
  static double engagementScore({
    required int totalMessages,
    required int readCount,
    required int favoriteCount,
    required int searchCount,
  }) {
    if (totalMessages == 0) return 0.0;
    final readRatio = (readCount / totalMessages).clamp(0.0, 1.0);
    final favRatio = (favoriteCount / _kMaxFavoritesCount).clamp(0.0, 1.0);
    final searchBonus = (searchCount * 0.02).clamp(0.0, 0.1);
    return ((readRatio * 0.5) + (favRatio * 0.3) + searchBonus).clamp(0.0, 1.0);
  }

  /// Форматує час з моменту останнього оновлення стрічки.
  ///
  /// [lastRefreshTime] — час останнього оновлення.
  static String formatLastRefresh(DateTime? lastRefreshTime) {
    if (lastRefreshTime == null) return 'ще не оновлювалась';
    final diff = DateTime.now().difference(lastRefreshTime);
    if (diff.inSeconds < 10) return 'щойно';
    if (diff.inSeconds < 60) return '${diff.inSeconds}с тому';
    if (diff.inMinutes < 60) return '${diff.inMinutes}хв тому';
    if (diff.inHours < 24) return '${diff.inHours}год тому';
    return '${lastRefreshTime.day}.${lastRefreshTime.month}';
  }

  /// Генерує текст для повідомлення-нагадування про нові поради.
  ///
  /// [unreadCount] — кількість непрочитаних повідомлень.
  static String notificationText(int unreadCount) {
    if (unreadCount == 0) return '';
    if (unreadCount == 1) return 'У тебе 1 нова порада!';
    if (unreadCount < 5) return 'У тебе $unreadCount нові поради!';
    if (unreadCount < 10) return '$unreadCount нових порад чекають на тебе!';
    return 'Більше $unreadCount порад у стрічці!';
  }

  /// Створює підсумковий звіт про використання стрічки за сесію.
  ///
  /// [refreshCount] — кількість оновлень.
  /// [searchCount] — кількість пошукових запитів.
  /// [readCount] — кількість прочитаних повідомлень.
  /// [favoriteCount] — кількість улюблених повідомлень.
  /// [sessionDuration] — тривалість сесії.
  static String buildSessionReport({
    required int refreshCount,
    required int searchCount,
    required int readCount,
    required int favoriteCount,
    required Duration sessionDuration,
  }) {
    final mins = sessionDuration.inMinutes;
    final lines = <String>[
      '── Звіт стрічки ──',
      'Оновлень: $refreshCount',
      'Пошуків: $searchCount',
      'Прочитано: $readCount',
      'Улюблених: $favoriteCount',
      'Час сесії: ${mins}хв',
    ];
    return lines.join('\n');
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Додаткові константи стрічки мотивації
// ═══════════════════════════════════════════════════════════════════════════

/// Максимальна довжина тексту для попереднього перегляду повідомлення.
const int _kMaxPreviewLength = 120;

/// Кількість повідомлень у «швидкій колекції» для слайдера.
const int _kQuickCollectionCount = 5;

/// Мінімальна тривалість сесії для активації power-user режиму (секунди).
const int _kPowerUserSessionSeconds = 120;

/// Максимальна кількість символів у пошуковому запиті для badge display.
const int _kBadgeSearchThreshold = 5;

/// Мінімальна кількість повідомлень для відображення digest badge.
const int _kDigestMinMessages = 7;

/// Тривалість анімації badge pulse (мілісекунди).
const int _kBadgePulseDurationMs = 1200;

/// Тривалість delay для staggered анімації карток (мілісекунди на картку).
const int _kStaggerDelayMs = 50;

/// Кількість повідомлень для одного «batch» експорту.
const int _kExportBatchSize = 20;

/// Затримка між batch-експортами (мілісекунди).
const int _kExportBatchDelayMs = 100;

/// Формат дати для повідомлень стрічки.
const String _kDateFormatPattern = 'dd.MM.yyyy';

/// Префікс для ключів кешу повідомлень.
const String _kCacheKeyPrefix = 'feed_msg_';

/// Максимальний розмір тексту для clipboard копіювання.
const int _kMaxClipboardLength = 500;

/// Кількість повідомлень у «mini-feed» для віджетів.
const int _kMiniFeedCount = 3;

/// Тривалість перебування повідомлення у focus-режимі (секунди).
const int _kFocusModeDurationSec = 30;

// ═══════════════════════════════════════════════════════════════════════════
// Розширення для роботи з колекціями повідомлень
// ═══════════════════════════════════════════════════════════════════════════

/// Розширення для списку повідомлень з пакетними операціями.
extension _MotivationListExtension on List<_MotivationMsg> {
  /// Фільтрує повідомлення за категорією.
  ///
  /// [category] — категорія для фільтрації.
  /// Повертає новий список з повідомленнями вказаної категорії.
  List<_MotivationMsg> filterByCategory(String category) {
    if (category == 'всі') return this;
    return where((m) => m.isInCategory(category)).toList();
  }

  /// Фільтрує повідомлення за пошуковим запитом.
  ///
  /// [query] — пошуковий запит (мінімум [_kMinSearchLength] символи).
  /// Повертає повідомлення, що містять запит у тексті, категорії чи авторі.
  List<_MotivationMsg> filterByQuery(String query) {
    if (query.length < _kMinSearchLength) return this;
    return where((m) => m.matchesQuery(query)).toList();
  }

  /// Сортує повідомлення за популярністю (спадання).
  ///
  /// Повертає новий список, відсортований від найпопулярнішого.
  List<_MotivationMsg> sortByPopularity() {
    final copy = List<_MotivationMsg>.from(this);
    copy.sort((a, b) => b.popularityScore.compareTo(a.popularityScore));
    return copy;
  }

  /// Сортує повідомлення за категорією (алфавітно).
  ///
  /// Повертає новий список, відсортований за назвою категорії.
  List<_MotivationMsg> sortByCategory() {
    final copy = List<_MotivationMsg>.from(this);
    copy.sort((a, b) => a.category.compareTo(b.category));
    return copy;
  }

  /// Повертає повідомлення з популярністю вище порогу.
  ///
  /// [threshold] — мінімальний рейтинг популярності (0-100).
  List<_MotivationMsg> abovePopularity(int threshold) {
    return where((m) => m.popularityScore >= threshold).toList();
  }

  /// Повертає повідомлення, що мають автора.
  ///
  /// Повертає новий список, що містить лише повідомлення з непорожнім полем [author].
  List<_MotivationMsg> withAuthor() {
    return where((m) => m.author != null && m.author!.isNotEmpty).toList();
  }

  /// Повертає перші [count] повідомлень для прев'ю.
  ///
  /// [count] — кількість повідомлень для повернення.
  List<_MotivationMsg> takePreview({int count = _kMiniFeedCount}) {
    return take(count.clamp(1, length)).toList();
  }

  /// Розбиває список на частини для пакетної обробки.
  ///
  /// [batchSize] — розмір однієї партії.
  List<List<_MotivationMsg>> batched(int batchSize) {
    if (isEmpty) return [];
    final batches = <List<_MotivationMsg>>[];
    for (var i = 0; i < length; i += batchSize) {
      final end = (i + batchSize).clamp(0, length);
      batches.add(sublist(i, end));
    }
    return batches;
  }

  /// Обчислює медіанний рейтинг популярності.
  ///
  /// Повертає медіану або 0, якщо список порожній.
  double medianPopularity() {
    if (isEmpty) return 0.0;
    final sorted = List<_MotivationMsg>.from(this)
      ..sort((a, b) => a.popularityScore.compareTo(b.popularityScore));
    final mid = sorted.length ~/ 2;
    if (sorted.length % 2 == 0) {
      return (sorted[mid - 1].popularityScore + sorted[mid].popularityScore) / 2.0;
    }
    return sorted[mid].popularityScore.toDouble();
  }

  /// Повертає кількість повідомлень у кожній категорії.
  ///
  /// Результат містить пари «категорія: кількість».
  Map<String, int> countByCategory() {
    final counts = <String, int>{};
    for (final msg in this) {
      counts[msg.category] = (counts[msg.category] ?? 0) + 1;
    }
    return counts;
  }

  /// Перевіряє, чи всі повідомлення прочитані за індексами.
  ///
  /// [readIndices] — множина індексів прочитаних повідомлень.
  bool allRead(Set<int> readIndices) {
    return asMap().entries.every((e) => readIndices.contains(e.key));
  }

  /// Повертає унікальні категорії повідомлень.
  ///
  /// Повертає відсортований список унікальних категорій.
  List<String> uniqueCategories() {
    return map((m) => m.category).toSet().toList()..sort();
  }

  /// Форматує повідомлення для експорту (рядки через перенос).
  ///
  /// Повертає рядок, де кожне повідомлення на окремому рядку.
  String formatForExport() {
    return asMap().entries.map((e) {
      final msg = e.value;
      final author = msg.author ?? 'Nexora';
      return '${e.key + 1}. [${msg.category}] ${msg.text} — $author';
    }).join('\n');
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Валідатор даних стрічки мотивації
// ═══════════════════════════════════════════════════════════════════════════

/// Клас для валідації даних стрічки мотивації.
///
/// Надає методи для перевірки коректності введених даних,
/// конфігураційних параметрів та обмежень.
class _FeedValidator {
  /// Не дозволяє створення екземплярів.
  _FeedValidator._();

  /// Перевіряє коректність пошукового запиту.
  ///
  /// [query] — рядок для перевірки.
  /// Повертає `true`, якщо запит відповідає вимогам довжини та формату.
  static bool isValidSearchQuery(String query) {
    if (query.isEmpty) return true;
    final trimmed = query.trim();
    if (trimmed.length < _kMinSearchLength) return false;
    if (trimmed.length > _kMaxSearchQueryLength) return false;
    return true;
  }

  /// Перевіряє, чи індекс повідомлення знаходиться в допустимих межах.
  ///
  /// [index] — індекс для перевірки.
  /// [totalMessages] — загальна кількість повідомлень.
  static bool isValidMessageIndex(int index, int totalMessages) {
    return index >= 0 && index < totalMessages;
  }

  /// Перевіряє, чи кількість улюблених повідомлень в межах ліміту.
  ///
  /// [currentCount] — поточна кількість.
  /// Повертає `true`, якщо ще можна додавати улюблені.
  static bool canAddFavorite(int currentCount) {
    return currentCount < _kMaxFavoritesCount;
  }

  /// Перевіряє, чи кількість розгорнутих карток в межах ліміту.
  ///
  /// [currentCount] — поточна кількість розгорнутих карток.
  static bool canExpandCard(int currentCount) {
    return currentCount < _kMaxExpandedCards;
  }

  /// Перевіряє, чи популярність повідомлення в допустимому діапазоні.
  ///
  /// [score] — рейтинг популярності для перевірки.
  static bool isValidPopularityScore(int score) {
    return score >= 0 && score <= 100;
  }

  /// Перевіряє, чи розмір тексту повідомлення для поділу в межах ліміту.
  ///
  /// [text] — текст повідомлення.
  static bool isValidShareText(String text) {
    if (text.isEmpty) return false;
    return text.length <= _kMaxClipboardLength;
  }

  /// Перевіряє, чи кількість повідомлень для експорту дозволена.
  ///
  /// [count] — кількість повідомлень.
  static bool isValidExportCount(int count) {
    return count > 0 && count <= _messages.length;
  }

  /// Перевіряє, чи категорія є допустимою для фільтрації.
  ///
  /// [category] — назва категорії.
  static bool isValidCategory(String category) {
    return _categories.contains(category);
  }

  /// Повертає очищений пошуковий запит.
  ///
  /// [query] — необроблений запит користувача.
  /// Повертає рядок, що відповідає всім обмеженням.
  static String sanitizedQuery(String query) {
    if (query.isEmpty) return '';
    final trimmed = query.trim();
    if (trimmed.length > _kMaxSearchQueryLength) {
      return trimmed.substring(0, _kMaxSearchQueryLength);
    }
    return trimmed;
  }

  /// Перевіряє коректність параметрів пагінації.
  ///
  /// [displayedCount] — поточна кількість відображених.
  /// [totalCount] — загальна кількість.
  static bool isValidPagination(int displayedCount, int totalCount) {
    return displayedCount > 0 && displayedCount <= totalCount;
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Кеш повідомлень стрічки для оптимізації продуктивності
// ═══════════════════════════════════════════════════════════════════════════

/// Клас для кешування повідомлень стрічки.
///
/// Зберігає оброблені дані (відфільтровані списки, зображення прев'ю)
/// для зменшення кількості обчислень при rebuild.
class _FeedCache {
  /// Створює кеш з початковими значеннями.
  _FeedCache();

  /// Внутрішнє сховище кешованих даних.
  final Map<String, dynamic> _cache = {};

  /// Максимальна кількість записів у кеші.
  static const int _kMaxCacheEntries = 50;

  /// Зберігає значення в кеш за ключем.
  ///
  /// [key] — унікальний ключ для кешування.
  /// [value] — значення для збереження.
  void put(String key, dynamic value) {
    if (_cache.length >= _kMaxCacheEntries) {
      _cache.remove(_cache.keys.first);
    }
    _cache[key] = value;
  }

  /// Отримує значення з кешу за ключем.
  ///
  /// [key] — унікальний ключ для пошуку.
  /// Повертає `null`, якщо запис не знайдено.
  T? get<T>(String key) {
    final value = _cache[key];
    if (value is T) return value;
    return null;
  }

  /// Перевіряє, чи є запис у кеші.
  ///
  /// [key] — унікальний ключ для перевірки.
  bool contains(String key) => _cache.containsKey(key);

  /// Видаляє запис з кешу за ключем.
  ///
  /// [key] — унікальний ключ для видалення.
  void remove(String key) {
    _cache.remove(key);
  }

  /// Очищає весь кеш.
  void clear() {
    _cache.clear();
  }

  /// Повертає поточну кількість записів у кеші.
  int get size => _cache.length;

  /// Повертає `true`, якщо кеш порожній.
  bool get isEmpty => _cache.isEmpty;

  /// Генерує ключ кешу для комбінації параметрів фільтрації.
  ///
  /// Використовується для уніфікації ключів при кешуванні.
  static String buildKey({
    required String category,
    required String query,
    required bool favoritesOnly,
    required String sort,
  }) {
    return '${_kCacheKeyPrefix}cat=$category&q=$query&fav=$favoritesOnly&sort=$sort';
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Темо-залежний будівник декорацій карток стрічки
// ═══════════════════════════════════════════════════════════════════════════

/// Будівник декорацій для карток стрічки мотивації.
///
/// Надає готові методи для створення темо-залежних
/// декорацій: градієнтів, рамок, тіней та backdrop-ефектів.
class _FeedCardDecorations {
  /// Не дозволяє створення екземплярів.
  _FeedCardDecorations._();

  /// Створює декорацію для звичайної картки.
  ///
  /// [cardColor] — колір фону картки.
  /// [borderColor] — колір рамки.
  /// [isRead] — чи повідомлення прочитане.
  static BoxDecoration standardCard({
    required Color cardColor,
    required Color borderColor,
    bool isRead = false,
    bool isFavorite = false,
  }) {
    return BoxDecoration(
      color: cardColor,
      borderRadius: BorderRadius.circular(Radii.lg),
      border: Border.all(
        color: isFavorite
            ? AppColorsPS5.coin.withOpacity(0.3)
            : (isRead ? borderColor.withOpacity(0.5) : borderColor),
      ),
    );
  }

  /// Створює декорацію з градієнтом для популярних повідомлень.
  ///
  /// [accent] — акцентний колір.
  static BoxDecoration popularCardGradient(Color accent) {
    return BoxDecoration(
      gradient: LinearGradient(
        colors: [
          accent.withOpacity(0.08),
          accent.withOpacity(0.02),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(Radii.lg),
      border: Border.all(color: accent.withOpacity(0.2)),
    );
  }

  /// Створює декорацію для картки тижневого дайджесту.
  ///
  /// [accent] — акцентний колір.
  static BoxDecoration digestCard(Color accent) {
    return BoxDecoration(
      gradient: LinearGradient(
        colors: [
          accent.withOpacity(0.06),
          accent.withOpacity(0.02),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(Radii.lg),
      border: Border.all(color: accent.withOpacity(0.15)),
    );
  }

  /// Створює декорацію для картки помилки.
  static BoxDecoration errorCard() {
    return BoxDecoration(
      color: AppColorsPS5.error.withOpacity(0.08),
      borderRadius: BorderRadius.circular(Radii.sm),
      border: Border.all(color: AppColorsPS5.error.withOpacity(0.2)),
    );
  }

  /// Створює декорацію для картки порожнього стану.
  ///
  /// [accent] — акцентний колір.
  static BoxDecoration emptyStateCard(Color accent) {
    return BoxDecoration(
      color: accent.withOpacity(0.04),
      borderRadius: BorderRadius.circular(Radii.md),
      border: Border.all(color: accent.withOpacity(0.12)),
    );
  }

  /// Створює декорацію для бейджа категорії.
  ///
  /// [color] — колір категорії.
  static BoxDecoration categoryBadge(Color color) {
    return BoxDecoration(
      color: color.withOpacity(0.15),
      borderRadius: BorderRadius.circular(Radii.sm),
    );
  }

  /// Створює декорацію для unread dot індикатора.
  ///
  /// [color] — колір індикатора.
  static BoxDecoration unreadDot(Color color) {
    return BoxDecoration(
      color: color,
      shape: BoxShape.circle,
    );
  }

  /// Створює декорацію для кнопки завантаження ще.
  ///
  /// [accent] — акцентний колір.
  static BoxDecoration loadMoreButton(Color accent) {
    return BoxDecoration(
      color: accent.withOpacity(0.04),
      borderRadius: BorderRadius.circular(Radii.md),
      border: Border.all(color: accent.withOpacity(0.1)),
    );
  }

  /// Створює декорацію для контейнера статистики.
  ///
  /// [accent] — акцентний колір.
  static BoxDecoration statsContainer(Color accent) {
    return BoxDecoration(
      color: accent.withOpacity(0.04),
      borderRadius: BorderRadius.circular(Radii.sm),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Провайдер підказок (tips) для стрічки мотивації
// ═══════════════════════════════════════════════════════════════════════════

/// Провайдер контекстних підказок для користувача стрічки.
///
/// Надає текстові підказки, що залежать від дій користувача:
/// порожній стан, перший запуск, активне використання тощо.
class _FeedTipProvider {
  /// Не дозволяє створення екземплярів.
  _FeedTipProvider._();

  /// Повертає підказку для порожнього списку улюблених.
  static String emptyFavoritesTip() {
    return 'Натисни ★ на пораді, щоб додати її в улюблені';
  }

  /// Повертає підказку для порожнього результату пошуку.
  static String emptySearchTip() {
    return 'Спробуй змінити фільтр або пошуковий запит';
  }

  /// Повертає підказку для нового користувача.
  static String firstVisitTip() {
    return 'Ласкаво просимо до стрічки мотивації! Тут ти знайдеш поради для заощадження.';
  }

  /// Повертає підказку для активного користувача (power user).
  static String powerUserTip(int refreshCount) {
    return 'Ти активний користувач! Вже $refreshCount оновлень стрічки.';
  }

  /// Повертає підказку при досягненні ліміту улюблених.
  static String favoritesLimitTip() {
    return 'Ти досяг ліміту улюблених повідомлень. Видаліть старі, щоб додати нові.';
  }

  /// Повертає підказку для заохочення читання.
  static String readingEncouragementTip(double readPercentage) {
    if (readPercentage >= 100) {
      return 'Вітаємо! Ти прочитав всі поради!';
    } else if (readPercentage >= 75) {
      return 'Майже все прочитано! Залишилось трохи!';
    } else if (readPercentage >= 50) {
      return 'Ти вже прочитав половину порад. Продовжуй!';
    } else if (readPercentage >= 25) {
      return 'Хорошій початок! Читай далі!';
    }
    return 'Почни читати поради — вони допоможуть тобі заощадити!';
  }

  /// Повертає випадкову підказку для щоденної мотивації.
  ///
  /// [seed] — число для генерації «випадкової» підказки.
  static String randomDailyTip(int seed) {
    final tips = [
      'Сьогодні — чудовий день для заощадження!',
      'Навіть маленька сума має значення!',
      'Твоя скарбничка чекає на тебе!',
      'Кожен внесок — це крок до свободи!',
      'Не чекай ідеального моменту — почни зараз!',
    ];
    return tips[seed % tips.length];
  }

  /// Повертає підказку для недавнього пошуку.
  ///
  /// [query] — пошуковий запит користувача.
  /// [resultCount] — кількість знайдених результатів.
  static String searchResultTip(String query, int resultCount) {
    if (resultCount == 0) {
      return 'За запитом «$query» нічого не знайдено.';
    } else if (resultCount == 1) {
      return 'Знайдено 1 пораду за запитом «$query».';
    } else {
      return 'Знайдено $resultCount порад за запитом «$query».';
    }
  }

  /// Повертає підказку для поділу повідомлення.
  static String shareTip(String preview) {
    return 'Скопійовано в буфер обміну: «$preview»';
  }

  /// Повертає набір підказок для онбордингу нового користувача.
  ///
  /// Повертає список з 3 підказок для навчання.
  static List<String> onboardingTips() {
    return [
      '📋 Свайпай картки для перегляду деталей',
      '⭐ Тапай ★ щоб зберегти улюблені поради',
      '🔍 Використовуй пошук для швидкого пошуку',
    ];
  }
}
