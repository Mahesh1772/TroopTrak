import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/guard_duty.dart';
import '../providers/guard_duty_provider.dart';
import '../widgets/org_chart_tile.dart';

class AddGuardDutyScreen extends StatefulWidget {
  final bool isEditing;
  final GuardDuty? dutyToEdit;

  const AddGuardDutyScreen({
    super.key,
    this.isEditing = false,
    this.dutyToEdit,
  }) : assert(isEditing == false || dutyToEdit != null);

  @override
  State<AddGuardDutyScreen> createState() => _AddGuardDutyScreenState();
}

class _AddGuardDutyScreenState extends State<AddGuardDutyScreen> {
  late final TextEditingController _dateController;
  late final TextEditingController _startTimeController;
  late final TextEditingController _endTimeController;
  late final TextEditingController _dutyTypeController;
  late final TextEditingController _pointsController;
  late Map<String, String> _participants;

  @override
  void initState() {
    super.initState();
    _dateController = TextEditingController(
      text: widget.isEditing ? widget.dutyToEdit!.dutyDate : '',
    );
    
    // Parse and format times properly
    _startTimeController = TextEditingController(
      text: widget.isEditing 
          ? _formatTimeString(widget.dutyToEdit!.startTime)
          : '',
    );
    _endTimeController = TextEditingController(
      text: widget.isEditing 
          ? _formatTimeString(widget.dutyToEdit!.endTime)
          : '',
    );
    
    _dutyTypeController = TextEditingController(
      text: widget.isEditing ? widget.dutyToEdit!.dutyType : '',
    );
    _pointsController = TextEditingController(
      text: widget.isEditing ? widget.dutyToEdit!.points.toString() : '',
    );
    _participants = widget.isEditing 
        ? Map<String, String>.from(widget.dutyToEdit!.participants)
        : {};
  }

  // Helper method to format time strings
  String _formatTimeString(String time) {
    try {
      // Handle different time formats
      if (time.contains('AM') || time.contains('PM')) {
        return time; // Already in correct format
      }
      
      // Parse 24-hour format
      final parts = time.split(':');
      if (parts.length == 2) {
        final hour = int.parse(parts[0]);
        final minute = int.parse(parts[1]);
        
        final period = hour >= 12 ? 'PM' : 'AM';
        final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
        
        return '${displayHour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} $period';
      }
      return time;
    } catch (e) {
      return time; // Return original if parsing fails
    }
  }

  @override
  void dispose() {
    _dateController.dispose();
    _startTimeController.dispose();
    _endTimeController.dispose();
    _dutyTypeController.dispose();
    _pointsController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date != null) {
      setState(() {
        _dateController.text = DateFormat('yyyy-MM-dd').format(date);
      });
    }
  }

  Future<void> _selectTime(BuildContext context, bool isStartTime) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    
    if (picked != null) {
      setState(() {
        final hour = picked.hour;
        final minute = picked.minute;
        final period = picked.period == DayPeriod.am ? 'AM' : 'PM';
        final displayHour = picked.hourOfPeriod == 0 ? 12 : picked.hourOfPeriod;
        
        final timeString = 
            '${displayHour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} $period';
            
        if (isStartTime) {
          _startTimeController.text = timeString;
        } else {
          _endTimeController.text = timeString;
        }
      });
    }
  }

  void _updateParticipants(Map<String, String> newParticipants) {
    setState(() {
      _participants = newParticipants;
    });
  }

  void _saveGuardDuty() {
    // Convert times to consistent format before saving
    final startTime = _startTimeController.text;
    final endTime = _endTimeController.text;
    
    final newDuty = GuardDuty(
      id: widget.isEditing ? widget.dutyToEdit!.id : '',
      dutyDate: _dateController.text,
      startTime: startTime,
      endTime: endTime,
      dutyType: _dutyTypeController.text,
      points: int.tryParse(_pointsController.text) ?? 0,
      participants: _participants,
    );

    if (widget.isEditing) {
      context.read<GuardDutyProvider>().updateDuty(
        widget.dutyToEdit!,  // old duty
        newDuty,            // new duty
      );
    } else {
      context.read<GuardDutyProvider>().addDuty(newDuty);
    }
    Navigator.pop(context);
  }

  bool _validateForm() {
    if (_dateController.text.isEmpty ||
        _startTimeController.text.isEmpty ||
        _endTimeController.text.isEmpty ||
        _dutyTypeController.text.isEmpty ||
        _pointsController.text.isEmpty ||
        _participants.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? 'Edit Guard Duty' : 'Add Guard Duty'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.sp),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date Picker
            InkWell(
              onTap: _selectDate,
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: 'Date',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                child: Text(_dateController.text.isEmpty 
                  ? 'Select Date' 
                  : _dateController.text),
              ),
            ),
            SizedBox(height: 16.h),

            // Time Pickers
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => _selectTime(context, true),
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: 'Start Time',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      child: Text(_startTimeController.text.isEmpty 
                        ? 'Start Time' 
                        : _startTimeController.text),
                    ),
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: InkWell(
                    onTap: () => _selectTime(context, false),
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: 'End Time',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      child: Text(_endTimeController.text.isEmpty 
                        ? 'End Time' 
                        : _endTimeController.text),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),

            // Duty Type and Points
            TextField(
              controller: _dutyTypeController,
              decoration: InputDecoration(
                labelText: 'Duty Type',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
            ),
            SizedBox(height: 16.h),
            TextField(
              controller: _pointsController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Points',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
            ),
            SizedBox(height: 24.h),

            // Participants Grid
            Text(
              'Participants',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8.h),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 1,
                crossAxisSpacing: 8.w,
                mainAxisSpacing: 8.h,
              ),
              itemCount: 9,
              itemBuilder: (context, index) {
                final entries = _participants.entries.toList();
                return OrgChartTile(
                  heroTag: 'participant_$index',
                  rank: index < entries.length ? entries[index].value : 'NA',
                  name: index < entries.length ? entries[index].key : 'NA$index',
                  onParticipantsUpdated: _updateParticipants,
                  currentParticipants: _participants,
                );
              },
            ),

            SizedBox(height: 24.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveGuardDuty,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                child: Text(
                  widget.isEditing ? 'Update Guard Duty' : 'Add Guard Duty',
                  style: TextStyle(fontSize: 16.sp),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 