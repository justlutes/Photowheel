//
//  PhotoBrowserPhotoView.h
//  PhotoWheel
//
//  Created by Kyle Lutes on 10/10/13.
//  Copyright (c) 2013 Kyle Lutes All rights reserved.
//

#import <UIKit/UIKit.h>

@class PhotoBrowserViewController;

@interface PhotoBrowserPhotoView : UIScrollView <UIScrollViewDelegate>


@property (nonatomic, assign) NSInteger index;
@property (nonatomic, weak) PhotoBrowserViewController
*photoBrowserViewController;

- (void)setImage:(UIImage *)newImage;
- (void)turnOffZoom;                                                    

@end
