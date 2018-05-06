//
//  Constants.h
//  PresentCardViewController
//
//  Created by windorz on 2018/5/3.
//  Copyright © 2018年 windorz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

// 视图的圆角值
extern CGFloat const topCornerRadius;

// 设置下拉后 disMiss 当前控制器的临界值
extern CGFloat const dragLimitToDismiss;

// 下拉当前视图的颜色变化相关值
extern CGFloat const dragAmountToDimBackgroundColor;

// 当开启弹簧效果时, 上拉当前卡片的话就会在最底部拼接一个 fakeView
// fakeView 的高度
extern CGFloat const fakeViewHeight;

// 一个移除视图的动画时间
extern NSTimeInterval const dimDuration;


