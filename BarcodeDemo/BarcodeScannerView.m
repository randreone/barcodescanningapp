//
//  BarcodeScannerView.m
//  BarcodeDemo
//
//  Created by Ike Ellis on 1/15/16.
//  Copyright © 2016 FormFast. All rights reserved.
//

#import "BarcodeScannerView.h"

@implementation BarcodeScannerOverlayView


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    
    if (_drawCorners != nil) {
        [self drawScanOutline:_drawCorners];
    }
}

- (void)drawScanOutline:(NSArray *)corners {
    
    NSAssert(corners != nil && corners.count == 4, @"Invalid corners");
    CGPoint points[4];

    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetStrokeColorWithColor(context, [UIColor greenColor].CGColor);
    
    //convert the points to CGPoint
    for (NSInteger pointIndex = 0; pointIndex < 4; ++pointIndex) {
        NSDictionary *pointDict = corners[pointIndex];
        points[pointIndex] = CGPointMake([pointDict[@"X"] floatValue], [pointDict[@"Y"] floatValue]);
    }
    
    CGContextMoveToPoint(context, points[0].x, points[0].y);
    for (NSInteger pointIndex = 1; pointIndex < 4; ++pointIndex) {
        CGContextAddLineToPoint(context, points[pointIndex].x, points[pointIndex].y);
    }
    
    CGContextClosePath(context);
    CGContextDrawPath(context, kCGPathStroke);

}

@end
