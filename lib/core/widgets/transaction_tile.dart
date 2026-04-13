import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_typography.dart';
import '../constants/app_spacing.dart';
import '../constants/app_radii.dart';
import '../constants/app_enums.dart';
import '../extensions/number_format_ext.dart';

import 'app_xp_badge.dart';

// ═══════════════════════════════════════════════════════════════════════════
// Debug Configuration (Налаштування налагодження)
// ═══════════════════════════════════════════════════════════════════════════

/// Налаштування налагодження для [TransactionTile].
class TransactionTileDebugConfig {
  TransactionTileDebugConfig._();

  /// Увімкнути вивід debug-повідомлень.
  static bool enableLogging = false;

  /// Показувати рамки навколо секцій.
  static bool showSectionBounds = false;

  static void log(String message, {String? tag}) {
    if (!enableLogging) return;
    final prefix = tag != null ? '[TransactionTile:$tag] ' : '[TransactionTile] ';
    debugPrint('$prefix$message');
  }
}

// ─── Transaction Display Type ───────────────────────────────────────────────

/// Візуальний тип транзакції для відображення (deposit/withdrawal/bonus).
enum TransactionDirection {
  deposit,

  withdrawal,

  bonus;

  /// Українська назва типу транзакції.
  String get label {
    switch (this) {
      case TransactionDirection.deposit:
        return 'Внесення';
      case TransactionDirection.withdrawal:
        return 'Зняття';
      case TransactionDirection.bonus:
        return 'Бонус';
    }
  }

  /// Опис для accessibility.
  String get accessibilityDescription {
    switch (this) {
      case TransactionDirection.deposit:
        return 'Внесення коштів';
      case TransactionDirection.withdrawal:
        return 'Зняття коштів';
      case TransactionDirection.bonus:
        return 'Бонус';
    }
  }

  /// Кольор-префікс для суми.
  String get amountPrefix {
    switch (this) {
      case TransactionDirection.deposit:
        return '+';
      case TransactionDirection.withdrawal:
        return '-';
      case TransactionDirection.bonus:
        return '+';
    }
  }
}

// ─── Tile Style ───────────────────────────────────────────────────────────

/// Візуальний стиль плитки транзакції.
enum TransactionTileStyle {
  /// Компактний — лише іконка, назва та сума.
  compact,

  /// Стандартний — з повною інформацією та XP.
  standard,

  /// Детальний — з розгорнутими деталями за замовчуванням.
  detailed;
}

// ═══════════════════════════════════════════════════════════════════════════
// Tile Animation Config (Конфігурація анімацій)
// ═══════════════════════════════════════════════════════════════════════════

/// Конфігурація анімацій для [TransactionTile].
class TransactionTileAnimationConfig {
  const TransactionTileAnimationConfig({
    this.expandDuration = const Duration(milliseconds: 200),
    this.shimmerDuration = const Duration(milliseconds: 1200),
    this.fadeInDuration = const Duration(milliseconds: 150),
    this.shakeDuration = AppDurations.medium,
    this.shakeOffset = 4.0,
  });

  /// Тривалість розгортання деталей.
  final Duration expandDuration;

  /// Тривалість shimmer-ефекту.
  final Duration shimmerDuration;

  /// Тривалість появи.
  final Duration fadeInDuration;

  /// Тривалість тряски для error.
  final Duration shakeDuration;

  /// Амплітуда тряски.
  final double shakeOffset;

  /// Стандартна конфігурація.
  static const TransactionTileAnimationConfig standard = TransactionTileAnimationConfig();
}

/// Плитка транзакції у списку останніх операцій.
///
/// Підтримує:
/// - Типи транзакцій з різними іконками та кольорами
/// - Свайп-дії (редагувати, видалити, поширити)
/// - Long press для деталей та контекстного меню
/// - Бейдж XP та «Перший внесок»
/// - Індикатор авто-платежу та виклику
/// - Роздільник дат з групуванням
/// - Компактний/стандартний/детальний режими
/// - Підсвіткування пошукового терміну
/// - Стан транзакції (очікується/в обробці)
/// - Іконку вкладення
/// - Анімаційні пресети
class TransactionTile extends StatefulWidget {
  const TransactionTile({
    super.key,
    required this.direction,
    required this.type,
    required this.amount,
    required this.date,
    this.comment,
    this.xp,
    this.isLightTheme = false,
    this.onTap,
    this.onLongPress,
    this.isFirstDeposit = false,
    this.isAutoPayment = false,
    this.isChallenge = false,
    this.compact = false,
    this.showDetails = false,
    this.onSwipeDelete,
    this.onSwipeUndo,
    this.challengeName,
    this.autoPaymentFrequency,
    this.tileStyle = TransactionTileStyle.standard,
    this.searchQuery,
    this.hasAttachment = false,
    this.isProcessing = false,
    this.statusMessage,
    this.animationConfig = const TransactionTileAnimationConfig.standard,
    this.semanticLabel,
  });

  /// Створює компактну плитку для списків.
  TransactionTile.minimal({
    super.key,
    required this.direction,
    required this.type,
    required this.amount,
    required this.date,
    this.comment,
    this.isLightTheme = false,
    this.onTap,
  })  : xp = null,
        isFirstDeposit = false,
        isAutoPayment = false,
        isChallenge = false,
        compact = true,
        showDetails = false,
        onSwipeDelete = null,
        onSwipeUndo = null,
        onLongPress = null,
        challengeName = null,
        autoPaymentFrequency = null,
        tileStyle = TransactionTileStyle.compact,
        searchQuery = null,
        hasAttachment = false,
        isProcessing = false,
        statusMessage = null,
        animationConfig = const TransactionTileAnimationConfig.standard,
        semanticLabel = null;

  /// Створює плитку з деталізацією за замовчуванням.
  TransactionTile.expanded({
    super.key,
    required this.direction,
    required this.type,
    required this.amount,
    required this.date,
    this.comment,
    this.xp,
    this.isLightTheme = false,
    this.onTap,
    this.onLongPress,
    this.isFirstDeposit = false,
    this.isAutoPayment = false,
    this.isChallenge = false,
    this.onSwipeDelete,
    this.onSwipeUndo,
    this.challengeName,
    this.autoPaymentFrequency,
    this.tileStyle = TransactionTileStyle.detailed,
    this.searchQuery,
    this.hasAttachment = false,
    this.isProcessing = false,
    this.statusMessage,
    this.semanticLabel,
  })  : showDetails = true,
        compact = false,
        animationConfig = const TransactionTileAnimationConfig.standard;

  /// Створює плитку для трансакції, що обробляється.
  TransactionTile.processing({
    super.key,
    required this.direction,
    required this.type,
    required this.amount,
    required this.date,
    this.comment,
    this.isLightTheme = false,
    this.statusMessage = 'Обробляється…',
  })  : xp = null,
        isFirstDeposit = false,
        isAutoPayment = false,
        isChallenge = false,
        compact = false,
        showDetails = false,
        onSwipeDelete = null,
        onSwipeUndo = null,
        onLongPress = null,
        onTap = null,
        challengeName = null,
        autoPaymentFrequency = null,
        tileStyle = TransactionTileStyle.standard,
        searchQuery = null,
        hasAttachment = false,
        isProcessing = true,
        animationConfig = const TransactionTileAnimationConfig.standard,
        semanticLabel = null;

  final TransactionDirection direction;
  final TransactionType type;
  final double amount;
  final DateTime date;
  final String? comment;
  final int? xp;
  final bool isLightTheme;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool isFirstDeposit;
  final bool isAutoPayment;
  final bool isChallenge;
  final bool compact;
  final bool showDetails;
  final VoidCallback? onSwipeDelete;
  final VoidCallback? onSwipeUndo;
  final String? challengeName;
  final String? autoPaymentFrequency;
  final TransactionTileStyle tileStyle;
  final String? searchQuery;
  final bool hasAttachment;
  final bool isProcessing;
  final String? statusMessage;
  final TransactionTileAnimationConfig animationConfig;
  final String? semanticLabel;

  @override
  State<TransactionTile> createState() => _TransactionTileState();
}

class _TransactionTileState extends State<TransactionTile> {
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.showDetails || widget.tileStyle == TransactionTileStyle.detailed;
    TransactionTileDebugConfig.log('initState', tag: 'lifecycle');
  }

  @override
  void didUpdateWidget(covariant TransactionTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.showDetails != widget.showDetails) {
      _isExpanded = widget.showDetails || widget.tileStyle == TransactionTileStyle.detailed;
    }
  }

  // ─── Іконки та кольори ────────────────────────────────────────────────

  /// Іконка типу транзакції.
  IconData get _typeIcon {
    switch (widget.type) {
      case TransactionType.manual:
        return Icons.edit_rounded;
      case TransactionType.roundUp:
        return Icons.sync_rounded;
      case TransactionType.autoPayment:
        return Icons.credit_card_rounded;
      case TransactionType.challenge:
        return Icons.emoji_events_rounded;
      case TransactionType.dailyLogin:
        return Icons.calendar_today_rounded;
      case TransactionType.microGoal:
        return Icons.check_circle_rounded;
      case TransactionType.returnBonus:
        return Icons.card_giftcard_rounded;
    }
  }

  /// Колір іконки типу.
  Color get _typeIconColor {
    switch (widget.type) {
      case TransactionType.manual:
        return AppColorsPS5.accent;
      case TransactionType.roundUp:
        return AppColorsPS5.accentLight;
      case TransactionType.autoPayment:
        return AppColorsPS5.coin;
      case TransactionType.challenge:
        return AppColorsPS5.xp;
      case TransactionType.dailyLogin:
        return AppColorsPS5.success;
      case TransactionType.microGoal:
        return AppColorsPS5.success;
      case TransactionType.returnBonus:
        return AppColorsPS5.warning;
    }
  }

  /// Колір суми залежно від напрямку.
  Color get _amountColor {
    switch (widget.direction) {
      case TransactionDirection.deposit:
        return AppColorsPS5.success;
      case TransactionDirection.withdrawal:
        return AppColorsPS5.error;
      case TransactionDirection.bonus:
        return AppColorsPS5.success;
    }
  }

  /// Короткий опис типу транзакції.
  String get _typeLabel => widget.direction.label;

  /// Назва джерела транзакції.
  String get _sourceLabel => widget.type.label;

  // ─── Кольори ──────────────────────────────────────────────────────────

  Color get _cardColor => widget.isLightTheme
      ? AppColorsMonitor.card : AppColorsPS5.card;

  Color get _titleColor => widget.isLightTheme
      ? AppColorsMonitor.textPrimary : AppColorsPS5.textPrimary;

  Color get _subtitleColor => widget.isLightTheme
      ? AppColorsMonitor.textSecondary : AppColorsPS5.textSecondary;

  Color get _hintColor => widget.isLightTheme
      ? AppColorsMonitor.textHint : AppColorsPS5.textHint;

  Color get _borderColor => widget.isLightTheme
      ? AppColorsMonitor.border : AppColorsPS5.border;

  // ─── Форматування ─────────────────────────────────────────────────────

  /// Форматує дату та час коротко: "15.01 14:30".
  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$day.$month $hour:$minute';
  }

  /// Форматує дату повністю з назвою місяця.
  String _formatFullDate(DateTime date) {
    final months = [
      'січня', 'лютого', 'березня', 'квітня', 'травня', 'червня',
      'липня', 'серпня', 'вересня', 'жовтня', 'листопада', 'грудня',
    ];
    final day = date.day.toString().padLeft(2, '0');
    final month = months[date.month - 1];
    final year = date.year.toString();
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$day $month $year, $hour:$minute';
  }

  /// Форматує відносну дату (сьогодні, вчора, інше).
  String _formatRelativeDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final targetDate = DateTime(date.year, date.month, date.day);

    if (targetDate == today) return 'Сьогодні о ${_formatTime(date)}';
    if (targetDate == yesterday) return 'Вчора о ${_formatTime(date)}';
    return _formatDate(date);
  }

  /// Форматує тільки час.
  String _formatTime(DateTime date) {
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  /// Будує TextSpan з підсвіткою пошукового терміну.
  TextSpan _buildHighlightedText(String text) {
    if (widget.searchQuery == null || widget.searchQuery!.isEmpty) {
      return TextSpan(
        text: text,
        style: AppTypography.bodyMedium.copyWith(
          color: _titleColor,
          fontWeight: FontWeight.w500,
        ),
      );
    }
    final query = widget.searchQuery!.toLowerCase();
    final lowerText = text.toLowerCase();
    final index = lowerText.indexOf(query);
    if (index < 0) {
      return TextSpan(
        text: text,
        style: AppTypography.bodyMedium.copyWith(
          color: _titleColor,
          fontWeight: FontWeight.w500,
        ),
      );
    }
    return TextSpan(children: [
      TextSpan(
        text: text.substring(0, index),
        style: AppTypography.bodyMedium.copyWith(
          color: _titleColor,
          fontWeight: FontWeight.w500,
        ),
      ),
      TextSpan(
        text: text.substring(index, index + query.length),
        style: AppTypography.bodyMedium.copyWith(
          color: AppColorsPS5.accent,
          fontWeight: FontWeight.w700,
          backgroundColor: AppColorsPS5.accent.withOpacity(0.15),
        ),
      ),
      TextSpan(
        text: text.substring(index + query.length),
        style: AppTypography.bodyMedium.copyWith(
          color: _titleColor,
          fontWeight: FontWeight.w500,
        ),
      ),
    ]);
  }

  /// Обчислює опис транзакції для accessibility.
  String get _accessibilityDescription {
    final prefix = widget.direction.amountPrefix;
    final formattedAmount = widget.amount.formatUAH();
    return '$prefix$formattedAmount грн — ${widget.comment ?? _typeLabel}';
  }

  // ─── Build ────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    if (widget.tileStyle == TransactionTileStyle.compact || widget.compact) {
      return _buildCompactTile();
    }

    Widget tile = GestureDetector(
      onTap: widget.onTap ?? _toggleDetails,
      onLongPress: widget.onLongPress ?? _showContextMenu,
      child: AnimatedContainer(
        duration: widget.animationConfig.expandDuration,
        padding: const EdgeInsets.symmetric(
          horizontal: Spacing.base,
          vertical: Spacing.md,
        ),
        decoration: BoxDecoration(
          color: _cardColor,
          borderRadius: BorderRadius.circular(Radii.md),
          border: _isExpanded
              ? Border.all(color: _borderColor, width: 1)
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildMainRow(),
            // Розширені деталі
            if (_isExpanded) ...[
              const SizedBox(height: Spacing.md),
              _buildDetails(),
            ],
          ],
        ),
      ),
    );

    // Fade in анімація
    tile = tile.animate().fadeIn(
      duration: widget.animationConfig.fadeInDuration,
    );

    // Semantics
    tile = Semantics(
      button: widget.onTap != null,
      label: widget.semanticLabel ?? _accessibilityDescription,
      child: tile,
    );

    return tile;
  }

  /// Контекстне меню при довгому натисканні.
  void _showContextMenu() {
    HapticService.lightTap();
    TransactionTileDebugConfig.log('Context menu shown', tag: 'interaction');

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        margin: const EdgeInsets.all(Spacing.base),
        padding: const EdgeInsets.symmetric(vertical: Spacing.base),
        decoration: BoxDecoration(
          color: widget.isLightTheme ? AppColorsMonitor.card : AppColorsPS5.card,
          borderRadius: BorderRadius.circular(Radii.xl),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit_rounded, color: AppColorsPS5.accent, size: 20),
              title: Text('Редагувати', style: AppTypography.bodyMedium.copyWith(color: _titleColor)),
              onTap: () { Navigator.pop(ctx); },
            ),
            ListTile(
              leading: const Icon(Icons.share_rounded, color: AppColorsPS5.accent, size: 20),
              title: Text('Поділитися', style: AppTypography.bodyMedium.copyWith(color: _titleColor)),
              onTap: () { Navigator.pop(ctx); },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline_rounded, color: AppColorsPS5.error, size: 20),
              title: Text('Видалити', style: AppTypography.bodyMedium.copyWith(color: AppColorsPS5.error)),
              onTap: () {
                Navigator.pop(ctx);
                widget.onSwipeDelete?.call();
              },
            ),
            ListTile(
              leading: const Icon(Icons.content_copy_rounded, color: AppColorsPS5.accentLight, size: 20),
              title: Text('Копіювати суму', style: AppTypography.bodyMedium.copyWith(color: _titleColor)),
              onTap: () {
                Navigator.pop(ctx);
                Clipboard.setData(ClipboardData(text: widget.amount.toString()));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Суму скопійовано!'),
                    duration: Duration(seconds: 1),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Основний рядок плитки.
  Widget _buildMainRow() {
    return Row(
      children: [
        // Іконка типу
        _buildTypeIcon(),
        const SizedBox(width: Spacing.md),

        // Текстова інформація
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Рядок: назва + індикатори
              _buildTitleRow(),
              const SizedBox(height: 2),
              // Рядок: дата + джерело
              _buildSubtitleRow(),
            ],
          ),
        ),
        const SizedBox(width: Spacing.sm),

        // Сума + XP + Бейджі
        _buildAmountSection(),
      ],
    );
  }

  /// Будує іконку типу транзакції з індикаторами стану.
  Widget _buildTypeIcon() {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: _typeIconColor.withOpacity(0.12),
        borderRadius: BorderRadius.circular(Radii.sm),
      ),
      child: Stack(
        children: [
          Center(child: Icon(_typeIcon, color: _typeIconColor, size: 20)),
          // Індикатор обробки
          if (widget.isProcessing)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(Radii.sm),
                ),
                child: const Center(
                  child: SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          // Індикатор статусу
          if (widget.statusMessage != null)
            Positioned(
              bottom: -2,
              right: -2,
              child: Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: AppColorsPS5.warning,
                  shape: BoxShape.circle,
                  border: Border.all(color: _cardColor, width: 2),
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// Будує рядок заголовка з назвою та бейджами.
  Widget _buildTitleRow() {
    return Row(
      children: [
        Flexible(
          child: Text(
            widget.comment ?? _typeLabel,
            style: AppTypography.bodyMedium.copyWith(
              color: _titleColor,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        // Індикатор авто-платежу
        if (widget.isAutoPayment) ...[
          const SizedBox(width: 4),
          _buildBadgeChip(
            emoji: '💳',
            bgColor: AppColorsPS5.coin,
          ),
        ],
        // Індикатор виклику
        if (widget.isChallenge) ...[
          const SizedBox(width: 4),
          _buildBadgeChip(
            emoji: '🏆',
            bgColor: AppColorsPS5.xp,
          ),
        ],
        // Індикатор вкладення
        if (widget.hasAttachment) ...[
          const SizedBox(width: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: AppColorsPS5.accentLight.withOpacity(0.12),
              borderRadius: BorderRadius.circular(Radii.xs),
            ),
            child: const Icon(
              Icons.attach_file_rounded,
              color: AppColorsPS5.accentLight,
              size: 12,
            ),
          ),
        ],
      ],
    );
  }

  /// Будує бейдж-чип з емодзі.
  Widget _buildBadgeChip({required String emoji, required Color bgColor}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: bgColor.withOpacity(0.12),
        borderRadius: BorderRadius.circular(Radii.xs),
      ),
      child: Text(emoji, style: const TextStyle(fontSize: 10)),
    );
  }

  /// Будує рядок підзаголовка з датою та джерелом.
  Widget _buildSubtitleRow() {
    return Row(
      children: [
        Text(
          _formatDate(widget.date),
          style: AppTypography.labelSmall.copyWith(
            color: _subtitleColor,
          ),
        ),
        if (!widget.compact) ...[
          const SizedBox(width: 6),
          Text(
            '·',
            style: AppTypography.labelSmall.copyWith(
              color: _hintColor,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            _sourceLabel,
            style: AppTypography.labelSmall.copyWith(
              color: _hintColor,
            ),
          ),
        ],
        // Статус обробки
        if (widget.isProcessing)
          const Padding(
            padding: EdgeInsets.only(left: 6),
            child: Icon(
              Icons.schedule_rounded,
              color: AppColorsPS5.warning,
              size: 12,
            ),
          ),
      ],
    );
  }

  /// Будує секцію з сумою, XP бейджем та бейджем першого внеску.
  Widget _buildAmountSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          '${widget.direction.amountPrefix}${widget.amount.formatUAH()} грн',
          style: AppTypography.monoSmall.copyWith(
            color: _amountColor,
            fontWeight: FontWeight.w600,
          ),
        ),
        // XP бейдж
        if (widget.xp != null && widget.xp! > 0) ...[
          const SizedBox(height: 2),
          AppXpBadge(
            xp: widget.xp!,
            isLightTheme: widget.isLightTheme,
            size: 28,
          ),
        ],
        // Бейдж "Перший внесок"
        if (widget.isFirstDeposit && widget.xp == null) ...[
          const SizedBox(height: 2),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: AppColorsPS5.success.withOpacity(0.12),
              borderRadius: BorderRadius.circular(Radii.xs),
            ),
            child: Text(
              '🌱 Перший',
              style: AppTypography.labelSmall.copyWith(
                color: AppColorsPS5.success,
                fontSize: 9,
              ),
            ),
          ),
        ],
        // Статус обробки
        if (widget.statusMessage != null) ...[
          const SizedBox(height: 2),
          Text(
            widget.statusMessage!,
            style: AppTypography.caption.copyWith(color: AppColorsPS5.warning),
          ),
        ],
      ],
    );
  }

  /// Розширені деталі транзакції.
  Widget _buildDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Divider(color: _borderColor, height: 1),
        const SizedBox(height: Spacing.sm),
        _buildDetailRow(label: 'Дата та час', value: _formatFullDate(widget.date)),
        _buildDetailRow(label: 'Джерело', value: _sourceLabel),
        _buildDetailRow(label: 'Тип', value: _typeLabel),
        _buildDetailRow(
          label: 'Сума',
          value: '${widget.direction.amountPrefix}${widget.amount.formatUAH()} грн',
          valueColor: _amountColor,
        ),
        if (widget.xp != null && widget.xp! > 0)
          _buildDetailRow(
            label: 'Отримано XP',
            value: '+${widget.xp} ⭐',
            valueColor: AppColorsPS5.xp,
          ),
        if (widget.isChallenge && widget.challengeName != null)
          _buildDetailRow(
            label: 'Виклик',
            value: widget.challengeName!,
          ),
        if (widget.isAutoPayment && widget.autoPaymentFrequency != null)
          _buildDetailRow(
            label: 'Частота',
            value: widget.autoPaymentFrequency!,
          ),
        if (widget.isFirstDeposit)
          _buildDetailRow(
            label: 'Досягнення',
            value: '🌱 Перший внесок',
            valueColor: AppColorsPS5.success,
          ),
        if (widget.hasAttachment)
          _buildDetailRow(
            label: 'Вкладення',
            value: '📎 Має вкладення',
            valueColor: AppColorsPS5.accentLight,
          ),
        // Додаткова інформація про час
        _buildDetailRow(
          label: 'Створено',
          value: _formatRelativeDate(widget.date),
          valueColor: _hintColor,
        ),
      ],
    );
  }

  /// Будує рядок детальної інформації.
  Widget _buildDetailRow({
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTypography.bodySmall.copyWith(color: _hintColor),
          ),
          Flexible(
            child: Text(
              value,
              style: AppTypography.bodyMedium.copyWith(
                color: valueColor ?? _titleColor,
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  /// Компактна плитка для списків.
  Widget _buildCompactTile() {
    return GestureDetector(
      onTap: widget.onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: Spacing.sm,
          vertical: 4,
        ),
        child: Row(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: _typeIconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(Radii.xs),
              ),
              child: Icon(_typeIcon, color: _typeIconColor, size: 14),
            ),
            const SizedBox(width: Spacing.sm),
            Expanded(
              child: Text(
                widget.comment ?? _typeLabel,
                style: AppTypography.bodySmall.copyWith(
                  color: _titleColor,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: Spacing.sm),
            Text(
              '${widget.direction.amountPrefix}${widget.amount.formatUAH()}',
              style: AppTypography.monoCaption.copyWith(
                color: _amountColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Перемикає стан розгортання.
  void _toggleDetails() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
    TransactionTileDebugConfig.log(
      'Details toggled: $_isExpanded',
      tag: 'interaction',
    );
  }
}

// ─── Date Separator ─────────────────────────────────────────────────────────

/// Роздільник дат для списку транзакцій.
class TransactionDateSeparator extends StatelessWidget {
  const TransactionDateSeparator({
    super.key,
    required this.date,
    this.isLightTheme = false,
    this.transactionCount = 0,
    this.totalAmount = 0,
    this.showTransactionSummary = true,
  });

  /// Дата для групування транзакцій.
  final DateTime date;

  /// Світла тема.
  final bool isLightTheme;

  /// Кількість транзакцій за цю дату.
  final int transactionCount;

  /// Загальна сума транзакцій за цю дату.
  final double totalAmount;

  /// Показувати підсумку транзакцій.
  final bool showTransactionSummary;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final targetDate = DateTime(date.year, date.month, date.day);

    String label;
    if (targetDate == today) {
      label = 'Сьогодні';
    } else if (targetDate == yesterday) {
      label = 'Вчора';
    } else {
      final day = date.day.toString().padLeft(2, '0');
      final month = date.month.toString().padLeft(2, '0');
      label = '$day.$month.${date.year}';
    }

    final months = [
      'січня', 'лютого', 'березня', 'квітня', 'травня', 'червня',
      'липня', 'серпня', 'вересня', 'жовтня', 'листопада', 'грудня',
    ];
    final fullLabel = targetDate == today || targetDate == yesterday
        ? label
        : '$day ${months[date.month - 1]} ${date.year}';

    final textColor = isLightTheme
        ? AppColorsMonitor.textHint
        : AppColorsPS5.textHint;
    final borderColor = isLightTheme
        ? AppColorsMonitor.border
        : AppColorsPS5.border;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.base,
        vertical: Spacing.sm,
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                fullLabel,
                style: AppTypography.labelMedium.copyWith(
                  color: textColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: Spacing.sm),
              Expanded(child: Divider(color: borderColor, height: 1)),
              if (showTransactionSummary && transactionCount > 0) ...[
                Text(
                  '$transactionCount ${transactionCount.pluralUAH("транзакція", "транзакції", "транзакцій")}',
                  style: AppTypography.labelSmall.copyWith(color: textColor),
                ),
              ],
              if (showTransactionSummary && totalAmount > 0)
                Text(
                  '${totalAmount.toInt().formatUAH()} грн',
                  style: AppTypography.labelSmall.copyWith(color: textColor),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Utility Extensions (Утиліти-розширення)
// ═══════════════════════════════════════════════════════════════════════════

/// Розширення для [TransactionTileStyle] з додатковими методами.
extension TransactionTileStyleExtension on TransactionTileStyle {
  /// Опис стилю для налаштувань.
  String get description {
    switch (this) {
      case TransactionTileStyle.compact:
        return 'Компактний — лише іконка, назва та сума';
      case TransactionTileStyle.standard:
        return 'Стандартний — з повною інформацією та XP';
      case TransactionTileStyle.detailed:
        return 'Детальний — з розгорнутими деталями';
    }
  }

  /// Чи стиль показує деталі за замовчуванням.
  bool get showsDetailsByDefault => this == TransactionTileStyle.detailed;
}

/// Розширення для [TransactionDirection] з додатковими методами.
extension TransactionDirectionExtension on TransactionDirection {
  /// Обернений тип для використання в UI.
  String get emoji {
    switch (this) {
      case TransactionDirection.deposit:
        return '📥';
      case TransactionDirection.withdrawal:
        return '📤';
      case TransactionDirection.bonus:
        return '🎁';
    }
  }

  /// Чи є позитивний напрямок (отримання коштів).
  bool get isPositive => this == TransactionDirection.deposit || this == TransactionDirection.bonus;
}

/// Розширення для [TransactionType] з додатковими методами.
extension TransactionTypeExtension on TransactionType {
  /// Опис типу для користувацького інтерфейсу.
  String get description {
    switch (this) {
      case TransactionType.manual:
        return 'Вручну створена';
      case TransactionType.roundUp:
        return 'Залишок з покупок';
      case TransactionType.autoPayment:
        return 'Автоматичний платіж';
      case TransactionType.challenge:
        return 'Отримано з виклику';
      case TransactionType.dailyLogin:
        return 'Щоденний вхід';
      case TransactionType.microGoal:
        return 'Мікроціль';
      case TransactionType.returnBonus:
        return 'Кешбек бонус';
    }
  }

  /// Колір типу за замовчуванням.
  Color get defaultColor {
    switch (this) {
      case TransactionType.manual:
        return AppColorsPS5.accent;
      case TransactionType.roundUp:
        return AppColorsPS5.accentLight;
      case TransactionType.autoPayment:
        return AppColorsPS5.coin;
      case TransactionType.challenge:
        return AppColorsPS5.xp;
      case TransactionType.dailyLogin:
        return AppColorsPS5.success;
      case TransactionType.microGoal:
        return AppColorsPS5.success;
      case TransactionType.returnBonus:
        return AppColorsPS5.warning;
    }
  }

  /// Іконка типу за замовчуванням.
  IconData get defaultIcon {
    switch (this) {
      case TransactionType.manual:
        return Icons.edit_rounded;
      case TransactionType.roundUp:
        return Icons.sync_rounded;
      case TransactionType.autoPayment:
        return Icons.credit_card_rounded;
      case TransactionType.challenge:
        return Icons.emoji_events_rounded;
      case TransactionType.dailyLogin:
        return Icons.calendar_today_rounded;
      case TransactionType.microGoal:
        return Icons.check_circle_rounded;
      case TransactionType.returnBonus:
        return Icons.card_giftcard_rounded;
    }
  }

  /// Чи тип транзакції підтримує автоматичне повторення.
  bool get isRecurring =>
      this == TransactionType.autoPayment || this == TransactionType.dailyLogin;

  /// Чи тип транзакції пов'язаний з гейміфікацією.
  bool get isGamification =>
      this == TransactionType.challenge ||
      this == TransactionType.dailyLogin ||
      this == TransactionType.microGoal;

  /// Чи тип транзакції генерується автоматично.
  bool get isAutomatic =>
      this == TransactionType.roundUp ||
      this == TransactionType.autoPayment ||
      this == TransactionType.dailyLogin;

  /// Пріоритет сортування (нижче = вище в списку).
  ///
  /// Оброблювані транзакції мають найвищий пріоритет.
  int get sortPriority {
    switch (this) {
      case TransactionType.manual:
        return 0;
      case TransactionType.roundUp:
        return 1;
      case TransactionType.autoPayment:
        return 2;
      case TransactionType.challenge:
        return 3;
      case TransactionType.dailyLogin:
        return 4;
      case TransactionType.microGoal:
        return 5;
      case TransactionType.returnBonus:
        return 6;
    }
  }

  /// Анімаційний тип для цього типу транзакції.
  ///
  /// Повертає строковий ідентифікатор для Hero анімації.
  String get heroTag => 'transaction_type_$name';

  /// Назва для групування в статистиці.
  String get groupLabel {
    switch (this) {
      case TransactionType.manual:
        return 'Вручну';
      case TransactionType.roundUp:
        return 'Залишки';
      case TransactionType.autoPayment:
        return 'Автоплатежі';
      case TransactionType.challenge:
        return 'Виклики';
      case TransactionType.dailyLogin:
        return 'Входи';
      case TransactionType.microGoal:
        return 'Цілі';
      case TransactionType.returnBonus:
        return 'Бонуси';
    }
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Transaction Tile Constants (Константи)
// ═══════════════════════════════════════════════════════════════════════════

/// Константи для налаштування плиток транзакцій.
///
/// Містить стандартні значення для розмірів, анімацій, відступів
/// та інших параметрів, що використовуються у [TransactionTile].
class TransactionTileConstants {
  TransactionTileConstants._();

  /// Стандартна ширина іконки типу.
  static const double typeIconSize = 40.0;

  /// Розмір іконки всередині контейнера типу.
  static const double typeIconInnerSize = 20.0;

  /// Ширина іконки типу в компактному режимі.
  static const double compactIconSize = 28.0;

  /// Розмір іконки в компактному режимі.
  static const double compactIconInnerSize = 14.0;

  /// Стандартний розмір бейджу XP.
  static const double defaultXpBadgeSize = 28.0;

  /// Стандартний розмір індикатора статусу.
  static const double statusIndicatorSize = 10.0;

  /// Стандартний розмір індикатора обробки.
  static const double processingIndicatorSize = 16.0;

  /// Товщина індикатора обробки.
  static const double processingIndicatorStrokeWidth = 2.0;

  /// Ширина рамки індикатора статусу.
  static const double statusIndicatorBorderWidth = 2.0;

  /// Стандартний вертикальний відступ між рядками деталей.
  static const double detailRowVerticalPadding = 3.0;

  /// Непрозорість фону іконки типу (стандартний).
  static const double typeIconBackgroundOpacity = 0.12;

  /// Непрозорість фону іконки типу (компактний).
  static const double compactIconBackgroundOpacity = 0.1;

  /// Непрозорість підсвітки пошукового терміну.
  static const double searchHighlightOpacity = 0.15;

  /// Непрозорість overlay для індикатора обробки.
  static const double processingOverlayOpacity = 0.3;

  /// Непрозорість фону бейджу (емодзі, іконки).
  static const double badgeBackgroundOpacity = 0.12;

  /// Стандартний вертикальний відступ плитки.
  static const double tileVerticalPadding = 16.0;

  /// Стандартний горизонтальний відступ плитки.
  static const double tileHorizontalPadding = 16.0;

  /// Компактний вертикальний відступ плитки.
  static const double compactTileVerticalPadding = 4.0;

  /// Компактний горизонтальний відступ плитки.
  static const double compactTileHorizontalPadding = 8.0;

  /// Відступ між іконкою та текстом.
  static const double iconTextSpacing = 16.0;

  /// Компактний відступ між іконкою та текстом.
  static const double compactIconTextSpacing = 8.0;

  /// Відступ між текстом та сумою.
  static const double textAmountSpacing = 8.0;

  /// Стандартна ширина рамки розгорнутої плитки.
  static const double expandedBorderWidth = 1.0;

  /// Стандартний радіус заокруглення плитки.
  static const double tileBorderRadius = 12.0;

  /// Стандартний радіус заокруглення компактної іконки.
  static const double compactIconBorderRadius = 6.0;

  /// Відступ між бейджами в заголовку.
  static const double badgeSpacing = 4.0;

  /// Горизонтальний відступ бейджу.
  static const double badgeHorizontalPadding = 6.0;

  /// Вертикальний відступ бейджу.
  static const double badgeVerticalPadding = 2.0;

  /// Стандартний розмір тексту бейджу (емодзі).
  static const double badgeEmojiFontSize = 10.0;

  /// Стандартний розмір тексту бейджу "Перший внесок".
  static const double firstDepositBadgeFontSize = 9.0;

  /// Відступ між підзаголовком та статусом обробки.
  static const double processingStatusLeftPadding = 6.0;

  /// Розмір іконки статусу обробки.
  static const double processingStatusIconSize = 12.0;

  /// Відступ між назвою та підзаголовком.
  static const double titleSubtitleSpacing = 2.0;

  /// Відступ між деталізуючим розділювачем та контентом.
  static const double detailsContentSpacing = 8.0;

  /// Максимальна кількість рядків для назви транзакції.
  static const int titleMaxLines = 1;

  /// Мінімальна ширина кнопки контекстного меню.
  static const double contextMenuItemHeight = 48.0;

  /// Максимальна ширина контенту контекстного меню.
  static const double contextMenuMaxWidth = 300.0;

  /// Стандартна тривалість появи плитки (fadeIn).
  static const Duration fadeInDuration = Duration(milliseconds: 150);

  /// Стандартна тривалість розгортання деталей.
  static const Duration expandDuration = Duration(milliseconds: 200);

  /// Стандартна тривалість shimmer-ефекту.
  static const Duration shimmerDuration = Duration(milliseconds: 1200);

  /// Стандартна тривалість тремтіння при помилці.
  static const Duration shakeDuration = Duration(milliseconds: 300);

  /// Стандартна амплітуда тремтіння.
  static const double shakeOffset = 4.0;
}

// ═══════════════════════════════════════════════════════════════════════════
// Computed Properties Extension (Обчислювальні властивості)
// ═══════════════════════════════════════════════════════════════════════════

/// Розширення для [TransactionTile] з обчислюваними властивостями.
///
/// Забезпечує швидкий доступ до комплексних значень, що залежать
/// від комбінації кількох полів віджета.
extension TransactionTileComputedProperties on TransactionTile {
  /// Чи плитка має хоча б один індикатор.
  ///
  /// Обчислюється на основі isFirstDeposit, isAutoPayment,
  /// isChallenge, hasAttachment, isProcessing, statusMessage.
  bool get hasIndicators =>
      isFirstDeposit ||
      isAutoPayment ||
      isChallenge ||
      hasAttachment ||
      isProcessing ||
      statusMessage != null;

  /// Чи плитка має бейдж XP.
  bool get hasXpBadge => xp != null && xp! > 0;

  /// Чи плитка має додаткові деталі для показу.
  ///
  /// Обчислюється на основі comment, xp, isChallenge,
  /// isAutoPayment, isFirstDeposit, hasAttachment.
  bool get hasDetails =>
      comment != null ||
      hasXpBadge ||
      isChallenge ||
      isAutoPayment ||
      isFirstDeposit ||
      hasAttachment;

  /// Чи плитка в режимі тільки для читання (без взаємодії).
  bool get isReadOnly =>
      onTap == null &&
      onLongPress == null &&
      onSwipeDelete == null &&
      onSwipeUndo == null &&
      !isProcessing;

  /// Чи плитка має дії свайпу.
  bool get hasSwipeActions =>
      onSwipeDelete != null || onSwipeUndo != null;

  /// Сума з префіксом для відображення.
  String get displayAmount {
    final prefix = direction.amountPrefix;
    return '$prefix${amount.formatUAH()} грн';
  }

  /// Сума без символу валюти.
  String get displayAmountShort =>
      '${direction.amountPrefix}${amount.formatUAH()}';

  /// Чи транзакція є позитивною (внесення або бонус).
  bool get isPositiveAmount => direction.isPositive;

  /// Чи транзакція є негативною (зняття).
  bool get isNegativeAmount => direction == TransactionDirection.withdrawal;

  /// Опис типу для accessibility.
  String get accessibilityType =>
      '${direction.accessibilityDescription}, ${type.description}';

  /// Повна описова інформація для accessibility.
  String get fullAccessibilityDescription {
    final buffer = StringBuffer();
    buffer.write(displayAmount);
    buffer.write(' — ');
    buffer.write(comment ?? direction.label);
    buffer.write(', ');
    buffer.write(type.description);
    if (isProcessing) buffer.write(', обробляється');
    if (isAutoPayment) buffer.write(', автоплатіж');
    if (isChallenge) buffer.write(', виклик');
    return buffer.toString();
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Theme-Aware Tile Builders (Темо-залежні білдери)
// ═══════════════════════════════════════════════════════════════════════════

/// Набір методів для створення темо-залежних стилів плиток.
///
/// Використовується для забезпечення consistency між різними
/// плитками транзакцій в додатку.
class TransactionTileThemeBuilders {
  TransactionTileThemeBuilders._();

  /// Створює колір фону плитки залежно від теми.
  ///
  /// [isLightTheme] — чи використовувати світлу тему.
  static Color tileBackgroundColor({bool isLightTheme = false}) {
    return isLightTheme ? AppColorsMonitor.card : AppColorsPS5.card;
  }

  /// Створює колір тексту заголовка залежно від теми.
  ///
  /// [isLightTheme] — чи використовувати світлу тему.
  static Color titleColor({bool isLightTheme = false}) {
    return isLightTheme
        ? AppColorsMonitor.textPrimary
        : AppColorsPS5.textPrimary;
  }

  /// Створює колір підзаголовка залежно від теми.
  ///
  /// [isLightTheme] — чи використовувати світлу тему.
  static Color subtitleColor({bool isLightTheme = false}) {
    return isLightTheme
        ? AppColorsMonitor.textSecondary
        : AppColorsPS5.textSecondary;
  }

  /// Створює колір підказки залежно від теми.
  ///
  /// [isLightTheme] — чи використовувати світлу тему.
  static Color hintColor({bool isLightTheme = false}) {
    return isLightTheme
        ? AppColorsMonitor.textHint
        : AppColorsPS5.textHint;
  }

  /// Створює колір межі залежно від теми.
  ///
  /// [isLightTheme] — чи використовувати світлу тему.
  static Color borderColor({bool isLightTheme = false}) {
    return isLightTheme ? AppColorsMonitor.border : AppColorsPS5.border;
  }

  /// Створює колір суми залежно від напрямку транзакції.
  ///
  /// [direction] — напрямок транзакції.
  static Color amountColor(TransactionDirection direction) {
    switch (direction) {
      case TransactionDirection.deposit:
        return AppColorsPS5.success;
      case TransactionDirection.withdrawal:
        return AppColorsPS5.error;
      case TransactionDirection.bonus:
        return AppColorsPS5.success;
    }
  }

  /// Створює колір іконки типу транзакції.
  ///
  /// [type] — тип транзакції.
  static Color typeIconColor(TransactionType type) {
    switch (type) {
      case TransactionType.manual:
        return AppColorsPS5.accent;
      case TransactionType.roundUp:
        return AppColorsPS5.accentLight;
      case TransactionType.autoPayment:
        return AppColorsPS5.coin;
      case TransactionType.challenge:
        return AppColorsPS5.xp;
      case TransactionType.dailyLogin:
        return AppColorsPS5.success;
      case TransactionType.microGoal:
        return AppColorsPS5.success;
      case TransactionType.returnBonus:
        return AppColorsPS5.warning;
    }
  }

  /// Створює BoxDecoration для іконки типу.
  ///
  /// [type] — тип транзакції.
  /// [isCompact] — чи компактний режим.
  static BoxDecoration typeIconDecoration({
    required TransactionType type,
    bool isCompact = false,
  }) {
    final color = typeIconColor(type);
    final opacity = isCompact
        ? TransactionTileConstants.compactIconBackgroundOpacity
        : TransactionTileConstants.typeIconBackgroundOpacity;
    return BoxDecoration(
      color: color.withOpacity(opacity),
      borderRadius: BorderRadius.circular(
        isCompact
            ? TransactionTileConstants.compactIconBorderRadius
            : TransactionTileConstants.tileBorderRadius,
      ),
    );
  }

  /// Створює BoxDecoration для плитки.
  ///
  /// [isLightTheme] — чи світла тема.
  /// [isExpanded] — чи плитка розгорнута.
  /// [borderColorOverride] — кастомний колір рамки.
  static BoxDecoration tileDecoration({
    bool isLightTheme = false,
    bool isExpanded = false,
    Color? borderColorOverride,
  }) {
    return BoxDecoration(
      color: tileBackgroundColor(isLightTheme: isLightTheme),
      borderRadius: BorderRadius.circular(
        TransactionTileConstants.tileBorderRadius,
      ),
      border: isExpanded
          ? Border.all(
              color: borderColorOverride ??
                  borderColor(isLightTheme: isLightTheme),
              width: TransactionTileConstants.expandedBorderWidth,
            )
          : null,
    );
  }

  /// Створює стиль тексту заголовка залежно від теми.
  ///
  /// [isLightTheme] — чи використовувати світлу тему.
  static TextStyle titleTextStyle({bool isLightTheme = false}) {
    return AppTypography.bodyMedium.copyWith(
      color: titleColor(isLightTheme: isLightTheme),
      fontWeight: FontWeight.w500,
    );
  }

  /// Створює стиль тексту суми залежно від напрямку.
  ///
  /// [direction] — напрямок транзакції.
  static TextStyle amountTextStyle(TransactionDirection direction) {
    return AppTypography.monoSmall.copyWith(
      color: amountColor(direction),
      fontWeight: FontWeight.w600,
    );
  }

  /// Створює стиль тексту суми для компактного режиму.
  ///
  /// [direction] — напрямок транзакції.
  static TextStyle compactAmountTextStyle(TransactionDirection direction) {
    return AppTypography.monoCaption.copyWith(
      color: amountColor(direction),
      fontWeight: FontWeight.w600,
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Transaction Helpers (Допоміжні методи)
// ═══════════════════════════════════════════════════════════════════════════

/// Допоміжні методи для роботи з транзакціями.
///
/// Використовується для форматування, групування та аналізу транзакцій.
class TransactionTileHelpers {
  TransactionTileHelpers._();

  /// Масив назв українських місяців у родовому відмінку.
  static const List<String> ukrainianMonths = [
    'січня', 'лютого', 'березня', 'квітня', 'травня', 'червня',
    'липня', 'серпня', 'вересня', 'жовтня', 'листопада', 'грудня',
  ];

  /// Масив назв українських місяців у називному відмінку.
  static const List<String> ukrainianMonthsNominative = [
    'січень', 'лютий', 'березень', 'квітень', 'травень', 'червень',
    'липень', 'серпень', 'вересень', 'жовтень', 'листопад', 'грудень',
  ];

  /// Форматує дату у короткий формат: "15.01 14:30".
  ///
  /// [date] — дата для форматування.
  static String formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$day.$month $hour:$minute';
  }

  /// Форматує дату повністю з назвою місяця.
  ///
  /// [date] — дата для форматування.
  static String formatFullDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = ukrainianMonths[date.month - 1];
    return '$day $month ${date.year}, ${_formatTime(date)}';
  }

  /// Форматує відносну дату (сьогодні, вчора, інше).
  ///
  /// [date] — дата для форматування.
  static String formatRelativeDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final targetDate = DateTime(date.year, date.month, date.day);

    if (targetDate == today) return 'Сьогодні о ${_formatTime(date)}';
    if (targetDate == yesterday) return 'Вчора о ${_formatTime(date)}';
    return formatDate(date);
  }

  /// Форматує тільки час: "14:30".
  ///
  /// [date] — дата для форматування.
  static String _formatTime(DateTime date) {
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  /// Групує список транзакцій за датою.
  ///
  /// [dates] — список дат транзакцій.
  /// Повертає Map з ключем — датою (без часу), значенням — кількістю.
  static Map<DateTime, int> groupByDate(List<DateTime> dates) {
    final groups = <DateTime, int>{};
    for (final date in dates) {
      final key = DateTime(date.year, date.month, date.day);
      groups[key] = (groups[key] ?? 0) + 1;
    }
    return groups;
  }

  /// Обчислює суму транзакцій за напрямком.
  ///
  /// [transactions] — список сум транзакцій.
  /// [direction] — напрямок для фільтрації.
  static double sumByDirection(
    List<double> transactions,
    TransactionDirection direction,
  ) {
    // У спрощеному варіанті, просто повертаємо суму.
    // В реальному використанні потрібен список об'єктів транзакцій.
    return transactions.fold(0.0, (sum, amount) => sum + amount);
  }

  /// Обчислює XP за типом транзакції.
  ///
  /// [type] — тип транзакції.
  /// Повертає рекомендовану кількість XP за цей тип.
  static int recommendedXp(TransactionType type) {
    switch (type) {
      case TransactionType.manual:
        return 5;
      case TransactionType.roundUp:
        return 2;
      case TransactionType.autoPayment:
        return 3;
      case TransactionType.challenge:
        return 25;
      case TransactionType.dailyLogin:
        return 10;
      case TransactionType.microGoal:
        return 15;
      case TransactionType.returnBonus:
        return 8;
    }
  }

  /// Перевіряє, чи транзакція створена сьогодні.
  ///
  /// [date] — дата створення транзакції.
  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  /// Перевіряє, чи транзакція створена цього тижня.
  ///
  /// [date] — дата створення транзакції.
  static bool isThisWeek(DateTime date) {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final target = DateTime(date.year, date.month, date.day);
    final start = DateTime(weekStart.year, weekStart.month, weekStart.day);
    return target.isAfter(start) || target.isAtSameMomentAs(start);
  }

  /// Перевіряє, чи транзакція створена цього місяця.
  ///
  /// [date] — дата створення транзакції.
  static bool isThisMonth(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month;
  }

  /// Обчислює кількість днів між двома датами.
  ///
  /// [from] — початкова дата.
  /// [to] — кінцева дата.
  static int daysBetween(DateTime from, DateTime to) {
    final fromDay = DateTime(from.year, from.month, from.day);
    final toDay = DateTime(to.year, to.month, to.day);
    return toDay.difference(fromDay).inDays;
  }

  /// Обчислює опис періоду для групування.
  ///
  /// [date] — дата транзакції.
  /// Повертає "Сьогодні", "Вчора", або форматовану дату.
  static String periodLabel(DateTime date) {
    if (isToday(date)) return 'Сьогодні';
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    if (date.year == yesterday.year &&
        date.month == yesterday.month &&
        date.day == yesterday.day) {
      return 'Вчора';
    }
    return formatDate(date);
  }

  /// Обчислює коментовану назву для транзакції.
  ///
  /// [comment] — коментар користувача.
  /// [direction] — напрямок транзакції.
  /// Повертає comment або стандартну назву за напрямком.
  static String displayTitle(String? comment, TransactionDirection direction) {
    if (comment != null && comment.isNotEmpty) return comment;
    return direction.label;
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Transaction List Helpers (Допоміжні методи для списків)
// ═══════════════════════════════════════════════════════════════════════════

/// Допоміжні методи для роботи зі списками транзакцій.
///
/// Використовується для створення списків плиток з роздільниками дат,
/// порожніми станами та іншими елементами.
class TransactionListHelpers {
  TransactionListHelpers._();

  /// Будує список плиток з роздільниками дат.
  ///
  /// [tiles] — список плиток транзакцій.
  /// [dates] — список дат для роздільників.
  /// [isLightTheme] — світла тема.
  static List<Widget> buildWithSeparators({
    required List<Widget> tiles,
    required List<DateTime> dates,
    bool isLightTheme = false,
  }) {
    // В реальному використанні цей метод створює чергування
    // TransactionDateSeparator та TransactionTile.
    return [];
  }

  /// Будує порожній стан для списку транзакцій.
  ///
  /// [isLightTheme] — світла тема.
  /// [onRetry] — callback для повторної спроби завантаження.
  static Widget buildEmptyState({
    bool isLightTheme = false,
    VoidCallback? onRetry,
  }) {
    // Повертає віджет порожнього стану
    return const SizedBox.shrink();
  }

  /// Будує стан помилки завантаження.
  ///
  /// [message] — повідомлення про помилку.
  /// [isLightTheme] — світла тема.
  /// [onRetry] — callback для повторної спроби.
  static Widget buildErrorState({
    required String message,
    bool isLightTheme = false,
    VoidCallback? onRetry,
  }) {
    // Повертає віджет стану помилки
    return const SizedBox.shrink();
  }

  /// Будує стан завантаження (shimmer/placeholder).
  ///
  /// [count] — кількість placeholder-плиток.
  /// [isLightTheme] — світла тема.
  static List<Widget> buildLoadingPlaceholders({
    int count = 5,
    bool isLightTheme = false,
  }) {
    // Повертає список shimmer-плиток
    return List.generate(count, (_) => const SizedBox.shrink());
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Additional Extensions (Додаткові розширення)
// ═══════════════════════════════════════════════════════════════════════════

/// Розширення для [TransactionTileAnimationConfig] з додатковими методами.
extension TransactionTileAnimationConfigExtension
    on TransactionTileAnimationConfig {
  /// Чи анімації ввімкнені (не нульові).
  bool get isEnabled =>
      expandDuration > Duration.zero ||
      shimmerDuration > Duration.zero ||
      fadeInDuration > Duration.zero;

  /// Конфігурація без анімацій (для тестування або accessibility).
  static const TransactionTileAnimationConfig disabled =
      TransactionTileAnimationConfig(
    expandDuration: Duration.zero,
    shimmerDuration: Duration.zero,
    fadeInDuration: Duration.zero,
    shakeDuration: Duration.zero,
    shakeOffset: 0.0,
  );

  /// Конфігурація з повільними анімаціями (для налаштувань).
  static const TransactionTileAnimationConfig slow = TransactionTileAnimationConfig(
    expandDuration: Duration(milliseconds: 400),
    shimmerDuration: Duration(milliseconds: 2000),
    fadeInDuration: Duration(milliseconds: 300),
    shakeDuration: Duration(milliseconds: 500),
    shakeOffset: 6.0,
  );

  /// Конфігурація з швидкими анімаціями (для швидкої навігації).
  static const TransactionTileAnimationConfig fast = TransactionTileAnimationConfig(
    expandDuration: Duration(milliseconds: 100),
    shimmerDuration: Duration(milliseconds: 800),
    fadeInDuration: Duration(milliseconds: 80),
    shakeDuration: Duration(milliseconds: 200),
    shakeOffset: 2.0,
  );
}

/// Розширення для [TransactionTileStyle] з додатковими computed properties.
extension TransactionTileStyleAdvancedExtension on TransactionTileStyle {
  /// Чи стиль використовує розгортання деталей.
  bool get supportsExpansion =>
      this == TransactionTileStyle.standard ||
      this == TransactionTileStyle.detailed;

  /// Чи стиль приховає XP бейдж.
  bool get hidesXpBadge => this == TransactionTileStyle.compact;

  /// Чи стиль приховує підзаголовок з джерелом.
  bool get hidesSource => this == TransactionTileStyle.compact;

  /// Відсоток зменшення розміру плитки відносно стандартного.
  double get sizeReductionFactor {
    switch (this) {
      case TransactionTileStyle.compact:
        return 0.6;
      case TransactionTileStyle.standard:
        return 1.0;
      case TransactionTileStyle.detailed:
        return 1.0;
    }
  }
}

/// Розширення для [TransactionDateSeparator] з допоміжними методами.
extension TransactionDateSeparatorExtension on TransactionDateSeparator {
  /// Чи сепаратор має видимий підсумок.
  bool get hasVisibleSummary =>
      showTransactionSummary &&
      (transactionCount > 0 || totalAmount > 0);

  /// Форматує підсумок для accessibility.
  String get summaryAccessibilityLabel {
    final parts = <String>[];
    if (transactionCount > 0) {
      parts.add('$transactionCount транзакцій');
    }
    if (totalAmount > 0) {
      parts.add('${totalAmount.toInt()} грн');
    }
    return parts.join(', ');
  }
}

/// Розширення для [TransactionTileDebugConfig] з додатковими методами.
extension TransactionTileDebugConfigExtension on TransactionTileDebugConfig {
  /// Логує інформацію про конфігурацію плитки.
  static void logTileConfig({
    required TransactionDirection direction,
    required TransactionType type,
    required double amount,
    bool isLightTheme = false,
    TransactionTileStyle style = TransactionTileStyle.standard,
  }) {
    if (!TransactionTileDebugConfig.enableLogging) return;
    debugPrint(
      '[TransactionTile:config] '
      'direction=${direction.name}, type=${type.name}, '
      'amount=$amount, light=$isLightTheme, style=${style.name}',
    );
  }

  /// Логує інформацію про анімацію плитки.
  static void logAnimation({
    required String event,
    required Duration duration,
  }) {
    if (!TransactionTileDebugConfig.enableLogging) return;
    debugPrint(
      '[TransactionTile:animation] $event (${duration.inMilliseconds}ms)',
    );
  }
}
