import 'package:ooriba/facial/RegistrationScreen.dart';
import 'package:ooriba/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // Import registration screen

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Hello👋',
                style: GoogleFonts.raleway(
                  textStyle: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Text(
                FirebaseAuth.instance.currentUser!.email!.toString(),
                style: GoogleFonts.raleway(
                  textStyle: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ),
              const SizedBox(
                height: 30,
              ),
              _logout(context),
              const SizedBox(
                height: 20,
              ),
              _navigateToRegistration(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _logout(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xff0D6EFD),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        minimumSize: const Size(double.infinity, 60),
        elevation: 0,
      ),
      onPressed: () async {
        await AuthService().signout(context: context);
      },
      child: const Text("Sign Out"),
    );
  }

  Widget _navigateToRegistration(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xff0D6EFD),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        minimumSize: const Size(double.infinity, 60),
        elevation: 0,
      ),
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const RegistrationScreen()),
        );
      },
      child: const Text("Go to Registration"),
    );
  }
}
