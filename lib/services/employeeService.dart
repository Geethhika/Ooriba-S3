import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:ooriba/employee_signup_success.dart';

class EmployeeService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<void> addEmployee(
      String firstName,
      String middleName,
      String lastName,
      String? email,
      String password,
      String? panNo,
      String resAdd,
      String perAdd,
      String phoneNumber,
      String dob,
      String aadharNo,
      File? dpImage,
      File? adhaarImage,
      File? supportImage,
      {required BuildContext context}) async {
    try {
      // Prepare employee data
      final employeeData = {
        'firstName': firstName,
        'middleName': middleName,
        'lastName': lastName,
        'email': email,
        'password': password, // Add password field
        'panNo': panNo?.toUpperCase(),
        'residentialAddress': resAdd,
        'permanentAddress': perAdd,
        'phoneNo': phoneNumber,
        'dob': dob,
        'aadharNo': aadharNo.replaceAll(' ', ''),
        'timestamp': FieldValue.serverTimestamp(),
      };

      // Upload images to Firebase Storage if they are provided
      if (dpImage != null) {
        String dpImageUrl =
            await _uploadImage(dpImage, 'profile_pictures/$phoneNumber');
        employeeData['dpImageUrl'] = dpImageUrl;
      }
      if (adhaarImage != null) {
        String adhaarImageUrl =
            await _uploadImage(adhaarImage, 'aadhaar_cards/$phoneNumber');
        employeeData['adhaarImageUrl'] = adhaarImageUrl;
      }
      if (supportImage != null) {
        String supportImageUrl = await _uploadImage(
            supportImage, 'supporting_documents/$phoneNumber');
        employeeData['supportImageUrl'] = supportImageUrl;
      }

      // Save employee data to Firestore with phone number as document ID
      await _db
          .collection('Employee')
          .doc(phoneNumber)
          .set(employeeData, SetOptions(merge: true));

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Signed up successfully')),
      );
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => ConfirmationPage()));
    } catch (e) {
      print('Error saving employee data: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to sign up: $e')),
      );
      throw e;
    }
  }

  Future<String> _uploadImage(File image, String path) async {
    final ref = _storage.ref().child(path);
    await ref.putFile(image);
    return await ref.getDownloadURL();
  }

  Future<void> updateEmployee({
    required String phoneNumber,
    String? firstName,
    String? middleName,
    String? lastName,
    String? password,
    String? panNo,
    String? resAdd,
    String? perAdd,
    String? dob,
    File? dpImage,
    File? adhaarImage,
    File? supportImage,
    required BuildContext context,
  }) async {
    try {
      // Prepare data map to update only provided fields
      final Map<String, dynamic> dataToUpdate = {};

      if (firstName != null) dataToUpdate['firstName'] = firstName;
      if (middleName != null) dataToUpdate['middleName'] = middleName;
      if (lastName != null) dataToUpdate['lastName'] = lastName;
      if (password != null)
        dataToUpdate['password'] = password; // Update password field
      dataToUpdate['phoneNumber'] = phoneNumber;
      if (panNo != null) dataToUpdate['panNo'] = panNo.toUpperCase();
      if (resAdd != null) dataToUpdate['residentialAddress'] = resAdd;
      if (perAdd != null) dataToUpdate['permanentAddress'] = perAdd;
      if (dob != null) dataToUpdate['dob'] = dob;

      if (dpImage != null) {
        String dpImageUrl =
            await _uploadImage(dpImage, 'profile_pictures/$phoneNumber');
        dataToUpdate['dpImageUrl'] = dpImageUrl;
      }

      if (adhaarImage != null) {
        String adhaarImageUrl =
            await _uploadImage(adhaarImage, 'aadhaar_cards/$phoneNumber');
        dataToUpdate['adhaarImageUrl'] = adhaarImageUrl;
      }

      if (supportImage != null) {
        String supportImageUrl = await _uploadImage(
            supportImage, 'supporting_documents/$phoneNumber');
        dataToUpdate['supportImageUrl'] = supportImageUrl;
      }

      // Update employee data in Firestore
      await _db.collection('Employee').doc(phoneNumber).update(dataToUpdate);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Employee data updated successfully')),
      );
    } catch (e) {
      print('Error updating employee data: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update data: $e')),
      );
      throw e;
    }
  }
}
