//
// Created by Alex Bird on 05/06/2014.
// Copyright (c) 2014 Nicolas CHENG. All rights reserved.
//


@protocol WYPopoverBackgroundViewDelegate;

@interface WYPopoverBackgroundView : UIView

@property (nonatomic, strong) UIColor *tintColor                UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) UIColor *fillTopColor             UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) UIColor *fillBottomColor          UI_APPEARANCE_SELECTOR;

@property (nonatomic, strong) UIColor *glossShadowColor         UI_APPEARANCE_SELECTOR;
@property (nonatomic, assign) CGSize   glossShadowOffset        UI_APPEARANCE_SELECTOR;
@property (nonatomic, assign) NSUInteger  glossShadowBlurRadius    UI_APPEARANCE_SELECTOR;

@property (nonatomic, assign) NSUInteger  borderWidth              UI_APPEARANCE_SELECTOR;
@property (nonatomic, assign) NSUInteger  arrowBase                UI_APPEARANCE_SELECTOR;
@property (nonatomic, assign) NSUInteger  arrowHeight              UI_APPEARANCE_SELECTOR;

@property (nonatomic, strong) UIColor *outerShadowColor         UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) UIColor *outerStrokeColor         UI_APPEARANCE_SELECTOR;
@property (nonatomic, assign) NSUInteger  outerShadowBlurRadius    UI_APPEARANCE_SELECTOR;
@property (nonatomic, assign) CGSize   outerShadowOffset        UI_APPEARANCE_SELECTOR;
@property (nonatomic, assign) NSUInteger  outerCornerRadius        UI_APPEARANCE_SELECTOR;
@property (nonatomic, assign) NSUInteger  minOuterCornerRadius     UI_APPEARANCE_SELECTOR;

@property (nonatomic, strong) UIColor *innerShadowColor         UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) UIColor *innerStrokeColor         UI_APPEARANCE_SELECTOR;
@property (nonatomic, assign) NSUInteger  innerShadowBlurRadius    UI_APPEARANCE_SELECTOR;
@property (nonatomic, assign) CGSize   innerShadowOffset        UI_APPEARANCE_SELECTOR;
@property (nonatomic, assign) NSUInteger  innerCornerRadius        UI_APPEARANCE_SELECTOR;

@property (nonatomic, assign) UIEdgeInsets viewContentInsets    UI_APPEARANCE_SELECTOR;

@property (nonatomic, strong) UIColor *overlayColor             UI_APPEARANCE_SELECTOR;

- (id)initWithContentSize:(CGSize)aContentSize;

- (void)setViewController:(UIViewController *)viewController;

@property(nonatomic, assign) id <WYPopoverBackgroundViewDelegate> delegate;

@property (nonatomic, assign) WYPopoverArrowDirection arrowDirection;

@property (nonatomic, strong, readonly) UIView *contentView;
@property (nonatomic, assign, readonly) float navigationBarHeight;
@property (nonatomic, assign, readonly) UIEdgeInsets outerShadowInsets;
@property (nonatomic, assign) float arrowOffset;
@property (nonatomic, assign) BOOL wantsDefaultContentAppearance;

@property (nonatomic, assign, getter = isAppearing) BOOL appearing;

@end

