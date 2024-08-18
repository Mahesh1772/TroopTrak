import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:intl/intl.dart';
import 'package:trooptrak_final_application/sample_nr/domain/entities/scanned_soldier.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/user_repository.dart';
import '../models/user_model.dart';

class UserRepositoryImpl implements UserRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  UserRepositoryImpl(FirebaseFirestore read);

  @override
  Stream<List<User>> getUsers() {
    return _firestore.collection('Users').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final userModel = UserModel.fromMap(doc.data());
        return User(
          id: doc.id,
          name: userModel.name,
          rank: userModel.rank,
          company: userModel.company,
          apppointment: userModel.apppointment,
          bloodgroup: userModel.bloodgroup,
          currentAttendance: userModel.currentAttendance,
          dob: userModel.dob,
          enlistment: userModel.enlistment,
          platoon: userModel.platoon,
          points: userModel.points,
          rationType: userModel.rationType,
          section: userModel.section,
        );
      }).toList();
    });
  }

  @override
  Future<void> updateUserAttendance(String id, bool isInsideCamp) async {
    await _firestore.collection('Users').doc(id).update({
      'currentAttendance': isInsideCamp ? 'Inside Camp' : 'Outside',
    });

    // Add the attendance record
    await _firestore
        .collection('Users')
        .doc(id)
        .collection('Attendance')
        .doc(DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now()))
        .set({
      'date&time': DateFormat('E d MMM yyyy HH:mm:ss').format(DateTime.now()),
      'isInsideCamp': isInsideCamp,
    });
  }

  @override
  Future<Either<String, void>> addUser(ScannedSoldier soldier) async {
    try {
      await _firestore.collection('Users').doc(soldier.name).set({
        'name': soldier.name,
        'rank': soldier.rank,
        'company': soldier.company,
        'appointment': soldier.appointment,
        'bloodgroup': soldier.bloodgroup,
        'currentAttendance': soldier.currentAttendance,
        'dob': soldier.dob,
        'ord' : soldier.ord,
        'enlistment': soldier.enlistment,
        'platoon': soldier.platoon,
        'section': soldier.section,
        'rationType': soldier.rationType,
        'points': soldier.points,
      });

      await _firestore
        .collection('Users')
        .doc(soldier.name)
        .collection('Attendance')
        .doc(DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now()))
        .set({
      'date&time': DateFormat('E d MMM yyyy HH:mm:ss').format(DateTime.now()),
      'isInsideCamp': soldier.currentAttendance == 'Inside Camp',
    });
      return const Right(null);
    } catch (e) {
      return Left('Error adding user: $e');
    }
  }
}
