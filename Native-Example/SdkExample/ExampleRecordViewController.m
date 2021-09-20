//
//  ExampleRecordViewController.m
//  SdkExample
//
//  Created by Роман Зенченко on 30.07.2021.
//

#import "ExampleRecordViewController.h"

#import "ExampleGamesViewController.h"
#import "AppDelegate.h"

@interface ExampleRecordViewController () <OSAIRecordGameViewDelegate>

@property (strong, nonatomic) OSAIRecordGameView *recordView;

@property (strong, nonatomic) UIView *prepareContainer;
@property (strong, nonatomic) UILabel *prepareLabel;
@property (strong, nonatomic) UIView *recordContainer;

@end

@implementation ExampleRecordViewController

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
    self.recordView = [OSAITableTennis getRecordGameViewForGame:self.game delegate:self];
    self.recordView.showTableDetection = YES;
    [self.view addSubview:self.recordView];

    self.prepareContainer = [UIView new];
    self.prepareContainer.backgroundColor = [UIColor clearColor];
    [self.recordView setPreparationView:self.prepareContainer];
    
    self.prepareLabel = [UILabel new];
    self.prepareLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightBold];
    self.prepareLabel.text = @"You need to maximize volume and phone need to be stable (on tripod or something)";
    [self.prepareContainer addSubview:self.prepareLabel];
    
    
    self.recordContainer = [UIView new];
    self.recordContainer.backgroundColor = [UIColor clearColor];
    [self.recordView setRecordingView:self.recordContainer];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    self.recordView.frame = self.view.bounds;
    CGSize prepareLabelSize = [self.prepareLabel sizeThatFits:CGSizeMake(self.view.bounds.size.width - 32, CGFLOAT_MAX)];
    self.prepareLabel.frame = CGRectMake(16, 50, self.view.bounds.size.width - 32, prepareLabelSize.height);
}

#pragma mark - OSAIRecordGameViewDelegate

- (void)recordGameViewDidFinishRecord:(OSAIRecordGameView *)gameView {
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    appDelegate.window.rootViewController = [ExampleGamesViewController new];
}

- (void)recordGameViewDidStartRecord:(OSAIRecordGameView *)gameView {
    NSLog(@"Did start record");
}

- (void)recordGameViewDidStartPreparation:(OSAIRecordGameView *)gameView {
    NSLog(@"Did start preparation");
}

- (void)recordGameViewDidChangeReadyState:(OSAIRecordGameView *)gameView {
    NSLog(@"readyForRecord: %d, isPhoneStable: %d, isVolumeLoud: %d, isTableInFrame: %d, isAirplaneMode %d", gameView.readyForRecord, gameView.isPhoneStable, gameView.isVolumeLoud, gameView.isTableInFrame, gameView.isAirplaneMode);
}

// optional
- (void)captureOutput:(AVCaptureOutput *)output didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    NSLog(@"You can add additional processing for video frames if you want");
}


@end
