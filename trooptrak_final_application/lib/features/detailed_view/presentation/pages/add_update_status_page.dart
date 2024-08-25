import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/status.dart';
import '../providers/status_provider.dart';

class AddUpdateStatusPage extends StatefulWidget {
  final String userId;
  final Status? status;

  const AddUpdateStatusPage({
    Key? key,
    required this.userId,
    this.status,
  }) : super(key: key);

  @override
  _AddUpdateStatusPageState createState() => _AddUpdateStatusPageState();
}

class _AddUpdateStatusPageState extends State<AddUpdateStatusPage> {
  final _formKey = GlobalKey<FormState>();
  late String _statusType;
  late TextEditingController _statusNameController;
  late String _startDate;
  late String _endDate;

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
    _startDate = widget.status?.startDate ?? DateFormat('d MMM yyyy').format(DateTime.now());
    _endDate = widget.status?.endDate ?? DateFormat('d MMM yyyy').format(DateTime.now());
  }

  @override
  void dispose() {
    _statusNameController.dispose();
    super.dispose();
  }

  void _showDatePicker(bool isStartDate) {
    showDatePicker(
      context: context,
      initialDate: DateFormat('d MMM yyyy').parse(isStartDate ? _startDate : _endDate),
      firstDate: DateTime(1960),
      lastDate: DateTime(2030),
    ).then((value) {
      if (value != null) {
        setState(() {
          if (isStartDate) {
            _startDate = DateFormat('d MMM yyyy').format(value);
          } else {
            _endDate = DateFormat('d MMM yyyy').format(value);
          }
        });
      }
    });
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
                        controller: TextEditingController(text: _startDate),
                        decoration: const InputDecoration(
                          labelText: 'Start Date',
                          border: OutlineInputBorder(),
                        ),
                        onTap: () => _showDatePicker(true),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        readOnly: true,
                        controller: TextEditingController(text: _endDate),
                        decoration: const InputDecoration(
                          labelText: 'End Date',
                          border: OutlineInputBorder(),
                        ),
                        onTap: () => _showDatePicker(false),
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
                        startDate: _startDate,
                        endDate: _endDate,
                        startId: DateFormat('yyyy-MM-dd HH:mm:ss').format(DateFormat('d MMM yyyy').parse(_startDate)),
                        endId: DateFormat('yyyy-MM-dd HH:mm:ss').format(DateFormat('d MMM yyyy').parse(_endDate)),
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
