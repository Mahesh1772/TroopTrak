import 'package:equatable/equatable.dart';

import '../../../../core/constants/ranks.dart';

class Soldier extends Equatable {
  const Soldier({
    required this.id,
    required this.name,
    required this.rank,
    this.company = '',
    this.platoon = '',
    this.section = '',
    this.appointment = '',
    this.rationType = '',
    this.bloodGroup = '',
    this.dob,
    this.enlistment,
    this.ord,
    this.isInCamp = true,
    this.points = 0,
  });

  /// `Users` document id; the soldier's name at creation time (K8, K14).
  final String id;
  final String name;
  final String rank;
  final String company;
  final String platoon;
  final String section;
  final String appointment;
  final String rationType;
  final String bloodGroup;
  final DateTime? dob;
  final DateTime? enlistment;
  final DateTime? ord;
  final bool isInCamp;
  final double points;

  bool get isOfficer => Ranks.isOfficer(rank);

  bool get isWose => Ranks.isWose(rank);

  /// R9: points never drop below zero.
  static double pointsAfter(double current, double delta) {
    final result = current + delta;
    return result < 0 ? 0 : result;
  }

  Soldier copyWith({
    String? id,
    String? name,
    String? rank,
    String? company,
    String? platoon,
    String? section,
    String? appointment,
    String? rationType,
    String? bloodGroup,
    DateTime? dob,
    DateTime? enlistment,
    DateTime? ord,
    bool? isInCamp,
    double? points,
  }) =>
      Soldier(
        id: id ?? this.id,
        name: name ?? this.name,
        rank: rank ?? this.rank,
        company: company ?? this.company,
        platoon: platoon ?? this.platoon,
        section: section ?? this.section,
        appointment: appointment ?? this.appointment,
        rationType: rationType ?? this.rationType,
        bloodGroup: bloodGroup ?? this.bloodGroup,
        dob: dob ?? this.dob,
        enlistment: enlistment ?? this.enlistment,
        ord: ord ?? this.ord,
        isInCamp: isInCamp ?? this.isInCamp,
        points: points ?? this.points,
      );

  @override
  List<Object?> get props => [
        id,
        name,
        rank,
        company,
        platoon,
        section,
        appointment,
        rationType,
        bloodGroup,
        dob,
        enlistment,
        ord,
        isInCamp,
        points,
      ];
}
