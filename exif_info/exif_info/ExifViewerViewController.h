//
//  ExifViewerViewController.h
//  ExifTools
//
//  Created by tbago on 2020/5/22.
//  Copyright © 2020 vxpen. All rights reserved.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface ExifViewerViewController : NSViewController

- (void)openFile;

- (void)openFileWithName:(NSString *) fileName;

@end

NS_ASSUME_NONNULL_END
