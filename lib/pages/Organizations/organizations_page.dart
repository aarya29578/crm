import 'package:flutter/material.dart';
import 'package:crm_flutter/pages/Organizations/add_organization_page.dart';
import 'package:crm_flutter/pages/Organizations/organizations_controller.dart';
import 'package:crm_flutter/styles/text_styles.dart';
import 'package:get/get.dart';

class OrganizationsPage extends StatefulWidget {
  const OrganizationsPage({super.key});

  @override
  State<OrganizationsPage> createState() => _OrganizationsPageState();
}

class _OrganizationsPageState extends State<OrganizationsPage> {
  final OrganizationsController orgController = Get.put(
    OrganizationsController(),
  );
  final ScrollController _scrollController = ScrollController();
  final double _cardElevation = 2.0;
  final double _cardMargin = 8.0;
  final double _cardPadding = 16.0;

  @override
  void initState() {
    super.initState();
    orgController.getAllOrganizations();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        title: Text("Organizations", style: whiteHeading),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () => orgController.getAllOrganizations(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Add your logic for adding a new organization here
          // Get.snackbar(
          //   'Add Organization',
          //   'Add organization functionality will go here',
          // );
          Get.to(AddOrganizationPage(isEdit: false));
        },
        backgroundColor: Colors.blueAccent,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: SafeArea(
        child: Obx(() {
          final response = orgController.allOrganizationRes.value;

          if (response.data == null) {
            return const Center(child: CircularProgressIndicator());
          }

          final orgList = response.data!;
          if (orgList.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.business_outlined,
                    size: 48,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No organizations found',
                    style: TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Add new organizations to see them here',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async => await orgController.getAllOrganizations(),
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(8),
              itemCount: orgList.length,
              itemBuilder: (context, index) {
                final org = orgList[index];
                final address = org.address;

                return Card(
                  elevation: _cardElevation,
                  color: Colors.white,
                  margin: EdgeInsets.all(_cardMargin),
                  child: Padding(
                    padding: EdgeInsets.all(_cardPadding),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.business,
                                    color: Colors.blueAccent,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      org.name ?? 'Unnamed Organization',
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit, size: 20),
                                  color: Colors.blue,
                                  onPressed: () {
                                    Get.to(
                                      AddOrganizationPage(
                                        isEdit: true,
                                        organizationData: org,
                                      ),
                                    );
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, size: 20),
                                  color: Colors.red,
                                  onPressed: () =>
                                      _handleDeleteOrganization(org),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        if (address != null) _buildAddressInfo(address),
                        const SizedBox(height: 8),
                        _buildMetaInfo(org),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        }),
      ),
    );
  }

  Widget _buildAddressInfo(dynamic address) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (address.street != null && address.street!.isNotEmpty)
          Text('Street: ${address.street}'),
        if (address.city != null && address.city!.isNotEmpty)
          Text('City: ${address.city}'),
        if (address.state != null && address.state!.isNotEmpty)
          Text('State: ${address.state}'),
        if (address.zip != null && address.zip!.isNotEmpty)
          Text('ZIP: ${address.zip}'),
      ],
    );
  }

  Widget _buildMetaInfo(dynamic org) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        if (org.createdAt != null)
          Text(
            'Created: ${_formatDate(org.createdAt!)}',
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
        if (org.updatedAt != null)
          Text(
            'Updated: ${_formatDate(org.updatedAt!)}',
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
      ],
    );
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateString;
    }
  }

  void _handleDeleteOrganization(dynamic org) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Organization'),
        content: Text('Are you sure you want to delete ${org.name}?'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              orgController.deleteOrganization(org.sId!);
              print('Deleted Organization: ${org.name}');
              Navigator.pop(context);
              //Get.back();
              //Get.snackbar('Deleted', '${org.name} deleted');
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
