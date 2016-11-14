//
//  MainViewController.h
//  PhotoWheel
//
//  Created by Kyle Lutes on 9/10/13.
//  Copyright (c) 2013 Kyle Lutes All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MainViewController : UIViewController

@property (nonatomic, assign, readonly) CGRect selectedPhotoFrame;
@property (nonatomic, strong, readonly) UIImage *selectedPhotoImage;


@end
