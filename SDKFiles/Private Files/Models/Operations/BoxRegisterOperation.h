
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

#import <Foundation/Foundation.h>
#import "BoxAPIOperation.h"

@class  BoxUser;

typedef enum _BoxRegisterResponseType {
	boxRegisterResponseTypeSuccess,
	boxRegisterResponseTypeEmailInvalid,
	boxRegisterResponseTypeEmailExists,
	boxRegisterResponseTypeUnknownError
} BoxRegisterResponseType;

@interface BoxRegisterOperation : BoxAPIOperation {
    NSString *_login;
	NSString *_password;
	
	BoxUser*_user;
}

@property (nonatomic, readwrite, retain) NSString *login;
@property (nonatomic, readwrite, retain) NSString *password;
@property (nonatomic, readwrite, retain) BoxUser*user;

+ (BoxRegisterOperation *)operationForLogin:(NSString *)login
								   password:(NSString *)password
								   delegate:(id <BoxOperationDelegate>)delegate;

- (id)initForLogin:(NSString *)login
		  password:(NSString *)password
			 delegate:(id <BoxOperationDelegate>)delegate;

@end
