import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'add_duty_soldiers_card.dart';
import 'hero_dialog_route.dart';
import 'custom_rect_tween.dart';

class OrgChartTile extends StatelessWidget {
  final String heroTag;
  final String rank;
  final String name;
  final Map<String, String> currentParticipants;
  final Function(Map<String, String>) onParticipantsUpdated;

  const OrgChartTile({
    super.key,
    required this.heroTag,
    required this.rank,
    required this.name,
    required this.currentParticipants,
    required this.onParticipantsUpdated,
  });

  @override
  Widget build(BuildContext context) {
    final bool isEmpty = name.contains('NA');

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          HeroDialogRoute(
            builder: (context) => AddDutySoldiersCard(
              heroTag: heroTag,
              currentParticipants: currentParticipants,
              onParticipantsUpdated: onParticipantsUpdated,
            ),
          ),
        );
      },
      child: Hero(
        tag: heroTag,
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: Theme.of(context).dividerColor,
            ),
          ),
          child: isEmpty
              ? Icon(
                  Icons.add,
                  size: 32.sp,
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      child: Text(rank),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      name,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12.sp),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
} 