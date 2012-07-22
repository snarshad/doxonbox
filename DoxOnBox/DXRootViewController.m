//
//  DXRootViewController.m
//  DoxOnBox
//
//  Created by Arshad Tayyeb on 7/21/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "DXRootViewController.h"

#import "DXModelController.h"

#import "DXDataViewController.h"

#import "BoxLoginViewController.h"
#import "BoxFile.h"
#import "DXBoxBrowserTableViewController.h"
#import "BoxAPIKey.h"
#import "BoxUser.h"


@interface DXRootViewController ()
@property (readonly, strong, nonatomic) DXModelController *modelController;
@end

@implementation DXRootViewController
{
    UIPopoverController *popoverController;
}

@synthesize pageViewController = _pageViewController;
@synthesize modelController = _modelController;
@synthesize boxLoginController;



- (void)setupLoginController
{
    self.boxLoginController = [BoxLoginViewController loginViewControllerWithNavBar:NO];
    self.boxLoginController.boxLoginDelegate = self;
}

- (void)setupPageViewController
{
    self.pageViewController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStylePageCurl navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
    self.pageViewController.delegate = self;
    
    DXDataViewController *startingViewController = [self.modelController viewControllerAtIndex:0 storyboard:self.storyboard];
    NSArray *viewControllers = [NSArray arrayWithObject:startingViewController];
    [self.pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:NULL];
    
    self.pageViewController.dataSource = self.modelController;
    
    // Set the page view controller's bounds using an inset rect so that self's view is visible around the edges of the pages.
    CGRect pageViewRect = self.view.bounds;
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        pageViewRect = CGRectInset(pageViewRect, 40.0, 40.0);
    }
    self.pageViewController.view.frame = pageViewRect;    
}


- (void)openPagesView
{    
    [self.pageViewController didMoveToParentViewController:self];
    // Add the page view controller's gesture recognizers to the book view controller's view so that the gestures are started more easily.
    [self addChildViewController:self.pageViewController];
    [self.view addSubview:self.pageViewController.view];
    
    self.view.gestureRecognizers = self.pageViewController.gestureRecognizers;
}

- (void)openLoginView
{
    if (![BoxLoginViewController userSignedIn])
    {
        [self.view addSubview:self.boxLoginController.view];
        [self addChildViewController:self.boxLoginController];
    }
    else
    {
        [self addChildViewController:self.pageViewController];
        [self.view addSubview:self.pageViewController.view];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    // Configure the page view controller and add it as a child view controller.
    [self setupPageViewController];
    [self setupLoginController];
    
    self.navigationItem.title = @"DoxOnBox";

//    UIBarButtonItem* boxItem = [[UIBarButtonItem alloc] initWithTitle:@"Box" style:UIBarButtonItemStyleBordered target:self action:@selector(showBoxFiles)] ;
//    self.navigationItem.leftBarButtonItem = boxItem;

//    UIBarButtonItem* geoItem = [[UIBarButtonItem alloc] initWithTitle:@"Geo" style:UIBarButtonItemStyleBordered target:self action:@selector(showGeo)] ;
//    self.navigationItem.rightBarButtonItem = geoItem;
    

    [self openLoginView];
//    [self openPagesView];
    
    
}

- (void)showBoxFiles
{
    [self performSegueWithIdentifier:@"BoxPopoverSegue" sender:self.navigationItem.rightBarButtonItem];
}

- (void)showGeo
{
    
}


- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

- (DXModelController *)modelController
{
     // Return the model controller object, creating it if necessary.
     // In more complex implementations, the model controller may be passed to the view controller.
    if (!_modelController) {
        _modelController = [[DXModelController alloc] init];
    }
    return _modelController;
}

#pragma mark - UIPageViewController delegate methods

/*
- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed
{
    
}
 */

- (UIPageViewControllerSpineLocation)pageViewController:(UIPageViewController *)pageViewController spineLocationForInterfaceOrientation:(UIInterfaceOrientation)orientation
{
    if (UIInterfaceOrientationIsPortrait(orientation) || ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)) {
        // In portrait orientation or on iPhone: Set the spine position to "min" and the page view controller's view controllers array to contain just one view controller. Setting the spine position to 'UIPageViewControllerSpineLocationMid' in landscape orientation sets the doubleSided property to YES, so set it to NO here.
        
        UIViewController *currentViewController = [self.pageViewController.viewControllers objectAtIndex:0];
        NSArray *viewControllers = [NSArray arrayWithObject:currentViewController];
        [self.pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:NULL];
        
        self.pageViewController.doubleSided = NO;
        return UIPageViewControllerSpineLocationMin;
    }

    // In landscape orientation: Set set the spine location to "mid" and the page view controller's view controllers array to contain two view controllers. If the current page is even, set it to contain the current and next view controllers; if it is odd, set the array to contain the previous and current view controllers.
    DXDataViewController *currentViewController = [self.pageViewController.viewControllers objectAtIndex:0];
    NSArray *viewControllers = nil;

    NSUInteger indexOfCurrentViewController = [self.modelController indexOfViewController:currentViewController];
    if (indexOfCurrentViewController == 0 || indexOfCurrentViewController % 2 == 0) {
        UIViewController *nextViewController = [self.modelController pageViewController:self.pageViewController viewControllerAfterViewController:currentViewController];
        viewControllers = [NSArray arrayWithObjects:currentViewController, nextViewController, nil];
    } else {
        UIViewController *previousViewController = [self.modelController pageViewController:self.pageViewController viewControllerBeforeViewController:currentViewController];
        viewControllers = [NSArray arrayWithObjects:previousViewController, currentViewController, nil];
    }
    [self.pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:NULL];


    return UIPageViewControllerSpineLocationMid;
}

#pragma mark -
- (void)boxLoginViewController:(BoxLoginViewController*)boxLoginViewController didFinishWithResult:(LoginResult)result
{
    //this method will be responsible for removing the view controller from the screen
    
//    [boxLoginViewController removeFromParentViewController];
    
    [UIView transitionFromView:self.boxLoginController.view toView:self.pageViewController.view duration:.5 options:UIViewAnimationOptionCurveEaseIn|UIViewAnimationOptionCurveEaseOut completion:^(BOOL finished) {
        [boxLoginController removeFromParentViewController];
//        [boxLoginViewController.view removeFromSuperview];
        [self addChildViewController:self.pageViewController];
        [self.view addSubview:self.pageViewController.view];
    }];
}

#pragma mark DXBoxBrowserTableViewControllerDelegate
- (void)fileSelected:(BoxFile *)boxFile
{
    NSLog(@"File Selected");
    [popoverController dismissPopoverAnimated:YES];
    
//    NSString *urlString = [NSString stringWithFormat:@"https://api.box.com/2.0/files/%@/data", [boxFile objectId]];

    NSString *urlString = [NSString stringWithFormat:@"https://www.box.net/api/1.0/download/%@/%@", [BoxUser savedUser].authToken, [boxFile objectId]];
    
//    NSDictionary *headers = [NSDictionary dictionaryWithObjectsAndKeys:
//                             [NSString stringWithFormat:@"BoxAuth api_key=%@&auth_token=%@", BOX_API_KEY, [BoxUser savedUser].authToken], @"Authorization: BoxAuth api_key",
//                             nil];
    
    self.modelController.delegate = self;
    [self.modelController loadPageWithURLString:urlString headers:nil];
    
}
#pragma mark DXModelDelegate
- (void)pageContentLoaded:(DXPageContent *)pageContent atIndex:(NSInteger)index
{
    NSLog(@"Going to flip");
    NSArray *newViewControllers = [NSArray arrayWithObject:[self.modelController viewControllerAtIndex:index storyboard:self.storyboard]];
    [self.pageViewController setViewControllers:newViewControllers direction:UIPageViewControllerNavigationDirectionReverse animated:YES completion:^(BOOL finished) {
        NSLog(@"Done flipping");
    }];
}


#pragma mark -

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"BoxPopoverSegue"])
    {
        popoverController =  [(UIStoryboardPopoverSegue *)segue popoverController];
        
        // Get reference to the destination view controller
        DXBoxBrowserTableViewController *vc = (DXBoxBrowserTableViewController *)[[segue destinationViewController] visibleViewController];
        
        // Pass any objects to the view controller here, like...
        [vc setBoxDelegate:self];        
    }    
}



@end
