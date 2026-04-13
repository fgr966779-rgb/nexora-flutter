/// Extensions on [DateTime] for Ukrainian relative time strings, formatting,
/// period checks, range generators, and date comparison utilities.
///
/// Містить:
/// - Відносний час (relative, relativeVerbose, remaining, relativeEN, relativeENFull)
/// - Перевірки періоду (isToday, isYesterday, isThisWeek, isThisMonth)
/// - Межі періодів (startOfDay, endOfDay, startOfWeek, startOfMonth)
/// - Форматування українською (formatUAH, formatShortUAH, formatFullUAH)
/// - Форматування англійською (formatEN, formatShortEN, relativeENFull)
/// - Назви місяців та днів тижня (називний, родовий, орудний відмінки)
/// - Порівняння дат (isSameDay, isSameWeek, daysUntil, workingDaysUntil)
/// - Робочі дні (addWorkingDays, nextWeekday, isWorkday, isWeekend)
/// - Конвертори (toSecondsSinceEpoch, toMillisecondsSinceEpoch, fromSecondsSinceEpoch)
/// - Знак зодіаку, китайський зодіак, свята України, вікові розрахунки
/// - Генератори діапазонів (daysRangeTo, lastNDays, nextNDays)
/// - Розширені формати для гейміфікації (formatCountdown, formatTransactionDate)
/// - ISO 8601 форматування, ювілейні дати
/// - Арифметика дат (addYears, addMonths, subtractYears, subtractMonths)
/// - Високосний рік, дні у році, залишки періодів
/// - Сезони (seasonUAH, seasonEN, seasonEmoji)
/// - AM/PM, 12-годинний формат, компактні формати
/// - Відсоток періоду (dayProgress, monthProgress, yearProgress)
/// - Тривалість між датами (durationTo, durationToShort, durationToFull)
/// - Порядкові дні тижня в місяці, юліанський день
/// - Валідація, вікові категорії, англомовні назви
library;

extension DateTimeExt on DateTime {
  // ─── Відносний час ────────────────────────────────────────────────

  /// Повертає відносний рядок часу українською.
  ///
  /// Приклади:
  /// - `"щойно"` — менше 1 хвилини
  /// - `"5 хв тому"` — 5 хвилин тому
  /// - `"1 год тому"` — 1 годину тому
  /// - `"вчора"` — 1 день тому
  /// - `"2 дні тому"` — кілька днів
  /// - `"3 тижні тому"` — кілька тижнів
  /// - `"2 міс тому"` — кілька місяців
  ///
  /// [now] — опціональна дата «зараз» для тестування.
  String relative({DateTime? now}) {
    final reference = now ?? DateTime.now();
    final difference = reference.difference(this);

    if (difference.isNegative) return 'зараз';

    final seconds = difference.inSeconds;
    final minutes = difference.inMinutes;
    final hours = difference.inHours;
    final days = difference.inDays;

    if (seconds < 60) {
      return 'щойно';
    } else if (minutes < 60) {
      final m = minutes;
      if (m == 1) return '1 хв тому';
      if (m >= 2 && m <= 4) return '$m хв тому';
      return '$m хв тому';
    } else if (hours < 24) {
      final h = hours;
      if (h == 1) return '1 год тому';
      if (h >= 2 && h <= 4) return '$h год тому';
      return '$h год тому';
    } else if (days == 1) {
      return 'вчора';
    } else if (days < 7) {
      if (days >= 2 && days <= 4) return '$days дні тому';
      return '$days днів тому';
    } else if (days < 30) {
      final weeks = days ~/ 7;
      if (weeks == 1) return '1 тиждень тому';
      if (weeks >= 2 && weeks <= 4) return '$weeks тижні тому';
      return '$weeks тижнів тому';
    } else {
      final months = days ~/ 30;
      if (months == 1) return '1 міс тому';
      if (months >= 2 && months <= 4) return '$months міс тому';
      return '$months міс тому';
    }
  }

  /// Повертає розгорнутий відносний рядок українською.
  ///
  /// Приклади:
  /// - `"хвилину тому"`, `"5 хвилин тому"`, `"годину тому"`
  /// - `"позавчора"` — 2 дні тому
  ///
  /// [now] — опціональна дата «зараз» для тестування.
  String relativeVerbose({DateTime? now}) {
    final reference = now ?? DateTime.now();
    final difference = reference.difference(this);

    if (difference.isNegative) return 'зараз';

    final seconds = difference.inSeconds;
    final minutes = difference.inMinutes;
    final hours = difference.inHours;
    final days = difference.inDays;

    if (seconds < 5) return 'щойно';
    if (seconds < 60) return 'кілька секунд тому';

    if (minutes < 60) {
      if (minutes == 1) return 'хвилину тому';
      if (minutes >= 2 && minutes <= 4) return '$minutes хвилини тому';
      return '$minutes хвилин тому';
    }

    if (hours < 24) {
      if (hours == 1) return 'годину тому';
      if (hours >= 2 && hours <= 4) return '$hours години тому';
      return '$hours годин тому';
    }

    if (days == 1) return 'вчора';
    if (days == 2) return 'позавчора';

    if (days < 7) {
      if (days >= 2 && days <= 4) return '$days дні тому';
      return '$days днів тому';
    }

    final weeks = days ~/ 7;
    if (weeks == 1) return 'тиждень тому';
    if (weeks >= 2 && weeks <= 4) return '$weeks тижні тому';
    return '$weeks тижнів тому';
  }

  /// Повертає короткий відносний рядок.
  ///
  /// Приклади: `"5хв"`, `"2год"`, `"3д"`, `"2тижд"`
  String relativeShort({DateTime? now}) {
    final reference = now ?? DateTime.now();
    final diff = reference.difference(this);

    if (diff.isNegative) return 'зараз';

    final minutes = diff.inMinutes;
    final hours = diff.inHours;
    final days = diff.inDays;

    if (minutes < 60) return '${minutes}хв';
    if (hours < 24) return '${hours}год';
    if (days == 1) return 'вчора';
    if (days < 7) return '${days}д';
    if (days < 30) return '${days ~/ 7}тижд';
    return '${days ~/ 30}міс';
  }

  /// Повертає англомовний відносний рядок.
  ///
  /// Приклади: `"just now"`, `"5 min ago"`, `"1 hour ago"`
  String relativeEN({DateTime? now}) {
    final reference = now ?? DateTime.now();
    final diff = reference.difference(this);

    if (diff.isNegative) return 'now';

    final minutes = diff.inMinutes;
    final hours = diff.inHours;
    final days = diff.inDays;

    if (minutes < 1) return 'just now';
    if (minutes < 60) return '${minutes}m ago';
    if (hours < 24) return '${hours}h ago';
    if (days == 1) return 'yesterday';
    if (days < 7) return '${days}d ago';
    if (days < 30) return '${days ~/ 7}w ago';
    return '${days ~/ 30}mo ago';
  }

  /// Повертає рядок "X днів залишилось" українською.
  ///
  /// Приклад: `"15 днів залишилось"`
  /// Якщо термін минув — повертає `"0 днів залишилось"`.
  ///
  /// [now] — опціональна дата «зараз» для тестування.
  String remaining({DateTime? now}) {
    final reference = now ?? DateTime.now();
    final difference = this.difference(reference);

    if (difference.isNegative) return '0 днів залишилось';

    final days = difference.inDays;
    if (days == 1) return '1 день залишилось';
    if (days >= 2 && days <= 4) return '$days дні залишилось';
    return '$days днів залишилось';
  }

  /// Повертає розгорнутий рядок з часом, що залишився.
  ///
  /// Приклади: `"2 дні 5 годин залишилось"`, `"3 години залишилось"`.
  ///
  /// [now] — опціональна дата «зараз» для тестування.
  String remainingDetailed({DateTime? now}) {
    final reference = now ?? DateTime.now();
    final diff = difference(reference);

    if (diff.isNegative) return '0 днів залишилось';

    final days = diff.inDays;
    final hours = diff.inHours % 24;
    final minutes = diff.inMinutes % 60;

    final parts = <String>[];
    if (days > 0) parts.add('$days ${_pluralDays(days)}');
    if (hours > 0) parts.add('$hours ${_pluralHours(hours)}');
    if (days == 0 && minutes > 0) {
      parts.add('$minutes ${_pluralMinutes(minutes)}');
    }

    return parts.isEmpty
        ? '0 хвилин залишилось'
        : '${parts.join(' ')} залишилось';
  }

  // ─── Перевірки періоду ────────────────────────────────────────────

  /// Чи відповідає ця дата сьогоднішньому дню.
  ///
  /// Порівнює рік, місяць та день без урахування часу.
  ///
  /// [now] — опціональна дата «зараз» для тестування.
  bool isTodayDate({DateTime? now}) {
    final n = now ?? DateTime.now();
    return year == n.year && month == n.month && day == n.day;
  }

  /// Чи відповідає ця дата сьогоднішньому дню (використовує DateTime.now).
  bool get isToday => isTodayDate();

  /// Чи відповідає ця дата вчорашньому дню.
  bool get isYesterday {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return year == yesterday.year &&
        month == yesterday.month &&
        day == yesterday.day;
  }

  /// Чи відповідає ця дата позавчорашньому дню.
  bool get isDayBeforeYesterday {
    final twoDaysAgo = DateTime.now().subtract(const Duration(days: 2));
    return year == twoDaysAgo.year &&
        month == twoDaysAgo.month &&
        day == twoDaysAgo.day;
  }

  /// Чи відповідає ця дата завтрашньому дню.
  bool get isTomorrow {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return year == tomorrow.year &&
        month == tomorrow.month &&
        day == tomorrow.day;
  }

  /// Чи потрапляє ця дата в поточний тиждень (понеділок — неділя).
  bool get isThisWeek {
    final now = DateTime.now();
    final startOfWeek = now.startOfWeek;
    final endOfWeek = now.endOfWeek;
    return !isBefore(startOfWeek) && !isAfter(endOfWeek);
  }

  /// Чи потрапляє ця дата в поточний місяць.
  bool get isThisMonth {
    final now = DateTime.now();
    return year == now.year && month == now.month;
  }

  /// Чи знаходиться ця дата в поточному році.
  bool get isThisYear {
    return year == DateTime.now().year;
  }

  /// Чи є ця дата в минулому тижні.
  bool get isLastWeek {
    final now = DateTime.now();
    final thisWeekStart = now.startOfWeek;
    final lastWeekStart = thisWeekStart.subtract(const Duration(days: 7));
    final lastWeekEnd = thisWeekStart.subtract(const Duration(days: 1));
    return !isBefore(lastWeekStart) && !isAfter(lastWeekEnd);
  }

  /// Чи є ця дата в минулому місяці.
  bool get isLastMonth {
    final now = DateTime.now();
    final lastMonth = DateTime(now.year, now.month - 1, 1);
    final thisMonthStart = DateTime(now.year, now.month, 1);
    return !isBefore(lastMonth) && isBefore(thisMonthStart);
  }

  /// Чи є ця дата в наступному тижні.
  bool get isNextWeek {
    final now = DateTime.now();
    final nextWeekStart = now.endOfWeek.add(const Duration(days: 1));
    final nextWeekEnd = nextWeekStart.add(const Duration(days: 6));
    return !isBefore(nextWeekStart) && !isAfter(nextWeekEnd);
  }

  /// Чи є ця дата в наступному місяці.
  bool get isNextMonth {
    final now = DateTime.now();
    final nextMonth = DateTime(now.year, now.month + 1, 1);
    final monthAfter = DateTime(now.year, now.month + 2, 1);
    return !isBefore(nextMonth) && isBefore(monthAfter);
  }

  // ─── Межі періодів ────────────────────────────────────────────────

  /// Початок дня (00:00:00).
  DateTime get startOfDay => DateTime(year, month, day);

  /// Кінець дня (23:59:59).
  DateTime get endOfDay => DateTime(year, month, day, 23, 59, 59, 999);

  /// Початок тижня (понеділок, 00:00:00).
  ///
  /// Використовує стандарт ISO 8601: понеділок = 1.
  DateTime get startOfWeek {
    final weekday = this.weekday;
    return subtract(Duration(days: weekday - 1)).startOfDay;
  }

  /// Кінець тижня (неділя, 23:59:59).
  DateTime get endOfWeek {
    final weekday = this.weekday;
    return add(Duration(days: 7 - weekday)).endOfDay;
  }

  /// Початок місяця (1-ше число, 00:00:00).
  DateTime get startOfMonth => DateTime(year, month, 1);

  /// Кінець місяця (останнє число, 23:59:59).
  DateTime get endOfMonth => DateTime(year, month + 1, 0, 23, 59, 59, 999);

  /// Початок року (1 січня, 00:00:00).
  DateTime get startOfYear => DateTime(year, 1, 1);

  /// Кінець року (31 грудня, 23:59:59).
  DateTime get endOfYear => DateTime(year, 12, 31, 23, 59, 59, 999);

  /// Початок кварталу.
  ///
  /// Квартал 1: 1 січня, Квартал 2: 1 квітня,
  /// Квартал 3: 1 липня, Квартал 4: 1 жовтня.
  DateTime get startOfQuarter {
    final q = ((month - 1) ~/ 3) * 3 + 1;
    return DateTime(year, q, 1);
  }

  /// Кінець кварталу.
  DateTime get endOfQuarter {
    final q = ((month - 1) ~/ 3) * 3 + 3;
    return DateTime(year, q + 1, 0, 23, 59, 59, 999);
  }

  /// Початок півріччя.
  ///
  /// Перше півріччя: 1 січня — 30 червня.
  /// Друге півріччя: 1 липня — 31 грудня.
  DateTime get startOfHalfYear {
    if (month <= 6) return DateTime(year, 1, 1);
    return DateTime(year, 7, 1);
  }

  /// Кінець півріччя.
  DateTime get endOfHalfYear {
    if (month <= 6) return DateTime(year, 6, 30, 23, 59, 59, 999);
    return DateTime(year, 12, 31, 23, 59, 59, 999);
  }

  // ─── Квартал ──────────────────────────────────────────────────────

  /// Номер кварталу (1–4).
  int get quarter => ((month - 1) ~/ 3) + 1;

  /// Назва кварталу українською.
  ///
  /// Повертає 'I квартал', 'II квартал', 'III квартал', 'IV квартал'.
  String get quarterNameUAH {
    const names = ['', 'I квартал', 'II квартал', 'III квартал', 'IV квартал'];
    return names[quarter] ?? '';
  }

  /// Номер півріччя (1 або 2).
  int get halfYear => month <= 6 ? 1 : 2;

  // ─── Фіскальний рік ───────────────────────────────────────────────

  /// Початок фіскального року (1 січня).
  DateTime get startOfFiscalYear => DateTime(year, 1, 1);

  /// Кінець фіскального року (31 грудня).
  DateTime get endOfFiscalYear => DateTime(year, 12, 31, 23, 59, 59, 999);

  // ─── Форматування українською ─────────────────────────────────────

  /// Форматує дату повністю українською.
  ///
  /// Приклад: `DateTime(2025, 4, 12).formatUAH()` → `"12 квітня 2025"`
  String formatUAH() {
    return '$day ${monthGenitiveUAH} $year';
  }

  /// Коротке форматування дати.
  ///
  /// Приклад: `DateTime(2025, 4, 12).formatShortUAH()` → `"12.04.25"`
  String formatShortUAH() {
    final d = day.toString().padLeft(2, '0');
    final m = month.toString().padLeft(2, '0');
    final y = (year % 100).toString().padLeft(2, '0');
    return '$d.$m.$y';
  }

  /// Формат DD.MM.YYYY (повний рік).
  ///
  /// Приклад: `"12.04.2025"`
  String formatFullShortUAH() {
    final d = day.toString().padLeft(2, '0');
    final m = month.toString().padLeft(2, '0');
    return '$d.$m.$year';
  }

  /// Повертає назву дня тижня українською.
  ///
  /// Приклад: `"субота"`
  String formatWeekdayUAH() => weekdayUAH;

  /// Повертає скорочену назву дня тижня.
  ///
  /// Приклад: `"сб"`
  String formatWeekdayShortUAH() => weekdayShortUAH;

  /// Повертає назву місяця та рік.
  ///
  /// Приклад: `"квітень 2025"`
  String formatMonthYearUAH() => '$monthUAH $year';

  /// Повертає назву місяця та рік у родовому відмінку.
  ///
  /// Приклад: `"квітня 2025"`
  String formatMonthYearGenitiveUAH() => '$monthGenitiveUAH $year';

  /// Форматує час як HH:MM.
  ///
  /// Приклад: `"14:30"`
  String formatTime() {
    return '${hour.toString().padLeft(2, "0")}:${minute.toString().padLeft(2, "0")}';
  }

  /// Форматує час як HH:MM:SS.
  ///
  /// Приклад: `"14:30:45"`
  String formatTimeWithSeconds() {
    return '${hour.toString().padLeft(2, "0")}:'
        '${minute.toString().padLeft(2, "0")}:'
        '${second.toString().padLeft(2, "0")}';
  }

  /// Форматує дату та час у форматі ISO 8601.
  ///
  /// Приклад: `"2025-04-12T14:30:00"`
  String formatISO8601() {
    return toIso8601String();
  }

  /// Форматує тільки дату у форматі ISO 8601.
  ///
  /// Приклад: `"2025-04-12"`
  String formatISODate() {
    return '${year.toString().padLeft(4, "0")}-'
        '${month.toString().padLeft(2, "0")}-'
        '${day.toString().padLeft(2, "0")}';
  }

  /// Форматує дату як "DD Month YYYY, HH:MM" для повідомлень.
  ///
  /// Приклад: `"12 квітня 2025, 14:30"`
  String formatDateTimeFull() {
    final time = formatTime();
    return '$day ${monthGenitiveUAH} $year, $time';
  }

  // ─── Назви місяців та днів тижня ──────────────────────────────────

  /// Назва дня тижня українською (називний відмінок).
  ///
  /// Приклад: `"понеділок"`, `"субота"`
  String get weekdayUAH {
    const days = [
      '', 'понеділок', 'вівторок', 'середа', 'четвер',
      "п\u0027ятниця", 'субота', 'неділя',
    ];
    return days[weekday] ?? '';
  }

  /// Скорочена назва дня тижня українською.
  ///
  /// Приклад: `"пн"`, `"сб"`
  String get weekdayShortUAH {
    const days = [
      '', 'пн', 'вт', 'ср', 'чт', 'пт', 'сб', 'нд',
    ];
    return days[weekday] ?? '';
  }

  /// Назва дня тижня українською (родовий відмінок).
  ///
  /// Приклад: `"понеділка"`, `"суботи"`
  String get weekdayGenitiveUAH {
    const days = [
      '', 'понеділка', 'вівторка', 'середи', 'четверга',
      "п\u0027ятниці", 'суботи', 'неділі',
    ];
    return days[weekday] ?? '';
  }

  /// Назва дня тижня українською (знахідний відмінок).
  ///
  /// Приклад: `"понеділок"`, `"суботу"`
  String get weekdayAccusativeUAH {
    const days = [
      '', 'понеділок', 'вівторок', 'середу', 'четвер',
      "п\u0027ятницю", 'суботу', 'неділю',
    ];
    return days[weekday] ?? '';
  }

  /// Назва місяця українською (називний відмінок).
  ///
  /// Приклад: `"січень"`, `"квітень"`, `"грудень"`
  String get monthUAH {
    const months = [
      '', 'січень', 'лютий', 'березень', 'квітень', 'травень',
      'червень', 'липень', 'серпень', 'вересень', 'жовтень',
      'листопад', 'грудень',
    ];
    return months[month] ?? '';
  }

  /// Назва місяця українською (родовий відмінок).
  ///
  /// Приклад: `"січня"`, `"квітня"`, `"грудня"`
  String get monthGenitiveUAH {
    const months = [
      '', 'січня', 'лютого', 'березня', 'квітня', 'травня',
      'червня', 'липня', 'серпня', 'вересня', 'жовтня',
      'листопада', 'грудня',
    ];
    return months[month] ?? '';
  }

  /// Скорочена назва місяця українською.
  ///
  /// Приклад: `"січ"`, `"кві"`, `"гру"`
  String get monthShortUAH {
    const months = [
      '', 'січ', 'лют', 'бер', 'кві', 'тра', 'чер',
      'лип', 'сер', 'вер', 'жов', 'лис', 'гру',
    ];
    return months[month] ?? '';
  }

  /// Назва місяця українською (орудний відмінок — «у січні»).
  ///
  /// Приклад: `"січні"`, `"квітні"`, `"грудні"`
  String get monthInstrumentalUAH {
    const months = [
      '', 'січні', 'лютому', 'березні', 'квітні', 'травні',
      'червні', 'липні', 'серпні', 'вересні', 'жовтні',
      'листопаді', 'грудні',
    ];
    return months[month] ?? '';
  }

  /// Назва місяця українською (давальний відмінок — «на січень»).
  ///
  /// Приклад: `"січень"`, `"квітень"`, `"грудень"`
  String get monthAccusativeUAH {
    const months = [
      '', 'січень', 'лютий', 'березень', 'квітень', 'травень',
      'червень', 'липень', 'серпень', 'вересень', 'жовтень',
      'листопад', 'грудень',
    ];
    return months[month] ?? '';
  }

  /// Англійська назва місяця.
  ///
  /// Приклад: `"January"`, `"April"`, `"December"`
  String get monthEN {
    const months = [
      '', 'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December',
    ];
    return months[month] ?? '';
  }

  /// Скорочена англійська назва місяця.
  ///
  /// Приклад: `"Jan"`, `"Apr"`, `"Dec"`
  String get monthShortEN {
    const months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return months[month] ?? '';
  }

  // ─── Порівняння дат ────────────────────────────────────────────────

  /// Кількість днів до вказаної дати.
  ///
  /// Повертає додатне значення, якщо [other] в майбутньому,
  /// від'ємне — якщо в минулому.
  int daysUntil(DateTime other) {
    final thisDay = startOfDay;
    final otherDay = other.startOfDay;
    return otherDay.difference(thisDay).inDays;
  }

  /// Кількість годин до вказаної дати.
  ///
  /// [other] — цільова дата.
  int hoursUntil(DateTime other) {
    return difference(other).inHours.abs();
  }

  /// Кількість хвилин до вказаної дати.
  ///
  /// [other] — цільова дата.
  int minutesUntil(DateTime other) {
    return difference(other).inMinutes.abs();
  }

  /// Чи збігаються дати (без урахування часу).
  ///
  /// Порівнює рік, місяць та день.
  bool isSameDay(DateTime other) {
    return year == other.year && month == other.month && day == other.day;
  }

  /// Чи збігаються дати та час (з точністю до хвилин).
  bool isSameMinute(DateTime other) {
    return year == other.year &&
        month == other.month &&
        day == other.day &&
        hour == other.hour &&
        minute == other.minute;
  }

  /// Чи знаходяться дати в одному тижні.
  ///
  /// Порівнює початок та кінець тижня обох дат.
  bool isSameWeek(DateTime other) {
    return !startOfWeek.isAfter(other.endOfWeek) &&
        !endOfWeek.isBefore(other.startOfWeek);
  }

  /// Чи знаходяться дати в одному місяці.
  bool isSameMonth(DateTime other) {
    return year == other.year && month == other.month;
  }

  /// Чи знаходяться дати в одному кварталі.
  bool isSameQuarter(DateTime other) {
    return year == other.year && quarter == other.quarter;
  }

  /// Чи знаходяться дати в одному році.
  bool isSameYear(DateTime other) {
    return year == other.year;
  }

  /// Чи є ця дата між [from] та [to] (включно).
  bool isBetween(DateTime from, DateTime to) {
    final start = from.isBefore(to) ? from : to;
    final end = from.isBefore(to) ? to : from;
    return !isBefore(start) && !isAfter(end);
  }

  /// Чи є ця дата строго між [from] та [to] (не включно).
  bool isBetweenExclusive(DateTime from, DateTime to) {
    return isAfter(from) && isBefore(to);
  }

  /// Повертає пізнішу з двох дат.
  DateTime latest(DateTime other) => isAfter(other) ? this : other;

  /// Повертає ранішу з двох дат.
  DateTime earliest(DateTime other) => isBefore(other) ? this : other;

  // ─── Зручні конструктори ──────────────────────────────────────────

  /// Копіює дату із заміною вказаних компонентів часу.
  ///
  /// [hour], [minute], [second], [millisecond], [microsecond] —
  /// опціональні нові значення. Якщо не вказані, зберігаються поточні.
  DateTime copyWithTime({
    int? hour,
    int? minute,
    int? second,
    int? millisecond,
    int? microsecond,
  }) {
    return DateTime(
      year, month, day,
      hour ?? this.hour,
      minute ?? this.minute,
      second ?? this.second,
      millisecond ?? this.millisecond,
      microsecond ?? this.microsecond,
    );
  }

  /// Копіює дату із заміною компонентів дати.
  ///
  /// [year], [month], [day] — опціональні нові значення.
  DateTime copyWithDate({
    int? year,
    int? month,
    int? day,
  }) {
    return DateTime(
      year ?? this.year,
      month ?? this.month,
      day ?? this.day,
      this.hour,
      this.minute,
      this.second,
      this.millisecond,
      this.microsecond,
    );
  }

  /// Встановлює час на початок дня (00:00:00).
  DateTime get atStartOfDay => startOfDay;

  /// Встановлює час на кінець дня (23:59:59).
  DateTime get atEndOfDay => endOfDay;

  // ─── Робочі дні ───────────────────────────────────────────────────

  /// Повертає наступний вказаний день тижня.
  ///
  /// [targetWeekday] — день тижня (1 = понеділок, 7 = неділя).
  /// Бросає [AssertionError], якщо [targetWeekday] поза межами 1–7.
  DateTime nextWeekday(int targetWeekday) {
    assert(targetWeekday >= 1 && targetWeekday <= 7);
    final diff = (targetWeekday - weekday) % 7;
    final daysToAdd = diff <= 0 ? diff + 7 : diff;
    return add(Duration(days: daysToAdd));
  }

  /// Повертає попередній вказаний день тижня.
  ///
  /// [targetWeekday] — день тижня (1 = понеділок, 7 = неділя).
  DateTime previousWeekday(int targetWeekday) {
    assert(targetWeekday >= 1 && targetWeekday <= 7);
    final diff = (weekday - targetWeekday) % 7;
    final daysToSubtract = diff <= 0 ? diff + 7 : diff;
    return subtract(Duration(days: daysToSubtract));
  }

  /// Додає вказану кількість робочих днів (без вихідних).
  ///
  /// [days] — кількість робочих днів для додавання.
  DateTime addWorkingDays(int days) {
    var result = this;
    var added = 0;
    while (added < days) {
      result = result.add(const Duration(days: 1));
      if (result.weekday <= 5) {
        added++;
      }
    }
    return result;
  }

  /// Віднімає вказану кількість робочих днів (без вихідних).
  ///
  /// [days] — кількість робочих днів для віднімання.
  DateTime subtractWorkingDays(int days) {
    var result = this;
    var subtracted = 0;
    while (subtracted < days) {
      result = result.subtract(const Duration(days: 1));
      if (result.weekday <= 5) {
        subtracted++;
      }
    }
    return result;
  }

  // ─── Вік ──────────────────────────────────────────────────────────

  /// Обчислює вік у повних роках.
  ///
  /// [referenceDate] — дата, на яку обчислюється вік (за замовчуванням сьогодні).
  int age({DateTime? referenceDate}) {
    final now = referenceDate ?? DateTime.now();
    var years = now.year - year;
    if (now.month < month || (now.month == month && now.day < day)) {
      years--;
    }
    return years;
  }

  /// Обчислює вік у місяцях.
  ///
  /// [referenceDate] — дата, на яку обчислюється.
  int ageInMonths({DateTime? referenceDate}) {
    final now = referenceDate ?? DateTime.now();
    var months = (now.year - year) * 12 + (now.month - month);
    if (now.day < day) months--;
    return months;
  }

  /// Обчислює дату наступного дня народження.
  ///
  /// Якщо день народження сьогодні — повертає наступний рік.
  DateTime nextBirthday({DateTime? referenceDate}) {
    final now = referenceDate ?? DateTime.now();
    var birthday = DateTime(now.year, month, day);
    if (!birthday.isAfter(now)) {
      birthday = DateTime(now.year + 1, month, day);
    }
    return birthday;
  }

  /// Кількість днів до наступного дня народження.
  ///
  /// Якщо день народження сьогодні — повертає 365 або 366.
  int daysUntilBirthday({DateTime? referenceDate}) {
    final next = nextBirthday(referenceDate: referenceDate);
    final now = referenceDate ?? DateTime.now();
    return next.difference(now).inDays;
  }

  // ─── Знак зодіаку ─────────────────────────────────────────────────

  /// Повертає знак зодіаку українською.
  ///
  /// Приклад: `"Овен"`, `"Телець"`, `"Близнюти"`.
  String get zodiacSign {
    const signs = [
      'Козеріг', 'Водолій', 'Риби', 'Овен', 'Телець',
      'Близнюти', 'Рак', 'Лев', 'Діва', 'Терези',
      'Скорпіон', 'Стрілець',
    ];
    const endDates = [19, 18, 20, 19, 20, 20, 22, 22, 22, 22, 21, 21];
    final index = month - 1;
    if (day < endDates[index]) return signs[index];
    return signs[(index + 1) % 12];
  }

  /// Символ знаку зодіаку.
  String get zodiacEmoji {
    const emojis = [
      '♑', '♒', '♓', '♈', '♉', '♊',
      '♋', '♌', '♍', '♎', '♏', '♐',
    ];
    const endDates = [19, 18, 20, 19, 20, 20, 22, 22, 22, 22, 21, 21];
    final index = month - 1;
    if (day < endDates[index]) return emojis[index];
    return emojis[(index + 1) % 12];
  }

  /// Елемент знаку зодіаку.
  ///
  /// Повертає 'Вогонь', 'Земля', 'Повітря' або 'Вода'.
  String get zodiacElement {
    final sign = zodiacSign;
    if (sign == 'Овен' || sign == 'Лев' || sign == 'Стрілець') return 'Вогонь';
    if (sign == 'Телець' || sign == 'Діва' || sign == 'Козеріг') return 'Земля';
    if (sign == 'Близнюти' || sign == 'Терези' || sign == 'Водолій') return 'Повітря';
    return 'Вода';
  }

  // ─── Свята ────────────────────────────────────────────────────────

  /// Чи є ця дата державним святом України.
  bool get isUkrainianHoliday {
    final holidays = _ukrainianHolidays(year);
    return holidays.any((d) => d.isSameDay(this));
  }

  /// Повертає назву українського свята, якщо дата є святом.
  ///
  /// Якщо не свято — повертає `null`.
  String? get ukrainianHolidayName {
    final holidays = _ukrainianHolidaysMap(year);
    return holidays[DateTime(year, month, day)];
  }

  /// Повертає список всіх свят України для року цієї дати.
  ///
  /// Повертає список [DateTime] з датами свят.
  List<DateTime> get ukrainianHolidaysForYear => _ukrainianHolidays(year);

  /// Повертає мапу свят України для року цієї дати.
  ///
  /// Повертає `Map<DateTime, String>` з датами та назвами.
  Map<DateTime, String> get ukrainianHolidaysMapForYear => _ukrainianHolidaysMap(year);

  // ─── Ювілеї ───────────────────────────────────────────────────────

  /// Чи є ця дата ювілейною (круглою датою).
  ///
  /// Ювілейними вважаються: 18, 20, 25, 30, 35, 40, 45, 50, 55, 60...
  bool isJubilee(int ageYears) {
    const jubileeYears = {18, 20, 25, 30, 35, 40, 45, 50, 55, 60, 65, 70, 75, 80, 85, 90, 95, 100};
    return jubileeYears.contains(ageYears);
  }

  /// Повертає назву ювілею українською.
  ///
  /// Приклад: `"двадцятиріччя"`, `"п'ятдесятиріччя"`.
  String jubileeName(int ageYears) {
    if (ageYears == 18) return 'повноліття';
    if (ageYears == 20) return 'двадцятиріччя';
    if (ageYears == 25) return 'двадцятип'ятиріччя';
    if (ageYears == 30) return 'тридцятиріччя';
    if (ageYears == 40) return 'сорокаріччя';
    if (ageYears == 50) return 'п'ятдесятиріччя';
    if (ageYears == 60) return 'шістдесятиріччя';
    if (ageYears == 70) return 'сімдесятиріччя';
    if (ageYears == 100) return 'століття';
    return '$ageYears-річчя';
  }

  // ─── Генератори діапазонів ────────────────────────────────────────

  /// Генерує список дат від цієї дати до [other] (включно).
  ///
  /// Приклад: `DateTime(2025, 4, 10).daysRangeTo(DateTime(2025, 4, 13))`
  /// → `[10.04, 11.04, 12.04, 13.04]`
  List<DateTime> daysRangeTo(DateTime other) {
    final from = startOfDay;
    final to = other.startOfDay;
    if (from.isAfter(to)) return [];

    final days = to.difference(from).inDays + 1;
    return List.generate(days, (i) => from.add(Duration(days: i)));
  }

  /// Генерує список дат за останні [days] днів від цієї дати.
  ///
  /// [days] — кількість днів для генерації.
  List<DateTime> lastNDays(int days) {
    return List.generate(days, (i) {
      return subtract(Duration(days: days - 1 - i)).startOfDay;
    });
  }

  /// Генерує список дат за наступні [days] днів від цієї дати.
  ///
  /// [days] — кількість днів для генерації.
  List<DateTime> nextNDays(int days) {
    return List.generate(days, (i) {
      return add(Duration(days: i)).startOfDay;
    });
  }

  /// Генерує список робочих днів від цієї дати до [other].
  ///
  /// Повертає тільки дні з понеділка по п'ятницю.
  List<DateTime> workingDaysRangeTo(DateTime other) {
    final allDays = daysRangeTo(other);
    return allDays.where((d) => d.weekday <= 5).toList();
  }

  /// Генерує список вихідних днів від цієї дати до [other].
  ///
  /// Повертає тільки дні з суботи та неділі.
  List<DateTime> weekendDaysRangeTo(DateTime other) {
    final allDays = daysRangeTo(other);
    return allDays.where((d) => d.weekday >= 6).toList();
  }

  // ─── Розширені формати для гейміфікації ───────────────────────────

  /// Форматує час як "DDд HHг MMхв" для таймерів і зворотного відліку.
  ///
  /// Приклад: `"15д 08г 42хв"`
  ///
  /// [now] — опціональна дата «зараз» для тестування.
  String formatCountdown({DateTime? now}) {
    final reference = now ?? DateTime.now();
    final diff = difference(reference);

    if (diff.isNegative) return '0д 0г 0хв';

    final days = diff.inDays;
    final hours = diff.inHours % 24;
    final minutes = diff.inMinutes % 60;

    final parts = <String>[];
    if (days > 0) parts.add('${days}д');
    if (hours > 0) parts.add('${hours.toString().padLeft(2, "0")}г');
    parts.add('${minutes.toString().padLeft(2, "0")}хв');
    return parts.join(' ');
  }

  /// Форматує зворотний відлік з секундами.
  ///
  /// Приклад: `"15д 08г 42хв 30с"`
  String formatCountdownWithSeconds({DateTime? now}) {
    final reference = now ?? DateTime.now();
    final diff = difference(reference);

    if (diff.isNegative) return '0д 0г 0хв 0с';

    final days = diff.inDays;
    final hours = diff.inHours % 24;
    final minutes = diff.inMinutes % 60;
    final seconds = diff.inSeconds % 60;

    final parts = <String>[];
    if (days > 0) parts.add('${days}д');
    if (hours > 0) parts.add('${hours.toString().padLeft(2, "0")}г');
    if (minutes > 0 || days > 0) parts.add('${minutes.toString().padLeft(2, "0")}хв');
    parts.add('${seconds.toString().padLeft(2, "0")}с');
    return parts.join(' ');
  }

  /// Форматує дату для списку транзакцій.
  ///
  /// Приклад: `"сьогодні"`, `"вчора"`, `"12 квітня"`, `"12 квітня 2024"`
  String formatTransactionDate() {
    if (isToday) return 'сьогодні';
    if (isYesterday) return 'вчора';
    if (isThisYear) return '$day ${monthGenitiveUAH}';
    return '$day ${monthGenitiveUAH} $year';
  }

  /// Форматує дату зі часом для повідомлень.
  ///
  /// Приклад: `"сьогодні, 14:30"`, `"12 квітня, 09:15"`
  String formatWithTime() {
    final time = formatTime();
    if (isToday) return 'сьогодні, $time';
    if (isYesterday) return 'вчора, $time';
    return '$day ${monthGenitiveUAH}, $time';
  }

  /// Форматує повний рядок дати та часу.
  ///
  /// Приклад: `"12 квітня 2025, 14:30"`
  String formatFullUAH() {
    final time = formatTime();
    return '$day ${monthGenitiveUAH} $year, $time';
  }

  /// Форматує дату для заголовка секції.
  ///
  /// Приклад: `"Квітень 2025"`, `"Сьогодні"`, `"Вчора"`
  String formatSectionHeader() {
    if (isToday) return 'Сьогодні';
    if (isYesterday) return 'Вчора';
    return formatMonthYearUAH();
  }

  /// Кількість повних років з цієї дати до сьогодні.
  int get yearsSince => age();

  /// Чи є дата у майбутньому.
  bool get isFuture => isAfter(DateTime.now());

  /// Чи є дата у минулому.
  bool get isPast => isBefore(DateTime.now());

  /// Чи є дата сьогодні або в майбутньому.
  bool get isTodayOrFuture => !isBefore(DateTime.now());

  /// Кількість днів у місяці цієї дати.
  int get daysInMonth => DateTime(year, month + 1, 0).day;

  /// Номер тижня в році (ISO 8601).
  ///
  /// Повертає значення від 1 до 53.
  int get weekNumber {
    final dayOfYear = DateTime(year, month, day)
        .difference(DateTime(year, 1, 1))
        .inDays;
    final weekDay = DateTime(year, month, day).weekday;
    return ((dayOfYear + weekDay - 1) ~/ 7) + 1;
  }

  /// Номер тижня в місяці (1–5).
  ///
  /// Повертає порядковий номер тижня в поточному місяці.
  int get weekOfMonth {
    final firstDayOfMonth = DateTime(year, month, 1).weekday;
    return ((day + firstDayOfMonth - 2) ~/ 7) + 1;
  }

  /// Номер дня в році (1–366).
  ///
  /// Повертає порядковий номер дня з початку року.
  int get dayOfYear {
    return DateTime(year, month, day).difference(DateTime(year, 1, 1)).inDays + 1;
  }

  /// Кількість робочих днів від цієї дати до [other].
  ///
  /// Підраховує тільки дні з понеділка по п'ятницю.
  /// Якщо [other] в минулому — повертає від'ємне значення.
  int workingDaysUntil(DateTime other) {
    final from = startOfDay;
    final to = other.startOfDay;
    var count = 0;
    var current = from;
    final isForward = !from.isAfter(to);

    while (isForward ? !current.isAfter(to) : !current.isBefore(to)) {
      if (current.weekday <= 5) {
        count += isForward ? 1 : -1;
      }
      current = current.add(const Duration(days: 1));
    }
    return count;
  }

  /// Чи є ця дата робочим днем (понеділок–п'ятниця).
  bool get isWorkday => weekday <= 5;

  /// Чи є ця дата вихідним (субота або неділя).
  bool get isWeekend => weekday >= 6;

  /// Чи є ця дата суботою.
  bool get isSaturday => weekday == DateTime.saturday;

  /// Чи є ця дата неділею.
  bool get isSunday => weekday == DateTime.sunday;

  /// Чи є ця дата вечірнім (після 18:00).
  bool get isEvening => hour >= 18;

  /// Чи є ця дата ранком (до 12:00).
  bool get isMorning => hour < 12;

  /// Чи є ця дата ввечері/вночі (після 22:00 або до 6:00).
  bool get isNightTime => hour >= 22 || hour < 6;

  /// Повертає привітання залежно від часу доби.
  ///
  /// Повертає: 'Доброго ранку', 'Добрий день', 'Добрий вечір', 'Доброї ночі'.
  String get greeting {
    final h = hour;
    if (h < 6) return 'Доброї ночі';
    if (h < 12) return 'Доброго ранку';
    if (h < 18) return 'Добрий день';
    return 'Добрий вечір';
  }

  /// Повертає іконку привітання залежно від часу доби.
  ///
  /// Повертає emoji: 🌙, ☀️, 🌤️, 🌅.
  String get greetingEmoji {
    final h = hour;
    if (h < 6) return '🌙';
    if (h < 12) return '☀️';
    if (h < 18) return '🌤️';
    return '🌅';
  }

  // ─── Конвертори epoch ─────────────────────────────────────────────

  /// Повертає секунди з початку епохи Unix (1 січня 1970).
  int get toSecondsSinceEpoch => millisecondsSinceEpoch ~/ 1000;

  /// Повертає мілісекунди з початку епохи Unix (вже є в Dart, але зручний аліас).
  int get toMillisecondsSinceEpoch => millisecondsSinceEpoch;

  /// Повертає мікросекунди з початку епохи Unix.
  int get toMicrosecondsSinceEpoch => microsecondsSinceEpoch;

  /// Створює DateTime з Unix timestamp у секундах.
  ///
  /// Приклад: `DateTimeExt.fromSecondsSinceEpoch(1712900000)`
  static DateTime fromSecondsSinceEpoch(int seconds) {
    return DateTime.fromMillisecondsSinceEpoch(seconds * 1000);
  }

  // ─── Високосний рік та дні ────────────────────────────────────────

  /// Чи є рік цієї дати високосним.
  bool get isLeapYear {
    final y = year;
    return (y % 4 == 0 && y % 100 != 0) || (y % 400 == 0);
  }

  /// Кількість днів у році цієї дати (365 або 366).
  int get daysInYear => isLeapYear ? 366 : 365;

  /// Кількість днів, що залишилось до кінця місяця.
  int get daysRemainingInMonth => daysInMonth - day;

  /// Кількість днів, що залишилось до кінця року.
  int get daysRemainingInYear {
    final lastDay = DateTime(year, 12, 31);
    return lastDay.difference(startOfDay).inDays + 1;
  }

  /// Кількість повних тижнів у місяці.
  int get weeksInMonth => (daysInMonth / 7).ceil();

  // ─── Арифметика дат ───────────────────────────────────────────────

  /// Додає вказану кількість років.
  ///
  /// Якщо дата — 29 лютого високосного року, а цільовий рік не високосний,
  /// поверне 28 лютого.
  DateTime addYears(int years) {
    var targetYear = year + years;
    var targetDay = day;
    if (month == 2 && targetDay == 29 && !_isLeapYear(targetYear)) {
      targetDay = 28;
    }
    return DateTime(targetYear, month, targetDay, hour, minute, second,
        millisecond, microsecond);
  }

  /// Віднімає вказану кількість років.
  DateTime subtractYears(int years) => addYears(-years);

  /// Додає вказану кількість місяців.
  ///
  /// Якщо цільовий день перевищує кількість днів у місяці,
  /// встановлює останній день місяця.
  DateTime addMonths(int months) {
    var totalMonths = year * 12 + (month - 1) + months;
    var targetYear = totalMonths ~/ 12;
    var targetMonth = (totalMonths % 12) + 1;
    var targetDay = day.clamp(1, DateTime(targetYear, targetMonth + 1, 0).day);
    return DateTime(targetYear, targetMonth, targetDay, hour, minute, second,
        millisecond, microsecond);
  }

  /// Віднімає вказану кількість місяців.
  DateTime subtractMonths(int months) => addMonths(-months);

  /// Допоміжний метод перевірки високосного року для довільного року.
  static bool _isLeapYear(int y) =>
      (y % 4 == 0 && y % 100 != 0) || (y % 400 == 0);

  // ─── Сезони ───────────────────────────────────────────────────────

  /// Повертає поточний сезон українською.
  ///
  /// Метеорологічні сезони:
  /// - Зима: грудень–лютий
  /// - Весна: березень–травень
  /// - Літо: червень–серпень
  /// - Осінь: вересень–листопад
  String get seasonUAH {
    if (month == 12 || month <= 2) return 'Зима';
    if (month >= 3 && month <= 5) return 'Весна';
    if (month >= 6 && month <= 8) return 'Літо';
    return 'Осінь';
  }

  /// Повертає поточний сезон англійською.
  String get seasonEN {
    if (month == 12 || month <= 2) return 'Winter';
    if (month >= 3 && month <= 5) return 'Spring';
    if (month >= 6 && month <= 8) return 'Summer';
    return 'Autumn';
  }

  /// Повертає емодзі сезону.
  String get seasonEmoji {
    if (month == 12 || month <= 2) return '❄️';
    if (month >= 3 && month <= 5) return '🌸';
    if (month >= 6 && month <= 8) return '☀️';
    return '🍂';
  }

  // ─── AM/PM та 12-годинний формат ───────────────────────────────────

  /// Чи є час до полудня (AM).
  bool get isAM => hour < 12;

  /// Чи є час після полудня (PM).
  bool get isPM => hour >= 12;

  /// Повертає `"AM"` або `"PM"`.
  String get amPm => hour < 12 ? 'AM' : 'PM';

  /// Форматує час у 12-годинному форматі.
  ///
  /// Приклад: `"2:30 PM"`, `"12:00 AM"`
  String formatTime12Hour() {
    final h = hour % 12;
    final displayHour = h == 0 ? 12 : h;
    final m = minute.toString().padLeft(2, '0');
    return '$displayHour:$m ${amPm}';
  }

  /// Форматує час у 12-годинному форматі із секундами.
  ///
  /// Приклад: `"2:30:45 PM"`
  String formatTime12HourWithSeconds() {
    final h = hour % 12;
    final displayHour = h == 0 ? 12 : h;
    final m = minute.toString().padLeft(2, '0');
    final s = second.toString().padLeft(2, '0');
    return '$displayHour:$m:$s ${amPm}';
  }

  // ─── Компактні та безпечні формати ─────────────────────────────────

  /// Компактний формат без роздільників: `"20250412"`.
  String get formatCompact => formatISODate().replaceAll('-', '');

  /// Компактний формат із часом: `"20250412T143000"`.
  String get formatCompactWithTime {
    return '${formatCompact}T'
        '${hour.toString().padLeft(2, "0")}'
        '${minute.toString().padLeft(2, "0")}'
        '${second.toString().padLeft(2, "0")}';
  }

  /// Формат для використання в іменах файлів: `"2025-04-12_14-30"`.
  String get formatFileName {
    final date = formatISODate();
    final time =
        '${hour.toString().padLeft(2, "0")}-${minute.toString().padLeft(2, "0")}';
    return '${date}_$time';
  }

  /// Сортувальний формат: `"YYYYMMDDHHMMSS"`.
  ///
  /// Приклад: `"20250412143000"`
  String get formatSortable => formatCompactWithTime;

  /// Формат для URL-параметрів: `"2025-04-12"`.
  String get formatUrlParam => formatISODate();

  // ─── Відсоток періоду ─────────────────────────────────────────────

  /// Відсоток пройденого дня (0.0 – 1.0).
  double get dayProgress {
    final totalMinutes = hour * 60 + minute + second / 60.0;
    return totalMinutes / 1440.0;
  }

  /// Відсоток пройденого місяця (0.0 – 1.0).
  double get monthProgress {
    return day / daysInMonth;
  }

  /// Відсоток пройденого року (0.0 – 1.0).
  double get yearProgress {
    return dayOfYear / daysInYear;
  }

  /// Відсоток пройденого тижня (0.0 – 1.0).
  double get weekProgress {
    final dayOfWeek = weekday; // 1 = Mon, 7 = Sun
    final totalMinutes = ((dayOfWeek - 1) * 1440.0) +
        (hour * 60 + minute + second / 60.0);
    return totalMinutes / (7 * 1440.0);
  }

  // ─── Тривалість між датами ────────────────────────────────────────

  /// Повертає опис тривалості між цією датою та [other] українською.
  ///
  /// Приклад: `"3 дні 5 годин"`, `"2 години 30 хвилин"`.
  String durationTo(DateTime other) {
    final diff = other.difference(this).abs();
    final days = diff.inDays;
    final hours = diff.inHours % 24;
    final minutes = diff.inMinutes % 60;

    final parts = <String>[];
    if (days > 0) parts.add('$days ${_pluralDays(days)}');
    if (hours > 0) parts.add('$hours ${_pluralHours(hours)}');
    if (minutes > 0 || parts.isEmpty) {
      parts.add('$minutes ${_pluralMinutes(minutes)}');
    }
    return parts.join(' ');
  }

  /// Повертає компактну тривалість між цією датою та [other].
  ///
  /// Приклад: `"3д 5г 30хв"`.
  String durationToShort(DateTime other) {
    final diff = other.difference(this).abs();
    final days = diff.inDays;
    final hours = diff.inHours % 24;
    final minutes = diff.inMinutes % 60;

    if (days > 0) return '${days}д ${hours}г';
    if (hours > 0) return '${hours}г ${minutes}хв';
    return '${minutes}хв';
  }

  /// Повертає повну тривалість із секундами.
  ///
  /// Приклад: `"3 дні 5 годин 30 хвилин 15 секунд"`.
  String durationToFull(DateTime other) {
    final diff = other.difference(this).abs();
    final days = diff.inDays;
    final hours = diff.inHours % 24;
    final minutes = diff.inMinutes % 60;
    final seconds = diff.inSeconds % 60;

    final parts = <String>[];
    if (days > 0) parts.add('$days ${_pluralDays(days)}');
    if (hours > 0) parts.add('$hours ${_pluralHours(hours)}');
    if (minutes > 0) parts.add('$minutes ${_pluralMinutes(minutes)}');
    if (seconds > 0 || parts.isEmpty) {
      parts.add('$seconds ${_pluralSeconds(seconds)}');
    }
    return parts.join(' ');
  }

  /// Допоміжний метод для множини секунд.
  static String _pluralSeconds(int n) {
    if (n == 1) return 'секунда';
    if (n >= 2 && n <= 4) return 'секунди';
    return 'секунд';
  }

  // ─── Залишок періоду ───────────────────────────────────────────────

  /// Час до кінця дня у форматі `"HH:MM:SS"`.
  String get timeToEndOfDay {
    final remaining = endOfDay.difference(this);
    final h = remaining.inHours;
    final m = remaining.inMinutes % 60;
    final s = remaining.inSeconds % 60;
    return '${h.toString().padLeft(2, "0")}:'
        '${m.toString().padLeft(2, "0")}:'
        '${s.toString().padLeft(2, "0")}';
  }

  /// Кількість секунд до кінця дня.
  int get secondsToEndOfDay => endOfDay.difference(this).inSeconds;

  /// Кількість хвилин до кінця дня.
  int get minutesToEndOfDay => endOfDay.difference(this).inMinutes;

  /// Кількість годин до кінця дня.
  int get hoursToEndOfDay => endOfDay.difference(this).inHours;

  // ─── Порядковий день тижня в місяці ───────────────────────────────

  /// Який це по рахунку [targetWeekday] у поточному місяці (1-based).
  ///
  /// Приклад: якщо сьогодні другий вівторок місяця, поверне 2.
  int nthWeekdayInMonth(int targetWeekday) {
    if (weekday != targetWeekday) return 0;
    return ((day - 1) ~/ 7) + 1;
  }

  /// Чи є ця дата останнім [targetWeekday] у місяці.
  ///
  /// Приклад: `date.isLastWeekdayInMonth(DateTime.tuesday)` → `true/false`.
  bool isLastWeekdayInMonth(int targetWeekday) {
    if (weekday != targetWeekday) return false;
    final lastDay = DateTime(year, month + 1, 0);
    return lastDay.day - day < 7;
  }

  /// Дата наступного [targetWeekday] у цьому ж місяці.
  ///
  /// Повертає `null`, якщо немає наступного такого дня тижня в цьому місяці.
  DateTime? nextWeekdayInMonth(int targetWeekday) {
    final daysLeft = daysInMonth - day;
    for (var i = 1; i <= daysLeft; i++) {
      final candidate = add(Duration(days: i));
      if (candidate.weekday == targetWeekday) return candidate;
    }
    return null;
  }

  // ─── Китайський зодіак ────────────────────────────────────────────

  /// Повертає китайський знак зодіаку.
  ///
  /// Приклад: `"Важка Свиня"`, `"Зелений Дракон"`.
  String get chineseZodiac {
    const animals = [
      'Мавпа', 'Півень', 'Собака', 'Свиня', 'Щур', 'Бик',
      'Тигр', 'Кролик', 'Дракон', 'Змія', 'Кінь', 'Коза',
    ];
    const elements = ['Метал', 'Вода', 'Дерево', 'Вогонь', 'Земля'];
    const elementEmojis = ['🪙', '💧', '🌿', '🔥', '🪨'];

    final index = (year - 4) % 12;
    final elementIndex = (year - 4) % 10 ~/ 2;
    final animal = animals[index];
    final element = elements[elementIndex];
    return '$element $animal';
  }

  /// Емодзі китайського зодіаку.
  String get chineseZodiacEmoji {
    const animals = ['🐒', '🐓', '🐕', '🐖', '🐀', '🐂', '🐅', '🐇', '🐉', '🐍', '🐴', '🐑'];
    final index = (year - 4) % 12;
    return animals[index];
  }

  // ─── Вік у різних одиницях ────────────────────────────────────────

  /// Вік у повних днях від цієї дати до сьогодні.
  int ageInDays({DateTime? referenceDate}) {
    final now = referenceDate ?? DateTime.now();
    return now.startOfDay.difference(startOfDay).inDays;
  }

  /// Вік у повних тижнях від цієї дати до сьогодні.
  int ageInWeeks({DateTime? referenceDate}) {
    return ageInDays(referenceDate: referenceDate) ~/ 7;
  }

  /// Вік у повних годинах від цієї дати до сьогодні.
  int ageInHours({DateTime? referenceDate}) {
    final now = referenceDate ?? DateTime.now();
    return now.difference(this).inHours;
  }

  /// Вік у повних хвилинах від цієї дати до сьогодні.
  int ageInMinutes({DateTime? referenceDate}) {
    final now = referenceDate ?? DateTime.now();
    return now.difference(this).inMinutes;
  }

  /// Повертає віковий діапазон українською.
  ///
  /// Приклад: `"дитина"`, `"підліток"`, `"дорослий"`, `"пенсіонер"`.
  String ageCategory({DateTime? referenceDate}) {
    final a = age(referenceDate: referenceDate);
    if (a < 1) return 'немовля';
    if (a < 3) return 'малюк';
    if (a < 7) return 'дитина';
    if (a < 13) return 'школяр';
    if (a < 18) return 'підліток';
    if (a < 30) return 'молода людина';
    if (a < 55) return 'дорослий';
    if (a < 65) return 'людина середнього віку';
    return 'пенсіонер';
  }

  // ─── Англомовні формати ────────────────────────────────────────────

  /// Форматує дату англійською: `"April 12, 2025"`.
  String formatEN() {
    return '$monthEN $day, $year';
  }

  /// Короткий англійський формат: `"Apr 12, 2025"`.
  String formatShortEN() {
    return '$monthShortEN $day, $year';
  }

  /// Англійська назва дня тижня.
  ///
  /// Приклад: `"Monday"`, `"Saturday"`.
  String get weekdayEN {
    const days = [
      '', 'Monday', 'Tuesday', 'Wednesday', 'Thursday',
      'Friday', 'Saturday', 'Sunday',
    ];
    return days[weekday] ?? '';
  }

  /// Скорочена англійська назва дня тижня.
  ///
  /// Приклад: `"Mon"`, `"Sat"`.
  String get weekdayShortEN {
    const days = [
      '', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun',
    ];
    return days[weekday] ?? '';
  }

  /// Англійський відносний час.
  ///
  /// Приклад: `"2 days ago"`, `"in 3 hours"`.
  String relativeENFull({DateTime? now}) {
    final reference = now ?? DateTime.now();
    final diff = reference.difference(this);

    if (diff.inSeconds < 60) return 'just now';
    if (diff.inMinutes < 60) {
      final m = diff.inMinutes;
      return m == 1 ? '1 minute ago' : '$m minutes ago';
    }
    if (diff.inHours < 24) {
      final h = diff.inHours;
      return h == 1 ? '1 hour ago' : '$h hours ago';
    }
    if (diff.inDays == 1) return 'yesterday';
    if (diff.inDays < 7) {
      final d = diff.inDays;
      return d == 1 ? '1 day ago' : '$d days ago';
    }
    if (diff.inDays < 30) {
      final w = diff.inDays ~/ 7;
      return w == 1 ? '1 week ago' : '$w weeks ago';
    }
    final mo = diff.inDays ~/ 30;
    return mo == 1 ? '1 month ago' : '$mo months ago';
  }

  /// Транзакційна дата англійською.
  ///
  /// Приклад: `"Today"`, `"Yesterday"`, `"April 12"`.
  String formatTransactionDateEN() {
    if (isToday) return 'Today';
    if (isYesterday) return 'Yesterday';
    if (isThisYear) return '$monthEN $day';
    return '$monthEN $day, $year';
  }

  // ─── Юліанський день ──────────────────────────────────────────────

  /// Юліанський день (Julian Day Number).
  ///
  /// Кількість днів з 1 січня 4713 до н.е. (юліанський календар).
  int get julianDayNumber {
    var y = year;
    var m = month;
    if (m <= 2) {
      y--;
      m += 12;
    }
    final a = y ~/ 100;
    final b = 2 - a + a ~/ 4;
    return (365.25 * (y + 4716)).floor() +
        (30.6001 * (m + 1)).floor() +
        day +
        b -
        1524;
  }

  // ─── Валідація ─────────────────────────────────────────────────────

  /// Чи є дата валідною (в межах розумного діапазону).
  ///
  /// Вважається валідною, якщо рік від 1900 до 2200.
  bool get isValidDate => year >= 1900 && year <= 2200;

  /// Чи є дата в минулому (строго до цього моменту).
  bool get isDistantPast => year < 2000;

  /// Чи є дата в далекому майбутньому.
  bool get isDistantFuture => year > 2100;

  /// Чи є час опівніччю (00:00:00).
  bool get isMidnight => hour == 0 && minute == 0 && second == 0 && millisecond == 0;

  /// Чи є час полуднем (12:00:00).
  bool get isNoon => hour == 12 && minute == 0 && second == 0 && millisecond == 0;

  // ─── Приватні методи ──────────────────────────────────────────────

  /// Допоміжний метод для множини днів.
  ///
  /// [n] — кількість днів.
  static String _pluralDays(int n) {
    if (n == 1) return 'день';
    if (n >= 2 && n <= 4) return 'дні';
    return 'днів';
  }

  /// Допоміжний метод для множини годин.
  ///
  /// [n] — кількість годин.
  static String _pluralHours(int n) {
    if (n == 1) return 'година';
    if (n >= 2 && n <= 4) return 'години';
    return 'годин';
  }

  /// Допоміжний метод для множини хвилин.
  ///
  /// [n] — кількість хвилин.
  static String _pluralMinutes(int n) {
    if (n == 1) return 'хвилина';
    if (n >= 2 && n <= 4) return 'хвилини';
    return 'хвилин';
  }

  /// Повертає дати державних свят України за [year].
  static List<DateTime> _ukrainianHolidays(int year) {
    return _ukrainianHolidaysMap(year).keys.toList();
  }

  /// Повертає карту дат → назва свят України.
  ///
  /// [year] — рік для визначення дат свят.
  static Map<DateTime, String> _ukrainianHolidaysMap(int year) {
    return {
      DateTime(year, 1, 1): 'Новий рік',
      DateTime(year, 1, 7): 'Різдво Христове',
      DateTime(year, 3, 8): 'Міжнародний жіночий день',
      DateTime(year, 5, 1): 'День праці',
      DateTime(year, 5, 9): 'День перемоги',
      DateTime(year, 6, 28): 'День Конституції',
      DateTime(year, 8, 24): 'День незалежності',
      DateTime(year, 10, 14): 'День захисника України',
      DateTime(year, 12, 25): 'Різдво (католицьке)',
    };
  }
}
