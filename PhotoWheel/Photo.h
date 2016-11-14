//
//  Photo.h
//  PhotoWheelPrototype
//
//  Created by Kyle Lutes on 9/10/13.
//  Copyright (c) 2013 Kyle Lutes All rights reserved.
//

#import "_Photo.h"

@interface Photo : _Photo

- (void)saveImage:(UIImage *)newImage;

- (UIImage *)originalImage;
- (UIImage *)largeImage;
- (UIImage *)thumbnailImage;
- (UIImage *)smallImage;

@end
