//
//  CostStatViewController.m
//  tripcost
//
//  Created by Andy on 13-3-28.
//  Copyright (c) 2013年 Andy. All rights reserved.
//

#import "AppDelegate.h"
#import "CostStatViewController.h"
#import "EGODatabase/EGODatabase.h"
#import <MessageUI/MFMailComposeViewController.h>
//#import "BiLLInfo.h"
#import "UIColor+Categories.h"
//#import "AppHelper.h"
//#import "UpgradeViewController.h"
//#import "Reachability.h"
//#import "MBProgressHUD.h"
//#import "Base64.h"
#import "ThisVenuesViewController.h"
#import "FSVenue.h"
#import "TableViewCell.h"
#import "AppHelper.h"
#import "Base64.h"

#pragma mark - CostStat
@interface CostStat ()

@end

@implementation CostStat
@synthesize vid,vname,bill;

@end

#pragma mark - CostCategory
@interface CostCategory ()

@end

@implementation CostCategory
@synthesize category,bill;

@end

#pragma mark - CostStatViewController
@interface CostStatViewController ()<MFMailComposeViewControllerDelegate,UIGestureRecognizerDelegate,UIScrollViewDelegate,UIAlertViewDelegate>
{
    CLLocationManager *_locationManager;
}
@end

@implementation CostStatViewController
@synthesize costbillArray,tripid,tripname,billtable,myweb,myweb2,categorybillArray,colors;
@synthesize swipeLeftRecognizer,swipeRightRecognizer,doubleTapRecognizer,tapRecognizer;
@synthesize iap;

#define NORMAL_CELL_HEIGHT 55

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(reloadData)
												 name:kReloadDataNotification
											   object:nil];

    self.totalCostLabel.font = [UIFont fontWithName:@"Avenir Next Condensed" size:20];
    
    self.colors = [NSMutableArray arrayWithObjects:@"#E0E4CC",@"#69D2E7",@"#46BFBD",@"#FDB45C",@"#949FB1",@"#4D5360",@"#D97041",@"#C7604C",@"#9D9B7F",@"#7D4F6D",@"#584A5E",@"#F7464A",@"#F38630",@"#21323D",nil];

    self.totalCostLabel.backgroundColor = [UIColor colorWithHexString:[colors objectAtIndex:0]]; //self.billtable.backgroundColor;
   // self.billtable.separatorColor = [UIColor clearColor];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        [self.mapView setFrame:CGRectInset(self.mapView.frame, 0, -50)];
    }

    
    self.billtable.tableHeaderView = self.mapView;
    self.billtable.tableFooterView = self.totalCostLabel;

    [self reloadData];

    _locationManager = [[CLLocationManager alloc]init];
    _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    _locationManager.delegate = self;
    [_locationManager startUpdatingLocation];
    
}

- (void)reloadData
{
    [self performSelectorInBackground:@selector(loadData) withObject:nil];
}

- (void)loadData
{
    [self loadbill];
    
    [self.billtable reloadData];
    
    [self proccessAnnotations];
}

-(void)setupMapForLocatoion:(CLLocation*)newLocation{
    MKCoordinateRegion region;
    MKCoordinateSpan span;
    span.latitudeDelta = 0.033;
    span.longitudeDelta = 0.033;
    CLLocationCoordinate2D location;
    location.latitude = newLocation.coordinate.latitude;
    location.longitude = newLocation.coordinate.longitude;
    region.span = span;
    region.center = location;
    [self.mapView setRegion:region animated:YES];
}

- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation{
    [_locationManager stopUpdatingLocation];
    [self setupMapForLocatoion:newLocation];
    [self proccessAnnotations];
}

-(void)removeAllAnnotationExceptOfCurrentUser
{
    NSMutableArray *annForRemove = [[NSMutableArray alloc] initWithArray:self.mapView.annotations];
    if ([self.mapView.annotations.lastObject isKindOfClass:[MKUserLocation class]]) {
        [annForRemove removeObject:self.mapView.annotations.lastObject];
    }else{
        for (id <MKAnnotation> annot_ in self.mapView.annotations)
        {
            if ([annot_ isKindOfClass:[MKUserLocation class]] ) {
                [annForRemove removeObject:annot_];
                break;
            }
        }
    }
    
    [self.mapView removeAnnotations:annForRemove];
}

-(void)proccessAnnotations{
    [self removeAllAnnotationExceptOfCurrentUser];
    [self.mapView addAnnotations:self.costbillArray];
}
- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation{
    if (annotation == mapView.userLocation)
        return nil;
    
    static NSString *s = @"ann";
    MKAnnotationView *pin = [mapView dequeueReusableAnnotationViewWithIdentifier:s];
    if (!pin) {
        pin = [[MKPinAnnotationView alloc]initWithAnnotation:annotation reuseIdentifier:s];
        pin.canShowCallout = YES;
      //  pin.image = [UIImage imageNamed:@"map"];
        pin.calloutOffset = CGPointMake(0, 0);
        UIButton *button = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        [button addTarget:self action:@selector(openVenue) forControlEvents:UIControlEventTouchUpInside];
        pin.rightCalloutAccessoryView = button;
        
    }
    return pin;
}

-(void)openVenue{
    
    ThisVenuesViewController *this = [[ThisVenuesViewController alloc] initWithVenues:self.mapView.selectedAnnotations.lastObject];
    AppDelegate *app = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [app.navigationController pushViewController:this animated:YES];
 
}

- (void)loadbill
{
    if (!costbillArray) {
        costbillArray = [[NSMutableArray alloc]init];
    }
    [costbillArray removeAllObjects];
    EGODatabase* database = [EGODatabase databaseWithPath:[NSHomeDirectory() stringByAppendingPathComponent:@"Documents/database.db"]];
    
    //查询所有消费过的地点
    NSString *sqlQuery = [[NSString alloc]initWithFormat:@"select distinct * from places  order by venueid"];
    //NSLog(@"%@",sqlQuery);

    double totalbill = 0.0;
    EGODatabaseResult *result = [database executeQuery:sqlQuery];
    for(EGODatabaseRow* row in result) {
        NSString *venueid = [row stringForColumn:@"venueid"];
        NSString *venuename = [row stringForColumn:@"venuename"];
        NSString *address = [row stringForColumn:@"address"];
        double latitude = [row doubleForColumn:@"latitude"];
        double longitude = [row doubleForColumn:@"longitude"];
        
        FSVenue *ann = [[FSVenue alloc]init];
        ann.name = venuename;
        ann.venueId = venueid;
        
        ann.location.address = address;
        //ann.location.distance = v[@"location"][@"distance"];
        
        [ann.location setCoordinate:CLLocationCoordinate2DMake(latitude,longitude)];
        
        //统计在这个地方的所有花费
        NSString *sqlQuery2 = [[NSString alloc]initWithFormat:@"select sum(bill) from bill where venueid='%@'",venueid];
        //NSLog(@"%@",sqlQuery2);
        EGODatabaseResult *result2 = [database executeQuery:sqlQuery2];
        for(EGODatabaseRow* row2 in result2) {
            double bill = [row2 doubleForColumnIndex:0];
            ann.bill = bill;
            if (bill != 0.0) {
                [self.costbillArray addObject:ann];
            }
            
            totalbill += bill;
        }
    }

    //计算总的消费
    [self.totalCostLabel setText:[NSString stringWithFormat:@"Total Cost: %.2f",totalbill]];

    [database close];
    
    NSString *strResult = [NSString stringWithFormat:@"AppStat:%d|%.1f",self.costbillArray.count,totalbill];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"AppStat" object:strResult]; // -> Analytics Event
}

- (void)viewDidUnload
{
    [self setBilltable:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)updateData
{
    [self.navigationController popViewControllerAnimated:YES];
}

//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
//{
//    return 1;
//}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.costbillArray.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NORMAL_CELL_HEIGHT;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"bill";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
        cell.textLabel.font = [UIFont fontWithName:@"Avenir Next Condensed" size:14];
        cell.textLabel.backgroundColor = cell.contentView.backgroundColor;
		cell.detailTextLabel.font = [UIFont fontWithName:@"Avenir Next Condensed" size:14];
        cell.detailTextLabel.backgroundColor = cell.contentView.backgroundColor;

        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
/*    if (indexPath.row == 0) {
        cell.textLabel.font = [UIFont fontWithName:@"Avenir Next Condensed" size:18];
        cell.textLabel.backgroundColor = cell.contentView.backgroundColor;

        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    else
    {
        cell.textLabel.font = [UIFont fontWithName:@"Avenir Next Condensed" size:14];
        cell.textLabel.backgroundColor = cell.contentView.backgroundColor;

        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    */
    FSVenue *venue = self.costbillArray[indexPath.row];
    cell.textLabel.text = venue.name;

  //  cell.dateTextLabel.text = [NSString stringWithFormat:@"%.2f",venue.bill];
    cell.textLabel.text = venue.name;
    if (venue.location.address) {
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%.2f",venue.bill];
    }
    else
        cell.detailTextLabel.text = @"";
    
    return cell;
}

#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    FSVenue *venue = self.costbillArray[indexPath.row];
    ThisVenuesViewController *this = [[ThisVenuesViewController alloc] initWithVenues:venue];
    AppDelegate *app = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [app.navigationController pushViewController:this animated:YES];
    
    //   [self playsound:1];
    
}


- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end
