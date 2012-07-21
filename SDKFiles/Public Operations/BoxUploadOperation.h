
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
#import "BoxOperation.h"

@class  BoxUser;

@interface BoxUploadOperation : BoxOperation 

@property (nonatomic, readwrite, retain) BoxUser *user;
@property (nonatomic, readwrite, retain) NSString *folderId;
@property (nonatomic, readwrite, retain) NSData *data;
@property (nonatomic, readwrite, retain) NSString *fileName;
@property (nonatomic, readwrite, retain) NSString *dataContentType;
@property (nonatomic, readwrite, assign) BOOL shouldShare;
@property (nonatomic, readwrite, retain) NSString *message;
@property (nonatomic, readwrite, retain) NSArray *emails;

+ (BoxUploadOperation *)operationForUser:(BoxUser*)user
						  targetFolderId:(NSString*)folderId
									data:(NSData *)data
								fileName:(NSString *)fileName
							 contentType:(NSString *)contentType
							 shouldShare:(BOOL)shouldShare
								 message:(NSString *)message
								  emails:(NSArray *)emails;

@end
