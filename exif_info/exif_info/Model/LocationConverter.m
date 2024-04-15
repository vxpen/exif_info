//
//  LocationConverter.m
//  ExifTools
//
//  Created by tbago on 2020/5/26.
//  Copyright © 2020 vxpen. All rights reserved.
//

#import "LocationConverter.h"
#import <math.h>
//#import <UIKit/UIGeometry.h>

static const double a = 6378245.0;
static const double ee = 0.00669342162296594323;
//static const double pi = 3.14159265358979324;

@implementation LocationConverter

#pragma mark - public method

+ (CLLocationCoordinate2D)transformFromWGSToGCJ:(CLLocationCoordinate2D) wgsLocation {
    CLLocationCoordinate2D adjustLoc;
    double adjustLat = [self transformLatWithX:wgsLocation.longitude - 105.0 withY:wgsLocation.latitude - 35.0];
    double adjustLon = [self transformLonWithX:wgsLocation.longitude - 105.0 withY:wgsLocation.latitude - 35.0];
    long double radLat = wgsLocation.latitude / 180.0 * pi;
    long double magic = sin(radLat);
    magic = 1 - ee * magic * magic;
    long double sqrtMagic = sqrt(magic);
    adjustLat = (adjustLat * 180.0) / ((a * (1 - ee)) / (magic * sqrtMagic) * pi);
    adjustLon = (adjustLon * 180.0) / (a / sqrtMagic * cos(radLat) * pi);
    adjustLoc.latitude = wgsLocation.latitude + adjustLat;
    adjustLoc.longitude = wgsLocation.longitude + adjustLon;

    return adjustLoc;
}

+(CLLocationCoordinate2D)transformFromGCJToWGS:(CLLocationCoordinate2D) gcjLocation
{
    double threshold = 0.00001;

    // The boundary
    double minLat = gcjLocation.latitude - 0.5;
    double maxLat = gcjLocation.latitude + 0.5;
    double minLng = gcjLocation.longitude - 0.5;
    double maxLng = gcjLocation.longitude + 0.5;

    double delta = 1;
    int maxIteration = 30;
    // Binary search
    while(true)
    {
        CLLocationCoordinate2D leftBottom  = [[self class] transformFromWGSToGCJ:(CLLocationCoordinate2D){.latitude = minLat,.longitude = minLng}];
        CLLocationCoordinate2D rightBottom = [[self class] transformFromWGSToGCJ:(CLLocationCoordinate2D){.latitude = minLat,.longitude = maxLng}];
        CLLocationCoordinate2D leftUp      = [[self class] transformFromWGSToGCJ:(CLLocationCoordinate2D){.latitude = maxLat,.longitude = minLng}];
        CLLocationCoordinate2D midPoint    = [[self class] transformFromWGSToGCJ:(CLLocationCoordinate2D){.latitude = ((minLat + maxLat) / 2),.longitude = ((minLng + maxLng) / 2)}];
        delta = fabs(midPoint.latitude - gcjLocation.latitude) + fabs(midPoint.longitude - gcjLocation.longitude);

        if(maxIteration-- <= 0 || delta <= threshold)
        {
            return (CLLocationCoordinate2D){.latitude = ((minLat + maxLat) / 2),.longitude = ((minLng + maxLng) / 2)};
        }

        if(isContains(gcjLocation, leftBottom, midPoint))
        {
            maxLat = (minLat + maxLat) / 2;
            maxLng = (minLng + maxLng) / 2;
        }
        else if(isContains(gcjLocation, rightBottom, midPoint))
        {
            maxLat = (minLat + maxLat) / 2;
            minLng = (minLng + maxLng) / 2;
        }
        else if(isContains(gcjLocation, leftUp, midPoint))
        {
            minLat = (minLat + maxLat) / 2;
            maxLng = (minLng + maxLng) / 2;
        }
        else
        {
            minLat = (minLat + maxLat) / 2;
            minLng = (minLng + maxLng) / 2;
        }
    }

}

#pragma mark - private method

+ (double)transformLatWithX:(double)x withY:(double)y
{
    double lat = -100.0 + 2.0 * x + 3.0 * y + 0.2 * y * y + 0.1 * x * y + 0.2 * sqrt(fabs(x));

    lat += (20.0 * sin(6.0 * x * pi) + 20.0 *sin(2.0 * x * pi)) * 2.0 / 3.0;
    lat += (20.0 * sin(y * pi) + 40.0 * sin(y / 3.0 * pi)) * 2.0 / 3.0;
    lat += (160.0 * sin(y / 12.0 * pi) + 320 * sin(y * pi / 30.0)) * 2.0 / 3.0;
    return lat;
}

+ (double)transformLonWithX:(double)x withY:(double)y
{
    double lon = 300.0 + x + 2.0 * y + 0.1 * x * x + 0.1 * x * y + 0.1 * sqrt(fabs(x));
    lon += (20.0 * sin(6.0 * x * pi) + 20.0 * sin(2.0 * x * pi)) * 2.0 / 3.0;
    lon += (20.0 * sin(x * pi) + 40.0 * sin(x / 3.0 * pi)) * 2.0 / 3.0;
    lon += (150.0 * sin(x / 12.0 * pi) + 300.0 * sin(x / 30.0 * pi)) * 2.0 / 3.0;
    return lon;
}

static bool isContains(CLLocationCoordinate2D point, CLLocationCoordinate2D p1, CLLocationCoordinate2D p2)
{
    return (point.latitude >= MIN(p1.latitude, p2.latitude) && point.latitude <= MAX(p1.latitude, p2.latitude)) && (point.longitude >= MIN(p1.longitude,p2.longitude) && point.longitude <= MAX(p1.longitude, p2.longitude));
}

@end
