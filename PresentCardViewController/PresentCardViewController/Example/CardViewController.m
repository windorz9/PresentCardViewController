//
//  CardViewController.m
//  PresentCardViewController
//
//  Created by windorz on 2018/5/4.
//  Copyright © 2018年 windorz. All rights reserved.
//

#import "CardViewController.h"
#import "UIColor+Extension.h"

@interface CardViewController ()

@end

@implementation CardViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor randomColor];
}
- (IBAction)tap:(id)sender {
    
    [self.delegate stackAnotherCard];

}

- (IBAction)dismissAllcards:(UIButton *)sender {
    [self.delegate dismissAllCards];
}

- (IBAction)Close:(UIButton *)sender {
    [self.delegate disMiss];

}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
