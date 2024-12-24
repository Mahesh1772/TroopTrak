import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/conduct.dart';
import '../../domain/repositories/conduct_repository.dart';
import '../models/conduct_model.dart';

class ConductRepositoryImpl implements ConductRepository {
  final FirebaseFirestore _firestore;

  ConductRepositoryImpl({FirebaseFirestore? firestore}) 
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Stream<List<Conduct>> getConducts() {
    return _firestore.collection('Conducts').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return ConductModel.fromJson(doc.data(), doc.id);
      }).toList();
    });
  }

  @override
  Future<void> addConduct(Conduct conduct) async {
    final conductModel = ConductModel(
      id: conduct.id,
      conductName: conduct.conductName,
      conductType: conduct.conductType,
      startDate: conduct.startDate,
      startTime: conduct.startTime,
      endTime: conduct.endTime,
      participants: conduct.participants,
      nonParticipants: conduct.nonParticipants,
      soldierReason: conduct.soldierReason,
    );

    await _firestore.collection('Conducts').add(conductModel.toJson());
  }

  @override
  Future<void> updateConduct(Conduct conduct) async {
    final conductModel = ConductModel(
      id: conduct.id,
      conductName: conduct.conductName,
      conductType: conduct.conductType,
      startDate: conduct.startDate,
      startTime: conduct.startTime,
      endTime: conduct.endTime,
      participants: conduct.participants,
      nonParticipants: conduct.nonParticipants,
      soldierReason: conduct.soldierReason,
    );

    await _firestore
        .collection('Conducts')
        .doc(conduct.id)
        .update(conductModel.toJson());
  }

  @override
  Future<void> deleteConduct(String id) async {
    await _firestore.collection('Conducts').doc(id).delete();
  }

  @override
  Stream<Conduct> getConductById(String id) {
    return _firestore.collection('Conducts').doc(id).snapshots().map((doc) {
      if (!doc.exists) throw Exception('Conduct not found');
      return ConductModel.fromJson(doc.data()!, doc.id);
    });
  }
} 