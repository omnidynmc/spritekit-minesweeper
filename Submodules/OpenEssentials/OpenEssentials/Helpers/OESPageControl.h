//
//  OESPageControl.h
//  OpenEssentials
//
//  Created by Gregory Carter on 3/12/13.
//  Copyright (c) 2013 OpenEssentails. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OESPageControl : UIControl
@property (nonatomic, strong) UIImage *oesCurrentPageImage;
@property (nonatomic, strong) UIImage *inactivePageImage;
@property (nonatomic, strong) UIImage *firstPageImage;
@property (nonatomic, strong) UIImage *inactiveFirstPageImage;
@property (nonatomic, assign) CGFloat dotSpacing;
@property (nonatomic, assign) NSInteger numberOfPages;
@property (nonatomic, assign) NSInteger currentPage;
@property (nonatomic, assign) BOOL hidesForSinglePage;
@end
