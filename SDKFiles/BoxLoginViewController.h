
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

#import <UIKit/UIKit.h>
#import "BoxUser.h"


typedef enum {
    LoginSuccess,
    LoginCancelled
} LoginResult;

@protocol BoxLoginViewControllerDelegate;



@interface BoxLoginViewController : UIViewController

@property (nonatomic, assign) id<BoxLoginViewControllerDelegate> boxLoginDelegate;

+ (id)loginViewControllerWithNavBar:(BOOL)includeNavBar; //if yes, returns a navigationcontroller to present modally
+ (BoxUser*)currentUser; //returns current signed in user. Returns nil if not signed in.
+ (BOOL)userSignedIn;
+ (void)logoutCurrentUser; //clears all data about logged in user

@end



@protocol BoxLoginViewControllerDelegate <NSObject>

- (void)boxLoginViewController:(BoxLoginViewController*)boxLoginViewController didFinishWithResult:(LoginResult)result; //this method will be responsible for removing the view controller from the screen

@optional
- (BOOL)boxLoginViewController:(BoxLoginViewController*)boxLoginViewController shouldDisplayError:(NSError*)error; //overwritten to return false if developer wants to use their own error messages

@end

