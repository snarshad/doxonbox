//
//  NSAttributedString+DXLexicalAnalysis.h
//  DoxOnBox
//
//  Created by Daniel DeCovnick on 7/22/12.
//  Copyright (c) 2012 Softyards Software. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSAttributedString (DXLexicalAnalysis)
+ (NSMutableAttributedString *)lexicallyHighlightedStringForString:(NSString *)str;
@end
