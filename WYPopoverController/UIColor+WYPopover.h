//
// Created by Alex Bird on 05/06/2014.
// Copyright (c) 2014 Nicolas CHENG. All rights reserved.
//

@interface UIColor (WYPopover)

- (BOOL)getValueOfRed:(CGFloat *)red green:(CGFloat *)green blue:(CGFloat *)blue alpha:(CGFloat *)apha;
- (NSString *)hexString;
- (UIColor *)colorByLighten:(float)d;
- (UIColor *)colorByDarken:(float)d;

@end
