import 'package:flutter/material.dart';
import 'package:crm_flutter/pages/Settings/Groups/group_page.dart';
import 'package:crm_flutter/pages/Settings/Roles/role_page.dart';
import 'package:crm_flutter/pages/Settings/Sources/source_page.dart';
import 'package:crm_flutter/pages/Settings/Types/type_page.dart';
import 'package:crm_flutter/styles/text_styles.dart';
import 'package:crm_flutter/widgets/IconTileRowCard.dart';
import 'package:get/get.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        elevation: 0,
        title: Text(
          "Settings",
          style: whiteHeading.copyWith(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // User Section
                _buildSettingsCard(
                  title: "User",
                  description:
                      "Manage all your users and their permissions in the CRM",
                  children: [
                    _buildSettingItem(
                      icon: Icons.group,
                      iconColor: Colors.blue.shade700,
                      title: "Groups",
                      onTap: () {
                        Get.to(GroupPage());
                      },
                    ),
                    _buildDivider(),
                    _buildSettingItem(
                      icon: Icons.verified_user,
                      iconColor: Colors.orange.shade700,
                      title: "Roles",
                      onTap: () {
                        Get.to(RolePage());
                      },
                    ),
                    _buildDivider(),
                    _buildSettingItem(
                      icon: Icons.people,
                      iconColor: Colors.green.shade700,
                      title: "Users",
                      onTap: () {},
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Lead Section
                _buildSettingsCard(
                  title: "Lead",
                  description:
                      "Manage all your leads related settings in the CRM",
                  children: [
                    _buildSettingItem(
                      icon: Icons.account_tree,
                      iconColor: Colors.purple.shade700,
                      title: "Pipelines",
                      onTap: () {},
                    ),
                    _buildDivider(),
                    _buildSettingItem(
                      icon: Icons.source,
                      iconColor: Colors.teal.shade700,
                      title: "Sources",
                      onTap: () => Get.to(const SourcePage()),
                    ),
                    _buildDivider(),
                    _buildSettingItem(
                      icon: Icons.category,
                      iconColor: Colors.indigo.shade700,
                      title: "Types",
                      onTap: () {
                        Get.to(TypePage());
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Warehouse Section
                _buildSettingsCard(
                  title: "Warehouse",
                  description: "Edit or Delete all your warehouses from CRM",
                  children: [
                    _buildSettingItem(
                      icon: Icons.warehouse,
                      iconColor: Colors.brown.shade700,
                      title: "Warehouses",
                      onTap: () {},
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Automation Section
                _buildSettingsCard(
                  title: "Automation",
                  description:
                      "Manage all your automation related settings in the CRM",
                  children: [
                    _buildSettingItem(
                      icon: Icons.tune,
                      iconColor: Colors.red.shade700,
                      title: "Attributes",
                      onTap: () {},
                    ),
                    _buildDivider(),
                    _buildSettingItem(
                      icon: Icons.email,
                      iconColor: Colors.blue.shade700,
                      title: "Email Templates",
                      onTap: () {},
                    ),
                    _buildDivider(),
                    _buildSettingItem(
                      icon: Icons.webhook,
                      iconColor: Colors.green.shade700,
                      title: "Webhooks",
                      onTap: () {},
                    ),
                    _buildDivider(),
                    _buildSettingItem(
                      icon: Icons.work,
                      iconColor: Colors.orange.shade700,
                      title: "Workflows",
                      onTap: () {},
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Other Settings Section
                _buildSettingsCard(
                  title: "Other Settings",
                  description: "Manage all your extra settings in the CRM",
                  children: [
                    _buildSettingItem(
                      icon: Icons.web,
                      iconColor: Colors.purple.shade700,
                      title: "Web Forms",
                      onTap: () {},
                    ),
                    _buildDivider(),
                    _buildSettingItem(
                      icon: Icons.tag,
                      iconColor: Colors.teal.shade700,
                      title: "Tags",
                      onTap: () {},
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsCard({
    required String title,
    required String description,
    required List<Widget> children,
  }) {
    return Card(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              description,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: iconColor.withOpacity(0.2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: iconColor),
      ),
      title: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      ),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: onTap,
    );
  }

  Widget _buildDivider() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Divider(height: 1, thickness: 1),
    );
  }
}
