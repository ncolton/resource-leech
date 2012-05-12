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
        NSLog(@"Determined page size to be %u", (unsigned int)pageSize);
    }
        
    pieDimensions = [[PieChartDimensions alloc] init];
    [pieDimensions setThickness:[[NSStatusBar systemStatusBar] thickness]];
    [pieDimensions setLineWidth:2];
    [pieDimensions setPadding:3];
    
    wiredColor = [[NSColor redColor] retain];
    activeColor = [[NSColor yellowColor] retain];
    inactiveColor = [[NSColor colorWithSRGBRed:0
                                        green:0.55
                                         blue:1
                                        alpha:1] retain];
    borderColor = [[NSColor grayColor] retain];
    
    timer = [NSTimer scheduledTimerWithTimeInterval:2.0
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
}

- (NSInteger)angleFromPercentage:(CGFloat)percentage
{
    return percentage * 360;
}

- (NSBezierPath *)buildPieWedgeWithCenterPoint:(NSPoint)centerPoint radius:(NSInteger)radius startAngle:(NSInteger)startAngle percentage:(CGFloat)percentage
{
    NSLog(@"Called with radius %ld, start %ld°, %f", (long)radius, (long)startAngle, percentage);
    NSInteger offset = 90;
    NSInteger wedgeStartAngle = offset - startAngle;
    NSInteger wedgeEndAngle = (wedgeStartAngle - [self angleFromPercentage:percentage]);
    NSLog(@"percentage: %f, start: %ld, end: %ld", percentage, (long)wedgeStartAngle, (long)wedgeEndAngle);
    
    NSBezierPath * pieWedge = [NSBezierPath bezierPath];
    [pieWedge moveToPoint:centerPoint];
    [pieWedge appendBezierPathWithArcWithCenter:centerPoint
                                         radius:radius
                                     startAngle:wedgeStartAngle
                                       endAngle:wedgeEndAngle
                                      clockwise:YES];
    [pieWedge lineToPoint:centerPoint];
    return pieWedge;
}

- (NSImage *)buildPieFromVMData:(vm_statistics_data_t)vmData
{
    NSUInteger totalMemory = vmData.wire_count + vmData.active_count + vmData.inactive_count + vmData.free_count;
    NSLog(@"total memory: %lu", (unsigned long)totalMemory);
    
    NSInteger offsetAngle = 0;
    CGFloat wiredPercentage = vmData.wire_count / (CGFloat)totalMemory;
    NSLog(@"wired: %f%%", wiredPercentage);
    NSBezierPath * pieSliceWired;
    pieSliceWired = [[self buildPieWedgeWithCenterPoint:[pieDimensions centerPoint]
                                                 radius:[pieDimensions radius]
                                             startAngle:offsetAngle
                                             percentage:wiredPercentage] retain];
    offsetAngle = [self angleFromPercentage:wiredPercentage];
    CGFloat activePercentage = vmData.active_count / (CGFloat)totalMemory;
    NSBezierPath * pieSliceActive;
    pieSliceActive = [[self buildPieWedgeWithCenterPoint:[pieDimensions centerPoint]
                                                 radius:[pieDimensions radius]
                                             startAngle:offsetAngle
                                             percentage:activePercentage] retain];
    offsetAngle = [self angleFromPercentage:wiredPercentage + activePercentage];
    CGFloat inactivePercentage = vmData.inactive_count / (CGFloat)totalMemory;
    NSBezierPath * pieSliceInactive;
    pieSliceInactive = [[self buildPieWedgeWithCenterPoint:[pieDimensions centerPoint]
                                                   radius:[pieDimensions radius]
                                               startAngle:offsetAngle
                                               percentage:inactivePercentage] retain];
    NSBezierPath * pieBorder;
    pieBorder = [[self buildPieBorderWithCenter:[pieDimensions centerPoint]
                                        radius:[pieDimensions radius]] retain];
    NSSize imageSize;
    imageSize.height = [pieDimensions height];
    imageSize.width = [pieDimensions width];
    NSImage *pie = [[NSImage alloc] initWithSize:imageSize];
    [pie lockFocus];
    [borderColor setStroke];
    [pieBorder stroke];
    [wiredColor setFill];
    [pieSliceWired fill];
    [activeColor setFill];
    [pieSliceActive fill];
    [inactiveColor setFill];
    [pieSliceInactive fill];
    [pie unlockFocus];
    
    [pieBorder release];
    [pieSliceWired release];
    [pieSliceActive release];
    [pieSliceInactive release];
    
    return [pie autorelease];
}

- (NSBezierPath *)buildPieBorderWithCenter:(NSPoint)center radius:(NSInteger)radius
{
    NSBezierPath * pieBorder = [NSBezierPath bezierPath];
    [pieBorder setLineWidth:[pieDimensions lineWidth]];
    [pieBorder appendBezierPathWithArcWithCenter:center
                                          radius:radius
                                      startAngle:0
                                        endAngle:360];
    return pieBorder;
}

- (vm_statistics_data_t)fetchMemoryData
{
    vm_statistics_data_t vmData;
    unsigned int count=HOST_VM_INFO_COUNT;
    kern_return_t hostOpStat = host_statistics(mach_host_self(), HOST_VM_INFO,
                                               (host_info_t)&vmData, &count);
    if (hostOpStat != KERN_SUCCESS)
    {
        NSLog(@"Unable to get VM statistics");
    }
    
    return vmData;
}

- (void)updatePie
{
    vm_statistics_data_t vmdata = [self fetchMemoryData];
    NSLog(@"wired: %ld, active: %ld, inactive: %ld, free: %ld",
          (long)vmdata.wire_count,
          (long)vmdata.active_count,
          (long)vmdata.inactive_count,
          (long)vmdata.free_count);
    NSImage * newPie = [[self buildPieFromVMData:vmdata] retain];
    [statusItem setImage:newPie];
    [newPie autorelease];
}

- (void)updateStats:(NSTimer *)timer
{
    [self updatePie];
}

@end
