import 'dart:convert';
import 'package:phonepe_payment_sdk/phonepe_payment_sdk.dart';

class PhonePeService {
  static Future<void> init({
    required bool prod,
    required String merchantId,
    required String flowId,
    bool enableLogs = false,
  }) async {
    await PhonePePaymentSdk.init(
      prod ? 'PRODUCTION' : 'SANDBOX',
      merchantId,
      flowId,
      enableLogs,
    );
  }

  static Future<Map?> startTxn({
    required Map<String, dynamic> payload,
    String iosScheme = '',
  }) async {
    final req = jsonEncode(payload);
    return PhonePePaymentSdk.startTransaction(req, iosScheme);
  }
}
