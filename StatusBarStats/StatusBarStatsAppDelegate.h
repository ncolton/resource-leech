//
//  StatusBarStatsAppDelegate.h
//  StatusBarStats
//
//  Created by Nikolai Colton on 3/24/11.
//  Copyright 2011 OddMagic. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <mach/mach.h>

@interface StatusBarStatsAppDelegate : NSObject <NSApplicationDelegate> {
@private
    IBOutlet NSMenu *statusMenu;
    NSStatusItem *statusItem;
    NSImage *pieChart;
    NSTimer *timer;
    
    mach_port_t hostPort;
    vm_size_t pageSize;
}

- (void)buildPie:(CGFloat)percentage;
- (CGFloat)getMemoryInformation;
- (void)updateStats:(NSTimer *)timer;
- (void)updatePie;
- (NSBezierPath *)buildPieWedge:(NSPoint)centerPoint endAngle:(CGFloat)endAngle startAngle:(CGFloat)startAngle radius:(CGFloat)radius;

@end
