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

#define DRAW_GRADIENTS

- (void)drawRect:(CGRect)rect
{    
    


#ifndef DRAW_GRADIENTS
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
#endif
    
    CGSize size = rect.size;
    
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
    

#ifdef DRAW_GRADIENTS
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext(); // 1-1

    CGContextSaveGState(context);        
        
    // Flip the coordinate system
    CGContextSetTextMatrix(context, CGAffineTransformIdentity); // 2-1
    CGContextTranslateCTM(context, 0, self.bounds.size.height); // 3-1
    CGContextScaleCTM(context, 1.0, -1.0); // 4-1
    
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((__bridge CFAttributedStringRef)self.attributedText);
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, self.bounds);
    CTFrameRef frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, 0), path, NULL);
    CTFrameDraw(frame, context);

    CFArrayRef lines = CTFrameGetLines(frame);
    CFIndex numLines = CFArrayGetCount(lines);        
    CGFloat ascent, descent, leading;
    CGFloat currentHeight = 0.0;
    CGFloat currentHeight2 = 0.0;

    CGContextRestoreGState(context);
    CGImageRef textImage = CGBitmapContextCreateImage(context);
    UIGraphicsEndImageContext();
    
    context = UIGraphicsGetCurrentContext();
    
    currentHeight = rect.origin.y;
    currentHeight2 = rect.origin.y;
    
    int howManyGradients = [gradients count];

    //iterate over the lines
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
        
        NSLog(@"%f", lineHeight);

        //figure out where to get the clipping path, based on the appropriate section of the text image
        //TODO: THIS IS WRONG
        CGRect textClipRect = CGRectMake(0.0f, 0.0f-thisLineOrigin.y, size.width, size.height);

        //where to draw the gradient
        CGRect gradientRect = CGRectMake(0.0f, currentHeight2, size.width, lineHeight);

        //create a layer in which we will draw the gradient
        CGLayerRef layer = CGLayerCreateWithContext(UIGraphicsGetCurrentContext(), CGSizeMake(size.width, lineHeight), NULL);

        CGContextSetTextMatrix(CGLayerGetContext(layer), CGAffineTransformIdentity); // 2-1
        CGContextTranslateCTM(CGLayerGetContext(layer), 0, lineHeight); // 3-1
        CGContextScaleCTM(CGLayerGetContext(layer), 1.0, -1.0); // 4-1
        
        //clip the layer using the appropiate section of text
        CGContextClipToMask(CGLayerGetContext(layer), textClipRect, textImage);        

        //draw the gradient in the layer
        CGContextDrawLinearGradient(CGLayerGetContext(layer), gradient.gradientRef, CGPointMake(0.0f, 0.0f), CGPointMake(size.width, 0.0f), 0);            
        
        //draw the layer at the appropriate place (i.e., where the text would be)
        CGContextDrawLayerInRect(UIGraphicsGetCurrentContext(), gradientRect, layer);

        CGLayerRelease(layer);
    }
#endif
}


@end
