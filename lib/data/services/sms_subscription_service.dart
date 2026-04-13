import 'dart:async';

/// Модель знайденої підписки.
class DetectedSubscription {
  final String name;
  final double amount;
  final String sourceSms;
  final DateTime date;

  DetectedSubscription({
    required this.name,
    required this.amount,
    required this.sourceSms,
    required this.date,
  });
}

/// Сервіс імітації сканування SMS для пошуку підписок.
class SmsSubscriptionService {
  /// Імітує сканування та повертає список знайдених потенційних підписок.
  Future<List<DetectedSubscription>> scanForSubscriptions() async {
    // Імітація затримки сканування
    await Future.delayed(const Duration(seconds: 2));

    return [
      DetectedSubscription(
        name: 'Netflix',
        amount: 350.0,
        sourceSms: 'Платіж 350.00 UAH NETFLIX.COM',
        date: DateTime.now().subtract(const Duration(days: 2)),
      ),
      DetectedSubscription(
        name: 'Spotify',
        amount: 199.0,
        sourceSms: 'Списання 199.00 UAH Spotify AB',
        date: DateTime.now().subtract(const Duration(days: 5)),
      ),
      DetectedSubscription(
        name: 'YouTube Premium',
        amount: 99.0,
        sourceSms: 'Google YouTube Premium 99.00 UAH',
        date: DateTime.now().subtract(const Duration(days: 10)),
      ),
      DetectedSubscription(
        name: 'iCloud',
        amount: 35.0,
        sourceSms: 'APPLE.COM/BILL 35.00 UAH',
        date: DateTime.now().subtract(const Duration(days: 15)),
      ),
    ];
  }
}
