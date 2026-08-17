import 'package:flutter/material.dart';
import 'package:crm_flutter/api/response/all_sources_response.dart';
import 'package:crm_flutter/pages/Settings/Sources/source_controller.dart';
import 'package:crm_flutter/styles/text_styles.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class SourcePage extends StatefulWidget {
  const SourcePage({super.key});

  @override
  State<SourcePage> createState() => _SourcePageState();
}

class _SourcePageState extends State<SourcePage> {
  final SourceController sourceController = Get.put(SourceController());
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    sourceController.getAllSources();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        title: Text("Lead Sources", style: whiteHeading),
        centerTitle: true,
        elevation: 2,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.white),
            onPressed: () => sourceController.getAllSources(),
          ),
        ],
      ),
      body: Obx(() {
        final response = sourceController.allSourceRes.value;

        if (response.data == null) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blueAccent),
            ),
          );
        }

        final sourcesList = response.data!;

        if (sourcesList.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.source_outlined,
                  size: 64,
                  color: Colors.grey.shade400,
                ),
                SizedBox(height: 16),
                Text(
                  "No lead sources found",
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 8),
                TextButton(
                  onPressed: () => sourceController.getAllSources(),
                  child: Text(
                    "Tap to refresh",
                    style: TextStyle(color: Colors.blueAccent),
                  ),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async => await sourceController.getAllSources(),
          color: Colors.blueAccent,
          child: ListView.separated(
            controller: _scrollController,
            padding: const EdgeInsets.all(16),
            itemCount: sourcesList.length,
            separatorBuilder: (context, index) => SizedBox(height: 12),
            itemBuilder: (context, index) {
              final source = sourcesList[index];
              final dateFormat = DateFormat('MMM dd, yyyy - hh:mm a');

              return Card(
                color: Colors.white,
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                margin: EdgeInsets.zero,
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => _showSourceDetails(source),
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade50,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.source,
                                size: 20,
                                color: Colors.blueAccent,
                              ),
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                source.name ?? "Unnamed Source",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey.shade800,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.delete_outline, size: 20),
                              color: Colors.redAccent,
                              onPressed: () => _handleDeleteSource(source),
                            ),
                          ],
                        ),
                        SizedBox(height: 12),
                        _buildInfoRow(
                          Icons.calendar_today_outlined,
                          "Created: ${dateFormat.format(DateTime.parse(source.createdAt!))}",
                        ),
                        SizedBox(height: 4),
                        _buildInfoRow(
                          Icons.update,
                          "Updated: ${dateFormat.format(DateTime.parse(source.updatedAt!))}",
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        );
      }),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey.shade500),
        SizedBox(width: 8),
        Text(text, style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
      ],
    );
  }

  void _showSourceDetails(Data source) {
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Text(
              "Source Details",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
            ),
            SizedBox(height: 20),
            _buildDetailItem("Name", source.name ?? "N/A"),
            _buildDetailItem("Created", source.createdAt ?? "N/A"),
            _buildDetailItem("Updated", source.updatedAt ?? "N/A"),
            SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Get.back(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  padding: EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text("Close", style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleDeleteSource(Data source) {
    Get.dialog(
      AlertDialog(
        title: Text(
          "Delete Source",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Text(
          "Are you sure you want to delete '${source.name}'?",
          style: TextStyle(fontSize: 15),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              "Cancel",
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ),
          TextButton(
            onPressed: () async {
              Get.back();
              Get.dialog(
                Center(child: CircularProgressIndicator()),
                barrierDismissible: false,
              );

              try {
                await sourceController.deleteSource(source.sId!);
                await sourceController.getAllSources();
                Get.back();

                Get.snackbar(
                  "Success",
                  "Source deleted successfully",
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.green,
                  colorText: Colors.white,
                  duration: Duration(seconds: 2),
                );
              } catch (e) {
                Get.back();
                Get.snackbar(
                  "Error",
                  "Failed to delete source",
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                );
              }
            },
            child: Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
