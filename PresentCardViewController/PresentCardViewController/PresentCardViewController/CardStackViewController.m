//
//  CardStackViewController.m
//  PresentCardViewController
//
//  Created by windorz on 2018/5/2.
//  Copyright © 2018年 windorz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "CardStackViewController.h"
#import "Helpers.h"
#import "UIView+Extension.h"
#import "Constants.h"

//typedef void(^Complection)(void);

@interface CardStackViewController () <UIDynamicAnimatorDelegate>

@property (nonatomic, strong) UIColor *bgColor;
@property (nonatomic, strong) NSMutableArray<UIViewController *> *viewControllers;
// 声明动画相关属性
@property (nonatomic, strong) UIDynamicAnimator *animator;
@property (nonatomic, strong) UICollisionBehavior *collisionBehavior;
@property (nonatomic, strong) NSMutableArray<UIAttachmentBehavior *> *attachmentBehaviors;
@property (nonatomic, strong) UIDynamicItemBehavior *dynamicItemBehavior;
@property (nonatomic, strong) UIAttachmentBehavior *panAttachmentBehavior;
@property (nonatomic, strong) UIPanGestureRecognizer *panGestureRecognizer;

@property (nonatomic, assign) BOOL isPresentingCard; // 默认为 false
@property (nonatomic, assign) CGPoint initialDraggingPoint; // 默认 CGPoint.zero
@property (nonatomic, strong) Complection stackCompletionBlock;
@property (nonatomic, readonly, strong) UIViewController *previousViewController;

@end
@implementation CardStackViewController

#pragma mark 懒加载
- (NSMutableArray<UIViewController *> *)viewControllers {
    
    if (!_viewControllers) {
        _viewControllers = [NSMutableArray<UIViewController *> array];
    }
    return _viewControllers;
}

- (NSMutableArray<UIAttachmentBehavior *> *)attachmentBehaviors {
    
    if (!_attachmentBehaviors) {
        _attachmentBehaviors = [NSMutableArray<UIAttachmentBehavior *> array];
    }
    return _attachmentBehaviors;
    
}

#pragma mark 初始化方法
- (instancetype)initWithRootViewcontroller:(UIViewController *)rootViewController {
    
    self = [super initWithNibName:nil bundle:nil];
    self.rootViewController = rootViewController;
    return self;
}

- (instancetype)init {
    
    self = [super initWithNibName:nil bundle:nil];
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    
    NSAssert(NO, @"这个方法没有被实现");
    return nil;
}

#pragma mark 只读属性
- (UIViewController *)topViewController {
    
    return self.viewControllers.lastObject;
    
}

- (NSInteger)numberOfCards {
    
    return self.viewControllers.count;
}

- (UIViewController *)previousViewController {
    
    NSInteger previousCardIndex = self.viewControllers.count - 2;
    if (previousCardIndex >= 0) {
        return self.viewControllers[previousCardIndex];
    }
    return nil;
    
}

#pragma mark 视图相关
- (void)viewDidLoad {
    
    [super viewDidLoad];
    // 首先进行初始值的设置
    [self setDefaultValue];
    
    [self setupView];
    
    [self initialiseAnimator];
    
    [self addGestureRecognizer];
    
    if (self.rootViewController) {
        UIViewController *viewController = self.rootViewController;

        [self stackViewController:viewController WithSize:CGSizeZero WithRoundedTopCorners:YES draggable:YES BottomBackgroundColor:nil Complection:nil];
        
    }
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:false];
    
    if (!self.isBeingPresented) {
        return;
    }
    
    UIImage *screenShotImage = [Helpers drawWindowHierarchyAfterScreenUpdates:NO];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:screenShotImage];
    
    [self.view insertSubview:imageView atIndex:0];
    [imageView pinEdgesToSuperviewEdges];
    
 
}

- (void)viewDidLayoutSubviews {
    
    [super viewDidLayoutSubviews];
    
    // 遍历出控制器数组当中所有的子控制器, 然后重新设置 layer.mask
    for (UIViewController *vc in self.viewControllers) {
        
        if (vc.view.layer.mask != nil) {
            vc.view.layer.mask = [self maskLayerWithBounds:vc.view.bounds];
        }
        
    }
    
}

- (CAShapeLayer *)maskLayerWithBounds:(CGRect)bounds {
    
    CAShapeLayer *layer = [[CAShapeLayer alloc] init];
    layer.frame = bounds;
    CGRect rect = CGRectMake(0, 0, bounds.size.width, bounds.size.height + fakeViewHeight);
    rect.origin = CGPointZero;
    // UIRectCornerTopRight && UIRectCornerTopLeft
    layer.path = [[UIBezierPath bezierPathWithRoundedRect:rect byRoundingCorners:UIRectCornerTopRight | UIRectCornerTopLeft cornerRadii:CGSizeMake(topCornerRadius, topCornerRadius)] CGPath];
    
    return layer;
}


#pragma mark 属性初始值设置
- (void)setDefaultValue {
    
    self.firstCardTopOffset = [[UIApplication sharedApplication] statusBarFrame].size.height;
    
    self.bgColor = [[UIColor blackColor] colorWithAlphaComponent:0.4];
    
    self.topOffsetBetweenCards = 10.0;
    
    self.cardDelay = 0.1;
    
    self.cardScaleFactor = 0.95;
    
    self.verticalTranslation = -20;
    
    self.bounces = YES;
    
    self.automaticallyDismiss = YES;
    
    self.damping = 1.0;
    
    self.frequency = 5.0;
    
    self.isPresentingCard = NO;
    
    self.initialDraggingPoint = CGPointZero;
    
    
}

#pragma mark 设置视图
- (void)setupView {
    
    self.view.backgroundColor = [UIColor clearColor];
    
    
}

- (void)initialiseAnimator {
    
    self.animator = [[UIDynamicAnimator alloc] initWithReferenceView:self.view];
    self.animator.delegate = self;
    
    self.dynamicItemBehavior = [[UIDynamicItemBehavior alloc] init];
    self.dynamicItemBehavior.allowsRotation = NO;
    
    self.collisionBehavior = [[UICollisionBehavior alloc] init];
    self.collisionBehavior.collisionMode = UICollisionBehaviorModeBoundaries;
    [self.collisionBehavior addBoundaryWithIdentifier:@"leftMargin" fromPoint:CGPointMake(-0.5, 0) toPoint:CGPointMake(-0.5, CGRectGetMaxY(self.view.bounds))];
    
    [self.collisionBehavior addBoundaryWithIdentifier:@"rightMargin" fromPoint:CGPointMake(CGRectGetMaxX(self.view.bounds) + 0.5, 0) toPoint:CGPointMake(CGRectGetMaxX(self.view.bounds), CGRectGetMaxY(self.view.bounds))];
    
    [self.animator addBehavior:self.dynamicItemBehavior];
    [self.animator addBehavior:self.collisionBehavior];
    
}


/// size 默认为 zero
/// roundedCorners true
/// isDraggable true
/// color nil
/// complection nil

/**
 新的卡片控制器入栈

 @param newContrller 想要 present 的控制器
 @param size 是否需要设置特殊的 size 默认 CGSizeZero
 @param roundedCorners 视图的上右 和上左 是否圆角显示 默认 yes
 @param isDraggable 是否可以用手指上下垂直拉动控制器 默认 yes
 @param color CardController 每个会加一个 假的self.view 给一个设置好的颜色, 默认是 present 的视图控制器的 bgColor
 @param complectionBlock 完成回调
 */
- (void)stackViewController:(UIViewController *)newContrller WithSize:(CGSize)size WithRoundedTopCorners:(BOOL)roundedCorners draggable:(BOOL)isDraggable BottomBackgroundColor:(UIColor *)color Complection:(Complection)complectionBlock {
    
    if (self.viewControllers.count == 0) {
        self.rootViewController = newContrller;
    }
    self.panGestureRecognizer.enabled = isDraggable;
    if (complectionBlock) {
        self.stackCompletionBlock = complectionBlock;
    }
    self.isPresentingCard = YES;
    
    [self animateCurrentCardBackToPresentNextOne];
    
    UIView *containerView = [self createContainerDimView];
    
    [self addChildViewController:newContrller ContainView:containerView fakeViewBackgroundColor:color];
    
    NSInteger numberOfPreviousCards = self.viewControllers.count - 1;
    
    newContrller.view.frame = [self newControllerFrameFromSize:size previousCards:numberOfPreviousCards];

    
    if (roundedCorners) {
        newContrller.view.layer.mask = [self maskLayerWithBounds:newContrller.view.bounds];
        
    }
    [newContrller.view addGestureRecognizer:self.panGestureRecognizer];
    
    [UIView animateWithDuration:0.3 animations:^{
        containerView.backgroundColor = self.bgColor;
    }];
    
    [Helpers delayClosure:self.cardDelay Closure:^{
        
        CGFloat anchorY = CGRectGetMaxY(self.view.frame) - CGRectGetMidY(newContrller.view.bounds);
        [self attachView:newContrller.view ToAnchorPoint:CGPointMake(self.view.center.x, anchorY)];
        [self.collisionBehavior addItem:newContrller.view];
        
        
    }];
 
}

- (void)animateCurrentCardBackToPresentNextOne {
    
    if (!self.topViewController) {
        return;
    }
    UIViewController *viewController = self.topViewController;
    
    CATransform3D transform = CATransform3DMakeScale(self.cardScaleFactor, self.cardScaleFactor, 1);
    
    CATransform3D finalTransform = CATransform3DTranslate(transform, 0, self.verticalTranslation, 0);
    
    CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:@"transform"];
    anim.fromValue = [NSValue valueWithCATransform3D:CATransform3DIdentity];
    anim.toValue = [NSValue valueWithCATransform3D:finalTransform];
    anim.duration = 0.4;
    anim.timingFunction = [CAMediaTimingFunction functionWithControlPoints:0.1 :0.5 :0.5 :1];
    anim.fillMode = kCAFillModeForwards;
    anim.removedOnCompletion = NO;
    [viewController.view.layer addAnimation:anim forKey:@"transform"];
}

// 创建背景模糊视图
- (UIView *)createContainerDimView {
    
    UIView *containerView = [[UIView alloc] init];
    containerView.backgroundColor = [UIColor clearColor];
    containerView.frame = self.view.bounds;
    
    [self.view addSubview:containerView];
    return containerView;
}

- (void)addChildViewController:(UIViewController *)newController ContainView:(UIView *)containerView fakeViewBackgroundColor:(UIColor *)bgColor {
    
    [self.viewControllers addObject:newController];
    
    [self addChildViewController:newController];
    
    [containerView addSubview: newController.view];
    
    [self addFakeBottomViewUnderneath:newController.view WithBackgroundColor:bgColor];
    
    [newController didMoveToParentViewController:self];

}

- (void)addFakeBottomViewUnderneath:(UIView *)view WithBackgroundColor:(UIColor *)backgroundColor {
    
    UIView *fakeView = [[UIView alloc] init];
    fakeView.translatesAutoresizingMaskIntoConstraints = NO;
    if (!backgroundColor) {
        fakeView.backgroundColor = view.backgroundColor;
    } else {
        fakeView.backgroundColor = backgroundColor;
    }
    [view addSubview:fakeView];
    [fakeView pinTopToBottomOf:view Constant:0];
    [fakeView pinLeadingToLeadingOf:view Constant:0];
    [fakeView pinTrailingToTrailingOf:view Constant:0];
    [fakeView setHeightToConstant:fakeViewHeight];
    
}

- (CGRect)newControllerFrameFromSize:(CGSize)size previousCards:(NSInteger)previousCards {
    
    CGFloat viewHeight = self.view.bounds.size.height;
    CGFloat viewWidth = self.view.bounds.size.width;
    

    if (!CGSizeEqualToSize(size, CGSizeZero)) {
        
        return CGRectMake(0, viewHeight, size.width, size.height);
        
    }
    
    CGFloat topMargin = self.firstCardTopOffset + (self.topOffsetBetweenCards * previousCards);
    
    return CGRectMake(0, viewHeight, viewWidth, viewHeight - topMargin);
}


- (void)attachView:(UIView *)aView ToAnchorPoint:(CGPoint)anchorPoint {
    
    UIAttachmentBehavior *attachmentBehaviour = [[UIAttachmentBehavior alloc] initWithItem:aView attachedToAnchor:anchorPoint];
    
    attachmentBehaviour.length = 1;
    [attachmentBehaviour setDamping:self.damping];
    [attachmentBehaviour setFrequency:self.frequency];
    
    [self.animator addBehavior:attachmentBehaviour];
    [self.attachmentBehaviors addObject:attachmentBehaviour];
    [self.dynamicItemBehavior addItem:aView];
    
    
}



- (void)addGestureRecognizer {
    
    self.panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];

}

- (void)handlePan:(UIPanGestureRecognizer *)sender {
    
    if (self.topViewController && [self.attachmentBehaviors lastObject]) {
        UIView *panningView = self.topViewController.view;
        UIAttachmentBehavior *currentAttachmentBehaviour = [self.attachmentBehaviors lastObject];
        UIView *currentDimView = panningView.superview;
        
        CGPoint panLocationInView = [sender locationInView:self.view];
        CGFloat defaultAnchorPointX = currentAttachmentBehaviour.anchorPoint.x;
        CGFloat defaultAnchorPointY = CGRectGetMaxY(self.view.frame) - CGRectGetMidY(panningView.bounds);
        
        switch (sender.state) {
            case UIGestureRecognizerStatePossible:
                return;
                break;
            case UIGestureRecognizerStateBegan:
                self.initialDraggingPoint = panLocationInView;
                break;
            case UIGestureRecognizerStateChanged:
            {
                CGFloat newYPosition = defaultAnchorPointY + [self calculateYPositionwithLocation:panLocationInView.y Dragging:self.initialDraggingPoint.y];
                currentAttachmentBehaviour.anchorPoint = CGPointMake(defaultAnchorPointX, newYPosition);
                
                CGFloat percentageDragged = (dragAmountToDimBackgroundColor - (panLocationInView.y - self.initialDraggingPoint.y))/dragAmountToDimBackgroundColor;
                
                CGFloat alphaPercentage = MIN(0.4, percentageDragged - 0.6);
                currentDimView.backgroundColor = [self.bgColor colorWithAlphaComponent:alphaPercentage];
                break;
            }
            case UIGestureRecognizerStateEnded:
            case UIGestureRecognizerStateFailed:
            case UIGestureRecognizerStateCancelled:
                
                currentAttachmentBehaviour.anchorPoint = CGPointMake(defaultAnchorPointX, defaultAnchorPointY);
                CGPoint velocity = CGPointMake(0, [sender velocityInView:self.view].y);
                
                [self.dynamicItemBehavior addLinearVelocity:velocity forItem:panningView];
                
                BOOL shouldDismiss = [self.delegate shouldDismiss:self.topViewController];
                
                if (([sender translationInView: self.view].y > dragLimitToDismiss) && shouldDismiss) {
                    [self unstackLastViewController:nil];
                } else {
                    [UIView animateWithDuration:dimDuration animations:^{
                        currentDimView.backgroundColor = self.bgColor;
                    }];
                }
                break;
        }
        
    }
    
    
    
}

- (void)unstackLastViewController:(Complection)complection {
    
    if (self.attachmentBehaviors.lastObject && self.topViewController) {
        
        UIAttachmentBehavior *attachmentBehaviour = self.attachmentBehaviors.lastObject;
        
        id<UIDynamicItem> item = attachmentBehaviour.items.lastObject;
        
        attachmentBehaviour.anchorPoint = CGPointMake(self.view.center.x, item.center.y + item.bounds.size.height);
        
        if (self.previousViewController) {
            [self animateCardToFrontViewController:self.previousViewController];
            [self removeDimViewToViewController:self.topViewController animated:YES complectionBlock:^{
                [self dismissCard];
                complection();
            }];
        }
  
    } else {
        return;
    }
    
    
    
}


/**
 移除当前控制器的 背景视图

 @param viewController 将要出栈的控制器
 @param animated 是否动画
 @param complection 完成回调
 */
- (void)removeDimViewToViewController:(UIViewController *)viewController animated:(BOOL)animated complectionBlock:(Complection)complection {
    
    if (!viewController.view.superview) {
        return;
    }
    UIView *containerView = viewController.view.superview;

    NSTimeInterval duration = animated ? dimDuration : 0.0;
    
    [UIView animateWithDuration:duration
                     animations:^{
                         containerView.backgroundColor = [UIColor clearColor];
                     } completion:^(BOOL finished) {
                         complection();
                     }];
}


/**
 topViewController 的上一个视图控制器的出现动画

 @param viewController 最上层控制器
 */
- (void)animateCardToFrontViewController:(UIViewController *)viewController {
    
    double duration = 0.4;
    
    CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:@"transform"];
    
    anim.toValue = [NSValue  valueWithCATransform3D:CATransform3DIdentity];
    anim.duration = duration;
    
    anim.timingFunction = [CAMediaTimingFunction functionWithControlPoints:0.1 :0.5 :0.5 : 1];
    
    anim.fillMode = kCAFillModeForwards;
    
    [anim setRemovedOnCompletion:NO];
    
    [viewController.view.layer addAnimation:anim forKey:@"transformBack"];
    
    
}

- (CGFloat)calculateYPositionwithLocation:(CGFloat)location Dragging:(CGFloat)initialDragging {
    
    CGFloat totalAmountDragged = location - initialDragging;
    
    if (totalAmountDragged < 0) {
        if (!self.bounces) {
            return 0;
        }
        return totalAmountDragged * log10(1 + self.initialDraggingPoint.y/fabs(totalAmountDragged));
    } else {
        
        return totalAmountDragged;
    }
    
}




/**
 topViewController 出栈
 */
- (void)dismissCard {
    
    if (!(self.topViewController && self.attachmentBehaviors.lastObject && self.topViewController.view.superview)) {
        
        return;
    }
    
    UIViewController *viewController = self.topViewController;
    UIAttachmentBehavior *currentBehaviour = self.attachmentBehaviors.lastObject;
    UIView *viewControllerSuperview = viewController.view.superview;
    
    [viewController willMoveToParentViewController:nil];
    [viewController.view removeFromSuperview];
    
    [viewControllerSuperview removeFromSuperview];
    [viewController removeFromParentViewController];
    [self.viewControllers removeLastObject];
    
    [self.animator removeBehavior:currentBehaviour];
    [self.attachmentBehaviors removeLastObject];
    
    [self.collisionBehavior removeItem:viewController.view];
    [self.dynamicItemBehavior removeItem:viewController.view];
    
    if ([self.delegate respondsToSelector:@selector(didFinishUnStacking:)]) {
        [self.delegate didFinishUnStacking:viewController];
    }
    
    if (self.topViewController) {
        [self.topViewController.view addGestureRecognizer:self.panGestureRecognizer];
        return;
    }
    
    [self.animator removeBehavior:self.dynamicItemBehavior];
    [self.animator removeBehavior:self.collisionBehavior];
    
    if (!self.automaticallyDismiss) {
        return;
    }
    
    [self dismissViewControllerAnimated:NO completion:^{
        if ([self.delegate respondsToSelector:@selector(didFinishDismissingCardController)]) {
            [self.delegate didFinishDismissingCardController];
        }
    }];
  
}

#pragma mark 外界调用出栈
/**
 指定出栈的控制器个数

 @param numberOfCards 控制器个数
 @param complection 完成回调.
 */
- (void)unstackLast:(NSInteger)numberOfCards ComplectionHandle:(Complection)complection {
    
    if (numberOfCards < self.numberOfCards) {
        
        NSMutableArray *viewControllersToUnstack = [NSMutableArray<UIViewController *> array];
        
        
        [self.viewControllers enumerateObjectsWithOptions:(NSEnumerationOptions)NSEnumerationReverse usingBlock:^(UIViewController * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {

            if (idx > (self.numberOfCards - numberOfCards - 1)) {

                [viewControllersToUnstack addObject:obj];
            }
        }];

         [self unstackSelectedViewControllers:(NSMutableArray<UIViewController *> *)viewControllersToUnstack Handle:complection];
        
        
    } else {
        // 解决方案一: 强制报错
//        NSAssert(NO, @"numberOfCards 必须小于 viewControllers 的 count");
        // 解决方案二:  全部控制器出栈 -- 推荐
        [self unstackAllViewControllersWithHandle:complection];
        return;
    }
    
}



/**
 将当前数组里面的所有的控制器出栈

 @param complection 完成回调
 */
- (void)unstackAllViewControllersWithHandle:(Complection)complection {
    
    [self unstackSelectedViewControllers:self.viewControllers Handle:complection];

}

/**
  将最上层的一个控制器出栈 (topViewController)

 @param complection 出栈后的完成回调
 */
- (void)unstackLastViewControllerWithHandle:(Complection)complection {
    
    if (self.attachmentBehaviors.lastObject && self.topViewController) {
        UIAttachmentBehavior *attachmentBehaviour = self.attachmentBehaviors.lastObject;
        id<UIDynamicItem> item = attachmentBehaviour.items.lastObject;

        UIViewController *topController = self.topViewController;
        attachmentBehaviour.anchorPoint = CGPointMake(self.view.center.x, item.center.y + item.bounds.size.height);
        
        // 如果topViewController 底下还存在控制器 就进行显示动画
        if (self.previousViewController) {
            [self animateCardToFrontViewController:self.previousViewController];
        }
        [self removeDimViewToViewController:topController animated:YES complectionBlock:^{
            [self dismissCard];
            if (complection) {
                complection();
            }
        }];
        
    } else {
        return;
    }
}



/**
 将 rootVC 后面的全部出栈, 只保留一个 rootVC

 @param complection 完成回调
 */
- (void)unstackToRootViewControllerWithHandle:(Complection)complection {
    
    [self unstackLast:self.viewControllers.count - 1 ComplectionHandle:complection];
    
    
}


/**
 指定一个self.viewControllers 里面的控制器 然后将它和它后面的控制器全部出栈

 @param viewController 需要出栈的控制器
 @param complection 完成回调
 */
- (void)unstackToViewController:(UIViewController *)viewController ComplectionHandle:(Complection)complection {
    
    if (![self.viewControllers indexOfObject: viewController]) {
        
        NSAssert(NO, @"控制器没有在栈中被发现");
        
    }
    
    NSInteger index = [self.viewControllers indexOfObject: viewController];
    
    NSInteger cardsToUnstack = self.numberOfCards - index + 1;
    
    [self unstackLast:cardsToUnstack ComplectionHandle:complection];
    
}



/**
 传入一个控制器的数组, 并将其全部进行出栈

 @param selectedControllers 目标控制器数组
 @param complection 完成回调.
 */
- (void)unstackSelectedViewControllers:(NSMutableArray<UIViewController *> *)selectedControllers Handle:(Complection)complection {
    
    CGPoint anchorPoint = CGPointMake(self.view.bounds.size.width / 2, self.view.bounds.size.height * 3/2);
    
    NSInteger remainingCards = self.numberOfCards - selectedControllers.count;
    NSMutableArray *behaviours = (NSMutableArray *)[self.attachmentBehaviors subarrayWithRange:NSMakeRange(remainingCards, self.numberOfCards - remainingCards)];
    
    for (UIAttachmentBehavior *behavior in behaviours) {
        behavior.anchorPoint = anchorPoint;
    }
    
    [UIView animateWithDuration:dimDuration animations:^{
        
        for (UIViewController *vc in selectedControllers) {
            [self removeDimViewToViewController:vc animated:NO complectionBlock:^{
                [self dismissCard];
            }];
        }
        
    } completion:^(BOOL finished) {
        if (selectedControllers.count < self.viewControllers.count) {
            NSInteger index = self.viewControllers.count - selectedControllers.count - 1;
            
            UIViewController *topVC = self.viewControllers[index];
            [self animateCardToFrontViewController:topVC];
            if (complection) {
                complection();
            }
        }
    }];
    
}

#pragma mark UIDynamicAnimatorDelegate
- (void)dynamicAnimatorDidPause:(UIDynamicAnimator *)animator {
    
    if (self.isPresentingCard && self.topViewController) {
        
        self.isPresentingCard = NO;
        
        if ([self.delegate respondsToSelector:@selector(didFinishStacking:)]) {
            
            [self.delegate didFinishStacking:self.topViewController];

        }
        if (self.stackCompletionBlock) {
            self.stackCompletionBlock();
        }
        
    } else {
        return;
    }
    
    
}

@end
