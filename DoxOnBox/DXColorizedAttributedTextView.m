//
//  DXColorizedAttributedTextView.m
//  DoxOnBox
//
//  Created by Daniel DeCovnick on 7/22/12.
//  Copyright (c) 2012 Softyards Software. All rights reserved.
//

#import "DXColorizedAttributedTextView.h"
#import <CoreText/CoreText.h>

@implementation DXColorizedAttributedTextView
@synthesize attributedText;


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{    
    
    CGContextRef context = UIGraphicsGetCurrentContext(); // 1-1
    
    // Flip the coordinate system
    CGContextSetTextMatrix(context, CGAffineTransformIdentity); // 2-1
    CGContextTranslateCTM(context, 0, self.bounds.size.height); // 3-1
    CGContextScaleCTM(context, 1.0, -1.0); // 4-1

    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((__bridge CFAttributedStringRef)self.attributedText);
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, self.bounds);
    CTFrameRef frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, 0), path, NULL);
    CTFrameDraw(frame, context);

    CFDictionaryRef dictRef = CTFrameGetFrameAttributes( frame );
    NSLog(@"dict %@", (__bridge NSDictionary *)dictRef);
    
    //    
    CGSize size = CGSizeMake(800, 800);
//    

    
    if (0)//self.colors)
    {
        
        
        UIGraphicsBeginImageContext(size);
        CGContextSaveGState(UIGraphicsGetCurrentContext());

        
        
        [self.attributedText.string drawInRect:CGRectMake(0.0f, 0.0f, size.width, size.height) withFont:self.font lineBreakMode:self.lineBreakMode];
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
}


@end
