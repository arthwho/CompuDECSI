import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Initialize timezone
  static void initializeTimeZones() {
    tz.initializeTimeZones();
  }

  Future<void> initialize() async {
    // Request permission for iOS
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');
    } else {
      print('User declined or has not accepted permission');
    }

    // Request exact alarm permission for Android
    try {
      await _localNotifications
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.requestExactAlarmsPermission();
      print('Requested exact alarm permission');
    } catch (e) {
      print('Could not request exact alarm permission: $e');
    }

    // Initialize local notifications
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        );

    const InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsIOS,
        );

    await _localNotifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Handle background messages
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Handle notification taps when app is opened from notification
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);

    // Get FCM token
    String? token = await _firebaseMessaging.getToken();
    if (token != null) {
      await _saveFCMToken(token);
    }

    // Listen for token refresh
    _firebaseMessaging.onTokenRefresh.listen(_saveFCMToken);
  }

  Future<void> _saveFCMToken(String token) async {
    final user = _auth.currentUser;
    if (user != null) {
      await _firestore.collection('users').doc(user.uid).update({
        'fcmToken': token,
        'lastTokenUpdate': FieldValue.serverTimestamp(),
      });
    }
  }

  void _onNotificationTapped(NotificationResponse response) {
    // Handle notification tap
    print('Notification tapped: ${response.payload}');
    // You can navigate to specific screens based on the payload
  }

  void _handleForegroundMessage(RemoteMessage message) {
    print('Got a message whilst in the foreground!');
    print('Message data: ${message.data}');

    if (message.notification != null) {
      print('Message also contained a notification: ${message.notification}');
      _showLocalNotification(message);
    }
  }

  void _handleNotificationTap(RemoteMessage message) {
    print('Notification tapped: ${message.data}');
    // Navigate to specific screen based on message data
  }

  Future<void> _showLocalNotification(RemoteMessage message) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
          'event_notifications',
          'Event Notifications',
          channelDescription: 'Notifications for upcoming events',
          importance: Importance.max,
          priority: Priority.high,
          showWhen: true,
          icon: 'ic_notification_logo',
        );

    const DarwinNotificationDetails iOSPlatformChannelSpecifics =
        DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    await _localNotifications.show(
      message.hashCode,
      message.notification?.title ?? 'Event Reminder',
      message.notification?.body ?? 'You have an upcoming event',
      platformChannelSpecifics,
      payload: message.data.toString(),
    );
  }

  // Schedule local notification for event 30 minutes before
  Future<void> scheduleEventNotification({
    required String eventId,
    required String eventTitle,
    required String eventLocation,
    required DateTime eventDateTime,
    String? eventDescription,
  }) async {
    print('=== NOTIFICATION SCHEDULING DEBUG ===');
    print('Event ID: $eventId');
    print('Event Title: $eventTitle');
    print('Event DateTime: $eventDateTime');
    print('Current DateTime: ${DateTime.now()}');

    // Calculate notification time (30 minutes before event)
    final notificationTime = eventDateTime.subtract(
      const Duration(minutes: 30),
    );
    print('Notification Time: $notificationTime');

    // Only schedule if the notification time is in the future
    if (notificationTime.isAfter(DateTime.now())) {
      print('Notification time is in the future - proceeding with scheduling');
      const AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails(
            'event_reminders',
            'Event Reminders',
            channelDescription: 'Reminders for upcoming events',
            importance: Importance.max,
            priority: Priority.high,
            showWhen: true,
            enableLights: true,
            playSound: true,
            icon: 'ic_event_notification',
          );

      const DarwinNotificationDetails iOSPlatformChannelSpecifics =
          DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          );

      const NotificationDetails platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: iOSPlatformChannelSpecifics,
      );

      final notificationBody =
          eventDescription != null && eventDescription.isNotEmpty
          ? '$eventDescription\nLocal: $eventLocation'
          : 'Seu evento começa em 30 minutos!\nLocal: $eventLocation';

      final notificationId = eventId.hashCode;
      print('Notification ID: $notificationId');
      print('Notification Title: Lembrete: $eventTitle');
      print('Notification Body: $notificationBody');

      try {
        // Try to schedule with exact alarm first
        await _localNotifications.zonedSchedule(
          notificationId, // Use event ID hash as notification ID
          'Lembrete: $eventTitle',
          notificationBody,
          tz.TZDateTime.from(notificationTime, tz.local),
          platformChannelSpecifics,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          payload: 'event_reminder:$eventId',
        );
        print('✅ Scheduled with exact alarm mode');
      } catch (e) {
        print(
          '⚠️ Exact alarm not permitted, trying with inexact scheduling...',
        );
        // Fallback to inexact scheduling
        await _localNotifications.zonedSchedule(
          notificationId,
          'Lembrete: $eventTitle',
          notificationBody,
          tz.TZDateTime.from(notificationTime, tz.local),
          platformChannelSpecifics,
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          payload: 'event_reminder:$eventId',
        );
        print('✅ Scheduled with inexact alarm mode');
      }

      print(
        '✅ Successfully scheduled notification for event: $eventTitle at ${notificationTime.toString()}',
      );

      // Verify the notification was scheduled
      final pendingNotifications = await _localNotifications
          .pendingNotificationRequests();
      print('Total pending notifications: ${pendingNotifications.length}');
      for (var notification in pendingNotifications) {
        print(
          'Pending notification: ID=${notification.id}, Title=${notification.title}',
        );
      }
    } else {
      print('❌ Notification time is in the past - not scheduling');
      print('Notification time: $notificationTime');
      print('Current time: ${DateTime.now()}');
    }
  }

  // Cancel scheduled notification for an event
  Future<void> cancelEventNotification(String eventId) async {
    await _localNotifications.cancel(eventId.hashCode);
    print('Cancelled notification for event: $eventId');
  }

  // Cancel all scheduled notifications
  Future<void> cancelAllNotifications() async {
    await _localNotifications.cancelAll();
    print('Cancelled all scheduled notifications');
  }

  // Get all pending notifications with their scheduled times
  Future<List<Map<String, dynamic>>> getPendingNotificationsWithTimes() async {
    final pendingNotifications = await _localNotifications
        .pendingNotificationRequests();
    final List<Map<String, dynamic>> notificationsWithTimes = [];

    for (final notification in pendingNotifications) {
      // Extract event time from the notification payload
      String eventTime = '30 minutos antes do evento';

      if (notification.payload != null &&
          notification.payload!.startsWith('event_reminder:')) {
        final eventId = notification.payload!.split(':')[1];

        // Try to get the actual event time from Firestore
        try {
          final eventDoc = await _firestore
              .collection('events')
              .doc(eventId)
              .get();
          if (eventDoc.exists) {
            final eventData = eventDoc.data()!;
            final date = eventData['date'] as String?;
            final time = eventData['time'] as String?;

            if (date != null && time != null) {
              // Format the event time for display
              final eventDateTime = _parseEventDateTime(date, time);
              if (eventDateTime != null) {
                // Format as "30/08/2025 às 10:00"
                final day = eventDateTime.day.toString().padLeft(2, '0');
                final month = eventDateTime.month.toString().padLeft(2, '0');
                final year = eventDateTime.year;
                final hour = eventDateTime.hour.toString().padLeft(2, '0');
                final minute = eventDateTime.minute.toString().padLeft(2, '0');

                eventTime = '$day/$month/$year às $hour:$minute';
              }
            }
          }
        } catch (e) {
          print('Error getting event time: $e');
        }
      }

      notificationsWithTimes.add({
        'notification': notification,
        'scheduledTime': eventTime,
      });
    }

    return notificationsWithTimes;
  }

  // Helper method to parse event date and time
  DateTime? _parseEventDateTime(String date, String time) {
    try {
      // Parse date (format: DD/MM/YYYY)
      final dateParts = date.split('/');
      if (dateParts.length != 3) return null;

      final day = int.parse(dateParts[0]);
      final month = int.parse(dateParts[1]);
      final year = int.parse(dateParts[2]);

      // Parse time (format: HH:MM)
      final timeParts = time.split(':');
      if (timeParts.length != 2) return null;

      final hour = int.parse(timeParts[0]);
      final minute = int.parse(timeParts[1]);

      return DateTime(year, month, day, hour, minute);
    } catch (e) {
      print('Error parsing date/time: $e');
      return null;
    }
  }

  // Get all pending notifications (original method for compatibility)
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _localNotifications.pendingNotificationRequests();
  }

  // Send push notification to specific user
  Future<void> sendPushNotificationToUser({
    required String userId,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    try {
      // Get user's FCM token
      final userDoc = await _firestore.collection('users').doc(userId).get();
      final fcmToken = userDoc.data()?['fcmToken'];

      if (fcmToken != null) {
        // Send notification via Cloud Function (you'll need to implement this)
        await _firestore.collection('notifications').add({
          'userId': userId,
          'fcmToken': fcmToken,
          'title': title,
          'body': body,
          'data': data ?? {},
          'timestamp': FieldValue.serverTimestamp(),
          'status': 'pending',
        });
      }
    } catch (e) {
      print('Error sending push notification: $e');
    }
  }

  // Send push notification to multiple users
  Future<void> sendPushNotificationToUsers({
    required List<String> userIds,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    for (String userId in userIds) {
      await sendPushNotificationToUser(
        userId: userId,
        title: title,
        body: body,
        data: data,
      );
    }
  }

  // Subscribe to topic for general notifications
  Future<void> subscribeToTopic(String topic) async {
    await _firebaseMessaging.subscribeToTopic(topic);
    print('Subscribed to topic: $topic');
  }

  // Unsubscribe from topic
  Future<void> unsubscribeFromTopic(String topic) async {
    await _firebaseMessaging.unsubscribeFromTopic(topic);
    print('Unsubscribed from topic: $topic');
  }

  // Get current FCM token
  Future<String?> getFCMToken() async {
    return await _firebaseMessaging.getToken();
  }

  // Check if notifications are enabled
  Future<bool> areNotificationsEnabled() async {
    final settings = await _firebaseMessaging.getNotificationSettings();
    return settings.authorizationStatus == AuthorizationStatus.authorized;
  }

  // Show immediate notification for testing
  Future<void> showImmediateNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
          'event_reminders',
          'Event Reminders',
          channelDescription: 'Reminders for upcoming events',
          importance: Importance.max,
          priority: Priority.high,
          showWhen: true,
          enableLights: true,
          playSound: true,
          icon: 'ic_notification_logo',
        );

    const DarwinNotificationDetails iOSPlatformChannelSpecifics =
        DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    final notificationId =
        DateTime.now().millisecondsSinceEpoch %
        2147483647; // Keep within 32-bit integer range

    await _localNotifications.show(
      notificationId,
      title,
      body,
      platformChannelSpecifics,
      payload: payload,
    );

    print('✅ Immediate notification shown: $title');
  }
}

// Background message handler
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('Handling a background message: ${message.messageId}');
  // You can perform background tasks here
}
