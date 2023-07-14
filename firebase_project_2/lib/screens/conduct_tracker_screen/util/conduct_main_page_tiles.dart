import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';

class ConductTile extends StatefulWidget {
  final String conductType;
  final String conductName;
  final int conductNumber;
  final bool isUserParticipating;

  const ConductTile(
      {super.key,
      required this.conductName,
      required this.conductType,
      required this.conductNumber,
      required this.isUserParticipating});

  @override
  State<ConductTile> createState() => _ConductTileState();
}

class _ConductTileState extends State<ConductTile>
    with TickerProviderStateMixin {
  late AnimationController _enterDetailedView;
  late AnimationController _isParticipatingIconController;

  @override
  void initState() {
    super.initState();

    _enterDetailedView =
        AnimationController(vsync: this, duration: const Duration(seconds: 10));
    _enterDetailedView.repeat();

    _isParticipatingIconController = AnimationController(
      vsync: this,
    );

    _isParticipatingIconController.repeat(period: Duration(seconds: 2));
  }

  @override
  void dispose() {
    _isParticipatingIconController.dispose();
    _enterDetailedView.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.0.sp),
      color: Colors.transparent,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(right: 30.0.w),
            child: Container(
              height: 70.h,
              width: 70.w,
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 53, 14, 145),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Center(
                child: widget.isUserParticipating
                    ? Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Stack(
                          children: [
                            Padding(
                              padding: EdgeInsets.all(16.0.sp),
                              child: Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 20.sp,
                              ),
                            ),
                            Lottie.network(
                                "https://lottie.host/220b2467-17d5-41d3-923a-3124581b9c71/VmZrHlNeR7.json",
                                controller: _isParticipatingIconController,
                                height: 60.h,
                                fit: BoxFit.cover),
                          ],
                        ),
                      )
                    : Lottie.network(
                        "https://lottie.host/b9ea1c18-05fc-4fba-b566-cebdaecc45b5/8ZFPRtgKqI.json",
                        height: 60.h,
                        fit: BoxFit.cover),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 230.w,
                child: AutoSizeText(
                  widget.conductType,
                  maxLines: 1,
                  style: GoogleFonts.poppins(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      color: Colors.white),
                ),
              ),
              SizedBox(
                width: 230.w,
                child: AutoSizeText(
                  widget.conductName,
                  maxLines: 1,
                  style: GoogleFonts.poppins(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.w500,
                      color: Colors.white),
                ),
              ),
            ],
          ),
          Lottie.network(
              "https://lottie.host/7e7767a8-9686-4837-86a8-ecae5e702dea/CqA0PWcGif.json",
              controller: _enterDetailedView,
              height: 45.h,
              fit: BoxFit.cover),
        ],
      ),
    );
  }
}
