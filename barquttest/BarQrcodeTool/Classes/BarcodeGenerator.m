//
//  BarcodeGenerator.m
//  BarcodeProject
//
//  Created by SG on 2017/3/15.
//  Copyright © 2017年 com.lky.zyt. All rights reserved.
//

#import "BarcodeGenerator.h"
#import <CoreImage/CoreImage.h>

@implementation BarcodeGenerator

#pragma mark -- 生成一维码
+ (UIImage *)createBarcodeImageString:(NSString *)barcodeString imagSize:(CGSize)size{
    //1.实例化一维码的滤镜
    CIFilter *filter = [CIFilter filterWithName:@"CICode128BarcodeGenerator"];
    //2.恢复滤镜的默认属性（因为滤镜有可能保存上一次的属性）
    [filter setDefaults];
    //3.将字条串转换成NSData
    NSData *data = [barcodeString dataUsingEncoding:NSUTF8StringEncoding];
    //4.通过KVO设置滤镜，传入data,滤镜就知道将传入的data数据生成一维码
    [filter setValue:data forKey:@"inputMessage"];
    //5.生成一维码 （获取滤镜输出的图片）
    CIImage *barcodeImage = [filter outputImage];
    //6. 调整图片大小和消除模糊
    CGFloat scaleX = size.width / barcodeImage.extent.size.width;
    CGFloat scaleY = size.height / barcodeImage.extent.size.height;
    CIImage *outputImage = [barcodeImage imageByApplyingTransform:CGAffineTransformScale(CGAffineTransformIdentity, scaleX, scaleY)];
    //7.返回条形码图
     return [UIImage imageWithCIImage:outputImage];
}

#pragma mark -- 生成二维码
+ (UIImage *)createQRImageString:(NSString *)QRString imageWidth:(CGFloat)width logo:(UIImage *)image{
    //生成二维码CIImage图片
    CIImage *QRCIImage = [BarcodeGenerator createCIImageWithQRForString:QRString];
    UIImage *QRImge = [BarcodeGenerator createImageAdjustCIimageFormCIImage:QRCIImage with:width];
    if (image) {
      return  [BarcodeGenerator addLogoImage: image toImage:QRImge];
    }
    return QRImge;
}
#pragma mark -- Private 生成二维码图片
+ (CIImage *)createCIImageWithQRForString:(NSString *)QRString{

    //1.实例化二维码的滤镜
    CIFilter *filter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    //2.恢复滤镜的默认属性（因为滤镜有可能保存上一次的属性）
    [filter setDefaults];
    //3.将字条串转换成NSData
    NSData *data = [QRString dataUsingEncoding:NSUTF8StringEncoding];
    //4.通过KVO设置滤镜，传入data,滤镜就知道将传入的data数据生成二给码
    [filter setValue:data forKey:@"inputMessage"];
    //5.生成二维码 （获取滤镜输出的图片）
    return [filter outputImage];
}
#pragma mark -- Private 调整图片大小
+ (UIImage *)createImageAdjustCIimageFormCIImage:(CIImage *)image with:(CGFloat)with {
    CGRect extent = CGRectIntegral(image.extent);
    CGFloat scale = MIN(with/CGRectGetWidth(extent), with/CGRectGetHeight(extent));

    size_t width = CGRectGetWidth(extent) * scale;
    size_t height = CGRectGetHeight(extent) * scale;
    CGColorSpaceRef ref = CGColorSpaceCreateDeviceGray();
    CGContextRef bitmapRef = CGBitmapContextCreate(nil, width, height, 8, 0, ref, (CGBitmapInfo)kCGImageAlphaNone);
    CIContext *context = [CIContext contextWithOptions:nil];
    CGImageRef bitmapImage = [context createCGImage:image fromRect:extent];
    CGContextSetInterpolationQuality(bitmapRef, kCGInterpolationNone);
    CGContextScaleCTM(bitmapRef, scale, scale);
    CGContextDrawImage(bitmapRef, extent, bitmapImage);
    // Create an image with the contents of our bitmap
    CGImageRef scaledImage = CGBitmapContextCreateImage(bitmapRef);
    // Cleanup
    CGContextRelease(bitmapRef);
    CGImageRelease(bitmapImage);
    return [UIImage imageWithCGImage:scaledImage];
}

#pragma mark -- Private 绘制Logo
+ (UIImage *)addLogoImage:(UIImage *)logoImage toImage:(UIImage *)image
    {

        UIGraphicsBeginImageContext(image.size);
        //Draw image2
        [image drawInRect:CGRectMake(0, 0, image.size.width, image.size.height)];
        UIImage *centerBacKImage = [UIImage imageNamed:@"barCodebackView"];
        [centerBacKImage drawInRect:CGRectMake(image.size.height*3/8-2.5, image.size.height*3/8-2.5, image.size.height/4+5, image.size.height/4+5)];
        //Draw image1
        [logoImage drawInRect:CGRectMake(image.size.height*3/8+2.5, image.size.height*3/8+2.5, image.size.height/4-5, image.size.height/4-5)];
        UIImage *resultImage=UIGraphicsGetImageFromCurrentImageContext();

        UIGraphicsEndImageContext();
        
        return resultImage;
}





@end
