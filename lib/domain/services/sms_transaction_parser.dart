import '../entities/expense.dart';

class ParsedTransaction {
  const ParsedTransaction({required this.amountMinor, required this.transactionType, this.merchant, this.referenceNumber, this.timestamp, required this.rawMessage, required this.confidence});
  final int amountMinor;
  final TransactionType transactionType;
  final String? merchant;
  final String? referenceNumber;
  final DateTime? timestamp;
  final String rawMessage;
  final double confidence;
}

class SmsTransactionParser {
  static final _amountPattern = RegExp(r'(?:rs\.?|inr|₹)\s*([0-9,]+(?:\.\d{1,2})?)', caseSensitive: false);
  static final _referencePattern = RegExp(r'(?:upi\s*(?:ref|id)?|ref(?:erence)?)\s*[:#-]?\s*([a-z0-9-]{6,})', caseSensitive: false);
  static final _debitWords = RegExp(r'\b(debited|debit|spent|paid|payment|upi|withdrawn)\b', caseSensitive: false);
  static final _creditWords = RegExp(r'\b(credited|credit|received)\b', caseSensitive: false);

  ParsedTransaction? parse(String message, {DateTime? receivedAt}) {
    final normalized = message.replaceAll(RegExp(r'\s+'), ' ').trim();
    final amountMatch = _amountPattern.firstMatch(normalized);
    if (amountMatch == null) return null;
    final transactionType = _creditWords.hasMatch(normalized) && !_debitWords.hasMatch(normalized)
        ? TransactionType.credit
        : _debitWords.hasMatch(normalized)
            ? TransactionType.debit
            : TransactionType.unknown;
    if (transactionType == TransactionType.unknown) return null;
    final rawAmount = amountMatch.group(1)!.replaceAll(',', '');
    final amount = double.tryParse(rawAmount);
    if (amount == null || amount <= 0) return null;
    final reference = _referencePattern.firstMatch(normalized)?.group(1);
    return ParsedTransaction(amountMinor: (amount * 100).round(), transactionType: transactionType, merchant: _merchant(normalized, amountMatch.start), referenceNumber: reference, timestamp: receivedAt, rawMessage: message, confidence: reference == null ? 0.75 : 0.9);
  }

  String? _merchant(String message, int amountStart) {
    final prefix = message.substring(0, amountStart).replaceFirst(RegExp(r'^.*?(?:debited|debit|spent|paid|payment|upi)\s+(?:by\s+)?', caseSensitive: false), '').trim();
    if (prefix.isEmpty || prefix.length > 80) return null;
    return prefix.replaceAll(RegExp(r'^(?:your\s+)?a/c\s+[^ ]+\s*', caseSensitive: false), '').trim();
  }
}
