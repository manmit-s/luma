import '../../domain/entities/internal_transfer.dart';
import '../../domain/entities/payment_source.dart';
import '../../domain/repositories/source_repository.dart';

class MemorySourceRepository implements SourceRepository {
  MemorySourceRepository({bool seed = true})
      : _sources = seed ? _seed() : [],
        _transfers = [];

  final List<PaymentSource> _sources;
  final List<InternalTransfer> _transfers;

  static List<PaymentSource> _seed() => [
        PaymentSource(
          id: 1,
          type: PaymentSourceType.wallet,
          bankIdentifier: 'cash_wallet',
          nickname: 'Cash Wallet',
          openingBalanceMinor: 0,
          isActive: true,
          createdAt: DateTime(2026, 1, 1),
          updatedAt: DateTime(2026, 1, 1),
        ),
      ];

  @override
  Future<List<PaymentSource>> getAllSources() async =>
      List.unmodifiable(_sources);

  @override
  Future<PaymentSource?> getSourceById(int id) async {
    for (final s in _sources) {
      if (s.id == id) return s;
    }
    return null;
  }

  @override
  Future<PaymentSource> saveSource(PaymentSource source) async {
    if (source.id <= 0) {
      final nextId =
          _sources.fold(0, (max, item) => item.id > max ? item.id : max) + 1;
      final created = PaymentSource(
        id: nextId,
        type: source.type,
        bankName: source.bankName,
        bankIdentifier: source.bankIdentifier,
        nickname: source.nickname,
        accountNumberLast4: source.accountNumberLast4,
        openingBalanceMinor: source.openingBalanceMinor,
        isActive: source.isActive,
        createdAt: source.createdAt,
        updatedAt: source.updatedAt,
      );
      _sources.add(created);
      return created;
    }
    final index = _sources.indexWhere((s) => s.id == source.id);
    if (index == -1) {
      _sources.add(source);
    } else {
      _sources[index] = source;
    }
    return source;
  }

  @override
  Future<void> deleteSource(int id) async {
    _sources.removeWhere((s) => s.id == id);
  }

  @override
  Future<List<InternalTransfer>> getAllTransfers() async =>
      List.unmodifiable(_transfers);

  @override
  Future<InternalTransfer?> getTransferById(int id) async {
    for (final t in _transfers) {
      if (t.id == id) return t;
    }
    return null;
  }

  @override
  Future<InternalTransfer> saveTransfer(InternalTransfer transfer) async {
    if (transfer.id <= 0) {
      final nextId =
          _transfers.fold(0, (max, item) => item.id > max ? item.id : max) + 1;
      final created = InternalTransfer(
        id: nextId,
        fromSourceId: transfer.fromSourceId,
        toSourceId: transfer.toSourceId,
        amountMinor: transfer.amountMinor,
        timestamp: transfer.timestamp,
        note: transfer.note,
        createdAt: transfer.createdAt,
        updatedAt: transfer.updatedAt,
      );
      _transfers.add(created);
      return created;
    }
    final index = _transfers.indexWhere((t) => t.id == transfer.id);
    if (index == -1) {
      _transfers.add(transfer);
    } else {
      _transfers[index] = transfer;
    }
    return transfer;
  }

  @override
  Future<void> deleteTransfer(int id) async {
    _transfers.removeWhere((t) => t.id == id);
  }

  @override
  Future<void> clearAll() async {
    _sources.clear();
    _transfers.clear();
  }
}
