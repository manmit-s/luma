import 'dart:async';

import 'package:drift/drift.dart';

import '../../domain/entities/internal_transfer.dart';
import '../../domain/entities/payment_source.dart';
import '../../domain/repositories/source_repository.dart';
import '../database/luma_database.dart';

class DriftSourceRepository implements SourceRepository {
  DriftSourceRepository(this.database) {
    _initFuture = _ensureSchema();
  }

  final LumaDatabase database;
  late final Future<void> _initFuture;

  Future<void> _ensureSchema() async {
    try {
      await database.customStatement('''
        CREATE TABLE IF NOT EXISTS payment_sources (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          type TEXT NOT NULL,
          bank_name TEXT,
          bank_identifier TEXT,
          nickname TEXT,
          account_number_last4 TEXT,
          opening_balance_minor INTEGER NOT NULL DEFAULT 0,
          is_active INTEGER NOT NULL DEFAULT 1,
          created_at INTEGER NOT NULL,
          updated_at INTEGER NOT NULL
        )
      ''');

      await database.customStatement('''
        CREATE TABLE IF NOT EXISTS internal_transfers (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          from_source_id INTEGER NOT NULL,
          to_source_id INTEGER NOT NULL,
          amount_minor INTEGER NOT NULL,
          timestamp INTEGER NOT NULL,
          note TEXT NOT NULL DEFAULT '',
          created_at INTEGER NOT NULL,
          updated_at INTEGER NOT NULL
        )
      ''');

      try {
        await database.customStatement(
          'ALTER TABLE expenses ADD COLUMN source_id INTEGER NULL',
        );
      } catch (_) {
        // Column may already exist
      }

      // Check if default cash wallet exists
      final existing = await database.customSelect(
        'SELECT COUNT(*) AS count FROM payment_sources',
      ).getSingle();
      final count = existing.data['count'] as int? ?? 0;
      if (count == 0) {
        final now = DateTime.now().millisecondsSinceEpoch;
        await database.customInsert(
          'INSERT INTO payment_sources (type, bank_name, bank_identifier, nickname, account_number_last4, opening_balance_minor, is_active, created_at, updated_at) '
          'VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)',
          variables: [
            Variable.withString('wallet'),
            const Variable<String>(null),
            Variable.withString('cash_wallet'),
            Variable.withString('Cash Wallet'),
            const Variable<String>(null),
            Variable.withInt(0),
            Variable.withInt(1),
            Variable.withInt(now),
            Variable.withInt(now),
          ],
        );
      }
    } catch (_) {
      // Best effort schema initialization
    }
  }

  PaymentSource _mapSourceRow(QueryRow row) {
    final typeStr = row.read<String>('type');
    final type = typeStr == 'bank'
        ? PaymentSourceType.bank
        : PaymentSourceType.wallet;
    final createdAtMs = row.read<int>('created_at');
    final updatedAtMs = row.read<int>('updated_at');

    return PaymentSource(
      id: row.read<int>('id'),
      type: type,
      bankName: row.readNullable<String>('bank_name'),
      bankIdentifier: row.readNullable<String>('bank_identifier'),
      nickname: row.readNullable<String>('nickname'),
      accountNumberLast4: row.readNullable<String>('account_number_last4'),
      openingBalanceMinor: row.read<int>('opening_balance_minor'),
      isActive: (row.read<int>('is_active')) == 1,
      createdAt: DateTime.fromMillisecondsSinceEpoch(createdAtMs),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(updatedAtMs),
    );
  }

  InternalTransfer _mapTransferRow(QueryRow row) {
    final timestampMs = row.read<int>('timestamp');
    final createdAtMs = row.read<int>('created_at');
    final updatedAtMs = row.read<int>('updated_at');

    return InternalTransfer(
      id: row.read<int>('id'),
      fromSourceId: row.read<int>('from_source_id'),
      toSourceId: row.read<int>('to_source_id'),
      amountMinor: row.read<int>('amount_minor'),
      timestamp: DateTime.fromMillisecondsSinceEpoch(timestampMs),
      note: row.readNullable<String>('note') ?? '',
      createdAt: DateTime.fromMillisecondsSinceEpoch(createdAtMs),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(updatedAtMs),
    );
  }

  @override
  Future<List<PaymentSource>> getAllSources() async {
    await _initFuture;
    final rows = await database.customSelect(
      'SELECT * FROM payment_sources ORDER BY is_active DESC, type DESC, id ASC',
    ).get();
    return rows.map(_mapSourceRow).toList();
  }

  @override
  Future<PaymentSource?> getSourceById(int id) async {
    await _initFuture;
    final rows = await database.customSelect(
      'SELECT * FROM payment_sources WHERE id = ?',
      variables: [Variable.withInt(id)],
    ).get();
    if (rows.isEmpty) return null;
    return _mapSourceRow(rows.first);
  }

  @override
  Future<PaymentSource> saveSource(PaymentSource source) async {
    await _initFuture;
    final nowMs = DateTime.now().millisecondsSinceEpoch;
    final typeStr = source.isBank ? 'bank' : 'wallet';

    if (source.id <= 0) {
      final insertedId = await database.customInsert(
        'INSERT INTO payment_sources (type, bank_name, bank_identifier, nickname, account_number_last4, opening_balance_minor, is_active, created_at, updated_at) '
        'VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)',
        variables: [
          Variable.withString(typeStr),
          Variable<String>(source.bankName),
          Variable<String>(source.bankIdentifier),
          Variable<String>(source.nickname),
          Variable<String>(source.accountNumberLast4),
          Variable.withInt(source.openingBalanceMinor),
          Variable.withInt(source.isActive ? 1 : 0),
          Variable.withInt(source.createdAt.millisecondsSinceEpoch),
          Variable.withInt(nowMs),
        ],
      );
      return source.copyWith(id: insertedId, updatedAt: DateTime.fromMillisecondsSinceEpoch(nowMs));
    }

    await database.customUpdate(
      'UPDATE payment_sources SET type = ?, bank_name = ?, bank_identifier = ?, nickname = ?, account_number_last4 = ?, opening_balance_minor = ?, is_active = ?, updated_at = ? WHERE id = ?',
      variables: [
        Variable.withString(typeStr),
        Variable<String>(source.bankName),
        Variable<String>(source.bankIdentifier),
        Variable<String>(source.nickname),
        Variable<String>(source.accountNumberLast4),
        Variable.withInt(source.openingBalanceMinor),
        Variable.withInt(source.isActive ? 1 : 0),
        Variable.withInt(nowMs),
        Variable.withInt(source.id),
      ],
    );
    return source.copyWith(updatedAt: DateTime.fromMillisecondsSinceEpoch(nowMs));
  }

  @override
  Future<void> deleteSource(int id) async {
    await _initFuture;
    await database.customUpdate(
      'DELETE FROM payment_sources WHERE id = ?',
      variables: [Variable.withInt(id)],
    );
  }

  @override
  Future<List<InternalTransfer>> getAllTransfers() async {
    await _initFuture;
    final rows = await database.customSelect(
      'SELECT * FROM internal_transfers ORDER BY timestamp DESC, id DESC',
    ).get();
    return rows.map(_mapTransferRow).toList();
  }

  @override
  Future<InternalTransfer?> getTransferById(int id) async {
    await _initFuture;
    final rows = await database.customSelect(
      'SELECT * FROM internal_transfers WHERE id = ?',
      variables: [Variable.withInt(id)],
    ).get();
    if (rows.isEmpty) return null;
    return _mapTransferRow(rows.first);
  }

  @override
  Future<InternalTransfer> saveTransfer(InternalTransfer transfer) async {
    await _initFuture;
    final nowMs = DateTime.now().millisecondsSinceEpoch;

    if (transfer.id <= 0) {
      final insertedId = await database.customInsert(
        'INSERT INTO internal_transfers (from_source_id, to_source_id, amount_minor, timestamp, note, created_at, updated_at) '
        'VALUES (?, ?, ?, ?, ?, ?, ?)',
        variables: [
          Variable.withInt(transfer.fromSourceId),
          Variable.withInt(transfer.toSourceId),
          Variable.withInt(transfer.amountMinor),
          Variable.withInt(transfer.timestamp.millisecondsSinceEpoch),
          Variable.withString(transfer.note),
          Variable.withInt(transfer.createdAt.millisecondsSinceEpoch),
          Variable.withInt(nowMs),
        ],
      );
      return transfer.copyWith(id: insertedId, updatedAt: DateTime.fromMillisecondsSinceEpoch(nowMs));
    }

    await database.customUpdate(
      'UPDATE internal_transfers SET from_source_id = ?, to_source_id = ?, amount_minor = ?, timestamp = ?, note = ?, updated_at = ? WHERE id = ?',
      variables: [
        Variable.withInt(transfer.fromSourceId),
        Variable.withInt(transfer.toSourceId),
        Variable.withInt(transfer.amountMinor),
        Variable.withInt(transfer.timestamp.millisecondsSinceEpoch),
        Variable.withString(transfer.note),
        Variable.withInt(nowMs),
        Variable.withInt(transfer.id),
      ],
    );
    return transfer.copyWith(updatedAt: DateTime.fromMillisecondsSinceEpoch(nowMs));
  }

  @override
  Future<void> deleteTransfer(int id) async {
    await _initFuture;
    await database.customUpdate(
      'DELETE FROM internal_transfers WHERE id = ?',
      variables: [Variable.withInt(id)],
    );
  }

  @override
  Future<void> clearAll() async {
    await _initFuture;
    await database.customStatement('DELETE FROM internal_transfers');
    await database.customStatement('DELETE FROM payment_sources');
  }
}
