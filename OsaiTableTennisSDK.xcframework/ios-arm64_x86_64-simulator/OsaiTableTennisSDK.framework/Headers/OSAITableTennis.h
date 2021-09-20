//
//  OSAITableTennis.h
//  OsaiTableTennisSDK
//
//  Created by Роман Зенченко on 20.05.2021.
//

#import <UIKit/UIKit.h>
#import "OSAIGameModel.h"
#import "OSAIUser.h"

#import "OSAIRecordGameView.h"

@interface OSAITableTennis : NSObject

/// Use [OSAITableTennis setupWithUserLogin:password:completion:] to init SDK
- (nullable instancetype)init NS_UNAVAILABLE;
/// Use [OSAITableTennis setupWithUserLogin:password:completion:] to init SDK
- (nullable instancetype)initWithCoder:(nullable NSCoder *)coder NS_UNAVAILABLE;

/// Setup sdk by providing osai user login and password. This method will try to login to existing user, or create new user.
/// @param login User login
/// @param password User password
/// @param completion SDK setup completion block
+ (void)setupWithUserLogin:(nonnull NSString *)login password:(nonnull NSString *)password completion:(void(^_Nonnull)(BOOL success, NSString * _Nullable error))completion;

//+ (nullable instancetype)sharedInstance;

/// Call this method from your AppDelegate for background upload
+ (void)application:(nonnull UIApplication *)application handleEventsForBackgroundURLSession:(nonnull NSString *)identifier completionHandler:(void (^_Nonnull)(void))completionHandler;

#pragma mark - User

/// Return object of current user
+ (nullable OSAIUser *)user;

#pragma mark - Games

/// Fetch user games from remote server and update local game states
+ (void)reloadGamesWithCompletion:(void(^_Nonnull)(BOOL success))completion;

/// Return all games, stored by SDK
+ (nonnull NSArray <OSAIGameModel *> *)games;

/// Create new game
/// @param leftPlayerName Name of left player
/// @param rightPlayerName Name of right player
/// @param gameType Type of game
/// @param userLogin Login of user
+ (nullable OSAIGameModel *)createGameWithLeftPlayerName:(nullable NSString *)leftPlayerName rightPlayerName:(nullable NSString *)rightPlayerName gameType:(OSAIGameType)gameType userLogin:(nullable NSString *)userLogin;

/// You can only upload one game per day. Returns date of next possible upload. Return nil if you can freely upload game
+ (nullable NSDate *)canUploadDate;


#pragma mark - Recording

/// Simple factory method for return UIView that record game and help user with camera position
+ (nonnull OSAIRecordGameView *)getRecordGameViewForGame:(nonnull OSAIGameModel *)game delegate:(nonnull id <OSAIRecordGameViewDelegate>)delegate;

@end

