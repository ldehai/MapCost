//
//  UIColor+Categories.h
//  tripcost
//
//  Created by andy on 13-5-17.
//  Copyright (c) 2013年 somolo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UIColor(MBCategory)

+ (UIColor *)colorWithHex:(UInt32)col;
+ (UIColor *)colorWithHexString:(NSString *)str;

@end

