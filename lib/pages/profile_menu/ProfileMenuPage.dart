import 'package:crm_flutter/api/dio_api.dart';
import 'package:crm_flutter/widgets/show_call_alert_dialog.dart';
import 'package:flutter/material.dart';
import 'package:crm_flutter/local_storage/local_storage.dart';
import 'package:crm_flutter/pages/Auth/LoginPage.dart';
import 'package:crm_flutter/pages/Call/Call_Logs.dart';
import 'package:crm_flutter/pages/Organizations/organizations_page.dart';
import 'package:crm_flutter/pages/Persons/persons_page.dart';
import 'package:crm_flutter/pages/Products/products_page.dart';
import 'package:crm_flutter/pages/Quotes/quotes_page.dart';
import 'package:crm_flutter/pages/Settings/settings_page.dart';
import 'package:crm_flutter/pages/all_project/AllProjectPage.dart';
import 'package:crm_flutter/pages/calls_history/CallsHistoryPage.dart';
import 'package:crm_flutter/styles/color_palette.dart';
import 'package:crm_flutter/styles/text_styles.dart';
import 'package:crm_flutter/widgets/IconTileRowCard.dart';
import 'package:get/get.dart';

class ProfileMenuPage extends StatelessWidget {
  const ProfileMenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ValueNotifier<bool> isSwitched = ValueNotifier(true);
    return Scaffold(
      //appBar: AppBar(backgroundColor: ColorConstants.MainPurpleBackground),
      backgroundColor: ColorConstants.MainPurpleBackground.withValues(
        alpha: 0.06,
      ),
      appBar: AppBar(
        title: Text(
          "Account",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        backgroundColor: ColorConstants.MainPurpleBackground,
      ),

      // Top Name container
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: SafeArea(
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top + 1,
                  left: MediaQuery.of(context).padding.left + 20,
                  bottom: MediaQuery.of(context).padding.bottom + 5,
                ),
                width: double.infinity,
                decoration: BoxDecoration(color: Colors.white),

                child:
                    // Profile Card
                    Row(
                      children: [
                        // Profile Avatar
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0xFF2196F3).withOpacity(0.1),
                            border: Border.all(
                              color: Color(0xFF2196F3).withOpacity(0.3),
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
                              style: TextStyle(
                                color: Color(0xFF2196F3),
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 16),
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
                                style: TextStyle(
                                  color: const Color(0xFF2B2B2B),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 20,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(
                                    Icons.phone_outlined,
                                    size: 16,
                                    color: Color(0xFF949393),
                                  ),
                                  SizedBox(width: 6),
                                  Text(
                                    (LocalStorage.sharedPreferences!.getInt(
                                              'phone_number',
                                            ) ??
                                            "no number found")
                                        .toString(),
                                    style: TextStyle(
                                      color: const Color(0xFF949393),
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

                // Column(
                //   crossAxisAlignment: CrossAxisAlignment.start,
                //   children: [
                //     Text(
                //       LocalStorage.sharedPreferences!.getString('user_name') ??
                //           "User", // Fallback to "User" if name is null
                //       style: TextStyle(
                //         color: const Color.fromARGB(221, 43, 43, 43),
                //         fontWeight: FontWeight.bold,
                //         letterSpacing: 0,
                //         fontSize: 22,
                //       ),
                //     ),
                //     Text(
                //       (
                //         LocalStorage.sharedPreferences!.getInt(
                //               'phone_number',
                //             ) ??
                //             "no number found",
                //       ).toString(),
                //       style: TextStyle(
                //         color: const Color.fromARGB(221, 148, 147, 147),
                //         fontWeight: FontWeight.bold,
                //         letterSpacing: 0,
                //         fontSize: 14,
                //       ),
                //     ),
                //     SizedBox(height: 10),
                //     // Row(
                //     //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //     //   children: [
                //     //     Expanded(
                //     //       child: Text(
                //     //         "Currently you are",
                //     //         style: blackSmallTitle,
                //     //       ),
                //     //     ),
                //     //     ValueListenableBuilder<bool>(
                //     //       valueListenable: isSwitched,
                //     //       builder: (context, value, child) {
                //     //         return Row(
                //     //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //     //           children: [
                //     //             Text(
                //     //               value
                //     //                   ? 'Active'
                //     //                   : 'Inactive', // Text changes based on state
                //     //               style: TextStyle(
                //     //                 color: value
                //     //                     ? Colors.green
                //     //                     : Colors.grey, // Green when active
                //     //                 fontSize: 14,
                //     //                 fontWeight: FontWeight.w500,
                //     //               ),
                //     //             ),
                //     //             SizedBox(width: 8),

                //     //             Transform.scale(
                //     //               scale: 0.7,
                //     //               child: Switch(
                //     //                 value: value,
                //     //                 onChanged: (newValue) =>
                //     //                     isSwitched.value = newValue,
                //     //                 activeColor: Colors
                //     //                     .white, // Makes the switch thumb green when on
                //     //                 activeTrackColor:
                //     //                     Colors.green, // Lighter green track
                //     //               ),
                //     //             ),
                //     //           ],
                //     //         );
                //     //       },
                //     //     ),
                //     //   ],
                //     // ),
                //   ],
                // ),
              ),

              // const SizedBox(height: 10),

              // Container(
              //   padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
              //   margin: EdgeInsets.symmetric(vertical: 1),
              //   width: double.infinity,
              //   decoration: BoxDecoration(
              //     color:
              //         // ColorConstants.MainPurpleBackground.withValues(
              //         //   alpha: 0.06,
              //         // ),
              //         Colors.white,
              //   ),

              //   child: Column(
              //     children: [
              //       IconTileRow(Icons.people, Colors.blue, "Persons", () {
              //         Get.to(PersonsPage());
              //       }),

              //       SizedBox(
              //         height: 1,
              //         width: double.infinity,
              //         child: const DecoratedBox(
              //           decoration: BoxDecoration(
              //             color: Color.fromARGB(255, 224, 224, 224),
              //           ),
              //         ),
              //       ),
              //       // const SizedBox(height: 10),
              //       IconTileRow(
              //         Icons.business_center,
              //         Colors.deepPurple,
              //         "Organizations",
              //         () {
              //           Get.to(OrganizationsPage());
              //         },
              //       ),

              //       SizedBox(
              //         height: 1,
              //         width: double.infinity,
              //         child: const DecoratedBox(
              //           decoration: BoxDecoration(
              //             color: Color.fromARGB(255, 224, 224, 224),
              //           ),
              //         ),
              //       ),
              //       // const SizedBox(height: 10),
              //       IconTileRow(
              //         Icons.edit_document,
              //         Colors.deepOrange,
              //         "Quotes",
              //         () {
              //           Get.to(QuotesPage());
              //         },
              //       ),

              //       SizedBox(
              //         height: 1,
              //         width: double.infinity,
              //         child: const DecoratedBox(
              //           decoration: BoxDecoration(
              //             color: Color.fromARGB(255, 224, 224, 224),
              //           ),
              //         ),
              //       ),
              //       // const SizedBox(height: 10),
              //       IconTileRow(Icons.card_travel, Colors.pink, "Products", () {
              //         Get.to(ProductsPage());
              //       }),

              //       SizedBox(
              //         height: 1,
              //         width: double.infinity,
              //         child: const DecoratedBox(
              //           decoration: BoxDecoration(
              //             color: Color.fromARGB(255, 224, 224, 224),
              //           ),
              //         ),
              //       ),
              //       // const SizedBox(height: 10),
              //       IconTileRow(
              //         Icons.business,
              //         const Color.fromARGB(255, 3, 74, 197),
              //         "Projects",
              //         () {},
              //       ),

              //       SizedBox(
              //         height: 1,
              //         width: double.infinity,
              //         child: const DecoratedBox(
              //           decoration: BoxDecoration(
              //             color: Color.fromARGB(255, 224, 224, 224),
              //           ),
              //         ),
              //       ),
              //       // const SizedBox(height: 10),
              //       IconTileRow(
              //         Icons.auto_graph_outlined,
              //         Colors.amber,
              //         "Your Stats",

              //         () {
              //           Get.to(AllProjectPage());
              //         },
              //       ),

              //       SizedBox(
              //         height: 1,
              //         width: double.infinity,
              //         child: const DecoratedBox(
              //           decoration: BoxDecoration(
              //             color: Color.fromARGB(255, 224, 224, 224),
              //           ),
              //         ),
              //       ),
              //       // const SizedBox(height: 10),
              //       IconTileRow(
              //         Icons.business,
              //         ColorConstants.MainPurpleBackground,
              //         "Expense Reimbursements",
              //         () {},
              //       ),

              //       SizedBox(
              //         height: 1,
              //         width: double.infinity,
              //         child: const DecoratedBox(
              //           decoration: BoxDecoration(
              //             color: Color.fromARGB(255, 224, 224, 224),
              //           ),
              //         ),
              //       ),
              //       // const SizedBox(height: 10),
              //       IconTileRow(
              //         Icons.business,
              //         const Color.fromARGB(255, 3, 75, 134),
              //         "Incentives",
              //         () {},
              //       ),

              //       SizedBox(
              //         height: 1,
              //         width: double.infinity,
              //         child: const DecoratedBox(
              //           decoration: BoxDecoration(
              //             color: Color.fromARGB(255, 224, 224, 224),
              //           ),
              //         ),
              //       ),
              //       // const SizedBox(height: 10),
              //       IconTileRow(Icons.call, Colors.red, "Call Logs", () {
              //         Get.to(CallLogs());
              //       }),
              //     ],
              //   ),
              // ),
              // SizedBox(height: 10),

              // Second container
              Container(
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                width: double.infinity,
                decoration: BoxDecoration(
                  color:
                      // ColorConstants.MainPurpleBackground.withValues(
                      //   alpha: 0.06,
                      // ),
                      Colors.white,
                ),

                child: Column(
                  children: [
                    // IconTileRow(Icons.settings, Colors.grey, "Settings", () {
                    //   Get.to(SettingsPage());
                    // }),
                    // SizedBox(
                    //   height: 1,
                    //   width: double.infinity,
                    //   child: const DecoratedBox(
                    //     decoration: BoxDecoration(
                    //       color: Color.fromARGB(255, 224, 224, 224),
                    //     ),
                    //   ),
                    // ),
                    //const SizedBox(height: 10),
                    //const Divider(),
                    // IconTileRow(Icons.tv, Colors.grey, "Saboo", () {}),

                    // Logout Button with updated design
                    // _buildLogoutTile(),
                    SizedBox(
                      height: 1,
                      width: double.infinity,
                      child: const DecoratedBox(
                        decoration: BoxDecoration(
                          color: Color.fromARGB(255, 224, 224, 224),
                        ),
                      ),
                    ),
                    // const SizedBox(height: 10),
                    // const Divider(),
                    IconTileRow(Icons.logout_sharp, Colors.red, "Logout", () {
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
                    }),
                  ],
                ),
              ),

              //SizedBox(height: 60),
              //Spacer(),

              // Help and Support purple container
              // Container(
              //   padding: EdgeInsets.only(
              //     top: 20,
              //     left: 20,
              //     bottom: 30,
              //     right: 20,
              //   ),
              //   width: double.infinity,
              //   decoration: BoxDecoration(color: Colors.blueAccent),

              //   child: Row(
              //     crossAxisAlignment: CrossAxisAlignment.center,
              //     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              //     children: [
              //       Icon(Icons.grid_view, color: Colors.white),
              //       SizedBox(width: 5),
              //       Expanded(
              //         child: Text(
              //           "Help & Support",
              //           style: TextStyle(
              //             color: Colors.white,
              //             fontWeight: FontWeight.bold,
              //             letterSpacing: 0,
              //           ),
              //         ),
              //       ),
              //       Container(
              //         padding: EdgeInsets.only(
              //           left: 20,
              //           top: 10,
              //           bottom: 10,
              //           right: 10,
              //         ),
              //         decoration: BoxDecoration(
              //           color: Colors.white,
              //           borderRadius: BorderRadius.circular(5),
              //         ),

              //         child: InkWell(
              //           onTap: () {},
              //           child: Row(
              //             children: [
              //               Icon(Icons.email_outlined),
              //               SizedBox(width: 5),
              //               Text("Support Email", style: blackSmallTitle),
              //             ],
              //           ),
              //         ),
              //       ),
              //     ],
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
