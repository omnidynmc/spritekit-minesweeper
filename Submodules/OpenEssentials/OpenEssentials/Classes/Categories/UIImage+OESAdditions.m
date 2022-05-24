//
//  UIImage+OESAdditions.m
//  OpenEssentials
//
//  Created by Gregory Carter on 10/13/12.
//  Copyright (c) 2012 OpenEssentails. All rights reserved.
//

#import "UIImage+OESAdditions.h"

@implementation UIImage (OESAdditions)
- (UIImage *)imageWithOverlayedImage:(UIImage *)image
{
    if (image == nil)
        return self;
    
    CGRect rect = CGRectMake(0.0f, 0.0f, self.size.width, self.size.height);
    
    UIGraphicsBeginImageContextWithOptions(self.size, NO, 0.0f);
    [self drawInRect:rect];
    [image drawInRect:rect];
    image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}


- (UIImage *)imageWithOverlayColor:(UIColor *)color
{
	if (color == nil)
        color = [UIColor grayColor];
	
    CGRect rect = CGRectMake(0.0f, 0.0f, self.size.width, self.size.height);

	CGFloat imageScale = self.scale;
	UIGraphicsBeginImageContextWithOptions(self.size, NO, imageScale);
	
    [self drawInRect:rect];

    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetBlendMode(context, kCGBlendModeSourceIn);

    CGContextSetFillColorWithColor(context, color.CGColor);
    CGContextFillRect(context, rect);

    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return image;
}


- (UIImage *)imageByAppendingImage:(UIImage *)image
{
    CGFloat spacing = 5.0f;

    CGSize newSize = CGSizeMake(self.size.width + spacing + image.size.width,
                                MAX(self.size.height, image.size.height));

    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0f);

    CGPoint drawPoint = CGPointMake(0.0f, truncf((newSize.height - self.size.height) / 2));
    [self drawAtPoint:drawPoint];

    drawPoint = CGPointMake(self.size.width + spacing, truncf((newSize.height - image.size.height) / 2));
    [image drawAtPoint:drawPoint];

    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

- (UIImage *)scaledToSize:(CGSize)newSize
{
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0f);
    [self drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();    
    UIGraphicsEndImageContext();
    return newImage;
}

//- (UIImage *)scaledToSize:(CGSize)newSize
//{
//    // Get size of current image
//    CGSize size = image.size;
//    
//    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
//    
//    // Frame location in view to show original image
//    imageView.frame = CGRectMake(0, 0, size.width, size.height);
//    [self.view addSubview:imageView];
//     
//    // Create rectangle that represents a cropped image  
//    // from the middle of the existing image
//    CGRect rect = CGRectMake(size.width / 4, size.height / 4 , 
//        (size.width / 2), (size.height / 2));
//     
//    // Create bitmap image from original image data,
//    // using rectangle to specify desired crop area
//    CGImageRef imageRef = CGImageCreateWithImageInRect([image CGImage], rect);
//    UIImage *img = [UIImage imageWithCGImage:imageRef]; 
//    CGImageRelease(imageRef);
//     
//    // Create and show the new image from bitmap data
//    imageView = [[UIImageView alloc] initWithImage:img];
//    [imageView setFrame:CGRectMake(0, 200, (size.width / 2), (size.height / 2))];
//    [self.view addSubview:imageView];
//}

- (UIImage *)resizeToSize:(CGSize)newSize thenCropWithRect:(CGRect)cropRect {
    CGContextRef context;
    CGImageRef imageRef;
    CGSize inputSize;
    UIImage *outputImage = nil;
    CGFloat scaleFactor, width;

    // resize, maintaining aspect ratio:
    inputSize = self.size;
    scaleFactor = newSize.height / inputSize.height;
    width = roundf( inputSize.width * scaleFactor );

    if ( width > newSize.width ) {
        scaleFactor = newSize.width / inputSize.width;
        newSize.height = roundf( inputSize.height * scaleFactor );
    } else {
        newSize.width = width;
    }

    UIGraphicsBeginImageContext( newSize );

    context = UIGraphicsGetCurrentContext();
    CGContextDrawImage( context, CGRectMake( 0, 0, newSize.width, newSize.height ), self.CGImage );
    outputImage = UIGraphicsGetImageFromCurrentImageContext();

    UIGraphicsEndImageContext();

    inputSize = newSize;

    // constrain crop rect to legitimate bounds
    if ( cropRect.origin.x >= inputSize.width || cropRect.origin.y >= inputSize.height ) return outputImage;
    if ( cropRect.origin.x + cropRect.size.width >= inputSize.width ) cropRect.size.width = inputSize.width - cropRect.origin.x;
    if ( cropRect.origin.y + cropRect.size.height >= inputSize.height ) cropRect.size.height = inputSize.height - cropRect.origin.y;

    // crop
    if ( ( imageRef = CGImageCreateWithImageInRect( outputImage.CGImage, cropRect ) ) ) {
        outputImage = [[UIImage alloc] initWithCGImage: imageRef];
        CGImageRelease(imageRef);
    }

    return outputImage;
}

@end
