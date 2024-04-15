//
//  AppDelegate.m
//  ExifTools
//
//  Created by tbago on 2020/5/22.
//  Copyright © 2020 vxpen. All rights reserved.
//

#import "AppDelegate.h"
#import "AppConfig.h"
#import "ExifViewerViewController.h"

@interface AppDelegate ()

@property (weak) IBOutlet NSMenuItem    *mainMenuItem;
@property (weak) IBOutlet NSMenuItem    *aboutMenuItem;
@property (weak) IBOutlet NSMenuItem    *hideMenuItem;
@property (weak) IBOutlet NSMenuItem    *quitMenuItem;
@property (weak) IBOutlet NSMenuItem    *helpMenuItem;

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    ///< init product special item display
    NSString *productName = [AppConfig getProductName];
    self.mainMenuItem.title = productName;

    NSString *aboutMenuString = @"About ";
    aboutMenuString = [aboutMenuString stringByAppendingString:productName];
    self.aboutMenuItem.title = aboutMenuString;

    NSString *hideMenuString = @"Hide ";
    hideMenuString = [hideMenuString stringByAppendingString:productName];
    self.hideMenuItem.title = hideMenuString;

    NSString *quiteMenuString = @"Quit ";
    quiteMenuString = [quiteMenuString stringByAppendingString:productName];
    self.quitMenuItem.title  = quiteMenuString;

    NSString *helpMenuString = productName;
    helpMenuString = [helpMenuString stringByAppendingString:@" Help"];
    self.helpMenuItem.title = helpMenuString;
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

- (void)application:(NSApplication *)sender openFiles:(NSArray<NSString *> *)filenames {
    ExifViewerViewController *viewController = (ExifViewerViewController *)[NSApplication sharedApplication].mainWindow.contentViewController;
    [viewController openFileWithName:filenames[0]];
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender {
    return YES;
}

#pragma mark - action

- (IBAction)aboutMenuClick:(NSMenuItem *)sender {
    NSStoryboard *storyboard = [NSStoryboard storyboardWithName:@"Main" bundle:nil];
    NSWindowController *aboutWindowController = [storyboard instantiateControllerWithIdentifier:@"AboutWindowController"];
    aboutWindowController.window.level = NSNormalWindowLevel;
    [aboutWindowController.window makeKeyAndOrderFront:nil];
}

- (IBAction)preferencesMenuClick:(NSMenuItem *)sender {
    NSStoryboard *storyboard = [NSStoryboard storyboardWithName:@"Main" bundle:nil];
    NSWindowController *preferencesWindowController = [storyboard instantiateControllerWithIdentifier:@"PreferencesWindowController"];
    preferencesWindowController.window.level = NSNormalWindowLevel;
    [preferencesWindowController.window makeKeyAndOrderFront:nil];
}

- (IBAction)openFileMenuClick:(NSMenuItem *)sender {
    // FIXME: (tbago) special on product
    ExifViewerViewController *viewController = (ExifViewerViewController *)[NSApplication sharedApplication].mainWindow.contentViewController;
    [viewController openFile];
}

- (IBAction)helpMenuClick:(NSMenuItem *)sender {
     NSURL *supportWebsitelUrl = [NSURL URLWithString:[AppConfig getSupportWebsite]];
     [[NSWorkspace sharedWorkspace] openURL:supportWebsitelUrl];
}

@end
