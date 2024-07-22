import 'package:cloud_firestore/cloud_firestore.dart';

class LeaveService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Apply for leave
  Future<void> applyLeave({
    required String employeeId,
    required String leaveType,
    required DateTime? fromDate,
    required DateTime? toDate,
    required double numberOfDays,
    required String? leaveReason,
  }) async {
    try {
      String fromDateStr =
          fromDate != null ? fromDate.toIso8601String().split('T').first : '';

      await _firestore
          .collection('leave')
          .doc('request')
          .collection(employeeId)
          .doc(fromDateStr)
          .set({
        'employeeId': employeeId,
        'leaveType': leaveType,
        'fromDate': fromDate,
        'toDate': toDate,
        'numberOfDays': numberOfDays,
        'leaveReason': leaveReason,
        'isApproved': null, // Initialize isApproved as null
        'appliedAt': FieldValue.serverTimestamp(), // Add appliedAt field
      });
    } catch (e) {
      print('Error applying leave: $e');
      throw e;
    }
  }

  // Update leave status (approve or reject)
  Future<void> updateLeaveStatus({
    required String employeeId,
    required String fromDateStr,
    required bool isApproved,
  }) async {
    try {
      // Update the leave status in the request collection
      await _firestore
          .collection('leave')
          .doc('request')
          .collection(employeeId)
          .doc(fromDateStr)
          .update({
        'isApproved': isApproved,
        'approvedAt': FieldValue.serverTimestamp(), // Add approvedAt field
      });

      // Fetch the leave details
      DocumentSnapshot<Map<String, dynamic>> leaveDoc = await _firestore
          .collection('leave')
          .doc('request')
          .collection(employeeId)
          .doc(fromDateStr)
          .get();

      if (leaveDoc.exists) {
        Map<String, dynamic> leaveData = leaveDoc.data()!;

        // If the leave is approved, copy the leave details to the "accept" collection
        if (isApproved) {
          await _firestore
              .collection('leave')
              .doc('accept')
              .collection(employeeId)
              .doc(fromDateStr)
              .set({
            'employeeId': leaveData['employeeId'],
            'leaveType': leaveData['leaveType'],
            'fromDate': leaveData['fromDate'],
            'toDate': leaveData['toDate'],
            'numberOfDays': leaveData['numberOfDays'],
            'leaveReason': leaveData['leaveReason'],
            'isApproved': true,
            'approvedAt': FieldValue.serverTimestamp(), // Add approvedAt field
          });

          // Update the LeaveTypes collection for the specific leave type
          await _firestore
              .collection('LeaveTypes')
              .doc(leaveData['leaveType'])
              .set({
            employeeId: FieldValue.increment(1),
            'numberOfDays': FieldValue.increment(leaveData['numberOfDays']),
          }, SetOptions(merge: true));

          await _firestore.collection('LeaveCount').doc(employeeId).set({
            'fromDate': leaveData['fromDate'],
            'count': FieldValue.increment(
                1), // Increment count in "accept" collection
          }, SetOptions(merge: true));
        } else {
          // If the leave is denied, copy the leave details to the "reject" collection
          await _firestore
              .collection('leave')
              .doc('reject')
              .collection(employeeId)
              .doc(fromDateStr)
              .set({
            'employeeId': leaveData['employeeId'],
            'leaveType': leaveData['leaveType'],
            'fromDate': leaveData['fromDate'],
            'toDate': leaveData['toDate'],
            'numberOfDays': leaveData['numberOfDays'],
            'leaveReason': leaveData['leaveReason'],
            'isApproved': false,
            'approvedAt': FieldValue.serverTimestamp(), // Add approvedAt field
          });

          await _firestore.collection('LeaveCount').doc(employeeId).set({
            'fromDate': leaveData['fromDate'],
            'count': FieldValue.increment(
                1), // Increment count in "reject" collection
          }, SetOptions(merge: true));
        }

        // Remove the leave request from the "request" collection
        await _firestore
            .collection('leave')
            .doc('request')
            .collection(employeeId)
            .doc(fromDateStr)
            .delete();
      }
    } catch (e) {
      print('Error updating leave status: $e');
      throw e;
    }
  }

  // Fetch leave details for a specific leave request
  Future<Map<String, dynamic>?> fetchLeaveDetails(
      String employeeId, String fromDateStr) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection('leave')
          .doc('request')
          .collection(employeeId)
          .doc(fromDateStr)
          .get();
      return doc.exists ? doc.data() as Map<String, dynamic>? : null;
    } catch (e) {
      print('Error fetching leave details: $e');
      throw e;
    }
  }

  // Fetch all leave requests across all employees
  Future<List<Map<String, dynamic>>> fetchAllLeaveRequests() async {
    try {
      // Step 1: Fetch all employeeIds from Regemp collection
      QuerySnapshot querySnapshot = await _firestore.collection('Regemp').get();
      List<String> employeeIds = [];
      querySnapshot.docs.forEach((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        if (data.containsKey('employeeId')) {
          String employeeId = data['employeeId'];
          if (employeeId.isNotEmpty) {
            employeeIds.add(employeeId);
          }
        }
      });

      // Step 2: Fetch leave requests for each employeeId using collectionGroup
      List<Map<String, dynamic>> allLeaveRequests = [];
      for (String employeeId in employeeIds) {
        QuerySnapshot querySnapshot = await _firestore
            .collection('leave')
            .doc('request')
            .collection(employeeId)
            .get();

        // Step 3: Map and collect leave request data
        List<Map<String, dynamic>> leaveRequests =
            querySnapshot.docs.map((doc) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          // Optionally add employeeId to each leave request
          // data['employeeId'] = employeeId;
          return data;
        }).toList();

        allLeaveRequests.addAll(leaveRequests);
      }

      return allLeaveRequests;
    } catch (e) {
      print('Error fetching all leave requests: $e');
      throw e;
    }
  }

  // Fetch leave requests for a specific employee
  Future<List<Map<String, dynamic>>> fetchLeaveRequestsByEmployeeId(
      String employeeId) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('leave')
          .doc('request')
          .collection(employeeId)
          .get();

      return querySnapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['employeeId'] = employeeId;
        return data;
      }).toList();
    } catch (e) {
      print('Error fetching leave requests by employee ID: $e');
      throw e;
    }
  }

  // Fetch leave count for a specific employee
  Future<Map<String, dynamic>?> fetchLeaveCount(String employeeId) async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection('LeaveCount').doc(employeeId).get();
      return doc.exists ? doc.data() as Map<String, dynamic>? : null;
    } catch (e) {
      print('Error fetching leave count: $e');
      throw e;
    }
  }

  // Fetch leave requests (accepted) within a specific date range for a specific employee
  Future<List<Map<String, dynamic>>> fetchLeaveRequests({
    required String employeeId,
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    List<Map<String, dynamic>> leaveRequests = [];

    QuerySnapshot snapshot = await _firestore
        .collection('leave')
        .doc('accept')
        .collection(employeeId)
        .get();

    for (var doc in snapshot.docs) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      DateTime docFromDate = (data['fromDate'] as Timestamp).toDate();

      if (fromDate != null && toDate != null) {
        if (docFromDate.isAfter(fromDate.subtract(Duration(days: 1))) &&
            docFromDate.isBefore(toDate.add(Duration(days: 1)))) {
          leaveRequests.add(data);
        }
      } else {
        leaveRequests.add(data);
      }
    }

    return leaveRequests;
  }

  // Fetch all leave dates for a specific employee
  Future<Map<String, dynamic>?> fetchLeaveDetailsByDate(
      String employeeId, DateTime date) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('leave')
          .doc('accept')
          .collection(employeeId)
          .get();

      for (var doc in querySnapshot.docs) {
        DateTime fromDate = (doc['fromDate'] as Timestamp).toDate();
        DateTime toDate = (doc['toDate'] as Timestamp).toDate();

        if (date.isAfter(fromDate.subtract(Duration(days: 1))) &&
            date.isBefore(toDate.add(Duration(days: 1)))) {
          // Return the leave details if the date falls within the range
          return doc.data() as Map<String, dynamic>;
        }
      }

      // Return null if no leave details found for the given date
      return null;
    } catch (e) {
      print('Error fetching leave details: $e');
      throw e;
    }
  }

  // Fetch details of rejected leave request
  Future<Map<String, dynamic>?> fetchRejectedLeaveDetails(
      String employeeId, String fromDateStr) async {
    try {
      DocumentSnapshot<Map<String, dynamic>> docSnapshot = await _firestore
          .collection('leave')
          .doc('reject')
          .collection(employeeId)
          .doc(fromDateStr)
          .get();

      if (docSnapshot.exists) {
        return docSnapshot.data();
      } else {
        return null;
      }
    } catch (e) {
      print('Error fetching rejected leave details: $e');
      throw e;
    }
  }

  // Fetch leave requests for a specific date across all employees
  Future<List<Map<String, dynamic>>> fetchLeaveRequestsByDate(
      DateTime selectedDate) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collectionGroup('request')
          .where('fromDate', isEqualTo: selectedDate)
          .get();

      List<Map<String, dynamic>> leaveRequests = querySnapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();

      return leaveRequests;
    } catch (e) {
      print('Error fetching leave requests by date: $e');
      throw e;
    }
  }
}
