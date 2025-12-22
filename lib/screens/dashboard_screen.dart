import 'package:flutter/material.dart';
import 'trip_list_screen.dart';
import 'bill_upload_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<Tab> myTabs = const [
    Tab(text: "Pending"),
    Tab(text: "Ongoing"),
    Tab(text: "Bill Uploads"),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: myTabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Colors.purple;
    final accentColor = Colors.pinkAccent;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Driver Dashboard"),
        backgroundColor: primaryColor,
        bottom: TabBar(
          controller: _tabController,
          tabs: myTabs,
          indicatorColor: accentColor,
          indicatorWeight: 4,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          TripListScreen(status: "Pending"),
          TripListScreen(status: "Ongoing"),
          BillUploadScreen(),
        ],
      ),
      backgroundColor: Colors.purple[50], // soft purple background
    );
  }
}
