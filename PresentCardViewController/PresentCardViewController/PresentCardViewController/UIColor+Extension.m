//
//  UIColor+Extension.m
//  PresentCardViewController
//
//  Created by windorz on 2018/5/3.
//  Copyright © 2018年 windorz. All rights reserved.
//

#import "UIColor+Extension.h"

@implementation UIColor (Extension)

+ (instancetype)colorWithRed:(CGFloat)red Green:(CGFloat)green Blue:(CGFloat)blue {
    
    return [UIColor colorWithRed:red/255.0 green:green/255.0 blue:blue/255.0 alpha:1];
    
}

+ (UIColor *)randomColor {
    
    UInt32 randomNumber = arc4random() % 4;
    switch (randomNumber) {
        case 0:
            return [UIColor colorWithRed:230 Green:230 Blue:250];
            break;
            
        case 1:
            return [UIColor colorWithRed:255 Green:250 Blue:129];
            break;
        case 2:
            return [UIColor colorWithRed:133 Green:202 Blue:93];
            break;
        case 3:
            return [UIColor colorWithRed:253 Green:222 Blue:238];
            break;
        default:
            return [UIColor whiteColor];
            break;
    }
    
}

@end
