import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_project_2/screens/guard_duty_tracker_screen.dart/util/custom_rect_tween.dart';
import 'package:firebase_project_2/screens/guard_duty_tracker_screen.dart/util/hero_dialog_route.dart';
import 'package:firebase_project_2/screens/guard_duty_tracker_screen.dart/add_duty_soldiers_card.dart';

class OrgChartTile extends StatefulWidget {
  const OrgChartTile(
      {super.key,
      required this.rank,
      required this.name,
      required this.heroTag,
      required this.callbackFunction,
      required this.nonParticipants,
      required this.dutySoldiersAndRanks});

  final String rank;
  final String? name;
  final String heroTag;
  final Function callbackFunction;
  final List nonParticipants;
  final Map<dynamic, dynamic> dutySoldiersAndRanks;

  @override
  State<OrgChartTile> createState() => _OrgChartTileState();
}

class _OrgChartTileState extends State<OrgChartTile> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          HeroDialogRoute(
            builder: (context) {
              return AddDutySoldiersCard(
                heroTag: widget.heroTag,
                callbackFunction: widget.callbackFunction,
                nonParticipants: widget.nonParticipants,
                dutySoldiersAndRanks: widget.dutySoldiersAndRanks,
              );
            },
          ),
        );
      },
      child: Hero(
        tag: widget.heroTag,
        createRectTween: (begin, end) {
          return CustomRectTween(begin: begin!, end: end!);
        },
        child: Container(
          width: 100.w,
          height: 100.h,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.r),
            gradient: const LinearGradient(
              colors: [
                Color.fromARGB(255, 38, 31, 60),
                Color.fromARGB(255, 54, 60, 81),
              ],
            ),
          ),
          child: widget.name!.contains("NA")
              ? Center(
                  child: Icon(
                    Icons.add,
                    color: Colors.white,
                    size: 50.sp,
                  ),
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: EdgeInsets.all(8.0.sp),
                      child: CircleAvatar(
                        backgroundColor: Colors.black,
                        child: Image.asset(
                          "lib/assets/army-ranks/${widget.rank.toLowerCase().toString()}.png",
                          width: 20.w,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 90.w,
                      height: 20.h,
                      child: AutoSizeText(
                        widget.name!,
                        maxLines: 2,
                        maxFontSize: 12,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w500, color: Colors.white),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
