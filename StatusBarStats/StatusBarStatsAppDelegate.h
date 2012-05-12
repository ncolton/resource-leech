//
//  StatusBarStatsAppDelegate.h
//  StatusBarStats
//
//  Created by Nikolai Colton on 3/24/11.
//  Copyright 2011 OddMagic. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <mach/mach.h>
#import "PieChartDimensions.h"

@interface StatusBarStatsAppDelegate : NSObject <NSApplicationDelegate> {
@private
    IBOutlet NSMenu *statusMenu;
    NSStatusItem *statusItem;
    NSImage *pieChart;
    NSTimer *timer;
    PieChartDimensions *pieDimensions;
    NSColor *wiredColor;
    NSColor *activeColor;
    NSColor *inactiveColor;
    NSColor *borderColor;
    
    mach_port_t hostPort;
    vm_size_t pageSize;
}

- (NSInteger)angleFromPercentage:(CGFloat)percentage;
- (NSBezierPath *)buildPieWedgeWithCenterPoint:(NSPoint)centerPoint radius:(NSInteger)radius startAngle:(NSInteger)startAngle percentage:(CGFloat)percentage;
- (NSImage *)buildPieFromVMData:(vm_statistics_data_t)vmData;
- (NSBezierPath *)buildPieBorderWithCenter:(NSPoint)center radius:(NSInteger)radius;
- (vm_statistics_data_t)fetchMemoryData;
- (void)updatePie;
- (void)updateStats:(NSTimer *)timer;

@end
