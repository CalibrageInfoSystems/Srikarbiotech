import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:location/location.dart';

typedef OnComplete = void Function(bool success, dynamic result, String? msg);


class LocationUpdatesService {
  static const String LOG_TAG = "MyService";
  late Location location;
  LocationData? currentLocation;
   double MINIMUM_MOVEMENT_SPEED = 0.2; // in meters/second
   double MAX_ACCURACY_THRESHOLD = 10; // in meters

  late StreamSubscription<LocationData> _locationSubscription;

  LocationUpdatesService() {
    location = Location();
    location.changeSettings(accuracy: LocationAccuracy.high);
  }

  Future<void> startLocationService(OnComplete onComplete) async {
    try {
      bool _serviceEnabled = await location.serviceEnabled();
      if (!_serviceEnabled) {
        _serviceEnabled = await location.requestService();
        if (!_serviceEnabled) {
          return;
        }
      }

      PermissionStatus _permissionGranted = await location.hasPermission();
      if (_permissionGranted == PermissionStatus.denied) {
        _permissionGranted = await location.requestPermission();
        if (_permissionGranted != PermissionStatus.granted) {
          return;
        }
      }

      _locationSubscription = location.onLocationChanged.listen((LocationData locationData) {
        onLocationChanged(locationData);
      });

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

  void onLocationChanged(LocationData locationData) {
    if (currentLocation != null) {
      double distance = calculateDistance(
        currentLocation!.latitude!,
        currentLocation!.longitude!,
        locationData.latitude!,
        locationData.longitude!,
      );

      if (locationData.speed != null &&
          locationData.speed! >= MINIMUM_MOVEMENT_SPEED &&
          locationData.accuracy! <= MAX_ACCURACY_THRESHOLD &&
          distance >= 50) {
        currentLocation = locationData;
        double latitude = currentLocation!.latitude!;
        double longitude = currentLocation!.longitude!;
        print("Latitude: $latitude, Longitude: $longitude, Distance: $distance meters");
        appendLog("Latitude: $latitude, Longitude: $longitude, Distance: $distance meters");
      }
    } else {
      // For the first location update, always append the log
      currentLocation = locationData;
      double latitude = currentLocation!.latitude!;
      double longitude = currentLocation!.longitude!;
      print("Latitude: $latitude, Longitude: $longitude");
      appendLog("Latitude: $latitude, Longitude: $longitude");
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

  void dispose() {
    _locationSubscription.cancel();
  }
}



