import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_radii.dart';
import '../../../../core/constants/app_shadows.dart';
import '../../../../core/constants/app_enums.dart';
import '../../../../core/widgets/app_button_primary.dart';
import '../../../../core/widgets/app_button_secondary.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/utils/haptic_service.dart';

/// Екран вибору цілі — PS5, Монітор, Власна ціль або додаткові категорії.
///
/// Дві великі картки поруч із анімацією вибору, неонове сяйво,
/// тактильний відгук при виборі, власна ціль з текстовим полем,
/// індикатор прогресу (крок 2 з 4), галерея цілей, слайдер ціни,
/// порівняння цілей, детальний прев'ю вибраної цілі, фільтрація категорій,
/// вибір ефекту виділення, підрахунок оцінки популярності.
class ChooseGoalScreen extends StatefulWidget {
  const ChooseGoalScreen({super.key});

  @override
  State<ChooseGoalScreen> createState() => _ChooseGoalScreenState();
}

class _ChooseGoalScreenState extends State<ChooseGoalScreen>
    with SingleTickerProviderStateMixin {
  GoalType? _selectedGoal;
  bool _showCustomInput = false;
  final _customGoalController = TextEditingController();
  final _customAmountController = TextEditingController();
  final _searchController = TextEditingController();
  double _cardScalePS5 = 1.0;
  double _cardScaleMonitor = 1.0;
  double _priceRangeValue = 20000;
  bool _showComparison = false;
  bool _showGoalGallery = false;
  String _goalSearchQuery = '';
  int _selectionEffectIndex = 0;

  /// Додаткові категорії цілей.
  static const _extraCategories = [
    _GoalCategory(icon: Icons.laptop_mac_rounded, name: 'Ноутбук', priceRange: 'від 25 000 грн', popularity: 4.5),
    _GoalCategory(icon: Icons.headphones_rounded, name: 'Навушники', priceRange: 'від 3 000 грн', popularity: 4.8),
    _GoalCategory(icon: Icons.camera_alt_rounded, name: 'Камера', priceRange: 'від 15 000 грн', popularity: 4.2),
    _GoalCategory(icon: Icons.phone_iphone_rounded, name: 'Телефон', priceRange: 'від 12 000 грн', popularity: 4.9),
    _GoalCategory(icon: Icons.fitness_center_rounded, name: 'Фітнес', priceRange: 'від 2 000 грн', popularity: 3.8),
    _GoalCategory(icon: Icons.flight_rounded, name: 'Подорож', priceRange: 'від 10 000 грн', popularity: 4.6),
    _GoalCategory(icon: Icons.videogame_asset_rounded, name: 'Ігрова приставка', priceRange: 'від 15 000 грн', popularity: 4.3),
    _GoalCategory(icon: Icons.desktop_windows_rounded, name: 'ПК комплектуюча', priceRange: 'від 30 000 грн', popularity: 4.1),
    _GoalCategory(icon: Icons.pedal_bike_rounded, name: 'Велосипед', priceRange: 'від 8 000 грн', popularity: 3.9),
    _GoalCategory(icon: Icons.school_rounded, name: 'Освіта', priceRange: 'від 5 000 грн', popularity: 4.0),
    _GoalCategory(icon: Icons.music_note_rounded, name: 'Музичний інструмент', priceRange: 'від 4 000 грн', popularity: 3.7),
    _GoalCategory(icon: Icons.kitchen_rounded, name: 'Техніка для дому', priceRange: 'від 3 000 грн', popularity: 3.5),
  ];

  /// Ефекти вибору для анімації.
  static const _selectionEffects = [
    _SelectionEffect(name: 'Зірки', icon: Icons.auto_awesome_rounded, colors: [AppColorsPS5.accent, AppColorsPS5.xp]),
    _SelectionEffect(name: 'Сяйво', icon: Icons.wb_sunny_rounded, colors: [AppColorsPS5.coin, AppColorsPS5.success]),
    _SelectionEffect(name: 'Пульс', icon: Icons.pulse_rounded, colors: [AppColorsPS5.warning, AppColorsPS5.error]),
  ];

  late AnimationController _comparisonController;
  late AnimationController _selectionEffectController;

  void _selectGoal(GoalType type) {
    HapticService.selection();
    setState(() {
      _selectedGoal = type;
      if (type == GoalType.ps5) {
        _cardScalePS5 = 1.05;
        _cardScaleMonitor = 0.95;
        _priceRangeValue = 20000;
      } else if (type == GoalType.monitor) {
        _cardScaleMonitor = 1.05;
        _cardScalePS5 = 0.95;
        _priceRangeValue = 12000;
      } else {
        _cardScalePS5 = 0.95;
        _cardScaleMonitor = 0.95;
      }
      _showCustomInput = type == GoalType.custom;
    });
  }

  void _selectPreset(GoalType type) {
    _selectGoal(type);
  }

  @override
  void initState() {
    super.initState();
    _comparisonController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _selectionEffectController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _customGoalController.dispose();
    _customAmountController.dispose();
    _searchController.dispose();
    _comparisonController.dispose();
    _selectionEffectController.dispose();
    super.dispose();
  }

  /// Перемкнути режим порівняння цілей.
  void _toggleComparison() {
    HapticService.selection();
    setState(() => _showComparison = !_showComparison);
    if (_showComparison) {
      _comparisonController.forward();
    } else {
      _comparisonController.reverse();
    }
  }

  /// Перемкнути галерею цілей.
  void _toggleGoalGallery() {
    HapticService.selection();
    setState(() => _showGoalGallery = !_showGoalGallery);
  }

  /// Змінити ефект вибору.
  void _cycleSelectionEffect() {
    HapticService.selection();
    setState(() {
      _selectionEffectIndex = (_selectionEffectIndex + 1) % _selectionEffects.length;
    });
  }

  /// Отримати загальну кількість додаткових категорій.
  int get _totalCategories => _extraCategories.length;

  /// Отримати відфільтровані категорії.
  List<_GoalCategory> get _filteredCategories {
    if (_goalSearchQuery.isEmpty) return _extraCategories;
    return _extraCategories
        .where((c) => c.name.toLowerCase().contains(_goalSearchQuery.toLowerCase()))
        .toList();
  }

  /// Обчислити середню популярність категорій.
  double get _averagePopularity {
    if (_filteredCategories.isEmpty) return 0;
    return _filteredCategories.map((c) => c.popularity).reduce((a, b) => a + b) / _filteredCategories.length;
  }

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;

    return Scaffold(
      backgroundColor:
          isLight ? AppColorsMonitor.background : AppColorsPS5.background,
      body: SafeArea(
        child: Column(
          children: [
            // ── Індикатор прогресу (крок 2 з 4) ──────────────────
            _buildProgressIndicator(isLight),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: Spacing.base),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: Spacing.xl),

                    // ── Заголовок ───────────────────────────────
                    Text(
                      'Що накопичуємо?',
                      style: AppTypography.displayMedium.copyWith(
                        color: isLight
                            ? AppColorsMonitor.textPrimary
                            : AppColorsPS5.textPrimary,
                      ),
                    ).animate().fadeIn(duration: 500.ms),

                    const SizedBox(height: Spacing.sm),

                    Text(
                      'Обери свою ціль — можна змінити пізніше',
                      style: AppTypography.bodyMedium.copyWith(
                        color: isLight
                            ? AppColorsMonitor.textSecondary
                            : AppColorsPS5.textSecondary,
                      ),
                    ).animate().fadeIn(duration: 500.ms, delay: 100.ms),

                    const SizedBox(height: Spacing.xxl),

                    // ── Картки вибору ──────────────────────────
                    Row(
                      children: [
                        Expanded(
                          child: _GoalCard(
                            goalType: GoalType.ps5,
                            title: 'PlayStation 5',
                            subtitle: 'від 20 000 грн',
                            description: 'Ігрова консоль нового покоління '
                                'з неймовірною графікою та швидкістю',
                            icon: Icons.gamepad_rounded,
                            isSelected: _selectedGoal == GoalType.ps5,
                            isUnselected: _selectedGoal != null &&
                                _selectedGoal != GoalType.ps5,
                            scale: _cardScalePS5,
                            isLight: isLight,
                            onTap: () => _selectPreset(GoalType.ps5),
                          ),
                        ),
                        const SizedBox(width: Spacing.base),
                        Expanded(
                          child: _GoalCard(
                            goalType: GoalType.monitor,
                            title: 'Монітор',
                            subtitle: 'від 12 000 грн',
                            description: 'Професійний монітор для роботи '
                                'або ігор з високою роздільною здатністю',
                            icon: Icons.desktop_windows_rounded,
                            isSelected: _selectedGoal == GoalType.monitor,
                            isUnselected: _selectedGoal != null &&
                                _selectedGoal != GoalType.monitor,
                            scale: _cardScaleMonitor,
                            isLight: isLight,
                            onTap: () => _selectPreset(GoalType.monitor),
                          ),
                        ),
                      ],
                    ).animate().slideY(
                      begin: 0.2,
                      end: 0,
                      duration: 600.ms,
                      delay: 300.ms,
                      curve: Curves.easeOutCubic,
                    ),

                    const SizedBox(height: Spacing.xl),

                    // ── Власна ціль ────────────────────────────
                    _buildCustomGoalSection(isLight),

                    const SizedBox(height: Spacing.lg),

                    // ── Кнопка «Більше цілей» ────────────────
                    _buildGoalGalleryToggle(isLight),

                    // ── Галерея додаткових цілей ─────────────
                    AnimatedSize(
                      duration: const Duration(milliseconds: 300),
                      child: _showGoalGallery
                          ? _buildGoalGallery(isLight)
                          : const SizedBox.shrink(),
                    ),

                    const SizedBox(height: Spacing.xxl),

                    // ── Кнопка порівняння цілей ────────────────
                    _buildComparisonToggle(isLight),

                    // ── Панель порівняння ────────────────────
                    AnimatedSize(
                      duration: const Duration(milliseconds: 300),
                      child: _showComparison
                          ? _buildComparisonPanel(isLight)
                          : const SizedBox.shrink(),
                    ),

                    // ── Деталі вибраної цілі ────────────────
                    if (_selectedGoal != null && _selectedGoal != GoalType.custom)
                      _buildGoalDetailsCard(isLight),

                    // ── Слайдер цінового діапазону ──────────
                    if (_selectedGoal != null)
                      _buildPriceRangeSlider(isLight),

                    const Spacer(flex: 1),

                    // ── Кнопка «Продовжити» ──────────────────
                    AppButtonPrimary(
                      label: 'Продовжити',
                      onPressed: _selectedGoal != null
                          ? () {
                              HapticService.mediumTap();
                              context.go('/set-goal');
                            }
                          : null,
                      isDisabled: _selectedGoal == null,
                      isLightTheme: isLight,
                    ).animate().fadeIn(duration: 500.ms, delay: 500.ms),

                    const SizedBox(height: Spacing.md),

                    // ── «Пропустити» ─────────────────────────
                    Center(
                      child: AppButtonSecondary(
                        label: 'Пропустити',
                        isLightTheme: isLight,
                        onPressed: () {
                          HapticService.lightTap();
                          context.go('/set-goal');
                        },
                      ).animate().fadeIn(duration: 500.ms, delay: 600.ms),
                    ),

                    const SizedBox(height: Spacing.xxl),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Індикатор прогресу (крок 2 з 4).
  Widget _buildProgressIndicator(bool isLight) {
    final accentColor = isLight ? AppColorsMonitor.accent : AppColorsPS5.accent;
    final bgColor = isLight ? AppColorsMonitor.textHint : AppColorsPS5.textHint;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: Spacing.base),
      child: Column(
        children: [
          const SizedBox(height: Spacing.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Крок 2 з 4', style: AppTypography.labelMedium.copyWith(color: isLight ? AppColorsMonitor.textSecondary : AppColorsPS5.textSecondary)),
              Text('Вибір цілі', style: AppTypography.labelMedium.copyWith(color: accentColor, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: Spacing.sm),
          Row(
            children: List.generate(4, (index) {
              final isActive = index == 1;
              final isCompleted = index == 0;
              return Expanded(
                child: Container(
                  height: 3,
                  margin: EdgeInsets.only(right: index < 3 ? Spacing.xs : 0),
                  decoration: BoxDecoration(
                    color: isCompleted ? accentColor : isActive ? accentColor.withOpacity(0.5) : bgColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  /// Секція «Власна ціль» з текстовими полями та підказками.
  Widget _buildCustomGoalSection(bool isLight) {
    final accentColor = isLight ? AppColorsMonitor.accent : AppColorsPS5.accent;
    final isSelected = _selectedGoal == GoalType.custom;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () {
            HapticService.selection();
            setState(() => _showCustomInput = !_showCustomInput);
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(Spacing.base),
            decoration: BoxDecoration(
              color: isSelected ? accentColor.withOpacity(0.08) : (isLight ? AppColorsMonitor.card : AppColorsPS5.card),
              borderRadius: BorderRadius.circular(Radii.lg),
              border: isSelected ? Border.all(color: accentColor, width: 1.5) : Border.all(color: isLight ? AppColorsMonitor.border : AppColorsPS5.border, width: 1),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(color: accentColor.withOpacity(0.1), borderRadius: BorderRadius.circular(Radii.md)),
                  child: Icon(Icons.edit_rounded, color: accentColor, size: 22),
                ),
                const SizedBox(width: Spacing.base),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Власна ціль', style: AppTypography.heading3.copyWith(color: isLight ? AppColorsMonitor.textPrimary : AppColorsPS5.textPrimary)),
                      Text('Назви те, про що мрієш', style: AppTypography.bodySmall.copyWith(color: isLight ? AppColorsMonitor.textSecondary : AppColorsPS5.textSecondary)),
                    ],
                  ),
                ),
                Icon(_showCustomInput ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded, color: isLight ? AppColorsMonitor.textSecondary : AppColorsPS5.textSecondary),
              ],
            ),
          ).animate().slideY(begin: 0.15, end: 0, duration: 500.ms, delay: 400.ms),
        ),
        // Розгорнуті поля
        AnimatedSize(
          duration: const Duration(milliseconds: 300),
          child: _showCustomInput
              ? Padding(
                  padding: const EdgeInsets.only(top: Spacing.base),
                  child: Column(
                    children: [
                      AppTextField(
                        hint: 'Наприклад: MacBook Pro, Велосипед, Подорож...',
                        controller: _customGoalController,
                        isLightTheme: isLight,
                        prefixIcon: Icon(Icons.flag_rounded, color: isLight ? AppColorsMonitor.accent : AppColorsPS5.accent),
                        onChanged: (_) {
                          if (_customGoalController.text.isNotEmpty && _selectedGoal != GoalType.custom) {
                            setState(() => _selectedGoal = GoalType.custom);
                          }
                        },
                      ),
                      const SizedBox(height: Spacing.sm),
                      AppTextField(
                        hint: 'Орієнтовна сума (грн)',
                        controller: _customAmountController,
                        isLightTheme: isLight,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        prefixIcon: Icon(Icons.attach_money_rounded, color: isLight ? AppColorsMonitor.accent : AppColorsPS5.accent),
                      ),
                      const SizedBox(height: Spacing.sm),
                      // Підказки для власної цілі
                      Container(
                        padding: const EdgeInsets.all(Spacing.sm),
                        decoration: BoxDecoration(
                          color: accentColor.withOpacity(0.04),
                          borderRadius: BorderRadius.circular(Radii.md),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.lightbulb_outline_rounded, color: accentColor.withOpacity(0.6), size: 14),
                                const SizedBox(width: Spacing.xs),
                                Text('💡 Поради для власної цілі:', style: AppTypography.labelSmall.copyWith(color: accentColor, fontWeight: FontWeight.w600)),
                              ],
                            ),
                            const SizedBox(height: Spacing.xs),
                            Text('• Обери реалістичну суму та термін', style: AppTypography.labelSmall.copyWith(color: isLight ? AppColorsMonitor.textSecondary : AppColorsPS5.textSecondary)),
                            Text('• Розбий велику мету на менші етапи', style: AppTypography.labelSmall.copyWith(color: isLight ? AppColorsMonitor.textSecondary : AppColorsPS5.textSecondary)),
                            Text('• Почни з невеликого внеску — 100 грн вже є внесок', style: AppTypography.labelSmall.copyWith(color: isLight ? AppColorsMonitor.textSecondary : AppColorsPS5.textSecondary)),
                          ],
                        ),
                      ),
                      const SizedBox(height: Spacing.sm),
                      AppButtonPrimary(
                        label: 'Обрати власну ціль',
                        onPressed: _customGoalController.text.trim().isNotEmpty ? () {
                          HapticService.mediumTap();
                          context.go('/set-goal');
                        } : null,
                        isDisabled: _customGoalController.text.trim().isEmpty,
                        isLightTheme: isLight,
                      ),
                    ],
                  ),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }

  /// Кнопка перемикання галереї цілей.
  Widget _buildGoalGalleryToggle(bool isLight) {
    final accentColor = isLight ? AppColorsMonitor.accent : AppColorsPS5.accent;
    return GestureDetector(
      onTap: _toggleGoalGallery,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: Spacing.base, vertical: Spacing.sm),
        decoration: BoxDecoration(
          color: _showGoalGallery ? accentColor.withOpacity(0.08) : Colors.transparent,
          borderRadius: BorderRadius.circular(Radii.md),
          border: Border.all(color: (isLight ? AppColorsMonitor.border : AppColorsPS5.border).withOpacity(0.5)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.grid_view_rounded, color: accentColor, size: 18),
            const SizedBox(width: Spacing.sm),
            Text('Більше категорій (${_totalCategories})', style: AppTypography.labelMedium.copyWith(color: accentColor)),
            Icon(_showGoalGallery ? Icons.expand_less_rounded : Icons.expand_more_rounded, color: accentColor, size: 18),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 400.ms, delay: 500.ms);
  }

  /// Галерея додаткових категорій цілей з пошуком та фільтрацією.
  Widget _buildGoalGallery(bool isLight) {
    final accentColor = isLight ? AppColorsMonitor.accent : AppColorsPS5.accent;
    final filtered = _filteredCategories;

    return Padding(
      padding: const EdgeInsets.only(top: Spacing.base),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Поле пошуку
          Container(
            padding: const EdgeInsets.symmetric(horizontal: Spacing.base, vertical: Spacing.xs),
            decoration: BoxDecoration(color: isLight ? AppColorsMonitor.surface : AppColorsPS5.surface, borderRadius: BorderRadius.circular(Radii.md), border: Border.all(color: isLight ? AppColorsMonitor.border : AppColorsPS5.border)),
            child: Row(
              children: [
                Icon(Icons.search_rounded, color: isLight ? AppColorsMonitor.textHint : AppColorsPS5.textHint, size: 18),
                const SizedBox(width: Spacing.sm),
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onChanged: (v) => setState(() => _goalSearchQuery = v),
                    style: AppTypography.labelMedium.copyWith(color: isLight ? AppColorsMonitor.textPrimary : AppColorsPS5.textPrimary),
                    decoration: InputDecoration.collapsed(
                      hintText: 'Пошук категорії...',
                      hintStyle: AppTypography.labelMedium.copyWith(color: isLight ? AppColorsMonitor.textHint : AppColorsPS5.textHint),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                if (_goalSearchQuery.isNotEmpty)
                  GestureDetector(
                    onTap: () {
                      _searchController.clear();
                      setState(() => _goalSearchQuery = '');
                    },
                    child: Icon(Icons.close_rounded, color: accentColor, size: 18),
                  ),
              ],
            ),
          ),
          const SizedBox(height: Spacing.xs),
          // Лічильник результатів
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Spacing.base),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Знайдено: ${filtered.length} категорій', style: AppTypography.labelSmall.copyWith(color: isLight ? AppColorsMonitor.textSecondary : AppColorsPS5.textSecondary)),
                Text('Сер. рейтинг: ${_averagePopularity.toStringAsFixed(1)} ⭐', style: AppTypography.labelSmall.copyWith(color: AppColorsPS5.coin)),
              ],
            ),
          ),
          const SizedBox(height: Spacing.sm),
          Wrap(
            spacing: Spacing.sm,
            runSpacing: Spacing.sm,
            children: filtered.map((cat) {
              return GestureDetector(
                onTap: () {
                  HapticService.selection();
                  setState(() => _selectedGoal = GoalType.custom);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: Spacing.sm, vertical: Spacing.xs),
                  decoration: BoxDecoration(
                    color: accentColor.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(Radii.circular),
                    border: Border.all(color: accentColor.withOpacity(0.12)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(cat.icon, color: accentColor, size: 16),
                      const SizedBox(width: 4),
                      Text(cat.name, style: AppTypography.labelSmall.copyWith(color: isLight ? AppColorsMonitor.textPrimary : AppColorsPS5.textPrimary)),
                      const SizedBox(width: 4),
                      Text('⭐${cat.popularity}', style: AppTypography.labelSmall.copyWith(color: AppColorsPS5.coin, fontSize: 10)),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms);
  }

  /// Кнопка порівняння цілей.
  Widget _buildComparisonToggle(bool isLight) {
    final accentColor = isLight ? AppColorsMonitor.accent : AppColorsPS5.accent;
    return Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: _toggleComparison,
            child: Text('📊 Порівняти цілі', style: AppTypography.labelMedium.copyWith(color: accentColor, decoration: TextDecoration.underline)),
          ),
          const SizedBox(width: Spacing.base),
          GestureDetector(
            onTap: _cycleSelectionEffect,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: Spacing.xs, vertical: 4),
              decoration: BoxDecoration(
                color: accentColor.withOpacity(0.06),
                borderRadius: BorderRadius.circular(Radii.sm),
                border: Border.all(color: accentColor.withOpacity(0.12)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(_selectionEffects[_selectionEffectIndex].icon, color: accentColor, size: 12),
                  const SizedBox(width: 4),
                  Text(_selectionEffects[_selectionEffectIndex].name, style: AppTypography.labelSmall.copyWith(color: accentColor, fontSize: 10)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Панель порівняння цілей PS5 vs Монітор з детальними характеристиками.
  Widget _buildComparisonPanel(bool isLight) {
    final accentColor = isLight ? AppColorsMonitor.accent : AppColorsPS5.accent;
    final textColor = isLight ? AppColorsMonitor.textPrimary : AppColorsPS5.textPrimary;
    final subColor = isLight ? AppColorsMonitor.textSecondary : AppColorsPS5.textSecondary;

    return Container(
      margin: const EdgeInsets.only(top: Spacing.base),
      padding: const EdgeInsets.all(Spacing.base),
      decoration: BoxDecoration(color: accentColor.withOpacity(0.06), borderRadius: BorderRadius.circular(Radii.lg), border: Border.all(color: accentColor.withOpacity(0.12))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Порівняння', style: AppTypography.heading3.copyWith(color: textColor)),
          const SizedBox(height: Spacing.sm),
          _buildComparisonRow('Ціна', 'від 20 000 грн', 'від 12 000 грн', isLight),
          _buildComparisonRow('Час накопичення', '~6 місяців', '~4 місяці', isLight),
          _buildComparisonRow('Популярність', '⭐⭐⭐⭐⭐', '⭐⭐⭐⭐', isLight),
          _buildComparisonRow('Мотивація', 'Висока', 'Середня', isLight),
          _buildComparisonRow('Підцілі', '5+ варіантів', '3+ варіанти', isLight),
          _buildComparisonRow('Складність', 'Середня', 'Легше', isLight),
          // Порада вибору
          const SizedBox(height: Spacing.sm),
          Container(
            padding: const EdgeInsets.all(Spacing.sm),
            decoration: BoxDecoration(color: accentColor.withOpacity(0.08), borderRadius: BorderRadius.circular(Radii.md)),
            child: Row(
              children: [
                Icon(Icons.tips_and_updates_rounded, color: accentColor.withOpacity(0.7), size: 14),
                const SizedBox(width: Spacing.xs),
                Expanded(
                  child: Text(
                    '💡 Порада: обери те, що дійсно мотивує тебе!',
                    style: AppTypography.labelSmall.copyWith(color: subColor),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms);
  }

  /// Рядок порівняння для панелі.
  Widget _buildComparisonRow(String label, String ps5Val, String monitorVal, bool isLight) {
    final subColor = isLight ? AppColorsMonitor.textSecondary : AppColorsPS5.textSecondary;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Spacing.xs),
      child: Row(
        children: [
          Expanded(flex: 2, child: Text(label, style: AppTypography.labelSmall.copyWith(color: subColor))),
          Expanded(flex: 3, child: Text(ps5Val, style: AppTypography.labelSmall.copyWith(color: subColor), textAlign: TextAlign.center)),
          Expanded(flex: 3, child: Text(monitorVal, style: AppTypography.labelSmall.copyWith(color: subColor), textAlign: TextAlign.center)),
        ],
      ),
    );
  }

  /// Слайдер цінового діапазону.
  Widget _buildPriceRangeSlider(bool isLight) {
    final accentColor = isLight ? AppColorsMonitor.accent : AppColorsPS5.accent;

    return Container(
      margin: const EdgeInsets.only(top: Spacing.base),
      padding: const EdgeInsets.all(Spacing.base),
      decoration: BoxDecoration(
        color: (isLight ? AppColorsMonitor.card : AppColorsPS5.card).withOpacity(0.6),
        borderRadius: BorderRadius.circular(Radii.lg),
        border: Border.all(color: accentColor.withOpacity(0.2), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Бюджет', style: AppTypography.labelLarge.copyWith(color: isLight ? AppColorsMonitor.textPrimary : AppColorsPS5.textPrimary)),
              Text('${_priceRangeValue.toInt().toString()} грн', style: AppTypography.monoSmall.copyWith(color: accentColor, fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: Spacing.sm),
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: accentColor,
              inactiveTrackColor: accentColor.withOpacity(0.15),
              thumbColor: accentColor,
              overlayColor: accentColor.withOpacity(0.2),
              trackHeight: 6,
            ),
            child: Slider(
              value: _priceRangeValue,
              min: 1000,
              max: 100000,
              divisions: 99,
              onChanged: (v) => setState(() => _priceRangeValue = v),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('1 000 грн', style: AppTypography.caption.copyWith(color: isLight ? AppColorsMonitor.textHint : AppColorsPS5.textHint)),
              Text('100 000 грн', style: AppTypography.caption.copyWith(color: isLight ? AppColorsMonitor.textHint : AppColorsPS5.textHint)),
            ],
          ),
          const SizedBox(height: Spacing.xs),
          Text('Встанов бюджет для фільтрації підходящих цілей', style: AppTypography.labelSmall.copyWith(color: isLight ? AppColorsMonitor.textHint : AppColorsPS5.textHint)),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms, delay: 200.ms);
  }

  /// Картка деталей обраної цілі з розширеними характеристиками.
  Widget _buildGoalDetailsCard(bool isLight) {
    final accentColor = isLight ? AppColorsMonitor.accent : AppColorsPS5.accent;

    String details;
    List<String> features;

    if (_selectedGoal == GoalType.ps5) {
      details = 'PlayStation 5 — ігрова консоль нового покоління';
      features = [
        'AMD Zen 2 процесор, 16 ГБ RAM',
        'SSD 825 ГБ для миттєвого завантаження',
        'Зворотна сумісність з PS4',
        'DualSense контролер з тактильним зворотним зв\'язком',
        'Tempest 3D Audio для імерсивного звуку',
        'Ray Tracing для реалістичної графіки',
        'Бездротове підключення контролерів',
      ];
    } else {
      details = 'Професійний монітор для роботи та розваг';
      features = [
        'IPS-матриця з точними кольорами',
        'Частота оновлення до 165 Гц',
        'Роздільна здатність 2K або 4K',
        'Зменшення втоми очей при тривалій роботі',
        'HDR підтримка для яскравих кольорів',
        'USB-C з швидкою передачею даних',
        'Регулювання висоти та нахилу',
      ];
    }

    return Container(
      padding: const EdgeInsets.all(Spacing.base),
      decoration: BoxDecoration(
        color: (isLight ? AppColorsMonitor.card : AppColorsPS5.card).withOpacity(0.6),
        borderRadius: BorderRadius.circular(Radii.lg),
        border: Border.all(color: accentColor.withOpacity(0.2), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline_rounded, color: accentColor, size: 18),
              const SizedBox(width: Spacing.sm),
              Text(details, style: AppTypography.labelLarge.copyWith(color: isLight ? AppColorsMonitor.textPrimary : AppColorsPS5.textPrimary)),
            ],
          ),
          const SizedBox(height: Spacing.sm),
          ...features.map((f) => Padding(
                padding: const EdgeInsets.only(bottom: Spacing.xs),
                child: Row(
                  children: [
                    Icon(Icons.check_circle_outline_rounded, color: accentColor.withOpacity(0.6), size: 14),
                    const SizedBox(width: Spacing.sm),
                    Expanded(child: Text(f, style: AppTypography.bodySmall.copyWith(color: isLight ? AppColorsMonitor.textSecondary : AppColorsPS5.textSecondary))),
                  ],
                ),
              )),
          // Кнопка «Поділитися»
          const SizedBox(height: Spacing.sm),
          GestureDetector(
            onTap: () {
              HapticService.selection();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('📋 Скопійовано в буфер обміну!', style: AppTypography.labelMedium.copyWith(color: AppColorsPS5.textPrimary)),
                  duration: const Duration(milliseconds: 1500),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Icon(Icons.share_rounded, color: accentColor, size: 14),
                const SizedBox(width: 4),
                Text('Поділитися деталі', style: AppTypography.labelSmall.copyWith(color: accentColor, decoration: TextDecoration.underline)),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0, duration: 400.ms);
  }
}

/// Категорія цілі для галереї.
class _GoalCategory {
  final IconData icon;
  final String name;
  final String priceRange;
  final double popularity;

  const _GoalCategory({
    required this.icon,
    required this.name,
    required this.priceRange,
    this.popularity = 4.0,
  });
}

/// Ефект вибору для анімації.
class _SelectionEffect {
  final String name;
  final IconData icon;
  final List<Color> colors;

  const _SelectionEffect({
    required this.name,
    required this.icon,
    required this.colors,
  });
}

/// Приватний віджет картки цілі з неоновим сяйвом та ефектами вибору.
class _GoalCard extends StatelessWidget {
  const _GoalCard({
    required this.goalType, required this.title, required this.subtitle, required this.description,
    required this.icon, required this.isSelected, required this.isUnselected,
    required this.scale, required this.isLight, required this.onTap,
  });

  final GoalType goalType;
  final String title;
  final String subtitle;
  final String description;
  final IconData icon;
  final bool isSelected;
  final bool isUnselected;
  final double scale;
  final bool isLight;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = goalType == GoalType.ps5;
    final accentColor = isLight ? AppColorsMonitor.accent : AppColorsPS5.accent;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutBack,
        transform: Matrix4.identity()..scale(scale),
        transformAlignment: Alignment.center,
        padding: const EdgeInsets.all(Spacing.xl),
        decoration: BoxDecoration(
          gradient: isDark ? const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF14141F), Color(0xFF1C1C2E)]) : const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFFF5F5FA), Color(0xFFFFFFFF)]),
          borderRadius: BorderRadius.circular(Radii.xl),
          border: isSelected ? Border.all(color: accentColor, width: 2) : null,
          boxShadow: isSelected ? [BoxShadow(color: accentColor.withOpacity(0.3), blurRadius: 20, spreadRadius: 2), BoxShadow(color: accentColor.withOpacity(0.1), blurRadius: 40, spreadRadius: 4)] : AppShadows.level2,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 60, height: 60,
              decoration: BoxDecoration(color: accentColor.withOpacity(0.12), borderRadius: BorderRadius.circular(Radii.base), boxShadow: isSelected ? [BoxShadow(color: accentColor.withOpacity(0.2), blurRadius: 12)] : null),
              child: Icon(icon, color: accentColor, size: 30),
            ),
            const SizedBox(height: Spacing.base),
            Text(title, style: AppTypography.heading2.copyWith(color: isDark ? AppColorsPS5.textPrimary : AppColorsMonitor.textPrimary)),
            const SizedBox(height: Spacing.xs),
            Text(subtitle, style: AppTypography.bodyMedium.copyWith(color: isDark ? AppColorsPS5.textSecondary : AppColorsMonitor.textSecondary)),
            const SizedBox(height: Spacing.sm),
            AnimatedSize(duration: const Duration(milliseconds: 300), child: isSelected ? Text(description, style: AppTypography.bodySmall.copyWith(color: isDark ? AppColorsPS5.textHint : AppColorsMonitor.textHint, height: 1.4)) : const SizedBox.shrink()),
            if (isSelected) Padding(
              padding: const EdgeInsets.only(top: Spacing.sm),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.check_circle_rounded, color: accentColor, size: 16),
                const SizedBox(width: Spacing.xs),
                Text('Обрано', style: AppTypography.labelSmall.copyWith(color: accentColor, fontWeight: FontWeight.w600)),
              ]),
            ),
          ],
        ),
      ).animate(target: isUnselected ? 1 : 0).fade(begin: 1.0, end: 0.5, duration: 300.ms),
    );
  }
}
