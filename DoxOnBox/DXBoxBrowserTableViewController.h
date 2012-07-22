//
//  DXBoxBrowserTableViewController.h
//  DoxOnBox
//
//  Created by Arshad Tayyeb on 7/21/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "BoxBrowserTableViewController.h"
@class BoxFile;

@protocol DXBoxBrowserTableViewControllerDelegate <NSObject>
- (void)fileSelected:(BoxFile *)boxFile;
@end

@interface DXBoxBrowserTableViewController : BoxBrowserTableViewController

@property (weak) id<DXBoxBrowserTableViewControllerDelegate>boxDelegate;
@property (weak) UIPopoverController *popoverController;
@end
