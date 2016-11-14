//
//  PhotosViewController.h
//  PhotoWheel
//
//  Created by Kyle Lutes on 9/10/13.
//  Copyright (c) 2013 Kyle Lutes All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PhotosViewController : UIViewController

@property (nonatomic, assign, readonly) NSInteger selectedPhotoIndex;
@property (nonatomic, assign, readonly) CGRect selectedPhotoFrame;


- (NSArray *)photos;
- (UIImage *)selectedPhotoImage;



@end
