import 'dart:async';

import 'package:crm_flutter/api/dio_api.dart';
import 'package:crm_flutter/api/response/all_follow_up_response.dart';
import 'package:crm_flutter/common_widgets/notificationService.dart';
import 'package:crm_flutter/helper/call_helper.dart';
import 'package:crm_flutter/local_storage/local_storage.dart';
import 'package:crm_flutter/local_storage/up_coming_followups_storage_service.dart';
import 'package:crm_flutter/pages/bottom_navigation_bar/LeadDetailsBottomNavigationBarPage.dart';
import 'package:crm_flutter/widgets/show_call_alert_dialog.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FollowUpController extends GetxController {
  final DioApi _dioApi = Get.find<DioApi>();
  final NotificationService _notificationService =
      Get.find<NotificationService>();

  List<FollowUpData> localList = [];
  final List<Timer> timers = [];

  @override
  void onInit() {
    super.onInit();
    init();
  }

  Future<void> init() async {
    // 🔹 Load stored data first
    localList = await FollowUpStorage.get();

    _removeExpired(localList);
    _schedule(localList);

    // 🔹 Fetch fresh data
    await syncWithApi();
  }

  Future<void> syncWithApi() async {
    final apiList = await _dioApi.fetchTodayFollowUps();

    _removeExpired(apiList);

    // 🔥 NEW STEP
    _removeDeletedFromApi(apiList);

    // 🔄 THEN merge
    Map<String, FollowUpData> map = {};

    for (var item in localList) {
      if (item.id != null) map[item.id!] = item;
    }

    for (var item in apiList) {
      if (item.id != null) map[item.id!] = item;
    }

    localList = map.values.toList();

    await FollowUpStorage.save(localList);

    _clearTimers();
    _schedule(localList);
  }

  void _removeExpired(List<FollowUpData> list) {
    final now = DateTime.now();

    list.removeWhere((item) {
      if (item.followUpDate == null) return true;

      final time = DateTime.tryParse(item.followUpDate!);
      if (time == null) return true;

      return time.isBefore(now);
    });
  }

  void _schedule(List<FollowUpData> list) {
    for (var item in list) {
      if (item.followUpDate == null) continue;

      final time = DateTime.parse(item.followUpDate!).toLocal();

      // 🔔 schedule system notification
      _notificationService.scheduleNotification(
        id: item.id.hashCode,
        title: "Follow-up Reminder",
        body: "${item.name?.first ?? ''} needs follow-up",
        scheduledDate: time,
      );

      // 🔥 ALSO trigger dialog (if app is open)
      final delay = time.difference(DateTime.now());

      if (!delay.isNegative) {
        timers.add(
          Timer(delay, () async {
            // 🔒 SAFETY NET: skip entirely if user has logged out.
            // Handles the case where logout() runs at the same moment
            // this timer fires, before stop() gets a chance to cancel it.
            final token = LocalStorage.sharedPreferences?.getString('token');
            if (token == null || token.isEmpty) {
              return;
            }

            // 🔥 1. CANCEL scheduled notification
            await NotificationService.cancelNotification(item.id.hashCode);

            // 🔥 2. Show popup
            triggerDialog([item]);

            // 🔔 3. Show instant notification
            _notificationService.showNotification(
              id: item.id.hashCode,
              title: "Follow-up Reminder",
              body: "${item.name?.first ?? ''} needs follow-up",
            );
          }),
        );
      }
    }
  }

  void _clearTimers() {
    for (var t in timers) {
      t.cancel();
    }
    timers.clear();
  }

  Future<void> stop() async {
    _clearTimers();
    localList.clear();
    await FollowUpStorage.save(localList);
  }

  void _removeDeletedFromApi(List<FollowUpData> apiList) {
    final now = DateTime.now();

    // Create API ID set
    final apiIds = apiList.map((e) => e.id).toSet();

    localList.removeWhere((localItem) {
      if (localItem.id == null) return true;

      // ✅ If exists in API → keep
      if (apiIds.contains(localItem.id)) return false;

      final time = DateTime.tryParse(localItem.followUpDate ?? "");
      if (time == null) return true;

      final diff = time.difference(now);

      // ⏰ BUFFER: keep if within 30 seconds
      if (diff.inSeconds.abs() <= 30) {
        print("⏳ Keeping near-time item: ${localItem.id}");
        return false;
      }

      // ❌ Otherwise remove
      print("❌ Removing deleted follow-up: ${localItem.id}");

      // 🔥 Cancel notification also
      NotificationService.cancelNotification(localItem.id.hashCode);

      return true;
    });
  }

  void triggerDialog(List<FollowUpData> list) {
    if (list.isEmpty) return;

    Get.dialog(
      StatefulBuilder(
        builder: (context, setState) {
          List<FollowUpData> tempList = List.from(list);

          return AlertDialog(
            title: const Text("Follow-ups"),
            content: SizedBox(
              width: double.maxFinite,
              height: Get.height * 0.4,
              child: tempList.isEmpty
                  ? const Center(child: Text("No follow-ups!"))
                  : ListView.builder(
                      itemCount: tempList.length,
                      itemBuilder: (context, index) {
                        final item = tempList[index];

                        final name =
                            "${item.name?.first ?? ''} ${item.name?.last ?? ''}";
                        final phone = item.phone?.toString() ?? "No phone";

                        return GestureDetector(
                          onTap: () {
                            Get.to(
                              LeadDetailsBottomNavigationBarPage(
                                LeadID: item.id ?? '',
                              ),
                            );
                          },
                          child: Container(
                            margin: const EdgeInsets.symmetric(vertical: 6),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.person),

                                const SizedBox(width: 10),

                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(name.isEmpty ? "No Name" : name),
                                      Text(phone),
                                    ],
                                  ),
                                ),

                                ElevatedButton(
                                  onPressed: () async {
                                    showCallAlertDialog(
                                      context,
                                      'Call $name',
                                      'Are you sure want to call $phone?',
                                      () async {
                                        await CallHelper.callAndTrack(
                                          phone.toString(),
                                          item.id,
                                          '',
                                        );

                                        // REMOVE ITEM AFTER CALL
                                        setState(() {
                                          tempList.removeAt(index);
                                        });

                                        // optional: close dialog if empty
                                        if (tempList.isEmpty) {
                                          Get.back();
                                        }

                                        /// VERY IMPORTANT
                                        await syncWithApi();
                                      },
                                      Colors.blue,
                                    );
                                  },
                                  child: const Icon(Icons.phone),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          );
        },
      ),
    );
  }
}
