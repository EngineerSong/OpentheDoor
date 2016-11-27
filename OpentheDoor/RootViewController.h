//
//  RootViewController.h
//  OpentheDoor
//
//  Created by barara on 16/1/28.
//  Copyright © 2016年 Jay. All rights reserved.
//

#import <UIKit/UIKit.h>
#import<CoreLocation/CoreLocation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import <Foundation/Foundation.h>
#import <SystemConfiguration/CaptiveNetwork.h>
#import "AFNetworkTool.h"
#import "AFNetworking.h"
#import "MyConnection.h"
#import <AVFoundation/AVFoundation.h>

@interface RootViewController : UIViewController <CLLocationManagerDelegate,CBCentralManagerDelegate,NSURLConnectionDataDelegate>

@property (nonatomic, strong) CBCentralManager *cbCentralMgr;

@property (strong, nonatomic) CLLocationManager * locationmanager;
@property (strong, nonatomic) CLBeaconRegion *beacon1;//被扫描的iBeacon


@end
