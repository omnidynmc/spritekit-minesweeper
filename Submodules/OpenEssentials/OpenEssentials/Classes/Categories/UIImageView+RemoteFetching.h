//
//  UIImageView+RemoteFetching.h
//  OpenEssentials
//
//  Created by Gregory Carter on 10/13/12.
//  Copyright (c) 2012 OpenEssentails. All rights reserved.
//
#import <UIKit/UIKit.h>

typedef void (^FetchImageCompletionHandler)(UIImage *);
typedef UIImage *(^FetchImagePreprocessHandler)(UIImage *);

@interface UIImageView (RemoteFetching)

+ (void)fetchImageWithURL:(NSURL *)url preprocessHandler:(FetchImagePreprocessHandler)preprocessHandler completionHandler:(FetchImageCompletionHandler)completionHandler;
+ (void)fetchImageCacheWithURL:(NSURL *)url preprocessHandler:(FetchImagePreprocessHandler)preprocessHandler completionHandler:(FetchImageCompletionHandler)completionHandler;

- (void)setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder animationDuration:(NSTimeInterval)duration;
- (void)overlayWithColor:(UIColor *)color;
- (void)setImage:(UIImage *)newImage duration:(NSTimeInterval)duration;

@end
