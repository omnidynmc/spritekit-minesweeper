//
//  UIViewController+OESAdditions.h
//  OpenEssentials
//
//  Created by Gregory Carter on 10/23/12.
//  Copyright (c) 2012 OpenEssentails. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (OESAdditions)
- (UIView *)loadViewFromNib:(NSString *)nibName bundle:(NSBundle *)bundle;
// Keyboard
// -- Notification Registration
- (void)oesRegisterForKeyboardNotifications;
- (void)oesUnregisterForKeyboardNotifications;
// -- Abstract
- (void)oesKeyboardWillHideWithFrame:(CGRect)frame duration:(NSTimeInterval)duration;
- (void)oesKeyboardWillShowWithFrame:(CGRect)frame duration:(NSTimeInterval)duration;
@end
