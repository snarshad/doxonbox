
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

@interface BoxPrivateShareOperation : BoxAPIOperation 

@property (nonatomic, readwrite, retain) NSString *targetID;
@property (nonatomic, readwrite, retain) NSString *targetType;
@property (nonatomic, readwrite, retain) NSString *message;
@property (nonatomic, readwrite, retain) NSArray *emails;
@property (nonatomic, readwrite, assign) BOOL notify;
@property (nonatomic, readwrite, retain) NSString *authToken;

+ (BoxPrivateShareOperation *)operationForTargetID:(NSString *)_targetID
										targetType:(NSString *)targetType
										   message:(NSString *)message
											emails:(NSArray *)emails
											notify:(BOOL)notify;

@end
