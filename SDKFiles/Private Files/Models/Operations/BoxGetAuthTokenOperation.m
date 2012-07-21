
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

#import "BoxGetAuthTokenOperation.h"
#import "BoxUser.h"

@implementation BoxGetAuthTokenOperation

@synthesize user = _user;
@synthesize ticket = _ticket;

+ (BoxGetAuthTokenOperation *)operationWithTicket:(NSString *)ticket
										 delegate:(id<BoxOperationDelegate>)delegate
{
	return [[[BoxGetAuthTokenOperation alloc] initWithTicket:ticket delegate:delegate] autorelease];
}

- (id)initWithTicket:(NSString *)ticket
			delegate:(id<BoxOperationDelegate>)delegate
{
	if ((self = [super initForType:BoxOperationTypeGetAuthToken delegate:delegate])) {
		self.user = nil;
		self.ticket = ticket;
	}

	return self;
}

- (void)dealloc {
	self.user = nil;
	self.ticket = nil;

	[super dealloc];
}

- (NSURL *)url {
	return [NSURL URLWithString:[BoxRESTApiFactory getAuthTokenUrlStringForTicket:self.ticket]];
}

- (NSArray *)resultKeysOfInterest {
	return [NSArray arrayWithObjects:@"status", @"auth_token", @"user", nil];
}

- (NSString *)successCode {
	return @"get_auth_token_ok";
}

- (void)processResult:(NSDictionary *)result {
	if ([[result objectForKey:@"status"] isEqual:[self successCode]]) {
		NSDictionary *userInfo = [result objectForKey:@"user"];
		self.user = [BoxUser userWithAttributes:userInfo];
		self.user.authToken = [result objectForKey:@"auth_token"];
	}

	[super processResult:result];
}

- (NSURL *)authenticationURL {
	if (!self.ticket) {
		return nil;
	}

	return [NSURL URLWithString:[BoxRESTApiFactory authenticationUrlStringForTicket:self.ticket]];
}

@end
