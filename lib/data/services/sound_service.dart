import 'dart:async';
import 'package:audioplayers/audioplayers.dart';

/// Категорії звукових ефектів.
enum SoundCategory {
  /// Звуки інтерфейсу (натискання, свайпи).
  ui,

  /// Звуки пов'язані з грошим (монети, внески).
  money,

  /// Звуки досягнень (бейджі, рівні, челенджі).
  achievement,

  /// Звуки помилок.
  error,

  /// Фонові звуки (мережива, атмосфера).
  ambient,

  /// Звуки святкування (конфеті, фінал).
  celebration,

  /// Звуки нотифікацій (сповіщення, нагадування).
  notification,

  /// Звуки навколишнього середовища (природа, місто).
  environmental;
}

/// Типи звукових ефектів.
enum SoundType {
  /// Натискання кнопки.
  click,

  /// Дзвін монет.
  coinDing,

  /// Акорд досягнення мілістону.
  milestone,

  /// Фанфари (велика подія).
  fanfare,

  /// XP «зап».
  xpZap,

  /// Помилка.
  error,

  /// Свайп.
  swipe,

  /// Мереживний звук (завантаження, відкриття).
  shimmer,

  /// Фанфари розблокування бейджу.
  badgeUnlocked,

  /// Pull-to-refresh звук.
  pullToRefresh,

  /// Навігація між екранами.
  navigate,

  /// Перемикання.
  toggle,

  /// Успіх.
  success,

  /// Попередження.
  warning,

  /// Фоновий звук (заглушка).
  backgroundMusic,

  /// Звук конфеті святкування.
  confetti,

  /// Звук монети, що падає.
  coinDrop,

  /// Звук підвищення рівня.
  levelUp,

  /// Звук розблокування досягнення.
  achievementUnlock,

  /// Легкий натиск (для UI).
  lightTap,

  /// Звук таймера.
  timerTick,

  /// Звук завершення цілі.
  goalComplete,

  /// Звук нотифікації.
  notification,

  /// Звук відкриття штори.
  curtainOpen,

  /// Звук закриття штори.
  curtainClose,

  /// Звук зірки (досягнення зірки).
  starEarned,
}

/// Конфігурація звукової події.
class SoundConfig {
  /// Тип звуку.
  final SoundType type;

  /// Шлях до аудіофайлу.
  final String assetPath;

  /// Категорія звуку.
  final SoundCategory category;

  /// Гучність за замовчуванням (множник від 0.0 до 1.0).
  final double defaultVolume;

  /// Чи можна відтворювати паралельно з іншими.
  final bool allowOverlap;

  /// Тривалість звуку в мілісекундах (приблизно).
  final int? durationMs;

  const SoundConfig({
    required this.type,
    required this.assetPath,
    required this.category,
    this.defaultVolume = 1.0,
    this.allowOverlap = false,
    this.durationMs,
  });
}

/// Елемент черги звукових ефектів.
class _SoundQueueItem {
  final SoundType type;
  final double? customVolume;
  final Duration? delay;
  const _SoundQueueItem(this.type, {this.customVolume, this.delay});
}

/// пресет гучності.
class VolumePreset {
  final String name;
  final double uiVolume;
  final double moneyVolume;
  final double achievementVolume;
  final double ambientVolume;
  final double celebrationVolume;
  final double notificationVolume;

  const VolumePreset({
    required this.name,
    required this.uiVolume,
    required this.moneyVolume,
    required this.achievementVolume,
    required this.ambientVolume,
    required this.celebrationVolume,
    required this.notificationVolume,
  });
}

/// пресет гучності залежно від теми.
class ThemeSoundPreset {
  final String themeName;
  final double masterVolume;
  final Map<SoundCategory, double> categoryOverrides;

  const ThemeSoundPreset({
    required this.themeName,
    required this.masterVolume,
    this.categoryOverrides = const {},
  });
}

/// Пресети еквалайзера для різних сценаріїв.
///
/// Кожен пресет визначає множники для різних частот.
class EqualizerPreset {
  final String name;
  final String description;
  final double bass;
  final double mid;
  final double treble;

  const EqualizerPreset({
    required this.name,
    required this.description,
    required this.bass,
    required this.mid,
    required this.treble,
  });

  /// Стандартний (плоский) пресет.
  static const standard = EqualizerPreset(
    name: 'Стандартний',
    description: 'Плоский еквалайзер без посилення',
    bass: 1.0,
    mid: 1.0,
    treble: 1.0,
  );

  /// Басовий пресет — підсилює низькі частоти.
  static const bass = EqualizerPreset(
    name: 'Басовий',
    description: 'Посилення басів для глибокого звуку',
    bass: 1.5,
    mid: 1.0,
    treble: 0.9,
  );

  /// Яскравий пресет — підсилює високі частоти.
  static const bright = EqualizerPreset(
    name: 'Яскравий',
    description: 'Чіткі високі частоти для монет та фанфар',
    bass: 0.9,
    mid: 1.1,
    treble: 1.4,
  );

  /// М'який пресет — зменшує високі частоти.
  static const soft = EqualizerPreset(
    name: 'М\'який',
    description: 'Приглушений звук для нічного режиму',
    bass: 1.1,
    mid: 0.9,
    treble: 0.7,
  );

  /// Усі пресети для вибору.
  static const all = [standard, bass, bright, soft];
}

/// Групи звуків для зручного управління.
///
/// Кожна група містить список типів звуків, що належать до неї.
class SoundGroup {
  final String name;
  final String description;
  final List<SoundType> soundTypes;

  const SoundGroup({
    required this.name,
    required this.description,
    required this.soundTypes,
  });

  /// Звуки інтерфейсу (натискання, навігація, перемикання).
  static const ui = SoundGroup(
    name: 'Інтерфейс',
    description: 'Звуки натискань, навігації та перемикань',
    soundTypes: [SoundType.click, SoundType.lightTap, SoundType.navigate, SoundType.toggle, SoundType.swipe],
  );

  /// Звуки святкування (конфеті, фанфари, рівні).
  static const celebration = SoundGroup(
    name: 'Святкування',
    description: 'Звуки досягнень, рівнів та святкувань',
    soundTypes: [SoundType.confetti, SoundType.fanfare, SoundType.levelUp, SoundType.badgeUnlocked, SoundType.achievementUnlock, SoundType.starEarned],
  );

  /// Звуки нотифікацій (сповіщення, нагадування).
  static const notification = SoundGroup(
    name: 'Сповіщення',
    description: 'Звуки нотифікацій, попереджень та нагадувань',
    soundTypes: [SoundType.notification, SoundType.warning, SoundType.error],
  );

  /// Фонові та навколишні звуки.
  static const ambient = SoundGroup(
    name: 'Навколишнє',
    description: 'Фонова музика та звуки середовища',
    soundTypes: [SoundType.backgroundMusic, SoundType.shimmer],
  );

  /// Усі групи.
  static const all = [ui, celebration, notification, ambient];

  /// Знаходить групу за типом звуку.
  static SoundGroup? findGroupForType(SoundType type) {
    for (final group in all) {
      if (group.soundTypes.contains(type)) return group;
    }
    return null;
  }
}

/// Сервіс управління звуковими ефектами.
///
/// Відтворює звукові ефекти для різних подій у додатку:
/// натискання, отримання монет, досягнення етапу тощо.
///
/// Усі виклики обгорнуті в try-catch, тому відсутність аудіофайлів
/// не призведе до падіння додатку.
///
/// Містить: розширені пресети звуків, управління категоріями,
/// пресети гучності, методи згасання звуку, управління чергою,
/// підтримку фонових звуків, синхронізацію тактильного зворотного зв'язку
/// зі звуком, пресети залежно від теми, еквалайзер, групи звуків,
/// crossfade, ducking, управління сесією аудіо.
class SoundService {
  SoundService() {
    _player = AudioPlayer();
    _overlayPlayer = AudioPlayer();
    _ambientPlayer = AudioPlayer();
    _initSoundConfigs();
    _initVolumePresets();
    _initThemePresets();
  }

  late final AudioPlayer _player;
  late final AudioPlayer _overlayPlayer;
  late final AudioPlayer _ambientPlayer;

  /// Чи увімкнено звуки загалом.
  bool _enabled = true;

  /// Загальна гучність (0.0–1.0).
  double _volume = 0.7;

  /// Гучність за категорією (множник від 0.0 до 1.0).
  final Map<SoundCategory, double> _categoryVolumes = {
    SoundCategory.ui: 0.5,
    SoundCategory.money: 0.8,
    SoundCategory.achievement: 0.9,
    SoundCategory.error: 0.7,
    SoundCategory.ambient: 0.3,
    SoundCategory.celebration: 1.0,
    SoundCategory.notification: 0.6,
    SoundCategory.environmental: 0.4,
  };

  /// Конфігурації звуків.
  final Map<SoundType, SoundConfig> _configs = {};

  /// Глушаться категорії.
  final Set<SoundCategory> _mutedCategories = {};

  /// Заглушені групи звуків.
  final Set<String> _mutedGroups = {};

  /// Черга звукових ефектів.
  final List<_SoundQueueItem> _soundQueue = [];

  /// Чи обробляється черга зараз.
  bool _isProcessingQueue = false;

  /// Пресети гучності.
  final Map<String, VolumePreset> _volumePresets = {};

  /// Пресети залежно від теми.
  final Map<String, ThemeSoundPreset> _themePresets = {};

  /// Поточний пресет гучності.
  String _currentVolumePreset = 'Стандартний';

  /// Поточна тема.
  String _currentTheme = 'Темна';

  /// Чи увімкнена синхронізація з тактильним зворотним зв'язком.
  bool _hapticSync = true;

  /// Стан згасання.
  bool _isFading = false;
  double _fadeTarget = 0.0;

  /// Поточний пресет еквалайзера.
  EqualizerPreset _equalizerPreset = EqualizerPreset.standard;

  /// Стан приглушення під час мовлення.
  bool _isDucking = false;
  double _duckVolume = 1.0;

  /// Стан аудіо сесії (чи активна).
  bool _audioSessionActive = true;

  /// Чи відстежувати гучність пристрою.
  bool _deviceVolumeMonitoring = false;

  /// Гучність пристрою (0.0–1.0).
  double _deviceVolume = 1.0;

  /// Чи увімкнено автоматичне вимкнення під час дзвінка.
  bool _muteDuringCalls = true;

  /// Налаштування звуку на true або false.
  void setEnabled(bool enabled) {
    _enabled = enabled;
    if (!enabled) {
      _player.stop();
      _overlayPlayer.stop();
      _ambientPlayer.stop();
    }
  }

  /// Чи увімкнено звуки.
  bool get isEnabled => _enabled;

  /// Встановлює загальну гучність (0.0–1.0).
  void setVolume(double volume) {
    _volume = volume.clamp(0.0, 1.0);
  }

  /// Повертає загальну гучність.
  double get volume => _volume;

  /// Встановлює гучність для категорії (0.0–1.0).
  void setCategoryVolume(SoundCategory category, double volume) {
    _categoryVolumes[category] = volume.clamp(0.0, 1.0);
  }

  /// Повертає гучність для категорії.
  double getCategoryVolume(SoundCategory category) {
    return _categoryVolumes[category] ?? 1.0;
  }

  /// Глушить/знімає глушення категорії.
  void toggleCategoryMute(SoundCategory category) {
    if (_mutedCategories.contains(category)) {
      _mutedCategories.remove(category);
    } else {
      _mutedCategories.add(category);
    }
  }

  /// Чи заглушена категорія.
  bool isCategoryMuted(SoundCategory category) {
    return _mutedCategories.contains(category);
  }

  /// Повертає всі заглушені категорії.
  Set<SoundCategory> get mutedCategories => Set.unmodifiable(_mutedCategories);

  /// Глушить/знімає глушення групи звуків.
  void toggleGroupMute(String groupName) {
    if (_mutedGroups.contains(groupName)) {
      _mutedGroups.remove(groupName);
    } else {
      _mutedGroups.add(groupName);
    }
  }

  /// Чи заглушена група звуків.
  bool isGroupMuted(String groupName) {
    return _mutedGroups.contains(groupName);
  }

  /// Встановлює пресет еквалайзера.
  void setEqualizerPreset(EqualizerPreset preset) {
    _equalizerPreset = preset;
  }

  /// Повертає поточний пресет еквалайзера.
  EqualizerPreset get equalizerPreset => _equalizerPreset;

  /// Перемикає синхронізацію з тактильним зворотним зв'язком.
  void setHapticSync(bool enabled) {
    _hapticSync = enabled;
  }

  /// Чи увімкнена синхронізація з тактильним зворотним зв'язком.
  bool get hapticSync => _hapticSync;

  // ── Ініціалізація конфігурацій ─────────────────────────────

  /// Ініціалізує конфігурації для всіх звукових ефектів.
  void _initSoundConfigs() {
    const configs = [
      SoundConfig(type: SoundType.click, assetPath: 'sounds/click.mp3', category: SoundCategory.ui, defaultVolume: 0.5, durationMs: 80),
      SoundConfig(type: SoundType.coinDing, assetPath: 'sounds/coin_ding.mp3', category: SoundCategory.money, defaultVolume: 0.8, durationMs: 300),
      SoundConfig(type: SoundType.milestone, assetPath: 'sounds/milestone.mp3', category: SoundCategory.achievement, defaultVolume: 0.9, durationMs: 800),
      SoundConfig(type: SoundType.fanfare, assetPath: 'sounds/fanfare.mp3', category: SoundCategory.achievement, defaultVolume: 1.0, durationMs: 2000),
      SoundConfig(type: SoundType.xpZap, assetPath: 'sounds/xp_zap.mp3', category: SoundCategory.money, defaultVolume: 0.6, durationMs: 150),
      SoundConfig(type: SoundType.error, assetPath: 'sounds/error.mp3', category: SoundCategory.error, defaultVolume: 0.7, durationMs: 400),
      SoundConfig(type: SoundType.swipe, assetPath: 'sounds/swipe.mp3', category: SoundCategory.ui, defaultVolume: 0.3, durationMs: 100),
      SoundConfig(type: SoundType.shimmer, assetPath: 'sounds/shimmer.mp3', category: SoundCategory.ambient, defaultVolume: 0.4, allowOverlap: true, durationMs: 500),
      SoundConfig(type: SoundType.badgeUnlocked, assetPath: 'sounds/badge_fanfare.mp3', category: SoundCategory.achievement, defaultVolume: 0.85, durationMs: 1200),
      SoundConfig(type: SoundType.pullToRefresh, assetPath: 'sounds/pull_to_refresh.mp3', category: SoundCategory.ui, defaultVolume: 0.4, durationMs: 200),
      SoundConfig(type: SoundType.navigate, assetPath: 'sounds/navigate.mp3', category: SoundCategory.ui, defaultVolume: 0.35, durationMs: 150),
      SoundConfig(type: SoundType.toggle, assetPath: 'sounds/toggle.mp3', category: SoundCategory.ui, defaultVolume: 0.45, durationMs: 100),
      SoundConfig(type: SoundType.success, assetPath: 'sounds/success.mp3', category: SoundCategory.achievement, defaultVolume: 0.75, durationMs: 500),
      SoundConfig(type: SoundType.warning, assetPath: 'sounds/warning.mp3', category: SoundCategory.error, defaultVolume: 0.6, durationMs: 600),
      SoundConfig(type: SoundType.backgroundMusic, assetPath: 'sounds/background.mp3', category: SoundCategory.ambient, defaultVolume: 0.2, allowOverlap: true),
      SoundConfig(type: SoundType.confetti, assetPath: 'sounds/confetti.mp3', category: SoundCategory.celebration, defaultVolume: 0.9, durationMs: 1500),
      SoundConfig(type: SoundType.coinDrop, assetPath: 'sounds/coin_drop.mp3', category: SoundCategory.money, defaultVolume: 0.7, durationMs: 250),
      SoundConfig(type: SoundType.levelUp, assetPath: 'sounds/level_up.mp3', category: SoundCategory.achievement, defaultVolume: 0.95, durationMs: 1000),
      SoundConfig(type: SoundType.achievementUnlock, assetPath: 'sounds/achievement_unlock.mp3', category: SoundCategory.celebration, defaultVolume: 0.9, durationMs: 1800),
      SoundConfig(type: SoundType.lightTap, assetPath: 'sounds/light_tap.mp3', category: SoundCategory.ui, defaultVolume: 0.25, durationMs: 50),
      SoundConfig(type: SoundType.timerTick, assetPath: 'sounds/timer_tick.mp3', category: SoundCategory.ui, defaultVolume: 0.3, durationMs: 80),
      SoundConfig(type: SoundType.goalComplete, assetPath: 'sounds/goal_complete.mp3', category: SoundCategory.celebration, defaultVolume: 1.0, durationMs: 3000),
      SoundConfig(type: SoundType.notification, assetPath: 'sounds/notification.mp3', category: SoundCategory.notification, defaultVolume: 0.5, durationMs: 400),
      SoundConfig(type: SoundType.curtainOpen, assetPath: 'sounds/curtain_open.mp3', category: SoundCategory.ui, defaultVolume: 0.3, durationMs: 200),
      SoundConfig(type: SoundType.curtainClose, assetPath: 'sounds/curtain_close.mp3', category: SoundCategory.ui, defaultVolume: 0.3, durationMs: 200),
      SoundConfig(type: SoundType.starEarned, assetPath: 'sounds/star_earned.mp3', category: SoundCategory.celebration, defaultVolume: 0.8, durationMs: 600),
    ];

    for (final config in configs) {
      _configs[config.type] = config;
    }
  }

  /// Ініціалізує пресети гучності.
  void _initVolumePresets() {
    _volumePresets['Тихий'] = const VolumePreset(
      name: 'Тихий', uiVolume: 0.2, moneyVolume: 0.3, achievementVolume: 0.4, ambientVolume: 0.1,
      celebrationVolume: 0.3, notificationVolume: 0.2,
    );
    _volumePresets['Стандартний'] = const VolumePreset(
      name: 'Стандартний', uiVolume: 0.5, moneyVolume: 0.8, achievementVolume: 0.9, ambientVolume: 0.3,
      celebrationVolume: 1.0, notificationVolume: 0.6,
    );
    _volumePresets['Голосний'] = const VolumePreset(
      name: 'Голосний', uiVolume: 0.8, moneyVolume: 1.0, achievementVolume: 1.0, ambientVolume: 0.5,
      celebrationVolume: 1.0, notificationVolume: 0.8,
    );
    _volumePresets['Без звуку'] = const VolumePreset(
      name: 'Без звуку', uiVolume: 0.0, moneyVolume: 0.0, achievementVolume: 0.0, ambientVolume: 0.0,
      celebrationVolume: 0.0, notificationVolume: 0.0,
    );
  }

  /// Ініціалізує пресети залежно від теми.
  void _initThemePresets() {
    _themePresets['Темна'] = const ThemeSoundPreset(
      themeName: 'Темна', masterVolume: 0.7,
      categoryOverrides: {SoundCategory.achievement: 1.0, SoundCategory.celebration: 1.0},
    );
    _themePresets['Світла'] = const ThemeSoundPreset(
      themeName: 'Світла', masterVolume: 0.6,
      categoryOverrides: {SoundCategory.ui: 0.4, SoundCategory.ambient: 0.2},
    );
    _themePresets['Святкування'] = const ThemeSoundPreset(
      themeName: 'Святкування', masterVolume: 1.0,
      categoryOverrides: {SoundCategory.celebration: 1.0, SoundCategory.money: 1.0},
    );
    _themePresets['Нічний'] = const ThemeSoundPreset(
      themeName: 'Нічний', masterVolume: 0.3,
      categoryOverrides: {SoundCategory.ui: 0.2, SoundCategory.ambient: 0.1, SoundCategory.achievement: 0.5},
    );
  }

  // ── Відтворення звуків ─────────────────────────────────────

  /// Відтворює звуковий ефект за типом.
  Future<void> play(SoundType type) async {
    if (!_enabled) return;
    if (!_audioSessionActive) return;

    final config = _configs[type];
    if (config == null) return;

    // Перевіряємо, чи категорія не заглушена.
    if (_mutedCategories.contains(config.category)) return;

    // Перевіряємо, чи група не заглушена.
    final group = SoundGroup.findGroupForType(type);
    if (group != null && _mutedGroups.contains(group.name)) return;

    // Застосовуємо еквалайзер
    final eqMultiplier = _getEqualizerMultiplier(config.category);
    final duckMultiplier = _isDucking ? 0.3 : 1.0;
    final effectiveVolume = _volume * config.defaultVolume * (_categoryVolumes[config.category] ?? 1.0) * eqMultiplier * duckMultiplier;

    try {
      final player = config.allowOverlap ? _overlayPlayer : _player;
      await player.play(
        AssetSource(config.assetPath),
        volume: effectiveVolume.clamp(0.0, 1.0),
      );
    } catch (_) {
      // Тихо ігноруємо помилку — файл може бути відсутній.
    }
  }

  /// Обчислює множник еквалайзера для категорії.
  double _getEqualizerMultiplier(SoundCategory category) {
    switch (category) {
      case SoundCategory.ui:
      case SoundCategory.money:
        return _equalizerPreset.treble;
      case SoundCategory.achievement:
      case SoundCategory.celebration:
        return _equalizerPreset.mid;
      case SoundCategory.ambient:
      case SoundCategory.environmental:
        return _equalizerPreset.bass;
      default:
        return 1.0;
    }
  }

  /// Відтворює звук із користувацькою гучністю.
  Future<void> playWithVolume(SoundType type, double customVolume) async {
    if (!_enabled) return;

    final config = _configs[type];
    if (config == null) return;
    if (_mutedCategories.contains(config.category)) return;

    try {
      final player = config.allowOverlap ? _overlayPlayer : _player;
      await player.play(
        AssetSource(config.assetPath),
        volume: customVolume.clamp(0.0, 1.0),
      );
    } catch (_) {}
  }

  /// Плавний перехід між двома звуками (crossfade).
  ///
  /// [from] — звук, що згасає.
  /// [to] — звук, що з'являється.
  /// [duration] — тривалість переходу.
  Future<void> crossfade(SoundType from, SoundType to, {Duration duration = const Duration(milliseconds: 500)}) async {
    final fadeOutMs = duration.inMilliseconds ~/ 2;
    await fadeTo(0.0, duration: Duration(milliseconds: fadeOutMs));
    await play(to);
    await fadeTo(_volume, duration: Duration(milliseconds: fadeOutMs));
  }

  /// Зупиняє всі звуки.
  Future<void> stopAll() async {
    try {
      await _player.stop();
      await _overlayPlayer.stop();
      await _ambientPlayer.stop();
    } catch (_) {}
  }

  /// Ставить на паузу всі звуки.
  Future<void> pauseAll() async {
    try {
      await _player.pause();
      await _overlayPlayer.pause();
      await _ambientPlayer.pause();
    } catch (_) {}
  }

  /// Продовжує відтворення всіх звуків.
  Future<void> resumeAll() async {
    if (!_enabled) return;
    try {
      await _player.resume();
      await _overlayPlayer.resume();
      await _ambientPlayer.resume();
    } catch (_) {}
  }

  // ── Ducking (приглушення під час мовлення) ─────────────────

  /// Увімкнути приглушення (нижча гучність під час мовлення).
  void startDucking() {
    if (_isDucking) return;
    _isDucking = true;
    _duckVolume = _volume;
    // Згасаємо до 30% поточної гучності
    fadeTo(_volume * 0.3, duration: const Duration(milliseconds: 200));
  }

  /// Вимкнути приглушення (відновлюємо гучність).
  void stopDucking() {
    if (!_isDucking) return;
    _isDucking = false;
    // Відновлюємо гучність
    fadeTo(_duckVolume, duration: const Duration(milliseconds: 300));
  }

  /// Чи зараз активне приглушення.
  bool get isDucking => _isDucking;

  // ── Методи згасання звуку ─────────────────────────────────

  /// Плавно згасає всі звуки до вказаної гучності.
  Future<void> fadeTo(double targetVolume, {Duration duration = const Duration(milliseconds: 500)}) async {
    _isFading = true;
    _fadeTarget = targetVolume;
    final steps = 20;
    final stepDuration = duration.milliseconds ~/ steps;
    final currentVol = _volume;
    final diff = targetVolume - currentVol;

    for (int i = 1; i <= steps; i++) {
      await Future.delayed(Duration(milliseconds: stepDuration));
      if (!_isFading) break;
      _volume = (currentVol + diff * (i / steps)).clamp(0.0, 1.0);
    }
    _isFading = false;
  }

  /// Скасовує згасання.
  void cancelFade() {
    _isFading = false;
  }

  // ── Управління чергою звуків ───────────────────────────────

  /// Додає звук до черги.
  void enqueue(SoundType type, {double? volume, Duration? delay}) {
    _soundQueue.add(_SoundQueueItem(type, customVolume: volume, delay: delay));
    if (!_isProcessingQueue) _processQueue();
  }

  /// Обробляє чергу звукових ефектів.
  Future<void> _processQueue() async {
    _isProcessingQueue = true;
    while (_soundQueue.isNotEmpty) {
      final item = _soundQueue.removeAt(0);
      if (item.delay != null) {
        await Future.delayed(item.delay!);
      }
      if (item.customVolume != null) {
        await playWithVolume(item.type, item.customVolume!);
      } else {
        await play(item.type);
      }
      // Чекаємо завершення звуку (приблизно)
      final config = _configs[item.type];
      if (config?.durationMs != null) {
        await Future.delayed(Duration(milliseconds: config!.durationMs! + 50));
      }
    }
    _isProcessingQueue = false;
  }

  /// Очищає чергу.
  void clearQueue() {
    _soundQueue.clear();
  }

  /// Чи черга порожня.
  bool get isQueueEmpty => _soundQueue.isEmpty;

  // ── Пресети гучності ───────────────────────────────────────

  /// Застосовує пресет гучності.
  void applyVolumePreset(String name) {
    final preset = _volumePresets[name];
    if (preset == null) return;
    _currentVolumePreset = name;
    _categoryVolumes[SoundCategory.ui] = preset.uiVolume;
    _categoryVolumes[SoundCategory.money] = preset.moneyVolume;
    _categoryVolumes[SoundCategory.achievement] = preset.achievementVolume;
    _categoryVolumes[SoundCategory.ambient] = preset.ambientVolume;
    _categoryVolumes[SoundCategory.celebration] = preset.celebrationVolume;
    _categoryVolumes[SoundCategory.notification] = preset.notificationVolume;
  }

  /// Повертає список доступних пресетів.
  List<String> get availableVolumePresets => _volumePresets.keys.toList();

  /// Повертає поточний пресет.
  String get currentVolumePreset => _currentVolumePreset;

  // ── Пресети залежно від теми ───────────────────────────────

  /// Застосовує звуковий пресет теми.
  void applyThemePreset(String themeName) {
    final preset = _themePresets[themeName];
    if (preset == null) return;
    _currentTheme = themeName;
    _volume = preset.masterVolume;
    for (final entry in preset.categoryOverrides.entries) {
      _categoryVolumes[entry.key] = entry.value;
    }
  }

  /// Повертає список доступних тем.
  List<String> get availableThemes => _themePresets.keys.toList();

  /// Повертає поточну тему.
  String get currentTheme => _currentTheme;

  // ── Аудіо сесія ────────────────────────────────────────────

  /// Активує/деактивує аудіо сесію.
  void setAudioSessionActive(bool active) {
    _audioSessionActive = active;
    if (!active) {
      pauseAll();
    }
  }

  /// Чи аудіо сесія активна.
  bool get isAudioSessionActive => _audioSessionActive;

  /// Увімкнути/вимкнути моніторинг гучності пристрою.
  void setDeviceVolumeMonitoring(bool enabled) {
    _deviceVolumeMonitoring = enabled;
  }

  /// Встановлює гучність пристрою (імітація).
  void setDeviceVolume(double volume) {
    _deviceVolume = volume.clamp(0.0, 1.0);
  }

  /// Гучність пристрою.
  double get deviceVolume => _deviceVolume;

  /// Увімкнути/вимкнути вимкнення під час дзвінка.
  void setMuteDuringCalls(bool enabled) {
    _muteDuringCalls = enabled;
  }

  /// Чи увімкнено вимкнення під час дзвінка.
  bool get muteDuringCalls => _muteDuringCalls;

  /// Імітація вхідного дзвінка — приглушує всі звуки.
  void simulateIncomingCall() {
    if (_muteDuringCalls) {
      fadeTo(0.0, duration: const Duration(milliseconds: 200));
    }
  }

  /// Імітація завершення дзвінка — відновлює гучність.
  void simulateCallEnded() {
    if (_muteDuringCalls) {
      fadeTo(_volume, duration: const Duration(milliseconds: 300));
    }
  }

  // ── Короткі методи для конкретних звуків ───────────────────

  Future<void> playClick() => play(SoundType.click);
  Future<void> playCoinDing() => play(SoundType.coinDing);
  Future<void> playMilestone() => play(SoundType.milestone);
  Future<void> playFanfare() => play(SoundType.fanfare);
  Future<void> playXpZap() => play(SoundType.xpZap);
  Future<void> playError() => play(SoundType.error);
  Future<void> playSwipe() => play(SoundType.swipe);
  Future<void> playShimmer() => play(SoundType.shimmer);
  Future<void> playBadgeFanfare() => play(SoundType.badgeUnlocked);
  Future<void> playPullToRefresh() => play(SoundType.pullToRefresh);
  Future<void> playNavigate() => play(SoundType.navigate);
  Future<void> playToggle() => play(SoundType.toggle);
  Future<void> playSuccess() => play(SoundType.success);
  Future<void> playWarning() => play(SoundType.warning);
  Future<void> playConfetti() => play(SoundType.confetti);
  Future<void> playCoinDrop() => play(SoundType.coinDrop);
  Future<void> playLevelUp() => play(SoundType.levelUp);
  Future<void> playAchievementUnlock() => play(SoundType.achievementUnlock);
  Future<void> playLightTap() => play(SoundType.lightTap);
  Future<void> playTimerTick() => play(SoundType.timerTick);
  Future<void> playGoalComplete() => play(SoundType.goalComplete);
  Future<void> playNotification() => play(SoundType.notification);
  Future<void> playCurtainOpen() => play(SoundType.curtainOpen);
  Future<void> playCurtainClose() => play(SoundType.curtainClose);
  Future<void> playStarEarned() => play(SoundType.starEarned);

  // ── Святкувальна послідовність звуків ──────────────────────

  /// Відтворює послідовність звуків для святкування.
  Future<void> playCelebrationSequence() async {
    enqueue(SoundType.coinDing, delay: const Duration(milliseconds: 0));
    enqueue(SoundType.coinDing, delay: const Duration(milliseconds: 200));
    enqueue(SoundType.coinDing, delay: const Duration(milliseconds: 200));
    enqueue(SoundType.levelUp, delay: const Duration(milliseconds: 400));
    enqueue(SoundType.confetti, delay: const Duration(milliseconds: 300));
  }

  /// Відтворює послідовність звуків для внеску.
  Future<void> playDepositSequence() async {
    enqueue(SoundType.coinDrop, delay: const Duration(milliseconds: 0));
    enqueue(SoundType.xpZap, delay: const Duration(milliseconds: 200));
    enqueue(SoundType.success, delay: const Duration(milliseconds: 300));
  }

  /// Відтворює послідовність звуків для розблокування досягнення.
  Future<void> playAchievementSequence() async {
    enqueue(SoundType.badgeUnlocked, delay: const Duration(milliseconds: 0));
    enqueue(SoundType.starEarned, delay: const Duration(milliseconds: 400));
    enqueue(SoundType.fanfare, delay: const Duration(milliseconds: 300));
  }

  // ── Фонова музика ──────────────────────────────────────────

  bool _backgroundPlaying = false;

  Future<void> playBackgroundMusic() async {
    if (!_enabled) return;
    if (_mutedCategories.contains(SoundCategory.ambient)) return;
    _backgroundPlaying = true;
    // Заглушка — фонова музика буде додана пізніше.
  }

  /// Відтворює фонову музику з зацикленням і згасанням.
  Future<void> playBackgroundMusicWithLoop({Duration fadeIn = const Duration(seconds: 2)}) async {
    if (!_enabled) return;
    _backgroundPlaying = true;
    await fadeTo(_categoryVolumes[SoundCategory.ambient] ?? 0.3, duration: fadeIn);
  }

  /// Зупиняє фонову музику зі згасанням.
  Future<void> stopBackgroundMusicWithFade({Duration fadeOut = const Duration(seconds: 1)}) async {
    await fadeTo(0.0, duration: fadeOut);
    _backgroundPlaying = false;
    try {
      await _ambientPlayer.stop();
    } catch (_) {}
  }

  Future<void> stopBackgroundMusic() async {
    _backgroundPlaying = false;
    try {
      await _ambientPlayer.stop();
    } catch (_) {}
  }

  bool get isBackgroundPlaying => _backgroundPlaying;

  // ── Звільнення ресурсів ────────────────────────────────────

  void dispose() {
    _player.dispose();
    _overlayPlayer.dispose();
    _ambientPlayer.dispose();
  }
}
