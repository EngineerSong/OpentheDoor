//
//  LoginViewController.m
//  OpentheDoor
//
//  Created by barara on 16/1/28.
//  Copyright © 2016年 Jay. All rights reserved.
//

#import "LoginViewController.h"
#import "RootViewController.h"

#define SANGEIP @"192.168.99.167"//三哥的IP地址
#define BEACONUUID @"DFA3EF9F-4C31-B4CC-35DC-9295E4C942D8"//iBeacon的uuid可以换成自己设备的uuid
#define MacOfJay @"4400109A1289"//Jay的mac地址
#define MacOfJison @"A01828685CA5"//Jison的mac地址
#define MacOfWifiY1openWRT @"20:76:93:34:51:f4"//Wifi Y1OPENWRT的mac地址
#define MacOfWifi50718 @"20:76:93:2e:77:f4"//Wifi 50718的mac地址

@interface LoginViewController ()

{
    UITextField *_nameTF;
    UISegmentedControl *_segment;
    UITextField *_phoneTF;
    
    UITextField *_macTF1;
    UITextField *_macTF2;
    UITextField *_macTF3;
    UITextField *_macTF4;
    UITextField *_macTF5;
    UITextField *_macTF6;
    
    UITapGestureRecognizer *_tap;
    NSMutableString *_sexStr;
}

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _tap = [[UITapGestureRecognizer alloc] init];
    [_tap addTarget:self action:@selector(tapp)];
    [self.view addGestureRecognizer:_tap];
    [self setUI];
}

- (void)setUI
{
    _sexStr = [[NSMutableString alloc] initWithString:@"男"];
    
    _nameTF = [[UITextField alloc] initWithFrame:CGRectMake((self.view.frame.size.width-260)/2, 80, 260, 60)];
    _nameTF.placeholder = @"请输入姓名";
    [self.view addSubview:_nameTF];
    
    _phoneTF = [[UITextField alloc] initWithFrame:CGRectMake((self.view.frame.size.width-260)/2, 150, 260, 60)];
    _phoneTF.placeholder = @"请输入手机号码";
    [self.view addSubview:_phoneTF];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake((self.view.frame.size.width-260)/2, 220, 120, 60)];
    label.text = @"性别:";
    [self.view addSubview:label];
    
    UILabel *labelUserMac = [[UILabel alloc] initWithFrame:CGRectMake((self.view.frame.size.width-260)/2, 220+70, 60, 60)];
    labelUserMac.text = @"Mac:";
    [self.view addSubview:labelUserMac];
    
    
    for (int i = 0; i < 5; i ++) {
        UILabel *maohaoLabel = [[UILabel alloc] initWithFrame:CGRectMake((self.view.frame.size.width-260)/2+60+30+40*i, 220+70, 5, 60)];
        maohaoLabel.text = @":";
        [self.view addSubview:maohaoLabel];
    }
    
    _macTF1 = [[UITextField alloc] initWithFrame:CGRectMake((self.view.frame.size.width-260)/2+60, 220+70+10, 25, 35)];
    _macTF1.layer.borderColor = [[UIColor grayColor] CGColor];
    _macTF1.layer.borderWidth = 1.0f;
    //圆角
    _macTF1.layer.masksToBounds = YES;
    _macTF1.layer.cornerRadius = 8.0f;
    [self.view addSubview:_macTF1];
    
    UILabel *maohaoLabel1 = [[UILabel alloc] initWithFrame:CGRectMake((self.view.frame.size.width-260)/2+60+30, 220+70, 5, 60)];
    maohaoLabel1.text = @":";
    [self.view addSubview:maohaoLabel1];
    
    _macTF2 = [[UITextField alloc] initWithFrame:CGRectMake((self.view.frame.size.width-260)/2+60+40, 220+70+10, 25, 35)];
    _macTF2.layer.borderColor = [[UIColor grayColor] CGColor];
    _macTF2.layer.borderWidth = 1.0f;
    //圆角
    _macTF2.layer.masksToBounds = YES;
    _macTF2.layer.cornerRadius = 8.0f;
    [self.view addSubview:_macTF2];
    
    _macTF3 = [[UITextField alloc] initWithFrame:CGRectMake((self.view.frame.size.width-260)/2+60+40*2, 220+70+10, 25, 35)];
    _macTF3.layer.borderColor = [[UIColor grayColor] CGColor];
    _macTF3.layer.borderWidth = 1.0f;
    //圆角
    _macTF3.layer.masksToBounds = YES;
    _macTF3.layer.cornerRadius = 8.0f;
    [self.view addSubview:_macTF3];
    
    _macTF4 = [[UITextField alloc] initWithFrame:CGRectMake((self.view.frame.size.width-260)/2+60+40*3, 220+70+10, 25, 35)];
    _macTF4.layer.borderColor = [[UIColor grayColor] CGColor];
    _macTF4.layer.borderWidth = 1.0f;
    //圆角
    _macTF4.layer.masksToBounds = YES;
    _macTF4.layer.cornerRadius = 8.0f;
    [self.view addSubview:_macTF4];
    
    _macTF5 = [[UITextField alloc] initWithFrame:CGRectMake((self.view.frame.size.width-260)/2+60+40*4, 220+70+10, 25, 35)];
    _macTF5.layer.borderColor = [[UIColor grayColor] CGColor];
    _macTF5.layer.borderWidth = 1.0f;
    //圆角
    _macTF5.layer.masksToBounds = YES;
    _macTF5.layer.cornerRadius = 8.0f;
    [self.view addSubview:_macTF5];
    
    _macTF6 = [[UITextField alloc] initWithFrame:CGRectMake((self.view.frame.size.width-260)/2+60+40*5, 220+70+10, 25, 35)];
    _macTF6.layer.borderColor = [[UIColor grayColor] CGColor];
    _macTF6.layer.borderWidth = 1.0f;
    //圆角
    _macTF6.layer.masksToBounds = YES;
    _macTF6.layer.cornerRadius = 8.0f;
    [self.view addSubview:_macTF6];
    
    UILabel *tishilabel = [[UILabel alloc] initWithFrame:CGRectMake((self.view.frame.size.width-260)/2, 220+70+45+10, 280, 20)];
    tishilabel.text = @"请将“设置-通用-关于本机-无线局域网地址”中的内容输入到上方";
    tishilabel.textColor = [UIColor grayColor];
    tishilabel.font = [UIFont fontWithName:@"Arial" size:10];
    //[tishilabel setNumberOfLines:0];
    [self.view addSubview:tishilabel];
    
    
    _segment = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:@"男",@"女", nil]];
    _segment.frame = CGRectMake((self.view.frame.size.width-260)/2+140, 230, 120, 40);
    _segment.tintColor = [UIColor blueColor];
    //设置颜色
    _segment.selectedSegmentIndex = 0;
    //设置被选中的分段
    [_segment addTarget:self action:@selector(segmentClick:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:_segment];
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    btn.frame = CGRectMake((self.view.frame.size.width-100)/2, 340+70-20, 100, 100);
    [btn setTitle:@"注册" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btn setBackgroundColor:[UIColor colorWithRed:53/255.0 green:220/255.0 blue:239/255.0 alpha:1]];
    //圆角
    btn.layer.masksToBounds = YES;
    btn.layer.cornerRadius = 50;
    [btn addTarget:self action:@selector(btnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
}

- (void)btnClick
{
    NSLog(@"点击注册");
    
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
    
    if (_nameTF.text && _phoneTF.text && _macTF1.text && _macTF2.text && _macTF3.text && _macTF4.text && _macTF5.text && _macTF6.text) {
        if ([self checkPhoneNumInput:_phoneTF.text]) {
            
            NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
            [dict setValue:_nameTF.text forKey:@"name"];
            [dict setValue:_phoneTF.text forKey:@"phone"];
            [dict setValue:_sexStr forKey:@"sex"];
            [dict setValue:[NSString stringWithFormat:@"%@%@%@%@%@%@",_macTF1.text,_macTF2.text,_macTF3.text,_macTF4.text,_macTF5.text,_macTF6.text] forKey:@"mac"];
            
            NSLog(@"dict = %@",dict);
            
            //管理器
            AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
            // 设置请求格式
            //manager.requestSerializer = [AFJSONRequestSerializer serializer];
            // 设置返回格式
            manager.responseSerializer = [AFJSONResponseSerializer serializer];
            //如果报接受类型不一致请替换一致text/html或别的
            manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
            //请求
            [manager POST:[NSString stringWithFormat:@"http://%@:8080/kaoqin/api/v1/user/register.api/",SANGEIP] parameters:dict success: ^(AFHTTPRequestOperation *operation, id responseObject) {
                NSLog(@"success -> %@", responseObject);
                
                if(![[NSUserDefaults standardUserDefaults] boolForKey:@"ready"]){
                    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"ready"];
                    NSLog(@"注册成功");
                }else{
                    NSLog(@"已注册");
                }
                
                if (![[NSUserDefaults standardUserDefaults] objectForKey:@"userMac"]) {
                    NSLog(@"存储用户Mac");
                    [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%@%@%@%@%@%@",_macTF1.text,_macTF2.text,_macTF3.text,_macTF4.text,_macTF5.text,_macTF6.text] forKey:@"userMac"];
                } else {
                    NSLog(@"更新存储的用户Mac");
                    [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%@%@%@%@%@%@",_macTF1.text,_macTF2.text,_macTF3.text,_macTF4.text,_macTF5.text,_macTF6.text] forKey:@"userMac"];
                }
                
                RootViewController *rvc = [[RootViewController alloc] init];
                [self presentViewController:rvc animated:YES completion:nil];
                
            } failure: ^(AFHTTPRequestOperation *operation, NSError *error) {
                NSLog(@"error = %@", error);
            }];
        }
    }
}

- (void)segmentClick:(UISegmentedControl *)sender
{
    NSInteger index = sender.selectedSegmentIndex;
    //获取被选中的分段
    
    if (index == 0) {
        _sexStr = [[NSMutableString alloc] initWithString:@"男"];
    }else{
        _sexStr = [[NSMutableString alloc] initWithString:@"女"];
    }
    
    NSLog(@"sex = %@",_sexStr);
}

- (void)tapp
{
    [self.view endEditing:YES];
}

-(BOOL)checkPhoneNumInput:(NSString *)phoneNumStr{
    
    
    
    NSString * MOBILE = @"^1(3[0-9]|5[0-35-9]|8[025-9])\\d{8}$";
    
    
    
    NSString * CM = @"^1(34[0-8]|(3[5-9]|5[017-9]|8[278])\\d)\\d{7}$";
    
    
    
    NSString * CU = @"^1(3[0-2]|5[256]|8[56])\\d{8}$";
    
    
    
    NSString * CT = @"^1((33|53|8[09])[0-9]|349)\\d{7}$";
    
    
    
    // NSString * PHS = @"^0(10|2[0-5789]|\\d{3})\\d{7,8}$";
    
    
    
    NSPredicate *regextestmobile = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", MOBILE];
    
    NSPredicate *regextestcm = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CM];
    
    NSPredicate *regextestcu = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CU];
    
    NSPredicate *regextestct = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CT];
    
    BOOL res1 = [regextestmobile evaluateWithObject:phoneNumStr];
    
    BOOL res2 = [regextestcm evaluateWithObject:phoneNumStr];
    
    BOOL res3 = [regextestcu evaluateWithObject:phoneNumStr];
    
    BOOL res4 = [regextestct evaluateWithObject:phoneNumStr];
    
    
    
    if (res1 || res2 || res3 || res4 )
        
    {
        
        return YES;
        
    }
    
    else
        
    {
        
        return NO;
        
    }
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
