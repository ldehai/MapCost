//
//  TimerTableViewCell.m
//  ElapseTimer
//
//  Created by andy on 13-6-5.
//  Copyright (c) 2013年 AM Studio. All rights reserved.
//

#import "TableViewCell.h"
#import <QuartzCore/QuartzCore.h>

@implementation TableViewCell
@synthesize dateTextLabel;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
    if (self) {
        self.textLabel.font = [UIFont fontWithName:@"Avenir Next Condensed" size:14];
        self.textLabel.backgroundColor = self.contentView.backgroundColor;
		self.detailTextLabel.font = [UIFont fontWithName:@"Avenir Next Condensed" size:14];
        self.detailTextLabel.backgroundColor = self.contentView.backgroundColor;
        CGSize size = [UIScreen mainScreen].bounds.size;
        self.dateTextLabel = [[UILabel alloc]initWithFrame:CGRectMake(size.width-110, 10, 100, CGRectGetHeight(self.contentView.frame))];
        self.dateTextLabel.font = [UIFont fontWithName:@"Avenir Next Condensed" size:14];
        self.dateTextLabel.textColor = self.detailTextLabel.textColor;
        self.dateTextLabel.backgroundColor = self.contentView.backgroundColor;
        self.dateTextLabel.textAlignment = NSTextAlignmentRight;
        [self.contentView addSubview:self.dateTextLabel];
    }
    return self;
}

-(UIImageView*)actionImageView {
    if (!_actionImageView) {
        _actionImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetHeight(self.frame), CGRectGetHeight(self.frame))];
        [_actionImageView setImage:[UIImage imageNamed:@"CheckmarkGrey"]];
        [_actionImageView setContentMode:UIViewContentModeCenter];
        [self.backView addSubview:_actionImageView];
    }
    return _actionImageView;
}

-(UIImageView*)deleteImageView {
    if (!_deleteImageView) {
        _deleteImageView = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.contentView.frame), 0, CGRectGetHeight(self.frame), CGRectGetHeight(self.frame))];
        [_deleteImageView setImage:[UIImage imageNamed:@"DeleteGrey"]];
        [_deleteImageView setContentMode:UIViewContentModeCenter];
        [self.backView addSubview:_deleteImageView];
    }
    return _deleteImageView;
}

-(void)prepareForReuse {
	[super prepareForReuse];
    self.cycleLabel.text = @"";
	self.textLabel.textColor = [UIColor blackColor];
	self.detailTextLabel.text = nil;
	self.detailTextLabel.textColor = [UIColor grayColor];
    self.dateTextLabel.text = nil;
	self.dateTextLabel.textColor = [UIColor grayColor];
	[self setUserInteractionEnabled:YES];
	self.imageView.alpha = 1;
	self.accessoryView = nil;
	self.accessoryType = UITableViewCellAccessoryNone;
    [self.contentView setHidden:NO];
    [_checkmarkProfileImageView removeFromSuperview];
    _checkmarkProfileImageView = nil;
    [self cleanupBackView];
}

-(void)layoutSubviews {
    [super layoutSubviews];
}

-(void)setThumbnail:(UIImage*)image {
	[self.profileImageView setImage:image];
}

//父类方法移动单元格，子类设置要显示的背景
-(void)animateContentViewForPoint:(CGPoint)translation velocity:(CGPoint)velocity {
    [super animateContentViewForPoint:translation velocity:velocity];
    //NSLog(@"cellcontentview height %f",self.contentView.frame.size.height);
    
    if (translation.x > 0) {
        [self.actionImageView setFrame:CGRectMake(MAX(CGRectGetMinX(self.contentView.frame) - CGRectGetWidth(self.actionImageView.frame), 0), CGRectGetMinY(self.actionImageView.frame), CGRectGetWidth(self.actionImageView.frame), CGRectGetHeight(self.actionImageView.frame))];

            //if (self.contentView.frame.origin.x < 2*CGRectGetWidth(self.actionImageView.frame)) {
        if (translation.x <= 1.5*self.contentView.frame.size.height) {
            [self.actionImageView setImage:[UIImage imageNamed:@"trash"]];
                self.backView.backgroundColor = [UIColor colorWithWhite:0.92 alpha:1];
                [self.actionImageView setAlpha:(self.contentView.frame.origin.x/self.actionImageView.frame.size.width)];
                
            }else// if (self.contentView.frame.origin.x > 2*CGRectGetWidth(self.actionImageView.frame))
            {
                [self.actionImageView setImage:[UIImage imageNamed:@"trash"]];
                self.backView.backgroundColor = [UIColor colorWithRed:239.0/255 green:84.0/255.0 blue:12.0/255 alpha:1.0];//[UIColor greenColor];
                
            }
    }
    else if (translation.x < 0) {
        [self.deleteImageView setFrame:CGRectMake(MIN(CGRectGetMaxX(self.frame) - CGRectGetWidth(self.deleteImageView.frame), CGRectGetMaxX(self.contentView.frame)), CGRectGetMinY(self.deleteImageView.frame), CGRectGetWidth(self.deleteImageView.frame), CGRectGetHeight(self.deleteImageView.frame))];
        if (fabs(translation.x) <= 1.5*self.contentView.frame.size.height) {
            [self.deleteImageView setImage:[UIImage imageNamed:@"trash"]];
            self.backView.backgroundColor = [UIColor colorWithWhite:0.92 alpha:1];
            [self.actionImageView setAlpha:(self.contentView.frame.origin.x/self.actionImageView.frame.size.width)];
        }
        else
        {
            [self.deleteImageView setImage:[UIImage imageNamed:@"trash"]];
            self.backView.backgroundColor = [UIColor colorWithRed:239.0/255 green:84.0/255.0 blue:12.0/255 alpha:1.0];
        }
    }
}

-(void)resetCellFromPoint:(CGPoint)translation velocity:(CGPoint)velocity {
    [super resetCellFromPoint:translation velocity:velocity];
    if (translation.x > 0 && translation.x < CGRectGetHeight(self.frame) * 2) {
        [UIView animateWithDuration:0.2
                         animations:^{
                             [self.actionImageView setFrame:CGRectMake(-CGRectGetWidth(self.actionImageView.frame), CGRectGetMinY(self.actionImageView.frame), CGRectGetWidth(self.actionImageView.frame), CGRectGetHeight(self.actionImageView.frame))];
                         }];
    } else if (translation.x < 0) {
        [UIView animateWithDuration:0.2
                         animations:^{
                             [self.deleteImageView setFrame:CGRectMake(CGRectGetMaxX(self.frame), CGRectGetMinY(self.deleteImageView.frame), CGRectGetWidth(self.deleteImageView.frame), CGRectGetHeight(self.deleteImageView.frame))];
                         }];
    }
}

-(void)cleanupBackView {
    [super cleanupBackView];
    [_actionImageView removeFromSuperview];
    _actionImageView = nil;

    [_deleteImageView removeFromSuperview];
    _deleteImageView = nil;
}

@end
