class PendingCallData {
  static Map<String, dynamic>? data;
  static String? outboundSessionId;

  static void clear() {
    data = null;
    outboundSessionId = null;
  }
}
