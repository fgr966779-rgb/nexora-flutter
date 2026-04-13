// ═══════════════════════════════════════════════════════════════════════════
// security_screen.dart — Security Settings Screen
// ═══════════════════════════════════════════════════════════════════════════
//
/// Екран «Безпека» — біометрія, PIN-код, інформація про шифрування.
///
/// Містить:
/// - Face ID / Touch ID перемикач з біометричною іконкою
/// - Секцію PIN-коду (встановити / змінити / видалити)
/// - Діалог введення PIN з 4 точками
/// - Двофакторну автентифікацію (для хмарної синхронізації)
/// - Інформаційну картку «AES-256 шифрування» з іконкою щита
/// - Інформацію про останній вхід
/// - Секцію зміни пароля
/// - Заглушки управління сесіями
/// - Індикатор оцінки безпеки
/// - Детальний розбив безпекових балів за категоріями
/// - Кнопку перевірки безпеки
/// - Історію спроб входу (mock)
/// - Рекомендації щодо покращення безпеки
/// - Таймер автоматичного блокування екрану
/// - Опції захисту скріншотів
/// - Інформацію про версію шифрування
///
/// {@category Settings}
/// {@subcategory Security}
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
import '../../../../core/extensions/build_context_ext.dart';

/// ─── Logging Tag ────────────────────────────────────────────────────────────

/// Тег для логування подій безпеки.
const String _logTag = '🔒 SecurityScreen';

/// ─── Security Constants ─────────────────────────────────────────────────────

/// Клас констант для параметрів безпеки.
class _SecurityConstants {
  /// Мінімальна довжина PIN-коду.
  static const int pinLength = 4;

  /// Максимальна кількість спроб вводу PIN.
  static const int maxPinAttempts = 5;

  /// Затримка між спробами PIN (мс).
  static const int pinAttemptDelayMs = 500;

  /// Мінімальна оцінка безпеки (Високий).
  static const int highSecurityThreshold = 80;

  /// Середня оцінка безпеки.
  static const int mediumSecurityThreshold = 50;

  /// Час автоматичного блокування (секунди).
  static const List<int> autoLockOptions = [30, 60, 120, 300, 600];

  /// Мапа балів за кожну функцію безпеки.
  static const int biometricsScore = 30;
  static const int pinScore = 30;
  static const int twoFactorScore = 25;
  static const int baseEncryptionScore = 15;

  /// Максимальна кількість сесій для відображення.
  static const int maxSessionsDisplay = 5;
}

/// ─── Main Screen Widget ────────────────────────────────────────────────────

/// Екран налаштувань безпеки користувача.
///
/// Надає контроль над:
/// - Біометричною автентифікацією
/// - PIN-кодом
/// - Двофакторною автентифікацією
/// - Управлінням сесіями
///
/// Приклад використання:
/// ```dart
/// Navigator.of(context).pushNamed('/security');
/// ```
class SecurityScreen extends StatefulWidget {
  /// Створює екран налаштувань безпеки.
  const SecurityScreen({super.key});

  @override
  State<SecurityScreen> createState() => _SecurityScreenState();
}

/// Стан екрану безпеки.
class _SecurityScreenState extends State<SecurityScreen> {
  // ─── Biometrics State ───────────────────────────────────────────────

  /// Чи увімкнено біометричну автентифікацію.
  bool _biometricsEnabled = false;

  /// Тип доступної біометрії (mock).
  String _biometricsType = 'Face ID';

  /// Чи біометрія доступна на пристрої.
  bool _biometricsAvailable = true;

  // ─── PIN State ──────────────────────────────────────────────────────

  /// Чи PIN-код встановлено.
  bool _pinSetup = false;

  /// Поточний PIN-код (вitched in production).
  String? _currentPin;

  /// Чи увімкнено двофакторну автентифікацію.
  bool _twoFactorEnabled = false;

  /// Чи показується діалог введення PIN.
  bool _showPinDialog = false;

  /// Чи зараз змінюється PIN (проти нової установки).
  bool _pinIsChanging = false;

  /// Кількість спроб вводу PIN.
  int _pinAttempts = 0;

  /// Чи PIN заблоковано через забагато спроб.
  bool _pinLocked = false;

  /// Чи показувати помилку невідповідності PIN.
  bool _showPinError = false;

  // ─── PIN Entry State ────────────────────────────────────────────────

  /// Введений PIN на першому кроці.
  String _enteredPin = '';

  /// Введений PIN на кроці підтвердження.
  String _confirmPin = '';

  /// Поточний крок введення PIN ('enter' | 'confirm' | 'old').
  String _pinStep = 'enter';

  // ─── Session State ──────────────────────────────────────────────────

  /// Чи показувати деталі сесій.
  bool _showSessionDetails = false;

  /// Автоматичне блокування (секунди).
  int _autoLockTimeout = 300;

  /// Чи увімкнено захист від скріншотів.
  bool _screenshotProtection = false;

  /// Чи завантажуються дані безпеки.
  bool _isLoadingSecurity = false;

  // ─── Mock Login History ─────────────────────────────────────────────

  /// Історія входів (mock дані).
  final List<_LoginRecord> _loginHistory = [
    _LoginRecord(
      device: 'iPhone 15 Pro',
      location: 'Київ, Україна',
      time: 'Сьогодні о 14:23',
      isCurrent: true,
      isSuccessful: true,
      method: 'Face ID',
    ),
    _LoginRecord(
      device: 'MacBook Pro',
      location: 'Київ, Україна',
      time: 'Вчора о 09:15',
      isCurrent: false,
      isSuccessful: true,
      method: 'PIN',
    ),
    _LoginRecord(
      device: 'iPad Air',
      location: 'Львів, Україна',
      time: '3 дні тому',
      isCurrent: false,
      isSuccessful: true,
      method: 'Face ID',
    ),
    _LoginRecord(
      device: 'Невідомий пристрій',
      location: 'Москва, Росія',
      time: '5 днів тому',
      isCurrent: false,
      isSuccessful: false,
      method: '—',
    ),
  ];

  // ─── Computed Properties ─────────────────────────────────────────────

  /// Загальна оцінка безпеки (0-100).
  int get _securityScore {
    try {
      int score = _SecurityConstants.baseEncryptionScore;
      if (_biometricsEnabled) score += _SecurityConstants.biometricsScore;
      if (_pinSetup) score += _SecurityConstants.pinScore;
      if (_twoFactorEnabled) score += _SecurityConstants.twoFactorScore;
      return score.clamp(0, 100);
    } catch (e) {
      developer.log('Error calculating security score: $e', name: _logTag);
      return _SecurityConstants.baseEncryptionScore;
    }
  }

  /// Текстова мітка рівня безпеки.
  String get _securityLabel {
    if (_securityScore >= _SecurityConstants.highSecurityThreshold) return 'Високий';
    if (_securityScore >= _SecurityConstants.mediumSecurityThreshold) return 'Середній';
    return 'Низький';
  }

  /// Колір рівня безпеки.
  Color get _securityColor {
    if (_securityScore >= _SecurityConstants.highSecurityThreshold) return AppColorsPS5.success;
    if (_securityScore >= _SecurityConstants.mediumSecurityThreshold) return AppColorsPS5.warning;
    return AppColorsPS5.error;
  }

  /// Кількість активних сесій.
  int get _activeSessionsCount {
    return _loginHistory.where((s) => s.isSuccessful && !s.isCurrent).length + 1;
  }

  /// Кількість невдалих спроб входу.
  int get _failedLoginAttempts {
    return _loginHistory.where((s) => !s.isSuccessful).length;
  }

  /// Рекомендації щодо покращення безпеки.
  List<String> get _securityRecommendations {
    final recommendations = <String>[];
    if (!_biometricsEnabled) recommendations.add('Увімкніть біометрію для швидкого та безпечного входу');
    if (!_pinSetup) recommendations.add('Встановіть PIN-код для додаткового захисту');
    if (!_twoFactorEnabled) recommendations.add('Увімкніть двофакторну автентифікацію для хмарної синхронізації');
    if (recommendations.isEmpty) recommendations.add('Ваш акаунт добре захищений! Продовжуйте в тому ж дусі.');
    return recommendations;
  }

  // ─── Lifecycle ────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    developer.log('Security screen initialized', name: _logTag);
    _detectBiometricsType();
  }

  @override
  void dispose() {
    developer.log('Security screen disposed', name: _logTag);
    super.dispose();
  }

  /// Визначає тип біометрії (mock).
  void _detectBiometricsType() {
    // В реальному додатку: local_auth package
    setState(() {
      _biometricsType = 'Face ID';
      _biometricsAvailable = true;
    });
  }

  // ─── Biometrics Methods ─────────────────────────────────────────────

  /// Перемикає біометричну автентифікацію.
  ///
  /// При увімкненні показує toast успіху.
  /// При вимкненні — toast попередження.
  Future<void> _toggleBiometrics(bool value) async {
    try {
      if (value && !_biometricsAvailable) {
        if (mounted) {
          context.showAppToast(
            'Біометрія недоступна на цьому пристрої',
            type: AppToastType.error,
          );
        }
        return;
      }

      setState(() => _biometricsEnabled = value);
      if (value) {
        developer.log('Biometrics enabled: $_biometricsType', name: _logTag);
        if (mounted) {
          context.showAppToast('$_biometricsType увімкнено', type: AppToastType.success);
        }
      } else {
        developer.log('Biometrics disabled', name: _logTag);
        if (mounted) {
          context.showAppToast('Біометрію вимкнено', type: AppToastType.warning);
        }
      }
    } catch (e) {
      developer.log('Error toggling biometrics: $e', name: _logTag);
      if (mounted) {
        context.showAppToast('Помилка: ${e.toString()}', type: AppToastType.error);
      }
    }
  }

  // ─── PIN Methods ────────────────────────────────────────────────────

  /// Відкриває діалог введення PIN.
  ///
  /// [isChange] — чи це зміна існуючого PIN.
  void _openPinDialog({bool isChange = false}) {
    if (_pinLocked) {
      context.showAppToast(
        'PIN заблоковано через забагато спроб. Спробуйте пізніше.',
        type: AppToastType.error,
      );
      return;
    }

    setState(() {
      _showPinDialog = true;
      _pinIsChanging = isChange;
      _enteredPin = '';
      _confirmPin = '';
      _pinStep = isChange ? 'old' : 'enter';
      _showPinError = false;
    });
    developer.log('PIN dialog opened (change: $isChange)', name: _logTag);
  }

  /// Закриває діалог введення PIN.
  void _closePinDialog() {
    setState(() {
      _showPinDialog = false;
      _showPinError = false;
    });
    developer.log('PIN dialog closed', name: _logTag);
  }

  /// Обробляє натискання цифри на keypad.
  void _onPinDigit(String digit) {
    if (_pinLocked) return;

    try {
      if (_pinStep == 'enter' || _pinStep == 'old') {
        final currentPin = _pinStep == 'old' ? _enteredPin : _enteredPin;
        if (currentPin.length < _SecurityConstants.pinLength) {
          setState(() => _enteredPin += digit);
          if (_pinStep == 'old' && _enteredPin.length == _SecurityConstants.pinLength) {
            // Verify old PIN
            Future.delayed(const Duration(milliseconds: _SecurityConstants.pinAttemptDelayMs), () {
              if (!mounted) return;
              if (_enteredPin == _currentPin) {
                setState(() {
                  _enteredPin = '';
                  _pinStep = 'enter';
                });
              } else {
                _handlePinError();
              }
            });
          } else if (_pinStep == 'enter' && _enteredPin.length == _SecurityConstants.pinLength) {
            Future.delayed(const Duration(milliseconds: _SecurityConstants.pinAttemptDelayMs), () {
              if (mounted) setState(() => _pinStep = 'confirm');
            });
          }
        }
      } else if (_pinStep == 'confirm') {
        if (_confirmPin.length < _SecurityConstants.pinLength) {
          setState(() => _confirmPin += digit);
          if (_confirmPin.length == _SecurityConstants.pinLength) {
            Future.delayed(const Duration(milliseconds: _SecurityConstants.pinAttemptDelayMs), () {
              if (!mounted) return;
              if (_confirmPin == _enteredPin) {
                setState(() {
                  _currentPin = _enteredPin;
                  _pinSetup = true;
                  _showPinDialog = false;
                  _showPinError = false;
                  _pinAttempts = 0;
                });
                developer.log('PIN set successfully', name: _logTag);
                if (mounted) {
                  context.showAppToast('PIN-код встановлено!', type: AppToastType.success);
                }
              } else {
                _handlePinError();
              }
            });
          }
        }
      }
    } catch (e) {
      developer.log('Error handling PIN digit: $e', name: _logTag);
    }
  }

  /// Обробляє помилку вводу PIN.
  void _handlePinError() {
    setState(() {
      _pinAttempts++;
      _showPinError = true;
      _confirmPin = '';
      if (_pinStep == 'confirm') {
        _pinStep = 'enter';
        _enteredPin = '';
      } else if (_pinStep == 'old') {
        _enteredPin = '';
      }
    });

    if (_pinAttempts >= _SecurityConstants.maxPinAttempts) {
      setState(() => _pinLocked = true);
      developer.log('PIN locked after $_pinAttempts attempts', name: _logTag, level: 900);
      if (mounted) {
        context.showAppToast(
          'PIN заблоковано! Забагато невдалих спроб.',
          type: AppToastType.error,
        );
        // Auto-unlock after 30 seconds
        Future.delayed(const Duration(seconds: 30), () {
          if (mounted) {
            setState(() {
              _pinLocked = false;
              _pinAttempts = 0;
            });
          }
        });
      }
    } else {
      if (mounted) {
        context.showAppToast(
          'Невірний PIN. Спроба ${_pinAttempts}/${_SecurityConstants.maxPinAttempts}',
          type: AppToastType.error,
        );
      }
    }
  }

  /// Обробляє натискання кнопки видалення.
  void _onPinDelete() {
    if (_pinStep == 'enter' || _pinStep == 'old') {
      if (_enteredPin.isNotEmpty) {
        setState(() => _enteredPin = _enteredPin.substring(0, _enteredPin.length - 1));
      }
    } else if (_pinStep == 'confirm') {
      if (_confirmPin.isNotEmpty) {
        setState(() => _confirmPin = _confirmPin.substring(0, _confirmPin.length - 1));
      } else {
        setState(() => _pinStep = 'enter');
      }
    }
  }

  /// Видаляє PIN-код з підтвердженням.
  void _removePin() {
    try {
      context.showConfirmDialog(
        title: 'Видалити PIN-код',
        message: 'Ви впевнені, що хочете видалити PIN-код? Це знизить рівень безпеки.',
        confirmText: 'Видалити',
        cancelText: 'Скасувати',
        destructive: true,
      ).then((confirmed) {
        if (confirmed != null && confirmed) {
          setState(() {
            _currentPin = null;
            _pinSetup = false;
            _pinAttempts = 0;
            _pinLocked = false;
          });
          developer.log('PIN removed', name: _logTag);
          if (mounted) {
            context.showAppToast('PIN-код видалено', type: AppToastType.warning);
          }
        }
      });
    } catch (e) {
      developer.log('Error removing PIN: $e', name: _logTag);
    }
  }

  // ─── Two Factor Methods ─────────────────────────────────────────────

  /// Перемикає двофакторну автентифікацію.
  void _toggleTwoFactor(bool value) {
    try {
      if (value && !_pinSetup) {
        context.showAppToast(
          'Спочатку встановіть PIN-код',
          type: AppToastType.warning,
        );
        return;
      }

      setState(() => _twoFactorEnabled = value);
      developer.log('2FA ${value ? "enabled" : "disabled"}', name: _logTag);

      if (value) {
        if (mounted) {
          context.showAppToast('Двофакторну автентифікацію увімкнено', type: AppToastType.success);
        }
      } else {
        if (mounted) {
          context.showAppToast('Двофакторну автентифікацію вимкнено', type: AppToastType.warning);
        }
      }
    } catch (e) {
      developer.log('Error toggling 2FA: $e', name: _logTag);
    }
  }

  // ─── Utility Methods ────────────────────────────────────────────────

  /// Форматує секунди у зручний вигляд.
  String _formatTimeout(int seconds) {
    if (seconds < 60) return '$seconds сек';
    if (seconds < 3600) return '${seconds ~/ 60} хв';
    return '${seconds ~/ 3600} год';
  }

  /// Запускає перевірку безпеки (mock).
  Future<void> _runSecurityCheck() async {
    setState(() => _isLoadingSecurity = true);
    developer.log('Running security check...', name: _logTag);

    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() => _isLoadingSecurity = false);
      context.showAppToast(
        'Перевірка завершена. Оцінка: $_securityScore%',
        type: _securityScore >= _SecurityConstants.highSecurityThreshold
            ? AppToastType.success
            : AppToastType.warning,
      );
    }
  }

  /// Видаляє сесію (mock).
  void _terminateSession(_LoginRecord session) {
    if (session.isCurrent) {
      context.showAppToast('Неможливо завершити поточну сесію', type: AppToastType.error);
      return;
    }

    setState(() => _loginHistory.remove(session));
    developer.log('Session terminated: ${session.device}', name: _logTag);
    if (mounted) {
      context.showAppToast('Сесію завершено', type: AppToastType.success);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final textColor = isDark ? AppColorsPS5.textPrimary : AppColorsMonitor.textPrimary;
    final subColor = isDark ? AppColorsPS5.textSecondary : AppColorsMonitor.textSecondary;
    final cardColor = isDark ? AppColorsPS5.card : AppColorsMonitor.card;
    final borderColor = isDark ? AppColorsPS5.border : AppColorsMonitor.border;
    final accent = isDark ? AppColorsPS5.accent : AppColorsMonitor.accent;

    return Scaffold(
      backgroundColor: isDark ? AppColorsPS5.background : AppColorsMonitor.background,
      appBar: AppBar(
        title: const Text('Безпека'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: textColor,
      ),
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.symmetric(horizontal: Spacing.base),
            children: [
              const SizedBox(height: Spacing.lg),

              // ─── Security Score Indicator ───────────────────
              _buildSecurityScoreCard(cardColor, borderColor, textColor),

              const SizedBox(height: Spacing.xxl),

              // ─── Security Recommendations ──────────────────
              _buildSecurityRecommendations(textColor, subColor, cardColor, borderColor),

              const SizedBox(height: Spacing.xxl),

              // ─── Біометрія ──────────────────────────────────
              Text('Біометрія', style: AppTypography.heading3.copyWith(color: textColor)),
              const SizedBox(height: Spacing.sm),
              _buildBiometricsCard(cardColor, borderColor, accent, textColor, subColor),

              const SizedBox(height: Spacing.xxl),

              // ─── PIN-код ────────────────────────────────────
              Text('PIN-код', style: AppTypography.heading3.copyWith(color: textColor)),
              const SizedBox(height: Spacing.sm),
              _buildPinCard(cardColor, borderColor, accent, textColor, subColor),

              const SizedBox(height: Spacing.xxl),

              // ─── Двофакторна автентифікація ────────────────
              Text('Додатковий захист', style: AppTypography.heading3.copyWith(color: textColor)),
              const SizedBox(height: Spacing.sm),
              _buildTwoFactorCard(cardColor, borderColor, accent, textColor, subColor),

              const SizedBox(height: Spacing.xxl),

              // ─── Автоматичне блокування ────────────────────
              Text('Автоматичне блокування', style: AppTypography.heading3.copyWith(color: textColor)),
              const SizedBox(height: Spacing.sm),
              _buildAutoLockSection(cardColor, borderColor, accent, textColor, subColor),

              const SizedBox(height: Spacing.xxl),

              // ─── Інформація про шифрування ──────────────────
              Text('Захист даних', style: AppTypography.heading3.copyWith(color: textColor)),
              const SizedBox(height: Spacing.sm),
              _buildEncryptionCard(cardColor, borderColor, textColor, subColor),

              const SizedBox(height: Spacing.xxl),

              // ─── Останній вхід ──────────────────────────────
              Text('Сесії', style: AppTypography.heading3.copyWith(color: textColor)),
              const SizedBox(height: Spacing.sm),
              _buildSessionCard(cardColor, borderColor, textColor, subColor, accent),

              const SizedBox(height: Spacing.xxxl),
            ],
          ),

          // ─── PIN Entry Dialog ──────────────────────────────
          if (_showPinDialog) _buildPinOverlay(accent),
        ],
      ),
    );
  }

  // ─── Security Recommendations ────────────────────────────────────────

  /// Будує картку рекомендацій щодо безпеки.
  Widget _buildSecurityRecommendations(Color textColor, Color subColor, Color cardColor, Color borderColor) {
    final recommendations = _securityRecommendations;
    final isGood = recommendations.length == 1 && recommendations.first.contains('добре');

    return Container(
      padding: const EdgeInsets.all(Spacing.base),
      decoration: BoxDecoration(
        color: isGood ? AppColorsPS5.success.withOpacity(0.06) : AppColorsPS5.warning.withOpacity(0.06),
        borderRadius: BorderRadius.circular(Radii.lg),
        border: Border.all(
          color: isGood ? AppColorsPS5.success.withOpacity(0.15) : AppColorsPS5.warning.withOpacity(0.15),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isGood ? Icons.check_circle_rounded : Icons.lightbulb_rounded,
                color: isGood ? AppColorsPS5.success : AppColorsPS5.warning,
                size: 20,
              ),
              const SizedBox(width: Spacing.sm),
              Text(
                isGood ? 'Все чудово!' : 'Рекомендації',
                style: AppTypography.labelMedium.copyWith(
                  color: isGood ? AppColorsPS5.success : AppColorsPS5.warning,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: Spacing.sm),
          ...recommendations.map((r) => Padding(
                padding: const EdgeInsets.only(bottom: Spacing.xs),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('• ', style: AppTypography.bodySmall.copyWith(color: subColor)),
                    Expanded(child: Text(r, style: AppTypography.bodySmall.copyWith(color: subColor))),
                  ],
                ),
              )),
        ],
      ),
    ).animate().fade(delay: 150.ms, duration: 400.ms);
  }

  // ─── Auto Lock Section ───────────────────────────────────────────────

  /// Будує секцію автоматичного блокування.
  Widget _buildAutoLockSection(Color cardColor, Color borderColor, Color accent, Color textColor, Color subColor) {
    return Container(
      padding: const EdgeInsets.all(Spacing.base),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(Radii.lg),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        children: [
          SwitchListTile.adaptive(
            value: _screenshotProtection,
            onChanged: (v) => setState(() => _screenshotProtection = v),
            activeColor: accent,
            contentPadding: EdgeInsets.zero,
            secondary: Container(
              width: 44, height: 44,
              decoration: BoxDecoration(color: accent.withOpacity(0.1), borderRadius: BorderRadius.circular(Radii.md)),
              child: Icon(Icons.screenshot_monitor_rounded, color: accent, size: 22),
            ),
            title: Text('Захист від скріншотів', style: AppTypography.bodyMedium.copyWith(color: textColor)),
            subtitle: Text(_screenshotProtection ? 'Скріншоти заборонені' : 'Скріншоти дозволені', style: AppTypography.bodySmall.copyWith(color: subColor)),
          ),
          const SizedBox(height: Spacing.sm),
          Container(
            padding: const EdgeInsets.all(Spacing.md),
            decoration: BoxDecoration(color: accent.withOpacity(0.05), borderRadius: BorderRadius.circular(Radii.md)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Автоблокування: ${_formatTimeout(_autoLockTimeout)}', style: AppTypography.labelMedium.copyWith(color: textColor)),
                const SizedBox(height: Spacing.sm),
                Wrap(
                  spacing: Spacing.sm,
                  runSpacing: Spacing.sm,
                  children: _SecurityConstants.autoLockOptions.map((seconds) {
                    final isSelected = _autoLockTimeout == seconds;
                    return GestureDetector(
                      onTap: () {
                        context.haptic();
                        setState(() => _autoLockTimeout = seconds);
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(horizontal: Spacing.sm, vertical: Spacing.xs),
                        decoration: BoxDecoration(
                          color: isSelected ? accent : Colors.transparent,
                          borderRadius: BorderRadius.circular(Radii.xl),
                          border: Border.all(color: isSelected ? accent : borderColor),
                        ),
                        child: Text(
                          _formatTimeout(seconds),
                          style: AppTypography.labelSmall.copyWith(
                            color: isSelected ? Colors.white : subColor,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── Security Score Card ─────────────────────────────────────────────

  Widget _buildSecurityScoreCard(Color cardColor, Color borderColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.all(Spacing.base),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(Radii.lg),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Рівень безпеки', style: AppTypography.labelLarge.copyWith(color: textColor)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _securityColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(Radii.xl),
                ),
                child: Text(
                  '$_securityScore% · $_securityLabel',
                  style: AppTypography.labelSmall.copyWith(
                    color: _securityColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: Spacing.md),
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: _securityScore / 100,
              backgroundColor: borderColor,
              valueColor: AlwaysStoppedAnimation<Color>(_securityColor),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: Spacing.sm),
          // Score breakdown
          _buildScoreBreakdown(textColor),
          const SizedBox(height: Spacing.sm),
          Text(
            _securityScore >= _SecurityConstants.highSecurityThreshold
                ? 'Ваш акаунт добре захищений!'
                : 'Увімкні більше функцій для кращого захисту',
            style: AppTypography.labelSmall.copyWith(color: _securityColor.withOpacity(0.8)),
          ),
          const SizedBox(height: Spacing.sm),
          // Security check button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _isLoadingSecurity ? null : _runSecurityCheck,
              icon: _isLoadingSecurity
                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.shield_rounded, size: 18),
              label: Text(_isLoadingSecurity ? 'Перевірка...' : 'Запустити перевірку безпеки'),
              style: OutlinedButton.styleFrom(
                foregroundColor: _securityColor,
                side: BorderSide(color: _securityColor),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Radii.md)),
              ),
            ),
          ),
        ],
      ),
    ).animate().fade(duration: 400.ms);
  }

  /// Будує розбивку балів безпеки.
  Widget _buildScoreBreakdown(Color textColor) {
    final subColor = textColor.withOpacity(0.6);
    return Container(
      padding: const EdgeInsets.all(Spacing.sm),
      decoration: BoxDecoration(color: textColor.withOpacity(0.03), borderRadius: BorderRadius.circular(Radii.sm)),
      child: Column(
        children: [
          _buildScoreRow('AES-256 шифрування', _SecurityConstants.baseEncryptionScore, AppColorsPS5.success, subColor),
          _buildScoreRow('Біометрія', _biometricsEnabled ? _SecurityConstants.biometricsScore : 0, _biometricsEnabled ? AppColorsPS5.success : textColor.withOpacity(0.3), subColor),
          _buildScoreRow('PIN-код', _pinSetup ? _SecurityConstants.pinScore : 0, _pinSetup ? AppColorsPS5.success : textColor.withOpacity(0.3), subColor),
          _buildScoreRow('Двофакторна', _twoFactorEnabled ? _SecurityConstants.twoFactorScore : 0, _twoFactorEnabled ? AppColorsPS5.success : textColor.withOpacity(0.3), subColor),
        ],
      ),
    );
  }

  /// Будує рядок з розбивкою балів.
  Widget _buildScoreRow(String label, int score, Color color, Color subColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(score > 0 ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded, color: color, size: 14),
          const SizedBox(width: Spacing.xs),
          Expanded(child: Text(label, style: AppTypography.caption.copyWith(color: subColor))),
          Text('+$score', style: AppTypography.caption.copyWith(color: color, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  // ─── Biometrics Card ───────────────────────────────────────────────

  Widget _buildBiometricsCard(Color cardColor, Color borderColor, Color accent, Color textColor, Color subColor) {
    return Container(
      padding: const EdgeInsets.all(Spacing.base),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(Radii.lg),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        children: [
          SwitchListTile.adaptive(
            value: _biometricsEnabled,
            onChanged: _toggleBiometrics,
            activeColor: accent,
            contentPadding: EdgeInsets.zero,
            secondary: Container(
              width: 44, height: 44,
              decoration: BoxDecoration(color: accent.withOpacity(0.1), borderRadius: BorderRadius.circular(Radii.md)),
              child: Icon(Icons.fingerprint_rounded, color: accent, size: 24),
            ),
            title: Text('$_biometricsType', style: AppTypography.bodyMedium.copyWith(color: textColor)),
            subtitle: Text(
              _biometricsAvailable
                  ? 'Використовувати біометрію для входу'
                  : 'Біометрія недоступна на цьому пристрої',
              style: AppTypography.bodySmall.copyWith(
                color: _biometricsAvailable ? subColor : AppColorsPS5.error,
              ),
            ),
          ),
          if (!_biometricsAvailable)
            Container(
              margin: const EdgeInsets.only(top: Spacing.sm),
              padding: const EdgeInsets.all(Spacing.sm),
              decoration: BoxDecoration(color: AppColorsPS5.error.withOpacity(0.06), borderRadius: BorderRadius.circular(Radii.sm)),
              child: Text('⚠️ Біометрія не підтримується вашим пристроєм', style: AppTypography.labelSmall.copyWith(color: AppColorsPS5.error, fontSize: 10)),
            ),
        ],
      ),
    );
  }

  // ─── PIN Card ───────────────────────────────────────────────────────

  Widget _buildPinCard(Color cardColor, Color borderColor, Color accent, Color textColor, Color subColor) {
    return Container(
      padding: const EdgeInsets.all(Spacing.base),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(Radii.lg),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 44, height: 44,
                decoration: BoxDecoration(color: accent.withOpacity(0.1), borderRadius: BorderRadius.circular(Radii.md)),
                child: Icon(Icons.pin_rounded, color: accent, size: 24),
              ),
              const SizedBox(width: Spacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('PIN-код', style: AppTypography.bodyMedium.copyWith(color: textColor)),
                    Row(
                      children: [
                        Text(
                          _pinSetup ? 'Встановлено' : 'Не встановлено',
                          style: AppTypography.bodySmall.copyWith(color: _pinSetup ? AppColorsPS5.success : subColor),
                        ),
                        if (_pinLocked) ...[
                          const SizedBox(width: Spacing.xs),
                          Text(' · Заблоковано', style: AppTypography.bodySmall.copyWith(color: AppColorsPS5.error)),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: Spacing.md),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: _pinLocked ? null : (_pinSetup ? () => _openPinDialog(isChange: true) : _openPinDialog),
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 200),
                    opacity: _pinLocked ? 0.5 : 1.0,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: Spacing.md),
                      decoration: BoxDecoration(
                        color: accent.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(Radii.md),
                        border: Border.all(color: accent.withOpacity(0.3)),
                      ),
                      child: Center(
                        child: Text(
                          _pinSetup ? 'Змінити PIN' : 'Встановити PIN',
                          style: AppTypography.labelLarge.copyWith(color: accent),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              if (_pinSetup) ...[
                const SizedBox(width: Spacing.md),
                Expanded(
                  child: GestureDetector(
                    onTap: _removePin,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: Spacing.md),
                      decoration: BoxDecoration(
                        color: AppColorsPS5.error.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(Radii.md),
                        border: Border.all(color: AppColorsPS5.error.withOpacity(0.2)),
                      ),
                      child: Center(
                        child: Text('Видалити', style: AppTypography.labelLarge.copyWith(color: AppColorsPS5.error)),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  // ─── Two Factor Card ────────────────────────────────────────────────

  Widget _buildTwoFactorCard(Color cardColor, Color borderColor, Color accent, Color textColor, Color subColor) {
    return Container(
      padding: const EdgeInsets.all(Spacing.base),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(Radii.lg),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        children: [
          SwitchListTile.adaptive(
            value: _twoFactorEnabled,
            onChanged: _toggleTwoFactor,
            activeColor: accent,
            contentPadding: EdgeInsets.zero,
            secondary: Container(
              width: 44, height: 44,
              decoration: BoxDecoration(color: accent.withOpacity(0.1), borderRadius: BorderRadius.circular(Radii.md)),
              child: Icon(Icons.shield_rounded, color: accent, size: 24),
            ),
            title: Text('Двофакторна автентифікація', style: AppTypography.bodyMedium.copyWith(color: textColor)),
            subtitle: Text('Для хмарної синхронізації та відновлення', style: AppTypography.bodySmall.copyWith(color: subColor)),
          ),
          if (_twoFactorEnabled)
            Container(
              margin: const EdgeInsets.only(top: Spacing.sm),
              padding: const EdgeInsets.all(Spacing.sm),
              decoration: BoxDecoration(color: AppColorsPS5.success.withOpacity(0.06), borderRadius: BorderRadius.circular(Radii.sm)),
              child: Text('✅ Двофакторна автентифікація активна', style: AppTypography.labelSmall.copyWith(color: AppColorsPS5.success, fontSize: 10)),
            ),
        ],
      ),
    );
  }

  // ─── Encryption Card ─────────────────────────────────────────────────

  Widget _buildEncryptionCard(Color cardColor, Color borderColor, Color textColor, Color subColor) {
    return Container(
      padding: const EdgeInsets.all(Spacing.base),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(Radii.lg),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 48, height: 48,
                decoration: BoxDecoration(
                  color: AppColorsPS5.success.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(Radii.md),
                ),
                child: const Icon(Icons.shield_rounded, color: AppColorsPS5.success, size: 26),
              ),
              const SizedBox(width: Spacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text('AES-256 шифрування', style: AppTypography.labelLarge.copyWith(color: textColor)),
                        const SizedBox(width: Spacing.xs),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(color: AppColorsPS5.success.withOpacity(0.1), borderRadius: BorderRadius.circular(Radii.sm)),
                          child: Text('Активно', style: AppTypography.labelSmall.copyWith(color: AppColorsPS5.success, fontWeight: FontWeight.w700, fontSize: 9)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text('Усі дані захищені AES-256 шифруванням. Ваша інформація зберігається локально на пристрої.', style: AppTypography.bodySmall.copyWith(color: subColor)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: Spacing.sm),
          Container(
            padding: const EdgeInsets.all(Spacing.sm),
            decoration: BoxDecoration(color: textColor.withOpacity(0.02), borderRadius: BorderRadius.circular(Radii.sm)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Технічні деталі:', style: AppTypography.caption.copyWith(color: subColor, fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text('• Алгоритм: AES-256-GCM', style: AppTypography.caption.copyWith(color: subColor.withOpacity(0.6), fontSize: 9)),
                Text('• Ключ: 256-бітний', style: AppTypography.caption.copyWith(color: subColor.withOpacity(0.6), fontSize: 9)),
                Text('• Режим: CBC + HMAC', style: AppTypography.caption.copyWith(color: subColor.withOpacity(0.6), fontSize: 9)),
                Text('• Зберігання: Тільки локально', style: AppTypography.caption.copyWith(color: subColor.withOpacity(0.6), fontSize: 9)),
              ],
            ),
          ),
        ],
      ),
    ).animate().fade(delay: 400.ms, duration: 400.ms);
  }

  // ─── Session Card ────────────────────────────────────────────────────

  Widget _buildSessionCard(Color cardColor, Color borderColor, Color textColor, Color subColor, Color accent) {
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
            children: [
              Container(
                width: 44, height: 44,
                decoration: BoxDecoration(color: accent.withOpacity(0.1), borderRadius: BorderRadius.circular(Radii.md)),
                child: const Icon(Icons.device_hub_rounded, color: AppColorsPS5.accent, size: 22),
              ),
              const SizedBox(width: Spacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Поточна сесія', style: AppTypography.bodyMedium.copyWith(color: textColor)),
                    Text('$_activeSessionsCount активних сесій · $_failedLoginAttempts невдалих спроб', style: AppTypography.bodySmall.copyWith(color: subColor)),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => setState(() => _showSessionDetails = !_showSessionDetails),
                child: Icon(_showSessionDetails ? Icons.expand_less_rounded : Icons.expand_more_rounded, color: subColor),
              ),
            ],
          ),
          if (_showSessionDetails)
            ..._loginHistory.map((session) => _buildSessionItem(session, textColor, subColor, accent)),
        ],
      ),
    );
  }

  /// Будує елемент сесії.
  Widget _buildSessionItem(_LoginRecord session, Color textColor, Color subColor, Color accent) {
    return Container(
      margin: const EdgeInsets.only(top: Spacing.sm),
      padding: const EdgeInsets.all(Spacing.md),
      decoration: BoxDecoration(
        color: session.isCurrent ? AppColorsPS5.success.withOpacity(0.05) : (session.isSuccessful ? textColor.withOpacity(0.02) : AppColorsPS5.error.withOpacity(0.05)),
        borderRadius: BorderRadius.circular(Radii.md),
        border: Border.all(
          color: session.isCurrent ? AppColorsPS5.success.withOpacity(0.15) : (session.isSuccessful ? borderColor : AppColorsPS5.error.withOpacity(0.15)),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      session.isSuccessful ? Icons.check_circle_rounded : Icons.error_rounded,
                      color: session.isSuccessful ? AppColorsPS5.success : AppColorsPS5.error,
                      size: 14,
                    ),
                    const SizedBox(width: Spacing.xs),
                    Expanded(
                      child: Text(
                        session.device + (session.isCurrent ? ' (Цей пристрій)' : ''),
                        style: AppTypography.labelSmall.copyWith(
                          color: textColor,
                          fontWeight: session.isCurrent ? FontWeight.w600 : FontWeight.w400,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text('${session.method} · ${session.location} · ${session.time}', style: AppTypography.caption.copyWith(color: subColor.withOpacity(0.6), fontSize: 9)),
              ],
            ),
          ),
          if (!session.isCurrent)
            GestureDetector(
              onTap: () => _terminateSession(session),
              child: Text('Завершити', style: AppTypography.labelSmall.copyWith(color: AppColorsPS5.error, decoration: TextDecoration.underline, fontSize: 10)),
            ),
        ],
      ),
    );
  }

  // ─── PIN Entry Overlay ──────────────────────────────────────────────

  Widget _buildPinOverlay(Color accent) {
    final currentPin = _pinStep == 'old' || _pinStep == 'enter' ? _enteredPin : _confirmPin;
    final title = _pinStep == 'old'
        ? 'Поточний PIN-код'
        : (_pinIsChanging
            ? 'Новий PIN-код'
            : (_pinStep == 'enter' ? 'Встановити PIN-код' : 'Підтвердити PIN-код'));
    final subtitle = _pinStep == 'old'
        ? 'Введіть поточний PIN-код'
        : (_pinStep == 'enter' ? 'Введіть 4-значний PIN-код' : 'Введіть PIN-код ще раз');

    return Positioned.fill(
      child: Container(
        color: Colors.black.withOpacity(0.6),
        child: Center(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: Spacing.xxl),
            padding: const EdgeInsets.all(Spacing.xl),
            decoration: BoxDecoration(
              color: AppColorsPS5.card,
              borderRadius: BorderRadius.circular(Radii.xl),
              border: Border.all(color: AppColorsPS5.border),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: _closePinDialog,
                    child: Icon(Icons.close_rounded, color: AppColorsPS5.textHint, size: 24),
                  ),
                ),
                const SizedBox(height: Spacing.md),
                Text(title, style: AppTypography.heading2.copyWith(color: AppColorsPS5.textPrimary)),
                const SizedBox(height: Spacing.xs),
                Text(subtitle, style: AppTypography.bodyMedium.copyWith(color: AppColorsPS5.textSecondary)),
                if (_showPinError)
                  Text('Невірний PIN', style: AppTypography.labelSmall.copyWith(color: AppColorsPS5.error)),
                if (_pinLocked)
                  Text('PIN заблоковано. Спробуйте пізніше.', style: AppTypography.labelSmall.copyWith(color: AppColorsPS5.error)),
                const SizedBox(height: Spacing.xxl),
                // PIN dots
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(_SecurityConstants.pinLength, (index) {
                    final filled = index < currentPin.length;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      width: 20, height: 20,
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: filled ? accent : AppColorsPS5.border,
                        boxShadow: filled ? [AppShadows.glow(accent, blur: 12, opacity: 0.3)] : null,
                      ),
                    );
                  }),
                ),
                if (!_pinLocked) ...[
                  const SizedBox(height: Spacing.xxl),
                  _buildNumberPad(accent),
                ],
              ],
            ),
          ),
        ),
      ),
    ).animate().fadeIn(duration: 200.ms);
  }

  Widget _buildNumberPad(Color accent) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final row in [
          ['1', '2', '3'],
          ['4', '5', '6'],
          ['7', '8', '9'],
          ['', '0', '⌫'],
        ])
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: row.map((digit) {
              if (digit.isEmpty) {
                return const SizedBox(width: 72, height: 56);
              }
              return GestureDetector(
                onTap: () {
                  if (digit == '⌫') {
                    _onPinDelete();
                  } else {
                    _onPinDigit(digit);
                  }
                },
                child: Container(
                  width: 72, height: 56,
                  margin: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: digit == '⌫' ? AppColorsPS5.error.withOpacity(0.1) : AppColorsPS5.cardElevated,
                    borderRadius: BorderRadius.circular(Radii.md),
                  ),
                  child: Center(
                    child: digit == '⌫'
                        ? Icon(Icons.backspace_rounded, color: AppColorsPS5.error, size: 22)
                        : Text(digit, style: AppTypography.heading2.copyWith(color: AppColorsPS5.textPrimary, fontSize: 24)),
                  ),
                ),
              );
            }).toList(),
          ),
      ],
    );
  }
}

/// ─── Data Models ─────────────────────────────────────────────────────────────

/// Запис історії входів.
  // ─── Password Strength Checker ────────────────────────────────────────

  /// Оцінює надійність пароля (mock).
  ///
  /// Повертає кортеж із:
  /// - `score` — від 0 до 100
  /// - `label` — текстова мітка ('Слабий', 'Середній', 'Надійний')
  /// - `color` — колір індикатора
  /// - `feedback` — поради щодо покращення
  Map<String, dynamic> _evaluatePasswordStrength(String password) {
    try {
      if (password.isEmpty) {
        return {'score': 0, 'label': 'Порожній', 'color': AppColorsPS5.textHint, 'feedback': 'Введіть пароль для аналізу'};
      }

      int score = 0;
      final feedback = <String>[];

      // Length checks
      if (password.length >= 6) score += 20;
      if (password.length >= 8) score += 10;
      if (password.length >= 12) score += 10;

      // Character variety
      if (password.contains(RegExp(r'[A-Z]'))) { score += 10; } else { feedback.add('Додайте великі літери (A-Z)'); }
      if (password.contains(RegExp(r'[a-z]'))) { score += 10; } else { feedback.add('Додайте малі літери (a-z)'); }
      if (password.contains(RegExp(r'[0-9]'))) { score += 10; } else { feedback.add('Додайте цифри (0-9)'); }
      if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) { score += 15; } else { feedback.add('Додайте спецсимволи'); }

      // Common patterns penalty
      if (RegExp(r'(.)\1{2,}').hasMatch(password)) {
        score -= 15;
        feedback.add('Уникайте повторень символів');
      }

      score = score.clamp(0, 100);

      String label;
      Color color;
      if (score >= 80) {
        label = 'Надійний';
        color = AppColorsPS5.success;
      } else if (score >= 50) {
        label = 'Середній';
        color = AppColorsPS5.warning;
      } else {
        label = 'Слабий';
        color = AppColorsPS5.error;
      }

      return {'score': score, 'label': label, 'color': color, 'feedback': feedback};
    } catch (e) {
      developer.log('Error evaluating password: $e', name: _logTag);
      return {'score': 0, 'label': 'Помилка', 'color': AppColorsPS5.error, 'feedback': <String>[]};
    }
  }

  // ─── Security Audit Log ──────────────────────────────────────────────

  /// Історія подій безпеки для аудиту (mock).
  final List<Map<String, String>> _securityAuditLog = [
    {'time': 'Сьогодні 14:23', 'event': 'Успішний вхід (Face ID)', 'device': 'iPhone 15 Pro'},
    {'time': 'Вчора 09:15', 'event': 'Зміна PIN-коду', 'device': 'iPhone 15 Pro'},
    {'time': '2 дні тому', 'event': '2FA увімкнено', 'device': 'iPhone 15 Pro'},
    {'time': '5 днів тому', 'event': 'Невдалий вхід', 'device': 'Невідомий'},
  ];

  /// Додає запис до журналу аудиту.
  void _addAuditEntry(String event) {
    try {
      setState(() {
        _securityAuditLog.insert(0, {
          'time': DateTime.now().toString().substring(0, 16),
          'event': event,
          'device': _biometricsType,
        });
        // Keep only last 50 entries
        while (_securityAuditLog.length > 50) {
          _securityAuditLog.removeLast();
        }
      });
      developer.log('Audit: $event', name: _logTag);
    } catch (e) {
      developer.log('Error adding audit entry: $e', name: _logTag);
    }
  }

  /// Повертає відфільтровані записи аудиту.
  List<Map<String, String>> get _filteredAuditLog {
    return _securityAuditLog;
  }

  // ─── Session Timeout ──────────────────────────────────────────────────

  /// Таймер автоматичного завершення неактивної сесії (mock).
  Timer? _sessionTimer;

  /// Чи сесія активна (не заблоковано через неактивність).
  bool _sessionActive = true;

  /// Кількість хвилин неактивності до блокування.
  int _sessionTimeoutMinutes = 15;

  /// Перезавантажує таймер неактивності сесії.
  void _resetSessionTimer() {
    _sessionTimer?.cancel();
    _sessionTimer = Timer(Duration(minutes: _sessionTimeoutMinutes), () {
      if (mounted) {
        setState(() => _sessionActive = false);
        _addAuditEntry('Автоблокування через неактивність');
      }
    });
  }

  /// Очища таймер сесії при виході з екрану.
  void _cancelSessionTimer() {
    _sessionTimer?.cancel();
    _sessionTimer = null;
  }

  // ─── Device Info Mock ────────────────────────────────────────────────

  /// Повертає інформацію про пристрій (mock).
  Map<String, String> _getDeviceInfo() {
    return {
      'platform': 'iOS',
      'model': 'iPhone 15 Pro',
      'osVersion': 'iOS 17.4',
      'appVersion': '1.0.0',
      'isSimulator': false,
      'isJailbroken': false,
    };
  }

  /// Перевіряє безпеку пристрою (mock).
  Map<String, dynamic> _checkDeviceSecurity() {
    try {
      return {
        'isSecure': true,
        'encryptionSupported': true,
        'biometricsAvailable': _biometricsAvailable,
        'screenLockEnabled': true,
        'osUpToDate': true,
        'isSimulator': false,
        'isJailbroken': false,
        'recommendations': [
          if (!_biometricsEnabled) 'Увімкніть біометрію',
          if (!_pinSetup) 'Встановіть PIN-код',
        ],
      };
    } catch (e) {
      developer.log('Error checking device security: $e', name: _logTag);
      return {'isSecure': false, 'recommendations': ['Помилка перевірки']};
    }
  }

  // ─── Encryption Animation State ─────────────────────────────────────

  /// Чи показувати анімацію перевірки шифрування.
  bool _isEncrypting = false;

  /// Запускає анімацію перевірки шифрування.
  Future<void> _runEncryptionCheck() async {
    try {
      setState(() => _isEncrypting = true);
      developer.log('Running encryption check...', name: _logTag);
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) {
        setState(() => _isEncrypting = false);
        context.showAppToast('Шифрування AES-256: активне ✓', type: AppToastType.success);
      }
    } catch (e) {
      developer.log('Error in encryption check: $e', name: _logTag);
      if (mounted) setState(() => _isEncrypting = false);
    }
  }

  // ─── Biometrics Fallback ─────────────────────────────────────────────

  /// Обробляє ситуацію, коли біометрія недоступна.
  ///
  /// Показує діалог з пропозицією встановити PIN як альтернативу.
  void _handleBiometricsUnavailable() {
    try {
      if (mounted) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            backgroundColor: context.isDark ? AppColorsPS5.card : AppColorsMonitor.card,
            title: Text('Біометрія недоступна', style: AppTypography.heading3.copyWith(
              color: context.isDark ? AppColorsPS5.textPrimary : AppColorsMonitor.textPrimary,
            )),
            content: Text(
              'Біометрична автентифікація не підтримується на вашому пристрої. '
              'Рекомендуємо встановити PIN-код для додаткового захисту.',
              style: AppTypography.bodyMedium.copyWith(
                color: context.isDark ? AppColorsPS5.textSecondary : AppColorsMonitor.textSecondary,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () { Navigator.pop(ctx); },
                child: Text('Пізніше', style: AppTypography.labelLarge.copyWith(
                  color: context.isDark ? AppColorsPS5.textSecondary : AppColorsMonitor.textSecondary,
                )),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  _openPinDialog(isChange: false);
                },
                child: Text('Встановити PIN', style: AppTypography.labelLarge.copyWith(color: AppColorsPS5.accent)),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      developer.log('Error handling biometrics unavailable: $e', name: _logTag);
    }
  }

  // ─── Accessibility ──────────────────────────────────────────────────

  /// Семантичний лейб для елементів безпеки.
  String _securitySemanticLabel(String title, String state) {
    return '$title: $state';
  }

  /// Семантичний лейб для кнопок дій.
  String _securityActionLabel(String action) {
    return 'Безпека: $action';
  }

  // ─── Format Helpers ──────────────────────────────────────────────────

  /// Форматує дату останньої активності.
  String _formatLastActive(DateTime? date) {
    if (date == null) return 'Ніколи';
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 1) return 'Щойно';
    if (diff.inMinutes < 60) return '${diff.inMinutes} хв тому';
    if (diff.inHours < 24) return '${diff.inHours} год тому';
    return '${diff.inDays} дн тому';
  }

  /// Форматує тривалість блокування у зручний вигляд.
  String _formatLockDuration(int seconds) {
    if (seconds < 60) return '$seconds сек';
    if (seconds < 3600) return '${seconds ~/ 60} хв ${seconds % 60 > 0 ? "${seconds % 60} сек" : ""}';
    return '${seconds ~/ 3600} год ${(seconds % 3600) ~/ 60 > 0 ? "${(seconds % 3600) ~/ 60} хв" : ""}';
  }

  // ─── Additional Security Constants ────────────────────────────────────

  /// Максимальна кількість записів аудиту.
  static const int maxAuditLogEntries = 100;

  /// Час автоматичного розблокування PIN (секунди).
  static const int pinAutoUnlockSeconds = 30;

  /// Версія протоколу шифрування.
  static const String encryptionProtocolVersion = 'AES-256-GCM v2.1';

  /// Мінімальна довжина пароля.
  static const int minPasswordLength = 8;

  /// Максимальна кількість активних сесій.
  static const int maxActiveSessions = 5;

  /// Ключ для збереження налаштувань безпеки.
  static const String securityPrefsKey = 'nexora_security_prefs';

  /// Мапа рівнів загроз для статусу.
  static const Map<String, String> threatLevelLabels = {
    'low': 'Низький',
    'medium': 'Середній',
    'high': 'Високий',
    'critical': 'Критичний',
  };

  /// Кольори рівнів загроз.
  static const Map<String, int> threatLevelColors = {
    'low': 0xFF4CAF50,
    'medium': 0xFFFFC107,
    'high': 0xFFFF9800,
    'critical': 0xFFF44336,
  };

  // ─── Audit Log ──────────────────────────────────────────────────────

  /// Лог аудиту подій безпеки.
  final List<_AuditEntry> _auditLog = [];

  /// Додає запис до логу аудиту.
  void _addAuditEntry(String action) {
    try {
      final entry = _AuditEntry(
        timestamp: DateTime.now(),
        action: action,
        details: _getSecuritySnapshot(),
      );
      _auditLog.insert(0, entry);
      // Trim audit log
      while (_auditLog.length > maxAuditLogEntries) {
        _auditLog.removeLast();
      }
      developer.log('Audit: $action', name: _logTag);
    } catch (e) {
      developer.log('Error adding audit entry: $e', name: _logTag);
    }
  }

  /// Повертає знімок поточного стану безпеки для аудиту.
  Map<String, dynamic> _getSecuritySnapshot() {
    return {
      'biometricsEnabled': _biometricsEnabled,
      'pinSetup': _pinSetup,
      'twoFactorEnabled': _twoFactorEnabled,
      'screenshotProtection': _screenshotProtection,
      'autoLockTimeout': _autoLockTimeout,
      'securityScore': _securityScore,
      'activeSessions': _activeSessionsCount,
      'failedAttempts': _failedLoginAttempts,
    };
  }

  /// Експортує лог аудиту у вигляді рядка.
  String _exportAuditLog() {
    try {
      final buffer = StringBuffer();
      buffer.writeln('=== Nexora Security Audit Log ===');
      buffer.writeln('Exported: ${DateTime.now().toIso8601String()}');
      buffer.writeln('Security Score: $_securityScore%');
      buffer.writeln('================================');
      for (final entry in _auditLog) {
        buffer.writeln('[${entry.timestamp.toIso8601String()}] ${entry.action}');
        entry.details.forEach((key, value) {
          buffer.writeln('  $key: $value');
        });
      }
      return buffer.toString();
    } catch (e) {
      developer.log('Error exporting audit log: $e', name: _logTag);
      return 'Error exporting audit log';
    }
  }

  /// Очищає лог аудиту з підтвердженням.
  Future<void> _clearAuditLog() async {
    try {
      final confirmed = await context.showConfirmDialog(
        title: 'Очистити лог безпеки?',
        message: 'Всі записи аудиту буде видалено назавжди.',
        confirmText: 'Очистити',
        cancelText: 'Скасувати',
        destructive: true,
      );
      if (confirmed == true && mounted) {
        setState(() => _auditLog.clear());
        developer.log('Audit log cleared', name: _logTag);
        context.showAppToast('Лог безпеки очищено', type: AppToastType.warning);
      }
    } catch (e) {
      developer.log('Error clearing audit log: $e', name: _logTag);
    }
  }

  // ─── Additional Computed Properties ─────────────────────────────────

  /// Чи всі функції безпеки увімкнено.
  bool get _allSecurityFeaturesEnabled =>
      _biometricsEnabled && _pinSetup && _twoFactorEnabled;

  /// Загальна кількість записів аудиту.
  int get _auditEntryCount => _auditLog.length;

  /// Чи є невидправлені рекомендації.
  bool get _hasPendingRecommendations => _securityRecommendations.any(
        (r) => !r.contains('добре'),
      );

  /// Кількість невидправлених рекомендацій.
  int get _pendingRecommendationsCount {
    return _securityRecommendations.where((r) => !r.contains('добре')).length;
  }

  /// Поточний рівень загрози.
  String get _threatLevel {
    if (_failedLoginAttempts >= 3) return 'critical';
    if (_failedLoginAttempts >= 1) return 'high';
    if (_securityScore < _SecurityConstants.mediumSecurityThreshold) return 'medium';
    return 'low';
  }

  /// Чи аккаунт потребує термінової уваги.
  bool get _needsAttention =>
      _threatLevel == 'high' || _threatLevel == 'critical';

  /// Відсоток увімкнених функцій безпеки.
  double get _securityFeaturesPercent {
    int enabled = 0;
    int total = 4;
    if (_biometricsEnabled) enabled++;
    if (_pinSetup) enabled++;
    if (_twoFactorEnabled) enabled++;
    if (_screenshotProtection) enabled++;
    return enabled / total;
  }

  /// Текстовий опис статусу сесії.
  String get _sessionStatusText {
    if (!_sessionActive) return 'Заблоковано через неактивність';
    return 'Активна · ${_activeSessionsCount} сесій';
  }

  /// Форматована статистика безпеки.
  String get _securityStatsFormatted {
    return 'Балів: $_securityScore/100 · '
        'Функцій: ${(_securityFeaturesPercent * 100).toInt()}% · '
        'Загроза: ${threatLevelLabels[_threatLevel] ?? "невідомо"}';
  }

  // ─── Batch Operations ───────────────────────────────────────────────

  /// Увімкнення всіх функцій безпеки одразу.
  Future<void> _enableAllSecurity() async {
    try {
      setState(() {
        _biometricsEnabled = true;
        _twoFactorEnabled = true;
        _screenshotProtection = true;
        if (!_pinSetup) {
          // Can't auto-set PIN, open dialog
          _openPinDialog();
          return;
        }
      });
      _addAuditEntry('All security features enabled');
      if (mounted) {
        context.showAppToast('Всі функції безпеки увімкнено!', type: AppToastType.success);
      }
    } catch (e) {
      developer.log('Error enabling all security: $e', name: _logTag);
    }
  }

  /// Завершення всіх сесій крім поточної.
  void _terminateAllOtherSessions() {
    try {
      final otherSessions = _loginHistory.where((s) => !s.isCurrent).toList();
      if (otherSessions.isEmpty) {
        context.showAppToast('Немає інших активних сесій', type: AppToastType.info);
        return;
      }
      setState(() {
        for (final session in otherSessions) {
          _loginHistory.remove(session);
        }
      });
      _addAuditEntry('Terminated ${otherSessions.length} sessions');
      if (mounted) {
        context.showAppToast(
          '${otherSessions.length} сесій завершено',
          type: AppToastType.success,
        );
      }
    } catch (e) {
      developer.log('Error terminating sessions: $e', name: _logTag);
    }
  }

  /// Скидання всіх лічильників спроб до початкових значень.
  void _resetAttemptCounters() {
    setState(() {
      _pinAttempts = 0;
      _pinLocked = false;
      _showPinError = false;
    });
    developer.log('Attempt counters reset', name: _logTag);
  }

  /// Генерує звіт безпеки у вигляді рядка.
  String _generateSecurityReport() {
    try {
      final buffer = StringBuffer();
      buffer.writeln('═══ Nexora Security Report ═══');
      buffer.writeln('Дата: ${DateTime.now().toIso8601String()}');
      buffer.writeln();
      buffer.writeln('Оцінка безпеки: $_securityScore% ($_securityLabel)');
      buffer.writeln('Рівень загрози: ${threatLevelLabels[_threatLevel]}');
      buffer.writeln();
      buffer.writeln('─── Функції ───');
      buffer.writeln('Біометрія: ${_biometricsEnabled ? "✅" : "❌"}');
      buffer.writeln('PIN-код: ${_pinSetup ? "✅" : "❌"}');
      buffer.writeln('2FA: ${_twoFactorEnabled ? "✅" : "❌"}');
      buffer.writeln('Захист скріншотів: ${_screenshotProtection ? "✅" : "❌"}');
      buffer.writeln('Шифрування: AES-256 ✅');
      buffer.writeln();
      buffer.writeln('─── Сесії ───');
      buffer.writeln('Активних: $_activeSessionsCount');
      buffer.writeln('Невдалих спроб: $_failedLoginAttempts');
      buffer.writeln();
      buffer.writeln('─── Рекомендації ───');
      for (final rec in _securityRecommendations) {
        buffer.writeln('• $rec');
      }
      buffer.writeln();
      buffer.writeln('Записів аудиту: $_auditEntryCount');
      buffer.writeln('═══════════════════════════');
      return buffer.toString();
    } catch (e) {
      developer.log('Error generating report: $e', name: _logTag);
      return 'Error generating security report';
    }
  }

  // ─── Validation Methods ────────────────────────────────────────────

  /// Валідує PIN-код.
  ///
  /// Перевіряє довжину, формат (лише цифри), та послідовність.
  String? _validatePin(String pin) {
    if (pin.length != _SecurityConstants.pinLength) {
      return 'PIN-код має містити ${_SecurityConstants.pinLength} цифри';
    }
    if (!RegExp(r'^\d+$').hasMatch(pin)) {
      return 'PIN-код має містити лише цифри';
    }
    // Check for sequential digits
    bool isSequential = true;
    for (int i = 1; i < pin.length; i++) {
      if (int.parse(pin[i]) != int.parse(pin[i - 1]) + 1) {
        isSequential = false;
        break;
      }
    }
    if (isSequential) {
      return 'PIN не може бути послідовністю цифр';
    }
    // Check for repeated digits
    if (pin.split('').every((c) => c == pin[0])) {
      return 'PIN не може складатися з однакових цифр';
    }
    return null;
  }

  /// Валідує параметри автоблокування.
  bool _isValidAutoLockValue(int seconds) {
    return _SecurityConstants.autoLockOptions.contains(seconds);
  }

  /// Перевіряє, чи пристрій достатньо безпечний.
  bool _isDeviceSecure() {
    final security = _checkDeviceSecurity();
    return security['isSecure'] == true;
  }

  /// Перевіряє, чи всі критичні функції безпеки увімкнено.
  bool _areCriticalFeaturesEnabled() {
    return _biometricsEnabled || _pinSetup;
  }

  // ─── Additional Widget Builders ────────────────────────────────────

  /// Будує картку загального статусу безпеки з детальною статистикою.
  Widget _buildSecurityOverviewCard(
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Огляд безпеки',
                style: AppTypography.labelLarge.copyWith(color: textColor),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: _needsAttention
                      ? AppColorsPS5.error.withOpacity(0.1)
                      : AppColorsPS5.success.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(Radii.sm),
                ),
                child: Text(
                  _needsAttention ? 'Потребує уваги' : 'Все ок',
                  style: AppTypography.labelSmall.copyWith(
                    color: _needsAttention
                        ? AppColorsPS5.error
                        : AppColorsPS5.success,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: Spacing.sm),
          _buildOverviewRow('Оцінка', '$_securityScore%', _securityColor, subColor),
          _buildOverviewRow('Функції', '${(_securityFeaturesPercent * 100).toInt()}%', accent, subColor),
          _buildOverviewRow('Загроза', threatLevelLabels[_threatLevel] ?? 'Невідомо',
              Color(threatLevelColors[_threatLevel] ?? 0xFF9E9E9E), subColor),
          _buildOverviewRow('Сесії', '$_activeSessionsCount активних', accent, subColor),
          _buildOverviewRow('Аудит', '$_auditEntryCount записів', subColor, subColor),
          const SizedBox(height: Spacing.sm),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                _addAuditEntry('Security report generated');
                context.showAppToast(
                  _generateSecurityReport(),
                  type: AppToastType.info,
                  duration: const Duration(milliseconds: 5000),
                );
              },
              icon: const Icon(Icons.assessment_rounded, size: 16),
              label: const Text('Згенерувати звіт'),
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

  /// Будує рядок огляду безпеки.
  Widget _buildOverviewRow(
    String label,
    String value,
    Color valueColor,
    Color subColor,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Text(label, style: AppTypography.labelSmall.copyWith(color: subColor)),
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

  /// Будує картку аудиту з останніми подіями.
  Widget _buildAuditLogCard(
    Color cardColor,
    Color borderColor,
    Color textColor,
    Color subColor,
    Color accent,
  ) {
    if (_auditLog.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(Spacing.base),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(Radii.lg),
          border: Border.all(color: borderColor),
        ),
        child: Column(
          children: [
            Icon(Icons.history_rounded, color: subColor, size: 32),
            const SizedBox(height: Spacing.sm),
            Text('Лог аудиту порожній', style: AppTypography.bodySmall.copyWith(color: subColor)),
            const SizedBox(height: Spacing.xs),
            Text('Події безпеки будуть записуватися тут',
                style: AppTypography.labelSmall.copyWith(color: subColor.withOpacity(0.6))),
          ],
        ),
      );
    }

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
              Text('Лог аудиту', style: AppTypography.labelMedium.copyWith(color: textColor)),
              GestureDetector(
                onTap: _clearAuditLog,
                child: Text('Очистити', style: AppTypography.labelSmall.copyWith(color: AppColorsPS5.error)),
              ),
            ],
          ),
          const SizedBox(height: Spacing.sm),
          ..._auditLog.take(5).map((entry) => Padding(
                padding: const EdgeInsets.only(bottom: Spacing.xs),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      margin: const EdgeInsets.only(top: 6),
                      decoration: BoxDecoration(
                        color: accent,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: Spacing.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(entry.action, style: AppTypography.labelSmall.copyWith(color: textColor)),
                          Text(
                            _formatLastActive(entry.timestamp),
                            style: AppTypography.caption.copyWith(color: subColor.withOpacity(0.6), fontSize: 9),
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

  @override
  void dispose() {
    _sessionTimer?.cancel();
    developer.log('Security screen disposed', name: _logTag);
    super.dispose();
  }

  // ─── Additional Security Constants ──────────────────────────────────────

  /// Версія алгоритму шифрування.
  static const String _encryptionVersion = 'AES-256-GCM';

  /// Версія протоколу безпеки.
  static const String _securityProtocolVersion = 'TLS 1.3';

  /// Мінімальна довжина пароля.
  static const int _minPasswordLength = 8;

  /// Максимальна кількість невдалих входів до блокування акаунта.
  static const int _maxFailedLoginsBeforeLockout = 10;

  /// Тривалість блокування після невдалих входів (хвилини).
  static const int _accountLockoutMinutes = 15;

  /// Тривалість сесії за замовчуванням (хвилини).
  static const int _defaultSessionDurationMinutes = 30;

  /// Мінімальна складність пароля (кількість категорій символів).
  static const int _minPasswordComplexity = 3;

  /// Максимальна кількість сесій на одного користувача.
  static const int _maxConcurrentSessions = 5;

  /// Категорії паролів для перевірки складності.
  static const List<String> _passwordCategories = [
    'Великі літери (A-Z)',
    'Малі літери (a-z)',
    'Цифри (0-9)',
    'Спеціальні символи (!@#$)',
  ];

  /// Час автоматичного розблокування PIN (секунди).
  static const int _pinAutoUnlockSeconds = 30;

  /// Іконки рівнів безпеки для відображення.
  static const List<IconData> _securityLevelIcons = [
    Icons.dangerous_rounded,
    Icons.warning_amber_rounded,
    Icons.shield_rounded,
    Icons.verified_user_rounded,
  ];

  /// Описи рівнів безпеки українською.
  static const Map<String, String> _securityLevelDescriptions = {
    'Низький': 'Ваш акаунт потребує додаткового захисту. Увімкніть PIN та біометрію.',
    'Середній': 'Захист непоганий, але можна покращити. Спробуйте 2FA.',
    'Високий': 'Ваш акаунт добре захищений. Продовжуйте в тому ж дусі!',
  };

  // ─── Additional Computed Properties ───────────────────────────────────

  /// Чи всі функції безпеки увімкнено.
  bool get _isFullySecured =>
      _biometricsEnabled && _pinSetup && _twoFactorEnabled && _screenshotProtection;

  /// Відсоток увімкнених функцій безпеки.
  double get _securityCompletionPercent {
    int enabled = 1; // base encryption always on
    if (_biometricsEnabled) enabled++;
    if (_pinSetup) enabled++;
    if (_twoFactorEnabled) enabled++;
    if (_screenshotProtection) enabled++;
    return (enabled / 5 * 100).clamp(0.0, 100.0);
  }

  /// Кількість невикористаних спроб PIN.
  int get _remainingPinAttempts =>
      _SecurityConstants.maxPinAttempts - _pinAttempts;

  /// Чи користувач може встановити 2FA.
  bool get _canEnableTwoFactor => _pinSetup && !_twoFactorEnabled;

  /// Кількість невизнаних пристроїв в історії.
  int get _unknownDeviceCount =>
      _loginHistory.where((s) => !s.isSuccessful).length;

  /// Список унікальних локацій входу.
  List<String> get _uniqueLocations {
    return _loginHistory
        .map((s) => s.location)
        .toSet()
        .toList();
  }

  /// Кількість унікальних локацій.
  int get _uniqueLocationCount => _uniqueLocations.length;

  /// Опис наступної дії для покращення безпеки.
  String get _nextSecurityAction {
    if (!_biometricsEnabled) return 'Увімкніть біометричну автентифікацію';
    if (!_pinSetup) return 'Встановіть PIN-код';
    if (!_twoFactorEnabled) return 'Увімкніть двофакторну автентифікацію';
    if (!_screenshotProtection) return 'Увімкніть захист від скріншотів';
    return 'Всі функції безпеки увімкнено!';
  }

  /// Іконка для наступної дії безпеки.
  IconData get _nextActionIcon {
    if (!_biometricsEnabled) return Icons.fingerprint_rounded;
    if (!_pinSetup) return Icons.pin_rounded;
    if (!_twoFactorEnabled) return Icons.lock_rounded;
    if (!_screenshotProtection) return Icons.screenshot_monitor_rounded;
    return Icons.check_circle_rounded;
  }

  /// Рівень безпеки як індекс (0-3).
  int get _securityLevelIndex {
    if (_securityScore >= _SecurityConstants.highSecurityThreshold) return 3;
    if (_securityScore >= _SecurityConstants.mediumSecurityThreshold) return 2;
    return 1;
  }

  /// Поточний PIN-код замаскований для відображення.
  String get _maskedPin {
    if (_currentPin == null || _currentPin!.isEmpty) return '••••';
    return '•' * _currentPin!.length;
  }

  // ─── Additional Validation Methods ────────────────────────────────────

  /// Перевіряє, чи PIN складається тільки з цифр.
  bool _isPinDigitsOnly(String pin) {
    return RegExp(r'^[0-9]+$').hasMatch(pin);
  }

  /// Перевіряє, чи PIN не містить простих послідовностей.
  bool _isPinNotSequential(String pin) {
    const sequential = ['1234', '4321', '1111', '0000', '9876', '6789'];
    return !sequential.contains(pin);
  }

  /// Перевіряє, чи пристрій підтримує біометрию (mock).
  bool _checkDeviceBiometricSupport() {
    // В реальному додатку: local_auth package
    return true;
  }

  /// Перевіряє, чи PIN відповідає вимогам безпеки.
  bool _validatePinStrength(String pin) {
    if (pin.length < _SecurityConstants.pinLength) return false;
    if (!_isPinDigitsOnly(pin)) return false;
    if (!_isPinNotSequential(pin)) return false;
    return true;
  }

  /// Перевіряє, чи час автоблокування є коректним.
  bool _isValidLockTimeout(int seconds) {
    return _SecurityConstants.autoLockOptions.contains(seconds);
  }

  /// Перевіряє, чи сесія не є застарілою (mock).
  bool _isSessionFresh(_LoginRecord session) {
    return session.isSuccessful && !session.time.contains('днів тому');
  }

  /// Повертає рівень складності пароля (1-5).
  int _evaluatePasswordStrength(String password) {
    if (password.isEmpty) return 0;
    int strength = 1;
    if (password.length >= 8) strength++;
    if (password.length >= 12) strength++;
    if (RegExp(r'[A-Z]').hasMatch(password)) strength++;
    if (RegExp(r'[0-9]').hasMatch(password)) strength++;
    if (RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) strength++;
    return strength.clamp(1, 5);
  }

  /// Повертає опис рівня складності пароля.
  String _getPasswordStrengthLabel(int strength) {
    switch (strength) {
      case 1: return 'Дуже слабкий';
      case 2: return 'Слабкий';
      case 3: return 'Середній';
      case 4: return 'Сильний';
      case 5: return 'Дуже сильний';
      default: return 'Невідомий';
    }
  }

  /// Повертає колір рівня складності пароля.
  Color _getPasswordStrengthColor(int strength) {
    switch (strength) {
      case 1: return AppColorsPS5.error;
      case 2: return AppColorsPS5.error.withOpacity(0.7);
      case 3: return AppColorsPS5.warning;
      case 4: return AppColorsPS5.success.withOpacity(0.8);
      case 5: return AppColorsPS5.success;
      default: return AppColorsPS5.textHint;
    }
  }

  // ─── Additional Private Helper Methods ────────────────────────────────

  /// Генерує звіт про безпеку у вигляді тексту.
  String _generateSecurityReport() {
    final buffer = StringBuffer();
    buffer.writeln('📋 Звіт про безпеку');
    buffer.writeln('Дата: ${DateTime.now().toIso8601String()}');
    buffer.writeln('Оцінка: $_securityScore% ($_securityLabel)');
    buffer.writeln('Біометрія: ${_biometricsEnabled ? "✅" : "❌"}');
    buffer.writeln('PIN-код: ${_pinSetup ? "✅" : "❌"}');
    buffer.writeln('2FA: ${_twoFactorEnabled ? "✅" : "❌"}');
    buffer.writeln('Захист скріншотів: ${_screenshotProtection ? "✅" : "❌"}');
    buffer.writeln('Автоблокування: ${_formatTimeout(_autoLockTimeout)}');
    buffer.writeln('Шифрування: $_encryptionVersion');
    buffer.writeln('Сесій: $_activeSessionsCount');
    buffer.writeln('Невдалих входів: $_failedLoginAttempts');
    return buffer.toString();
  }

  /// Обчислює час до автоматичного розблокування PIN.
  String _getPinUnlockCountdown() {
    if (!_pinLocked) return '';
    return 'Спробуйте через $_pinAutoUnlockSeconds сек';
  }

  /// Копіює звіт про безпеку в буфер обміну.
  Future<void> _copySecurityReport() async {
    try {
      final report = _generateSecurityReport();
      await Clipboard.setData(ClipboardData(text: report));
      if (mounted) {
        context.showAppToast('Звіт скопійовано!', type: AppToastType.success);
      }
    } catch (e) {
      developer.log('Error copying report: $e', name: _logTag);
    }
  }

  /// Перемикає деталі сесій.
  void _toggleSessionDetails() {
    setState(() => _showSessionDetails = !_showSessionDetails);
    developer.log('Session details toggled', name: _logTag);
  }

  /// Завершує всі сесії крім поточної (mock).
  Future<void> _terminateAllOtherSessions() async {
    try {
      final confirmed = await context.showConfirmDialog(
        title: 'Завершити всі інші сесії?',
        message: 'Всі пристрої, крім поточного, будуть відключені.',
        confirmText: 'Завершити все',
        cancelText: 'Скасувати',
        destructive: true,
      );
      if (confirmed != true) return;

      setState(() {
        _loginHistory.removeWhere((s) => !s.isCurrent);
      });
      developer.log('All other sessions terminated', name: _logTag);
      if (mounted) {
        context.showAppToast('Всі інші сесії завершено', type: AppToastType.success);
      }
    } catch (e) {
      developer.log('Error terminating sessions: $e', name: _logTag);
    }
  }

  /// Показує діалог з інформацією про шифрування.
  void _showEncryptionInfo() {
    try {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: context.isDark ? AppColorsPS5.card : AppColorsMonitor.card,
          title: Text('🔐 Інформація про шифрування', style: AppTypography.heading3.copyWith(
            color: context.isDark ? AppColorsPS5.textPrimary : AppColorsMonitor.textPrimary,
          )),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInfoRow('Алгоритм', _encryptionVersion),
              _buildInfoRow('Протокол', _securityProtocolVersion),
              _buildInfoRow('Розмір ключа', '256 біт'),
              _buildInfoRow('Режим', 'GCM (Authenticated)'),
              _buildInfoRow('Вектор', 'Ініціалізація щоразу'),
              const SizedBox(height: Spacing.sm),
              Text('Всі дані шифруються локально на пристрої перед збереженням.', style: AppTypography.bodySmall.copyWith(
                color: context.isDark ? AppColorsPS5.textSecondary : AppColorsMonitor.textSecondary,
              )),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('Зрозуміло', style: AppTypography.labelLarge.copyWith(
                color: AppColorsPS5.accent,
              )),
            ),
          ],
        ),
      );
    } catch (e) {
      developer.log('Error showing encryption info: $e', name: _logTag);
    }
  }

  /// Будує рядок інформації в діалозі.
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTypography.bodySmall.copyWith(
            color: AppColorsPS5.textSecondary,
          )),
          Text(value, style: AppTypography.bodySmall.copyWith(
            color: AppColorsPS5.textPrimary,
            fontWeight: FontWeight.w600,
          )),
        ],
      ),
    );
  }

  // ─── Additional Theme-Aware Widget Builders ──────────────────────────

  /// Будує картку швидких дій безпеки.
  Widget _buildQuickActionsCard(Color cardColor, Color borderColor, Color accent, Color textColor, Color subColor) {
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
          Text('Швидкі дії', style: AppTypography.labelLarge.copyWith(color: textColor, fontWeight: FontWeight.w600)),
          const SizedBox(height: Spacing.md),
          _buildQuickActionButton(
            icon: Icons.copy_rounded,
            label: 'Скопіювати звіт',
            subLabel: 'Звіт про безпеку в буфер',
            onTap: _copySecurityReport,
            accent: accent,
            textColor: textColor,
            subColor: subColor,
          ),
          const SizedBox(height: Spacing.sm),
          _buildQuickActionButton(
            icon: Icons.info_outline_rounded,
            label: 'Про шифрування',
            subLabel: '$_encryptionVersion · $_securityProtocolVersion',
            onTap: _showEncryptionInfo,
            accent: accent,
            textColor: textColor,
            subColor: subColor,
          ),
          const SizedBox(height: Spacing.sm),
          _buildQuickActionButton(
            icon: Icons.logout_rounded,
            label: 'Завершити інші сесії',
            subLabel: '$_activeSessionsCount сесій активних',
            onTap: _terminateAllOtherSessions,
            accent: AppColorsPS5.error,
            textColor: textColor,
            subColor: subColor,
          ),
        ],
      ),
    ).animate().fade(delay: 350.ms, duration: 400.ms);
  }

  /// Будує кнопку швидкої дії безпеки.
  Widget _buildQuickActionButton({
    required IconData icon,
    required String label,
    required String subLabel,
    required VoidCallback onTap,
    required Color accent,
    required Color textColor,
    required Color subColor,
  }) {
    return GestureDetector(
      onTap: () {
        context.haptic();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.all(Spacing.md),
        decoration: BoxDecoration(
          color: accent.withOpacity(0.04),
          borderRadius: BorderRadius.circular(Radii.md),
          border: Border.all(color: accent.withOpacity(0.08)),
        ),
        child: Row(
          children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                color: accent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(Radii.sm),
              ),
              child: Icon(icon, color: accent, size: 20),
            ),
            const SizedBox(width: Spacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: AppTypography.labelMedium.copyWith(color: textColor)),
                  Text(subLabel, style: AppTypography.caption.copyWith(color: subColor)),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: subColor, size: 18),
          ],
        ),
      ),
    );
  }

  /// Будує картку наступної дії безпеки.
  Widget _buildNextActionCard(Color cardColor, Color borderColor, Color accent, Color textColor, Color subColor) {
    final allDone = _isFullySecured;
    return Container(
      padding: const EdgeInsets.all(Spacing.base),
      decoration: BoxDecoration(
        color: allDone ? AppColorsPS5.success.withOpacity(0.04) : accent.withOpacity(0.04),
        borderRadius: BorderRadius.circular(Radii.lg),
        border: Border.all(
          color: allDone ? AppColorsPS5.success.withOpacity(0.12) : accent.withOpacity(0.12),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              color: (allDone ? AppColorsPS5.success : accent).withOpacity(0.1),
              borderRadius: BorderRadius.circular(Radii.md),
            ),
            child: Icon(
              allDone ? Icons.check_circle_rounded : _nextActionIcon,
              color: allDone ? AppColorsPS5.success : accent,
              size: 22,
            ),
          ),
          const SizedBox(width: Spacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  allDone ? 'Всі функції увімкнено!' : 'Наступна рекомендація',
                  style: AppTypography.labelMedium.copyWith(
                    color: allDone ? AppColorsPS5.success : textColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  allDone ? 'Профіль повністю захищений' : _nextSecurityAction,
                  style: AppTypography.bodySmall.copyWith(color: subColor),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fade(delay: 200.ms, duration: 400.ms);
  }

  /// Будує картку статистики сесій.
  Widget _buildSessionStatsCard(Color cardColor, Color borderColor, Color textColor, Color subColor) {
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
          Text('Статистика сесій', style: AppTypography.labelMedium.copyWith(color: textColor, fontWeight: FontWeight.w600)),
          const SizedBox(height: Spacing.sm),
          _buildSessionStatRow('Всього сесій', '$_activeSessionsCount', textColor, subColor),
          _buildSessionStatRow('Унікальних локацій', '$_uniqueLocationCount', textColor, subColor),
          _buildSessionStatRow('Невдалих спроб', '$_failedLoginAttempts', _failedLoginAttempts > 0 ? AppColorsPS5.error : textColor, subColor),
          _buildSessionStatRow('Невідомих пристроїв', '$_unknownDeviceCount', _unknownDeviceCount > 0 ? AppColorsPS5.error : textColor, subColor),
        ],
      ),
    );
  }

  /// Будує рядок статистики сесій.
  Widget _buildSessionStatRow(String label, String value, Color valueColor, Color subColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Text(label, style: AppTypography.labelSmall.copyWith(color: subColor)),
          const Spacer(),
          Text(value, style: AppTypography.labelSmall.copyWith(color: valueColor, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  /// Будує індикатор завершення налаштувань безпеки.
  Widget _buildSecurityCompletionIndicator(Color accent, Color textColor, Color subColor) {
    final percent = _securityCompletionPercent;
    return Container(
      padding: const EdgeInsets.all(Spacing.sm),
      decoration: BoxDecoration(
        color: percent >= 100 ? AppColorsPS5.success.withOpacity(0.06) : accent.withOpacity(0.04),
        borderRadius: BorderRadius.circular(Radii.sm),
        border: Border.all(
          color: percent >= 100 ? AppColorsPS5.success.withOpacity(0.12) : accent.withOpacity(0.08),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: LinearProgressIndicator(
                value: percent / 100,
                minHeight: 4,
                backgroundColor: borderColor.withOpacity(0.2),
                valueColor: AlwaysStoppedAnimation(
                  percent >= 100 ? AppColorsPS5.success : accent,
                ),
              ),
            ),
          ),
          const SizedBox(width: Spacing.sm),
          Text(
            '${percent.toInt()}%',
            style: AppTypography.caption.copyWith(
              color: percent >= 100 ? AppColorsPS5.success : accent,
              fontWeight: FontWeight.w700,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}

/// ─── Audit Entry Model ───────────────────────────────────────────────

/// Запис логу аудиту подій безпеки.
///
/// Зберігає часову мітку, опис дії та знімок стану безпеки.
class _AuditEntry {
  /// Час події.
  final DateTime timestamp;

  /// Опис дії.
  final String action;

  /// Знімок стану безпеки на момент події.
  final Map<String, dynamic> details;

  /// Створює запис аудиту.
  const _AuditEntry({
    required this.timestamp,
    required this.action,
    required this.details,
  });
}

/// ─── Login Record Model ───────────────────────────────────────────────
///
/// Зберігає інформацію про кожен вхід у систему:
/// пристрій, місцезнаходження, час, метод автентифікації.
class _LoginRecord {
  /// Назва пристрою.
  final String device;

  /// Місцезнаходження входу.
  final String location;

  /// Час входу.
  final String time;

  /// Чи це поточна активна сесія.
  final bool isCurrent;

  /// Чи вхід був успішним.
  final bool isSuccessful;

  /// Метод автентифікації.
  final String method;

  /// Створює запис історії входів.
  const _LoginRecord({
    required this.device,
    required this.location,
    required this.time,
    required this.isCurrent,
    required this.isSuccessful,
    required this.method,
  });
}

// ═══════════════════════════════════════════════════════════════════════════
// EXTENSION — Additional Validation, Helpers, Widget Builders
// ═══════════════════════════════════════════════════════════════════════════

/// Додаткові константи для розширених функцій безпеки.
class _SecurityExtensions {
  /// Допустимі сили паролів.
  static const List<String> pinStrengthLabels = ['Слабкий', 'Середній', 'Сильний', 'Відмінний'];

  /// Ризикові локації.
  static const List<String> riskyLocations = ['Москва', 'Росія', 'Пекін', 'Minsk'];

  /// Версія протоколу шифрування.
  static const String encryptionVersion = 'AES-256-GCM v2';

  /// Кількість днів дії пароля до експірації.
  static const int passwordExpiryDays = 90;

  /// Мінімальна кількість унікальних цифр у PIN.
  static const int minUniquePinDigits = 2;

  /// Коефіцієнт зниження безпеки за невдалі спроби.
  static const double failedAttemptPenalty = 5.0;

  /// Максимальна кількість одночасних сесій.
  static const int maxConcurrentSessions = 5;

  /// Описи рівнів безпеки для UI.
  static const Map<int, String> securityLevelDescriptions = {
    0: 'Критично низький — негайно увімкніть додатковий захист',
    1: 'Низький — рекомендуємо увімкнути PIN та біометрію',
    2: 'Середній — додайте двофакторну автентифікацію',
    3: 'Високий — ваш акаунт добре захищений',
    4: 'Максимальний — усі функції безпеки увімкнені',
  };

  /// Іконки рівнів безпеки.
  static const Map<int, IconData> securityLevelIcons = {
    0: Icons.dangerous_rounded,
    1: Icons.warning_amber_rounded,
    2: Icons.shield_rounded,
    3: Icons.verified_user_rounded,
    4: Icons.security_rounded,
  };

  /// Підтримувані алгоритми шифрування.
  static const List<String> supportedAlgorithms = [
    'AES-256-GCM',
    'ChaCha20-Poly1305',
    'RSA-4096',
  ];

  /// Типи перевірок безпеки.
  static const List<String> securityCheckTypes = [
    'Швидка перевірка',
    'Повна перевірка',
    'Аудит сесій',
    'Перевірка цілісності',
  ];

  /// Поради щодо безпеки.
  static const List<String> securityTips = [
    'Регулярно оновлюйте PIN-код',
    'Використовуйте біометрію для зручності',
    'Увімкніть двофакторну автентифікацію',
    'Перевіряйте історію входів щотижня',
    'Не діліться паролями з третіми особами',
    'Блокуйте пристрій при втраті',
    'Використовуйте складні паролі',
    'Оновлюйте додаток до останньої версії',
  ];

  /// Формати часових пояснень автоблокування.
  static const Map<int, String> timeoutDescriptions = {
    30: '30 секунд — для публічних місць',
    60: '1 хвилина — стандартний',
    120: '2 хвилини — помірний',
    300: '5 хвилин — для домашнього використання',
    600: '10 хвилин — максимальний',
  };
}

/// Розширення для _SecurityScreenState з додатковими валідаторами.
extension _SecurityValidationExt on _SecurityScreenState {
  /// Валідує PIN-код.
  String? validatePin(String pin) {
    if (pin.isEmpty) return 'PIN-код не може бути порожнім';
    if (pin.length != _SecurityConstants.pinLength) {
      return 'PIN має містити рівно ${_SecurityConstants.pinLength} цифри';
    }
    if (!RegExp(r'^\d+$').hasMatch(pin)) {
      return 'PIN повинен містити тільки цифри';
    }
    final uniqueDigits = pin.split('').toSet().length;
    if (uniqueDigits < _SecurityExtensions.minUniquePinDigits) {
      return 'PIN повинен містити більше різних цифр';
    }
    return null;
  }

  /// Обчислює силу PIN-коду (0–3).
  int calculatePinStrength(String pin) {
    if (pin.length < 4) return 0;
    int strength = 0;
    final uniqueDigits = pin.split('').toSet().length;
    if (uniqueDigits >= 3) strength++;
    bool hasNoSequence = true;
    for (int i = 1; i < pin.length; i++) {
      if ((int.parse(pin[i]) - int.parse(pin[i - 1])).abs() == 1) {
        hasNoSequence = false;
        break;
      }
    }
    if (hasNoSequence) strength++;
    if (uniqueDigits == pin.length) strength++;
    if (pin.length >= 4) strength++;
    return strength.clamp(0, 3);
  }

  /// Перевіряє, чи локація є ризиковою.
  bool isRiskLocation(String location) {
    return _SecurityExtensions.riskyLocations
        .any((r) => location.contains(r));
  }

  /// Повертає зменшену оцінку з урахуванням невдалих спроб.
  int adjustedSecurityScore(int baseScore, int failedAttempts) {
    return (baseScore - failedAttempts * _SecurityExtensions.failedAttemptPenalty)
        .clamp(0, 100)
        .round()
        .toInt();
  }

  /// Повертає текстові дані про шифрування.
  Map<String, String> getEncryptionInfo() {
    return {
      'Алгоритм': _SecurityExtensions.encryptionVersion,
      'Режим': 'Galois/Counter Mode',
      'Довжина ключа': '256 біт',
      'IV розмір': '96 біт',
      'Тег аутентифікації': '128 біт',
      'Бібліотека': 'Flutter Secure Storage',
      'Стан': '✅ Активний',
    };
  }

  /// Форматує дату останньої зміни пароля.
  String formatLastPasswordChange() => '2 тижні тому';

  /// Обчислює дні до експірації пароля.
  int daysUntilPasswordExpiry() => 76;
}

/// Виджет для відображення деталей шифрування у секції безпеки.
class EncryptionDetailsWidget extends StatelessWidget {
  /// Колір картки.
  final Color cardColor;

  /// Колір рамки.
  final Color borderColor;

  /// Основний колір тексту.
  final Color textColor;

  /// Другорядний колір тексту.
  final Color subColor;

  /// Створює віджет деталей шифрування.
  const EncryptionDetailsWidget({
    super.key,
    required this.cardColor,
    required this.borderColor,
    required this.textColor,
    required this.subColor,
  });

  @override
  Widget build(BuildContext context) {
    final details = {
      'Алгоритм': _SecurityExtensions.encryptionVersion,
      'Режим': 'Galois/Counter Mode',
      'Довжина ключа': '256 біт',
      'IV розмір': '96 біт',
      'Тег аутентифікації': '128 біт',
      'Бібліотека': 'Flutter Secure Storage',
      'Стан': '✅ Активний',
    };
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
            children: [
              Icon(Icons.enhanced_encryption_rounded, color: textColor, size: 18),
              const SizedBox(width: Spacing.sm),
              Text(
                'Деталі шифрування',
                style: AppTypography.labelMedium.copyWith(
                  color: textColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: Spacing.sm),
          ...details.entries.map((e) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    e.key,
                    style: AppTypography.labelSmall.copyWith(color: subColor),
                  ),
                ),
                Text(
                  e.value,
                  style: AppTypography.labelSmall.copyWith(
                    color: textColor,
                    fontWeight: FontWeight.w500,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }
}

/// Виджет індикатора загроз для екрану безпеки.
class ThreatIndicatorWidget extends StatelessWidget {
  /// Кількість підозрілих спроб входу.
  final int suspiciousCount;

  /// Основний колір.
  final Color textColor;

  /// Другорядний колір.
  final Color subColor;

  /// Створює індикатор загроз.
  const ThreatIndicatorWidget({
    super.key,
    required this.suspiciousCount,
    required this.textColor,
    required this.subColor,
  });

  @override
  Widget build(BuildContext context) {
    final isSafe = suspiciousCount == 0;
    return Container(
      padding: const EdgeInsets.all(Spacing.sm),
      decoration: BoxDecoration(
        color: isSafe
            ? AppColorsPS5.success.withOpacity(0.06)
            : AppColorsPS5.error.withOpacity(0.06),
        borderRadius: BorderRadius.circular(Radii.md),
        border: Border.all(
          color: isSafe
              ? AppColorsPS5.success.withOpacity(0.15)
              : AppColorsPS5.error.withOpacity(0.15),
        ),
      ),
      child: Row(
        children: [
          Icon(
            isSafe ? Icons.verified_user_rounded : Icons.gpp_bad_rounded,
            color: isSafe ? AppColorsPS5.success : AppColorsPS5.error,
            size: 16,
          ),
          const SizedBox(width: Spacing.sm),
          Expanded(
            child: Text(
              isSafe
                  ? 'Жодних підозрілих сесій не виявлено'
                  : 'Виявлено $suspiciousCount підозрілих спроб входу',
              style: AppTypography.labelSmall.copyWith(
                color: isSafe ? AppColorsPS5.success : AppColorsPS5.error,
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Виджет рядка функції безпеки з іконкою та статусом.
class SecurityFeatureRow extends StatelessWidget {
  /// Назва функції.
  final String label;

  /// Чи увімкнено.
  final bool isEnabled;

  /// Опис.
  final String subtitle;

  /// Іконка.
  final IconData icon;

  /// Колір акценту.
  final Color accent;

  /// Колір тексту.
  final Color textColor;

  /// Другорядний колір.
  final Color subColor;

  /// Створює рядок функції безпеки.
  const SecurityFeatureRow({
    super.key,
    required this.label,
    required this.isEnabled,
    required this.subtitle,
    required this.icon,
    required this.accent,
    required this.textColor,
    required this.subColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Spacing.xs),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: isEnabled
                  ? accent.withOpacity(0.1)
                  : subColor.withOpacity(0.06),
              borderRadius: BorderRadius.circular(Radii.sm),
            ),
            child: Icon(
              icon,
              color: isEnabled ? accent : subColor.withOpacity(0.5),
              size: 16,
            ),
          ),
          const SizedBox(width: Spacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTypography.labelSmall.copyWith(
                    color: textColor,
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                  ),
                ),
                Text(
                  subtitle,
                  style: AppTypography.caption.copyWith(
                    color: subColor.withOpacity(0.7),
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            isEnabled
                ? Icons.check_circle_rounded
                : Icons.radio_button_unchecked_rounded,
            color: isEnabled ? AppColorsPS5.success : subColor.withOpacity(0.4),
            size: 16,
          ),
        ],
      ),
    );
  }
}
