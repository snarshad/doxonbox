//
//  DXDataViewController.m
//  DoxOnBox
//
//  Created by Arshad Tayyeb on 7/21/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "DXDataViewController.h"
#import "DXPageContent.h"

@interface DXDataViewController ()

@end

const float PAGINATION_FONT_SIZE = 16.0f;

@implementation DXDataViewController

@synthesize dataLabel = _dataLabel;
@synthesize dataObject = _dataObject;
@synthesize backgroundView;
@synthesize textView;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    NSMutableArray *colors = [[NSMutableArray alloc] initWithCapacity:4];
    [colors addObject:[UIColor colorWithRed:1.0f green:0.0f blue:0.0f alpha:1.0f]];
    [colors addObject:[UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:1.0f]];
    [colors addObject:[UIColor colorWithRed:0.0f green:0.0f blue:1.0f alpha:1.0f]];
    [colors addObject:[UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:1.0f]];
    self.textView.colors = colors;
    self.textView.lineBreakMode = UILineBreakModeWordWrap;
    
    self.backgroundView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background7.jpeg"]];
    
    self.textView.backgroundColor = [UIColor clearColor];
}

- (void)switchFont
{
    self.textView.font = [[NSUserDefaults standardUserDefaults] boolForKey:@"DXUserDefaultsUseDyslexicMode"] ? [UIFont fontWithName:@"OpenDyslexic-Regular" size:16.0f] : [UIFont systemFontOfSize:18.0f];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    self.dataLabel = nil;
    self.textView = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.dataLabel.text = [self.dataObject pageTitle];
    self.textView.text = [self.dataObject pageText];
    self.textView.font = [[NSUserDefaults standardUserDefaults] boolForKey:@"DXUserDefaultsUseDyslexicMode"] ? [UIFont fontWithName:@"OpenDyslexic-Regular" size:16.0f] : [UIFont systemFontOfSize:18.0f];

}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

@end
