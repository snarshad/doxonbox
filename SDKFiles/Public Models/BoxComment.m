
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

#import "BoxComment.h"


@implementation BoxComment

@synthesize message;
@synthesize createdAt;
@synthesize userName;
@synthesize userID;
@synthesize avatarURL;
@synthesize replyComments;

+ (BoxComment *)commentWithAttributes:(NSDictionary *)attributes {
	BoxComment *comment = [[[BoxComment alloc] init] autorelease];
	NSMutableArray *replyComments = [NSMutableArray array];

	NSNumberFormatter *numberFormatter = [[[NSNumberFormatter alloc] init] autorelease];
	[numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];

	comment.objectId = [attributes objectForKey:@"comment_id"];
	comment.message = [attributes objectForKey:@"message"];
	comment.userID = [attributes objectForKey:@"user_id"];
	comment.userName = [attributes objectForKey:@"user_name"];
	comment.createdAt = [NSDate dateWithTimeIntervalSince1970:[(NSString *)[attributes objectForKey:@"created"] intValue]];
	comment.avatarURL = [NSURL URLWithString:[attributes objectForKey:@"avatar_url"]];
	for (NSDictionary *replyComment in [attributes objectForKey:@"reply_comments"]) {
		[replyComments addObject:[BoxComment commentWithAttributes:replyComment]];
	}
	comment.replyComments = replyComments;

	return comment;
}

- (void)dealloc {
	self.objectId = nil;
	self.message = nil;
	self.userID = nil;
	self.userName = nil;
	self.createdAt = nil;
	self.avatarURL = nil;
	self.replyComments = nil;

	[super dealloc];
}

- (NSDictionary *)attributesDictionary {
	NSArray *keys = [self attributeNames];
	NSMutableDictionary *info = [NSMutableDictionary dictionaryWithCapacity:[keys count]];

	for (NSString *key in keys) {
		id result = [self performSelector:NSSelectorFromString(key)];
		if (result) {
			[info setObject:result forKey:key];
		}
	}

	return info;
}

- (NSArray *)attributeNames {
	return [NSArray arrayWithObjects:
			@"message",
			@"createdAt",
			@"userName",
			@"userID",
			@"avatarURL",
			@"replyComments",
			nil];
}

@end
