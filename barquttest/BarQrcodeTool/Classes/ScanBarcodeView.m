//
//  ScanBarcodeView.m
//  BarQrcodeDemo
//
//  Created by MJX on 2017/6/21.
//  Copyright © 2017年 ShangTong. All rights reserved.
//

#import "ScanBarcodeView.h"
#import <AVFoundation/AVFoundation.h>

/*
 * 屏幕 高宽 边界
 */
#define SB_SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height
#define SB_SCREEN_WIDTH  [UIScreen mainScreen].bounds.size.width
#define SB_SCREEN_BOUNDS  [UIScreen mainScreen].bounds
#define ScanBar_WITH 260

#define SB_TOP (SB_SCREEN_HEIGHT - ScanBar_WITH)/2
#define SB_LEFT (SB_SCREEN_WIDTH - ScanBar_WITH)/2

#define SB_kScanRect CGRectMake(SB_LEFT, SB_TOP, ScanBar_WITH, ScanBar_WITH)

@interface ScanBarcodeView ()<AVCaptureMetadataOutputObjectsDelegate>{
    int num;
    BOOL upOrdown;
    NSTimer *timer;
    CAShapeLayer *cropLayer;
}
@property (nonatomic, strong) AVCaptureDevice *device;
@property (nonatomic, strong) AVCaptureInput *input;
@property (nonatomic, strong) AVCaptureMetadataOutput *output;
@property (nonatomic, strong) AVCaptureSession *session;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *captureLayer;

@property (nonatomic, strong) UIImageView *line;

@property(nonatomic,strong)UIButton *status;



@end

@implementation ScanBarcodeView

- (void)dealloc
{
    [timer invalidate];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.frame = CGRectMake(0, 0, SB_SCREEN_WIDTH, SB_SCREEN_HEIGHT);
        [self setUI];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        self.frame = CGRectMake(0, 0, SB_SCREEN_WIDTH, SB_SCREEN_HEIGHT);
        [self setUI];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self setUI];
    }
    return self;
}

- (instancetype)initWithScanBarcodeView{
    self = [super initWithFrame:CGRectMake(0, 0, SB_SCREEN_WIDTH, SB_SCREEN_HEIGHT)];
    if (self ) {
        [self setUI];
    }
    return self;
}
//MARK:-- 初始化view
- (void)setUI{
    //设置标题
    [self setTitle:nil];
    // 设置返回按钮
    [self setBackView];
    // 设置扫描区域和动画
    [self configView];
    // 设置背景的颜色
    [self setCropRect];
    // 设置扫描
    [self setCamera];
}
//MARK:-- 设置返回按钮
- (void)setBackView{
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(5, 32, 75, 35)];
    [button setImage:[UIImage imageNamed:@"cancel"] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(removeScanBarcodeView) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:button];
}

//MARK:-- 移除当前视图
- (void)removeScanBarcodeView{
    [self removeFromSuperview];
}
//MARK:-- 设置标题
- (void)setTitle:(NSString *)title{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(100, 32,SB_SCREEN_WIDTH-200 , 35)];
    label.textColor = [UIColor colorWithRed:100 green:100 blue:100 alpha:1];
    label.textAlignment= NSTextAlignmentCenter;
    if (title) {
        label.text = title;
    }else{
        label.text = @"二维码/条码";
    }
    [self addSubview:label];
}

- (void)setIsFlashlight:(BOOL)isFlashlight{
    _isFlashlight = isFlashlight;
    if (isFlashlight) {
        
        UIButton *flashlightButton  = [[UIButton alloc]initWithFrame:CGRectMake(SB_SCREEN_WIDTH/2-25, SB_TOP + ScanBar_WITH + 30, 50, 75)];
        [flashlightButton setImage:[UIImage imageNamed: @"flashligh"] forState:UIControlStateNormal];
        [self addSubview:flashlightButton];
        [flashlightButton addTarget:self action:@selector(flashlightClick:) forControlEvents:UIControlEventTouchUpInside];
        
        self.status = [[UIButton alloc] initWithFrame:CGRectMake(SB_SCREEN_WIDTH/2-30, CGRectGetMaxY(flashlightButton.frame)+10, 60, 20)];
        [self.status setTitleColor:[UIColor colorWithRed:100 green:100 blue:100 alpha:1] forState:UIControlStateNormal];
        self.status.userInteractionEnabled = NO;
        [self.status setTitle:@"打开" forState:UIControlStateNormal];
        [self.status setTitle:@"关闭" forState:UIControlStateSelected];
        [self addSubview:self.status];
        
    }
}


- (void)flashlightClick:(UIButton *)sender{
    sender.selected = !sender.selected;
    [self.device lockForConfiguration:nil];
    self.device.torchMode =  sender.selected? AVCaptureTorchModeOn:AVCaptureTorchModeOff;
    [self.device unlockForConfiguration];
    self.status.selected = sender.selected;
}

#pragma mark -- 设置扫描区域和动画
- (void)configView{
    UILabel *promptLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, SB_TOP-35,SB_SCREEN_WIDTH , 30)];
    promptLabel.textColor = [UIColor colorWithRed:100 green:100 blue:100 alpha:1];
    promptLabel.textAlignment= NSTextAlignmentCenter;
    promptLabel.text = @"请对准条码";
    [self addSubview:promptLabel];
    
    UIImageView *imageView = [[UIImageView alloc]initWithFrame:SB_kScanRect];
    imageView.image=[UIImage imageNamed:@"pick_bg"];
    [self addSubview:imageView];
    
    upOrdown = NO;
    num = 0 ;
    
    _line = [[UIImageView alloc]initWithFrame:CGRectMake(SB_LEFT, SB_TOP+10, ScanBar_WITH, 2)];
    _line.image = [UIImage imageNamed:@"line"];
    [self addSubview:_line];
    
    timer = [NSTimer scheduledTimerWithTimeInterval:0.02 target:self selector:@selector(animation) userInfo:nil repeats:YES];
    timer.fireDate = [NSDate distantPast];
}

- (void)animation{
    if (upOrdown == NO) {
        num ++;
        
        if (2*num == 200) {
            upOrdown = YES;
        }
    }else{
        num --;
        if (num == 0) {
            upOrdown = NO;
        }
    }
    _line.frame = CGRectMake(SB_LEFT, SB_TOP+10 + 2*num, ScanBar_WITH, 2);
}

#pragma mark -- 设置背景的颜色
- (void)setCropRect{
    cropLayer = [[CAShapeLayer alloc] init];
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, nil, SB_kScanRect);
    CGPathAddRect(path, nil, SB_SCREEN_BOUNDS);
    [cropLayer setFillRule:kCAFillRuleEvenOdd];
    [cropLayer setPath:path];
    [cropLayer setFillColor: [UIColor grayColor].CGColor];
    [cropLayer setOpacity:0.5];
    [cropLayer setNeedsDisplay];
    [self.layer addSublayer:cropLayer];
}

#pragma mark -- 设置扫描及代理
- (void)setCamera{
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if (!device) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self removeScanBarcodeView];
        });
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"该设备没有摄像头" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alertView show];
//        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:@"该设备没有摄像头" preferredStyle:UIAlertControllerStyleAlert];
//        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDestructive handler:nil];
//        [alertController addAction:cancelAction];
//        [self presentViewController:alertController animated:YES completion:nil];
        
        return;
    }
    //1.实例化拍摄设备
    _device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    //2.设置输入设备
    _input = [AVCaptureDeviceInput deviceInputWithDevice:self.device error:nil];
    
    //3.设置元数输入和代理
    _output = [[AVCaptureMetadataOutput alloc]init];
    [_output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    //4. 设置扫描区域
    CGFloat top = SB_TOP/SB_SCREEN_HEIGHT;
    CGFloat left = SB_LEFT/SB_SCREEN_WIDTH;
    CGFloat width = ScanBar_WITH/SB_SCREEN_WIDTH;
    CGFloat height = ScanBar_WITH/SB_SCREEN_HEIGHT;
    //注意top与left互换 width与height互换
    [_output setRectOfInterest:CGRectMake(top, left, height, width)];
    
    //5. 添加拍摄会话
    _session = [[AVCaptureSession alloc]init];
    [_session setSessionPreset:AVCaptureSessionPresetHigh];
    if ([_session canAddInput:self.input]) {
        [_session addInput:self.input];
    }
    if ([_session canAddOutput:self.output]) {
        [_session addOutput:self.output];
    }
    
    //6. 设置扫码支持的编码格式(如下设置条形码和二维码兼容)
    _output.metadataObjectTypes=@[AVMetadataObjectTypeQRCode,AVMetadataObjectTypeEAN13Code, AVMetadataObjectTypeEAN8Code, AVMetadataObjectTypeCode128Code];
    
    //7. 实例化预览图层
    _captureLayer = [AVCaptureVideoPreviewLayer layerWithSession:_session];
    _captureLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    _captureLayer.frame = SB_SCREEN_BOUNDS;
    //8. 将图层插入到当前视图
    [self.layer insertSublayer:_captureLayer atIndex:0];
    
    //9. 启动会话
    [_session startRunning];
}

#pragma mark -- AVCaptureMetadataOutputObjectsDelegate

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection{
    if (metadataObjects.count>0) {
        //停止扫描
        [_session stopRunning];
        timer.fireDate = [NSDate distantFuture];
        AVMetadataMachineReadableCodeObject *metadataObject = [metadataObjects objectAtIndex:0];
        NSString *stringValue=metadataObject.stringValue;
        if (self.delegate && [self.delegate  respondsToSelector:@selector(didFinishResultForScanBarcodeView:value:)]) {
            [self.delegate didFinishResultForScanBarcodeView:self value:stringValue];
            [self removeScanBarcodeView];
        }
    }
}

@end
