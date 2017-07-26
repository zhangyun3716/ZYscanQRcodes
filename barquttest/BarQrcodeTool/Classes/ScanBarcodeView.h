//
//  ScanBarcodeView.h
//  BarQrcodeDemo
//
//  Created by MJX on 2017/6/21.
//  Copyright © 2017年 ShangTong. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ScanBarcodeView;

@protocol ScanBarcodeViewDelegate <NSObject>

- (void)didFinishResultForScanBarcodeView:(ScanBarcodeView *)view value:(NSString *)result;

@end

@interface ScanBarcodeView : UIView

//MARK:-- 初始化view
- (instancetype)initWithScanBarcodeView;

//MARK:-- 设置标题
- (void)setTitle:(NSString *)title;


@property(nonatomic,assign)BOOL isFlashlight;

@property (nonatomic, weak) id<ScanBarcodeViewDelegate> delegate;




@end
