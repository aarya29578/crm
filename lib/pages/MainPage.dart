import 'package:crm_flutter/local_storage/local_storage.dart';
import 'package:crm_flutter/pages/Allocations/components/custom_chip.dart';
import 'package:crm_flutter/pages/lead_details/LeadDetailsPage.dart';
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
  final Claimedcontroller ccontroller = Get.put(Claimedcontroller());
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    homeController.getAllLeadStage().then((_) {
      // Load initial leads if not on Home tab
      if (_selectedIndex > 0) {
        _loadLeadsForSelectedTab();
      }
    });
  }

  void _loadLeadsForSelectedTab() {
    final stages = homeController.allLeadStageRes.value.data ?? [];
    if (_selectedIndex - 1 < stages.length) {
      final stageId = stages[_selectedIndex - 1].sId ?? '';
      ccontroller.getLeadbyStage(stageId);
    }
  }

  final userName = LocalStorage.sharedPreferences?.getString('user_name');
  final campaign = LocalStorage.sharedPreferences?.getString('user_campaign');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConstants.MainPurpleBackground.withValues(
        alpha: 0.5,
      ),
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('Welcome'),
                SizedBox(width: 7),
                Text(
                  (userName == null || userName!.isEmpty)
                      ? "User!"
                      : "$userName!",
                ),
              ],
            ),
            Text(
              (campaign == null || campaign!.isEmpty)
                  ? "→ no campaign name!"
                  : "→ $campaign",
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w400),
            ),
          ],
        ),
        titleTextStyle: TextStyle(
          fontSize: 21,
          color: Colors.white,
          fontWeight: FontWeight.w700,
        ),
        backgroundColor: ColorConstants.MainPurpleBackground,
        // toolbarHeight: 20,
      ),
      body: Container(
        color: Colors.white,
        child: Column(
          children: [
            // Tab selector
            FutureBuilder(
              future: homeController.getAllLeadStage(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const SizedBox(
                    height: 50,
                    child: Center(child: Text('Error loading stages')),
                  );
                }

                final stages = homeController.allLeadStageRes.value.data ?? [];

                return SizedBox(
                  height: 50,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    scrollDirection: Axis.horizontal,
                    itemCount: stages.length + 1,
                    itemBuilder: (context, index) {
                      final isHomeTab = index == 0;
                      final isSelected = _selectedIndex == index;

                      return buildCustomChip(
                        text: isHomeTab
                            ? 'Home'
                            : stages[index - 1].name ?? 'Unknown',
                        isSelected: _selectedIndex == index,
                        onTap: () {
                          setState(() {
                            _selectedIndex = index;
                            if (index > 0) _loadLeadsForSelectedTab();
                          });
                        },
                      );
                    },
                  ),
                );
              },
            ),

            // Content area
            Expanded(child: _buildContent()),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_selectedIndex == 0) {
      return HomePage();
    }

    final stages = homeController.allLeadStageRes.value.data ?? [];
    if (_selectedIndex - 1 >= stages.length) {
      return const Center(child: Text('Invalid selection'));
    }

    return Obx(() {
      if (ccontroller.stateload.value == PageState.loading) {
        return Column(
          children: List.generate(
            3, // Number of shimmer cards to show
            (index) => ClaimedLeadCardShimmer(),
          ),
        );
      }

      if (ccontroller.getLeadByStageRes.value.leadDetails?.isEmpty ?? true) {
        return const Center(child: Text('No Leads'));
      }

      return SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              color: Colors.grey.shade200,
              padding: const EdgeInsets.only(left: 20, top: 10, bottom: 10),
              child: Text(
                "${ccontroller.getLeadByStageRes.value.leadDetails?.length ?? 0} Leads",
                style: greyHeading,
              ),
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount:
                  ccontroller.getLeadByStageRes.value.leadDetails?.length ?? 0,
              itemBuilder: (context, index) {
                final data =
                    ccontroller.getLeadByStageRes.value.leadDetails![index];
                return GestureDetector(
                  onTap: () {
                    String LeadId = data.sId!;
                    print("*********************************** " + LeadId);
                    Get.to(LeadDetailsBottomNavigationBarPage(LeadID: LeadId));
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
                  ),
                );
              },
            ),
          ],
        ),
      );
    });
  }
}
