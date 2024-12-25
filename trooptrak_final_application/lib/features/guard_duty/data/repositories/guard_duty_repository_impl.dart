import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/guard_duty.dart';
import '../../domain/repositories/guard_duty_repository.dart';
import '../models/guard_duty_model.dart';

class GuardDutyRepositoryImpl implements GuardDutyRepository {
  final FirebaseFirestore _firestore;

  GuardDutyRepositoryImpl(this._firestore);

  @override
  Future<List<GuardDuty>> getGuardDuties() async {
    final snapshot = await _firestore.collection('Duties').get();
    return snapshot.docs
        .map((doc) => GuardDutyModel.fromJson(doc.data(), doc.id))
        .toList();
  }

  @override
  Future<void> addGuardDuty(GuardDuty duty) async {
    final dutyModel = GuardDutyModel(
      id: duty.id,
      dutyDate: duty.dutyDate,
      startTime: duty.startTime,
      endTime: duty.endTime,
      dutyType: duty.dutyType,
      points: duty.points,
      participants: duty.participants,
    );
    await _firestore.collection('Duties').add(dutyModel.toJson());
  }

  @override
  Future<void> updateGuardDuty(GuardDuty duty) async {
    final dutyModel = GuardDutyModel(
      id: duty.id,
      dutyDate: duty.dutyDate,
      startTime: duty.startTime,
      endTime: duty.endTime,
      dutyType: duty.dutyType,
      points: duty.points,
      participants: duty.participants,
    );
    await _firestore
        .collection('Duties')
        .doc(duty.id)
        .update(dutyModel.toJson());
  }

  @override
  Future<void> deleteGuardDuty(String dutyId) async {
    await _firestore.collection('Duties').doc(dutyId).delete();
  }

  @override
  Future<void> updateUserPoints(String userId, int points) async {
    final userDoc = await _firestore.collection('Users').doc(userId).get();
    final currentPoints = userDoc.data()?['points'] ?? 0;
    
    await _firestore.collection('Users').doc(userId).update({
      'points': currentPoints + points,
    });
  }
} 