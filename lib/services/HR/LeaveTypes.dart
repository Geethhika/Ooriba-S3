import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class LeaveTypesService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final CollectionReference _leaveTypesCollection =
      FirebaseFirestore.instance.collection('LeaveTypes');
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Fetch leave types from the database
  Future<List<String>> fetchLeaveTypes() async {
    try {
      QuerySnapshot snapshot = await _leaveTypesCollection.get();
      List<String> leaveTypes = snapshot.docs.map((doc) => doc.id).toList();
      return leaveTypes;
    } catch (e) {
      print('Error fetching leave types: $e');
      return [];
    }
  }

  // Fetch employee data by ID
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

  Future<List<Map<String, dynamic>>?> fetchLeaveByDate(
      String employeeId, String fromDateStr, String toDateStr) async {
  try {
    QuerySnapshot querySnapshot = await _firestore
        .collection('leave')
        .doc('accept')
        .collection(employeeId)
        .where(FieldPath.documentId,
            isGreaterThanOrEqualTo: fromDateStr)
        .where(FieldPath.documentId,
            isLessThanOrEqualTo: toDateStr)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      return querySnapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
    } else {
      return null;
    }
  } catch (e) {
    print(e);
    return null;
  }
}


  // Fetch leave data for a specific year and employee
  Future<Map<String, dynamic>> getLeaveData(
      String employeeId, String leaveType) async {
    try {
      String currentYear = DateFormat('yyyy').format(DateTime.now());
      DocumentReference leaveDoc = _leaveTypesCollection
          .doc(leaveType)
          .collection(currentYear)
          .doc(employeeId);

      DocumentSnapshot snapshot = await leaveDoc.get();

      int leavesTaken = 0;
      if (snapshot.exists && snapshot.data() != null) {
        leavesTaken =
            (snapshot.data() as Map<String, dynamic>)['leavesTaken'] ?? 0;
      }

      int balance = 4 - leavesTaken;

      return {
        'leavesTaken': leavesTaken,
        'balance': balance,
      };
    } catch (e) {
      print('Error fetching leave data: $e');
      return {
        'leavesTaken': 0,
        'balance': 4,
      };
    }
  }
}