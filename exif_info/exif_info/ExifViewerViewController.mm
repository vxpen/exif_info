//
//  ExifViewerViewController.m
//  ExifTools
//
//  Created by tbago on 2020/5/22.
//  Copyright © 2020 vxpen. All rights reserved.
//

#import "ExifViewerViewController.h"
#include <exiv2/exiv2.hpp>
#include <iostream>

#import "TextTableCellView.h"
#import "DragDropWindow.h"
#import "BriefExifInfoViewController.h"
#import "DetailExifInfoViewController.h"
#import "ExifDataConverter.h"

@interface ExifViewerViewController ()<NSTableViewDataSource,
                                       NSTableViewDelegate,
                                       DragDropWindowDelegate>

@property (weak) DragDropWindow         *fatherWindow;
@property (weak) IBOutlet NSView        *sliderBackView;
@property (weak) IBOutlet NSButton      *briefExifSliderButton;
@property (weak) IBOutlet NSButton      *detailExifSliderButton;
@property (weak) IBOutlet NSView        *tipBackView;
@property (weak) IBOutlet NSView        *briefExifInfoView;
@property (weak) IBOutlet NSView        *detailExifInfoView;

@property (weak, nonatomic) BriefExifInfoViewController     *briefExifInfoViewController;
@property (weak, nonatomic) DetailExifInfoViewController    *detailExifInfoViewController;

@property (strong, nonatomic) NSString                      *inputFilePath;
@property (strong, nonatomic) NSMutableArray<ExifData *>    *exifDataArray;
@property (strong, nonatomic) NSArray                       *supporFileTypeArray;
@end

@implementation ExifViewerViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.sliderBackView.wantsLayer = YES;
    self.sliderBackView.layer.backgroundColor = [NSColor colorWithRed:62/255.0 green:69/255.0 blue:81/255.0 alpha:1.0].CGColor;
    self.sliderBackView.layer.borderWidth = 1.0;
    self.sliderBackView.layer.borderColor = [NSColor lightGrayColor].CGColor;

    self.briefExifSliderButton.state = NSControlStateValueOn;
    self.briefExifSliderButton.toolTip = @"Show brief exif info";
    self.detailExifSliderButton.toolTip = @"Show detail exif info";

    self.supporFileTypeArray = @[@"jpeg", @"jpg", @"dng", @"png", @"cr2"];
}

- (void)viewDidAppear {
    [super viewDidAppear];

    self.fatherWindow = (DragDropWindow *)self.view.window;
    self.fatherWindow.supportFileTypeArray = self.supporFileTypeArray;
    self.fatherWindow.fileDelegate = self;
}

- (void)prepareForSegue:(NSStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"BriefExifInfoSegue"]) {
        self.briefExifInfoViewController = segue.destinationController;
    }
    else if ([segue.identifier isEqualToString:@"DetailExifInfoSegue"]) {
        self.detailExifInfoViewController = segue.destinationController;
    }
}

#pragma mark - public method

- (void)openFile {
    NSOpenPanel *openPanel = [NSOpenPanel openPanel];

    [openPanel setPrompt: @"Select"];
    [openPanel setCanChooseFiles:YES];
    [openPanel setCanChooseDirectories:NO];
    [openPanel setCanCreateDirectories:NO];
    [openPanel setAllowsMultipleSelection:YES];

    [openPanel setAllowedFileTypes:self.supporFileTypeArray];
    NSModalResponse response = [openPanel runModal];
    if (response == NSModalResponseOK) {
        NSURL *selectFileUrl = [[openPanel URLs] firstObject];
        self.inputFilePath = selectFileUrl.absoluteString;
        [self loadFile];
    }
}

- (void)openFileWithName:(NSString *) fileName {
    self.inputFilePath = fileName;
    [self loadFile];
}

#pragma mark - action

- (IBAction)briefExifSliderButtonClick:(NSButton *)sender {
    self.briefExifSliderButton.state = NSControlStateValueOn;
    self.detailExifSliderButton.state = NSControlStateValueOff;
    if (self.exifDataArray.count > 0) {
        self.detailExifInfoView.hidden = YES;
        [self syncBriefExifInfo];
    }
}

- (IBAction)detailExifButtonClick:(NSButton *)sender {
    self.briefExifSliderButton.state = NSControlStateValueOff;
    self.detailExifSliderButton.state = NSControlStateValueOn;
    if (self.exifDataArray.count > 0) {
        self.briefExifInfoView.hidden = YES;
        [self syncDetailExifInfo];
    }
}

#pragma mark - DragDropWindowDelegate

- (void)dragDropWindow:(NSWindow *) window didAddFile:(NSArray *) fileArray {
    self.inputFilePath = [fileArray firstObject];

    [self loadFile];
}

#pragma mark - private method

- (void)loadFile {
    [self.exifDataArray removeAllObjects];
    Exiv2::Image::AutoPtr image = Exiv2::ImageFactory::open(self.inputFilePath.UTF8String);
    if (image.get() == NULL) {
        [self showAlertWithMessageAndInformativeText:@"Error" informativeText:@"Unsupport file format"];
        return;
    }

    image->readMetadata();
    Exiv2::ExifData &exifData = image->exifData();
    if (exifData.empty()) {
        [self showAlertWithMessageAndInformativeText:@"Info" informativeText:@"No Exif data found in file"];
        return;
    }

    for (Exiv2::ExifData::iterator i = exifData.begin(); i != exifData.end(); ++i)
    {
        ExifData *exifData = [ExifData initWithOriginName:i->key().c_str() originValue:i->value().toString().c_str()];
        if (exifData != nil) {
            [self.exifDataArray addObject:exifData];
        }

//        const char* tn = i->typeName();
//        std::cout << std::setw(44) << std::setfill(' ') << std::left
//                  << i->key() << " "
//                  << "0x" << std::setw(4) << std::setfill('0') << std::right
//                  << std::hex << i->tag() << " "
//                  << std::setw(9) << std::setfill(' ') << std::left
//                  << (tn ? tn : "Unknown") << " "
//                  << std::dec << std::setw(3)
//                  << std::setfill(' ') << std::right
//                  << i->count() << "  "
//                  << std::dec << i->value()
//                  << "\n";
    }
    
    [ExifDataConverter converterExifDataToReadable:self.exifDataArray];

    self.tipBackView.hidden = YES;
    if (self.briefExifSliderButton.state == NSControlStateValueOn) {
        [self syncBriefExifInfo];
    }
    else if (self.detailExifSliderButton.state == NSControlStateValueOn) {
        [self syncDetailExifInfo];
    }
}

- (void)syncBriefExifInfo {
    self.briefExifInfoViewController.manufacturer = nil;

    for (ExifData *exifData in self.exifDataArray) {
        if ([exifData.dataName isEqualToString:@"Manufacturer"]) {
            self.briefExifInfoViewController.manufacturer = exifData.dataValue;
        }
        else if ([exifData.dataName isEqualToString:@"Lens Make"]) {  ///< iPhone photo not have manufacturer
            if (self.briefExifInfoViewController.manufacturer == nil) {
                self.briefExifInfoViewController.manufacturer = exifData.dataValue;
            }
        }
        else if ([exifData.dataName isEqualToString:@"Model"]) {
            self.briefExifInfoViewController.model = exifData.dataValue;
        }
        else if ([exifData.dataName isEqualToString:@"Date and Time"]) {
            self.briefExifInfoViewController.dateTime = exifData.dataValue;
        }
        else if ([exifData.dataName isEqualToString:@"GPS Latitude"]) {
            self.briefExifInfoViewController.haveGPSInfo = YES;
            self.briefExifInfoViewController.latitude = [exifData.dataValue doubleValue];
        }
        else if ([exifData.dataName isEqualToString:@"GPS Longitude"]) {
            self.briefExifInfoViewController.longitude = [exifData.dataValue doubleValue];
        }
        else if ([exifData.dataName isEqualToString:@"GPS Altitude"]) {
            self.briefExifInfoViewController.altitude = exifData.dataValue;
        }

        else if ([exifData.dataName isEqualToString:@"Aperture"]) {
            self.briefExifInfoViewController.aperture = exifData.dataValue;
        }
        else if ([exifData.dataName isEqualToString:@"Exposure Mode"]) {
            self.briefExifInfoViewController.exposureMode = exifData.dataValue;
        }
        else if ([exifData.dataName isEqualToString:@"Exposure Program"]) {
            self.briefExifInfoViewController.exposureProgram = exifData.dataValue;
        }
        else if ([exifData.dataName isEqualToString:@"Exposure Time"]) {
            self.briefExifInfoViewController.exposureTime = exifData.dataValue;
        }
        else if ([exifData.dataName isEqualToString:@"Flash"]) {
            self.briefExifInfoViewController.flash = exifData.dataValue;
        }
        else if ([exifData.dataName isEqualToString:@"FNumber"]) {
            self.briefExifInfoViewController.fNumber = exifData.dataValue;
        }
        else if ([exifData.dataName isEqualToString:@"Focal Length"]) {
            self.briefExifInfoViewController.focalLength = exifData.dataValue;
        }
        else if ([exifData.dataName isEqualToString:@"ISO Speed Ratings"]) {
            self.briefExifInfoViewController.ISOSpeedRatings = exifData.dataValue;
        }
        else if ([exifData.dataName isEqualToString:@"Metering Mode"]) {
            self.briefExifInfoViewController.meteringMode = exifData.dataValue;
        }
        else if ([exifData.dataName isEqualToString:@"Shutter Speed"]) {
            self.briefExifInfoViewController.shutterSpeed = exifData.dataValue;
        }
        else if ([exifData.dataName isEqualToString:@"White Balance"]) {
            self.briefExifInfoViewController.whiteBalance = exifData.dataValue;
        }
    }

    [self.briefExifInfoViewController syncExifInfo];
    self.briefExifInfoView.hidden = NO;
}

- (void)syncDetailExifInfo {
    [self.detailExifInfoViewController setExifDataArray:self.exifDataArray];
    self.detailExifInfoView.hidden = NO;
}

- (void)showAlertWithMessageAndInformativeText:(NSString *) message
                               informativeText:(NSString *) informativeText
{
    NSAlert *alert = [[NSAlert alloc] init];
    [alert addButtonWithTitle:@"OK"];

    [alert setMessageText:message];
    [alert setInformativeText:informativeText];
    [alert beginSheetModalForWindow:self.view.window completionHandler:^(NSModalResponse returnCode) {
    }];
}

#pragma mark - get & set

- (NSMutableArray *)exifDataArray {
    if (_exifDataArray == nil) {
        _exifDataArray = [[NSMutableArray alloc] init];
    }
    return _exifDataArray;
}

@end
