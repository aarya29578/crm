import 'package:crm_flutter/models/enums.dart';
import 'package:flutter/material.dart';
import 'package:crm_flutter/pages/home/HomeController.dart';
import 'package:crm_flutter/pages/lead_details/LeadDetailsController.dart';
import 'package:flutter/services.dart';
import 'package:crm_flutter/styles/color_palette.dart';
import 'package:get/get.dart';

class LeadDetailsPage extends StatefulWidget {
  final String leadId;

  const LeadDetailsPage({super.key, required this.leadId});

  @override
  State<LeadDetailsPage> createState() => _LeadDetailsPageState();
}

class _LeadDetailsPageState extends State<LeadDetailsPage> {
  final Leaddetailscontroller leadDetailsController = Get.put(
    Leaddetailscontroller(),
  );

  final HomeController homeController = Get.put(HomeController());

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    try {
      print("leadiddetailpage:${widget.leadId}");
      await leadDetailsController.getAllLeadDetails(context, widget.leadId);
    } catch (e) {
      print("Error in loadData: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Failed to load data: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        surfaceTintColor: ColorConstants.MainPurpleBackground,
        backgroundColor: ColorConstants.MainPurpleBackground,
        elevation: 0,
        toolbarHeight: 40,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text("Back"),
        titleTextStyle: const TextStyle(color: Colors.white, fontSize: 20),
        // actions: [
        //   IconButton(
        //     icon: Icon(Icons.edit, color: Colors.white),
        //     onPressed: () {},
        //   ),
        //   IconButton(
        //     icon: Icon(Icons.more_vert, color: Colors.white),
        //     onPressed: () {},
        //   ),
        // ],
      ),
      body: Obx(() {
        // final response = homeController.allLeadsRes.value;
        // final leadList = response.data ?? [];
        // final leadDetails = leadList.firstWhereOrNull(
        //   (lead) => lead.sId == widget.leadId,
        // );
        final leadDetails = leadDetailsController.allLeadDetailRes.value.data;

        if (leadDetailsController.pageState.value == PageState.loading) {
          return const Center(child: CircularProgressIndicator());
        }

        return Column(
          children: [
            // Header Section
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              decoration: BoxDecoration(
                color: ColorConstants.MainPurpleBackground,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Lead ID
                  // Text(
                  //   "Lead #${widget.leadId.substring(0, 8)}...",
                  //   style: TextStyle(
                  //     color: Colors.white.withOpacity(0.8),
                  //     fontSize: 12,
                  //   ),
                  // ),
                  // const SizedBox(height: 8),

                  // Name and Age
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          "${leadDetails?.name?.first ?? 'N/A'} ${leadDetails?.name?.last ?? ''}",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontSize: 24,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (leadDetails?.age != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '${leadDetails?.age} yrs',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // Company and Designation
                  if (leadDetails?.companyName != null)
                    Text(
                      '${leadDetails?.companyName}${leadDetails?.designation != '' ? ' • ${leadDetails?.designation}' : ''}',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),

            /// Quick Actions Bar
            // Container(
            //   padding: const EdgeInsets.symmetric(vertical: 12),
            //   decoration: BoxDecoration(
            //     color: Colors.white,
            //     boxShadow: [
            //       BoxShadow(
            //         color: Colors.grey.withOpacity(0.1),
            //         blurRadius: 10,
            //         offset: const Offset(0, 2),
            //       ),
            //     ],
            //   ),
            //   child: Row(
            //     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            //     children: [
            //       _buildActionButton(Icons.phone, "Call", Colors.green),
            //       _buildActionButton(Icons.email, "Email", Colors.blue),
            //       _buildActionButton(
            //         Icons.calendar_today,
            //         "Schedule",
            //         Colors.orange,
            //       ),
            //       _buildActionButton(Icons.chat, "Message", Colors.purple),
            //     ],
            //   ),
            // ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // Status and Category Cards
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Expanded(
                            child: _buildInfoCard(
                              title: "Status",
                              value:
                                  leadDetails?.leadStageId?.name ?? "Not Set",
                              // color: _getStatusColor(
                              //   leadDetails?.leadStageId?.name,
                              // ),
                              color: _hexToColor(
                                leadDetails?.leadStageId?.color,
                              ),
                              // onTap: () => StatusChangePopup.show(context),
                            ),
                          ),
                          const SizedBox(width: 12),
                          if (leadDetails?.priority != null &&
                              leadDetails!.priority!.isNotEmpty)
                            Expanded(
                              child: _buildInfoCard(
                                title: "Priority",
                                value: leadDetails.priority ?? "no priority",
                                color: _getPriorityColor(leadDetails.priority),
                                // onTap: () => showCategoryChangePopup(context),
                              ),
                            ),
                        ],
                      ),
                    ),

                    // Contact Information Section
                    _buildSection(
                      title: "Contact Information",
                      children: [
                        if (leadDetails?.phone != null)
                          _buildInfoRow(
                            icon: Icons.phone,
                            label: "Phone",
                            value:
                                leadDetails?.phone?.toString() ??
                                "Not Provided",
                          ),
                        if (leadDetails?.email != '')
                          _buildInfoRow(
                            icon: Icons.email,
                            label: "Email",
                            value: leadDetails?.email ?? "Not Provided",
                          ),
                        if (leadDetails?.address != '')
                          _buildInfoRow(
                            icon: Icons.location_on,
                            label: "Address",
                            value: leadDetails?.address ?? "Not Provided",
                          ),
                        if (leadDetails?.pincode != null)
                          _buildInfoRow(
                            icon: Icons.pin_drop,
                            label: "Pin Code",
                            value:
                                leadDetails?.pincode.toString() ?? 'no pincode',
                          ),
                      ],
                    ),

                    // Lead Details Section
                    _buildSection(
                      title: "Lead Details",
                      children: [
                        _buildDetailRow(
                          "Source",
                          leadDetails?.leadSourceId?.name,
                        ),
                        _buildDetailRow(
                          "Stage",
                          leadDetails?.leadStageId?.name,
                        ),
                        _buildDetailRow(
                          "Assigned To",
                          leadDetails?.assignedTo?.name,
                        ),
                        _buildDetailRow("Gender", leadDetails?.gender),
                        _buildDetailRow("Remarks", leadDetails?.remarks),
                        if (leadDetails?.name?.middle != null)
                          _buildDetailRow(
                            "Middle Name",
                            leadDetails?.name?.middle,
                          ),
                        _buildDetailRow(
                          "Company Name",
                          leadDetails?.companyName,
                        ),
                        _buildDetailRow(
                          "Designation",
                          leadDetails?.designation,
                        ),
                        if (leadDetails?.compaignName?.name != null)
                          _buildDetailRow(
                            "Campaign",
                            leadDetails?.compaignName?.name,
                          ),
                      ],
                    ),

                    /// Additional Info Section
                    // _buildSection(
                    //   title: "Additional Information",
                    //   children: [
                    //     Container(
                    //       padding: const EdgeInsets.all(16),
                    //       decoration: BoxDecoration(
                    //         color: Colors.grey.shade50,
                    //         borderRadius: BorderRadius.circular(10),
                    //       ),
                    //       child: Column(
                    //         children: [
                    //           SvgPicture.asset(
                    //             "assets/svgs/share.svg",
                    //             height: 80,
                    //           ),
                    //           const SizedBox(height: 12),
                    //           const Text(
                    //             "Share project details with client",
                    //             style: TextStyle(
                    //               fontWeight: FontWeight.w600,
                    //               color: Colors.grey,
                    //             ),
                    //           ),
                    //           const SizedBox(height: 12),
                    //           ElevatedButton(
                    //             onPressed: () {},
                    //             style: ElevatedButton.styleFrom(
                    //               backgroundColor:
                    //                   ColorConstants.MainPurpleBackground,
                    //               shape: RoundedRectangleBorder(
                    //                 borderRadius: BorderRadius.circular(8),
                    //               ),
                    //               padding: const EdgeInsets.symmetric(
                    //                 horizontal: 24,
                    //                 vertical: 12,
                    //               ),
                    //             ),
                    //             child: const Text(
                    //               "Share Details",
                    //               style: TextStyle(color: Colors.white),
                    //             ),
                    //           ),
                    //         ],
                    //       ),
                    //     ),
                    //   ],
                    // ),

                    /// Activity Section
                    // _buildSection(
                    //   title: "Recent Activity",
                    //   children: [
                    //     _buildActivityTile(
                    //       icon: Icons.phone,
                    //       title: "Outgoing Call",
                    //       subtitle: "22nd March, 12:00 PM • 5m 6s",
                    //       time: "2 days ago",
                    //     ),
                    //     _buildActivityTile(
                    //       icon: Icons.note,
                    //       title: "Note Added",
                    //       subtitle: "Client interested in 1BHK",
                    //       time: "1 week ago",
                    //     ),
                    //     TextButton(
                    //       onPressed: () => Get.to(ActivityPage()),
                    //       child: Row(
                    //         mainAxisAlignment: MainAxisAlignment.center,
                    //         children: [
                    //           Text(
                    //             "View All Activity",
                    //             style: TextStyle(
                    //               color: ColorConstants.MainPurpleBackground,
                    //               fontWeight: FontWeight.w600,
                    //             ),
                    //           ),
                    //           const SizedBox(width: 4),
                    //           Icon(
                    //             Icons.arrow_forward,
                    //             size: 16,
                    //             color: ColorConstants.MainPurpleBackground,
                    //           ),
                    //         ],
                    //       ),
                    //     ),
                    //   ],
                    // ),

                    /// Notes Section
                    // _buildSection(
                    //   title: "Notes",
                    //   children: [
                    //     Container(
                    //       padding: const EdgeInsets.all(16),
                    //       decoration: BoxDecoration(
                    //         color: Colors.grey.shade50,
                    //         borderRadius: BorderRadius.circular(10),
                    //       ),
                    //       child: Column(
                    //         crossAxisAlignment: CrossAxisAlignment.start,
                    //         children: [
                    //           Row(
                    //             children: [
                    //               CircleAvatar(
                    //                 backgroundColor: Colors.green.shade400,
                    //                 child: const Text(
                    //                   "SV",
                    //                   style: TextStyle(
                    //                     color: Colors.white,
                    //                     fontWeight: FontWeight.bold,
                    //                   ),
                    //                 ),
                    //               ),
                    //               const SizedBox(width: 12),
                    //               Expanded(
                    //                 child: Column(
                    //                   crossAxisAlignment:
                    //                       CrossAxisAlignment.start,
                    //                   children: [
                    //                     Text(
                    //                       "Atlanta Customer Data",
                    //                       style: const TextStyle(
                    //                         fontWeight: FontWeight.w600,
                    //                       ),
                    //                     ),
                    //                     Text(
                    //                       "Lead Note • 1 mo ago",
                    //                       style: TextStyle(
                    //                         color: Colors.grey.shade600,
                    //                         fontSize: 12,
                    //                       ),
                    //                     ),
                    //                   ],
                    //                 ),
                    //               ),
                    //             ],
                    //           ),
                    //           const SizedBox(height: 12),
                    //           Text(
                    //             "Client koparkhairane me rehta hai 1 bhk main dekh toh raha hai",
                    //             style: TextStyle(color: Colors.grey.shade800),
                    //           ),
                    //           const SizedBox(height: 16),
                    //           Container(
                    //             padding: const EdgeInsets.all(12),
                    //             decoration: BoxDecoration(
                    //               color: Colors.white,
                    //               borderRadius: BorderRadius.circular(8),
                    //               border: Border.all(
                    //                 color: Colors.grey.shade300,
                    //               ),
                    //             ),
                    //             child: Row(
                    //               children: [
                    //                 Icon(
                    //                   Icons.add,
                    //                   color: Colors.grey.shade600,
                    //                 ),
                    //                 const SizedBox(width: 8),
                    //                 Text(
                    //                   "Add a Note",
                    //                   style: TextStyle(
                    //                     color: Colors.grey.shade600,
                    //                     fontWeight: FontWeight.w500,
                    //                   ),
                    //                 ),
                    //               ],
                    //             ),
                    //           ),
                    //         ],
                    //       ),
                    //     ),
                    //   ],
                    // ),

                    /// Transfer Lead Button
                    // Container(
                    //   margin: const EdgeInsets.all(16),
                    //   child: OutlinedButton(
                    //     onPressed: () {},
                    //     style: OutlinedButton.styleFrom(
                    //       side: BorderSide(
                    //         color: ColorConstants.MainPurpleBackground,
                    //         width: 2,
                    //       ),
                    //       padding: const EdgeInsets.symmetric(vertical: 16),
                    //       shape: RoundedRectangleBorder(
                    //         borderRadius: BorderRadius.circular(10),
                    //       ),
                    //     ),
                    //     child: SizedBox(
                    //       width: double.infinity,
                    //       child: Center(
                    //         child: Text(
                    //           "Transfer Lead",
                    //           style: TextStyle(
                    //             color: ColorConstants.MainPurpleBackground,
                    //             fontWeight: FontWeight.w600,
                    //             fontSize: 16,
                    //           ),
                    //         ),
                    //       ),
                    //     ),
                    //   ),
                    // ),

                    // const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  // Helper Widgets
  Widget _buildActionButton(IconData icon, String label, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey.shade700,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard({
    required String title,
    required String value,
    required Color color,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    value,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                // Icon(
                //   Icons.arrow_forward_ios,
                //   size: 14,
                //   color: Colors.grey.shade400,
                // ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.black87,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(children: children),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.grey.shade600, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
          if (value != "")
            IconButton(
              icon: Icon(Icons.copy, size: 18, color: Colors.grey.shade500),
              onPressed: () {
                _copyToClipboard(value, label);
              },
            ),
        ],
      ),
    );
  }

  // Add this method to copy text to clipboard
  void _copyToClipboard(String text, String label) {
    Clipboard.setData(ClipboardData(text: text));

    // Show a snackbar or toast to confirm
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$label copied to clipboard'),
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Widget _buildDetailRow(String label, String? value) {
    if (value == null || value.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required String time,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 20, color: Colors.grey.shade600),
      ),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            subtitle,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
          ),
          Text(
            time,
            style: TextStyle(color: Colors.grey.shade500, fontSize: 11),
          ),
        ],
      ),
      trailing: Icon(Icons.chevron_right, color: Colors.grey.shade400),
    );
  }

  // Helper methods for colors
  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'Follow Up':
        return Colors.black;
      case 'warm':
        return Colors.orange;
      case 'cold':
        return Colors.blue;
      case 'converted':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  // Color _hexToColor(String? hex) {
  //   hex = hex?.replaceAll('#', '');
  //   return Color(int.parse('FF$hex', radix: 16));
  // }

  Color _hexToColor(String? hex) {
    if (hex == null || hex.isEmpty) {
      return Colors.grey; // fallback color
    }

    hex = hex.replaceAll('#', '');

    try {
      return Color(int.parse('FF$hex', radix: 16));
    } catch (_) {
      return Colors.grey;
    }
  }

  Color _getPriorityColor(String? priority) {
    switch (priority?.toLowerCase()) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      case 'low':
        return Colors.green;
      default:
        return Colors.blue;
    }
  }
}
