
import 'package:cloud_firestore/cloud_firestore.dart';

class DateService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<Map<String, Map<String, String>>> getDataByDate(String date) async {
    try {
      DocumentSnapshot snapshot = await _firestore.collection('Dates').doc(date).get();

      if (snapshot.exists) {
        Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
        return data.map((employeeId, value) {
          Map<String, dynamic> employeeData = value as Map<String, dynamic>;

          // Check if checkIn and checkOut fields exist and are not null
          DateTime? checkIn;
          DateTime? checkOut;

          if (employeeData.containsKey('checkIn') && employeeData['checkIn'] != null) {
            Timestamp checkInTimestamp = employeeData['checkIn'];
            checkIn = checkInTimestamp.toDate();
          }

          if (employeeData.containsKey('checkOut') && employeeData['checkOut'] != null) {
            Timestamp checkOutTimestamp = employeeData['checkOut'];
            checkOut = checkOutTimestamp.toDate();
          }

          return MapEntry(employeeId, {
            'checkIn': checkIn?.toString() ?? 'Not Provided', // Provide default or handle as needed
            'checkOut': checkOut?.toString() ?? 'Not Provided', // Provide default or handle as needed
          });
        });
      } else {
        print('Document does not exist for the given date: $date');
        return {};
      }
    } catch (e) {
      print('Error retrieving data: $e');
      return {};
    }
  }
}
