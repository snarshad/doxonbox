//
//  DXModelController.m
//  DoxOnBox
//
//  Created by Arshad Tayyeb on 7/21/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "DXModelController.h"

#import "DXDataViewController.h"
#import "DXPageContent.h"
#import "DXNetPageContent.h"
#import "DXRootViewController.h"
#import "DXStringPaginator.h"
#import "DXHTMLStripper.h"

/*
 A controller object that manages a simple model -- a collection of month names.
 
 The controller serves as the data source for the page view controller; it therefore implements pageViewController:viewControllerBeforeViewController: and pageViewController:viewControllerAfterViewController:.
 It also implements a custom method, viewControllerAtIndex: which is useful in the implementation of the data source methods, and in the initial configuration of the application.
 
 There is no need to actually create view controllers for each page in advance -- indeed doing so incurs unnecessary overhead. Given the data model, these methods create, configure, and return a new view controller on demand.
 */

@interface DXModelController()
@property (readonly, strong, nonatomic) NSMutableArray *pageData;
@end

@implementation DXModelController
{
    NSOperationQueue *lookupQueue;
}

@synthesize pageData = _pageData;
@synthesize delegate;


- (void)generateTestData
{
    for (int i = 0; i < 10; i++)
    {
        DXPageContent *pContent = [[DXPageContent alloc] init];
        pContent.pageTitle = [NSString stringWithFormat:@"Page %d", i];
        pContent.pageText = @"Four score and seven years ago our fathers brought forth on this continent, a new nation, conceived in Liberty, and dedicated to the proposition that all men are created equal. Now we are engaged in a great civil war, testing whether that nation, or any nation so conceived and so dedicated, can long endure. We are met on a great battle-field of that war. We have come to dedicate a portion of that field, as a final resting place for those who here gave their lives that that nation might live. It is altogether fitting and proper that we should do this.\
";
        [self.pageData addObject:pContent];
    }
}

- (id)init
{
    self = [super init];
    if (self) {
        // Create the data model.
//        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];

        lookupQueue = [[NSOperationQueue alloc] init];
        [lookupQueue setMaxConcurrentOperationCount:5];
        
        _pageData = [[NSMutableArray alloc] initWithCapacity:10]; 
        [self generateTestData];
    }
    return self;
}

- (DXDataViewController *)viewControllerAtIndex:(NSUInteger)index storyboard:(UIStoryboard *)storyboard
{   
    NSLog(@"viewControllerAtIndex %d", index);
    // Return the data view controller for the given index.
    if (([self.pageData count] == 0) || (index >= [self.pageData count])) {
        return nil;
    }
    
    // Create a new view controller and pass suitable data.
    DXDataViewController *dataViewController = [storyboard instantiateViewControllerWithIdentifier:@"DXDataViewController"];
    dataViewController.dataObject = [self.pageData objectAtIndex:index];
    return dataViewController;
}

- (NSUInteger)indexOfViewController:(DXDataViewController *)viewController
{   
     // Return the index of the given data view controller.
     // For simplicity, this implementation uses a static array of model objects and the view controller stores the model object; you can therefore use the model object to identify the index.
    return [self.pageData indexOfObject:viewController.dataObject];
}

#pragma mark - Page View Controller Data Source

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    NSLog(@"viewControllerBeforeViewController");
    NSUInteger index = [self indexOfViewController:(DXDataViewController *)viewController];
    if ((index == 0) || (index == NSNotFound)) {
        return nil;
    }
    
    index--;
    return [self viewControllerAtIndex:index storyboard:viewController.storyboard];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    NSLog(@"viewControllerAfterViewController");
    NSUInteger index = [self indexOfViewController:(DXDataViewController *)viewController];
    if (index == NSNotFound) {
        return nil;
    }
    
    index++;
    if (index == [self.pageData count]) {
        return nil;
    }
    return [self viewControllerAtIndex:index storyboard:viewController.storyboard];
}

- (void)loadPageWithURLString:(NSString *)urlString headers:(NSDictionary *)headers
{
    if (urlString)
    {
        DXNetPageContent *pageToLoad = [[DXNetPageContent alloc] initWithURL:urlString];
        [pageToLoad setRequestHeaders:headers];

        [lookupQueue addOperationWithBlock:^{
            NSLog(@"Loading");
            if ([pageToLoad loadSynchronous])
            {
                NSLog(@"Adding loaded page");
                
                NSString *pageText = pageToLoad.pageText;

                __block CGSize pageSize;
                UIFont *font = READER_FONT;
                dispatch_sync(dispatch_get_main_queue(), ^{
                    pageSize = ((DXRootViewController *)self.delegate).pageViewController.view.frame.size;
                });
                NSArray *pagesOfText = [DXStringPaginator pagesInString:pageText withFont:font frameSize:pageSize];
                
                //[self.pageData insertObject:pageToLoad atIndex:0];
                for (unsigned int i = 0; i < [pagesOfText count]; i++)
                {
                    DXPageContent *page = [[DXPageContent alloc] init];
                    page.pageText = [pagesOfText objectAtIndex:i];
                    page.pageTitle = [NSString stringWithFormat:@"%@ (%d/%d)", pageToLoad.pageTitle, i+1, pagesOfText.count];
                    [self.pageData insertObject:page atIndex:i];
                }
                
                if ([self.delegate respondsToSelector:@selector(pageContentLoaded:atIndex:)])
                {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.delegate pageContentLoaded:pageToLoad atIndex:0];
                    });
                }
                
                NSLog(@"Loaded");
            } else {
                NSLog(@"Failed");
            }
        }];
    }
}

- (void)loadPageWithHTMLContent:(NSString *)contentString
{
    NSDictionary *content = [DXHTMLStripper plainTextFromHTML:contentString];

    __block CGSize pageSize;
    UIFont *font = READER_FONT;

    if ([NSThread isMainThread])
    {
        pageSize = ((DXRootViewController *)self.delegate).pageViewController.view.frame.size;
    } else {
        dispatch_sync(dispatch_get_main_queue(), ^{
            pageSize = ((DXRootViewController *)self.delegate).pageViewController.view.frame.size;
        });
    }
    
    NSArray *pagesOfText = [DXStringPaginator pagesInString:[content valueForKey:@"body"] withFont:font frameSize:pageSize];
    
    for (unsigned int i = 0; i < [pagesOfText count]; i++)
    {
        DXPageContent *page = [[DXPageContent alloc] init];
        page.pageText = [pagesOfText objectAtIndex:i];
        page.pageTitle = [NSString stringWithFormat:@"%@ (%d/%d)", [content valueForKey:@"title"], i+1, pagesOfText.count];
        [self.pageData insertObject:page atIndex:i];
    }
    
    if ([self.delegate respondsToSelector:@selector(pageContentLoaded:atIndex:)])
    {
        if ([NSThread isMainThread])
        {
            [self.delegate pageContentLoaded:[self.pageData objectAtIndex:0] atIndex:0];
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.delegate pageContentLoaded:[self.pageData objectAtIndex:0] atIndex:0];
            });
        }
    }
    
}


@end
