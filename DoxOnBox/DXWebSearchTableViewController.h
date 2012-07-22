//
//  DXWebSearchTableViewController.h
//  DoxOnBox
//
//  Created by Arshad Tayyeb on 7/21/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol DXWebSearchTableViewControllerDelegate <NSObject>
- (void)didLoadContent:(NSString *)contentString;
@end

@interface DXWebSearchTableViewController : UITableViewController
@property (weak, readwrite) id <DXWebSearchTableViewControllerDelegate>searchTableDelegate;
@end
