import 'package:flutter/material.dart';

class ConductTile extends StatelessWidget {
  final String conductType;
  final String conductName;
  final int conductNumber;

  const ConductTile({
    super.key,
    required this.conductName,
    required this.conductType,
    required this.conductNumber,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      color: Colors.transparent,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 30.0),
            child: Container(
              height: 70,
              width: 70,
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 53, 14, 145),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(
                  (conductNumber + 1).toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  conductType,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  conductName,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_outlined),
        ],
      ),
    );
  }
} 