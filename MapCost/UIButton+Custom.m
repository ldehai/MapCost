//
//  UIButton+Custom.m
//  Think
//
//  Created by andy on 13-11-7.
//  Copyright (c) 2013年 AM Studio. All rights reserved.
//

#import "UIButton+Custom.h"

@implementation UIButton (Custom)

- (UIButton*)CustomNavigateTitle
{
    [self setShowsTouchWhenHighlighted:TRUE];
    self.titleLabel.font = [UIFont fontWithName:@"Avenir Next Condensed" size:18];
    [self setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self setFrame:CGRectMake(0, 0, 45, 25)];
    
    return self;
}

@end
