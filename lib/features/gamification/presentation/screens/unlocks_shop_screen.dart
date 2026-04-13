import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_radii.dart';
import '../../../../core/constants/app_shadows.dart';
import '../../../../core/widgets/app_coin_badge.dart';
import '../../../../core/extensions/build_context_ext.dart';

/// Екран «Магазин» — баланс монет, вкладки категорій, сітка товарів з прев'ю, цінами,
/// куплені з галочкою, заблоковані, bottom sheet з деталями + кнопка покупки,
/// інвентар, екіпування, фільтрування, пошук, обране.
class UnlocksShopScreen extends StatefulWidget {
  const UnlocksShopScreen({super.key});

  @override
  State<UnlocksShopScreen> createState() => _UnlocksShopScreenState();
}

class _UnlocksShopScreenState extends State<UnlocksShopScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _userCoins = 250;
  final Set<String> _purchasedItems = {'theme_neon', 'sound_chill'};
  final Set<String> _equippedItems = {'theme_neon'};
  bool _purchaseAnimating = false;
  String _searchQuery = '';
  bool _showInventory = false;
  String _priceFilter = 'Усе';

  static const _tabs = ['Усе', 'Теми', 'Ефекти', 'Звуки', 'Значки'];
  static const _priceFilters = ['Усе', 'До 100', '100-200', '200+'];

  final _shopItems = [
    _ShopItem('theme_neon', 'Неонова тема', 100, Colors.purpleAccent, 'Унікальна неонова тема з яскравими акцентами.', 'Теми'),
    _ShopItem('theme_ocean', 'Океанська тема', 100, Colors.blueAccent, 'Спокійна океанська палітра.', 'Теми'),
    _ShopItem('theme_sunset', 'Захід сонця', 150, Colors.orangeAccent, 'Теплі кольори заходу сонця.', 'Теми'),
    _ShopItem('theme_forest', 'Лісова тема', 120, Colors.greenAccent, 'Природні зелені тони.', 'Теми'),
    _ShopItem('effect_glow', 'Свічення частинок', 80, Colors.cyanAccent, 'Ефект світіння навколо цілі.', 'Ефекти'),
    _ShopItem('effect_rain', 'Дощ з монет', 120, Colors.amberAccent, 'Анімація дощу з монет при внеску.', 'Ефекти'),
    _ShopItem('effect_snow', 'Сніговий ефект', 120, Colors.lightBlueAccent, 'Зимова анімація сніжинок.', 'Ефекти'),
    _ShopItem('sound_chill', 'Чілл мелодія', 50, Colors.tealAccent, 'Розслаблена мелодія при успіху.', 'Звуки'),
    _ShopItem('sound_epic', 'Епічна перемога', 60, Colors.redAccent, 'Епічний звук при досягненні цілі.', 'Звуки'),
    _ShopItem('sound_lofi', 'Lo-fi біт', 70, Colors.indigoAccent, 'Lo-fi музика для фокусу.', 'Звуки'),
    _ShopItem('sound_nature', 'Звуки природи', 55, Colors.green, 'Звуки лісу та дощу.', 'Звуки'),
    _ShopItem('badge_premium', 'Преміум значок', 200, Colors.yellowAccent, 'Ексклюзивний значок на аватар.', 'Значки'),
    _ShopItem('badge_golden', 'Золотий значок', 300, Colors.orange, 'Преміальний золотий значок.', 'Значки'),
    _ShopItem('badge_crystal', 'Кришталевий значок', 250, Colors.lightBlue, 'Напівпрозорий кришталевий значок.', 'Значки'),
  ];

  List<_ShopItem> get _filteredItems {
    var items = _shopItems.where((item) {
      // Tab filter
      if (_tabController.index > 0) {
        final tabName = _tabs[_tabController.index];
        if (item.category != tabName) return false;
      }
      // Price filter
      if (_priceFilter != 'Усе') {
        if (_priceFilter == 'До 100' && item.price > 100) return false;
        if (_priceFilter == '100-200' && (item.price < 100 || item.price > 200)) return false;
        if (_priceFilter == '200+' && item.price < 200) return false;
      }
      // Search filter
      if (_searchQuery.isNotEmpty) {
        if (!item.name.toLowerCase().contains(_searchQuery.toLowerCase())) return false;
      }
      return true;
    }).toList();
    return items;
  }

  List<_ShopItem> _itemsForTab(int tabIndex) {
    if (tabIndex == 0) return _shopItems;
    final tabName = _tabs[tabIndex];
    return _shopItems.where((i) => i.category == tabName).toList();
  }

  bool _isPurchased(String id) => _purchasedItems.contains(id);
  bool _isEquipped(String id) => _equippedItems.contains(id);
  int get _purchasedCount => _purchasedItems.length;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;

    return Scaffold(
      backgroundColor:
          isDark ? AppColorsPS5.background : AppColorsMonitor.background,
      appBar: AppBar(
        title: const Text('Магазин'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor:
            isDark ? AppColorsPS5.textPrimary : AppColorsMonitor.textPrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.inventory_rounded),
            onPressed: () => setState(() => _showInventory = !_showInventory),
            tooltip: 'Інвентар',
          ),
          Padding(
            padding: const EdgeInsets.only(right: Spacing.md),
            child: Center(
                child: AppCoinBadge(coins: _userCoins, isLightTheme: !isDark)),
          ),
        ],
      ),
      body: Column(
        children: [
          // ─── Баланс монет + прогрес колекції ────────────────
          Container(
            margin: const EdgeInsets.symmetric(
                horizontal: Spacing.base, vertical: Spacing.sm),
            padding: const EdgeInsets.symmetric(
                horizontal: Spacing.base, vertical: Spacing.md),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColorsPS5.coin.withOpacity(0.15),
                  AppColorsPS5.coin.withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(Radii.lg),
              border: Border.all(
                color: AppColorsPS5.coin.withOpacity(0.3),
              ),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.monetization_on_rounded,
                        color: AppColorsPS5.coin, size: 22),
                    const SizedBox(width: Spacing.sm),
                    Text(
                      'Твій баланс: $_userCoins монет',
                      style: AppTypography.labelLarge.copyWith(
                        color: AppColorsPS5.coin,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: Spacing.sm),
                // Колекційний прогрес
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Колекція: $_purchasedCount / ${_shopItems.length}',
                      style: AppTypography.bodySmall.copyWith(
                        color: isDark ? AppColorsPS5.textSecondary : AppColorsMonitor.textSecondary,
                      ),
                    ),
                    const SizedBox(width: Spacing.sm),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(3),
                        child: LinearProgressIndicator(
                          value: _purchasedCount / _shopItems.length,
                          minHeight: 4,
                          backgroundColor: isDark ? AppColorsPS5.border : AppColorsMonitor.border,
                          valueColor: AlwaysStoppedAnimation(AppColorsPS5.coin),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ).animate().fade(duration: 300.ms),

          // ─── Пошук ────────────────────────────────────────────
          if (!_showInventory) ...[
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: Spacing.base, vertical: Spacing.xs),
              child: Container(
                height: 40,
                decoration: BoxDecoration(
                  color: isDark ? AppColorsPS5.card : AppColorsMonitor.card,
                  borderRadius: BorderRadius.circular(Radii.md),
                  border: Border.all(color: isDark ? AppColorsPS5.border : AppColorsMonitor.border),
                ),
                child: TextField(
                  onChanged: (v) => setState(() => _searchQuery = v),
                  style: AppTypography.bodySmall.copyWith(
                    color: isDark ? AppColorsPS5.textPrimary : AppColorsMonitor.textPrimary,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Пошук товарів...',
                    hintStyle: AppTypography.bodySmall.copyWith(
                      color: isDark ? AppColorsPS5.textHint : AppColorsMonitor.textHint,
                    ),
                    prefixIcon: Icon(Icons.search_rounded, size: 18,
                      color: isDark ? AppColorsPS5.textHint : AppColorsMonitor.textHint),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: Spacing.sm),
                  ),
                ),
              ),
            ),
            // ─── Фільтр ціни ────────────────────────────────────
            SizedBox(
              height: 36,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: Spacing.base),
                itemCount: _priceFilters.length,
                separatorBuilder: (_, __) => const SizedBox(width: Spacing.sm),
                itemBuilder: (context, i) {
                  final isActive = _priceFilters[i] == _priceFilter;
                  return GestureDetector(
                    onTap: () => setState(() => _priceFilter = _priceFilters[i]),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: isActive
                            ? (isDark ? AppColorsPS5.accent : AppColorsMonitor.accent)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(Radii.xl),
                        border: Border.all(
                          color: isActive
                              ? (isDark ? AppColorsPS5.accent : AppColorsMonitor.accent)
                              : (isDark ? AppColorsPS5.border : AppColorsMonitor.border),
                        ),
                      ),
                      child: Text(
                        _priceFilters[i],
                        style: AppTypography.labelSmall.copyWith(
                          color: isActive ? Colors.white : (isDark ? AppColorsPS5.textSecondary : AppColorsMonitor.textSecondary),
                          fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],

          // ─── TabBar ───────────────────────────────────────────
          TabBar(
            controller: _tabController,
            isScrollable: true,
            padding: const EdgeInsets.symmetric(horizontal: Spacing.base),
            labelColor:
                isDark ? AppColorsPS5.accent : AppColorsMonitor.accent,
            unselectedLabelColor: isDark
                ? AppColorsPS5.textSecondary
                : AppColorsMonitor.textSecondary,
            indicatorColor:
                isDark ? AppColorsPS5.accent : AppColorsMonitor.accent,
            tabs: _tabs.map((t) => Tab(text: t)).toList(),
          ),

          // ─── TabBarView або Інвентар ────────────────────────
          Expanded(
            child: _showInventory
                ? _buildInventoryView(isDark)
                : TabBarView(
                    controller: _tabController,
                    children: List.generate(_tabs.length, (tabIndex) {
                      final items = _searchQuery.isEmpty && _priceFilter == 'Усе'
                          ? _itemsForTab(tabIndex)
                          : _filteredItems;
                      if (items.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.search_off_rounded, size: 48,
                                color: isDark ? AppColorsPS5.textHint : AppColorsMonitor.textHint),
                              const SizedBox(height: Spacing.md),
                              Text('Нічого не знайдено',
                                style: AppTypography.bodyMedium.copyWith(
                                  color: isDark ? AppColorsPS5.textHint : AppColorsMonitor.textHint,
                                )),
                            ],
                          ),
                        );
                      }
                      return GridView.builder(
                        padding: const EdgeInsets.all(Spacing.base),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: Spacing.md,
                          mainAxisSpacing: Spacing.md,
                          childAspectRatio: 0.8,
                        ),
                        itemCount: items.length,
                        itemBuilder: (context, i) {
                          final item = items[i];
                          final canAfford = _userCoins >= item.price;
                          final isPurchased = _isPurchased(item.id);
                          final isEquipped = _isEquipped(item.id);
                          return _ShopItemTile(
                            item: item,
                            canAfford: canAfford,
                            isPurchased: isPurchased,
                            isEquipped: isEquipped,
                            isDark: isDark,
                            onTap: () => _showItemDetail(
                                context, item, canAfford, isDark),
                          )
                              .animate()
                              .fade(delay: (100 * i).ms, duration: 300.ms)
                              .scale(
                                  delay: (100 * i).ms,
                                  duration: 300.ms,
                                  begin: const Offset(0.9, 0.9));
                        },
                      );
                    }),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildInventoryView(bool isDark) {
    final purchasedItems = _shopItems.where((i) => _isPurchased(i.id)).toList();
    final equippedId = _equippedItems.isNotEmpty ? _equippedItems.last : null;

    return ListView(
      padding: const EdgeInsets.all(Spacing.base),
      children: [
        Text(
          'Інвентар',
          style: AppTypography.heading3.copyWith(
            color: isDark ? AppColorsPS5.textPrimary : AppColorsMonitor.textPrimary,
          ),
        ),
        const SizedBox(height: Spacing.md),
        Text(
          'Куплено: $_purchasedCount предметів. Натисни для деталей.',
          style: AppTypography.bodySmall.copyWith(
            color: isDark ? AppColorsPS5.textSecondary : AppColorsMonitor.textSecondary,
          ),
        ),
        const SizedBox(height: Spacing.md),
        ...purchasedItems.map((item) {
          final isEquipped = item.id == equippedId;
          return Container(
            margin: const EdgeInsets.only(bottom: Spacing.sm),
            padding: const EdgeInsets.all(Spacing.md),
            decoration: BoxDecoration(
              color: isDark ? AppColorsPS5.card : AppColorsMonitor.card,
              borderRadius: BorderRadius.circular(Radii.md),
              border: Border.all(
                color: isEquipped
                    ? AppColorsPS5.coin.withOpacity(0.5)
                    : (isDark ? AppColorsPS5.border : AppColorsMonitor.border),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: item.previewColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(Radii.sm),
                  ),
                  child: Icon(Icons.auto_awesome_rounded,
                      color: item.previewColor, size: 22),
                ),
                const SizedBox(width: Spacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.name, style: AppTypography.labelMedium.copyWith(
                        color: isDark ? AppColorsPS5.textPrimary : AppColorsMonitor.textPrimary,
                      )),
                      Text(item.category, style: AppTypography.caption.copyWith(
                        color: isDark ? AppColorsPS5.textHint : AppColorsMonitor.textHint,
                      )),
                    ],
                  ),
                ),
                if (isEquipped)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColorsPS5.coin.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(Radii.sm),
                    ),
                    child: Text('Активно', style: AppTypography.caption.copyWith(
                      color: AppColorsPS5.coin, fontWeight: FontWeight.w600,
                    )),
                  )
                else
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _equippedItems.clear();
                        _equippedItems.add(item.id);
                      });
                    },
                    child: Text('Активувати', style: AppTypography.labelSmall.copyWith(
                      color: isDark ? AppColorsPS5.accent : AppColorsMonitor.accent,
                    )),
                  ),
              ],
            ),
          );
        }),
        if (purchasedItems.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(Spacing.xxl),
              child: Text('Інвентар порожній. Завітай магазин!',
                style: AppTypography.bodyMedium.copyWith(
                  color: isDark ? AppColorsPS5.textHint : AppColorsMonitor.textHint,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }

  void _showItemDetail(
      BuildContext context, _ShopItem item, bool canAfford, bool isDark) {
    context.haptic();
    final accent = isDark ? AppColorsPS5.accent : AppColorsMonitor.accent;
    final textColor = isDark ? AppColorsPS5.textPrimary : AppColorsMonitor.textPrimary;
    final subColor = isDark ? AppColorsPS5.textSecondary : AppColorsMonitor.textSecondary;
    final isPurchased = _isPurchased(item.id);
    final isEquipped = _isEquipped(item.id);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? const Color(0xFF1E1E2E) : Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(Spacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Прев'ю
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: item.previewColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(Radii.lg),
                  boxShadow: [
                    BoxShadow(
                      color: item.previewColor.withOpacity(0.3),
                      blurRadius: 20,
                    ),
                  ],
                ),
                child: Icon(Icons.auto_awesome_rounded,
                    color: item.previewColor, size: 44),
              )
                  .animate()
                  .scale(
                      duration: 400.ms, curve: Curves.easeOutBack,
                      begin: const Offset(0.7, 0.7)),
              const SizedBox(height: Spacing.lg),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(item.name,
                      style: AppTypography.heading2.copyWith(color: textColor)),
                  const SizedBox(width: Spacing.sm),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: accent.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(Radii.sm),
                    ),
                    child: Text(item.category, style: AppTypography.caption.copyWith(
                      color: accent, fontWeight: FontWeight.w600,
                    )),
                  ),
                ],
              ),
              const SizedBox(height: Spacing.sm),
              Text(item.description,
                  style: AppTypography.bodyMedium.copyWith(color: subColor),
                  textAlign: TextAlign.center),
              const SizedBox(height: Spacing.lg),

              // Ціна
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColorsPS5.coin.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(Radii.md),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.monetization_on_rounded,
                        color: AppColorsPS5.coin, size: 20),
                    const SizedBox(width: 6),
                    Text(
                      '${item.price} монет',
                      style: AppTypography.monoSmall.copyWith(
                        color: AppColorsPS5.coin,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: Spacing.xl),

              // Кнопка: куплено / купити / недостатньо
              if (isPurchased)
                Container(
                  height: 52,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColorsPS5.success.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(Radii.base),
                    border: Border.all(
                        color: AppColorsPS5.success.withOpacity(0.3)),
                  ),
                  child: Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.check_circle_rounded,
                            color: AppColorsPS5.success, size: 20),
                        const SizedBox(width: Spacing.sm),
                        Text(
                          isEquipped ? 'Активовано' : 'Куплено',
                          style: AppTypography.buttonLarge.copyWith(
                            color: AppColorsPS5.success,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else if (canAfford)
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _userCoins -= item.price;
                      _purchasedItems.add(item.id);
                      _equippedItems.add(item.id);
                    });
                    Navigator.pop(ctx);
                    context.showToast(
                        '«${item.name}» активовано!',
                        icon: Icons.check_circle_rounded);
                  },
                  child: Container(
                    height: 52,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                          colors: [AppColorsPS5.gradientStart, AppColorsPS5.gradientEnd]),
                      borderRadius: BorderRadius.circular(Radii.base),
                      boxShadow: AppShadows.glow(accent),
                    ),
                    child: Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.shopping_bag_rounded,
                              color: Colors.white, size: 20),
                          const SizedBox(width: Spacing.sm),
                          Text(
                            'Купити та активувати',
                            style: AppTypography.buttonLarge
                                .copyWith(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              else
                Opacity(
                  opacity: 0.5,
                  child: Container(
                    height: 52,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: isDark ? AppColorsPS5.card : AppColorsMonitor.card,
                      borderRadius: BorderRadius.circular(Radii.base),
                      border: Border.all(
                          color: isDark
                              ? AppColorsPS5.border
                              : AppColorsMonitor.border),
                    ),
                    child: Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.lock_rounded,
                              color: isDark
                                  ? AppColorsPS5.textHint
                                  : AppColorsMonitor.textHint,
                              size: 18),
                          const SizedBox(width: Spacing.sm),
                          Text(
                            'Недостатньо монет',
                            style: AppTypography.buttonLarge.copyWith(
                              color: isDark
                                  ? AppColorsPS5.textSecondary
                                  : AppColorsMonitor.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: Spacing.base),
            ],
          ),
        ),
      ),
    );
  }
}

class _ShopItem {
  final String id;
  final String name;
  final int price;
  final Color previewColor;
  final String description;
  final String category;

  const _ShopItem(this.id, this.name, this.price, this.previewColor, this.description, [this.category = '']);
}

class _ShopItemTile extends StatelessWidget {
  const _ShopItemTile({
    required this.item,
    required this.canAfford,
    required this.isPurchased,
    required this.isEquipped,
    required this.isDark,
    required this.onTap,
  });

  final _ShopItem item;
  final bool canAfford;
  final bool isPurchased;
  final bool isEquipped;
  final bool isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cardColor = isDark ? AppColorsPS5.card : AppColorsMonitor.card;
    final textColor = isDark ? AppColorsPS5.textPrimary : AppColorsMonitor.textPrimary;
    final borderColor = isDark ? AppColorsPS5.border : AppColorsMonitor.border;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(Radii.lg),
          border: Border.all(
            color: isEquipped
                ? AppColorsPS5.coin.withOpacity(0.5)
                : isPurchased
                    ? AppColorsPS5.success.withOpacity(0.4)
                    : !canAfford
                        ? borderColor
                        : (isDark ? AppColorsPS5.accent : AppColorsMonitor.accent)
                            .withOpacity(0.3),
          ),
          boxShadow: isPurchased
              ? [
                  BoxShadow(
                    color: AppColorsPS5.success.withOpacity(0.1),
                    blurRadius: 8,
                  ),
                ]
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: isPurchased
                          ? AppColorsPS5.success.withOpacity(0.08)
                          : item.previewColor.withOpacity(0.15),
                      borderRadius:
                          const BorderRadius.vertical(top: Radius.circular(Radii.lg)),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.auto_awesome_rounded,
                        color: isPurchased
                            ? AppColorsPS5.success
                            : item.previewColor,
                        size: 40,
                      ),
                    ),
                  ),
                  if (isEquipped)
                    Positioned(
                      top: 6,
                      left: 6,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: AppColorsPS5.coin,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.check_rounded, color: Colors.white, size: 12),
                      ),
                    ),
                  if (isPurchased && !isEquipped)
                    Positioned(
                      top: 6,
                      right: 6,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: AppColorsPS5.success,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.check_rounded, color: Colors.white, size: 14),
                      ),
                    ),
                  if (!canAfford && !isPurchased)
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          color: (isDark ? AppColorsPS5.background : AppColorsMonitor.background)
                              .withOpacity(0.5),
                          borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(Radii.lg)),
                        ),
                        child: Center(
                          child: Icon(Icons.lock_rounded,
                              color: isDark
                                  ? AppColorsPS5.textHint
                                  : AppColorsMonitor.textHint,
                              size: 28),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(Spacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.name,
                      style: AppTypography.labelMedium.copyWith(color: textColor),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 2),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.monetization_on_rounded,
                          color: canAfford || isPurchased
                              ? AppColorsPS5.coin
                              : AppColorsPS5.error,
                          size: 14),
                      const SizedBox(width: 2),
                      Text(
                        '${item.price}',
                        style: AppTypography.monoCaption.copyWith(
                          color: canAfford || isPurchased
                              ? AppColorsPS5.coin
                              : AppColorsPS5.error,
                        ),
                      ),
                      if (isEquipped) ...[
                        const Spacer(),
                        Text('Активно', style: AppTypography.caption.copyWith(
                          color: AppColorsPS5.coin, fontWeight: FontWeight.w600,
                        )),
                      ],
                      if (isPurchased && !isEquipped) ...[
                        const Spacer(),
                        Text('Куплено', style: AppTypography.caption.copyWith(
                          color: AppColorsPS5.success, fontWeight: FontWeight.w600,
                        )),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
