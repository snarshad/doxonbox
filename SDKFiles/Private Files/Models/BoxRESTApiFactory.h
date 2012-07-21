
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
#import "BoxModelUtilityFunctions.h"

/*
 The BoxRESTApiFactory creates NSString versions of urls given input parameters for many of box's API calls.
 
 see the SideBar on http://developers.box.net/
 
 The API calls require both an API_KEY - see the BoxAPIKey.h file to replace it. You can get this API key from http://developers.box.net/
 
 Many of these API calls also require a token. This token string uniquely identifies a user and an application and never expires. 
 This way you only need to have a user login once.
 
 Please go to BoxAPIKey.h and add your API Key to: 
 static const NSString * BOX_API_KEY = @"<YOUR API KEY HERE>";
 */

@interface BoxRESTApiFactory : NSObject {
	
}

+ (NSString *)getAuthTokenUrlString:(NSString *)userName userPassword:(NSString *)userPassword;
+ (NSString *)getAccountTreeOneLevelUrlString:(NSString *)token boxFolderId:(NSString *)folderID;
+ (NSString *)getAccountTreeOneLevelUrlStringFoldersOnly:(NSString *)token boxFolderId:(NSString *)folderID;
+ (NSString *)getLogoutUrlString:(NSString *)boxAuthToken;
+ (NSString *) getUploadUrlString:(NSString *)boxAuthToken boxFolderID:(NSString *)boxFolderID;
+ (NSString *)getDownloadUrlString:(NSString *)boxAuthToken
						 boxFileID:(NSString *)boxFileID;
/*
 * boxTarget is the type of item to be shared - possible values are "file" or "folder"
 * boxTargetId is the fileId of the item to be shared
 * boxSharePassword is an optional password you can use to protect a publicly shared folder
 * boxMessage is the message to include in emails to people you're sharing with
 * boxEmails is an array of email addresses to include when sending
 */ 

+ (NSString *)getFolderFileShareUrlString:(NSString *)boxToken
								boxTarget:(NSString *)target
							  boxTargetId:(NSString *)targetId
						 boxSharePassword:(NSString *)sharePassword
							   boxMessage:(NSString *)shareMessage
								boxEmails:(NSArray *)shareEmails;

+ (NSString *)getBoxRegisterNewAccountUrlString:(NSString *)boxLoginName boxPassword:(NSString *)password;

+ (NSString *)getTicketUrlString;
+ (NSString *)authenticationUrlStringForTicket:(NSString *)ticket;
+ (NSString *)getAuthTokenUrlStringForTicket:(NSString *)ticket;

+ (NSString *)moveURLStringForAuthToken:(NSString *)authToken
							 targetType:(NSString *)targetType
							   targetID:(NSString *)targetID
						  destinationID:(NSString *)destinationID;
+ (NSString *)copyUrlStringForAuthToken:(NSString *)authToken
							 targetType:(NSString *)targetType
							   targetId:(NSString *)targetId
						  destinationId:(NSString *)destinationId;
+ (NSString *)deleteUrlStringForAuthToken:(NSString *)authToken
							   targetType:(NSString *)targetType
								 targetId:(NSString *)targetId;
+ (NSString *)getCommentsURLStringForAuthToken:(NSString *)authToken
									targetType:(NSString *)targetType
									  targetID:(NSString *)targetID;
+ (NSString *)addCommentsURLStringForAuthToken:(NSString *)authToken
									targetType:(NSString *)targetType
									  targetID:(NSString *)targetID
									   message:(NSString *)message;
+ (NSString *)deleteCommentURLStringForAuthToken:(NSString *)authToken
									   commentID:(NSString *)commentID;

+ (NSString *)publicShareURLStringForAuthToken:(NSString *)authToken
									  targetID:(NSString *)targetID
									targetType:(NSString *)targetType
									  password:(NSString *)password
									   message:(NSString *)message
										emails:(NSArray *)emails;
+ (NSString *)publicUnshareURLStringForAuthToken:(NSString *)authToken
										targetID:(NSString *)targetID
									  targetType:(NSString *)targetType;
+ (NSString *)privateShareURLStringForAuthToken:(NSString *)authToken
									   targetID:(NSString *)targetID
									 targetType:(NSString *)targetType
										message:(NSString *)message
										 emails:(NSArray *)emails
										 notify:(BOOL)notify;

+ (NSString *)updatesURLStringSince:(NSDate *)date authToken:(NSString *)authToken;


+ (NSString *)registerUrlStringForLogin:(NSString *)login password:(NSString *)password;
+ (NSString *)createFolderUrlStringForAuthToken:(NSString *)authToken
									   parentId:(NSString *)parentID
										   name:(NSString *)name
										  share:(BOOL)share;

+ (NSString *)renameUrlStringForAuthToken:(NSString *)authToken
							   targetType:(NSString *)targetType
								 targetID:(NSString *)targetID
								  newName:(NSString *)newName;

@end
