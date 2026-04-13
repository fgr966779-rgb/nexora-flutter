import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../constants/app_colors.dart';
import '../constants/app_typography.dart';
import '../constants/app_spacing.dart';
import '../constants/app_radii.dart';
import '../constants/app_durations.dart';
import '../constants/app_easings.dart';

// ─── Debug Configuration ───────────────────────────────────────────────────

/// Налаштування налагодження для [AppTextField].
class TextFieldDebugConfig {
  TextFieldDebugConfig._();

  /// Увімкнути вивід debug-повідомлень.
  static bool enableLogging = false;

  /// Показувати рамки навколо полів.
  static bool showBounds = false;

  static void log(String message, {String? tag}) {
    if (!enableLogging) return;
    final prefix = tag != null ? '[TextField:$tag] ' : '[TextField] ';
    debugPrint('$prefix$message');
  }
}

// ─── Text Field Type Enum ───────────────────────────────────────────────────

/// Тип поля вводу — визначає клавіатуру, іконку та поведінку.
enum TextFieldType {
  /// Звичайний текстовий ввод.
  text,

  /// Числовий ввод (сума, кількість).
  number,

  /// Електронна пошта.
  email,

  /// Пошукове поле з іконкою лупи.
  search,

  /// Багаторядковий коментар.
  comment,

  /// Пароль з приховуванням символів.
  password,

  /// Номер телефону.
  phone,

  /// URL адреса.
  url;

  /// Тип клавіатури для Flutter.
  TextInputType get keyboardType {
    switch (this) {
      case TextFieldType.text:
        return TextInputType.text;
      case TextFieldType.number:
        return const TextInputType.numberWithOptions(decimal: true);
      case TextFieldType.email:
        return TextInputType.emailAddress;
      case TextFieldType.search:
        return TextInputType.text;
      case TextFieldType.comment:
        return TextInputType.multiline;
      case TextFieldType.password:
        return TextInputType.visiblePassword;
      case TextFieldType.phone:
        return TextInputType.phone;
      case TextFieldType.url:
        return TextInputType.url;
    }
  }

  /// Тип вводу для форматування.
  bool get isNumeric => this == TextFieldType.number;

  /// Дозволити багато рядків.
  bool get isMultiline => this == TextFieldType.comment;

  /// Кількість рядків.
  int get maxLines => isMultiline ? 4 : 1;

  /// Іконка за замовчуванням.
  IconData? get defaultIcon {
    switch (this) {
      case TextFieldType.text:
        return null;
      case TextFieldType.number:
        return Icons.attach_money_rounded;
      case TextFieldType.email:
        return Icons.mail_outline_rounded;
      case TextFieldType.search:
        return Icons.search_rounded;
      case TextFieldType.comment:
        return null;
      case TextFieldType.password:
        return Icons.lock_outline_rounded;
      case TextFieldType.phone:
        return Icons.phone_outlined;
      case TextFieldType.url:
        return Icons.link_rounded;
    }
  }

  /// Дія клавіатури за замовчуванням.
  TextInputAction get defaultAction {
    switch (this) {
      case TextFieldType.text:
        return TextInputAction.next;
      case TextFieldType.number:
        return TextInputAction.done;
      case TextFieldType.email:
        return TextInputAction.next;
      case TextFieldType.search:
        return TextInputAction.search;
      case TextFieldType.comment:
        return TextInputAction.newline;
      case TextFieldType.password:
        return TextInputAction.done;
      case TextFieldType.phone:
        return TextInputAction.next;
      case TextFieldType.url:
        return TextInputAction.done;
    }
  }

  /// Українська назва типу поля.
  String get label {
    switch (this) {
      case TextFieldType.text:
        return 'Текст';
      case TextFieldType.number:
        return 'Число';
      case TextFieldType.email:
        return 'Пошта';
      case TextFieldType.search:
        return 'Пошук';
      case TextFieldType.comment:
        return 'Коментар';
      case TextFieldType.password:
        return 'Пароль';
      case TextFieldType.phone:
        return 'Телефон';
      case TextFieldType.url:
        return 'URL';
    }
  }

  /// Валідатор за замовчуванням для цього типу.
  String? Function(String?)? get defaultValidator {
    switch (this) {
      case TextFieldType.email:
        return (value) {
          if (value == null || value.isEmpty) return null;
          final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
          if (!emailRegex.hasMatch(value)) return 'Введіть коректну email адресу';
          return null;
        };
      case TextFieldType.phone:
        return (value) {
          if (value == null || value.isEmpty) return null;
          final phoneRegex = RegExp(r'^\+?[\d\s\-\(\)]{7,15}$');
          if (!phoneRegex.hasMatch(value)) return 'Введіть коректний номер';
          return null;
        };
      case TextFieldType.url:
        return (value) {
          if (value == null || value.isEmpty) return null;
          final uri = Uri.tryParse(value);
          if (uri == null || !uri.hasScheme) return 'Введіть коректний URL';
          return null;
        };
      default:
        return null;
    }
  }
}

/// Розширений TextFormField з підтримкою різних типів, валідацією,
/// лічильником символів, форматуванням валют та анімацією фокусу.
class AppTextField extends StatefulWidget {
  const AppTextField({
    super.key,
    required this.hint,
    this.controller,
    this.onChanged,
    this.validator,
    this.fieldType = TextFieldType.text,
    this.obscureText = false,
    this.isLightTheme = false,
    this.suffixIcon,
    this.prefixIcon,
    this.prefixWidget,
    this.suffixWidget,
    this.enabled = true,
    this.maxLines,
    this.textInputAction,
    this.maxLength,
    this.showCharacterCounter = false,
    this.helperText,
    this.errorMessage,
    this.isSuccess = false,
    this.successMessage,
    this.showClearButton = false,
    this.enablePasswordToggle = false,
    this.isCurrency = false,
    this.currencySymbol = '₴',
    this.focusGlowEnabled = true,
    this.labelText,
    this.readOnly = false,
    this.autofocus = false,
    this.onSubmitted,
    this.inputFormatters,
    this.hintStyle,
    this.textAlign = TextAlign.start,
    this.semanticCounterText,
    this.enableSuggestions = true,
  });

  /// Створює текстове поле для email з валідацією.
  AppTextField.email({
    super.key,
    this.controller,
    this.onChanged,
    this.isLightTheme = false,
    this.enabled = true,
    this.showClearButton = true,
    this.readOnly = false,
    this.semanticCounterText,
  })  : hint = 'example@email.com',
        validator = null,
        fieldType = TextFieldType.email,
        obscureText = false,
        suffixIcon = null,
        prefixIcon = null,
        prefixWidget = null,
        suffixWidget = null,
        maxLines = null,
        textInputAction = TextInputAction.next,
        maxLength = null,
        showCharacterCounter = false,
        helperText = 'Ваша електронна пошта',
        errorMessage = null,
        isSuccess = false,
        successMessage = null,
        enablePasswordToggle = false,
        isCurrency = false,
        currencySymbol = '₴',
        focusGlowEnabled = true,
        labelText = 'Email',
        autofocus = false,
        onSubmitted = null,
        inputFormatters = null,
        hintStyle = null,
        textAlign = TextAlign.start,
        enableSuggestions = true;

  /// Створює поле для пароля з перемикачем видимості.
  AppTextField.password({
    super.key,
    this.controller,
    this.isLightTheme = false,
    this.enabled = true,
    this.showClearButton = false,
    this.maxLength,
    this.showCharacterCounter = false,
    this.helperText,
    this.errorMessage,
    this.onSubmitted,
    this.semanticCounterText,
  })  : hint = 'Введіть пароль',
        onChanged = null,
        validator = null,
        fieldType = TextFieldType.password,
        obscureText = true,
        suffixIcon = null,
        prefixIcon = null,
        prefixWidget = null,
        suffixWidget = null,
        maxLines = null,
        textInputAction = TextInputAction.done,
        isSuccess = false,
        successMessage = null,
        enablePasswordToggle = true,
        isCurrency = false,
        currencySymbol = '₴',
        focusGlowEnabled = true,
        labelText = 'Пароль',
        readOnly = false,
        autofocus = false,
        inputFormatters = null,
        hintStyle = null,
        textAlign = TextAlign.start,
        enableSuggestions = false;

  /// Створює поле для суми з форматуванням валюти.
  AppTextField.currency({
    super.key,
    this.controller,
    this.onChanged,
    this.isLightTheme = false,
    this.enabled = true,
    this.showClearButton = true,
    this.errorMessage,
    this.semanticCounterText,
  })  : hint = '0',
        validator = null,
        fieldType = TextFieldType.number,
        obscureText = false,
        suffixIcon = null,
        prefixIcon = null,
        prefixWidget = null,
        suffixWidget = null,
        maxLines = null,
        textInputAction = TextInputAction.done,
        maxLength = null,
        showCharacterCounter = false,
        helperText = 'Сума у гривнях',
        isSuccess = false,
        successMessage = null,
        enablePasswordToggle = false,
        isCurrency = true,
        currencySymbol = '₴',
        focusGlowEnabled = true,
        labelText = 'Сума',
        readOnly = false,
        autofocus = false,
        onSubmitted = null,
        inputFormatters = null,
        hintStyle = null,
        textAlign = TextAlign.end,
        enableSuggestions = false;

  /// Створює пошукове поле.
  AppTextField.search({
    super.key,
    this.controller,
    required String searchHint,
    this.onChanged,
    this.isLightTheme = false,
    this.enabled = true,
    this.showClearButton = true,
    this.onSubmitted,
    this.semanticCounterText,
  })  : hint = searchHint,
        validator = null,
        fieldType = TextFieldType.search,
        obscureText = false,
        suffixIcon = null,
        prefixIcon = null,
        prefixWidget = null,
        suffixWidget = null,
        maxLines = null,
        textInputAction = TextInputAction.search,
        maxLength = null,
        showCharacterCounter = false,
        helperText = null,
        errorMessage = null,
        isSuccess = false,
        successMessage = null,
        enablePasswordToggle = false,
        isCurrency = false,
        currencySymbol = '₴',
        focusGlowEnabled = true,
        labelText = null,
        readOnly = false,
        autofocus = false,
        inputFormatters = null,
        hintStyle = null,
        textAlign = TextAlign.start,
        enableSuggestions = false;

  /// Підказка у полі вводу.
  final String hint;

  /// Контролер тексту.
  final TextEditingController? controller;

  /// Зворотний виклик при зміні тексту.
  final ValueChanged<String>? onChanged;

  /// Валідатор форми.
  final String? Function(String?)? validator;

  /// Тип поля вводу.
  final TextFieldType fieldType;

  /// Приховувати текст (пароль).
  final bool obscureText;

  /// Світла тема.
  final bool isLightTheme;

  /// Іконка в кінці поля.
  final Widget? suffixIcon;

  /// Іконка на початку поля.
  final Widget? prefixIcon;

  /// Кастомний віджет-префікс.
  final Widget? prefixWidget;

  /// Кастомний віджет-суфікс.
  final Widget? suffixWidget;

  /// Увімкнене поле.
  final bool enabled;

  /// Максимальна кількість рядків (перевизначає fieldType).
  final int? maxLines;

  /// Дія клавіатури (Enter, Next, Done тощо).
  final TextInputAction? textInputAction;

  /// Максимальна кількість символів.
  final int? maxLength;

  /// Показувати лічильник символів.
  final bool showCharacterCounter;

  /// Допоміжний текст під полем.
  final String? helperText;

  /// Повідомлення про помилку (примусовий error-стан).
  final String? errorMessage;

  /// Стан успіху (зелена рамка).
  final bool isSuccess;

  /// Повідомлення успіху під полем.
  final String? successMessage;

  /// Показувати кнопку очищення тексту.
  final bool showClearButton;

  /// Увімкнути перемикач видимості пароля.
  final bool enablePasswordToggle;

  /// Форматувати як грошову суму.
  final bool isCurrency;

  /// Символ валюти для форматування.
  final String currencySymbol;

  /// Увімкнути ефект свічення при фокусі.
  final bool focusGlowEnabled;

  /// Текст-заголовок над полем.
  final String? labelText;

  /// Поле тільки для читання.
  final bool readOnly;

  /// Автоматичний фокус при появі.
  final bool autofocus;

  /// Callback при натисканні Enter на клавіатурі.
  final VoidCallback? onSubmitted;

  /// Кастомні форматувальники вводу.
  final List<TextInputFormatter>? inputFormatters;

  /// Кастомний стиль підказки.
  final TextStyle? hintStyle;

  /// Вирівнювання тексту.
  final TextAlign textAlign;

  /// Семантичний текст лічильника для accessibility.
  final String? semanticCounterText;

  /// Увімкнути підказки автозаповнення.
  final bool enableSuggestions;

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  final FocusNode _focusNode = FocusNode();
  bool _hasFocus = false;
  bool _obscured = true;
  int _characterCount = 0;

  // ─── Color Getters ───────────────────────────────────────────────────

  /// Колір рамки залежно від стану.
  Color get _borderColor {
    if (widget.errorMessage != null) return AppColorsPS5.error;
    if (widget.isSuccess) return AppColorsPS5.success;
    if (_hasFocus) {
      return widget.isLightTheme ? AppColorsMonitor.accent : AppColorsPS5.accent;
    }
    return widget.isLightTheme ? AppColorsMonitor.border : AppColorsPS5.border;
  }

  /// Колір свічення при фокусі.
  Color get _focusGlow =>
      widget.isLightTheme ? AppColorsMonitor.glow : AppColorsPS5.glow;

  /// Колір свічення при помилці.
  Color get _errorGlow => AppColorsPS5.error.withOpacity(0.2);

  /// Колір свічення при успіху.
  Color get _successGlow => AppColorsPS5.success.withOpacity(0.15);

  /// Основний колір тексту.
  Color get _textPrimary =>
      widget.isLightTheme ? AppColorsMonitor.textPrimary : AppColorsPS5.textPrimary;

  /// Колір підказки.
  Color get _textHint =>
      widget.isLightTheme ? AppColorsMonitor.textHint : AppColorsPS5.textHint;

  /// Вторинний колір тексту.
  Color get _textSecondary =>
      widget.isLightTheme
          ? AppColorsMonitor.textSecondary
          : AppColorsPS5.textSecondary;

  /// Колір фону поля.
  Color get _surfaceColor =>
      widget.isLightTheme ? AppColorsMonitor.surface : AppColorsPS5.surface;

  /// Колір вимкненого тексту.
  Color get _disabledColor => AppColorsPS5.textHint.withOpacity(0.3);

  // ─── Effective Values ────────────────────────────────────────────────

  /// Ефективна кількість рядків.
  int get _effectiveMaxLines =>
      widget.maxLines ?? widget.fieldType.maxLines;

  /// Чи є помилка.
  bool get _hasError => widget.errorMessage != null;

  /// Ефективний тип клавіатури.
  TextInputType get _effectiveKeyboard => widget.fieldType.keyboardType;

  /// Ефективна дія клавіатури.
  TextInputAction get _effectiveAction =>
      widget.textInputAction ?? widget.fieldType.defaultAction;

  // ─── Lifecycle ───────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _obscured = widget.obscureText || widget.fieldType == TextFieldType.password;
    _focusNode.addListener(_onFocusChange);
    _updateCharacterCount();
    TextFieldDebugConfig.log('initState', tag: 'lifecycle');
  }

  @override
  void didUpdateWidget(covariant AppTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.obscureText != oldWidget.obscureText) {
      _obscured = widget.obscureText;
    }
    if (widget.controller != oldWidget.controller) {
      _updateCharacterCount();
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    TextFieldDebugConfig.log('dispose', tag: 'lifecycle');
    super.dispose();
  }

  /// Обробляє зміну фокусу.
  void _onFocusChange() {
    setState(() => _hasFocus = _focusNode.hasFocus);
    TextFieldDebugConfig.log(
      'Focus changed: $_hasFocus',
      tag: 'focus',
    );
  }

  /// Оновлює лічильник символів.
  void _updateCharacterCount() {
    _characterCount = widget.controller?.text.length ?? 0;
  }

  /// Обробляє зміну тексту.
  void _onTextChanged(String value) {
    setState(() => _characterCount = value.length);
    widget.onChanged?.call(value);
  }

  /// Перемикає видимість пароля.
  void _toggleObscure() {
    setState(() => _obscured = !_obscured);
    TextFieldDebugConfig.log('Password toggle: obscured=$_obscured', tag: 'interaction');
  }

  /// Очищає текст поля.
  void _clearText() {
    widget.controller?.clear();
    setState(() => _characterCount = 0);
    widget.onChanged?.call('');
    TextFieldDebugConfig.log('Text cleared', tag: 'interaction');
  }

  /// Обробляє натискання Enter.
  void _onFieldSubmitted(String value) {
    widget.onSubmitted?.call();
    // Знімати фокус після відправки
    if (widget.textInputAction == TextInputAction.done ||
        widget.textInputAction == TextInputAction.search ||
        widget.textInputAction == TextInputAction.go) {
      _focusNode.unfocus();
    }
  }

  /// Перевіряє коректність конфігурації.
  void _validateConfig() {
    assert(
      widget.maxLength == null || widget.maxLength! > 0,
      'maxLength must be positive',
    );
    if (widget.enablePasswordToggle && !widget.obscureText &&
        widget.fieldType != TextFieldType.password) {
      TextFieldDebugConfig.log(
        'Warning: enablePasswordToggle is true but field is not password type',
        tag: 'validation',
      );
    }
  }

  // ─── Input Formatting ────────────────────────────────────────────────

  /// Будує список форматувальників вводу.
  List<TextInputFormatter>? get _inputFormatters {
    final formatters = <TextInputFormatter>[];

    // Кастомні форматувальники від користувача
    if (widget.inputFormatters != null) {
      formatters.addAll(widget.inputFormatters!);
      return formatters;
    }

    // Фільтрація для числових та валютних полів
    if (widget.fieldType.isNumeric || widget.isCurrency) {
      formatters.add(FilteringTextInputFormatter.allow(
        RegExp(r'[\d.,]'),
      ));
    }

    // Валютне форматування
    if (widget.isCurrency) {
      formatters.add(_CurrencyInputFormatter(
        symbol: widget.currencySymbol,
      ));
    }

    if (formatters.isEmpty) return null;
    return formatters;
  }

  // ─── Build ───────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    _validateConfig();

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Label ──
        if (widget.labelText != null) ...[
          Padding(
            padding: const EdgeInsets.only(bottom: Spacing.xs),
            child: Text(
              widget.labelText!,
              style: AppTypography.labelMedium.copyWith(
                color: _textPrimary,
              ),
            ),
          ),
        ],
        // ── Field ──
        AnimatedContainer(
          duration: AppDurations.medium,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(Radii.md),
            boxShadow: _buildFocusShadow(),
          ),
          child: TextFormField(
            controller: widget.controller,
            focusNode: _focusNode,
            onChanged: _onTextChanged,
            validator: widget.validator ?? widget.fieldType.defaultValidator,
            keyboardType: _effectiveKeyboard,
            obscureText: widget.enablePasswordToggle ? _obscured : widget.obscureText,
            enabled: widget.enabled,
            readOnly: widget.readOnly,
            maxLines: _effectiveMaxLines,
            textInputAction: _effectiveAction,
            maxLength: widget.showCharacterCounter || widget.maxLength != null
                ? widget.maxLength
                : null,
            inputFormatters: _inputFormatters,
            autofocus: widget.autofocus,
            onFieldSubmitted: _onFieldSubmitted,
            enableSuggestions: widget.enableSuggestions,
            style: AppTypography.bodyLarge.copyWith(
              color: widget.enabled ? _textPrimary : _disabledColor,
            ),
            textAlign: widget.textAlign,
            decoration: InputDecoration(
              hintText: widget.hint,
              hintStyle: widget.hintStyle ?? AppTypography.bodyLarge.copyWith(color: _textHint),
              labelText: widget.labelText,
              prefixIcon: _buildPrefixIcon(),
              prefixText: widget.isCurrency ? '${widget.currencySymbol} ' : null,
              prefixStyle: AppTypography.bodyLarge.copyWith(
                color: _textSecondary,
              ),
              suffixIcon: _buildSuffixIcon(),
              suffixText: widget.suffixWidget != null ? null : null,
              filled: true,
              fillColor: _surfaceColor,
              contentPadding: EdgeInsets.symmetric(
                horizontal: Spacing.base,
                vertical: _effectiveMaxLines > 1 ? 16 : 14,
              ),
              border: _buildBorder(Radii.md),
              enabledBorder: _buildBorder(Radii.md),
              focusedBorder: _buildFocusedBorder(Radii.md),
              errorBorder: _buildErrorBorder(Radii.md),
              focusedErrorBorder: _buildFocusedErrorBorder(Radii.md),
              errorText: widget.errorMessage,
              errorStyle: AppTypography.labelSmall.copyWith(
                color: AppColorsPS5.error,
              ),
              counterText: '',
              disabledBorder: _buildDisabledBorder(Radii.md),
              semanticCounterText: widget.semanticCounterText,
            ),
          ),
        ),
        // ── Helper / Status Text ──
        if (widget.helperText != null ||
            widget.isSuccess && widget.successMessage != null ||
            widget.showCharacterCounter) ...[
          const SizedBox(height: Spacing.xxs),
          _buildBottomInfo(),
        ],
      ],
    );
  }

  // ─── Shadow ──────────────────────────────────────────────────────────

  /// Будує тінь залежно від стану фокусу/помилки/успіху.
  List<BoxShadow>? _buildFocusShadow() {
    if (!widget.focusGlowEnabled) return null;
    if (!widget.enabled) return null;

    if (_hasError && _hasFocus) {
      return [BoxShadow(color: _errorGlow, blurRadius: 16, spreadRadius: 1)];
    }
    if (widget.isSuccess && _hasFocus) {
      return [BoxShadow(color: _successGlow, blurRadius: 16, spreadRadius: 1)];
    }
    if (_hasFocus) {
      return [
        BoxShadow(color: _focusGlow, blurRadius: 16, spreadRadius: 1),
      ];
    }
    return null;
  }

  // ─── Borders ─────────────────────────────────────────────────────────

  /// Стандартна рамка.
  OutlineInputBorder _buildBorder(double radius) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(radius),
      borderSide: BorderSide(
        color: _borderColor,
        width: widget.isSuccess ? 2.0 : 1.5,
      ),
    );
  }

  /// Рамка при фокусі.
  OutlineInputBorder _buildFocusedBorder(double radius) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(radius),
      borderSide: BorderSide(
        color: widget.isSuccess
            ? AppColorsPS5.success
            : (widget.isLightTheme ? AppColorsMonitor.accent : AppColorsPS5.accent),
        width: 2.0,
      ),
    );
  }

  /// Рамка при помилці.
  OutlineInputBorder _buildErrorBorder(double radius) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(radius),
      borderSide: BorderSide(
        color: AppColorsPS5.error,
        width: 1.5,
      ),
    );
  }

  /// Рамка при помилці з фокусом.
  OutlineInputBorder _buildFocusedErrorBorder(double radius) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(radius),
      borderSide: const BorderSide(
        color: AppColorsPS5.error,
        width: 2.0,
      ),
    );
  }

  /// Рамка вимкненого поля.
  OutlineInputBorder _buildDisabledBorder(double radius) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(radius),
      borderSide: BorderSide(
        color: AppColorsPS5.border.withOpacity(0.5),
        width: 1.0,
      ),
    );
  }

  // ─── Prefix Icon ─────────────────────────────────────────────────────

  /// Будує іконку префіксу.
  Widget? _buildPrefixIcon() {
    if (widget.prefixWidget != null) return widget.prefixWidget;
    if (widget.prefixIcon != null) return widget.prefixIcon;
    final defaultIcon = widget.fieldType.defaultIcon;
    if (defaultIcon != null) {
      return Icon(defaultIcon, color: _textHint, size: 20);
    }
    return null;
  }

  // ─── Suffix Icons ───────────────────────────────────────────────────

  /// Будує суфіксні іконки (очищення, перемикач пароля, кастомна).
  Widget? _buildSuffixIcon() {
    if (widget.suffixWidget != null) return widget.suffixWidget;

    final icons = <Widget>[];

    // Кнопка очищення
    if (widget.showClearButton && _characterCount > 0 && !widget.readOnly) {
      icons.add(
        IconButton(
          icon: Icon(Icons.close_rounded, color: _textHint, size: 18),
          onPressed: _clearText,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          tooltip: 'Очистити',
        ),
      );
    }

    // Перемикач пароля
    if (widget.enablePasswordToggle) {
      icons.add(
        IconButton(
          icon: Icon(
            _obscured
                ? Icons.visibility_off_outlined
                : Icons.visibility_outlined,
            color: _textHint,
            size: 20,
          ),
          onPressed: _toggleObscure,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          tooltip: _obscured ? 'Показати пароль' : 'Приховати пароль',
        ),
      );
    }

    // Кастомна іконка
    if (widget.suffixIcon != null) {
      icons.add(widget.suffixIcon!);
    }

    if (icons.isEmpty) return null;
    if (icons.length == 1) return icons.first;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: icons,
    );
  }

  // ─── Bottom Info ─────────────────────────────────────────────────────

  /// Будує нижній інформаційний рядок.
  Widget _buildBottomInfo() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Допоміжний текст або статус
        Expanded(
          child: widget.isSuccess && widget.successMessage != null
              ? _buildSuccessInfo()
              : widget.helperText != null
                  ? Text(
                      widget.helperText!,
                      style: AppTypography.labelSmall.copyWith(
                        color: _textSecondary,
                      ),
                    )
                  : const SizedBox.shrink(),
        ),
        // Лічильник символів
        if (widget.showCharacterCounter && widget.maxLength != null) ...[
          const SizedBox(width: Spacing.sm),
          _buildCharacterCounter(),
        ],
      ],
    );
  }

  /// Будує індикатор успіху.
  Widget _buildSuccessInfo() {
    return Row(
      children: [
        Icon(
          Icons.check_circle_rounded,
          color: AppColorsPS5.success,
          size: 14,
        ),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            widget.successMessage!,
            style: AppTypography.labelSmall.copyWith(
              color: AppColorsPS5.success,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  /// Будує лічильник символів.
  Widget _buildCharacterCounter() {
    final isOverLimit = _characterCount >= widget.maxLength!;
    final color = isOverLimit ? AppColorsPS5.error : _textHint;

    return AnimatedDefaultTextStyle(
      duration: AppDurations.fast,
      style: AppTypography.labelSmall.copyWith(color: color),
      child: Text(
        '$_characterCount / ${widget.maxLength}',
      ),
    );
  }
}

// ─── Currency Input Formatter ───────────────────────────────────────────────

/// Форматувальник для вводу грошових сум.
///
/// Дозволяє вводити цифри та крапку/кому, автоматично форматуючи значення.
class _CurrencyInputFormatter extends TextInputFormatter {
  _CurrencyInputFormatter({this.symbol = '₴'});

  /// Символ валюти.
  final String symbol;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Дозволяємо лише цифри та роздільник
    final text = newValue.text.replaceAll(RegExp(r'[^\d.,]'), '');

    // Блокуємо зайві роздільники
    final parts = text.split(RegExp(r'[.,]'));
    if (parts.length > 2) {
      return oldValue;
    }

    // Обмежуємо 2 знаки після роздільника
    if (parts.length == 2 && parts[1].length > 2) {
      return oldValue;
    }

    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}

// ─── Utility Extensions ─────────────────────────────────────────────────────

/// Розширення для [TextFieldType] з додатковими методами.
extension TextFieldTypeExtension on TextFieldType {
  /// Чи тип потребує приховування вводу.
  bool get isSecret => this == TextFieldType.password;

  /// Чи тип потребує валідацію.
  bool get needsValidation =>
      this == TextFieldType.email ||
      this == TextFieldType.phone ||
      this == TextFieldType.url;

  /// Опис типу для accessibility.
  String get accessibilityDescription {
    switch (this) {
      case TextFieldType.text:
        return 'Текстове поле';
      case TextFieldType.number:
        return 'Числове поле';
      case TextFieldType.email:
        return 'Поле електронної пошти';
      case TextFieldType.search:
        return 'Поле пошуку';
      case TextFieldType.comment:
        return 'Поле коментаря';
      case TextFieldType.password:
        return 'Поле пароля';
      case TextFieldType.phone:
        return 'Поле номеру телефону';
      case TextFieldType.url:
        return 'Поле URL адреси';
    }
  }
}

/// Допоміжні методи для роботи з текстовими полями.
class AppTextFieldHelpers {
  AppTextFieldHelpers._();

  /// Створює стандартний валідатор для обов'язкового поля.
  static String? Function(String?) requiredValidator([String? label]) {
    final fieldName = label ?? 'Це поле';
    return (value) {
      if (value == null || value.trim().isEmpty) {
        return '$fieldName є обов\'язковим';
      }
      return null;
    };
  }

  /// Створює валідатор мінімальної довжини.
  static String? Function(String?) minLengthValidator(int minLength, [String? label]) {
    final fieldName = label ?? 'Це поле';
    return (value) {
      if (value == null || value.length < minLength) {
        return 'Мінімум $minLength символів для $fieldName';
      }
      return null;
    };
  }

  /// Створює валідатор максимальної довжини.
  static String? Function(String?) maxLengthValidator(int maxLength, [String? label]) {
    final fieldName = label ?? 'Це поле';
    return (value) {
      if (value != null && value.length > maxLength) {
        return 'Максимум $maxLength символів для $fieldName';
      }
      return null;
    };
  }

  /// Комбінує кілька валідаторів в один.
  static String? Function(String?) combineValidators(
    List<String? Function(String?)> validators,
  ) {
    return (value) {
      for (final validator in validators) {
        final error = validator(value);
        if (error != null) return error;
      }
      return null;
    };
  }

  /// Створює валідатор для формату email.
  ///
  /// Перевіряє наявність символу @ та коректного домену.
  /// Повертає [customMessage] або стандартне повідомлення про помилку.
  static String? Function(String?) emailValidator([String? customMessage]) {
    return (value) {
      if (value == null || value.isEmpty) return null;
      final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
      if (!emailRegex.hasMatch(value)) {
        return customMessage ?? 'Введіть коректну email адресу';
      }
      return null;
    };
  }

  /// Створює валідатор для формату URL.
  ///
  /// Перевіряє наявність схеми (http/https) та коректного хосту.
  static String? Function(String?) urlValidator([String? customMessage]) {
    return (value) {
      if (value == null || value.isEmpty) return null;
      final uri = Uri.tryParse(value);
      if (uri == null || !uri.hasScheme || !uri.host.contains('.')) {
        return customMessage ?? 'Введіть коректний URL';
      }
      return null;
    };
  }

  /// Створює валідатор для номера телефону (український формат).
  ///
  /// Приймає формати: +380XXXXXXXXX, 0XXXXXXXXX.
  static String? Function(String?) phoneValidator([String? customMessage]) {
    return (value) {
      if (value == null || value.isEmpty) return null;
      final digitsOnly = value.replaceAll(RegExp(r'[^\d]'), '');
      if (digitsOnly.length < 9 || digitsOnly.length > 12) {
        return customMessage ?? 'Введіть коректний номер телефону';
      }
      return null;
    };
  }

  /// Створює валідатор для числового значення з діапазоном.
  ///
  /// [min] — мінімальне допустиме значення.
  /// [max] — максимальне допустиме значення.
  /// Використовується для полів типу [TextFieldType.number] та [AppTextField.currency].
  static String? Function(String?) rangeValidator(
    double min,
    double max, {
    String? label,
  }) {
    final fieldName = label ?? 'Значення';
    return (value) {
      if (value == null || value.isEmpty) return null;
      final parsed = double.tryParse(value.replaceAll(',', '.'));
      if (parsed == null) return '$fieldName має бути числом';
      if (parsed < min) return '$fieldName не може бути менше $min';
      if (parsed > max) return '$fieldName не може бути більше $max';
      return null;
    };
  }

  /// Створює валідатор для формату пароля.
  ///
  /// Перевіряє мінімальну довжину, наявність великих літер та цифр.
  static String? Function(String?) passwordValidator({
    int minLength = 8,
    bool requireUppercase = true,
    bool requireDigit = true,
    String? customMessage,
  }) {
    return (value) {
      if (value == null || value.isEmpty) return null;
      if (value.length < minLength) {
        return customMessage ?? 'Пароль має містити мінімум $minLength символів';
      }
      if (requireUppercase && !value.contains(RegExp(r'[A-ZА-Я]'))) {
        return 'Пароль має містити мінімум одну велику літеру';
      }
      if (requireDigit && !value.contains(RegExp(r'[0-9]'))) {
        return 'Пароль має містити мінімум одну цифру';
      }
      return null;
    };
  }

  /// Створює валідатор для поля з шаблоном (regex).
  ///
  /// [pattern] — регулярний вираз для перевірки.
  /// [errorMessage] — повідомлення про помилку при невідповідності шаблону.
  static String? Function(String?) patternValidator(
    String pattern, {
    required String errorMessage,
  }) {
    final regex = RegExp(pattern);
    return (value) {
      if (value == null || value.isEmpty) return null;
      if (!regex.hasMatch(value)) return errorMessage;
      return null;
    };
  }
}

// ─── Additional Constants ─────────────────────────────────────────────────

/// Константи для налаштування текстових полів.
///
/// Містить стандартні значення для анімацій, розмірів, отступів
/// та інших параметрів, що використовуються у [AppTextField].
class AppTextFieldConstants {
  AppTextFieldConstants._();

  /// Стандартна висота текстового поля (однорядковий).
  static const double defaultHeight = 52.0;

  /// Стандартна висота багаторядкового текстового поля.
  static const double multilineMinHeight = 120.0;

  /// Стандартний розмір іконки префіксу.
  static const double prefixIconSize = 20.0;

  /// Стандартний розмір іконки суфіксу.
  static const double suffixIconSize = 18.0;

  /// Мінімальна ширина кнопки суфіксу.
  static const double suffixButtonMinWidth = 32.0;

  /// Мінімальна висота кнопки суфіксу.
  static const double suffixButtonMinHeight = 32.0;

  /// Стандартна ширина рамки при фокусі.
  static const double focusedBorderWidth = 2.0;

  /// Стандартна ширина рамки без фокусу.
  static const double unfocusedBorderWidth = 1.5;

  /// Стандартна ширина рамки при помилці без фокусу.
  static const double errorBorderWidth = 1.5;

  /// Стандартна ширина рамки при помилці з фокусом.
  static const double focusedErrorBorderWidth = 2.0;

  /// Стандартна ширина рамки вимкненого поля.
  static const double disabledBorderWidth = 1.0;

  /// Максимальна кількість символів для коментаря.
  static const int defaultCommentMaxLength = 500;

  /// Максимальна кількість символів для короткого тексту.
  static const int defaultTextMaxLength = 255;

  /// Максимальна кількість символів для пароля.
  static const int defaultPasswordMaxLength = 128;

  /// Максимальна кількість символів для номера телефону.
  static const int defaultPhoneMaxLength = 15;

  /// Максимальна кількість рядків для коментаря.
  static const int defaultMaxLines = 4;

  /// Мінімальна кількість рядків для багаторядкового поля.
  static const int defaultMinLines = 1;

  /// Стандартний радіус розмиття тіні при фокусі.
  static const double focusGlowBlurRadius = 16.0;

  /// Стандартний розмір поширення тіні при фокусі.
  static const double focusGlowSpreadRadius = 1.0;

  /// Непрозорість тіні при помилці.
  static const double errorGlowOpacity = 0.2;

  /// Непрозорість тіні при успіху.
  static const double successGlowOpacity = 0.15;

  /// Непрозорість вимкненого тексту.
  static const double disabledTextOpacity = 0.3;

  /// Непрозорість кольору рукоятки перетягування.
  static const double handleOpacity = 0.5;

  /// Непрозорість підсвітки пошукового терміну.
  static const double searchHighlightOpacity = 0.15;

  /// Стандартний розмір бейджу XP.
  static const double defaultXpBadgeSize = 28.0;

  /// Стандартний розмір індикатора статусу.
  static const double statusIndicatorSize = 10.0;

  /// Стандартний розмір індикатора обробки.
  static const double processingIndicatorSize = 16.0;

  /// Стандартна тривалість анімації появи бейджу.
  static const Duration badgeAnimationDuration = Duration(milliseconds: 200);

  /// Стандартна тривалість анімації тремтіння при помилці.
  static const Duration shakeAnimationDuration = Duration(milliseconds: 300);

  /// Стандартна амплітуда тремтіння.
  static const double shakeAnimationOffset = 4.0;

  /// Регулярний вираз для фільтрації числового вводу (з десятковою точкою).
  static final RegExp numericPattern = RegExp(r'[\d.,]');

  /// Регулярний вираз для видалення всіх нечислових символів.
  static final RegExp nonNumericPattern = RegExp(r'[^\d.,]');

  /// Регулярний вираз для видалення зайвих роздільників у валюті.
  static final RegExp decimalSeparatorPattern = RegExp(r'[.,]');

  /// Регулярний вираз для перевірки формату email.
  static final RegExp emailPattern =
      RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');

  /// Регулярний вираз для перевірки формату телефону.
  static final RegExp phonePattern = RegExp(r'^\+?[\d\s\-\(\)]{7,15}$');

  /// Регулярний вираз для перевірки наявності великої літери.
  static final RegExp uppercasePattern = RegExp(r'[A-ZА-Я]');

  /// Регулярний вираз для перевірки наявності цифри.
  static final RegExp digitPattern = RegExp(r'[0-9]');

  /// Регулярний вираз для перевірки наявності спеціального символу.
  static final RegExp specialCharPattern = RegExp(r'[!@#$%^&*(),.?":{}|<>]');
}

// ─── Theme-Aware Input Decorations ────────────────────────────────────────

/// Набір методів для створення темо-залежних прикрас вводу.
///
/// Використовується для створення一致性 (consistency) між різними
/// текстовими полями в додатку, незалежно від обраної теми.
class AppTextFieldDecorations {
  AppTextFieldDecorations._();

  /// Створює стандартну рамку для текстового поля.
  ///
  /// [radius] — радіус заокруглення рамки.
  /// [color] — колір рамки (якщо null — стандартний залежно від стану).
  /// [width] — товщина рамки (за замовчуванням 1.5).
  static OutlineInputBorder standardBorder({
    required double radius,
    Color? color,
    double width = 1.5,
  }) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(radius),
      borderSide: BorderSide(
        color: color ?? AppColorsPS5.border,
        width: width,
      ),
    );
  }

  /// Створює рамку з фокусом для текстового поля.
  ///
  /// [radius] — радіус заокруглення рамки.
  /// [isLightTheme] — чи використовувати світлу тему.
  /// [width] — товщина рамки (за замовчуванням 2.0).
  static OutlineInputBorder focusedBorder({
    required double radius,
    bool isLightTheme = false,
    double width = 2.0,
  }) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(radius),
      borderSide: BorderSide(
        color: isLightTheme ? AppColorsMonitor.accent : AppColorsPS5.accent,
        width: width,
      ),
    );
  }

  /// Створює рамку помилки для текстового поля.
  ///
  /// [radius] — радіус заокруглення рамки.
  /// [isFocused] — чи поле має фокус (впливає на товщину).
  static OutlineInputBorder errorBorder({
    required double radius,
    bool isFocused = false,
  }) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(radius),
      borderSide: BorderSide(
        color: AppColorsPS5.error,
        width: isFocused ? 2.0 : 1.5,
      ),
    );
  }

  /// Створює рамку успіху для текстового поля.
  ///
  /// [radius] — радіус заокруглення рамки.
  /// [isFocused] — чи поле має фокус (впливає на товщину).
  static OutlineInputBorder successBorder({
    required double radius,
    bool isFocused = false,
  }) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(radius),
      borderSide: BorderSide(
        color: AppColorsPS5.success,
        width: isFocused ? 2.0 : 2.0,
      ),
    );
  }

  /// Створює рамку вимкненого текстового поля.
  ///
  /// [radius] — радіус заокруглення рамки.
  static OutlineInputBorder disabledBorder({required double radius}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(radius),
      borderSide: BorderSide(
        color: AppColorsPS5.border.withOpacity(0.5),
        width: 1.0,
      ),
    );
  }

  /// Створює тінь для стану фокусу.
  ///
  /// [glowColor] — колір свічення.
  /// [blurRadius] — радіус розмиття.
  /// [spreadRadius] — радіус поширення.
  static List<BoxShadow> focusShadow({
    required Color glowColor,
    double blurRadius = 16.0,
    double spreadRadius = 1.0,
  }) {
    return [
      BoxShadow(
        color: glowColor,
        blurRadius: blurRadius,
        spreadRadius: spreadRadius,
      ),
    ];
  }

  /// Створює стандартне заповнення для текстового поля.
  ///
  /// [horizontal] — горизонтальний відступ (за замовчуванням Spacing.base).
  /// [vertical] — вертикальний відступ (за замовчуванням 14 для однорядкового).
  /// [isMultiline] — чи поле багаторядкове (впливає на вертикальний відступ).
  static EdgeInsets contentPadding({
    double horizontal = 16.0,
    double? vertical,
    bool isMultiline = false,
  }) {
    return EdgeInsets.symmetric(
      horizontal: horizontal,
      vertical: vertical ?? (isMultiline ? 16.0 : 14.0),
    );
  }

  /// Створює стиль підказки залежно від теми.
  ///
  /// [isLightTheme] — чи використовувати світлу тему.
  /// [overrideColor] — кастомний колір (перевизначає темну/світлу логіку).
  static TextStyle hintStyle({
    bool isLightTheme = false,
    Color? overrideColor,
  }) {
    return AppTypography.bodyLarge.copyWith(
      color: overrideColor ??
          (isLightTheme ? AppColorsMonitor.textHint : AppColorsPS5.textHint),
    );
  }

  /// Створює стиль тексту залежно від теми.
  ///
  /// [isLightTheme] — чи використовувати світлу тему.
  /// [isEnabled] — чи поле ввімкнене.
  /// [overrideColor] — кастомний колір тексту.
  static TextStyle textStyle({
    bool isLightTheme = false,
    bool isEnabled = true,
    Color? overrideColor,
  }) {
    final baseColor = isLightTheme
        ? AppColorsMonitor.textPrimary
        : AppColorsPS5.textPrimary;
    return AppTypography.bodyLarge.copyWith(
      color: isEnabled
          ? (overrideColor ?? baseColor)
          : AppColorsPS5.textHint.withOpacity(0.3),
    );
  }
}

// ─── Computed Properties Extension ────────────────────────────────────────

/// Розширення для [_AppTextFieldState] з обчислюваними властивостями.
///
/// Забезпечує швидкий доступ до комплексних значень, що залежать
/// від комбінації кількох полів віджета.
extension AppTextFieldComputedProperties on AppTextField {
  /// Чи поле є обов'язковим для заповнення.
  ///
  /// Обчислюється на основі наявності валідатора та типу поля.
  bool get isRequired =>
      validator != null ||
      fieldType.needsValidation;

  /// Чи поле підтримує очищення тексту.
  ///
  /// Обчислюється на основі прапорців showClearButton, readOnly та enabled.
  bool get canClear => showClearButton && !readOnly && enabled;

  /// Чи поле має додатковий контент (іконки, бейджі).
  ///
  /// Обчислюється на основі наявності prefixIcon, suffixIcon, prefixWidget,
  /// suffixWidget, isCurrency, showClearButton, enablePasswordToggle.
  bool get hasDecorations =>
      prefixIcon != null ||
      suffixIcon != null ||
      prefixWidget != null ||
      suffixWidget != null ||
      isCurrency ||
      showClearButton ||
      enablePasswordToggle;

  /// Ефективна максимальна кількість символів.
  ///
  /// Повертає maxLength або значення за замовчуванням для типу поля.
  int? get effectiveMaxLength {
    if (maxLength != null) return maxLength;
    switch (fieldType) {
      case TextFieldType.phone:
        return 15;
      case TextFieldType.password:
        return 128;
      case TextFieldType.comment:
        return 500;
      default:
        return null;
    }
  }

  /// Ефективний текст-підказка для accessibility.
  ///
  /// Оббирається з labelText або fieldType.label.
  String get accessibilityHint => labelText ?? fieldType.label;

  /// Опис стану поля для accessibility.
  ///
  /// Включає тип поля, поточний стан (фокус, помилка, успіх).
  String get accessibilityState {
    final parts = <String>[fieldType.accessibilityDescription];
    if (errorMessage != null) parts.add('з помилкою');
    if (isSuccess) parts.add('успішно');
    if (readOnly) parts.add('тільки для читання');
    if (!enabled) parts.add('вимкнено');
    return parts.join(', ');
  }
}

// ─── Text Field State Listener ────────────────────────────────────────────

/// Інтерфейс для прослуховування змін стану текстового поля.
///
/// Реалізується віджетами-батьками, яким потрібно знати про зміну
/// стану фокусу, валідації чи кількості символів.
abstract class AppTextFieldListener {
  /// Викликається при отриманні полем фокусу.
  void onTextFieldFocused(String fieldKey);

  /// Викликається при втраті полем фокусу.
  void onTextFieldUnfocused(String fieldKey);

  /// Викликається при зміні тексту в полі.
  void onTextFieldChanged(String fieldKey, String value);

  /// Викликається при виявленні помилки валідації.
  void onTextFieldError(String fieldKey, String error);

  /// Викликається при успішній валідації.
  void onTextFieldValid(String fieldKey);
}

/// Базова реалізація [AppTextFieldListener] з логуванням.
///
/// Використовується для відладки та як шаблон для створення
/// специфічних слухачів.
class LoggingTextFieldListener implements AppTextFieldListener {
  LoggingTextFieldListener({this.tag = 'default'});

  /// Тег для ідентифікації слухача в логах.
  final String tag;

  @override
  void onTextFieldFocused(String fieldKey) {
    TextFieldDebugConfig.log('[$tag] Focused: $fieldKey', tag: 'listener');
  }

  @override
  void onTextFieldUnfocused(String fieldKey) {
    TextFieldDebugConfig.log('[$tag] Unfocused: $fieldKey', tag: 'listener');
  }

  @override
  void onTextFieldChanged(String fieldKey, String value) {
    TextFieldDebugConfig.log(
      '[$tag] Changed: $fieldKey → "${value.length} chars"',
      tag: 'listener',
    );
  }

  @override
  void onTextFieldError(String fieldKey, String error) {
    TextFieldDebugConfig.log(
      '[$tag] Error: $fieldKey → $error',
      tag: 'listener',
    );
  }

  @override
  void onTextFieldValid(String fieldKey) {
    TextFieldDebugConfig.log(
      '[$tag] Valid: $fieldKey',
      tag: 'listener',
    );
  }
}

// ─── Phone Number Formatter ───────────────────────────────────────────────

/// Форматувальник для вводу номера телефону.
///
/// Автоматично додає форматування (пробіли, дужки) під час вводу.
class _PhoneInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Дозволяємо лише цифри, +, пробіли, дужки та дефіси
    final text = newValue.text.replaceAll(RegExp(r'[^\d+\s\-\(\)]'), '');

    // Форматуємо український номер: +380 XX XXX XX XX
    if (text.startsWith('+380') && text.length > 4) {
      final digits = text.replaceAll(RegExp(r'[^\d]'), '');
      if (digits.length <= 4) {
        return newValue.copyWith(text: '+$digits', selection: _endSelection(text));
      }
      final buffer = StringBuffer('+');
      buffer.write(digits.substring(1, 4)); // 380
      if (digits.length > 4) buffer.write(' ${digits.substring(4, digits.length.clamp(4, 6))}');
      if (digits.length > 6) buffer.write(' ${digits.substring(6, digits.length.clamp(6, 8))}');
      if (digits.length > 8) buffer.write(' ${digits.substring(8, digits.length.clamp(8, 10))}');
      if (digits.length > 10) buffer.write(' ${digits.substring(10, digits.length.clamp(10, 12))}');

      return TextEditingValue(
        text: buffer.toString(),
        selection: TextSelection.collapsed(offset: buffer.length),
      );
    }

    if (text != newValue.text) {
      return TextEditingValue(
        text: text,
        selection: TextSelection.collapsed(offset: text.length),
      );
    }

    return newValue;
  }

  TextSelection _endSelection(String text) {
    return TextSelection.collapsed(offset: text.length);
  }
}

// ─── Debounced Text Change Handler ────────────────────────────────────────

/// Обробник змін тексту з затримкою (debounce).
///
/// Корисний для полів пошуку, де не потрібно викликати onChanged
/// при кожному натисканні клавіші.
class DebouncedTextHandler {
  DebouncedTextHandler({
    required this.onDebounced,
    this.delay = const Duration(milliseconds: 300),
  });

  /// Callback після затримки.
  final ValueChanged<String> onDebounced;

  /// Затримка перед викликом callback.
  final Duration delay;

  DateTime? _lastChangeTime;
  String? _pendingValue;

  /// Обробляє зміну тексту з затримкою.
  void handle(String value) {
    _pendingValue = value;
    _lastChangeTime = DateTime.now();
    Future.delayed(delay, () {
      if (_pendingValue == value &&
          _lastChangeTime != null &&
          DateTime.now().difference(_lastChangeTime!) >= delay) {
        onDebounced(value);
      }
    });
  }

  /// Скидає стан обробника.
  void reset() {
    _pendingValue = null;
    _lastChangeTime = null;
  }

  /// Скасовує відкладений виклик.
  void cancel() {
    _pendingValue = null;
    _lastChangeTime = null;
  }
}
