//
//  RootViewController.m
//  OpentheDoor
//
//  Created by barara on 16/1/28.
//  Copyright © 2016年 Jay. All rights reserved.
//

#import "RootViewController.h"

#define SANGEIP @"192.168.99.167"//三哥的IP地址
#define BEACONUUID @"DFA3EF9F-4C31-B4CC-35DC-9295E4C942D8"//iBeacon的uuid可以换成自己设备的uuid
#define MacOfJay @"4400109A1289"//Jay的mac地址
#define MacOfJison @"A01828685CA5"//Jison的mac地址
#define MacOfWifiY1openWRT @"20:76:93:34:51:f4"//Wifi Y1OPENWRT的mac地址
#define MacOfWifi50718 @"20:76:93:2e:77:f4"//Wifi 50718的mac地址

@interface RootViewController () <AVAudioPlayerDelegate>

{
    UIImageView *_imageWifi;
    UIImageView *_imageView;
    UILabel *_timeLabel;
    UILabel *_dateLabel;
    UIButton *_openBtn;
    NSString *_userIDStr;
    int _stateNum;
    
    AVAudioPlayer *_player;
    NSTimer *_timer;
    
    UIImageView *_insideImage;
    UIImageView *_outsideImage;
    
    NSString *_userMacStr;
}

@end

@implementation RootViewController

- (void)viewWillAppear:(BOOL)animated
{
    
    if (!_imageWifi) {
        return;
    }
    
    NSString *ssid = @"Not Found";
    NSString *macIp = @"Not Found";
    CFArrayRef myArray = CNCopySupportedInterfaces();
    if (myArray != nil) {
        CFDictionaryRef myDict = CNCopyCurrentNetworkInfo(CFArrayGetValueAtIndex(myArray, 0));
        if (myDict != nil) {
            NSDictionary *dict = (NSDictionary*)CFBridgingRelease(myDict);
            
            ssid = [dict valueForKey:@"SSID"];
            macIp = [dict valueForKey:@"BSSID"];
            NSLog(@"BSSID = %@",macIp);
            
            if (![macIp isEqualToString:MacOfWifi50718]) {
                [_imageWifi setImage:[UIImage imageNamed:@"wuxianweilianjiezhuangtai.png"]];
            }else{
                [_imageWifi setImage:[UIImage imageNamed:@"wuxianlianjiezhuangtai.png"]];
            }
        }else{
            [_imageWifi setImage:[UIImage imageNamed:@"wuxianweilianjiezhuangtai.png"]];        }
    }else{
        [_imageWifi setImage:[UIImage imageNamed:@"wuxianweilianjiezhuangtai.png"]];
    }
}

//发送当前出入时间，如果发送失败就存入NSUserDefaults，numStr外出是0，进入是1
- (void)uploadOrSaveDataWithStatus:(NSString *)numStr
{
    if (!_userIDStr) {
        [self login];
    }
    
    //获取当前时间
    NSDate *  senddate=[NSDate date];
    NSDateFormatter  *dateformatter=[[NSDateFormatter alloc] init];
    [dateformatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
    NSString *  locationString=[dateformatter stringFromDate:senddate];
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setValue:_userIDStr forKey:@"employeeId"];
    [dict setValue:locationString forKey:@"outTime"];
    [dict setValue:numStr forKey:@"status"];
    
    //管理器
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    // 设置请求格式
    //manager.requestSerializer = [AFJSONRequestSerializer serializer];
    // 设置返回格式
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    //如果报接受类型不一致请替换一致text/html或别的
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    
    //请求
    [manager POST:[NSString stringWithFormat:@"http://%@:8080/kaoqin/api/v1/user/saveinoutlog.api/",SANGEIP] parameters:dict success: ^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"saveRequest success -> %@", responseObject);
    } failure: ^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"saveRequest error = %@", error);
        NSString *str = [NSString stringWithFormat:@"%@&%@",locationString,numStr];
        [self updateData:str];
    }];
}

//存入NSUserDefaults的时间+出入状态的数据
//格式为 2016-01-30 14:40:41&1
//&后面的0表示出门，1表示进门
- (void)updateData:(NSString *)dataStr
{
    if(![[NSUserDefaults standardUserDefaults] objectForKey:@"inOutData"]){
        
        NSArray *arr = [[NSArray alloc] initWithObjects:dataStr, nil];
        
        [[NSUserDefaults standardUserDefaults] setObject:arr forKey:@"inOutData"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }else{
        NSArray *arr = [[NSUserDefaults standardUserDefaults] objectForKey:@"inOutData"];
        if (arr.count < 3) {
            NSMutableArray *muArr = [[NSMutableArray alloc] initWithArray:arr];
            [muArr addObject:dataStr];
            NSArray *dataArr = [[NSArray alloc] initWithArray:muArr];
            
            [[NSUserDefaults standardUserDefaults] setObject:dataArr forKey:@"inOutData"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }else{
            NSMutableArray *muArr = [[NSMutableArray alloc] initWithArray:arr];
            [muArr removeObjectAtIndex:0];
            [muArr addObject:dataStr];
            NSArray *dataArr = [[NSArray alloc] initWithArray:muArr];
            
            [[NSUserDefaults standardUserDefaults] setObject:dataArr forKey:@"inOutData"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
    }
}

//找到iBeacon后扫描它的信息
- (void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region{
    
    NSLog(@"扫描iBeacon的信息");
    
    //NSString *path = [NSString stringWithFormat:@"%@/Documents/a.pcm",NSHomeDirectory()];
//            NSString *path = [[NSBundle mainBundle] pathForResource:@"Beat It" ofType:@"mp3"];
//            NSURL *url = [NSURL fileURLWithPath:path];
//            //NSLog(@"%@",path);
//    
//            //播放声音
//            _player = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
//            _player.delegate = self;
//            _player.volume = 1.0;
//            [_player prepareToPlay];
//            [_player play];
    
    
    //打印所有iBeacon的信息
    
    for (CLBeacon* beacon in beacons) {
        
        NSLog(@"rssi is :%ld",beacon.rssi);
        
        NSLog(@"beacon.proximity %ld",beacon.proximity);
        
        NSLog(@"beacon.uuid: %@",beacon.proximityUUID);
        
        NSLog(@"beacon.accuracy: %f",beacon.accuracy);
        
        //int a = [beacon.major intValue];
        //NSString *aStr = [NSString stringWithFormat:@"%04x",a];
        
        //NSLog(@"16进制的minor 为 %@",aStr);
        
        int a = [beacon.minor intValue];
        
        if (beacon.proximity == CLProximityImmediate) {
            _stateNum = a;
            if (_stateNum == 3) {
                if(![[NSUserDefaults standardUserDefaults] boolForKey:@"isInside"]){
                    NSLog(@"在外面");
                    
//                    NSString *path = [[NSBundle mainBundle] pathForResource:@"scan" ofType:@"m4r"];
//                    NSURL *url = [NSURL fileURLWithPath:path];
//                    //NSLog(@"%@",path);
//                    
//                    //播放声音
//                    _player = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
//                    _player.delegate = self;
//                    _player.volume = 1.0;
//                    [_player prepareToPlay];
//                    [_player play];

                    
                }else{
                    NSLog(@"外出");
                    
                    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"isInside"];
                    
                    NSString *path = [[NSBundle mainBundle] pathForResource:@"gongsonghuangshang" ofType:@"m4r"];
                    NSURL *url = [NSURL fileURLWithPath:path];
                    //NSLog(@"%@",path);
                    
                    //播放声音
                    _player = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
                    _player.delegate = self;
                    _player.volume = 1.0;
                    [_player prepareToPlay];
                    [_player play];
                    
                    [self uploadOrSaveDataWithStatus:[NSString stringWithFormat:@"0"]];
                    
                    _outsideImage = [[UIImageView alloc] initWithFrame:CGRectMake((self.view.frame.size.width-240)/2, 560-40-40-10+130+20, 240, 20)];
                    [_outsideImage setImage:[UIImage imageNamed:@"OUTSIDE.png"]];
                    [self.view addSubview:_outsideImage];
                    
                    [UIView animateWithDuration:0.5 animations:^{
                        _outsideImage.alpha = 0;
                    } completion:^(BOOL finished) {
                        
                        [UIView animateWithDuration:0.5 animations:^{
                            _outsideImage.alpha = 1;
                        } completion:^(BOOL finished) {
                            
                            [UIView animateWithDuration:0.5 animations:^{
                                _outsideImage.alpha = 0;
                            } completion:^(BOOL finished) {
                                
                                [UIView animateWithDuration:0.5 animations:^{
                                    _outsideImage.alpha = 1;
                                } completion:^(BOOL finished) {
                                    
                                    [UIView animateWithDuration:0.5 animations:^{
                                        _outsideImage.alpha = 0;
                                    } completion:^(BOOL finished) {
                                        [_outsideImage removeFromSuperview];
                                    }];
                                    
                                }];
                                
                            }];
                            
                        }];
                        
                    }];
                    
                }
            }
            if (_stateNum == 2) {
                if(![[NSUserDefaults standardUserDefaults] boolForKey:@"isInside"]){
                    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"isInside"];
                    NSLog(@"进入");
                    
                    NSString *path = [[NSBundle mainBundle] pathForResource:@"huangshangjixiang" ofType:@"m4r"];
                    NSURL *url = [NSURL fileURLWithPath:path];
                    //NSLog(@"%@",path);
                    
                    //播放声音
                    _player = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
                    _player.delegate = self;
                    _player.volume = 1.0;
                    [_player prepareToPlay];
                    [_player play];
                    
                    [self uploadOrSaveDataWithStatus:[NSString stringWithFormat:@"1"]];
                    
                    _insideImage = [[UIImageView alloc] initWithFrame:CGRectMake((self.view.frame.size.width-240)/2, 560-40-40-10+130+20, 240, 20)];
                    [_insideImage setImage:[UIImage imageNamed:@"INSIDE.png"]];
                    [self.view addSubview:_insideImage];
                    
                    [UIView animateWithDuration:0.5 animations:^{
                        _insideImage.alpha = 0;
                    } completion:^(BOOL finished) {
                        
                        [UIView animateWithDuration:0.5 animations:^{
                            _insideImage.alpha = 1;
                        } completion:^(BOOL finished) {
                            
                            [UIView animateWithDuration:0.5 animations:^{
                                _insideImage.alpha = 0;
                            } completion:^(BOOL finished) {
                                
                                [UIView animateWithDuration:0.5 animations:^{
                                    _insideImage.alpha = 1;
                                } completion:^(BOOL finished) {
                                    
                                    [UIView animateWithDuration:0.5 animations:^{
                                        _insideImage.alpha = 0;
                                    } completion:^(BOOL finished) {
                                        [_insideImage removeFromSuperview];
                                    }];
                                    
                                }];
                                
                            }];
                            
                        }];
                        
                    }];

                }else{
                    NSLog(@"早已进入");
                    
                }
            }
        }
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self setUI];
    
    _userMacStr = [[NSUserDefaults standardUserDefaults] stringForKey:@"userMac"];
    
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    if (kCLAuthorizationStatusDenied == status || kCLAuthorizationStatusRestricted == status) {
        //CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"请在“设置-食全酒美-位置”中开启位置服务"];
        //[self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"您好" message:@"请在“设置-OpentheDoor-位置”中开启位置服务" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [av show];
    }
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"inOutData"]) {
        NSLog(@"Data from NSUserDefaults = %@",[[NSUserDefaults standardUserDefaults] objectForKey:@"inOutData"]);
    }
    
    //创建一个中央
    self.cbCentralMgr = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
    self.cbCentralMgr.delegate = self;
    
    self.locationmanager = [[CLLocationManager alloc] init];//初始化
    
    self.locationmanager.delegate = self;
    self.locationmanager.activityType = CLActivityTypeFitness;
    self.locationmanager.distanceFilter = kCLDistanceFilterNone;
    self.locationmanager.desiredAccuracy = kCLLocationAccuracyBest;
    self.locationmanager.pausesLocationUpdatesAutomatically = NO;
    
    [self.locationmanager requestAlwaysAuthorization];//设置location是一直允许，即永久获取位置权限
    
    self.beacon1 = [[CLBeaconRegion alloc] initWithProximityUUID:[[NSUUID alloc] initWithUUIDString:BEACONUUID] identifier:@"jinx"];//初始化监测的iBeacon信息
    self.beacon1.notifyEntryStateOnDisplay = NO;//在屏幕点亮的时候（锁屏状态下按下 home 键，或者因为收到推送点亮等）进行一次扫描
    
    [self.locationmanager startMonitoringForRegion:self.beacon1];//开始
    [self.locationmanager startRangingBeaconsInRegion:self.beacon1];
    [self.locationmanager requestStateForRegion:self.beacon1];
    
    [self login];
    
    _timer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(timerFunc) userInfo:nil repeats:YES];
}

//每一秒都被调用一次
- (void)timerFunc
{
    if (_timeLabel && _dateLabel) {
        //获取当前时间
        NSDate *  senddate=[NSDate date];
        NSDateFormatter  *dateformatter=[[NSDateFormatter alloc] init];
        [dateformatter setDateFormat:@"HH:mm"];
        NSString *locationString=[dateformatter stringFromDate:senddate];
        
        _timeLabel.text = locationString;
        
        NSDateFormatter *dateformatter2=[[NSDateFormatter alloc] init];
        [dateformatter2 setDateFormat:@"MM月dd日 cccc"];
        NSString *locationString2=[dateformatter2 stringFromDate:senddate];
        
        _dateLabel.text = locationString2;
    }
}

- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    //    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    //    if (central.state != CBCentralManagerStatePoweredOn) {
    //        //NSLog(@"蓝牙未打开");
    //        if (kCLAuthorizationStatusDenied == status || kCLAuthorizationStatusRestricted == status) {
    //            //NSLog(@"请打开您的位置服务!");
    //
    //            NSLog(@"请打开蓝牙并在“设置-食全酒美-位置”中开启位置服务");
    //
    //        }else{
    //            NSLog(@"请打开蓝牙");
    //        }
    //    }else{
    //        //NSLog(@"蓝牙已打开");
    //        if (kCLAuthorizationStatusDenied == status || kCLAuthorizationStatusRestricted == status) {
    //
    //            NSLog(@"请在“设置-食全酒美-位置”中开启位置服务");
    //        }
    //    }
}

- (void)login
{
    NSString *ssid = @"Not Found";
    NSString *macIp = @"Not Found";
    CFArrayRef myArray = CNCopySupportedInterfaces();
    if (myArray != nil) {
        CFDictionaryRef myDict = CNCopyCurrentNetworkInfo(CFArrayGetValueAtIndex(myArray, 0));
        if (myDict != nil) {
            NSDictionary *dict = (NSDictionary*)CFBridgingRelease(myDict);
            
            ssid = [dict valueForKey:@"SSID"];
            macIp = [dict valueForKey:@"BSSID"];
            NSLog(@"BSSID = %@",macIp);
            
            if (![macIp isEqualToString:MacOfWifi50718]) {
                UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"Wifi" message:@"请到设置中连接我们的Wifi" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
                [alert show];
                return;
            }
        }else{
            UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"Wifi" message:@"请到设置中连接我们的Wifi" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
            [alert show];
            return;
        }
    }else{
        UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"Wifi" message:@"请到设置中连接我们的Wifi" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    [MyConnection connectionWithUrl:[NSString stringWithFormat:@"http://%@:8080/kaoqin/api/v1/user/getemp.api/%@",SANGEIP,_userMacStr] WithValue:nil FinishBlock:^(NSData *data) {
        NSLog(@"登陆成功");
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        NSLog(@"dic = %@",dic);
        
        _userIDStr = dic[@"id"];
        
        UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"登陆" message:@"登陆成功" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alert show];
        
    } FailedBlock:^{
        NSLog(@"登陆失败");
        
        UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"登陆" message:@"登陆失败" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alert show];
    }];
}

- (void)setUI
{
    _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 260-40)];
    [_imageView setImage:[UIImage imageNamed:@"beijing.png"]];
    [self.view addSubview:_imageView];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake((self.view.frame.size.width-140)/2, 30, 140, 20)];
    label.text = @"掌控通行证";
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor whiteColor];
    label.font = [UIFont fontWithName:@"Arial" size:20];
    [self.view addSubview:label];
    
    //获取当前时间
    NSDate *  senddate=[NSDate date];
    NSDateFormatter  *dateformatter=[[NSDateFormatter alloc] init];
    [dateformatter setDateFormat:@"HH:mm"];
    NSString *locationString=[dateformatter stringFromDate:senddate];
    
    _timeLabel = [[UILabel alloc] initWithFrame:CGRectMake((self.view.frame.size.width-300)/2, 105-40+10, 300, 70)];
    _timeLabel.text = locationString;
    _timeLabel.textAlignment = NSTextAlignmentCenter;
    _timeLabel.textColor = [UIColor whiteColor];
    _timeLabel.font = [UIFont fontWithName:@"Arial" size:90];
    [self.view addSubview:_timeLabel];
    
    NSDateFormatter *dateformatter2=[[NSDateFormatter alloc] init];
    [dateformatter2 setDateFormat:@"MM月dd日 cccc"];
    NSString *locationString2=[dateformatter2 stringFromDate:senddate];
    
    _dateLabel = [[UILabel alloc] initWithFrame:CGRectMake((self.view.frame.size.width-270)/2, 200-40+10, 270, 20)];
    _dateLabel.text = locationString2;
    _dateLabel.textAlignment = NSTextAlignmentCenter;
    _dateLabel.textColor = [UIColor whiteColor];
    [self.view addSubview:_dateLabel];
    
    _imageWifi = [[UIImageView alloc] initWithFrame:CGRectMake(20, 30, 22, 17)];
    NSString *ssid = @"Not Found";
    NSString *macIp = @"Not Found";
    CFArrayRef myArray = CNCopySupportedInterfaces();
    if (myArray != nil) {
        CFDictionaryRef myDict = CNCopyCurrentNetworkInfo(CFArrayGetValueAtIndex(myArray, 0));
        if (myDict != nil) {
            NSDictionary *dict = (NSDictionary*)CFBridgingRelease(myDict);
            
            ssid = [dict valueForKey:@"SSID"];
            macIp = [dict valueForKey:@"BSSID"];
            NSLog(@"BSSID = %@",macIp);
            
            if (![macIp isEqualToString:MacOfWifi50718]) {
                [_imageWifi setImage:[UIImage imageNamed:@"wuxianweilianjiezhuangtai.png"]];
            }else{
                [_imageWifi setImage:[UIImage imageNamed:@"wuxianlianjiezhuangtai.png"]];
            }
        }else{
            [_imageWifi setImage:[UIImage imageNamed:@"wuxianweilianjiezhuangtai.png"]];        }
    }else{
        [_imageWifi setImage:[UIImage imageNamed:@"wuxianweilianjiezhuangtai.png"]];
    }
    [self.view addSubview:_imageWifi];
    
    UIImageView *iv1 = [[UIImageView alloc] initWithFrame:CGRectMake(0, 300-40-40, self.view.frame.size.width, 240)];
    [iv1 setImage:[UIImage imageNamed:@"Group.png"]];
    [self.view addSubview:iv1];
    
    _openBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _openBtn.frame = CGRectMake((self.view.frame.size.width-130)/2, 560-40-40-10, 130, 130);
    //[btn setTitle:@"开门" forState:UIControlStateNormal];
    //[btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    //[btn setBackgroundColor:[UIColor colorWithRed:53/255.0 green:220/255.0 blue:239/255.0 alpha:1]];
    [_openBtn setImage:[UIImage imageNamed:@"guanmen.png"] forState:UIControlStateNormal];
    [_openBtn setImage:[UIImage imageNamed:@"kaimen.png"] forState:UIControlStateHighlighted];
    //圆角
    _openBtn.layer.masksToBounds = YES;
    _openBtn.layer.cornerRadius = 130/2;
    [_openBtn addTarget:self action:@selector(btnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_openBtn];
    
    UIButton *topBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    topBtn.frame = CGRectMake(self.view.frame.size.width-85, 340-40-40, 70, 40);
    [topBtn setTitle:@"打卡" forState:UIControlStateNormal];
    [topBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [topBtn setBackgroundColor:[UIColor colorWithRed:53/255.0 green:220/255.0 blue:239/255.0 alpha:1]];
    //圆角
    topBtn.layer.masksToBounds = YES;
    topBtn.layer.cornerRadius = 10;
    [topBtn addTarget:self action:@selector(topBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:topBtn];
    
    UIButton *downBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    downBtn.frame = CGRectMake(self.view.frame.size.width-85, 340+120-40-40, 70, 40);
    [downBtn setTitle:@"打卡" forState:UIControlStateNormal];
    [downBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [downBtn setBackgroundColor:[UIColor colorWithRed:53/255.0 green:220/255.0 blue:239/255.0 alpha:1]];
    //圆角
    downBtn.layer.masksToBounds = YES;
    downBtn.layer.cornerRadius = 10;
    [downBtn addTarget:self action:@selector(downBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:downBtn];
}

- (void)topBtnClick
{
    NSString *ssid = @"Not Found";
    NSString *macIp = @"Not Found";
    CFArrayRef myArray = CNCopySupportedInterfaces();
    if (myArray != nil) {
        CFDictionaryRef myDict = CNCopyCurrentNetworkInfo(CFArrayGetValueAtIndex(myArray, 0));
        if (myDict != nil) {
            NSDictionary *dict = (NSDictionary*)CFBridgingRelease(myDict);
            
            ssid = [dict valueForKey:@"SSID"];
            macIp = [dict valueForKey:@"BSSID"];
            NSLog(@"BSSID = %@",macIp);
            
            if (![macIp isEqualToString:MacOfWifi50718]) {
                UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"Wifi" message:@"请到设置中连接我们的Wifi" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
                [alert show];
                return;
            }
        }else{
            UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"Wifi" message:@"请到设置中连接我们的Wifi" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
            [alert show];
            return;
        }
    }else{
        UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"Wifi" message:@"请到设置中连接我们的Wifi" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    if (!_userIDStr) {
        [self login];
    }
    
    [MyConnection connectionWithUrl:[NSString stringWithFormat:@"http://%@:8080/kaoqin/api/v1/user/clock.api/%@/%@",SANGEIP,_userIDStr,_userMacStr] WithValue:nil FinishBlock:^(NSData *data) {
        NSLog(@"考勤成功");
//        UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"考勤" message:@"打卡成功" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
//        [alert show];
        NSString *path = [[NSBundle mainBundle] pathForResource:@"dakachenggong" ofType:@"m4r"];
        NSURL *url = [NSURL fileURLWithPath:path];
        //NSLog(@"%@",path);
        
        //播放声音
        _player = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
        _player.delegate = self;
        _player.volume = 1.0;
        [_player prepareToPlay];
        [_player play];

    } FailedBlock:^{
        NSLog(@"考勤失败");
//        UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"考勤" message:@"打卡失败" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
//        [alert show];
        NSString *path = [[NSBundle mainBundle] pathForResource:@"dakachenggong" ofType:@"m4r"];
        NSURL *url = [NSURL fileURLWithPath:path];
        //NSLog(@"%@",path);
        
        //播放声音
        _player = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
        _player.delegate = self;
        _player.volume = 1.0;
        [_player prepareToPlay];
        [_player play];

    }];
}

- (void)downBtnClick
{
    NSString *ssid = @"Not Found";
    NSString *macIp = @"Not Found";
    CFArrayRef myArray = CNCopySupportedInterfaces();
    if (myArray != nil) {
        CFDictionaryRef myDict = CNCopyCurrentNetworkInfo(CFArrayGetValueAtIndex(myArray, 0));
        if (myDict != nil) {
            NSDictionary *dict = (NSDictionary*)CFBridgingRelease(myDict);
            
            ssid = [dict valueForKey:@"SSID"];
            macIp = [dict valueForKey:@"BSSID"];
            NSLog(@"BSSID = %@",macIp);
            
            if (![macIp isEqualToString:MacOfWifi50718]) {
                UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"Wifi" message:@"请到设置中连接我们的Wifi" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
                [alert show];
                return;
            }
        }else{
            UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"Wifi" message:@"请到设置中连接我们的Wifi" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
            [alert show];
            return;
        }
    }else{
        UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"Wifi" message:@"请到设置中连接我们的Wifi" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    if (!_userIDStr) {
        [self login];
    }
    
    [MyConnection connectionWithUrl:[NSString stringWithFormat:@"http://%@:8080/kaoqin/api/v1/user/clock.api/%@/%@",SANGEIP,_userIDStr,_userMacStr] WithValue:nil FinishBlock:^(NSData *data) {
        NSLog(@"考勤成功");
//        UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"考勤" message:@"打卡成功" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
//        [alert show];
        NSString *path = [[NSBundle mainBundle] pathForResource:@"dakachenggong" ofType:@"m4r"];
        NSURL *url = [NSURL fileURLWithPath:path];
        //NSLog(@"%@",path);
        
        //播放声音
        _player = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
        _player.delegate = self;
        _player.volume = 1.0;
        [_player prepareToPlay];
        [_player play];
    } FailedBlock:^{
        NSLog(@"考勤失败");
//        UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"考勤" message:@"打卡失败" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
//        [alert show];
        NSString *path = [[NSBundle mainBundle] pathForResource:@"dakachenggong" ofType:@"m4r"];
        NSURL *url = [NSURL fileURLWithPath:path];
        //NSLog(@"%@",path);
        
        //播放声音
        _player = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
        _player.delegate = self;
        _player.volume = 1.0;
        [_player prepareToPlay];
        [_player play];
    }];
}

- (void)btnClick
{
    _openBtn.highlighted = YES;
    
    NSString *ssid = @"Not Found";
    NSString *macIp = @"Not Found";
    CFArrayRef myArray = CNCopySupportedInterfaces();
    if (myArray != nil) {
        CFDictionaryRef myDict = CNCopyCurrentNetworkInfo(CFArrayGetValueAtIndex(myArray, 0));
        if (myDict != nil) {
            NSDictionary *dict = (NSDictionary*)CFBridgingRelease(myDict);
            
            ssid = [dict valueForKey:@"SSID"];
            macIp = [dict valueForKey:@"BSSID"];
            NSLog(@"BSSID = %@",macIp);
            
            if (![macIp isEqualToString:MacOfWifi50718]) {
                UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"Wifi" message:@"请到设置中连接我们的Wifi" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
                [alert show];
                return;
            }
        }else{
            UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"Wifi" message:@"请到设置中连接我们的Wifi" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
            [alert show];
            return;
        }
    }else{
        UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"Wifi" message:@"请到设置中连接我们的Wifi" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    if (!_userIDStr) {
        [self login];
    }
    
    [MyConnection connectionWithUrl:[NSString stringWithFormat:@"http://%@:8080/kaoqin/api/v1/user/opendor.api/%@",SANGEIP,_userIDStr] WithValue:nil FinishBlock:^(NSData *data) {
        NSLog(@"开门成功");
//        UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"开门" message:@"开门成功" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
//        [alert show];
    } FailedBlock:^{
        NSLog(@"开门失败");
//        UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"开门" message:@"开门失败" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
//        [alert show];
    }];
    
    sleep(2.5);
    _openBtn.highlighted = NO;
}

//- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
//    if ([alertView tag] == 0) {    // it's the Error alert
//        if (buttonIndex == 0) {     // and they clicked OK.
//            // do stuff
//        }
//    }
//}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
