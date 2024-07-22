
// // import 'package:flutter/material.dart';
// // import 'package:image_picker/image_picker.dart';
// // import 'package:ooriba_s3/services/employeeService.dart';
// // import 'dart:io';

// // import 'package:ooriba_s3/services/retrieveDataByEmail.dart';

// // class EditPersonalDetailsPage extends StatefulWidget {
// //   final String email;

// //   const EditPersonalDetailsPage({Key? key, required this.email}) : super(key: key);

// //   @override
// //   _EditPersonalDetailsPageState createState() => _EditPersonalDetailsPageState();
// // }

// // class _EditPersonalDetailsPageState extends State<EditPersonalDetailsPage> {
// //   final _formKey = GlobalKey<FormState>();
// //   final _phoneNumber = TextEditingController();
// //   final _firstName = TextEditingController();
// //   final _middleName = TextEditingController();
// //   final _lastName = TextEditingController();
// //   final _email = TextEditingController();
// //   final _residentialAddress = TextEditingController();
// //   final _permanentAddress = TextEditingController();
// //   final _password = TextEditingController();
// //   File? dpImage, supportImage, adhaarImage;
// //   FirestoreService firestoreService = FirestoreService();

// //   @override
// //   void initState() {
// //     super.initState();
// //     _fetchEmployeeData();
// //   }

// //   Future<void> _fetchEmployeeData() async {
// //     Map<String, dynamic>? userDetails = await firestoreService.getEmployeeByEmail(widget.email);
// //     if (userDetails != null) {
// //       setState(() {
// //         _firstName.text = userDetails['firstName'] ?? '';
// //         _middleName.text = userDetails['middleName'] ?? '';
// //         _lastName.text = userDetails['lastName'] ?? '';
// //         _email.text = widget.email;
// //         _residentialAddress.text = userDetails['residentialAddress'] ?? '';
// //         _permanentAddress.text = userDetails['permanentAddress'] ?? '';
// //         _phoneNumber.text = userDetails['phoneNo'] ?? '';
// //         _password.text = userDetails['password'] ?? '';
// //       });
// //     }
// //   }

// //   Future<void> _pickImage(int x) async {
// //     final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
// //     if (pickedFile != null) {
// //       setState(() {
// //         if (x == 2) {
// //           dpImage = File(pickedFile.path);
// //         }
// //         if (x == 1) {
// //           adhaarImage = File(pickedFile.path);
// //         }
// //         if (x == 3) {
// //           supportImage = File(pickedFile.path);
// //         }
// //       });
// //     }
// //   }

// //   void _submitForm() async {
// //     final firstName = _firstName.text.isNotEmpty ? _firstName.text : null;
// //     final middleName = _middleName.text.isNotEmpty ? _middleName.text : null;
// //     final lastName = _lastName.text.isNotEmpty ? _lastName.text : null;
// //     final email = _email.text.isNotEmpty ? _email.text : null;
// //     final password = _password.text.isNotEmpty ? _password.text : null;
// //     final resAdd = _residentialAddress.text.isNotEmpty ? _residentialAddress.text : null;
// //     final perAdd = _permanentAddress.text.isNotEmpty ? _permanentAddress.text : null;
// //     final phoneNo = _phoneNumber.text.isNotEmpty ? _phoneNumber.text : null;
// //     EmployeeService employeeService = EmployeeService();

// //     try {
// //       await employeeService.updateEmployee(
// //         email: widget.email,
// //         firstName: firstName,
// //         middleName: middleName,
// //         lastName: lastName,
// //         resAdd: resAdd,
// //         perAdd: perAdd,
// //         phoneNo: phoneNo,
// //         dpImage: dpImage,
// //         adhaarImage: adhaarImage,
// //         supportImage: supportImage,
// //         context: context,
// //       );
// //       ScaffoldMessenger.of(context).showSnackBar(
// //         SnackBar(content: Text('Details updated successfully')),
// //       );
// //       Navigator.pop(context);
// //     } catch (e) {
// //       ScaffoldMessenger.of(context).showSnackBar(
// //         SnackBar(content: Text('Failed to update details: $e')),
// //       );
// //     }
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       appBar: AppBar(
// //         title: const Text('Edit Personal Details'),
// //       ),
// //       body: SingleChildScrollView(
// //         child: Padding(
// //           padding: const EdgeInsets.all(16.0),
// //           child: Center(
// //             child: ConstrainedBox(
// //               constraints: const BoxConstraints(
// //                 maxWidth: 400, // Limit the width for larger screens
// //               ),
// //               child: Container(
// //                 padding: const EdgeInsets.all(16.0),
// //                 decoration: BoxDecoration(
// //                   color: Colors.white,
// //                   borderRadius: BorderRadius.circular(10),
// //                   boxShadow: const [
// //                     BoxShadow(
// //                       color: Colors.black12,
// //                       blurRadius: 10,
// //                       offset: Offset(0, 5),
// //                     ),
// //                   ],
// //                 ),
// //                 child: Form(
// //                   key: _formKey,
// //                   child: Column(
// //                     mainAxisAlignment: MainAxisAlignment.center,
// //                     children: <Widget>[
// //                       const Text(
// //                         'Edit Personal Details',
// //                         style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
// //                       ),
// //                       const SizedBox(height: 20),
// //                       TextFormField(
// //                         controller: _firstName,
// //                         decoration: const InputDecoration(
// //                           labelText: 'First Name',
// //                           border: OutlineInputBorder(),
// //                         ),
// //                       ),
// //                       const SizedBox(height: 20),
// //                       TextFormField(
// //                         controller: _middleName,
// //                         decoration: const InputDecoration(
// //                           labelText: 'Middle Name',
// //                           border: OutlineInputBorder(),
// //                         ),
// //                       ),
// //                       const SizedBox(height: 20),
// //                       TextFormField(
// //                         controller: _lastName,
// //                         decoration: const InputDecoration(
// //                           labelText: 'Last Name',
// //                           border: OutlineInputBorder(),
// //                         ),
// //                       ),
// //                       const SizedBox(height: 20),
// //                       TextFormField(
// //                         controller: _email,
// //                         decoration: const InputDecoration(
// //                           labelText: 'Email',
// //                           border: OutlineInputBorder(),
// //                         ),
// //                       ),
// //                       const SizedBox(height: 20),
// //                       TextFormField(
// //                         controller: _password,
// //                         decoration: const InputDecoration(
// //                           labelText: 'Password',
// //                           border: OutlineInputBorder(),
// //                         ),
// //                         obscureText: true,
// //                       ),
// //                       const SizedBox(height: 20),
// //                       TextFormField(
// //                         controller: _residentialAddress,
// //                         decoration: const InputDecoration(
// //                           labelText: 'Residential Address',
// //                           border: OutlineInputBorder(),
// //                         ),
// //                       ),
// //                       const SizedBox(height: 20),
// //                       TextFormField(
// //                         controller: _permanentAddress,
// //                         decoration: const InputDecoration(
// //                           labelText: 'Permanent Address',
// //                           border: OutlineInputBorder(),
// //                         ),
// //                       ),
// //                       const SizedBox(height: 20),
// //                       TextFormField(
// //                         controller: _phoneNumber,
// //                         decoration: const InputDecoration(
// //                           labelText: 'Phone Number',
// //                           border: OutlineInputBorder(),
// //                         ),
// //                       ),
// //                       const SizedBox(height: 20),
// //                       ElevatedButton(
// //                         onPressed: () => _pickImage(2),
// //                         child: const Text('Upload DP Image'),
// //                       ),
// //                       const SizedBox(height: 10),
// //                       dpImage == null ? const Text('No image selected.') : Image.file(dpImage!),
// //                       const SizedBox(height: 20),
// //                       ElevatedButton(
// //                         onPressed: () => _pickImage(1),
// //                         child: const Text('Upload Aadhaar Image'),
// //                       ),
// //                       const SizedBox(height: 10),
// //                       adhaarImage == null ? const Text('No image selected.') : Image.file(adhaarImage!),
// //                       const SizedBox(height: 20),
// //                       ElevatedButton(
// //                         onPressed: () => _pickImage(3),
// //                         child: const Text('Upload Supporting Image'),
// //                       ),
// //                       const SizedBox(height: 10),
// //                       supportImage == null ? const Text('No image selected.') : Image.file(supportImage!),
// //                       const SizedBox(height: 20),
// //                       ElevatedButton(
// //                         onPressed: _submitForm,
// //                         child: const Text('Save Changes'),
// //                       ),
// //                     ],
// //                   ),
// //                 ),
// //               ),
// //             ),
// //           ),
// //         ),
// //       ),
// //     );
// //   }
// // }

// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:ooriba_s3/services/employeeService.dart';
// import 'dart:io';

// import 'package:ooriba_s3/services/retrieveDataByEmail.dart';

// class EditPersonalDetailsPage extends StatefulWidget {
//   final String email;

//   const EditPersonalDetailsPage({super.key, required this.email});

//   @override
//   _EditPersonalDetailsPageState createState() => _EditPersonalDetailsPageState();
// }

// class _EditPersonalDetailsPageState extends State<EditPersonalDetailsPage> {
//   final _formKey = GlobalKey<FormState>();
//   final _phoneNumber = TextEditingController();
//   final _firstName = TextEditingController();
//   final _middleName = TextEditingController();
//   final _lastName = TextEditingController();
//   final _email = TextEditingController();
//   final _residentialAddress = TextEditingController();
//   final _permanentAddress = TextEditingController();
//   final _password = TextEditingController();
//   File? dpImage, supportImage, adhaarImage;
//   FirestoreService firestoreService = FirestoreService();

//   @override
//   void initState() {
//     super.initState();
//     _fetchEmployeeData();
//   }

//   Future<void> _fetchEmployeeData() async {
//     Map<String, dynamic>? userDetails = await firestoreService.getEmployeeByEmail(widget.email, 'Regemp');
//     if (userDetails != null) {
//       setState(() {
//         _firstName.text = userDetails['firstName'] ?? '';
//         _middleName.text = userDetails['middleName'] ?? '';
//         _lastName.text = userDetails['lastName'] ?? '';
//         _email.text = widget.email;
//         _residentialAddress.text = userDetails['residentialAddress'] ?? '';
//         _permanentAddress.text = userDetails['permanentAddress'] ?? '';
//         _phoneNumber.text = userDetails['phoneNo'] ?? '';
//         _password.text = userDetails['password'] ?? '';
//       });
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Employee data not found')),
//       );
//     }
//   }

//   Future<void> _pickImage(int x) async {
//     final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
//     if (pickedFile != null) {
//       setState(() {
//         if (x == 2) {
//           dpImage = File(pickedFile.path);
//         }
//         if (x == 1) {
//           adhaarImage = File(pickedFile.path);
//         }
//         if (x == 3) {
//           supportImage = File(pickedFile.path);
//         }
//       });
//     }
//   }

//   void _submitForm() async {
//     final firstName = _firstName.text.isNotEmpty ? _firstName.text : null;
//     final middleName = _middleName.text.isNotEmpty ? _middleName.text : null;
//     final lastName = _lastName.text.isNotEmpty ? _lastName.text : null;
//     final email = _email.text.isNotEmpty ? _email.text : null;
//     final password = _password.text.isNotEmpty ? _password.text : null;
//     final resAdd = _residentialAddress.text.isNotEmpty ? _residentialAddress.text : null;
//     final perAdd = _permanentAddress.text.isNotEmpty ? _permanentAddress.text : null;
//     final phoneNo = _phoneNumber.text.isNotEmpty ? _phoneNumber.text : null;
//     EmployeeService employeeService = EmployeeService();

//     try {
//       await employeeService.updateEmployee(
//         email: widget.email,
//         firstName: firstName,
//         middleName: middleName,
//         lastName: lastName,
//         resAdd: resAdd,
//         perAdd: perAdd,
//         phoneNo: phoneNo,
//         dpImage: dpImage,
//         adhaarImage: adhaarImage,
//         supportImage: supportImage,
//         context: context,
//       );
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Details updated successfully')),
//       );
//       Navigator.pop(context);
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Failed to update details: $e')),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Edit Personal Details'),
//       ),
//       body: SingleChildScrollView(
//         child: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Center(
//             child: ConstrainedBox(
//               constraints: const BoxConstraints(
//                 maxWidth: 400, // Limit the width for larger screens
//               ),
//               child: Container(
//                 padding: const EdgeInsets.all(16.0),
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.circular(10),
//                   boxShadow: const [
//                     BoxShadow(
//                       color: Colors.black12,
//                       blurRadius: 10,
//                       offset: Offset(0, 5),
//                     ),
//                   ],
//                 ),
//                 child: Form(
//                   key: _formKey,
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: <Widget>[
//                       const Text(
//                         'Edit Personal Details',
//                         style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
//                       ),
//                       const SizedBox(height: 20),
//                       TextFormField(
//                         controller: _firstName,
//                         decoration: const InputDecoration(
//                           labelText: 'First Name',
//                           border: OutlineInputBorder(),
//                         ),
//                       ),
//                       const SizedBox(height: 20),
//                       TextFormField(
//                         controller: _middleName,
//                         decoration: const InputDecoration(
//                           labelText: 'Middle Name',
//                           border: OutlineInputBorder(),
//                         ),
//                       ),
//                       const SizedBox(height: 20),
//                       TextFormField(
//                         controller: _lastName,
//                         decoration: const InputDecoration(
//                           labelText: 'Last Name',
//                           border: OutlineInputBorder(),
//                         ),
//                       ),
//                       const SizedBox(height: 20),
//                       TextFormField(
//                         controller: _email,
//                         decoration: const InputDecoration(
//                           labelText: 'Email',
//                           border: OutlineInputBorder(),
//                         ),
//                       ),
//                       const SizedBox(height: 20),
//                       TextFormField(
//                         controller: _password,
//                         decoration: const InputDecoration(
//                           labelText: 'Password',
//                           border: OutlineInputBorder(),
//                         ),
//                         obscureText: true,
//                       ),
//                       const SizedBox(height: 20),
//                       TextFormField(
//                         controller: _residentialAddress,
//                         decoration: const InputDecoration(
//                           labelText: 'Residential Address',
//                           border: OutlineInputBorder(),
//                         ),
//                       ),
//                       const SizedBox(height: 20),
//                       TextFormField(
//                         controller: _permanentAddress,
//                         decoration: const InputDecoration(
//                           labelText: 'Permanent Address',
//                           border: OutlineInputBorder(),
//                         ),
//                       ),
//                       const SizedBox(height: 20),
//                       TextFormField(
//                         controller: _phoneNumber,
//                         decoration: const InputDecoration(
//                           labelText: 'Phone Number',
//                           border: OutlineInputBorder(),
//                         ),
//                       ),
//                       const SizedBox(height: 20),
//                       ElevatedButton(
//                         onPressed: () => _pickImage(2),
//                         child: const Text('Upload DP Image'),
//                       ),
//                       const SizedBox(height: 10),
//                       dpImage == null ? const Text('No image selected.') : Image.file(dpImage!),
//                       const SizedBox(height: 20),
//                       ElevatedButton(
//                         onPressed: () => _pickImage(1),
//                         child: const Text('Upload Aadhaar Image'),
//                       ),
//                       const SizedBox(height: 10),
//                       adhaarImage == null ? const Text('No image selected.') : Image.file(adhaarImage!),
//                       const SizedBox(height: 20),
//                       ElevatedButton(
//                         onPressed: () => _pickImage(3),
//                         child: const Text('Upload Supporting Image'),
//                       ),
//                       const SizedBox(height: 10),
//                       supportImage == null ? const Text('No image selected.') : Image.file(supportImage!),
//                       const SizedBox(height: 20),
//                       ElevatedButton(
//                         onPressed: _submitForm,
//                         child: const Text('Save Changes'),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
