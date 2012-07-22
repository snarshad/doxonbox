//
//  NSAttributedString+DXLexicalAnalysis.m
//  DoxOnBox
//
//  Created by Daniel DeCovnick on 7/22/12.
//  Copyright (c) 2012 Softyards Software. All rights reserved.
//

#import "NSAttributedString+DXLexicalAnalysis.h"
#import <CoreText/CoreText.h>

@implementation NSAttributedString (DXLexicalAnalysis)
+ (NSMutableAttributedString *)lexicallyHighlightedStringForString:(NSString *)str
{
    NSMutableAttributedString *ret = [[NSMutableAttributedString alloc] initWithString:str];
    [str enumerateLinguisticTagsInRange:NSMakeRange(0, str.length) 
                                 scheme:NSLinguisticTagSchemeLexicalClass 
                                options:0 
                            orthography:nil
                             usingBlock:
     ^(NSString *tag, NSRange tokenRange, NSRange sentenceRange, BOOL *stop) 
    {
        if (tag == NSLinguisticTagNoun || tag == NSLinguisticTagVerb)
        {
            [ret setAttributes:[NSDictionary dictionaryWithObject:(id)[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:1.0].CGColor forKey:(NSString *)kCTForegroundColorAttributeName] range:tokenRange];
        }
        else if (tag == NSLinguisticTagPreposition || tag == NSLinguisticTagPronoun || tag == NSLinguisticTagInterjection || tag == NSLinguisticTagAdjective)
        {
            [ret setAttributes:[NSDictionary dictionaryWithObject:(id)[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.75].CGColor forKey:(NSString *)kCTForegroundColorAttributeName] range:tokenRange];
        }
        else if (tag == NSLinguisticTagPunctuation || tag == NSLinguisticTagParticle || tag == NSLinguisticTagInterjection || tag == NSLinguisticTagAdverb)
        {
            [ret setAttributes:[NSDictionary dictionaryWithObject:(id)[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.5].CGColor forKey:(NSString *)kCTForegroundColorAttributeName] range:tokenRange];
        }
        else if (tag == NSLinguisticTagClassifier || tag == NSLinguisticTagConjunction || tag == NSLinguisticTagDeterminer || tag == NSLinguisticTagOtherWord)
        {
            [ret setAttributes:[NSDictionary dictionaryWithObject:(id)[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.25].CGColor forKey:(NSString *)kCTForegroundColorAttributeName] range:tokenRange];
        }
    }];
    return ret;
}
@end
