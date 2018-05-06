//
//  CardViewController.h
//  PresentCardViewController
//
//  Created by windorz on 2018/5/4.
//  Copyright © 2018年 windorz. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CardViewControllerDelegate <NSObject>
- (void)disMiss;
- (void)stackAnotherCard;
- (void)dismissAllCards;

@end

@interface CardViewController : UIViewController

@property (nonatomic, weak) id<CardViewControllerDelegate> delegate;


@end
