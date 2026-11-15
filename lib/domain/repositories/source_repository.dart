import '../entities/internal_transfer.dart';
import '../entities/payment_source.dart';

abstract interface class SourceRepository {
  Future<List<PaymentSource>> getAllSources();
  Future<PaymentSource?> getSourceById(int id);
  Future<PaymentSource> saveSource(PaymentSource source);
  Future<void> deleteSource(int id);

  Future<List<InternalTransfer>> getAllTransfers();
  Future<InternalTransfer?> getTransferById(int id);
  Future<InternalTransfer> saveTransfer(InternalTransfer transfer);
  Future<void> deleteTransfer(int id);

  Future<void> clearAll();
}
