
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

#import "BoxGetUpdatesOperation.h"
#import "BoxUpdatesListModelXMLBuilder.h"
#import "BoxLoginViewController.h"


@interface BoxGetUpdatesOperation() {
	NSDate *_updatesStart;
	NSString *_authToken;
	
	NSArray *_updates;
}

- (id)initForStartTime:(NSDate *)updatesStart
			 authToken:(NSString *)authToken
			  delegate:(id<BoxOperationDelegate>)delegate;

@end

@implementation BoxGetUpdatesOperation

@synthesize updatesStart = _updatesStart;
@synthesize authToken = _authToken;
@synthesize updates = _updates;

+ (BoxGetUpdatesOperation *)operationForStartTime:(NSDate *)updatesStart
{
	return [[[BoxGetUpdatesOperation alloc] initForStartTime:updatesStart
												   authToken:[BoxLoginViewController currentUser].authToken
													delegate:nil] autorelease];
}

- (id)initForStartTime:(NSDate *)updatesStart
			 authToken:(NSString *)authToken
			  delegate:(id<BoxOperationDelegate>)delegate
{
	if (self = [super initForType:BoxOperationTypeGetUpdates delegate:delegate]) {
		self.updatesStart = updatesStart;
		self.authToken = authToken;
	}

	return self;
}

- (void)dealloc {
	self.updatesStart = nil;
	self.authToken = nil;
    [_updates release];
    _updates = nil;

	[super dealloc];
}

- (void)requestDidCompleteWithResponse:(NSHTTPURLResponse *)response {
	if (_receivedData != nil && [response statusCode] == 200) {
		BoxUpdatesListModelXMLBuilder *builder = [[BoxUpdatesListModelXMLBuilder alloc] init];
		NSArray *updates = [builder updatesWithData:_receivedData];
		NSMutableDictionary *result = [NSMutableDictionary dictionaryWithObject:updates
																		 forKey:@"updates"];
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
	return [NSURL URLWithString:[BoxRESTApiFactory updatesURLStringSince:self.updatesStart
															   authToken:self.authToken]];
}

- (NSString *)successCode {
	return @"s_get_updates";
}

- (NSArray *)resultKeysOfInterest {
	return [NSArray arrayWithObjects:@"status", @"updates", nil];
}

- (void)processResult:(NSDictionary *)result {
	_updates = [result objectForKey:@"updates"];
	if (_updates) {
		[_updates retain];
	}

	[super processResult:result];
}

@end
