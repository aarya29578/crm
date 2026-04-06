import 'dart:convert';
import 'package:crm_flutter/api/response/all_follow_up_response.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FollowUpStorage {
  static const String key = "followups";

  /// SAVE
  static Future<void> save(List<FollowUpData> list) async {
    final prefs = await SharedPreferences.getInstance();

    final jsonList = list.map((e) => e.toJson()).toList();

    prefs.setString(key, jsonEncode(jsonList));
  }

  /// GET
  static Future<List<FollowUpData>> get() async {
    final prefs = await SharedPreferences.getInstance();

    final data = prefs.getString(key);
    if (data == null) return [];

    final decoded = jsonDecode(data) as List;

    return decoded.map((e) => FollowUpData.fromJson(e)).toList();
  }

  /// CLEAR
  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.remove(key);
  }
}
