import 'package:url_launcher/url_launcher.dart';

class WhatsAppUtils {
  static Future<void> launchWhatsApp(String message, String phoneNumber) async {
    final Uri whatsappUrl = Uri.parse('https://wa.me/$phoneNumber?text=${Uri.encodeComponent(message)}');
    if (await canLaunchUrl(whatsappUrl)) {
      await launchUrl(whatsappUrl, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch $whatsappUrl';
    }
  }
}
