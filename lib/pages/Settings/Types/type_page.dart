import 'package:flutter/material.dart';
import 'package:crm_flutter/api/response/all_types_response.dart';
import 'package:crm_flutter/pages/Settings/Types/type_controller.dart';
import 'package:crm_flutter/styles/text_styles.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import 'package:crm_flutter/pages/Settings/Types/add_type_page.dart';
import 'package:intl/intl.dart';

class TypePage extends StatefulWidget {
  const TypePage({super.key});

  @override
  State<TypePage> createState() => _TypePageState();
}

class _TypePageState extends State<TypePage> {
  final TypeController typeController = Get.put(TypeController());
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    typeController.getAllTypes();
  }

  String _formatDate(String? dateTimeString) {
    if (dateTimeString == null || dateTimeString.isEmpty) return 'N/A';

    try {
      final dateTime = DateTime.parse(dateTimeString);
      return DateFormat('MMM dd, yyyy - hh:mm a').format(dateTime);
    } catch (e) {
      return 'N/A';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        title: Text("Lead Types", style: whiteHeading),
        centerTitle: true,
        elevation: 2,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.white),
            onPressed: () => typeController.getAllTypes(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.to(() => AddTypePage()),
        backgroundColor: Colors.blueAccent,
        elevation: 4,
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
      body: Obx(() {
        final response = typeController.allTypeRes.value;

        if (response.data == null) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blueAccent),
            ),
          );
        }

        final typesList = response.data!;

        if (typesList.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.type_specimen,
                  size: 64,
                  color: Colors.grey.shade400,
                ),
                SizedBox(height: 16),
                Text(
                  "No lead types found",
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 8),
                TextButton(
                  onPressed: () => typeController.getAllTypes(),
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
          onRefresh: () async => await typeController.getAllTypes(),
          color: Colors.blueAccent,
          child: ListView.separated(
            controller: _scrollController,
            padding: const EdgeInsets.all(16),
            itemCount: typesList.length,
            separatorBuilder: (context, index) => SizedBox(height: 12),
            itemBuilder: (context, index) {
              final type = typesList[index];
              return Card(
                color: Colors.white,
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                margin: EdgeInsets.zero,
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => _showTypeDetails(type),
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
                                Icons.type_specimen,
                                size: 20,
                                color: Colors.blueAccent,
                              ),
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                type.name ?? "Unnamed Type",
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
                              onPressed: () => _handleDeleteType(type),
                            ),
                          ],
                        ),
                        SizedBox(height: 12),
                        _buildInfoRow(
                          Icons.calendar_today_outlined,
                          "Created: ${_formatDate(type.createdAt)}",
                        ),
                        SizedBox(height: 4),
                        _buildInfoRow(
                          Icons.update,
                          "Updated: ${_formatDate(type.updatedAt)}",
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

  void _showTypeDetails(Data type) {
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
              "Type Details",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
            ),
            SizedBox(height: 20),
            _buildDetailItem("Name", type.name ?? "N/A"),
            _buildDetailItem("Created", type.createdAt ?? "N/A"),
            _buildDetailItem("Updated", type.updatedAt ?? "N/A"),
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

  void _handleDeleteType(Data type) {
    Get.dialog(
      AlertDialog(
        title: Text(
          "Delete Type",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Text(
          "Are you sure you want to delete '${type.name}'?",
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
                await typeController.deleteType(type.sId!);
                await typeController.getAllTypes();
                Get.back();

                Get.snackbar(
                  "Success",
                  "Type deleted successfully",
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.green,
                  colorText: Colors.white,
                  duration: Duration(seconds: 2),
                );
              } catch (e) {
                Get.back();
                Get.snackbar(
                  "Error",
                  "Failed to delete type",
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
