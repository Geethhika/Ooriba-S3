// // //EmailJS
// // import 'dart:convert';
// // import 'package:flutter/foundation.dart';
// // import 'package:http/http.dart' as http;
// // import 'package:flutter/material.dart';
// // import 'package:intl/intl.dart';
// // import 'package:ooriba_s3/services/auth_service.dart';
// // import 'package:ooriba_s3/services/updateEmployee.dart';
// // import 'package:ooriba_s3/services/retrieveDataByEmail.dart' as retrieveDataByEmail;

// // class EmployeeCheckInPage extends StatefulWidget {
  
// //  final String empname;
// //   final String empemail;
 
// //   const EmployeeCheckInPage({super.key, required this.empname, required this.empemail});

// //   @override
// //   // ignore: library_private_types_in_public_api
// //   _EmployeeCheckInPageState createState() => _EmployeeCheckInPageState();
// // }

// // class CheckInOutRecord {
// //   final DateTime date;
// //   bool isCheckedIn;
// //   DateTime? checkInTime;
// //   DateTime? checkOutTime;

// //   CheckInOutRecord(
// //       {required this.date,
// //       this.isCheckedIn = false,
// //       this.checkInTime,
// //       this.checkOutTime});
// // }


// // class _EmployeeCheckInPageState extends State<EmployeeCheckInPage> {
// //    String? employeeId;
// //   String? employeeName;
// //    late DateTime dataDate;
// //   late List<CheckInOutRecord> checkInOutRecords;
// //    late String _email;
 

// //   @override
// //   void initState() {
// //     super.initState();
// //     _email = widget.empemail;
// //     checkInOutRecords = _generateCheckInOutRecords();
// //      _fetchEmployeeDetails(widget.empemail);
// //   }
// //  String formatTimeWithoutSeconds(DateTime? dateTime) {
// //     if (dateTime == null) {
// //       return 'N/A'; // Return 'N/A' if dateTime is null
// //     }
// //     return DateFormat('yyyy-MM-dd HH:mm').format(dateTime); // Format without seconds
// //   }
// //   Future<void> _fetchEmployeeDetails(String email) async {
// //     retrieveDataByEmail.FirestoreService firestoreService = retrieveDataByEmail.FirestoreService();
// //     Map<String, dynamic>? employeeData = await firestoreService.getEmployeeByEmail(email);

// //     if (employeeData != null) {
// //       setState(() {
// //         employeeId = employeeData['employeeId'];
// //         employeeName = employeeData['firstName'];
// //         // employeeName = employeeData['firstName'] + ' ' + employeeData['lastName'];
// //       });
// //     }
// //   }

// //   List<CheckInOutRecord> _generateCheckInOutRecords() {

// //     // Generate records for the last 7 days
// //     List<CheckInOutRecord> records = [];
// //     DateTime now = DateTime.now();
    
// //     for (int i = 0; i < 1; i++) {
// //       DateTime date = now.subtract(Duration(days: i));
// //       // Dummy logic to alternate check-in and check-out for demonstration
// //       bool isCheckedIn = i.isOdd;
// //       DateTime? checkInTime = isCheckedIn ? date.add(Duration(hours: 8)) : null;
// //       DateTime? checkOutTime =
// //           isCheckedIn ? null : date.add(Duration(hours: 8));

// //       records.add(CheckInOutRecord(
// //           date: date,
// //           isCheckedIn: isCheckedIn,
// //           checkInTime: checkInTime,
// //           checkOutTime: checkOutTime));
// //     }
// //     return records;
// //   }

  

// //  void _toggleCheckInOut(int index) async {
  
// //     final FirestoreService _firestoreService = FirestoreService();
// //        void _addData() async {
// //     if (widget.empname.isNotEmpty) {
// //       setState(() {
// //       });
      
// //       await _firestoreService.addCheckInOutData(widget.empemail,checkInOutRecords[index].checkInTime!,checkInOutRecords[index].checkOutTime!,dataDate);

// //       setState(() {
// //       });

// //       ScaffoldMessenger.of(context).showSnackBar(
// //         SnackBar(content: Text('Data added successfully')),
// //       );
// //     } else {
// //       ScaffoldMessenger.of(context).showSnackBar(
// //         SnackBar(content: Text('Please enter a first name')),
// //       );
// //     }
// //   }
      
// //     setState(() {
// //       DateTime now=DateTime.now();
// //       checkInOutRecords[index].isCheckedIn =
// //           !checkInOutRecords[index].isCheckedIn;
// //         dataDate=now.subtract(Duration(days: index));
// //       if (checkInOutRecords[index].isCheckedIn) {
// //         checkInOutRecords[index].checkInTime = DateTime.now();
// //         checkInOutRecords[index].checkOutTime = null;

// //         // _sendCheckInEmail(widget.empname, widget.empemail,
// //         //     checkInOutRecords[index].checkInTime!);
// //       } else {
// //         checkInOutRecords[index].checkOutTime = DateTime.now();
// //          _addData();
// //         // _sendCheckOutEmail(widget.empname, widget.empemail,
// //         //     checkInOutRecords[index].checkOutTime!);
// //       }
// //     });
// //     //update into database

     

// //   }

// //   //email thing by emailJS
// //   // Future<void> _sendCheckInEmail(
// //   //     String empname,String empemail, DateTime checkInTime) async {
// //   //   const serviceId = 'service_qe69w28';
// //   //   const templateId = 'template_1owmygk';
// //   //   const userId = 'lMYaM2NpLYjm2qSWI';
// //   //   final url = Uri.parse('https://api.emailjs.com/api/v1.0/email/send');
// //   //   final response = await http.post(
// //   //     url,
// //   //     headers: {
// //   //       'origin':'http:localhost',
// //   //       'Content-Type': 'application/json',
// //   //     },
// //   //     body: jsonEncode({
// //   //       'service_id': serviceId,
// //   //       'template_id': templateId,
// //   //       'user_id': userId,
// //   //       'template_params': {
// //   //         'empname': empname,
// //   //         'empemail':empemail,
// //   //         'check_in_time': checkInTime.toIso8601String(),
// //   //       }
// //   //     }),
// //   //   );

// //   //   if (response.statusCode == 200) {
// //   //     if (kDebugMode) {
// //   //       print('Check-in email sent successfully');
// //   //     }
// //   //   } else {
// //   //     if (kDebugMode) {
// //   //       print('Failed to send check-in email: ${response.body}');
// //   //     }
// //   //   }
// //   // }

// //   // Future<void> _sendCheckOutEmail(
// //   //     String empname,String empemail, DateTime checkOutTime) async {
// //   //   const serviceId = 'service_qe69w28';
// //   //   const templateId = 'template_drhybtc';
// //   //   const userId = 'lMYaM2NpLYjm2qSWI';
// //   //   final url = Uri.parse('https://api.emailjs.com/api/v1.0/email/send');
// //   //   final response = await http.post(
// //   //     url,
// //   //     headers: {  
// //   //       'Content-Type': 'application/json',
// //   //     },
// //   //     body: jsonEncode({
// //   //       'service_id': serviceId,
// //   //       'template_id': templateId,
// //   //       'user_id': userId,
// //   //       'template_params': {
// //   //         'empemail':empemail,
// //   //         'empname': empname,
// //   //         'check_out_time': checkOutTime.toIso8601String(),
// //   //       }
// //   //     }),
// //   //   );

// //   //   if (response.statusCode == 200) {
// //   //     if (kDebugMode) {
// //   //       print('Check-out email sent successfully');
// //   //     }
// //   //   } else {
// //   //     if (kDebugMode) {
// //   //       print('Failed to send check-out email: ${response.body}');
// //   //     }
// //   //   }
// //   // }

// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       appBar: AppBar(
// //         title: Text('Welcome, ${employeeId != null && employeeName != null ? '$employeeName-$employeeId' : widget.empemail}'),
// //         actions: [
// //           IconButton(
// //             icon: Icon(Icons.logout),
// //            onPressed: () async {
// //         await AuthService().signout(context: context);
// //       },
// //           ),
// //         ],
// //       ),
// //       body: ListView.builder(
// //   itemCount: checkInOutRecords.length,
// //   itemBuilder: (context, index) {
// //     bool isCheckedIn = checkInOutRecords[index].isCheckedIn;
// //     return ListTile(
// //       title: Text(
// //         'Date: ${checkInOutRecords[index].date.toLocal().toString().split(' ')[0]}',
// //       ),
// //       subtitle: isCheckedIn
// //           ? Text('Checked in at: ${formatTimeWithoutSeconds(checkInOutRecords[index].checkInTime)}')
// //           : Text('Checked out at: ${formatTimeWithoutSeconds(checkInOutRecords[index].checkOutTime)}'),
// //       trailing: ElevatedButton(
// //         onPressed: () => _toggleCheckInOut(index),
// //         style: ElevatedButton.styleFrom(
// //           backgroundColor: isCheckedIn ? Colors.green: Colors.orange, // Set button color
// //         ),
// //         child: Text(isCheckedIn ? 'Check Out' : 'Check In'),
// //       ),
// //     );
// //   },
// // ),

// //     );
// //   }
 
// // }

// //EmailJS
// // import 'dart:convert';
// // import 'package:flutter/foundation.dart';
// // import 'package:http/http.dart' as http;

// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:ooriba_s3/services/auth_service.dart';
// import 'package:ooriba_s3/services/updateEmployeeDate.dart';
// import 'package:ooriba_s3/services/retrieveDataByEmail.dart' as retrieveDataByEmail;

// class EmployeeCheckInPage extends StatefulWidget {
//   final String empname;
//   final String empemail;

//   const EmployeeCheckInPage({super.key, required this.empname, required this.empemail});

//   @override
//   // ignore: library_private_types_in_public_api
//   _EmployeeCheckInPageState createState() => _EmployeeCheckInPageState();
// }

// class CheckInOutRecord {
//   final DateTime date;
//   bool isCheckedIn;
//   DateTime? checkInTime;
//   DateTime? checkOutTime;

//   CheckInOutRecord({
//     required this.date,
//     this.isCheckedIn = false,
//     this.checkInTime,
//     this.checkOutTime,
//   });
// }

// class _EmployeeCheckInPageState extends State<EmployeeCheckInPage> {
//   String? employeeId;
//   String? employeeName;
//   String? employeePhoneNumber; // Add this line
//   late DateTime dataDate;
//   late List<CheckInOutRecord> checkInOutRecords;
//   late String _email;

//   @override
//   void initState() {
//     super.initState();
//     _email = widget.empemail;
//     checkInOutRecords = _generateCheckInOutRecords();
//     _fetchEmployeeDetails(widget.empemail);
//   }

//   String formatTimeWithoutSeconds(DateTime? dateTime) {
//     if (dateTime == null) {
//       return 'Null'; // Return 'N/A' if dateTime is null
//     }
//     return DateFormat('yyyy-MM-dd HH:mm').format(dateTime); // Format without seconds
//   }

//   Future<void> _fetchEmployeeDetails(String email) async {
//     retrieveDataByEmail.FirestoreService firestoreService = retrieveDataByEmail.FirestoreService();
//     Map<String, dynamic>? employeeData = await firestoreService.getEmployeeByEmail(email,'Regemp');

//     if (employeeData != null) {
//       setState(() {
//         employeeId = employeeData['employeeId'];
//         employeeName = employeeData['firstName'];
//         employeePhoneNumber = employeeData['phoneNo']; // Assuming the phone number is stored with this key
//       });
//     }
//   }

//   List<CheckInOutRecord> _generateCheckInOutRecords() {
//     // Generate records for the last 7 days
//     List<CheckInOutRecord> records = [];
//     DateTime now = DateTime.now();

//     for (int i = 0; i < 1; i++) {
//       DateTime date = now.subtract(Duration(days: i));
//       // Dummy logic to alternate check-in and check-out for demonstration
//       bool isCheckedIn = i.isOdd;
//       DateTime? checkInTime = isCheckedIn ? date.add(const Duration(hours: 8)) : null;
//       DateTime? checkOutTime = isCheckedIn ? null : date.add(const Duration(hours: 8));

//       records.add(CheckInOutRecord(
//         date: date,
//         isCheckedIn: isCheckedIn,
//         checkInTime: checkInTime,
//         checkOutTime: checkOutTime,
//       ));
//     }
//     return records;
//   }


//   void _toggleCheckInOut(int index) async {
//     //update employee attendance date
//     final FirestoreService firestoreService = FirestoreService();
//     void addData() async {
//       if (widget.empname.isNotEmpty) {
//         setState(() {});

//         await firestoreService.addCheckInOutData(
//             widget.empemail, checkInOutRecords[index].checkInTime!, checkInOutRecords[index].checkOutTime!, dataDate);

//         setState(() {});

//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Data added successfully')),
//         );
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Please enter a first name')),
//         );
//       }
//     }

//     setState(() {
//       DateTime now = DateTime.now();
//       checkInOutRecords[index].isCheckedIn = !checkInOutRecords[index].isCheckedIn;
//       dataDate = now.subtract(Duration(days: index));
//       if (checkInOutRecords[index].isCheckedIn) {
//         checkInOutRecords[index].checkInTime = DateTime.now();
//         checkInOutRecords[index].checkOutTime = null;
//       } else {
//         checkInOutRecords[index].checkOutTime = DateTime.now();
//         addData();

//         // Send SMS on checkout
//         // if (employeePhoneNumber != null) {
//         //   String message = "Hello ${widget.empname}, you have successfully checked out on ${formatTimeWithoutSeconds(checkInOutRecords[index].checkOutTime)}.";
//         //   // _sendSms(employeePhoneNumber!, message);
//         // } else {
//         //   print("Employee phone number not available.");
//         // }

//       }
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Welcome, ${employeeId != null && employeeName != null ? '$employeeName-$employeeId' : widget.empemail}'),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.logout),
//             onPressed: () async {
//               await AuthService().signout(context: context);
//             },
//           ),
//         ],
//       ),
//       body: ListView.builder(
//         itemCount: checkInOutRecords.length,
//         itemBuilder: (context, index) {
//           bool isCheckedIn = checkInOutRecords[index].isCheckedIn;
//           return ListTile(
//             title: Text(
//               'Date: ${checkInOutRecords[index].date.toLocal().toString().split(' ')[0]}',
//             ),
//             subtitle: isCheckedIn
//                 ? Text('Checked in at: ${formatTimeWithoutSeconds(checkInOutRecords[index].checkInTime)}')
//                 : Text('Checked out at: ${formatTimeWithoutSeconds(checkInOutRecords[index].checkOutTime)}'),
//             trailing: ElevatedButton(
//               onPressed: () => _toggleCheckInOut(index),
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: isCheckedIn ? Colors.green : Colors.orange, // Set button color
//               ),
//               child: Text(isCheckedIn ? 'Check Out' : 'Check In'),
//             ),
//           );
//         },
//       ),
//     );
//   }
// }
