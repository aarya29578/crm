import 'package:flutter/material.dart';
import 'package:crm_flutter/pages/Settings/Groups/add_group_page.dart';
import 'package:crm_flutter/pages/Settings/Groups/group_controller.dart';
import 'package:crm_flutter/styles/text_styles.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import 'package:flutter/material.dart';
import 'package:crm_flutter/pages/Settings/Groups/add_group_page.dart';
import 'package:crm_flutter/pages/Settings/Groups/group_controller.dart';
import 'package:crm_flutter/styles/text_styles.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class GroupPage extends StatefulWidget {
  const GroupPage({super.key});

  @override
  State<GroupPage> createState() => _GroupPageState();
}

class _GroupPageState extends State<GroupPage> {
  GroupController groupController = Get.put(GroupController());
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    groupController.getAllGroups();
  }

  String _formatDate(String? dateTimeString) {
    if (dateTimeString == null || dateTimeString.isEmpty) return 'N/A';

    try {
      final dateTime = DateTime.parse(dateTimeString);
      return DateFormat('MMM dd, yyyy').format(dateTime);
    } catch (e) {
      return 'N/A';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        title: Text("Groups", style: whiteHeading),
        centerTitle: true,
        elevation: 2,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () {
              groupController.getAllGroups();
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Get.to(() => AddGroupPage(isEdit: false));
        },
        backgroundColor: Colors.blueAccent,
        elevation: 4,
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
      body: Obx(() {
        final response = groupController.allGroupRes.value;
        if (response.data == null) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blueAccent),
            ),
          );
        }

        final groupList = response.data!;

        if (groupList.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.group, size: 60, color: Colors.grey.shade400),
                const SizedBox(height: 16),
                Text(
                  "No Groups Found",
                  style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 8),
                Text(
                  "Tap the + button to add a new group",
                  style: TextStyle(color: Colors.grey.shade500),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            await groupController.getAllGroups();
          },
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(16),
            itemCount: groupList.length,
            itemBuilder: (context, index) {
              final group = groupList[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // First row with icon, name, and action buttons
                      Row(
                        children: [
                          // Group icon
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.group,
                              size: 20,
                              color: Colors.blue.shade600,
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Group name
                          Expanded(
                            child: Text(
                              group.name ?? "Unnamed Group",
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.blueGrey,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          // Action buttons
                          IconButton(
                            icon: const Icon(Icons.edit, size: 20),
                            color: Colors.blue,
                            onPressed: () {
                              Get.to(
                                () => AddGroupPage(
                                  isEdit: true,
                                  groupData: group,
                                ),
                              );
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, size: 20),
                            color: Colors.red,
                            onPressed: () {
                              _showDeleteDialog(group.sId!);
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Description
                      if (group.description?.isNotEmpty ?? false)
                        Padding(
                          padding: const EdgeInsets.only(
                            left: 48,
                          ), // Align with text
                          child: Text(
                            group.description!,
                            style: TextStyle(
                              color: Colors.grey.shade700,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      const SizedBox(height: 12),
                      // Dates row
                      Padding(
                        padding: const EdgeInsets.only(
                          left: 48,
                        ), // Align with text
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildDateInfo(
                              icon: Icons.calendar_today,
                              label: 'Created',
                              date: _formatDate(group.createdAt),
                            ),
                            _buildDateInfo(
                              icon: Icons.update,
                              label: 'Updated',
                              date: _formatDate(group.updatedAt),
                            ),
                          ],
                        ),
                      ),
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

  Widget _buildDateInfo({
    required IconData icon,
    required String label,
    required String date,
  }) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
            ),
            const SizedBox(height: 2),
            Text(
              date,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade700,
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _showDeleteDialog(String groupId) {
    Get.dialog(
      AlertDialog(
        title: const Text('Delete Group'),
        content: const Text('Are you sure you want to delete this group?'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Get.back();
              groupController.deleteGroup(groupId);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
