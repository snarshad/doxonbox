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
- (NSDictionary *)plainTextFromHTML:(NSString *)originalString;
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

- (NSDictionary *)plainTextFromHTML:(NSString *)originalString
{
    if ([NSThread isMainThread])
    {
        NSLog(@"*** WARNING - there is trouble when this is on the main thread");
    }

    dispatch_sync(dispatch_get_main_queue(), ^{
        if (!g_webView)
        {
            g_webView = [[UIWebView alloc] initWithFrame:CGRectZero];
        };
        g_webView.delegate = self;
    });
    
    [_webLoadLock lock];
    [_webLoadLock unlockWithCondition:1];
    g_webView.delegate = self;
    [g_webView loadHTMLString:originalString baseURL:nil];
    
    __block NSString *text = nil;
    __block NSString *title = nil;

    NSLog(@"Locking When 0.");
    if ([_webLoadLock lockWhenCondition:0 beforeDate:[NSDate dateWithTimeIntervalSinceNow:20]])
    {
        NSLog(@"Locked When 0.");
            dispatch_sync(dispatch_get_main_queue(), ^{
//                title = [g_webView stringByEvaluatingJavaScriptFromString:@"document.title"];
                text = [g_webView stringByEvaluatingJavaScriptFromString:@"document.body.innerText"];
                NSLog(@"2. title: %@", title);
            });
        [_webLoadLock unlock];
    } else {
            dispatch_sync(dispatch_get_main_queue(), ^{
                text = [g_webView stringByEvaluatingJavaScriptFromString:@"document.body.innerText"];
                //            title = [g_webView stringByEvaluatingJavaScriptFromString:@"document.title"];
                NSLog(@"4.  title: %@", title);
            });
    }
    
    return [NSDictionary dictionaryWithObjectsAndKeys:
            title ? title : @"HTML Document", @"title",
            text ? text : @"", @"body",
            nil];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    NSLog(@"Finished Load");
    [_webLoadLock lock];
    [_webLoadLock unlockWithCondition:0];    
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    NSLog(@"Error Load");
    [_webLoadLock lock];
    [_webLoadLock unlockWithCondition:0];
}

+ (NSDictionary *)plainTextFromHTML:(NSString *)stringWithHTML
{
    return [[DXHTMLStripper sharedStripper] plainTextFromHTML:stringWithHTML];
}

@end
