// import 'package:flutter/material.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import 'package:geocoding/geocoding.dart';
// import 'package:geolocator/geolocator.dart';
// class Geolocation extends StatefulWidget {
//   @override
//   _HomeState createState() => _HomeState();
// }

// class _HomeState extends State<Geolocation> {
//   String currentAddress = 'My Address';
//   Position? currentPosition;
//   double? currentAccuracy;
//   double? distanceToLandmark;

//   // Set a fixed landmark position (update with your desired coordinates)
//   // 16.487026724481314, 80.5028066313203
//   final double landmarkLatitude = 106.487026724481314;  // landmark latitude
//   final double landmarkLongitude = 800.5028066313203;  // landmark longitude

//   Future<Position> _determinePosition() async {
//     bool serviceEnabled;
//     LocationPermission permission;

//     // Test if location services are enabled.
//     serviceEnabled = await Geolocator.isLocationServiceEnabled();
//     if (!serviceEnabled) {
//       Fluttertoast.showToast(msg: 'Please enable Your Location Service');
//       throw Exception('Location services are disabled.');
//     }

//     permission = await Geolocator.checkPermission();
//     if (permission == LocationPermission.denied) {
//       permission = await Geolocator.requestPermission();
//       if (permission == LocationPermission.denied) {
//         Fluttertoast.showToast(msg: 'Location permissions are denied');
//         throw Exception('Location permissions are denied');
//       }
//     }

//     if (permission == LocationPermission.deniedForever) {
//       Fluttertoast.showToast(
//           msg:
//               'Location permissions are permanently denied, we cannot request permissions.');
//       throw Exception('Location permissions are permanently denied.');
//     }

//     // When we reach here, permissions are granted and we can access the position
//     return await Geolocator.getCurrentPosition(
//         desiredAccuracy: LocationAccuracy.bestForNavigation);
//   }

//   void _getAddressFromLatLng(Position position) async {
//     try {
//       List<Placemark> placemarks =
//           await placemarkFromCoordinates(position.latitude, position.longitude);

//       Placemark place = placemarks[0];

//       setState(() {
//         currentPosition = position;
//         currentAccuracy = position.accuracy;
//         currentAddress =
//             "${place.street}, ${place.locality}, ${place.postalCode}, ${place.country}";
//         distanceToLandmark = Geolocator.distanceBetween(
//           position.latitude, position.longitude, landmarkLatitude, landmarkLongitude);
        
//         // Check if within 50 meters radius
//         if (distanceToLandmark! <= 50) {
//           Fluttertoast.showToast(msg: "You're in 50m radius of the location");
//         } else {
//           Fluttertoast.showToast(msg: "You're not in 50m radius from location");
//         }
//       });
//     } catch (e) {
//       print(e);
//     }
//   }

//   void _locateMe() async {
//     try {
//       Position position = await _determinePosition();
//       _getAddressFromLatLng(position);
//     } catch (e) {
//       print(e);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('My Location'),
//       ),
//       body: Center(
//           child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Text(currentAddress),
//           currentPosition != null
//               ? Text('Latitude = ' + currentPosition!.latitude.toString())
//               : Container(),
//           currentPosition != null
//               ? Text('Longitude = ' + currentPosition!.longitude.toString())
//               : Container(),
//           currentPosition != null
//               ? Text('Accuracy = ' + currentAccuracy!.toString() + ' meters')
//               : Container(),
//           distanceToLandmark != null
//               ? Text('Distance to Landmark = ' + distanceToLandmark!.toStringAsFixed(2) + ' meters')
//               : Container(),
//           TextButton(
//               onPressed: _locateMe,
//               child: Text('My Location'))
//         ],
//       )),
//     );
//   }
// }