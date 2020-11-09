import Flutter
import UIKit

public class SwiftTwilioFlutterSDKPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "twilioFlutterSDK", binaryMessenger: registrar.messenger())
    let instance = SwiftTwilioFlutterSDKPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    result("iOS " + UIDevice.current.systemVersion)
  }
}
