//
//  DXDataViewController.h
//  DoxOnBox
//
//  Created by Arshad Tayyeb on 7/21/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BLColorizedTextView.h"

@interface DXDataViewController : UIViewController

@property (strong, nonatomic) IBOutlet UILabel *dataLabel;
@property (strong, nonatomic) IBOutlet BLColorizedTextView *textView;
@property (strong, nonatomic) IBOutlet UIView *backgroundView;
@property (strong, nonatomic) id dataObject;

@end
