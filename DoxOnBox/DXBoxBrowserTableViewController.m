//
//  DXBoxBrowserTableViewController.m
//  DoxOnBox
//
//  Created by Arshad Tayyeb on 7/21/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "DXBoxBrowserTableViewController.h"
#import "BoxFile.h"

@interface DXBoxBrowserTableViewController ()

@end

@implementation DXBoxBrowserTableViewController
@synthesize boxDelegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)init
{
    self = [super initWithFolderID:@"0"];
    return self;
}

- (void)viewDidLoad
{    
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell * cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
    return cell;
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    // Insert code here for the action that should be performed when the accessory button is pressed.
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    BoxObject* boxObject = (BoxObject*)[self.rootFolder.objectsInFolder objectAtIndex:indexPath.row];
    if ([boxObject isKindOfClass:[BoxFolder class]])
    {
        BoxObject * boxObject = ((BoxObject*)[self.rootFolder.objectsInFolder objectAtIndex:indexPath.row]);
        if ([boxObject isKindOfClass:[BoxFolder class]]) {
            DXBoxBrowserTableViewController * browserTableViewController = [[[self class] alloc] initWithFolderID:boxObject.objectId]; //Using [self class] ensures that if this class is subclassed, it pushes the correct kind of BoxBrowserTableViewController
            if (self.navigationController == nil) {
                NSLog(@"Error: BoxBrowserTableViewController should be in a UINavigationViewController to work properly.");
            }
            browserTableViewController.boxDelegate = self.boxDelegate;
            [self.navigationController pushViewController:browserTableViewController animated:YES];
        }    } 

    if ([boxObject isKindOfClass:[BoxFile class]])
    {
        BoxFile *bFile = (BoxFile *)boxObject;
        BoxFileModelFileType type = [bFile getFileType];
        if (type == BoxFileModelGeneralFileType) {
            NSLog(@"General");
            
            if ([boxDelegate respondsToSelector:@selector(fileSelected:)])
            {
                [boxDelegate fileSelected:bFile];
            }
//            [self dismissPopoverAnimated:YES];
            
        } else if (type == BoxFileModelWebdocFileType) {
            NSLog(@"Webdoc");
            if ([boxDelegate respondsToSelector:@selector(fileSelected:)])
            {
                [boxDelegate fileSelected:bFile];
            }
            //            [self dismissPopoverAnimated:YES];
        }
    }

}
@end
