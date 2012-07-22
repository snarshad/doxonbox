//
//  DXSettingsViewController.m
//  DoxOnBox
//
//  Created by Daniel DeCovnick on 7/21/12.
//  Copyright (c) 2012 Softyards Software. All rights reserved.
//

#import "DXSettingsViewController.h"
#import "BoxUser.h"

@interface DXSettingsViewController ()

@end

@implementation DXSettingsViewController
@synthesize fontSizePicker, popoverDelegate;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
     self.fontSizePicker = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    UISwitch *switchView = [[UISwitch alloc] initWithFrame:CGRectZero];
    switch (indexPath.row)
    {
        case 0:
            cell.accessoryView = switchView;
            [switchView setOn:[[NSUserDefaults standardUserDefaults] boolForKey:@"DXUserDefaultsUseDyslexicMode"]];
            cell.textLabel.text = @"Dyslexic Mode";
            [switchView addTarget:self action:@selector(toggleDyslexicMode:) forControlEvents:UIControlEventTouchUpInside];
            break;
        case 1:
            cell.accessoryView = switchView;
            [switchView setOn:[[NSUserDefaults standardUserDefaults] boolForKey:@"DXUserDefaultsUseLexicalColoring"]];
            cell.textLabel.text = @"Lexical Tagging";
            [switchView addTarget:self action:@selector(toggleLexicalMode:) forControlEvents:UIControlEventTouchUpInside];
            break;
        default:
            cell.textLabel.text = @"Log out";
            break;
    }
    
    return cell;
}
- (IBAction)toggleDyslexicMode:(id)sender
{
    [[NSUserDefaults standardUserDefaults] setBool:[sender state] forKey:@"DXUserDefaultUseDyslexicMode"];
}
- (IBAction)toggleLexicalMode:(id)sender
{
    [[NSUserDefaults standardUserDefaults] setBool:[sender state] forKey:@"DXUserDefaultsUseLexicalColoring"];
}
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return 10;
}
/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [popoverDelegate logOut:self];
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

@end
