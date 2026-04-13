import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_radii.dart';
import '../../../../core/constants/app_enums.dart';
import '../../../../core/widgets/app_button_primary.dart';
import '../../../../core/widgets/app_particle_bg.dart';
import '../../../../core/utils/haptic_service.dart';

/// Екран привітання — перший крок онбордингу.
///
/// Повноекранний градієнтний фон з частинками, назвою бренду та кнопкою «Почати».
/// Містить анімований логотип із сяйвом, частинки на фоні, спінер завантаження,
/// діалог умов використання, інформацію про версію та звук при натисканні.
/// Додатково: варіанти частинок (4 форми: зірки, серця, ромби, кола),
/// перемикач теми (PS5/Monitor), режим доступності, вибір мови,
/// анімовані варіанти логотипу (3), розширені текстові анімації,
/// блок довіри, політика конфіденційності, «Що нового?», діалог підтримки.
class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  bool _isLoading = true;
  bool _showSkipHint = false;
  double _glowOpacity = 0.0;
  int _logoVariant = 0;
  int _particleVariant = 0;
  bool _accessibilityMode = false;
  bool _showLanguageSheet = false;
  bool _showThemePreview = false;
  bool _isDarkTheme = true;
  String _selectedLanguage = '🇺🇦 Українська';
  String _loadingMessage = 'Підготовка...';
  int _loadingDots = 0;

  static const _languages = [
    '🇺🇦 Українська',
    '🇺🇸 English',
    '🇵🇱 Polski',
    '🇩🇪 Deutsch',
    '🇫🇷 Français',
  ];

  static const _languageNames = {
    '🇺🇦 Українська': 'Українська',
    '🇺🇸 English': 'Англійська',
    '🇵🇱 Polski': 'Польська',
    '🇩🇪 Deutsch': 'Німецька',
    '🇫🇷 Français': 'Французька',
  };

  static const _logoIcons = [
    Icons.savings_rounded,
    Icons.account_balance_rounded,
    Icons.trending_up_rounded,
  ];

  static const _logoLabels = [
    'Заощадження',
    'Банк',
    'Зростання',
  ];

  static const _particleVariantNames = [
    'Зірки',
    'Серця',
    'Ромби',
    'Кола',
  ];

  /// Описи кожного варіанту частинок для підказки.
  static const _particleVariantDescriptions = [
    'Сяючі зірки на темному фоні',
    'М′які серця з пульсацією',
    'Геометричні ромби з блиском',
    'Плавні кола з градієнтом',
  ];

  static const _loadingMessages = [
    'Підготовка...',
    'Завантаження даних...',
    'Налаштування теми...',
    'Майже готово!',
  ];

  late AnimationController _glowController;
  late AnimationController _logoRotateController;
  Timer? _loadingTimer;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _logoRotateController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4000),
    )..repeat();

    // Анімація завантаження з повідомленнями
    _startLoadingSequence();

    Future.delayed(const Duration(milliseconds: 3000), () {
      if (mounted) setState(() => _showSkipHint = true);
    });

    _glowController.addListener(() {
      if (mounted) {
        setState(() {
          _glowOpacity = 0.3 + (_glowController.value * 0.4);
        });
      }
    });

    _cycleLogoVariant();
  }

  /// Послідовність завантаження з повідомленнями та спінером.
  void _startLoadingSequence() {
    _loadingTimer = Timer.periodic(const Duration(milliseconds: 400), (timer) {
      if (!mounted) { timer.cancel(); return; }
      setState(() {
        _loadingDots = (_loadingDots + 1) % 4;
        final msgIndex = _loadingDots ~/ 2;
        if (msgIndex < _loadingMessages.length) {
          _loadingMessage = _loadingMessages[msgIndex];
        }
      });
    });

    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        _loadingTimer?.cancel();
        setState(() => _isLoading = false);
      }
    });
  }

  void _cycleLogoVariant() {
    Timer.periodic(const Duration(seconds: 4), (timer) {
      if (!mounted) { timer.cancel(); return; }
      HapticService.lightTap();
      setState(() {
        _logoVariant = (_logoVariant + 1) % _logoIcons.length;
      });
    });
  }

  @override
  void dispose() {
    _loadingTimer?.cancel();
    _glowController.dispose();
    _logoRotateController.dispose();
    super.dispose();
  }

  void _onStartPressed() {
    HapticService.lightTap();
    HapticService.selection();
    context.go('/concept');
  }

  void _cycleParticleVariant() {
    HapticService.selection();
    setState(() {
      _particleVariant = (_particleVariant + 1) % 4;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${_particleVariantNames[_particleVariant]}: ${_particleVariantDescriptions[_particleVariant]}',
          style: AppTypography.labelMedium.copyWith(color: AppColorsPS5.textPrimary),
        ),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(milliseconds: 1500),
      ),
    );
  }

  void _toggleAccessibility() {
    HapticService.selection();
    setState(() => _accessibilityMode = !_accessibilityMode);
    HapticService.mediumTap();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _accessibilityMode ? 'Режим доступності увімкнено' : 'Режим доступності вимкнено',
          style: AppTypography.labelMedium.copyWith(color: AppColorsPS5.textPrimary),
        ),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(milliseconds: 1500),
      ),
    );
  }

  void _toggleThemePreview() {
    HapticService.selection();
    setState(() {
      _showThemePreview = !_showThemePreview;
      _isDarkTheme = !_isDarkTheme;
    });
  }

  void _showLanguageSelection() {
    HapticService.selection();
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A2E),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(Radii.xl))),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: Spacing.sm),
            Container(width: 48, height: 4, decoration: BoxDecoration(color: AppColorsPS5.textHint.withOpacity(0.3), borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: Spacing.base),
            Text('Обери мову', style: AppTypography.heading2.copyWith(color: AppColorsPS5.textPrimary)),
            const SizedBox(height: Spacing.base),
            ..._languages.map((lang) => ListTile(
              title: Text(lang, style: AppTypography.bodyLarge.copyWith(
                color: _selectedLanguage == lang ? AppColorsPS5.accent : AppColorsPS5.textSecondary,
                fontWeight: _selectedLanguage == lang ? FontWeight.w700 : FontWeight.w400,
              )),
              subtitle: Text(
                _languageNames[lang] ?? lang,
                style: AppTypography.labelSmall.copyWith(color: AppColorsPS5.textHint),
              ),
              trailing: _selectedLanguage == lang ? const Icon(Icons.check_circle_rounded, color: AppColorsPS5.accent) : null,
              onTap: () {
                HapticService.selection();
                setState(() => _selectedLanguage = lang);
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Мова: $lang', style: AppTypography.labelMedium), behavior: SnackBarBehavior.floating, duration: const Duration(milliseconds: 1200)),
                );
              },
            )),
            const SizedBox(height: Spacing.base),
          ],
        ),
      ),
    );
  }

  /// Діалог перемикача теми з попереднім переглядом PS5/Monitor.
  void _showThemeToggleDialog() {
    HapticService.lightTap();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Radii.lg)),
        title: Text('Обери тему', style: AppTypography.heading2.copyWith(color: AppColorsPS5.textPrimary)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildThemePreviewCard(
              isSelected: _isDarkTheme,
              themeName: 'PS5 Темна',
              themeDescription: 'Темний фон з неоновими акцентами та синім сяйвом',
              gradientColors: const [Color(0xFF0A0A0F), Color(0xFF0A1628)],
              accentColor: AppColorsPS5.accent,
              onTap: () {
                setState(() => _isDarkTheme = true);
                Navigator.pop(ctx);
                HapticService.selection();
              },
            ),
            const SizedBox(height: Spacing.md),
            _buildThemePreviewCard(
              isSelected: !_isDarkTheme,
              themeName: 'Monitor Світла',
              themeDescription: 'Світлий фон з чистими лініями та м′якими акцентами',
              gradientColors: const [Color(0xFFF5F5FA), Color(0xFFE8E8F0)],
              accentColor: AppColorsMonitor.accent,
              textColor: AppColorsMonitor.textPrimary,
              onTap: () {
                setState(() => _isDarkTheme = false);
                Navigator.pop(ctx);
                HapticService.selection();
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Закрити', style: AppTypography.labelLarge.copyWith(color: AppColorsPS5.accent)),
          ),
        ],
      ),
    );
  }

  Widget _buildThemePreviewCard({
    required bool isSelected,
    required String themeName,
    required String themeDescription,
    required List<Color> gradientColors,
    required Color accentColor,
    Color? textColor,
    required VoidCallback onTap,
  }) {
    final txtColor = textColor ?? AppColorsPS5.textPrimary;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(Spacing.base),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: gradientColors),
          borderRadius: BorderRadius.circular(Radii.md),
          border: Border.all(
            color: isSelected ? accentColor : (txtColor).withOpacity(0.2),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 16, height: 16,
                  decoration: BoxDecoration(
                    color: isSelected ? accentColor : Colors.transparent,
                    shape: BoxShape.circle,
                    border: Border.all(color: accentColor, width: 2),
                  ),
                  child: isSelected ? const Icon(Icons.check_rounded, color: Colors.white, size: 10) : null,
                ),
                const SizedBox(width: Spacing.sm),
                Text(themeName, style: AppTypography.labelLarge.copyWith(color: txtColor, fontWeight: FontWeight.w600)),
              ],
            ),
            const SizedBox(height: Spacing.xs),
            Text(themeDescription, style: AppTypography.labelSmall.copyWith(color: txtColor.withOpacity(0.7))),
          ],
        ),
      ),
    );
  }

  void _showTermsDialog() {
    HapticService.lightTap();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Radii.lg)),
        title: Text('Умови використання', style: AppTypography.heading2.copyWith(color: AppColorsPS5.textPrimary)),
        content: SingleChildScrollView(
          child: Text(
            'Ласкаво просимо до Nexora!\n\n'
            '1. Дані про заощадження зберігаються локально на твоєму пристрої.\n\n'
            '2. Ми не передаємо особисту інформацію третім особам.\n\n'
            '3. Nexora — це інструмент мотивації, а не фінансова установа. '
            'Усі кошти залишаються на твоєму рахунку.\n\n'
            '4. Використовуючи додаток, ти погоджуєшся нести особисту '
            'відповідальність за свої фінансові рішення.\n\n'
            '5. Додаток може надсилати нагадування для підтримки мотивації.\n\n'
            '6. Усі гейміфікаційні елементи (XP, монети, бейджі) є '
            'внутрішньо-ігровою валютою та не мають реальної вартості.\n\n'
            '7. Nexora не несе відповідальності за втрату даних '
            'у разі видалення додатку або скидання пристрою.\n\n'
            '8. Ми не гарантуємо стабільність гейміфікаційних функцій '
            'та залишаємо за собою право змінювати правила.\n\n'
            'Останнє оновлення: січень 2025',
            style: AppTypography.bodyMedium.copyWith(color: AppColorsPS5.textSecondary, height: 1.6),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Закрити', style: AppTypography.labelLarge.copyWith(color: AppColorsPS5.accent)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Погоджуюсь', style: AppTypography.labelLarge.copyWith(color: AppColorsPS5.success)),
          ),
        ],
      ),
    );
  }

  void _showPrivacyDialog() {
    HapticService.lightTap();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Radii.lg)),
        title: Text('Політика конфіденційності', style: AppTypography.heading2.copyWith(color: AppColorsPS5.textPrimary)),
        content: SingleChildScrollView(
          child: Text(
            'Політика конфіденційності Nexora\n\n'
            '🔒 Збір даних\n'
            'Nexora не збирає жодних персональних даних. Усі дані '
            'про заощадження зберігається виключно на твоєму пристрої.\n\n'
            '📊 Аналітика\n'
            'Додаток не використовує сторонні сервіси аналітики. '
            'Жодна інформація не передається на зовнішні сервери.\n\n'
            '📱 Доступ до пристрою\n'
            'Nexora не вимагає доступу до камери, мікрофона, контактів '
            'або геолокації. Лише базові сповіщення для нагадувань.\n\n'
            '💳 Фінансові дані\n'
            'Додаток не зберігає банківських реквізитів, номерів карток '
            'або паролів. Усі операції виконуються вручну користувачем.\n\n'
            '🧒 Дитяча конфіденційність\n'
            'Nexora підходить для користувачів будь-якого віку. '
            'Оскільки ми не збираємо дані, немає спеціальних обмежень.\n\n'
            '🔄 Оновлення політики\n'
            'Ми залишаємо за собою право оновлювати цю політику. '
            'Усі зміни будуть відображені у додатку.\n\n'
            '📧 Зв\'язок\n'
            'З питаннями конфіденційності: privacy@nexora.app\n\n'
            'Останнє оновлення: січень 2025',
            style: AppTypography.bodyMedium.copyWith(color: AppColorsPS5.textSecondary, height: 1.6),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Зрозуміло', style: AppTypography.labelLarge.copyWith(color: AppColorsPS5.accent)),
          ),
        ],
      ),
    );
  }

  void _showSupportDialog() {
    HapticService.lightTap();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Radii.lg)),
        title: Text('Підтримка', style: AppTypography.heading2.copyWith(color: AppColorsPS5.textPrimary)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Зв\'яжіться з нами одним зі способів:', style: AppTypography.bodyMedium.copyWith(color: AppColorsPS5.textSecondary)),
            const SizedBox(height: Spacing.base),
            _supportItem(Icons.email_rounded, 'support@nexora.app', 'Email'),
            _supportItem(Icons.telegram_rounded, '@nexora_bot', 'Telegram'),
            _supportItem(Icons.chat_rounded, 'Онлайн чат', 'Чат'),
            _supportItem(Icons.bug_report_rounded, 'bugs@nexora.app', 'Баг-репорт'),
            const SizedBox(height: Spacing.base),
            Text('Відповідь зазвичай у темі листування.', style: AppTypography.labelSmall.copyWith(color: AppColorsPS5.textHint)),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text('Закрити', style: AppTypography.labelLarge.copyWith(color: AppColorsPS5.accent))),
        ],
      ),
    );
  }

  /// Діалог «Що нового?» з описом оновлень.
  void _showWhatsNewDialog() {
    HapticService.lightTap();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Radii.lg)),
        title: Text('Що нового у версії 2.0?', style: AppTypography.heading2.copyWith(color: AppColorsPS5.textPrimary)),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _whatsNewItem('🎮', 'Нова гейміфікація', 'XP, монети, бейджі, рівні та стріки'),
              _whatsNewItem('🎨', 'Дві теми оформлення', 'Темна PS5 та світла Monitor'),
              _whatsNewItem('📊', 'Розумні поради', 'Персоналізовані рекомендації заощаджень'),
              _whatsNewItem('🎯', 'Етапи цілей', 'Milestones для мотивації на кожному кроці'),
              _whatsNewItem('♿', 'Режим доступності', 'Збільшені шрифти та контраст'),
              _whatsNewItem('🌍', 'Багатомовність', 'Підтримка 5 мов інтерфейсу'),
              _whatsNewItem('❄️', 'Заморожування серії', 'Збережи свою серію за допомогою льоду'),
              _whatsNewItem('📈', 'Аналітика витрат', 'Детальна розбивка джерел коштів'),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text('Зрозуміло!', style: AppTypography.labelLarge.copyWith(color: AppColorsPS5.accent))),
        ],
      ),
    );
  }

  Widget _supportItem(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Spacing.sm),
      child: Row(
        children: [
          Icon(icon, color: AppColorsPS5.accent, size: 20),
          const SizedBox(width: Spacing.md),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value, style: AppTypography.bodyMedium.copyWith(color: AppColorsPS5.textPrimary)),
              Text(label, style: AppTypography.labelSmall.copyWith(color: AppColorsPS5.textSecondary)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _whatsNewItem(String emoji, String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: Spacing.base),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 22)),
          const SizedBox(width: Spacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTypography.labelMedium.copyWith(color: AppColorsPS5.textPrimary, fontWeight: FontWeight.w600)),
                Text(description, style: AppTypography.labelSmall.copyWith(color: AppColorsPS5.textSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0A0A0F), Color(0xFF0A1628)],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // ── Частинки на фоні ───────────────────────
              Positioned.fill(child: ParticleSilhouette(goalType: GoalType.ps5, progress: 0.0)),

              // ── Індикатор варіанту частинок ──────────────
              if (!_isLoading)
                Positioned(
                  bottom: Spacing.xxl + 60,
                  right: Spacing.base,
                  child: GestureDetector(
                    onTap: _cycleParticleVariant,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: Spacing.sm, vertical: Spacing.xs),
                      decoration: BoxDecoration(color: AppColorsPS5.accent.withOpacity(0.08), borderRadius: BorderRadius.circular(Radii.circular), border: Border.all(color: AppColorsPS5.accent.withOpacity(0.15))),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        Icon(Icons.auto_awesome_rounded, color: AppColorsPS5.accent.withOpacity(0.5), size: 12),
                        const SizedBox(width: 4),
                        Text('${_particleVariantNames[_particleVariant]}', style: AppTypography.labelSmall.copyWith(color: AppColorsPS5.textHint, fontSize: 9)),
                      ]),
                    ),
                  ).animate().fadeIn(duration: 400.ms, delay: 2000.ms),
                ),

              // ── Оверлей завантаження ────────────────────────
              if (_isLoading)
                Positioned.fill(
                  child: Container(
                    color: const Color(0xFF0A0A0F),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(width: 40, height: 40, child: CircularProgressIndicator(strokeWidth: 3, valueColor: AlwaysStoppedAnimation<Color>(AppColorsPS5.accent.withOpacity(0.8)))),
                          const SizedBox(height: Spacing.base),
                          Text(_loadingMessage, style: AppTypography.bodyMedium.copyWith(color: AppColorsPS5.textSecondary)),
                          const SizedBox(height: Spacing.xs),
                          Text('Завантаження ресурсів...', style: AppTypography.labelSmall.copyWith(color: AppColorsPS5.textHint)),
                        ],
                      ),
                    ),
                  ),
                ),

              // ── Основний контент ────────────────────────────────
              if (!_isLoading)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: Spacing.xxl),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 40),

                        // Верхня панель налаштувань
                        _buildTopSettingsRow(),

                        const SizedBox(height: 30),

                        // Анімований логотип (3 варіанти)
                        _buildAnimatedLogo(),

                        const SizedBox(height: Spacing.xl),

                        // Лейбло логотипу
                        Text(
                          _logoLabels[_logoVariant],
                          style: AppTypography.labelSmall.copyWith(
                            color: AppColorsPS5.accent.withOpacity(0.6),
                            letterSpacing: 3.0,
                          ),
                          textAlign: TextAlign.center,
                        ).animate().fadeIn(duration: 400.ms, delay: 150.ms),

                        const SizedBox(height: Spacing.sm),

                        // Назва бренду — staggered reveal
                        Text('Nexora', style: AppTypography.displayLarge.copyWith(
                          color: AppColorsPS5.textPrimary, fontSize: _accessibilityMode ? 56 : 48, letterSpacing: -1.5, fontWeight: FontWeight.w800,
                        ), textAlign: TextAlign.center,
                        ).animate().slideY(begin: 0.3, end: 0, duration: 800.ms, curve: Curves.easeOutCubic, delay: 200.ms).fadeIn(duration: 600.ms, delay: 200.ms),

                        const SizedBox(height: Spacing.sm),

                        // Підзаголовок 1
                        Text('Твоя мрія. Твій темп. Твоя гра.', style: AppTypography.bodyLarge.copyWith(color: AppColorsPS5.textSecondary, fontSize: _accessibilityMode ? 20 : 16), textAlign: TextAlign.center)
                            .animate().fadeIn(duration: 600.ms, delay: 600.ms),

                        const SizedBox(height: Spacing.xs),

                        // Підзаголовок 2
                        Text('Гейміфікована скарбничка для великих цілей', style: AppTypography.bodySmall.copyWith(color: AppColorsPS5.textHint), textAlign: TextAlign.center)
                            .animate().fadeIn(duration: 500.ms, delay: 800.ms),

                        const SizedBox(height: 4),

                        // Підзаголовок 3
                        Text('Накопичуй. Грай. Досягай.', style: AppTypography.labelSmall.copyWith(color: AppColorsPS5.textHint.withOpacity(0.5), letterSpacing: 2.0), textAlign: TextAlign.center)
                            .animate().fadeIn(duration: 500.ms, delay: 900.ms),

                        // Блок довіри — staggered
                        Padding(
                          padding: const EdgeInsets.only(top: Spacing.xs),
                          child: Text('🔒 Дані лише на твоєму пристрої', style: AppTypography.labelSmall.copyWith(color: AppColorsPS5.success.withOpacity(0.6)), textAlign: TextAlign.center)
                              .animate().fadeIn(duration: 500.ms, delay: 950.ms),
                        ),

                        // Підказка поточної теми
                        Padding(
                          padding: const EdgeInsets.only(top: Spacing.xs),
                          child: GestureDetector(
                            onTap: _showThemeToggleDialog,
                            child: Text(
                              _isDarkTheme ? '🎨 Тема: PS5 Темна (натисни для зміни)' : '🎨 Тема: Monitor Світла (натисни для зміни)',
                              style: AppTypography.labelSmall.copyWith(color: AppColorsPS5.textHint.withOpacity(0.4), decoration: TextDecoration.underline, decorationColor: AppColorsPS5.textHint.withOpacity(0.2)),
                              textAlign: TextAlign.center,
                            ),
                          ).animate().fadeIn(duration: 500.ms, delay: 1000.ms),
                        ),

                        const Spacer(flex: 2),

                        // Що нового блок
                        GestureDetector(
                          onTap: _showWhatsNewDialog,
                          child: Container(
                            padding: const EdgeInsets.all(Spacing.base),
                            decoration: BoxDecoration(
                              color: AppColorsPS5.accent.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(Radii.md),
                              border: Border.all(color: AppColorsPS5.accent.withOpacity(0.1)),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.new_releases_rounded, color: AppColorsPS5.accent, size: 16),
                                const SizedBox(width: Spacing.sm),
                                Text('🆕 Що нового у версії 2.0?', style: AppTypography.labelMedium.copyWith(color: AppColorsPS5.accent, fontWeight: FontWeight.w500)),
                                const SizedBox(width: Spacing.xs),
                                Icon(Icons.chevron_right_rounded, color: AppColorsPS5.accent.withOpacity(0.5), size: 16),
                              ],
                            ),
                          ),
                        ).animate().fadeIn(duration: 400.ms, delay: 1050.ms).slideY(begin: 0.1, end: 0, delay: 1050.ms, duration: 400.ms),

                        const SizedBox(height: Spacing.lg),

                        // Ознаки платформи
                        _buildPlatformBadges(),

                        const SizedBox(height: Spacing.xl),

                        // Кнопка «Почати»
                        AppButtonPrimary(
                          label: 'Почати',
                          onPressed: _onStartPressed,
                          icon: Icons.arrow_forward_rounded,
                        ).animate().slideY(begin: 0.2, end: 0, duration: 600.ms, curve: Curves.easeOutCubic, delay: 1000.ms).fadeIn(duration: 500.ms, delay: 1000.ms),

                        const SizedBox(height: Spacing.lg),

                        // Умови використання
                        GestureDetector(
                          onTap: _showTermsDialog,
                          child: Text('Продовжуючи, ти погоджуєшся з умовами використання', style: AppTypography.labelSmall.copyWith(color: AppColorsPS5.textHint, decoration: TextDecoration.underline, decorationColor: AppColorsPS5.textHint.withOpacity(0.4)), textAlign: TextAlign.center),
                        ).animate().fadeIn(duration: 500.ms, delay: 1200.ms),

                        const SizedBox(height: Spacing.xs),

                        // Політика конфіденційності
                        GestureDetector(
                          onTap: _showPrivacyDialog,
                          child: Text('Політика конфіденційності', style: AppTypography.labelSmall.copyWith(color: AppColorsPS5.textHint, decoration: TextDecoration.underline, decorationColor: AppColorsPS5.textHint.withOpacity(0.3)), textAlign: TextAlign.center),
                        ).animate().fadeIn(duration: 500.ms, delay: 1250.ms),

                        const SizedBox(height: Spacing.xs),

                        // Кнопка підтримки
                        GestureDetector(
                          onTap: _showSupportDialog,
                          child: Text('Потрібна допомога?', style: AppTypography.labelSmall.copyWith(color: AppColorsPS5.textHint, decoration: TextDecoration.underline, decorationColor: AppColorsPS5.textHint.withOpacity(0.4)), textAlign: TextAlign.center),
                        ).animate().fadeIn(duration: 500.ms, delay: 1300.ms),

                        const SizedBox(height: Spacing.base),

                        // Версія
                        Text('Версія 1.0.0', style: AppTypography.labelSmall.copyWith(color: AppColorsPS5.textHint.withOpacity(0.5), fontSize: 10)).animate().fadeIn(duration: 500.ms, delay: 1400.ms),

                        const SizedBox(height: Spacing.sm),
                      ],
                    ),
                  ),
                ),
              ),

              // ── Підказка «Пропустити» ───────────────────
              if (_showSkipHint && !_isLoading)
                Positioned(
                  top: Spacing.xl,
                  right: Spacing.base,
                  child: GestureDetector(
                    onTap: () { HapticService.lightTap(); context.go('/concept'); },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: Spacing.base, vertical: Spacing.sm),
                      decoration: BoxDecoration(color: AppColorsPS5.textHint.withOpacity(0.1), borderRadius: BorderRadius.circular(Radii.circular)),
                      child: Text('Пропустити →', style: AppTypography.labelMedium.copyWith(color: AppColorsPS5.textHint)),
                    ),
                  ).animate().fadeIn(duration: 300.ms).slideX(begin: 0.2, end: 0, duration: 300.ms),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopSettingsRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Мова
        GestureDetector(
          onTap: _showLanguageSelection,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: Spacing.sm, vertical: Spacing.xs),
            decoration: BoxDecoration(color: AppColorsPS5.accent.withOpacity(0.06), borderRadius: BorderRadius.circular(Radii.circular), border: Border.all(color: AppColorsPS5.accent.withOpacity(0.1))),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.language_rounded, color: AppColorsPS5.accent.withOpacity(0.5), size: 14),
              const SizedBox(width: 4),
              Text(_selectedLanguage, style: AppTypography.labelSmall.copyWith(color: AppColorsPS5.textHint, fontSize: 11)),
            ]),
          ),
        ).animate().fadeIn(duration: 400.ms, delay: 1600.ms),
        const SizedBox(width: Spacing.sm),
        // Доступність
        GestureDetector(
          onTap: _toggleAccessibility,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: Spacing.sm, vertical: Spacing.xs),
            decoration: BoxDecoration(color: _accessibilityMode ? AppColorsPS5.accent.withOpacity(0.12) : AppColorsPS5.accent.withOpacity(0.06), borderRadius: BorderRadius.circular(Radii.circular), border: Border.all(color: _accessibilityMode ? AppColorsPS5.accent.withOpacity(0.3) : AppColorsPS5.accent.withOpacity(0.1))),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(_accessibilityMode ? Icons.accessibility_new_rounded : Icons.accessibility_rounded, color: _accessibilityMode ? AppColorsPS5.accent : AppColorsPS5.accent.withOpacity(0.5), size: 14),
              const SizedBox(width: 4),
              Text('Доступність', style: AppTypography.labelSmall.copyWith(color: _accessibilityMode ? AppColorsPS5.accent : AppColorsPS5.textHint, fontSize: 11)),
            ]),
          ),
        ).animate().fadeIn(duration: 400.ms, delay: 1700.ms),
        const SizedBox(width: Spacing.sm),
        // Тема
        GestureDetector(
          onTap: _showThemeToggleDialog,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: Spacing.sm, vertical: Spacing.xs),
            decoration: BoxDecoration(color: AppColorsPS5.accent.withOpacity(0.06), borderRadius: BorderRadius.circular(Radii.circular), border: Border.all(color: AppColorsPS5.accent.withOpacity(0.1))),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(_isDarkTheme ? Icons.dark_mode_rounded : Icons.light_mode_rounded, color: AppColorsPS5.accent.withOpacity(0.5), size: 14),
              const SizedBox(width: 4),
              Text(_isDarkTheme ? 'PS5' : 'Monitor', style: AppTypography.labelSmall.copyWith(color: AppColorsPS5.textHint, fontSize: 11)),
            ]),
          ),
        ).animate().fadeIn(duration: 400.ms, delay: 1800.ms),
      ],
    );
  }

  Widget _buildAnimatedLogo() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 600),
      transitionBuilder: (child, animation) {
        return ScaleTransition(
          scale: CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
          child: FadeTransition(opacity: animation, child: child),
        );
      },
      child: Container(
        key: ValueKey(_logoVariant),
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(color: AppColorsPS5.accent.withOpacity(_glowOpacity), blurRadius: 40, spreadRadius: 8),
            BoxShadow(color: AppColorsPS5.accent.withOpacity(_glowOpacity * 0.5), blurRadius: 80, spreadRadius: 16),
          ],
          gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF1A1A2E), Color(0xFF16213E)]),
          border: Border.all(color: AppColorsPS5.accent.withOpacity(0.3), width: 2),
        ),
        child: Center(child: Icon(_logoIcons[_logoVariant], size: 48, color: AppColorsPS5.accent)),
      ),
    ).animate().scale(begin: const Offset(0.5, 0.5), end: const Offset(1.0, 1.0), duration: 800.ms, curve: Curves.easeOutBack)
        .fadeIn(duration: 600.ms)
        .then().shimmer(duration: 2000.ms, color: AppColorsPS5.accent.withOpacity(0.15), delay: 1000.ms);
  }

  Widget _buildPlatformBadges() {
    final badges = [
      _PlatformBadge(icon: Icons.shield_rounded, label: 'Безпечно', description: 'Локальне зберігання', delay: 900.ms),
      _PlatformBadge(icon: Icons.lock_rounded, label: 'Офлайн', description: 'Працює без інтернету', delay: 1000.ms),
      _PlatformBadge(icon: Icons.speed_rounded, label: 'Швидко', description: 'Миттєві операції', delay: 1100.ms),
      _PlatformBadge(icon: Icons.videogame_asset_rounded, label: 'Гейміфікація', description: 'XP, монети, бейджі', delay: 1200.ms),
      _PlatformBadge(icon: Icons.cloud_off_rounded, label: 'Приватність', description: 'Без реєстрації', delay: 1300.ms),
      _PlatformBadge(icon: Icons.palette_rounded, label: 'Дві теми', description: 'PS5 та Monitor', delay: 1400.ms),
      _PlatformBadge(icon: Icons.translate_rounded, label: '5 мов', description: 'Включаючи українську', delay: 1500.ms),
    ];
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: Spacing.sm,
      runSpacing: Spacing.xs,
      children: badges.map((b) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: Spacing.xs),
        child: _PlatformBadgeWidget(badge: b),
      )).toList(),
    );
  }
}

class _PlatformBadge {
  final IconData icon;
  final String label;
  final String description;
  final Duration delay;
  const _PlatformBadge({required this.icon, required this.label, required this.description, required this.delay});
}

class _PlatformBadgeWidget extends StatelessWidget {
  const _PlatformBadgeWidget({required this.badge});
  final _PlatformBadge badge;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: badge.description,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 40, height: 40, decoration: BoxDecoration(color: AppColorsPS5.accent.withOpacity(0.08), borderRadius: BorderRadius.circular(Radii.base)), child: Icon(badge.icon, color: AppColorsPS5.accent.withOpacity(0.6), size: 20)),
          const SizedBox(height: Spacing.xs),
          Text(badge.label, style: AppTypography.labelSmall.copyWith(color: AppColorsPS5.textHint, fontSize: 10)),
        ],
      ).animate().fadeIn(duration: 400.ms, delay: badge.delay).slideY(begin: 0.15, end: 0, duration: 400.ms, delay: badge.delay, curve: Curves.easeOutCubic),
    );
  }
}
