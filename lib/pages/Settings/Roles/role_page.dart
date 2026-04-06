import 'package:flutter/material.dart';
import 'package:crm_flutter/pages/Settings/Roles/role_controller.dart';
import 'package:crm_flutter/pages/Settings/Types/add_type_page.dart';
import 'package:crm_flutter/styles/text_styles.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

class RolePage extends StatefulWidget {
  const RolePage({super.key});

  @override
  State<RolePage> createState() => _RolePageState();
}

class _RolePageState extends State<RolePage> {
  RoleController roleController = Get.put(RoleController());
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    roleController.getAllRoles();
  }

  // Helper function to extract date from timestamp
  String _formatDate(String? timestamp) {
    if (timestamp == null || timestamp.isEmpty) return "Not available";

    try {
      final dateTime = DateTime.parse(timestamp);
      return "${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}";
    } catch (e) {
      return timestamp; // Return original if parsing fails
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        title: Text("Lead Roles", style: whiteHeading),
        centerTitle: true,
        elevation: 2,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () => roleController.getAllRoles(),
          ),
        ],
      ),

      body: Obx(() {
        final response = roleController.allRoleRes.value;
        if (response.data == null) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blueAccent),
            ),
          );
        }

        final rolesList = response.data!;

        if (rolesList.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.people_alt_outlined,
                  size: 64,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 16),
                Text(
                  "No lead roles found",
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => roleController.getAllRoles(),
                  child: const Text(
                    "Tap to refresh",
                    style: TextStyle(color: Colors.blueAccent),
                  ),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            await roleController.getAllRoles();
          },
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(16),
            itemCount: rolesList.length,
            itemBuilder: (context, index) {
              final role = rolesList[index];
              final createdAt = _formatDate(role.createdAt);
              final updatedAt = _formatDate(role.updatedAt);

              return Card(
                color: Colors.white,
                margin: const EdgeInsets.only(bottom: 16),
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.badge, color: Colors.blueAccent),
                          const SizedBox(width: 10),
                          Text(
                            role.name ?? "Unnamed Role",
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _buildInfoRow(
                        "Description:",
                        role.description ?? "No description",
                      ),
                      const SizedBox(height: 8),
                      _buildInfoRow(
                        "Permission Type:",
                        role.permissionType ?? "Not specified",
                      ),
                      const SizedBox(height: 8),
                      _buildPermissionsSection(role.permissions ?? []),
                      const SizedBox(height: 12),
                      _buildTimestamps(createdAt, updatedAt),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      }),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            color: Colors.black54,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w400),
          ),
        ),
      ],
    );
  }

  Widget _buildPermissionsSection(List<dynamic> permissions) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Permissions:",
          style: TextStyle(fontWeight: FontWeight.w500, color: Colors.black54),
        ),
        const SizedBox(height: 4),
        if (permissions.isEmpty)
          const Text(
            "No permissions assigned",
            style: TextStyle(color: Colors.grey),
          )
        else
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: permissions.map((permission) {
              return Chip(
                label: Text(
                  permission.toString(),
                  style: const TextStyle(fontSize: 12),
                ),
                backgroundColor: Colors.blue.shade50,
                visualDensity: VisualDensity.compact,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              );
            }).toList(),
          ),
      ],
    );
  }

  Widget _buildTimestamps(String createdAt, String updatedAt) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildTimestampItem(Icons.access_time, "Created", createdAt),
        _buildTimestampItem(Icons.update, "Updated", updatedAt),
      ],
    );
  }

  Widget _buildTimestampItem(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.grey),
        const SizedBox(width: 4),
        Text(
          "$label: ",
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
        Text(value, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}
