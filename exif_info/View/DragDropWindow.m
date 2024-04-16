//
//  DragDropWindow.m
//  ExifTools
//
//  Created by tbago on 2020/5/28.
//  Copyright © 2020 vxpen. All rights reserved.
//

#import "DragDropWindow.h"

@interface DragDropWindow() <NSDraggingDestination>

@end

@implementation DragDropWindow

- (void)awakeFromNib {
    [super awakeFromNib];
    [self registerForDraggedTypes:[NSArray arrayWithObjects:NSFilenamesPboardType, nil]];
}

- (NSDragOperation)draggingEntered:(id <NSDraggingInfo>)sender {
    // Need the delegate hooked up to accept the dragged item(s) into the model
    if (self.fileDelegate == nil) {
        return NSDragOperationNone;
    }

    if ([[[sender draggingPasteboard] types] containsObject:NSFilenamesPboardType]) {
        return NSDragOperationCopy;
    }

    return NSDragOperationNone;
}

// Stop the NSTableView implementation getting in the way
- (NSDragOperation)draggingUpdated:(id <NSDraggingInfo>)sender {
    return [self draggingEntered:sender];
}

- (BOOL)performDragOperation:(id <NSDraggingInfo>)sender {
    if(self.fileDelegate == nil) {
        return NO;
    }
    NSPasteboard *pboard;
    pboard = [sender draggingPasteboard];
    if ([[pboard types] containsObject:NSFilenamesPboardType]) {
        NSMutableArray *dragFileArray = [pboard propertyListForType:NSFilenamesPboardType];
        if(self.supportFileTypeArray.count > 0) {
            for(int32_t i =0 ;i < dragFileArray.count;) {
                NSString *pathExtension = [dragFileArray[i] pathExtension];
                if(![self.supportFileTypeArray containsObject:[pathExtension lowercaseString]]) {
                    [dragFileArray removeObjectAtIndex:i];
                }
                else {
                    i++;
                }
            }
        }
        if (dragFileArray.count == 0) {
            return NO;
        }
        [self.fileDelegate dragDropWindow:self didAddFile:dragFileArray];
        return YES;
    }
    return NO;
}

@end
