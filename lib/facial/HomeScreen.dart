// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:ooriba_s3/facial/RecognitionScreen.dart';

// class HomeScreen extends StatefulWidget{
//   final String email;
//   const HomeScreen({Key? key, required this.email}) : super(key: key);

//   @override
//   State<HomeScreen> createState() => _HomePageState();

// }

// class _HomePageState extends State<HomeScreen> {
//   @override
//   Widget build(BuildContext context) {
//     double screenWidth = MediaQuery.of(context).size.width;
//     double screenHeight = MediaQuery.of(context).size.height;
//     return Scaffold(
//       body: Column(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Container(
//             margin: const EdgeInsets.only(top: 100),
//             child: Image.asset("assets/images/logo.png", width: screenWidth - 40, height: screenWidth - 40),
//           ),
//           Container(
//             margin: const EdgeInsets.only(bottom: 50),
//             child: Column(
//               children: [
//                 ElevatedButton(
//                   onPressed: () {
//                     Navigator.push(context, MaterialPageRoute(builder: (context) => RecognitionScreen(email: widget.email)));
//                     // Navigator.push(context, MaterialPageRoute(builder: (context) => RecognitionScreen(email:"vikasyadav177714@gmail.com")));
//                   },
//                   style: ElevatedButton.styleFrom(minimumSize: Size(screenWidth - 30, 50)),
//                   child: const Text("Recognize"),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
