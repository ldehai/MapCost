//
//  AppDelegate.h
//  MapCost
//
//  Created by andy on 13-8-15.
//  Copyright (c) 2013年 AM Studio. All rights reserved.
//

#import <UIKit/UIKit.h>

@class NearbyVenuesViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, retain) UINavigationController *navigationController;
@property (strong, nonatomic) NearbyVenuesViewController *viewController;
@property(nonatomic,retain)NSArray *arrayCategory;
@property(nonatomic,retain)NSArray *arrayCategoryImg;
@property (nonatomic,strong) UIView *containView;

@end
