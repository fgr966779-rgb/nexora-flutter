/// Токени відступів та пресети EdgeInsets для додатку Nexora.
///
/// Два рівні абстракції:
/// 1. **Базові значення** — шкала на основі 4-px сітки в класі [Spacing].
/// 2. **Пресети EdgeInsets** — загальноприйняті патерни в [EdgeInsetsSpacing].
/// 3. **Адаптивні помічники** — методи для різних розмірів екрана.
/// 4. **Помічники безпечної зони** — обробка виїмок, клавіатури, системного UI.
/// 5. **Кастомні помічники** — для специфічних патернів UI.
/// 6. **Розширення** — extension methods для double та EdgeInsets.
library;

import 'dart:math';

import 'package:flutter/material.dart';

// ═══════════════════════════════════════════════════════════════════════════
// Базові значення відступів (Spacing Tokens)
// ═══════════════════════════════════════════════════════════════════════════

/// Клас із статичними константами відступів на основі 4-піксельної сітки.
///
/// Всі значення кратні 2 для чіткого рендерингу на будь-якій щільності.
/// Використовуйте ці токени замість "магічних чисел" для консистентності.
///
/// Приклад:
/// ```dart
/// Padding(padding: EdgeInsets.all(Spacing.base))
/// SizedBox(height: Spacing.sectionGap)
/// ```
class Spacing {
  Spacing._();

  // ═══════════════════════════════════════════════════════════════════════
  // Базова сітка 4-px (Base 4-px Grid Scale)
  // ═══════════════════════════════════════════════════════════════════════

  /// 2 px — тонка лінія-розділювач, мінімальний відступ.
  static const double xxs = 2.0;

  /// 4 px — щільний рядковий відступ.
  static const double xs = 4.0;

  /// 6 px — мікро-проміжок.
  static const double xxsMd = 6.0;

  /// 8 px — стандартний компактний проміжок.
  static const double sm = 8.0;

  /// 10 px — проміжок між іконкою та підписом.
  static const double smMd = 10.0;

  /// 12 px — середній проміжок між елементами.
  static const double md = 12.0;

  /// 14 px — трохи більше за середній.
  static const double mdLg = 14.0;

  /// 16 px — базовий layout-відступ.
  static const double base = 16.0;

  /// 18 px — комфортний малий проміжок.
  static const double lgMd = 18.0;

  /// 20 px — комфортний секційний проміжок.
  static const double lg = 20.0;

  /// 22 px — між lg та xl.
  static const double lgXl = 22.0;

  /// 24 px — великий секційний розділювач.
  static const double xl = 24.0;

  /// 28 px — дуже великий секційний розділювач.
  static const double xlXxl = 28.0;

  /// 32 px — дуже великий проміжок (рівень сторінки).
  static const double xxl = 32.0;

  /// 40 px — надвеликий проміжок.
  static const double xxxl = 40.0;

  /// 48 px — мажорний вертикальний розділювач.
  static const double huge = 48.0;

  /// 56 px — hero-рівневий проміжок.
  static const double massive = 56.0;

  /// 64 px — над-hero вертикальний проміжок.
  static const double ultra = 64.0;

  /// 72 px — екстремально великий проміжок для повноекранних секцій.
  static const double extreme = 72.0;

  /// 80 px — максимальний вертикальний проміжок.
  static const double maximum = 80.0;

  /// 96 px — для величезних gap-ів між незалежними секціями.
  static const double colossal = 96.0;

  /// 120 px — для повноекранних hero-розділювачів.
  static const double hero = 120.0;

  // ═══════════════════════════════════════════════════════════════════════
  // Семантичні токени layout (Semantic Layout Tokens)
  // ═══════════════════════════════════════════════════════════════════════

  /// Горизонтальний відступ сторінки.
  static const double pageHorizontal = 20.0;

  /// Горизонтальний відступ сторінки для компактних екранів.
  static const double pageHorizontalCompact = 16.0;

  /// Горизонтальний відступ сторінки для планшетів.
  static const double pageHorizontalTablet = 32.0;

  /// Горизонтальний відступ сторінки для десктопу.
  static const double pageHorizontalDesktop = 48.0;

  /// Вертикальний проміжок між основними секціями дашборду.
  static const double sectionGap = 24.0;

  /// Внутрішній відступ для карток цілей / транзакцій.
  static const double cardPadding = 16.0;

  /// Вертикальний відступ всередині карток.
  static const double cardPaddingVertical = 14.0;

  /// Внутрішній відступ для компактних карток.
  static const double cardPaddingCompact = 12.0;

  /// Проміжок між елементами у вертикальному списку.
  static const double listGap = 12.0;

  /// Проміжок між елементами у сітці.
  static const double gridGap = 12.0;

  /// Малий проміжок між іконкою та її текстовою міткою.
  static const double iconTextGap = 8.0;

  /// Горизонтальний внутрішній відступ для кнопок.
  static const double buttonPaddingHorizontal = 20.0;

  /// Вертикальний внутрішній відступ для кнопок.
  static const double buttonPaddingVertical = 12.0;

  /// Мінімальний відступ навколо FAB.
  static const double fabMargin = 16.0;

  /// Стандартна висота app-bar.
  static const double appBarHeight = 56.0;

  /// Висота нижньої панелі навігації.
  static const double bottomNavHeight = 64.0;

  /// Запасний відступ зверху безпечної зони.
  static const double safeAreaTop = 48.0;

  /// Проміжок між стекованими бейджами / чіпами.
  static const double chipGap = 8.0;

  /// Внутрішній відступ для модального вікна / діалогу.
  static const double modalBodyPadding = 24.0;

  /// Верхній відступ drag-handle нижнього листа.
  static const double bottomSheetHandleTop = 12.0;

  /// Горизонтальний відступ для toast / snackbar.
  static const double toastMargin = 16.0;

  /// Горизонтальний відступ аватара у списках.
  static const double avatarPadding = 12.0;

  /// Внутрішній відступ для поля вводу.
  static const double inputPadding = 14.0;

  /// Padding для вмісту текстового поля.
  static const double textFieldPadding = 16.0;

  /// Висота розділювача з відступами.
  static const double dividerSpacing = 16.0;

  /// Нижній відступ для заголовка секції.
  static const double sectionTitleMargin = 12.0;

  /// Внутрішній відступ для картки сповіщення.
  static const double notificationPadding = 16.0;

  /// Внутрішній відступ для діалогу.
  static const double dialogPadding = 24.0;

  /// Висота панелі вкладок.
  static const double tabBarHeight = 48.0;

  /// Розгорнута висота SliverAppBar.
  static const double sliverExpandedHeight = 200.0;

  /// Внутрішній відступ для чіпу.
  static const double chipPadding = 8.0;

  /// Внутрішній відступ для DatePicker.
  static const double datePickerPadding = 16.0;

  /// Внутрішній відступ для області графіку.
  static const double chartPadding = 16.0;

  /// Проміжок між елементами таймлайну.
  static const double timelineItemGap = 16.0;

  /// Внутрішній відступ для stepper-кроку.
  static const double stepperPadding = 24.0;

  /// Відстань зсуву тіні картки.
  static const double cardShadowOffset = 4.0;

  /// Внутрішній відступ для bottomsheet кнопок дії.
  static const double bottomSheetButtonPadding = 14.0;

  /// Мінімальна ширина торкання для кнопок.
  static const double touchTargetMin = 44.0;

  /// Відступ для іконки всередині кнопки.
  static const double iconButtonPadding = 8.0;

  /// Горизонтальний відступ для рядків таблиці.
  static const double tableRowPadding = 12.0;

  /// Відступ між елементами форми.
  static const double formFieldGap = 16.0;

  /// Відступ між групами полів форми.
  static const double formGroupGap = 24.0;

  // ═══════════════════════════════════════════════════════════════════════
  // Додаткові семантичні токени (Extended Semantic Tokens)
  // ═══════════════════════════════════════════════════════════════════════

  /// Відступ для горизонтального scrolling чіпу.
  static const double chipScrollPadding = 8.0;

  /// Відступ для horizontal page indicator dots.
  static const double pageIndicatorPadding = 16.0;

  /// Відступ для circular progress indicator.
  static const double progressIndicatorPadding = 8.0;

  /// Gap для Stepper icon area.
  static const double stepperIconPadding = 12.0;

  /// Внутрішній відступ для календарної комірки.
  static const double calendarCellPadding = 4.0;

  /// Gap між картками в шопі.
  static const double shopCardGap = 16.0;

  /// Gap між елементами лідерборду.
  static const double leaderboardItemGap = 8.0;

  /// Gap між items в horizontal scrolling goals.
  static const double goalsScrollGap = 12.0;

  /// Відступ для badge position (top-right offset).
  static const double badgeOffset = 6.0;

  /// Відстань від centre до edge для toast positioning.
  static const double toastBottomMargin = 24.0;

  /// Gap між elements in a wrap widget.
  static const double wrapGap = 8.0;

  /// Gap для chart legend items.
  static const double chartLegendGap = 16.0;

  /// Gap для chart axis labels.
  static const double chartAxisLabelPadding = 4.0;

  /// Відступ для dropdown overlay from trigger.
  static const double dropdownOverlayOffset = 4.0;

  /// Gap між toggle buttons в a ToggleButtons row.
  static const double toggleButtonGap = 0.0;

  /// Відступ для search bar trailing icon.
  static const double searchTrailingPadding = 12.0;

  /// Відступ для navigation rail item.
  static const double navRailItemPadding = 12.0;

  /// Gap між cards в Masonry grid.
  static const double masonryGridGap = 12.0;

  /// Gap для Timeline connector line length.
  static const double timelineConnectorLength = 24.0;

  /// Відступ для SliverList separator.
  static const double sliverSeparatorHeight = 1.0;

  /// Відступ для modal content max width constraint (desktop).
  static const double modalMaxWidth = 560.0;

  /// Відступ для dialog max width constraint.
  static const double dialogMaxWidth = 400.0;

  /// Gap для expansion tile children indent.
  static const double expansionTileIndent = 16.0;

  /// Відступ для hero widget padding.
  static const double heroPadding = 0.0;

  /// Gap для segmented control internal spacing.
  static const double segmentedControlPadding = 8.0;

  /// Відступ для tab bar in collapsed AppBar.
  static const double collapsedTabBarPadding = 12.0;

  // ═══════════════════════════════════════════════════════════════════════
  // Допоміжні методи (Helper Methods)
  // ═══════════════════════════════════════════════════════════════════════

  /// Повертає відступ між елементами у каскадному списку.
  ///
  /// [index] — індекс елемента (починаючи з 0).
  /// [stagger] — базова затримка між елементами (за замовчуванням 8).
  static double staggered(int index, {double stagger = 8.0}) {
    return index * stagger;
  }

  /// Масштабує відступ залежно від ширини екрана.
  ///
  /// [value] — базове значення відступу.
  /// [screenWidth] — поточна ширина екрана.
  /// [baseWidth] — базова ширина (за замовчуванням 375).
  static double responsiveScale(
    double value,
    double screenWidth, {
    double baseWidth = 375,
  }) {
    final scale = (screenWidth / baseWidth).clamp(0.85, 1.3);
    return value * scale;
  }

  /// Повертає горизонтальний відступ сторінки залежно від ширини екрана.
  ///
  /// [screenWidth] — поточна ширина екрана.
  static double responsivePageHorizontal(double screenWidth) {
    if (screenWidth >= 1024) return pageHorizontalDesktop;
    if (screenWidth >= 600) return pageHorizontalTablet;
    return pageHorizontal;
  }

  /// Повертає відступ з урахуванням клавіатури.
  ///
  /// [viewInsetsBottom] — висота клавіатури.
  /// [additionalPadding] — додатковий відступ (за замовчуванням 16).
  static double keyboardAware(
    double viewInsetsBottom, {
    double additionalPadding = 16.0,
  }) {
    if (viewInsetsBottom > 0) {
      return viewInsetsBottom + additionalPadding;
    }
    return 0.0;
  }

  /// Повертає мінімум між двома значеннями відступів.
  static double min(double a, double b) => a < b ? a : b;

  /// Повертає максимум між двома значеннями відступів.
  static double max(double a, double b) => a > b ? a : b;

  /// Обмежує значення відступу в межах [minVal] та [maxVal].
  static double clamp(double value, double minVal, double maxVal) {
    return value.clamp(minVal, maxVal);
  }

  /// Повертає значення найближчого кратного [grid].
  ///
  /// [value] — значення для округлення.
  /// [grid] — розмір сітки (за замовчуванням 4).
  static double snapToGrid(double value, {double grid = 4.0}) {
    return (value / grid).round() * grid;
  }

  /// Обчислює вертикальний відступ для списку з фіксованим заголовком.
  ///
  /// [headerHeight] — висота заголовка.
  /// [itemCount] — кількість елементів.
  /// [itemHeight] — висота одного елемента.
  /// [availableHeight] — доступна висота.
  static double listVerticalSpacing({
    required double headerHeight,
    required int itemCount,
    required double itemHeight,
    required double availableHeight,
  }) {
    final used = headerHeight + (itemCount * itemHeight);
    final remaining = availableHeight - used;
    return remaining.clamp(0.0, maximum);
  }

  /// Обчислює відступ для центрування елемента по вертикалі.
  ///
  /// [containerHeight] — висота контейнера.
  /// [elementHeight] — висота елемента.
  static double verticalCenter(double containerHeight, double elementHeight) {
    return (containerHeight - elementHeight) / 2;
  }

  /// Обчислює відступ для центрування елемента по горизонталі.
  ///
  /// [containerWidth] — ширина контейнера.
  /// [elementWidth] — ширина елемента.
  static double horizontalCenter(double containerWidth, double elementWidth) {
    return (containerWidth - elementWidth) / 2;
  }

  /// Обчислює maxWidth контенту для адаптивного layout.
  ///
  /// Повертає мінімум між шириною екрана та максимальною шириною контенту.
  static double contentMaxWidth(double screenWidth, {double maxWidth = 600.0}) {
    return min(screenWidth, maxWidth);
  }

  /// Генерує список відступів для N-елементного каскадного списку.
  ///
  /// [count] — кількість елементів.
  /// [baseGap] — базовий проміжок (за замовчуванням 8).
  static List<double> staggeredList(int count, {double baseGap = 8.0}) {
    return List.generate(count, (i) => staggered(i, stagger: baseGap));
  }

  /// Валідація: перевіряє, чи відступ не є від'ємним.
  ///
  /// Повертає 0.0 якщо значення від'ємне.
  static double validateNonNegative(double value) {
    assert(value >= 0, 'Відступ не може бути від\'ємним: $value');
    return value < 0 ? 0.0 : value;
  }

  /// Повертає опис відступу для дебагу.
  static String debugSpacing(double value) {
    return 'Відступ: ${value.toStringAsFixed(1)}px';
  }

  /// Повертає всі семантичні назви та їх значення для дебагу.
  static Map<String, double> debugMap() {
    return {
      'xxs': xxs,
      'xs': xs,
      'sm': sm,
      'md': md,
      'base': base,
      'lg': lg,
      'xl': xl,
      'xxl': xxl,
      'xxxl': xxxl,
      'huge': huge,
      'massive': massive,
      'ultra': ultra,
      'pageHorizontal': pageHorizontal,
      'sectionGap': sectionGap,
      'cardPadding': cardPadding,
      'listGap': listGap,
    };
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Пресети EdgeInsets (EdgeInsets Presets)
// ═══════════════════════════════════════════════════════════════════════════

/// Попередньо створені значення [EdgeInsets] на основі токенів [Spacing].
///
/// Використовуйте ці пресети замість `EdgeInsets.all(16)` для консистентності.
class EdgeInsetsSpacing {
  EdgeInsetsSpacing._();

  // ═══════════════════════════════════════════════════════════════════════
  // Сторінка та картки (Page & Card)
  // ═══════════════════════════════════════════════════════════════════════

  /// `EdgeInsets.symmetric(horizontal: 20)` — відступ сторінки.
  static const EdgeInsets pageHorizontal =
      EdgeInsets.symmetric(horizontal: Spacing.pageHorizontal);

  /// `EdgeInsets.all(16)` — стандартний відступ картки.
  static const EdgeInsets card = EdgeInsets.all(Spacing.cardPadding);

  /// `EdgeInsets.symmetric(horizontal: 16, vertical: 14)` — асиметрична картка.
  static const EdgeInsets cardAsymmetric = EdgeInsets.symmetric(
    horizontal: Spacing.cardPadding,
    vertical: Spacing.cardPaddingVertical,
  );

  /// `EdgeInsets.all(12)` — компактна картка / list tile.
  static const EdgeInsets cardSm = EdgeInsets.all(Spacing.listGap);

  /// `EdgeInsets.all(12)` — компактна картка (зменшена).
  static const EdgeInsets cardCompact =
      EdgeInsets.all(Spacing.cardPaddingCompact);

  // ═══════════════════════════════════════════════════════════════════════
  // Чіпси, бейджі, іконки (Chips, Badges, Icons)
  // ═══════════════════════════════════════════════════════════════════════

  /// `EdgeInsets.all(8)` — чіп / бейдж внутрішній відступ.
  static const EdgeInsets chip = EdgeInsets.all(Spacing.sm);

  /// `EdgeInsets.all(8)` — відступ ікон-кнопки.
  static const EdgeInsets iconButton = EdgeInsets.all(Spacing.sm);

  /// `EdgeInsets.symmetric(horizontal: 16, vertical: 8)` — мітка з іконкою.
  static const EdgeInsets labelWithIcon = EdgeInsets.symmetric(
    horizontal: Spacing.cardPadding,
    vertical: Spacing.sm,
  );

  // ═══════════════════════════════════════════════════════════════════════
  // Модальні вікна та діалоги (Modals & Dialogs)
  // ═══════════════════════════════════════════════════════════════════════

  /// `EdgeInsets.all(24)` — тіло модального вікна / діалогу.
  static const EdgeInsets modalBody =
      EdgeInsets.all(Spacing.modalBodyPadding);

  /// `EdgeInsets.only(top: 12)` — область рукоятки нижнього листа.
  static const EdgeInsets bottomSheetHandle =
      EdgeInsets.only(top: Spacing.bottomSheetHandleTop);

  /// `EdgeInsets.all(12)` — контент діалогу.
  static const EdgeInsets dialogContent =
      EdgeInsets.all(Spacing.listGap);

  /// `EdgeInsets.fromLTRB(24, 24, 24, 16)` — тіло діалогу з меншим низом.
  static const EdgeInsets dialogBody = EdgeInsets.fromLTRB(
    Spacing.xl,
    Spacing.xl,
    Spacing.xl,
    Spacing.cardPadding,
  );

  /// `EdgeInsets.symmetric(horizontal: 16, vertical: 24)` — заголовок модалки.
  static const EdgeInsets modalHeader = EdgeInsets.symmetric(
    horizontal: Spacing.cardPadding,
    vertical: Spacing.xl,
  );

  // ═══════════════════════════════════════════════════════════════════════
  // Кнопки (Buttons)
  // ═══════════════════════════════════════════════════════════════════════

  /// `EdgeInsets.symmetric(horizontal: 20, vertical: 12)` — inset кнопки.
  static const EdgeInsets button = EdgeInsets.symmetric(
    horizontal: Spacing.buttonPaddingHorizontal,
    vertical: Spacing.buttonPaddingVertical,
  );

  /// `EdgeInsets.symmetric(horizontal: 12, vertical: 8)` — компактна кнопка.
  static const EdgeInsets buttonSm = EdgeInsets.symmetric(
    horizontal: Spacing.listGap,
    vertical: Spacing.sm,
  );

  /// `EdgeInsets.symmetric(horizontal: 24, vertical: 16)` — велика кнопка.
  static const EdgeInsets buttonLg = EdgeInsets.symmetric(
    horizontal: Spacing.xl,
    vertical: Spacing.cardPadding,
  );

  /// `EdgeInsets.symmetric(horizontal: 32, vertical: 18)` — екстра-велика кнопка.
  static const EdgeInsets buttonXl = EdgeInsets.symmetric(
    horizontal: Spacing.xxl,
    vertical: Spacing.lgMd,
  );

  /// `EdgeInsets.symmetric(horizontal: 8, vertical: 4)` — міні кнопка.
  static const EdgeInsets buttonXs = EdgeInsets.symmetric(
    horizontal: Spacing.sm,
    vertical: Spacing.xs,
  );

  // ═══════════════════════════════════════════════════════════════════════
  // Поля вводу (Input Fields)
  // ═══════════════════════════════════════════════════════════════════════

  /// `EdgeInsets.symmetric(horizontal: 20)` — горизонтальний відступ поля вводу.
  static const EdgeInsets inputHorizontal =
      EdgeInsets.symmetric(horizontal: Spacing.pageHorizontal);

  /// `EdgeInsets.symmetric(horizontal: 16, vertical: 12)` — повний відступ поля вводу.
  static const EdgeInsets input = EdgeInsets.symmetric(
    horizontal: Spacing.cardPadding,
    vertical: Spacing.listGap,
  );

  /// `EdgeInsets.symmetric(horizontal: 16, vertical: 16)` — великий відступ поля.
  static const EdgeInsets inputLg = EdgeInsets.all(Spacing.cardPadding);

  // ═══════════════════════════════════════════════════════════════════════
  // Списки та секції (Lists & Sections)
  // ═══════════════════════════════════════════════════════════════════════

  /// `EdgeInsets.symmetric(horizontal: 16)` — відступ заголовка секції.
  static const EdgeInsets sectionHeader =
      EdgeInsets.symmetric(horizontal: Spacing.cardPadding);

  /// `EdgeInsets.all(12)` — відступ контенту list tile.
  static const EdgeInsets listTile = EdgeInsets.all(Spacing.listGap);

  /// `EdgeInsets.all(24)` — просторий секційний відступ.
  static const EdgeInsets section = EdgeInsets.all(Spacing.xl);

  /// `EdgeInsets.all(8)` — компактний внутрішній відступ.
  static const EdgeInsets compact = EdgeInsets.all(Spacing.sm);

  /// `EdgeInsets.all(4)` — щільний внутрішній відступ.
  static const EdgeInsets tight = EdgeInsets.all(Spacing.xs);

  /// `EdgeInsets.all(2)` — тонкий внутрішній відступ.
  static const EdgeInsets hairline = EdgeInsets.all(Spacing.xxs);

  // ═══════════════════════════════════════════════════════════════════════
  // Однобічні відступи (One-Sided Insets)
  // ═══════════════════════════════════════════════════════════════════════

  /// `EdgeInsets.only(top: 24)` — верхній секційний відступ.
  static const EdgeInsets sectionTop = EdgeInsets.only(top: Spacing.xl);

  /// `EdgeInsets.only(bottom: 16)` — нижній секційний відступ.
  static const EdgeInsets sectionBottom =
      EdgeInsets.only(bottom: Spacing.base);

  /// `EdgeInsets.only(left: 16)` — відступ контенту зліва.
  static const EdgeInsets contentLeft =
      EdgeInsets.only(left: Spacing.cardPadding);

  /// `EdgeInsets.only(right: 16)` — відступ контенту справа.
  static const EdgeInsets contentRight =
      EdgeInsets.only(right: Spacing.cardPadding);

  /// `EdgeInsets.only(left: 8, right: 8)` — симетричний горизонтальний компактний.
  static const EdgeInsets horizontalSm =
      EdgeInsets.symmetric(horizontal: Spacing.sm);

  /// `EdgeInsets.only(top: 8, bottom: 8)` — симетричний вертикальний компактний.
  static const EdgeInsets verticalSm =
      EdgeInsets.symmetric(vertical: Spacing.sm);

  // ═══════════════════════════════════════════════════════════════════════
  // Комбіновані відступи (Combined Insets)
  // ═══════════════════════════════════════════════════════════════════════

  /// `EdgeInsets.symmetric(horizontal: 20, vertical: 16)` — сторінка з вертикаллю.
  static const EdgeInsets pageWithVertical = EdgeInsets.symmetric(
    horizontal: Spacing.pageHorizontal,
    vertical: Spacing.cardPadding,
  );

  /// `EdgeInsets.fromLTRB(16, 8, 16, 0)` — відступ заголовка картки.
  static const EdgeInsets cardHeader = EdgeInsets.fromLTRB(
    Spacing.cardPadding,
    Spacing.sm,
    Spacing.cardPadding,
    0,
  );

  /// `EdgeInsets.fromLTRB(16, 0, 16, 16)` — відступ тіла картки.
  static const EdgeInsets cardBody = EdgeInsets.fromLTRB(
    Spacing.cardPadding,
    0,
    Spacing.cardPadding,
    Spacing.cardPadding,
  );

  /// `EdgeInsets.fromLTRB(16, 12, 16, 8)` — відступ картки з футером.
  static const EdgeInsets cardWithFooter = EdgeInsets.fromLTRB(
    Spacing.cardPadding,
    Spacing.listGap,
    Spacing.cardPadding,
    Spacing.sm,
  );

  /// `EdgeInsets.fromLTRB(8, 16, 8, 16)` — відступ бічної панелі.
  static const EdgeInsets sidePanel = EdgeInsets.fromLTRB(
    Spacing.sm,
    Spacing.cardPadding,
    Spacing.sm,
    Spacing.cardPadding,
  );

  // ═══════════════════════════════════════════════════════════════════════
  // Специфічні відступи (Specific Insets)
  // ═══════════════════════════════════════════════════════════════════════

  /// `EdgeInsets.symmetric(horizontal: 16)` — відступ toast/snackbar.
  static const EdgeInsets toastMargin =
      EdgeInsets.symmetric(horizontal: Spacing.toastMargin);

  /// `EdgeInsets.all(16)` — відступ сповіщення.
  static const EdgeInsets notification =
      EdgeInsets.all(Spacing.cardPadding);

  /// `EdgeInsets.all(16)` — відступ для avatar container.
  static const EdgeInsets avatar = EdgeInsets.all(Spacing.cardPadding);

  /// `EdgeInsets.all(4)` — відступ для badge overlay.
  static const EdgeInsets badgeOverlay = EdgeInsets.all(Spacing.xs);

  /// `EdgeInsets.all(8)` — відступ для progress indicator container.
  static const EdgeInsets progressContainer = EdgeInsets.all(Spacing.sm);

  /// `EdgeInsets.symmetric(horizontal: 16, vertical: 8)` — відступ для dropdown.
  static const EdgeInsets dropdownItem = EdgeInsets.symmetric(
    horizontal: Spacing.cardPadding,
    vertical: Spacing.sm,
  );

  // ═══════════════════════════════════════════════════════════════════════
  // Адаптивні методи EdgeInsets (Responsive Edge Inset Methods)
  // ═══════════════════════════════════════════════════════════════════════

  /// Повертає горизонтальний відступ сторінки залежно від ширини екрана.
  static EdgeInsets responsivePageHorizontal(double screenWidth) {
    final h = Spacing.responsivePageHorizontal(screenWidth);
    return EdgeInsets.symmetric(horizontal: h);
  }

  /// Повертає відступи з урахуванням безпечної зони.
  static EdgeInsets withSafeArea(EdgeInsets safePadding) {
    return EdgeInsets.only(
      top: safePadding.top,
      bottom: safePadding.bottom,
    );
  }

  /// Повертає відступи з урахуванням клавіатури.
  static EdgeInsets keyboardAware(
    EdgeInsets viewInsets, {
    double extra = 16.0,
  }) {
    if (viewInsets.bottom > 0) {
      return EdgeInsets.only(bottom: viewInsets.bottom + extra);
    }
    return EdgeInsets.zero;
  }

  /// Повертає відступи для нижнього листа з урахуванням безпечної зони.
  static EdgeInsets bottomSheetPadding(EdgeInsets safePadding) {
    return EdgeInsets.only(bottom: safePadding.bottom);
  }

  /// Повертає відступи для AppBar з урахуванням статус-бару.
  static EdgeInsets appBarPadding(EdgeInsets safePadding) {
    return EdgeInsets.only(top: safePadding.top);
  }

  /// Повертає відступи для ландшафтної орієнтації.
  static EdgeInsets landscape(EdgeInsets original, bool isLandscape) {
    if (!isLandscape) return original;
    return EdgeInsets.fromLTRB(
      original.left * 1.5,
      original.top * 0.5,
      original.right * 1.5,
      original.bottom * 0.5,
    );
  }

  /// Повертає відступи з додатковим відступом знизу.
  static EdgeInsets withBottomPadding(
    EdgeInsets original, {
    double extraBottom = 16.0,
  }) {
    return EdgeInsets.only(
      left: original.left,
      top: original.top,
      right: original.right,
      bottom: original.bottom + extraBottom,
    );
  }

  /// Повертає відступи, що центрують дочірній елемент.
  static EdgeInsets centeredOverlay({
    required double width,
    required double height,
    required double screenWidth,
    required double screenHeight,
  }) {
    return EdgeInsets.only(
      left: (screenWidth - width) / 2,
      top: (screenHeight - height) / 2,
    );
  }

  /// Повертає відступи для floating action button.
  static EdgeInsets fabPosition({
    required EdgeInsets safePadding,
    double additionalBottom = 0,
  }) {
    return EdgeInsets.only(
      right: Spacing.base,
      bottom: Spacing.base + safePadding.bottom + additionalBottom,
    );
  }

  /// Створює EdgeInsets з вказаним значенням для всіх сторін.
  ///
  /// Зручний factory-метод замість EdgeInsets.all.
  static EdgeInsets all(double value) => EdgeInsets.all(value);

  /// Створює EdgeInsets з симетричними горизонтальними відступами.
  static EdgeInsets horizontal(double value) =>
      EdgeInsets.symmetric(horizontal: value);

  /// Створює EdgeInsets з симетричними вертикальними відступами.
  static EdgeInsets vertical(double value) =>
      EdgeInsets.symmetric(vertical: value);

  /// Створює EdgeInsets з кастомними значеннями для кожної сторони.
  static EdgeInsets custom({
    double left = 0,
    double top = 0,
    double right = 0,
    double bottom = 0,
  }) =>
      EdgeInsets.fromLTRB(left, top, right, bottom);

  /// Додає два EdgeInsets разом (поелементно).
  ///
  /// Корисно для комбінування пресетів.
  static EdgeInsets add(EdgeInsets a, EdgeInsets b) {
    return EdgeInsets.fromLTRB(
      a.left + b.left,
      a.top + b.top,
      a.right + b.right,
      a.bottom + b.bottom,
    );
  }

  /// Віднімає EdgeInsets (поелементно).
  static EdgeInsets subtract(EdgeInsets a, EdgeInsets b) {
    return EdgeInsets.fromLTRB(
      (a.left - b.left).clamp(0, double.infinity),
      (a.top - b.top).clamp(0, double.infinity),
      (a.right - b.right).clamp(0, double.infinity),
      (a.bottom - b.bottom).clamp(0, double.infinity),
    );
  }

  /// Масштабує всі значення EdgeInsets на коефіцієнт.
  static EdgeInsets scale(EdgeInsets insets, double factor) {
    return EdgeInsets.fromLTRB(
      insets.left * factor,
      insets.top * factor,
      insets.right * factor,
      insets.bottom * factor,
    );
  }

  /// Серіалізує EdgeInsets у JSON.
  static Map<String, dynamic> toJson(EdgeInsets insets) => {
        'left': insets.left,
        'top': insets.top,
        'right': insets.right,
        'bottom': insets.bottom,
      };

  /// Десеріалізує EdgeInsets із JSON.
  static EdgeInsets fromJson(Map<String, dynamic> json) => EdgeInsets.fromLTRB(
        (json['left'] as num?)?.toDouble() ?? 0,
        (json['top'] as num?)?.toDouble() ?? 0,
        (json['right'] as num?)?.toDouble() ?? 0,
        (json['bottom'] as num?)?.toDouble() ?? 0,
      );
}

// ═══════════════════════════════════════════════════════════════════════════
// SizedBox пресети (SizedBox Convenience Presets)
// ═══════════════════════════════════════════════════════════════════════════

/// Зручні константи [SizedBox] на основі токенів [Spacing].
///
/// Використовуйте для швидкого створення відступів між віджетами:
/// ```dart
/// Column(
///   children: [
///     Text('Hello'),
///     SpacingBoxes.md,
///     Text('World'),
///   ],
/// )
/// ```
class SpacingBoxes {
  SpacingBoxes._();

  /// Вертикальний відступ 2px.
  static const SizedBox xxs = SizedBox(height: Spacing.xxs);

  /// Вертикальний відступ 4px.
  static const SizedBox xs = SizedBox(height: Spacing.xs);

  /// Вертикальний відступ 6px.
  static const SizedBox xxsMd = SizedBox(height: Spacing.xxsMd);

  /// Вертикальний відступ 8px.
  static const SizedBox sm = SizedBox(height: Spacing.sm);

  /// Вертикальний відступ 10px.
  static const SizedBox smMd = SizedBox(height: Spacing.smMd);

  /// Вертикальний відступ 12px.
  static const SizedBox md = SizedBox(height: Spacing.md);

  /// Вертикальний відступ 14px.
  static const SizedBox mdLg = SizedBox(height: Spacing.mdLg);

  /// Вертикальний відступ 16px.
  static const SizedBox base = SizedBox(height: Spacing.base);

  /// Вертикальний відступ 18px.
  static const SizedBox lgMd = SizedBox(height: Spacing.lgMd);

  /// Вертикальний відступ 20px.
  static const SizedBox lg = SizedBox(height: Spacing.lg);

  /// Вертикальний відступ 22px.
  static const SizedBox lgXl = SizedBox(height: Spacing.lgXl);

  /// Вертикальний відступ 24px.
  static const SizedBox xl = SizedBox(height: Spacing.xl);

  /// Вертикальний відступ 28px.
  static const SizedBox xlXxl = SizedBox(height: Spacing.xlXxl);

  /// Вертикальний відступ 32px.
  static const SizedBox xxl = SizedBox(height: Spacing.xxl);

  /// Вертикальний відступ 40px.
  static const SizedBox xxxl = SizedBox(height: Spacing.xxxl);

  /// Вертикальний відступ 48px.
  static const SizedBox huge = SizedBox(height: Spacing.huge);

  /// Вертикальний відступ 56px.
  static const SizedBox massive = SizedBox(height: Spacing.massive);

  /// Вертикальний відступ 64px.
  static const SizedBox ultra = SizedBox(height: Spacing.ultra);

  /// Горизонтальний відступ 8px.
  static const SizedBox hSm = SizedBox(width: Spacing.sm);

  /// Горизонтальний відступ 12px.
  static const SizedBox hMd = SizedBox(width: Spacing.md);

  /// Горизонтальний відступ 16px.
  static const SizedBox hBase = SizedBox(width: Spacing.base);

  /// Горизонтальний відступ 20px.
  static const SizedBox hLg = SizedBox(width: Spacing.lg);

  /// Горизонтальний відступ 24px.
  static const SizedBox hXl = SizedBox(width: Spacing.xl);

  /// Горизонтальний відступ 32px.
  static const SizedBox hXxl = SizedBox(width: Spacing.xxl);

  /// Створює кастомний вертикальний відступ.
  static SizedBox vertical(double height) => SizedBox(height: height);

  /// Створює кастомний горизонтальний відступ.
  static SizedBox horizontal(double width) => SizedBox(width: width);

  /// Створює відступ з вказаною шириною та висотою.
  static SizedBox custom({double width = 0, double height = 0}) =>
      SizedBox(width: width, height: height);

  /// Створює відступ на основі кількості пропусків сітки.
  ///
  /// [gridSteps] — кількість кроків сітки (кожен 4px).
  static SizedBox fromGridSteps(int gridSteps) =>
      SizedBox(height: gridSteps * 4.0);
}

// ═══════════════════════════════════════════════════════════════════════════
// Розширення (Extensions)
// ═══════════════════════════════════════════════════════════════════════════

/// Розширення для [double] для зручного створення SizedBox.
extension SpacingDoubleExtension on double {
  /// Створює вертикальний SizedBox з цією висотою.
  SizedBox get vertical => SizedBox(height: this);

  /// Створює горизонтальний SizedBox з цією шириною.
  SizedBox get horizontal => SizedBox(width: this);

  /// Округлює до найближчого кратного сітки (4px).
  double snapToGrid({double grid = 4.0}) =>
      (this / grid).round() * grid;

  /// Обмежує значення вказаними межами.
  double clampSpacing({double min = 0.0, double max = 120.0}) =>
      clamp(min, max);
}

/// Розширення для [EdgeInsets] для додаткових операцій.
extension EdgeInsetsExtension on EdgeInsets {
  /// Повертає EdgeInsets з доданим відступом знизу.
  EdgeInsets addBottom(double extra) =>
      EdgeInsets.fromLTRB(left, top, right, bottom + extra);

  /// Повертає EdgeInsets з доданим відступом зверху.
  EdgeInsets addTop(double extra) =>
      EdgeInsets.fromLTRB(left, top + extra, right, bottom);

  /// Повертає EdgeInsets з доданим відступом зліва.
  EdgeInsets addLeft(double extra) =>
      EdgeInsets.fromLTRB(left + extra, top, right, bottom);

  /// Повертає EdgeInsets з доданим відступом справа.
  EdgeInsets addRight(double extra) =>
      EdgeInsets.fromLTRB(left, top, right + extra, bottom);

  /// Повертає загальну горизонтальну ширину (left + right).
  double get horizontalTotal => left + right;

  /// Повертає загальну вертикальну висоту (top + bottom).
  double get verticalTotal => top + bottom;

  /// Масштабує всі значення EdgeInsets на коефіцієнт.
  EdgeInsets scale(double factor) => EdgeInsetsSpacing.scale(this, factor);

  /// Повертає EdgeInsets з нульовими значеннями.
  EdgeInsets get zero => EdgeInsets.zero;

  /// Серіалізує EdgeInsets у JSON.
  Map<String, dynamic> toJson() => EdgeInsetsSpacing.toJson(this);
}

/// Розширення для [BuildContext] для швидкого отримання адаптивних відступів.
extension SpacingContextExtension on BuildContext {
  /// Повертає адаптивний горизонтальний відступ сторінки.
  EdgeInsets get responsivePagePadding =>
      EdgeInsetsSpacing.responsivePageHorizontal(
        MediaQuery.of(this).size.width,
      );

  /// Повертає відступи безпечної зони.
  EdgeInsets get safeAreaPadding => MediaQuery.of(this).padding;

  /// Повертає viewInsets (для клавіатури).
  EdgeInsets get keyboardInsets => MediaQuery.of(this).viewInsets;
}
