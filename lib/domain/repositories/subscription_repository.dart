import '../entities/subscription.dart';

abstract interface class SubscriptionRepository {
  Future<List<Subscription>> getAll();
  Future<List<Subscription>> getActive();
  Future<Subscription?> findById(int id);
  Future<Subscription> save(Subscription subscription);
  Future<void> delete(int id);
  Future<void> clearAll();
}
