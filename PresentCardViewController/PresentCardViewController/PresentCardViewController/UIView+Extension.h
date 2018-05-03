//
//  UIView+Extension.h
//  PresentCardViewController
//
//  Created by windorz on 2018/5/2.
//  Copyright © 2018年 windorz. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (Extension)

- (void)pinEdgesToSuperviewEdges;

- (void)pinLeadingToLeadingOf:(UIView *)view Constant:(CGFloat)constant;

- (void)pinTrailingToTrailingOf:(UIView *)view Constant:(CGFloat)constant;

- (void)pinTopToTopOf:(UIView *)view Constant:(CGFloat)constant;

- (void)pinTopToBottomOf:(UIView *)view Constant:(CGFloat)constant;

- (void)pinBottomToBotomOf:(UIView *)view Constant:(CGFloat)constant;

- (void)pinBottomToTopOf:(UIView *)view Constant:(CGFloat)constant;

- (void)setHeightToConstant:(CGFloat)height;

@end
