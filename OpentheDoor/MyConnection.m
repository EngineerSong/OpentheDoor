//
//  MyConnection.m
//  LimitDemo
//
//  Created by pk on 15/3/24.
//  Copyright (c) 2015年 pk. All rights reserved.
//

#import "MyConnection.h"

@implementation MyConnection

- (void)aa{
    //http://www.baidu.com
    [MyConnection connectionWithUrl:@"http://www.baidu.com" WithValue:@"??" FinishBlock:^(NSData *data) {
        //data 就是请求的数据
    } FailedBlock:^{
        NSLog(@"请求失败");
    }];
}

+ (void)connectionWithUrl:(NSString *)url WithValue:(NSString *)value FinishBlock:(FinishBlock)finishBlock FailedBlock:(FailedBlock)failedBlock{
    MyRequest* request = [[MyRequest alloc] init];
    request.url = url;
    if (value.length) {
        request.value = value;
    }
    request.finishBlock = finishBlock;
    request.failedBlock = failedBlock;
    [request startRequest];
}

@end
