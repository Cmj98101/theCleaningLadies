import 'dart:async';

import 'package:flutter/services.dart';

class TwilioFlutterSDK {
  static const MethodChannel _channel =
      const MethodChannel('twilioFlutterSDK');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }
}
