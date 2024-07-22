import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<List<Map<String, dynamic>>> getEmployees() {
    return _db.collection('Employee').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => doc.data()).toList();
    });
  }
}
