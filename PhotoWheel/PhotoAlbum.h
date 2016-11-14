//
//  PhotoAlbum.h
//  PhotoWheelPrototype
//
//  Created by Kyle Lutes on 9/10/13.
//  Copyright (c) 2013 Kyle Lutes All rights reserved.
//

#import "_PhotoAlbum.h"

@interface PhotoAlbum : _PhotoAlbum

+ (PhotoAlbum *)newPhotoAlbumWithName:(NSString *)albumName inContext:(NSManagedObjectContext *)context;
+ (NSMutableOrderedSet *)allPhotoAlbumsInContext:(NSManagedObjectContext *)context;

@end
