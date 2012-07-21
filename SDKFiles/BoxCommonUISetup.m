
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

#import "BoxCommonUISetup.h"


@implementation BoxCommonUISetup

+(void) formatNavigationBarWithBoxIconAndColorScheme:(UINavigationController*)navController andNavItem:(UINavigationItem*)navItem
{
	UIImageView * logo = [[[UIImageView alloc] initWithFrame: CGRectMake(0, 0, 54.0f, 32.0f)] autorelease];
    logo.image = [UIImage imageNamed:@"BoxTopBarLogo"];
    logo.center = [navController.navigationBar center];
    navItem.titleView = logo;
	navController.navigationBar.tintColor = [UIColor colorWithRed:0.219608f green:0.537255f blue:0.74117647f alpha:1.0];
}

@end
