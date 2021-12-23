import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:the_cleaning_ladies/models/user_models/admin.dart';
import 'package:the_cleaning_ladies/models/user_models/client.dart';
import 'package:flutter_app_badger/flutter_app_badger.dart';
import 'package:the_cleaning_ladies/notification_model/notification_model.dart';
import 'package:the_cleaning_ladies/src/admin/views/MyClients/messageInbox.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class PushNotifications {
  /// Admin account
  final Admin admin;

  /// Context for current page
  BuildContext context;

  bool Function() isMounted;

  FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  String _appBadgeSupported = 'Unknown';
  final _db = FirebaseFirestore.instance;
  final FirebaseMessaging _fcm = FirebaseMessaging();
  StreamSubscription iosSubscription;
  int notificationLimit = 54;

  /// Function that will be called on Page/Screen
  Function(Admin, Client) onNotification;

  PushNotifications(
      {@required this.admin,
      @required this.context,
      @required this.isMounted,
      this.onNotification}) {
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('America/Detroit'));
    configureNotifications();
    initializeNotificationHandler();
    initPlatformState(() {
      return isMounted();
    });
    addPendingNotifications();
  }
  PushNotifications.schedule(
      {@required this.admin,
      @required NotificationModel notification,
      @required Function() onQueueFull,
      @required Function() onNotificationScheduled,
      @required Function(String) onError}) {
    onScheduleRequest(
        notification, onQueueFull, onNotificationScheduled, onError);
  }
  PushNotifications.updateScheduled(
      {@required this.admin,
      @required NotificationModel notification,
      @required Function() onQueueFull,
      @required Function() onNotificationScheduled,
      @required Function(String) onError}) {
    deleteScheduledNotification(notification);
    onScheduleRequest(
        notification, onQueueFull, onNotificationScheduled, onError);
  }
  PushNotifications.deleteScheduled(
      {@required this.admin, NotificationModel notification}) {
    deleteScheduledNotification(notification);
  }
  void clearAllFiredNotifications() async {
    List<NotificationModel> awaitingNotifications =
        await admin.fetchAwaitingNotifications(isSet: true);
    awaitingNotifications.forEach((notification) {
      if (notification.reminderFor.isBefore(DateTime.now())) {
        notification.ref.delete();
      }
    });
  }

  Future<void> addPendingNotifications() async {
    clearAllFiredNotifications();

    // int pendingNotificationCount = await pendingNotifications()
    print('pending Notification List: ${await pendingNotificationsCount()}');
    // Fetch only 54 unscheduled Notifications from DB
    List<NotificationModel> awaitingNotifications =
        await admin.fetchAwaitingNotifications();

    if (awaitingNotifications.isEmpty) return;

    // schedule up to 54 notification only if Admin wants
    // reminders for each appointment
    if (await checkNotificationsCount()) {
      int allowedToAdd = notificationLimit - await pendingNotificationsCount();
      awaitingNotifications.sort(
          (date1, date2) => date1.reminderFor.compareTo(date2.reminderFor));
      for (var i = 0; i < allowedToAdd; i++) {
        NotificationModel notification = awaitingNotifications[i];
        scheduledNotification(notification, () {
          notification.ref.update({'isSet': true});
          print('successfull ${notification.id}');
        }, (error) {
          print(error);
        });
      }
    } else {
      //TODO: IN THE FUTURE if pending list
      // is full then check the latest notification
      // to see if it scheduled at a later date
      // then the notification that is trying to be scheduled now
      print('queue is full at the moment');
    }
  }

  void onScheduleRequest(NotificationModel notification, Function() onQueueFull,
      Function() onNotificationScheduled, Function(String) onError) async {
    if (await checkNotificationsCount()) {
      return scheduledNotification(
          notification, onNotificationScheduled, onError);
    }
    onQueueFull();
  }

  Future<bool> checkNotificationsCount() async {
    int scheduledCount = await pendingNotificationsCount();
    return scheduledCount < notificationLimit ? true : false;
  }

  Future<List<PendingNotificationRequest>> pendingNotifications() async {
    List<PendingNotificationRequest> pendingNotifications =
        await _flutterLocalNotificationsPlugin.pendingNotificationRequests();
    return pendingNotifications;
  }

  Future<int> pendingNotificationsCount() async {
    List<PendingNotificationRequest> pendingNotifications =
        await _flutterLocalNotificationsPlugin.pendingNotificationRequests();
    return pendingNotifications.length;
  }

  initPlatformState(bool Function() isMounted) async {
    String appBadgeSupported;
    try {
      bool res = await FlutterAppBadger.isAppBadgeSupported();
      if (res) {
        appBadgeSupported = 'Supported';
      } else {
        appBadgeSupported = 'Not supported';
      }
    } on PlatformException {
      appBadgeSupported = 'Failed to get badge support.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!isMounted()) return;

    _appBadgeSupported = appBadgeSupported;
    await admin.updateAdminNotificationCount(
        checkNotifications: true,
        onDone: () {
          removeBadge();
          addBadge(admin.notificationCount);
        });
    // print(appBadgeSupported);
  }

  void addBadge(int badgeCount) {
    FlutterAppBadger.updateBadgeCount(badgeCount);
    print('added badge $badgeCount');
  }

  void removeBadge() {
    FlutterAppBadger.removeBadge();
  }

  int generateId() {
    DateTime now = DateTime.now();
    String idCombination = '${now.minute}${now.second}${now.millisecond}';
    int id = int.parse(idCombination);
    return id;
  }

  Future<void> scheduledNotification(NotificationModel notification,
      Function() onNotificationScheduled, Function(String) onError) async {
    if (tz.TZDateTime.from(notification.reminderFor, tz.local)
        .isBefore(DateTime.now())) {
      onError(
          'Cannot Schedule a notification because the reminder time has passed');
      return print(
          'Cannot Schedule a notification because the reminder time has passed');
    }

    await _flutterLocalNotificationsPlugin.zonedSchedule(
        notification.id,
        notification.title,
        notification.body,
        tz.TZDateTime.from(notification.reminderFor, tz.local),
        setupPlatformChannelSpecifics(),
        payload: notification.payload,
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime);
    onNotificationScheduled();
  }

  Future<void> deleteScheduledNotification(
      NotificationModel notification) async {
    await _flutterLocalNotificationsPlugin.cancel(notification.id);
  }

  NotificationDetails setupPlatformChannelSpecifics() {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
            'your channel id', 'your channel name', 'your channel description',
            importance: Importance.max,
            priority: Priority.high,
            ticker: 'ticker');
    return NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );
  }
  // Future<void> showNotification() async {
  //   const AndroidNotificationDetails androidPlatformChannelSpecifics =
  //       AndroidNotificationDetails(
  //           'your channel id', 'your channel name', 'your channel description',
  //           importance: Importance.max,
  //           priority: Priority.high,
  //           ticker: 'ticker');
  //   const NotificationDetails platformChannelSpecifics =
  //       NotificationDetails(android: androidPlatformChannelSpecifics);
  //   await _flutterLocalNotificationsPlugin.show(
  //       0, 'plain title', 'plain body', platformChannelSpecifics,
  //       payload: 'item x');
  // }

  void initializeNotificationHandler() async {
// initialise the plugin. app_icon needs to be a added as a drawable resource to the Android head project
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('app_icon');
    final IOSInitializationSettings initializationSettingsIOS =
        IOSInitializationSettings(
      onDidReceiveLocalNotification: onDidReceiveLocalNotification,
    );

    final InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );
    await _flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: selectNotification);
  }

  Future selectNotification(String payload) async {
    if (payload != null) {
      debugPrint('notification payload: $payload');
    }
    // await Navigator.push(
    //   context,
    //   MaterialPageRoute<void>(builder: (context) => SecondScreen(payload)),
    // );
  }

  Future onDidReceiveLocalNotification(
      int id, String title, String body, String payload) async {
    // display a dialog with the notification details, tap ok to go to another page
    showDialog(
      context: context,
      builder: (BuildContext context) => CupertinoAlertDialog(
        title: Text(title),
        content: Text(body),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            child: Text('Ok'),
            onPressed: () async {},
          )
        ],
      ),
    );
  }

  void configureNotifications() {
    // Future<DocumentSnapshot> snap = _db.doc('Users/${user.id}').get();
    if (Platform.isIOS) {
      iosSubscription = _fcm.onIosSettingsRegistered.listen((data) {
        _saveDeviceToken();
      });
      _fcm.requestNotificationPermissions(
          IosNotificationSettings(sound: true, badge: true, alert: true));
    } else {
      _saveDeviceToken();
    }

    _fcm.configure(
      onMessage: (Map<String, dynamic> message) async {
        print("onMessage1 $message");
        // var body = message['aps']["alert"]["body"];
        var title = message['aps']["alert"]["title"];
        var data = message['data'] ?? message;

        var clientId = data['clientId'];
        // var message1 = message['notification']['data'];

        final snackbar = SnackBar(
          content: Text('$title'),
          action: SnackBarAction(
              label: 'go',
              onPressed: () async {
                Client client = await admin.getClient('Users/$clientId');
                await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            MessageInboxScreen(admin, client)));
              }),
        );
        Scaffold.of(context).showSnackBar(snackbar);
      },
      onBackgroundMessage: Platform.isIOS ? null : myBackgroundMessageHandler,
      onLaunch: (Map<String, dynamic> message) async {
        print('onLaunch $message');
        var data = message['data'] ?? message;
        var clientId = data['clientId'];
        Client client = await admin.getClient('Users/$clientId');
        return onNotification(admin, client);
      },
      onResume: (Map<String, dynamic> message) async {
        print('onResume $message');

        var data = message['data'] ?? message;
        var clientId = data['clientId'];
        Client client = await admin.getClient('Users/$clientId');
        return onNotification(admin, client);
      },
    );
  }

  // TOP-LEVEL or STATIC function to handle background messages
  static Future<dynamic> myBackgroundMessageHandler(
      Map<String, dynamic> message) async {
    print('AppPushs myBackgroundMessageHandler : $message');

    return Future<void>.value();
  }

  _saveDeviceToken() async {
    String uid = admin?.id ?? '';
    if (uid == '') return print('_saveDeviceToken UID is empty/null');
    String fcmToken = await _fcm.getToken();

    if (fcmToken != null) {
      var userRef =
          _db.collection('Users').doc(uid).collection('Tokens').doc(fcmToken);
      await userRef.set({
        'token': fcmToken,
        'createdAt': FieldValue.serverTimestamp(),
        'platform': Platform.operatingSystem
      });
    }
  }

  /// Dispose function for Notification
  void dispose() {
    iosSubscription?.cancel();
  }
}
