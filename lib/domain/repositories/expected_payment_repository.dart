import '../entities/expected_payment.dart';

abstract interface class ExpectedPaymentRepository {
  Future<List<ExpectedPayment>> getAll();
  Future<List<ExpectedPayment>> getUpcoming();
  Future<List<ExpectedPayment>> getBySubscriptionId(int subscriptionId);
  Future<ExpectedPayment?> findById(int id);
  Future<ExpectedPayment> save(ExpectedPayment payment);
  Future<void> delete(int id);
  Future<void> deleteBySubscriptionId(int subscriptionId);
  Future<void> clearAll();
}
