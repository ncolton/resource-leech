//
//  PieChartDimensions.h
//  StatusBarStats
//
//  Created by Nikolai Colton on 5/11/12.
//  Copyright (c) 2012 OddMagic. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PieChartDimensions : NSObject
{
    NSInteger thickness;
    NSInteger padding;
    NSInteger lineWidth;
}

@property NSInteger thickness;
@property NSInteger padding;
@property NSInteger lineWidth;

- (NSInteger)height;
- (NSInteger)width;
- (NSInteger)radius;
- (NSPoint)centerPoint;

@end
