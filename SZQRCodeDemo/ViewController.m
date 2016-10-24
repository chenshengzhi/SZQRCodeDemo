//
//  ViewController.m
//  SZQRCodeDemo
//
//  Created by 陈圣治 on 15/11/6.
//  Copyright © 2015年 shengzhichen. All rights reserved.
//

#import "ViewController.h"
#import "SZQRCodeViewController.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UIButton *startQRCode;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)startQRCodeHandle:(id)sender {
    __weak typeof(self) weakSelf = self;
    [SZQRCodeViewController detectPermissionWithBlock:^(BOOL permit) {
        if (permit) {
            SZQRCodeViewController *vc = [[SZQRCodeViewController alloc] initWithScaneResultBlock:^(BOOL success, NSString *stringValue) {
                [weakSelf.navigationController popViewControllerAnimated:NO];
                if (success) {
                    NSLog(@"-----\n%@", stringValue);
                    if ([stringValue.lowercaseString hasPrefix:@"http://"] || [stringValue.lowercaseString hasPrefix:@"https://"]) {
                        dispatch_async(dispatch_get_main_queue(), ^(void){
                            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:stringValue]];
                        });
                    }
                }
            }];
            [weakSelf.navigationController pushViewController:vc animated:YES];
        } else {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"没有权限访问相机"
                                                                message:@"请在 \"设置 - 隐私 - 相机\" 设置允许访问相机。"
                                                               delegate:nil
                                                      cancelButtonTitle:nil
                                                      otherButtonTitles:@"确定", nil];
            [alertView show];
        }
    }];
}

- (IBAction)generateHandle:(id)sender {
    UIImage *qrcode = [self createNonInterpolatedUIImageFormCIImage:[self createQRForString:@"http://www.chenshengzhi.name"] withSize:200.0f];
    UIImage *customQrcode = [self imageBlackToTransparent:qrcode withRed:60.0f andGreen:74.0f andBlue:89.0f];
    
    UIViewController *vc = [[UIViewController alloc] init];
    vc.view.backgroundColor = [UIColor whiteColor];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:customQrcode];
    [vc.view addSubview:imageView];
    imageView.center = CGPointMake(vc.view.frame.size.width/2, vc.view.frame.size.height/2);
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)detectImageHandle:(id)sender {
    if ([[[UIDevice currentDevice] systemVersion] compare:@"8.0" options:NSNumericSearch] != NSOrderedAscending) {
        //iOS8.0及以上
        CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeQRCode context:nil options:nil];
        
        UIImage *srcImage = [UIImage imageNamed:@"generate"];
        CIImage *image = [CIImage imageWithCGImage:srcImage.CGImage];
        NSArray *features = [detector featuresInImage:image];
        NSLog(@"%@", features);
        
        CIQRCodeFeature *f = [features firstObject];
        NSLog(@"%@", f.messageString);
        
        NSString *stringValue = f.messageString.lowercaseString;
        if ([stringValue.lowercaseString hasPrefix:@"http://"] || [stringValue.lowercaseString hasPrefix:@"https://"]) {
            dispatch_async(dispatch_get_main_queue(), ^(void){
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:stringValue]];
            });
        }
    } else {
        NSLog(@"系统版本太低, 不支持");
    }
}

#pragma mark - 二维码生成工具方法 -
- (CIImage *)createQRForString:(NSString *)qrString {
    // Need to convert the string to a UTF-8 encoded NSData object
    NSData *stringData = [qrString dataUsingEncoding:NSUTF8StringEncoding];
    // Create the filter
    CIFilter *qrFilter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    // Set the message content and error-correction level
    [qrFilter setValue:stringData forKey:@"inputMessage"];
    [qrFilter setValue:@"M" forKey:@"inputCorrectionLevel"];
    // Send the image back
    return qrFilter.outputImage;
}

- (UIImage *)createNonInterpolatedUIImageFormCIImage:(CIImage *)image withSize:(CGFloat)size {
    CGRect extent = CGRectIntegral(image.extent);
    CGFloat scale = MIN(size/CGRectGetWidth(extent), size/CGRectGetHeight(extent));
    // create a bitmap image that we'll draw into a bitmap context at the desired size;
    size_t width = CGRectGetWidth(extent) * scale;
    size_t height = CGRectGetHeight(extent) * scale;
    CGColorSpaceRef cs = CGColorSpaceCreateDeviceGray();
    CGContextRef bitmapRef = CGBitmapContextCreate(nil, width, height, 8, 0, cs, (CGBitmapInfo)kCGImageAlphaNone);
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

void ProviderReleaseData (void *info, const void *data, size_t size){
    free((void*)data);
}

- (UIImage *)imageBlackToTransparent:(UIImage *)image withRed:(CGFloat)red andGreen:(CGFloat)green andBlue:(CGFloat)blue{
    const int imageWidth = image.size.width;
    const int imageHeight = image.size.height;
    size_t      bytesPerRow = imageWidth * 4;
    uint32_t* rgbImageBuf = (uint32_t*)malloc(bytesPerRow * imageHeight);
    // create context
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(rgbImageBuf, imageWidth, imageHeight, 8, bytesPerRow, colorSpace,
                                                 kCGBitmapByteOrder32Little | kCGImageAlphaNoneSkipLast);
    CGContextDrawImage(context, CGRectMake(0, 0, imageWidth, imageHeight), image.CGImage);
    // traverse pixe
    int pixelNum = imageWidth * imageHeight;
    uint32_t* pCurPtr = rgbImageBuf;
    for (int i = 0; i < pixelNum; i++, pCurPtr++) {
        if ((*pCurPtr & 0xFFFFFF00) < 0x99999900) {
            // change color
            uint8_t* ptr = (uint8_t*)pCurPtr;
            ptr[3] = red; //0~255
            ptr[2] = green;
            ptr[1] = blue;
        } else {
            uint8_t* ptr = (uint8_t*)pCurPtr;
            ptr[0] = 0;
        }
    }
    // context to image
    CGDataProviderRef dataProvider = CGDataProviderCreateWithData(NULL, rgbImageBuf, bytesPerRow * imageHeight, ProviderReleaseData);
    CGImageRef imageRef = CGImageCreate(imageWidth, imageHeight, 8, 32, bytesPerRow, colorSpace,
                                        kCGImageAlphaLast | kCGBitmapByteOrder32Little, dataProvider,
                                        NULL, true, kCGRenderingIntentDefault);
    CGDataProviderRelease(dataProvider);
    UIImage* resultUIImage = [UIImage imageWithCGImage:imageRef];
    // release
    CGImageRelease(imageRef);
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    return resultUIImage;
}

@end
