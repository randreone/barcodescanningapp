//
//  BarcodeScannerView.m
//  BarcodeDemo
//
//  Created by Ike Ellis on 1/15/16.
//  Copyright © 2016 FormFast. All rights reserved.
//

#import "BarcodeScannerView.h"

@implementation BarcodeScannerView


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    
//    CGContextRef contextRef = UIGraphicsGetCurrentContext();
//    CGContextSetStrokeColorWithColor(contextRef, [UIColor redColor].CGColor);
//    CGContextMoveToPoint(contextRef, 0, 0);
//    CGContextAddLineToPoint(contextRef, 150, 0);
//    CGContextClosePath(contextRef);
//    CGContextDrawPath(contextRef, kCGPathStroke);
    
    if (_drawCorners != nil) {
        [self drawScanOutline:_drawCorners];
        
//        NSAssert(_drawCorners != nil && _drawCorners.count == 4, @"Invalid corners");
//        CGPoint points[4];
        
//        CGContextRef context = UIGraphicsGetCurrentContext();
//        CGContextSetRGBStrokeColor(context, 0.0, 1.0, 0.0, 1.0);
        
        // Drawing code
        //    for (NSInteger pointIndex = 0; pointIndex < 4; ++pointIndex) {
        //
        //        NSDictionary *pointDict = corners[pointIndex];
        //        points[pointIndex] = CGPointMake([pointDict[@"X"] floatValue], [pointDict[@"Y"] floatValue]);
        //    }
        //
        //    CGContextMoveToPoint(context, points[0].x, points[0].y);
        //    for (NSInteger pointIndex = 0; pointIndex < 3; ++pointIndex) {
        //        CGContextAddLineToPoint(context, points[pointIndex+1].x, points[pointIndex+1].y);
        //    }
        
//        CGContextRef contextRef = UIGraphicsGetCurrentContext();
//        CGContextSetStrokeColorWithColor(contextRef, [UIColor greenColor].CGColor);
//        CGContextMoveToPoint(contextRef, 0, 10);
//        CGContextAddLineToPoint(contextRef, 150, 10);
//        CGContextClosePath(contextRef);
//        CGContextDrawPath(contextRef, kCGPathStroke);
        
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
