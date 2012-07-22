//
//  DXNetPageContent.m
//  DoxOnBox
//
//  Created by Arshad Tayyeb on 7/21/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "DXNetPageContent.h"
#import "NSString+stripHtml.h"
#import "NSString+ContentEncoding.h"
#import "DXStringPaginator.h"

@interface DXNetPageContent ()
- (BOOL)loadAsynchronous;
@end

@implementation DXNetPageContent
{
    BOOL _loading;
    BOOL _loaded;    
    NSString *_urlString;
    NSDictionary *_requestHeaders;
    NSData *_data;
}
@synthesize urlString = _urlString, requestHeaders = _requestHeaders, loaded = _loaded, loading = _loading;
@synthesize data=_data;

- (id)initWithURL:(NSString *)urlString
{
    if (self = [super init])
    {
        self.urlString = urlString;
    }
    return self;
}

- (BOOL)loadAsynchronous
{
    if (self.loading)
        return YES;

    @synchronized (self)
    {
        self.loading = YES;
        self.loaded = NO;
        self.data = nil;
    }

    [NSThread detachNewThreadSelector:@selector(loadSynchronous) toTarget:self withObject:nil];
    
    return YES;
}

- (BOOL)loadSynchronous
{
    NSURL *url = [NSURL URLWithString:self.urlString];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];

    if (self.requestHeaders.count > 0)
    {
        [request setAllHTTPHeaderFields:self.requestHeaders];
    }
    
    NSLog(@"Requesting: %@.  Headers: %@", self.urlString, self.requestHeaders);
    
    NSHTTPURLResponse *response = nil;
    NSError *error = nil;
    
    self.loaded = NO;

    self.data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];

    @synchronized (self)
    {
        self.loading = NO;
    }

    if (error || !self.data)
    {
        NSLog(@"Did not get any data from URL %@.  Error: %@", self.urlString, error);
    } else {
        NSLog(@"Response headers: %@", [response allHeaderFields]);
        @synchronized (self)
        {
            self.loaded = YES;
            NSStringEncoding encoding = NSUTF8StringEncoding;
            
            NSString *encodedString =[[NSString alloc] initWithData:self.data
                                                           encoding:encoding];
            if ([[response.allHeaderFields allKeys] containsObject:@"Content-Type"])
            {
                NSString *contentType = [response.allHeaderFields valueForKey:@"Content-Type"];
                encoding = [NSString stringEncodingFromContentType:contentType];
                
                if ([contentType rangeOfString:@"text/html"].location != NSNotFound)
                {
                    encodedString = [encodedString stripHtml];
                }
                
                NSLog(@"Detected encoding %d from %@", encoding, contentType); 
            }
                
            self.pageText = encodedString;
        }        
        NSArray *sentences = [DXStringPaginator sentencesInString:self.pageText];
        for (NSString *sentence in sentences)
        {
            NSLog(@"** %@\r\n", sentence);
        }
        
        NSArray *pages = [DXStringPaginator pagesInString:self.pageText withFont:[UIFont systemFontOfSize:18] frameSize:CGSizeMake(320, 480)];

        for (NSString *page in pages)
        {
            NSLog(@"*PAGE* %@\r\n", page);
        }
        
    }
    return self.loaded;
}


@end
