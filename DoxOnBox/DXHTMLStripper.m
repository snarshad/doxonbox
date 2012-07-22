//
//  DXHTMLStripper.m
//  DoxOnBox
//
//  Created by Arshad Tayyeb on 7/21/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "DXHTMLStripper.h"

static UIWebView *g_webView = nil;
static DXHTMLStripper * g_stripper = nil;

@interface DXHTMLStripper ()
- (NSString *)plainTextFromHTML:(NSString *)originalString;
@end

@implementation DXHTMLStripper
{
    NSConditionLock *_webLoadLock; 
}

- (id)init
{
    if (self = [super init])
    {
        _webLoadLock = [[NSConditionLock alloc] initWithCondition:0];
    }
                return self;
}

+ (DXHTMLStripper *)sharedStripper
{
    @synchronized (self)
    {
        if (g_stripper == nil)
            g_stripper = [[DXHTMLStripper alloc] init];
    }
    return g_stripper;
}

- (NSString *)plainTextFromHTML:(NSString *)originalString
{
    NSLog(@"plainTextFromHTML: %@.  \r\n Original:%@", g_webView, originalString);

    dispatch_sync(dispatch_get_main_queue(), ^{
        if (!g_webView)
        {
            g_webView = [[UIWebView alloc] initWithFrame:CGRectZero];
        };
    });
    
    NSLog(@"loading HTML: %@", g_webView);

    [_webLoadLock lock];
    [_webLoadLock unlockWithCondition:1];
    [g_webView loadHTMLString:originalString baseURL:nil];
    
    __block NSString *text = nil;
    
    if ([_webLoadLock lockWhenCondition:1 beforeDate:[NSDate dateWithTimeIntervalSinceNow:10]])
    {
        NSLog(@"Success waiting for lock");
        dispatch_sync(dispatch_get_main_queue(), ^{
        text = [g_webView stringByEvaluatingJavaScriptFromString:@"document.body.innerText"];
        });
    } else {
        NSLog(@"Gave up waiting for lock after 10 secs");
        dispatch_sync(dispatch_get_main_queue(), ^{
            text = [g_webView stringByEvaluatingJavaScriptFromString:@"document.body.innerText"];
        });
    }
    
    NSLog(@"TEXT: %@", text);
    return text;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [_webLoadLock lock];
    [_webLoadLock unlockWithCondition:0];
    NSLog(@"Finished Loading");
    
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [_webLoadLock lock];
    [_webLoadLock unlockWithCondition:0];
    NSLog(@"Error Loading");
    
}

+ (NSString *)plainTextFromHTML:(NSString *)stringWithHTML
{
    return [[DXHTMLStripper sharedStripper] plainTextFromHTML:stringWithHTML];
}

@end
