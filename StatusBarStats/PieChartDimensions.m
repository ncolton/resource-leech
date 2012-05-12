//
//  PieChartDimensions.m
//  StatusBarStats
//
//  Created by Nikolai Colton on 5/11/12.
//  Copyright (c) 2012 OddMagic. All rights reserved.
//

#import "PieChartDimensions.h"

@implementation PieChartDimensions

@synthesize thickness;
@synthesize padding;
@synthesize lineWidth;

- (id)init
{
    if (self = [super init])
    {
        [self setThickness:0];
        [self setPadding:0];
    }
    return self;
}

- (NSInteger)width
{
    return thickness - padding;
}

- (NSInteger)height
{
    return thickness;
}

- (NSInteger)radius
{
    return ([self height] - ([self padding] * 2)) / 2;
}

- (NSPoint)centerPoint
{
    return NSMakePoint([self width] / 2, [self height] / 2);
}

@end
