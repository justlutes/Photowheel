//
//  MainViewController.m
//  PhotoWheel
//
//  Created by Kyle Lutes on 9/10/13.
//  Copyright (c) 2013 Kyle Lutes All rights reserved.
//

#import "MainViewController.h"
#import "AlbumsViewController.h"
#import "AppDelegate.h"
#import "PhotosViewController.h"
#import "PhotoBrowserViewController.h"

@interface MainViewController ()
//- (IBAction)dismissAbout:(UIStoryboardSegue *)segue;
@property (nonatomic, assign, readwrite) CGRect selectedPhotoFrame;
@property (nonatomic, strong, readwrite) UIImage *selectedPhotoImage;
- (IBAction)dismissAbout:(id)sender;
- (IBAction)pushPhotoBrowser:(id)sender;
@end

@implementation MainViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// The unwind action has been replaced with a standard action
// as a workaround for a particular unwind segue bug.
// - (IBAction)dismissAbout:(UIStoryboardSegue *)segue
- (IBAction)dismissAbout:(id)sender
{
   [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)pushPhotoBrowser:(id)sender
{
   [self performSegueWithIdentifier:@"PushPhotoBrowser" sender:sender];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
   id destinationVC = [segue destinationViewController];
   if ([destinationVC isKindOfClass:[AlbumsViewController class]]) {
      UIApplication *app = [UIApplication sharedApplication];
      AppDelegate *appDelegate = (AppDelegate *)[app delegate];

      NSManagedObjectContext *context;
      context = [appDelegate managedObjectContext];

      [destinationVC setManagedObjectContext:context];
       
   } else if ([[segue identifier] isEqualToString:@"PushPhotoBrowser"]) {
       [destinationVC setPhotos:[sender photos]];
       [destinationVC setStartAtIndex:[sender selectedPhotoIndex]];
       
       id sourceVC = [segue sourceViewController];
       CGRect frame = [sender selectedPhotoFrame];
       frame = [[self view] convertRect:frame fromView:[sender view]];
       [sourceVC setSelectedPhotoFrame:frame];
       [sourceVC setSelectedPhotoImage:[sender selectedPhotoImage]];
   }
}

@end
