//
//  SZQRCodeViewController.m
//  SZQRCodeDemo
//
//  Created by 陈圣治 on 15/11/6.
//  Copyright © 2015年 shengzhichen. All rights reserved.
//

#import "SZQRCodeViewController.h"
@import AVFoundation;

@interface SZQRCodeViewController () <AVCaptureMetadataOutputObjectsDelegate>

@property (nonatomic, strong) AVCaptureSession *captureSession;

@end

@implementation SZQRCodeViewController

+ (void)detectPermissionWithBlock:(SZQRCodeDetectPermissionBlock)block {
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (authStatus == AVAuthorizationStatusDenied || authStatus == AVAuthorizationStatusRestricted) {
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

#pragma mark - life cycle -
- (instancetype)init {
    if (self = [super init]) {
        self.qrcodeOptions = SZQRCodeOptionQRCode;
    }
    return self;
}

- (instancetype)initWithScaneResultBlock:(SZQRCodeScaneResultBlock)scaneResultBlock {
    if (self = [self init]) {
        _scaneResultBlock = scaneResultBlock;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
        
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.maskView = [[SZQRCodeCoverView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:self.maskView];
    
    [self initCapture];
}

- (void)initCapture {
    self.captureSession = [[AVCaptureSession alloc] init];
    
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    AVCaptureDeviceInput *deviceInput = [[AVCaptureDeviceInput alloc] initWithDevice:device error:nil];
    [self.captureSession addInput:deviceInput];
    AVCaptureMetadataOutput *metadataOutput = [[AVCaptureMetadataOutput alloc] init];
    [self.captureSession addOutput:metadataOutput];
    [metadataOutput setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];

    NSMutableArray *metadataObjectTypes = [NSMutableArray array];
    if ((self.qrcodeOptions & SZQRCodeOptionQRCode) > 0) {
        [metadataObjectTypes addObject:AVMetadataObjectTypeQRCode];
    }
    if ((self.qrcodeOptions & SZQRCodeOptionQRCodeBarCode) > 0) {
        [metadataObjectTypes addObject:AVMetadataObjectTypeEAN13Code];
        [metadataObjectTypes addObject:AVMetadataObjectTypeEAN8Code];
        [metadataObjectTypes addObject:AVMetadataObjectTypeCode128Code];
    }
    metadataOutput.metadataObjectTypes = metadataObjectTypes;

    AVCaptureVideoPreviewLayer *previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:self.captureSession];
    previewLayer.frame = self.view.bounds;
    previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    [self.view.layer insertSublayer:previewLayer atIndex:0];
    metadataOutput.rectOfInterest = [previewLayer metadataOutputRectOfInterestForRect:self.maskView.areaRectWithoutCover];
    
    if (device.isFocusPointOfInterestSupported && [device isFocusModeSupported:AVCaptureFocusModeContinuousAutoFocus]) {
        NSError *error = nil;
        [device lockForConfiguration:&error];
        if (!error) {
            [device setFocusMode:AVCaptureFocusModeContinuousAutoFocus];
            CGRect rectOfInterest = metadataOutput.rectOfInterest;
            [device setFocusPointOfInterest:CGPointMake(rectOfInterest.origin.x + rectOfInterest.size.width/2, rectOfInterest.origin.y + rectOfInterest.size.height/2)];
            [device unlockForConfiguration];
        }
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    [self.captureSession startRunning];
    [self.maskView startDetectionAnimation];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self.captureSession stopRunning];
    [self.maskView stopDetectionAnimation];
}

#pragma mark - AVCaptureMetadataOutputObjectsDelegate -
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection {
    [self.captureSession stopRunning];
    [self.maskView stopDetectionAnimation];
    
    AVMetadataMachineReadableCodeObject *codeObject = metadataObjects.firstObject;
    if (codeObject) {
        NSLog(@"%@", codeObject.stringValue);
        if (_scaneResultBlock) {
            _scaneResultBlock(YES, [codeObject.stringValue copy]);
        }
    }
}

@end
