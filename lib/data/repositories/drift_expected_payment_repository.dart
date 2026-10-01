import 'package:drift/drift.dart';

import '../../domain/entities/expected_payment.dart' as domain;
import '../../domain/repositories/expected_payment_repository.dart';
import '../database/luma_database.dart' as store;

int _statusToInt(domain.ExpectedPaymentStatus s) => switch (s) {
      domain.ExpectedPaymentStatus.upcoming => 0,
      domain.ExpectedPaymentStatus.matched => 1,
      domain.ExpectedPaymentStatus.missed => 2,
      domain.ExpectedPaymentStatus.cancelled => 3,
    };

domain.ExpectedPaymentStatus _statusFromInt(int v) => switch (v) {
      1 => domain.ExpectedPaymentStatus.matched,
      2 => domain.ExpectedPaymentStatus.missed,
      3 => domain.ExpectedPaymentStatus.cancelled,
      _ => domain.ExpectedPaymentStatus.upcoming,
    };

domain.ExpectedPayment _toEntity(store.ExpectedPayment row) =>
    domain.ExpectedPayment(
      id: row.id,
      subscriptionId: row.subscriptionId,
      expectedDate: row.expectedDate,
      expectedAmountMinor: row.expectedAmountMinor,
      status: _statusFromInt(row.status),
      matchedExpenseId: row.matchedExpenseId,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );

class DriftExpectedPaymentRepository implements ExpectedPaymentRepository {
  DriftExpectedPaymentRepository(this.database);

  final store.LumaDatabase database;

  @override
  Future<List<domain.ExpectedPayment>> getAll() async {
    final rows = await (database.select(database.expectedPayments)
          ..orderBy([(t) => OrderingTerm.asc(t.expectedDate)]))
        .get();
    return rows.map(_toEntity).toList();
  }

  @override
  Future<List<domain.ExpectedPayment>> getUpcoming() async {
    final rows = await (database.select(database.expectedPayments)
          ..where((t) => t.status.equals(0))
          ..orderBy([(t) => OrderingTerm.asc(t.expectedDate)]))
        .get();
    return rows.map(_toEntity).toList();
  }

  @override
  Future<List<domain.ExpectedPayment>> getBySubscriptionId(
      int subscriptionId) async {
    final rows = await (database.select(database.expectedPayments)
          ..where((t) => t.subscriptionId.equals(subscriptionId))
          ..orderBy([(t) => OrderingTerm.asc(t.expectedDate)]))
        .get();
    return rows.map(_toEntity).toList();
  }

  @override
  Future<domain.ExpectedPayment?> findById(int id) async {
    final query = database.select(database.expectedPayments)
      ..where((t) => t.id.equals(id));
    final row = await query.getSingleOrNull();
    return row == null ? null : _toEntity(row);
  }

  @override
  Future<domain.ExpectedPayment> save(domain.ExpectedPayment payment) async {
    if (payment.id == 0) {
      final companion = store.ExpectedPaymentsCompanion.insert(
        subscriptionId: payment.subscriptionId,
        expectedDate: payment.expectedDate,
        expectedAmountMinor: payment.expectedAmountMinor,
        status: Value(_statusToInt(payment.status)),
        matchedExpenseId: Value(payment.matchedExpenseId),
        createdAt: payment.createdAt,
        updatedAt: payment.updatedAt,
      );
      final id =
          await database.into(database.expectedPayments).insert(companion);
      return payment.copyWith(id: id);
    } else {
      final companion = store.ExpectedPaymentsCompanion(
        id: Value(payment.id),
        subscriptionId: Value(payment.subscriptionId),
        expectedDate: Value(payment.expectedDate),
        expectedAmountMinor: Value(payment.expectedAmountMinor),
        status: Value(_statusToInt(payment.status)),
        matchedExpenseId: Value(payment.matchedExpenseId),
        createdAt: Value(payment.createdAt),
        updatedAt: Value(payment.updatedAt),
      );
      await database.update(database.expectedPayments).replace(companion);
      return payment;
    }
  }

  @override
  Future<void> delete(int id) async {
    await (database.delete(database.expectedPayments)
          ..where((t) => t.id.equals(id)))
        .go();
  }

  @override
  Future<void> deleteBySubscriptionId(int subscriptionId) async {
    await (database.delete(database.expectedPayments)
          ..where((t) => t.subscriptionId.equals(subscriptionId)))
        .go();
  }

  @override
  Future<void> clearAll() async {
    await database.delete(database.expectedPayments).go();
  }
}
