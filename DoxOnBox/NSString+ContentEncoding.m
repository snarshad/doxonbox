//
//  NSString+ContentEncoding.m
//  DoxOnBox
//
//  Created by Arshad Tayyeb on 7/21/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NSString+ContentEncoding.h"

@implementation NSString (ContentEncoding)

+ (NSStringEncoding)stringEncodingFromContentType:(NSString*)contentType {
    
	NSString *mimeType;
	NSString *charEncoding;
    
	NSRange semicolonRange = [contentType rangeOfString: @";"];
	if (semicolonRange.location == NSNotFound) {
		mimeType = contentType;
		charEncoding = @"";
	} else {
		mimeType = [contentType substringToIndex:semicolonRange.location];
		NSRange charsetEqualsRange = [contentType rangeOfString: @"charset="];
		if (charsetEqualsRange.location == NSNotFound)
			charEncoding = @"";
		else {
			NSInteger encodingIndex = charsetEqualsRange.location + charsetEqualsRange.length;
			charEncoding = [contentType substringFromIndex:encodingIndex];
		}
	}
    
	// Finally convert to an NSStringEncoding
	NSStringEncoding stringEncoding = CFStringConvertEncodingToNSStringEncoding(CFStringConvertIANACharSetNameToEncoding((__bridge CFStringRef)charEncoding));
    
	return stringEncoding;
}
@end
