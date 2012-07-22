//
//  DXNetPageContent.h
//  DoxOnBox
//
//  Created by Arshad Tayyeb on 7/21/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "DXPageContent.h"

@interface DXNetPageContent : DXPageContent
@property (nonatomic, strong) NSString *urlString;
@property (nonatomic, strong) NSDictionary *requestHeaders;
@property (readwrite) BOOL loaded;
@property (readwrite) BOOL loading;
@property (nonatomic, strong) NSData *data;

- (BOOL)loadAsynchronous;
- (BOOL)loadSynchronous;

- (id)initWithURL:(NSString *)urlString;
@end
