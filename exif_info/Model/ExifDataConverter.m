//
//  ExifDataConverter.m
//  ExifTools
//
//  Created by tbago on 2020/5/25.
//  Copyright © 2020 vxpen. All rights reserved.
//

#import "ExifDataConverter.h"

@implementation ExifDataConverter

+ (void)converterExifDataToReadable:(NSArray *) exifDataArray {
    BOOL northLatitude = NO;
    BOOL eastLongitude = NO;
    BOOL aboveSeaLevel = YES;
    for (ExifData *exifData in exifDataArray)
    {
        if ([exifData.dataName isEqualToString:@"GPS Latitude Reference"]) {
            if ([exifData.dataValue isEqualToString:@"N"]) {
                northLatitude = YES;
            }
        }
        else if ([exifData.dataName isEqualToString:@"GPS Latitude"]) {
            NSArray *splitArray = [exifData.dataValue componentsSeparatedByString:@" "];
            if (splitArray.count == 3) {
                NSString *ddString = splitArray[0];
                NSArray *ddSplitArray = [ddString componentsSeparatedByString:@"/"];
                NSInteger ddValue = [ddSplitArray[0] integerValue];

                NSString *mmString = splitArray[1];
                NSArray *mmSplitArray = [mmString componentsSeparatedByString:@"/"];
                NSInteger mmValue = [mmSplitArray[0] integerValue];

                NSString *ssString = splitArray[2];
                NSArray *ssSplitArray =  [ssString componentsSeparatedByString:@"/"];
                double ssValue = [ssSplitArray[0] doubleValue]/ [ssSplitArray[1] doubleValue];
                double latitude = ddValue + mmValue/60.0 + ssValue/3600.0;
                if (northLatitude) {
                    exifData.dataValue = [NSString stringWithFormat:@"%lf", latitude];
                }
                else {
                    exifData.dataValue = [NSString stringWithFormat:@"%lf", -1*latitude];
                }
            }
        }
        else if ([exifData.dataName isEqualToString:@"GPS Longitude Reference"]) {
            if ([exifData.dataValue isEqualToString:@"E"]) {
                eastLongitude = YES;
            }
        }
        else if ([exifData.dataName isEqualToString:@"GPS Longitude"]) {
            NSArray *splitArray = [exifData.dataValue componentsSeparatedByString:@" "];
            if (splitArray.count == 3) {
                NSString *ddString = splitArray[0];
                NSArray *ddSplitArray = [ddString componentsSeparatedByString:@"/"];
                NSInteger ddValue = [ddSplitArray[0] integerValue];

                NSString *mmString = splitArray[1];
                NSArray *mmSplitArray = [mmString componentsSeparatedByString:@"/"];
                NSInteger mmValue = [mmSplitArray[0] doubleValue];

                NSString *ssString = splitArray[2];
                NSArray *ssSplitArray =  [ssString componentsSeparatedByString:@"/"];
                double ssValue = [ssSplitArray[0] doubleValue] / [ssSplitArray[1] doubleValue];

                double longitude = ddValue + mmValue/60.0 + ssValue/3600.0;
                if (eastLongitude) {
                    exifData.dataValue = [NSString stringWithFormat:@"%lf", longitude];
                }
                else {
                    exifData.dataValue = [NSString stringWithFormat:@"%lf", -1*longitude];
                }
            }
        }
        else if ([exifData.dataName isEqualToString:@"GPS Altitude Reference"]) {
            if ([exifData.dataValue integerValue] == 1) {
                aboveSeaLevel = NO;
            }
        }
        else if ([exifData.dataName isEqualToString:@"GPS Altitude"]) {
            NSString *valueString = exifData.dataValue;
            NSArray *splitArray = [valueString componentsSeparatedByString:@"/"];
            if (splitArray.count == 2) {
                double numerator = [splitArray[0] doubleValue];
                double denominator = [splitArray[1] doubleValue];
                if (!aboveSeaLevel) {
                    exifData.dataValue = [NSString stringWithFormat:@"%.2f m", -1*numerator/denominator];
                }
                else {
                    exifData.dataValue = [NSString stringWithFormat:@"%.2f m", numerator/denominator];
                }
            }
        }

        else if ([exifData.dataName isEqualToString:@"Aperture"]) {
//            NSString *valueString = exifData.dataValue;
//            NSArray *splitArray = [valueString componentsSeparatedByString:@"/"];
//            if (splitArray.count == 2) {
//                double numerator = [splitArray[0] doubleValue];
//                double denominator = [splitArray[1] doubleValue];
//                exifData.dataValue = [NSString stringWithFormat:@"%.1f", numerator/denominator];
//            }
        }
        else if ([exifData.dataName isEqualToString:@"Exposure Bias"]) {
            NSString *valueString = exifData.dataValue;
            NSArray *splitArray = [valueString componentsSeparatedByString:@"/"];
            if (splitArray.count == 2) {
                NSInteger numerator = [splitArray[0] integerValue];
                NSInteger denominator = [splitArray[1] integerValue];
                exifData.dataValue = [NSString stringWithFormat:@"%zd EV", numerator/denominator];
            }
        }
        else if ([exifData.dataName isEqualToString:@"Exposure Mode"]) {
            NSInteger valueInteger = [exifData.dataValue integerValue];
            if (valueInteger == 0) {
                exifData.dataValue = @"Auto";
            }
            else if (valueInteger == 1) {
                exifData.dataValue = @"Manual";
            }
            else if (valueInteger == 2) {
                exifData.dataValue = @"Auto Bracketing";
            }
        }
        else if ([exifData.dataName isEqualToString:@"Exposure Program"]) {
            NSInteger valueInteger = [exifData.dataValue integerValue];
            switch (valueInteger) {
                case 0:
                    exifData.dataValue = @"Not defined";
                    break;
                case 1:
                    exifData.dataValue = @"Manual";
                    break;
                case 2:
                    exifData.dataValue = @"Auto";
                    break;
                case 3:
                    exifData.dataValue = @"Aperture priority";
                    break;
                case 4:
                    exifData.dataValue = @"Shutter priority";
                    break;
                case 5:
                    exifData.dataValue = @"Creative program";
                    break;
                case 6:
                    exifData.dataValue = @"Action program";
                    break;
                case 7:
                    exifData.dataValue = @"Portrait mode";
                    break;
                case 8:
                    exifData.dataValue = @"Landscape mode";
                    break;
            }
        }
        else if ([exifData.dataName isEqualToString:@"Exif Version"]) {
            NSString *valueString = exifData.dataValue;
            NSArray *splitArray = [valueString componentsSeparatedByString:@" "];
            if(splitArray.count == 4) {
                char version1 = (char)[splitArray[0] integerValue];
                char version2 = (char)[splitArray[1] integerValue];
                char version3 = (char)[splitArray[2] integerValue];
                char version4 = (char)[splitArray[3] integerValue];
                if (version1 == '0') {
                    exifData.dataValue = [NSString stringWithFormat:@"%c.%c%c", version2, version3, version4];
                }
                else {
                    exifData.dataValue = [NSString stringWithFormat:@"%c%c.%c%c", version1, version2, version3, version4];
                }
            }
        }
        else if ([exifData.dataName isEqualToString:@"Exposure Time"]) {
            exifData.dataValue = [exifData.dataValue stringByAppendingString:@" s"];
        }
        else if ([exifData.dataName isEqualToString:@"Flash"]) {
            NSInteger integerValue = [exifData.dataValue integerValue];
            if (integerValue == 0x00) {
                exifData.dataValue = @"Did not fire";
            }
            else if (integerValue == 0x01) {
                exifData.dataValue = @"Fired";
            }
            else if (integerValue == 0x05) {
                exifData.dataValue = @"Strobe return light not detected";
            }
            else if (integerValue == 0x07) {
                exifData.dataValue = @"Strobe return light detected";
            }
            else if (integerValue == 0x09) {
                exifData.dataValue = @"Fired, compulsory flash mode";
            }
            else if (integerValue == 0x0D) {
                exifData.dataValue = @"Fired, compulsory flash mode, return light not detected";
            }
            else if (integerValue == 0x0F) {
                exifData.dataValue = @"Fired, compulsory flash mode, return light detected";
            }
            else if (integerValue == 0x10) {
                exifData.dataValue = @"Not fire, compulsory flash mode";
            }
            else if (integerValue == 0x18) {
                exifData.dataValue = @"Not fire, auto mode";
            }
            else if (integerValue == 0x19) {
                exifData.dataValue = @"Fired, auto mode";
            }
            else if (integerValue == 0x1D) {
                exifData.dataValue = @"Fired, auto mode, return light not detected";
            }
            else if (integerValue == 0x0F) {
                exifData.dataValue = @"Fired, auto mode, return light detected";
            }
            else if (integerValue == 0x20) {
                exifData.dataValue = @"No flash function";
            }
            else if (integerValue == 0x41) {
                exifData.dataValue = @"Fired, red-eye reduction mode";
            }
            else if (integerValue == 0x45) {
                exifData.dataValue = @"Fired, red-eye reduction mode, return light not detected";
            }
            else if (integerValue == 0x47) {
                exifData.dataValue = @"Fired, red-eye reduction mode, return light detected";
            }
            else if (integerValue == 0x49) {
                exifData.dataValue = @"Fired, compulsory flash mode, red-eye reduction mode";
            }
            else if (integerValue == 0x4d) {
                exifData.dataValue = @"Fired, compulsory flash mode, red-eye reduction mode, return light not detected";
            }
            else if (integerValue == 0x4f) {
                exifData.dataValue = @"Fired, compulsory flash mode, red-eye reduction mode, return light detected";
            }
            else if (integerValue == 0x59) {
                exifData.dataValue = @"Fired, auto mode, red-eye reduction mode";
            }
            else if (integerValue == 0x5d) {
                exifData.dataValue = @"Fired, auto mode, return light not detected, red-eye reduction mode";
            }
            else if (integerValue == 0x5f) {
                exifData.dataValue = @"Fired, auto mode, return light detected, red-eye reduction mode";
            }
        }
        else if ([exifData.dataName isEqualToString:@"FNumber"]) {
            NSString *valueString = exifData.dataValue;
            NSArray *splitArray = [valueString componentsSeparatedByString:@"/"];
            if (splitArray.count == 2) {
                double numerator = [splitArray[0] doubleValue];
                double denominator = [splitArray[1] doubleValue];
                exifData.dataValue = [NSString stringWithFormat:@"F %.1f", numerator/denominator];
            }
        }
        else if ([exifData.dataName isEqualToString:@"Focal Length"]) {
            NSString *valueString = exifData.dataValue;
            NSArray *splitArray = [valueString componentsSeparatedByString:@"/"];
            if (splitArray.count == 2) {
                double numerator = [splitArray[0] doubleValue];
                double denominator = [splitArray[1] doubleValue];
                exifData.dataValue = [NSString stringWithFormat:@"%.2f mm", numerator/denominator];
            }
        }
        else if ([exifData.dataName isEqualToString:@"Metering Mode"]) {
            NSInteger integerValue = [exifData.dataValue integerValue];
            switch (integerValue) {
                case 0:
                    exifData.dataValue = @"Unknown";
                    break;
                case 1:
                    exifData.dataValue = @"Average";
                    break;
                case 2:
                    exifData.dataValue = @"CenterWeightedAverage";
                    break;
                case 3:
                    exifData.dataValue = @"Spot";
                case 4:
                    exifData.dataValue = @"MultiSpot";
                    break;
                case 5:
                    exifData.dataValue = @"Pattern";
                    break;
                case 6:
                    exifData.dataValue = @"Partial";
                    break;
                case 255:
                    exifData.dataValue = @"Other";
                    break;
            }
        }
        else if ([exifData.dataName isEqualToString:@"Shutter Speed"]) {
            exifData.dataValue = [exifData.dataValue stringByAppendingString:@" s"];
        }
        else if ([exifData.dataName isEqualToString:@"White Balance"]) {
            NSInteger dataValue = [exifData.dataValue integerValue];
            if (dataValue == 0) {
                exifData.dataValue = @"Auto";
            }
            else if (dataValue == 1) {
                exifData.dataValue = @"Manual";
            }
        }
    }
}

@end
