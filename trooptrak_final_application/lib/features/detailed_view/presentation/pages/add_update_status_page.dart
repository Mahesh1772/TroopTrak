// lib/presentation/pages/add_update_status_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
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
    _startDateTime = widget.status != null
        ? DateTime.parse(widget.status!.startId)
        : DateTime.now();
    _endDateTime = widget.status != null
        ? DateTime.parse(widget.status!.endId)
        : DateTime.now().add(const Duration(hours: 1));
  }

  @override
  void dispose() {
    _statusNameController.dispose();
    super.dispose();
  }

  Future<void> _selectDateTime(bool isStart) async {
    final date = await showDatePicker(
      context: context,
      initialDate: isStart ? _startDateTime : _endDateTime,
      firstDate: isStart ? DateTime(2000) : _startDateTime,
      lastDate: DateTime(2100),
      builder: (context, child) {
        final theme = Theme.of(context);
        final isDarkMode = theme.brightness == Brightness.dark;
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: theme.colorScheme.copyWith(
              primary: theme.colorScheme.secondary,
              onPrimary: Colors.white,
              surface: isDarkMode ? const Color.fromARGB(255, 45, 50, 65) : Colors.white,
              onSurface: isDarkMode ? Colors.white : theme.colorScheme.onSurface,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: theme.colorScheme.secondary,
              ),
            ),
            dialogBackgroundColor: isDarkMode ? const Color.fromARGB(255, 35, 40, 55) : Colors.white,
          ),
          child: child!,
        );
      },
    );
    if (date != null) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(isStart ? _startDateTime : _endDateTime),
        builder: (context, child) {
          final theme = Theme.of(context);
          final isDarkMode = theme.brightness == Brightness.dark;
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: theme.colorScheme.copyWith(
                primary: theme.colorScheme.secondary,
                onPrimary: Colors.white,
                surface: isDarkMode ? const Color.fromARGB(255, 45, 50, 65) : Colors.white,
                onSurface: isDarkMode ? Colors.white : theme.colorScheme.onSurface,
              ),
              textButtonTheme: TextButtonThemeData(
                style: TextButton.styleFrom(
                  foregroundColor: theme.colorScheme.secondary,
                ),
              ),
              dialogBackgroundColor: isDarkMode ? const Color.fromARGB(255, 35, 40, 55) : Colors.white,
            ),
            child: child!,
          );
        },
      );
      if (time != null) {
        final selectedDateTime = DateTime(
          date.year,
          date.month,
          date.day,
          time.hour,
          time.minute,
        );

        if (!isStart && selectedDateTime.isBefore(_startDateTime)) {
          final theme = Theme.of(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text(
                'End date/time cannot be before start date/time',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 1.2,
                ),
              ),
              backgroundColor: theme.colorScheme.error,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
              margin: const EdgeInsets.all(16),
            ),
          );
          return;
        }

        setState(() {
          if (isStart) {
            _startDateTime = selectedDateTime;
            // If end date is before new start date, update it
            if (_endDateTime.isBefore(_startDateTime)) {
              _endDateTime = _startDateTime.add(const Duration(hours: 1));
            }
          } else {
            _endDateTime = selectedDateTime;
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Back Button and Title
                  InkWell(
                    onTap: () => Navigator.pop(context),
                    child: Icon(
                      Icons.arrow_back_sharp,
                      color: theme.colorScheme.tertiary,
                      size: 25.sp,
                    ),
                  ),
                  SizedBox(height: 20.h),
                  Text(
                    widget.status == null ? "Add New Status  ✍️" : "Update Status  ✍️",
                    style: GoogleFonts.poppins(
                      fontSize: 30.sp,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.tertiary,
                    ),
                  ),
                  Text(
                    widget.status == null ? "Fill in the details for the new status" : "Edit the status details",
                    style: GoogleFonts.poppins(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w300,
                      color: theme.colorScheme.tertiary,
                    ),
                  ),
                  SizedBox(height: 32.h),

                  // Status Type Dropdown
                  Container(
                    height: 70.h,
                    decoration: BoxDecoration(
                      color: isDarkMode ? const Color.fromARGB(255, 45, 50, 65) : theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(12.r),
                      boxShadow: [
                        BoxShadow(
                          color: isDarkMode ? Colors.black.withOpacity(0.3) : Colors.black.withOpacity(0.1),
                          blurRadius: 4.r,
                          offset: Offset(0, 2.h),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      child: DropdownButtonFormField<String>(
                        value: _statusType,
                        items: _statusTypes
                            .map((type) => DropdownMenuItem(
                                  value: type,
                                  child: Text(
                                    type,
                                    style: GoogleFonts.poppins(
                                      color: isDarkMode ? Colors.white : theme.colorScheme.onSurface,
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ))
                            .toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => _statusType = value);
                          }
                        },
                        decoration: InputDecoration(
                          labelText: 'Status Type',
                          labelStyle: GoogleFonts.poppins(
                            color: theme.colorScheme.tertiary.withOpacity(0.7),
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                          ),
                          border: InputBorder.none,
                        ),
                        validator: (value) {
                          if (value == _statusTypes[0]) {
                            return 'Please select a status type';
                          }
                          return null;
                        },
                        dropdownColor: isDarkMode ? const Color.fromARGB(255, 45, 50, 65) : theme.colorScheme.surface,
                      ),
                    ),
                  ),
                  SizedBox(height: 24.h),

                  // Status Name Field
                  Container(
                    height: 70.h,
                    decoration: BoxDecoration(
                      color: isDarkMode ? const Color.fromARGB(255, 45, 50, 65) : theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(12.r),
                      boxShadow: [
                        BoxShadow(
                          color: isDarkMode ? Colors.black.withOpacity(0.3) : Colors.black.withOpacity(0.1),
                          blurRadius: 4.r,
                          offset: Offset(0, 2.h),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      child: TextFormField(
                        controller: _statusNameController,
                        style: GoogleFonts.poppins(
                          color: isDarkMode ? Colors.white : theme.colorScheme.onSurface,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w500,
                        ),
                        decoration: InputDecoration(
                          labelText: 'Status Name',
                          labelStyle: GoogleFonts.poppins(
                            color: theme.colorScheme.tertiary.withOpacity(0.7),
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                          ),
                          border: InputBorder.none,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a status name';
                          }
                          return null;
                        },
                      ),
                    ),
                  ),
                  SizedBox(height: 24.h),

                  // Date Time Pickers
                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () => _selectDateTime(true),
                          child: Container(
                            height: 70.h,
                            decoration: BoxDecoration(
                              color: isDarkMode ? const Color.fromARGB(255, 45, 50, 65) : theme.colorScheme.surface,
                              borderRadius: BorderRadius.circular(12.r),
                              boxShadow: [
                                BoxShadow(
                                  color: isDarkMode ? Colors.black.withOpacity(0.3) : Colors.black.withOpacity(0.1),
                                  blurRadius: 4.r,
                                  offset: Offset(0, 2.h),
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16.w),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Start Date',
                                    style: GoogleFonts.poppins(
                                      color: theme.colorScheme.tertiary.withOpacity(0.7),
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  SizedBox(height: 4.h),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        DateFormat('dd MMM yyyy HH:mm').format(_startDateTime),
                                        style: GoogleFonts.poppins(
                                          color: theme.colorScheme.tertiary,
                                          fontSize: 14.sp,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      Icon(
                                        Icons.calendar_today_rounded,
                                        color: theme.colorScheme.tertiary,
                                        size: 20.sp,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 16.w),
                      Expanded(
                        child: InkWell(
                          onTap: () => _selectDateTime(false),
                          child: Container(
                            height: 70.h,
                            decoration: BoxDecoration(
                              color: isDarkMode ? const Color.fromARGB(255, 45, 50, 65) : theme.colorScheme.surface,
                              borderRadius: BorderRadius.circular(12.r),
                              boxShadow: [
                                BoxShadow(
                                  color: isDarkMode ? Colors.black.withOpacity(0.3) : Colors.black.withOpacity(0.1),
                                  blurRadius: 4.r,
                                  offset: Offset(0, 2.h),
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16.w),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'End Date',
                                    style: GoogleFonts.poppins(
                                      color: theme.colorScheme.tertiary.withOpacity(0.7),
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  SizedBox(height: 4.h),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        DateFormat('dd MMM yyyy HH:mm').format(_endDateTime),
                                        style: GoogleFonts.poppins(
                                          color: theme.colorScheme.tertiary,
                                          fontSize: 14.sp,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      Icon(
                                        Icons.calendar_today_rounded,
                                        color: theme.colorScheme.tertiary,
                                        size: 20.sp,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 32.h),

                  // Save Button
                  SizedBox(
                    width: double.infinity,
                    height: 48.h,
                    child: ElevatedButton.icon(
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
                      icon: Icon(
                        widget.status == null ? Icons.add_rounded : Icons.save_rounded,
                        size: 20.sp,
                        color: Colors.white,
                      ),
                      label: Text(
                        widget.status == null ? 'ADD STATUS' : 'UPDATE STATUS',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                          fontSize: 14.sp,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.secondary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 24.h),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
