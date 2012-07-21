
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

#import "BoxOperation.h"


@interface BoxOperation() {
    void (^__completionHandler) (BoxOperation *op, BoxOperationResponse response);
}

@end

@implementation BoxOperation

@synthesize response = _response;
@synthesize error = _error;
@synthesize delegate = _delegate;
@synthesize operationType = _operationType;
@synthesize operationResponse = _operationResponse;
@synthesize summary = _summary;
@synthesize completionHandler = __completionHandler;

- (id)initForType:(BoxOperationType)type delegate:(id <BoxOperationDelegate>)delegate {
	if (self = [super init]) {
        self.delegate = delegate;
        self.operationType = type;
		self.operationResponse = BoxOperationResponseNone;
		self.summary = @"Performing unknown operation…";
	}

	return self;
}

- (void)setResponseType:(BoxOperationResponse)responseType {
	[self setResponseType:responseType message:nil];
}

- (void)setResponseType:(BoxOperationResponse)responseType message:(NSString *)msg {
	self.operationResponse = responseType;
	if (responseType == BoxOperationResponseUserCancelled) {
		self.error = [NSError errorWithDomain:NSCocoaErrorDomain code:NSUserCancelledError userInfo:nil];
	} else if (responseType != BoxOperationResponseSuccessful) {
		if (!msg) {
			msg = [self messageForResponseType:responseType];
		}

		NSDictionary *userInfo = nil;
		if (msg) {
			userInfo = [NSDictionary dictionaryWithObject:msg forKey:NSLocalizedDescriptionKey];
		}
		self.error = [NSError errorWithDomain:BoxOperationErrorDomain code:(NSInteger)responseType userInfo:userInfo];
	} else {
		self.error = nil;
	}
}

- (NSString *)messageForResponseType:(BoxOperationResponse)responseType {
	switch (responseType) {
		case BoxOperationResponseUnknownFolderID:
			return @"The destination folder does not exist.";
		case BoxOperationResponseNotLoggedIn:
			return @"The Box account was unexpectedly logged out.";
		case BoxOperationResponseWrongPermissions:
			return @"Access denied to the destination folder.";
		case BoxOperationResponseInternalAPIError:
			return @"Box.com servers are currently overloaded. Please try again later.";
		default:
			break;
	}

	return nil;
}

- (void)dealloc {
    self.response = nil;
    self.error = nil;
    _delegate = nil;
    self.summary = nil;
    self.completionHandler = nil;

	[super dealloc];
}

@end
