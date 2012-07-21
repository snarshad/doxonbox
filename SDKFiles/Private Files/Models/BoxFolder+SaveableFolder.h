
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

/*
 * BoxUser+SaveableSelectedFolder adds some basic save and retrieval functionality to BoxUser that is specific to the BoxPopup.
 * Because the user selects a particular Folder to upload to, we'd like to save it for the next time they open up the application so they don't
 * need to select that particular folder more than once.
 * 
 * These functions only save the folder ID and folder Name, they do not save any other folder properties.
 *
 * Only one folder can be saved at a time.
 */

#import <Foundation/Foundation.h>
#import "BoxFolder.h"

@interface BoxFolder (SaveableFolder) 

/*
 * saveAsCurrent Folder saves the current folder to phone memory for future retrieval. It only saves out the folder's objectID and the folderName
 */
- (BOOL)saveAsCurrentFolder;

/*
 * retrieveSavedFolder returns a folder with only the folder's objectId and name
 *
 * It returns nil if no folder has ever been saved out or if clearSavedFolder was last called
 */
+ (BoxFolder *)savedFolder;

/*
 * clearSavedFolder clears the saved folder so the next time retrieveSavedFolder is called, it returns nil
 */ 
+ (BOOL)clearSavedFolder;

@end
