//
//  ViewController.m
//  barquttest
//
//  Created by flexium on 2017/7/25.
//  Copyright © 2017年 FLEXium. All rights reserved.
//

#import "ViewController.h"
#import "ZFScanViewController.h"
#import "ZYScannerView.h"
@interface ViewController ()
@property (nonatomic, strong) UIButton * scanButton;//扫描按钮
@property (nonatomic, strong) UIButton * scanButton2;//扫描按钮
@property (nonatomic, strong) UILabel * resultLabel;//显示扫描结果
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = ZFWhite;
    
    //扫描按钮
    self.scanButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.scanButton.frame = CGRectMake((SCREEN_WIDTH - 300) / 2, SCREEN_HEIGHT - 150, 100, 70);
    [self.scanButton setBackgroundColor:[UIColor redColor]];
    [self.scanButton setTitle:@"類似微信扫描" forState:UIControlStateNormal];
    [self.scanButton addTarget:self action:@selector(scanAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.scanButton];
    
    //扫描按钮
    self.scanButton2 = [UIButton buttonWithType:UIButtonTypeSystem];
    self.scanButton2.frame = CGRectMake((SCREEN_WIDTH + 100) / 2, SCREEN_HEIGHT - 150, 100, 70);
    [self.scanButton2 setBackgroundColor:[UIColor redColor]];
    [self.scanButton2 setTitle:@"條形碼扫描" forState:UIControlStateNormal];
    [self.scanButton2 addTarget:self action:@selector(scanAction2:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.scanButton2];
    
    
    //显示扫描结果
    self.resultLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 200, SCREEN_WIDTH, 100)];
    self.resultLabel.textAlignment = NSTextAlignmentCenter;
    self.resultLabel.numberOfLines = 0;
    [self.view addSubview:self.resultLabel];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
    // Dispose of any resources that can be recreated.
}

/**
 *  扫描事件
 */
- (void)scanAction:(UIButton *)sender{
    
    ZFScanViewController * vc = [[ZFScanViewController alloc] init];
    
    vc.returnScanBarCodeValue = ^(NSString * barCodeString){
        
        self.resultLabel.text = [NSString stringWithFormat:@"類似微信扫描结果:\n%@",barCodeString];
        
        NSLog(@"方法一扫描结果的字符串======%@",barCodeString);
        
    };
    
    [self presentViewController:vc animated:YES completion:nil];
    
}
- (void)scanAction2:(UIButton *)sender{
    [[NSUserDefaults standardUserDefaults] setValue:@"掃描工卡" forKey: @"textlable"];
    [[ZYScannerView sharedScannerView] showOnView:self.view block:^(NSString *str) {
        NSLog(@"%@",str);
         self.resultLabel.text = [NSString stringWithFormat:@"條形碼扫描结果:\n%@",str];
    }];
    
}
#pragma mark - 横竖屏适配

/**
 *  PS：size为控制器self.view的size，若图表不是直接添加self.view上，则修改以下的frame值
 */
- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id <UIViewControllerTransitionCoordinator>)coordinator{
    
    self.scanButton.frame = CGRectMake((SCREEN_HEIGHT - 100) / 2, SCREEN_WIDTH - 100, 100, 30);
    
    //横屏(转前是横屏，转后是竖屏)
    if ([[UIApplication sharedApplication] statusBarOrientation] == UIInterfaceOrientationLandscapeLeft || [[UIApplication sharedApplication] statusBarOrientation] == UIInterfaceOrientationLandscapeRight) {
        
        self.resultLabel.frame = CGRectMake(0, 200, SCREEN_HEIGHT, 100);
        
        //竖屏(转前是竖屏，转后是横屏)
    }else{
        self.resultLabel.frame = CGRectMake(0, 80, SCREEN_HEIGHT, 100);
        
    }
}
@end
