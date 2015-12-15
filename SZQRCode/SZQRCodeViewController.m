//
//  SZQRCodeViewController.m
//  SZQRCodeDemo
//
//  Created by 陈圣治 on 15/11/6.
//  Copyright © 2015年 shengzhichen. All rights reserved.
//

#import "SZQRCodeViewController.h"
#import "SZQRCodeCoverView.h"
@import AVFoundation;

@interface SZQRCodeViewController () <AVCaptureMetadataOutputObjectsDelegate>

@property (nonatomic, strong) SZQRCodeCoverView *maskView;
@property (nonatomic, strong) AVCaptureSession *captureSession;

@end

@implementation SZQRCodeViewController

+ (void)detectPermissionWithBlock:(SZQRCodeDetectPermissionBlock)block {
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if (!device) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"没有可用的相机"
                                                            message:nil
                                                           delegate:nil
                                                  cancelButtonTitle:nil
                                                  otherButtonTitles:@"确定", nil];
        [alertView show];
        return;
    }
    
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (authStatus == AVAuthorizationStatusDenied || authStatus == AVAuthorizationStatusRestricted) {
        [SZQRCodeViewController showNoPermisstionNotice];
        if (block) {
            block(NO);
        }
    } else if (authStatus == AVAuthorizationStatusNotDetermined) {
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
            dispatch_async(dispatch_get_main_queue(), ^(void){
                if (granted) {
                    if (block) {
                        block(YES);
                    }
                } else {
                    [SZQRCodeViewController showNoPermisstionNotice];
                    if (block) {
                        block(NO);
                    }
                }
            });
        }];
    } else {
        if (block) {
            block(YES);
        }
    }
}

+ (void)showNoPermisstionNotice {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"没有权限访问相机"
                                                        message:@"请在 \"设置 - 隐私 - 相机\" 设置允许访问相机。"
                                                       delegate:nil
                                              cancelButtonTitle:nil
                                              otherButtonTitles:@"确定", nil];
    [alertView show];
}

#pragma mark - life cycle -
- (instancetype)initWithScaneResultBlock:(SZQRCodeScaneResultBlock)scaneResultBlock {
    if (self = [super init]) {
        _scaneResultBlock = scaneResultBlock;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
        
    self.view.backgroundColor = [UIColor whiteColor];
    
    _maskView = [[SZQRCodeCoverView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:_maskView];
    
    [self initCapture];
    
    [_captureSession startRunning];
    [_maskView startScanAnimation];
}

- (void)initCapture {
    _captureSession = [[AVCaptureSession alloc] init];
    
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    AVCaptureDeviceInput *deviceInput = [[AVCaptureDeviceInput alloc] initWithDevice:device error:nil];
    [_captureSession addInput:deviceInput];
    AVCaptureMetadataOutput *metadataOutput = [[AVCaptureMetadataOutput alloc] init];
    [_captureSession addOutput:metadataOutput];
    [metadataOutput setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    if ([metadataOutput.availableMetadataObjectTypes containsObject:AVMetadataObjectTypeQRCode]) {
        metadataOutput.metadataObjectTypes = [NSArray arrayWithObject:AVMetadataObjectTypeQRCode];
    }
    
    AVCaptureVideoPreviewLayer *previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:_captureSession];
    previewLayer.frame = self.view.bounds;
    previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    [self.view.layer insertSublayer:previewLayer atIndex:0];
    metadataOutput.rectOfInterest = [previewLayer metadataOutputRectOfInterestForRect:_maskView.areaRectWithoutCover];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [_captureSession startRunning];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [_captureSession stopRunning];
}

#pragma mark - AVCaptureMetadataOutputObjectsDelegate -
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection {
    [_captureSession stopRunning];
    
    AVMetadataMachineReadableCodeObject *codeObject = metadataObjects.firstObject;
    if (codeObject) {
        if (_scaneResultBlock) {
            _scaneResultBlock(YES, [codeObject.stringValue copy]);
        }
    }
}

@end
