// import 'package:crm_flutter/api/dio_api.dart';
// import 'package:crm_flutter/api/response/all_leads_response.dart';
// import 'package:crm_flutter/pages/home/components/date_range_picker_dialog.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';

// class AllocationController extends GetxController {
//   // final DioApi api = Get.find<DioApi>();
//   RxList<Data> leads = <Data>[].obs;
//   RxBool isLoading = false.obs;
//   RxBool isMoreDataAvailable = true.obs;
//   int currentPage = 1;
//   RxString selectedTimeRange = 'Today'.obs;
//   Rx<DateTime?> selectedStartDate = Rx<DateTime?>(null);
//   Rx<DateTime?> selectedEndDate = Rx<DateTime?>(null);

//   Future<void> getAllLeads({
//     bool isInitial = false,
//     DateTime? startDate,
//     DateTime? endDate,
//   }) async {
//     if (isLoading.value) return;

//     // Use ever to ensure state updates happen properly
//     ever(isLoading, (_) {
//       update();
//     });

//     isLoading.value = true;

//     try {
//       if (isInitial) {
//         currentPage = 1;
//         leads.clear();
//         isMoreDataAvailable.value = true;
//       }

//       final response = await DioApi().getAllLeads(
//         page: currentPage,
//         startDate: startDate,
//         endDate: endDate,
//       );

//       if (response.success == true && response.data != null) {
//         if (response.data!.isEmpty) {
//           isMoreDataAvailable.value = false;
//         } else {
//           leads.addAll(response.data!);
//           currentPage++;
//         }
//       }
//     } catch (e) {
//       print("Error loading leads: $e");
//     } finally {
//       isLoading.value = false;
//     }
//   }

//   //
//   void selectTimeRange(String range, BuildContext context) async {
//     selectedTimeRange.value = range;

//     DateTime? startDate;
//     DateTime? endDate;

//     final now = DateTime.now();

//     switch (range) {
//       case 'Today':
//         startDate = DateTime(now.year, now.month, now.day);
//         endDate = now;
//         break;
//       case 'Yesterday':
//         final yesterday = now.subtract(Duration(days: 1));
//         startDate = DateTime(yesterday.year, yesterday.month, yesterday.day);
//         endDate = DateTime(
//           now.year,
//           now.month,
//           now.day,
//         ).subtract(Duration(seconds: 1));
//         break;
//       case 'Last 30 Days':
//         startDate = now.subtract(Duration(days: 30));
//         endDate = now;
//         break;
//       case 'Select Range':
//         final result = await showDialog(
//           context: context,
//           builder: (context) => DateRangePickerDialogg(
//             initialStartDate: selectedStartDate.value,
//             initialEndDate: selectedEndDate.value,
//           ),
//         );

//         if (result != null) {
//           selectedStartDate.value = result['startDate'];
//           selectedEndDate.value = result['endDate'];
//           startDate = selectedStartDate.value;
//           endDate = selectedEndDate.value;
//         } else {
//           return; // User cancelled
//         }
//         break;
//     }

//     // Fetch data with the selected date range
//     if (startDate != null && endDate != null) {
//       await getAllLeads(
//         isInitial: true,
//         startDate: startDate,
//         endDate: endDate,
//       );
//     }
//   }

//   //
// }
import 'package:crm_flutter/api/dio_api.dart';
import 'package:crm_flutter/api/response/all_leads_response.dart';
import 'package:crm_flutter/local_storage/up_coming_followups_controller.dart';
import 'package:crm_flutter/pages/home/components/date_range_picker_dialog.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AllocationController extends GetxController {
  // final DioApi api = Get.find<DioApi>();
  RxList<Data> leads = <Data>[].obs;
  RxBool isLoading = false.obs; // for first load
  RxBool isPaginationLoading = false.obs; // for next pages
  RxBool isMoreDataAvailable = true.obs;
  int currentPage = 1;
  RxString selectedTimeRange = 'Today'.obs;
  Rx<DateTime?> selectedStartDate = Rx<DateTime?>(null);
  Rx<DateTime?> selectedEndDate = Rx<DateTime?>(null);

  DateTime? filterStartDate;
  DateTime? filterEndDate;

  // Future<void> getAllLeads({
  //   bool isInitial = false,
  //   DateTime? startDate,
  //   DateTime? endDate,
  // }) async {
  //   if (!isMoreDataAvailable.value) return;
  //   if (isLoading.value) return;

  //   isLoading.value = true;

  //   try {
  //     if (isInitial) {
  //       currentPage = 1;
  //       leads.clear();
  //       isMoreDataAvailable.value = true;
  //     }

  //     await Get.find<FollowUpController>().syncWithApi();

  //     await Future.delayed(Duration(milliseconds: 10));

  //     final response = await DioApi().getAllLeads(
  //       page: currentPage,
  //       startDate: startDate,
  //       endDate: endDate,
  //     );

  //     if (response.success == true) {
  //       // Safely handle the data
  //       isLoading.value = false;
  //       final List<Data>? responseData = response.data;

  //       if (responseData == null || responseData.isEmpty) {
  //         isMoreDataAvailable.value = false;
  //       } else {
  //         leads.addAll(responseData);
  //         currentPage++;
  //       }
  //     }
  //   } catch (e) {
  //     print("Error loading leads: $e");
  //   } finally {
  //     isLoading.value = false;
  //   }
  // }
  Future<void> getAllLeads({
    bool isInitial = false,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    // if (isLoading.value) return;

    // isLoading.value = true;
    if (isInitial) {
      if (isLoading.value) return;
      isLoading.value = true;
    } else {
      if (isPaginationLoading.value || !isMoreDataAvailable.value) return;
      isPaginationLoading.value = true;
    }

    try {
      if (isInitial) {
        currentPage = 1;
        leads.clear();
        isMoreDataAvailable.value = true;

        /// SAVE FILTERS HERE
        filterStartDate = startDate;
        filterEndDate = endDate;
      }

      await Get.find<FollowUpController>().syncWithApi();

      await Future.delayed(Duration(milliseconds: 10));

      final response = await DioApi().getAllLeads(
        page: currentPage,

        ///  ALWAYS USE STORED VALUES
        startDate: filterStartDate,
        endDate: filterEndDate,
      );

      if (response.success == true) {
        final List<Data>? responseData = response.data;

        if (responseData == null || responseData.isEmpty) {
          isMoreDataAvailable.value = false;
        } else {
          leads.addAll(responseData); // append, not replace
          currentPage++;
        }
      }
    } catch (e) {
      print("Error loading leads: $e");
    } finally {
      isLoading.value = false;
      isPaginationLoading.value = false;
    }
  }

  void selectTimeRange(String range, BuildContext context) async {
    selectedTimeRange.value = range;

    DateTime? startDate;
    DateTime? endDate;

    final now = DateTime.now();

    switch (range) {
      case 'Today':
        startDate = DateTime(now.year, now.month, now.day);
        endDate = now;
        break;
      case 'Yesterday':
        final yesterday = now.subtract(const Duration(days: 1));
        startDate = DateTime(yesterday.year, yesterday.month, yesterday.day);
        endDate = DateTime(
          now.year,
          now.month,
          now.day,
        ).subtract(const Duration(seconds: 1));
        break;
      case 'Last 30 Days':
        startDate = now.subtract(const Duration(days: 30));
        endDate = now;
        break;
      case 'Select Range':
        final result = await showDialog(
          context: context,
          builder: (context) => DateRangePickerDialogg(
            initialStartDate: selectedStartDate.value,
            initialEndDate: selectedEndDate.value,
          ),
        );

        if (result != null) {
          selectedStartDate.value = result['startDate'];
          selectedEndDate.value = result['endDate'];
          startDate = selectedStartDate.value;
          endDate = selectedEndDate.value;
        } else {
          return; // User cancelled
        }
        break;
    }

    // Fetch data with the selected date range
    if (startDate != null && endDate != null) {
      await getAllLeads(
        isInitial: true,
        startDate: startDate,
        endDate: endDate,
      );
    }
  }
}
