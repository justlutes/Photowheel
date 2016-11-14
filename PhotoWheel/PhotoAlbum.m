//
//  PhotoAlbum.m
//  PhotoWheelPrototype
//
//  Created by Kyle Lutes on 9/10/13.
//  Copyright (c) 2013 Kyle Lutes All rights reserved.
//

#import "PhotoAlbum.h"
#import "Photo.h"

@implementation PhotoAlbum

- (void)awakeFromInsert
{
   [super awakeFromInsert];
   [self setDateAdded:[NSDate date]];
}

+ (PhotoAlbum *)newPhotoAlbumWithName:(NSString *)albumName
                            inContext:(NSManagedObjectContext *)context
{
   PhotoAlbum *newAlbum = [NSEntityDescription
                           insertNewObjectForEntityForName:@"PhotoAlbum"
                           inManagedObjectContext:context];
   [newAlbum setName:albumName];
   
   NSMutableOrderedSet *photos =
      [newAlbum mutableOrderedSetValueForKey:@"photos"];
   for (int index=0; index<10; index++) {
      Photo *placeholderPhoto = [NSEntityDescription
                                 insertNewObjectForEntityForName:@"Photo"
                                 inManagedObjectContext:context];
      [photos addObject:placeholderPhoto];
   }
   return newAlbum;
}

+ (NSMutableOrderedSet *)allPhotoAlbumsInContext:
   (NSManagedObjectContext *)context
{
   NSFetchRequest *fetchRequest = [NSFetchRequest
                                fetchRequestWithEntityName:@"PhotoAlbum"];
   
   NSSortDescriptor *sortDescriptor = [NSSortDescriptor
                                       sortDescriptorWithKey:@"name"
                                       ascending:YES];
   NSArray *sortDescriptors = @[sortDescriptor];
   [fetchRequest setSortDescriptors:sortDescriptors];
   
   NSError *error = nil;
   NSArray *photoAlbums = [context executeFetchRequest:fetchRequest
                                                 error:&error];
   
   if (photoAlbums != nil) {
      return [NSMutableOrderedSet orderedSetWithArray:photoAlbums];
   } else {
      return [NSMutableOrderedSet orderedSet];
   }
}

@end
