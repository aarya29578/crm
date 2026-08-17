import 'package:crm_flutter/local_storage/local_storage.dart';
import 'package:crm_flutter/pages/Allocations/components/custom_chip.dart';
import 'package:crm_flutter/pages/home/components/campaign_multiselect_dialog.dart';
import 'package:crm_flutter/utils/timeago.dart';
import 'package:flutter/material.dart';
import 'package:crm_flutter/models/enums.dart';
import 'package:crm_flutter/pages/bottom_navigation_bar/LeadDetailsBottomNavigationBarPage.dart';
import 'package:crm_flutter/pages/claimed/ClaimedController.dart';
import 'package:crm_flutter/pages/home/HomeController.dart';
import 'package:crm_flutter/pages/home/HomePage.dart';
import 'package:crm_flutter/styles/color_palette.dart';
import 'package:crm_flutter/styles/text_styles.dart';
import 'package:crm_flutter/widgets/ClaimedLeadCard.dart';
import 'package:crm_flutter/widgets/lead_shimmer_card.dart';
import 'package:get/get.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final HomeController homeController = Get.put(HomeController());
  final Claimedcontroller controller = Get.put(Claimedcontroller());

  @override
  void initState() {
    super.initState();
    homeController.getAllLeadStage();
  }

  final userName = LocalStorage.sharedPreferences?.getString('user_name');
  final campaign = LocalStorage.sharedPreferences?.getString('user_campaign');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConstants.MainPurpleBackground.withValues(
        alpha: 0.06,
      ),
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('Welcome'),
                SizedBox(width: 7),
                Flexible(
                  child: Text(
                    (userName == null || userName!.isEmpty)
                        ? "User!"
                        : "$userName!",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            Obx(() {
              final selected = homeController.selectedCampaigns;
              String displayString;
              if (selected.isEmpty) {
                displayString = "→ All Campaigns";
              } else {
                displayString = "→ ${selected.map((c) => c.name).join(', ')}";
              }
              return Text(
                displayString,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              );
            }),
          ],
        ),
        titleTextStyle: TextStyle(
          fontSize: 21,
          color: Colors.white,
          fontWeight: FontWeight.w700,
        ),
        backgroundColor: ColorConstants.MainPurpleBackground,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () async {
              try {
                await homeController.getAllLeadStage();
                await homeController.getAllLeads();

                if (homeController.mainSelectedIndices.contains(0)) {
                  await homeController.selectTimeRange(
                    homeController.selectedTimeRange.value,
                    context,
                  );
                } else {
                  homeController.loadLeadsForSelectedTab(controller);
                }
              } catch (e) {
                Get.snackbar(
                  "Error",
                  "Failed to refresh: $e",
                  snackPosition: SnackPosition.TOP,
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                );
              }
            },
          ),
          Obx(() {
            final count = homeController.selectedCampaigns.length;
            return Stack(
              alignment: Alignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.filter_list, color: Colors.white),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => const CampaignMultiSelectDialog(),
                    );
                  },
                ),
                if (count > 0)
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        '$count',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            );
          }),
        ],
      ),
      body: Container(
        color: Colors.transparent,
        child: Column(
          children: [
            // Tab selector
            Obx(() {
              if (homeController.countLoading.value == PageState.loading) {
                return const SizedBox(
                  height: 50,
                  child: Center(
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                );
              }

              final stages = homeController.allLeadStageRes.value.data ?? [];

              if (stages.isEmpty) {
                return const SizedBox(
                  height: 50,
                  child: Center(child: Text('No stages found')),
                );
              }

              // Register observable changes
              final currentSelections = homeController.mainSelectedIndices
                  .toList();

              return SizedBox(
                height: 50,
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  scrollDirection: Axis.horizontal,
                  itemCount: stages.length + 1,
                  itemBuilder: (context, index) {
                    final isHomeTab = index == 0;
                    final isSelected = currentSelections.contains(index);

                    return buildCustomChip(
                      text: isHomeTab
                          ? 'Home'
                          : stages[index - 1].name ?? 'Unknown',
                      isSelected: isSelected,
                      onTap: () {
                        if (index == 0) {
                          // Select only Home
                          homeController.mainSelectedIndices
                            ..clear()
                            ..add(0);
                        } else {
                          // Remove Home selection
                          homeController.mainSelectedIndices.remove(0);

                          if (homeController.mainSelectedIndices.contains(
                            index,
                          )) {
                            homeController.mainSelectedIndices.remove(index);

                            // If no stage selected, go back to Home
                            if (homeController.mainSelectedIndices.isEmpty) {
                              homeController.mainSelectedIndices.add(0);
                            }
                          } else {
                            homeController.mainSelectedIndices.add(index);
                          }
                        }

                        if (!homeController.mainSelectedIndices.contains(0)) {
                          homeController.loadLeadsForSelectedTab(controller);
                        }
                      },
                    );
                  },
                ),
              );
            }),
            const SizedBox(
              height: 12,
            ), // Gap between status chips and date filter
            // Content area
            Expanded(child: _buildContent()),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    return Obx(() {
      if (homeController.mainSelectedIndices.contains(0)) {
        return HomePage();
      }

      final stages = homeController.allLeadStageRes.value.data ?? [];
      // Validation check for invalid selection
      bool hasValidSelection = false;
      for (int index in homeController.mainSelectedIndices) {
        if (index > 0 && index - 1 < stages.length) {
          hasValidSelection = true;
          break;
        }
      }

      if (!hasValidSelection) {
        return const Center(child: Text('Invalid selection'));
      }

      if (controller.stateload.value == PageState.loading) {
        return Column(
          children: List.generate(
            3, // Number of shimmer cards to show
            (index) => ClaimedLeadCardShimmer(),
          ),
        );
      }

      if (controller.getLeadByStageRes.value.leadDetails?.isEmpty ?? true) {
        return RefreshIndicator(
          onRefresh: () async {
            try {
              await homeController.getAllLeadStage();
              homeController.loadLeadsForSelectedTab(controller);
            } catch (e) {
              // print("Error refreshing stage: $e");
            }
          },
          child: const SingleChildScrollView(
            physics: AlwaysScrollableScrollPhysics(),
            child: SizedBox(
              height: 200,
              child: Center(child: Text('No Leads')),
            ),
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: () async {
          try {
            await homeController.getAllLeadStage();
            homeController.loadLeadsForSelectedTab(controller);
          } catch (e) {
            // print("Error refreshing stage: $e");
          }
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                color: Colors.grey.shade200,
                padding: const EdgeInsets.only(left: 20, top: 10, bottom: 10),
                child: Text(
                  "${controller.getLeadByStageRes.value.leadDetails?.length ?? 0} Leads",
                  style: greyHeading,
                ),
              ),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount:
                    controller.getLeadByStageRes.value.leadDetails?.length ??
                    0,
                itemBuilder: (context, index) {
                  final data =
                      controller.getLeadByStageRes.value.leadDetails![index];
                  return GestureDetector(
                    onTap: () {
                      String LeadId = data.sId!;
                      // print("*********************************** $LeadId");
                      Get.to(
                        LeadDetailsBottomNavigationBarPage(LeadID: LeadId),
                      );
                      // Get.to(LeadDetailsPage(leadId: LeadId));
                    },
                    child: ClaimedLeadCard(
                      context,
                      timeAgo(data.createdAt ?? ""),
                      "${data.name?.first} ${data.name?.last}",
                      data.phone ?? 'no number found',
                      data.leadSourceId?.name ?? "no name",
                      data.assignedTo?.name ?? "not assigned",
                      data.compaignName?.name ?? "no Campaign found!",
                      data.sId,
                      data.email ?? "no email",
                      data.followUpDate,
                      data.stageFieldValues,
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      );
    });
  }
}
