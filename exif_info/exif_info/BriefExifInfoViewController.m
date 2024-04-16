//
//  BriefExifInfoViewController.m
//  ExifTools
//
//  Created by tbago on 2020/5/25.
//  Copyright © 2020 vxpen. All rights reserved.
//

#import "BriefExifInfoViewController.h"
#import <MapKit/MapKit.h>
#import "AppSettings.h"
#import "MapPhotoAnnotation.h"
#import "LocationConverter.h"

static const CLLocationDegrees kCoordinateSpanDefaultValue = 0.003;
static NSString *const kPhotoLocationIdentifier = @"PhotoLocationIdentifier";

@interface BriefExifInfoViewController () <MKMapViewDelegate>
@property (weak) IBOutlet NSScrollView *fatherScrollView;
@property (weak) IBOutlet NSView        *contentView;
@property (weak) IBOutlet NSView        *leftBorderView;

@property (weak) IBOutlet NSView        *imageHeaderBackView;
@property (weak) IBOutlet NSView        *gpsInfoHeaderBackView;
@property (weak) IBOutlet NSView        *photographHeaderBackView;


@property (weak) IBOutlet NSTextField   *dateTimeTextField;
@property (weak) IBOutlet NSTextField   *manufacturerValueTextField;
@property (weak) IBOutlet NSTextField   *modelValueTextField;
@property (weak) IBOutlet NSTextField   *latitudeValueTextField;
@property (weak) IBOutlet NSTextField   *longitudeValueTextField;
@property (weak) IBOutlet NSTextField   *altitudeTextField;
@property (weak) IBOutlet NSTextField   *locationTextField;
@property (weak) IBOutlet MKMapView     *mapView;

@property (strong ,nonatomic) MapPhotoAnnotation    *photoAnnotation;

@property (weak) IBOutlet NSTextField       *apertureTextField;
@property (weak) IBOutlet NSTextField       *exposureModeTextField;
@property (weak) IBOutlet NSTextField       *exposureProgramTextField;
@property (weak) IBOutlet NSTextField       *exposureTimeTextField;
@property (weak) IBOutlet NSTextField       *flashTextField;
@property (weak) IBOutlet NSTextField       *fNumberTextField;
@property (weak) IBOutlet NSTextField       *focalLengthTextField;
@property (weak) IBOutlet NSTextField       *ISOSpeedRatingsTextField;
@property (weak) IBOutlet NSTextField       *meteringModeTextField;
@property (weak) IBOutlet NSTextField       *shutterSpeedTextField;
@property (weak) IBOutlet NSTextField       *whiteBalanceTextField;

@end

@implementation BriefExifInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    CGColorRef headerBackView = [NSColor colorWithRed:95/255.0 green:148/255.0 blue:220/255.0 alpha:1.0].CGColor;

    self.imageHeaderBackView.wantsLayer = YES;
    self.imageHeaderBackView.layer.backgroundColor = headerBackView;
    self.gpsInfoHeaderBackView.wantsLayer = YES;
    self.gpsInfoHeaderBackView.layer.backgroundColor = headerBackView;
    self.photographHeaderBackView.wantsLayer =  YES;
    self.photographHeaderBackView.layer.backgroundColor = headerBackView;

    self.leftBorderView.wantsLayer = YES;
    self.leftBorderView.layer.backgroundColor = [NSColor whiteColor].CGColor;

    self.mapView.delegate = self;

    self.fatherScrollView.documentView = self.contentView;
}

- (void)syncExifInfo {
    if (self.dateTime != nil) {
        self.dateTimeTextField.stringValue              = self.dateTime;
    }
    else {
        self.dateTimeTextField.stringValue = @"";
    }

    if (self.manufacturer != nil) {
        self.manufacturerValueTextField.stringValue     = self.manufacturer;
    }
    else {
        self.manufacturerValueTextField.stringValue = @"";
    }

    if (self.model != nil) {
        self.modelValueTextField.stringValue            = self.model;
    }
    else {
        self.modelValueTextField.stringValue    = @"";
    }

    if (!self.haveGPSInfo) {
        self.latitudeValueTextField.stringValue     = @"";
        self.longitudeValueTextField.stringValue    = @"";
        self.altitudeTextField.stringValue          = @"";
    }
    else {
        self.latitudeValueTextField.stringValue     = [NSString stringWithFormat:@"%f", self.latitude];
        self.longitudeValueTextField.stringValue    = [NSString stringWithFormat:@"%f", self.longitude];
        self.altitudeTextField.stringValue          = self.altitude;

        CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(self.latitude, self.longitude);
        if ([AppSettings sharedInstance].enableCalibrateMapCoordinates) {
            coordinate = [LocationConverter transformFromWGSToGCJ:coordinate];
        }
        MKCoordinateRegion regin = self.mapView.region;
        regin.center = coordinate;
        regin = MKCoordinateRegionMake(regin.center, MKCoordinateSpanMake(kCoordinateSpanDefaultValue, kCoordinateSpanDefaultValue));
        [self.mapView setRegion:regin animated:YES];

        if (self.photoAnnotation == nil) {
            self.photoAnnotation = [[MapPhotoAnnotation alloc] init];
            self.photoAnnotation.coordinate = coordinate;
            [self.mapView addAnnotation:self.photoAnnotation];
        }
        else {
            self.photoAnnotation.coordinate = coordinate;
        }

        [self getLocationByLatitude:coordinate.latitude longitude:coordinate.longitude complate:^(NSString *locationValue) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.locationTextField.stringValue = locationValue;
            });
        }];
    }
    if (self.aperture != nil) {
        self.apertureTextField.stringValue              = self.aperture;
    }
    else {
        self.apertureTextField.stringValue  = @"";
    }

    if (self.exposureMode != nil) {
        self.exposureModeTextField.stringValue          = self.exposureMode;
    }
    else {
        self.exposureModeTextField.stringValue  = @"";
    }

    if (self.exposureProgram != nil) {
        self.exposureProgramTextField.stringValue       = self.exposureProgram;
    }
    else {
        self.exposureProgramTextField.stringValue   = @"";
    }

    if (self.exposureTime != nil) {
        self.exposureTimeTextField.stringValue          = self.exposureTime;
    }
    else {
        self.exposureTimeTextField.stringValue          = @"";
    }

    if (self.flash != nil) {
        self.flashTextField.stringValue                 = self.flash;
    }
    else {
        self.flashTextField.stringValue = @"";
    }

    if (self.fNumber != nil) {
        self.fNumberTextField.stringValue               = self.fNumber;
    }
    else {
        self.fNumberTextField.stringValue = @"";
    }

    if (self.focalLength != nil) {
        self.focalLengthTextField.stringValue           = self.focalLength;
    }
    else {
        self.focalLengthTextField.stringValue = @"";
    }

    if (self.ISOSpeedRatings != nil) {
        self.ISOSpeedRatingsTextField.stringValue       = self.ISOSpeedRatings;
    }
    else {
        self.ISOSpeedRatingsTextField.stringValue = @"";
    }

    if (self.meteringMode != nil) {
        self.meteringModeTextField.stringValue          = self.meteringMode;
    }
    else {
        self.meteringModeTextField.stringValue = @"";
    }

    if (self.shutterSpeed != nil) {
        self.shutterSpeedTextField.stringValue          = self.shutterSpeed;
    }
    else {
        self.shutterSpeedTextField.stringValue = @"";
    }

    if (self.whiteBalance != nil) {
        self.whiteBalanceTextField.stringValue          = self.whiteBalance;
    }
    else {
        self.whiteBalanceTextField.stringValue = @"";
    }
}


#pragma mark - MKMapViewDelegate

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    if ([annotation isKindOfClass:[MapPhotoAnnotation class]]) {
        MKAnnotationView *av = [mapView dequeueReusableAnnotationViewWithIdentifier:kPhotoLocationIdentifier];
        if (av == nil) {
            av = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:kPhotoLocationIdentifier];
        } else {
            av.annotation = annotation;
        }
        av.image = [NSImage imageNamed:@"map_photo_position"];
        return av;
    }
    return nil;
}

#pragma mark - helper method

- (void)getLocationByLatitude:(double) latitude
                    longitude:(double) longitude
                     complate:(void(^)(NSString *locationValue)) complate {
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    CLLocation *currentLocation = [[CLLocation alloc] initWithLatitude:latitude longitude:longitude];

    __block BOOL getLocation = NO;
    [geocoder reverseGeocodeLocation:currentLocation completionHandler:^(NSArray *array, NSError *error) {
        getLocation = YES;
        if (array.count > 0) {
            CLPlacemark *placemark = [array objectAtIndex:0];
            NSString *city = placemark.locality;
            NSString *subCity = placemark.subLocality;
            NSString *name = placemark.name;
            NSString *thoroughfare = placemark.thoroughfare;
//            NSString *administrativeArea = placemark.administrativeArea;
            NSString *resultString = [[NSString alloc] init];
            if (name != nil) {
                resultString = [resultString stringByAppendingString:name];
            }
            else if (thoroughfare != nil) {
                resultString = [resultString stringByAppendingString:thoroughfare];
            }

            if (subCity != nil) {
                resultString = [resultString stringByAppendingString:@", "];
                resultString = [resultString stringByAppendingString:subCity];
            }
            if (city != nil) {
                resultString = [resultString stringByAppendingString:@", "];
                resultString = [resultString stringByAppendingString:city];
            }
//            if (administrativeArea != nil) {
//                resultString = [resultString stringByAppendingString:@", "];
//                resultString = [resultString stringByAppendingString:administrativeArea];
//            }
            complate(resultString);
        }
        else if (error == nil && [array count] == 0) {
            complate(@"Unknown");
        }
        else if (error != nil) {
            complate(@"Unknown");
        }
    }];

    ///< 八秒后如果没有获取到地里位置，则认为网络超时
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 8*NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        if (!getLocation) {
            [geocoder cancelGeocode];
            complate(@"Unknown");;
        }
    });
}
@end
