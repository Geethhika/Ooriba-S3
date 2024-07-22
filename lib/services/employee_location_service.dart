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
