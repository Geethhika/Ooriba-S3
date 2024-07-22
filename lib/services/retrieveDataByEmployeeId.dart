import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<Map<String, dynamic>?> getEmployeeById(String employeeId) async {
    try {
      QuerySnapshot snapshot = await _db
          .collection('Regemp')
          .where('employeeId', isEqualTo: employeeId)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        return snapshot.docs.first.data() as Map<String, dynamic>;
      } else {
        return null;
      }
    } catch (e) {
      print(e);
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> getAllEmployees() async {
    try {
      QuerySnapshot snapshot = await _db.collection('Regemp').get();
      return snapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
    } catch (e) {
      print(e);
      return [];
    }
  }

  Future<Map<String, dynamic>> getCheckInOutDataByEmployeeId(String employeeId, DateTime timestamp) async {
    String date = DateFormat('yyyy-MM-dd').format(timestamp);
    DocumentSnapshot doc = await _db.collection('Dates').doc(date).get();

    if (doc.exists) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      if (data.containsKey(employeeId)) {
        Map<String, dynamic> employeeData = data[employeeId];
        return {
          'checkIn': (employeeData['checkIn'] as Timestamp?)?.toDate(),
          'checkOut': (employeeData['checkOut'] as Timestamp?)?.toDate(),
        };
      }
    }
    return {};
  }

  Future<void> toggleCheckInCheckOut(String employeeId, DateTime timestamp) async {
    String date = DateFormat('yyyy-MM-dd').format(timestamp);
    DocumentReference docRef = _db.collection('Dates').doc(date);
    DocumentSnapshot doc = await docRef.get();

    if (doc.exists) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      if (data.containsKey(employeeId)) {
        Map<String, dynamic> employeeData = data[employeeId];
        if (employeeData['checkIn'] != null && employeeData['checkOut'] == null) {
          // Perform check-out
          employeeData['checkOut'] = timestamp;
        } else {
          // Perform check-in
          employeeData['checkIn'] = timestamp;
          employeeData['checkOut'] = null;
        }
        data[employeeId] = employeeData;
        await docRef.set(data, SetOptions(merge: true));
      } else {
        // Perform check-in
        data[employeeId] = {
          'checkIn': timestamp,
          'checkOut': null,
        };
        await docRef.set(data, SetOptions(merge: true));
      }
    } else {
      // Create new document and perform check-in
      await docRef.set({
        employeeId: {
          'checkIn': timestamp,
          'checkOut': null,
        },
      }, SetOptions(merge: true));
    }
  }
}
