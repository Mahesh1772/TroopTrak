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
    _startTimeController = TextEditingController(
      text: widget.isEditing ? widget.dutyToEdit!.startTime : '',
    );
    _endTimeController = TextEditingController(
      text: widget.isEditing ? widget.dutyToEdit!.endTime : '',
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

  Future<void> _selectTime(bool isStartTime) async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (time != null) {
      setState(() {
        final controller = isStartTime ? _startTimeController : _endTimeController;
        controller.text = time.format(context);
      });
    }
  }

  void _updateParticipants(Map<String, String> newParticipants) {
    setState(() {
      _participants = newParticipants;
    });
  }

  void _saveGuardDuty() {
    if (!_validateForm()) return;

    final provider = context.read<GuardDutyProvider>();
    
    final guardDuty = GuardDuty(
      id: widget.isEditing ? widget.dutyToEdit!.id : DateTime.now().toString(),
      dutyDate: _dateController.text,
      startTime: _startTimeController.text,
      endTime: _endTimeController.text,
      dutyType: _dutyTypeController.text,
      points: int.parse(_pointsController.text),
      participants: _participants,
    );

    if (widget.isEditing) {
      provider.updateDuty(widget.dutyToEdit!, guardDuty);
    } else {
      provider.addDuty(guardDuty);
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
                    onTap: () => _selectTime(true),
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
                    onTap: () => _selectTime(false),
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