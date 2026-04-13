import 'dart:async';
import 'dart:math' as math;

/// Extensions on [num] for Ukrainian currency formatting, statistics,
/// mathematical utilities, gamification formatting, and morphological helpers.
///
/// Містить:
/// - Гривня (formatUAH, formatCurrency, formatCurrencyShort)
/// - Інші валюти (formatUSD, formatEUR, formatGBP, formatPLN, formatWithSymbol)
/// - Відсотки (formatPercent, formatPercentSpaced, formatPercentWithEmoji)
/// - Тривалість (formatMinutes, formatSeconds, formatMs, formatDuration)
/// - Стан числа (isPositive, isNegative, isZero, isBetween)
/// - Римські числа (toRoman)
/// - Порядкові числівники (toOrdinalUAH, toOrdinalFeminine, toOrdinalEN)
/// - Байти (formatBytes, formatBytesUA)
/// - Дроби (formatFraction, formatRatio, simplifyFraction)
/// - Статистичне форматування (formatAverage, formatTrend, formatChange)
/// - Математичні утиліти (mapToRange, lerpTo, factorial, isPowerOfTwo)
/// - Анімація (animateCount, animateIntCount)
/// - Українська морфологія (pluralUAH, toWordsUAH)
/// - Гейміфікація (formatXP, formatCoins, formatStreak, formatLevel)
/// - Валідація (isValidPort, isValidPercentage, isPrime, isFibonacci)
/// - Наукове форматування (formatScientific, formatEngineering)
/// - Температура (formatCelsius, formatFahrenheit, celsiusToFahrenheit)
/// - Відстань та вага (formatKm, formatAutoDistance, formatKg, formatAutoWeight)
/// - Швидкість (formatKmh, kmhToMs)
/// - Системи числення (toHex, toBinary, toOctal, fromHex, fromBinary)
/// - Фінансові утиліти (withTax, withDiscount, formatInstallment)
/// - Тригонометрія та логарифми (sin, cos, tan, ln, log10, toRadians)
/// - Англомовні числівники (toWordsEN, toOrdinalEN)
/// - Текстове представлення (progressBar, barChart, padZero)
/// - Телефонні та спеціальні формати (formatPhoneUA, formatCardNumber)
library;

/// Форматування чисел у стилі української гривні та інших валютах.
///
/// Приклади:
/// ```dart
/// 12450.formatUAH()        → "12 450"
/// 12450.formatCurrency()   → "12 450,00 грн"
/// 0.65.formatPercent()     → "65%"
/// 42.toWordsUAH()          → "сорок два"
/// ```
extension NumberFormatUAH on num {
  // ─── Гривня ───────────────────────────────────────────────────────

  /// Форматує число з пробілом як роздільником тисяч.
  ///
  /// Приклад: `12450.formatUAH()` → `"12 450"`
  ///
  /// Повертає від'ємні числа з мінусом.
  String formatUAH() {
    final intPart = toInt().abs();
    final buffer = StringBuffer();
    final digits = intPart.toString();

    int count = 0;
    for (int i = digits.length - 1; i >= 0; i--) {
      if (count > 0 && count % 3 == 0) {
        buffer.write(' ');
      }
      buffer.write(digits[i]);
      count++;
    }

    final reversed = buffer.toString().split('').reversed.join();
    return this < 0 ? '-$reversed' : reversed;
  }

  /// Форматує число з копійками та знаком гривні.
  ///
  /// Приклад: `12450.5.formatCurrency()` → `"12 450,50 грн"`
  ///
  /// [decimals] — кількість знаків після коми (за замовчуванням 2).
  String formatCurrency({int decimals = 2}) {
    final isNeg = this < 0;
    final absVal = abs();
    final intPart = absVal.toInt();
    final decPart = ((absVal - intPart) * math.pow(10, decimals)).round();

    final formatted = intPart.formatUAH();
    final decStr = decPart.toString().padLeft(decimals, '0');
    final sign = isNeg ? '-' : '';
    return '$sign$formatted,$decStr грн';
  }

  /// Форматує число з коротким символом гривні.
  ///
  /// Приклад: `12450.formatCurrencyShort()` → `"12 450 ₴"`
  ///
  /// [decimals] — кількість знаків після коми (за замовчуванням 0).
  String formatCurrencyShort({int decimals = 0}) {
    final formatted = decimals == 0
        ? formatUAH()
        : formatWithDecimals(decimals: decimals);
    return '$formatted ₴';
  }

  /// Форматує число з копійками (без символу валюти).
  ///
  /// Приклад: `12450.5.formatWithDecimals()` → `"12 450,50"`
  ///
  /// [decimals] — кількість знаків після коми (за замовчуванням 2).
  String formatWithDecimals({int decimals = 2}) {
    final isNeg = this < 0;
    final absVal = abs();
    final intPart = absVal.toInt();
    final decPart = ((absVal - intPart) * math.pow(10, decimals)).round();

    final formatted = intPart.formatUAH();
    final decStr = decPart.toString().padLeft(decimals, '0');
    final sign = isNeg ? '-' : '';
    return '$sign$formatted,$decStr';
  }

  /// Компактне форматування числа з суфіксом.
  ///
  /// Приклад: `12450.compactUAH()` → `"12.4K"`
  ///
  /// Використовує суфікси: K (тисячі), M (мільйони), B (мільярди).
  String compactUAH() {
    final abs = this.abs();
    if (abs >= 1000000000) {
      return '${(abs / 1000000000).toStringAsFixed(1).replaceAll(RegExp(r'\.0$'), '')}B';
    } else if (abs >= 1000000) {
      return '${(abs / 1000000).toStringAsFixed(1).replaceAll(RegExp(r'\.0$'), '')}M';
    } else if (abs >= 1000) {
      return '${(abs / 1000).toStringAsFixed(1).replaceAll(RegExp(r'\.0$'), '')}K';
    }
    return formatUAH();
  }

  /// Компактне форматування з українськими суфіксами.
  ///
  /// Приклад: `1500.compactUAHVerbose()` → `"1.5 тис."`
  ///
  /// Використовує українські суфікси: тис., млн, млрд.
  String compactUAHVerbose() {
    final abs = this.abs();
    if (abs >= 1000000000) {
      return '${(abs / 1000000000).toStringAsFixed(1).replaceAll(RegExp(r'\.0$'), '')} млрд';
    } else if (abs >= 1000000) {
      return '${(abs / 1000000).toStringAsFixed(1).replaceAll(RegExp(r'\.0$'), '')} млн';
    } else if (abs >= 1000) {
      return '${(abs / 1000).toStringAsFixed(1).replaceAll(RegExp(r'\.0$'), '')} тис.';
    }
    return formatUAH();
  }

  // ─── Інші валюти ──────────────────────────────────────────────────

  /// Форматує число з символом долара.
  ///
  /// Приклад: `12450.formatUSD()` → `"12 450 $"`
  ///
  /// [decimals] — кількість знаків після коми.
  String formatUSD({int decimals = 2}) {
    if (decimals == 0) return '${formatUAH()} \$';
    return '${formatWithDecimals(decimals: decimals)} \$';
  }

  /// Форматує число з символом євро.
  ///
  /// Приклад: `12450.formatEUR()` → `"12 450 €"`
  ///
  /// [decimals] — кількість знаків після коми.
  String formatEUR({int decimals = 2}) {
    if (decimals == 0) return '${formatUAH()} €';
    return '${formatWithDecimals(decimals: decimals)} €';
  }

  /// Форматує число з символом фунта стерлінгів.
  ///
  /// Приклад: `12450.formatGBP()` → `"12 450 £"`
  ///
  /// [decimals] — кількість знаків після коми.
  String formatGBP({int decimals = 2}) {
    if (decimals == 0) return '${formatUAH()} £';
    return '${formatWithDecimals(decimals: decimals)} £';
  }

  /// Форматує число з символом злотого (PLN).
  ///
  /// Приклад: `12450.formatPLN()` → `"12 450 zł"`
  String formatPLN({int decimals = 2}) {
    if (decimals == 0) return '${formatUAH()} zł';
    return '${formatWithDecimals(decimals: decimals)} zł';
  }

  /// Форматує число з довільним символом валюти.
  ///
  /// Приклад: `12450.formatWithSymbol('₴')` → `"12 450 ₴"`
  ///
  /// [symbol] — символ валюти.
  /// [decimals] — кількість знаків після коми.
  String formatWithSymbol(String symbol, {int decimals = 0}) {
    if (decimals == 0) return '$formatUAH() $symbol';
    return '${formatWithDecimals(decimals: decimals)} $symbol';
  }

  // ─── Відсотки ─────────────────────────────────────────────────────

  /// Форматує число як відсоток.
  ///
  /// Приклад: `65.3.formatPercent()` → `"65.3%"`
  ///
  /// [decimals] — кількість знаків після коми.
  String formatPercent({int decimals = 1}) {
    return '${toStringAsFixed(decimals).replaceAll(RegExp(r'\.?0+$'), '')}%';
  }

  /// Форматує число як відсоток із пробілом між цифрами.
  ///
  /// Приклад: `65300.formatPercentSpaced()` → `"65 300%"`
  String formatPercentSpaced({int decimals = 1}) {
    return '${formatUAH().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]} ',
    )}%';
  }

  /// Форматує число як відсоток з колірним індикатором emoji.
  ///
  /// Приклад: `65.formatPercentWithEmoji(50)` → `"65% 📈"`
  ///
  /// [baseline] — базове значення для порівняння.
  String formatPercentWithEmoji(num baseline) {
    final percent = formatPercent();
    if (this > baseline) return '$percent 📈';
    if (this < baseline) return '$percent 📉';
    return '$percent ➡️';
  }

  /// Форматує число як відсоток з максимально точним знаком.
  ///
  /// Приклад: `0.0567.formatPrecisePercent()` → `"5.67%"`
  ///
  /// [decimals] — кількість знаків після коми.
  String formatPrecisePercent({int decimals = 2}) {
    final multiplied = toDouble() * 100;
    return '${multiplied.toStringAsFixed(decimals)}%';
  }

  /// Форматує число як відсоток з українським суфіксом.
  ///
  /// Приклад: `65.formatPercentUAH()` → `"65 відсотків"`
  String formatPercentUAH() {
    final value = toDouble().abs();
    final n = value.round();
    return '$n ${_percentWord(n)}';
  }

  /// Повертає правильну форму слова «відсотків».
  static String _percentWord(int n) {
    final lastTwo = n % 100;
    final lastOne = n % 10;
    if (lastTwo >= 11 && lastTwo <= 14) return 'відсотків';
    if (lastOne == 1) return 'відсоток';
    if (lastOne >= 2 && lastOne <= 4) return 'відсотки';
    return 'відсотків';
  }

  // ─── Тривалість ───────────────────────────────────────────────────

  /// Форматує кількість хвилин як тривалість.
  ///
  /// Приклад: `135.formatMinutes()` → `"2 год 15 хв"`
  String formatMinutes() {
    final totalMin = toInt().abs();
    final hours = totalMin ~/ 60;
    final minutes = totalMin % 60;

    if (hours == 0) return '$minutes хв';
    if (minutes == 0) return '$hours год';
    return '$hours год $minutes хв';
  }

  /// Форматує секунди як тривалість.
  ///
  /// Приклад: `135.formatSeconds()` → `"2 хв 15 с"`
  String formatSeconds() {
    final totalSec = toInt().abs();
    final hours = totalSec ~/ 3600;
    final minutes = (totalSec % 3600) ~/ 60;
    final seconds = totalSec % 60;

    final parts = <String>[];
    if (hours > 0) parts.add('$hours год');
    if (minutes > 0) parts.add('$minutes хв');
    if (seconds > 0 || parts.isEmpty) parts.add('$seconds с');
    return parts.join(' ');
  }

  /// Форматує мілісекунди як зручну тривалість.
  ///
  /// Приклад: `1250.formatMs()` → `"1.3 с"`
  String formatMs() {
    final ms = toInt().abs();
    if (ms < 1000) return '$ms мс';
    return '${(ms / 1000).toStringAsFixed(1)} с';
  }

  /// Форматує мілісекунди як тривалість з точністю до хвилин.
  ///
  /// Приклад: `90125.formatMsDetailed()` → `"1 хв 30 с"`
  String formatMsDetailed() {
    final ms = toInt().abs();
    final totalSec = ms ~/ 1000;
    final minutes = totalSec ~/ 60;
    final seconds = totalSec % 60;

    if (minutes == 0) return '$seconds с';
    return '$minutes хв $seconds с';
  }

  /// Форматує кількість днів як тривалість.
  ///
  /// Приклад: `102.formatDuration()` → `"3 міс 12 дн"`
  String formatDuration() {
    final totalDays = toInt().abs();
    final months = totalDays ~/ 30;
    final days = totalDays % 30;

    if (months == 0) return '$days дн';
    if (days == 0) return '$months міс';
    return '$months міс $days дн';
  }

  /// Форматує дні як зворотний відлік.
  ///
  /// Приклад: `102.formatCountdown()` → `"102д"`
  String formatCountdown() {
    final totalDays = toInt().abs();
    return '${totalDays}д';
  }

  /// Форматує дні як розгорнутий зворотний відлік.
  ///
  /// Приклад: `45.formatCountdownVerbose()` → `"45 днів"`
  String formatCountdownVerbose() {
    final n = toInt().abs();
    return '$n ${_dayWord(n)}';
  }

  /// Форматує години як тривалість.
  ///
  /// Приклад: `48.formatHours()` → `"2 доби"`
  String formatHours() {
    final totalHours = toInt().abs();
    final days = totalHours ~/ 24;
    final hours = totalHours % 24;

    if (days == 0) return '$hours год';
    if (hours == 0) return '$days ${_dayWord(days)}';
    return '$days ${_dayWord(days)} $hours год';
  }

  /// Повертає правильне слово для кількості днів.
  static String _dayWord(int n) {
    final lastTwo = n % 100;
    final lastOne = n % 10;
    if (lastTwo >= 11 && lastTwo <= 14) return 'днів';
    if (lastOne == 1) return 'день';
    if (lastOne >= 2 && lastOne <= 4) return 'дні';
    return 'днів';
  }

  // ─── Стан числа ───────────────────────────────────────────────────

  /// Чи є число додатним (більше нуля).
  bool get isPositive => this > 0;

  /// Чи є число від'ємним (менше нуля).
  bool get isNegative => this < 0;

  /// Чи дорівнює число нулю.
  bool get isZero => this == 0;

  /// Чи є число ненульовим.
  bool get isNonZero => this != 0;

  /// Чи є число в межах діапазону [min]…[max] (включно).
  bool isBetween(num min, num max) => this >= min && this <= max;

  /// Чи є число строго всередині діапазону (не включаючи межі).
  bool isStrictlyBetween(num min, num max) => this > min && this < max;

  /// Обмежує число в діапазоні [min]…[max].
  ///
  /// Повертає [min], якщо число менше; [max], якщо більше.
  num clampRange(num min, num max) {
    return clamp(min, max);
  }

  /// Повертає абсолютну величину.
  num absValue => abs();

  /// Повертає число з обмеженням мінімуму.
  ///
  /// Приклад: `5.minValue(10)` → `10`
  num minValue(num min) => this < min ? min : this;

  /// Повертає число з обмеженням максимуму.
  ///
  /// Приклад: `5.maxValue(3)` → `3`
  num maxValue(num max) => this > max ? max : this;

  /// Повертає 0, якщо число від'ємне або нуль.
  num get nonNegative => this < 0 ? 0 : this;

  /// Повертає 1, якщо число > 0, інакше 0.
  int get toFlag => this > 0 ? 1 : 0;

  // ─── Валідація ─────────────────────────────────────────────────────

  /// Чи є число валідним портом (1–65535).
  bool get isValidPort => toInt() >= 1 && toInt() <= 65535;

  /// Чи є число валідним відсотком (0.0–100.0).
  bool get isValidPercentage => toDouble() >= 0.0 && toDouble() <= 100.0;

  /// Чи є число валідним HTTP статус-кодом (100–599).
  bool get isValidHttpStatus => toInt() >= 100 && toInt() <= 599;

  /// Чи є число парним.
  bool get isEven => toInt() % 2 == 0;

  /// Чи є число непарним.
  bool get isOdd => toInt() % 2 != 0;

  /// Чи є число простим.
  ///
  /// Повертає `true` для 2, 3, 5, 7, 11, 13...
  bool get isPrime {
    if (toInt() < 2) return false;
    if (toInt() == 2) return true;
    if (toInt() % 2 == 0) return false;
    final n = toInt();
    for (int i = 3; i * i <= n; i += 2) {
      if (n % i == 0) return false;
    }
    return true;
  }

  /// Чи є число ідеальним квадратом.
  ///
  /// Повертає `true` для 0, 1, 4, 9, 16, 25...
  bool get isPerfectSquare {
    final n = toInt();
    if (n < 0) return false;
    final root = math.sqrt(n).round();
    return root * root == n;
  }

  /// Повертає квадратний корінь числа.
  ///
  /// Повертає 0 для від'ємних чисел.
  num get squareRoot => this < 0 ? 0 : math.sqrt(toDouble());

  /// Повертає куб числа.
  num get cubed => toDouble() * toDouble() * toDouble();

  // ─── Римські числа ────────────────────────────────────────────────

  /// Перетворює число на римський запис.
  ///
  /// Підтримує числа від 1 до 3999.
  ///
  /// Приклад: `42.toRoman()` → `"XLII"`, `2024.toRoman()` → `"MMXXIV"`
  String toRoman() {
    final n = toInt().clamp(1, 3999);
    const values = [1000, 900, 500, 400, 100, 90, 50, 40, 10, 9, 5, 4, 1];
    const numerals = [
      'M', 'CM', 'D', 'CD', 'C', 'XC', 'L', 'XL', 'X', 'IX', 'V', 'IV', 'I',
    ];

    final buffer = StringBuffer();
    var remaining = n;
    for (var i = 0; i < values.length; i++) {
      while (remaining >= values[i]) {
        buffer.write(numerals[i]);
        remaining -= values[i];
      }
    }
    return buffer.toString();
  }

  // ─── Порядкові числівники ─────────────────────────────────────────

  /// Повертає український порядковий числівник.
  ///
  /// Приклад: `1.toOrdinalUAH()` → `"1-й"`, `2.toOrdinalUAH()` → `"2-й"`
  String toOrdinalUAH() {
    final n = toInt().abs();
    return '$n-й';
  }

  /// Повертає розгорнутий український порядковий числівник.
  ///
  /// Приклад: `1.toOrdinalUAHVerbose()` → `"перший"`
  /// Приклад: `2.toOrdinalUAHVerbose()` → `"другий"`
  String toOrdinalUAHVerbose() {
    final n = toInt().abs();
    if (n == 1) return 'перший';
    if (n == 2) return 'другий';
    if (n == 3) return 'третій';
    if (n == 4) return 'четвертий';
    if (n == 5) return 'п\'ятий';
    if (n == 6) return 'шостий';
    if (n == 7) return 'сьомий';
    if (n == 8) return 'восьмий';
    if (n == 9) return 'дев\'ятий';
    if (n == 10) return 'десятий';
    if (n == 11) return 'одинадцятий';
    if (n == 12) return 'дванадцятий';
    if (n >= 2 && n <= 4) return '$n-й';
    return '$n-й';
  }

  /// Повертає жіночий порядковий числівник.
  ///
  /// Приклад: `1.toOrdinalFeminine()` → `"перша"`, `2.toOrdinalFeminine()` → `"друга"`
  String toOrdinalFeminine() {
    final n = toInt().abs();
    if (n == 1) return 'перша';
    if (n == 2) return 'друга';
    if (n == 3) return 'третя';
    return '$n-а';
  }

  // ─── Байти ────────────────────────────────────────────────────────

  /// Форматує число як розмір у байтах.
  ///
  /// Приклад: `1536.formatBytes()` → `"1.5 KB"`
  String formatBytes() {
    final bytes = toDouble().abs();
    if (bytes < 1024) return '${bytes.toStringAsFixed(0)} B';
    if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    }
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  /// Форматує число як розмір у байтах з українськими одиницями.
  ///
  /// Приклад: `1536.formatBytesUA()` → `"1,5 КБ"`
  String formatBytesUA() {
    final bytes = toDouble().abs();
    if (bytes < 1024) return '${bytes.toStringAsFixed(0)} Б';
    if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1).replaceAll('.', ',')} КБ';
    }
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1).replaceAll('.', ',')} МБ';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1).replaceAll('.', ',')} ГБ';
  }

  // ─── Дроби ────────────────────────────────────────────────────────

  /// Форматує число як дріб (наприклад 1/4, 3/5).
  ///
  /// [denominator] — знаменник.
  String formatFraction(int denominator) {
    final n = toInt().abs();
    return '$n/$denominator';
  }

  /// Форматує число як відношення (наприклад 3:2).
  ///
  /// [other] — друге число.
  String formatRatio(num other) {
    return '$toInt():${other.toInt()}';
  }

  /// Спрощує дріб (наприклад, 4/8 → 1/2).
  ///
  /// [denominator] — початковий знаменник.
  String simplifyFraction(int denominator) {
    final n = toInt().abs();
    if (denominator == 0) return '∞';
    final gcdVal = _gcd(n, denominator);
    return '${n ~/ gcdVal}/${denominator ~/ gcdVal}';
  }

  /// Найбільший спільний дільник.
  static int _gcd(int a, int b) {
    while (b != 0) {
      final t = b;
      b = a % b;
      a = t;
    }
    return a;
  }

  /// Найменше спільне кратне.
  static int lcm(int a, int b) {
    if (a == 0 || b == 0) return 0;
    return (a * b).abs() ~/ _gcd(a, b);
  }

  // ─── Статистичне форматування ──────────────────────────────────────

  /// Форматує число як середнє значення.
  ///
  /// Приклад: `2450.formatAverage()` → `"~2 450"`
  String formatAverage() => '~${formatUAH()}';

  /// Форматує число як тренд (зі стрілкою).
  ///
  /// [previous] — попереднє значення.
  /// Приклад: `150.formatTrend(100)` → `"150 ↑"`
  String formatTrend(num previous) {
    if (previous == 0) return formatUAH();
    final diff = this - previous;
    if (diff > 0) return '${formatUAH()} ↑';
    if (diff < 0) return '${formatUAH()} ↓';
    return '${formatUAH()} →';
  }

  /// Форматує число як зміну відносно [baseline].
  ///
  /// Приклад: `150.formatChange(100)` → `"+50"`
  String formatChange(num baseline) {
    final diff = this - baseline;
    if (diff == 0) return '0';
    if (diff > 0) return '+${diff.toInt().formatUAH()}';
    return diff.toInt().formatUAH();
  }

  /// Форматує число як відсоток зміни відносно [baseline].
  ///
  /// Приклад: `150.formatChangePercent(100)` → `"+50%"`
  String formatChangePercent(num baseline) {
    if (baseline == 0) return '∞';
    final percent = ((this - baseline) / baseline * 100);
    if (percent == 0) return '0%';
    if (percent > 0) return '+${percent.toStringAsFixed(1)}%';
    return '${percent.toStringAsFixed(1)}%';
  }

  /// Форматує число як стандартне відхилення.
  ///
  /// Приклад: `15.formatStdDev(100)` → `"15.0σ"`
  String formatStdDev(num mean) {
    return '${toStringAsFixed(1)}σ';
  }

  /// Форматує число як медіанне значення.
  ///
  /// Приклад: `2450.formatMedian()` → `"Мд: 2 450"`
  String formatMedian() => 'Мд: ${formatUAH()}';

  /// Форматує число як моду (найчастіше значення).
  ///
  /// Приклад: `1500.formatMode()` → `"Мо: 1 500"`
  String formatMode() => 'Мо: ${formatUAH()}';

  /// Форматує число з позначкою довіркового інтервалу.
  ///
  /// Приклад: `100.formatConfidence(10)` → `"100 ±10"`
  String formatConfidence(num margin) {
    return '${formatUAH()} ±${margin.toInt().formatUAH()}';
  }

  // ─── Математичні утиліти ──────────────────────────────────────────

  /// Мапує число з одного діапазону в інший.
  ///
  /// Приклад: `5.mapToRange(0, 10, 0, 100)` → `50`
  ///
  /// [fromMin], [fromMax] — вихідний діапазон.
  /// [toMin], [toMax] — цільовий діапазон.
  double mapToRange(
    double fromMin,
    double fromMax,
    double toMin,
    double toMax,
  ) {
    final clamped = clamp(fromMin, fromMax).toDouble();
    final ratio = (clamped - fromMin) / (fromMax - fromMin);
    return toMin + ratio * (toMax - toMin);
  }

  /// Лінійна інтерполяція до [target] з коефіцієнтом [t].
  ///
  /// [target] — цільове значення.
  /// [t] — коефіцієнт інтерполяції (0.0 = це число, 1.0 = цільове).
  double lerpTo(num target, double t) {
    return toDouble() + (target.toDouble() - toDouble()) * t.clamp(0.0, 1.0);
  }

  /// Обмежує число в діапазоні та повертає double.
  double clampDouble(double min, double max) {
    return toDouble().clamp(min, max);
  }

  /// Обмежує число в діапазоні та повертає int.
  int clampInt(int min, int max) {
    return toInt().clamp(min, max);
  }

  /// Повертає число з вказаною точністю (кількістю знаків).
  ///
  /// Приклад: `123.456.fixed(1)` → `"123.5"`
  String fixed(int decimals) {
    return toDouble().toStringAsFixed(decimals);
  }

  // ─── Наукове форматування ─────────────────────────────────────────

  /// Форматує число в науковому записі.
  ///
  /// Приклад: `1500.formatScientific()` → `"1.50e+3"`
  String formatScientific({int decimals = 2}) {
    return toDouble().toStringAsExponential(decimals);
  }

  /// Форматує число з інженерним позначенням (кратне 3).
  ///
  /// Приклад: `1500.formatEngineering()` → `"1.5E3"`
  String formatEngineering({int decimals = 1}) {
    final value = toDouble().abs();
    if (value == 0) return '0';

    final exp = (math.log(value) / math.log(10)).floor();
    final engExp = (exp ~/ 3) * 3;
    final mantissa = value / math.pow(10, engExp);

    final expStr = engExp == 0 ? '' : 'E$engExp';
    return '${mantissa.toStringAsFixed(decimals)}$expStr';
  }

  // ─── Анімація ─────────────────────────────────────────────────────

  /// Створює потік значень для анімації підрахунку.
  ///
  /// Генерує [duration] значень від 0 до цього числа з ease-out кубічною кривою.
  ///
  /// Приклад використання:
  /// ```dart
  /// number.animateCount(Duration(seconds: 1)).listen((value) {
  ///   setState(() => displayValue = value.round());
  /// });
  /// ```
  Stream<double> animateCount(Duration duration) {
    const stepsPerSecond = 60;
    final totalSteps = (duration.inMilliseconds * stepsPerSecond / 1000).ceil();
    final target = toDouble();

    return Stream<double>.periodic(
      Duration(milliseconds: 1000 ~/ stepsPerSecond),
      (count) {
        final progress = (count + 1) / totalSteps;
        final easedProgress = 1 - math.pow(1 - progress, 3);
        return target * easedProgress;
      },
    ).take(totalSteps);
  }

  /// Створює потік цілих чисел для анімації підрахунку.
  ///
  /// Генерує rounded значення з плавною анімацією.
  Stream<int> animateIntCount(Duration duration) {
    return animateCount(duration).map((v) => v.round());
  }

  // ─── Українська морфологія ────────────────────────────────────────

  /// Вибирає правильну форму слова залежно від числа.
  ///
  /// Правила української мови:
  /// - [one] — для 1 (і чисел, що закінчуються на 1, крім 11).
  /// - [few] — для 2–4 (і чисел, що закінчуються на 2–4, крім 12–14).
  /// - [many] — для 0, 5–9, 10–19, 20–29 тощо.
  ///
  /// Приклад: `5.pluralUAH('внесок', 'внески', 'внесків')` → `"5 внесків"`
  String pluralUAH(String one, String few, String many) {
    final n = toInt().abs();
    final lastTwo = n % 100;
    final lastOne = n % 10;

    if (lastTwo >= 11 && lastTwo <= 14) {
      return '$n $many';
    }
    if (lastOne == 1) {
      return '$n $one';
    }
    if (lastOne >= 2 && lastOne <= 4) {
      return '$n $few';
    }
    return '$n $many';
  }

  /// Перетворює число на український текст (до 999).
  ///
  /// Приклад: `42.toWordsUAH()` → `"сорок два"`
  /// Приклад: `0.toWordsUAH()` → `"нуль"`
  String toWordsUAH() {
    if (toInt() == 0) return 'нуль';
    if (toInt() < 0) return 'мінус ${(-this).toWordsUAH()}';
    if (toInt() >= 1000) return formatUAH();

    return _numberToWords(toInt());
  }

  /// Перетворює число на гривневий запис.
  ///
  /// Приклад: `12450.toCurrencyWordsUAH()` → `"дванадцять тисяч чотириста п'ятдесят грн"`
  String toCurrencyWordsUAH() {
    if (toDouble().abs() < 1000) {
      return '${toWordsUAH()} грн';
    }
    return '${compactUAHVerbose()} грн';
  }

  /// Форматує число з відстанню та українським суфіксом.
  ///
  /// Приклад: `1200.formatDistance()` → `"1.2 тис."`
  String formatDistance() {
    final abs = this.abs();
    if (abs >= 1000000) {
      final value = abs / 1000000;
      final formatted = value == value.toInt()
          ? value.toInt().toString()
          : value.toStringAsFixed(1).replaceAll(RegExp(r'\.0$'), '');
      return '$formatted млн';
    } else if (abs >= 1000) {
      final value = abs / 1000;
      final formatted = value == value.toInt()
          ? value.toInt().toString()
          : value.toStringAsFixed(1).replaceAll(RegExp(r'\.0$'), '');
      return '$formatted тис.';
    }
    return formatUAH();
  }

  // ─── Гейміфікація ─────────────────────────────────────────────────

  /// Форматує XP з іконкою зірочки.
  ///
  /// Приклад: `1250.formatXP()` → `"1 250 ⭐"`
  String formatXP() {
    return '${formatUAH()} ⭐';
  }

  /// Форматує XP з іконкою зірочки та compact форматом.
  ///
  /// Приклад: `1250.formatXPCompact()` → `"1.2K ⭐"`
  String formatXPCompact() {
    return '${compactUAH()} ⭐';
  }

  /// Форматує кількість монеток.
  ///
  /// Приклад: `350.formatCoins()` → `"350 🪙"`
  String formatCoins() {
    return '${formatUAH()} 🪙';
  }

  /// Форматує монети з compact форматом.
  ///
  /// Приклад: `1500.formatCoinsCompact()` → `"1.5K 🪙"`
  String formatCoinsCompact() {
    return '${compactUAH()} 🪙';
  }

  /// Повертає число з плюсом для позитивних значень.
  ///
  /// Приклад: `500.formatSigned()` → `"+500"`
  String formatSigned() {
    if (this > 0) return '+${formatUAH()}';
    return formatUAH();
  }

  /// Повертає знак числа: `"+"`, `"−"` або `"0"`.
  String get signSymbol {
    if (this > 0) return '+';
    if (this < 0) return '−';
    return '0';
  }

  /// Абсолютне значення у вигляді відсотка від [total].
  ///
  /// Приклад: `250.percentOf(1000)` → `"25%"`
  String percentOf(num total) {
    if (total == 0) return '0%';
    final percent = (this / total * 100);
    return percent.formatPercent();
  }

  /// Форматує числа для прогрес-бару.
  ///
  /// Приклад: `75.formatProgress()` → `"75%"`
  ///
  /// [max] — максимальне значення (за замовчуванням 100).
  String formatProgress({num max = 100}) {
    if (max == 0) return '0%';
    final percent = (this / max * 100).clamp(0, 100);
    return percent.formatPercent();
  }

  /// Форматує число як позицію в рейтингу.
  ///
  /// Приклад: `42.formatRank()` → `"#42"`
  String formatRank() => '#${formatUAH()}';

  /// Форматує число як множник.
  ///
  /// Приклад: `2.5.formatMultiplier()` → `"x2.5"`
  String formatMultiplier() {
    final val = toDouble();
    if (val == val.toInt()) return 'x${val.toInt()}';
    return 'x$val';
  }

  /// Форматує число як рівень з шаблоном.
  ///
  /// Приклад: `15.formatLevel()` → `"Рівень 15"`
  String formatLevel() => 'Рівень ${toInt()}';

  /// Форматує число як рівень з емодзі.
  ///
  /// Приклад: `15.formatLevelWithEmoji()` → `"🌱 Рівень 15"`
  String formatLevelWithEmoji() {
    final n = toInt().abs();
    String emoji;
    if (n <= 2) emoji = '🌱';
    else if (n <= 4) emoji = '🐷';
    else if (n <= 6) emoji = '🏆';
    else emoji = '⭐';
    return '$emoji Рівень $n';
  }

  /// Форматує число як кількість днів серії.
  ///
  /// Приклад: `7.formatStreak()` → `"7 днів поспіль 🔥"`
  String formatStreak() {
    final n = toInt().abs();
    final daysWord = n.pluralUAH('день', 'дні', 'днів');
    return '$n $daysWord поспіль 🔥';
  }

  /// Форматує число як кількість серій (для гейміфікації).
  ///
  /// Приклад: `3.formatStreaks()` → `"3 серії 🔥"`
  String formatStreaks() {
    final n = toInt().abs();
    return '$n ${n.pluralUAH("серия", "серії", "серій")} 🔥';
  }

  /// Форматує число як кількість бейджів.
  ///
  /// Приклад: `5.formatBadges()` → `"5 🏅"`
  String formatBadges() {
    return '${formatUAH()} 🏅';
  }

  /// Форматує число як кількість виконаних цілей.
  ///
  /// Приклад: `3.formatGoals()` → `"3 ціль ✅"`
  String formatGoals() {
    final n = toInt().abs();
    return '$n ${n.pluralUAH("ціль", "цілі", "цілей")} ✅';
  }

  /// Форматує число як кількість челенджів.
  ///
  /// Приклад: `10.formatChallenges()` → `"10 челенджів 🏆"`
  String formatChallenges() {
    final n = toInt().abs();
    return '$n ${n.pluralUAH("челендж", "челенджі", "челенджів")} 🏆';
  }

  // ─── Температура ───────────────────────────────────────────────────

  /// Форматує число як температуру в Цельсіях.
  ///
  /// Приклад: `25.formatCelsius()` → `"25°C"`, `-5.formatCelsius()` → `"-5°C"`
  String formatCelsius({int decimals = 0}) {
    if (decimals == 0) return '${toInt()}°C';
    return '${toDouble().toStringAsFixed(decimals)}°C';
  }

  /// Форматує число як температуру в Фаренгейтах.
  ///
  /// Приклад: `77.formatFahrenheit()` → `"77°F"`
  String formatFahrenheit({int decimals = 0}) {
    if (decimals == 0) return '${toInt()}°F';
    return '${toDouble().toStringAsFixed(decimals)}°F';
  }

  /// Конвертує з Цельсіїв у Фаренгейти.
  ///
  /// Приклад: `100.celsiusToFahrenheit()` → `"212°F"`
  String celsiusToFahrenheit({int decimals = 0}) {
    final f = toDouble() * 9 / 5 + 32;
    if (decimals == 0) return '${f.round()}°F';
    return '${f.toStringAsFixed(decimals)}°F';
  }

  /// Конвертує з Фаренгейтів у Цельсії.
  ///
  /// Приклад: `212.fahrenheitToCelsius()` → `"100°C"`
  String fahrenheitToCelsius({int decimals = 0}) {
    final c = (toDouble() - 32) * 5 / 9;
    if (decimals == 0) return '${c.round()}°C';
    return '${c.toStringAsFixed(decimals)}°C';
  }

  /// Повертає опис температури українською.
  ///
  /// Приклад: `25.temperatureDescription()` → `"тепло"`
  /// Приклад: `-10.temperatureDescription()` → `"морозно"`
  String temperatureDescription() {
    final t = toDouble();
    if (t < -25) return 'екстремальний мороз';
    if (t < -15) return 'сильний мороз';
    if (t < -5) return 'морозно';
    if (t < 0) return 'холодно, мінус';
    if (t < 5) return 'близько до нуля';
    if (t < 12) return 'прохолодно';
    if (t < 20) return 'комфортно';
    if (t < 28) return 'тепло';
    if (t < 35) return 'спекотно';
    return 'екстремальна спека';
  }

  // ─── Відстань ─────────────────────────────────────────────────────

  /// Форматує число як відстань у кілометрах.
  ///
  /// Приклад: `1250.formatKm()` → `"1 250 км"`
  String formatKm({int decimals = 0}) {
    if (decimals == 0) return '${formatUAH()} км';
    return '${formatWithDecimals(decimals: decimals)} км';
  }

  /// Форматує число як відстань у метрах.
  ///
  /// Приклад: `500.formatM()` → `"500 м"`
  String formatM() => '${formatUAH()} м';

  /// Форматує число як відстань у сантиметрах.
  ///
  /// Приклад: `175.formatCm()` → `"175 см"`
  String formatCm() => '${formatUAH()} см';

  /// Форматує число як відстань у міліметрах.
  ///
  /// Приклад: `50.formatMm()` → `"50 мм"`
  String formatMm() => '${formatUAH()} мм';

  /// Форматує метри в автоматичній одиниці.
  ///
  /// Приклад: `1500.formatAutoDistance()` → `"1.5 км"`
  /// Приклад: `800.formatAutoDistance()` → `"800 м"`
  String formatAutoDistance() {
    final abs = toDouble().abs();
    if (abs >= 1000) {
      final km = abs / 1000;
      final formatted = km.toStringAsFixed(1).replaceAll(RegExp(r'\.0$'), '');
      return '$formatted км';
    }
    return '${toInt()} м';
  }

  // ─── Вага ─────────────────────────────────────────────────────────

  /// Форматує число як вагу у кілограмах.
  ///
  /// Приклад: `75.formatKg()` → `"75 кг"`
  String formatKg({int decimals = 0}) {
    if (decimals == 0) return '${formatUAH()} кг';
    return '${formatWithDecimals(decimals: decimals)} кг';
  }

  /// Форматує число як вагу у грамах.
  ///
  /// Приклад: `500.formatG()` → `"500 г"`
  String formatG() => '${formatUAH()} г';

  /// Форматує грами в автоматичній одиниці.
  ///
  /// Приклад: `1500.formatAutoWeight()` → `"1.5 кг"`
  String formatAutoWeight() {
    final abs = toDouble().abs();
    if (abs >= 1000) {
      final kg = abs / 1000;
      final formatted = kg.toStringAsFixed(1).replaceAll(RegExp(r'\.0$'), '');
      return '$formatted кг';
    }
    return '${toInt()} г';
  }

  // ─── Швидкість ────────────────────────────────────────────────────

  /// Форматує число як швидкість у км/год.
  ///
  /// Приклад: `120.formatKmh()` → `"120 км/год"`
  String formatKmh({int decimals = 0}) {
    if (decimals == 0) return '${formatUAH()} км/год';
    return '${formatWithDecimals(decimals: decimals)} км/год';
  }

  /// Форматує число як швидкість у м/с.
  ///
  /// Приклад: `10.formatMs()` → `"10 м/с"`
  String formatSpeedMs() => '${formatUAH()} м/с';

  /// Конвертує км/год у м/с.
  ///
  /// Приклад: `36.kmhToMs()` → `"10 м/с"`
  String kmhToMs({int decimals = 1}) {
    final ms = toDouble() / 3.6;
    return '${ms.toStringAsFixed(decimals)} м/с';
  }

  // ─── Системи числення ─────────────────────────────────────────────

  /// Перетворює число на шістнадцятковий запис.
  ///
  /// Приклад: `255.toHex()` → `"FF"`
  String toHex({bool prefix = true}) {
    final hex = toInt().toRadixString(16).toUpperCase();
    return prefix ? '0x$hex' : hex;
  }

  /// Перетворює число на двійковий запис.
  ///
  /// Приклад: `10.toBinary()` → `"1010"`
  String toBinary({bool prefix = true}) {
    final bin = toInt().toRadixString(2);
    return prefix ? '0b$bin' : bin;
  }

  /// Перетворює число на вісімковий запис.
  ///
  /// Приклад: `8.toOctal()` → `"10"`
  String toOctal({bool prefix = true}) {
    final oct = toInt().toRadixString(8);
    return prefix ? '0o$oct' : oct;
  }

  /// Перетворює шістнадцятковий рядок у число.
  ///
  /// Приклад: `NumberFormatUAH.fromHex('FF')` → `255`
  static int fromHex(String hex) {
    return int.parse(hex.replaceFirst(RegExp(r'^0x'), ''), radix: 16);
  }

  /// Перетворює двійковий рядок у число.
  ///
  /// Приклад: `NumberFormatUAH.fromBinary('1010')` → `10`
  static int fromBinary(String bin) {
    return int.parse(bin.replaceFirst(RegExp(r'^0b'), ''), radix: 2);
  }

  // ─── Математичні утиліти (розширені) ──────────────────────────────

  /// Факторіал числа.
  ///
  /// Підтримує числа від 0 до 20 (максимум для int64).
  /// Приклад: `5.factorial()` → `120`
  BigInt get factorial {
    final n = toInt();
    if (n < 0) throw ArgumentError('Факторіал не визначений для від\'ємних чисел');
    if (n > 20) throw ArgumentError('Факторіал для $n занадто великий');
    if (n <= 1) return BigInt.one;
    var result = BigInt.one;
    for (var i = 2; i <= n; i++) {
      result *= BigInt.from(i);
    }
    return result;
  }

  /// Чи є число степенем двійки.
  ///
  /// Приклад: `8.isPowerOfTwo` → `true`, `6.isPowerOfTwo` → `false`
  bool get isPowerOfTwo {
    final n = toInt();
    return n > 0 && (n & (n - 1)) == 0;
  }

  /// Чи є число числом Фібоначчі.
  ///
  /// Приклад: `8.isFibonacci` → `true`, `6.isFibonacci` → `false`
  bool get isFibonacci {
    final n = toInt();
    if (n < 0) return false;
    // Число є Фібоначчі, якщо 5n²+4 або 5n²-4 є ідеальним квадратом
    final test1 = 5 * n * n + 4;
    final test2 = 5 * n * n - 4;
    return _isPerfectSquareLong(test1) || _isPerfectSquareLong(test2);
  }

  /// Допоміжний метод перевірки ідеального квадрату для великих чисел.
  static bool _isPerfectSquareLong(int n) {
    if (n < 0) return false;
    final root = math.sqrt(n.toDouble()).round();
    return root * root == n;
  }

  /// Найближче число, кратне [multiple].
  ///
  /// Приклад: `17.nearestMultipleOf(5)` → `15`
  /// Приклад: `18.nearestMultipleOf(5)` → `20`
  int nearestMultipleOf(int multiple) {
    if (multiple == 0) return 0;
    return ((toInt() + multiple ~/ 2) ~/ multiple) * multiple;
  }

  /// Округлення вниз до кратного [multiple].
  ///
  /// Приклад: `17.floorToMultiple(5)` → `15`
  int floorToMultiple(int multiple) {
    if (multiple == 0) return 0;
    return (toInt() ~/ multiple) * multiple;
  }

  /// Округлення вгору до кратного [multiple].
  ///
  /// Приклад: `17.ceilToMultiple(5)` → `20`
  int ceilToMultiple(int multiple) {
    if (multiple == 0) return 0;
    return ((toInt() + multiple - 1) ~/ multiple) * multiple;
  }

  /// Поділ з остачею: повертає мапу з 'quotient' та 'remainder'.
  ///
  /// Приклад: `17.divmod(5)` → `{quotient: 3, remainder: 2}`
  Map<String, int> divmod(int divisor) {
    if (divisor == 0) throw ArgumentError('Дільник не може бути нульовим');
    return {
      'quotient': toInt() ~/ divisor,
      'remainder': toInt() % divisor,
    };
  }

  // ─── Англомовні числівники ────────────────────────────────────────

  /// Перетворює число на англійський текст (до 999).
  ///
  /// Приклад: `42.toWordsEN()` → `"forty two"`
  String toWordsEN() {
    if (toInt() == 0) return 'zero';
    if (toInt() < 0) return 'minus ${(-this).toWordsEN()}';
    if (toInt() >= 1000) return formatUAH();
    return _numberToWordsEN(toInt());
  }

  /// Англійський порядковий числівник.
  ///
  /// Приклад: `1.toOrdinalEN()` → `"1st"`, `2.toOrdinalEN()` → `"2nd"`
  /// Приклад: `3.toOrdinalEN()` → `"3rd"`, `4.toOrdinalEN()` → `"4th"`
  String toOrdinalEN() {
    final n = toInt().abs();
    final suffix = _ordinalSuffixEN(n);
    return '$n$suffix';
  }

  /// Повертає англійський суфікс порядкового числівника.
  static String _ordinalSuffixEN(int n) {
    if (n >= 11 && n <= 13) return 'th';
    switch (n % 10) {
      case 1:
        return 'st';
      case 2:
        return 'nd';
      case 3:
        return 'rd';
      default:
        return 'th';
    }
  }

  /// Перетворює число від 1 до 999 на англійський текст.
  static String _numberToWordsEN(int n) {
    const ones = [
      '', 'one', 'two', 'three', 'four', 'five', 'six',
      'seven', 'eight', 'nine',
    ];
    const teens = [
      'ten', 'eleven', 'twelve', 'thirteen', 'fourteen',
      'fifteen', 'sixteen', 'seventeen', 'eighteen', 'nineteen',
    ];
    const tens = [
      '', '', 'twenty', 'thirty', 'forty', 'fifty',
      'sixty', 'seventy', 'eighty', 'ninety',
    ];

    final buffer = StringBuffer();

    if (n >= 100) {
      buffer.write('${ones[n ~/ 100]} hundred');
      if (n % 100 != 0) buffer.write(' ');
    }

    final remainder = n % 100;
    if (remainder >= 10 && remainder < 20) {
      buffer.write(teens[remainder - 10]);
    } else {
      final ten = remainder ~/ 10;
      final one = remainder % 10;
      if (ten > 0) buffer.write(tens[ten]);
      if (one > 0) {
        if (ten > 0) buffer.write(' ');
        buffer.write(ones[one]);
      }
    }

    return buffer.toString();
  }

  // ─── Текстове представлення ───────────────────────────────────────

  /// Створює текстовий прогрес-бар.
  ///
  /// Приклад: `75.progressBar(width: 10)` → `"██████████░░░░░░░░░░░"`
  ///
  /// [max] — максимальне значення (за замовчуванням 100).
  /// [width] — ширина прогрес-бару (за замовчуванням 20).
  /// [filled] — символ заповнення (за замовчуванням '█').
  /// [empty] — символ порожнечі (за замовчуванням '░').
  String progressBar({
    num max = 100,
    int width = 20,
    String filled = '█',
    String empty = '░',
  }) {
    final progress = (this / max).clamp(0.0, 1.0).toDouble();
    final filledCount = (progress * width).round();
    final emptyCount = width - filledCount;
    return filled * filledCount + empty * emptyCount;
  }

  /// Створює текстовий графік (гістограму) для списку значень.
  ///
  /// Приклад: `[3, 7, 2].barChart()` → `"███\n███████\n██"`
  static String barChart(List<num> values,
      {String filled = '█', String separator = '\n'}) {
    return values.map((v) {
      final count = v.toInt().clamp(0, 100);
      return filled * count;
    }).join(separator);
  }

  /// Повертає число з ведучими нулями.
  ///
  /// Приклад: `5.padZero(3)` → `"005"`
  String padZero(int width) {
    return toInt().abs().toString().padLeft(width, '0');
  }

  /// Повертає число з розрядними сепараторами (кома).
  ///
  /// Приклад: `12345.formatWithComma()` → `"12,345"`
  String formatWithComma() {
    final intPart = toInt().abs();
    final buffer = StringBuffer();
    final digits = intPart.toString();
    var count = 0;
    for (var i = digits.length - 1; i >= 0; i--) {
      if (count > 0 && count % 3 == 0) buffer.write(',');
      buffer.write(digits[i]);
      count++;
    }
    final reversed = buffer.toString().split('').reversed.join();
    return this < 0 ? '-$reversed' : reversed;
  }

  // ─── Фінансові утиліти ────────────────────────────────────────────

  /// Обчислює податок від суми.
  ///
  /// Приклад: `1000.withTax(20)` → `"1 200"`
  ///
  /// [taxRate] — ставка податку у відсотках.
  String withTax(num taxRate, {int decimals = 0}) {
    final withTax = toDouble() * (1 + taxRate.toDouble() / 100);
    if (decimals == 0) return withTax.round().formatUAH();
    return withTax.toStringAsFixed(decimals).replaceFirst('.', ',');
  }

  /// Обчислює суму з дисконтом.
  ///
  /// Приклад: `1000.withDiscount(15)` → `"850"`
  ///
  /// [discountPercent] — розмір знижки у відсотках.
  String withDiscount(num discountPercent, {int decimals = 0}) {
    final discounted = toDouble() * (1 - discountPercent.toDouble() / 100);
    if (decimals == 0) return discounted.round().formatUAH();
    return discounted.toStringAsFixed(decimals).replaceFirst('.', ',');
  }

  /// Обчислює суму податку.
  ///
  /// Приклад: `1000.taxAmount(20)` → `"200"`
  ///
  /// [taxRate] — ставка податку у відсотках.
  String taxAmount(num taxRate, {int decimals = 0}) {
    final tax = toDouble() * taxRate.toDouble() / 100;
    if (decimals == 0) return tax.round().formatUAH();
    return tax.toStringAsFixed(decimals).replaceFirst('.', ',');
  }

  /// Розбиває число на частини (наприклад, для розстрочки).
  ///
  /// Приклад: `10000.splitIntoParts(12)` повертає список з 12 елементів по 833/834.
  List<int> splitIntoParts(int parts) {
    if (parts <= 0) throw ArgumentError('Кількість частин має бути > 0');
    final total = toInt().abs();
    final base = total ~/ parts;
    final remainder = total % parts;
    final result = List<int>.filled(parts, base);
    for (var i = 0; i < remainder; i++) {
      result[i]++;
    }
    return result;
  }

  /// Форматує розстрочку українською.
  ///
  /// Приклад: `12000.formatInstallment(12)` → `"1 000 грн/міс × 12 міс"`
  String formatInstallment(int months) {
    final perMonth = (toDouble() / months).round();
    return '${perMonth.formatUAH()} грн/міс × $months міс';
  }

  // ─── Градуси та радіани ───────────────────────────────────────────

  /// Конвертує градуси у радіани.
  ///
  /// Приклад: `180.toRadians()` → `3.14159...`
  double get toRadians => toDouble() * math.pi / 180;

  /// Конвертує радіани у градуси.
  ///
  /// Приклад: `3.14159.toDegrees()` → `180.0`
  double get toDegrees => toDouble() * 180 / math.pi;

  /// Синус числа (вважається в радіанах).
  double get sin => math.sin(toDouble());

  /// Косинус числа (вважається в радіанах).
  double get cos => math.cos(toDouble());

  /// Тангенс числа (вважається в радіанах).
  double get tan => math.tan(toDouble());

  /// Арксинус числа.
  double get asin => math.asin(toDouble());

  /// Арккосинус числа.
  double get acos => math.acos(toDouble());

  /// Арктангенс числа.
  double get atan => math.atan(toDouble());

  /// Натуральний логарифм.
  double get ln => math.log(toDouble());

  /// Десятковий логарифм.
  double get log10 => math.log10(toDouble());

  /// Логарифм з довільною основою.
  ///
  /// Приклад: `8.logBase(2)` → `3.0`
  double logBase(num base) => math.log(toDouble()) / math.log(base.toDouble());

  // ─── Телефонні та спеціальні формати ──────────────────────────────

  /// Форматує число як український номер телефону.
  ///
  /// Приклад: `380441234567.formatPhoneUA()` → `"+38 (044) 123-45-67"`
  String formatPhoneUA() {
    final digits = toInt().abs().toString();
    if (digits.length == 12) {
      return '+${digits.substring(0, 2)} (${digits.substring(2, 5)}) '
          '${digits.substring(5, 8)}-${digits.substring(8, 10)}-${digits.substring(10, 12)}';
    }
    if (digits.length == 10) {
      return '+3${digits.substring(0, 1)} (${digits.substring(1, 3)}) '
          '${digits.substring(3, 5)}-${digits.substring(5, 7)}-${digits.substring(7, 9)}';
    }
    return digits;
  }

  /// Форматує число як номер банківської картки.
  ///
  /// Приклад: `1234567812345678.formatCardNumber()` → `"1234 5678 1234 5678"`
  String formatCardNumber() {
    final digits = toInt().abs().toString();
    final buffer = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      if (i > 0 && i % 4 == 0) buffer.write(' ');
      buffer.write(digits[i]);
    }
    return buffer.toString();
  }

  /// Форматує число як індекс (поштовий).
  ///
  /// Приклад: `12345.formatPostalCode()` → `"12345"`
  String formatPostalCode() => padZero(5);

  // ─── Приватні методи ──────────────────────────────────────────────

  /// Перетворює число від 1 до 999 на український текст.
  ///
  /// [n] — число для перетворення (1–999).
  static String _numberToWords(int n) {
    if (n == 0) return 'нуль';

    const ones = [
      '', 'один', 'два', 'три', 'чотири', "п\u0027ять", 'шість',
      'сім', 'вісім', "дев\u0027ять",
    ];
    const teens = [
      'десять', 'одинадцять', 'дванадцять', 'тринадцять',
      "чотирнадцять", "п\u0027ятнадцять", 'шістнадцять',
      'сімнадцять', 'вісімнадцять', "дев\u0027ятнадцять",
    ];
    const tens = [
      '', '', 'двадцять', 'тридцять', 'сорок', "п\u0027ятдесят",
      'шістдесят', 'сімдесят', 'вісімдесят', "дев\u0027яносто",
    ];
    const hundreds = [
      '', 'сто', 'двісті', 'триста', 'чотириста',
      "п\u0027ятсот", 'шістсот', 'сімсот', 'вісімсот',
      "дев\u0027ятсот",
    ];

    final buffer = StringBuffer();

    if (n >= 100) {
      buffer.write(hundreds[n ~/ 100]);
      if (n % 100 != 0) buffer.write(' ');
    }

    final remainder = n % 100;
    if (remainder >= 10 && remainder < 20) {
      buffer.write(teens[remainder - 10]);
    } else {
      final ten = remainder ~/ 10;
      final one = remainder % 10;
      if (ten > 0) buffer.write(tens[ten]);
      if (one > 0) {
        if (ten > 0) buffer.write(' ');
        buffer.write(ones[one]);
      }
    }

    return buffer.toString();
  }
}
