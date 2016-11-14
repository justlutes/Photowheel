//
//  PhotoBrowserViewController.h
//  PhotoWheel
//
//  Created by Kyle Lutes on 10/10/13.
//  Copyright (c) 2013 Kyle Lutes All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PhotoBrowserViewController : UIViewController <UIScrollViewDelegate>

@property (nonatomic, weak) IBOutlet UIScrollView *scrollView;
@property (nonatomic, assign) NSInteger startAtIndex;
@property (nonatomic, strong) NSArray *photos;

- (void)toggleChromeDisplay;                                            


@end
