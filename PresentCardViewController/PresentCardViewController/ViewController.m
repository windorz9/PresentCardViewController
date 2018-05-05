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

@interface ViewController () <CardViewControllerDelegate>

@property (nonatomic, strong) CardStackViewController *cardStackController;
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
    
    self.cardStackController = [[CardStackViewController alloc] init];
    
    
    
}
- (IBAction)tapPress:(UITapGestureRecognizer *)sender {
    
    // 点击唤起控制器
    //    self.cardVC.delegate = self;
    [self presentViewController:self.cardStackController animated:NO completion:nil];
    
    CardViewController *rootVC = [self newController];
    
    rootVC.delegate = self;
    [self.cardStackController stackViewController:rootVC WithSize:CGSizeZero WithRoundedTopCorners:YES draggable:YES BottomBackgroundColor:nil Complection:nil];
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
    [self.cardStackController stackViewController:cardVC WithSize:CGSizeZero WithRoundedTopCorners:YES draggable:YES BottomBackgroundColor:nil Complection:^{
        NSLog(@"Complection Block");
    }];
    
}




- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
