//
//  TextTableCellView.h
//  video_wrapper
//
//  Created by tbago on 2020/4/20.
//  Copyright © 2020 tbago. All rights reserved.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface TextTableCellView : NSTableCellView

@property (weak) IBOutlet NSTextField *titleTextField;

@end

NS_ASSUME_NONNULL_END
