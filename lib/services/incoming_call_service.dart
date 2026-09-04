import 'package:flutter/services.dart';
import 'package:crm_flutter/api/dio_api.dart';

class IncomingCallService {
  static const MethodChannel _channel = MethodChannel(
    'com.example.crm_flutter/call',
  );

  static final DioApi _dioApi = DioApi();

  static void initialize() {
    print("🔥 IncomingCallService initialized");

    _channel.setMethodCallHandler((call) async {
      print("🔥 MethodChannel event received: ${call.method}");
      print("🔥 Arguments: ${call.arguments}");

      if (call.method == 'incomingCallEnded') {
        try {
          final data = Map<String, dynamic>.from(call.arguments);

          print("📞 Incoming call received from Android");
          print(data);

          final payload = {
            "calls": [data],
          };

          print("🚀 ABOUT TO HIT API");
          print("🚀 Payload: $payload");

          final response = await _dioApi.syncIncomingCall(payload);

          print("✅ API RESPONSE: $response");
        } catch (e, stackTrace) {
          print("❌ Incoming call processing failed: $e");
          print(stackTrace);
        }
      }
    });
  }
}
