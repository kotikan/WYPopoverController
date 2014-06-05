/*
 Version 0.2.2
 
 WYPopoverController is available under the MIT license.
 
 Copyright © 2013 Nicolas CHENG
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included
 in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
 INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
 PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
 HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
 OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
 SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

#import "WYPopoverController.h"
#import "WYPopoverBackgroundView.h"

#import <objc/runtime.h>
#import "WYBasics.h"
#import "WYPopoverBackgroundViewDelegate.h"


////////////////////////////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////////////////////////////

@interface UINavigationController (WYPopover)

@property(nonatomic, assign, getter = isEmbedInPopover) BOOL embedInPopover;

@end

////////////////////////////////////////////////////////////////////////////////////////////////////////

@implementation UINavigationController (WYPopover)

static char const * const UINavigationControllerEmbedInPopoverTagKey = "UINavigationControllerEmbedInPopoverTagKey";

@dynamic embedInPopover;

+ (void)load
{
    Method original, swizzle;
    
    original = class_getInstanceMethod(self, @selector(pushViewController:animated:));
    swizzle = class_getInstanceMethod(self, @selector(sizzled_pushViewController:animated:));
    
    method_exchangeImplementations(original, swizzle);
    
    original = class_getInstanceMethod(self, @selector(setViewControllers:animated:));
    swizzle = class_getInstanceMethod(self, @selector(sizzled_setViewControllers:animated:));
    
    method_exchangeImplementations(original, swizzle);
}

- (BOOL)isEmbedInPopover
{
    BOOL result = NO;
    
    NSNumber *value = objc_getAssociatedObject(self, UINavigationControllerEmbedInPopoverTagKey);
    
    if (value)
    {
        result = [value boolValue];
    }
    
    return result;
}

- (void)setEmbedInPopover:(BOOL)value
{
    objc_setAssociatedObject(self, UINavigationControllerEmbedInPopoverTagKey, [NSNumber numberWithBool:value], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (CGSize)contentSize:(UIViewController *)aViewController
{
    CGSize result = CGSizeZero;
    
#pragma clang diagnostic push
#pragma GCC diagnostic ignored "-Wdeprecated"
    if ([aViewController respondsToSelector:@selector(contentSizeForViewInPopover)])
    {
        result = aViewController.contentSizeForViewInPopover;
    }
#pragma clang diagnostic pop
    
#ifdef WY_BASE_SDK_7_ENABLED
    if ([aViewController respondsToSelector:@selector(preferredContentSize)])
    {
        result = aViewController.preferredContentSize;
    }
#endif
    
    return result;
}

- (void)setContentSize:(CGSize)aContentSize
{
#pragma clang diagnostic push
#pragma GCC diagnostic ignored "-Wdeprecated"
    [self setContentSizeForViewInPopover:aContentSize];
#pragma clang diagnostic pop
    
#ifdef WY_BASE_SDK_7_ENABLED
    if ([self respondsToSelector:@selector(setPreferredContentSize:)]) {
        [self setPreferredContentSize:aContentSize];
    }
#endif
}

- (void)sizzled_pushViewController:(UIViewController *)aViewController animated:(BOOL)aAnimated
{
    if (self.isEmbedInPopover)
    {
#ifdef WY_BASE_SDK_7_ENABLED
        if ([aViewController respondsToSelector:@selector(setEdgesForExtendedLayout:)]) {
            aViewController.edgesForExtendedLayout = UIRectEdgeNone;
        }
#endif
        CGSize contentSize = [self contentSize:aViewController];
        [self setContentSize:contentSize];
    }
    
    [self sizzled_pushViewController:aViewController animated:aAnimated];
    
    if (self.isEmbedInPopover)
    {
        CGSize contentSize = [self contentSize:aViewController];
        [self setContentSize:contentSize];
    }
}

- (void)sizzled_setViewControllers:(NSArray *)aViewControllers animated:(BOOL)aAnimated
{
    NSUInteger count = [aViewControllers count];
    
#ifdef WY_BASE_SDK_7_ENABLED
    if (self.isEmbedInPopover && count > 0)
    {
        for (UIViewController *viewController in aViewControllers) {
            if ([viewController respondsToSelector:@selector(setEdgesForExtendedLayout:)])
            {
                viewController.edgesForExtendedLayout = UIRectEdgeNone;
            }
        }
    }
#endif
    
    [self sizzled_setViewControllers:aViewControllers animated:aAnimated];
    
    if (self.isEmbedInPopover && count > 0)
    {
        UIViewController *topViewController = [aViewControllers objectAtIndex:(count - 1)];
        CGSize contentSize = [self contentSize:topViewController];
        [self setContentSize:contentSize];
    }
}

@end

////////////////////////////////////////////////////////////////////////////////////////////////////////

@interface UIViewController (WYPopover)
@end

////////////////////////////////////////////////////////////////////////////////////////////////////////

@implementation UIViewController (WYPopover)

+ (void)load
{
    Method original, swizzle;
    
#pragma clang diagnostic push
#pragma GCC diagnostic ignored "-Wdeprecated"
    original = class_getInstanceMethod(self, @selector(setContentSizeForViewInPopover:));
    swizzle = class_getInstanceMethod(self, @selector(sizzled_setContentSizeForViewInPopover:));
    method_exchangeImplementations(original, swizzle);
#pragma clang diagnostic pop
    
#ifdef WY_BASE_SDK_7_ENABLED
    original = class_getInstanceMethod(self, @selector(setPreferredContentSize:));
    swizzle = class_getInstanceMethod(self, @selector(sizzled_setPreferredContentSize:));
    
    if (original != NULL) {
        method_exchangeImplementations(original, swizzle);
    }
#endif
}

- (void)sizzled_setContentSizeForViewInPopover:(CGSize)aSize
{
    [self sizzled_setContentSizeForViewInPopover:aSize];
    
    if ([self isKindOfClass:[UINavigationController class]] == NO && self.navigationController != nil)
    {
#pragma clang diagnostic push
#pragma GCC diagnostic ignored "-Wdeprecated"
        [self.navigationController setContentSizeForViewInPopover:aSize];
#pragma clang diagnostic pop
    }
}

- (void)sizzled_setPreferredContentSize:(CGSize)aSize
{
    [self sizzled_setPreferredContentSize:aSize];
    
    if ([self isKindOfClass:[UINavigationController class]] == NO && self.navigationController != nil)
    {
#ifdef WY_BASE_SDK_7_ENABLED
        if ([self respondsToSelector:@selector(setPreferredContentSize:)]) {
            [self.navigationController setPreferredContentSize:aSize];
        }
#endif
    }
}

@end

////////////////////////////////////////////////////////////////////////////////////////////////////////

@interface WYPopoverArea : NSObject
{
}

@property (nonatomic, assign) WYPopoverArrowDirection arrowDirection;
@property (nonatomic, assign) CGSize areaSize;
@property (nonatomic, assign, readonly) float value;

@end

////////////////////////////////////////////////////////////////////////////////////////////////////////

#pragma mark
#pragma mark - WYPopoverArea

@implementation WYPopoverArea

@synthesize arrowDirection;
@synthesize areaSize;
@synthesize value;

- (NSString*)description
{
    NSString* direction = @"";
    
    if (arrowDirection == WYPopoverArrowDirectionUp)
    {
        direction = @"UP";
    }
    else if (arrowDirection == WYPopoverArrowDirectionDown)
    {
        direction = @"DOWN";
    }
    else if (arrowDirection == WYPopoverArrowDirectionLeft)
    {
        direction = @"LEFT";
    }
    else if (arrowDirection == WYPopoverArrowDirectionRight)
    {
        direction = @"RIGHT";
    }
    else if (arrowDirection == WYPopoverArrowDirectionNone)
    {
        direction = @"NONE";
    }
    
    return [NSString stringWithFormat:@"%@ [ %f x %f ]", direction, areaSize.width, areaSize.height];
}

- (float)value
{
    float result = 0;
    
    if (areaSize.width > 0 && areaSize.height > 0)
    {
        float w1 = ceilf(areaSize.width / 10.0);
        float h1 = ceilf(areaSize.height / 10.0);
        
        result = (w1 * h1);
    }
    
    return result;
}

@end

////////////////////////////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////////////////////////////

@interface UIImage (WYPopover)

+ (UIImage *)imageWithColor:(UIColor *)color;

@end

////////////////////////////////////////////////////////////////////////////////////////////////////////

#pragma mark
#pragma mark - UIImage (WYPopover)

@implementation UIImage (WYPopover)

static float edgeSizeFromCornerRadius(float cornerRadius) {
    return cornerRadius * 2 + 1;
}

+ (UIImage *)imageWithColor:(UIColor *)color
{
    return [self imageWithColor:color size:CGSizeMake(8, 8) cornerRadius:0];
}

+ (UIImage *)imageWithColor:(UIColor *)color
               cornerRadius:(float)cornerRadius
{
    float min = edgeSizeFromCornerRadius(cornerRadius);
    
    CGSize minSize = CGSizeMake(min, min);
    
    return [self imageWithColor:color size:minSize cornerRadius:cornerRadius];
}

+ (UIImage *)imageWithColor:(UIColor *)color
                       size:(CGSize)aSize
               cornerRadius:(float)cornerRadius
{
    CGRect rect = CGRectMake(0, 0, aSize.width, aSize.height);
    UIBezierPath *roundedRect = [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:cornerRadius];
    roundedRect.lineWidth = 0;
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0.0f);
    [color setFill];
    [roundedRect fill];
    //[roundedRect stroke];
    //[roundedRect addClip];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return [image resizableImageWithCapInsets:UIEdgeInsetsMake(cornerRadius, cornerRadius, cornerRadius, cornerRadius)];
}

@end

////////////////////////////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////////////////////////////

#pragma mark
#pragma mark - WYPopoverInnerView

////////////////////////////////////////////////////////////////////////////////////////////////////////

@protocol WYPopoverOverlayViewDelegate;

@interface WYPopoverOverlayView : UIView
{
    BOOL testHits;
}

@property(nonatomic, assign) id <WYPopoverOverlayViewDelegate> delegate;
@property(nonatomic, unsafe_unretained) NSArray *passthroughViews;

@end


////////////////////////////////////////////////////////////////////////////////////////////////////////

#pragma mark
#pragma mark - WYPopoverOverlayViewDelegate

@protocol WYPopoverOverlayViewDelegate <NSObject>

@optional
- (void)popoverOverlayViewDidTouch:(WYPopoverOverlayView *)overlayView;

@end

////////////////////////////////////////////////////////////////////////////////////////////////////////

#pragma mark
#pragma mark - WYPopoverOverlayView

@implementation WYPopoverOverlayView

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if ([self.delegate respondsToSelector:@selector(popoverOverlayViewDidTouch:)])
    {
        [self.delegate popoverOverlayViewDidTouch:self];
    }
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    if (testHits) {
        return NO;
    }
    
    UIView *view = [super hitTest:point withEvent:event];
    
    if (view == self)
    {
        testHits = YES;
        UIView *superHitView = [self.superview hitTest:point withEvent:event];
        testHits = NO;
        
        if ([self isPassthroughView:superHitView])
        {
            return superHitView;
        }
    }
    
    return view;
}

- (BOOL)isPassthroughView:(UIView *)view
{
	if (view == nil)
    {
		return NO;
	}
	
	if ([self.passthroughViews containsObject:view])
    {
		return YES;
	}
	
	return [self isPassthroughView:view.superview];
}

#pragma mark - UIAccessibility

- (void)accessibilityElementDidBecomeFocused {
    self.accessibilityLabel = NSLocalizedString(@"Double-tap to dismiss pop-up window.", nil);
}

@end

////////////////////////////////////////////////////////////////////////////////////////////////////////

#pragma mark
#pragma mark - WYPopoverBackgroundViewDelegate

////////////////////////////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////////////////////////////

#pragma mark
#pragma mark - WYPopoverBackgroundView

////////////////////////////////////////////////////////////////////////////

@interface WYPopoverController () <WYPopoverOverlayViewDelegate, WYPopoverBackgroundViewDelegate>
{
    UIViewController        *viewController;
    CGRect                   rect;
    UIView                  *inView;
    WYPopoverOverlayView    *overlayView;
    WYPopoverBackgroundView *backgroundView;
    WYPopoverArrowDirection  permittedArrowDirections;
    BOOL                     animated;
    BOOL                     isListeningNotifications;
    BOOL                     isInterfaceOrientationChanging;
    __weak UIBarButtonItem  *barButtonItem;
    CGRect                   keyboardRect;
    CGRect                   originalStatusBarFrame;
    CGRect                   transitioningToStatusBarFrame;
    CGRect                   originalViewFrame;

    WYPopoverAnimationOptions options;
    
    BOOL themeUpdatesEnabled;
    BOOL themeIsUpdating;
}

- (void)dismissPopoverAnimated:(BOOL)aAnimated
                       options:(WYPopoverAnimationOptions)aAptions
                    completion:(void (^)(void))aCompletion
                  callDelegate:(BOOL)aCallDelegate;

- (WYPopoverArrowDirection)arrowDirectionForRect:(CGRect)aRect
                                          inView:(UIView*)aView
                                     contentSize:(CGSize)aContentSize
                                     arrowHeight:(float)aArrowHeight
                        permittedArrowDirections:(WYPopoverArrowDirection)aArrowDirections;

- (CGSize)sizeForRect:(CGRect)aRect
               inView:(UIView *)aView
          arrowHeight:(float)aArrowHeight
       arrowDirection:(WYPopoverArrowDirection)aArrowDirection;

- (void)registerTheme;
- (void)unregisterTheme;
- (void)updateThemeUI;

- (CGSize)topViewControllerContentSize;

@end

////////////////////////////////////////////////////////////////////////////

#pragma mark
#pragma mark - WYPopoverController

@implementation WYPopoverController

@synthesize delegate;
@synthesize passthroughViews;
@synthesize peekThroughViews;
@synthesize wantsDefaultContentAppearance;
@synthesize popoverVisible;
@synthesize popoverLayoutMargins;
@synthesize popoverContentSize = popoverContentSize_;
@synthesize animationDuration;
@synthesize theme;

static WYPopoverTheme *defaultTheme_ = nil;

+ (void)setDefaultTheme:(WYPopoverTheme *)aTheme
{
    defaultTheme_ = aTheme;
    
    @autoreleasepool {
        WYPopoverBackgroundView *appearance = [WYPopoverBackgroundView appearance];
        appearance.tintColor = aTheme.tintColor;
        appearance.outerStrokeColor = aTheme.outerStrokeColor;
        appearance.innerStrokeColor = aTheme.innerStrokeColor;
        appearance.fillTopColor = aTheme.fillTopColor;
        appearance.fillBottomColor = aTheme.fillBottomColor;
        appearance.glossShadowColor = aTheme.glossShadowColor;
        appearance.glossShadowOffset = aTheme.glossShadowOffset;
        appearance.glossShadowBlurRadius = aTheme.glossShadowBlurRadius;
        appearance.borderWidth = aTheme.borderWidth;
        appearance.arrowBase = aTheme.arrowBase;
        appearance.arrowHeight = aTheme.arrowHeight;
        appearance.outerShadowColor = aTheme.outerShadowColor;
        appearance.outerShadowBlurRadius = aTheme.outerShadowBlurRadius;
        appearance.outerShadowOffset = aTheme.outerShadowOffset;
        appearance.outerCornerRadius = aTheme.outerCornerRadius;
        appearance.minOuterCornerRadius = aTheme.minOuterCornerRadius;
        appearance.innerShadowColor = aTheme.innerShadowColor;
        appearance.innerShadowBlurRadius = aTheme.innerShadowBlurRadius;
        appearance.innerShadowOffset = aTheme.innerShadowOffset;
        appearance.innerCornerRadius = aTheme.innerCornerRadius;
        appearance.viewContentInsets = aTheme.viewContentInsets;
        appearance.overlayColor = aTheme.overlayColor;
    }
}

+ (WYPopoverTheme *)defaultTheme
{
    return defaultTheme_;
}

+ (void)load
{
    [WYPopoverController setDefaultTheme:[WYPopoverTheme theme]];
}

- (id)init
{
    self = [super init];
    
    if (self)
    {
        popoverLayoutMargins = UIEdgeInsetsMake(10, 10, 10, 10);
        keyboardRect = CGRectZero;
        animationDuration = WY_POPOVER_DEFAULT_ANIMATION_DURATION;
        
        themeUpdatesEnabled = NO;
        
        [self setTheme:[WYPopoverController defaultTheme]];
        
        themeIsUpdating = YES;
        
        WYPopoverBackgroundView *appearance = [WYPopoverBackgroundView appearance];
        theme.tintColor = appearance.tintColor;
        theme.outerStrokeColor = appearance.outerStrokeColor;
        theme.innerStrokeColor = appearance.innerStrokeColor;
        theme.fillTopColor = appearance.fillTopColor;
        theme.fillBottomColor = appearance.fillBottomColor;
        theme.glossShadowColor = appearance.glossShadowColor;
        theme.glossShadowOffset = appearance.glossShadowOffset;
        theme.glossShadowBlurRadius = appearance.glossShadowBlurRadius;
        theme.borderWidth = appearance.borderWidth;
        theme.arrowBase = appearance.arrowBase;
        theme.arrowHeight = appearance.arrowHeight;
        theme.outerShadowColor = appearance.outerShadowColor;
        theme.outerShadowBlurRadius = appearance.outerShadowBlurRadius;
        theme.outerShadowOffset = appearance.outerShadowOffset;
        theme.outerCornerRadius = appearance.outerCornerRadius;
        theme.minOuterCornerRadius = appearance.minOuterCornerRadius;
        theme.innerShadowColor = appearance.innerShadowColor;
        theme.innerShadowBlurRadius = appearance.innerShadowBlurRadius;
        theme.innerShadowOffset = appearance.innerShadowOffset;
        theme.innerCornerRadius = appearance.innerCornerRadius;
        theme.viewContentInsets = appearance.viewContentInsets;
        theme.overlayColor = appearance.overlayColor;

        themeIsUpdating = NO;
        themeUpdatesEnabled = YES;
        
        popoverContentSize_ = CGSizeZero;
        originalViewFrame = CGRectNull;
        transitioningToStatusBarFrame = CGRectNull;
    }
    
    return self;
}

- (id)initWithContentViewController:(UIViewController *)aViewController
{
    self = [self init];
    
    if (self)
    {
        viewController = aViewController;
    }
    
    return self;
}

- (void)setTheme:(WYPopoverTheme *)value
{
    [self unregisterTheme];
    theme = value;
    [self registerTheme];
    [self updateThemeUI];
    
    themeIsUpdating = NO;
}

- (void)registerTheme
{
    if (theme == nil) return;
    
    NSArray *keypaths = [theme observableKeypaths];
    for (NSString *keypath in keypaths) {
		[theme addObserver:self forKeyPath:keypath options:NSKeyValueObservingOptionNew context:NULL];
	}
}

- (void)unregisterTheme
{
    if (theme == nil) return;
    
    @try {
        NSArray *keypaths = [theme observableKeypaths];
        for (NSString *keypath in keypaths) {
            [theme removeObserver:self forKeyPath:keypath];
        }
    }
    @catch (NSException * __unused exception) {}
}

- (void)updateThemeUI
{
    if (theme == nil || themeUpdatesEnabled == NO || themeIsUpdating == YES) return;
    
    if (backgroundView != nil) {
        backgroundView.tintColor = theme.tintColor;
        backgroundView.outerStrokeColor = theme.outerStrokeColor;
        backgroundView.innerStrokeColor = theme.innerStrokeColor;
        backgroundView.fillTopColor = theme.fillTopColor;
        backgroundView.fillBottomColor = theme.fillBottomColor;
        backgroundView.glossShadowColor = theme.glossShadowColor;
        backgroundView.glossShadowOffset = theme.glossShadowOffset;
        backgroundView.glossShadowBlurRadius = theme.glossShadowBlurRadius;
        backgroundView.borderWidth = theme.borderWidth;
        backgroundView.arrowBase = theme.arrowBase;
        backgroundView.arrowHeight = theme.arrowHeight;
        backgroundView.outerShadowColor = theme.outerShadowColor;
        backgroundView.outerShadowBlurRadius = theme.outerShadowBlurRadius;
        backgroundView.outerShadowOffset = theme.outerShadowOffset;
        backgroundView.outerCornerRadius = theme.outerCornerRadius;
        backgroundView.minOuterCornerRadius = theme.minOuterCornerRadius;
        backgroundView.innerShadowColor = theme.innerShadowColor;
        backgroundView.innerShadowBlurRadius = theme.innerShadowBlurRadius;
        backgroundView.innerShadowOffset = theme.innerShadowOffset;
        backgroundView.innerCornerRadius = theme.innerCornerRadius;
        backgroundView.viewContentInsets = theme.viewContentInsets;
        [backgroundView setNeedsDisplay];
    }
    
    if (overlayView != nil) {
        overlayView.backgroundColor = theme.overlayColor;
    }
    
    [self positionPopover:NO];
    
    [self setPopoverNavigationBarBackgroundImage];
}

- (void)beginThemeUpdates
{
    themeIsUpdating = YES;
}

- (void)endThemeUpdates
{
    themeIsUpdating = NO;
    [self updateThemeUI];
}

- (BOOL)isPopoverVisible
{
    BOOL result = (overlayView != nil);
    return result;
}

- (UIViewController *)contentViewController
{
    return viewController;
}

- (CGSize)topViewControllerContentSize
{
    CGSize result = CGSizeZero;
    
    UIViewController *topViewController = viewController;
    
    if ([viewController isKindOfClass:[UINavigationController class]] == YES)
    {
        UINavigationController *navigationController = (UINavigationController *)viewController;
        topViewController = [navigationController topViewController];
    }
    
#ifdef WY_BASE_SDK_7_ENABLED
    if ([topViewController respondsToSelector:@selector(preferredContentSize)])
    {
        result = topViewController.preferredContentSize;
    }
#endif
    
    if (CGSizeEqualToSize(result, CGSizeZero))
    {
#pragma clang diagnostic push
#pragma GCC diagnostic ignored "-Wdeprecated"
        result = topViewController.contentSizeForViewInPopover;
#pragma clang diagnostic pop
    }
    
    if (CGSizeEqualToSize(result, CGSizeZero))
    {
        CGSize windowSize = [[UIApplication sharedApplication] keyWindow].bounds.size;
        
        UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
        
        result = CGSizeMake(320, UIDeviceOrientationIsLandscape(orientation) ? windowSize.width : windowSize.height);
    }
    
    return result;
}

- (CGSize)popoverContentSize
{
    CGSize result = popoverContentSize_;
    
    if (CGSizeEqualToSize(result, CGSizeZero))
    {
        result = [self topViewControllerContentSize];
    }
    
    return result;
}

- (void)setPopoverContentSize:(CGSize)size
{
    popoverContentSize_ = size;
    [self positionPopover:YES];
}

- (void)presentPopoverFromRect:(CGRect)aRect
                        inView:(UIView *)aView
      permittedArrowDirections:(WYPopoverArrowDirection)aArrowDirections
                      animated:(BOOL)aAnimated
{
    [self presentPopoverFromRect:aRect
                          inView:aView
        permittedArrowDirections:aArrowDirections
                        animated:aAnimated
                      completion:nil];
}

- (void)presentPopoverFromRect:(CGRect)aRect
                        inView:(UIView *)aView
      permittedArrowDirections:(WYPopoverArrowDirection)aArrowDirections
                      animated:(BOOL)aAnimated
                    completion:(void (^)(void))completion
{
    [self presentPopoverFromRect:aRect
                          inView:aView
        permittedArrowDirections:aArrowDirections
                        animated:aAnimated
                         options:WYPopoverAnimationOptionFade
                      completion:completion];
}

- (void)presentPopoverFromRect:(CGRect)aRect
                        inView:(UIView *)aView
      permittedArrowDirections:(WYPopoverArrowDirection)aArrowDirections
                      animated:(BOOL)aAnimated
                       options:(WYPopoverAnimationOptions)aOptions
{
    [self presentPopoverFromRect:aRect
                          inView:aView
        permittedArrowDirections:aArrowDirections
                        animated:aAnimated
                         options:aOptions
                      completion:nil];
}

- (void)presentPopoverFromRect:(CGRect)aRect
                        inView:(UIView *)aView
      permittedArrowDirections:(WYPopoverArrowDirection)aArrowDirections
                      animated:(BOOL)aAnimated
                       options:(WYPopoverAnimationOptions)aOptions
                    completion:(void (^)(void))completion
{
    NSAssert((aArrowDirections != WYPopoverArrowDirectionUnknown), @"WYPopoverArrowDirection must not be UNKNOWN");
    
    rect = aRect;
    inView = aView;
    permittedArrowDirections = aArrowDirections;
    animated = aAnimated;
    options = aOptions;
    originalStatusBarFrame = [[UIApplication sharedApplication] statusBarFrame];

    CGSize contentViewSize = self.popoverContentSize;
    
    if (overlayView == nil)
    {
        overlayView = [[WYPopoverOverlayView alloc] initWithFrame:inView.window.bounds];
        overlayView.autoresizesSubviews = NO;
        overlayView.isAccessibilityElement = YES;
        overlayView.accessibilityTraits = UIAccessibilityTraitNone;
        overlayView.delegate = self;
        overlayView.passthroughViews = passthroughViews;
        
        backgroundView = [[WYPopoverBackgroundView alloc] initWithContentSize:contentViewSize];
        backgroundView.appearing = YES;
        backgroundView.isAccessibilityElement = YES;
        backgroundView.accessibilityTraits = UIAccessibilityTraitNone;
        
        backgroundView.delegate = self;
        backgroundView.hidden = YES;
        
        [inView.window addSubview:backgroundView];
        [inView.window insertSubview:overlayView belowSubview:backgroundView];
    }
    
    [self updateThemeUI];
    
    __weak __typeof__(self) weakSelf = self;
    
    void (^completionBlock)(BOOL) = ^(BOOL animated) {
        
        __typeof__(self) strongSelf = weakSelf;
        
        if (strongSelf)
        {
            if ([strongSelf->viewController isKindOfClass:[UINavigationController class]] == NO)
            {
                [strongSelf->viewController viewDidAppear:YES];
            }
            
            if ([strongSelf->viewController respondsToSelector:@selector(preferredContentSize)])
            {
                [strongSelf->viewController addObserver:self forKeyPath:NSStringFromSelector(@selector(preferredContentSize)) options:0 context:nil];
            }
            else
            {
                [strongSelf->viewController addObserver:self forKeyPath:NSStringFromSelector(@selector(contentSizeForViewInPopover)) options:0 context:nil];
            }
            
            strongSelf->backgroundView.appearing = NO;
        }
        
        if (completion)
        {
            completion();
        }
        else if (strongSelf && strongSelf->delegate && [strongSelf->delegate respondsToSelector:@selector(popoverControllerDidPresentPopover:)])
        {
            [strongSelf->delegate popoverControllerDidPresentPopover:strongSelf];
        }
        
        
    };
    
#ifdef WY_BASE_SDK_7_ENABLED
    if ([inView.window respondsToSelector:@selector(setTintAdjustmentMode:)]) {
        for (UIView *subview in inView.window.subviews) {
            if (subview != backgroundView) {
                [subview setTintAdjustmentMode:UIViewTintAdjustmentModeDimmed];
            }
        }
    }
#endif
    
    backgroundView.hidden = NO;
    
    if (animated)
    {
        if ((options & WYPopoverAnimationOptionFade) == WYPopoverAnimationOptionFade)
        {
            overlayView.alpha = 0;
            backgroundView.alpha = 0;
        }
        
        [viewController viewWillAppear:YES];
        
        CGAffineTransform endTransform = backgroundView.transform;
        
        if ((options & WYPopoverAnimationOptionScale) == WYPopoverAnimationOptionScale)
        {
            CGAffineTransform startTransform = [self transformForArrowDirection:backgroundView.arrowDirection];
            backgroundView.transform = startTransform;
        }
        
        [UIView animateWithDuration:animationDuration animations:^{
            __typeof__(self) strongSelf = weakSelf;
            
            if (strongSelf)
            {
                strongSelf->overlayView.alpha = 1;
                strongSelf->backgroundView.alpha = 1;
                strongSelf->backgroundView.transform = endTransform;
            }
        } completion:^(BOOL finished) {
            completionBlock(YES);
        }];
        for (UIView *view in peekThroughViews) {
            view.alpha = 1;
            CGRect frame = [overlayView convertRect:view.frame fromView:view.superview];
            [view removeFromSuperview];
            view.frame = frame;
            [overlayView addSubview:view];
        }
    }
    else
    {
        [viewController viewWillAppear:NO];
        completionBlock(NO);
    }
    
    if (isListeningNotifications == NO)
    {
        isListeningNotifications = YES;
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(willChangeStatusBarFrame:)
                                                     name:UIApplicationWillChangeStatusBarFrameNotification
                                                   object:nil];

        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(didChangeStatusBarOrientation:)
                                                     name:UIApplicationDidChangeStatusBarOrientationNotification
                                                   object:nil];
        
        [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(didChangeDeviceOrientation:)
                                                     name:UIDeviceOrientationDidChangeNotification
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardWillShow:)
                                                     name:UIKeyboardWillShowNotification object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardWillHide:)
                                                     name:UIKeyboardWillHideNotification object:nil];
    }
}

- (void)presentPopoverFromBarButtonItem:(UIBarButtonItem *)aItem
               permittedArrowDirections:(WYPopoverArrowDirection)aArrowDirections
                               animated:(BOOL)aAnimated
{
    [self presentPopoverFromBarButtonItem:aItem
                 permittedArrowDirections:aArrowDirections
                                 animated:aAnimated
                               completion:nil];
}

- (void)presentPopoverFromBarButtonItem:(UIBarButtonItem *)aItem
               permittedArrowDirections:(WYPopoverArrowDirection)aArrowDirections
                               animated:(BOOL)aAnimated
                             completion:(void (^)(void))completion
{
    [self presentPopoverFromBarButtonItem:aItem
                 permittedArrowDirections:aArrowDirections
                                 animated:aAnimated
                                  options:WYPopoverAnimationOptionFade
                               completion:completion];
}

- (void)presentPopoverFromBarButtonItem:(UIBarButtonItem *)aItem
               permittedArrowDirections:(WYPopoverArrowDirection)aArrowDirections
                               animated:(BOOL)aAnimated
                                options:(WYPopoverAnimationOptions)aOptions
{
    [self presentPopoverFromBarButtonItem:aItem
                 permittedArrowDirections:aArrowDirections
                                 animated:aAnimated
                                  options:aOptions
                               completion:nil];
}

- (void)presentPopoverFromBarButtonItem:(UIBarButtonItem *)aItem
               permittedArrowDirections:(WYPopoverArrowDirection)aArrowDirections
                               animated:(BOOL)aAnimated
                                options:(WYPopoverAnimationOptions)aOptions
                             completion:(void (^)(void))completion
{
    barButtonItem = aItem;
    UIView *itemView = [barButtonItem valueForKey:@"view"];
    aArrowDirections = WYPopoverArrowDirectionDown | WYPopoverArrowDirectionUp;
    [self presentPopoverFromRect:itemView.bounds
                          inView:itemView
        permittedArrowDirections:aArrowDirections
                        animated:aAnimated
                         options:aOptions
                      completion:completion];
}

- (void)presentPopoverAsDialogAnimated:(BOOL)aAnimated
{
    [self presentPopoverAsDialogAnimated:aAnimated
                              completion:nil];
}

- (void)presentPopoverAsDialogAnimated:(BOOL)aAnimated
                            completion:(void (^)(void))completion
{
    [self presentPopoverAsDialogAnimated:aAnimated
                                 options:WYPopoverAnimationOptionFade
                              completion:completion];
}

- (void)presentPopoverAsDialogAnimated:(BOOL)aAnimated
                               options:(WYPopoverAnimationOptions)aOptions
{
    [self presentPopoverAsDialogAnimated:aAnimated
                                 options:aOptions
                              completion:nil];
}

- (void)presentPopoverAsDialogAnimated:(BOOL)aAnimated
                               options:(WYPopoverAnimationOptions)aOptions
                            completion:(void (^)(void))completion
{
    [self presentPopoverFromRect:CGRectZero
                          inView:nil
        permittedArrowDirections:WYPopoverArrowDirectionNone
                        animated:aAnimated
                         options:aOptions
                      completion:completion];
}

- (CGAffineTransform)transformForArrowDirection:(WYPopoverArrowDirection)arrowDirection
{
    CGAffineTransform transform = backgroundView.transform;
    
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];

    CGSize containerViewSize = backgroundView.frame.size;
    
    if (backgroundView.arrowHeight > 0)
    {
        if (UIDeviceOrientationIsLandscape(orientation)) {
            containerViewSize.width = backgroundView.frame.size.height;
            containerViewSize.height = backgroundView.frame.size.width;
        }
        
        //WY_LOG(@"containerView.arrowOffset = %f", containerView.arrowOffset);
        //WY_LOG(@"containerViewSize = %@", NSStringFromCGSize(containerViewSize));
        //WY_LOG(@"orientation = %@", WYStringFromOrientation(orientation));
        
        if (arrowDirection == WYPopoverArrowDirectionDown)
        {
            transform = CGAffineTransformTranslate(transform, backgroundView.arrowOffset, containerViewSize.height / 2);
        }
        
        if (arrowDirection == WYPopoverArrowDirectionUp)
        {
            transform = CGAffineTransformTranslate(transform, backgroundView.arrowOffset, -containerViewSize.height / 2);
        }
        
        if (arrowDirection == WYPopoverArrowDirectionRight)
        {
            transform = CGAffineTransformTranslate(transform, containerViewSize.width / 2, backgroundView.arrowOffset);
        }
        
        if (arrowDirection == WYPopoverArrowDirectionLeft)
        {
            transform = CGAffineTransformTranslate(transform, -containerViewSize.width / 2, backgroundView.arrowOffset);
        }
    }
    
    transform = CGAffineTransformScale(transform, 0.01, 0.01);
    
    return transform;
}

- (void)setPopoverNavigationBarBackgroundImage
{
    if ([viewController isKindOfClass:[UINavigationController class]] == YES)
    {
        UINavigationController *navigationController = (UINavigationController *)viewController;
        navigationController.embedInPopover = YES;
        
#ifdef WY_BASE_SDK_7_ENABLED
        if ([navigationController respondsToSelector:@selector(setEdgesForExtendedLayout:)])
        {
            UIViewController *topViewController = [navigationController topViewController];
            [topViewController setEdgesForExtendedLayout:UIRectEdgeNone];
        }
#endif
        
        if (wantsDefaultContentAppearance == NO)
        {
            [navigationController.navigationBar setBackgroundImage:[UIImage imageWithColor:[UIColor clearColor]] forBarMetrics:UIBarMetricsDefault];
        }
    }
    
    viewController.view.clipsToBounds = YES;
    
    if (backgroundView.borderWidth == 0)
    {
        viewController.view.layer.cornerRadius = backgroundView.outerCornerRadius;
    }
}

- (void)positionPopover:(BOOL)aAnimated
{
    CGRect savedContainerFrame = backgroundView.frame;
    
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    
    CGSize contentViewSize = self.popoverContentSize;
    CGSize minContainerSize = WY_POPOVER_MIN_SIZE;
    
    CGRect viewFrame;
    CGRect containerFrame = CGRectZero;
    float minX, maxX, minY, maxY, offset = 0;
    CGSize containerViewSize = CGSizeZero;
    
    float overlayWidth = UIInterfaceOrientationIsPortrait(orientation) ? overlayView.bounds.size.width : overlayView.bounds.size.height;
    float overlayHeight = UIInterfaceOrientationIsPortrait(orientation) ? overlayView.bounds.size.height : overlayView.bounds.size.width;
    
    float keyboardHeight = UIInterfaceOrientationIsPortrait(orientation) ? keyboardRect.size.height : keyboardRect.size.width;
    
    if (delegate && [delegate respondsToSelector:@selector(popoverControllerShouldIgnoreKeyboardBounds:)]) {
        BOOL shouldIgnore = [delegate popoverControllerShouldIgnoreKeyboardBounds:self];
        
        if (shouldIgnore) {
            keyboardHeight = 0;
        }
    }
    
    WYPopoverArrowDirection arrowDirection = permittedArrowDirections;
    
    overlayView.bounds = inView.window.bounds;
    backgroundView.transform = CGAffineTransformIdentity;


    if (CGRectIsNull(originalViewFrame)) {
        originalViewFrame = [inView convertRect:rect toView:nil];
        originalViewFrame = WYRectInWindowBounds(originalViewFrame, orientation);
    }
    viewFrame = originalViewFrame;

    minX = popoverLayoutMargins.left;
    maxX = overlayWidth - popoverLayoutMargins.right;
    minY = WYStatusBarHeight() + popoverLayoutMargins.top;
    maxY = overlayHeight - popoverLayoutMargins.bottom - keyboardHeight;
    
    // Which direction ?
    //
    arrowDirection = [self arrowDirectionForRect:rect
                                          inView:inView
                                     contentSize:contentViewSize
                                     arrowHeight:backgroundView.arrowHeight
                        permittedArrowDirections:arrowDirection];
    
    // Position of the popover
    //
    
    minX -= backgroundView.outerShadowInsets.left;
    maxX += backgroundView.outerShadowInsets.right;
    minY -= backgroundView.outerShadowInsets.top;
    maxY += backgroundView.outerShadowInsets.bottom;
    
    if (arrowDirection == WYPopoverArrowDirectionDown)
    {
        backgroundView.arrowDirection = WYPopoverArrowDirectionDown;
        containerViewSize = [backgroundView sizeThatFits:contentViewSize];
        
        containerFrame = CGRectZero;
        containerFrame.size = containerViewSize;
        containerFrame.size.width = MIN(maxX - minX, containerFrame.size.width);
        containerFrame.size.height = MIN(maxY - minY, containerFrame.size.height);
        
        backgroundView.frame = CGRectIntegral(containerFrame);
        
        backgroundView.center = CGPointMake(viewFrame.origin.x + viewFrame.size.width / 2, viewFrame.origin.y + viewFrame.size.height / 2);
        
        containerFrame = backgroundView.frame;
        
        offset = 0;
        
        if (containerFrame.origin.x < minX)
        {
            offset = minX - containerFrame.origin.x;
            containerFrame.origin.x = minX;
            offset = -offset;
        }
        else if (containerFrame.origin.x + containerFrame.size.width > maxX)
        {
            offset = (backgroundView.frame.origin.x + backgroundView.frame.size.width) - maxX;
            containerFrame.origin.x -= offset;
        }
        
        backgroundView.arrowOffset = offset;
        offset = backgroundView.frame.size.height / 2 + viewFrame.size.height / 2 - backgroundView.outerShadowInsets.bottom;
        
        containerFrame.origin.y -= offset;
        
        if (containerFrame.origin.y < minY)
        {
            offset = minY - containerFrame.origin.y;
            containerFrame.size.height -= offset;
            
            if (containerFrame.size.height < minContainerSize.height)
            {
                // popover is overflowing
                offset -= (minContainerSize.height - containerFrame.size.height);
                containerFrame.size.height = minContainerSize.height;
            }
            
            containerFrame.origin.y += offset;
        }
    }
    
    if (arrowDirection == WYPopoverArrowDirectionUp)
    {
        backgroundView.arrowDirection = WYPopoverArrowDirectionUp;
        containerViewSize = [backgroundView sizeThatFits:contentViewSize];
        
        containerFrame = CGRectZero;
        containerFrame.size = containerViewSize;
        containerFrame.size.width = MIN(maxX - minX, containerFrame.size.width);
        containerFrame.size.height = MIN(maxY - minY, containerFrame.size.height);
        
        backgroundView.frame = containerFrame;
        
        backgroundView.center = CGPointMake(viewFrame.origin.x + viewFrame.size.width / 2, viewFrame.origin.y + viewFrame.size.height / 2);
        
        containerFrame = backgroundView.frame;
        
        offset = 0;
        
        if (containerFrame.origin.x < minX)
        {
            offset = minX - containerFrame.origin.x;
            containerFrame.origin.x = minX;
            offset = -offset;
        }
        else if (containerFrame.origin.x + containerFrame.size.width > maxX)
        {
            offset = (backgroundView.frame.origin.x + backgroundView.frame.size.width) - maxX;
            containerFrame.origin.x -= offset;
        }
        
        backgroundView.arrowOffset = offset;
        offset = backgroundView.frame.size.height / 2 + viewFrame.size.height / 2 - backgroundView.outerShadowInsets.top;
        
        containerFrame.origin.y += offset;
        
        if (containerFrame.origin.y + containerFrame.size.height > maxY)
        {
            offset = (containerFrame.origin.y + containerFrame.size.height) - maxY;
            containerFrame.size.height -= offset;
            
            if (containerFrame.size.height < minContainerSize.height)
            {
                // popover is overflowing
                containerFrame.size.height = minContainerSize.height;
            }
        }
    }
    
    if (arrowDirection == WYPopoverArrowDirectionRight)
    {
        backgroundView.arrowDirection = WYPopoverArrowDirectionRight;
        containerViewSize = [backgroundView sizeThatFits:contentViewSize];
        
        containerFrame = CGRectZero;
        containerFrame.size = containerViewSize;
        containerFrame.size.width = MIN(maxX - minX, containerFrame.size.width);
        containerFrame.size.height = MIN(maxY - minY, containerFrame.size.height);
        
        backgroundView.frame = CGRectIntegral(containerFrame);
        
        backgroundView.center = CGPointMake(viewFrame.origin.x + viewFrame.size.width / 2, viewFrame.origin.y + viewFrame.size.height / 2);
        
        containerFrame = backgroundView.frame;
        
        offset = backgroundView.frame.size.width / 2 + viewFrame.size.width / 2 - backgroundView.outerShadowInsets.right;
        
        containerFrame.origin.x -= offset;
        
        if (containerFrame.origin.x < minX)
        {
            offset = minX - containerFrame.origin.x;
            containerFrame.size.width -= offset;
            
            if (containerFrame.size.width < minContainerSize.width)
            {
                // popover is overflowing
                offset -= (minContainerSize.width - containerFrame.size.width);
                containerFrame.size.width = minContainerSize.width;
            }
            
            containerFrame.origin.x += offset;
        }
        
        offset = 0;
        
        if (containerFrame.origin.y < minY)
        {
            offset = minY - containerFrame.origin.y;
            containerFrame.origin.y = minY;
            offset = -offset;
        }
        else if (containerFrame.origin.y + containerFrame.size.height > maxY)
        {
            offset = (backgroundView.frame.origin.y + backgroundView.frame.size.height) - maxY;
            containerFrame.origin.y -= offset;
        }
        
        backgroundView.arrowOffset = offset;
    }
    
    if (arrowDirection == WYPopoverArrowDirectionLeft)
    {
        backgroundView.arrowDirection = WYPopoverArrowDirectionLeft;
        containerViewSize = [backgroundView sizeThatFits:contentViewSize];
        
        containerFrame = CGRectZero;
        containerFrame.size = containerViewSize;
        containerFrame.size.width = MIN(maxX - minX, containerFrame.size.width);
        containerFrame.size.height = MIN(maxY - minY, containerFrame.size.height);
        backgroundView.frame = containerFrame;
        
        backgroundView.center = CGPointMake(viewFrame.origin.x + viewFrame.size.width / 2, viewFrame.origin.y + viewFrame.size.height / 2);
        
        containerFrame = CGRectIntegral(backgroundView.frame);
        
        offset = backgroundView.frame.size.width / 2 + viewFrame.size.width / 2 - backgroundView.outerShadowInsets.left;
        
        containerFrame.origin.x += offset;
        
        if (containerFrame.origin.x + containerFrame.size.width > maxX)
        {
            offset = (containerFrame.origin.x + containerFrame.size.width) - maxX;
            containerFrame.size.width -= offset;
            
            if (containerFrame.size.width < minContainerSize.width)
            {
                // popover is overflowing
                containerFrame.size.width = minContainerSize.width;
            }
        }
        
        offset = 0;
        
        if (containerFrame.origin.y < minY)
        {
            offset = minY - containerFrame.origin.y;
            containerFrame.origin.y = minY;
            offset = -offset;
        }
        else if (containerFrame.origin.y + containerFrame.size.height > maxY)
        {
            offset = (backgroundView.frame.origin.y + backgroundView.frame.size.height) - maxY;
            containerFrame.origin.y -= offset;
        }
        
        backgroundView.arrowOffset = offset;
    }
    
    if (arrowDirection == WYPopoverArrowDirectionNone)
    {
        backgroundView.arrowDirection = WYPopoverArrowDirectionNone;
        containerViewSize = [backgroundView sizeThatFits:contentViewSize];
        
        containerFrame = CGRectZero;
        containerFrame.size = containerViewSize;
        containerFrame.size.width = MIN(maxX - minX, containerFrame.size.width);
        containerFrame.size.height = MIN(maxY - minY, containerFrame.size.height);
        backgroundView.frame = CGRectIntegral(containerFrame);
        
        backgroundView.center = CGPointMake(minX + (maxX - minX) / 2, minY + (maxY - minY) / 2);
        
        containerFrame = backgroundView.frame;
        
        backgroundView.arrowOffset = offset;
    }
    
    containerFrame = CGRectIntegral(containerFrame);
    
    backgroundView.frame = containerFrame;
    
    backgroundView.wantsDefaultContentAppearance = wantsDefaultContentAppearance;
    
    [backgroundView setViewController:viewController];
    
    // keyboard support
    //
    if (keyboardHeight > 0) {
        
        float keyboardY = UIInterfaceOrientationIsPortrait(orientation) ? keyboardRect.origin.y : keyboardRect.origin.x;
        
        float yOffset = containerFrame.origin.y + containerFrame.size.height - keyboardY;
        
        if (yOffset > 0) {
            
            if (containerFrame.origin.y - yOffset < minY) {
                yOffset -= minY - (containerFrame.origin.y - yOffset);
            }
            
            if ([delegate respondsToSelector:@selector(popoverController:willTranslatePopoverWithYOffset:)])
            {
                [delegate popoverController:self willTranslatePopoverWithYOffset:&yOffset];
            }
            
            containerFrame.origin.y -= yOffset;
        }
    }

    // status bar support
    if (!CGRectIsNull(transitioningToStatusBarFrame)) {
        CGFloat yOffset = transitioningToStatusBarFrame.size.height - originalStatusBarFrame.size.height;
        containerFrame.origin.y += yOffset;
        transitioningToStatusBarFrame = CGRectNull;
    }

    CGPoint containerOrigin = containerFrame.origin;
    
    backgroundView.transform = CGAffineTransformMakeRotation(WYInterfaceOrientationAngleOfOrientation(orientation));
    
    containerFrame = backgroundView.frame;
    
    containerFrame.origin = WYPointRelativeToOrientation(containerOrigin, containerFrame.size, orientation);

    if (aAnimated == YES) {
        backgroundView.frame = savedContainerFrame;
        __weak __typeof__(self) weakSelf = self;
        [UIView animateWithDuration:0.35f animations:^{
            __typeof__(self) strongSelf = weakSelf;
            strongSelf->backgroundView.frame = containerFrame;
        }];
    } else {
        backgroundView.frame = containerFrame;
    }
    
//    WY_LOG(@"popoverContainerView.frame = %@", NSStringFromCGRect(backgroundView.frame));
}

- (void)dismissPopoverAnimated:(BOOL)aAnimated
{
    [self dismissPopoverAnimated:aAnimated
                         options:options
                      completion:nil];
}

- (void)dismissPopoverAnimated:(BOOL)aAnimated
                    completion:(void (^)(void))completion
{
    [self dismissPopoverAnimated:aAnimated
                         options:options
                      completion:completion];
}

- (void)dismissPopoverAnimated:(BOOL)aAnimated
                       options:(WYPopoverAnimationOptions)aOptions
{
    [self dismissPopoverAnimated:aAnimated
                         options:aOptions
                      completion:nil];
}

- (void)dismissPopoverAnimated:(BOOL)aAnimated
                       options:(WYPopoverAnimationOptions)aOptions
                    completion:(void (^)(void))completion
{
    [self dismissPopoverAnimated:aAnimated
                         options:aOptions
                      completion:completion
                    callDelegate:NO];
}

- (void)dismissPopoverAnimated:(BOOL)aAnimated
                       options:(WYPopoverAnimationOptions)aOptions
                    completion:(void (^)(void))completion
                  callDelegate:(BOOL)callDelegate
{
    float duration = self.animationDuration;
    WYPopoverAnimationOptions style = aOptions;
    
    __weak __typeof__(self) weakSelf = self;
    
    void (^afterCompletionBlock)() = ^() {
        
#ifdef WY_BASE_SDK_7_ENABLED
        if ([inView.window respondsToSelector:@selector(setTintAdjustmentMode:)]) {
            for (UIView *subview in inView.window.subviews) {
                if (subview != backgroundView) {
                    [subview setTintAdjustmentMode:UIViewTintAdjustmentModeAutomatic];
                }
            }
        }
#endif
        
        __typeof__(self) strongSelf = weakSelf;
        
        if (strongSelf)
        {
            strongSelf->backgroundView = nil;
            
            [strongSelf->overlayView removeFromSuperview];
            strongSelf->overlayView = nil;
            
            if ([strongSelf->viewController isKindOfClass:[UINavigationController class]] == NO)
            {
                [strongSelf->viewController viewDidDisappear:aAnimated];
            }
            
            if (completion)
            {
                completion();
            }
            else if (callDelegate)
            {
                if (strongSelf->delegate && [strongSelf->delegate respondsToSelector:@selector(popoverControllerDidDismissPopover:)])
                {
                    [strongSelf->delegate popoverControllerDidDismissPopover:strongSelf];
                }
            }
        }
    };
    
    void (^completionBlock)() = ^() {
        
        __typeof__(self) strongSelf = weakSelf;
        [strongSelf->backgroundView removeFromSuperview];
        
        if (aAnimated)
        {
            [UIView animateWithDuration:duration animations:^{
                __typeof__(self) strongSelf = weakSelf;
                
                if (strongSelf)
                {
                    strongSelf->overlayView.alpha = 0;
                    for (UIView *view in peekThroughViews) {
                        view.alpha = 0;
                    }
                }
            } completion:^(BOOL finished) {
                afterCompletionBlock();
            }];
        }
        else
        {
            afterCompletionBlock();
        }
    };
    
    if (isListeningNotifications == YES)
    {
        isListeningNotifications = NO;
        
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:UIApplicationDidChangeStatusBarOrientationNotification
                                                      object:nil];
        
        [[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:UIDeviceOrientationDidChangeNotification
                                                      object:nil];
        
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:UIKeyboardWillShowNotification
                                                      object:nil];
        
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:UIKeyboardWillHideNotification
                                                      object:nil];
    }
    
    if ([viewController isKindOfClass:[UINavigationController class]] == NO)
    {
        [viewController viewWillDisappear:aAnimated];
    }
    
    @try {
        if ([viewController respondsToSelector:@selector(preferredContentSize)]) {
            [viewController removeObserver:self forKeyPath:NSStringFromSelector(@selector(preferredContentSize))];
        } else {
            [viewController removeObserver:self forKeyPath:NSStringFromSelector(@selector(contentSizeForViewInPopover))];
        }
    }
    @catch (NSException * __unused exception) {}
    
    if (aAnimated)
    {
        [UIView animateWithDuration:duration animations:^{
            __typeof__(self) strongSelf = weakSelf;
            
            if (strongSelf)
            {
                if ((style & WYPopoverAnimationOptionFade) == WYPopoverAnimationOptionFade)
                {
                    strongSelf->backgroundView.alpha = 0;
                }
                
                if ((style & WYPopoverAnimationOptionScale) == WYPopoverAnimationOptionScale)
                {
                    CGAffineTransform endTransform = [self transformForArrowDirection:strongSelf->backgroundView.arrowDirection];
                    strongSelf->backgroundView.transform = endTransform;
                }
            }
        } completion:^(BOOL finished) {
            completionBlock();
        }];
    }
    else
    {
        completionBlock();
    }
}

#pragma mark KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (object == viewController)
    {
        if ([keyPath isEqualToString:NSStringFromSelector(@selector(preferredContentSize))]
            || [keyPath isEqualToString:NSStringFromSelector(@selector(contentSizeForViewInPopover))])
        {
            CGSize contentSize = [self topViewControllerContentSize];
            [self setPopoverContentSize:contentSize];
        }
    }
    else if (object == theme)
    {
        [self updateThemeUI];
    }
}

#pragma mark WYPopoverOverlayViewDelegate

- (void)popoverOverlayViewDidTouch:(WYPopoverOverlayView *)aOverlayView
{
    //BOOL isTouched = [containerView isTouchedAtPoint:[containerView convertPoint:aPoint fromView:aOverlayView]];
    
    //if (!isTouched)
    //{
        BOOL shouldDismiss = !viewController.modalInPopover;
        
        if (shouldDismiss && delegate && [delegate respondsToSelector:@selector(popoverControllerShouldDismissPopover:)])
        {
            shouldDismiss = [delegate popoverControllerShouldDismissPopover:self];
        }
        
        if (shouldDismiss)
        {
            [self dismissPopoverAnimated:animated options:options completion:nil callDelegate:YES];
        }
    //}
}

#pragma mark WYPopoverBackgroundViewDelegate

- (void)popoverBackgroundViewDidTouchOutside:(WYPopoverBackgroundView *)aBackgroundView
{
    [self popoverOverlayViewDidTouch:nil];
}

#pragma mark Private

- (WYPopoverArrowDirection)arrowDirectionForRect:(CGRect)aRect
                                          inView:(UIView *)aView
                                     contentSize:(CGSize)contentSize
                                     arrowHeight:(float)arrowHeight
                        permittedArrowDirections:(WYPopoverArrowDirection)arrowDirections
{
    WYPopoverArrowDirection arrowDirection = WYPopoverArrowDirectionUnknown;
    
    NSMutableArray *areas = [NSMutableArray arrayWithCapacity:0];
    WYPopoverArea *area;
    
    if ((arrowDirections & WYPopoverArrowDirectionDown) == WYPopoverArrowDirectionDown)
    {
        area = [[WYPopoverArea alloc] init];
        area.areaSize = [self sizeForRect:aRect inView:aView arrowHeight:arrowHeight arrowDirection:WYPopoverArrowDirectionDown];
        area.arrowDirection = WYPopoverArrowDirectionDown;
        [areas addObject:area];
    }
    
    if ((arrowDirections & WYPopoverArrowDirectionUp) == WYPopoverArrowDirectionUp)
    {
        area = [[WYPopoverArea alloc] init];
        area.areaSize = [self sizeForRect:aRect inView:aView arrowHeight:arrowHeight arrowDirection:WYPopoverArrowDirectionUp];
        area.arrowDirection = WYPopoverArrowDirectionUp;
        [areas addObject:area];
    }
    
    if ((arrowDirections & WYPopoverArrowDirectionLeft) == WYPopoverArrowDirectionLeft)
    {
        area = [[WYPopoverArea alloc] init];
        area.areaSize = [self sizeForRect:aRect inView:aView arrowHeight:arrowHeight arrowDirection:WYPopoverArrowDirectionLeft];
        area.arrowDirection = WYPopoverArrowDirectionLeft;
        [areas addObject:area];
    }
    
    if ((arrowDirections & WYPopoverArrowDirectionRight) == WYPopoverArrowDirectionRight)
    {
        area = [[WYPopoverArea alloc] init];
        area.areaSize = [self sizeForRect:aRect inView:aView arrowHeight:arrowHeight arrowDirection:WYPopoverArrowDirectionRight];
        area.arrowDirection = WYPopoverArrowDirectionRight;
        [areas addObject:area];
    }
    
    if ((arrowDirections & WYPopoverArrowDirectionNone) == WYPopoverArrowDirectionNone)
    {
        area = [[WYPopoverArea alloc] init];
        area.areaSize = [self sizeForRect:aRect inView:aView arrowHeight:arrowHeight arrowDirection:WYPopoverArrowDirectionNone];
        area.arrowDirection = WYPopoverArrowDirectionNone;
        [areas addObject:area];
    }
    
    if ([areas count] > 1)
    {
        NSIndexSet* indexes = [areas indexesOfObjectsPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
            WYPopoverArea* popoverArea = (WYPopoverArea*)obj;
            
            BOOL result = (popoverArea.areaSize.width > 0 && popoverArea.areaSize.height > 0);
            
            return result;
        }];
        
        areas = [NSMutableArray arrayWithArray:[areas objectsAtIndexes:indexes]];
    }
    
    [areas sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        WYPopoverArea *area1 = (WYPopoverArea *)obj1;
        WYPopoverArea *area2 = (WYPopoverArea *)obj2;
        
        float val1 = area1.value;
        float val2 = area2.value;
        
        NSComparisonResult result = NSOrderedSame;
        
        if (val1 > val2)
        {
            result = NSOrderedAscending;
        }
        else if (val1 < val2)
        {
            result = NSOrderedDescending;
        }
        
        return result;
    }];
    
    for (NSUInteger i = 0; i < [areas count]; i++)
    {
        WYPopoverArea *popoverArea = (WYPopoverArea *)[areas objectAtIndex:i];
        
        if (popoverArea.areaSize.width >= contentSize.width)
        {
            arrowDirection = popoverArea.arrowDirection;
            break;
        }
    }
    
    if (arrowDirection == WYPopoverArrowDirectionUnknown)
    {
        if ([areas count] > 0)
        {
            arrowDirection = ((WYPopoverArea *)[areas objectAtIndex:0]).arrowDirection;
        }
        else
        {
            if ((arrowDirections & WYPopoverArrowDirectionDown) == WYPopoverArrowDirectionDown)
            {
                arrowDirection = WYPopoverArrowDirectionDown;
            }
            else if ((arrowDirections & WYPopoverArrowDirectionUp) == WYPopoverArrowDirectionUp)
            {
                arrowDirection = WYPopoverArrowDirectionUp;
            }
            else if ((arrowDirections & WYPopoverArrowDirectionLeft) == WYPopoverArrowDirectionLeft)
            {
                arrowDirection = WYPopoverArrowDirectionLeft;
            }
            else
            {
                arrowDirection = WYPopoverArrowDirectionRight;
            }
        }
    }
    
    return arrowDirection;
}

- (CGSize)sizeForRect:(CGRect)aRect
               inView:(UIView *)aView
          arrowHeight:(float)arrowHeight
       arrowDirection:(WYPopoverArrowDirection)arrowDirection
{
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    
    CGRect viewFrame = [aView convertRect:aRect toView:nil];
    viewFrame = WYRectInWindowBounds(viewFrame, orientation);
    
    float minX, maxX, minY, maxY = 0;
    
    float keyboardHeight = UIInterfaceOrientationIsPortrait(orientation) ? keyboardRect.size.height : keyboardRect.size.width;
    
    if (delegate && [delegate respondsToSelector:@selector(popoverControllerShouldIgnoreKeyboardBounds:)]) {
        BOOL shouldIgnore = [delegate popoverControllerShouldIgnoreKeyboardBounds:self];
        
        if (shouldIgnore) {
            keyboardHeight = 0;
        }
    }
    
    float overlayWidth = UIInterfaceOrientationIsPortrait(orientation) ? overlayView.bounds.size.width : overlayView.bounds.size.height;
    
    float overlayHeight = UIInterfaceOrientationIsPortrait(orientation) ? overlayView.bounds.size.height : overlayView.bounds.size.width;
    
    minX = popoverLayoutMargins.left;
    maxX = overlayWidth - popoverLayoutMargins.right;
    minY = WYStatusBarHeight() + popoverLayoutMargins.top;
    maxY = overlayHeight - popoverLayoutMargins.bottom - keyboardHeight;
    
    CGSize result = CGSizeZero;
    
    if (arrowDirection == WYPopoverArrowDirectionLeft)
    {
        result.width = maxX - (viewFrame.origin.x + viewFrame.size.width);
        result.width -= arrowHeight;
        result.height = maxY - minY;
    }
    else if (arrowDirection == WYPopoverArrowDirectionRight)
    {
        result.width = viewFrame.origin.x - minX;
        result.width -= arrowHeight;
        result.height = maxY - minY;
    }
    else if (arrowDirection == WYPopoverArrowDirectionDown)
    {
        result.width = maxX - minX;
        result.height = viewFrame.origin.y - minY;
        result.height -= arrowHeight;
    }
    else if (arrowDirection == WYPopoverArrowDirectionUp)
    {
        result.width = maxX - minX;
        result.height = maxY - (viewFrame.origin.y + viewFrame.size.height);
        result.height -= arrowHeight;
    }
    else if (arrowDirection == WYPopoverArrowDirectionNone)
    {
        result.width = maxX - minX;
        result.height = maxY - minY;
    }
    
    return result;
}

#pragma mark Inline functions

static NSString* WYStringFromOrientation(NSInteger orientation) {
    NSString *result = @"Unknown";
    
    switch (orientation) {
        case UIInterfaceOrientationPortrait:
            result = @"Portrait";
            break;
        case UIInterfaceOrientationPortraitUpsideDown:
            result = @"Portrait UpsideDown";
            break;
        case UIInterfaceOrientationLandscapeLeft:
            result = @"Landscape Left";
            break;
        case UIInterfaceOrientationLandscapeRight:
            result = @"Landscape Right";
            break;
        default:
            break;
    }
    
    return result;
}

static float WYStatusBarHeight() {
    UIInterfaceOrientation orienation = [[UIApplication sharedApplication] statusBarOrientation];
    
    float statusBarHeight = 0;
    {
        CGRect statusBarFrame = [[UIApplication sharedApplication] statusBarFrame];
        statusBarHeight = statusBarFrame.size.height;
        
        if (UIDeviceOrientationIsLandscape(orienation))
        {
            statusBarHeight = statusBarFrame.size.width;
        }
    }
    
    return statusBarHeight;
}

static float WYInterfaceOrientationAngleOfOrientation(UIInterfaceOrientation orientation)
{
    float angle;
    
    switch (orientation)
    {
        case UIInterfaceOrientationPortraitUpsideDown:
            angle = M_PI;
            break;
        case UIInterfaceOrientationLandscapeLeft:
            angle = -M_PI_2;
            break;
        case UIInterfaceOrientationLandscapeRight:
            angle = M_PI_2;
            break;
        default:
            angle = 0.0;
            break;
    }
    
    return angle;
}

static CGRect WYRectInWindowBounds(CGRect rect, UIInterfaceOrientation orientation) {
    
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    
    float windowWidth = keyWindow.bounds.size.width;
    float windowHeight = keyWindow.bounds.size.height;
    
    CGRect result = rect;
    
    if (orientation == UIInterfaceOrientationLandscapeRight) {
        
        result.origin.x = rect.origin.y;
        result.origin.y = windowWidth - rect.origin.x - rect.size.width;
        result.size.width = rect.size.height;
        result.size.height = rect.size.width;
    }
    
    if (orientation == UIInterfaceOrientationLandscapeLeft) {
        
        result.origin.x = windowHeight - rect.origin.y - rect.size.height;
        result.origin.y = rect.origin.x;
        result.size.width = rect.size.height;
        result.size.height = rect.size.width;
    }
    
    if (orientation == UIInterfaceOrientationPortraitUpsideDown) {
        
        result.origin.x = windowWidth - rect.origin.x - rect.size.width;
        result.origin.y = windowHeight - rect.origin.y - rect.size.height;
    }
    
    return result;
}

static CGPoint WYPointRelativeToOrientation(CGPoint origin, CGSize size, UIInterfaceOrientation orientation) {
    
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    
    float windowWidth = keyWindow.bounds.size.width;
    float windowHeight = keyWindow.bounds.size.height;
    
    CGPoint result = origin;
    
    if (orientation == UIInterfaceOrientationLandscapeRight) {
        result.x = windowWidth - origin.y - size.width;
        result.y = origin.x;
    }
    
    if (orientation == UIInterfaceOrientationLandscapeLeft) {
        result.x = origin.y;
        result.y = windowHeight - origin.x - size.height;
    }
    
    if (orientation == UIInterfaceOrientationPortraitUpsideDown) {
        result.x = windowWidth - origin.x - size.width;
        result.y = windowHeight - origin.y - size.height;
    }
    
    return result;
}

#pragma mark Selectors

- (void)willChangeStatusBarFrame:(NSNotification *)notification
{
    NSValue* rectValue = [[notification userInfo] valueForKey:UIApplicationStatusBarFrameUserInfoKey];
    transitioningToStatusBarFrame = [rectValue CGRectValue];
    CGFloat offset = transitioningToStatusBarFrame.size.height - originalStatusBarFrame.size.height;
    [UIView animateWithDuration:0.35
                          delay:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         CGRect frame = inView.window.bounds;
                         overlayView.frame = CGRectOffset(frame, 0, offset);
                     }
                     completion:nil];
    [self positionPopover:YES];
}

- (void)didChangeStatusBarOrientation:(NSNotification *)notification
{
    isInterfaceOrientationChanging = YES;
}

- (void)didChangeDeviceOrientation:(NSNotification *)notification
{
    if (isInterfaceOrientationChanging == NO) return;
    
    isInterfaceOrientationChanging = NO;
    
    if ([viewController isKindOfClass:[UINavigationController class]])
    {
        UINavigationController* navigationController = (UINavigationController*)viewController;
        
        if (navigationController.navigationBarHidden == NO)
        {
            navigationController.navigationBarHidden = YES;
            navigationController.navigationBarHidden = NO;
        }
    }
    
    if (barButtonItem)
    {
        inView = [barButtonItem valueForKey:@"view"];
        rect = inView.bounds;
    }
    else if ([delegate respondsToSelector:@selector(popoverController:willRepositionPopoverToRect:inView:)])
    {
        CGRect anotherRect;
        UIView *anotherInView;
        
        [delegate popoverController:self willRepositionPopoverToRect:&anotherRect inView:&anotherInView];
        
        if (&anotherRect != NULL)
        {
            rect = anotherRect;
        }
        
        if (&anotherInView != NULL)
        {
            inView = anotherInView;
        }
    }
    
    [self positionPopover:NO];
}

- (void)keyboardWillShow:(NSNotification *)notification
{
    NSDictionary *info = [notification userInfo];
    keyboardRect = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    //UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    //WY_LOG(@"orientation = %@", WYStringFromOrientation(orientation));
    //WY_LOG(@"keyboardRect = %@", NSStringFromCGRect(keyboardRect));
    
    BOOL shouldIgnore = NO;
    
    if (delegate && [delegate respondsToSelector:@selector(popoverControllerShouldIgnoreKeyboardBounds:)]) {
        shouldIgnore = [delegate popoverControllerShouldIgnoreKeyboardBounds:self];
    }
    
    if (shouldIgnore == NO) {
        [self positionPopover:YES];
    }
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    keyboardRect = CGRectZero;
    
    BOOL shouldIgnore = NO;
    
    if (delegate && [delegate respondsToSelector:@selector(popoverControllerShouldIgnoreKeyboardBounds:)]) {
        shouldIgnore = [delegate popoverControllerShouldIgnoreKeyboardBounds:self];
    }
    
    if (shouldIgnore == NO) {
        [self positionPopover:YES];
    }
}

#pragma mark Memory management

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [backgroundView removeFromSuperview];
    [backgroundView setDelegate:nil];
    
    [overlayView removeFromSuperview];
    [overlayView setDelegate:nil];
    
    barButtonItem = nil;
    passthroughViews = nil;
    viewController = nil;
    inView = nil;
    overlayView = nil;
    backgroundView = nil;
    
    [self unregisterTheme];
    theme = nil;
}

@end

