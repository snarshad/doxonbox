//
//  GDataXMLNode+SingleNode.h
//

#import <Foundation/Foundation.h>

#import "GDataXMLNode.h"

@interface GDataXMLNode (SingleNode)

- (NSString *)innerText;
- (GDataXMLNode *)nodeForXPath:(NSString *)query error:(NSError **)error;
- (NSString *)innerTextForXPath:(NSString *)query error:(NSError **)error;

@end