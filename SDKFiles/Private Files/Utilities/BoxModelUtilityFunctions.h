
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

#import <Foundation/Foundation.h>
#import "GTMRegex.h"

/*
 * BoxModelUtilityFunctions contains a couple of functions that the Box.com application uses to format date and file size. 
 * these are just for convenience.
 */

@interface BoxModelUtilityFunctions : NSObject {

}

+ (NSString *)getFileDateString:(NSDate *)date;
+ (NSString *)getFileFolderSizeString:(NSNumber *)fileSize;
+ (BOOL)isValidEmail:(NSString *)email;
+ (NSString *)urlEncodeParameter:(NSString *)paramToEncode;

@end
