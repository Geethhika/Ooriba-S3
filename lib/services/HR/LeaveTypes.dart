import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class LeaveTypesService {
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

  // Fetch detailed leave types with employee IDs and numbers
  Future<Map<String, Map<String, int>>> fetchDetailedLeaveTypes() async {
    try {
      QuerySnapshot snapshot = await _leaveTypesCollection.get();
      Map<String, Map<String, int>> leaveTypesDetails = {};

      for (var doc in snapshot.docs) {
        String leaveType = doc.id;
        Map<String, int> employeeLeaveData = {};

        // Check if the document data is not null
        Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;
        if (data != null) {
          data.forEach((key, value) {
            // Assuming value is an integer representing the number of leave days
            if (value is int) {
              employeeLeaveData[key] = value;
            }
          });
        }

        leaveTypesDetails[leaveType] = employeeLeaveData;
      }

      return leaveTypesDetails;
    } catch (e) {
      print('Error fetching detailed leave types: $e');
      return {};
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

  Future<DocumentSnapshot> fetchSickLeaveData() async {
    return await _db.collection('LeaveTypes').doc('Sick Leave').get();
  }

  Future<bool> canRequestSickLeave(String employeeId) async {
    try {
      DocumentSnapshot doc = await fetchSickLeaveData();

      if (doc.exists) {
        Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;
        if (data != null && data.containsKey(employeeId)) {
          int numberOfDays = data[employeeId];
          return numberOfDays <
              4; // Assuming 4 is the maximum allowed sick leave days
        } else {
          // If no data is found for the employee, treat numberOfDays as 0
          return true;
        }
      } else {
        // If the 'Sick Leave' document does not exist, allow the request
        return true;
      }
    } catch (e) {
      print('Error checking sick leave request: $e');
      return false;
    }
  }

  // Calculate eligible earned leave days
  Future<int> calculateEligibleEarnedLeave(String employeeId) async {
    try {
      // Fetch employee data
      Map<String, dynamic>? employeeData = await getEmployeeById(employeeId);
      if (employeeData == null) {
        throw 'Employee data not found';
      }

      // Get joining date
      String joiningDateString = employeeData['joiningDate'];
      DateTime joiningDate = DateFormat('dd/MM/yyyy').parse(joiningDateString);

      // Calculate the number of eligible leave days based on joining date
      DateTime currentDate = DateTime.now();
      int monthsDifference = ((currentDate.year - joiningDate.year) * 12) +
          currentDate.month -
          joiningDate.month;
      int totalEligibleLeaveDays = monthsDifference;

      // Fetch the number of leaves already taken
      DocumentSnapshot doc =
          await _db.collection('LeaveTypes').doc('Earned Leave').get();
      int takenLeaveDays = 0;
      if (doc.exists) {
        Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;
        if (data != null && data.containsKey(employeeId)) {
          // Retrieve the number of days taken from the document
          takenLeaveDays = data[employeeId]['numberOfDays'] ?? 0;
        }
      }

      // Calculate the remaining eligible leave days
      int remainingLeaveDays = totalEligibleLeaveDays - takenLeaveDays;

      return remainingLeaveDays;
    } catch (e) {
      print('Error calculating eligible earned leave: $e');
      return 0;
    }
  }
}
