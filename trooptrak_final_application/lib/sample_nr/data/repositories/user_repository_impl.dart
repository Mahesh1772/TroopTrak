import 'package:cloud_firestore/cloud_firestore.dart';
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
}
