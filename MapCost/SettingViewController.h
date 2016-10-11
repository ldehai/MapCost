//
//  SettingViewController.h
//  myshoe
//
//  Created by andy on 13-4-25.
//  Copyright (c) 2013年 somolo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SettingViewController : UIViewController

@property (strong, nonatomic) IBOutlet UITableView *setTable;
@property (strong, nonatomic) IBOutlet UILabel *name;
@property (strong, nonatomic) IBOutlet UIImageView *logoimage;
@property (strong, nonatomic) IBOutlet UILabel *namelabel;
- (IBAction)cancel:(id)sender;
@property (strong, nonatomic) IBOutlet UIButton *cancelBtn;
@property (weak, nonatomic) IBOutlet UILabel *verlabel;
- (IBAction)openTumblr:(id)sender;
- (IBAction)openFacebook:(id)sender;
- (IBAction)openTwitter:(id)sender;
- (IBAction)openGithub:(id)sender;
@end
