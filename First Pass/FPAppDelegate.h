//
//  FPAppDelegate.h
//  First Pass
//
//  Created by Thiago Ricieri on 06/10/13.
//  Copyright (c) 2013 First Pass. All rights reserved.
//

#import "definitions.h"
#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>

@interface FPAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

- (void) startFromHome;
- (void) restartApplication;

@end
