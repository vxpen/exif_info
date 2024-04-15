//
//  AppSettings.h
//  ExifTools
//
//  Created by tbago on 2020/5/28.
//  Copyright © 2020 vxpen. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface AppSettings : NSObject

+ (instancetype)sharedInstance;

@property (assign, nonatomic) BOOL  enableCalibrateMapCoordinates;

@end

NS_ASSUME_NONNULL_END
