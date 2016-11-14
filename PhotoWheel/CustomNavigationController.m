//
//  CustomNavigationController.m
//  PhotoWheel
//
//  Created by Kyle Lutes on 9/15/13.
//  Copyright (c) 2013 Kyle Lutes All rights reserved.
//

#import "CustomNavigationController.h"
#import "UIView+PWCategory.h"
#import "MainViewController.h"

@interface CustomNavigationController ()

@end

@implementation CustomNavigationController

- (UIViewController *)popViewControllerAnimated:(BOOL)animated
{
   UIViewController *sourceViewController = [self topViewController];
   
   // Animates image snapshot of the view
   UIView *sourceView = [sourceViewController view];
   UIImage *sourceViewImage = [sourceView pw_imageSnapshot];
   UIImageView *sourceImageView = [[UIImageView alloc]
                                   initWithImage:sourceViewImage];
   
    // Offset the sourceImageView frame by the height of the status bar.
    // This prevents the image from dropping down after the view controller
    // is popped from the stack.
    UIInterfaceOrientation orientation;
    orientation = [sourceViewController interfaceOrientation];
    BOOL isLandscape = UIInterfaceOrientationIsLandscape(orientation);   // 2
    
    UIApplication *app = [UIApplication sharedApplication];
    CGRect statusBarFrame = [app statusBarFrame];
    CGFloat statusBarHeight;
    if (isLandscape) {
        statusBarHeight = statusBarFrame.size.width;
    } else {
        statusBarHeight = statusBarFrame.size.height;
    }
    CGRect newFrame;
    newFrame = CGRectOffset([sourceImageView frame], 0, -statusBarHeight);
    [sourceImageView setFrame:newFrame];
    
    
    NSArray *viewControllers = [self viewControllers];
    NSInteger count = [viewControllers count];
    NSInteger index = count - 2;
    
    id destinationViewController = nil;
    destinationViewController = [viewControllers objectAtIndex:index];
    UIView *destinationView = [destinationViewController view];
    UIImage *destinationViewImage = [destinationView pw_imageSnapshot];
    UIImageView *destinationImageView = nil;
    destinationImageView = [[UIImageView alloc] initWithImage:destinationViewImage];
   
   [super popViewControllerAnimated:NO];
   
   [destinationView addSubview:destinationImageView];
   [destinationView addSubview:sourceImageView];
   
    CGRect selectedPhotoFrame = [destinationViewController selectedPhotoFrame];
    CGPoint shrinkToPoint = CGPointMake(CGRectGetMidX(selectedPhotoFrame),
                                        CGRectGetMidY(selectedPhotoFrame));
   
   void (^animations)(void) = ^ {
      [sourceImageView setFrame:CGRectMake(shrinkToPoint.x,
                                           shrinkToPoint.y,
                                           0,
                                           0)];
      [sourceImageView setAlpha:0.0];
      
      // Animate the nav bar too
      UINavigationBar *navBar = [self navigationBar];
      [navBar setFrame:CGRectOffset(navBar.frame, 0, -navBar.frame.size.height)];
   };
   
   void (^completion)(BOOL) = ^(BOOL finished) {
      [self setNavigationBarHidden:YES];
      // Reset the nav bar position
      UINavigationBar *navBar = [self navigationBar];
      [navBar setFrame:CGRectOffset(navBar.frame, 0, navBar.frame.size.height)];
      
      [sourceImageView removeFromSuperview];
      [destinationImageView removeFromSuperview];
   };
   
   [UIView transitionWithView:destinationView
                     duration:2.0
                      options:UIViewAnimationOptionTransitionNone
                   animations:animations
                   completion:completion];
   
   return sourceViewController;
}

@end
