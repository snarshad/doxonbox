
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

#import "BoxObject.h"

@interface BoxComment : BoxObject {
	
}

@property (retain, nonatomic) NSString *message;
@property (retain, nonatomic) NSDate *createdAt;
@property (retain, nonatomic) NSString *userName;
@property (retain, nonatomic) NSNumber *userID;
@property (retain, nonatomic) NSURL *avatarURL;
@property (retain, nonatomic) NSArray *replyComments;

+ (BoxComment *)commentWithAttributes:(NSDictionary *)attributes;

- (NSDictionary *)attributesDictionary;
- (NSArray *)attributeNames;

@end
