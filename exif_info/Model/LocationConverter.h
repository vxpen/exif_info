//
//  LocationConverter.h
//  ExifTools
//
//  Created by tbago on 2020/5/26.
//  Copyright © 2020 vxpen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

NS_ASSUME_NONNULL_BEGIN

@interface LocationConverter : NSObject

/**
 *  将WGS-84转为GCJ-02(火星坐标)
 */
+ (CLLocationCoordinate2D)transformFromWGSToGCJ:(CLLocationCoordinate2D) wgsLocation;

/**
 *  将GCJ-02(火星坐标)转为WGS-84:
 */
+ (CLLocationCoordinate2D)transformFromGCJToWGS:(CLLocationCoordinate2D) gcjLocation;

@end

NS_ASSUME_NONNULL_END
