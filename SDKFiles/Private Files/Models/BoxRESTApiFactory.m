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


#import "BoxRESTApiFactory.h" 
#import "BoxAPIKey.h"


@implementation BoxRESTApiFactory

+ (NSString *)getAuthTokenUrlString:(NSString *)userName userPassword:(NSString *)userPassword {
	NSString *password = [BoxModelUtilityFunctions urlEncodeParameter:userPassword];
	NSString *user = [BoxModelUtilityFunctions urlEncodeParameter:userName];
	NSString *urlString =  [NSString stringWithFormat:
							@"https://www.box.net/api/1.0/rest?action=authorization&api_key=%@&login=%@&password=%@&method",
							BOX_API_KEY,
							user,
							password];
    
	return urlString;
}

+ (NSString *)getAccountTreeOneLevelUrlString:(NSString *)token boxFolderId:(NSString *)folderID {
	NSString *urlString = [NSString stringWithFormat:
						   @"https://www.box.net/api/1.0/rest?action=get_account_tree&api_key=%@&auth_token=%@&folder_id=%@&params[]=nozip&params[]=onelevel&params[]=has_collaborators&params[]=checksum",
						   BOX_API_KEY,
						   token,
						   folderID];
    
	return urlString;
}

+ (NSString *)getAccountTreeOneLevelUrlStringFoldersOnly:(NSString *)token boxFolderId:(NSString *)folderID {
	NSString *urlString = [NSString stringWithFormat:
						   @"https://www.box.net/api/1.0/rest?action=get_account_tree&api_key=%@&auth_token=%@&folder_id=%@&params[]=nozip&params[]=onelevel&params[]=has_collaborators&params[]=checksum&params[]=nofiles",
						   BOX_API_KEY,
						   token,
						   folderID];
    
	return urlString;
}

+ (NSString *)getLogoutUrlString:(NSString *)boxAuthToken {
	NSString *urlString = [NSString stringWithFormat: 
						   @"https://www.box.net/api/1.0/rest?action=logout&api_key=%@&auth_token=%@",
						   BOX_API_KEY,
						   boxAuthToken];
    
	return urlString;
}

+ (NSString *)getUploadUrlString:(NSString *)boxAuthToken boxFolderID:(NSString *)boxFolderID {
	NSString *urlString = [NSString stringWithFormat:
						   @"https://upload.box.net/api/1.0/upload/%@/%@",
						   boxAuthToken,
						   boxFolderID];
    
	return urlString;
}

+ (NSString *)getDownloadUrlString:(NSString *)boxAuthToken
						 boxFileID:(NSString *)boxFileID
{
	return [NSString stringWithFormat:
			@"https://www.box.net/api/1.0/download/%@/%@",
			boxAuthToken,
			boxFileID];
}

+ (NSString *)getFolderFileShareUrlString:(NSString *)boxToken
                                boxTarget:(NSString *)target
                              boxTargetId:(NSString *)targetId
						 boxSharePassword:(NSString *)sharePassword
                               boxMessage:(NSString *)shareMessage
								boxEmails:(NSArray *)shareEmails
{
	if (shareMessage == nil) {
		shareMessage = @"";
	}
    
	NSString *encodedString = [BoxModelUtilityFunctions urlEncodeParameter:shareMessage];
	NSString *urlString =  [NSString stringWithFormat:
							@"https://www.box.net/api/1.0/rest?action=public_share&api_key=%@&auth_token=%@&target=%@&target_id=%@&password=%@&message=%@",
							BOX_API_KEY,
							boxToken,
							target,
							targetId,
							sharePassword,
							encodedString];
    
	if (shareEmails) {
		for (NSString *str in shareEmails) {
			urlString = [urlString stringByAppendingFormat:
						 @"&emails[]=%@",
						 [str stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding]];
		}
	}
    
	return urlString;
}

+ (NSString *)getBoxRegisterNewAccountUrlString:(NSString *)boxLoginName boxPassword:(NSString *)password {
	NSString *pword = [BoxModelUtilityFunctions urlEncodeParameter:password];
	NSString *user = [BoxModelUtilityFunctions urlEncodeParameter:boxLoginName];
	NSString *urlString =  [NSString stringWithFormat:
							@"https://www.box.net/api/1.0/rest?action=register_new_user&api_key=%@&login=%@&password=%@",
							BOX_API_KEY,
							user,
							pword];
    
	return urlString;
}

+ (NSString *)getTicketUrlString {
	return [NSString stringWithFormat:
			@"https://www.box.net/api/1.0/rest?action=get_ticket&api_key=%@",
			BOX_API_KEY];
}

+ (NSString *)authenticationUrlStringForTicket:(NSString *)ticket {
	return [NSString stringWithFormat:
			@"https://m.box.net/api/1.0/auth/%@",
			ticket];
}

+ (NSString *)getAuthTokenUrlStringForTicket:(NSString *)ticket {
	return [NSString stringWithFormat:
			@"https://www.box.net/api/1.0/rest?action=get_auth_token&api_key=%@&ticket=%@",
			BOX_API_KEY,
			ticket];
}

+ (NSString *)moveURLStringForAuthToken:(NSString *)authToken
							 targetType:(NSString *)targetType
							   targetID:(NSString *)targetID
						  destinationID:(NSString *)destinationID
{
	return [NSString stringWithFormat:
			@"%@/rest?action=move&api_key=%@&auth_token=%@&target=%@&target_id=%@&destination_id=%@",
			@"https://www.box.net/api/1.0",
			BOX_API_KEY,
			authToken,
			targetType,
			targetID,
			destinationID];
}

+ (NSString *)copyUrlStringForAuthToken:(NSString *)authToken
							 targetType:(NSString *)targetType
							   targetId:(NSString *)targetId
						  destinationId:(NSString *)destinationId
{
	return [[NSString alloc] initWithFormat:
			@"https://www.box.net/api/1.0/rest?action=copy&api_key=%@&auth_token=%@&target=%@&target_id=%@&destination_id=%@",
			BOX_API_KEY,
			authToken,
			targetType,
			targetId,
			destinationId];
}

+ (NSString *)deleteUrlStringForAuthToken:(NSString *)authToken
							   targetType:(NSString *)targetType
								 targetId:(NSString *)targetId
{
	return [NSString stringWithFormat:
			@"https://www.box.net/api/1.0/rest?action=delete&api_key=%@&auth_token=%@&target=%@&target_id=%@",
			BOX_API_KEY,
			authToken,
			targetType,
			targetId];
}

+ (NSString *)getCommentsURLStringForAuthToken:(NSString *)authToken
									targetType:(NSString *)targetType
									  targetID:(NSString *)targetID
{
	return [NSString stringWithFormat:
			@"%@/rest?action=get_comments&api_key=%@&auth_token=%@&target=%@&target_id=%@",
			@"https://www.box.net/api/1.0",
			BOX_API_KEY,
			authToken,
			targetType,
			targetID];
}

+ (NSString *)addCommentsURLStringForAuthToken:(NSString *)authToken
									targetType:(NSString *)targetType
									  targetID:(NSString *)targetID
									   message:(NSString *)message
{
	return [NSString stringWithFormat:
			@"%@/rest?action=add_comment&api_key=%@&auth_token=%@&target=%@&target_id=%@&message=%@",
			@"https://www.box.net/api/1.0",
			BOX_API_KEY,
			authToken,
			targetType,
			targetID,
			[BoxModelUtilityFunctions urlEncodeParameter:message]];
}

+ (NSString *)deleteCommentURLStringForAuthToken:(NSString *)authToken
									   commentID:(NSString *)commentID
{
	return [NSString stringWithFormat:
			@"%@/rest?action=delete_comment&api_key=%@&auth_token=%@&target_id=%@",
			@"https://www.box.net/api/1.0",
			BOX_API_KEY,
			authToken,
			commentID];
}

+ (NSString *)publicShareURLStringForAuthToken:(NSString *)authToken
									  targetID:(NSString *)targetID
									targetType:(NSString *)targetType
									  password:(NSString *)password
									   message:(NSString *)message
										emails:(NSArray *)emails
{
	if ([password isEqualToString:@""]) {
        password = nil;
    }
    password = password ? [BoxModelUtilityFunctions urlEncodeParameter:password] : @"";
	message = message ? [BoxModelUtilityFunctions urlEncodeParameter:message] : @"";
	emails = emails ? emails : [NSArray array];
    
	NSString *url = [NSString stringWithFormat:
					 @"%@/rest?action=public_share&api_key=%@&auth_token=%@&target=%@&target_id=%@&password=%@&message=%@",
					 @"https://www.box.net/api/1.0",
					 BOX_API_KEY,
					 authToken,
					 targetType,
					 targetID,
					 password,
					 message];
    
	for (NSString *email in emails) {
		url = [url stringByAppendingFormat:
			   @"&emails[]=%@",
			   [email stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding]];
	}
	return url;
}

+ (NSString *)publicUnshareURLStringForAuthToken:(NSString *)authToken
										targetID:(NSString *)targetID
									  targetType:(NSString *)targetType
{
	return [NSString stringWithFormat:
			@"%@/rest?action=public_unshare&api_key=%@&auth_token=%@&target=%@&target_id=%@",
			@"https://www.box.net/api/1.0",
			BOX_API_KEY,
			authToken,
			targetType,
			targetID];	
}

+ (NSString *)privateShareURLStringForAuthToken:(NSString *)authToken
									   targetID:(NSString *)targetID
									 targetType:(NSString *)targetType
										message:(NSString *)message
										 emails:(NSArray *)emails
										 notify:(BOOL)notify
{
	NSString *url;
    
	message = message ? [BoxModelUtilityFunctions urlEncodeParameter:message] : @"";
	emails = emails ? emails : [NSArray array];
    
	url = [NSString stringWithFormat:
		   @"%@/rest?action=private_share&api_key=%@&auth_token=%@&target=%@&target_id=%@&message=%@&notify=%@",
		   @"https://www.box.net/api/1.0",
		   BOX_API_KEY,
		   authToken,
		   targetType,
		   targetID,
		   message,
		   (notify ? @"true" : @"false")];
    
	for (NSString *email in emails) {
		url = [url stringByAppendingFormat:
			   @"&emails[]=%@",
			   [email stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding]];
	}
    
	return url;
}

+ (NSString *)updatesURLStringSince:(NSDate *)date authToken:(NSString *)authToken {
	NSString *beginTimeStampString = [NSString stringWithFormat:@"%.0f", [date timeIntervalSince1970]];
	NSString *endTimeStampString = [NSString stringWithFormat:@"%.0f", [[NSDate date] timeIntervalSince1970]];
    
	return [NSString stringWithFormat:
			@"%@/rest?action=get_updates&api_key=%@&auth_token=%@&begin_timestamp=%@&end_timestamp=%@&params[]=nozip&params[]=use_attributes&params[]=comment_count&params[]=web_links",
			@"https://www.box.net/api/1.0",
			BOX_API_KEY,
			authToken,
			beginTimeStampString,
			endTimeStampString];
}


+ (NSString *)registerUrlStringForLogin:(NSString *)login password:(NSString *)password {
	return [NSString stringWithFormat:
			@"https://www.box.net/api/1.0/rest?action=register_new_user&api_key=%@&login=%@&password=%@",
			BOX_API_KEY,
			login,
			password];
}

+ (NSString *)createFolderUrlStringForAuthToken:(NSString *)authToken
									   parentId:(NSString *)parentID
										   name:(NSString *)name
										  share:(BOOL)share
{
	NSString *encodedName = [BoxModelUtilityFunctions urlEncodeParameter:name];
	return [NSString stringWithFormat:
			@"https://www.box.net/api/1.0/rest?action=create_folder&api_key=%@&auth_token=%@&parent_id=%@&name=%@&share=%d",
			BOX_API_KEY,
			authToken,
			parentID,
			encodedName,
			share];
}

+ (NSString *)renameUrlStringForAuthToken:(NSString *)authToken
							   targetType:(NSString *)targetType
								 targetID:(NSString *)targetID
								  newName:(NSString *)newName
{
	NSString *encodedName = [BoxModelUtilityFunctions urlEncodeParameter:newName];
	return [NSString stringWithFormat:
			@"https://www.box.net/api/1.0/rest?action=rename&api_key=%@&auth_token=%@&target=%@&target_id=%@&new_name=%@",
			BOX_API_KEY,
			authToken,
			targetType,
			targetID,
			encodedName];
}


@end
