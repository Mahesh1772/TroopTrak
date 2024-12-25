import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:trooptrak_final_application/features/nominal_roll/presentation/providers/user_detail_provider.dart';
import 'package:trooptrak_final_application/features/nominal_roll/domain/entities/user.dart';

class EditSoldierScreen extends StatefulWidget {
  final String userId;

  const EditSoldierScreen({super.key, required this.userId});

  @override
  _EditSoldierScreenState createState() => _EditSoldierScreenState();
}

class _EditSoldierScreenState extends State<EditSoldierScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _companyController;
  late TextEditingController _appointmentController;
  late TextEditingController _platoonController;
  late TextEditingController _sectionController;
  late TextEditingController _pointsController;
  
  String? _selectedRank;
  String? _selectedRationType;
  String? _selectedBloodType;
  String _dob = '';
  String _ord = '';
  String _enlistment = '';
  bool isFirstTime = true;

  final _rationTypes = [
    "Select your ration type...",
    "NM",
    "M",
    "VI",
    "VC",
    "SD NM",
    "SD M",
    "SD VI",
    "SD VC"
  ];

  final _ranks = [
    "Select your rank...",
    "REC",
    "PTE",
    "LCP",
    "CPL",
    "CFC",
    "SCT",
    "3SG",
    "2SG",
    "1SG",
    "SSG",
    "MSG",
    "3WO",
    "2WO",
    "1WO",
    "MWO",
    "SWO",
    "CWO",
    "OCT",
    "2LT",
    "LTA",
    "CPT",
    "MAJ",
    "LTC",
    "SLTC",
    "COL",
    "BG",
    "MG",
    "LG",
  ];

  final _bloodTypes = [
    "Select your blood type...",
    "O-",
    "O+",
    "B-",
    "B+",
    "A-",
    "A+",
    "AB-",
    "AB+",
    "Unknown"
  ];

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (isFirstTime) {
      final userProvider = Provider.of<UserDetailProvider>(context, listen: false);
      if (userProvider.user != null) {
        _loadUserData(userProvider.user!);
      }
    }
  }

  void _initializeControllers() {
    _nameController = TextEditingController();
    _companyController = TextEditingController();
    _appointmentController = TextEditingController();
    _platoonController = TextEditingController();
    _sectionController = TextEditingController();
    _pointsController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _companyController.dispose();
    _appointmentController.dispose();
    _platoonController.dispose();
    _sectionController.dispose();
    _pointsController.dispose();
    super.dispose();
  }

  void _loadUserData(User user) {
    _nameController.text = user.name;
    _selectedRank = user.rank;
    _companyController.text = user.company;
    _appointmentController.text = user.apppointment;
    _selectedBloodType = user.bloodgroup;
    _dob = user.dob;
    _enlistment = user.enlistment;
    _ord = user.ord;
    _platoonController.text = user.platoon;
    _sectionController.text = user.section;
    _selectedRationType = user.rationType;
    _pointsController.text = user.points.toString();
    isFirstTime = false;
  }

  void _showDatePicker(String type) {
    DateTime initialDate;
    DateTime firstDate;
    DateTime lastDate;
    String currentValue = '';
    final now = DateTime.now();
    
    switch (type) {
      case 'dob':
        currentValue = _dob;
        // DOB can't be after today and not before 1960
        firstDate = DateTime(1960);
        lastDate = now;
        initialDate = currentValue.isNotEmpty 
            ? DateFormat("d MMM yyyy").parse(currentValue)
            : DateTime(now.year - 18); // Default to 18 years ago
        break;
      case 'enlistment':
        currentValue = _enlistment;
        // Enlistment can't be before DOB and not after today
        try {
          firstDate = _dob.isNotEmpty 
              ? DateFormat("d MMM yyyy").parse(_dob)
              : DateTime(1960);
        } catch (e) {
          firstDate = DateTime(1960);
        }
        lastDate = now;
        initialDate = currentValue.isNotEmpty 
            ? DateFormat("d MMM yyyy").parse(currentValue)
            : now;
        break;
      case 'ord':
        currentValue = _ord;
        // ORD must be after enlistment date and can be up to 5 years from now
        try {
          firstDate = _enlistment.isNotEmpty 
              ? DateFormat("d MMM yyyy").parse(_enlistment)
              : now;
        } catch (e) {
          firstDate = now;
        }
        lastDate = DateTime(now.year + 5);
        initialDate = currentValue.isNotEmpty 
            ? DateFormat("d MMM yyyy").parse(currentValue)
            : firstDate.add(const Duration(days: 730)); // Default to 2 years from enlistment
        break;
      default:
        return;
    }

    try {
      // Ensure initialDate is within bounds
      if (initialDate.isAfter(lastDate)) {
        initialDate = lastDate;
      } else if (initialDate.isBefore(firstDate)) {
        initialDate = firstDate;
      }
    } catch (e) {
      initialDate = now;
    }

    showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
      builder: (context, child) {
        final theme = Theme.of(context);
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: theme.colorScheme.copyWith(
              primary: theme.colorScheme.secondary,
              onPrimary: theme.colorScheme.tertiary,
              onSurface: theme.colorScheme.tertiary,
            ),
          ),
          child: child!,
        );
      },
    ).then((value) {
      if (value != null) {
        setState(() {
          final formattedDate = DateFormat('d MMM yyyy').format(value);
          switch (type) {
            case 'dob':
              _dob = formattedDate;
              // Clear enlistment and ORD if DOB is after them
              if (_enlistment.isNotEmpty) {
                try {
                  final enlistmentDate = DateFormat("d MMM yyyy").parse(_enlistment);
                  if (value.isAfter(enlistmentDate)) {
                    _enlistment = '';
                    _ord = '';
                  }
                } catch (e) {
                  _enlistment = '';
                  _ord = '';
                }
              }
              break;
            case 'ord':
              _ord = formattedDate;
              break;
            case 'enlistment':
              _enlistment = formattedDate;
              // Clear ORD if enlistment date is after current ORD
              if (_ord.isNotEmpty) {
                try {
                  final ordDate = DateFormat("d MMM yyyy").parse(_ord);
                  if (value.isAfter(ordDate)) {
                    _ord = '';
                  }
                } catch (e) {
                  _ord = '';
                }
              }
              break;
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? Color.fromARGB(255, 35, 40, 55) : theme.colorScheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InkWell(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Icon(
                      Icons.arrow_back_rounded,
                      color: theme.colorScheme.tertiary,
                      size: 24.sp,
                    ),
                  ),
                  SizedBox(height: 20.h),
                  Text(
                    "Change details  ✍️",
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: theme.colorScheme.tertiary,
                      letterSpacing: 1.2,
                      fontSize: 24.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "Update the details of an existing soldier.",
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.tertiary.withOpacity(0.8),
                      letterSpacing: 0.5,
                      fontSize: 14.sp,
                    ),
                  ),
                  SizedBox(height: 20.h),
                  Container(
                    decoration: BoxDecoration(
                      color: isDarkMode ? Color.fromARGB(255, 45, 50, 65) : theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(12.r),
                      boxShadow: [
                        BoxShadow(
                          color: isDarkMode ? Colors.black.withOpacity(0.5) : Colors.black.withOpacity(0.1),
                          blurRadius: 8.r,
                          offset: Offset(0, 4.h),
                          spreadRadius: isDarkMode ? 1.r : 0.r,
                        ),
                      ],
                    ),
                    child: TextFormField(
                      controller: _nameController,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: isDarkMode ? Colors.white : theme.colorScheme.onSurface,
                        letterSpacing: 0.5,
                        fontSize: 14.sp,
                      ),
                      decoration: InputDecoration(
                        labelText: 'Name',
                        labelStyle: theme.textTheme.bodySmall?.copyWith(
                          color: isDarkMode ? Colors.grey[400] : theme.colorScheme.onSurface.withOpacity(0.7),
                          letterSpacing: 1.2,
                          fontSize: 12.sp,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.transparent,
                        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a name';
                        }
                        return null;
                      },
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Container(
                    decoration: BoxDecoration(
                      color: isDarkMode ? Color.fromARGB(255, 45, 50, 65) : theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(12.r),
                      boxShadow: [
                        BoxShadow(
                          color: isDarkMode ? Colors.black.withOpacity(0.5) : Colors.black.withOpacity(0.1),
                          blurRadius: 8.r,
                          offset: Offset(0, 4.h),
                          spreadRadius: isDarkMode ? 1.r : 0.r,
                        ),
                      ],
                    ),
                    child: DropdownButtonFormField<String>(
                      value: _selectedRank,
                      items: _ranks.map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(
                            value,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: isDarkMode ? Colors.white : theme.colorScheme.onSurface,
                              letterSpacing: 0.5,
                              fontSize: 14.sp,
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedRank = newValue;
                        });
                      },
                      decoration: InputDecoration(
                        labelText: 'Rank',
                        labelStyle: theme.textTheme.bodySmall?.copyWith(
                          color: isDarkMode ? Colors.grey[400] : theme.colorScheme.onSurface.withOpacity(0.7),
                          letterSpacing: 1.2,
                          fontSize: 12.sp,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.transparent,
                        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                      ),
                      validator: (value) {
                        if (value == _ranks[0]) {
                          return 'Please select a rank';
                        }
                        return null;
                      },
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Container(
                    decoration: BoxDecoration(
                      color: isDarkMode ? Color.fromARGB(255, 45, 50, 65) : theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(12.r),
                      boxShadow: [
                        BoxShadow(
                          color: isDarkMode ? Colors.black.withOpacity(0.5) : Colors.black.withOpacity(0.1),
                          blurRadius: 8.r,
                          offset: Offset(0, 4.h),
                          spreadRadius: isDarkMode ? 1.r : 0.r,
                        ),
                      ],
                    ),
                    child: TextFormField(
                      controller: _companyController,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: isDarkMode ? Colors.white : theme.colorScheme.onSurface,
                        letterSpacing: 0.5,
                        fontSize: 14.sp,
                      ),
                      decoration: InputDecoration(
                        labelText: 'Company',
                        labelStyle: theme.textTheme.bodySmall?.copyWith(
                          color: isDarkMode ? Colors.grey[400] : theme.colorScheme.onSurface.withOpacity(0.7),
                          letterSpacing: 1.2,
                          fontSize: 12.sp,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.transparent,
                        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a company';
                        }
                        return null;
                      },
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Container(
                    decoration: BoxDecoration(
                      color: isDarkMode ? Color.fromARGB(255, 45, 50, 65) : theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(12.r),
                      boxShadow: [
                        BoxShadow(
                          color: isDarkMode ? Colors.black.withOpacity(0.5) : Colors.black.withOpacity(0.1),
                          blurRadius: 8.r,
                          offset: Offset(0, 4.h),
                          spreadRadius: isDarkMode ? 1.r : 0.r,
                        ),
                      ],
                    ),
                    child: TextFormField(
                      controller: _appointmentController,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: isDarkMode ? Colors.white : theme.colorScheme.onSurface,
                        letterSpacing: 0.5,
                        fontSize: 14.sp,
                      ),
                      decoration: InputDecoration(
                        labelText: 'Appointment',
                        labelStyle: theme.textTheme.bodySmall?.copyWith(
                          color: isDarkMode ? Colors.grey[400] : theme.colorScheme.onSurface.withOpacity(0.7),
                          letterSpacing: 1.2,
                          fontSize: 12.sp,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.transparent,
                        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter an appointment';
                        }
                        return null;
                      },
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Container(
                    decoration: BoxDecoration(
                      color: isDarkMode ? Color.fromARGB(255, 45, 50, 65) : theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(12.r),
                      boxShadow: [
                        BoxShadow(
                          color: isDarkMode ? Colors.black.withOpacity(0.5) : Colors.black.withOpacity(0.1),
                          blurRadius: 8.r,
                          offset: Offset(0, 4.h),
                          spreadRadius: isDarkMode ? 1.r : 0.r,
                        ),
                      ],
                    ),
                    child: TextFormField(
                      controller: _platoonController,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: isDarkMode ? Colors.white : theme.colorScheme.onSurface,
                        letterSpacing: 0.5,
                        fontSize: 14.sp,
                      ),
                      decoration: InputDecoration(
                        labelText: 'Platoon',
                        labelStyle: theme.textTheme.bodySmall?.copyWith(
                          color: isDarkMode ? Colors.grey[400] : theme.colorScheme.onSurface.withOpacity(0.7),
                          letterSpacing: 1.2,
                          fontSize: 12.sp,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.transparent,
                        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a platoon';
                        }
                        return null;
                      },
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Container(
                    decoration: BoxDecoration(
                      color: isDarkMode ? Color.fromARGB(255, 45, 50, 65) : theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(12.r),
                      boxShadow: [
                        BoxShadow(
                          color: isDarkMode ? Colors.black.withOpacity(0.5) : Colors.black.withOpacity(0.1),
                          blurRadius: 8.r,
                          offset: Offset(0, 4.h),
                          spreadRadius: isDarkMode ? 1.r : 0.r,
                        ),
                      ],
                    ),
                    child: TextFormField(
                      controller: _sectionController,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: isDarkMode ? Colors.white : theme.colorScheme.onSurface,
                        letterSpacing: 0.5,
                        fontSize: 14.sp,
                      ),
                      decoration: InputDecoration(
                        labelText: 'Section',
                        labelStyle: theme.textTheme.bodySmall?.copyWith(
                          color: isDarkMode ? Colors.grey[400] : theme.colorScheme.onSurface.withOpacity(0.7),
                          letterSpacing: 1.2,
                          fontSize: 12.sp,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.transparent,
                        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a section';
                        }
                        return null;
                      },
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Container(
                    decoration: BoxDecoration(
                      color: isDarkMode ? Color.fromARGB(255, 45, 50, 65) : theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(12.r),
                      boxShadow: [
                        BoxShadow(
                          color: isDarkMode ? Colors.black.withOpacity(0.5) : Colors.black.withOpacity(0.1),
                          blurRadius: 8.r,
                          offset: Offset(0, 4.h),
                          spreadRadius: isDarkMode ? 1.r : 0.r,
                        ),
                      ],
                    ),
                    child: TextFormField(
                      controller: _pointsController,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: isDarkMode ? Colors.white : theme.colorScheme.onSurface,
                        letterSpacing: 0.5,
                        fontSize: 14.sp,
                      ),
                      decoration: InputDecoration(
                        labelText: 'Points',
                        labelStyle: theme.textTheme.bodySmall?.copyWith(
                          color: isDarkMode ? Colors.grey[400] : theme.colorScheme.onSurface.withOpacity(0.7),
                          letterSpacing: 1.2,
                          fontSize: 12.sp,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.transparent,
                        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter points';
                        }
                        if (int.tryParse(value) == null) {
                          return 'Please enter a valid number';
                        }
                        return null;
                      },
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Container(
                    decoration: BoxDecoration(
                      color: isDarkMode ? Color.fromARGB(255, 45, 50, 65) : theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(12.r),
                      boxShadow: [
                        BoxShadow(
                          color: isDarkMode ? Colors.black.withOpacity(0.5) : Colors.black.withOpacity(0.1),
                          blurRadius: 8.r,
                          offset: Offset(0, 4.h),
                          spreadRadius: isDarkMode ? 1.r : 0.r,
                        ),
                      ],
                    ),
                    child: DropdownButtonFormField<String>(
                      value: _selectedRationType,
                      items: _rationTypes.map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(
                            value,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: isDarkMode ? Colors.white : theme.colorScheme.onSurface,
                              letterSpacing: 0.5,
                              fontSize: 14.sp,
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedRationType = newValue;
                        });
                      },
                      decoration: InputDecoration(
                        labelText: 'Ration Type',
                        labelStyle: theme.textTheme.bodySmall?.copyWith(
                          color: isDarkMode ? Colors.grey[400] : theme.colorScheme.onSurface.withOpacity(0.7),
                          letterSpacing: 1.2,
                          fontSize: 12.sp,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.transparent,
                        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                      ),
                      validator: (value) {
                        if (value == _rationTypes[0]) {
                          return 'Please select a ration type';
                        }
                        return null;
                      },
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Container(
                    decoration: BoxDecoration(
                      color: isDarkMode ? Color.fromARGB(255, 45, 50, 65) : theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(12.r),
                      boxShadow: [
                        BoxShadow(
                          color: isDarkMode ? Colors.black.withOpacity(0.5) : Colors.black.withOpacity(0.1),
                          blurRadius: 8.r,
                          offset: Offset(0, 4.h),
                          spreadRadius: isDarkMode ? 1.r : 0.r,
                        ),
                      ],
                    ),
                    child: DropdownButtonFormField<String>(
                      value: _selectedBloodType,
                      items: _bloodTypes.map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(
                            value,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: isDarkMode ? Colors.white : theme.colorScheme.onSurface,
                              letterSpacing: 0.5,
                              fontSize: 14.sp,
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedBloodType = newValue;
                        });
                      },
                      decoration: InputDecoration(
                        labelText: 'Blood Type',
                        labelStyle: theme.textTheme.bodySmall?.copyWith(
                          color: isDarkMode ? Colors.grey[400] : theme.colorScheme.onSurface.withOpacity(0.7),
                          letterSpacing: 1.2,
                          fontSize: 12.sp,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.transparent,
                        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                      ),
                      validator: (value) {
                        if (value == _bloodTypes[0]) {
                          return 'Please select a blood type';
                        }
                        return null;
                      },
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () => _showDatePicker('dob'),
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                            decoration: BoxDecoration(
                              color: isDarkMode ? Color.fromARGB(255, 45, 50, 65) : theme.colorScheme.surface,
                              borderRadius: BorderRadius.circular(12.r),
                              boxShadow: [
                                BoxShadow(
                                  color: isDarkMode ? Colors.black.withOpacity(0.5) : Colors.black.withOpacity(0.1),
                                  blurRadius: 8.r,
                                  offset: Offset(0, 4.h),
                                  spreadRadius: isDarkMode ? 1.r : 0.r,
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Date of Birth',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: isDarkMode ? Colors.grey[400] : theme.colorScheme.onSurface.withOpacity(0.7),
                                    letterSpacing: 1.2,
                                    fontSize: 12.sp,
                                  ),
                                ),
                                SizedBox(height: 4.h),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        _dob.isEmpty ? 'Select date' : _dob,
                                        style: theme.textTheme.bodyMedium?.copyWith(
                                          color: isDarkMode ? Colors.white : theme.colorScheme.onSurface,
                                          letterSpacing: 0.5,
                                          fontSize: 14.sp,
                                        ),
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
                      SizedBox(width: 16.w),
                      Expanded(
                        child: InkWell(
                          onTap: () => _showDatePicker('enlistment'),
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                            decoration: BoxDecoration(
                              color: isDarkMode ? Color.fromARGB(255, 45, 50, 65) : theme.colorScheme.surface,
                              borderRadius: BorderRadius.circular(12.r),
                              boxShadow: [
                                BoxShadow(
                                  color: isDarkMode ? Colors.black.withOpacity(0.5) : Colors.black.withOpacity(0.1),
                                  blurRadius: 8.r,
                                  offset: Offset(0, 4.h),
                                  spreadRadius: isDarkMode ? 1.r : 0.r,
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Enlistment Date',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: isDarkMode ? Colors.grey[400] : theme.colorScheme.onSurface.withOpacity(0.7),
                                    letterSpacing: 1.2,
                                    fontSize: 12.sp,
                                  ),
                                ),
                                SizedBox(height: 4.h),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        _enlistment.isEmpty ? 'Select date' : _enlistment,
                                        style: theme.textTheme.bodyMedium?.copyWith(
                                          color: isDarkMode ? Colors.white : theme.colorScheme.onSurface,
                                          letterSpacing: 0.5,
                                          fontSize: 14.sp,
                                        ),
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
                    ],
                  ),
                  SizedBox(height: 16.h),
                  InkWell(
                    onTap: () => _showDatePicker('ord'),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                      decoration: BoxDecoration(
                        color: isDarkMode ? Color.fromARGB(255, 45, 50, 65) : theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(12.r),
                        boxShadow: [
                          BoxShadow(
                            color: isDarkMode ? Colors.black.withOpacity(0.5) : Colors.black.withOpacity(0.1),
                            blurRadius: 8.r,
                            offset: Offset(0, 4.h),
                            spreadRadius: isDarkMode ? 1.r : 0.r,
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'ORD Date',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: isDarkMode ? Colors.grey[400] : theme.colorScheme.onSurface.withOpacity(0.7),
                              letterSpacing: 1.2,
                              fontSize: 12.sp,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  _ord.isEmpty ? 'Select date' : _ord,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: isDarkMode ? Colors.white : theme.colorScheme.onSurface,
                                    letterSpacing: 0.5,
                                    fontSize: 14.sp,
                                  ),
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
                  SizedBox(height: 24.h),
                  SizedBox(
                    width: double.infinity,
                    height: 48.h,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          final user = User(
                            id: widget.userId,
                            name: _nameController.text,
                            rank: _selectedRank!,
                            company: _companyController.text,
                            apppointment: _appointmentController.text,
                            bloodgroup: _selectedBloodType!,
                            dob: _dob,
                            enlistment: _enlistment,
                            ord: _ord,
                            platoon: _platoonController.text,
                            section: _sectionController.text,
                            rationType: _selectedRationType!,
                            points: _pointsController.text,
                            currentAttendance: context.read<UserDetailProvider>().user?.currentAttendance ?? 'Outside Camp',
                          );

                          context.read<UserDetailProvider>().updateUser(user);
                          Navigator.pop(context);
                        }
                      },
                      icon: Icon(
                        Icons.save_rounded,
                        size: 20.sp,
                        color: Colors.white,
                      ),
                      label: Text(
                        'SAVE CHANGES',
                        style: theme.textTheme.titleMedium?.copyWith(
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