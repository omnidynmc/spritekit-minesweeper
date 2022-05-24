//
//  OESContainmentViewController.h
//  OpenEssentials
//
//  Created by Gregory Carter on 9/7/13.
//  Copyright (c) 2013 OpenEssentails. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol OESContainmentChildViewController <NSObject>
@optional
- (id)initWithObject:(id)object;
@end

@interface OESContainmentViewController : UIViewController
@property (nonatomic, strong, readonly) UIViewController<OESContainmentChildViewController> *selectedViewController;
// -- Abstract
- (NSArray *)viewControllerClassNames;
- (NSArray *)containmentViewControllers;
- (NSUInteger)numberOfViewControllers;
- (UIViewController *)viewControllerAtIndex:(NSUInteger)index;
- (void)selectViewControllerAtIndex:(NSUInteger)index;
- (void)selectedViewController:(UIViewController<OESContainmentChildViewController> *)viewController index:(NSUInteger)index;
@end
