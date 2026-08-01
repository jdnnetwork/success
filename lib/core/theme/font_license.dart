import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Makes the bundled font's licence part of the app's licence page.
///
/// Noto Sans KR is under the SIL Open Font License, which requires the licence
/// to accompany the font wherever it is redistributed — an APK counts. Flutter
/// collects the licences of *packages* automatically; a font dropped into
/// `assets/` is invisible to it, so this hands it over.
void registerFontLicense() {
  LicenseRegistry.addLicense(() async* {
    final text = await rootBundle.loadString('assets/fonts/OFL.txt');
    yield LicenseEntryWithLineBreaks(const ['Noto Sans KR'], text);
  });
}
