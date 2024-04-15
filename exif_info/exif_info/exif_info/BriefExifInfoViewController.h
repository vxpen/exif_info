//
//  BriefExifInfoViewController.h
//  ExifTools
//
//  Created by tbago on 2020/5/25.
//  Copyright © 2020 vxpen. All rights reserved.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface BriefExifInfoViewController : NSViewController

@property (copy ,nonatomic) NSString                    *dateTime;
@property (copy, nonatomic, nullable) NSString          *manufacturer;
@property (copy, nonatomic) NSString                    *model;
@property (assign, nonatomic) BOOL                      haveGPSInfo;
@property (assign, nonatomic) double                    latitude;
@property (assign, nonatomic) double                    longitude;
@property (copy, nonatomic) NSString                    *altitude;

@property (copy, nonatomic) NSString                    *aperture;
@property (copy, nonatomic) NSString                    *exposureMode;
@property (copy, nonatomic) NSString                    *exposureProgram;
@property (copy, nonatomic) NSString                    *exposureTime;
@property (copy, nonatomic) NSString                    *flash;
@property (copy, nonatomic) NSString                    *fNumber;
@property (copy, nonatomic) NSString                    *focalLength;
@property (copy, nonatomic) NSString                    *ISOSpeedRatings;
@property (copy, nonatomic) NSString                    *meteringMode;
@property (copy, nonatomic) NSString                    *shutterSpeed;
@property (copy, nonatomic) NSString                    *whiteBalance;

- (void)syncExifInfo;

@end

NS_ASSUME_NONNULL_END
