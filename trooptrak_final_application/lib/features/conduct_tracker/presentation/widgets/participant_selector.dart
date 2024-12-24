import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ParticipantSelector extends StatefulWidget {
  final List<String> selectedParticipants;
  final Map<String, String> soldierReason;
  final String? conductType;
  final Function(List<String>, Map<String, String>) onParticipantsChanged;

  const ParticipantSelector({
    Key? key,
    required this.selectedParticipants,
    required this.soldierReason,
    required this.conductType,
    required this.onParticipantsChanged,
  }) : super(key: key);

  @override
  State<ParticipantSelector> createState() => _ParticipantSelectorState();
}

class _ParticipantSelectorState extends State<ParticipantSelector> {
  List<Map<String, dynamic>> _allSoldiers = [];
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadSoldiers();
  }

  Future<void> _loadSoldiers() async {
    final snapshot = await FirebaseFirestore.instance.collection('Users').get();
    setState(() {
      _allSoldiers = snapshot.docs
          .map((doc) => {...doc.data(), 'id': doc.id})
          .toList();
    });
  }

  List<Map<String, dynamic>> get _filteredSoldiers {
    return _allSoldiers.where((soldier) {
      final name = soldier['name'].toString().toLowerCase();
      return name.contains(_searchQuery.toLowerCase());
    }).toList();
  }

  void _toggleParticipant(String soldierId) {
    final List<String> updatedParticipants = [...widget.selectedParticipants];
    final Map<String, String> updatedReasons = {...widget.soldierReason};

    if (updatedParticipants.contains(soldierId)) {
      updatedParticipants.remove(soldierId);
      updatedReasons[soldierId] = 'Removed from conduct';
    } else {
      updatedParticipants.add(soldierId);
      updatedReasons.remove(soldierId);
    }

    widget.onParticipantsChanged(updatedParticipants, updatedReasons);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          decoration: const InputDecoration(
            labelText: 'Search Soldiers',
            prefixIcon: Icon(Icons.search),
          ),
          onChanged: (value) {
            setState(() {
              _searchQuery = value;
            });
          },
        ),
        const SizedBox(height: 16),
        const Text(
          'Select Participants',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _filteredSoldiers.length,
          itemBuilder: (context, index) {
            final soldier = _filteredSoldiers[index];
            final isSelected = widget.selectedParticipants.contains(soldier['id']);

            return ListTile(
              title: Text(soldier['name']),
              subtitle: Text(soldier['rank']),
              trailing: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: isSelected ? Colors.red : Colors.green,
                ),
                onPressed: () => _toggleParticipant(soldier['id']),
                child: Text(
                  isSelected ? 'REMOVE' : 'ADD',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
} 