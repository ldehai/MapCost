//
//  MyAnnotation.m
//  MapCost
//
//  Created by andy on 13-11-13.
//  Copyright (c) 2013年 AM Studio. All rights reserved.
//

#import "MyAnnotation.h"

@implementation MyAnnotation

- (id)initWithLocation:(CLLocationCoordinate2D)coord {
    self = [super init];
    if (self) {
        self.coordinate = coord;
    }
    return self;
}
@end
