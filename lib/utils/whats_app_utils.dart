import 'package:url_launcher/url_launcher.dart';

class WhatsAppUtils {
  static Future<void> launchWhatsApp(String message, String phoneNumber) async {
    final uri = Uri.parse('https://wa.me/$phoneNumber?text=${Uri.encodeComponent(message)}');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      throw 'Could not launch WhatsApp';
    }
  }
}
