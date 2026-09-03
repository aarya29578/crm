import 'package:crm_flutter/local_storage/up_coming_followups_controller.dart';
import 'package:crm_flutter/pages/Allocations/allocations_page.dart';
import 'package:crm_flutter/pages/Call/Call_Logs.dart';
import 'package:crm_flutter/styles/color_palette.dart';
import 'package:flutter/material.dart';
import 'package:crm_flutter/pages/MainPage.dart';
import 'package:crm_flutter/pages/profile_menu/ProfileMenuPage.dart';
import 'package:get/get.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent_bottom_nav_bar_v2.dart';

class BottomNavigationBarPage extends StatefulWidget {
  const BottomNavigationBarPage({super.key});

  @override
  State<BottomNavigationBarPage> createState() =>
      _BottomNavigationBarPageState();
}

class _BottomNavigationBarPageState extends State<BottomNavigationBarPage> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();

    // just ensure controller is initialized
    Get.put(FollowUpController());
    // NotificationService().showNotification(
    //   id: 999,
    //   title: "Test Notification",
    //   body: "If you see this, notifications work",
    // );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PersistentTabView(
        controller: PersistentTabController(initialIndex: _currentIndex),
        tabs: _buildTabs(),
        onTabChanged: (index) {
          // Force rebuild when tab changes
          WidgetsBinding.instance.addPostFrameCallback((_) {
            setState(() {
              _currentIndex = index;
            });
          });
        },
        navBarBuilder: (navBarConfig) => Style11BottomNavBar(
          navBarConfig: navBarConfig,
          navBarDecoration: NavBarDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 12,
                spreadRadius: 0,
                offset: const Offset(0, -4),
              ),
            ],
          ),
        ),
        backgroundColor: Colors.white,
        handleAndroidBackButtonPress: true,
        resizeToAvoidBottomInset: true,
        stateManagement: true,
      ),
    );
  }

  List<PersistentTabConfig> _buildTabs() {
    return [
      _buildTab(0, const MainPage(), Icons.home_outlined, Icons.home, "Home"),
      _buildTab(
        1,
        AllocationPage(),
        Icons.calendar_today_outlined,
        Icons.calendar_today,
        "Calendar",
      ),
      // _buildTab(
      //   2,
      //   const SearchPage(),
      //   Icons.search_outlined,
      //   Icons.search,
      //   "Search",
      // ),
      _buildTab(
        2,
        CallLogs(),
        Icons.wifi_calling_3_outlined,
        Icons.wifi_calling_3_sharp,
        "Alerts",
      ),
      _buildTab(
        3,
        ProfileMenuPage(),
        Icons.person_outlined,
        Icons.person,
        "Profile",
      ),
    ];
  }

  PersistentTabConfig _buildTab(
    int index,
    Widget screen,
    IconData icon,
    IconData activeIcon,
    String label,
  ) {
    final isActive = _currentIndex == index;
    final primaryColor =
        Theme.of(context).primaryColor ?? const Color(0xFF2563EB);

    return PersistentTabConfig(
      screen: screen,
      item: ItemConfig(
        icon: SizedBox(
          height: 40,
          // padding: const EdgeInsets.all(8),
          // decoration: BoxDecoration(
          //   //shape: BoxShape.circle,
          //   color: isActive
          //       ? primaryColor.withOpacity(0.1)
          //       : Colors.transparent,
          // ),
          child: Icon(
            isActive ? activeIcon : icon,
            size: 24,
            color: isActive
                ? ColorConstants.MainPurpleBackground
                : Colors.grey.shade600,
          ),
        ),
        title: label,
        textStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          height: 1.2,
          color: isActive ? primaryColor : Colors.grey.shade600,
        ),
      ),
    );
  }
}
