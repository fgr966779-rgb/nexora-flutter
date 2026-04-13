// ═══════════════════════════════════════════════════════════════════════════
// profile_screen.dart — User Profile Screen
// ═══════════════════════════════════════════════════════════════════════════
//
/// Екран профілю — аватар, статистика, розділи налаштувань.
///
/// Містить: аватар з рівневим бейджем, статистику користувача,
/// розділи загальних, безпекових, даних налаштувань, стан редагування
/// імені, діалог підтвердження виходу, анімації елементів,
/// тактильний зворотний зв'язок, повзунок XP, індикатор заповнення
/// профілю, секція QR-коду, секція рівня з прогрес-баром,
/// розширену статистику, управління акаунтом, теплову карту активності,
/// порівняння з іншими користувачами, секцію нагород та досягнень.
///
/// {@category Settings}
/// {@subcategory Profile}
library;

import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_radii.dart';
import '../../../../core/utils/haptic_service.dart';
import '../../../../core/extensions/build_context_ext.dart';

/// ─── Logging Tag ────────────────────────────────────────────────────────────

/// Тег для логування подій профілю.
const String _logTag = '👤 ProfileScreen';

/// ─── Profile Constants ────────────────────────────────────────────────────────

/// Клас констант для параметрів профілю.
class _ProfileConstants {
  /// Мінімальна довжина імені користувача.
  static const int minNameLength = 2;

  /// Максимальна довжина імені користувача.
  static const int maxNameLength = 50;

  /// Кількість XP за рівень (базова).
  static const int xpPerLevel = 2000;

  /// Кількість доступних аватарів.
  static const int avatarCount = 16;

  /// Максимальна кількість помічних повідомлень.
  static const int maxTipCount = 5;

  /// Тривалість анімації аватара (мс).
  static const int avatarAnimationDuration = 3000;
}

/// ─── Main Screen Widget ────────────────────────────────────────────────────

/// Екран профілю користувача.
///
/// Відображає особисту інформацію, статистику досягнень
/// та надає доступ до налаштувань.
class ProfileScreen extends StatefulWidget {
  /// Створює екран профілю.
  ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

/// Стан екрану профілю.
class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  // ─── User Data ──────────────────────────────────────────────────────

  /// Ім'я користувача.
  final String _userName = 'Олександр';

  /// Електронна пошта користувача.
  final String _userEmail = 'alex@example.com';

  /// Дата приєднання.
  final String _joinDate = '1 січня 2025';

  /// Кількість завершених цілей.
  final int _goalsCompleted = 2;

  /// Поточний XP користувача.
  final int _userXp = 1450;

  /// XP до наступного рівня.
  final int _xpToNextLevel = 550;

  /// Поточний рівень користувача.
  final int _currentLevel = 4;

  /// Загальна кількість внесків.
  final int _totalDeposits = 47;

  /// Загальна сума заощаджень.
  final int _totalSaved = 15600;

  /// Поточна серія днів.
  final int _currentStreak = 5;

  /// Найкраща серія днів.
  final int _bestStreak = 12;

  /// Кількість отриманих бейджів.
  final int _badgesCount = 7;

  /// Кількість активних викликів.
  final int _challengesJoined = 3;

  // ─── UI State ─────────────────────────────────────────────────────────

  /// Чи зараз редагується ім'я.
  bool _isEditingName = false;

  /// Контролер для поля вводу імені.
  final _nameController = TextEditingController();

  /// Контролер анімації аватара.
  late AnimationController _avatarController;

  /// Чи показувати деталей рівня.
  bool _showLevelDetails = false;

  /// Обране аватар емодзі.
  String _selectedAvatar = '🎮';

  // ─── Tip System ──────────────────────────────────────────────────────

  /// Поточний індекс поради.
  int _currentTipIndex = 0;

  /// Поради для покращення профілю.
  static const _profileTips = [
    'Додайте фото профілю для покращення індикатора заповнення',
    'Увімкніть біометрію для додаткової безпеки',
    'Налаштуйте сповіщення, щоб не пропустити внески',
    'Створіть резервну копію для захисту даних',
    'Приєднуйтесь до виклику для додаткової мотивації',
  ];

  /// Доступні аватари для вибору.
  static const _avatarOptions = [
    '🎮', '🎯', '💎', '🚀', '⭐', '🔥', '🏆', '💰',
    '🦁', '🐱', '🦊', '🐺', '🌟', '🎪', '🎨', '⚡',
  ];

  // ─── Computed Properties ─────────────────────────────────────────────

  /// Відсоток заповнення профілю (0.0–1.0).
  double get _profileCompletion {
    try {
      int filled = 0;
      const total = 8;
      if (_userName.isNotEmpty) filled++;
      if (_userEmail.isNotEmpty) filled++;
      filled++; // аватар
      filled++; // приєднався
      filled++; // досягнення
      filled++; // пароль
      filled++; // біометрія
      filled++; // сповіщення
      return (filled / total).clamp(0.0, 1.0);
    } catch (e) {
      developer.log('Error calculating profile completion: $e', name: _logTag);
      return 0.0;
    }
  }

  /// Назва рівня залежно від номера.
  String get _levelName {
    if (_currentLevel >= 10) return 'Легенда';
    if (_currentLevel >= 7) return 'Майстер';
    if (_currentLevel >= 5) return 'Експерт';
    if (_currentLevel >= 3) return 'Відмінник';
    return 'Початківець';
  }

  /// Опис рівня.
  String get _levelDescription {
    switch (_levelName) {
      case 'Легенда': return 'Ти досяг вершини фінансової дисципліни!';
      case 'Майстер': return 'Ти на шляху до легендарного статусу!';
      case 'Експерт': return 'Твій досвід вражає інших!';
      case 'Відмінник': return 'Ти демонструєш стабільний прогрес!';
      default: return 'Кожен шлях починається з першого кроку!';
    }
  }

  /// XP прогрес (0.0–1.0).
  double get _xpProgress {
    try {
      return (_userXp / (_userXp + _xpToNextLevel)).clamp(0.0, 1.0);
    } catch (e) {
      return 0.0;
    }
  }

  /// Кількість XP до наступного рівня (загальна).
  int get _totalXpForNextLevel => _userXp + _xpToNextLevel;

  /// Дні з моменту установки.
  int get _daysSinceInstall {
    try {
      final installDate = DateTime(2025, 1, 1);
      return DateTime.now().difference(installDate).inDays;
    } catch (_) {
      return 0;
    }
  }

  /// Опис кількості днів з установки.
  String get _daysSinceInstallFormatted {
    final days = _daysSinceInstall;
    if (days < 1) return 'Сьогодні';
    if (days < 7) return '$days дн';
    if (days < 30) return '${(days / 7).floor()} тижн';
    if (days < 365) return '${(days / 30).floor()} міс';
    return '${(days / 365).floor()} р';
  }

  /// Кількість отриманих бейджів у відсотках.
  double get _badgesProgress {
    return (_badgesCount / 10).clamp(0.0, 1.0);
  }

  // ─── Lifecycle ────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    developer.log('Profile screen initialized for user: $_userName', name: _logTag);
    _nameController.text = _userName;
    _avatarController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: _ProfileConstants.avatarAnimationDuration),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _avatarController.dispose();
    developer.log('Profile screen disposed', name: _logTag);
    super.dispose();
  }

  // ─── Actions ─────────────────────────────────────────────────────────

  /// Починає редагування імені.
  void _startEditName() {
    try {
      HapticService.selection();
      setState(() {
        _isEditingName = true;
        _nameController.text = _userName;
      });
      developer.log('Started editing name', name: _logTag);
    } catch (e) {
      developer.log('Error starting name edit: $e', name: _logTag);
    }
  }

  /// Зберігає нове ім'я.
  void _saveName() {
    try {
      final newName = _nameController.text.trim();
      if (newName.length < _ProfileConstants.minNameLength) {
        context.showAppToast(
          'Мінімальна довжина — ${_ProfileConstants.minNameLength} символи',
          type: AppToastType.warning,
        );
        return;
      }
      if (newName.length > _ProfileConstants.maxNameLength) {
        context.showAppToast(
          'Максимальна довжина — ${_ProfileConstants.maxNameLength} символів',
          type: AppToastType.warning,
        );
        return;
      }
      HapticService.success();
      setState(() => _isEditingName = false);
      context.showToast('Ім\'я збережено!', icon: Icons.check_circle_rounded);
      developer.log('Name saved: $newName', name: _logTag);
    } catch (e) {
      developer.log('Error saving name: $e', name: _logTag);
    }
  }

  /// Показує вибір аватара.
  void _showAvatarPicker() {
    try {
      HapticService.selection();
      developer.log('Opening avatar picker', name: _logTag);
      showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (_) => Container(
          padding: const EdgeInsets.all(Spacing.xl),
          decoration: BoxDecoration(
            color: context.isDark ? AppColorsPS5.card : AppColorsMonitor.card,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(Radii.xl)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColorsPS5.textHint.withOpacity(0.3), borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: Spacing.lg),
              Text('Обери аватар', style: AppTypography.heading3.copyWith(color: AppColorsPS5.textPrimary)),
              const SizedBox(height: Spacing.md),
              Wrap(
                spacing: Spacing.md,
                runSpacing: Spacing.md,
                children: _avatarOptions.map((emoji) {
                  final isSelected = emoji == _selectedAvatar;
                  return GestureDetector(
                    onTap: () {
                      HapticService.selection();
                      setState(() => _selectedAvatar = emoji);
                      Navigator.pop(context);
                      context.showToast('Аватар оновлено!', icon: Icons.check_circle_rounded);
                      developer.log('Avatar changed to: $emoji', name: _logTag);
                    },
                    child: Container(
                      width: 64, height: 64,
                      decoration: BoxDecoration(
                        color: isSelected ? AppColorsPS5.accent.withOpacity(0.15) : (context.isDark ? AppColorsPS5.card : AppColorsMonitor.card),
                        borderRadius: BorderRadius.circular(Radii.lg),
                        border: Border.all(color: isSelected ? AppColorsPS5.accent : AppColorsPS5.border, width: isSelected ? 2 : 1),
                      ),
                      child: Center(child: Text(emoji, style: const TextStyle(fontSize: 28))),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: Spacing.xxl),
            ],
          ),
        ),
      );
    } catch (e) {
      developer.log('Error showing avatar picker: $e', name: _logTag);
    }
  }

  /// Показує діалог виходу.
  void _showLogoutDialog() {
    HapticService.mediumTap();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: context.isDark ? AppColorsPS5.card : AppColorsMonitor.card,
        title: Text('Вийти?', style: AppTypography.heading3.copyWith(color: context.isDark ? AppColorsPS5.textPrimary : AppColorsMonitor.textPrimary)),
        content: Text('Ви впевнені, що хочете вийти з акаунта?\nВсі дані залишаться на пристрої.', style: AppTypography.bodyMedium.copyWith(color: context.isDark ? AppColorsPS5.textSecondary : AppColorsMonitor.textSecondary)),
        actions: [
          TextButton(onPressed: () { HapticService.lightTap(); Navigator.pop(ctx); }, child: Text('Скасувати', style: AppTypography.labelLarge.copyWith(color: context.isDark ? AppColorsPS5.textSecondary : AppColorsMonitor.textSecondary))),
          TextButton(onPressed: () { HapticService.lightTap(); Navigator.pop(ctx); context.showToast('Вихід виконано', icon: Icons.logout_rounded); }, child: Text('Вийти', style: AppTypography.labelLarge.copyWith(color: AppColorsPS5.error))),
        ],
      ),
    );
  }

  /// Показує діалог видалення акаунта.
  void _showDeleteAccountDialog() {
    HapticService.error();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: context.isDark ? AppColorsPS5.card : AppColorsMonitor.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Radii.lg), side: BorderSide(color: AppColorsPS5.error.withOpacity(0.3))),
        title: Text('Видалити акаунт?', style: AppTypography.heading3.copyWith(color: AppColorsPS5.error)),
        content: Text('Ця дія незворотна. Всі ваші дані, цілі та досягнення буде видалено назавжди.', style: AppTypography.bodyMedium.copyWith(color: context.isDark ? AppColorsPS5.textSecondary : AppColorsMonitor.textSecondary)),
        actions: [
          TextButton(onPressed: () { HapticService.lightTap(); Navigator.pop(ctx); }, child: Text('Скасувати', style: AppTypography.labelLarge.copyWith(color: context.isDark ? AppColorsPS5.textSecondary : AppColorsMonitor.textSecondary))),
          TextButton(onPressed: () { HapticService.lightTap(); Navigator.pop(ctx); context.showToast('Видалення скасовано', icon: Icons.info_rounded); }, child: Text('Видалити', style: AppTypography.labelLarge.copyWith(color: AppColorsPS5.error))),
        ],
      ),
    );
  }

  /// Показує QR-код.
  void _showQRCode() {
    HapticService.lightTap();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: const EdgeInsets.all(Spacing.xxl),
        decoration: BoxDecoration(
          color: context.isDark ? AppColorsPS5.card : AppColorsMonitor.card,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(Radii.xl)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColorsPS5.textHint.withOpacity(0.3), borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: Spacing.lg),
            Text('Мій QR-код', style: AppTypography.heading3.copyWith(color: AppColorsPS5.textPrimary)),
            const SizedBox(height: Spacing.md),
            Container(
              width: 180, height: 180,
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(Radii.lg)),
              child: Center(
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.qr_code_rounded, size: 80, color: Colors.black87),
                  const SizedBox(height: Spacing.sm),
                  Text('@$_userName', style: AppTypography.labelMedium.copyWith(color: Colors.black87)),
                ]),
              ),
            ),
            const SizedBox(height: Spacing.md),
            Text('Покажи QR-код другу, щоб додати його', style: AppTypography.bodySmall.copyWith(color: AppColorsPS5.textSecondary), textAlign: TextAlign.center),
            const SizedBox(height: Spacing.xxl),
          ],
        ),
      ),
    );
  }

  /// Перемикає детальну інформацію про рівень.
  void _toggleLevelDetails() {
    HapticService.selection();
    setState(() => _showLevelDetails = !_showLevelDetails);
  }

  /// Показує наступну пораду.
  void _nextTip() {
    setState(() {
      _currentTipIndex = (_currentTipIndex + 1) % _ProfileConstants.maxTipCount;
    });
  }

  /// Валідує ім'я користувача.
  String? _validateName(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return 'Ім\'я не може бути порожнім';
    if (trimmed.length < _ProfileConstants.minNameLength) return 'Мінімальна довжина — ${_ProfileConstants.minNameLength} символи';
    if (trimmed.length > _ProfileConstants.maxNameLength) return 'Максимальна довжина — ${_ProfileConstants.maxNameLength} символів';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final textColor = isDark ? AppColorsPS5.textPrimary : AppColorsMonitor.textPrimary;
    final subColor = isDark ? AppColorsPS5.textSecondary : AppColorsMonitor.textSecondary;
    final cardColor = isDark ? AppColorsPS5.card : AppColorsMonitor.card;
    final borderColor = isDark ? AppColorsPS5.border : AppColorsMonitor.border;
    final accent = isDark ? AppColorsPS5.accent : AppColorsMonitor.accent;
    final hintColor = isDark ? AppColorsPS5.textHint : AppColorsMonitor.textHint;

    return Scaffold(
      backgroundColor: isDark ? AppColorsPS5.background : AppColorsMonitor.background,
      appBar: AppBar(
        title: const Text('Профіль'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: textColor,
        actions: [
          IconButton(icon: Icon(Icons.qr_code_rounded, color: subColor), onPressed: _showQRCode, tooltip: 'Мій QR-код'),
          IconButton(icon: Icon(Icons.info_outline_rounded, color: subColor), onPressed: () { HapticService.lightTap(); context.showToast('Nexora v1.0.0 · Збережено локально', icon: Icons.info_rounded); }, tooltip: 'Про додаток'),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: Spacing.base),
        children: [
          const SizedBox(height: Spacing.lg),
          _buildProfileHeader(textColor, subColor, accent, hintColor),
          const SizedBox(height: Spacing.xl),
          _buildProfileCompletion(isDark),
          const SizedBox(height: Spacing.sm),
          _buildProfileTip(subColor, accent),
          const SizedBox(height: Spacing.xl),
          _buildStatsGrid(isDark, textColor, subColor, cardColor, borderColor, accent),
          const SizedBox(height: Spacing.xl),
          _sectionTitle('Рівень та досягнення', textColor),
          const SizedBox(height: Spacing.sm),
          _buildLevelSection(cardColor, borderColor, textColor, subColor, accent, hintColor),
          const SizedBox(height: Spacing.xl),
          _sectionTitle('Загальне', textColor),
          const SizedBox(height: Spacing.sm),
          if (_isEditingName)
            _buildNameEditor(textColor, subColor, cardColor, accent),
          _settingsTile(icon: Icons.palette_rounded, title: 'Змінити тему', subtitle: 'Темна (PS5)', trailing: Icon(Icons.chevron_right_rounded, color: hintColor, size: 20), onTap: () { HapticService.selection(); Navigator.of(context).pushNamed('/change-theme'); }, cardColor: cardColor, borderColor: borderColor, textColor: textColor, subColor: subColor, hintColor: hintColor),
          _settingsTile(icon: Icons.language_rounded, title: 'Мова', subtitle: '🇺🇦 Українська', trailing: Icon(Icons.chevron_right_rounded, color: hintColor, size: 20), onTap: () { HapticService.selection(); context.showToast('Мова: Українська', icon: Icons.language_rounded); }, cardColor: cardColor, borderColor: borderColor, textColor: textColor, subColor: subColor, hintColor: hintColor),
          _settingsTile(icon: Icons.accessibility_rounded, title: 'Доступність', subtitle: 'Розмір шрифту, контраст', trailing: Icon(Icons.chevron_right_rounded, color: hintColor, size: 20), onTap: () { HapticService.selection(); context.showToast('Налаштування доступності', icon: Icons.accessibility_rounded); }, cardColor: cardColor, borderColor: borderColor, textColor: textColor, subColor: subColor, hintColor: hintColor),
          const SizedBox(height: Spacing.xl),
          _sectionTitle('Безпека', textColor),
          const SizedBox(height: Spacing.sm),
          _buildSecuritySection(cardColor, borderColor, textColor, subColor, hintColor),
          const SizedBox(height: Spacing.xl),
          _sectionTitle('Дані', textColor),
          const SizedBox(height: Spacing.sm),
          _buildDataSection(cardColor, borderColor, textColor, subColor, hintColor),
          const SizedBox(height: Spacing.xxl),
          _sectionTitle('Небезпечна зона', AppColorsPS5.error),
          const SizedBox(height: Spacing.sm),
          _settingsTile(icon: Icons.delete_forever_rounded, title: 'Видалити акаунт', subtitle: 'Ця дія незворотна', titleColor: AppColorsPS5.error, iconColor: AppColorsPS5.error, onTap: _showDeleteAccountDialog, cardColor: AppColorsPS5.error.withOpacity(0.04), borderColor: AppColorsPS5.error.withOpacity(0.15), textColor: AppColorsPS5.error, subColor: subColor, hintColor: hintColor),
          const SizedBox(height: Spacing.xxl),
          Center(child: TextButton(onPressed: _showLogoutDialog, child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.logout_rounded, color: AppColorsPS5.error, size: 18), const SizedBox(width: Spacing.sm), Text('Вийти з акаунта', style: AppTypography.buttonMedium.copyWith(color: AppColorsPS5.error))])))).animate().fade(delay: 400.ms, duration: 400.ms),
          const SizedBox(height: Spacing.lg),
          Center(child: Text('Nexora v1.0.0 · Збережено локально на пристрої\nДнів у додатку: $_daysSinceInstallFormatted', style: AppTypography.caption.copyWith(color: hintColor), textAlign: TextAlign.center)),
          const SizedBox(height: Spacing.xxxl),
        ],
      ),
    );
  }

  /// Будує заголовок профілю з аватаром.
  Widget _buildProfileHeader(Color textColor, Color subColor, Color accent, Color hintColor) {
    return Center(
      child: Column(
        children: [
          // Avatar with level badge
          GestureDetector(
            onTap: _showAvatarPicker,
            child: AnimatedBuilder(
              animation: _avatarController,
              builder: (context, child) {
                final glow = 0.3 + 0.2 * _avatarController.value;
                return Container(
                  width: 96, height: 96,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(colors: [accent.withOpacity(glow), accent.withOpacity(glow * 0.3)]),
                    border: Border.all(color: accent, width: 2),
                    boxShadow: [BoxShadow(color: accent.withOpacity(glow * 0.5), blurRadius: 20)],
                  ),
                  child: Center(child: Text(_selectedAvatar, style: const TextStyle(fontSize: 40))),
                );
              },
            ),
          ),
          const SizedBox(height: Spacing.md),
          // Name with edit button
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Text(_userName, style: AppTypography.heading2.copyWith(color: textColor)),
            const SizedBox(width: Spacing.xs),
            GestureDetector(onTap: _startEditName, child: Icon(Icons.edit_rounded, color: hintColor, size: 16)),
          ]),
          const SizedBox(height: Spacing.xs),
          Text(_userEmail, style: AppTypography.bodyMedium.copyWith(color: subColor)),
          const SizedBox(height: Spacing.xs),
          Text('$_levelName · $_currentLevel рівень', style: AppTypography.labelSmall.copyWith(color: accent)),
          const SizedBox(height: Spacing.sm),
          // XP progress bar
          SizedBox(
            width: 160,
            child: Column(children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: _xpProgress,
                  minHeight: 6,
                  backgroundColor: borderColor.withOpacity(0.3),
                  valueColor: AlwaysStoppedAnimation(AppColorsPS5.xp),
                ),
              ),
              const SizedBox(height: Spacing.xs),
              Text('$_userXp / $_totalXpForNextLevel XP до наступного рівня', style: AppTypography.caption.copyWith(color: AppColorsPS5.xp, fontWeight: FontWeight.w600), textAlign: TextAlign.center),
            ]),
          ),
        ],
      ),
    ).animate().fade(duration: 400.ms);
  }

  /// Будує пораду покращення профілю.
  Widget _buildProfileTip(Color subColor, Color accent) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: Spacing.base),
      padding: const EdgeInsets.all(Spacing.sm),
      decoration: BoxDecoration(color: accent.withOpacity(0.04), borderRadius: BorderRadius.circular(Radii.sm), border: Border.all(color: accent.withOpacity(0.08))),
      child: Row(
        children: [
          Expanded(child: Text('💡 ${_profileTips[_currentTipIndex]}', style: AppTypography.labelSmall.copyWith(color: subColor, fontSize: 10))),
          GestureDetector(onTap: _nextTip, child: Icon(Icons.refresh_rounded, color: accent, size: 14)),
        ],
      ),
    );
  }

  /// Будує секцію безпеки.
  Widget _buildSecuritySection(Color cardColor, Color borderColor, Color textColor, Color subColor, Color hintColor) {
    return Column(children: [
      _settingsTile(icon: Icons.fingerprint_rounded, title: 'Face ID / Touch ID', subtitle: 'Увімкнено', trailing: Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3), decoration: BoxDecoration(color: AppColorsPS5.success.withOpacity(0.1), borderRadius: BorderRadius.circular(Radii.sm)), child: Text('Активно', style: AppTypography.labelSmall.copyWith(color: AppColorsPS5.success, fontWeight: FontWeight.w600))), onTap: () { HapticService.selection(); Navigator.of(context).pushNamed('/security'); }, cardColor: cardColor, borderColor: borderColor, textColor: textColor, subColor: subColor, hintColor: hintColor),
      _settingsTile(icon: Icons.pin_rounded, title: 'PIN-код', subtitle: 'Встановлено', trailing: Icon(Icons.chevron_right_rounded, color: hintColor, size: 20), onTap: () { HapticService.selection(); Navigator.of(context).pushNamed('/security'); }, cardColor: cardColor, borderColor: borderColor, textColor: textColor, subColor: subColor, hintColor: hintColor),
      _settingsTile(icon: Icons.shield_rounded, title: 'Рівень безпеки', subtitle: 'Високий (85%)', trailing: Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3), decoration: BoxDecoration(color: AppColorsPS5.success.withOpacity(0.1), borderRadius: BorderRadius.circular(Radii.sm)), child: Text('85%', style: AppTypography.labelSmall.copyWith(color: AppColorsPS5.success, fontWeight: FontWeight.w600))), onTap: () { HapticService.selection(); Navigator.of(context).pushNamed('/security'); }, cardColor: cardColor, borderColor: borderColor, textColor: textColor, subColor: subColor, hintColor: hintColor),
      _settingsTile(icon: Icons.lock_rounded, title: 'Змінити пароль', subtitle: 'Останнє: 2 тижні тому', trailing: Icon(Icons.chevron_right_rounded, color: hintColor, size: 20), onTap: () { HapticService.selection(); context.showToast('Функція зміни пароля', icon: Icons.lock_rounded); }, cardColor: cardColor, borderColor: borderColor, textColor: textColor, subColor: subColor, hintColor: hintColor),
    ]);
  }

  /// Будує секцію даних.
  Widget _buildDataSection(Color cardColor, Color borderColor, Color textColor, Color subColor, Color hintColor) {
    return Column(children: [
      _settingsTile(icon: Icons.cloud_upload_rounded, title: 'Резервне копіювання', subtitle: 'Останнє: сьогодні', trailing: Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3), decoration: BoxDecoration(color: AppColorsPS5.success.withOpacity(0.1), borderRadius: BorderRadius.circular(Radii.sm)), child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.cloud_done_rounded, color: AppColorsPS5.success, size: 12), const SizedBox(width: 4), Text('OK', style: AppTypography.labelSmall.copyWith(color: AppColorsPS5.success, fontWeight: FontWeight.w600))])), onTap: () { HapticService.selection(); Navigator.of(context).pushNamed('/backup'); }, cardColor: cardColor, borderColor: borderColor, textColor: textColor, subColor: subColor, hintColor: hintColor),
      _settingsTile(icon: Icons.notifications_rounded, title: 'Сповіщення', subtitle: 'Налаштовано', trailing: Icon(Icons.chevron_right_rounded, color: hintColor, size: 20), onTap: () { HapticService.selection(); Navigator.of(context).pushNamed('/notifications'); }, cardColor: cardColor, borderColor: borderColor, textColor: textColor, subColor: subColor, hintColor: hintColor),
      _settingsTile(icon: Icons.sms_rounded, title: 'Сканер підписок', subtitle: 'Пошук регулярних витрат у SMS', trailing: Icon(Icons.chevron_right_rounded, color: hintColor, size: 20), onTap: () { HapticService.selection(); Navigator.of(context).pushNamed('/subscription-scanner'); }, cardColor: cardColor, borderColor: borderColor, textColor: textColor, subColor: subColor, hintColor: hintColor),
      _settingsTile(icon: Icons.file_download_rounded, title: 'Експорт CSV', subtitle: 'Завантажити транзакції', onTap: () { HapticService.lightTap(); context.showToast('CSV експортовано!', icon: Icons.check_circle_rounded); }, cardColor: cardColor, borderColor: borderColor, textColor: textColor, subColor: subColor, hintColor: hintColor),
      _settingsTile(icon: Icons.file_upload_rounded, title: 'Імпорт даних', subtitle: 'Відновити з файлу', onTap: () { HapticService.lightTap(); context.showToast('Функція імпорту', icon: Icons.file_upload_rounded); }, cardColor: cardColor, borderColor: borderColor, textColor: textColor, subColor: subColor, hintColor: hintColor),
    ]);
  }

  /// Будує секцію рівня з прогресом.
  Widget _buildLevelSection(Color cardColor, Color borderColor, Color textColor, Color subColor, Color accent, Color hintColor) {
    return Column(children: [
      _settingsTile(icon: Icons.military_tech_rounded, title: 'Бейджі та досягнення', subtitle: '$_badgesCount отримано', trailing: Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3), decoration: BoxDecoration(color: AppColorsPS5.xp.withOpacity(0.1), borderRadius: BorderRadius.circular(Radii.sm)), child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.emoji_events_rounded, color: AppColorsPS5.xp, size: 12), const SizedBox(width: 4), Text('$_badgesCount', style: AppTypography.labelSmall.copyWith(color: AppColorsPS5.xp, fontWeight: FontWeight.w600))])), onTap: () { HapticService.selection(); context.showToast('$_badgesCount досягнень розблоковано!', icon: Icons.emoji_events_rounded); }, cardColor: cardColor, borderColor: borderColor, textColor: textColor, subColor: subColor, hintColor: hintColor),
      _settingsTile(icon: Icons.bolt_rounded, title: 'Виклики', subtitle: '$_challengesJoined активних', trailing: Icon(Icons.chevron_right_rounded, color: hintColor, size: 20), onTap: () { HapticService.selection(); context.showToast('$_challengesJoined викликів у процесі', icon: Icons.bolt_rounded); }, cardColor: cardColor, borderColor: borderColor, textColor: textColor, subColor: subColor, hintColor: hintColor),
      _settingsTile(icon: Icons.leaderboard_rounded, title: 'Рейтинг', subtitle: 'Топ-15% серед користувачів', trailing: Icon(Icons.chevron_right_rounded, color: hintColor, size: 20), onTap: () { HapticService.selection(); context.showToast('Лідерборд незабаром!', icon: Icons.leaderboard_rounded); }, cardColor: cardColor, borderColor: borderColor, textColor: textColor, subColor: subColor, hintColor: hintColor),
      // Level details toggle
      GestureDetector(
        onTap: _toggleLevelDetails,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.only(bottom: Spacing.sm),
          padding: const EdgeInsets.symmetric(horizontal: Spacing.base, vertical: Spacing.sm),
          decoration: BoxDecoration(color: accent.withOpacity(0.04), borderRadius: BorderRadius.circular(Radii.md), border: Border.all(color: accent.withOpacity(0.08))),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('$_levelName · $_currentLevel рівень', style: AppTypography.labelMedium.copyWith(color: accent, fontWeight: FontWeight.w600)),
            Icon(_showLevelDetails ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded, color: accent, size: 18),
          ]),
        ),
      ),
      if (_showLevelDetails)
        Container(
          margin: const EdgeInsets.only(bottom: Spacing.sm),
          padding: const EdgeInsets.all(Spacing.base),
          decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(Radii.lg), border: Border.all(color: borderColor)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('$_levelDescription', style: AppTypography.bodySmall.copyWith(color: subColor)),
            const SizedBox(height: Spacing.sm),
            _buildLevelStatRow('XP', '$_userXp / $_totalXpForNextLevel', AppColorsPS5.xp, subColor),
            _buildLevelStatRow('Бейджі', '$_badgesCount / 10', AppColorsPS5.coin, subColor),
            _buildLevelStatRow('Досягнуто цілей', '$_goalsCompleted', AppColorsPS5.success, subColor),
            _buildLevelStatRow('Стріка', '$_currentStreak дн (найкраща: $_bestStreak)', AppColorsPS5.error, subColor),
          ]),
        ).animate().fade(duration: 300.ms),
    ]);
  }

  /// Будує рядок статистики рівня.
  Widget _buildLevelStatRow(String label, String value, Color color, Color subColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Spacing.xs),
      child: Row(children: [
        Text(label, style: AppTypography.labelSmall.copyWith(color: subColor)),
        const Spacer(),
        Text(value, style: AppTypography.labelSmall.copyWith(color: color, fontWeight: FontWeight.w600)),
      ]),
    );
  }

  /// Будує редактор імені.
  Widget _buildNameEditor(Color textColor, Color subColor, Color cardColor, Color accent) {
    return Container(
      margin: const EdgeInsets.only(bottom: Spacing.sm),
      padding: const EdgeInsets.all(Spacing.base),
      decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(Radii.lg), border: Border.all(color: accent)),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _nameController,
              style: AppTypography.bodyMedium.copyWith(color: textColor),
              autofocus: true,
              maxLength: _ProfileConstants.maxNameLength,
              decoration: InputDecoration(
                hintText: 'Нове ім\'я',
                hintStyle: AppTypography.bodyMedium.copyWith(color: subColor.withOpacity(0.5)),
                border: InputBorder.none,
                counterText: '',
              ),
              onChanged: (v) {
                final error = _validateName(v);
                // Could show error state
              },
            ),
          ),
          const SizedBox(width: Spacing.sm),
          GestureDetector(
            onTap: _saveName,
            child: Container(
              padding: const EdgeInsets.all(Spacing.sm),
              decoration: BoxDecoration(color: accent, borderRadius: BorderRadius.circular(Radii.circular)),
              child: Icon(Icons.check_rounded, color: Colors.white, size: 20),
            ),
          ),
          const SizedBox(width: Spacing.xs),
          GestureDetector(
            onTap: () => setState(() => _isEditingName = false),
            child: Icon(Icons.close_rounded, color: subColor, size: 20),
          ),
        ],
      ),
    ).animate().fade(duration: 300.ms);
  }

  /// Будує індикатор заповнення профілю.
  Widget _buildProfileCompletion(bool isDark) {
    final percent = (_profileCompletion * 100).toInt();
    final color = isDark ? AppColorsMonitor.accent : AppColorsPS5.accent;
    final subColor = isDark ? AppColorsPS5.textSecondary : AppColorsMonitor.textSecondary;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: Spacing.base),
      padding: const EdgeInsets.all(Spacing.base),
      decoration: BoxDecoration(color: color.withOpacity(0.06), borderRadius: BorderRadius.circular(Radii.md), border: Border.all(color: color.withOpacity(0.12))),
      child: Column(
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('Заповнення профілю', style: AppTypography.labelMedium.copyWith(color: isDark ? AppColorsPS5.textPrimary : AppColorsMonitor.textPrimary, fontWeight: FontWeight.w600)),
            Text('$percent%', style: AppTypography.labelMedium.copyWith(color: color, fontWeight: FontWeight.w700)),
          ]),
          const SizedBox(height: Spacing.sm),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(value: _profileCompletion, minHeight: 6, backgroundColor: (isDark ? AppColorsPS5.border : AppColorsMonitor.border).withOpacity(0.3), valueColor: AlwaysStoppedAnimation(color)),
          ),
          const SizedBox(height: Spacing.xs),
          Text(percent >= 100 ? 'Профіль повністю заповнений! 🎉' : 'Додайте фото, щоб покращити профіль', style: AppTypography.caption.copyWith(color: subColor)),
        ],
      ),
    ).animate().fade(delay: 150.ms, duration: 400.ms);
  }

  /// Будує сітку статистики.
  Widget _buildStatsGrid(bool isDark, Color textColor, Color subColor, Color cardColor, Color borderColor, Color accent) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _statCard('З нами з', _joinDate, isDark, Icons.calendar_today_rounded)),
            const SizedBox(width: Spacing.sm),
            Expanded(child: _statCard('Досягнуто', '$_goalsCompleted', isDark, Icons.flag_rounded)),
          ],
        ).animate().fade(delay: 200.ms, duration: 400.ms),
        const SizedBox(height: Spacing.sm),
        Row(
          children: [
            Expanded(child: _statCard('Внесків', '$_totalDeposits', isDark, Icons.payments_rounded)),
            const SizedBox(width: Spacing.sm),
            Expanded(child: _statCard('Серія', '$_currentStreak дн.', isDark, Icons.local_fire_department_rounded)),
          ],
        ).animate().fade(delay: 250.ms, duration: 400.ms),
        const SizedBox(height: Spacing.sm),
        Row(
          children: [
            Expanded(child: _statCard('Найкраща серія', '$_bestStreak дн.', isDark, Icons.emoji_events_rounded)),
            const SizedBox(width: Spacing.sm),
            Expanded(child: _statCard('Всього збережено', '$_totalSaved ₴', isDark, Icons.savings_rounded)),
          ],
        ).animate().fade(delay: 300.ms, duration: 400.ms),
        const SizedBox(height: Spacing.sm),
        Row(
          children: [
            Expanded(child: _statCard('XP', '$_userXp', isDark, Icons.bolt_rounded)),
            const SizedBox(width: Spacing.sm),
            Expanded(child: _statCard('Виклики', '$_challengesJoined', isDark, Icons.emoji_events_rounded)),
          ],
        ).animate().fade(delay: 350.ms, duration: 400.ms),
      ],
    );
  }

  Widget _sectionTitle(String title, Color color) {
    return Padding(
      padding: const EdgeInsets.only(left: Spacing.xs),
      child: Text(title, style: AppTypography.labelMedium.copyWith(color: color, letterSpacing: 0.5)),
    );
  }

  Widget _statCard(String label, String value, bool isDark, [IconData? icon]) {
    final cardColor = isDark ? AppColorsPS5.card : AppColorsMonitor.card;
    final textColor = isDark ? AppColorsPS5.textPrimary : AppColorsMonitor.textPrimary;
    final subColor = isDark ? AppColorsPS5.textSecondary : AppColorsMonitor.textSecondary;
    final accent = isDark ? AppColorsPS5.accent : AppColorsMonitor.accent;

    return Container(
      padding: const EdgeInsets.all(Spacing.sm),
      decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(Radii.md), border: Border.all(color: isDark ? AppColorsPS5.border : AppColorsMonitor.border)),
      child: Column(
        children: [
          if (icon != null) Icon(icon, color: accent, size: 18),
          const SizedBox(height: Spacing.xs),
          Text(value, style: AppTypography.labelSmall.copyWith(color: textColor, fontWeight: FontWeight.w600), textAlign: TextAlign.center),
          const SizedBox(height: 2),
          Text(label, style: AppTypography.caption.copyWith(color: subColor), textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _settingsTile({
    required IconData icon, required String title, required String subtitle, Widget? trailing,
    Color? titleColor, Color? iconColor,
    required VoidCallback? onTap,
    required Color cardColor, required Color borderColor, required Color textColor, required Color subColor, required Color hintColor,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: Spacing.sm),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(Spacing.base),
          decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(Radii.lg), border: Border.all(color: borderColor)),
          child: Row(
            children: [
              Icon(icon, color: iconColor ?? textColor, size: 22),
              const SizedBox(width: Spacing.md),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(title, style: AppTypography.bodyMedium.copyWith(color: titleColor ?? textColor)),
                  if (subtitle.isNotEmpty) Text(subtitle, style: AppTypography.bodySmall.copyWith(color: subColor)),
                ]),
              ),
              if (trailing != null) trailing,
            ],
          ),
        ),
      ),
    );
  }

  // ─── Additional Profile Constants ────────────────────────────────────

  /// Максимальна кількість символів для email.
  static const int maxEmailLength = 100;

  /// Кількість XP за щоденний вхід.
  static const int dailyLoginXp = 10;

  /// Кількість XP за внесок.
  static const int depositXp = 25;

  /// Кількість XP за завершену ціль.
  static const int goalCompletedXp = 200;

  /// Кількість XP за досягнення.
  static const int achievementXp = 50;

  /// Мінімальний розмір фото профілю (КБ).
  static const int minProfilePhotoSizeKB = 10;

  /// Максимальний розмір фото профілю (КБ).
  static const int maxProfilePhotoSizeKB = 5120;

  /// Рівні користувача з описами.
  static const Map<int, String> levelDescriptions = {
    1: 'Початківець',
    2: 'Новачок',
    3: 'Відмінник',
    4: 'Хорошист',
    5: 'Експерт',
    6: 'Віртуоз',
    7: 'Майстер',
    8: 'Елітний майстер',
    9: 'Гранд-майстер',
    10: 'Легенда',
  };

  /// Іконки для рівнів.
  static const Map<int, IconData> levelIcons = {
    1: Icons.star_outline_rounded,
    2: Icons.star_half_rounded,
    3: Icons.star_rounded,
    5: Icons.emoji_events_rounded,
    7: Icons.military_tech_rounded,
    10: Icons.workspace_premium_rounded,
  };

  /// Дни тижня для Heatmap.
  static const List<String> heatmapDays = ['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Нд'];

  /// Кількість тижнів для відображення heatmap.
  static const int heatmapWeeks = 8;

  /// Нагороди (mock дані).
  static const List<_Achievement> achievements = [
    _Achievement(name: 'Перший внесок', emoji: '🌱', xpReward: 10, unlocked: true),
    _Achievement(name: 'Тиждень поспіль', emoji: '🔥', xpReward: 50, unlocked: true),
    _Achievement(name: 'Перша ціль', emoji: '🎯', xpReward: 100, unlocked: true),
    _Achievement(name: 'Колекціонер', emoji: '🏆', xpReward: 200, unlocked: false),
    _Achievement(name: 'Мільйонер', emoji: '💰', xpReward: 500, unlocked: false),
    _Achievement(name: 'Легенда', emoji: '👑', xpReward: 1000, unlocked: false),
  ];

  // ─── Additional Computed Properties ─────────────────────────────────

  /// Середнє значення внеску.
  double get _averageDeposit {
    if (_totalDeposits == 0) return 0;
    return _totalSaved / _totalDeposits;
  }

  /// XP до наступного рівня (форматоване).
  String get _xpFormatted => '$_userXp XP';

  /// XP за останній тиждень (mock).
  int get _weeklyXp => _currentStreak * dailyLoginXp + 2 * depositXp;

  /// Загальна кількість розблокованих нагород.
  int get _unlockedAchievements =>
      achievements.where((a) => a.unlocked).length;

  /// Загальний XP від нагород.
  int get _totalAchievementXp =>
      achievements.where((a) => a.unlocked).fold<int>(0, (sum, a) => sum + a.xpReward);

  /// Відсоток прогресу до наступного рівня.
  double get _levelProgressPercent {
    return (_userXp / _totalXpForNextLevel * 100).clamp(0, 100);
  }

  /// Опис поточного рівня.
  String get _currentLevelDescription {
    return levelDescriptions[_currentLevel] ?? 'Невідомий рівень';
  }

  /// Іконка поточного рівня.
  IconData get _currentLevelIcon {
    // Find closest level icon
    int? closest;
    for (final level in levelIcons.keys) {
      if (level <= _currentLevel) closest = level;
    }
    return levelIcons[closest] ?? Icons.star_rounded;
  }

  /// Кількість нагород до розблокування.
  int get _lockedAchievements =>
      achievements.where((a) => !a.unlocked).length;

  /// Загальна XP з усіх джерел.
  int get _totalXpEarned => _userXp + _totalAchievementXp;

  /// Чи профіль повністю заповнений.
  bool get _isProfileComplete => _profileCompletion >= 1.0;

  /// Відсоток від найкращої серії.
  double get _streakPercent {
    if (_bestStreak == 0) return 0;
    return (_currentStreak / _bestStreak * 100).clamp(0, 100);
  }

  /// Форматована інформація про рівень для шеринга.
  String get _shareableLevelInfo {
    return '🎯 $_levelName · Рівень $_currentLevel · $_userXp XP #Nexora';
  }

  // ─── Additional Validation Methods ──────────────────────────────────

  /// Валідує email користувача.
  String? _validateEmail(String email) {
    final trimmed = email.trim();
    if (trimmed.isEmpty) return null; // Email optional
    if (trimmed.length > maxEmailLength) return 'Email занадто довгий';
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(trimmed)) return 'Некоректний формат email';
    return null;
  }

  /// Валідує розмір фото профілю.
  String? _validateProfilePhoto(int sizeKB) {
    if (sizeKB < minProfilePhotoSizeKB) {
      return 'Фото занадто мале (мінімум ${minProfilePhotoSizeKB} КБ)';
    }
    if (sizeKB > maxProfilePhotoSizeKB) {
      return 'Фото занадто велике (максимум ${maxProfilePhotoSizeKB} КБ)';
    }
    return null;
  }

  /// Валідує юзернейм.
  bool _isUsernameValid(String name) {
    return _validateName(name) == null;
  }

  /// Перевіряє, чи email доступний (mock).
  bool _isEmailAvailable(String email) {
    // In production: check with backend
    return email != 'admin@nexora.app';
  }

  /// Перевіряє, чи пароль достатньо складний.
  bool _isPasswordStrong(String password) {
    if (password.length < 8) return false;
    if (!RegExp(r'[A-Z]').hasMatch(password)) return false;
    if (!RegExp(r'[0-9]').hasMatch(password)) return false;
    if (!RegExp(r'[!@#\$%^&*]').hasMatch(password)) return false;
    return true;
  }

  // ─── Private Helper Methods ─────────────────────────────────────────

  /// Обчислює XP, необхідний для вказаного рівня.
  int _xpRequiredForLevel(int level) {
    return _ProfileConstants.xpPerLevel * level;
  }

  /// Обчислює кількість XP, що залишився до наступної нагороди.
  int _xpUntilNextAchievement() {
    final nextLocked = achievements.where((a) => !a.unlocked).firstOrNull;
    if (nextLocked == null) return 0;
    return nextLocked.xpReward - (_totalAchievementXp % nextLocked.xpReward);
  }

  /// Генерує heatmap даних активності (mock).
  List<int> _generateHeatmapData() {
    return List.generate(
      heatmapWeeks * heatmapDays.length,
      (index) => (index % 5 == 0) ? 0 : (index % 3 + 1),
    );
  }

  /// Повертає кольір для heatmap клітинки.
  Color _getHeatmapColor(int activity) {
    if (activity == 0) return Colors.grey.withOpacity(0.1);
    if (activity <= 2) return AppColorsPS5.success.withOpacity(0.3);
    if (activity <= 4) return AppColorsPS5.success.withOpacity(0.6);
    return AppColorsPS5.success.withOpacity(0.9);
  }

  /// Форматує суму для відображення.
  String _formatCurrency(int amount) {
    if (amount >= 1000000) return '${(amount / 1000000).toStringAsFixed(1)}М ₴';
    if (amount >= 1000) return '${(amount / 1000).toStringAsFixed(1)}К ₴';
    return '$amount ₴';
  }

  /// Форматує дату приєднання для експорту.
  String _formatJoinDateForExport() {
    return '$_joinDate (день $_daysSinceInstall)';
  }

  /// Генерує статистику профілю для експорту.
  Map<String, dynamic> _generateProfileExportData() {
    return {
      'userName': _userName,
      'userEmail': _userEmail,
      'joinDate': _joinDate,
      'level': _currentLevel,
      'levelName': _levelName,
      'xp': _userXp,
      'xpToNextLevel': _xpToNextLevel,
      'totalDeposits': _totalDeposits,
      'totalSaved': _totalSaved,
      'goalsCompleted': _goalsCompleted,
      'currentStreak': _currentStreak,
      'bestStreak': _bestStreak,
      'badgesCount': _badgesCount,
      'challengesJoined': _challengesJoined,
      'profileCompletion': (_profileCompletion * 100).toInt(),
      'selectedAvatar': _selectedAvatar,
      'achievements': achievements
          .map((a) => {'name': a.name, 'emoji': a.emoji, 'unlocked': a.unlocked})
          .toList(),
    };
  }

  /// Копіює дані профілю в буфер обміну.
  Future<void> _copyProfileShareLink() async {
    try {
      HapticService.lightTap();
      final data = _generateProfileExportData();
      final encoded = Uri.encodeComponent(jsonEncode(data));
      await Clipboard.setData(ClipboardData(text: 'nexora://profile?data=$encoded'));
      if (mounted) {
        context.showAppToast('Посилання скопійовано!', type: AppToastType.success);
      }
      developer.log('Profile share link copied', name: _logTag);
    } catch (e) {
      developer.log('Error copying profile link: $e', name: _logTag);
    }
  }

  /// Показує діалог експорту профілю.
  Future<void> _showExportProfileDialog() async {
    try {
      HapticService.selection();
      final data = _generateProfileExportData();
      final jsonString = jsonEncode(data);
      await Clipboard.setData(ClipboardData(text: jsonString));
      if (mounted) {
        context.showAppToast('Дані профілю скопійовано!', type: AppToastType.success);
      }
      developer.log('Profile data exported to clipboard', name: _logTag);
    } catch (e) {
      developer.log('Error exporting profile: $e', name: _logTag);
    }
  }

  /// Показує діалог зміни email.
  void _showChangeEmailDialog() {
    try {
      final controller = TextEditingController(text: _userEmail);
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: context.isDark ? AppColorsPS5.card : AppColorsMonitor.card,
          title: Text('Змінити email', style: AppTypography.heading3.copyWith(
            color: context.isDark ? AppColorsPS5.textPrimary : AppColorsMonitor.textPrimary,
          )),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.emailAddress,
            style: AppTypography.bodyMedium.copyWith(
              color: context.isDark ? AppColorsPS5.textPrimary : AppColorsMonitor.textPrimary,
            ),
            decoration: InputDecoration(
              hintText: 'email@example.com',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(Radii.md),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () { HapticService.lightTap(); Navigator.pop(ctx); },
              child: Text('Скасувати', style: AppTypography.labelLarge.copyWith(
                color: context.isDark ? AppColorsPS5.textSecondary : AppColorsMonitor.textSecondary,
              )),
            ),
            TextButton(
              onPressed: () {
                HapticService.success();
                Navigator.pop(ctx);
                context.showAppToast('Email оновлено!', type: AppToastType.success);
              },
              child: Text('Зберегти', style: AppTypography.labelLarge.copyWith(color: AppColorsPS5.accent)),
            ),
          ],
        ),
      );
    } catch (e) {
      developer.log('Error showing email dialog: $e', name: _logTag);
    }
  }

  // ─── Additional Widget Builders ────────────────────────────────────

  /// Будує секцію нагород та досягнень.
  Widget _buildAchievementsSection(
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
              Text('Нагороди', style: AppTypography.labelMedium.copyWith(color: textColor, fontWeight: FontWeight.w600)),
              Text('$_unlockedAchievements/${achievements.length}', style: AppTypography.labelSmall.copyWith(color: subColor)),
            ],
          ),
          const SizedBox(height: Spacing.sm),
          ...achievements.map((achievement) => Padding(
                padding: const EdgeInsets.only(bottom: Spacing.xs),
                child: Row(
                  children: [
                    Container(
                      width: 40, height: 40,
                      decoration: BoxDecoration(
                        color: achievement.unlocked
                            ? accent.withOpacity(0.15)
                            : subColor.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(Radii.sm),
                        border: Border.all(
                          color: achievement.unlocked ? accent.withOpacity(0.3) : borderColor,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          achievement.unlocked ? achievement.emoji : '🔒',
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                    ),
                    const SizedBox(width: Spacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                          achievement.name,
                          style: AppTypography.labelSmall.copyWith(
                            color: achievement.unlocked ? textColor : subColor,
                            fontWeight: achievement.unlocked ? FontWeight.w600 : FontWeight.w400,
                          ),
                        ),
                          Text(
                            '+${achievement.xpReward} XP · ${achievement.unlocked ? "Розблоковано" : "Заблоковано"}',
                            style: AppTypography.caption.copyWith(
                              color: achievement.unlocked
                                  ? AppColorsPS5.success
                                  : subColor.withOpacity(0.5),
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

  /// Будує секцію heatmap активності.
  Widget _buildActivityHeatmap(
    Color cardColor,
    Color borderColor,
    Color textColor,
    Color subColor,
  ) {
    final data = _generateHeatmapData();
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
          Text('Активність (останні 8 тижнів)', style: AppTypography.labelMedium.copyWith(color: textColor, fontWeight: FontWeight.w600)),
          const SizedBox(height: Spacing.sm),
          // Day headers
          Row(
            children: heatmapDays.map((day) => Expanded(
              child: Center(
                child: Text(day, style: AppTypography.caption.copyWith(color: subColor, fontSize: 9)),
              ),
            )).toList(),
          ),
          const SizedBox(height: Spacing.xs),
          // Heatmap grid
          ...List.generate(heatmapWeeks, (week) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 2),
              child: Row(
                children: List.generate(heatmapDays.length, (day) {
                  final index = week * heatmapDays.length + day;
                  final activity = data[index];
                  return Expanded(
                    child: Container(
                      height: 16,
                      margin: const EdgeInsets.symmetric(horizontal: 1),
                      decoration: BoxDecoration(
                        color: _getHeatmapColor(activity),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  );
                }),
              ),
            );
          }),
          const SizedBox(height: Spacing.xs),
          Text('Більше активності = яскравіший колір', style: AppTypography.caption.copyWith(color: subColor.withOpacity(0.5), fontSize: 9)),
        ],
      ),
    );
  }

  /// Будує рядок розширеної статистики.
  Widget _buildExtendedStatRow(String label, String value, Color valueColor, Color subColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Text(label, style: AppTypography.labelSmall.copyWith(color: subColor)),
          const Spacer(),
          Text(value, style: AppTypography.labelSmall.copyWith(color: valueColor, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

/// ─── Achievement Model ─────────────────────────────────────────────────

/// Модель нагороди/досягнення користувача.
///
/// Зберігає назву, емодзі-іконку, винагороду XP
/// та стан розблокування.
class _Achievement {
  /// Назва нагороди.
  final String name;

  /// Емодзі-іконка.
  final String emoji;

  /// XP винагорода.
  final int xpReward;

  /// Чи нагорода розблокована.
  final bool unlocked;

  /// Створює нагороду.
  const _Achievement({
    required this.name,
    required this.emoji,
    required this.xpReward,
    required this.unlocked,
  });
}

// ═══════════════════════════════════════════════════════════════════════════
// EXTENSION — Additional Constants, Validators, Widgets, Helpers
// ═══════════════════════════════════════════════════════════════════════════

/// Додаткові константи для профілю користувача.
class _ProfileExtensions {
  /// Мінімальна кількість символів для опису біо.
  static const int minBioLength = 10;

  /// Максимальна кількість символів для опису біо.
  static const int maxBioLength = 500;

  /// Мінімальна довжина імені.
  static const int minDisplayNameLength = 2;

  /// Максимальна довжина імені.
  static const int maxDisplayNameLength = 30;

  /// Кількість XP за щоденну активність.
  static const int dailyXpReward = 50;

  /// Кількість XP за досягнення цілі.
  static const int goalCompletionXp = 500;

  /// Кількість XP за серію днів.
  static const int streakXpPerDay = 25;

  /// Кількість XP за завантаження фото.
  static const int photoUploadXp = 100;

  /// Кількість XP за заповнення профілю на 100%.
  static const int fullProfileXp = 200;

  /// Кількість XP за приєднання до виклику.
  static const int challengeJoinXp = 150;

  /// Кількість XP за експорт даних.
  static const int dataExportXp = 50;

  /// Кількість XP за перше резервне копіювання.
  static const int firstBackupXp = 300;

  /// Кількість категорій нагород.
  static const int achievementCategories = 8;

  /// Кількість нагород на рівень.
  static const int achievementsPerLevel = 3;

  /// Максимальна довжина серії днів для відображення.
  static const int maxStreakDisplayDays = 365;

  /// Рівні користувачів.
  static const List<String> userLevels = [
    'Початківець',
    'Відмінник',
    'Експерт',
    'Майстер',
    'Легенда',
  ];

  /// Описи рівнів користувачів.
  static const Map<String, String> levelDescriptions = {
    'Початківець': 'Кожен шлях починається з першого кроку!',
    'Відмінник': 'Ти демонструєш стабільний прогрес!',
    'Експерт': 'Твій досвід вражає інших!',
    'Майстер': 'Ти на шляху до легендарного статусу!',
    'Легенда': 'Ти досяг вершини фінансової дисципліни!',
  };

  /// Іконки рівнів.
  static const Map<String, IconData> levelIcons = {
    'Початківець': Icons.star_border_rounded,
    'Відмінник': Icons.star_half_rounded,
    'Експерт': Icons.star_rounded,
    'Майстер': Icons.star_rounded,
    'Легенда': Icons.grade_rounded,
  };

  /// Колірні теми для рівнів.
  static const Map<String, Color> levelColors = {
    'Початківець': Color(0xFF9E9E9E),
    'Відмінник': Color(0xFF66BB6A),
    'Експерт': Color(0xFF42A5F5),
    'Майстер': Color(0xFFFFB300),
    'Легенда': Color(0xFFFFD700),
  };

  /// Нагороди за досягнення.
  static const List<Map<String, dynamic>> achievementDefinitions = [
    {'name': 'Перший внесок', 'emoji': '💰', 'xp': 100, 'unlocked': true},
    {'name': '7-денна серія', 'emoji': '🔥', 'xp': 200, 'unlocked': true},
    {'name': '10 цілей', 'emoji': '🎯', 'xp': 300, 'unlocked': true},
    {'name': 'Перша копія', 'emoji': '💾', 'xp': 300, 'unlocked': true},
    {'name': 'Перший виклик', 'emoji': '⚡', 'xp': 150, 'unlocked': true},
    {'name': 'Заповнений профіль', 'emoji': '👤', 'xp': 200, 'unlocked': true},
    {'name': '100% завершень', 'emoji': '✅', 'xp': 500, 'unlocked': true},
    {'name': 'Майстер', 'emoji': '🏆', 'xp': 1000, 'unlocked': false},
    {'name': 'Легенда', 'emoji': '👑', 'xp': 2000, 'unlocked': false},
  ];

  /// Типи фільтрів для активності.
  static const List<String> activityFilterTypes = [
    'Всі',
    'Внески',
    'Цілі',
    'Досягнення',
    'Виклики',
  ];

  /// Поради щодо покращення профілю.
  static const List<String> profileImprovementTips = [
    'Додайте фото для покращення індикатора заповнення',
    'Увімкніть біометрію для додаткової безпеки',
    'Налаштуйте сповіщення для нагадування про внески',
    'Створіть резервну копію для захисту даних',
    'Приєднуйся до виклику для додаткової мотивації',
    'Заповніть всі поля профілю для 100% заповнення',
    'Досягніть 10-денної серії для XP бонусу',
    'Завантажте аватар для персоналізації',
    'Поділіться на щоденні нагадування',
    'Експортуйте дані для безпечного зберігання',
    'Заповніть мета-дані для покращення досвіду',
    'Перевірте налаштування безпеки щотижня',
  ];

  /// Часові рамки для активності користувача.
  static const Map<String, int> activityTimeFrames = {
    'today': 1,
    'week': 7,
    'month': 30,
    'year': 365,
    'all': 1000,
  };
}

/// Розширення для обчислення статистики профілю.
extension _ProfileStatsExt on _ProfileScreenState {
  /// Обчислює середній щоденний XP.
  double get averageDailyXp {
    final days = _daysSinceInstall;
    if (days <= 0) return 0;
    return _userXp / days;
  }

  /// Обчислює кількість XP до наступного рівня.
  int get xpRemaining => _xpToNextLevel;

  /// Обчислює відсоток прогресу до рівня.
  double get levelProgressPercent {
    return _xpProgress * 100;
  }

  /// Обчислює кількість XP, необхідну для наступного рівня.
  int get xpRequired => _ProfileConstants.xpPerLevel;

  /// Обчислює кількість годин між внесками (mock).
  double get hoursBetweenDeposits {
    if (_totalDeposits < 2) return 0;
    return (_daysSinceInstall * 24.0) / _totalDeposits;
  }

  /// Обчислює суму заощаджень за день (mock).
  double get averageSavingsPerDay {
    final days = _daysSinceInstall;
    if (days <= 0) return 0;
    return _totalSaved / days;
  }

  /// Обчислює кількість XP, отриманих за наявки.
  int get appearanceXpEarned {
    return _ProfileExtensions.fullProfileXp; // Mock
  }

  /// Обчислює загальну кількість зароблених XP.
  int get totalXpEarned {
    return _userXp + _goalsCompleted * _ProfileExtensions.goalCompletionXp;
  }

  /// Обчислює кількість незаблокованих нагород.
  int get unlockedAchievements {
    return _ProfileExtensions.achievementDefinitions
        .where((a) => a['unlocked'] as bool)
        .length;
  }

  /// Обчислює загальну кількість XP для розблокування.
  int get totalXpForAllAchievements {
    return _ProfileExtensions.achievementDefinitions
        .fold<int>(0, (sum, a) => sum + (a['xp'] as int));
  }

  /// Обчислює прогрес unlocking нагород у відсотках.
  double get achievementUnlockProgress {
    final total = totalXpForAllAchievements;
    if (total <= 0) return 0;
    return (totalXpEarned / total).clamp(0.0, 1.0);
  }

  /// Перевіряє, чи досягнуто всіх нагород.
  bool get allAchievementsUnlocked => unlockedAchievements >=
      _ProfileExtensions.achievementDefinitions.length;

  /// Обчислює відсоток серії порівняно з найкращою.
  double get streakPercentOfBest {
    if (_bestStreak <= 0) return 0;
    return (_currentStreak / _bestStreak).clamp(0.0, 1.0);
  }

  /// Повертає опис поточного активного виклику.
  String get currentChallengeName => 'Збережи 500₴ за місяць';

  /// Повертає статус готовності до наступного рівня.
  String get nextLevelReadiness {
    final remaining = _xpToNextLevel;
    if (remaining <= 0) return 'Можнається підвищення!';
    return 'Ще $remaining XP';
  }

  /// Обчислює кількість днів до наступного рівня.
  int get estimatedDaysToNextLevel {
    final remaining = _xpToNextLevel;
    final dailyXp = _ProfileExtensions.dailyXpReward;
    if (dailyXp <= 0) return 0;
    return (remaining / dailyXp).ceil();
  }

  /// Форматує суму заощаджень з валютою.
  String formatSavings(int amount) {
    if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)}М';
    }
    if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(1)}К';
    }
    return '$amount';
  }

  /// Обчислює індекс заощадливості (заощадження / дні * 1000).
  double get savingsIndex {
    final days = _daysSinceInstall;
    if (days <= 0) return 0;
    return (_totalSaved / days).clamp(0, 999999);
  }

  /// Форматує час доби з моменту установки.
  String formatDaysSinceInstall() {
    final days = _daysSinceInstall;
    if (days < 1) return 'Сьогодні';
    if (days < 7) return '$days дн';
    if (days < 30) return '${(days / 7).floor()} тиж';
    if (days < 365) return '${(days / 30).floor()} міс';
    return '${(days / 365).floor()} р';
  }
}

/// Виджет-карка для відображення деталей рівня користувача.
class LevelDetailsCard extends StatelessWidget {
  /// Поточний рівень.
  final int currentLevel;

  /// XP поточного користувача.
  final int currentXp;

  /// XP до наступного рівня.
  final int xpToNextLevel;

  /// Кількість бейджів.
  final int badgesCount;

  /// Кількість завершених цілей.
  final int goalsCompleted;

  /// Поточна серія.
  final int currentStreak;

  /// Найкраща серія.
  final int bestStreak;

  /// Чи показувати деталі.
  final bool showDetails;

  /// Назва рівня.
  final String levelName;

  /// Опис рівня.
  final String levelDescription;

  /// Колір картки.
  final Color cardColor;

  /// Колір рамки.
  final Color borderColor;

  /// Основний колір тексту.
  final Color textColor;

  /// Другорядний колір.
  final Color subColor;

  /// Акцентний колір.
  final Color accent;

  /// Створює картку деталей рівня.
  const LevelDetailsCard({
    super.key,
    required this.currentLevel,
    required this.currentXp,
    required this.xpToNextLevel,
    required this.badgesCount,
    required this.goalsCompleted,
    required this.currentStreak,
    required this.bestStreak,
    required this.showDetails,
    required this.levelName,
    required this.levelDescription,
    required this.cardColor,
    required this.borderColor,
    required this.textColor,
    required this.subColor,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    final totalXp = currentXp + xpToNextLevel;
    return Container(
      margin: const EdgeInsets.only(bottom: Spacing.sm),
      padding: const EdgeInsets.all(Spacing.base),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(Radii.lg),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            levelDescription,
            style: AppTypography.bodySmall.copyWith(color: subColor),
          ),
          const SizedBox(height: Spacing.sm),
          _buildStatRow('XP', '$currentXp / $totalXp', AppColorsPS5.xp, subColor),
          _buildStatRow(
            'Бейджі', '$badgesCount / 10', AppColorsPS5.coin, subColor,
          ),
          _buildStatRow(
            'Досягнуто цілей', '$goalsCompleted', AppColorsPS5.success, subColor,
          ),
          _buildStatRow(
            'Стріка',
            '$currentStreak дн (найкраща: $bestStreak)',
            AppColorsPS5.error,
            subColor,
          ),
        ],
      ),
    );
  }

  /// Будує рядок статистики.
  Widget _buildStatRow(
    String label,
    String value,
    Color valueColor,
    Color labelColor,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Spacing.xs),
      child: Row(
        children: [
          Text(
            label,
            style: AppTypography.labelSmall.copyWith(color: labelColor),
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
}

/// Виджет порад щодо покращення профілю.
class ProfileTipCarousel extends StatelessWidget {
  /// Поточний індекс поради.
  final int currentIndex;

  /// Колір акценту.
  final Color accent;

  /// Другорядний колір.
  final Color subColor;

  /// Створює карусель порад.
  const ProfileTipCarousel({
    super.key,
    required this.currentIndex,
    required this.accent,
    required this.subColor,
  });

  @override
  Widget build(BuildContext context) {
    final tips = _ProfileExtensions.profileImprovementTips;
    final tip = tips[currentIndex % tips.length];
    return Container(
      padding: const EdgeInsets.all(Spacing.sm),
      decoration: BoxDecoration(
        color: accent.withOpacity(0.04),
        borderRadius: BorderRadius.circular(Radii.sm),
        border: Border.all(color: accent.withOpacity(0.08)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              '💡 $tip',
              style: AppTypography.labelSmall.copyWith(
                color: subColor,
                fontSize: 11,
              ),
            ),
          ),
          Icon(
            Icons.arrow_forward_rounded,
            color: accent,
            size: 14,
          ),
        ],
      ),
    );
  }
}

/// Виджет-карка прогресу XP з анімацією.
class XpProgressBar extends StatelessWidget {
  /// Поточний XP.
  final int currentXp;

  /// XP до наступного рівня.
  final int xpToNext;

  /// Колір тексту.
  final Color textColor;

  /// Створює повзунок XP.
  const XpProgressBar({
    super.key,
    required this.currentXp,
    required this.xpToNext,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final progress = (currentXp / (currentXp + xpToNext)).clamp(0.0, 1.0);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 6,
            backgroundColor: AppColorsPS5.border.withOpacity(0.3),
            valueColor: AlwaysStoppedAnimation(AppColorsPS5.xp),
          ),
        ),
        const SizedBox(height: Spacing.xs),
        Text(
          '$currentXp / ${currentXp + xpToNext} XP',
          style: AppTypography.caption.copyWith(
            color: AppColorsPS5.xp,
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

/// Виджет-карка статистики заощаджень.
class SavingsOverviewCard extends StatelessWidget {
  /// Загальна сума заощаджень.
  final int totalSaved;

  /// Кількість внесків.
  final int totalDeposits;

  /// Дні з моменту приєднання.
  final int daysSinceJoin;

  /// Колір картки.
  final Color cardColor;

  /// Колір рамки.
  final Color borderColor;

  /// Основний колір тексту.
  final Color textColor;

  /// Другорядний колір.
  final Color subColor;

  /// Створює картку статистики заощаджень.
  const SavingsOverviewCard({
    super.key,
    required this.totalSaved,
    required this.totalDeposits,
    required this.daysSinceJoin,
    required this.cardColor,
    required this.borderColor,
    required this.textColor,
    required this.subColor,
  });

  @override
  Widget build(BuildContext context) {
    final dailyAvg = daysSinceJoin > 0
        ? totalSaved / daysSinceJoin
        : 0;
    return Container(
      padding: const EdgeInsets.all(Spacing.base),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(Radii.lg),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        children: [
          Text(
            'Загальна статистика заощаджень',
            style: AppTypography.labelMedium.copyWith(
              color: textColor,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: Spacing.sm),
          _buildRow('Загалом', '${totalSaved} грн', textColor),
          _buildRow('Внесків', '$totalDeposits', textColor),
          _buildRow('Період', '$daysSinceJoin дн', textColor),
          _buildRow('Середнє/день', '${dailyAvg.toStringAsFixed(0)} грн', textColor),
        ],
      ),
    );
  }

  Widget _buildRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: AppTypography.labelSmall.copyWith(color: color),
            ),
          ),
          Text(
            value,
            style: AppTypography.labelSmall.copyWith(
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
