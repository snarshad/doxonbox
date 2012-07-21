
#import <Foundation/Foundation.h>

@interface UIApplication (Security)

+ (void)deleteKeychainValue:(NSString *)identifier;
+ (BOOL)updateKeychainValue:(NSString *)password forIdentifier:(NSString *)identifier;
+ (BOOL)createKeychainValue:(NSString *)password forIdentifier:(NSString *)identifier;
+ (NSString *)searchKeychainMatching:(NSString *)identifier;
+ (NSMutableDictionary *)searchDictionary:(NSString *)identifier;

@end

