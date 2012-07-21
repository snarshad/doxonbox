
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

#import <Foundation/Foundation.h>

#import "BoxAPIOperation.h"

@interface BoxCopyOperation : BoxAPIOperation {
	NSString *_authToken;
	NSString *_targetType;
	NSString *_targetID;
	NSString *_destinationID;
}

@property (nonatomic, readwrite, retain) NSString *authToken;
@property (nonatomic, readwrite, retain) NSString *targetType;
@property (nonatomic, readwrite, retain) NSString *targetID;
@property (nonatomic, readwrite, retain) NSString *destinationID;

+ (BoxCopyOperation *)operationForTargetId:(NSString *)_targetID
								targetType:(NSString *)targetType
							 destinationId:(NSString *)destinationId
								 authToken:(NSString *)authToken
								  delegate:(id <BoxOperationDelegate>)delegate;

- (id)initForTargetId:(NSString *)_targetID
		   targetType:(NSString *)targetType
		destinationId:(NSString *)destinationId
			authToken:(NSString *)authToken
			 delegate:(id <BoxOperationDelegate>)delegate;

@end
