//
//  AppDelegate.m
//  RecordFace
//
//  Created by barara on 16/1/6.
//  Copyright © 2016年 Jay. All rights reserved.
//

#import "AppDelegate.h"
#import "LoginViewController.h"
#import "RootViewController.h"

#define kUUID @"DFA3EF9F-4C31-B4CC-35DC-9295E4C942D8"//iBeacon的uuid可以换成自己设备的uuid

@interface AppDelegate ()

@end

@implementation AppDelegate

- (NSDate *)getCustomDateWithHour:(NSInteger)hour and:(NSInteger)min
{
    //获取当前时间
    NSDate *currentDate = [NSDate date];
    NSCalendar *currentCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *currentComps = [[NSDateComponents alloc] init];
    
    NSInteger unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSWeekdayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
    
    currentComps = [currentCalendar components:unitFlags fromDate:currentDate];
    
    //设置当天的某个点
    NSDateComponents *resultComps = [[NSDateComponents alloc] init];
    [resultComps setYear:[currentComps year]];
    [resultComps setMonth:[currentComps month]];
    [resultComps setDay:[currentComps day]];
    [resultComps setHour:hour];
    [resultComps setMinute:min];
    
    NSCalendar *resultCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    return [resultCalendar dateFromComponents:resultComps];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    
    [NSThread sleepForTimeInterval:2.0];   //设置进程停止2秒
    
    //开启通知
    [application registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert|UIUserNotificationTypeBadge|UIUserNotificationTypeSound categories:nil]];//注册本地推送
    
    _locationManager = [[CLLocationManager alloc] init];
    _locationManager.delegate = self;
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    if(![[NSUserDefaults standardUserDefaults] boolForKey:@"ready"]){
        NSLog(@"未注册");
        
        LoginViewController *lvc = [[LoginViewController alloc] init];
        self.window.rootViewController = lvc;
    }else{
        NSLog(@"已注册");
        
        RootViewController *rvc = [[RootViewController alloc] init];
        self.window.rootViewController = rvc;
    }
    
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    return YES;
}

- (void)locationManager:(CLLocationManager *)manager didDetermineState:(CLRegionState)state forRegion:(CLRegion *)region
{
    // A user can transition in or out of a region while the application is not running.
    // When this happens CoreLocation will launch the application momentarily, call this delegate method
    // and we will let the user know via a local notification.
    
    NSString *namePath = [NSString stringWithFormat:@"%@/Documents/Name.txt",NSHomeDirectory()];
    NSFileManager *fileManage = [NSFileManager defaultManager];
    
    if ([fileManage fileExistsAtPath:namePath]) {
        return;
    }
    
    //正常上下班时间
    NSDate *date9 = [self getCustomDateWithHour:8 and:40];
    NSDate *date17 = [self getCustomDateWithHour:17 and:30];
    
    //测试用时间
    //NSDate *date9 = [self getCustomDateWithHour:15 and:28];
    //NSDate *date17 = [self getCustomDateWithHour:15 and:29];
    
    NSDate *currentDate = [NSDate date];
    
    if ([currentDate compare:date9]==NSOrderedDescending && [currentDate compare:date17]==NSOrderedAscending)
    {
        return;
    }
    
    //开启通知
    
        UILocalNotification *notification = [[UILocalNotification alloc] init];
        // 推送声音
        //notification.soundName = UILocalNotificationDefaultSoundName;
        notification.soundName = @"recordFace.m4r";
    
        if(state == CLRegionStateInside && [currentDate compare:date9]==NSOrderedAscending)
        {
            notification.alertBody = @"上班啦，记得刷脸哦";
        }
        else if(state == CLRegionStateOutside && [currentDate compare:date17]==NSOrderedDescending)
        {
            notification.alertBody = @"下班啦，记得刷脸哦";
        }
        else if(state == CLRegionStateInside && [currentDate compare:date17]==NSOrderedDescending)
        {
            notification.alertBody = @"下班啦，记得刷脸哦";
        }
        else
        {
            return;
        }
    
    //    UIApplication *app = [UIApplication sharedApplication];
    //    [app scheduleLocalNotification:notification];
    
        // If the application is in the foreground, it will get a callback to application:didReceiveLocalNotification:.
        // If its not, iOS will display the notification to the user.
        [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
}

//发现有iBeacon进入监测范围
-(void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region{
    
    NSLog(@"有iBeacon进入监测范围了");
    
    //[self.locationmanager startRangingBeaconsInRegion:self.beacon1];//开始RegionBeacons
}

- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region {
    
    NSLog(@"离开nobeacon区域了。。。");
    
    //    if ([region isKindOfClass:[CLBeaconRegion class]]) {
    //        UILocalNotification *notification = [[UILocalNotification alloc] init];
    //        notification.alertBody = @"Are you forgetting something?";
    //        notification.soundName = @"Default";
    //        [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
    //    }
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    // If the application is in the foreground, we will notify the user of the region's state via an alert.
    
    
//    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:notification.alertBody message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
//    [alert show];
    
    
}

//禁止横屏
- (NSUInteger)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window
{
    return UIInterfaceOrientationMaskPortrait;
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

@end
