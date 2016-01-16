//
//  ViewController.m
//  BarcodeDemo
//
//  Created by Ike Ellis on 1/15/16.
//  Copyright © 2016 FormFast. All rights reserved.
//

#import "ViewController.h"
#import "BarcodeScannerView.h"
#import <MTBBarcodeScanner.h>

@interface ViewController () {
    
    MTBBarcodeScanner *_scanner;

    NSArray *_corners;
}

@property (strong, nonatomic) IBOutlet UIView *barcodeView;
@property (strong, nonatomic) IBOutlet BarcodeScannerView *barcodeOverlayView;
@property (strong, nonatomic) IBOutlet UILabel *resultLabel;
@property (strong, nonatomic) IBOutlet UIButton *startScanButton;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    _scanner = [[MTBBarcodeScanner alloc] initWithPreviewView:_barcodeView];
    
    _resultLabel.text = @"Scanning...";
    self.view.frame = [[UIScreen mainScreen] bounds];
    [self.view setNeedsLayout];
}

- (void)viewDidAppear:(BOOL)animated {
    
    [self startScanning];
}

- (void)startScanning {
    
    _barcodeOverlayView.drawCorners = nil;
    [_barcodeOverlayView setNeedsDisplay];
    
    [MTBBarcodeScanner requestCameraPermissionWithSuccess:^(BOOL success) {
        if (success) {
            _startScanButton.enabled = NO;
            [_scanner unfreezeCapture];
            _resultLabel.text = @"";
            [_scanner startScanningWithResultBlock:^(NSArray *codes) {
                AVMetadataMachineReadableCodeObject *code = [codes firstObject];
                NSLog(@"Found code: %@", code.stringValue);
                
                _resultLabel.text = code.stringValue;
                _barcodeOverlayView.drawCorners = code.corners;
                [_barcodeOverlayView setNeedsDisplay];
                
                [_scanner freezeCapture];
                _startScanButton.enabled = YES;
            }];
            
        } else {
            // The user denied access to the camera
            _startScanButton.enabled = YES;
        }
    }];
    
}




- (IBAction)startScanPressed:(UIButton *)sender {
    [self startScanning];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
