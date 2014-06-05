//
// Created by Alex Bird on 05/06/2014.
// Copyright (c) 2014 Nicolas CHENG. All rights reserved.
//

#import "WYPopoverTheme.h"
#import "WYBasics.h"
#import "UIColor+WYPopover.h"

@implementation WYPopoverTheme

@synthesize tintColor;
@synthesize fillTopColor;
@synthesize fillBottomColor;

@synthesize glossShadowColor;
@synthesize glossShadowOffset;
@synthesize glossShadowBlurRadius;

@synthesize borderWidth;
@synthesize arrowBase;
@synthesize arrowHeight;

@synthesize outerShadowColor;
@synthesize outerStrokeColor;
@synthesize outerShadowBlurRadius;
@synthesize outerShadowOffset;
@synthesize outerCornerRadius;
@synthesize minOuterCornerRadius;

@synthesize innerShadowColor;
@synthesize innerStrokeColor;
@synthesize innerShadowBlurRadius;
@synthesize innerShadowOffset;
@synthesize innerCornerRadius;

@synthesize viewContentInsets;

@synthesize overlayColor;

+ (id)theme {

    WYPopoverTheme *result = nil;

    if (WY_IS_IOS_LESS_THAN(@"7.0")) {
        result = [WYPopoverTheme themeForIOS6];
    } else {
        result = [WYPopoverTheme themeForIOS7];
    }

    return result;
}

+ (id)themeForIOS6 {

    WYPopoverTheme *result = [[WYPopoverTheme alloc] init];

    result.tintColor = [UIColor colorWithRed:55./255. green:63./255. blue:71./255. alpha:1.0];
    result.outerStrokeColor = nil;
    result.innerStrokeColor = nil;
    result.fillTopColor = result.tintColor;
    result.fillBottomColor = [result.tintColor colorByDarken:0.4];
    result.glossShadowColor = nil;
    result.glossShadowOffset = CGSizeMake(0, 1.5);
    result.glossShadowBlurRadius = 0;
    result.borderWidth = 6;
    result.arrowBase = 42;
    result.arrowHeight = 18;
    result.outerShadowColor = [UIColor colorWithWhite:0 alpha:0.75];
    result.outerShadowBlurRadius = 8;
    result.outerShadowOffset = CGSizeMake(0, 2);
    result.outerCornerRadius = 8;
    result.minOuterCornerRadius = 0;
    result.innerShadowColor = [UIColor colorWithWhite:0 alpha:0.75];
    result.innerShadowBlurRadius = 2;
    result.innerShadowOffset = CGSizeMake(0, 1);
    result.innerCornerRadius = 6;
    result.viewContentInsets = UIEdgeInsetsMake(3, 0, 0, 0);
    result.overlayColor = [UIColor clearColor];

    return result;
}

+ (id)themeForIOS7 {

    WYPopoverTheme *result = [[WYPopoverTheme alloc] init];

    result.tintColor = [UIColor colorWithRed:244./255. green:244./255. blue:244./255. alpha:1.0];
    result.outerStrokeColor = [UIColor clearColor];
    result.innerStrokeColor = [UIColor clearColor];
    result.fillTopColor = nil;
    result.fillBottomColor = nil;
    result.glossShadowColor = nil;
    result.glossShadowOffset = CGSizeZero;
    result.glossShadowBlurRadius = 0;
    result.borderWidth = 0;
    result.arrowBase = 25;
    result.arrowHeight = 13;
    result.outerShadowColor = [UIColor clearColor];
    result.outerShadowBlurRadius = 0;
    result.outerShadowOffset = CGSizeZero;
    result.outerCornerRadius = 5;
    result.minOuterCornerRadius = 0;
    result.innerShadowColor = [UIColor clearColor];
    result.innerShadowBlurRadius = 0;
    result.innerShadowOffset = CGSizeZero;
    result.innerCornerRadius = 0;
    result.viewContentInsets = UIEdgeInsetsZero;
    result.overlayColor = [UIColor colorWithWhite:0 alpha:0.15];

    return result;
}

- (NSUInteger)innerCornerRadius
{
    float result = innerCornerRadius;

    if (borderWidth == 0)
    {
        result = 0;

        if (outerCornerRadius > 0)
        {
            result = outerCornerRadius;
        }
    }

    return result;
}

- (CGSize)outerShadowOffset
{
    CGSize result = outerShadowOffset;

    result.width = MIN(result.width, outerShadowBlurRadius);
    result.height = MIN(result.height, outerShadowBlurRadius);

    return result;
}

- (UIColor *)innerStrokeColor
{
    UIColor *result = innerStrokeColor;

    if (result == nil)
    {
        result = [self.fillTopColor colorByDarken:0.6];
    }

    return result;
}

- (UIColor *)outerStrokeColor
{
    UIColor *result = outerStrokeColor;

    if (result == nil)
    {
        result = [self.fillTopColor colorByDarken:0.6];
    }

    return result;
}

- (UIColor *)glossShadowColor
{
    UIColor *result = glossShadowColor;

    if (result == nil)
    {
        result = [self.fillTopColor colorByLighten:0.2];
    }

    return result;
}

- (UIColor *)fillTopColor
{
    UIColor *result = fillTopColor;

    if (result == nil)
    {
        result = tintColor;
    }

    return result;
}

- (UIColor *)fillBottomColor
{
    UIColor *result = fillBottomColor;

    if (result == nil)
    {
        result = self.fillTopColor;
    }

    return result;
}

- (NSArray *)observableKeypaths {
    return [NSArray arrayWithObjects:@"tintColor", @"outerStrokeColor", @"innerStrokeColor", @"fillTopColor", @"fillBottomColor", @"glossShadowColor", @"glossShadowOffset", @"glossShadowBlurRadius", @"borderWidth", @"arrowBase", @"arrowHeight", @"outerShadowColor", @"outerShadowBlurRadius", @"outerShadowOffset", @"outerCornerRadius", @"innerShadowColor", @"innerShadowBlurRadius", @"innerShadowOffset", @"innerCornerRadius", @"viewContentInsets", @"overlayColor", nil];
}

@end