//
//  StatusBarStatsAppDelegate.m
//  StatusBarStats
//
//  Created by Nikolai Colton on 3/24/11.
//  Copyright 2011 OddMagic. All rights reserved.
//

#import "StatusBarStatsAppDelegate.h"

@implementation StatusBarStatsAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
}

- (void)awakeFromNib
{
    // - (NSStatusItem *)statusItemWithLength:(CGFloat)length
    // length can be:
    // NSVariableStatusItemLength - Makes the status item length dynamic
    // NSSquareStatusItemLength - Sets status item length to match thickness
    statusItem = [[[NSStatusBar systemStatusBar]
                   statusItemWithLength:NSVariableStatusItemLength] retain];
    [statusItem setMenu:statusMenu];
    // To use an image instead of text:
    // - (void)setImage:(NSImage *)image
    // - (void)setAlternateImage:(NSImage *)image
    [statusItem setTitle:@"Status"];
    // Highlight when clicked on by user
    [statusItem setHighlightMode:YES];
}

@end
