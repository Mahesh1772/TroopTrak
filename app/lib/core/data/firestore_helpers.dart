import 'package:cloud_firestore/cloud_firestore.dart';

const firestoreBatchLimit = 450;

Future<void> deleteInChunks(
  FirebaseFirestore db,
  List<DocumentReference<Object?>> refs,
) async {
  for (var start = 0; start < refs.length; start += firestoreBatchLimit) {
    final batch = db.batch();
    for (final ref in refs.skip(start).take(firestoreBatchLimit)) {
      batch.delete(ref);
    }
    await batch.commit();
  }
}

String readString(Object? value) => value?.toString() ?? '';

double readDouble(Object? value) => switch (value) {
      final num n => n.toDouble(),
      final String s => double.tryParse(s) ?? 0,
      _ => 0,
    };
