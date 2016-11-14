//
//  _Photo.h
//  PhotoWheelPrototype
//
//  Created by Kyle Lutes on 9/10/13.
//  Copyright (c) 2013 Kyle Lutes All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class _PhotoAlbum;

@interface _Photo : NSManagedObject

@property (nonatomic, retain) NSDate * dateAdded;
@property (nonatomic, retain) NSData * originalImageData;
@property (nonatomic, retain) NSData * thumbnailImageData;
@property (nonatomic, retain) NSData * largeImageData;
@property (nonatomic, retain) NSData * smallImageData;
@property (nonatomic, retain) _PhotoAlbum *photoAlbum;

@end
