import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/conduct.dart';
import '../providers/conduct_provider.dart';
import '../widgets/participant_selector.dart';

class AddConductScreen extends StatefulWidget {
  final Conduct? conduct; // Optional - if provided, we're in edit mode

  const AddConductScreen({super.key, this.conduct});

  @override
  State<AddConductScreen> createState() => _AddConductScreenState();
}

class _AddConductScreenState extends State<AddConductScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _conductNameController;
  String? _selectedConductType;
  late String _startDate;
  late String _startTime;
  late String _endTime;
  List<String> _selectedParticipants = [];
  Map<String, String> _soldierReason = {};

  final List<String> _conductTypes = [
    'Run',
    'S&P',
    'IMT',
    'ATP',
    'IPPT',
    'SOC',
    'Metabolic Circuit',
    'Combat Circuit',
    'Route March',
    'Outfield',
  ];

  @override
  void initState() {
    super.initState();
    _conductNameController = TextEditingController(text: widget.conduct?.conductName);
    _selectedConductType = widget.conduct?.conductType;
    _startDate = widget.conduct?.startDate ?? DateFormat('d MMM yyyy').format(DateTime.now());
    _startTime = widget.conduct?.startTime ?? 'Start Time:';
    _endTime = widget.conduct?.endTime ?? 'End Time:';
    _selectedParticipants = widget.conduct?.participants ?? [];
    _soldierReason = widget.conduct?.soldierReason ?? {};
  }

  @override
  void dispose() {
    _conductNameController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateFormat('d MMM yyyy').parse(_startDate),
      firstDate: DateTime(2022),
      lastDate: DateTime(2025),
    );
    if (picked != null) {
      setState(() {
        _startDate = DateFormat('d MMM yyyy').format(picked);
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
        if (isStartTime) {
          _startTime = picked.format(context);
        } else {
          _endTime = picked.format(context);
        }
      });
    }
  }

  void _saveConduct() {
    if (!_formKey.currentState!.validate()) return;

    final conduct = Conduct(
      id: widget.conduct?.id ?? '',
      conductName: _conductNameController.text,
      conductType: _selectedConductType!,
      startDate: _startDate,
      startTime: _startTime,
      endTime: _endTime,
      participants: _selectedParticipants,
      soldierReason: _soldierReason, nonParticipants: [],
    );

    if (widget.conduct != null) {
      context.read<ConductProvider>().updateConduct(conduct);
    } else {
      context.read<ConductProvider>().addConduct(conduct);
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.conduct != null ? 'Edit Conduct' : 'Add New Conduct'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _conductNameController,
                decoration: const InputDecoration(labelText: 'Conduct Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a conduct name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedConductType,
                decoration: const InputDecoration(labelText: 'Conduct Type'),
                items: _conductTypes.map((type) {
                  return DropdownMenuItem(value: type, child: Text(type));
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedConductType = value;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a conduct type';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              ListTile(
                title: Text(_startDate),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => _selectDate(context),
              ),
              ListTile(
                title: Text(_startTime),
                trailing: const Icon(Icons.access_time),
                onTap: () => _selectTime(context, true),
              ),
              ListTile(
                title: Text(_endTime),
                trailing: const Icon(Icons.access_time),
                onTap: () => _selectTime(context, false),
              ),
              const SizedBox(height: 16),
              ParticipantSelector(
                selectedParticipants: _selectedParticipants,
                soldierReason: _soldierReason,
                conductType: _selectedConductType,
                onParticipantsChanged: (participants, reasons) {
                  setState(() {
                    _selectedParticipants = participants;
                    _soldierReason = reasons;
                  });
                },
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveConduct,
                  child: Text(widget.conduct != null ? 'Update Conduct' : 'Add Conduct'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 