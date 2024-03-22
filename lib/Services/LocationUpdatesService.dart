import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:location/location.dart';

typedef OnComplete = void Function(bool success, dynamic result, String? msg);

class LocationUpdatesService {
  static const String LOG_TAG = "MyService";
  late Timer _timer;
  Location location = Location();
  LocationData? currentLocation;
  double latitude = 0.0;
  double longitude = 0.0;
  late StreamSubscription<LocationData> _locationSubscription;

  late bool _serviceEnabled;
  late PermissionStatus _permissionGranted;

  FalogService() {
    _serviceEnabled = false;
    _permissionGranted = PermissionStatus.denied;
    location.changeSettings(accuracy: LocationAccuracy.high);
  }

  Future<void> startLocationService(OnComplete onComplete) async {
    try {
      _serviceEnabled = await location.serviceEnabled();
      if (!_serviceEnabled) {
        _serviceEnabled = await location.requestService();
        if (!_serviceEnabled) {
          return;
        }
      }

      _permissionGranted = await location.hasPermission();
      if (_permissionGranted == PermissionStatus.denied) {
        _permissionGranted = await location.requestPermission();
        if (_permissionGranted != PermissionStatus.granted) {
          return;
        }
      }

      _locationSubscription = location.onLocationChanged.listen((LocationData locationData) {
        onLocationChanged(locationData);
      });

      await requestLocationUpdates(LocationAccuracy.high, 0, 10);
      await requestLocationUpdates(LocationAccuracy.low, 0, 10);

      if (onComplete != null) {
        onComplete(true, null, "Location service started");
      }
    } catch (e) {
      print("Error starting location service: $e");
      if (onComplete != null) {
        onComplete(false, null, "Error starting location service: $e");
      }
    }
  }

  Future<void> requestLocationUpdates(LocationAccuracy accuracy, int interval, double distance) async {
    try {
      await location.changeSettings(interval: interval, distanceFilter: distance, accuracy: accuracy);
    } catch (e) {
      print("Error requesting location updates: $e");
    }
  }

  void appendLog(String text) {
    final String folderName = 'Srikar_Groups';
    final String fileName = 'Usertrackinglog.file';

    Directory appFolderPath = Directory('/storage/emulated/0/Download/$folderName');
    if (!appFolderPath.existsSync()) {
      appFolderPath.createSync(recursive: true);
    }

    final logFile = File('${appFolderPath.path}/$fileName');
    if (!logFile.existsSync()) {
      logFile.createSync();
    }

    try {
      final buf = logFile.openWrite(mode: FileMode.append);
      buf.writeln(text);
      buf.close();
    } catch (e) {
      print("Error appending to log file: $e");
    }
  }
  void onLocationChanged(LocationData locationData) {
    if (currentLocation != null) {
      double distance = calculateDistance(
          currentLocation!.latitude!,
          currentLocation!.longitude!,
          locationData.latitude!,
          locationData.longitude!);
      print(" Distance: $distance meters");
      appendLog(" Distance: $distance meters");
      // Check if the distance is greater than or equal to 200 meters
      if (distance >= 200) {
        // Update the current location
        currentLocation = locationData;
        latitude = currentLocation!.latitude!;
        longitude = currentLocation!.longitude!;
        print("Latitude: $latitude, Longitude: $longitude, Distance: $distance meters");
        appendLog("Latitude: $latitude, Longitude: $longitude, Distance: $distance meters");
      }
    } else {
      // For the first location update, always append the log
      currentLocation = locationData;
      latitude = currentLocation!.latitude!;
      longitude = currentLocation!.longitude!;
      print("latitude: $latitude, longitude: $longitude");
      appendLog("Latitude: $latitude, Longitude: $longitude");

      // Start a timer to save the location every 1 minute
      _timer = Timer.periodic(Duration(minutes: 1), (timer) {
        // Save the latitude and longitude to the log
        appendLog("Latitude: $latitude, Longitude: $longitude");
      });
    }
  }
  // void onLocationChanged(LocationData locationData) {
  //   if (currentLocation != null) {
  //     double distance = calculateDistance(
  //         currentLocation!.latitude!,
  //         currentLocation!.longitude!,
  //         locationData.latitude!,
  //         locationData.longitude!);
  //
  //     if (distance >= 200) {
  //       currentLocation = locationData;
  //       latitude = currentLocation!.latitude!;
  //       longitude = currentLocation!.longitude!;
  //       print("Latitude: $latitude, Longitude: $longitude, Distance: $distance meters");
  //       appendLog("Latitude: $latitude, Longitude: $longitude, Distance: $distance meters");
  //     }
  //   } else {
  //     // For the first location update, always append the log
  //     currentLocation = locationData;
  //     latitude = currentLocation!.latitude!;
  //     longitude = currentLocation!.longitude!;
  //     print("latitude: $latitude, longitude: $longitude");
  //     appendLog("Latitude: $latitude, Longitude: $longitude");
  //   }
  // }
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


  void dispose() {
    _locationSubscription.cancel();
  }
}
