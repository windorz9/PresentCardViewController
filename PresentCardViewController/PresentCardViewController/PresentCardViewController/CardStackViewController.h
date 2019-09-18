//
//  CardStackViewController.h
//  PresentCardViewController
//
//  Created by windorz on 2018/5/2.
//  Copyright © 2018年 windorz. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^Complection)(void);

@protocol CardStackViewControllerDelegate <NSObject>
@optional
- (void)didFinishStacking:(UIViewController *)viewController;
- (void)didFinishUnStacking:(UIViewController *)viewController;
- (BOOL)shouldDismiss:(UIViewController *)viewContrller;
- (void)didFinishDismissingCardController;

@end
@interface CardStackViewController : UIViewController


/**
 根视图控制器
 */
@property (nonatomic, strong) UIViewController *rootViewController;

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
 是否开启弹簧效果
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

/**
 新的卡片控制器入栈
 
 @param newContrller 想要 present 的控制器
 @param size 是否需要设置特殊的 size 默认 CGSizeZero
 @param roundedCorners 视图的上右 和上左 是否圆角显示 默认 yes
 @param isDraggable 是否可以用手指上下垂直拉动控制器 默认 yes
 @param color CardController 每个会加一个 假的self.view 给一个设置好的颜色, 默认是 present 的视图控制器的 bgColor
 @param complectionBlock 完成回调
 */
- (void)stackViewController:(UIViewController *)newContrller withSize:(CGSize)size roundedTopCorners:(BOOL)roundedCorners draggable:(BOOL)isDraggable bottomBackgroundColor:(UIColor *)color complection:(Complection)complectionBlock;


/**
 将最上层的一个控制器出栈 (topViewController)
 
 @param complection 出栈后的完成回调
 */
- (void)unstackLastViewControllerWithHandle:(Complection)complection;

/**
 将当前数组里面的所有的控制器出栈
 
 @param complection 完成回调
 */
- (void)unstackAllViewControllersWithHandle:(Complection)complection;

/**
 指定一个self.viewControllers 里面的控制器 然后将它和它后面的控制器全部出栈
 
 @param viewController 需要出栈的控制器
 @param complection 完成回调
 */
- (void)unstackToViewController:(UIViewController *)viewController complectionHandle:(Complection)complection;


/**
 指定出栈的控制器个数
 
 @param numberOfCards 控制器个数
 @param complection 完成回调.
 */
- (void)unstackLast:(NSInteger)numberOfCards complectionHandle:(Complection)complection;

/**
 将 rootVC 后面的全部出栈, 只保留一个 rootVC
 
 @param complection 完成回调
 */
- (void)unstackToRootViewControllerWithHandle:(Complection)complection;
@end
