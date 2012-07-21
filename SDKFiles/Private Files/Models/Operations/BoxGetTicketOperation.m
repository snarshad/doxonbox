
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

#import "BoxGetTicketOperation.h"


@implementation BoxGetTicketOperation

@synthesize ticket = _ticket;

+ (BoxGetTicketOperation *)operationWithDelegate:(id<BoxOperationDelegate>)delegate {
	return [[[BoxGetTicketOperation alloc] initWithDelegate:delegate] autorelease];
}

- (id)initWithDelegate:(id<BoxOperationDelegate>)delegate {
	if ((self = [super initForType:BoxOperationTypeGetTicket delegate:delegate])) {
		self.ticket = nil;
	}

	return self;
}

- (void)dealloc {
	self.ticket = nil;

	[super dealloc];
}

- (NSURL *)url {
	return [NSURL URLWithString:[BoxRESTApiFactory getTicketUrlString]];
}

- (NSArray *)resultKeysOfInterest {
	return [NSArray arrayWithObjects:@"status", @"ticket", nil];
}

- (NSString *)successCode {
	return @"get_ticket_ok";
}

- (void)processResult:(NSDictionary *)result {
	self.ticket = [result objectForKey:@"ticket"];

	[super processResult:result];
}

- (NSURL *)authenticationURL {
	if (!self.ticket) {
		return nil;
	}

	return [NSURL URLWithString:[BoxRESTApiFactory authenticationUrlStringForTicket:self.ticket]];
}

@end
