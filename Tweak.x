#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface FLEXManager : NSObject
- (void)sharedManager;
- (void)showExplorer;
@end

extern BOOL EnablesTweak();
extern BOOL Shake();

%hook YTAppDelegate
- (BOOL)application:(id)application didFinishLaunchingWithOptions:(id)launchOptions {
    BOOL didFinishLaunching = %orig;
    if (EnablesTweak()) [[%c(FLEXManager) performSelector:@selector(sharedManager)] performSelector:@selector(showExplorer)];
    return didFinishLaunching;
}
- (void)appWillResignActive {
    %orig;
    if (EnablesTweak()) [[%c(FLEXManager) performSelector:@selector(sharedManager)] performSelector:@selector(showExplorer)];
}
%end

%hook UIWindow
- (void)motionBegan:(UIEventSubtype)motion withEvent:(UIEvent *)event {
    %orig;
    if (motion == UIEventSubtypeMotionShake && Shake()) [[%c(FLEXManager) performSelector:@selector(sharedManager)] performSelector:@selector(showExplorer)];
}
%end