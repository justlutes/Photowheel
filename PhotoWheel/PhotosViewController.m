//
//  PhotosViewController.m
//  PhotoWheel
//
//  Created by Kyle Lutes on 9/10/13.
//  Copyright (c) 2013 Kyle Lutes All rights reserved.
//

#import "PhotosViewController.h"
#import "PhotoAlbum.h"
#import "Photo.h"
#import "ThumbnailCell.h"

@interface PhotosViewController () <UIActionSheetDelegate,
UIImagePickerControllerDelegate, UINavigationControllerDelegate,
UICollectionViewDataSource, UICollectionViewDelegate,
NSFetchedResultsControllerDelegate>

@property (nonatomic, strong) PhotoAlbum *photoAlbum;
@property (nonatomic, weak) IBOutlet UIToolbar *toolbar;
@property (nonatomic, weak) IBOutlet UITextField *textField;
@property (nonatomic, weak) IBOutlet UIBarButtonItem *addButton;
@property (nonatomic, strong) UIImagePickerController *imagePickerController;
@property (nonatomic, strong) UIPopoverController *imagePickerPopoverController;
@property (nonatomic, assign, readwrite) NSInteger selectedPhotoIndex;
@property (nonatomic, assign, readwrite) CGRect selectedPhotoFrame;



@property (nonatomic, weak) IBOutlet UICollectionView *collectionView;
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;

- (IBAction)showActionMenu:(id)sender;
- (IBAction)addPhoto:(id)sender;
@end

@implementation PhotosViewController

- (void)dealloc
{
   NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
   [nc removeObserver:self name:kPhotoWheelDidSelectAlbum object:nil];
}

- (void)viewDidLoad
{
   [super viewDidLoad];
   NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
   [nc addObserver:self
          selector:@selector(didSelectAlbum:)
              name:kPhotoWheelDidSelectAlbum
            object:nil];

   UIImage *image = [UIImage imageNamed:@"1x1-transparent"];
   [[self toolbar] setBackgroundImage:image
                   forToolbarPosition:UIToolbarPositionAny
                           barMetrics:UIBarMetricsDefault];
    
    
     self.collectionView.backgroundColor = [UIColor colorWithRed:(26/255.0) green:(188/255.0) blue:(156/255.0) alpha:1];
    
}

- (void)didSelectAlbum:(NSNotification *)notification
{
   PhotoAlbum *photoAlbum = nil;
   NSDictionary *userInfo = [notification userInfo];
   if (userInfo) {
      photoAlbum = userInfo[@"PhotoAlbum"];
   }
   [self setPhotoAlbum:photoAlbum];
   [self reloadData];
}

- (void)reloadData
{
   PhotoAlbum *album = [self photoAlbum];
   if (album) {
      [[self toolbar] setHidden:NO];
      [[self textField] setText:[album name]];
   } else {
      [[self toolbar] setHidden:YES];
      [[self textField] setText:@""];
   }
   
   [self setFetchedResultsController:nil];
   [[self collectionView] reloadData];
}

- (void)saveChanges
{
   PhotoAlbum *album = [self photoAlbum];
   NSManagedObjectContext *context = [album managedObjectContext];
   NSError *error = nil;
   if (![context save:&error])
   {
      // Replace this implementation with code to handle the
      // error appropriately.
      NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
      abort();
   }
}

- (UIImagePickerController *)imagePickerController
{
   if (_imagePickerController) {
      return _imagePickerController;
   }

   UIImagePickerController *imagePickerController =  nil;
   imagePickerController = [[UIImagePickerController alloc] init];
   [imagePickerController setDelegate:self];
   [self setImagePickerController:imagePickerController];
   
   return _imagePickerController;
}

#pragma mark - UITextFieldDelegate methods

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
   [textField setBorderStyle:UITextBorderStyleRoundedRect];
   [textField setTextColor:[UIColor blackColor]];
   [textField setBackgroundColor:[UIColor whiteColor]];
   return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
   [textField setBackgroundColor:[UIColor clearColor]];
   [textField setTextColor:[UIColor whiteColor]];
   [textField setBorderStyle:UITextBorderStyleNone];
   
   [[self photoAlbum] setName:[textField text]];
   [self saveChanges];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
   [textField resignFirstResponder];
   return NO;
}

#pragma mark - Actions

- (IBAction)showActionMenu:(id)sender
{
   UIActionSheet *actionSheet = [[UIActionSheet alloc] init];
   [actionSheet setDelegate:self];
   [actionSheet addButtonWithTitle:@"Delete Photo Album"];
   [actionSheet showFromBarButtonItem:sender animated:YES];
}

- (IBAction)addPhoto:(id)sender
{
   if ([self imagePickerPopoverController]) {
      [[self imagePickerPopoverController] dismissPopoverAnimated:YES];
   }
   
   [self presentPhotoPickerMenu];
}

#pragma mark - Confirm and delete photo album

- (void)confirmDeletePhotoAlbum
{
   NSString *message;
   NSString *name = [[self photoAlbum] name];
   if ([name length] > 0) {
      message = [NSString stringWithFormat:
                 @"Delete the photo album \"%@\". This action cannot be undone.",
                 name];
   } else {
      message = @"Delete this photo album? This action cannot be undone.";
   }
   UIAlertView *alertView = [[UIAlertView alloc]
                             initWithTitle:@"Delete Photo Album"
                             message:message
                             delegate:self
                             cancelButtonTitle:@"Cancel"
                             otherButtonTitles:@"OK", nil];
   [alertView show];
}

#pragma mark - UIAlertViewDelegate methods

- (void)alertView:(UIAlertView *)alertView
clickedButtonAtIndex:(NSInteger)buttonIndex
{
   if (buttonIndex == 1) {
      PhotoAlbum *album = [self photoAlbum];
      NSManagedObjectContext *context = [album managedObjectContext];
      [context deleteObject:album];
      [self saveChanges];
      [self setPhotoAlbum:nil];
      [self reloadData];
   }
}

#pragma mark - UIActionSheetDelegate methods

- (void)actionSheet:(UIActionSheet *)actionSheet
clickedButtonAtIndex:(NSInteger)buttonIndex
{
   // Do nothing if the user taps outside the action
   // sheet (thus closing the popover containing the
   // action sheet).
   if (buttonIndex < 0) {
      return;
   }
   
   NSMutableArray *names = [[NSMutableArray alloc] init];
   
   if ([actionSheet tag] == 0) {
      [names addObject:@"confirmDeletePhotoAlbum"];
      
   } else {
      BOOL hasCamera = [UIImagePickerController
                        isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
      if (hasCamera) [names addObject:@"presentCamera"];
      [names addObject:@"presentPhotoLibrary"];
   }
   
   SEL selector = NSSelectorFromString([names objectAtIndex:buttonIndex]);
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
   [self performSelector:selector];
#pragma clang diagnostic pop
}

#pragma mark - Image picker helper methods

- (void)presentCamera
{
   // Display the camera.
   UIImagePickerController *imagePicker = [self imagePickerController];
   [imagePicker setSourceType:UIImagePickerControllerSourceTypeCamera];
   [self presentViewController:imagePicker animated:YES completion:nil];
}

- (void)presentPhotoLibrary
{
   // Display assets from the photo library only.
   UIImagePickerController *imagePicker = [self imagePickerController];
   [imagePicker setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
   
   UIPopoverController *newPopoverController =
   [[UIPopoverController alloc] initWithContentViewController:imagePicker];
   [newPopoverController presentPopoverFromBarButtonItem:[self addButton]
                                permittedArrowDirections:UIPopoverArrowDirectionAny
                                                animated:YES];
   [self setImagePickerPopoverController:newPopoverController];
}

- (void)presentPhotoPickerMenu
{
   UIActionSheet *actionSheet = [[UIActionSheet alloc] init];
   [actionSheet setDelegate:self];
   BOOL hasCamera = [UIImagePickerController
                     isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
   if (hasCamera) {
      [actionSheet addButtonWithTitle:@"Take Photo"];
   }
   [actionSheet addButtonWithTitle:@"Choose from Library"];
   [actionSheet setTag:1];
   [actionSheet showFromBarButtonItem:[self addButton] animated:YES];
}

#pragma mark - UIImagePickerControllerDelegate methods

- (void)imagePickerController:(UIImagePickerController *)picker
didFinishPickingMediaWithInfo:(NSDictionary *)info
{
   // If the popover controller is available,
   // assume the photo is selected from the library
   // and not from the camera.
   BOOL takenWithCamera = ([self imagePickerPopoverController] == nil);
   
   if (takenWithCamera) {
      [self dismissViewControllerAnimated:YES completion:nil];
   } else {
      [[self imagePickerPopoverController] dismissPopoverAnimated:YES];
      [self setImagePickerPopoverController:nil];
   }
   
   // Retrieve and display the image.
   UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];

   PhotoAlbum *album = [self photoAlbum];
   NSManagedObjectContext *context = [album managedObjectContext];
   Photo *newPhoto =
   [NSEntityDescription insertNewObjectForEntityForName:@"Photo"
                                 inManagedObjectContext:context];
   [newPhoto setDateAdded:[NSDate date]];
   [newPhoto saveImage:image];
   [newPhoto setPhotoAlbum:[self photoAlbum]];
   
   [self saveChanges];
}

#pragma mark - NSFetchedResultsController and NSFetchedResultsControllerDelegate

- (NSFetchedResultsController *)fetchedResultsController
{
   if (_fetchedResultsController) {
      return _fetchedResultsController;
   }
   
   PhotoAlbum *album = [self photoAlbum];
   NSManagedObjectContext *context = [album managedObjectContext];
   if (!context) {
      return nil;
   }
   
   NSString *cacheName = [NSString stringWithFormat:@"%@-%@",
                          [self.photoAlbum name], [self.photoAlbum dateAdded]];
   NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
   NSEntityDescription *entityDescription =
   [NSEntityDescription entityForName:@"Photo"
               inManagedObjectContext:context];
   [fetchRequest setEntity:entityDescription];
   
   NSSortDescriptor *sortDescriptor =
   [NSSortDescriptor sortDescriptorWithKey:@"dateAdded" ascending:YES];
   [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];

   NSPredicate *predicate = nil;
   predicate = [NSPredicate predicateWithFormat:@"photoAlbum = %@", [self photoAlbum]];
   [fetchRequest setPredicate:predicate];
   
   NSFetchedResultsController *newFetchedResultsController =
   [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                       managedObjectContext:context
                                         sectionNameKeyPath:nil
                                                  cacheName:cacheName];
   [newFetchedResultsController setDelegate:self];
   [self setFetchedResultsController:newFetchedResultsController];
   
   NSError *error = nil;
   if (![[self fetchedResultsController] performFetch:&error])
   {
      // Replace this implementation with code to handle the
      // error appropriately.
      
      NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
      abort();
   }
   
   return _fetchedResultsController;
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
   [[self collectionView] reloadData];
}

#pragma mark - UICollectionViewDataSource and UICollectionViewDelegate

- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section
{
   NSFetchedResultsController *frc = [self fetchedResultsController];
   NSInteger count = [[[frc sections] objectAtIndex:section] numberOfObjects];
   return count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
   ThumbnailCell *cell =
   [collectionView dequeueReusableCellWithReuseIdentifier:@"ThumbnailCell"
                                             forIndexPath:indexPath];

   NSFetchedResultsController *frc = [self fetchedResultsController];
   Photo *photo = [frc objectAtIndexPath:indexPath];
   [[cell imageView] setImage:[photo smallImage]];
   
   return cell;
}

- (void)collectionView:(UICollectionView *)collectionView
didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [self setSelectedPhotoIndex:[indexPath item]];
    
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    CGRect cellFrame = [cell frame];
    cellFrame = [[self view] convertRect:cellFrame fromView:collectionView];
    [self setSelectedPhotoFrame:cellFrame];
    
    UIApplication *app = [UIApplication sharedApplication];
    [app sendAction:@selector(pushPhotoBrowser:) to:nil from:self forEvent:nil];
}

- (UIImage *)selectedPhotoImage
{
    NSInteger index = [self selectedPhotoIndex];
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:index inSection:0];
    NSFetchedResultsController *frc = [self fetchedResultsController];
    Photo *photo = [frc objectAtIndexPath:indexPath];
    return [photo largeImage];
}

#pragma mark - Public Methods

- (NSArray *)photos
{
    NSArray *photos = [[self fetchedResultsController] fetchedObjects];
    return photos;
}

@end
