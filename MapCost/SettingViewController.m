//
//  SettingViewController.m
//  myshoe
//
//  Created by andy on 13-4-25.
//  Copyright (c) 2013年 somolo. All rights reserved.
//

#import "SettingViewController.h"
#import "AppHelper.h"
//#import "UpgradeViewController.h"
#import "AppDelegate.h"
#import <MessageUI/MessageUI.h>
//#import "ThemeViewController.h"
#import "UIDevice+IdentifierAddition.h"
//#import "Reachability.h"
//#import "MBProgressHUD.h"
//#import "Base64.h"
//#import "DonateViewController.h"

@interface SettingViewController ()<MFMailComposeViewControllerDelegate>

@property (nonatomic, strong) NSArray *dataArray;
@property (nonatomic, strong) NSArray *appArray;
@end

@implementation SettingViewController
@synthesize name;

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
    [self setTitle:@"About"];
    [self addNavigationButton];
    
    NSString *strBundleVersion = [NSString stringWithFormat:@"%@", [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]];
    self.verlabel.text = [NSString stringWithFormat:@"MapCost v %@",strBundleVersion];
    
    self.appArray = [NSArray arrayWithObjects:
                     [NSArray arrayWithObjects:@"ShoeBox",@"shoebox.png",@"Find your shoes quickly",
                      @"https://itunes.apple.com/us/app/shoebox-find-your-shoes-quickly/id640885172?ls=1&mt=8",nil],
                     
                     [NSArray arrayWithObjects:@"TripCost",@"tripcost.png",@"Split bills with friends",
                      @"https://itunes.apple.com/us/app/tripcost-split-bills-friends/id633501469?ls=1&mt=8",nil],
                     [NSArray arrayWithObjects:@"E.Timer",@"etimer.png",@"Excellent CountDown Timer",
                      @"https://itunes.apple.com/us/app/e.timer/id660765636?ls=1&mt=8",nil],nil];
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
    
}

- (void)goback
{
    [self dismissViewControllerAnimated:YES completion:nil];
//    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidAppear:(BOOL)animated
{
}

- (NSString*)tableView:(UITableView*)tableView titleForHeaderInSection:(NSInteger)section
{
    return @" ";
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.appArray.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    static NSString *AppCellIdentifier = @"appCell";
    
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:AppCellIdentifier];
    cell.textLabel.font = [UIFont fontWithName:@"Courier New" size:18];
    cell.textLabel.text = [[self.appArray objectAtIndex:indexPath.row] objectAtIndex:0];
    cell.detailTextLabel.text = [[self.appArray objectAtIndex:indexPath.row] objectAtIndex:2];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.imageView.image = [UIImage imageNamed:[[self.appArray objectAtIndex:indexPath.row] objectAtIndex:1]];

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSString *strAppUrl = [[self.appArray objectAtIndex:indexPath.row] objectAtIndex:3];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:strAppUrl]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setLogoimage:nil];
    [self setNamelabel:nil];
    [self setCancelBtn:nil];
    [super viewDidUnload];
    
}
- (IBAction)openTumblr:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://mapcost.tumblr.com"]];
}

- (IBAction)openFacebook:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://www.facebook.com/pages/Mapcost/543218942410545"]];
}

- (IBAction)openTwitter:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://www.twitter.com/ldehai"]];
}

- (IBAction)openGithub:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://github.com/ldehai/MapCost/issues"]];
}
@end
