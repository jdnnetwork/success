import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

/// Opens the platform phone app pre-filled with a number. By contract it
/// NEVER places a call — on Android `tel:` resolves to ACTION_DIAL, which
/// only shows the dialer; the user must press call themselves.
abstract interface class PhoneDialer {
  Future<void> openDialer(String number);
}

class UrlLauncherPhoneDialer implements PhoneDialer {
  const UrlLauncherPhoneDialer();

  @override
  Future<void> openDialer(String number) async {
    final uri = Uri(scheme: 'tel', path: number);
    await launchUrl(uri);
  }
}

final phoneDialerProvider = Provider<PhoneDialer>(
  (ref) => const UrlLauncherPhoneDialer(),
);
