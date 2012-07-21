
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

#import "BoxBrowserTableViewController.h"
#import "BoxFolder.h"
#import "BoxFile.h"
#import "BoxNetworkOperationManager.h"


@interface BoxBrowserTableViewController () {
    BoxFolder *__rootFolder;
    NSString *__folderID;
}

@property (nonatomic, readwrite, retain) NSString * folderID; //overriding readonly properties from .h file
@property (nonatomic, readwrite, retain) BoxFolder * rootFolder;

@end

@implementation BoxBrowserTableViewController

@synthesize folderID = __folderID, rootFolder = __rootFolder;

#pragma mark - View Life Cycle

- (id)initWithFolderID:(NSString*)folderID {
    self = [super init];
    if (self) {
        self.folderID = folderID;
    }
    return self;
}

- (id)init {
    return [self initWithFolderID:@"0"]; //Default value
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Loading...";
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self refreshTableViewSource];
}

- (void)dealloc {
    [__rootFolder release];
    __rootFolder = nil;
    [__folderID release];
    __folderID = nil;
    
    [super dealloc];
}

#pragma mark - Table view data source

- (void)refreshTableViewSource {
    BoxGetFolderCompletionHandler block = ^(BoxFolder* folder, BoxFolderDownloadResponseType response) {
        if (response == boxFolderDownloadResponseTypeFolderSuccessfullyRetrieved) {
            if ([self.folderID isEqualToString:@"0"]) {
                self.title = @"Root Folder";
            } else {
                self.title = folder.objectName;
            }
            self.rootFolder = folder;
            [self.tableView reloadData];
        } else {
            self.title = @"Error";
            UIAlertView * alert = [[[UIAlertView alloc] initWithTitle:@"Error" message:[BoxNetworkOperationManager humanReadableErrorFromResponse:(BoxOperationResponse)response] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] autorelease];
            [alert show];
        }
    };
    if (self.folderID == nil) {
        NSLog(@"Error: FolderID must be set in BoxBrowserTableViewController");
    }
    [[BoxNetworkOperationManager sharedBoxOperationManager] getBoxFolderForID:self.folderID onCompletion:block];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.rootFolder.objectsInFolder count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"Cell"] autorelease];
    }
    BoxObject* boxObject = (BoxObject*)[self.rootFolder.objectsInFolder objectAtIndex:indexPath.row];
    
    cell.textLabel.text = boxObject.objectName;
    cell.detailTextLabel.text = boxObject.objectDescription;
    
    if ([boxObject isKindOfClass:[BoxFolder class]]) {
        BoxFolder * folder = (BoxFolder*)boxObject;
        if(folder.isCollaborated) {
            cell.imageView.image = [UIImage imageNamed:@"BoxCollabFolder"];
        } else {
            cell.imageView.image = [UIImage imageNamed:@"BoxFolderIcon"];
        }
        if ([folder.fileCount intValue] == 1) {
            cell.detailTextLabel.text = [NSString stringWithFormat:@"1 file. %@", folder.objectDescription];
        } else {
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ files. %@", folder.fileCount, folder.objectDescription];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleBlue;
    } else {
        cell.imageView.image = [UIImage imageNamed:@"BoxDocumentIcon"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    BoxObject * boxObject = ((BoxObject*)[self.rootFolder.objectsInFolder objectAtIndex:indexPath.row]);
    if ([boxObject isKindOfClass:[BoxFolder class]]) {
        BoxBrowserTableViewController * browserTableViewController = [[[[self class] alloc] initWithFolderID:boxObject.objectId] autorelease]; //Using [self class] ensures that if this class is subclassed, it pushes the correct kind of BoxBrowserTableViewController
        if (self.navigationController == nil) {
            NSLog(@"Error: BoxBrowserTableViewController should be in a UINavigationViewController to work properly.");
        }
        [self.navigationController pushViewController:browserTableViewController animated:YES];
    }
}


@end
