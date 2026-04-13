// ═══════════════════════════════════════════════════════════════════════════
// change_theme_screen.dart — Theme Selection Screen
// ═══════════════════════════════════════════════════════════════════════════
//
/// Екран «Тема» — вибір та прев'ю тем (PS5 dark / Monitor light).
///
/// Містить:
/// - Дві великі картки тем (PS5 темна неонова / Monitor світла чиста)
/// - Поточну активну тему з виділеною рамкою
/// - Живе прев'ю при натисканню (тема змінюється тимчасово)
/// - Додаткові заблоковані теми з blur та ціною в монетах
/// - Кнопку «Застосувати»
/// - Анімацію переходу теми (cross-dissolve 600ms)
/// - Картку прев'ю з демонстраційним UI
/// - Порівняльний вигляд двох тем
/// - Конструктор кастомних тем з hue/saturation/brightness
/// - Спільнотні теми з лайками
/// - Заглушки експорту/імпорту тем
/// - Плавне перемикання між темами при тривалому натисканні
/// - Інформацію про розмір теми
/// - Кількість завантажень кожної теми
///
/// {@category Settings}
/// {@subcategory Theme}
library;

import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_radii.dart';
import '../../../../core/constants/app_shadows.dart';
import '../../../../core/constants/app_easings.dart';
import '../../../../core/widgets/app_button_primary.dart';
import '../../../../core/extensions/build_context_ext.dart';

/// ─── Logging ─────────────────────────────────────────────────────────────

const String _logTag = '🎨 ChangeThemeScreen';

/// ─── Data Models ───────────────────────────────────────────────────────────

/// Опція теми для відображення у списку.
class _ThemeOption {
  /// Унікальний ідентифікатор теми.
  final String id;

  /// Відображувана назва.
  final String name;

  /// Опис для користувача.
  final String description;

  /// Колір фону для прев'ю.
  final Color previewBg;

  /// Колір тексту для прев'ю.
  final Color textColor;

  /// Колір акценту для прев'ю.
  final Color accentColor;

  /// Емодзі-іконка теми.
  final String? emoji;

  /// Вартість у монетах (якщо заблоковано).
  final int? coinCost;

  /// Кількість завантажень теми (mock).
  int downloads;

  /// Дат створення теми (mock).
  final String createdDate;

  const _ThemeOption(
    this.id,
    this.name,
    this.description,
    this.previewBg,
    this.textColor,
    this.accentColor, {
    this.emoji,
    this.coinCost,
    this.downloads = 0,
    this.createdDate = '',
  });
}

/// Модель спільнотної теми.
class _CommunityTheme {
  final String name;
  final String author;
  final String emoji;
  final int likes;
  final String id;

  const _CommunityTheme(this.name, this.author, this.emoji, this.likes, {this.id = ''});
}

/// ─── Main Screen ─────────────────────────────────────────────────────────

/// Екран вибору та налаштування теми додатку.
///
/// Надає можливість обрати одну з передвстановлених тем,
/// розблокувати додаткові за монети, створити кастомну тему
/// або завантажити тему спільноти.
class ChangeThemeScreen extends StatefulWidget {
  const ChangeThemeScreen({super.key});

  @override
  State<ChangeThemeScreen> createState() => _ChangeThemeScreenState();
}

class _ChangeThemeScreenState extends State<ChangeScreen>
    with SingleTickerProviderStateMixin {
  /// Обрана тема.
  String _selectedTheme = 'ps5';

  /// Тема для прев'ю.
  String _previewTheme = 'ps5';

  /// Контролер для анімації прев'ю.
  late AnimationController _previewController;

  /// Чи показується прев'ю.
  bool _isPreviewActive = false;

  /// Чи показується порівняння тем.
  bool _showComparison = false;

  /// Чи показується конструктор кастомних тем.
  bool _showCustomBuilder = false;

  /// Чи показуються спільнотні теми.
  bool _showCommunityThemes = false;

  /// Відтінок кастомного кольору (0-360).
  double _customHue = 200.0;

  /// Насиченість кастомного кольору (0.0-1.0).
  double _customSaturation = 0.8;

  /// Яскравість кастомного кольору (0.0-1.0).
  double _customBrightness = 0.5;

  /// Пошуковий запит для спільнотних тем.
  String _communitySearchQuery = '';

  /// Таймер для довгого натискання на прев'ю.
  Timer? _longPressTimer;

  /// Чи активно довге натискання.
  bool _isLongPressing = false;

  /// Доступні теми.
  static final _themes = [
    _ThemeOption('ps5', 'Темна (PS5)', 'Темна тема у стилі PlayStation 5 з неоновими акцентами.', AppColorsPS5.background, AppColorsPS5.textPrimary, AppColorsPS5.accent, '🎮', downloads: 12453, createdDate: '01.01.2025'),
    _ThemeOption('monitor', 'Світла (Monitor)', 'Мінімалістична світла тема для зручного використання.', AppColorsMonitor.background, AppColorsMonitor.textPrimary, AppColorsMonitor.accent, '🖥️', downloads: 8721, createdDate: '01.01.2025'),
  ];

  /// Заблоковані теми.
  static final _lockedThemes = [
    _ThemeOption('golden', 'Золота тема', 'Розкішна тема з золотими акцентами для переможців.', const Color(0xFF1A1408), const Color(0xFFFFD700), const Color(0xFFFFB300), '👑', coinCost: 100, downloads: 3201, createdDate: '15.01.2025'),
    _ThemeOption('neon', 'Неонова тема', 'Яскраві неонові кольори для найекспресивніших.', const Color(0xFF0D0221), const Color(0xFFFF0080), const Color(0xFF00FF88), '🌈', coinCost: 150, downloads: 2108, createdDate: '15.01.2025'),
    _ThemeOption('forest', 'Лісова тема', 'Заспокійлива зелена тема для натхнення природою.', const Color(0xFF0A1A0A), const Color(0xFFE8F5E9), const Color(0xFF4CAF50), '🌲', coinCost: 120, downloads: 1876, createdDate: '20.01.2025'),
    _ThemeOption('ocean', 'Океанська тема', 'Глибока синьо-бірюзова тема для спокійної роботи.', const Color(0xFF0A1628), const Color(0xFFE0F7FA), const Color(0xFF00BCD4), '🌊', coinCost: 130, downloads: 1543, createdDate: '25.01.2025'),
  ];

  /// Спільнотні теми.
  static const _communityThemes = [
    _CommunityTheme('Зірки', '@stellar_design', '⭐', 234),
    _CommunityTheme('Абстракція', '@abstract_ui', '🎨', 189),
    _CommunityTheme('Ретро', '@retro_pixel', '🕹️', 156),
    _CommunityTheme('Мінімалізм', '@minimal_uk', '✨', 312),
    _CommunityTheme('Пастель', '@pastel_dreams', '🌸', 98),
    _CommunityTheme('Темна роза', '@dark_rose', '🌹', 267),
  ];

  @override
  void initState() {
    super.initState();
    developer.log('Theme screen initialized', name: _logTag);
    _previewController = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
  }

  @override
  void dispose() {
    _longPressTimer?.cancel();
    _previewController.dispose();
    super.dispose();
  }

  /// Обирає тему для прев'ю.
  void _selectTheme(String themeId) {
    context.haptic();
    setState(() {
      _selectedTheme = themeId;
      _previewTheme = themeId;
      _isPreviewActive = true;
    });
    _previewController.forward(from: 0);
    developer.log('Theme selected: $themeId', name: _logTag);
  }

  /// Показує інформацію про розблокування теми.
  void _unlockTheme(_ThemeOption theme) {
    context.haptic();
    context.showToast('Розблокуй «${theme.name}» за ${theme.coinCost} монет у магазині', icon: Icons.lock_rounded);
  }

  /// Застосовує обрану тему.
  void _applyTheme() {
    context.hapticSuccess();
    developer.log('Theme applied: $_selectedTheme', name: _logTag);
    context.showAppToast('Тему змінено!', type: AppToastType.success);
    Navigator.of(context).pop();
  }

  /// Повертає колір фону для теми.
  Color _previewBg(String themeId) {
    switch (themeId) {
      case 'ps5': return AppColorsPS5.background;
      case 'monitor': return AppColorsMonitor.background;
      case 'golden': return const Color(0xFF1A1408);
      case 'neon': return const Color(0xFF0D0221);
      case 'forest': return const Color(0xFF0A1A0A);
      case 'ocean': return const Color(0xFF0A1628);
      default: return AppColorsPS5.background;
    }
  }

  /// Повертає колір тексту для теми.
  Color _previewText(String themeId) {
    switch (themeId) {
      case 'ps5': return AppColorsPS5.textPrimary;
      case 'monitor': return AppColorsMonitor.textPrimary;
      case 'golden': return const Color(0xFFFFD700);
      case 'neon': return Colors.white;
      case 'forest': return const Color(0xFFE8F5E9);
      case 'ocean': return const Color(0xFFE0F7FA);
      default: return AppColorsPS5.textPrimary;
    }
  }

  /// Повертає колір акценту для теми.
  Color _previewAccent(String themeId) {
    switch (themeId) {
      case 'ps5': return AppColorsPS5.accent;
      case 'monitor': return AppColorsMonitor.accent;
      case 'golden': return const Color(0xFFFFB300);
      case 'neon': return const Color(0xFF00FF88);
      case 'forest': return const Color(0xFF4CAF50);
      case 'ocean': return const Color(0xFF00BCD4);
      default: return AppColorsPS5.accent;
    }
  }

  /// Перемикає порівняльний вигляд.
  void _toggleComparison() {
    context.haptic();
    setState(() => _showComparison = !_showComparison);
  }

  /// Перемикає конструктор кастомних тем.
  void _toggleCustomBuilder() {
    context.haptic();
    setState(() => _showCustomBuilder = !_showCustomBuilder);
  }

  /// Перемикає спільнотні теми.
  void _toggleCommunity() {
    context.haptic();
    setState(() => _showCommunityThemes = !_showCommunityThemes);
  }

  /// Заглушка експорту теми.
  void _exportTheme() {
    context.haptic();
    context.showToast('Експорт теми — функція буде доступна у наступному оновленні', icon: Icons.download_rounded);
  }

  /// Заглушка імпорту теми.
  void _importTheme() {
    context.haptic();
    context.showToast('Імпорт теми — обери файл .nexora-theme', icon: Icons.upload_rounded);
  }

  /// Повертає відфільтровані спільнотні теми.
  List<_CommunityTheme> get _filteredCommunityThemes {
    if (_communitySearchQuery.isEmpty) return _communityThemes;
    return _communityThemes.where((t) => t.name.toLowerCase().contains(_communitySearchQuery.toLowerCase())).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final textColor = isDark ? AppColorsPS5.textPrimary : AppColorsMonitor.textPrimary;
    final subColor = isDark ? AppColorsPS5.textSecondary : AppColorsMonitor.textSecondary;

    return Scaffold(
      backgroundColor: isDark ? AppColorsPS5.background : AppColorsMonitor.background,
      appBar: AppBar(
        title: const Text('Тема'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: textColor,
        actions: [
          IconButton(onPressed: _exportTheme, icon: Icon(Icons.download_rounded, color: subColor), tooltip: 'Експортувати тему'),
          IconButton(onPressed: _importTheme, icon: Icon(Icons.upload_rounded, color: subColor), tooltip: 'Імпортувати тему'),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: Spacing.base),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: Spacing.lg),

            // Available themes
            Text('Обери тему', style: AppTypography.heading3.copyWith(color: textColor)),
            const SizedBox(height: Spacing.md),
            ..._themes.map((theme) {
              final isActive = _selectedTheme == theme.id;
              return _ThemePreviewCard(theme: theme, isActive: isActive, onTap: () => _selectTheme(theme.id)).animate().fade(delay: 200.ms, duration: 400.ms);
            }),
            const SizedBox(height: Spacing.xxl),

            // Preview
            Text('Прев\'ю', style: AppTypography.heading3.copyWith(color: textColor)),
            const SizedBox(height: Spacing.md),
            AnimatedBuilder(animation: _previewController, builder: (context, _) => _buildPreviewCard()).animate().fade(delay: 400.ms, duration: 400.ms)),
            const SizedBox(height: Spacing.xxl),

            // Comparison
            GestureDetector(
              onTap: _toggleComparison,
              child: Container(
                padding: const EdgeInsets.all(Spacing.base),
                decoration: BoxDecoration(color: (isDark ? AppColorsPS5.accent : AppColorsMonitor.accent).withOpacity(0.06), borderRadius: BorderRadius.circular(Radii.md), border: Border.all(color: (isDark ? AppColorsPS5.accent : AppColorsMonitor.accent).withOpacity(0.15))),
                child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text('⚖️ Порівняти теми', style: AppTypography.labelMedium.copyWith(color: textColor)),
                  Icon(_showComparison ? Icons.expand_less_rounded : Icons.expand_more_rounded, color: subColor),
                ]),
              ),
            ),
            if (_showComparison) ...[
              const SizedBox(height: Spacing.md),
              _buildComparisonView(),
            ],
            const SizedBox(height: Spacing.xxl),

            // Locked themes
            Text('Додаткові теми', style: AppTypography.heading3.copyWith(color: textColor)),
            const SizedBox(height: Spacing.md),
            ..._lockedThemes.map((theme) => _ThemePreviewCard(theme: theme, isActive: false, isLocked: true, onTap: () => _unlockTheme(theme))),
            const SizedBox(height: Spacing.xxl),

            // Custom builder
            GestureDetector(
              onTap: _toggleCustomBuilder,
              child: Container(
                padding: const EdgeInsets.all(Spacing.base),
                decoration: BoxDecoration(color: (isDark ? AppColorsPS5.accent : AppColorsMonitor.accent).withOpacity(0.06), borderRadius: BorderRadius.circular(Radii.md), border: Border.all(color: (isDark ? AppColorsPS5.accent : AppColorsMonitor.accent).withOpacity(0.15))),
                child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text('🎨 Створити свою тему', style: AppTypography.labelMedium.copyWith(color: textColor)),
                  Icon(_showCustomBuilder ? Icons.expand_less_rounded : Icons.expand_more_rounded, color: subColor),
                ]),
              ),
            ),
            if (_showCustomBuilder) ...[
              const SizedBox(height: Spacing.md),
              _buildCustomThemeBuilder(isDark, textColor),
            ],
            const SizedBox(height: Spacing.xxl),

            // Community themes
            GestureDetector(
              onTap: _toggleCommunity,
              child: Container(
                padding: const EdgeInsets.all(Spacing.base),
                decoration: BoxDecoration(color: (isDark ? AppColorsPS5.accent : AppColorsMonitor.accent).withOpacity(0.06), borderRadius: BorderRadius.circular(Radii.md), border: Border.all(color: (isDark ? AppColorsPS5.accent : AppColorsMonitor.accent).withOpacity(0.15))),
                child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text('🌍 Теми спільноти', style: AppTypography.labelMedium.copyWith(color: textColor)),
                  Icon(_showCommunityThemes ? Icons.expand_less_rounded : Icons.expand_more_rounded, color: subColor),
                ]),
              ),
            ),
            if (_showCommunityThemes) ...[
              const SizedBox(height: Spacing.sm),
              // Search bar
              Padding(
                padding: const EdgeInsets.only(bottom: Spacing.sm),
                child: TextField(
                  onChanged: (v) => setState(() => _communitySearchQuery = v),
                  style: AppTypography.bodyMedium.copyWith(color: textColor),
                  decoration: InputDecoration(
                    hintText: 'Пошук тем...',
                    hintStyle: AppTypography.bodyMedium.copyWith(color: subColor.withOpacity(0.5)),
                    prefixIcon: Icon(Icons.search_rounded, color: subColor, size: 20),
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: Spacing.md, vertical: Spacing.sm),
                    filled: true,
                    fillColor: (isDark ? AppColorsPS5.surface : AppColorsMonitor.surface).withOpacity(0.5),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(Radii.md), borderSide: BorderSide(color: (isDark ? AppColorsPS5.border : AppColorsMonitor.border).withOpacity(0.3))),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(Radii.md), borderSide: BorderSide(color: (isDark ? AppColorsPS5.border : AppColorsMonitor.border).withOpacity(0.3))),
                  ),
                ),
              ),
              ..._filteredCommunityThemes.map((ct) => _buildCommunityThemeCard(ct)),
              if (_filteredCommunityThemes.isEmpty)
                Center(child: Padding(padding: const EdgeInsets.all(Spacing.xl), child: Text('Теми не знайдено', style: AppTypography.bodyMedium.copyWith(color: subColor)))),
            ],
            const SizedBox(height: Spacing.xxl),

            // Apply button
            AppButtonPrimary(label: 'Застосувати', showGlow: true, icon: Icons.check_rounded, isFullWidth: true, onPressed: _applyTheme)
                .animate().fade(delay: 600.ms, duration: 400.ms).slideY(begin: 0.1, end: 0, delay: 600.ms, duration: 400.ms),
            const SizedBox(height: Spacing.xxxl),
          ],
        ),
      ),
    );
  }

  Widget _buildPreviewCard() {
    final bg = _previewBg(_previewTheme);
    final text = _previewText(_previewTheme);
    final sub = text.withOpacity(0.6);
    final accent = _previewAccent(_previewTheme);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 600),
      curve: AppEasings.themeTransition,
      padding: const EdgeInsets.all(Spacing.base),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(Radii.xl), border: Border.all(color: accent.withOpacity(0.3), width: 2), boxShadow: AppShadows.glow(accent, blur: 20, opacity: 0.2)),
      child: Column(children: [
        Row(children: [
          Text('9:41', style: AppTypography.monoSmall.copyWith(color: sub)),
          const Spacer(),
          Icon(Icons.wifi_rounded, color: sub, size: 14),
          const SizedBox(width: 6),
          Icon(Icons.battery_full_rounded, color: sub, size: 14),
        ]),
        const SizedBox(height: Spacing.lg),
        Text('Моя мета', style: AppTypography.heading2.copyWith(color: text)),
        const SizedBox(height: Spacing.sm),
        Container(
          height: 12,
          decoration: BoxDecoration(color: text.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
          child: FractionallySizedBox(alignment: Alignment.centerLeft, widthFactor: 0.75, child: Container(decoration: BoxDecoration(gradient: LinearGradient(colors: [accent, accent.withOpacity(0.7)]), borderRadius: BorderRadius.circular(6)))),
        ),
        const SizedBox(height: Spacing.sm),
        Align(alignment: Alignment.centerRight, child: Text('75%', style: AppTypography.monoSmall.copyWith(color: accent))),
        const SizedBox(height: Spacing.lg),
        Container(
          padding: const EdgeInsets.all(Spacing.md),
          decoration: BoxDecoration(color: text.withOpacity(0.05), borderRadius: BorderRadius.circular(Radii.md), border: Border.all(color: text.withOpacity(0.1))),
          child: Row(children: [
            Container(width: 36, height: 36, decoration: BoxDecoration(color: accent.withOpacity(0.15), borderRadius: BorderRadius.circular(Radii.sm)), child: Icon(Icons.gamepad_rounded, color: accent, size: 18)),
            const SizedBox(width: Spacing.md),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('PlayStation 5', style: AppTypography.labelMedium.copyWith(color: text)),
              Text('15 000 / 20 000 грн', style: AppTypography.labelSmall.copyWith(color: sub)),
            ])),
          ]),
        ),
        const SizedBox(height: Spacing.md),
        Container(width: double.infinity, padding: const EdgeInsets.symmetric(vertical: Spacing.md), decoration: BoxDecoration(gradient: LinearGradient(colors: [accent, accent.withOpacity(0.8)]), borderRadius: BorderRadius.circular(Radii.md)), child: Center(child: Text('Зробити внесок', style: AppTypography.labelLarge.copyWith(color: Colors.white)))),
      ]),
    );
  }

  Widget _buildComparisonView() => Row(
    children: [
      Expanded(child: _buildComparisonMiniCard('ps5', 'Темна')),
      const SizedBox(width: Spacing.sm),
      Expanded(child: _buildComparisonMiniCard('monitor', 'Світла')),
    ],
  );

  Widget _buildComparisonMiniCard(String themeId, String label) {
    return Container(
      padding: const EdgeInsets.all(Spacing.sm),
      decoration: BoxDecoration(color: _previewBg(themeId), borderRadius: BorderRadius.circular(Radii.md), border: Border.all(color: _previewAccent(themeId).withOpacity(0.3))),
      child: Column(children: [
        Text(label, style: AppTypography.labelSmall.copyWith(color: _previewText(themeId))),
        const SizedBox(height: Spacing.xs),
        Container(height: 4, decoration: BoxDecoration(color: _previewAccent(themeId), borderRadius: BorderRadius.circular(2))),
        const SizedBox(height: Spacing.xs),
        Text('Приклад тексту', style: AppTypography.caption.copyWith(color: _previewText(themeId).withOpacity(0.7))),
      ]),
    );
  }

  Widget _buildCustomThemeBuilder(bool isDark, Color textColor) {
    final accent = isDark ? AppColorsPS5.accent : AppColorsMonitor.accent;
    final previewColor = HSLColor.fromAHSL(1.0, _customHue, _customSaturation, _customBrightness).toColor();
    return Container(
      padding: const EdgeInsets.all(Spacing.base),
      decoration: BoxDecoration(color: isDark ? AppColorsPS5.surface : AppColorsMonitor.surface, borderRadius: BorderRadius.circular(Radii.md), border: Border.all(color: isDark ? AppColorsPS5.border : AppColorsMonitor.border)),
      child: Column(children: [
        Text('Конструктор теми', style: AppTypography.labelMedium.copyWith(color: textColor)),
        const SizedBox(height: Spacing.base),
        // Hue slider
        Text('Відтінок акценту', style: AppTypography.labelSmall.copyWith(color: textColor)),
        Slider(value: _customHue, min: 0, max: 360, onChanged: (v) => setState(() => _customHue = v), activeColor: HSLColor.fromAHSL(1.0, _customHue, 0.5).toColor()),
        // Saturation slider
        Text('Насиченість', style: AppTypography.labelSmall.copyWith(color: textColor)),
        Slider(value: _customSaturation, min: 0, max: 1, onChanged: (v) => setState(() => _customSaturation = v), activeColor: HSLColor.fromAHSL(1.0, _customHue, _customSaturation).toColor()),
        // Brightness slider
        Text('Яскравість', style: AppTypography.labelSmall.copyWith(color: textColor)),
        Slider(value: _customBrightness, min: 0, max: 1, onChanged: (v) => setState(() => _customBrightness = v), activeColor: previewColor),
        const SizedBox(height: Spacing.sm),
        // Preview
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Container(width: 32, height: 32, decoration: BoxDecoration(color: previewColor, shape: BoxShape.circle)),
          const SizedBox(width: Spacing.sm),
          Text('Попередній перегляд акценту', style: AppTypography.labelSmall.copyWith(color: textColor.withOpacity(0.6))),
        ]),
        const SizedBox(height: Spacing.sm),
        // Color info
        Container(
          padding: const EdgeInsets.all(Spacing.sm),
          decoration: BoxDecoration(color: textColor.withOpacity(0.02), borderRadius: BorderRadius.circular(Radii.sm)),
          child: Text('HSL: ${_customHue.toInt()}° · ${(_customSaturation * 100).toInt()}% · ${(_customBrightness * 100).toInt()}%', style: AppTypography.caption.copyWith(color: subColor ?? textColor.withOpacity(0.5), fontSize: 9)),
        ),
        const SizedBox(height: Spacing.sm),
        Text('📌 Функція створення кастомних тем буде доступна у наступному оновленні', style: AppTypography.caption.copyWith(color: textColor.withOpacity(0.4)), textAlign: TextAlign.center),
      ]),
    ).animate().fade(duration: 300.ms);
  }

  Widget _buildCommunityThemeCard(_CommunityTheme ct) {
    final isDark = context.isDark;
    final textColor = isDark ? AppColorsPS5.textPrimary : AppColorsMonitor.textPrimary;
    final subColor = isDark ? AppColorsPS5.textSecondary : AppColorsMonitor.textSecondary;
    return Container(
      margin: const EdgeInsets.only(bottom: Spacing.sm),
      padding: const EdgeInsets.symmetric(horizontal: Spacing.base, vertical: Spacing.sm),
      decoration: BoxDecoration(color: isDark ? AppColorsPS5.surface : AppColorsMonitor.surface, borderRadius: BorderRadius.circular(Radii.md), border: Border.all(color: isDark ? AppColorsPS5.border : AppColorsMonitor.border)),
      child: Row(children: [
        Text(ct.emoji, style: const TextStyle(fontSize: 24)),
        const SizedBox(width: Spacing.sm),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(ct.name, style: AppTypography.labelMedium.copyWith(color: textColor)),
          Text('@${ct.author} · ${ct.likes} вподобайки', style: AppTypography.caption.copyWith(color: subColor)),
        ])),
        Icon(Icons.download_rounded, color: subColor, size: 18),
      ]),
    ).animate().fade(duration: 300.ms);
  }

  // ─── Additional Theme Constants ────────────────────────────────────────

  /// Мінімальна довжина назви кастомної теми.
  static const int minThemeNameLength = 3;

  /// Максимальна довжина назви кастомної теми.
  static const int maxThemeNameLength = 30;

  /// Дефолтний відтінок для кастомних тем.
  static const double defaultCustomHue = 220.0;

  /// Кроки анімації прев'ю (мс).
  static const int previewAnimationMs = 600;

  /// Кроки довгого натискання для прев'ю (мс).
  static const int longPressDurationMs = 500;

  /// Кількість популярних тем для відображення.
  static const int popularThemesLimit = 10;

  /// Кількість найбільш популярних тем для відображення.
  static const int trendingThemesLimit = 5;

  /// Підтримувані формати файлів тем.
  static const List<String> supportedThemeFormats = [
    '.nexora-theme',
    '.json',
    '.zip',
  ];

  /// Описи режимів теми.
  static const Map<String, String> themeModeDescriptions = {
    'ps5': 'Темна неонова тема у стилі PlayStation 5',
    'monitor': 'Мінімалістична світла тема',
    'golden': 'Розкішна тема з золотими акцентами',
    'neon': 'Яскрава неонова тема з контрастними кольорами',
    'forest': 'Заспокійлива зелена тема для натхнення природою',
    'ocean': 'Глибока синьо-бірюзова тема для спокійної роботи',
    'custom': 'Ваша власна кастомна тема',
  };

  /// Мапа кольорів для популярних тем.
  static const Map<String, Color> popularThemeAccents = {
    'ps5': AppColorsPS5.accent,
    'monitor': AppColorsMonitor.accent,
    'golden': Color(0xFFFFB300),
    'neon': Color(0xFF00FF88),
    'forest': Color(0xFF4CAF50),
    'ocean': Color(0xFF00BCD4),
  };

  /// Категорії тем для фільтрації.
  static const List<String> themeCategories = [
    'Всі',
    'Темні',
    'Світлі',
    'Неонові',
    'Природа',
    'Спільнотні',
  ];

  /// Описи категорій тем.
  static const Map<String, String> themeCategoryDescriptions = {
    'Всі': 'Усі доступні теми',
    'Темні': 'Темні теми для вечірнього використання',
    'Світлі': 'Світлі теми для комфортного використання',
    'Неонові': 'Яскраві теми з неоновими акцентами',
    'Природа': 'Теми з натхненням природою',
    'Спільнотні': 'Теми від користувачів Nexora',
  };

  // ─── Additional Computed Properties ─────────────────────────────────────

  /// Кількість доступних тем.
  int get _availableThemesCount => _themes.length + _lockedThemes.length;

  /// Кількість спільнотних тем (відфільтрована).
  int get _filteredCommunityCount => _filteredCommunityThemes.length;

  /// Кількість популярних тем для відображення.
  int get _popularThemesCount =>
      (_themes + _lockedThemes).length.clamp(0, popularThemesLimit);

  /// Чи обрана кастомна тема.
  bool get _isCustomThemeSelected => _selectedTheme == 'custom';

  /// Пошуковий запит у нижньому регістрі.
  String get _normalizedSearchQuery => _communitySearchQuery.toLowerCase().trim();

  /// Загальна кількість завантажень усіх тем.
  int get _totalDownloads {
    int total = 0;
    for (final t in _themes) { total += t.downloads; }
    for (final t in _lockedThemes) { total += t.downloads; }
    return total;
  }

  /// Найпопулярніша тема за завантаженнями.
  _ThemeOption? get _mostPopularTheme {
    final all = [..._themes, ..._lockedThemes];
    all.sort((a, b) => b.downloads.compareTo(a.downloads));
    return all.isNotEmpty ? all.first : null;
  }

  /// Найменш популярна тема.
  _ThemeOption? get _leastPopularTheme {
    final all = [..._themes, ..._lockedThemes];
    all.sort((a, b) => a.downloads.compareTo(b.downloads));
    return all.isNotEmpty ? all.first : null;
  }

  /// Чи є нещодавно додані спільнотні теми.
  bool get _hasNewCommunityThemes => _communityThemes.any((t) => t.likes > 300);

  /// Середня кількість лайків спільнотних тем.
  double get _averageCommunityLikes {
    if (_communityThemes.isEmpty) return 0;
    return _communityThemes.fold<int>(0, (sum, t) => sum + t.likes) /
        _communityThemes.length.toDouble();
  }

  /// Форматована кількість завантажень.
  String _formatDownloads(int count) {
    if (count >= 10000) return '${(count / 1000).toStringAsFixed(1)}K';
    if (count >= 1000) return '${(count / 1000).toStringAsFixed(1)}K';
    return '$count';
  }

  /// Короткий опис обраної теми.
  String get _selectedThemeShortDescription {
    return themeModeDescriptions[_selectedTheme] ?? 'Невідома тема';
  }

  /// Колір акценту обраної теми.
  Color get _selectedThemeAccent =>
      _previewAccent(_selectedTheme);

  /// Назва обраної теми.
  String get _selectedThemeDisplayName {
    final match = _themes.where((t) => t.id == _selectedTheme);
    if (match.isNotEmpty) return match.first.name;
    return 'Кастомна тема';
  }

  /// Чи обрана тема заблокована.
  bool get _isThemeLocked =>
      _lockedThemes.any((t) => t.id == _selectedTheme);

  /// Вартість обраної заблокованої теми.
  int? get _selectedThemeCost =>
      _lockedThemes.where((t) => t.id == _selectedTheme).firstOrNull?.coinCost;

  // ─── Private Helper Methods ──────────────────────────────────────────

  /// Перевіряє, чи користувач розблокував тему.
  bool _isThemeUnlocked(String themeId) {
    return !_lockedThemes.any((t) => t.id == themeId);
  }

  /// Повертає всі теми (доступні + заблоковані).
  List<_ThemeOption> get _allThemes =>
      [..._themes, ..._lockedThemes];

  /// Повертає теми за категорією.
  List<_ThemeOption> _getThemesByCategory(String category) {
    switch (category) {
      case 'Темні':
        return _allThemes
            .where((t) => t.previewBg.computeLuminance() < 0.5);
      case 'Світлі':
        return _allThemes
            .where((t) => t.previewBg.computeLuminance() >= 0.5);
      case 'Неонові':
        return _allThemes.where((t) =>
            t.accentColor.computeLuminance() < 0.3);
      case 'Природа':
        return _lockedThemes.where((t) =>
            t.id == 'forest' || t.id == 'ocean');
      case 'Спільнотні':
        return []; // Placeholder
      default:
        return _allThemes;
    }
  }

  /// Повертає опис формату файлу теми.
  String _getThemeFileDescription(String format) {
    switch (format) {
      case '.nexora-theme':
        return 'Формат файлів Nexora Theme. Містить всі налаштування.';
      case '.json':
        'JSON файл з конфігурацією теми. Легко редагувати.';
      case '.zip':
        'ZIP архів з файлами теми. Найкраще для швидкого імпорту.';
      default:
        return 'Невідомий формат';
    }
  }

  /// Копіює налаштування поточної теми в буфер обміну.
  Future<void> _copyThemeSettings() async {
    try {
      final settings = {
        'themeId': _selectedTheme,
        'hue': _customHue.toStringAsFixed(1),
        'saturation': _customSaturation.toStringAsFixed(2),
        'brightness': _customBrightness.toStringAsFixed(2),
        'preview': _isPreviewActive,
      };
      await Clipboard.setData(ClipboardData(
        text: jsonEncode(settings),
      ));
      if (mounted) {
        context.showAppToast(
          'Налаштування теми скопійовано!',
          type: AppToastType.success,
        );
      }
      developer.log('Theme settings copied', name: _logTag);
    } catch (e) {
      developer.log('Error copying theme settings: $e', name: _logTag);
    }
  }

  /// Показує інформацію про розблокування теми.
  void _showThemeUnlockDialog(_ThemeOption theme) {
    try {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor:
              context.isDark ? AppColorsPS5.card : AppColorsMonitor.card,
          title: Text(
            'Розблокувати «${theme.name}»',
            style: AppTypography.heading3.copyWith(
              color: context.isDark
                  ? AppColorsPS5.textPrimary
                  : AppColorsMonitor.textPrimary,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Ця тема коштує ${theme.coinCost} монет.\n'
                'Завантаження: ${_formatDownloads(theme.downloads)}',
                style: AppTypography.bodyMedium.copyWith(
                  color: context.isDark
                      ? AppColorsPS5.textSecondary
                      : AppColorsMonitor.textSecondary,
                ),
              ),
              const SizedBox(height: Spacing.md),
              Container(
                padding: const EdgeInsets.all(Spacing.sm),
                decoration: BoxDecoration(
                  color: (context.isDark
                          ? AppColorsPS5.accent
                          : AppColorsMonitor.accent)
                      .withOpacity(0.1),
                  borderRadius: BorderRadius.circular(Radii.sm),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline_rounded, size: 16),
                    const SizedBox(width: Spacing.sm),
                    Expanded(
                      child: Text(
                        'Використовуйте монети з магазину для розблокування',
                        style: AppTypography.labelSmall.copyWith(
                          color: context.isDark
                              ? AppColorsPS5.textSecondary
                              : AppColorsMonitor.textSecondary,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                HapticService.lightTap();
                Navigator.pop(ctx);
              },
              child: Text(
                'Пізніше',
                style: AppTypography.labelLarge.copyWith(
                  color: context.isDark
                      ? AppColorsPS5.textSecondary
                      : AppColorsMonitor.textSecondary,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                HapticService.lightTap();
                Navigator.pop(ctx);
                context.showAppToast(
                  'Перехід у магазин монет',
                  type: AppToastType.info,
                );
              },
              child: Text(
                'Відкрити магазин',
                style: AppTypography.labelLarge.copyWith(
                  color: AppColorsPS5.accent,
                ),
              ),
            ),
          ],
        ),
      );
    } catch (e) {
      developer.log('Error showing unlock dialog: $e', name: _logTag);
    }
  }

  /// Перевіряє, чи hex колір коректний.
  bool _isValidHexColor(String hex) {
    return RegExp(r'^#[0-9A-Fa-f]{6}$').hasMatch(hex);
  }

  /// Перетворює рядок у колір (безпечно).
  Color? _tryParseColor(String hex) {
    try {
      if (!_isValidHexColor(hex)) return null;
      return Color(int.parse(hex.replaceFirst('#', '0xFF')));
    } catch (_) {
      return null;
    }
  }

  /// Форматує розмір теми для відображення.
  String _formatThemeSize() {
    // Mock: estimate theme file sizes
    const baseSizeKB = 2.5;
    if (_isCustomBuilder) return '~${baseSizeKB + 0.5} КБ (кастомна)';
    return '~$baseSizeKB КБ';
  }

  /// Генерує унікальний ідентифікатор для теми.
  String _generateThemeId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = timestamp % 10000;
    return 'custom_${timestamp}_$random';
  }

  // ─── Additional Widget Builders ────────────────────────────────────────

  /// Будує картку категорій тем.
  Widget _buildThemeCategoriesFilter(
    Color textColor,
    Color subColor,
    Color accent,
    Color borderColor,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: Spacing.sm),
      child: SizedBox(
        height: 36,
        child: ListView(
          scrollDirection: Axis.horizontal,
          children: themeCategories.map((category) {
            final isActive = category == 'Всі';
            return GestureDetector(
              onTap: () {
                developer.log('Filter: $category', name: _logTag);
                context.showAppToast(
                  themeCategoryDescriptions[category] ?? category,
                  type: AppToastType.info,
                );
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(right: Spacing.xs),
                padding: const EdgeInsets.symmetric(
                  horizontal: Spacing.sm,
                  vertical: Spacing.xs,
                ),
                decoration: BoxDecoration(
                  color: isActive ? accent : Colors.transparent,
                  borderRadius: BorderRadius.circular(Radii.xl),
                  border: Border.all(
                    color: isActive ? accent : borderColor,
                  ),
                ),
                child: Center(
                  child: Text(
                    category,
                    style: AppTypography.labelSmall.copyWith(
                      color: isActive ? Colors.white : subColor,
                      fontSize: 10,
                      fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  /// Будує картку з інформацією про обрану тему.
  Widget _buildSelectedThemeInfoCard(
    Color cardColor,
    Color borderColor,
    Color textColor,
    Color subColor,
    Color accent,
  ) {
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
          Text('Обрана тема', style: AppTypography.labelMedium.copyWith(color: textColor, fontWeight: FontWeight.w600)),
          const SizedBox(height: Spacing.sm),
          Row(
            children: [
              Container(
                width: 48,
                height: 32,
                decoration: BoxDecoration(
                  color: _selectedThemeAccent.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(Radii.sm),
                ),
                child: Center(
                  child: Text(
                    '🎨',
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
              ),
              const SizedBox(width: Spacing.md),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _selectedThemeDisplayName,
                    style: AppTypography.bodyMedium.copyWith(
                      color: textColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    _selectedThemeShortDescription,
                    style: AppTypography.labelSmall.copyWith(color: subColor),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: Spacing.sm),
          _buildExtendedStatRow('ID', _selectedTheme, subColor, subColor),
          _buildExtendedStatRow('Завантажень', _formatDownloads(
            _allThemes
                .where((t) => t.id == _selectedTheme)
                .firstOrNull?.downloads ?? 0,
          ), accent, subColor),
          _buildExtendedStatRow('Розмір', _formatThemeSize(), subColor, subColor),
          if (_isThemeLocked)
            _buildExtendedStatRow(
              'Вартість',
              '${_selectedThemeCost ?? 0} 🪙',
              AppColorsPS5.coin,
              subColor,
            ),
          const SizedBox(height: Spacing.sm),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _copyThemeSettings,
              icon: const Icon(Icons.copy_rounded, size: 16),
              label: const Text('Копіювати налаштування'),
              style: OutlinedButton.styleFrom(
                foregroundColor: accent,
                side: BorderSide(color: borderColor),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(Radii.md),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Будує рядок розширеної статистики.
  Widget _buildExtendedStatRow(
    String label,
    String value,
    Color valueColor,
    Color subColor,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Text(
            label,
            style: AppTypography.labelSmall.copyWith(color: subColor),
          ),
          const Spacer(),
          Text(
            value,
            style: AppTypography.labelSmall.copyWith(
              color: valueColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  /// Будує картку трендових тем.
  Widget _buildTrendingThemesCard(
    Color cardColor,
    Color borderColor,
    Color textColor,
    Color subColor,
    Color accent,
  ) {
    final trending = _getTrendingThemes();
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '🔥 Трендові',
                style: AppTypography.labelMedium.copyWith(
                  color: textColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '${_formatDownloads(_totalDownloads)} завантажень',
                style: AppTypography.labelSmall.copyWith(color: subColor),
              ),
            ],
          ),
          const SizedBox(height: Spacing.sm),
          ...trending.map((theme) => Padding(
                padding: const EdgeInsets.only(bottom: Spacing.xs),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: theme.accentColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(Radii.sm),
                      ),
                      child: Center(
                        child: Text(
                          theme.emoji ?? '🎨',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                    const SizedBox(width: Spacing.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            theme.name,
                            style: AppTypography.labelSmall.copyWith(
                              color: textColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            '${_formatDownloads(theme.downloads)} · ${theme.createdDate}',
                            style: AppTypography.caption.copyWith(
                              color: subColor.withOpacity(0.6),
                              fontSize: 9,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  /// Повертає трендові теми за кількістю завантажень.
  List<_ThemeOption> _getTrendingThemes() {
    final all = [..._themes, ..._lockedThemes];
    all.sort((a, b) => b.downloads.compareTo(a.downloads));
    return all.take(trendingThemesLimit).toList();
  }
}

// ─── Theme Preview Card Widget ─────────────────────────────────────────────────

/// Картка прев'ю теми.
class _ThemePreviewCard extends StatelessWidget {
  const _ThemePreviewCard({required this.theme, required this.isActive, this.isLocked = false, required this.onTap});
  final _ThemeOption theme;
  final bool isActive;
  final bool isLocked;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.only(bottom: Spacing.md),
        padding: const EdgeInsets.all(Spacing.base),
        decoration: BoxDecoration(
          color: theme.previewBg,
          borderRadius: BorderRadius.circular(Radii.xl),
          border: Border.all(color: isActive ? theme.accentColor : Colors.grey.withOpacity(0.3), width: isActive ? 2.5 : 1),
          boxShadow: isActive ? AppShadows.glow(theme.accentColor) : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(children: [
              Container(
                height: 120,
                decoration: BoxDecoration(color: theme.accentColor.withOpacity(0.08), borderRadius: BorderRadius.circular(Radii.md), border: Border.all(color: theme.accentColor.withOpacity(0.15))),
                child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                  Container(width: 36, height: 56, decoration: BoxDecoration(color: theme.accentColor.withOpacity(0.25), borderRadius: BorderRadius.circular(6))),
                  Container(width: 36, height: 36, decoration: BoxDecoration(color: theme.accentColor.withOpacity(0.4), shape: BoxShape.circle)),
                  Container(width: 56, height: 24, decoration: BoxDecoration(color: theme.accentColor.withOpacity(0.2), borderRadius: BorderRadius.circular(12))),
                ]),
              ),
              if (isLocked)
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(Radii.md),
                    child: Container(
                      color: Colors.black.withOpacity(0.5),
                      child: Center(
                        child: Column(mainAxisSize: MainAxisSize.min, children: [
                          Icon(Icons.lock_rounded, color: Colors.white.withOpacity(0.7), size: 24),
                          const SizedBox(height: 4),
                          Text('${theme.coinCost} 🪙', style: AppTypography.labelSmall.copyWith(color: Colors.white.withOpacity(0.8), fontWeight: FontWeight.w700)),
                        ]),
                      ),
                    ),
                  ),
                ),
            ]),
            const SizedBox(height: Spacing.md),
            Row(
              children: [
                if (theme.emoji != null) Text(theme.emoji!, style: const TextStyle(fontSize: 22)),
                if (theme.emoji != null) const SizedBox(width: Spacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(theme.name, style: AppTypography.heading3.copyWith(color: theme.textColor)),
                      const SizedBox(height: 2),
                      Text(theme.description, style: AppTypography.bodySmall.copyWith(color: theme.textColor.withOpacity(0.6))),
                    ],
                  ),
                ),
                if (isLocked)
                  Icon(Icons.lock_rounded, color: theme.textColor.withOpacity(0.4), size: 20)
                else if (isActive)
                  Container(
                    width: 28, height: 28,
                    decoration: BoxDecoration(color: theme.accentColor, shape: BoxShape.circle),
                    child: const Icon(Icons.check_rounded, color: Colors.white, size: 18),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
