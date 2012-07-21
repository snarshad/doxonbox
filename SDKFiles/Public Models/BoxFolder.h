
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
#import "BoxModelUtilityFunctions.h"

/*
 * BoxUser subclasses BoxObjectModel and contains a few extra properties and functions to support folder operations.
 * 
 * FolderModels contain an NSArray of BoxObjectModels in the _objectsInFolder property. Folders always come first, then files in this list.
 */

typedef enum _BoxFolderDownloadResponseType {
	boxFolderDownloadResponseTypeFolderSuccessfullyRetrieved = 1,
	boxFolderDownloadResponseTypeFolderNotLoggedIn = 2,
	boxFolderDownloadResponseTypeFolderFetchError = 100 //unknown error
} BoxFolderDownloadResponseType;

@interface BoxFolder : BoxObject {
	NSMutableArray *_objectsInFolder; // Contains objects of type BoxObject
	NSNumber *_fileCount;
	NSMutableArray *_collaborations; // collaborations is not populated automatically by BoxFolderXMLBuilder
	BOOL _isCollaborated;
	int _folderCount;
}

@property (nonatomic, readonly) NSMutableArray *objectsInFolder;
@property (nonatomic, readwrite, retain) NSNumber *fileCount;
@property (nonatomic, readonly) NSMutableArray *collaborations;
@property (nonatomic, readwrite, assign) BOOL isCollaborated;

- (void)addModel:(BoxObject *)model;

- (BoxObject *)getModelAtIndex:(NSNumber *)index;

- (int)numberOfObjectsInFolder;

- (int)getFolderCount;

- (NSMutableDictionary *)getValuesInDictionaryForm;
- (void)setValuesWithDictionary:(NSDictionary *)values;

- (void)releaseAndNilValues;

@end
