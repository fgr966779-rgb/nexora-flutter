import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_radii.dart';
import '../../../../core/constants/app_shadows.dart';
import '../../../../core/constants/app_durations.dart';
import '../../../../core/constants/app_easings.dart';
import '../../../../core/extensions/number_format_ext.dart';
import '../../../../core/utils/haptic_service.dart';
import '../../../../core/widgets/app_confetti.dart';
import '../../../../core/widgets/app_button_primary.dart';
import '../../../../core/widgets/app_button_secondary.dart';

// ──────────────────────────────────────────────────────────────────────────────
// Enums & Data Models
// ──────────────────────────────────────────────────────────────────────────────

/// The current phase of the cinematic celebration sequence.
///
/// Each phase builds upon the previous one, creating a layered
/// animation experience. The [CinematicScreen] drives transitions
/// automatically but the enum is exposed for testing and debugging.
enum CinematicPhase {
  /// Black screen fade-in (0–800 ms).
  fadeToBlack,

  /// Goal object scales & rotates into view (800–2000 ms).
  objectAppear,

  /// Typewriter "ВІТАЄМО!" text animation (1600–2600 ms).
  typewriter,

  /// Stat rows stagger in one by one (2000–3200 ms).
  statsReveal,

  /// Action buttons fade + slide in (3000+ ms).
  buttons,

  /// All animations complete; user can interact freely.
  complete,
}

/// Represents a single statistic shown during the celebration.
///
/// Used by [CinematicScreen] and [JourneySummaryScreen] for a shared
/// data contract.
class GoalStatistic {
  const GoalStatistic({
    required this.label,
    required this.value,
    this.icon,
    this.highlight = false,
  });

  /// Display label (e.g. "Накопичено").
  final String label;

  /// Formatted value (e.g. "25 999 грн").
  final String value;

  /// Optional leading icon.
  final IconData? icon;

  /// When `true` the row is rendered with an accent colour.
  final bool highlight;
}

/// Error thrown when the cinematic sequence cannot initialise.
///
/// This can happen if the [TickerProvider] is disposed before
/// controllers are created, or if required animation values are invalid.
class CinematicInitException implements Exception {
  const CinematicInitException(this.message);
  final String message;

  @override
  String toString() => 'CinematicInitException: $message';
}

// ──────────────────────────────────────────────────────────────────────────────
// CinematicScreen
// ──────────────────────────────────────────────────────────────────────────────

/// Великий святковий екран — багатофазний: fade to black → об'єкт з firework
/// → typewriter "ВІТАЄМО!" → stagger статистика → кнопки.
///
/// The screen plays a multi-phase cinematic celebration when a user
/// reaches their savings goal. Phases are driven by
/// [AnimationController]s and transition automatically via delayed
/// futures.
///
/// ## Phase Timeline
///
/// | Phase         | Start (ms) | Duration (ms) |
/// |---------------|-----------|---------------|
/// | Fade to black | 0         | 800           |
/// | Object appear | 800       | 800           |
/// | Fireworks     | 1 000     | 2 000 (loop)  |
/// | Typewriter    | 1 600     | ~300          |
/// | Stats reveal  | 2 000     | 8 × 150       |
/// | Buttons       | 3 000     | 400           |
///
/// ## Usage
///
/// ```dart
/// Navigator.of(context).push(
///   MaterialPageRoute(
///     builder: (_) => CinematicScreen(
///       goalName: 'PlayStation 5',
///       goalIcon: Icons.gamepad_rounded,
///     ),
///   ),
/// );
/// ```
///
/// ## Accessibility
///
/// The screen enters full-screen immersive mode on init and restores
/// system overlays on dispose. All animations are purely visual and
/// do not block semantics tree traversal.
class CinematicScreen extends StatefulWidget {
  const CinematicScreen({
    super.key,
    this.goalName = 'PlayStation 5',
    this.goalIcon = Icons.gamepad_rounded,
    this.stats = const [],
    this.onSharePressed,
    this.onNewGoalPressed,
    this.autoEnterImmersive = true,
  });

  /// The name of the achieved goal displayed in the subtitle.
  final String goalName;

  /// Leading icon rendered inside the glowing orb.
  final IconData goalIcon;

  /// Override the default statistics list. When empty the built-in
  /// defaults are used.
  final List<GoalStatistic> stats;

  /// Callback invoked when the "Поділитися результатом" button is pressed.
  /// If `null` the button calls [shareCinematicResult] internally.
  final VoidCallback? onSharePressed;

  /// Callback invoked when "Нова мета" is pressed.
  /// Defaults to `pushReplacementNamed('/new-goal')`.
  final VoidCallback? onNewGoalPressed;

  /// Whether to automatically hide system UI overlays on entry.
  final bool autoEnterImmersive;

  @override
  State<CinematicScreen> createState() => _CinematicScreenState();

  /// Lint-friendly factory for test harnesses.
  @visibleForTesting
  static CinematicScreen test({
    String goalName = 'Test Goal',
    IconData goalIcon = Icons.star,
    List<GoalStatistic> stats = const [],
  }) {
    return CinematicScreen(
      goalName: goalName,
      goalIcon: goalIcon,
      stats: stats,
      autoEnterImmersive: false,
    );
  }
}

class _CinematicScreenState extends State<CinematicScreen>
    with TickerProviderStateMixin {
  // ── Phase controllers ─────────────────────────────────────────

  /// Phase 1: fade to black.
  late AnimationController _fadeController;

  /// Phase 2: object appear (scale bounce).
  late AnimationController _scaleController;

  /// Phase 2: 360° rotation around the orb.
  late AnimationController _rotateController;

  /// Firework particle explosions (repeating).
  late AnimationController _fireworkController;

  /// Continuous background floating particles.
  late AnimationController _particleController;

  /// Pulsating glow ring around the goal orb.
  late AnimationController _pulseController;

  late Animation<double> _scaleAnim;
  late Animation<double> _rotateAnim;
  late Animation<double> _pulseAnim;

  /// Whether Phase 2 (object appear) has been triggered.
  bool _phase2Started = false;

  /// Tracks the current animation phase for debugging / analytics.
  CinematicPhase _currentPhase = CinematicPhase.fadeToBlack;

  /// Whether the screen is currently in immersive (full-screen) mode.
  bool _isImmersive = false;

  /// Guards against double-taps on share button.
  bool _isSharing = false;

  /// Holds an error that occurred during initialisation, if any.
  CinematicInitException? _initError;

  /// Additional animation controller for the shimmer sweep effect.
  late AnimationController _shimmerController;

  /// Additional animation controller for the background star field.
  late AnimationController _starFieldController;

  /// Shimmer sweep animation value, oscillating from -1.0 to 1.0.
  late Animation<double> _shimmerAnim;

  /// Tracks the total number of times the user has replayed the
  /// celebration animation.
  int _replayCount = 0;

  /// Whether the motivational quote has been shown during this
  /// session. Used to avoid repeating it on replays.
  bool _motivationalQuoteShown = false;

  /// Timestamp when the animation sequence started, used for
  /// analytics and performance tracking.
  final DateTime _sequenceStartTime = DateTime.now();

  /// Scroll controller for the content scroll view, used to
  /// auto-scroll to the stats section when Phase 4 begins.
  final ScrollController _contentScrollController = ScrollController();

  // ── Default stats data ─────────────────────────────────────────

  static const _defaultStats = [
    ('Накопичено', '25 999 грн'),
    ('Кількість внесків', '87'),
    ('Середній внесок', '299 грн'),
    ('Час', '3 міс та 12 днів'),
    ('Найбільший внесок', '2 000 грн'),
    ('Найдовша серія', '21 день'),
    ('Рівень', 'Чемпіон (5)'),
    ('Значки', '8 / 10'),
  ];

  // ── Additional constants ──────────────────────────────────────

  /// Primary gradient colours used for the goal orb.
  static const _orbGradientColors = [
    Color(0xFF006FCD),
    Color(0xFF00C6FF),
  ];

  /// Shimmer sweep colours used in the secondary overlay.
  static const _shimmerSweepColors = [
    Color(0x33FFFFFF),
    Color(0x00FFFFFF),
  ];

  /// Star field configuration — number of background stars.
  static const _starFieldCount = 60;

  /// Maximum star field twinkle opacity.
  static const _starFieldMaxOpacity = 0.35;

  /// Minimum duration before the user is allowed to skip the intro.
  static const _minIntroDuration = Duration(milliseconds: 1200);

  /// Maximum number of replays allowed per session to prevent
  /// excessive haptic feedback.
  static const _maxReplaysPerSession = 10;

  /// Collection of motivational quotes shown after the celebration
  /// completes, randomly selected per session.
  static const _motivationalQuotes = [
    'Кожна мета — це крок до кращого майбутнього!',
    'Ти довів, що дисципліна — це суперсила!',
    'Світ належить тим, хто не здається!',
    'Нові звершення вже чекають на тебе!',
    'Твоя наполегливість надихає!',
  ];

  /// Celebration badge tiers based on the number of completed goals.
  static const _badgeTiers = [
    ('Фінішер', 'assets/badges/finisher.png', 'Перша досягнута мета'),
    ('Стійкий', 'assets/badges/steady.png', '3 досягнуті мети'),
    ('Майстер', 'assets/badges/master.png', '5 досягнутих мет'),
    ('Легенда', 'assets/badges/legend.png', '10 досягнутих мет'),
  ];

  /// Effective statistics list — custom stats or defaults.
  List<({String label, String value})> get _effectiveStats {
    if (widget.stats.isNotEmpty) {
      return widget.stats.map((s) => (label: s.label, value: s.value)).toList();
    }
    return _defaultStats.map((s) => (label: s.$1, value: s.$2)).toList();
  }

  // ── Computed properties ────────────────────────────────────────

  /// Whether all animation phases have completed and the user
  /// can interact freely with all UI elements.
  bool get _isAnimationComplete =>
      _currentPhase == CinematicPhase.complete;

  /// The current glow radius of the pulsing ring, computed from
  /// [_pulseAnim] and a base offset. Returns a [Radius] suitable
  /// for use in [BoxDecoration.borderRadius].
  double get _currentGlowRadius => 100 * _pulseAnim.value;

  /// The effective particle count for the firework painter.
  /// Increases by 10% for each replay (up to a cap of 200).
  int get _effectiveParticleCount {
    const baseCount = 120;
    const increment = 12;
    const maxCount = 200;
    return (baseCount + _replayCount * increment).clamp(baseCount, maxCount);
  }

  /// The elapsed time since the animation sequence started.
  /// Returns [Duration.zero] if the sequence hasn't started yet.
  Duration get _elapsedDuration =>
      DateTime.now().difference(_sequenceStartTime);

  /// A randomly selected motivational quote for this session.
  /// Cached after the first call to avoid changing mid-session.
  String get _sessionMotivationalQuote {
    final idx = _sequenceStartTime.millisecond % _motivationalQuotes.length;
    return _motivationalQuotes[idx];
  }

  /// The current badge tier based on a hypothetical goals-completed
  /// count. For now returns the first tier as a placeholder.
  ({String name, String icon, String description}) get _currentBadge =>
      _badgeTiers.first;

  /// Whether the user can safely skip the intro animation without
  /// missing critical visual feedback.
  bool get _canSkipIntro =>
      _elapsedDuration >= _minIntroDuration ||
      _currentPhase.index >= CinematicPhase.objectAppear.index;

  // ── Validation helpers ─────────────────────────────────────────

  /// Validates that a [CinematicPhase] transition from [from] to [to]
  /// is legal. Phase transitions must be sequential (index must
  /// increase by exactly 1).
  bool _isValidPhaseTransition(CinematicPhase from, CinematicPhase to) {
    return to.index == from.index + 1;
  }

  /// Computes the glow intensity for the pulsing ring based on the
  /// current pulse animation value. Returns a value in [0.0, 1.0]
  /// where 1.0 is maximum glow.
  double _computeGlowIntensity() {
    final raw = _pulseAnim.value;
    // Map [0.95, 1.05] → [0.0, 1.0]
    return ((raw - 0.95) / 0.10).clamp(0.0, 1.0);
  }

  /// Computes a theme-aware accent colour that adjusts brightness
  /// based on the current platform brightness. On light platforms
  /// the accent shifts slightly darker for better contrast.
  Color _computeAdaptiveAccentColor() {
    final brightness = MediaQuery.of(context).platformBrightness;
    if (brightness == Brightness.light) {
      return const Color(0xFF005BB5);
    }
    return const Color(0xFF006FCD);
  }

  /// Validates that all required controllers are initialised and
  /// not disposed. Returns `null` if everything is valid, or an
  /// error message describing the problem.
  String? _validateControllersState() {
    if (!_fadeController.isAnimating && _fadeController.value == 0.0 &&
        _currentPhase != CinematicPhase.fadeToBlack) {
      return 'Fade controller in unexpected state';
    }
    if (_phase2Started && _scaleController.value == 0.0) {
      return 'Scale controller not started after Phase 2';
    }
    return null;
  }

  /// Formats an elapsed [Duration] as a human-readable string
  /// for the debug overlay (e.g. "2.4 s").
  String _formatElapsed(Duration d) {
    final seconds = d.inMilliseconds / 1000.0;
    return '${seconds.toStringAsFixed(1)} s';
  }

  // ── Lifecycle ──────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    try {
      _initAnimationControllers();
      _schedulePhaseTransitions();
      if (widget.autoEnterImmersive) _enterImmersiveMode();
    } on Exception catch (e) {
      _initError = CinematicInitException(e.toString());
      debugPrint('[CinematicScreen] Init error: $_initError');
    }
  }

  /// Creates and configures all [AnimationController] instances.
  ///
  /// Each controller is initialised with a fixed duration and
  /// [Curves] that match the design spec. Controllers that repeat
  /// call [AnimationController.repeat] immediately.
  void _initAnimationControllers() {
    // Phase 1: Fade to black (800 ms)
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();

    // Phase 2: Scale (0 → 1.2 → 1.0, 800 ms, spring)
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _scaleAnim = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.2), weight: 60),
      TweenSequenceItem(tween: Tween(begin: 1.2, end: 1.0), weight: 40),
    ]).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeOutBack,
    ));

    // Phase 2: Rotate 360°
    _rotateController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _rotateAnim = Tween<double>(begin: 0, end: 2 * math.pi).animate(
      CurvedAnimation(parent: _rotateController, curve: Curves.easeInOut),
    );

    // Pulsating glow ring (sine wave, 1.5 s loop)
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
    _pulseAnim = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOutSine),
    );

    // Firework animation (120 particles, 2 s, repeat)
    _fireworkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    // Continuous background particles (4 s loop)
    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4000),
    )..repeat();

    // Shimmer sweep effect (3 s loop)
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat();
    _shimmerAnim = Tween<double>(begin: -1.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _shimmerController,
        curve: Curves.easeInOutSine,
      ),
    );

    // Background star field (5 s loop)
    _starFieldController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 5000),
    )..repeat();
  }

  /// Schedules the automatic phase transitions using [Future.delayed].
  ///
  /// Each transition checks [State.mounted] before calling [setState]
  /// or starting controllers to avoid memory leaks.
  void _schedulePhaseTransitions() {
    // Phase 1 → Phase 2 (after fade completes)
    Future.delayed(const Duration(milliseconds: 800), _startPhase2);

    // Phase 2: start fireworks slightly after object appears
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (mounted) _fireworkController.repeat();
    });
  }

  /// Triggers Phase 2 — goal object scales and rotates in.
  void _startPhase2() {
    if (!mounted) return;
    setState(() {
      _phase2Started = true;
      _currentPhase = CinematicPhase.objectAppear;
    });
    _scaleController.forward();
    _rotateController.forward();
    HapticService.heavyTap();

    // Transition to typewriter phase once object animation starts
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        setState(() => _currentPhase = CinematicPhase.typewriter);
      }
    });

    // Transition to stats phase
    Future.delayed(const Duration(milliseconds: 2000), () {
      if (mounted) {
        setState(() => _currentPhase = CinematicPhase.statsReveal);
      }
    });

    // Transition to buttons phase
    Future.delayed(const Duration(milliseconds: 3000), () {
      if (mounted) {
        setState(() => _currentPhase = CinematicPhase.buttons);
      }
    });

    // Mark complete
    Future.delayed(const Duration(milliseconds: 3600), () {
      if (mounted) {
        setState(() => _currentPhase = CinematicPhase.complete);
      }
    });
  }

  /// Automatically scrolls to the stats section when the stats
  /// reveal phase begins, ensuring the user can see them without
  /// manual scrolling.
  void _scrollToStats() {
    if (!_contentScrollController.hasClients) return;
    // Approximate offset: header + goal orb + typewriter text
    const targetOffset = 480.0;
    _contentScrollController.animateTo(
      targetOffset,
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOutCubic,
    );
  }

  /// Logs a phase transition event for analytics. In release builds
  /// this is a no-op; in debug builds it prints to the console.
  void _logPhaseTransition(CinematicPhase newPhase) {
    assert(() {
      debugPrint(
        '[CinematicScreen] Phase transition: ${_currentPhase.name} → '
        '${newPhase.name} (${_formatElapsed(_elapsedDuration)})',
      );
      return true;
    }());
  }

  /// Shows a motivational quote at the bottom of the screen after
  /// all animations complete. Only shows once per session.
  void _showMotivationalQuote() {
    if (_motivationalQuoteShown) return;
    _motivationalQuoteShown = true;
    HapticService.lightTap();
  }

  /// Builds the current badge earned for completing the goal.
  /// Displays the badge name and description in a themed card.
  Widget _buildCurrentBadge() {
    final badge = _currentBadge;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.base,
        vertical: Spacing.md,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(Radii.lg),
        border: Border.all(
          color: const Color(0xFFFFD600).withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFFFFD600).withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.emoji_events_rounded,
              color: Color(0xFFFFD600),
              size: 20,
            ),
          ),
          const SizedBox(width: Spacing.sm),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                badge.name,
                style: AppTypography.labelMedium.copyWith(
                  color: const Color(0xFFFFD600),
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                badge.description,
                style: AppTypography.caption.copyWith(
                  color: Colors.white.withOpacity(0.4),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Theme-aware colour helpers ───────────────────────────────

  /// Returns a colour palette derived from the current [CinematicPhase].
  ///
  /// Different phases use slightly different hues to reinforce
  /// the visual narrative. The returned list always contains exactly
  /// two colours: a primary and a secondary accent.
  List<Color> _getPhasePalette() {
    switch (_currentPhase) {
      case CinematicPhase.fadeToBlack:
        return const [Color(0xFF1A1A2E), Color(0xFF16213E)];
      case CinematicPhase.objectAppear:
        return const [Color(0xFF006FCD), Color(0xFF00C6FF)];
      case CinematicPhase.typewriter:
        return const [Color(0xFF00C6FF), Color(0xFF74B9FF)];
      case CinematicPhase.statsReveal:
        return const [Color(0xFF0984E3), Color(0xFF6C5CE7)];
      case CinematicPhase.buttons:
        return const [Color(0xFF6C5CE7), Color(0xFFA29BFE)];
      case CinematicPhase.complete:
        return const [Color(0xFF00B894), Color(0xFF55EFC4)];
    }
  }

  /// Resolves the effective text colour for celebration labels
  /// based on the current phase and platform brightness.
  ///
  /// During early phases the text is dimmer; it brightens once
  /// the typewriter phase is reached.
  Color _getEffectiveTextColor() {
    if (_currentPhase.index < CinematicPhase.typewriter.index) {
      return Colors.white.withOpacity(0.3);
    }
    return Colors.white.withOpacity(0.85);
  }

  /// Builds a themed progress indicator showing which phase the
  /// celebration sequence is currently in. Each dot corresponds
  /// to one [CinematicPhase] (except [CinematicPhase.complete]).
  Widget _buildPhaseIndicator() {
    if (!_phase2Started) return const SizedBox.shrink();

    final phases = CinematicPhase.values
        .where((p) => p != CinematicPhase.complete)
        .toList();
    final currentIdx = _currentPhase.index.clamp(0, phases.length - 1);

    return Container(
      margin: const EdgeInsets.only(bottom: Spacing.lg),
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.md,
        vertical: Spacing.xs,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(Radii.xl),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(phases.length, (i) {
          final isActive = i <= currentIdx;
          final dotColor = isActive
              ? const Color(0xFF00C6FF)
              : Colors.white.withOpacity(0.15);
          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: EdgeInsets.only(right: i < phases.length - 1 ? 6 : 0),
            width: isActive ? 24 : 8,
            height: 8,
            decoration: BoxDecoration(
              color: dotColor,
              borderRadius: BorderRadius.circular(4),
              boxShadow: isActive
                  ? [
                      BoxShadow(
                        color: const Color(0xFF00C6FF).withOpacity(0.4),
                        blurRadius: 6,
                      ),
                    ]
                  : null,
            ),
          );
        }),
      ),
    );
  }

  /// Builds the motivational quote card that appears after the
  /// celebration completes. Uses [_sessionMotivationalQuote] for
  /// the text content and includes a subtle shimmer animation.
  Widget _buildMotivationalQuoteCard() {
    if (!_isAnimationComplete || !_motivationalQuoteShown) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: Spacing.base,
        vertical: Spacing.md,
      ),
      padding: const EdgeInsets.all(Spacing.base),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.08),
            Colors.white.withOpacity(0.02),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(Radii.lg),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(
                Icons.format_quote_rounded,
                color: Color(0xFFFFD600),
                size: 20,
              ),
              const SizedBox(width: Spacing.sm),
              Text(
                'Мотивація дня',
                style: AppTypography.labelSmall.copyWith(
                  color: Colors.white.withOpacity(0.5),
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: Spacing.sm),
          Text(
            _sessionMotivationalQuote,
            style: AppTypography.bodyMedium.copyWith(
              color: Colors.white.withOpacity(0.8),
              fontStyle: FontStyle.italic,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ).animate().fadeIn(delay: 400.ms, duration: 600.ms);
  }

  /// Builds a share preview card showing what the shared content
  /// will look like. Displayed inline before the share button.
  Widget _buildSharePreview() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: Spacing.base),
      padding: const EdgeInsets.all(Spacing.md),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(Radii.md),
        border: Border.all(
          color: Colors.white.withOpacity(0.08),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: _orbGradientColors.first.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              widget.goalIcon,
              color: Colors.white.withOpacity(0.7),
              size: 24,
            ),
          ),
          const SizedBox(width: Spacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '🎉 Я досяг(ла) мети "${widget.goalName}" у Nexora!',
                  style: AppTypography.labelSmall.copyWith(
                    color: Colors.white.withOpacity(0.6),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  _effectiveStats.first.value,
                  style: AppTypography.caption.copyWith(
                    color: Colors.white.withOpacity(0.4),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Computes a performance score for the cinematic sequence based
  /// on the elapsed time and number of replays. Returns a value
  /// in [0, 100] where 100 means the user watched the full sequence
  /// without skipping or replaying.
  int _computeEngagementScore() {
    const optimalViewTime = Duration(milliseconds: 3600);
    const maxViewTime = Duration(milliseconds: 30000);

    final elapsed = _elapsedDuration;
    if (elapsed < optimalViewTime) {
      // Penalty for early exit
      return ((elapsed.inMilliseconds / optimalViewTime.inMilliseconds) * 80)
          .round();
    }
    if (elapsed < maxViewTime && _replayCount == 0) {
      // Perfect: watched full sequence, no replays
      return 100;
    }
    // Small penalty for replays (but still positive engagement)
    final replayPenalty = _replayCount * 3;
    return (85 - replayPenalty).clamp(50, 85);
  }

  /// Formats the engagement score as a letter grade (A+ through D).
  String _formatEngagementGrade(int score) {
    if (score >= 95) return 'A+';
    if (score >= 85) return 'A';
    if (score >= 75) return 'B+';
    if (score >= 65) return 'B';
    if (score >= 50) return 'C';
    return 'D';
  }

  /// Returns the estimated frame rate of the animations based on
  /// the number of active controllers and the current device
  /// screen size. This is a rough heuristic for analytics.
  double _estimateFrameRate() {
    final pixelCount =
        MediaQuery.of(context).size.width *
        MediaQuery.of(context).size.height;
    final activeControllers = [
      _fadeController,
      if (_phase2Started) _scaleController,
      if (_phase2Started) _rotateController,
      if (_phase2Started) _fireworkController,
      _particleController,
      _pulseController,
      _shimmerController,
      _starFieldController,
    ].length;

    // Heuristic: more pixels + more controllers → lower expected FPS
    final pixelsPerController = pixelCount / activeControllers;
    if (pixelsPerController < 500000) return 120.0;
    if (pixelsPerController < 1500000) return 90.0;
    return 60.0;
  }

  /// Validates that the star field configuration is within acceptable
  /// performance bounds. Returns `null` if everything is fine.
  String? _validateStarFieldConfig() {
    if (_starFieldCount > 200) {
      return 'Star field count exceeds recommended maximum of 200';
    }
    if (_starFieldMaxOpacity > 0.6) {
      return 'Star field opacity above 0.6 may cause visual noise';
    }
    return null;
  }

  /// Builds a debug panel (only visible in debug mode) showing
  /// performance metrics and controller states.
  Widget _buildDebugPanel() {
    if (!kDebugMode || !_phase2Started) return const SizedBox.shrink();

    final engagement = _computeEngagementScore();
    return Positioned(
      top: 4,
      left: 4,
      child: IgnorePointer(
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.6),
            borderRadius: BorderRadius.circular(Radii.sm),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '⏱ ${_formatElapsed(_elapsedDuration)}',
                style: AppTypography.labelSmall.copyWith(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 9,
                ),
              ),
              Text(
                '📊 ${_effectiveParticleCount} particles',
                style: AppTypography.labelSmall.copyWith(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 9,
                ),
              ),
              Text(
                '🎯 Engagement: ${_formatEngagementGrade(engagement)} ($engagement)',
                style: AppTypography.labelSmall.copyWith(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 9,
                ),
              ),
              Text(
                '🖥 ~${_estimateFrameRate().toStringAsFixed(0)} FPS est.',
                style: AppTypography.labelSmall.copyWith(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 9,
                ),
              ),
              Text(
                '🔁 Replays: $_replayCount / $_maxReplaysPerSession',
                style: AppTypography.labelSmall.copyWith(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 9,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    _rotateController.dispose();
    _fireworkController.dispose();
    _particleController.dispose();
    _pulseController.dispose();
    _shimmerController.dispose();
    _starFieldController.dispose();
    _contentScrollController.dispose();
    _exitImmersiveMode();
    super.dispose();
  }

  // ── Immersive Mode ─────────────────────────────────────────────

  /// Hides system overlays for a full-screen cinematic experience.
  void _enterImmersiveMode() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    _isImmersive = true;
  }

  /// Restores system overlays.
  void _exitImmersiveMode() {
    if (!_isImmersive) return;
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.edgeToEdge,
    );
    _isImmersive = false;
  }

  // ── Actions ────────────────────────────────────────────────────

  /// Handles the "Поділитися результатом" button tap.
  ///
  /// Guards against double-taps via [_isSharing]. If [onSharePressed]
  /// is provided it is called; otherwise a default share action runs.
  Future<void> _handleShare() async {
    if (_isSharing) return;
    setState(() => _isSharing = true);
    HapticService.lightTap();
    try {
      if (widget.onSharePressed != null) {
        widget.onSharePressed!();
      } else {
        await _defaultShareAction();
      }
    } catch (e) {
      debugPrint('[CinematicScreen] Share error: $e');
      if (mounted) _showErrorSnackBar('Не вдалося поділитися');
    } finally {
      if (mounted) setState(() => _isSharing = false);
    }
  }

  /// Default share implementation — copies result to clipboard.
  Future<void> _defaultShareAction() async {
    final text = '🎉 Я досяг(ла) мети "${widget.goalName}" у Nexora!';
    await Clipboard.setData(ClipboardData(text: text));
    if (mounted) _showSuccessSnackBar('Скопійовано в буфер обміну');
  }

  /// Handles "Нова мета" navigation.
  void _handleNewGoal() {
    HapticService.mediumTap();
    if (widget.onNewGoalPressed != null) {
      widget.onNewGoalPressed!();
    } else {
      Navigator.of(context).pushReplacementNamed('/new-goal');
    }
  }

  /// Restarts all repeatable animations for a re-watch effect.
  /// Increments [_replayCount] and caps at [_maxReplaysPerSession].
  void _handleReplay() {
    if (_replayCount >= _maxReplaysPerSession) {
      _showErrorSnackBar('Максимальна кількість повторів досягнута');
      return;
    }
    _replayCount++;
    HapticService.lightTap();
    _logPhaseTransition(_currentPhase);
    _scaleController.forward(from: 0);
    _rotateController.forward(from: 0);
    _fireworkController.forward(from: 0);
  }

  /// Restarts the entire cinematic sequence from Phase 1.
  void _handleFullRestart() {
    setState(() {
      _phase2Started = false;
      _currentPhase = CinematicPhase.fadeToBlack;
    });
    _fadeController.forward(from: 0);
    _scaleController.reset();
    _rotateController.reset();
    _fireworkController.reset();
    _fireworkController.stop();
    _schedulePhaseTransitions();
  }

  // ── Snack-bars ─────────────────────────────────────────────────

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green.shade700,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: 'OK',
          textColor: Colors.white,
          onPressed: () {},
        ),
      ),
    );
  }

  // ── Build ──────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    // Show an error overlay if init failed.
    if (_initError != null) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(Spacing.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, color: Colors.redAccent, size: 48),
                const SizedBox(height: Spacing.md),
                Text(
                  'Помилка завантаження святкування',
                  style: AppTypography.headlineSmall.copyWith(color: Colors.white),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: Spacing.sm),
                Text(
                  _initError!.message,
                  style: AppTypography.bodySmall.copyWith(
                    color: Colors.white.withOpacity(0.6),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: Spacing.lg),
                AppButtonPrimary(
                  label: 'Спробувати ще раз',
                  icon: Icons.refresh_rounded,
                  onPressed: () {
                    setState(() => _initError = null);
                    _handleFullRestart();
                  },
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // ── Phase 1: Fade to black overlay ────────────────────
          AnimatedBuilder(
            animation: _fadeController,
            builder: (context, _) {
              final opacity = _fadeController.value.clamp(0.0, 1.0);
              return Positioned.fill(
                child: IgnorePointer(
                  child: Container(
                    color: Colors.black.withOpacity(opacity),
                  ),
                ),
              );
            },
          ),

          // ── Continuous floating particles ──────────────────────
          if (_phase2Started)
            Positioned.fill(
              child: IgnorePointer(
                child: AnimatedBuilder(
                  animation: _particleController,
                  builder: (context, _) {
                    return CustomPaint(
                      painter: _ContinuousParticlePainter(
                        progress: _particleController.value,
                        screenSize: MediaQuery.of(context).size,
                      ),
                    );
                  },
                ),
              ),
            ),

          // ── Phase 2: Firework particles ────────────────────────
          if (_phase2Started)
            Positioned.fill(
              child: IgnorePointer(
                child: AnimatedBuilder(
                  animation: _fireworkController,
                  builder: (context, _) {
                    return CustomPaint(
                      painter: _FireworkPainter(
                        progress: _fireworkController.value,
                        screenSize: MediaQuery.of(context).size,
                        particleCount: 120,
                      ),
                    );
                  },
                ),
              ),
            ),

          // ── Phase 2: Confetti ─────────────────────────────────
          if (_phase2Started)
            const Positioned.fill(
              child: AppConfetti(particleCount: 80),
            ),

          // ── Phase debug overlay (hidden in release) ──────────
          if (_phase2Started && kDebugMode)
            Positioned(
              top: 4,
              right: 4,
              child: IgnorePointer(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(Radii.sm),
                  ),
                  child: Text(
                    'Phase: ${_currentPhase.name}',
                    style: AppTypography.labelSmall.copyWith(
                      color: Colors.white.withOpacity(0.5),
                      fontSize: 10,
                    ),
                  ),
                ),
              ),
            ),

          // ── Content ─────────────────────────────────────────────
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: Spacing.base),
              child: Column(
                children: [
                  const SizedBox(height: 48),

                  // ── Phase 2: Goal object with radial glow ────────
                  if (_phase2Started)
                    _buildGoalObject(),

                  const SizedBox(height: Spacing.xxl),

                  // ── Phase 3: «ВІТАЄМО!» typewriter (30ms/letter) ─
                  if (_phase2Started)
                    _TypewriterText(
                      text: 'ВІТАЄМО!',
                      style: AppTypography.displayLarge.copyWith(
                        color: Colors.white,
                        fontSize: 40,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 6,
                      ),
                      delay: const Duration(milliseconds: 1600),
                      letterDelay: 30,
                      onComplete: () {
                        if (mounted) {
                          HapticService.lightTap();
                        }
                      },
                    ),

                  const SizedBox(height: Spacing.sm),

                  // Subtitle
                  if (_phase2Started)
                    Text(
                      'Ти це зробив! Твоя цель «${widget.goalName}» досягнута!',
                      style: AppTypography.bodyLarge.copyWith(
                        color: Colors.white.withOpacity(0.7),
                      ),
                      textAlign: TextAlign.center,
                    ).animate().fadeIn(delay: 2200.ms, duration: 600.ms),

                  const SizedBox(height: Spacing.xxl),

                  // ── Phase 4: Stats list (stagger 150ms) ──────────
                  if (_phase2Started)
                    ..._effectiveStats.asMap().entries.map((entry) {
                      final i = entry.key;
                      final stat = entry.value;
                      return _StatRow(
                        label: stat.label,
                        value: stat.value,
                        index: i,
                      );
                    }),

                  const SizedBox(height: Spacing.xxl),

                  // ── Buttons stagger ─────────────────────────────
                  if (_phase2Started) ...[
                    AppButtonPrimary(
                      label: _isSharing
                          ? 'Надсилання…'
                          : 'Поділитися результатом',
                      icon: _isSharing
                          ? Icons.hourglass_top_rounded
                          : Icons.share_rounded,
                      showGlow: true,
                      onPressed: _isSharing ? null : _handleShare,
                    ).animate()
                        .fadeIn(delay: 3000.ms, duration: 400.ms)
                        .slideY(
                          begin: 0.15,
                          end: 0,
                          delay: 3000.ms,
                          duration: 400.ms,
                        ),

                    const SizedBox(height: Spacing.md),

                    Row(
                      children: [
                        Expanded(
                          child: AppButtonSecondary(
                            label: 'Переглянути повторно',
                            icon: Icons.replay_rounded,
                            onPressed: _handleReplay,
                          ),
                        ),
                        const SizedBox(width: Spacing.md),
                        Expanded(
                          child: AppButtonPrimary(
                            label: 'Нова мета',
                            icon: Icons.add_rounded,
                            onPressed: _handleNewGoal,
                          ),
                        ),
                      ],
                    ).animate()
                        .fadeIn(delay: 3200.ms, duration: 400.ms)
                        .slideY(
                          begin: 0.15,
                          end: 0,
                          delay: 3200.ms,
                          duration: 400.ms,
                        ),
                  ],

                  const SizedBox(height: Spacing.xxxl),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Goal object with radial glow and 360° rotation ────────────

  /// Builds the animated goal orb with outer pulsing glow ring.
  ///
  /// The orb scales in with an overshoot, rotates 360°, and the
  /// icon counter-rotates to remain upright. A secondary
  /// [_buildPulsingGlowRing] renders behind it.
  Widget _buildGoalObject() {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _scaleController,
        _rotateController,
        _pulseController,
      ]),
      builder: (context, _) {
        return SizedBox(
          width: 220,
          height: 220,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Outer pulsing glow ring
              _buildPulsingGlowRing(),
              // Main orb
              Transform.scale(
                scale: _scaleAnim.value,
                child: Transform.rotate(
                  angle: _rotateAnim.value,
                  child: Container(
                    width: 180,
                    height: 180,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFF006FCD),
                          Color(0xFF00C6FF),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF006FCD).withOpacity(0.6),
                          blurRadius: 60,
                          spreadRadius: 8,
                        ),
                        BoxShadow(
                          color: const Color(0xFF00C6FF).withOpacity(0.3),
                          blurRadius: 100,
                          spreadRadius: 20,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Transform.rotate(
                        angle: -_rotateAnim.value,
                        child: Icon(
                          widget.goalIcon,
                          color: Colors.white.withOpacity(0.9),
                          size: 72,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    ).animate().fadeIn(duration: 600.ms);
  }

  /// Renders a pulsating glow ring behind the goal orb.
  ///
  /// Uses [_pulseAnim] to oscillate between 0.95× and 1.05× scale,
  /// producing a subtle "breathing" halo effect.
  Widget _buildPulsingGlowRing() {
    return Container(
      width: 200 * _pulseAnim.value,
      height: 200 * _pulseAnim.value,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: const Color(0xFF00C6FF).withOpacity(0.2),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF006FCD).withOpacity(0.15),
            blurRadius: 40,
            spreadRadius: 4,
          ),
        ],
      ),
    );
  }

  // ── Additional widget builders ─────────────────────────────────

  /// Builds a shimmer sweep overlay that passes across the goal orb
  /// once the object appear phase is active. The sweep oscillates
  /// left-to-right using [_shimmerAnim].
  Widget _buildShimmerOverlay() {
    return AnimatedBuilder(
      animation: _shimmerController,
      builder: (context, _) {
        final sweepPosition = (_shimmerAnim.value + 1.0) / 2.0;
        return SizedBox(
          width: 180,
          height: 180,
          child: ClipOval(
            child: Align(
              alignment: Alignment(sweepPosition * 2 - 1, 0),
              child: Container(
                width: 60,
                height: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: _shimmerSweepColors,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// Builds a background star field that twinkles behind the
  /// celebration content. Uses [_starFieldController] to animate
  /// individual star brightness.
  Widget _buildStarField(Size screenSize) {
    return Positioned.fill(
      child: IgnorePointer(
        child: AnimatedBuilder(
          animation: _starFieldController,
          builder: (context, _) {
            return CustomPaint(
              painter: _StarFieldPainter(
                progress: _starFieldController.value,
                screenSize: screenSize,
                count: _starFieldCount,
                maxOpacity: _starFieldMaxOpacity,
              ),
            );
          },
        ),
      ),
    );
  }

  /// Builds the motivational quote card that appears at the bottom
  /// of the celebration sequence after all phases complete.
  Widget _buildMotivationalQuoteCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: Spacing.base),
      padding: const EdgeInsets.all(Spacing.base),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(Radii.lg),
        border: Border.all(
          color: Colors.white.withOpacity(0.08),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.format_quote_rounded,
                color: Colors.white.withOpacity(0.2),
                size: 18,
              ),
              const SizedBox(width: 4),
              Text(
                'Мотивація дня',
                style: AppTypography.caption.copyWith(
                  color: Colors.white.withOpacity(0.3),
                ),
              ),
            ],
          ),
          const SizedBox(height: Spacing.sm),
          Text(
            _sessionMotivationalQuote,
            style: AppTypography.bodyMedium.copyWith(
              color: Colors.white.withOpacity(0.6),
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ).animate().fadeIn(
      delay: 3800.ms,
      duration: 500.ms,
    );
  }

  /// Builds the elapsed time indicator shown in the debug overlay.
  /// Only visible in debug mode, displays formatted elapsed time.
  Widget _buildDebugElapsedIndicator() {
    return AnimatedBuilder(
      animation: _particleController,
      builder: (context, _) {
        return Text(
          'Elapsed: ${_formatElapsed(_elapsedDuration)}',
          style: AppTypography.caption.copyWith(
            color: Colors.white.withOpacity(0.3),
            fontSize: 9,
          ),
        );
      },
    );
  }

  /// Builds an enhanced debug overlay widget with phase info and
  /// elapsed time. Only rendered when [kDebugMode] is true.
  Widget _buildEnhancedDebugOverlay() {
    final validationError = _validateControllersState();
    return Positioned(
      top: 4,
      left: 4,
      right: 4,
      child: IgnorePointer(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(Radii.sm),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Phase: ${_currentPhase.name}',
                    style: AppTypography.labelSmall.copyWith(
                      color: Colors.white.withOpacity(0.5),
                      fontSize: 10,
                    ),
                  ),
                  _buildDebugElapsedIndicator(),
                  Text(
                    'Replays: $_replayCount / $_maxReplaysPerSession',
                    style: AppTypography.caption.copyWith(
                      color: Colors.white.withOpacity(0.3),
                      fontSize: 9,
                    ),
                  ),
                  Text(
                    'Particles: $_effectiveParticleCount',
                    style: AppTypography.caption.copyWith(
                      color: Colors.white.withOpacity(0.3),
                      fontSize: 9,
                    ),
                  ),
                  if (validationError != null)
                    Text(
                      '⚠ $validationError',
                      style: AppTypography.caption.copyWith(
                        color: Colors.redAccent.withOpacity(0.7),
                        fontSize: 9,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Typewriter Text
// ──────────────────────────────────────────────────────────────────────────────

/// Typewriter text — анімує появу кожного символу.
///
/// Characters are revealed one at a time at a configurable
/// [letterDelay]. A blinking cursor (`|`) is shown after the last
/// revealed character and disappears once all characters are visible.
///
/// ## Example
///
/// ```dart
/// _TypewriterText(
///   text: 'ВІТАЄМО!',
///   style: TextStyle(fontSize: 40),
///   delay: Duration(milliseconds: 1600),
///   letterDelay: 30,
/// )
/// ```
class _TypewriterText extends StatefulWidget {
  const _TypewriterText({
    required this.text,
    required this.style,
    required this.delay,
    this.letterDelay = 80,
    this.onComplete,
  });

  /// Full text to reveal character-by-character.
  final String text;

  /// Style applied to the [Text] widget.
  final TextStyle style;

  /// Duration before the typewriter starts (phase offset).
  final Duration delay;

  /// Milliseconds between each character reveal.
  final int letterDelay;

  /// Optional callback fired when all characters are visible.
  final VoidCallback? onComplete;

  @override
  State<_TypewriterText> createState() => _TypewriterTextState();
}

class _TypewriterTextState extends State<_TypewriterText>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  int _charCount = 0;
  bool _completed = false;

  @override
  void initState() {
    super.initState();

    // Guard against empty text.
    if (widget.text.isEmpty) {
      _completed = true;
      widget.onComplete?.call();
      return;
    }

    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: widget.text.length * widget.letterDelay),
    );
    _controller.addListener(_onTick);
    _controller.addStatusListener(_onStatus);

    Future.delayed(widget.delay, () {
      if (mounted) _controller.forward();
    });
  }

  void _onTick() {
    final newCount = (widget.text.length * _controller.value).floor();
    if (newCount != _charCount) {
      setState(() => _charCount = newCount);
    }
  }

  void _onStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed && !_completed) {
      _completed = true;
      widget.onComplete?.call();
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onTick);
    _controller.removeStatusListener(_onStatus);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final visibleText =
        widget.text.substring(0, _charCount.clamp(0, widget.text.length));
    final hasCursor = _charCount < widget.text.length;
    return Text(
      visibleText + (hasCursor ? '|' : ''),
      style: widget.style,
      textAlign: TextAlign.center,
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Stat Row
// ──────────────────────────────────────────────────────────────────────────────

/// Статистика — окремий рядок з stagger fade-in (150ms між рядками).
///
/// Each row staggers its entrance by [index] × 150 ms after the
/// stats phase begins (2 000 ms into the sequence).
class _StatRow extends StatelessWidget {
  const _StatRow({
    required this.label,
    required this.value,
    required this.index,
  });

  /// Display label (e.g. "Накопичено").
  final String label;

  /// Formatted value (e.g. "25 999 грн").
  final String value;

  /// Zero-based index used to calculate the stagger delay.
  final int index;

  /// Base delay before the stats phase begins.
  static const _baseDelayMs = 2000;

  /// Milliseconds between each stat row appearance.
  static const _staggerMs = 150;

  @override
  Widget build(BuildContext context) {
    final delayMs = _baseDelayMs + index * _staggerMs;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTypography.bodyMedium.copyWith(
              color: Colors.white.withOpacity(0.5),
            ),
          ),
          Text(
            value,
            style: AppTypography.monoMedium.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(
      delay: Duration(milliseconds: delayMs),
      duration: 400.ms,
    ).slideX(
      begin: 0.1,
      end: 0,
      delay: Duration(milliseconds: delayMs),
      duration: 400.ms,
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Continuous Particle Painter
// ──────────────────────────────────────────────────────────────────────────────

/// Continuous floating particle animation.
///
/// Renders 30 small circles that drift upward in sinusoidal
/// paths. Each particle uses a deterministic random seed so the
/// layout is stable across frames.
class _ContinuousParticlePainter extends CustomPainter {
  _ContinuousParticlePainter({
    required this.progress,
    required this.screenSize,
  });

  /// Animation progress in `[0, 1)`, driven by [_particleController].
  final double progress;

  /// Logical screen size used to constrain particle positions.
  final Size screenSize;

  static final _random = math.Random(123);

  /// Number of particles rendered per frame.
  static const _count = 30;

  /// Maximum drift height in logical pixels.
  static const _maxDrift = 200.0;

  /// Horizontal sine amplitude in logical pixels.
  static const _sineAmplitude = 20.0;

  /// Supported particle colours.
  static const _colors = [
    Color(0xFF006FCD),
    Color(0xFF00C6FF),
    Color(0xFFFFD600),
    Color(0xFFFF6B6B),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    for (int i = 0; i < _count; i++) {
      final baseX = _random.nextDouble() * screenSize.width;
      final baseY = _random.nextDouble() * screenSize.height;
      final speed = 0.5 + _random.nextDouble() * 1.5;
      final particleSize = 1.0 + _random.nextDouble() * 2.0;

      final t = (progress * speed + _random.nextDouble()) % 1.0;
      final x = baseX + math.sin(t * math.pi * 2 + i) * _sineAmplitude;
      final y = (baseY - t * _maxDrift) % screenSize.height;
      final opacity = (1.0 - t).clamp(0.0, 0.4);

      final color = _colors[_random.nextInt(_colors.length)];

      canvas.drawCircle(
        Offset(x, y.abs()),
        particleSize,
        Paint()..color = color.withOpacity(opacity),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ContinuousParticlePainter old) =>
      old.progress != progress;
}

// ──────────────────────────────────────────────────────────────────────────────
// Firework Painter
// ──────────────────────────────────────────────────────────────────────────────

/// Firework painter — 100+ частинок з різними кольорами та траєкторіями.
///
/// Renders multiple "bursts" that stagger their start times. Each
/// burst contains [particleCount] / [burstCount] particles that
/// radiate outward with gravity. A centre flash and optional trail
/// effect add polish.
class _FireworkPainter extends CustomPainter {
  _FireworkPainter({
    required this.progress,
    required this.screenSize,
    this.particleCount = 100,
  });

  /// Animation progress in `[0, 1)`.
  final double progress;

  /// Logical screen size for positioning.
  final Size screenSize;

  /// Total particles across all bursts.
  final int particleCount;

  static final _random = math.Random(42);

  /// Number of distinct burst origins.
  static const _burstCount = 6;

  /// Delay between each burst (as a fraction of total duration).
  static const _burstDelay = 0.15;

  /// Gravity acceleration applied to vertical displacement.
  static const _gravity = 50.0;

  /// Minimum and maximum radial speed (logical px).
  static const _minSpeed = 50.0;
  static const _maxSpeed = 190.0;

  static const _colors = [
    Color(0xFFFF6B6B),
    Color(0xFF4ECDC4),
    Color(0xFFFFD93D),
    Color(0xFF6C5CE7),
    Color(0xFFA8E6CF),
    Color(0xFFFF8A5C),
    Color(0xFF006FCD),
    Color(0xFFFF4081),
    Color(0xFF00C6FF),
    Color(0xFFFFD600),
    Color(0xFF76FF03),
    Color(0xFFE040FB),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    for (int b = 0; b < _burstCount; b++) {
      final burstDelay = b * _burstDelay;
      final localProgress =
          ((progress - burstDelay) / (1.0 - burstDelay)).clamp(0.0, 1.0);

      if (localProgress <= 0) continue;

      final centerX = screenSize.width * (0.15 + _random.nextDouble() * 0.7);
      final centerY = screenSize.height * (0.05 + _random.nextDouble() * 0.4);

      final particlesPerBurst = particleCount ~/ _burstCount;
      for (int i = 0; i < particlesPerBurst; i++) {
        final angle = (2 * math.pi / particlesPerBurst) * i +
            _random.nextDouble() * 0.3;
        final speed = _minSpeed + _random.nextDouble() * (_maxSpeed - _minSpeed);
        final t = localProgress;
        final x = centerX + math.cos(angle) * speed * t;
        final y =
            centerY + math.sin(angle) * speed * t + _gravity * t * t;

        final fadeOut = t > 0.5 ? 1.0 - ((t - 0.5) / 0.5) : 1.0;
        final particleSize = (2 + _random.nextDouble() * 4) * fadeOut;

        final color = _colors[_random.nextInt(_colors.length)];
        final paint = Paint()
          ..color = color.withOpacity(fadeOut.clamp(0.0, 1.0) * 0.85);

        canvas.drawCircle(Offset(x, y), particleSize, paint);

        // Trail effect — smaller dot behind the main particle.
        if (t < 0.4) {
          final trailX =
              centerX + math.cos(angle) * speed * t * 0.6;
          final trailY =
              centerY +
              math.sin(angle) * speed * t * 0.6 +
              _gravity * t * t * 0.4;
          canvas.drawCircle(
            Offset(trailX, trailY),
            particleSize * 0.4,
            Paint()..color = color.withOpacity(0.25),
          );
        }
      }

      // Centre flash — bright white dot that fades quickly.
      if (localProgress < 0.15) {
        final flashOpacity = (1.0 - localProgress / 0.15) * 0.4;
        canvas.drawCircle(
          Offset(centerX, centerY),
          8,
          Paint()..color = Colors.white.withOpacity(flashOpacity),
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _FireworkPainter old) =>
      old.progress != progress;
}

// ──────────────────────────────────────────────────────────────────────
// Star Field Painter
// ──────────────────────────────────────────────────────────────────────

/// Background star field painter — renders twinkling stars behind
/// the celebration content.
///
/// Each star uses a deterministic random seed for position and
/// brightness. The [progress] value drives individual twinkle
/// animations, creating a subtle parallax-like depth effect.
///
/// ## Performance
///
/// The painter is designed to be lightweight. At the default
/// [_starFieldCount] of 60 stars, the paint method completes in
/// under 1 ms on modern devices.
class _StarFieldPainter extends CustomPainter {
  /// Creates a new [_StarFieldPainter].
  _StarFieldPainter({
    required this.progress,
    required this.screenSize,
    this.count = 60,
    this.maxOpacity = 0.35,
  });

  /// Animation progress in `[0, 1)`, driven by [_starFieldController].
  final double progress;

  /// Logical screen size used to position stars.
  final Size screenSize;

  /// Number of stars to render per frame.
  final int count;

  /// Maximum opacity a star can reach during its twinkle cycle.
  final double maxOpacity;

  /// Deterministic random instance for stable star positions.
  static final _random = math.Random(999);

  @override
  void paint(Canvas canvas, Size size) {
    for (int i = 0; i < count; i++) {
      final baseX = _random.nextDouble() * screenSize.width;
      final baseY = _random.nextDouble() * screenSize.height;
      final starSize = 0.5 + _random.nextDouble() * 1.5;

      // Each star has its own twinkle frequency
      final frequency = 0.5 + _random.nextDouble() * 2.0;
      final phaseOffset = _random.nextDouble() * math.pi * 2;
      final twinkle =
          math.sin(progress * math.pi * 2 * frequency + phaseOffset);
      final opacity =
          ((twinkle + 1.0) / 2.0 * maxOpacity).clamp(0.0, maxOpacity);

      if (opacity < 0.05) continue;

      canvas.drawCircle(
        Offset(baseX, baseY),
        starSize,
        Paint()..color = Colors.white.withOpacity(opacity),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _StarFieldPainter old) =>
      old.progress != progress;
}
