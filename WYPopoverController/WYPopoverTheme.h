//
// Created by Alex Bird on 05/06/2014.
// Copyright (c) 2014 Nicolas CHENG. All rights reserved.
//


@interface WYPopoverTheme : NSObject

@property (nonatomic, strong) UIColor *tintColor;
@property (nonatomic, strong) UIColor *fillTopColor;
@property (nonatomic, strong) UIColor *fillBottomColor;

@property (nonatomic, strong) UIColor *glossShadowColor;
@property (nonatomic, assign) CGSize   glossShadowOffset;
@property (nonatomic, assign) NSUInteger  glossShadowBlurRadius;

@property (nonatomic, assign) NSUInteger  borderWidth;
@property (nonatomic, assign) NSUInteger  arrowBase;
@property (nonatomic, assign) NSUInteger  arrowHeight;

@property (nonatomic, strong) UIColor *outerShadowColor;
@property (nonatomic, strong) UIColor *outerStrokeColor;
@property (nonatomic, assign) NSUInteger  outerShadowBlurRadius;
@property (nonatomic, assign) CGSize   outerShadowOffset;
@property (nonatomic, assign) NSUInteger  outerCornerRadius;
@property (nonatomic, assign) NSUInteger  minOuterCornerRadius;

@property (nonatomic, strong) UIColor *innerShadowColor;
@property (nonatomic, strong) UIColor *innerStrokeColor;
@property (nonatomic, assign) NSUInteger  innerShadowBlurRadius;
@property (nonatomic, assign) CGSize   innerShadowOffset;
@property (nonatomic, assign) NSUInteger  innerCornerRadius;

@property (nonatomic, assign) UIEdgeInsets viewContentInsets;

@property (nonatomic, strong) UIColor *overlayColor;

+ (instancetype)theme;
+ (instancetype)themeForIOS6;
+ (instancetype)themeForIOS7;

- (NSArray *)observableKeypaths;
@end
