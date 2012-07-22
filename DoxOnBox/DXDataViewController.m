//
//  DXDataViewController.m
//  DoxOnBox
//
//  Created by Arshad Tayyeb on 7/21/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "DXDataViewController.h"
#import "DXPageContent.h"
#import "DXColorizedAttributedTextView.h"
#import "NSAttributedString+DXLexicalAnalysis.h"
#import <CoreText/CoreText.h>

@interface DXDataViewController ()

@end

const float PAGINATION_FONT_SIZE = 16.0f;

@implementation DXDataViewController

@synthesize dataLabel = _dataLabel;
@synthesize dataObject = _dataObject;
@synthesize backgroundView;
@synthesize textView;
@synthesize lastTextView;

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
    NSMutableArray *colors = [[NSMutableArray alloc] initWithCapacity:4];
    [colors addObject:[UIColor colorWithRed:1.0f green:0.0f blue:0.0f alpha:1.0f]];
    [colors addObject:[UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:1.0f]];
    [colors addObject:[UIColor colorWithRed:0.0f green:0.0f blue:1.0f alpha:1.0f]];
    [colors addObject:[UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:1.0f]];
    self.textView.colors = colors;
    self.textView.lineBreakMode = UILineBreakModeWordWrap;
    
    self.textView.backgroundColor = [UIColor clearColor];

    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DXUserDefaultsUseLexicalColoring"])
    {
        self.lastTextView = self.textView;
        UIView *superview = [self.lastTextView superview];
        [self.lastTextView removeFromSuperview];
        self.textView = [[DXColorizedAttributedTextView alloc] initWithFrame:self.textView.frame];
        NSMutableAttributedString *str = [NSAttributedString lexicallyHighlightedStringForString:[self.dataObject pageText]];
        UIFont *font = [[NSUserDefaults standardUserDefaults] boolForKey:@"DXUserDefaultsUseDyslexicMode"] ? [UIFont fontWithName:@"OpenDyslexic-Regular" size:16.0f] : [UIFont systemFontOfSize:18.0f];
        CTFontRef ctfont = CTFontCreateWithName((__bridge CFStringRef)font.fontName, font.pointSize, NULL);
        [str addAttribute:(NSString *)kCTFontAttributeName value:(__bridge UIFont *)ctfont range:NSMakeRange(0, str.length)];
        ((DXColorizedAttributedTextView *)self.textView).attributedText = str;
        [superview addSubview:textView];
        
    }
    else
    {
        self.textView = self.lastTextView ? self.lastTextView : self.textView;
    }
    [self switchFont];
    [super viewWillAppear:animated];
    self.dataLabel.text = [self.dataObject pageTitle];
    self.textView.text = [self.dataObject pageText];

    
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
