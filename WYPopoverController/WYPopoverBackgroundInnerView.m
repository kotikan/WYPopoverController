//
// Created by Alex Bird on 05/06/2014.
// Copyright (c) 2014 Nicolas CHENG. All rights reserved.
//

#import "WYPopoverBackgroundInnerView.h"



@implementation WYPopoverBackgroundInnerView

@synthesize innerStrokeColor;

@synthesize gradientTopColor;
@synthesize gradientBottomColor;
@synthesize gradientHeight;
@synthesize gradientTopPosition;

@synthesize innerShadowColor;
@synthesize innerShadowOffset;
@synthesize innerShadowBlurRadius;
@synthesize innerCornerRadius;

@synthesize navigationBarHeight;
@synthesize wantsDefaultContentAppearance;
@synthesize borderWidth;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.backgroundColor = [UIColor clearColor];
        self.userInteractionEnabled = NO;
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = UIGraphicsGetCurrentContext();

    //// Gradient Declarations
    NSArray* fillGradientColors = [NSArray arrayWithObjects:
                                   (id)gradientTopColor.CGColor,
                                   (id)gradientBottomColor.CGColor, nil];

    CGFloat fillGradientLocations[2] = { 0, 1 };

    CGGradientRef fillGradient = CGGradientCreateWithColors(colorSpace, (__bridge CFArrayRef)fillGradientColors, fillGradientLocations);

    //// innerRect Drawing
    float barHeight = (wantsDefaultContentAppearance == NO) ? navigationBarHeight : 0;
    float cornerRadius = (wantsDefaultContentAppearance == NO) ? innerCornerRadius : 0;

    CGRect innerRect = CGRectMake(CGRectGetMinX(rect), CGRectGetMinY(rect) + barHeight, CGRectGetWidth(rect) , CGRectGetHeight(rect) - barHeight);

    UIBezierPath* rectPath = [UIBezierPath bezierPathWithRect:innerRect];

    UIBezierPath* roundedRectPath = [UIBezierPath bezierPathWithRoundedRect:innerRect cornerRadius:cornerRadius + 1];

    if (wantsDefaultContentAppearance == NO && borderWidth > 0)
    {
        CGContextSaveGState(context);
        {
            [rectPath appendPath:roundedRectPath];
            rectPath.usesEvenOddFillRule = YES;
            [rectPath addClip];

            CGContextDrawLinearGradient(context, fillGradient,
                                        CGPointMake(0, -gradientTopPosition),
                                        CGPointMake(0, -gradientTopPosition + gradientHeight),
                                        0);
        }
        CGContextRestoreGState(context);
    }

    CGContextSaveGState(context);
    {
        if (wantsDefaultContentAppearance == NO && borderWidth > 0)
        {
            [roundedRectPath addClip];
            CGContextSetShadowWithColor(context, innerShadowOffset, innerShadowBlurRadius, innerShadowColor.CGColor);
        }

        UIBezierPath* inRoundedRectPath = [UIBezierPath bezierPathWithRoundedRect:CGRectInset(innerRect, 0.5, 0.5) cornerRadius:cornerRadius];

        if (borderWidth == 0)
        {
            inRoundedRectPath = [UIBezierPath bezierPathWithRoundedRect:CGRectInset(innerRect, 0.5, 0.5) byRoundingCorners:UIRectCornerBottomLeft|UIRectCornerBottomRight cornerRadii:CGSizeMake(cornerRadius, cornerRadius)];
        }

        [self.innerStrokeColor setStroke];
        inRoundedRectPath.lineWidth = 1;
        [inRoundedRectPath stroke];
    }

    CGContextRestoreGState(context);

    CGGradientRelease(fillGradient);
    CGColorSpaceRelease(colorSpace);
}

- (void)dealloc
{
    innerShadowColor = nil;
    innerStrokeColor = nil;
    gradientTopColor = nil;
    gradientBottomColor = nil;
}

@end