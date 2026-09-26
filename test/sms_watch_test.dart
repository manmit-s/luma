import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:luma/main.dart';

/// Proves the SMS watch chain end-to-end (with a mocked native queue):
/// receiver queue → drain on launch → pending expense → resume re-drain
/// without duplicating (fingerprint guard).
void main() {
  const smsChannel = MethodChannel('luma/sms');
  const queuedSms =
      'Your A/C XX1234 debited by Rs.200.90 at Uber. UPI Ref 999888777';

  testWidgets('queued SMS becomes pending on launch, resume dedupes', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(smsChannel, (call) async {
      if (call.method == 'drainSmsQueue') return <String>[queuedSms];
      return null;
    });
    addTearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(smsChannel, null);
    });

    await tester.pumpWidget(const ProviderScope(child: LumaApp()));
    await tester.pumpAndSettle();

    // Seed has 1 pending (Uber); the queued SMS adds a second.
    expect(find.text('2 pending'), findsOneWidget);
    expect(find.text('Unknown merchant'), findsWidgets);
    expect(tester.takeException(), isNull);

    // Re-drain on resume must not duplicate (same fingerprint).
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pumpAndSettle();
    expect(find.text('2 pending'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
