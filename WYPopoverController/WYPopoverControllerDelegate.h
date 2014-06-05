//
// Created by Alex Bird on 05/06/2014.
// Copyright (c) 2014 Nicolas CHENG. All rights reserved.
//


@class WYPopoverController;

@protocol WYPopoverControllerDelegate <NSObject>
@optional

- (BOOL)popoverControllerShouldDismissPopover:(WYPopoverController *)popoverController;

- (void)popoverControllerDidPresentPopover:(WYPopoverController *)popoverController;

- (void)popoverControllerDidDismissPopover:(WYPopoverController *)popoverController;

- (void)popoverController:(WYPopoverController *)popoverController willRepositionPopoverToRect:(inout CGRect *)rect inView:(inout UIView **)view;

- (BOOL)popoverControllerShouldIgnoreKeyboardBounds:(WYPopoverController *)popoverController;

- (void)popoverController:(WYPopoverController *)popoverController willTranslatePopoverWithYOffset:(float *)value;

@end


