
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

#import "BoxLoginViewController.h"
#import "BoxCommonUISetup.h"
#import "BoxLoginNavigationController.h"
#import "BoxLoginBuilder.h"


@interface BoxLoginViewController () <BoxLoginBuilderDelegate> {
    UIWebView * __webView;
    BoxLoginBuilder * __loginBuilder;
    id<BoxLoginViewControllerDelegate> __boxLoginDelegate;
}

@property (nonatomic, readwrite, retain) UIWebView * webView;
@property (nonatomic, readwrite, retain) BoxLoginBuilder * loginBuilder;

- (void)loginAction;

@end

@implementation BoxLoginViewController

@synthesize boxLoginDelegate = __boxLoginDelegate, webView = __webView, loginBuilder = __loginBuilder;

#pragma mark - Initialization

- (id)init {
    self = [super init];
    return self;
}

/* This method either returns a BoxLoginNavBarViewController or a BoxLoginViewController depending on includeNavBar. BoxLoginNavBarViewController subclasses UINavigationController, but also responds to all
 the same methods as BoxLoginViewController. */

+ (id)loginViewControllerWithNavBar:(BOOL)includeNavBar {
    if (includeNavBar) {
        UIViewController * internalViewController =[[BoxLoginViewController alloc] init];
        BoxLoginNavigationController * navController = [[[BoxLoginNavigationController alloc] initWithRootViewController:internalViewController] autorelease];
        [BoxCommonUISetup formatNavigationBarWithBoxIconAndColorScheme:navController andNavItem:internalViewController.navigationItem];
        UIBarButtonItem * cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:navController action:@selector(cancelButtonPressed:)];
        internalViewController.navigationItem.leftBarButtonItem = cancelButton;
        [internalViewController release];
        [cancelButton release];
        return navController;
    } else {
        return [[[BoxLoginViewController alloc] init] autorelease];
    }
}

#pragma mark - Class Methods

+ (BoxUser *)currentUser { 
    return [BoxUser savedUser];
}

+ (BOOL)userSignedIn {
    return [BoxUser savedUser] != nil;
}

+ (void)logoutCurrentUser {
    [BoxUser clearSavedUser];
}

#pragma mark - View Lifecycle

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
	if (self.webView == nil)
	{
		self.webView = [[[UIWebView alloc] initWithFrame:self.view.bounds] autorelease];
		[self.view addSubview:self.webView];
    }
	[self performSelectorOnMainThread:@selector(loginAction) withObject:nil waitUntilDone:NO];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self stopActivityIndicator];
}

- (void)loadView {
    [super loadView];
    self.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - self.navigationController.navigationBar.frame.size.height); //automatically resizes in case of a nav bar
}

- (void)dealloc {
    [__webView release];
    __webView = nil;
    [__loginBuilder release];
    __loginBuilder = nil;
    __boxLoginDelegate = nil;
    [super dealloc];
}

#pragma mark - Login Methods

- (void)loginAction {
    @synchronized(self) {
        if (!self.loginBuilder) {
            self.loginBuilder = [[BoxLoginBuilder alloc] initWithWebview:self.webView delegate:self];
            [self.loginBuilder release]; //back to a retain count of 1. Shouldn't autorelease because on a different thread
        }
    }
	
	[self.loginBuilder startLoginProcess];
}

#pragma mark - BoxLoginBuilderDelegate Methods

- (void)loginCompletedWithUser:(BoxUser *)user stayLoggedIn:(BOOL)stayLoggedIn {
    [user save:stayLoggedIn];
    if (self.boxLoginDelegate && [self.boxLoginDelegate respondsToSelector:@selector(boxLoginViewController:didFinishWithResult:)]) {
        [self.boxLoginDelegate boxLoginViewController:self didFinishWithResult:LoginSuccess];
    } else {
        NSLog(@"Login was completed in BoxLoginViewController and it tried to notify its delegate, but the delegate was nil or boxLoginViewController:didFinishWithResult: has not been implemented.");
    }
}

- (void)loginOperation:(BoxOperation*)op failedWithError:(BoxLoginBuilderResponseType)response {
    BOOL displayError = YES;
    if (self.boxLoginDelegate && [self.boxLoginDelegate respondsToSelector:@selector(boxLoginViewController:shouldDisplayError:)]) {
        displayError = [self.boxLoginDelegate boxLoginViewController:self shouldDisplayError:op.error];
    }
    if (displayError) {
        NSString * message = [op.error localizedDescription];
        if (response == BoxLoginBuilderResponseTypeFailed) {
            message = @"Wrong username/password. Please try again.";
        }
        UIAlertView * alertView = [[[UIAlertView alloc] initWithTitle:@"Error" message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] autorelease];
        [alertView performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:NO];
    }
}

- (void)startActivityIndicator {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
}

- (void)stopActivityIndicator {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}

@end
