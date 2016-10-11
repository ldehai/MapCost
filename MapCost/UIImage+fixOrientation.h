//
//  UIImage+fixOrientation.h
//  myshoe
//
//  Created by andy on 13-4-19.
//  Copyright (c) 2013年 somolo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UIImage (fixOrientation)

- (UIImage *)fixOrientation;
- (UIImage *)scaleToSize:(CGSize)size;
- (UIImage *)crop:(CGRect)rect;
@end
