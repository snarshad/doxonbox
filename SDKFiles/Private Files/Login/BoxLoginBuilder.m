
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

#import "BoxLoginBuilder.h"
#import "BoxGetTicketOperation.h"
#import "BoxGetAuthTokenOperation.h"
#import "BoxNetworkOperationManager.h"



#define REMEMBER_LOGIN @"remember_login="

@interface BoxLoginBuilder() {
    BOOL __rememberLogin;
    NSOperationQueue * __queue;
    BoxGetTicketOperation *__ticketOperation;
}

@property (nonatomic, readwrite, assign) BOOL rememberLogin;
@property (nonatomic, readwrite, retain) NSOperationQueue * queue;
@property (nonatomic, readwrite, retain) BoxGetTicketOperation * ticketOperation;

@end

@implementation BoxLoginBuilder

@synthesize rememberLogin = __rememberLogin;
@synthesize queue = __queue;
@synthesize ticketOperation = __ticketOperation;

- (id)initWithWebview:(UIWebView *)webView delegate:(id<BoxLoginBuilderDelegate>)delegate {
	if ((self = [super init])) {
		_webView = webView;
		webView.delegate = self;
		
		_delegate = delegate;
		
		__ticketOperation = [[BoxGetTicketOperation alloc] initWithDelegate:self];
        __queue = [[NSOperationQueue alloc] init];
	}
	return self;
}

- (void)dealloc {
	
	_webView.delegate = nil;
	__ticketOperation.delegate = nil;
	
	[__ticketOperation release];
    __ticketOperation = nil;
    [__queue release];
    __queue = nil;
	
	[super dealloc];
}

- (void)startLoginProcess {
	
	// if we don't have the ticket, request it
	// otherwise, go straight to the next step
	if (!self.ticketOperation.ticket || self.ticketOperation.ticket == @"") {
        if (_delegate) {
            [_delegate startActivityIndicator];
        }
        [self.queue addOperation:self.ticketOperation];
    } else {
        [self operation:self.ticketOperation didCompleteForPath:nil response:BoxOperationResponseSuccessful];
    }
}

#pragma mark -
#pragma mark BoxOperationDelegate

- (void)operation:(BoxOperation *)op didCompleteForPath:(NSString *)path response:(BoxOperationResponse)response {
	if (response != BoxOperationResponseSuccessful) {
		dispatch_async(dispatch_get_main_queue(), ^{
			[_delegate loginOperation:op failedWithError:BoxLoginBuilderResponseTypeFailed];
		});
	}
	// what we do depends on which operation completed
	else if (op.operationType == BoxOperationTypeGetTicket) {
		// need to launch the webview
		_webViewStep = BoxLoginBuilderWebViewStepBegin;
		dispatch_async(dispatch_get_main_queue(), ^{
			[_delegate startActivityIndicator];
			[_webView loadRequest:[NSURLRequest requestWithURL:self.ticketOperation.authenticationURL]];
		});
	} else if (op.operationType == BoxOperationTypeGetAuthToken) {
		// login complete!
		dispatch_async(dispatch_get_main_queue(), ^{
			[_delegate loginCompletedWithUser:((BoxGetAuthTokenOperation*)op).user stayLoggedIn:self.rememberLogin];
			[_delegate stopActivityIndicator];
		});
	}
}

#pragma mark -
#pragma mark UIWebViewDelegate

- (void)webViewDidFinishLoad:(UIWebView *)webView {

	if (_webViewStep == BoxLoginBuilderWebViewStepFormSubmitted) {
		// start the authentication request
		[_delegate startActivityIndicator];
        BoxGetAuthTokenOperation * authTokenOperation = [[[BoxGetAuthTokenOperation alloc] initWithTicket:self.ticketOperation.ticket delegate:self] autorelease];
		[self.queue addOperation:authTokenOperation];
	} else if (_webViewStep == BoxLoginBuilderWebViewStepUserPassField) {
		[_delegate stopActivityIndicator];
	}
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
	// request type  UIWebViewNavigationTypeFormSubmitted means they hit log in
	// request type UIWebViewNavigationTypeOther means we fed it to the UIWebView
	if (navigationType == UIWebViewNavigationTypeOther) {
		_webViewStep = BoxLoginBuilderWebViewStepUserPassField;
	} else if (navigationType == UIWebViewNavigationTypeFormSubmitted) {
        NSData * httpBody = [request HTTPBody];
        NSString * request = [[[NSString alloc] initWithData:httpBody encoding:NSUTF8StringEncoding] autorelease];
        NSRange range = [request rangeOfString:REMEMBER_LOGIN]; //This must be updated if the website changes. It is based off a parameter name in the url.
        if (range.location == NSNotFound) {
            self.rememberLogin = NO;
        } else {
            self.rememberLogin = YES;
        }
		_webViewStep = BoxLoginBuilderWebViewStepFormSubmitted;
	}
	return YES;
}

@end
