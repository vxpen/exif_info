//
//  DragDropView.h
//  ExifTools
//
//  Created by tbago on 2020/5/25.
//  Copyright © 2020 vxpen. All rights reserved.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@protocol DragDropViewDelegate <NSObject>

- (void)dragDropView:(NSView *) dragDropView didAddFile:(NSArray *) fileArray;

@end

@interface DragDropView : NSView

@property (strong, nonatomic) NSArray                              *supportFileTypeArray;
@property (weak, nonatomic, nullable) id<DragDropViewDelegate>     fileDelegate;

@end

NS_ASSUME_NONNULL_END
