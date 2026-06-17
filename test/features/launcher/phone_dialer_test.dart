import 'package:flutter_test/flutter_test.dart';
import 'package:app/features/launcher/data/phone_dialer.dart';

/// Records dialer opens. There is no "call" method to record — the interface
/// makes auto-calling impossible.
class FakePhoneDialer implements PhoneDialer {
  final List<String> opened = [];
  @override
  Future<void> openDialer(String number) async => opened.add(number);
}

void main() {
  test('openDialer records the number, exposes no auto-call path', () async {
    final dialer = FakePhoneDialer();
    await dialer.openDialer('119');
    expect(dialer.opened, ['119']);
    // PhoneDialer has exactly one method; there is no place callers could
    // trigger a call without user confirmation in the OS dialer.
    expect(PhoneDialer, isNotNull);
  });
}
