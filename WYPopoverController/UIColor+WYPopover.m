//
// Created by Alex Bird on 05/06/2014.
// Copyright (c) 2014 Nicolas CHENG. All rights reserved.
//

#import "UIColor+WYPopover.h"

@implementation UIColor (WYPopover)

- (BOOL)getValueOfRed:(CGFloat *)red green:(CGFloat *)green blue:(CGFloat *)blue alpha:(CGFloat *)alpha
{
    // model: kCGColorSpaceModelRGB, num_comps: 4
    // model: kCGColorSpaceModelMonochrome, num_comps: 2

    CGColorSpaceRef colorSpace = CGColorSpaceRetain(CGColorGetColorSpace([self CGColor]));
    CGColorSpaceModel colorSpaceModel = CGColorSpaceGetModel(colorSpace);
    CGColorSpaceRelease(colorSpace);

    CGFloat rFloat = 0.0, gFloat = 0.0, bFloat = 0.0, aFloat = 0.0;
    BOOL result = NO;

    if (colorSpaceModel == kCGColorSpaceModelRGB)
    {
        result = [self getRed:&rFloat green:&gFloat blue:&bFloat alpha:&aFloat];
    }
    else if (colorSpaceModel == kCGColorSpaceModelMonochrome)
    {
        result = [self getWhite:&rFloat alpha:&aFloat];
        gFloat = rFloat;
        bFloat = rFloat;
    }

    if (red) *red = rFloat;
    if (green) *green = gFloat;
    if (blue) *blue = bFloat;
    if (alpha) *alpha = aFloat;

    return result;
}

- (NSString *)hexString
{
    CGFloat rFloat, gFloat, bFloat, aFloat;
    int r, g, b, a;
    [self getValueOfRed:&rFloat green:&gFloat blue:&bFloat alpha:&aFloat];

    r = (int)(255.0 * rFloat);
    g = (int)(255.0 * gFloat);
    b = (int)(255.0 * bFloat);
    a = (int)(255.0 * aFloat);

    return [NSString stringWithFormat:@"#%02x%02x%02x%02x", r, g, b, a];
}

- (UIColor *)colorByLighten:(float)d
{
    CGFloat rFloat, gFloat, bFloat, aFloat;
    [self getValueOfRed:&rFloat green:&gFloat blue:&bFloat alpha:&aFloat];

    return [UIColor colorWithRed:MIN(rFloat + d, 1.0)
                           green:MIN(gFloat + d, 1.0)
                            blue:MIN(bFloat + d, 1.0)
                           alpha:1.0];
}

- (UIColor *)colorByDarken:(float)d
{
    CGFloat rFloat, gFloat, bFloat, aFloat;
    [self getValueOfRed:&rFloat green:&gFloat blue:&bFloat alpha:&aFloat];

    return [UIColor colorWithRed:MAX(rFloat - d, 0.0)
                           green:MAX(gFloat - d, 0.0)
                            blue:MAX(bFloat - d, 0.0)
                           alpha:1.0];
}

@end