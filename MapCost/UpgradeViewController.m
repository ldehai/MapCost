//
//  UpgradeViewController.m
//  myshoe
//
//  Created by andy on 13-4-25.
//  Copyright (c) 2013年 somolo. All rights reserved.
//

#import "UpgradeViewController.h"
#import "AppDelegate.h"
#import "AppHelper.h"
//#import "MBProgressHUD.h"
//#import "Reachability.h"
#import "UIButton+Custom.h"
#import "SVProgressHUD.h"

@interface UpgradeViewController ()

@end

@implementation UpgradeViewController
@synthesize lbprice,iap;

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
    // Do any additional setup after loading the view from its nib.
    
    [self setTitle:@"Upgrade Pro"];
    [self addNavigationButton];
    
    
    [self.indicator setHidesWhenStopped:YES];
    [self.indicator startAnimating];
    [[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(updateProductPrice)
												 name:kInAppPurchaseManagerProductsFetchedNotification
											   object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(purchaseSuccess)
												 name:kIAPTransactionSucceededNotification
											   object:nil];

    self.iap = [InAppPurchaseManager sharedInstance];
    self.iap.type = 1;
    [self.iap loadStore];
    
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
    [btn addTarget:self action:@selector(goback) forControlEvents:UIControlEventTouchDown];
    [btn setFrame:CGRectMake(20, 0, 30, 25)];
    
    UIBarButtonItem *barbtn = [[UIBarButtonItem alloc] initWithCustomView:btn];
    [barbtn setBackgroundImage:[UIImage new] forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    self.navigationItem.leftBarButtonItem = barbtn;
    
    btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setShowsTouchWhenHighlighted:TRUE];
    //[btn setTitle:@"Upgrade" forState:UIControlStateNormal];
    //[btn CustomNavigateTitle];
    [btn setImage:[UIImage imageNamed:@"upgrade@2x.png"] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(upgrade:) forControlEvents:UIControlEventTouchUpInside];
    [btn setFrame:CGRectMake(0, 0, 20, 25)];
    barbtn = [[UIBarButtonItem alloc] initWithCustomView:btn];
    self.navigationItem.rightBarButtonItem = barbtn;
}


- (void)updateProductPrice
{
    lbprice.text = self.iap.price;
    [self.indicator stopAnimating];
}

- (void)purchaseSuccess
{
    [SVProgressHUD showSuccessWithStatus:@"Success!"];
    
    [self dismissViewControllerAnimated:YES completion:nil];
   // [self.navigationController popViewControllerAnimated:YES];
}

- (void)goback
{
    [SVProgressHUD dismiss];
    [self dismissViewControllerAnimated:YES completion:nil];
   // [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {

    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
  //  [super dealloc];
}
- (IBAction)back:(id)sender {
    
    [SVProgressHUD dismiss];
    [self.navigationController popViewControllerAnimated:YES];
    
}
- (IBAction)restore:(id)sender {
    
    [self.iap restore];
}

- (IBAction)upgrade:(id)sender {

    [SVProgressHUD show];
    
    self.iap.type = 2;
    [self.iap loadStore];
}

- (void)viewDidUnload {
    [self setLbprice:nil];
    [super viewDidUnload];
}
@end
