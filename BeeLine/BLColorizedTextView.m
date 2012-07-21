//
//  BLColorizedTextView.m
//  BeeLine
//

#import "BLColorizedTextView.h"


@implementation BLColorizedTextView

@synthesize text=text_;
@synthesize font=font_;
@synthesize lineBreakMode=lineBreakMode_;
@synthesize colors=colors_;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    CGSize size = self.bounds.size;
    
    UIGraphicsBeginImageContext(size);
    CGContextSaveGState(UIGraphicsGetCurrentContext());
    CGContextTranslateCTM(UIGraphicsGetCurrentContext(), 0, size.height);
    CGContextScaleCTM(UIGraphicsGetCurrentContext(), 1.0, -1.0);
    [self.text drawInRect:CGRectMake(0.0f, 0.0f, size.width, size.height) withFont:self.font lineBreakMode:self.lineBreakMode];
    CGContextRestoreGState(UIGraphicsGetCurrentContext());
    CGImageRef textImage = CGBitmapContextCreateImage(UIGraphicsGetCurrentContext());
    UIGraphicsEndImageContext();
    
    CGSize lineHeight = [@"l" sizeWithFont:self.font];
    
    NSMutableArray *gradients = [[NSMutableArray alloc] initWithCapacity:[self.colors count]];
    int howManyColors = [self.colors count];
    for (int n = 0; n < howManyColors; n++) {
        UIColor *startColor = [self.colors objectAtIndex:n];
        UIColor *endColor   = [self.colors objectAtIndex:n >= howManyColors - 1 ? 0 : n + 1];
        const CGFloat *startColorComponents = CGColorGetComponents(startColor.CGColor);
        const CGFloat *endColorComponents   = CGColorGetComponents(endColor.CGColor);
        
        CGFloat components[8] = { startColorComponents[0], startColorComponents[1], startColorComponents[2], startColorComponents[3],
                                  endColorComponents[0],   endColorComponents[1],   endColorComponents[2],   endColorComponents[3] };
        CGFloat locations[2] = {0.0f, 1.0f};
        CGGradientRef textGradient = CGGradientCreateWithColorComponents(CGColorSpaceCreateDeviceRGB(), components, locations, 2);
        [gradients addObject:[[BLGradientRef alloc] initWithCGGradientRef:textGradient]];
    }

    int howManyLines = ceilf(size.height / lineHeight.height);
    int howManyGradients = [gradients count];
    for (int n = 0; n < howManyLines; n++) {
        int gradientIndex = n % howManyGradients;
        BLGradientRef *gradient = [gradients objectAtIndex:gradientIndex];
        
        CGLayerRef layer = CGLayerCreateWithContext(UIGraphicsGetCurrentContext(), CGSizeMake(size.width, lineHeight.height), NULL);
        CGContextClipToMask(CGLayerGetContext(layer), CGRectMake(0.0f, 0.0f - lineHeight.height * n, size.width, size.height), textImage);        
        CGContextDrawLinearGradient(CGLayerGetContext(layer), gradient.gradientRef, CGPointMake(0.0f, 0.0f), CGPointMake(size.width, 0.0f), 0);
        
        CGContextDrawLayerInRect(UIGraphicsGetCurrentContext(), CGRectMake(0.0f, lineHeight.height * n, size.width, lineHeight.height), layer);
        CGLayerRelease(layer);
    }
}



@end

@implementation BLGradientRef

@synthesize gradientRef=gradientRef_;

- (id)initWithCGGradientRef:(CGGradientRef)gradientRef {
    self = [super init];
    if (self) {
        gradientRef_ = gradientRef;
    }
    return self;
}

@end