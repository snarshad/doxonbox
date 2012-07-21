
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

#import "BoxCopyOperation.h"
#import "BoxRESTApiFactory.h"

@implementation BoxCopyOperation

@synthesize authToken = _authToken;
@synthesize targetType = _targetType;
@synthesize targetID = _targetId;
@synthesize destinationID = _destinationID;

+ (BoxCopyOperation *)operationForTargetId:(NSString *)targetID
								targetType:(NSString *)targetType
							 destinationId:(NSString *)destinationID
								 authToken:(NSString *)authToken
								  delegate:(id<BoxOperationDelegate>)delegate
{
	return [[[BoxCopyOperation alloc] initForTargetId:targetID
										   targetType:targetType
										destinationId:destinationID
											authToken:authToken
											 delegate:delegate] autorelease];
}

- (id)initForTargetId:(NSString *)targetID
		   targetType:(NSString *)targetType
		destinationId:(NSString *)destinationID
			authToken:(NSString *)authToken
			 delegate:(id <BoxOperationDelegate>)delegate
{
	if ((self = [super initForType:BoxOperationTypeMove delegate:delegate])) {
		self.targetID = targetID;
		self.targetType = targetType;
		self.destinationID = destinationID;
		self.authToken = authToken;
	}

	return self;
}

- (NSURL *)url {
    
    NSString *link = [[BoxRESTApiFactory copyUrlStringForAuthToken:self.authToken 
                                                       targetType:self.targetType 
                                                         targetId:self.targetID 
                                                     destinationId:self.destinationID] autorelease];
	return [NSURL URLWithString:link];
}

- (NSString *)successCode {
	return @"s_delete_node";
}

- (void)dealloc {
    [_authToken release];
    _authToken = nil;
    [_targetType release];
    _targetType = nil;
    [_targetID release];
    _targetID = nil;
    [_destinationID release];
    _destinationID = nil;
    
    [super dealloc];
}

@end
