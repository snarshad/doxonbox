
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

#import "BoxMoveOperation.h"
#import "BoxLoginViewController.h"


@interface BoxMoveOperation() {
	NSString *_itemID;
	NSString *_itemType;
	NSString *_destFolderID;
	NSString *_authToken;
}

- (id)initForItemID:(NSString *)itemID
		   itemType:(NSString *)itemType
destinationFolderID:(NSString *)destFolderID
		  authToken:(NSString *)authToken
		   delegate:(id<BoxOperationDelegate>)delegate;

@end

@implementation BoxMoveOperation

@synthesize itemID = _itemID;
@synthesize itemType = _itemType;
@synthesize destFolderID = _destFolderID;
@synthesize authToken = _authToken;

+ (BoxMoveOperation *)operationForItemID:(NSString *)itemID
								itemType:(NSString *)itemType
					 destinationFolderID:(NSString *)destFolderID
{
	return [[[BoxMoveOperation alloc] initForItemID:itemID
										   itemType:itemType
								destinationFolderID:destFolderID
										  authToken:[BoxLoginViewController currentUser].authToken
										   delegate:nil] autorelease];
}

- (id)initForItemID:(NSString *)itemID
		   itemType:(NSString *)itemType
destinationFolderID:(NSString *)destFolderID
		  authToken:(NSString *)authToken
		   delegate:(id<BoxOperationDelegate>)delegate
{
	if (self = [super initForType:BoxOperationTypeMove delegate:delegate]) {
		self.itemID = itemID;
		self.itemType = itemType;
		self.destFolderID = destFolderID;
		self.authToken = authToken;
	}
	
	return self;
}

- (void)dealloc {
	self.itemType = nil;
	self.authToken = nil;
    [_itemID release];
    _itemID = nil;
    [_destFolderID release];
    _destFolderID = nil;

	[super dealloc];
}

- (NSURL *)url {
	return [NSURL URLWithString:[BoxRESTApiFactory moveURLStringForAuthToken:self.authToken
																  targetType:self.itemType
																	targetID:self.itemID
															   destinationID:self.destFolderID]];
}

- (NSString *)successCode {
	return @"s_move_node";
}

@end
