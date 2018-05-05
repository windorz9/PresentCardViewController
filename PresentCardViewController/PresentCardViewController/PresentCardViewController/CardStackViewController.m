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
    layer.path = (__bridge CGPathRef _Nullable)([UIBezierPath bezierPathWithRoundedRect:rect byRoundingCorners:UIRectCornerTopRight && UIRectCornerTopLeft cornerRadii:CGSizeMake(topCornerRadius, topCornerRadius)]);
    
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
- (void)stackViewController:(UIViewController *)newContrller WithSize:(CGSize)size WithRoundedTopCorners:(BOOL)roundedCorners draggable:(BOOL)isDraggable BottomBackgroundColor:(UIColor *)color Complection:(Complection)complectionBlock {
    
    if (self.viewControllers.count == 0) {
        self.rootViewController = newContrller;
    }
    self.panGestureRecognizer.enabled = isDraggable;
    self.stackCompletionBlock = complectionBlock;
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
        CGFloat defaultAnchorPointY = CGRectGetMaxY(self.view.bounds) - CGRectGetMidY(panningView.bounds);
        
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
                // FIXME: disMiss
                [self dismissCard];
                complection();
            }];
        }
  
    } else {
        return;
    }
    
    
    
}

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



- (NSInteger)numberOfCards {
    
    return self.viewControllers.count;
    
}

- (UIViewController *)topViewController {
    
    return self.viewControllers.lastObject;
    
}

- (UIViewController *)previousViewController {
    
    NSInteger previousCardIndex = self.viewControllers.count - 2;
    if (previousCardIndex >= 0) {
        return self.viewControllers[previousCardIndex];
    }
    return nil;
    
}

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
- (void)unstackLast:(NSInteger)numberOfCards ComplectionHandle:(Complection)complection {
    
    if (numberOfCards <= self.viewControllers.count) {
        
        NSMutableArray *viewControllersToUnstack = [NSMutableArray<UIViewController *> array];
        
        [self.viewControllers enumerateObjectsWithOptions:(NSEnumerationOptions)NSEnumerationReverse usingBlock:^(UIViewController * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (idx < numberOfCards) {
                [viewControllersToUnstack addObject:obj];
            }
        }];

        // FIXME: 还有一个方法
        [self unstackSelectedViewControllers:(NSMutableArray<UIViewController *> *)[viewControllersToUnstack reverseObjectEnumerator] Handle:complection];
        
        
    } else {
        NSAssert(NO, @"numberOfCards 必须小于 viewControllers 的 count");
        return;
    }
    
}


- (void)unstackAllViewControllersWithHandle:(Complection)complection {
    
    [self unstackSelectedViewControllers:self.viewControllers Handle:complection];

}

- (void)unstackLastViewControllerWithHandle:(Complection)complection {
    
    if (self.attachmentBehaviors.lastObject && self.topViewController) {
        UIAttachmentBehavior *attachmentBehaviour = self.attachmentBehaviors.lastObject;
        id<UIDynamicItem> item = attachmentBehaviour.items.lastObject;

        UIViewController *topController = self.topViewController;
        attachmentBehaviour.anchorPoint = CGPointMake(self.view.center.x, item.center.y + item.bounds.size.height);
        
        if (self.previousViewController) {
            [self animateCardToFrontViewController:self.previousViewController];
        }
        [self removeDimViewToViewController:topController animated:YES complectionBlock:^{
            [self dismissCard];
            complection();
        }];
        
    } else {
        return;
    }
    
}

- (void)unstackToRootViewControllerWithHandle:(Complection)complection {
    
    [self unstackLast:self.viewControllers.count - 1 ComplectionHandle:complection];
    
    
}

- (void)unstackToViewController:(UIViewController *)viewController ComplectionHandle:(Complection)complection {
    
    if (![self.viewControllers indexOfObject: viewController]) {
        
        NSAssert(NO, @"控制器没有在栈中被发现");
        
    }
    
    NSInteger index = [self.viewControllers indexOfObject: viewController];
    
    NSInteger cardsToUnstack = self.numberOfCards - index + 1;
    
    [self unstackLast:cardsToUnstack ComplectionHandle:complection];
    
}

- (void)unstackSelectedViewControllers:(NSMutableArray<UIViewController *> *)selectedControllers Handle:(Complection)complection {
    
    CGPoint anchorPoint = CGPointMake(self.view.bounds.size.width, self.view.bounds.size.height * 3/2);
    
    NSInteger remainingCards = self.numberOfCards - selectedControllers.count;
    
    NSMutableArray *behaviours = (NSMutableArray *)[self.attachmentBehaviors subarrayWithRange:NSMakeRange(0, remainingCards)];
    
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
            complection();
        }
    }];
    
    
    
    
}



#pragma mark UIDynamicAnimatorDelegate
- (void)dynamicAnimatorDidPause:(UIDynamicAnimator *)animator {
    
    if (self.isPresentingCard && self.topViewController) {
        
        self.isPresentingCard = NO;
        
        if ([self.delegate respondsToSelector:@selector(didFinishStacking:)]) {
            
            [self.delegate didFinishStacking:self.topViewController];
            self.stackCompletionBlock();
        }
        
    } else {
        return;
    }
    
    
}

@end
