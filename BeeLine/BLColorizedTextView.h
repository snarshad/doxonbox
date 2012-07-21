//
//  BLColorizedTextView.h
//  BeeLine
//

#import <UIKit/UIKit.h>


@interface BLColorizedTextView : UIView {
    NSString *text_;
    UIFont *font_;
    UILineBreakMode lineBreakMode_;
    NSArray *colors_;
}

@property (nonatomic) NSString *text;
@property (nonatomic) UIFont *font;
@property (nonatomic, assign) UILineBreakMode lineBreakMode;
@property (nonatomic) NSArray *colors;

@end

@interface BLGradientRef : NSObject {
@private
    CGGradientRef gradientRef_;
}

- (id)initWithCGGradientRef:(CGGradientRef)gradientRef;

@property (nonatomic, assign) CGGradientRef gradientRef;

@end