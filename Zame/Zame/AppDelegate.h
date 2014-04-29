//
//  AppDelegate.h
//  Zame
//
//  Created by Sebastian Messier on 4/17/14.
//  Copyright (c) 2014 CIS195. All rights reserved.
//

#import <UIKit/UIKit.h>
static NSString * const kClientId = @"spotify-ios-sdk-beta";
static NSString * const kCallbackURL = @"spotify-ios-sdk-beta://callback";
@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@end
