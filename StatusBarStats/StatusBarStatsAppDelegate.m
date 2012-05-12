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
    hostPort = mach_host_self();
    if (host_page_size(hostPort, &pageSize) != KERN_SUCCESS)
	{
        NSLog(@"Unable to determine page size; using default 4096");
		pageSize=4096;
	} else {
        NSLog(@"Determined page size to be %lu", pageSize);
    }
    
    timer = [NSTimer scheduledTimerWithTimeInterval:60.0
                                             target:self
                                           selector:@selector(updateStats:)
                                           userInfo:nil
                                            repeats:YES];
    [self updatePie];
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
    [self buildPie:0];
    [statusItem setImage:pieChart];
}

- (NSBezierPath *)buildPieWedge:(NSPoint)centerPoint endAngle:(CGFloat)endAngle startAngle:(CGFloat)startAngle radius:(CGFloat)radius
{
    NSBezierPath * pieWedge = [NSBezierPath bezierPath];
    [pieWedge moveToPoint:centerPoint];
    [pieWedge appendBezierPathWithArcWithCenter: centerPoint
                                         radius: radius
                                     startAngle: startAngle
                                       endAngle: endAngle];
    [pieWedge lineToPoint:centerPoint];
    return pieWedge;
}

- (void)buildPie:(CGFloat)percentage
{
    CGFloat padding = 3;
    
    CGFloat thickness = [[NSStatusBar systemStatusBar] thickness];
    NSSize imageSize;
    imageSize.height = thickness;
    imageSize.width = thickness - padding; // Keep the sides snug
    
    pieChart = [[[NSImage alloc] initWithSize:imageSize] autorelease];
    
    NSPoint centerPoint = NSMakePoint(imageSize.width/2, imageSize.height/2);
    CGFloat radius = (imageSize.height - (padding * 2)) / 2;
    
    NSColor * blueishColor = [NSColor colorWithSRGBRed:0
                                                 green:0.55
                                                  blue:1
                                                 alpha:1];
    
    CGFloat endAngle = 90;
    CGFloat startAngle = endAngle - 360 * percentage;
    
    NSBezierPath * pieBorder = [NSBezierPath bezierPath];
    [pieBorder setLineWidth:2];
    [pieBorder appendBezierPathWithArcWithCenter: centerPoint
                                          radius: radius
                                      startAngle: startAngle
                                        endAngle: startAngle + 360];
    
    NSBezierPath *pieWedge;
    pieWedge = [self buildPieWedge:centerPoint endAngle:endAngle startAngle:startAngle radius:radius];
    
    [pieChart lockFocus]; // Draw after this
    [[NSColor grayColor] setStroke];
    [blueishColor setFill];
    [pieBorder stroke];
    [pieWedge fill];
    [pieChart unlockFocus]; // Finish drawing before this
}

- (CGFloat)getMemoryInformation
{
    vm_statistics_data_t vmData;
    unsigned int count=HOST_VM_INFO_COUNT;
    kern_return_t retVal = host_statistics(mach_host_self(),
                                           HOST_VM_INFO,
                                           (host_info_t)&vmData,
                                           &count);
    if (retVal != KERN_SUCCESS)
    {
        NSLog(@"Unable to get VM statistics");
        // TODO: Toss exception? Error? Exit?
        return 0;
    }
    
    NSLog(@"active: %u", vmData.active_count);
    NSLog(@"inactive: %u", vmData.inactive_count);
    NSLog(@"wire: %u", vmData.wire_count);
    NSLog(@"free: %u", vmData.free_count);
    
    natural_t usedMemory = vmData.active_count + vmData.inactive_count + vmData.wire_count;
    natural_t freeMemory = vmData.free_count;
    natural_t totalMemory = vmData.active_count + vmData.inactive_count + vmData.wire_count + vmData.free_count;
    
    NSLog(@"Total:\t%lu bytes", totalMemory * pageSize);
    NSLog(@"Used :\t%lu bytes", usedMemory * pageSize);
    NSLog(@"Free :\t%lu bytes", freeMemory * pageSize);
    
    CGFloat memoryPercent = (CGFloat) usedMemory / (CGFloat) totalMemory;
    return memoryPercent;
}


- (void)updatePie
{
    CGFloat memoryPercent = [self getMemoryInformation];
    NSString *percent = [NSString stringWithFormat:@"%i%%", (NSInteger)(memoryPercent * 100)];
    [self buildPie:memoryPercent];
    [statusItem setImage:pieChart];
    [statusItem setTitle:percent];
    //[[statusItem view] setNeedsDisplay:YES];
}

- (void)updateStats:(NSTimer *)timer
{
    [self updatePie];
}

@end
