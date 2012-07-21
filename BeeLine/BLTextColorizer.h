//
//  BLTextColorizer.h
//  BeeLine

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


@interface BLTextColorizer : NSObject {
    NSString *text_;
    NSArray *colors_;
    NSUInteger period_;
}

@property (nonatomic) NSString *text;
@property (nonatomic) NSArray *colors;
@property (nonatomic, assign) NSUInteger period;

- (id)initWithText:(NSString *)text;
- (NSString *)colorize;

@end
