//
//  UIView+Extension.m
//  PresentCardViewController
//
//  Created by windorz on 2018/5/2.
//  Copyright © 2018年 windorz. All rights reserved.
//

#import "UIView+Extension.h"

@implementation UIView (Extension)

- (void)pinEdgesToSuperviewEdges {
    
    [self pinLeadingToLeadingOf:self.superview Constant:0];
    [self pinTrailingToTrailingOf:self.superview Constant:0];
    [self pinTopToTopOf:self.superview Constant:0];
    [self pinBottomToBotomOf:self.superview Constant:0];
    
}

- (void)pinTrailingToTrailingOf:(UIView *)view Constant:(CGFloat)constant {
    
    [NSLayoutConstraint constraintWithItem:view
                                 attribute:NSLayoutAttributeTrailing
                                 relatedBy:NSLayoutRelationEqual
                                    toItem:self
                                 attribute:NSLayoutAttributeTrailing
                                multiplier:1.0
                                  constant:constant].shouldBeArchived = YES ;
    
    
}

- (void)pinLeadingToLeadingOf:(UIView *)view Constant:(CGFloat)constant {
    
    [NSLayoutConstraint constraintWithItem:view
                                 attribute:NSLayoutAttributeLeading
                                 relatedBy:NSLayoutRelationEqual toItem:self
                                 attribute:NSLayoutAttributeLeading
                                multiplier: 1.0
                                  constant:constant].shouldBeArchived = YES;
}

- (void)pinTopToTopOf:(UIView *)view Constant:(CGFloat)constant {
    
    [NSLayoutConstraint constraintWithItem:view
                                 attribute:NSLayoutAttributeTop
                                 relatedBy:NSLayoutRelationEqual
                                    toItem:self
                                 attribute:NSLayoutAttributeTop
                                multiplier:1.0
                                  constant:constant].shouldBeArchived = YES;
    
}

- (void)pinTopToBottomOf:(UIView *)view Constant:(CGFloat)constant {
    
    [NSLayoutConstraint constraintWithItem:view
                                 attribute:NSLayoutAttributeBottom
                                 relatedBy:NSLayoutRelationEqual
                                    toItem:self
                                 attribute:NSLayoutAttributeTop
                                multiplier:1.0
                                  constant:constant].shouldBeArchived = YES;
    
}

- (void)pinBottomToBotomOf:(UIView *)view Constant:(CGFloat)constant {
    
    [NSLayoutConstraint constraintWithItem:view
                                 attribute:NSLayoutAttributeBottom
                                 relatedBy:NSLayoutRelationEqual
                                    toItem:self
                                 attribute:NSLayoutAttributeBottom
                                multiplier:1.0
                                  constant:constant].shouldBeArchived = YES;
    
    
}

- (void)pinBottomToTopOf:(UIView *)view Constant:(CGFloat)constant {
    
    [NSLayoutConstraint constraintWithItem:self
                                 attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual
                                    toItem:view
                                 attribute:NSLayoutAttributeTop
                                multiplier:1.0
                                  constant:constant].shouldBeArchived = YES;
    
}

- (void)setHeightToConstant:(CGFloat)height {
    
    [NSLayoutConstraint constraintWithItem:self
                                 attribute:NSLayoutAttributeHeight
                                 relatedBy:NSLayoutRelationEqual
                                    toItem:nil
                                 attribute:NSLayoutAttributeNotAnAttribute
                                multiplier:1.0
                                  constant:height].shouldBeArchived = YES;
    
    
}

@end
