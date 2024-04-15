//
//  MapPhotoAnnotation.h
//  ExifTools
//
//  Created by tbago on 2020/5/26.
//  Copyright © 2020 vxpen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MapPhotoAnnotation : NSObject<MKAnnotation>

@property (nonatomic, readwrite) CLLocationCoordinate2D coordinate;
@property (nonatomic, readwrite, copy, nullable) NSString *title;
@property (nonatomic, readwrite, copy, nullable) NSString *subtitle;

@end

NS_ASSUME_NONNULL_END
