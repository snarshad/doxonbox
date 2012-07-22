//
//  NSString+URLUtils.m
//  KioskWebBrowser
//
//  Created by Arshad Tayyeb on 4/29/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NSString+URLUtils.h"

@implementation NSString (URLUtils)

+ (NSString *)predictedSchemeForPartialURL:(NSString *)partialURL
{
    return (partialURL.length > 0) ? @"http" : nil;
}

- (NSURL *)normalizedURL
{
    NSURL *url = [NSURL URLWithString:[self stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding]];
    
    if (!url || !url.scheme)
    {
        url = [NSURL URLWithString:[[NSString predictedSchemeForPartialURL:self] stringByAppendingFormat:@"://%@", [self stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding]]];
    }
    return url;
}


@end
