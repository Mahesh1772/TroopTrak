import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../domain/entities/conduct.dart';
import '../providers/conduct_provider.dart';
import '../widgets/participant_selector.dart';

class AddConductScreen extends StatefulWidget {
  final Conduct? conduct;

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
    _startTime = widget.conduct?.startTime ?? DateFormat('HH:mm').format(DateTime.now());
    _endTime = widget.conduct?.endTime ?? DateFormat('HH:mm').format(DateTime.now().add(const Duration(hours: 1)));
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

  void _onParticipantsChanged(List<String> participants, Map<String, String> reasons) async {
    final allSoldiers = await context.read<ConductProvider>().getAllSoldierIds();
    
    setState(() {
      _selectedParticipants = participants;
      _soldierReason = reasons;
    });
  }

  void _saveConduct() async {
    if (!_formKey.currentState!.validate()) return;

    final allSoldiers = await context.read<ConductProvider>().getAllSoldierIds();
    for (var soldier in allSoldiers) {
      if (!_selectedParticipants.contains(soldier) && 
          !_soldierReason.containsKey(soldier)) {
        _soldierReason[soldier] = "Removed from conduct";
      }
    }

    final conduct = Conduct(
      id: widget.conduct?.id ?? '',
      conductName: _conductNameController.text,
      conductType: _selectedConductType!,
      startDate: _startDate,
      startTime: _startTime,
      endTime: _endTime,
      participants: _selectedParticipants,
      nonParticipants: allSoldiers
          .where((id) => !_selectedParticipants.contains(id))
          .toList(),
      soldierReason: _soldierReason,
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
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? const Color.fromARGB(255, 35, 40, 55) : theme.colorScheme.surface,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              isDarkMode ? const Color.fromARGB(255, 35, 40, 55) : Colors.white,
              isDarkMode ? const Color.fromARGB(255, 25, 30, 45) : Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      theme.colorScheme.secondary,
                      theme.colorScheme.secondary.withOpacity(0.9),
                    ],
                  ),
                ),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: EdgeInsets.all(8.w),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Icon(
                          Icons.arrow_back_rounded,
                          color: Colors.white,
                          size: 20.sp,
                        ),
                      ),
                    ),
                    SizedBox(width: 16.w),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.conduct != null ? 'Edit Conduct' : 'Add New Conduct',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 20.sp,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                        Text(
                          'Fill in the details for the conduct',
                          style: GoogleFonts.poppins(
                            color: Colors.white70,
                            fontSize: 12.sp,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: isDarkMode ? const Color.fromARGB(255, 45, 50, 65) : Colors.white,
                            borderRadius: BorderRadius.circular(12.r),
                            boxShadow: [
                              BoxShadow(
                                color: isDarkMode 
                                  ? Colors.black.withOpacity(0.3) 
                                  : Colors.black.withOpacity(0.1),
                                blurRadius: 8.r,
                                offset: Offset(0, 4.h),
                              ),
                            ],
                          ),
                          padding: EdgeInsets.all(16.w),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Conduct Type',
                                style: GoogleFonts.poppins(
                                  color: isDarkMode ? Colors.white70 : Colors.black54,
                                  fontSize: 12.sp,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              SizedBox(height: 8.h),
                              Container(
                                decoration: BoxDecoration(
                                  color: isDarkMode 
                                      ? Colors.black.withOpacity(0.2) 
                                      : Colors.grey[100],
                                  borderRadius: BorderRadius.circular(8.r),
                                ),
                                child: DropdownButtonFormField<String>(
                                  value: _selectedConductType,
                                  style: GoogleFonts.poppins(
                                    color: isDarkMode ? Colors.white : Colors.black87,
                                    fontSize: 14.sp,
                                  ),
                                  decoration: InputDecoration(
                                    contentPadding: EdgeInsets.symmetric(horizontal: 12.w),
                                    border: InputBorder.none,
                                    hintText: 'Select conduct type...',
                                    hintStyle: GoogleFonts.poppins(
                                      color: isDarkMode ? Colors.white38 : Colors.black38,
                                      fontSize: 14.sp,
                                    ),
                                  ),
                                  items: _conductTypes.map((type) {
                                    return DropdownMenuItem(
                                      value: type,
                                      child: Text(type),
                                    );
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
                              ),
                              SizedBox(height: 16.h),
                              Text(
                                'Conduct Name',
                                style: GoogleFonts.poppins(
                                  color: isDarkMode ? Colors.white70 : Colors.black54,
                                  fontSize: 12.sp,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              SizedBox(height: 8.h),
                              Container(
                                decoration: BoxDecoration(
                                  color: isDarkMode 
                                      ? Colors.black.withOpacity(0.2) 
                                      : Colors.grey[100],
                                  borderRadius: BorderRadius.circular(8.r),
                                ),
                                child: TextFormField(
                                  controller: _conductNameController,
                                  style: GoogleFonts.poppins(
                                    color: isDarkMode ? Colors.white : Colors.black87,
                                    fontSize: 14.sp,
                                  ),
                                  decoration: InputDecoration(
                                    contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
                                    border: InputBorder.none,
                                    hintText: 'Enter conduct name...',
                                    hintStyle: GoogleFonts.poppins(
                                      color: isDarkMode ? Colors.white38 : Colors.black38,
                                      fontSize: 14.sp,
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter a conduct name';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 16.h),
                        Container(
                          decoration: BoxDecoration(
                            color: isDarkMode ? const Color.fromARGB(255, 45, 50, 65) : Colors.white,
                            borderRadius: BorderRadius.circular(12.r),
                            boxShadow: [
                              BoxShadow(
                                color: isDarkMode 
                                  ? Colors.black.withOpacity(0.3) 
                                  : Colors.black.withOpacity(0.1),
                                blurRadius: 8.r,
                                offset: Offset(0, 4.h),
                              ),
                            ],
                          ),
                          padding: EdgeInsets.all(16.w),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Date and Time',
                                style: GoogleFonts.poppins(
                                  color: isDarkMode ? Colors.white70 : Colors.black54,
                                  fontSize: 12.sp,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              SizedBox(height: 12.h),
                              GestureDetector(
                                onTap: () => _selectDate(context),
                                child: Container(
                                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
                                  decoration: BoxDecoration(
                                    color: isDarkMode 
                                        ? Colors.black.withOpacity(0.2) 
                                        : Colors.grey[100],
                                    borderRadius: BorderRadius.circular(8.r),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        _startDate,
                                        style: GoogleFonts.poppins(
                                          color: isDarkMode ? Colors.white : Colors.black87,
                                          fontSize: 14.sp,
                                        ),
                                      ),
                                      Icon(
                                        Icons.calendar_today_rounded,
                                        color: isDarkMode 
                                            ? Colors.white.withOpacity(0.9)
                                            : theme.colorScheme.tertiary,
                                        size: 20.sp,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(height: 12.h),
                              Row(
                                children: [
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () => _selectTime(context, true),
                                      child: Container(
                                        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
                                        decoration: BoxDecoration(
                                          color: isDarkMode 
                                              ? Colors.black.withOpacity(0.2) 
                                              : Colors.grey[100],
                                          borderRadius: BorderRadius.circular(8.r),
                                        ),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              _startTime,
                                              style: GoogleFonts.poppins(
                                                color: isDarkMode ? Colors.white : Colors.black87,
                                                fontSize: 14.sp,
                                              ),
                                            ),
                                            Icon(
                                              Icons.access_time_rounded,
                                              color: isDarkMode 
                                                  ? Colors.white.withOpacity(0.9)
                                                  : theme.colorScheme.tertiary,
                                              size: 20.sp,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 12.w),
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () => _selectTime(context, false),
                                      child: Container(
                                        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
                                        decoration: BoxDecoration(
                                          color: isDarkMode 
                                              ? Colors.black.withOpacity(0.2) 
                                              : Colors.grey[100],
                                          borderRadius: BorderRadius.circular(8.r),
                                        ),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              _endTime,
                                              style: GoogleFonts.poppins(
                                                color: isDarkMode ? Colors.white : Colors.black87,
                                                fontSize: 14.sp,
                                              ),
                                            ),
                                            Icon(
                                              Icons.access_time_rounded,
                                              color: isDarkMode 
                                                  ? Colors.white.withOpacity(0.9)
                                                  : theme.colorScheme.tertiary,
                                              size: 20.sp,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 16.h),
                        Container(
                          decoration: BoxDecoration(
                            color: isDarkMode ? const Color.fromARGB(255, 45, 50, 65) : Colors.white,
                            borderRadius: BorderRadius.circular(12.r),
                            boxShadow: [
                              BoxShadow(
                                color: isDarkMode 
                                  ? Colors.black.withOpacity(0.3) 
                                  : Colors.black.withOpacity(0.1),
                                blurRadius: 8.r,
                                offset: Offset(0, 4.h),
                              ),
                            ],
                          ),
                          padding: EdgeInsets.all(16.w),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Participants',
                                style: GoogleFonts.poppins(
                                  color: isDarkMode ? Colors.white70 : Colors.black54,
                                  fontSize: 12.sp,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              SizedBox(height: 12.h),
                              ParticipantSelector(
                                selectedParticipants: _selectedParticipants,
                                soldierReason: _soldierReason,
                                conductType: _selectedConductType,
                                onParticipantsChanged: (participants, reasons, nonParticipants) {
                                  setState(() {
                                    _selectedParticipants = participants;
                                    _soldierReason = reasons;
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 24.h),
                        Container(
                          width: double.infinity,
                          height: 48.h,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                theme.colorScheme.secondary,
                                theme.colorScheme.secondary.withOpacity(0.9),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(12.r),
                            boxShadow: [
                              BoxShadow(
                                color: theme.colorScheme.secondary.withOpacity(0.3),
                                blurRadius: 12.r,
                                offset: Offset(0, 6.h),
                              ),
                            ],
                          ),
                          child: ElevatedButton.icon(
                            onPressed: _saveConduct,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                            ),
                            icon: Icon(
                              widget.conduct != null ? Icons.save_rounded : Icons.add_rounded,
                              size: 20.sp,
                              color: Colors.white,
                            ),
                            label: Text(
                              widget.conduct != null ? 'UPDATE CONDUCT' : 'ADD CONDUCT',
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 1,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 