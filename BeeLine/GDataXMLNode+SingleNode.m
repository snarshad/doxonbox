//
//  GDataXMLNode+SingleNode.m
//

#import "GDataXMLNode+SingleNode.h"


@implementation GDataXMLNode (SingleNode)

- (NSString *)innerText {
    NSMutableString *innerText = [[NSMutableString alloc] init];
    for (GDataXMLNode *child in [self children]) {
        [innerText appendString:[child stringValue]];
    }
    return innerText;
}

- (GDataXMLNode *)nodeForXPath:(NSString *)query error:(NSError **)error {
    NSArray *nodes = [self nodesForXPath:query error:error];
    if (nodes == nil || [nodes count] <= 0) {
        return nil;
    }
    else {
        return [nodes objectAtIndex:0];
    }
}

- (NSString *)innerTextForXPath:(NSString *)query error:(NSError **)error {
    GDataXMLNode *node = [self nodeForXPath:query error:error];
    if (node == nil) {
        return nil;
    }
    else {
        return [node innerText];
    }
}

@end
