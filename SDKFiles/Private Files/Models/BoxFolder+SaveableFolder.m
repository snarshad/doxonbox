
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

#import "BoxFolder+SaveableFolder.h"

#define BOX_FOLDER_MODEL_SAVED_INFORMATION @"/Documents/BoxUserSavedInformation.plist"

@implementation BoxFolder (SaveableFolder)


- (BOOL)saveAsCurrentFolder {
	NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:
						  self.objectName, @"objectName", 
						  self.objectId, @"objectId",
						  @"1", @"isValid",
						  nil];
	
	NSString *savedFile = [NSHomeDirectory() stringByAppendingPathComponent:BOX_FOLDER_MODEL_SAVED_INFORMATION];
	
	NSString *pList = [dict description];
	[dict release];
	
	NSError *error = nil;
	BOOL r = [pList writeToFile:savedFile atomically:YES encoding:NSUTF8StringEncoding error:&error];
	
	if (error) {
		NSLog(@"Error: %@ -- %@",
			  [error localizedDescription],
			  [error localizedFailureReason]);
	}

	if (r) {
		NSLog(@"Info saved to: %@", savedFile);
	} else {
		NSLog(@"Failed to saved info to: %@", savedFile);
	}

	return r;
}

+ (BoxFolder *)savedFolder {
	NSString *savedFile = [NSHomeDirectory() stringByAppendingPathComponent:BOX_FOLDER_MODEL_SAVED_INFORMATION];
	NSError *err;
	NSString *pList = [NSString stringWithContentsOfFile:savedFile
												encoding:NSUTF8StringEncoding
												   error:&err];
	NSDictionary *dict = [pList propertyList];
	
	BoxFolder *folderModel = [[[BoxFolder alloc] init] autorelease];
	
	BOOL isValid;
	
	if (dict) {
		folderModel.objectName = [dict objectForKey:@"objectName"];
		folderModel.objectId = (NSString *)[dict objectForKey:@"objectId"];
		isValid = [((NSString *)[dict objectForKey:@"isValid"]) boolValue];
	} else {
		return nil;
	}
	
	if (!isValid) {
		return nil;
	}

	return folderModel;
}

+ (BOOL)clearSavedFolder {
	NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:
						  @"", @"objectName", 
						  @"", @"objectId",
						  @"0", @"isValid",
						  nil];
	
	NSString *savedFile = [NSHomeDirectory() stringByAppendingPathComponent: BOX_FOLDER_MODEL_SAVED_INFORMATION];
	
	NSString *pList = [dict description];
	[dict release];
	
	NSError *error = nil;
	BOOL r = [pList writeToFile:savedFile atomically:YES encoding:NSUTF8StringEncoding error:&error];
	
	if (error) {
		NSLog(@"Error: %@ -- %@",
			  [error localizedDescription],
			  [error localizedFailureReason]);
	}

	if (r) {
		NSLog(@"Clear Success");
	} else {
		NSLog(@"Clear Failure");
	}

	return r;
}

@end
