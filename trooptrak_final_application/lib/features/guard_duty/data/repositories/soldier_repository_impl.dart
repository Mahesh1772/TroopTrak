import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/soldier.dart';
import '../../domain/repositories/soldier_repository.dart';

class SoldierRepositoryImpl implements SoldierRepository {
  final FirebaseFirestore _firestore;

  SoldierRepositoryImpl(this._firestore);

  @override
  Future<List<Soldier>> getSoldiers() async {
    try {
      final snapshot = await _firestore.collection('Users').get();
      
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return Soldier(
          id: doc.id,
          name: data['name'] ?? '',
          rank: data['rank'] ?? '',
          appointment: data['appointment'] ?? '',
        );
      }).toList();
    } catch (e) {
      throw Exception('Failed to fetch soldiers: $e');
    }
  }
} 