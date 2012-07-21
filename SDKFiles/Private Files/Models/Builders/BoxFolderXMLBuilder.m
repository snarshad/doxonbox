
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

#import "BoxFolderXMLBuilder.h"


@implementation BoxFolderXMLBuilder

static NSMutableString *contentHolder;
static NSMutableString *status;
static NSIndexPath *basePath;

static BOOL inCollaborationTag;
static BOOL inInnerFolderTag;
static BOOL inOuterFolderTag;

static BoxFolder *curModel;

static NSLock *parserLock = nil; // necessary so that the statics don't trample each other from different threads. Fix later if we want XML parsing & DL to be parallel (doesn't makes sense for iphone though). We should go to JSON though... Really.

- (id)init {
	if (self = [super init]) {
        
    }
    
    inCollaborationTag = NO;
    inInnerFolderTag = NO;
	inOuterFolderTag = NO;
    
	return self;
}

- (void)parseDidStartDocument:(NSXMLParser *)parser {
}

- (BOOL)parseXMLWithUrlLocal:(NSURL *)xmlUrl
				rootFolderId:(NSString *)rootId
				  parseError:(NSError **)error
				 folderModel:(BoxFolder *)folder
			   basePathOrNil:(NSIndexPath *)path
{
	curModel = folder;
	basePath = path;
    
	if (!basePath) {
		basePath = [NSIndexPath indexPathWithIndex:0];
	}
    
	if (!curModel) {
		assert(NO);
        return NO;
	}
    
    NSData * dataXml = [[[NSData alloc] initWithContentsOfURL:xmlUrl] autorelease];
    NSXMLParser *parser = [[[NSXMLParser alloc] initWithData:dataXml] autorelease];
    
    [parser setDelegate:self];
    [parser setShouldProcessNamespaces:NO];
    [parser setShouldReportNamespacePrefixes: NO];
    [parser setShouldResolveExternalEntities: NO];
    
    if ([parser parse] == NO)
    {
        if (*error){
            *error = [parser parserError];
        } else {
            *error = [[parser parserError] copy];
        }
        
        return NO;
    }
    
    return YES;
}

/*
 * This function can be used to populate a folder in-place.
 * i.e. if you have a folder that only has header information, you can use this function to fully populate the subdirectories in that folder by passing in
 * the BoxUser, rootID (of that model) and the necessary error codes.
 */

+ (BoxFolderDownloadResponseType)parseXMLWithUrl:(NSURL *)xmlUrl
									rootFolderId:(NSString *)rootId
									  parseError:(NSError **)error
                                     folderModel:(BoxFolder *)folder
                                   basePathOrNil:(NSIndexPath *)path
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    if (!parserLock) {
        parserLock = [[NSLock alloc] init];
    }
    
    [parserLock lock];
    
    status = nil;
    
    BoxFolderXMLBuilder *reader = [[BoxFolderXMLBuilder alloc] init];
    folder.objectId = rootId;
    
    [reader parseXMLWithUrlLocal:xmlUrl
                    rootFolderId:rootId
                      parseError:error
                     folderModel:folder
                   basePathOrNil:path];
    [reader release];
    
    NSString * statusCopy;
    if (status != nil) {
        statusCopy = [[status copy] autorelease];
    } else {
        statusCopy = nil;
    }
    
    [parserLock unlock];
    
    if(statusCopy && [statusCopy isEqualToString:@"listing_ok"]) {
        [pool drain];
        return boxFolderDownloadResponseTypeFolderSuccessfullyRetrieved;
    } else if(statusCopy && [statusCopy isEqualToString:@"not_logged_in"]) {
        [pool drain];
        return boxFolderDownloadResponseTypeFolderNotLoggedIn;
    } else {
        [pool drain];
        return boxFolderDownloadResponseTypeFolderFetchError;
    }
}

+ (BoxFolder *)folderForId:(NSString *)rootId
					 token:(NSString *)token
		   responsePointer:(BoxFolderDownloadResponseType *)response
			 basePathOrNil:(NSIndexPath *)path
{
	NSString *url = [BoxRESTApiFactory getAccountTreeOneLevelUrlString:token
														   boxFolderId:rootId];
	BoxFolder *model = [[[BoxFolder alloc] init] autorelease];
	NSError *err;
	
	*response = [BoxFolderXMLBuilder parseXMLWithUrl:[NSURL URLWithString:url]
										rootFolderId:rootId
										  parseError:&err
										 folderModel:model
									   basePathOrNil:path];
    
	return model;
}

- (int)folderCount {
	return [curModel.objectsInFolder count];
}

- (NSMutableArray *)folderList {
    return curModel.objectsInFolder;
}

- (void)parser:(NSXMLParser *)parser
didStartElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI
 qualifiedName:(NSString *)qName
	attributes:(NSDictionary *)attributeDict
{
	if (qName) {
		elementName = qName;
	}
    
	if ([elementName isEqualToString:@"collaboration"]) {
        inCollaborationTag = YES;
        if (inInnerFolderTag) {
			((BoxFolder *)[curModel.objectsInFolder lastObject]).isCollaborated = YES;
        }
    } else if ([elementName isEqualToString: @"status"] && !inCollaborationTag) {
		contentHolder = [NSMutableString string ];
	} else if ([elementName isEqualToString: @"file"]){
		BoxFile *info = [[[BoxFile alloc] initWithDictionary:attributeDict] autorelease];
		[curModel.objectsInFolder addObject:info];
	} else if ([elementName isEqualToString: @"folder"]){
		if(inOuterFolderTag == YES) {
			inInnerFolderTag = YES;
		} else {
			inOuterFolderTag = YES;
		}
		NSString *thisId = [attributeDict objectForKey: @"id"];
		bool isRoot = FALSE;
		
		if (thisId) {
			int idLen = [thisId length];
			if (idLen > 0) {
				if ([thisId isEqualToString: curModel.objectId]) {
                    isRoot =TRUE;
				}
			}
		}
        
		if (isRoot) {
			[curModel setValuesWithDictionary:attributeDict]; // we do this for the root, otherwise it would be unnecessary.
		} else {
			BoxFolder *folder = [[BoxFolder alloc] initWithDictionary:attributeDict];
			[curModel.objectsInFolder addObject:folder];
			[folder release];
		}
	} else if ([elementName isEqual: @"collaboration"]) {
        inCollaborationTag = NO;
    } else {
		contentHolder = nil;
	}
}

- (void)parser:(NSXMLParser *)parser
 didEndElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI
 qualifiedName:(NSString *)qName
{
	if (qName) {
		elementName = qName;
	}
    
	if ([elementName isEqualToString: @"status"] && !inCollaborationTag) {
		status = [[contentHolder copy] autorelease];
	} else if ([elementName isEqualToString:@"folder"]) {
		if(inInnerFolderTag) {
			inInnerFolderTag = NO;
		} else {
			inOuterFolderTag = NO;
		}
    }
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)xString {
	if (contentHolder) {
		[contentHolder appendString: xString];
	}
}

@end
