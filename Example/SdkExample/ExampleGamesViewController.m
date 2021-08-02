//
//  ExampleGamesViewController.m
//  SdkExample
//
//  Created by Роман Зенченко on 30.07.2021.
//

#import "ExampleGamesViewController.h"
#import <OsaiTableTennisSDK/OsaiTableTennisSDK.h>

#import "ExampleRecordViewController.h"
#import "AppDelegate.h"

@interface ExampleGamesViewController () <UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) NSArray <OSAIGameModel *> *games;

@property (strong, nonatomic) UIButton *createGameButton;

@end

@implementation ExampleGamesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView = [UITableView new];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 80, 0);
    [self.view addSubview:self.tableView];
    
    self.createGameButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.createGameButton setTitle:@"Create game" forState:UIControlStateNormal];
    [self.createGameButton addTarget:self action:@selector(createGameButtonTap) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.createGameButton];
    
    [self reloadTable];
}

- (void)reloadTable {
    self.games = [OSAITableTennis.sharedInstance games];
    [self.tableView reloadData];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    self.createGameButton.frame = CGRectMake(16, CGRectGetHeight(self.view.bounds) - (44 + 16 + self.view.safeAreaInsets.bottom), CGRectGetWidth(self.view.bounds) - 32, 44);
    self.tableView.frame = self.view.bounds;
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.games.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell =  [tableView dequeueReusableCellWithIdentifier:@"defaultCell"];
    if (!cell) {
       cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"defaultCell"];
    }
    OSAIGameModel *game = self.games[indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"%@ – %@, %zd", game.leftPlayerName, game.rightPlayerName, game.state];
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    [OSAITableTennis.sharedInstance removeGame:self.games[indexPath.row]];
    self.games = [OSAITableTennis.sharedInstance games];
    [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationTop];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    OSAIGameModel *game = self.games[indexPath.row];
    if (game.state == OSAIGameStateLocal) {
        // You need to observe `state` and `uploadProgress` properties to show upload progress and status to user
        [game uploadVideos];
    } else if (game.state == OSAIGameStateWaitForProcessing) {
        // You need to observe `processState` property to show recognition progress to user
        [game updateStatus];
    }
}

#pragma mark - Actions

- (void)createGameButtonTap {
    OSAIGameModel *game = [OSAITableTennis.sharedInstance createGameWithLeftPlayerName:@"Foo" rightPlayerName:@"Bar" gameType:OSAIGameTypeGame userLogin:@"demo"];
    ExampleRecordViewController *controller = [ExampleRecordViewController new];
    controller.game = game;
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    appDelegate.window.rootViewController = controller;
}


@end
