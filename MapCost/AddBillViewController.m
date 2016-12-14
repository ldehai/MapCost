//
//  AddBillViewController.m
//
//  Created by Andy on 13-8-18.
//  Copyright (c) 2013年 AM Studio. All rights reserved.
//

#import "AppDelegate.h"
#import "AddBillViewController.h"
#import "BiLLInfo.h"
#import "UIImage+fixOrientation.h"

@interface AddBillViewController ()<UITextFieldDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>
{
    NSString *tag;
    UILabel *label;
    UIImagePickerController *uip;
    
    NSInteger nStatus;
}

@property(retain,nonatomic)UIButton *button;
@property(retain,nonatomic)NSMutableString *string;
@property(assign,nonatomic)double num1,num2,num3,num4;
@property(nonatomic,retain)UILabel *lbbackground;

@end

@implementation AddBillViewController
#define LEFT_EDGE 30
#define BUTTON_WIDTH 50
#define BUTTON_HEIGHT 45

typedef enum CalStatus{
    CalStatusEqual = 0,
    CalStatusCancel = 1,
    CalStatusOK = 2
}CalStatus;

@synthesize button,label,string,num1,num2,num3,num4;//string保存字符，显示数值。num1是存输入的数值，num2是存运算符前的数值，num3是运算结果，num4是判断进行何种运算
@synthesize bill,comment,btnequal,delegate,venueId;

- (id)initWithBill:(BiLLInfo*)billInfo
{
    self = [super init];
    if (self) {
        self.bill = billInfo;
    }
    
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"Add Bill";
    UIBarButtonItem *barbtn = [[UIBarButtonItem alloc] initWithTitle:@"Close" style:UIBarButtonItemStylePlain target:self action:@selector(goback)];
    [barbtn setBackgroundImage:[UIImage new] forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    self.navigationItem.leftBarButtonItem = barbtn;
    
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"camera@2x"] style:UIBarButtonItemStylePlain target:self action:@selector(takePhoto:)];
    
    [addButton setBackgroundImage:[UIImage new] forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
  //  self.navigationItem.rightBarButtonItem = addButton;
    
   // self.label.font = [UIFont fontWithName:@"DB LCD Temp" size:24.0];
    if (self.bill.bill != 0) {
        self.comment.text = self.bill.comment;
        self.label.text = [NSString stringWithFormat:@"%.2f",self.bill.bill];
    }
    else{
        self.label.text = @"0.00";
    }

    [self.img setContentMode:UIViewContentModeScaleAspectFill];
    [self.img setClipsToBounds:YES];
    [self.img setImage:[UIImage imageWithContentsOfFile:self.bill.imagepath]];
    [self createCalculate];
    
    nStatus = CalStatusCancel;
}
    
- (void)goback
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    else
    {
        [self.delegate cancel];
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    [self.view setBackgroundColor:[UIColor clearColor]];
    [self.view setOpaque:1];
}

//渐隐渐现
- (void)viewDidAppear:(BOOL)animated
{
//    [UIView animateWithDuration:0.6
//                     animations:^{
//                         self.view.alpha = 1.0;
//                     }];
//
}

- (void)highlightButton:(UIButton *)b {
    [b setHighlighted:YES];
}

-(void)createCalculate
{
    self.string=[[NSMutableString alloc]init];//初始化可变字符串，分配内存
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self.comment resignFirstResponder];
    
    if (![self.comment.text isEqualToString:self.bill.comment]) {
        //[btnequal setTitle:@"OK" forState:UIControlStateNormal];
        nStatus = CalStatusOK;
        [btnequal setImage:[UIImage imageNamed:@"check@2x"] forState:UIControlStateNormal];
    }
    
    [self presentViewController:[UIViewController new] animated:NO completion:^{ [self dismissViewControllerAnimated:NO completion:nil]; }];
    
    return YES;
}

-(void)saveBill
{
    if ([self.label.text isEqualToString:@""]) {
        [self.delegate cancel];
        return;
    }
    if (!self.bill) {
        self.bill = [[BiLLInfo alloc]init];
    }
    if (comment.text == nil) {
        comment.text = @"";
    }
    NSLog(@"%@",self.comment.text);
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    [dateFormatter setTimeStyle:NSDateFormatterMediumStyle];
    [dateFormatter setDateFormat:@"yyyyMMddhhmmss"];
    NSString *imageid = [dateFormatter stringFromDate:[NSDate date]];
    
    self.bill.bill = [self.label.text doubleValue];
    self.bill.comment = self.comment.text;
    self.bill.tag = tag;
    self.bill.venueId = self.venueId;
    
    //照片名
    if (self.img) {
        NSString *imageName  = [NSString stringWithFormat:@"%@.png",imageid];
        NSString *pngPath = [NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"Documents/%@", imageName]];
        UIImage *image = self.img.image;
//        CGSize size = [[UIScreen mainScreen] bounds].size;
//        
//        CGSize scaledsize = CGSizeMake(size.width/2,size.height/2);
//        if (image.size.width > image.size.height) {
//            scaledsize = CGSizeMake(size.height/2,size.width/2);
//        }
//        image = [image scaleToSize:scaledsize];
//        
//        [UIImagePNGRepresentation(image) writeToFile:pngPath atomically:YES];
//        
        NSData *imageData;
        imageData=UIImageJPEGRepresentation(image, 0.5);
        if ([imageData writeToFile:pngPath atomically:YES]) {
            NSLog(@"保存图片成功");
        }
        
        self.bill.imagepath = pngPath;
    }
    
    [self.delegate savebill:self.bill];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)btndown:(id)sender {
    [sender setBackgroundColor:[UIColor grayColor]];
}

- (IBAction)digitclick:(id)sender {
        
    [UIView animateWithDuration:0.1
                     animations:^{
                         [sender setBackgroundColor:[UIColor clearColor]];
                     }];
    

    
    //保证是符号时在输入数字时隐藏
    if ([self.string hasPrefix:@"+"]||[self.string hasPrefix:@"-"]||[self.string hasPrefix:@"*"]||[self.string hasPrefix:@"/"])//判断是否为运算符
    {
        [self.string setString:@""];//字符串清零
    }
    
    //最长支持8位，含小数点
    if ([self.string length]>8) {
        return;
    }
    [self.string appendString:[sender currentTitle]];//数字连续输入
    self.label.text=[NSString stringWithString:string];//显示数值
    self.num1=[self.label.text doubleValue];//保存输入的数值
    //    NSLog(@"%f",self.num1);
    
    if (nStatus == CalStatusCancel) {
        nStatus = CalStatusOK;
        [btnequal setTitle:@"" forState:UIControlStateNormal];
        [btnequal setImage:[UIImage imageNamed:@"check@2x"] forState:UIControlStateNormal];
    }
//    if ([btnequal.titleLabel.text isEqualToString:@"X"]) {
//        [btnequal setTitle:@"OK" forState:UIControlStateNormal];
//        [btnequal setImage:[UIImage imageNamed:@"check@2x"] forState:UIControlStateNormal];
//    }
}

- (IBAction)operate:(id)sender {
    [UIView animateWithDuration:0.1
                     animations:^{
                         [sender setBackgroundColor:[UIColor clearColor]];
                     }];
    
    [self.string setString:@""];//字符串清零
    [self.string appendString:[sender currentTitle]];
    
    //判断输入是+号
    if ([self.string hasPrefix:@"+"])
    {
        self.num2=self.num1;//将前面的数值保存在num2里
        self.num4=1;
    }
    //判断输入是-号
    else if([self.string hasPrefix:@"-"])
    {
        self.num2=self.num1;
        self.num4=2;
    }

    nStatus = CalStatusEqual;
    [btnequal setTitle:@"=" forState:UIControlStateNormal];
    [btnequal setImage:nil forState:UIControlStateNormal];
}

- (IBAction)clear:(id)sender {
    [UIView animateWithDuration:0.4
                     animations:^{
                         [sender setBackgroundColor:[UIColor clearColor]];
                     }];
    
    if (![self.label.text isEqualToString:@""])//判断不是空
    {
        self.label.text = @"0";
        [self.string setString:@""];
        
        btnequal.titleLabel.text = @"";
        nStatus = CalStatusCancel;
        [btnequal setImage:[UIImage imageNamed:@"cancel@2x"] forState:UIControlStateNormal];
    }
}
- (IBAction)calculate:(id)sender {
   
    if (nStatus == CalStatusCancel)
    {
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        {
            [self dismissViewControllerAnimated:YES completion:nil];
        }
        else
        {
            [self.delegate cancel];
        }
        return;
    }
    if (nStatus == CalStatusOK)
    {
        [self saveBill];
        return;
    }
    
    if (nStatus == CalStatusEqual) {
        nStatus = CalStatusOK;
        [btnequal setTitle:@"" forState:UIControlStateNormal];
        [btnequal setImage:[UIImage imageNamed:@"check@2x"] forState:UIControlStateNormal];
    }
   
    //判断输入是+号
    if (self.num4==1)
    {
        self.num3=self.num2+[self.label.text doubleValue];//[self.label.text doubleValue]是每次后输入的数字
        self.label.text=[NSString stringWithFormat:@"%.2f",self.num3];//显示结果
        self.num1=[self.label.text doubleValue];//为了可以连加。保存结果
        self.num3=0;
        [self.string setString:@""];//保证每次结果正确输出后，再次计算，不用按清除键
    }
    //判断输入是-号
    else if(self.num4==2)
    {
        self.num3=self.num2-[self.label.text doubleValue];
        self.label.text=[NSString stringWithFormat:@"%.2f",self.num3];
        self.num1=[self.label.text doubleValue];
        self.num3=0;
        [self.string setString:@""];
    }
    
    self.num4 = 0;
}

- (void)viewDidUnload {
    [self setBtnequal:nil];
    [self setComment:nil];
    [super viewDidUnload];
}

- (IBAction)btnclick:(id)sender {
    [comment resignFirstResponder];
}
- (IBAction)takePhoto:(id)sender {
    
    [comment resignFirstResponder];
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        UIImagePickerController* imagePicker = [[UIImagePickerController alloc] init];
        imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        
        imagePicker.showsCameraControls = YES;
        imagePicker.toolbarHidden = YES;
        imagePicker.navigationBarHidden = YES;
        imagePicker.wantsFullScreenLayout = NO;
        imagePicker.delegate = self;
        uip = imagePicker;
    }

    [self presentViewController:uip animated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image = [info valueForKey:UIImagePickerControllerOriginalImage];
    image = [image fixOrientation];
    [self.img setImage:image];
    
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    nStatus = CalStatusOK;
    [btnequal setTitle:@"" forState:UIControlStateNormal];
    [btnequal setImage:[UIImage imageNamed:@"check@2x"] forState:UIControlStateNormal];
    
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

@end
