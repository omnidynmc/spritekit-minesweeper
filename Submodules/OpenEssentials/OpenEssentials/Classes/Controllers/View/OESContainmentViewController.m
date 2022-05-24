//
//  OESContainmentViewController.m
//  OpenEssentials
//
//  Created by Gregory Carter on 9/7/13.
//  Copyright (c) 2013 OpenEssentails. All rights reserved.
//

#import "OESContainmentViewController.h"

#import "NSDictionary+OESAdditions.h"

@interface OESContainmentViewController ()
// Data Structures
@property (nonatomic, strong, readwrite) NSMutableArray *viewControllers;
@property (nonatomic, strong, readwrite) UIViewController<OESContainmentChildViewController> *selectedViewController;

@end

@implementation OESContainmentViewController

#pragma mark -- Abstract


- (NSArray *)viewControllerClassNames
{
    return @[
    ];
}


- (NSUInteger)numberOfViewControllers
{
    return [self.viewControllers count];
}


- (UIViewController *)viewControllerAtIndex:(NSUInteger)index
{
    if (index >= self.viewControllers.count) {
        return nil;
    }
    
    id object = self.viewControllers[index];
    
    UIViewController *viewController;
    
    id classNamesObject = self.viewControllerClassNames[index];

    NSString *className;
    id classObject;
    
    BOOL hasObjectInit = NO;
    BOOL wrapInNavigationController = NO;
    if ([classNamesObject isKindOfClass:[NSDictionary class]]) {
        NSDictionary *classDictionary = classNamesObject;
        className = [classDictionary stringForKey:@"className"];
        classObject = [classDictionary objectForKey:@"object"];
        
        NSNumber *wrapInNavigationNumber = [classDictionary numberForKey:@"wrapInNavigationController"];
        
        wrapInNavigationController = wrapInNavigationNumber != nil ? ([wrapInNavigationNumber integerValue] == 1) : NO;

        hasObjectInit = YES;
    }
    else if ([classNamesObject isKindOfClass:[NSString class]]) {
        className = (NSString *)classNamesObject;
    }

    if (className == nil) {
        // We can't continue if we don't know how to handle the view controllers; this is a programmer error and means you either didn't pass back an NSString with the class name or a dictionary with className defined.
        @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:[NSString stringWithFormat:@"viewControllerClassNames object returned unknown '%s' on line %d", __PRETTY_FUNCTION__, __LINE__] userInfo:nil];
    }
    
    Class class = NSClassFromString(className);
    
    BOOL needsViewController = object == [NSNull null] || ![object isKindOfClass:class];
    if (needsViewController) {
        BOOL classResponds = [class instancesRespondToSelector:@selector(initWithObject:)];
        if (hasObjectInit && classResponds) {
            viewController = [[class alloc] initWithObject:classObject];
        }
        else {
            viewController = [class new];
        }
        self.viewControllers[index] = viewController;
    }
    else {
        viewController = object;
    }
    
    
    if (wrapInNavigationController) {
        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:viewController];
        return navigationController;
    }
    
    return viewController;
}


- (void)selectViewControllerAtIndex:(NSUInteger)index
{
    UIViewController<OESContainmentChildViewController> *viewController = (UIViewController<OESContainmentChildViewController> *)[self viewControllerAtIndex:index];

    BOOL needsViewControllerChange = viewController != nil && viewController != self.selectedViewController;
    if (!needsViewControllerChange) {
        return;
    }
        
    [self selectedViewController:viewController index:index];

    self.selectedViewController = viewController;
}


- (void)selectedViewController:(UIViewController *)viewController index:(NSUInteger)index
{
    // abstract
}


- (NSArray *)containmentViewControllers
{
    return [NSArray arrayWithArray:self.viewControllers];
}


#pragma mark - [Accessor Overrides]


- (NSMutableArray *)viewControllers
{
    NSUInteger numberOfViewControllerClassNames = [self.viewControllerClassNames count];
    BOOL shouldReload = _viewControllers == nil || numberOfViewControllerClassNames != [_viewControllers count];
    if (!shouldReload) {
        return _viewControllers;
    }
    
    NSUInteger max = [[self viewControllerClassNames] count];
    if (_viewControllers == nil) {
        _viewControllers = [[NSMutableArray alloc] initWithCapacity:max];
    }
    else if ([_viewControllers count] > numberOfViewControllerClassNames) {
        while(_viewControllers.count > numberOfViewControllerClassNames) {
            [_viewControllers removeLastObject];
        }
    }
    
    
    for (NSUInteger index = 0; index < max; ++index) {
        BOOL isAlreadyPopulated = [_viewControllers count] > index;
        if (isAlreadyPopulated) {
            // avoid destroying a view controller that is already there from a reload
            continue;
        }

        _viewControllers[index] = [NSNull null];
    }
    
    return _viewControllers;
}

@end
