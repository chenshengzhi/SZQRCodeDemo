//
//  SZQRCodeViewController.h
//  SZQRCodeDemo
//
//  Created by 陈圣治 on 15/11/6.
//  Copyright © 2015年 shengzhichen. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^SZQRCodeDetectPermissionBlock)(BOOL permit);
typedef void(^SZQRCodeScaneResultBlock)(BOOL success, NSString *stringValue);

@interface SZQRCodeViewController : UIViewController

@property (nonatomic, copy) SZQRCodeScaneResultBlock scaneResultBlock;

+ (void)detectPermissionWithBlock:(SZQRCodeDetectPermissionBlock)block;

- (instancetype)initWithScaneResultBlock:(SZQRCodeScaneResultBlock)scaneResultBlock;

@end
