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

@implementation DXHTMLStripper
{
    NSLock *_webLoadLock; 
}

- (id)init
{
    if (self = [super init])
    {
        _webLoadLock = [[NSLock alloc] init];
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

- (NSString *)getTextFromWebview:(NSString *)originalString
{
    NSLog(@"getTextFromWebview: %@.  \r\n Original:%@", g_webView, self);
    if (![NSThread isMainThread])
    {
        return [[self onMainAsync:NO] getTextFromWebview:originalString];
    }
    
    if (!g_webView)
    {
        g_webView = [[UIWebView alloc] initWithFrame:CGRectZero];
    }
    
    NSLog(@"loading HTML: %@", g_webView);
    
    
    [g_webView loadHTMLString:originalString baseURL:nil];
    
    NSString *text = [g_webView stringByEvaluatingJavaScriptFromString:@"document.body.innerText"];
    
    NSLog(@"TEXT: %@", text);
    return text;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    NSLog(@"Finished Loading");
    
}

+ (NSString *)stripHTMLFrom:(NSString *)stringWithHTML
{
    return [[DXHTMLStripper sharedStripper] getTextFromWebview:stringWithHTML];
}

@end
