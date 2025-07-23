import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../services/phonepe_api.dart';
import '../../services/phonepe_service.dart';

class PhonePePaymentScreen extends StatefulWidget {
  final String propertyId;
  const PhonePePaymentScreen({super.key, required this.propertyId});

  @override
  State<PhonePePaymentScreen> createState() => _PhonePePaymentScreenState();
}

class _PhonePePaymentScreenState extends State<PhonePePaymentScreen> {
  bool _loading = false;
  String _result = '';

  Future<void> _pay() async {
    setState(() => _loading = true);

    try {
      // 1. Create order in backend
      final orderResp = await PhonePeApi.createOrder(
        amountPaise: 3000 * 100,
        merchantUserId: widget.propertyId, // or user uid
        callbackUrl: 'https://yourdomain.com/phonepe/webhook', // or whatever
      );

      final payload = {
        "orderId": orderResp["data"]["merchantTransactionId"] ??
            orderResp["data"]["orderId"],
        "merchantId": orderResp["data"]["merchantId"],
        "token": orderResp["data"]["instrumentResponse"]["redirectInfo"]
                ["urlToken"] ??
            orderResp["data"]["token"],
        "paymentMode": {"type": "PAY_PAGE"}
      };

      // 2. init SDK (only once – you can move this to app init)
      await PhonePeService.init(
        prod: kReleaseMode,
        merchantId: orderResp["data"]["merchantId"],
        flowId: widget.propertyId,
        enableLogs: !kReleaseMode,
      );

      // 3. Start transaction
      final res = await PhonePeService.startTxn(
        payload: payload,
        iosScheme: 'rentloapp', // your iOS scheme; '' on Android is fine
      );

      if (res == null) {
        _result = 'Flow Incomplete';
      } else {
        final status = res['status'];
        final error = res['error'];
        _result = 'Status: $status, Error: $error';
        // TODO: if status != SUCCESS, maybe show retry
        // If SUCCESS → verify from backend (poll or wait for webhook), then mark property as active
      }
    } catch (e) {
      _result = 'Payment failed: $e';
    }

    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Payment ₹3000')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text('List Fee: ₹3000'),
            const SizedBox(height: 20),
            if (_loading) const CircularProgressIndicator(),
            if (!_loading)
              ElevatedButton(
                onPressed: _pay,
                child: const Text('Pay with PhonePe'),
              ),
            const SizedBox(height: 20),
            Text(_result, style: const TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
