/*
 *	_________         __       __
 * |______  /         \ \     / /
 *       / /           \ \   / /
 *      / /             \ \ / /
 *     / /               \   /
 *    / /                 | |
 *   / /                  | |
 *  / /_________          | |
 * /____________|         |_|
 *
 Copyright (c) 2011 ~ 2016 zhangyun. All rights reserved.
 */

//[[ZYScannerView sharedScannerView] showOnView:self.view block:^(NSString *str) {
//    NSLog(@"%@",str);
//}];

#import "ZYScannerView.h"
#import <AVFoundation/AVFoundation.h>

@interface ZYScannerView () <AVCaptureMetadataOutputObjectsDelegate>

@property (nonatomic, strong) UIImageView * scanLineImg;

@property (nonatomic, strong) AVCaptureSession *session;

@property (nonatomic, strong) AVCaptureVideoPreviewLayer *perviewLayer;

@property (nonatomic, strong) UIView *scannerView;

@property (nonatomic, strong)UIButton *dakaizhaoming;

@property (nonatomic, strong) NSMutableArray *metadataObjectTypes;/**< 输入类型 */

@property (nonatomic, strong) UILabel *textlabless;
/** 第一次旋转 */
@property (nonatomic, assign) CGFloat isFirstTransition;

@property (nonatomic,strong)UIImageView *topLeftImg;
@property (nonatomic,strong)UIImageView *topRightImg;
@property (nonatomic,strong)UIImageView *bottomLeftImg;
@property (nonatomic,strong)UIImageView *bottomRightImg;
/** 屏幕尺寸参数 */
#define SCREEN_WIDTH        ([UIScreen mainScreen].bounds.size.width)
#define SCREEN_HEIGHT       ([UIScreen mainScreen].bounds.size.height)

@property (nonatomic, assign) int opens;/**< 打开样式 */
@end

@implementation ZYScannerView


- (NSMutableArray *)metadataObjectTypes{
    if (!_metadataObjectTypes) {
        _metadataObjectTypes = [NSMutableArray arrayWithObjects:AVMetadataObjectTypeAztecCode, AVMetadataObjectTypeCode128Code, AVMetadataObjectTypeCode39Code, AVMetadataObjectTypeCode39Mod43Code, AVMetadataObjectTypeCode93Code, AVMetadataObjectTypeEAN13Code, AVMetadataObjectTypeEAN8Code, AVMetadataObjectTypePDF417Code, AVMetadataObjectTypeQRCode, AVMetadataObjectTypeUPCECode, nil];
        
        // >= iOS 8
        if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_7_1) {
            [_metadataObjectTypes addObjectsFromArray:@[AVMetadataObjectTypeInterleaved2of5Code, AVMetadataObjectTypeITF14Code, AVMetadataObjectTypeDataMatrixCode]];
        }
    }
    
    return _metadataObjectTypes;
}

+ (ZYScannerView *)sharedScannerView {
    
    static ZYScannerView *v = nil;
    
    v = [[ZYScannerView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    return v;
    
}

- (void)showOnView:(UIView *)view block:(BackBlock)block{
    
    self.back = [block copy];
    
    [self.session startRunning];
    
    [view addSubview:self];
    
    self.hidden = NO;
}

- (void)dismiss {
    
    [self.session stopRunning];
    
    self.hidden = YES;
    
    [self removeFromSuperview];
    
}

#pragma mark - 内部调用

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
      
        self.backgroundColor=[UIColor lightGrayColor ];
        
        _scannerView = [[UIView alloc] initWithFrame:CGRectMake(0, 150,  self.bounds.size.width, 45)];
        
        _scannerView.backgroundColor = [UIColor clearColor];
        
//        _scannerView.layer.borderWidth = 2.0;
//        
//        _scannerView.layer.borderColor = [UIColor lightGrayColor].CGColor;
        
        //边框
        UIImage * topLeft = [UIImage imageNamed:@"ScanQR1"];
        UIImage * topRight = [UIImage imageNamed:@"ScanQR2"];
        UIImage * bottomLeft = [UIImage imageNamed:@"ScanQR3"];
        UIImage * bottomRight = [UIImage imageNamed:@"ScanQR4"];
        
        //左上
        self.topLeftImg = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 16, 16)];
        self.topLeftImg.image = topLeft;
        [self.scannerView addSubview:self.topLeftImg];
        
        //右上
        self.topRightImg = [[UIImageView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-16, 0, 16, 16)];
        self.topRightImg.image = topRight;
        [self.scannerView addSubview:self.topRightImg];
        
        //左下
        self.bottomLeftImg = [[UIImageView alloc] initWithFrame:CGRectMake(0, 45-16, 16, 16)];
        self.bottomLeftImg.image = bottomLeft;
        [self.scannerView addSubview:self.bottomLeftImg];
        
        //右下
        self.bottomRightImg = [[UIImageView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-16,45-16 , 16, 16)];
        self.bottomRightImg.image = bottomRight;
        [self.scannerView addSubview:self.bottomRightImg];
        
        //扫描线
//        UIImage * scanLine = [UIImage imageNamed:@"line2.png"];
        UIImage * scanLine = [UIImage imageNamed:@"line.png"];
        self.scanLineImg = [[UIImageView alloc] init];
        self.scanLineImg.image = scanLine;
//        self.scanLineImg.contentMode = UIViewContentModeScaleAspectFit;
//        [self.scanLineImg setFrame:CGRectMake(0, 150, 1.2, 45)];
         [self.scanLineImg setFrame:CGRectMake(0, 150, SCREEN_WIDTH, 1.02)];
//        =UIRectFrame(CGRectMake(0, 150, 0, 45));
        [self.scannerView addSubview:self.scanLineImg];
        
        [self.scanLineImg.layer addAnimation:[self animation] forKey:nil];
        
        UIView *backview=[[UIView alloc]initWithFrame:CGRectMake(0, 0, self.bounds.size.width, 150)];
        
        backview.backgroundColor=[UIColor blackColor];
        
        backview.alpha=0.45;
        
        UILabel *textlable=[[UILabel alloc]initWithFrame:CGRectMake(0, 50,  self.bounds.size.width, 52)];
        
        textlable.text=[[NSUserDefaults standardUserDefaults] valueForKey:@"textlable"];
        
        textlable.textColor=[UIColor whiteColor];
        
        textlable.font=[UIFont systemFontOfSize:21];
        
        textlable.textAlignment=NSTextAlignmentCenter;
        
        [backview addSubview:textlable];
        
        [self addSubview:backview];
        
        UIView *backview2=[[UIView alloc]initWithFrame:CGRectMake(0, 195,  self.bounds.size.width, 400)];
        
        backview2.backgroundColor=[UIColor lightGrayColor];
        
        backview2.alpha=0.45;
        
        [self addSubview:backview2];
        
        _dakaizhaoming=[[UIButton alloc  ]initWithFrame:CGRectMake(50, self.frame.size.height-125, 40, 40)];
        
        self.dakaizhaoming.layer.cornerRadius=10;//self.imageView.frame.size.width/2+5;//裁成圆角
        
        self.dakaizhaoming.layer.masksToBounds=YES;//隐藏裁剪掉的部分
        
//        _dakaizhaoming.backgroundColor=[UIColor colorWithRed:49.0/255.0 green:134.0/255.0 blue:251.0/255.0 alpha:1];
        
        [_dakaizhaoming setBackgroundImage:[UIImage imageNamed:@"Flashlight_N"] forState:UIControlStateNormal];

//        [_dakaizhaoming setTitle:@"手电筒" forState:UIControlStateNormal];
        
        UILabel *textlable3=[[UILabel alloc]initWithFrame:CGRectMake(40, self.frame.size.height-80, 60, 20)];
        textlable3.text=@"手电筒";
        self.textlabless=textlable3;
        textlable3.textAlignment=NSTextAlignmentCenter;
        textlable3.textColor=[UIColor whiteColor];
        [self addSubview:textlable3];
        
        [_dakaizhaoming addTarget:self action:@selector(setDakaizhaoming:) forControlEvents:UIControlEventTouchUpInside];
        
        [self addSubview:_dakaizhaoming];
        
        UIButton *blackbtn= [[UIButton alloc]initWithFrame:CGRectMake(self.frame.size.width -100, self.frame.size.height-134, 40, 60)];
        
        blackbtn.layer.cornerRadius=7;//self.imageView.frame.size.width/2+5;//裁成圆角
        
        [blackbtn setBackgroundImage:[UIImage imageNamed:@"Down"] forState:UIControlStateNormal];
        
        blackbtn.layer.masksToBounds=YES;//隐藏裁剪掉的部分
        
//        blackbtn.backgroundColor=[UIColor colorWithRed:49.0/255.0 green:134.0/255.0 blue:251.0/255.0 alpha:1];
//       [blackbtn setImage:[[UIImage imageNamed:@"Down"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forState:UIControlStateNormal];
//        [blackbtn setTitle:@"返回" forState:UIControlStateNormal];
        
        [blackbtn addTarget:self action:@selector(black) forControlEvents:UIControlEventTouchUpInside];
        UILabel *textlable2=[[UILabel alloc]initWithFrame:CGRectMake(self.frame.size.width -100, self.frame.size.height-80, 40, 20)];
        textlable2.text=@"返回";
        textlable2.textAlignment=NSTextAlignmentCenter;
        textlable2.textColor=[UIColor whiteColor];
        [self addSubview:textlable2];
        [self addSubview:blackbtn];
        
        [self addSubview:_scannerView];
        
        [self start];
        
    }
    
    return self;
}

- (void)start {
    // 摄像头设备
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    // 设置输入
    NSError *error = nil;
    
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
    if (error) {
        
        NSLog(@"启动摄像头失败：%@",error.localizedDescription);
        
        return;
        
    }
    
    // 设置输出元素
    AVCaptureMetadataOutput *output = [[AVCaptureMetadataOutput alloc] init];
    
    [output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    
    // 设置拍摄会话
    AVCaptureSession *session = [[AVCaptureSession alloc] init];
    
    [session addInput:input];
    
    [session addOutput:output];
    
    session.sessionPreset = AVCaptureSessionPresetHigh;
    
    // 制定输出类型

     output.metadataObjectTypes = self.metadataObjectTypes;
    // 设置预览图次
    AVCaptureVideoPreviewLayer *perviewLayer = [AVCaptureVideoPreviewLayer layerWithSession:session];
    
    perviewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    
    perviewLayer.frame = self.bounds;
    
    perviewLayer.backgroundColor=[[UIColor colorWithWhite:0.5f alpha:0.5]CGColor];

    _perviewLayer = perviewLayer;
    
    [self.layer insertSublayer:_perviewLayer atIndex:0];
    
    CGSize size = [UIScreen mainScreen].bounds.size;
    
    CGRect cropRect = _scannerView.frame;
    
    CGFloat p1 = size.height/size.width;
    
    CGFloat p2 = 1920./1080.;  //使用1080p的图像输出
    
    if (p1 < p2) {
        
        CGFloat fixHeight = [UIScreen mainScreen].bounds.size.width * 1920. / 1080.;
        
        CGFloat fixPadding = (fixHeight - size.height)/2;
        
        output.rectOfInterest = CGRectMake((cropRect.origin.y + fixPadding)/fixHeight,
                                           cropRect.origin.x/size.width,
                                           cropRect.size.height/fixHeight,
                                           cropRect.size.width/size.width);
    } else {
        
        CGFloat fixWidth = [UIScreen mainScreen].bounds.size.height * 1080. / 1920.;
        
        CGFloat fixPadding = (fixWidth - size.width)/2;
        
        output.rectOfInterest = CGRectMake(cropRect.origin.y/size.height,
                                           (cropRect.origin.x + fixPadding)/fixWidth,
                                           cropRect.size.height/size.height,
                                           cropRect.size.width/fixWidth);
        
    }
    
    _session = session;

}

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection

{
    
    NSLog(@"%@", metadataObjects);
    
    if (metadataObjects != nil && [metadataObjects count] > 0) {
        
        AVMetadataMachineReadableCodeObject *obj = metadataObjects[0];
        
        if ([[obj type] isEqualToString:AVMetadataObjectTypeCode39Code]||[[obj type] isEqualToString:AVMetadataObjectTypeEAN13Code]||[[obj type] isEqualToString:AVMetadataObjectTypeCode128Code]||[[obj type] isEqualToString:AVMetadataObjectTypeQRCode]) {
            
            NSString *bakestr=obj.stringValue;
            
            if (bakestr!=nil) {
                
                [self.session stopRunning];
                
                if (self.back) {
                    
                    self.back(bakestr);
                    
//                    [_dakaizhaoming setTitle:@"打開照明" forState:UIControlStateNormal];
                    [_dakaizhaoming setBackgroundImage:[UIImage imageNamed:@"Flashlight_N"] forState:UIControlStateNormal];

                    [self dismiss];
                    
                }
            }
        }
    }
}

//记得返回扫描数据
-(void)black{
    
//    [_dakaizhaoming setTitle:@"打開照明" forState:UIControlStateNormal];
    [_dakaizhaoming setBackgroundImage:[UIImage imageNamed:@"Flashlight_N"] forState:UIControlStateNormal];

    [self systemLightSwitch:NO];
    
   [[NSNotificationCenter defaultCenter] postNotificationName:@"PassValueWithNotification" object:nil];
    
    [self dismiss];
    
    }
-(void)setDakaizhaoming:(UIButton *)dakaizhaoming{
    
    
    
    if (self.opens==0) {
        
        [self systemLightSwitch:YES];
        
        
    } else {
        
        [self systemLightSwitch:NO];
        
    }
    
}
- (void)systemLightSwitch:(BOOL)open
{
    if (open) {
        self.textlabless.textColor=[UIColor greenColor];
        [_dakaizhaoming setBackgroundImage:[UIImage imageNamed:@"Flashlight_H"] forState:UIControlStateNormal];
        self.opens=1;
//        [_dakaizhaoming setTitle:@"關閉照明" forState:UIControlStateNormal];
        
    } else {
         self.textlabless.textColor=[UIColor whiteColor];
        [_dakaizhaoming setBackgroundImage:[UIImage imageNamed:@"Flashlight_N"] forState:UIControlStateNormal];
        self.opens=0;

//        [_dakaizhaoming setTitle:@"打開照明" forState:UIControlStateNormal];
        
    }
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    if ([device hasTorch]) {
        
        [device lockForConfiguration:nil];
        
        if (open) {
            self.opens=1;
            [device setTorchMode:AVCaptureTorchModeOn];
            
        } else {
            self.opens=0;
            [device setTorchMode:AVCaptureTorchModeOff];
            
        }
        
        [device unlockForConfiguration];
    }
}
/**
 *  动画
 */
- (CABasicAnimation *)animation{
    CABasicAnimation * animation = [CABasicAnimation animationWithKeyPath:@"position"];
    animation.duration = 3;
    animation.fillMode = kCAFillModeForwards;
    animation.removedOnCompletion = NO;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    animation.repeatCount = MAXFLOAT;
    
//    animation.fromValue = [NSValue valueWithCGPoint:CGPointMake(0,25 )];
//    animation.toValue = [NSValue valueWithCGPoint:CGPointMake(SCREEN_WIDTH, 25)];
        animation.fromValue = [NSValue valueWithCGPoint:CGPointMake(SCREEN_WIDTH/2,0 )];
        animation.toValue = [NSValue valueWithCGPoint:CGPointMake(SCREEN_WIDTH/2,45)];
    
    return animation;
}


@end
