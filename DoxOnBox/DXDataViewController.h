//
//  DXDataViewController.h
//  DoxOnBox
//
//  Created by Arshad Tayyeb on 7/21/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BLColorizedTextView.h"
#import "DXColorizedAttributedTextView.h"

extern const float PAGINATION_FONT_SIZE;
//#define READER_FONT [UIFont fontWithName:@"OpenDyslexic-Regular" size:16.0f]
#define READER_FONT [UIFont systemFontOfSize:18.0f]

@interface DXDataViewController : UIViewController

@property (strong, nonatomic) IBOutlet UILabel *dataLabel;
@property (strong, nonatomic) IBOutlet BLColorizedTextView *textView;
@property (strong, nonatomic) DXColorizedAttributedTextView *lexicalTextView;
@property (strong, nonatomic) IBOutlet UIView *backgroundView;
@property (strong, nonatomic) id dataObject;
- (void)switchFont;
- (void)switchLexical;

@end
