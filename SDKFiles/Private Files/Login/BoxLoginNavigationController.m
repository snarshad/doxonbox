
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

#import "BoxLoginNavigationController.h"
#import "BoxLoginViewController.h"


@interface BoxLoginNavigationController () {
    id<BoxLoginViewControllerDelegate> __boxLoginDelegate;
}

@property (nonatomic, assign) id<BoxLoginViewControllerDelegate> boxLoginDelegate;

- (void)cancelButtonPressed:(id)cancelButton;

@end

@implementation BoxLoginNavigationController

@synthesize boxLoginDelegate = __boxLoginDelegate;

#pragma mark - Button Methods

- (void)cancelButtonPressed:(id)cancelButton {
    if ([self.boxLoginDelegate respondsToSelector:@selector(boxLoginViewController:didFinishWithResult:)]) {
        [self.boxLoginDelegate boxLoginViewController:(BoxLoginViewController*)self didFinishWithResult:LoginCancelled];
    } else {
        NSLog(@"Cancel button was pressed in BoxLoginViewController and tried to notify its delegate, but the delegate was nil or boxLoginViewController:didFinishWithResult: has not been implemented.");
    }
}

#pragma mark - Properties

- (void)setBoxLoginDelegate:(id<BoxLoginViewControllerDelegate>)newBoxLoginDelegate {
    __boxLoginDelegate = newBoxLoginDelegate;
    UIViewController * rootVC = (BoxLoginViewController*)[self.viewControllers objectAtIndex:0];
    if ([rootVC isKindOfClass:[BoxLoginViewController class]]) {
        ((BoxLoginViewController*)rootVC).boxLoginDelegate = newBoxLoginDelegate; //pass on delegate to the actual object as well
    } else {
        NSLog(@"Error: The root view controller in the wrapper navigation controller for BoxLogin must always be a BoxLoginViewController. Any changes to this may cause unexpected behavior.");
    }
}

#pragma mark - View Life Cycle

- (void)dealloc {
    __boxLoginDelegate = nil;
    
    [super dealloc];
}

@end
