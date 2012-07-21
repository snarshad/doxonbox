
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

@class BoxObject;
@class BoxUpdate;


@interface BoxUpdatesListModelXMLBuilder : NSObject <NSXMLParserDelegate> {
	NSMutableString *_contentHolder;
	NSMutableString *_status;

	BoxUpdate *_currentUpdate;
	NSMutableDictionary *_currentUpdateParameterDictionary;
	NSMutableArray *_updatesList;
	
	BoxObject *_boxObject;
}

@property (nonatomic, readwrite, retain) NSMutableString *contentHolder;
@property (nonatomic, readwrite, retain) NSString *status;

@property (nonatomic, readwrite, retain) BoxUpdate *currentUpdate;
@property (nonatomic, readwrite, retain) NSMutableDictionary *currentUpdateAttributes;
@property (nonatomic, readwrite, retain) NSMutableArray *updatesList;
@property (nonatomic, readwrite, retain) BoxObject *boxObject;

- (NSArray *)updatesWithData:(NSData *)xmlData;

@end
