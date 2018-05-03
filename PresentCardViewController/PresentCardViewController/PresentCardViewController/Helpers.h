//
//  Helpers.h
//  PresentCardViewController
//
//  Created by windorz on 2018/5/2.
//  Copyright © 2018年 windorz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface Helpers : NSObject

+ (UIImage *)drawWindowHierarchyAfterScreenUpdates:(BOOL)afterScreenUpdates;

+ (void)delayClosure:(double)delay Closure:(void (^)(void))closure;

@end
