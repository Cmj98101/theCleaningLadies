import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
// import 'package:twilioFlutterSDK/twilioFlutterSDK.dart';

void main() {
  const MethodChannel channel = MethodChannel('twilioFlutterSDK');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    // expect(await TwilioFlutterSDK.platformVersion, '42');
  });
}
