import 'dart:convert';
import 'package:http/http.dart' as http;

class PhonePeApi {
  static Future<Map<String, dynamic>> createOrder({
    required int amountPaise,
    required String merchantUserId,
    required String callbackUrl,
  }) async {
    final uri = Uri.parse('https://<yourCloudFnUrl>/phonepeCreateOrder');
    final res = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'amount': amountPaise,
        'merchantUserId': merchantUserId,
        'callbackUrl': callbackUrl,
      }),
    );
    if (res.statusCode != 200) {
      throw Exception('Create order failed: ${res.body}');
    }
    return jsonDecode(res.body);
  }
}
