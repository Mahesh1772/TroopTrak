import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/user_repository.dart';
import '../models/user_model.dart';

class UserRepositoryImpl implements UserRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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
    await _firestore.collection('Users').doc(id).collection('Attendance').doc(DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now())).set({
      'date&time': DateFormat('E d MMM yyyy HH:mm:ss').format(DateTime.now()),
      'isInsideCamp': isInsideCamp,
    });
  }
}
