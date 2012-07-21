
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

#import <UIKit/UIKit.h>
#import "BoxFolder.h"
#import "BoxFile.h"
#import "BoxRESTApiFactory.h"

#define FOLDER_MODEL @"folderModel"
#define RESPONSE_TYPE @"responseType"
#define ERROR @"error"

@interface BoxFolderXMLBuilder : NSObject <NSXMLParserDelegate> {


}

/*
 * getFolderForId:andToken:andResponsePointer takes a folderId, a token and a pointer to a response type pointing at valid memory
 * and returns a BoxUser containing all of the information for this folder as well as all of the folders and files below it. 
 * (Folders contained in the root folder will have all header information - name, date created, isCollaborated, etc. but they will 
 * not contain a list of their own files and folders).
 *
 * To descend into a folder heirarchy, call this method with a root folder id, select a folder in the now-populated root folder and call
 * this method again with the selected folder's folder Id. 
 *
 */

+ (BoxFolder *)folderForId:(NSString *)rootId
					 token:(NSString *)token
		   responsePointer:(BoxFolderDownloadResponseType *)response
			 basePathOrNil:(NSIndexPath *)path;

@end
