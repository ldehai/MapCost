//
//  ThisVenuesViewController.m
//
//  Created by Andy on 2013-08-18.
//
//

#import "ThisVenuesViewController.h"
#import "Foursquare2.h"
#import "FSVenue.h"
#import "FSConverter.h"
#import "AddBillViewController.h"
#import "EGODatabase.h"
#import "BiLLInfo.h"
#import "CostStatViewController.h"
#import "TableViewCell.h"
#import "UIColor+Categories.h"
#import "UIImage+fixOrientation.h"
#import "MyVenue.h"

@interface ThisVenuesViewController ()<AddBillDelegate,RMSwipeTableViewCellDelegate,UIAlertViewDelegate>
{
    AddBillViewController *addbillView;
    UIView *dimBackgroundView;
    FSVenue *currentVenue;
    //id <MKAnnotation> currentVenue;
    NSMutableArray *billArray;
    double totalCost;
}
@end

@implementation ThisVenuesViewController

- (id)initWithVenues:(FSVenue*) venue
{
    self = [super init];
    if (self) {
        currentVenue = venue;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self addNavigationButton];
    
//    self.tableView.separatorColor = [UIColor clearColor];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        [self.mapView setFrame:CGRectInset(self.mapView.frame, 0, -60)];
    }

    self.tableView.tableHeaderView = self.mapView;

    self.totalCostLabel.font = [UIFont fontWithName:@"Avenir Next Condensed" size:20];
    
    self.colors = [NSMutableArray arrayWithObjects:@"#E0E4CC",@"#69D2E7",@"#46BFBD",@"#FDB45C",@"#949FB1",@"#4D5360",@"#D97041",@"#C7604C",@"#9D9B7F",@"#7D4F6D",@"#584A5E",@"#F7464A",@"#F38630",@"#21323D",nil];
    
//    self.totalCostLabel.backgroundColor = [UIColor colorWithHexString:[self.colors objectAtIndex:0]]; //
    self.tableView.tableFooterView = self.tableFooter;
    
//    self.tableView.tableFooterView = self.footer;
    _locationManager = [[CLLocationManager alloc]init];
    _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    _locationManager.delegate = self;
    [_locationManager startUpdatingLocation];
    
    [self setTitle:currentVenue.name];
    [self loadBillWithVenueId:currentVenue.venueId];
//
//    if ([currentVenue isKindOfClass:[MyVenue class]])
//    {
//        MyVenue *ann = (MyVenue*)currentVenue;
//        [self setTitle:ann.name];
//        [self loadBillWithVenueId:ann.venueId];
//    }
//    else
//    {
//        FSVenue *ann = (FSVenue*)currentVenue;
//        [self setTitle:ann.name];
//        [self loadBillWithVenueId:ann.venueId];
//    }

    
}

- (void)setTitle:(NSString *)title
{
    [super setTitle:title];
    UILabel *titleView = (UILabel *)self.navigationItem.titleView;
    if (!titleView) {
        titleView = [[UILabel alloc] initWithFrame:CGRectZero];
        titleView.backgroundColor = [UIColor clearColor];
        titleView.font = [UIFont fontWithName:@"Avenir-Book" size:16];
        titleView.textColor = [UIColor blackColor]; // Change to desired color
        
        self.navigationItem.titleView = titleView;
    }
    titleView.text = title;
    [titleView sizeToFit];
}

-(void)addNavigationButton{
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setShowsTouchWhenHighlighted:TRUE];
    [btn setImage:[UIImage imageNamed:@"back@2x.png"] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(goback:) forControlEvents:UIControlEventTouchDown];
    [btn setFrame:CGRectMake(20, 0, 30, 25)];
    
    UIBarButtonItem *barbtn = [[UIBarButtonItem alloc] initWithCustomView:btn];
    [barbtn setBackgroundImage:[UIImage new] forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    self.navigationItem.leftBarButtonItem = barbtn;
    
    btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setShowsTouchWhenHighlighted:TRUE];
    [btn setImage:[UIImage imageNamed:@"trash@2x.png"] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(deleteVenueBill) forControlEvents:UIControlEventTouchUpInside];
    [btn setFrame:CGRectMake(0, 0, 20, 25)];
    barbtn = [[UIBarButtonItem alloc] initWithCustomView:btn];
    self.navigationItem.rightBarButtonItem = barbtn;
}

- (void)deleteVenueBill
{
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:@"Delete All Bills At This Venue?" delegate:nil cancelButtonTitle:@"YES" otherButtonTitles:@"NO",nil];
    alert.delegate = self;
    
    [alert show];
    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        [self deleteVenueBillCommit];
    }
}

- (void)deleteVenueBillCommit
{
    EGODatabase* database = [EGODatabase databaseWithPath:[NSHomeDirectory() stringByAppendingPathComponent:@"Documents/database.db"]];
    
    NSString *sqlQuery = [[NSString alloc]initWithFormat:@"select billid,imagepath,bill from bill where venueid = '%@' order by billid desc",currentVenue.venueId];
    //NSLog(@"%@",sqlQuery);
    
    EGODatabaseResult *result = [database executeQuery:sqlQuery];
    for(EGODatabaseRow* row in result) {
        NSString *billid = [row stringForColumn:@"billid"];
        NSString *imagepath = [row stringForColumn:@"imagepath"];
        
        //删除账单
        NSString *sqlDelete = [[NSString alloc]initWithFormat:@"delete from bill where billid='%@'",billid];
        [database executeQuery:sqlDelete];
        
        //删除相关图片
        NSString *pngPath = [NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"Documents/%@", imagepath]];
        NSFileManager *filemanager = [NSFileManager defaultManager];
        [filemanager removeItemAtPath:pngPath error:nil];
    }
    
    [self loadBillWithVenueId:currentVenue.venueId];
}
-(void)loadBillWithVenueId:(NSString*)venueId
{
    if (!billArray) {
        billArray = [[NSMutableArray alloc]init];
    }
    [billArray removeAllObjects];
    
    EGODatabase* database = [EGODatabase databaseWithPath:[NSHomeDirectory() stringByAppendingPathComponent:@"Documents/database.db"]];
    
    NSString *sqlQuery = [[NSString alloc]initWithFormat:@"select billid,date,comment,imagepath,bill from bill where venueid = '%@' order by billid desc",venueId];
    //NSLog(@"%@",sqlQuery);
    
    totalCost = 0.0;
    EGODatabaseResult *result = [database executeQuery:sqlQuery];
    for(EGODatabaseRow* row in result) {
        NSString *billid = [row stringForColumn:@"billid"];
        NSString *date = [row stringForColumn:@"date"];
        NSString *comment = [row stringForColumn:@"comment"];
        NSString *imagepath = [row stringForColumn:@"imagepath"];
        double bill = [row doubleForColumn:@"bill"];
        
        BiLLInfo *bInfo = [[BiLLInfo alloc]init];
        bInfo.billid = billid;
        bInfo.bill =bill;
        bInfo.date = date;
        bInfo.imagepath = imagepath;
        bInfo.comment = comment;
        
        //NSLog(@"%@",billid);
        [billArray addObject:bInfo];
        
        totalCost += bill;
    }

    [database close];
    
    [self.totalCostLabel setText:[NSString stringWithFormat:@"TotalCost:%.2f  ",totalCost]];
    [self.tableView reloadData];
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
  //  [self.mapView addAnnotations:self.nearbyVenues];
    
    [self.tableView reloadData];
    
}

-(void)setupMapForLocatoion:(FSLocation*)newLocation{
    MKCoordinateRegion region;
    MKCoordinateSpan span;
    span.latitudeDelta = 0.003;
    span.longitudeDelta = 0.003;
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
    [self setupMapForLocatoion:currentVenue.location];
    
    NSMutableArray *nearbyVenues = [NSMutableArray arrayWithCapacity:1];
    [nearbyVenues addObject:currentVenue];
    [self.mapView addAnnotations:nearbyVenues];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setUsernameLabel:nil];
    [self setFooter:nil];
    [super viewDidUnload];
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation{
    if (annotation == mapView.userLocation)
        return nil;
    
    static NSString *s = @"ann";
    MKAnnotationView *pin = [mapView dequeueReusableAnnotationViewWithIdentifier:s];
    if (!pin) {
        pin = [[MKPinAnnotationView alloc]initWithAnnotation:annotation reuseIdentifier:s];
        pin.canShowCallout = YES;
        pin.image = [UIImage imageNamed:@"map"];
        pin.calloutOffset = CGPointMake(0, 0);
       // UIButton *button = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
       // [button addTarget:self action:@selector(checkinButton) forControlEvents:UIControlEventTouchUpInside];
       // pin.rightCalloutAccessoryView = button;
        
    }
    return pin;
}

-(void)checkinButton{
   // self.selected = self.mapView.selectedAnnotations.lastObject;
   // [self userDidSelectVenue];
}


-(void)userDidSelectVenue{
    /*if ([Foursquare2 isAuthorized]) {
        [self checkin];
    }else{
        [Foursquare2 authorizeWithCallback:^(BOOL success, id result) {
            if (success) {
                [Foursquare2  getDetailForUser:@"self"
                                      callback:^(BOOL success, id result){
                                          if (success) {
                                              [self checkin];
                                          }
                                      }];
            }
        }];
    }*/
}

- (void)initDatabase
{
    //数据库路径
    NSString *dbPath  = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/database.db"];
    
    NSFileManager *fm = [NSFileManager defaultManager];
    if(![fm fileExistsAtPath:dbPath])
    {
        EGODatabase* database = [EGODatabase databaseWithPath:dbPath];
        
        NSString *strSql = @"create table if not exists bill(id integer primary key asc, billid text, venueid text,venuename text,date text,tag text,comment text,bill double);";
        [database executeQuery:strSql];
        [database close];
    }
}

- (void)savebill:(BiLLInfo *)bill
{
  //  [[NSNotificationCenter defaultCenter] postNotificationName:@"AppAddBillSuccess" object:[NSString stringWithFormat:@"%@:%@:%.1f",currentVenue.name,bill.comment,bill.bill]]; // -> Analytics Event
    [[NSNotificationCenter defaultCenter] postNotificationName:@"AppAddBillSuccess" object:currentVenue.name]; // -> Analytics Event
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        self.navigationController.navigationBarHidden = NO;
        if (addbillView) {
            [UIView animateWithDuration:0.1
                             animations:^{
                                 addbillView.view.transform = CGAffineTransformMakeScale(1.1, 1.1);
                             }completion:^(BOOL finish){
                                 [UIView animateWithDuration:0.4
                                                  animations:^{
                                                      addbillView.view.transform = CGAffineTransformMakeScale(0.05, 0.05);
                                                  }completion:^(BOOL finish){
                                                      [addbillView.view removeFromSuperview];
                                                      addbillView = nil;
                                                  }];
                             }];
        }
        if (dimBackgroundView) {
            [dimBackgroundView removeFromSuperview];
            dimBackgroundView = nil;
        }
    }
    
    //replace sigle quote in name field
    //currentVenue.name =  [currentVenue.name stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
    NSString *VenueName =  [currentVenue.name stringByReplacingOccurrencesOfString:@"'" withString:@"''"];

    NSString *sqlQuery = [[NSString alloc]initWithFormat:@"select * from bill where billid='%@'",bill.billid];
    //NSLog(@"%@",sqlQuery);
    EGODatabase* database = [EGODatabase databaseWithPath:[NSHomeDirectory() stringByAppendingPathComponent:@"Documents/database.db"]];
    EGODatabaseResult *result = [database executeQuery:sqlQuery];
    if (result.count == 0) {
        
        NSString *sqlInsert= [[NSString alloc] initWithFormat:@"insert or replace into bill(billid,venueid,venuename,date,tag,comment,bill,imagepath) values ('%@','%@','%@','%@','%@','%@','%.2f','%@')", bill.billid,currentVenue.venueId,VenueName,bill.date,bill.tag,bill.comment,bill.bill,bill.imagepath];
        
        NSLog(@"%@",sqlInsert);
        
        result = [database executeQuery:sqlInsert];
        
        //save this venues

        sqlQuery = [[NSString alloc]initWithFormat:@"select * from places where venueid = '%@'",currentVenue.venueId];
        EGODatabaseResult *result = [database executeQuery:sqlQuery];
        if (result.count == 0) {
            sqlInsert = [[NSString alloc] initWithFormat:@"insert into places(venueid,venuename,address,latitude,longitude) values('%@','%@','%@','%.6f','%.6f')",currentVenue.venueId,VenueName,currentVenue.location.address,currentVenue.location.coordinate.latitude,currentVenue.location.coordinate.longitude];
            
            //NSLog(@"%@",sqlInsert);
            result = [database executeQuery:sqlInsert];
        }
    }
    else
    {
        NSString *strUpdate = [NSString stringWithFormat:@"update bill set tag='%@', bill='%f',comment='%@',imagepath='%@' where billid = '%@'",bill.tag,bill.bill,bill.comment,bill.imagepath, bill.billid];
        result = [database executeQuery:strUpdate];
    }
    
    [self loadBillWithVenueId:currentVenue.venueId];
}

- (void)cancel
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        if (addbillView) {
            [UIView animateWithDuration:0.1
                             animations:^{
                                 addbillView.view.transform = CGAffineTransformMakeScale(1.1, 1.1);
                             }completion:^(BOOL finish){
                                 [UIView animateWithDuration:0.4
                                                  animations:^{
                                                      addbillView.view.transform = CGAffineTransformMakeScale(0.05, 0.05);
                                                  }completion:^(BOOL finish){
                                                      [addbillView.view removeFromSuperview];
                                                      addbillView = nil;
                                                  }];
                             }];
        }
        if (dimBackgroundView) {
            [dimBackgroundView removeFromSuperview];
            dimBackgroundView = nil;
        }
        
        self.navigationController.navigationBarHidden = NO;
    }
}

- (IBAction)billStat:(id)sender {
    CostStatViewController *stat = [[CostStatViewController alloc]initWithNibName:nil bundle:nil];
    [self presentViewController:stat animated:YES completion:nil];
}

- (IBAction)goback:(id)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:kReloadDataNotification object:nil userInfo:nil];
    
    self.navigationController.navigationBarHidden = NO;
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)addbill:(id)sender {
    AddBillViewController *addbill = [[AddBillViewController alloc]initWithNibName:nil bundle:nil];
    addbill.delegate = self;
    UINavigationController *navController = [[UINavigationController alloc]initWithRootViewController:addbill];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        navController.modalPresentationStyle = UIModalPresentationFormSheet;
        [self presentViewController:navController animated:YES completion:nil];
    }
    else
    {
        self.navigationController.navigationBarHidden = YES;
        dimBackgroundView = [[UIView alloc] initWithFrame:self.view.bounds];
        dimBackgroundView.backgroundColor = [[UIColor grayColor] colorWithAlphaComponent:.3f];
        
        [self.view addSubview:dimBackgroundView];
        
        if (!addbillView) {
            addbillView = [[AddBillViewController alloc]initWithNibName:@"AddBillViewController" bundle:nil];
        }
        addbillView.delegate = self;
        addbillView.view.frame = self.view.frame;
        [self.view addSubview:addbillView.view];
        
        addbillView.view.transform = CGAffineTransformMakeScale(0.05, 0.05);
        [UIView animateWithDuration:0.3
                         animations:^{
                             addbillView.view.transform = CGAffineTransformMakeScale(1.1, 1.1);
                         }completion:^(BOOL finish){
                             [UIView animateWithDuration:0.1
                                              animations:^{
                                                  addbillView.view.transform = CGAffineTransformMakeScale(1.0, 1.0);
                                              }completion:^(BOOL finish){
                                                  /* [UIView animateWithDuration:0.1
                                                   animations:^{
                                                   addbillView.view.transform = CGAffineTransformMakeScale(1, 1);
                                                   }completion:^(BOOL finish){
                                                   
                                                   }];*/
                                              }];
                         }];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"AppBillClick" object:self]; // -> Analytics Event

}

- (void)deletebill:(BiLLInfo*)bill
{
    NSString *sqlQuery = [[NSString alloc]initWithFormat:@"delete from bill where billid='%@'",bill.billid];
    
    EGODatabase* database = [EGODatabase databaseWithPath:[NSHomeDirectory() stringByAppendingPathComponent:@"Documents/database.db"]];
    EGODatabaseResult *result = [database executeQuery:sqlQuery];
    
    [database close];
    
    //delete image
    NSString *pngPath = [NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"Documents/%@", bill.imagepath]];
    NSFileManager *filemanager = [NSFileManager defaultManager];
    [filemanager removeItemAtPath:pngPath error:nil];
    
    totalCost = totalCost - bill.bill;
    [self.totalCostLabel setText:[NSString stringWithFormat:@"TotalCost:%.2f  ", totalCost]];
    //NSLog(@"TotalCost:%.2f  billcost:%.2f result:%.2f",totalCost,bill.bill,totalCost - bill.bill);
    
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return billArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 55;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"bill";
    TableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[TableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    BiLLInfo *bill = billArray[indexPath.row];
    cell.dateTextLabel.text = [NSString stringWithFormat:@"%.2f",bill.bill];
    cell.textLabel.text = bill.comment;
    cell.detailTextLabel.text = bill.date;
    cell.textLabel.textColor = [UIColor blackColor];
    cell.detailTextLabel.textColor = [UIColor blackColor];
    cell.dateTextLabel.textColor = [UIColor blackColor];
    
    cell.imageView.clipsToBounds = YES;
    cell.imageView.contentMode = UIViewContentModeScaleAspectFill;
    cell.imageView.image = [UIImage imageWithContentsOfFile:bill.imagepath];
    cell.delegate = self;
    cell.revealDirection = RMSwipeTableViewCellRevealDirectionBoth;

//    if(indexPath.row < billArray.count)
//    {
//        UIImageView *line = [[UIImageView alloc] initWithFrame:CGRectMake(5, 65, 320-10, 1)];
//        line.backgroundColor = [[UIColor grayColor] colorWithAlphaComponent:0.3];
//        [cell addSubview:line];
//    }
    
    return cell;
}

#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    BiLLInfo *bill = [billArray objectAtIndex:indexPath.row];
    
    AddBillViewController *addbill = [[AddBillViewController alloc] initWithBill:bill];
    addbill.delegate = self;
    UINavigationController *navController = [[UINavigationController alloc]initWithRootViewController:addbill];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        navController.modalPresentationStyle = UIModalPresentationFormSheet;
        [self presentViewController:navController animated:YES completion:nil];
    }
    else
    {
        self.navigationController.navigationBarHidden = YES;
        
        dimBackgroundView = [[UIView alloc] initWithFrame:self.view.bounds];
        dimBackgroundView.backgroundColor = [[UIColor grayColor] colorWithAlphaComponent:.3f];
        
        [self.view addSubview:dimBackgroundView];
        
        if (!addbillView) {
            addbillView = [[AddBillViewController alloc] initWithBill:bill];
        }
        addbillView.delegate = self;
        addbillView.view.frame = self.view.frame;
        [self.view addSubview:addbillView.view];
        
        addbillView.view.transform = CGAffineTransformMakeScale(0.05, 0.05);
        [UIView animateWithDuration:0.3
                         animations:^{
                             addbillView.view.transform = CGAffineTransformMakeScale(1.1, 1.1);
                         }completion:^(BOOL finish){
                             [UIView animateWithDuration:0.1
                                              animations:^{
                                                  addbillView.view.transform = CGAffineTransformMakeScale(1.0, 1.0);
                                              }completion:^(BOOL finish){
                                                  /* [UIView animateWithDuration:0.1
                                                   animations:^{
                                                   addbillView.view.transform = CGAffineTransformMakeScale(1, 1);
                                                   }completion:^(BOOL finish){
                                                   
                                                   }];*/
                                              }];
                         }];
    }
}

#pragma mark - Swipe Table View Cell Delegate
-(void)swipeTableViewCellDidResetState:(RMSwipeTableViewCell *)swipeTableViewCell fromLocation:(CGPoint)translation animation:(RMSwipeTableViewCellAnimationType)animation velocity:(CGPoint)velocity {
    
    NSIndexPath *indexPath = [self.tableView indexPathForCell:swipeTableViewCell];
    TableViewCell *cell = (TableViewCell*)[self.tableView cellForRowAtIndexPath:indexPath];
    float CellContentHeight = cell.contentView.frame.size.height;

    if (translation.x >= (CellContentHeight * 1.5)) {
        BiLLInfo *bill = [billArray objectAtIndex:indexPath.row];
        [self deletebill:bill];
        [billArray removeObjectAtIndex:indexPath.row];
        [self.tableView beginUpdates];
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        [self.tableView endUpdates];
    }
    else if (translation.x <= -(CellContentHeight * 1.5)) {
        BiLLInfo *bill = [billArray objectAtIndex:indexPath.row];
        [self deletebill:bill];
        [billArray removeObjectAtIndex:indexPath.row];
        [self.tableView beginUpdates];
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        [self.tableView endUpdates];
    }
}

@end
