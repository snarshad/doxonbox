
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

#import "BoxUpdatesListModelXMLBuilder.h"
#import "BoxRESTApiFactory.h"
#import "BoxUpdate.h"

#import "BoxFolder.h"
#import "BoxFile.h"
#import "BoxComment.h"

#define classTags [NSArray arrayWithObjects:@"folder", @"file", @"discussion", nil]

@implementation BoxUpdatesListModelXMLBuilder

@synthesize contentHolder = _contentHolder;
@synthesize status = _status;

@synthesize currentUpdateAttributes = _currentUpdateParameterDictionary;
@synthesize updatesList = _updatesList;
@synthesize currentUpdate = _currentUpdate;
@synthesize boxObject = _boxObject;

- (void)dealloc {
	self.contentHolder = nil;
	self.status = nil;

	self.currentUpdateAttributes = nil;
	self.updatesList = nil;
	self.currentUpdate = nil;
	self.boxObject = nil;

	[super dealloc];
}

#pragma mark -

- (NSArray *)updatesWithData:(NSData *)xmlData {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
	self.updatesList = [[[NSMutableArray alloc] init] autorelease];
	self.contentHolder = [[[NSMutableString alloc] initWithString:@""] autorelease];

	NSXMLParser *parser = [[NSXMLParser alloc] initWithData:xmlData];
	[parser setDelegate: self];
	[parser setShouldProcessNamespaces:NO];
	[parser setShouldReportNamespacePrefixes: NO];
	[parser setShouldResolveExternalEntities: NO];
	[parser parse];	
	[parser release];
    
    [pool drain];
	
	return self.updatesList;
}

- (void)parser:(NSXMLParser *)parser
didStartElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI
 qualifiedName:(NSString *)qualifiedName
	attributes:(NSDictionary *)attributeDict
{
	if ([elementName isEqualToString:@"update"]) { // outermost tag - create an update object, populate with values and add objectModels to it
		self.currentUpdate = [[[BoxUpdate alloc] init] autorelease];
		self.currentUpdateAttributes = [[[NSMutableDictionary alloc] init] autorelease];
	} else if ([classTags containsObject:elementName]) {
		Class childClass = [BoxObject class]; // default value
		
        if ([elementName isEqualToString:@"folder"]) {
			childClass = [BoxFolder class];
		} else if ([elementName isEqualToString:@"file"]) {
			childClass = [BoxFile class];
		} else if ([elementName isEqualToString:@"discussion"]) {
			childClass = [BoxComment class];
		}
        
		self.boxObject = [[[childClass alloc] init] autorelease];
	}
}

- (void)parser:(NSXMLParser *)parser
 didEndElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI
 qualifiedName:(NSString *)qName
{
	if (self.boxObject) {
		if ([classTags containsObject:elementName]) {
			[self.currentUpdate addObjectToUpdate:self.boxObject];
			self.boxObject = nil;
		} else if ([elementName hasSuffix:@"id"]) {
			self.boxObject.objectId = self.contentHolder;
		} else if ([elementName hasSuffix:@"name"] && ![elementName isEqualToString:@"shared_name"]) {
			self.boxObject.objectName = [NSString stringWithString:self.contentHolder];
		}
	} else {
		if ([elementName isEqualToString:@"update"]) {
			[self.currentUpdate setAttributesDictionary:self.currentUpdateAttributes];
			[self.updatesList addObject:self.currentUpdate];
			self.currentUpdate = nil;
			self.currentUpdateAttributes = nil;
		} else if ([elementName isEqualToString:@"update_id"]) {
			[self.currentUpdateAttributes setObject:[NSString stringWithString:self.contentHolder] forKey:@"update_id"];
			[self.contentHolder setString:@""];
		} else if ([elementName isEqualToString:@"user_id"]) {
			[self.currentUpdateAttributes setObject:[NSString stringWithString:self.contentHolder] forKey:@"user_id"];
			[self.contentHolder setString:@""];
		} else if ([elementName isEqualToString:@"user_name"]) {
			[self.currentUpdateAttributes setObject:[NSString stringWithString:self.contentHolder] forKey:@"user_name"];
			[self.contentHolder setString:@""];
		} else if ([elementName isEqualToString:@"user_email"]) {
			[self.currentUpdateAttributes setObject:[NSString stringWithString:self.contentHolder] forKey:@"user_email"];
			[self.contentHolder setString:@""];
		} else if ([elementName isEqualToString:@"updated"]) {
			[self.currentUpdateAttributes setObject:[NSString stringWithString:self.contentHolder] forKey:@"updated"];
			[self.contentHolder setString:@""];
		} else if ([elementName isEqualToString:@"update_type"]) {
			[self.currentUpdateAttributes setObject:[NSString stringWithString:self.contentHolder] forKey:@"update_type"];
			[self.contentHolder setString:@""];
		} else if ([elementName isEqualToString:@"folder_id"]) {
			[self.currentUpdateAttributes setObject:[NSString stringWithString:self.contentHolder] forKey:@"folder_id"];
			[self.contentHolder setString:@""];
		} else if ([elementName isEqualToString:@"folder_name"]) {
			[self.currentUpdateAttributes setObject:[NSString stringWithString:self.contentHolder] forKey:@"folder_name"];
			[self.contentHolder setString:@""];
		} else if ([elementName isEqualToString:@"shared"]) {
			[self.currentUpdateAttributes setObject:[NSString stringWithString:self.contentHolder] forKey:@"shared"];
			[self.contentHolder setString:@""];
		} else if ([elementName isEqualToString:@"shared_name"]) {
			[self.currentUpdateAttributes setObject:[NSString stringWithString:self.contentHolder] forKey:@"shared_name"];
			[self.contentHolder setString:@""];
		} else if ([elementName isEqualToString:@"owner_id"]) {
			[self.currentUpdateAttributes setObject:[NSString stringWithString:self.contentHolder] forKey:@"owner_id"];
			[self.contentHolder setString:@""];
		} else if ([elementName isEqualToString:@"collab_access"]) {
			[self.currentUpdateAttributes setObject:[NSString stringWithString:self.contentHolder] forKey:@"collab_access"];
			[self.contentHolder setString:@""];
		} else if ([elementName isEqualToString:@"status"]) {
			self.status = [NSString stringWithString:self.contentHolder];
			[self.contentHolder setString:@""];
		}
	}
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
	[self.contentHolder appendString:string];
}

@end
