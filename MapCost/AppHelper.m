//
//  AppHelper.m
//  myshoe
//
//  Created by andy on 13-4-17.
//  Copyright (c) 2013年 somolo. All rights reserved.
//

#import "AppHelper.h"
#import "EGODatabase.h"
#import "UIImage+fixOrientation.h"

@implementation AppHelper

static AppHelper *instance = nil;

+ (AppHelper*)sharedInstance
{
    @synchronized(self){
        if (instance == nil) {
            instance = [[AppHelper alloc]init];
            [instance start];
        }
    }
    return instance;
}

- (void)start
{

}
- (NSString*)currentDateString
{    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setTimeStyle:NSDateFormatterMediumStyle];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
//    [dateFormatter setDateFormat:@"yyyy-MM-dd"];

    return [dateFormatter stringFromDate:[NSDate date]];
}

- (void)initDatabase
{
    //最终数据库路径
    NSString *dbPath  = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/database.db"];
    
    NSFileManager *fm = [NSFileManager defaultManager];
    if(![fm fileExistsAtPath:dbPath])
    {
        EGODatabase* database = [EGODatabase databaseWithPath:dbPath];
        
        //create main table
        NSString *strSql = @"create table if not exists main(id integer primary key asc, shoeid text,name text,adddate text,comment text);";
        [database executeQuery:strSql];
        
        //create timeline table
        strSql = @"create table if not exists timeline(id integer primary key asc, shoeid text,type integer,signtime text,comment text);";
        [database executeQuery:strSql];

        [database close];
    }
}

- (void)upgrade
{
    if (!self.iap) {
        InAppPurchaseManager *purchase = [[InAppPurchaseManager alloc] init];
        self.iap = purchase;
    }
    
    [self.iap loadStore];
}

- (void)restore
{
    
    if (!self.iap) {
        InAppPurchaseManager *purchase = [[InAppPurchaseManager alloc] init];
        self.iap = purchase;
    }
    
    [self.iap restore];
}

- (BOOL)readPurchaseInfo
{
    
    NSUserDefaults *pref = [NSUserDefaults standardUserDefaults];
    int value = [pref integerForKey:@"purchased"];
    if (value == 1) {
        return TRUE;
    }
    return FALSE;
}

- (BOOL)writePurchaseInfo
{
    NSUserDefaults *pref = [NSUserDefaults standardUserDefaults];
    [pref setInteger:1 forKey:@"purchased"];
    
    return TRUE;
}

- (int)getCurrentTheme
{
    NSUserDefaults *pref = [NSUserDefaults standardUserDefaults];
    int value = [pref integerForKey:@"themeid"];
    
    if (value > 100) {
        value = 0;
    }
    
    return value;
}

- (void)setCurrentTheme:(int)themeid
{
    NSUserDefaults *pref = [NSUserDefaults standardUserDefaults];
    [pref setInteger:themeid forKey:@"themeid"];
}

//一个月不使用就提醒
- (void)addNotification {
/*    UILocalNotification *localNotification = [[UILocalNotification alloc] init];
    NSDate *today = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];

    
    [dateFormatter setDateFormat:@"YYYY"];
    NSString *stryear = [dateFormatter stringFromDate:today];
    [dateFormatter setDateFormat:@"MM"];
    NSString *strmonth = [dateFormatter stringFromDate:today];
    [dateFormatter setDateFormat:@"dd"];
    NSString *strday = [dateFormatter stringFromDate:today];
        
    NSString *strFutureDate = nil;
    
    if ([strmonth intValue] == 12)
    {
        strFutureDate = [NSString stringWithFormat:@"%d-%d-%d",[stryear intValue] + 1, 1,[strday intValue]];
    }
    else
    {
        strFutureDate = [NSString stringWithFormat:@"%d-%d-%d",[stryear intValue], [strmonth intValue] + 1, [strday intValue]];
    }
    
    NSLog(@"%@",strFutureDate);

    [dateFormatter setTimeStyle:kCFDateFormatterMediumStyle];
    [dateFormatter setDateStyle:kCFDateFormatterMediumStyle];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
//    NSDate *dd = [dateFormatter dateFromString:strFutureDate];
//    NSString *strToday = [dateFormatter stringFromDate:dd];
    localNotification.fireDate = [dateFormatter dateFromString:strFutureDate];
    localNotification.alertBody = @"Your shoes miss you!";
    localNotification.soundName = UILocalNotificationDefaultSoundName;

    
//    NSDictionary *infoDict = [NSDictionary dictionaryWithObjectsAndKeys:@"Object 1", @"Key 1", @"Object 2", @"Key 2", nil];
//    localNotification.userInfo = infoDict;
    
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    localNotification.applicationIconBadgeNumber = 0;
//    [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
    [localNotification release];*/
}

@end
