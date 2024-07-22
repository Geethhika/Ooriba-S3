import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<List<Map<String, dynamic>>> getEmployees() {
    return _db.collection('Employee').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        var data = doc.data();
        data['id'] = doc.id; // Add document ID to the data
        return data;
      }).toList();
    });
  }

  Future<void> saveEmployeeData(String docId, Map<String, dynamic> data) async {
    try {
      await _db
          .collection('Employee')
          .doc(docId)
          .set(data, SetOptions(merge: true));
    } catch (e) {
      print('Error saving employee data: $e');
      rethrow; // Re-throw the error to handle it in the UI
    }
  }
}
