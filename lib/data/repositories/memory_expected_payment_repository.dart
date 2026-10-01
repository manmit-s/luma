import '../../domain/entities/expected_payment.dart';
import '../../domain/repositories/expected_payment_repository.dart';

class MemoryExpectedPaymentRepository implements ExpectedPaymentRepository {
  MemoryExpectedPaymentRepository({List<ExpectedPayment>? initial})
      : _payments = List.of(initial ?? []);

  final List<ExpectedPayment> _payments;
  int _nextId = 200;

  @override
  Future<List<ExpectedPayment>> getAll() async {
    final list = List<ExpectedPayment>.from(_payments)
      ..sort((a, b) => a.expectedDate.compareTo(b.expectedDate));
    return list;
  }

  @override
  Future<List<ExpectedPayment>> getUpcoming() async {
    final list = _payments
        .where((p) => p.status == ExpectedPaymentStatus.upcoming)
        .toList()
      ..sort((a, b) => a.expectedDate.compareTo(b.expectedDate));
    return list;
  }

  @override
  Future<List<ExpectedPayment>> getBySubscriptionId(int subscriptionId) async {
    final list = _payments
        .where((p) => p.subscriptionId == subscriptionId)
        .toList()
      ..sort((a, b) => a.expectedDate.compareTo(b.expectedDate));
    return list;
  }

  @override
  Future<ExpectedPayment?> findById(int id) async {
    try {
      return _payments.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<ExpectedPayment> save(ExpectedPayment payment) async {
    if (payment.id == 0) {
      final saved = payment.copyWith(id: _nextId++);
      _payments.add(saved);
      return saved;
    }
    final index = _payments.indexWhere((p) => p.id == payment.id);
    if (index >= 0) {
      _payments[index] = payment;
    } else {
      _payments.add(payment);
    }
    return payment;
  }

  @override
  Future<void> delete(int id) async {
    _payments.removeWhere((p) => p.id == id);
  }

  @override
  Future<void> deleteBySubscriptionId(int subscriptionId) async {
    _payments.removeWhere((p) => p.subscriptionId == subscriptionId);
  }

  @override
  Future<void> clearAll() async {
    _payments.clear();
  }
}
