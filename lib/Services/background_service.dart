// ignore_for_file: non_constant_identifier_names

import 'dart:io';
import 'dart:ui';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:geolocator/geolocator.dart';

const String notificationChannelId = "foreground_service";
const int foregroundServiceNotificationId = 888;
const String initialNotificationTitle = "TRACK YOUR LOCATION";
const String initialNotificationContent = "Initializing";

const int distanceThreshold = 50; // in meters
double MAX_ACCURACY_THRESHOLD = 20.0; // meters
double MAX_SPEED_ACCURACY_THRESHOLD = 5.0; // meters/second
double MIN_SPEED_THRESHOLD = 0.5; // meters/second

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  DartPluginRegistrant.ensureInitialized();

  if (service is AndroidServiceInstance) {
    service.on('setAsForeground').listen((event) async {
      await service.setAsForegroundService();
    });

    service.on('setAsBackground').listen((event) async {
      await service.setAsBackgroundService();
    });
  }

  service.on("stop_service").listen((event) async {
    await service.stopSelf();
  });

  double lastLatitude = 0.0;
  double lastLongitude = 0.0;

  Geolocator.getPositionStream().listen((Position position) async {
    final permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.always) {
      // final accuracy = position.accuracy;
      // final speedAccuracy = position.speedAccuracy;
      // final speed = position.speed;
      service.invoke('on_location_changed', position.toJson());
      print('Latitude: ${position.latitude}, Longitude: ${position.longitude}');
      print(
          'accuracy: ${position.accuracy}, speedAccuracy: ${position.speedAccuracy}.speed: ${position.speed}');

      if (position.accuracy <= MAX_ACCURACY_THRESHOLD &&
          position.speedAccuracy <= MAX_SPEED_ACCURACY_THRESHOLD &&
          position.speed >= MIN_SPEED_THRESHOLD) {
        // Your code here
        appendLog(
            'accuracy: ${position.accuracy}, speedAccuracy: ${position.speedAccuracy}.speed: ${position.speed}');

        final distance = Geolocator.distanceBetween(
          lastLatitude,
          lastLongitude,
          position.latitude,
          position.longitude,
        );

        print(
            'Latitude: ${position.latitude}, Longitude: ${position.longitude}.distance $distance');

        if (distance >= distanceThreshold) {
          print(
              'Latitude: ${position.latitude}, Longitude: ${position.longitude}');
          appendLog(
              'Latitude: ${position.latitude}, Longitude: ${position.longitude}.distance $distance');
          lastLatitude = position.latitude;
          lastLongitude = position.longitude;

          // final userName = await CustomSharedPreference().getData(
          //   key: SharedPreferenceKeys.userName,
          // );

          // Notification code can be included here if needed
        }
      }
    }
  });
}

// await NotificationService(FlutterLocalNotificationsPlugin())
//     .showNotification(
//   showNotificationId: foregroundServiceNotificationId,
//   title: "Hii, $userName",
//   body:
//   'Your Latitude: ${position.latitude}, Longitude: ${position.longitude}',
//   payload: "service",
//   androidNotificationDetails: const AndroidNotificationDetails(
//     notificationChannelId,
//     notificationChannelId,
//     ongoing: true,
//   ),
// );

void appendLog(String text) {
  const String folderName = 'Srikar_Groups';
  const String fileName = 'UsertrackinglogTest.file';

  Directory appFolderPath =
      Directory('/storage/emulated/0/Download/$folderName');
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

class BackgroundService {
  final FlutterBackgroundService flutterBackgroundService =
      FlutterBackgroundService();

  FlutterBackgroundService get instance => flutterBackgroundService;

  // Future<void> initializeService() async {
  //   await NotificationService(FlutterLocalNotificationsPlugin()).createChannel(
  //     const AndroidNotificationChannel(
  //       notificationChannelId,
  //       notificationChannelId,
  //     ),
  //   );
  //   await flutterBackgroundService.configure(
  //     androidConfiguration: AndroidConfiguration(
  //       onStart: onStart,
  //       autoStart: false,
  //       isForegroundMode: true,
  //       notificationChannelId: notificationChannelId,
  //       foregroundServiceNotificationId: foregroundServiceNotificationId,
  //       initialNotificationTitle: initialNotificationTitle,
  //       initialNotificationContent: initialNotificationContent,
  //     ),
  //     iosConfiguration: IosConfiguration(
  //       autoStart: true,
  //       onForeground: onStart,
  //     ),
  //   );
  //   await flutterBackgroundService.startService();
  // }

  void setServiceAsForeGround() async {
    flutterBackgroundService.invoke("setAsForeground");
  }

  void stopService() {
    flutterBackgroundService.invoke("stop_service");
  }

  initializeService() {}
}
