
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

#import "NSArray+BoxUtils.h"


@implementation NSArray (BoxUtils)

- (id)archive {
	NSMutableArray *archive = [NSMutableArray arrayWithCapacity:[self count]];

	for (id obj in self) {
		[archive addObject:[obj archive]];
	}

	return archive;
}

- (id)firstObject {
	return [self objectAtIndex:0];
}

- (NSArray *)arrayByShiftingFirstObject {
	return [self subarrayWithRange:NSMakeRange(1, [self count] -1)];
}

- (NSArray *)arrayByFlatteningObjects {
	int count = [self count], i;
	NSMutableArray *array = [NSMutableArray arrayWithCapacity:count];
	Class nsarrayClass = [NSArray class];

	for (i = 0; i < count; i++) {
		id object = [self objectAtIndex:i];
		if (![object isKindOfClass:nsarrayClass]) {
			[array addObject:object];
		} else {
			[array addObjectsFromArray:[object arrayByFlatteningObjects]];
		}
	}

	return array;
}

- (NSArray *)map:(id (^)(id object))block {
	NSUInteger count = [self count];
	id *temp = (id *)malloc(count * sizeof(id));

	[self enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		temp[idx] = [block(obj) retain];
	}];

	NSUInteger i;
	NSArray *result = [NSArray arrayWithObjects:temp count:count];
	for (i = 0; i < count; i++) {
		[temp[i] release];
	}
	free(temp);
	return result;
}

- (void)apply:(void (^)(id object))block {
	[self enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		block(obj);
	}];
}

@end

@implementation NSMutableArray (BoxUtils)

- (void)push:(id)obj {
	[self addObject:obj];
}

- (id)pop {
	@try {
		id obj = [self lastObject];
		[self removeLastObject];
		return obj;
	} @catch (NSException * e) {
		return nil;
	}

	return nil;
}

@end
