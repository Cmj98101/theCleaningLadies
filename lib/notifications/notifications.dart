import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:the_cleaning_ladies/models/user_models/admin.dart';
import 'package:the_cleaning_ladies/models/user_models/client.dart';
import 'package:flutter_app_badger/flutter_app_badger.dart';
import 'package:the_cleaning_ladies/src/admin/views/messageInbox.dart';

class NotificationModel {
  final String title;
  final String body;
  final String id;
  NotificationModel(
      {@required this.title, @required this.body, @required this.id});
}

class PushNotifications {
  final Admin admin;
  final BuildContext context;
  bool Function() isMounted;
  String _appBadgeSupported = 'Unknown';
  final Function(Admin, Client) onNotification;
  PushNotifications(
      {@required this.admin,
      @required this.context,
      @required this.isMounted,
      this.onNotification}) {
    configureNotifications();
    initPlatformState(() {
      return isMounted();
    });
  }

  final _db = FirebaseFirestore.instance;
  final FirebaseMessaging _fcm = FirebaseMessaging();
  StreamSubscription iosSubscription;

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

  void configureNotifications() {
    // Future<DocumentSnapshot> snap = _db.doc('Users/${user.id}').get();
    if (Platform.isIOS) {
      iosSubscription = _fcm.onIosSettingsRegistered.listen((data) {
        _saveDeviceToken();
        // snap.then((doc) {
        //   bool subscribed = doc['subscribed'] ?? false;
        //   if (subscribed) {
        //   } else {
        //     // _fcm.subscribeToTopic('${user.code}');
        //     // _db.doc('Users/${user.id}').update({
        //     //   // 'subscribedTo': '${user.code}',
        //     //   'subscribed': true
        //     // })
        //     // // .whenComplete(() => print('SUBSCRIBED TO ${user.code}'));
        //   }
        // });
      });
      _fcm.requestNotificationPermissions(
          IosNotificationSettings(sound: true, badge: true, alert: true));
    } else {
      _saveDeviceToken();
      // snap.then((doc) {
      //   bool subscribed = doc['subscribed'] ?? false;
      //   if (subscribed) {
      //   } else {
      //     // _fcm.subscribeToTopic('${user.code}');
      //     // _db.document('Users/${user.id}').updateData({
      //     //   'subscribedTo': '${user.code}',
      //     //   'subscribed': true
      //     // }).whenComplete(() => print('SUBSCRIBED TO ${user.code}'));
      //   }
      // });
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

  void dispose() {
    iosSubscription?.cancel();
  }
}
