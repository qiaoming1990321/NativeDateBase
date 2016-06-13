//
//  NSString+Extension.m
//  CBExtension
//
//  Created by ly on 13-6-29.
//  Copyright (c) 2013年 Lei Yan. All rights reserved.
//

#import "NSString+Extension.h"
#import "NSObject+ObjectEmpty.h"

@implementation NSString (Extension)

#pragma mark - Regular expression
- (NSMutableArray *)itemsForPattern:(NSString *)pattern
{
    return [self itemsForPattern:pattern captureGroupIndex:0];
}

- (NSMutableArray *)itemsForPattern:(NSString *)pattern captureGroupIndex:(NSUInteger)index
{
    if ( !pattern )
        return nil;
    
    NSError *error = nil;
    NSRegularExpression *regx = [[NSRegularExpression alloc] initWithPattern:pattern
        options:NSRegularExpressionCaseInsensitive error:&error];
    if (error)
    {
        NSLog(@"Error for create regular expression:\nString: %@\nPattern %@\nError: %@\n",self, pattern, error);
    }
    else
    {
        NSMutableArray *results = [[NSMutableArray alloc] init];
        NSRange searchRange = NSMakeRange(0, [self length]);
        [regx enumerateMatchesInString:self options:0 range:searchRange usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
            
            NSRange groupRange =  [result rangeAtIndex:index];
            NSString *match = [self substringWithRange:groupRange];
            [results addObject:match];
        }];
        return results;
    }
    
    [regx release];
    return nil;
}

- (NSString *)itemForPatter:(NSString *)pattern
{
    return [self itemForPattern:pattern captureGroupIndex:0];
}

- (NSString *)itemForPattern:(NSString *)pattern captureGroupIndex:(NSUInteger)index
{
    if ( !pattern )
        return nil;
    
    NSError *error = nil;
    NSRegularExpression *regx = [[NSRegularExpression alloc] initWithPattern:pattern
        options:NSRegularExpressionCaseInsensitive error:&error];
    if (error)
    {
        NSLog(@"Error for create regular expression:\nString: %@\nPattern %@\nError: %@\n",self, pattern, error);
    }
    else
    {
        NSRange searchRange = NSMakeRange(0, [self length]);
        NSTextCheckingResult *result = [regx firstMatchInString:self options:0 range:searchRange];
        NSRange groupRange = [result rangeAtIndex:index];
        NSString *match = [self substringWithRange:groupRange];
        [regx release];
        return match;
    }
    
    [regx release];
    return nil;
}

#pragma mark - Time Interval
- (NSTimeInterval)timeIntervalFromString:(NSString *)timeString withDateFormat:(NSString *)format
{
    NSDateFormatter *formatter = [[[NSDateFormatter alloc] init]autorelease];
    [formatter setDateFormat:format];
    return [[formatter dateFromString:timeString] timeIntervalSince1970];
}

- (NSTimeInterval)localTimeIntervalFromString:(NSString *)timeString withDateFormat:(NSString *)format
{
    NSTimeInterval timeInterval = [self timeIntervalFromString:timeString withDateFormat:format];
    NSUInteger secondsOffset = [[NSTimeZone localTimeZone] secondsFromGMT];
    return (timeInterval + secondsOffset);
}

#pragma mark - Contains
- (BOOL)contains:(NSString *)piece
{
    return ( [self rangeOfString:piece].location != NSNotFound );
}

- (NSString *)trim
{
    return [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

+ (BOOL)isBlankString:(NSString *)string {
    BOOL result = NO;
    
    if (NULL == string || [string isEqual:nil] || [string isEqual:Nil])
    {
        result = YES;
    }
    else if ([string isEqual:[NSNull null]])
    {
        result = YES;
    }
    else if (0 == [string length] || 0 == [[string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length])
    {
        result = YES;
    }
    else if([string isEqualToString:@"(null)"])
    {
        result = YES;
    }
    
    return result;
}

+ (NSString*)safeString:(id)string
{
    if([string isKindOfClass:[NSNumber class]])
    {
        NSNumber *num = (NSNumber *)string;
        return num.stringValue;
    }
    else if ([NSObject empty:string] || [string isEqualToString:@"null"] || [string isEqualToString:@"<null>"]) {
        return @"";
    }
    
    return [NSString stringWithFormat:@"%@", string];
}

- (NSComparisonResult)sortedKeys:(NSString*)key
{
    return NSOrderedDescending;
}

- (BOOL)localVersionAboveServer:(NSString*)serverVersion
{
    NSArray *localArray = [self componentsSeparatedByString:@"."];
    NSArray *serverArray = [serverVersion componentsSeparatedByString:@"."];
    for (NSInteger i = 0; i < [serverArray count]; i++) {
        NSInteger serverValue = [[serverArray objectAtIndex:i] integerValue];
        NSInteger localValue = [[localArray objectAtIndex:i] integerValue];
        if (serverValue > localValue) {
            return NO;
        }else if (serverValue < localValue) {
            return YES;
        }
    }
    return NO;
}
@end
