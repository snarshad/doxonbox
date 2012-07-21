
//
// Copyright 2011 Box, Inc.
//
//   Licensed under the Apache License, Version 2.0 (the "License");
//   you may not use this file except in compliance with the License.
//   You may obtain a copy of the License at
//
//       http://www.apache.org/licenses/LICENSE-2.0
//
//   Unless required by applicable law or agreed to in writing, software
//   distributed under the License is distributed on an "AS IS" BASIS,
//   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//   See the License for the specific language governing permissions and
//   limitations under the License.
//

#import "BoxModelUtilityFunctions.h"


@implementation BoxModelUtilityFunctions

+ (NSString *)getFileFolderSizeString:(NSNumber *)_fileSize {
	NSString *result_str = nil;
	long long fileSize = [_fileSize longLongValue];

	if (fileSize > 1000000) {
		double dSize = fileSize / 1000000.0f;
		result_str = [NSString stringWithFormat: @"%1.1f MB", dSize];
	} else if (fileSize > 1000) {
		double dSize = fileSize / 1000.0f;
		result_str = [NSString stringWithFormat: @"%1.1f KB", dSize];
	} else {
		result_str = [NSString stringWithFormat: @"%d bytes", fileSize];
	}

	return result_str;
}

+ (NSString *)getFileDateString:(NSDate *)date {
	NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init]  autorelease];
	[dateFormatter setDateStyle:NSDateFormatterMediumStyle];	
	[dateFormatter setTimeStyle:NSDateFormatterNoStyle];

	NSString *result_str = [dateFormatter stringFromDate: date];
	return result_str;
}

+ (BOOL)isValidEmail:(NSString *)email {
	if(email == nil || [email isEqualToString:@""]) {
		return NO;
	}

	NSString *emailRegEx = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
	GTMRegex *regex = [GTMRegex regexWithPattern:emailRegEx];
	if (([regex matchesString:email]) == YES) {
		return YES;
	} else {
		return NO;
	}
}

+ (NSString *)urlEncodeParameter:(NSString *)paramToEncode {
	NSString *object = (NSString *)CFURLCreateStringByAddingPercentEscapes(
															   NULL,
															   (CFStringRef)paramToEncode,
															   NULL,
															   (CFStringRef)@"!*'();:@&=+$,/?%#[]",
															   kCFStringEncodingUTF8);

    return [object autorelease];
}

@end
