import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_radii.dart';
import '../../../../core/constants/app_shadows.dart';
import '../../../../core/constants/app_durations.dart';
import '../../../../core/constants/app_easings.dart';
import '../../../../core/extensions/build_context_ext.dart';
import '../../../../core/widgets/app_button_primary.dart';
import '../../../../core/widgets/app_button_secondary.dart';

/// Екран «Нова мета?» — вибір PS5/Монітор, інша ціль, пауза.
///
/// Містить:
/// - Вибір типу цілі (PS5 / Монітор / Власна картки)
/// - Введення власного типу цілі
/// - Поле вводу суми з пресетами для кожного типу
/// - Поле назви цілі з плейсхолдером
/// - Опціональний вибір дати завершення
/// - Прев'ю щоденної суми
/// - Кнопку «Створити ціль»
/// - Валідацію всіх полів
/// - Стан завантаження під час створення
/// - Анімацію успіху при створенні
/// - Галерею шаблонів цілей (8 шаблонів)
/// - Підказки на основі історії
/// - Вибір емодзі/зображення для цілі
/// - Перегляд категорій цілей
/// - Індикатор складності (легко/середньо/важко)
/// - Оцінку терміну виконання
/// - Порівняння з подібними цілями
/// - Заглушки спільнотних цілей
class NewGoalScreen extends StatefulWidget {
  const NewGoalScreen({super.key});

  @override
  State<NewGoalScreen> createState() => _NewGoalScreenState();
}

class _NewGoalScreenState extends State<NewGoalScreen> {
  // ─── State ──────────────────────────────────────────────────────────────

  String? _selectedType; // 'ps5' | 'monitor' | 'custom'
  String _customTypeName = '';
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  DateTime? _selectedDate;
  bool _isCreating = false;
  bool _showSuccess = false;
  String _selectedEmoji = '🎯';
  bool _showTemplates = false;
  bool _showDifficulty = false;

  final _formKey = GlobalKey<FormState>();

  // Presets per type
  static const _presets = {
    'ps5': [20000, 25000, 18000, 30000],
    'monitor': [15000, 20000, 25000, 35000],
    'custom': [5000, 10000, 20000, 50000],
  };

  static const _typeInfo = {
    'ps5': {
      'name': 'PlayStation 5',
      'subtitle': 'Оновлена консоля нового покоління',
      'icon': Icons.gamepad_rounded,
      'placeholder': 'Моя PS5',
    },
    'monitor': {
      'name': 'Монітор',
      'subtitle': 'Професійний 27" 4K монітор',
      'icon': Icons.desktop_windows_rounded,
      'placeholder': 'Мій монітор',
    },
    'custom': {
      'name': 'Власна ціль',
      'subtitle': 'Створи свою унікальну мету',
      'icon': Icons.flag_rounded,
      'placeholder': 'Назва цілі',
    },
  };

  /// 8 шаблонів цілей для галереї.
  static const _goalTemplates = [
    _GoalTemplate(emoji: '🎮', name: 'PlayStation 5', amount: 25000, category: 'Геймінг', difficulty: 'Середньо'),
    _GoalTemplate(emoji: '🖥️', name: '4K Монітор', amount: 18000, category: 'Техніка', difficulty: 'Легко'),
    _GoalTemplate(emoji: '✈️', name: 'Подорож до Європи', amount: 40000, category: 'Подорожі', difficulty: 'Важко'),
    _GoalTemplate(emoji: '🚗', name: 'Автомобіль', amount: 300000, category: 'Транспорт', difficulty: 'Важко'),
    _GoalTemplate(emoji: '📱', name: 'Новий iPhone', amount: 35000, category: 'Техніка', difficulty: 'Середньо'),
    _GoalTemplate(emoji: '📚', name: 'Онлайн курси', amount: 5000, category: 'Освіта', difficulty: 'Легко'),
    _GoalTemplate(emoji: '🏠', name: 'Ремонт кімнати', amount: 50000, category: 'Житло', difficulty: 'Середньо'),
    _GoalTemplate(emoji: '📷', name: 'Фотоапарат', amount: 25000, category: 'Хобі', difficulty: 'Середньо'),
  ];

  /// 12 емодзі для вибору іконки цілі.
  static const _goalEmojis = [
    '🎯', '🎮', '🖥️', '✈️', '🚗', '📱', '📚', '🏠',
    '📷', '💰', '🎁', '⭐', '🏆', '💎', '🎉', '🚀',
  ];

  /// Підказки на основі історії (імітація).
  static const _historySuggestions = [
    'Попередня ціль «PS5» досягнута за 2 місяці. Спробуй Монітор!',
    'Ти успішно накопичував по 200 грн/день. Цей темп працює!',
    'Автоплатіж допоміг заощадити 30% більше минулого разу.',
  ];

  /// Категорії для перегляду.
  static const _categories = [
    '🎮 Геймінг', '🖥️ Техніка', '✈️ Подорожі', '🚗 Транспорт',
    '📚 Освіта', '🏠 Житло', '📱 Гаджети', '📷 Хобі',
    '💰 Інвестиції', '🎁 Подарунки', '🎵 Розваги', '⚽ Спорт',
  ];

  /// Validation rules for goal creation form fields.
  static const _minGoalAmount = 100.0;
  static const _maxGoalAmount = 1000000.0;
  static const _minNameLength = 2;
  static const _maxNameLength = 50;

  /// Predefined goal difficulty thresholds (in UAH).
  static const _difficultyThresholds = [
    (5000, '🌱 Легко'),
    (20000, '💪 Середньо'),
    (100000, '🔥 Важко'),
    (double.infinity, '🏆 Експерт'),
  ];

  /// Currency symbols for amount display.
  static const _currencySymbol = '₴';
  static const _currencyCode = 'UAH';

  /// Community goals count (mock data for social proof).
  static const _communityGoalCounts = {
    'ps5': 1234,
    'monitor': 856,
    'custom': 3421,
  };

  /// Popular time period suggestions for date picker.
  static const _timePeriodSuggestions = [
    ('1 місяць', 30),
    ('3 місяці', 90),
    ('6 місяців', 180),
    ('1 рік', 365),
  ];

  /// Achievement rewards for creating the first goal.
  static const _firstGoalRewards = {
    'xp': 25,
    'coins': 10,
    'badge': '⭐ Перша ціль',
  };

  /// Track whether the amount field has been touched by the user.
  bool _amountFieldTouched = false;

  String get _effectiveType => _selectedType ?? 'custom';
  int get _dailyAmount {
    final amount = double.tryParse(_amountController.text) ?? 0;
    if (amount <= 0) return 0;
    return (amount / 30).ceil();
  }

  /// Індикатор складності на основі суми.
  String get _difficultyLabel {
    final amount = double.tryParse(_amountController.text) ?? 0;
    if (amount <= 5000) return '🌱 Легко';
    if (amount <= 20000) return '💪 Середньо';
    if (amount <= 100000) return '🔥 Важко';
    return '🏆 Експерт';
  }

  /// Оцінка терміну виконання.
  String get _estimatedTime {
    final amount = double.tryParse(_amountController.text) ?? 0;
    if (amount <= 0) return '—';
    final daily = 200; // середній внесок
    final days = (amount / daily).ceil();
    if (days <= 30) return '~${days} дн';
    if (days <= 365) return '~${(days / 30).ceil()} міс';
    return '~${(days / 365).toStringAsFixed(1)} рок';
  }

  /// The estimated daily amount based on the current amount and
  /// a standard 30-day month.
  double get _estimatedDailyAmount {
    final amount = double.tryParse(_amountController.text) ?? 0;
    if (amount <= 0 || !widget.selectedDate.isAfter(DateTime.now())) return 0;
    final days = widget.selectedDate!.difference(DateTime.now()).inDays;
    if (days <= 0) return amount;
    return amount / days;
  }

  /// The estimated daily amount formatted for display.
  String get _estimatedDailyFormatted {
    final daily = _estimatedDailyAmount;
    if (daily <= 0) return '';
    return '${daily.toStringAsFixed(0)} грн/день';
}

  /// The number of days remaining until the selected deadline.
  int get _daysRemaining {
    if (widget.selectedDate == null) return 0;
    return widget.selectedDate!.difference(DateTime.now()).inDays;
  }

  /// The formatted remaining days string.
  String get _daysRemainingFormatted {
    final days = _daysRemaining;
    if (days <= 0) return '';
    return '$days дн залишилось';
 }

  /// Whether the selected amount is considered a "stretch goal" (requires
  /// more than 500 UAH/day to complete on time).
  bool get _isStretchGoal {
    final daily = _estimatedDailyAmount;
    return daily > 500;
  }

  /// The recommended daily contribution based on the amount and deadline.
  String get _recommendedDaily {
    final amount = double.tryParse(_amountController.text) ?? 0;
    final days = _daysRemaining;
    if (amount <= 0 || days <= 0) return '';
    final daily = amount / days;
    if (daily < 50) return '${daily.toStringAsFixed(0)} грн/день (легко!)';
    if (daily < 300) return '${daily.toStringAsFixed(0)} грн/день';
    return '${daily.toStringAsFixed(0)} грн/день (потребує дисципліни)';
 }

  bool _validate() {
    if (_selectedType == null) return false;
    if (_selectedType == 'custom' && _customTypeName.trim().isEmpty) return false;
    final amount = double.tryParse(_amountController.text) ?? 0;
    if (amount < 100) return false;
    return true;
  }

  /// Extended validation with descriptive error messages.
  /// Returns `null` if valid, or a human-readable error string.
  String? _validateWithMessage() {
    if (_selectedType == null) {
      return 'Обери тип цілі';
    }
    if (_selectedType == 'custom' && _customTypeName.trim().isEmpty) {
    return 'Введи назву типу цілі';
  }
    final name = _nameController.text.trim();
  if (name.isEmpty) {
    return 'Введи назву цілі';
  }
  if (name.length < _minNameLength) {
    return 'Назва повинна містити мінімум $_minNameLength символи';
  }
  if (name.length > _maxNameLength) {
    return 'Назва занадто довга (макс. $_maxNameLength)';
  }
  if (!_amountFieldTouched) {
    return 'Введи цільову суму';
  }
    final amount = double.tryParse(_amountController.text) ?? 0;
  if (amount < _minGoalAmount) {
    return 'Мінімальна сума — ${_minGoalAmount.toInt()} $_currencySymbol';
  }
  if (amount > _maxGoalAmount) {
    return 'Максимальна сума — ${(_maxGoalAmount / 1000).toStringAsFixed(0)} тис. $_currencySymbol';
  }
    return null;
 }

  /// Validates the amount field in real-time.
  String? _validateAmount(String? value) {
    if (value == null || value.isEmpty) return null;
    final amount = double.tryParse(value);
    if (amount == null) return 'Введи коректне число';
    if (amount < 0) return 'Сума не може бути від\'ємною';
    if (amount > _maxGoalAmount) return 'Занадто велика сума';
    return null;
 }

  /// Validates the goal name field in real-time.
  String? _validateName(String? value) {
    if (value == null || value.isEmpty) return null;
    if (value.length < _minNameLength) {
      return 'Мінімум $_minNameLength символи';
  }
  if (value.length > _maxNameLength) {
    return 'Максимум $_maxNameLength символів';
  }
  return null;
 }

  /// Computes the difficulty tier based on the amount.
  String _computeDifficultyTier(double amount) {
    for (final threshold in _difficultyThresholds) {
      if (amount < threshold.$1) return threshold.$2;
    }
    return _difficultyThresholds.last.$2;
  }

  /// Gets a motivational message based on the current form state.
  String _getMotivationalMessage() {
    final amount = double.tryParse(_amountController.text) ?? 0;
    if (amount <= 0) return 'Обери ціль і почни накопичувати!';
    final tier = _computeDifficultyTier(amount);
    switch (tier) {
      case '🌱 Легко':
        return 'Це під силу — починай сьогодні!';
      case '💪 Середньо':
        return 'Вимагливо, але результат вартий!';
      case '🔥 Важко':
        return 'Справжня відданість — ти впораєшся!';
      default:
        return 'Легендарний виклик —历史上的сяй!';
    }
 }

  /// Formats a percentage completion for display.
  String _formatPercent(double fraction) {
    return '${(fraction * 100).toStringAsFixed(0)}%';
 }

  /// Gets the number of completed deposits for the previous goal.
  int get _previousGoalDeposits {
    // Mock implementation
    return 42;
  }

  /// Gets the total days for the previous goal.
  int get _previousGoalDays {
    // Mock implementation
    return 67;
  }

  Future<void> _createGoal() async {
    if (!_validate()) {
      context.showAppToast(
        'Заповни всі поля коректно',
        type: AppToastType.warning,
      );
      return;
    }

    setState(() => _isCreating = true);
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() {
        _isCreating = false;
        _showSuccess = true;
      });

      // Navigate after success animation
      Future.delayed(const Duration(milliseconds: 1500), () {
        if (mounted) {
          Navigator.of(context).pushNamed(
            '/set-goal',
            arguments: _effectiveType,
          );
        }
      });
    }
  }

  /// Сформувати текст поділитися результатом.
  String _generateShareText() {
    final name = _nameController.text.trim();
    final amount = double.tryParse(_amountController.text) ?? 0;
    return '🎉 Я створив(ла) ціль «$name» на $_currencySymbol${amount.toInt()} у Nexora!';
  }

  /// Determines the appropriate emoji based on selected type.
  String _getTypeEmoji(String type) {
    switch (type) {
      case 'ps5': return '🎮';
      case 'monitor': return '🖥️';
      default: return _selectedEmoji;
    }
  }

  /// Gets the gradient colors for the currently selected type.
  List<Color> _getTypeGradient(String type) {
    switch (type) {
      case 'ps5':
        return const [Color(0xFF006FCD), Color(0xFF00C6FF)];
      case 'monitor':
        return const [Color(0xFF6C5CE7), Color(0xFFA8E6CF)];
      default:
        return const [Color(0xFFFF9100), Color(0xFFFFD600)];
    }
  }

  /// Gets the icon for a given type.
  IconData _getTypeIcon(String type) {
    return (_typeInfo[type]?['icon'] as IconData?) ?? Icons.flag_rounded;
  }

  /// Computes how achievable the goal is based on average
  /// user performance data.
  String _computeAchievability() {
    final amount = double.tryParse(_amountController.text) ?? 0;
    if (amount <= 0) return '';
    final avgDaily = 200.0; // Mock average
    final days = 90; // Standard quarter
    final achievable = avgDaily * days;
    final ratio = achievable / amount;
    if (ratio >= 1.0) return 'Легко досяжно';
    if (ratio >= 0.7) return 'Потрібно зусилля';
    if (ratio >= 0.4) return 'Амбітно, але можливо';
    return 'Потребує значних зусиль';
 }

  void _selectType(String type) {
    context.haptic();
    final info = _typeInfo[type]!;
    setState(() {
      _selectedType = type;
      _nameController.text = info['placeholder'] as String;
    });
  }

  void _selectTemplate(_GoalTemplate template) {
    context.haptic();
    setState(() {
      _selectedEmoji = template.emoji;
      _nameController.text = template.name;
      _amountController.text = template.amount.toString();
      _showTemplates = false;
    });
 }

  /// Filters templates by the selected category.
  List<_GoalTemplate> _getFilteredTemplates() {
    if (_selectedType == null) return _goalTemplates;
    final categoryMap = {
      'ps5': 'Геймінг',
      'monitor': 'Техніка',
      'custom': null,
    };
    final category = categoryMap[_selectedType];
    if (category == null) return _goalTemplates;
    return _goalTemplates.where((t) => t.category == category).toList();
 }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 90)),
      firstDate: DateTime.now().add(const Duration(days: 7)),
      lastDate: DateTime.now().add(const Duration(days: 730)),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: Theme.of(context).colorScheme.copyWith(
            primary: AppColorsPS5.accent,
          ),
        ),
        child: child!,
      ),
    );
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 90)),
      firstDate: DateTime.now().add(const Duration(days: 7)),
      lastDate: DateTime.now().add(const Duration(days: 730)),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: Theme.of(context).colorScheme.copyWith(
            primary: AppColorsPS5.accent,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  /// Resets the entire form to its initial state.
  void _resetForm() {
    HapticService.lightTap();
    setState(() {
      _selectedType = null;
      _customTypeName = '';
      _nameController.clear();
      _amountController.clear();
      _selectedDate = null;
      _selectedEmoji = '🎯';
      _showTemplates = false;
      _showDifficulty = false;
      _amountFieldTouched = false;
    });
  }

  /// Quick-selects a popular time period from suggestions.
  void _selectTimePeriod(String label, int days) {
    HapticService.selection();
    final targetDate = DateTime.now().add(Duration(days: days));
    setState(() => _selectedDate = targetDate);
 }

  // ── Additional computed properties ──────────────────────────────

  /// Whether the form currently has any data entered (type, name,
  /// or amount). Used to conditionally show a "clear" button.
  bool get _hasAnyFormData {
    return _selectedType != null ||
        _nameController.text.isNotEmpty ||
        _amountController.text.isNotEmpty;
  }

  /// The total community goal count for the currently selected type.
  /// Returns 0 if no type is selected.
  int get _communityCountForType {
    if (_selectedType == null) return 0;
    return _communityGoalCounts[_selectedType] ?? 0;
  }

  /// The formatted community count string (e.g. "1 234").
  String get _formattedCommunityCount {
    final count = _communityCountForType;
    if (count <= 0) return '';
    return count.toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]} ',
    );
  }

  /// Whether the selected deadline is within the next 30 days
  /// (considered an aggressive timeline).
  bool get _isAggressiveTimeline {
    if (_selectedDate == null) return false;
    final days = _selectedDate!.difference(DateTime.now()).inDays;
    return days > 0 && days <= 30;
  }

  /// Whether the selected deadline is more than 1 year away.
  bool get _isLongTimeline {
    if (_selectedDate == null) return false;
    final days = _selectedDate!.difference(DateTime.now()).inDays;
    return days > 365;
  }

  /// The current form completion percentage (0-100).
  /// Computed based on which fields are filled.
  int get _formCompletionPercent {
    int score = 0;
    const totalSteps = 5;
    if (_selectedType != null) score++;
    if (_nameController.text.trim().isNotEmpty) score++;
    if (double.tryParse(_amountController.text) != null &&
        (double.tryParse(_amountController.text) ?? 0) > 0) {
      score++;
    }
    if (_selectedEmoji != '🎯') score++;
    if (_selectedDate != null) score++;
    return (score / totalSteps * 100).round();
  }

  /// A human-readable label for the form completion stage.
  String get _formCompletionLabel {
    final pct = _formCompletionPercent;
    if (pct == 0) return 'Почни створення цілі';
    if (pct < 40) return 'Майже почав...';
    if (pct < 60) return 'Хороший початок!';
    if (pct < 80) return 'Майже готово!';
    if (pct < 100) return 'Ще один крок!';
    return 'Все готово! 🎉';
  }

  /// The colour representing the form completion progress.
  Color _formCompletionColor() {
    final pct = _formCompletionPercent;
    if (pct >= 80) return AppColorsPS5.success;
    if (pct >= 50) return AppColorsPS5.accent;
    return AppColorsPS5.warning;
  }

  // ── Additional validation methods ──────────────────────────────

  /// Validates the selected date is not in the past.
  /// Returns an error message if invalid, or `null` if fine.
  String? _validateSelectedDate() {
    if (_selectedDate == null) return null;
    if (_selectedDate!.isBefore(DateTime.now())) {
      return 'Дата не може бути в минулому';
    }
    if (_selectedDate!.difference(DateTime.now()).inDays < 7) {
      return 'Мінімум 7 днів від сьогодні';
    }
    return null;
  }

  /// Validates that the form state is internally consistent.
  /// Checks for edge cases like extremely short or long deadlines
  /// relative to the selected amount.
  String? _validateFormConsistency() {
    final amount = double.tryParse(_amountController.text) ?? 0;
    if (amount <= 0 || _selectedDate == null) return null;

    final days = _selectedDate!.difference(DateTime.now()).inDays;
    final dailyAmount = amount / days;

    if (dailyAmount > 10000) {
      return 'Щоденний внесок перевищує 10 000 грн. '
          'Розглянь більш реалістичний термін.';
    }
    if (dailyAmount < 1 && amount > 100) {
      return 'З такою сумою термін занадто довгий. '
          'Спробуй скоротити дедлайн.';
    }
    return null;
  }

  /// Computes the next recommended preset based on the currently
  /// entered amount. Returns the nearest preset value above or below
  /// the current input, whichever is closer.
  int? _getNearestPreset() {
    final amount = double.tryParse(_amountController.text);
    if (amount == null) return null;
    final presets = _presets[_effectiveType] ?? _presets['custom']!;
    if (presets.isEmpty) return null;

    int? nearest;
    int nearestDistance = double.maxFinite.toInt();
    for (final preset in presets) {
      final dist = (preset - amount).abs().toInt();
      if (dist < nearestDistance && dist > 0) {
        nearestDistance = dist;
        nearest = preset;
      }
    }
    return nearest;
  }

  // ── Additional widget builders ─────────────────────────────────

  /// Builds the form completion progress indicator bar.
  Widget _buildFormProgressBar(Color accent, Color subColor) {
    final pct = _formCompletionPercent;
    final color = _formCompletionColor();

    return Container(
      margin: const EdgeInsets.only(bottom: Spacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _formCompletionLabel,
                style: AppTypography.labelSmall.copyWith(
                  color: subColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '$pct%',
                style: AppTypography.labelSmall.copyWith(
                  color: color,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: pct / 100,
              backgroundColor: color.withOpacity(0.1),
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }

  /// Builds a community social proof card showing how many other
  /// users have created goals of this type.
  Widget _buildCommunityProofCard(Color accent, Color subColor) {
    if (_selectedType == null) return const SizedBox.shrink();
    final count = _formattedCommunityCount;

    return Container(
      margin: const EdgeInsets.only(bottom: Spacing.md),
      padding: const EdgeInsets.all(Spacing.sm),
      decoration: BoxDecoration(
        color: accent.withOpacity(0.04),
        borderRadius: BorderRadius.circular(Radii.sm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.groups_rounded,
            color: Color(0xFFFFD600),
            size: 16,
          ),
          const SizedBox(width: 6),
          Text(
            '$count користувачів обрали цей тип цілі',
            style: AppTypography.labelSmall.copyWith(color: subColor),
          ),
        ],
      ),
    );
  }

  /// Builds a timeline warning card when the user selects an
  /// aggressive or unusually long deadline.
  Widget _buildTimelineWarning(Color subColor) {
    if (_selectedDate == null) return const SizedBox.shrink();

    if (_isAggressiveTimeline) {
      return Container(
        margin: const EdgeInsets.only(top: Spacing.sm),
        padding: const EdgeInsets.all(Spacing.sm),
        decoration: BoxDecoration(
          color: AppColorsPS5.warning.withOpacity(0.08),
          borderRadius: BorderRadius.circular(Radii.sm),
          border: Border.all(
            color: AppColorsPS5.warning.withOpacity(0.15),
          ),
        ),
        child: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: AppColorsPS5.warning, size: 16),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                '⏰ Агресивний термін — потребує значної дисципліни!',
                style: AppTypography.labelSmall.copyWith(
                  color: AppColorsPS5.warning,
                  fontSize: 11,
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (_isLongTimeline) {
      return Container(
        margin: const EdgeInsets.only(top: Spacing.sm),
        padding: const EdgeInsets.all(Spacing.sm),
        decoration: BoxDecoration(
          color: AppColorsPS5.coin.withOpacity(0.06),
          borderRadius: BorderRadius.circular(Radii.sm),
        ),
        child: Row(
          children: [
            const Icon(Icons.info_outline_rounded, color: AppColorsPS5.coin, size: 16),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                '📅 Довгий термін — можна зробити внески меншими!',
                style: AppTypography.labelSmall.copyWith(
                  color: AppColorsPS5.coin,
                  fontSize: 11,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return const SizedBox.shrink();
  }

  /// Builds a preview of the XP and coin rewards the user will
  /// receive upon creating their first goal.
  Widget _buildRewardsPreview(Color accent, Color subColor) {
    return Container(
      margin: const EdgeInsets.only(top: Spacing.md),
      padding: const EdgeInsets.all(Spacing.md),
      decoration: BoxDecoration(
        color: accent.withOpacity(0.04),
        borderRadius: BorderRadius.circular(Radii.md),
        border: Border.all(color: accent.withOpacity(0.08)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Column(
            children: [
              Text(
                '+${_firstGoalRewards['xp']}',
                style: AppTypography.labelMedium.copyWith(
                  color: AppColorsPS5.xp,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                'XP',
                style: AppTypography.caption.copyWith(color: subColor),
              ),
            ],
          ),
          Container(width: 1, height: 30, color: accent.withOpacity(0.1)),
          Column(
            children: [
              Text(
                '+${_firstGoalRewards['coins']}',
                style: AppTypography.labelMedium.copyWith(
                  color: AppColorsPS5.coin,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                'монет',
                style: AppTypography.caption.copyWith(color: subColor),
              ),
            ],
          ),
          Container(width: 1, height: 30, color: accent.withOpacity(0.1)),
          Column(
            children: [
              Text(
                _firstGoalRewards['badge'] as String,
                style: AppTypography.labelSmall.copyWith(
                  color: AppColorsPS5.warning,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                'бейдж',
                style: AppTypography.caption.copyWith(color: subColor),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Builds an achievability indicator showing how realistic the
  /// goal is based on average user data.
  Widget _buildAchievabilityIndicator(Color accent, Color subColor) {
    final achievability = _computeAchievability();
    if (achievability.isEmpty) return const SizedBox.shrink();

    final isEasy = achievability == 'Легко досяжно';
    final indicatorColor = isEasy
        ? AppColorsPS5.success
        : achievability == 'Потребує значних зусиль'
            ? AppColorsPS5.warning
            : accent;

    return Container(
      margin: const EdgeInsets.only(top: Spacing.sm),
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.md,
        vertical: Spacing.xs,
      ),
      decoration: BoxDecoration(
        color: indicatorColor.withOpacity(0.06),
        borderRadius: BorderRadius.circular(Radii.circular),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isEasy ? Icons.check_circle_rounded : Icons.info_rounded,
            color: indicatorColor,
            size: 14,
          ),
          const SizedBox(width: 6),
          Text(
            achievability,
            style: AppTypography.labelSmall.copyWith(
              color: indicatorColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColorsPS5.background : AppColorsMonitor.background;
    final textColor = isDark ? AppColorsPS5.textPrimary : AppColorsMonitor.textPrimary;
    final subColor = isDark ? AppColorsPS5.textSecondary : AppColorsMonitor.textSecondary;
    final cardColor = isDark ? AppColorsPS5.card : AppColorsMonitor.card;
    final borderColor = isDark ? AppColorsPS5.border : AppColorsMonitor.border;
    final accent = isDark ? AppColorsPS5.accent : AppColorsMonitor.accent;

    // Success overlay
    if (_showSuccess) {
      return Scaffold(
        backgroundColor: bgColor,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: AppColorsPS5.success.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  color: AppColorsPS5.success,
                  size: 56,
                ),
              )
                  .animate()
                  .scale(
                    duration: 500.ms,
                    curve: AppEasings.elastic,
                  )
                  .fadeIn(duration: 300.ms),
              const SizedBox(height: Spacing.lg),
              Text(
                '$_selectedEmoji Ціль створено!',
                style: AppTypography.heading2.copyWith(color: textColor),
              )
                  .animate()
                  .fade(delay: 200.ms, duration: 400.ms),
              const SizedBox(height: Spacing.sm),
              Text(
                'Перенаправлення...',
                style: AppTypography.bodyMedium.copyWith(color: subColor),
              )
                  .animate()
                  .fade(delay: 400.ms, duration: 400.ms),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: textColor,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: Spacing.base),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: Spacing.lg),

                // ─── Заголовок ────────────────────────────────────
                Text(
                  'Нова мета?',
                  style: AppTypography.displayLarge.copyWith(color: textColor),
                  textAlign: TextAlign.center,
                ).animate().fadeIn(duration: 500.ms),

                const SizedBox(height: Spacing.sm),

                Text(
                  'Ти довів, що можеш. Що далі?',
                  style: AppTypography.bodyLarge.copyWith(color: subColor),
                  textAlign: TextAlign.center,
                )
                    .animate()
                    .fadeIn(delay: 200.ms, duration: 500.ms),

                const SizedBox(height: Spacing.xxl),

                // ─── Тип Selection ────────────────────────────────
                Text(
                  'Обери тип цілі',
                  style: AppTypography.labelLarge.copyWith(color: subColor),
                ),
                const SizedBox(height: Spacing.sm),

                // PS5 Card
                _buildTypeCard(
                  type: 'ps5',
                  icon: Icons.gamepad_rounded,
                  title: 'PlayStation 5',
                  subtitle: 'Оновлена консоля нового покоління',
                  gradientColors: const [Color(0xFF006FCD), Color(0xFF00C6FF)],
                  textColor: textColor,
                  cardColor: cardColor,
                  borderColor: borderColor,
                  accent: accent,
                ),

                const SizedBox(height: Spacing.md),

                // Monitor Card
                _buildTypeCard(
                  type: 'monitor',
                  icon: Icons.desktop_windows_rounded,
                  title: 'Монітор',
                  subtitle: 'Професійний 27" 4K монітор',
                  gradientColors: const [Color(0xFF6C5CE7), Color(0xFFA8E6CF)],
                  textColor: textColor,
                  cardColor: cardColor,
                  borderColor: borderColor,
                  accent: accent,
                ),

                const SizedBox(height: Spacing.md),

                // Custom Card
                _buildTypeCard(
                  type: 'custom',
                  icon: Icons.flag_rounded,
                  title: 'Власна ціль',
                  subtitle: 'Створи свою унікальну мету',
                  gradientColors: const [Color(0xFFFF9100), Color(0xFFFFD600)],
                  textColor: textColor,
                  cardColor: cardColor,
                  borderColor: borderColor,
                  accent: accent,
                ),

                // ─── Галерея шаблонів цілей ─────────────────────
                const SizedBox(height: Spacing.xl),
                GestureDetector(
                  onTap: () => setState(() => _showTemplates = !_showTemplates),
                  child: Container(
                    padding: const EdgeInsets.all(Spacing.base),
                    decoration: BoxDecoration(
                      color: accent.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(Radii.md),
                      border: Border.all(color: accent.withOpacity(0.12)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('📦 Шаблони цілей', style: AppTypography.labelLarge.copyWith(color: accent, fontWeight: FontWeight.w600)),
                        Icon(_showTemplates ? Icons.expand_less_rounded : Icons.expand_more_rounded, color: accent),
                      ],
                    ),
                  ),
                ),
                if (_showTemplates) ...[
                  const SizedBox(height: Spacing.sm),
                  ..._goalTemplates.map((t) => _buildTemplateCard(t, accent, textColor, subColor, borderColor)),
                ],

                const SizedBox(height: Spacing.xl),

                // ─── Custom type input ──────────────────────────
                if (_selectedType == 'custom') ...[
                  Text(
                    'Назва типу цілі',
                    style: AppTypography.labelMedium.copyWith(color: subColor),
                  ),
                  const SizedBox(height: Spacing.xs),
                  TextFormField(
                    controller: TextEditingController(
                      text: _customTypeName,
                    ),
                    onChanged: (v) => _customTypeName = v,
                    style: AppTypography.bodyLarge.copyWith(color: textColor),
                    decoration: InputDecoration(
                      hintText: 'Наприклад: Велосипед, Подорож...',
                      hintStyle: AppTypography.bodyLarge.copyWith(
                        color: subColor.withOpacity(0.5),
                      ),
                      filled: true,
                      fillColor: isDark
                          ? AppColorsPS5.surface
                          : AppColorsMonitor.surface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(Radii.md),
                        borderSide: BorderSide(color: borderColor),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(Radii.md),
                        borderSide: BorderSide(color: borderColor),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(Radii.md),
                        borderSide: BorderSide(
                          color: accent,
                          width: 2,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: Spacing.base,
                        vertical: 14,
                      ),
                    ),
                  ),
                  const SizedBox(height: Spacing.lg),
                ],

                // ─── Goal Name ──────────────────────────────────────
                Text(
                  'Назва цілі',
                  style: AppTypography.labelMedium.copyWith(color: subColor),
                ),
                const SizedBox(height: Spacing.xs),
                TextFormField(
                  controller: _nameController,
                  style: AppTypography.bodyLarge.copyWith(color: textColor),
                  decoration: InputDecoration(
                    hintText: _typeInfo[_effectiveType]?['placeholder'] as String? ?? 'Назва цілі',
                    hintStyle: AppTypography.bodyLarge.copyWith(
                      color: subColor.withOpacity(0.5),
                    ),
                    filled: true,
                    fillColor: isDark ? AppColorsPS5.surface : AppColorsMonitor.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(Radii.md),
                      borderSide: BorderSide(color: borderColor),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(Radii.md),
                      borderSide: BorderSide(color: borderColor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(Radii.md),
                      borderSide: BorderSide(color: accent, width: 2),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: Spacing.base,
                      vertical: 14,
                    ),
                  ),
                ),

                // ─── Емодзі-пікер ──────────────────────────────────
                const SizedBox(height: Spacing.md),
                Text(
                  'Обери іконку',
                  style: AppTypography.labelMedium.copyWith(color: subColor),
                ),
                const SizedBox(height: Spacing.xs),
                Wrap(
                  spacing: Spacing.sm,
                  runSpacing: Spacing.sm,
                  children: _goalEmojis.map((emoji) {
                    final isSelected = _selectedEmoji == emoji;
                    return GestureDetector(
                      onTap: () {
                        context.haptic();
                        setState(() => _selectedEmoji = emoji);
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: isSelected ? accent.withOpacity(0.15) : Colors.transparent,
                          borderRadius: BorderRadius.circular(Radii.sm),
                          border: isSelected ? Border.all(color: accent, width: 1.5) : null,
                        ),
                        child: Center(
                          child: Text(emoji, style: const TextStyle(fontSize: 20)),
                        ),
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: Spacing.lg),

                // ─── Amount Input with Presets ─────────────────────
                Text(
                  'Цільова сума (грн)',
                  style: AppTypography.labelMedium.copyWith(color: subColor),
                ),
                const SizedBox(height: Spacing.xs),
                TextFormField(
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                  style: AppTypography.bodyLarge.copyWith(color: textColor),
                  decoration: InputDecoration(
                    hintText: '20000',
                    hintStyle: AppTypography.bodyLarge.copyWith(
                      color: subColor.withOpacity(0.5),
                    ),
                    prefixText: '₴ ',
                    prefixStyle: AppTypography.bodyLarge.copyWith(
                      color: subColor,
                    ),
                    filled: true,
                    fillColor: isDark ? AppColorsPS5.surface : AppColorsMonitor.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(Radii.md),
                      borderSide: BorderSide(color: borderColor),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(Radii.md),
                      borderSide: BorderSide(color: borderColor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(Radii.md),
                      borderSide: BorderSide(color: accent, width: 2),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: Spacing.base,
                      vertical: 14,
                    ),
                  ),
                ),
                const SizedBox(height: Spacing.sm),

                // ─── Amount Presets ────────────────────────────────
                Wrap(
                  spacing: Spacing.sm,
                  runSpacing: Spacing.sm,
                  children: (_presets[_effectiveType] ?? _presets['custom']!)
                      .map((preset) {
                    return GestureDetector(
                      onTap: () {
                        context.haptic();
                        setState(() {
                          _amountController.text = preset.toString();
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: Spacing.md,
                          vertical: Spacing.xs,
                        ),
                        decoration: BoxDecoration(
                          color: accent.withOpacity(0.08),
                          borderRadius:
                              BorderRadius.circular(Radii.xl),
                          border: Border.all(
                            color: accent.withOpacity(0.2),
                          ),
                        ),
                        child: Text(
                          '${preset.toString()} грн',
                          style: AppTypography.labelMedium.copyWith(
                            color: accent,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    );
                  })
                      .toList(),
                ),

                // ─── Daily Amount Preview ────────────────────────
                const SizedBox(height: Spacing.lg),
                Container(
                  padding: const EdgeInsets.all(Spacing.md),
                  decoration: BoxDecoration(
                    color: accent.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(Radii.md),
                    border: Border.all(color: accent.withOpacity(0.12)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.calendar_today_rounded, color: accent, size: 18),
                      const SizedBox(width: Spacing.sm),
                      Expanded(
                        child: Text(
                          _dailyAmount > 0
                              ? 'Щоденно: $_dailyAmount грн / день (30 днів)'
                              : 'Введи суму для розрахунку',
                          style: AppTypography.labelSmall.copyWith(
                            color: _dailyAmount > 0
                                ? accent
                                : subColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // ─── Складність та термін ─────────────────────────
                const SizedBox(height: Spacing.md),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(Spacing.sm),
                        decoration: BoxDecoration(
                          color: accent.withOpacity(0.04),
                          borderRadius: BorderRadius.circular(Radii.sm),
                          border: Border.all(color: accent.withOpacity(0.08)),
                        ),
                        child: Column(
                          children: [
                            Text('Складність', style: AppTypography.caption.copyWith(color: subColor)),
                            const SizedBox(height: 2),
                            Text(_difficultyLabel, style: AppTypography.labelSmall.copyWith(color: accent, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: Spacing.sm),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(Spacing.sm),
                        decoration: BoxDecoration(
                          color: accent.withOpacity(0.04),
                          borderRadius: BorderRadius.circular(Radii.sm),
                          border: Border.all(color: accent.withOpacity(0.08)),
                        ),
                        child: Column(
                          children: [
                            Text('Орієнтовний термін', style: AppTypography.caption.copyWith(color: subColor)),
                            const SizedBox(height: 2),
                            Text(_estimatedTime, style: AppTypography.labelSmall.copyWith(color: accent, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                // ─── Категорії для перегляду ─────────────────────
                const SizedBox(height: Spacing.lg),
                Text(
                  'Категорії',
                  style: AppTypography.labelLarge.copyWith(color: subColor),
                ),
                const SizedBox(height: Spacing.xs),
                Wrap(
                  spacing: Spacing.sm,
                  runSpacing: Spacing.sm,
                  children: _categories.map((cat) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: Spacing.sm, vertical: Spacing.xs),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(Radii.circular),
                        border: Border.all(color: borderColor),
                      ),
                      child: Text(cat, style: AppTypography.labelSmall.copyWith(color: subColor)),
                    );
                  }).toList(),
                ),

                // ─── Підказки з історії ──────────────────────────
                const SizedBox(height: Spacing.lg),
                Container(
                  padding: const EdgeInsets.all(Spacing.base),
                  decoration: BoxDecoration(
                    color: AppColorsPS5.warning.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(Radii.md),
                    border: Border.all(color: AppColorsPS5.warning.withOpacity(0.12)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('💡 Поради на основі історії', style: AppTypography.labelMedium.copyWith(color: AppColorsPS5.warning, fontWeight: FontWeight.w600)),
                      const SizedBox(height: Spacing.sm),
                      ..._historySuggestions.map((s) => Padding(
                        padding: const EdgeInsets.only(bottom: Spacing.xs),
                        child: Text('• $s', style: AppTypography.labelSmall.copyWith(color: subColor)),
                      )),
                    ],
                  ),
                ),

                // ─── Цілі спільноти (заглушка) ──────────────────
                const SizedBox(height: Spacing.lg),
                Container(
                  padding: const EdgeInsets.all(Spacing.base),
                  decoration: BoxDecoration(
                    color: accent.withOpacity(0.04),
                    borderRadius: BorderRadius.circular(Radii.md),
                    border: Border.all(color: accent.withOpacity(0.08)),
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.groups_rounded, color: accent, size: 24),
                      const SizedBox(height: Spacing.sm),
                      Text('🌍 Цілі спільноти', style: AppTypography.labelLarge.copyWith(color: accent, fontWeight: FontWeight.w600)),
                      const SizedBox(height: Spacing.xs),
                      Text('1 234 людини накопичують на PlayStation 5', style: AppTypography.labelSmall.copyWith(color: subColor)),
                      Text('856 людей накопичують на Монітор', style: AppTypography.labelSmall.copyWith(color: subColor)),
                      const SizedBox(height: Spacing.sm),
                      Text('Долучайся до Nexora!', style: AppTypography.labelSmall.copyWith(color: accent, fontStyle: FontStyle.italic)),
                    ],
                  ),
                ),

                // ─── Target Date Picker ───────────────────────────
                const SizedBox(height: Spacing.xl),
                Text(
                  'Бажана дата (необов\'язково)',
                  style: AppTypography.labelMedium.copyWith(color: subColor),
                ),
                const SizedBox(height: Spacing.xs),
                GestureDetector(
                  onTap: _pickDate,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: Spacing.base,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: isDark ? AppColorsPS5.surface : AppColorsMonitor.surface,
                      borderRadius: BorderRadius.circular(Radii.md),
                      border: Border.all(color: borderColor),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.event_rounded, color: subColor, size: 20),
                        const SizedBox(width: Spacing.md),
                        Text(
                          _selectedDate != null
                              ? '${_selectedDate!.day.toString().padLeft(2, '0')}.${_selectedDate!.month.toString().padLeft(2, '0')}.${_selectedDate!.year}'
                              : 'Обрати дату',
                          style: AppTypography.bodyMedium.copyWith(
                            color: _selectedDate != null
                                ? textColor
                                : subColor.withOpacity(0.5),
                          ),
                        ),
                        const Spacer(),
                        if (_selectedDate != null)
                          GestureDetector(
                            onTap: () => setState(() => _selectedDate = null),
                            child: Icon(Icons.close_rounded, color: subColor, size: 18),
                          ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: Spacing.xxl),

                // ─── Create Button ──────────────────────────────
                AppButtonPrimary(
                  label: 'Створити ціль',
                  icon: Icons.add_circle_rounded,
                  showGlow: true,
                  isFullWidth: true,
                  isLoading: _isCreating,
                  onPressed: _isCreating ? null : _createGoal,
                ),

                const SizedBox(height: Spacing.lg),

                // ─── Pause Button ────────────────────────────────
                AppButtonSecondary(
                  label: 'Взяти паузу',
                  icon: Icons.pause_circle_outline_rounded,
                  isFullWidth: true,
                  onPressed: () => Navigator.of(context).pushReplacementNamed('/dashboard'),
                ),

                const SizedBox(height: Spacing.xxxl),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Картка шаблону цілі.
  Widget _buildTemplateCard(_GoalTemplate t, Color accent, Color textColor, Color subColor, Color borderColor) {
    return GestureDetector(
      onTap: () => _selectTemplate(t),
      child: Container(
        margin: const EdgeInsets.only(bottom: Spacing.sm),
        padding: const EdgeInsets.all(Spacing.md),
        decoration: BoxDecoration(
          color: accent.withOpacity(0.04),
          borderRadius: BorderRadius.circular(Radii.md),
          border: Border.all(color: accent.withOpacity(0.1)),
        ),
        child: Row(
          children: [
            Text(t.emoji, style: const TextStyle(fontSize: 28)),
            const SizedBox(width: Spacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(t.name, style: AppTypography.labelMedium.copyWith(color: textColor, fontWeight: FontWeight.w600)),
                  Text('${t.category} · ${t.amount.formatUAH()} грн · ${t.difficulty}', style: AppTypography.labelSmall.copyWith(color: subColor)),
                ],
              ),
            ),
            const Icon(Icons.add_circle_outline_rounded, color: AppColorsPS5.accent, size: 20),
          ],
        ),
      ),
    );
  }

  // ─── Type Selection Card ────────────────────────────────────────────────

  Widget _buildTypeCard({
    required String type,
    required IconData icon,
    required String title,
    required String subtitle,
    required List<Color> gradientColors,
    required Color textColor,
    required Color cardColor,
    required Color borderColor,
    required Color accent,
  }) {
    final isSelected = _selectedType == type;

    return GestureDetector(
      onTap: () => _selectType(type),
      child: AnimatedContainer(
        duration: AppDurations.medium,
        padding: const EdgeInsets.all(Spacing.base),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(Radii.xl),
          border: Border.all(
            color: isSelected
                ? accent
                : borderColor,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected ? AppShadows.glow(accent) : AppShadows.level2,
        ),
        child: Row(
          children: [
            // Gradient preview
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: gradientColors),
                borderRadius: BorderRadius.circular(Radii.lg),
                boxShadow: [
                  BoxShadow(
                    color: gradientColors.first.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(icon, color: Colors.white, size: 36),
            ),
            const SizedBox(width: Spacing.lg),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.heading2.copyWith(color: textColor),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: AppTypography.bodySmall.copyWith(color: subColor),
                  ),
                ],
              ),
            ),
            // Selection indicator
            if (isSelected)
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: accent,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_rounded, color: Colors.white, size: 18),
              )
            else
              Icon(Icons.arrow_forward_ios_rounded, color: subColor, size: 18),
          ],
        ),
      ),
    );
  }
}

/// Шаблон цілі для галереї.
class _GoalTemplate {
  final String emoji;
  final String name;
  final int amount;
  final String category;
  final String difficulty;
  const _GoalTemplate({required this.emoji, required this.name, required this.amount, required this.category, required this.difficulty});
}
