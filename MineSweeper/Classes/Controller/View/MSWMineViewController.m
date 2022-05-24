//
//  MSWViewController.m
//  MineSweeper
//
//  Created by Gregory Carter on 8/27/13.
//  Copyright (c) 2013 Gregory Carter. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>

#import "MSWMineViewController.h"
#import "MSWMineView.h"
#import "MSWMineTile.h"
#import "MSWSoundManager.h"

#import "MSWScene.h"

static const NSUInteger MSWViewControllerNumberOfTilesWide = 8;
static const NSUInteger MSWViewControllerNumberOfTilesHigh = 10;
static const NSUInteger MSWViewControllerMaximumMines = 10;

@interface MSWMineViewController () <MSWMineViewDelegate>
@property (nonatomic, weak) IBOutlet UIButton *gameButton;
@property (nonatomic, weak) IBOutlet UIButton *cheatButton;
@property (nonatomic, weak) IBOutlet UIButton *verifyButton;

@property (nonatomic, weak) IBOutlet MSWMineView *mineView;
@property (nonatomic, weak) IBOutlet SKView *skView;
@property (nonatomic, weak) IBOutlet UILabel *winConditionLabel;
@property (nonatomic, strong) IBOutletCollection(UIButton) NSArray *gameButtons;
@property (nonatomic, strong) MSWScene *scene;
@property (nonatomic, assign, getter = isShowingWinConditionLabel) BOOL showWinConditionLabel;
@end

@implementation MSWMineViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    [self.mineView resetWithNumberOfTilesWide:MSWViewControllerNumberOfTilesWide numberOfTilesHigh:MSWViewControllerNumberOfTilesHigh maximumMines:MSWViewControllerMaximumMines minimumBombToss:30];
    
    NSArray *controlStates = @[
        @(UIControlStateNormal),
        @(UIControlStateDisabled),
        @(UIControlStateHighlighted)
    ];
    
    [controlStates enumerateObjectsUsingBlock:^(NSNumber *controlStateNumber, NSUInteger idx, BOOL *stop) {
        UIControlState controlState = [controlStateNumber integerValue];
        
        [self.gameButton setBackgroundImage:[[self.gameButton backgroundImageForState:controlState] resizableImageWithCapInsets:UIEdgeInsetsMake(0.0f, 15.0f, 0.0f, 0.0f)] forState:controlState];
        
        [self.cheatButton setBackgroundImage:[[self.cheatButton backgroundImageForState:controlState] resizableImageWithCapInsets:UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 15.0f)] forState:controlState];
    }];
    
    [self addLongPressGestureRecognizerToButton:self.verifyButton];
    
    [self presentScene];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL) shouldAutorotate
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

#pragma mark - Private

- (void)presentScene
{
    // Pick a size for the scene
    CGSize size = self.skView.bounds.size;

    MSWScene *scene = [MSWScene sceneWithSize:size];

    // Set the scale mode to scale to fit the window
    scene.scaleMode = SKSceneScaleModeAspectFit;

    self.skView.backgroundColor = [SKColor clearColor];

    [self.skView presentScene:scene];

    self.scene = scene;
}

- (void)reset
{
    [self.mineView resetWithNumberOfTilesWide:MSWViewControllerNumberOfTilesWide numberOfTilesHigh:MSWViewControllerNumberOfTilesHigh maximumMines:MSWViewControllerMaximumMines minimumBombToss:30];

    if (!self.winConditionLabel.hidden) {
        self.showWinConditionLabel = NO;
    }
}

- (void)addLongPressGestureRecognizerToButton:(UIButton *)button
{
    UILongPressGestureRecognizer *longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(didTouchHoldVerifyButton:)];
    [longPressGestureRecognizer setMinimumPressDuration:0.5f];
    [button addGestureRecognizer:longPressGestureRecognizer];
}

#pragma mark - Actions

- (IBAction)didTouchNewButton:(UIButton *)newButton
{
    [self reset];
}

- (IBAction)didTouchFlagButton:(UIButton *)flagButton
{
    self.mineView.flag = !self.mineView.flag;
    flagButton.selected = self.mineView.flag;
}

- (IBAction)didTouchDownCheatButton:(UIButton *)cheatButton
{
    [self.mineView showReveal:YES];
}

- (IBAction)didTouchUpCheatButton:(UIButton *)cheatButton
{
    [self.mineView showReveal:NO];
}

- (IBAction)didTouchVerifyButton:(UIButton *)verifyButton
{
    [self.mineView verify];
}

- (IBAction)didTouchHoldVerifyButton:(UIButton *)verifyButton
{
    [self.mineView tossRandomBomb];
}

#pragma mark - <MSWMineViewDelegate>

- (void)mineView:(MSWMineView *)mineView didFinishGameWithWinStatus:(BOOL)winStatus
{
    // already in win state?
    if (self.isShowingWinConditionLabel)
        return;

    NSString *winConditionText = winStatus ? @"WIN!" : @"FAIL!";
    UIColor *winConditionColor = winStatus ? [UIColor greenColor] : [UIColor redColor];
    
    self.winConditionLabel.textColor = winConditionColor;
    self.winConditionLabel.text = winConditionText;
    
    self.showWinConditionLabel = YES;
}

- (void)mineView:(MSWMineView *)mineView didTripMineAtTile:(MSWMineTile *)mineTile
{
    CGPoint centerPointInView = [self.skView convertPoint:mineTile.button.center fromView:self.mineView];
    
    [self.scene explodeMineAtPoint:centerPointInView];

    //[[MSWSoundManager sharedInstance] playExplosion];
}

- (void)mineView:(MSWMineView *)mineView wantTossBombAtMineTile:(MSWMineTile *)mineTile
{
    CGPoint centerPointInView = [self.skView convertPoint:mineTile.button.center fromView:self.mineView];
//    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"MSWTileBombOverlay"]];
//    imageView.center = centerPointInView;
//    [self.skView addSubview:imageView];

    [self.scene tossMineAtPoint:centerPointInView completion:^{
        [mineTile touched];
    }];
}

#pragma mark - [Mutator Overrides]

- (void)setShowWinConditionLabel:(BOOL)showWinConditionLabel
{
    _showWinConditionLabel = showWinConditionLabel;
    
    if (self.winConditionLabel.hidden) {
        self.winConditionLabel.alpha = 0.0f;
        self.winConditionLabel.hidden = NO;
    }

    [UIView animateWithDuration:0.25f delay:0.0f options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.winConditionLabel.alpha = showWinConditionLabel ? 1.0f : 0.0f;
    } completion:^(BOOL finished) {
        self.winConditionLabel.hidden = !showWinConditionLabel;
    }];
    
    [self.gameButtons enumerateObjectsUsingBlock:^(UIButton *button, NSUInteger idx, BOOL *stop) {
        button.enabled = !showWinConditionLabel;
    }];
}

@end
