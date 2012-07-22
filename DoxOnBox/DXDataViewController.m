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
@synthesize lexicalTextView;

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
    
    self.lexicalTextView = [[DXColorizedAttributedTextView alloc] initWithFrame:self.textView.frame];
    self.lexicalTextView.autoresizingMask = self.textView.autoresizingMask;
    [self.textView.superview addSubview:self.lexicalTextView];
    [self switchLexical];
}

- (void)switchLexical
{
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DXUserDefaultsUseLexicalColoring"])
    {
        self.lexicalTextView.alpha = 1.0;
        self.textView.alpha = 0.0;
    } else {
        self.lexicalTextView.alpha = 0.0;
        self.textView.alpha = 1.0;
    }

//    self.lexicalTextView.alpha = .5;
//    self.textView.alpha = 1.0;

    
}

- (void)switchFont
{
    self.textView.font = [[NSUserDefaults standardUserDefaults] boolForKey:@"DXUserDefaultsUseDyslexicMode"] ? [UIFont fontWithName:@"OpenDyslexic-Regular" size:[[NSUserDefaults standardUserDefaults] floatForKey:@"DXUserDefaultsFontSize"] - 2.0f] : [UIFont fontWithName:@"TimesNewRomanPSMT" size:[[NSUserDefaults standardUserDefaults] floatForKey:@"DXUserDefaultsFontSize"]];
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
//    NSMutableArray *colors = [[NSMutableArray alloc] initWithCapacity:4];
//    [colors addObject:[UIColor colorWithRed:1.0f green:0.0f blue:0.0f alpha:1.0f]];
//    [colors addObject:[UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:1.0f]];
//    [colors addObject:[UIColor colorWithRed:0.0f green:0.0f blue:1.0f alpha:1.0f]];
//    [colors addObject:[UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:1.0f]];
//    self.textView.colors = colors;
//    self.textView.lineBreakMode = UILineBreakModeWordWrap;
//    
//    self.textView.backgroundColor = [UIColor clearColor];

    self.dataLabel.text = [self.dataObject pageTitle];

    //set up lexical display view
        NSMutableAttributedString *str = [NSAttributedString lexicallyHighlightedStringForString:[self.dataObject pageText]];
        UIFont *font = [[NSUserDefaults standardUserDefaults] boolForKey:@"DXUserDefaultsUseDyslexicMode"] ? [UIFont fontWithName:@"OpenDyslexic-Regular" size:[[NSUserDefaults standardUserDefaults] floatForKey:@"DXUserDefaultsFontSize"] - 2.0f] : [UIFont fontWithName:@"TimesNewRomanPSMT" size:[[NSUserDefaults standardUserDefaults] floatForKey:@"DXUserDefaultsFontSize"]];
        CTFontRef ctfont = CTFontCreateWithName((__bridge CFStringRef)font.fontName, font.pointSize, NULL);
        [str addAttribute:(NSString *)kCTFontAttributeName value:(__bridge UIFont *)ctfont range:NSMakeRange(0, str.length)];
        self.lexicalTextView.attributedText = str;        

    //set up beeline display view
    self.textView.text = [self.dataObject pageText];

    [self switchFont];
    
    //choose which view to show
    [self switchLexical];
    [super viewWillAppear:animated];

    
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
