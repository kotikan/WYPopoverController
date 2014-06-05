//
// Created by Alex Bird on 05/06/2014.
// Copyright (c) 2014 Nicolas CHENG. All rights reserved.
//

#import <objc/runtime.h>
#import "WYPopoverBackgroundView.h"
#import "WYPopoverBackgroundInnerView.h"
#import "WYPopoverBackgroundViewDelegate.h"
#import "WYBasics.h"

@interface WYPopoverBackgroundView ()
{
    WYPopoverBackgroundInnerView *innerView;
    CGSize contentSize;
}

- (CGRect)outerRect;
- (CGRect)innerRect;
- (CGRect)arrowRect;

- (CGRect)outerRect:(CGRect)rect arrowDirection:(WYPopoverArrowDirection)aArrowDirection;
- (CGRect)innerRect:(CGRect)rect arrowDirection:(WYPopoverArrowDirection)aArrowDirection;
- (CGRect)arrowRect:(CGRect)rect arrowDirection:(WYPopoverArrowDirection)aArrowDirection;

- (BOOL)isTouchedAtPoint:(CGPoint)point;

@end

@implementation WYPopoverBackgroundView

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

@synthesize arrowDirection;
@synthesize contentView;
@synthesize arrowOffset;
@synthesize navigationBarHeight;
@synthesize wantsDefaultContentAppearance;

@synthesize outerShadowInsets;

- (id)initWithContentSize:(CGSize)aContentSize
{
    self = [super initWithFrame:CGRectMake(0, 0, aContentSize.width, aContentSize.height)];

    if (self != nil)
    {
        contentSize = aContentSize;

        self.autoresizesSubviews = NO;
        self.backgroundColor = [UIColor clearColor];

        self.arrowDirection = WYPopoverArrowDirectionDown;
        self.arrowOffset = 0;

        self.layer.name = @"parent";

        if (WY_IS_IOS_GREATER_THAN_OR_EQUAL_TO(@"6.0"))
        {
            self.layer.drawsAsynchronously = YES;
        }

        self.layer.contentsScale = [UIScreen mainScreen].scale;
        //self.layer.edgeAntialiasingMask = kCALayerLeftEdge | kCALayerRightEdge | kCALayerBottomEdge | kCALayerTopEdge;
        self.layer.delegate = self;
    }

    return self;
}

/*
- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
{
    BOOL result = [super pointInside:point withEvent:event];

    if (self.isAppearing == NO)
    {
        BOOL isTouched = [self isTouchedAtPoint:point];

        if (isTouched == NO && UIAccessibilityIsVoiceOverRunning())
        {
            UIAccessibilityPostNotification(UIAccessibilityLayoutChangedNotification, nil);
            UIAccessibilityPostNotification(UIAccessibilityAnnouncementNotification, NSLocalizedString(@"Double-tap to dismiss pop-up window.", nil));
        }
    }

    return result;
}
*/


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *oneTouch = [touches anyObject];
    CGPoint point = [oneTouch locationInView:self];

    if ([self isTouchedAtPoint:point] == NO)
    {
        if ([self.delegate respondsToSelector:@selector(popoverBackgroundViewDidTouchOutside:)])
        {
            [self.delegate popoverBackgroundViewDidTouchOutside:self];
        }
    }
}

- (UIEdgeInsets)outerShadowInsets
{
    UIEdgeInsets result = UIEdgeInsetsMake(outerShadowBlurRadius, outerShadowBlurRadius, outerShadowBlurRadius, outerShadowBlurRadius);

    result.top -= self.outerShadowOffset.height;
    result.bottom += self.outerShadowOffset.height;
    result.left -= self.outerShadowOffset.width;
    result.right += self.outerShadowOffset.width;

    return result;
}

- (void)setArrowOffset:(float)value
{
    float coef = 1;

    if (value != 0)
    {
        coef = value / ABS(value);

        value = ABS(value);

        CGRect outerRect = [self outerRect];

        float delta = self.arrowBase / 2. + .5;

        delta  += MIN(minOuterCornerRadius, outerCornerRadius);

        outerRect = CGRectInset(outerRect, delta, delta);

        if (arrowDirection == WYPopoverArrowDirectionUp || arrowDirection == WYPopoverArrowDirectionDown)
        {
            value += coef * self.outerShadowOffset.width;
            value = MIN(value, CGRectGetWidth(outerRect) / 2);
        }

        if (arrowDirection == WYPopoverArrowDirectionLeft || arrowDirection == WYPopoverArrowDirectionRight)
        {
            value += coef * self.outerShadowOffset.height;
            value = MIN(value, CGRectGetHeight(outerRect) / 2);
        }
    }
    else
    {
        if (arrowDirection == WYPopoverArrowDirectionUp || arrowDirection == WYPopoverArrowDirectionDown)
        {
            value += self.outerShadowOffset.width;
        }

        if (arrowDirection == WYPopoverArrowDirectionLeft || arrowDirection == WYPopoverArrowDirectionRight)
        {
            value += self.outerShadowOffset.height;
        }
    }

    arrowOffset = value * coef;
}

- (void)setViewController:(UIViewController *)viewController
{
    contentView = viewController.view;

    contentView.frame = CGRectIntegral(CGRectMake(0, 0, self.bounds.size.width, 100));

    [self addSubview:contentView];

    navigationBarHeight = 0;

    if ([viewController isKindOfClass:[UINavigationController class]])
    {
        UINavigationController* navigationController = (UINavigationController*)viewController;
        navigationBarHeight = navigationController.navigationBar.bounds.size.height;
    }

    contentView.frame = CGRectIntegral([self innerRect]);

    if (innerView == nil)
    {
        innerView = [[WYPopoverBackgroundInnerView alloc] initWithFrame:contentView.frame];
        innerView.userInteractionEnabled = NO;

        innerView.gradientTopColor = self.fillTopColor;
        innerView.gradientBottomColor = self.fillBottomColor;
        innerView.innerShadowColor = innerShadowColor;
        innerView.innerStrokeColor = self.innerStrokeColor;
        innerView.innerShadowOffset = innerShadowOffset;
        innerView.innerCornerRadius = self.innerCornerRadius;
        innerView.innerShadowBlurRadius = innerShadowBlurRadius;
        innerView.borderWidth = self.borderWidth;
    }

    innerView.navigationBarHeight = navigationBarHeight;
    innerView.gradientHeight = self.frame.size.height - 2 * outerShadowBlurRadius;
    innerView.gradientTopPosition = contentView.frame.origin.y - self.outerShadowInsets.top;
    innerView.wantsDefaultContentAppearance = wantsDefaultContentAppearance;

    [self insertSubview:innerView aboveSubview:contentView];

    innerView.frame = CGRectIntegral(contentView.frame);

    [self.layer setNeedsDisplay];
}

- (CGSize)sizeThatFits:(CGSize)size
{
    CGSize result = size;

    result.width += 2 * (borderWidth + outerShadowBlurRadius);
    result.height += borderWidth + 2 * outerShadowBlurRadius;

    if (navigationBarHeight == 0)
    {
        result.height += borderWidth;
    }

    if (arrowDirection == WYPopoverArrowDirectionUp || arrowDirection == WYPopoverArrowDirectionDown)
    {
        result.height += arrowHeight;
    }

    if (arrowDirection == WYPopoverArrowDirectionLeft || arrowDirection == WYPopoverArrowDirectionRight)
    {
        result.width += arrowHeight;
    }

    return result;
}

- (void)sizeToFit
{
    CGSize size = [self sizeThatFits:contentSize];
    self.bounds = CGRectMake(0, 0, size.width, size.height);
}

#pragma mark Drawing

- (void)setNeedsDisplay
{
    [super setNeedsDisplay];

    [self.layer setNeedsDisplay];

    if (innerView)
    {
        innerView.gradientTopColor = self.fillTopColor;
        innerView.gradientBottomColor = self.fillBottomColor;
        innerView.innerShadowColor = innerShadowColor;
        innerView.innerStrokeColor = self.innerStrokeColor;
        innerView.innerShadowOffset = innerShadowOffset;
        innerView.innerCornerRadius = self.innerCornerRadius;
        innerView.innerShadowBlurRadius = innerShadowBlurRadius;
        innerView.borderWidth = self.borderWidth;

        innerView.navigationBarHeight = navigationBarHeight;
        innerView.gradientHeight = self.frame.size.height - 2 * outerShadowBlurRadius;
        innerView.gradientTopPosition = contentView.frame.origin.y - self.outerShadowInsets.top;
        innerView.wantsDefaultContentAppearance = wantsDefaultContentAppearance;

        [innerView setNeedsDisplay];
    }
}

#pragma mark CALayerDelegate

- (void)drawLayer:(CALayer *)layer inContext:(CGContextRef)context
{
    if ([layer.name isEqualToString:@"parent"])
    {
        UIGraphicsPushContext(context);
        //CGContextSetShouldAntialias(context, YES);
        //CGContextSetAllowsAntialiasing(context, YES);

        //// General Declarations
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();

        //// Gradient Declarations
        NSArray* fillGradientColors = [NSArray arrayWithObjects:
                                       (id)self.fillTopColor.CGColor,
                                       (id)self.fillBottomColor.CGColor, nil];

        CGFloat fillGradientLocations[2] = {0, 1};
        CGGradientRef fillGradient = CGGradientCreateWithColors(colorSpace, (__bridge CFArrayRef)fillGradientColors, fillGradientLocations);

        // Frames
        CGRect rect = self.bounds;

        CGRect outerRect = [self outerRect:rect arrowDirection:self.arrowDirection];
        outerRect = CGRectInset(outerRect, 0.5, 0.5);

        // Inner Path
        CGMutablePathRef outerPathRef = CGPathCreateMutable();

        CGPoint origin = CGPointZero;

        float reducedOuterCornerRadius = 0;

        if (arrowDirection == WYPopoverArrowDirectionUp || arrowDirection == WYPopoverArrowDirectionDown)
        {
            if (arrowOffset >= 0)
            {
                reducedOuterCornerRadius = CGRectGetMaxX(outerRect) - (CGRectGetMidX(outerRect) + arrowOffset + arrowBase / 2);
            }
            else
            {
                reducedOuterCornerRadius = (CGRectGetMidX(outerRect) + arrowOffset - arrowBase / 2) - CGRectGetMinX(outerRect);
            }
        }
        else if (arrowDirection == WYPopoverArrowDirectionLeft || arrowDirection == WYPopoverArrowDirectionRight)
        {
            if (arrowOffset >= 0)
            {
                reducedOuterCornerRadius = CGRectGetMaxY(outerRect) - (CGRectGetMidY(outerRect) + arrowOffset + arrowBase / 2);
            }
            else
            {
                reducedOuterCornerRadius = (CGRectGetMidY(outerRect) + arrowOffset - arrowBase / 2) - CGRectGetMinY(outerRect);
            }
        }

        reducedOuterCornerRadius = MIN(reducedOuterCornerRadius, outerCornerRadius);

        if (arrowDirection == WYPopoverArrowDirectionUp)
        {
            origin = CGPointMake(CGRectGetMidX(outerRect) + arrowOffset - arrowBase / 2, CGRectGetMinY(outerRect));

            CGPathMoveToPoint(outerPathRef, NULL, origin.x, origin.y);

            CGPathAddLineToPoint(outerPathRef, NULL, CGRectGetMidX(outerRect) + arrowOffset, CGRectGetMinY(outerRect) - arrowHeight);
            CGPathAddLineToPoint(outerPathRef, NULL, CGRectGetMidX(outerRect) + arrowOffset + arrowBase / 2, CGRectGetMinY(outerRect));

            CGPathAddArcToPoint(outerPathRef, NULL, CGRectGetMaxX(outerRect), CGRectGetMinY(outerRect), CGRectGetMaxX(outerRect), CGRectGetMaxY(outerRect), (arrowOffset >= 0) ? reducedOuterCornerRadius : outerCornerRadius);
            CGPathAddArcToPoint(outerPathRef, NULL, CGRectGetMaxX(outerRect), CGRectGetMaxY(outerRect), CGRectGetMinX(outerRect), CGRectGetMaxY(outerRect), outerCornerRadius);
            CGPathAddArcToPoint(outerPathRef, NULL, CGRectGetMinX(outerRect), CGRectGetMaxY(outerRect), CGRectGetMinX(outerRect), CGRectGetMinY(outerRect), outerCornerRadius);
            CGPathAddArcToPoint(outerPathRef, NULL, CGRectGetMinX(outerRect), CGRectGetMinY(outerRect), CGRectGetMaxX(outerRect), CGRectGetMinY(outerRect), (arrowOffset < 0) ? reducedOuterCornerRadius : outerCornerRadius);

            CGPathAddLineToPoint(outerPathRef, NULL, origin.x, origin.y);
        }

        if (arrowDirection == WYPopoverArrowDirectionDown)
        {
            origin = CGPointMake(CGRectGetMidX(outerRect) + arrowOffset + arrowBase / 2, CGRectGetMaxY(outerRect));

            CGPathMoveToPoint(outerPathRef, NULL, origin.x, origin.y);

            CGPathAddLineToPoint(outerPathRef, NULL, CGRectGetMidX(outerRect) + arrowOffset, CGRectGetMaxY(outerRect) + arrowHeight);
            CGPathAddLineToPoint(outerPathRef, NULL, CGRectGetMidX(outerRect) + arrowOffset - arrowBase / 2, CGRectGetMaxY(outerRect));

            CGPathAddArcToPoint(outerPathRef, NULL, CGRectGetMinX(outerRect), CGRectGetMaxY(outerRect), CGRectGetMinX(outerRect), CGRectGetMinY(outerRect), (arrowOffset < 0) ? reducedOuterCornerRadius : outerCornerRadius);
            CGPathAddArcToPoint(outerPathRef, NULL, CGRectGetMinX(outerRect), CGRectGetMinY(outerRect), CGRectGetMaxX(outerRect), CGRectGetMinY(outerRect), outerCornerRadius);
            CGPathAddArcToPoint(outerPathRef, NULL, CGRectGetMaxX(outerRect), CGRectGetMinY(outerRect), CGRectGetMaxX(outerRect), CGRectGetMaxY(outerRect), outerCornerRadius);
            CGPathAddArcToPoint(outerPathRef, NULL, CGRectGetMaxX(outerRect), CGRectGetMaxY(outerRect), CGRectGetMinX(outerRect), CGRectGetMaxY(outerRect), (arrowOffset >= 0) ? reducedOuterCornerRadius : outerCornerRadius);

            CGPathAddLineToPoint(outerPathRef, NULL, origin.x, origin.y);
        }

        if (arrowDirection == WYPopoverArrowDirectionLeft)
        {
            origin = CGPointMake(CGRectGetMinX(outerRect), CGRectGetMidY(outerRect) + arrowOffset + arrowBase / 2);

            CGPathMoveToPoint(outerPathRef, NULL, origin.x, origin.y);

            CGPathAddLineToPoint(outerPathRef, NULL, CGRectGetMinX(outerRect) - arrowHeight, CGRectGetMidY(outerRect) + arrowOffset);
            CGPathAddLineToPoint(outerPathRef, NULL, CGRectGetMinX(outerRect), CGRectGetMidY(outerRect) + arrowOffset - arrowBase / 2);

            CGPathAddArcToPoint(outerPathRef, NULL, CGRectGetMinX(outerRect), CGRectGetMinY(outerRect), CGRectGetMaxX(outerRect), CGRectGetMinY(outerRect), (arrowOffset < 0) ? reducedOuterCornerRadius : outerCornerRadius);
            CGPathAddArcToPoint(outerPathRef, NULL, CGRectGetMaxX(outerRect), CGRectGetMinY(outerRect), CGRectGetMaxX(outerRect), CGRectGetMaxY(outerRect), outerCornerRadius);
            CGPathAddArcToPoint(outerPathRef, NULL, CGRectGetMaxX(outerRect), CGRectGetMaxY(outerRect), CGRectGetMinX(outerRect), CGRectGetMaxY(outerRect), outerCornerRadius);
            CGPathAddArcToPoint(outerPathRef, NULL, CGRectGetMinX(outerRect), CGRectGetMaxY(outerRect), CGRectGetMinX(outerRect), CGRectGetMinY(outerRect), (arrowOffset >= 0) ? reducedOuterCornerRadius : outerCornerRadius);

            CGPathAddLineToPoint(outerPathRef, NULL, origin.x, origin.y);
        }

        if (arrowDirection == WYPopoverArrowDirectionRight)
        {
            origin = CGPointMake(CGRectGetMaxX(outerRect), CGRectGetMidY(outerRect) + arrowOffset - arrowBase / 2);

            CGPathMoveToPoint(outerPathRef, NULL, origin.x, origin.y);

            CGPathAddLineToPoint(outerPathRef, NULL, CGRectGetMaxX(outerRect) + arrowHeight, CGRectGetMidY(outerRect) + arrowOffset);
            CGPathAddLineToPoint(outerPathRef, NULL, CGRectGetMaxX(outerRect), CGRectGetMidY(outerRect) + arrowOffset + arrowBase / 2);

            CGPathAddArcToPoint(outerPathRef, NULL, CGRectGetMaxX(outerRect), CGRectGetMaxY(outerRect), CGRectGetMinX(outerRect), CGRectGetMaxY(outerRect), (arrowOffset >= 0) ? reducedOuterCornerRadius : outerCornerRadius);
            CGPathAddArcToPoint(outerPathRef, NULL, CGRectGetMinX(outerRect), CGRectGetMaxY(outerRect), CGRectGetMinX(outerRect), CGRectGetMinY(outerRect), outerCornerRadius);
            CGPathAddArcToPoint(outerPathRef, NULL, CGRectGetMinX(outerRect), CGRectGetMinY(outerRect), CGRectGetMaxX(outerRect), CGRectGetMinY(outerRect), outerCornerRadius);
            CGPathAddArcToPoint(outerPathRef, NULL, CGRectGetMaxX(outerRect), CGRectGetMinY(outerRect), CGRectGetMaxX(outerRect), CGRectGetMaxY(outerRect), (arrowOffset < 0) ? reducedOuterCornerRadius : outerCornerRadius);

            CGPathAddLineToPoint(outerPathRef, NULL, origin.x, origin.y);
        }

        if (arrowDirection == WYPopoverArrowDirectionNone)
        {
            origin = CGPointMake(CGRectGetMaxX(outerRect), CGRectGetMidY(outerRect));

            CGPathMoveToPoint(outerPathRef, NULL, origin.x, origin.y);

            CGPathAddLineToPoint(outerPathRef, NULL, CGRectGetMaxX(outerRect), CGRectGetMidY(outerRect));
            CGPathAddLineToPoint(outerPathRef, NULL, CGRectGetMaxX(outerRect), CGRectGetMidY(outerRect));

            CGPathAddArcToPoint(outerPathRef, NULL, CGRectGetMaxX(outerRect), CGRectGetMaxY(outerRect), CGRectGetMinX(outerRect), CGRectGetMaxY(outerRect), outerCornerRadius);
            CGPathAddArcToPoint(outerPathRef, NULL, CGRectGetMinX(outerRect), CGRectGetMaxY(outerRect), CGRectGetMinX(outerRect), CGRectGetMinY(outerRect), outerCornerRadius);
            CGPathAddArcToPoint(outerPathRef, NULL, CGRectGetMinX(outerRect), CGRectGetMinY(outerRect), CGRectGetMaxX(outerRect), CGRectGetMinY(outerRect), outerCornerRadius);
            CGPathAddArcToPoint(outerPathRef, NULL, CGRectGetMaxX(outerRect), CGRectGetMinY(outerRect), CGRectGetMaxX(outerRect), CGRectGetMaxY(outerRect), outerCornerRadius);

            CGPathAddLineToPoint(outerPathRef, NULL, origin.x, origin.y);
        }

        CGPathCloseSubpath(outerPathRef);

        UIBezierPath* outerRectPath = [UIBezierPath bezierPathWithCGPath:outerPathRef];

        CGContextSaveGState(context);
        {
            CGContextSetShadowWithColor(context, self.outerShadowOffset, outerShadowBlurRadius, outerShadowColor.CGColor);
            CGContextBeginTransparencyLayer(context, NULL);
            [outerRectPath addClip];
            CGRect outerRectBounds = CGPathGetPathBoundingBox(outerRectPath.CGPath);
            CGContextDrawLinearGradient(context, fillGradient,
                                        CGPointMake(CGRectGetMidX(outerRectBounds), CGRectGetMinY(outerRectBounds)),
                                        CGPointMake(CGRectGetMidX(outerRectBounds), CGRectGetMaxY(outerRectBounds)),
                                        0);
            CGContextEndTransparencyLayer(context);
        }
        CGContextRestoreGState(context);

        ////// outerRect Inner Shadow
        CGRect outerRectBorderRect = CGRectInset([outerRectPath bounds], -glossShadowBlurRadius, -glossShadowBlurRadius);
        outerRectBorderRect = CGRectOffset(outerRectBorderRect, -glossShadowOffset.width, -glossShadowOffset.height);
        outerRectBorderRect = CGRectInset(CGRectUnion(outerRectBorderRect, [outerRectPath bounds]), -1, -1);

        UIBezierPath* outerRectNegativePath = [UIBezierPath bezierPathWithRect: outerRectBorderRect];
        [outerRectNegativePath appendPath: outerRectPath];
        outerRectNegativePath.usesEvenOddFillRule = YES;

        CGContextSaveGState(context);
        {
            float xOffset = glossShadowOffset.width + round(outerRectBorderRect.size.width);
            float yOffset = glossShadowOffset.height;
            CGContextSetShadowWithColor(context,
                                        CGSizeMake(xOffset + copysign(0.1, xOffset), yOffset + copysign(0.1, yOffset)),
                                        glossShadowBlurRadius,
                                        self.glossShadowColor.CGColor);

            [outerRectPath addClip];
            CGAffineTransform transform = CGAffineTransformMakeTranslation(-round(outerRectBorderRect.size.width), 0);
            [outerRectNegativePath applyTransform: transform];
            [[UIColor grayColor] setFill];
            [outerRectNegativePath fill];
        }
        CGContextRestoreGState(context);

        [self.outerStrokeColor setStroke];
        outerRectPath.lineWidth = 1;
        [outerRectPath stroke];

        //// Cleanup
        CFRelease(outerPathRef);
        CGGradientRelease(fillGradient);
        CGColorSpaceRelease(colorSpace);

        UIGraphicsPopContext();
    }
}

#pragma mark Private

- (CGRect)outerRect
{
    return [self outerRect:self.bounds arrowDirection:self.arrowDirection];
}

- (CGRect)innerRect
{
    return [self innerRect:self.bounds arrowDirection:self.arrowDirection];
}

- (CGRect)arrowRect
{
    return [self arrowRect:self.bounds arrowDirection:self.arrowDirection];
}

- (CGRect)outerRect:(CGRect)rect arrowDirection:(WYPopoverArrowDirection)aArrowDirection
{
    CGRect result = rect;

    if (aArrowDirection == WYPopoverArrowDirectionUp || arrowDirection == WYPopoverArrowDirectionDown)
    {
        result.size.height -= arrowHeight;

        if (aArrowDirection == WYPopoverArrowDirectionUp)
        {
            result = CGRectOffset(result, 0, arrowHeight);
        }
    }

    if (aArrowDirection == WYPopoverArrowDirectionLeft || arrowDirection == WYPopoverArrowDirectionRight)
    {
        result.size.width -= arrowHeight;

        if (aArrowDirection == WYPopoverArrowDirectionLeft)
        {
            result = CGRectOffset(result, arrowHeight, 0);
        }
    }

    result = CGRectInset(result, outerShadowBlurRadius, outerShadowBlurRadius);
    result.origin.x -= self.outerShadowOffset.width;
    result.origin.y -= self.outerShadowOffset.height;

    return result;
}

- (CGRect)innerRect:(CGRect)rect arrowDirection:(WYPopoverArrowDirection)aArrowDirection
{
    CGRect result = [self outerRect:rect arrowDirection:aArrowDirection];

    result.origin.x += borderWidth;
    result.origin.y += 0;
    result.size.width -= 2 * borderWidth;
    result.size.height -= borderWidth;

    if (navigationBarHeight == 0 || wantsDefaultContentAppearance)
    {
        result.origin.y += borderWidth;
        result.size.height -= borderWidth;
    }

    result.origin.x += viewContentInsets.left;
    result.origin.y += viewContentInsets.top;
    result.size.width = result.size.width - viewContentInsets.left - viewContentInsets.right;
    result.size.height = result.size.height - viewContentInsets.top - viewContentInsets.bottom;

    if (borderWidth > 0)
    {
        result = CGRectInset(result, -1, -1);
    }

    return result;
}

- (CGRect)arrowRect:(CGRect)rect arrowDirection:(WYPopoverArrowDirection)aArrowDirection
{
    CGRect result = CGRectZero;

    if (arrowHeight > 0)
    {
        result.size = CGSizeMake(arrowBase, arrowHeight);

        if (aArrowDirection == WYPopoverArrowDirectionLeft || arrowDirection == WYPopoverArrowDirectionRight)
        {
            result.size = CGSizeMake(arrowHeight, arrowBase);
        }

        CGRect outerRect = [self outerRect:rect arrowDirection:aArrowDirection];

        if (aArrowDirection == WYPopoverArrowDirectionDown)
        {
            result.origin.x = CGRectGetMidX(outerRect) - result.size.width / 2 + arrowOffset;
            result.origin.y = CGRectGetMaxY(outerRect);
        }

        if (aArrowDirection == WYPopoverArrowDirectionUp)
        {
            result.origin.x = CGRectGetMidX(outerRect) - result.size.width / 2 + arrowOffset;
            result.origin.y = CGRectGetMinY(outerRect) - result.size.height;
        }

        if (aArrowDirection == WYPopoverArrowDirectionRight)
        {
            result.origin.x = CGRectGetMaxX(outerRect);
            result.origin.y = CGRectGetMidY(outerRect) - result.size.height / 2 + arrowOffset;
        }

        if (aArrowDirection == WYPopoverArrowDirectionLeft)
        {
            result.origin.x = CGRectGetMinX(outerRect) - result.size.width;
            result.origin.y = CGRectGetMidY(outerRect) - result.size.height / 2 + arrowOffset;
        }
    }

    return result;
}

- (BOOL)isTouchedAtPoint:(CGPoint)point
{
    BOOL result = NO;

    CGRect outerRect = [self outerRect];
    CGRect arrowRect = [self arrowRect];

    result = (CGRectContainsPoint(outerRect, point) || CGRectContainsPoint(arrowRect, point));

    return result;
}

#pragma mark Memory Management

- (void)dealloc
{
    contentView = nil;
    innerView = nil;
    tintColor = nil;
    outerStrokeColor = nil;
    innerStrokeColor = nil;
    fillTopColor = nil;
    fillBottomColor = nil;
    glossShadowColor = nil;
    outerShadowColor = nil;
    innerShadowColor = nil;
}

@end