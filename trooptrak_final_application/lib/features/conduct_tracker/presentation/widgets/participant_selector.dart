import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ParticipantSelector extends StatefulWidget {
  final List<String> selectedParticipants;
  final Map<String, String> soldierReason;
  final String? conductType;
  final Function(List<String>, Map<String, String>, List<String>) onParticipantsChanged;

  const ParticipantSelector({
    super.key,
    required this.selectedParticipants,
    required this.soldierReason,
    required this.conductType,
    required this.onParticipantsChanged,
  });

  @override
  State<ParticipantSelector> createState() => _ParticipantSelectorState();
}

class _ParticipantSelectorState extends State<ParticipantSelector> {
  List<Map<String, dynamic>> _allSoldiers = [];
  String _searchQuery = '';
  List<String> _nonParticipants = [];

  @override
  void initState() {
    super.initState();
    _loadSoldiers();
  }

  Future<void> _loadSoldiers() async {
    final snapshot = await FirebaseFirestore.instance.collection('Users').get();
    final soldiers = snapshot.docs
        .map((doc) => {...doc.data(), 'id': doc.id})
        .toList();
    
    setState(() {
      _allSoldiers = soldiers;
      _updateNonParticipants();
    });
  }

  void _updateNonParticipants() {
    _nonParticipants = _allSoldiers
        .map((s) => s['id'].toString())
        .where((id) => !widget.selectedParticipants.contains(id))
        .toList();
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

    _updateNonParticipants();
    widget.onParticipantsChanged(updatedParticipants, updatedReasons, _nonParticipants);
  }

  List<Map<String, dynamic>> get _filteredSoldiers {
    return _allSoldiers.where((soldier) {
      final name = soldier['name'].toString().toLowerCase();
      return name.contains(_searchQuery.toLowerCase());
    }).toList();
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
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Select Participants',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () {
                if (widget.selectedParticipants.length == _allSoldiers.length) {
                  // Deselect all
                  widget.onParticipantsChanged([], {}, []);
                } else {
                  // Select all
                  final allSoldierIds = _allSoldiers.map((s) => s['id'].toString()).toList();
                  widget.onParticipantsChanged(allSoldierIds, {}, []);
                }
              },
              child: Text(
                widget.selectedParticipants.length == _allSoldiers.length
                    ? 'Deselect All'
                    : 'Select All',
              ),
            ),
          ],
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