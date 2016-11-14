//
//  AboutViewController.m
//  PhotoWheel
//
//  Created by Kyle Lutes on 9/15/13.
//  Copyright (c) 2013 Kyle Lutes All rights reserved.
//


#import "AboutViewController.h"

@interface AboutViewController ()

@end

@implementation AboutViewController
@synthesize versionLabel;

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
	
    NSString *path = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"];
    versionLabel.text = path;

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
