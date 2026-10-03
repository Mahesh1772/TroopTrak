import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../constants/blood_types.dart';
import '../constants/ration_types.dart';
import '../theme/app_spacing.dart';
import 'app_dropdown_field.dart';
import 'picker_fields.dart';

/// Holds the soldier profile fields shared by register, profile capture and
/// add/edit soldier. Dates default to [today], as every source form did.
class ProfileFormController extends ChangeNotifier {
  ProfileFormController({required DateTime today})
      : dob = today,
        enlistment = today,
        ord = today;

  final name = TextEditingController();
  final company = TextEditingController();
  final platoon = TextEditingController();
  final section = TextEditingController();
  final appointment = TextEditingController();
  String? rank;
  String? rationType;
  String? bloodGroup;
  DateTime dob;
  DateTime enlistment;
  DateTime ord;

  void prefill({
    required String name,
    required String rank,
    required String company,
    required String platoon,
    required String section,
    required String appointment,
    required String rationType,
    required String bloodGroup,
    DateTime? dob,
    DateTime? enlistment,
    DateTime? ord,
  }) {
    this.name.text = name;
    this.company.text = company;
    this.platoon.text = platoon;
    this.section.text = section;
    this.appointment.text = appointment;
    this.rank = rank.isEmpty ? null : rank;
    this.rationType = rationType.isEmpty ? null : rationType;
    this.bloodGroup = bloodGroup.isEmpty ? null : bloodGroup;
    if (dob != null) this.dob = dob;
    if (enlistment != null) this.enlistment = enlistment;
    if (ord != null) this.ord = ord;
    notifyListeners();
  }

  void update(VoidCallback change) {
    change();
    notifyListeners();
  }

  @override
  void dispose() {
    for (final c in [name, company, platoon, section, appointment]) {
      c.dispose();
    }
    super.dispose();
  }
}

String? _required(String? value, String message) =>
    (value == null || value.trim().isEmpty) ? message : null;

class ProfileFormFields extends StatelessWidget {
  const ProfileFormFields({
    super.key,
    required this.controller,
    required this.ranks,
    required this.nameValidator,
    required this.today,
    this.nameLabel = 'Enter Name (as in NRIC):',
  });

  final ProfileFormController controller;
  final List<String> ranks;
  final FormFieldValidator<String> nameValidator;
  final DateTime today;
  final String nameLabel;

  @override
  Widget build(BuildContext context) {
    final gap = SizedBox(height: AppSpacing.lg.h);
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _text('profile-name', controller.name, nameLabel, Icons.person,
              nameValidator),
          gap,
          _text(
              'profile-appointment',
              controller.appointment,
              'Appointment (in unit):',
              Icons.work_outline,
              (v) => _required(v, 'Appointment Missing')),
          gap,
          AppDropdownField<String>(
            key: const Key('profile-ration'),
            items: RationTypes.all,
            value: controller.rationType,
            hintText: 'Select your ration type...',
            prefixIcon: Icons.restaurant,
            validator: (v) => v == null ? 'Walao what food you eat?' : null,
            onChanged: (v) =>
                controller.update(() => controller.rationType = v),
          ),
          gap,
          AppDropdownField<String>(
            key: const Key('profile-rank'),
            items: ranks,
            value: controller.rank,
            hintText: 'Select your rank...',
            prefixIcon: Icons.military_tech,
            validator: (v) => v == null ? 'Walao provide rank liao' : null,
            onChanged: (v) => controller.update(() => controller.rank = v),
          ),
          gap,
          AppDropdownField<String>(
            key: const Key('profile-blood'),
            items: BloodTypes.all,
            value: controller.bloodGroup,
            hintText: 'Select your blood type...',
            prefixIcon: Icons.bloodtype,
            validator: (v) =>
                v == null ? 'Why your blood field empty ah?' : null,
            onChanged: (v) =>
                controller.update(() => controller.bloodGroup = v),
          ),
          gap,
          DatePickerField(
            key: const Key('profile-dob'),
            hintText: 'Date of Birth',
            value: controller.dob,
            icon: Icons.cake,
            firstDate: DateTime(1960),
            lastDate: today,
            onChanged: (d) => controller.update(() => controller.dob = d),
          ),
          gap,
          _text('profile-company', controller.company, 'Company:', Icons.groups,
              (v) => _required(v, 'Company Name Missing')),
          gap,
          _text('profile-platoon', controller.platoon, 'Platoon:', Icons.group,
              (v) => _required(v, 'Platoon Information Missing')),
          gap,
          _text(
              'profile-section',
              controller.section,
              'Section/Detail:',
              Icons.person_pin,
              (v) => _required(v, 'Section Information Missing')),
          gap,
          DatePickerField(
            key: const Key('profile-enlistment'),
            hintText: 'Enlistment Date',
            value: controller.enlistment,
            icon: Icons.login,
            firstDate: DateTime(1960),
            lastDate: DateTime(2100),
            onChanged: (d) =>
                controller.update(() => controller.enlistment = d),
          ),
          gap,
          DatePickerField(
            key: const Key('profile-ord'),
            hintText: 'ORD',
            value: controller.ord,
            icon: Icons.logout,
            firstDate: DateTime(1960),
            lastDate: DateTime(2100),
            onChanged: (d) => controller.update(() => controller.ord = d),
          ),
        ],
      ),
    );
  }

  Widget _text(
    String key,
    TextEditingController c,
    String label,
    IconData icon,
    FormFieldValidator<String> validator,
  ) =>
      TextFormField(
        key: Key(key),
        controller: c,
        validator: validator,
        decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon)),
      );
}
