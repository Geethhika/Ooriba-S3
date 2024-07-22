import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ForgetPassService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> sendPasswordResetEmail(
      String email, BuildContext context) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Password reset email sent'),
          backgroundColor: Colors.green,
        ),
      );
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'invalid-email':
          message = 'The email address is not valid.';
          break;
        case 'user-not-found':
          message = 'There is no user corresponding to this email.';
          break;
        default:
          message = 'An error occurred, please try again.';
          break;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
