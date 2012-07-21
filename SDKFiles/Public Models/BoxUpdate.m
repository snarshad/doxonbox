
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

#import "BoxUpdate.h"
#import "BoxObject.h"

#define __BoxLongLongNSNumberFromDictionaryString(dictionary,key) ([dictionary objectForKey:key] != nil ? [NSNumber numberWithLongLong:[((NSString*)[dictionary objectForKey:key]) longLongValue]] : nil)
#define __BoxNSDateFromDictionaryString(dictionary,key) ([dictionary objectForKey:key] != nil ?  [NSDate dateWithTimeIntervalSince1970:[[dictionary objectForKey:key] doubleValue]] : nil)

@implementation BoxUpdate

@synthesize updateId = _updateId;
@synthesize userId = _userId;
@synthesize userName = _userName;
@synthesize userEmail = _userEmail;
@synthesize updateUpdatedTime = _updateUpdatedTime;
@synthesize updateType = _updateType;
@synthesize folderId = _folderId;
@synthesize folderName = _folderName;
@synthesize isShared = _isShared;
@synthesize shareName = _shareName;
@synthesize ownerId = _ownerId;
@synthesize collabAccess = _collabAccess;

@synthesize boxObjects = _boxObjects;

+ (NSString *)stringForBoxUpdateType:(BoxUpdateTypeOld)type {
	switch (type) {
		case BoxUpdateTypeSent:
			return @"sent";
		case BoxUpdateTypeDownloaded:
			return @"downloaded";
		case BoxUpdateTypeCommentedOn:
			return @"commented on";
		case BoxUpdateTypeMoved:
			return @"moved";
		case BoxUpdateTypeUpdated:
			return @"updated";
		case BoxUpdateTypeAdded:
			return @"added";
		case BoxUpdateTypePreviewed:
			return @"previewed";
		case BoxUpdateTypeDownloadedAndPreviewed:
			return @"downloaded and previewed";
		case BoxUpdateTypeCopied:
			return @"copied";
		case BoxUpdateTypeLocked:
			return @"locked";
		case BoxUpdateTypeUnlocked:
			return @"unlocked";
		case BoxUpdateTypeAssignedTask:
			return @"assigned task";
		case BoxUpdateTypeRespondedToTask:
			return @"responded to task";
	}

	return nil;
}

+ (BoxUpdateTypeOld)boxUpdateTypeForString:(NSString *)type {
	if ([type isEqualToString:@"sent"]) {
		return BoxUpdateTypeSent;
	} else if([type isEqualToString:@"downloaded"]) {
		return BoxUpdateTypeDownloaded;
	} else if([type isEqualToString:@"commented on"]) {
		return BoxUpdateTypeCommentedOn;
	} else if([type isEqualToString:@"moved"]) {
		return BoxUpdateTypeMoved;
	} else if([type isEqualToString:@"updated"]) {
		return BoxUpdateTypeUpdated;
	} else if([type isEqualToString:@"added"]) {
		return BoxUpdateTypeAdded;
	} else if([type isEqualToString:@"previewed"]) {
		return BoxUpdateTypePreviewed;
	} else if([type isEqualToString:@"downloaded and previewed"]) {
		return BoxUpdateTypeDownloadedAndPreviewed;	
	} else if([type isEqualToString:@"copied"]) {
		return BoxUpdateTypeCopied;
	} else if([type isEqualToString:@"locked"]) {
		return BoxUpdateTypeLocked;
	} else if([type isEqualToString:@"unlocked"]) {
		return BoxUpdateTypeUnlocked;
	} else if([type isEqualToString:@"assigned task"]) {
		return BoxUpdateTypeAssignedTask;
	} else if([type isEqualToString:@"responded to task"]) {
		return BoxUpdateTypeRespondedToTask;
	}

	return -1;
}

- (id)init {
	return [self initWithDictionary:nil];
}

- (id)initWithDictionary:(NSDictionary *)values {
	if (self = [super init]) {
		[self setAttributesDictionary:values];
		self.boxObjects = [[[NSMutableArray alloc] init] autorelease];
	}

	return self;
}

- (void) releaseAndNilValues {
	self.updateId = nil;
	self.userId = nil;
	self.userName = nil;
	self.userEmail = nil;
	self.updateUpdatedTime = nil;
	self.updateType = 0;
	self.folderId = nil;
	self.folderName = nil;
	self.isShared = NO;
	self.shareName = nil;
	self.ownerId = nil;
	self.collabAccess = NO; 
	self.boxObjects = nil;
}

- (void)setAttributesDictionary:(NSDictionary *)values {
	self.updateId = __BoxLongLongNSNumberFromDictionaryString(values, @"update_id");
	self.userId = __BoxLongLongNSNumberFromDictionaryString(values, @"user_id");
	self.userName = [values objectForKey:@"user_name"];
	self.userEmail = [values objectForKey:@"user_email"];
	self.updateUpdatedTime = __BoxNSDateFromDictionaryString(values,@"updated");
	self.updateType = ([values objectForKey:@"update_type"] != nil ? [BoxUpdate boxUpdateTypeForString:(NSString*)[values objectForKey:@"update_type"]] : 0);
	self.folderId = __BoxLongLongNSNumberFromDictionaryString(values,@"folder_id");
	self.folderName = [values objectForKey:@"folder_name"];
	if ([values objectForKey:@"shared"] != nil) {
		self.isShared = ([((NSString *)[values objectForKey:@"shared"]) isEqualToString:@"1"] ? YES : NO);
	}
	self.shareName = [values objectForKey:@"shared_name"];
	self.ownerId = __BoxLongLongNSNumberFromDictionaryString(values,@"owner_id");
	if([values objectForKey:@"collab_access"]) {
		self.collabAccess = ([((NSString *)[values objectForKey:@"collab_access"]) isEqualToString:@"1"] ? YES : NO);
	}
}
- (NSMutableDictionary *)attributesDictionary {
	NSMutableDictionary *returnDict = [[[NSMutableDictionary alloc] initWithCapacity:12] autorelease];

	if (self.updateId) {
		[returnDict setObject:[NSString stringWithFormat:@"%@", self.updateId] forKey:@"update_id"];
	}
	if (self.userId) {
		[returnDict setObject:[NSString stringWithFormat:@"%@", self.userId] forKey:@"user_id"];		
	}
 	if (self.userName) {
		[returnDict setObject:self.userName forKey:@"user_name"];
	}
	if (self.userEmail) {
		[returnDict setObject:self.userEmail forKey:@"user_email"];
	}
	if (self.updateUpdatedTime) {
		[returnDict setObject:[NSString stringWithFormat:@"%f", [self.updateUpdatedTime timeIntervalSince1970]] forKey:@"updated"];
	}
	[returnDict setObject:[BoxUpdate stringForBoxUpdateType:self.updateType] forKey:@"update_type"];
	if (self.folderId) {
		[returnDict setObject:[NSString stringWithFormat:@"%@", self.folderId] forKey:@"folder_id"];
	}
	if (self.folderName) {
		[returnDict setObject:self.folderName forKey:@"folder_name"];
	}
	self.isShared ?	[returnDict setObject:@"1" forKey:@"shared"] : [returnDict setObject:@"0" forKey:@"shared"];
	if (self.shareName) {
		[returnDict setObject:self.shareName forKey:@"share_name"];
	}
	if (self.ownerId) {
		[returnDict setObject:[NSString stringWithFormat:@"%@", self.ownerId] forKey:@"owner_id"];
	}
	self.collabAccess ? [returnDict setObject:@"1" forKey:@"collab_access"] : [returnDict setObject:@"0" forKey:@"collab_access"];

	return returnDict;
}

- (void)addObjectToUpdate:(BoxObject *)boxObject {
	[self.boxObjects addObject:boxObject];
}

- (void)dealloc {
	[self releaseAndNilValues];
	[super dealloc];
}

@end
