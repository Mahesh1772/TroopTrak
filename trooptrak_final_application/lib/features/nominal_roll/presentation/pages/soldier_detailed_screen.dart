import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trooptrak_final_application/features/detailed_view/presentation/widgets/statuses_tab.dart';
import '../providers/user_detail_provider.dart';
import '../widgets/basic_info_tab.dart';
import '../../../detailed_view/presentation/widgets/attendance_tab.dart';



class SoldierDetailedScreen extends StatefulWidget {
  final String userId;

  const SoldierDetailedScreen({super.key, required this.userId});

  @override
  _SoldierDetailedScreenState createState() => _SoldierDetailedScreenState();
}

class _SoldierDetailedScreenState extends State<SoldierDetailedScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;

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
    setState(() {
      _isLoading = true;
    });

    final userProvider = context.read<UserDetailProvider>();
    userProvider.loadUser(widget.userId);

    userProvider.waitForInitialLoad().then((_) {
      setState(() {
        _isLoading = false;
      });
    }).catchError((error) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading user data: $error')),
      );
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Consumer<UserDetailProvider>(
              builder: (context, provider, child) {
                final user = provider.user;
                if (user == null) {
                  return const Center(child: Text('User not found'));
                }
                return TabBarView(
                  controller: _tabController,
                  children: [
                    BasicInfoTab(userId: widget.userId),
                    AttendanceTab(userId: widget.userId),
                    StatusesTab(userId: widget.userId),
                  ],
                );
              },
            ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
