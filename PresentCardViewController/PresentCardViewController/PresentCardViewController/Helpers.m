//
//  Helpers.m
//  PresentCardViewController
//
//  Created by windorz on 2018/5/2.
//  Copyright © 2018年 windorz. All rights reserved.
//

#import "Helpers.h"

@implementation Helpers

+ (UIImage *)drawWindowHierarchyAfterScreenUpdates:(BOOL)afterScreenUpdates {
    
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    if (!window) {
        return nil;
    }
    UIGraphicsBeginImageContextWithOptions(window.bounds.size, NO, 0);
    [window drawViewHierarchyInRect:window.bounds afterScreenUpdates:afterScreenUpdates];
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return image;
}

+ (void)delayClosure:(double)delay Closure:(void (^)(void))closure {
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        closure();
    });
 
}



@end
