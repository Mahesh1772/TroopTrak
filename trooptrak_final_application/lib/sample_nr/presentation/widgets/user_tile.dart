import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:animated_toggle_switch/animated_toggle_switch.dart';
import 'package:provider/provider.dart';
import 'package:trooptrak_final_application/sample_nr/presentation/providers/user_provider.dart';
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

  // @override
  // void initState() {
  //   super.initState();
  //   isInsideCamp = widget.user.currentAttendance == 'Inside Camp';
  // }

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
    return ['REC', 'PTE', 'LCP', 'CPL', 'CFC', '3SG', '2SG', '1SG', 'SSG', 'MSG', '3WO', '2WO', '1WO', 'MWO', 'SWO', 'CWO'].contains(rank);
  }

  @override
  Widget build(BuildContext context) {
    Color tileColor = soldierColorGenerator(widget.user.rank);

    return GestureDetector(
      onTap: () {
        // Navigate to detailed screen if needed
      },
      child: Padding(
        padding: const EdgeInsets.all(1.0),
        child: Container(
          decoration: BoxDecoration(
            boxShadow: const [
              BoxShadow(
                blurRadius: 2.0,
                spreadRadius: 2.0,
                offset: Offset(10, 10),
                color: Colors.black54,
              )
            ],
            color: tileColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: Colors.transparent.withOpacity(0.15),
                      borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(12),
                        bottomLeft: Radius.circular(12),
                      ),
                    ),
                    child: Image.asset(
                      "lib/assets/army-ranks/${widget.user.rank.toLowerCase()}.png",
                      color: rankColorPicker(widget.user.rank) ? Colors.white70 : null,
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                child: Image.asset(
                  soldierIconGenerator(widget.user.rank),
                  width: 90,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: SizedBox(
                  height: 40,
                  width: double.maxFinite,
                  child: Center(
                    child: AutoSizeText(
                      widget.user.name,
                      maxLines: 2,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                inCampStatusTextChanger(widget.user.currentAttendance == 'Inside Camp'),
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 15),
              AnimatedToggleSwitch<bool>.rolling(
                current: widget.user.currentAttendance == 'Inside Camp',
                values: const [false, true],
                 onChanged: (value) async {
                  final userProvider = Provider.of<UserProvider>(context, listen: false);
                  await userProvider.updateUserAttendance(widget.user.id, value);
                },
                iconBuilder: rollingIconBuilder,
                borderWidth: 3.0,
                indicatorColor: Theme.of(context).colorScheme.primary,
                innerColor: Colors.amber,
                height: 40,
                dif: 10,
                iconRadius: 10.0,
                selectedIconRadius: 13.0,
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