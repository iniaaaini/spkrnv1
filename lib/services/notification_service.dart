// // services/notification_service.dart
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// class NotificationService {
//   static final NotificationService _instance = NotificationService._internal();
//   factory NotificationService() => _instance;
//   NotificationService._internal();

//   late FlutterLocalNotificationsPlugin _notifications;
//   bool _isInitialized = false;

//   Future<void> initialize() async {
//     if (_isInitialized) return;

//     _notifications = FlutterLocalNotificationsPlugin();

//     // Setup channel untuk Android
//     const AndroidInitializationSettings androidSettings =
//         AndroidInitializationSettings('@mipmap/ic_launcher');

//     // Setup untuk iOS
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

//     // Buat notification channel untuk Android 8.0+
//     const AndroidNotificationChannel channel = AndroidNotificationChannel(
//       'timer_channel',
//       'Timer Masak SIPAKARENA',
//       description: 'Notifikasi untuk timer memasak gula aren',
//       importance: Importance.high,
//       playSound: false,
//       showBadge: true,
//     );

//     await _notifications
//         .resolvePlatformSpecificImplementation<
//             AndroidFlutterLocalNotificationsPlugin>()
//         ?.createNotificationChannel(channel);

//     _isInitialized = true;
//     print('✅ Notification Service Initialized');
//   }

//   Future<void> showTimerNotification({
//     required String title,
//     required String body,
//   }) async {
//     if (!_isInitialized) {
//       print('❌ Notification service not initialized');
//       return;
//     }

//     try {
//       const AndroidNotificationDetails androidDetails =
//           AndroidNotificationDetails(
//         'timer_channel',
//         'Timer Masak SIPAKARENA',
//         channelDescription: 'Notifikasi untuk timer memasak gula aren',
//         importance: Importance.high,
//         priority: Priority.high,
//         ongoing: true,
//         autoCancel: false,
//         showWhen: false,
//         visibility: NotificationVisibility.public,
//         playSound: false,
//         enableVibration: false,
//       );

//       const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
//         threadIdentifier: 'timer_channel',
//         presentAlert: true,
//         presentBadge: true,
//         presentSound: false,
//       );

//       const NotificationDetails details = NotificationDetails(
//         android: androidDetails,
//         iOS: iosDetails,
//       );

//       await _notifications.show(
//         1,
//         title,
//         body,
//         details,
//       );

//       print('🔔 NOTIFICATION SHOWN: $title - $body');
//     } catch (e) {
//       print('❌ Error showing notification: $e');
//     }
//   }

//   Future<void> updateTimerNotification({
//     required String title,
//     required String body,
//   }) async {
//     if (!_isInitialized) {
//       print('❌ Notification service not initialized');
//       return;
//     }

//     try {
//       const AndroidNotificationDetails androidDetails =
//           AndroidNotificationDetails(
//         'timer_channel',
//         'Timer Masak SIPAKARENA',
//         channelDescription: 'Notifikasi untuk timer memasak gula aren',
//         importance: Importance.high,
//         priority: Priority.high,
//         ongoing: true,
//         autoCancel: false,
//         showWhen: false,
//         visibility: NotificationVisibility.public,
//         playSound: false,
//         enableVibration: false,
//       );

//       const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
//         threadIdentifier: 'timer_channel',
//         presentAlert: true,
//         presentBadge: true,
//         presentSound: false,
//       );

//       const NotificationDetails details = NotificationDetails(
//         android: androidDetails,
//         iOS: iosDetails,
//       );

//       await _notifications.show(
//         1,
//         title,
//         body,
//         details,
//       );

//       print('🔔 NOTIFICATION UPDATED: $title - $body');
//     } catch (e) {
//       print('❌ Error updating notification: $e');
//     }
//   }

//   Future<void> showFinishedNotification({
//     required String title,
//     required String body,
//   }) async {
//     if (!_isInitialized) {
//       print('❌ Notification service not initialized');
//       return;
//     }

//     try {
//       const AndroidNotificationDetails androidDetails =
//           AndroidNotificationDetails(
//         'timer_channel',
//         'Timer Masak SIPAKARENA',
//         channelDescription: 'Notifikasi untuk timer memasak gula aren',
//         importance: Importance.high,
//         priority: Priority.high,
//         ongoing: false,
//         autoCancel: true,
//         showWhen: true,
//         visibility: NotificationVisibility.public,
//         playSound: true,
//         enableVibration: true,
//       );

//       const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
//         threadIdentifier: 'timer_channel',
//         presentAlert: true,
//         presentBadge: true,
//         presentSound: true,
//       );

//       const NotificationDetails details = NotificationDetails(
//         android: androidDetails,
//         iOS: iosDetails,
//       );

//       await _notifications.show(
//         2,
//         title,
//         body,
//         details,
//       );

//       print('🔔 FINISHED NOTIFICATION: $title - $body');
//     } catch (e) {
//       print('❌ Error showing finished notification: $e');
//     }
//   }

//   Future<void> cancelTimerNotification() async {
//     if (!_isInitialized) return;
    
//     try {
//       await _notifications.cancel(1);
//       print('🔔 NOTIFICATION CANCELLED');
//     } catch (e) {
//       print('❌ Error cancelling notification: $e');
//     }
//   }

//   Future<void> cancelAllNotifications() async {
//     if (!_isInitialized) return;
    
//     try {
//       await _notifications.cancelAll();
//       print('🔔 ALL NOTIFICATIONS CANCELLED');
//     } catch (e) {
//       print('❌ Error cancelling all notifications: $e');
//     }
//   }

//   Future<bool> requestPermissions() async {
//     if (!_isInitialized) return false;

//     try {
//       // Request permission untuk Android
//       final bool? androidResult = await _notifications
//           .resolvePlatformSpecificImplementation<
//               AndroidFlutterLocalNotificationsPlugin>()
//           ?.requestPermission();

//       // Request permission untuk iOS - gunakan method yang benar
//       final bool? iosResult = await _notifications
//           .resolvePlatformSpecificImplementation<
//               IOSFlutterLocalNotificationsPlugin>()
//           ?.requestPermissions(
//             alert: true,
//             badge: true,
//             sound: true,
//           );

//       return androidResult == true || iosResult == true;
//     } catch (e) {
//       print('❌ Error requesting permissions: $e');
//       return false;
//     }
//   }
// }