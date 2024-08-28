import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:animated_toggle_switch/animated_toggle_switch.dart';
import 'package:provider/provider.dart';
import 'package:trooptrak_final_application/features/nominal_roll/presentation/pages/soldier_detailed_screen.dart';
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
    Color tileColor = soldierColorGenerator(widget.user.rank);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SoldierDetailedScreen(userId: widget.user.name),
          ),
        );
      },
      child: Padding(
        padding: EdgeInsets.all(1.0.sp),
        child: Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                blurRadius: 2.0.r,
                spreadRadius: 2.0.r,
                offset: Offset(10.w, 10.h),
                color: Colors.black54,
              )
            ],
            color: tileColor,
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    width: 40.w,
                    height: 40.h,
                    padding: EdgeInsets.all(5.sp),
                    decoration: BoxDecoration(
                      color: Colors.transparent.withOpacity(0.15),
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(12.r),
                        bottomLeft: Radius.circular(12.r),
                      ),
                    ),
                    child: Image.asset(
                      "lib/assets/army-ranks/${widget.user.rank.toLowerCase()}.png",
                      color: rankColorPicker(widget.user.rank)
                          ? Colors.white70
                          : null,
                    ),
                  ),
                ],
              ),
              Padding(
                padding:
                    EdgeInsets.symmetric(horizontal: 24.0.w, vertical: 8.0.h),
                child: Image.asset(
                  soldierIconGenerator(widget.user.rank),
                  width: 90.w,
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.0.h),
                child: SizedBox(
                  height: 40.h,
                  width: double.maxFinite,
                  child: Center(
                    child: AutoSizeText(
                      widget.user.name,
                      maxLines: 2,
                      textAlign: TextAlign.center,
                      style:
                          Theme.of(context).textTheme.displayMedium?.copyWith(
                                color: Colors.white,
                              ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 10.h),
              Text(
                inCampStatusTextChanger(
                    widget.user.currentAttendance == 'Inside Camp'),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.white,
                    ),
              ),
              const SizedBox(height: 15),
              AnimatedToggleSwitch<bool>.rolling(
                current: widget.user.currentAttendance == 'Inside Camp',
                values: const [false, true],
                 onChanged: (value) async {
                  final attendanceProvider = Provider.of<AttendanceProvider>(context, listen: false);
                  await attendanceProvider.updateUserAttendanceRecord(widget.user.name, value).first;
                },
                iconBuilder: rollingIconBuilder,
                borderWidth: 3.0.w,
                indicatorColor: Theme.of(context).colorScheme.primary,
                innerColor: Colors.amber,
                height: 40.h,
                dif: 10,
                iconRadius: 10.0.r,
                selectedIconRadius: 13.0.r,
                borderColor: Colors.transparent,
                loading: loading,
              ),
            ],
          ),
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
