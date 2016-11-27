//
//  MyRequest.h
//  LimitDemo
//
//  Created by pk on 15/3/24.
//  Copyright (c) 2015年 pk. All rights reserved.
//

#import <UIKit/UIKit.h>

//FinishBlock finishBlock;
//void(^finishBlock)(NSData*);
//finishBlock = ^(NSData* data){
//
//};

typedef void(^FinishBlock)(NSData* data);
typedef void(^FailedBlock)();


@interface MyRequest : NSObject

//请求地址
@property (nonatomic, copy) NSString* url;
//传入的value
@property (nonatomic, copy) NSString* value;
//block 用copy修饰
//完成的回调
@property (nonatomic, copy) FinishBlock finishBlock;
//失败的回调
@property (nonatomic, copy) FailedBlock failedBlock;

//开始请求
- (void)startRequest;

@end
