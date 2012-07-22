//
//  DXHTMLStripper.h
//  DoxOnBox
//
//  Created by Arshad Tayyeb on 7/21/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DXHTMLStripper : NSObject <UIWebViewDelegate>
+ (NSDictionary *)plainTextFromHTML:(NSString *)stringWithHTML;

@end
