//
//  MSWMenuViewController.m
//  MineSweeper
//
//  Created by Gregory Carter on 9/7/13.
//  Copyright (c) 2013 Gregory Carter. All rights reserved.
//

#import "MSWMenuViewController.h"

@interface MSWMenuViewController ()
@property (nonatomic, weak) IBOutlet UIButton *createGameButton;
@property (nonatomic, weak) IBOutlet UIButton *rankingButton;
@property (nonatomic, weak) IBOutlet UIButton *helpButton;
@end

@implementation MSWMenuViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Actions

- (IBAction)didTouchUpCreateGameButton:(UIButton *)button
{
}

- (IBAction)didTouchUpRankingButton:(UIButton *)button
{
}

- (IBAction)didTouchUpHelpButton:(UIButton *)button
{
}

@end
