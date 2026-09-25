import 'dart:convert';

import 'package:crypto/crypto.dart';

String smsFingerprint(String message) {
  final normalized = message.toLowerCase().replaceAll(RegExp(r'\s+'), ' ').trim();
  return sha256.convert(utf8.encode(normalized)).toString();
}
