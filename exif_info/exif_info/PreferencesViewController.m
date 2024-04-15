//
//  PreferencesViewController.m
//  ExifTools
//
//  Created by tbago on 2020/5/28.
//  Copyright © 2020 vxpen. All rights reserved.
//

#import "PreferencesViewController.h"
#import "AppSettings.h"

@interface PreferencesViewController ()

@property (weak) IBOutlet NSButton *calibrateMapCoordinatesButton;

@end

@implementation PreferencesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.calibrateMapCoordinatesButton.state = [AppSettings sharedInstance].enableCalibrateMapCoordinates;
}

#pragma mark - action

- (IBAction)calibrateMapCoordinatesButtonClick:(NSButton *)sender {
    [AppSettings sharedInstance].enableCalibrateMapCoordinates = sender.state;
}

@end
