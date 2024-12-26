import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../providers/soldier_provider.dart';
import 'add_soldier_to_duty_tile.dart';
import 'custom_rect_tween.dart';
import 'hero_dialog_route.dart';

class AddDutySoldiersCard extends StatefulWidget {
  final String heroTag;
  final Map<String, String> currentParticipants;
  final Function(Map<String, String>) onParticipantsUpdated;

  const AddDutySoldiersCard({
    super.key,
    required this.heroTag,
    required this.currentParticipants,
    required this.onParticipantsUpdated,
  });

  @override
  State<AddDutySoldiersCard> createState() => _AddDutySoldiersCardState();
}

class _AddDutySoldiersCardState extends State<AddDutySoldiersCard> {
  late Map<String, String> selectedSoldiers;
  String searchText = '';

  @override
  void initState() {
    super.initState();
    selectedSoldiers = Map<String, String>.from(widget.currentParticipants);
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(16.0.sp),
        child: Hero(
          tag: widget.heroTag,
          createRectTween: (begin, end) {
            return CustomRectTween(begin: begin!, end: end!);
          },
          child: Material(
            color: Theme.of(context).cardColor,
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(16.sp),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Add Soldiers',
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 16.h),
                    TextField(
                      onChanged: (value) {
                        setState(() {
                          searchText = value;
                        });
                      },
                      decoration: InputDecoration(
                        hintText: 'Search soldiers...',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                    ),
                    SizedBox(height: 16.h),
                    Consumer<SoldierProvider>(
                      builder: (context, provider, child) {
                        if (provider.isLoading) {
                          return const CircularProgressIndicator();
                        }

                        if (provider.error != null) {
                          return Text('Error: ${provider.error}');
                        }

                        if (provider.soldiers.isEmpty) {
                          return const Text('No soldiers found');
                        }

                        final soldiers = provider.soldiers
                            .where((soldier) => 
                                soldier.name.toLowerCase().contains(searchText.toLowerCase()) ||
                                soldier.rank.toLowerCase().contains(searchText.toLowerCase()))
                            .toList();

                        return SizedBox(
                          height: 400.h,
                          child: ListView.builder(
                            itemCount: soldiers.length,
                            itemBuilder: (context, index) {
                              final soldier = soldiers[index];
                              return AddSoldierToDutyTile(
                                rank: soldier.rank,
                                name: soldier.name,
                                appointment: soldier.appointment,
                                isSelected: selectedSoldiers.containsKey(soldier.name),
                                onSelected: (selected) {
                                  setState(() {
                                    if (selected) {
                                      selectedSoldiers[soldier.name] = soldier.rank;
                                    } else {
                                      selectedSoldiers.remove(soldier.name);
                                    }
                                  });
                                },
                              );
                            },
                          ),
                        );
                      },
                    ),
                    SizedBox(height: 16.h),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          widget.onParticipantsUpdated(selectedSoldiers);
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 16.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                        ),
                        child: Text(
                          'Confirm Selection',
                          style: TextStyle(fontSize: 16.sp),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
} 