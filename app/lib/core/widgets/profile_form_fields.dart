import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../features/soldiers/domain/validators/profile_date_limits.dart';
import '../../features/soldiers/domain/validators/soldier_validators.dart';
import '../constants/blood_types.dart';
import '../constants/ration_types.dart';
import '../theme/app_spacing.dart';
import 'app_dropdown_field.dart';
import 'app_text_field.dart';
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

/// The labelled fields of the soldier profile, one per row. Validation comes
/// from [SoldierValidators]; only the name rule varies by screen.
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
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: AppSpacing.md.h,
        children: [
          AppTextField(
            key: const Key('profile-name'),
            controller: controller.name,
            label: nameLabel,
            icon: Icons.person_rounded,
            validator: nameValidator,
          ),
          AppTextField(
            key: const Key('profile-appointment'),
            controller: controller.appointment,
            label: 'Appointment (in unit):',
            icon: Icons.work_outline_rounded,
            validator: SoldierValidators.appointment,
          ),
          AppDropdownField<String>(
            key: const Key('profile-ration'),
            label: 'Ration type:',
            items: RationTypes.all,
            value: controller.rationType,
            hintText: 'Select your ration type...',
            prefixIcon: Icons.restaurant_rounded,
            validator: SoldierValidators.rationType,
            onChanged: (v) =>
                controller.update(() => controller.rationType = v),
          ),
          AppDropdownField<String>(
            key: const Key('profile-rank'),
            label: 'Rank:',
            items: ranks,
            value: controller.rank,
            hintText: 'Select your rank...',
            prefixIcon: Icons.military_tech_rounded,
            validator: SoldierValidators.rank,
            onChanged: (v) => controller.update(() => controller.rank = v),
          ),
          AppDropdownField<String>(
            key: const Key('profile-blood'),
            label: 'Blood type:',
            items: BloodTypes.all,
            value: controller.bloodGroup,
            hintText: 'Select your blood type...',
            prefixIcon: Icons.bloodtype_rounded,
            validator: SoldierValidators.bloodGroup,
            onChanged: (v) =>
                controller.update(() => controller.bloodGroup = v),
          ),
          _date(
            key: 'profile-dob',
            label: 'Date of Birth:',
            icon: Icons.cake_rounded,
            value: controller.dob,
            lastDate: ProfileDateLimits.latestBirth(today),
            validator: SoldierValidators.dateOfBirth,
            set: (d) => controller.dob = d,
          ),
          AppTextField(
            key: const Key('profile-company'),
            controller: controller.company,
            label: 'Company:',
            icon: Icons.groups_rounded,
            validator: SoldierValidators.company,
          ),
          AppTextField(
            key: const Key('profile-platoon'),
            controller: controller.platoon,
            label: 'Platoon:',
            icon: Icons.group_rounded,
            validator: SoldierValidators.platoon,
          ),
          AppTextField(
            key: const Key('profile-section'),
            controller: controller.section,
            label: 'Section/Detail:',
            icon: Icons.person_pin_rounded,
            validator: SoldierValidators.section,
          ),
          _date(
            key: 'profile-enlistment',
            label: 'Enlistment Date:',
            icon: Icons.login_rounded,
            value: controller.enlistment,
            lastDate: ProfileDateLimits.latest,
            validator: SoldierValidators.enlistmentDate,
            set: (d) => controller.enlistment = d,
          ),
          _date(
            key: 'profile-ord',
            label: 'ORD:',
            icon: Icons.logout_rounded,
            value: controller.ord,
            lastDate: ProfileDateLimits.latest,
            validator: SoldierValidators.ordDate,
            set: (d) => controller.ord = d,
          ),
        ],
      ),
    );
  }

  Widget _date({
    required String key,
    required String label,
    required IconData icon,
    required DateTime? value,
    required DateTime lastDate,
    required FormFieldValidator<DateTime> validator,
    required ValueSetter<DateTime> set,
  }) =>
      DatePickerField(
        key: Key(key),
        label: label,
        hintText: 'Pick a date',
        value: value,
        initialDate: today,
        icon: icon,
        firstDate: ProfileDateLimits.earliest,
        lastDate: lastDate,
        validator: validator,
        onChanged: (d) => controller.update(() => set(d)),
      );
}
