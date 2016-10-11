//
//  DateBill.h
//  trip
//
//  Created by Andy on 13-3-20.
//  Copyright (c) 2013年 souxiang. All rights reserved.
//

#import <Foundation/Foundation.h>

@class BiLLInfo;

@interface DateBill : NSObject {
	NSString *date;
	NSMutableArray *bills;
}

@property (nonatomic, copy) NSString *date;
@property (nonatomic, retain) NSMutableArray *bills;
- (id)initWithDate:(NSString *)dateString;
- (void)addbill:(BiLLInfo*)bill;

@end