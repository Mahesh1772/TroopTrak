import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
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
              backgroundColor: const Color.fromARGB(255, 243, 246, 254),
              body: SingleChildScrollView(
                child: Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(12.0.r)),
                        gradient: const LinearGradient(
                          colors: [
                            Color.fromARGB(255, 72, 30, 229),
                            Color.fromARGB(255, 130, 60, 229),
                          ],
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
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      InkWell(
                                        onTap: () {
                                          Navigator.pop(context);
                                        },
                                        child: Icon(
                                          Icons.arrow_back_sharp,
                                          color: Colors.white,
                                          size: 30.sp,
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
                                  SizedBox(height: 20.h),
                                  Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 10.w),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          user.name.toUpperCase(),
                                          style: GoogleFonts.poppins(
                                            color: Colors.white,
                                            fontSize: 26.sp,
                                            fontWeight: FontWeight.w600,
                                            letterSpacing: 1.5,
                                          ),
                                        ),
                                        Text(
                                          "${user.rank} ${user.apppointment}",
                                          style: GoogleFonts.poppins(
                                            color: Colors.white,
                                            fontSize: 16.sp,
                                            fontWeight: FontWeight.w500,
                                            letterSpacing: 1.5,
                                          ),
                                        ),
                                        SizedBox(height: 20.h),
                                        Text(
                                          "${user.company} COMPANY",
                                          style: GoogleFonts.poppins(
                                            color: Colors.white,
                                            fontSize: 16.sp,
                                            fontWeight: FontWeight.w500,
                                            letterSpacing: 1.5,
                                          ),
                                        ),
                                        Text(
                                          "Platoon ${user.platoon}, Section ${user.section}",
                                          style: GoogleFonts.poppins(
                                            color: Colors.white,
                                            fontSize: 16.sp,
                                            fontWeight: FontWeight.w500,
                                            letterSpacing: 1.5,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: 30.h),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 10.h),
                        TabBar(
                          labelStyle: GoogleFonts.poppins(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 1.5,
                          ),
                          unselectedLabelStyle: GoogleFonts.poppins(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 1.5,
                          ),
                          labelColor: const Color.fromARGB(255, 72, 30, 229),
                          unselectedLabelColor: Colors.grey,
                          indicatorColor: const Color.fromARGB(255, 72, 30, 229),
                          controller: _tabController,
                          tabs: const [
                            Tab(
                              text: "BASIC INFO",
                              icon: Icon(Icons.info),
                            ),
                            Tab(
                              text: "STATUSES",
                              icon: Icon(Icons.warning_rounded),
                            ),
                            Tab(
                              text: "ATTENDANCE",
                              icon: Icon(Icons.person_add_alt_1),
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
      },
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
