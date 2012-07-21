
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

#import "BoxHTTPRequestBuilders.h"


@implementation BoxHTTPRequestBuilders

+ (NSData *)postBodyDataChunkForStringBoundary:(NSString *)stringBoundary
									 valueName:(NSString *)name
										  data:(NSData *)data
{
	NSMutableData *dataChunk = [[[NSMutableData alloc] init] autorelease];
	[dataChunk appendData:[[NSString stringWithFormat:@"--%@\r\n",stringBoundary]
						   dataUsingEncoding:NSUTF8StringEncoding]];
	[dataChunk appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n", name]
						   dataUsingEncoding:NSUTF8StringEncoding]];
	[dataChunk appendData:[[NSString stringWithFormat:@"\r\n"]
						   dataUsingEncoding:NSUTF8StringEncoding]];
	[dataChunk appendData:data];
	[dataChunk appendData:[[NSString stringWithFormat:@"\r\n"]
						   dataUsingEncoding:NSUTF8StringEncoding]];

	return dataChunk;
}

+ (NSURLRequest *)uploadRequestWithUser:(BoxUser *)userModel
						 targetFolderId:(NSString *)targetFolderId
								   data:(NSData *)data
							   filename:(NSString *)filename
							contentType:(NSString *)dataContentType
							  URLString:(NSString *)urlString
							shouldShare:(BOOL)shouldShare
								message:(NSString *)message
								 emails:(NSArray *)emails
{
	NSURL *upUrl = [NSURL URLWithString:urlString];
	NSMutableURLRequest *postRequest = [NSMutableURLRequest requestWithURL:upUrl];

	//adding header information
	[postRequest setHTTPMethod:@"POST"];

	NSString *stringBoundary = @"0xKhTmLbOuNdArY";
	NSString *contentType = [NSString stringWithFormat:@"multipart/form-data;boundary=%@", stringBoundary];
	[postRequest addValue:contentType forHTTPHeaderField:@"Content-Type"];

	//setting up the body
	NSMutableData *postBody = [NSMutableData data];
	
	if (shouldShare) {
		[postBody appendData:[self postBodyDataChunkForStringBoundary:stringBoundary
															valueName:@"share"
																 data:[@"1" dataUsingEncoding:NSUTF8StringEncoding]]];
		[postBody appendData:[self postBodyDataChunkForStringBoundary:stringBoundary
															valueName:@"message"
																 data:[message dataUsingEncoding:NSUTF8StringEncoding]]];

		for (NSString *email in emails) {
			[postBody appendData:[self postBodyDataChunkForStringBoundary:stringBoundary
																valueName:@"emails[]"
																	 data:[email dataUsingEncoding:NSUTF8StringEncoding]]];
		}
	}

	[postBody appendData:[[NSString stringWithFormat:@"--%@\r\n", stringBoundary]
						  dataUsingEncoding:NSUTF8StringEncoding]];

	[postBody appendData:[[NSString stringWithFormat:@"Content-Disposition:form-data;name=\"file_name\";filename=\"%@\"\r\n", filename]
						   dataUsingEncoding:NSUTF8StringEncoding]];

	[postBody appendData:[[NSString stringWithFormat:@"Content-type:%@\r\n\r\n", dataContentType]
						  dataUsingEncoding:NSUTF8StringEncoding]];
	[postBody appendData:data];
	[postBody appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n", stringBoundary]
						  dataUsingEncoding: NSUTF8StringEncoding]];

	[postRequest setHTTPBody: postBody];

	return postRequest;
}

+ (NSURLRequest *)uploadRequestForUser:(BoxUser *)userModel
						targetFolderId:(NSString *)targetFolderId
								  data:(NSData *)data
							  filename:(NSString *)filename
						   contentType:(NSString *)dataContentType
{
	NSString *urlString = [BoxRESTApiFactory getUploadUrlString:userModel.authToken
													boxFolderID:targetFolderId];

	return [self uploadRequestWithUser:userModel
					   targetFolderId:targetFolderId
								 data:data
							 filename:filename
						  contentType:dataContentType
							URLString:urlString
						  shouldShare:NO
							  message:nil
							   emails:nil];
}

+ (NSURLRequest *)advancedUploadRequestForUser:(BoxUser *)userModel
								targetFolderId:(NSString *)targetFolderId
										  data:(NSData *)data
									  filename:(NSString *)filename
								   contentType:(NSString *)dataContentType
								   shouldshare:(BOOL)shouldShare
									   message:(NSString *)message
										emails:(NSArray *)emails
{
	NSString *urlString = [BoxRESTApiFactory getUploadUrlString:userModel.authToken
													boxFolderID:targetFolderId];
	return [self uploadRequestWithUser:userModel
					   targetFolderId:targetFolderId
								 data:data
							 filename:filename
						  contentType:dataContentType
							URLString:urlString
						  shouldShare:shouldShare
							  message:message
							   emails:emails];
}


+ (BoxUploadResponseType)advancedUploadForUser:(BoxUser *)userModel
								targetFolderId:(NSString *)targetFolderId
										  data:(NSData *)data
									  filename:(NSString *)filename
								   contentType:(NSString *)dataContentType
								   shouldshare:(BOOL)shouldShare
									   message:(NSString *)message
										emails:(NSArray *)emails
{
	NSURLRequest *uploadRequest = [BoxHTTPRequestBuilders advancedUploadRequestForUser:userModel
																		targetFolderId:targetFolderId
																				  data:data
																			  filename:filename
																		   contentType:dataContentType
																		   shouldshare:shouldShare
																			   message:message
																				emails:emails];

	NSHTTPURLResponse *theResponse = nil;
	NSError *theError = nil;
	NSString *ret = nil;

	NSData *theResponseData = [NSURLConnection sendSynchronousRequest:uploadRequest 
													returningResponse:&theResponse 
																error:&theError];
	ret = [[[NSString alloc] initWithData:theResponseData encoding:NSUTF8StringEncoding] autorelease];

	if (theResponseData == nil || [theResponse statusCode] != 200) {
		return boxUploadResponseTypeLoginFailed;
	} else if ([ret rangeOfString:@"access_denied"].location != NSNotFound) {
		return boxUploadResponseTypePreviewOnlyPermissions;
	} else {
		return boxUploadResponseTypeUploadSuccessful;
	}
}

@end
