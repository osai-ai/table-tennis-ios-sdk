//
//  RecordViewController.m
//  OsaiTableTennis
//
//  Created by Роман Зенченко on 21.05.2021.
//

#import "RecordViewController.h"

#import "GamesViewController.h"
#import "ExampleAppDelegate.h"

@interface RecordViewController () <OSAIRecordGameViewDelegate>

@property (strong, nonatomic) OSAIRecordGameView *recordView;
@property (strong, nonatomic) UIView *prepareContainer;
@property (strong, nonatomic) UIView *recordContainer;

@end

@implementation RecordViewController

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskLandscape;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationLandscapeLeft;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.recordView = [OSAITableTennis.sharedInstance getRecordGameViewForGame:self.game delegate:self];
    self.recordView.showTableDetection = YES;
    [self.view addSubview:self.recordView];

    self.prepareContainer = [UIView new];
    self.prepareContainer.backgroundColor = [UIColor clearColor];
    [self.recordView setPreparationView:self.prepareContainer];
    
    self.recordContainer = [UIView new];
    self.recordContainer.backgroundColor = [UIColor clearColor];
    [self.recordView setRecordingView:self.recordContainer];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    self.recordView.frame = self.view.bounds;
}

#pragma mark - OSAIRecordGameViewDelegate

- (void)recordGameViewDidFinishRecord:(OSAIRecordGameView *)gameView {
    ExampleAppDelegate *appDelegate = (ExampleAppDelegate *)[UIApplication sharedApplication].delegate;
    appDelegate.window.rootViewController = [GamesViewController new];
}

- (void)recordGameViewDidStartRecord:(OSAIRecordGameView *)gameView {
    NSLog(@"Did start record");
}

- (void)recordGameViewDidStartPreparation:(OSAIRecordGameView *)gameView {
    NSLog(@"Did start preparation");
}

- (void)recordGameViewDidChangeReadyState:(OSAIRecordGameView *)gameView {
    NSLog(@"readyForRecord: %d, isPhoneStable: %d, isVolumeLoud: %d, isTableInFrame: %d", gameView.readyForRecord, gameView.isPhoneStable, gameView.isVolumeLoud, gameView.isTableInFrame);
}

// optional
//- (void)captureOutput:(AVCaptureOutput *)output didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
//    NSLog(@"You can add additional processing for video frames if you want");
//}


@end
