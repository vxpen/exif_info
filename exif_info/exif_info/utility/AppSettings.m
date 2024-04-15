//
//  AppSettings.m
//  ExifTools
//
//  Created by tbago on 2020/5/28.
//  Copyright © 2020 vxpen. All rights reserved.
//

#import "AppSettings.h"

static const NSString * const kEnableCalibrateMapCoordinatesKey = @"EnableCalibrateMapCoordinates";

@implementation AppSettings

@synthesize enableCalibrateMapCoordinates = _enableCalibrateMapCoordinates;

+ (instancetype)sharedInstance {
    static AppSettings *sInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sInstance = [[AppSettings alloc] init];
    });
    return sInstance;
}

#pragma mark - get & set

- (BOOL)enableCalibrateMapCoordinates {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults objectForKey:kEnableCalibrateMapCoordinatesKey] != nil) {
        _enableCalibrateMapCoordinates = [[defaults objectForKey:kEnableCalibrateMapCoordinatesKey] boolValue];
    }
    else {
        NSBundle *mainBundle = [NSBundle mainBundle];
        NSString *language = [[mainBundle preferredLocalizations] objectAtIndex:0];
        if ([language isEqualToString:@"zh-Hans"]) {
            _enableCalibrateMapCoordinates = YES;
        }
        else {
            _enableCalibrateMapCoordinates = NO;
        }
    }
    return _enableCalibrateMapCoordinates;
}

- (void)setEnableCalibrateMapCoordinates:(BOOL)enableCalibrateMapCoordinates {
    _enableCalibrateMapCoordinates = enableCalibrateMapCoordinates;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:@(_enableCalibrateMapCoordinates) forKey:kEnableCalibrateMapCoordinatesKey];
    [defaults synchronize];
}
@end
