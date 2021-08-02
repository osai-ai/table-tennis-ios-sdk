//
//  AppDelegate.m
//  SdkExample
//
//  Created by Роман Зенченко on 30.07.2021.
//

#import "AppDelegate.h"
#import "ExampleGamesViewController.h"

#import <OsaiTableTennisSDK/OsaiTableTennisSDK.h>

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [OSAITableTennis setupWithApiKey:@"demo"];
    
    self.window = [[UIWindow alloc] initWithFrame:UIScreen.mainScreen.bounds];
    self.window.rootViewController = [ExampleGamesViewController new];
    [self.window makeKeyAndVisible];
    
    return YES;
}


- (void)application:(UIApplication *)application handleEventsForBackgroundURLSession:(NSString *)identifier completionHandler:(void (^)(void))completionHandler {
    [OSAITableTennis.sharedInstance application:application handleEventsForBackgroundURLSession:identifier completionHandler:completionHandler];
}

@end
