
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
#import "BoxUser.h"
#import "BoxRESTApiFactory.h"

typedef enum _UploadResponseType {
	boxUploadResponseTypeUploadSuccessful,
	boxUploadResponseTypeNoConnection,
	boxUploadResponseTypeNotLoggedIn,
	boxUploadResponseTypeLoginFailed,
	boxUploadResponseTypePreviewOnlyPermissions
} BoxUploadResponseType;

@interface BoxHTTPRequestBuilders : NSObject {

}

/*
 * doAdvancedUpload:andTargetFolderId:andData:andFilename:andContentType:andShouldshare:andMessage:andEmails Uploads a file for the 
 * user in userModel
 * with the data in Data
 * the desired filename filename (with extension appended before passing to this file)
 * dataContentType - content type e.g. 'image/gif'
 * whether or not this file should be shared 
 * if it should be shared what the message should be (message can be nil)
 * if it should be shared who to email it to (emails can be nil)
 */
+ (BoxUploadResponseType)advancedUploadForUser:(BoxUser *)userModel
								targetFolderId:(NSString *)targetFolderId
										  data:(NSData *)data
									  filename:(NSString *)filename
								   contentType:(NSString *)dataContentType
								   shouldshare:(BOOL)shouldShare
									   message:(NSString *)message
										emails:(NSArray *)emails;

/*
 * These two functions generate the URL requests, but do not handle the sending of the data or the parsing of the result. You can use them if you
 * want to send data in a different way
 */
+ (NSURLRequest *)uploadRequestForUser:(BoxUser *)userModel
						targetFolderId:(NSString *)targetFolderId
								  data:(NSData *)data
							  filename:(NSString *)filename
						   contentType:(NSString *)dataContentType;

+ (NSURLRequest *)advancedUploadRequestForUser:(BoxUser *)userModel
								targetFolderId:(NSString *)targetFolderId
										  data:(NSData *)data
									  filename:(NSString *)filename
								   contentType:(NSString *)dataContentType
								   shouldshare:(BOOL)shouldShare
									   message:(NSString *)message
										emails:(NSArray *)emails;

@end
