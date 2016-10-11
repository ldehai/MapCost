//
//  CostStatViewController.h
//  tripcost
//
//  Created by Andy on 13-3-28.
//  Copyright (c) 2013年 Andy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

@interface CostStat: NSObject
@property (nonatomic, strong) NSString *vid;
@property (nonatomic, strong) NSString *vname;
@property (nonatomic, assign) double bill;
@end

@interface CostCategory: NSObject {
	int category;
	double bill;
}
@property (nonatomic,assign) int category;
@property (nonatomic,assign) double bill;
@end


@class InAppPurchaseManager;
@interface CostStatViewController : UIViewController<CLLocationManagerDelegate>

@property (nonatomic,retain) NSMutableArray *costbillArray;
@property (nonatomic,retain) NSMutableArray *categorybillArray;
@property (nonatomic,retain) NSString *tripid;
@property (nonatomic,retain) NSString *tripname;
@property (retain, nonatomic) UIWebView *myweb;
@property (retain, nonatomic) UIWebView *myweb2;
@property (retain, nonatomic) IBOutlet UITableView *billtable;
@property (strong, nonatomic) IBOutlet MKMapView *mapView;
@property (retain) UITapGestureRecognizer * tapRecognizer;
@property (retain) UITapGestureRecognizer * doubleTapRecognizer;
@property (retain) UISwipeGestureRecognizer * swipeLeftRecognizer;
@property (retain) UISwipeGestureRecognizer * swipeRightRecognizer;
@property (nonatomic,retain)  NSMutableArray *colors;
@property (nonatomic,retain)  InAppPurchaseManager *iap;
@property (strong, nonatomic) IBOutlet UILabel *totalCostLabel;
- (IBAction)back:(id)sender;
- (IBAction)share:(id)sender;
- (void)reloadData;
- (void)sendExportBill;

@end
