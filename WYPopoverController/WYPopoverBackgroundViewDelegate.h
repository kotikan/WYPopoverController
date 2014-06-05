//
// Created by Alex Bird on 05/06/2014.
// Copyright (c) 2014 Nicolas CHENG. All rights reserved.
//

@protocol WYPopoverBackgroundViewDelegate <NSObject>

@optional
- (void)popoverBackgroundViewDidTouchOutside:(WYPopoverBackgroundView *)backgroundView;

@end