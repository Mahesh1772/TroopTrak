import 'package:json_annotation/json_annotation.dart';
import 'package:cloud_firestore_odm/cloud_firestore_odm.dart';

@JsonSerializable(explicitToJson: true)
class User {
  User({
    required this.rank,
    required this.appointment,
    required this.rationType,
    required this.status,
    required this.mobileNumber,
    required this.bloodgroup,
    required this.dob,
    required this.ord,
    required this.attendence,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      rank: json['rank'],
      appointment: json['appointment'],
      rationType: json['rationType'],
      status: json['status'],
      mobileNumber: json['mobileNumber'],
      bloodgroup: json['bloodgroup'],
      dob: json['dob'],
      ord: json['ord'],
      attendence: json['attendence'],
    );
  }

  final String rank;
  final String appointment;
  final String rationType;
  final String status;
  final String mobileNumber;
  final String bloodgroup;
  final String dob;
  final String ord;
  final String attendence;

  Map<String, Object?> toJson() {
    return {
      'rank'        :  rank,
      'appointment' :  appointment,
      'rationType'  :  rationType,  
      'status'      :  status,  
      'mobileNumber':  mobileNumber,          
      'bloodgroup'  :  bloodgroup,        
      'dob'         :  dob,      
      'ord'         :  ord,  
      'attendence'  :  attendence,
    };
  }
}
