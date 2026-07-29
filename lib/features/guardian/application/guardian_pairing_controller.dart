import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/supabase/supabase_providers.dart';
import '../../../domain/pair_link.dart';
import 'guardian_home_apps_controller.dart';
import 'guardian_session_controller.dart';

/// The application id the install link points at.
///
/// Still the Flutter template's default. It has to change before anything is
/// published — Play refuses `com.example.*`, and the id can never be changed
/// once a listing exists — so it lives here rather than being spelled out at
/// each call site.
const applicationId = 'com.example.app';

/// Everyone looking after the selected parent.
final guardiansForSelectedProvider = FutureProvider<List<GuardianLink>>((
  ref,
) async {
  final profile = ref.watch(selectedSeniorProfileProvider);
  if (profile == null) return const [];
  return ref.watch(pairingRepositoryProvider).guardiansFor(profile.id);
});

/// The guardian half of Phase 5: issuing codes and typing the one their parent
/// read out.
class GuardianPairingController extends Notifier<void> {
  @override
  void build() {}

  /// 경로 A. Creates the parent and the invite, then hands the message to the
  /// SMS app.
  ///
  /// Returns the link so the caller can show the code too. It deliberately
  /// does not report whether the message was sent, because the app cannot know
  /// — opening the messaging app is as far as `07_PHASE_PLAN` allows, and the
  /// same rule as SOS applies: never claim an action the user still has to
  /// take themselves.
  Future<PairLink> inviteSenior({
    required String displayName,
    String? phoneNumber,
  }) async {
    final link = await ref
        .read(pairingRepositoryProvider)
        .createSeniorInvite(displayName: displayName);
    ref.invalidate(linkedSeniorProfilesProvider);

    // Not awaited. The invite exists whether or not the messaging app opens,
    // and the app cannot see what happens there anyway — so holding the
    // guardian on a spinner until another app answers would make them wait for
    // a result that is never coming.
    unawaited(
      _openMessagingApp(
        phoneNumber: phoneNumber,
        body: link.installMessage(
          seniorName: displayName,
          applicationId: applicationId,
        ),
      ),
    );
    return link;
  }

  /// 경로 B. The number the parent read out, plus the two things it could not
  /// carry.
  Future<void> claimCode({
    required String code,
    required String displayName,
    String? phoneNumber,
  }) async {
    await ref
        .read(pairingRepositoryProvider)
        .claimSeniorPairingCode(
          code: code,
          displayName: displayName,
          phoneNumber: phoneNumber,
        );
    ref.invalidate(linkedSeniorProfilesProvider);
  }

  Future<PairLink> createRecoveryCode(String seniorProfileId) =>
      ref.read(pairingRepositoryProvider).createRecoveryCode(seniorProfileId);

  Future<PairLink> createFamilyInvite(String seniorProfileId) =>
      ref.read(pairingRepositoryProvider).createFamilyInvite(seniorProfileId);

  Future<void> redeemFamilyInvite(String code) async {
    await ref.read(pairingRepositoryProvider).redeemFamilyInvite(code);
    ref.invalidate(linkedSeniorProfilesProvider);
  }

  Future<void> requestPrimary(String seniorProfileId) async {
    await ref
        .read(pairingRepositoryProvider)
        .requestPrimaryGuardian(seniorProfileId);
    ref.invalidate(guardiansForSelectedProvider);
  }

  /// Opens the messaging app with the body filled in. A missing number is
  /// fine — the guardian picks the recipient there.
  Future<void> _openMessagingApp({
    String? phoneNumber,
    required String body,
  }) async {
    final uri = Uri(
      scheme: 'sms',
      path: phoneNumber?.replaceAll(RegExp(r'[^0-9+]'), '') ?? '',
      queryParameters: {'body': body},
    );
    try {
      await launchUrl(uri);
    } on Object {
      // The invite still exists and the code still works; the guardian can
      // read it out instead. Failing the whole flow over the messaging app
      // would throw away a perfectly good invite.
    }
  }
}

final guardianPairingControllerProvider =
    NotifierProvider<GuardianPairingController, void>(
      GuardianPairingController.new,
    );
