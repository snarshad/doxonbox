
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

#import "BoxDeleteCommentOperation.h"
#import "BoxLoginViewController.h"


@interface BoxDeleteCommentOperation()

- (id)initForCommentID:(NSString *)commentID
			 authToken:(NSString *)authToken
			  delegate:(id<BoxOperationDelegate>)delegate;

@end

@implementation BoxDeleteCommentOperation

@synthesize commentID = _commentID;
@synthesize authToken = _authToken;

+ (BoxDeleteCommentOperation *)operationForCommentID:(NSString *)commentID
{
	return [[[BoxDeleteCommentOperation alloc] initForCommentID:commentID
													  authToken:[BoxLoginViewController currentUser].authToken
                                                       delegate:nil] autorelease];
}

- (id)initForCommentID:(NSString *)commentID
			 authToken:(NSString *)authToken
			  delegate:(id<BoxOperationDelegate>)delegate
{
	if (self = [super initForType:BoxOperationTypeAddComment delegate:delegate]) {
		self.commentID = commentID;
		self.authToken = authToken;
	}

	return self;
}

- (void)dealloc {
	self.authToken = nil;
    [_commentID release];
    _commentID = nil;

	[super dealloc];
}

- (NSURL *)url {
	return [NSURL URLWithString:[BoxRESTApiFactory deleteCommentURLStringForAuthToken:self.authToken
																			commentID:self.commentID]];
}

- (NSString *)successCode {
	return @"delete_comment_ok";
}

@end
