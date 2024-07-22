// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter_email_sender/flutter_email_sender.dart';

// class SignUpEmailService {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;

//   Future<Map<String, dynamic>> getEmployeeDetails(String email) async {
//     try {
//       DocumentSnapshot doc =
//           await _firestore.collection('Employee').doc(email).get();
//       if (doc.exists) {
//         return doc.data() as Map<String, dynamic>;
//       } else {
//         throw Exception('No employee found with this email.');
//       }
//     } catch (e) {
//       throw Exception('Failed to fetch employee details: $e');
//     }
//   }

//   Future<void> sendSignUpEmail(String email) async {
//     final employeeData = await getEmployeeDetails(email);

//     final Email emailToSend = Email(
//       body: 'A new employee has signed up.\n\n'
//           'First Name: ${employeeData['firstName']}\n'
//           'Last Name: ${employeeData['lastName']}\n'
//           'Email: ${employeeData['email']}\n'
//           'Please review the sign-up details.',
//       subject: 'New Employee Sign Up',
//       recipients: [
//         'anweshadash04@gmail.com'
//       ], // Replace with the HR email address
//       cc: [
//         'geethikamulugu@gmail.com'
//       ], // Replace with CC email address if needed
//       bcc: ['bcc@example.com'], // Replace with BCC email address if needed
//       isHTML: false,
//     );

//     try {
//       await FlutterEmailSender.send(emailToSend);
//     } catch (e) {
//       throw Exception('Failed to send sign-up email: $e');
//     }
//   }
// }