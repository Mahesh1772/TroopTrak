import 'package:flutter/material.dart';
import '../../domain/entities/conduct.dart';
import 'conduct_tile.dart';
import '../pages/conduct_details_screen.dart';

class ConductList extends StatelessWidget {
  final List<Conduct> conducts;

  const ConductList({
    super.key,
    required this.conducts,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: conducts.length,
      itemBuilder: (context, index) {
        final conduct = conducts[index];
        return InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ConductDetailsScreen(conductId: conduct.id),
              ),
            );
          },
          child: ConductTile(
            conductNumber: index,
            conductName: conduct.conductName,
            conductType: conduct.conductType,
          ),
        );
      },
    );
  }
}