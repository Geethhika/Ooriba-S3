// // employee_id_generator.dart
// import 'package:cloud_firestore/cloud_firestore.dart';

// class EmployeeIdGenerator {
//   static const String _prefix = 'OOB';
//   static const int _idLength = 3;

//   Future<String> generateEmployeeId() async {
//     final querySnapshot = await FirebaseFirestore.instance
//         .collection('Regemp')
//         .orderBy('employeeId', descending: true)
//         .limit(1)
//         .get();

//     if (querySnapshot.docs.isEmpty) {
//       return '$_prefix${_formatId(1)}';
//     } else {
//       final lastId = querySnapshot.docs.first.get('employeeId') as String;
//       final numericPart = int.tryParse(lastId.replaceFirst(_prefix, '')) ?? 0;
//       return '$_prefix${_formatId(numericPart + 1)}';
//     }
//   }

//   String _formatId(int id) {
//     return id.toString().padLeft(_idLength, '0');
//   }
// }
import 'package:cloud_firestore/cloud_firestore.dart';

class EmployeeIdGenerator {
  Future<String> generateEmployeeId(String location) async {
    // Fetch location details from Firestore collection "location"
    DocumentReference locationRef =
        FirebaseFirestore.instance.collection('Locations').doc(location);

    DocumentSnapshot locationDoc = await locationRef.get();

    if (locationDoc.exists) {
      // Cast data to Map<String, dynamic>
      Map<String, dynamic> locationData =
          locationDoc.data() as Map<String, dynamic>;

      // Get prefix and current count
      String prefix = locationData['prefix'];
      int count;

      // Check if count field exists
      if (locationData.containsKey('count')) {
        count = locationData['count'];
      } else {
        count = 0;
      }

      // Increment count
      count++;

      // Update count in Firestore
      await locationRef.update({'count': count});

      // Generate employeeId with format: prefix + count (e.g., JEY001)
      String employeeId = '$prefix${count.toString().padLeft(3, '0')}';
      return employeeId;
    } else {
      throw Exception('Location details not found');
    }
  }
}