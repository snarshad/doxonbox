
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

#import "BoxGetCommentsOperation.h"
#import "BoxComment.h"
#import "BoxCommentsListModelXMLBuilder.h"
#import "BoxLoginViewController.h"


@interface BoxGetCommentsOperation()  {
	NSString * _targetID;
	NSString *_targetType;
	NSString *_authToken;
    
	NSArray *_comments;
}

- (id)initForTargetID:(NSString *)targetID
		   targetType:(NSString *)targetType
			authToken:(NSString *)authToken
			 delegate:(id<BoxOperationDelegate>)delegate;

@end

@implementation BoxGetCommentsOperation

@synthesize targetID = _targetID;
@synthesize targetType = _targetType;
@synthesize authToken = _authToken;
@synthesize comments = _comments;

+ (BoxGetCommentsOperation *)operationForTargetID:(NSString *)targetID
									   targetType:(NSString *)targetType
{
	return [[[BoxGetCommentsOperation alloc] initForTargetID:targetID
												  targetType:targetType
												   authToken:[BoxLoginViewController currentUser].authToken
													delegate:nil] autorelease];
}

- (id)initForTargetID:(NSString *)targetID
		   targetType:(NSString *)targetType
			authToken:(NSString *)authToken
			 delegate:(id<BoxOperationDelegate>)delegate
{
	if (self = [super initForType:BoxOperationTypeGetComments delegate:delegate]) {
		self.targetID = targetID;
		self.targetType = targetType;
		self.authToken = authToken;
	}

	return self;
}

- (void)dealloc {
	self.targetType = nil;
	self.authToken = nil;
    [_comments release];
    _comments = nil;
    [_targetID release];
    _targetID = nil;

	[super dealloc];
}

- (void)requestDidCompleteWithResponse:(NSHTTPURLResponse *)response {
	if (_receivedData != nil && [response statusCode] == 200) {
		BoxCommentsListModelXMLBuilder *builder = [[BoxCommentsListModelXMLBuilder alloc] init];
		NSMutableDictionary *result = [NSMutableDictionary dictionaryWithObject:[builder commentsForURL:[self url]]
																		 forKey:@"comments"];
		_receivedData = nil;
		[result setObject:builder.status forKey:@"status"];
		[builder release];

		if (!self.error) {
			[self processResult:result];
		}
	}

	[super requestDidCompleteWithResponse:response];
}

- (NSURL *)url {
	return [NSURL URLWithString:[BoxRESTApiFactory getCommentsURLStringForAuthToken:self.authToken
																		 targetType:self.targetType
																		   targetID:self.targetID]];
}

- (NSString *)successCode {
	return @"get_comments_ok";
}

- (NSArray *)resultKeysOfInterest {
	return [NSArray arrayWithObjects:@"status", @"comments", nil];
}

- (void)processResult:(NSDictionary *)result {
	_comments = [result objectForKey:@"comments"];
	if (_comments) {
		[_comments retain];
	}

	[super processResult:result];
}

@end
