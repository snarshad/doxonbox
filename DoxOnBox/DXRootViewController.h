//
//  DXRootViewController.h
//  DoxOnBox
//
//  Created by Arshad Tayyeb on 7/21/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BoxLoginViewController.h"
#import "DXBoxBrowserTableViewController.h"
#import "DXModelController.h"

@class BoxLoginNavigationController, BoxBrowserTableViewController;

@interface DXRootViewController : UIViewController <UIPageViewControllerDelegate, BoxLoginViewControllerDelegate, DXBoxBrowserTableViewControllerDelegate, DXModelDelegate>

@property (strong, nonatomic) UIPageViewController *pageViewController;
@property (strong, nonatomic) BoxLoginViewController *boxLoginController;

@end
