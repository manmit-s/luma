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
  static final _amountPattern = RegExp(
    r'(?:rs\.?|inr|₹)\s*([0-9,]+(?:\.\d{1,2})?)',
    caseSensitive: false,
  );

  // SBI-style bare amounts with no currency marker ("debited by 1.00", "debited by 500").
  // Requires debit verb + preposition (by/for/with) so phone numbers and reference
  // numbers are never matched.
  static final _bareAmountPattern = RegExp(
    r'(?:debited|spent|paid|withdrawn|transferred)\s+(?:by|for|with)\s+([0-9,]+(?:\.\d{1,2})?)',
    caseSensitive: false,
  );

  // UPI and Bank reference numbers: Refno, UPI Ref, Ref No, RRN, Txn ID, IMPS Ref, etc.
  static final _referencePatterns = [
    RegExp(r'\bupi\/(?:(?:p2m|p2a|p2p)\/)?([a-z0-9]{6,})', caseSensitive: false),
    RegExp(
      r'\b(?:upi\s*(?:ref|id|rrn)?|ref(?:erence)?(?:\s*\.?\s*no)?|rrn|txn\s*(?:id|no|ref)?|imps\s*ref)\s*[:#\/-]?\s*([a-z0-9-]{6,})',
      caseSensitive: false,
    ),
  ];

  static final _debitWords = RegExp(
    r'\b(debited|debit|spent|paid|payment|upi|withdrawn|trf|transfer|transferred|sent|deducted|purchase)\b',
    caseSensitive: false,
  );

  static final _creditWords = RegExp(
    r'\b(credited|credit|received|refund|cashback)\b',
    caseSensitive: false,
  );

  // Payee / Merchant patterns:
  // 1. "Info: BIL*NETFLIX" or "Info: VPS*Swiggy*Bangalore" or "Info: Zomato"
  static final _infoPattern = RegExp(
    r"\b(?:info|desc)\s*:\s*(?:[a-z0-9]{2,4}\*)?([A-Za-z0-9 .&\u2019'-]{2,50}?)(?=[.*]|\s+(?:avl|avail|bal|ref|$))",
    caseSensitive: false,
  );

  // 2. UPI deep path: "UPI/P2M/426812345678/Zomato" or "UPI/426812345678/Zomato"
  static final _upiPathPattern = RegExp(
    r"\bupi\/(?:(?:p2m|p2a|p2p)\/)?[0-9a-z]+\/([A-Za-z0-9 .&\u2019'-]{2,50}?)(?=\s+(?:avl|avail|bal|ref|on\b|$)|[\/.]|$)",
    caseSensitive: false,
  );

  // 3. "at <Merchant>" e.g. "at Uber", "at AMAZON INDIA", "at Chai Point"
  static final _atMerchantPattern = RegExp(
    r"\bat\s+([A-Za-z0-9 .&\u2019'-]{2,50}?)(?=\s+(?:on\b|dated\b|date\b|via\b|using\b|ref\b|refno\b|upi\b|avl\b|avail\b|bal\b|limit\b|\.|\(|$))",
    caseSensitive: false,
  );

  // 4. "towards <Merchant>" e.g. "towards NETFLIX"
  static final _towardsPattern = RegExp(
    r"\b(?:towards)\s+([A-Za-z0-9 .&\u2019'-]{2,50}?)(?=\s+(?:on\b|dated\b|date\b|via\b|using\b|ref\b|refno\b|upi\b|avl\b|avail\b|bal\b|limit\b|\.|\(|$))",
    caseSensitive: false,
  );

  // 5. "to VPA <vpa>" or "to <payee>" e.g. "to VPA swiggy@icici", "to Starbucks", "trf to JAGANNATH SAMAL"
  static final _toPayeePattern = RegExp(
    r"(?:\btrf\s+to\b|\btransfer(?:red)?\s+to\b|\bpaid\s+to\b|\bcredited\s+to\b|\bdebited\s+to\b|\bsent\s+to\b|\bto\b)\s+(?:vpa\s+)?([A-Za-z0-9 .&\u2019'@-]{2,50}?)(?=\s+(?:refno\b|ref\b|upi\b|on\b|date\b|dated\b|via\b|using\b|avl\b|avail\b|bal\b|\.|\(|$))",
    caseSensitive: false,
  );

  ParsedTransaction? parse(String message, {DateTime? receivedAt}) {
    final normalized = message.replaceAll(RegExp(r'\s+'), ' ').trim();
    final amountMatch =
        _amountPattern.firstMatch(normalized) ?? _bareAmountPattern.firstMatch(normalized);
    if (amountMatch == null) return null;

    final transactionType =
        _creditWords.hasMatch(normalized) && !_debitWords.hasMatch(normalized)
            ? TransactionType.credit
            : _debitWords.hasMatch(normalized)
                ? TransactionType.debit
                : TransactionType.unknown;
    if (transactionType == TransactionType.unknown) return null;

    final rawAmount = amountMatch.group(1)!.replaceAll(',', '');
    final amount = double.tryParse(rawAmount);
    if (amount == null || amount <= 0) return null;

    String? reference;
    for (final pattern in _referencePatterns) {
      final match = pattern.firstMatch(normalized);
      if (match != null) {
        reference = match.group(1);
        break;
      }
    }

    final digits = amountMatch.group(1)!;
    final digitsStart =
        amountMatch.start + amountMatch.group(0)!.indexOf(digits);

    return ParsedTransaction(
      amountMinor: (amount * 100).round(),
      transactionType: transactionType,
      merchant: _merchant(normalized, digitsStart),
      referenceNumber: reference,
      timestamp: receivedAt,
      rawMessage: message,
      confidence: reference == null ? 0.75 : 0.9,
    );
  }

  String? _merchant(String message, int amountStart) {
    // 1. Try structured patterns after amount or anywhere in text
    // Info pattern: Info: BIL*NETFLIX
    final infoMatch = _infoPattern.firstMatch(message)?.group(1);
    final cleanedInfo = _cleanMerchant(infoMatch);
    if (cleanedInfo != null) return cleanedInfo;

    // UPI Path pattern: UPI/P2M/.../Zomato
    final upiPathMatch = _upiPathPattern.firstMatch(message)?.group(1);
    final cleanedUpi = _cleanMerchant(upiPathMatch);
    if (cleanedUpi != null) return cleanedUpi;

    // "at <Merchant>"
    final atMatch = _atMerchantPattern.firstMatch(message)?.group(1);
    final cleanedAt = _cleanMerchant(atMatch);
    if (cleanedAt != null) return cleanedAt;

    // "towards <Merchant>"
    final towardsMatch = _towardsPattern.firstMatch(message)?.group(1);
    final cleanedTowards = _cleanMerchant(towardsMatch);
    if (cleanedTowards != null) return cleanedTowards;

    // "to <Merchant>" / "to VPA <vpa>" / "trf to <Name>"
    final toMatch = _toPayeePattern.firstMatch(message)?.group(1);
    final cleanedTo = _cleanMerchant(toMatch);
    if (cleanedTo != null) return cleanedTo;

    // Fallback: prefix before amount ("Swiggy debited Rs 250...")
    final prefix = message
        .substring(0, amountStart)
        .replaceFirst(
          RegExp(
            r'^.*(?:debited|debit|spent|paid|payment|upi|withdrawn|sent|deducted)\s+(?:by\s+|for\s+|with\s+)?',
            caseSensitive: false,
          ),
          '',
        )
        .trim();
    final cleanedPrefix = _cleanMerchant(prefix);
    if (cleanedPrefix != null) return cleanedPrefix;

    return null;
  }

  String? _cleanMerchant(String? raw) {
    if (raw == null) return null;
    var candidate = raw.trim();

    // If candidate is a VPA like "swiggy@icici" or "merchant@okaxis", strip the handle
    if (candidate.contains('@')) {
      final handle = candidate.split('@').first.trim();
      if (handle.isNotEmpty) {
        candidate = handle;
      }
    }

    // Strip leading phrases and trailing currency/punctuation
    candidate = candidate
        .replaceAll(RegExp(r'^(?:vpa|your|a/c|acct|account)\s+', caseSensitive: false), '')
        .replaceAll(RegExp(r'^(?:your\s+)?a/c\s+[^ ]+\s*', caseSensitive: false), '')
        .replaceAll(RegExp(r'(?:rs\.?|inr|₹)\s*$', caseSensitive: false), '')
        .replaceAll(RegExp(r'^[.,;:!—\-–/*]+\s*'), '')
        .replaceAll(RegExp(r'\s*[.,;:!—\-–/*]+$'), '')
        .trim();

    if (candidate.length < 2 || candidate.length > 60) return null;

    // Noise filter: ensure candidate is not just account words, noise, or bank keywords
    final lower = candidate.toLowerCase();
    const noiseWords = {
      'your a/c',
      'a/c',
      'acct',
      'account',
      'bank',
      'our bank',
      'call',
      'help',
      'services',
      'otp',
      'not u',
      'if not u',
      'customer',
      'dear customer',
      'dear upi user',
      'user',
      'upi user',
      'card',
      'credit card',
      'debit card',
    };
    if (noiseWords.contains(lower)) return null;

    // Must contain at least one letter
    if (!RegExp(r'[A-Za-z]').hasMatch(candidate)) return null;

    return candidate;
  }
}
