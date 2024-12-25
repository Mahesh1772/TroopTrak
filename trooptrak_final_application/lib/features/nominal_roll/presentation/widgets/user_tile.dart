import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:animated_toggle_switch/animated_toggle_switch.dart';
import 'package:provider/provider.dart';
import 'package:trooptrak_final_application/features/detailed_view/presentation/pages/soldier_detailed_screen.dart';
import '../../../detailed_view/presentation/providers/attendance_provider.dart';
import '../../domain/entities/user.dart';

class UserTile extends StatefulWidget {
  final User user;

  const UserTile({super.key, required this.user});

  @override
  State<UserTile> createState() => _UserTileState();
}

class _UserTileState extends State<UserTile> {
  late bool isInsideCamp;
  bool loading = false;

  @override
  void initState() {
    super.initState();
    isInsideCamp = widget.user.currentAttendance == 'Inside Camp';
  }

  @override
  void didUpdateWidget(UserTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update the state when the user data changes
    if (oldWidget.user.currentAttendance != widget.user.currentAttendance) {
      setState(() {
        isInsideCamp = widget.user.currentAttendance == 'Inside Camp';
      });
    }
  }

  String inCampStatusTextChanger(bool value) {
    return value ? "IN CAMP" : "NOT IN CAMP";
  }

  String soldierIconGenerator(String rank) {
    if (['REC', 'PTE', 'LCP', 'CPL', 'CFC'].contains(rank)) {
      return "lib/assets/army-ranks/men.png";
    } else {
      return "lib/assets/army-ranks/soldier.png";
    }
  }

  Color soldierColorGenerator(String rank) {
    if (['REC', 'PTE', 'LCP', 'CPL', 'CFC'].contains(rank)) {
      return Colors.brown.shade800;
    } else if (rank == 'SCT') {
      return Colors.brown.shade400;
    } else if (['3SG', '2SG', '1SG', 'SSG', 'MSG'].contains(rank)) {
      return Colors.indigo.shade700;
    } else if (['3WO', '2WO', '1WO', 'MWO', 'SWO', 'CWO'].contains(rank)) {
      return Colors.indigo.shade400;
    } else if (rank == 'OCT') {
      return Colors.teal.shade900;
    } else if (['2LT', 'LTA', 'CPT'].contains(rank)) {
      return Colors.teal.shade800;
    } else {
      return Colors.teal.shade400;
    }
  }

  bool rankColorPicker(String rank) {
    return [
      'REC',
      'PTE',
      'LCP',
      'CPL',
      'CFC',
      '3SG',
      '2SG',
      '1SG',
      'SSG',
      'MSG',
      '3WO',
      '2WO',
      '1WO',
      'MWO',
      'SWO',
      'CWO'
    ].contains(rank);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    Color tileColor = soldierColorGenerator(widget.user.rank);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SoldierDetailedScreen(userId: widget.user.id),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: isDarkMode ? const Color.fromARGB(255, 45, 50, 65) : Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: isDarkMode 
                ? Colors.black.withOpacity(0.3) 
                : Colors.black.withOpacity(0.15),
              blurRadius: 16.r,
              offset: Offset(0, 6.h),
              spreadRadius: isDarkMode ? 1.r : 2.r,
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              height: 32.h,
              decoration: BoxDecoration(
                color: tileColor,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16.r),
                  topRight: Radius.circular(16.r),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    width: 32.w,
                    height: 32.h,
                    padding: EdgeInsets.all(6.sp),
                    decoration: BoxDecoration(
                      color: Colors.black26,
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(16.r),
                      ),
                    ),
                    child: Image.asset(
                      "lib/assets/army-ranks/${widget.user.rank.toLowerCase()}.png",
                      color: rankColorPicker(widget.user.rank) ? Colors.white : null,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: Image.asset(
                      soldierIconGenerator(widget.user.rank),
                      height: 80.h,
                      width: 80.w,
                    ),
                  ),
                  Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12.w),
                        child: AutoSizeText(
                          widget.user.name,
                          maxLines: 2,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: isDarkMode ? Colors.white : Colors.black87,
                            fontWeight: FontWeight.w600,
                            fontSize: 16.sp,
                            height: 1.2,
                          ),
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        isInsideCamp ? 'Inside Camp' : 'Outside Camp',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isDarkMode ? Colors.white70 : Colors.black54,
                          fontSize: 12.sp,
                          letterSpacing: 0.5,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: AnimatedToggleSwitch<bool>.rolling(
                      current: isInsideCamp,
                      values: const [false, true],
                      onChanged: (value) async {
                        setState(() {
                          loading = true;
                        });
                        try {
                          final attendanceProvider = Provider.of<AttendanceProvider>(context, listen: false);
                          await attendanceProvider.updateUserAttendanceRecord(widget.user.id, value).first;
                          setState(() {
                            isInsideCamp = value;
                          });
                        } finally {
                          setState(() {
                            loading = false;
                          });
                        }
                      },
                      iconBuilder: rollingIconBuilder,
                      borderWidth: 2.w,
                      indicatorColor: tileColor,
                      innerColor: isDarkMode ? Colors.black26 : Colors.black.withOpacity(0.05),
                      height: 32.h,
                      dif: 10.w,
                      iconRadius: 10.r,
                      selectedIconRadius: 12.r,
                      borderColor: Colors.transparent,
                      loading: loading,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget rollingIconBuilder(bool value, Size iconSize, bool foreground) {
  IconData data = value ? Icons.check_circle : Icons.cancel;
  return Icon(
    data,
    size: iconSize.shortestSide,
  );
}
