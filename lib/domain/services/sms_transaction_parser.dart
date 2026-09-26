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
  // SBI-style bare amounts with no currency marker ("debited by 1.00").
  // Strict on purpose: the debit verb must precede, and paise (.NN) are
  // required, so phone numbers and reference numbers can't match.
  static final _bareAmountPattern = RegExp(r'(?:debited|spent|paid|withdrawn)\s+by\s+([0-9,]+\.\d{2})', caseSensitive: false);
  static final _referencePattern = RegExp(r'\b(?:upi\s*(?:ref|id)?|ref(?:erence)?(?:\s*\.?\s*no)?)\s*[:#-]?\s*([a-z0-9-]{6,})', caseSensitive: false);
  // Payee positioned after the amount ("trf to JAGANNATH SAMAL Refno ...").
  // Captures up to the next metadata keyword so refs/dates never leak in.
  static final _payeePattern = RegExp(r'(?:\btrf\b|transfer(?:red)?|paid|credited)\s+to\s+([A-Za-z][A-Za-z0-9 .&\u2019-]{1,60}?)(?=\s+(?:refno|ref\b|upi\b|on\b|date\b|dated\b)|$)', caseSensitive: false);
  static final _debitWords = RegExp(r'\b(debited|debit|spent|paid|payment|upi|withdrawn|trf)\b', caseSensitive: false);
  static final _creditWords = RegExp(r'\b(credited|credit|received)\b', caseSensitive: false);

  ParsedTransaction? parse(String message, {DateTime? receivedAt}) {
    final normalized = message.replaceAll(RegExp(r'\s+'), ' ').trim();
    final amountMatch = _amountPattern.firstMatch(normalized) ?? _bareAmountPattern.firstMatch(normalized);
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
    // Anchor on the digits themselves: the marked pattern's match start sits
    // on the currency marker ("Rs.200"), the bare pattern's on the verb
    // ("debited by 1.00") — group(1) is the digits in both cases.
    final digits = amountMatch.group(1)!;
    final digitsStart =
        amountMatch.start + amountMatch.group(0)!.indexOf(digits);
    return ParsedTransaction(amountMinor: (amount * 100).round(), transactionType: transactionType, merchant: _merchant(normalized, digitsStart), referenceNumber: reference, timestamp: receivedAt, rawMessage: message, confidence: reference == null ? 0.75 : 0.9);
  }

  String? _merchant(String message, int amountStart) {
    // Greedy: strip through the LAST debit word before the amount, so greetings
    // containing verbs ("Dear UPI user ... debited by") can't leak in as names.
    final prefix = message.substring(0, amountStart).replaceFirst(RegExp(r'^.*(?:debited|debit|spent|paid|payment|upi)\s+(?:by\s+)?', caseSensitive: false), '').trim();
    if (prefix.isNotEmpty && prefix.length <= 80) {
      final cleaned = prefix
          .replaceAll(RegExp(r'^(?:your\s+)?a/c\s+[^ ]+\s*', caseSensitive: false), '')
          // Dangling currency marker left behind ("Paid Rs." → "Paid").
          .replaceAll(RegExp(r'(?:rs\.?|inr|₹)\s*$', caseSensitive: false), '')
          .replaceAll(RegExp(r'[.,;:!—\-–\s]+$'), '')
          .trim();
      // Never invent a merchant from punctuation scraps.
      if (cleaned.length >= 2) return cleaned;
    }
    // Fallback: payee named after the amount ("trf to NAME Refno ...").
    final payee = _payeePattern.firstMatch(message)?.group(1)?.trim();
    if (payee == null || payee.length < 2) return null;
    return payee;
  }
}
