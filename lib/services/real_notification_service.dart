// // services/real_notification_service.dart
// import 'dart:async';
// // services/real_notification_service.dart
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// class RealNotificationService {
//   static final RealNotificationService _instance = RealNotificationService._internal();
//   factory RealNotificationService() => _instance;
//   RealNotificationService._internal();

//   static final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();

//   Future<void> initialize() async {
//     const AndroidInitializationSettings androidSettings =
//         AndroidInitializationSettings('@mipmap/ic_launcher');

//     const DarwinInitializationSettings iosSettings =
//         DarwinInitializationSettings(
//       requestAlertPermission: true,
//       requestBadgePermission: true,
//       requestSoundPermission: true,
//     );

//     const InitializationSettings settings = InitializationSettings(
//       android: androidSettings,
//       iOS: iosSettings,
//     );

//     await _notifications.initialize(settings);

//     // Request permission untuk Android 13+
//     await _requestPermissions();
//   }

//   Future<void> _requestPermissions() async {
//     final bool? result = await _notifications.resolvePlatformSpecificImplementation<
//         AndroidFlutterLocalNotificationsPlugin>()?.requestPermission();
//     print('Notification permission granted: $result');
//   }

//   Future<void> showTimerNotification({
//     required String title,
//     required String body,
//   }) async {
//     const AndroidNotificationDetails androidDetails =
//         AndroidNotificationDetails(
//       'timer_channel',
//       'Timer Masak',
//       channelDescription: 'Notifikasi untuk timer memasak gula aren',
//       importance: Importance.high,
//       priority: Priority.high,
//       ongoing: true,
//       autoCancel: false,
//       showWhen: false,
//       visibility: NotificationVisibility.public,
//       playSound: false,
//     );

//     const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
//       threadIdentifier: 'timer_channel',
//     );

//     const NotificationDetails details = NotificationDetails(
//       android: androidDetails,
//       iOS: iosDetails,
//     );

//     await _notifications.show(
//       1,
//       title,
//       body,
//       details,
//     );
//   }

//   Future<void> updateTimerNotification({
//     required String title,
//     required String body,
//   }) async {
//     const AndroidNotificationDetails androidDetails =
//         AndroidNotificationDetails(
//       'timer_channel',
//       'Timer Masak',
//       channelDescription: 'Notifikasi untuk timer memasak gula aren',
//       importance: Importance.high,
//       priority: Priority.high,
//       ongoing: true,
//       autoCancel: false,
//       showWhen: false,
//       visibility: NotificationVisibility.public,
//       playSound: false,
//     );

//     const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
//       threadIdentifier: 'timer_channel',
//     );

//     const NotificationDetails details = NotificationDetails(
//       android: androidDetails,
//       iOS: iosDetails,
//     );

//     await _notifications.show(
//       1,
//       title,
//       body,
//       details,
//     );
//   }

//   Future<void> showFinishedNotification({
//     required String title,
//     required String body,
//   }) async {
//     const AndroidNotificationDetails androidDetails =
//         AndroidNotificationDetails(
//       'timer_channel',
//       'Timer Masak',
//       channelDescription: 'Notifikasi untuk timer memasak gula aren',
//       importance: Importance.high,
//       priority: Priority.high,
//       ongoing: false,
//       autoCancel: true,
//       showWhen: true,
//       visibility: NotificationVisibility.public,
//       playSound: true,
//     );

//     const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
//       threadIdentifier: 'timer_channel',
//     );

//     const NotificationDetails details = NotificationDetails(
//       android: androidDetails,
//       iOS: iosDetails,
//     );

//     await _notifications.show(
//       2,
//       title,
//       body,
//       details,
//     );
//   }

//   Future<void> cancelTimerNotification() async {
//     await _notifications.cancel(1);
//   }

//   Future<void> cancelAllNotifications() async {
//     await _notifications.cancelAll();
//   }
// }