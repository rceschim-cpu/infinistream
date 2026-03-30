import 'package:url_launcher/url_launcher.dart';
import '../constants/streaming_constants.dart';

class DeepLinkService {
  static Future<bool> openUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      return launchUrl(uri, mode: LaunchMode.externalApplication);
    }
    return false;
  }

  static Future<void> watchTitle(
      String providerName, String titleName) async {
    final info = StreamingConstants.getInfo(providerName);
    if (info == null) return;
    await openUrl(info.searchForTitle(titleName));
  }

  static Future<void> openSignup(String providerName) async {
    final info = StreamingConstants.getInfo(providerName);
    if (info == null) return;
    await openUrl(info.signupUrl);
  }

  static Future<void> openCancellation(String providerName) async {
    final info = StreamingConstants.getInfo(providerName);
    if (info == null) return;
    await openUrl(info.cancelUrl);
  }
}
