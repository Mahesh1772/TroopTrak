import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:recase/recase.dart';
import 'package:trooptrak_final_application/features/detailed_view/presentation/widgets/statuses_tab.dart';
import '../providers/user_detail_provider.dart';
import '../widgets/basic_info_tab.dart';
import '../../../detailed_view/presentation/pages/attendance_tab.dart';

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

  bool rankColorPicker(String rank) {
    return (rank == 'REC' ||
        rank == 'PTE' ||
        rank == 'LCP' ||
        rank == 'CPL' ||
        rank == 'CFC' ||
        rank == '3SG' ||
        rank == '2SG' ||
        rank == '1SG' ||
        rank == 'SSG' ||
        rank == 'MSG' ||
        rank == '3WO' ||
        rank == '2WO' ||
        rank == '1WO' ||
        rank == 'MWO' ||
        rank == 'SWO' ||
        rank == 'CWO');
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
    return _isLoading
        ? const Center(
            child: CircularProgressIndicator(),
          )
        : Consumer<UserDetailProvider>(
            builder: (context, provider, child) {
              final user = provider.user;
              if (user == null) {
                return const Center(child: Text('User not found'));
              }

              return Scaffold(
                body: SingleChildScrollView(
                  child: Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          borderRadius:
                              BorderRadius.all(Radius.circular(12.0.r)),
                          gradient: const LinearGradient(
                            colors: [
                              Color.fromARGB(255, 72, 30, 229),
                              Color.fromARGB(255, 130, 60, 229),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: SafeArea(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 10.w),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    InkWell(
                                      onTap: () {
                                        Navigator.pop(context);
                                      },
                                      child: Icon(
                                        Icons.arrow_back_sharp,
                                        color: Colors.white,
                                        size: 25.sp,
                                      ),
                                    ),
                                    SizedBox(
                                      height: 20.h,
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(
                                          left: 20.0.w,
                                          right: 20.0.w,
                                          top: 20.0.h),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  user.name.toUpperCase(),
                                                  maxLines: 3,
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .displayLarge!
                                                      .copyWith(
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        letterSpacing: 1.5,
                                                      ),
                                                ),
                                                SizedBox(
                                                  height: 5.h,
                                                ),
                                                Text(
                                                  user.apppointment.titleCase,
                                                  maxLines: 2,
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodyLarge!
                                                      .copyWith(
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        letterSpacing: 1.5,
                                                      ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Image.asset(
                                            "lib/assets/army-ranks/${user.rank.toString().toLowerCase()}.png",
                                            width: 60.w,
                                            color: rankColorPicker(user.rank)
                                                ? Colors.white
                                                : null,
                                          )
                                        ],
                                      ),
                                    ),
                                    SizedBox(
                                      height: 20.h,
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(left: 20.0.w),
                                      child: Text(
                                        "${user.company.toUpperCase()} COMPANY",
                                        maxLines: 2,
                                        style: Theme.of(context)
                                            .textTheme
                                            .headlineLarge!
                                            .copyWith(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w500,
                                              letterSpacing: 1.5,
                                            ),
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(
                                          left: 20.0.w, bottom: 50.0.h),
                                      child: Text(
                                        "Platoon ${user.platoon}, Section ${user.section}",
                                        maxLines: 2,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyLarge!
                                            .copyWith(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w500,
                                              letterSpacing: 1.5,
                                            ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Column(
                        children: [
                          SizedBox(
                            height: 10.h,
                          ),
                          TabBar(
                            labelStyle: Theme.of(context)
                                .textTheme
                                .bodyLarge!
                                .copyWith(
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.5,
                                  color: Theme.of(context).colorScheme.tertiary,
                                ),
                            indicatorColor:
                                Theme.of(context).colorScheme.tertiary,
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
                    ],
                  ),
                ),
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
