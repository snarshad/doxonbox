//
//  BLTextColorizer.m
//  BeeLine

#import "BLTextColorizer.h"


@implementation BLTextColorizer

@synthesize text=text_;
@synthesize colors=colors_;
@synthesize period=period_;

- (id)initWithText:(NSString *)text {
    self = [super init];
    if (self) {
        text_ = text;
        period_ = 50u;
    }
    return self;
}

- (NSString *)colorize {
    int totalColors = [self.colors count];
    NSMutableArray *allColors = [[NSMutableArray alloc] initWithCapacity:totalColors * self.period];
    
    for (int n=0; n <  totalColors; n++) {
        UIColor *thisColor = [self.colors objectAtIndex:n];
        UIColor *nextColor = [self.colors objectAtIndex:n == totalColors - 1 ? 0 : n+1];
        
        const CGFloat *thisColorComponents = CGColorGetComponents([thisColor CGColor]);
        const CGFloat *nextColorComponents = CGColorGetComponents([nextColor CGColor]);
        
        CGFloat rStep = (nextColorComponents[0] - thisColorComponents[0]) / self.period;
        CGFloat gStep = (nextColorComponents[1] - thisColorComponents[1]) / self.period;
        CGFloat bStep = (nextColorComponents[2] - thisColorComponents[2]) / self.period;

        for (int m=0; m < self.period; m++) {
            [allColors addObject:[UIColor colorWithRed:thisColorComponents[0] + rStep * m 
                                                 green:thisColorComponents[1] + gStep * m 
                                                  blue:thisColorComponents[2] + bStep * m 	
                                                 alpha:1.0f]];
        }
    }
    
    NSMutableString *returnValue = [[NSMutableString alloc] init];
    int length = [self.text length];
    for (int n = 0; n < length; n++) {
        unichar character = [self.text characterAtIndex:n];
        int colorIndex = n % [allColors count];
        const CGFloat *colorComponents = CGColorGetComponents([[allColors objectAtIndex:colorIndex] CGColor]);
        [returnValue appendFormat:@"<span style=\"color:rgb(%i,%i,%i)\">%C</span>", (int)(colorComponents[0] * 255), (int)(colorComponents[1] * 255), (int)(colorComponents[2] * 255), character];
    }
    return returnValue;
}


@end
