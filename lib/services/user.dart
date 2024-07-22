import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class UserFirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> saveLastLoginTime(String phoneNo, DateTime lastLoginTime) async {
    await _db.collection('Users').doc(phoneNo).update({
      'lastLoginTime': lastLoginTime,
    });
  }

  Future<DocumentSnapshot> getLastLoginTime(String phoneNo) async {
    return await _db.collection('Users').doc(phoneNo).get();
  }

  Future<void> createLastLoginTime(String phoneNo, DateTime lastLoginTime) async {
    await _db.collection('Users').doc(phoneNo).set({
      'lastLoginTime': lastLoginTime,
    });
  }

  Future<DocumentSnapshot> getCheckInOutData(String phoneNo, String date) async {
    return await _db.collection('Dates').doc(date).get();
  }

  Future<void> addCheckInOutData(String phoneNo, DateTime checkInTime, DateTime? checkOutTime, DateTime timestamp) async {
    String date = DateFormat('yyyy-MM-dd').format(timestamp);
    DocumentReference docRef = _db.collection('Dates').doc(date);
    Map<String, dynamic> data = {
      'checkIn': checkInTime,
      'checkOut': checkOutTime,
    };
    await docRef.set({
      phoneNo: data,
    }, SetOptions(merge: true));
  }

  // New Methods
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
