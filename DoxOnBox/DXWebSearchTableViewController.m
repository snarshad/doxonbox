//
//  DXWebSearchTableViewController.m
//  DoxOnBox
//
//  Created by Arshad Tayyeb on 7/21/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//
#define LOG_API NSLog(@"%@", NSStringFromSelector(_cmd))

#import "DXWebSearchTableViewController.h"
#import "NSString+URLUtils.h"

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

    NSDictionary *item = [filteredListContent objectAtIndex:indexPath.row];
    
    if ([[item allKeys] containsObject:@"title"])
    {
        cell.textLabel.text = [item valueForKey:@"title"];
    } else if ([[item allKeys] containsObject:@"urlString"]) {
        cell.textLabel.text = [item valueForKey:@"urlString"];
    } else {
        cell.textLabel.text = [item description];
    }
    
    if ([[item allKeys] containsObject:@"pageid"])
    {
        cell.detailTextLabel.text = @"Wikipedia";
    } else {
        cell.detailTextLabel.text = @"URL";
    }
    
    NSLog(@"New Cell at %d: %@ : %@", indexPath.row, cell.textLabel.text, cell.detailTextLabel.text);
    
        
    return cell;
}

#pragma mark - Table view delegate


- (void)loadWikipediaInfoFor:(NSDictionary *)item
{
    _isLoading = YES;

    NSString *pageid = [item valueForKey:@"pageid"];
    //    NSString *title = [item valueForKey:@"title"];
    
    
    
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
            NSLog(@"Page content: %@", [[[[[results allValues] lastObject] valueForKey:@"revisions"] lastObject] valueForKey:@"*"]);
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [searchTableDelegate didLoadContent:contentString];
            });
        }
        _isLoading = NO;
    });    
}

- (void)loadURLInfoFor:(NSDictionary *)item
{
    _isLoading = YES;
    
    NSString *urlString = [item valueForKey:@"urlString"];        
    [searchTableDelegate didSelectURL:urlString];

    _isLoading = NO;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    LOG_API;
    
    if (_isLoading)
        return;
    
    NSDictionary *item = [filteredListContent objectAtIndex:indexPath.row];
    
    if ([[item allKeys] containsObject:@"pageid"])
    {
        [self loadWikipediaInfoFor:item];
    } else if ([[item allKeys] containsObject:@"urlString"]) {
        [self loadURLInfoFor:item];
    }
    
}


- (void)showURLCell:(NSString *)urlString
{
    [filteredListContent removeAllObjects];
    
    NSDictionary *urlCellResult = 
    [NSDictionary dictionaryWithObjectsAndKeys:
     urlString, @"urlString",
     nil];
    
    [filteredListContent addObject:urlCellResult];
}

- (void)searchWikipedia:(NSString *)searchText
{
    _isSearching = YES;

    dispatch_queue_t taskQ = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(taskQ, ^{
        //This is a fine wikipedia search - EXCEPT it only returns one result
        NSString *wikisearchURL = [NSString stringWithFormat:@"http://en.wikipedia.org/w/api.php?action=query&format=json&titles=%@", [searchText stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        
        // This list=search API would be perfect, except it doesn't return pageids!!
        //        NSString *wikisearchURL = [NSString stringWithFormat:@"http://en.wikipedia.org/w/api.php?action=query&format=json&list=search&srsearch=%@",[searchText stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        
        NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:
                                                      wikisearchURL                  
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
            
            //If the text in the search bar changed while we were performing this search, trigger another search
            if (![self.searchDisplayController.searchBar.text isEqualToString:lastSearchedText])
            {
                NSLog(@"Triggering search again for %@", self.searchDisplayController.searchBar.text);
                [self searchBar:self.searchDisplayController.searchBar textDidChange:self.searchDisplayController.searchBar.text];
            } else {
                NSLog(@"NOT triggering search again %@ =  %@", lastSearchedText, self.searchDisplayController.searchBar.text);
            }
            
            NSLog(@"tv: %@", self.tableView);
            [self.searchDisplayController.searchResultsTableView reloadData];
        });
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
    
    lastSearchedText = searchText;    
    
    BOOL isURL = ([searchText componentsSeparatedByString:@"."].count > 1);
    
    if (isURL)
    {
        [self showURLCell:searchText];
    } else {
        [self searchWikipedia:searchText];
    }
    

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
    NSLog(@"x");
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [self.searchDisplayController.searchBar resignFirstResponder];

    
    if (filteredListContent.count == 1)
    {
        [self tableView:self.searchDisplayController.searchResultsTableView didSelectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    }
    
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
