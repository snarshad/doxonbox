
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
#import "BoxHTTPRequestBuilders.h"

#define BoxOperationErrorDomain @"net.box.operationError"

#define BoxOperationErrorRecoveryUI @"net.box.operationError.recoveryUI"
#define BoxOperationErrorRecoveryAction @"net.box.operationError.recoveryAction"

#define BoxOperationErrorRecoverySelectFolderUI @"net.box.operationError.recoveryUI.selectFolder"
#define BoxOperationErrorRecoveryRenameToUI @"net.box.operationError.recoveryUI.renameTo"
#define BoxOperationErrorRecoveryRenameToAction @"net.box.operationError.recoveryAction.renameTo"
#define BoxOperationErrorRecoveryRootFilesAction @"net.box.operationError.recoveryAction.rootFiles"

#define BoxOperationErrorRecoveryCurrentItemName @"net.box.operationError.currentItemName"
#define BoxOperationErrorRecoveryCurrentItemNames @"net.box.operationError.currentItemNames"
#define BoxOperationErrorRecoveryCurrentItemPath @"net.box.operationError.currentItemPath"
#define BoxOperationErrorRecoveryRootPath @"net.box.operationError.rootPath"

#define BoxOperationErrorRecoveryAvailableDestinationFolderNames @"net.box.operationError.availableDestinationFolderNames"
#define BoxOperationErrorRecoveryDefaultValue @"net.box.operationError.defaultValue"


typedef enum _BoxOperationType {
	BoxOperationTypeUpload = 1,
	BoxOperationTypeDownload,
	BoxOperationTypeCreateFolder,
	BoxOperationTypeMove,
	BoxOperationTypeRename,
	BoxOperationTypeToggleSync,
	BoxOperationTypeDelete,
	BoxOperationTypeLogout,
	BoxOperationTypeLogin,
	BoxOperationTypeMakeUpdate,
	BoxOperationTypeFileInfoUpdate,
	BoxOperationTypeFolderUpdate,
	BoxOperationTypeGetTicket,
	BoxOperationTypeGetAuthToken,
	BoxOperationTypeGetComments,
	BoxOperationTypeAddComment,
	BoxOperationTypeDeleteComment,
	BoxOperationTypePublicShare,
	BoxOperationTypePublicUnshare,
	BoxOperationTypePrivateShare,
	BoxOperationTypeGetUpdates,
	BoxOperationSimpleHTTPRequest
} BoxOperationType;

typedef enum _BoxOperationResponse {
	BoxOperationResponseNone = 0,
	BoxOperationResponseSuccessful = 1,
	BoxOperationResponseNotLoggedIn = 2,
	BoxOperationResponseWrongPermissions,
	BoxOperationResponseInvalidName,
	BoxOperationResponseAlreadyRegistered,
	BoxOperationResponseDiskError,
	BoxOperationResponseProtectedWriteError,
	BoxOperationResponseUnknownFolderID,
	BoxOperationResponseUserCancelled,
	BoxOperationResponseSyncStateAlreadySet,
	BoxOperationResponseInternalAPIError,
	BoxOperationResponseUnknownError = 100
} BoxOperationResponse;

@class BoxOperation;

@protocol BoxOperationDelegate <NSObject>
@optional
- (void)operationQueueWillBegin;
- (void)operationQueueDidComplete;

- (void)operation:(BoxOperation *)op willBeginForPath:(NSString *)path;
- (void)operation:(BoxOperation *)op didProgressForPath:(NSString *)path completionRatio:(NSNumber *)ratio;
- (void)operation:(BoxOperation *)op didCompleteForPath:(NSString *)path response:(BoxOperationResponse)response;

@end


@interface BoxOperation : NSOperation {
	id _response;
	id <BoxOperationDelegate> _delegate;
	
	BoxOperationType _operationType;
	BoxOperationResponse _operationResponse;
	NSError *_error;
	
	NSString *_summary;
}

@property (nonatomic, readwrite, retain) id response;
@property (nonatomic, readwrite, retain) NSError *error;
@property (nonatomic, readwrite, retain) NSString *summary;
@property (nonatomic, readwrite, assign) id <BoxOperationDelegate> delegate;
@property (nonatomic, readwrite, assign) BoxOperationType operationType;
@property (nonatomic, readwrite, assign) BoxOperationResponse operationResponse;

//for sdk finish callbacks
@property (copy) void (^completionHandler) (BoxOperation *op, BoxOperationResponse response);

- (id)initForType:(BoxOperationType)type delegate:(id <BoxOperationDelegate>)delegate;
- (void)setResponseType:(BoxOperationResponse)responseType;
- (void)setResponseType:(BoxOperationResponse)responseType message:(NSString *)msg;
- (NSString *)messageForResponseType:(BoxOperationResponse)responseType;

@end
