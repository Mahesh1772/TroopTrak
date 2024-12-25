import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DutyParticipantSelector extends StatefulWidget {
  final Map<String, String> selectedParticipants;
  final Function(Map<String, String>) onParticipantsChanged;

  const DutyParticipantSelector({
    super.key,
    required this.selectedParticipants,
    required this.onParticipantsChanged,
  });

  @override
  State<DutyParticipantSelector> createState() => _DutyParticipantSelectorState();
}

class _DutyParticipantSelectorState extends State<DutyParticipantSelector> {
  List<Map<String, dynamic>> _availableSoldiers = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSoldiers();
  }

  Future<void> _loadSoldiers() async {
    final snapshot = await FirebaseFirestore.instance.collection('Users').get();
    setState(() {
      _availableSoldiers = snapshot.docs
          .map((doc) => {
                'id': doc.id,
                'name': doc.data()['name'],
                'rank': doc.data()['rank'],
              })
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Duty Participants',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 8.h),
        TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Search soldiers...',
            prefixIcon: const Icon(Icons.search),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
            ),
          ),
          onChanged: (value) => setState(() {}),
        ),
        SizedBox(height: 16.h),
        _buildParticipantsList(),
      ],
    );
  }

  Widget _buildParticipantsList() {
    final searchQuery = _searchController.text.toLowerCase();
    final filteredSoldiers = _availableSoldiers.where((soldier) {
      return soldier['name'].toLowerCase().contains(searchQuery) ||
          soldier['rank'].toLowerCase().contains(searchQuery);
    }).toList();

    return Container(
      height: 200.h,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: ListView.builder(
        itemCount: filteredSoldiers.length,
        itemBuilder: (context, index) {
          final soldier = filteredSoldiers[index];
          final isSelected = widget.selectedParticipants
              .containsKey(soldier['id']);

          return CheckboxListTile(
            title: Text(soldier['name']),
            subtitle: Text(soldier['rank']),
            value: isSelected,
            onChanged: (selected) {
              final updatedParticipants = Map<String, String>.from(
                widget.selectedParticipants,
              );
              
              if (selected == true) {
                updatedParticipants[soldier['id']] = soldier['rank'];
              } else {
                updatedParticipants.remove(soldier['id']);
              }
              
              widget.onParticipantsChanged(updatedParticipants);
            },
          );
        },
      ),
    );
  }
} 