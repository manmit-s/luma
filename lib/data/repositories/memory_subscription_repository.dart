import '../../domain/entities/subscription.dart';
import '../../domain/repositories/subscription_repository.dart';

class MemorySubscriptionRepository implements SubscriptionRepository {
  MemorySubscriptionRepository({List<Subscription>? initial})
      : _subscriptions = List.of(initial ?? []);

  final List<Subscription> _subscriptions;
  int _nextId = 100;

  @override
  Future<List<Subscription>> getAll() async {
    final list = List<Subscription>.from(_subscriptions)
      ..sort((a, b) => a.nextRenewalDate.compareTo(b.nextRenewalDate));
    return list;
  }

  @override
  Future<List<Subscription>> getActive() async {
    final list = _subscriptions
        .where((s) => s.status == SubscriptionStatus.active || s.status == SubscriptionStatus.trial)
        .toList()
      ..sort((a, b) => a.nextRenewalDate.compareTo(b.nextRenewalDate));
    return list;
  }

  @override
  Future<Subscription?> findById(int id) async {
    try {
      return _subscriptions.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<Subscription> save(Subscription subscription) async {
    if (subscription.id == 0) {
      final saved = subscription.copyWith(id: _nextId++);
      _subscriptions.add(saved);
      return saved;
    }
    final index = _subscriptions.indexWhere((s) => s.id == subscription.id);
    if (index >= 0) {
      _subscriptions[index] = subscription;
    } else {
      _subscriptions.add(subscription);
    }
    return subscription;
  }

  @override
  Future<void> delete(int id) async {
    _subscriptions.removeWhere((s) => s.id == id);
  }

  @override
  Future<void> clearAll() async {
    _subscriptions.clear();
  }
}
