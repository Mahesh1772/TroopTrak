// lib/presentation/pages/add_update_status_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/status.dart';
import '../providers/status_provider.dart';

class AddUpdateStatusPage extends StatefulWidget {
  final String userId;
  final Status? status;

  const AddUpdateStatusPage({
    super.key,
    required this.userId,
    this.status,
  });

  @override
  _AddUpdateStatusPageState createState() => _AddUpdateStatusPageState();
}

class _AddUpdateStatusPageState extends State<AddUpdateStatusPage> {
  final _formKey = GlobalKey<FormState>();
  late String _statusType;
  late TextEditingController _statusNameController;
  late DateTime _startDateTime;
  late DateTime _endDateTime;

  final List<String> _statusTypes = [
    "Select status type...",
    "Excuse",
    "Leave",
    "Medical Appointment",
  ];

  @override
  void initState() {
    super.initState();
    _statusType = widget.status?.statusType ?? _statusTypes[0];
    _statusNameController = TextEditingController(text: widget.status?.statusName ?? '');
    _startDateTime = widget.status != null ? DateTime.parse(widget.status!.startId) : DateTime.now();
    _endDateTime = widget.status != null ? DateTime.parse(widget.status!.endId) : DateTime.now().add(const Duration(hours: 1));
  }

  @override
  void dispose() {
    _statusNameController.dispose();
    super.dispose();
  }

  void _showDateTimePicker(bool isStartDate) async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: isStartDate ? _startDateTime : _endDateTime,
      firstDate: DateTime(1960),
      lastDate: DateTime(2030),
    );

    if (pickedDate != null) {
      final pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(isStartDate ? _startDateTime : _endDateTime),
      );

      if (pickedTime != null) {
        setState(() {
          if (isStartDate) {
            _startDateTime = DateTime(
              pickedDate.year,
              pickedDate.month,
              pickedDate.day,
              pickedTime.hour,
              pickedTime.minute,
            );
          } else {
            _endDateTime = DateTime(
              pickedDate.year,
              pickedDate.month,
              pickedDate.day,
              pickedTime.hour,
              pickedTime.minute,
            );
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.status == null ? 'Add New Status' : 'Update Status'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DropdownButtonFormField<String>(
                  value: _statusType,
                  items: _statusTypes.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _statusType = newValue!;
                    });
                  },
                  decoration: const InputDecoration(
                    labelText: 'Status Type',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _statusNameController,
                  decoration: const InputDecoration(
                    labelText: 'Status Name',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a status name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        readOnly: true,
                        controller: TextEditingController(
                          text: DateFormat('dd MMM yyyy HH:mm').format(_startDateTime),
                        ),
                        decoration: const InputDecoration(
                          labelText: 'Start Date & Time',
                          border: OutlineInputBorder(),
                        ),
                        onTap: () => _showDateTimePicker(true),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        readOnly: true,
                        controller: TextEditingController(
                          text: DateFormat('dd MMM yyyy HH:mm').format(_endDateTime),
                        ),
                        decoration: const InputDecoration(
                          labelText: 'End Date & Time',
                          border: OutlineInputBorder(),
                        ),
                        onTap: () => _showDateTimePicker(false),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      final status = Status(
                        id: widget.status?.id ?? '',
                        statusType: _statusType,
                        statusName: _statusNameController.text,
                        startId: _startDateTime.toIso8601String(),
                        endId: _endDateTime.toIso8601String(),
                      );

                      if (widget.status == null) {
                        Provider.of<StatusProvider>(context, listen: false)
                            .addStatus(widget.userId, status);
                      } else {
                        Provider.of<StatusProvider>(context, listen: false)
                            .updateStatus(widget.userId, status);
                      }

                      Navigator.pop(context);
                    }
                  },
                  child: Text(widget.status == null ? 'Add Status' : 'Update Status'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
