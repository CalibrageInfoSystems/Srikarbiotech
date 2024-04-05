// import 'package:awesome_notifications/awesome_notifications.dart';

// class NotificationController {

//   @pragma("vm:entry-point")
//   static Future<void> onNotificationCreatedMethod(ReceivedNotification receivedNotification) async {}

//   @pragma("vm:entry-point")
//   static Future<void> onNotificationDisplayMethod(ReceivedNotification receivedNotification) async {}

//   @pragma("vm:entry-point")
//   static Future<void> onDismissActionReceivedMethod(ReceivedAction receivedAction) async {}

//   @pragma("vm:entry-point")
//   static Future<void> onActionReceivedMethod(ReceivedAction receivedAction) async {}
// }

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:share_plus/share_plus.dart';

class NotificationController {
  @pragma("vm:entry-point")
  static Future<void> onNotificationCreatedMethod(
      ReceivedNotification receivedNotification) async {}

  @pragma("vm:entry-point")
  static Future<void> onNotificationDisplayedMethod(
      ReceivedNotification receivedNotification) async {}

  @pragma("vm:entry-point")
  static Future<void> onDismissActionReceivedMethod(
      ReceivedAction receivedAction) async {}

  @pragma("vm:entry-point")
  static Future<void> onActionReceivedMethod(
      ReceivedAction receivedAction) async {
    await Share.share('This is sample text!', subject: 'Title test');
  }
}
