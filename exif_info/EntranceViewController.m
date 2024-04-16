//
//  EntranceViewController.m
//  ExifTools
//
//  Created by tbago on 2020/5/22.
//  Copyright © 2020 vxpen. All rights reserved.
//

#import "EntranceViewController.h"

@implementation EntranceViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // Do any additional setup after loading the view.
}

#pragma mark - action

- (IBAction)exifViewerButtonClick:(NSButton *)sender {
    NSWindowController *exifViewerWindowController = [self.storyboard instantiateControllerWithIdentifier:@"ExifViewerWindowController"];

    [self.view.window close];
    [exifViewerWindowController showWindow:nil];
}

@end
