// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import 'package:ooriba_s3/HR/hr_dashboard_page.dart';
// import 'package:ooriba_s3/employee_checkin_page.dart';
// import 'package:ooriba_s3/employee_signup_success.dart';
// import 'package:ooriba_s3/facial/HomeScreen.dart';
// import 'package:ooriba_s3/main.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// class AuthService {

//   Future<void> signup({
//     required String email,
//     required String password,
//     required BuildContext context,
//   }) async {
//     try {
//       await FirebaseAuth.instance.createUserWithEmailAndPassword(
//         email: email,
//         password: password,
//       );

//       await Future.delayed(const Duration(seconds: 1));
//       Navigator.push(
//         context,
//         MaterialPageRoute(builder: (context) => ConfirmationPage()),
//       );
//     } on FirebaseAuthException catch (e) {
//       String message = '';
//       if (e.code == 'weak-password') {
//         message = 'The password provided is too weak.';
//       } else if (e.code == 'email-already-in-use') {
//         message = 'An account already exists with that email.';
//       }
//       Fluttertoast.showToast(
//         msg: message,
//         toastLength: Toast.LENGTH_LONG,
//         gravity: ToastGravity.SNACKBAR,
//         backgroundColor: Colors.black54,
//         textColor: Colors.white,
//         fontSize: 14.0,
//       );
//     }
//   }
//   //   Future<bool> signin({
// //     required String email,
// //     required String password,
// //     required String role,
// //     required BuildContext context,
// //   }) async {
// //     final FirestoreService firestore_Service = FirestoreService();
// //     Map<String, dynamic>? employeeData = await firestore_Service.searchEmployee(email: email);

// //     try {
// //       await FirebaseAuth.instance.signInWithEmailAndPassword(
// //         email: email,
// //         password: password,
// //       );

// //       await Future.delayed(const Duration(seconds: 1));
// //       if (role == "employee") {
// //         String firstName = employeeData != null ? employeeData['firstName'] ?? '' : '';
// //         Navigator.pushReplacement(
// //           context,
// //           MaterialPageRoute(
// //             builder: (BuildContext context) => EmployeeCheckInPage(empname: firstName, empemail: email),
// //           ),
// //         );
// //       } else {
// //         Navigator.pushReplacement(
// //           context,
// //           MaterialPageRoute(
// //             builder: (BuildContext context) => const HRDashboardPage(),
// //           ),
// //         );
// //       }
// //       return true;
// //     } on FirebaseAuthException catch (e) {
// //       String message = '';
// //       if (e.code == 'invalid-email') {
// //         message = 'No user found for that email.';
// //       } else if (e.code == 'invalid-credential') {
// //         message = 'Wrong password provided for that user.';
// //       }
// //       Fluttertoast.showToast(
// //         msg: message,
// //         toastLength: Toast.LENGTH_LONG,
// //         gravity: ToastGravity.SNACKBAR,
// //         backgroundColor: Colors.black54,
// //         textColor: Colors.white,
// //         fontSize: 14.0,
// //       );
// //       return false;
// //     }

//   Future<bool> signin({
//     required String email,
//     required String password,
//     required BuildContext context,
//   }) async {
//     try {
//       // Fetch the document from the Firestore collection "Regemp"
//       DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
//           await FirebaseFirestore.instance
//               .collection('Regemp')
//               .doc(email)
//               .get();

//       // Check if the document exists
//       if (!documentSnapshot.exists) {
//         Fluttertoast.showToast(
//           msg: 'No user found for that email.',
//           toastLength: Toast.LENGTH_LONG,
//           gravity: ToastGravity.SNACKBAR,
//           backgroundColor: Colors.black54,
//           textColor: Colors.white,
//           fontSize: 14.0,
//         );
//         return false;
//       }

//       // Retrieve the role from the document
//       String role = documentSnapshot.data()?['role'] ?? '';

//       // Sign in with Firebase Authentication
//       await FirebaseAuth.instance.signInWithEmailAndPassword(
//         email: email,
//         password: password,
//       );

//       // Navigate to the appropriate page based on the role
//       await Future.delayed(const Duration(seconds: 1));
//       if (role == "Standard") {
//         String firstName = documentSnapshot.data()?['firstName'] ?? '';
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(
//             builder: (BuildContext context) =>
//                 HomeScreen(email: email),
//           ),
//           // MaterialPageRoute(
//           //   builder: (BuildContext context) =>
//           //       EmployeeCheckInPage(empname: firstName, empemail: email),
//           // ),
//         );
//         return true;
//       } else if (role == "HR") {
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(
//             builder: (BuildContext context) => const HRDashboardPage(),
//           ),
//         );
//         return false;
//       } else {
//         Fluttertoast.showToast(
//           msg: 'Invalid role assigned to the user.',
//           toastLength: Toast.LENGTH_LONG,
//           gravity: ToastGravity.SNACKBAR,
//           backgroundColor: Colors.black54,
//           textColor: Colors.white,
//           fontSize: 14.0,
//         );
//         return false;
//       }
//       return true;
//     } on FirebaseAuthException catch (e) {
//       String message = '';
//       if (e.code == 'invalid-email') {
//         message = 'No user found for that email.';
//       } else if (e.code == 'invalid-credential') {
//         message = 'Wrong password provided for that user.';
//       }
//       Fluttertoast.showToast(
//         msg: message,
//         toastLength: Toast.LENGTH_LONG,
//         gravity: ToastGravity.SNACKBAR,
//         backgroundColor: Colors.black54,
//         textColor: Colors.white,
//         fontSize: 14.0,
//       );
//       return false;
//     }
//   }

//   Future<void> signout({
//     required BuildContext context,
//   }) async {
//     await FirebaseAuth.instance.signOut();
//     await Future.delayed(const Duration(seconds: 1));
//     Navigator.pushReplacement(
//       context,
//       MaterialPageRoute(
//         builder: (BuildContext context) => LoginPage(),
//       ),
//     );
//   }

//   getUserSession() {}
// }

// Future<void> saveUserSession(String? uid) async {
//     final SharedPreferences prefs = await SharedPreferences.getInstance();
//     await prefs.setString('userUid', uid ?? '');
//   }

//   Future<String?> getUserSession() async {
//     final SharedPreferences prefs = await SharedPreferences.getInstance();
//     return prefs.getString('userUid');
//   }

//   Future<void> clearUserSession() async {
//     final SharedPreferences prefs = await SharedPreferences.getInstance();
//     await prefs.remove('userUid');
//   }
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import 'package:ooriba_s3/HR/hr_dashboard_page.dart';
// import 'package:ooriba_s3/main.dart';
// import 'package:ooriba_s3/post_login_page.dart';
// import 'package:ooriba_s3/siteManager/siteManagerDashboard.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// class AuthService {
//   Future<bool> signin({
//     required String identifier,
//     required String password,
//     required BuildContext context,
//   }) async {
//     String? email;

//     try {
//       // Determine if the identifier is an email or phone number
//       if (isEmail(identifier)) {
//         email = identifier;
//       } else if (isPhoneNumber(identifier)) {
//         email = await getEmailFromPhoneNumber(identifier);
//         if (email == null) {
//           Fluttertoast.showToast(
//             msg: 'No user found for that phone numberxx. $identifier',
//             toastLength: Toast.LENGTH_LONG,
//             gravity: ToastGravity.SNACKBAR,
//             backgroundColor: Colors.black54,
//             textColor: Colors.white,
//             fontSize: 14.0,
//           );
//           return false;
//         }
//       } else {
//         Fluttertoast.showToast(
//           msg: 'Invalid email or phone number format.',
//           toastLength: Toast.LENGTH_LONG,
//           gravity: ToastGravity.SNACKBAR,
//           backgroundColor: Colors.black54,
//           textColor: Colors.white,
//           fontSize: 14.0,
//         );
//         return false;
//       }

//       // Fetch the document from the Firestore collection "Regemp"
//       // DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
//       //     await FirebaseFirestore.instance
//       //         .collection('Regemp')
//       //         .doc(email)
//       //         .get();
//       final FirebaseFirestore _db = FirebaseFirestore.instance;

//       QuerySnapshot snapshot = (await _db
//           .collection('Regemp')
//           .where('email', isEqualTo: email).limit(1)
//           .get());
//       // Check if the document exists
//       if (!snapshot.docs.isNotEmpty) {
//         Fluttertoast.showToast(
//           msg: 'No user found for that email in database. $email',
//           toastLength: Toast.LENGTH_LONG,
//           gravity: ToastGravity.SNACKBAR,
//           backgroundColor: Colors.black54,
//           textColor: Colors.white,
//           fontSize: 14.0,
//         );
//         return false;
//       }
//       else{

//       }

//       // Retrieve the role from the document
//       String role = Snapshot.data()?['role'] ?? '';
//       String emai = documentSnapshot.data()?['email'] ?? '';
//       String pass = documentSnapshot.data()?['password'] ?? '';
//       if (emai == null && emai != "null") {
//         // Sign in with Firebase Authentication
//         await FirebaseAuth.instance.signInWithEmailAndPassword(
//           email: email!,
//           password: password,
//         );
//       } else {
//         if (pass != password) {
//           Fluttertoast.showToast(
//             msg: 'Incorrect Password',
//             toastLength: Toast.LENGTH_LONG,
//             gravity: ToastGravity.SNACKBAR,
//             backgroundColor: Colors.black54,
//             textColor: Colors.white,
//             fontSize: 14.0,
//           );

//           return false;
//         }
//         ;
//       }

//       await saveUserSession(email, role);

//       // Navigate to the appropriate page based on the role
//       await Future.delayed(const Duration(seconds: 1));
//       if (role == "Standard") {
//         // String firstName = documentSnapshot.data()?['firstName'] ?? '';
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(
//             builder: (BuildContext context) =>
//                 PostLoginPage(phoneNumber: email!, userDetails: {}),
//           ),
//         );
//         return true;
//       } else if (role == "HR") {
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(
//             builder: (BuildContext context) => const HRDashboardPage(),
//           ),
//         );
//         return true;
//       } else if (role == "SiteManager") {
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(
//             builder: (BuildContext context) =>
//                 Sitemanagerdashboard(phoneNumber: email!, userDetails: {}),
//           ),
//         );
//         return true;
//       } else {
//         Fluttertoast.showToast(
//           msg: 'Invalid role assigned to the user.',
//           toastLength: Toast.LENGTH_LONG,
//           gravity: ToastGravity.SNACKBAR,
//           backgroundColor: Colors.black54,
//           textColor: Colors.white,
//           fontSize: 14.0,
//         );
//         return false;
//       }
//     } on FirebaseAuthException catch (e) {
//       String message = '';
//       if (e.code == 'invalid-email') {
//         message = 'No user found for that email. Firebase';
//       } else if (e.code == 'invalid-credential') {
//         message = 'Wrong password provided for that user.';
//       }
//       Fluttertoast.showToast(
//         msg: message,
//         toastLength: Toast.LENGTH_LONG,
//         gravity: ToastGravity.SNACKBAR,
//         backgroundColor: Colors.black54,
//         textColor: Colors.white,
//         fontSize: 14.0,
//       );
//       return false;
//     }
//   }

//   Future<void> signout({
//     required BuildContext context,
//   }) async {
//     await FirebaseAuth.instance.signOut();
//     await clearUserSession();
//     Navigator.pushAndRemoveUntil(
//         context,
//         MaterialPageRoute(
//           builder: (BuildContext context) => LoginPage(),
//         ),
//         (Route<dynamic> route) => false);
//   }
//   //   Future<void> signout({
//   //   required BuildContext context,
//   // }) async {
//   //   await FirebaseAuth.instance.signOut();
//   //   await Future.delayed(const Duration(seconds: 1));
//   //   Navigator.pushReplacement(
//   //     context,
//   //     MaterialPageRoute(
//   //       builder: (BuildContext context) => LoginPage(),
//   //     ),
//   //   );
//   // }

//   Future<String?> getUserSession() async {
//     final SharedPreferences prefs = await SharedPreferences.getInstance();
//     return prefs.getString('email');
//   }

//   Future<String?> getUserRole() async {
//     final SharedPreferences prefs = await SharedPreferences.getInstance();
//     return prefs.getString('role');
//   }

//   Future<void> saveUserSession(String email, String role) async {
//     final SharedPreferences prefs = await SharedPreferences.getInstance();
//     await prefs.setString('email', email);
//     await prefs.setString('role', role);
//   }

//   Future<void> clearUserSession() async {
//     final SharedPreferences prefs = await SharedPreferences.getInstance();
//     await prefs.remove('email');
//     await prefs.remove('role');
//   }

//   bool isEmail(String input) {
//     // Simple regex to check if the input is an email
//     final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
//     return emailRegex.hasMatch(input);
//   }

//   bool isPhoneNumber(String input) {
//     // Simple regex to check if the input is a phone number
//     final phoneRegex = RegExp(r'^\d{10}$');
//     return phoneRegex.hasMatch(input);
//   }

//   Future<String?> getEmailFromPhoneNumber(String phoneNumber) async {
//     // Query Firestore to get the email associated with the phone number
//     QuerySnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
//         .instance
//         .collection('Regemp')
//         .where('phoneNo', isEqualTo: phoneNumber)
//         .limit(1)
//         .get();

//     if (snapshot.docs.isEmpty) {
//       return null;
//     }

//     return snapshot.docs.first.id;
//   }
// }
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:ooriba/Admin/admin_dashboard_page.dart';
import 'package:ooriba/HR/hr_dashboard_page.dart';
import 'package:ooriba/main.dart';
import 'package:ooriba/post_login_page.dart';
import 'package:ooriba/siteManager/siteManagerDashboard.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  Future<bool> signin({
    required String identifier,
    required String password,
    required BuildContext context,
  }) async {
    try {
      if (identifier == "admin@gmail.com" && password == "Admin@1") {
        await saveUserSession(identifier, "Admin");
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (BuildContext context) => AdminDashboardPage(),
          ),
        );
        return true;
      }
      if (isEmail(identifier)) {
        // Sign in using Firebase Authentication
        return await signInWithEmail(identifier, password, context);
      } else if (isPhoneNumber(identifier)) {
        // Check if there is an email associated with the phone number
        print(
            "..........via email..................Sign in using Firebase Authentication.......................");

        String? email = await getEmailFromPhoneNumber(identifier);
        if (email != null) {
          // Sign in using Firebase Authentication
          print(
              "..........number has email..................Sign in using Firebase Authentication.......................");
          return await signInWithEmail(email, password, context);
        } else {
          // Check the Firestore for the phone number
          print("............................signing with phone number");
          return await handlePhoneNumberLogin(identifier, password, context);
        }
      } else {
        Fluttertoast.showToast(
          msg: 'Invalid email or phone number format.',
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.SNACKBAR,
          backgroundColor: Colors.black54,
          textColor: Colors.white,
          fontSize: 14.0,
        );
        return false;
      }
    } on FirebaseAuthException catch (e) {
      String message = 'Authentication error: ${e.message}';
      Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.SNACKBAR,
        backgroundColor: Colors.black54,
        textColor: Colors.white,
        fontSize: 14.0,
      );
      return false;
    }
  }

  Future<bool> signInWithEmail(
      String email, String password, BuildContext context) async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Fetch the user's role from Firestore based on phone number
      final QuerySnapshot<Map<String, dynamic>> snapshot =
          await FirebaseFirestore.instance
              .collection('Regemp')
              .where('email', isEqualTo: email)
              .limit(1)
              .get();

      if (snapshot.docs.isEmpty) {
        Fluttertoast.showToast(
          msg: 'No user found for that email in the database. $email',
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.SNACKBAR,
          backgroundColor: Colors.black54,
          textColor: Colors.white,
          fontSize: 14.0,
        );
        return false;
      }

      final userDoc = snapshot.docs.first;
      String role = userDoc.data()['role'] ?? '';
      await saveUserSession(email, role);

      // Navigate to the appropriate page based on the role
      return await navigateBasedOnRole(context, role, email);
    } on FirebaseAuthException catch (e) {
      String message = 'Please verify the credentials';
      Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.SNACKBAR,
        backgroundColor: Colors.black54,
        textColor: Colors.white,
        fontSize: 14.0,
      );
      return false;
    }
  }

  Future<bool> handlePhoneNumberLogin(
      String phoneNumber, String password, BuildContext context) async {
    // Query Firestore to get the employee details associated with the phone number
    final DocumentSnapshot<Map<String, dynamic>> userDoc =
        await FirebaseFirestore.instance
            .collection('Regemp')
            .doc(phoneNumber)
            .get();

    if (!userDoc.exists) {
      Fluttertoast.showToast(
        msg: 'No user found for that phone number.',
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.SNACKBAR,
        backgroundColor: Colors.black54,
        textColor: Colors.white,
        fontSize: 14.0,
      );
      return false;
    }

    String storedPassword = userDoc.data()?['password'] ?? '';
    String role = userDoc.data()?['role'] ?? '';
    String email = userDoc.data()?['email'] ?? userDoc.data()?['phoneNo'];

    if (storedPassword == password) {
      await saveUserSession(email, role);

      // Navigate to the appropriate page based on the role
      return await navigateBasedOnRole(context, role, email);
    } else {
      Fluttertoast.showToast(
        msg: 'Incorrect password.',
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.SNACKBAR,
        backgroundColor: Colors.black54,
        textColor: Colors.white,
        fontSize: 14.0,
      );
      return false;
    }
  }

  Future<bool> navigateBasedOnRole(
      BuildContext context, String role, String email) async {
    await Future.delayed(const Duration(seconds: 1));
    if (role == "Standard") {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (BuildContext context) =>
              PostLoginPage(phoneNumber: email, userDetails: {}),
        ),
      );
      return true;
    } else if (role == "HR") {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (BuildContext context) => const HRDashboardPage(),
        ),
      );
      return true;
    } else if (role == "Admin") {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (BuildContext context) => const AdminDashboardPage(),
        ),
      );
      return true;
    } else if (role == "SiteManager") {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (BuildContext context) =>
              Sitemanagerdashboard(phoneNumber: email, userDetails: {}),
        ),
      );
      return true;
    } else {
      Fluttertoast.showToast(
        msg: 'Invalid role assigned to the user.',
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.SNACKBAR,
        backgroundColor: Colors.black54,
        textColor: Colors.white,
        fontSize: 14.0,
      );
      return false;
    }
  }

  Future<void> signout({
    required BuildContext context,
  }) async {
    await FirebaseAuth.instance.signOut();
    await clearUserSession();
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (BuildContext context) => LoginPage(),
        ),
        (Route<dynamic> route) => false);
  }

  Future<String?> getUserSession() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('email');
  }

  Future<String?> getUserRole() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('role');
  }

  Future<void> saveUserSession(String email, String role) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('email', email);
    await prefs.setString('role', role);
  }

  Future<void> clearUserSession() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('email');
    await prefs.remove('role');
  }

  bool isEmail(String input) {
    // Simple regex to check if the input is an email
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    return emailRegex.hasMatch(input);
  }

  bool isPhoneNumber(String input) {
    // Simple regex to check if the input is a phone number
    final phoneRegex = RegExp(r'^\d{10}$');
    return phoneRegex.hasMatch(input);
  }

  Future<String?> getEmailFromPhoneNumber(String phoneNumber) async {
    // Query Firestore to get the email associated with the phone number
    final DocumentSnapshot<Map<String, dynamic>> userDoc =
        await FirebaseFirestore.instance
            .collection('Regemp')
            .doc(phoneNumber)
            .get();

    if (!userDoc.exists) {
      return null;
    }

    return userDoc.data()?['email'];
  }
}
