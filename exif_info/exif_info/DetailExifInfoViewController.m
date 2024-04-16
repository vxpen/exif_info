//
//  DetailExifInfoViewController.m
//  ExifTools
//
//  Created by tbago on 2020/5/28.
//  Copyright © 2020 vxpen. All rights reserved.
//

#import "DetailExifInfoViewController.h"
#import "ExifData.h"
#import "TextTableCellView.h"

@interface DetailExifInfoViewController()<NSTableViewDataSource,
                                          NSTableViewDelegate>

@property (weak) IBOutlet NSTableView   *tableView;
@property (strong, nonatomic) NSArray   *exifDataArray;

@end

@implementation DetailExifInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.tableView.dataSource = self;
    self.tableView.delegate = self;
}

#pragma mark - public method

- (void)setExifDataArray:(NSArray *) exifDataArray {
    _exifDataArray = exifDataArray;

    [self.tableView reloadData];
}

#pragma mark - NSTableView datasource & delegate

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return self.exifDataArray.count;
}

- (NSView *)tableView:(NSTableView *)tableView
   viewForTableColumn:(NSTableColumn *)tableColumn
                  row:(NSInteger)row {
    NSString *identifier = [tableColumn identifier];
    ExifData *exifData = self.exifDataArray[row];
    if ([identifier isEqualToString:@"TypeNameTableColumn"]) {
        TextTableCellView *cellView = [tableView makeViewWithIdentifier:identifier owner:self];
        cellView.titleTextField.stringValue = exifData.dataName;
        cellView.titleTextField.toolTip = exifData.dataDescription;
        return cellView;
    }
    else if ([identifier isEqualToString:@"TypeValueTableColumn"]) {
        TextTableCellView *cellView = [tableView makeViewWithIdentifier:identifier owner:self];
        cellView.titleTextField.stringValue = exifData.dataValue;
        return cellView;
    }
    return nil;
}

@end
