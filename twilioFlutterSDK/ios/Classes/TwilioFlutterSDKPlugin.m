#import "TwilioFlutterSDKPlugin.h"
#if __has_include(<twilioFlutterSDK/twilioFlutterSDK-Swift.h>)
#import <twilioFlutterSDK/twilioFlutterSDK-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "twilioFlutterSDK-Swift.h"
#endif

@implementation TwilioFlutterSDKPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftTwilioFlutterSDKPlugin registerWithRegistrar:registrar];
}
@end
