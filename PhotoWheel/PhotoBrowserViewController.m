//
//  PhotoBrowserViewController.m
//  PhotoWheel
//
//  Created by Kyle Lutes on 10/10/13.
//  Copyright (c) 2013 Kyle Lutes All rights reserved.
//

#import "PhotoBrowserViewController.h"
#import "Photo.h"
#import "PhotoBrowserPhotoView.h"


@interface PhotoBrowserViewController ()
@property (nonatomic, assign) NSInteger currentIndex;
@property (nonatomic, strong) NSMutableArray *photoViewCache;
@property (nonatomic, assign, getter=isChromeHidden) BOOL chromeHidden;
@property (nonatomic, strong) NSTimer *chromeHideTimer;
@property (nonatomic, assign) CGFloat statusBarHeight;

@end

@implementation PhotoBrowserViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Make sure to set wantsFullScreenLayout or the photo
    // will not display behind the status bar.
    [self setWantsFullScreenLayout:YES];
    
    // Set the view's frame size. This ensures that the scroll view
    // autoresizes correctly and avoids surprises when retrieving
    // the scroll view's bounds later.
    CGRect frame = [[UIScreen mainScreen] bounds];
    [[self view] setFrame:frame];
    
    UIScrollView *scrollView = [self scrollView];
    // Set the initial size.
    [scrollView setFrame:[self frameForPagingScrollView]];
    [scrollView setDelegate:self];
    [scrollView setBackgroundColor:[UIColor blackColor]];
    [scrollView setTranslatesAutoresizingMaskIntoConstraints:YES];
    [scrollView setAutoresizingMask:UIViewAutoresizingFlexibleWidth |
     UIViewAutoresizingFlexibleHeight];
    [scrollView setAutoresizesSubviews:YES];
    [scrollView setPagingEnabled:YES];
    [scrollView setShowsVerticalScrollIndicator:NO];
    [scrollView setShowsHorizontalScrollIndicator:NO];
    
    [self initPhotoViewCache];
    
    // Must store the status bar size while it is still visible.
    UIApplication *app = [UIApplication sharedApplication];
    CGRect statusBarFrame = [app statusBarFrame];
    if (UIInterfaceOrientationIsLandscape([self interfaceOrientation])) {
        [self setStatusBarHeight:statusBarFrame.size.width];
    } else {
        [self setStatusBarHeight:statusBarFrame.size.height];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self setScrollViewContentSize];
    [self setCurrentIndex:[self startAtIndex]];
    [self scrollToIndex:[self startAtIndex]];
    [self setTitleWithCurrentIndex];
    [self startChromeDisplayTimer];

}

- (void)viewWillDisappear:(BOOL)animated                                
{
    [self cancelChromeDisplayTimer];
    [super viewWillDisappear:animated];
}

#pragma mark - Helpers

- (NSInteger)numberOfPhotos
{
    NSInteger numberOfPhotos = [[self photos] count];
    return numberOfPhotos;
}

- (UIImage*)imageAtIndex:(NSInteger)index
{
    Photo *photo = [[self photos] objectAtIndex:index];
    UIImage *image = [photo largeImage];
    return image;
}

#pragma mark - Helper methods

- (void)initPhotoViewCache
{
    // Set up the photo's view cache. We keep only three views in
    // memory. NSNull is used as a placeholder for the other
    // elements in the view cache array.
    
    NSInteger numberOfPhotos = [self numberOfPhotos];
    NSMutableArray *cache = nil;
    cache = [[NSMutableArray alloc] initWithCapacity:numberOfPhotos];
    for (int i=0; i < numberOfPhotos; i++) {
        [cache addObject:[NSNull null]];
    }
    [self setPhotoViewCache:cache];
}

- (void)setScrollViewContentSize
{
    NSInteger pageCount = [self numberOfPhotos];
    if (pageCount == 0) {
        pageCount = 1;
    }
    
    CGRect bounds = [[self scrollView] bounds];
    CGSize size = CGSizeMake(bounds.size.width * pageCount,
                             // Divide in half to prevent horizontal
                             // scrolling.
                             bounds.size.height / 2);
    [[self scrollView] setContentSize:size];
}

- (void)scrollToIndex:(NSInteger)index
{
    CGRect bounds = [[self scrollView] bounds];
    bounds.origin.x = bounds.size.width * index;
    bounds.origin.y = 0;
    [[self scrollView] scrollRectToVisible:bounds animated:NO];
}

- (void)setTitleWithCurrentIndex
{
    NSInteger index = [self currentIndex] + 1;
    if (index < 1) {
        // Prevents the title from showing 0 of n when the user
        // attempts to scroll the first page to the right.
        index = 1;
    }
    NSInteger count = [self numberOfPhotos];
    NSString *title = nil;
    title = [NSString stringWithFormat:@"%1$i of %2$i", index, count, nil];
    [self setTitle:title];
}

#pragma mark - Frame calculations
#define PADDING  20

- (CGRect)frameForPagingScrollView
{
    CGRect frame = [[UIScreen mainScreen] bounds];
    frame.origin.x -= PADDING;
    frame.size.width += (2 * PADDING);
    return frame;
}

- (CGRect)frameForPageAtIndex:(NSUInteger)index
{
    CGRect bounds = [[self scrollView] bounds];
    CGRect pageFrame = bounds;
    pageFrame.size.width -= (2 * PADDING);
    pageFrame.origin.x = (bounds.size.width * index) + PADDING;
    return pageFrame;
}

#pragma mark - Page management

- (void)loadPage:(NSInteger)index
{
    if (index < 0 || index >= [self numberOfPhotos]) {
        return;
    }
    
    id currentView = [[self photoViewCache] objectAtIndex:index];
    if ([currentView isKindOfClass:[PhotoBrowserPhotoView class]]==NO) {
        // Load the photo view.
        CGRect frame = [self frameForPageAtIndex:index];
        PhotoBrowserPhotoView *newView = [[PhotoBrowserPhotoView alloc]
                                          initWithFrame:frame];
        [newView setBackgroundColor:[UIColor clearColor]];
        [newView setImage:[self imageAtIndex:index]];
        [newView setPhotoBrowserViewController:self];
        [newView setIndex:index];
        
        [[self scrollView] addSubview:newView];
        [[self photoViewCache] replaceObjectAtIndex:index withObject:newView];
    } else {
        [currentView turnOffZoom];
    }}

- (void)unloadPage:(NSInteger)index
{
    if (index < 0 || index >= [self numberOfPhotos]) {
        return;
    }
    
    id currentView = [[self photoViewCache] objectAtIndex:index];
    if ([currentView isKindOfClass:[PhotoBrowserPhotoView class]]) {     
        [currentView removeFromSuperview];
        [[self photoViewCache] replaceObjectAtIndex:index withObject:[NSNull null]];
    }
}
- (void)setCurrentIndex:(NSInteger)newIndex
{
    _currentIndex = newIndex;
    
    [self loadPage:_currentIndex];
    [self loadPage:_currentIndex + 1];
    [self loadPage:_currentIndex - 1];
    [self unloadPage:_currentIndex + 2];
    [self unloadPage:_currentIndex - 2];
    
    [self setTitleWithCurrentIndex];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if ([scrollView isScrollEnabled]) {
        CGFloat pageWidth = scrollView.bounds.size.width;
        float fractionalPage = scrollView.contentOffset.x / pageWidth;
        NSInteger page = floor(fractionalPage);
        if (page != [self currentIndex]) {
            [self setCurrentIndex:page];
        }
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self hideChrome];
}

#pragma mark - Chrome helpers

- (void)toggleChromeDisplay
{
    [self toggleChrome:![self isChromeHidden]];
}

- (void)toggleChrome:(BOOL)hide
{
    [self setChromeHidden:hide];
    if (hide) {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.4];
    }
    
    CGFloat alpha = hide ? 0.0 : 1.0;
    
    UINavigationBar *navbar = [[self navigationController] navigationBar];
    [navbar setAlpha:alpha];
    
    [[UIApplication sharedApplication] setStatusBarHidden:hide];
    
    if (hide) {
        [UIView commitAnimations];
    }
    
    if ( ! [self isChromeHidden] ) {
        [self startChromeDisplayTimer];
    }
}

- (void)hideChrome
{
    NSTimer *timer = [self chromeHideTimer];
    if (timer && [timer isValid]) {
        [timer invalidate];
        [self setChromeHideTimer:nil];
    }
    [self toggleChrome:YES];
}

- (void)startChromeDisplayTimer
{
    [self cancelChromeDisplayTimer];
    NSTimer *timer = nil;
    timer = [NSTimer scheduledTimerWithTimeInterval:5.0
                                             target:self
                                           selector:@selector(hideChrome)
                                           userInfo:nil
                                            repeats:NO];
    [self setChromeHideTimer:timer];
}

- (void)cancelChromeDisplayTimer
{
    if ([self chromeHideTimer]) {
        [[self chromeHideTimer] invalidate];
        [self setChromeHideTimer:nil];
    }
}

#pragma mark - Gesture handlers

- (void)imageTapped:(UITapGestureRecognizer *)recognizer                
{
    [self toggleChromeDisplay];
}

@end
