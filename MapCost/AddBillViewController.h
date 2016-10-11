//
//  AddBillViewController.h
//  trip
//
//  Created by Andy on 13-3-7.
//  Copyright (c) 2013年 souxiang. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TripInfo;
@class BiLLInfo;
@protocol AddBillDelegate <NSObject>
-(void)savebill:(BiLLInfo*)bill;
-(void)cancel;
@end

@interface AddBillViewController : UIViewController

@property (nonatomic,strong) NSString *venueId;
@property (nonatomic,strong)BiLLInfo *bill;
@property (nonatomic,weak) id<AddBillDelegate> delegate;
@property (strong, nonatomic) IBOutlet UITextField *comment;
@property (strong, nonatomic) IBOutlet UILabel *label;
@property (strong, nonatomic) IBOutlet UIButton *btnequal;
@property (strong, nonatomic) IBOutlet UIButton *btnlocation;
@property (weak, nonatomic) IBOutlet UIImageView *img;

- (id)initWithBill:(BiLLInfo*)billInfo;
- (IBAction)btnclick:(id)sender;

- (IBAction)btndown:(id)sender;
- (IBAction)digitclick:(id)sender;
- (IBAction)operate:(id)sender;
- (IBAction)clear:(id)sender;
- (IBAction)calculate:(id)sender;
- (IBAction)takePhoto:(id)sender;
@end
