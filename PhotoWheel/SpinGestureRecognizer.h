//
//  SpinGestureRecognizer.h
//  PhotoWheelPrototype
//
//  Created by Kyle Lutes on 9/10/13.
//  Copyright (c) 2013 Kyle Lutes All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SpinGestureRecognizer : UIGestureRecognizer

/**
 The rotation of the gesture in radians since its last change.
 */
@property (nonatomic, assign) CGFloat rotation;

@end
