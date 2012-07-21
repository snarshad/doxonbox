
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

#import "BoxDeleteOperation.h"
#import "BoxLoginViewController.h"


@interface BoxDeleteOperation()

- (id)initForTargetId:(NSString *)targetID
		   targetType:(NSString *)targetType
			authToken:(NSString *)authToken
			 delegate:(id <BoxOperationDelegate>)delegate;

@end

@implementation BoxDeleteOperation

@synthesize authToken = _authToken;
@synthesize targetType = _targetType;
@synthesize targetID = _targetID;

+ (BoxDeleteOperation *)operationForTargetId:(NSString *)targetID
								  targetType:(NSString *)targetType
{
	BoxDeleteOperation *operation = [[BoxDeleteOperation alloc] initForTargetId:targetID 
																	 targetType:targetType 
																	  authToken:[BoxLoginViewController currentUser].authToken
                                                                       delegate:nil];

	return [operation autorelease];
}

- (id)initForTargetId:(NSString *)targetID
		   targetType:(NSString *)targetType
			authToken:(NSString *)authToken
			 delegate:(id <BoxOperationDelegate>)delegate
{
	if ((self = [super initForType:BoxOperationTypeDelete delegate:delegate])) {
		self.targetID = targetID;
		self.targetType = targetType;
		self.authToken = authToken;
	}

	return self;
}

- (NSURL *)url {
	return [NSURL URLWithString:[BoxRESTApiFactory deleteUrlStringForAuthToken:self.authToken
																	targetType:self.targetType
																	  targetId:self.targetID]];
}

- (NSString *)successCode {
	return @"s_delete_node";
}

- (void)processErrorCode:(NSString *)status {
	if ([status isEqualToString:@"e_filename_in_use"]) {
		self.error = [NSError errorWithDomain:BoxOperationErrorDomain
										 code:BoxOperationResponseInvalidName
									 userInfo:[NSDictionary dictionary]];
		[self setResponseType:BoxOperationResponseInvalidName];
	} else {
		[super processErrorCode:status];
	}
}

- (void)dealloc {
    [_authToken release];
    _authToken = nil;
    [_targetType release];
    _targetType = nil;
    [_targetID release];
    _targetID = nil;
    
    [super dealloc];
}

@end
