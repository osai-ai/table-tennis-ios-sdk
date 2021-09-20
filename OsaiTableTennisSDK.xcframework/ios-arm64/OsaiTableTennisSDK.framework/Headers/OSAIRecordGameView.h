//
//  OSAIRecordGameView.h
//  OsaiTableTennisSDK
//
//  Created by Роман Зенченко on 21.05.2021.
//

#import <UIKit/UIKit.h>
#import "OSAIGameModel.h"

#import <AVFoundation/AVFoundation.h>

@class OSAIRecordGameView;
@protocol OSAIRecordGameViewDelegate <NSObject>

/// Record is finished. You need to close record controller
/// @param gameView sender
- (void)recordGameViewDidFinishRecord:(nonnull OSAIRecordGameView *)gameView;

/// You need to hide your preparation views. And you can show your custom record overlay
/// @param gameView sender
- (void)recordGameViewDidStartRecord:(nonnull OSAIRecordGameView *)gameView;

/// You can show some custom preparation views
/// @param gameView sender
- (void)recordGameViewDidStartPreparation:(nonnull OSAIRecordGameView *)gameView;

/// Property *readyForRecord* or one of preparation flags is changed
/// @param gameView sender
- (void)recordGameViewDidChangeReadyState:(nonnull OSAIRecordGameView *)gameView;

@optional
- (void)captureOutput:(nonnull AVCaptureOutput *)output didOutputSampleBuffer:(CMSampleBufferRef _Nullable )sampleBuffer fromConnection:(nonnull AVCaptureConnection *)connection;

@end

@interface OSAIRecordGameView : UIView
- (nullable instancetype)init NS_UNAVAILABLE;
- (nonnull instancetype)initWithFrame:(CGRect)frame NS_UNAVAILABLE;
- (nullable instancetype)initWithCoder:(nullable NSCoder *)coder NS_UNAVAILABLE;
- (nonnull instancetype)initWithDelegte:(nonnull id <OSAIRecordGameViewDelegate> )delegate game:(nonnull OSAIGameModel *)game NS_DESIGNATED_INITIALIZER;

/// Customize font on every elements in this view
@property (strong, nonatomic, nonnull) UIFont *font;

/// Use your own start button
@property (strong, nonatomic, nullable) UIButton *customStartButton;
/// Use your own stop button
@property (strong, nonatomic, nullable) UIButton *customStopButton;
/// Use your own cancel button
@property (strong, nonatomic, nullable) UIButton *customCancelButton;

/// Seconds to countdown between preparation and actual record. Default to 10 seconds
@property (assign, nonatomic) NSUInteger countdownSeconds;

/// Show border for our table detection. Use only for test purposes. Default to NO
@property (assign, nonatomic) BOOL showTableDetection;

/// Use ultra wide camera if can. Default to NO
@property (assign, nonatomic) BOOL useUltraWideCamera;

/// You can set some view, that will be visible on preparation step. OSAIRecordGameView will hide it by itself
/// @param preparationView your container view with some preparation info
- (void)setPreparationView:(nullable UIView *)preparationView;

/// You can set some view, that will be visible on recording step. OSAIRecordGameView will hide it by itself
/// @param recordingView your container view with some recording info
- (void)setRecordingView:(nullable UIView *)recordingView;

#pragma mark - Preparation flags
/// All preparation is set. Observable
@property (assign, nonatomic, readonly) BOOL readyForRecord;
/// Table positioned correctly. Observable
@property (assign, nonatomic, readonly) BOOL isTableInFrame;
/// Phone volume is enough. Observable
@property (assign, nonatomic, readonly) BOOL isVolumeLoud;
/// Device is stable and fixed. Observable
@property (assign, nonatomic, readonly) BOOL isPhoneStable;
/// Device is on airplane mode. Observable
@property (assign, nonatomic, readonly) BOOL isAirplaneMode;


#pragma mark - Debug

/// Disable table detection
@property (assign, nonatomic) BOOL disableTableDetection;
/// Time of last table recognition round
@property (assign, nonatomic, readonly) double lastRunTime;
/// FPS of table recognition model
@property (assign, nonatomic, readonly) NSInteger tableFPS;
/// FPS of camera frame processing
@property (assign, nonatomic, readonly) NSInteger cameraFPS;

@end
