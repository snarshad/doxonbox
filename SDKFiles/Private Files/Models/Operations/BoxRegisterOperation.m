
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

#import "BoxRegisterOperation.h"
#import "BoxUser.h"

@implementation BoxRegisterOperation

@synthesize login = _login;
@synthesize password = _password;
@synthesize user = _user;

+ (BoxRegisterOperation *)operationForLogin:(NSString *)login
								   password:(NSString *)password
								   delegate:(id<BoxOperationDelegate>)delegate
{
	return [[[BoxRegisterOperation alloc] initForLogin:login
											  password:password
											  delegate:delegate] autorelease];
}

- (id)initForLogin:(NSString *)login 
		  password:(NSString *)password 
		  delegate:(id<BoxOperationDelegate>)delegate
{
	if ((self = [super initForType:BoxOperationTypeLogin delegate:delegate])) {
		self.login = login;
		self.password = password;
		self.user = nil;
	}

	return self;
}

- (NSURL *)url {
	return [NSURL URLWithString:[BoxRESTApiFactory registerUrlStringForLogin:self.login
																	password:self.password]];
}

- (NSString *)successCode {
	return @"successful_register";
}

- (NSArray *)resultKeysOfInterest {
	return [NSArray arrayWithObjects:@"status", @"auth_token", @"user", nil];
}

- (void)processErrorCode:(NSString *)status {
	if ([status isEqualToString:@"email_invalid"]) {
		self.error = [NSError errorWithDomain:BoxOperationErrorDomain
										 code:BoxOperationResponseInvalidName
									 userInfo:[NSDictionary dictionary]];
		self.operationResponse = BoxOperationResponseInvalidName;
	} else if ([status isEqualToString:@"email_already_registered"]) {
		self.error = [NSError errorWithDomain:BoxOperationErrorDomain
										 code:BoxOperationResponseAlreadyRegistered
									 userInfo:[NSDictionary dictionary]];
		self.operationResponse = BoxOperationResponseAlreadyRegistered;
	} else if ([status isEqualToString:@"application_restricted"]) {
		self.error = [NSError errorWithDomain:BoxOperationErrorDomain
										 code:BoxOperationResponseInternalAPIError
									 userInfo:[NSDictionary dictionary]];
		self.operationResponse = BoxOperationResponseInternalAPIError;
	} else if ([status isEqualToString:@"e_register"]) {
		self.error = [NSError errorWithDomain:BoxOperationErrorDomain
										 code:BoxOperationResponseUnknownError
									 userInfo:[NSDictionary dictionary]];
		self.operationResponse = BoxOperationResponseUnknownError;
	} else {
		[super processErrorCode:status];
	}
}

- (void)processResult:(NSDictionary *)result {
	NSDictionary *userInfo = [result objectForKey:@"user"];
	if (userInfo) {
		self.user = [BoxUser userWithAttributes:userInfo];
		self.user.authToken = [result objectForKey:@"auth_token"];
	}

	[super processResult:result];
}

- (void)dealloc {
    [_login release];
    _login = nil;
    [_password release];
    _password = nil;
    [_user release];
    _user = nil;
    
    [super dealloc];
}

@end
