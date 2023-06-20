import 'package:flutter/material.dart';
import 'package:prototype_1/screens/guard_duty_tracker_screen.dart/util/custom_rect_tween.dart';

class AddDutySoldiersCard extends StatefulWidget {
  const AddDutySoldiersCard({super.key});

  @override
  State<AddDutySoldiersCard> createState() => _AddDutySoldiersCardState();
}

late String _heroAddDutySoldiers;

class _AddDutySoldiersCardState extends State<AddDutySoldiersCard> {
  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: _heroAddDutySoldiers,
      createRectTween: (begin, end) {
        return CustomRectTween(begin: begin!, end: end!);
      },
      child: Container(
        height: 400,
        width: 300,
        decoration: const BoxDecoration(
          color: Colors.black54,
        ),
      ),
    );
  }
}
