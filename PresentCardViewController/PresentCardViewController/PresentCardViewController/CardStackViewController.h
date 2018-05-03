//
//  CardStackViewController.h
//  PresentCardViewController
//
//  Created by windorz on 2018/5/2.
//  Copyright © 2018年 windorz. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CardStackViewControllerDelegate <NSObject>

- (void)didFinishStacking:(UIViewController *)viewController;
- (void)didFinishUnStacking:(UIViewController *)viewController;
- (BOOL)shouldDismiss:(UIViewController *)viewContrller;
- (void)didFinishDismissingCardController;

@end
@interface CardStackViewController : UIViewController

/**
 第一个卡片视图控制器离 Screen 顶部的距离
 初始化的时候设置一个初始值 UIApplication.shared.statusBarFrame.height
 */
@property (nonatomic, assign) CGFloat firstCardTopOffset;

/**
 两个相邻的卡片控制器之间的距离
 初始化默认为 10
 */
@property (nonatomic, assign) CGFloat topOffsetBetweenCards;

/**
 卡片动画的执行时间
 默认值为 0.1
 */
@property (nonatomic, assign) CFTimeInterval cardDelay;

/**
 执行入栈动画后, 上一张卡片要显示的大小比例
 默认值 0.95
 */
@property (nonatomic, assign) CGFloat cardScaleFactor;

/**
 加入新的卡片控制器时, 卡片垂直移动的距离
 默认是 -20
 */
@property (nonatomic, assign) CGFloat verticalTranslation;

/**
 是否能拖动卡片控制器
 默认是 Yes
 */
@property (nonatomic, assign) BOOL bounces;

/**
 是否需要手动释放
 默认是 Yes
 */
@property (nonatomic, assign) BOOL automaticallyDismiss;

/**
 卡片控制器将要显示时的 阻尼系数
 默认 1.0
 */
@property (nonatomic, assign) CGFloat damping;

/**
 卡片控制器将要显示时的 频率系数
 默认 5.0
 */
@property (nonatomic, assign) CGFloat frequency;

/**
 当前卡片控制器的个数 只读
 */
@property (nonatomic, readonly , assign) NSInteger numberOfCards;

/**
 卡片控制器的根控制器 只读
 */
@property (nonatomic, readonly , strong) UIViewController *topViewController;

@property (nonatomic, weak) id<CardStackViewControllerDelegate> delegate;


// 初始化方法
- (instancetype)initWithRootViewcontroller:(UIViewController *)rootViewController;

- (instancetype)init;

@end
