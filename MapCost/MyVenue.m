//
//  MyVenue.m
//  MapCost
//
//  Created by andy on 13-11-14.
//  Copyright (c) 2013年 AM Studio. All rights reserved.
//

#import "MyVenue.h"

@implementation MyVenue

- (id)init
{
    self = [super init];
    if (self) {
        self.location = [[FSLocation alloc]init];
    }
    return self;
}

-(CLLocationCoordinate2D)coordinate{
    return self.location.coordinate;
}

- (void)setCoordinate:(CLLocationCoordinate2D)cord
{
    self.location.coordinate = cord;
    
    if ([self.delegate respondsToSelector:@selector(updateVenueCoordinate:withVenueid:)]) {
        [self.delegate updateVenueCoordinate:cord withVenueid:self.venueId];
    }
}

-(NSString*)title{
    return self.name;
}

@end
