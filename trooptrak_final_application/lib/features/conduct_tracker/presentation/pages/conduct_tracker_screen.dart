import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/conduct_provider.dart';
import '../widgets/conduct_calendar.dart';
import '../widgets/conduct_bar_graph.dart';
import '../widgets/conduct_list.dart';
import '../widgets/date_selector.dart';
import '../widgets/add_conduct_button.dart';
import '../widgets/no_conducts_widget.dart';
import '../../domain/entities/conduct.dart';

class ConductTrackerScreen extends StatelessWidget {
  const ConductTrackerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.all(20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    DateSelector(),
                    AddConductButton(),
                  ],
                ),
              ),
              const ConductCalendar(),
              const SizedBox(height: 30),
              StreamBuilder<List<Conduct>>(
                stream: context.watch<ConductProvider>().conducts,
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final conducts = snapshot.data!;
                  final selectedDate = context.watch<ConductProvider>().selectedDate;
                  final todayConducts = context.read<ConductProvider>()
                      .filterConductsByDate(conducts, selectedDate);

                  if (todayConducts.isEmpty) {
                    return const NoConductsWidget();
                  }

                  return Column(
                    children: [
                      ConductBarGraph(
                        conducts: todayConducts,
                        participationStrength: context
                            .read<ConductProvider>()
                            .getParticipationStrength(todayConducts),
                      ),
                      const SizedBox(height: 20),
                      ConductList(conducts: todayConducts),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
} 