import 'package:crm_flutter/api/dio_api.dart';
import 'package:crm_flutter/pages/profile_menu/template_list_page.dart';
import 'package:crm_flutter/widgets/show_call_alert_dialog.dart';
import 'package:flutter/material.dart';
import 'package:crm_flutter/local_storage/local_storage.dart';
import 'package:crm_flutter/pages/Auth/LoginPage.dart';
import 'package:crm_flutter/styles/color_palette.dart';
import 'package:get/get.dart';

class ProfileMenuPage extends StatelessWidget {
  const ProfileMenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConstants.MainPurpleBackground.withValues(
        alpha: 0.06,
      ),

      appBar: AppBar(
        title: const Text(
          "Account",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        backgroundColor: ColorConstants.MainPurpleBackground,
      ),

      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),

        child: SafeArea(
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 18,
                ),

                decoration: const BoxDecoration(color: Colors.white),

                child: Row(
                  children: [
                    // Profile Avatar
                    Container(
                      width: 60,
                      height: 60,

                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF2196F3).withOpacity(0.1),

                        border: Border.all(
                          color: const Color(0xFF2196F3).withOpacity(0.3),
                          width: 2,
                        ),
                      ),

                      child: Center(
                        child: Text(
                          (LocalStorage.sharedPreferences!.getString(
                                    'user_name',
                                  )?[0] ??
                                  "U")
                              .toUpperCase(),

                          style: const TextStyle(
                            color: Color(0xFF2196F3),
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 16),

                    // User Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,

                        children: [
                          Text(
                            LocalStorage.sharedPreferences!.getString(
                                  'user_name',
                                ) ??
                                "User",

                            style: const TextStyle(
                              color: Color(0xFF2B2B2B),
                              fontWeight: FontWeight.w600,
                              fontSize: 20,
                            ),
                          ),

                          const SizedBox(height: 5),

                          Row(
                            children: [
                              const Icon(
                                Icons.phone_outlined,
                                size: 16,
                                color: Color(0xFF949393),
                              ),

                              const SizedBox(width: 6),

                              Text(
                                (LocalStorage.sharedPreferences!.getInt(
                                          'phone_number',
                                        ) ??
                                        "no number found")
                                    .toString(),

                                style: const TextStyle(
                                  color: Color(0xFF949393),
                                  fontWeight: FontWeight.w500,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 10,
                ),

                decoration: const BoxDecoration(color: Colors.white),

                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      height: 75,

                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(14),

                        border: Border.all(
                          color: Colors.blue.shade200,
                          width: 1,
                        ),
                      ),

                      child: Material(
                        color: Colors.transparent,

                        child: InkWell(
                          borderRadius: BorderRadius.circular(14),

                          onTap: () {
                            Get.to(() => TemplateListPage());
                          },

                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 18),

                            child: Row(
                              children: [
                                // Template Icon
                                Container(
                                  width: 48,
                                  height: 48,

                                  decoration: BoxDecoration(
                                    color: Colors.blue.shade100,
                                    borderRadius: BorderRadius.circular(12),
                                  ),

                                  child: Icon(
                                    Icons.description_outlined,
                                    color: Colors.blue.shade700,
                                    size: 27,
                                  ),
                                ),

                                const SizedBox(width: 15),

                                // Template Text
                                const Expanded(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,

                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,

                                    children: [
                                      Text(
                                        "Templates",
                                        style: TextStyle(
                                          fontSize: 17,
                                          fontWeight: FontWeight.w700,
                                          color: Color(0xFF1F2937),
                                        ),
                                      ),

                                      SizedBox(height: 3),

                                      Text(
                                        "Manage message templates",
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Color(0xFF6B7280),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // Arrow
                                Icon(
                                  Icons.arrow_forward_ios_rounded,
                                  size: 18,
                                  color: Colors.blue,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    Container(
                      width: double.infinity,
                      height: 60,

                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(14),

                        border: Border.all(color: Colors.red.shade100),
                      ),

                      child: Material(
                        color: Colors.transparent,

                        child: InkWell(
                          borderRadius: BorderRadius.circular(14),

                          onTap: () {
                            showCallAlertDialog(
                              context,
                              'Logout!',
                              'Are you sure want to logout?',

                              () async {
                                await DioApi().logout();

                                await LocalStorage.sharedPreferences!.clear();

                                await Get.offAll(LoginPage());
                              },

                              Colors.red,
                            );
                          },

                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 18),

                            child: Row(
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,

                                  decoration: BoxDecoration(
                                    color: Colors.red.shade100,
                                    borderRadius: BorderRadius.circular(10),
                                  ),

                                  child: Icon(
                                    Icons.logout_rounded,
                                    color: Colors.red.shade700,
                                    size: 22,
                                  ),
                                ),

                                const SizedBox(width: 15),

                                const Expanded(
                                  child: Text(
                                    "Logout",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFFDC2626),
                                    ),
                                  ),
                                ),

                                Icon(
                                  Icons.arrow_forward_ios_rounded,
                                  size: 16,
                                  color: Colors.red,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    
              ),
            ],
          ),
        ),
      ),
    );
  }
}
