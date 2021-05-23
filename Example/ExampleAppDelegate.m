//
//  ExampleAppDelegate.m
//  OsaiTableTennisSDK
//
//  Created by Роман Зенченко on 21.05.2021.
//

#import "ExampleAppDelegate.h"
#import "GamesViewController.h"

#import <OsaiTableTennisSDK/OsaiTableTennisSDK.h>


@implementation ExampleAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [OSAITableTennis setupWithApiKey:@"XXXXXX"];
    
    self.window = [[UIWindow alloc] initWithFrame:UIScreen.mainScreen.bounds];
    self.window.rootViewController = [GamesViewController new];
    [self.window makeKeyAndVisible];
    
    return YES;
}

- (void)application:(UIApplication *)application handleEventsForBackgroundURLSession:(NSString *)identifier completionHandler:(void (^)(void))completionHandler {
    [OSAITableTennis.sharedInstance application:application handleEventsForBackgroundURLSession:identifier completionHandler:completionHandler];
}

@end
