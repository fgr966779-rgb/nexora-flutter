import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_radii.dart';
import '../../../../core/widgets/app_button_primary.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../data/services/sms_subscription_service.dart';

/// Екран сканера підписок по SMS.
class SubscriptionScannerScreen extends StatefulWidget {
  const SubscriptionScannerScreen({super.key});

  @override
  State<SubscriptionScannerScreen> createState() => _SubscriptionScannerScreenState();
}

class _SubscriptionScannerScreenState extends State<SubscriptionScannerScreen> {
  final SmsSubscriptionService _service = SmsSubscriptionService();
  List<DetectedSubscription> _subscriptions = [];
  bool _isScanning = false;
  bool _hasScanned = false;

  Future<void> _startScan() async {
    setState(() {
      _isScanning = true;
      _hasScanned = false;
    });

    final results = await _service.scanForSubscriptions();

    setState(() {
      _subscriptions = results;
      _isScanning = false;
      _hasScanned = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColorsPS5.background : AppColorsMonitor.background,
      appBar: AppBar(
        title: const Text('Сканер підписок'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: isDark ? AppColorsPS5.textPrimary : AppColorsMonitor.textPrimary,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(Spacing.base),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildInfoCard(isDark),
              const SizedBox(height: Spacing.lg),
              if (!_hasScanned && !_isScanning)
                _buildInitialState(isDark)
              else if (_isScanning)
                _buildScanningState(isDark)
              else
                Expanded(child: _buildResultsList(isDark)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(bool isDark) {
    return AppCard(
      isLightTheme: !isDark,
      child: Row(
        children: [
          Icon(Icons.info_outline_rounded, color: isDark ? AppColorsPS5.accent : AppColorsMonitor.accent),
          const SizedBox(width: Spacing.md),
          Expanded(
            child: Text(
              'Ми проаналізуємо SMS від банків, щоб знайти регулярні платежі та допомогти вам заощадити.',
              style: AppTypography.bodySmall.copyWith(color: isDark ? AppColorsPS5.textSecondary : AppColorsMonitor.textSecondary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInitialState(bool isDark) {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.sms_failed_rounded, size: 80, color: isDark ? AppColorsPS5.border : AppColorsMonitor.border),
          const SizedBox(height: Spacing.xl),
          Text(
            'Готові почати сканування?',
            style: AppTypography.heading2.copyWith(color: isDark ? AppColorsPS5.textPrimary : AppColorsMonitor.textPrimary),
          ),
          const SizedBox(height: Spacing.md),
          AppButtonPrimary(
            label: 'Почати сканування',
            onPressed: _startScan,
            isLightTheme: !isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildScanningState(bool isDark) {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(color: AppColorsPS5.accent),
          const SizedBox(height: Spacing.xl),
          Text(
            'Аналізуємо повідомлення...',
            style: AppTypography.labelLarge.copyWith(color: isDark ? AppColorsPS5.textPrimary : AppColorsMonitor.textPrimary),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsList(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Знайдено ${_subscriptions.length} підписки:',
          style: AppTypography.heading3.copyWith(color: isDark ? AppColorsPS5.textPrimary : AppColorsMonitor.textPrimary),
        ),
        const SizedBox(height: Spacing.md),
        Expanded(
          child: ListView.separated(
            itemCount: _subscriptions.length,
            separatorBuilder: (_, __) => const SizedBox(height: Spacing.sm),
            itemBuilder: (context, index) {
              final sub = _subscriptions[index];
              return AppCard(
                isLightTheme: !isDark,
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    padding: const EdgeInsets.all(Spacing.sm),
                    decoration: BoxDecoration(
                      color: AppColorsPS5.error.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.subscriptions_rounded, color: AppColorsPS5.error),
                  ),
                  title: Text(sub.name, style: AppTypography.labelLarge.copyWith(color: isDark ? AppColorsPS5.textPrimary : AppColorsMonitor.textPrimary)),
                  subtitle: Text(sub.sourceSms, style: AppTypography.caption.copyWith(color: isDark ? AppColorsPS5.textHint : AppColorsMonitor.textHint), maxLines: 1, overflow: TextOverflow.ellipsis),
                  trailing: Text(
                    '${sub.amount.toInt()} грн',
                    style: AppTypography.monoMedium.copyWith(color: AppColorsPS5.error),
                  ),
                ),
              ).animate().fadeIn(delay: (index * 100).ms).slideX();
            },
          ),
        ),
        const SizedBox(height: Spacing.base),
        AppButtonPrimary(
          label: 'Сканувати ще раз',
          onPressed: _startScan,
          isLightTheme: !isDark,
        ),
      ],
    );
  }
}
