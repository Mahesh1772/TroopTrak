import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/statuses_tab.dart';
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

class _SoldierDetailedScreenState extends State<SoldierDetailedScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadUserData();
  }

  void _loadUserData() {
    final provider = Provider.of<UserDetailProvider>(context, listen: false);
    provider.loadUser(widget.userId);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return WillPopScope(
      onWillPop: () async {
        final provider = Provider.of<UserDetailProvider>(context, listen: false);
        provider.clearCurrentUser();
        return true;
      },
      child: Consumer<UserDetailProvider>(
        builder: (context, provider, child) {
          return StreamBuilder<User?>(
            stream: provider.userStream,
            initialData: provider.user,
            builder: (context, snapshot) {
              if (provider.isLoading) {
                return Scaffold(
                  backgroundColor: isDarkMode ? const Color.fromARGB(255, 35, 40, 55) : theme.colorScheme.surface,
                  appBar: AppBar(
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    leading: IconButton(
                      icon: Icon(
                        Icons.arrow_back_sharp,
                        color: theme.colorScheme.tertiary,
                        size: 25.sp,
                      ),
                      onPressed: () {
                        provider.clearCurrentUser();
                        Navigator.pop(context);
                      },
                    ),
                  ),
                  body: Center(
                    child: CircularProgressIndicator(
                      color: theme.colorScheme.secondary,
                      strokeWidth: 2.w,
                    ),
                  ),
                );
              }

              final user = snapshot.data;
              if (user == null) {
                return Scaffold(
                  backgroundColor: isDarkMode ? const Color.fromARGB(255, 35, 40, 55) : theme.colorScheme.surface,
                  body: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline_rounded,
                          size: 32.sp,
                          color: theme.colorScheme.error,
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          'User not found',
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: theme.colorScheme.tertiary,
                            letterSpacing: 1.2,
                            fontSize: 16.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return Scaffold(
                backgroundColor: theme.scaffoldBackgroundColor,
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
                                            size: 25.sp,
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 20.h),
                                    Padding(
                                      padding: EdgeInsets.symmetric(horizontal: 20.w),
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Text(
                                                  user.name.toUpperCase(),
                                                  style: GoogleFonts.poppins(
                                                    color: Colors.white,
                                                    fontSize: 25.sp,
                                                    fontWeight: FontWeight.bold,
                                                    letterSpacing: 1.5,
                                                  ),
                                                ),
                                                SizedBox(height: 4.h),
                                                Row(
                                                  children: [
                                                    Text(
                                                      "${user.rank} ${user.apppointment}",
                                                      style: GoogleFonts.poppins(
                                                        color: Colors.white,
                                                        fontSize: 16.sp,
                                                        fontWeight: FontWeight.w500,
                                                        letterSpacing: 1.5,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                SizedBox(height: 16.h),
                                                Text(
                                                  "${user.company} COMPANY",
                                                  style: GoogleFonts.poppins(
                                                    color: Colors.white,
                                                    fontSize: 18.sp,
                                                    fontWeight: FontWeight.bold,
                                                    letterSpacing: 1.5,
                                                  ),
                                                ),
                                                SizedBox(height: 4.h),
                                                Text(
                                                  "Platoon ${user.platoon}, Section ${user.section}",
                                                  style: GoogleFonts.poppins(
                                                    color: Colors.white,
                                                    fontSize: 16.sp,
                                                    fontWeight: FontWeight.w500,
                                                    letterSpacing: 1.5,
                                                  ),
                                                ),
                                                SizedBox(height: 20.h),
                                              ],
                                            ),
                                          ),
                                          SizedBox(width: 16.w),
                                          Container(
                                            padding: EdgeInsets.all(16.sp),
                                            decoration: BoxDecoration(
                                              color: Colors.white.withOpacity(0.15),
                                              borderRadius: BorderRadius.circular(16.r),
                                            ),
                                            child: Image.asset(
                                              "lib/assets/army-ranks/${user.rank.toLowerCase()}.png",
                                              width: 70.w,
                                              height: 70.h,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
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
                            labelColor: isDarkMode
                                ? const Color.fromARGB(255, 130, 100, 255)
                                : const Color.fromARGB(255, 72, 30, 229),
                            unselectedLabelColor: isDarkMode 
                                ? Colors.white.withOpacity(0.8)
                                : Colors.black.withOpacity(0.7),
                            indicatorColor: isDarkMode
                                ? const Color.fromARGB(255, 130, 100, 255)
                                : const Color.fromARGB(255, 72, 30, 229),
                            controller: _tabController,
                            tabs: [
                              Tab(
                                text: "BASIC INFO",
                                icon: Icon(
                                  Icons.info,
                                  color: isDarkMode 
                                      ? const Color.fromARGB(255, 130, 100, 255)
                                      : const Color.fromARGB(255, 72, 30, 229),
                                ),
                              ),
                              Tab(
                                text: "STATUSES",
                                icon: Icon(
                                  Icons.warning_rounded,
                                  color: isDarkMode 
                                      ? const Color.fromARGB(255, 130, 100, 255)
                                      : const Color.fromARGB(255, 72, 30, 229),
                                ),
                              ),
                              Tab(
                                text: "ATTENDANCE",
                                icon: Icon(
                                  Icons.person_add_alt_1,
                                  color: isDarkMode 
                                      ? const Color.fromARGB(255, 130, 100, 255)
                                      : const Color.fromARGB(255, 72, 30, 229),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            width: double.maxFinite,
                            height: MediaQuery.of(context).size.height * 0.7,
                            child: TabBarView(
                              controller: _tabController,
                              children: [
                                BasicInfoTab(userId: user.id),
                                StatusesTab(userId: user.id),
                                AttendanceTab(userId: user.id),
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
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
