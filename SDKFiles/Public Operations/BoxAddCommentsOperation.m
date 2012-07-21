
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

#import "BoxAddCommentsOperation.h"
#import "BoxLoginViewController.h"


@interface BoxAddCommentsOperation() {
	NSString * _targetID;
	NSString *_targetType;
	NSString *_message;
	NSString *_authToken;
}

- (id)initForTargetID:(NSString *)_targetID
		   targetType:(NSString *)targetType
			  message:(NSString *)message
			authToken:(NSString *)authToken
			 delegate:(id <BoxOperationDelegate>)delegate;

@end


@implementation BoxAddCommentsOperation

@synthesize targetID = _targetID;
@synthesize targetType = _targetType;
@synthesize message = _message;
@synthesize authToken = _authToken;

+ (BoxAddCommentsOperation *)operationForTargetID:(NSString *)targetID
									   targetType:(NSString *)targetType
										  message:(NSString *)message
{
	return [[[BoxAddCommentsOperation alloc] initForTargetID:targetID
												  targetType:targetType
													 message:message
												   authToken:[BoxLoginViewController currentUser].authToken
													delegate:nil] autorelease];
}

- (id)initForTargetID:(NSString *)targetID
		   targetType:(NSString *)targetType
			  message:(NSString *)message
			authToken:(NSString *)authToken
			 delegate:(id <BoxOperationDelegate>)delegate
{
	if (self = [super initForType:BoxOperationTypeAddComment delegate:delegate]) {
		self.targetID = targetID;
		self.targetType = targetType;
		self.message = message;
		self.authToken = authToken;
	}

	return self;
}

- (void)dealloc {
	self.targetType = nil;
	self.message = nil;
	self.authToken = nil;
    
    [_targetID release];
    _targetID = nil;

	[super dealloc];
}

- (NSURL *)url {
	return [NSURL URLWithString:[BoxRESTApiFactory addCommentsURLStringForAuthToken:self.authToken
																		 targetType:self.targetType
																		   targetID:self.targetID
																			message:self.message]];
}

- (NSString *)successCode {
	return @"add_comment_ok";
}

@end
