import 'dart:convert';

import 'package:nexora/data/models/auto_payment_model.dart';
import 'package:nexora/data/models/challenge_model.dart';
import 'package:nexora/data/models/goal_model.dart';
import 'package:nexora/data/models/transaction_model.dart';
import 'package:nexora/data/models/user_profile_model.dart';
import 'package:nexora/data/repositories/auto_payment_repository.dart';
import 'package:nexora/data/repositories/challenge_repository.dart';
import 'package:nexora/data/repositories/goal_repository.dart';
import 'package:nexora/data/repositories/transaction_repository.dart';
import 'package:nexora/data/repositories/user_repository.dart';

/// Репозиторій для експорту/імпорту даних (JSON, CSV).
///
/// Забезпечує повне бекапування, відновлення, версіонування,
/// валідацію даних при імпорті, розрахунок розміру бекапу
/// та управління історією бекапів.
///
/// Всі рядки-повідомлення українською.
class BackupRepository {
  final GoalRepository _goalRepo;
  final TransactionRepository _transactionRepo;
  final UserRepository _userRepo;
  final ChallengeRepository _challengeRepo;
  final AutoPaymentRepository _autoPaymentRepo;

  /// Історія бекапів для версіонування.
  final List<BackupInfo> _backupHistory = [];

  /// Максимальна кількість записів в історії.
  static const int _maxHistorySize = 50;

  /// Максимальна кількість записів для імпорту (захист від перевантаження).
  static const int _maxImportRecords = 10000;

  BackupRepository({
    required GoalRepository goalRepo,
    required TransactionRepository transactionRepo,
    required UserRepository userRepo,
    required ChallengeRepository challengeRepo,
    required AutoPaymentRepository autoPaymentRepo,
  })  : _goalRepo = goalRepo,
        _transactionRepo = transactionRepo,
        _userRepo = userRepo,
        _challengeRepo = challengeRepo,
        _autoPaymentRepo = autoPaymentRepo;

  // ─── JSON Експорт ──────────────────────────────────────────────────

  /// Експортує всі дані у форматі JSON (повний бекап).
  String exportToJson() {
    final backup = {
      'version': '1.0.0',
      'exportedAt': DateTime.now().toIso8601String(),
      'app': 'nexora',
      'user': _userRepo.getUser().toJson(),
      'goals': _goalRepo.getAll().map((g) => g.toJson()).toList(),
      'transactions':
          _transactionRepo.getAll().map((t) => t.toJson()).toList(),
      'challenges':
          _challengeRepo.getAll().map((c) => c.toJson()).toList(),
      'autoPayments':
          _autoPaymentRepo.getAll().map((a) => a.toJson()).toList(),
      'stats': _generateStats(),
    };
    return const JsonEncoder.withIndent('  ').convert(backup);
  }

  /// Експортує компактний JSON (без відступів, менший розмір).
  String exportToJsonCompact() {
    final backup = {
      'v': '1.0.0',
      'at': DateTime.now().toIso8601String(),
      'app': 'nexora',
      'u': _userRepo.getUser().toJson(),
      'g': _goalRepo.getAll().map((g) => g.toJson()).toList(),
      't': _transactionRepo.getAll().map((t) => t.toJson()).toList(),
      'c': _challengeRepo.getAll().map((c) => c.toJson()).toList(),
      'a': _autoPaymentRepo.getAll().map((a) => a.toJson()).toList(),
    };
    return json.encode(backup);
  }

  /// Експортує лише профіль користувача.
  String exportUserJson() {
    final data = {
      'version': '1.0.0',
      'exportedAt': DateTime.now().toIso8601String(),
      'app': 'nexora',
      'user': _userRepo.getUser().toJson(),
    };
    return const JsonEncoder.withIndent('  ').convert(data);
  }

  /// Експортує лише цілі.
  String exportGoalsJson() {
    final data = {
      'version': '1.0.0',
      'exportedAt': DateTime.now().toIso8601String(),
      'app': 'nexora',
      'goals': _goalRepo.getAll().map((g) => g.toJson()).toList(),
    };
    return const JsonEncoder.withIndent('  ').convert(data);
  }

  /// Експортує лише транзакції.
  String exportTransactionsJson() {
    final data = {
      'version': '1.0.0',
      'exportedAt': DateTime.now().toIso8601String(),
      'app': 'nexora',
      'transactions':
          _transactionRepo.getAll().map((t) => t.toJson()).toList(),
      'summary': {
        'total': _transactionRepo.count,
        'totalAmount': _transactionRepo.totalAmount,
      },
    };
    return const JsonEncoder.withIndent('  ').convert(data);
  }

  /// Експортує лише челенджі.
  String exportChallengesJson() {
    final data = {
      'version': '1.0.0',
      'exportedAt': DateTime.now().toIso8601String(),
      'app': 'nexora',
      'challenges':
          _challengeRepo.getAll().map((c) => c.toJson()).toList(),
    };
    return const JsonEncoder.withIndent('  ').convert(data);
  }

  /// Експортує лише автоплатежі.
  String exportAutoPaymentsJson() {
    final data = {
      'version': '1.0.0',
      'exportedAt': DateTime.now().toIso8601String(),
      'app': 'nexora',
      'autoPayments':
          _autoPaymentRepo.getAll().map((a) => a.toJson()).toList(),
    };
    return const JsonEncoder.withIndent('  ').convert(data);
  }

  // ─── JSON Імпорт ──────────────────────────────────────────────────

  /// Імпортує дані з JSON-рядка. Повертає результат імпорту.
  ImportResult importFromJson(String jsonString) {
    try {
      final data = json.decode(jsonString) as Map<String, dynamic>;

      // Базова валідація
      final validation = _validateImportData(data);
      if (!validation.isValid) {
        return ImportResult(
          success: false,
          errors: validation.errors,
        );
      }

      int importedGoals = 0;
      int importedTransactions = 0;
      int importedChallenges = 0;
      int importedAutoPayments = 0;
      int importedUser = 0;

      // Імпорт профілю користувача
      final userData = data['user'] ?? data['u'];
      if (userData != null) {
        final user = UserProfile.fromJson(userData as Map<String, dynamic>);
        _userRepo.save(user);
        importedUser = 1;
      }

      // Імпорт цілей
      final goalsData = data['goals'] ?? data['g'];
      if (goalsData != null) {
        final goalsList = goalsData as List<dynamic>;
        for (final goalJson in goalsList) {
          if (importedGoals >= _maxImportRecords) break;
          try {
            final goal = Goal.fromJson(goalJson as Map<String, dynamic>);
            _goalRepo.saveSilent(goal);
            importedGoals++;
          } catch (_) {
            // Пропускаємо некоректні записи
          }
        }
      }

      // Імпорт транзакцій
      final txData = data['transactions'] ?? data['t'];
      if (txData != null) {
        final txList = txData as List<dynamic>;
        for (final txJson in txList) {
          if (importedTransactions >= _maxImportRecords) break;
          try {
            final tx =
                Transaction.fromJson(txJson as Map<String, dynamic>);
            _transactionRepo.saveSilent(tx);
            importedTransactions++;
          } catch (_) {
            // Пропускаємо некоректні записи
          }
        }
      }

      // Імпорт челенджів
      final chData = data['challenges'] ?? data['c'];
      if (chData != null) {
        final chList = chData as List<dynamic>;
        for (final chJson in chList) {
          if (importedChallenges >= _maxImportRecords) break;
          try {
            final ch = Challenge.fromJson(chJson as Map<String, dynamic>);
            _challengeRepo.save(ch);
            importedChallenges++;
          } catch (_) {
            // Пропускаємо некоректні записи
          }
        }
      }

      // Імпорт автоматичних платежів
      final apData = data['autoPayments'] ?? data['a'];
      if (apData != null) {
        final apList = apData as List<dynamic>;
        for (final apJson in apList) {
          if (importedAutoPayments >= _maxImportRecords) break;
          try {
            final ap =
                AutoPayment.fromJson(apJson as Map<String, dynamic>);
            _autoPaymentRepo.saveSilent(ap);
            importedAutoPayments++;
          } catch (_) {
            // Пропускаємо некоректні записи
          }
        }
      }

      // Додаємо запис в історію бекапів
      _addBackupHistory(BackupType.import);

      return ImportResult(
        success: true,
        importedGoals: importedGoals,
        importedTransactions: importedTransactions,
        importedChallenges: importedChallenges,
        importedAutoPayments: importedAutoPayments,
        importedUser: importedUser,
      );
    } catch (e) {
      return ImportResult(
        success: false,
        errors: ['Помилка парсингу JSON: ${e.toString()}'],
      );
    }
  }

  // ─── CSV Експорт ───────────────────────────────────────────────────

  /// Експортує транзакції у CSV-формат.
  String exportCsv() {
    return _exportTransactionsCsv();
  }

  /// Експортує транзакції у CSV (повна назва).
  String exportTransactionsCsv() {
    return _exportTransactionsCsv();
  }

  /// Експортує резюме цілей у CSV-формат.
  String exportGoalsCsv() {
    final buffer = StringBuffer();
    buffer.writeln(
      'ID,Тип,Назва,Ціль,Накопичено,Прогрес %,Статус,Стрік,Створено',
    );

    final goals = _goalRepo.getAll();
    for (final g in goals) {
      final progress = (g.progress * 100).toStringAsFixed(1);
      final line = [
        g.id,
        g.type.name,
        g.name,
        g.targetAmount.toStringAsFixed(2),
        g.currentAmount.toStringAsFixed(2),
        progress,
        g.status.name,
        g.streakDays,
        g.createdAt.toIso8601String(),
      ].join(',');
      buffer.writeln(line);
    }

    return buffer.toString();
  }

  /// Експортує резюме автоплатежів у CSV.
  String exportAutoPaymentsCsv() {
    final buffer = StringBuffer();
    buffer.writeln(
      'ID,Ціль ID,Сума,Частота,День тижня,День місяця,Увімкнено,Ліміт,Виконань,Виплачено',
    );

    final payments = _autoPaymentRepo.getAll();
    for (final p in payments) {
      final line = [
        p.id,
        p.goalId,
        p.amount.toStringAsFixed(2),
        p.frequency.name,
        p.dayOfWeek?.toString() ?? '',
        p.dayOfMonth?.toString() ?? '',
        p.isEnabled.toString(),
        p.limitPerPeriod?.toStringAsFixed(2) ?? '',
        p.timesExecuted,
        p.totalPaid.toStringAsFixed(2),
      ].join(',');
      buffer.writeln(line);
    }

    return buffer.toString();
  }

  /// Експортує повний звіт у CSV (усі секції).
  String exportFullCsv() {
    final buffer = StringBuffer();

    // Профіль
    buffer.writeln('=== ПРОФІЛЬ КОРИСТУВАЧА ===');
    final user = _userRepo.getUser();
    buffer.writeln(
        'Ім\'я,Email,XP,Монети,Рівень,Стрік,Найбільший стрік,Бейджів,Дата реєстрації');
    buffer.writeln([
      user.name,
      user.email,
      user.xp,
      user.coins,
      user.currentLevel,
      user.currentStreak,
      user.longestStreak,
      user.unlockedBadges.length,
      user.createdAt.toIso8601String(),
    ].join(','));

    buffer.writeln();

    // Транзакції
    buffer.writeln('=== ТРАНЗАКЦІЇ ===');
    buffer.write(_exportTransactionsCsv());

    buffer.writeln();

    // Цілі
    buffer.writeln('=== ЦІЛІ ===');
    buffer.write(exportGoalsCsv());

    buffer.writeln();

    // Автоплатежі
    buffer.writeln('=== АВТОПЛАТЕЖІ ===');
    buffer.write(exportAutoPaymentsCsv());

    return buffer.toString();
  }

  // ─── CSV Імпорт ────────────────────────────────────────────────────

  /// Імпортує транзакції з CSV. Повертає кількість імпортованих.
  int importFromCsv(String csvContent, {String goalIdPrefix = ''}) {
    final lines = csvContent.split('\n');
    if (lines.length < 2) return 0;

    int imported = 0;
    // Пропускаємо заголовок
    for (int i = 1; i < lines.length; i++) {
      final line = lines[i].trim();
      if (line.isEmpty) continue;
      if (imported >= _maxImportRecords) break;

      try {
        final parts = line.split(',');
        if (parts.length < 6) continue;

        final tx = Transaction(
          id: parts[0],
          goalId:
              goalIdPrefix.isNotEmpty ? goalIdPrefix : parts[1],
          type: TransactionType.values.firstWhere(
            (e) => e.name == parts[2],
            orElse: () => TransactionType.manual,
          ),
          amount: double.tryParse(parts[3]) ?? 0,
          createdAt: DateTime.tryParse(parts[4]) ?? DateTime.now(),
          comment: parts.length > 5 ? parts[5] : null,
          xpEarned: parts.length > 6 ? int.tryParse(parts[6]) ?? 0 : 0,
          coinsEarned:
              parts.length > 7 ? int.tryParse(parts[7]) ?? 0 : 0,
        );
        _transactionRepo.saveSilent(tx);
        imported++;
      } catch (_) {
        // Пропускаємо некоректні рядки
      }
    }

    if (imported > 0) {
      _addBackupHistory(BackupType.csvImport);
    }

    return imported;
  }

  /// Імпортує цілі з CSV. Повертає кількість імпортованих.
  int importGoalsFromCsv(String csvContent) {
    final lines = csvContent.split('\n');
    if (lines.length < 2) return 0;

    int imported = 0;
    for (int i = 1; i < lines.length; i++) {
      final line = lines[i].trim();
      if (line.isEmpty) continue;

      try {
        final parts = line.split(',');
        if (parts.length < 4) continue;

        final goal = Goal(
          id: parts[0],
          type: GoalType.values.firstWhere(
            (e) => e.name == parts[1],
            orElse: () => GoalType.custom,
          ),
          name: parts[2],
          targetAmount: double.tryParse(parts[3]) ?? 0,
          currentAmount:
              parts.length > 4 ? double.tryParse(parts[4]) ?? 0 : 0,
          createdAt: DateTime.now(),
        );
        _goalRepo.saveSilent(goal);
        imported++;
      } catch (_) {
        // Пропускаємо некоректні рядки
      }
    }
    return imported;
  }

  // ─── Версіонування бекапів ─────────────────────────────────────────

  /// Створює запис бекапу в історії з обмеженням розміру.
  void _addBackupHistory(BackupType type) {
    if (_backupHistory.length >= _maxHistorySize) {
      _backupHistory.removeAt(0);
    }
    _backupHistory.add(BackupInfo(
      timestamp: DateTime.now(),
      type: type,
      stats: _generateStats(),
    ));
  }

  /// Створює бекап та додає в історію. Повертає JSON.
  String createBackup() {
    final json = exportToJson();
    _addBackupHistory(BackupType.full);
    return json;
  }

  /// Створює компактний бекап та додає в історію.
  String createCompactBackup() {
    final json = exportToJsonCompact();
    _addBackupHistory(BackupType.fullCompact);
    return json;
  }

  /// Повертає історію бекапів.
  List<BackupInfo> getBackupHistory() {
    return List.unmodifiable(_backupHistory);
  }

  /// Очищає історію бекапів.
  void clearBackupHistory() {
    _backupHistory.clear();
  }

  /// Повертає кількість записів в історії бекапів.
  int get backupHistoryCount => _backupHistory.length;

  /// Повертає історію бекапів за типом.
  List<BackupInfo> getBackupHistoryByType(BackupType type) {
    return _backupHistory
        .where((info) => info.type == type)
        .toList();
  }

  /// Повертає останні N записів історії.
  List<BackupInfo> getRecentBackupHistory({int limit = 10}) {
    if (_backupHistory.length <= limit) {
      return List.unmodifiable(_backupHistory);
    }
    return List.unmodifiable(
      _backupHistory.sublist(_backupHistory.length - limit),
    );
  }

  // ─── Інформація про розмір бекапу ─────────────────────────────────

  /// Повертає розмір експорту у байтах.
  int get lastBackupSize {
    final json = exportToJson();
    return json.length;
  }

  /// Повертає розмір компактного експорту у байтах.
  int get compactBackupSize {
    final json = exportToJsonCompact();
    return json.length;
  }

  /// Повертає розмір повного CSV-експорту у байтах.
  int get fullCsvSize {
    final csv = exportFullCsv();
    return csv.length;
  }

  /// Повертає інформацію про останній бекап.
  BackupInfo? get lastBackupInfo {
    if (_backupHistory.isEmpty) return null;
    return _backupHistory.last;
  }

  /// Повертає дату останнього бекапу, або null.
  DateTime? get lastBackupDate {
    if (_backupHistory.isEmpty) return null;
    return _backupHistory.last.timestamp;
  }

  /// Повертає кількість хвилин з останнього бекапу, або null.
  int? get minutesSinceLastBackup {
    final date = lastBackupDate;
    if (date == null) return null;
    return DateTime.now().difference(date).inMinutes;
  }

  /// Повертає розмір бекапу як текст (Б, КБ, МБ).
  String get formattedBackupSize {
    final bytes = lastBackupSize;
    if (bytes < 1024) return '$bytes Б';
    if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} КБ';
    }
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} МБ';
  }

  /// Повертає розмір компактного бекапу як текст.
  String get formattedCompactSize {
    final bytes = compactBackupSize;
    if (bytes < 1024) return '$bytes Б';
    if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} КБ';
    }
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} МБ';
  }

  /// Чи рекомендується зробити бекап (немає бекапу або минуло більше 24 годин).
  bool get isBackupRecommended {
    final date = lastBackupDate;
    if (date == null) return true;
    return DateTime.now().difference(date).inHours > 24;
  }

  /// Повертає текстову підказку щодо бекапу.
  String get backupTipText {
    if (_backupHistory.isEmpty) {
      return '💡 Зроби свій перший бекап, щоб зберегти всі дані!';
    }
    if (isBackupRecommended) {
      return '⚠️ Минуло більше 24 годин з останнього бекапу. Рекомендуємо оновити!';
    }
    return '✅ Бекап актуальний. Останній: ${lastBackupInfo?.formattedDate ?? "невідомо"}.';
  }

  // ─── Cloud Backup (stub) ───────────────────────────────────────────

  /// Заглушка для хмарного бекапу.
  Future<bool> cloudBackup() async {
    // TODO: Реалізувати інтеграцію з хмарним сервісом (Google Drive, iCloud)
    return false;
  }

  /// Заглушка для відновлення з хмари.
  Future<bool> cloudRestore() async {
    // TODO: Реалізувати інтеграцію з хмарним сервісом
    return false;
  }

  /// Чи доступний хмарний бекап.
  bool get isCloudBackupAvailable => false;

  // ─── Валідація ─────────────────────────────────────────────────────

  /// Валідує дані для імпорту. Повертає результат перевірки.
  ValidationResult _validateImportData(Map<String, dynamic> data) {
    final errors = <String>[];

    // Перевірка формату додатку
    final app = data['app'];
    if (app != 'nexora') {
      errors.add('Невідомий формат даних: очікується "nexora"');
    }

    // Перевірка версії формату
    final version = data['version'] ?? data['v'];
    if (version == null) {
      errors.add('Версія формату не вказана');
    }

    // Перевірка структури профілю
    final userData = data['user'] ?? data['u'];
    if (userData != null && userData is! Map<String, dynamic>) {
      errors.add('Некоректний формат профілю: очікується об\'єкт');
    }

    // Перевірка структури цілей
    final goalsData = data['goals'] ?? data['g'];
    if (goalsData != null && goalsData is! List) {
      errors.add('Некоректний формат цілей: очікується масив');
    } else if (goalsData is List && goalsData.length > _maxImportRecords) {
      errors.add(
        'Занадто багато цілей: ${goalsData.length} (максимум $_maxImportRecords)',
      );
    }

    // Перевірка структури транзакцій
    final txData = data['transactions'] ?? data['t'];
    if (txData != null && txData is! List) {
      errors.add('Некоректний формат транзакцій: очікується масив');
    } else if (txData is List && txData.length > _maxImportRecords) {
      errors.add(
        'Занадто багато транзакцій: ${txData.length} (максимум $_maxImportRecords)',
      );
    }

    // Перевірка структури челенджів
    final chData = data['challenges'] ?? data['c'];
    if (chData != null && chData is! List) {
      errors.add('Некоректний формат челенджів: очікується масив');
    }

    // Перевірка структури автоплатежів
    final apData = data['autoPayments'] ?? data['a'];
    if (apData != null && apData is! List) {
      errors.add('Некоректний формат автоплатежів: очікується масив');
    }

    return ValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
    );
  }

  /// Швидка перевірка формату JSON (чи це бекап Nexora).
  bool isNexoraBackup(String jsonString) {
    try {
      final data = json.decode(jsonString) as Map<String, dynamic>;
      return data['app'] == 'nexora';
    } catch (_) {
      return false;
    }
  }

  /// Витягує версію формату з JSON. Повертає null якщо не вдалося.
  String? extractVersion(String jsonString) {
    try {
      final data = json.decode(jsonString) as Map<String, dynamic>;
      return (data['version'] ?? data['v']) as String?;
    } catch (_) {
      return null;
    }
  }

  // ─── Статистика ────────────────────────────────────────────────────

  /// Генерує статистику для бекапу.
  Map<String, dynamic> _generateStats() {
    return {
      'goalsCount': _goalRepo.count,
      'activeGoals': _goalRepo.activeCount,
      'completedGoals': _goalRepo.completedCount,
      'transactionsCount': _transactionRepo.count,
      'totalSaved': _transactionRepo.totalAmount,
      'challengesCount': _challengeRepo.count,
      'completedChallenges': _challengeRepo.completedCount,
      'autoPaymentsCount': _autoPaymentRepo.count,
      'activeAutoPayments': _autoPaymentRepo.getActive().length,
      'userLevel': _userRepo.getUser().currentLevel,
      'userXp': _userRepo.getUser().xp,
      'userCoins': _userRepo.getUser().coins,
      'badgesCount': _userRepo.getBadges().length,
    };
  }

  /// Повертає поточну статистику всіх даних.
  Map<String, dynamic> getCurrentStats() {
    return _generateStats();
  }

  /// Повертає статистику у вигляді форматованого тексту.
  String getFormattedStats() {
    final stats = getCurrentStats();
    return '🎯 Цілей: ${stats['goalsCount']} (активних: ${stats['activeGoals']}) · '
        '💰 Транзакцій: ${stats['transactionsCount']} · '
        '🏆 Челенджів: ${stats['challengesCount']} · '
        '💳 Автоплатежів: ${stats['autoPaymentsCount']}';
  }

  // ─── Приватні методи ───────────────────────────────────────────────

  /// Генерує CSV для транзакцій.
  String _exportTransactionsCsv() {
    final buffer = StringBuffer();
    buffer.writeln(
      'ID,Ціль ID,Тип,Сума,Дата,Коментар,XP,Монети',
    );

    final transactions = _transactionRepo.getAll();
    for (final t in transactions) {
      final date = t.createdAt.toIso8601String();
      final comment = t.comment?.replaceAll('"', '""') ?? '';
      final line = [
        t.id,
        t.goalId,
        t.type.name,
        t.amount.toStringAsFixed(2),
        date,
        comment,
        t.xpEarned,
        t.coinsEarned,
      ].join(',');
      buffer.writeln(line);
    }

    return buffer.toString();
  }
}

/// Тип бекапу.
enum BackupType {
  /// Повний бекап (форматований JSON).
  full,

  /// Компактний бекап (JSON без відступів).
  fullCompact,

  /// Імпорт з JSON.
  import,

  /// Імпорт з CSV.
  csvImport,

  /// Хмарний бекап.
  cloud,
}

/// Інформація про бекап.
class BackupInfo {
  final DateTime timestamp;
  final BackupType type;
  final Map<String, dynamic> stats;

  BackupInfo({
    required this.timestamp,
    required this.type,
    required this.stats,
  });

  /// Назва типу бекапу українською.
  String get typeName {
    switch (type) {
      case BackupType.full:
        return 'Повний бекап';
      case BackupType.fullCompact:
        return 'Компактний бекап';
      case BackupType.import:
        return 'Імпорт';
      case BackupType.csvImport:
        return 'CSV імпорт';
      case BackupType.cloud:
        return 'Хмарний бекап';
    }
  }

  /// Емодзі для типу бекапу.
  String get typeEmoji {
    switch (type) {
      case BackupType.full:
        return '💾';
      case BackupType.fullCompact:
        return '📦';
      case BackupType.import:
        return '📥';
      case BackupType.csvImport:
        return '📊';
      case BackupType.cloud:
        return '☁️';
    }
  }

  /// Форматована дата бекапу.
  String get formattedDate {
    return '${timestamp.day.toString().padLeft(2, '0')}.'
        '${timestamp.month.toString().padLeft(2, '0')}.'
        '${timestamp.year} '
        '${timestamp.hour.toString().padLeft(2, '0')}:'
        '${timestamp.minute.toString().padLeft(2, '0')}';
  }

  /// Форматована дата з секунлами.
  String get formattedDateTime {
    return '${formattedDate}:'
        '${timestamp.second.toString().padLeft(2, '0')}';
  }

  /// Коротке зведення бекапу.
  String get summary {
    final goals = stats['goalsCount'] ?? 0;
    final transactions = stats['transactionsCount'] ?? 0;
    return '$typeEmoji $typeName · $goals цілей · $transactions транзакцій';
  }

  factory BackupInfo.fromJson(Map<String, dynamic> json) {
    return BackupInfo(
      timestamp: DateTime.parse(json['timestamp'] as String),
      type: BackupType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => BackupType.full,
      ),
      stats: (json['stats'] as Map<String, dynamic>?) ?? {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'timestamp': timestamp.toIso8601String(),
      'type': type.name,
      'stats': stats,
    };
  }
}

/// Результат валідації даних для імпорту.
class ValidationResult {
  final bool isValid;
  final List<String> errors;

  ValidationResult({required this.isValid, this.errors = const []});

  /// Формоване повідомлення про помилки.
  String get errorMessage {
    if (isValid) return '✅ Дані валідні';
    return '❌ Помилки: ${errors.join("; ")}';
  }
}

/// Результат імпорту даних.
class ImportResult {
  final bool success;
  final int importedGoals;
  final int importedTransactions;
  final int importedChallenges;
  final int importedAutoPayments;
  final int importedUser;
  final List<String> errors;

  ImportResult({
    required this.success,
    this.importedGoals = 0,
    this.importedTransactions = 0,
    this.importedChallenges = 0,
    this.importedAutoPayments = 0,
    this.importedUser = 0,
    this.errors = const [],
  });

  /// Загальна кількість імпортованих записів.
  int get totalImported =>
      importedGoals +
      importedTransactions +
      importedChallenges +
      importedAutoPayments +
      importedUser;

  /// Повідомлення про результат українською.
  String get message {
    if (!success) {
      return '❌ Помилка імпорту: ${errors.join("; ")}';
    }
    return '✅ Успішно імпортовано: '
        '$importedGoals цілей, '
        '$importedTransactions транзакцій, '
        '$importedChallenges челенджів, '
        '$importedAutoPayments автоплатежів';
  }

  /// Розширений звіт імпорту.
  String get detailedMessage {
    if (!success) {
      return '❌ Помилка імпорту:\n${errors.map((e) => '  • $e').join("\n")}';
    }
    final parts = <String>[
      '✅ Імпорт завершено успішно!',
      '  📊 Загалом записів: $totalImported',
    ];
    if (importedUser > 0) parts.add('  👤 Профіль: оновлено');
    if (importedGoals > 0) parts.add('  🎯 Цілей: $importedGoals');
    if (importedTransactions > 0) {
      parts.add('  💰 Транзакцій: $importedTransactions');
    }
    if (importedChallenges > 0) {
      parts.add('  🏆 Челенджів: $importedChallenges');
    }
    if (importedAutoPayments > 0) {
      parts.add('  💳 Автоплатежів: $importedAutoPayments');
    }
    return parts.join('\n');
  }
}
