class UserModel {
  final String name;
  final String rank;
  final String company;
  final String apppointment;
  final String bloodgroup;
  final String currentAttendance;
  final String dob;
  final String enlistment;
  final String ord;
  final String platoon;
  final String points;
  final String rationType;
  final String section;

  UserModel({
    required this.name,
    required this.rank,
    required this.company,
    required this.apppointment,
    required this.bloodgroup,
    required this.currentAttendance,
    required this.dob,
    required this.enlistment,
    required this.ord,
    required this.platoon,
    required this.points,
    required this.rationType,
    required this.section,
    });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      name: map['name'] ?? '',
      rank: map['rank'] ?? '',
      company: map['company'] ?? '',
      apppointment: map['apppointment'] ?? '',
      bloodgroup: map['bloodgroup'] ?? '',
      currentAttendance: map['currentAttendance'] ?? '',
      dob: map['dob'] ?? '',
      enlistment: map['enlistment'] ?? '',
      ord: map['ord'] ?? '',
      platoon: map['platoon'] ?? '',
      points: map['points'] ?? '',
      rationType: map['rationType'] ?? '',
      section: map['section'] ?? '',
    );
  }
}
