//
//  BiLLInfo.h
//  trip
//
//  Created by Andy on 13-3-7.
//  Copyright (c) 2013年 souxiang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BiLLInfo : NSObject

@property (nonatomic,strong) NSString *billid;
@property (nonatomic,assign) double bill;
@property (nonatomic,strong) NSString *tag;
@property (nonatomic,strong) NSString *date;
@property (nonatomic,strong) NSString *comment;
@property (nonatomic,strong) NSString *venueId;
@property (nonatomic,strong) NSString *venueName;
@property (nonatomic,strong) NSString *imagepath;

@end
