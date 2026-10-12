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

  // SBI-style bare amounts with no currency marker ("debited by 1.00", "debited by 500", "credited by 2.00").
  // Requires debit/credit verb + preposition (by/for/with) so phone numbers and reference
  // numbers are never matched.
  static final _bareAmountPattern = RegExp(
    r'(?:debited|credited|spent|paid|withdrawn|transferred|deposited)\s+(?:by|for|with)\s+([0-9,]+(?:\.\d{1,2})?)',
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

  // Explicit account credit indicators
  static final _creditActionPattern = RegExp(
    r'(?:'
    r'[- ]credited\s+(?:by|with|to|in)?\b|'
    r'\bcredited\b|'
    r'\bamount\s+credited\b|'
    r'\b(?:a\/c|acct|account)\s+(?:is\s+|has\s+been\s+)?credited\b|'
    r'\b(?:is|has\s+been|was)\s+credited\b|'
    r'\b(?:transfer(?:red)?|trf)\s+from\b|'
    r'\breceived\s+(?:by|from|in|for|rs\.?|inr|₹)?\b|'
    r'\bamount\s+received\b|'
    r'\b(?:deposited|deposit)\b|'
    r'\b(?:refund(?:ed)?|cashback)\b|'
    r'\bcredit\b(?!\s+(?:card|limit|line|score|balance))'
    r')',
    caseSensitive: false,
  );

  // Explicit account debit indicators
  static final _debitActionPattern = RegExp(
    r'(?:'
    r'[- ]debited\s+(?:by|with|from)?\b|'
    r'\bdebited\b|'
    r'\bamount\s+debited\b|'
    r'\b(?:a\/c|acct|account)\s+(?:is\s+|has\s+been\s+)?debited\b|'
    r'\b(?:is|has\s+been|was)\s+debited\b|'
    r'\b(?:withdrawn|withdrawal|deducted)\b|'
    r'\b(?:spent|sent)\b|'
    r'\b(?:transfer(?:red)?|trf)\s+to\b|'
    r'\b(?:paid\s+to|paid\s+at|paid\s+for|sent\s+to)\b|'
    r'\b(?:paid|purchase)\b|'
    r'\bdebit\b(?!\s+card)'
    r')',
    caseSensitive: false,
  );

  static final _datePattern = RegExp(
    r'\b(\d{1,2})[-/ ]?(jan|feb|mar|apr|may|jun|jul|aug|sep|oct|nov|dec)[a-z]*[-/ ]?(\d{2,4})\b',
    caseSensitive: false,
  );

  static final _numericDatePattern = RegExp(
    r'\b(\d{1,2})[-/.](\d{1,2})[-/.](\d{2,4})\b',
  );

  static final _timePattern = RegExp(
    r'\b([01]?\d|2[0-3]):([0-5]\d)(?::([0-5]\d))?\s*(am|pm)?\b',
    caseSensitive: false,
  );

  static ({int year, int month, int day})? _extractDate(String message) {
    final match = _datePattern.firstMatch(message);
    if (match != null) {
      final day = int.tryParse(match.group(1)!);
      final monthStr = match.group(2)!.toLowerCase();
      final yearStr = match.group(3)!;
      if (day != null && day >= 1 && day <= 31) {
        const months = {
          'jan': 1, 'feb': 2, 'mar': 3, 'apr': 4, 'may': 5, 'jun': 6,
          'jul': 7, 'aug': 8, 'sep': 9, 'oct': 10, 'nov': 11, 'dec': 12,
        };
        final month = months[monthStr];
        var year = int.tryParse(yearStr);
        if (month != null && year != null) {
          if (year < 100) year += 2000;
          return (year: year, month: month, day: day);
        }
      }
    }

    final numMatch = _numericDatePattern.firstMatch(message);
    if (numMatch != null) {
      final day = int.tryParse(numMatch.group(1)!);
      final month = int.tryParse(numMatch.group(2)!);
      var year = int.tryParse(numMatch.group(3)!);
      if (day != null &&
          day >= 1 &&
          day <= 31 &&
          month != null &&
          month >= 1 &&
          month <= 12 &&
          year != null) {
        if (year < 100) year += 2000;
        return (year: year, month: month, day: day);
      }
    }

    return null;
  }

  static ({int hour, int minute, int second})? _extractTime(String message) {
    final timeMatch = _timePattern.firstMatch(message);
    if (timeMatch == null) return null;
    var hour = int.tryParse(timeMatch.group(1)!);
    final minute = int.tryParse(timeMatch.group(2)!);
    final second = int.tryParse(timeMatch.group(3) ?? '') ?? 0;
    final ampm = timeMatch.group(4)?.toLowerCase();

    if (hour == null || minute == null) return null;

    if (ampm != null) {
      if (ampm == 'pm' && hour < 12) hour += 12;
      if (ampm == 'am' && hour == 12) hour = 0;
    }

    if (hour < 0 || hour > 23 || minute < 0 || minute > 59) return null;

    return (hour: hour, minute: minute, second: second);
  }

  static DateTime? _parseTimestamp(String message, {DateTime? receivedAt}) {
    final d = _extractDate(message);
    final t = _extractTime(message);

    if (d != null) {
      if (t != null) {
        return DateTime(d.year, d.month, d.day, t.hour, t.minute, t.second);
      } else if (receivedAt != null) {
        return DateTime(d.year, d.month, d.day, receivedAt.hour, receivedAt.minute, receivedAt.second);
      } else {
        return DateTime(d.year, d.month, d.day);
      }
    } else if (t != null) {
      if (receivedAt != null) {
        return DateTime(receivedAt.year, receivedAt.month, receivedAt.day, t.hour, t.minute, t.second);
      } else {
        final now = DateTime.now();
        return DateTime(now.year, now.month, now.day, t.hour, t.minute, t.second);
      }
    } else {
      return receivedAt;
    }
  }

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

  // 5. "transfer from <Merchant>" / "from <Merchant>" / "trf from <Merchant>" / "received from <Merchant>"
  static final _fromPayeePattern = RegExp(
    r"(?:\btransfer(?:red)?\s+from\b|\btrf\s+from\b|\breceived\s+from\b|\bfrom\b)\s+(?:vpa\s+)?([A-Za-z0-9 .&\u2019'@-]{2,50}?)(?=\s+(?:to\b|refno\b|ref\b|upi\b|on\b|date\b|dated\b|via\b|using\b|avl\b|avail\b|bal\b|\.|\(|$))",
    caseSensitive: false,
  );

  // 6. "to VPA <vpa>" or "to <payee>" e.g. "to VPA swiggy@icici", "to Starbucks", "trf to JAGANNATH SAMAL"
  static final _toPayeePattern = RegExp(
    r"(?:\btrf\s+to\b|\btransfer(?:red)?\s+to\b|\bpaid\s+to\b|\bcredited\s+to\b|\bdebited\s+to\b|\bsent\s+to\b|\bto\b)\s+(?:vpa\s+)?([A-Za-z0-9 .&\u2019'@-]{2,50}?)(?=\s+(?:from\b|refno\b|ref\b|upi\b|on\b|date\b|dated\b|via\b|using\b|avl\b|avail\b|bal\b|\.|\(|$))",
    caseSensitive: false,
  );

  ParsedTransaction? parse(String message, {DateTime? receivedAt}) {
    final normalized = message.replaceAll(RegExp(r'\s+'), ' ').trim();
    final amountMatch =
        _amountPattern.firstMatch(normalized) ?? _bareAmountPattern.firstMatch(normalized);
    if (amountMatch == null) return null;

    final rawAmount = amountMatch.group(1)!.replaceAll(',', '');
    final amount = double.tryParse(rawAmount);
    if (amount == null || amount <= 0) return null;

    final hasCredit = _creditActionPattern.hasMatch(normalized);
    final hasDebit = _debitActionPattern.hasMatch(normalized);

    final TransactionType transactionType;
    if (hasCredit && !hasDebit) {
      transactionType = TransactionType.credit;
    } else if (hasDebit && !hasCredit) {
      transactionType = TransactionType.debit;
    } else if (hasCredit && hasDebit) {
      // Both matched: prioritize explicit account-level verb
      final accountCredit = RegExp(
        r'[- ]credited\b|\bcredited\s+(?:by|with|to|in)?\b|\bamount\s+credited\b|\b(?:a\/c|acct|account)\s+(?:is\s+|has\s+been\s+)?credited\b',
        caseSensitive: false,
      ).hasMatch(normalized);
      final accountDebit = RegExp(
        r'[- ]debited\b|\bdebited\s+(?:by|with|from)?\b|\bamount\s+debited\b|\b(?:a\/c|acct|account)\s+(?:is\s+|has\s+been\s+)?debited\b',
        caseSensitive: false,
      ).hasMatch(normalized);

      if (accountCredit && !accountDebit) {
        transactionType = TransactionType.credit;
      } else if (accountDebit && !accountCredit) {
        transactionType = TransactionType.debit;
      } else {
        transactionType = TransactionType.unknown;
      }
    } else {
      transactionType = TransactionType.unknown;
    }

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

    final timestamp = _parseTimestamp(normalized, receivedAt: receivedAt);

    return ParsedTransaction(
      amountMinor: (amount * 100).round(),
      transactionType: transactionType,
      merchant: _merchant(normalized, digitsStart, transactionType: transactionType),
      referenceNumber: reference,
      timestamp: timestamp,
      rawMessage: message,
      confidence: reference == null ? 0.75 : 0.9,
    );
  }

  String? _merchant(String message, int amountStart, {TransactionType? transactionType}) {
    // 1. Try structured patterns after amount or anywhere in text
    // Info pattern: Info: BIL*NETFLIX
    for (final m in _infoPattern.allMatches(message)) {
      final cleaned = _cleanMerchant(m.group(1));
      if (cleaned != null) return cleaned;
    }

    // UPI Path pattern: UPI/P2M/.../Zomato
    for (final m in _upiPathPattern.allMatches(message)) {
      final cleaned = _cleanMerchant(m.group(1));
      if (cleaned != null) return cleaned;
    }

    // "at <Merchant>"
    for (final m in _atMerchantPattern.allMatches(message)) {
      final cleaned = _cleanMerchant(m.group(1));
      if (cleaned != null) return cleaned;
    }

    // "towards <Merchant>"
    for (final m in _towardsPattern.allMatches(message)) {
      final cleaned = _cleanMerchant(m.group(1));
      if (cleaned != null) return cleaned;
    }

    if (transactionType == TransactionType.credit) {
      // For credits: check from first ("transfer from YouTube"), then to
      for (final m in _fromPayeePattern.allMatches(message)) {
        final cleaned = _cleanMerchant(m.group(1));
        if (cleaned != null) return cleaned;
      }

      for (final m in _toPayeePattern.allMatches(message)) {
        final cleaned = _cleanMerchant(m.group(1));
        if (cleaned != null) return cleaned;
      }
    } else {
      // For debits / unknown: check to first ("to Ramesh Sharma"), then from
      for (final m in _toPayeePattern.allMatches(message)) {
        final cleaned = _cleanMerchant(m.group(1));
        if (cleaned != null) return cleaned;
      }

      for (final m in _fromPayeePattern.allMatches(message)) {
        final cleaned = _cleanMerchant(m.group(1));
        if (cleaned != null) return cleaned;
      }
    }

    // Fallback: prefix before amount ("Swiggy debited Rs 250...")
    final prefix = message
        .substring(0, amountStart)
        .replaceFirst(
          RegExp(
            r'^.*(?:debited|credited|debit|credit|spent|paid|payment|upi|withdrawn|sent|deducted)\s+(?:by\s+|for\s+|with\s+)?',
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
