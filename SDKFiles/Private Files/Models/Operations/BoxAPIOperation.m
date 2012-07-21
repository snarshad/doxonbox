
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

#import "BoxAPIOperation.h"
#import "NSDictionaryXMLParser.h"


@implementation BoxAPIOperation
@synthesize successCode = _successCode, destPath;

- (void)dealloc {
	[_successCode release];
    _successCode = nil;
	[destPath release];
    destPath = nil;
	
	[super dealloc];
}

- (void)requestDidCompleteWithResponse:(NSHTTPURLResponse *)response {
	if (_receivedData != nil && [response statusCode] == 200) {
		NSDictionary *result = [NSDictionaryXMLParser dictionaryWithXML:_receivedData
														   selectedKeys:[self resultKeysOfInterest]
																  error:&_error];
		
		if (!self.error) {
			[self processResult:result];
		}
	}
	
	[super requestDidCompleteWithResponse:response];
}

- (NSArray *)resultKeysOfInterest {
	return [NSArray arrayWithObjects:@"status", nil];
}

- (void)processResult:(NSDictionary *)result {
	NSString *status = [result valueForKey:@"status"];
	if (status) {
		[self processStatusCode:status];
	}
}

- (void)processStatusCode:(NSString *)status {
	if ([status isEqualToString:self.successCode]) {
		[self setResponseType:BoxOperationResponseSuccessful];
		return;
	} else if ([status isEqualToString:@"not_logged_in"]) {
		[self setResponseType:BoxOperationResponseNotLoggedIn];
	} else if ([status isEqualToString:@"application_restricted"]) {
		[self setResponseType:BoxOperationResponseWrongPermissions];
	} else if ([status isEqualToString:@"wrong auth token"]) {
		[self setResponseType:BoxOperationResponseNotLoggedIn];
	} else {
		[self processErrorCode:status];
	}
}
					
- (void)processErrorCode:(NSString *)status {
	[self setResponseType:BoxOperationResponseUnknownError 
				  message:[NSString stringWithFormat:@"API Operation received unknown error code: %@. Please contact Box.com support.", status]];
}	

@end
