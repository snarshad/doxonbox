
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

#import "BoxNetworkOperationManager.h"
#import "BoxFolderXMLBuilder.h"


#define BOX_NETWORK_OPERATION_FOLDER_ID @"folderID"
#define BOX_NETWORK_OPERATION_BLOCK @"block"

static BoxNetworkOperationManager * sharedManager = nil;

@interface BoxNetworkOperationManager() <BoxOperationDelegate> {
    NSOperationQueue * __queue;
}

@property (nonatomic, retain) NSOperationQueue * queue;

- (void)getFolder:(NSDictionary*)params; // This method is blocking, so it should be called asynchronously to avoid stalling the UI

@end

@implementation BoxNetworkOperationManager

@synthesize queue = __queue;

#pragma mark - Initialization

+ (BoxNetworkOperationManager*)sharedBoxOperationManager { 
    if (!sharedManager) {
        sharedManager = [[BoxNetworkOperationManager alloc] init];
    }
    return sharedManager;
}

#pragma mark - Object Lifecycle

- (void)dealloc {
    [__queue release];
    __queue = nil;
    [super dealloc];
}

- (NSOperationQueue*)queue {
    if (!__queue) {
        __queue = [[NSOperationQueue alloc] init];
    }
    return __queue;
}

#pragma mark - Public Methods

- (void)sendRequest:(BoxOperation*)networkOperation onCompletetion:(BoxOperationCompletionHandler)block {
    networkOperation.delegate = self;
    networkOperation.completionHandler = block;
    [self.queue addOperation:networkOperation];
}

- (void)getBoxFolderForID:(NSString *)folderID onCompletion:(BoxGetFolderCompletionHandler)block {
    NSDictionary * params = [NSDictionary dictionaryWithObjectsAndKeys:folderID, BOX_NETWORK_OPERATION_FOLDER_ID, Block_copy(block), BOX_NETWORK_OPERATION_BLOCK, nil];
    [NSThread detachNewThreadSelector:@selector(getFolder:) toTarget:self withObject:params];
}

+ (NSString*)humanReadableErrorFromResponse:(BoxOperationResponse)response {
    switch (response) {
        case BoxOperationResponseNone:
        case BoxOperationResponseUnknownError:
            return @"Unknown error.";
        case BoxOperationResponseSuccessful:
            return @"Network operation successful";
        case BoxOperationResponseNotLoggedIn:
            return @"User not logged in.";
        case BoxOperationResponseWrongPermissions:
            return @"User does not have the correct permissions.";
        case BoxOperationResponseInvalidName:
            return @"Invalid name.";
        case BoxOperationResponseAlreadyRegistered:
            return @"User is already registered.";
        case BoxOperationResponseDiskError:
            return @"Disk error.";
        case BoxOperationResponseProtectedWriteError:
            return @"Protected write error";
        case BoxOperationResponseUnknownFolderID:
            return @"Unknown folder ID. Possibly the folder specified no longer exists.";
        case BoxOperationResponseUserCancelled:
            return @"Operation didn't complete because it was canceled by the user.";
        case BoxOperationResponseSyncStateAlreadySet:
            return @"The sync has already completed.";
        case BoxOperationResponseInternalAPIError:
            return @"There was an internal problem with your request.";
        default:
            return @"";
    }
}

#pragma mark - Private Methods

- (void)getFolder:(NSDictionary*)params {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
	BoxUser* userModel = [BoxUser savedUser];
	
	NSString * ticket = userModel.authToken;
	NSString * folderIdToDownload = [params objectForKey:BOX_NETWORK_OPERATION_FOLDER_ID];
	BoxFolderDownloadResponseType responseType = 0;
	BoxFolder * folderModel = [BoxFolderXMLBuilder folderForId:folderIdToDownload token:ticket responsePointer:&responseType basePathOrNil:nil]; //This method is the line which makes getFolder: blocking.
	
    BoxGetFolderCompletionHandler block = [params objectForKey:BOX_NETWORK_OPERATION_BLOCK];
    dispatch_async(dispatch_get_main_queue(), ^{
        block(folderModel, responseType);
        Block_release(block); //now finished with it
    });
    
    [pool drain];
}

#pragma mark - NetworkOperationDelegate Methods

- (void)operation:(BoxOperation *)op didCompleteForPath:(NSString *)path response:(BoxOperationResponse)response {
    dispatch_async(dispatch_get_main_queue(), ^{
        op.completionHandler(op, response);
    });
}

@end
