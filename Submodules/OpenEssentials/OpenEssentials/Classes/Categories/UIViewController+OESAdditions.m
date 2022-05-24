//
//  UIViewController+OESAdditions.m
//  OpenEssentials
//
//  Created by Gregory Carter on 10/23/12.
//  Copyright (c) 2012 OpenEssentails. All rights reserved.
//

#import "UIViewController+OESAdditions.h"

@implementation UIViewController (OESAdditions)

- (UIView *)loadViewFromNib:(NSString *)nibName bundle:(NSBundle *)bundle
{
    if (isNil(bundle))
        bundle = [NSBundle mainBundle];

    // store current view
    UIView *savedCurrentView = self.view;

    NSArray *nibs = [bundle loadNibNamed:nibName owner:self options:nil];
    if (isEmpty(nibs)) {
        OESLogError(@"Unable to load nib '%@' in bundle '%@'", nibName, bundle);
        return nil;
    } // if

    self.view = savedCurrentView;

    return [nibs objectAtIndex:0];
}

#pragma mark - Keyboard Handling
#pragma mark -- Abstract

- (void)oesKeyboardWillShowWithFrame:(CGRect)frame duration:(NSTimeInterval)duration
{
    // abstract
}

- (void)oesKeyboardWillHideWithFrame:(CGRect)frame duration:(NSTimeInterval)duration
{
    // abstract
}

#pragma mark -- Notification Registration

- (void)oesRegisterForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(oesKeyboardWillShowHandler:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(oesKeyboardWillHideHandler:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)oesUnregisterForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

#pragma mark -- Notification Handlers

- (void)oesKeyboardWillShowHandler:(NSNotification *)notification
{
    NSDictionary *userInfo = notification.userInfo;
    
    CGRect frame = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    NSTimeInterval duration = [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];

    BOOL isLandscape = UIInterfaceOrientationIsLandscape(self.interfaceOrientation);

    // dumbass frame returned is backwards in landscape
    if (isLandscape)
        frame = CGRectMake(frame.origin.y, frame.origin.x, frame.size.height, frame.size.width);
    
    [self oesKeyboardWillShowWithFrame:frame duration:duration];
}

- (void)oesKeyboardWillHideHandler:(NSNotification *)notification
{
    NSDictionary *userInfo = notification.userInfo;
    
    CGRect frame = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    NSTimeInterval duration = [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];

    BOOL isLandscape = UIInterfaceOrientationIsLandscape(self.interfaceOrientation);

    // dumbass frame returned is backwards in landscape
    if (isLandscape)
        frame = CGRectMake(frame.origin.y, frame.origin.x, frame.size.height, frame.size.width);

    [self oesKeyboardWillHideWithFrame:frame duration:duration];
}

@end
