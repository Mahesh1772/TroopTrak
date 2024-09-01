import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:intl/intl.dart';
import 'package:trooptrak_final_application/features/nominal_roll/domain/entities/attendance_record.dart';
import 'package:trooptrak_final_application/features/nominal_roll/domain/entities/scanned_soldier.dart';
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
          ord: userModel.ord,
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

  @override
  Stream<User> getUserById(String id) {
    return _firestore.collection('Users').doc(id).snapshots().map((doc) {
      if (!doc.exists) {
        throw Exception('User not found');
      }
      final data = doc.data() as Map<String, dynamic>;
      return User(
        id: doc.id,
        name: data['name'],
        rank: data['rank'],
        company: data['company'],
        apppointment: data['appointment'],
        bloodgroup: data['bloodgroup'],
        currentAttendance: data['currentAttendance'],
        dob: data['dob'],
        ord: data['ord'],
        enlistment: data['enlistment'],
        platoon: data['platoon'],
        points: data['points'],
        rationType: data['rationType'],
        section: data['section'],
      );
    });
  }

  @override
  Stream<List<AttendanceRecord>> getUserAttendance(String id) {
    return _firestore
        .collection('Users')
        .doc(id)
        .collection('Attendance')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => AttendanceRecord(
                  dateTime: doc['date&time'],
                  isInsideCamp: doc['isInsideCamp'],
                ))
            .toList());
  }

  @override
  Future<Either<String, void>> updateUser(User user) async {
    try {
      await _firestore.collection('Users').doc(user.id).update({
        'name': user.name,
        'rank': user.rank,
        'company': user.company,
        'appointment': user.apppointment,
        'bloodgroup': user.bloodgroup,
        'currentAttendance': user.currentAttendance,
        'dob': user.dob,
        'ord': user.ord,
        'enlistment': user.enlistment,
        'platoon': user.platoon,
        'section': user.section,
        'rationType': user.rationType,
        'points': user.points,
      });
      return const Right(null);
    } catch (e) {
      return Left('Error updating user: $e');
    }
  }

  @override
  Future<Either<String, void>> deleteUser(String userId) async {
    try {
      // Delete the user document
      await _firestore.collection('Users').doc(userId).delete();
      
      // Delete the user's attendance subcollection
      final attendanceSnapshot = await _firestore
          .collection('Users')
          .doc(userId)
          .collection('Attendance')
          .get();
      
      for (var doc in attendanceSnapshot.docs) {
        await doc.reference.delete();
      }

      // Delete the user's Statuses subcollection
      final statusSnapshot = await _firestore
          .collection('Users')
          .doc(userId)
          .collection('Statuses')
          .get();
      
      for (var doc in statusSnapshot.docs) {
        await doc.reference.delete();
      }

      return const Right(null);
    } catch (e) {
      return Left('Error deleting user: $e');
    }
  }
}
