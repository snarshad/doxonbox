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

    if ([_webLoadLock lockWhenCondition:0 beforeDate:[NSDate dateWithTimeIntervalSinceNow:10]])
    {
        dispatch_sync(dispatch_get_main_queue(), ^{
        text = [g_webView stringByEvaluatingJavaScriptFromString:@"document.body.innerText"];
        });
        [_webLoadLock unlock];
    } else {
        dispatch_sync(dispatch_get_main_queue(), ^{
            text = [g_webView stringByEvaluatingJavaScriptFromString:@"document.body.innerText"];
        });
    }
    
    return text;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [_webLoadLock lock];
    [_webLoadLock unlockWithCondition:0];    
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [_webLoadLock lock];
    [_webLoadLock unlockWithCondition:0];
}

+ (NSString *)plainTextFromHTML:(NSString *)stringWithHTML
{
    return [[DXHTMLStripper sharedStripper] plainTextFromHTML:stringWithHTML];
}

@end
