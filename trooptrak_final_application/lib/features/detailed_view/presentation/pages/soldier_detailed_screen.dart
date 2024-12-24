import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:trooptrak_final_application/features/detailed_view/presentation/widgets/statuses_tab.dart';
import '../../../nominal_roll/domain/entities/user.dart';
import '../../../nominal_roll/presentation/providers/user_detail_provider.dart';
import '../widgets/basic_info_tab.dart';
import 'attendance_tab.dart';

class SoldierDetailedScreen extends StatefulWidget {
  final String userId;

  const SoldierDetailedScreen({super.key, required this.userId});

  @override
  _SoldierDetailedScreenState createState() => _SoldierDetailedScreenState();
}

class _SoldierDetailedScreenState extends State<SoldierDetailedScreen>
    with TickerProviderStateMixin {
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
    return Consumer<UserDetailProvider>(
      builder: (context, provider, child) {
        return StreamBuilder<User?>(
          stream: provider.userStream,
          initialData: provider.user,
          builder: (context, snapshot) {
            if (provider.isLoading) {
              return const Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }

            final user = snapshot.data;
            if (user == null) {
              return const Scaffold(
                body: Center(child: Text('User not found')),
              );
            }

            return Scaffold(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              body: SingleChildScrollView(
                child: Column(
                  children: [
                    Container(
                      width: double.maxFinite,
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 72, 30, 229),
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(30.r),
                          bottomRight: Radius.circular(30.r),
                        ),
                      ),
                      child: SafeArea(
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                IconButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  icon: const Icon(
                                    Icons.arrow_back_ios_new_rounded,
                                    color: Colors.white,
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.all(12.0.sp),
                                  child: Image.asset(
                                    "lib/assets/army-ranks/${user.rank.toLowerCase()}.png",
                                    width: 40.w,
                                    height: 40.h,
                                    color: Colors.white70,
                                  ),
                                ),
                              ],
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 24.0.w),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    user.name.toUpperCase(),
                                    style: Theme.of(context)
                                        .textTheme
                                        .displayLarge!
                                        .copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w500,
                                          letterSpacing: 1.5,
                                          fontSize: 26.sp,
                                        ),
                                  ),
                                  Text(
                                    "${user.rank} ${user.apppointment}",
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyLarge!
                                        .copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w500,
                                          letterSpacing: 1.5,
                                        ),
                                  ),
                                  SizedBox(height: 20.h),
                                  Text(
                                    "${user.company} COMPANY",
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyLarge!
                                        .copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w500,
                                          letterSpacing: 1.5,
                                        ),
                                  ),
                                  Text(
                                    "Platoon ${user.platoon}, Section ${user.section}",
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyLarge!
                                        .copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w500,
                                          letterSpacing: 1.5,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 20.h),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 10.h),
                    TabBar(
                      labelStyle: Theme.of(context).textTheme.bodyLarge!.copyWith(
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                            color: Theme.of(context).colorScheme.tertiary,
                          ),
                      indicatorColor: Theme.of(context).colorScheme.tertiary,
                      controller: _tabController,
                      tabs: [
                        Tab(
                          text: "BASIC INFO",
                          icon: Icon(
                            Icons.info,
                            color: Theme.of(context).colorScheme.tertiary,
                          ),
                        ),
                        Tab(
                          text: "STATUSES",
                          icon: Icon(
                            Icons.warning_rounded,
                            color: Theme.of(context).colorScheme.tertiary,
                          ),
                        ),
                        Tab(
                          text: "ATTENDANCE",
                          icon: Icon(
                            Icons.person_add_alt_1,
                            color: Theme.of(context).colorScheme.tertiary,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      width: double.maxFinite,
                      height: 750.h,
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          BasicInfoTab(userId: widget.userId),
                          StatusesTab(userId: widget.userId),
                          AttendanceTab(userId: widget.userId),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
