// lib/presentation/widgets/past_status_tile.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:auto_size_text/auto_size_text.dart';
import '../../domain/entities/status.dart';
import '../pages/add_update_status_page.dart';
import '../providers/status_provider.dart';
import 'package:provider/provider.dart';

class PastStatusTile extends StatelessWidget {
  final Status status;
  final String userId;

  const PastStatusTile({super.key, required this.status, required this.userId});

  @override
  Widget build(BuildContext context) {
    IconData tileIcon;
    if (status.statusType == "Excuse") {
      tileIcon = Icons.personal_injury_rounded;
    } else if (status.statusType == "Leave") {
      tileIcon = Icons.medical_services_rounded;
    } else if (status.statusType == "Medical Appointment") {
      tileIcon = Icons.date_range_rounded;
    } else {
      tileIcon = Icons.info_outline;
    }

    return Padding(
      padding: EdgeInsets.only(bottom: 8.0.h),
      child: Container(
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 144, 143, 143),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Padding(
          padding: EdgeInsets.all(16.0.sp),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(
                tileIcon,
                color: Colors.white,
                size: 30.sp,
              ),
              SizedBox(
                width: 100.w,
                child: AutoSizeText(
                  status.statusName,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    fontSize: 16.sp,
                    color: Colors.white,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(
                width: 200.w,
                child: AutoSizeText(
                  "${status.startDate} - ${status.endDate}",
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    fontSize: 14.sp,
                    color: Colors.white,
                  ),
                  maxLines: 1,
                ),
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.white),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddUpdateStatusPage(
                            userId: userId,
                            status: status,
                          ),
                        ),
                      );
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.white),
                    onPressed: () {
                      Provider.of<StatusProvider>(context, listen: false)
                          .deleteStatus(userId, status.id);
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}