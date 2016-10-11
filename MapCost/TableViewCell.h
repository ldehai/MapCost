//
//  TimerTableViewCell.h
//  ElapseTimer
//
//  Created by andy on 13-6-5.
//  Copyright (c) 2013年 AM Studio. All rights reserved.
//

#import "RMSwipeTableViewCell.h"

@interface TableViewCell : RMSwipeTableViewCell

@property (nonatomic, strong) UIImageView *profileImageView;
@property (nonatomic, strong) UIImageView *checkmarkProfileImageView;

//背景按钮
@property (nonatomic, strong) UIImageView *actionImageView;

@property (nonatomic,retain) UILabel *cycleLabel;
//删除按钮
@property (nonatomic, strong) UIImageView *deleteImageView;

@property (nonatomic, assign) int noticeColorStyle;
@property (nonatomic, strong) UILabel* dateTextLabel;

-(void)setThumbnail:(UIImage*)image;
@end
