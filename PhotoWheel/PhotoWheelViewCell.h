//
//  PhotoWheelViewCell.h
//  PhotoWheelPrototype
//
//  Created by Kyle Lutes on 9/10/13.
//  Copyright (c) 2013 Kyle Lutes All rights reserved.
//

#import "WheelView.h"

@interface PhotoWheelViewCell : WheelViewCell

@property (nonatomic, weak) IBOutlet UIImageView *imageView;
@property (nonatomic, weak) IBOutlet UILabel *label;

+ (PhotoWheelViewCell *)photoWheelViewCell;

@end
