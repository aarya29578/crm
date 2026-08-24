import 'package:flutter/material.dart';

import 'package:crm_flutter/pages/follow_up/TodayFollowUpController.dart';
import 'package:crm_flutter/styles/color_palette.dart';
import 'package:crm_flutter/styles/text_styles.dart';
import 'package:crm_flutter/widgets/FollowUpCard.dart';
import 'package:get/get.dart';

class TodayFollowUpPage extends StatelessWidget {
  TodayFollowUpPage({super.key});

  final TodayFollowUpController controller = Get.put(TodayFollowUpController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: ColorConstants.MainPurpleBackground,
        title: const Text("TODAY", style: TextStyle(color: Colors.white)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Obx(
              () => Text(
                "${controller.followUpSummary.length} Follow ups",
                style: greenHeading,
              ),
            ),

            const SizedBox(height: 20),

            Expanded(
              child: Obx(
                () => ListView.separated(
                  physics: const AlwaysScrollableScrollPhysics(),
                  separatorBuilder: (context, index) {
                    return const SizedBox(height: 10);
                  },
                  itemBuilder: (context, index) {
                    final item = controller.followUpSummary[index];

                    return FollowUpCard(item['name'], item['time']);
                  },
                  itemCount: controller.followUpSummary.length,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
