//
//  UIColor+UIColor_Extension.m
//  XesSpeiyouSystemClient
//
//  Created by 寇永赞 on 13-3-19.
//  Copyright (c) 2013年 XueErSi. All rights reserved.
//

#import "UIColor+Extension.h"

@implementation UIColor (Extension)

+(UIColor *) colorWithHexString:(NSString *)hexString {
    NSString *cleanString = [hexString stringByReplacingOccurrencesOfString:@"#" withString:@""];
    if([cleanString length] == 3) {
        cleanString = [NSString stringWithFormat:@"%@%@%@%@%@%@",
                       [cleanString substringWithRange:NSMakeRange(0, 1)],[cleanString substringWithRange:NSMakeRange(0, 1)],
                       [cleanString substringWithRange:NSMakeRange(1, 1)],[cleanString substringWithRange:NSMakeRange(1, 1)],
                       [cleanString substringWithRange:NSMakeRange(2, 1)],[cleanString substringWithRange:NSMakeRange(2, 1)]];
    }
    if([cleanString length] == 6) {
        cleanString = [cleanString stringByAppendingString:@"ff"];
    }
    
    unsigned baseValue;
    [[NSScanner scannerWithString:cleanString] scanHexInt:&baseValue];
    
    CGFloat red = ((baseValue >> 24) & 0xFF)/255.0f;
    CGFloat green = ((baseValue >> 16) & 0xFF)/255.0f;
    CGFloat blue = ((baseValue >> 8) & 0xFF)/255.0f;
    CGFloat alpha = ((baseValue >> 0) & 0xFF)/255.0f;
    
    return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
}

@end
