#import "PluginPitelPlugin.h"
#if __has_include(<flutter_pitel_voip/flutter_pitel_voip-Swift.h>)
#import <flutter_pitel_voip/flutter_pitel_voip-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "flutter_pitel_voip-Swift.h"
#endif

@implementation PluginPitelPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftPluginPitelPlugin registerWithRegistrar:registrar];
}
@end
