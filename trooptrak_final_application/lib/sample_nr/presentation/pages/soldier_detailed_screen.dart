import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_detail_provider.dart';
import '../widgets/basic_info_tab.dart';
import '../widgets/attendance_tab.dart';
import '../widgets/statuses_tab.dart';

class SoldierDetailedScreen extends StatefulWidget {
  final String userId;

  const SoldierDetailedScreen({super.key, required this.userId});

  @override
  _SoldierDetailedScreenState createState() => _SoldierDetailedScreenState();
}

class _SoldierDetailedScreenState extends State<SoldierDetailedScreen> with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadUserData();
  }

  @override
  void didUpdateWidget(SoldierDetailedScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.userId != oldWidget.userId) {
      _loadUserData();
    }
  }

  void _loadUserData() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UserDetailProvider>().loadUser(widget.userId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Soldier Details'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Basic Info'),
            Tab(text: 'Attendance'),
            Tab(text: 'Statuses'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          BasicInfoTab(userId: widget.userId),
          AttendanceTab(userId: widget.userId),
          StatusesTab(userId: widget.userId),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}