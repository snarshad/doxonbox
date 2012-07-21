
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

#import "NSDictionaryXMLParser.h"
#import "NSArray+BoxUtils.h"


@implementation NSDictionaryXMLParser

@synthesize error, currentElementKey=_currentElementKey, currentElementData=_currentElementData;

+ (NSDictionary *)dictionaryWithXMLContentsOfURL:(NSURL *)url 
									selectedKeys:(NSArray *)keys 
										   error:(NSError **)error 
{
	NSDictionaryXMLParser *parser = [[NSDictionaryXMLParser alloc] initWithSelectedKeys:keys];
	NSDictionary *results = [parser parseURL:url];
	
	if (error) {
		*error = [parser error];
	}
	
	[parser release];
	
	return results;
}

+ (NSDictionary *)dictionaryWithXML:(NSData *)data selectedKeys:(NSArray *)keys error:(NSError **)error  {
	NSDictionaryXMLParser *parser = [[NSDictionaryXMLParser alloc] initWithSelectedKeys:keys];
	NSDictionary *results = [parser parse:data];
	
	if (error) {
		*error = [parser error];
	}
	
	[parser release];
	
	return results;
}

- (id)initWithSelectedKeys:(NSArray *)_keys {
	if (self = [super init]) {
		keys = [_keys retain];
	}
	
	return self;
}

- (void)dealloc {
	[keys release];
    keys = nil;
    [_currentElementKey release];
    _currentElementKey = nil;
    [_currentElementData release];
    _currentElementData = nil;
	[super dealloc];
}

- (NSDictionary *)parseURL:(NSURL *)url  {
	return [self parse:[NSData dataWithContentsOfURL:url]];
}

- (NSDictionary *)parse:(NSData *)data {
	NSXMLParser *parser = [[NSXMLParser alloc] initWithData:data];
	
	results = [NSMutableDictionary dictionary];
	dataStack = [[NSMutableArray alloc] init];
	[dataStack push:results];
	
	[parser setDelegate: self];
	[parser setShouldProcessNamespaces:NO];
	[parser setShouldReportNamespacePrefixes: NO]; 
	[parser setShouldResolveExternalEntities: NO];
	[parser parse];
	
	[self setError:[parser parserError]];
	[parser release];
	
	results = [[dataStack pop] retain];
	[dataStack release];
		
	return [results autorelease];
}

#pragma mark Implementation

- (void) parseDidStartDocument: (NSXMLParser *) parser {
	self.currentElementData = nil;
	self.currentElementKey = nil;
}

- (void) parser:(NSXMLParser *)parser 
didStartElement:(NSString *)elementName 
   namespaceURI:(NSString *)namespaceURI 
  qualifiedName:(NSString *)qName 
	 attributes:(NSDictionary *)attributeDict
{
    if (qName) {
        elementName = qName;
    }
	// If currentElementData is still set, it signals we're going recursive
	if ([self.currentElementData isKindOfClass:[NSString class]] && ![self.currentElementData length]) {
		[dataStack pop]; // Pop the string that was pushed on below
		[dataStack push:[NSMutableDictionary dictionary]];
		[results setObject:[dataStack lastObject] forKey:self.currentElementKey];
		results = [dataStack lastObject];
	}
			
	if (self.currentElementData || [dataStack count] > 1 || [keys containsObject:elementName]) {
		self.currentElementData = [NSMutableString string];
		
		if ([attributeDict count]) {
			[dataStack push:[NSMutableDictionary dictionaryWithDictionary:attributeDict]];
			[results setObject:[dataStack lastObject] forKey:elementName];
			results = [dataStack lastObject];
			self.currentElementKey = @"value";
		} else {
			self.currentElementKey = elementName;
			[dataStack push:self.currentElementData];
		}
	}
}

- (void) parser:(NSXMLParser *)parser 
  didEndElement:(NSString *)elementName 
   namespaceURI:(NSString *)namespaceURI 
  qualifiedName: (NSString *) qName
{
    /*if (qName) { //Currently, this code causes an analyzer problem so has been commented out. However, if element name is ever needed in the future in this method, these lines should be included.
        elementName = qName;
    }*/
	if (self.currentElementData) {
		if ([self.currentElementData isKindOfClass:[NSString class]]) {
			[results setObject:[self.currentElementData stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] forKey:self.currentElementKey];
		} else {
			[results setObject:self.currentElementData forKey:self.currentElementKey];
		}

	}
	
	// Avoid popping first data container
	if ([dataStack count] > 1) {
		[dataStack pop];
		results = [dataStack lastObject];
	}
	
	self.currentElementData = nil;
}

- (void) parser:(NSXMLParser *)parser foundCharacters:(NSString *)xString {
	[self.currentElementData appendString:xString];
}

@end
