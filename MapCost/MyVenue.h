//
//  MyVenue.h
//  MapCost
//
//  Created by andy on 13-11-14.
//  Copyright (c) 2013年 AM Studio. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FSVenue.h"

@protocol MyVenueDelegate <NSObject>

- (void)updateVenueCoordinate:(CLLocationCoordinate2D)cord withVenueid:(NSString*)vid;

@end
@interface MyVenue : FSVenue <MKAnnotation>
//
//@property (nonatomic,strong)NSString*name;
//@property (nonatomic,strong)NSString*venueId;
//@property (nonatomic,strong)FSLocation*location;
//@property (nonatomic,assign) double bill;
@property (nonatomic,weak) id<MyVenueDelegate> delegate;

@end
