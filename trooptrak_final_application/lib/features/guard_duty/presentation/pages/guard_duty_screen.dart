import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/guard_duty_provider.dart';
import '../widgets/points_leaderboard_tab.dart';
import '../widgets/upcoming_duties_tab.dart';
import '../pages/add_guard_duty_screen.dart';

class GuardDutyScreen extends StatefulWidget {
  const GuardDutyScreen({super.key});

  @override
  State<GuardDutyScreen> createState() => _GuardDutyScreenState();
}

class _GuardDutyScreenState extends State<GuardDutyScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GuardDutyProvider>().loadDuties();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddGuardDutyScreen(),
            ),
          );
        },
        backgroundColor: Theme.of(context).primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: SafeArea(
        child: Column(
          children: [
            TabBar(
              controller: _tabController,
              tabs: const [
                Tab(
                  text: "POINTS LEADERBOARD",
                  icon: Icon(Icons.leaderboard_rounded),
                ),
                Tab(
                  text: "UPCOMING DUTIES",
                  icon: Icon(Icons.more_time_rounded),
                ),
              ],
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: const [
                  PointsLeaderboardTab(),
                  UpcomingDutiesTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
} 