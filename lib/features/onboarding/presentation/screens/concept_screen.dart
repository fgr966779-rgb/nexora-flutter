import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_radii.dart';
import '../../../../core/constants/app_shadows.dart';
import '../../../../core/widgets/app_button_primary.dart';
import '../../../../core/widgets/app_button_secondary.dart';
import '../../../../core/utils/haptic_service.dart';

/// Екран «Як це працює?» — пояснення концепції додатку.
///
/// Містить 4 картки кроків з послідовною анімацією появи,
/// лічильник кроків з анімацією, кнопку пропуску,
/// індикатор прогресу, розгортання карток, інтерактивні
/// демо-елементи, прогрес між кроками, анімовані іконки,
/// чат-підказки, детальні поради, FAQ секцію, навігаційні стрілки,
/// мотиваційні цитати, ефекти паралаксу.
class ConceptScreen extends StatefulWidget {
  const ConceptScreen({super.key});

  @override
  State<ConceptScreen> createState() => _ConceptScreenState();
}

class _ConceptScreenState extends State<ConceptScreen>
    with TickerProviderStateMixin {
  int _expandedCard = -1;
  int _animatedStep = 0;
  Timer? _stepTimer;
  bool _showDemoPreview = false;
  int _demoProgress = 0;
  Timer? _demoTimer;
  bool _showFaq = false;
  String _currentQuoteIndex = '0';
  Timer? _quoteTimer;

  late AnimationController _parallaxController;

  /// Мотиваційні цитати для демонстрації концепції.
  static const _motivationalQuotes = [
    'Кожен внесок — крок до мрії!',
    'Маленькі суми роблять великі результати',
    'Накопичуй послідовно — отримай бонуси!',
    'Твій прогрес — твоя гордість',
  ];

  /// Часто запитувані питання.
  static const _faqItems = [
    _FaqItem(
      question: 'Чи безкоштовно користуватися?',
      answer: 'Так! Nexora повністю безкоштовна. Ти нічого не втрачаєш.',
      icon: Icons.lock_open_rounded,
    ),
    _FaqItem(
      question: 'Чи безпечні мої кошти?',
      answer: 'Абсолютно! Дані захищені банківським рівнем шифрування.',
      icon: Icons.security_rounded,
    ),
    _FaqItem(
      question: 'Як працює автоматичне округлення?',
      answer: 'Кожну покупку ми округлюємо до 10 грн, різниця йде у скарбничку.',
      icon: Icons.autorenew_rounded,
    ),
    _FaqItem(
      question: 'Чи можна змінити ціль?',
      answer: 'Так! У будь-який момент у налаштуваннях.',
      icon: Icons.swap_horiz_rounded,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _parallaxController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat(reverse: true);

    // Анімація лічильника кроків — послідовно 01, 02, 03.
    _stepTimer = Timer.periodic(const Duration(milliseconds: 600), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        _animatedStep++;
        if (_animatedStep >= 3) timer.cancel();
      });
    });

    // Цикл мотиваційних цитат
    _quoteTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        _currentQuoteIndex = (int.parse(_currentQuoteIndex) + 1)
            .toString();
        if (int.parse(_currentQuoteIndex) >= _motivationalQuotes.length) {
          _currentQuoteIndex = '0';
        }
      });
    });
  }

  @override
  void dispose() {
    _stepTimer?.cancel();
    _demoTimer?.cancel();
    _quoteTimer?.cancel();
    _parallaxController.dispose();
    super.dispose();
  }

  /// Перемикнути розгорнуту картку кроку.
  void _toggleCard(int index) {
    HapticService.selection();
    setState(() {
      _expandedCard = _expandedCard == index ? -1 : index;
    });
  }

  /// Запустити інтерактивне демо прогресу.
  void _startDemoProgress() {
    HapticService.lightTap();
    setState(() {
      _showDemoPreview = !_showDemoPreview;
      _demoProgress = 0;
    });
    if (_showDemoPreview) {
      _demoTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
        if (!mounted) {
          timer.cancel();
          return;
        }
        setState(() {
          _demoProgress += 2;
          if (_demoProgress >= 100) {
            _demoProgress = 100;
            timer.cancel();
            HapticService.success();
          }
        });
      });
    } else {
      _demoTimer?.cancel();
    }
  }

  /// Перемкнути FAQ секцію.
  void _toggleFaq() {
    HapticService.lightTap();
    setState(() => _showFaq = !_showFaq);
  }

  void _onNextPressed() {
    HapticService.lightTap();
    context.go('/choose-goal');
  }

  void _onSkipPressed() {
    HapticService.lightTap();
    context.go('/choose-goal');
  }

  void _onFaqItemTap(int index) {
    HapticService.lightTap();
    setState(() {
      if (_expandedCard == index + 10) {
        _expandedCard = -1;
      } else {
        _expandedCard = index + 10;
      }
    });
  }

  void _shareApp() {
    HapticService.mediumTap();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '📎 Посилання скопійовано в буфер обміну!',
          style: AppTypography.labelMedium.copyWith(
            color: AppColorsPS5.textPrimary,
          ),
        ),
        duration: const Duration(milliseconds: 2000),
        behavior: SnackBarBehavior.floating,
      ),
    );
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
            // ── Індикатор прогресу (крок 1 з 4) ──────────────────
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
                      'Як це працює?',
                      style: AppTypography.displayMedium.copyWith(
                        color: isLight
                            ? AppColorsMonitor.textPrimary
                            : AppColorsPS5.textPrimary,
                      ),
                    ).animate().fadeIn(duration: 500.ms),

                    const SizedBox(height: Spacing.sm),

                    Text(
                      'Три прості кроки до твоєї мрії',
                      style: AppTypography.bodyMedium.copyWith(
                        color: isLight
                            ? AppColorsMonitor.textSecondary
                            : AppColorsPS5.textSecondary,
                      ),
                    ).animate().fadeIn(duration: 500.ms, delay: 100.ms),

                    // ── Мотиваційна цитата з циклу ──────────────
                    const SizedBox(height: Spacing.md),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 400),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: Spacing.md,
                          vertical: Spacing.sm,
                        ),
                        decoration: BoxDecoration(
                          color: (isLight
                                  ? AppColorsMonitor.accent
                                  : AppColorsPS5.accent)
                              .withOpacity(0.06),
                          borderRadius: BorderRadius.circular(Radii.md),
                          border: Border.all(
                            color: (isLight
                                    ? AppColorsMonitor.accent
                                    : AppColorsPS5.accent)
                                .withOpacity(0.12),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.format_quote_rounded,
                              color: isLight
                                  ? AppColorsMonitor.accent
                                  : AppColorsPS5.accent,
                              size: 16,
                            ),
                            const SizedBox(width: Spacing.sm),
                            Expanded(
                              child: Text(
                                _motivationalQuotes[
                                    int.parse(_currentQuoteIndex)],
                                style: AppTypography.labelSmall.copyWith(
                                  color: isLight
                                      ? AppColorsMonitor.textSecondary
                                      : AppColorsPS5.textSecondary,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ).animate().fadeIn(duration: 300.ms, delay: 150.ms),

                    // ── Анімований лічильник кроків ────────────────
                    const SizedBox(height: Spacing.xl),
                    _buildStepCounter(isLight),

                    const SizedBox(height: Spacing.xxl),

                    // ── Картка 1 ───────────────────────────────
                    _ExpandableStepCard(
                      number: '01',
                      displayNumber: _animatedStep >= 1 ? '01' : '00',
                      icon: Icons.flag_rounded,
                      secondaryIcon: Icons.explore_rounded,
                      title: 'Обери свою ціль',
                      description:
                          'PlayStation 5, новий монітор або будь-що інше — ти обираєш, куди ведеш',
                      expandedDescription:
                          'У Nexora ти можеш обрати одну із заздалегідь налаштованих цілей '
                          '(PS5, монітор) або створити власну. Кожна ціль має унікальний '
                          'візуальний стиль — від темної неонової теми PS5 до світлої '
                          'мінідальної теми монітора. Ти також можеш додати підцілі: '
                          'геймпад, навушники чи підписку на сервіс.',
                      expandedTip:
                          '💡 Порада: обери реалістичну суму — так легше залишатись мотивованим!',
                      isLight: isLight,
                      delay: 0.ms,
                      isExpanded: _expandedCard == 0,
                      onTap: () => _toggleCard(0),
                    ),

                    const SizedBox(height: Spacing.md),

                    // ── Картка 2 ───────────────────────────────
                    _ExpandableStepCard(
                      number: '02',
                      displayNumber: _animatedStep >= 2 ? '02' : '01',
                      icon: Icons.schedule_rounded,
                      secondaryIcon: Icons.repeat_rounded,
                      title: 'Відкладай у своєму темпі',
                      description:
                          'Ручні внески, автоматичне округлення витрат або регулярні автоплатежі',
                      expandedDescription:
                          'Внески можна робити вручну у будь-який момент. Також доступне '
                          'автоматичне округлення — кожну покупку ми округлимо до найближчих '
                          '10 грн, а різницю відправимо у скарбничку. Автоплатежі дозволяють '
                          'налаштувати регулярні внески: щоденно, щотижня або щомісяця.',
                      expandedTip:
                          '💡 Порада: налаштуй автоплатеж для автоматичного накопичення!',
                      isLight: isLight,
                      delay: 150.ms,
                      isExpanded: _expandedCard == 1,
                      onTap: () => _toggleCard(1),
                    ),

                    const SizedBox(height: Spacing.md),

                    // ── Картка 3 ───────────────────────────────
                    _ExpandableStepCard(
                      number: '03',
                      displayNumber: _animatedStep >= 3 ? '03' : '02',
                      icon: Icons.trending_up_rounded,
                      secondaryIcon: Icons.emoji_events_rounded,
                      title: 'Дивись, як збирається мрія',
                      description:
                          'Кожен внесок наближає тебе до цілі — бачиш прогрес у реальному часі',
                      expandedDescription:
                          'Прогрес візуалізується у реальному часі за допомогою частинок, '
                          'які заповнюють силует твоєї цілі. За активність ти отримуєш XP, '
                          'монети, бейджі та серію днів. Виклики та мікро-цілі роблять '
                          'накопичення захопливим гейміфікованим досвідом!',
                      expandedTip:
                          '💡 Порада: поділися прогресом з друзями для додаткової мотивації!',
                      isLight: isLight,
                      delay: 300.ms,
                      isExpanded: _expandedCard == 2,
                      onTap: () => _toggleCard(2),
                    ),

                    const SizedBox(height: Spacing.xl),

                    // ── Інтерактивне демо прогресу ──────────────
                    _buildInteractiveDemo(isLight),

                    const SizedBox(height: Spacing.xl),

                    // ── Статистика користувачів ──────────────────
                    _buildSocialProof(isLight),

                    const SizedBox(height: Spacing.xxl),

                    // ── FAQ секція ───────────────────────────
                    _buildFaqSection(isLight),

                    const SizedBox(height: Spacing.lg),

                    // ── Кнопка «Далі» ──────────────────────────
                    Center(
                      child: AppButtonPrimary(
                        label: 'Далі',
                        onPressed: _onNextPressed,
                        isLightTheme: isLight,
                      )
                          .animate(target: 1)
                          .fadeIn(duration: 500.ms, delay: 500.ms)
                          .scale(
                            begin: const Offset(0.95, 0.95),
                            end: const Offset(1.0, 1.0),
                            duration: 500.ms,
                            delay: 500.ms,
                            curve: Curves.easeOutBack,
                          ),
                    ),

                    const SizedBox(height: Spacing.md),

                    // ── Кнопка «Пропустити» ──────────────────────
                    Center(
                      child: AppButtonSecondary(
                        label: 'Пропустити',
                        isLightTheme: isLight,
                        onPressed: _onSkipPressed,
                      ).animate().fadeIn(duration: 500.ms, delay: 600.ms),
                    ),

                    const SizedBox(height: Spacing.lg),

                    // ── Кнопка «Поділитися» ──────────────────
                    Center(
                      child: TextButton.icon(
                        onPressed: _shareApp,
                        icon: Icon(
                          Icons.share_rounded,
                          color: isLight
                              ? AppColorsMonitor.accent
                              : AppColorsPS5.accent,
                          size: 16,
                        ),
                        label: Text(
                          'Поділитися з друзями про Nexora',
                          style: AppTypography.labelMedium.copyWith(
                            color: isLight
                                ? AppColorsMonitor.accent
                                : AppColorsPS5.accent,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ).animate().fadeIn(duration: 400.ms, delay: 700.ms),

                    // ── Нумерація сторінки ─────────────────────
                    const SizedBox(height: Spacing.md),
                    Center(
                      child: Text(
                        '1 / 3',
                        style: AppTypography.caption.copyWith(
                          color: (isLight
                                  ? AppColorsMonitor.textHint
                                  : AppColorsPS5.textHint)
                              .withOpacity(0.5),
                        ),
                      ),
                    ).animate().fadeIn(duration: 300.ms, delay: 800.ms),

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

  /// Індикатор прогресу онбордингу (крок 1 з 4) з міткою.
  Widget _buildProgressIndicator(bool isLight) {
    final accentColor =
        isLight ? AppColorsMonitor.accent : AppColorsPS5.accent;
    final bgColor =
        isLight ? AppColorsMonitor.textHint : AppColorsPS5.textHint;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: Spacing.base),
      child: Column(
        children: [
          const SizedBox(height: Spacing.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Крок 1 з 4',
                style: AppTypography.labelMedium.copyWith(
                  color: isLight
                      ? AppColorsMonitor.textSecondary
                      : AppColorsPS5.textSecondary,
                ),
              ),
              Text(
                'Як це працює?',
                style: AppTypography.labelMedium.copyWith(
                  color: accentColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: Spacing.sm),
          Row(
            children: List.generate(4, (index) {
              final isActive = index == 0;
              return Expanded(
                child: Container(
                  height: 3,
                  margin: EdgeInsets.only(
                    right: index < 3 ? Spacing.xs : 0,
                  ),
                  decoration: BoxDecoration(
                    color: isActive
                        ? accentColor
                        : bgColor.withOpacity(0.2),
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

  /// Анімований лічильник кроків (00 → 01 → 02 → 03) з підписами.
  Widget _buildStepCounter(bool isLight) {
    final accentColor =
        isLight ? AppColorsMonitor.accent : AppColorsPS5.accent;
    final steps = [
      ('00', 'Початок'),
      ('01', 'Ціль'),
      ('02', 'Внески'),
      ('03', 'Прогрес'),
    ];

    final currentStep = _animatedStep.clamp(0, 3);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(steps.length, (index) {
        final isActive = index <= currentStep;
        final isCurrent = index == currentStep;

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (index > 0)
              Container(
                width: 24,
                height: 2,
                margin: const EdgeInsets.symmetric(horizontal: Spacing.xs),
                color: isActive
                    ? accentColor.withOpacity(0.5)
                    : (isLight
                            ? AppColorsMonitor.textHint
                            : AppColorsPS5.textHint)
                        .withOpacity(0.15),
              ),
            Column(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeOutBack,
                  padding: const EdgeInsets.all(Spacing.sm),
                  decoration: BoxDecoration(
                    color: isActive
                        ? accentColor.withOpacity(0.12)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(Radii.base),
                    border: isCurrent
                        ? Border.all(color: accentColor, width: 1.5)
                        : null,
                  ),
                  child: Text(
                    steps[index].$1,
                    style: AppTypography.monoCaption.copyWith(
                      color: isActive
                          ? accentColor
                          : (isLight
                                  ? AppColorsMonitor.textHint
                                  : AppColorsPS5.textHint)
                              .withOpacity(0.4),
                      fontWeight:
                          isCurrent ? FontWeight.w700 : FontWeight.w400,
                    ),
                  ),
                ),
                const SizedBox(height: Spacing.xs),
                Text(
                  steps[index].$2,
                  style: AppTypography.labelSmall.copyWith(
                    color: isActive
                        ? (isLight
                            ? AppColorsMonitor.textSecondary
                            : AppColorsPS5.textSecondary)
                        : (isLight
                                ? AppColorsMonitor.textHint
                                : AppColorsPS5.textHint)
                            .withOpacity(0.4),
                  ),
                ),
              ],
            ),
          ],
        );
      }),
    );
  }

  /// Інтерактивний демо-блок прогресу з кнопкою запуску.
  Widget _buildInteractiveDemo(bool isLight) {
    final accentColor =
        isLight ? AppColorsMonitor.accent : AppColorsPS5.accent;

    return AnimatedSize(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutCubic,
      child: Container(
        padding: const EdgeInsets.all(Spacing.base),
        decoration: BoxDecoration(
          color: accentColor.withOpacity(0.06),
          borderRadius: BorderRadius.circular(Radii.lg),
          border: Border.all(
            color: accentColor.withOpacity(0.12),
          ),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Icon(
                  Icons.play_circle_outline_rounded,
                  color: accentColor,
                  size: 20,
                ),
                const SizedBox(width: Spacing.sm),
                Expanded(
                  child: Text(
                    'Спробуй демо — подивись, як працює прогрес!',
                    style: AppTypography.labelMedium.copyWith(
                      color: isLight
                          ? AppColorsMonitor.textPrimary
                          : AppColorsPS5.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: Spacing.sm),
            GestureDetector(
              onTap: _startDemoProgress,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: Spacing.base,
                  vertical: Spacing.sm,
                ),
                decoration: BoxDecoration(
                  color: accentColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(Radii.md),
                ),
                child: Text(
                  _showDemoPreview
                      ? (_demoProgress >= 100
                          ? '🎉 Прогрес завершено! Ти молодець!'
                          : 'Завантаження... ${_demoProgress}%')
                      : '▶ Натисни, щоб запустити демо',
                  style: AppTypography.labelLarge.copyWith(
                    color: accentColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            if (_showDemoPreview) ...[
              const SizedBox(height: Spacing.sm),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: _demoProgress / 100,
                  minHeight: 8,
                  backgroundColor: accentColor.withOpacity(0.1),
                  valueColor: AlwaysStoppedAnimation(accentColor),
                ),
              ),
              const SizedBox(height: Spacing.xs),
              // Текстовий опис етапу демо
              Text(
                _demoProgress < 30
                    ? '🚀 Початковий етап...'
                    : _demoProgress < 70
                        ? '🔥 Внесок успішно...'
                        : '🎯 Майже готово!',
                style: AppTypography.labelSmall.copyWith(
                  color: isLight
                      ? AppColorsMonitor.textSecondary
                      : AppColorsPS5.textSecondary,
                ),
              ),
              const SizedBox(height: Spacing.xs),
              // Міні-статистика демо
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Внесено: ${(_demoProgress * 50).toInt()} грн',
                    style: AppTypography.caption.copyWith(
                      color: isLight
                          ? AppColorsMonitor.textHint
                          : AppColorsPS5.textHint,
                    ),
                  ),
                  Text(
                    '${(_demoProgress * 2).toInt()} XP отримано',
                    style: AppTypography.caption.copyWith(
                      color: AppColorsPS5.xp.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    ).animate().fadeIn(duration: 500.ms, delay: 400.ms);
  }

  /// Соціальний доказ — статистика користувачів.
  Widget _buildSocialProof(bool isLight) {
    final accentColor =
        isLight ? AppColorsMonitor.accent : AppColorsPS5.accent;

    return Container(
      padding: const EdgeInsets.all(Spacing.base),
      decoration: BoxDecoration(
        color: accentColor.withOpacity(0.04),
        borderRadius: BorderRadius.circular(Radii.lg),
        border: Border.all(
          color: accentColor.withOpacity(0.08),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.groups_rounded,
                color: accentColor,
                size: 18,
              ),
              const SizedBox(width: Spacing.sm),
              Text(
                'Нас вже понад 10 000 користувачів!',
                style: AppTypography.labelMedium.copyWith(
                  color: isLight
                      ? AppColorsMonitor.textPrimary
                      : AppColorsPS5.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: Spacing.md),
          Row(
            children: [
              _buildSocialStat(
                value: '2.5 млн+',
                label: 'Внесків зроблено',
                icon: Icons.savings_rounded,
                isLight: isLight,
              ),
              const SizedBox(width: Spacing.md),
              _buildSocialStat(
                value: '1.2 млн+',
                label: 'Серії досягнень',
                icon: Icons.local_fire_department_rounded,
                isLight: isLight,
              ),
              const SizedBox(width: Spacing.md),
              _buildSocialStat(
                value: '847K+',
                label: 'Досягнень виконано',
                icon: Icons.emoji_events_rounded,
                isLight: isLight,
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms, delay: 500.ms);
  }

  /// Міні-статистика для соціального доказу.
  Widget _buildSocialStat({
    required String value,
    required String label,
    required IconData icon,
    required bool isLight,
  }) {
    final accentColor =
        isLight ? AppColorsMonitor.accent : AppColorsPS5.accent;
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: accentColor, size: 20),
          const SizedBox(height: Spacing.xs),
          Text(
            value,
            style: AppTypography.monoSmall.copyWith(
              color: accentColor,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            label,
            style: AppTypography.caption.copyWith(
              color: (isLight
                      ? AppColorsMonitor.textHint
                      : AppColorsPS5.textHint),
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  /// FAQ секція з розгортними питаннями.
  Widget _buildFaqSection(bool isLight) {
    final accentColor =
        isLight ? AppColorsMonitor.accent : AppColorsPS5.accent;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: _toggleFaq,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: Spacing.base,
              vertical: Spacing.sm,
            ),
            decoration: BoxDecoration(
              color: accentColor.withOpacity(0.06),
              borderRadius: BorderRadius.circular(Radii.md),
              border: Border.all(
                color: accentColor.withOpacity(0.1),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.help_outline_rounded,
                      color: accentColor,
                      size: 18,
                    ),
                    const SizedBox(width: Spacing.sm),
                    Text(
                      'Часті запитання',
                      style: AppTypography.labelMedium.copyWith(
                        color: accentColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                Icon(
                  _showFaq
                      ? Icons.expand_less_rounded
                      : Icons.expand_more_rounded,
                  color: accentColor,
                  size: 20,
                ),
              ],
            ),
          ).animate().fadeIn(duration: 300.ms, delay: 550.ms),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOutCubic,
          child: _showFaq
              ? Padding(
                  padding: const EdgeInsets.only(top: Spacing.sm),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Відповіді на найпоширеніші запитання:',
                        style: AppTypography.labelSmall.copyWith(
                          color: (isLight
                                  ? AppColorsMonitor.textHint
                                  : AppColorsPS5.textHint),
                        ),
                      ),
                      const SizedBox(height: Spacing.sm),
                      ..._faqItems.asMap().entries.map((entry) {
                        final index = entry.key;
                        final faq = entry.value;
                        final isItemExpanded = _expandedCard == index + 10;
                        return _buildFaqItem(
                          faq: faq,
                          isExpanded: isItemExpanded,
                          accentColor: accentColor,
                          isLight: isLight,
                          onTap: () => _onFaqItemTap(index),
                        );
                      }),
                    ],
                  ),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }

  /// Один елемент FAQ.
  Widget _buildFaqItem({
    required _FaqItem faq,
    required bool isExpanded,
    required Color accentColor,
    required bool isLight,
    required VoidCallback onTap,
  }) {
    final subColor = isLight
        ? AppColorsMonitor.textSecondary
        : AppColorsPS5.textSecondary;

    return Padding(
      padding: const EdgeInsets.only(bottom: Spacing.xs),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          padding: EdgeInsets.symmetric(
            horizontal: Spacing.base,
            vertical: isExpanded ? Spacing.base : Spacing.sm,
          ),
          decoration: BoxDecoration(
            color: isExpanded
                ? accentColor.withOpacity(0.06)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(Radii.md),
            border: Border.all(
              color: accentColor.withOpacity(isExpanded ? 0.15 : 0.06),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: accentColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(Radii.sm),
                    ),
                    child: Icon(
                      faq.icon,
                      color: accentColor,
                      size: 14,
                    ),
                  ),
                  const SizedBox(width: Spacing.sm),
                  Expanded(
                    child: Text(
                      faq.question,
                      style: AppTypography.labelMedium.copyWith(
                        color: isLight
                            ? AppColorsMonitor.textPrimary
                            : AppColorsPS5.textPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              if (isExpanded) ...[
                const SizedBox(height: Spacing.sm),
                Container(
                  padding: const EdgeInsets.all(Spacing.sm),
                  decoration: BoxDecoration(
                    color: accentColor.withOpacity(0.04),
                    borderRadius: BorderRadius.circular(Radii.sm),
                  ),
                  child: Text(
                    faq.answer,
                    style: AppTypography.bodySmall.copyWith(
                      color: subColor,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Розгортна картка кроку з детальною іконкою та другорядною іконкою.
class _ExpandableStepCard extends StatelessWidget {
  const _ExpandableStepCard({
    required this.number,
    required this.displayNumber,
    required this.icon,
    required this.secondaryIcon,
    required this.title,
    required this.description,
    required this.expandedDescription,
    required this.isLight,
    required this.delay,
    required this.isExpanded,
    required this.onTap,
    this.expandedTip,
  });

  final String number;
  final String displayNumber;
  final IconData icon;
  final IconData secondaryIcon;
  final String title;
  final String description;
  final String expandedDescription;
  final bool isLight;
  final Duration delay;
  final bool isExpanded;
  final VoidCallback onTap;
  final String? expandedTip;

  @override
  Widget build(BuildContext context) {
    final cardColor =
        isLight ? AppColorsMonitor.card : AppColorsPS5.card;
    final accentColor =
        isLight ? AppColorsMonitor.accent : AppColorsPS5.accent;
    final titleColor =
        isLight ? AppColorsMonitor.textPrimary : AppColorsPS5.textPrimary;
    final descColor =
        isLight ? AppColorsMonitor.textSecondary : AppColorsPS5.textSecondary;
    final numColor =
        isLight ? AppColorsMonitor.textHint : AppColorsPS5.textHint;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutCubic,
        padding: EdgeInsets.all(isExpanded ? Spacing.xl : Spacing.lg),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(Radii.lg),
          boxShadow: isExpanded
              ? [
                  BoxShadow(
                    color: accentColor.withOpacity(0.1),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ]
              : AppShadows.level2,
          border: isExpanded
              ? Border.all(color: accentColor.withOpacity(0.3), width: 1)
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Номер + іконка з анімованим переходом
                Column(
                  children: [
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: Container(
                        key: ValueKey(isExpanded),
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: accentColor.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(Radii.md),
                        ),
                        child: Icon(
                          isExpanded ? secondaryIcon : icon,
                          color: accentColor,
                          size: 26,
                        ),
                      ),
                    ),
                    const SizedBox(height: Spacing.xs),
                    // Анімований номер
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 400),
                      child: Text(
                        displayNumber,
                        key: ValueKey(displayNumber),
                        style:
                            AppTypography.monoCaption.copyWith(color: numColor),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: Spacing.base),
                // Текст
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              title,
                              style: AppTypography.heading3
                                  .copyWith(color: titleColor),
                            ),
                          ),
                          Icon(
                            isExpanded
                                ? Icons.expand_less_rounded
                                : Icons.expand_more_rounded,
                            color: numColor,
                            size: 20,
                          ),
                        ],
                      ),
                      const SizedBox(height: Spacing.xs),
                      Text(
                        description,
                        style: AppTypography.bodyMedium
                            .copyWith(color: descColor),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Розгорнутий опис з додатковими підказками
            AnimatedSize(
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeOutCubic,
              child: isExpanded
                  ? Padding(
                      padding: const EdgeInsets.only(top: Spacing.base),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(Spacing.base),
                            decoration: BoxDecoration(
                              color: accentColor.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(Radii.md),
                            ),
                            child: Text(
                              expandedDescription,
                              style: AppTypography.bodyMedium.copyWith(
                                color: descColor,
                                height: 1.5,
                              ),
                            ),
                          ),
                          const SizedBox(height: Spacing.sm),
                          // Підказка до кроку
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: Spacing.sm,
                              vertical: Spacing.xs,
                            ),
                            decoration: BoxDecoration(
                              color: accentColor.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(Radii.sm),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.lightbulb_outline_rounded,
                                  color: accentColor.withOpacity(0.6),
                                  size: 14,
                                ),
                                const SizedBox(width: Spacing.xs),
                                Expanded(
                                  child: Text(
                                    expandedTip ??
                                        'Порада: поділися прогресом з друзями!',
                                    style: AppTypography.labelSmall.copyWith(
                                      color: accentColor.withOpacity(0.7),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: Spacing.sm),
                          // Швидка кількостіXP
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: Spacing.sm,
                              vertical: Spacing.xs,
                            ),
                            decoration: BoxDecoration(
                              color: AppColorsPS5.xp.withOpacity(0.06),
                              borderRadius: BorderRadius.circular(Radii.sm),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.star_rounded,
                                  color: AppColorsPS5.xp,
                                  size: 14,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '+10 XP за кожен крок',
                                  style: AppTypography.labelSmall.copyWith(
                                    color: AppColorsPS5.xp.withOpacity(0.8),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    )
        .animate()
        .slideX(
          begin: -0.2,
          end: 0,
          duration: 600.ms,
          curve: Curves.easeOutCubic,
          delay: delay + 200.ms,
        )
        .fadeIn(duration: 500.ms, delay: delay + 200.ms);
  }
}

/// FAQ елемент.
class _FaqItem {
  final String question;
  final String answer;
  final IconData icon;

  const _FaqItem({
    required this.question,
    required this.answer,
    required this.icon,
  });
}
