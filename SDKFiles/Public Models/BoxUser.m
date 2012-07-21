
//
// Copyright 2011 Box, Inc.
//
//   Licensed under the Apache License, Version 2.0 (the "License");
//   you may not use this file except in compliance with the License.
//   You may obtain a copy of the License at
//
//       http://www.apache.org/licenses/LICENSE-2.0
//
//   Unless required by applicable law or agreed to in writing, software
//   distributed under the License is distributed on an "AS IS" BASIS,
//   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//   See the License for the specific language governing permissions and
//   limitations under the License.
//

#import "BoxUser.h"
#import "UIApplication+Security.h"


static BoxUser * sharedLoggedInUser = nil;

#define BOX_USER_INFO_FILE_NAME @"BoxUsernameInfo.bin"

#define USERNAME @"login"
#define EMAIL @"email"
#define ACCESSID @"access_id"
#define USERID @"user_id"
#define AUTHTOKEN @"auth_token"

@interface BoxUser() <NSCoding> {
	NSString *__authToken;
    
	NSString *__userName;
	NSString *__email;
	
	NSNumber *__accessId;
	NSNumber *__userId;    
}

+ (NSString*)pathForUserInfo;

@end

@implementation BoxUser

@synthesize authToken = __authToken, userName = __userName, email = __email, accessId = __accessId, userId = __userId;

- (void)encodeWithCoder:(NSCoder *)aCoder { //does not save authtoken for security reasons
    [aCoder encodeObject:self.userName forKey:USERNAME];
    [aCoder encodeObject:self.email forKey:EMAIL];
    [aCoder encodeObject:self.accessId forKey:ACCESSID];
    [aCoder encodeObject:self.userId forKey:USERID];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [self init];
    if (self) {
        self.userName = [aDecoder decodeObjectForKey:USERNAME];
        self.email = [aDecoder decodeObjectForKey:EMAIL];
        self.accessId = [aDecoder decodeObjectForKey:ACCESSID];
        self.userId = [aDecoder decodeObjectForKey:USERID];
        self.authToken = nil;
    }
    return self;
}

+ (BoxUser *)userWithAttributes:(NSDictionary *)attributes {
    
	NSNumberFormatter *numberFormatter = [[[NSNumberFormatter alloc] init] autorelease];
	[numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
    
	BoxUser *user = [[BoxUser alloc] init];
	user.userName = [attributes objectForKey:USERNAME];
	user.email = [attributes objectForKey:EMAIL];
	user.userId = [numberFormatter numberFromString:[attributes objectForKey:USERID]];
	user.accessId = [numberFormatter numberFromString:[attributes objectForKey:ACCESSID]];
	user.authToken = [attributes objectForKey:AUTHTOKEN];
    
	return [user autorelease];
}

+ (BoxUser *)savedUser {
    if (sharedLoggedInUser != nil) {
        return sharedLoggedInUser;
    }
    BoxUser * user = [NSKeyedUnarchiver unarchiveObjectWithFile:[[self class] pathForUserInfo]];
    if (user == nil) {
        return nil; //no file exists
    }
    user.authToken = [UIApplication searchKeychainMatching:user.userName];
    if (user.authToken == nil) {
        return nil;
    }
    sharedLoggedInUser = [user retain];
    return user;
}

+ (BOOL)clearSavedUser {
    BoxUser * currentUser = sharedLoggedInUser;
    if (!currentUser) {
        currentUser = [NSKeyedUnarchiver unarchiveObjectWithFile:[[self class] pathForUserInfo]];
    }
    if (currentUser) {
        [UIApplication deleteKeychainValue:currentUser.userName];
    }
    if (sharedLoggedInUser != nil) {
        [sharedLoggedInUser release];
        sharedLoggedInUser = nil;
    }
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    return [fileMgr removeItemAtPath:[self pathForUserInfo] error:NULL];
}

- (BOOL)loggedIn {
    if(self.authToken == nil || 
	   [self.authToken compare:@""] == NSOrderedSame || 
	   self.userName == nil || 
	   [self.userName compare:@""] == NSOrderedSame) {
        [[self class] clearSavedUser];
		return  NO;
	}
	return YES;
}

- (BOOL)save:(BOOL)rememberLogin {
    [[self class] clearSavedUser];
    sharedLoggedInUser = [self retain];
    BOOL success = YES;
    if (rememberLogin) {
        success = [NSKeyedArchiver archiveRootObject:self toFile:[[self class] pathForUserInfo]];
        if (success) {
            success = [UIApplication createKeychainValue:self.authToken forIdentifier:sharedLoggedInUser.userName];
        }
    }
    return success;
}

+ (NSString*)pathForUserInfo {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    if ([paths count] == 0) {
        return nil;
    }
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *path = [documentsDirectory stringByAppendingPathComponent:BOX_USER_INFO_FILE_NAME];
    return path;
}

- (void)dealloc {
    [__authToken release];
    __authToken = nil;
    [__userName release];
    __userName = nil;
    [__email release];
    __email = nil;
    [__accessId release];
    __accessId = nil;
    [__userId release];
    __userId = nil;
    [super dealloc];
}


@end
