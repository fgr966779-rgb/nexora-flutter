import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_typography.dart';
import '../constants/app_spacing.dart';
import '../constants/app_radii.dart';
import '../extensions/number_format_ext.dart';

// ═══════════════════════════════════════════════════════════════════════════
// Групи пресетів сум (Preset Groups)
// ═══════════════════════════════════════════════════════════════════════════

/// Групи пресетів сум для швидкого вибору при внеску.
///
/// Кожна група містить типові суми для відповідного сценарію:
/// - Швидкі: для дрібних щоденних заощаджень
/// - Середні: для регулярних планових внесків
/// - Великі: для разових великих платежів
/// - Цільові: для цільових заощаджень за категоріями
/// - Звичайні: найчастіші суми користувача
enum PresetGroup {
  /// Швидкі пресети для дрібних сум.
  ///
  /// Ідеальні для щоденних "кавових" заощаджень.
  quick(
    label: 'Швидкі',
    description: 'Дрібні щоденні суми',
    icon: Icons.flash_on_rounded,
    amounts: [50.0, 100.0, 200.0, 500.0],
  ),

  /// Середні пресети для регулярних внесків.
  ///
  /// Для щотижневних або тижневих платежів.
  medium(
    label: 'Середні',
    description: 'Регулярні планові суми',
    icon: Icons.trending_up_rounded,
    amounts: [500.0, 1000.0, 2000.0, 5000.0],
  ),

  /// Великі пресети для значних платежів.
  ///
  /// Для щомісячних або одноразових великих сум.
  large(
    label: 'Великі',
    description: 'Разові значні суми',
    icon: Icons.account_balance_wallet_rounded,
    amounts: [5000.0, 10000.0, 20000.0, 50000.0],
  ),

  /// Цільові пресети за категоріями.
  ///
  /// Спеціальні суми для конкретних цілей.
  goal(
    label: 'Цільові',
    description: 'За категоріями цілей',
    icon: Icons.flag_rounded,
    amounts: [1000.0, 5000.0, 10000.0, 25000.0],
  ),

  /// Звичайні пресети — найчастіші суми.
  ///
  /// Генеруються на основі історії користувача.
  frequent(
    label: 'Часті',
    description: 'Твої найчастіші суми',
    icon: Icons.history_rounded,
    amounts: [100.0, 500.0, 1000.0, 2000.0],
  );

  const PresetGroup({
    required this.label,
    required this.description,
    required this.icon,
    required this.amounts,
  });

  /// Назва групи (українською).
  final String label;

  /// Опис групи (українською).
  final String description;

  /// Іконка групи.
  final IconData icon;

  /// Суми у групі.
  final List<double> amounts;

  /// Повертає місцезнаходження для надпису в UI.
  String get accessibilityLabel => 'Група пресетів: $label';
}

// ═══════════════════════════════════════════════════════════════════════════
// Категорії пресетів (Preset Categories)
// ═══════════════════════════════════════════════════════════════════════════

/// Категорія пресету для контекстного відображення.
///
/// Визначає, коли який пресет показувати залежно від контексту.
enum PresetCategory {
  /// Пресети для щоденного заощадження.
  daily(
    label: 'Щоденні',
    icon: Icons.today_rounded,
    defaultAmounts: [50.0, 100.0, 150.0, 200.0, 300.0],
  ),

  /// Пресети для тижневого заощадження.
  weekly(
    label: 'Тижневі',
    icon: Icons.date_range_rounded,
    defaultAmounts: [200.0, 500.0, 1000.0, 1500.0, 2000.0],
  ),

  /// Пресети для щомісячного заощадження.
  monthly(
    label: 'Місячні',
    icon: Icons.calendar_month_rounded,
    defaultAmounts: [1000.0, 2000.0, 5000.0, 10000.0, 15000.0],
  ),

  /// Пресети для разових великих сум.
  lumpSum(
    label: 'Разові',
    icon: Icons.savings_rounded,
    defaultAmounts: [5000.0, 10000.0, 20000.0, 50000.0],
  ),

  /// Пресети для заощаджень на каву.
  coffee(
    label: 'Кавові',
    icon: Icons.local_cafe_rounded,
    defaultAmounts: [50.0, 80.0, 100.0, 150.0],
  );

  const PresetCategory({
    required this.label,
    required this.icon,
    required this.defaultAmounts,
  });

  /// Назва категорії (українською).
  final String label;

  /// Іконка категорії.
  final IconData icon;

  /// Суми за замовчуванням для цієї категорії.
  final List<double> defaultAmounts;
}

// ═══════════════════════════════════════════════════════════════════════════
// Елемент пресету суми (Preset Item)
// ═══════════════════════════════════════════════════════════════════════════

/// Один пресет суми з метаданими.
///
/// Містить не лише суму, а й інформацію про групу,
/// популярність, кількість використань та кастомну назву.
class AmountPresetItem {
  const AmountPresetItem({
    required this.amount,
    required this.group,
    this.isPopular = false,
    this.useCount = 0,
    this.customLabel,
    this.category,
    this.lastUsedAt,
    this.isFavorite = false,
  });

  /// Сума пресету в гривнях.
  final double amount;

  /// Група пресету (quick, medium, large).
  final PresetGroup group;

  /// Чи є найпопулярнішим пресетом у цій групі.
  final bool isPopular;

  /// Кількість використань (для сортування "найчастіші").
  final int useCount;

  /// Кастомна назва (наприклад, "Кава", "Обід").
  final String? customLabel;

  /// Категорія пресету (daily, weekly, monthly).
  final PresetCategory? category;

  /// Дата останнього використання.
  final DateTime? lastUsedAt;

  /// Чи додано до улюблених.
  final bool isFavorite;

  /// Форматована сума з валютою (наприклад, "500 грн").
  String get formattedAmount => '${amount.formatUAH()} грн';

  /// Форматована сума без валюти (наприклад, "500").
  String get formattedShort => amount.formatUAH();

  /// Опис пресету для accessibility.
  String get accessibilityLabel {
    final label = customLabel ?? formattedAmount;
    return 'Сума: $label';
  }

  /// Кастомна копія з оновленими даними.
  AmountPresetItem copyWith({
    double? amount,
    int? useCount,
    bool? isPopular,
    String? customLabel,
    PresetCategory? category,
    DateTime? lastUsedAt,
    bool? isFavorite,
  }) {
    return AmountPresetItem(
      amount: amount ?? this.amount,
      group: group,
      isPopular: isPopular ?? this.isPopular,
      useCount: useCount ?? this.useCount,
      customLabel: customLabel ?? this.customLabel,
      category: category ?? this.category,
      lastUsedAt: lastUsedAt ?? this.lastUsedAt,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
/// Горизонтальний ряд пресетів сум (Widget)
// ═══════════════════════════════════════════════════════════════════════════

/// Горизонтальний ряд капсул-пресетів сум.
///
/// Підтримує:
/// - Кастомні пресети сум
/// - Групи пресетів (quick, medium, large)
/// - Анімований вибір з масштабуванням
/// - Опцію введення кастомної суми
/// - Відображення валюти
/// - Бейдж "Популярний" для найвикористовуванішого
/// - Long press для введення кастомної суми
/// - Улюблені пресети з іконкою зірки
/// - Режим пошуку пресетів
///
/// Приклад використання:
/// ```dart
/// AmountPresets(
///   selectedAmount: _selectedAmount,
///   onSelect: (amount) => setState(() => _selectedAmount = amount),
///   group: PresetGroup.quick,
///   popularAmount: 200.0,
/// )
/// ```
class AmountPresets extends StatefulWidget {
  const AmountPresets({
    super.key,
    required this.selectedAmount,
    required this.onSelect,
    this.isLightTheme = false,
    this.group = PresetGroup.quick,
    this.customPresets,
    this.showCustomInput = true,
    this.popularAmount,
    this.enableAnimation = true,
    this.onLongPressCustom,
    this.currencySuffix = 'грн',
    this.favoriteAmounts = const [],
    this.onToggleFavorite,
  });

  /// Обрана сума (null = нічого не обрано).
  final double? selectedAmount;

  /// Callback при виборі суми.
  final ValueChanged<double> onSelect;

  /// Світла тема (Monitor замість PS5).
  final bool isLightTheme;

  /// Група пресетів.
  final PresetGroup group;

  /// Кастомний список пресетів (перевизначає group).
  final List<double>? customPresets;

  /// Показувати кнопку кастомної суми.
  final bool showCustomInput;

  /// Сума, що вважається найпопулярнішою (бейдж 🔥).
  final double? popularAmount;

  /// Увімкнути анімацію вибору (масштабування при натисканні).
  final bool enableAnimation;

  /// Callback при long press на кастомну суму.
  final VoidCallback? onLongPressCustom;

  /// Суфікс валюти для відображення.
  final String currencySuffix;

  /// Список улюблених сум.
  final List<double> favoriteAmounts;

  /// Callback при перемиканні улюбленого пресету.
  final ValueChanged<double>? onToggleFavorite;

  @override
  State<AmountPresets> createState() => _AmountPresetsState();
}

class _AmountPresetsState extends State<AmountPresets> {
  /// Стан натискання для кожного пресету (для анімації масштабу).
  final Map<double, bool> _pressed = {};

  /// Ефективний список пресетів.
  List<double> get _presetAmounts =>
      widget.customPresets ?? widget.group.amounts;

  // ═══════════════════════════════════════════════════════════════════════
  // Гетери кольорів (Color Getters)
  // ═══════════════════════════════════════════════════════════════════════

  /// Колір активного пресету (accent).
  Color get _accentColor => widget.isLightTheme
      ? AppColorsMonitor.accent
      : AppColorsPS5.accent;

  /// Колір тексту пресету.
  Color get _textColor => widget.isLightTheme
      ? AppColorsMonitor.textPrimary
      : AppColorsPS5.textPrimary;

  /// Колір підказки (для "Своя" кнопки).
  Color get _hintColor => widget.isLightTheme
      ? AppColorsMonitor.textHint
      : AppColorsPS5.textHint;

  /// Колір рамки пресету.
  Color get _borderColor => widget.isLightTheme
      ? AppColorsMonitor.border
      : AppColorsPS5.border;

  /// Колір монети (для популярного бейджу).
  Color get _coinColor => AppColorsPS5.coin;

  /// Колір фону популярного бейджу (світлий).
  Color get _popularBgColor => widget.isLightTheme
      ? AppColorsMonitor.success.withOpacity(0.1)
      : AppColorsPS5.success.withOpacity(0.1);

  /// Колір тексту популярного бейджу.
  Color get _popularTextColor => AppColorsPS5.success;

  /// Колір улюбленого пресету (золотий).
  Color get _favoriteColor => AppColorsPS5.coin;

  // ═══════════════════════════════════════════════════════════════════════
  // Побудова (Build)
  // ═══════════════════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: Spacing.base),
      child: Row(
        children: [
          // ── Кнопка кастомної суми ──
          if (widget.showCustomInput) ...[
            _buildCustomInputButton(),
            const SizedBox(width: Spacing.sm),
          ],
          // ── Улюблені пресети ──
          ...widget.favoriteAmounts.map((amount) {
            return Padding(
              padding: const EdgeInsets.only(right: Spacing.sm),
              child: _buildPresetButton(amount, isFavorite: true),
            );
          }),
          // ── Пресети сум ──
          ..._presetAmounts.map((amount) {
            return Padding(
              padding: const EdgeInsets.only(right: Spacing.sm),
              child: _buildPresetButton(amount),
            );
          }),
        ],
      ),
    );
  }

  /// Будує кнопку "Своя" для введення кастомної суми.
  Widget _buildCustomInputButton() {
    return GestureDetector(
      onTap: () => widget.onLongPressCustom?.call(),
      child: AnimatedContainer(
        duration: widget.enableAnimation
            ? const Duration(milliseconds: 200)
            : Duration.zero,
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(
          horizontal: Spacing.base,
          vertical: Spacing.sm + 2,
        ),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(Radii.circular),
          border: Border.all(
            color: _borderColor,
            width: 1.5,
            strokeAlign: BorderSide.strokeAlignOutside,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.edit_rounded,
              color: _hintColor,
              size: 14,
            ),
            const SizedBox(width: 4),
            Text(
              'Своя',
              style: AppTypography.labelLarge.copyWith(
                color: _hintColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Будує кнопку пресету конкретної суми.
  Widget _buildPresetButton(double amount, {bool isFavorite = false}) {
    final isSelected = widget.selectedAmount == amount;
    final isPopular = widget.popularAmount == amount;
    final isPressed = _pressed[amount] ?? false;

    return GestureDetector(
      onTapDown: (_) {
        if (widget.enableAnimation) {
          setState(() => _pressed[amount] = true);
        }
      },
      onTapUp: (_) {
        if (widget.enableAnimation) {
          setState(() => _pressed[amount] = false);
        }
      },
      onTapCancel: () {
        if (widget.enableAnimation) {
          setState(() => _pressed[amount] = false);
        }
      },
      onTap: () => widget.onSelect(amount),
      onLongPress: () {
        widget.onToggleFavorite?.call(amount);
      },
      child: AnimatedContainer(
        duration: widget.enableAnimation
            ? const Duration(milliseconds: 200)
            : Duration.zero,
        curve: Curves.easeInOut,
        transform: isPressed
            ? (Matrix4.identity()..scale(0.95))
            : Matrix4.identity(),
        transformAlignment: Alignment.center,
        padding: EdgeInsets.symmetric(
          horizontal: (isPopular || isFavorite) ? Spacing.xs : Spacing.base,
          vertical: Spacing.sm + 2,
        ),
        decoration: BoxDecoration(
          color: isSelected ? _accentColor : Colors.transparent,
          borderRadius: BorderRadius.circular(Radii.circular),
          border: Border.all(
            color: isSelected ? _accentColor : _borderColor,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Іконка улюбленого ──
            if (isFavorite) ...[
              Icon(
                Icons.star_rounded,
                size: 12,
                color: isSelected ? Colors.white.withOpacity(0.8) : _favoriteColor,
              ),
              const SizedBox(width: 4),
            ],
            // ── Бейдж "Популярний" ──
            if (isPopular && !isFavorite) ...[
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 6,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.white.withOpacity(0.2)
                      : _popularBgColor,
                  borderRadius: BorderRadius.circular(Radii.xs),
                ),
                child: Text(
                  '🔥',
                  style: const TextStyle(fontSize: 10),
                ),
              ),
              const SizedBox(width: 4),
            ],
            // ── Сума ──
            Text(
              '${amount.formatUAH()} ${widget.currencySuffix}',
              style: AppTypography.labelLarge.copyWith(
                color: isSelected ? Colors.white : _textColor,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
/// Повний вигляд з усіма групами (All Presets View)
// ═══════════════════════════════════════════════════════════════════════════

/// Повний вигляд з усіма групами пресетів сум.
///
/// Містить вкладки для перемикання між групами
/// та ряд пресетів поточної групи.
class AllAmountPresets extends StatelessWidget {
  const AllAmountPresets({
    super.key,
    required this.selectedAmount,
    required this.onSelect,
    this.isLightTheme = false,
    this.customPresets,
    this.showCustomInput = true,
    this.popularAmount,
    this.onLongPressCustom,
    this.currencySuffix = 'грн',
    this.activeGroup = PresetGroup.quick,
    this.onGroupChanged,
    this.favoriteAmounts = const [],
    this.onToggleFavorite,
  });

  /// Обрана сума.
  final double? selectedAmount;

  /// Callback при виборі суми.
  final ValueChanged<double> onSelect;

  /// Світла тема.
  final bool isLightTheme;

  /// Кастомний список пресетів (перевизначає group).
  final List<double>? customPresets;

  /// Показувати кнопку кастомної суми.
  final bool showCustomInput;

  /// Сума, що вважається найпопулярнішою.
  final double? popularAmount;

  /// Callback при long press на кастомну суму.
  final VoidCallback? onLongPressCustom;

  /// Суфікс валюти.
  final String currencySuffix;

  /// Активна група пресетів.
  final PresetGroup activeGroup;

  /// Callback при зміні групи.
  final ValueChanged<PresetGroup>? onGroupChanged;

  /// Список улюблених сум.
  final List<double> favoriteAmounts;

  /// Callback при перемиканні улюбленого пресету.
  final ValueChanged<double>? onToggleFavorite;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Вкладки груп ──
        _buildGroupTabs(),
        const SizedBox(height: Spacing.sm),
        // ── Опис групи ──
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: Spacing.base),
          child: Text(
            activeGroup.description,
            style: AppTypography.caption.copyWith(
              color: isLightTheme
                  ? AppColorsMonitor.textHint
                  : AppColorsPS5.textHint,
            ),
          ),
        ),
        const SizedBox(height: Spacing.sm),
        // ── Пресети активної групи ──
        AmountPresets(
          selectedAmount: selectedAmount,
          onSelect: onSelect,
          isLightTheme: isLightTheme,
          group: activeGroup,
          customPresets: customPresets,
          showCustomInput: showCustomInput,
          popularAmount: popularAmount,
          onLongPressCustom: onLongPressCustom,
          currencySuffix: currencySuffix,
          favoriteAmounts: favoriteAmounts,
          onToggleFavorite: onToggleFavorite,
        ),
      ],
    );
  }

  /// Будує ряд вкладок для перемикання між групами пресетів.
  Widget _buildGroupTabs() {
    final textColor = isLightTheme
        ? AppColorsMonitor.textSecondary
        : AppColorsPS5.textSecondary;

    final activeColor = isLightTheme
        ? AppColorsMonitor.accent
        : AppColorsPS5.accent;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Spacing.base),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: PresetGroup.values.map((group) {
            final isActive = group == activeGroup;
            return Padding(
              padding: const EdgeInsets.only(right: Spacing.md),
              child: GestureDetector(
                onTap: () => onGroupChanged?.call(group),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: isActive
                        ? activeColor.withOpacity(0.1)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(Radii.sm),
                    border: isActive
                        ? Border.all(color: activeColor, width: 1)
                        : null,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        group.icon,
                        size: 14,
                        color: isActive ? activeColor : textColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        group.label,
                        style: AppTypography.labelMedium.copyWith(
                          color: isActive ? activeColor : textColor,
                          fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Цільовий генератор пресетів (Goal-Aware Preset Generator)
// ═══════════════════════════════════════════════════════════════════════════

/// Генерує пресети на основі поточної цілі.
///
/// Розраховує оптимальні суми внесків залежно від:
/// - Цільової суми
/// - Залишеної суми
/// - Днів до дедлайну (якщо є)
/// - Попередніх внесків
class GoalAwarePresetGenerator {
  GoalAwarePresetGenerator._();

  /// Генерує списки пресетів на основі параметрів цілі.
  ///
  /// [targetAmount] — цільова сума в гривнях.
  /// [currentAmount] — поточна зібрана сума.
  /// [daysRemaining] — днів до дедлайну (null = без дедлайну).
  /// [recentAmounts] — останні суми внесків.
  ///
  /// Повертає список пресетів відсортований за доречністю.
  static List<double> generatePresets({
    required double targetAmount,
    required double currentAmount,
    int? daysRemaining,
    List<double>? recentAmounts,
  }) {
    final remaining = targetAmount - currentAmount;
    if (remaining <= 0) return [100.0, 500.0, 1000.0, 5000.0];

    final presets = <double>{};

    // Базові пресети — короті суми
    if (remaining >= 50000) {
      presets.addAll([5000.0, 10000.0, 15000.0, 20000.0]);
    } else if (remaining >= 10000) {
      presets.addAll([1000.0, 2000.0, 5000.0, 10000.0]);
    } else if (remaining >= 5000) {
      presets.addAll([500.0, 1000.0, 2000.0, 5000.0]);
    } else if (remaining >= 1000) {
      presets.addAll([200.0, 500.0, 1000.0, 1500.0]);
    } else {
      presets.addAll([50.0, 100.0, 200.0, 500.0]);
    }

    // Пресет на основі днів до дедлайну
    if (daysRemaining != null && daysRemaining > 0) {
      final dailyTarget = remaining / daysRemaining;
      presets.add((dailyTarget / 10).ceilToDouble() * 10); // Округлення до 10
    }

    // Пресети на основі останніх внесків
    if (recentAmounts != null && recentAmounts.isNotEmpty) {
      final avg = recentAmounts.reduce((a, b) => a + b) / recentAmounts.length;
      presets.add((avg / 50).roundToDouble() * 50); // Округлення до 50
    }

    // Сортування за зростанням
    final sorted = presets.toList()..sort();
    return sorted.take(6).toList();
  }

  /// Генерує опис пресету залежно від контексту цілі.
  ///
  /// Наприклад: "Один внесок для завершення" або "Щоденний внесок".
  static String getDescriptionForAmount(
    double amount, {
    required double remaining,
    int? daysRemaining,
  }) {
    if (amount >= remaining) return 'Фінальний внесок!';
    if (daysRemaining != null && daysRemaining > 0) {
      final daily = remaining / daysRemaining;
      if (amount >= daily * 3) return 'Прискорений внесок';
      if (amount >= daily) return 'Нормальний внесок';
      return 'Невеликий внесок';
    }
    if (amount >= 5000) return 'Великий внесок';
    if (amount >= 1000) return 'Середній внесок';
    return 'Невеликий внесок';
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Панель пошуку пресетів (Preset Search)
// ═══════════════════════════════════════════════════════════════════════════

/// Панель пошуку для швидкого знаходження суми серед пресетів.
///
/// Дозволяє вводити суму та шукати серед всіх пресетів,
/// історії використання та кастомних сум.
class PresetSearchPanel extends StatefulWidget {
  const PresetSearchPanel({
    super.key,
    required this.onSelect,
    this.isLightTheme = false,
    this.allPresets,
    this.historyAmounts = const [],
    this.currencySuffix = 'грн',
  });

  /// Callback при виборі суми.
  final ValueChanged<double> onSelect;

  /// Світла тема.
  final bool isLightTheme;

  /// Всі доступні пресети.
  final List<double>? allPresets;

  /// Суми з історії використання.
  final List<double> historyAmounts;

  /// Суфікс валюти.
  final String currencySuffix;

  @override
  State<PresetSearchPanel> createState() => _PresetSearchPanelState();
}

class _PresetSearchPanelState extends State<PresetSearchPanel> {
  final _searchController = TextEditingController();
  List<double> _filteredResults = [];

  @override
  void initState() {
    super.initState();
    _filteredResults = widget.historyAmounts.isNotEmpty
        ? widget.historyAmounts
        : (widget.allPresets ?? [100.0, 500.0, 1000.0, 5000.0]);
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.replaceAll(RegExp(r'[^\d]'), '');
    if (query.isEmpty) {
      setState(() {
        _filteredResults = widget.historyAmounts.isNotEmpty
            ? widget.historyAmounts
            : (widget.allPresets ?? [100.0, 500.0, 1000.0, 5000.0]);
      });
      return;
    }

    final searchValue = double.tryParse(query) ?? 0;
    final all = {
      ...?widget.allPresets,
      ...widget.historyAmounts,
    };

    setState(() {
      _filteredResults = all
          .where((amount) {
            final formatted = amount.toInt().toString();
            return formatted.contains(query);
          })
          .toList()
        ..sort((a, b) =>
            (a - searchValue).abs().compareTo((b - searchValue).abs()));
    });
  }

  @override
  Widget build(BuildContext context) {
    final textColor = widget.isLightTheme
        ? AppColorsMonitor.textPrimary
        : AppColorsPS5.textPrimary;
    final hintColor = widget.isLightTheme
        ? AppColorsMonitor.textHint
        : AppColorsPS5.textHint;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // ── Поле пошуку ──
        Padding(
          padding: const EdgeInsets.all(Spacing.base),
          child: TextField(
            controller: _searchController,
            style: AppTypography.bodyMedium.copyWith(color: textColor),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              hintText: 'Пошук суми...',
              hintStyle: AppTypography.bodyMedium.copyWith(color: hintColor),
              prefixIcon: Icon(Icons.search_rounded, color: hintColor, size: 20),
              suffixIcon: _searchController.text.isNotEmpty
                  ? GestureDetector(
                      onTap: () {
                        _searchController.clear();
                        _onSearchChanged();
                      },
                      child: Icon(Icons.clear_rounded,
                          color: hintColor, size: 20),
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(Radii.base),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: Spacing.base,
                vertical: Spacing.md,
              ),
            ),
          ),
        ),
        // ── Результати ──
        if (_filteredResults.isEmpty)
          Padding(
            padding: const EdgeInsets.all(Spacing.base),
            child: Text(
              'Нічого не знайдено',
              style: AppTypography.bodySmall.copyWith(color: hintColor),
            ),
          )
        else
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _filteredResults.length.clamp(0, 6),
              itemBuilder: (context, index) {
                final amount = _filteredResults[index];
                return ListTile(
                  dense: true,
                  title: Text(
                    '${amount.formatUAH()} ${widget.currencySuffix}',
                    style: AppTypography.labelLarge.copyWith(color: textColor),
                  ),
                  trailing: Icon(Icons.add_circle_outline_rounded,
                      color: textColor, size: 20),
                  onTap: () => widget.onSelect(amount),
                );
              },
            ),
          ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Допоміжні методи (Helper Methods)
// ═══════════════════════════════════════════════════════════════════════════

/// Допоміжні методи для роботи з пресетами сум.
class AmountPresetsHelpers {
  AmountPresetsHelpers._();

  /// Повертає найближчий пресет до заданої суми.
  ///
  /// Шукає серед стандартних пресетів та повертає найближчу суму.
  static double findClosestPreset(double amount) {
    final allPresets = [
      ...PresetGroup.quick.amounts,
      ...PresetGroup.medium.amounts,
      ...PresetGroup.large.amounts,
    ];

    double closest = allPresets.first;
    double minDiff = (amount - closest).abs();

    for (final preset in allPresets) {
      final diff = (amount - preset).abs();
      if (diff < minDiff) {
        closest = preset;
        minDiff = diff;
      }
    }

    return closest;
  }

  /// Повертає суму найпопулярнішого пресету.
  ///
  /// [useCounts] — карта: сума → кількість використань.
  static double findMostPopularPreset(Map<double, int> useCounts) {
    if (useCounts.isEmpty) return 100.0;

    double popular = 0.0;
    int maxCount = 0;

    useCounts.forEach((amount, count) {
      if (count > maxCount) {
        popular = amount;
        maxCount = count;
      }
    });

    return popular;
  }

  /// Форматує суму для відображення з валютою.
  ///
  /// Наприклад: formatAmount(1500) → "1 500 грн"
  static String formatAmount(double amount, {String suffix = 'грн'}) {
    return '${amount.formatUAH()} $suffix';
  }

  /// Повертає опис пресета для accessibility.
  ///
  /// [amount] — сума пресету.
  static String accessibilityDescription(double amount) {
    return 'Вибрано суму: ${amount.formatUAH()} гривень';
  }

  /// Повертає опис вибору для screen reader.
  static String selectedMessage(double? amount) {
    if (amount == null) return 'Сума не обрана';
    return 'Обрано: ${amount.formatUAH()} гривень';
  }

  /// Перевіряє, чи сума є "округлою" (кратна 50 або 100).
  static bool isRoundAmount(double amount) {
    return amount % 50 == 0;
  }

  /// Повертає діапазон сум для групи пресетів.
  static ({double min, double max}) rangeForGroup(PresetGroup group) {
    final amounts = group.amounts;
    return (
      min: amounts.reduce((a, b) => a < b ? a : b),
      max: amounts.reduce((a, b) => a > b ? a : b),
    );
  }

  /// Повертає відсортовані пресети за частотою використання.
  ///
  /// [useCounts] — карта: сума → кількість використань.
  static List<double> sortedByFrequency(Map<double, int> useCounts) {
    final entries = useCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return entries.map((e) => e.key).toList();
  }

  /// Генерує пресети на основі історії використання.
  ///
  /// Аналізує останні [history] сум та генерує рекомендації.
  static List<double> generateFromHistory(List<double> history) {
    if (history.isEmpty) return PresetGroup.quick.amounts;
    if (history.length < 3) return history.toSet().toList()..sort();

    // Групуємо суми та знаходимо найчастіші
    final frequency = <double, int>{};
    for (final amount in history) {
      frequency[amount] = (frequency[amount] ?? 0) + 1;
    }

    // Сортуємо за частотою та повертаємо топ-6
    final sorted = frequency.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return sorted.take(6).map((e) => e.key).toList()..sort();
  }

  /// Пошук пресета за рядком (цифрами).
  ///
  /// Шукає серед [availablePresets] та повертає результати.
  static List<double> searchPresets(
    String query,
    List<double> availablePresets,
  ) {
    if (query.isEmpty) return availablePresets;
    final cleanQuery = query.replaceAll(RegExp(r'[^\d]'), '');
    if (cleanQuery.isEmpty) return availablePresets;

    return availablePresets
        .where((amount) => amount.toInt().toString().contains(cleanQuery))
        .toList()
      ..sort((a, b) {
        final aDiff = (a.toInt().toString().length - cleanQuery.length).abs();
        final bDiff = (b.toInt().toString().length - cleanQuery.length).abs();
        return aDiff.compareTo(bDiff);
      });
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Константи пресетів сум (Preset Constants)
// ═══════════════════════════════════════════════════════════════════════════

/// Константи для пресетів сум: ліміти, розміри, тривалості.
///
/// Містить усі числові значення, які використовуються для налаштування
/// пресетів сум в додатку Nexora.
class AmountPresetsConstants {
  AmountPresetsConstants._();

  /// Мінімальна сума пресету.
  static const double minAmount = 10.0;

  /// Максимальна сума пресету.
  static const double maxAmount = 1000000.0;

  /// Максимальна кількість пресетів у групі.
  static const int maxPresetsPerGroup = 6;

  /// Максимальна кількість улюблених пресетів.
  static const int maxFavoritePresets = 10;

  /// Максимальна кількість пресетів у пошуку.
  static const int maxSearchResults = 6;

  /// Мінімальна довжина рядка для пошуку.
  static const int minSearchQueryLength = 1;

  /// Крок округлення суми.
  static const double roundingStep = 50.0;

  /// Мінімальна кількість елементів історії для генерації пресетів.
  static const int minHistoryForGeneration = 3;

  /// Максимальна кількість згенерованих пресетів.
  static const int maxGeneratedPresets = 6;

  /// Мінімальна кількість використань для "популярного" пресету.
  static const int popularMinUseCount = 3;

  /// Стандартний суфікс валюти.
  static const String defaultCurrencySuffix = 'грн';

  /// Стандартна тривалість анімації пресету.
  static const Duration animationDuration = Duration(milliseconds: 200);

  /// Крива анімації пресету.
  static const Curve animationCurve = Curves.easeInOut;

  /// Масштаб пресету при натисканні.
  static const double pressScale = 0.95;

  /// Ширина рамки пресету.
  static const double borderWidth = 1.5;

  /// Розмір іконки улюбленого пресету.
  static const double favoriteIconSize = 12.0;

  /// Розмір іконки пошуку.
  static const double searchIconSize = 20.0;

  /// Розмір іконки "Своя" кнопки.
  static const double customInputIconSize = 14.0;

  /// Мінімальна кількість символів для назви пресету.
  static const int minCustomLabelLength = 1;

  /// Максимальна кількість символів для назви пресету.
  static const int maxCustomLabelLength = 30;

  /// Відстань між пресетами в ряду.
  static const double presetSpacing = 8.0;

  /// Відстань між кнопкою "Своя" та пресетами.
  static const double customInputSpacing = 8.0;
}

// ═══════════════════════════════════════════════════════════════════════════
// Валідація пресетів (Presets Validation)
// ═══════════════════════════════════════════════════════════════════════════

/// Методи валідації для пресетів сум.
///
/// Перевіряє коректність параметрів пресетів.
class PresetsValidation {
  PresetsValidation._();

  /// Перевіряє, чи сума в допустимих межах.
  static bool isValidAmount(double amount) {
    return amount >= AmountPresetsConstants.minAmount &&
        amount <= AmountPresetsConstants.maxAmount;
  }

  /// Перевіряє, чи сума позитивна.
  static bool isPositiveAmount(double amount) {
    return amount > 0;
  }

  /// Перевіряє, чи сума округлена.
  static bool isRoundedAmount(double amount) {
    return amount % AmountPresetsConstants.roundingStep == 0;
  }

  /// Перевіряє, чи кількість пресетів не перевищує ліміт.
  static bool isValidPresetCount(int count) {
    return count > 0 && count <= AmountPresetsConstants.maxPresetsPerGroup;
  }

  /// Перевіряє, чи кастомна назва в допустимих межах.
  static bool isValidCustomLabel(String? label) {
    if (label == null) return true;
    return label.isNotEmpty &&
        label.length >= AmountPresetsConstants.minCustomLabelLength &&
        label.length <= AmountPresetsConstants.maxCustomLabelLength;
  }

  /// Перевіряє, чи кількість улюблених пресетів не перевищує ліміт.
  static bool isValidFavoriteCount(int count) {
    return count <= AmountPresetsConstants.maxFavoritePresets;
  }

  /// Перевіряє, чи список пресетів не пустий.
  static bool isValidPresetList(List<double> presets) {
    return presets.isNotEmpty;
  }

  /// Перевіряє, чи всі суми в списку унікальні.
  static bool hasUniqueAmounts(List<double> presets) {
    return presets.toSet().length == presets.length;
  }

  /// Перевіряє, чи сума є дуплікатом у списку.
  static bool isDuplicateAmount(double amount, List<double> presets) {
    return presets.contains(amount);
  }

  /// Перевіряє, чи список пресетів відсортований.
  static bool isSorted(List<double> presets) {
    for (var i = 1; i < presets.length; i++) {
      if (presets[i] <= presets[i - 1]) return false;
    }
    return true;
  }

  /// Повертає список помилок валідації для списку пресетів.
  static List<String> validatePresetList(List<double> presets) {
    final errors = <String>[];
    if (!isValidPresetList(presets)) {
      errors.add('Список пресетів пустий');
    }
    for (final amount in presets) {
      if (!isValidAmount(amount)) {
        errors.add('Сума $amount поза межами');
      }
    }
    if (!hasUniqueAmounts(presets)) {
      errors.add('Список містить дублікати');
    }
    if (presets.length > AmountPresetsConstants.maxPresetsPerGroup) {
      errors.add('Забагато пресетів (макс. ${AmountPresetsConstants.maxPresetsPerGroup})');
    }
    return errors;
  }

  /// Округлює суму до найближчого кратного [roundingStep].
  static double roundAmount(double amount) {
    final step = AmountPresetsConstants.roundingStep;
    return (amount / step).round() * step;
  }

  /// Повертає опис помилки валідації.
  static String errorMessage(String field, dynamic value) {
    return 'Некоректне значення $field: $value';
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Розширення PresetGroup (Group Extensions)
// ═══════════════════════════════════════════════════════════════════════════

/// Розширення для [PresetGroup] з додатковими computed properties.
extension PresetGroupExtension on PresetGroup {
  /// Мінімальна сума в групі.
  double get minAmount => amounts.reduce((a, b) => a < b ? a : b);

  /// Максимальна сума в групі.
  double get maxAmount => amounts.reduce((a, b) => a > b ? a : b);

  /// Середня сума в групі.
  double get averageAmount {
    if (amounts.isEmpty) return 0;
    return amounts.reduce((a, b) => a + b) / amounts.length;
  }

  /// Діапазон сум в групі.
  ({double min, double max}) get range => (min: minAmount, max: maxAmount);

  /// Кількість пресетів в групі.
  int get presetCount => amounts.length;

  /// Чи це група з великими сумами.
  bool get isHighValue => maxAmount >= 10000;

  /// Чи це група з малими сумами.
  bool get isLowValue => maxAmount < 1000;

  /// Форматований діапазон для відображення.
  String get formattedRange =>
      '${minAmount.formatUAH()} — ${maxAmount.formatUAH()} грн';

  /// Опис групи для accessibility.
  String get accessibilityDescription =>
      'Група $label: ${amounts.length} пресетів від ${minAmount.formatUAH()} до ${maxAmount.formatUAH()} гривень';

  /// Повертає групу за назвою (case-insensitive).
  static PresetGroup? fromName(String name) {
    final lower = name.toLowerCase();
    for (final group in PresetGroup.values) {
      if (group.name.toLowerCase() == lower ||
          group.label.toLowerCase() == lower) {
        return group;
      }
    }
    return null;
  }

  /// Сортує групи за середньою сумою (за зростанням).
  static List<PresetGroup> sortedByAverageAmount() {
    final groups = List<PresetGroup>.from(PresetGroup.values);
    groups.sort((a, b) => a.averageAmount.compareTo(b.averageAmount));
    return groups;
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Розширення PresetCategory (Category Extensions)
// ═══════════════════════════════════════════════════════════════════════════

/// Розширення для [PresetCategory] з додатковими computed properties.
extension PresetCategoryExtension on PresetCategory {
  /// Мінімальна сума в категорії.
  double get minAmount => defaultAmounts.reduce((a, b) => a < b ? a : b);

  /// Максимальна сума в категорії.
  double get maxAmount => defaultAmounts.reduce((a, b) => a > b ? a : b);

  /// Кількість пресетів в категорії.
  int get presetCount => defaultAmounts.length;

  /// Середня сума в категорії.
  double get averageAmount {
    if (defaultAmounts.isEmpty) return 0;
    return defaultAmounts.reduce((a, b) => a + b) / defaultAmounts.length;
  }

  /// Форматований діапазон для відображення.
  String get formattedRange =>
      '${minAmount.formatUAH()} — ${maxAmount.formatUAH()} грн';

  /// Опис категорії для accessibility.
  String get accessibilityDescription =>
      'Категорія $label: ${defaultAmounts.length} пресетів';

  /// Чи категорія має триваліший період (місячний).
  bool get isLongTerm => this == PresetCategory.monthly || this == PresetCategory.lumpSum;

  /// Чи категорія короткострокова.
  bool get isShortTerm =>
      this == PresetCategory.daily || this == PresetCategory.coffee;

  /// Повертає категорію за назвою.
  static PresetCategory? fromName(String name) {
    final lower = name.toLowerCase();
    for (final cat in PresetCategory.values) {
      if (cat.name.toLowerCase() == lower ||
          cat.label.toLowerCase() == lower) {
        return cat;
      }
    }
    return null;
  }

  /// Повертає всі категорії відсортовані за кількістю пресетів.
  static List<PresetCategory> sortedByPresetCount() {
    final cats = List<PresetCategory>.from(PresetCategory.values);
    cats.sort((a, b) => a.presetCount.compareTo(b.presetCount));
    return cats;
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Розширення AmountPresetItem (Item Extensions)
// ═══════════════════════════════════════════════════════════════════════════

/// Розширення для [AmountPresetItem] з додатковими computed properties.
extension AmountPresetItemExtension on AmountPresetItem {
  /// Чи пресет має кастомну назву.
  bool get hasCustomLabel => customLabel != null && customLabel!.isNotEmpty;

  /// Чи пресет має категорію.
  bool get hasCategory => category != null;

  /// Чи пресет використовувався хоча б раз.
  bool get hasBeenUsed => useCount > 0;

  /// Чи пресет є "популярним" (використовувався > 3 рази).
  bool get isFrequentlyUsed =>
      useCount >= AmountPresetsConstants.popularMinUseCount;

  /// Чи пресет нещодавно використовувався (останні 7 днів).
  bool get wasRecentlyUsed {
    if (lastUsedAt == null) return false;
    return DateTime.now().difference(lastUsedAt!).inDays <= 7;
  }

  /// Кількість днів з останнього використання.
  int? get daysSinceLastUse {
    if (lastUsedAt == null) return null;
    return DateTime.now().difference(lastUsedAt!).inDays;
  }

  /// Опис пресету для debug-логування.
  String get debugDescription {
    final parts = <String>[
      'AmountPresetItem(',
      'amount: $amount,',
      'group: ${group.name},',
      'useCount: $useCount,',
      if (isPopular) 'popular: true,',
      if (isFavorite) 'favorite: true,',
      if (hasCustomLabel) 'label: "$customLabel",',
      if (hasCategory) 'category: ${category!.name},',
      if (lastUsedAt != null) 'lastUsed: $lastUsedAt',
      ')',
    ];
    return parts.join(' ');
  }

  /// Повертає "швидкість" використання (використань на день).
  double get usageRate {
    if (lastUsedAt == null || useCount == 0) return 0;
    final days = DateTime.now().difference(lastUsedAt!).inDays;
    if (days == 0) return useCount.toDouble();
    return useCount / days;
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Тема пресетів (Preset Theme Helpers)
// ═══════════════════════════════════════════════════════════════════════════

/// Допоміжний клас для визначення кольорів пресетів залежно від теми.
///
/// Центральний точка для всіх кольорових рішень пресетів.
class PresetsThemeHelper {
  PresetsThemeHelper._();

  /// Повертає колір активного пресету.
  static Color accentColor({required bool isLightTheme}) {
    return isLightTheme ? AppColorsMonitor.accent : AppColorsPS5.accent;
  }

  /// Повертає колір тексту пресету.
  static Color textColor({required bool isLightTheme}) {
    return isLightTheme ? AppColorsMonitor.textPrimary : AppColorsPS5.textPrimary;
  }

  /// Повертає колір підказки.
  static Color hintColor({required bool isLightTheme}) {
    return isLightTheme ? AppColorsMonitor.textHint : AppColorsPS5.textHint;
  }

  /// Повертає колір рамки пресету.
  static Color borderColor({required bool isLightTheme}) {
    return isLightTheme ? AppColorsMonitor.border : AppColorsPS5.border;
  }

  /// Повертає колір тексту для选中 стану.
  static Color selectedTextColor({required bool isSelected}) {
    return isSelected ? Colors.white : AppColorsPS5.textPrimary;
  }

  /// Повертає колір фону популярного бейджу.
  static Color popularBadgeBg({required bool isLightTheme}) {
    return isLightTheme
        ? AppColorsMonitor.success.withOpacity(0.1)
        : AppColorsPS5.success.withOpacity(0.1);
  }

  /// Повертає колір тексту популярного бейджу.
  static Color popularBadgeText() {
    return AppColorsPS5.success;
  }

  /// Повертає колір улюбленого пресету.
  static Color favoriteColor() {
    return AppColorsPS5.coin;
  }

  /// Повертає колір фону іконки улюбленого пресету.
  static Color favoriteIconBg({required bool isSelected}) {
    if (isSelected) return Colors.white.withOpacity(0.2);
    return AppColorsPS5.coin.withOpacity(0.1);
  }

  /// Повертає колір тексту вкладки групи.
  static Color groupTabTextColor({
    required bool isActive,
    required bool isLightTheme,
  }) {
    if (isActive) return accentColor(isLightTheme: isLightTheme);
    return isLightTheme
        ? AppColorsMonitor.textSecondary
        : AppColorsPS5.textSecondary;
  }

  /// Повертає колір фону вкладки групи.
  static Color groupTabBgColor({
    required bool isActive,
    required bool isLightTheme,
  }) {
    if (!isActive) return Colors.transparent;
    return accentColor(isLightTheme: isLightTheme).withOpacity(0.1);
  }

  /// Повертає колір рамки вкладки групи.
  static Color groupTabBorderColor({
    required bool isActive,
    required bool isLightTheme,
  }) {
    if (!isActive) return Colors.transparent;
    return accentColor(isLightTheme: isLightTheme);
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Аналітика пресетів (Preset Analytics)
// ═══════════════════════════════════════════════════════════════════════════

/// Аналітичні методи для пресетів сум.
///
/// Надає обчислені метрики для аналізу використання пресетів.
class PresetAnalytics {
  PresetAnalytics._();

  /// Обчислює загальну суму всіх використаних пресетів.
  static double totalAmount(List<AmountPresetItem> items) {
    return items.fold(0.0, (sum, item) => sum + item.amount * item.useCount);
  }

  /// Обчислює середню суму використаного пресету.
  static double averageUsedAmount(List<AmountPresetItem> items) {
    final used = items.where((i) => i.hasBeenUsed).toList();
    if (used.isEmpty) return 0;
    return used.fold(0.0, (sum, item) => sum + item.amount) / used.length;
  }

  /// Повертає найпопулярніший пресет.
  static AmountPresetItem? mostPopular(List<AmountPresetItem> items) {
    if (items.isEmpty) return null;
    return items.reduce((a, b) => a.useCount >= b.useCount ? a : b);
  }

  /// Повертає найменш використовуваний пресет.
  static AmountPresetItem? leastPopular(List<AmountPresetItem> items) {
    if (items.isEmpty) return null;
    return items.reduce((a, b) => a.useCount <= b.useCount ? a : b);
  }

  /// Повертає пресети відсортовані за частотою використання.
  static List<AmountPresetItem> sortedByUsage(List<AmountPresetItem> items) {
    final sorted = List<AmountPresetItem>.from(items);
    sorted.sort((a, b) => b.useCount.compareTo(a.useCount));
    return sorted;
  }

  /// Повертає пресети відсортовані за сумою (за зростанням).
  static List<AmountPresetItem> sortedByAmount(List<AmountPresetItem> items) {
    final sorted = List<AmountPresetItem>.from(items);
    sorted.sort((a, b) => a.amount.compareTo(b.amount));
    return sorted;
  }

  /// Повертає пресети відсортовані за останнім використанням (найновіші перші).
  static List<AmountPresetItem> sortedByRecency(List<AmountPresetItem> items) {
    final withDate = items.where((i) => i.lastUsedAt != null).toList();
    final sorted = List<AmountPresetItem>.from(withDate);
    sorted.sort((a, b) {
      if (a.lastUsedAt == null && b.lastUsedAt == null) return 0;
      if (a.lastUsedAt == null) return 1;
      if (b.lastUsedAt == null) return -1;
      return b.lastUsedAt!.compareTo(a.lastUsedAt!);
    });
    return sorted;
  }

  /// Повертає кількість унікальних використаних пресетів.
  static int uniqueUsedCount(List<AmountPresetItem> items) {
    return items.where((i) => i.hasBeenUsed).length;
  }

  /// Повертає відсоток пресетів, що використовувалися хоча б раз.
  static double usagePercentage(List<AmountPresetItem> items) {
    if (items.isEmpty) return 0;
    return (uniqueUsedCount(items) / items.length) * 100;
  }

  /// Повертає пресети для "рекомендацій" (топ-3 за частотою).
  static List<AmountPresetItem> topRecommendations(List<AmountPresetItem> items) {
    return sortedByUsage(items).take(3).toList();
  }

  /// Генерує статистичний звіт для пресетів.
  static String generateStatsReport(List<AmountPresetItem> items) {
    final buffer = StringBuffer('Preset Stats Report\n');
    buffer.writeln('Total items: ${items.length}');
    buffer.writeln('Used items: ${uniqueUsedCount(items)}');
    buffer.writeln('Usage rate: ${usagePercentage(items).toStringAsFixed(1)}%');
    buffer.writeln('Total amount: ${totalAmount(items).formatUAH()} грн');
    buffer.writeln('Average used: ${averageUsedAmount(items).formatUAH()} грн');
    final popular = mostPopular(items);
    if (popular != null) {
      buffer.writeln('Most popular: ${popular.formattedAmount} (${popular.useCount} uses)');
    }
    return buffer.toString();
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Форматування пресетів (Preset Format Helpers)
// ═══════════════════════════════════════════════════════════════════════════

/// Допоміжні методи для форматування пресетів.
///
/// Надає готові формати для відображення пресетів.
class PresetFormatHelpers {
  PresetFormatHelpers._();

  /// Форматує суму з валютою та пробілами.
  static String formatWithCurrency(double amount, {String suffix = 'грн'}) {
    return '${amount.formatUAH()} $suffix';
  }

  /// Форматує суму без валюти.
  static String formatShort(double amount) {
    return amount.formatUAH();
  }

  /// Форматує суму в компактному вигляді (тисячі → "К").
  ///
  /// Наприклад: 10000 → "10К", 500000 → "500К".
  static String formatCompact(double amount) {
    if (amount >= 1000000) return '${(amount / 1000000).toStringAsFixed(1)}М';
    if (amount >= 1000) return '${(amount / 1000).toStringAsFixed(amount % 1000 == 0 ? 0 : 1)}К';
    return amount.toInt().toString();
  }

  /// Форматує діапазон сум.
  static String formatRange(double min, double max, {String suffix = 'грн'}) {
    return '${min.formatUAH()} — ${max.formatUAH()} $suffix';
  }

  /// Форматує опис пресету з назвою.
  static String formatPresetWithLabel(double amount, {String? customLabel}) {
    if (customLabel != null) return '$customLabel (${amount.formatUAH()} грн)';
    return '${amount.formatUAH()} грн';
  }

  /// Форматує опис групи для відображення.
  static String formatGroupDescription(PresetGroup group) {
    return '${group.label}: ${group.formattedRange}';
  }

  /// Форматує опис категорії для відображення.
  static String formatCategoryDescription(PresetCategory category) {
    return '${category.label} (${category.presetCount} пресетів)';
  }

  /// Форматує кількість використань.
  static String formatUseCount(int count) {
    if (count == 0) return 'Не використовувався';
    if (count == 1) return '1 раз';
    if (count >= 2 && count <= 4) return '$count рази';
    return '$count разів';
  }

  /// Форматує дату останнього використання.
  static String formatLastUsed(DateTime? date) {
    if (date == null) return 'Ніколи';
    final days = DateTime.now().difference(date).inDays;
    if (days == 0) return 'Сьогодні';
    if (days == 1) return 'Вчора';
    if (days < 7) return '$days днів тому';
    if (days < 30) return '${(days / 7).floor()} тижнів тому';
    return '${(days / 30).floor()} місяців тому';
  }

  /// Форматує опис пресету для accessibility.
  static String accessibilityString({
    required double amount,
    required bool isSelected,
    required bool isFavorite,
    required bool isPopular,
    String? customLabel,
  }) {
    final parts = <String>[];
    if (customLabel != null) parts.add(customLabel);
    parts.add('${amount.formatUAH()} гривень');
    if (isSelected) parts.add('обрано');
    if (isFavorite) parts.add('улюблений');
    if (isPopular) parts.add('популярний');
    return parts.join(', ');
  }
}
