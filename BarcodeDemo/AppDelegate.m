//
//  AppDelegate.m
//  BarcodeDemo
//
//  Created by Ike Ellis on 1/15/16.
//  Copyright © 2016 FormFast. All rights reserved.
//

#import "AppDelegate.h"
#import "Common.h"
#import <SVProgressHUD.h>
#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>



@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.

    [Fabric with:@[[Crashlytics class]]];

    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<NSString *,id> *)options {    // handler code here
    
    NSString *newURL = [[url absoluteString] stringByReplacingOccurrencesOfString:@"formfast://" withString:@"https://"];
    
    if (newURL != nil) {
        [[NSUserDefaults standardUserDefaults] setObject:newURL forKey:kConfiguredURLKey];
        
        BOOL allowEmailConfig = [[NSUserDefaults standardUserDefaults] boolForKey:kAllowConfiguredURLKey];
        
        if (allowEmailConfig) {
            [SVProgressHUD showSuccessWithStatus:[NSString stringWithFormat:@"Configured Launch URL: %@", newURL]];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationLaunchURLChanged object:nil userInfo:@{kNotificationLaunchURLKey: newURL}];
            
        } else {
            [SVProgressHUD showErrorWithStatus:@"Set new launch URL, but configured launch URLs are disabled in app settings"];             
        }
    }
    
    return YES;
}

@end
