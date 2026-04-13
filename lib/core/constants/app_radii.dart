/// Border radius tokens & helpers for the Nexora gamified savings app.
///
/// Provides base scale values, semantic component radii, and a
/// convenience helper ([namedBorderRadius]) for quick lookups.
/// Also includes asymmetric radius builders, responsive scaling,
/// interpolation utilities, path-based builders, notch cutout presets,
/// and comprehensive RRect helpers.
library;

import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';

class Radii {
  Radii._();

  // ─── Base Scale ────────────────────────────────────────────────────

  /// Extra-extra small — 4 px (tiny pills, inline chips).
  static const double xs = 4.0;

  /// Extra small — 8 px (small buttons, tags).
  static const double sm = 8.0;

  /// Small-medium — 10 px.
  static const double smMd = 10.0;

  /// Medium — 12 px (cards on mobile, inputs).
  static const double md = 12.0;

  /// Base — 16 px (default card, sheet corners).
  static const double base = 16.0;

  /// Medium-large — 18 px.
  static const double mdLg = 18.0;

  /// Large — 20 px (modals, large cards).
  static const double lg = 20.0;

  /// Extra large — 24 px (bottom sheets, prominent cards).
  static const double xl = 24.0;

  /// Extra-extra large — 32 px (hero sections, full-width panels).
  static const double xxl = 32.0;

  /// Massive — 40 px (full-screen panels).
  static const double massive = 40.0;

  /// Circular — 100 px (avatars, progress rings).
  static const double circular = 100.0;

  // ─── Semantic Component Radii ──────────────────────────────────────

  /// Primary / CTA button.
  static const double button = 12.0;

  /// Small / secondary button.
  static const double buttonSm = 8.0;

  /// Large prominent button.
  static const double buttonLg = 16.0;

  /// Extra large button (hero CTA).
  static const double buttonXl = 20.0;

  /// Pill-shaped button (fully rounded).
  static const double buttonPill = 100.0;

  /// Savings goal card, transaction tile.
  static const double card = 16.0;

  /// Compact card variant.
  static const double cardSm = 12.0;

  /// Large card variant.
  static const double cardLg = 20.0;

  /// Extended card (full width with slight rounding).
  static const double cardExtended = 12.0;

  /// Modal / dialog window.
  static const double modal = 20.0;

  /// Large modal window.
  static const double modalLg = 24.0;

  /// Text / amount input field.
  static const double input = 12.0;

  /// Large input field.
  static const double inputLg = 16.0;

  /// Search input field (more rounded).
  static const double searchInput = 24.0;

  /// Progress bar (fully rounded ends).
  static const double progress = 100.0;

  /// Tag / capsule label pill.
  static const double tag = 100.0;

  /// Avatar circle (standard size).
  static const double avatar = 50.0;

  /// Avatar small.
  static const double avatarSm = 24.0;

  /// Avatar large.
  static const double avatarLg = 64.0;

  /// Achievement / level badge.
  static const double badge = 8.0;

  /// Large badge.
  static const double badgeLg = 12.0;

  /// Filter / action chip.
  static const double chip = 100.0;

  /// Alert / confirmation dialog.
  static const double dialog = 16.0;

  /// Large dialog.
  static const double dialogLg = 24.0;

  /// Bottom sheet (top corners only).
  static const double bottomSheet = 24.0;

  /// Bottom sheet compact (less rounded).
  static const double bottomSheetSm = 16.0;

  /// Floating action button.
  static const double fab = 16.0;

  /// Extended FAB (rectangular with rounded corners).
  static const double fabExtended = 16.0;

  /// Tooltip callout.
  static const double tooltip = 8.0;

  /// Snackbar / toast.
  static const double snackbar = 12.0;

  /// Notification card.
  static const double notification = 14.0;

  /// Large notification card.
  static const double notificationLg = 18.0;

  /// Challenge card (slightly more rounded for playfulness).
  static const double challenge = 20.0;

  /// Streak fire indicator badge.
  static const double streak = 100.0;

  /// XP bar indicator.
  static const double xpBar = 100.0;

  /// Coin icon badge.
  static const double coinBadge = 12.0;

  /// Level indicator circle.
  static const double levelCircle = 50.0;

  /// Calendar date cell.
  static const double calendarCell = 10.0;

  /// Calendar selected date.
  static const double calendarSelected = 50.0;

  /// Slider thumb.
  static const double sliderThumb = 10.0;

  /// Switch track.
  static const double switchTrack = 100.0;

  /// Tab indicator.
  static const double tabIndicator = 100.0;

  /// Divider line (slight rounding for pill dividers).
  static const double dividerPill = 100.0;

  /// Image thumbnail.
  static const double imageThumbnail = 8.0;

  /// Code block.
  static const double codeBlock = 12.0;

  // ─── Додаткові семантичні радіуси ──────────────────────────────────

  /// Карточка депозиту (злегка більший за стандартну).
  static const double depositCard = 18.0;

  /// Карточка цілі заощаджень (більш округла).
  static const double savingsGoalCard = 20.0;

  /// Карточка транзакції (компактна).
  static const double transactionTile = 12.0;

  /// Секція статистики (велика картка).
  static const double statsCard = 16.0;

  /// Секція графіка (з меншим округленням).
  static const double chartSection = 12.0;

  /// Навігаційна панель (нижня).
  static const double bottomNav = 16.0;

  /// Панель інструментів (верхня).
  static const double topBar = 12.0;

  /// Картка профілю користувача.
  static const double profileCard = 20.0;

  /// Рядок налаштувань.
  static const double settingsRow = 12.0;

  /// Поле пошуку.
  static const double searchField = 28.0;

  /// Банер акції / промо.
  static const double promoBanner = 16.0;

  /// Картка магазину (внутрішньоігрового).
  static const double shopItem = 16.0;

  /// Елемент списку товарів.
  static const double shopListItem = 12.0;

  /// Картка лідерборду.
  static const double leaderboardCard = 16.0;

  /// Кнопка «Поділитися».
  static const double shareButton = 24.0;

  /// Стрілка-індикатор (навігація).
  static const double arrowIndicator = 8.0;

  /// Попап повідомлення (context menu).
  static const double popup = 16.0;

  /// Перетягуваний елемент (drag handle).
  static const double dragHandle = 6.0;

  /// Індикатор прогресу кільця.
  static const double ringProgress = 50.0;

  /// Картка зведення (summary).
  static const double summaryCard = 14.0;

  /// Картка поради (tip card).
  static const double tipCard = 16.0;

  /// Бейдж рангу користувача.
  static const double rankBadge = 10.0;

  // ─── Notch & Cutout Presets ────────────────────────────────────────

  /// Standard notch cutout radius.
  static const double notchCutout = 12.0;

  /// Bottom navigation notch (center cutout).
  static const double navNotch = 20.0;

  /// FAB notch (for notch-out in bottom app bar).
  static const double fabNotch = 28.0;

  /// FAB notch для великої кнопки.
  static const double fabNotchLg = 32.0;

  /// Notch для картки з вирізом зверху.
  static const double cardTopNotch = 16.0;

  /// Notch для bottom sheet з FAB.
  static const double sheetFabNotch = 28.0;

  /// Notch для хвилеподібного краю.
  static const double waveNotch = 20.0;

  // ─── Helper Methods ────────────────────────────────────────────────

  /// Returns a [BorderRadius] with all corners set to [radius].
  static BorderRadius all(double radius) => BorderRadius.circular(radius);

  /// Returns a [BorderRadius] with only top corners rounded.
  static BorderRadius top(double radius) => BorderRadius.vertical(
        top: Radius.circular(radius),
      );

  /// Returns a [BorderRadius] with only bottom corners rounded.
  static BorderRadius bottom(double radius) => BorderRadius.vertical(
        bottom: Radius.circular(radius),
      );

  /// Returns a [BorderRadius] with only the top-left corner rounded.
  static BorderRadius topLeft(double radius) => BorderRadius.only(
        topLeft: Radius.circular(radius),
      );

  /// Returns a [BorderRadius] with only the bottom-right corner rounded.
  static BorderRadius bottomRight(double radius) => BorderRadius.only(
        bottomRight: Radius.circular(radius),
      );

  /// Returns a [BorderRadius] with only the top-right corner rounded.
  static BorderRadius topRight(double radius) => BorderRadius.only(
        topRight: Radius.circular(radius),
      );

  /// Returns a [BorderRadius] with only the bottom-left corner rounded.
  static BorderRadius bottomLeft(double radius) => BorderRadius.only(
        bottomLeft: Radius.circular(radius),
      );

  /// Returns a [BorderRadius] with left corners rounded.
  static BorderRadius left(double radius) => BorderRadius.horizontal(
        left: Radius.circular(radius),
      );

  /// Returns a [BorderRadius] with right corners rounded.
  static BorderRadius right(double radius) => BorderRadius.horizontal(
        right: Radius.circular(radius),
      );

  /// Returns an asymmetric [BorderRadius] with different radii per corner.
  ///
  /// [topLeft], [topRight], [bottomRight], [bottomLeft] — individual radii.
  static BorderRadius asymmetric({
    double topLeft = 0,
    double topRight = 0,
    double bottomRight = 0,
    double bottomLeft = 0,
  }) {
    return BorderRadius.only(
      topLeft: Radius.circular(topLeft),
      topRight: Radius.circular(topRight),
      bottomRight: Radius.circular(bottomRight),
      bottomLeft: Radius.circular(bottomLeft),
    );
  }

  /// Returns a [BorderRadius] with different vertical radii.
  ///
  /// [top] — радіус верхніх кутів.
  /// [bottom] — радіус нижніх кутів.
  static BorderRadius vertical(double top, double bottom) {
    return BorderRadius.vertical(
      top: Radius.circular(top),
      bottom: Radius.circular(bottom),
    );
  }

  /// Returns a [BorderRadius] with different horizontal radii.
  ///
  /// [left] — радіус лівих кутів.
  /// [right] — радіус правих кутів.
  static BorderRadius horizontal(double left, double right) {
    return BorderRadius.horizontal(
      left: Radius.circular(left),
      right: Radius.circular(right),
    );
  }

  /// Lookup a pre-defined [BorderRadius] by semantic element name.
  ///
  /// ```dart
  /// final radius = Radii.namedBorderRadius('card'); // BorderRadius.circular(16)
  /// ```
  ///
  /// Supported names: `button`, `buttonSm`, `buttonLg`, `card`, `cardSm`,
  /// `modal`, `input`, `progress`, `tag`, `avatar`, `badge`, `chip`,
  /// `dialog`, `bottomSheet`, `fab`, `tooltip`, `snackbar`, `notification`,
  /// `challenge`, `streak`, `circular`.
  ///
  /// Falls back to [base] for unknown names.
  static BorderRadius namedBorderRadius(String name) {
    switch (name) {
      case 'button':
        return all(button);
      case 'buttonSm':
        return all(buttonSm);
      case 'buttonLg':
        return all(buttonLg);
      case 'buttonPill':
        return all(buttonPill);
      case 'card':
        return all(card);
      case 'cardSm':
        return all(cardSm);
      case 'cardLg':
        return all(cardLg);
      case 'modal':
        return all(modal);
      case 'modalLg':
        return all(modalLg);
      case 'input':
        return all(input);
      case 'inputLg':
        return all(inputLg);
      case 'searchInput':
        return all(searchInput);
      case 'searchField':
        return all(searchField);
      case 'progress':
        return all(progress);
      case 'tag':
        return all(tag);
      case 'avatar':
        return all(avatar);
      case 'avatarSm':
        return all(avatarSm);
      case 'avatarLg':
        return all(avatarLg);
      case 'badge':
        return all(badge);
      case 'badgeLg':
        return all(badgeLg);
      case 'rankBadge':
        return all(rankBadge);
      case 'chip':
        return all(chip);
      case 'dialog':
        return all(dialog);
      case 'dialogLg':
        return all(dialogLg);
      case 'bottomSheet':
        return top(bottomSheet);
      case 'bottomSheetSm':
        return top(bottomSheetSm);
      case 'fab':
        return all(fab);
      case 'fabExtended':
        return all(fabExtended);
      case 'tooltip':
        return all(tooltip);
      case 'snackbar':
        return all(snackbar);
      case 'notification':
        return all(notification);
      case 'notificationLg':
        return all(notificationLg);
      case 'challenge':
        return all(challenge);
      case 'streak':
        return all(streak);
      case 'xpBar':
        return all(xpBar);
      case 'coinBadge':
        return all(coinBadge);
      case 'levelCircle':
        return all(levelCircle);
      case 'calendarCell':
        return all(calendarCell);
      case 'calendarSelected':
        return all(calendarSelected);
      case 'sliderThumb':
        return all(sliderThumb);
      case 'switchTrack':
        return all(switchTrack);
      case 'tabIndicator':
        return all(tabIndicator);
      case 'codeBlock':
        return all(codeBlock);
      case 'circular':
        return all(circular);
      case 'massive':
        return all(massive);
      case 'depositCard':
        return all(depositCard);
      case 'savingsGoalCard':
        return all(savingsGoalCard);
      case 'transactionTile':
        return all(transactionTile);
      case 'statsCard':
        return all(statsCard);
      case 'chartSection':
        return all(chartSection);
      case 'bottomNav':
        return all(bottomNav);
      case 'topBar':
        return all(topBar);
      case 'profileCard':
        return all(profileCard);
      case 'settingsRow':
        return all(settingsRow);
      case 'promoBanner':
        return all(promoBanner);
      case 'shopItem':
        return all(shopItem);
      case 'shopListItem':
        return all(shopListItem);
      case 'leaderboardCard':
        return all(leaderboardCard);
      case 'shareButton':
        return all(shareButton);
      case 'popup':
        return all(popup);
      case 'summaryCard':
        return all(summaryCard);
      case 'tipCard':
        return all(tipCard);
      case 'ringProgress':
        return all(ringProgress);
      default:
        return all(base);
    }
  }

  /// Повертає числове значення радіуса за назвою.
  ///
  /// Зручно для використання поза контекстом [BorderRadius].
  static double namedRadius(String name) {
    switch (name) {
      case 'xs':
        return xs;
      case 'sm':
        return sm;
      case 'smMd':
        return smMd;
      case 'md':
        return md;
      case 'base':
        return base;
      case 'mdLg':
        return mdLg;
      case 'lg':
        return lg;
      case 'xl':
        return xl;
      case 'xxl':
        return xxl;
      case 'massive':
        return massive;
      case 'circular':
        return circular;
      case 'button':
        return button;
      case 'buttonSm':
        return buttonSm;
      case 'card':
        return card;
      case 'cardSm':
        return cardSm;
      case 'cardLg':
        return cardLg;
      case 'modal':
        return modal;
      case 'input':
        return input;
      case 'progress':
        return progress;
      case 'badge':
        return badge;
      case 'fab':
        return fab;
      case 'snackbar':
        return snackbar;
      case 'challenge':
        return challenge;
      default:
        return base;
    }
  }

  // ─── Масштабування та інтерполяція ────────────────────────────────

  /// Масштабує радіус відносно ширини екрана.
  ///
  /// [radius] — базовий радіус.
  /// [screenWidth] — ширина екрана.
  /// [baseWidth] — базова ширина (за замовчуванням 375).
  ///
  /// На більших екранах радіус трохи збільшується для пропорційності.
  static double responsiveScale(
    double radius,
    double screenWidth, {
    double baseWidth = 375,
  }) {
    final scale = (screenWidth / baseWidth).clamp(0.9, 1.3);
    return radius * scale;
  }

  /// Повертає адаптивний [BorderRadius] для карток.
  ///
  /// На ширших екранах використовує більший радіус.
  static BorderRadius responsiveCard(double screenWidth) {
    final scaled = responsiveScale(card, screenWidth);
    return all(scaled);
  }

  /// Повертає адаптивний [BorderRadius] для модальних вікон.
  static BorderRadius responsiveModal(double screenWidth) {
    final scaled = responsiveScale(modal, screenWidth);
    return all(scaled);
  }

  /// Інтерполює між двома значеннями [BorderRadius].
  ///
  /// [a] — початковий радіус.
  /// [b] — кінцевий радіус.
  /// [t] — коефіцієнт (0.0 = a, 1.0 = b).
  static BorderRadius lerp(BorderRadius a, BorderRadius b, double t) {
    return BorderRadius.lerp(a, b, t.clamp(0.0, 1.0)) ?? a;
  }

  /// Інтерполює між двома числовими значеннями радіуса.
  ///
  /// [a] — початкове значення.
  /// [b] — кінцеве значення.
  /// [t] — коефіцієнт (0.0 = a, 1.0 = b).
  static double lerpDouble(double a, double b, double t) {
    return a + (b - a) * t.clamp(0.0, 1.0);
  }

  /// Інтерполює між радіусами за назвою.
  ///
  /// Зручно для анімацій між різними компонентами.
  static BorderRadius lerpNamed(
    String nameA,
    String nameB,
    double t,
  ) {
    return lerp(namedBorderRadius(nameA), namedBorderRadius(nameB), t);
  }

  /// Обмежує всі кути [BorderRadius] максимальним значенням.
  ///
  /// Корисно для запобігання перекручування на малих елементах.
  static BorderRadius clampRadius(
    BorderRadius radius,
    double maxRadius,
  ) {
    return BorderRadius.only(
      topLeft: _clampRadius(radius.topLeft, maxRadius),
      topRight: _clampRadius(radius.topRight, maxRadius),
      bottomLeft: _clampRadius(radius.bottomLeft, maxRadius),
      bottomRight: _clampRadius(radius.bottomRight, maxRadius),
    );
  }

  static Radius _clampRadius(Radius r, double max) {
    return Radius.elliptical(
      r.x.clamp(0, max),
      r.y.clamp(0, max),
    );
  }

  // ─── RRect Helpers ─────────────────────────────────────────────────

  /// Повертає [RRect] (rounded rectangle) з вказаним розміром та радіусом.
  ///
  /// [rect] — прямокутник (Offset + Size).
  /// [radius] — радіус кутів.
  static RRect toRRect(Rect rect, double radius) {
    return RRect.fromRectAndCorners(
      rect,
      topLeft: Radius.circular(radius),
      topRight: Radius.circular(radius),
      bottomLeft: Radius.circular(radius),
      bottomRight: Radius.circular(radius),
    );
  }

  /// Повертає [RRect] з асиметричними кутами.
  ///
  /// [rect] — прямокутник.
  /// [topLeft], [topRight], [bottomRight], [bottomLeft] — індивідуальні радіуси.
  static RRect toAsymmetricRRect(
    Rect rect, {
    double topLeft = 0,
    double topRight = 0,
    double bottomRight = 0,
    double bottomLeft = 0,
  }) {
    return RRect.fromRectAndCorners(
      rect,
      topLeft: Radius.circular(topLeft),
      topRight: Radius.circular(topRight),
      bottomLeft: Radius.circular(bottomLeft),
      bottomRight: Radius.circular(bottomRight),
    );
  }

  /// Повертає [RRect] для верхньої частини прямокутника (як bottom sheet).
  ///
  /// [rect] — прямокутник.
  /// [radius] — радіус верхніх кутів.
  static RRect toTopRRect(Rect rect, double radius) {
    return RRect.fromRectAndCorners(
      rect,
      topLeft: Radius.circular(radius),
      topRight: Radius.circular(radius),
    );
  }

  /// Повертає [RRect] для нижньої частини прямокутника.
  ///
  /// [rect] — прямокутник.
  /// [radius] — радіус нижніх кутів.
  static RRect toBottomRRect(Rect rect, double radius) {
    return RRect.fromRectAndCorners(
      rect,
      bottomLeft: Radius.circular(radius),
      bottomRight: Radius.circular(radius),
    );
  }

  /// Повертає [RRect] з вирізом для FAB внизу.
  ///
  /// Використовується для bottom sheet з напівкруглим вирізом.
  static RRect toNotchRRect(
    Rect rect, {
    double topRadius = 20.0,
    double notchRadius = 28.0,
    double notchCenterX = 0,
    double notchWidth = 56.0,
  }) {
    return RRect.fromRectAndCorners(
      rect,
      topLeft: Radius.circular(topRadius),
      topRight: Radius.circular(topRadius),
    );
  }

  /// Повертає [RRect] для хвилеподібного краю.
  static RRect toWaveRRect(Rect rect, double radius) {
    return RRect.fromRectAndCorners(
      rect,
      topLeft: Radius.circular(radius),
      topRight: Radius.circular(radius),
    );
  }

  // ─── Path-Based Builders ───────────────────────────────────────────

  /// Створює [Path] з округленими верхніми кутами.
  ///
  /// Корисно для CustomPaint з нестандартними формами.
  static Path topRoundedPath(Size size, double radius) {
    final path = Path();
    path.moveTo(0, size.height);
    path.lineTo(0, radius);
    path.quadraticBezierTo(0, 0, radius, 0);
    path.lineTo(size.width - radius, 0);
    path.quadraticBezierTo(size.width, 0, size.width, radius);
    path.lineTo(size.width, size.height);
    path.close();
    return path;
  }

  /// Створює [Path] з округленими нижніми кутами.
  static Path bottomRoundedPath(Size size, double radius) {
    final path = Path();
    path.moveTo(0, 0);
    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height - radius);
    path.quadraticBezierTo(
      size.width, size.height, size.width - radius, size.height,
    );
    path.lineTo(radius, size.height);
    path.quadraticBezierTo(0, size.height, 0, size.height - radius);
    path.close();
    return path;
  }

  /// Створює [Path] з округленими всіма кутами.
  static Path roundedRectPath(Size size, double radius) {
    final path = Path();
    path.moveTo(radius, 0);
    path.lineTo(size.width - radius, 0);
    path.quadraticBezierTo(size.width, 0, size.width, radius);
    path.lineTo(size.width, size.height - radius);
    path.quadraticBezierTo(
      size.width, size.height, size.width - radius, size.height,
    );
    path.lineTo(radius, size.height);
    path.quadraticBezierTo(0, size.height, 0, size.height - radius);
    path.lineTo(0, radius);
    path.quadraticBezierTo(0, 0, radius, 0);
    path.close();
    return path;
  }

  /// Створює [Path] з напівкруглим вирізом зверху (для FAB notch).
  static Path notchPath(
    Size size, {
    double notchRadius = 28.0,
    double notchCenterXFactor = 0.5,
  }) {
    final centerX = size.width * notchCenterXFactor;
    final path = Path();
    path.moveTo(0, size.height);
    path.lineTo(0, 0);
    path.lineTo(centerX - notchRadius, 0);
    path.arcToPoint(
      Offset(centerX + notchRadius, 0),
      radius: Radius.circular(notchRadius),
      clockwise: true,
    );
    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height);
    path.close();
    return path;
  }

  // ─── ShapeBorder & Decoration ──────────────────────────────────────

  /// Повертає [ShapeBorder] для використання у Material віджетах.
  ///
  /// [radius] — радіус кутів.
  /// [side] — рамка.
  static OutlinedBorder shapeBorder({
    double radius = 16.0,
    BorderSide? side,
  }) {
    return RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(radius),
      side: side ?? BorderSide.none,
    );
  }

  /// Повертає [OutlinedBorder] з асиметричними кутами.
  static OutlinedBorder asymmetricShapeBorder({
    double topLeft = 0,
    double topRight = 0,
    double bottomRight = 0,
    double bottomLeft = 0,
    BorderSide? side,
  }) {
    return RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(topLeft),
        topRight: Radius.circular(topRight),
        bottomLeft: Radius.circular(bottomLeft),
        bottomRight: Radius.circular(bottomRight),
      ),
      side: side ?? BorderSide.none,
    );
  }

  /// Повертає [BoxDecoration] з округленими кутами.
  ///
  /// [radius] — радіус кутів.
  /// [color] — колір фону.
  /// [border] — рамка.
  /// [boxShadow] — тінь.
  static BoxDecoration decoration({
    double radius = 16.0,
    Color? color,
    BoxBorder? border,
    List<BoxShadow>? boxShadow,
  }) {
    return BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(radius),
      border: border,
      boxShadow: boxShadow,
    );
  }

  /// Повертає [BoxDecoration] з асиметричними кутами.
  static BoxDecoration asymmetricDecoration({
    double topLeft = 16.0,
    double topRight = 16.0,
    double bottomRight = 16.0,
    double bottomLeft = 16.0,
    Color? color,
    BoxBorder? border,
    List<BoxShadow>? boxShadow,
  }) {
    return BoxDecoration(
      color: color,
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(topLeft),
        topRight: Radius.circular(topRight),
        bottomLeft: Radius.circular(bottomLeft),
        bottomRight: Radius.circular(bottomRight),
      ),
      border: border,
      boxShadow: boxShadow,
    );
  }

  // ─── Утиліти ──────────────────────────────────────────────────────

  /// Обмежує радіус так, щоб він не перевищував половину
  /// найменшої сторони прямокутника.
  ///
  /// Це запобігає «перекручуванню» округлених кутів
  /// на дуже малих елементах.
  static double constrainToSize(double radius, double width, double height) {
    final maxRadius = math.min(width, height) / 2;
    return radius.clamp(0, maxRadius);
  }

  /// Повертає мінімальний радіус для даного розміру.
  ///
  /// Автоматично зменшує радіус, якщо елемент замалий.
  static double autoRadius(double desired, double width, double height) {
    return constrainToSize(desired, width, height);
  }

  /// Обчислює радіус для SQUARE аватара розміром [size].
  ///
  /// Завжди повертає половину розміру для ідеального кола.
  static double avatarRadius(double size) {
    return size / 2;
  }

  /// Повертає опис радіуса для дебагу.
  static String debugRadius(double radius) {
    return 'Радіус: ${radius.toStringAsFixed(1)}px';
  }

  /// Повертає всі зареєстровані назви компонентів.
  ///
  /// Для використання в UI-налаштуваннях.
  static List<String> get allComponentNames => [
        'xs', 'sm', 'smMd', 'md', 'base', 'mdLg', 'lg', 'xl', 'xxl',
        'massive', 'circular', 'button', 'buttonSm', 'buttonLg', 'buttonXl',
        'buttonPill', 'card', 'cardSm', 'cardLg', 'cardExtended',
        'modal', 'modalLg', 'input', 'inputLg', 'searchInput',
        'searchField', 'progress', 'tag', 'avatar', 'avatarSm', 'avatarLg',
        'badge', 'badgeLg', 'rankBadge', 'chip', 'dialog', 'dialogLg',
        'bottomSheet', 'bottomSheetSm', 'fab', 'fabExtended',
        'tooltip', 'snackbar', 'notification', 'notificationLg',
        'challenge', 'streak', 'xpBar', 'coinBadge', 'levelCircle',
        'calendarCell', 'calendarSelected', 'sliderThumb', 'switchTrack',
        'tabIndicator', 'dividerPill', 'imageThumbnail', 'codeBlock',
        'depositCard', 'savingsGoalCard', 'transactionTile', 'statsCard',
        'chartSection', 'bottomNav', 'topBar', 'profileCard',
        'settingsRow', 'promoBanner', 'shopItem', 'shopListItem',
        'leaderboardCard', 'shareButton', 'popup', 'summaryCard',
        'tipCard', 'ringProgress', 'onboardingCard', 'rewardCard',
        'streakCard', 'tutorialTooltip', 'overlayPanel',
      ];

  // ─── Додаткові семантичні радіуси (Extended Component Radii) ────────

  /// Картка онбордингу.
  static const double onboardingCard = 24.0;

  /// Картка нагороди.
  static const double rewardCard = 16.0;

  /// Картка серії (streak).
  static const double streakCard = 20.0;

  /// Тултіп туторіалу.
  static const double tutorialTooltip = 12.0;

  /// Оверлей панель.
  static const double overlayPanel = 24.0;

  /// Картка челенджу (велика).
  static const double challengeCardLg = 24.0;

  /// Картка з прогрес-баром.
  static const double progressCard = 14.0;

  /// Tile для Quick Actions.
  static const double quickActionTile = 12.0;

  /// Картка дня (daily card).
  static const double dailyCard = 18.0;

  /// Поле з кількістю (number input).
  static const double numberInput = 16.0;

  /// Панель з графіком.
  static const double chartPanel = 20.0;

  /// Картка товару в магазині (велика).
  static const double shopItemLg = 20.0;

  /// Рядок статистики (stats row).
  static const double statsRow = 10.0;

  /// Картка досягнення (achievement card).
  static const double achievementCard = 18.0;

  /// Закріплена картка (pinned card).
  static const double pinnedCard = 16.0;

  /// Банер з анімацією.
  static const double animatedBanner = 20.0;

  // ─── Додаткові методи ──────────────────────────────────────────────

  /// Повертає [StadiumBorder] для повністю округленого елемента.
  ///
  /// Корисно для chip, tag, progress bar.
  static StadiumBorder stadiumBorder({BorderSide? side}) {
    return StadiumBorder(side: side ?? BorderSide.none);
  }

  /// Повертає [CircleBorder] для кругового елемента.
  ///
  /// Корисно для avatar, progress ring.
  static CircleBorder circleBorder({BorderSide? side}) {
    return CircleBorder(side: side ?? BorderSide.none);
  }

  /// Повертає [BeveledRectangleBorder] з фаскованими кутами.
  ///
  /// Дає 3D-ефект підняття.
  static BeveledRectangleBorder beveledBorder({
    BorderSide? side,
    BorderRadius? borderRadius,
  }) {
    return BeveledRectangleBorder(
      side: side ?? BorderSide.none,
      borderRadius: borderRadius ?? BorderRadius.circular(base),
    );
  }

  /// Повертає [ContinuousRectangleBorder] для плавно округленого елемента.
  ///
  /// Кути плавно згладжуються, як у iOS.
  static ContinuousRectangleBorder continuousBorder({
    BorderSide? side,
    BorderRadius? borderRadius,
  }) {
    return ContinuousRectangleBorder(
      side: side ?? BorderSide.none,
      borderRadius: borderRadius ?? BorderRadius.circular(lg),
    );
  }

  /// Валідація: перевіряє, чи радіус не є від'ємним.
  static double validateRadius(double radius) {
    assert(radius >= 0, 'Радіус не може бути від\'ємним: $radius');
    return radius < 0 ? 0.0 : radius;
  }

  /// Повертає мапу всіх компонентів та їх значень для дебагу.
  static Map<String, double> debugMap() {
    return {
      for (final name in allComponentNames)
        name: namedRadius(name),
    };
  }

  /// Обчислює радіус для Responsive Layout.
  ///
  /// [screenWidth] — поточна ширина екрана.
  /// [baseRadius] — базовий радіус для телефону (за замовчуванням 16).
  static double adaptiveRadius(
    double screenWidth, {
    double baseRadius = 16.0,
    double tabletRadius = 20.0,
    double desktopRadius = 24.0,
  }) {
    if (screenWidth >= 1024) return desktopRadius;
    if (screenWidth >= 600) return tabletRadius;
    return baseRadius;
  }

  /// Повертає адаптивний [BorderRadius] для будь-якого компонента.
  static BorderRadius adaptiveBorderRadius(
    double screenWidth, {
    double phoneRadius = 16.0,
    double tabletRadius = 20.0,
    double desktopRadius = 24.0,
  }) {
    return all(adaptiveRadius(
      screenWidth,
      baseRadius: phoneRadius,
      tabletRadius: tabletRadius,
      desktopRadius: desktopRadius,
    ));
  }

  /// Створює [ClipRRect] з вказаним радіусом.
  ///
  /// Зручний метод для обрізання дочірніх елементів.
  static ClipRRect clipRRect({
    required BorderRadius borderRadius,
    Widget? child,
  }) {
    return ClipRRect(
      borderRadius: borderRadius,
      child: child,
    );
  }

  /// Створює [RRect] для лівого вирізу.
  static RRect toLeftRRect(Rect rect, double radius) {
    return RRect.fromRectAndCorners(
      rect,
      topLeft: Radius.circular(radius),
      bottomLeft: Radius.circular(radius),
    );
  }

  /// Створює [RRect] для правого вирізу.
  static RRect toRightRRect(Rect rect, double radius) {
    return RRect.fromRectAndCorners(
      rect,
      topRight: Radius.circular(radius),
      bottomRight: Radius.circular(radius),
    );
  }

  /// Створює [Path] з округленими лівими кутами.
  static Path leftRoundedPath(Size size, double radius) {
    final path = Path();
    path.moveTo(radius, 0);
    path.lineTo(0, 0);
    path.lineTo(0, size.height - radius);
    path.quadraticBezierTo(0, size.height, radius, size.height);
    path.lineTo(size.width, size.height);
    path.lineTo(size.width, 0);
    path.lineTo(radius, 0);
    path.quadraticBezierTo(0, 0, radius, 0);
    path.close();
    return path;
  }

  /// Створює [Path] з округленими правими кутами.
  static Path rightRoundedPath(Size size, double radius) {
    final path = Path();
    path.moveTo(0, 0);
    path.lineTo(size.width - radius, 0);
    path.quadraticBezierTo(size.width, 0, size.width, radius);
    path.lineTo(size.width, size.height - radius);
    path.quadraticBezierTo(size.width, size.height, size.width - radius, size.height);
    path.lineTo(0, size.height);
    path.lineTo(0, 0);
    path.close();
    return path;
  }

  /// Створює [Path] для ромбовидної форми.
  static Path diamondPath(Size size) {
    final path = Path();
    final cx = size.width / 2;
    final cy = size.height / 2;
    path.moveTo(cx, 0);
    path.lineTo(size.width, cy);
    path.lineTo(cx, size.height);
    path.lineTo(0, cy);
    path.close();
    return path;
  }

  /// Створює [Path] для шестикутної форми.
  static Path hexagonPath(Size size) {
    final path = Path();
    final w = size.width / 2;
    final h = size.height / 2;
    path.moveTo(w * 0.75, 0);
    path.lineTo(size.width - w * 0.25, 0);
    path.lineTo(size.width, h);
    path.lineTo(size.width - w * 0.25, size.height);
    path.lineTo(w * 0.75, size.height);
    path.lineTo(0, h);
    path.close();
    return path;
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Розширення (Extensions)
// ═══════════════════════════════════════════════════════════════════════════

/// Розширення для [double] для створення [BorderRadius].
extension RadiiDoubleExtension on double {
  /// Створює [BorderRadius.circular] з цим значенням.
  BorderRadius get circular => BorderRadius.circular(this);

  /// Створює [BorderRadius.vertical] з верхнім радіусом.
  BorderRadius get topRadius => Radii.top(this);

  /// Створює [BorderRadius.vertical] з нижнім радіусом.
  BorderRadius get bottomRadius => Radii.bottom(this);

  /// Обмежує радіус відносно розміру.
  ///
  /// [width] та [height] — розміри елемента.
  double constrainTo(double width, double height) =>
      Radii.constrainToSize(this, width, height);

  /// Обчислює радіус аватара для цього розміру.
  double get avatarR => Radii.avatarRadius(this);
}

/// Розширення для [BorderRadius] для додаткових операцій.
extension BorderRadiusExtension on BorderRadius {
  /// Масштабує всі кути на коефіцієнт.
  BorderRadius scale(double factor) => BorderRadius.only(
        topLeft: Radius.elliptical(
          topLeft.x * factor,
          topLeft.y * factor,
        ),
        topRight: Radius.elliptical(
          topRight.x * factor,
          topRight.y * factor,
        ),
        bottomLeft: Radius.elliptical(
          bottomLeft.x * factor,
          bottomLeft.y * factor,
        ),
        bottomRight: Radius.elliptical(
          bottomRight.x * factor,
          bottomRight.y * factor,
        ),
      );

  /// Повертає максимальне значення радіусу серед усіх кутів.
  double get maxRadius {
    return [
      topLeft.x, topLeft.y,
      topRight.x, topRight.y,
      bottomLeft.x, bottomLeft.y,
      bottomRight.x, bottomRight.y,
    ].reduce(math.max);
  }

  /// Повертає мінімальне значення радіусу серед усіх кутів.
  double get minRadius {
    return [
      topLeft.x, topLeft.y,
      topRight.x, topRight.y,
      bottomLeft.x, bottomLeft.y,
      bottomRight.x, bottomRight.y,
    ].reduce(math.min);
  }

  /// Перевіряє, чи всі кути мають однаковий радіус.
  bool get isUniform =>
      topLeft == topRight &&
      topRight == bottomLeft &&
      bottomLeft == bottomRight;

  /// Повертає опис для дебагу.
  String get debugDescription =>
      'BorderRadius(tl: ${topLeft.x.toStringAsFixed(1)}, '
      'tr: ${topRight.x.toStringAsFixed(1)}, '
      'bl: ${bottomLeft.x.toStringAsFixed(1)}, '
      'br: ${bottomRight.x.toStringAsFixed(1)})';
}
