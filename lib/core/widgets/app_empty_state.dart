import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../constants/app_colors.dart';
import '../constants/app_typography.dart';
import '../constants/app_spacing.dart';
import '../constants/app_radii.dart';
import '../constants/app_durations.dart';
import '../constants/app_easings.dart';

// ═══════════════════════════════════════════════════════════════════════════
// Перелік типів пустого стану (Empty State Type Enum)
// ═══════════════════════════════════════════════════════════════════════════

/// Тип пустого стану — визначає іконку, тексти та тип дії.
///
/// Кожен тип має автоматичні іконки, заголовки, підзаголовки,
/// кольори та текстові мітки кнопок.
enum EmptyStateType {
  /// Немає активної цілі заощаджень.
  ///
  /// Коли користувач ще не створив жодної цілі.
  noGoal(
    icon: Icons.flag_outlined,
    title: 'Немає активної цілі',
    subtitle: 'Створи нову ціль заощаджень, щоб почати накопичувати',
    actionLabel: 'Створити ціль',
    secondaryLabel: 'Переглянути шаблони',
    emoji: '🎯',
    accentColor: Color(0xFF006FCD),
    illustrationType: EmptyIllustrationType.goal,
  ),

  /// Немає транзакцій.
  ///
  /// Коли історія транзакцій порожня.
  noTransactions(
    icon: Icons.receipt_long_outlined,
    title: 'Немає транзакцій',
    subtitle: 'Твоя історія порожня. Зроби перший внесок!',
    actionLabel: 'Додати внесок',
    secondaryLabel: 'Імпортувати',
    emoji: '💳',
    accentColor: Color(0xFF4D9AE8),
    illustrationType: EmptyIllustrationType.transaction,
  ),

  /// Немає активних викликів.
  ///
  /// Коли користувач не бере участі у жодному виклику.
  noChallenges(
    icon: Icons.bolt_outlined,
    title: 'Немає викликів',
    subtitle: 'Виклики допоможуть заощадити швидше і цікавіше',
    actionLabel: 'Знайти виклик',
    secondaryLabel: 'Мої завершені',
    emoji: '⚡',
    accentColor: Color(0xFFFF9100),
    illustrationType: EmptyIllustrationType.challenge,
  ),

  /// Немає зароблених бейджів.
  ///
  /// Коли користувач ще не отримав жодного бейджу.
  noBadges(
    icon: Icons.emoji_events_outlined,
    title: 'Немає бейджів',
    subtitle: 'Виконуй завдання та виклики, щоб заробити бейджі',
    actionLabel: 'Перегляти завдання',
    secondaryLabel: 'Доступні нагороди',
    emoji: '🏆',
    accentColor: Color(0xFFFFD600),
    illustrationType: EmptyIllustrationType.badge,
  ),

  /// Немає досягнень.
  ///
  /// Коли користувач ще не має жодного досягнення.
  noAchievements(
    icon: Icons.military_tech_outlined,
    title: 'Немає досягнень',
    subtitle: 'Здобувай досягнення за активність та старанність!',
    actionLabel: 'Перегляти можливості',
    secondaryLabel: 'Як працюють досягнення',
    emoji: '🎖️',
    accentColor: Color(0xFFAB47BC),
    illustrationType: EmptyIllustrationType.achievement,
  ),

  /// Немає підключення до інтернету.
  ///
  /// Коли пристрій не має доступу до мережі.
  noInternet(
    icon: Icons.wifi_off_rounded,
    title: 'Немає інтернету',
    subtitle: 'Перевірте з\'єднання та спробуйте ще раз',
    actionLabel: 'Спробувати знову',
    secondaryLabel: null,
    emoji: '🌐',
    accentColor: Color(0xFF78909C),
    illustrationType: EmptyIllustrationType.offline,
  ),

  /// Сталася помилка при завантаженні даних.
  ///
  /// Коли сталася помилка сервера або мережі.
  error(
    icon: Icons.error_outline_rounded,
    title: 'Щось пішло не так',
    subtitle: 'Не вдалося завантажити дані. Спробуйте пізніше',
    actionLabel: 'Повторити',
    secondaryLabel: 'Написати в підтримку',
    emoji: '❌',
    accentColor: Color(0xFFFF1744),
    illustrationType: EmptyIllustrationType.error,
  ),

  /// Немає результатів пошуку.
  ///
  /// Коли пошук не дав результатів.
  noSearchResults(
    icon: Icons.search_off_rounded,
    title: 'Нічого не знайдено',
    subtitle: 'Спробуйте змінити параметри пошуку',
    actionLabel: 'Очистити фільтри',
    secondaryLabel: null,
    emoji: '🔍',
    accentColor: Color(0xFF4D9AE8),
    illustrationType: EmptyIllustrationType.search,
  ),

  /// Контент ще не доступний.
  ///
  /// Для upcoming features або locked content.
  comingSoon(
    icon: Icons.lock_clock_outlined,
    title: 'Незабаром',
    subtitle: 'Цей розділ буде доступний у найближчому оновленні',
    actionLabel: 'Дізнатися більше',
    secondaryLabel: null,
    emoji: '🔒',
    accentColor: Color(0xFF78909C),
    illustrationType: EmptyIllustrationType.locked,
  );

  const EmptyStateType({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.actionLabel,
    required this.secondaryLabel,
    required this.emoji,
    required this.accentColor,
    required this.illustrationType,
  });

  /// Іконка для стану (Material Icons).
  final IconData icon;

  /// Заголовок стану (українською).
  final String title;

  /// Підзаголовок стану (українською).
  final String subtitle;

  /// Текст кнопки основної дії.
  final String? actionLabel;

  /// Текст другорядної кнопки.
  final String? secondaryLabel;

  /// Емодзі для стану (для сповіщень або чатів).
  final String emoji;

  /// Колір-акцент для іконки.
  final Color accentColor;

  /// Тип ілюстрації для анімованого фону.
  final EmptyIllustrationType illustrationType;

  /// Колір іконки залежить від теми.
  Color iconColor(bool isLightTheme) {
    return isLightTheme ? accentColor : accentColor;
  }

  /// Фонова область навколо іконки (круг з напівпрозорим фоном).
  Color iconBgColor(bool isLightTheme) {
    return accentColor.withOpacity(0.1);
  }

  /// Третинна дія (якщо є).
  String? get tertiaryLabel {
    switch (this) {
      case EmptyStateType.noGoal:
        return 'Отримати підказку';
      case EmptyStateType.noTransactions:
        return 'Як це працює';
      case EmptyStateType.noChallenges:
        return 'Створити свій';
      case EmptyStateType.noAchievements:
        return 'Переглянути leaderboard';
      default:
        return null;
    }
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Типи ілюстрацій для пустого стану (Illustration Types)
// ═══════════════════════════════════════════════════════════════════════════

/// Тип анімованої ілюстрації для пустого стану.
enum EmptyIllustrationType {
  /// Ілюстрація для цілей — прапорець на горі.
  goal,

  /// Ілюстрація для транзакцій — порожня картка.
  transaction,

  /// Ілюстрація для викликів — блискавка.
  challenge,

  /// Ілюстрація для бейджів — трофей.
  badge,

  /// Ілюстрація для досягнень — медаль.
  achievement,

  /// Ілюстрація для офлайн-стану — хмарка.
  offline,

  /// Ілюстрація для помилки — попереджувальний знак.
  error,

  /// Ілюстрація для пошуку — лупа.
  search,

  /// Ілюстрація для заблокованого контенту — замок.
  locked,
}

// ═══════════════════════════════════════════════════════════════════════════
// Анімовані ілюстрації (Animated Illustration Widgets)
// ═══════════════════════════════════════════════════════════════════════════

/// Анімована ілюстрація для пустого стану.
///
/// Генерує просту геометричну ілюстрацію залежно від типу.
/// Використовує кольори та форми відповідно до контексту.
class EmptyStateIllustration extends StatefulWidget {
  const EmptyStateIllustration({
    super.key,
    required this.type,
    this.accentColor,
    this.size = 120,
  });

  /// Тип ілюстрації.
  final EmptyIllustrationType type;

  /// Кольор-акцент.
  final Color? accentColor;

  /// Розмір ілюстрації в пікселях.
  final double size;

  @override
  State<EmptyStateIllustration> createState() => _EmptyStateIllustrationState();
}

class _EmptyStateIllustrationState extends State<EmptyStateIllustration>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.accentColor ?? AppColorsPS5.accent;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final value = _controller.value;
        return SizedBox(
          width: widget.size,
          height: widget.size,
          child: CustomPaint(
            painter: _EmptyIllustrationPainter(
              type: widget.type,
              color: color,
              animValue: value,
            ),
          ),
        );
      },
    );
  }
}

/// Кастомний painter для геометричних ілюстрацій пустого стану.
class _EmptyIllustrationPainter extends CustomPainter {
  _EmptyIllustrationPainter({
    required this.type,
    required this.color,
    required this.animValue,
  });

  final EmptyIllustrationType type;
  final Color color;
  final double animValue;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()
      ..color = color.withOpacity(0.15)
      ..style = PaintingStyle.fill;

    // Декоративні кола
    canvas.drawCircle(
      center + Offset(0, -10 + animValue * 4),
      size.width * 0.35,
      paint,
    );
    canvas.drawCircle(
      center + Offset(15, 10 - animValue * 3),
      size.width * 0.15,
      paint..color = color.withOpacity(0.1),
    );

    // Центральної елемент — коло з емодзі
    final centerPaint = Paint()
      ..color = color.withOpacity(0.2 + animValue * 0.05)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, size.width * 0.25, centerPaint);
  }

  @override
  bool shouldRepaint(covariant _EmptyIllustrationPainter old) {
    return old.animValue != animValue || old.color != color;
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Віджет пустого стану (Empty State Widget)
// ═══════════════════════════════════════════════════════════════════════════

/// Повноекранний стан порожнього контенту з іконкою, текстом та кнопками.
///
/// Підтримує 9 типів пустого стану з автоматичними іконками та текстами,
/// кастомні перевизначення, кнопку дії, другорядну дію, терциарну дію,
/// анімацію появи, анімовану ілюстрацію, placeholder для Lottie,
/// та адаптивне масштабування розмірів.
///
/// Приклад використання:
/// ```dart
/// AppEmptyState(
///   type: EmptyStateType.noGoal,
///   onAction: () => Navigator.pushNamed(context, '/goal/create'),
/// )
///
/// // З анімованою ілюстрацією
/// AppEmptyState(
///   type: EmptyStateType.noTransactions,
///   showIllustration: true,
///   onAction: () => _showAddTransaction(),
/// )
/// ```
class AppEmptyState extends StatelessWidget {
  const AppEmptyState({
    super.key,
    this.type,
    this.icon,
    this.title,
    this.subtitle,
    this.actionLabel,
    this.onAction,
    this.secondaryLabel,
    this.onSecondaryAction,
    this.isLightTheme = false,
    this.animate = true,
    this.lottiePlaceholder,
    this.iconSize = 64,
    this.showIllustration = false,
    this.compact = false,
    this.tertiaryLabel,
    this.onTertiaryAction,
    this.animationDelay = Duration.zero,
  });

  /// Тип пустого стану (визначає іконку, тексти автоматично).
  final EmptyStateType? type;

  /// Кастомна іконка (перевизначає type.icon).
  final IconData? icon;

  /// Кастомний заголовок (перевизначає type.title).
  final String? title;

  /// Кастомний підзаголовок (перевизначає type.subtitle).
  final String? subtitle;

  /// Кастомний текст кнопки дії (перевизначає type.actionLabel).
  final String? actionLabel;

  /// Зворотний виклик кнопки дії.
  final VoidCallback? onAction;

  /// Кастомний текст другорядної кнопки (перевизначає type.secondaryLabel).
  final String? secondaryLabel;

  /// Зворотний виклик другорядної кнопки.
  final VoidCallback? onSecondaryAction;

  /// Світла тема (Monitor замість PS5).
  final bool isLightTheme;

  /// Показувати анімацію появи (fade-in).
  final bool animate;

  /// Заглушка для Lottie-анімації (можна додати пізніше).
  final Widget? lottiePlaceholder;

  /// Розмір іконки в пікселях.
  final double iconSize;

  /// Показувати анімовану ілюстрацію замість іконки.
  final bool showIllustration;

  /// Компактний режим — без вертикальних відступів.
  final bool compact;

  /// Кастомний текст терциарної кнопки.
  final String? tertiaryLabel;

  /// Зворотний виклик терциарної кнопки.
  final VoidCallback? onTertiaryAction;

  /// Затримка анімації появи.
  final Duration animationDelay;

  // ═══════════════════════════════════════════════════════════════════════
  // Обчислені значення (Computed Values)
  // ═══════════════════════════════════════════════════════════════════════

  /// Ефективна іконка (кастомна або з типу).
  IconData get _effectiveIcon => icon ?? type?.icon ?? Icons.inbox_outlined;

  /// Ефективний заголовок.
  String get _effectiveTitle => title ?? type?.title ?? 'Немає даних';

  /// Ефективний підзаголовок.
  String get _effectiveSubtitle =>
      subtitle ?? type?.subtitle ?? 'Здається, тут поки нічого немає';

  /// Ефективна мітка кнопки дії.
  String? get _effectiveActionLabel =>
      actionLabel ?? type?.actionLabel;

  /// Ефективна мітка другорядної кнопки.
  String? get _effectiveSecondaryLabel =>
      secondaryLabel ?? type?.secondaryLabel;

  /// Ефективна мітка терциарної кнопки.
  String? get _effectiveTertiaryLabel =>
      tertiaryLabel ?? type?.tertiaryLabel;

  /// Ефективний колір іконки.
  Color get _effectiveIconColor =>
      type?.iconColor(isLightTheme) ??
      (isLightTheme
          ? AppColorsMonitor.textHint
          : AppColorsPS5.textHint);

  /// Колір заголовка.
  Color get _titleColor =>
      isLightTheme ? AppColorsMonitor.textPrimary : AppColorsPS5.textPrimary;

  /// Колір підзаголовка.
  Color get _subtitleColor =>
      isLightTheme
          ? AppColorsMonitor.textSecondary
          : AppColorsPS5.textSecondary;

  /// Колір кнопки дії.
  Color get _buttonColor =>
      isLightTheme ? AppColorsMonitor.accent : AppColorsPS5.accent;

  /// Колір фону іконки.
  Color get _iconBgColor =>
      type?.iconBgColor(isLightTheme) ?? _effectiveIconColor.withOpacity(0.1);

  /// Кольор-акцент з типу.
  Color get _accentColor =>
      type?.accentColor ?? AppColorsPS5.accent;

  // ═══════════════════════════════════════════════════════════════════════
  // Побудова (Build)
  // ═══════════════════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    Widget content = Center(
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: compact ? Spacing.xl : Spacing.xxl,
          vertical: compact ? Spacing.xl : Spacing.xxxl,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Анімована ілюстрація ──
            if (showIllustration && type != null) ...[
              EmptyStateIllustration(
                type: type!.illustrationType,
                accentColor: _accentColor,
                size: iconSize * 1.8,
              ),
            ] else if (lottiePlaceholder != null) ...[
              SizedBox(
                width: iconSize * 2,
                height: iconSize * 2,
                child: lottiePlaceholder!,
              ),
            ] else ...[
              _buildIconContainer(),
            ],
            const SizedBox(height: Spacing.lg),
            // ── Заголовок ──
            Text(
              _effectiveTitle,
              style: (compact ? AppTypography.heading3 : AppTypography.heading2)
                  .copyWith(color: _titleColor),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: Spacing.sm),
            // ── Підзаголовок ──
            Text(
              _effectiveSubtitle,
              style: AppTypography.bodyMedium.copyWith(
                color: _subtitleColor,
              ),
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: Spacing.xl),
            // ── Кнопки дій ──
            _buildActionButtons(),
          ],
        ),
      ),
    );

    // ── Анімація появи ──
    if (animate) {
      content = content.animate(
        delay: animationDelay,
      ).fadeIn(
            duration: AppDurations.medium,
            curve: AppEasings.decelerate,
          );
    }

    return content;
  }

  // ═══════════════════════════════════════════════════════════════════════
  // Контейнер іконки (Icon Container)
  // ═══════════════════════════════════════════════════════════════════════

  /// Будує круглий контейнер з іконкою.
  Widget _buildIconContainer() {
    return Container(
      width: iconSize * 1.4,
      height: iconSize * 1.4,
      decoration: BoxDecoration(
        color: _iconBgColor,
        shape: BoxShape.circle,
      ),
      child: Icon(
        _effectiveIcon,
        size: iconSize,
        color: _effectiveIconColor,
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // Кнопки дій (Action Buttons)
  // ═══════════════════════════════════════════════════════════════════════

  /// Будує кнопки основної, другорядної та терциарної дії.
  Widget _buildActionButtons() {
    final hasPrimary = _effectiveActionLabel != null && onAction != null;
    final hasSecondary =
        _effectiveSecondaryLabel != null && onSecondaryAction != null;
    final hasTertiary =
        _effectiveTertiaryLabel != null && onTertiaryAction != null;

    if (!hasPrimary && !hasSecondary && !hasTertiary) {
      return const SizedBox.shrink();
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // ── Основна кнопка ──
        if (hasPrimary) ...[
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onAction,
              style: ElevatedButton.styleFrom(
                backgroundColor: _buttonColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: Spacing.xl,
                  vertical: Spacing.md + 2,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(Radii.base),
                ),
                elevation: 0,
              ),
              child: Text(
                _effectiveActionLabel!,
                style: AppTypography.buttonMedium.copyWith(
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
        // ── Другорядна кнопка ──
        if (hasSecondary) ...[
          const SizedBox(height: Spacing.sm),
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: onSecondaryAction,
              style: TextButton.styleFrom(
                foregroundColor: _subtitleColor,
                padding: const EdgeInsets.symmetric(
                  horizontal: Spacing.xl,
                  vertical: Spacing.md,
                ),
              ),
              child: Text(
                _effectiveSecondaryLabel!,
                style: AppTypography.buttonMedium.copyWith(
                  color: _subtitleColor,
                ),
              ),
            ),
          ),
        ],
        // ── Терциарна кнопка ──
        if (hasTertiary) ...[
          const SizedBox(height: Spacing.xs),
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: onTertiaryAction,
              style: TextButton.styleFrom(
                foregroundColor: _subtitleColor.withOpacity(0.7),
                padding: const EdgeInsets.symmetric(
                  horizontal: Spacing.xl,
                  vertical: Spacing.sm,
                ),
              ),
              child: Text(
                _effectiveTertiaryLabel!,
                style: AppTypography.labelSmall.copyWith(
                  color: _subtitleColor.withOpacity(0.7),
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Зручні фабричні конструктори (Convenience Factory Methods)
// ═══════════════════════════════════════════════════════════════════════════

/// Зручні фабричні конструктори для типових пустих станів.
///
/// Дозволяють швидко створити пустий стан без явного
/// вказування типу та міток.
extension AppEmptyStatePresets on AppEmptyState {
  /// Пустий стан — немає цілей.
  static AppEmptyState noGoal({
    VoidCallback? onCreate,
    VoidCallback? onTemplates,
    VoidCallback? onTip,
    bool isLightTheme = false,
    bool showIllustration = false,
  }) {
    return AppEmptyState(
      type: EmptyStateType.noGoal,
      onAction: onCreate,
      onSecondaryAction: onTemplates,
      onTertiaryAction: onTip,
      isLightTheme: isLightTheme,
      showIllustration: showIllustration,
    );
  }

  /// Пустий стан — немає транзакцій.
  static AppEmptyState noTransactions({
    VoidCallback? onAdd,
    VoidCallback? onImport,
    VoidCallback? onHowItWorks,
    bool isLightTheme = false,
    bool showIllustration = false,
  }) {
    return AppEmptyState(
      type: EmptyStateType.noTransactions,
      onAction: onAdd,
      onSecondaryAction: onImport,
      onTertiaryAction: onHowItWorks,
      isLightTheme: isLightTheme,
      showIllustration: showIllustration,
    );
  }

  /// Пустий стан — немає викликів.
  static AppEmptyState noChallenges({
    VoidCallback? onBrowse,
    VoidCallback? onCompleted,
    VoidCallback? onCreate,
    bool isLightTheme = false,
    bool showIllustration = false,
  }) {
    return AppEmptyState(
      type: EmptyStateType.noChallenges,
      onAction: onBrowse,
      onSecondaryAction: onCompleted,
      onTertiaryAction: onCreate,
      isLightTheme: isLightTheme,
      showIllustration: showIllustration,
    );
  }

  /// Пустий стан — немає бейджів.
  static AppEmptyState noBadges({
    VoidCallback? onViewTasks,
    VoidCallback? onRewards,
    bool isLightTheme = false,
    bool showIllustration = false,
  }) {
    return AppEmptyState(
      type: EmptyStateType.noBadges,
      onAction: onViewTasks,
      onSecondaryAction: onRewards,
      isLightTheme: isLightTheme,
      showIllustration: showIllustration,
    );
  }

  /// Пустий стан — немає досягнень.
  static AppEmptyState noAchievements({
    VoidCallback? onView,
    VoidCallback? onLeaderboard,
    bool isLightTheme = false,
    bool showIllustration = false,
  }) {
    return AppEmptyState(
      type: EmptyStateType.noAchievements,
      onAction: onView,
      onSecondaryAction: onLeaderboard,
      isLightTheme: isLightTheme,
      showIllustration: showIllustration,
    );
  }

  /// Пустий стан — немає інтернету.
  static AppEmptyState noInternet({
    VoidCallback? onRetry,
    bool isLightTheme = false,
    bool showIllustration = false,
  }) {
    return AppEmptyState(
      type: EmptyStateType.noInternet,
      onAction: onRetry,
      isLightTheme: isLightTheme,
      showIllustration: showIllustration,
    );
  }

  /// Пустий стан — помилка.
  static AppEmptyState error({
    VoidCallback? onRetry,
    VoidCallback? onSupport,
    bool isLightTheme = false,
    bool showIllustration = false,
  }) {
    return AppEmptyState(
      type: EmptyStateType.error,
      onAction: onRetry,
      onSecondaryAction: onSupport,
      isLightTheme: isLightTheme,
      showIllustration: showIllustration,
    );
  }

  /// Пустий стан — немає результатів пошуку.
  static AppEmptyState noSearchResults({
    VoidCallback? onClearFilters,
    bool isLightTheme = false,
    bool showIllustration = false,
  }) {
    return AppEmptyState(
      type: EmptyStateType.noSearchResults,
      onAction: onClearFilters,
      isLightTheme: isLightTheme,
      showIllustration: showIllustration,
    );
  }

  /// Пустий стан — контент незабаром.
  static AppEmptyState comingSoon({
    VoidCallback? onLearnMore,
    bool isLightTheme = false,
    bool showIllustration = false,
  }) {
    return AppEmptyState(
      type: EmptyStateType.comingSoon,
      onAction: onLearnMore,
      isLightTheme: isLightTheme,
      showIllustration: showIllustration,
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Допоміжні віджети (Helper Widgets)
// ═══════════════════════════════════════════════════════════════════════════

/// Міні-пустий стан для вбудовування у списки та картки.
///
/// Компактна версія з лише іконкою, коротким текстом та однією кнопкою.
class AppEmptyStateMini extends StatelessWidget {
  const AppEmptyStateMini({
    super.key,
    required this.title,
    this.subtitle,
    this.icon = Icons.inbox_outlined,
    this.onAction,
    this.actionLabel,
    this.isLightTheme = false,
    this.accentColor,
  });

  /// Заголовок.
  final String title;

  /// Підзаголовок.
  final String? subtitle;

  /// Іконка.
  final IconData icon;

  /// Callback дії.
  final VoidCallback? onAction;

  /// Текст кнопки.
  final String? actionLabel;

  /// Світла тема.
  final bool isLightTheme;

  /// Кольор-акцент.
  final Color? accentColor;

  @override
  Widget build(BuildContext context) {
    final color = accentColor ??
        (isLightTheme ? AppColorsMonitor.accent : AppColorsPS5.accent);
    final textColor =
        isLightTheme ? AppColorsMonitor.textPrimary : AppColorsPS5.textPrimary;
    final subColor =
        isLightTheme ? AppColorsMonitor.textSecondary : AppColorsPS5.textSecondary;
    final bgColor =
        isLightTheme ? AppColorsMonitor.card : AppColorsPS5.card;

    return Container(
      padding: const EdgeInsets.all(Spacing.xl),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(Radii.md),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 40),
          const SizedBox(height: Spacing.md),
          Text(
            title,
            style: AppTypography.labelLarge.copyWith(color: textColor),
            textAlign: TextAlign.center,
          ),
          if (subtitle != null) ...[
            const SizedBox(height: Spacing.xs),
            Text(
              subtitle!,
              style: AppTypography.caption.copyWith(color: subColor),
              textAlign: TextAlign.center,
              maxLines: 2,
            ),
          ],
          if (onAction != null && actionLabel != null) ...[
            const SizedBox(height: Spacing.md),
            GestureDetector(
              onTap: onAction,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: Spacing.lg,
                  vertical: Spacing.sm,
                ),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(Radii.base),
                ),
                child: Text(
                  actionLabel!,
                  style: AppTypography.labelMedium.copyWith(
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Конфігурація пустого стану (Empty State Configuration)
// ═══════════════════════════════════════════════════════════════════════════

/// Клас конфігурації для пустого стану.
///
/// Об'єднує всі налаштування в один об'єкт для зручного управління.
///
/// Приклад створення:
/// ```dart
/// final config = EmptyStateConfig(
///   isLightTheme: true,
///   animate: true,
///   showIllustration: true,
/// );
/// ```
class EmptyStateConfig {
  /// Створює конфігурацію з усіма параметрами.
  const EmptyStateConfig({
    this.isLightTheme = false,
    this.animate = true,
    this.showIllustration = false,
    this.compact = false,
    this.iconSize = 64,
    this.animationDelay = Duration.zero,
  });

  /// Світла тема.
  final bool isLightTheme;

  /// Показувати анімацію появи.
  final bool animate;

  /// Показувати анімовану ілюстрацію.
  final bool showIllustration;

  /// Компактний режим.
  final bool compact;

  /// Розмір іконки.
  final double iconSize;

  /// Затримка анімації.
  final Duration animationDelay;

  /// Створює копію конфігурації з перевизначенням.
  EmptyStateConfig copyWith({
    bool? isLightTheme,
    bool? animate,
    bool? showIllustration,
    bool? compact,
    double? iconSize,
    Duration? animationDelay,
  }) {
    return EmptyStateConfig(
      isLightTheme: isLightTheme ?? this.isLightTheme,
      animate: animate ?? this.animate,
      showIllustration: showIllustration ?? this.showIllustration,
      compact: compact ?? this.compact,
      iconSize: iconSize ?? this.iconSize,
      animationDelay: animationDelay ?? this.animationDelay,
    );
  }

  /// Повертає кольори для вказаної теми.
  EmptyStateColors colors() {
    return isLightTheme
        ? EmptyStateColors.monitor()
        : EmptyStateColors.ps5();
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Кольори пустого стану (Empty State Colors)
// ═══════════════════════════════════════════════════════════════════════════

/// Клас кольорів для пустого стану.
///
/// Об'єднує всі кольори в один об'єкт для зручного доступу.
class EmptyStateColors {
  /// Створює кольори для темної теми PS5.
  const EmptyStateColors.ps5({
    this.background = const Color(0xFF0A0A12),
    this.card = const Color(0xFF16161E),
    this.textPrimary = const Color(0xFFFFFFFF),
    this.textSecondary = const Color(0xFF9E9EB0),
    this.textHint = const Color(0xFF6B6B80),
    this.accent = const Color(0xFF00D1FF),
    this.iconBg = Color(0x1A00D1FF),
    this.buttonPrimary = const Color(0xFF00D1FF),
    this.buttonText = const Color(0xFFFFFFFF),
  });

  /// Створює кольори для світлої теми Monitor.
  const EmptyStateColors.monitor({
    this.background = const Color(0xFFF5F5FA),
    this.card = const Color(0xFFFFFFFF),
    this.textPrimary = const Color(0xFF1A1A2E),
    this.textSecondary = const Color(0xFF6B7280),
    this.textHint = const(0xFF9CA3AF),
    this.accent = const Color(0xFF006FCD),
    this.iconBg = const Color(0x1A006FCD),
    this.buttonPrimary = const Color(0xFF006FCD),
    this.buttonText = const Color(0xFFFFFFFF),
  });

  /// Колір фону.
  final Color background;

  /// Колір картки.
  final Color card;

  /// Колір основного тексту.
  final Color textPrimary;

  /// Колір другорядного тексту.
  final Color textSecondary;

  /// Колір тексту підказки.
  final Color textHint;

  /// Колір-акцент.
  final Color accent;

  /// Колір фону іконки.
  final Color iconBg;

  /// Колір основної кнопки.
  final Color buttonPrimary;

  /// Колір тексту кнопки.
  final Color buttonText;
}

// ═══════════════════════════════════════════════════════════════════════════
// Предвизначені конфігурації (Preset Configurations)
// ═══════════════════════════════════════════════════════════════════════════

/// Передвизначені конфігурації для пустого стану.
///
/// Дозволяє швидко обрати потрібний стиль відображення.
class EmptyStateConfigs {
  EmptyStateConfigs._();

  /// Стандартна конфігурація для темної теми PS5.
  static const EmptyStateConfig ps5 = EmptyStateConfig(
    isLightTheme: false,
    animate: true,
  );

  /// Стандартна конфігурація для світлої теми Monitor.
  static const EmptyStateConfig monitor = EmptyStateConfig(
    isLightTheme: true,
    animate: true,
  );

  /// Конфігурація з анімованою ілюстрацією.
  static const EmptyStateConfig withIllustration = EmptyStateConfig(
    showIllustration: true,
  );

  /// Компактна конфігурація (для вбудовування у списки).
  static const EmptyStateConfig compact = EmptyStateConfig(
    compact: true,
    iconSize: 40,
  );

  /// Конфігурація без анімації (для миттєвого відображення).
  static const EmptyStateConfig instant = EmptyStateConfig(
    animate: false,
  );

  /// Конфігурація з великою іконкою (для порожніх сторінок).
  static const EmptyStateConfig large = EmptyStateConfig(
    iconSize: 96,
    showIllustration: true,
  );

  /// Конфігурація з затримкою анімації.
  static EmptyStateConfig withDelay(Duration delay) => EmptyStateConfig(
    animationDelay: delay,
  );
}

// ═══════════════════════════════════════════════════════════════════════════
// Розширення типів (Type Extensions)
// ═══════════════════════════════════════════════════════════════════════════

/// Розширення для [EmptyStateType] з додатковими властивостями.
extension EmptyStateTypeExtension on EmptyStateType {
  /// Чи тип має вторинну дію.
  bool get hasSecondaryAction => secondaryLabel != null;

  /// Чи тип має терциарну дію.
  bool get hasTertiaryAction => tertiaryLabel != null;

  /// Чи тип є помилкою (потрібен retry).
  bool get isError => this == EmptyStateType.error;

  /// Чи тип пов'язаний з мережею.
  bool get isNetworkRelated =>
      this == EmptyStateType.noInternet ||
      this == EmptyStateType.error;

  /// Чи тип пов'язаний з відсутністю контенту.
  bool get isContentEmpty =>
      this == EmptyStateType.noGoal ||
      this == EmptyStateType.noTransactions ||
      this == EmptyStateType.noChallenges ||
      this == EmptyStateType.noBadges ||
      this == EmptyStateType.noAchievements;

  /// Чи тип заблокований / незабаром.
  bool get isLockedOrComing =>
      this == EmptyStateType.comingSoon;

  /// Повертає повний опис типу для дебагу.
  String get debugDescription {
    return '$name (icon: ${icon.codePoint}, '
        'accent: ${accentColor.toARGB32()}, '
        'hasAction: ${actionLabel != null})';
  }

  /// Повертає JSON-подібне представлення типу.
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'title': title,
      'subtitle': subtitle,
      'emoji': emoji,
      'accentColor': accentColor.toARGB32(),
      'actionLabel': actionLabel,
      'secondaryLabel': secondaryLabel,
      'tertiaryLabel': tertiaryLabel,
      'illustrationType': illustrationType.name,
    };
  }
}

/// Розширення для [EmptyIllustrationType] з додатковими властивостями.
extension EmptyIllustrationTypeExtension on EmptyIllustrationType {
  /// Чи тип пов'язаний з помилкою.
  bool get isErrorType =>
      this == EmptyIllustrationType.error ||
      this == EmptyIllustrationType.offline;

  /// Чи тип пов'язаний з нагородами.
  bool get isRewardType =>
      this == EmptyIllustrationType.badge ||
      this == EmptyIllustrationType.achievement;

  /// Українська назва типу ілюстрації.
  String get localizedName {
    switch (this) {
      case EmptyIllustrationType.goal:
        return 'Ціль';
      case EmptyIllustrationType.transaction:
        return 'Транзакція';
      case EmptyIllustrationType.challenge:
        return 'Виклик';
      case EmptyIllustrationType.badge:
        return 'Бейдж';
      case EmptyIllustrationType.achievement:
        return 'Досягнення';
      case EmptyIllustrationType.offline:
        return 'Офлайн';
      case EmptyIllustrationType.error:
        return 'Помилка';
      case EmptyIllustrationType.search:
        return 'Пошук';
      case EmptyIllustrationType.locked:
        return 'Заблоковано';
    }
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Валідація (Validation)
// ═══════════════════════════════════════════════════════════════════════════

/// Валідатори для параметрів пустого стану.
///
/// Забезпечують безпечні значення для всіх конфігураційних параметрів.
class EmptyStateValidators {
  EmptyStateValidators._();

  /// Мінімальний розмір іконки.
  static const double minIconSize = 24.0;

  /// Максимальний розмір іконки.
  static const double maxIconSize = 200.0;

  /// Мінімальна ширина контейнера.
  static const double minContainerWidth = 100.0;

  /// Максимальна кількість кнопок дій.
  static const int maxActionButtons = 3;

  /// Максимальна довжина заголовка (символів).
  static const int maxTitleLength = 100;

  /// Максимальна довжина підзаголовка (символів).
  static const int maxSubtitleLength = 300;

  /// Валідує розмір іконки.
  ///
  /// Повертає значення в безпечному діапазоні.
  static double validateIconSize(double size) {
    return size.clamp(minIconSize, maxIconSize);
  }

  /// Валідує довжину заголовка.
  ///
  /// Повертає true якщо заголовок в межах допустимої довжини.
  static bool isValidTitle(String title) {
    return title.isNotEmpty && title.length <= maxTitleLength;
  }

  /// Валідує довжину підзаголовка.
  ///
  /// Повертає true якщо підзаголовок в межах допустимої довжини.
  static bool isValidSubtitle(String subtitle) {
    return subtitle.length <= maxSubtitleLength;
  }

  /// Валідує чи кількість кнопок дій в допустимих межах.
  static bool isValidActionCount({
    bool hasPrimary,
    bool hasSecondary,
    bool hasTertiary,
  }) {
    int count = 0;
    if (hasPrimary) count++;
    if (hasSecondary) count++;
    if (hasTertiary) count++;
    return count <= maxActionButtons;
  }

  /// Обрізає заголовок до максимально допустимої довжини.
  static String sanitizeTitle(String title) {
    if (title.length <= maxTitleLength) return title;
    return '${title.substring(0, maxTitleLength - 3)}...';
  }

  /// Обрізає підзаголовок до максимально допустимої довжини.
  static String sanitizeSubtitle(String subtitle) {
    if (subtitle.length <= maxSubtitleLength) return subtitle;
    return '${subtitle.substring(0, maxSubtitleLength - 3)}...';
  }

  /// Перевіряє чи тип пустого стану підтримує ілюстрацію.
  static bool supportsIllustration(EmptyStateType type) {
    return type.illustrationType != EmptyIllustrationType.error &&
        type.illustrationType != EmptyIllustrationType.offline;
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Тема-білдер (Empty State Theme Builder)
// ═══════════════════════════════════════════════════════════════════════════

/// Білдер теми для пустого стану.
///
/// Дозволяє створювати кастомні палітри кольорів
/// для різних типів пустого стану.
///
/// Приклад використання:
/// ```dart
/// final theme = EmptyStateThemeBuilder()
///   .withAccentColor(const Color(0xFFFF5722))
///   .withIconSize(80)
///   .build();
/// ```
class EmptyStateThemeBuilder {
  /// Створює білдер з початковими значеннями.
  EmptyStateThemeBuilder({
    this.accentColor,
    this.iconSize = 64,
    this.isLightTheme = false,
    this.showIllustration = false,
    this.compact = false,
  });

  /// Кастомний колір-акцент.
  final Color? accentColor;

  /// Розмір іконки.
  final double iconSize;

  /// Світла тема.
  final bool isLightTheme;

  /// Показувати ілюстрацію.
  final bool showIllustration;

  /// Компактний режим.
  final bool compact;

  /// Встановлює колір-акцент.
  EmptyStateThemeBuilder withAccentColor(Color color) {
    return EmptyStateThemeBuilder(
      accentColor: color,
      iconSize: iconSize,
      isLightTheme: isLightTheme,
      showIllustration: showIllustration,
      compact: compact,
    );
  }

  /// Встановлює розмір іконки.
  EmptyStateThemeBuilder withIconSize(double size) {
    return EmptyStateThemeBuilder(
      accentColor: accentColor,
      iconSize: EmptyStateValidators.validateIconSize(size),
      isLightTheme: isLightTheme,
      showIllustration: showIllustration,
      compact: compact,
    );
  }

  /// Встановлює тему.
  EmptyStateThemeBuilder withTheme(bool light) {
    return EmptyStateThemeBuilder(
      accentColor: accentColor,
      iconSize: iconSize,
      isLightTheme: light,
      showIllustration: showIllustration,
      compact: compact,
    );
  }

  /// Вмикає ілюстрацію.
  EmptyStateThemeBuilder withIllustration() {
    return EmptyStateThemeBuilder(
      accentColor: accentColor,
      iconSize: iconSize,
      isLightTheme: isLightTheme,
      showIllustration: true,
      compact: compact,
    );
  }

  /// Вмикає компактний режим.
  EmptyStateThemeBuilder withCompactMode() {
    return EmptyStateThemeBuilder(
      accentColor: accentColor,
      iconSize: 40,
      isLightTheme: isLightTheme,
      showIllustration: showIllustration,
      compact: true,
    );
  }

  /// Створює конфігурацію з поточними налаштуваннями.
  EmptyStateConfig build() {
    return EmptyStateConfig(
      isLightTheme: isLightTheme,
      showIllustration: showIllustration,
      compact: compact,
      iconSize: iconSize,
    );
  }

  /// Створює кольори для поточної конфігурації.
  EmptyStateColors buildColors() {
    return isLightTheme
        ? const EmptyStateColors.monitor()
        : const EmptyStateColors.ps5();
  }

  /// Створює конфігурацію для темної теми.
  EmptyStateConfig buildDark() => build()..copyWith(isLightTheme: false);

  /// Створює конфігурацію для світлої теми.
  EmptyStateConfig buildLight() => build()..copyWith(isLightTheme: true);

  @override
  String toString() =>
      'EmptyStateThemeBuilder(accentColor: $accentColor, '
      'iconSize: $iconSize, '
      'isLightTheme: $isLightTheme)';
}

// ═══════════════════════════════════════════════════════════════════════════
// Допоміжні будівельники (Utility Builders)
// ═══════════════════════════════════════════════════════════════════════════

/// Будівельники для поширених компонентів пустого стану.
///
/// Надає фабричні методи для створення специфічних варіантів
/// пустого стану з кастомізацією.
class EmptyStateBuilders {
  EmptyStateBuilders._();

  /// Будує пустий стан для списку транзакцій з фільтрами.
  static Widget transactionListEmpty({
    VoidCallback? onAdd,
    VoidCallback? onImport,
    VoidCallback? onClearFilters,
    bool isLightTheme = false,
  }) {
    return AppEmptyState(
      type: EmptyStateType.noTransactions,
      onAction: onAdd,
      onSecondaryAction: onImport,
      onTertiaryAction: onClearFilters,
      isLightTheme: isLightTheme,
      showIllustration: true,
    );
  }

  /// Будує пустий стан для екрана цілей з шаблонами.
  static Widget goalListEmpty({
    VoidCallback? onCreate,
    VoidCallback? onTemplates,
    VoidCallback? onTip,
    bool isLightTheme = false,
  }) {
    return AppEmptyState(
      type: EmptyStateType.noGoal,
      onAction: onCreate,
      onSecondaryAction: onTemplates,
      onTertiaryAction: onTip,
      isLightTheme: isLightTheme,
      showIllustration: true,
    );
  }

  /// Будує пустий стан для екрана гейміфікації.
  static Widget gamificationEmpty({
    VoidCallback? onBrowse,
    VoidCallback? onCompleted,
    VoidCallback? onCreate,
    bool isLightTheme = false,
  }) {
    return AppEmptyState(
      type: EmptyStateType.noChallenges,
      onAction: onBrowse,
      onSecondaryAction: onCompleted,
      onTertiaryAction: onCreate,
      isLightTheme: isLightTheme,
      showIllustration: true,
    );
  }

  /// Будує пустий стан для екрана пошуку без результатів.
  static Widget searchEmpty({
    VoidCallback? onClearFilters,
    String? customTitle,
    String? customSubtitle,
    bool isLightTheme = false,
  }) {
    return AppEmptyState(
      type: EmptyStateType.noSearchResults,
      title: customTitle,
      subtitle: customSubtitle,
      onAction: onClearFilters,
      isLightTheme: isLightTheme,
    );
  }

  /// Будує пустий стан для екрана помилки.
  static Widget errorState({
    VoidCallback? onRetry,
    VoidCallback? onSupport,
    String? customTitle,
    String? customSubtitle,
    bool isLightTheme = false,
  }) {
    return AppEmptyState(
      type: EmptyStateType.error,
      title: customTitle,
      subtitle: customSubtitle,
      onAction: onRetry,
      onSecondaryAction: onSupport,
      isLightTheme: isLightTheme,
    );
  }

  /// Будує пустий стан для відсутності інтернету.
  static Widget offlineState({
    VoidCallback? onRetry,
    bool isLightTheme = false,
  }) {
    return AppEmptyState(
      type: EmptyStateType.noInternet,
      onAction: onRetry,
      isLightTheme: isLightTheme,
    );
  }

  /// Будує пустий стан для coming soon / locked контенту.
  static Widget comingSoonState({
    VoidCallback? onLearnMore,
    String? customTitle,
    String? customSubtitle,
    bool isLightTheme = false,
  }) {
    return AppEmptyState(
      type: EmptyStateType.comingSoon,
      title: customTitle,
      subtitle: customSubtitle,
      onAction: onLearnMore,
      isLightTheme: isLightTheme,
    );
  }

  /// Будує компактний пустий стан для вбудовування у картки.
  static Widget embeddedMini({
    required String title,
    String? subtitle,
    IconData icon = Icons.inbox_outlined,
    VoidCallback? onAction,
    String? actionLabel,
    bool isLightTheme = false,
    Color? accentColor,
  }) {
    return AppEmptyStateMini(
      title: title,
      subtitle: subtitle,
      icon: icon,
      onAction: onAction,
      actionLabel: actionLabel,
      isLightTheme: isLightTheme,
      accentColor: accentColor,
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Валідатор пустого стану (Empty State Validator)
// ═══════════════════════════════════════════════════════════════════════════

/// Валідатор параметрів пустого стану.
///
/// Перевіряє коректність значень перед створенням віджета.
class EmptyStateValidator {
  EmptyStateValidator._();

  /// Перевіряє розмір іконки.
  static String? validateIconSize(double size) {
    if (size <= 0) return 'Розмір іконки повинен бути > 0';
    if (size > 200) return 'Розмір іконки занадто великий (макс: 200)';
    return null;
  }

  /// Перевіряє затримку анімації.
  static String? validateAnimationDelay(Duration delay) {
    if (delay.isNegative) return 'Затримка анімації не може бути від\'ємною';
    if (delay.inSeconds > 10) return 'Затримка занадто велика (макс: 10с)';
    return null;
  }

  /// Перевіряє наявність обох текстових полів (title + subtitle).
  static String? validateTextFields({
    String? title,
    String? subtitle,
    EmptyStateType? type,
  }) {
    final effectiveTitle = title ?? type?.title;
    if (effectiveTitle == null || effectiveTitle.isEmpty) {
      return 'Заголовок порожній';
    }
    return null;
  }

  /// Перевіряє відповідність кнопки та callback.
  static String? validateButtonAction({
    String? label,
    VoidCallback? action,
    String buttonName = 'основна',
  }) {
    if (label != null && label.isNotEmpty && action == null) {
      return '$buttonName кнопка має мітку "$label" але без callback';
    }
    if (label == null && action != null) {
      return '$buttonName кнопка має callback але без мітки';
    }
    return null;
  }

  /// Повна валідація всіх параметрів.
  static List<String> validateAll({
    double iconSize = 64,
    Duration animationDelay = Duration.zero,
    String? title,
    String? subtitle,
    String? actionLabel,
    VoidCallback? onAction,
    String? secondaryLabel,
    VoidCallback? onSecondaryAction,
    String? tertiaryLabel,
    VoidCallback? onTertiaryAction,
  }) {
    final errors = <String>[];
    final s = validateIconSize(iconSize);
    if (s != null) errors.add(s);
    final d = validateAnimationDelay(animationDelay);
    if (d != null) errors.add(d);
    final p = validateButtonAction(label: actionLabel, action: onAction, buttonName: 'Основна');
    if (p != null) errors.add(p);
    final p2 = validateButtonAction(label: secondaryLabel, action: onSecondaryAction, buttonName: 'Другорядна');
    if (p2 != null) errors.add(p2);
    final p3 = validateButtonAction(label: tertiaryLabel, action: onTertiaryAction, buttonName: 'Терциарна');
    if (p3 != null) errors.add(p3);
    return errors;
  }

  /// Швидка перевірка.
  static bool isValid({
    double iconSize = 64,
    String? title,
    String? actionLabel,
  }) {
    return validateIconSize(iconSize) == null &&
        (title != null || actionLabel != null);
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Метрики пустого стану (Empty State Metrics)
// ═══════════════════════════════════════════════════════════════════════════

/// Метрики для аналізу використання пустих станів.
///
/// Збирає статистику про те, які пусті стани найчастіше
/// відображаються користувачам.
class EmptyStateMetrics {
  EmptyStateMetrics._();

  static final EmptyStateMetrics instance = EmptyStateMetrics._();

  /// Карта: тип пустого стану → кількість відображень.
  final Map<EmptyStateType, int> _viewCounts = {};

  /// Загальна кількість відображень.
  int _totalViews = 0;

  /// Картка: тип → перший час відображення.
  final Map<EmptyStateType, DateTime> _firstSeen = {};

  /// Картка: тип → останній час відображення.
  final Map<EmptyStateType, DateTime> _lastSeen = {};

  /// Реєструє відображення пустого стану.
  void recordView(EmptyStateType type) {
    _viewCounts[type] = (_viewCounts[type] ?? 0) + 1;
    _totalViews++;
    final now = DateTime.now();
    _firstSeen.putIfAbsent(type, () => now);
    _lastSeen[type] = now;
  }

  /// Повертає кількість відображень для типу.
  int getViewCount(EmptyStateType type) => _viewCounts[type] ?? 0;

  /// Повертає загальну кількість відображень.
  int get totalViews => _totalViews;

  /// Повертає найчастіший пустий стан.
  EmptyStateType? get mostViewed {
    if (_viewCounts.isEmpty) return null;
    return _viewCounts.entries.reduce(
      (a, b) => a.value >= b.value ? a : b,
    ).key;
  }

  /// Повертає найменш частий пустий стан.
  EmptyStateType? get leastViewed {
    if (_viewCounts.isEmpty) return null;
    return _viewCounts.entries.reduce(
      (a, b) => a.value <= b.value ? a : b,
    ).key;
  }

  /// Повертає топ-3 найчастіших пустих станів.
  List<MapEntry<EmptyStateType, int>> get top3 {
    final sorted = _viewCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sorted.take(3).toList();
  }

  /// Чи тип коли-небудь відображався.
  bool wasSeen(EmptyStateType type) => _viewCounts.containsKey(type);

  /// Скидає всю статистику.
  void reset() {
    _viewCounts.clear();
    _totalViews = 0;
    _firstSeen.clear();
    _lastSeen.clear();
  }

  /// Генерує текстовий звіт.
  String generateReport() {
    final buffer = StringBuffer();
    buffer.writeln('📊 Звіт пустих станів:');
    buffer.writeln('  Загальних відображень: $_totalViews');
    if (_viewCounts.isNotEmpty) {
      buffer.writeln('  По типах:');
      for (final entry in _viewCounts.entries) {
        buffer.writeln('    ${entry.key.name}: ${entry.value}');
      }
      if (mostViewed != null) {
        buffer.writeln('  Найчастіший: ${mostViewed!.name}');
      }
    }
    return buffer.toString();
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Провайдер теми пустого стану (Empty State Theme Provider)
// ═══════════════════════════════════════════════════════════════════════════

/// Провайдер кольорів та стилів для пустого стану.
///
/// Централізує доступ до кольорів залежно від теми.
class EmptyStateThemeProvider {
  EmptyStateThemeProvider({required this.isLightTheme});

  /// Світла тема.
  final bool isLightTheme;

  /// Повертає кольори для поточної теми.
  EmptyStateColors get colors => EmptyStateConfig(
        isLightTheme: isLightTheme,
      ).colors();

  /// Колір фону.
  Color get background => colors.background;

  /// Колір картки.
  Color get card => colors.card;

  /// Колір основного тексту.
  Color get textPrimary => colors.textPrimary;

  /// Колір другорядного тексту.
  Color get textSecondary => colors.textSecondary;

  /// Колір підказки.
  Color get textHint => colors.textHint;

  /// Колір-акцент.
  Color get accent => colors.accent;

  /// Колір фону іконки.
  Color get iconBg => colors.iconBg;

  /// Колір основної кнопки.
  Color get buttonPrimary => colors.buttonPrimary;

  /// Колір тексту кнопки.
  Color get buttonText => colors.buttonText;

  /// Повертає колір іконки для типу пустого стану.
  Color iconColorForType(EmptyStateType type) => type.iconColor(isLightTheme);

  /// Повертає колір фону іконки для типу.
  Color iconBgForType(EmptyStateType type) => type.iconBgColor(isLightTheme);

  /// Створює BoxDecoration для контейнера іконки.
  BoxDecoration iconBoxDecoration(EmptyStateType type) {
    return BoxDecoration(
      color: iconBgForType(type),
      shape: BoxShape.circle,
    );
  }

  /// Створює BoxDecoration для картки пустого стану.
  BoxDecoration cardDecoration() {
    return BoxDecoration(
      color: card,
      borderRadius: BorderRadius.circular(Radii.md),
    );
  }

  /// Створює конфігурацію для AppEmptyState.
  EmptyStateConfig toConfig({
    bool animate = true,
    bool showIllustration = false,
    bool compact = false,
    double iconSize = 64,
    Duration animationDelay = Duration.zero,
  }) {
    return EmptyStateConfig(
      isLightTheme: isLightTheme,
      animate: animate,
      showIllustration: showIllustration,
      compact: compact,
      iconSize: iconSize,
      animationDelay: animationDelay,
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Конфігурація анімації пустого стану (Empty State Animation Config)
// ═══════════════════════════════════════════════════════════════════════════

/// Конфігурація анімації для пустого стану.
///
/// Дозволяє тонко налаштувати анімацію появи.
class EmptyStateAnimationConfig {
  const EmptyStateAnimationConfig({
    this.enableFadeIn = true,
    this.enableSlideUp = true,
    this.enableScale = false,
    this.fadeInDuration = const Duration(milliseconds: 400),
    this.slideUpOffset = 20.0,
    this.scaleFrom = 0.9,
    this.staggerDelay = const Duration(milliseconds: 80),
    this.curve = Curves.easeOutCubic,
  });

  /// Увімкнути fade-in ефект.
  final bool enableFadeIn;

  /// Увімкнути slide-up ефект.
  final bool enableSlideUp;

  /// Увімкнути scale ефект.
  final bool enableScale;

  /// Тривалість fade-in.
  final Duration fadeInDuration;

  /// Зміщення slide-up.
  final double slideUpOffset;

  /// Початковий масштаб.
  final double scaleFrom;

  /// Затримка між елементами.
  final Duration staggerDelay;

  /// Крива анімації.
  final Curve curve;

  /// Створює копію з перевизначенням.
  EmptyStateAnimationConfig copyWith({
    bool? enableFadeIn,
    bool? enableSlideUp,
    bool? enableScale,
    Duration? fadeInDuration,
    double? slideUpOffset,
    double? scaleFrom,
    Duration? staggerDelay,
    Curve? curve,
  }) {
    return EmptyStateAnimationConfig(
      enableFadeIn: enableFadeIn ?? this.enableFadeIn,
      enableSlideUp: enableSlideUp ?? this.enableSlideUp,
      enableScale: enableScale ?? this.enableScale,
      fadeInDuration: fadeInDuration ?? this.fadeInDuration,
      slideUpOffset: slideUpOffset ?? this.slideUpOffset,
      scaleFrom: scaleFrom ?? this.scaleFrom,
      staggerDelay: staggerDelay ?? this.staggerDelay,
      curve: curve ?? this.curve,
    );
  }

  /// Створює стандартну конфігурацію.
  static const EmptyStateAnimationConfig standard = EmptyStateAnimationConfig();

  /// Створює швидку конфігурацію.
  static const EmptyStateAnimationConfig fast = EmptyStateAnimationConfig(
    fadeInDuration: Duration(milliseconds: 200),
    slideUpOffset: 10.0,
  );

  /// Створює повільну конфігурацію.
  static const EmptyStateAnimationConfig slow = EmptyStateAnimationConfig(
    fadeInDuration: Duration(milliseconds: 800),
    slideUpOffset: 30.0,
    enableScale: true,
    scaleFrom: 0.85,
    curve: Curves.easeOutBack,
  );

  /// Створює мінімалістичну конфігурацію.
  static const EmptyStateAnimationConfig minimal = EmptyStateAnimationConfig(
    enableFadeIn: true,
    enableSlideUp: false,
    enableScale: false,
  );
}
