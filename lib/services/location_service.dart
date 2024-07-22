// import 'package:location/location.dart';

// class LocationService {
//   final Location _locationService = Location();

//   Future<LocationData> getCurrentLocation() async {
//     return await _locationService.getLocation();
//   }
// }
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';

class LocationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Fetch all location document IDs
  Future<List<String>> getAllLocations() async {
    try {
      QuerySnapshot querySnapshot =
          await _firestore.collection('Locations').get();
      List<String> locations = querySnapshot.docs.map((doc) => doc.id).toList();
      return locations;
    } catch (e) {
      print('Error fetching locations: $e');
      return [];
    }
  }

  // Fetch location details by prefix
  Future<Map<String, dynamic>> getLocationByPrefix(String prefix) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('Locations')
          .where('prefix', isEqualTo: prefix)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        // Assuming that the prefix is unique and there's only one matching document
        DocumentSnapshot documentSnapshot = querySnapshot.docs.first;
        return documentSnapshot.data() as Map<String, dynamic>;
      } else {
        print('No document found with prefix: $prefix');
        return {};
      }
    } catch (e) {
      print('Error retrieving document: $e');
      return {};
    }
  }

  Future<Position> determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    return await Geolocator.getCurrentPosition();
  }

  Future<bool> isWithinRadius(Position currentPosition, double restrictedRadius,
      GeoPoint locationCoordinates) async {
    double distance = Geolocator.distanceBetween(
      currentPosition.latitude,
      currentPosition.longitude,
      locationCoordinates.latitude,
      locationCoordinates.longitude,
    );

    return distance <= restrictedRadius;
  }
}
