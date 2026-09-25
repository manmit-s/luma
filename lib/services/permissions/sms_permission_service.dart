import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

enum SmsPermissionState {
  granted,
  denied,
  permanentlyDenied,
  restricted,
  unavailable,
}

class SmsPermissionService {
  Future<SmsPermissionState> status() async {
    try {
      final status = await Permission.sms.status;
      return _map(status);
    } on MissingPluginException {
      return SmsPermissionState.unavailable;
    } catch (_) {
      return SmsPermissionState.unavailable;
    }
  }

  Future<SmsPermissionState> request() async {
    try {
      final status = await Permission.sms.request();
      return _map(status);
    } on MissingPluginException {
      return SmsPermissionState.unavailable;
    } catch (_) {
      return SmsPermissionState.restricted;
    }
  }

  Future<void> openSettings() async {
    try {
      await openAppSettings();
    } catch (_) {
      // Best effort only.
    }
  }

  SmsPermissionState _map(PermissionStatus status) {
    if (status.isGranted) return SmsPermissionState.granted;
    if (status.isPermanentlyDenied) {
      return SmsPermissionState.permanentlyDenied;
    }
    if (status.isRestricted) return SmsPermissionState.restricted;
    if (status.isLimited) return SmsPermissionState.granted;
    return SmsPermissionState.denied;
  }
}
