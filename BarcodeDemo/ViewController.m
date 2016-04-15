//
//  ViewController.m
//  BarcodeDemo
//
//  Created by Ike Ellis on 1/15/16.
//  Copyright © 2016 FormFast. All rights reserved.
//

#import "ViewController.h"
#import "BarcodeScannerView.h"
#import "Common.h"
#import <MTBBarcodeScanner.h>


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
@property (strong, nonatomic) IBOutlet UIImageView *logoImageView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    _scanner = [[MTBBarcodeScanner alloc] initWithPreviewView:_barcodeView];
    
    _resultLabel.text = @"Scanning...";
    self.view.frame = [[UIScreen mainScreen] bounds];
    [self.view setNeedsLayout];
    
    [self registerDefaultsFromSettingsBundle];
    
    BOOL allowEmailConfigured = [[NSUserDefaults standardUserDefaults] boolForKey:kAllowConfiguredURLKey];
    if (allowEmailConfigured) {
        _launchURL = [[NSUserDefaults standardUserDefaults] objectForKey:kConfiguredURLKey];
    }
    
    if (_launchURL == nil || _launchURL.length == 0) {
        _launchURL = [[NSUserDefaults standardUserDefaults] objectForKey:kLaunchURLKey];
        if (_launchURL == nil || _launchURL.length == 0) {
            _launchURL = kDefaultURL;
        }
    }

    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(launchURLChanged:) name:kNotificationLaunchURLChanged object:nil];
//
//    _logoImageView.userInteractionEnabled = YES;
//    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(logoTapped:)];
//    [_logoImageView addGestureRecognizer:tapGesture];
    
}

- (void)launchURLChanged:(NSNotification *)info {
    NSString *url = info.userInfo[kNotificationLaunchURLKey];

    _launchURL = url;

}


- (void)viewDidAppear:(BOOL)animated {
    
    [self startScanning];
    _activityIndicator.hidden = YES;
    _timer = nil;
}

- (void)registerDefaultsFromSettingsBundle {
    // this function writes default settings as settings
    NSString *settingsBundle = [[NSBundle mainBundle] pathForResource:@"Settings" ofType:@"bundle"];
    if(!settingsBundle) {
        NSLog(@"Could not find Settings.bundle");
        return;
    }
    
    NSDictionary *settings = [NSDictionary dictionaryWithContentsOfFile:[settingsBundle stringByAppendingPathComponent:@"Root.plist"]];
    NSArray *preferences = [settings objectForKey:@"PreferenceSpecifiers"];
    
    NSMutableDictionary *defaultsToRegister = [[NSMutableDictionary alloc] initWithCapacity:[preferences count]];
    for(NSDictionary *prefSpecification in preferences) {
        NSString *key = [prefSpecification objectForKey:@"Key"];
        if(key) {
            [defaultsToRegister setObject:[prefSpecification objectForKey:@"DefaultValue"] forKey:key];
            NSLog(@"writing as default %@ to the key %@",[prefSpecification objectForKey:@"DefaultValue"],key);
        }
    }
    
    [[NSUserDefaults standardUserDefaults] registerDefaults:defaultsToRegister];
    
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
        [_scanner updateCaptureLayerFrame:_barcodeView.bounds];
    } completion:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
        [_scanner refreshVideoOrientation:[UIApplication sharedApplication].statusBarOrientation];
    }];
}

- (void)startScanning {
    
    _barcodeOverlayView.drawCorners = nil;
    [_barcodeOverlayView setNeedsDisplay];
    _activityIndicator.hidden = YES;
    
    [MTBBarcodeScanner requestCameraPermissionWithSuccess:^(BOOL success) {
        if (success) {
            _startScanButton.hidden = YES;
            [_scanner unfreezeCapture];
            _resultLabel.text = @"";
            [_scanner startScanningWithResultBlock:^(NSArray *codes) {
                AVMetadataMachineReadableCodeObject *code = [codes firstObject];
                NSLog(@"Found code: %@", code.stringValue);

                NSString *recordID = code.stringValue;
                _resultLabel.text = recordID;
                

                _barcodeOverlayView.drawCorners = code.corners;
                [_barcodeOverlayView setNeedsDisplay];
                
                [_scanner freezeCapture];
                
                _activityIndicator.hidden = NO;
                [_activityIndicator startAnimating];
                

                _timer = [NSTimer scheduledTimerWithTimeInterval:kScanDelay target:self selector:@selector(timerComplete:) userInfo:recordID repeats:NO];

                
            }];
            
        } else {
            // The user denied access to the camera
            _startScanButton.hidden = NO;
        }
    }];
    
}

- (void)timerComplete:(NSTimer *)timer {
    
    _timer = nil;
    _startScanButton.hidden = NO;
    [_activityIndicator stopAnimating];
    _activityIndicator.hidden = YES;
    
    NSString *urlString = [NSString stringWithFormat:_launchURL, timer.userInfo];
    NSURL *url = [NSURL URLWithString:urlString];
    if (url) {
        [[UIApplication sharedApplication] openURL:url];
    }
}
                                          
- (void)logoTapped:(UIGestureRecognizer *)gesture {
  
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Change the target URL"
                                                                   message:@"This is an alert."
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* defaultAction =
    [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                       handler:^(UIAlertAction * action) {
                                       
                                           _launchURL = alert.textFields[0].text;
                                           [[NSUserDefaults standardUserDefaults] setObject:_launchURL forKey:kLaunchURLKey];
                                                          
                                       }];
    [alert addAction:defaultAction];
    
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.text = _launchURL;
    }];
    [self presentViewController:alert animated:YES completion:nil];
}


- (IBAction)startScanPressed:(UIButton *)sender {
    [self startScanning];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
