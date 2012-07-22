//
//  DXWebSearchTableViewController.m
//  DoxOnBox
//
//  Created by Arshad Tayyeb on 7/21/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//
#define LOG_API NSLog(@"%@", NSStringFromSelector(_cmd))

#import "DXWebSearchTableViewController.h"

@interface DXWebSearchTableViewController ()

@end

@implementation DXWebSearchTableViewController
{
    NSMutableArray	*filteredListContent;	// The content filtered as a result of a search.
    BOOL _isSearching;
    BOOL _isLoading;
    NSString *lastSearchedText;
}
@synthesize searchTableDelegate;
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

    filteredListContent = [[NSMutableArray alloc] initWithCapacity:10];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

#pragma mark - Table view delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    LOG_API;
    NSLog(@"%d", filteredListContent.count);
    return filteredListContent.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    LOG_API;
    static NSString *CellIdentifier = @"xwebSearchCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"xwebSearchCell"];
    }

    cell.textLabel.text = [[filteredListContent objectAtIndex:indexPath.row] valueForKey:@"title"];
    cell.detailTextLabel.text = @"Wikipedia";
    
    NSLog(@"New Cell at %d: %@ : %@", indexPath.row, cell.textLabel.text, cell.detailTextLabel.text);
    
        
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    LOG_API;
    
    if (_isLoading)
        return;
    
    _isLoading = YES;

    
    NSString *pageid = [[filteredListContent objectAtIndex:indexPath.row] valueForKey:@"pageid"];
//    NSString *title = [[filteredListContent objectAtIndex:indexPath.row] valueForKey:@"title"];
    
    
    
    NSString *pageContentURL = [NSString stringWithFormat:@"http://en.wikipedia.org/w/api.php?action=query&prop=revisions&pageids=%@&rvprop=content&rvparse&format=json", pageid];

    dispatch_async(dispatch_get_main_queue(), ^{
        [searchTableDelegate loadingContent:pageContentURL];
    });

    dispatch_queue_t taskQ = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(taskQ, ^{
        NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:
                                                      pageContentURL
                                                      ]];

        NSDictionary *results = nil;
        NSError *parseError = nil;
        id jsonObject = data ? [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&parseError] : nil;
        if (!jsonObject || parseError)
        {
            NSLog(@"Error getting json from %@: %@", data, parseError);
        } else {
            results = [jsonObject valueForKeyPath:@"query.pages"];
            NSString *contentString = [[[[[results allValues] lastObject] valueForKey:@"revisions"] lastObject] valueForKey:@"*"];
//            NSLog(@"Page content: %@", [[[[[results allValues] lastObject] valueForKey:@"revisions"] lastObject] valueForKey:@"*"]);
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [searchTableDelegate didLoadContent:contentString];
            });
        }
        _isLoading = NO;
    });
}


#pragma mark UISearchBarDelegate
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    LOG_API;
    NSLog(@"Search text: %@", searchText);
    if (searchText.length < 2)
        return;
    
    if (_isSearching)
    {
        NSLog(@"Searching, so ignoring text: %@", searchText);
        return;
    }

    NSLog(@"Searching for: %@", searchText);
    
    _isSearching = YES;
    lastSearchedText = searchText;    

    dispatch_queue_t taskQ = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(taskQ, ^{
        NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:
                                                      [NSString stringWithFormat:@"http://en.wikipedia.org/w/api.php?action=query&format=json&titles=%@", [searchText stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]
                                                      ]];
        NSDictionary *results = nil;
        NSError *parseError = nil;
        id jsonObject = data ? [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&parseError] : nil;
        if (!jsonObject || parseError)
        {
            NSLog(@"Error getting json from %@: %@", data, parseError);
        } else {
            results = [jsonObject valueForKeyPath:@"query.pages"];
            NSLog(@"Page info: %@", [results allValues]);
        }
        
        _isSearching = NO;
		dispatch_async(dispatch_get_main_queue(), ^{
            [filteredListContent removeAllObjects];
            [filteredListContent addObjectsFromArray:[results allValues]];
            if (![searchBar.text isEqualToString:lastSearchedText])
            {
                NSLog(@"Triggering search again for %@", searchBar.text);
                [self searchBar:searchBar textDidChange:searchBar.text];
            } else {
                NSLog(@"NOT triggering search again %@ =  %@", lastSearchedText, searchBar.text);
            }
            
            NSLog(@"tv: %@", self.tableView);
            [self.tableView reloadData];
        });
    });



}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    LOG_API;

    self.searchDisplayController.searchResultsTableView.hidden = NO;
    self.searchDisplayController.active = YES;
    
}

- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar {  
    LOG_API;
    return YES;
}

- (void)searchBarCancelButtonClicked:(UISearchBar *) searchBar
{
    LOG_API;
    
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
    
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [self.searchDisplayController.searchBar resignFirstResponder];
    
    self.searchDisplayController.searchResultsTableView.hidden = YES;
    self.searchDisplayController.active = NO;
}

- (void)searchDisplayController:(UISearchDisplayController *)controller didLoadSearchResultsTableView:(UITableView *)tableView
{
    NSLog(@"didLoadSearchResultsTableView");
    if (!self.searchDisplayController.searchBar.isFirstResponder)
    {
    }
}

- (void)searchDisplayController:(UISearchDisplayController *)controller willUnloadSearchResultsTableView:(UITableView *)tableView
{
    NSLog(@"willUnloadSearchResultsTableView");
}


-  (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{    
    LOG_API;
    NSLog(@"Should for string: %@", searchString);

    return YES;
    if (![lastSearchedText isEqualToString:searchString])
    {
        [self searchBar:controller.searchBar textDidChange:searchString];
    }
    
    self.searchDisplayController.searchResultsTableView.hidden = !self.searchDisplayController.searchBar.isFirstResponder;
    if (!self.searchDisplayController.searchBar.isFirstResponder)
    {
        NSLog(@"NO");
        return NO;
    }
    
    return YES;
}


- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption
{
    LOG_API;
    if (!self.searchDisplayController.searchBar.isFirstResponder)
    {
        return NO;
    }
    
    return YES;
}


- (void)searchDisplayControllerWillEndSearch:(UISearchDisplayController *)controller
{
}


@end
