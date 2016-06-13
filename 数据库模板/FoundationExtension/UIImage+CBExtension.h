//
//  UIImage+CBExtension.h
//  CBExtension
//
//  Created by ly on 13-7-7.
//  Copyright (c) 2013年 Lei Yan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (CBExtension)

/*** 返回可拉伸的图片 */
- (UIImage *)stretchableImage;
//修正旋转问题
- (UIImage *)fixOrientation;
//缩小图片:image 原图片  size缩放目标尺寸
+ (UIImage *)cutImageFromImage:(UIImage *)image dstSize:(CGSize)size;
+ (UIImage*)scaleImage:(NSString*)originPath
               dstSize:(CGSize)imgSize
           maxFileSize:(long long)maxSize;
+ (BOOL)scaleImage:(UIImage*)originImg
           dstSize:(CGSize)imgSize
       maxFileSize:(long long)maxSize
           dstPath:(NSString*)dstPath;
@end
