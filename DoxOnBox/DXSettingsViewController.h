//
//  DXSettingsViewController.h
//  DoxOnBox
//
//  Created by Daniel DeCovnick on 7/21/12.
//  Copyright (c) 2012 Softyards Software. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DXSettingsViewController;
@protocol DXSettingsDelegate <NSObject>

- (void)logOut:(DXSettingsViewController *)sender;

@end

@interface DXSettingsViewController : UITableViewController <UIPickerViewDataSource, UIPickerViewDelegate>
@property (nonatomic, strong, readwrite) IBOutlet UIPickerView *fontSizePicker;
- (IBAction)toggleDyslexicMode:(id)sender;
- (IBAction)toggleLexicalMode:(id)sender;
@property (weak, readwrite) id popoverDelegate;

@end
