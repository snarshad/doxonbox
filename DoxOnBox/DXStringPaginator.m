//
//  DXStringPaginator.m
//  DoxOnBox
//
//  Created by Arshad Tayyeb on 7/21/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "DXStringPaginator.h"

@interface DXStringPaginator()
+ (DXStringPaginator *)sharedPaginator;
@end

static DXStringPaginator *g_stringPaginator = nil;

@implementation DXStringPaginator
{
    
}

+ (DXStringPaginator *)sharedPaginator
{
    if (!g_stringPaginator)
    {
        g_stringPaginator = [[DXStringPaginator alloc] init];
    }
    return g_stringPaginator;
}

- (id)init
{
    if (self = [super init])
    {
    }
    return self;
}

- (NSArray *)sentencesInString:(NSString *)string
{
    __block NSMutableArray *sentences = [[NSMutableArray alloc] init];
    [string enumerateSubstringsInRange:NSMakeRange(0, string.length) options:NSStringEnumerationBySentences usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
        [sentences addObject:[string substringWithRange:substringRange]];
    }];
    return sentences;
}

+ (NSArray *)sentencesInString:(NSString *)string
{
    return [[DXStringPaginator sharedPaginator] sentencesInString:string];
}

@end
