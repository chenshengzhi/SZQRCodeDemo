//
//  SZCropFillView.m
//  SZCropFillViewDemo
//
//  Created by 陈圣治 on 15/11/6.
//  Copyright © 2015年 shengzhichen. All rights reserved.
//

#import "SZCropFillView.h"

@implementation SZCropFillView

- (void)commInit {
    self.opaque = NO;
    self.userInteractionEnabled = NO;
    self.fillColor = [UIColor colorWithWhite:0 alpha:.3];
    CGFloat defaultWidth = 180;
    self.noFillRect = CGRectMake(MAX(0, self.frame.size.width/2 - 150/2), MAX(0, self.frame.size.height/2 - 150/2), defaultWidth, defaultWidth);
}

- (instancetype)init {
    if (self = [super init]) {
        [self commInit];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self commInit];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self commInit];
    }
    return self;
}

- (void)awakeFromNib {
    [self commInit];
}

- (void)drawRect:(CGRect)rect {
    CGContextRef ref = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(ref, self.fillColor.CGColor);
    CGContextFillRect(ref, rect);
    
    CGContextClearRect(ref, self.noFillRect);
}

@end
