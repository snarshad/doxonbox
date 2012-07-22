//
//  NSString+ContentEncoding.h
//  DoxOnBox
//
//  Created by Arshad Tayyeb on 7/21/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (ContentEncoding)
+ (NSStringEncoding)stringEncodingFromContentType:(NSString*)contentType;

@end
