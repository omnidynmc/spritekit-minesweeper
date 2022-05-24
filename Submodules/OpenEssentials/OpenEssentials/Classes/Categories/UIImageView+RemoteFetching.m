//
//  UIImageView+RemoteFetching.m
//  OpenEssentials
//
//  Created by Gregory Carter on 10/13/12.
//  Copyright (c) 2012 OpenEssentails. All rights reserved.
//

#import "UIImageView+RemoteFetching.h"

@implementation UIImageView (RemoteFetching)

typedef BOOL (^DispatchFetchImageHandler)(UIImage *);

- (void)setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder animationDuration:(NSTimeInterval)duration
{
    self.image = placeholder;
    
    __block UIImageView *safeSelf = self;
    //[safeSelf retain];
    [UIImageView fetchImageWithURL:url preprocessHandler:nil completionHandler:^(UIImage *image) {
		if (image != nil) {
			[safeSelf setImage:image];
		}
	}];
}

+ (void)fetchImageWithURL:(NSURL *)url preprocessHandler:(FetchImagePreprocessHandler)preprocessHandler completionHandler:(FetchImageCompletionHandler)completionHandler
{
    if (url == nil || [[url absoluteString] length] < 1) {
        OESLogInfo(@"A nil or empty URL was passed to fetchImageWithURL:preprocessingHandler:completionHandler:");
        return;
    }
	
    NSString *urlString = [url absoluteString];
    NSString *imageFilename = [urlString lastPathComponent];
    NSString *bundlePath = [[NSBundle mainBundle] pathForResource:imageFilename ofType:nil];
	
    DispatchFetchImageHandler dispatchFetchImageHandler = ^(UIImage *image) {
        if (image == nil) {
            return NO;
        }
        
        if (preprocessHandler) {
            UIImage *replaceImage = preprocessHandler(image);
            image = replaceImage;
        }
		
        if (completionHandler) {
            dispatch_async(dispatch_get_main_queue(), ^{ completionHandler(image); });
        }
        
        return YES;
    };
    
    dispatch_queue_t backgroundQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0);
    
    if (bundlePath != nil) {
        dispatch_async(backgroundQueue, ^{
            // in bundle, set
            UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfFile:bundlePath]];
            dispatchFetchImageHandler(image);
        });
    }
    else {
		dispatch_async(backgroundQueue, ^{
            UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:url]];
            dispatchFetchImageHandler(image);
        });
    }
}

+ (void)fetchImageCacheWithURL:(NSURL *)url preprocessHandler:(FetchImagePreprocessHandler)preprocessHandler completionHandler:(FetchImageCompletionHandler)completionHandler
{
    static NSCache *ImageCache = nil;
    
    if (ImageCache == nil) {
        ImageCache = [[NSCache alloc] init];
    }
    
    if (url == nil || [[url absoluteString] length] < 1) {
        OESLogDebug(@"A nil or empty URL was passed to fetchImageWithURL:preprocessingHandler:completionHandler:");
        return;
    }
	   
    NSString *urlString = [url absoluteString];
    NSString *imageFilename = [urlString lastPathComponent];
    NSString *bundlePath = [[NSBundle mainBundle] pathForResource:imageFilename ofType:nil];
    NSString *cacheKey = [url absoluteString];
    BOOL foundInCache = NO;
    
    DispatchFetchImageHandler dispatchFetchImageHandler = ^(UIImage *image) {
        if (image == nil) {
            return NO;
        }
        
        if (preprocessHandler) {
            UIImage *replaceImage = preprocessHandler(image);
            image = replaceImage;
        }

        if (foundInCache == NO) {
            [ImageCache setObject:image forKey:cacheKey];
        }
		
        if (completionHandler) {
            dispatch_async(dispatch_get_main_queue(), ^{ completionHandler(image); });
        }

        return YES;
    };
    
    UIImage *image = [ImageCache objectForKey:cacheKey];

    if (image != nil) {
        dispatchFetchImageHandler(image);
        return;
    }

    dispatch_queue_t backgroundQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0);
    
    if (bundlePath != nil) {
        dispatch_async(backgroundQueue, ^{
            // in bundle, set
            UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfFile:bundlePath]];
            dispatchFetchImageHandler(image);
        });
    }
    else {
		dispatch_async(backgroundQueue, ^{
            UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:url]];
            dispatchFetchImageHandler(image);
        });
    }
}

- (void)overlayWithColor:(UIColor *)color
{
    if (color == nil)
        color = [UIColor grayColor];
    
    CGRect rect = CGRectMake(0.0f, 0.0f, self.image.size.width, self.image.size.height);
    
    UIGraphicsBeginImageContextWithOptions(self.image.size, NO, 0.0f);
    [self.image drawInRect:rect];
	
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetBlendMode(context, kCGBlendModeSourceIn);
	
    CGContextSetFillColorWithColor(context, color.CGColor);
    CGContextFillRect(context, rect);
    
    self.image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
}


// Updates the image by fading from the current image to the new image.
- (void)setImage:(UIImage *)newImage duration:(NSTimeInterval)duration
{
    if (duration < 0.01f) {
        [self setImage:newImage];
        return;
    }
	
	// Create a view that looks like the current image view to fade out.
    UIImageView *fadeOutImageView = [[UIImageView alloc] initWithImage:self.image];
    fadeOutImageView.frame = self.frame;
    fadeOutImageView.clipsToBounds = self.clipsToBounds;
    fadeOutImageView.autoresizingMask = self.autoresizingMask;
    fadeOutImageView.contentMode = self.contentMode;
    fadeOutImageView.opaque = self.opaque;
    fadeOutImageView.alpha = self.alpha;
    [self.superview insertSubview:fadeOutImageView aboveSubview:self];
	
    CGFloat originalAlpha = self.alpha;
    self.image = newImage;
    self.alpha = 0.0f;
	
	// Animate the fade-in/out.
    [UIView animateWithDuration:duration
                          delay:0.0f
                        options:UIViewAnimationOptionCurveLinear
                     animations:^ {
                         self.alpha = originalAlpha;
                         fadeOutImageView.alpha = 0.0f;
                     }
                     completion:^(BOOL finished) {
                         [fadeOutImageView removeFromSuperview];
                     }];
}


@end
