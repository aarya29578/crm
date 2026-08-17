import 'package:crm_flutter/api/response/all_campaigns_response.dart';
import 'package:crm_flutter/models/enums.dart';
import 'package:crm_flutter/pages/home/HomeController.dart';
import 'package:crm_flutter/styles/color_palette.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CampaignMultiSelectDialog extends StatefulWidget {
  const CampaignMultiSelectDialog({super.key});

  @override
  State<CampaignMultiSelectDialog> createState() =>
      _CampaignMultiSelectDialogState();
}

class _CampaignMultiSelectDialogState extends State<CampaignMultiSelectDialog> {
  final HomeController homeController = Get.find<HomeController>();
  final TextEditingController searchController = TextEditingController();
  List<CampaignData> filteredCampaigns = [];

  @override
  void initState() {
    super.initState();
    filteredCampaigns = homeController.allCampaigns.toList();
    searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    setState(() {
      filteredCampaigns = homeController.allCampaigns
          .where(
            (c) => (c.name ?? '').toLowerCase().contains(
              searchController.text.toLowerCase(),
            ),
          )
          .toList();
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.65,
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: ColorConstants.MainPurpleBackground.withValues(
                  alpha: 0.05,
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.campaign_rounded,
                        color: ColorConstants.MainPurpleBackground,
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        "Select Campaigns",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  InkWell(
                    onTap: () => Navigator.pop(context),
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.close,
                        size: 20,
                        color: Colors.black54,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Search Bar
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: searchController,
                decoration: InputDecoration(
                  hintText: 'Search campaigns...',
                  hintStyle: TextStyle(color: Colors.grey.shade400),
                  prefixIcon: Icon(
                    Icons.search,
                    color: ColorConstants.MainPurpleBackground,
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
              ),
            ),

            // Select All
            Obx(() {
              final _ = homeController.selectedCampaigns.length;
              if (filteredCampaigns.isEmpty) return const SizedBox();

              final isAllSelected =
                  filteredCampaigns.isNotEmpty &&
                  filteredCampaigns.every(
                    (fc) => homeController.selectedCampaigns.any(
                      (sc) => sc.sId == fc.sId,
                    ),
                  );

              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                decoration: BoxDecoration(
                  color: isAllSelected
                      ? ColorConstants.MainPurpleBackground.withValues(
                          alpha: 0.1,
                        )
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isAllSelected
                        ? ColorConstants.MainPurpleBackground.withValues(
                            alpha: 0.3,
                          )
                        : Colors.grey.shade200,
                  ),
                ),
                child: CheckboxListTile(
                  activeColor: ColorConstants.MainPurpleBackground,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  title: const Text(
                    "Select All",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  value: isAllSelected,
                  onChanged: (bool? value) {
                    homeController.toggleSelectAllCampaigns(
                      filteredCampaigns,
                      context,
                    );
                  },
                  controlAffinity: ListTileControlAffinity.trailing,
                ),
              );
            }),

            // List
            Expanded(
              child: Obx(() {
                final _ = homeController.selectedCampaigns.length;

                if (homeController.campaignLoading.value == PageState.loading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (filteredCampaigns.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.inbox_outlined,
                          size: 48,
                          color: Colors.grey.shade300,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "No campaigns found",
                          style: TextStyle(color: Colors.grey.shade500),
                        ),
                      ],
                    ),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  itemCount: filteredCampaigns.length,
                  itemBuilder: (context, index) {
                    final campaign = filteredCampaigns[index];
                    final isSelected = homeController.selectedCampaigns.any(
                      (c) => c.sId == campaign.sId,
                    );

                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? ColorConstants.MainPurpleBackground.withValues(
                                alpha: 0.05,
                              )
                            : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? ColorConstants.MainPurpleBackground.withValues(
                                  alpha: 0.3,
                                )
                              : Colors.grey.shade200,
                        ),
                      ),
                      child: CheckboxListTile(
                        activeColor: ColorConstants.MainPurpleBackground,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        title: Text(
                          campaign.name ?? '',
                          style: TextStyle(
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.normal,
                            color: isSelected
                                ? ColorConstants.MainPurpleBackground
                                : Colors.black87,
                          ),
                        ),
                        value: isSelected,
                        onChanged: (bool? value) {
                          homeController.toggleCampaignSelection(
                            campaign,
                            context,
                          );
                        },
                      ),
                    );
                  },
                );
              }),
            ),

            // Footer
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    offset: const Offset(0, -4),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        side: BorderSide(color: Colors.red.shade300),
                      ),
                      onPressed: () {
                        homeController.clearCampaign(context);
                        Navigator.pop(context);
                      },
                      child: Text(
                        "Clear",
                        style: TextStyle(
                          color: Colors.red.shade600,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ColorConstants.MainPurpleBackground,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),

                      onPressed: () async {
                        await homeController.refreshAllData(context);
                        Navigator.pop(context);
                      },

                      child: const Text(
                        "Done",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
