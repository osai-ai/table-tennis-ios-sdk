//
//  OSAITableTennisSDKModule.m
//  OsaiTTSdkExample
//
//  Created by Роман Зенченко on 15.09.2021.
//

#import "OSAITableTennisSDKModule.h"

#import <React/RCTConvert.h>

@implementation RCTConvert (GameType)
  RCT_ENUM_CONVERTER(OSAIGameType, (@{ @(OSAIGameTypeGame) : @(OSAIGameTypeGame), @(OSAIGameTypeTraining) : @(OSAIGameTypeTraining)}), OSAIGameTypeGame, integerValue)
@end

@interface RNTOSAIRecordGameView : OSAIRecordGameView

/// Record is finished. You need to close record controller
@property (nonatomic, copy) RCTBubblingEventBlock onFinishRecord;
/// You need to hide your preparation views. And you can show your custom record overlay
@property (nonatomic, copy) RCTBubblingEventBlock onStartRecord;
/// You can show some custom preparation views
@property (nonatomic, copy) RCTBubblingEventBlock onStartPreparation;
/// Property *readyForRecord* or one of preparation flags is changed
@property (nonatomic, copy) RCTBubblingEventBlock onChangeReadyState;

/// Customize font on every elements in this view
@property (nonatomic, strong) NSString *fontName;

@end

@implementation RNTOSAIRecordGameView

/// Customize font on every elements in this view
/// @param fontName Name of font to use in RecordView
- (void)setFontName:(NSString *)fontName {
  UIFont *font = [UIFont fontWithName:fontName size:12];
  if (font) {
    [self setFont:font];
  }
}

@end

// Some local varaibles to create game and show RecordView
NSString *osai_createGameLeftPlayerName;
NSString *osai_createGameRightPlayerName;
OSAIGameType osai_createGameGameType;
NSString *osai_createGameUserLogin;

@implementation OSAITableTennisSDKModule {
  /// Local ref to games. For observing
  NSArray <OSAIGameModel *> *_osai_games;
  
  /// Module has event listeners
  bool _osai_hasListeners;
}
RCT_EXPORT_MODULE(OSAITableTennisSDK);

+ (BOOL)requiresMainQueueSetup
{
  return YES;
}

-(void)startObserving {
  _osai_hasListeners = YES;
}
-(void)stopObserving {
  _osai_hasListeners = NO;
}

- (void)dealloc
{
  [self _osai_removeObservers];
}


/// Enums export
- (NSDictionary *)constantsToExport {
  NSDictionary *processState = @{
    @"OSAIProcessStateNotStarted": @(OSAIProcessStateNotStarted),
    @"OSAIProcessStateHandling": @(OSAIProcessStateHandling),
    @"OSAIProcessStateDone": @(OSAIProcessStateDone),
    @"OSAIProcessStateCancelled": @(OSAIProcessStateCancelled),
  };
  
  NSDictionary *gameState = @{
    @"OSAIGameStateLocal": @(OSAIGameStateLocal),
    @"OSAIGameStateUploading": @(OSAIGameStateUploading),
    @"OSAIGameStateUploadingPause": @(OSAIGameStateUploadingPause),
    @"OSAIGameStateError": @(OSAIGameStateError),
    @"OSAIGameStateWaitForProcessing": @(OSAIGameStateWaitForProcessing),
  };
  
  NSDictionary *gameType = @{
    @"OSAIGameTypeGame": @(OSAIGameTypeGame),
    @"OSAIGameTypeTraining": @(OSAIGameTypeTraining),
  };
  
  return @{
    @"OSAIProcessState": processState,
    @"OSAIGameState": gameState,
    @"OSAIGameType": gameType,
  };
}

/// Create new game
/// @param leftPlayerName Name of left player
/// @param rightPlayerName Name of right player
/// @param gameType Type of game
/// @param userLogin Login of user
RCT_EXPORT_METHOD(createGameWithLeftPlayerName:(nullable NSString *)leftPlayer rightPlayer:(nullable NSString *)rightPlayer type:(OSAIGameType)type login:(nullable NSString *)login) {
  NSLog(@"createGameWithLeftPlayerName %@ %@ %zd %@", leftPlayer, rightPlayer, type, login);
  osai_createGameLeftPlayerName = leftPlayer;
  osai_createGameRightPlayerName = rightPlayer;
  osai_createGameUserLogin = login;
  osai_createGameGameType = type;
}


/// Setup sdk by providing osai user login and password. This method will try to login to existing user, or create new user.
/// @param login User login
/// @param password User password
/// @param completion SDK setup completion block
RCT_EXPORT_METHOD(setupWithUserLogin:(NSString *)login
                password:(NSString *)password
                  success:(RCTResponseSenderBlock)success
                  fail:(RCTResponseSenderBlock)fail) {
  [OSAITableTennis setupWithUserLogin:login password:password completion:^(BOOL blockSuccess, NSString * _Nullable error) {
    if (error) {
      fail(@[error]);
    } else {
      success(@[]);
    }
  }];
}

/// You can only upload one game per day. Returns date of next possible upload. Return nil if you can freely upload game
RCT_EXPORT_BLOCKING_SYNCHRONOUS_METHOD(canUploadGame) {
  NSDate *canUploadDate = OSAITableTennis.canUploadDate;
  BOOL canUpload = canUploadDate == nil;
  return @(canUpload);
}

/// Start/resume upload game with id
/// @param gameId Local game identifier
RCT_EXPORT_METHOD(uploadGameWithId:(NSString *)gameId) {
  OSAIGameModel *game = [OSAITableTennis.games filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"identifier == %@", gameId]].firstObject;
  NSLog(@"GAME FOUND %@", game.identifier);
  if (game) {
    [game uploadVideos];
  }
}

/// Stop game with id uploading process
/// @param gameId Local game identifier
RCT_EXPORT_METHOD(stopUploadGameWithId:(NSString *)gameId) {
  OSAIGameModel *game = [OSAITableTennis.games filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"identifier == %@", gameId]].firstObject;
  NSLog(@"GAME FOUND %@", game.identifier);
  if (game) {
    [game stopUpload];
  }
}

/// Fetch user games from remote server and update local game states
RCT_EXPORT_METHOD(reloadGamesWithCompletion:(RCTResponseSenderBlock)completion) {
  [OSAITableTennis reloadGamesWithCompletion:^(BOOL success) {
    completion(@[]);
  }];
}

/// Return all games, stored by SDK
RCT_EXPORT_BLOCKING_SYNCHRONOUS_METHOD(getGames) {
  [self _osai_removeObservers];
  _osai_games = [NSArray arrayWithArray:[OSAITableTennis games] ?: @[]];
  [self _osai_addObservers];
  NSMutableArray *result = [NSMutableArray new];
  for (OSAIGameModel *game in _osai_games) {
    [result addObject:[self _osai_gameToDict:game]];
  }
  return result;
}

/// Return object of current user
RCT_EXPORT_BLOCKING_SYNCHRONOUS_METHOD(getUser) {
  OSAIUser *user = OSAITableTennis.user;
  if (user) {
    return [self _osai_userToDict:user];
  }
  return [NSNull null];
}

/// Map OSAIUser object to dict
- (NSDictionary *)_osai_userToDict:(OSAIUser *)user {
  NSMutableDictionary *result = [NSMutableDictionary new];
  
  result[@"userId"] = user.userId.stringValue;
  result[@"userLogin"] = user.userLogin;
  result[@"token"] = user.token;
  result[@"firstName"] = user.firstName;
  result[@"lastName"] = user.lastName;
  
  return result;
}

/// Map OSAIGameModel object to dict
- (NSDictionary *)_osai_gameToDict:(OSAIGameModel *)game {
  NSMutableDictionary *result = [NSMutableDictionary new];
  
  result[@"id"] = game.identifier;
  result[@"state"] = @(game.state);
  result[@"processState"] = @(game.processState);
  result[@"reportUrl"] = game.reportUrl ?: [NSNull null];
  result[@"leftPlayerName"] = game.leftPlayerName ?: [NSNull null];
  result[@"rightPlayerName"] = game.rightPlayerName ?: [NSNull null];
  result[@"date"] = @(game.date.timeIntervalSince1970);
  result[@"duration"] = @(game.duration);
  result[@"totalSize"] = @(game.totalSize);
  result[@"uploadProgress"] = @(game.uploadProgress);
  result[@"type"] = @(game.type);
  result[@"uploadError"] = game.error ? game.error.localizedDescription?: [NSNull null] : [NSNull null];
  result[@"remoteVideoUrl"] = game.remoteVideoUrl.absoluteString ?: [NSNull null];
  result[@"path"] = game.path ?: [NSNull null];
  result[@"needUpload"] = @(game.needUpload);
  
  if (game.path) {
    result[@"thumbnail"] = [game.path stringByAppendingPathComponent:@"preview.jpg"];
  } else {
    result[@"thumbnail"] = [NSNull null];
  }
  return result;
}

+ (NSString *)_osai_processStateToString:(OSAIProcessState)state {
  NSDictionary *processState = @{
    @(OSAIProcessStateNotStarted): @"OSAIProcessStateNotStarted",
    @(OSAIProcessStateHandling): @"OSAIProcessStateHandling",
    @(OSAIProcessStateDone): @"OSAIProcessStateDone",
    @(OSAIProcessStateCancelled): @"OSAIProcessStateCancelled",
  };
  return processState[@(state)];
}

+ (NSString *)_osai_gameStateToString:(OSAIGameState)state {
  NSDictionary *gameState = @{
    @(OSAIGameStateLocal): @"OSAIGameStateLocal",
    @(OSAIGameStateUploading): @"OSAIGameStateUploading",
    @(OSAIGameStateUploadingPause): @"OSAIGameStateUploadingPause",
    @(OSAIGameStateError): @"OSAIGameStateError",
    @(OSAIGameStateWaitForProcessing): @"OSAIGameStateWaitForProcessing",
  };
  return gameState[@(state)];
}

+ (NSString *)_osai_gameTypeToString:(OSAIGameType)state {
  NSDictionary *gameType = @{
    @(OSAIGameTypeGame): @"OSAIGameTypeGame",
    @(OSAIGameTypeTraining): @"OSAIGameTypeTraining",
  };
  return gameType[@(state)];
}

- (void)_osai_removeObservers {
  for (OSAIGameModel *game in _osai_games) {
    [game removeObserver:self forKeyPath:@"state"];
    [game removeObserver:self forKeyPath:@"processState"];
    [game removeObserver:self forKeyPath:@"uploadProgress"];
    [game removeObserver:self forKeyPath:@"totalSize"];
  }
}

- (void)_osai_addObservers {
  for (OSAIGameModel *game in _osai_games) {
    [game addObserver:self forKeyPath:@"state" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
    [game addObserver:self forKeyPath:@"processState" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
    [game addObserver:self forKeyPath:@"uploadProgress" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
    [game addObserver:self forKeyPath:@"totalSize" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
  }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
  BOOL changed = NO;
  if ([object isKindOfClass:OSAIGameModel.class]) {
    changed = ![[change objectForKey:NSKeyValueChangeNewKey] isEqual:[change objectForKey:NSKeyValueChangeOldKey]];
  }
  if ([keyPath isEqualToString:@"state"]) {
    if (_osai_hasListeners && changed) {
      [self sendEventWithName:@"osai_gameStateChanged" body:[self _osai_gameToDict:(OSAIGameModel *)object]];
    }
  } else if ([keyPath isEqualToString:@"processState"]) {
    if (_osai_hasListeners && changed) {
      [self sendEventWithName:@"osai_gameProcessStateChanged" body:[self _osai_gameToDict:(OSAIGameModel *)object]];
    }
  } else if ([keyPath isEqualToString:@"uploadProgress"]) {
    if (_osai_hasListeners && changed) {
      [self sendEventWithName:@"osai_gameUploadProgressChanged" body:[self _osai_gameToDict:(OSAIGameModel *)object]];
    }
  } else if ([keyPath isEqualToString:@"totalSize"]) {
    if (_osai_hasListeners && changed) {
      [self sendEventWithName:@"osai_gameTotalSizeChanged" body:[self _osai_gameToDict:(OSAIGameModel *)object]];
    }
  } else {
    [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
  }
}

- (NSArray<NSString *> *)supportedEvents {
  return @[
    @"osai_gameStateChanged",
    @"osai_gameProcessStateChanged",
    @"osai_gameUploadProgressChanged",
    @"osai_gameTotalSizeChanged",
  ];
}

@end

@interface OSAITableTennisSDKRecordingViewManager : RCTViewManager <OSAIRecordGameViewDelegate>

@property (strong, nonatomic) RNTOSAIRecordGameView *recordView;

@end

@implementation OSAITableTennisSDKRecordingViewManager
RCT_EXPORT_MODULE(OSAITableTennisRecordView)

RCT_EXPORT_VIEW_PROPERTY(onFinishRecord, RCTBubblingEventBlock)
RCT_EXPORT_VIEW_PROPERTY(onStartRecord, RCTBubblingEventBlock)
RCT_EXPORT_VIEW_PROPERTY(onStartPreparation, RCTBubblingEventBlock)
RCT_EXPORT_VIEW_PROPERTY(onChangeReadyState, RCTBubblingEventBlock)

RCT_EXPORT_VIEW_PROPERTY(countdownSeconds, NSUInteger)
RCT_EXPORT_VIEW_PROPERTY(showTableDetection, BOOL)
RCT_EXPORT_VIEW_PROPERTY(useUltraWideCamera, BOOL)

RCT_EXPORT_VIEW_PROPERTY(fontName, NSString *)

- (UIView *)view
{
  // Create new game from local vars and return OSAIRecordGameView
  OSAIGameModel *game = [OSAITableTennis createGameWithLeftPlayerName:osai_createGameLeftPlayerName rightPlayerName:osai_createGameRightPlayerName gameType:osai_createGameGameType userLogin:osai_createGameUserLogin];
  self.recordView = [[RNTOSAIRecordGameView alloc] initWithDelegte:self game:game];
  return self.recordView;
}

#pragma mark - OSAIRecordGameViewDelegate

- (void)recordGameViewDidFinishRecord:(OSAIRecordGameView *)gameView {
  if (!((RNTOSAIRecordGameView *)gameView).onFinishRecord) {
      return;
    }
  
  ((RNTOSAIRecordGameView *)gameView).onFinishRecord(@{});
}

- (void)recordGameViewDidStartRecord:(OSAIRecordGameView *)gameView {
  if (!((RNTOSAIRecordGameView *)gameView).onStartRecord) {
      return;
    }
  
  ((RNTOSAIRecordGameView *)gameView).onStartRecord(@{});
}

- (void)recordGameViewDidStartPreparation:(OSAIRecordGameView *)gameView {
  if (!((RNTOSAIRecordGameView *)gameView).onStartPreparation) {
      return;
    }
  
  ((RNTOSAIRecordGameView *)gameView).onStartPreparation(@{});
}

- (void)recordGameViewDidChangeReadyState:(OSAIRecordGameView *)gameView {
  if (!((RNTOSAIRecordGameView *)gameView).onChangeReadyState) {
    return;
  }
  
  ((RNTOSAIRecordGameView *)gameView).onChangeReadyState(@{
    @"readyForRecord": @(gameView.readyForRecord),
    @"isPhoneStable": @(gameView.isPhoneStable),
    @"isVolumeLoud": @(gameView.isVolumeLoud),
    @"isTableInFrame": @(gameView.isTableInFrame),
    @"isAirplaneMode": @(gameView.isAirplaneMode)});
}

@end
