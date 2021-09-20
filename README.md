# iOS SDK for record and process your table tenins games

This sdk is for https://tt.osai.ai

## How to use

Drag `OsaiTableTennisSDK.xcframework` into your XCode project, add this framework in `General->Frameworks, Libraries, and Embedded Content` of your app and select `Embed and sign`

### Preparation

Add initialization code in your AppDelegate. User needs to be registered in osai service. You can ask user for password, or generate password silently by yourserlves
```objc
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [OSAITableTennis setupWithUserLogin:@"XXX" password:@"XXX" completion:^(BOOL success, NSString * _Nullable error) {
        // Show your interface
    }];
    ...
}
```


Add `handleEventsForBackgroundURLSession` call for background games upload
```objc
- (void)application:(UIApplication *)application handleEventsForBackgroundURLSession:(NSString *)identifier completionHandler:(void (^)(void))completionHandler {
	// This is for background upload session
    [OSAITableTennis.sharedInstance application:application handleEventsForBackgroundURLSession:identifier completionHandler:completionHandler];
}
```


Add `NSCameraUsageDescription` string to your Info.plist file

### Games

For record you need to create game first

```objc 
//  OSAITableTennis.h

/// Create new game
/// @param leftPlayerName Name of left player
/// @param rightPlayerName Name of right player
/// @param gameType Type of game
/// @param userLogin Login of user
- (nullable OSAIGameModel *)createGameWithLeftPlayerName:(nullable NSString *)leftPlayerName rightPlayerName:(nullable NSString *)rightPlayerName gameType:(OSAIGameType)gameType userLogin:(nullable NSString *)userLogin;
```

To obtain all available local recorded games you can call  

```objc
//  OSAITableTennis.h

/// Return all games, stored by SDK
- (nonnull NSArray <OSAIGameModel *> *)games;
```

To update games states and fetch remote games from server you need to call

```objc
//  OSAITableTennis.h

/// Fetch user games from remote server and update local game states
+ (void)reloadGamesWithCompletion:(void(^_Nonnull)(BOOL success))completion;
```

### Record game

With the game object `OSAIGameModel` you need to present recording view on your recording controller. Controller need to be in landscape orientation

```objc
//  OSAITableTennis.h

/// Simple factory method for return UIView that record game and help user with camera position
- (nonnull OSAIRecordGameView *)getRecordGameViewForGame:(nonnull OSAIGameModel *)game delegate:(nonnull id <OSAIRecordGameViewDelegate>)delegate;
```

When recording is complete - delegate method will called, and you can return to games list
```objc
//  OSAIRecordGameView.h

/// You need to close record controller
/// @param gameView sender
- (void)recordGameViewDidFinishRecord:(nonnull OSAIRecordGameView *)gameView;
```


### Upload game

To upload your game to our backend for postprocessing you need to call upload method on the game object
```objc
//  OSAIGameModel.h

/// Start/resume game upload
- (void)uploadVideos;
```

And `stopUpload` for pause/cancel upload process for this game
```objc
//  OSAIGameModel.h

/// Stop uploading process
- (void)stopUpload;
```

Take a look to example application for better understanding. Have a nice day :)
