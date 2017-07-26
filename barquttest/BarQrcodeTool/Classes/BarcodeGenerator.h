//
//  BarcodeGenerator.h
//  BarcodeProject
//
//  Created by SG on 2017/3/15.
//  Copyright © 2017年 com.lky.zyt. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface BarcodeGenerator : NSObject
/*生成条形码 对128code的形式
 *barcodeString:传入数据
 *size:生成一维码的图片大小
 */
+ (UIImage *)createBarcodeImageString:(NSString *)barcodeString imagSize:(CGSize)size;

/*生成条形码 对128code的形式
 *QRString:传入数据
 *with:生成二维码的图片大小
 *image:想要二维码中间有个logo,就可以传过来，否则可以传nil
 */
+ (UIImage *)createQRImageString:(NSString *)QRString imageWidth:(CGFloat)width logo:(UIImage *)image;

@end
