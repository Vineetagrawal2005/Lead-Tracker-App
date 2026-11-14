/// Helper to launch the phone dialer using [url_launcher].
///
/// The AndroidManifest.xml must declare a `<queries>` entry for the `tel`
/// scheme (see section 9 of the assignment) so package visibility allows
/// launching the dialer on Android 11+.
///
/// A WhatsApp button could be added later here using `https://wa.me/<number>`.
library;

import 'package:url_launcher/url_launcher.dart';

class LauncherHelper {
  LauncherHelper._();

  /// Opens the device dialer with [phone] pre-filled. Returns true if the
  /// URL could be launched.
  static Future<bool> call(String phone) async {
    final digits = phone.replaceAll(RegExp(r'[^0-9]'), '');
    // Prefix with India country code for a 10-digit mobile number.
    final formatted = digits.length == 10 ? '91$digits' : digits;
    final uri = Uri(scheme: 'tel', path: '+$formatted');
    if (await canLaunchUrl(uri)) {
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
    return false;
  }
}
