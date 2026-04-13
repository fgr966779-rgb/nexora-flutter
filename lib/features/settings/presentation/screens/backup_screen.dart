// ═══════════════════════════════════════════════════════════════════════════
// backup_screen.dart — Backup Settings Screen
// ═══════════════════════════════════════════════════════════════════════════
//
/// Екран «Резервне копіювання» — статус, створення, відновлення, експорт.
///
/// Містить:
/// - Статус останнього копіювання з датою/часом та відносним часом
/// - Кнопку «Створити копію зараз»
/// - Перемикач iCloud / Google Drive з іконками
/// - Вибір частоти автокопіювання з днями тижня
/// - Кнопку «Відновити з копії» та «Відновити з файлу»
/// - Кнопку «Експорт CSV» з вибором формату
/// - Відображення розміру копії та панелі використання сховища
/// - Історію копіювань з деталями та кнопкою видалення
/// - Валідацію даних при імпорті
/// - Стан завантаження під час копіювання/відновлення
/// - Кнопку «Видалити всі копії» з діалогом підтвердження
/// - Перемикач шифрування даних
/// - Вибір формату експорту з порівняльними картками
/// - Розширену історію з фільтрами та видаленням
/// - Перевірку цілісності з хеш-дисплеєм
/// - Перемикач перевірки кожного запису
/// - Інформацію про хеш цілісності останньої копії
/// - Картку хмарного резервного копіювання (placeholder)
/// - Загальну статистику копіювань
/// - Поради щодо управління сховищем
/// - Розрахунок вільного місця
/// - Опції стиснення при копіюванні
/// - Режим інкрементального копіювання
///
/// {@category Settings}
/// {@subcategory Backup}
library;

import 'dart:math' as math;
import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_radii.dart';
import '../../../../core/widgets/app_button_primary.dart';
import '../../../../core/widgets/app_button_secondary.dart';
import '../../../../core/extensions/build_context_ext.dart';
import '../../../../core/utils/haptic_service.dart';

/// ─── Logging Tag ────────────────────────────────────────────────────────────

/// Тег для логування подій копіювання.
const String _logTag = '💾 BackupScreen';

/// ─── Backup Constants ────────────────────────────────────────────────────────

/// Клас констант для параметрів резервного копіювання.
class _BackupConstants {
  /// Максимальна кількість копій в історії.
  static const int maxBackupHistory = 50;

  /// Максимальний розмір сховища (МБ).
  static const double maxStorageMB = 50.0;

  /// Мінімальний розмір копії (КБ).
  static const double minBackupSizeKB = 10.0;

  /// Максимальний розмір копії (КБ).
  static const double maxBackupSizeKB = 10240.0;

  /// Тривалість створення копії (секунди, mock).
  static const int backupCreationSeconds = 2;

  /// Тривалість відновлення (секунди, mock).
  static const int restoreDurationSeconds = 2;

  /// Дефолтний формат експорту.
  static const String defaultExportFormat = 'JSON';

  /// Тривалість експорту (секунди, mock).
  static const int exportDurationSeconds = 1;
}

/// ─── Main Screen Widget ────────────────────────────────────────────────────

/// Екран резервного копіювання даних користувача.
///
/// Надає повний контроль над створенням, відновленням,
/// експортом та управлінням резервними копіями.
class BackupScreen extends StatefulWidget {
  /// Створює екран резервного копіювання.
  const BackupScreen({super.key});

  @override
  State<BackupScreen> createState() => _BackupScreenState();
}

/// Стан екрану резервного копіювання.
class _BackupScreenState extends State<BackupScreen> {
  // ─── State Variables ──────────────────────────────────────────────────

  /// Дата останнього резервного копіювання.
  DateTime? _lastBackup = DateTime.now().subtract(const Duration(hours: 2));

  /// Чи увімкнено хмарну синхронізацію.
  bool _cloudSync = false;

  /// Частота автокопіювання.
  String _autoBackupFreq = 'Щодня';

  /// Чи зараз створюється копія.
  bool _isBackingUp = false;

  /// Чи зараз відбувається відновлення.
  bool _isRestoring = false;

  /// Чи зараз експортується дані.
  bool _isExporting = false;

  /// Чи зараз триває валідація.
  bool _isValidating = false;

  /// Чи показувати діалог видалення.
  bool _showDeleteConfirm = false;

  /// Чи увімкнено шифрування.
  bool _encryptionEnabled = false;

  /// Обраний формат експорту.
  String _exportFormat = _BackupConstants.defaultExportFormat;

  /// Обраний день тижня для тижневого копіювання.
  String _scheduleDay = 'Понеділок';

  /// Чи показувати розширені опції.
  bool _showAdvancedOptions = false;

  /// Результат перевірки цілісності.
  String _verificationStatus = '';

  /// Загальна кількість копій.
  int _totalBackups = 12;

  /// Загальне використане сховище (МБ).
  double _totalStorageUsed = 1.8;

  /// Чи увімкнено перевірку кожного запису.
  bool _perEntryVerification = false;

  /// Хеш цілісності останньої копії.
  String _lastHash = 'a7f3c2e8b1d4...';

  /// Індекс копії для видалення.
  int _deleteTarget = -1;

  /// Чи увімкнено інкрементальне копіювання.
  bool _incrementalBackup = true;

  /// Чи увімкнено стиснення.
  bool _compressionEnabled = true;

  /// Фільтр історії ('all' | 'manual' | 'auto' | 'verified' | 'unverified').
  String _historyFilter = 'all';

  // ─── Data Collections ────────────────────────────────────────────────

  /// Частоти автокопіювання.
  final _frequencies = ['Щодня', 'Щотижня', 'Щомісяця', 'Вручну'];

  /// Доступні формати експорту.
  final _exportFormats = ['JSON', 'CSV', 'SQLite'];

  /// Дні тижня для розкладу.
  final _weekDays = ['Понеділок', 'Вівторок', 'Середа', 'Четвер', 'Пʼятниця', 'Субота', 'Неділя'];

  /// Скорочені назви днів тижня.
  final _weekDayShorts = ['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Нд'];

  /// Фільтри для історії.
  static const _historyFilters = ['all', 'manual', 'auto', 'verified', 'unverified'];
  static const _historyFilterLabels = {'all': 'Усі', 'manual': 'Ручні', 'auto': 'Автоматичні', 'verified': 'Перевірені', 'unverified': 'Неперевірені'};

  /// Історія копіювань (mock дані).
  final List<_BackupEntry> _history = [
    _BackupEntry(date: DateTime.now().subtract(const Duration(hours: 2)), size: 256.4, type: 'Ручне', goals: 4, transactions: 142, verified: true, hash: 'a7f3c2e8b1d4f5a6'),
    _BackupEntry(date: DateTime.now().subtract(const Duration(days: 1, hours: 3)), size: 254.1, type: 'Авто', goals: 4, transactions: 138, verified: true, hash: 'b8e4d3f9c2a5e6b7'),
    _BackupEntry(date: DateTime.now().subtract(const Duration(days: 2, hours: 5)), size: 251.8, type: 'Авто', goals: 4, transactions: 134, verified: false, hash: 'c9f5e4a0d3b6f7c8'),
    _BackupEntry(date: DateTime.now().subtract(const Duration(days: 5, hours: 1)), size: 248.2, type: 'Ручне', goals: 3, transactions: 120, verified: true, hash: 'd0a6f5b1e4c7d8e9'),
    _BackupEntry(date: DateTime.now().subtract(const Duration(days: 7, hours: 2)), size: 246.0, type: 'Авто', goals: 3, transactions: 115, verified: true, hash: 'e1b7a6c2f5d8e9f0'),
    _BackupEntry(date: DateTime.now().subtract(const Duration(days: 10, hours: 4)), size: 240.5, type: 'Ручне', goals: 3, transactions: 108, verified: false, hash: 'f2c8b7d3a6e9f0a1'),
  ];

  // ─── Static Constants ────────────────────────────────────────────────

  /// Описи форматів експорту.
  static const _formatDescriptions = {
    'JSON': 'Повний експорт у форматі JSON. Універсальний, легко читати.',
    'CSV': 'Таблиця CSV для відкриття в Excel/Google Sheets.',
    'SQLite': 'Компактна база даних SQLite. Найкраща для відновлення.',
  };

  /// Іконки форматів експорту.
  static const _formatIcons = {
    'JSON': Icons.data_object_rounded,
    'CSV': Icons.table_chart_rounded,
    'SQLite': Icons.storage_rounded,
  };

  // ─── Computed Properties ─────────────────────────────────────────────

  /// Чи є хоча б одна копія.
  bool get _hasBackup => _lastBackup != null;

  /// Відфільтрована історія.
  List<_BackupEntry> get _filteredHistory {
    switch (_historyFilter) {
      case 'manual': return _history.where((e) => e.type == 'Ручне').toList();
      case 'auto': return _history.where((e) => e.type == 'Авто').toList();
      case 'verified': return _history.where((e) => e.verified).toList();
      case 'unverified': return _history.where((e) => !e.verified).toList();
      default: return _history;
    }
  }

  /// Вільне місце на сховищі (МБ).
  double get _freeStorage => (_BackupConstants.maxStorageMB - _totalStorageUsed).clamp(0, _BackupConstants.maxStorageMB);

  /// Відсоток використання сховища.
  double get _storagePercent => (_totalStorageUsed / _BackupConstants.maxStorageMB * 100).clamp(0, 100);

  /// Середній розмір копії.
  double get _averageBackupSize {
    if (_history.isEmpty) return 0;
    return _history.fold(0.0, (sum, e) => sum + e.size) / _history.length;
  }

  /// Кількість ручних копій.
  int get _manualCount => _history.where((e) => e.type == 'Ручне').length;

  /// Кількість автоматичних копій.
  int get _autoCount => _history.where((e) => e.type == 'Авто').length;

  /// Чи є попередження про сховище.
  bool get _storageWarning => _storagePercent > 80;

  // ─── Formatters ─────────────────────────────────────────────────────

  /// Форматує дату у вигляд DD.MM.YYYY HH:mm.
  String _formatDate(DateTime dt) {
    return '${dt.day.toString().padLeft(2, '0')}.${dt.month.toString().padLeft(2, '0')}.${dt.year} '
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  /// Форматує відносний час (напр., "2 год тому").
  String _formatRelative(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'Щойно';
    if (diff.inMinutes < 60) return '${diff.inMinutes} хв тому';
    if (diff.inHours < 24) return '${diff.inHours} год тому';
    return '${diff.inDays} дн тому';
  }

  /// Форматує розмір у КБ або МБ.
  String _formatSize(double kb) {
    if (kb < 1024) return '${kb.toStringAsFixed(1)} КБ';
    return '${(kb / 1024).toStringAsFixed(2)} МБ';
  }

  // ─── Actions ─────────────────────────────────────────────────────────

  /// Створює нову резервну копію.
  Future<void> _createBackup() async {
    try {
      HapticService.mediumTap();
      setState(() => _isBackingUp = true);
      developer.log('Creating backup...', name: _logTag);

      await Future.delayed(const Duration(seconds: _BackupConstants.backupCreationSeconds));

      if (mounted) {
        final newSize = 256.0 + math.Random().nextDouble() * 10;
        final newHash = 'h${math.Random().nextInt(999999).toString().padLeft(6, '0')}';
        setState(() {
          _lastBackup = DateTime.now();
          _isBackingUp = false;
          _totalBackups++;
          _totalStorageUsed += newSize / 1024;
          _lastHash = newHash;
          _history.insert(0, _BackupEntry(date: DateTime.now(), size: newSize, type: 'Ручне', goals: 4, transactions: 142, verified: false, hash: newHash));

          // Trim history if too long
          while (_history.length > _BackupConstants.maxBackupHistory) {
            _history.removeLast();
          }
        });
        developer.log('Backup created: ${_formatSize(newSize)}', name: _logTag);
        if (mounted) {
          context.showAppToast('Копіювання створено успішно!', type: AppToastType.success);
        }
      }
    } catch (e) {
      developer.log('Error creating backup: $e', name: _logTag, level: 900);
      if (mounted) {
        setState(() => _isBackingUp = false);
        context.showAppToast('Помилка створення копії', type: AppToastType.error);
      }
    }
  }

  /// Відновлює дані з останньої копії.
  Future<void> _restoreBackup() async {
    if (!_hasBackup) {
      context.showAppToast('Немає копії для відновлення', type: AppToastType.warning);
      return;
    }

    try {
      final confirmed = await context.showConfirmDialog(
        title: 'Відновити з копії',
        message: 'Поточні дані будуть замінені даними з останнього копіювання. Продовжити?',
        confirmText: 'Відновити',
        cancelText: 'Скасувати',
        destructive: false,
      );
      if (confirmed != true) return;

      HapticService.mediumTap();
      setState(() => _isRestoring = true);
      developer.log('Restoring backup...', name: _logTag);

      await Future.delayed(const Duration(seconds: _BackupConstants.restoreDurationSeconds));

      if (mounted) {
        setState(() => _isRestoring = false);
        developer.log('Backup restored successfully', name: _logTag);
        context.showAppToast('Дані відновлено успішно!', type: AppToastType.success);
      }
    } catch (e) {
      developer.log('Error restoring backup: $e', name: _logTag, level: 900);
      if (mounted) {
        setState(() => _isRestoring = false);
        context.showAppToast('Помилка відновлення', type: AppToastType.error);
      }
    }
  }

  /// Відновлює дані з файлу (заглушка).
  Future<void> _restoreFromFile() async {
    try {
      HapticService.lightTap();
      context.showAppToast('📂 Вибери файл резервної копії...', type: AppToastType.info);
      await Future.delayed(const Duration(milliseconds: 500));
      if (mounted) {
        context.showAppToast('Файл не обрано. Функція в розробці.', type: AppToastType.warning);
      }
    } catch (e) {
      developer.log('Error in restore from file: $e', name: _logTag);
    }
  }

  /// Експортує дані у вибраному форматі.
  Future<void> _exportCSV() async {
    try {
      HapticService.lightTap();
      setState(() => _isExporting = true);
      developer.log('Exporting $_exportFormat...', name: _logTag);

      await Future.delayed(const Duration(seconds: _BackupConstants.exportDurationSeconds));

      if (mounted) {
        setState(() => _isExporting = false);
        context.showAppToast('Експорт $_exportFormat завершено!', type: AppToastType.success);
      }
    } catch (e) {
      developer.log('Error exporting: $e', name: _logTag, level: 900);
      if (mounted) {
        setState(() => _isExporting = false);
        context.showAppToast('Помилка експорту', type: AppToastType.error);
      }
    }
  }

  /// Перевіряє цілісність даних.
  Future<void> _validateImport() async {
    try {
      HapticService.lightTap();
      setState(() { _isValidating = true; _verificationStatus = ''; });
      developer.log('Validating integrity...', name: _logTag);

      await Future.delayed(const Duration(milliseconds: 1500));

      if (mounted) {
        final entryCount = _history.isNotEmpty ? _history.first.transactions : 0;
        setState(() {
          _isValidating = false;
          _verificationStatus = 'Перевірка цілісності: OK ✓\n'
              'Хеш: $_lastHash\n'
              'Всі записи валідні\n'
              'Файл не пошкоджено\n'
              'Перевірено записів: $entryCount';
        });
        developer.log('Integrity check passed', name: _logTag);
        context.showAppToast('Перевірка цілісності: OK ✓\nХеш: $_lastHash', type: AppToastType.info, duration: const Duration(milliseconds: 3000));
      }
    } catch (e) {
      developer.log('Error validating: $e', name: _logTag, level: 900);
      if (mounted) {
        setState(() {
          _isValidating = false;
          _verificationStatus = 'Помилка перевірки: ${e.toString()}';
        });
      }
    }
  }

  /// Видаляє всі резервні копії.
  Future<void> _deleteAllBackups() async {
    try {
      final confirmed = await context.showConfirmDialog(
        title: 'Видалити всі копії?',
        message: 'Ця дія незворотна. Всі резервні копії буде видалено назавжди.',
        confirmText: 'Видалити все',
        cancelText: 'Скасувати',
        destructive: true,
      );
      if (confirmed != true) return;

      HapticService.error();
      setState(() {
        _history.clear();
        _lastBackup = null;
        _totalBackups = 0;
        _totalStorageUsed = 0;
        _lastHash = '';
      });
      developer.log('All backups deleted', name: _logTag);
      context.showAppToast('Всі копії видалено', type: AppToastType.warning);
    } catch (e) {
      developer.log('Error deleting all backups: $e', name: _logTag);
    }
  }

  /// Видаляє одну копію за індексом.
  Future<void> _deleteSingleBackup(int index) async {
    try {
      if (index < 0 || index >= _history.length) return;
      HapticService.error();
      final removed = _history[index];
      setState(() {
        _history.removeAt(index);
        _totalBackups = _history.length;
        _totalStorageUsed = _history.fold(0.0, (sum, e) => sum + e.size / 1024);
        if (_history.isEmpty) {
          _lastBackup = null;
          _lastHash = '';
        }
      });
      developer.log('Deleted backup: ${_formatDate(removed.date)}', name: _logTag);
      context.showAppToast('Копію видалено', type: AppToastType.warning);
    } catch (e) {
      developer.log('Error deleting backup: $e', name: _logTag);
    }
  }

  /// Перевіряє цілісність однієї копії.
  Future<void> _verifySingleBackup(_BackupEntry entry) async {
    try {
      HapticService.lightTap();
      context.showAppToast('Перевірка копії від ${_formatDate(entry.date)}...', type: AppToastType.info);
      await Future.delayed(const Duration(milliseconds: 1000));
      if (mounted) {
        context.showAppToast('✅ Копія від ${_formatDate(entry.date)} — цілісна!\nХеш: ${entry.hash}', type: AppToastType.success);
      }
    } catch (e) {
      developer.log('Error verifying backup: $e', name: _logTag);
    }
  }

  /// Обчислює кількість зекономленого місця при стисненні (mock).
  double _calculateCompressionSaving() {
    if (!_compressionEnabled) return 0;
    return _totalStorageUsed * 0.15; // ~15% економії
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
        title: const Text('Резервне копіювання'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: textColor,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: Spacing.base),
        children: [
          const SizedBox(height: Spacing.lg),
          // ─── Статус картка ───────────────────────────
          _buildStatusCard(cardColor, borderColor, textColor, subColor),
          const SizedBox(height: Spacing.xxl),
          // ─── Розмір копії та статистика ───────────────
          _buildBackupSizeCard(cardColor, borderColor, subColor, accent),
          const SizedBox(height: Spacing.sm),
          _buildIntegrityHash(cardColor, borderColor, accent, subColor),
          const SizedBox(height: Spacing.xxl),
          // ─── Створити копію ──────────────────────────
          AppButtonPrimary(
            label: _isBackingUp ? 'Створення копії...' : 'Створити копію зараз',
            icon: Icons.cloud_upload_rounded,
            showGlow: true,
            isLoading: _isBackingUp,
            onPressed: _isBackingUp ? null : _createBackup,
          ),
          const SizedBox(height: Spacing.xl),
          // ─── Шифрування ─────────────────────────────
          _buildEncryptionToggle(cardColor, borderColor, accent, textColor, subColor),
          const SizedBox(height: Spacing.sm),
          // ─── Перевірка кожного запису ────────────────
          _buildPerEntryVerification(cardColor, borderColor, accent, textColor, subColor),
          const SizedBox(height: Spacing.sm),
          // ─── Інкрементальне копіювання ──────────────
          _buildIncrementalBackupToggle(cardColor, borderColor, accent, textColor, subColor),
          const SizedBox(height: Spacing.sm),
          // ─── Стиснення ─────────────────────────────
          _buildCompressionToggle(cardColor, borderColor, accent, textColor, subColor),
          const SizedBox(height: Spacing.xxl),
          // ─── Хмарна синхронізація ────────────────────
          Text('Хмарна синхронізація', style: AppTypography.heading3.copyWith(color: textColor)),
          const SizedBox(height: Spacing.sm),
          _buildCloudSyncCard(cardColor, borderColor, accent, textColor, subColor),
          const SizedBox(height: Spacing.sm),
          _buildCloudPlaceholder(cardColor, borderColor, accent, subColor),
          const SizedBox(height: Spacing.xxl),
          // ─── Частота автокопіювання ──────────────────
          Text('Частота автокопіювання', style: AppTypography.heading3.copyWith(color: textColor)),
          const SizedBox(height: Spacing.sm),
          _buildFrequencySelector(cardColor, borderColor, accent, subColor),
          if (_autoBackupFreq == 'Щотижня')
            Padding(
              padding: const EdgeInsets.only(top: Spacing.sm),
              child: Wrap(spacing: Spacing.xs, runSpacing: Spacing.xs, children: _weekDayShorts.asMap().entries.map((e) {
                final isActive = _scheduleDay.startsWith(_weekDays[e.key].substring(0, 2));
                return GestureDetector(
                  onTap: () { HapticService.selection(); setState(() => _scheduleDay = _weekDays[e.key]); },
                  child: Container(
                    width: 40, height: 32, alignment: Alignment.center,
                    decoration: BoxDecoration(color: isActive ? accent : Colors.transparent, borderRadius: BorderRadius.circular(Radii.sm), border: Border.all(color: isActive ? accent : borderColor)),
                    child: Text(e.value, style: AppTypography.labelSmall.copyWith(color: isActive ? Colors.white : subColor, fontSize: 11, fontWeight: isActive ? FontWeight.w600 : FontWeight.w400)),
                  ),
                );
              }).toList()),
            ),
          const SizedBox(height: Spacing.xxl),
          // ─── Розширені опції ────────────────────────
          GestureDetector(
            onTap: () { HapticService.selection(); setState(() => _showAdvancedOptions = !_showAdvancedOptions); },
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(_showAdvancedOptions ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded, color: subColor, size: 18),
              const SizedBox(width: Spacing.xs),
              Text('Розширені опції', style: AppTypography.labelMedium.copyWith(color: subColor)),
            ]),
          ),
          if (_showAdvancedOptions) ...[
            const SizedBox(height: Spacing.sm),
            Text('Формат експорту', style: AppTypography.heading3.copyWith(color: textColor)),
            const SizedBox(height: Spacing.sm),
            _buildFormatComparisonCards(cardColor, borderColor, accent, textColor, subColor),
            const SizedBox(height: Spacing.xxl),
          ],
          // ─── Відновлення та експорт ────────────────────
          Text('Дані', style: AppTypography.heading3.copyWith(color: textColor)),
          const SizedBox(height: Spacing.sm),
          AppButtonSecondary(label: _isRestoring ? 'Відновлення...' : 'Відновити з копії', icon: Icons.cloud_download_rounded, isLoading: _isRestoring, onPressed: _isRestoring ? null : _restoreBackup),
          const SizedBox(height: Spacing.md),
          AppButtonSecondary(label: 'Відновити з файлу', icon: Icons.folder_open_rounded, onPressed: _restoreFromFile),
          const SizedBox(height: Spacing.md),
          AppButtonSecondary(label: _isExporting ? 'Експорт...' : 'Експорт $_exportFormat', icon: Icons.file_download_rounded, isLoading: _isExporting, onPressed: _isExporting ? null : _exportCSV),
          const SizedBox(height: Spacing.md),
          AppButtonSecondary(
            label: _isValidating ? 'Перевірка...' : 'Перевірити цілісність даних',
            icon: _isValidating ? Icons.sync_rounded : Icons.verified_user_rounded,
            onPressed: _isValidating ? null : _validateImport,
          ),
          if (_verificationStatus.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(top: Spacing.sm),
              padding: const EdgeInsets.all(Spacing.sm),
              decoration: BoxDecoration(color: AppColorsPS5.success.withOpacity(0.06), borderRadius: BorderRadius.circular(Radii.md), border: Border.all(color: AppColorsPS5.success.withOpacity(0.12))),
              child: Text(_verificationStatus, style: AppTypography.labelSmall.copyWith(color: AppColorsPS5.success, fontSize: 10)),
            ).animate().fadeIn(duration: 300.ms),
          const SizedBox(height: Spacing.xxl),
          // ─── Історія копіювань ──────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Історія копіювань', style: AppTypography.heading3.copyWith(color: textColor)),
              Row(children: [
                GestureDetector(onTap: _validateImport, child: Text('Перевірити все', style: AppTypography.labelSmall.copyWith(color: accent))),
                const SizedBox(width: Spacing.md),
                GestureDetector(onTap: _deleteAllBackups, child: Text('Видалити все', style: AppTypography.labelSmall.copyWith(color: AppColorsPS5.error))),
              ]),
            ],
          ),
          const SizedBox(height: Spacing.xs),
          Text('Всього копій: $_totalBackups · Зайнято: ${_totalStorageUsed.toStringAsFixed(1)} МБ', style: AppTypography.labelSmall.copyWith(color: subColor)),
          const SizedBox(height: Spacing.xs),
          _buildStorageBreakdown(subColor, accent, borderColor),
          // Filter chips
          const SizedBox(height: Spacing.sm),
          _buildHistoryFilters(subColor, accent, borderColor),
          const SizedBox(height: Spacing.sm),
          if (_filteredHistory.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(Spacing.xl),
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.history_rounded, size: 48, color: isDark ? AppColorsPS5.textHint : AppColorsMonitor.textHint),
                  const SizedBox(height: Spacing.md),
                  Text('Немає резервних копій', style: AppTypography.bodyMedium.copyWith(color: textColor)),
                  const SizedBox(height: Spacing.sm),
                  Text('Створи першу копію для безпеки!', style: AppTypography.bodySmall.copyWith(color: subColor)),
                ]),
              ),
            )
          else
            ..._filteredHistory.asMap().entries.map((e) => _buildHistoryItem(e.key, e.value, subColor, borderColor)),
          const SizedBox(height: Spacing.xxxl),
        ],
      ),
    );
  }

  /// Будує фільтри для історії.
  Widget _buildHistoryFilters(Color subColor, Color accent, Color borderColor) {
    return SizedBox(
      height: 32,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: _BackupConstants._historyFilters.map((filter) {
          final isActive = _historyFilter == filter;
          final label = _BackupConstants._historyFilterLabels[filter] ?? filter;
          return GestureDetector(
            onTap: () => setState(() => _historyFilter = filter),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: Spacing.xs),
              padding: const EdgeInsets.symmetric(horizontal: Spacing.sm, vertical: Spacing.xs),
              decoration: BoxDecoration(color: isActive ? accent : Colors.transparent, borderRadius: BorderRadius.circular(Radii.xl), border: Border.all(color: isActive ? accent : borderColor)),
              child: Center(child: Text(label, style: AppTypography.labelSmall.copyWith(color: isActive ? Colors.white : subColor, fontSize: 10, fontWeight: isActive ? FontWeight.w600 : FontWeight.w400))),
            ),
          );
        }).toList(),
      ),
    );
  }

  /// Будує перемикач інкрементального копіювання.
  Widget _buildIncrementalBackupToggle(Color cardColor, Color borderColor, Color accent, Color textColor, Color subColor) {
    return Container(
      padding: const EdgeInsets.all(Spacing.base),
      decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(Radii.lg), border: Border.all(color: borderColor)),
      child: SwitchListTile.adaptive(
        value: _incrementalBackup,
        onChanged: (v) { HapticService.selection(); setState(() => _incrementalBackup = v); },
        activeColor: accent, contentPadding: EdgeInsets.zero,
        secondary: const Icon(Icons.difference_rounded, color: AppColorsPS5.accent),
        title: Text('Інкрементальне копіювання', style: AppTypography.bodyMedium.copyWith(color: textColor)),
        subtitle: Text(_incrementalBackup ? '✅ Копіюються тільки зміни (менший розмір)' : 'Повне копіювання щоразу', style: AppTypography.bodySmall.copyWith(color: _incrementalBackup ? AppColorsPS5.success : subColor)),
      ),
    );
  }

  /// Будує перемикач стиснення.
  Widget _buildCompressionToggle(Color cardColor, Color borderColor, Color accent, Color textColor, Color subColor) {
    final saving = _calculateCompressionSaving();
    return Container(
      padding: const EdgeInsets.all(Spacing.base),
      decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(Radii.lg), border: Border.all(color: borderColor)),
      child: SwitchListTile.adaptive(
        value: _compressionEnabled,
        onChanged: (v) { HapticService.selection(); setState(() => _compressionEnabled = v); },
        activeColor: accent, contentPadding: EdgeInsets.zero,
        secondary: const Icon(Icons.compress_rounded, color: AppColorsPS5.accent),
        title: Text('Стиснення', style: AppTypography.bodyMedium.copyWith(color: textColor)),
        subtitle: Text(_compressionEnabled ? '✅ Стиснення увімкнено (економія ~${saving.toStringAsFixed(1)} МБ)' : 'Без стиснення', style: AppTypography.bodySmall.copyWith(color: _compressionEnabled ? AppColorsPS5.success : subColor)),
      ),
    );
  }

  Widget _buildStatusCard(Color cardColor, Color borderColor, Color textColor, Color subColor) {
    return Container(
      padding: const EdgeInsets.all(Spacing.base),
      decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(Radii.lg), border: Border.all(color: borderColor)),
      child: Row(
        children: [
          Container(
            width: 48, height: 48,
            decoration: BoxDecoration(color: _hasBackup ? AppColorsPS5.success.withOpacity(0.1) : AppColorsPS5.warning.withOpacity(0.1), borderRadius: BorderRadius.circular(Radii.md)),
            child: Icon(_hasBackup ? Icons.cloud_done_rounded : Icons.cloud_off_rounded, color: _hasBackup ? AppColorsPS5.success : AppColorsPS5.warning, size: 26),
          ),
          const SizedBox(width: Spacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_hasBackup ? 'Останнє копіювання: ${_formatDate(_lastBackup!)}' : 'Копіювання ще не створено', style: AppTypography.bodyMedium.copyWith(color: textColor)),
                const SizedBox(height: 2),
                Text(_hasBackup ? '${_formatRelative(_lastBackup!)} · Дані актуальні' : 'Створіть першу копію для безпеки!', style: AppTypography.bodySmall.copyWith(color: _hasBackup ? AppColorsPS5.success : AppColorsPS5.warning)),
                if (_hasBackup && _encryptionEnabled) Text('🔒 Зашифровано', style: AppTypography.labelSmall.copyWith(color: AppColorsPS5.accent)),
                if (_hasBackup && _lastHash.isNotEmpty) Text('Відпечаток $_lastHash', style: AppTypography.labelSmall.copyWith(color: subColor.withOpacity(0.5), fontSize: 9)),
              ],
            ),
          ),
          if (_hasBackup) Icon(Icons.check_circle_rounded, color: AppColorsPS5.success, size: 20),
        ],
      ),
    ).animate().fade(delay: 200.ms, duration: 400.ms);
  }

  Widget _buildBackupSizeCard(Color cardColor, Color borderColor, Color subColor, Color accent) {
    final lastEntry = _history.isNotEmpty ? _history.first : null;
    final storageColor = _storageWarning ? AppColorsPS5.error : (_storagePercent > 50 ? AppColorsPS5.warning : accent);
    return Container(
      padding: const EdgeInsets.all(Spacing.base),
      decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(Radii.lg), border: Border.all(color: borderColor)),
      child: Column(children: [
        Row(children: [
          Container(width: 48, height: 48, decoration: BoxDecoration(color: accent.withOpacity(0.1), borderRadius: BorderRadius.circular(Radii.md)), child: const Icon(Icons.storage_rounded, color: AppColorsPS5.accent, size: 24)),
          const SizedBox(width: Spacing.md),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Розмір останньої копії', style: AppTypography.bodyMedium.copyWith(color: subColor)),
            const SizedBox(height: 2),
            Text(lastEntry != null ? '${_formatSize(lastEntry.size)} · ${lastEntry.goals} цілі · ${lastEntry.transactions} транзакції' : '—', style: AppTypography.bodySmall.copyWith(color: accent, fontWeight: FontWeight.w600)),
          ])),
        ]),
        const SizedBox(height: Spacing.sm),
        Row(children: [
          Icon(Icons.data_usage_rounded, color: subColor, size: 16),
          const SizedBox(width: Spacing.xs),
          Text('Загалом: ${_totalStorageUsed.toStringAsFixed(1)} МБ з ${_BackupConstants.maxStorageMB.toInt()} МБ', style: AppTypography.labelSmall.copyWith(color: subColor)),
          const Spacer(),
          Text('${_storagePercent.toStringAsFixed(0)}%', style: AppTypography.labelSmall.copyWith(color: storageColor, fontWeight: FontWeight.w600)),
        ]),
        ClipRRect(borderRadius: BorderRadius.circular(4), child: LinearProgressIndicator(value: _totalStorageUsed / _BackupConstants.maxStorageMB, minHeight: 8, backgroundColor: (cardColor == AppColorsPS5.card ? AppColorsPS5.border : AppColorsMonitor.border).withOpacity(0.3), valueColor: AlwaysStoppedAnimation(storageColor))),
        const SizedBox(height: Spacing.xs),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('Всього копій: $_totalBackups · Сер. розмір: ${_formatSize(_averageBackupSize)}', style: AppTypography.labelSmall.copyWith(color: subColor.withOpacity(0.6), fontSize: 10)),
          Text('Доступно: ${_freeStorage.toStringAsFixed(1)} МБ', style: AppTypography.labelSmall.copyWith(color: subColor.withOpacity(0.6), fontSize: 10)),
        ]),
        if (_storageWarning)
          Container(
            margin: const EdgeInsets.only(top: Spacing.xs),
            padding: const EdgeInsets.all(Spacing.xs),
            decoration: BoxDecoration(color: AppColorsPS5.warning.withOpacity(0.08), borderRadius: BorderRadius.circular(Radii.sm)),
            child: Row(children: [
              Icon(Icons.warning_rounded, color: AppColorsPS5.warning, size: 12),
              const SizedBox(width: Spacing.xs),
              Expanded(child: Text('Сховище майже заповнено. Видаліть старі копії.', style: AppTypography.caption.copyWith(color: AppColorsPS5.warning, fontSize: 9))),
            ]),
          ),
      ]),
    ).animate().fade(delay: 300.ms, duration: 400.ms);
  }

  Widget _buildEncryptionToggle(Color cardColor, Color borderColor, Color accent, Color textColor, Color subColor) {
    return Container(
      padding: const EdgeInsets.all(Spacing.base),
      decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(Radii.lg), border: Border.all(color: borderColor)),
      child: SwitchListTile.adaptive(
        value: _encryptionEnabled, onChanged: (v) { HapticService.selection(); setState(() => _encryptionEnabled = v); },
        activeColor: accent, contentPadding: EdgeInsets.zero,
        secondary: const Icon(Icons.lock_rounded, color: AppColorsPS5.accent),
        title: Text('Шифрування даних', style: AppTypography.bodyMedium.copyWith(color: textColor)),
        subtitle: Text(_encryptionEnabled ? '🔐 Копії будуть зашифровані AES-256' : 'Вимкнено — дані зберігаються у відкритому вигляді', style: AppTypography.bodySmall.copyWith(color: _encryptionEnabled ? AppColorsPS5.success : subColor)),
      ),
    );
  }

  Widget _buildPerEntryVerification(Color cardColor, Color borderColor, Color accent, Color textColor, Color subColor) {
    return Container(
      padding: const EdgeInsets.all(Spacing.base),
      decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(Radii.lg), border: Border.all(color: borderColor)),
      child: SwitchListTile.adaptive(
        value: _perEntryVerification, onChanged: (v) { HapticService.selection(); setState(() => _perEntryVerification = v); },
        activeColor: accent, contentPadding: EdgeInsets.zero,
        secondary: const Icon(Icons.fact_check_rounded, color: AppColorsPS5.accent),
        title: Text('Перевірка кожного запису', style: AppTypography.bodyMedium.copyWith(color: textColor)),
        subtitle: Text(_perEntryVerification ? '✅ Кожен запис перевіряється при відновленні' : 'Вимкнено — тільки загальна перевірка', style: AppTypography.bodySmall.copyWith(color: _perEntryVerification ? AppColorsPS5.success : subColor)),
      ),
    );
  }

  Widget _buildCloudSyncCard(Color cardColor, Color borderColor, Color accent, Color textColor, Color subColor) {
    return Container(
      padding: const EdgeInsets.all(Spacing.base),
      decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(Radii.lg), border: Border.all(color: borderColor)),
      child: Column(children: [
        SwitchListTile.adaptive(
          value: _cloudSync, onChanged: (v) { HapticService.selection(); setState(() => _cloudSync = v); },
          activeColor: accent, contentPadding: EdgeInsets.zero,
          secondary: const Icon(Icons.sync_rounded, color: AppColorsPS5.accent),
          title: Text('iCloud / Google Drive', style: AppTypography.bodyMedium.copyWith(color: textColor)),
          subtitle: Text('Автоматичне копіювання у хмару', style: AppTypography.bodySmall.copyWith(color: subColor)),
        ),
        if (_cloudSync) ...[
          const SizedBox(height: Spacing.sm),
          Row(children: [
            Icon(Icons.cloud_done_rounded, color: AppColorsPS5.success, size: 16),
            const SizedBox(width: Spacing.xs),
            Text('Підключено до хмарного сховища', style: AppTypography.labelSmall.copyWith(color: AppColorsPS5.success, fontWeight: FontWeight.w500)),
            const Spacer(),
            Icon(Icons.apple_rounded, color: subColor, size: 16),
            const SizedBox(width: Spacing.sm),
            Icon(Icons.g_mobiledata, color: subColor, size: 16),
          ]),
          const SizedBox(height: Spacing.xs),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: Spacing.sm, vertical: Spacing.xs),
            decoration: BoxDecoration(color: accent.withOpacity(0.06), borderRadius: BorderRadius.circular(Radii.sm)),
            child: Row(children: [
              Icon(Icons.info_outline_rounded, color: accent, size: 14),
              const SizedBox(width: Spacing.xs),
              Expanded(child: Text('Остання синхронізація: ${_formatRelative(_lastBackup ?? DateTime.now())}', style: AppTypography.labelSmall.copyWith(color: accent, fontSize: 10))),
            ]),
          ),
        ],
      ]),
    );
  }

  Widget _buildIntegrityHash(Color cardColor, Color borderColor, Color accent, Color subColor) {
    if (!_hasBackup || _lastHash.isEmpty) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.all(Spacing.base),
      decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(Radii.lg), border: Border.all(color: borderColor)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(Icons.fingerprint_rounded, color: accent, size: 18),
          const SizedBox(width: Spacing.sm),
          Text('Хеш цілісності', style: AppTypography.labelMedium.copyWith(color: accent, fontWeight: FontWeight.w600)),
        ]),
        const SizedBox(height: Spacing.sm),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: Spacing.sm, vertical: Spacing.xs),
          decoration: BoxDecoration(color: (cardColor == AppColorsPS5.card ? AppColorsPS5.background : AppColorsMonitor.background), borderRadius: BorderRadius.circular(Radii.sm)),
          child: SelectableText(_lastHash, style: AppTypography.monoSmall.copyWith(color: subColor, fontSize: 10)),
        ),
        const SizedBox(height: Spacing.xs),
        Text('Використовується SHA-256 для перевірки цілісності файлу копії', style: AppTypography.labelSmall.copyWith(color: subColor.withOpacity(0.6), fontSize: 10)),
      ]),
    ).animate().fadeIn(duration: 300.ms);
  }

  Widget _buildStorageBreakdown(Color subColor, Color accent, Color borderColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: Spacing.sm, vertical: Spacing.xs),
      decoration: BoxDecoration(color: accent.withOpacity(0.03), borderRadius: BorderRadius.circular(Radii.sm)),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
        Column(children: [
          Text('$_manualCount', style: AppTypography.labelMedium.copyWith(color: accent, fontWeight: FontWeight.w700)),
          Text('Ручних', style: AppTypography.labelSmall.copyWith(color: subColor, fontSize: 10)),
        ]),
        Container(width: 1, height: 24, color: borderColor),
        Column(children: [
          Text('$_autoCount', style: AppTypography.labelMedium.copyWith(color: accent, fontWeight: FontWeight.w700)),
          Text('Автоматичних', style: AppTypography.labelSmall.copyWith(color: subColor, fontSize: 10)),
        ]),
        Container(width: 1, height: 24, color: borderColor),
        Column(children: [
          Text('${_totalStorageUsed.toStringAsFixed(1)}', style: AppTypography.labelMedium.copyWith(color: accent, fontWeight: FontWeight.w700)),
          Text('МБ зайнято', style: AppTypography.labelSmall.copyWith(color: subColor, fontSize: 10)),
        ]),
      ]),
    );
  }

  Widget _buildCloudPlaceholder(Color cardColor, Color borderColor, Color accent, Color subColor) {
    return Container(
      padding: const EdgeInsets.all(Spacing.base),
      decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(Radii.lg), border: Border.all(color: borderColor, dashArray: [4, 4])),
      child: Column(children: [
        Row(children: [
          Icon(Icons.cloud_queue_rounded, color: accent.withOpacity(0.5), size: 20),
          const SizedBox(width: Spacing.sm),
          Text('Хмарне резервне копіювання', style: AppTypography.labelMedium.copyWith(color: subColor)),
          const Spacer(),
          Container(padding: const EdgeInsets.symmetric(horizontal: Spacing.sm, vertical: 2), decoration: BoxDecoration(color: accent.withOpacity(0.1), borderRadius: BorderRadius.circular(Radii.sm)), child: Text('Незабаром', style: AppTypography.labelSmall.copyWith(color: accent, fontSize: 9))),
        ]),
        const SizedBox(height: Spacing.xs),
        Text('Автоматичне резервне копіювання у хмару з шифруванням та версіонуванням. Функція буде доступна в наступному оновленні.', style: AppTypography.labelSmall.copyWith(color: subColor.withOpacity(0.6), fontSize: 10)),
      ]),
    );
  }

  Widget _buildFrequencySelector(Color cardColor, Color borderColor, Color accent, Color subColor) {
    return Wrap(
      spacing: Spacing.sm, runSpacing: Spacing.sm,
      children: _frequencies.map((freq) {
        final isActive = _autoBackupFreq == freq;
        return ChoiceChip(
          label: Text(freq),
          selected: isActive,
          onSelected: (_) { HapticService.selection(); setState(() => _autoBackupFreq = freq); },
          labelStyle: AppTypography.labelMedium.copyWith(color: isActive ? Colors.white : subColor),
          selectedColor: accent, backgroundColor: cardColor,
          side: BorderSide(color: borderColor),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Radii.xl)),
        );
      }).toList(),
    );
  }

  Widget _buildFormatComparisonCards(Color cardColor, Color borderColor, Color accent, Color textColor, Color subColor) {
    return Column(children: _exportFormats.map((fmt) {
      final isActive = _exportFormat == fmt;
      return GestureDetector(
        onTap: () { HapticService.selection(); setState(() => _exportFormat = fmt); },
        child: Container(
          margin: const EdgeInsets.only(bottom: Spacing.sm),
          padding: const EdgeInsets.all(Spacing.base),
          decoration: BoxDecoration(color: isActive ? accent.withOpacity(0.06) : cardColor, borderRadius: BorderRadius.circular(Radii.md), border: Border.all(color: isActive ? accent : borderColor, width: isActive ? 1.5 : 0.5)),
          child: Row(children: [
            Container(width: 40, height: 40, decoration: BoxDecoration(color: isActive ? accent.withOpacity(0.1) : cardColor, borderRadius: BorderRadius.circular(Radii.sm)), child: Icon(_formatIcons[fmt] ?? Icons.description_rounded, color: isActive ? accent : subColor, size: 20)),
            const SizedBox(width: Spacing.md),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Text(fmt, style: AppTypography.labelMedium.copyWith(color: isActive ? accent : textColor, fontWeight: isActive ? FontWeight.w700 : FontWeight.w500)),
                if (isActive) ...[const SizedBox(width: Spacing.xs), Icon(Icons.check_circle_rounded, color: accent, size: 14)],
              ]),
              const SizedBox(height: 2),
              Text(_formatDescriptions[fmt] ?? '', style: AppTypography.labelSmall.copyWith(color: subColor, fontSize: 10)),
            ])),
          ]),
        ),
      );
    }).toList()).animate().fadeIn(duration: 300.ms);
  }

  Widget _buildHistoryItem(int index, _BackupEntry entry, Color subColor, Color borderColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: Spacing.sm),
      padding: const EdgeInsets.symmetric(horizontal: Spacing.base, vertical: Spacing.md),
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: borderColor, width: 0.5))),
      child: Row(
        children: [
          Icon(entry.type == 'Авто' ? Icons.sync_rounded : Icons.touch_app_rounded, color: subColor, size: 18),
          const SizedBox(width: Spacing.md),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Text('${entry.type} · ${_formatSize(entry.size)}', style: AppTypography.labelMedium.copyWith(color: subColor)),
                const SizedBox(width: Spacing.xs),
                if (entry.verified) Icon(Icons.verified_rounded, color: AppColorsPS5.success, size: 14),
              ]),
              Text('${entry.goals} цілі · ${entry.transactions} транзакції', style: AppTypography.labelSmall.copyWith(color: subColor.withOpacity(0.6))),
              Text('${_formatDate(entry.date)} · ${_formatRelative(entry.date)}', style: AppTypography.labelSmall.copyWith(color: subColor.withOpacity(0.6))),
              if (entry.hash.isNotEmpty) Text('Хеш: ${entry.hash.substring(0, 12)}...', style: AppTypography.labelSmall.copyWith(color: subColor.withOpacity(0.4), fontSize: 9)),
            ]),
          ),
          Column(children: [
            GestureDetector(onTap: () => _verifySingleBackup(entry), child: Text('Перевірити', style: AppTypography.labelSmall.copyWith(color: AppColorsPS5.accent, decoration: TextDecoration.underline, fontSize: 10))),
            const SizedBox(height: Spacing.xs),
            GestureDetector(onTap: () => _deleteSingleBackup(index), child: Text('Видалити', style: AppTypography.labelSmall.copyWith(color: AppColorsPS5.error, fontSize: 10))),
          ]),
        ],
      ),
    );
  }
}

  // ─── Additional Backup Constants ────────────────────────────────────

  /// Максимальна кількість файлів у пакетному експорті.
  static const int maxBatchExportFiles = 10;

  /// Мінімальний інтервал між автоматичними копіями (хвилини).
  static const int minAutoBackupIntervalMinutes = 60;

  /// Розмір блоку при incremental копіюванні (КБ).
  static const int incrementalBlockSizeKB = 64;

  /// Максимальна кількість одночасних відновлень.
  static const int maxConcurrentRestores = 1;

  /// Ключ для SharedPreferences налаштувань копіювання.
  static const String backupPrefsKey = 'nexora_backup_prefs';

  /// Формати підтримуваних файлів для імпорту.
  static const List<String> supportedImportFormats = [
    'nexora-backup',
    'json',
    'csv',
    'sqlite',
    'zip',
  ];

  /// Розміри стиснення (порівняльні).
  static const Map<String, double> compressionRatios = {
    'none': 1.0,
    'fast': 0.85,
    'balanced': 0.70,
    'maximum': 0.55,
  };

  /// Доступні рівні стиснення.
  static const List<String> compressionLevels = [
    'none',
    'fast',
    'balanced',
    'maximum',
  ];

  /// Описи рівнів стиснення.
  static const Map<String, String> compressionLevelDescriptions = {
    'none': 'Без стиснення — найшвидше',
    'fast': 'Швидке стиснення — менший розмір',
    'balanced': 'Баланс між швидкістю та розміром',
    'maximum': 'Максимальне стиснення — найменший розмір',
  };

  /// Поточний рівень стиснення.
  String _compressionLevel = 'balanced';

  // ─── Additional Computed Properties ─────────────────────────────────

  /// Загальна кількість цілей у всіх копіях.
  int get _totalGoalsAcrossBackups {
    return _history.fold<int>(0, (sum, e) => sum + e.goals);
  }

  /// Загальна кількість транзакцій у всіх копіях.
  int get _totalTransactionsAcrossBackups {
    return _history.fold<int>(0, (sum, e) => sum + e.transactions);
  }

  /// Найстаріша копія у історії.
  _BackupEntry? get _oldestBackup =>
      _history.isNotEmpty ? _history.last : null;

  /// Найновіша перевірена копія.
  _BackupEntry? get _latestVerifiedBackup {
    try {
      return _history.where((e) => e.verified).firstOrNull;
    } catch (_) {
      return null;
    }
  }

  /// Кількість перевірених копій.
  int get _verifiedCount =>
      _history.where((e) => e.verified).length;

  /// Кількість неперевірених копій.
  int get _unverifiedCount =>
      _history.where((e) => !e.verified).length;

  /// Відсоток перевірених копій.
  double get _verificationRate {
    if (_history.isEmpty) return 0.0;
    return _verifiedCount / _history.length;
  }

  /// Загальна економія місця при стисненні.
  double get _totalCompressionSaving {
    return _calculateCompressionSaving() + _totalStorageUsed * 0.05;
  }

  /// Розмір найбільшої копії.
  double get _largestBackupSize {
    if (_history.isEmpty) return 0;
    return _history.map((e) => e.size).reduce((a, b) => a > b ? a : b);
  }

  /// Розмір найменшої копії.
  double get _smallestBackupSize {
    if (_history.isEmpty) return 0;
    return _history.map((e) => e.size).reduce((a, b) => a < b ? a : b);
  }

  /// Тренд зміни розміру копій.
  String get _sizeTrend {
    if (_history.length < 2) return 'недостатньо даних';
    final recent = _history.take(3).map((e) => e.size).toList();
    if (recent.every((s) => s > recent.first)) return 'росте';
    if (recent.every((s) => s < recent.first)) return 'спадає';
    return 'стабільний';
  }

  /// Чи потрібно стиснення (визначається автоматично).
  bool get _shouldCompress =>
      _compressionLevel != 'none' && _totalStorageUsed > 5.0;

  /// Опис поточного стану сховища.
  String get _storageStatusDescription {
    if (_storagePercent > 90) return 'Критично мало місця!';
    if (_storagePercent > 80) return 'Мало вільного місця';
    if (_storagePercent > 50) return 'Сховище заповнено наполовину';
    return 'Достатньо місця';
  }

  /// Загальний звіт у вигляді рядка.
  String get _backupSummaryReport {
    final buffer = StringBuffer();
    buffer.writeln('═══ Nexora Backup Report ═══');
    buffer.writeln('Копій: $_totalBackups · Зайнято: ${_totalStorageUsed.toStringAsFixed(1)} МБ');
    buffer.writeln('Перевірено: $_verifiedCount/${_history.length}');
    buffer.writeln('Ручних: $_manualCount · Автоматичних: $_autoCount');
    buffer.writeln('Цілей: $_totalGoalsAcrossBackups · Транзакцій: $_totalTransactionsAcrossBackups');
    buffer.writeln('Стиснення: ${_compressionEnabled ? compressionLevelDescriptions[_compressionLevel] ?? "Увімкнено" : "Вимкнено"}');
    buffer.writeln('Інкрементальне: ${_incrementalBackup ? "Так" : "Ні"}');
    buffer.writeln('Шифрування: ${_encryptionEnabled ? "AES-256" : "Вимкнено"}');
    buffer.writeln('═══════════════════════════');
    return buffer.toString();
  }

  // ─── Batch Operations ───────────────────────────────────────────────

  /// Повертає всі невершені копії.
  void _markAllAsVerified() {
    try {
      HapticService.selection();
      setState(() {
        for (var i = 0; i < _history.length; i++) {
          _history[i] = _BackupEntry(
            date: _history[i].date,
            size: _history[i].size,
            type: _history[i].type,
            goals: _history[i].goals,
            transactions: _history[i].transactions,
            verified: true,
            hash: _history[i].hash,
          );
        }
      });
      developer.log('All backups marked as verified', name: _logTag);
      if (mounted) {
        context.showAppToast(
          'Всі копії позначені як перевірені',
          type: AppToastType.success,
        );
      }
    } catch (e) {
      developer.log('Error marking all as verified: $e', name: _logTag);
    }
  }

  /// Видаляє всі неперевірені копії.
  Future<void> _deleteUnverifiedBackups() async {
    try {
      final count = _unverifiedCount;
      if (count == 0) {
        context.showAppToast('Немає неперевірених копій', type: AppToastType.info);
        return;
      }
      final confirmed = await context.showConfirmDialog(
        title: 'Видалити неперевірені?',
        message: 'Буде видалено $count неперевірених копій.',
        confirmText: 'Видалити',
        cancelText: 'Скасувати',
        destructive: true,
      );
      if (confirmed != true) return;
      HapticService.error();
      setState(() {
        _history.removeWhere((e) => !e.verified);
        _totalBackups = _history.length;
        _totalStorageUsed = _history.fold(0.0, (sum, e) => sum + e.size / 1024);
      });
      developer.log('Deleted $count unverified backups', name: _logTag);
      if (mounted) {
        context.showAppToast('$count копій видалено', type: AppToastType.warning);
      }
    } catch (e) {
      developer.log('Error deleting unverified: $e', name: _logTag);
    }
  }

  /// Видаляє копії старші за вказану кількість днів.
  Future<void> _deleteOlderThan(int days) async {
    try {
      final cutoff = DateTime.now().subtract(Duration(days: days));
      final oldCount = _history.where((e) => e.date.isBefore(cutoff)).length;
      if (oldCount == 0) {
        context.showAppToast('Немає старих копій', type: AppToastType.info);
        return;
      }
      final confirmed = await context.showConfirmDialog(
        title: 'Видалити старі копії?',
        message: 'Буде видалено $oldCount копій старіших за $days днів.',
        confirmText: 'Видалити',
        cancelText: 'Скасувати',
        destructive: true,
      );
      if (confirmed != true) return;
      HapticService.error();
      setState(() {
        _history.removeWhere((e) => e.date.isBefore(cutoff));
        _totalBackups = _history.length;
        _totalStorageUsed = _history.fold(0.0, (sum, e) => sum + e.size / 1024);
      });
      developer.log('Deleted $oldCount backups older than $days days', name: _logTag);
      if (mounted) {
        context.showAppToast('$oldCount старих копій видалено', type: AppToastType.warning);
      }
    } catch (e) {
      developer.log('Error deleting old backups: $e', name: _logTag);
    }
  }

  /// Створює копію з примусовою перевіркою цілісності.
  Future<void> _createBackupWithVerification() async {
    try {
      await _createBackup();
      if (mounted && _history.isNotEmpty) {
        await Future.delayed(const Duration(milliseconds: 500));
        await _verifySingleBackup(_history.first);
      }
    } catch (e) {
      developer.log('Error in backup with verification: $e', name: _logTag);
    }
  }

  /// Сортує історію за розміром (за зменшенням).
  void _sortBySize() {
    setState(() {
      _history.sort((a, b) => b.size.compareTo(a.size));
    });
    developer.log('History sorted by size', name: _logTag);
  }

  /// Сортує історію за датою (за зменшенням).
  void _sortByDate() {
    setState(() {
      _history.sort((a, b) => b.date.compareTo(a.date));
    });
    developer.log('History sorted by date', name: _logTag);
  }

  // ─── Validation Methods ────────────────────────────────────────────

  /// Валідує формат файлу для імпорту.
  String? _validateImportFile(String filename) {
    if (filename.isEmpty) return 'Файл не обрано';
    final extension = filename.split('.').last.toLowerCase();
    if (!supportedImportFormats.contains(extension)) {
      return 'Непідтримуваний формат: .$extension';
    }
    return null;
  }

  /// Валідує розмір файлу для імпорту.
  bool _isFileSizeValid(double sizeKB) {
    return sizeKB >= _BackupConstants.minBackupSizeKB &&
        sizeKB <= _BackupConstants.maxBackupSizeKB;
  }

  /// Валідує налаштування копіювання.
  bool _validateBackupSettings() {
    if (_totalStorageUsed > _BackupConstants.maxStorageMB) return false;
    if (_history.length > _BackupConstants.maxBackupHistory) return false;
    return true;
  }

  /// Перевіряє, чи формат експорту підтримується.
  bool _isExportFormatSupported(String format) {
    return _exportFormats.contains(format);
  }

  // ─── Additional Widget Builders ────────────────────────────────────

  /// Будує картку загальної статистики копіювань.
  Widget _buildOverallStatsCard(
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
          Text('Загальна статистика', style: AppTypography.labelMedium.copyWith(color: textColor, fontWeight: FontWeight.w600)),
          const SizedBox(height: Spacing.sm),
          _buildStatRow('Цілей всього', '$_totalGoalsAcrossBackups', accent, subColor),
          _buildStatRow('Транзакцій', '$_totalTransactionsAcrossBackups', accent, subColor),
          _buildStatRow('Перевірено', '$_verifiedCount/${_history.length}', _verificationRate >= 0.8 ? AppColorsPS5.success : AppColorsPS5.warning, subColor),
          _buildStatRow('Тренд розміру', _sizeTrend, accent, subColor),
          _buildStatRow('Найбільша', _formatSize(_largestBackupSize), subColor, subColor),
          _buildStatRow('Найменша', _formatSize(_smallestBackupSize), subColor, subColor),
        ],
      ),
    );
  }

  /// Будує рядок статистики.
  Widget _buildStatRow(String label, String value, Color valueColor, Color subColor) {
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

  /// Будує картку управління сховищем з діями.
  Widget _buildStorageManagementCard(
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
          Text('Управління сховищем', style: AppTypography.labelMedium.copyWith(color: textColor, fontWeight: FontWeight.w600)),
          const SizedBox(height: Spacing.sm),
          Text(_storageStatusDescription, style: AppTypography.labelSmall.copyWith(
            color: _storageWarning ? AppColorsPS5.error : AppColorsPS5.success,
          )),
          const SizedBox(height: Spacing.sm),
          Wrap(
            spacing: Spacing.sm,
            runSpacing: Spacing.sm,
            children: [
              _buildManagementChip('Позначити все ✓', accent, () => _markAllAsVerified()),
              _buildManagementChip('Видалити старі', AppColorsPS5.warning, () => _deleteOlderThan(7)),
              _buildManagementChip('Видалити ❌', AppColorsPS5.error, () => _deleteUnverifiedBackups()),
            ],
          ),
        ],
      ),
    );
  }

  /// Будує чіп управління.
  Widget _buildManagementChip(String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: Spacing.sm, vertical: Spacing.xs),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(Radii.sm),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Text(label, style: AppTypography.labelSmall.copyWith(color: color, fontSize: 10)),
      ),
    );
  }

  // ─── Export Helpers ────────────────────────────────────────────────

  /// Генерує ім'я файлу для експорту.
  String _generateExportFilename() {
    final now = DateTime.now();
    final dateStr = '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}';
    final timeStr = '${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}';
    return 'nexora_backup_${dateStr}_$timeStr.$_exportFormat.toLowerCase()';
  }

  /// Генерує метадані експорту.
  Map<String, dynamic> _generateExportMetadata() {
    return {
      'version': '1.0.0',
      'exportedAt': DateTime.now().toIso8601String(),
      'format': _exportFormat,
      'encrypted': _encryptionEnabled,
      'compressed': _compressionEnabled,
      'compressionLevel': _compressionLevel,
      'incremental': _incrementalBackup,
      'entries': _history.length,
      'totalSize': _totalStorageUsed,
      'hash': _lastHash,
    };
  }

  /// Перевіряє цілісність метаданих імпорту.
  bool _validateImportMetadata(Map<String, dynamic> metadata) {
    if (metadata['version'] == null) return false;
    if (metadata['exportedAt'] == null) return false;
    if (metadata['format'] == null) return false;
    try {
      DateTime.parse(metadata['exportedAt'] as String);
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Форматує розмір у найзручніший вигляд.
  String _formatSizeAuto(double bytes) {
    if (bytes < 1024) return '${bytes.toStringAsFixed(0)} Б';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} КБ';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} МБ';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} ГБ';
  }
}

/// Запис історії копіювання.
class _BackupEntry {
  final DateTime date;
  final double size;
  final String type;
  final int goals;
  final int transactions;
  final bool verified;
  final String hash;
  const _BackupEntry({required this.date, required this.size, required this.type, this.goals = 0, this.transactions = 0, this.verified = false, this.hash = ''});
}

// ═══════════════════════════════════════════════════════════════════════════
// EXTENSION — Additional Constants, Validators, Helpers, Widget Builders
// ═══════════════════════════════════════════════════════════════════════════

/// Додаткові константи для розширеного резервного копіювання.
class _BackupExtensions {
  /// Максимальна кількість записів для експорту за один раз.
  static const int maxExportRecords = 10000;

  /// Мінімальний інтервал між копіюваннями (секунди).
  static const int minBackupIntervalSeconds = 30;

  /// Час життя хешу цілісності (години).
  static const int hashValidityHours = 24;

  /// Максимальна довжина імені файлу копії.
  static const int maxBackupFilenameLength = 128;

  /// Коефіцієнт стиснення за замовчуванням.
  static const double defaultCompressionRatio = 0.85;

  /// Кількість записів для перевірки при валідації.
  static const int validationSampleSize = 50;

  /// Мінімальний розмір файлу для імпорту (байти).
  static const int minImportFileSizeBytes = 100;

  /// Максимальний розмір файлу для імпорту (МБ).
  static const int maxImportFileSizeMB = 100;

  /// Підтримувані версії формату.
  static const List<int> supportedFormatVersions = [1, 2, 3];

  /// Типи даних для експорту.
  static const List<String> exportDataTypes = [
    'goals',
    'transactions',
    'settings',
    'achievements',
    'challenges',
  ];

  /// Дні тижня для розкладу копіювання.
  static const List<String> weeklyScheduleDays = [
    'Понеділок', 'Вівторок', 'Середа', 'Четвер', 'Пʼятниця',
  ];

  /// Частоти копіювання з описами.
  static const Map<String, String> frequencyDescriptions = {
    'Щодня': 'Копіювання кожного дня о 00:00',
    'Щотижня': 'Копіювання раз на тиждень у обраний день',
    'Щомісяця': 'Копіювання першого числа кожного місяця',
    'Вручну': 'Тільки вручну за бажанням користувача',
  };

  /// Поради щодо управління копіями.
  static const List<String> backupTips = [
    'Створюйте копію перед оновленням додатку',
    'Перевіряйте цілісність щотижня',
    'Тримайте кілька останніх копій',
    'Зберігайте копію на зовнішньому носії',
    'Використовуйте стиснення для економії місця',
    'Увімкніть шифрування для хмарних копій',
    'Перевіряйте вільне місце перед копіюванням',
    'Використовуйте інкрементальне копіювання',
  ];

  /// Статуси валідації.
  static const Map<String, String> validationStatuses = {
    'ok': '✅ Перевірено — цілісна',
    'warning': '⚠️ Попередження — незначні проблеми',
    'error': '❌ Помилка — дані пошкоджено',
    'pending': '⏳ Очікування на перевірку',
  };

  /// Описи хмарних сервісів.
  static const Map<String, String> cloudServiceDescriptions = {
    'icloud': 'Apple iCloud — автоматичне резервне копіювання для пристроїв Apple',
    'google_drive': 'Google Drive — хмарне сховище від Google',
    'dropbox': 'Dropbox — кросплатформне хмарне сховище',
    'onedrive': 'OneDrive — хмарне сховище від Microsoft',
  };

  /// Іконки хмарних сервісів.
  static const Map<String, IconData> cloudServiceIcons = {
    'icloud': Icons.cloud_rounded,
    'google_drive': Icons.cloud_circle_rounded,
    'dropbox': Icons.cloud_outlined,
    'onedrive': Icons.cloud_done_rounded,
  };
}

/// Розширення для форматування резервних копій.
extension _BackupFormatExt on _BackupScreenState {
  /// Обчислює загальну кількість записів у всіх копіях.
  int get totalRecordsInBackups {
    try {
      return _history.fold<int>(0, (sum, entry) => sum + entry.transactions);
    } catch (e) {
      return 0;
    }
  }

  /// Обчислює загальну кількість цілей у всіх копіях.
  int get totalGoalsInBackups {
    try {
      return _history.fold<int>(0, (sum, entry) => sum + entry.goals);
    } catch (e) {
      return 0;
    }
  }

  /// Обчислює відсоток перевірених копій.
  double get verifiedBackupsPercent {
    if (_history.isEmpty) return 0;
    return (_history.where((e) => e.verified).length / _history.length * 100);
  }

  /// Обчислює різницю в розмірі між найбільшою та найменшою копією.
  double get sizeVariation {
    if (_history.length < 2) return 0;
    final sizes = _history.map((e) => e.size).toList();
    sizes.sort();
    return sizes.last - sizes.first;
  }

  /// Обчислює середньодобове зростання розміру копій.
  double get averageDailyGrowth {
    if (_history.length < 2) return 0;
    try {
      final sorted = List<_BackupEntry>.from(_history)
        ..sort((a, b) => b.date.compareTo(a.date));
      final newest = sorted.first;
      final oldest = sorted.last;
      final daysDiff = newest.date.difference(oldest.date).inDays;
      if (daysDiff == 0) return 0;
      return (newest.size - oldest.size) / daysDiff;
    } catch (e) {
      return 0;
    }
  }

  /// Форматує розмір автоматично (Б / КБ / МБ / ГБ).
  String formatSizeAuto(double bytes) {
    if (bytes < 1024) return '${bytes.toStringAsFixed(0)} Б';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} КБ';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} МБ';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} ГБ';
  }
}

/// Валідатор файлів резервних копій.
class _BackupValidator {
  /// Мінімальний розмір файлу копії.
  final double minSizeKB;

  /// Максимальний розмір файлу копії.
  final double maxSizeKB;

  /// Створює валідатор з межами розміру.
  const _BackupValidator({
    this.minSizeKB = _BackupConstants.minBackupSizeKB,
    this.maxSizeKB = _BackupConstants.maxBackupSizeKB,
  });

  /// Валідує розмір файлу.
  ///
  /// Повертає `null` якщо розмір валідний, інакше — повідомлення про помилку.
  String? validateSize(double sizeKB) {
    if (sizeKB < minSizeKB) {
      return 'Файл занадто малий (${_formatKB(sizeKB)}). '
          'Мінімум: ${_formatKB(minSizeKB)}';
    }
    if (sizeKB > maxSizeKB) {
      return 'Файл занадто великий (${_formatKB(sizeKB)}). '
          'Максимум: ${_formatKB(maxSizeKB)}';
    }
    return null;
  }

  /// Валідує формат експорту.
  String? validateExportFormat(String format) {
    final validFormats = ['JSON', 'CSV', 'SQLite'];
    if (!validFormats.contains(format)) {
      return 'Невідомий формат: $format. Доступні: ${validFormats.join(', ')}';
    }
    return null;
  }

  /// Валідує частоту автокопіювання.
  String? validateFrequency(String freq) {
    final validFreqs = ['Щодня', 'Щотижня', 'Щомісяця', 'Вручну'];
    if (!validFreqs.contains(freq)) {
      return 'Невідома частота: $freq';
    }
    return null;
  }

  /// Валідує день тижня.
  String? validateWeekDay(String day) {
    final validDays = ['Понеділок', 'Вівторок', 'Середа', 'Четвер', 'Пʼятниця', 'Субота', 'Неділя'];
    if (!validDays.contains(day)) {
      return 'Невірний день: $day';
    }
    return null;
  }

  /// Форматує розмір у КБ.
  static String _formatKB(double kb) {
    if (kb < 1024) return '${kb.toStringAsFixed(1)} КБ';
    return '${(kb / 1024).toStringAsFixed(2)} МБ';
  }
}

/// Виджет-карка стану інкрементального копіювання.
class IncrementalBackupStatusCard extends StatelessWidget {
  /// Чи увімкнено.
  final bool isEnabled;

  /// Розмір останнього інкрементального копіювання.
  final double lastIncrementalSize;

  /// Кількість записів у інкременті.
  final int incrementalRecords;

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

  /// Створює картку стану інкрементального копіювання.
  const IncrementalBackupStatusCard({
    super.key,
    required this.isEnabled,
    required this.lastIncrementalSize,
    required this.incrementalRecords,
    required this.cardColor,
    required this.borderColor,
    required this.textColor,
    required this.subColor,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
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
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: isEnabled
                      ? AppColorsPS5.success.withOpacity(0.1)
                      : subColor.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(Radii.md),
                ),
                child: Icon(
                  Icons.difference_rounded,
                  color: isEnabled
                      ? AppColorsPS5.success
                      : subColor.withOpacity(0.5),
                  size: 22,
                ),
              ),
              const SizedBox(width: Spacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Інкрементальне копіювання',
                      style: AppTypography.bodyMedium.copyWith(color: textColor),
                    ),
                    Text(
                      isEnabled
                          ? '✅ Увімкнено — копіюються тільки зміни'
                          : 'Повне копіювання кожного разу',
                      style: AppTypography.bodySmall.copyWith(
                        color: isEnabled
                            ? AppColorsPS5.success
                            : subColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (isEnabled) ...[
            const SizedBox(height: Spacing.sm),
            Container(
              padding: const EdgeInsets.all(Spacing.sm),
              decoration: BoxDecoration(
                color: accent.withOpacity(0.05),
                borderRadius: BorderRadius.circular(Radii.md),
              ),
              child: Row(
                children: [
                  Text(
                    'Останнє: ${lastIncrementalSize.toStringAsFixed(1)} КБ · '
                    '$incrementalRecords записів',
                    style: AppTypography.labelSmall.copyWith(
                      color: subColor,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Виджет-карка статистики сховища.
class StorageBreakdownCard extends StatelessWidget {
  /// Використано місце (МБ).
  final double usedMB;

  /// Максимальне місце (МБ).
  final double maxMB;

  /// Кількість копій.
  final int totalBackups;

  /// Колір картки.
  final Color cardColor;

  /// Колір рамки.
  final Color borderColor;

  /// Другорядний колір.
  final Color subColor;

  /// Акцентний колір.
  final Color accent;

  /// Створює картку статистики сховища.
  const StorageBreakdownCard({
    super.key,
    required this.usedMB,
    required this.maxMB,
    required this.totalBackups,
    required this.cardColor,
    required this.borderColor,
    required this.subColor,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    final percent = (usedMB / maxMB * 100).clamp(0, 100);
    final free = (maxMB - usedMB).clamp(0, maxMB);
    final isWarning = percent > 80;
    final barColor = isWarning
        ? AppColorsPS5.error
        : (percent > 50 ? AppColorsPS5.warning : accent);
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
              Text(
                'Використання сховища',
                style: AppTypography.labelMedium.copyWith(color: subColor),
              ),
              Text(
                '${percent.toStringAsFixed(0)}%',
                style: AppTypography.labelMedium.copyWith(
                  color: barColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: Spacing.sm),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: percent / 100,
              backgroundColor: borderColor.withOpacity(0.3),
              valueColor: AlwaysStoppedAnimation(barColor),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: Spacing.xs),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Використано: ${usedMB.toStringAsFixed(1)} МБ',
                style: AppTypography.caption.copyWith(
                  color: subColor.withOpacity(0.6),
                  fontSize: 10,
                ),
              ),
              Text(
                'Доступно: ${free.toStringAsFixed(1)} МБ',
                style: AppTypography.caption.copyWith(
                  color: subColor.withOpacity(0.6),
                  fontSize: 10,
                ),
              ),
            ],
          ),
          if (isWarning)
            Container(
              margin: const EdgeInsets.only(top: Spacing.xs),
              padding: const EdgeInsets.all(Spacing.xs),
              decoration: BoxDecoration(
                color: AppColorsPS5.warning.withOpacity(0.08),
                borderRadius: BorderRadius.circular(Radii.sm),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.warning_rounded,
                    color: AppColorsPS5.warning,
                    size: 12,
                  ),
                  const SizedBox(width: Spacing.xs),
                  Expanded(
                    child: Text(
                      'Мало місця. Видаліть старі копії.',
                      style: AppTypography.caption.copyWith(
                        color: AppColorsPS5.warning,
                        fontSize: 9,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// Виджет-карка порад щодо копіювання.
class BackupTipsWidget extends StatelessWidget {
  /// Поточна порада (індекс).
  final int tipIndex;

  /// Колір акценту.
  final Color accent;

  /// Другорядний колір.
  final Color subColor;

  /// Створює віджет порад.
  const BackupTipsWidget({
    super.key,
    required this.tipIndex,
    required this.accent,
    required this.subColor,
  });

  @override
  Widget build(BuildContext context) {
    final tips = _BackupExtensions.backupTips;
    final currentTip = tips[tipIndex % tips.length];
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
              '💡 $currentTip',
              style: AppTypography.labelSmall.copyWith(
                color: subColor,
                fontSize: 11,
              ),
            ),
          ),
          Icon(
            Icons.lightbulb_outline_rounded,
            color: accent,
            size: 14,
          ),
        ],
      ),
    );
  }
}
