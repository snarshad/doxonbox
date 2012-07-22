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
    CGSize size = rect.size;
//    

    
    if (self.colors)
    {
        //This is the beeline code that adds gradients
        
        //prepare the gradients
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
        
        
        
        CFArrayRef lines = CTFrameGetLines(frame);
        CFIndex numLines = CFArrayGetCount(lines);        
        CGFloat ascent, descent, leading;
        CGFloat currentHeight = 0.0;
        CGFloat currentHeight2 = 0.0;

        NSLog(@"%d lines", numLines);

        UIGraphicsBeginImageContext(rect.size);
        context = UIGraphicsGetCurrentContext(); // 1-1

        CGContextSaveGState(context);        
        
//        [self.attributedText.string drawInRect:CGRectMake(0.0f, 0.0f, size.width, size.height) withFont:self.font lineBreakMode:self.lineBreakMode];
        
        // Flip the coordinate system
        CGContextSetTextMatrix(context, CGAffineTransformIdentity); // 2-1
        CGContextTranslateCTM(context, 0, self.bounds.size.height); // 3-1
        CGContextScaleCTM(context, 1.0, -1.0); // 4-1
        
        CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((__bridge CFAttributedStringRef)self.attributedText);
        CGMutablePathRef path = CGPathCreateMutable();
        CGPathAddRect(path, NULL, self.bounds);
        CTFrameRef frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, 0), path, NULL);
        CTFrameDraw(frame, context);

        CGContextRestoreGState(context);
        CGImageRef textImage = CGBitmapContextCreateImage(context);
        UIGraphicsEndImageContext();
        
        context = UIGraphicsGetCurrentContext();
        
        int howManyLines = numLines;
        int howManyGradients = [gradients count];

        for (CFIndex index = 0; index < CFArrayGetCount(lines); index++) {
            CTLineRef line = (CTLineRef)CFArrayGetValueAtIndex(lines, index);
            CTLineGetTypographicBounds(line, &ascent,  &descent, &leading);	
            CGRect lineBounds = CTLineGetImageBounds(line, context);
            currentHeight += lineBounds.size.height;
            
            CGFloat lineHeight = (ascent + fabsf(descent) + leading);
            currentHeight2 += lineHeight;	
            
            CGPoint thisLineOrigin;
			CTFrameGetLineOrigins(frame, CFRangeMake(index, 1), &thisLineOrigin);
            
            NSLog(@"Line %ld at %@ : %@ %f %f", index, NSStringFromCGPoint(thisLineOrigin), NSStringFromCGRect(lineBounds), currentHeight, currentHeight2);

            int gradientIndex = index % howManyGradients;
            BLGradientRef *gradient = [gradients objectAtIndex:gradientIndex];
            
            CGLayerRef layer = CGLayerCreateWithContext(UIGraphicsGetCurrentContext(), CGSizeMake(size.width, lineHeight), NULL);
            CGContextClipToMask(CGLayerGetContext(layer), CGRectMake(0.0f, 0.0f - currentHeight2, size.width, size.height), textImage);        
            CGContextDrawLinearGradient(CGLayerGetContext(layer), gradient.gradientRef, CGPointMake(0.0f, 0.0f), CGPointMake(size.width, 0.0f), 0);
            
            CGContextDrawLayerInRect(UIGraphicsGetCurrentContext(), CGRectMake(0.0f, currentHeight2, size.width, lineHeight), layer);
            CGLayerRelease(layer);
        }
    }
}


@end
