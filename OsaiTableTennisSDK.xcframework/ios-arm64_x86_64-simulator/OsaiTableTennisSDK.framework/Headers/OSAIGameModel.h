//
//  OSAIGameModel.h
//  OsaiTableTennis
//
//  Created by Роман Зенченко on 09.03.2021.
//

#import <UIKit/UIKit.h>

/// State of processing
typedef NS_ENUM(NSUInteger, OSAIProcessState) {
    /// Processing of game is not started yet
    OSAIProcessStateNotStarted,
    /// Processing in progress
    OSAIProcessStateHandling,
    /// Processing done, you can check report in *reportUrl*
    OSAIProcessStateDone,
    /// Processing cancelled
    OSAIProcessStateCancelled,
};

/// State of the game
typedef NS_ENUM(NSUInteger, OSAIGameState) {
    /// Game is created or recorded. Not uploaded to osai server
    OSAIGameStateLocal,
    /// Game is uploading to osai server
    OSAIGameStateUploading,
    /// Uploading is suspended. You can resume by calling *uploadVideos*
    OSAIGameStateUploadingPause,
    /// Uploading finished with error
    OSAIGameStateError,
    /// Game are uploaded and wait for processing
    OSAIGameStateWaitForProcessing
};

/// Type of recording game
typedef NS_ENUM(NSUInteger, OSAIGameType) {
    /// With referee
    OSAIGameTypeGame,
    /// Without referee
    OSAIGameTypeTraining
};

@interface OSAIGameModel : NSObject <NSCoding>

/// Internal game id
@property (strong, nonatomic, readonly) NSString *identifier;
/// Game local state. Observable
@property (assign, nonatomic, readonly) OSAIGameState state;
/// Game processing state. Observable
@property (assign, nonatomic, readonly) OSAIProcessState processState;
/// Link to report
@property (strong, nonatomic, readonly) NSString *reportUrl;
/// Name of left player
@property (strong, nonatomic, readonly) NSString *leftPlayerName;
/// Name of right player
@property (strong, nonatomic, readonly) NSString *rightPlayerName;

/// Move players one to another
- (void)switchPlayers;

/// Date of creation
@property (strong, nonatomic, readonly) NSDate *date;
/// Duration of recorded game in seconds. Observable
@property (assign, nonatomic, readonly) double duration;
/// Total size of video in MB
@property (assign, nonatomic, readonly) double totalSize;
/// Upload progress. Observable
@property (assign, nonatomic, readonly) double uploadProgress;
/// Type of game
@property (assign, nonatomic, readonly) OSAIGameType type;
/// Uploading error. Only for state OSAIGameStateError
@property (strong, nonatomic, readonly) NSError *error;

/// Thumbnail of recorded game
@property (strong, nonatomic, readonly) UIImage *thumbnail;

/// Remote URL for video
@property (strong, nonatomic, readonly) NSURL *remoteVideoUrl;

/// Path of stored videos
@property (strong, nonatomic, readonly) NSString *path;

/// Game is currently recorded
@property (assign, nonatomic, readonly) BOOL isRecording;

/// Start/resume game upload
- (void)uploadVideos;

/// Stop uploading process
- (void)stopUpload;

/// Game is only on local device. Need to be uploaded
- (BOOL)needUpload;

@end
