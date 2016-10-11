//
//  AppHelper.h
//  myshoe
//
//  Created by andy on 13-4-17.
//  Copyright (c) 2013年 somolo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "InAppPurchaseManager.h"

#define kSaveImageSucceededNotification @"kSaveImageSucceededNotification"
#define kInAppPurchaseManagerProductsFetchedNotification @"kInAppPurchaseManagerProductsFetchedNotification"
#define kIAPTransactionFailedNotification @"kIAPTransactionFailedNotification"
#define kIAPTransactionSucceededNotification @"kIAPTransactionSucceededNotification"

typedef enum ScrollDirection {
    ScrollDirectionNone,
    ScrollDirectionRight,
    ScrollDirectionLeft,
    ScrollDirectionUp,
    ScrollDirectionDown,
    ScrollDirectionCrazy,
} ScrollDirection;

@interface AppHelper : NSObject

@property (nonatomic,strong) InAppPurchaseManager *iap;
@property (nonatomic,strong) UIView *HUDView;

+ (AppHelper*)sharedInstance;

- (void)upgrade;
- (void)restore;
- (BOOL)readPurchaseInfo;
- (BOOL)writePurchaseInfo;
//- (void)addNotification;
- (int)getCurrentTheme;
- (void)setCurrentTheme:(int)themeid;
@end
