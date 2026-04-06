import 'dart:io';
import 'package:crm_flutter/api/dio_api.dart';
import 'package:crm_flutter/api/response/all_lead_details_response.dart';
import 'package:crm_flutter/api/response/all_leads_response.dart';
import 'package:crm_flutter/local_storage/local_storage.dart';
import 'package:crm_flutter/models/enums.dart';
import 'package:crm_flutter/pages/Allocations/WhatsappSMS/whatsapp_sms_controller.dart';
import 'package:crm_flutter/pages/lead_details/LeadDetailsController.dart';
import 'package:crm_flutter/widgets/poppups/poppups.dart';
import 'package:dio/dio.dart';
import 'package:external_path/external_path.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:velocity_x/velocity_x.dart';

class CallLogCard extends StatelessWidget {
  final context;
  final bool? isMissedFUps;
  final List<Timeline>? timelineData;
  final String name;
  final String? leadId;
  final String? campaignId;
  final String? campaign;
  final String tag;
  final AssignedTo? assignedTo;
  final VoidCallback? accept;
  final VoidCallback? decline;
  final DateTime? followUp;
  final String time;
  final int? phone;
  // final bool isMissedCall;
  final VoidCallback? onCallBack;

  CallLogCard({
    Key? key,
    this.context,
    this.isMissedFUps = false,
    this.timelineData,
    required this.name,
    this.leadId,
    this.campaignId,
    this.campaign,
    required this.tag,
    this.assignedTo,
    this.accept,
    this.decline,
    this.followUp,
    this.time = "no time found",
    this.phone,
    // this.isMissedCall = false,
    this.onCallBack,
  }) : super(key: key);

  final Leaddetailscontroller leadDetailsController = Get.put(
    Leaddetailscontroller(),
  );
  final WhatsappSmsController _whatsappSmsController =
      Get.find<WhatsappSmsController>();
  RxList<PlatformFile> selectedFiles = <PlatformFile>[].obs;
  RxList<String> removedFiles = <String>[].obs;

  void openBottomSheet(
    BuildContext context,
    List<Timeline>? data,
    leadID,
  ) async {
    selectedFiles.clear();
    removedFiles.clear();
    await leadDetailsController.getAllLeadDetails(context, leadID);

    // RxList documents = <dynamic>[].obs;
    RxList<Document> documents = <Document>[].obs;

    RxBool isDocumentExist = false.obs;
    // RxList<PlatformFile> selectedFiles = <PlatformFile>[].obs;

    // final getResponse =
    //     leadDetailsController.allLeadDetailRes.value.data?.documents;

    // documents.value = getResponse ?? [];
    // documents.assignAll(getResponse ?? []);
    // documents.assignAll(
    //   leadDetailsController.allLeadDetailRes.value.data?.documents ?? [],
    // );
    documents.value = List<Document>.from(
      leadDetailsController.allLeadDetailRes.value.data?.documents ?? [],
    );

    final originalDocuments = List<Document>.from(documents);

    // List documents = List.from(
    //   leadDetailsController.allLeadDetailRes.value.data?.documents ?? [],
    // );
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final String isoTime = time;
    final dateTime = DateTime.parse(isoTime).toLocal();
    final formattedTime = DateFormat('hh:mm a, dd MMM').format(dateTime);

    showModalBottomSheet(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 1.0,
          minChildSize: 0.7,
          maxChildSize: 1.0,
          expand: true,

          builder: (context, scrollController) {
            return RefreshIndicator(
              onRefresh: () async {
                await Future.delayed(Duration(seconds: 1));
                await leadDetailsController.getAllLeadDetails(context, leadID);

                // documents.assignAll(
                //   leadDetailsController
                //           .allLeadDetailRes
                //           .value
                //           .data
                //           ?.documents ??
                //       [],
                // );
                documents.value = List<Document>.from(
                  leadDetailsController
                          .allLeadDetailRes
                          .value
                          .data
                          ?.documents ??
                      [],
                );
                documents.refresh();
              },
              child: Container(
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[900] : Colors.white,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                ),
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: MediaQuery.of(context).size.height,
                    ),
                    child: Column(
                      children: [
                        const SizedBox(height: 10),

                        /// drag handle
                        Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),

                        // const SizedBox(height: 20),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: const Text('Cancel'),
                              ),
                            ],
                          ),
                        ),
                        // const SizedBox(height: 20),

                        /// Name
                        Text(
                          name,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        if (phone != null)
                          Text(
                            phone.toString(),
                            style: TextStyle(
                              fontSize: 15,
                              color: isDark
                                  ? Colors.grey[400]
                                  : Colors.grey[700],
                              fontWeight: FontWeight.w400,
                            ),
                          ),

                        const SizedBox(height: 14),

                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                          child: InkWell(
                            focusColor: Colors.grey,
                            splashColor: Colors.grey,
                            borderRadius: BorderRadius.circular(10),
                            onTap: () => uploadFile(context),
                            /**
                             * {
  "status": "fail",
  "error": {
    "statusCode": 403,
    "status": "fail",
    "errorCode": null,
    "isOperational": true
  },
  "message": "Permission denied",
  "stack": "Error: Permission denied\n    at /opt/crm_backend/middleware/permissionMiddleware.js:29:21\n    at process.processTicksAndRejections (node:internal/process/task_queues:105:5)"
}
                             */
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Text("Click to upload your documents - "),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.link,
                                      size: 14,
                                      color: Colors.blue,
                                    ),
                                    const SizedBox(width: 5),
                                    Text(
                                      "Select Files",
                                      style: TextStyle(color: Colors.blue),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Obx(() {
                          if (selectedFiles.isEmpty) return const SizedBox();

                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 10),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      "Selected Files",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),

                                    if (selectedFiles.isNotEmpty)
                                      Row(
                                        children: [
                                          TextButton(
                                            onPressed: () {
                                              selectedFiles.clear();
                                            },
                                            child: const Text("Cancel"),
                                          ),

                                          ElevatedButton(
                                            onPressed: () async {
                                              List<String> paths = [];

                                              for (var file in selectedFiles) {
                                                if (file.path != null) {
                                                  paths.add(file.path!);
                                                }
                                              }

                                              await DioApi()
                                                  .patchAllLeadDetails(
                                                    leadId!,
                                                    paths,
                                                    removedFiles,
                                                  );

                                              /// refresh api
                                              await leadDetailsController
                                                  .getAllLeadDetails(
                                                    context,
                                                    leadId,
                                                  );

                                              /// update local documents list
                                              // documents.assignAll(
                                              //   leadDetailsController
                                              //           .allLeadDetailRes
                                              //           .value
                                              //           .data
                                              //           ?.documents ??
                                              //       [],
                                              // );
                                              isDocumentExist.value = true;
                                              documents.value =
                                                  List<Document>.from(
                                                    leadDetailsController
                                                            .allLeadDetailRes
                                                            .value
                                                            .data
                                                            ?.documents ??
                                                        [],
                                                  );

                                              selectedFiles.clear();
                                              removedFiles.clear();
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                const SnackBar(
                                                  content: Text(
                                                    "Files uploaded successfully",
                                                  ),
                                                  behavior:
                                                      SnackBarBehavior.floating,
                                                ),
                                              );
                                            },
                                            child: Text(
                                              removedFiles.isNotEmpty
                                                  ? "Update"
                                                  : 'Upload',
                                            ),
                                          ),
                                        ],
                                      ),
                                  ],
                                ),

                                ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: selectedFiles.length,
                                  itemBuilder: (context, index) {
                                    final file = selectedFiles[index];

                                    return ListTile(
                                      leading: const Icon(
                                        Icons.insert_drive_file,
                                      ),
                                      title: Text(
                                        file.name,
                                        style: TextStyle(fontSize: 13),
                                      ),
                                      trailing: IconButton(
                                        icon: const Icon(
                                          Icons.close,
                                          color: Colors.red,
                                        ),
                                        onPressed: () {
                                          selectedFiles.removeAt(index);
                                        },
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          );
                        }),

                        // if (removedFiles.isNotEmpty ||
                        //     documents.isNotEmpty ||
                        //     isDocumentExist.value == true) ...[
                        //   const SizedBox(height: 15),
                        Obx(() {
                          if (removedFiles.isEmpty && documents.isEmpty) {
                            return const SizedBox();
                          }
                          print('removedfiles$removedFiles');
                          return Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 10,
                                ),
                                child: Row(
                                  children: [
                                    Text(
                                      "Existing Documents",
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                      ),
                                      textAlign: TextAlign.start,
                                    ),
                                    const Spacer(),
                                    if (removedFiles.isNotEmpty &&
                                        selectedFiles.isEmpty)
                                      Row(
                                        children: [
                                          TextButton(
                                            onPressed: () {
                                              removedFiles.clear();

                                              /// restore original list
                                              documents.value =
                                                  originalDocuments;
                                            },
                                            child: const Text("Cancel"),
                                          ),

                                          ElevatedButton(
                                            onPressed: () async {
                                              List<String> paths = [];

                                              for (var file in selectedFiles) {
                                                if (file.path != null) {
                                                  paths.add(file.path!);
                                                }
                                              }

                                              await DioApi()
                                                  .patchAllLeadDetails(
                                                    leadId!,
                                                    paths,
                                                    removedFiles,
                                                  );

                                              // selectedFiles.clear();
                                              removedFiles.clear();

                                              /// refresh api
                                              await leadDetailsController
                                                  .getAllLeadDetails(
                                                    context,
                                                    leadId,
                                                  );

                                              /// update local documents list
                                              // documents.assignAll(
                                              //   leadDetailsController
                                              //           .allLeadDetailRes
                                              //           .value
                                              //           .data
                                              //           ?.documents ??
                                              //       [],
                                              // );
                                              documents.value =
                                                  List<Document>.from(
                                                    leadDetailsController
                                                            .allLeadDetailRes
                                                            .value
                                                            .data
                                                            ?.documents ??
                                                        [],
                                                  );
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                const SnackBar(
                                                  content: Text(
                                                    "Files Updated successfully",
                                                  ),
                                                  behavior:
                                                      SnackBarBehavior.floating,
                                                ),
                                              );
                                            },
                                            child: const Text("Update"),
                                          ),
                                        ],
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        }),
                        const SizedBox(height: 10),

                        Obx(() {
                          if (removedFiles.isEmpty && documents.isEmpty) {
                            return const SizedBox();
                          }
                          return ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            // itemCount: getResponse.length,
                            itemCount: documents.length,
                            itemBuilder: (context, index) {
                              // final item = getResponse[index];
                              final item = documents[index];
                              return Padding(
                                padding: const EdgeInsets.all(10),
                                child: Container(
                                  padding: const EdgeInsets.all(5),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: isDark
                                        ? Colors.grey[850]
                                        : Colors.grey.shade100,
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: InkWell(
                                          focusColor: Colors.transparent,
                                          splashColor: Colors.transparent,
                                          onTap: () async {
                                            final confirm = await showDialog<bool>(
                                              context: context,
                                              builder: (context) {
                                                return AlertDialog(
                                                  title: const Text(
                                                    "Download File",
                                                  ),
                                                  content: const Text(
                                                    "Do you want to download this file?",
                                                  ),
                                                  actions: [
                                                    TextButton(
                                                      onPressed: () {
                                                        Navigator.pop(
                                                          context,
                                                          false,
                                                        );
                                                      },
                                                      child: const Text(
                                                        "Cancel",
                                                      ),
                                                    ),
                                                    ElevatedButton(
                                                      onPressed: () {
                                                        Navigator.pop(
                                                          context,
                                                          true,
                                                        );
                                                      },
                                                      child: const Text(
                                                        "Download",
                                                      ),
                                                    ),
                                                  ],
                                                );
                                              },
                                            );

                                            if (confirm != true) return;

                                            final documentsPath =
                                                await ExternalPath.getExternalStoragePublicDirectory(
                                                  ExternalPath
                                                      .DIRECTORY_DOCUMENTS,
                                                );

                                            /// CREATE CRM FOLDER
                                            final dir = Directory(
                                              "$documentsPath/CRM",
                                            );

                                            if (!await dir.exists()) {
                                              await dir.create(recursive: true);
                                            }

                                            /// FILE PATH
                                            final filePath =
                                                "${dir.path}/${item.originalName}";

                                            /// DOWNLOAD FILE
                                            await Dio().download(
                                              item.documentUrl ?? '',
                                              filePath,
                                            );

                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  "Saved in $filePath",
                                                ),
                                                behavior:
                                                    SnackBarBehavior.floating,
                                              ),
                                            );
                                          },
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 15,
                                            ),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  item.originalName ?? '',
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                const SizedBox(height: 5),
                                                Text(
                                                  'Upload date: ${formatDate(item.uploadDate)}',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    // fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                const SizedBox(height: 5),
                                                Text(
                                                  'File Size: ${formatFileSize(item.size ?? 0)}',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    // fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                        ),
                                        child: IconButton(
                                          onPressed: () {
                                            /// store removed filename
                                            if (!removedFiles.contains(
                                              item.originalName,
                                            )) {
                                              removedFiles.add(
                                                item.originalName ?? '',
                                              );
                                            }

                                            /// remove from UI
                                            documents.removeAt(index);
                                          },
                                          icon: const Icon(
                                            Icons.delete,
                                            color: Colors.red,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        }),
                        // ],
                        const SizedBox(height: 14),

                        if (data == null || data.isEmpty)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 40),
                            child: Center(
                              child: Text(
                                "No details found!",
                                style: TextStyle(fontSize: 14),
                              ),
                            ),
                          ),

                        if (data != null && data.isNotEmpty) ...[
                          Text(
                            "Timeline",
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                            textAlign: TextAlign.start,
                          ),
                          const SizedBox(height: 15),

                          /// Timeline list
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            controller: scrollController,
                            itemCount: data.length ?? 0,
                            itemBuilder: (context, index) {
                              final item = data[index];
                              // final isLast = index == (data?.length ?? 1 - 1);
                              final isLast = index == ((data.length ?? 0) - 1);

                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    /// LEFT TIMELINE INDICATOR
                                    Column(
                                      children: [
                                        /// Circle icon
                                        Container(
                                          width: 30,
                                          height: 30,
                                          decoration: BoxDecoration(
                                            color: index == 0
                                                ? Colors.blue.shade50
                                                : Colors.grey.shade50,
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: index == 0
                                                  ? Colors.blue
                                                  : Colors.grey,
                                              width: 2,
                                            ),
                                          ),
                                          child: Icon(
                                            index == 0
                                                ? Icons.circle
                                                : Icons.check,
                                            size: 16,
                                            color: index == 0
                                                ? Colors.blue
                                                : Colors.grey,
                                          ),
                                        ),

                                        /// Vertical line
                                        if (!isLast)
                                          Container(
                                            width: 2,
                                            height: 170,
                                            color: Colors.blue.shade100,
                                          ),
                                      ],
                                    ),

                                    const SizedBox(width: 12),

                                    /// RIGHT CONTENT
                                    Expanded(
                                      child: Container(
                                        margin: const EdgeInsets.only(
                                          bottom: 16,
                                        ),
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: isDark
                                              ? Colors.grey[850]
                                              : Colors.grey.shade100,
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            /// Stage
                                            Text(
                                              item?.stage ?? '',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                            ),

                                            const SizedBox(height: 2),

                                            /// Date
                                            Text(
                                              formatTimelineDate(
                                                item?.date ?? '',
                                              ),
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey[600],
                                              ),
                                            ),

                                            const SizedBox(height: 8),

                                            const Text(
                                              "Agent: ",
                                              style: TextStyle(
                                                fontWeight: FontWeight.w500,
                                                fontSize: 14,
                                              ),
                                            ),

                                            /// Note
                                            Text(
                                              item?.agent ?? '',
                                              style: const TextStyle(
                                                fontSize: 13,
                                              ),
                                            ),
                                            const SizedBox(height: 3),
                                            if (item.note != null &&
                                                item.note!.isNotEmpty)
                                              const Text(
                                                "Notes: ",
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: 14,
                                                ),
                                              ),

                                            /// Note
                                            Text(
                                              item.note ?? '',
                                              style: const TextStyle(
                                                fontSize: 13,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> uploadFile(BuildContext context) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx', 'jpg', 'png'],
    );

    if (result != null) {
      selectedFiles.addAll(result.files);
    }
  }

  String formatFileSize(int bytes) {
    const kb = 1024;
    const mb = 1024 * 1024;
    const gb = 1024 * 1024 * 1024;

    if (bytes < kb) {
      return "$bytes B";
    } else if (bytes < mb) {
      return "${(bytes / kb).toStringAsFixed(2)} KB";
    } else if (bytes < gb) {
      return "${(bytes / mb).toStringAsFixed(2)} MB";
    } else {
      return "${(bytes / gb).toStringAsFixed(2)} GB";
    }
  }

  String formatDate(String? date) {
    if (date == null || date.isEmpty) return '';

    final dateTime = DateTime.parse(date).toLocal();

    return DateFormat('dd MMM yyyy, hh:mm a').format(dateTime);
  }

  void onWhatsApp(BuildContext context) {
    print("WhatsApp clicked");

    /// reset before opening
    _whatsappSmsController.currentPage = 1;
    _whatsappSmsController.wsData.clear();
    _whatsappSmsController.isMoreDataAvailable.value = true;

    /// OPEN DIALOG FIRST
    alertDialog(
      () async {
        if (_whatsappSmsController.wsData.isEmpty ||
            _whatsappSmsController.wsData.first.body == null) {
          Get.snackbar(
            "Error",
            "No message template found",
            snackPosition: SnackPosition.BOTTOM,
          );
          return;
        }

        final template = _whatsappSmsController.wsData.first.body ?? '';
        final customerName = _whatsappSmsController.wsData.first.name ?? '';

        final message = template
            .replaceAll("{{customer_name}}", name)
            .replaceAll(
              "{{agent_name}}",
              LocalStorage.sharedPreferences!.getString('user_name') ?? "User",
            );

        await openWhatsApp(phone.toString(), message);
      },
      context,
      _whatsappSmsController,
      whichSource: 'WhatsApp',
      content: Obx(() {
        if (_whatsappSmsController.isLoading.value == PageState.loading) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(strokeWidth: 2, color: Colors.black54),
              SizedBox(height: 10),
              Text("Loading..."),
            ],
          );
        }

        /// Show proper message if empty
        if (_whatsappSmsController.wsData.isEmpty) {
          return Text(
            "No templates available",
            style: TextStyle(color: Colors.red),
          );
        }

        return Text('Do you want to open WhatsApp?');
      }),
    );

    /// CALL API AFTER DIALOG OPENS
    Future.microtask(() {
      _whatsappSmsController.getWhatsSms(
        whichSource: 'whatsapp',
        campaignId: campaignId,
      );
    });
  }

  Future<void> openWhatsApp(String phone, String message) async {
    final encodedMessage = Uri.encodeComponent(message);

    final uri = Uri.parse(
      "whatsapp://send?phone=91$phone&text=$encodedMessage",
    );

    print("whatsappURL : $uri");

    if (await canLaunchUrl(uri)) {
      await launchUrl(
        uri,
        mode: LaunchMode.externalApplication, // IMPORTANT
      );
    } else {
      print("WhatsApp not installed or cannot open");

      /// Fallback to browser (always works)
      final fallback = Uri.parse("https://wa.me/91$phone?text=$encodedMessage");

      await launchUrl(fallback, mode: LaunchMode.externalApplication);
    }
  }

  void onSms(BuildContext context) {
    print("SMS clicked");

    _whatsappSmsController.currentPage = 1;
    _whatsappSmsController.wsData.clear();
    _whatsappSmsController.isMoreDataAvailable.value = true;

    alertDialog(
      () async {
        if (_whatsappSmsController.wsData.isEmpty ||
            _whatsappSmsController.wsData.first.body == null) {
          Get.snackbar(
            "Error",
            "No message template found",
            snackPosition: SnackPosition.BOTTOM,
          );
          return;
        }

        final template = _whatsappSmsController.wsData.first.body ?? '';
        final customerName = _whatsappSmsController.wsData.first.name ?? '';

        final message = template
            .replaceAll("{{customer_name}}", name)
            .replaceAll(
              "{{agent_name}}",
              LocalStorage.sharedPreferences!.getString('user_name') ?? "User",
            );

        await openSMS(phone.toString(), message);
      },
      context,
      _whatsappSmsController,
      whichSource: 'SMS',
      content: Obx(() {
        if (_whatsappSmsController.isLoading.value == PageState.loading) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(strokeWidth: 2, color: Colors.black54),
              SizedBox(height: 10),
              Text("Loading..."),
            ],
          );
        }

        /// Show proper message if empty
        if (_whatsappSmsController.wsData.isEmpty) {
          return Text(
            "No templates available",
            style: TextStyle(color: Colors.red),
          );
        }

        return Text('Do you want to open SMS?');
      }),
    );

    Future.microtask(() {
      _whatsappSmsController.getWhatsSms(
        whichSource: 'sms',
        campaignId: campaignId,
      );
    });
  }

  Future<void> openSMS(String phone, String message) async {
    final url = "sms:$phone?body=${Uri.encodeComponent(message)}";

    print('SmsURL : $url');

    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      print("Could not launch SMS");
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    // Example timestamp
    final String isoTime = time;

    // Parse and format
    final dateTime = DateTime.parse(isoTime).toLocal();
    final formattedTime = DateFormat('hh:mm a, dd MMM').format(dateTime);

    // Color scheme
    // final statusColor = isMissedCall ? Colors.red : Colors.green;
    // final statusIcon = isMissedCall ? Icons.phone_missed : Icons.phone;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[900] : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Status indicator
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 128),
                  shape: BoxShape.circle,
                ),
                // child: Icon(statusIcon, color: statusColor, size: 20),
                child: Center(
                  child: Text(
                    // '',
                    (name[0]).toUpperCase(),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 16),

              // Content area
              Expanded(
                child: InkWell(
                  splashColor: Colors.transparent,
                  focusColor: Colors.transparent,
                  hoverColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                  onTap: () => openBottomSheet(context, timelineData, leadId),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        name,
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: isDark
                                              ? Colors.white
                                              : Colors.grey[900],
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                      ),
                                    ),
                                    // if (isMissedCall)
                                    //   Container(
                                    //     margin: const EdgeInsets.only(left: 8),
                                    //     padding: const EdgeInsets.symmetric(
                                    //       horizontal: 8,
                                    //       vertical: 2,
                                    //     ),
                                    //     decoration: BoxDecoration(
                                    //       color: Colors.red.withOpacity(0.1),
                                    //       borderRadius: BorderRadius.circular(
                                    //         12,
                                    //       ),
                                    //     ),
                                    //     child: Text(
                                    //       'Missed',
                                    //       style: TextStyle(
                                    //         fontSize: 10,
                                    //         fontWeight: FontWeight.w600,
                                    //         color: Colors.red,
                                    //       ),
                                    //     ),
                                    //   ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                if (phone != null)
                                  Text(
                                    phone.toString(),
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: isDark
                                          ? Colors.grey[400]
                                          : Colors.grey[700],
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      // Bottom row with time and tag
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.access_time,
                                size: 14,
                                color: isDark
                                    ? Colors.grey[500]
                                    : Colors.grey[600],
                              ),
                              const SizedBox(width: 4),
                              Text(
                                formattedTime,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isDark
                                      ? Colors.grey[500]
                                      : Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      if (campaign != null) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.green.shade50,
                                Colors.green.shade100,
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            border: Border.all(
                              color: Colors.green.withOpacity(0.3),
                              width: 0.5,
                            ),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            campaign ?? '',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Colors.blue.shade800,
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 10),
                      if (tag.isNotEmpty) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.blue.shade50,
                                Colors.blue.shade100,
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            border: Border.all(
                              color: Colors.blue.withOpacity(0.3),
                              width: 0.5,
                            ),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            tag,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Colors.blue.shade800,
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 7),
                      if (followUp != null && tag == 'Follow Up') ...[
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.yellow.shade200,
                                Colors.yellow.shade300,
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            border: Border.all(
                              color: Colors.yellow,
                              width: 0.6,
                            ),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            followUp != null
                                ? DateFormat(
                                    'dd/MM/yyyy  hh:mm a',
                                  ).format(followUp!.toLocal())
                                : 'no date & time',
                            // followUp!.toIso8601String(),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Colors.blue.shade800,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              const SizedBox(width: 12),

              if (assignedTo == null && isMissedFUps == false) ...[
                Column(
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade400,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: accept,
                      child: const Text('Accept'),
                    ),
                    5.heightBox,
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade300,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: decline,
                      child: const Text('Reject'),
                    ),
                  ],
                ),
              ],
              // Call Back Button
              if (assignedTo != null || isMissedFUps == true) ...[
                Column(
                  children: [
                    ///Phone
                    InkWell(
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(12),
                        bottomRight: Radius.circular(12),
                      ),
                      onTap: onCallBack,
                      child: IconButton(
                        onPressed: onCallBack,
                        icon: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [
                                Colors.blue.shade100,
                                Colors.blue.shade200,
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.blue.withOpacity(0.2),
                                blurRadius: 6,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.phone,
                            color: Colors.blue.shade800,
                            size: 20,
                          ),
                        ),
                        splashRadius: 24,
                      ),
                    ),

                    ///WhatsApp
                    IconButton(
                      onPressed: () => onWhatsApp(context),
                      icon: Container(
                        padding: const EdgeInsets.all(8),
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [
                              Colors.blue.shade100,
                              Colors.green.shade200,
                            ],
                          ),
                        ),
                        child: Image.asset(
                          'assets/whatsapp.png',
                          color: Colors.green.shade800,
                        ),
                      ),
                    ),

                    ///SMS
                    IconButton(
                      onPressed: () => onSms(context),
                      icon: Container(
                        padding: const EdgeInsets.all(8),
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [
                              Colors.blue.shade100,
                              Colors.brown.shade200,
                            ],
                          ),
                        ),
                        child: Icon(
                          Icons.sms,
                          color: Colors.brown.shade800,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
