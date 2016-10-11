//
//  UpgradeViewController.h
//  myshoe
//
//  Created by andy on 13-4-25.
//  Copyright (c) 2013年 somolo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "InAppPurchaseManager.h"

@interface UpgradeViewController : UIViewController

@property (nonatomic,retain) InAppPurchaseManager *iap;
@property (retain, nonatomic) IBOutlet UILabel *lbprice;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *indicator;
- (IBAction)back:(id)sender;
- (IBAction)upgrade:(id)sender;
- (IBAction)restore:(id)sender;

@end
