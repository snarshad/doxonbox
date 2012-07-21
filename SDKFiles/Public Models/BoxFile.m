
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

#import "BoxFile.h"


@implementation BoxFile

@synthesize smallThumbnailURL = _smallThumbnailURL;
@synthesize largeThumbnailURL = _largeThumbnailURL;
@synthesize largerThumbnailURL = _largerThumbnailURL;
@synthesize previewThumbnailURL = _previewThumbnailURL;
@synthesize sha1 = _sha1;

- (void)releaseAndNilValues {
	[super releaseAndNilValues];
	
	self.smallThumbnailURL = nil;
	self.largeThumbnailURL = nil;
	self.largerThumbnailURL = nil;
	self.previewThumbnailURL = nil;
    
    [_sha1 release];
    _sha1 = nil;
}

- (void)setValuesWithDictionary:(NSDictionary *)values {
	[super setValuesWithDictionary:values];

	if ([values objectForKey:@"small_thumbnail"]) {
		self.smallThumbnailURL = [values objectForKey:@"small_thumbnail"];
	}
	if ([values objectForKey:@"large_thumbnail"]) {
		self.largeThumbnailURL = [values objectForKey:@"large_thumbnail"];
	}
	if ([values objectForKey:@"larger_thumbnail"]) {
		self.largerThumbnailURL = [values objectForKey:@"larger_thumbnail"];
	}
	if ([values objectForKey:@"preview_thumbnail"]) {
		self.previewThumbnailURL = [values objectForKey:@"preview_thumbnail"];
	}
	if ([values objectForKey:@"sha1"]) {
		self.sha1 = [values objectForKey:@"sha1"];
	}
}

- (NSMutableDictionary *)getValuesInDictionaryForm {
	NSMutableDictionary *dictToReturn = [super getValuesInDictionaryForm];

	if (self.smallThumbnailURL) {
		[dictToReturn setObject:self.smallThumbnailURL forKey:@"small_thumbnail"];
	}
	if (self.largeThumbnailURL) {
		[dictToReturn setObject:self.largeThumbnailURL forKey:@"large_thumbnail"];
	}
	if (self.largerThumbnailURL) {
		[dictToReturn setObject:self.largerThumbnailURL forKey:@"larger_thumbnail"];
	}
	if (self.previewThumbnailURL) {
		[dictToReturn setObject:self.previewThumbnailURL forKey:@"preview_thumbnail"];
	}
	if (self.sha1) {
		[dictToReturn setObject:self.sha1 forKey:@"sha1"];
	}
	return dictToReturn;
}

- (id)init {
	if (self = [super init]) {
		self.smallThumbnailURL = nil;
		self.largeThumbnailURL = nil;
		self.largerThumbnailURL = nil;
		self.previewThumbnailURL = nil;
	}

	return self;
}

- (id)initWithDictionary:(NSDictionary *)values {
	if (self = [super init]) {
		self.smallThumbnailURL = nil;
		self.largeThumbnailURL = nil;
		self.largerThumbnailURL = nil;
		self.previewThumbnailURL = nil;

		[self setValuesWithDictionary:values];
	}

	return self;
}

- (NSString *)objectToString {
	return [NSString stringWithFormat:
			@"File Name: %@, Id: %@, Description: %@, Size: %@, Created Time: %@, Updated Time: %@, Thumbnail URL: %@", 
			self.objectName,
			self.objectId,
			self.objectDescription,
			[BoxModelUtilityFunctions getFileFolderSizeString:self.objectSize],
			[BoxModelUtilityFunctions getFileDateString:self.objectCreatedTime],
			[BoxModelUtilityFunctions getFileDateString:self.objectUpdatedTime],
			self.previewThumbnailURL];
}

- (void)dealloc {
	[self releaseAndNilValues];
	[super dealloc];
}

- (BoxFileModelFileType)getFileType {
	BoxFileModelFileType result;

	if ([ [_objectName uppercaseString] hasSuffix: @"MP3"] ||
		[ [_objectName uppercaseString] hasSuffix: @"MP4"] ||
		[ [_objectName uppercaseString] hasSuffix: @"WAV"] ||
		[ [_objectName uppercaseString] hasSuffix: @"AAC"] ||
		[ [_objectName uppercaseString] hasSuffix: @"MOV"] ||
		[ [_objectName uppercaseString] hasSuffix: @"MPV"] ||
		[ [_objectName uppercaseString] hasSuffix: @"3GP"]) {
		result = BoxFileModelMediaFileType;
	} else if([ [_objectName uppercaseString] hasSuffix: @"WEBDOC"]) {
		result = BoxFileModelWebdocFileType;
	} else {
		result = BoxFileModelGeneralFileType;
	}

	return result;
}

- (NSString *)objectSubtitleDescription {
	if([_objectCreatedTime isEqualToDate:_objectUpdatedTime]) {
		return [NSString stringWithFormat:@"Created %@ | %@",
				[BoxModelUtilityFunctions getFileDateString:_objectCreatedTime],
				[BoxModelUtilityFunctions getFileFolderSizeString:_objectSize]];
	} else {
		return [NSString stringWithFormat:@"Updated %@ | %@",
				[BoxModelUtilityFunctions getFileDateString:_objectUpdatedTime],
				[BoxModelUtilityFunctions getFileFolderSizeString:_objectSize]];
	}
}

- (NSString *)objectSubtitleDescriptionExtended {
	NSString *shared = @"";
	if (self.isShared) {
		shared = @" | Shared";
	}
	
	if ([_objectCreatedTime isEqualToDate:_objectUpdatedTime]) {
		return [NSString stringWithFormat:@"Created %@ | %@%@",
				[BoxModelUtilityFunctions getFileDateString:_objectCreatedTime],
				[BoxModelUtilityFunctions getFileFolderSizeString:_objectSize],
				shared];
	} else {
		return [NSString stringWithFormat:@"Updated %@ | %@%@",
				[BoxModelUtilityFunctions getFileDateString:_objectUpdatedTime],
				[BoxModelUtilityFunctions getFileFolderSizeString:_objectSize],
				shared];
	}
}

@end
