//
//  NSObject+ObjectEmpty.m
//  XesSpeiyouSystemClient
//
//  Created by zhouyan on 13-3-1.
//  Copyright (c) 2013年 XueErSi. All rights reserved.
//

#import "NSObject+ObjectEmpty.h"
#import "NSString+Extension.h"

@implementation NSObject (ObjectEmpty)
+ (BOOL)empty:(NSObject *)o{
	if (o==nil) {
		return YES;
	}
	if (o==NULL) {
		return YES;
	}
	if (o==[NSNull new]) {
		return YES;
	}
	if ([o isKindOfClass:[NSString class]]) {
		return [NSString isBlankString:(NSString *)o];
	}
	if ([o isKindOfClass:[NSData class]]) {
		return [((NSData *)o) length]<=0;
	}
	if ([o isKindOfClass:[NSDictionary class]]) {
		return [((NSDictionary *)o) count]<=0;
	}
	if ([o isKindOfClass:[NSArray class]]) {
		return [((NSArray *)o) count]<=0;
	}
	if ([o isKindOfClass:[NSSet class]]) {
		return [((NSSet *)o) count]<=0;
	}
	return NO;
}
@end
