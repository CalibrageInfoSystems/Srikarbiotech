import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:location/location.dart' as loc;
import 'package:geocoding/geocoding.dart';
import 'package:shared_preferences/shared_preferences.dart';
class LocationUpdatesService extends StatefulWidget {
  @override
  _LocationUpdatesServiceState createState() => _LocationUpdatesServiceState();


}

class _LocationUpdatesServiceState extends State<LocationUpdatesService> {
  loc.Location location = loc.Location();
  loc.LocationData? currentLocation;
  StreamSubscription<loc.LocationData>? locationStreamSubscription;

  @override
  void initState() {
    super.initState();
    requestLocationUpdates(); // Call the method to start location updates when the widget initializes
    locationStreamSubscription = location.onLocationChanged.listen((loc.LocationData newLocation) {
      setState(() {
        currentLocation = newLocation;
        onNewLocation(currentLocation!);
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    locationStreamSubscription?.cancel();
  }

  void requestLocationUpdates() {
    location.requestPermission().then((granted) {
      if (granted != loc.PermissionStatus.granted) {
        return;
      }
      location.changeSettings(
        accuracy: loc.LocationAccuracy.high,
        interval: 1000,
        distanceFilter: 0,
      );
    });
  }

  // Future<void> onNewLocation(loc.LocationData locationData) async {
  //   String address = await getAddress(locationData.latitude!, locationData.longitude!);
  //
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   prefs.setDouble('latitude', locationData.latitude!);
  //   prefs.setDouble('longitude', locationData.longitude!);
  //   prefs.setString('address', address);
  //
  //   double savedLatitude = prefs.getDouble('latitude') ?? 0.0;
  //   double savedLongitude = prefs.getDouble('longitude') ?? 0.0;
  //   String savedAddress = prefs.getString('address') ?? '';
  //
  //   print('Saved Latitude: $savedLatitude');
  //   print('Saved Longitude: $savedLongitude');
  //   print('Saved Address: $savedAddress');
  // }

  Future<void> onNewLocation(loc.LocationData locationData) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Retrieve previous location details
    double? prevLatitude = prefs.getDouble('latitude');
    double? prevLongitude = prefs.getDouble('longitude');

    // Calculate distance between previous and current location
    double distance = calculateDistance(
      prevLatitude ?? locationData.latitude!,
      prevLongitude ?? locationData.longitude!,
      locationData.latitude!,
      locationData.longitude!,
    );

    print('Saved distance: ${distance}');
    // If distance exceeds 200 meters, save the location details
    if (distance >= 200) {
      String address = await getAddress(locationData.latitude!, locationData.longitude!);

      prefs.setDouble('latitude', locationData.latitude!);
      prefs.setDouble('longitude', locationData.longitude!);
      prefs.setString('address', address);

      print('Saved Latitude: ${locationData.latitude!}');
      print('Saved Longitude: ${locationData.longitude!}');
      print('Saved Address: $address');
    }
  }

// Function to calculate distance between two coordinates using Haversine formula
  double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const int radius = 6371; // Earth's radius in km

    double dLat = degreesToRadians(lat2 - lat1);
    double dLon = degreesToRadians(lon2 - lon1);

    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(degreesToRadians(lat1)) * cos(degreesToRadians(lat2)) * sin(dLon / 2) * sin(dLon / 2);

    double c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return radius * c * 1000; // Distance in meters
  }

// Function to convert degrees to radians
  double degreesToRadians(double degrees) {
    return degrees * pi / 180;
  }


  Future<String> getAddress(double latitude, double longitude) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(latitude, longitude);
      if (placemarks.isNotEmpty) {
        Placemark placemark = placemarks[0];
        String address = '${placemark.street}, ${placemark.locality}, ${placemark.administrativeArea}, ${placemark.country}';
        return address;
      }
    } catch (e) {
      print('Error getting address: $e');
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
