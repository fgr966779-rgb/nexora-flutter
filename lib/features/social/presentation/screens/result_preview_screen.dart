import 'dart:math' as math;
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
import '../../../../core/utils/haptic_service.dart';
import '../../../../core/widgets/app_button_primary.dart';
import '../../../../core/widgets/app_button_secondary.dart';

// ═══════════════════════════════════════════════════════════════════════════
// Константи екрану «Попередній перегляд»
// ═══════════════════════════════════════════════════════════════════════════

/// Кількість орбітальних частинок.
const int _kOrbitalParticleCount = 12;

/// Радіус орбіти частинок.
const double _kOrbitRadius = 88.0;

/// Розмір основної візуалізації.
const double _kVisualizationSize = 220.0;

/// Розмір внутрішнього кільця.
const double _kInnerRingSize = 160.0;

/// Розмір основного кола.
const double _kMainCircleSize = 130.0;

/// Тривалість обертання (секунди).
const int _kSpinDurationSec = 4;

/// Тривалість scale-анімації (мілісекунди).
const int _kScaleDurationMs = 800;

/// Тривалість counter-анімації (мілісекунди).
const int _kCounterDurationMs = 2000;

/// Затримка запуску counter (мілісекунди).
const int _kCounterDelayMs = 500;

/// Кількість зіроківок для святкування.
const int _kCelebrationSparkleCount = 4;

/// Мінімальний відсоток для показу зіроківок.
const int _kSparkleMinPercent = 95;

/// Максимальний розмір частинки (пікселів).
const double _kMaxParticleSize = 5.5;

/// Мінімальний розмір частинки (пікселів).
const double _kMinParticleSize = 3.0;

/// Мінімальна непрозорість частинок.
const double _kMinParticleOpacity = 0.3;

/// Максимальна непрозорість частинок.
const double _kMaxParticleOpacity = 0.7;

/// Мінімальна непрозорість зовнішнього кільця.
const double _kOuterRingMinOpacity = 0.08;

/// Мінімальна непрозорість внутрішнього кільця.
const double _kInnerRingMinOpacity = 0.15;

/// Максимальна кількість зображень для експорту за сесію.
const int _kMaxExportsPerSession = 10;

/// Затримка перед повторним експортом (мілісекунди).
const int _kExportCooldownMs = 1000;

/// Кількість шаблонів для прев'ю результату.
const int _kTemplateCount = 3;

/// Тривалість анімації зміни шаблону (мілісекунди).
const int _kTemplateSwitchDurationMs = 400;

/// Мінімальна сума для показу «вражаючого» результату.
const double _kImpressiveAmountThreshold = 10000.0;

/// Максимальна довжина тексту підпису при експорті.
const int _kMaxCaptionLength = 150;

// ═══════════════════════════════════════════════════════════════════════════
// Utility Extensions
// ═══════════════════════════════════════════════════════════════════════════

/// Розширення для роботи з анімаціями.
extension _AnimationUtils on double {
  /// Обмежує значення між min та max.
  double clampValue(double min, double max) => clamp(min, max);

  /// Перевіряє, чи значення позитивне.
  bool get isPositive => this > 0;

  /// Повертає відсоток як рядок з символом.
  String formattedAsPercent() => (this * 100).toInt().toString() + '%';
}

/// Розширення для Color.
extension _ColorAnimationUtils on Color {
  /// Повертає колір з модифікованою непрозорістю.
  Color withOpacityClamped(double opacity) => withOpacity(opacity.clamp(0.0, 1.0));

  /// Створює LinearGradient від поточного кольору до прозорого.
  LinearGradient toTransparentGradient({Alignment begin = Alignment.topLeft, Alignment? end}) {
    return LinearGradient(
      colors: [this, this.withOpacity(0.0)],
      begin: begin,
      end: end ?? Alignment.bottomRight,
    );
  }
}

/// Екран «Попередній перегляд»
///
/// Визначає вигляд та налаштування візуалізації результату.
enum PreviewTemplate {
  /// Стандартний шаблон — базова візуалізація з частинками.
  standard(
    label: 'Стандартний',
    icon: Icons.circle_outlined,
    description: 'Класичний вигляд з частинками та відсотками',
  ),

  /// Мінімалістичний шаблон — чистий та простий.
  minimal(
    label: 'Мінімалістичний',
    icon: Icons.minimize_rounded,
    description: 'Чистий вигляд без зайвих елементів',
  ),

  /// Ефектний шаблон — з великими частинками та блискітками.
  cinematic(
    label: 'Кінематографічний',
    icon: Icons.movie_rounded,
    description: 'Ефектний вигляд з анімацією частинок',
  ),

  /// Спортивний шаблон — динамічний з акцентом на досягненнях.
  sport(
    label: 'Спортивний',
    icon: Icons.emoji_events_rounded,
    description: 'Динамічний вигляд з фокусом на досягненнях',
  ),

  /// Елегантний шаблон — м'які кольори та плавні переходи.
  elegant(
    label: 'Елегантний',
    icon: Icons.auto_awesome_rounded,
    description: 'М\'який вигляд з плавними анімаціями',
  );

  const PreviewTemplate({
    required this.label,
    required this.icon,
    required this.description,
  });

  /// Назва шаблону (українською).
  final String label;

  /// Іконка шаблону.
  final IconData icon;

  /// Опис шаблону (українською).
  final String description;
}

/// Формат експорту попереднього перегляду.
enum ExportFormat {
  /// Зображення PNG.
  png(label: 'PNG', icon: Icons.image_rounded),

  /// Документ PDF.
  pdf(label: 'PDF', icon: Icons.picture_as_pdf_rounded),

  /// Спеціальний формат для соціальних мереж.
  social(label: 'Для соцмереж', icon: Icons.share_rounded),

  /// Відео (у розробці).
  video(label: 'Відео', icon: Icons.videocam_rounded);

  const ExportFormat({
    required this.label,
    required this.icon,
  });

  /// Назва формату (українською).
  final String label;

  /// Іконка формату.
  final IconData icon;
}

/// Екран «Попередній перегляд» — кінематографічна анімація цілі на 100%.
///
/// Містить:
/// - Обертову 3D-подібну візуалізацію цілі на 100%
/// - Текст «100% завершено!» з анімацією
/// - Підзаголовок «Так виглядатиме твій результат»
/// - Кнопку «Це надихає!»
/// - Кнопку «Завантажити як відео» (вимкнена, з бейджем «незабаром»)
/// - Частинкові ефекти навколо цілі
/// - Анімацію масштабу при появі
/// - Закриття при натисканні поза контентом
/// - Кнопку «Поділитися результатом»
/// - Швидкі дії: розблокувати бейдж, переглянути статистику, експорт
/// - Лічильник відсотків з анімацією
/// - Кілька шаблонів попереднього перегляду
/// - Порівняння «початок vs поточний»
/// - Вибір формату експорту
class ResultPreviewScreen extends StatefulWidget {
  /// Створює екран прев'ю результату.
  ///
  /// [goalName] — назва цілі накопичування (за замовчуванням 'PS5').
  /// [collectedAmount] — зібрана сума (за замовчуванням 25999).
  /// [targetAmount] — цільова сума (за замовчуванням 25000).
  /// [daysTaken] — кількість днів досягнення (за замовчуванням 45).
  const ResultPreviewScreen({
    super.key,
    this.goalName = 'PS5',
    this.collectedAmount = 25999,
    this.targetAmount = 25000,
    this.daysTaken = 45,
  });

  /// Назва цілі накопичування.
  final String goalName;

  /// Зібрана сума.
  final int collectedAmount;

  /// Цільова сума.
  final int targetAmount;

  /// Кількість днів досягнення.
  final int daysTaken;

  @override
  State<ResultPreviewScreen> createState() => _ResultPreviewScreenState();
}

class _ResultPreviewScreenState extends State<ResultPreviewScreen>
    with TickerProviderStateMixin {
  late AnimationController _spinController;
  late AnimationController _scaleController;
  late Animation<double> _scaleAnim;
  late Animation<double> _particleController;
  late AnimationController _counterController;
  int _animatedPercent = 0;

  /// Активний шаблон попереднього перегляду.
  PreviewTemplate _currentTemplate = PreviewTemplate.cinematic;

  /// Чи показувати порівняння «початок vs зараз».
  bool _showComparison = false;

  /// Чи показуємо панель вибору шаблону.
  bool _showTemplatePicker = false;

  /// Чи показуємо панель вибору формату експорту.
  bool _showExportPicker = false;

  /// Початкова сума для порівняння.
  final double _startAmount = 0;

  /// Поточна сума для порівняння.
  final double _currentAmount = 25000;

  /// Назва цілі.
  final String _goalName = 'PlayStation 5';

  @override
  void initState() {
    super.initState();

    // Spin controller for 3D-like rotation
    _spinController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();

    // Scale controller for entrance animation
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _scaleAnim = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 0.0, end: 1.15),
        weight: 60,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.15, end: 1.0),
        weight: 40,
      ),
    ]).animate(CurvedAnimation(
      parent: _scaleController,
      curve: AppEasings.smooth,
    ));

    // Particle animation controller
    _particleController = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _spinController,
        curve: Curves.easeInOut,
      ),
    );

    // Counter animation
    _counterController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..addListener(() {
        if (mounted) {
          setState(() {
            _animatedPercent = (_counterController.value * 100).toInt();
          });
        }
      });

    _scaleController.forward();

    // Start counter after a delay
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) _counterController.forward();
    });
  }

  @override
  void dispose() {
    _spinController.dispose();
    _scaleController.dispose();
    _counterController.dispose();
    super.dispose();
  }

  /// Кількість експортів за поточну сесію.
  int _exportCount = 0;

  /// Час останнього експорту.
  DateTime? _lastExportTime;

  /// Поточний індекс шаблону.
  int _currentTemplateIndex = 0;

  /// Чи результат вражаючий (сума > порогу).
  bool get _isImpressive => collectedAmount >= _kImpressiveAmountThreshold;

  /// Обчислює перевиконання цілі у відсотках.
  double get _overachievementPercent {
    if (targetAmount <= 0) return 0.0;
    return ((collectedAmount - targetAmount) / targetAmount * 100).clamp(0, double.infinity);
  }

  /// Обчислює середній щоденний внесок.
  double get _averageDaily {
    if (daysTaken <= 0) return 0.0;
    return collectedAmount / daysTaken;
  }

  /// Перевіряє, чи експорт дозволений (ліміт + cooldown).
  bool get _canExport {
    if (_exportCount >= _kMaxExportsPerSession) return false;
    if (_lastExportTime == null) return true;
    return DateTime.now().difference(_lastExportTime!).inMilliseconds >= _kExportCooldownMs;
  }

  /// Обробляє експорт результату з перевірками лімітів.
  void _handleExport(ExportFormat format) {
    if (!_canExport) {
      context.showToast('Зачекай перед наступним експортом', icon: Icons.hourglass_top_rounded);
      return;
    }
    _exportCount++;
    _lastExportTime = DateTime.now();
    debugPrint('[ResultPreview] Export #$exportCount: $format');
    _onExport(format);
  }

  /// Обробляє натискання «Мене надихає».
  void _onInspired() {
    HapticService.success();
    Navigator.of(context).pop(true);
  }

  void _onShare() {
    HapticService.selection();
    _showShareBottomSheet();
  }

  void _showShareBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: const EdgeInsets.all(Spacing.xl),
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? AppColorsPS5.card
              : AppColorsMonitor.card,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(Radii.xl),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColorsPS5.textHint.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: Spacing.lg),
            Text(
              'Поділитися результатом',
              style: AppTypography.heading3.copyWith(
                color: AppColorsPS5.textPrimary,
              ),
            ),
            const SizedBox(height: Spacing.md),
            _shareOption(Icons.copy_rounded, 'Копіювати посилання'),
            _shareOption(Icons.image_rounded, 'Зберегти як зображення'),
            _shareOption(Icons.share_rounded, 'Поділитися через...'),
            _shareOption(Icons.qr_code_rounded, 'Показати QR-код'),
            const SizedBox(height: Spacing.xl),
          ],
        ),
      ),
    );
  }

  Widget _shareOption(IconData icon, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: Spacing.sm),
      child: GestureDetector(
        onTap: () {
          HapticService.lightTap();
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('$label — успішно!', style: AppTypography.labelMedium.copyWith(color: AppColorsPS5.textPrimary)),
              behavior: SnackBarBehavior.floating,
              duration: const Duration(milliseconds: 1500),
            ),
          );
        },
        child: Row(
          children: [
            Icon(icon, color: AppColorsPS5.accent, size: 22),
            const SizedBox(width: Spacing.md),
            Text(label, style: AppTypography.bodyMedium.copyWith(color: AppColorsPS5.textPrimary)),
            const Spacer(),
            Icon(Icons.chevron_right_rounded, color: AppColorsPS5.textHint, size: 20),
          ],
        ),
      ),
    );
  }

  void _onExport(ExportFormat format) {
    HapticService.selection();
    Navigator.pop(context);
    final messages = {
      ExportFormat.png: 'Зображення збережено!',
      ExportFormat.pdf: 'Звіт експортовано в PDF!',
      ExportFormat.social: 'Зображення для соцмереж готове!',
      ExportFormat.video: 'Відео поки недоступне 🚧',
    };
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          messages[format] ?? 'Експортовано!',
          style: AppTypography.labelMedium.copyWith(color: AppColorsPS5.textPrimary),
        ),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(milliseconds: 2000),
        action: format != ExportFormat.video
            ? SnackBarAction(
                label: 'OK',
                onPressed: () {},
                textColor: AppColorsPS5.accent,
              )
            : null,
      ),
    );
  }

  void _showExportPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: const EdgeInsets.all(Spacing.xl),
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? AppColorsPS5.card
              : AppColorsMonitor.card,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(Radii.xl),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColorsPS5.textHint.withOpacity(0.3), borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: Spacing.lg),
            Text('Оберіть формат експорту', style: AppTypography.heading3.copyWith(color: AppColorsPS5.textPrimary)),
            const SizedBox(height: Spacing.md),
            ...ExportFormat.values.map((format) => Padding(
              padding: const EdgeInsets.only(bottom: Spacing.sm),
              child: GestureDetector(
                onTap: () => _onExport(format),
                child: Container(
                  padding: const EdgeInsets.all(Spacing.base),
                  decoration: BoxDecoration(
                    color: AppColorsPS5.accent.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(Radii.md),
                    border: Border.all(color: AppColorsPS5.accent.withOpacity(0.12)),
                  ),
                  child: Row(children: [
                    Icon(format.icon, color: AppColorsPS5.accent, size: 22),
                    const SizedBox(width: Spacing.md),
                    Text(format.label, style: AppTypography.labelLarge.copyWith(color: AppColorsPS5.textPrimary)),
                    const Spacer(),
                    if (format == ExportFormat.video)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(color: AppColorsPS5.warning, borderRadius: BorderRadius.circular(Radii.sm)),
                        child: Text('Незабаром', style: AppTypography.labelSmall.copyWith(color: Colors.black, fontWeight: FontWeight.w700)),
                      ),
                  ]),
                ),
              ),
            )),
            const SizedBox(height: Spacing.xl),
          ],
        ),
      ),
    );
  }

  void _toggleComparison() {
    HapticService.selection();
    setState(() => _showComparison = !_showComparison);
  }

  void _cycleTemplate() {
    HapticService.selection();
    setState(() {
      final values = PreviewTemplate.values;
      final idx = values.indexOf(_currentTemplate);
      _currentTemplate = values[(idx + 1) % values.length];
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor =
        isDark ? AppColorsPS5.background : AppColorsMonitor.background;
    final textColor =
        isDark ? AppColorsPS5.textPrimary : AppColorsMonitor.textPrimary;
    final subColor =
        isDark ? AppColorsPS5.textSecondary : AppColorsMonitor.textSecondary;
    final accent =
        isDark ? AppColorsPS5.accent : AppColorsMonitor.accent;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text('Попередній перегляд — ${_currentTemplate.label}'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: textColor,
        actions: [
          // Кнопка зміни шаблону
          IconButton(
            icon: Icon(Icons.style_rounded, color: subColor),
            onPressed: _cycleTemplate,
            tooltip: 'Змінити шаблон',
          ),
          // Кнопка порівняння
          IconButton(
            icon: Icon(
              _showComparison ? Icons.compare_arrows_rounded : Icons.swap_vert_rounded,
              color: _showComparison ? accent : subColor,
            ),
            onPressed: _toggleComparison,
            tooltip: 'Порівняння',
          ),
          // Кнопка поділитися
          IconButton(
            icon: Icon(Icons.share_rounded, color: subColor),
            onPressed: _onShare,
            tooltip: 'Поділитися',
          ),
        ],
      ),
      body: GestureDetector(
        onTap: () => Navigator.of(context).pop(true),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: Spacing.base),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: Spacing.xxl),

                // ─── Spinning 3D-like Goal Visualization ────────────
                _buildGoalVisualization(accent),

                const SizedBox(height: Spacing.xxl),

                // ─── Animated counter ─────────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '$_animatedPercent',
                      style: AppTypography.displayMedium.copyWith(
                        color: accent,
                        fontSize: 48,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '% завершено!',
                      style: AppTypography.displaySmall.copyWith(
                        color: textColor,
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                )
                    .animate()
                    .fade(delay: 400.ms, duration: 600.ms)
                    .slideY(
                      begin: 0.2,
                      end: 0,
                      delay: 400.ms,
                      duration: 600.ms,
                      curve: AppEasings.smooth,
                    ),

                const SizedBox(height: Spacing.sm),

                // ─── Goal name ──────────────────────────────────
                Text(
                  _goalName,
                  style: AppTypography.heading4.copyWith(
                    color: subColor,
                    letterSpacing: 1.0,
                  ),
                  textAlign: TextAlign.center,
                ).animate().fade(delay: 450.ms, duration: 500.ms),

                const SizedBox(height: Spacing.sm),

                // ─── Subtitle ───────────────────────────────────────
                Text(
                  'Так виглядатиме твій результат',
                  style: AppTypography.bodyLarge.copyWith(color: subColor),
                  textAlign: TextAlign.center,
                )
                    .animate()
                    .fade(delay: 600.ms, duration: 500.ms)
                    .slideY(begin: 0.1, end: 0, delay: 600.ms, duration: 500.ms),

                // ─── Sparkle text ───────────────────────────────────
                const SizedBox(height: Spacing.xs),
                Text(
                  '✨ Твоя мета — у твоїх руках! ✨',
                  style: AppTypography.bodyMedium.copyWith(
                    color: accent,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                )
                    .animate()
                    .fade(delay: 800.ms, duration: 400.ms)
                    .scale(
                      delay: 800.ms,
                      duration: 500.ms,
                      curve: AppEasings.subtlePop,
                    ),

                // ─── Comparison view (start vs current) ──────────
                if (_showComparison)
                  _buildComparisonView(isDark, accent),

                // ─── Achievement preview ────────────────────────────
                const SizedBox(height: Spacing.lg),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: Spacing.base, vertical: Spacing.sm),
                  decoration: BoxDecoration(
                    color: AppColorsPS5.xp.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(Radii.md),
                    border: Border.all(color: AppColorsPS5.xp.withOpacity(0.15)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.emoji_events_rounded, color: AppColorsPS5.xp, size: 18),
                      const SizedBox(width: Spacing.sm),
                      Text(
                        'Досягнення «Мета досягнута» чекає на тебе!',
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColorsPS5.xp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ).animate().fade(delay: 900.ms, duration: 400.ms).scale(delay: 900.ms, duration: 400.ms, curve: Curves.easeOutBack),

                const Spacer(),

                // ─── Quick actions row ─────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: Spacing.xl),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            HapticService.selection();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Статистика цілі відкрита!', style: AppTypography.labelMedium.copyWith(color: AppColorsPS5.textPrimary)),
                                behavior: SnackBarBehavior.floating,
                                duration: const Duration(milliseconds: 1500),
                              ),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.all(Spacing.md),
                            decoration: BoxDecoration(
                              color: accent.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(Radii.md),
                              border: Border.all(color: accent.withOpacity(0.15)),
                            ),
                            child: Column(
                              children: [
                                Icon(Icons.bar_chart_rounded, color: accent, size: 22),
                                const SizedBox(height: Spacing.xs),
                                Text('Статистика', style: AppTypography.labelSmall.copyWith(color: accent)),
                              ],
                            ),
                          ),
                        ),
                      ).animate().fade(delay: 1000.ms, duration: 300.ms),
                      const SizedBox(width: Spacing.sm),
                      Expanded(
                        child: GestureDetector(
                          onTap: _onShare,
                          child: Container(
                            padding: const EdgeInsets.all(Spacing.md),
                            decoration: BoxDecoration(
                              color: accent.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(Radii.md),
                              border: Border.all(color: accent.withOpacity(0.15)),
                            ),
                            child: Column(
                              children: [
                                Icon(Icons.share_rounded, color: accent, size: 22),
                                const SizedBox(height: Spacing.xs),
                                Text('Поділитися', style: AppTypography.labelSmall.copyWith(color: accent)),
                              ],
                            ),
                          ),
                        ),
                      ).animate().fade(delay: 1100.ms, duration: 300.ms),
                      const SizedBox(width: Spacing.sm),
                      Expanded(
                        child: GestureDetector(
                          onTap: _showExportPicker,
                          child: Container(
                            padding: const EdgeInsets.all(Spacing.md),
                            decoration: BoxDecoration(
                              color: accent.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(Radii.md),
                              border: Border.all(color: accent.withOpacity(0.15)),
                            ),
                            child: Column(
                              children: [
                                Icon(Icons.file_download_rounded, color: accent, size: 22),
                                const SizedBox(height: Spacing.xs),
                                Text('Експорт', style: AppTypography.labelSmall.copyWith(color: accent)),
                              ],
                            ),
                          ),
                        ),
                      ).animate().fade(delay: 1200.ms, duration: 300.ms),
                    ],
                  ),
                ),

                const SizedBox(height: Spacing.lg),

                // ─── Action Buttons ────────────────────────────────
                // Primary: «Це надихає!»
                AppButtonPrimary(
                  label: 'Це надихає!',
                  icon: Icons.celebration_rounded,
                  showGlow: true,
                  isFullWidth: true,
                  onPressed: _onInspired,
                )
                    .animate()
                    .fade(delay: 1300.ms, duration: 400.ms)
                    .slideY(begin: 0.1, end: 0, delay: 1300.ms, duration: 400.ms),

                const SizedBox(height: Spacing.md),

                // Secondary: «Завантажити як відео» (disabled + badge)
                Stack(
                  children: [
                    AppButtonSecondary(
                      label: 'Завантажити як відео',
                      icon: Icons.videocam_rounded,
                      isDisabled: true,
                      isFullWidth: true,
                      onPressed: () {},
                    ),
                    Positioned(
                      right: 12,
                      top: -8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: AppColorsPS5.warning,
                          borderRadius: BorderRadius.circular(Radii.sm),
                          boxShadow: AppShadows.warningGlow(
                            blur: 8,
                            opacity: 0.3,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.lock_outline_rounded,
                              color: Colors.black,
                              size: 10,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              'незабаром',
                              style: AppTypography.labelSmall.copyWith(
                                color: Colors.black,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                )
                    .animate()
                    .fade(delay: 1400.ms, duration: 400.ms),

                // ─── Share hint ─────────────────────────────────────
                const SizedBox(height: Spacing.md),
                Text(
                  'Натисни поза карткою, щоб закрити',
                  style: AppTypography.labelSmall.copyWith(
                    color: isDark
                        ? AppColorsPS5.textHint
                        : AppColorsMonitor.textHint,
                  ),
                )
                    .animate()
                    .fade(delay: 1600.ms, duration: 400.ms),

                const SizedBox(height: Spacing.xxl),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─── Comparison View (Start vs Current) ────────────────────────────────

  Widget _buildComparisonView(bool isDark, Color accent) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Spacing.xl),
      child: Container(
        margin: const EdgeInsets.only(top: Spacing.md),
        padding: const EdgeInsets.all(Spacing.base),
        decoration: BoxDecoration(
          color: (isDark ? AppColorsPS5.card : AppColorsMonitor.card)
              .withOpacity(0.8),
          borderRadius: BorderRadius.circular(Radii.lg),
          border: Border.all(
            color: accent.withOpacity(0.15),
          ),
        ),
        child: Column(
          children: [
            Text(
              '📊 Порівняння',
              style: AppTypography.labelMedium.copyWith(
                color: accent,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: Spacing.md),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                // Початок
                Column(
                  children: [
                    Text(
                      '0 ₴',
                      style: AppTypography.monoMedium.copyWith(
                        color: isDark ? AppColorsPS5.textHint : AppColorsMonitor.textHint,
                      ),
                    ),
                    const SizedBox(height: Spacing.xs),
                    Text(
                      'Початок',
                      style: AppTypography.caption.copyWith(
                        color: isDark ? AppColorsPS5.textSecondary : AppColorsMonitor.textSecondary,
                      ),
                    ),
                  ],
                ),
                // Стрілка
                Icon(Icons.arrow_forward_rounded, color: accent, size: 24),
                // Поточний
                Column(
                  children: [
                    Text(
                      '$_currentAmount ₴',
                      style: AppTypography.monoMedium.copyWith(
                        color: accent,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: Spacing.xs),
                    Text(
                      'Зараз',
                      style: AppTypography.caption.copyWith(
                        color: isDark ? AppColorsPS5.textSecondary : AppColorsMonitor.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    ).animate().fade(duration: 400.ms).scale(duration: 400.ms, curve: Curves.easeOutBack);
  }

  // ─── Goal Visualization with Particles ──────────────────────────────────

  Widget _buildGoalVisualization(Color accent) {
    return AnimatedBuilder(
      animation: _spinController,
      builder: (context, _) {
        final rotation = _spinController.value * 0.04 * math.pi;
        final particleT = _particleController.value;

        return AnimatedBuilder(
          animation: _scaleController,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnim.value,
              child: SizedBox(
                width: 220,
                height: 220,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // ── Orbital particles ──
                    ...List.generate(12, (index) {
                      final angle = (index / 12) * 2 * math.pi +
                          _spinController.value * math.pi * 2;
                      final radius = 88.0 + math.sin(particleT * math.pi * 2 + index) * 12;
                      final px = math.cos(angle) * radius;
                      final py = math.sin(angle) * radius * 0.7;
                      final size = 3.0 + math.sin(particleT * math.pi * 2 + index * 0.5) * 2.5;
                      final opacity = 0.3 + math.sin(particleT * math.pi * 2 + index * 0.3) * 0.4;

                      return Positioned(
                        left: 110 + px - size / 2,
                        top: 110 + py - size / 2,
                        child: Container(
                          width: size,
                          height: size,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: accent.withOpacity(opacity),
                            boxShadow: [
                              BoxShadow(
                                color: accent.withOpacity(opacity * 0.6),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                        ),
                      );
                    }),

                    // ── Outer ring ──
                    Container(
                      width: 180,
                      height: 180,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: accent.withOpacity(0.08 + particleT * 0.05),
                          width: 1,
                        ),
                      ),
                    ),

                    // ── Inner glow ring ──
                    Container(
                      width: 160,
                      height: 160,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: accent.withOpacity(0.15 + particleT * 0.1),
                          width: 2,
                        ),
                      ),
                    ),

                    // ── Main circle ──
                    Transform.rotate(
                      angle: rotation,
                      child: Container(
                        width: 130,
                        height: 130,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [
                              AppColorsPS5.gradientStart,
                              AppColorsPS5.gradientEnd,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            AppShadows.glow(
                              AppColorsPS5.accent,
                              blur: 40,
                              opacity: 0.4 + particleT * 0.3,
                              spread: 4,
                            ),
                          ],
                        ),
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.gamepad_rounded,
                                color: Colors.white.withOpacity(0.9),
                                size: 44,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '$_animatedPercent%',
                                style: AppTypography.labelLarge.copyWith(
                                  color: Colors.white.withOpacity(0.8),
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // ── Celebration sparkles ──
                    if (_animatedPercent >= 95)
                      ...List.generate(4, (index) {
                        final angle = (index / 4) * 2 * math.pi + _spinController.value * math.pi;
                        final dist = 60.0 + math.sin(particleT * math.pi * 4 + index * 2) * 10;
                        final sx = math.cos(angle) * dist;
                        final sy = math.sin(angle) * dist;
                        return Positioned(
                          left: 110 + sx - 4,
                          top: 110 + sy - 4,
                          child: Icon(
                            Icons.auto_awesome_rounded,
                            color: Colors.amber.withOpacity(0.5 + particleT * 0.3),
                            size: 10,
                          ),
                        );
                      }),
                  ],
                ),
              ),
            );
          },
        );
      },
    ).animate().fade(duration: 800.ms, curve: AppEasings.smooth);
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Додаткові константи екрану «Попередній перегляд»
// ═══════════════════════════════════════════════════════════════════════════

/// Мінімальний відсоток для показу «excellent» badge.
const int _kExcellentPercent = 95;

/// Мінімальний відсоток для показу «good» badge.
const int _kGoodPercent = 75;

/// Мінімальний відсоток для показу «average» badge.
const int _kAveragePercent = 50;

/// Кількість кольорів у градієнті кільця прогресу.
const int _kGradientColorCount = 3;

/// Тривалість затримки перед початком анімації кільця (мілісекунди).
const int _kRingAnimDelayMs = 200;

/// Розмір бейджа результату (пікселі).
const double _kResultBadgeSize = 48.0;

/// Кількість фонових частинок для святкування.
const int _kCelebrationParticles = 8;

/// Максимальна швидкість обертання орбіти (радіан/секунду).
const double _kMaxOrbitalSpeed = 2.0;

/// Мінімальна непрозорість фонових частинок.
const double _kMinParticleOpacity = 0.1;

/// Максимальна непрозорість фонових частинок.
const double _kMaxParticleOpacity = 0.6;

/// Кількість кадрів для згладжування анімації.
const int _kAnimationSmoothingFrames = 30;

/// Мінімальна кількість цілей для показу «Майстер цілей» badge.
const int _kMasterGoalsThreshold = 10;

/// Тривалість затримки перед показом summary card (мілісекунди).
const int _kSummaryDelayMs = 1200;

/// Максимальна кількість статистичних метрик для відображення.
const int _kMaxStatMetrics = 6;

/// Коефіцієнт масштабування для orbital частинок.
const double _kOrbitalScaleFactor = 1.2;

/// Префікс для ключів кешу результатів.
const String _kResultCachePrefix = 'result_';

/// Максимальна кількість записів у кеші результатів.
const int _kResultMaxCacheEntries = 20;

/// Формат підсумкового тексту для результату.
const String _kSummaryFormat = '{percent}% виконано';

/// Мінімальний відсоток для показу ефекту святкування.
const int _kCelebrationMinPercent = 90;

/// Тривалість затримки перед перезапуском анімації (мілісекунди).
const int _kRestartAnimDelayMs = 3000;

// ═══════════════════════════════════════════════════════════════════════════
// Валідатор даних результату
// ═══════════════════════════════════════════════════════════════════════════

/// Клас для валідації даних екрану результату.
///
/// Перевіряє коректність відсотків, розмірів, параметрів анімації.
class _ResultValidator {
  /// Не дозволяє створення екземплярів.
  _ResultValidator._();

  /// Перевіряє, чи відсоток в допустимому діапазоні (0-100).
  ///
  /// [percent] — відсоток для перевірки.
  static bool isValidPercent(int percent) {
    return percent >= 0 && percent <= 100;
  }

  /// Перевіряє, чи розмір візуалізації в допустимих межах.
  ///
  /// [size] — розмір у пікселях.
  static bool isValidSize(double size) {
    return size > 0 && size <= 500;
  }

  /// Перевіряє, чи кількість орбітальних частинок допустима.
  ///
  /// [count] — кількість частинок.
  static bool isValidParticleCount(int count) {
    return count >= 0 && count <= 20;
  }

  /// Перевіряє, чи швидкість обертання в допустимих межах.
  ///
  /// [duration] — тривалість обертання в секундах.
  static bool isValidSpinDuration(int duration) {
    return duration > 0 && duration <= 60;
  }

  /// Повертає класифікацію результату за відсотком.
  ///
  /// [percent] — відсоток виконання.
  static String resultClassification(int percent) {
    if (percent >= _kExcellentPercent) return 'Відмінно';
    if (percent >= _kGoodPercent) return 'Добре';
    if (percent >= _kAveragePercent) return 'Середньо';
    return 'Потребує покращення';
  }

  /// Повертає колір для класифікації результату.
  ///
  /// [percent] — відсоток виконання.
  static Color classificationColor(int percent) {
    if (percent >= _kExcellentPercent) return AppColorsPS5.success;
    if (percent >= _kGoodPercent) return AppColorsPS5.accent;
    if (percent >= _kAveragePercent) return AppColorsPS5.coin;
    return AppColorsPS5.error;
  }

  /// Обчислює кількість зірокок для результату (1-5).
  ///
  /// [percent] — відсоток виконання.
  static int starRating(int percent) {
    if (percent >= 98) return 5;
    if (percent >= 90) return 4;
    if (percent >= 75) return 3;
    if (percent >= 50) return 2;
    return 1;
  }

  /// Перевіряє, чи налаштування анімації коректні.
  ///
  /// [duration] — тривалість анімації.
  /// [delay] — затримка.
  static bool isValidAnimationConfig(int duration, int delay) {
    return duration > 0 && delay >= 0 && delay < duration;
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Кеш результатів попереднього перегляду
// ═══════════════════════════════════════════════════════════════════════════

/// Клас для кешування обчислених результатів попереднього перегляду.
///
/// Зберігає попередньо обчислені значення анімацій,
/// кольорів та метрик для оптимізації rebuild.
class _ResultCache {
  /// Створює кеш з початковими значеннями.
  _ResultCache();

  /// Внутрішнє сховище.
  final Map<String, dynamic> _store = {};

  /// Зберігає значення за ключем.
  ///
  /// [key] — унікальний ключ.
  /// [value] — значення для кешування.
  void put(String key, dynamic value) {
    if (_store.length >= _kResultMaxCacheEntries) {
      _store.remove(_store.keys.first);
    }
    _store['$_kResultCachePrefix$key'] = value;
  }

  /// Отримує значення з кешу.
  ///
  /// [key] — унікальний ключ.
  T? get<T>(String key) {
    final value = _store['$_kResultCachePrefix$key'];
    if (value is T) return value;
    return null;
  }

  /// Перевіряє наявність ключа.
  bool contains(String key) => _store.containsKey('$_kResultCachePrefix$key');

  /// Очищає кеш.
  void clear() => _store.clear();

  /// Розмір кешу.
  int get size => _store.length;
}

// ═══════════════════════════════════════════════════════════════════════════
// Аналітика результатів попереднього перегляду
// ═══════════════════════════════════════════════════════════════════════════

/// Клас для обчислення аналітичних метрик результату.
///
/// Надає методи для розрахунку тенденцій, порівнянь,
/// та генерації підсумкових текстів.
class _ResultAnalytics {
  /// Створює об'єкт аналітики.
  const _ResultAnalytics();

  /// Обчислює різницю між поточним та попереднім результатом.
  ///
  /// [current] — поточний відсоток.
  /// [previous] — попередній відсоток.
  int difference(int current, int previous) {
    return current - previous;
  }

  /// Повертає текстову оцінку прогресу.
  ///
  /// [current] — поточний відсоток.
  /// [previous] — попередній відсоток.
  String progressLabel(int current, int previous) {
    final diff = difference(current, previous);
    if (diff > 0) return '+$diff% краще';
    if (diff < 0) return '$diff% гірше';
    return 'Без змін';
  }

  /// Повертає іконку для оцінки прогресу.
  ///
  /// [current] — поточний відсоток.
  /// [previous] — попередній відсоток.
  IconData progressIcon(int current, int previous) {
    final diff = difference(current, previous);
    if (diff > 0) return Icons.trending_up_rounded;
    if (diff < 0) return Icons.trending_down_rounded;
    return Icons.remove_rounded;
  }

  /// Обчислює середній відсоток за список результатів.
  ///
  /// [percents] — список відсотків.
  double average(List<int> percents) {
    if (percents.isEmpty) return 0.0;
    return percents.fold<int>(0, (sum, p) => sum + p) / percents.length;
  }

  /// Повертає найкращий результат зі списку.
  ///
  /// [percents] — список відсотків.
  int bestResult(List<int> percents) {
    if (percents.isEmpty) return 0;
    return percents.reduce((a, b) => a > b ? a : b);
  }

  /// Обчислює медіанний результат.
  ///
  /// [percents] — список відсотків.
  double median(List<int> percents) {
    if (percents.isEmpty) return 0.0;
    final sorted = List<int>.from(percents)..sort();
    final mid = sorted.length ~/ 2;
    if (sorted.length % 2 == 0) {
      return (sorted[mid - 1] + sorted[mid]) / 2.0;
    }
    return sorted[mid].toDouble();
  }

  /// Форматує підсумковий текст результату.
  ///
  /// [percent] — відсоток виконання.
  static String formatResultSummary(int percent) {
    if (percent >= _kExcellentPercent) {
      return 'Чудовий результат! $percent% цілі досягнуто!';
    } else if (percent >= _kGoodPercent) {
      return 'Гарна робота! $percent% — ти на правильному шляху.';
    } else if (percent >= _kAveragePercent) {
      return '$percent% виконано. Є можливість для покращення.';
    }
    return '$percent% виконано. Не здавайся, наступного разу буде краще!';
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Темо-залежний будівник декорацій для результату
// ═══════════════════════════════════════════════════════════════════════════

/// Будівник декорацій для екрану попереднього перегляду результату.
///
/// Надає готові методи для створення темо-залежних
/// декорацій для кільця прогресу, карток статистики та badge.
class _ResultDecorations {
  /// Не дозволяє створення екземплярів.
  _ResultDecorations._();

  /// Створює декорацію для картки кільця прогресу.
  ///
  /// [accent] — акцентний колір.
  /// [isDark] — чи використовується темна тема.
  static BoxDecoration progressRingCard(Color accent, bool isDark) {
    return BoxDecoration(
      color: isDark ? AppColorsPS5.card : AppColorsMonitor.card,
      shape: BoxShape.circle,
      boxShadow: [
        AppShadows.glow(
          accent,
          blur: 40,
          opacity: 0.3,
          spread: 4,
        ),
      ],
    );
  }

  /// Створює декорацію для картки статистики.
  ///
  /// [isDark] — чи використовується темна тема.
  static BoxDecoration statsCard(bool isDark) {
    return BoxDecoration(
      color: (isDark ? AppColorsPS5.card : AppColorsMonitor.card).withOpacity(0.8),
      borderRadius: BorderRadius.circular(Radii.lg),
      border: Border.all(
        color: (isDark ? AppColorsPS5.border : AppColorsMonitor.border).withOpacity(0.5),
      ),
    );
  }

  /// Створює декорацію для badge результату.
  ///
  /// [color] — колір badge.
  static BoxDecoration resultBadge(Color color) {
    return BoxDecoration(
      color: color.withOpacity(0.15),
      borderRadius: BorderRadius.circular(Radii.xl),
      border: Border.all(color: color.withOpacity(0.3)),
    );
  }

  /// Створює декорацію для ефекту святкування.
  ///
  /// [color] — колір ефекту.
  static BoxDecoration celebrationOverlay(Color color) {
    return BoxDecoration(
      gradient: RadialGradient(
        colors: [
          color.withOpacity(0.2),
          color.withOpacity(0.05),
          Colors.transparent,
        ],
        radius: 0.8,
      ),
    );
  }

  /// Створює декорацію для внутрішнього кільця.
  ///
  /// [accent] — акцентний колір.
  static BoxDecoration innerRing(Color accent) {
    return BoxDecoration(
      color: accent.withOpacity(0.05),
      shape: BoxShape.circle,
      border: Border.all(
        color: accent.withOpacity(0.1),
        width: 1,
      ),
    );
  }

  /// Створює декорацію для елемента орбітальної частинки.
  ///
  /// [color] — колір частинки.
  static BoxDecoration orbitalParticle(Color color) {
    return BoxDecoration(
      color: color,
      shape: BoxShape.circle,
      boxShadow: [
        BoxShadow(
          color: color.withOpacity(0.5),
          blurRadius: 4,
          spreadRadius: 1,
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Провайдер підказок для екрану результату
// ═══════════════════════════════════════════════════════════════════════════

/// Провайдер контекстних підказок для екрану попереднього перегляду.
class _ResultTipProvider {
  /// Не дозволяє створення екземплярів.
  _ResultTipProvider._();

  /// Підказка для ідеального результату (100%).
  static String perfectTip() {
    return 'Ідеально! Ти досяг 100% цілі! Ти — справжній чемпіон!';
  }

  /// Підказка для відмінного результату (95%+).
  static String excellentTip(int percent) {
    return 'Фантастично! $percent% — результат майже ідеальний!';
  }

  /// Підказка для доброго результату (75%+).
  static String goodTip(int percent) {
    return 'Гарно! $percent% — ти на правильному шляху до мети!';
  }

  /// Підказка для середнього результату (50%+).
  static String averageTip(int percent) {
    return '$percent% — непоганий початок. Продовжуй працювати!';
  }

  /// Підказка для результату, що потребує покращення.
  static String needsImprovementTip(int percent) {
    return '$percent% — не зупиняйся! Кожен день наближає тебе до мети.';
  }

  /// Повертає підказку залежно від відсотка.
  static String contextualTip(int percent) {
    if (percent >= 100) return perfectTip();
    if (percent >= _kExcellentPercent) return excellentTip(percent);
    if (percent >= _kGoodPercent) return goodTip(percent);
    if (percent >= _kAveragePercent) return averageTip(percent);
    return needsImprovementTip(percent);
  }

  /// Підказка для порівняння з попереднім результатом.
  static String comparisonTip(int current, int previous) {
    final diff = current - previous;
    if (diff > 0) return 'Ти покращив результат на $diff%!';
    if (diff < 0) return 'Результат зменшився на ${diff.abs()}%.';
    return 'Результат незмінний.';
  }

  /// Підказка для заохочення повторної спроби.
  static String retryEncouragement() {
    return 'Спробуй знову — ти можеш краще!';
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Утиліти для обчислення параметрів анімації
// ═══════════════════════════════════════════════════════════════════════════

/// Утиліти для обчислення параметрів анімацій візуалізації.
class _AnimationUtils {
  /// Не дозволяє створення екземплярів.
  _AnimationUtils._();

  /// Обчислює кут для орбітальної частинки за індексом.
  ///
  /// [index] — індекс частинки.
  /// [total] — загальна кількість частинок.
  /// [progress] — поточний прогрес анімації (0.0 — 1.0).
  static double orbitalAngle(int index, int total, double progress) {
    if (total <= 0) return 0.0;
    return (index / total) * 2 * math.pi + progress * math.pi * 2;
  }

  /// Обчислює позицію частинки на орбіті.
  ///
  /// [angle] — кут в радіанах.
  /// [radius] — радіус орбіти.
  /// Повертає пару (x, y).
  static (double x, double y) orbitalPosition(double angle, double radius) {
    return (math.cos(angle) * radius, math.sin(angle) * radius);
  }

  /// Обчислює непрозорість частинки з пульсацією.
  ///
  /// [time] — час (0.0 — 1.0).
  /// [minOpacity] — мінімальна непрозорість.
  /// [maxOpacity] — максимальна непрозорість.
  static double pulsatingOpacity(double time, {double minOpacity = 0.2, double maxOpacity = 0.8}) {
    final t = (math.sin(time * math.pi * 2) + 1) / 2;
    return minOpacity + (maxOpacity - minOpacity) * t;
  }

  /// Згладжує значення за допомогою інтерполяції.
  ///
  /// [current] — поточне значення.
  /// [target] — цільове значення.
  /// [factor] — коефіцієнт згладжування (0.0 — 1.0).
  static double smooth(double current, double target, double factor) {
    return current + (target - current) * factor;
  }

  /// Обчислює масштаб для bounce-ефекту.
  ///
  /// [progress] — прогрес анімації (0.0 — 1.0).
  static double bounceScale(double progress) {
    if (progress < 0.5) {
      return 1.0 + 0.2 * math.sin(progress * math.pi * 2);
    }
    return 1.0 - 0.1 * math.sin((progress - 0.5) * math.pi);
  }

  /// Обчислює розмір частинки залежно від дистанції.
  ///
  /// [distance] — відстань від центру.
  /// [baseSize] — базовий розмір.
  static double particleSize(double distance, double baseSize) {
    return baseSize * (1.0 - distance / (_kOrbitRadius * _kOrbitalScaleFactor)).clamp(0.3, 1.0);
  }
}
