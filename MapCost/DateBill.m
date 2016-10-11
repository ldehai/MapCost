//
//  DateBill.m
//  trip
//
//  Created by Andy on 13-3-20.
//  Copyright (c) 2013年 souxiang. All rights reserved.
//

#import "DateBill.h"
#import "BiLLInfo.h"

@interface DateBill (Private)
- (id)initWithDate:(NSString *)dateString;
@end


@implementation DateBill

@synthesize date,bills;

#pragma mark -
#pragma mark DateBill.
- (void)dealloc {
	[date release];
    
	[super dealloc];
}

- (id)initWithDate:(NSString *)dateString {
	
	if (self = [super init]) {
		date = [dateString copy];
        bills = [[NSMutableArray alloc] init];
	}
	return self;
}

- (void)addbill:(BiLLInfo*)bill
{
    [bills insertObject:bill atIndex:0];
}
@end
