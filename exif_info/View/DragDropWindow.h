//
//  DragDropWindow.h
//  ExifTools
//
//  Created by tbago on 2020/5/28.
//  Copyright © 2020 vxpen. All rights reserved.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@protocol DragDropWindowDelegate <NSObject>

- (void)dragDropWindow:(NSWindow *) window didAddFile:(NSArray *) fileArray;

@end

@interface DragDropWindow : NSWindow

@property (strong, nonatomic) NSArray                              *supportFileTypeArray;
@property (weak, nonatomic, nullable) id<DragDropWindowDelegate>     fileDelegate;

@end

NS_ASSUME_NONNULL_END
