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
        }
    }];
}


@end
