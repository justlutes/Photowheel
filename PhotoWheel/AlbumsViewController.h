//
//  AlbumsViewController.h
//  PhotoWheel
//
//  Created by Kyle Lutes on 9/15/13.
//  Copyright (c) 2013 Kyle Lutes All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WheelView.h"

@interface AlbumsViewController : UIViewController <NSFetchedResultsControllerDelegate, WheelViewDataSource, WheelViewDelegate>

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, weak) IBOutlet WheelView *wheelView;

- (IBAction)addPhotoAlbum:(id)sender;

@end
