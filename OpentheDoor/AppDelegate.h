//
//  AppDelegate.h
//  RecordFace
//
//  Created by barara on 16/1/6.
//  Copyright © 2016年 Jay. All rights reserved.
//

#import <UIKit/UIKit.h>
#import<CoreLocation/CoreLocation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import <Foundation/Foundation.h>
#import <SystemConfiguration/CaptiveNetwork.h>
#import <AVFoundation/AVFoundation.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate,CLLocationManagerDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) CLBeaconRegion *beaconRegion;//被扫描的iBeacon

@property (strong, nonatomic) CLLocationManager * locationManager;

@end

