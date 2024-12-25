import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../domain/usecases/filter_participants_usecase.dart';
import '../providers/conduct_provider.dart';

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
  late List<String> _selectedParticipants;
  late Map<String, String> _soldierReason;
  List<Map<String, dynamic>> _allSoldiers = [];
  String _searchQuery = '';
  List<String> _nonParticipants = [];

  @override
  void initState() {
    super.initState();
    _loadSoldiers();
  }

  @override
  void didUpdateWidget(ParticipantSelector oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.conductType != oldWidget.conductType) {
      _applyAutomaticFiltering();
    }
  }

  Future<void> _applyAutomaticFiltering() async {
    if (widget.conductType == null) return;

    final provider = context.read<ConductProvider>();
    final allSoldiers = await provider.getAllSoldierIds();
    final statusList = await provider.getSoldiersStatus();
    
    final filterUseCase = FilterParticipantsUseCase();
    final soldierReason = await filterUseCase.execute(widget.conductType!, statusList);

    setState(() {
      _selectedParticipants = allSoldiers
          .where((id) => !soldierReason.containsKey(id))
          .toList();
      _soldierReason = soldierReason;
    });

    widget.onParticipantsChanged(
      _selectedParticipants,
      _soldierReason,
      allSoldiers.where((id) => soldierReason.containsKey(id)).toList(),
    );
  }

  Future<void> _loadSoldiers() async {
    final snapshot = await FirebaseFirestore.instance.collection('Users').get();
    final soldiers = snapshot.docs
        .map((doc) => {...doc.data(), 'id': doc.id})
        .toList();
    
    setState(() {
      _allSoldiers = soldiers;
      
      // Auto-select all soldiers if this is a new conduct (i.e., selectedParticipants is empty)
      if (widget.selectedParticipants.isEmpty) {
        final allSoldierIds = soldiers.map((s) => s['id'].toString()).toList();
        widget.onParticipantsChanged(allSoldierIds, {}, []);
      } else {
        _updateNonParticipants();
      }
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
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: isDarkMode 
                ? Colors.black.withOpacity(0.2) 
                : Colors.grey[100],
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: TextField(
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
            style: GoogleFonts.poppins(
              color: isDarkMode ? Colors.white : Colors.black87,
              fontSize: 14.sp,
            ),
            decoration: InputDecoration(
              hintText: 'Search Soldiers',
              hintStyle: GoogleFonts.poppins(
                color: isDarkMode ? Colors.white38 : Colors.black38,
                fontSize: 14.sp,
              ),
              prefixIcon: Icon(
                Icons.search_rounded,
                color: isDarkMode ? Colors.white38 : Colors.black38,
                size: 20.sp,
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
            ),
          ),
        ),
        SizedBox(height: 16.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Select Participants',
              style: GoogleFonts.poppins(
                color: isDarkMode ? Colors.white : Colors.black87,
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            TextButton(
              onPressed: () {
                if (widget.selectedParticipants.length == _allSoldiers.length) {
                  widget.onParticipantsChanged([], {}, []);
                } else {
                  final allSoldierIds = _allSoldiers.map((s) => s['id'].toString()).toList();
                  widget.onParticipantsChanged(allSoldierIds, {}, []);
                }
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: isDarkMode 
                      ? theme.colorScheme.secondary.withOpacity(0.15)
                      : theme.colorScheme.secondary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Text(
                  widget.selectedParticipants.length == _allSoldiers.length
                      ? 'DESELECT ALL'
                      : 'SELECT ALL',
                  style: GoogleFonts.poppins(
                    color: isDarkMode
                        ? Colors.white.withOpacity(0.9)
                        : theme.colorScheme.secondary,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _filteredSoldiers.length,
          itemBuilder: (context, index) {
            final soldier = _filteredSoldiers[index];
            final isSelected = widget.selectedParticipants.contains(soldier['id']);
            
            return Padding(
              padding: EdgeInsets.only(bottom: 8.h),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      isSelected 
                          ? theme.colorScheme.secondary.withOpacity(isDarkMode ? 0.3 : 0.1)
                          : isDarkMode 
                              ? Colors.black.withOpacity(0.2) 
                              : Colors.grey[100]!,
                      isSelected 
                          ? theme.colorScheme.secondary.withOpacity(isDarkMode ? 0.1 : 0.05)
                          : isDarkMode 
                              ? Colors.black.withOpacity(0.1) 
                              : Colors.grey[50]!,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color: isSelected 
                        ? theme.colorScheme.secondary.withOpacity(isDarkMode ? 0.5 : 0.3)
                        : Colors.transparent,
                    width: 1,
                  ),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => _toggleParticipant(soldier['id']),
                    borderRadius: BorderRadius.circular(12.r),
                    child: Padding(
                      padding: EdgeInsets.all(12.w),
                      child: Row(
                        children: [
                          Container(
                            width: 40.w,
                            height: 40.w,
                            decoration: BoxDecoration(
                              color: isSelected 
                                  ? theme.colorScheme.secondary.withOpacity(0.9)
                                  : isDarkMode 
                                      ? Colors.white.withOpacity(0.1)
                                      : Colors.white,
                              borderRadius: BorderRadius.circular(8.r),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 4,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Image.asset(
                                "lib/assets/army-ranks/${soldier['rank'].toString().toLowerCase()}.png",
                                width: 24.w,
                                height: 24.w,
                                color: isSelected 
                                    ? Colors.white
                                    : isDarkMode 
                                        ? Colors.white 
                                        : Colors.black87,
                              ),
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  soldier['name'],
                                  style: GoogleFonts.poppins(
                                    color: isDarkMode ? Colors.white : Colors.black87,
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  soldier['rank'],
                                  style: GoogleFonts.poppins(
                                    color: isDarkMode ? Colors.white70 : Colors.black54,
                                    fontSize: 12.sp,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                            decoration: BoxDecoration(
                              color: isSelected 
                                  ? Colors.red.withOpacity(0.15)
                                  : theme.colorScheme.secondary.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(20.r),
                            ),
                            child: Text(
                              isSelected ? 'REMOVE' : 'ADD',
                              style: GoogleFonts.poppins(
                                color: isSelected 
                                    ? Colors.red.shade400
                                    : isDarkMode
                                        ? theme.colorScheme.secondary.withOpacity(0.95)
                                        : theme.colorScheme.secondary.withOpacity(0.9),
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
} 