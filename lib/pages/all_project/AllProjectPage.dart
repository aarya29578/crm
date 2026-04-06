import 'package:flutter/material.dart';
import 'package:crm_flutter/pages/all_project/activity/ActivityPage.dart';
import 'package:crm_flutter/pages/all_project/calls_activity/CallsActivityPage.dart';
import 'package:crm_flutter/pages/all_project/leads_received/LeadsReceivedPage.dart';
import 'package:crm_flutter/pages/all_project/revenue/RevenuePage.dart';
import 'package:crm_flutter/styles/color_palette.dart';

class AllProjectPage extends StatefulWidget {
  const AllProjectPage({super.key});

  @override
  State<AllProjectPage> createState() => _AllProjectPageState();
}

class _AllProjectPageState extends State<AllProjectPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade300,
      appBar: AppBar(
        backgroundColor: ColorConstants.MainPurpleBackground,
        bottom: TabBar(
          tabAlignment: TabAlignment.start,
          controller: _tabController,
          isScrollable: true,
          labelPadding: EdgeInsets.symmetric(horizontal: 8),
          tabs: const [
            Tab(text: 'Activity'),
            Tab(text: 'Leads Received'),
            Tab(text: 'Calls Activity'),
            Tab(text: 'Revenue'),
          ],
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
        ),
        title: Container(
          padding: EdgeInsets.all(10),
          // decoration: BoxDecoration(color: Colors.white),
          child: Row(
            children: [
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  "All Projects",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    letterSpacing: 0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              // Icon(Icons.keyboard_arrow_down, color: Colors.black),
            ],
          ),
        ),
      ),
      body: SafeArea(
        child: TabBarView(
          controller: _tabController,
          children: [
            // Replace these with your actual tab content widgets
            ActivityPage(),
            LeadsReceivedPage(),
            CallsActivityPage(),
            RevenuePage(),
          ],
        ),
      ),
    );
  }

  Widget _buildLeadsReceivedTab() {
    return Center(child: Text('Leads Received Content'));
  }

  Widget _buildCallsActiveTab() {
    return Center(child: Text('Calls Active Content'));
  }

  Widget _buildRevenueTab() {
    return Center(child: Text('Revenue Content'));
  }
}
