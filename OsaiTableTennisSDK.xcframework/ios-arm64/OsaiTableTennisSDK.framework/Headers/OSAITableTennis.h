//
//  OSAITableTennis.h
//  OsaiTableTennisSDK
//
//  Created by Роман Зенченко on 20.05.2021.
//

#import <UIKit/UIKit.h>
#import "OSAIGameModel.h"

#import "OSAIRecordGameView.h"

@interface OSAITableTennis : NSObject

/// Use [OSAITableTennis setupWithApiKey:] to init SDK
- (nullable instancetype)init NS_UNAVAILABLE;
/// Use [OSAITableTennis setupWithApiKey:] to init SDK
- (nullable instancetype)initWithCoder:(nullable NSCoder *)coder NS_UNAVAILABLE;

/// Default setup. With default username
+ (void)setupWithApiKey:(nonnull NSString *)apiKey;
/// Setup with username. Username is used for local games store
+ (void)setupWithApiKey:(nonnull NSString *)apiKey username:(nonnull NSString *)username;
+ (nullable instancetype)sharedInstance;

/// Call this method from your AppDelegate for background upload
- (void)application:(nonnull UIApplication *)application handleEventsForBackgroundURLSession:(nonnull NSString *)identifier completionHandler:(void (^_Nonnull)(void))completionHandler;


#pragma mark - Games

/// Return all games, stored by SDK
- (nonnull NSArray <OSAIGameModel *> *)games;

/// Create new game
/// @param leftPlayerName Name of left player
/// @param rightPlayerName Name of right player
/// @param gameType Type of game
/// @param userLogin Login of user
- (nullable OSAIGameModel *)createGameWithLeftPlayerName:(nullable NSString *)leftPlayerName rightPlayerName:(nullable NSString *)rightPlayerName gameType:(OSAIGameType)gameType userLogin:(nullable NSString *)userLogin;

/// Remove existing game
/// @param game Object of game to remove
- (void)removeGame:(nonnull OSAIGameModel *)game;


#pragma mark - Recording

/// Simple factory method for return UIView that record game and help user with camera position
- (nonnull OSAIRecordGameView *)getRecordGameViewForGame:(nonnull OSAIGameModel *)game delegate:(nonnull id <OSAIRecordGameViewDelegate>)delegate;

@end

