//
//  UIView+PWCategory.m
//  PhotoWheel
//
//  Created by Kyle Lutes on 9/21/13.
//  Copyright (c) 2013 Kyle Lutes All rights reserved.
//

#import "UIView+PWCategory.h"
#import <QuartzCore/QuartzCore.h>

@implementation UIView (PWCategory)

- (UIImage *)pw_imageSnapshot
{
   UIGraphicsBeginImageContext([self bounds].size);
   [[self layer] renderInContext:UIGraphicsGetCurrentContext()];
   UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
   UIGraphicsEndImageContext();
   
   return image;
}

@end
