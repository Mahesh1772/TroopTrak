import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../domain/entities/guard_duty.dart';
import '../providers/guard_duty_provider.dart';
import '../widgets/duty_participant_selector.dart';

class AddGuardDutyScreen extends StatefulWidget {
  final GuardDuty? dutyToEdit;

  const AddGuardDutyScreen({super.key, this.dutyToEdit});

  @override
  State<AddGuardDutyScreen> createState() => _AddGuardDutyScreenState();
}

class _AddGuardDutyScreenState extends State<AddGuardDutyScreen> {
  final _formKey = GlobalKey<FormState>();
  late DateTime _selectedDate;
  late TimeOfDay _startTime;
  late TimeOfDay _endTime;
  String _dutyType = 'Weekday'; // Default value
  Map<String, String> _selectedParticipants = {};

  @override
  void initState() {
    super.initState();
    if (widget.dutyToEdit != null) {
      _initializeWithExistingDuty();
    } else {
      _initializeNewDuty();
    }
  }

  void _initializeNewDuty() {
    _selectedDate = DateTime.now();
    _startTime = TimeOfDay.now();
    _endTime = TimeOfDay.now().replacing(hour: TimeOfDay.now().hour + 1);
  }

  void _initializeWithExistingDuty() {
    final duty = widget.dutyToEdit!;
    _selectedDate = _parseDate(duty.dutyDate);
    _startTime = _parseTime(duty.startTime);
    _endTime = _parseTime(duty.endTime);
    _dutyType = duty.dutyType;
    _selectedParticipants = duty.participants;
  }

  DateTime _parseDate(String date) {
    // Implement date parsing logic
    return DateTime.now(); // Placeholder
  }

  TimeOfDay _parseTime(String time) {
    // Implement time parsing logic
    return TimeOfDay.now(); // Placeholder
  }

  double _calculatePoints() {
    // Implement points calculation based on duty type and timing
    if (_dutyType == 'Weekend') return 2.0;
    if (_dutyType == 'Public Holiday') return 3.0;
    return 1.0; // Weekday
  }

  Future<void> _saveDuty() async {
    if (!_formKey.currentState!.validate()) return;

    final duty = GuardDuty(
      id: widget.dutyToEdit?.id ?? '',
      dutyDate: _selectedDate.toString(),
      startTime: _startTime.format(context),
      endTime: _endTime.format(context),
      dutyType: _dutyType,
      points: _calculatePoints(),
      participants: _selectedParticipants,
    );

    final provider = context.read<GuardDutyProvider>();
    
    try {
      if (widget.dutyToEdit != null) {
        await provider.updateDuty(widget.dutyToEdit!, duty);
      } else {
        await provider.addDuty(duty);
      }
      if (mounted) Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.dutyToEdit != null ? 'Edit Duty' : 'Add New Duty'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.sp),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDatePicker(),
              SizedBox(height: 16.h),
              _buildTimePickers(),
              SizedBox(height: 16.h),
              _buildDutyTypeSelector(),
              SizedBox(height: 16.h),
              DutyParticipantSelector(
                selectedParticipants: _selectedParticipants,
                onParticipantsChanged: (participants) {
                  setState(() => _selectedParticipants = participants);
                },
              ),
              SizedBox(height: 32.h),
              _buildSaveButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDatePicker() {
    return ListTile(
      title: const Text('Date'),
      subtitle: Text(_selectedDate.toString().split(' ')[0]),
      trailing: const Icon(Icons.calendar_today),
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: _selectedDate,
          firstDate: DateTime.now(),
          lastDate: DateTime.now().add(const Duration(days: 365)),
        );
        if (date != null) {
          setState(() => _selectedDate = date);
        }
      },
    );
  }

  Widget _buildTimePickers() {
    return Row(
      children: [
        Expanded(
          child: ListTile(
            title: const Text('Start Time'),
            subtitle: Text(_startTime.format(context)),
            onTap: () async {
              final time = await showTimePicker(
                context: context,
                initialTime: _startTime,
              );
              if (time != null) {
                setState(() => _startTime = time);
              }
            },
          ),
        ),
        Expanded(
          child: ListTile(
            title: const Text('End Time'),
            subtitle: Text(_endTime.format(context)),
            onTap: () async {
              final time = await showTimePicker(
                context: context,
                initialTime: _endTime,
              );
              if (time != null) {
                setState(() => _endTime = time);
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDutyTypeSelector() {
    return DropdownButtonFormField<String>(
      value: _dutyType,
      decoration: const InputDecoration(labelText: 'Duty Type'),
      items: ['Weekday', 'Weekend', 'Public Holiday']
          .map((type) => DropdownMenuItem(
                value: type,
                child: Text(type),
              ))
          .toList(),
      onChanged: (value) {
        if (value != null) {
          setState(() => _dutyType = value);
        }
      },
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _saveDuty,
        child: Text(
          widget.dutyToEdit != null ? 'Update Duty' : 'Add Duty',
          style: TextStyle(fontSize: 16.sp),
        ),
      ),
    );
  }
} 