
//
// Copyright 2011 Box, Inc.
//
//   Licensed under the Apache License, Version 2.0 (the "License");
//   you may not use this file except in compliance with the License.
//   You may obtain a copy of the License at
//
//       http://www.apache.org/licenses/LICENSE-2.0
//
//   Unless required by applicable law or agreed to in writing, software
//   distributed under the License is distributed on an "AS IS" BASIS,
//   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//   See the License for the specific language governing permissions and
//   limitations under the License.
//

#import <UIKit/UIKit.h>
#import "BoxFolder.h"


@interface BoxBrowserTableViewController : UITableViewController

@property (nonatomic, readonly, retain) NSString * folderID;
@property (nonatomic, readonly, retain) BoxFolder * rootFolder; //Refers to the folder that is being presented by the view.

- (id)initWithFolderID:(NSString*)folderID; //The folderID must be set. Use @"0" for the root folder.
- (void)refreshTableViewSource; //This method refetches the BoxFolder item from the server and refreshes the UITableView.

@end

/* Usage

 The SDK provides a BoxBrowserTableViewController for browsing files and folders. It is recommended that you subclass this class to override the functionality you desire. To initialize the object, use the following code:
 
 BoxBrowserTableViewController * browserTableViewController = [[BoxBrowserTableViewController alloc] initWithFolderID:@"0"];
 
 Here, @”0” is used to designate the root folder. Then, the browserTableViewController must be used inside of a UINavigationViewController. To subclass BoxBrowserTableViewController, we recommend that you at least override the following methods:
 
 - (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
     UITableViewCell * cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
     cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
     return cell;
 }
 - (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
     // Insert code here for the action that should be performed when the accessory button is pressed.
 }
 
 The first method adds a disclosure button to the cells to register an action (because selecting a folder will open the folder). The second method handles the action that should be performed when the disclosure button is pressed. By default, - (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath is reserved for selecting folders to open them (on files, it does nothing), but feel free to override this function if you desire different functionality. The sample app has several examples of how this class can be subclassed (see most of the actions).
 
*/

