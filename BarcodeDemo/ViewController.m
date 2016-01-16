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

#define kDefaultURL @"https://www.amazon.com"
#define kScanDelay 1.5

@interface ViewController () {
    
    MTBBarcodeScanner *_scanner;

    NSArray *_corners;
    
    NSString *_launchURL;
    NSTimer *_timer;
    
}

@property (strong, nonatomic) IBOutlet UIView *barcodeView;
@property (strong, nonatomic) IBOutlet BarcodeScannerOverlayView *barcodeOverlayView;
@property (strong, nonatomic) IBOutlet UILabel *resultLabel;
@property (strong, nonatomic) IBOutlet UIButton *startScanButton;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    _scanner = [[MTBBarcodeScanner alloc] initWithPreviewView:_barcodeView];
    
    _resultLabel.text = @"Scanning...";
    self.view.frame = [[UIScreen mainScreen] bounds];
    [self.view setNeedsLayout];
    
    _launchURL = kDefaultURL;
    
}

- (void)viewDidAppear:(BOOL)animated {
    
    [self startScanning];
    _activityIndicator.hidden = YES;
    _timer = nil;
}

- (void)startScanning {
    
    _barcodeOverlayView.drawCorners = nil;
    [_barcodeOverlayView setNeedsDisplay];
    _activityIndicator.hidden = YES;
    
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
                
                _activityIndicator.hidden = NO;
                [_activityIndicator startAnimating];
                
                _timer = [NSTimer scheduledTimerWithTimeInterval:kScanDelay target:self selector:@selector(timerComplete:) userInfo:code.stringValue repeats:NO];
                
            }];
            
        } else {
            // The user denied access to the camera
            _startScanButton.enabled = YES;
        }
    }];
    
}

- (void)timerComplete:(NSString *)code {
    
    _timer = nil;
    _startScanButton.enabled = YES;
    [_activityIndicator stopAnimating];
    _activityIndicator.hidden = YES;
    
    NSURL *url = [NSURL URLWithString:_launchURL];
    if (url) {
        //TODO: process URL with code
        [[UIApplication sharedApplication] openURL:url];
    }
}


- (IBAction)startScanPressed:(UIButton *)sender {
    [self startScanning];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
