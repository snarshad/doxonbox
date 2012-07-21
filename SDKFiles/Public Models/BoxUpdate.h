
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
#import "BoxObject.h"

typedef enum _BoxUpdateType {
	BoxUpdateTypeSent,
	BoxUpdateTypeDownloaded,
	BoxUpdateTypeCommentedOn,
	BoxUpdateTypeMoved,
	BoxUpdateTypeUpdated,
	BoxUpdateTypeAdded,
	BoxUpdateTypePreviewed,
	BoxUpdateTypeDownloadedAndPreviewed,
	BoxUpdateTypeCopied,
	BoxUpdateTypeLocked,
	BoxUpdateTypeUnlocked,
	BoxUpdateTypeAssignedTask,
	BoxUpdateTypeRespondedToTask
} BoxUpdateTypeOld;

@interface BoxUpdate : NSObject {
	NSNumber *_updateId;
	NSNumber *_userId;
	NSString *_userName;
	NSString *_userEmail;
	NSDate   *_updateUpdatedTime;
	BoxUpdateTypeOld _updateType;
	NSNumber *_folderId;
	NSString *_folderName;
	BOOL _isShared;
	NSString *_shareName;
	NSNumber *_ownerId;
	BOOL _collabAccess;
		
	NSMutableArray *_boxObjects;
}

@property (nonatomic, readwrite, retain) NSNumber *updateId;
@property (nonatomic, readwrite, retain) NSNumber *userId;
@property (nonatomic, readwrite, retain) NSString *userName;
@property (nonatomic, readwrite, retain) NSString *userEmail;
@property (nonatomic, readwrite, retain) NSDate   *updateUpdatedTime;
@property (nonatomic, readwrite, assign) BoxUpdateTypeOld updateType;
@property (nonatomic, readwrite, retain) NSNumber *folderId;
@property (nonatomic, readwrite, retain) NSString *folderName;
@property (nonatomic, readwrite, assign) BOOL isShared;
@property (nonatomic, readwrite, retain) NSString *shareName;
@property (nonatomic, readwrite, retain) NSNumber *ownerId;
@property (nonatomic, readwrite, assign) BOOL	collabAccess;

@property (nonatomic, readwrite, retain) NSMutableArray *boxObjects;

- (id)initWithDictionary:(NSDictionary *)values;
- (void)setAttributesDictionary:(NSDictionary *)attributes;
- (NSMutableDictionary *)attributesDictionary;

- (void)addObjectToUpdate:(BoxObject *)boxObject;


@end
