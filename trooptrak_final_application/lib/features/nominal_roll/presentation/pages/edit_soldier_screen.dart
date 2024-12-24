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
        // Enlistment can't be after today and not before 1960
        firstDate = DateTime(1960);
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
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      resizeToAvoidBottomInset: false,
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
                      Icons.arrow_back_sharp,
                      color: theme.colorScheme.tertiary,
                      size: 25.sp,
                    ),
                  ),
                  SizedBox(height: 20.h),
                  Text(
                    "Change details  ✍️",
                    style: theme.textTheme.displayMedium,
                  ),
                  Text(
                    "Update the details of an existing soldier.",
                    style: theme.textTheme.bodyMedium,
                  ),
                  SizedBox(height: 20.h),
                  _buildTextField(context, _nameController, 'Enter Name (as in NRIC):'),
                  SizedBox(height: 16.h),
                  Row(
                    children: [
                      Expanded(
                        child: _buildDatePicker(context, 'Date of Birth', _dob, () => _showDatePicker('dob')),
                      ),
                      SizedBox(width: 16.w),
                      Expanded(
                        child: _buildDropdown(
                          context,
                          value: _selectedRationType,
                          items: _rationTypes,
                          onChanged: (value) => setState(() => _selectedRationType = value),
                          hint: 'Ration Type',
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),
                  Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: _buildDropdown(
                          context,
                          value: _selectedRank,
                          items: _ranks,
                          onChanged: (value) => setState(() => _selectedRank = value),
                          hint: 'Select Rank',
                        ),
                      ),
                      SizedBox(width: 16.w),
                      Expanded(
                        flex: 4,
                        child: _buildDropdown(
                          context,
                          value: _selectedBloodType,
                          items: _bloodTypes,
                          onChanged: (value) => setState(() => _selectedBloodType = value),
                          hint: 'Blood Type',
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),
                  _buildTextField(context, _companyController, 'Company:'),
                  SizedBox(height: 16.h),
                  _buildTextField(context, _platoonController, 'Platoon:'),
                  SizedBox(height: 16.h),
                  _buildTextField(context, _sectionController, 'Section:'),
                  SizedBox(height: 16.h),
                  _buildTextField(context, _appointmentController, 'Appointment (in unit):'),
                  SizedBox(height: 16.h),
                  Row(
                    children: [
                      Expanded(
                        child: _buildDatePicker(context, 'Enlistment', _enlistment, () => _showDatePicker('enlistment')),
                      ),
                      SizedBox(width: 16.w),
                      Expanded(
                        child: _buildDatePicker(context, 'ORD', _ord, () => _showDatePicker('ord')),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),
                  _buildTextField(context, _pointsController, 'Points', isNumeric: true),
                  SizedBox(height: 24.h),
                  SizedBox(
                    width: double.infinity,
                    height: 56.h,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.secondary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      onPressed: _submitForm,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.edit_note_rounded,
                            color: Colors.white,
                            size: 24.sp,
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            'UPDATE DETAILS',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
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

  Widget _buildTextField(BuildContext context, TextEditingController controller, String label, {bool isNumeric = false}) {
    final theme = Theme.of(context);
    String hintText = '';
    
    // Set appropriate hint text based on label
    switch (label.toLowerCase()) {
      case 'enter name (as in nric):':
        hintText = 'e.g., TAN XIAO MING';
        break;
      case 'company:':
        hintText = 'e.g., ALPHA';
        break;
      case 'platoon:':
        hintText = 'e.g., 1';
        break;
      case 'section:':
        hintText = 'e.g., 1';
        break;
      case 'appointment (in unit):':
        hintText = 'e.g., PC';
        break;
      case 'points':
        hintText = 'e.g., 4';
        break;
      default:
        hintText = 'Enter ${label.toLowerCase()}';
    }

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: theme.colorScheme.secondary.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
      child: TextFormField(
        controller: controller,
        style: theme.textTheme.bodyMedium?.copyWith(
          fontSize: 16.sp,
          color: theme.colorScheme.tertiary,
        ),
        decoration: InputDecoration(
          isDense: true,
          contentPadding: EdgeInsets.symmetric(vertical: 8.h),
          border: InputBorder.none,
          labelText: label,
          hintText: hintText,
          floatingLabelBehavior: FloatingLabelBehavior.auto,
          labelStyle: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.secondary,
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
          ),
          hintStyle: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.tertiary.withOpacity(0.5),
            fontSize: 16.sp,
          ),
        ),
        keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter ${label.toLowerCase()}';
          }
          
          // Additional field-specific validations
          switch (label.toLowerCase()) {
            case 'enter name (as in nric):':
              if (value.length < 3) {
                return 'Name must be at least 3 characters long';
              }
              break;
            case 'company:':
              if (value.length < 2) {
                return 'Please enter a valid company';
              }
              break;
            case 'platoon:':
              if (int.tryParse(value) == null || int.parse(value) < 1) {
                return 'Please enter a valid platoon number';
              }
              break;
            case 'section:':
              if (int.tryParse(value) == null || int.parse(value) < 1) {
                return 'Please enter a valid section number';
              }
              break;
            case 'points':
              if (int.tryParse(value) == null || int.parse(value) < 0) {
                return 'Please enter a valid points value';
              }
              break;
          }
          return null;
        },
      ),
    );
  }

  Widget _buildDropdown(
    BuildContext context, {
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
    required String hint,
  }) {
    final theme = Theme.of(context);
    String hintText = '';
    
    // Set appropriate hint text based on hint
    switch (hint.toLowerCase()) {
      case 'ration type':
        hintText = 'e.g., NM';
        break;
      case 'select rank':
        hintText = 'e.g., CPL';
        break;
      case 'blood type':
        hintText = 'e.g., O+';
        break;
      default:
        hintText = 'Select ${hint.toLowerCase()}';
    }

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: theme.colorScheme.secondary.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            hint,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.secondary,
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 4.h),
          SizedBox(
            height: 24.h,
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: value,
                isExpanded: true,
                icon: Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: theme.colorScheme.secondary,
                  size: 24.sp,
                ),
                dropdownColor: theme.colorScheme.surface,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontSize: 16.sp,
                  color: theme.colorScheme.tertiary,
                ),
                items: items.map((String item) {
                  return DropdownMenuItem(
                    value: item,
                    child: Text(
                      item,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontSize: 16.sp,
                        color: item.startsWith('Select') 
                            ? theme.colorScheme.tertiary.withOpacity(0.5)
                            : theme.colorScheme.tertiary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                }).toList(),
                onChanged: onChanged,
                hint: Text(
                  hintText,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontSize: 16.sp,
                    color: theme.colorScheme.tertiary.withOpacity(0.5),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDatePicker(BuildContext context, String label, String value, VoidCallback onTap) {
    final theme = Theme.of(context);
    String hintText = 'e.g., 1 Jan 2024';
    
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: theme.colorScheme.secondary.withOpacity(0.3),
            width: 1.5,
          ),
        ),
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.secondary,
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 4.h),
            SizedBox(
              height: 24.h,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    value.isEmpty ? hintText : value,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontSize: 16.sp,
                      color: value.isEmpty 
                          ? theme.colorScheme.tertiary.withOpacity(0.5)
                          : theme.colorScheme.tertiary,
                    ),
                  ),
                  Icon(
                    Icons.calendar_today_outlined,
                    color: theme.colorScheme.secondary,
                    size: 20.sp,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitForm() async {
    bool isValid = _formKey.currentState!.validate();
    final theme = Theme.of(context);
    
    // Additional date validations
    if (_dob.isEmpty) {
      isValid = false;
      _showError('Please select a date of birth');
    }
    
    if (_enlistment.isEmpty) {
      isValid = false;
      _showError('Please select an enlistment date');
    }
    
    if (_ord.isEmpty) {
      isValid = false;
      _showError('Please select an ORD date');
    }

    // Validate dropdown selections
    if (_selectedRank == null || _selectedRank!.startsWith('Select')) {
      isValid = false;
      _showError('Please select a rank');
    }

    if (_selectedRationType == null || _selectedRationType!.startsWith('Select')) {
      isValid = false;
      _showError('Please select a ration type');
    }

    if (_selectedBloodType == null || _selectedBloodType!.startsWith('Select')) {
      isValid = false;
      _showError('Please select a blood type');
    }

    // Validate date relationships
    try {
      final dobDate = DateFormat("d MMM yyyy").parse(_dob);
      final enlistmentDate = DateFormat("d MMM yyyy").parse(_enlistment);
      final ordDate = DateFormat("d MMM yyyy").parse(_ord);
      final now = DateTime.now();

      if (dobDate.isAfter(now)) {
        isValid = false;
        _showError('Date of birth cannot be in the future');
      }

      if (enlistmentDate.isAfter(now)) {
        isValid = false;
        _showError('Enlistment date cannot be in the future');
      }

      if (enlistmentDate.isBefore(dobDate)) {
        isValid = false;
        _showError('Enlistment date cannot be before date of birth');
      }

      if (ordDate.isBefore(enlistmentDate)) {
        isValid = false;
        _showError('ORD date cannot be before enlistment date');
      }
    } catch (e) {
      isValid = false;
      _showError('Invalid date format');
    }

    if (isValid) {
      try {
        final provider = Provider.of<UserDetailProvider>(context, listen: false);
        
        final updatedUser = User(
          id: widget.userId,
          name: _nameController.text.trim(),
          rank: _selectedRank!,
          company: _companyController.text.trim(),
          apppointment: _appointmentController.text.trim(),
          bloodgroup: _selectedBloodType!,
          currentAttendance: provider.user!.currentAttendance,
          dob: _dob,
          enlistment: _enlistment,
          ord: _ord,
          platoon: _platoonController.text.trim(),
          points: _pointsController.text.trim(),
          rationType: _selectedRationType!,
          section: _sectionController.text.trim(),
        );

        await provider.updateUser(updatedUser);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'User details updated successfully',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.tertiary,
                ),
              ),
              backgroundColor: theme.colorScheme.secondary,
            ),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        _showError('Error updating user details: $e');
      }
    }
  }

  void _showError(String message) {
    final theme = Theme.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.tertiary,
          ),
        ),
        backgroundColor: theme.colorScheme.error,
      ),
    );
  }
}