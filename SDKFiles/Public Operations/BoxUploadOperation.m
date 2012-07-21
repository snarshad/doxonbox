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

#import "BoxUploadOperation.h"
#import "BoxHTTPRequestBuilders.h"
#import "BoxLoginViewController.h"


@interface BoxUploadOperation() {
    BoxUser*_user;
	NSString *_folderId;
	NSData *_data;
	NSString *_fileName;
	NSString *_dataContentType;
	BOOL _shouldShare;
	NSString *_message;
	NSArray *_emails;
	
	BOOL _isExecuting;
	BOOL _isFinished;
}

- (id)initForUser:(BoxUser*)user
   targetFolderId:(NSString*)folderId
			 data:(NSData *)data
		 fileName:(NSString *)fileName
	  contentType:(NSString *)contentType
	  shouldShare:(BOOL)shouldShare
		  message:(NSString *)message
		   emails:(NSArray *)emails
		 delegate:(id<BoxOperationDelegate>)delegate;
- (void)finish;

@end

@implementation BoxUploadOperation

@synthesize user = _user;
@synthesize folderId = _folderId;
@synthesize data = _data;
@synthesize fileName = _fileName;
@synthesize dataContentType = _dataContentType;
@synthesize shouldShare = _shouldShare;
@synthesize message = _message;
@synthesize emails = _emails;

+ (BoxUploadOperation *)operationForUser:(BoxUser*)user
						  targetFolderId:(NSString*)folderId
									data:(NSData *)data
								fileName:(NSString *)fileName
							 contentType:(NSString *)contentType
							 shouldShare:(BOOL)shouldShare
								 message:(NSString *)message
								  emails:(NSArray *)emails
{
	return [[[BoxUploadOperation alloc] initForUser:user 
									 targetFolderId:folderId 
											   data:data 
										   fileName:fileName 
										contentType:contentType 
										shouldShare:shouldShare 
											message:message 
											 emails:emails 
										   delegate:nil] autorelease];
}

- (id)initForUser:(BoxUser*)user
   targetFolderId:(NSString*)folderId
			 data:(NSData *)data
		 fileName:(NSString *)fileName
	  contentType:(NSString *)contentType
	  shouldShare:(BOOL)shouldShare
		  message:(NSString *)message
		   emails:(NSArray *)emails
		 delegate:(id<BoxOperationDelegate>)delegate {
	
	if ((self = [super initForType:BoxOperationTypeUpload delegate:delegate])) {
		self.user = user;
		self.folderId = folderId;
		self.data = data;
		self.fileName = fileName;
		self.dataContentType = contentType;
		self.shouldShare = shouldShare;
		self.message = message;
		self.emails = emails;
	}

	return self;
}

- (void)dealloc {
	self.user = nil;
	self.data = nil;
	self.fileName = nil;
	self.dataContentType = nil;
	self.message = nil;
	self.emails = nil;
    [_folderId release];
    _folderId = nil;

	[super dealloc];
}

#pragma mark -
#pragma mark NSOperation methods

- (void)main {
	if (![self isCancelled] && ![[[self dependencies] lastObject] isCancelled]) {
		if ([_delegate respondsToSelector:@selector(operation:willBeginForPath:)]) {
			[_delegate operation:self willBeginForPath:nil];
		}

		BoxUploadResponseType uploadResponse = [BoxHTTPRequestBuilders advancedUploadForUser:self.user
																			  targetFolderId:self.folderId 
																						data:self.data
																					filename:self.fileName
																				 contentType:self.dataContentType
																				 shouldshare:self.shouldShare
																					 message:self.message
																					  emails:self.emails];

		// process the result
		if (uploadResponse == boxUploadResponseTypeUploadSuccessful) {
			self.operationResponse = BoxOperationResponseSuccessful;
		} else if (uploadResponse == boxUploadResponseTypeNoConnection) {
			self.operationResponse = BoxOperationResponseUnknownError;
		} else if (uploadResponse == boxUploadResponseTypeNotLoggedIn ||
				   uploadResponse == boxUploadResponseTypeLoginFailed) {
			self.operationResponse = BoxOperationResponseNotLoggedIn;
		} else if (uploadResponse == boxUploadResponseTypePreviewOnlyPermissions) {
			self.operationResponse = BoxOperationResponseWrongPermissions;
		} else {
			self.operationResponse = BoxOperationResponseUnknownError;
		}

		if ([_delegate respondsToSelector:@selector(operation:didCompleteForPath:response:)]) {
			[_delegate operation:self didCompleteForPath:nil response:self.operationResponse];
		}
	}
	[self finish];
}

- (void)finish {	
	[self willChangeValueForKey:@"isExecuting"];
	_isExecuting = NO;
    [self didChangeValueForKey:@"isExecuting"];

	[self willChangeValueForKey:@"isFinished"];
    _isFinished = YES;
	[self didChangeValueForKey:@"isFinished"];
}

- (BOOL)isConcurrent {
    return YES;
}

- (BOOL)isExecuting {
    return _isExecuting;
}

- (BOOL)isFinished {
    return _isFinished;
}

@end
