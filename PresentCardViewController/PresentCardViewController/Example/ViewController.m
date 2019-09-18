//
//  ViewController.m
//  PresentCardViewController
//
//  Created by windorz on 2018/5/2.
//  Copyright © 2018年 windorz. All rights reserved.
//

#import "ViewController.h"
#import "Helpers.h"
#import "CardStackViewController.h"
#import "CardViewController.h"

@interface ViewController () <CardViewControllerDelegate, CardStackViewControllerDelegate>

@property (nonatomic, strong) CardStackViewController *cardStackController;
// 调整缩放的比例 默认 0.95
@property (weak, nonatomic) IBOutlet UILabel *firstSliderLabel;
@property (weak, nonatomic) IBOutlet UISlider *firstSlider;
@property (weak, nonatomic) IBOutlet UILabel *secondSliderLabel;
@property (weak, nonatomic) IBOutlet UISlider *secondSlider;
@property (weak, nonatomic) IBOutlet UILabel *thirdSliderLabel;
@property (weak, nonatomic) IBOutlet UISlider *thirdSlider;
@property (weak, nonatomic) IBOutlet UILabel *fourthSliderLabel;
@property (weak, nonatomic) IBOutlet UISlider *fourthSlider;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (IBAction)tapPress:(UITapGestureRecognizer *)sender {
    
    self.cardStackController = [[CardStackViewController alloc] init];
    // 点击唤起控制器
    self.cardStackController.delegate = self;
    [self presentViewController:self.cardStackController animated:NO completion:nil];
    // 设置初始值
    // 缩放倍数
    self.cardStackController.cardScaleFactor = self.firstSlider.value;
    // 距离顶部距离
    self.cardStackController.firstCardTopOffset = self.secondSlider.value;
    // 卡片控制器之间的距离
    self.cardStackController.topOffsetBetweenCards = self.thirdSlider.value;
    // topViewController 变化时, 上一个 TopVC 会进入背景当中, 进入后的移动距离
    self.cardStackController.verticalTranslation = self.fourthSlider.value;

    CardViewController *rootVC = [self newController];
    rootVC.delegate = self;
    [self.cardStackController stackViewController:rootVC withSize:CGSizeZero roundedTopCorners:YES draggable:YES bottomBackgroundColor:nil complection:nil];
    
}

- (IBAction)sliderValueChange:(UISlider *)sender {
    self.firstSliderLabel.text = [NSString stringWithFormat:@"%.02f", self.firstSlider.value];
    self.secondSliderLabel.text = [NSString stringWithFormat:@"%.02f", self.secondSlider.value];

    self.thirdSliderLabel.text = [NSString stringWithFormat:@"%.02f", self.thirdSlider.value];
    self.fourthSliderLabel.text = [NSString stringWithFormat:@"%.02f", self.fourthSlider.value];
}

- (CardViewController *)newController {
    return [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"CardViewController"];
}

#pragma mark CardViewController Delegate
- (void)dismissAllCards {
    [self.cardStackController unstackAllViewControllersWithHandle:nil];
}

- (void)disMiss {
    [self.cardStackController unstackLastViewControllerWithHandle:^{
        NSLog(@"disMiss complection");
    }];
}

- (void)stackAnotherCard {
    CardViewController *cardVC = [self newController];
    cardVC.delegate = self;
    [self.cardStackController stackViewController:cardVC withSize:CGSizeZero roundedTopCorners:YES draggable:YES bottomBackgroundColor:nil complection:^{
        NSLog(@"Complection Block");
    }];
}

#pragma mark CardStackViewControllerDelegate
- (void)didFinishStacking:(UIViewController *)viewController {
    NSLog(@"finish Stacking");
}

- (void)didFinishUnStacking:(UIViewController *)viewController {
    NSLog(@"UnStacking");
}

- (void)didFinishDismissingCardController {
    self.cardStackController = nil;
    NSLog(@"didFinishDismissingAllCardController");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
