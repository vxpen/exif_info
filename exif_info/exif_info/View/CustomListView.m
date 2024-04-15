//
//  CustomListView.m
//  ExifTools
//
//  Created by tbago on 2020/5/25.
//  Copyright © 2020 vxpen. All rights reserved.
//

#import "CustomListView.h"

static const NSInteger kTextHeight = 16;
static const NSInteger kStartTextPosition = 10;
static const NSInteger kTextSpace = 20;

@implementation CustomListView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    NSColor *lineColor = [NSColor whiteColor];
    [lineColor setStroke];
    NSBezierPath *path = [NSBezierPath bezierPath];
    path.lineWidth = 1;

    NSPoint startPoint = {0, 0};
    NSPoint endPoint = {0, self.bounds.size.height};
    [path moveToPoint:startPoint];
    [path lineToPoint:endPoint];
    [path stroke];

    startPoint = CGPointMake(0, self.bounds.size.height - (kStartTextPosition + kTextHeight*0.5));
    endPoint = CGPointMake(self.bounds.size.width, startPoint.y);
    [path moveToPoint:startPoint];
    [path lineToPoint:endPoint];
    [path stroke];

    for (NSInteger i = 1; i < self.listCount - 1; i++) {
        startPoint = CGPointMake(0, self.bounds.size.height - kStartTextPosition - (kTextSpace+kTextHeight)*i - kTextHeight*0.5 - i);
        endPoint = CGPointMake(self.bounds.size.width, startPoint.y);
        [path moveToPoint:startPoint];
        [path lineToPoint:endPoint];
        [path stroke];
    }

    startPoint = CGPointMake(0, 0);
    endPoint = CGPointMake(self.bounds.size.width, startPoint.y);
    [path moveToPoint:startPoint];
    [path lineToPoint:endPoint];
    [path stroke];
}

@end
