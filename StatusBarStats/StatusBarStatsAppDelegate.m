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
    // [statusItem setTitle:@"Status"];
    // Highlight when clicked on by user
    [statusItem setHighlightMode:YES];
    [statusItem setImage:[self buildPie]];
}

- (NSImage *)buildPie
{
    CGFloat padding = 3;
    
    CGFloat thickness = [[NSStatusBar systemStatusBar] thickness];
    NSSize imageSize;
    imageSize.height = thickness;
    imageSize.width = thickness - padding; // Keep the sides snug
    
    pieChart = [[[NSImage alloc] initWithSize:imageSize] autorelease];
    
    NSPoint centerPoint = NSMakePoint(imageSize.width/2, imageSize.height/2);
    CGFloat radius = (imageSize.height - (padding * 2)) / 2;
    
    NSColor * blueishColor = [NSColor colorWithSRGBRed:0 green:0.55 blue:1 alpha:1];
    
    CGFloat wedgePercent = 0.85;
    CGFloat endAngle = 90;
    CGFloat startAngle = endAngle - 360 * wedgePercent;
    
    NSBezierPath * pieBorder = [NSBezierPath bezierPath];
    [pieBorder setLineWidth:2];
    [pieBorder appendBezierPathWithArcWithCenter:centerPoint
                                          radius:radius
                                      startAngle:startAngle
                                        endAngle:startAngle + 360];
    
    NSBezierPath * pieWedge = [NSBezierPath bezierPath];
    [pieWedge moveToPoint:centerPoint];
    [pieWedge appendBezierPathWithArcWithCenter: centerPoint
                                         radius: radius
                                     startAngle: startAngle
                                       endAngle: endAngle];
    [pieWedge lineToPoint:centerPoint];
    
    [pieChart lockFocus]; // Draw after this
    [[NSColor grayColor] setStroke];
    [blueishColor setFill];
    [pieBorder stroke];
    [pieWedge fill];
    [pieChart unlockFocus]; // Finish drawing before this
    
    return [pieChart autorelease];
}

@end
