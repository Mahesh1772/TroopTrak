import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/conduct_provider.dart';

class DateSelector extends StatelessWidget {
  const DateSelector({super.key});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () async {
        final DateTime? picked = await showDatePicker(
          context: context,
          initialDate: context.read<ConductProvider>().selectedDate,
          firstDate: DateTime(2022),
          lastDate: DateTime(2025),
        );
        if (picked != null) {
          context.read<ConductProvider>().updateSelectedDate(picked);
        }
      },
      child: const Text('Select Date'),
    );
  }
} 