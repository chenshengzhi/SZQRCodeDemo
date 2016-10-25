//
//  SZQRCodeViewController.h
//  SZQRCodeDemo
//
//  Created by 陈圣治 on 15/11/6.
//  Copyright © 2015年 shengzhichen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SZQRCodeCoverView.h"

typedef NS_OPTIONS(NSUInteger, SZQRCodeOptions) {
    SZQRCodeOptionQRCode = 1 << 0,
    SZQRCodeOptionQRCodeBarCode = 1 << 1,
    SZQRCodeOptionAll = SZQRCodeOptionQRCode | SZQRCodeOptionQRCodeBarCode,
};

typedef void(^SZQRCodeDetectPermissionBlock)(BOOL permit);
typedef void(^SZQRCodeScaneResultBlock)(BOOL success, NSString *stringValue);

@interface SZQRCodeViewController : UIViewController

@property (nonatomic, strong) SZQRCodeCoverView *maskView;

@property (nonatomic) SZQRCodeOptions qrcodeOptions;

@property (nonatomic, copy) SZQRCodeScaneResultBlock scaneResultBlock;

+ (void)detectPermissionWithBlock:(SZQRCodeDetectPermissionBlock)block;

- (instancetype)initWithScaneResultBlock:(SZQRCodeScaneResultBlock)scaneResultBlock;

@end
