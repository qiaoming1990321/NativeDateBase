//
//  UIImage+CBExtension.m
//  CBExtension
//
//  Created by ly on 13-7-7.
//  Copyright (c) 2013年 Lei Yan. All rights reserved.
//

#import "UIImage+CBExtension.h"
#import "FileManager.h"

@implementation UIImage (CBExtension)

- (id)stretchableImage
{
    NSInteger leftCap = (NSInteger)(self.size.width/2);
    NSInteger topCap = (NSInteger)(self.size.height/2);
    return [self stretchableImageWithLeftCapWidth:leftCap topCapHeight:topCap];
}

- (UIImage *)fixOrientation
{
    // No-op if the orientation is already correct
    if (self.imageOrientation == UIImageOrientationUp) return self;
    
    // We need to calculate the proper transformation to make the image upright.
    // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
    CGSize size = [UIImage finalImageSizeWithDestSize:CGSizeMake(ScreenWidth, ScreenHeight) originImg:self];
    CGAffineTransform transform = CGAffineTransformIdentity;
    //iphone UIImageOrientationRight
    NSLog(@"%f %f imageOrientation %zd", self.size.width, self.size.height, self.imageOrientation);
    switch (self.imageOrientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
//            transform = CGAffineTransformTranslate(transform, self.size.width, self.size.height);
            transform = CGAffineTransformTranslate(transform, size.width, size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
//            transform = CGAffineTransformTranslate(transform, self.size.width, 0);
            transform = CGAffineTransformTranslate(transform, size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
//            transform = CGAffineTransformTranslate(transform, 0, self.size.height);
            transform = CGAffineTransformTranslate(transform, 0, size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        case UIImageOrientationUp:
        case UIImageOrientationUpMirrored:
            break;
    }
    
    switch (self.imageOrientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
//            transform = CGAffineTransformTranslate(transform, self.size.width, 0);
            transform = CGAffineTransformTranslate(transform, size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
//            transform = CGAffineTransformTranslate(transform, self.size.height, 0);
            transform = CGAffineTransformTranslate(transform, size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        case UIImageOrientationUp:
        case UIImageOrientationDown:
        case UIImageOrientationLeft:
        case UIImageOrientationRight:
            break;
    }
    // Now we draw the underlying CGImage into a new context, applying the transform
    // calculated above.
    /*
     CGContextRef ctx = CGBitmapContextCreate(NULL, self.size.width,
     self.size.height,
     CGImageGetBitsPerComponent(self.CGImage),
     0,
     CGImageGetColorSpace(self.CGImage),
     CGImageGetBitmapInfo(self.CGImage));
     */
    NSLog(@"%f %f", self.size.width, self.size.height);

    CGContextRef ctx = CGBitmapContextCreate(NULL,
//                                             self.size.width,
//                                             self.size.height,
                                             size.width,
                                             size.height,
                                             8,
                                             0,
                                             CGImageGetColorSpace(self.CGImage),
                                             kCGBitmapByteOrder32Little);
    
    CGContextConcatCTM(ctx, transform);
    switch (self.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            // Grr...
//            CGContextDrawImage(ctx, CGRectMake(0,0,self.size.height,self.size.width), self.CGImage);
            CGContextDrawImage(ctx, CGRectMake(0,0,size.height,size.width), self.CGImage);
            break;
            
        default:
//            CGContextDrawImage(ctx, CGRectMake(0,0,self.size.width,self.size.height), self.CGImage);
            CGContextDrawImage(ctx, CGRectMake(0,0,size.width,size.height), self.CGImage);
            break;
    }
    
    // And now we just create a new UIImage from the drawing context
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;
}

+ (CGSize)finalImageSizeWithDestSize:(CGSize)size originImg:(UIImage*)image
{
    CGSize destSize;
    NSInteger dstWidth = size.width;
    NSInteger dstHeight = size.height;
    CGFloat srcWidth = image.size.width;
    CGFloat srcHeight = image.size.height;
    if (srcWidth <= dstWidth && srcHeight <= dstHeight) {
        return size;
    }
    CGFloat widthRatio = srcWidth / dstWidth;
    CGFloat heightRatio = srcHeight / dstHeight;
    
    if (widthRatio > heightRatio) {
        dstWidth = srcWidth / widthRatio;
        dstHeight = srcHeight / widthRatio;
    }else {
        dstWidth = srcWidth / heightRatio;
        dstHeight = srcHeight / heightRatio;
    }
    destSize.width = dstWidth;
    destSize.height = dstHeight;
    return destSize;
}

+ (UIImage *)cutImageFromImage:(UIImage *)image dstSize:(CGSize)size
{
    CGSize dstSize = [UIImage finalImageSizeWithDestSize:size originImg:image];
    NSInteger dstWidth = dstSize.width;
    NSInteger dstHeight = dstSize.height;
    CGFloat srcWidth = image.size.width;
    CGFloat srcHeight = image.size.height;
    if (srcWidth <= dstWidth && srcHeight <= dstHeight) {
        return image;
    }
    
    CGContextRef ctx = CGBitmapContextCreate(NULL,
                                             dstWidth,
                                             dstHeight,
                                             8,
                                             0,
                                             CGImageGetColorSpace(image.CGImage),
                                             kCGBitmapByteOrder32Little);
    CGContextDrawImage(ctx, CGRectMake(0,0,dstWidth,dstHeight), image.CGImage);
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;
}

+ (UIImage*)scaleImage:(NSString*)originPath
               dstSize:(CGSize)imgSize
           maxFileSize:(long long)maxSize
{
    NSInteger fileSize = [FileManager getFileSizeWithPath:originPath];
    if (fileSize > maxSize) {
        UIImage *image = [UIImage imageWithContentsOfFile:originPath];
        image = [UIImage cutImageFromImage:image dstSize:CGSizeMake(imgSize.width, imgSize.height)];
        NSData *imageData = UIImagePNGRepresentation(image);
        [FileManager deleteFileWithPath:originPath];
        [imageData writeToFile:originPath atomically:YES];
        imageData = nil;
        image = nil;
    
    }
    return [UIImage imageWithContentsOfFile:originPath];
}

+ (BOOL)scaleImage:(UIImage*)originImg
               dstSize:(CGSize)imgSize
           maxFileSize:(long long)maxSize
               dstPath:(NSString*)dstPath
{
    UIImage *image = [originImg copy];
    image = [UIImage cutImageFromImage:image dstSize:CGSizeMake(imgSize.width, imgSize.height)];
    image = [image fixOrientation];
    NSData *imageData = UIImageJPEGRepresentation(image, 1);
//    NSData *imageData = UIImagePNGRepresentation(image);
    [FileManager deleteFileWithPath:dstPath];
//    image = [UIImage imageWithData:imageData];
    
    BOOL ret = [imageData writeToFile:dstPath atomically:YES];
    if (ret) {
        [FileManager addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:dstPath]];
    }
//    debug_Log(@"end end scaleImage %lld", beginTime);
//    NSString *smallDestPath = [NSString stringWithFormat:@"%@%@", dstPath, SmallImageExtension];
//    imageData = UIImageJPEGRepresentation(image, 0.1);
//    [FileManager deleteFileWithPath:smallDestPath];
//    ret = [imageData writeToFile:smallDestPath atomically:YES];
//    debug_Log(@"end end end scaleImage %lld", beginTime);
    image = nil;
    imageData = nil;
    return ret;
}
@end
