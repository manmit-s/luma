enum PaymentSourceType { bank, wallet }

enum BankTier { major, midTier, smallFinance }

class BankCatalogueItem {
  const BankCatalogueItem({
    required this.id,
    required this.name,
    required this.shortName,
    required this.senderCodes,
    required this.tier,
  });

  final String id;
  final String name;
  final String shortName;
  final List<String> senderCodes;
  final BankTier tier;
}

/// Predefined catalogue of popular Indian banks (major, mid-tier, and small finance).
/// Custom bank creation is not allowed per product specification.
const List<BankCatalogueItem> indianBankCatalogue = [
  // --- Major Banks ---
  BankCatalogueItem(
    id: 'sbi',
    name: 'State Bank of India',
    shortName: 'SBI',
    senderCodes: ['SBIINB', 'SBIPSG', 'SBISMS', 'ATMSBI', 'SBIRRN'],
    tier: BankTier.major,
  ),
  BankCatalogueItem(
    id: 'hdfc',
    name: 'HDFC Bank',
    shortName: 'HDFC',
    senderCodes: ['HDFCBK', 'HDFCNC', 'HDFC'],
    tier: BankTier.major,
  ),
  BankCatalogueItem(
    id: 'icici',
    name: 'ICICI Bank',
    shortName: 'ICICI',
    senderCodes: ['ICICIB', 'ICICIS', 'ICICI'],
    tier: BankTier.major,
  ),
  BankCatalogueItem(
    id: 'axis',
    name: 'Axis Bank',
    shortName: 'Axis',
    senderCodes: ['AXISBK', 'AXISIN', 'AXIS'],
    tier: BankTier.major,
  ),
  BankCatalogueItem(
    id: 'kotak',
    name: 'Kotak Mahindra Bank',
    shortName: 'Kotak',
    senderCodes: ['KOTAKB', 'KOTAKM', 'KOTAK'],
    tier: BankTier.major,
  ),
  BankCatalogueItem(
    id: 'pnb',
    name: 'Punjab National Bank',
    shortName: 'PNB',
    senderCodes: ['PNBSMS', 'PUNJAB', 'PNB'],
    tier: BankTier.major,
  ),
  BankCatalogueItem(
    id: 'bob',
    name: 'Bank of Baroda',
    shortName: 'BOB',
    senderCodes: ['BOBTXN', 'BOBSMS', 'BARODA', 'BOB'],
    tier: BankTier.major,
  ),
  BankCatalogueItem(
    id: 'canara',
    name: 'Canara Bank',
    shortName: 'Canara',
    senderCodes: ['CANBNK', 'CANARA'],
    tier: BankTier.major,
  ),
  BankCatalogueItem(
    id: 'union',
    name: 'Union Bank of India',
    shortName: 'Union Bank',
    senderCodes: ['UNIONB', 'UBIN', 'UBI'],
    tier: BankTier.major,
  ),
  BankCatalogueItem(
    id: 'boi',
    name: 'Bank of India',
    shortName: 'BOI',
    senderCodes: ['BOISMS', 'BOIIND', 'BOI'],
    tier: BankTier.major,
  ),
  BankCatalogueItem(
    id: 'indusind',
    name: 'IndusInd Bank',
    shortName: 'IndusInd',
    senderCodes: ['INDBNK', 'INDUS', 'INDUSB'],
    tier: BankTier.major,
  ),
  BankCatalogueItem(
    id: 'idfc',
    name: 'IDFC FIRST Bank',
    shortName: 'IDFC FIRST',
    senderCodes: ['IDFCFB', 'IDFCBN', 'IDFC'],
    tier: BankTier.major,
  ),

  // --- Mid-Tier Banks ---
  BankCatalogueItem(
    id: 'federal',
    name: 'Federal Bank',
    shortName: 'Federal',
    senderCodes: ['FDRLBN', 'FEDBNK', 'FEDRL'],
    tier: BankTier.midTier,
  ),
  BankCatalogueItem(
    id: 'yes',
    name: 'Yes Bank',
    shortName: 'Yes Bank',
    senderCodes: ['YESBNK', 'YESBN', 'YESB'],
    tier: BankTier.midTier,
  ),
  BankCatalogueItem(
    id: 'indian_bank',
    name: 'Indian Bank',
    shortName: 'Indian Bank',
    senderCodes: ['IDIBNK', 'INDBAN'],
    tier: BankTier.midTier,
  ),
  BankCatalogueItem(
    id: 'cbi',
    name: 'Central Bank of India',
    shortName: 'Central Bank',
    senderCodes: ['CBISMS', 'CENTBK'],
    tier: BankTier.midTier,
  ),
  BankCatalogueItem(
    id: 'iob',
    name: 'Indian Overseas Bank',
    shortName: 'IOB',
    senderCodes: ['IOBCHN', 'IOBSMS', 'IOB'],
    tier: BankTier.midTier,
  ),
  BankCatalogueItem(
    id: 'uco',
    name: 'UCO Bank',
    shortName: 'UCO Bank',
    senderCodes: ['UCOBNK', 'UCOCAL'],
    tier: BankTier.midTier,
  ),
  BankCatalogueItem(
    id: 'bom',
    name: 'Bank of Maharashtra',
    shortName: 'BOM',
    senderCodes: ['BOMBNK', 'MAHBK'],
    tier: BankTier.midTier,
  ),
  BankCatalogueItem(
    id: 'psb',
    name: 'Punjab & Sind Bank',
    shortName: 'Punjab & Sind',
    senderCodes: ['PSBSMS', 'PUNSIN'],
    tier: BankTier.midTier,
  ),
  BankCatalogueItem(
    id: 'bandhan',
    name: 'Bandhan Bank',
    shortName: 'Bandhan',
    senderCodes: ['BNDHAN', 'BDNBNK'],
    tier: BankTier.midTier,
  ),
  BankCatalogueItem(
    id: 'rbl',
    name: 'RBL Bank',
    shortName: 'RBL',
    senderCodes: ['RBLBNK', 'RATNAK'],
    tier: BankTier.midTier,
  ),
  BankCatalogueItem(
    id: 'south_indian',
    name: 'South Indian Bank',
    shortName: 'South Indian',
    senderCodes: ['SIBLTD', 'SOINBN'],
    tier: BankTier.midTier,
  ),
  BankCatalogueItem(
    id: 'city_union',
    name: 'City Union Bank',
    shortName: 'City Union',
    senderCodes: ['CUBTXN', 'CIUBK'],
    tier: BankTier.midTier,
  ),
  BankCatalogueItem(
    id: 'karur_vysya',
    name: 'Karur Vysya Bank',
    shortName: 'KVB',
    senderCodes: ['KVBANK', 'KVBLTD'],
    tier: BankTier.midTier,
  ),
  BankCatalogueItem(
    id: 'karnataka',
    name: 'Karnataka Bank',
    shortName: 'Karnataka',
    senderCodes: ['KBLTXN', 'KARBNK'],
    tier: BankTier.midTier,
  ),
  BankCatalogueItem(
    id: 'jk_bank',
    name: 'Jammu & Kashmir Bank',
    shortName: 'J&K Bank',
    senderCodes: ['JKBANK', 'JKSMS'],
    tier: BankTier.midTier,
  ),
  BankCatalogueItem(
    id: 'dbs',
    name: 'DBS Bank India',
    shortName: 'DBS',
    senderCodes: ['DBSBNK', 'DBSTXN'],
    tier: BankTier.midTier,
  ),
  BankCatalogueItem(
    id: 'sc',
    name: 'Standard Chartered Bank',
    shortName: 'StanChart',
    senderCodes: ['SCBLTD', 'SCB'],
    tier: BankTier.midTier,
  ),
  BankCatalogueItem(
    id: 'hsbc',
    name: 'HSBC India',
    shortName: 'HSBC',
    senderCodes: ['HSBCIN', 'HSBC'],
    tier: BankTier.midTier,
  ),

  // --- Small Finance Banks ---
  BankCatalogueItem(
    id: 'au_sf',
    name: 'AU Small Finance Bank',
    shortName: 'AU Small Finance',
    senderCodes: ['AUBANK', 'AUSFB'],
    tier: BankTier.smallFinance,
  ),
  BankCatalogueItem(
    id: 'equitas_sf',
    name: 'Equitas Small Finance Bank',
    shortName: 'Equitas SFB',
    senderCodes: ['EQITAS', 'EQSFB'],
    tier: BankTier.smallFinance,
  ),
  BankCatalogueItem(
    id: 'ujjivan_sf',
    name: 'Ujjivan Small Finance Bank',
    shortName: 'Ujjivan SFB',
    senderCodes: ['UJJIVN', 'UJSFB'],
    tier: BankTier.smallFinance,
  ),
  BankCatalogueItem(
    id: 'jana_sf',
    name: 'Jana Small Finance Bank',
    shortName: 'Jana SFB',
    senderCodes: ['JANABK', 'JANASF'],
    tier: BankTier.smallFinance,
  ),
  BankCatalogueItem(
    id: 'capital_sf',
    name: 'Capital Small Finance Bank',
    shortName: 'Capital SFB',
    senderCodes: ['CAPSFB'],
    tier: BankTier.smallFinance,
  ),
  BankCatalogueItem(
    id: 'suryoday_sf',
    name: 'Suryoday Small Finance Bank',
    shortName: 'Suryoday SFB',
    senderCodes: ['SURSFB'],
    tier: BankTier.smallFinance,
  ),
  BankCatalogueItem(
    id: 'utkarsh_sf',
    name: 'Utkarsh Small Finance Bank',
    shortName: 'Utkarsh SFB',
    senderCodes: ['UTKSFB'],
    tier: BankTier.smallFinance,
  ),
  BankCatalogueItem(
    id: 'esaf_sf',
    name: 'ESAF Small Finance Bank',
    shortName: 'ESAF SFB',
    senderCodes: ['ESAFSF'],
    tier: BankTier.smallFinance,
  ),
  BankCatalogueItem(
    id: 'ne_sf',
    name: 'North East Small Finance Bank',
    shortName: 'North East SFB',
    senderCodes: ['NESFB'],
    tier: BankTier.smallFinance,
  ),
  BankCatalogueItem(
    id: 'shivalik_sf',
    name: 'Shivalik Small Finance Bank',
    shortName: 'Shivalik SFB',
    senderCodes: ['SHIVSF'],
    tier: BankTier.smallFinance,
  ),
];

class PaymentSource {
  const PaymentSource({
    required this.id,
    required this.type,
    this.bankName,
    this.bankIdentifier,
    this.nickname,
    this.accountNumberLast4,
    this.openingBalanceMinor = 0,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  final int id;
  final PaymentSourceType type;
  final String? bankName;
  final String? bankIdentifier;
  final String? nickname;
  final String? accountNumberLast4;
  final int openingBalanceMinor;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  bool get isWallet => type == PaymentSourceType.wallet;
  bool get isBank => type == PaymentSourceType.bank;

  /// Full descriptive title for account lists and selection.
  String get displayName {
    if (isWallet) {
      if (nickname != null && nickname!.trim().isNotEmpty) {
        return nickname!.trim();
      }
      return 'Cash Wallet';
    }
    final name = (bankName != null && bankName!.trim().isNotEmpty)
        ? bankName!.trim()
        : 'Bank Account';
    final suffix = (accountNumberLast4 != null && accountNumberLast4!.trim().isNotEmpty)
        ? ' (**${accountNumberLast4!.trim()})'
        : '';
    if (nickname != null && nickname!.trim().isNotEmpty) {
      return '${nickname!.trim()} ($name$suffix)';
    }
    return '$name$suffix';
  }

  /// Compact title for chips, tags, and summary rows.
  String get shortLabel {
    if (isWallet) {
      if (nickname != null && nickname!.trim().isNotEmpty) {
        return nickname!.trim();
      }
      return 'Cash Wallet';
    }
    if (nickname != null && nickname!.trim().isNotEmpty) {
      return nickname!.trim();
    }
    final name = bankName ?? 'Bank';
    final suffix = accountNumberLast4 != null ? ' **$accountNumberLast4' : '';
    return '$name$suffix';
  }

  PaymentSource copyWith({
    int? id,
    PaymentSourceType? type,
    String? bankName,
    String? bankIdentifier,
    String? nickname,
    String? accountNumberLast4,
    int? openingBalanceMinor,
    bool? isActive,
    DateTime? updatedAt,
  }) =>
      PaymentSource(
        id: id ?? this.id,
        type: type ?? this.type,
        bankName: bankName ?? this.bankName,
        bankIdentifier: bankIdentifier ?? this.bankIdentifier,
        nickname: nickname ?? this.nickname,
        accountNumberLast4: accountNumberLast4 ?? this.accountNumberLast4,
        openingBalanceMinor: openingBalanceMinor ?? this.openingBalanceMinor,
        isActive: isActive ?? this.isActive,
        createdAt: createdAt,
        updatedAt: updatedAt ?? DateTime.now(),
      );
}

BankCatalogueItem? findBankInCatalogue(String? query) {
  if (query == null || query.trim().isEmpty) return null;
  final clean = query.trim().toUpperCase();
  for (final item in indianBankCatalogue) {
    if (item.id.toUpperCase() == clean) return item;
    if (item.shortName.toUpperCase() == clean) return item;
    if (item.name.toUpperCase() == clean) return item;
    for (final code in item.senderCodes) {
      if (code == clean || clean.contains(code)) return item;
    }
  }
  return null;
}
