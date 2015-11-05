//
//  CPTMutablePlotRange+SwiftCompat.m
//  Kompass
//
//  Created by Tim Consigny on 05/11/2015.
//  Copyright © 2015 Rsx. All rights reserved.
//

#import "CPTMutablePlotRange+SwiftCompat.h"

@implementation CPTMutablePlotRange (SwiftCompat)
- (void)setLengthFloat:(float)lengthFloat
{
    NSNumber *number = [NSNumber numberWithFloat:lengthFloat];
    [self setLength:number];
    
   }


@end
