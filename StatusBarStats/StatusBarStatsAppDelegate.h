//
//  StatusBarStatsAppDelegate.h
//  StatusBarStats
//
//  Created by Nikolai Colton on 3/24/11.
//  Copyright 2011 OddMagic. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface StatusBarStatsAppDelegate : NSObject <NSApplicationDelegate> {
@private
//    NSWindow *window;
    IBOutlet NSMenu *statusMenu;
    NSStatusItem *statusItem;
}

//@property (assign) IBOutlet NSWindow *window;

@end
