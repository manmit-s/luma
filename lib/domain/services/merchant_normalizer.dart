class MerchantNormalizer {
  String normalize(String? merchant) {
    if (merchant == null || merchant.trim().isEmpty) return '';
    return merchant
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9 ]'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }
}
