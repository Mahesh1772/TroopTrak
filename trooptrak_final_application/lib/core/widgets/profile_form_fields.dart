import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../constants/blood_types.dart';
import '../constants/ration_types.dart';
import '../theme/app_spacing.dart';
import 'app_dropdown_field.dart';
import 'picker_fields.dart';

/// Holds the soldier profile fields shared by register, profile capture and
/// add/edit soldier. Commander forms default the dates to [today]; profile
/// capture leaves them empty so each must be picked (K17).
class ProfileFormController extends ChangeNotifier {
  ProfileFormController({DateTime? today})
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
  DateTime? dob;
  DateTime? enlistment;
  DateTime? ord;

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
          _date(
            key: 'profile-dob',
            hint: 'Date of Birth',
            missing: 'Select your date of birth',
            icon: Icons.cake,
            value: controller.dob,
            lastDate: today,
            set: (d) => controller.dob = d,
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
          _date(
            key: 'profile-enlistment',
            hint: 'Enlistment Date',
            missing: 'Select your enlistment date',
            icon: Icons.login,
            value: controller.enlistment,
            lastDate: DateTime(2100),
            set: (d) => controller.enlistment = d,
          ),
          gap,
          _date(
            key: 'profile-ord',
            hint: 'ORD',
            missing: 'Select your ORD date',
            icon: Icons.logout,
            value: controller.ord,
            lastDate: DateTime(2100),
            set: (d) => controller.ord = d,
          ),
        ],
      ),
    );
  }

  Widget _date({
    required String key,
    required String hint,
    required String missing,
    required IconData icon,
    required DateTime? value,
    required DateTime lastDate,
    required ValueSetter<DateTime> set,
  }) =>
      DatePickerField(
        key: Key(key),
        hintText: hint,
        value: value,
        initialDate: today,
        icon: icon,
        firstDate: DateTime(1960),
        lastDate: lastDate,
        validator: (d) => d == null ? missing : null,
        onChanged: (d) => controller.update(() => set(d)),
      );

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
