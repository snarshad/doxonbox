
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

#import "BoxCommentsListModelXMLBuilder.h"


@implementation BoxCommentsListModelXMLBuilder

@synthesize contentHolder = _contentHolder;
@synthesize status = _status;

@synthesize mainCommentList = _mainCommentList;
@synthesize replyCommentList = _replyCommentList;
@synthesize currentComment = _currentComment;
@synthesize currentCommentAttributes = _currentCommentAttributes;

@synthesize inReplyComments = _inReplyComments;
@synthesize replyCommentsBuilder = _replyCommentsBuilder;

+ (NSArray *)commentsForURL:(NSURL *)url {
	BoxCommentsListModelXMLBuilder *builder = [[[BoxCommentsListModelXMLBuilder alloc] init] autorelease];
	
	return [builder commentsForURL:url];
}

- (NSArray *)commentsForURL:(NSURL *)url {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    NSData * dataXml = [[[NSData alloc] initWithContentsOfURL:url] autorelease];
	NSXMLParser *parser = [[NSXMLParser alloc] initWithData:dataXml];
	
	[parser setDelegate: self];
	[parser setShouldProcessNamespaces:NO];
	[parser setShouldReportNamespacePrefixes: NO];
	[parser setShouldResolveExternalEntities: NO];
	
	[parser parse];
	
    [parser release];
    
    [pool drain];
	
	return self.mainCommentList;
}

- (id)init {
	if (self = [super init]) {
		self.contentHolder = [NSMutableString string];
	}

	return self;
}

- (void) dealloc {
	self.contentHolder = nil;
	self.status = nil;

	self.mainCommentList = nil;
	self.replyCommentList = nil;
	self.currentComment = nil;
	self.currentCommentAttributes = nil;

	self.replyCommentsBuilder = nil;

	[super dealloc];
}

- (void)parser:(NSXMLParser *)parser 
didStartElement:(NSString *)elementName 
  namespaceURI:(NSString *)namespaceURI 
 qualifiedName:(NSString *)qualifiedName 
	attributes:(NSDictionary *)attributeDict 
{
	if ([elementName isEqualToString:@"reply_comments"]) {
		self.inReplyComments = YES;
		self.replyCommentsBuilder = [[[BoxCommentsListModelXMLBuilder alloc] init] autorelease];
	}

	if (self.inReplyComments) {
		NSString *elementNameToPass = elementName;
		if ([elementName isEqualToString:@"reply_comments"]) {
			elementNameToPass = @"comments";
		}
		[_replyCommentsBuilder parser:parser
					  didStartElement:elementNameToPass
						 namespaceURI:namespaceURI
						qualifiedName:qualifiedName
						   attributes:attributeDict];
		return;
	}

	if ([elementName isEqualToString:@"comments"]) {
		self.inReplyComments = NO;
		self.mainCommentList = [NSMutableArray array];
	} else if ([elementName isEqualToString:@"comment"] || [elementName isEqualToString:@"item"]) {
		self.currentCommentAttributes = [[[NSMutableDictionary alloc] initWithCapacity:7] autorelease];
	}
}

- (void)parser:(NSXMLParser *)parser
 didEndElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI
 qualifiedName:(NSString *)qName
{
	if (self.inReplyComments) {
		if ([elementName isEqualToString:@"reply_comments"]) {
			self.inReplyComments = NO;
			self.replyCommentList = self.replyCommentsBuilder.mainCommentList;
			self.replyCommentsBuilder = nil;
		} else {
			[self.replyCommentsBuilder parser:parser 
								didEndElement:elementName
								 namespaceURI:namespaceURI
								qualifiedName:qName];
			return;
		}
	}

	if ([elementName isEqualToString:@"comments"]) {
		return;
	} else if ([elementName isEqualToString:@"comment"] || [elementName isEqualToString:@"item"]) {
		BoxComment *comment = [BoxComment commentWithAttributes:self.currentCommentAttributes];
		self.currentCommentAttributes = nil;
		comment.replyComments = self.replyCommentList;
		self.replyCommentList = nil;

		[self.mainCommentList addObject:comment];
	} else if ([elementName isEqualToString:@"reply_comments"]) {
		self.inReplyComments = NO;
	} else if ([elementName isEqualToString:@"comment_id"]) {
		[self.currentCommentAttributes setObject:[NSString stringWithString:self.contentHolder] forKey:[NSString stringWithString:elementName]];
		[self.contentHolder setString:@""];
	} else if ([elementName isEqualToString:@"message"]) {
		[self.currentCommentAttributes setObject:[NSString stringWithString:self.contentHolder] forKey:[NSString stringWithString:elementName]];
		[self.contentHolder setString:@""];
	} else if ([elementName isEqualToString:@"user_id"]) {
		[self.currentCommentAttributes setObject:[NSString stringWithString:self.contentHolder] forKey:[NSString stringWithString:elementName]];
		[self.contentHolder setString:@""];
	} else if ([elementName isEqualToString:@"user_name"]) {
		[self.currentCommentAttributes setObject:[NSString stringWithString:self.contentHolder] forKey:[NSString stringWithString:elementName]];
		[self.contentHolder setString:@""];
	} else if ([elementName isEqualToString:@"avatar_url"]) {
		[self.currentCommentAttributes setObject:[NSString stringWithString:self.contentHolder] forKey:[NSString stringWithString:elementName]];
		[self.contentHolder setString:@""];
	} else if ([elementName isEqualToString:@"created"]) {
		[self.currentCommentAttributes setObject:[NSString stringWithString:self.contentHolder] forKey:[NSString stringWithString:elementName]];
		[self.contentHolder setString:@""];
	} else if ([elementName isEqualToString:@"can_reply"]) {
		[self.currentCommentAttributes setObject:[NSString stringWithString:self.contentHolder] forKey:[NSString stringWithString:elementName]];
		[self.contentHolder setString:@""];
	} else if ([elementName isEqualToString:@"status"]) {
		self.status = [NSString stringWithString:self.contentHolder];
		[self.contentHolder setString:@""];
	}
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
	if (self.inReplyComments) {
		[self.replyCommentsBuilder parser:parser foundCharacters:string];
	} else {
		[self.contentHolder appendString:string];
	}
}

@end
