//
//  MyAnnotation.h
//  MapCost
//
//  Created by andy on 13-11-13.
//  Copyright (c) 2013年 AM Studio. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MKAnnotation.h>

@interface MyAnnotation : NSObject <MKAnnotation>

@property (nonatomic) CLLocationCoordinate2D coordinate;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *subtitle;

- (id)initWithLocation:(CLLocationCoordinate2D)coord;

@end
