//
//  BiLLInfo.m
//  trip
//
//  Created by Andy on 13-3-7.
//  Copyright (c) 2013年 souxiang. All rights reserved.
//

#import "BiLLInfo.h"

@implementation BiLLInfo

@synthesize billid,bill,tag,date,comment,venueId,venueName,imagepath;

-(id)init
{
    if (self = [super init]) {
                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
        [dateFormatter setTimeStyle:NSDateFormatterMediumStyle];
        [dateFormatter setDateFormat:@"yyyyMMddHHmmss"];
        NSString *timestamp = [dateFormatter stringFromDate:[NSDate date]];

		self.billid = timestamp;
        
        NSDate *today = [NSDate date];
        [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
        self.date = [dateFormatter stringFromDate:today];
        
        self.tag = @"";
	}
    
	return self;
}
@end
