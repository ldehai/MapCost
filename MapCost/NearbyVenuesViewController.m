//
//  NearbyVenuesViewController.m
//  Foursquare2-iOS
//
//  Created by Constantine Fry on 1/20/13.
//
//
#import "AppDelegate.h"
#import "NearbyVenuesViewController.h"
#import "Foursquare2.h"
#import "FSVenue.h"
#import "FSConverter.h"
#import "EGODatabase.h"
#import "BiLLInfo.h"
#import "CostStatViewController.h"
#import "ThisVenuesViewController.h"
#import <MessageUI/MessageUI.h>
#import "UIDevice+IdentifierAddition.h"
#import "MyVenue.h"
#import "SettingViewController.h"
#import "UpgradeViewController.h"
#import "AppHelper.h"
#import "SVProgressHUD.h"
#import "Base64.h"
#import "SettingViewController.h"
#import "UIColor+Categories.h"

enum CURRENT_PAGE {
    CURRENT_PAGE_HOME = 1,
    CURRENT_PAGE_COST = 2
    };

@interface NearbyVenuesViewController ()<MFMailComposeViewControllerDelegate,MyVenueDelegate>
{
    UIView *dimBackgroundView;
    CostStatViewController *statView;
    SettingViewController *setView;
    BOOL bShowList;
    UIView *popMenu;
    int curPage;
    int myTotleVenue;
    MyVenue *myann;
}
@end

@implementation NearbyVenuesViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    curPage = CURRENT_PAGE_HOME;
    [self setTitle:@"MapCost"];
//    [self.navigationController.navigationBar setTintColor:[UIColor colorWithRed:248.0/255.0 green:248.0/255.0 blue:248.0/255.0 alpha:1.0]];
    
   [self addNavigationButton];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        [self.header setFrame:CGRectInset(self.header.frame, 0, -50)];
    }
    self.tableView.tableHeaderView = self.header;
    self.tableView.tableFooterView = self.footer;
    _locationManager = [[CLLocationManager alloc]init];
    _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    _locationManager.delegate = self;
    [_locationManager startUpdatingLocation];
    
    
    [SVProgressHUD show];
    
    [self initDatabase];
    
    [self proccessAnnotations];
    
    UILongPressGestureRecognizer *longpress = [[UILongPressGestureRecognizer alloc]
                                               initWithTarget:self
                                               action:@selector(handlelongpress:)];
    longpress.minimumPressDuration = 0.6; //0.6秒长按
    [self.header addGestureRecognizer:longpress];

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
    [btn setImage:[UIImage imageNamed:@"menu"] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(leftButtonAction) forControlEvents:UIControlEventTouchUpInside];
    //[btn addTarget:self.viewDeckController action:@selector(toggleLeftView) forControlEvents:UIControlEventTouchUpInside];
    [btn setFrame:CGRectMake(0, 0, 20, 14)];
    
    UIBarButtonItem *barbtn = [[UIBarButtonItem alloc] initWithCustomView:btn];
    self.navigationItem.leftBarButtonItem = barbtn;
    
    btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setShowsTouchWhenHighlighted:TRUE];
    [btn setImage:[UIImage imageNamed:@"stat"] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(flipAction:) forControlEvents:UIControlEventTouchUpInside];
    [btn setFrame:CGRectMake(0, 0, 20, 20)];
    barbtn = [[UIBarButtonItem alloc] initWithCustomView:btn];
    self.navigationItem.rightBarButtonItem = barbtn;

}

//长按地图，添加自定义地点
-(void) handlelongpress:(UIGestureRecognizer*)gestureRecognizer
{
    myTotleVenue = [self getMyVenueCount];
    bool bPurchased = [[AppHelper sharedInstance] readPurchaseInfo];
    if (myTotleVenue >= 3 && !bPurchased) {
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"AppLongpressMap2Limited" object:self]; // -> Analytics Event
        
        if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
            
            [self upgradePro:nil];
            
            return;
        }
        if (gestureRecognizer.state != UIGestureRecognizerStateBegan)
            return;
    }

    //在长按后返回，防止加两次
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan){
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"AppLongpressMap" object:self]; // -> Analytics Event
        
        //获取当前点按的坐标，并转化为地图坐标
        CGPoint touchPoint = [gestureRecognizer locationInView:self.mapView];
        
        CLLocationCoordinate2D touchMapCoordinate = [self.mapView convertPoint:touchPoint toCoordinateFromView:self.mapView];
        
        myann = [[MyVenue alloc] init];
        NSString *venueid = [self generateID];
        NSString *venuename = @"New Venue";
        NSString *address = @"Self-Defined Address";
        
//        CLLocation *curPoint = [[CLLocation alloc]initWithLatitude:touchMapCoordinate.latitude longitude:touchMapCoordinate.longitude];
//        CLLocation *centerPoint =  [[CLLocation alloc]initWithLatitude:self.mapView.centerCoordinate.latitude longitude:self.mapView.centerCoordinate.longitude];
//        CLLocationDistance dist = [curPoint distanceFromLocation:centerPoint];
        
        myann.name = venuename;
        myann.venueId = venueid;
        myann.location.address = address;
//        ann.location.distance = 0;
        myann.location.coordinate = touchMapCoordinate;
        myann.delegate = self;
        
        [self.mapView addAnnotation:myann];
    }
    else if (gestureRecognizer.state == UIGestureRecognizerStateEnded)
    {
        //修改自定义地点名称和地址
        if(!dimBackgroundView)
        {
            dimBackgroundView = [[UIView alloc] initWithFrame:self.view.bounds];
            dimBackgroundView.backgroundColor = [[UIColor clearColor] colorWithAlphaComponent:0.7];
            dimBackgroundView.backgroundColor = [UIColor clearColor];
        }
        [self.view addSubview:dimBackgroundView];
        
        CGSize size = [[UIScreen mainScreen] bounds].size;
        CGRect frame = self.editVenue.frame;
        frame.origin.y = size.height+100;
        frame.origin.x = size.width/2-frame.size.width/2;
        self.editVenue.frame = frame;
        
        self.editVenue.backgroundColor = [UIColor colorWithRed:245.0/255.0 green:245.0/255.0 blue:245.0/255.0 alpha:1.0];
        self.editVenue.layer.shadowOffset = CGSizeMake(3, 2);
        self.editVenue.layer.shadowColor = [UIColor colorWithRed:70.0/255.0 green:70.0/255.0 blue:80.0/255.0 alpha:1.0].CGColor;
        self.editVenue.layer.shadowOpacity = 0.8;

        [self.view addSubview:self.editVenue];
        //[self.view addSubview:setView.view];
        
        [self performSelector:@selector(activeInputFocus) withObject:nil afterDelay:0.1];
        
    }
}

- (void) keyboardWillShown:(NSNotification *)nsNotification {
    NSDictionary *userInfo = [nsNotification userInfo];
    CGSize kbSize = [[userInfo objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    NSValue* aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    NSLog(@"Height: %f Width: %f", kbSize.height, kbSize.width);
    CGRect keyboardRect = [aValue CGRectValue];
    
    CGSize size = [[UIScreen mainScreen] bounds].size;
    
    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseInOut animations:^(void) {
        CGRect frame = self.editVenue.frame;
        if (keyboardRect.origin.y != size.height) {
            
            int height = self.navigationController.navigationBar.frame.size.height + [UIApplication sharedApplication].statusBarFrame.size.height;
            
            float sysversion = [[[UIDevice currentDevice] systemVersion] floatValue];
            if (sysversion < 7.0) {
                frame.origin.y = keyboardRect.origin.y-frame.size.height-height;
            }
            else
                frame.origin.y = keyboardRect.origin.y-frame.size.height;
        }
        self.editVenue.frame = frame;
        
    } completion:^(BOOL finished) {
    }];
}

- (IBAction)saveVenue:(id)sender {
    if (![self.venueName.text isEqualToString:@""]) {
        
//        MyVenue *ann = self.mapView.selectedAnnotations.lastObject;
        myann.name = self.venueName.text;
        myann.location.address = self.venueAddress.text;
        
        //重新加入是为了更新提示框的文字
        [self.mapView removeAnnotation:myann];
        [self.mapView addAnnotation:myann];
        
        if (!self.nearbyVenues) {
            self.nearbyVenues = [[NSMutableArray alloc]init];
        }
        [self.nearbyVenues insertObject:myann atIndex:0];
        
        //加入数据库
        [self saveVenue2Database:myann];
        
        //插入列表
        NSIndexPath * indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        //NSIndexPath * indexPath = [self.tableView indexPathForCell:swipeTableViewCell];
        if (self.nearbyVenues.count == 1) {
            [self.tableView reloadData];
        }
        else
        {
            [self.tableView beginUpdates];
            [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationRight];
            [self.tableView endUpdates];
        }
        [dimBackgroundView removeFromSuperview];
        [self.editVenue removeFromSuperview];
        self.venueName.text = self.venueAddress.text = @"";
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"AppAddVenueSuccess" object:self.venueName.text]; // -> Analytics Event
        
        myann = nil;
    }
}

- (IBAction)cancelVenue:(id)sender {
//    MyVenue *ann = self.mapView.selectedAnnotations.lastObject;
    [self.mapView removeAnnotation:myann];
    myann = nil;
    
    [dimBackgroundView removeFromSuperview];
    [self.editVenue removeFromSuperview];
}

- (void)activeInputFocus
{
    [[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(keyboardWillShown:)
												 name:UIKeyboardWillShowNotification
											   object:nil];

    [self.venueName becomeFirstResponder];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *) event
{
    UITouch *touch = [[event allTouches] anyObject];
    
    if (dimBackgroundView == touch.view) {
        if (popMenu.superview) {
            [self openSetting:nil];
        }
        
        if (self.editVenue.superview) {
            [self cancelVenue:nil];
            //[self.editVenue removeFromSuperview];
        }
    }
}

- (NSString*)generateID
{
    NSUUID *UUID = [NSUUID UUID];
    NSString *UUIDString = UUID.UUIDString;
    NSLog(@"Original UUID:\t%@", UUIDString);
    
    return UUIDString;
}

- (void)leftButtonAction
{
    [self performSelector:@selector(openSetting:) withObject:nil afterDelay:0.0];
}


- (IBAction)openSetting:(id)sender{
    
    if(!dimBackgroundView)
    {
        dimBackgroundView = [[UIView alloc] initWithFrame:self.view.bounds];
        //dimBackgroundView.backgroundColor = [[UIColor clearColor] colorWithAlphaComponent:0.0];
        dimBackgroundView.backgroundColor = [UIColor clearColor];
    }
    [self.view addSubview:dimBackgroundView];
    
//    if (!setView) {
//        setView = [[SettingViewController alloc]initWithNibName:nil bundle:nil];
//        CGRect frame = self.view.frame;
//        frame.origin.y = -frame.size.height;
//        frame.size.width = 80;
//        setView.view.frame = frame;
//        //setView.delegate = self;
//    }
    BOOL  bPurchase = [[AppHelper sharedInstance] readPurchaseInfo];
    if (curPage == CURRENT_PAGE_HOME) {
        if (bPurchase)
            popMenu = self.popMenuSimple;
        else
            popMenu = self.popMenuHome;
    }
    else if(bPurchase)
        popMenu = self.popMenuCostSimple;
    else
        popMenu = self.popMenuCost;
    
    //为菜单添加阴影
    popMenu.layer.shadowOffset = CGSizeMake(3, 2);
    popMenu.layer.shadowColor = [UIColor colorWithRed:70.0/255.0 green:70.0/255.0 blue:80.0/255.0 alpha:1.0].CGColor;
    popMenu.layer.shadowOpacity = 0.8;

    CGRect frame = popMenu.frame;
    frame.origin.y = - frame.size.height;
    popMenu.frame = frame;
    [self.view addSubview:popMenu];
    //[self.view addSubview:setView.view];
    
    if (!bShowList) {
        CGRect frame = popMenu.frame;
        int height = self.navigationController.navigationBar.frame.size.height + [UIApplication sharedApplication].statusBarFrame.size.height;
        
        float sysversion = [[[UIDevice currentDevice] systemVersion] floatValue];
        frame.origin.y = sysversion < 7.0?0:height;
        [UIView animateWithDuration:0.3
                         animations:^{
                             //dimBackgroundView.backgroundColor = [[UIColor clearColor] colorWithAlphaComponent:0.3];
                             [popMenu setFrame:frame];
                         }];
    }
    else{
        CGRect frame = popMenu.frame;
        frame.origin.y = -frame.size.height;
        [UIView animateWithDuration:0.3
                         animations:^{
                             //dimBackgroundView.backgroundColor = [[UIColor clearColor] colorWithAlphaComponent:0.0];
                             [popMenu setFrame:frame];
                             
                             [UIView animateWithDuration:0.3
                                              animations:^{
                                                  //dimBackgroundView.backgroundColor = [[UIColor clearColor] colorWithAlphaComponent:0.0];
                                                  [popMenu setFrame:frame];
                                              }];
                         }];
        
        [self performSelector:@selector(closeSetting) withObject:nil afterDelay:0.3];
    }
    
    bShowList = !bShowList;
}

-(void)closeSetting
{
    [dimBackgroundView removeFromSuperview];
    [self.popMenuHome removeFromSuperview];
}

-(void)mailto
{
    if ([MFMailComposeViewController canSendMail])
    {
        NSString *contact = @"ldehai+mapcost@gmail.com";
        MFMailComposeViewController *mailViewController = [[MFMailComposeViewController alloc] init];
        [mailViewController setToRecipients:[[NSArray alloc]initWithObjects:contact, nil]];
        mailViewController.mailComposeDelegate = self;
        if (contact) {
           // NSString *device = [[UIDevice currentDevice] model];
            NSString *deviceid = [[UIDevice currentDevice] uniqueGlobalDeviceIdentifier];
            NSLog(@"uniqueIdentifier[%@]",deviceid);
           // NSString *version = [[UIDevice currentDevice] systemVersion];
            NSString *strBundleVersion = [NSString stringWithFormat:@"%@", [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]];
            
            NSString *language = [[[NSUserDefaults standardUserDefaults] objectForKey:@"AppleLanguages"] objectAtIndex:0];
            NSString *deviceString = [NSString stringWithFormat:@" %@ | iOS %@ | %@",
                                      [[UIDevice currentDevice] model],[[UIDevice currentDevice] systemVersion],language];
            [mailViewController setMessageBody:deviceString isHTML:YES];
            [mailViewController setSubject:[NSString stringWithFormat:@"MapCost Feedback(v%@)",strBundleVersion]];
        }
       
        [self presentViewController:mailViewController animated:YES completion:nil];
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"No Mail Accounts" message:@"Please set up a Mail account in order to send email." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        
        NSLog(@"Device is unable to send email in its current state.");
    }

}

- (IBAction)flipAction:(id)sender
{
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.75];
    
	[UIView setAnimationTransition:([self.tableView superview] ?
                                    UIViewAnimationTransitionFlipFromRight : UIViewAnimationTransitionFlipFromLeft)
                           forView:self.view cache:YES];
    if (!statView) {
        statView = [[CostStatViewController alloc]initWithNibName:nil bundle:nil];
        [statView.view setFrame:self.view.frame];
    }
	if ([self.tableView superview])
	{
		[self.tableView removeFromSuperview];
		[self.view addSubview:statView.view];

     //   [[NSNotificationCenter defaultCenter] postNotificationName:kReloadDataNotification object:self userInfo:nil];

        [self setTitle:@"Summary"];
        curPage = CURRENT_PAGE_COST;
	}
	else
	{
		[statView.view removeFromSuperview];
		[self.view addSubview:self.tableView];

        [self setTitle:@"MapCost"];
        curPage = CURRENT_PAGE_HOME;
	}
	
	[UIView commitAnimations];
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error __OSX_AVAILABLE_STARTING(__MAC_NA,__IPHONE_3_0)
{
    [controller dismissViewControllerAnimated:YES completion:nil];
}

-(void)removeAllAnnotationExceptOfCurrentUser
{
    NSMutableArray *annForRemove = [[NSMutableArray alloc] initWithArray:self.mapView.annotations];
    if ([self.mapView.annotations.lastObject isKindOfClass:[MKUserLocation class]]) {
        [annForRemove removeObject:self.mapView.annotations.lastObject];
    }
    else
    {
        for (id <MKAnnotation> annot_ in self.mapView.annotations)
        {
            if ([annot_ isKindOfClass:[MKUserLocation class]] ||
                [annot_ isKindOfClass:[MyVenue class]]) {
                
                [annForRemove removeObject:annot_];
                //break;
            }
        }
    }
    
    [self.mapView removeAnnotations:annForRemove];
}

-(void)proccessAnnotations{
    [self removeAllAnnotationExceptOfCurrentUser];

    [self loadVenue];

    [self.mapView addAnnotations:self.nearbyVenues];
    
    [self.tableView reloadData];
    
    [SVProgressHUD dismiss];
    
}

-(void)getVenuesForLocation:(CLLocation*)location{
    [Foursquare2 searchVenuesNearByLatitude:@(location.coordinate.latitude)
								  longitude:@(location.coordinate.longitude)
								 accuracyLL:nil
								   altitude:nil
								accuracyAlt:nil
									  query:nil
									  limit:nil
									 intent:intentCheckin
                                     radius:@(500)
                                 categoryId:nil
								   callback:^(BOOL success, id result){
									   if (success) {
										   NSDictionary *dic = result;
										   NSArray* venues = [dic valueForKeyPath:@"response.venues"];
                                           FSConverter *converter = [[FSConverter alloc]init];
                                           self.nearbyVenues = [converter convertToObjects:venues];
                                           [self proccessAnnotations];
									   }
								   }];
    
}

-(void)setupMapForLocatoion:(CLLocation*)newLocation{
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
//
//- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated{
//    
//}
- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation{
    [_locationManager stopUpdatingLocation];
    [self setupMapForLocatoion:newLocation];
    [self getVenuesForLocation:newLocation];
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view didChangeDragState:(MKAnnotationViewDragState)newState
   fromOldState:(MKAnnotationViewDragState)oldState{
    if (newState == MKAnnotationViewDragStateEnding) {
        
    }
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated{
    CLLocationCoordinate2D location = mapView.centerCoordinate;
    CLLocation *newLocation = [[CLLocation alloc] initWithLatitude:location.latitude longitude:location.longitude];
    [self setupMapForLocatoion:newLocation];
    [self getVenuesForLocation:newLocation];
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation{
    if (annotation == mapView.userLocation)
        return nil;
    
    if ([annotation isKindOfClass:[MKUserLocation class]])
    {
        return nil;
    }
    //self-define location
    else if ([annotation isKindOfClass:[MyVenue class]])
    {
/*        static NSString *s = @"myann";
        MKAnnotationView *pin = [mapView dequeueReusableAnnotationViewWithIdentifier:s];
        if (pin == nil) {
            pin = [[MKPinAnnotationView alloc]initWithAnnotation:annotation reuseIdentifier:s];
        }
        pin.canShowCallout = YES;
        pin.tintColor = [UIColor colorWithHexString:@"00AB72"];
        pin.image = [UIImage imageNamed:@"icon"];
        pin.calloutOffset = CGPointMake(0, 0);
        UIButton *buttonRight = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        [buttonRight addTarget:self action:@selector(openVenue) forControlEvents:UIControlEventTouchUpInside];
        pin.rightCalloutAccessoryView = buttonRight;
        
        UIButton *buttonLeft = [UIButton buttonWithType:UIButtonTypeCustom];
        [buttonLeft setFrame:CGRectMake(0, 0, 16, 20)];
        [buttonLeft setImage:[UIImage imageNamed:@"trash@2x"] forState:UIControlStateNormal];
        [buttonLeft addTarget:self action:@selector(deleteMyVenue:withEvent:) forControlEvents:UIControlEventTouchUpInside];
        
        pin.leftCalloutAccessoryView = buttonLeft;
        pin.draggable = YES;
        
        
        return pin;*/
        static NSString *annotationViewReuseIdentifier = @"annotationViewReuseIdentifier";

        MKAnnotationView *annotationView = (MKAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:annotationViewReuseIdentifier];
        
        if (annotationView == nil)
        {
            annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:annotationViewReuseIdentifier];
        }
        
        // here you can assign your friend's image
        annotationView.image = [UIImage imageNamed:@"favorite_green"];
        annotationView.annotation = annotation;
        
        // add below line of code to enable selection on annotation view
        annotationView.canShowCallout = YES;
        UIButton *buttonRight = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        [buttonRight addTarget:self action:@selector(openVenue) forControlEvents:UIControlEventTouchUpInside];
        annotationView.rightCalloutAccessoryView = buttonRight;
        
        UIButton *buttonLeft = [UIButton buttonWithType:UIButtonTypeCustom];
        [buttonLeft setFrame:CGRectMake(0, 0, 16, 20)];
        [buttonLeft setImage:[UIImage imageNamed:@"trash@2x"] forState:UIControlStateNormal];
        [buttonLeft addTarget:self action:@selector(deleteMyVenue:withEvent:) forControlEvents:UIControlEventTouchUpInside];
        
        annotationView.leftCalloutAccessoryView = buttonLeft;
        annotationView.draggable = YES;
        
        return annotationView;
        
    }
    //foursquare supply locations
    else
    {
        static NSString *s = @"ann";
        MKAnnotationView *pin = [mapView dequeueReusableAnnotationViewWithIdentifier:s];
        if (!pin) {
            pin = [[MKPinAnnotationView alloc]initWithAnnotation:annotation reuseIdentifier:s];
            pin.canShowCallout = YES;
            pin.image = [UIImage imageNamed:@"map"];
            pin.calloutOffset = CGPointMake(0, 0);
            UIButton *button = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
            [button addTarget:self action:@selector(openVenue) forControlEvents:UIControlEventTouchUpInside];
            pin.rightCalloutAccessoryView = button;
            
        }
        return pin;
    }
    
    return nil;
}

-(void)openVenue{
    self.selected = self.mapView.selectedAnnotations.lastObject;
    
    ThisVenuesViewController *this = [[ThisVenuesViewController alloc] initWithVenues:self.selected];
    [self.navigationController pushViewController:this animated:YES];
    
}

- (void) deleteMyVenue: (UIControl *) button withEvent: (UIEvent *) event
{
    //获取当前选中的地点
    MyVenue *selectann = self.mapView.selectedAnnotations.lastObject;
    
    //从数据库中删除
    NSString *dbPath  = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/database.db"];
    
    EGODatabase* database = [EGODatabase databaseWithPath:dbPath];
    
    NSString* sqlDelete = [[NSString alloc] initWithFormat:@"delete from myplaces where venueid='%@'",selectann.venueId];
    
    [database executeQuery:sqlDelete];
    
    [database close];

    //从地图中清除选中的地点
    [self.mapView removeAnnotation:selectann];
    
    //从列表中去掉
    for (int i=0; i<self.nearbyVenues.count; i++) {
        FSVenue* ven = [self.nearbyVenues objectAtIndex:i];
        if ([ven.venueId isEqualToString:selectann.venueId]) {
            [self.nearbyVenues removeObject:ven];
            
            if (self.nearbyVenues.count == 0) {
                [self.tableView reloadData];
            }
            else
            {
                NSIndexPath * indexPath = [NSIndexPath indexPathForRow:i inSection:0];
                [self.tableView beginUpdates];
                [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
                [self.tableView endUpdates];
            }
            break;
        }
    }
}

- (void)saveVenue2Database:(MyVenue*)venue
{
    NSString *dbPath  = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/database.db"];
    
    EGODatabase* database = [EGODatabase databaseWithPath:dbPath];
    
    NSString* sqlInsert = [[NSString alloc] initWithFormat:@"insert into myplaces(venueid,venuename,address,latitude,longitude) values('%@','%@','%@','%.6f','%.6f')",venue.venueId,venue.name,venue.location.address,venue.location.coordinate.latitude,venue.location.coordinate.longitude];
    
    [database executeQuery:sqlInsert];
    
    [database close];

}

- (void)updateVenue2Database:(MyVenue*)venue
{
    NSString *dbPath  = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/database.db"];
    
    EGODatabase* database = [EGODatabase databaseWithPath:dbPath];
    
    NSString* sqlUpdate = [[NSString alloc] initWithFormat:@"update myplaces set latitude= '%.6f',longitude='%.6f' where venueid='%@'",venue.location.coordinate.latitude,venue.location.coordinate.longitude,venue.venueId];
    
    NSLog(@"%@",sqlUpdate);
    [database executeQuery:sqlUpdate];
    
    [database close];
    
}

- (void)updateVenueCoordinate:(CLLocationCoordinate2D)cord withVenueid:(NSString*)vid
{
    NSString *dbPath  = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/database.db"];
    
    EGODatabase* database = [EGODatabase databaseWithPath:dbPath];
    
    NSString* sqlUpdate = [[NSString alloc] initWithFormat:@"update myplaces set latitude= '%.6f',longitude='%.6f' where venueid='%@'",cord.latitude,cord.longitude,vid];
    
    NSLog(@"%@",sqlUpdate);
    [database executeQuery:sqlUpdate];
    
    [database close];
}

//初始检查正式数据库是否存在
- (void)initDatabase
{
    //最终数据库路径
    NSString *dbPath  = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/database.db"];
    
    NSFileManager *fm = [NSFileManager defaultManager];
    if(![fm fileExistsAtPath:dbPath])
    {
        EGODatabase* database = [EGODatabase databaseWithPath:dbPath];
        
        NSString *strSql = @"create table if not exists bill(id integer primary key asc, billid text, venueid text,venuename text,date text,tag text,comment text,bill double,imagepath text);";
        [database executeQuery:strSql];
        
        strSql = @"create table if not exists places(id integer primary key asc, venueid text,venuename text,address text,latitude double,longitude double);";
        [database executeQuery:strSql];

        strSql = @"create table if not exists myplaces(id integer primary key asc, venueid text,venuename text,address text,latitude double,longitude double);";
        [database executeQuery:strSql];

        [database close];
        
        NSUserDefaults *pref = [NSUserDefaults standardUserDefaults];
        [pref setValue:@"1.2" forKey:@"dbver"];

    }
    
    NSUserDefaults *pref = [NSUserDefaults standardUserDefaults];
    NSString* ver = [pref stringForKey:@"dbver"];
    if ( !ver || [ver isEqualToString:@""] || [ver isEqualToString:@"1.1"])
    {
        EGODatabase* database = [EGODatabase databaseWithPath:dbPath];

        NSString *strSql = @"create table if not exists myplaces(id integer primary key asc, venueid text,venuename text,address text,latitude double,longitude double);";
        [database executeQuery:strSql];

        [database close];
        
        NSUserDefaults *pref = [NSUserDefaults standardUserDefaults];
        [pref setValue:@"1.2" forKey:@"dbver"];

    }

}

- (int)getMyVenueCount
{
    EGODatabase* database = [EGODatabase databaseWithPath:[NSHomeDirectory() stringByAppendingPathComponent:@"Documents/database.db"]];
    
    //查询所有的自定义地点
    NSString *sqlQuery = [[NSString alloc]initWithFormat:@"select distinct count(*) from myplaces"];
    //NSLog(@"%@",sqlQuery);
    
    EGODatabaseResult *result = [database executeQuery:sqlQuery];
    for(EGODatabaseRow* row in result) {
        myTotleVenue = [row intForColumnIndex:0];
    }
    
    [database close];
    
    return myTotleVenue;
}

- (void)loadVenue
{
    if (!self.nearbyVenues) {
        self.nearbyVenues = [[NSMutableArray alloc]init];
    }
    
    EGODatabase* database = [EGODatabase databaseWithPath:[NSHomeDirectory() stringByAppendingPathComponent:@"Documents/database.db"]];
    
    //查询所有的自定义地点
    NSString *sqlQuery = [[NSString alloc]initWithFormat:@"select distinct * from myplaces  order by venueid"];
    //NSLog(@"%@",sqlQuery);
    
    EGODatabaseResult *result = [database executeQuery:sqlQuery];
    for(EGODatabaseRow* row in result) {
        NSString *venueid = [row stringForColumn:@"venueid"];
        NSString *venuename = [row stringForColumn:@"venuename"];
        NSString *address = [row stringForColumn:@"address"];
        double latitude = [row doubleForColumn:@"latitude"];
        double longitude = [row doubleForColumn:@"longitude"];
        
        MyVenue *ann = [[MyVenue alloc]init];
        ann.delegate = self;
        ann.name = venuename;
        ann.venueId = venueid;
        
        ann.location.address = address;
        ann.location.distance = 0;
        //ann.location.distance = v[@"location"][@"distance"];
        
        [ann.location setCoordinate:CLLocationCoordinate2DMake(latitude,longitude)];
        
        [self.nearbyVenues insertObject:ann atIndex:0];
        
    }

    [database close];
}

- (IBAction)giveFeedback:(id)sender {
    [self openSetting:nil];
//    [self mailto];
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"itms-apps://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=689270210"]];

}

- (IBAction)billStat:(id)sender {
    CostStatViewController *stat = [[CostStatViewController alloc]initWithNibName:nil bundle:nil];
    [self presentViewController:stat animated:YES completion:nil];
}

- (IBAction)loadAllVenue:(id)sender {
    [self openSetting:nil];
    
    [_locationManager startUpdatingLocation];
    
    
    [SVProgressHUD show];
}

- (IBAction)loadFavoriteVenue:(id)sender {
    
    [self openSetting:nil];
    BOOL  bPurchase = [[AppHelper sharedInstance] readPurchaseInfo];
    if (!bPurchase) {
        [self upgradePro:nil];
    }
    else
    {
        [self.nearbyVenues removeAllObjects];
        [self proccessAnnotations];
    }
    
}

- (IBAction)upgradePro:(id)sender {
    if (bShowList) {
        [self openSetting:nil];
    }
    
    UpgradeViewController *upgradeView = [[UpgradeViewController alloc]initWithNibName:nil bundle:nil];
    
    UINavigationController *navController = [[UINavigationController alloc]initWithRootViewController:upgradeView];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        navController.modalPresentationStyle = UIModalPresentationFormSheet;
    }
    
    [self presentViewController:navController animated:YES completion:nil];
  //  [self.navigationController pushViewController:upgradeView animated:YES];
}

- (IBAction)suggestApps:(id)sender {
    [self openSetting:nil];
}

- (IBAction)about:(id)sender {
    [self openSetting:nil];
    
    SettingViewController *set = [[SettingViewController alloc]initWithNibName:nil bundle:nil];
    
    UINavigationController *navController = [[UINavigationController alloc]initWithRootViewController:set];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        navController.modalPresentationStyle = UIModalPresentationFormSheet;
    }
    
    [self presentViewController:navController animated:YES completion:nil];
    
//    [self.navigationController pushViewController:set animated:YES];
}

- (IBAction)exportBills:(id)sender {
    [self openSetting:nil];
    
    BOOL  bPurchase = [[AppHelper sharedInstance] readPurchaseInfo];
    if (!bPurchase) {
        [self upgradePro:nil];
    }
    else
        [self sendExportBill];
}


- (void)sendExportBill
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"AppSendExportBill" object:self]; // -> Analytics Event
    
    if ([MFMailComposeViewController canSendMail]==YES)
    {
        MFMailComposeViewController *mailViewController = [[MFMailComposeViewController alloc] init];
        mailViewController.mailComposeDelegate = self;
        [mailViewController setSubject:@"MapCost Export Bills"];
        NSString *strMessage = @"<p>MapCost Export Bills</p>";
        
        [mailViewController setMessageBody:strMessage isHTML:YES];
        //    mailViewController.navigationBar.tintColor = [UIColor redColor];
        
        [self generateExportData];
        NSString *strAttachment = [NSTemporaryDirectory() stringByAppendingPathComponent:@"MapCostBills.csv"];
        NSData *myData = [NSData dataWithContentsOfFile:strAttachment];
        NSString *fileName = @"MapCostBills.csv";
        [mailViewController addAttachmentData:myData mimeType:@"text/csv" fileName:fileName];
        [self presentViewController:mailViewController animated:YES completion:nil];
    }
    else
    {
        NSString *deviceType = [UIDevice currentDevice].model;
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"")
                                                        message:[NSString stringWithFormat:NSLocalizedString(@"Your %@ must have an email account set up", @""), deviceType]
                                                       delegate:nil
                                              cancelButtonTitle:NSLocalizedString(@"Ok", @"")
                                              otherButtonTitles:nil];
        alert.delegate = self;
        [alert show];
    }

}

-(void)launchMailAppOnDevice
{
    NSString *recipients = @"mailto:ldehai@gmail.com?subject=mapcost export";
    NSString *body = @"&body=mapcost export";
    
    NSString *email = [NSString stringWithFormat:@"%@%@", recipients, body];
    email = [email stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:email]];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex NS_DEPRECATED_IOS(2_0, 9_0){
    [self launchMailAppOnDevice];
}

- (void)generateExportData
{
    EGODatabase* database = [EGODatabase databaseWithPath:[NSHomeDirectory() stringByAppendingPathComponent:@"Documents/database.db"]];
    
    //查询所有消费过的地点
    NSString *sqlQuery = [[NSString alloc]initWithFormat:@"select distinct * from places  order by venueid"];
    //NSLog(@"%@",sqlQuery);
    
    NSMutableDictionary *dictId2Name = [NSMutableDictionary dictionary];
    EGODatabaseResult *result = [database executeQuery:sqlQuery];
    for(EGODatabaseRow* row in result) {
        NSString *venueid = [row stringForColumn:@"venueid"];
        NSString *venuename = [row stringForColumn:@"venuename"];
        
        [dictId2Name setValue:venuename forKey:venueid];
    }
    
    
    NSString *strHeader = @"Location,Date,Bill,Comment\n";
    NSMutableString *strContent = [[NSMutableString alloc]init];
    [strContent appendString:strHeader];
    
    sqlQuery = [[NSString alloc]initWithFormat:@"select venueid,date,comment,bill from bill order by date desc"];
    //NSLog(@"%@",sqlQuery);
    
    result = [database executeQuery:sqlQuery];
    for(EGODatabaseRow* row in result) {
        NSString *venueid = [row stringForColumn:@"venueid"];
        NSString *venuename = [dictId2Name objectForKey:venueid];
        NSString *date = [row stringForColumn:@"date"];
        double bill = [row doubleForColumn:@"bill"];
        NSString *comment = [row stringForColumn:@"comment"];
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
        [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
        
        
        NSDate *billdate = [dateFormatter dateFromString:date];
        [dateFormatter setDateFormat:@"yyyy-MM-dd"];
        NSString * dateString = [dateFormatter stringFromDate:billdate];

        NSString *strbill = [NSString stringWithFormat:@"%@,%@,%.2f,%@\n",venuename,dateString,bill,comment];
        NSLog(@"%@",strbill);
        [strContent appendString:strbill];
        
    }
    
    [database close];
    
    //write to csv bill file
    NSString *strAttachment = [NSTemporaryDirectory() stringByAppendingPathComponent:@"MapCostBills.csv"];
    BOOL bret = [strContent writeToFile:strAttachment atomically:YES encoding:NSUTF8StringEncoding error:nil];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setUsernameLabel:nil];
    [self setLogoutButton:nil];
    [self setFooter:nil];
    [super viewDidUnload];
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.nearbyVenues.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if (self.nearbyVenues.count) {
        return 1;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        cell.textLabel.font = [UIFont fontWithName:@"Avenir Next Condensed" size:14];
        cell.detailTextLabel.font = [UIFont fontWithName:@"Avenir Next Condensed" size:12];
        cell.detailTextLabel.textColor = [UIColor lightGrayColor];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    cell.textLabel.text = [self.nearbyVenues[indexPath.row] name];
    FSVenue *venue = self.nearbyVenues[indexPath.row];
    if (venue.location.distance && venue.location.address) {
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@m, %@",
                                     venue.location.distance,
                                     venue.location.address];
    }
    else if (venue.location.address) {
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@",
                                     venue.location.address];
    }else if(venue.location.distance){
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@m",
                                     venue.location.distance];
    }
    
    if ([venue isKindOfClass:[MyVenue class]]) {
        cell.textLabel.textColor = [UIColor colorWithHexString:@"00AB72"];
    }
    else{
        cell.textLabel.textColor = [UIColor blackColor];
    }

    return cell;
}



#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    self.selected = self.nearbyVenues[indexPath.row];

    ThisVenuesViewController *this = [[ThisVenuesViewController alloc] initWithVenues:self.selected];
    //AppDelegate *app = (AppDelegate *)[UIApplication sharedApplication].delegate;
    //[app.navigationController pushViewController:this animated:YES];
    [self.navigationController pushViewController:this animated:YES];
    //   [self.navigationController pushViewController:this animated:YES];
     
 //   [self playsound:1];
    
}
@end
