import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app/features/launcher/data/phone_dialer.dart';
import 'package:app/features/launcher/presentation/sos_screen.dart';

class FakePhoneDialer implements PhoneDialer {
  final List<String> opened = [];
  @override
  Future<void> openDialer(String number) async => opened.add(number);
}

void main() {
  testWidgets('SOS shows 119/112/보호자 and dials 119 without auto-calling', (
    tester,
  ) async {
    final dialer = FakePhoneDialer();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [phoneDialerProvider.overrideWithValue(dialer)],
        child: const MaterialApp(home: SosScreen()),
      ),
    );

    expect(find.text('119'), findsOneWidget);
    expect(find.text('112'), findsOneWidget);
    expect(find.text('보호자'), findsOneWidget);

    await tester.tap(find.text('119'));
    await tester.pumpAndSettle();

    // Only the dialer was opened; nothing places a call.
    expect(dialer.opened, ['119']);
  });
}
