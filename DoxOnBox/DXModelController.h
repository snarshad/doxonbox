//
//  DXModelController.h
//  DoxOnBox
//
//  Created by Arshad Tayyeb on 7/21/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DXDataViewController, DXPageContent;

@protocol DXModelDelegate <NSObject>
- (void)pageContentLoaded:(DXPageContent *)pageContent atIndex:(NSInteger)index;
@end

@interface DXModelController : NSObject <UIPageViewControllerDataSource>
@property (weak) id<DXModelDelegate> delegate;

- (DXDataViewController *)viewControllerAtIndex:(NSUInteger)index storyboard:(UIStoryboard *)storyboard;
- (NSUInteger)indexOfViewController:(DXDataViewController *)viewController;

- (void)loadPageWithURLString:(NSString *)urlString headers:(NSDictionary *)headers;

@end
