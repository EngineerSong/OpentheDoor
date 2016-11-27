//
//  MyRequest.m
//  LimitDemo
//
//  Created by pk on 15/3/24.
//  Copyright (c) 2015年 pk. All rights reserved.
//

#import "MyRequest.h"

@interface MyRequest ()<NSURLConnectionDataDelegate>{
    NSMutableData* _mData;
}

@end

@implementation MyRequest

- (void)startRequest{
    _mData = [[NSMutableData alloc] init];
    //请求
    NSURLRequest* request = [NSURLRequest requestWithURL:[NSURL URLWithString:self.url]];
    
    if (_value.length) {
        //创建一个 NSMutableURLRequest 添加 header
        NSMutableURLRequest *mutableRequest = [request mutableCopy];
        NSString *value = [NSString stringWithFormat:@"%@",_value];
        [mutableRequest addValue:value forHTTPHeaderField:@"apikey"];
        //把值覆给request
        request = [mutableRequest copy];
    }
    
    [NSURLConnection connectionWithRequest:request delegate:self];
}
//接收响应 
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}
//接收响应体
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
    [_mData appendData:data];
}
//请求完成
- (void)connectionDidFinishLoading:(NSURLConnection *)connection{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    //回调数据
    if (self.finishBlock) {
        self.finishBlock(_mData);
    }
}
//请求失败
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    if (self.failedBlock) {
        self.failedBlock();
    }
}




@end
