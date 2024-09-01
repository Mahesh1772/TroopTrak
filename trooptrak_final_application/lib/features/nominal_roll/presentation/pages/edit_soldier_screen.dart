import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
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
  late TextEditingController _rankController;
  late TextEditingController _companyController;
  late TextEditingController _appointmentController;
  late TextEditingController _bloodGroupController;
  late TextEditingController _dobController;
  late TextEditingController _enlistmentController;
  late TextEditingController _ordController;
  late TextEditingController _platoonController;
  late TextEditingController _sectionController;
  late TextEditingController _rationTypeController;
  late TextEditingController _pointsController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _rankController = TextEditingController();
    _companyController = TextEditingController();
    _appointmentController = TextEditingController();
    _bloodGroupController = TextEditingController();
    _dobController = TextEditingController();
    _enlistmentController = TextEditingController();
    _ordController = TextEditingController();
    _platoonController = TextEditingController();
    _sectionController = TextEditingController();
    _rationTypeController = TextEditingController();
    _pointsController = TextEditingController();

    // Load user data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userProvider = Provider.of<UserDetailProvider>(context, listen: false);
      final user = userProvider.user;
      if (user != null) {
        _nameController.text = user.name;
        _rankController.text = user.rank;
        _companyController.text = user.company;
        _appointmentController.text = user.apppointment;
        _bloodGroupController.text = user.bloodgroup;
        _dobController.text = user.dob;
        _enlistmentController.text = user.enlistment;
        _ordController.text = user.ord;
        _platoonController.text = user.platoon;
        _sectionController.text = user.section;
        _rationTypeController.text = user.rationType;
        _pointsController.text = user.points.toString();
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _rankController.dispose();
    _companyController.dispose();
    _appointmentController.dispose();
    _bloodGroupController.dispose();
    _dobController.dispose();
    _enlistmentController.dispose();
    _ordController.dispose();
    _platoonController.dispose();
    _sectionController.dispose();
    _rationTypeController.dispose();
    _pointsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Soldier Details'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0.w),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                _buildTextField(_nameController, 'Name'),
                _buildTextField(_rankController, 'Rank'),
                _buildTextField(_companyController, 'Company'),
                _buildTextField(_appointmentController, 'Appointment'),
                _buildTextField(_bloodGroupController, 'Blood Group'),
                _buildTextField(_dobController, 'Date of Birth'),
                _buildTextField(_enlistmentController, 'Enlistment Date'),
                _buildTextField(_ordController, 'ORD Date'),
                _buildTextField(_platoonController, 'Platoon'),
                _buildTextField(_sectionController, 'Section'),
                _buildTextField(_rationTypeController, 'Ration Type'),
                _buildTextField(_pointsController, 'Points', isNumeric: true),
                SizedBox(height: 20.h),
                ElevatedButton(
                  onPressed: _submitForm,
                  child: const Text('Save Changes'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, {bool isNumeric = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0.h),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter $label';
          }
          return null;
        },
      ),
    );
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final updatedUser = User(
        id: widget.userId,
        name: _nameController.text,
        rank: _rankController.text,
        company: _companyController.text,
        apppointment: _appointmentController.text,
        bloodgroup: _bloodGroupController.text,
        currentAttendance: Provider.of<UserDetailProvider>(context, listen: false).user!.currentAttendance,
        dob: _dobController.text,
        enlistment: _enlistmentController.text,
        ord: _ordController.text,
        platoon: _platoonController.text,
        points: _pointsController.text,
        rationType: _rationTypeController.text,
        section: _sectionController.text,
      );

      Provider.of<UserDetailProvider>(context, listen: false).updateUser(updatedUser);
      Navigator.pop(context);
    }
  }
}