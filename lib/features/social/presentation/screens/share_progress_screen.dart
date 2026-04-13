import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_radii.dart';
import '../../../../core/constants/app_shadows.dart';
import '../../../../core/widgets/app_button_primary.dart';
import '../../../../core/widgets/app_button_secondary.dart';
import '../../../../core/extensions/build_context_ext.dart';

// ═══════════════════════════════════════════════════════════════════════════
// Константи екрану «Поділитися»
// ═══════════════════════════════════════════════════════════════════════════

/// Максимальна довжина тексту повідомлення для поділу.
const int _kMaxMessageLength = 220;

/// Мінімальна довжина тексту повідомлення.
const int _kMinMessageLength = 5;

/// Піксельний коефіцієнт для захоплення зображення.
const double _kImagePixelRatio = 3.0;

/// Тривалість пульсу картки (мілісекунди).
const int _kPulseDurationMs = 2000;

/// Максимальна кількість записів в історії поділів.
const int _kMaxShareHistory = 20;

/// Тривалість анімації появи картки (мілісекунди).
const int _kCardAppearDurationMs = 500;

/// Затримка перед автозбереженням прев'ю (мілісекунди).
const int _kAutoSaveDelayMs = 2000;

/// Максимальна кількість емодзі в повідомленні.
const int _kMaxEmojis = 5;

/// Шаблон для генерації хештегу цілі.
const String _kHashtagTemplate = '#nexora_savings';

// ═══════════════════════════════════════════════════════════════════════════
// Utility Extensions
// ═══════════════════════════════════════════════════════════════════════════

/// Розширення для безпечної роботи з текстом повідомлень.
extension _ShareTextUtils on String {
  /// Обрізає текст до вказаної довжини з безпекою для null.
  String safeTruncate(int maxLength) {
    if (length <= maxLength) return this;
    return '${substring(0, maxLength)}...';
  }

  /// Перевіряє, чи текст не порожній після trim.
  bool get isNotBlank => trim().isNotEmpty;

  /// Повертає кількість слів у тексті.
  int get wordCount => split(RegExp(r'\s+')).where((s) => s.isNotEmpty).length;
}

/// Дані цілі для шаблону повідомлення при поділу.
class _ShareGoalData {
  /// Назва цілі накопичування.
  final String goalName;

  /// Поточна накопичена сума.
  final int currentAmount;

  /// Цільова сума.
  final int targetAmount;

  /// Тривалість активності (формат: 'X дн.').
  final String daysActive;

  /// Кількість внесків за час накопичування.
  final int depositCount;

  /// Обчислений відсоток прогресу.
  double get progress {
    if (targetAmount <= 0) return 0.0;
    return (currentAmount / targetAmount * 100).clamp(0, 100);
  }

  /// Сума, що залишилася до цілі.
  int get remaining => (targetAmount - currentAmount).clamp(0, targetAmount);

  /// Обчислює середній внесок за день.
  double get averagePerDay {
    final days = int.tryParse(daysActive.replaceAll(RegExp(r'[^\d]'), '')) ?? 1;
    if (days <= 0) return 0.0;
    return currentAmount / days;
  }

  const _ShareGoalData({
    required this.goalName,
    required this.currentAmount,
    required this.targetAmount,
    required this.daysActive,
    required this.depositCount,
  });
}

/// Дані запису в історії поділів.
///
/// Зберігає інформацію про кожну дію поділу: платформу, текст,
/// часову мітку та успішність операції.
class _ShareHistoryEntry {
  /// Створює запис історії поділу.
  const _ShareHistoryEntry({
    required this.platform,
    required this.message,
    required this.timestamp,
    required this.isSuccess,
  });

  /// Назва платформи поділу (наприклад, 'Telegram', 'Instagram').
  final String platform;

  /// Текст повідомлення, яке ділили.
  final String message;

  /// Часова мітка події.
  final DateTime timestamp;

  /// Чи операція поділу була успішною.
  final bool isSuccess;

  /// Повертає текстове представлення запису.
  @override
  String toString() => '[$_platform] ${isSuccess ? '✓' : '✗'} $timestamp';
}

/// Аналітика поділів для екрану «Поділитися».
///
/// Відстежує кількість поділів за платформами, успішність
/// та надає методи для розрахунку статистики.
class _ShareAnalytics {
  /// Створює об'єкт аналітики.
  const _ShareAnalytics();

  /// Обчислює кількість поділів за кожною платформою.
  ///
  /// [history] — список записів історії поділів.
  Map<String, int> sharesPerPlatform(List<_ShareHistoryEntry> history) {
    final counts = <String, int>{};
    try {
      for (final entry in history) {
        counts[entry.platform] = (counts[entry.platform] ?? 0) + 1;
      }
    } catch (e) {
      debugPrint('[ShareAnalytics] Error counting per platform: $e');
    }
    return counts;
  }

  /// Обчислює відсоток успішних поділів.
  ///
  /// [history] — список записів історії поділів.
  double successRate(List<_ShareHistoryEntry> history) {
    if (history.isEmpty) return 0.0;
    try {
      final successes = history.where((e) => e.isSuccess).length;
      return (successes / history.length) * 100;
    } catch (e) {
      debugPrint('[ShareAnalytics] Error calculating success rate: $e');
      return 0.0;
    }
  }

  /// Повертає найпопулярнішу платформу для поділів.
  ///
  /// [history] — список записів історії поділів.
  String? mostUsedPlatform(List<_ShareHistoryEntry> history) {
    if (history.isEmpty) return null;
    try {
      final counts = sharesPerPlatform(history);
      if (counts.isEmpty) return null;
      return counts.entries.reduce((a, b) => a.value >= b.value ? a : b).key;
    } catch (e) {
      debugPrint('[ShareAnalytics] Error finding most used platform: $e');
      return null;
    }
  }
}

/// Категорія шаблону повідомлення для поділу.
enum _ShareMessageCategory {
  /// Спортивне мотивування.
  sport('Спорт', Icons.sports_score_rounded),

  /// Досягнення.
  achievement('Досягнення', Icons.emoji_events_rounded),

  /// Подяка.
  gratitude('Подяка', Icons.favorite_rounded),

  /// Виклик.
  challenge('Виклик', Icons.bolt_rounded);

  const _ShareMessageCategory(this.label, this.icon);

  /// Мітка для відображення в UI.
  final String label;

  /// Іконка категорії.
  final IconData icon;
}

/// Екран «Поділитися» — прев'ю-картка з градієнтом, шаблони повідомлень,
/// кнопки для Instagram/Telegram/Twitter/Зберегти/Копіювати, кастомізація кольору.
class ShareProgressScreen extends StatefulWidget {
  const ShareProgressScreen({super.key});

  @override
  State<ShareProgressScreen> createState() => _ShareProgressScreenState();
}

class _ShareProgressScreenState extends State<ShareProgressScreen>
    with SingleTickerProviderStateMixin {
  final GlobalKey _previewKey = GlobalKey();
  double _progress = 65;

  /// Дані цілі для шаблону повідомлення
  final String _goalName = 'PS5';
  final int _currentAmount = 13000;
  final int _targetAmount = 20000;
  final String _daysActive = '23 дн.';

  /// Кількість внесків
  final int _depositCount = 45;

  /// Обрано користувацьке повідомлення
  int _selectedTemplateIndex = 0;

  /// Дозволені кольори для кастомізації картки
  static const _cardColors = [
    Color(0xFF006FCD), // Синій (PS5)
    Color(0xFFE1306C), // Рожевий
    Color(0xFF2ECC71), // Зелений
    Color(0xFF9B59B6), // Фіолетовий
    Color(0xFFE67E22), // Оранжевий
    Color(0xFF1ABC9C), // Бірюзовий
    Color(0xFFE74C3C), // Червоний
    Color(0xFFF39C12), // Жовтий
  ];

  /// Назви кольорів для accessibility
  static const _colorNames = [
    'Синій', 'Рожевий', 'Зелений', 'Фіолетовий',
    'Оранжевий', 'Бірюзовий', 'Червоний', 'Жовтий',
  ];

  int _selectedColorIndex = 0;

  /// Контролер повідомлення
  final _messageController = TextEditingController();
  bool _isCustomMessage = false;

  /// Чи показуємо секцію шаблонів
  bool _showTemplates = false;

  /// Анімація пульсу картки
  late AnimationController _cardPulseController;

  /// Історія поділів за поточну сесію.
  final List<_ShareHistoryEntry> _shareHistory = [];

  /// Аналітика поділів.
  final _ShareAnalytics _analytics = const _ShareAnalytics();

  /// Чи показувати водяний знак на картці.
  bool _showWatermark = true;

  /// Чи показувати панель історії поділів.
  bool _showShareHistory = false;

  /// Чи відбувається захоплення зображення.
  bool _isCapturing = false;

  /// Кількість поділів за сесію.
  int _totalShares = 0;

  /// Шаблони повідомлень
  final _templates = [
    'Я накопичую на {goal}. Вже {current} з {target} грн!',
    'Моя мрія стає ближче! {progress}% накопичено на {goal} 💪',
    'День за днем — і ось результат: {current} грн на {goal}!',
    'Накопичування — це сила! Вже {progress}% на {goal} 🚀',
    '{days} щоденних внесків привели мене до {current} грн на {goal}!',
    'Мій секрет? Регулярність! {progress}% на {goal} ✨',
    'Кожна гривня наближає мене до {goal}. {current} грн за {days}! 🎯',
    'Nexora допомагає мені мріяти масштабніше! {progress}% на {goal} 💎',
  ];

  String _getTemplatedMessage(int index) {
    final t = _templates[index];
    return t
        .replaceAll('{goal}', _goalName)
        .replaceAll('{current}', _currentAmount.toString())
        .replaceAll('{target}', _targetAmount.toString())
        .replaceAll('{progress}', '$_progress')
        .replaceAll('{days}', _daysActive);
  }

  String get _activeMessage =>
      _isCustomMessage ? _messageController.text : _getTemplatedMessage(_selectedTemplateIndex);

  @override
  void initState() {
    super.initState();
    _messageController.text = _getTemplatedMessage(0);
    _cardPulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _messageController.dispose();
    _cardPulseController.dispose();
    super.dispose();
  }

  void _onTemplateSelected(int index) {
    context.haptic();
    setState(() {
      _selectedTemplateIndex = index;
      _isCustomMessage = false;
      _messageController.text = _getTemplatedMessage(index);
    });
  }

  void _onCustomMessage() {
    context.haptic();
    setState(() {
      _isCustomMessage = true;
      _messageController.text = '';
    });
    _showEditMessageDialog(context);
  }

  void _onColorSelected(int index) {
    context.haptic();
    setState(() => _selectedColorIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;

    return Scaffold(
      backgroundColor: isDark ? AppColorsPS5.background : AppColorsMonitor.background,
      appBar: AppBar(
        title: const Text('Поділитися прогресом'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: isDark ? AppColorsPS5.textPrimary : AppColorsMonitor.textPrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline_rounded),
            onPressed: () {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Як це працює?'),
                  content: const Text(
                    'Збережи картку або поділися нею в соціальних мережах! '
                    'Ти можеш обрати колір, шаблон повідомлення або написати свій власний текст.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Зрозуміло'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: Spacing.base),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: Spacing.xl),

            // ─── Прев'ю картка (RepaintBoundary) ────────────────
            RepaintBoundary(
              key: _previewKey,
              child: AnimatedBuilder(
                animation: _cardPulseController,
                builder: (context, child) {
                  final glowIntensity = 0.3 + 0.15 * _cardPulseController.value;
                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: Spacing.xxl,
                      vertical: Spacing.xxl + Spacing.sm,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          _cardColors[_selectedColorIndex],
                          _cardColors[_selectedColorIndex].withOpacity(0.55),
                          _cardColors[(_selectedColorIndex + 2) % _cardColors.length].withOpacity(0.3),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(Radii.xl),
                      boxShadow: [
                        BoxShadow(
                          color: _cardColors[_selectedColorIndex].withOpacity(glowIntensity),
                          blurRadius: 32,
                          spreadRadius: 4,
                        ),
                        BoxShadow(
                          color: _cardColors[_selectedColorIndex].withOpacity(0.2),
                          blurRadius: 60,
                          spreadRadius: 0,
                        ),
                      ],
                    ),
                    child: child,
                  );
                },
                child: Column(
                  children: [
                    // Міні-візуалізація з прогресом — кільце
                    SizedBox(
                      width: 130,
                      height: 130,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Фонове кільце
                          SizedBox(
                            width: 130,
                            height: 130,
                            child: CircularProgressIndicator(
                              value: _progress / 100,
                              strokeWidth: 10,
                              backgroundColor: Colors.white.withOpacity(0.12),
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white.withOpacity(0.9),
                              ),
                            ),
                          ),
                          // Іконка в центрі з фоном
                          Container(
                            width: 90,
                            height: 90,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.12),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.gamepad_rounded,
                              color: Colors.white,
                              size: 44,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: Spacing.lg),

                    // Великий відсоток накопичено
                    Text(
                      '$_progress% накопичено!',
                      style: AppTypography.displayMedium.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 38,
                      ),
                    ),
                    const SizedBox(height: Spacing.sm),

                    // Назва цілі
                    Text(
                      _goalName,
                      style: AppTypography.heading3.copyWith(
                        color: Colors.white.withOpacity(0.85),
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: Spacing.md),

                    // Шаблонне повідомлення
                    Text(
                      _activeMessage,
                      style: AppTypography.bodyMedium.copyWith(
                        color: Colors.white.withOpacity(0.88),
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: Spacing.md),

                    // Кількість накопичено
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: Spacing.base + Spacing.xs,
                        vertical: Spacing.sm + Spacing.xs,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(Radii.circular),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _currentAmount.toString(),
                            style: AppTypography.monoMedium.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(width: Spacing.xs),
                          Text(
                            '/ $_targetAmount грн',
                            style: AppTypography.labelMedium.copyWith(
                              color: Colors.white.withOpacity(0.65),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: Spacing.sm),

                    // Міні-статистика
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildMiniStat('$_depositCount внесків', Icons.receipt_rounded),
                        Container(width: 1, height: 14, color: Colors.white.withOpacity(0.2)),
                        _buildMiniStat(_daysActive, Icons.calendar_today_rounded),
                      ],
                    ),
                    const SizedBox(height: Spacing.md),

                    // Логотип додатку
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(Radii.sm),
                          ),
                          child: const Icon(
                            Icons.savings_rounded,
                            color: Colors.white,
                            size: 14,
                          ),
                        ),
                        const SizedBox(width: Spacing.xs),
                        Text(
                          'nexora',
                          style: AppTypography.labelSmall.copyWith(
                            color: Colors.white.withOpacity(0.55),
                            letterSpacing: 3,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ).animate().scale(delay: 200.ms, duration: 500.ms, curve: Curves.easeOutBack),

            const SizedBox(height: Spacing.xxl),

            // ─── Секція шаблонів повідомлень ────────────────────
            Container(
              padding: const EdgeInsets.all(Spacing.base),
              decoration: BoxDecoration(
                color: (isDark ? AppColorsPS5.card : AppColorsMonitor.card),
                borderRadius: BorderRadius.circular(Radii.lg),
                border: Border.all(
                  color: isDark ? AppColorsPS5.border : AppColorsMonitor.border,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Повідомлення',
                        style: AppTypography.heading3.copyWith(
                          color: isDark ? AppColorsPS5.textPrimary : AppColorsMonitor.textPrimary,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => setState(() => _showTemplates = !_showTemplates),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _showTemplates ? 'Сховати' : 'Всі шаблони',
                              style: AppTypography.labelMedium.copyWith(
                                color: isDark ? AppColorsPS5.accent : AppColorsMonitor.accent,
                              ),
                            ),
                            Icon(
                              _showTemplates
                                  ? Icons.keyboard_arrow_up_rounded
                                  : Icons.keyboard_arrow_down_rounded,
                              color: isDark ? AppColorsPS5.accent : AppColorsMonitor.accent,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: Spacing.sm),

                  // Попередній перегляд повідомлення
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(Spacing.base),
                    decoration: BoxDecoration(
                      color: (isDark ? AppColorsPS5.surface : AppColorsMonitor.surface),
                      borderRadius: BorderRadius.circular(Radii.md),
                    ),
                    child: Text(
                      _activeMessage,
                      style: AppTypography.bodyMedium.copyWith(
                        color: isDark ? AppColorsPS5.textPrimary : AppColorsMonitor.textPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(height: Spacing.sm),

                  // Кнопки редагування
                  Row(
                    children: [
                      Expanded(
                        child: AppButtonSecondary(
                          label: 'Редагувати',
                          icon: Icons.edit_rounded,
                          onPressed: () => _showEditMessageDialog(context),
                        ),
                      ),
                      const SizedBox(width: Spacing.sm),
                      Expanded(
                        child: AppButtonSecondary(
                          label: 'Свій текст',
                          icon: Icons.create_rounded,
                          onPressed: _onCustomMessage,
                        ),
                      ),
                    ],
                  ),

                  // Розгорнуті шаблони
                  AnimatedSize(
                    duration: const Duration(milliseconds: 300),
                    child: _showTemplates
                        ? Column(
                            children: [
                              const SizedBox(height: Spacing.base),
                              ...List.generate(_templates.length, (i) {
                                final isSelected = i == _selectedTemplateIndex && !_isCustomMessage;
                                return GestureDetector(
                                  onTap: () => _onTemplateSelected(i),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    margin: const EdgeInsets.only(bottom: Spacing.xs),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: Spacing.base,
                                      vertical: Spacing.sm,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? (isDark ? AppColorsPS5.accent : AppColorsMonitor.accent).withOpacity(0.1)
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(Radii.md),
                                      border: Border.all(
                                        color: isSelected
                                            ? (isDark ? AppColorsPS5.accent : AppColorsMonitor.accent)
                                            : Colors.transparent,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          isSelected ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                                          size: 18,
                                          color: isSelected
                                              ? (isDark ? AppColorsPS5.accent : AppColorsMonitor.accent)
                                              : (isDark ? AppColorsPS5.textHint : AppColorsMonitor.textHint),
                                        ),
                                        const SizedBox(width: Spacing.sm),
                                        Expanded(
                                          child: Text(
                                            _getTemplatedMessage(i),
                                            style: AppTypography.bodySmall.copyWith(
                                              color: isDark ? AppColorsPS5.textSecondary : AppColorsMonitor.textSecondary,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }),
                            ],
                          )
                        : const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: Spacing.xl),

            // ─── Кастомізація кольору ───────────────────────────
            Container(
              padding: const EdgeInsets.all(Spacing.base),
              decoration: BoxDecoration(
                color: (isDark ? AppColorsPS5.card : AppColorsMonitor.card),
                borderRadius: BorderRadius.circular(Radii.lg),
                border: Border.all(
                  color: isDark ? AppColorsPS5.border : AppColorsMonitor.border,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Колір картки',
                        style: AppTypography.heading3.copyWith(
                          color: isDark ? AppColorsPS5.textPrimary : AppColorsMonitor.textPrimary,
                        ),
                      ),
                      Text(
                        _colorNames[_selectedColorIndex],
                        style: AppTypography.labelMedium.copyWith(
                          color: isDark ? AppColorsPS5.textSecondary : AppColorsMonitor.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: Spacing.base),
                  Wrap(
                    spacing: Spacing.sm,
                    runSpacing: Spacing.sm,
                    children: List.generate(_cardColors.length, (index) {
                      final color = _cardColors[index];
                      final isSelected = index == _selectedColorIndex;
                      return GestureDetector(
                        onTap: () => _onColorSelected(index),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected ? Colors.white : Colors.transparent,
                              width: 3,
                            ),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: color.withOpacity(0.4),
                                      blurRadius: 14,
                                      spreadRadius: 2,
                                    ),
                                  ]
                                : null,
                          ),
                          child: isSelected
                              ? const Icon(Icons.check_rounded, color: Colors.white, size: 20)
                              : null,
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),
            const SizedBox(height: Spacing.xxl),

            // ─── Кнопки поділу ─────────────────────────────────
            Text(
              'Поділитися в',
              style: AppTypography.heading3.copyWith(
                color: isDark ? AppColorsPS5.textPrimary : AppColorsMonitor.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: Spacing.lg),

            // Перший ряд: Instagram, Telegram, Twitter
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _ShareButton(
                  icon: Icons.camera_alt_rounded,
                  label: 'Instagram',
                  color: const Color(0xFFE1306C),
                  onTap: () => _shareToInstagram(context),
                ),
                const SizedBox(width: Spacing.md),
                _ShareButton(
                  icon: Icons.send_rounded,
                  label: 'Telegram',
                  color: const Color(0xFF2AABEE),
                  onTap: () => _shareToTelegram(context),
                ),
                const SizedBox(width: Spacing.md),
                _ShareButton(
                  icon: Icons.tag_rounded,
                  label: 'Twitter',
                  color: const Color(0xFF1DA1F2),
                  onTap: () => _shareToTwitter(context),
                ),
              ],
            ),

            const SizedBox(height: Spacing.lg),

            // Другий ряд: Зберегти, Копіювати
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _ShareButton(
                  icon: Icons.save_alt_rounded,
                  label: 'Зберегти',
                  color: isDark ? AppColorsPS5.accent : AppColorsMonitor.accent,
                  onTap: () async {
                    await _captureAndSave();
                    if (mounted) {
                      context.showToast(
                        'Зображення збережено!',
                        icon: Icons.check_circle_rounded,
                      );
                    }
                  },
                ),
                const SizedBox(width: Spacing.md),
                _ShareButton(
                  icon: Icons.copy_rounded,
                  label: 'Копіювати',
                  color: isDark ? AppColorsPS5.accent : AppColorsMonitor.accent,
                  onTap: () => _copyShareText(context),
                ),
              ],
            ),

            const SizedBox(height: Spacing.xxl),

            // ─── Зберегти зображення (велика кнопка) ─────────────
            AppButtonPrimary(
              label: 'Зберегти зображення',
              icon: Icons.save_alt_rounded,
              onPressed: () async {
                await _captureAndSave();
                if (mounted) {
                  context.showToast('Зображення збережено!', icon: Icons.check_circle_rounded);
                }
              },
            ),
            const SizedBox(height: Spacing.md),

            // ─── Копіювати текст (велика кнопка) ───────────────
            AppButtonSecondary(
              label: 'Копіювати текст',
              icon: Icons.copy_rounded,
              onPressed: () => _copyShareText(context),
            ),
            const SizedBox(height: Spacing.xxxl),
          ],
        ),
      ),
    );
  }

  /// Міні-статистика для картки.
  Widget _buildMiniStat(String text, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Spacing.sm),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white.withOpacity(0.6), size: 13),
          const SizedBox(width: 4),
          Text(
            text,
            style: AppTypography.labelSmall.copyWith(
              color: Colors.white.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }

  /// Показати діалог редагування повідомлення.
  void _showEditMessageDialog(BuildContext context) {
    _messageController.text = _activeMessage;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Редагувати повідомлення'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _messageController,
              maxLines: 4,
              maxLength: 220,
              decoration: InputDecoration(
                hintText: 'Введи своє повідомлення...',
                border: const OutlineInputBorder(),
                counterText: '${_messageController.text.length}/220',
              ),
              onChanged: (_) => setState(() {
                _isCustomMessage = true;
              }),
            ),
            const SizedBox(height: Spacing.sm),
            Text(
              'Порада: використовуй емодзі для привернення уваги! 🎯',
              style: AppTypography.labelSmall.copyWith(
                color: AppColorsPS5.textSecondary,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Скасувати'),
          ),
          TextButton(
            onPressed: () {
              setState(() => _isCustomMessage = true);
              Navigator.pop(ctx);
              context.showToast('Повідомлення оновлено!');
            },
            child: const Text('Зберегти'),
          ),
        ],
      ),
    );
  }

  /// Копіювати текст в буфер обміну.
  void _copyShareText(BuildContext context) {
    Clipboard.setData(ClipboardData(text: _activeMessage));
    context.showToast('Текст скопійовано!', icon: Icons.check_circle_rounded);
  }

  /// Заглушка для поділу в Instagram.
  void _shareToInstagram(BuildContext context) {
    context.showToast('Instagram Story — незабаром!', icon: Icons.camera_alt_rounded);
  }

  /// Заглушка для поділу в Telegram.
  void _shareToTelegram(BuildContext context) {
    debugPrint('Share to Telegram: $_activeMessage');
    context.showToast('Telegram — незабаром!', icon: Icons.send_rounded);
  }

  /// Заглушка для поділу в Twitter.
  void _shareToTwitter(BuildContext context) {
    debugPrint('Share to Twitter: $_activeMessage');
    context.showToast('Twitter — незабаром!', icon: Icons.tag_rounded);
  }

  /// Захопити картку як зображення та зберегти.
  ///
  /// Використовує [RepaintBoundary] для отримання чистого зображення картки
  /// з [_kImagePixelRatio] піксельним коефіцієнтом. Зберігає у форматі PNG.
  /// Повертає `true` якщо захоплення було успішним.
  Future<bool> _captureAndSave() async {
    try {
      final boundary = _previewKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) {
        debugPrint('[ShareProgress] Error: RepaintBoundary not found');
        return false;
      }
      final image = await boundary.toImage(pixelRatio: _kImagePixelRatio);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) {
        debugPrint('[ShareProgress] Error: Failed to get byte data');
        return false;
      }
      final bytes = byteData.buffer.asUint8List();
      debugPrint('[ShareProgress] Captured image: ${bytes.length} bytes (${(bytes.length / 1024).toStringAsFixed(1)} KB)');
      return true;
    } catch (e, stackTrace) {
      debugPrint('[ShareProgress] Error capturing image: $e');
      debugPrint('[ShareProgress] Stack trace: $stackTrace');
      return false;
    }
  }

  /// Створює підпис з даними цілі для експорту.
  String _buildShareCaption() {
    return 'Моя мрія стає ближче! '
        '${_progress}% накопичено на $_goalName через Nexora 💪';
  }

  /// Валідує текст повідомлення перед збереженням.
  bool _validateMessage(String text) {
    return text.trim().length >= _kMinMessageLength &&
           text.trim().length <= _kMaxMessageLength;
  }

  /// Обчислює розмір зображення в кілобайтах.
  int _estimateImageSizeKb() {
    // Приблизковий розрахунок для картки 400x500 PNG
    return 150; // kB
  }

  /// Додає запис до історії поділів.
  ///
  /// [platform] — назва платформи поділу.
  /// [isSuccess] — чи операція була успішною.
  void _addToShareHistory(String platform, {bool isSuccess = true}) {
    try {
      _shareHistory.insert(0, _ShareHistoryEntry(
        platform: platform,
        message: _activeMessage.safeTruncate(50),
        timestamp: DateTime.now(),
        isSuccess: isSuccess,
      ));
      if (_shareHistory.length > _kMaxShareHistory) {
        _shareHistory.removeRange(_kMaxShareHistory, _shareHistory.length);
      }
      _totalShares++;
      debugPrint('[ShareProgress] Share history: $platform (success=$isSuccess, total=$_totalShares)');
    } catch (e) {
      debugPrint('[ShareProgress] Error adding to share history: $e');
    }
  }

  /// Перемикає відображення водяного знака.
  void _toggleWatermark() {
    context.haptic();
    setState(() => _showWatermark = !_showWatermark);
    debugPrint('[ShareProgress] Watermark: $_showWatermark');
  }

  /// Перемикає відображення панелі історії поділів.
  void _toggleShareHistory() {
    context.haptic();
    setState(() => _showShareHistory = !_showShareHistory);
    debugPrint('[ShareProgress] Share history panel: $_showShareHistory');
  }

  /// Будує панель історії поділів.
  Widget _buildShareHistoryPanel(Color textColor, Color subColor, Color cardColor, Color borderColor, Color accent) {
    if (_shareHistory.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(Spacing.base),
        child: Column(
          children: [
            Icon(Icons.history_rounded, color: subColor.withOpacity(0.4), size: 36),
            const SizedBox(height: Spacing.sm),
            Text('Поки немає записів', style: AppTypography.bodySmall.copyWith(color: subColor)),
            Text('Здійсни перший поділ!', style: AppTypography.labelSmall.copyWith(color: subColor.withOpacity(0.6), fontSize: 10)),
          ],
        ),
      );
    }
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: Spacing.base, vertical: Spacing.xs),
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
              Icon(Icons.history_rounded, color: accent, size: 18),
              const SizedBox(width: Spacing.sm),
              Text('Історія поділів', style: AppTypography.labelMedium.copyWith(color: textColor, fontWeight: FontWeight.w600)),
              const Spacer(),
              Text('$_totalShares поділів', style: AppTypography.labelSmall.copyWith(color: subColor)),
            ],
          ),
          const SizedBox(height: Spacing.sm),
          _buildShareStatsRow(subColor, accent),
          const SizedBox(height: Spacing.sm),
          ..._shareHistory.take(5).map((entry) => _buildHistoryEntry(entry, subColor)),
        ],
      ),
    );
  }

  /// Будує рядок статистики поділів.
  Widget _buildShareStatsRow(Color subColor, Color accent) {
    final successRate = _analytics.successRate(_shareHistory);
    final topPlatform = _analytics.mostUsedPlatform(_shareHistory);
    return Container(
      padding: const EdgeInsets.all(Spacing.sm),
      decoration: BoxDecoration(color: accent.withOpacity(0.04), borderRadius: BorderRadius.circular(Radii.sm)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Text('Успішність: ${successRate.toStringAsFixed(0)}%', style: AppTypography.labelSmall.copyWith(color: subColor, fontSize: 10)),
          if (topPlatform != null)
            Text('Топ: $topPlatform', style: AppTypography.labelSmall.copyWith(color: accent, fontSize: 10, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  /// Будує запис історії поділу.
  Widget _buildHistoryEntry(_ShareHistoryEntry entry, Color subColor) {
    final timeStr = _formatTimestamp(entry.timestamp);
    return Padding(
      padding: const EdgeInsets.only(bottom: Spacing.xs),
      child: Row(
        children: [
          Icon(
            entry.isSuccess ? Icons.check_circle_rounded : Icons.error_rounded,
            color: entry.isSuccess ? AppColorsPS5.success : AppColorsPS5.error,
            size: 14,
          ),
          const SizedBox(width: Spacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(entry.platform, style: AppTypography.labelSmall.copyWith(color: subColor, fontWeight: FontWeight.w500)),
                Text(entry.message, style: AppTypography.labelSmall.copyWith(color: subColor.withOpacity(0.5), fontSize: 9), maxLines: 1, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          Text(timeStr, style: AppTypography.labelSmall.copyWith(color: subColor.withOpacity(0.4), fontSize: 9)),
        ],
      ),
    );
  }

  /// Форматує часову мітку для відображення.
  String _formatTimestamp(DateTime timestamp) {
    try {
      final now = DateTime.now();
      final diff = now.difference(timestamp);
      if (diff.inMinutes < 1) return 'щойно';
      if (diff.inMinutes < 60) return '${diff.inMinutes}хв';
      if (diff.inHours < 24) return '${diff.inHours}год';
      return '${timestamp.day}.${timestamp.month}';
    } catch (e) {
      return '';
    }
  }

  /// Будує перемикач водяного знака.
  Widget _buildWatermarkToggle(Color subColor, Color accent) {
    return GestureDetector(
      onTap: _toggleWatermark,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _showWatermark ? Icons.water_drop_rounded : Icons.water_drop_outlined,
            color: _showWatermark ? accent : subColor,
            size: 16,
          ),
          const SizedBox(width: 4),
          Text(
            'Водяний знак',
            style: AppTypography.labelSmall.copyWith(color: _showWatermark ? accent : subColor),
          ),
        ],
      ),
    );
  }

  /// Рахує кількість емодзі в тексті.
  ///
  /// Повертає кількість емодзі-символів у [text].
  int _countEmojis(String text) {
    try {
      return text.runes.where((rune) => rune > 0x1F000).length;
    } catch (e) {
      return 0;
    }
  }

  /// Обчислює відсоток заповненості цілі для відображення.
  double get _completionPercent {
    if (_targetAmount <= 0) return 0.0;
    return (_currentAmount / _targetAmount * 100).clamp(0, 100);
  }

  /// Обчислює суму, що залишилася до досягнення цілі.
  int get _remainingAmount => (_targetAmount - _currentAmount).clamp(0, _targetAmount);

  /// Обчислює середній внесок за день активності.
  double get _averageDailyDeposit {
    final days = int.tryParse(_daysActive.replaceAll(RegExp(r'[^\d]'), '')) ?? 1;
    if (days <= 0) return 0.0;
    return _currentAmount / days;
  }

  /// Перевіряє, чи текст повідомлення достатньо довгий для експорту.
  bool get _isExportReady =>
      _activeMessage.isNotBlank &&
      _activeMessage.length >= _kMinMessageLength &&
      _countEmojis(_activeMessage) <= _kMaxEmojis;

  /// Повертає описовий тип шаблону для accessibility.
  String _getTemplateDescription(int index) {
    switch (index % _templates.length) {
      case 0: return 'Шаблон з базовими даними про ціль';
      case 1: return 'Мотиваційний шаблон з відсотком';
      case 2: return 'Шаблон з акцентом на внески';
      case 3: case 4: return 'Шаблон з акцентом на регулярність';
      case 5: return 'Шаблон з фокусом на секрет успіху';
      case 6: case 7: return 'Шаблон з емодзі-декорацією';
      default: return 'Стандартний шаблон';
    }
  }

  /// Створює повний текст для поділу з хештегами та лінком.
  String _buildFullShareText() {
    final buffer = StringBuffer();
    buffer.write(_activeMessage);
    buffer.write('\n\n');
    buffer.write(_kHashtagTemplate);
    buffer.write(' ');
    buffer.write('$_progress% | ');
    buffer.write('$_goalName | ');
    buffer.write('$_currentAmount/$_targetAmount грн');
    return buffer.toString();
  }

  /// Валідує введений користувачем текст перед збереженням.
  ///
  /// Повертає `true`, якщо текст пройшов всі перевірки.
  bool _isMessageValid() {
    if (_activeMessage.isBlank) return false;
    if (_activeMessage.length > _kMaxMessageLength) return false;
    if (_activeMessage.length < _kMinMessageLength) return false;
    if (_countEmojis(_activeMessage) > _kMaxEmojis) return false;
    return true;
  }

  /// Повертає список доступних категорій шаблонів.
  List<_ShareMessageCategory> get _availableCategories =>
      _ShareMessageCategory.values.toList();

  /// Повертає опис помилки валідації для поточного повідомлення.
  String? _validationError {
    if (_activeMessage.isBlank) return 'Введи текст повідомлення';
    if (_activeMessage.length > _kMaxMessageLength) {
      return 'Текст задовгий (макс. $_kMaxMessageLength символів)';
    }
    if (_activeMessage.length < _kMinMessageLength) {
      return 'Текст занадто короткий (мін. $_kMinMessageLength символів)';
    }
    if (_countEmojis(_activeMessage) > _kMaxEmojis) {
      return 'Забагато емодзі (макс. $_kMaxEmojis)';
    }
    return null;
  }

  /// Будує підпис для опублікування з карткою.
  String _buildPublicationCaption() {
    return 'Моя мрія стає ближче! '
        '$_progress% накопичено на $_goalName через Nexora 💪 '
        '$_kHashtagTemplate';
  }

  /// Генерує унікальне ім'я файлу для збереження зображення.
  String _generateExportFileName() {
    final now = DateTime.now();
    final date = '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}';
    final safeName = _goalName.replaceAll(RegExp(r'[^a-zA-Zа-яА-Я0-9]'), '_').toLowerCase();
    return 'nexora_${safeName}_$date.png';
  }

  /// Повертає розмір тексту повідомлення в символах.
  int get _messageCharCount => _activeMessage.length;

  /// Повертає оцінку якості повідомлення (0.0 — 1.0).
  double get _messageQualityScore {
    if (_activeMessage.isBlank) return 0.0;
    double score = 0.0;
    // Довжина: оптимально 50-150 символів
    final len = _activeMessage.length.toDouble();
    if (len >= 50 && len <= 150) score += 0.3;
    else if (len > 0) score += 0.1;
    // Наявність емодзі
    if (_countEmojis(_activeMessage) > 0 &&
        _countEmojis(_activeMessage) <= 3) score += 0.2;
    // Містить цифри (конкретні дані)
    if (RegExp(r'\d').hasMatch(_activeMessage)) score += 0.2;
    // Містить ключові слова
    if (RegExp(r'накопич|внеск|ціл|мрій|збереж', caseSensitive: false)
        .hasMatch(_activeMessage)) {
      score += 0.3;
    }
    return score.clamp(0.0, 1.0);
  }

  /// Створює структуровані дані цілі для експорту.
  _ShareGoalData get _shareGoalData => _ShareGoalData(
    goalName: _goalName,
    currentAmount: _currentAmount,
    targetAmount: _targetAmount,
    daysActive: _daysActive,
    depositCount: _depositCount,
  );

  /// Форматує суму з валютою та знаком гривні.
  String _formatAmount(int amount) {
    return '${amount.toString()} грн';
  }

  /// Перевіряє, чи поточний колір картки є стандартним (синій).
  bool get _isDefaultColor => _selectedColorIndex == 0;

  /// Обчислює індекс наступного кольору (циклічно).
  int get _nextColorIndex =>
      (_selectedColorIndex + 1) % _cardColors.length;

  /// Будує колір-дискриптор для обраного кольору.
  String _colorDescription(int index) {
    if (index < 0 || index >= _colorNames.length) return 'Невідомий';
    return '${_colorNames[index]} (${_cardColors[index].toArgb()})';
  }
}

/// Кнопка поділу — кругла іконка з підписом.
///
/// Використовується для швидкого доступу до платформ поділу:
/// Instagram, Telegram, Twitter, Зберегти, Копіювати.
/// Містить анімацію натискання та підтримку різних кольорів.
class _ShareButton extends StatelessWidget {
  /// Створює кнопку поділу.
  ///
  /// [icon] — іконка платформи або дії.
  /// [label] — текстова мітка кнопки.
  /// [color] — основний колір кнопки.
  /// [onTap] — колбек при натисканні.
  /// [size] — розмір кнопки (за замовчуванням 58).
  /// [showLoading] — чи показувати індикатор завантаження.
  /// [isEnabled] — чи кнопка активна.
  const _ShareButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
    this.size = 58,
    this.showLoading = false,
    this.isEnabled = true,
  });

  /// Іконка платформи або дії.
  final IconData icon;

  /// Текстова мітка кнопки.
  final String label;

  /// Основний колір кнопки.
  final Color color;

  /// Колбек при натисканні.
  final VoidCallback onTap;

  /// Розмір кнопки в пікселях.
  final double size;

  /// Чи показувати індикатор завантаження.
  final bool showLoading;

  /// Чи кнопка активна.
  final bool isEnabled;

  /// Обчислює відносний розмір іконки на основі розміру кнопки.
  double get _iconSize => size * 0.41;

  /// Обчислює радіус для кнопки (половина розміру для круглої форми).
  double get _borderRadius => size / 2;

  /// Обчислює непрозорість фону кнопки.
  double get _bgOpacity => isEnabled ? 0.12 : 0.05;

  /// Обчислює непрозорість рамки.
  double get _borderOpacity => isEnabled ? 0.35 : 0.15;

  /// Обчислює непрозорість тексту.
  double get _textOpacity => isEnabled ? 1.0 : 0.4;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isEnabled ? onTap : () {},
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 150),
        opacity: isEnabled ? 1.0 : 0.5,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                color: color.withOpacity(_bgOpacity),
                shape: BoxShape.circle,
                border: Border.all(color: color.withOpacity(_borderOpacity), width: 1.5),
                boxShadow: isEnabled
                    ? [
                        BoxShadow(
                          color: color.withOpacity(0.15),
                          blurRadius: 8,
                          spreadRadius: 1,
                        ),
                      ]
                    : null,
              ),
              child: showLoading
                  ? SizedBox(
                      width: _iconSize,
                      height: _iconSize,
                      child: const CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Icon(icon, color: color, size: _iconSize),
            ),
            const SizedBox(height: Spacing.sm),
            Text(
              label,
              style: AppTypography.labelSmall.copyWith(
                color: color.withOpacity(_textOpacity),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Додаткові константи екрану «Поділитися»
// ═══════════════════════════════════════════════════════════════════════════

/// Максимальна кількість емодзі в одному повідомленні для поділу.
const int _kMaxShareEmojis = 8;

/// Мінімальна ширина прев'ю-картки (пікселі).
const double _kMinPreviewWidth = 280.0;

/// Максимальна ширина прев'ю-картки (пікселі).
const double _kMaxPreviewWidth = 400.0;

/// Тривалість анімації появи кнопки поділу (мілісекунди).
const int _kShareButtonAnimMs = 300;

/// Тривалість затримки перед генерацією прев'ю (мілісекунди).
const int _kPreviewGenDelayMs = 150;

/// Кількість фонових шаблонів для картки поділу.
const int _kTemplateCount = 5;

/// Максимальна довжина імені користувача в прев'ю.
const int _kMaxAuthorNameLength = 30;

/// Відступ між рядками у форматі експорту.
const String _kExportLineSeparator = '\n';

/// Кількість записів у міні-історії поділів для прев'ю.
const int _kMiniHistoryCount = 3;

/// Тривалість анімації появи повідомлення успіху (мілісекунди).
const int _kSuccessAnimMs = 400;

/// Коефіцієнт масштабування для зображення з комплексними ефектами.
const double _kCaptureScaleFactor = 1.5;

/// Максимальна кількість фільтрів для стилів поділу.
const int _kMaxStyleFilters = 6;

/// Мінімальна кількість внесків для показу badge «Експерт поділу».
const int _kExpertShareThreshold = 10;

/// Тривалість затримки між подвійними поділами (мілісекунди).
const int _kShareDebounceMs = 500;

/// Формат timestamp для записів історії поділів.
const String _kShareTimestampFormat = 'HH:mm dd.MM';

// ═══════════════════════════════════════════════════════════════════════════
// Валідатор даних екрану «Поділитися»
// ═══════════════════════════════════════════════════════════════════════════

/// Клас для валідації даних екрану поділу.
///
/// Перевіряє коректність тексту повідомлень, параметрів прев'ю,
/// даних цілей та історії поділів.
class _ShareValidator {
  /// Не дозволяє створення екземплярів.
  _ShareValidator._();

  /// Перевіряє коректність тексту повідомлення для поділу.
  ///
  /// [text] — текст повідомлення.
  /// Повертає `true`, якщо текст відповідає обмеженням.
  static bool isValidShareText(String text) {
    if (text.isEmpty) return false;
    if (text.trim().length < _kMinMessageLength) return false;
    if (text.length > _kMaxMessageLength) return false;
    return true;
  }

  /// Перевіряє коректність імені автора для прев'ю.
  ///
  /// [name] — ім'я користувача.
  static bool isValidAuthorName(String name) {
    if (name.isEmpty) return false;
    if (name.length > _kMaxAuthorNameLength) return false;
    return name.trim().isNotEmpty;
  }

  /// Перевіряє, чи розмір прев'ю в допустимих межах.
  ///
  /// [width] — ширина прев'ю.
  static bool isValidPreviewWidth(double width) {
    return width >= _kMinPreviewWidth && width <= _kMaxPreviewWidth;
  }

  /// Перевіряє, чи можна додати запис в історію поділів.
  ///
  /// [currentCount] — поточна кількість записів.
  static bool canAddToHistory(int currentCount) {
    return currentCount < _kMaxShareHistory;
  }

  /// Перевіряє, чи користувач отримав badge «Експерт поділу».
  ///
  /// [shareCount] — кількість поділів користувача.
  static bool hasExpertBadge(int shareCount) {
    return shareCount >= _kExpertShareThreshold;
  }

  /// Повертає очищений текст повідомлення.
  ///
  /// [text] — необроблений текст користувача.
  /// Повертає текст, що відповідає обмеженням довжини.
  static String sanitizedText(String text) {
    if (text.isEmpty) return '';
    final trimmed = text.trim();
    if (trimmed.length > _kMaxMessageLength) {
      return trimmed.substring(0, _kMaxMessageLength);
    }
    return trimmed;
  }

  /// Перевіряє, чи формат зображення підтримується для експорту.
  ///
  /// [format] — формат зображення (png, jpeg).
  static bool isSupportedImageFormat(String format) {
    return ['png', 'jpeg', 'jpg'].contains(format.toLowerCase());
  }

  /// Обчислює кількість емодзі у рядку.
  ///
  /// [text] — текст для перевірки.
  static int countEmojis(String text) {
    final emojiRegex = RegExp(
      r'[\u{1F600}-\u{1F64F}]'
      r'|[\u{1F300}-\u{1F5FF}]'
      r'|[\u{1F680}-\u{1F6FF}]'
      r'|[\u{1F1E0}-\u{1F1FF}]'
      r'|[\u{2600}-\u{26FF}]'
      r'|[\u{2700}-\u{27BF}]',
      unicode: true,
    );
    return emojiRegex.allMatches(text).length;
  }

  /// Перевіряє, чи кількість емодзі в межах ліміту.
  ///
  /// [text] — текст повідомлення.
  static bool isEmojiCountValid(String text) {
    return countEmojis(text) <= _kMaxShareEmojis;
  }

  /// Перевіряє, чи піксельний коефіцієнт в допустимих межах.
  ///
  /// [ratio] — піксельний коефіцієнт.
  static bool isValidPixelRatio(double ratio) {
    return ratio >= 1.0 && ratio <= 4.0;
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Аналітика поділів (розширена)
// ═══════════════════════════════════════════════════════════════════════════

/// Розширена аналітика поділів для розрахунку додаткових метрик.
///
/// Надає методи для обчислення частоти поділів, унікальних каналів,
/// трендів та рекомендацій.
class _ShareAdvancedAnalytics {
  /// Створює об'єкт розширеної аналітики.
  const _ShareAdvancedAnalytics();

  /// Обчислює частоту поділів за останні N днів.
  ///
  /// [history] — історія поділів.
  /// [days] — кількість днів для аналізу (за замовчуванням 7).
  /// Повертає середню кількість поділів на день.
  double sharesPerDay(List<_ShareHistoryEntry> history, {int days = 7}) {
    if (history.isEmpty || days <= 0) return 0.0;
    try {
      final cutoff = DateTime.now().subtract(Duration(days: days));
      final recent = history.where((e) => e.timestamp.isAfter(cutoff)).length;
      return recent / days;
    } catch (e) {
      debugPrint('[ShareAnalytics] Error calculating shares per day: $e');
      return 0.0;
    }
  }

  /// Повертає найпопулярніший канал поділу.
  ///
  /// [history] — історія поділів.
  /// Повертає назву каналу або 'Невідомо', якщо історія порожня.
  String mostPopularChannel(List<_ShareHistoryEntry> history) {
    if (history.isEmpty) return 'Невідомо';
    try {
      final channelCounts = <String, int>{};
      for (final entry in history) {
        final channel = entry.channel;
        channelCounts[channel] = (channelCounts[channel] ?? 0) + 1;
      }
      final sorted = channelCounts.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      return sorted.first.key;
    } catch (e) {
      debugPrint('[ShareAnalytics] Error finding popular channel: $e');
      return 'Невідомо';
    }
  }

  /// Обчислює відсоток успішних поділів.
  ///
  /// [history] — історія поділів.
  double successRate(List<_ShareHistoryEntry> history) {
    if (history.isEmpty) return 0.0;
    try {
      final successful = history.where((e) => e.isSuccessful).length;
      return (successful / history.length) * 100;
    } catch (e) {
      return 0.0;
    }
  }

  /// Повертає список унікальних каналів, які використовував користувач.
  ///
  /// [history] — історія поділів.
  List<String> uniqueChannels(List<_ShareHistoryEntry> history) {
    if (history.isEmpty) return [];
    return history.map((e) => e.channel).toSet().toList()..sort();
  }

  /// Обчислює «оцінку соціальної активності» користувача.
  ///
  /// Базується на кількості поділів, каналах та частоті.
  /// Повертає значення від 0.0 до 1.0.
  double socialActivityScore(List<_ShareHistoryEntry> history) {
    if (history.isEmpty) return 0.0;
    try {
      final shareScore = (history.length / _kExpertShareThreshold).clamp(0.0, 0.5);
      final channelScore = (uniqueChannels(history).length / 4.0).clamp(0.0, 0.3);
      final frequencyScore = (sharesPerDay(history) / 2.0).clamp(0.0, 0.2);
      return shareScore + channelScore + frequencyScore;
    } catch (e) {
      return 0.0;
    }
  }

  /// Форматує зведення поділів для відображення в UI.
  ///
  /// [history] — історія поділів.
  static String formatShareSummary(List<_ShareHistoryEntry> history) {
    final total = history.length;
    final channels = history.map((e) => e.channel).toSet().length;
    final recent = history.where((e) {
      return e.timestamp.isAfter(DateTime.now().subtract(const Duration(days: 7)));
    }).length;
    return 'Усього: $total | Каналів: $channels | За тиждень: $recent';
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Розширення для обробки тексту повідомлень поділу
// ═══════════════════════════════════════════════════════════════════════════

/// Розширення для роботи з текстом повідомлень поділу.
extension _ShareTextFormatter on String {
  /// Обрізає текст до вказаної довжини з безпекою.
  ///
  /// [maxLength] — максимальна кількість символів.
  /// [ellipsis] — символ обрізання.
  String safeTruncateWithEllipsis(int maxLength, [String ellipsis = '...']) {
    if (length <= maxLength) return this;
    return '${substring(0, maxLength - ellipsis.length)}$ellipsis';
  }

  /// Видаляє зайві пробіли та переноси рядків.
  ///
  /// Повертає очищений текст без подвійних пробілів.
  String normalizeWhitespace() {
    return replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  /// Обчислює орієнтовну кількість рядків при відображенні.
  ///
  /// [charsPerLine] — середня кількість символів у рядку.
  int estimatedLineCount([int charsPerLine = 40]) {
    if (isEmpty) return 0;
    return (length / charsPerLine).ceil();
  }

  /// Додає хештег до кінця тексту, якщо його ще немає.
  ///
  /// [hashtag] — хештег для додавання.
  String appendHashtag(String hashtag) {
    if (contains(hashtag)) return this;
    return '$this $hashtag';
  }

  /// Видаляє всі емодзі з тексту.
  ///
  /// Повертає текст без емодзі.
  String removeEmojis() {
    return replaceAll(
      RegExp(
        r'[\u{1F600}-\u{1F64F}]'
        r'|[\u{1F300}-\u{1F5FF}]'
        r'|[\u{1F680}-\u{1F6FF}]'
        r'|[\u{1F1E0}-\u{1F1FF}]'
        r'|[\u{2600}-\u{26FF}]'
        r'|[\u{2700}-\u{27BF}]',
        unicode: true,
      ),
      '',
    );
  }

  /// Обрізає текст до початкового імені файлу.
  ///
  /// Повертає перші [maxWords] слів тексту.
  String firstWords(int maxWords) {
    final words = split(' ');
    if (words.length <= maxWords) return this;
    return words.take(maxWords).join(' ');
  }

  /// Перевіряє, чи текст містить тільки латинські символи та цифри.
  bool get isLatinOnly {
    return RegExp(r'^[a-zA-Z0-9\s]+$').hasMatch(this);
  }

  /// Повертає текст у верхньому регістрі з обрізанням.
  ///
  /// [maxLength] — максимальна довжина.
  String toUpperCaseTruncated(int maxLength) {
    return toUpperCase().safeTruncateWithEllipsis(maxLength);
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Темо-залежний будівник декорацій для екрану поділу
// ═══════════════════════════════════════════════════════════════════════════

/// Будівник декорацій для екрану поділу.
///
/// Надає готові методи для створення темо-залежних
/// декорацій для карток поділу, прев'ю та кнопок.
class _ShareDecorations {
  /// Не дозволяє створення екземплярів.
  _ShareDecorations._();

  /// Створює декорацію для прев'ю-картки.
  ///
  /// [accent] — акцентний колір.
  /// [isDark] — чи використовується темна тема.
  static BoxDecoration previewCard(Color accent, bool isDark) {
    return BoxDecoration(
      color: isDark ? AppColorsPS5.card : AppColorsMonitor.card,
      borderRadius: BorderRadius.circular(Radii.lg),
      border: Border.all(
        color: isDark ? AppColorsPS5.border : AppColorsMonitor.border,
      ),
      boxShadow: [
        BoxShadow(
          color: accent.withOpacity(0.08),
          blurRadius: 16,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  /// Створює декорацію для кнопки поділу з градієнтом.
  ///
  /// [color] — основний колір кнопки.
  static BoxDecoration shareButtonGradient(Color color) {
    return BoxDecoration(
      gradient: LinearGradient(
        colors: [
          color,
          color.withOpacity(0.8),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(Radii.md),
    );
  }

  /// Створює декорацію для запису історії поділів.
  ///
  /// [isDark] — чи використовується темна тема.
  static BoxDecoration historyEntry(bool isDark) {
    return BoxDecoration(
      color: (isDark ? AppColorsPS5.card : AppColorsMonitor.card).withOpacity(0.6),
      borderRadius: BorderRadius.circular(Radii.md),
      border: Border.all(
        color: (isDark ? AppColorsPS5.border : AppColorsMonitor.border).withOpacity(0.5),
      ),
    );
  }

  /// Створює декорацію для контейнера повідомлення успіху.
  ///
  /// [successColor] — колір успіху.
  static BoxDecoration successBanner(Color successColor) {
    return BoxDecoration(
      color: successColor.withOpacity(0.1),
      borderRadius: BorderRadius.circular(Radii.md),
      border: Border.all(color: successColor.withOpacity(0.25)),
    );
  }

  /// Створює декорацію для контейнера помилки валідації.
  static BoxDecoration validationError() {
    return BoxDecoration(
      color: AppColorsPS5.error.withOpacity(0.08),
      borderRadius: BorderRadius.circular(Radii.sm),
      border: Border.all(color: AppColorsPS5.error.withOpacity(0.2)),
    );
  }

  /// Створює декорацію з тінню для кнопки поділу.
  ///
  /// [color] — колір кнопки.
  static BoxDecoration elevatedShareButton(Color color) {
    return BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(Radii.md),
      boxShadow: [
        BoxShadow(
          color: color.withOpacity(0.3),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }
}
