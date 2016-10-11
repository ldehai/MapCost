//
//  AppDelegate.m
//  MapCost
//
//  Created by andy on 13-8-15.
//  Copyright (c) 2013年 AM Studio. All rights reserved.
//

#import "AppDelegate.h"

#import "ViewController.h"
#import "NearbyVenuesViewController.h"
#import "Foursquare2.h"
#import "SettingViewController.h"
//#import "BakerAnalyticsEvents.h"

@interface AppDelegate()<CLLocationManagerDelegate>
{
    CLLocationManager *_locationManager;
    CLLocationCoordinate2D _locationCoordinate2D;
}

@end
@implementation AppDelegate
@synthesize viewController;

- (void)initializeiCloudAccess {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if ([[NSFileManager defaultManager]
             URLForUbiquityContainerIdentifier:nil] != nil)
            NSLog(@"iCloud is available\n");
        else
            NSLog(@"This tutorial requires iCloud, but it is not available.\n");
    });
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
   // [self initializeiCloudAccess];
    [Foursquare2 setupFoursquareWithKey:@"SBJW3CUDLI2BV32IZBYI0TIRTJ5XDB550TCX3IXKT4JMMSI5"
                                 secret:@"W5GBRV4KKN5CRCUYBTDPWM1VXGWKC4OHCDU2Q0HVDJ5D1UNQ"
                            callbackURL:@"mapcost"];

    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    
    self.viewController = [[NearbyVenuesViewController alloc] initWithNibName:@"NearbyVenuesViewController" bundle:nil];
    self.navigationController = [[UINavigationController alloc]initWithRootViewController:self.viewController];
    [self.window addSubview:[self.navigationController view]];
    self.window.rootViewController = self.navigationController;

    [self.window makeKeyAndVisible];

//    [BakerAnalyticsEvents sharedInstance]; // Initialization
    [[NSNotificationCenter defaultCenter] postNotificationName:@"AppStart" object:self]; // -> Analytics Event
    
    if (![CLLocationManager locationServicesEnabled]) {
        
    }else if ([CLLocationManager authorizationStatus]==kCLAuthorizationStatusNotDetermined){
        _locationManager=[[CLLocationManager alloc]init];
        
        [_locationManager requestWhenInUseAuthorization];
    }
    //定位管理器
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    
    //被禁用了,提示用户到系统设置中打开
    if(status == kCLAuthorizationStatusDenied){
//        SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:@"提醒" andMessage:@"频道需要根据您的位置提供相关的频道信息。您未开启定位服务，请到频道设置中开启。"];
//        [alertView addButtonWithTitle:@"取消"
//                                 type:SIAlertViewButtonTypeDestructive
//                              handler:^(SIAlertView *alert) {
//                                  [alert dismissAnimated:YES];
//                              }];
//        [alertView addButtonWithTitle:@"设置"
//                                 type:SIAlertViewButtonTypeDefault
//                              handler:^(SIAlertView *alert) {
//                                  NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
//                                  if([[UIApplication sharedApplication] canOpenURL:url]) {
//                                      [[UIApplication sharedApplication] openURL:url];
//                                  }
//                                  
//                                  [alert dismissAnimated:YES];
//                              }];
//        alertView.transitionStyle = SIAlertViewTransitionStyleBounce;
//        [alertView show];
    }
    //已经获取了权限
    else{
//        if (status == kCLAuthorizationStatusAuthorizedWhenInUse) {
            [_locationManager requestWhenInUseAuthorization];
            [_locationManager startUpdatingLocation];
//        }
    }
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
