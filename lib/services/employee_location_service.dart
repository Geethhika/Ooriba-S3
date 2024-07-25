import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';

class EmployeeLocationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> saveEmployeeLocation(String employeeId, Position position, DateTime timestamp, String type) async {
    String todayDate = DateFormat('yyyy-MM-dd').format(timestamp);
    DocumentReference locationRef = _firestore.collection('employee_locations').doc(todayDate);

    return locationRef.set({
      employeeId: FieldValue.arrayUnion([{
        'timestamp': timestamp,
        'location': GeoPoint(position.latitude, position.longitude),
        'type': type,
      }])
    }, SetOptions(merge: true));
  }

  Future<Map<String, int>> getWorkingDays(String month) async {
    int monthIndex = DateFormat.MMMM().parse(month).month;
    int year = DateTime.now().year;

    DateTime startDate = DateTime(year, monthIndex, 1);
    DateTime endDate = DateTime(year, monthIndex + 1, 1).subtract(Duration(days: 1));

    QuerySnapshot querySnapshot = await _firestore
        .collection('employee_locations')
        .where('timestamp', isGreaterThanOrEqualTo: startDate)
        .where('timestamp', isLessThanOrEqualTo: endDate)
        .get();

    Map<String, int> workingDays = {};

    for (var doc in querySnapshot.docs) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      data.forEach((employeeId, locations) {
        if (locations is List) {
          for (var location in locations) {
            if (location['type'] == 'check-in') {
              if (!workingDays.containsKey(employeeId)) {
                workingDays[employeeId] = 0;
              }
              workingDays[employeeId] = workingDays[employeeId]! + 1;
              break;
            }
          }
        }
      });
    }

    return workingDays;
  }

  Future<Map<String, dynamic>> fetchEmployeeCoordinates(String employeeId) async {
    String todayDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
    DocumentSnapshot snapshot = await _firestore.collection('employee_locations').doc(todayDate).get();

    if (snapshot.exists) {
      Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
      if (data.containsKey(employeeId)) {
        List<dynamic> locations = data[employeeId];
        return locations.last; // Get the latest location
      }
    }

    throw 'No location data found for the employee';
  }
}



